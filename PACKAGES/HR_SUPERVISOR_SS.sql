--------------------------------------------------------
--  DDL for Package HR_SUPERVISOR_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SUPERVISOR_SS" 
/* $Header: hrsupwrs.pkh 120.1 2005/09/22 10:04:19 svittal noship $*/
AUTHID CURRENT_USER AS

     -- declare a table for storing txn steps
    gtt_transaction_steps  hr_transaction_ss.transaction_table ;

    TYPE lrt_direct_reports is RECORD (
      last_name      per_people_f.last_name%type DEFAULT NULL,
      first_name     per_people_f.first_name%type ,
      person_id      per_people_f.person_id%type ,
      full_name      per_people_f.full_name%type ,
      assignment_id  per_assignments_f.assignment_id%type,
      supervisor_id  per_people_f.person_id%type,
      -- Assignment Security
      supervisor_assignment_id  per_assignments_f.supervisor_assignment_id%type,

      supervisor_name  per_people_f.full_name%type ,
      effective_date VARCHAR2(20) DEFAULT NULL,
      error_code     VARCHAR2(10) );

    TYPE ltt_direct_reports is table of lrt_direct_reports
       INDEX BY BINARY_INTEGER ;

/*
  ||===========================================================================
  || FUNCTION: update_object_version
  || DESCRIPTION: Update the object version number in the transaction step
  ||              to pass the invalid object api error for Save for Later.
  ||=======================================================================
  */
  PROCEDURE update_object_version
  (p_transaction_step_id in     number
  ,p_login_person_id in number);

  /*
  ||===========================================================================
  || PROCEDURE: branch_on_cost_center_mgr
  || DESCRIPTION:
  ||        This procedure will read the CURRENT_PERSON_ID item level
  ||        attribute value and then find out nocopy if the employee to be terminated
  ||        is a cost center manager or not.  If yes, it will set the WF item
  ||        attribute HR_TERM_COST_CENTER_MGR_FLAG to 'Y' and the WF result code
  ||        will be set to "Y".  In doing so,  workflow will transition to the
  ||        Cost Center page accordingly.
  ||        This procedure will set the wf transition code as follows:
  ||          (Y/N)
  ||          For 'Y'    => branch to Cost Center page
  ||              'N'    => do not branch to Cost Center page
  ||=======================================================================
  */
PROCEDURE branch_on_cost_center_mgr
 (itemtype     in     varchar2
  ,itemkey     in     varchar2
  ,actid       in     number
  ,funcmode    in     varchar2
  ,resultout   out nocopy varchar2);

/*
  ||===========================================================================
  || PROCEDURE: create_transaction
  || DESCRIPTION: Create transaction and transaction steps.
  ||===========================================================================
  */

  PROCEDURE  Create_transaction(
     p_item_type               IN WF_ITEMS.ITEM_TYPE%TYPE ,
     p_item_key                IN WF_ITEMS.ITEM_KEY%TYPE ,
     p_act_id                  IN NUMBER ,
     p_transaction_id          IN OUT NOCOPY NUMBER ,
     p_transaction_step_id     IN OUT NOCOPY NUMBER,
     p_login_person_id         IN NUMBER ,
     p_review_proc_call        IN VARCHAR2 ,
     p_no_of_direct_reports    IN NUMBER DEFAULT 0,
     p_no_of_emps              IN NUMBER DEFAULT 0 ,
     p_selected_emp_name       IN VARCHAR2 DEFAULT NULL,
     p_single_supervisor_name  IN VARCHAR2 DEFAULT NULL ,
     p_single_effective_date   IN DATE DEFAULT NULL,
     p_term_flag               IN VARCHAR2,
     p_selected_emp_id         IN NUMBER,
     p_rptg_grp_id             IN VARCHAR2 DEFAULT NULL,
     p_plan_id                 IN VARCHAR2 DEFAULT NULL,
     p_effective_date_option   IN VARCHAR2  DEFAULT NULL );


/*
  ||===========================================================================
  || PROCEDURE: process_api
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

   PROCEDURE process_api (
     p_transaction_step_id IN
     hr_api_transaction_steps.transaction_step_id%type,
     p_validate BOOLEAN default FALSE,
     p_effective_date IN VARCHAR2 default NULL) ;


/*
  ||===========================================================================
  || PROCEDURE: write_transaction
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

  PROCEDURE write_transaction (
    p_old_sup_id      NUMBER  default NULL,
    p_old_sup_asg_id      NUMBER  default NULL,
    p_new_sup_id      NUMBER  default NULL,
    -- Assignment Security
    p_new_sup_asg_id      NUMBER  default NULL,

    p_old_sup_name    per_people_f.full_name%type default NULL,
    p_new_sup_name    per_people_f.full_name%type,
    p_emp_name        per_people_f.full_name%type,
    p_emp_id          per_people_f.person_id%type default NULL,
    p_effective_date  Date ,
    p_assignment_id   NUMBER ,
    p_section_code    IN VARCHAR2,
    p_row_num         NUMBER DEFAULT 0,
    p_transaction_step_id  NUMBER,
    p_login_person_id     IN  NUMBER);

/*
  ||===========================================================================
  || PROCEDURE: update_asg
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

  procedure update_asg
  (p_validate                     in     NUMBER default 0
  ,p_effective_date               in     date
  ,p_attribute_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number default null
  -- Assignment Secuirty
  ,p_supervisor_assignment_id     in     number default null

  ,p_assignment_number            in     varchar2 default null
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy NUMBER
  ,p_other_manager_warning           out nocopy NUMBER
  ,p_item_type                    in     varchar2 default null
  ,p_item_key                     in     varchar2 default null
  ,p_actid                        in     varchar2 default null
  ,p_error_message_appl              out nocopy varchar2
  ,p_error_message_name              out nocopy varchar2
  ,p_error_message                   out nocopy    long
  );


/*
  ||===========================================================================
  || PROCEDURE: update_asg
  || DESCRIPTION: This procedure takes all region rows in change manager page
  ||              as a table type structure in out parameter. Iterates through
  ||              the table type rows and calls the overloaded update_asg.
  || Success:     After successfull validation of all rows, writes data into
  ||              transaction tables
  || Failure:     If any of the rows error in validating, then does not write into
  ||              transaction tables and returns the row level error
  ||
  ||===========================================================================
  */

  procedure update_asg
  (p_validate                     in     number default 0
  ,p_attribute_update_mode        in     varchar2
  ,p_manager_details_tab          in out nocopy SSHR_MANAGER_DETAILS_TAB_TYP
  ,p_item_type                    in     varchar2 default null
  ,p_item_key                     in     varchar2 default null
  ,p_actid                        in     varchar2 default null
  ,p_rptg_grp_id                  in     varchar2 default null
  ,p_plan_id                      in     varchar2 default null
  ,p_effective_date_option	  in     varchar2 default null
  ,p_num_of_direct_reports        in     number default 0
  ,p_num_of_new_direct_reports    in     number default 0
  ,p_selected_person_id           in     number
  ,p_selected_person_name         in     varchar2
  ,p_term_sup_flag                in     varchar2
  ,p_login_person_id              in     number
  ,p_save_for_later               in     varchar2 default 'SAVE'
  ,p_transaction_step_id          in out nocopy number
  );



END ;

 

/
