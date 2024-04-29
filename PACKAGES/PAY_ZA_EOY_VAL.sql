--------------------------------------------------------
--  DDL for Package PAY_ZA_EOY_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_EOY_VAL" AUTHID CURRENT_USER as
/* $Header: pyzatyev.pkh 120.2.12010000.4 2009/11/19 06:15:01 rbabla ship $ */
-- Package specification
--
TYPE t_xml_element_rec IS RECORD
     (tagname  VARCHAR2(100)
     ,tagvalue VARCHAR2(500)
     );

TYPE t_xml_element_table IS TABLE OF t_xml_element_rec INDEX BY BINARY_INTEGER;

g_xml_element_table     t_xml_element_table;

Function modulus_10_test
  (p_tax_number            in     number) return number;
  pragma restrict_references(modulus_10_test,WNDS,WNPS);
--
Function modulus_10_test
  (p_tax_number            in     varchar2
  ,p_type                  in     varchar2  default null) return number;  --Added for TYE2010
  pragma restrict_references(modulus_10_test,WNDS,WNPS);
--

Function check_id_dob
  (p_id_number                     in     number
  ,p_dob                           in     date) return number;
  pragma restrict_references(check_id_dob,WNDS,WNPS);
--
function decimal_character_conversion ( amount_char in varchar2)
return varchar2;

Function check_IRP5_no
  (p_payroll_id                    in     number
  ,p_irp5no                        in     varchar2
  ,p_tax_year                      in     varchar2) return number;
   pragma restrict_references(check_IRP5_no,WNDS,WNPS);
--
Procedure get_tax_start_end_dates
  (p_payroll_id                    in     number
  ,p_tax_year                      in     varchar2
  ,p_tax_start_date                out nocopy    varchar2
  ,p_tax_end_date                  out nocopy    varchar2);
  pragma restrict_references(get_tax_start_end_dates,WNDS,WNPS);
--
Procedure populate_messages(    c_name OUT NOCOPY VARCHAR2,
                                c_ref_no OUT NOCOPY VARCHAR2,
                                c_ref_no_invalid OUT NOCOPY VARCHAR2,
                                c_person_name OUT NOCOPY VARCHAR2,
                                c_telephone OUT NOCOPY VARCHAR2,
                                c_add_line1 OUT NOCOPY VARCHAR2,
                                c_pcode OUT NOCOPY VARCHAR2,
                                c_pcode1 OUT NOCOPY VARCHAR2,
                                trade_name OUT NOCOPY VARCHAR2,
                                paye_no OUT NOCOPY VARCHAR2,
                                paye_no1 OUT NOCOPY VARCHAR2,
                                address OUT NOCOPY VARCHAR2,
                                pcode OUT NOCOPY VARCHAR2,
                                pcode1 OUT NOCOPY VARCHAR2,
                                payroll_number OUT NOCOPY VARCHAR2,
                                nature_entered OUT NOCOPY VARCHAR2,
                                id_passport OUT NOCOPY VARCHAR2,
                                no_id_passport OUT NOCOPY VARCHAR2,
                                sur_trade_name OUT NOCOPY VARCHAR2,
                                cc_no OUT NOCOPY VARCHAR2,
                                sur_first_name OUT NOCOPY VARCHAR2,
                                M_sur_fname OUT NOCOPY VARCHAR2,
                                M_id_pno_fname OUT NOCOPY VARCHAR2,
                                M_cc_trade_name OUT NOCOPY VARCHAR2,
                                M_lname_fname_cc OUT NOCOPY VARCHAR2,
                                invalid_it_no OUT NOCOPY VARCHAR2,
                                birth_id OUT NOCOPY VARCHAR2,
                                legal_entity  OUT NOCOPY VARCHAR2,
                                no_site_paye_split OUT NOCOPY VARCHAR2,
                                neg_bal_not_alwd OUT NOCOPY VARCHAR2,
                                clearance_num OUT NOCOPY VARCHAR2,
                                terminate_emp OUT NOCOPY VARCHAR2,
                                town_city OUT NOCOPY VARCHAR2,
                                employer_name OUT NOCOPY VARCHAR2);
pragma restrict_references(populate_messages,WNDS,WNPS);

-- for TYE 2008 write the exceptions to the log file

PROCEDURE VALIDATE_TYE_DATA (
                      errbuf                     out nocopy varchar2,
                      retcode                    out nocopy number,
                      p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type,
                      p_tax_yr_start_date               IN DATE,
                      p_tax_yr_end_date                 IN DATE
                      );

--Added for TYE2010
Function check_id_dob
  (p_id_number                     in     varchar2
  ,p_dob                           in     date
  ,p_new_format                    in     varchar2) return number;
  pragma restrict_references(check_id_dob,WNDS,WNPS);


procedure get_tyev_xml (
                      P_PROCESS_NAME          IN varchar2,
                      P_BUSINESS_GROUP_ID     IN number,
                      P_ACTN_PARAMTR_GRP_ID   IN number,
                      P_LEGAL_ENTITY          IN number,
                      P_LEGAL_ENTITY_HIDDEN   IN varchar2,
                      P_TAX_YEAR              IN varchar2,
                      P_TAX_YEAR_H            IN varchar2,
                      P_CERT_TYPE             IN varchar2,
                      P_CERT_TYPE_H           IN varchar2,
                      P_PAYROLL_ID            IN number,
                      P_PAYROLL_ID_H          IN varchar2,
                      P_START_DATE            IN varchar2,
                      P_END_DATE              IN varchar2,
                      P_ASG_SET_ID            IN number,
                      P_ASG_SET_ID_H          IN varchar2,
                      P_PERSON_ID             IN number,
                      P_PERSON_ID_H           IN varchar2,
                      P_TEST_RUN              IN varchar2,
                      P_SORT_ORDER1           IN varchar2,
                      P_SORT_ORDER2           IN varchar2,
                      P_SORT_ORDER3           IN varchar2,
                      P_MONTHLY_RUN           IN varchar2,
                      p_template_name         IN varchar2,
                      p_xml out nocopy CLOB
);



PROCEDURE VALIDATE_TYE_DATA_EOY2010 (
                      errbuf                     out nocopy varchar2,
                      retcode                    out nocopy number,
                      p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type,
                      p_tax_yr_start_date        IN DATE,
                      p_tax_yr_end_date          IN DATE,
                      p_tax_year                 IN NUMBER
                      );




end PAY_ZA_EOY_VAL;

/
