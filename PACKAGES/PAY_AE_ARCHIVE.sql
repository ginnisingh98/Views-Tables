--------------------------------------------------------
--  DDL for Package PAY_AE_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyaeparc.pkh 120.0.12000000.1 2007/01/17 15:22:56 appldev noship $ */

FUNCTION GET_PARAMETER(p_parameter_string IN VARCHAR2
                      ,p_token            IN VARCHAR2
                      ,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2;

PROCEDURE GET_ALL_PARAMETERS(p_payroll_action_id    IN   NUMBER
                            ,p_business_group_id    OUT  NOCOPY NUMBER
                            ,p_start_date           OUT  NOCOPY VARCHAR2
                            ,p_end_date             OUT  NOCOPY VARCHAR2
                            ,p_effective_date       OUT  NOCOPY DATE
                            ,p_payroll_id           OUT  NOCOPY VARCHAR2
                            ,p_consolidation_set    OUT  NOCOPY VARCHAR2);

PROCEDURE RANGE_CODE (p_payroll_action_id    IN    NUMBER
                     ,p_sql    OUT   NOCOPY VARCHAR2) ;

PROCEDURE ASSIGNMENT_ACTION_CODE (p_payroll_action_id     IN NUMBER
                                 ,p_start_person          IN NUMBER
                                 ,p_end_person            IN NUMBER
                                 ,p_chunk                 IN NUMBER);

PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER);

PROCEDURE SETUP_ELEMENT_DEFINITIONS( p_classification_name IN VARCHAR2
                                    ,p_element_name        IN VARCHAR2
                                    ,p_element_type_id     IN NUMBER
				    ,p_element_type        IN VARCHAR2
                                    ,p_input_value_id      IN NUMBER
                                    ,p_input_value         IN VARCHAR2
                                    ,p_uom                 IN VARCHAR2
                                    ,p_archive_flag        IN VARCHAR2);

PROCEDURE SETUP_BALANCE_DEFINITIONS(p_balance_name         IN VARCHAR2
                                   ,p_defined_balance_id   IN NUMBER
                                   ,p_balance_type_id      IN NUMBER
				   ,p_uom                  IN VARCHAR2);

FUNCTION GET_COUNTRY_NAME(p_territory_code VARCHAR2) RETURN VARCHAR2;

PROCEDURE ARCHIVE_EMPLOYEE_DETAILS (p_archive_assact_id        	IN NUMBER
                                   ,p_assignment_id            	IN NUMBER
                                   ,p_assignment_action_id      IN NUMBER
                                   ,p_payroll_action_id         IN NUMBER
                                   ,p_time_period_id            IN NUMBER
                                   ,p_date_earned              	IN DATE
                                   ,p_pay_date_earned           IN DATE
                                   ,p_effective_date            IN DATE);

PROCEDURE ARCHIVE_ELEMENT_INFO(	p_payroll_action_id  IN NUMBER
				,p_effective_date    IN DATE
				,p_date_earned       IN DATE
				,p_pre_payact_id     IN NUMBER);

PROCEDURE ARCHIVE_MAIN_ELEMENTS(p_archive_assact_id     IN NUMBER,
							p_assignment_action_id  IN NUMBER,
							p_assignment_id         IN NUMBER,
							p_date_earned           IN DATE,
							p_effective_date        IN DATE  );

FUNCTION GET_DEFINED_BALANCE_ID(p_user_name IN VARCHAR2) RETURN NUMBER;

PROCEDURE ARCHIVE_PAYMENT_INFO(p_archive_assact_id IN NUMBER,
                               p_prepay_assact_id  IN NUMBER,
                               p_assignment_id     IN NUMBER,
                               p_date_earned       IN DATE,
                               p_effective_date    IN DATE);

PROCEDURE ARCHIVE_ADD_ELEMENT(p_archive_assact_id     IN NUMBER,
			      p_assignment_action_id  IN NUMBER,
                              p_assignment_id         IN NUMBER,
                              p_payroll_action_id     IN NUMBER,
                              p_date_earned           IN DATE,
                              p_effective_date        IN DATE,
                              p_pre_payact_id         IN NUMBER,
                              p_archive_flag          IN VARCHAR2);

PROCEDURE ARCHIVE_OTH_BALANCE(p_archive_assact_id     IN NUMBER,
                              p_assignment_action_id  IN NUMBER,
                              p_assignment_id         IN NUMBER,
                              p_payroll_action_id     IN NUMBER,
                              p_record_count          IN NUMBER,
                              p_pre_payact_id         IN NUMBER,
                              p_effective_date        IN DATE,
                              p_date_earned           IN DATE,
                              p_archive_flag          IN VARCHAR2);


PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
                      ,p_effective_date       IN DATE);


END PAY_AE_ARCHIVE;

 

/
