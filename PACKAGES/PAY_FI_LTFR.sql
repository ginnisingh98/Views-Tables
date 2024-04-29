--------------------------------------------------------
--  DDL for Package PAY_FI_LTFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_LTFR" AUTHID CURRENT_USER AS
 /* $Header: pyfiltfr.pkh 120.0.12000000.1 2007/01/17 19:24:55 appldev noship $ */

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

END PAY_FI_LTFR;

 

/
