--------------------------------------------------------
--  DDL for Package HR_WORKFLOW_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WORKFLOW_SERVICE" AUTHID CURRENT_USER as
/* $Header: hrwfserv.pkh 120.1 2005/09/23 16:08:20 svittal noship $ */
  --
  g_hr_activity_type           varchar2(30) := 'HR_ACTIVITY_TYPE';
  g_hr_activity_type_value     varchar2(30) := 'HR_ACTIVITY_TYPE_VALUE';
  g_hr_web_page_code           varchar2(4)  := 'HTML';
  g_window_title               varchar2(30) := 'WINDOW_TITLE';
  g_wf_root_process            varchar2(4)  := 'ROOT';
  g_wf_root_process_active     varchar2(6)  := 'ACTIVE';
  g_wf_function                varchar2(8)  := 'FUNCTION';
  g_wf_activity_notified       varchar2(8)  := 'NOTIFIED';
  g_token_tickler              varchar2(18) := '$$TICKLER_VALUE$$';
  g_tickler_unordered          varchar2(9)  := 'UNORDERED';
  g_tickler_ascending          varchar2(9)  := 'ASCENDING';
  g_tickler_descending         varchar2(10) := 'DESCENDING';
  --
  g_invalid_responsibility EXCEPTION;
  TYPE g_varchar2_tab_type IS TABLE OF varchar2(2000) INDEX BY BINARY_INTEGER;
  g_varchar2_tab_default g_varchar2_tab_type;
  --
  TYPE active_wf_items_rec IS RECORD (
        active_item_key      wf_items.item_key%type,
        activity_result_code wf_item_activity_statuses_v.activity_result_code%type,
        activity_id          wf_item_activity_statuses_v.activity_id%type
   );
  --
  TYPE active_wf_items_list IS TABLE OF active_wf_items_rec  INDEX BY BINARY_INTEGER;
  --
  TYPE active_wf_trans_items_rec   IS RECORD (
        active_item_key      wf_items.item_key%type
       ,activity_id          wf_item_activity_statuses_v.activity_id%type
       ,trans_step_id        hr_api_transaction_steps.transaction_step_id %type
       ,activity_result_code
                   wf_item_activity_statuses_v.activity_result_code%type
   );
  --
  TYPE active_wf_trans_items_list IS TABLE OF active_wf_trans_items_rec
                                  INDEX BY BINARY_INTEGER;
  --

-- ----------------------------------------------------------------------------
-- |--------------------< check_usernm_exists_subj_aprv >---------------------|
-- ----------------------------------------------------------------------------
-- Bug #788954 Fix: This procedure is used in workflow Approved Process.  This
--                  function is invoked to check that if the subject-of-approval
--                  person has an apps login username.  If not, then workflow
--                  will not send out a notification to the subject person.
-- ----------------------------------------------------------------------------
PROCEDURE check_usernm_exists_subj_aprv
  (itemtype     IN VARCHAR2
  ,itemkey      IN VARCHAR2
  ,actid        IN NUMBER
  ,funcmode     IN VARCHAR2
  ,resultout    OUT NOCOPY VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_hr_directory_services >------------------|
-- ----------------------------------------------------------------------------
procedure create_hr_directory_services
  (p_item_type         in wf_items.item_type%type
  ,p_item_key          in wf_items.item_key%type
  ,p_service_name      in varchar2
  ,p_service_person_id in per_all_people_f.person_id%type);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_item_attr_expanded_info >------------------|
-- ----------------------------------------------------------------------------
procedure get_item_attr_expanded_info
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_name      in       wf_item_attributes.name%type
  ,p_exists         out nocopy boolean
  ,p_subtype        out nocopy wf_item_attributes.subtype%type
  ,p_type           out nocopy wf_item_attributes.type%type
  ,p_format         out nocopy wf_item_attributes.format%type
  ,p_date_value     out nocopy wf_item_attribute_values.date_value%type
  ,p_number_value   out nocopy wf_item_attribute_values.number_value%type
  ,p_text_value     out nocopy wf_item_attribute_values.text_value%type);
