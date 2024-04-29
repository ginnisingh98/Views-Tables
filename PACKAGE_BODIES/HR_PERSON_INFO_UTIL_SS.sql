--------------------------------------------------------
--  DDL for Package Body HR_PERSON_INFO_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_INFO_UTIL_SS" AS
/* $Header: hrperuts.pkb 120.1.12000000.2 2007/04/09 14:33:51 dbatra ship $*/

-- Global variables
  g_package               constant varchar2(75):='HR_PERSON_INFO_UTIL_SS.';
  g_data_error            exception;
  g_flex_struct hr_dflex_utility.l_ignore_dfcode_varray :=  hr_dflex_utility.l_ignore_dfcode_varray(); -- 4644909
--
-- ---------------------------------------------------------------------------
-- --------------------- < check_pending_approval_items> ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will check whether there are any pending approval
--          items in workflow for a given process name and process section
--          name.  If the p_process_name parameter is passed in, then this
--          procedure will be searching for Personal Information pending
--          approval items.  This procedure returns three output parameters.
--
--
-- Input Parameters:
--   p_item_type - required.
--   p_process_name - required.  It is the process name coded in the FND Form
--                    function parameters.
--   p_api_name      - This api_name in conjunction with the p_item_type and
--                     p_item_key parameters will uniquely identify the
--                     activity_id which was used to save recs to the trans
--                     table.
--   p_result_code - This result code is used in collaboration with the derived
--                   activity_id to check for pending approval items.
--                   If it is null,it will be defaulted to 'SUBMIT_FOR_APPROVAL'
--                   result code.
--
--   p_current_person_id - the person_id for whom the action is to be performed.
--
--   p_address_context - this is used by Address section in the Personal
--                       Information Overview page.  Since primary and secondary
--                       address use the same api name, we need this parameter
--                       to indicate further filtering by transaction values for
--                       "P_PRIMARY_FLAG" equals to "Y" or "N".
--                       Valid values are "PRIMARY" or "SECONDARY".
--
--  Output Parameters:
--   1) p_multiple_item_keys - this parameter will have a value only if p_trans_rec_count >1.
--                             If not it is null.
--   2) p_pending_item_key - this parameter will return the pending item key value.
--
-- Inovked by: Java code.
-- ---------------------------------------------------------------------------
PROCEDURE check_pending_approval_items (
    p_item_type                       in  varchar2
   ,p_process_name                    in  varchar2
   ,p_api_name                        in  varchar2
   ,p_result_code                     in  varchar2 default null
   ,p_current_person_id               in  number
   ,p_address_context                 in  varchar2 default null
   ,p_multiple_item_keys              out nocopy varchar2
   ,p_pending_item_key                out nocopy varchar2
)is

  ln_trans_rec_count       number default 0;
  ln_count                 number default 0;
  ln_trans_step_id         number default null;
  ln_trans_obj_vers_num    hr_api_transaction_steps.object_version_number%type
                           default null;
  ltt_active_wf_items      hr_workflow_service.active_wf_trans_items_list;
  ltt_trans_step_ids       hr_util_web.g_varchar2_tab_type;
  ltt_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
  ln_trans_step_rows       NUMBER  ;
  lv_multiple_trans_step_ids varchar2(32000) default null;
  lv_trans_step_ids          varchar2(32000) default null;
  ln_actid                 wf_item_attribute_values.number_value%type
                           default null;
  ln_total_count           number  default 0;
  ln_index                 number  default 0;
-- vbala 01/11
  lv_item_key              varchar2(240)   default null;
  lv_multiple_item_keys    varchar2(32000) default null;
  lv_redirect_item_key     varchar2(240)   default null;
-- vbala 01/11
  l_address_context        varchar2(800)  default null;
  l_api_name               varchar2(1000) default null;
  l_process_section        varchar2(500) default null;
  l_section_context        varchar2(400)  default null;


