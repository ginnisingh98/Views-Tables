--------------------------------------------------------
--  DDL for Package Body HR_CCMGR_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CCMGR_SS" AS
/* $Header: hrccmwrs.pkb 120.1 2006/02/07 14:56:50 snachuri noship $ */

-- Global Variables
l_trans_tbl hr_transaction_ss.transaction_table;
g_package      Varchar2(30):='HR_CCMGR_SS';
g_api_name     Varchar2(30):='HR_CCMGR_SS.PROCESS_API';
g_date_format  Varchar2(10):='RRRR-MM-DD';
g_data_error   Exception;

-- Cursors
cursor c_supDetails (p_id Number) IS
Select s.full_name, s.person_id
From per_all_people_f s, per_all_assignments_f paf
Where paf.person_id = p_id
and paf.supervisor_id = s.person_id
and paf.primary_flag = 'Y'
and s.current_employee_flag = 'Y'
and paf.assignment_type = 'E'
and trunc(sysdate) between s.effective_start_date and s.effective_end_date
and trunc(sysdate) between paf.effective_start_date and paf.effective_end_date;

cursor c_noaccess_list (p_id Varchar2) IS
Select haotl.name organization_name,
       pap.full_name manager_name,
fnd_date.canonical_to_date(cm.ORG_INFORMATION3) start_Date,
fnd_date.canonical_to_date(cm.ORG_INFORMATION4) end_Date,
decode((decode(decode(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE', HR_SECURITY.SHOW_RECORD('HR_ALL_ORGANIZATION_UNITS', HAO.ORGANIZATION_ID)
),'TRUE',0,1)+ decode(decode(hr_general.get_xbg_profile,'Y', hao.business_group_id , hr_general.get_business_group_id),hao.business_group_id,0,1)
+ decode(decode(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE', HR_SECURITY.SHOW_RECORD('PER_ALL_PEOPLE_F', PAP.PERSON_ID, PAP.PERSON_TYPE_ID, PAP.EMPLOYEE_NUMBER,PAP.APPLICANT_NUMBER)
),'TRUE',0,1) + decode(decode(hr_general.get_xbg_profile,'Y',pap.business_group_id , hr_general.get_business_group_id),pap.business_group_id,0,1)),0,'Y','N') hasUpdateAccess
from  hr_organization_information cm,per_all_people_f pap
     ,hr_all_organization_units hao ,hr_all_organization_units_tl haotl
where cm.org_information_context = 'Organization Name Alias'
and cm.ORG_INFORMATION2 = p_id
and cm.ORG_INFORMATION2 = to_char(pap.person_id)
and pap.current_employee_flag = 'Y'
and hao.organization_id = cm.organization_id
and pap.person_id=p_id
and trunc(sysdate) between pap.effective_start_date and pap.effective_end_date
and trunc(sysdate) between hao.date_from and nvl(hao.date_to,trunc(sysdate))
and HAO.ORGANIZATION_ID = HAOTL.ORGANIZATION_ID
and HAOTL.LANGUAGE = USERENV('LANG')
and trunc(sysdate) between hao.date_from and nvl(hao.date_to,trunc(sysdate))
and exists (select 'e' from hr_organization_information class,
                   hr_org_info_types_by_class ctype
                    where ctype.org_information_type = 'Organization Name Alias'
                    and ctype.org_classification = class.org_information1
                    and class.org_information_context = 'CLASS'
                    and class.org_information2 = 'Y'
                    and class.organization_id = cm.organization_id)
/* Excluding pending approval */
and not exists (select 'e' from hr_api_transaction_steps s, hr_api_transactions t,
                                hr_api_transaction_values v
                 where s.api_name = 'HR_CCMGR_SS.PROCESS_API'
                 and s.transaction_id = t.transaction_id and status = 'Y'
                 and s.transaction_step_id = v.transaction_step_id
                 and v.name = 'P_ORGANIZATION_ID'
                 and v.number_value = hao.organization_id
                 and rownum < 2)