-- ----------------------------------------------------------------------------
-- |-------------------------< get_act_attr_expanded_info >------------------|
-- ----------------------------------------------------------------------------
procedure get_act_attr_expanded_info
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_actid     in       wf_activity_attr_values.process_activity_id%type
  ,p_name      in       wf_activity_attributes.name%type
  ,p_exists         out nocopy boolean
  ,p_subtype        out nocopy wf_activity_attributes.subtype%type
  ,p_type           out nocopy wf_activity_attributes.type%type
  ,p_format         out nocopy wf_activity_attributes.format%type
  ,p_date_value     out nocopy wf_activity_attr_values.date_value%type
  ,p_number_value   out nocopy wf_activity_attr_values.number_value%type
  ,p_text_value     out nocopy wf_activity_attr_values.text_value%type);
-- ----------------------------------------------------------------------------
-- |-------------------------< check_activity_type_attrs >--------------------|
-- ----------------------------------------------------------------------------
procedure check_activity_type_attrs
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_actid     in wf_activity_attr_values.process_activity_id%type);
-- ----------------------------------------------------------------------------
-- |-------------------------------< hr_web_page >----------------------------|
-- ----------------------------------------------------------------------------
procedure hr_web_page
  (itemtype   in     varchar2
  ,itemkey    in     varchar2
  ,actid      in     number
  ,funcmode   in     varchar2
  ,resultout     out nocopy varchar2);
-- ----------------------------------------------------------------------------
-- |-------------------------< check_hr_window_title >------------------------|
-- ----------------------------------------------------------------------------
function check_hr_window_title
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_actid     in wf_activity_attr_values.process_activity_id%type)
  return boolean;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_hr_window_title >------------------------|
-- ----------------------------------------------------------------------------
function get_hr_window_title
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type
  ,p_actid     in wf_activity_attr_values.process_activity_id%type)
  return varchar2;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_web_page_code >--------------------------|
-- ----------------------------------------------------------------------------
function check_web_page_code
  (p_item_type             in wf_items.item_type%type
  ,p_item_key              in wf_items.item_key%type
  ,p_actid                 in wf_activity_attr_values.process_activity_id%type
  ,p_web_page_section_code in wf_activity_attributes.name%type)
  return boolean;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_web_page_code >------------------------|
-- ----------------------------------------------------------------------------
function get_web_page_code
  (p_item_type             in wf_items.item_type%type
  ,p_item_key              in wf_items.item_key%type
  ,p_actid                 in wf_activity_attr_values.process_activity_id%type
  ,p_web_page_section_code in wf_activity_attributes.name%type)
  return varchar2;
-- ----------------------------------------------------------------------------
-- |-------------------------< check_activity_reentry >-----------------------|
-- ----------------------------------------------------------------------------
function check_activity_reentry
  (p_item_type in wf_items.item_type%type
  ,p_item_key  in wf_items.item_key%type
  ,p_actid     in wf_activity_attr_values.process_activity_id%type)
  return boolean;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_activity_reentry_value >-------------------|
-- ----------------------------------------------------------------------------
function get_activity_reentry_value
  (p_item_type in wf_items.item_type%type
  ,p_item_key  in wf_items.item_key%type
  ,p_actid     in wf_activity_attr_values.process_activity_id%type)
  return wf_item_activity_statuses_v.activity_result_code%type;
-- ----------------------------------------------------------------------------
-- |------------------------------< create_process >--------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure is overloaded so that it will accept p_person_id
--          and p_called_from as parameters.
-- ----------------------------------------------------------------------------
procedure create_process
  (p_process_name            in wf_process_activities.process_name%type
  ,p_item_type               in wf_items.item_type%type
  ,p_person_id               in varchar2 default null
  ,p_called_from             in varchar2 default null
  ,p_item_attribute          in g_varchar2_tab_type
                                default g_varchar2_tab_default
  ,p_item_attribute_value    in g_varchar2_tab_type
                                default g_varchar2_tab_default
  ,p_number_of_attributes_in in number default 0);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< continue_process >---------------------------|
-- ----------------------------------------------------------------------------
procedure continue_process
  (p_item_type in       wf_items.item_type%type
  ,p_item_key  in       wf_items.item_key%type);
