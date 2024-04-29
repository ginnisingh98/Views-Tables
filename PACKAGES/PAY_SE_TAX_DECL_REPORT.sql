--------------------------------------------------------
--  DDL for Package PAY_SE_TAX_DECL_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_TAX_DECL_REPORT" AUTHID CURRENT_USER AS
/* $Header: pysetadr.pkh 120.1.12000000.1 2007/04/24 07:10:57 rsahai noship $ */
        TYPE tagdata IS RECORD
        (
            TagName VARCHAR2(240),
            TagValue VARCHAR2(240)
        );
        TYPE ttagdata
        IS TABLE OF tagdata
        INDEX BY BINARY_INTEGER;
        gplsqltable ttagdata;

  function get_archive_payroll_action_id(p_payroll_action_id in number)
  return number;
       PROCEDURE get_data (
             p_business_group_id  in varchar2, --temp removal ..shoud be added for G
          p_payroll_action_id       				IN  VARCHAR2 ,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   );

	PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB);
	 PROCEDURE get_digit_breakup(
      p_amount IN NUMBER,
      p_digit1 OUT NOCOPY NUMBER,
      p_digit2 OUT NOCOPY NUMBER,
      p_digit3 OUT NOCOPY NUMBER,
      p_digit4 OUT NOCOPY NUMBER,
      p_digit5 OUT NOCOPY NUMBER,
      p_digit6 OUT NOCOPY NUMBER,
      p_digit7 OUT NOCOPY NUMBER,
      p_digit8 OUT NOCOPY NUMBER,
      p_digit9 OUT NOCOPY NUMBER
   );

PROCEDURE GET_XML
(
	p_business_group_id	IN	NUMBER,
	p_payroll_action_id	IN	VARCHAR2 ,
  	p_template_name		IN	VARCHAR2,
	p_xml 			OUT	NOCOPY CLOB
	);


END PAY_SE_TAX_DECL_REPORT;


 

/