and (nvl(fnd_date.canonical_to_date(cm.ORG_INFORMATION4),sysdate) >= sysdate
       Or (fnd_date.canonical_to_date(cm.ORG_INFORMATION4) <= sysdate
           and fnd_date.canonical_to_date(cm.ORG_INFORMATION3)
                           = (select max(fnd_date.canonical_to_date(oi.ORG_INFORMATION3))
                             from hr_organization_information oi
                             where oi.org_information_context = 'Organization Name Alias'
                             and oi.organization_id = cm.organization_id)));

--
procedure get_supervisor_details(p_emp_id IN Number,
                                 p_sup_id OUT NOCOPY Number,
                                 p_sup_name OUT NOCOPY Varchar2) IS

l_proc Varchar2(200) := g_package || 'get_supervisor_details';
Begin
        hr_utility.set_location(' Entering:' || l_proc,5);
        Open c_supDetails(p_emp_id);
        Fetch c_supDetails into p_sup_name, p_sup_id;
	hr_utility.set_location( l_proc , 10);
        If c_supDetails%notfound Then
	    hr_utility.set_location( l_proc,15);
            p_sup_id := Null;
            p_sup_name := Null;
        End If;
	hr_utility.set_location( l_proc, 20);
        close c_supDetails;
        hr_utility.set_location(' Leaving:' || l_proc,25);

Exception When others then
    hr_utility.set_location(' Leaving:' || l_proc,555);
    close c_supDetails;
    p_sup_id := Null;
    p_sup_name := Null;
    hr_utility.set_location(' Leaving:' || l_proc,560);
End get_supervisor_details;

procedure get_noaccess_list(document_id IN Varchar2,
                            display_type IN Varchar2,
                            document IN OUT NOCOPY Clob,
                            document_type IN OUT NOCOPY Varchar2) IS
l_proc Varchar2(200) := g_package || 'get_noaccess_list';
Begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    /* ld_effective_date := wf_engine.GetItemAttrDate
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,aname    => 'CURRENT_EFFECTIVE_DATE'); */

--  hr_java_script_web.alert('Person Id:'||document_id);
  document_type := 'text/html';
  hr_utility.set_location(l_proc,10);
  For I in c_noaccess_list(document_id) Loop
   If I.hasUpdateAccess = 'N' Then
    WF_NOTIFICATION.WriteToClob(document, I.organization_name||'<br>');
   End If;
  End Loop;
  hr_utility.set_location(' Leaving:' || l_proc,15);
End get_noaccess_list;

procedure issue_notify(itemtype IN Varchar2,
                       itemkey IN Varchar2,
                       actid IN Number,
                       funmode IN Varchar2,
                       result OUT NOCOPY Varchar2) IS
l_proc Varchar2(200) := g_package || 'issue_notify';
lnSupId     Number;
lnSupName   Varchar2(240);
lnSupUserName    Varchar2(30);
Begin
   hr_utility.set_location(' Entering:' || l_proc,5);
   result := 'COMPLETE:'||'N';
   lnSupId := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname => 'HR_MGR_ID_OF_LOGIN_PERSON');
   hr_utility.set_location(l_proc,10);
   --
   If (lnSupId is not Null And
      nvl(wf_engine.GetItemAttrText(itemtype => itemtype, itemkey  => itemkey,
                                    aname => 'HR_TERM_SUP_FLAG'),'#') = 'Y') Then
        hr_utility.set_location(l_proc,15);
        result := 'COMPLETE:'||'Y';
        wf_directory.GetUserName ('PER',
                                  lnSupId,
                                  lnSupUserName,
                                  lnSupName);
        hr_utility.set_location(l_proc,20);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'SUPERVISOR_USERNAME',
                                  lnSupUserName);
        hr_utility.set_location(l_proc,25);
        wf_engine.SetItemAttrText(itemtype,
                                  itemkey,
                                  'SUPERVISOR_DISPLAY_NAME',
                                  lnSupName);
   End If;
   hr_utility.set_location(' Leaving:' || l_proc,30);
Exception
   When Others then
   result := 'COMPLETE:'||'N';
   hr_utility.set_location(' Leaving:' || l_proc,555);
End issue_notify;

--
procedure delete_trans_steps(itemtype IN Varchar2
                            ,itemkey IN Varchar2
                            ,actid IN Number) IS
