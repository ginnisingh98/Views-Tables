--------------------------------------------------------
--  DDL for Package Body HR_TERMINATION_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TERMINATION_SS" AS
/* $Header: hrtrmwrs.pkb 120.2.12010000.5 2010/01/29 09:46:06 gpurohit ship $ */

  -- Package scope global variables.
  -- The canonical date format has to use hyphens instead of slashes, ie.
  -- "RRRR/MM/DD" will give a java IllegalArgument error because the java
  -- dateValue() is expecting the date string in "rrrr-mm-dd" format.
  -- All date fields are converted to canonical date formats and return to
  -- the java caller.
  g_date_format  constant varchar2(10):='RRRR-MM-DD';
  g_package      constant varchar2(30) := 'HR_TERMINATION_SS';


/*
  ||===========================================================================
  || FUNCTION: update_object_version
  || DESCRIPTION: Update the object version number in the transaction step
  ||              to pass the invalid object api error for Save for Later.
  ||=======================================================================
  */
  PROCEDURE update_object_version
  (p_transaction_step_id in     number
  ,p_login_person_id in number) IS


    CURSOR csr_new_object_number(p_period_of_service_id in number) is
    SELECT object_version_number
    FROM   per_periods_of_service   pps
    where  period_of_service_id = p_period_of_service_id;

    ln_old_object_number         number;
    ln_period_of_service_id      number;
    ln_new_object_number         number;
l_proc constant varchar2(100) := g_package || ' update_object_version';
  BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);
    ln_period_of_service_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'P_PERIOD_OF_SERVICE_ID');


    OPEN csr_new_object_number(ln_period_of_service_id);
    FETCH csr_new_object_number into ln_new_object_number;
    CLOSE csr_new_object_number;

    ln_old_object_number :=
       hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'P_OBJECT_VERSION_NUMBER');

  IF ln_old_object_number <> ln_new_object_number then
    hr_transaction_api.set_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_person_id           => p_login_person_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER'
    ,p_value               => ln_new_object_number);
  END IF;

hr_utility.set_location('Leaving: '|| l_proc,10);
  END update_object_version;

  -- Bug 2098595 Fix Ends
  --
  -- Core HR API will not support update of field Rehire Recommendation
  -- and Rehire Reason. Hence we make following call to Person API
  -- to update the Fields.
PROCEDURE  update_per_details(
     p_validate                      in     number  default 0
    ,p_effective_date                in     date
    ,p_period_of_service_id          in     number
    ,p_actual_termination_date       in     date
    ,p_rehire_recommendation         in     varchar2 default hr_api.g_varchar2
    ,p_rehire_reason                 in     varchar2 default hr_api.g_varchar2
  )  IS

  l_person_id                   per_all_people_f.person_id%TYPE;
  l_per_object_version_number   per_all_people_f.object_version_number%TYPE;
  l_employee_number             per_all_people_f.employee_number%TYPE;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_full_name                   per_all_people_f.full_name%TYPE;
  l_comment_id                  per_all_people_f.comment_id%TYPE;
  l_name_combination_warning    boolean;
  l_assign_payroll_warning      boolean;
  l_orig_hire_warning           boolean;
  l_proc    varchar2(100) := g_package ||'update_per_details';

  l_err_msg                     long default null;

  cursor csr_get_derived_details is
    select per.person_id
         , per.employee_number
         , per.object_version_number
      from per_all_people_f       per
         , per_business_groups    bus
         , per_periods_of_service pds
         , per_person_types       pet
     where pds.period_of_service_id  = p_period_of_service_id
     and   bus.business_group_id     = pds.business_group_id
     and   per.person_id             = pds.person_id
     and   p_actual_termination_date + 1 between per.effective_start_date
                                     and     per.effective_end_date
     and   pet.person_type_id        = per.person_type_id;

     l_validate boolean;

  BEGIN

    SAVEPOINT update_person_details;
    open  csr_get_derived_details;
    fetch csr_get_derived_details
       into l_person_id
          , l_employee_number
          , l_per_object_version_number;

    l_validate := hr_java_conv_util_ss.get_boolean (p_number => p_validate);
    -- The Transaction mode will be UPDATE as per the rehire tab in people form.

    hr_person_api.update_person (
       p_validate                     => l_validate
      ,p_effective_date               => p_effective_date + 1
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_person_id                    => l_person_id
      ,p_object_version_number        => l_per_object_version_number
      ,p_employee_number              => l_employee_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_rehire_recommendation        => p_rehire_recommendation
      ,p_rehire_reason                => p_rehire_reason
      ,p_full_name                    => l_full_name
      ,p_comment_id                   => l_comment_id
      ,p_name_combination_warning     => l_name_combination_warning
      ,p_assign_payroll_warning       => l_assign_payroll_warning
      ,p_orig_hire_warning            => l_orig_hire_warning
    );

    IF l_validate THEN
        ROLLBACK TO update_person_details;
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
      l_err_msg := hr_java_conv_util_ss.get_formatted_error_message
                        (p_single_error_message => hr_utility.get_message);
      hr_utility.set_location('EXCEPTION '|| l_err_msg || ': '|| l_proc,560);
      rollback TO update_person_details;
      raise;
  END update_per_details;


  /*
  ||=======================================================================
  || FUNCTION    : get_termination_details  - Private
  || DESCRIPTION : This overloaded funciton return the  termination related
  ||               information by given transaction_step_id.
  ||=======================================================================
  */
  FUNCTION get_termination_details (
    p_transaction_step_id IN
      hr_api_transaction_steps.transaction_step_id%type
  )
  RETURN hr_termination_ss.rt_termination;

  /*
  ||=======================================================================
  || FUNCTION:    get_term_flex_detail   - Private
  || DESCRIPTION: This function returns termination dff data by
  ||              transaction step id.
  ||=======================================================================
  */
  FUNCTION get_term_flex_detail (
    p_transaction_step_id IN
      hr_api_transaction_steps.transaction_step_id%type
  )
  RETURN hr_termination_ss.t_flex_table;

  /*
  ||===========================================================================
  || FUNCTION: branch_on_subordinate_presence
  || DESCRIPTION:
  ||        This procedure will read the CURRENT_PERSON_ID item level
  ||        attribute value and then find out if the employee to be terminated
  ||        has any subordinates or not.  If he has, this procedure will set
  ||        the wf result code to "Y".  So, workflow will transition to the
  ||        Supevisor page accordingly.
  ||        This procedure will set the wf transition code as follows:
  ||          (Y/N)
  ||          For 'Y'    => branch to Supervisor page
  ||              'N'    => do not branch to Supervisor page
  ||=======================================================================
  */
PROCEDURE branch_on_subordinate_presence
 (itemtype     in     varchar2
  ,itemkey     in     varchar2
  ,actid       in     number
  ,funcmode    in     varchar2
  ,resultout   out nocopy varchar2)
IS

  l_text_value            wf_item_attribute_values.text_value%type;
  l_number_value          wf_item_attribute_values.number_value%type;
  l_asg_number_value      wf_item_attribute_values.number_value%type;
  l_effective_date        date;
  l_person_id             number default null;
  l_proc constant varchar2(100) := g_package || 'branch_on_subordinate_presence';

 dummy		varchar2(2);
 l_term_sec_asg	varchar2(2);

 dummy_2		varchar2(2);
 l_vol_term		varchar2(6);

  ----------------------------------------------------------------------------
  -- Bug 2130066 Fix Begins:
  -- When a Supervisor Security profile is defined with a restrictions to n
  -- number of levels, this cursor will not return any row if the employee to
  -- terminated has subordinates beyond the n number of levels.
  -- For example, Employee 1 (a supervisor with a Supervisor Security profile
  -- set up to have the maximum hierarchy level = 1, that means the profile
  -- will only show 1 level of subordinates) is a supervisor, he has Employee 2
  -- as the subordinate.  In SSHR hierarchy tree, Employee 2 is shown.
  -- Employee 2 himself also has subordinates reporting to him, say Employee 3.
  -- But in SSHR hierarchy tree, Employee 3 is not listed because of the
  -- maximum hierarchy level in the Supervisor Security Profile.  When Employee
  -- 1 selects to terminate Employee 2, the following cursor will not return
  -- rows for Employee 2.  I believe the hr security view uses the Supervisor's
  -- person list to run the query.  In this case, Employee 3 is beyong the
  -- level specified, thus no rows returned.
  -- Changed the cursor to use base table so that it will return rows regardless
  -- of maximum hierarchy level specified in the Supervisor Security profile.
  ----------------------------------------------------------------------------
  CURSOR csr_get_subordinate IS
  SELECT ppf.person_id
  FROM   per_all_people_f        ppf        -- Bug 2130066 fix
        ,per_all_assignments_f   paf
        ,per_periods_of_service  ppos
  WHERE  paf.supervisor_id = l_number_value
  AND    paf.person_id = ppf.person_id
  AND    ppf.person_id = ppos.person_id
  AND    ppf.current_employee_flag = 'Y'
  AND    l_effective_date between ppf.effective_start_date
                          and     ppf.effective_end_date
--  AND    paf.primary_flag = 'Y' -- commented to support multiple assignments
  AND    paf.assignment_type = 'E'
  AND    l_effective_date between paf.effective_start_date
                          and     paf.effective_end_date
  AND    l_effective_date between ppos.date_start
                          and nvl(ppos.actual_termination_date
                                 ,l_effective_date)
  and ((dummy = 'N' and paf.supervisor_assignment_id=l_asg_number_value)
              OR dummy = 'Y')
  UNION          -- CWK Phase III Changes.
  SELECT ppf.person_id
  FROM   per_all_people_f        ppf        -- Bug 2130066 fix
        ,per_all_assignments_f   paf
        ,per_periods_of_placement  ppop
  WHERE  paf.supervisor_id = l_number_value
  AND    paf.person_id = ppf.person_id
  AND    ppf.person_id = ppop.person_id
  AND    ppf.current_npw_flag = 'Y'
  AND    l_effective_date between ppf.effective_start_date
                          and     ppf.effective_end_date