BEGIN
  --
  -- ------------------------------------------------------------------
  -- Check if there are any transactions waiting to be approved.
  ---------------------------------------------------------------------------
  -- 1) Find all item keys which have a status of "ACTIVE" for p_process_name
  --    and the result code is the result code passed in or the default
  --    'SUBMIT_FOR_APPROVAL' result code.
  -- 2) Return the count in p_trans_rec_count and p_multiple_trans_step_ids if
  --    there is multiple transactions steps found. Otherwise,if there is only
  --    1 transaction step, return the value in p_trans_step_id output parm.
  --    There can be defunct workflow processes.  Therefore, we must
  --    match active processes with transaction tables.
  ---------------------------------------------------------------------------
  --
  -- The following function will return a PL/SQL table which has following
  -- fields : Item Key, Activity ID, Result Code
  --
  l_api_name  := p_api_name;
  l_address_context := p_address_context;

  WHILE (instr(l_api_name, '|') <> 0) LOOP
      l_process_section :=  substr(l_api_name, 1, instr(l_api_name, '|')-1);
      l_section_context :=  substr(l_address_context, 1, instr(l_address_context, '|')-1);
      lv_multiple_item_keys := 'null';
      lv_redirect_item_key  := 'null';

      IF (l_section_context = 'null') THEN
         l_section_context := null;
      END IF;
      IF (l_process_section <> 'DISPLAY_OFF') THEN
        ltt_active_wf_items := hr_workflow_service.get_active_wf_items
                          (p_item_type            => p_item_type
                          ,p_process_name         => p_process_name
                          ,p_current_person_id    => p_current_person_id
                          ,p_api_name             => l_process_section
                          ,p_activity_result_code => p_result_code
                          ,p_address_context      => l_section_context
                          );
      END IF;
      l_api_name := substr(l_api_name, instr(l_api_name, '|')+1);
      l_address_context := substr(l_address_context, instr(l_address_context, '|')+1);
      ln_count := ltt_active_wf_items.count;
      IF ln_count > 0
      THEN
        IF ln_count = 1
        THEN
-- vbala 01/11
           lv_multiple_item_keys := null;
           lv_item_key := ltt_active_wf_items(1).active_item_key;
           lv_redirect_item_key := ltt_active_wf_items(1).active_item_key;
-- vbala 01/11
        ELSE
          FOR j in 1..ln_count
          LOOP
-- vbala 01/11
            lv_multiple_item_keys := lv_trans_step_ids ||
                                 ltt_active_wf_items(j).active_item_key || ',';
-- vbala 01/11
            ln_total_count := ln_total_count + 1;
          END LOOP;
        --
        -- now remove the last comma
-- vbala 01/11
           lv_multiple_item_keys := rtrim(lv_multiple_item_keys, ',');
           lv_item_key := null;
           lv_redirect_item_key := ltt_active_wf_items(1).active_item_key;
-- vbala 01/11
        END IF;
      END IF;
     --
-- vbala 01/11
      p_multiple_item_keys := p_multiple_item_keys||lv_multiple_item_keys||'|';
      p_pending_item_key := p_pending_item_key||lv_redirect_item_key||'|';
-- vbala 01/11
  END LOOP;

END check_pending_approval_items;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< process_action >----------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will be called from the overview page, which will route
--          for the process section (e.g:- BASIC_DETAILS or MAIN_ADDRESS) to either
--          type of change or update page, depending on the link on the overview page.
--
-- Parameters:
--   Input
--   p_item_type - required. It is the item type for the workflow process.
--   p_item_key  - required.  It is the item key for the workflow process.
--   p_actid  - required. It is the item key for the workflow process.
--   p_funcmode  - required.  It is the func mode for the workflow process.

--  Output Parameters:
--   1) p_resultout - will populate the result code for the activity
-- --------------------------------------------------------------------------
PROCEDURE process_action
  (p_item_type   in   varchar2
  ,p_item_key    in   varchar2
  ,p_actid       in   number
  ,p_funcmode    in   varchar2
  ,p_resultout   out nocopy  varchar2) is
--
 lv_perinfo_process_section   varchar2(50);
 lv_perinfo_action_type       varchar2(50);
 lv_trans_submit              varchar2(20);

 ln_transaction_id            number;

