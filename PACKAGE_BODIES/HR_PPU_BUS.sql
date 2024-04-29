--------------------------------------------------------
--  DDL for Package Body HR_PPU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PPU_BUS" as
/* $Header: hrppurhi.pkb 115.1 99/07/17 05:36:57 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_ppu_bus.';  -- Global package name
--
--
--  Business Validation Section
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_ppu_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_ppu_shd.g_rec_type) is
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_ppu_shd.g_rec_type) is
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
end hr_ppu_bus;

/
