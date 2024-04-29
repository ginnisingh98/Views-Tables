--------------------------------------------------------
--  DDL for Package Body HR_NEW_USER_REG_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NEW_USER_REG_SS" AS
/* $Header: hrregwrs.pkb 120.1.12010000.6 2009/09/17 08:58:49 ckondapi ship $*/

-- This package is for the new user registration process

-- Package Variables
--
g_package  varchar2(33) := 'HR_NEW_USER_REG_SS.';
g_update_object_version varchar2(30) := 'update_object_version';

FUNCTION is_Assignment_SFL(
p_transaction_step_id in number)
RETURN boolean is

l_review_proc_call     varchar2(4000);
l_save_mode  varchar2(2000);

BEGIN

    l_save_mode :=    hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_SAVE_MODE');

    l_review_proc_call:=    hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => p_transaction_step_id
        ,p_name                => 'P_REVIEW_PROC_CALL');

RETURN (l_save_mode = 'SAVE_FOR_LATER') and (l_review_proc_call = 'HrAssignment');

END is_Assignment_SFL;

-- ----------------------------------------------------------------------------
-- |---------------------------< processNewUserTransaction >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure creates a person  using the data in the
-- transaction tables if it doesn't find one.

procedure  processNewUserTransaction
(WfItemType     in varchar2,
 WfItemKey      in varchar2,
 PersonId       in out nocopy varchar2,
 AssignmentId   in out nocopy varchar2) is

  cursor csr_person is select person_id from per_all_people_f where person_id = PersonId;

  cursor csr_txn_step_id is
  select trs.transaction_step_id
    from   hr_api_transaction_steps trs
    where  trs.transaction_id = hr_transaction_ss.get_transaction_id
                        (WfItemType  ,WfItemKey )
    and    trs.api_name ='HR_PROCESS_PERSON_SS.PROCESS_API';

  l_effective_date	date;
  l_session_c		number;
  l_transaction_step_id 	number;
  l_business_grp_Id number;

  l_newUserPersonId per_all_people_f.person_id%type;
  l_result varchar2(100);
  l_proc varchar2(72)  := g_package||'processNewUserTransaction';
begin

hr_utility.set_location('Entering:'|| l_proc, 5);

open csr_person;
fetch csr_person into l_newUserPersonId;

-- if the person Id is not in the database then a dummy person was created and rolled back in the database.
-- need to recreat the person again.

if csr_person%notfound then
hr_utility.set_location('in side if csr_person%notfound :'|| l_proc, 5);
/*
hr_transaction_web.commit_transaction
(itemtype=>WfItemType,
 itemkey=>WfItemKey,
 actid=>'12345',   -- can hard code this to anything this is not being used inside the call
 funmode=>'RUN',   -- the necessary mode to run the api in commit mode
 result=>l_result); -- though we are getting the error results back we are not using them.
-- the commit process will call Process_api of hr_process_person_ss which
*/
/* Replaced commit_transaction with process_selected_transaction, commit transaction will
   call all the steps for a given item key. However we need only person and address apis
   are
*/

--ignore the emp number generation for newhire flow
hr_new_user_reg_ss.g_ignore_emp_generation := 'YES';

--bug 5665820
if(hr_general.get_business_group_id is null) then

open csr_txn_step_id;
fetch csr_txn_step_id into l_transaction_step_id;
close csr_txn_step_id;

l_business_grp_Id :=hr_transaction_api.get_number_value
                                (p_transaction_step_id => l_transaction_step_id
                                ,p_name => 'P_BUSINESS_GROUP_ID');

fnd_profile.put('PER_BUSINESS_GROUP_ID',l_business_grp_Id);

end if;
--bug 5665820

  --bug 7459817
l_effective_date   :=   to_date(wf_engine.getitemattrtext
                          	(itemtype => WfItemType
                          	,itemkey  => WfItemKey
                          	,aname    => 'P_EFFECTIVE_DATE'),'RRRR-MM-DD');
 begin
   select 1 into l_session_c from fnd_sessions where session_id=userenv('sessionid');
  exception
   when no_data_found then
     insert into fnd_sessions(session_id,effective_date) values(userenv('sessionid'),l_effective_date);
 end;

process_selected_transaction
(p_item_type => WfItemType,
 p_item_key => WfItemKey);

-- the commit process will call Process_api of hr_process_person_ss which
-- creates a person and returns us the person id and assignment_id.

