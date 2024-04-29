--------------------------------------------------------
--  DDL for Package PA_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MISC" AUTHID CURRENT_USER AS
/* $Header: PAMISCS.pls 115.0 99/07/16 15:08:05 porting ship $ */

 FUNCTION get_exp_cycle_start_day_code RETURN NUMBER;
 pragma RESTRICT_REFERENCES (get_exp_cycle_start_day_code, WNDS, WNPS );

 FUNCTION get_set_of_books_id RETURN NUMBER;
 pragma RESTRICT_REFERENCES (get_set_of_books_id, WNDS, WNPS );

 FUNCTION get_job_id (
                      x_person_id      IN NUMBER,
                      x_task_id        IN NUMBER,
                      x_project_id     IN NUMBER,
                      x_effective_date IN DATE
                     )
                     RETURN NUMBER;
 pragma RESTRICT_REFERENCES (get_job_id, WNDS, WNPS );

 FUNCTION get_week_ending_date (
                                x_expenditure_item_date IN DATE
                               )
                               RETURN DATE;
 pragma RESTRICT_REFERENCES (get_week_ending_date, WNDS, WNPS );


 FUNCTION get_month_ending_date (
                                x_expenditure_item_date IN DATE
                               )
                               RETURN DATE;
 pragma RESTRICT_REFERENCES (get_month_ending_date, WNDS, WNPS );

 FUNCTION get_pa_period (
                         x_pa_date IN DATE
                        )
                        RETURN VARCHAR2;
 pragma RESTRICT_REFERENCES (get_pa_period, WNDS, WNPS );

 FUNCTION get_gl_period (
                         x_gl_date IN DATE
                        )
                        RETURN VARCHAR2;
 pragma RESTRICT_REFERENCES (get_gl_period, WNDS, WNPS );

 FUNCTION spread_amount (
		        x_type_of_spread    IN VARCHAR2,
		        x_start_date        IN DATE,
		        x_end_date          IN DATE,
		        x_start_pa_date     IN DATE,
		        x_end_pa_date       IN DATE,
		        x_amount            IN NUMBER)
		        RETURN NUMBER ;
 pragma RESTRICT_REFERENCES ( spread_amount, WNDS, WNPS );

END PA_MISC;

 

/
