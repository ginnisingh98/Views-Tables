--------------------------------------------------------
--  DDL for Package Body HR_AMEUTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AMEUTIL_SS" AS
/* $Header: hrameutlss.pkb 120.7.12010000.5 2009/08/28 11:13:25 vkodedal ship $ */

-- Package Variables
--
g_package  constant varchar2(14) := 'hr_ameutil_ss.';
g_debug constant boolean := hr_utility.debug_enabled;




-------------------------------------------------------------------------------
---------   function get_item_type  --------------------------------------------

----------  private function to get item type for current transaction ---------
-------------------------------------------------------------------------------
function get_item_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
c_item_type    varchar2(50);

begin

 begin
    if g_debug then
      hr_utility.set_location('querying hr_api_transactions.item_type for p_transaction_id:'||p_transaction_id, 2);
    end if;
    select t.item_type
    into c_item_type
    from hr_api_transactions t
    where transaction_id=get_item_type.p_transaction_id;
  exception
    when no_data_found then
     -- get the data from the steps
     if g_debug then
      hr_utility.set_location('querying hr_api_transaction_steps.item_type for p_transaction_id:'||p_transaction_id, 2);
    end if;
     select ts.item_type
     into get_item_type.c_item_type
     from hr_api_transaction_steps ts
     where ts.transaction_id=get_item_type.p_transaction_id
     and ts.item_type is not null and rownum <=1;
  end;

return c_item_type;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_item_type',p_transaction_id);
    RAISE;

end get_item_type;



-------------------------------------------------------------------------------
---------   function get_item_key  --------------------------------------------
----------  private function to get item key for current transaction ---------
-------------------------------------------------------------------------------

function get_item_key
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
c_item_key    varchar2(50);

begin

 begin
    if g_debug then
      hr_utility.set_location('querying hr_api_transactions.item_type for p_transaction_id:'||p_transaction_id, 2);
    end if;
    select t.item_key
    into get_item_key.c_item_key
    from hr_api_transactions t
    where transaction_id=get_item_key.p_transaction_id;
  exception
    when no_data_found then
     -- get the data from the steps
     if g_debug then
      hr_utility.set_location('querying hr_api_transaction_steps.item_type for p_transaction_id:'||p_transaction_id, 2);
     end if;
     select ts.item_key
     into get_item_key.c_item_key
     from hr_api_transaction_steps ts
     where ts.transaction_id=get_item_key.p_transaction_id
     and ts.item_type is not null and rownum <=1;
  end;

return get_item_key.c_item_key;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_item_key',p_transaction_id);
    RAISE;

end get_item_key;

function get_process_name
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_process_name varchar2(100);
c_item_type    varchar2(50);
c_item_key     varchar2(100);

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key := get_item_key(p_transaction_id);

 select t.process_name
    into get_process_name.c_process_name
    from hr_api_transactions t
    where transaction_id=get_process_name.p_transaction_id;

return c_process_name;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_process_name',c_item_type,c_item_key);
    RAISE;
end get_process_name ;

