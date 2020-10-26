/*
 * File: mprfgen.c                                                          
 * Description: Multi-port register file (LUT/Block-RAM based) generator 
 * for Spartan-3, Virtex-4, Virtex-5, Virtex-6 FPGAs and above.
 * Author: Nikolaos Kavvadias <nikolaos.kavvadias@gmail.com>                
 *         2007-2020                 
 * Copyright: (C) 2007-2020 Nikolaos Kavvadias
 * Website: http://www.nkavvadias.com
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>


typedef enum {
  READ_ASYNC = 0,
  READ_FIRST = 1,
  WRITE_FIRST = 2,
  READ_THROUGH = 3
} READ_MODE;

int enable_infer=0, enable_read_mode=READ_ASYNC;
int nwp=1, nrp=2;
unsigned int bw=16, nregs=1024;


/* Print a configurable number of space characters to an output file (specified 
 * by the given filename; the file is assumed already opened).
 */
void print_spaces(FILE *f, int nspaces)
{
  int i;
  
  for (i = 0; i < nspaces; i++)
  {
    fprintf(f, " ");
  }
}

/* fprintf prefixed by a number of space characters. 
 */
void pfprintf(FILE *f, int nspaces, char *fmt, ...)
{
  va_list args;
  print_spaces(f, nspaces);
  va_start(args, fmt);
  vfprintf(f, fmt, args);
  va_end(args);
}

/* TIMESTAMP prints the current YMDHMS date as a time stamp to file f.
 * Example  :
 *   31 May 2001 09:45:54 AM
 * Licensing: This code is distributed under the GNU LGPL license. 
 * Modified : 24 September 2003
 * Author   : John Burkardt
 */
void timestamp(FILE *f)
{
#define TIME_SIZE 40
  static char time_buffer[TIME_SIZE];
  const struct tm *tm;
  time_t now;

  now = time(NULL);
  tm = localtime(&now);
  (void)strftime(time_buffer, TIME_SIZE, "%d %B %Y %I:%M:%S %p", tm);
  fprintf(f, "%s\n", time_buffer);
  return;
#undef TIME_SIZE
}

/* Integer logarithm-2 function (rounds to ceiling).
 */
unsigned int log2c(int inp)
{
  int i, temp, log;

  log = 0;
  temp = 1;

  for (i=0; i<=inp; i++)
  {
    if (temp < inp)
    {
      log  = log + 1;
      temp = temp * 2;
    }
  }

  return (log);
}

/* Writes the corresponding string representation of the given block 
 * RAM read mode.
 */
void decode_read_mode(char *s, READ_MODE val)
{
  switch (val)
  {
    case READ_ASYNC:
      strcpy(s, "READ_ASYNC");
      break;
    case READ_FIRST:
      strcpy(s, "READ_FIRST");
      break;
    case WRITE_FIRST:
      strcpy(s, "WRITE_FIRST");
      break;
    case READ_THROUGH:
      strcpy(s, "READ_THROUGH");
      break;
    default:
      fprintf(stderr, "Error: Unknown block RAM read mode.\n");
      exit(1);
      break;
  }
}

/* Prints the prologue for the generated memory model file. 
 */
void print_mprf_tu_prologue(FILE *infile, char *fname)
{
  pfprintf(infile, 0, "-- File automatically generated by \"mprfgen\".\n\
-- Filename: %s\n", fname);
  fprintf(infile, "-- Date: ");
  timestamp(infile);
  fprintf(infile, "-- Author: Nikolaos Kavvadias 2007-2020\n\n");
  
  pfprintf(infile, 0, "library IEEE;\n");
  pfprintf(infile, 0, "use IEEE.std_logic_1164.all;\n");
  pfprintf(infile, 0, "use IEEE.numeric_std.all;\n");
  pfprintf(infile, 0, "use WORK.util_functions_pkg.all;\n");

  if (enable_infer == 0)
  {
    pfprintf(infile, 0, "library UNISIM;\n");
    pfprintf(infile, 0, "use UNISIM.vcomponents.all;\n");
  }

  fprintf(infile, "\n");
}