PersonId := to_char(hr_process_person_ss.g_person_id);
AssignmentId := to_char(hr_process_person_ss.g_assignment_id);
end if;
-- close the cursor
close csr_person;

hr_utility.set_location('Leaving:'|| l_proc, 10);

EXCEPTION
  WHEN OTHERS THEN
  PersonId := null;
  AssignmentId := null;
    raise;

end processNewUserTransaction;

procedure process_selected_transaction
  (p_item_type           in varchar2
  ,p_item_key            in varchar2
  ,p_ignore_warnings     in varchar2 default 'Y'
  ,p_validate            in boolean default false
  ,p_update_object_version in varchar2 default 'N'
  ,p_effective_date      in varchar2 default null
  ,p_api_name            in varchar2 default null) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_transaction_id      hr_api_transactions.transaction_id%type;
  l_application_error   boolean := false;
  l_object_version_error   boolean := false;
  l_obj_fatal_error     boolean := false;
  l_warning_error       boolean := false;
  l_ignore_warnings     boolean;
  l_obj_api_name        varchar2(200);
  l_api_error_name      varchar2(200);

  -- Generic Cursor
  cursor csr_trs is
    select trs.transaction_step_id
          ,trs.api_name
          ,trs.item_type
          ,trs.item_key
          ,trs.activity_id
          ,trs.creator_person_id
    from   hr_api_transaction_steps trs
    where  trs.transaction_id = l_transaction_id
    and    trs.api_name in ('HR_PROCESS_PERSON_SS.PROCESS_API',
                            'HR_PROCESS_ADDRESS_SS.PROCESS_API',
                            'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API',
                            'HR_PROCESS_CONTACT_SS.PROCESS_CREATE_CONTACT_API')
    order by trs.processing_order,trs.transaction_step_id;

  --Selective cursor
  cursor csr_sel_trs is
    select trs.transaction_step_id
          ,trs.api_name
          ,trs.item_type
          ,trs.item_key
          ,trs.activity_id
          ,trs.creator_person_id
    from   hr_api_transaction_steps trs
    where  trs.transaction_id = l_transaction_id
    and    trs.api_name = p_api_name
    order by trs.processing_order;