l_proc Varchar2(200) := g_package || 'delete_trans_steps';
Begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    if (itemtype is Null or itemkey is Null) Then
        hr_utility.set_location(' Leaving:' || l_proc,10);
        return;
    End If;

    Delete From hr_api_transaction_values tv
    Where tv.transaction_step_id in (Select ts.transaction_step_id
                                          From hr_api_transaction_steps ts
                                      Where ts.item_key = itemkey
                                      And ts.item_type = itemtype
                                      And ts.activity_id = actid
                                      And ts.api_name = 'HR_CCMGR_SS.PROCESS_API');
    hr_utility.set_location(l_proc,15);
    Delete From hr_api_transaction_steps
    Where item_key = itemkey
    And item_type = itemtype
    And activity_id = actid
    And api_name = 'HR_CCMGR_SS.PROCESS_API';
    hr_utility.set_location(' Leaving:' || l_proc,20);
End delete_trans_steps;


--
procedure process_api(p_validate in boolean default false
                     ,p_transaction_step_id in number default null
                     ,p_effective_date in varchar2 default null) IS

l_proc Varchar2(200) := g_package || 'process_api';
l_ccmgr_rec  HR_CCMGR_TYPE;
l_eff_date Date;
l_warning boolean;
Begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    l_eff_date := nvl(hr_transaction_api.get_date_value(p_transaction_step_id, 'P_EFFECTIVE_DATE'),trunc(sysdate));

    dt_fndate.set_effective_date(l_eff_date);
    hr_utility.set_location(l_proc,10);

    l_ccmgr_rec := HR_CCMGR_TYPE(hr_transaction_api.get_number_value(p_transaction_step_id, 'P_ORG_INFORMATION_ID'),
                                 hr_transaction_api.get_number_value(p_transaction_step_id, 'P_ORGANIZATION_ID'),
                                 Null, -- organization name
                                 hr_transaction_api.get_number_value(p_transaction_step_id, 'P_CURR_MANAGER_ID'),
                                 hr_transaction_api.get_number_value(p_transaction_step_id, 'P_CURR_MANAGER'),
                                 hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_ORG_INFORMATION1'),
                                 hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_MANAGER_ID'),
                                 hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_MANAGER'),
                                 hr_transaction_api.get_date_value(p_transaction_step_id, 'P_CURR_START_DATE'),
                                 hr_transaction_api.get_date_value(p_transaction_step_id, 'P_START_DATE'),
                                 hr_transaction_api.get_date_value(p_transaction_step_id, 'P_CURR_END_DATE'),
                                 hr_transaction_api.get_date_value(p_transaction_step_id, 'P_END_DATE'),
                                 hr_transaction_api.get_number_value(p_transaction_step_id, 'P_OVN_NUMBER'),
                                 Null, Null, Null);
    hr_utility.set_location(l_proc,15);

    -- SFL on update page might not have captured manager info.
	if (l_ccmgr_rec.manager_id is null and l_ccmgr_rec.manager is null) then
	        hr_utility.set_location(l_proc,20);
        	l_ccmgr_rec.manager := l_ccmgr_rec.current_manager;
        	l_ccmgr_rec.manager_id := l_ccmgr_rec.current_manager_id;
        end if;
    hr_utility.set_location(l_proc,25);
    validate_ccmgr_record(l_ccmgr_rec, p_validate,l_eff_date, l_warning);
    hr_utility.set_location(' Leaving:' || l_proc,30);
Exception When others then
   hr_utility.set_location(' Leaving:' || l_proc,555);
    raise;
End process_api;

--
Procedure validate_ccmgr_record(p_ccmgr_rec IN HR_CCMGR_TYPE
                               ,p_validate_mode IN boolean Default true
                               ,p_eff_date IN Date
                               ,p_warning OUT NOCOPY Boolean) IS