--  AND    paf.primary_flag = 'Y' -- commented to support multiple assignments
  AND    paf.assignment_type = 'C'
  AND    l_effective_date between paf.effective_start_date
                          and     paf.effective_end_date
  AND    l_effective_date between ppop.date_start
                          and nvl(ppop.actual_termination_date
                                 ,l_effective_date)
  and ((dummy = 'N' and paf.supervisor_assignment_id=l_asg_number_value)
              OR dummy = 'Y');

   cursor csr_attr_value(actid in number, name in varchar2) is
	SELECT WAAV.TEXT_VALUE Value
	FROM WF_ACTIVITY_ATTR_VALUES WAAV
	WHERE WAAV.PROCESS_ACTIVITY_ID = actid
	AND WAAV.NAME = name;

BEGIN
--
hr_utility.set_location('Entering: '|| l_proc,5);
  l_number_value := wf_engine.GetItemAttrNumber
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,aname    => 'CURRENT_PERSON_ID');

  -- The termination effective date was stored in the wf item attribute
  -- P_EFFECTIVE_DATE as a text value in the canonical format, ie. 'RRRR/MM/DD'.
  l_text_value := wf_engine.GetItemAttrText
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,aname    => 'P_EFFECTIVE_DATE');

  --
  -- Now convert the text value date to date data type
  -- Bug 2476134 - 07/29/2002
  -- Changed the <> null to IS NOT NULL.
  IF l_text_value IS NOT NULL
  THEN
  hr_utility.trace('In (if l_text_value IS NOT NULL): '|| l_proc);
     l_effective_date := trunc(
                         to_date(l_text_value, hr_transaction_ss.g_date_format)
                         );
  ELSE
  hr_utility.trace('In else of (if l_text_value IS NOT NULL): '|| l_proc);
     -- Use sysdate if the wf item attribute contains null value
     l_effective_date := trunc(sysdate);
  END IF;

  l_asg_number_value := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CURRENT_ASSIGNMENT_ID');

select primary_flag into dummy from per_all_assignments_f
where assignment_id=l_asg_number_value and l_effective_date between effective_start_date
and effective_end_date;

l_term_sec_asg := wf_engine.getitemattrtext(itemtype, itemkey,
                                                'HR_TERM_SEC_ASG',true);

if (l_term_sec_asg is null OR l_term_sec_asg <> 'Y') then
  dummy := 'Y';
end if;

   if (l_number_value = fnd_global.employee_id) then
      l_vol_term := wf_engine.getitemattrtext(itemtype, itemkey,
                                                		'HR_VOL_TERM_SS',true);
      if (l_vol_term is not null) then
         open csr_attr_value(actid,'BYPASS_CHG_MGR');
         fetch csr_attr_value into dummy_2;
         close  csr_attr_value;
      end if;
   end if;

  OPEN csr_get_subordinate;
  FETCH csr_get_subordinate into l_person_id;

  IF csr_get_subordinate%NOTFOUND
  THEN
     -- no subordinates, then set the result code to 'N'
     resultout := 'COMPLETE:'|| 'N';
  ELSIF (dummy_2 = 'Y') then
     resultout := 'COMPLETE:'|| 'N';
     if (l_vol_term = 'CCMGR') then
        wf_engine.setitemattrtext(itemtype,itemkey,'HR_VOL_TERM_SS','BOTH');
     elsif (l_vol_term = 'Y') then
        wf_engine.setitemattrtext(itemtype,itemkey,'HR_VOL_TERM_SS','SUP');
     end if;
  ELSE
     resultout := 'COMPLETE:'|| 'Y';
  END IF;
  --
  CLOSE csr_get_subordinate;

  -- 08/07/01 Bug 1853417 Fix:
  -- Need to set the wf item attribute HR_TERM_SUP_FLAG so that the Supervisor
  -- page knows that the caller is from Termination.
  -- NOTE: The HR_TERM_SUP_FLAG attribute is not used for determining whether
  --       to branch to the Supervisor page or not.
  wf_engine.SetItemAttrText
                (itemtype => itemtype
                ,itemkey  => itemkey
                ,aname    => 'HR_TERM_SUP_FLAG'
                ,avalue   => 'Y');
--
hr_utility.set_location('Leaving: '|| l_proc,15);