/* Prints the entity of the generated memory model. 
 */
void print_mprf_entity(FILE *infile, int num_ni, int num_no)
{
  pfprintf(infile, 0, "entity regfile is\n");
  pfprintf(infile, 2, "generic (\n");
  pfprintf(infile, 4, "NWP           : integer := %d;\n", num_no);
  pfprintf(infile, 4, "NRP           : integer := %d;\n", num_ni);
  pfprintf(infile, 4, "AW            : integer := %d;\n", log2c(nregs));
  pfprintf(infile, 4, "DW            : integer := %d\n", bw);
  pfprintf(infile, 2, ");\n");
  pfprintf(infile, 2, "port (\n");
  pfprintf(infile, 4, "clock         : in  std_logic;\n");
  pfprintf(infile, 4, "reset         : in  std_logic;\n");
  pfprintf(infile, 4, "enable        : in  std_logic;\n");
  pfprintf(infile, 4, "we_v          : in  std_logic_vector(NWP-1 downto 0);\n");
  pfprintf(infile, 4, "re_v          : in  std_logic_vector(NRP-1 downto 0);\n");
  pfprintf(infile, 4, "waddr_v       : in  std_logic_vector(NWP*AW-1 downto 0);\n");
  pfprintf(infile, 4, "raddr_v       : in  std_logic_vector(NRP*AW-1 downto 0);\n");
  pfprintf(infile, 4, "input_data_v  : in  std_logic_vector(NWP*DW-1 downto 0);\n");
  pfprintf(infile, 4, "ram_output_v  : out std_logic_vector(NRP*DW-1 downto 0)\n");
  pfprintf(infile, 2, ");\n");
  pfprintf(infile, 0, "end regfile;\n\n");
}

/* Prints the declaration part of the architecture for the generated memory 
 * model. 
 */
void print_mprf_architecture_prologue(FILE *infile, int num_no)
{
  pfprintf(infile, 0, "architecture rtl of regfile is\n");

  if (enable_infer == 1)
  {
    pfprintf(infile, 2, "component regfile_core\n");
    pfprintf(infile, 4, "generic (\n");
    pfprintf(infile, 6, "AW            : integer :=  5;\n");
    pfprintf(infile, 6, "DW            : integer := 32\n");
    pfprintf(infile, 4, ");\n");
    pfprintf(infile, 4, "port (\n");
    pfprintf(infile, 6, "clock         : in  std_logic;\n");
    pfprintf(infile, 6, "reset         : in  std_logic;\n");
    pfprintf(infile, 6, "enable        : in  std_logic;\n");
    pfprintf(infile, 6, "we            : in  std_logic;\n");
    pfprintf(infile, 6, "re            : in  std_logic;\n");
    pfprintf(infile, 6, "waddr         : in  std_logic_vector(AW-1 downto 0);\n");
    pfprintf(infile, 6, "raddr         : in  std_logic_vector(AW-1 downto 0);\n");
    pfprintf(infile, 6, "input_data    : in  std_logic_vector(DW-1 downto 0);\n");
    pfprintf(infile, 6, "ram_output    : out std_logic_vector(DW-1 downto 0)\n");
    pfprintf(infile, 4, ");\n");
    pfprintf(infile, 2, "end component;\n");
  }
  
  pfprintf(infile, 2, "constant NREGS : integer := 2**AW;\n");
  pfprintf(infile, 2, "type banksel_type is array (NRP-1 downto 0) of std_logic_vector(log2c(NWP)-1 downto 0);\n");

  if (num_no != 1)
  {
    pfprintf(infile, 2, "signal banksel_v    : std_logic_vector(NRP*log2c(NWP)-1 downto 0);\n");
    pfprintf(infile, 2, "signal ia_sel       : banksel_type;\n");
  }
  
  pfprintf(infile, 2, "signal ram_output_i : std_logic_vector((NRP*NWP*DW)-1 downto 0);\n");

  pfprintf(infile, 0, "begin\n");
}

