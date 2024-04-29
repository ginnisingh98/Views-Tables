--------------------------------------------------------
--  DDL for Package HR_COMP_PROFILE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMP_PROFILE_SS" AUTHID CURRENT_USER AS
/* $Header: hrcprwrs.pkh 120.0.12010000.5 2008/10/08 09:13:27 psugumar ship $ */
--

API_NAME VARCHAR(50) := 'HR_COMP_PROFILE_SS.PROCESS_API';

COMPETENCES_CHANGED VARCHAR2(30) := 'COMPETENCES_CHANGED';
NEXT                VARCHAR2(10) := 'NEXT';


TYPE transaction_row IS RECORD
        (param_name VARCHAR2(200)
        ,param_value LONG
        ,param_data_type VARCHAR2(200));

TYPE transaction_table1 IS TABLE OF transaction_row INDEX BY BINARY_INTEGER;

g_api_name  varchar2(50) := 'HR_COMP_PROFILE_SS.PROCESS_API';
g_date_format varchar2(15) := 'RRRR-MM-DD';

g_upd_mode                   constant varchar2(30) := 'CORRECT';
g_upgrade_proficiency_mode   constant varchar2(30) := 'UPGRADE';

-- Exceptions
g_fatal_error                  exception;
g_data_err                     exception;
g_access_violation_err         exception;

-- ---------------------------------------------------------------------------
-- ---------------------------- < process_api > ------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure reads the data from transaction table and saves it
--          to the database.
--          This procedure is called after Workflow Approval or the user
--          chooses "Update" without approval in workflow.
-- ---------------------------------------------------------------------------
Procedure process_api(
           p_validate            in boolean  default false
          ,p_transaction_step_id in number
          ,p_effective_date        in varchar2 default null);
--
Procedure api_validate_competence_rec_ss(
           p_item_type             in varchar2
          ,p_item_key              in varchar2
          ,p_activity_id           in varchar2
          ,p_pid                   in number
          ,p_validate              in varchar2
          ,p_business_group_id     in number   default null
          ,p_change_mode           in varchar2 default null
          ,p_competence_element_id in number   default null
          ,p_preupd_obj_vers_num   in number   default null
          ,p_competence_id         in number   default null
          ,p_proficiency_level_id  in number   default null
          ,p_eff_date_from         in varchar2 default null
          ,p_comments              in varchar2 default null
          ,p_eff_date_to           in varchar2 default null
          ,p_proficy_lvl_source    in varchar2 default null
          ,p_certification_mthd    in varchar2 default null
          ,p_certification_date    in varchar2 default null
          ,p_next_certifctn_date   in varchar2 default null
          ,p_competence_status     in varchar2 default NULL -- Competence Qualification Link enhancement
          ,p_transaction_step_id   in out nocopy number
          ,p_error_message         out nocopy long);
--
Procedure process_save_currentupdate(
           p_item_type              in wf_items.item_type%type
          ,p_item_key               in wf_items.item_key%type
          ,p_actid                  in varchar2
          ,p_person_id              in number
          ,p_change_mode            in varchar2  default null
          ,p_preupd_obj_vers_num    in number default null
          ,p_competence_id          in number default null
          ,p_competence_element_id  in number default null
          ,p_competence_name        in varchar2 default null
          ,p_competence_alias       in varchar2 default null
          ,p_proficiency_level_id   in number default null
          ,p_step_value             in number default null
          ,p_preupd_proficy_lvl_id  in number default null
          ,p_certification_mthd     in varchar2 default null
          ,p_proficy_lvl_source     in varchar2 default null
          ,p_eff_date_from          in varchar2 default null
          ,p_eff_date_to            in varchar2 default null
          ,p_certification_date     in varchar2 default null
          ,p_next_certifctn_date    in varchar2 default null
          ,p_comments               in varchar2 default null
          ,p_prev_step_value        in number   default null
          ,p_prev_start_date        in varchar2 default null
          ,p_competence_status      IN VARCHAR2 DEFAULT NULL -- Competence Qualification Link enhancement
          ,transaction_step_id      in number default null);
