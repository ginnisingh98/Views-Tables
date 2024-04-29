--------------------------------------------------------
--  DDL for Package CS_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CTX_PKG" AUTHID CURRENT_USER AS
/* $Header: cscuctxs.pls 115.0 99/07/16 08:56:23 porting ship $ */

 PROCEDURE Get_Context_Stop_Words(stop_word_list OUT VARCHAR2,
                         policy1 IN VARCHAR2 default NULL,
                         policy2 IN VARCHAR2 default NULL,
                         policy3 IN VARCHAR2 default NULL,
                         policy4 IN VARCHAR2 default NULL);


 PROCEDURE Clean_Results_Table(results_table IN VARCHAR2,
					conid1 	     IN NUMBER DEFAULT 0,
					conid2 	     IN NUMBER DEFAULT 0,
					conid3 	     IN NUMBER DEFAULT 0,
					conid4 	     IN NUMBER DEFAULT 0
					);

 PROCEDURE Update_Context_Index(policy_name IN VARCHAR2,
					primary_key IN VARCHAR2
					);

 PROCEDURE Get_Conids(sequence_name IN VARCHAR2,
				  no_of_conids  IN NUMBER,
				  conid1 	      OUT NUMBER,
				  conid2 	      OUT NUMBER,
				  conid3 	      OUT NUMBER,
				  conid4 	      OUT NUMBER
				  );

 PROCEDURE Search(policy1       IN VARCHAR2,
                  policy2       IN VARCHAR2,
                  policy3       IN VARCHAR2,
                  policy4       IN VARCHAR2,
			   stop_words    IN VARCHAR2,
                  search_string IN VARCHAR2,
                  search_option IN VARCHAR2,-- 'AND', 'OR', 'EXACT'
                  results_table IN VARCHAR2,
                  conid1        IN NUMBER,-- unique id for policy1
                  conid2        IN NUMBER,-- unique id for policy2
                  conid3        IN NUMBER,-- unique id for policy3
                  conid4        IN NUMBER-- unique id for policy4
                  );

 PROCEDURE Get_Result_Table(result_table  OUT VARCHAR2);

 PROCEDURE Release_Result_Table(result_table IN VARCHAR2);

END;

 

/
