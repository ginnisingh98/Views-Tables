--------------------------------------------------------
--  DDL for Package Body FND_HASH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_HASH_PKG" as
/* $Header: AFCPHSHB.pls 115.5 2003/09/20 15:32:23 ckclark ship $ */

  type inttab is table of binary_integer index by binary_integer;
  type numtab is table of number         index by binary_integer;

  CRCARRAY numtab;
  CRCFLAG  boolean := null;

  /*
  ** Returns a table of XOR results for 4-bit nibbles.
  ** This is needed because PL/SQL has no way to do XOR natively,
  ** so a lookup table is used.  A table of 8-bit bytes would
  ** be 65536 entries long, so byte values are XORed in 4-bit
  ** nibbles, and a small table of 256 results is sufficient.
  */
  function HEXNIBBLE return varchar2 is
  begin
    return('0123456789ABCDEF'||
           '1032547698BADCFE'||
           '23016745AB89EFCD'||
           '32107654BA98FEDC'||
           '45670123CDEF89AB'||
           '54761032DCFE98BA'||
           '67452301EFCDAB89'||
           '76543210FEDCBA98'||
           '89ABCDEF01234567'||
           '98BADCFE10325476'||
           'AB89EFCD23016745'||
           'BA98FEDC32107654'||
           'CDEF89AB45670123'||
           'DCFE98BA54761032'||
           'EFCDAB8967452301'||
           'FEDCBA9876543210');
  end HEXNIBBLE;

  /*
  ** Compute the XOR of two integers and return an
  ** integer result, modulo 32 bits.
  */
  function XOR32(B1 in number, B2 in number)
    return number
  is
    A1       number;
    A2       number;
    NIBBLE1  number;
    NIBBLE2  number;
    NIBBLE3  number;
    NIBBLE4  number;
    NIBBLE5  number;
    NIBBLE6  number;
    NIBBLE7  number;
    NIBBLE8  number;
    HEXTABLE varchar2(256);
    CHARBIN  varchar2(16);
  begin
    A1 := B1;
    A2 := B2;
    NIBBLE1 := mod(A1, 16) * 16 + mod(A2, 16) + 1;
    A1 := trunc(A1/16);
    A2 := trunc(A2/16);
    NIBBLE2 := mod(A1, 16) * 16 + mod(A2, 16) + 1;
    A1 := trunc(A1/16);
    A2 := trunc(A2/16);
    NIBBLE3 := mod(A1, 16) * 16 + mod(A2, 16) + 1;
    A1 := trunc(A1/16);
    A2 := trunc(A2/16);
    NIBBLE4 := mod(A1, 16) * 16 + mod(A2, 16) + 1;
    A1 := trunc(A1/16);
    A2 := trunc(A2/16);
    NIBBLE5 := mod(A1, 16) * 16 + mod(A2, 16) + 1;
    A1 := trunc(A1/16);
    A2 := trunc(A2/16);
    NIBBLE6 := mod(A1, 16) * 16 + mod(A2, 16) + 1;
    A1 := trunc(A1/16);
    A2 := trunc(A2/16);
    NIBBLE7 := mod(A1, 16) * 16 + mod(A2, 16) + 1;
    A1 := trunc(A1/16);
    A2 := trunc(A2/16);
    NIBBLE8 := mod(A1, 16) * 16 + mod(A2, 16) + 1;

    HEXTABLE := HEXNIBBLE;

    CHARBIN := '0123456789ABCDEF';

    return((instr(CHARBIN,substr(HEXTABLE,NIBBLE1,1))-1) +
           (instr(CHARBIN,substr(HEXTABLE,NIBBLE2,1))-1)*16 +
           (instr(CHARBIN,substr(HEXTABLE,NIBBLE3,1))-1)*16*16 +
           (instr(CHARBIN,substr(HEXTABLE,NIBBLE4,1))-1)*16*16*16 +
           (instr(CHARBIN,substr(HEXTABLE,NIBBLE5,1))-1)*16*16*16*16 +
           (instr(CHARBIN,substr(HEXTABLE,NIBBLE6,1))-1)*16*16*16*16*16 +
           (instr(CHARBIN,substr(HEXTABLE,NIBBLE7,1))-1)*16*16*16*16*16*16 +
           (instr(CHARBIN,substr(HEXTABLE,NIBBLE8,1))-1)*16*16*16*16*16*16*16.0);

  end XOR32;

  /*
  ** Compute an array of 32-bit CRC values
  */
  procedure CRCINIT
  is
    A binary_integer;
    B binary_integer;
    X number;
  begin
    if (CRCFLAG is null) then
      for A in 1..256 loop
        X := A - 1;
        for B in 1..8 loop
          if (MOD(X, 2) = 1) then
            X := XOR32(trunc(X/2), 3988292384);
          else
            X := trunc(X/2);
          end if;
        end loop;
        CRCARRAY(A) := mod(X, 4294967296);
      end loop;
      CRCFLAG := TRUE;
    end if;
  end CRCINIT;

  function CRC32(DATASTRING in varchar2)
    return number
  is
    DATAINT    inttab;
    SLEN       binary_integer;
    DLEN       binary_integer;
    KLOC       binary_integer;
    KTEMP      binary_integer;
    TINDEX     binary_integer;
    CRCRESULT  number;
  begin

    -- Initialize CRC table
    CRCINIT;

    -- Turn the data string into a series of binary integer byte values
    DLEN := 0;
    SLEN := length(DATASTRING);
    for KLOC in 1..SLEN loop
      KTEMP := ascii(substr(DATASTRING,KLOC,1));
      if (KTEMP >= 256 * 256 * 256) then
        DATAINT(DLEN + 4) := mod(KTEMP, 256);
        KTEMP := (KTEMP - mod(KTEMP, 256))/256;
        DATAINT(DLEN + 3) := mod(KTEMP, 256);
        KTEMP := (KTEMP - mod(KTEMP, 256))/256;
        DATAINT(DLEN + 2) := mod(KTEMP, 256);
        KTEMP := (KTEMP - mod(KTEMP, 256))/256;
        DATAINT(DLEN + 1) := mod(KTEMP, 256);
        DLEN := DLEN + 4;
      elsif (KTEMP >= 256 * 256) then
        DATAINT(DLEN + 3) := mod(KTEMP, 256);
        KTEMP := (KTEMP - mod(KTEMP, 256))/256;
        DATAINT(DLEN + 2) := mod(KTEMP, 256);
        KTEMP := (KTEMP - mod(KTEMP, 256))/256;
        DATAINT(DLEN + 1) := mod(KTEMP, 256);
        DLEN := DLEN + 3;
      elsif (KTEMP >= 256) then
        DATAINT(DLEN + 2) := mod(KTEMP, 256);
        KTEMP := (KTEMP - mod(KTEMP, 256))/256;
        DATAINT(DLEN + 1) := mod(KTEMP, 256);
        DLEN := DLEN + 2;
      else
        DLEN := DLEN + 1;
        DATAINT(DLEN) := mod(KTEMP, 256);
      end if;
    end loop;

    -- Loop through the data string and compute the CRC result
    CRCRESULT := 4294967295;
    for KLOC in 1..DLEN loop
      TINDEX := mod(XOR32(CRCRESULT, DATAINT(KLOC)), 256) + 1;
      CRCRESULT := XOR32(CRCARRAY(TINDEX), trunc(CRCRESULT/256));
    end loop;

    CRCRESULT := XOR32(CRCRESULT, 4294967295);

    return(CRCRESULT);
  end CRC32;

end FND_HASH_PKG;

/
