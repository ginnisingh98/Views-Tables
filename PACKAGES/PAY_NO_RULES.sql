--------------------------------------------------------
--  DDL for Package PAY_NO_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_RULES" AUTHID CURRENT_USER AS
/* $Header: pynorule.pkh 120.4.12010000.1 2008/07/27 23:15:35 appldev ship $ */
--

-------------------- cursor to get all the assignment_action_id if run types is enabled -----------------

CURSOR csr_run_types(p_action_context_id   NUMBER ) IS
SELECT assignment_action_id
FROM   pay_assignment_actions
WHERE  source_action_id = p_action_context_id
AND    action_status  = 'C'
UNION
SELECT p_action_context_id assignment_action_id
FROM dual;


------ cursor to get the balance details ------------------------------------

	 CURSOR csr_balance_info(p_action_context_id   NUMBER
                           ,p_pa_category         VARCHAR2
                           ,p_aap_category        VARCHAR2) IS
     SELECT pai.effective_date       e1,     pai1.effective_date       ee1,
           pai.action_information1  a1,     pai1.action_information1  aa1,
           pai.action_information2  a2,     pai1.action_information2  aa2,
           pai.action_information3  a3,     pai1.action_information3  aa3,
           DECODE(pai1.action_information5,NULL,pai.action_information4,
		    pai.action_information4||'('||pai1.action_information5||')')  a4,
                                            pai1.action_information4  aa4,
           pai.action_information5  a5,     pai1.action_information5  aa5,
           pai.action_information6  a6,     pai1.action_information6  aa6,
           pai.action_information7  a7,     pai1.action_information7  aa7,
           pai.action_information8  a8,     pai1.action_information8  aa8,
           pai.action_information9  a9,     pai1.action_information9  aa9,
           pai.action_information10 a10,    pai1.action_information10 aa10,
           pai.action_information11 a11,    pai1.action_information11 aa11,
           pai.action_information12 a12,    pai1.action_information12 aa12,
           pai.action_information13 a13,    pai1.action_information13 aa13,
           pai.action_information14 a14,    pai1.action_information14 aa14,
           pai.action_information15 a15,    pai1.action_information15 aa15,
           pai.action_information16 a16,    pai1.action_information16 aa16,
           pai.action_information17 a17,    pai1.action_information17 aa17,
           pai.action_information18 a18,    pai1.action_information18 aa18,
           pai.action_information19 a19,    pai1.action_information19 aa19,
           pai.action_information20 a20,    pai1.action_information20 aa20,
           pai.action_information21 a21,    pai1.action_information21 aa21,
           pai.action_information22 a22,    pai1.action_information22 aa22,
           pai.action_information23 a23,    pai1.action_information23 aa23,
           pai.action_information24 a24,    pai1.action_information24 aa24,
           pai.action_information25 a25,    pai1.action_information25 aa25,
           pai.action_information26 a26,    pai1.action_information26 aa26,
           pai.action_information27 a27,    pai1.action_information27 aa27,
           pai.action_information28 a28,    pai1.action_information28 aa28,
           pai.action_information29 a29,    pai1.action_information29 aa29,
           pai.action_information30 a30,    pai1.action_information30 aa30
	FROM pay_action_information pai
		,pay_action_information pai1
		,pay_assignment_actions paa
	WHERE pai.action_context_type       = 'PA'
	AND pai.action_information_category = p_pa_category
	AND pai1.action_context_type        = 'AAP'
	AND pai1.action_information_category = p_aap_category
	AND pai.action_information2          = pai1.action_information1
	AND pai.action_context_id            = paa.payroll_action_id
	AND pai1.action_context_id           = paa.assignment_action_id
	AND paa.assignment_action_id = p_action_context_id
        ORDER BY pai.action_information5,pai1.action_information5 DESC;

-----------------------------------------

PROCEDURE get_main_tax_unit_id
  (p_assignment_id                 IN     NUMBER
  ,p_effective_date                IN     DATE
  ,p_tax_unit_id                   OUT NOCOPY NUMBER );
--
/*
PROCEDURE get_source_text_context(p_asg_act_id  NUMBER
                                  ,p_ee_id       NUMBER
                                  ,p_source_text IN OUT NOCOPY VARCHAR2);
*/
--

-----------------------------------------------------------------------------
-- Procedure : get_third_party_org_context
-- It fetches the third party context of the Assignment Id.
-----------------------------------------------------------------------------

PROCEDURE get_third_party_org_context
(p_asg_act_id  IN     NUMBER
,p_ee_id                IN     NUMBER
,p_third_party_id       IN OUT NOCOPY NUMBER );

--
PROCEDURE get_default_jurisdiction(p_asg_act_id   NUMBER,
                                   p_ee_id        NUMBER,
                                   p_jurisdiction IN OUT NOCOPY VARCHAR2);
--
/*
 PROCEDURE get_source_context(p_asg_act_id IN NUMBER,
                                p_ee_id      IN NUMBER,
                                p_source_id  IN OUT NOCOPY VARCHAR2);
*/
--
/*Test procedure for local unit id */
PROCEDURE get_main_local_unit_id(p_assignment_id IN  NUMBER,
    p_effective_date IN DATE,
    p_local_unit_id  OUT NOCOPY NUMBER);
--
-----------------------------------------
FUNCTION load_xml  (p_node_type     VARCHAR2,
                    p_context_code  VARCHAR2,
                    p_node          VARCHAR2,
                    p_data          VARCHAR2) RETURN VARCHAR2;


-----------------------------------------
FUNCTION flex_seg_enabled(p_context_code              VARCHAR2,
                          p_application_column_name   VARCHAR2) RETURN BOOLEAN;

-----------------------------------------

   PROCEDURE add_custom_xml
       (p_assignment_action_id number,
        p_action_information_category varchar2,
        p_document_type varchar2) ;


-----------------------------------------
PROCEDURE get_source_text_context
(p_asg_act_id		IN      NUMBER,
p_ee_id			IN      NUMBER,
p_source_text		IN OUT  NOCOPY VARCHAR2);

--------------------------------------------

PROCEDURE get_source_text2_context
(p_asg_act_id   IN		NUMBER
,p_ee_id        IN		NUMBER
,p_source_text2 IN OUT NOCOPY VARCHAR2);

---------------------------------------------
FUNCTION get_payslip_sort_order1 RETURN VARCHAR2 ;
---------------------------------------------
FUNCTION get_payslip_sort_order2 RETURN VARCHAR2 ;
---------------------------------------------
FUNCTION get_payslip_sort_order3 RETURN VARCHAR2 ;
---------------------------------------------
END PAY_NO_RULES ;

/