/* Prints the actual block RAM instances. 
 */
void print_mprf_bram_gen(FILE *infile, int num_ni, int num_no)
{
  int i, j;

  if (enable_infer == 1)
  {
    for (j = 0; j < num_ni; j++)
    {
      for (i = 0; i < num_no; i++)
      {
        char s[20];
        decode_read_mode(s, enable_read_mode);
        pfprintf(infile, 2, "nwp_nrp_bram_instance_%d : entity WORK.regfile_core(%s)\n", 
          i*num_ni + j, s);
        pfprintf(infile, 4, "generic map (\n");
        pfprintf(infile, 6, "AW            => AW-log2c(NWP),\n");
        pfprintf(infile, 6, "DW            => DW\n");
        pfprintf(infile, 4, ")\n");
        pfprintf(infile, 4, "port map (\n");
        pfprintf(infile, 6, "clock         => clock,\n");
        pfprintf(infile, 6, "reset         => reset,\n");
        pfprintf(infile, 6, "enable        => enable,\n");
        pfprintf(infile, 6, "we            => we_v(%d),\n", i);
        pfprintf(infile, 6, "re            => re_v(%d),\n", j);
        pfprintf(infile, 6, "waddr         => waddr_v(AW*(%d+1)-log2c(NWP)-1 downto AW*%d),\n", i, i);
        pfprintf(infile, 6, "raddr         => raddr_v(AW*(%d+1)-log2c(NWP)-1 downto AW*%d),\n", j, j);
        pfprintf(infile, 6, "input_data    => input_data_v(DW*(%d+1)-1 downto DW*%d),\n", i, i);
        pfprintf(infile, 6, "ram_output    => ram_output_i(DW*((%d*NRP+%d)+1)-1 downto DW*(%d*NRP+%d))\n", i, j, i, j);
        pfprintf(infile, 4, ");\n\n");
      }
    }
  }
  else
  {
    if ((enable_read_mode == READ_ASYNC) || (enable_read_mode == READ_THROUGH))
    {
      fprintf(stderr, "Error: Unsupported read mode for an instantiated block RAM.\n");
      exit(1);
    }
    
    int k;
    for (j = 0; j < num_ni; j++)
    {
      for (i = 0; i < num_no; i++)
      {
        char s[20];
        decode_read_mode(s, enable_read_mode);
        pfprintf(infile, 2, "nwp_nrp_bram_instance_%d : RAMB16_S36_S36\n", i*num_ni + j);
        pfprintf(infile, 4, "generic map (\n");
        pfprintf(infile, 6, "WRITE_MODE_A => \"%s\",\n", s);
        pfprintf(infile, 6, "WRITE_MODE_B => \"%s\",\n", s);
        for (k = 0; k <= 0x3F; k++)
        {
          pfprintf(infile, 6, "INIT_%02X => X\"0000000000000000000000000000000000000000000000000000000000000000\",\n", k);
        }
        for (k = 0; k <= 0x07; k++)
        { 
          pfprintf(infile, 6, "INITP_%02X => X\"0000000000000000000000000000000000000000000000000000000000000000\"", k);
          if (k < 0x07)
          {
            fprintf(infile, ",");
		  }
		  fprintf(infile, "\n");
        }
        pfprintf(infile, 4, ")\n");
        pfprintf(infile, 4, "port map (\n");
        pfprintf(infile, 6, "DIA           => input_data_v(DW*(%d+1)-1 downto DW*%d),\n", i, i);
        pfprintf(infile, 6, "DIPA          => (others => '0'),\n");
        pfprintf(infile, 6, "ADDRA         => waddr_v(AW*(%d+1)-log2c(NWP)-1 downto AW*%d),\n", i, i);
        pfprintf(infile, 6, "ENA           => enable,\n");
        pfprintf(infile, 6, "WEA           => we_v(%d),\n", i);
        pfprintf(infile, 6, "SSRA          => reset,\n");
        pfprintf(infile, 6, "CLKA          => clock,\n");
        pfprintf(infile, 6, "DOA           => open,\n");
        pfprintf(infile, 6, "DOPA          => open,\n");
        pfprintf(infile, 6, "DIB           => (others => '0'),\n");
        pfprintf(infile, 6, "DIPB          => (others => '0'),\n");
        pfprintf(infile, 6, "ADDRB         => raddr_v(AW*(%d+1)-log2c(NWP)-1 downto AW*%d),\n", j, j);
        pfprintf(infile, 6, "ENB           => enable,\n");
        pfprintf(infile, 6, "WEB           => '0',\n");
        pfprintf(infile, 6, "SSRB          => reset,\n");
        pfprintf(infile, 6, "CLKB          => clock,\n");
        pfprintf(infile, 6, "DOB           => ram_output_i(DW*((%d*NRP+%d)+1)-1 downto DW*(%d*NRP+%d)),\n", i, j, i, j);
        pfprintf(infile, 6, "DOPB          => open\n");
        pfprintf(infile, 4, ");\n\n");
      }
    }
  }
}

