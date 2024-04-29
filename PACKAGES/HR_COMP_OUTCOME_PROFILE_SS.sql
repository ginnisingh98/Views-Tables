--------------------------------------------------------
--  DDL for Package HR_COMP_OUTCOME_PROFILE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMP_OUTCOME_PROFILE_SS" AUTHID CURRENT_USER AS
/* $Header: hrcorwrs.pkh 120.0 2005/05/30 23:23:14 appldev noship $ */
--
API_NAME CONSTANT VARCHAR(50) := 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API';

OUTCOME_CHANGED constant VARCHAR2(30) := 'OUTCOME_CHANGED';
NEXT              constant  VARCHAR2(10) := 'NEXT';


TYPE transaction_row IS RECORD
        (param_name VARCHAR2(200)
        ,param_value LONG
        ,param_data_type VARCHAR2(200));

TYPE transaction_table1 IS TABLE OF transaction_row INDEX BY BINARY_INTEGER;

g_api_name constant varchar2(50) := 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API';
g_date_format CONSTANT varchar2(15) := 'RRRR-MM-DD';

g_upd_mode                   constant varchar2(30) := 'CORRECT';

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
--          chooses "Update" without approval in workflow. from
--          hr_comp_profile_ss.process_api
-- ---------------------------------------------------------------------------
Procedure process_api(
           p_validate              in boolean  default false
          ,p_transaction_step_id   in number
          ,p_competence_element_id in number
          ,p_effective_date        in varchar2 default null);

Procedure call_process_api (
          p_validate               in boolean  default false
          ,p_competence_element_id IN number
          ,p_new_competence_element_id IN number
          ,p_competence_id         IN number
          ,p_item_type             IN hr_api_transaction_steps.item_type%type
          ,p_item_key              IN hr_api_transaction_steps.item_key%type
          ,p_activity_id           IN hr_api_transaction_steps.ACTIVITY_ID%TYPE
          ,p_person_id             IN NUMBER
          ,p_effective_date        IN date DEFAULT trunc(sysdate));

Procedure api_validate_com_out_rec_ss (
           p_item_type                in varchar2
          ,p_item_key                 in varchar2
          ,p_activity_id              in varchar2
          ,p_validate                 in varchar2
          ,p_change_mode              in varchar2 default null
          ,p_comp_element_outcome_id  in varchar2 default null
          ,p_competence_element_id    in varchar2 default null
          ,p_competence_id            in varchar2 default null
          ,p_preupd_obj_vers_num      in number default null
          ,p_outcome_id               in number default null
          ,p_date_from                in varchar2 default null
          ,p_date_to                  in varchar2 default null
          ,p_transaction_step_id      in out nocopy varchar2
          ,p_comp_from_date           IN VARCHAR2 DEFAULT null
          ,p_comp_to_date             IN VARCHAR2 DEFAULT null
          ,p_person_id                IN VARCHAR2 DEFAULT null
          ,p_error_message            out nocopy long);


PROCEDURE save_transaction_step
                (p_item_type           IN VARCHAR2
                ,p_item_key            IN VARCHAR2
                ,p_actid               IN NUMBER
                ,p_login_person_id     IN NUMBER
                ,p_transaction_step_id IN OUT NOCOPY NUMBER
                ,p_api_name            IN VARCHAR2  default null
                ,p_api_display_name    IN VARCHAR2 DEFAULT NULL
                ,p_transaction_data    IN TRANSACTION_TABLE1);

--
PROCEDURE delete_transaction_step_id
          (p_transaction_step_id IN number);

--

PROCEDURE delete_all_ids
          (p_item_type in varchar2
          ,p_item_key  in varchar2);

--


--
Procedure delete_add_page
          (p_transaction_step_id in number);
--


PROCEDURE mark_for_delete
          (p_item_type                in varchar2
          ,p_item_key                 in varchar2
          ,p_activity_id              in varchar2
          ,p_comp_element_outcome_id  in number
          ,p_transaction_step_id      in varchar2 default null
          ,p_error_message            OUT NOCOPY long);

Procedure check_if_cmptnce_rec_changed
          (p_item_type             IN varchar2
          ,p_item_key              IN varchar2
          ,p_activity_id           IN varchar2
          ,p_pid                   in number
          ,p_competence_element_id in number
          ,p_competence_id         in number
          ,p_rec_changed           out nocopy boolean);

Procedure delete(p_validate            in boolean default false
                     ,p_transaction_step_id in number
                     ,p_effective_date        in varchar2 default null);

Procedure process_api(
           p_validate              in boolean  default false
          ,p_transaction_step_id   in number
          ,p_effective_date        in varchar2 default null);

Procedure del_correct_rec(
           p_item_type             IN varchar2
          ,p_item_key              IN varchar2
          ,p_activity_id           IN varchar2
          ,p_competence_element_id in number);

End hr_comp_outcome_profile_ss;

 

/
