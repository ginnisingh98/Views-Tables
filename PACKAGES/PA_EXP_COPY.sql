--------------------------------------------------------
--  DDL for Package PA_EXP_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXP_COPY" AUTHID CURRENT_USER AS
/* $Header: PAXTEXCS.pls 120.1 2005/08/09 04:53:30 avajain noship $ */

  PROCEDURE  ValidateEmp ( X_person_id  IN NUMBER
                         , X_date       IN DATE
                         , X_status     OUT NOCOPY VARCHAR2 );

  PROCEDURE  CopyItems ( X_orig_exp_id   IN NUMBER
                       , X_new_exp_id    IN NUMBER
                       , X_date          IN DATE
                       , X_person_id     IN NUMBER
		       , P_Inc_By_Org_Id IN NUMBER ); /* Added parameter for enhancement bug 2683803 */

  PROCEDURE  preapproved ( copy_option             IN VARCHAR2
                         , copy_items              IN VARCHAR2
                         , orig_exp_group          IN VARCHAR2
                         , new_exp_group           IN VARCHAR2
                         , orig_exp_id             IN NUMBER
                         , exp_ending_date         IN DATE
                         , new_inc_by_person       IN NUMBER
                         , userid                  IN NUMBER
                         , procedure_num_copied    IN OUT NOCOPY NUMBER
                         , procedure_num_rejected  IN OUT NOCOPY NUMBER
                         , procedure_return_code   IN OUT NOCOPY VARCHAR2
			  /** start of bug fix 2329146 **/
		         , p_sys_link_function     IN VARCHAR2 default null
                         , p_exp_type_class_code   IN VARCHAR2 default 'PT'
			  /** end of bug fix **/
			 , P_Update_Emp_Orgs       IN VARCHAR2 default NULL /* Added parameter for bug 2683803 */
                          );

  PROCEDURE online ( orig_exp_id            IN NUMBER
                   , new_exp_id             IN NUMBER
                   , exp_ending_date        IN DATE
                   , X_inc_by_person        IN NUMBER
                   , userid                 IN NUMBER
                   , procedure_return_code  IN OUT NOCOPY VARCHAR2 );

  PROCEDURE ReverseExpGroup ( X_orig_exp_group       IN VARCHAR2
                        ,  X_new_exp_group           IN VARCHAR2
                        ,  X_user_id                 IN NUMBER
                        ,  X_module                  IN VARCHAR2
                        ,  X_num_reversed            IN OUT NOCOPY NUMBER
                        ,  X_num_rejected            IN OUT NOCOPY NUMBER
                        ,  X_return_code             IN OUT NOCOPY VARCHAR2
                        ,  X_expgrp_status           IN VARCHAR2 DEFAULT 'WORKING' );

  /* Added function below for Bug 2678790 */
  Function Check_lcm(P_Lcm_Name IN Pa_Expenditure_Items_All.Labor_Cost_Multiplier_Name%TYPE,
                           P_Ei_Date  IN Pa_Expenditure_Items_All.Expenditure_Item_Date%TYPE) RETURN VARCHAR2;

END  PA_EXP_COPY;
 

/
