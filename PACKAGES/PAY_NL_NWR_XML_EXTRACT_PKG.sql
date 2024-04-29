--------------------------------------------------------
--  DDL for Package PAY_NL_NWR_XML_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_NWR_XML_EXTRACT_PKG" AUTHID CURRENT_USER as
/* $Header: pynlwrep.pkh 120.2.12010000.1 2008/07/27 23:13:03 appldev ship $ */
--
FUNCTION get_tag_name (p_context_code         VARCHAR2
                      ,p_node                 VARCHAR2) RETURN VARCHAR2;
--
FUNCTION yes_no(p_yn VARCHAR2) RETURN VARCHAR2;
--
FUNCTION get_le_name(p_payroll_action_id      NUMBER) RETURN VARCHAR2;
--
PROCEDURE load_xml ( p_node_type     VARCHAR2
                    ,p_context_code  VARCHAR2
                    ,p_node          VARCHAR2
                    ,p_data          VARCHAR2);
--
--------------------------------------------------------------------------------
--    Name        : GENERATE
--    Description : This procedure interprets archived information and prints it
--                  out to an XML file.
--------------------------------------------------------------------------------
--
PROCEDURE generate( p_action_context_id         NUMBER
                   ,p_nwr_report_type           VARCHAR2
                   --,p_xdo_output_type           VARCHAR2
                   ,p_assignment_set_id         NUMBER
                   ,p_sort_order                VARCHAR2
                   ,p_template_name             VARCHAR2
                   ,p_xml                       OUT NOCOPY CLOB);
