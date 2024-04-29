--------------------------------------------------------
--  DDL for Package PAY_SE_ARCHIVE_TETA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_ARCHIVE_TETA" AUTHID CURRENT_USER AS
/* $Header: pyseteta.pkh 120.0.12000000.1 2007/07/11 12:29:32 dbehera noship $ */

	FUNCTION GET_PARAMETER
		(p_parameter_string		IN VARCHAR2
                ,p_token			IN VARCHAR2
                ,p_segment_number		IN NUMBER default NULL
		) RETURN VARCHAR2;

	PROCEDURE GET_ALL_PARAMETERS
		(
		 p_payroll_action_id		IN   NUMBER
		,p_business_group_id		OUT  NOCOPY NUMBER
		,p_person_id		        OUT  NOCOPY  NUMBER
		,p_date_report	                OUT  NOCOPY DATE
		,p_effective_date               OUT  NOCOPY	DATE
		,p_archive			OUT  NOCOPY  VARCHAR2);

	PROCEDURE RANGE_CODE
		(p_payroll_action_id		IN    NUMBER
                ,p_sql				OUT   NOCOPY VARCHAR2) ;

	PROCEDURE ASSIGNMENT_ACTION_CODE
		(p_payroll_action_id		IN NUMBER
                ,p_start_person			IN NUMBER
                ,p_end_person			IN NUMBER
                ,p_chunk			IN NUMBER);

	PROCEDURE INITIALIZATION_CODE
		(p_payroll_action_id		IN NUMBER);


	PROCEDURE ARCHIVE_CODE
		(p_assignment_action_id		IN NUMBER
                ,p_effective_date		IN DATE);

	PROCEDURE DEINITIALIZATION_CODE
		(p_payroll_action_id	IN pay_payroll_actions.payroll_action_id%type);



END PAY_SE_ARCHIVE_TETA;

 

/