EXCEPTION
  WHEN OTHERS THEN
    resultout := null;
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    WF_CORE.CONTEXT(g_package
                   ,'branch_on_subordinate_presence'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    RAISE;
end branch_on_subordinate_presence;
--
--
  /*
  ||===========================================================================
  || PROCEDURE: actual_termination_emp
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_ex_employee_api.actual_termination_emp
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see peexeapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE actual_termination_emp
    (p_validate                      in     number  default 0
    ,p_effective_date                in     date
    ,p_period_of_service_id          in     number
    ,p_object_version_number         in out nocopy number
    ,p_actual_termination_date       in     date
    ,p_last_standard_process_date    in out nocopy date
    ,p_person_type_id                in     number   default hr_api.g_number
    ,p_assignment_status_type_id     in     number   default hr_api.g_number
    ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
    ,p_rehire_recommendation         in     varchar2 default hr_api.g_varchar2
    ,p_rehire_reason                 in     varchar2 default hr_api.g_varchar2
    ,p_termination_accepted_person   in     number   default hr_api.g_number
    ,p_accepted_termination_date     in     date     default hr_api.g_date
    ,p_comments                      in     varchar2 default hr_api.g_varchar2
    ,p_notified_termination_date     in     date     default hr_api.g_date
    ,p_projected_termination_date    in     date     default hr_api.g_date
    ,p_final_process_date            in out nocopy date
    ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
    ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
    ,p_pds_information_category      in     varchar2 default hr_api.g_varchar2
    ,p_pds_information1              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information2              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information3              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information4              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information5              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information6              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information7              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information8              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information9              in     varchar2 default hr_api.g_varchar2
    ,p_pds_information10             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information11             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information12             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information13             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information14             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information15             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information16             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information17             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information18             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information19             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information20             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information21             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information22             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information23             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information24             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information25             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information26             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information27             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information28             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information29             in     varchar2 default hr_api.g_varchar2
    ,p_pds_information30             in     varchar2 default hr_api.g_varchar2
    ,p_supervisor_warning            out nocopy    number
    ,p_event_warning                 out nocopy    number
    ,p_interview_warning             out nocopy    number
    ,p_review_warning                out nocopy    number
    ,p_recruiter_warning             out nocopy    number
    ,p_asg_future_changes_warning    out nocopy    number
    ,p_entries_changed_warning       out nocopy    varchar2
    ,p_pay_proposal_warning          out nocopy    number
    ,p_dod_warning                   out nocopy    number
    ,p_error_message                 out nocopy    long
  )
  IS

    lb_supervisor_warning         BOOLEAN;
    lb_event_warning              BOOLEAN;
    lb_interview_warning          BOOLEAN;
    lb_review_warning             BOOLEAN;
    lb_recruiter_warning          BOOLEAN;
    lb_asg_future_changes_warning BOOLEAN;
    lb_pay_proposal_warning       BOOLEAN;
    lb_dod_warning                BOOLEAN;

    l_proc    varchar2(100) := g_package ||'actual_termination_emp';

    l_err_msg                     long default null;
    actual_term_emp_err           exception;
    update_pds_details_err        exception;
    fr_localization_err           exception;

    -- Added for FR localization bug 2881583
    l_pds_information10 varchar2(150);
    l_business_group_id number;
    l_legislation_code varchar2(30);
    l_pds_information_category varchar2(30);

    --set outparameter for final_process_emp
    l_org_now_no_manager_warning boolean;
    l_entries_changed_warning varchar2(1);
    l_final_process_date date;
    l_asg_future_changes_warning boolean;

  BEGIN


    hr_utility.set_location('Entering: ' || l_proc,5);

    -- Bug 2098595 Fix Begins: 12/03/2001
    -- Need to switch the order of calling the api.  We need to call
    -- hr_termination_ss.update_pds_details first to set the flex segments
    -- before calling hr_ex_employee_api.actual_termination_emp.
    -- Otherwise, when there is a mandatory segment, we'll get an error
    -- as follows:
    -- The mandatory column Attribute??(also known as xxxx) has not been
    -- assigned a value.
    -- The reason is because in hr_ex_employee_api.actual_termination_emp,
    -- it validates flex segments and there are no parameters to receive
    -- flex segments in hr_ex_employee_api.actual_termination_emp.  So, we
    -- need to flip the order to set the value of flex segments.
    -- Call update_pds_details;
    --
    -- Need to set a savepoint.  Call update_pds_details and
    -- actual_termination_emp with p_validate = false.  Rollback changes
    -- if the passed in parameter p_validate = true.


      SAVEPOINT terminate_ee;
      -- Set p_validate to false to commit the desc flex segments, especially
      -- the mandatory segments to avoid the following error issued by
      -- hr_ex_employee_api.actual_termination_emp.
      -- The mandatory column Attribute??(also known as xxxx) has not been
      -- assigned a value.

--------------------------------------------------------------
-- Bug 2881583
-- Determine whether legislation code is FR. If so the default the
-- PDS_INFORMATION10 to Actual Termination Date.
-- This is required for compatibility with code delivered in FP.D
--
-- N.B. Local variable l_pds_information10 declared at
-- top of procedure
-- Also l_pds_information10 used in call to
-- hr_termination_ss.update_pds_details below
--------------------------------------------------------------
      l_pds_information10 := p_pds_information10;
      l_pds_information_category := p_pds_information_category;

        select business_group_id
          into l_business_group_id
          from per_periods_of_service
         where period_of_service_id = p_period_of_service_id;

        hr_utility.trace('checking FR legislation ' || l_proc);
        --
        l_legislation_code :=
         hr_api.return_legislation_code(p_business_group_id => l_business_group_id);
        --
        if l_legislation_code = 'FR' then
          if p_actual_termination_date is not null and
           (p_pds_information10 = hr_api.g_varchar2
           or p_pds_information10 is null ) then
             l_pds_information10
                := fnd_date.date_to_canonical(p_actual_termination_date);
             l_pds_information_category := l_legislation_code;
          end if;
        end if;
--

      hr_utility.trace('Calling hr_termination_ss.update_pds_details ' || l_proc);
      hr_termination_ss.update_pds_details
        (p_validate                    => 0
        ,p_effective_date              => p_effective_date
        ,p_period_of_service_id        => p_period_of_service_id
        ,p_termination_accepted_person => p_termination_accepted_person
        ,p_accepted_termination_date   => p_accepted_termination_date
        ,p_object_version_number       => p_object_version_number
        ,p_comments                    => p_comments
        ,p_leaving_reason              => p_leaving_reason
        ,p_notified_termination_date   => p_notified_termination_date
        ,p_projected_termination_date  => p_projected_termination_date
        ,p_attribute_category          => p_attribute_category
        ,p_attribute1                  => p_attribute1
        ,p_attribute2                  => p_attribute2
        ,p_attribute3                  => p_attribute3
        ,p_attribute4                  => p_attribute4
        ,p_attribute5                  => p_attribute5
        ,p_attribute6                  => p_attribute6
        ,p_attribute7                  => p_attribute7
        ,p_attribute8                  => p_attribute8
        ,p_attribute9                  => p_attribute9
        ,p_attribute10                 => p_attribute10
        ,p_attribute11                 => p_attribute11
        ,p_attribute12                 => p_attribute12
        ,p_attribute13                 => p_attribute13
        ,p_attribute14                 => p_attribute14
        ,p_attribute15                 => p_attribute15
        ,p_attribute16                 => p_attribute16
        ,p_attribute17                 => p_attribute17
        ,p_attribute18                 => p_attribute18
        ,p_attribute19                 => p_attribute19
        ,p_attribute20                 => p_attribute20
        ,p_pds_information_category    => l_pds_information_category -- bug 2881583
        ,p_pds_information1            => p_pds_information1
        ,p_pds_information2            => p_pds_information2
        ,p_pds_information3            => p_pds_information3
        ,p_pds_information4            => p_pds_information4
        ,p_pds_information5            => p_pds_information5
        ,p_pds_information6            => p_pds_information6
        ,p_pds_information7            => p_pds_information7
        ,p_pds_information8            => p_pds_information8
        ,p_pds_information9            => p_pds_information9
        ,p_pds_information10           => l_pds_information10 -- bug 2881583
        ,p_pds_information11           => p_pds_information11
        ,p_pds_information12           => p_pds_information12
        ,p_pds_information13           => p_pds_information13
        ,p_pds_information14           => p_pds_information14
        ,p_pds_information15           => p_pds_information15
        ,p_pds_information16           => p_pds_information16
        ,p_pds_information17           => p_pds_information17
        ,p_pds_information18           => p_pds_information18
        ,p_pds_information19           => p_pds_information19
        ,p_pds_information20           => p_pds_information20
        ,p_pds_information21           => p_pds_information21
        ,p_pds_information22           => p_pds_information22
        ,p_pds_information23           => p_pds_information23
        ,p_pds_information24           => p_pds_information24
        ,p_pds_information25           => p_pds_information25
        ,p_pds_information26           => p_pds_information26
        ,p_pds_information27           => p_pds_information27
        ,p_pds_information28           => p_pds_information28
        ,p_pds_information29           => p_pds_information29
        ,p_pds_information30           => p_pds_information30
      );


    -- Now actually call API
    hr_utility.trace('Calling hr_ex_employee_api.actual_termination_emp ' || l_proc);

    hr_ex_employee_api.actual_termination_emp
       (p_validate                   => false
       ,p_effective_date             =>  p_effective_date
       ,p_period_of_service_id       =>  p_period_of_service_id
       ,p_object_version_number      =>  p_object_version_number
       ,p_actual_termination_date    =>  p_actual_termination_date
       ,p_last_standard_process_date =>  p_last_standard_process_date
       ,p_person_type_id             =>  p_person_type_id
       ,p_assignment_status_type_id  =>  p_assignment_status_type_id
       ,p_leaving_reason             =>  p_leaving_reason
--       ,p_rehire_recommendation      =>  p_rehire_recommendation
--       ,p_rehire_reason              =>  p_rehire_reason
       ,p_supervisor_warning         =>  lb_supervisor_warning
       ,p_event_warning              =>  lb_event_warning
       ,p_interview_warning          =>  lb_interview_warning
       ,p_review_warning             =>  lb_review_warning
       ,p_recruiter_warning          =>  lb_recruiter_warning
       ,p_asg_future_changes_warning =>  lb_asg_future_changes_warning
       ,p_entries_changed_warning    =>  p_entries_changed_warning
       ,p_pay_proposal_warning       =>  lb_pay_proposal_warning
       ,p_dod_warning                =>  lb_dod_warning);


    p_supervisor_warning         :=
        hr_java_conv_util_ss.get_number(p_boolean => lb_supervisor_warning);
    p_event_warning              :=
        hr_java_conv_util_ss.get_number(p_boolean => lb_event_warning);
    p_interview_warning          :=
        hr_java_conv_util_ss.get_number(p_boolean => lb_interview_warning);
    p_review_warning             :=
        hr_java_conv_util_ss.get_number(p_boolean => lb_review_warning);
    p_recruiter_warning          :=
        hr_java_conv_util_ss.get_number(p_boolean => lb_recruiter_warning);
    p_asg_future_changes_warning :=
    hr_java_conv_util_ss.get_number(p_boolean => lb_asg_future_changes_warning);
    p_pay_proposal_warning       :=
        hr_java_conv_util_ss.get_number(p_boolean => lb_pay_proposal_warning);
    p_dod_warning                :=
        hr_java_conv_util_ss.get_number(p_boolean => lb_dod_warning);

    -- Bug 2098595 Fix Ends
    --
    -- Core HR API will not support update of field Rehire Recommendation
    -- and Rehire Reason. Hence we make following call to Person API
    -- to update the Fields.
    hr_utility.trace('Calling hr_termination_ss.update_per_details ' || l_proc);
    -- moved cursor definitions to new procedure , which can be called from
    -- proces_api also.
    update_per_details(
        p_validate                   => 0,  -- false
        p_effective_date             => p_effective_date,
        p_period_of_service_id       => p_period_of_service_id,
        p_actual_termination_date    => p_actual_termination_date,
        p_rehire_recommendation      => p_rehire_recommendation,
        p_rehire_reason              => p_rehire_reason);

    --call for Final_emp_process
    l_entries_changed_warning := 'N';
    l_final_process_date := p_final_process_date;

    IF l_final_process_date IS NOT NULL
    THEN
     hr_ex_employee_api.final_process_emp(
        p_validate                   => false,
        p_period_of_service_id       => p_period_of_service_id,
        p_object_version_number      => p_object_version_number,
        p_final_process_date         => l_final_process_date,
        p_org_now_no_manager_warning => l_org_now_no_manager_warning,
        p_asg_future_changes_warning => l_asg_future_changes_warning,
        p_entries_changed_warning    => l_entries_changed_warning );
   END IF;

    --end of call Final-emp_process

    IF hr_java_conv_util_ss.get_boolean (p_number => p_validate)
    THEN
       -- validate mode is true, rollback all the changes
       rollback to terminate_ee;
    END IF;
    --
    --

    hr_utility.set_location(' Leaving: ' || l_proc,10);
  EXCEPTION

    WHEN OTHERS THEN


      -- Call the hr_java_conv_util_ss to strip off the unfriendly error
      -- message.
      -- For example:
      --  "Error: java.sql.SQLExcpetion: ORA-01400: cannot insert NULL into
      --  ("HR"."PER_PERSON_LIST_CHANGES"."SECURITY_PROFILE_ID").  ORA-06512:
      --  at "APPS.HR_TERMINATION_SS", line xxx ORA-06512: at line 1.
      -- With the call to hr_java_conv_util_ss, the error message text will
      -- become:
      --  "Error: ORA-01400: cannot insert NULL into
      --  ("HR"."PER_PERSON_LIST_CHANGES"."SECURITY_PROFILE_ID").


      p_error_message := hr_java_conv_util_ss.get_formatted_error_message
                        (p_single_error_message => hr_utility.get_message);
      hr_utility.set_location('EXCEPTION '|| p_error_message|| ' :' ||  l_proc,575);
      -- rollback the changes in case of exception
      rollback to terminate_ee;
      p_supervisor_warning   := null;
      p_event_warning        := null;
      p_interview_warning    := null;
      p_review_warning       := null;
      p_recruiter_warning    := null;
      p_asg_future_changes_warning  := null;
      p_pay_proposal_warning  := null;
      p_dod_warning           := null;

  END actual_termination_emp;

  /*
  ||===========================================================================
  || PROCEDURE: update_pds_details
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_periods_of_service_api.update_pds_details
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pepdsapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE update_pds_details
    (p_validate                      in     number  default 0
    ,p_effective_date                in     date
    ,p_period_of_service_id          in     number
    ,p_termination_accepted_person   in     number   default hr_api.g_number
    ,p_accepted_termination_date     in     date     default hr_api.g_date
    ,p_object_version_number         in out nocopy number
    ,p_comments                      in     varchar2 default hr_api.g_varchar2
    ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
    ,p_notified_termination_date     in     date     default hr_api.g_date
    ,p_projected_termination_date    in     date     default hr_api.g_date
    ,p_attribute_category            in varchar2     default hr_api.g_varchar2
    ,p_attribute1                    in varchar2     default hr_api.g_varchar2
    ,p_attribute2                    in varchar2     default hr_api.g_varchar2
    ,p_attribute3                    in varchar2     default hr_api.g_varchar2
    ,p_attribute4                    in varchar2     default hr_api.g_varchar2
    ,p_attribute5                    in varchar2     default hr_api.g_varchar2
    ,p_attribute6                    in varchar2     default hr_api.g_varchar2
    ,p_attribute7                    in varchar2     default hr_api.g_varchar2
    ,p_attribute8                    in varchar2     default hr_api.g_varchar2
    ,p_attribute9                    in varchar2     default hr_api.g_varchar2
    ,p_attribute10                   in varchar2     default hr_api.g_varchar2
    ,p_attribute11                   in varchar2     default hr_api.g_varchar2
    ,p_attribute12                   in varchar2     default hr_api.g_varchar2
    ,p_attribute13                   in varchar2     default hr_api.g_varchar2
    ,p_attribute14                   in varchar2     default hr_api.g_varchar2
    ,p_attribute15                   in varchar2     default hr_api.g_varchar2
    ,p_attribute16                   in varchar2     default hr_api.g_varchar2
    ,p_attribute17                   in varchar2     default hr_api.g_varchar2
    ,p_attribute18                   in varchar2     default hr_api.g_varchar2
    ,p_attribute19                   in varchar2     default hr_api.g_varchar2
    ,p_attribute20                   in varchar2     default hr_api.g_varchar2
    ,p_pds_information_category      in varchar2     default hr_api.g_varchar2
    ,p_pds_information1              in varchar2     default hr_api.g_varchar2
    ,p_pds_information2              in varchar2     default hr_api.g_varchar2
    ,p_pds_information3              in varchar2     default hr_api.g_varchar2
    ,p_pds_information4              in varchar2     default hr_api.g_varchar2
    ,p_pds_information5              in varchar2     default hr_api.g_varchar2
    ,p_pds_information6              in varchar2     default hr_api.g_varchar2
    ,p_pds_information7              in varchar2     default hr_api.g_varchar2
    ,p_pds_information8              in varchar2     default hr_api.g_varchar2
    ,p_pds_information9              in varchar2     default hr_api.g_varchar2
    ,p_pds_information10             in varchar2     default hr_api.g_varchar2
    ,p_pds_information11             in varchar2     default hr_api.g_varchar2
    ,p_pds_information12             in varchar2     default hr_api.g_varchar2
    ,p_pds_information13             in varchar2     default hr_api.g_varchar2
    ,p_pds_information14             in varchar2     default hr_api.g_varchar2
    ,p_pds_information15             in varchar2     default hr_api.g_varchar2
    ,p_pds_information16             in varchar2     default hr_api.g_varchar2
    ,p_pds_information17             in varchar2     default hr_api.g_varchar2
    ,p_pds_information18             in varchar2     default hr_api.g_varchar2
    ,p_pds_information19             in varchar2     default hr_api.g_varchar2
    ,p_pds_information20             in varchar2     default hr_api.g_varchar2
    ,p_pds_information21             in varchar2     default hr_api.g_varchar2
    ,p_pds_information22             in varchar2     default hr_api.g_varchar2
    ,p_pds_information23             in varchar2     default hr_api.g_varchar2
    ,p_pds_information24             in varchar2     default hr_api.g_varchar2
    ,p_pds_information25             in varchar2     default hr_api.g_varchar2
    ,p_pds_information26             in varchar2     default hr_api.g_varchar2
    ,p_pds_information27             in varchar2     default hr_api.g_varchar2
    ,p_pds_information28             in varchar2     default hr_api.g_varchar2
    ,p_pds_information29             in varchar2     default hr_api.g_varchar2
    ,p_pds_information30             in varchar2     default hr_api.g_varchar2
   )
IS
 l_proc constant varchar2(100) := g_package || ' update_pds_details';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
  -- Call Actual API
  hr_periods_of_service_api.update_pds_details
    (p_validate                     =>  hr_java_conv_util_ss.get_boolean (p_number => p_validate)
    ,p_effective_date               =>  p_effective_date
    ,p_period_of_service_id         =>  p_period_of_service_id
    ,p_termination_accepted_person  =>  p_termination_accepted_person
    ,p_accepted_termination_date    =>  p_accepted_termination_date
    ,p_object_version_number        =>  p_object_version_number
    ,p_comments                     =>  p_comments
    ,p_leaving_reason               =>  p_leaving_reason
    ,p_notified_termination_date    =>  p_notified_termination_date
    ,p_projected_termination_date   =>  p_projected_termination_date
    ,p_attribute_category           =>  p_attribute_category
    ,p_attribute1                   =>  p_attribute1
    ,p_attribute2                   =>  p_attribute2
    ,p_attribute3                   =>  p_attribute3
    ,p_attribute4                   =>  p_attribute4
    ,p_attribute5                   =>  p_attribute5
    ,p_attribute6                   =>  p_attribute6
    ,p_attribute7                   =>  p_attribute7
    ,p_attribute8                   =>  p_attribute8
    ,p_attribute9                   =>  p_attribute9
    ,p_attribute10                  =>  p_attribute10
    ,p_attribute11                  =>  p_attribute11
    ,p_attribute12                  =>  p_attribute12
    ,p_attribute13                  =>  p_attribute13
    ,p_attribute14                  =>  p_attribute14
    ,p_attribute15                  =>  p_attribute15
    ,p_attribute16                  =>  p_attribute16
    ,p_attribute17                  =>  p_attribute17
    ,p_attribute18                  =>  p_attribute18
    ,p_attribute19                  =>  p_attribute19
    ,p_attribute20                  =>  p_attribute20
    ,p_pds_information_category     =>  p_pds_information_category
    ,p_pds_information1             =>  p_pds_information1
    ,p_pds_information2             =>  p_pds_information2
    ,p_pds_information3             =>  p_pds_information3
    ,p_pds_information4             =>  p_pds_information4
    ,p_pds_information5             =>  p_pds_information5
    ,p_pds_information6             =>  p_pds_information6
    ,p_pds_information7             =>  p_pds_information7
    ,p_pds_information8             =>  p_pds_information8
    ,p_pds_information9             =>  p_pds_information9
    ,p_pds_information10            =>  p_pds_information10
    ,p_pds_information11            =>  p_pds_information11
    ,p_pds_information12            =>  p_pds_information12
    ,p_pds_information13            =>  p_pds_information13
    ,p_pds_information14            =>  p_pds_information14
    ,p_pds_information15            =>  p_pds_information15
    ,p_pds_information16            =>  p_pds_information16
    ,p_pds_information17            =>  p_pds_information17
    ,p_pds_information18            =>  p_pds_information18
    ,p_pds_information19            =>  p_pds_information19
    ,p_pds_information20            =>  p_pds_information20
    ,p_pds_information21            =>  p_pds_information21
    ,p_pds_information22            =>  p_pds_information22
    ,p_pds_information23            =>  p_pds_information23
    ,p_pds_information24            =>  p_pds_information24
    ,p_pds_information25            =>  p_pds_information25
    ,p_pds_information26            =>  p_pds_information26
    ,p_pds_information27            =>  p_pds_information27
    ,p_pds_information28            =>  p_pds_information28
    ,p_pds_information29            =>  p_pds_information29
    ,p_pds_information30            =>  p_pds_information30);

hr_utility.set_location('Leaving: '|| l_proc,10);


  EXCEPTION
    WHEN OTHERS THEN
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      RAISE;

  END update_pds_details;

  /*
  ||===========================================================================
  || PROCEDURE: process_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Save Termination Transaction to transaction table
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Transaction details that need to be saved to transaction table
  ||
  || out nocopy Arguments:
  ||     None.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Writes to transaction table
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */
  PROCEDURE process_save
    (p_item_type                     in     wf_items.item_type%TYPE
    ,p_item_key                      in     wf_items.item_key%TYPE
    ,p_actid                         in     varchar2
    ,p_effective_date                in     varchar2 default hr_api.g_varchar2
    ,p_period_of_service_id          in     varchar2 default hr_api.g_varchar2
    ,p_object_version_number         in     varchar2 default hr_api.g_varchar2
    ,p_actual_termination_date       in     varchar2 default hr_api.g_varchar2
    ,p_notified_termination_date     in     varchar2 default hr_api.g_varchar2
    ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
    ,p_comments                      in     varchar2 default hr_api.g_varchar2
    ,p_login_person_id               in     number
    ,p_person_id                     in     number
    ,p_attribute_category            in varchar2     default hr_api.g_varchar2
    ,p_attribute1                    in varchar2     default hr_api.g_varchar2
    ,p_attribute2                    in varchar2     default hr_api.g_varchar2
    ,p_attribute3                    in varchar2     default hr_api.g_varchar2
    ,p_attribute4                    in varchar2     default hr_api.g_varchar2
    ,p_attribute5                    in varchar2     default hr_api.g_varchar2
    ,p_attribute6                    in varchar2     default hr_api.g_varchar2
    ,p_attribute7                    in varchar2     default hr_api.g_varchar2
    ,p_attribute8                    in varchar2     default hr_api.g_varchar2
    ,p_attribute9                    in varchar2     default hr_api.g_varchar2
    ,p_attribute10                   in varchar2     default hr_api.g_varchar2
    ,p_attribute11                   in varchar2     default hr_api.g_varchar2
    ,p_attribute12                   in varchar2     default hr_api.g_varchar2
    ,p_attribute13                   in varchar2     default hr_api.g_varchar2
    ,p_attribute14                   in varchar2     default hr_api.g_varchar2
    ,p_attribute15                   in varchar2     default hr_api.g_varchar2
    ,p_attribute16                   in varchar2     default hr_api.g_varchar2
    ,p_attribute17                   in varchar2     default hr_api.g_varchar2
    ,p_attribute18                   in varchar2     default hr_api.g_varchar2
    ,p_attribute19                   in varchar2     default hr_api.g_varchar2
    ,p_attribute20                   in varchar2     default hr_api.g_varchar2
    ,p_review_proc_call              in varchar2     default hr_api.g_varchar2
    ,p_pds_information_category      in varchar2     default hr_api.g_varchar2
    ,p_pds_information1              in varchar2     default hr_api.g_varchar2
    ,p_pds_information2              in varchar2     default hr_api.g_varchar2
    ,p_pds_information3              in varchar2     default hr_api.g_varchar2
    ,p_pds_information4              in varchar2     default hr_api.g_varchar2
    ,p_pds_information5              in varchar2     default hr_api.g_varchar2
    ,p_pds_information6              in varchar2     default hr_api.g_varchar2
    ,p_pds_information7              in varchar2     default hr_api.g_varchar2
    ,p_pds_information8              in varchar2     default hr_api.g_varchar2
    ,p_pds_information9              in varchar2     default hr_api.g_varchar2
    ,p_pds_information10             in varchar2     default hr_api.g_varchar2
    ,p_pds_information11             in varchar2     default hr_api.g_varchar2
    ,p_pds_information12             in varchar2     default hr_api.g_varchar2
    ,p_pds_information13             in varchar2     default hr_api.g_varchar2
    ,p_pds_information14             in varchar2     default hr_api.g_varchar2
    ,p_pds_information15             in varchar2     default hr_api.g_varchar2
    ,p_pds_information16             in varchar2     default hr_api.g_varchar2
    ,p_pds_information17             in varchar2     default hr_api.g_varchar2
    ,p_pds_information18             in varchar2     default hr_api.g_varchar2
    ,p_pds_information19             in varchar2     default hr_api.g_varchar2
    ,p_pds_information20             in varchar2     default hr_api.g_varchar2
    ,p_pds_information21             in varchar2     default hr_api.g_varchar2
    ,p_pds_information22             in varchar2     default hr_api.g_varchar2
    ,p_pds_information23             in varchar2     default hr_api.g_varchar2
    ,p_pds_information24             in varchar2     default hr_api.g_varchar2
    ,p_pds_information25             in varchar2     default hr_api.g_varchar2
    ,p_pds_information26             in varchar2     default hr_api.g_varchar2
    ,p_pds_information27             in varchar2     default hr_api.g_varchar2
    ,p_pds_information28             in varchar2     default hr_api.g_varchar2
    ,p_pds_information29             in varchar2     default hr_api.g_varchar2
    ,p_pds_information30             in varchar2     default hr_api.g_varchar2
    ,p_person_type_id                in number       default hr_api.g_number
    ,p_assignment_status_type_id     in number       default hr_api.g_number
    ,p_effective_date_option         in varchar2     default hr_api.g_varchar2
    ,p_rehire_recommendation         in varchar2     default hr_api.g_varchar2
    ,p_rehire_reason                 in varchar2     default hr_api.g_varchar2
    ,p_last_standard_process_date    in varchar2     default hr_api.g_varchar2
    ,p_projected_termination_date    in varchar2     default hr_api.g_varchar2
    ,p_final_process_date            in varchar2     default hr_api.g_varchar2
  )

 IS

   li_count                  INTEGER ;
   lv_activity_name          wf_item_activity_statuses_v.activity_name%TYPE;
   ln_transaction_id         NUMBER;
   lv_result                 VARCHAR2(100);
   ln_ovn                    hr_api_transaction_steps.object_version_number%TYPE;
   ltt_trans_step_ids        hr_util_web.g_varchar2_tab_type;
   ln_transaction_step_id    hr_api_transaction_steps.transaction_step_id%TYPE;
   ltt_trans_obj_vers_num    hr_util_web.g_varchar2_tab_type;
   ln_trans_step_rows        NUMBER  default 0;
   ln_supervisor_count       NUMBER;
l_proc constant varchar2(100) := g_package || ' process_save';
 BEGIN

hr_utility.set_location('Entering: '|| l_proc,5);
    ----------------------------------------------------------------------
    -- Save data to transaction table.
    ----------------------------------------------------------------------

    li_count := 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ACTUAL_TERMINATION_DATE';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_actual_termination_date;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'DATE';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PERIOD_OF_SERVICE_ID';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_period_of_service_id;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'NUMBER';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PERSON_ID';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_person_id;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'NUMBER';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_OBJECT_VERSION_NUMBER';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_object_version_number;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'NUMBER';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_LEAVING_REASON';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_leaving_reason;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PERSON_TYPE_ID';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_person_type_id;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'NUMBER';

      li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ASSIGNMENT_STATUS_TYPE_ID';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_assignment_status_type_id;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'NUMBER';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_REHIRE_RECOMMENDATION';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_rehire_recommendation;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_REHIRE_REASON';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_rehire_reason;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_NOTIFIED_TERMINATION_DATE';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_notified_termination_date;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'DATE';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_LAST_STANDARD_PROCESS_DATE';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_last_standard_process_date;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'DATE';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PROJECTED_TERMINATION_DATE';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_projected_termination_date;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'DATE';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_FINAL_PROCESS_DATE';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_final_process_date;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'DATE';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_COMMENTS';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_comments;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    ----------------------------------------------------------------------
    -- DDF repeat 20 times
    ----------------------------------------------------------------------

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE_CATEGORY';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute_category;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE1';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE2';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute2;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE3';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute3;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE4';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute4;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE5';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute5;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE6';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute6;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE7';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute7;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE8';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute8;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE9';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute9;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE10';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute10;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE11';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute11;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE12';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute12;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE13';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute13;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

     li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE14';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute14;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE15';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute15;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE16';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute16;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

     li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE17';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute17;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE18';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute18;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE19';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute19;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ATTRIBUTE20';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_attribute20;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    ----------------------------------------------------------------------
    -- Store the activity internal name for this particular
    -- activity with other information.
    ----------------------------------------------------------------------
    lv_activity_name := hr_termination_ss.gv_TERMINATION_ACTIVITY_NAME;
    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_ACTIVITY_NAME';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := lv_activity_name;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    ----------------------------------------------------------------------
    -- Store the the Review Procedure Call and
    -- activity id with other information.
    ----------------------------------------------------------------------
    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_REVIEW_PROC_CALL';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_review_proc_call;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_REVIEW_ACTID';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_actid;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    ---------------------------------------------------------------------
    -- DDF Enhancement
    -- Store DDF Segments
    ---------------------------------------------------------------------

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION_CATEGORY';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information_category;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION1';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION2';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information2;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION3';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information3;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
      := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION4';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information4;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION5';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information5;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION6';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information6;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION7';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information7;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION8';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information8;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION9';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information9;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION10';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information10;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION11';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information11;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION12';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information12;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION13';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information13;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

     li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION14';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information14;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION15';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information15;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION16';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information16;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

     li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION17';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information17;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION18';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information18;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION19';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information19;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION20';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information20;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION21';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information21;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION22';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information22;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION23';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information23;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

     li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION24';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information24;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION25';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information25;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION26';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information26;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

     li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION27';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information27;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION28';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information28;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION29';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information29;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    hr_termination_ss.gtt_transaction_steps(li_count).param_name
      := 'P_PDS_INFORMATION30';
    hr_termination_ss.gtt_transaction_steps(li_count).param_value
      := p_pds_information30;
    hr_termination_ss.gtt_transaction_steps(li_count).param_data_type
        := 'VARCHAR2';
    ---------------------------------------------------------------------
    -- Check if there is already a transaction for this process?
    ---------------------------------------------------------------------
    ln_transaction_id := hr_transaction_ss.get_transaction_id (
                           p_Item_Type => p_item_type,
                           p_Item_Key  => p_item_key
                         );

    IF ln_transaction_id IS NULL
    THEN
       hr_utility.trace('In (iF ln_transaction_id IS NULL): '|| l_proc);
      -------------------------------------------------------------------
      -- Create a new transaction
      -------------------------------------------------------------------
      hr_transaction_ss.start_transaction (
        itemtype                => p_item_type,
        itemkey                 => p_item_key,
        actid                   => TO_NUMBER(p_actid),
        funmode                 => 'RUN',
        p_effective_date_option => p_effective_date_option,
        p_login_person_id       => p_login_person_id,
        result                  => lv_result
      );

      ln_transaction_id := hr_transaction_ss.get_transaction_id (
                             p_Item_Type => p_item_type,
                             p_Item_Key => p_item_key
                           );
    END IF;

    ---------------------------------------------------------------------
    -- There is already a transaction for this process.
    -- Retieve the transaction step for this current
    -- activity. We will update this transaction step with
    -- the new information.
    ---------------------------------------------------------------------
    hr_transaction_api.get_transaction_step_info (
      p_Item_Type             => p_item_type,
      p_Item_Key              => p_item_key,
      p_activity_id           => to_number(p_actid),
      p_transaction_step_id   => ltt_trans_step_ids,
      p_object_version_number => ltt_trans_obj_vers_num,
      p_rows                  => ln_trans_step_rows
    );

    IF ln_trans_step_rows < 1
    THEN
    hr_utility.trace('In (IF ln_trans_step_rows < 1): '|| l_proc);
      --------------------------------------------------------------------
      -- There is no transaction step for this transaction.
      -- Create a step within this new transaction
      --------------------------------------------------------------------
      hr_transaction_api.create_transaction_step (
        p_validate              => false,
        p_creator_person_id     => p_login_person_id,
        p_transaction_id        => ln_transaction_id,
        p_api_name              => g_package || '.PROCESS_API',
        p_Item_Type             => p_item_type,
        p_Item_Key              => p_item_key,
        p_activity_id           => TO_NUMBER(p_actid),
        p_transaction_step_id   => ln_transaction_step_id,
        p_object_version_number => ln_ovn
      );
    ELSE
    hr_utility.trace('In else of (IF ln_trans_step_rows < 1): '|| l_proc);
      --------------------------------------------------------------------
      -- There are transaction steps for this transaction.
      -- Get the Transaction Step ID for this activity.
      --------------------------------------------------------------------
      ln_transaction_step_id  :=
        hr_transaction_ss.get_activity_trans_step_id (
          p_activity_name     => lv_activity_name,
          p_trans_step_id_tbl => ltt_trans_step_ids
        );

    END IF;

    hr_transaction_ss.save_transaction_step (
      p_item_Type           => p_item_type,
      p_item_Key            => p_item_key,
      p_actid               => TO_NUMBER(p_actid),
      p_login_person_id     => p_login_person_id,
      p_transaction_step_id => ln_transaction_step_id,
      p_api_name            => 'hr_termination_ss.process_save',
      p_transaction_data    => hr_termination_ss.gtt_transaction_steps
    );

    -- 07/16/2001 Bug 1853417 Fix:
    -- The code to check for existence of subordinates for the
    -- terminated employee has been moved to the new procedure
    -- branch_on_subordinate_presence.

hr_utility.set_location('Leaving: '|| l_proc,20);
 EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     RAISE;  -- Raise error here relevant to the new tech stack.

 END process_save;

  /*
  ||=======================================================================
  || PROCEDURE   : process_api
  || DESCRIPTION : This procedure gets data stored in the transaction table
  ||             : and call the APIs in update mode
  ||=======================================================================
  */
  PROCEDURE process_api (
    p_validate            IN BOOLEAN DEFAULT FALSE,
    p_transaction_step_id IN NUMBER DEFAULT NULL,
    p_effective_date      IN VARCHAR2 DEFAULT NULL
  )
  IS
    lrt_termination hr_termination_ss.rt_termination;
    ld_actual_term_date
      per_periods_of_service.actual_termination_date%TYPE;
    lv_term_reason per_periods_of_service.leaving_reason%TYPE;
    ll_term_comments per_periods_of_service.comments%TYPE;
    ln_person_id per_all_people_f.person_id%TYPE;
    ln_period_of_service_id
      per_periods_of_service.period_of_service_id%TYPE;
    ln_object_version_number
      per_periods_of_service.object_version_number%TYPE;
    ------------------------------------------------------------------------
    -- out parameters required by API actual_termination_emp
    ------------------------------------------------------------------------
    ld_last_standard_process_date
      per_periods_of_service.last_standard_process_date%TYPE;
    ld_notified_term_date
      per_periods_of_service.notified_termination_date%TYPE;

    ld_projected_termination_date
      per_periods_of_service.projected_termination_date%TYPE;
    ld_final_process_date
      per_periods_of_service.final_process_date%TYPE;

    lb_supervisor_warning         BOOLEAN;
    lb_event_warning              BOOLEAN;
    lb_interview_warning          BOOLEAN;
    lb_review_warning             BOOLEAN;
    lb_recruiter_warning          BOOLEAN;
    lb_asg_future_changes_warning BOOLEAN;
    lv_entries_changed_warning    VARCHAR2(500);
    lb_pay_proposal_warning       BOOLEAN;
    lb_dod_warning                BOOLEAN;

    --DFF
    lt_term_flex hr_termination_ss.t_flex_table;
    lv_attribute_category         VARCHAR2(100);

    --DDF Enhancement
    lv_pds_information_category   VARCHAR2(100);

    -- For SAVE_FOR_LATER
    ld_effective_date             date default null;

    lv_person_type_id               per_person_types.person_type_id%TYPE;
    lv_assignment_status_type_id
        per_assignment_status_types.assignment_status_type_id%TYPE;
    lv_rehire_recommendation        per_all_people_f.rehire_recommendation%TYPE;
    lv_rehire_reason                per_all_people_f.rehire_reason%TYPE;

    l_proc    varchar2(100) := g_package ||'process_api';

    -- Added for FR localization bug 2881583
    l_business_group_id number;
    l_legislation_code varchar2(30);

    --set outparameter for final_process_emp
    l_org_now_no_manager_warning boolean;
    l_entries_changed_warning varchar2(1);
    l_asg_future_changes_warning boolean;

    -- to print the error message
    l_err_msg                     long default null;

  BEGIN

    hr_utility.set_location('Entering: ' || l_proc,5  );

    -- The following is for SAVE_FOR_LATER code change.
    -- 1)When the Action page re-launch a suspended workflow process, it does
    --   a validation by calling the process_api with the new user entered
    --   effective date.  Added a new parameter p_effective_date to this proc.
    --   If p_effective_date is not null, then use it as the effective date for
    --   api validation.
    -- 2)When the Action page re-launch a suspended workflow process, it
    --   allows user to enter a new effective date. We should not use the
    --   effective date that we saved in the transaction table.
    --   In process_api, if the p_effective_date parameter is null then use
    --   the workflow attribute P_EFFECTIVE_DATE as the effective date for api
    --   validation.
    --
    IF (p_effective_date is not null) THEN
       ld_effective_date:= to_date(p_effective_date,g_date_format);
    ELSE
       ld_effective_date:= to_date(
       hr_transaction_ss.get_wf_effective_date
          (p_transaction_step_id => p_transaction_step_id),g_date_format);
    END IF;

    savepoint ex_emp_savepoint;

    -----------------------------------------------------------------------
    -- get common data for APIs from transaction table
    -----------------------------------------------------------------------
    ln_period_of_service_id :=
      hr_transaction_api.get_number_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_PERIOD_OF_SERVICE_ID'
      );

    ln_object_version_number :=
      hr_transaction_api.get_number_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_OBJECT_VERSION_NUMBER'
      );

    lrt_termination := get_termination_details (
                         p_transaction_step_id => p_transaction_step_id
                       );

    ld_notified_term_date := lrt_termination.notified_termination_date;

    ld_projected_termination_date := lrt_termination.projected_termination_date;
    ld_final_process_date := lrt_termination.final_process_date;

    -- For SAVE_FOR_LATER, when a user launch a suspended process, he will have
    -- an opportunity to change to a new effective date.  Since the
    -- actual_termination_date is populated from the effective date, this field
    -- needs to use new effective date value instead of from transaction table.
    -- See SAVE_FOR_LATER comments above.
    ld_actual_term_date   := ld_effective_date;
    lv_term_reason        := lrt_termination.leaving_reason;
    ll_term_comments      := lrt_termination.comments;

    ld_last_standard_process_date := lrt_termination.last_standard_process_date;

    lv_person_type_id     := lrt_termination.person_type_id;
    lv_assignment_status_type_id
                    := lrt_termination.assignment_status_type_id;

    lv_rehire_recommendation := lrt_termination.rehire_recommendation;
    lv_rehire_reason := lrt_termination.rehire_reason;

    --------------------------------------------------------------------------
    -- get dff data for update_pds_details API
    -- DDF Enhancement, This Function will return DFF Data as well from 21-50
    --------------------------------------------------------------------------
    lt_term_flex := get_term_flex_detail (
                      p_transaction_step_id => p_transaction_step_id
                   );

    lv_attribute_category :=
      hr_transaction_api.get_varchar2_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_ATTRIBUTE_CATEGORY'
      );

    -- DDF Enhancement : Get PDS_INFORMATION_CATEGORY
    lv_pds_information_category :=
      hr_transaction_api.get_varchar2_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_PDS_INFORMATION_CATEGORY'
      );