begin

 -- get the itemattr TRAN_SUBMIT
  lv_trans_submit := wf_engine.GetItemAttrText(itemtype  => p_item_type,
                            itemkey   => p_item_key,
                            aname    => 'TRAN_SUBMIT');

 -- Delete the transaction only if not from RETURN FOR CORRECTION
 if (p_funcmode = 'RUN') AND (lv_trans_submit <> 'C') then

 -- 22-May-2003: Bug 2967944: NS: Fetching transactionId from Hr_api_transactions
 -- as new transaction are already deleted when cancel is pressed on any page (with V5 changes).
 -- but WF attribute still exists, thus the api call to rollback fails with the following error
 -- "ORA-20001: The primary key specified is invalid"

 -- Clear the transaction before proceeding further, as this is required to support
 -- the browser back button.
    ln_transaction_id  :=  pqh_ss_workflow.get_transaction_id(
                                         p_itemtype => p_item_type
                                        ,p_itemkey  => p_item_key );
    IF (ln_transaction_id is not null)  THEN
          hr_transaction_api.rollback_transaction(
                 p_transaction_id => ln_transaction_id);
    END IF;

/*  hr_transaction_web.rollback_transaction(itemtype => p_item_type
                                          ,itemkey => p_item_key
                                          ,actid  => p_actid
                                          ,funmode => p_funcmode
                                          ,result => p_resultout ); */

-- also we need to nullify item attribute 'TRANSACTION_ID' in work flow engine
   wf_engine.SetItemAttrText(itemtype  => p_item_type,
                            itemkey   => p_item_key,
                             aname    => 'TRANSACTION_ID',
                             avalue   => null);

 end if;
 -- set the result to DEFAULT: to stall the workflow engine
    p_resultout := 'DEFAULT';

  lv_perinfo_process_section := wf_engine.GetItemAttrText(itemtype  => p_item_type,
                                                          itemkey   => p_item_key,
                                  aname     => gv_wf_process_sect_attr_name);
  lv_perinfo_action_type     := wf_engine.GetItemAttrText(itemtype  => p_item_type,
                                                          itemkey   => p_item_key,
                                  aname     => gv_wf_action_type_attr_name);

  if(lv_perinfo_process_section = gv_basic_details_sect) then
     if (lv_perinfo_action_type = gv_update_attr_value) then
        p_resultout := gv_update_basic_details_value;
     elsif (lv_perinfo_action_type = gv_view_future_changes_value or
            lv_perinfo_action_type = gv_view_pending_approval_value) then
        p_resultout := gv_view_basic_details_value;
     end if;
  end if;

  if(lv_perinfo_process_section = gv_main_address_sect) then
     if (lv_perinfo_action_type = gv_update_attr_value) then
        p_resultout := gv_update_main_address_value;
     elsif (lv_perinfo_action_type = gv_add_attr_value) then
        p_resultout := gv_add_main_address_value;
     elsif (lv_perinfo_action_type = gv_view_future_changes_value or
            lv_perinfo_action_type = gv_view_pending_approval_value) then
        p_resultout := gv_view_main_address_value;
     end if;
  end if;

  if(lv_perinfo_process_section = gv_secondary_address_sect) then
      if (lv_perinfo_action_type = gv_update_attr_value) then
        p_resultout := gv_update_second_address_value;
     elsif (lv_perinfo_action_type = gv_add_attr_value) then
        p_resultout := gv_add_second_address_value;
     elsif (lv_perinfo_action_type = gv_view_future_changes_value or
            lv_perinfo_action_type = gv_view_pending_approval_value) then
        p_resultout := gv_view_second_address_value;
     end if;
  end if;

  --
  -- PB : For conatcts module
  --
  if(lv_perinfo_process_section = gv_contacts_sect) then
      if (lv_perinfo_action_type = gv_add_upd_attr_value) then
        p_resultout := gv_add_upd_contacts_value;
     elsif (lv_perinfo_action_type = gv_del_attr_value) then
        p_resultout := gv_del_contacts_value;
     end if;
  end if;
  return;

 if p_funcmode = 'CANCEL' then
    p_resultout := 'COMPLETE:';
    return;
 end if;
