--------------------------------------------------------
--  DDL for Package Body OTA_PMM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_PMM_BUS" as
/* $Header: otpmm01t.pkb 115.2 99/07/16 00:53:06 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_pmm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CHECK_DUPLICATE_MEMBER >---------------------|
-- ----------------------------------------------------------------------------
/*
CHECK_DUPLICATE_MEMBER
Duplicate events should not be allowed on any one Program
*/
--
procedure CHECK_DUPLICATE_MEMBER (p_program_membership_id number
                                 ,p_program_event_id      number
                                 ,p_event_id              number) is
l_duplicate varchar2(1);
--
cursor get_duplicate is
select null
from   ota_program_memberships
where  program_event_id    = p_program_event_id
and    event_id            = p_event_id
and   (p_program_membership_id is null or
      (p_program_membership_id is not null and
       p_program_membership_id <> program_membership_id));
begin
  open  get_duplicate;
  fetch get_duplicate into l_duplicate;
  if get_duplicate%found then
     close get_duplicate;
     fnd_message.set_name('OTA','OTA_13428_PMM_DUPLICATE');
     fnd_message.raise_error;
  end if;
  close get_duplicate;
end CHECK_DUPLICATE_MEMBER;
--
-- ----------------------------------------------------------------------------
-- |------------------------< event_status_ok >--------------------------------
-- ----------------------------------------------------------------------------
--
-- Checks whether a program member has the correct event status based on the
-- event status of the program
--
procedure event_status_ok(p_event_id         in number,
			  p_program_event_id in number) is
  --
  l_dummy varchar2(1);
  l_proc varchar2(72) := g_package||' event_status_ok';
  l_error boolean := false;
  --
  cursor c1 is
    select null
    from   ota_events evt
    where  evt.event_id = p_program_event_id
    and    evt.event_status = 'N'
    and    exists (select null
		   from   ota_events evt2
		   where  evt2.event_id = p_event_id
		   and    evt2.event_status = 'P');
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      -- Event is planned whereas program is normal.
      --
      l_error := true;
      --
    end if;
    --
  close c1;
  --
  if l_error then
    --
    fnd_message.set_name('OTA','OTA_13607_PMM_EVENT_PLANNED');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end event_status_ok;
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_pmm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  CHECK_DUPLICATE_MEMBER(p_program_membership_id => p_rec.program_membership_id
                        ,p_program_event_id      => p_rec.program_event_id
                        ,p_event_id              => p_rec.event_id);
  --
  event_status_ok(p_rec.event_id,
		  p_rec.program_event_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ota_pmm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  CHECK_DUPLICATE_MEMBER(p_program_membership_id => p_rec.program_membership_id
                        ,p_program_event_id      => p_rec.program_event_id
                        ,p_event_id              => p_rec.event_id);
  --
  event_status_ok(p_rec.event_id,
		  p_rec.program_event_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_pmm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_pmm_bus;

/