--
    CURSOR csr_message_info(p_action_context_id   NUMBER
                           ,p_category            VARCHAR2) IS
    SELECT  pai.*
	FROM    pay_action_information pai
	WHERE   pai.action_context_type         = 'PA'
	AND     pai.action_context_id           = p_action_context_id
	AND     pai.action_information_category = p_category;
    --
    CURSOR csr_collective_info(p_action_context_id   NUMBER
                              ,p_category            VARCHAR2
                              ,p_type                VARCHAR2
                              ,p_start_date          VARCHAR2
                              ,p_end_date            VARCHAR2) IS
    SELECT   pai.*
	FROM     pay_action_information pai
	WHERE    pai.action_context_type            = 'PA'
	AND      pai.action_context_id              = p_action_context_id
	AND      pai.action_information_category    = p_category
	AND 	 pai.action_information1			= p_type
    AND		 pai.action_information3			= p_start_date
	AND		 pai.action_information4			= p_end_date
    ORDER BY pai.action_information_id;
    --
    CURSOR csr_swmf_info(p_action_context_id   NUMBER
                        ,p_category            VARCHAR2
                        ,p_type                VARCHAR2
                        ,p_start_date          VARCHAR2
                        ,p_end_date            VARCHAR2) IS
    SELECT   pai.*
	FROM     pay_action_information pai
	WHERE    pai.action_context_type            = 'PA'
	AND      pai.action_context_id              = p_action_context_id
	AND      pai.action_information_category    = p_category
	AND 	 pai.action_information1			= p_type
    AND		 pai.action_information5			= p_start_date
	AND		 pai.action_information6			= p_end_date
    ORDER BY pai.action_information_id;
    --
    CURSOR csr_corr_balance_info(p_action_context_id   NUMBER
                                ,p_category            VARCHAR2
                                ,p_type                VARCHAR2) IS
    SELECT  pai.*
	FROM    pay_action_information pai
	WHERE   pai.action_context_type         = 'PA'
	AND     pai.action_context_id           = p_action_context_id
	AND     pai.action_information_category = p_category
	AND 	pai.action_information1			= p_type;
    --
    CURSOR csr_employment_info(p_action_context_id   NUMBER
                              ,p_category            VARCHAR2
                              ,p_type                VARCHAR2
                              ,p_start_date          VARCHAR2
                              ,p_end_date            VARCHAR2
							  ,p_sort_odr			 VARCHAR2) IS
    SELECT pai.action_information_id
          ,pai.effective_date
          ,pai.assignment_id
          ,pai.action_information1
          ,pai.action_information2
          ,pai.action_information3
          ,pai.action_information4
          ,pai.action_information5
          ,pai.action_information6
          ,pai.action_information7
          ,pai.action_information8
          ,TRANSLATE(pai.action_information9
                    , 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' ||
                        REPLACE(TRANSLATE( pai.action_information9
                                          ,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
                                          ,'A')
                                , 'A'
                                , '')
                    , 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz') action_information9
          ,pai.action_information10
          ,pai.action_information11
          ,pai.action_information12
          ,pai.action_information13
          ,pai.action_information14
          ,pai.action_information15
          ,pai.action_information16
          ,pai.action_information17
          ,pai.action_information18
          ,pai.action_information19
          ,pai.action_information20
          ,pai.action_information21
          ,pai.action_information22
          ,pai.action_information23
          ,pai.action_information24
          ,pai.action_information25
          ,pai.action_information26
          ,pai.action_information27
          ,pai.action_information28
          ,pai.action_information29
          ,pai.action_information30
    FROM pay_action_information pai
        ,pay_assignment_actions paa
    WHERE pai.action_context_type       = 'AAP'
    AND pai.action_context_id           = paa.assignment_action_id
    AND paa.payroll_action_id	        = p_action_context_id
    AND pai.action_information_category = p_category
    AND pai.action_information1         = p_type
    AND	pai.action_information2			= p_start_date
	AND	pai.action_information3			= p_end_date
    ORDER BY DECODE(p_sort_odr,'ASSIGNMENT_NUMBER',pai.action_information4,'EMPLOYEE_NAME',pai.action_information11);
    --
    CURSOR csr_assignment_filter(p_assignment_set_id    NUMBER
                                ,p_assignment_id        NUMBER) IS
    SELECT hasa.INCLUDE_OR_EXCLUDE
    FROM   hr_assignment_sets has
          ,hr_assignment_set_amendments hasa
    WHERE has.assignment_set_id 			= hasa.assignment_set_id
    AND   has.assignment_set_id 			= p_assignment_set_id
    --AND	  hasa.INCLUDE_OR_EXCLUDE			= 'I'
    AND	  hasa.assignment_id 				= p_assignment_id;
    --
    CURSOR csr_address_info(p_action_context_id     NUMBER
                           ,p_category              VARCHAR2
                           ,p_type                  VARCHAR2
                           ,p_action_information_id NUMBER
                           ,p_assignment_id         NUMBER) IS
    SELECT pai.*
    FROM pay_action_information pai
        ,pay_assignment_actions paa
    WHERE pai.action_context_type       = 'AAP'
    AND pai.action_context_id           = paa.assignment_action_id
    AND paa.payroll_action_id	        = p_action_context_id
    AND pai.action_information_category = p_category
    AND pai.assignment_id               = p_assignment_id
    AND pai.action_information26        = p_type
    AND pai.action_information27        = TO_CHAR(p_action_information_id);
    --
    CURSOR csr_income_info( p_action_context_id     NUMBER
                           ,p_category              VARCHAR2
                           ,p_type                  VARCHAR2
                           ,p_action_information_id NUMBER) IS
    SELECT pai.*
    FROM pay_action_information pai
        ,pay_assignment_actions paa
    WHERE pai.action_context_type       = 'AAP'
    AND pai.action_context_id           = paa.assignment_action_id
    AND paa.payroll_action_id	        = p_action_context_id
    AND pai.action_information_category = p_category
    AND pai.action_information1         = p_type
    AND pai.action_information2         = TO_CHAR(p_action_information_id);
    --
    CURSOR csr_income_info1(p_action_context_id     NUMBER
                           ,p_category              VARCHAR2
                           ,p_type                  VARCHAR2
                           ,p_action_information_id NUMBER) IS
    SELECT pai.*
    FROM pay_action_information pai
        ,pay_assignment_actions paa
    WHERE pai.action_context_type       = 'AAP'
    AND pai.action_context_id           = paa.assignment_action_id
    AND paa.payroll_action_id	        = p_action_context_id
    AND pai.action_information_category = p_category
    AND pai.action_information1         = p_type
    AND pai.action_information2         = TO_CHAR(p_action_information_id);
    --
   /* CURSOR csr_correction_info(p_action_context_id   NUMBER
                              ,p_category            VARCHAR2
                              ,p_type                VARCHAR2) IS
    SELECT DISTINCT action_information3
                   ,action_information4
	FROM    pay_action_information pai
	WHERE   pai.action_context_type         = 'PA'
	AND     pai.action_context_id           = p_action_context_id
	AND     pai.action_information_category = p_category
	AND 	pai.action_information1			= p_type; */
    --
    CURSOR csr_correction_info(p_action_context_id   NUMBER
                              ,p_category            VARCHAR2
                              ,p_type                VARCHAR2) IS
	SELECT DISTINCT action_information2 start_date
	               ,action_information3 end_date
	FROM pay_action_information pai
		,pay_assignment_actions paa
	WHERE pai.action_context_type         = 'AAP'
	AND   pai.action_information_category = p_category
	AND   pai.action_context_id 		  = paa.assignment_action_id
	AND   paa.payroll_action_id 		  = p_action_context_id
	AND   pai.action_information1 		 <> p_type;
--
END pay_nl_nwr_xml_extract_pkg;

/
