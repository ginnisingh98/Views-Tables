--------------------------------------------------------
--  DDL for Package PAY_GB_P6EDI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P6EDI_PKG" AUTHID CURRENT_USER AS
/* $Header: pygbp6ei.pkh 120.2 2007/11/02 10:04:30 dchindar noship $ */
--
--
-- --------------- p6 upload process ---------------------
--
-- uploads p6 information from flat file into
-- pay_gb_tax_code_interface table
--
PROCEDURE upload_p6(errbuf OUT NOCOPY VARCHAR2,
                    retcode OUT NOCOPY NUMBER,
                    p_request_id in number default null,
                    p_filename IN VARCHAR2,
                    p_mode IN NUMBER,
                    p_effective_date IN varchar2,
                    p_business_group_id IN NUMBER,
                    --p_payroll_id in number default null,
                    -- p_authority  IN varchar2 default null, /*Change for soy 08-09*/
		    p_validate_only IN varchar2);
--
--
--
FUNCTION get_qualifier(line VARCHAR2)
  return VARCHAR2;
--
--
--
FUNCTION get_name(line VARCHAR2)
  return VARCHAR2;
--
--
--
FUNCTION process_att(line VARCHAR2, qualifier VARCHAR2)
  return VARCHAR2;
--
--
--
FUNCTION process_date(line VARCHAR2)
  return VARCHAR2;
--
--
--
FUNCTION process_tax(line VARCHAR2, process_type NUMBER)
  return VARCHAR2;
--
--
--
PROCEDURE write_to_database(date_of_message_p VARCHAR2,
                           form_type_p VARCHAR2,
                           district_number_p VARCHAR2,
                           employer_reference_p VARCHAR2,
                           ni_number_p VARCHAR2,
                           works_number_p VARCHAR2,
                           total_pay_prev_emp_p VARCHAR2,
                           total_tax_prev_emp_p VARCHAR2,
                           tax_code_p VARCHAR2,
                           week1_month1_indicator_p VARCHAR2,
                           employee_name_p VARCHAR2,
                           effective_date_p VARCHAR2,
                           issue_date_p VARCHAR2,
                           request_id_p number default null);
--
--
--
end pay_gb_p6edi_pkg;

/
