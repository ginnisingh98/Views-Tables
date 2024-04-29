--------------------------------------------------------
--  DDL for Package PSP_CREATE_EFF_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_CREATE_EFF_REPORTS" 
/* $Header: PSPERCRS.pls 120.4 2006/01/19 07:34 tbalacha noship $*/


AUTHID CURRENT_USER AS


   PROCEDURE effort_asg_action_code (p_pactid IN NUMBER,
                                  stperson IN NUMBER,
                                  endperson IN NUMBER,
                                  p_chunk_num IN NUMBER);

PROCEDURE PSPREP_INIT(p_payroll_action_id IN NUMBER);

  PROCEDURE EFFORT_ARCHIVE(payroll_action_id  IN NUMBER,
                           chunk_number IN NUMBER);


  PROCEDURE CREATE_EFFORT_REPORTS(errBuf          	OUT NOCOPY VARCHAR2,
 		    retCode 	    	OUT NOCOPY VARCHAR2,
                    p_pactid            IN NUMBER,
                    p_request_id        IN NUMBER,
                    p_chunk_num         IN     NUMBER
		 );

  Procedure populate_eff_tables(errBuf          OUT NOCOPY VARCHAR2,
                    retCode         OUT NOCOPY VARCHAR2,
                    p_pactid      IN NUMBER,
                    p_request_id  IN  NUMBER,
                    p_chunk_num  IN NUMBER,
                    p_supercede_mode IN VARCHAR2 default null       -- added for supercede
                    );

   PROCEDURE populate_error_table(p_request_id IN NUMBER, p_start_person IN NUMBER, p_end_person IN NUMBER, p_min_effort_report_id IN NUMBER, p_retry_request_id IN NUMBER, p_mode in varchar2, p_match_level in varchar2);

g_lookup_code  varchar2(30);



  type effort_sum_criteria_type is record
  (
     array_sum_criteria  t_varchar_30_type := t_varchar_30_type(NULL),
     array_sum_order     t_num_15_type := t_num_15_type(NULL),
     array_criteria_value1 t_varchar_30_type := t_varchar_30_type(NULL),
     array_criteria_value2  t_varchar_30_type := t_varchar_30_type(NULL)

  );

 eff_template_sum_rec effort_sum_criteria_type;


type person_rec_type is record
(
  person_id t_num_15_type := t_num_15_type(NULL)

);

person_array  person_rec_type;


 g_exec_string varchar2(8000);
 g_psp_request_id   number;
 g_psp_template_id  number;
 g_psp_effort_start date;
 g_psp_effort_end    date;



  type person_eff_rec_type is record
(
  array_person_id  t_num_15_type := t_num_15_type(NULL) ,
 array_effort_report_id t_num_15_type := t_num_15_type(NULL) ,
 sum_tot   t_num_15_2_type := t_num_15_2_type(NULL) ,
 payroll_percent_tot t_num_15_2_type := t_num_15_2_type(NULL) ,
 array_assignment_id t_num_15_type := t_num_15_type(NULL)
);

 person_rec  person_eff_rec_type;
  type details_array_rec_type is record

(

  effort_report_detail_id  t_num_15_type := t_num_15_type(NULL) ,
  effort_report_id t_num_15_type := t_num_15_type(NULL)
);

 details_array  details_array_rec_type;

   det_effort_report_id         t_num_15_type := t_num_15_type(NULL) ;
   det_effort_report_detail_id  t_num_15_type  := t_num_15_type(NULL);
   det_person_id               t_num_15_type := t_num_15_type(NULL) ;
   det_segment1               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment2               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment3               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment4               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment5               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment6               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment7               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment8               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment9               t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment10              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment11              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment12              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment13              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment14              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment15              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment16              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment17              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment18              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment19              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment20              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment21              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment22              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment23              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment24              t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment25             t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment26             t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment27             t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment28             t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment29             t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_segment30             t_varchar_25_type := t_varchar_25_type(NULL) ;
   det_assignment_id         t_num_15_type := t_num_15_type(NULL);
   det_project_id           t_num_15_type := t_num_15_type(NULL) ;
   det_exp_org_id           t_num_15_type := t_num_15_type(NULL) ;
   det_expenditure_type    t_varchar_30_type := t_varchar_30_type(NULL);
   det_task_id              t_num_15_type := t_num_15_type(NULL) ;
   det_award_id             t_num_15_type := t_num_15_type(NULL) ;
   det_distribution_amount  t_num_15_2_type := t_num_15_2_type(NULL);
   det_sum_amount           t_number_type := t_number_type(NULL) ;
   det_dr_cr_flag           t_varchar_1_type := t_varchar_1_type(NULL);
   det_schedule_start_date  t_date_type := t_date_type(NULL) ;
   det_schedule_end_date    t_date_type := t_date_type(NULL);


 type eff_det_lines_type is record
 (
   effort_report_detail_id  t_num_15_type := t_num_15_type(NULL) ,
   person_id             t_num_15_type := t_num_15_type(NULL)
 );

 -- for supercede
 g_summarization_criteria varchar2(2000);

    PROCEDURE VALIDATE_PTAOE(p_start_person		IN		NUMBER,
				             p_end_person		IN		NUMBER,
               				 p_request_id		IN		NUMBER,
               				 p_retry_request_id	IN		NUMBER,
            				 p_return_status	OUT	NOCOPY	VARCHAR2);

END;
 

/