--------------------------------------------------------------
-- Bug 2881583
-- Determine whether legislation code is FR. If so the default the
-- PDS_INFORMATION10 to Actual Termination Date.
-- This is required for compatibility with code delivered in FP.D
--------------------------------------------------------------
      begin
        select business_group_id
          into l_business_group_id
          from per_periods_of_service
         where period_of_service_id = ln_period_of_service_id;
        --
        l_legislation_code :=
         hr_api.return_legislation_code(p_business_group_id => l_business_group_id);
        --
        if l_legislation_code = 'FR' then
        hr_utility.trace('In if l_legislation_code = FR'|| l_proc);
          if ld_actual_term_date is not null and
           (lt_term_flex(30) = hr_api.g_varchar2
           or lt_term_flex(30) is null ) then
             lt_term_flex(30)
                := fnd_date.date_to_canonical(ld_actual_term_date);
             lv_pds_information_category := l_legislation_code;
          end if;
        end if;

      exception when others then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
      end;

    -- Bug 2098595 Fix Begins: 11/12/2001
    -- Need to switch the order of calling the api.  We need to call
    -- hr_termination_ss.update_pds_details first to set the flex segments
    -- before calling hr_ex_employee_api.actual_termination_emp.
    -- Otherwise, when there is a mandatory segment, we'll get an error
    -- as follows:
    -- The mandatory column Attribute??(also known as xxxx) has not been
    -- assigned a value.
    -- The reason is because in hr_ex_employee_api.actual_termination_emp,
    -- it validates flex segments and there are no parameters to receive
    -- flex segments in hr_ex_employee_api.actual_termination_emp.  So, we
    -- need to flip the order to set the value of flex segments.
    --
    -- Call update_pds_details;
    hr_periods_of_service_api.update_pds_details (
        p_validate                     => FALSE,
        p_effective_date               => ld_actual_term_date,
        p_period_of_service_id         => ln_period_of_service_id,
        p_object_version_number        => ln_object_version_number,
        p_comments                     => ll_term_comments,
        p_leaving_reason               => lv_term_reason,
        p_notified_termination_date    => ld_notified_term_date,
        p_projected_termination_date   => ld_projected_termination_date,
        p_attribute_category           => lv_attribute_category,
        p_attribute1                   => lt_term_flex(1),
        p_attribute2                   => lt_term_flex(2),
        p_attribute3                   => lt_term_flex(3),
        p_attribute4                   => lt_term_flex(4),
        p_attribute5                   => lt_term_flex(5),
        p_attribute6                   => lt_term_flex(6),
        p_attribute7                   => lt_term_flex(7),
        p_attribute8                   => lt_term_flex(8),
        p_attribute9                   => lt_term_flex(9),
        p_attribute10                  => lt_term_flex(10),
        p_attribute11                  => lt_term_flex(11),
        p_attribute12                  => lt_term_flex(12),
        p_attribute13                  => lt_term_flex(13),
        p_attribute14                  => lt_term_flex(14),
        p_attribute15                  => lt_term_flex(15),
        p_attribute16                  => lt_term_flex(16),
        p_attribute17                  => lt_term_flex(17),
        p_attribute18                  => lt_term_flex(18),
        p_attribute19                  => lt_term_flex(19),
        p_attribute20                  => lt_term_flex(20),
        ---- DDF Enhancement : Save DDF Segments data as well.
        p_pds_information_category     => lv_pds_information_category,
        p_pds_information1             => lt_term_flex(21),
        p_pds_information2             => lt_term_flex(22),
        p_pds_information3             => lt_term_flex(23),
        p_pds_information4             => lt_term_flex(24),
        p_pds_information5             => lt_term_flex(25),
        p_pds_information6             => lt_term_flex(26),
        p_pds_information7             => lt_term_flex(27),
        p_pds_information8             => lt_term_flex(28),
        p_pds_information9             => lt_term_flex(29),
        p_pds_information10            => lt_term_flex(30),
        p_pds_information11            => lt_term_flex(31),
        p_pds_information12            => lt_term_flex(32),
        p_pds_information13            => lt_term_flex(33),
        p_pds_information14            => lt_term_flex(34),
        p_pds_information15            => lt_term_flex(35),
        p_pds_information16            => lt_term_flex(36),
        p_pds_information17            => lt_term_flex(37),
        p_pds_information18            => lt_term_flex(38),
        p_pds_information19            => lt_term_flex(39),
        p_pds_information20            => lt_term_flex(40),
        p_pds_information21            => lt_term_flex(41),
        p_pds_information22            => lt_term_flex(42),
        p_pds_information23            => lt_term_flex(43),
        p_pds_information24            => lt_term_flex(44),
        p_pds_information25            => lt_term_flex(45),
        p_pds_information26            => lt_term_flex(46),
        p_pds_information27            => lt_term_flex(47),
        p_pds_information28            => lt_term_flex(48),
        p_pds_information29            => lt_term_flex(49),
        p_pds_information30            => lt_term_flex(50)
      );

    -- Bug Fix 2089615 Ends

    hr_ex_employee_api.actual_termination_emp (
        p_validate                   => FALSE,
        p_effective_date             => ld_actual_term_date,
        p_period_of_service_id       => ln_period_of_service_id,
        p_object_version_number      => ln_object_version_number,
        p_actual_termination_date    => ld_actual_term_date,
        p_last_standard_process_date => ld_last_standard_process_date,
        p_leaving_reason             => lv_term_reason,
--        p_rehire_recommendation      => lv_rehire_recommendation,
--        p_rehire_reason              => lv_rehire_reason,
        p_person_type_id             => lv_person_type_id,
        p_assignment_status_type_id  => lv_assignment_status_type_id,
        p_supervisor_warning         => lb_supervisor_warning,
        p_event_warning              => lb_event_warning,
        p_interview_warning          => lb_interview_warning,
        p_review_warning             => lb_review_warning,
        p_recruiter_warning          => lb_recruiter_warning,
        p_asg_future_changes_warning => lb_asg_future_changes_warning,
        p_entries_changed_warning    => lv_entries_changed_warning,
        p_pay_proposal_warning       => lb_pay_proposal_warning,
        p_dod_warning                => lb_dod_warning
      );

    -- Bug 2098595 Fix Ends
    --
    -- Core HR API will not support update of field Rehire Recommendation
    -- and Rehire Reason. Hence we make following call to Person API
    -- to update the Fields.
    update_per_details(
        p_validate                   => 0,  -- false
        p_effective_date             => ld_actual_term_date,
        p_period_of_service_id       => ln_period_of_service_id,
        p_actual_termination_date    => ld_actual_term_date,
        p_rehire_recommendation      => lv_rehire_recommendation,
        p_rehire_reason              => lv_rehire_reason
    );

     --call for Final_emp_process bug 3843399
    l_entries_changed_warning := 'N';

    if ld_final_process_date is not null
    THEN
    hr_ex_employee_api.final_process_emp(
        p_validate                   => false,
        p_period_of_service_id       => ln_period_of_service_id,
        p_object_version_number      => ln_object_version_number,
        p_final_process_date         => ld_final_process_date,
        p_org_now_no_manager_warning => l_org_now_no_manager_warning,
        p_asg_future_changes_warning => l_asg_future_changes_warning,
        p_entries_changed_warning    => l_entries_changed_warning );


    END IF;
    --end of call bug 3843399

    hr_utility.set_location(' Leaving: ' || l_proc,15);


  EXCEPTION
   WHEN OTHERS THEN
     l_err_msg := hr_java_conv_util_ss.get_formatted_error_message
                        (p_single_error_message => hr_utility.get_message);
     hr_utility.set_location('EXCEPTION '|| l_err_msg || ':  ' || l_proc,5600);
     rollback to ex_emp_savepoint;
     RAISE;
  END process_api;


  /*
  ||=======================================================================
  || FUNCTION    : get_termination_details
  || DESCRIPTION : This overloaded funciton return the  termination related
  ||               information by given transaction_step_id.
  ||=======================================================================
  */
  FUNCTION get_termination_details (
    p_transaction_step_id IN
      hr_api_transaction_steps.transaction_step_id%type
  )
  RETURN hr_termination_ss.rt_termination
  IS
    lrt_termination hr_termination_ss.rt_termination;
    l_proc constant varchar2(100) := g_package || ' get_termination_details';
  BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
    lrt_termination.notified_termination_date :=
      hr_transaction_api.get_date_value (
        p_transaction_step_id => p_transaction_step_id,
	p_name                => 'P_NOTIFIED_TERMINATION_DATE'
      );

    lrt_termination.last_standard_process_date :=
      hr_transaction_api.get_date_value (
        p_transaction_step_id => p_transaction_step_id,
	p_name                => 'P_LAST_STANDARD_PROCESS_DATE'
      );

    lrt_termination.projected_termination_date :=
      hr_transaction_api.get_date_value (
        p_transaction_step_id => p_transaction_step_id,
	p_name                => 'P_PROJECTED_TERMINATION_DATE'
      );

    lrt_termination.final_process_date :=
      hr_transaction_api.get_date_value (
        p_transaction_step_id => p_transaction_step_id,
	p_name                => 'P_FINAL_PROCESS_DATE'
      );

    lrt_termination.actual_termination_date :=
      hr_transaction_api.get_date_value (
        p_transaction_step_id => p_transaction_step_id,
	p_name                => 'P_ACTUAL_TERMINATION_DATE'
      );

    lrt_termination.leaving_reason :=
      hr_transaction_api.get_varchar2_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_LEAVING_REASON'
      );

    lrt_termination.person_type_id :=
      hr_transaction_api.get_number_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_PERSON_TYPE_ID'
      );

    lrt_termination.assignment_status_type_id :=
      hr_transaction_api.get_number_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_ASSIGNMENT_STATUS_TYPE_ID'
      );

    lrt_termination.comments :=
      hr_transaction_api.get_varchar2_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_COMMENTS'
      );

    lrt_termination.period_of_service_id :=
      hr_transaction_api.get_number_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_PERIOD_OF_SERVICE_ID'
      );

    lrt_termination.object_version_number :=
      hr_transaction_api.get_number_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_OBJECT_VERSION_NUMBER'
      );

    lrt_termination.rehire_recommendation :=
      hr_transaction_api.get_varchar2_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_REHIRE_RECOMMENDATION'
      );

    lrt_termination.rehire_reason :=
      hr_transaction_api.get_varchar2_value (
        p_transaction_step_id => p_transaction_step_id,
        p_name                => 'P_REHIRE_REASON'
      );
 hr_utility.set_location('Leaving: '|| l_proc,10);
    RETURN lrt_termination;
  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      RAISE;
  END get_termination_details;

  /*
  ||=======================================================================
  || FUNCTION:    get_term_flex_detail
  || DESCRIPTION: This function returns termination dff data by
  ||              transaction step id.
  ||=======================================================================
  */
  FUNCTION get_term_flex_detail (
    p_transaction_step_id IN
      hr_api_transaction_steps.transaction_step_id%type
  )
  RETURN hr_termination_ss.t_flex_table
  IS
    lt_term_flex hr_termination_ss.t_flex_table;
    l_proc constant varchar2(100) := g_package || 'get_term_flex_detail ';
  BEGIN
    ---- First 20 DFF Data
    ---- Next 30, DDF Data
    hr_utility.set_location('Entering: '|| l_proc,5);
    FOR ln_counter IN 1..20 LOOP
      lt_term_flex(ln_counter) := NULL;
    END LOOP;
    FOR ln_counter IN 1..20 LOOP
      lt_term_flex(ln_counter) :=
        hr_transaction_api.get_varchar2_value (
          p_transaction_step_id => p_transaction_step_id,
          p_name                => 'P_ATTRIBUTE' || to_char(ln_counter)
        );
    END LOOP;
    ---------------------------------------------------------------------------
    -- DDF Enhancement : Return DDF Segments data from Transaction Table
    -- We have to get P_PDS_INFORMATION1 to P_PDS_INFORMATION30
    ---------------------------------------------------------------------------
    FOR ln_counter IN 21..50 LOOP
      lt_term_flex(ln_counter) := NULL;
    END LOOP;
    FOR ln_counter IN 21..50 LOOP
      lt_term_flex(ln_counter) :=
        hr_transaction_api.get_varchar2_value (
          p_transaction_step_id => p_transaction_step_id,
          p_name                => 'P_PDS_INFORMATION' ||
                                    to_char(ln_counter - 20)
        );
    END LOOP;
