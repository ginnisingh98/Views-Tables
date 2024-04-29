--------------------------------------------------------
--  DDL for Package Body FND_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_NUMBER" as
/* $Header: AFNUMBRB.pls 115.15 2004/08/19 19:10:39 dmcmahon ship $ */

  C_FORMAT constant varchar2(60) :=
                    'FM999999999999999999999.99999999999999999999';

--
--  Canonical functions
--

  function canonical_to_number(
    canonical varchar2)
  return number is
    decimal_char varchar2(1);
  begin
    if (canonical_mask <> C_FORMAT) then -- old behavior for 3757291
      return to_number(canonical, canonical_mask);
    end if;
    decimal_char := substr(ltrim(to_char(.3,'0D0')),2,1);
    return round(to_number(translate(canonical, '.', decimal_char)), 20);
  end canonical_to_number;

  function number_to_canonical(
    numberval number)
  return varchar2 is
    decimal_char varchar2(1);
  begin
    if (canonical_mask <> C_FORMAT) then -- old behavior for 3757291
      return rtrim(to_char(numberval, canonical_mask),'.');
    end if;
    decimal_char := substr(ltrim(to_char(.3,'0D0')),2,1);
    return translate(to_char(round(numberval, 20)), decimal_char, '.');
  end number_to_canonical;

--  use 'set serverout on;' to see the output from this test program

  procedure test is
    pi number := 3.1415;
    my_char varchar2(20);
  begin
/*
    DBMS_OUTPUT.PUT_LINE('Decimal separator is '||fnd_number.decimal_char);
    DBMS_OUTPUT.PUT_LINE('Group separator is '||fnd_number.group_separator);
    DBMS_OUTPUT.PUT_LINE('Canonical mask is '||fnd_number.canonical_mask);

    DBMS_OUTPUT.PUT_LINE('Canon number is '||fnd_number.number_to_canonical(pi));
    DBMS_OUTPUT.PUT_LINE('and back is '||to_char(fnd_number.canonical_to_number('3.14')));
    DBMS_OUTPUT.PUT_LINE('Canon integer is '||fnd_number.number_to_canonical(4));
    select fnd_number.number_to_canonical(pi)
    into my_char
    from dual;

    DBMS_OUTPUT.PUT_LINE('Canon number from SQL is '||my_char);

*/
    NULL;
  end;


  procedure initialize is

  begin
   canonical_mask  := C_FORMAT;
   decimal_char    := substr(ltrim(to_char(.3,'0D0')),2,1);
   group_separator := substr(ltrim(to_char(1032,'0G999')),2,1);
  end ;


begin
  canonical_mask := C_FORMAT;

-- OK, this is a bit kludgey, but I can't seem to find any way to access
-- the numeric characters directly.
  decimal_char := substr(ltrim(to_char(.3,'0D0')),2,1);
  group_separator := substr(ltrim(to_char(1032,'0G999')),2,1);
end FND_NUMBER;

/