------------------------------------------------------------------
-- Name: get_transaction_category
-- Desc: Derive the category of transaction
-- Params: transaction_step_id
-- Returns: varchar2
------------------------------------------------------------------
function get_transaction_category (
	p_transaction_step_id IN hr_api_transaction_steps.transaction_step_id%TYPE)
		return varchar2 is

  -- local variables
  lv_procedure_name constant varchar2(24) := 'get_transaction_category';
  l_transaction_category varchar2(50);
  l_category_undefined constant varchar2(5) :='OTHER';

  BEGIN
     hr_utility.set_location(lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with step_id:'||p_transaction_step_id, 2);
    end if;

     BEGIN
	select decode(hats.api_name,
	'BEN_PROCESS_COMPENSATION_W.PROCESS_API','BENEFITS',
	'HR_APPLY_FOR_JOB_APP_WEB.PROCESS_API','BENEFITS',
	'HR_ASSIGNMENT_COMMON_SAVE_WEB.PROCESS_API',l_category_undefined,
	'HR_BASIC_DETAILS_WEB.PROCESS_API',l_category_undefined,
	'HR_CAED_SS.PROCESS_API',l_category_undefined,
	'HR_CCMGR_SS.PROCESS_API',l_category_undefined,
	'HR_COMP_PROFILE_SS.PROCESS_API',l_category_undefined,
	'HR_COMP_REVIEW_WEB_SS.PROCESS_API',l_category_undefined,
	'HR_EMP_ADDRESS_WEB.PROCESS_API',l_category_undefined,
	'HR_EMP_CONTACT_WEB.PROCESS_API',l_category_undefined,
	'HR_EMP_MARITAL_WEB.PROCESS_API',l_category_undefined,
	'HR_LOA_SS.PROCESS_API',l_category_undefined,
	'HR_PAY_RATE_SS.PROCESS_API','SALARY',
	'HR_PAY_RATE_SS.PROCESS_API_JAVA','SALARY',
 	'PER_SSHR_CHANGE_PAY.PROCESS_API','SALARY',
	'PER_SSHR_CHANGE_PAY.PROCESS_API_JAVA','SALARY',
	'HR_PERCMPTNCE_REVIEW_WEB.PROCESS_API',l_category_undefined,
	'HR_PROCESS_ADDRESS_SS.PROCESS_API',l_category_undefined,
	'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API','ASSIGNMENT',
	'HR_PROCESS_CONTACT_SS.PROCESS_API',l_category_undefined,
	'HR_PROCESS_CONTACT_SS.PROCESS_CREATE_CONTACT_API',l_category_undefined,
	'HR_PROCESS_EIT_SS.PROCESS_API',l_category_undefined,
	'HR_PROCESS_PERSON_SS.PROCESS_API',l_category_undefined,
	'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API',l_category_undefined,
	'HR_PROCESS_SIT_SS.PROCESS_API',l_category_undefined,
	'HR_PROF_UTIL_WEB.PROCESS_API',l_category_undefined,
	'HR_QUA_AWARDS_UTIL_SS.PROCESS_API',l_category_undefined,
	'HR_SALARY_WEB.PROCESS_API','SALARY',
	'HR_SALARY_WEB.process_API','SALARY',
	'HR_SIT_WEB.PROCESS_API',l_category_undefined,
	'HR_SUPERVISOR_SS.PROCESS_API','TRANSFER',
	'HR_SUPERVISOR_WEB.PROCESS_API','TRANSFER',
	'HR_SUPERVISOR_WEB.process_API','TRANSFER',
	'HR_TERMINATION_SS.PROCESS_API','TERMINATION',
	'HR_TERMINATION_SS.PROCESS_SAVE','TERMINATION',
	'HR_TERMINATION_WEB.PROCESS_API','TERMINATION',
	'PAY_PPMV4_SS.PROCESS_API','PAYROLL',
	'PAY_US_OTF_UTIL_WEB.UPDATE_W4_INFO','PAYROLL',
	'PAY_US_WEB_W4.UPDATE_W4_INFO','PAYROLL',
	'PQH_PROCESS_ACADEMIC_RANK.PROCESS_API',l_category_undefined,
	'PQH_PROCESS_EMP_REVIEW.PROCESS_API',l_category_undefined,
	'PQH_PROCESS_TENURE_STATUS.PROCESS_API',l_category_undefined,
	l_category_undefined)
	into l_transaction_category
	from hr_api_transaction_steps hats
	where hats.transaction_step_id = p_transaction_step_id;

	END;

	if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving '||lv_procedure_name||'with p_transaction_step_id:'||p_transaction_step_id, 10);
	end if;

	return l_transaction_category;
  EXCEPTION
    WHEN OTHERS THEN
     raise;
end;

Function isHrHelpDeskAgent
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
 return varchar2 IS

 p_item_key hr_api_transactions.item_key%TYPE;
 p_item_type hr_api_transactions.item_type%TYPE;
 p_hrhd_val varchar2(1);

 Begin
 p_item_type := get_item_type(p_transaction_id);
 p_item_key := get_item_key(p_transaction_id);

 SELECT NVL(text_value,'N') into p_hrhd_val
 FROM wf_item_attribute_values
 where item_type= p_item_type and item_key = p_item_key
 and NAME = 'IS_HR_HELPDESK_AGENT';

 return p_hrhd_val;

 exception
  when others then
  return 'N';

End isHrHelpDeskAgent;


FUNCTION get_requestor_person_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(23) := 'get_requestor_person_id';
ln_requestor_person_id number;
lv_transaction_ref_table hr_api_transactions.transaction_ref_table%type;
lv_transaction_ref_id hr_api_transactions.transaction_ref_id%type;

p_hrhd varchar2(1);

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    p_hrhd := isHrHelpDeskAgent(p_transaction_id);

    if p_hrhd = 'Y' then

    -- get the selected person_id from hr_api_transactions
    -- this would be for HR helpdesk approvals.
    begin
      select selected_person_id
      into ln_requestor_person_id
      from hr_api_transactions
      where transaction_id=p_transaction_id;
    exception
    when others then
       raise;
    end;

    else

    -- get the creator person_id from hr_api_transactions
    -- this would be the default  for all SSHR approvals.

    begin
      select creator_person_id
      into ln_requestor_person_id
      from hr_api_transactions
      where transaction_id=p_transaction_id;
    exception
    when others then
       raise;
    end;

    end if;

   -- if the transaction is for appraisal we need go through
   -- Main Appraiser chain for approvals.
   begin
      select transaction_ref_table,transaction_ref_id
      into lv_transaction_ref_table,lv_transaction_ref_id
      from hr_api_transactions
      where transaction_id=p_transaction_id;

      if(lv_transaction_ref_table='PER_APPRAISALS') then
        begin
          select main_appraiser_id
          into ln_requestor_person_id
          from per_appraisals
          where appraisal_id=lv_transaction_ref_id;
        exception
        when others then
          -- do not raise, return
          null;
        end;
      end if;
   exception
   when others then
        hr_utility.trace(' exception in checking the hr_api_transactions.transaction_ref_table:'||
                             lv_transaction_ref_table||' : ' || sqlerrm);
        -- just log the message no need to raise it
   end;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
end if;

return fnd_number.number_to_canonical(ln_requestor_person_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_requestor_person_id;

function get_sel_person_assignment_id
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
c_assignment_id number;
c_item_type    varchar2(50);
c_item_key     varchar2(100);

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key := get_item_key(p_transaction_id);

if (c_item_key is not null) then
     c_assignment_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'CURRENT_ASSIGNMENT_ID',
	                     ignore_notfound => true);

else
      select assignment_id into c_assignment_id from hr_api_transactions
      where transaction_id = p_transaction_id;
end if;

return fnd_number.number_to_canonical(c_assignment_id);
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_sel_person_assignment_id',c_item_type,c_item_key);
    RAISE;


end get_sel_person_assignment_id ;


FUNCTION get_payrate_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(19) := 'get_payrate_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
--     and hr_api_transaction_steps.api_name='HR_PAY_RATE_SS.PROCESS_API';
       and hr_api_transaction_steps.api_name in ('PER_SSHR_CHANGE_PAY.PROCESS_API', 'HR_PAY_RATE_SS.PROCESS_API');
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_payrate_step_id;


FUNCTION get_assignment_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(22) := 'get_assignment_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
       and hr_api_transaction_steps.api_name='HR_PROCESS_ASSIGNMENT_SS.PROCESS_API';
   return ln_step_id;
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;

return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_assignment_step_id;


FUNCTION get_supeversior_Chg_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(27) := 'get_supeversior_Chg_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
       and hr_api_transaction_steps.api_name='HR_SUPERVISOR_SS.PROCESS_API';
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_supeversior_Chg_step_id;


FUNCTION get_loa_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(15) default 'get_loa_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
       and hr_api_transaction_steps.api_name='HR_PERSON_ABSENCE_SWI.PROCESS_API';
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_loa_step_id;


FUNCTION get_termination_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(23) := 'get_termination_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
       and hr_api_transaction_steps.api_name='HR_TERMINATION_SS.PROCESS_API';
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_termination_step_id;

FUNCTION isChangePay
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(11) := 'isChangePay';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

  ln_step_id :=get_payrate_step_id(p_transaction_id);

  if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isChangePay;


FUNCTION isAssignmentChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(18) := 'isAssignmentChange';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

ln_step_id :=get_assignment_step_id(p_transaction_id);
 if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isAssignmentChange;


FUNCTION isSupervisorChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(18) := 'isSupervisorChange';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

ln_step_id := get_supeversior_Chg_step_id(p_transaction_id);
 if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;

  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isSupervisorChange;



FUNCTION isLOAChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(11) := 'isLOAChange';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

ln_step_id := get_loa_step_id(p_transaction_id);
 if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;

  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isLOAChange;



FUNCTION isTermination
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(18) := 'isAssignmentChange';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

ln_step_id :=get_termination_step_id(p_transaction_id);
 if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isTermination;


FUNCTION get_salary_percent_change
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(25) := 'get_salary_percent_change';
ln_salary_percent_change number default null;
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
ln_no_of_components     NUMBER ;
lv_param_name hr_api_transaction_values.varchar2_value%type;
p_sum_percentage per_pay_transactions.change_percentage%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    -- get payrate step id
       ln_step_id := get_payrate_step_id(p_transaction_id);

      if(ln_step_id is null) then
        ln_salary_percent_change := null;
     else
     -- fix for bug 4148680
if (is_new_change_pay (ln_step_id)= ame_util.booleanAttributeFalse)then
      if(hr_transaction_api.get_varchar2_value(ln_step_id,'p_multiple_components')='Y') then
        -- get number of components P_NO_OF_COMPONENTS

       ln_no_of_components :=hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id,
                    p_name =>'P_NO_OF_COMPONENTS');
        ln_salary_percent_change:= 0;
        FOR i in 1..ln_no_of_components
        LOOP
           lv_param_name := 'p_change_percent'||i;
           ln_salary_percent_change:= ln_salary_percent_change + fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id,
                    p_name =>lv_param_name));
        end loop;
      else

      ln_salary_percent_change:=   hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id,
                    p_name =>'p_change_percent');
      end if;