begin
  -- set the ignore warnings flag
  if upper(p_ignore_warnings) = 'Y' then
    l_ignore_warnings := true;
  else
    l_ignore_warnings := false;
  end if;
  -- get the transaction id
  l_transaction_id := hr_transaction_ss.get_transaction_id
                         (p_item_type => p_item_type
                         ,p_item_key  => p_item_key);
  if l_transaction_id is null then
     return;
  end if;


  hr_process_person_ss.g_person_id := null;
  hr_process_person_ss.g_assignment_id := null;

  if(p_api_name is not null) then
    -- process selected api step
    for csr_sel in csr_sel_trs loop
     begin
       hr_transaction_ss.process_web_api_call
       (p_transaction_step_id => csr_sel.transaction_step_id
       ,p_api_name            => csr_sel.api_name
       ,p_validate => p_validate);
     exception
      when hr_utility.hr_error then
        -- an application error has been raised. set the error flag
        -- to indicate an application error
        -- the error message should of been set already
        hr_message.provide_error;
        l_api_error_name := hr_message.last_message_name;
        if l_api_error_name = 'HR_7155_OBJECT_INVALID' then
          l_obj_fatal_error := true;
          exit;
        else
          l_application_error := true;

          -------------------------------------------------------------------
          -- 05/09/2002 Bug 2356339 Fix Begins
          -- We need to exit the loop here when there is an application error.
          -- This will happen when apporval is required and the final approver
          -- approved the change.  When the Workflow responsibility to approve
          -- the transaction has no Security Profile attached, and the
          -- Business Group profile option is null and Cross Business Group
          -- equals to 'N', you will get an Application Error after the final
          -- approver approves the transaction.  This problem usually happens
          -- in New Hire or Applicant Hire whereby the new employee created
          -- is not in the per_person_list table.  In hr_process_person_ss.
          -- process_api, it call hr_employee_api.create_employee which
          -- eventually will call dt_api.return_min_start_date.  This
          -- dt_api.return_min_start_date accesses the per_people_f secured
          -- view, you will get HR_7182_DT_NO_MIN_MAX_ROWS error with the
          -- following error text:
          --  No DateTrack row found in table per_people_f.
          -- When that happens, the l_application_error is set to true. However,
          -- if there is no Exit statement, this code will continue to call
          -- the next transaction step.  Each of the subsequent step will fail
          -- with an error until the last step is called and the error from
          -- the last step will overwrite the initial real error message.
          -- Without the exit statement, it will be very difficult to pinpoint
          -- the location where the real problem occurred.
          ---------------------------------------------------------------------

          EXIT;  -- Bug 2356339 Fix

          -- 05/09/2002 Bug 2356339 Fix Ends

        end if;
        raise;
      when others then
        -- a system error has occurred so raise it to stop
        -- processing of the transaction steps
        raise;
     end;
    end loop;
  else
   -- select each transaction steps to process
   for i in csr_trs loop
    begin
      -- call the API for the transaction step
      -- don't call the assignment step, if coming back from
      -- SFL and SFL is done on Assignment page
     if (i.api_name <> 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API') OR
        ((i.api_name = 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API') and
         (NOT is_Assignment_SFL(i.transaction_step_id))) then
      if p_update_object_version = 'Y' then
        -- update object version for each step
        l_obj_api_name := substr(i.api_name,1, instr(i.api_name,'.'));
        l_obj_api_name := l_obj_api_name || g_update_object_version;
        hr_transaction_ss.process_web_api_call
        (p_transaction_step_id => i.transaction_step_id
        ,p_api_name            => l_obj_api_name
        ,p_extra_parameter_name => 'p_login_person_id'
        ,p_extra_parameter_value => i.creator_person_id
        ,p_validate => false);
      elsif p_effective_date is not null then
        --validate api with the new p_effective_date
        hr_transaction_ss.process_web_api_call
        (p_transaction_step_id => i.transaction_step_id
        ,p_api_name            => i.api_name
        ,p_extra_parameter_name => 'p_effective_date'
        ,p_extra_parameter_value => p_effective_date
        ,p_validate => p_validate);
      else
        --validate api
        hr_transaction_ss.process_web_api_call
        (p_transaction_step_id => i.transaction_step_id
        ,p_api_name            => i.api_name
        ,p_validate => p_validate);
      end if;
     end if;
      -- do we ignore any warnings which may have been set?
      if not l_ignore_warnings then
        -- check to see if any warnings have been set
        if (not l_warning_error) and
          hr_emp_error_utility.exists_warning_text
            (p_item_type => i.item_type
            ,p_item_key  => i.item_key
            ,p_actid     => i.activity_id) then
          -- set the warning flag to true
          l_warning_error := true;
        end if;
      end if;
    exception
      when hr_utility.hr_error then
        -- an application error has been raised. set the error flag
        -- to indicate an application error
        -- the error message should of been set already
        hr_message.provide_error;
        l_api_error_name := hr_message.last_message_name;
        if l_api_error_name = 'HR_7155_OBJECT_INVALID' then
          l_obj_fatal_error := true;
          exit;
          --if i.api_name = 'BEN_PROCESS_COMPENSATION_W.PROCESS_API' then
          --  fnd_message.set_name('PER','HR_FATAL_OBJECT_ERROR');
          --  l_obj_fatal_error := true;
          --  exit;
          --end if;
        else
          l_application_error := true;

          -------------------------------------------------------------------
          -- 05/09/2002 Bug 2356339 Fix Begins
          -- We need to exit the loop here when there is an application error.
          -- This will happen when apporval is required and the final approver
          -- approved the change.  When the Workflow responsibility to approve
          -- the transaction has no Security Profile attached, and the
          -- Business Group profile option is null and Cross Business Group
          -- equals to 'N', you will get an Application Error after the final
          -- approver approves the transaction.  This problem usually happens
          -- in New Hire or Applicant Hire whereby the new employee created
          -- is not in the per_person_list table.  In hr_process_person_ss.
          -- process_api, it call hr_employee_api.create_employee which
          -- eventually will call dt_api.return_min_start_date.  This
          -- dt_api.return_min_start_date accesses the per_people_f secured
          -- view, you will get HR_7182_DT_NO_MIN_MAX_ROWS error with the
          -- following error text:
          --  No DateTrack row found in table per_people_f.
          -- When that happens, the l_application_error is set to true. However,
          -- if there is no Exit statement, this code will continue to call
          -- the next transaction step.  Each of the subsequent step will fail
          -- with an error until the last step is called and the error from
          -- the last step will overwrite the initial real error message.
          -- Without the exit statement, it will be very difficult to debug the
          -- location when the real problem occurs.
          ---------------------------------------------------------------------

          EXIT;  -- Bug 2356339 Fix

          -- 05/09/2002 Bug 2356339 Fix Ends

        end if;
        raise;
      when others then
        -- a system error has occurred so raise it to stop
        -- processing of the transaction steps
        raise;
    end;
   end loop;
  end if;

  -- check to see if any application errors where raised
  if l_obj_fatal_error then
    fnd_message.set_name('PER','HR_FATAL_OBJECT_ERROR');
    raise hr_utility.hr_error;
  elsif l_object_version_error then
    fnd_message.set_name('PER','HR_7155_OBJECT_INVALID');
    raise hr_utility.hr_error;
  elsif l_application_error or l_warning_error then
    raise hr_utility.hr_error;
  end if;

exception
  when others then
    -- an application error, warning or system error was raised so
    -- keep raising it so the calling process must handle it
    raise;
end process_selected_transaction;

procedure  processExEmpTransaction
(WfItemType     in varchar2,
 WfItemKey      in varchar2,
 PersonId       in out nocopy varchar2,
 AssignmentId   in out nocopy varchar2,
 p_error_message                 out nocopy    long) is

  l_person_id number;

  cursor csr_person is select person_id,person_type_id from per_all_people_f where person_id = l_person_id
  and CURRENT_EMP_OR_APL_FLAG = 'Y';


  l_newUserPersonId per_all_people_f.person_id%type;
  l_person_type_id number;
  l_object_version_number number;
  l_asg_object_version_number         number;
  l_per_effective_start_date          date;
  l_per_effective_end_date            date;
  l_assignment_sequence               number;
  l_assignment_number                 varchar2(250);
  l_assign_payroll_warning            boolean;
  l_proc varchar2(72)  := g_package||'processExEmpTransaction';
  l_transaction_id      hr_api_transactions.transaction_id%type;
  l_date Date;
begin
hr_utility.set_location('Entering:'|| l_proc, 5);
l_person_id := PersonId;
l_date := to_date(wf_engine.GetItemAttrText(WfItemType,WfItemKey,'P_EFFECTIVE_DATE'),'RRRR-MM-DD');
l_date := nvl(l_date,trunc(sysdate));
open csr_person;
fetch csr_person into l_newUserPersonId,l_person_type_id;

l_transaction_id := hr_transaction_ss.get_transaction_id
                         (p_item_type => WfItemType
                         ,p_item_key  => WfItemKey);

  if l_transaction_id is null then
    begin
     savepoint ex_emp_process;
     if csr_person%found then
    	begin
	  select max(object_version_number) into l_object_version_number from per_all_people_f
	  where person_id = l_person_id;
        exception
	when others then
	null;
	end;
        hr_employee_api.re_hire_ex_employee
		(p_validate                     => false
		,p_hire_date                    => l_date
		,p_person_id                    => l_person_id
		,p_per_object_version_number    => l_object_version_number
		,p_person_type_id               => l_person_type_id
		,p_rehire_reason                => null
		,p_assignment_id                => AssignmentId
		,p_asg_object_version_number    => l_asg_object_version_number
		,p_per_effective_start_date     => l_per_effective_start_date
		,p_per_effective_end_date       => l_per_effective_end_date
		,p_assignment_sequence          => l_assignment_sequence
		,p_assignment_number            => l_assignment_number
		,p_assign_payroll_warning       => l_assign_payroll_warning
		 );
     end if;
    PersonId := to_char(l_person_id);
    AssignmentId := to_char(AssignmentId);
    rollback to ex_emp_process;
   EXCEPTION
	WHEN OTHERS THEN
	hr_utility.set_location('Exception:'|| l_proc, 10);
  	PersonId := null;
  	AssignmentId := null;
	p_error_message := hr_utility.get_message;
	rollback to ex_emp_process;
    end;
    else
    process_selected_transaction
		(p_item_type => WfItemType,
 		p_item_key => WfItemKey);
    PersonId := to_char(hr_process_person_ss.g_person_id);
    AssignmentId := to_char(hr_process_person_ss.g_assignment_id);

end if;
close csr_person;

hr_utility.set_location('Leaving:'|| l_proc, 10);
EXCEPTION
WHEN OTHERS THEN
hr_utility.set_location('Exception:'|| l_proc, 10);
  PersonId := null;
  AssignmentId := null;
p_error_message := hr_utility.get_message;

end processExEmpTransaction;

end hr_new_user_reg_ss;

/
