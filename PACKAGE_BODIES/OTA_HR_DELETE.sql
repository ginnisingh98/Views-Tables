--------------------------------------------------------
--  DDL for Package Body OTA_HR_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_HR_DELETE" as
/* $Header: otdhr01t.pkb 115.0 99/07/16 00:51:19 porting ship $ */
--
g_package  varchar2(33)	:= '  ota_hr_delete.';  -- Global package name
--
Procedure check_delete(p_person_id       number default null
                      ,p_organization_id number default null
                      ,p_job_id          number default null
                      ,p_position_id     number default null
                      ,p_address_id      number default null
                      ,p_analysis_criteria_id number default null
                      ) is
--
  l_proc 	varchar2(72) := g_package||'check_delete';
  l_exists      varchar2(1);
--
  cursor c_activity_versions1 is
  select null
  from  ota_activity_versions
  where controlling_person_id = p_person_id;
--
  cursor c_activity_versions2 is
  select null
  from  ota_activity_versions
  where developer_organization_id = p_organization_id;
--
  cursor c_delegate_bookings1 is
  select null
  from   ota_delegate_bookings
  where  delegate_person_id = p_person_id;
--
  cursor c_delegate_bookings2 is
  select null
  from   ota_delegate_bookings
  where  sponsor_person_id = p_person_id;
--
  cursor c_delegate_bookings3 is
  select null
  from   ota_delegate_bookings
  where  organization_id = p_organization_id;
--
  cursor c_delegate_bookings4 is
  select null
  from   ota_delegate_bookings
  where  person_address_id = p_address_id;
--
  cursor c_events is
  select null
  from   ota_events
  where  organization_id = p_organization_id;
--
  cursor c_event_associations1 is
  select null
  from   ota_event_associations
  where  organization_id = p_organization_id;
--
  cursor c_event_associations2 is
  select null
  from   ota_event_associations
  where  job_id = p_job_id;
--
  cursor c_event_associations3 is
  select null
  from   ota_event_associations
  where  position_id = p_position_id;
--
  cursor c_finance_headers1 is
  select null
  from   ota_finance_headers
  where  organization_id = p_organization_id;