exception
  when others then
    wf_core.Context
      (g_package, 'process_action', p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;
END process_action;

-- ----------------------------------------------------------------------------
-- |-------------------------------< is_duplicate_person >-----------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure can be used to check if there are any duplicate persons
--          this will internally call hr_generl2.is_duplicate_person function.
--
-- Parameters:
--   Input
--   p_first_name - required.
--   p_last_name  - required.
--   p_national_identifier  - required.
--   p_date_of_birth  - required.

--  Output Parameters:
--   1) p_resultout - will have a value of 0 for flase
--                                         1 for true
-- ---------------------------------------------------------------------------

PROCEDURE is_duplicate_person
  (p_first_name                  in  varchar2
  ,p_last_name                   in  varchar2
  ,p_national_identifier         in  varchar2
  ,p_date_of_birth               in  date
  ,p_effective_date              in  date
  ,p_resultout                   out nocopy number
) is


 isDuplicate                     boolean := false;
 l_session_date DATE;
 l_full_name VARCHAR2(240);
 l_duplicate_flag VARCHAR2(4);

BEGIN

-- Get the session date
BEGIN
  SELECT se.effective_date
  INTO   l_session_date
  FROM   fnd_sessions se
  WHERE  se.session_id =USERENV('sessionid');
EXCEPTION
WHEN NO_DATA_FOUND THEN
-- insert the effective date into session to be used
-- by is_duplicate_person
 IF(l_session_date is null) THEN
   hr_utility.fnd_insert(p_effective_date);
 END IF;
END;

-- Bug Fix : 2948405.
if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
  hr_person.derive_full_name(p_first_name    => p_first_name,
                             p_middle_names  => null,
                             p_last_name     => p_last_name,
                             p_known_as      => null,
                             p_title         => null,
                             p_suffix        => null,
                             p_pre_name_adjunct => null,
                             p_date_of_birth => p_date_of_birth,
                             p_person_id         => null,
                             p_business_group_id => fnd_global.per_business_group_id,
                             p_full_name => l_full_name,
                             p_duplicate_flag => l_duplicate_flag );

  if l_duplicate_flag = 'Y' then
  isDuplicate := true;
  end if;

 else

 isDuplicate := hr_general2.is_duplicate_person(p_first_name,
                                                p_last_name,
                                                p_national_identifier,
                                                p_date_of_birth);

 end if;

-- call the hr_java_conv_util_ss to get the number out of boolean
-- to be passed to java

p_resultout := hr_java_conv_util_ss.get_number(isDuplicate);

EXCEPTION
  WHEN OTHERS THEN
    raise;

END is_duplicate_person;

--
--
-- Fix 2091186 Start
-- ----------------------------------------------------------------------------
-- |--------------------< create_ignore_df_validation >-----------------------|
-- ----------------------------------------------------------------------------
-- Purpose: To add descriptive flex field to ignorable list.
-- Parameters:
--   Input
--   p_flex_name - required.
-- ----------------------------------------------------------------------------

PROCEDURE create_ignore_df_validation
( p_flex_name varchar2
) IS

l_flex_code varchar2(40) := NULL;
-- l_add_struct hr_dflex_utility.l_ignore_dfcode_varray :=  hr_dflex_utility.l_ignore_dfcode_varray();  --4644909

BEGIN
     g_flex_struct.extend(1);
     g_flex_struct(g_flex_struct.count) := p_flex_name;

/*     l_add_struct.extend(1);
     l_add_struct(l_add_struct.count) := p_flex_name; */ -- 4644909
     --
     hr_dflex_utility.create_ignore_df_validation(p_rec => g_flex_struct);

END create_ignore_df_validation;
--
-- ----------------------------------------------------------------------------
-- |--------------------< remove_ignore_df_validation >-----------------------|
-- ----------------------------------------------------------------------------
-- Purpose: To remove descriptive flex field validation.
-- Parameters:
--   Input
--   none.
-- ----------------------------------------------------------------------------

PROCEDURE remove_ignore_df_validation
IS

BEGIN
g_flex_struct.delete; -- 4644909
hr_dflex_utility.remove_ignore_df_validation;
END remove_ignore_df_validation;
--
-- Fix 2091186 End

-- |--------------------< get_trns_employee_number >-----------------------|
-- ----------------------------------------------------------------------------
-- Purpose: To get the employee number stored in the basic details step. This
-- procedure will be called from assignment and supervisor wrappers to get the
-- employee number while hiring an applicant.
-- Parameters:
--   Input
--   none.
-- ----------------------------------------------------------------------------