/* Prints the concurrent assignments for bank selection. 
 */
void print_mprf_banksel_gen(FILE *infile, int num_ni, int num_no)
{
  if (num_no != 1)
  {
    int i;
    for (i = 0; i < num_ni; i++)
    {
      pfprintf(infile, 2, "banksel_v(log2c(NWP)*(%d+1)-1 downto log2c(NWP)*%d) <= raddr_v(AW*(%d+1)-1 downto AW*(%d+1)-log2c(NWP));\n",
      i, i, i, i);
    }
    fprintf(infile,"\n");
  }
}

/* Prints the necessary code for handling output port multiplexers. 
 */
void print_mprf_outmuxes_gen(FILE *infile, int num_ni, int num_no)
{
  int i;

  if (num_no == 1)
  {
    for (i = 0; i < num_ni; i++)
    {
      pfprintf(infile, 2, "ram_output_v(DW*(%d+1)-1 downto DW*%d) <= ram_output_i(DW*(%d+1)-1 downto DW*%d);\n",
      i, i, i, i);
    }
  }
  else
  {
    int j;
    for (j = 0; j < num_ni; j++)
    {
      pfprintf(infile, 2, "process (ram_output_i, banksel_v)\n");
      pfprintf(infile, 4, "variable ia_sel_part : integer range 0 to NWP-1;\n");
      pfprintf(infile, 2, "begin\n");
      pfprintf(infile, 4, "ia_sel(%d) <= banksel_v(log2c(NWP)*(%d+1)-1 downto log2c(NWP)*%d);\n", j, j, j);
      pfprintf(infile, 4, "ia_sel_part := to_integer(unsigned(ia_sel(%d)));\n", j);
      pfprintf(infile, 4, "case ia_sel_part is\n");

      for (i = 0; i < num_no; i++)
      {
        pfprintf(infile, 6, "when %d      => ram_output_v(DW*(%d+1)-1 downto DW*%d) <= ram_output_i(DW*(%d+%d*NRP+1)-1 downto DW*(%d+%d*NRP));\n",
        i, j, j, j, i, j, i);
      }

      pfprintf(infile, 6, "when others => ram_output_v(DW*(%d+1)-1 downto DW*%d) <= (others => '0');\n", j, j);
      pfprintf(infile, 4, "end case;\n");
      pfprintf(infile, 2, "end process;\n\n");
    }
  }
}

/* Generates the architecture body of the memory model. 
 */
void print_mprf_architecture_body(FILE *infile, int num_ni, int num_no)
{
  print_mprf_bram_gen(infile, num_ni, num_no);
  print_mprf_banksel_gen(infile, num_ni, num_no);
  print_mprf_outmuxes_gen(infile, num_ni, num_no);
}

/* print_mprf_epilogue:
 * Prints the epilogue of the architecture for the generated memory model. 
 */
