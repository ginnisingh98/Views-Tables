--------------------------------------------------------
--  DDL for Package Body XDP_CRYPT_TOOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_CRYPT_TOOLS" AS
/* $Header: XDPCRPTB.pls 120.2 2006/04/10 23:20:30 dputhiye noship $ */


Function getprivatekey return varchar2;

Function Convbin(c1 in char) return char
IS
 loop1 number;
 value number;
 divis number;
 r1 varchar2(30);

BEGIN
 r1 := '';
 value := ascii(c1);
 divis := 128;
  for loop1 in 0..7 loop
   if trunc(value/divis) = 1 then
     r1 := r1 || '1';
   else
   r1 := r1 || '0';
   end if;
  value := value mod divis;
  divis := divis / 2;
 end loop;
 return r1;
END Convbin;

Function getprivatekey  return varchar2
IS
 haha varchar2(40);
 huh varchar2(40);
 temp varchar2(80);
 gee varchar2(80);

BEGIN
   haha := 'WOANGIRUNSO';
   gee := '897456HE89FDGN8945';
   gee := '789Y45GBNR57IBFY89';
   huh := 'KJGIHNDFSDOIJG';

   temp := haha || huh;
   return temp;
END getprivatekey;

Function XORBIN(c1 in char, c2 in char) return char
IS
 loop1 number;
 loop11 number;
 r1 varchar2(8);
 r2 varchar2(8);
 r3 number;
 result varchar2(40);
 divis number;

BEGIN
 result := '';
  for loop1 in 1..length(c1) loop
   r1 := convbin(substr(c1,loop1,1));
   r2 := convbin(substr(c2,loop1,1));
   divis := 128;
   r3 := 0;
    for loop11 in 1..8 loop
     if to_number(substr(r1,loop11,1))+to_number(substr(r2,loop11,1))=1
     then
       r3 := r3 + divis;
     end if;
     divis := divis / 2;
    end loop;
   result := result || fnd_global.local_chr(r3);
  end loop;
 return(result);
end XORBIN;




Function GetKey(key in varchar2)  return varchar2
IS
 temp varchar2(80);
 hmm varchar2(40);
 uhuh varchar2(40);

 gee varchar2(80);

 hehe varchar2(80);
BEGIN
 hmm := 'MGDGDDNDFGDIUH';

 /* this is ajust junk */
 gee := 'GKFDFKJKDKJDFKDFGD';
 gee := '89NJIGF78GFDB89DF';
 uhuh := 'JKDFIUHTER';
 gee := 'JBG9854NGDF789TDF';
 /* This is just junk man */

 hehe := hmm || uhuh;
 if key = hehe then
    temp := getprivatekey;
 else
    temp := NULL;
 end if;

 return temp;
   return temp;
END GetKey;


Function Encrypt(target in varchar2, key in varchar2) return varchar2
IS
result varchar2(100);

BEGIN
 if target is NULL then
    return NULL;
 end if;
 result := XORBIN(target,key);
 return result;
END Encrypt;



end xdp_crypt_tools;

/
