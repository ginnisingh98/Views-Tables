--------------------------------------------------------
--  DDL for Package PAY_SE_ARCHIVE_CWCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_ARCHIVE_CWCA" AUTHID CURRENT_USER AS
/* $Header: pysecwca.pkh 120.0.12010000.2 2010/01/12 10:07:17 vijranga ship $ */

	FUNCTION GET_PARAMETER
		(p_parameter_string	 IN VARCHAR2
                ,p_token				 IN VARCHAR2
                ,p_segment_number  IN NUMBER default NULL ) RETURN VARCHAR2;

	PROCEDURE get_all_parameters (
		p_payroll_action_id        IN       NUMBER              -- In parameter
		,p_business_group_id        OUT NOCOPY NUMBER          -- Core parameter
		,p_effective_date           OUT NOCOPY DATE            -- Core parameter
		,p_person_id                OUT NOCOPY NUMBER          -- User parameter
		,p_assignment_id            OUT NOCOPY VARCHAR2        -- User parameter
		,p_still_employed           OUT NOCOPY VARCHAR2        -- User parameter
		,p_report_start_year        OUT NOCOPY VARCHAR2         -- User parameter
		,p_report_start_month       OUT NOCOPY VARCHAR2         -- User parameter
		);

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

	-- Bug# 9222739 fix starts
	FUNCTION GET_DEFINED_BALANCE_VALUE
        (p_assignment_id              IN NUMBER
          ,p_balance_name               IN VARCHAR2
          ,p_balance_dim                IN VARCHAR2
          ,p_virtual_date               IN DATE) RETURN NUMBER;

	-- Bug# 9222739 fix ends

END PAY_SE_ARCHIVE_CWCA;

/