--
  cursor c_skill_provisions is
  select null
  from   ota_skill_provisions
  where  analysis_criteria_id = p_analysis_criteria_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_person_id is not null then
     --
  hr_utility.set_location('Entering:'||l_proc, 10);
     open c_activity_versions1;
     fetch c_activity_versions1 into l_exists;
     if c_activity_versions1%found then
        close c_activity_versions1;
        fnd_message.set_name('OTA','OTA_13546_PERSON_DELETE');
        fnd_message.set_token('TABLE','OTA_ACTIVITY_VERSIONS');
        fnd_message.set_token('COLUMN','CONTROLLING_PERSON_ID');
        fnd_message.raise_error;
     end if;
     close c_activity_versions1;
     --
  hr_utility.set_location('Entering:'||l_proc, 15);
     open c_delegate_bookings1;
     fetch c_delegate_bookings1 into l_exists;
     if c_delegate_bookings1%found then
        close c_delegate_bookings1;
        fnd_message.set_name('OTA','OTA_13546_PERSON_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','DELEGATE_PERSON_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings1;
     --
  hr_utility.set_location('Entering:'||l_proc, 20);
     open c_delegate_bookings2;
     fetch c_delegate_bookings2 into l_exists;
     if c_delegate_bookings2%found then
        close c_delegate_bookings2;
        fnd_message.set_name('OTA','OTA_13546_PERSON_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','SPONSOR_PERSON_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings2;
     --
  elsif p_organization_id is not null then
  --
  hr_utility.set_location('Entering:'||l_proc, 25);
     open c_events;
     fetch c_events into l_exists;
     if c_events%found then
        close c_events;
        fnd_message.set_name('OTA','OTA_13547_ORGANIZATION_DELETE');
        fnd_message.set_token('TABLE','OTA_EVENTS');
        fnd_message.set_token('COLUMN','ORGANIZATION_ID');
        fnd_message.raise_error;
     end if;
     close c_events;
     --
  hr_utility.set_location('Entering:'||l_proc, 30);
     open c_activity_versions2;
     fetch c_activity_versions2 into l_exists;
     if c_activity_versions2%found then
        close c_activity_versions2;
        fnd_message.set_name('OTA','OTA_13547_ORGANIZATION_DELETE');
        fnd_message.set_token('TABLE','OTA_ACTIVITY_VERSIONS');
        fnd_message.set_token('COLUMN','DEVELOPER_ORGANIZATION_ID');
        fnd_message.raise_error;
     end if;
     close c_activity_versions2;
     --
  hr_utility.set_location('Entering:'||l_proc, 35);
     open c_finance_headers1;
     fetch c_finance_headers1 into l_exists;
     if c_finance_headers1%found then
        close c_finance_headers1;
        fnd_message.set_name('OTA','OTA_13547_ORGANIZATION_DELETE');
        fnd_message.set_token('TABLE','OTA_FINANCE_HEADERS');
        fnd_message.set_token('COLUMN','ORGANIZATION_ID');
        fnd_message.raise_error;
     end if;
     close c_finance_headers1;
     --
  hr_utility.set_location('Entering:'||l_proc, 40);
     open c_delegate_bookings3;
     fetch c_delegate_bookings3 into l_exists;
     if c_delegate_bookings3%found then
        close c_delegate_bookings3;
        fnd_message.set_name('OTA','OTA_13547_ORGANIZATION_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','ORGANIZATION_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings3;
     --
  hr_utility.set_location('Entering:'||l_proc, 45);
     open c_event_associations1;
     fetch c_event_associations1 into l_exists;
     if c_event_associations1%found then
        close c_event_associations1;
        fnd_message.set_name('OTA','OTA_13547_ORGANIZATION_DELETE');
        fnd_message.set_token('TABLE','OTA_EVENT_ASSOCIATIONS');
        fnd_message.set_token('COLUMN','ORGANIZATION_ID');
        fnd_message.raise_error;
     end if;
     close c_event_associations1;
     --
  elsif p_job_id is not null then
  --
  hr_utility.set_location('Entering:'||l_proc, 50);
     open c_event_associations2;
     fetch c_event_associations2 into l_exists;
     if c_event_associations2%found then
        close c_event_associations2;
        fnd_message.set_name('OTA','OTA_13548_JOB_DELETE');
        fnd_message.set_token('TABLE','OTA_EVENT_ASSOCIATIONS');
        fnd_message.set_token('COLUMN','JOB_ID');
        fnd_message.raise_error;
     end if;
     close c_event_associations2;
     --
  elsif p_position_id is not null then
  --
  hr_utility.set_location('Entering:'||l_proc, 55);
     open c_event_associations3;
     fetch c_event_associations3 into l_exists;
     if c_event_associations3%found then
        close c_event_associations3;
        fnd_message.set_name('OTA','OTA_13549_POSITION_DELETE');
        fnd_message.set_token('TABLE','OTA_EVENT_ASSOCIATIONS');
        fnd_message.set_token('COLUMN','POSITION_ID');
        fnd_message.raise_error;
     end if;
     close c_event_associations3;
     --
  elsif p_address_id is not null then
  --
  hr_utility.set_location('Entering:'||l_proc, 60);
     open c_delegate_bookings4;
     fetch c_delegate_bookings4 into l_exists;
     if c_delegate_bookings4%found then
        close c_delegate_bookings4;
        fnd_message.set_name('OTA','OTA_13550_ADDRESS_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','PERSON_ADDRESS_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings4;
     --
  elsif p_analysis_criteria_id is not null then
  --
  hr_utility.set_location('Entering:'||l_proc, 65);
     open c_skill_provisions;
     fetch c_skill_provisions into l_exists;
     if c_skill_provisions%found then
        close c_skill_provisions;
        fnd_message.set_name('OTA','OTA_13551_ANAL_CRIT_DELETE');
        fnd_message.set_token('TABLE','OTA_SKILL_PROVISIONS');
        fnd_message.set_token('COLUMN','ANALYSIS_CRITERIA_ID');
        fnd_message.raise_error;
     end if;
     close c_skill_provisions;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end;
--
end ota_hr_delete;

/
