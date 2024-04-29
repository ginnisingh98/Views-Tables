--------------------------------------------------------
--  DDL for Package PAY_DK_ARCHIVE_EIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_ARCHIVE_EIN" AUTHID CURRENT_USER AS
 /* $Header: pydkeina.pkh 120.1.12010000.4 2010/03/19 10:27:43 knadhan ship $ */

	FUNCTION GET_PARAMETER
		(p_parameter_string	 IN VARCHAR2
                ,p_token				 IN VARCHAR2
                ,p_segment_number  IN NUMBER default NULL ) RETURN VARCHAR2;

	PROCEDURE GET_ALL_PARAMETERS
		( p_payroll_action_id IN   NUMBER
		,p_business_group_id  OUT  NOCOPY NUMBER
		,p_legal_employer_id  OUT  NOCOPY  NUMBER
		,p_effective_date     OUT  NOCOPY DATE
		,p_payroll            OUT NOCOPY NUMBER
		--,p_payroll_period     OUT NOCOPY NUMBER
		,p_payroll_type   OUT  NOCOPY VARCHAR2
		,p_start_date     OUT  NOCOPY VARCHAR2   /* 9489806 */
                ,p_end_date       OUT  NOCOPY VARCHAR2
		,p_test_submission    OUT NOCOPY VARCHAR2
		,p_company_terminating OUT NOCOPY VARCHAR2
      		,p_sender_id OUT NOCOPY VARCHAR2);

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

END PAY_DK_ARCHIVE_EIN;

/
