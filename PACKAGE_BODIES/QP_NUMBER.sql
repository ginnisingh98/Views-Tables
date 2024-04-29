--------------------------------------------------------
--  DDL for Package Body QP_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_NUMBER" as
/* $Header: QPNUMBRB.pls 120.0 2005/06/02 00:22:55 appldev noship $ */



--
--  Canonical functions
--

  function canonical_to_number(
    canonical varchar2)
  return number is
  begin
    return to_number(canonical, canonical_mask);
  end canonical_to_number;

  function number_to_canonical(
    numberval number)
  return varchar2 is
  begin
    return rtrim(to_char(numberval, canonical_mask),'.');
  end number_to_canonical;

--  use 'set serverout on;' to see the output from this test program

  procedure test is
    pi number := 3.1415;
    my_char varchar2(20);
  begin
/*
    DBMS_OUTPUT.PUT_LINE('Decimal separator is '||qp_number.decimal_char);
    DBMS_OUTPUT.PUT_LINE('Group separator is '||qp_number.group_separator);
    DBMS_OUTPUT.PUT_LINE('Canonical mask is '||qp_number.canonical_mask);

    DBMS_OUTPUT.PUT_LINE('Canon number is '||qp_number.number_to_canonical(pi));
    DBMS_OUTPUT.PUT_LINE('and back is '||to_char(qp_number.canonical_to_number('3.14')));
    DBMS_OUTPUT.PUT_LINE('Canon integer is '||qp_number.number_to_canonical(4));
    select qp_number.number_to_canonical(pi)
    into my_char
    from dual;

    DBMS_OUTPUT.PUT_LINE('Canon number from SQL is '||my_char);

*/
    NULL;
  end;


  procedure initialize is

  begin
   canonical_mask  := 'FM999999999999999999999.99999999999999999999';
   decimal_char    := substr(ltrim(to_char(.3,'0D0')),2,1);
   group_separator := substr(ltrim(to_char(1032,'0G999')),2,1);
  end ;


begin
  canonical_mask := 'FM999999999999999999999.99999999999999999999';

-- OK, this is a bit kludgey, but I can't seem to find any way to access
--XS the numeric characters directly.
  decimal_char := substr(ltrim(to_char(.3,'0D0')),2,1);
  group_separator := substr(ltrim(to_char(1032,'0G999')),2,1);
end QP_NUMBER;

/
