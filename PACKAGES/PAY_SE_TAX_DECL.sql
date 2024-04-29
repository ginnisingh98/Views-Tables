--------------------------------------------------------
--  DDL for Package PAY_SE_TAX_DECL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_TAX_DECL" AUTHID CURRENT_USER AS
/* $Header: pysetada.pkh 120.0.12000000.1 2007/04/24 07:04:19 rsahai noship $ */

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
		,p_legal_employer_id   OUT  NOCOPY  NUMBER
		,p_month OUT NOCOPY VARCHAR2
		,p_year		OUT  NOCOPY  NUMBER
		,p_administrative_code		OUT NOCOPY VARCHAR2
		,p_information		OUT NOCOPY VARCHAR2
		,p_declaration_due_date OUT NOCOPY DATE
		) ;

/*GET DEFINED BALANCE ID*/
FUNCTION GET_DEFINED_BALANCE_ID
  (p_balance_name   		IN  VARCHAR2
  ,p_dbi_suffix     		IN  VARCHAR2 )
RETURN NUMBER;


/*GET BALANCE NAME*/
FUNCTION GET_BALANCE_NAME
  (p_input_value_id   		IN  VARCHAR2)
RETURN VARCHAR2 ;


/*Funtion to get the costed value*/
/*FUNCTION COSTED_VALUE
	(p_run_result_id IN NUMBER
	,p_input_value_id IN NUMBER)
	RETURN NUMBER;*/


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
end PAY_SE_TAX_DECL;

 

/
