--------------------------------------------------------
--  DDL for Package PA_ONLINE_COPY_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ONLINE_COPY_EXP" AUTHID CURRENT_USER AS
/* $Header: PAXTRCPS.pls 120.1 2005/08/17 12:57:08 ramurthy noship $ */

  PROCEDURE  ValidateEmp ( X_ei_date           IN DATE
			 , X_job_id            IN OUT NOCOPY NUMBER
                         , X_status            IN OUT NOCOPY VARCHAR2 );

  PROCEDURE  CopyItems ( X_orig_exp_id      IN NUMBER
                       , X_new_exp_id       IN NUMBER
                       , X_days_diff        IN NUMBER
		       , x_total_exp_copied IN OUT NOCOPY NUMBER);

  PROCEDURE  Copy_exp ( orig_exp_id            IN NUMBER
                      , old_exp_ending_date    IN DATE
                      , new_exp_id             IN NUMBER
                      , new_exp_ending_date    IN DATE
                      , incurred_by_org_id     IN NUMBER
                      , expenditure_class_code IN VARCHAR2
		      , x_exp_status_code      IN VARCHAR2
                      , x_exp_source_code      IN VARCHAR2
                      , x_copy_exp_type_flag   IN VARCHAR2
                      , x_copy_qty_flag        IN VARCHAR2
                      , x_copy_cmt_flag        IN VARCHAR2
                      , x_copy_dff_flag        IN VARCHAR2
		      , x_copy_attachment_flag IN VARCHAR2
                      , X_inc_by_person        IN NUMBER
                      , X_entered_by_person_id IN NUMBER
                      , userid                 IN NUMBER
		      , x_total_exp_copied     IN OUT NOCOPY NUMBER);

  PROCEDURE Validate_item (x_project_id IN NUMBER,
                           x_task_id IN NUMBER,
                           x_expenditure_item_date IN DATE,
                           x_expenditure_type IN VARCHAR2,
			   x_sys_link_func IN VARCHAR2,
                           x_quantity IN NUMBER,
                           x_attribute_category IN VARCHAR2,
                           x_attribute1 IN VARCHAR2,
                           x_attribute2 IN VARCHAR2,
                           x_attribute3 IN VARCHAR2,
                           x_attribute4 IN VARCHAR2,
                           x_attribute5 IN VARCHAR2,
                           x_attribute6 IN VARCHAR2,
                           x_attribute7 IN VARCHAR2,
                           x_attribute8 IN VARCHAR2,
                           x_attribute9 IN VARCHAR2,
                           x_attribute10 IN VARCHAR2,
			   x_billable_flag IN OUT NOCOPY VARCHAR2,
			   x_job_id        IN OUT NOCOPY NUMBER,
                           temp_outcome IN OUT NOCOPY VARCHAR2);

  FUNCTION EXP_EXISTS_IN_DENORM(x_orig_exp_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (EXP_EXISTS_IN_DENORM, WNDS, WNPS ) ;

END  PA_ONLINE_COPY_EXP;

 

/