hr_utility.set_location('Leaving: '|| l_proc,10);
    RETURN lt_term_flex;
  END get_term_flex_detail;


  /*
  ||===========================================================================
  || PROCEDURE: get_term_transaction
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Reads Termination Transaction from transaction table
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Transaction id keys
  ||
  || out nocopy Arguments:
  ||     None.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Reads from transaction table
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */
  procedure get_term_transaction
    (p_transaction_step_id           in     varchar2
    ,p_period_of_service_id          out nocopy    varchar2
    ,p_object_version_number         out nocopy    varchar2
    ,p_actual_termination_date       out nocopy    varchar2
    ,p_notified_termination_date     out nocopy    varchar2
    ,p_leaving_reason                out nocopy    varchar2
    ,p_person_type_id                out nocopy    varchar2
    ,p_assignment_status_type_id     out nocopy    varchar2
    ,p_rehire_recommendation         out nocopy    varchar2
    ,p_rehire_reason                 out nocopy    varchar2
    ,p_comments                      out nocopy    varchar2
    ,p_last_standard_process_date    out nocopy    varchar2
    ,p_projected_termination_date    out nocopy    varchar2
    ,p_final_process_date            out nocopy    varchar2
    ,p_attribute_category            out nocopy    varchar2
    ,p_attribute1                    out nocopy    varchar2
    ,p_attribute2                    out nocopy    varchar2
    ,p_attribute3                    out nocopy    varchar2
    ,p_attribute4                    out nocopy    varchar2
    ,p_attribute5                    out nocopy    varchar2
    ,p_attribute6                    out nocopy    varchar2
    ,p_attribute7                    out nocopy    varchar2
    ,p_attribute8                    out nocopy    varchar2
    ,p_attribute9                    out nocopy    varchar2
    ,p_attribute10                   out nocopy    varchar2
    ,p_attribute11                   out nocopy    varchar2
    ,p_attribute12                   out nocopy    varchar2
    ,p_attribute13                   out nocopy    varchar2
    ,p_attribute14                   out nocopy    varchar2
    ,p_attribute15                   out nocopy    varchar2
    ,p_attribute16                   out nocopy    varchar2
    ,p_attribute17                   out nocopy    varchar2
    ,p_attribute18                   out nocopy    varchar2
    ,p_attribute19                   out nocopy    varchar2
    ,p_attribute20                   out nocopy    varchar2
    ,p_review_actid                  out nocopy    varchar2
    ,p_review_proc_call              out nocopy    varchar2
    ,p_pds_information_category      out nocopy    varchar2
    ,p_pds_information1              out nocopy    varchar2
    ,p_pds_information2              out nocopy    varchar2
    ,p_pds_information3              out nocopy    varchar2
    ,p_pds_information4              out nocopy    varchar2
    ,p_pds_information5              out nocopy    varchar2
    ,p_pds_information6              out nocopy    varchar2
    ,p_pds_information7              out nocopy    varchar2
    ,p_pds_information8              out nocopy    varchar2
    ,p_pds_information9              out nocopy    varchar2
    ,p_pds_information10             out nocopy    varchar2
    ,p_pds_information11             out nocopy    varchar2
    ,p_pds_information12             out nocopy    varchar2
    ,p_pds_information13             out nocopy    varchar2
    ,p_pds_information14             out nocopy    varchar2
    ,p_pds_information15             out nocopy    varchar2
    ,p_pds_information16             out nocopy    varchar2
    ,p_pds_information17             out nocopy    varchar2
    ,p_pds_information18             out nocopy    varchar2
    ,p_pds_information19             out nocopy    varchar2
    ,p_pds_information20             out nocopy    varchar2
    ,p_pds_information21             out nocopy    varchar2
    ,p_pds_information22             out nocopy    varchar2
    ,p_pds_information23             out nocopy    varchar2
    ,p_pds_information24             out nocopy    varchar2
    ,p_pds_information25             out nocopy    varchar2
    ,p_pds_information26             out nocopy    varchar2
    ,p_pds_information27             out nocopy    varchar2
    ,p_pds_information28             out nocopy    varchar2
    ,p_pds_information29             out nocopy    varchar2
    ,p_pds_information30             out nocopy    varchar2
  )
