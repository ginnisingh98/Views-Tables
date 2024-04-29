--------------------------------------------------------
--  DDL for Package ENI_VALUESET_CATEGORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_VALUESET_CATEGORY" AUTHID CURRENT_USER as
/* $Header: ENIITCTS.pls 115.11 2003/08/14 19:41:37 sbag noship $  */

   -- Main procedure for error handling
   -- Standard concurrent manager parameters
   procedure      ENI_POPULATE_MAIN
  ( Errbuf    out NOCOPY Varchar2,
    retcode   out NOCOPY Varchar2
  ) ;

   -- Procedure which actually looks at all values and creates categories
   procedure      ENI_POPULATE_CATEGORY ;

   -- Procedure that validates the structure before calling ENI_POPULATE_CATEGORY
   function      ENI_VALIDATE_STRUCTURE  return boolean;

   -- Procedure that returns the value set is associated with the PRODUCT structure
   function GET_FLEX_VALUE_SET_ID(p_appl_id varchar2,
                                  p_id_flex_code varchar2,
                                  p_vbh_catset_id number)
            return number;

end;

 

/
