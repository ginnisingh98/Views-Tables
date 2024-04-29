--------------------------------------------------------
--  DDL for Package PAY_NO_ARCHIVE_RSEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_ARCHIVE_RSEA" AUTHID CURRENT_USER AS
/* $Header: pynorsea.pkh 120.0.12000000.1 2007/05/20 09:45:20 rlingama noship $ */

	FUNCTION GET_PARAMETER
		(p_parameter_string	 IN VARCHAR2
                ,p_token				 IN VARCHAR2
                ,p_segment_number  IN NUMBER default NULL ) RETURN VARCHAR2;

	PROCEDURE GET_ALL_PARAMETERS
		(
		 p_payroll_action_id		IN   NUMBER
		,p_business_group_id              OUT  NOCOPY NUMBER
		,p_legal_employer_id                OUT  NOCOPY  NUMBER
		,p_local_unit_id                           OUT  NOCOPY  NUMBER
--		,p_period					OUT  NOCOPY  VARCHAR2
--		,p_year						OUT  NOCOPY  VARCHAR2
		,p_effective_date                         OUT  NOCOPY DATE
		,p_archive					OUT  NOCOPY  VARCHAR2);

	PROCEDURE RANGE_CODE
		(p_payroll_action_id	IN    NUMBER
                ,p_sql				OUT   NOCOPY VARCHAR2) ;

	PROCEDURE ASSIGNMENT_ACTION_CODE
		(p_payroll_action_id	IN NUMBER
                ,p_start_person           IN NUMBER
                ,p_end_person            IN NUMBER
                ,p_chunk			IN NUMBER);

	PROCEDURE INITIALIZATION_CODE
		(p_payroll_action_id	IN NUMBER);


	PROCEDURE ARCHIVE_CODE
		(p_assignment_action_id		IN NUMBER
                ,p_effective_date		IN DATE);

END PAY_NO_ARCHIVE_RSEA;

 

/