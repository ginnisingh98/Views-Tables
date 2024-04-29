--------------------------------------------------------
--  DDL for Function XXAH_IS_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."XXAH_IS_NUMBER" (p_string in varchar2) return varchar2 is
  v_num NUMBER;
begin
  v_num := to_number(p_string);
  return('Y');
exception
when others then
  return('N');
end xxah_is_number;
 

/