PROCEDURE get_trns_employee_number
( p_item_type varchar2
 ,p_item_key  varchar2
 ,p_employee_number out nocopy varchar2
)IS

  l_api_names            hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows                  NUMBER  ;
  l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
  l_transaction_step_id
         hr_api_transaction_steps.transaction_step_id%type default null;
  l_employee_number                   varchar2(30) default null;

BEGIN

 hr_transaction_api.get_transaction_step_info
     (p_item_type              => p_item_type
     ,p_item_key               => p_item_key
     ,p_transaction_step_id    => l_trans_step_ids
     ,p_api_name               => l_api_names
     ,p_rows                   => l_trans_step_rows);
  --

 FOR i in 0..l_trans_step_rows-1 LOOP
   IF(l_api_names(i) = 'HR_PROCESS_PERSON_SS.PROCESS_API') THEN
      l_transaction_step_id := l_trans_step_ids(i);
   END IF;
 END LOOP;

  l_employee_number := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => l_transaction_step_id
                          ,p_name => 'P_EMPLOYEE_NUMBER');

  p_employee_number := l_employee_number;


END get_trns_employee_number;
--

procedure check_ni_unique(
p_national_identifier          in        varchar2    default null
,p_business_group_id           in        number
,p_person_id                   in        number
,p_ni_duplicate_warn_or_err    out nocopy       varchar2) is

 l_warning                           boolean default false;
 l_warning_or_error                  varchar2(20);

begin

  hr_utility.clear_message();
  hr_utility.clear_warning();

  l_warning_or_error := fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING');
  if l_warning_or_error is null then
    l_warning_or_error:= 'WARNING';
  end if;

  if p_national_identifier is not null then

      hr_ni_chk_pkg.check_ni_unique(p_national_identifier => p_national_identifier
                                   ,p_person_id => p_person_id
                                   ,p_business_group_id => p_business_group_id
                                   ,p_raise_error_or_warning => l_warning_or_error);


  l_warning := hr_utility.check_warning();
   if l_warning then
    p_ni_duplicate_warn_or_err := 'WARNING';
   else
    p_ni_duplicate_warn_or_err := 'NONE';
   end if;
  end if;

  exception
   when others then
  if not l_warning then
    p_ni_duplicate_warn_or_err := 'ERROR';
    raise;
  end if;
end check_ni_unique;
--

procedure validate_national_identifier(
  p_national_identifier    VARCHAR2,
  p_birth_date             DATE,
  p_gender                 VARCHAR2,
  p_event                  VARCHAR2 default 'WHEN-VALIDATE-RECORD',
  p_person_id              NUMBER,
  p_business_group_id      NUMBER,
  p_legislation_code       VARCHAR2,
  p_effective_date         DATE,
  p_warning            OUT NOCOPY VARCHAR2,
  p_person_type_id         NUMBER default NULL,
  p_region_of_birth         VARCHAR2 default NULL,
  p_country_of_birth        VARCHAR2 default NULL) IS

 l_warning                           boolean default false;
 l_out_warning                       varchar2(20);
 l_out_ni                            per_all_people_f.national_identifier%type;
begin

 if p_national_identifier is not null then

   l_out_ni :=  hr_ni_chk_pkg.validate_national_identifier(
                                    p_national_identifier => p_national_identifier
                                   ,p_birth_date => p_birth_date
                                   ,p_gender => p_gender
                                   ,p_person_id => p_person_id
                                   ,p_business_group_id => p_business_group_id
                                   ,p_legislation_code => p_legislation_code
                                   ,p_session_date => p_effective_date
                                   ,p_warning => l_out_warning
                                   ,p_person_type_id => p_person_type_id
                                   ,p_region_of_birth => p_region_of_birth
                                   ,p_country_of_birth => p_country_of_birth);

  l_warning := l_out_warning = 'Y';
   if l_warning then
    p_warning := 'WARNING';
   else
    p_warning := 'NONE';
   end if;
  end if;

 exception
   when others then
  if not l_warning then
    p_warning := 'ERROR';
    raise;
  end if;


end validate_national_identifier;


END hr_person_info_util_ss;
--

/
