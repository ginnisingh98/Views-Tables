--------------------------------------------------------
--  DDL for Package Body BEN_FYI_NTFN_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_FYI_NTFN_SS" as
/* $Header: befyintf.pkb 120.0.12010000.2 2008/08/05 14:26:09 ubhat ship $*/
--
-- ---------------------------------------------------------------------------+
-- Purpose: This function will set the value of the workflow attribute
--          receiver name to the seeded workflow role.
--          Workflow engine will send notification to this role.
-- ---------------------------------------------------------------------------+
g_package varchar2(60) := 'ben_fyi_ntfn_ss' ;

procedure set_role_to_send_ntfn
  (itemtype in     varchar2
  ,itemkey in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,result   out nocopy varchar2
  ) is

cursor c1 is select pqr.role_id,pqr.role_name
                  from pqh_roles pqr
                  where pqr.role_type_cd ='SSBNFT' ;

cursor c2(l_role_id number) is
                  select pei.person_id,
                  ppf.full_name,
                  usr.user_name,
                  usr.user_id user_id
                  from per_people_extra_info pei,
                  per_all_people_f ppf,
                  fnd_user usr,
                  pqh_roles rls
                  where pei.information_type = 'PQH_ROLE_USERS'
                  and pei.person_id = ppf.person_id
                  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
                  and usr.employee_id = ppf.person_id
                  and rls.role_id = to_number(pei.pei_information3)
                  and nvl(pei.pei_information5,'Y')='Y'
                  and rls.role_id = l_role_id;

l_proc varchar2(61) := g_package||':'||'set_role_to_send_ntfn';

begin
--
--hr_utility.set_location(l_proc || ' Entering ',10);
--
for role_rec in c1 loop
  --hr_utility.set_location('checking people for role '||role_rec.role_name,20);
  for user_in_role in c2(role_rec.role_id) loop
    --hr_utility.set_location('user '||user_in_role.user_name||' has this role ',20);
    --6773021
    wf_engine.SetItemAttrText(itemtype => itemtype
                          ,itemkey => itemkey
                          ,aname  => 'RECEIVER_NAME'
                          ,avalue => role_rec.role_name);
  end loop;
end loop;
--
--hr_utility.set_location(l_proc || ' Exiting ',100);
--
result := 'COMPLETE:';
--
exception
--
when others then
--
  result := null;
  raise;
--
end set_role_to_send_ntfn;
--
-- This function is currently not used anywhere
--
procedure build_url(
           p_item_type                 in varchar2
          ,p_item_key                  in varchar2
          ,p_from_ntfn                 in varchar2 default 'Y'
          ) is

l_proc  varchar2(61) := g_package||':'||'build_url';
l_process_name varchar2(100);
l_url   varchar2(2000);
l_param varchar2(2000);
--
begin
--
hr_utility.set_location('Entering'||l_proc,10);
--
l_url := wf_engine.GetItemAttrText(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname    => 'NTFN_LINK_TO_REVIEW');
--
l_process_name := wf_engine.GetItemAttrText(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname    => 'PROCESS_NAME');
--
l_url := l_url||'&'||'pItemType='||p_item_type||'&'||'pItemKey='||p_item_key||'&'||'pProcessName='||l_process_name||'&'||'pFromNtfn='||p_from_ntfn;
--
hr_utility.set_location('Leaving'||l_proc,10);
--
wf_engine.SetItemAttrText(itemtype => p_item_type
                          ,itemkey => p_item_key
                          ,aname  => 'NTFN_LINK_TO_REVIEW'
                          ,avalue => l_url);
--
end;
--
end ben_fyi_ntfn_ss;

/
