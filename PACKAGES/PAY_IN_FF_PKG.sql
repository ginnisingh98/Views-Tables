--------------------------------------------------------
--  DDL for Package PAY_IN_FF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_FF_PKG" AUTHID CURRENT_USER AS
/*  $Header: pyindedn.pkh 120.3.12010000.3 2008/10/10 09:17:07 mdubasi ship $ */

FUNCTION check_retainer (p_assignment_id     IN NUMBER
                        ,p_payroll_action_id IN NUMBER)
         RETURN NUMBER;

FUNCTION check_edli(p_assignment_id     IN NUMBER
                   ,p_effective_date    IN DATE)
         RETURN VARCHAR2;

FUNCTION get_esi_cont_amt(p_assignment_action_id IN NUMBER
                         ,p_assignment_id        IN NUMBER
                         ,p_date_earned          IN DATE
			 ,p_eligible_amt         IN NUMBER)
         RETURN NUMBER;
FUNCTION round_to_5paise( p_number IN NUMBER)
	 RETURN NUMBER;

FUNCTION get_net_accrual ( p_assignment_id     IN  NUMBER
                               ,p_payroll_id        IN  NUMBER
                               ,p_business_group_id IN  NUMBER
                               ,p_calculation_date  IN  DATE
                               ,p_plan_category     IN  VARCHAR2
                               ,p_message           OUT NOCOPY VARCHAR2
			      )
	RETURN NUMBER;

FUNCTION get_period_number (p_payroll_id IN NUMBER
                           ,p_term_date IN DATE )
RETURN NUMBER;

FUNCTION sec_80dd_percent ( p_assignment_id IN per_all_assignments_f.assignment_id%type
                           ,p_date_earned IN date)
RETURN VARCHAR2;

PROCEDURE check_pf_update
         (p_effective_date   IN  DATE
         ,p_dt_mode          IN  VARCHAR2
         ,p_assignment_id    IN  NUMBER
         ,p_gre_org          IN  VARCHAR2
	 ,p_pf_org           IN  VARCHAR2
	 ,p_esi_org          IN  VARCHAR2
         ,p_message          OUT NOCOPY VARCHAR2
         ,p_gre              IN NUMBER
	 ,p_pf               IN NUMBER
	 ,p_esi              IN NUMBER
         );

PROCEDURE check_esi_update
         (p_effective_date   IN  DATE
	 ,p_dt_mode          IN  VARCHAR2
	 ,p_assignment_id    IN  NUMBER
	 ,p_esi_org           IN  VARCHAR2
         ,p_message          OUT NOCOPY VARCHAR2
	 );

PROCEDURE check_father_husband_name
             (p_assignment_id		IN NUMBER
             ,p_effective_date          IN DATE
	     ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_value             OUT NOCOPY VARCHAR2);

Function in_reset_input_values(p_assignment_id  NUMBER
		      ,p_business_group_id NUMBER
		      ,p_element_type_id   NUMBER
 	              ,p_element_entry_id  NUMBER
                      ,p_date              DATE
		      ,p_input_value       VARCHAR2)

Return Number ;

PROCEDURE check_pf_location
            (p_organization_id  IN NUMBER
  	    ,p_calling_procedure  IN VARCHAR2
            ,p_message_name       OUT NOCOPY VARCHAR2
            ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
            ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type);

FUNCTION get_lwf_state
            (p_organization_id  IN NUMBER) RETURN VARCHAR2;

FUNCTION get_esi_disability_details( p_assignment_id in number
                                    ,p_date_earned in date
                                    ,p_disable_proof out  NOCOPY varchar2)
Return Number;

END pay_in_ff_pkg;


/
