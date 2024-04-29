--------------------------------------------------------
--  DDL for Package PAY_SE_CWCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_CWCR" AUTHID CURRENT_USER AS
 /* $Header: pysecwcr.pkh 120.0.12010000.2 2008/08/06 08:17:36 ubhat ship $ */

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

	PROCEDURE get_digit_breakup(
		p_number IN NUMBER,
		p_digit1 OUT NOCOPY NUMBER,
		p_digit2 OUT NOCOPY NUMBER,
		p_digit3 OUT NOCOPY NUMBER,
		p_digit4 OUT NOCOPY NUMBER,
		p_digit5 OUT NOCOPY NUMBER,
		p_digit6 OUT NOCOPY NUMBER,
		p_digit7 OUT NOCOPY NUMBER,
		p_digit8 OUT NOCOPY NUMBER,
		p_digit9 OUT NOCOPY NUMBER,
		p_digit10 OUT NOCOPY NUMBER
   );

END PAY_SE_CWCR;

/