IS

   lv_date                           varchar2(200) default null;
l_proc constant varchar2(100) := g_package || ' get_term_transaction';

BEGIN
     hr_utility.set_location('Entering: '|| l_proc,5);
  --
    p_period_of_service_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERIOD_OF_SERVICE_ID');
  --
    p_object_version_number:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'P_OBJECT_VERSION_NUMBER');
  --
  -- Bug 2086516 Fix Begins - 11/15/2001
  -- When re-launching a Save For Later action,we need to get the Effective Date
  -- from Workflow because a user can change the Effective Date which is saved
  -- to WF as an item attribute.  Otherwise, the page will display the Effective
  -- Date from the transaction table and ignore the new date entered by the
  -- user.

    p_actual_termination_date:=
      hr_transaction_ss.get_wf_effective_date
      (p_transaction_step_id => p_transaction_step_id);
  --
  -- Bug 2086516 Fix Ends - 11/15/2001
  --
    p_notified_termination_date:= to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_NOTIFIED_TERMINATION_DATE')
      ,g_date_format);
  --
    p_last_standard_process_date := to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_LAST_STANDARD_PROCESS_DATE')
      ,g_date_format);
  --
    p_projected_termination_date := to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PROJECTED_TERMINATION_DATE')
      ,g_date_format);
  --
   p_final_process_date := to_char(
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_FINAL_PROCESS_DATE')
      ,g_date_format);
  --
    p_leaving_reason:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_LEAVING_REASON');
  --
    p_person_type_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERSON_TYPE_ID');
  --
    p_assignment_status_type_id:=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ASSIGNMENT_STATUS_TYPE_ID');
  --
    p_comments:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_COMMENTS');
  --
    p_rehire_recommendation:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_RECOMMENDATION');
  --
    p_rehire_reason:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_REASON');

  --
    p_attribute_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE_CATEGORY');
  --
    p_attribute1:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE1');
  --
    p_attribute2:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE2');
  --
    p_attribute3:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE3');
  --
    p_attribute4:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE4');
  --
    p_attribute5:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE5');
  --
    p_attribute6:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE6');
  --
    p_attribute7:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE7');
  --
    p_attribute8:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE8');
  --
    p_attribute9:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE9');
  --
    p_attribute10:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE10');
  --
    p_attribute11:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE11');
  --
    p_attribute12:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE12');
  --
    p_attribute13:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE13');
  --
    p_attribute14:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE14');
  --
    p_attribute15:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE15');
  --
    p_attribute16:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE16');
  --
    p_attribute17:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE17');
  --
    p_attribute18:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE18');
  --
    p_attribute19:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE19');
  --
    p_attribute20:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE20');
  --
    p_review_actid:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REVIEW_ACTID');
  --
    p_review_proc_call:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REVIEW_PROC_CALL');

  -- DDF Enhancement : Retrieve from Transaction table.
  --
    p_pds_information_category:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION_CATEGORY');
  --
    p_pds_information1:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION1');
  --
    p_pds_information2:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION2');
  --
    p_pds_information3:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION3');
  --
    p_pds_information4:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION4');
  --
    p_pds_information5:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION5');
  --
    p_pds_information6:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION6');
  --
    p_pds_information7:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION7');
  --
    p_pds_information8:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION8');
  --
    p_pds_information9:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION9');
  --
    p_pds_information10:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION10');
  --
    p_pds_information11:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION11');
  --
    p_pds_information12:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION12');
  --
    p_pds_information13:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION13');
  --
    p_pds_information14:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION14');
  --
    p_pds_information15:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION15');
  --
    p_pds_information16:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION16');
  --
    p_pds_information17:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION17');
  --
    p_pds_information18:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION18');
  --
    p_pds_information19:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION19');
  --
    p_pds_information20:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION20');
  --
    p_pds_information21:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION21');
  --
    p_pds_information22:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION22');
  --
    p_pds_information23:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION23');
  --
    p_pds_information24:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION24');
  --
    p_pds_information25:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION25');
  --
    p_pds_information26:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION26');
  --
    p_pds_information27:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION27');
  --
    p_pds_information28:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION28');
  --
    p_pds_information29:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION29');
  --
    p_pds_information30:=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION30');
  --
