--------------------------------------------------------
--  DDL for Package Body EDW_LOOKUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_LOOKUP_PKG" AS
/* $Header: poafklkb.pls 120.1 2005/06/13 12:42:35 sriswami noship $  */

Function Lookup_code_fk(
	p_lookup_table			in VARCHAR2,
	p_lookup_type			in VARCHAR2,
	p_lookup_code			in VARCHAR2) return VARCHAR2 IS

v_lookup VARCHAR2(240) := 'NA_EDW';
cursor c is
	select lookup_code_pk
	from edw_lookup_code_fkv
	where lookup_type = p_lookup_type
	and lookup_code = p_lookup_code
	and table_code = p_lookup_table;

BEGIN
if(p_lookup_table is not NULL and
   p_lookup_type is not NULL and
   p_lookup_code is not NULL) then

	OPEN c;
	FETCH c into v_lookup;
	CLOSE c;
end if;

return (v_lookup);


EXCEPTION when others then
      if c%ISOPEN then
         CLOSE c;
      end if;

  return('NA_EDW');

END Lookup_code_fk;


Function Lookup_code_fk(
	p_lookup_table			in VARCHAR2,
	p_lookup_type			in VARCHAR2,
	p_lookup_code			in number) return VARCHAR2 IS

v_lookup VARCHAR2(240) := 'NA_EDW';
cursor c is
	select lookup_code_pk
	from edw_lookup_code_fkv
	where lookup_type = p_lookup_type
	and lookup_code = to_char (p_lookup_code)
	and table_code = p_lookup_table;

BEGIN
if(p_lookup_table is not NULL and
p_lookup_type is not NULL and
p_lookup_code is not NULL) then

	OPEN c;
	FETCH c into v_lookup;
	CLOSE c;
end if;

return (v_lookup);

EXCEPTION when others then
  if c%isopen then
     	close c;
  end if;
  return('NA_EDW');

END Lookup_code_fk;

END EDW_LOOKUP_PKG; --package body

/
