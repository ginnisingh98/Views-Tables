--------------------------------------------------------
--  DDL for Package Body GMAUOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMAUOM" as
/*      $Header: gmauomvb.pls 115.2 2002/02/20 07:39:04 pkm ship       $ */

/* This function will return true if uom_code passed to this function
   exists as unit_of_measure in another row. */
 function isUomCodeThere(
		p_row_id varchar2,
		p_uom_code varchar2) return boolean is

 uom_count number:=0;

 Begin

	select count(*) into uom_count
	from mtl_units_of_measure
	where unit_of_measure = p_uom_code
	and (row_id <> p_row_id
	or p_row_id is null);

	if ( uom_count >= 1) THEN
	  return true;
	else
	  return false;
	end if;
 exception
	when others then
		return false;
 end;

/* This function will return true if unit_of_measure passed to this function
   exists as uom_code in another row. */
 function isUnitOfMeasureThere(
			p_row_id varchar2,
			p_unit_of_measure varchar2) return boolean  is
 uom_count number :=0;

 Begin

	select count(*) into uom_count
	from mtl_units_of_measure
	where uom_code = p_unit_of_measure
	and (row_id <> p_row_id
	or p_row_id is null);

	if ( uom_count >= 1) THEN
	  return true;
	else
	  return false;
	end if;
 exception
	when others then
		return false;
 end;

end gmaUom;

/
