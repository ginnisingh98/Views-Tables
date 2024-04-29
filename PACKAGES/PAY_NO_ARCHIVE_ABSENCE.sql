--------------------------------------------------------
--  DDL for Package PAY_NO_ARCHIVE_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_ARCHIVE_ABSENCE" AUTHID CURRENT_USER as
/* $Header: pynoabsa.pkh 120.0.12000000.1 2007/05/22 05:29:41 rajesrin noship $ */
	TYPE AbsenceRec IS RECORD(initialized varchar2(1),
	              quater varchar2(2),
	              sick_1_3_ocr_sc 		NUMBER,
	              sick_1_3_days_sc 		NUMBER,
	              sick_1_3_ocr_dc 		NUMBER,
	              sick_1_3_days_dc 		NUMBER,
	              sick_4_16_ocrs 		NUMBER,
	              sick_4_16_days 		NUMBER,
	              sick_more_16_ocrs 	NUMBER,
	              sick_more_16_days 	NUMBER,
	              sick_8_weeks_ocr  	NUMBER,
	              sick_8_weeks_days 	NUMBER,
	              cms_abs_ocrs		NUMBER,
	              cms_abs_days		NUMBER,
	              parental_abs_ocrs		NUMBER,
	              parental_abs_days		NUMBER,
	              other_abs_ocrs		NUMBER,
	              other_abs_days		NUMBER,
	              other_abs_paid_ocrs	NUMBER,
	              other_abs_paid_days	NUMBER
	              );

	TYPE abstab IS TABLE OF AbsenceRec INDEX BY BINARY_INTEGER;
	absmale abstab;
	absfemale abstab;


	FUNCTION GET_PARAMETER
		(p_parameter_string	 IN VARCHAR2
                ,p_token				 IN VARCHAR2
                ,p_segment_number  IN NUMBER default NULL ) RETURN VARCHAR2;
	PROCEDURE GET_ALL_PARAMETERS
		(p_payroll_action_id	IN   	    NUMBER
		,p_business_group_id    OUT  NOCOPY NUMBER
		,p_legal_employer_id    OUT  NOCOPY NUMBER
		,p_start_date           OUT  NOCOPY DATE
		,p_end_date             OUT  NOCOPY DATE
		,p_archive		OUT NOCOPY VARCHAR2
		,p_effective_date       OUT  NOCOPY DATE
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

       PROCEDURE DEINITIALIZE_CODE(p_payroll_action_id IN NUMBER);

END PAY_NO_ARCHIVE_ABSENCE;

 

/
