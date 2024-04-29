--------------------------------------------------------
--  DDL for Package PSP_TEMPLATE_SELECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_TEMPLATE_SELECTION" 
/* $Header: PSPTPLSLS.pls 120.1 2005/07/08 02:33 spchakra noship $*/


AUTHID CURRENT_USER AS


PROCEDURE insert_into_template_history(p_payroll_action_id  IN NUMBER, p_request_id OUT NOCOPY NUMBER );
PROCEDURE range_code(pactid IN NUMBER, sqlstr out nocopy varchar2);


  Procedure get_final_selection_list(errBuf          OUT NOCOPY VARCHAR2,
                    retCode         OUT NOCOPY VARCHAR2,
                    p_request_id  IN  NUMBER,
                    p_person_asg_flag  IN  BOOLEAN
                    );





 PROCEDURE get_lowest_cardinality (p_request_id IN NUMBER, p_effort_start IN
DATE, p_effort_end IN DATE, p_business_group_id IN NUMBER, p_set_of_books_id IN NUMBER);

PROCEDURE prepare_initial_person_list(p_request_id IN NUMBER, p_effort_start
IN DATE, p_effort_end IN DATE, p_business_group_id IN NUMBER, p_Set_of_books_id IN NUMBER);

PROCEDURE prune_initial_person_list(p_request_id IN NUMBER, p_effort_start IN DATE, p_effort_end IN DATE,
  p_business_group_id IN NUMBER, p_set_of_books_id IN NUMBER);

PROCEDURE apply_exclusion_criteria(p_request_id IN NUMBER, p_effort_start DATE, p_effort_end DATE,
  p_business_group_id IN NUMBER, p_set_of_books_id IN NUMBER);

--	Introduced the folowing procedures for UVA bug fix 4429787
	PROCEDURE get_asg_lowest_cardinality	(p_request_id		IN	NUMBER,
						p_effort_start		IN	DATE,
						p_effort_end		IN	DATE,
						p_business_group_id	IN	NUMBER,
						p_set_of_books_id	IN	NUMBER);

	PROCEDURE prepare_initial_asg_list(p_request_id		IN	NUMBER,
						p_effort_start		IN	DATE,
						p_effort_end		IN	DATE,
						p_business_group_id	IN	NUMBER,
						p_set_of_books_id	IN	NUMBER);

	PROCEDURE prune_initial_asg_list	(p_request_id		IN	NUMBER,
						p_effort_start		IN	DATE,
						p_effort_end		IN	DATE,
						p_business_group_id	IN	NUMBER,
						p_set_of_books_id	IN	NUMBER);

	PROCEDURE apply_asg_exclusion_criteria	(p_request_id		IN	NUMBER,
						p_effort_start		IN	DATE,
						p_effort_end		IN	DATE,
						p_business_group_id	IN	NUMBER,
						p_set_of_books_id	IN	NUMBER);
--	End of changes for bug fix 4429787

PROCEDURE apply_ff_formula_exclusion(p_request_id IN NUMBER, p_effort_start DATe, p_effort_end DATE);


 g_lookup_code  varchar2(30);
 g_exec_string varchar2(4000);


 TYPE t_varchar_30_type is TABLE Of VARCHAR2(30)  INDEX BY BINARY_INTEGER;
 TYPE t_varchar_1_type is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE t_num_15_type      IS TABLE OF NUMBER(15)          INDEX BY BINARY_INTEGER;
  TYPE t_num_1_type      IS TABLE OF NUMBER(1)          INDEX BY BINARY_INTEGER;



  type template_sel_criteria_type is record
  (
     array_sel_criteria  t_varchar_30_type

  );

 template_rec template_sel_criteria_type;

  type template_Selection_values_type is record
(

  array_sel_criteria t_varchar_30_type,
  array_inc_exc_flag t_varchar_1_type,
  array_criteria_value1 t_varchar_30_type,
  array_criteria_value2 t_varchar_30_type,
  array_criteria_value3 t_varchar_30_type
);

 template_sel_criteria template_selection_values_type;

  type effort_sum_criteria_type is record
  (
     array_sum_criteria  t_varchar_30_type,
     array_sum_order     t_num_1_type,
     array_criteria_value1 t_varchar_30_type ,
     array_criteria_value2  t_varchar_30_type

  );

 eff_template_sum_rec effort_sum_criteria_type;

  type person_rec_type is record
(
  array_person_id  t_num_15_type ,
 array_effort_report_id t_num_15_type,
 sum_tot   t_num_15_type
);



FUNCTION get_parameter_value(name in varchar2, parameter_list varchar2) return varchar2;

END;

 

/
