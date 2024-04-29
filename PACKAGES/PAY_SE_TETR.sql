--------------------------------------------------------
--  DDL for Package PAY_SE_TETR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_TETR" AUTHID CURRENT_USER AS
 /* $Header: pysetetr.pkh 120.0.12000000.1 2007/07/11 12:31:50 dbehera noship $ */

        TYPE tagdata IS RECORD
        (
            TagName VARCHAR2(240),
            TagValue VARCHAR2(240)
        );

        TYPE ttagdata
        IS TABLE OF tagdata
        INDEX BY BINARY_INTEGER;

        gtagdata ttagdata;



	PROCEDURE GET_DATA (
				p_business_group_id				IN NUMBER,
				p_payroll_action_id       				IN  VARCHAR2 ,
  			        p_template_name					IN VARCHAR2,
				p_xml 								OUT NOCOPY CLOB
			    );

	PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB);

END PAY_SE_TETR;

 

/
