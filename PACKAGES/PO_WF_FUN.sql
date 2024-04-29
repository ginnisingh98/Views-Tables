--------------------------------------------------------
--  DDL for Package PO_WF_FUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WF_FUN" AUTHID CURRENT_USER AS
/* $Header: powffuns.pls 120.0 2005/06/01 20:20:29 appldev noship $ */

cursor wf_functions_cursor(x_item_type varchar2) is
  select distinct substr(wa.function,1,instr(wa.function,'.')-1) package_name,
         substr(wa.function,instr(wa.function,'.')+1) procedure_name,
         wa.item_type,
         wa.name
  from   wf_activities wa
  where  wa.type='FUNCTION'
    and  wa.function like 'PO%'
    and  wa.item_type like x_item_type;

--bug4025028 start
-- Removed the hardcoded 'APPS' for the owner and passing it as a parameter to the cursor
--bug4025028 end
cursor wf_function_codes_cursor(x_package_name  varchar2,
                                x_line_s       number,
                                x_line_e       number,
                                p_apps_schema_name varchar2)  is --bug4025028
  select text, line
    from all_source
   where name = x_package_name
     and owner= p_apps_schema_name --bug4025028
     and type='PACKAGE BODY'
     and line > x_line_s and line < x_line_e
  and (upper(text) like '%SETITEMATTR%'
   or  upper(text) like '%GETITEMATTR%'
   or  upper(text) like '%SETITEMUSERKEY%'
   or  upper(text) like '%SETITEMOWNER%'
   or  upper(text) like '%UPDATE %'
   or upper(text) like '%INSERT %INTO%'  );


PROCEDURE PRINT_FUNCTION(x_item_type varchar2);

END PO_WF_FUN;

 

/