--changes made by schowdhu Bug#6919576
    else
     begin
	    select sum(change_percentage)
	           into p_sum_percentage
		   from   per_pay_transactions ppt
	    where  parent_pay_transaction_id is null
	    and pay_proposal_id is null    ---8847573
	    and    ppt.transaction_step_id = ln_step_id;
	    exception
	    when no_data_found then
	      return null;
	    when others then
	       raise;
    end;

  ln_salary_percent_change := p_sum_percentage;

     end if;
     end if;
     return ln_salary_percent_change;


if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_salary_percent_change;


FUNCTION get_salary_amount_change
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(24) := 'get_salary_amount_change';
ln_salary_amt_change number default null;
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
ln_no_of_components     NUMBER ;
lv_param_name hr_api_transaction_values.varchar2_value%type;
p_sum_amount per_pay_transactions.change_amount_n%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    -- get the payrate step id
    ln_step_id := get_payrate_step_id(p_transaction_id);

      if(ln_step_id is null) then
        ln_salary_amt_change := null;
     else
    if (is_new_change_pay(ln_step_id) = ame_util.booleanAttributeFalse) then
      -- fix for bug 4148680
       if(hr_transaction_api.get_varchar2_value(ln_step_id,'p_multiple_components')='Y') then
        -- get number of components P_NO_OF_COMPONENTS
       ln_no_of_components :=hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id,
                    p_name =>'P_NO_OF_COMPONENTS');
        ln_salary_amt_change:= 0;
        FOR i in 1..ln_no_of_components
        LOOP
           lv_param_name := 'p_change_amount'||i;
           ln_salary_amt_change:= ln_salary_amt_change + fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id,
                    p_name =>lv_param_name));
        end loop;
      else
      ln_salary_amt_change:=    fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id,
                    p_name =>'p_change_amount'));
       end if;