--

FUNCTION comp_not_exists
    (p_item_type in varchar2
    ,p_item_key in varchar2
    ,p_person_id in number
    ,p_competence_id in number
    ) Return varchar2;

PROCEDURE save_transaction_step(
                   p_item_type IN VARCHAR2
                  ,p_item_key IN VARCHAR2
          ,p_actid IN NUMBER
          ,p_login_person_id IN NUMBER
          ,p_transaction_step_id IN OUT NOCOPY NUMBER
                  ,p_api_name IN VARCHAR2  default null
                  ,p_api_display_name IN VARCHAR2 DEFAULT NULL
          ,p_transaction_data IN TRANSACTION_TABLE1) ;
--
PROCEDURE delete_transaction_step_id(
           p_transaction_step_id IN number);
--
PROCEDURE delete_all_ids(
           p_item_type in varchar2
          ,p_item_key  in varchar2);
--
Procedure del_pen_currupd_ids(
           p_item_type IN varchar2
          ,p_item_key  IN varchar2);
--
Procedure del_add_ids(
           p_item_type IN varchar2
          ,p_item_key  IN varchar2) ;

-- to save data on update main page into tx table
PROCEDURE process_save_update_details(
           p_item_type              in wf_items.item_type%type
          ,p_item_key               in wf_items.item_key%type
          ,p_actid                  in varchar2
          ,p_person_id                in number
          ,p_proficiency_level_id   in number default null
          ,p_step_value             in number default null
          ,p_eff_date_from          in varchar2 default null
          ,p_prev_step_value        in number default null
          ,p_competence_status      IN VARCHAR2 DEFAULT null
          ,transaction_step_id      in number );
-- to save the date on the update details page into tx table
procedure save_update_details(
           p_item_type            in varchar2
          ,p_item_key             in varchar2
          ,p_activity_id          in varchar2
          ,p_pid                  in number
          ,p_competence_id        in number
          ,p_competence_element_id in number default null
          ,p_proficiency_level_id in number   default null
          ,p_eff_date_from        in varchar2 default null
          ,p_comments             in varchar2 default null
          ,p_eff_date_to          in varchar2 default null
          ,p_proficy_lvl_source   in varchar2 default null
          ,p_certification_mthd   in varchar2 default null
          ,p_certification_date   in varchar2 default null
          ,p_next_certifctn_date  in varchar2 default null
          ,p_preupd_obj_vers_num  in number   default null
          ,p_transaction_step_id  in number
          ,p_prev_eff_date_from   in varchar2 default null
          ,p_pre_eff_date_to      in varchar2 default null
          ,p_competence_status    in varchar2 default null  -- Competence Qualification Enhancement
          ,p_error_message        out nocopy long);

--
procedure get_comp_name_alias(
           p_competence_name   in out nocopy varchar2
          ,p_competence_alias  in out nocopy varchar2
          ,p_competence_id     out nocopy varchar2
          ,p_business_group_id in  varchar2) ;
--
procedure set_name_alias(
           p_competence_id   in varchar2 default null
          ,l_competence_name   out nocopy varchar2
          ,l_competence_alias  out nocopy varchar2) ;
--
PROCEDURE write_add_transaction(
           p_item_type             in varchar2 default null
          ,p_item_key              in varchar2 default null
          ,p_activity_id           in varchar2 default null
          ,p_pid                   in varchar2 default null
          ,p_competence_id         in varchar2 default null
          ,p_competence_name       in varchar2 default null
          ,p_competence_alias      in varchar2 default null
          ,p_proficiency_level_id  in varchar2 default null
          ,p_step_value            in varchar2 default null
          ,p_eff_date_from         in varchar2 default null
          ,p_change_mode           in varchar2 default null
          ,p_row_index             in number default null
          ,p_transaction_step_id   in out nocopy varchar2
          ,p_competence_status     IN VARCHAR2 DEFAULT NULL ) ;-- Competence Qualification link
