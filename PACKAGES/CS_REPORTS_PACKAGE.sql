--------------------------------------------------------
--  DDL for Package CS_REPORTS_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_REPORTS_PACKAGE" AUTHID CURRENT_USER AS
/*$Header: csxreps.pls 115.0 99/07/16 09:08:36 porting ship $*/

PROCEDURE cs_get_company_name (rp_company_name IN OUT VARCHAR2,
						 p_sob_id              NUMBER);
PROCEDURE CS_get_Report_Name(rp_report_name IN OUT VARCHAR2,
                          p_conc_request_id NUMBER,
                          p_report_name     VARCHAR2) ;
PROCEDURE Get_P_Struct_Num (p_Item_Struct_Num IN OUT VARCHAR2,
					   return_value      IN OUT NUMBER) ;
END CS_REPORTS_PACKAGE;

 

/
