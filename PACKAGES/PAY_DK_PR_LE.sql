--------------------------------------------------------
--  DDL for Package PAY_DK_PR_LE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_PR_LE" AUTHID CURRENT_USER AS
/* $Header: pydkprle.pkh 120.6 2006/01/27 06:52:38 pgopal noship $ */

/* GET PARAMETER */
FUNCTION GET_PARAMETER(
	 p_parameter_string IN VARCHAR2
	,p_token            IN VARCHAR2
	,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2 ;


/* GET ALL PARAMETERS */
PROCEDURE GET_ALL_PARAMETERS(
 		 p_payroll_action_id	IN           NUMBER
		,p_business_group_id    OUT  NOCOPY  NUMBER
		,p_effective_date	OUT  NOCOPY  DATE
		,p_archive		OUT  NOCOPY  VARCHAR2
		,p_element_set_id    OUT  NOCOPY  NUMBER
		,p_legal_employer_id OUT NOCOPY NUMBER
		,p_payroll_id		OUT  NOCOPY  NUMBER
		,p_fromdate		OUT NOCOPY DATE
		,p_todate		OUT NOCOPY DATE
		) ;

/*GET DEFINED BALANCE ID*/
FUNCTION GET_DEFINED_BALANCE_ID(
   p_input_value_id	    IN  VARCHAR2
  ,p_dbi_suffix     		IN  VARCHAR2)
RETURN NUMBER;


/*Funtion to get the costed code*/
FUNCTION COSTED_CODE
	(p_run_result_id IN NUMBER
	,p_input_value_id IN NUMBER)
	RETURN VARCHAR2 ;


/* RANGE CODE */
PROCEDURE RANGE_CODE (pactid    IN    NUMBER
		      ,sqlstr    OUT   NOCOPY VARCHAR2) ;


/* INITIALIZATION CODE */
PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER) ;


/* ASSIGNMENT ACTION CODE */
PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER) ;


 /* ARCHIVE CODE */
PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
 		      ,p_effective_date    IN DATE) ;



-- Main Procedure to populate details for reporting

PROCEDURE populate_details
(
	p_payroll_action_id in varchar2,
	p_template_name in varchar2,
	p_xml out nocopy clob
);

END PAY_DK_PR_LE;

 

/