--
Procedure get_pending_addition_ids(
           p_item_type IN varchar2
          ,p_item_key  IN varchar2
          ,p_step_values  out nocopy varchar2
          ,p_rows         out nocopy number);

procedure validate_updated_row
          (p_competence_id    in varchar2
          ,p_step_value       in varchar2
          ,p_person_id        in varchar2
          ,p_eff_date_from    in varchar2 default null
          ,r_step_value       out nocopy varchar2
          ,r_new_prof_level   out nocopy varchar2
          ,p_item_type        in varchar2 default null
          ,p_item_key         in varchar2 default null
          ,p_activity_id      in varchar2 default null
          ,p_error_message    out nocopy varchar2);
--
procedure get_lov_comp_id(
           p_competence_name   in varchar2 default null
          ,p_competence_alias  in varchar2 default null
          ,l_competence_id     out nocopy varchar2);
--
procedure set_parameters(
          p_competence_id        in out nocopy varchar2
         ,p_competence_name      in out nocopy varchar2
         ,p_competence_alias     in out nocopy varchar2
         ,p_step_value           in out nocopy varchar2
         ,p_prof_level_id        in out nocopy varchar2
         ,p_business_group_id    in varchar2
         -- bug 2946360 fix
         ,p_item_type            in varchar2 default null
         ,p_item_key             in varchar2 default null
         ,p_person_id            in number default null
         ,p_dup_comp_not_exists  out nocopy varchar2
         -- bug 2946360 fix
         -- bug fix 4136402
         ,p_eff_date_from          in varchar2 default null
         ,p_eff_date_to            in varchar2 default null
         ,p_activity_id            in varchar2 default null
         -- bug fix 4136402
         ,p_error_message        out nocopy long);
--
procedure set_upd_parameters(
          p_competence_id         in varchar2 default null
          ,p_step_value           in varchar2 default null);
--
Procedure delete_add_page(
           transaction_step_ids in varchar2);
--
procedure add_to_addition(p_item_type in varchar2
                         ,p_item_key  in varchar2);
--
procedure update_date_validate(
           p_person_id in varchar2 default null
          ,p_competence_id in varchar2 default null
          ,p_eff_date_from in varchar2 default null
          ,p_error_message out nocopy varchar2) ;
--
procedure ex_comp_date_validation(
           p_person_id         in varchar2
          ,p_competence_id    in varchar2
          ,p_eff_date_from    in varchar2) ;
--
Procedure write_proc_actid(
           p_item_type          in varchar2
          ,p_item_key           in varchar2
          ,p_activity_id        in varchar2
          ,p_person_id          in varchar2
          ,p_review_proc_call   in varchar2);
--
Procedure get_correction_trans_values(
           p_item_type             in varchar2
          ,p_item_key              in varchar2
          ,p_competence_element_id in number
          ,p_proficiency_level_id  out nocopy number
          ,p_start_date            out nocopy date
          ,p_end_date              out nocopy date
          ,p_justification         out nocopy varchar2
          ,p_acquired_by           out nocopy varchar2
          ,p_measured_by           out nocopy varchar2
          ,p_ceritification_date   out nocopy varchar2
          ,p_next_review_date      out nocopy varchar2);
--
PROCEDURE final_update_save(
           p_item_type            in varchar2
          ,p_item_key             in varchar2
          ,p_activity_id          in varchar2
          ,p_competence_element_id in number default null
          ,p_pid                  in number
          ,p_proficiency_level_id in number default null
          ,p_eff_date_from        in varchar2 default null
          ,p_step_value           in number
          ,p_transaction_step_id    in number
          ,p_competence_status   IN varchar2);
--
Function get_preferred_prof_range(
     p_person_id     in varchar2
    ,p_competence_id in number) Return VARCHAR2;
--
Function is_proficiency_required
    (p_person_id     in varchar2
    ,p_competence_id in number) Return VARCHAR2;
--
function get_party_id
  (p_person_id   in number,
   p_business_group_id in number
   ) return number;
--
End hr_comp_profile_ss;

/