l_proc Varchar2(200) := g_package || 'validate_ccmgr_record';
x_obj_number         Number;
x_org_information_id Number;
l_manager_id         Number;
l_start_date         Date;
l_end_date           Date;
l_upd_mode           Boolean;
l_mode               Varchar2(30);
Begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_upd_mode := true;
  savepoint save_ccmgr_rec;

  If (p_ccmgr_rec.current_manager_id = nvl(p_ccmgr_rec.manager_id,p_ccmgr_rec.current_manager_id) And
      nvl(p_ccmgr_rec.current_start_date,p_ccmgr_rec.start_date) = p_ccmgr_rec.start_date) Then
    -- mode CORRECTION iff startDate and manager have not changed
    hr_utility.set_location(l_proc,10);
    l_mode := 'CORRECTION';
    l_manager_id := p_ccmgr_rec.current_manager_id;
    l_start_date := p_ccmgr_rec.start_date;
    l_end_date := p_ccmgr_rec.end_date;
  Else
    hr_utility.set_location(l_proc,15);
    l_mode := 'UPDATE';
    l_manager_id := p_ccmgr_rec.current_manager_id;
    l_start_date := p_ccmgr_rec.current_start_date;
    l_end_date := p_ccmgr_rec.start_date-1;
    If (p_ccmgr_rec.current_end_date is not Null) Then
        l_upd_mode := false;
    End If;
  End If;
  hr_utility.set_location(l_proc,20);
    x_obj_number := p_ccmgr_rec.object_version_number;

  If (l_upd_mode) Then
    hr_utility.set_location(l_proc,25);
    hr_organization_api.update_org_manager
        (p_validate              => false
        ,p_effective_date        => p_eff_date
        ,p_organization_id       => p_ccmgr_rec.organization_id
        ,p_org_information_id    => p_ccmgr_rec.org_information_id
        ,p_org_info_type_code    => 'Organization Name Alias'
        ,p_org_information1      => p_ccmgr_rec.org_information1
        ,p_org_information2      => l_manager_id
        ,p_org_information3      => fnd_date.date_to_canonical(l_start_date)
        ,p_org_information4      => fnd_date.date_to_canonical(l_end_date)
        ,p_org_information5      => Null
        ,p_org_information6      => Null
        ,p_org_information7      => Null
        ,p_org_information8      => Null
        ,p_org_information9      => Null
        ,p_org_information10     => Null
        ,p_org_information11     => Null
        ,p_org_information12     => Null
        ,p_org_information13     => Null
        ,p_org_information14     => Null
        ,p_org_information15     => Null
        ,p_org_information16     => Null
        ,p_org_information17     => Null
        ,p_org_information18     => Null
        ,p_org_information19     => Null
        ,p_org_information20     => Null
        ,p_object_version_number => x_obj_number
        ,p_warning => p_warning);
  End If;
  hr_utility.set_location(l_proc,30);
  If (p_ccmgr_rec.current_manager_id <> p_ccmgr_rec.manager_id Or
      p_ccmgr_rec.current_start_date <> p_ccmgr_rec.start_date) Then
    -- creating the new record
    hr_utility.set_location(l_proc,35);
    hr_organization_api.create_org_manager
        (p_validate              => false
        ,p_effective_date        => p_eff_date
        ,p_organization_id       => p_ccmgr_rec.organization_id
        ,p_org_info_type_code    => 'Organization Name Alias'
        ,p_org_information1      => p_ccmgr_rec.org_information1
        ,p_org_information2      => p_ccmgr_rec.manager_id
        ,p_org_information3      => fnd_date.date_to_canonical(p_ccmgr_rec.start_date)
        ,p_org_information4      => fnd_date.date_to_canonical(p_ccmgr_rec.end_date)
        ,p_org_information5      => Null
        ,p_org_information6      => Null
        ,p_org_information7      => Null
        ,p_org_information8      => Null
        ,p_org_information9      => Null
        ,p_org_information10     => Null
        ,p_org_information11     => Null
        ,p_org_information12     => Null
        ,p_org_information13     => Null
        ,p_org_information14     => Null
        ,p_org_information15     => Null
        ,p_org_information16     => Null
        ,p_org_information17     => Null
        ,p_org_information18     => Null
        ,p_org_information19     => Null
        ,p_org_information20     => Null
        ,p_org_information_id    => x_org_information_id
        ,p_object_version_number => x_obj_number
        ,p_warning => p_warning);
  End If;
  hr_utility.set_location(l_proc,40);
  If p_validate_mode = true Then
     hr_utility.set_location(l_proc,45);
     rollback to save_ccmgr_rec;
  End If;
  hr_utility.set_location(' Leaving:' || l_proc,50);

Exception When others then
    hr_utility.set_location(' Leaving:' || l_proc,555);
    rollback to save_ccmgr_rec;
    raise;
