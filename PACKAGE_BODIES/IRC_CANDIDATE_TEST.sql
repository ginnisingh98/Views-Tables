--------------------------------------------------------
--  DDL for Package Body IRC_CANDIDATE_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CANDIDATE_TEST" as
/* $Header: ircndtst.pkb 120.0 2005/07/26 14:59:58 mbocutt noship $ */
--Package Variables
--
g_package varchar2(33) := 'irc_candidate_test.';
--
-- -------------------------------------------------------------------------
-- |------------------------< is_person_a_candidate >----------------------|
-- -------------------------------------------------------------------------
--
function is_person_a_candidate
(p_person_id in number)
return boolean is
cursor c_party is
select per.party_id
from per_all_people_f per
where per.person_id=p_person_id
and sysdate between per.effective_start_date and per.effective_end_date;
l_party_id number;
--
cursor c_person is
select 1 from per_person_type_usages_f ptu
, per_person_types ppt
where  ptu.person_id=p_person_id
and ppt.person_type_id=ptu.person_type_id
and ppt.system_person_type='IRC_REG_USER'
and sysdate between ptu.effective_start_date and ptu.effective_end_date;
--
cursor c_person_party is
select 1 from per_person_type_usages_f ptu
, per_person_types ppt
,per_all_people_f per
where  ptu.person_id=per.person_id
and ppt.person_type_id=ptu.person_type_id
and ppt.system_person_type='IRC_REG_USER'
and sysdate between ptu.effective_start_date and ptu.effective_end_date
and per.party_id=l_party_id
and sysdate between per.effective_start_date and per.effective_end_date;
--
l_dummy number;
l_candidate boolean :=false;
l_proc          varchar2(72) := g_package||'is_person_a_candidate';
begin
  hr_utility.set_location(' Entering: '||l_proc, 10);
  open c_party;
  fetch c_party into l_party_id;
  close c_party;
  if l_party_id is null then
    hr_utility.set_location(l_proc, 20);
    open c_person;
    fetch c_person into l_dummy;
    if c_person%found then
      close c_person;
      l_candidate:=true;
    else
      close c_person;
    end if;
  else
    hr_utility.set_location(l_proc, 30);
    open c_person_party;
    fetch c_person_party into l_dummy;
    if c_person_party%found then
      close c_person_party;
      l_candidate:=true;
    else
      close c_person_party;
    end if;
  end if;
  hr_utility.set_location(' Leaving: '||l_proc, 20);
  return l_candidate;
end is_person_a_candidate;
end irc_candidate_test;

/
