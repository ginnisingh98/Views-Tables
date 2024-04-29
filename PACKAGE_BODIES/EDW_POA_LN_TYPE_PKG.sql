--------------------------------------------------------
--  DDL for Package Body EDW_POA_LN_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_POA_LN_TYPE_PKG" AS
/* $Header: poafkltb.pls 120.1 2005/06/13 12:48:28 sriswami noship $  */
VERSION	CONSTANT CHAR(80) := '$Header: poafkltb.pls 120.1 2005/06/13 12:48:28 sriswami noship $';

Function Line_type_fk(
	p_order_type			in VARCHAR2) return VARCHAR2 IS

l_linetype VARCHAR2(240) := 'NA_EDW';
cursor c is
	select line_type_pk
	from edw_poa_ln_type_lcv
	where order_type = p_order_type;
BEGIN
return(upper(p_order_type));
if(p_order_type is not NULL) then

	OPEN c;
	FETCH c into l_linetype;
	CLOSE c;
end if;

return (l_linetype);


EXCEPTION when others then
  close c;
  return('NA_EDW ');
END Line_type_fk;


END; --package body

/