hr_utility.set_location('Leaving: '|| l_proc,10);
EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     p_period_of_service_id    := null;
     p_object_version_number    := null;
     p_actual_termination_date   := null;
     p_notified_termination_date  := null;
     p_leaving_reason        := null;
     p_person_type_id := NULL;
     p_assignment_status_type_id := NULL;
     p_comments              := null;
     p_attribute_category    := null;
     p_attribute1    := null;
     p_attribute2    := null;
     p_attribute3    := null;
     p_attribute4    := null;
     p_attribute5    := null;
     p_attribute6    := null;
     p_attribute7    := null;
     p_attribute8    := null;
     p_attribute9    := null;
     p_attribute10   := null;
     p_attribute11   := null;
     p_attribute12   := null;
     p_attribute13   := null;
     p_attribute14   := null;
     p_attribute15   := null;
     p_attribute16   := null;
     p_attribute17   := null;
     p_attribute18   := null;
     p_attribute19   := null;
     p_attribute20   := null;
     p_review_actid  := null;
     p_review_proc_call := null;
     p_pds_information_category := null;
     p_pds_information1 := null;
     p_pds_information2 := null;
     p_pds_information3 := null;
     p_pds_information4 := null;
     p_pds_information5 := null;
     p_pds_information6 := null;
     p_pds_information7 := null;
     p_pds_information8 := null;
     p_pds_information9 := null;
     p_pds_information10 := null;
     p_pds_information11 := null;
     p_pds_information12 := null;
     p_pds_information13 := null;
     p_pds_information14 := null;
     p_pds_information15 := null;
     p_pds_information16 := null;
     p_pds_information17 := null;
     p_pds_information18 := null;
     p_pds_information19 := null;
     p_pds_information20 := null;
     p_pds_information21 := null;
     p_pds_information22 := null;
     p_pds_information23 := null;
     p_pds_information24 := null;
     p_pds_information25 := null;
     p_pds_information26 := null;
     p_pds_information27 := null;
     p_pds_information28 := null;
     p_pds_information29 := null;
     p_pds_information30 := null;
    RAISE;  -- Raise error here relevant to the new tech stack.

END get_term_transaction;

END hr_termination_ss;

/
