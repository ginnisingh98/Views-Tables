--------------------------------------------------------
--  DDL for Package PAY_IN_INDIA_BENEFITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_INDIA_BENEFITS" AUTHID CURRENT_USER AS
/* $Header: pyinmed.pkh 120.8 2008/04/23 12:19:38 lnagaraj noship $ */

-- Global Variables Section
type t_element_values_rec is record
(element_name pay_element_types_f.element_name%TYPE
,input_name   pay_input_values_f.name%TYPE
,planned_val  pay_element_entry_values.screen_entry_value%TYPE
,actual_val   pay_element_entry_values.screen_entry_value%TYPE
);

type t_element_values_tab is table of t_element_values_rec
  index by binary_integer;

type t_tab_entry_details_rec is record
(entry_id     pay_element_entries_f.element_entry_id%TYPE
,input1_value pay_element_entry_values.screen_entry_value%TYPE
,input2_value pay_element_entry_values.screen_entry_value%TYPE
,input3_value pay_element_entry_values.screen_entry_value%TYPE
);

type t_entry_details_tab is table of t_tab_entry_details_rec
  index by binary_integer;

  FUNCTION get_med_submitted(p_assignment_id NUMBER
                           ,p_tax_yr     VARCHAR2
			   ,p_created_from DATE DEFAULT NULL
			   ,p_created_to DATE DEFAULT NULL
			   ,p_approval_status VARCHAR2 DEFAULT NULL)
  RETURN NUMBER ;

  FUNCTION get_med_exempted(p_assignment_id NUMBER
                           ,p_tax_yr     VARCHAR2
		           ,p_created_from DATE DEFAULT NULL
		           ,p_created_to DATE DEFAULT NULL
		           ,p_approval_status VARCHAR2 DEFAULT NULL)
  RETURN NUMBER ;

  FUNCTION get_ltc_submitted(p_assignment_id NUMBER
                            ,p_tax_yr     VARCHAR2
			    ,p_created_from DATE DEFAULT NULL
			    ,p_created_to DATE DEFAULT NULL
			    ,p_approval_status VARCHAR2 DEFAULT NULL
			    ,p_carry_over IN VARCHAR2 )
  RETURN NUMBER ;


  FUNCTION get_ltc_exempted(p_assignment_id NUMBER
                           ,p_tax_yr     VARCHAR2
			   ,p_created_from DATE DEFAULT NULL
			   ,p_created_to DATE DEFAULT NULL
			   ,p_approval_status VARCHAR2 DEFAULT NULL
			   ,p_carry_over IN VARCHAR2 )
  RETURN NUMBER ;


  FUNCTION get_med_bill_date(p_assignment_id NUMBER
                            ,p_tax_yr     VARCHAR2
		 	    ,p_created_from DATE DEFAULT NULL
		 	    ,p_created_to DATE DEFAULT NULL
			    ,p_approval_status VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;


  FUNCTION get_last_updated_date(p_assignment_id      IN NUMBER
                                ,p_block              IN VARCHAR2
                                ,p_asg_info_type      IN VARCHAR2
	                        ,p_created_from       IN DATE DEFAULT NULL
	                        ,p_created_to         IN DATE DEFAULT NULL
	                        ,p_approved           IN VARCHAR2 DEFAULT NULL
                                ,p_carry_over IN VARCHAR2 default null				)
  RETURN DATE;

  FUNCTION get_entry_value(p_assignment_id IN NUMBER
                          ,p_entry_id IN NUMBER
                          ,p_input_name IN VARCHAR2
			  ,p_date      IN DATE)
  RETURN VARCHAR2 ;



  FUNCTION get_relationship(p_person_id         IN NUMBER
                           ,p_business_group_id IN NUMBER)
  RETURN VARCHAR2;



  PROCEDURE set_profile(p_person_id IN NUMBER);


  PROCEDURE delete_medical_bill_entry(
                              p_asg_extra_info_id IN NUMBER);

  PROCEDURE medical_bill_entry(p_asg_id IN NUMBER
                              ,p_financial_yr IN VARCHAR2 DEFAULT NULL /* needed mainly for PU*/
                              ,p_bill_date IN DATE DEFAULT NULL
			      ,p_person_id IN NUMBER
			      ,p_con_person_id IN NUMBER DEFAULT NULL
			      ,p_old_bill_amt IN NUMBER DEFAULT NULL
			      ,p_new_bill_amt IN NUMBER DEFAULT NULL
			      ,p_old_exempt_amt IN NUMBER DEFAULT NULL
			      ,p_new_exempt_amt IN NUMBER DEFAULT NULL
			      ,p_element_entry_id IN NUMBER DEFAULT NULL
			      ,p_bill_number IN VARCHAR2 DEFAULT NULL
			      ,p_asg_extra_info_id IN NUMBER DEFAULT NULL
			      ,p_ovn IN NUMBER DEFAULT NULL
			      ,p_business_group_id IN NUMBER
			      ,p_element_entry_date IN DATE
			      ,p_super_user IN VARCHAR2
			      ,p_ee_comments IN VARCHAR2
			      ,p_er_comments IN VARCHAR2
                              );

  PROCEDURE ltc_bill_entry(p_asg_id IN NUMBER
                            ,p_ltc_block IN VARCHAR2 DEFAULT NULL /* needed mainly for PU*/
			    ,p_ben_name IN VARCHAR2 DEFAULT NULL
			    ,p_place_from IN VARCHAR2 DEFAULT NULL
			    ,p_bill_number IN VARCHAR2 DEFAULT NULL
			    ,p_ee_comments IN VARCHAR2
			    ,p_er_comments IN VARCHAR2
                            ,p_place_to IN VARCHAR2 DEFAULT NULL
	                    ,p_travel_mode IN VARCHAR2 DEFAULT NULL
			    ,p_bill_amt IN NUMBER DEFAULT NULL
			    ,p_exempt_amt IN NUMBER DEFAULT NULL
			    ,p_element_entry_id IN OUT NOCOPY NUMBER
			    ,p_start_date IN DATE
			    ,p_end_date IN DATE
			    ,p_carry_over_flag IN VARCHAR2 DEFAULT NULL
			    ,p_asg_extra_info_id IN NUMBER DEFAULT NULL
			    ,p_element_entry_date IN DATE
			    ,p_super_user IN VARCHAR2
			    ,p_person_id IN NUMBER
 , p_warnings OUT NOCOPY VARCHAR2
                            );
 FUNCTION get_medical_balance( p_asg_id IN NUMBER,
                               p_tax_year IN VARCHAR2,
			       p_balance_name IN VARCHAR2)
 RETURN NUMBER;

FUNCTION get_ltc_balance (p_asg_id IN NUMBER,
                          p_ltc_block  IN VARCHAR2,
  	                  p_balance_name IN VARCHAR2)
RETURN NUMBER ;

PROCEDURE is_locked( p_person_id  IN  NUMBER
                    ,p_ltc_or_med IN VARCHAR2
                    ,p_locked     OUT NOCOPY VARCHAR2 ) ;
PROCEDURE update_ltc_element
(
 p_employee_number          IN VARCHAR2
,p_full_name                IN VARCHAR2
,p_start_date               IN DATE
,p_effective_end_date       IN DATE DEFAULT NULL
,p_fare		            IN NUMBER
,p_blockYr		    IN VARCHAR2
,p_carry		    IN VARCHAR2
,p_benefit		    IN NUMBER
,p_assignment_id            IN NUMBER
,p_element_entry_id         IN NUMBER  DEFAULT NULL
,p_warnings                 OUT NOCOPY VARCHAR2
);

END pay_in_india_benefits;

/