--changes made by schowdhu Bug#6919576
      else
          begin
       	    select sum(change_amount_n)
       	           into p_sum_amount
       		   from   per_pay_transactions ppt
       	    where  parent_pay_transaction_id is null
       	    and    pay_proposal_id is null    ---8847573
       	    and    ppt.transaction_step_id = ln_step_id;
       	    exception
       	    when no_data_found then
       	      return null;
       	    when others then
       	       raise;
         end;
          ln_salary_amt_change := p_sum_amount;
     end if;
     end if;
     return ln_salary_amt_change;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_salary_amount_change;

--function added by schowdhu Bug#6919576

FUNCTION is_new_change_pay(p_transaction_step_id IN hr_api_transaction_steps.transaction_step_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(19) := 'is_new_change_pay';
ln_api_name hr_api_transaction_steps.api_name%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_step_id:'||p_transaction_step_id, 2);
    end if;
  begin
    select api_name
       into ln_api_name
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_step_id=p_transaction_step_id;
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_step__id:'||p_transaction_step_id, 10);
	end if;
if (ln_api_name='PER_SSHR_CHANGE_PAY.PROCESS_API') then
    lv_status := ame_util.booleanAttributeTrue;
else
    lv_status := ame_util.booleanAttributeFalse;
end if;
return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_step_id);
    RAISE;
END is_new_change_pay;

FUNCTION get_transaction_init_date
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(25) := 'get_transaction_init_date';
lv_creation_date_string varchar2(30) default null;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select ame_util.versiondatetostring(creation_date)
    into lv_creation_date_string
    from hr_api_transactions
   where transaction_id=p_transaction_id;
  exception
  when others then
    raise;
  end;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_creation_date_string;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_transaction_init_date;



FUNCTION get_transaction_effective_date
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(30) := 'get_transaction_effective_date';
lv_effective_date_string varchar2(30) default null;
lv_item_type    varchar2(50);
lv_item_key     varchar2(100);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;


lv_item_type := get_item_type(p_transaction_id);
lv_item_key := get_item_key(p_transaction_id);

if(lv_item_key is not null) then
     lv_effective_date_string := ame_util.versiondatetostring(wf_engine.GetItemAttrDate(itemtype => lv_item_type ,
                                              itemkey => lv_item_key,
                                              aname => 'CURRENT_EFFECTIVE_DATE',
                                               ignore_notfound => true));

else
      select transaction_effective_date into lv_effective_date_string from hr_api_transactions
      where transaction_id = p_transaction_id;
end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;

  return lv_effective_date_string;

EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_transaction_effective_date;



FUNCTION get_sel_person_prop_sup_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(26) := 'get_sel_person_prop_sup_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
ln_sel_person_prop_sup_id varchar2(10);
ln_new_sel_person_prop_sup_id number;
ln_old_sel_person_prop_sup_id number;

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
       -- get step id
       ln_step_id:= get_supeversior_Chg_step_id(p_transaction_id);
       if(ln_step_id is not null) then
         ln_new_sel_person_prop_sup_id :=
           fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_step_id,
                            p_name =>'p_selected_person_sup_id'));
         ln_old_sel_person_prop_sup_id :=
           fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_step_id,
                            p_name =>'p_selected_person_old_sup_id'));

         if(nvl(ln_new_sel_person_prop_sup_id,-111)<>nvl(ln_old_sel_person_prop_sup_id,-111)) then
           ln_sel_person_prop_sup_id:=ln_new_sel_person_prop_sup_id;
         else
           ln_sel_person_prop_sup_id:= null;
         end if;
       else
        ln_sel_person_prop_sup_id := null;
       end if;


if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return ln_sel_person_prop_sup_id;

EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_sel_person_prop_sup_id;

FUNCTION get_selected_person_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(22) := 'get_selected_person_id';
lv_selected_person_id varchar2(10);
lv_item_type    varchar2(50);
lv_item_key     varchar2(100);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    lv_item_type := get_item_type(p_transaction_id);
    lv_item_key := get_item_key(p_transaction_id);

   -- CURRENT_PERSON_ID
 if ( lv_item_key is not NULL) then
    lv_selected_person_id := wf_engine.GetItemAttrNumber(itemtype => lv_item_type ,
                                              itemkey => lv_item_key,
                                              aname => 'CURRENT_PERSON_ID',
	                    ignore_notfound => true);

   else
      select selected_person_id into lv_selected_person_id from hr_api_transactions
      where transaction_id = p_transaction_id;
    end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;

