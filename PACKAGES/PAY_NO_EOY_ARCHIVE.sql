--------------------------------------------------------
--  DDL for Package PAY_NO_EOY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_EOY_ARCHIVE" AUTHID CURRENT_USER AS
 /* $Header: pynoeoya.pkh 120.0.12010000.5 2009/02/11 04:46:56 vijranga ship $ */
 --
 --
 -- -----------------------------------------------------------------------------
 -- Data types.
 -- -----------------------------------------------------------------------------
 --
 TYPE t_rep_code_rec IS RECORD
  (reporting_code VARCHAR2(10)
  ,amount         VARCHAR2(10)
  ,info1          VARCHAR2(30)
  ,info2          VARCHAR2(30)
  ,info3          VARCHAR2(30)
  ,info4          VARCHAR2(30)
  ,info5          VARCHAR2(30)
  ,info6          VARCHAR2(30)
  ,info7          VARCHAR2(100)
  ,info8          VARCHAR2(100)
  ,info9          VARCHAR2(100)
  ,info10         VARCHAR2(100)
  ,info11         VARCHAR2(100)
  ,info12         VARCHAR2(100)
  ,info13         VARCHAR2(30) --2009 changes
  ,info14         VARCHAR2(30) --2009 changes
  ,info15         VARCHAR2(30) --2009 changes
  ,info16         VARCHAR2(30) --2009 changes
  ,info17         VARCHAR2(100) --2009 changes
  ,info18         VARCHAR2(100) --2009 changes
  ,info19         VARCHAR2(100) --2009 changes
  ,info20         VARCHAR2(100) --2009 changes
  );
 --
 TYPE t_rep_code_table IS TABLE OF t_rep_code_rec INDEX BY BINARY_INTEGER;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Localisation delivered support for extracting specific reporting codes.
 --
 -- Needs to populate the archive as follows:-
 --
 --  pay_action_information_api.create_action_information
 --  (p_action_context_type         => 'AAP'
 --  ,p_action_context_id           => p_assignment_action_id
 --  ,p_action_information_id       => l_act_inf_id
 --  ,p_object_version_number       => l_ovn
 --  ,p_effective_date              => p_report_date
 --  ,p_action_information_category => 'EMEA REPORT INFORMATION'
 --  ,p_action_information1         => 'ASG_REP_CODE_INFO'
 --  ,p_action_information2         => p_reporting_code
 --  ,p_action_information3         => <amount>
 --  ,p_action_information4         => <info1>
 --  ,p_action_information5         => <info2>
 --  ,p_action_information6         => <info3>
 --  ,p_action_information7         => <info4>
 --  ,p_action_information8         => <info5>
 --  ,p_action_information9         => <info6>
 --  ,p_action_information10        => <Seaman Component status>
 --  ,p_action_information11         => <info7>		--2009 changes
 --  ,p_action_information12         => <info8>		--2009 changes
 --  ,p_action_information13         => <info9>		--2009 changes
 --  ,p_action_information14         => <info10>	--2009 changes
 --);
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE extract_reporting_code
 (p_assignment_action_id IN NUMBER
 ,p_reporting_code       IN VARCHAR2
 ,p_report_date          IN DATE);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Localisation delivered support for collating specific reporting codes.
 --
 -- Cursor to retrieve reporting code informastion to be collated:-
 --
 --  CURSOR csr_REPORTING_CODES
 --          (p_payroll_action_id IN NUMBER
 --          ,p_legal_employer_id IN VARCHAR2
 --         ,p_reporting_code    IN VARCHAR2) IS
 --   SELECT asg_act.action_information5  person_id
 --         ,asg_act.action_information6  tax_municipality
 --         ,TO_NUMBER(rep_cde.action_information3)  amount
 --   FROM   pay_assignment_actions paa
 --         ,pay_action_information asg_act
 --         ,pay_action_information rep_cde
 --   WHERE  paa.payroll_action_id               = p_payroll_action_id
 --     AND  asg_act.action_context_type         = 'AAP'
 --     AND  asg_act.action_context_id           = paa.assignment_action_id
 --     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
 --     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
 --     AND  asg_act.action_information2         = p_legal_employer_id
 --     AND  rep_cde.action_context_type         = 'AAP'
 --     AND  rep_cde.action_context_id           = asg_act.action_context_id
 --     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
 --     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
 --     AND  rep_cde.action_information2         = p_reporting_code;
 --
  -- Needs to populate the archive as follows:-
 --
 --  pay_action_information_api.create_action_information
 --  (p_action_context_type         => 'PA'
 --  ,p_action_context_id           => p_payroll_action_id
 --  ,p_action_information_id       => l_act_inf_id
 --  ,p_object_version_number       => l_ovn
 --  ,p_effective_date              => p_report_date
 --  ,p_action_information_category => 'EMEA REPORT INFORMATION'
 --  ,p_action_information1         => 'AUDIT_REP_SUMMARY'
 --  ,p_action_information2         => p_legal_employer_id
 --  ,p_action_information3         => <person ID>
 --  ,p_action_information4         => p_reporting_code
 --  ,p_action_information5         => <amount>
 --  ,p_action_information6         => <info1>
 --  ,p_action_information7         => <info2>
 --  ,p_action_information8         => <info3>
 --  ,p_action_information9         => <info4>
 --  ,p_action_information10        => <info5>
 --  ,p_action_information11        => <info6>
 --  ,p_action_information12        => <tax_municipality>
 --  ,p_action_information13        => <Seaman Component status>
 --  ,p_action_information14        => <info7>		--2009 changes
 --  ,p_action_information15        => <info8>		--2009 changes
 --  ,p_action_information16        => <info9>		--2009 changes
 --  ,p_action_information17        => <info10>		--2009 changes
 --);
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE collate_reporting_code
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR2);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Parse out parameters from string.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_parameter
 (p_parameter_string IN VARCHAR2
 ,p_token            IN VARCHAR) RETURN VARCHAR2;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the prompt for a given information item.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_info_prompt
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR2
 ,p_info_id           IN VARCHAR2) RETURN VARCHAR2;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the Data Type for a given information item.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_info_dtype
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR
 ,p_info_id           IN VARCHAR2) RETURN VARCHAR2;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the description for a given reporting code.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_code_desc
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR) RETURN VARCHAR2;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the ORID for a given reporting code.
 -- -----------------------------------------------------------------------------
 FUNCTION get_xml_orid
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR
 ,p_info_id           IN VARCHAR2) RETURN VARCHAR2;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE range_code
 (p_payroll_action_id IN NUMBER
 ,p_sql               OUT NOCOPY VARCHAR2);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE assignment_action_code
 (p_payroll_action_id IN NUMBER
 ,p_start_person      IN NUMBER
 ,p_end_person        IN NUMBER
 ,p_chunk             IN NUMBER);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE initialization_code
 (p_payroll_action_id IN NUMBER);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE archive_code
 (p_assignment_action_id IN NUMBER
 ,p_effective_date       IN DATE);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE deinitialization_code
 (p_payroll_action_id IN NUMBER);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Generates XML for the Norwegian End of Year Audit report.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_audit_data
 (p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB);
 --
 --
  -- -----------------------------------------------------------------------------
 -- Generates PDF Report for the Norwegian End of Year Employer Contribution Summary
 -- report.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_employer_contribution_data
 (p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB);
  --
 --
 -- -----------------------------------------------------------------------------
 -- Generates XML for the Norwegian End of Year Employer Contribution Summary
 -- report.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_employer_contribution_xml
 (p_business_group_id IN NUMBER
 ,p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB);
  --
 --
 -- -----------------------------------------------------------------------------
 -- Generates Report for the Norwegian End of Year Report called Certificate of Pay
 -- and Tax Deducted for each employee.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_employee_cerificate_data
 (p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Generates XML for the Norwegian End of Year Report called Certificate of Pay
 -- and Tax Deducted for each employee.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_employee_certificate_xml
 (p_business_group_id IN NUMBER
 ,p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB);
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns Y if Person is employed throughout the year in same Tax Unit
 -- -----------------------------------------------------------------------------
 --
 --
  FUNCTION employed_throughout_year ( p_person_id        IN NUMBER
                                     ,p_legal_empoyer_id IN NUMBER
                                     ,p_effective_date   IN DATE )
  RETURN VARCHAR2 ;
 --
END pay_no_eoy_archive;

/
