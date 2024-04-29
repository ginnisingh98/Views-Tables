--------------------------------------------------------
--  DDL for Package Body FF_ARC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_ARC_BUS" as
/* $Header: ffarcrhi.pkb 115.4 2002/12/23 13:59:55 arashid ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ff_arc_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- (A.M Added) chk_non_updateable_args
-- ----------------------------------------------------------------------------
--
procedure chk_non_updateable_args
  (p_rec 	in	ff_arc_shd.g_rec_type) is
--
   l_proc varchar2(72) := g_package || 'chk_non_updateable_args';
   l_error exception;
   l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
-- Only proceed with validation if a row exists for the current record
--
   if not ff_arc_shd.api_updating
       (p_archive_item_id	=>	p_rec.archive_item_id,
        p_object_version_number => 	p_rec.object_version_number)
   then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','20');
   end if;
--
   hr_utility.set_location(l_proc,30);
--
   if nvl(p_rec.user_entity_id, hr_api.g_number) <>
      nvl(ff_arc_shd.g_old_rec.user_entity_id, hr_api.g_number) then
      l_argument := 'user_entity_id';
      raise l_error;
   end if;
--
   if nvl(p_rec.context1, hr_api.g_number) <>
         nvl(ff_arc_shd.g_old_rec.context1, hr_api.g_number) then
      l_argument := 'context1';
      raise l_error;
   end if;
--
   if nvl(p_rec.archive_type, hr_api.g_varchar2) <>
         nvl(ff_arc_shd.g_old_rec.archive_type, hr_api.g_varchar2) then
      l_argument := 'archive_type';
      raise l_error;
   end if;
--
   hr_utility.set_location(l_proc,40);
--
Exception
  when l_error then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => l_argument);
  when others then raise;
  hr_utility.set_location(l_proc,50);
end chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ff_arc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Check the value's data type.
  --
  ff_arc_shd.chk_value(p_rec.value, p_rec.user_entity_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ff_arc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations .
  -- A.M. added call to check that the user has not tried
  -- to update a non-updateable column.
  --
  chk_non_updateable_args(p_rec);
  --
  -- Check the value's data type.
  --
  ff_arc_shd.chk_value(p_rec.value, p_rec.user_entity_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
end ff_arc_bus;

/