-- ----------------------------------------------------------------------------
-- |------------------------< transition_activity >---------------------------|
-- ----------------------------------------------------------------------------
procedure transition_activity
  (p_item_type   in wf_items.item_type%type
  ,p_item_key    in wf_items.item_key%type
  ,p_actid       in wf_activity_attr_values.process_activity_id%type
  ,p_result_code in wf_item_activity_statuses_v.activity_result_code%type);
-- ----------------------------------------------------------------------------
-- |-------------------------<  check_active_wf_items >-- ---------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This function is overloaded.  It will only return the pending
--          approval workflow items for a section of a page, ie. by
--          activity_result_code to a table.
-- ----------------------------------------------------------------------------
function check_active_wf_items
  (p_item_type             in wf_items.item_type%type
  ,p_process_name          in wf_process_activities.process_name%type
  ,p_current_person_id     in per_people_f.person_id%type
  ,p_activity_name         in wf_item_activity_statuses_v.activity_name%type
  ,p_activity_result_code  in varchar2
  )
  return active_wf_items_list;
--
--
function check_active_wf_items
  (p_item_type             in wf_items.item_type%type
  ,p_process_name          in wf_process_activities.process_name%type
  ,p_current_person_id     in per_people_f.person_id%type
  ,p_activity_name         in wf_item_activity_statuses_v.activity_name%type
  )
  return active_wf_items_list;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_active_wf_items >-------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This function will return all the pending approval workflow items
--          for a page for a given item_type, item_key and the api_name.  If a
--          page has many sections, the caller can pass the result code to
--          find out if a particular section has active pending approval
--          items by comparing the activity result code.
--          This function is designed specifically for use in Personal
--          Information to look for pending approval items which contain an
--          acitivity with a specific result code equals to the input parameter.
--          For Address Section in Personal Information, it needs to pass
--          a value of either "PRIMARY" or "SECONDARY" in the parameter
--          p_address_context because Primary Address and Secondary Address
--          share the same api name, which is hr_process_address_ss.
-- ----------------------------------------------------------------------------
FUNCTION get_active_wf_items
  (p_item_type             in wf_items.item_type%type
  ,p_process_name          in wf_process_activities.process_name%type
  ,p_current_person_id     in per_people_f.person_id%type
  ,p_api_name              in hr_api_transaction_steps.api_name%type
  ,p_activity_result_code  in varchar2  default null
  ,p_address_context       in varchar2  default null
  )
  return active_wf_trans_items_list;

--
procedure remove_defunct_process
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2);
--
/*procedure start_cleanup_process
  (p_process_name            in wf_process_activities.process_name%type
  ,p_item_type               in wf_items.item_type%type
  );
*/

procedure start_cleanup_process(
                 p_item_type               in wf_items.item_type%type
                ,p_transaction_age         in wf_item_attribute_values.number_value%type
                ,p_process_name            in wf_process_activities.process_name%type default 'HR_BACKGROUND_CLEANUP_PRC',
  p_transaction_status in varchar2 default 'ALL'
  ) ;
--


-- Block
--   Stop and wait for external completion
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - NOTIFIED
procedure Block(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2);


--
--
-- TotalConcurrent
--   Concurrent Program version
-- IN:
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   itemtype - Item type to delete, or null for all itemtypes
--   age - Minimum age of data to purge (in days)
procedure TotalConcurrent(
  errbuf out nocopy varchar2,
  retcode out nocopy varchar2,
  itemtype in varchar2 default null,
  age in varchar2 default '0',
  p_process_name in varchar2 default 'HR_BACKGROUND_CLEANUP_PRC',
  transaction_status in varchar2 default 'ALL');

--
function getItemType(p_transaction_id in hr_api_transactions.transaction_id%type)
  return wf_items.item_type%type;

function getItemKey(p_transaction_id in hr_api_transactions.transaction_id%type)
  return wf_items.item_key%type;

function item_attribute_exists
  (p_item_type in wf_items.item_type%type
  ,p_item_key  in wf_items.item_key%type
  ,p_name      in wf_item_attribute_values.name%type)
  return boolean;

END hr_workflow_service;

 

/
