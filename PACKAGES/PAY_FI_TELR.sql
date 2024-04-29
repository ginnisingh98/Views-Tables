--------------------------------------------------------
--  DDL for Package PAY_FI_TELR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_TELR" AUTHID CURRENT_USER AS
/* $Header: pyfitelr.pkh 120.0.12000000.1 2007/01/17 19:29:50 appldev noship $ */


        TYPE XMLREC IS RECORD
        (
            TagName VARCHAR2(240),
            TagValue VARCHAR2(240)
        );

        TYPE TELXML
        IS TABLE OF XMLREC
        INDEX BY BINARY_INTEGER;

        TEL_DATA TELXML;


	PROCEDURE GET_DATA (p_business_group_id	IN NUMBER,
						p_payroll_action_id	IN VARCHAR2 ,
                        p_test_run             IN VARCHAR2,
  			    	    p_template_name			IN VARCHAR2,
						p_xml 						OUT NOCOPY CLOB
			    		);

	PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB);

END PAY_FI_TELR;
 

/
