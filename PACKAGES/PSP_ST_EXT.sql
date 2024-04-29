--------------------------------------------------------
--  DDL for Package PSP_ST_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ST_EXT" AUTHID CURRENT_USER as
/* $Header: PSPTREXS.pls 120.4 2006/12/22 04:24:41 vdharmap noship $ */

--- PROCEDURE summary_extension;
-- replaced the above procedure with four procedures below for 2968684
 procedure summary_ext_adjustment(p_adj_sum_batch_name IN VARCHAR2,
                                  p_business_group_id  IN NUMBER,
                                  p_set_of_books_id    IN NUMBER);

 procedure summary_ext_actual(p_source_type        IN VARCHAR2,
                              p_source_code        IN VARCHAR2,
                              p_payroll_id         IN NUMBER,
                              p_time_period_id     IN NUMBER,
                              p_batch_name         IN VARCHAR2,
                              p_business_group_id  IN NUMBER,
                              p_set_of_books_id    IN NUMBER);

 procedure summary_ext_encumber(p_payroll_id        IN NUMBER,
                                p_business_group_id IN NUMBER,
                                p_set_of_books_id   IN NUMBER);

 procedure summary_ext_encumber_liq(p_payroll_id        IN  NUMBER,
                                    p_action_type       IN VARCHAR2,
                                    p_business_group_id IN NUMBER,
                                    p_set_of_books_id   IN NUMBER);

 FUNCTION get_enc_amount( p_assignment_id 	IN 	NUMBER ,
			  p_element_type_id	IN	NUMBER,
			  p_time_period_id 	IN	NUMBER,
           		  p_asg_start_date	IN	DATE,
           	 	  p_asg_end_date	IN	DATE)
 return NUMBER;

PROCEDURE get_labor_enc_dates	(p_project_id			IN	NUMBER,
				p_task_id			IN	NUMBER,
				p_award_id			IN	NUMBER,
				p_expenditure_type		IN	VARCHAR2,
				p_expenditure_organization_id	IN	NUMBER,
				p_payroll_id			IN	NUMBER,
				p_start_date			OUT NOCOPY	DATE,
				p_end_date			OUT NOCOPY	DATE);

--- added for 5643110
PROCEDURE tieback_actual(p_payroll_control_id   IN  NUMBER,
                        p_source_type        IN  VARCHAR2,
                        p_period_end_date    IN  DATE,
                        p_gms_batch_name     IN  VARCHAR2,
                        p_txn_source         in varchar2,
                        p_business_group_id  IN NUMBER,
                        p_set_of_books_id    IN NUMBER);

----- new procedure for 5463110
PROCEDURE tieback_adjustment(p_payroll_control_id   IN  NUMBER,
                             p_adjutment_batch_name in varchar2,
                             p_gms_batch_name     IN  VARCHAR2,
                             p_business_group_id  IN NUMBER,
                             p_set_of_books_id    IN NUMBER);

END PSP_ST_EXT;

/
