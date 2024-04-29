--------------------------------------------------------
--  DDL for Package Body IRC_REGISTER_EX_EMP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_REGISTER_EX_EMP_WF" as
/* $Header: irexempr.pkb 120.2 2005/11/23 01:01:58 gjaggava noship $ */
--Package Variables
--
g_package varchar2(33) := 'irc_register_ex_emp_wf.';
--
-- -------------------------------------------------------------------------
-- |------------------------< self_register_user_save >------------------|
-- -------------------------------------------------------------------------
--
procedure self_register_user_save
(itemtype in varchar2,
itemkey in varchar2,
actid in number,
funcmode in varchar2,
resultout out nocopy varchar2) is
l_current_email_address          varchar2(255);
l_responsibility_id              number;
l_resp_appl_id                   number;
l_security_group_id              number;
l_first_name                     varchar2(255);
l_last_name                      varchar2(255);
l_middle_names                   varchar2(255);
l_previous_last_name             varchar2(255);
l_employee_number                varchar2(255);
l_national_identifier            varchar2(255);
l_date_of_birth                  date;
l_email_address                  varchar2(255);
l_home_phone_number              varchar2(255);
l_work_phone_number              varchar2(255);
l_address_line_1                 varchar2(255);
l_manager_last_name              varchar2(255);
l_allow_access                   varchar2(255);
l_language                       varchar2(255);
l_user_name                      varchar2(255);
l_proc          varchar2(72) := g_package||'self_register_user_save';
begin
  hr_utility.set_location(' Entering: '||l_proc, 10);
  if (funcmode='RUN') then
    hr_utility.set_location(l_proc,20);

    l_current_email_address:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'CURRENT_EMAIL_ADDRESS');
    l_responsibility_id:=wf_engine.getItemAttrNumber
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'RESPONSIBILITY_ID');
    l_resp_appl_id:=wf_engine.getItemAttrNumber
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'RESP_APPL_ID');
    l_security_group_id:=wf_engine.getItemAttrNumber
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'SECURITY_GROUP_ID');
    l_first_name:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'FIRST_NAME');
    l_last_name:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'LAST_NAME');
    l_middle_names:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'MIDDLE_NAMES');
    l_previous_last_name:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'PREVIOUS_LAST_NAME');
    l_employee_number:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'EMPLOYEE_NUMBER');
    l_national_identifier:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'NATIONAL_IDENTIFIER');
    l_date_of_birth:=wf_engine.getItemAttrDate
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'DATE_OF_BIRTH');
    l_email_address:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'EMAIL_ADDRESS');
    l_home_phone_number:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'HOME_PHONE_NUMBER');
    l_work_phone_number:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'WORK_PHONE_NUMBER');
    l_address_line_1:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'ADDRESS_LINE_1');
    l_manager_last_name:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'MANAGER_LAST_NAME');
    l_allow_access:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'ALLOW_ACCESS');
    l_language:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'LANGUAGE');
    l_user_name:=wf_engine.getItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'USER_NAME');

  hr_utility.set_location(l_proc,30);

    IRC_PARTY_API.SELF_REGISTER_USER
    (p_current_email_address                 => l_current_email_address
    ,p_responsibility_id                     => l_responsibility_id
    ,p_resp_appl_id                          => l_resp_appl_id
    ,p_security_group_id                     => l_security_group_id
    ,p_first_name                            => l_first_name
    ,p_last_name                             => l_last_name
    ,p_middle_names                          => l_middle_names
    ,p_previous_last_name                    => l_previous_last_name
    ,p_employee_number                       => l_employee_number
    ,p_national_identifier                   => l_national_identifier
    ,p_date_of_birth                         => l_date_of_birth
    ,p_email_address                         => l_email_address
    ,p_home_phone_number                     => l_home_phone_number
    ,p_work_phone_number                     => l_work_phone_number
    ,p_address_line_1                        => l_address_line_1
    ,p_manager_last_name                     => l_manager_last_name
    ,p_allow_access                          => l_allow_access
    ,p_language                              => l_language
    ,p_user_name                             => l_user_name
    );
    resultout:='COMPLETE';
    hr_utility.set_location('Leaving: '||l_proc,40);

    return;
  end if;
  exception
  when others then
    hr_utility.set_location(l_proc,50);

    wf_core.context('IRC_REGISTER_EX_EMP_WF'
                   ,'SELF_REGISTER_USER_SAVE'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);

    raise;
  end self_register_user_save;

procedure self_register_user_init
   (p_current_email_address     IN     varchar2
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_first_name                IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_middle_names              IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_employee_number           IN     varchar2 default null
   ,p_national_identifier       IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_home_phone_number         IN     varchar2 default null
   ,p_work_phone_number         IN     varchar2 default null
   ,p_address_line_1            IN     varchar2 default null
   ,p_manager_last_name         IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default 'N'
   ,p_language                  IN     varchar2 default null
   ,p_user_name                 IN     varchar2 default null
   ) is
l_proc          varchar2(72) := g_package||'self_register_user_init';
itemtype varchar2(30):='IRC_REG';
itemkey varchar2(30);
begin
  hr_utility.set_location(' Entering: '||l_proc, 10);
  --
  select irc_wf_s.nextval
  into itemkey
  from dual;
  --
  wf_engine.CreateProcess (itemtype => itemtype,
                           itemkey => itemkey,
                           process => 'REG_REQUEST' );

    hr_utility.set_location(l_proc,20);

    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'CURRENT_EMAIL_ADDRESS',
                 avalue   => p_current_email_address);
    wf_engine.setItemAttrNumber
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'RESPONSIBILITY_ID',
                 avalue   => p_responsibility_id);
    wf_engine.setItemAttrNumber
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'RESP_APPL_ID',
                 avalue   => p_resp_appl_id);
    wf_engine.setItemAttrNumber
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'SECURITY_GROUP_ID',
                 avalue   => p_security_group_id);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'FIRST_NAME',
                 avalue   => p_first_name);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'LAST_NAME',
                 avalue   => p_last_name);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'MIDDLE_NAMES',
                 avalue   => p_middle_names);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'PREVIOUS_LAST_NAME',
                 avalue   => p_previous_last_name);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'EMPLOYEE_NUMBER',
                 avalue   => p_employee_number);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'NATIONAL_IDENTIFIER',
                 avalue   => p_national_identifier);
    wf_engine.setItemAttrDate
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'DATE_OF_BIRTH',
                 avalue   => p_date_of_birth);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'EMAIL_ADDRESS',
                 avalue   => p_email_address);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'HOME_PHONE_NUMBER',
                 avalue   => p_home_phone_number);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'WORK_PHONE_NUMBER',
                 avalue   => p_work_phone_number);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'ADDRESS_LINE_1',
                 avalue   => p_address_line_1);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'MANAGER_LAST_NAME',
                 avalue   => p_manager_last_name);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'ALLOW_ACCESS',
                 avalue   => p_allow_access);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'LANGUAGE',
                 avalue   => p_language);
    wf_engine.setItemAttrText
                (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'USER_NAME',
                 avalue   => p_user_name);
    hr_utility.set_location(l_proc,30);

    wf_engine.StartProcess (itemtype => itemtype,
    itemkey => itemkey );
    hr_utility.set_location('Leaving: '||l_proc,40);
  exception
  when others then
    wf_core.context('IRC_REGISTER_EX_EMP_WF'
                   ,'SELF_REGISTER_USER_INIT'
                   ,itemtype
                   ,itemkey);

    raise;

  end self_register_user_init;
end irc_register_ex_emp_wf;

/
