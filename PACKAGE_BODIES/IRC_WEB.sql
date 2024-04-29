--------------------------------------------------------
--  DDL for Package Body IRC_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_WEB" as
/* $Header: ircweb.pkb 120.0 2005/07/26 15:02:28 mbocutt noship $ */

procedure show_vacancy (M in VARCHAR2) is

    l_text                  varchar2(2000);
    l_parameters            icx_on_utilities.v80_table;
    l_url                   varchar2(2000);
    l_vacancy_id varchar2(30);
    l_posting_id varchar2(30);
    l_function_name fnd_form_functions.function_name%type;
    --
    l_b boolean;
    --
    cursor csr_posting(p_vac_id number) is
      select to_char(pra.posting_content_id)
      from per_recruitment_activities pra
      ,per_recruitment_activity_for prf
      where prf.vacancy_id=p_vac_id
      and pra.recruitment_activity_id=prf.recruitment_activity_id
      and pra.posting_content_id is not null
      order by pra.date_start;
begin
--
  l_b:= icx_sec.validateSession(c_validate_only=>'Y');
--
  l_function_name:=fnd_profile.value('IRC_JOB_NOTIFICATION_URL');
--
  l_text := icx_call.decrypt(M);
  icx_on_utilities.unpack_parameters(l_text,l_parameters);
  l_vacancy_id:=l_parameters(1);
--
  open csr_posting(to_number(l_vacancy_id));
  fetch csr_posting into l_posting_id;
  close csr_posting;
--
  if (fnd_function.test(l_function_name)) then
-- for createExecLink, p_url_only must be N to not get the link html
    l_url:=icx_portlet.createExecLink
    (p_function_id=>fnd_function.get_function_id(l_function_name)
    ,p_application_id=>fnd_global.resp_appl_id
    ,p_responsibility_id=>fnd_global.resp_id
    ,p_security_group_id=>fnd_global.security_group_id
    ,p_parameters=>'p_svid='||l_vacancy_id||'&'||'p_spid='||l_posting_id
    ,p_url_only=>'Y'
    ,p_link_name=>'Not needed'
    );
  else
-- for createExecLink2, p_url_only must be Y to not get the link html
    l_url:=icx_portlet.createExecLink2
    (p_function_name=>l_function_name
    ,p_application_short_name=>'PER'
    ,p_responsibility_key=>'IRC_EXT_SITE_VISITOR'
    ,p_security_group_key=>'STANDARD'
    ,p_parameters=>'p_svid='||l_vacancy_id||'&'||'p_spid='||l_posting_id
    ,p_url_only=>'Y'
    ,p_link_name=>'Not needed'
    );
  end if;
  htp.p('<META HTTP-EQUIV=Refresh CONTENT="1; URL='||l_url||'">');

END show_vacancy;

--
-- this procedure is only included for backwards compatibility with the party links.
--

procedure show_candidate (M in VARCHAR2) is

    l_text                  varchar2(2000);
    l_parameters            icx_on_utilities.v80_table;
    l_url                   varchar2(2000);
    l_party_id varchar2(30);
    l_function_name fnd_form_functions.function_name%type;
    l_session_id number;
    --
    l_b boolean;
    cursor c1 is
    select person_id
    from per_all_people_f
    where party_id=l_party_id
    and business_group_id=fnd_profile.value('IRC_REGISTRATION_BG_ID');
    --
    cursor c2 is
    select person_id
    from per_all_people_f
    where party_id=l_party_id
    order by effective_start_date;
    --
    l_person_id number;
begin
--
  l_b:= icx_sec.validateSession(c_validate_only=>'Y');
--
  l_function_name:=fnd_profile.value('IRC_SUITABLE_SEEKERS_URL');
--
  l_text := icx_call.decrypt(M);
  icx_on_utilities.unpack_parameters(l_text,l_parameters);
  l_party_id:=l_parameters(1);
  open c1;
  fetch c1 into l_person_id;
  if c1%notfound then
    close c1;
    open c2;
    fetch c2 into l_person_id;
    close c2;
  else
    close c1;
  end if;

  l_session_id:=icx_sec.getSessionCookie;

