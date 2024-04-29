--------------------------------------------------------
--  DDL for Package PAY_NO_ARC_RSEA_07
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_ARC_RSEA_07" AUTHID CURRENT_USER AS
/* $Header: pynorse7.pkh 120.0.12000000.1 2007/05/20 09:44:52 rlingama noship $ */
--
-- -----------------------------------------------------------------------------
-- GET PARAMETER
-- -----------------------------------------------------------------------------
FUNCTION GET_PARAMETER(
		 p_parameter_string IN VARCHAR2
		,p_token            IN VARCHAR2
		,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2;
-- -----------------------------------------------------------------------------
-- GET ALL PARAMETERS
-- -----------------------------------------------------------------------------
PROCEDURE GET_ALL_PARAMETERS(p_payroll_action_id  IN   NUMBER
                            ,p_business_group_id  OUT  NOCOPY NUMBER
                            ,p_legal_employer_id  OUT  NOCOPY NUMBER
                            ,p_local_unit_id      OUT  NOCOPY NUMBER
                            ,p_effective_date     OUT  NOCOPY DATE
                            ,p_archive					  OUT  NOCOPY VARCHAR2);
-- -----------------------------------------------------------------------------
-- RANGE CODE
-- -----------------------------------------------------------------------------
PROCEDURE RANGE_CODE(p_payroll_action_id IN           NUMBER
                    ,p_sql               OUT   NOCOPY VARCHAR2);
-- -----------------------------------------------------------------------------
-- ASSIGNMENT ACTION CODE
-- -----------------------------------------------------------------------------
PROCEDURE ASSG_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER);
-- -----------------------------------------------------------------------------
-- INITIALIZATION CODE
-- -----------------------------------------------------------------------------
PROCEDURE INIT_CODE(p_payroll_action_id IN NUMBER);
-- -----------------------------------------------------------------------------
-- ARCHIVE CODE
-- -----------------------------------------------------------------------------
PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
          			      ,p_effective_date       IN DATE);
-- ------------------------------------------------------ --
-- GET_PDF_REP to generate the xml for pdf report (audit) --
-- ------------------------------------------------------ --
 PROCEDURE get_pdf_rep
 (p_business_group_id IN NUMBER
 ,p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB);
-- ------------------------------------------------- --
-- GET_XML_REP to generate the standard xml extract  --
-- ------------------------------------------------- --
 PROCEDURE get_xml_rep
 (p_business_group_id IN NUMBER
 ,p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB);
--
END PAY_NO_ARC_RSEA_07;

 

/
