--------------------------------------------------------
--  DDL for Package Body CS_REPORTS_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_REPORTS_PACKAGE" AS
/*$Header: csxrepb.pls 115.0 99/07/16 09:08:32 porting ship $*/

PROCEDURE cs_get_company_name (rp_company_name IN OUT VARCHAR2,
				           p_sob_id              NUMBER) IS
      CURSOR fetch_company_name IS
      SELECT sob.name
      FROM   gl_sets_of_books sob
      WHERE  sob.set_of_books_id = p_sob_id;
 BEGIN
  OPEN fetch_company_name;
  FETCH fetch_company_name
  INTO  rp_company_name;
  CLOSE fetch_company_name;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     NULL ;
END cs_get_company_name ;

PROCEDURE cs_Get_Report_Name(rp_report_name IN OUT VARCHAR2,
                                            p_conc_request_id NUMBER,
                                            p_report_name     VARCHAR2) IS
   CURSOR report_name IS
   SELECT cp.user_concurrent_program_name
   FROM   FND_CONCURRENT_PROGRAMS_VL cp,
          FND_CONCURRENT_REQUESTS cr
   WHERE  cr.request_id            = p_conc_request_id
     AND  cp.application_id        = cr.program_application_id
     AND  cp.concurrent_program_id = cr.concurrent_program_id;
BEGIN
   OPEN report_name;
   FETCH report_name
   INTO  rp_report_name;
   CLOSE report_name;

EXCEPTION
      WHEN NO_DATA_FOUND
      THEN RP_REPORT_NAME := p_report_name;
END cs_get_report_name;

PROCEDURE Get_P_Struct_Num (p_Item_Struct_Num IN OUT VARCHAR2,
					   return_value      IN OUT NUMBER) IS
   CURSOR get_p_item_struct_num IS
   SELECT structure_id
   FROM   mtl_default_sets_view
   WHERE  functional_area_id = 2 ;
BEGIN
  OPEN get_p_item_struct_num ;
  FETCH get_p_item_struct_num
   INTO p_Item_Struct_Num;

  CLOSE get_p_item_struct_num;
  return_value := 1;

  EXCEPTION
   WHEN OTHERS THEN return_value := 0;
END Get_P_Struct_Num;

END CS_REPORTS_PACKAGE;

/
