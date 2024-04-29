--------------------------------------------------------
--  DDL for Package Body FF_CON_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_CON_BUS" as
/* $Header: ffconrhi.pkb 115.1 2002/12/23 13:59:57 arashid ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ff_con_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ff_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_context_id number;
--
  cursor chk_context_id (c_context_id number) is
  select context_id from ff_contexts
  where context_id = c_context_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Simple check on context ID as no FK constraint exists.
  --
  open chk_context_id(p_rec.context_id);
  fetch chk_context_id into l_context_id;
  close chk_context_id;
  --
  if l_context_id is null then
     raise no_data_found;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception when no_data_found then
--
-- Raise error although FK does not exist.
   ff_con_shd.constraint_error('FF_ARCHIVE_ITEM_CONTEXT_FK2');
--
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ff_con_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ff_con_shd.g_rec_type) is
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
end ff_con_bus;

/