void print_mprf_epilogue(FILE *infile)
{
  fprintf(infile, "end rtl;\n");
}

/* Print usage instructions for the "mprfgen" program.
 */
static void print_usage()
{
  printf("\n");
  printf("* Usage:\n");
  printf("* mprfen [options] <out.vhd>\n");
  printf("* Example: ./mprfgen -infer -read-first -nwp 2 -nrp 3 file.vhd\n");
  printf("* \n");
  printf("* Options:\n");
  printf("*   -h:           Print this help.\n");
  printf("*   -infer:       Use generic RAM storage that can be inferred as\n");
  printf("*                 block RAM(s).\n");
  printf("*   -<read-mode>: Read mode supported by the generated RAM. Valid\n");
  printf("*                 options: {read-async, read-first, write-first,\n");
  printf("*                 read-through}. \"read-through\" cannot be used for\n");
  printf("*                 for block RAM instantiation. Default is \"read-async\"\n");
  printf("*   -nwp <num>:   Number of write ports for the register file\n");
  printf("*                 (default: 1).\n");
  printf("*   -nrp <num>:   Number of read ports for the register file\n");
  printf("*                 (default: 2).\n");
  printf("*   -bw <num>:    Bitwidth for each memory entry (default: 16).\n");
  printf("*   -nregs <num>: Memory size (default: 1024).\n");
  printf("* \n\n");
}

/* Program entry.
 */
int main(int argc, char **argv)
{
  FILE *file_o = NULL;
  char *file_name = NULL;
  int i;

  /* Command-line argument passing. */
  if (argc < 2)
  {
    print_usage();
    return EXIT_SUCCESS;
  }

  for (i = 1; i < argc; i++)
  {
    if (strcmp("-h",argv[i]) == 0)
    {
      print_usage();
      exit(EXIT_FAILURE);
    }
    else if (strcmp("-infer",argv[i]) == 0)
    {
      enable_infer = 1;
    }
    else if (strcmp("-read-async",argv[i]) == 0)
    {
      enable_read_mode = READ_ASYNC;
    }
    else if (strcmp("-read-first",argv[i]) == 0)
    {
      enable_read_mode = READ_FIRST;
    }
    else if (strcmp("-write-first",argv[i]) == 0)
    {
      enable_read_mode = WRITE_FIRST;
    }
    else if (strcmp("-read-through",argv[i]) == 0)
    {
      enable_read_mode = READ_THROUGH;
    }
    else if (strcmp("-nwp",argv[i]) == 0)
    {
      if ((i+1) < argc)
      {
        i++;
        nwp = atoi(argv[i]);
      }
    }
    else if (strcmp("-nrp",argv[i]) == 0)
    {
      if ((i+1) < argc)
      {
        i++;
        nrp = atoi(argv[i]);
      }
    }
    else if (strcmp("-bw",argv[i]) == 0)
    {
      if ((i+1) < argc)
      {
        i++;
        bw = atoi(argv[i]);
      }
    }
    else if (strcmp("-nregs",argv[i]) == 0)
    {
      if ((i+1) < argc)
      {
        i++;
        nregs = atoi(argv[i]);
      }
    }
    else
    {
      if (argv[i][0] != '-')
      {
        file_o = fopen(argv[i], "wb");
        if (file_o == NULL)
        {
          fprintf(stderr,"Error: Can't write %s!\n", argv[i]);
          return -1;
        }
        file_name = malloc((strlen(argv[i])+1) * sizeof(char));
        strcpy(file_name, argv[i]);
      }
    }
  }

  /* The actual logic of the "mprfgen" program. */
  print_mprf_tu_prologue(file_o, file_name);
  print_mprf_entity(file_o, nrp, nwp);
  print_mprf_architecture_prologue(file_o, nwp);
  print_mprf_architecture_body(file_o, nrp, nwp);
  print_mprf_epilogue(file_o);

  fclose(file_o);
  free(file_name);

  return 0;
}