return   fnd_number.number_to_canonical(lv_selected_person_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_selected_person_id;

FUNCTION get_proposed_job_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(19) := 'get_proposed_job_id';
lv_job_id varchar2(15);
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
ln_new_job_id number;
ln_orginal_job_id number;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

   ln_step_id := get_assignment_step_id(p_transaction_id);
   if(ln_step_id is not null) then
     -- fix for bug 4145754
     ln_new_job_id := fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_JOB_ID'));

     ln_orginal_job_id := fnd_number.number_to_canonical(hr_transaction_api.get_original_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_JOB_ID'));
     if(nvl(ln_new_job_id,-111)<>nvl(ln_orginal_job_id,-111)) then
      lv_job_id:=ln_new_job_id;
     else
      lv_job_id:= null;
     end if;
    else
      lv_job_id:= null;
    end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;

  return lv_job_id;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_proposed_job_id;


FUNCTION get_proposed_position_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(24) := 'get_proposed_position_id';
lv_position_id varchar2(15);
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
ln_new_position_id number;
ln_orginal_position_id number;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    ln_step_id := get_assignment_step_id(p_transaction_id);
   if(ln_step_id is not null) then

     ln_new_position_id := fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_POSITION_ID'));

     ln_orginal_position_id := fnd_number.number_to_canonical(hr_transaction_api.get_original_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_POSITION_ID'));
     if(nvl(ln_new_position_id,-111)<>nvl(ln_orginal_position_id,-111)) then
      lv_position_id:=ln_new_position_id;
     else
      lv_position_id:= null;
     end if;
    else
      lv_position_id:= null;
    end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
   return lv_position_id;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_proposed_position_id;


FUNCTION get_proposed_grade_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(21) := 'get_proposed_grade_id';
lv_grade_id varchar2(15);
ln_step_id hr_api_transaction_steps.transaction_step_id%type;

ln_new_id number;
ln_orginal_id number;

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;


   ln_step_id := get_assignment_step_id(p_transaction_id);
   if(ln_step_id is not null) then

     ln_new_id := fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_GRADE_ID'));

     ln_orginal_id := fnd_number.number_to_canonical(hr_transaction_api.get_original_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_GRADE_ID'));
     if(nvl(ln_new_id,-111)<>nvl(ln_orginal_id,-111)) then
      lv_grade_id:=ln_new_id;
     else
      lv_grade_id:= null;
     end if;

    else
      lv_grade_id:= null;
    end if;


if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_grade_id;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_proposed_grade_id;

FUNCTION get_proposed_location_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(24) := 'get_proposed_location_id';
lv_location_id varchar2(15);
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
ln_new_id number;
ln_orginal_id number;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
     ln_step_id := get_assignment_step_id(p_transaction_id);
   if(ln_step_id is not null) then

     ln_new_id := fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_LOCATION_ID'));

     ln_orginal_id := fnd_number.number_to_canonical(hr_transaction_api.get_original_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_LOCATION_ID'));
     if(nvl(ln_new_id,-111)<>nvl(ln_orginal_id,-111)) then
      lv_location_id:=ln_new_id;
     else
      lv_location_id:= null;
     end if;
    else
      lv_location_id:= null;
    end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_location_id;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_proposed_location_id;

FUNCTION get_appraisal_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(18) := 'get_appraisal_type';
lv_transaction_ref_table hr_api_transactions.transaction_ref_table%type;
lv_transaction_ref_id hr_api_transactions.transaction_ref_id%type;
lv_system_type VARCHAR2(30) default null;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

begin
      select transaction_ref_table,transaction_ref_id
      into lv_transaction_ref_table,lv_transaction_ref_id
      from hr_api_transactions
      where transaction_id=p_transaction_id;

      if(lv_transaction_ref_table='PER_APPRAISALS') then
        begin
          select per_appraisals.system_type
          into lv_system_type
          from per_appraisals
          where appraisal_id=lv_transaction_ref_id;
        exception
        when others then
          -- do not raise, return
          null;
        end;
      end if;
   exception
   when others then
        hr_utility.trace(' exception in checking the hr_api_transactions.transaction_ref_table:'|| sqlerrm);
        -- just log the message no need to raise it
   end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_system_type;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_appraisal_type;


FUNCTION get_overall_appraisal_rating
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(28) := 'get_overall_appraisal_rating';
lv_transaction_ref_table hr_api_transactions.transaction_ref_table%type;
lv_transaction_ref_id hr_api_transactions.transaction_ref_id%type;
ln_overall_rating number;

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    begin
      select transaction_ref_table,transaction_ref_id
      into lv_transaction_ref_table,lv_transaction_ref_id
      from hr_api_transactions
      where transaction_id=p_transaction_id;

      if(lv_transaction_ref_table='PER_APPRAISALS') then
        begin
          Select prl.step_value
          into ln_overall_rating
	  from per_appraisals appr, per_rating_levels prl
          where appraisal_id = lv_transaction_ref_id
          and appr.overall_performance_level_id = prl.rating_level_id;
        exception
        when others then
          -- do not raise, return
          null;
        end;
      end if;
   exception
   when others then
        hr_utility.trace(' exception in checking the hr_api_transactions.transaction_ref_table:'|| sqlerrm);
        -- just log the message no need to raise it
   end;






if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return fnd_number.number_to_canonical(ln_overall_rating);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_overall_appraisal_rating;

FUNCTION get_absence_type_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(19) := 'get_absence_type_id';
lv_absence_type_id number;
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

   ln_step_id := get_loa_step_id(p_transaction_id);
   if(ln_step_id is not null) then
      select INFORMATION5 INTO lv_absence_type_id from hr_api_transaction_steps where transaction_step_id = ln_step_id;
   else
      lv_absence_type_id:= null;
   end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_absence_type_id;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_absence_type_id;

FUNCTION get_proposed_payroll_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(23) := 'get_proposed_payroll_id';

lv_payroll_id varchar2(15);
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
ln_new_id number;
ln_orginal_id number;

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
     ln_step_id := get_assignment_step_id(p_transaction_id);
   if(ln_step_id is not null) then

     ln_new_id := fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_PAYROLL_ID'));

     ln_orginal_id := fnd_number.number_to_canonical(hr_transaction_api.get_original_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_PAYROLL_ID'));
     if(nvl(ln_new_id,-111)<>nvl(ln_orginal_id,-111)) then
      lv_payroll_id:=ln_new_id;
     else
      lv_payroll_id:= null;
     end if;
    else
      lv_payroll_id:= null;
    end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_payroll_id;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_proposed_payroll_id;


FUNCTION get_proposed_salary_basis
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(25) := 'get_proposed_salary_basis';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_salary_basis VARCHAR2(30) default null;
ln_pay_basis_id number;
lv_item_type    varchar2(50);
lv_item_key     varchar2(100);
ld_effective_date date;
ln_new_id number;
ln_orginal_id number;

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    ln_step_id := get_assignment_step_id(p_transaction_id);
    if(ln_step_id is not null) then
     ln_new_id := fnd_number.number_to_canonical(hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_PAY_BASIS_ID'));

     ln_orginal_id := fnd_number.number_to_canonical(hr_transaction_api.get_original_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_PAY_BASIS_ID'));
     if(nvl(ln_new_id,-111)<>nvl(ln_orginal_id,-111)) then
      ln_pay_basis_id:=ln_new_id;
     else
      ln_pay_basis_id:= null;
      return null;
     end if;


     lv_item_type := get_item_type(p_transaction_id);
     lv_item_key := get_item_key(p_transaction_id);

if (lv_item_key is not null) then
     ld_effective_date:= wf_engine.GetItemAttrDate(itemtype => lv_item_type ,
                                              itemkey => lv_item_key,
                                              aname => 'CURRENT_EFFECTIVE_DATE',
      	                    ignore_notfound => true);

else
      select transaction_effective_date into ld_effective_date from hr_api_transactions
      where transaction_id = p_transaction_id;
end if;

       select ppb.name
       into lv_salary_basis
       from pay_element_types_f pet,
       pay_input_values_f       piv,
       per_pay_bases            ppb
       where ppb.pay_basis_id=ln_pay_basis_id
       and ppb.input_value_id=piv.input_value_id
       and ld_effective_date  between
       piv.effective_start_date and
       piv.effective_end_date
       and piv.element_type_id=pet.element_type_id
       and ld_effective_date  between
       pet.effective_start_date and
       pet.effective_end_date;

    else
      lv_salary_basis:= null;
    end if;


if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return lv_salary_basis;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_proposed_salary_basis;


FUNCTION get_asg_change_reason
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(21) := 'get_asg_change_reason';
lv_asg_change_reason VARCHAR2(30) default null;
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_new_value  VARCHAR2(30);
lv_orginal_value  VARCHAR2(30);

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    ln_step_id := get_assignment_step_id(p_transaction_id);
   if(ln_step_id is not null) then

     lv_new_value:= hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => ln_step_id
                              ,p_name                => 'P_CHANGE_REASON');

     lv_orginal_value:= hr_transaction_api.get_original_varchar2_value
                              (p_transaction_step_id => ln_step_id
                              ,p_name                => 'P_CHANGE_REASON');

      if(nvl(lv_new_value,'-111')<>nvl(lv_orginal_value,'-111')) then
       lv_asg_change_reason:=lv_new_value;
      else
        lv_asg_change_reason:=null;
      end if;

    else
      lv_asg_change_reason:= null;
    end if;


if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_asg_change_reason;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_asg_change_reason;

FUNCTION get_leaving_reason
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(18) := 'get_leaving_reason';
lv_leaving_reason VARCHAR2(30) default null;
ln_step_id hr_api_transaction_steps.transaction_step_id%type;

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
    ln_step_id := get_termination_step_id(p_transaction_id);
   if(ln_step_id is not null) then
     lv_leaving_reason:= hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => ln_step_id
                              ,p_name                => 'P_LEAVING_REASON');
    else
      lv_leaving_reason:= null;
    end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return lv_leaving_reason;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_leaving_reason;


FUNCTION get_person_type_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(18) := 'get_person_type_id';
lv_person_type_id VARCHAR2(30) default null;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;


if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_person_type_id;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_person_type_id;


FUNCTION getYOS(
    p_person_id IN NUMBER
   ,p_eff_date IN DATE )
RETURN NUMBER
IS
  ln_result NUMBER:=0;

  CURSOR c_yos (p_person_id IN per_people_f.person_id%TYPE)
  IS
  SELECT ROUND(SUM(MONTHS_BETWEEN(
		decode(sign(p_eff_date-nvl(actual_termination_date, p_eff_date)),
                           -1, trunc(p_eff_date), nvl(actual_termination_date, trunc(p_eff_date))),
                trunc(ser.date_start))/12), 2) yos
  FROM per_periods_of_service ser
  WHERE ser.person_id = p_person_id
  AND ser.date_start <= p_eff_date;

BEGIN
  OPEN c_yos(p_person_id => p_person_id);
  FETCH c_yos INTO ln_result;
  CLOSE c_yos;

  IF ln_result < 1/365
  THEN ln_result := ROUND(1/365,2);
  END IF;

  RETURN ln_result;
  Exception When Others then
    return 0;
END getYOS;


FUNCTION get_length_of_service
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(21) := 'get_length_of_service';
ln_length_of_service number;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

ln_length_of_service := getYOS(get_selected_person_id(p_transaction_id),trunc(sysdate));

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return fnd_number.number_to_canonical(ln_length_of_service);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_length_of_service;



FUNCTION get_assignment_category
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(23) := 'get_assignment_category';
lv_assignment_category VARCHAR2(30) default null;
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_new_value  VARCHAR2(30);
lv_orginal_value  VARCHAR2(30);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
   ln_step_id := get_assignment_step_id(p_transaction_id);
   if(ln_step_id is not null) then
     lv_new_value:= hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => ln_step_id
                              ,p_name                => 'P_EMPLOYMENT_CATEGORY');

     lv_orginal_value:= hr_transaction_api.get_original_varchar2_value
                              (p_transaction_step_id => ln_step_id
                              ,p_name                => 'P_EMPLOYMENT_CATEGORY');

      if(nvl(lv_new_value,'-111')<>nvl(lv_orginal_value,'-111')) then
       lv_assignment_category:=lv_new_value;
      else
        lv_assignment_category:=null;
      end if;

    else
      lv_assignment_category:= null;
    end if;



if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_assignment_category;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_assignment_category;

FUNCTION get_payroll_con_user_name
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(25) := 'get_payroll_con_user_name';
lv_user_name varchar2(30) default null;
lv_orig_system   varchar2(50);
lv_orig_system_id   number;
BEGIN

  if(hr_utility.debug_enabled) then
    -- write debug statements
    hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
  end if;

 if(isMidPayPayPeriodChange(p_transaction_id)=ame_util.booleanAttributeTrue) then
    if(hr_utility.debug_enabled) then
       hr_utility.set_location('calling wf_engine.getitemattrtext ',3);
    end if;
    lv_user_name:= wf_engine.getitemattrtext(get_item_type(p_transaction_id),get_item_key(p_transaction_id),'HR_PAYROLL_CONTACT_USERNAME',true);
    -- get the role info details
    if(lv_user_name is not null) then
      wf_directory.getroleorigsysinfo(lv_user_name,lv_orig_system,lv_orig_system_id);
      lv_user_name:=lv_orig_system||':'||lv_orig_system_id;
    end if;
 end if;

 if(hr_utility.debug_enabled) then
   hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
end if;

return lv_user_name;

EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_payroll_con_user_name;


FUNCTION get_basic_details_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(25) := 'get_basic_details_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
       and hr_api_transaction_steps.api_name='HR_PROCESS_PERSON_SS.PROCESS_API';
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_basic_details_step_id;


FUNCTION isPersonDetailsChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(21) := 'isPersonDetailsChange';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

  ln_step_id := get_basic_details_step_id(p_transaction_id);

  if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isPersonDetailsChange;




FUNCTION get_person_address_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(26) := 'get_person_address_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
       and hr_api_transaction_steps.api_name='HR_PROCESS_ADDRESS_SS.PROCESS_API';
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_person_address_step_id;


FUNCTION isPersonAddressChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(21) := 'isPersonAddressChange';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

  ln_step_id := get_person_address_step_id(p_transaction_id);

  if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isPersonAddressChange;


FUNCTION get_person_contact_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(30) := 'get_person_contact_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
       and hr_api_transaction_steps.api_name in ('HR_PROCESS_CONTACT_SS.PROCESS_API',
                                                 'HR_PROCESS_CONTACT_SS.PROCESS_CREATE_CONTACT_API')
       and rownum<2;

  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_person_contact_step_id;


FUNCTION isPersonContactChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(21) := 'isPersonAddressChange';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

  ln_step_id := get_person_contact_step_id(p_transaction_id);

  if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isPersonContactChange;



FUNCTION get_caed_step_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(16) := 'get_caed_step_id';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;
  begin
    select transaction_step_id
       into ln_step_id
       from hr_api_transaction_steps
       where hr_api_transaction_steps.transaction_id=p_transaction_id
       and hr_api_transaction_steps.api_name='HR_CAED_SS.PROCESS_API';
  exception
  when no_data_found then
    return null;
  when others then
     raise;
  end;
if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_step_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_caed_step_id;


FUNCTION isReleaseInformation
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
-- local variables
lv_procedure_name constant varchar2(20) := 'isReleaseInformation';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

  ln_step_id := get_caed_step_id(p_transaction_id);

  if(ln_step_id is not null) then
   lv_status := ame_util.booleanAttributeTrue;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
  return lv_status;
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isReleaseInformation;


FUNCTION get_paybasis_id
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
-- local variables
lv_procedure_name constant varchar2(25) := 'get_proposed_salary_basis';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_salary_basis VARCHAR2(30) default null;
ln_pay_basis_id number;
lv_item_type    varchar2(50);
lv_item_key     varchar2(100);
ld_effective_date date;
BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

    ln_step_id := get_assignment_step_id(p_transaction_id);
    if(ln_step_id is not null) then
     ln_pay_basis_id :=  hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_step_id
                   ,p_name                => 'P_PAY_BASIS_ID');

    end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Leaving'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;
return fnd_number.number_to_canonical(ln_pay_basis_id);
EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END get_paybasis_id;

FUNCTION isMidPayPayPeriodChange
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
 -- local variables
lv_procedure_name constant varchar2(25) := 'isMidPayPayPeriodChange';
ln_step_id hr_api_transaction_steps.transaction_step_id%type;
lv_status varchar2(10);
result varchar2(50);


l_assignment_id     per_all_assignments_f.assignment_id%type default null;
l_payroll_id        per_all_assignments_f.payroll_id%type default null;
l_old_pay_basis_id  per_all_assignments_f.pay_basis_id%type default null;
l_new_pay_basis_id  per_all_assignments_f.pay_basis_id%type default null;
l_pay_period_start_date    date default null;
l_pay_period_end_date      date default null;

l_asg_txn_step_id          hr_api_transaction_steps.transaction_step_id%type
                           default null;
l_effective_date           date default null;


CURSOR csr_check_mid_pay_period(p_eff_date_csr   in date
                                 ,p_payroll_id_csr in number) IS
select start_date, end_date
from   per_time_periods
where  p_eff_date_csr > start_date
and    p_eff_date_csr <= end_date
and    payroll_id = p_payroll_id_csr;

-- Get existing assignment data
CURSOR csr_get_old_asg_data IS
SELECT pay_basis_id
FROM   per_all_assignments_f
WHERE  assignment_id = l_assignment_id
AND    l_effective_date between effective_start_date
                            and effective_end_date
AND    assignment_type = 'E';

BEGIN
 hr_utility.set_location(g_package||'.'||lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 2);
    end if;

 -- check if this transaction has assignment step
  if(isAssignmentChange(p_transaction_id)=ame_util.booleanAttributeTrue) then
      -- code logic from hr_workflow_ss.check_mid_pay_period_change

     l_asg_txn_step_id:= get_assignment_step_id(p_transaction_id);
     l_effective_date := to_date(
        hr_transaction_ss.get_wf_effective_date
          (p_transaction_step_id => l_asg_txn_step_id),
                        hr_transaction_ss.g_date_format);

        -- Get the pay_basis_id and payroll_id
        l_new_pay_basis_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_PAY_BASIS_ID');

        l_payroll_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_PAYROLL_ID');

        l_assignment_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_ASSIGNMENT_ID');

        -- Now get the old pay basis id
        OPEN csr_get_old_asg_data;
        FETCH csr_get_old_asg_data into l_old_pay_basis_id;
        IF csr_get_old_asg_data%NOTFOUND  THEN
         -- could be a new hire or applicant hire, there is no asg rec
          CLOSE csr_get_old_asg_data;
        ELSE
           CLOSE csr_get_old_asg_data;
        END IF;

        IF l_old_pay_basis_id IS NOT NULL and
           l_new_pay_basis_id IS NOT NULL and
           l_old_pay_basis_id <> l_new_pay_basis_id and
           l_payroll_id IS NOT NULL
        THEN
           -- perform mid pay period check
           OPEN csr_check_mid_pay_period
              (p_eff_date_csr   => l_effective_date
              ,p_payroll_id_csr => l_payroll_id);
           FETCH csr_check_mid_pay_period into l_pay_period_start_date
                                             ,l_pay_period_end_date;
           IF csr_check_mid_pay_period%NOTFOUND  THEN
              -- That means the effective date is not in mid pay period
              lv_status := ame_util.booleanAttributeFalse;
              CLOSE csr_check_mid_pay_period;
           ELSE
              lv_status := ame_util.booleanAttributeTrue;
              CLOSE csr_check_mid_pay_period;
           END IF;
        END IF;
  else
    lv_status := ame_util.booleanAttributeFalse;
  end if;

if(hr_utility.debug_enabled) then
          -- write debug statements
          hr_utility.set_location('Entered'||lv_procedure_name||'with transaction_id:'||p_transaction_id, 10);
	end if;

  return lv_status;


EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.lv_procedure_name',p_transaction_id);
    RAISE;

END isMidPayPayPeriodChange;


FUNCTION getRequestorPositionId
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number
is
-- local variable
ln_position_id number;
c_proc constant varchar2(30) := 'getRequestorPositionId';


cursor requestorPosId is
select paf.position_id
 from per_all_assignments_f paf,
      per_all_people_f ppf,
      per_position_structures pps, per_pos_structure_versions ppsv,
      hr_api_transactions hat
where hat.transaction_id = p_transaction_id
and paf.person_id  = hat.creator_person_id
and trunc(sysdate) between paf.effective_start_date and paf.effective_end_date
and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
and paf.primary_flag = 'Y'
and paf.assignment_type in ('E','C')
and paf.person_id = ppf.person_id
and ppf.business_group_id = pps.business_group_id(+)
and pps.primary_position_flag (+) = 'Y'
and pps.position_structure_id = ppsv.position_structure_id(+)
and trunc(sysdate) between ppsv.date_from(+) and nvl(ppsv.date_to(+),sysdate);
begin
  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
   end if;

  open requestorPosId;
   fetch requestorPosId into ln_position_id;
   if(requestorPosId%notfound) then
     ln_position_id:= null;
   end if;
  close requestorPosId;

  if (g_debug ) then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
  end if;

 return ln_position_id;

exception
when others then

    if g_debug then
       hr_utility.set_location('Error in  getRequestorPositionId SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;
  -- close the cursor if open
  if(requestorPosId%isopen) then
    close requestorPosId;
  end if;
  raise;
end getRequestorPositionId;

END HR_AMEUTIL_SS;

/