End validate_ccmgr_record;

--
Function getattrName(msgName OUT NOCOPY Varchar2) Return Varchar2 IS
l_proc Varchar2(200) := g_package || 'getattrName';
Begin

    hr_utility.set_location(' Entering:' || l_proc,5);
    If (sqlcode <> '-20001') Then
         hr_utility.set_location(' Leaving:' || l_proc,10);
                Return Null; End If;
    msgName := ltrim(replace(replace(sqlerrm,'ORA-20001',''),':',''));
    If msgName in ('PER_289693_START_DATE_NULL','PER_289695_START_DATE_FORMAT',
                   'PER_289697_START_BEFORE_END','PER_289699_START_DATE_BFR_HIRE') Then
        hr_utility.set_location(' Leaving:' || l_proc,15);
        return 'StartDate';
    Elsif msgName in ('PER_289696_END_DATE_FORMAT','PER_289700_END_DATE_AFTER_TERM') Then
        hr_utility.set_location(' Leaving:' || l_proc,20);
        return 'EndDate';
    Elsif msgName in ('PER_289694_NO_MANAGER','PER_289698_PERSON_ID_INVALID',
                      'PER_289702_INVALID_MANAGER','PER_289703_CCM_OVERLAP') Then
        hr_utility.set_location(' Leaving:' || l_proc,25);
        return 'Manager';
    Elsif msgName in ('PER_289746_CCM_AFTER_ORG','PER_289701_INVALID_COST_CENTER') Then
	hr_utility.set_location(' Leaving:' || l_proc,30);
        return 'OrganizationName';
    End If;
    hr_utility.set_location(' Leaving:' || l_proc,35);
    return Null;
End getattrName;

--
Procedure update_ccmgr_recs(p_item_key  IN Varchar2
                           ,p_item_type IN Varchar2
                           ,p_activity_id IN Number
                           ,p_login_person_id IN OUT NOCOPY Number
                           ,p_ccmgr_tbl IN OUT NOCOPY HR_CCMGR_TABLE
                           ,p_mode IN Varchar2 Default '#'
                           ,p_error_message OUT NOCOPY Long
                           ,p_status OUT NOCOPY Varchar2) IS
l_proc Varchar2(200) := g_package || 'update_ccmgr_recs';
l_transaction_id    Number:=Null;
x_trans_ovn         Number:=Null;
l_result            Varchar2(100);
l_count             Number;
x_warning           Boolean;
l_attrName          Varchar2(30);
l_eff_date          Date;


Begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    p_login_person_id := nvl(fnd_global.employee_id,p_login_person_id);

    Begin
        hr_utility.set_location(l_proc,10);
    	l_eff_date := nvl(fnd_date.canonical_to_date(wf_engine.GetItemAttrText(p_item_key,p_item_type,'P_EFFECTIVE_DATE')),trunc(sysdate));
    Exception when others then
        l_eff_date := trunc(sysdate);
        hr_utility.set_location(l_proc,555);
    End;
    hr_utility.set_location(l_proc,15);
    l_transaction_id := hr_transaction_ss.get_transaction_id(p_item_type ,p_item_key);
    dt_fndate.set_effective_date(l_eff_date);

    If l_transaction_id is Null Then
        hr_utility.set_location(l_proc,20);
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_activity_id
           ,funmode    => 'RUN'
           ,p_login_person_id => p_login_person_id
           ,result     => l_result);
        l_transaction_id := hr_transaction_ss.get_transaction_id(p_item_type ,p_item_key);
    End If;
    hr_utility.set_location(l_proc,25);
    For I in 1 .. p_ccmgr_tbl.count Loop
     Begin
      hr_utility.set_location(l_proc || 'Entering: p_ccmgr_tbl.count Loop' ,30);
      If nvl(p_mode,'#') <> 'S' Then

        if (p_ccmgr_tbl(I).manager is not Null and p_ccmgr_tbl(I).manager_id is Null) Then
        Begin
	        hr_utility.set_location(l_proc ,35);
		Select person_id into p_ccmgr_tbl(I).manager_id
		From per_all_people_f
		where full_name = p_ccmgr_tbl(I).manager
		and current_employee_flag = 'Y'
		and trunc(sysdate) between effective_start_date and effective_end_date;

            Exception when others then
            	p_status := 'E';
            	p_ccmgr_tbl(I).p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
            				      p_attr_name => 'Manager'
                                             ,p_app_short_name => 'PER'
                                             ,p_message_name => 'HR_CCMGR_USE_MGR_LOV');
		hr_utility.set_location(l_proc,560);
	    	goto exit_point;
        End;
        End If;
        hr_utility.set_location(l_proc ,40);
        -- Record has not changed
        If p_ccmgr_tbl(I).current_manager_id = nvl(p_ccmgr_tbl(I).manager_id,p_ccmgr_tbl(I).current_manager_id) And
           nvl(trunc(p_ccmgr_tbl(I).current_start_date),sysdate) = nvl(trunc(p_ccmgr_tbl(I).start_date),sysdate) And
           nvl(trunc(p_ccmgr_tbl(I).current_end_date),sysdate) = nvl(trunc(p_ccmgr_tbl(I).end_date),sysdate) Then
            -- Rolling back unchanged saved step if not Save for later mode.
	    hr_utility.set_location(l_proc ,45);
           If (p_ccmgr_tbl(I).trans_step_id is not Null) Then
	        hr_utility.set_location(l_proc ,50);
                Delete From hr_api_transaction_values where transaction_step_id = p_ccmgr_tbl(I).trans_step_id;
                Delete From hr_api_transaction_steps where transaction_step_id = p_ccmgr_tbl(I).trans_step_id;
           End If;
	   hr_utility.set_location(l_proc ,55);
           goto exit_point;
        End If;

        -- correction
	hr_utility.set_location(l_proc ,60);
        If p_ccmgr_tbl(I).manager is Null Then
	    hr_utility.set_location(l_proc ,65);
            p_ccmgr_tbl(I).manager := p_ccmgr_tbl(I).current_manager;
            p_ccmgr_tbl(I).manager_id := p_ccmgr_tbl(I).current_manager_id;
        End If;
        hr_utility.set_location(l_proc ,70);
        Begin
            -- invoke orgInformation api
            x_warning := False;
            validate_ccmgr_record(p_ccmgr_tbl(I), true, l_eff_date, x_warning);
            If x_warning Then  -- handling api warnings
	        hr_utility.set_location(l_proc ,75);
                p_ccmgr_tbl(I).p_warning_message := hr_java_conv_util_ss.get_formatted_error_message(
                                                   p_attr_name => 'OrganizationName'
                                                   ,p_error_message => p_ccmgr_tbl(I).p_warning_message
                                                   ,p_app_short_name => 'PER'
                                                   ,p_message_name => 'PER_289738_CCM_GAPS_CREATED');
                p_status := 'W';

            End If;
	    hr_utility.set_location(l_proc ,80);
        Exception when others then
            -- handling api errors
            p_status := 'E';
            l_attrName := getattrName(p_ccmgr_tbl(I).p_error_message);
	    hr_utility.set_location(l_proc,565);
            If (l_attrName is not null) Then
	      hr_utility.set_location(l_proc,570);
              p_ccmgr_tbl(I).p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                                                   p_attr_name => l_attrName
                                                   ,p_app_short_name => 'PER'
                                                   ,p_message_name => p_ccmgr_tbl(I).p_error_message);
            Else
	    hr_utility.set_location( l_proc,575);
              p_ccmgr_tbl(I).p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                                                   p_attr_name => 'Manager'
                                                  ,p_app_short_name => 'ERR'
                                                  ,p_single_error_message => nvl(fnd_message.get,
                                                   nvl(hr_utility.get_message,substr(sqlerrm,255))));
            End If;
        End;
      End If;

      --
       hr_utility.set_location(l_proc ,85);
      If p_ccmgr_tbl(I).trans_step_id is Null Then
       hr_utility.set_location(l_proc ,90);
            x_trans_ovn := Null;
            hr_transaction_api.create_transaction_step
	              (p_validate => false
        	      ,p_creator_person_id => p_login_person_id
              	      ,p_transaction_id => l_transaction_id
              	      ,p_api_name => g_package||'.PROCESS_API'
                      ,p_item_type => p_item_type
                      ,p_item_key => p_item_key
	              ,p_activity_id => p_activity_id
	              ,p_transaction_step_id => p_ccmgr_tbl(I).trans_step_id
                      ,p_object_version_number => x_trans_ovn);
      End If;
      hr_utility.set_location(l_proc ,95);
        -- populating transaction table

        l_count := 1;
        l_trans_tbl(l_count).param_name := 'P_ORG_INFORMATION_ID';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).org_information_id;
 	    l_trans_tbl(l_count).param_data_type := 'NUMBER';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_OVN_NUMBER';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).object_version_number;
 	    l_trans_tbl(l_count).param_data_type := 'NUMBER';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_ORGANIZATION_ID';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).organization_id;
 	    l_trans_tbl(l_count).param_data_type := 'NUMBER';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_ORGANIZATION_NAME';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).organization_name;
 	    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_CURR_MANAGER_ID';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).current_manager_id;
 	    l_trans_tbl(l_count).param_data_type := 'NUMBER';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_CURR_MANAGER';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).current_manager;
 	    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_ORG_INFORMATION1';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).org_information1;
 	    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_MANAGER_ID';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).manager_id;
 	    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_MANAGER';
    	l_trans_tbl(l_count).param_value := p_ccmgr_tbl(I).manager;
 	    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_EFFECTIVE_DATE';
    	l_trans_tbl(l_count).param_value := to_char(l_eff_date,g_date_format);
 	    l_trans_tbl(l_count).param_data_type := 'DATE';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_CURR_START_DATE';
    	l_trans_tbl(l_count).param_value := to_char(p_ccmgr_tbl(I).current_start_date,g_date_format);
 	    l_trans_tbl(l_count).param_data_type := 'DATE';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_START_DATE';
    	l_trans_tbl(l_count).param_value := to_char(p_ccmgr_tbl(I).start_date,g_date_format);
 	    l_trans_tbl(l_count).param_data_type := 'DATE';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_CURR_END_DATE';
    	l_trans_tbl(l_count).param_value := to_char(p_ccmgr_tbl(I).current_end_date,g_date_format);
 	    l_trans_tbl(l_count).param_data_type := 'DATE';

        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_END_DATE';
    	l_trans_tbl(l_count).param_value := to_char(p_ccmgr_tbl(I).end_date,g_date_format);
 	    l_trans_tbl(l_count).param_data_type := 'DATE';

        hr_utility.set_location(l_proc ,100);
        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_REVIEW_PROC_CALL';
    	l_trans_tbl(l_count).param_value := wf_engine.GetActivityAttrText(p_item_type,p_item_key,
                                            p_activity_id, 'HR_REVIEW_REGION_ITEM', False);

 	    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

        hr_utility.set_location(l_proc ,105);
        l_count := l_count+1;
        l_trans_tbl(l_count).param_name := 'P_REVIEW_ACTID';
    	l_trans_tbl(l_count).param_value := p_activity_id;
 	    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
       hr_utility.set_location(l_proc ,110);
            hr_transaction_ss.save_transaction_step
           	        	(p_item_type => p_item_type
                   		,p_item_key => p_item_key
       	            	,p_actid => p_activity_id
               	        ,p_login_person_id => p_login_person_id
                        ,p_transaction_step_id => p_ccmgr_tbl(I).trans_step_id
                   		,p_api_name  => g_package||'.PROCESS_API'
                   		,p_transaction_data    => l_trans_tbl);
     hr_utility.set_location(l_proc ,115);
     <<exit_point>>  Null;
      commit;
      hr_utility.set_location(l_proc || 'Leaving: p_ccmgr_tbl.count Loop' ,120);
      Exception when others then
        p_status := 'E';
        p_ccmgr_tbl(I).p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                                                    p_error_message => p_ccmgr_tbl(I).p_error_message
                                                   ,p_attr_name => 'Manager'
                                                   ,p_single_error_message => substr(sqlerrm,255));
      hr_utility.set_location(l_proc  ,555);
      End;
    End Loop;
  hr_utility.set_location(' Leaving:' || l_proc,125);
  Exception when others then
    p_status := 'E';
    hr_utility.set_location(' Leaving:' || l_proc,560);
    raise;
End update_ccmgr_recs;
End HR_CCMGR_SS;

/
