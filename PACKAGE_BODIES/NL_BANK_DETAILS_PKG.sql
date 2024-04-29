--------------------------------------------------------
--  DDL for Package Body NL_BANK_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."NL_BANK_DETAILS_PKG" AS
-- $Header: penlbank.pkb 115.8 2002/04/17 03:52:03 pkm ship        $
--
-- Validates the bank account number
--
FUNCTION validate_account_number
( accno IN VARCHAR2) RETURN NUMBER IS

   a number := 0;
   b number := 0;
   c number := 0;
   d number := 0;
   e number := 0;
   f number := 0;
   g number := 0;
   h number := 0;
   i number := 0;
   j number := 0;
   ii varchar2(1);
   a_total number := 0;
   a_rem number := 0;
   a_diff number := 0;
   acno  number := 0;
begin
-- Check for length of the account number
-- If Account number starts with 'P' followed by up to 8
-- numbers, then account is valid, no validations are
-- performed.

if length(accno) >1 then
   ii := substr(accno,1,1);
else
   ii := '';
end if;

if length(accno) >1 and length(accno) <= 9 and upper(ii) = 'P' then
   acno := to_number(substr(accno,2));
   a_rem := length(substr(accno,2));
   if (a_rem > 8) or (acno = 0) or
     (substr(accno,2,1) = ' ') then
      return 1;
   else
      return 0;
   end if;

-- If Account Number is nine characters long, perform the weighted
-- average calculations.

elsif length(accno) =  9 then
      acno := to_number(accno);
      a := to_number(substr(acno,1,1));
      b := to_number(substr(acno,2,1));
      c := to_number(substr(acno,3,1));
      d := to_number(substr(acno,4,1));
      e := to_number(substr(acno,5,1));
      f := to_number(substr(acno,6,1));
      g := to_number(substr(acno,7,1));
      h := to_number(substr(acno,8,1));
      i := to_number(substr(acno,9,1));
      a_total := (a*9) + (b*8) + (c*7) + (d*6) + (e*5) + (f*4) + (g*3) + (h*2);
      a_rem := (a_total - 11*floor(a_total/11));
      if a_rem = 0 then
        a_diff := 0;
      else
        a_diff := 11 - a_rem;
      end if;
      if a_diff = i then
          return 0;
      else
          return 1;
      end if;

-- If Account Number is ten characters long

elsif length(accno) = 10 then
      --acno := to_number(accno);
      a := to_number(substr(accno,1,1));
      b := to_number(substr(accno,2,1));
      c := to_number(substr(accno,3,1));
      d := to_number(substr(accno,4,1));
      e := to_number(substr(accno,5,1));
      f := to_number(substr(accno,6,1));
      g := to_number(substr(accno,7,1));
      h := to_number(substr(accno,8,1));
      i := to_number(substr(accno,9,1));
      j := to_number(substr(accno,10,1));
      a_total := (a*10) + (b*9) + (c*8) + (d*7) + (e*6) + (f*5) + (g*4) + (h*3) + (i*2);
      a_rem := (a_total - 11*floor(a_total/11));
      if a_rem = 0 then
        a_diff := 0;
      else
        a_diff := 11 - a_rem;
      end if;
      if a_diff = j then
          return 0;
      else
          return 1;
      end if;

else
   return 1;
end if;

EXCEPTION
when INVALID_NUMBER then
return 1;
when VALUE_ERROR then
return 1;

end validate_account_number;

end nl_bank_details_pkg;

/
