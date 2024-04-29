--------------------------------------------------------
--  DDL for Package PAY_FI_ARCHIVE_DPSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_ARCHIVE_DPSA" AUTHID CURRENT_USER AS
/* $Header: pyfidpsa.pkh 120.1.12000000.1 2007/04/26 12:48:57 dbehera noship $ */

	FUNCTION GET_PARAMETER
		(p_parameter_string	 IN VARCHAR2
                ,p_token				 IN VARCHAR2
                ,p_segment_number  IN NUMBER default NULL ) RETURN VARCHAR2;

	PROCEDURE GET_ALL_PARAMETERS
		(      p_payroll_action_id		IN   NUMBER
		,p_business_group_id              OUT  NOCOPY NUMBER
		,p_legal_employer_id                OUT  NOCOPY  NUMBER
		,p_local_unit_id                           OUT  NOCOPY  NUMBER
		,p_year						OUT  NOCOPY  VARCHAR2
		,p_transact_type				OUT  NOCOPY  VARCHAR2
		,p_deduction_ss				OUT  NOCOPY   NUMBER
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

	PROCEDURE DEINITIALIZATION_CODE
	    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type);

END PAY_FI_ARCHIVE_DPSA;

 

/
