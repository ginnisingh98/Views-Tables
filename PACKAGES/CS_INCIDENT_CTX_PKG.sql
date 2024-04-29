--------------------------------------------------------
--  DDL for Package CS_INCIDENT_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INCIDENT_CTX_PKG" AUTHID CURRENT_USER AS
/* $Header: cssrctxs.pls 115.0 99/07/16 09:02:12 porting ship $ */

 PROCEDURE Execute_Query_Contains(str1 IN VARCHAR2,str2 IN VARCHAR2,
		str3 IN VARCHAR2,str4 IN VARCHAR2, result_table IN VARCHAR2);

 PROCEDURE Update_Context_Index(policy_name IN VARCHAR2, primary_key IN VARCHAR2);

 PROCEDURE Get_Context_Stop_Words(stop_word_list OUT VARCHAR2);

 PROCEDURE Get_Result_Table(result_table  OUT VARCHAR2);

 PROCEDURE Release_Result_Table(result_table IN VARCHAR2);

END;

 

/
