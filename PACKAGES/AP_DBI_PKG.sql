--------------------------------------------------------
--  DDL for Package AP_DBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_DBI_PKG" AUTHID CURRENT_USER AS
/* $Header: apdbiges.pls 120.0 2005/08/11 02:52:14 ajmcguir noship $ */

TYPE r_dbi_key_value_arr IS TABLE OF NUMBER(15);

-- Public Procedure Specification

PROCEDURE Maintain_DBI_Summary(P_Table_Name IN VARCHAR2,
                        	P_Operation IN VARCHAR2,
                        	P_Key_Value1 IN NUMBER DEFAULT NULL,
                        	P_Key_Value2 IN NUMBER DEFAULT NULL,
				P_Key_Value_List IN
					AP_DBI_PKG.r_dbi_key_value_arr
					DEFAULT NULL,
				P_Calling_Sequence in VARCHAR2);

PROCEDURE Insert_Payment_Confirm_DBI(
          p_checkrun_name      IN VARCHAR2,
          p_base_currency_code IN VARCHAR2,
          p_key_table          IN VARCHAR2,
          p_calling_sequence   IN VARCHAR2,
          p_debug_mode         IN VARCHAR2 default 'N');

END AP_DBI_PKG;



 

/
