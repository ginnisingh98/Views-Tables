--------------------------------------------------------
--  DDL for Package Body IGS_GE_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_NUMBER" AS
/* $Header: IGSGE11B.pls 115.2 2002/02/12 16:57:02 pkm ship    $ */

function to_num(
  p_canonical_number in varchar2)
return number is
begin
  return fnd_number.canonical_to_number(p_canonical_number);
end to_num;

function to_cann(
  p_numberval in number)
return varchar2 is
begin
  return fnd_number.number_to_canonical(p_numberval);
end to_cann;

end IGS_GE_NUMBER;

/
