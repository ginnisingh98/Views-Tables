--------------------------------------------------------
--  DDL for Package PAY_IE_TAX_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_TAX_VAL" AUTHID CURRENT_USER as
/* $Header: pyietxvl.pkh 120.1.12010000.1 2008/07/27 22:51:52 appldev ship $ */


PROCEDURE count_validation(
        errbuf          OUT NOCOPY VARCHAR2
        , retcode       OUT NOCOPY VARCHAR2
        , p_employer_number IN  VARCHAR2
        , p_tax_year    IN  pay_ie_tax_header_interface.tax_year%TYPE);


PROCEDURE valinsupd (
 errbuf 		OUT NOCOPY VARCHAR2
, retcode 		OUT NOCOPY VARCHAR2
, p_employer_number 	IN VARCHAR2
, p_tax_year 		IN NUMBER
, p_validate_mode 	IN VARCHAR2 :='IE_VALIDATE'
, p_payroll_id	 	IN NUMBER := NULL
);


PROCEDURE getparam(
   errbuf 		OUT NOCOPY VARCHAR2
 , retcode 		OUT NOCOPY VARCHAR2
 , p_data_file 		IN VARCHAR2
 , p_employer_number 	IN VARCHAR2
 , p_tax_year 		IN NUMBER
 , p_validate_mode 	IN VARCHAR2 :='IE_VALIDATE'
 , p_payroll_id	 	IN NUMBER := NULL
 );

-- Bug Fix 3500192
PROCEDURE log_ie_paye_header;

PROCEDURE log_ie_paye_body(
   p_paye_details_id  IN NUMBER
 , p_pps_number	     IN VARCHAR2
 , p_employee_number  IN VARCHAR2
 );

PROCEDURE log_ie_paye_footer(p_total IN NUMBER);

end PAY_IE_TAX_VAL;

/
