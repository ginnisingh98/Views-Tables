--------------------------------------------------------
--  DDL for Package Body IGS_GE_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_DATE" AS
/* $Header: IGSGE10B.pls 115.2 2002/02/12 16:56:58 pkm ship    $ */

function igsdate(
  p_canonical_date in varchar2)
return date is
begin
  return fnd_date.canonical_to_date(p_canonical_date);
end igsdate;

function igschar(
  p_dateval in date)
return varchar2 is
begin
  return to_char(p_dateval, 'YYYY/MM/DD');
end igschar;

function igscharDT(
  p_dateval in date)
return varchar2 is
begin
  return fnd_date.date_to_canonical(p_dateval);
end igscharDT;

end IGS_GE_DATE;

/