OracleApps.runFunction(c_function_id=>fnd_function.get_function_id(l_function_name)
                      ,n_session_id=>l_session_id
                      ,c_parameters=>'addBreadCrumb=RP&retainAM=Yp_sprsn='||l_person_id);
END show_candidate;

procedure show_approval (M in VARCHAR2) is

    l_text                  varchar2(2000);
    l_parameters            icx_on_utilities.v80_table;
    l_url                   varchar2(2000);
    itemkey varchar2(30);
    l_function_name fnd_form_functions.function_name%type;
    itemtype varchar2(30);
    l_transaction_id varchar2(80);
    apr_object_type  varchar2(240);
    approval_process varchar2(4000);
    l_session_id number;
  --
    l_b boolean;
begin
--
-- validate the session (without getting a login prompt
-- so that the profile options and so on are available
-- in this session
--
  l_b:= icx_sec.validateSession(c_validate_only=>'Y');
  l_session_id:=icx_sec.getSessionCookie;
--
  l_text := icx_call.decrypt(M);
  icx_on_utilities.unpack_parameters(l_text,l_parameters);
  itemkey:=l_parameters(1);
  --
  itemtype:=fnd_profile.value('IRC_WORKFLOW_ITEM_TYPE');
  --
 l_transaction_id := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRC_APPROVE_TRANS_ID');
  --
  apr_object_type := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALITEM');
  --
  approval_process := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALPROCESS');
  --
  l_function_name:=fnd_profile.value('IRC_'||apr_object_type||'_APPROVAL_URL');
  --
  -- test to see if the responsibility that we are running in has access to the
  -- standard function
  --
  if not (fnd_function.test(l_function_name)) then
    -- if we do not have access to the standard function, access one which
    -- does not have the menus on it.
    l_function_name:=l_function_name||'_EXT';
    -- redirect to the function, passing the approval transaction id
    OracleApps.runFunction(c_function_id=>fnd_function.get_function_id(l_function_name)
                        ,n_session_id=>l_session_id
                        ,c_parameters=>'ext=Y&approvalTransactionId=' || l_transaction_id);
  else
    -- redirect to the function with menus, passing the approval transaction id
    OracleApps.runFunction(c_function_id=>fnd_function.get_function_id(l_function_name)
                        ,n_session_id=>l_session_id
                        ,c_parameters=>'ext=N&approvalTransactionId=' || l_transaction_id);
  end if;
END show_approval;
--
procedure correct_approval (M in VARCHAR2) is

    l_text                  varchar2(2000);
    l_parameters            icx_on_utilities.v80_table;
    l_url                   varchar2(2000);
    itemkey varchar2(30);
    l_function_name fnd_form_functions.function_name%type;
    itemtype varchar2(30);
    l_transaction_id varchar2(80);
    apr_object_type  varchar2(240);
    approval_process varchar2(4000);
    l_session_id number;
  --
    l_b boolean;
begin
--
-- validate the session (without getting a login prompt
-- so that the profile options and so on are available
-- in this session
--
  l_b:= icx_sec.validateSession(c_validate_only=>'Y');
  l_session_id:=icx_sec.getSessionCookie;
--
  l_text := icx_call.decrypt(M);
  icx_on_utilities.unpack_parameters(l_text,l_parameters);
  itemkey:=l_parameters(1);
  l_function_name:=l_parameters(2);
  --
  itemtype:=fnd_profile.value('IRC_WORKFLOW_ITEM_TYPE');
  --
  l_transaction_id := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRC_APPROVE_TRANS_ID');
  --
  apr_object_type := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALITEM');
  --
  approval_process := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALPROCESS');
  --
  OracleApps.runFunction(c_function_id=>fnd_function.get_function_id(l_function_name)
                      ,n_session_id=>l_session_id
                      ,c_parameters=>'correctionTransactionId=' || l_transaction_id);

END correct_approval;
--
end irc_web;

/
