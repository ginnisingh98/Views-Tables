--------------------------------------------------------
--  DDL for Package Body HR_PAB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAB_BUS" as
/* $Header: hrpabrhi.pkb 115.1 99/07/17 05:36:11 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_pab_bus.';  -- Global package name
--
--
--
--   Business Rules
--
-- ----------------------------------------------------------------------------
-- |--------------< check_unique_patt_bit >----------------------------|
--
--  Public
--   Description
--      Ensure that the Pattern Bit Code is unique
--
Procedure check_unique_patt_bit (p_pattern_bit_code in varchar2) is
  cursor c1 is
    select  h.rowid
    from   hr_pattern_bits h
    where upper(h.pattern_bit_code) = upper(p_pattern_bit_code);
  c1_rec c1%ROWTYPE;
BEGIN
    open c1;
    fetch c1 into c1_rec;
    if c1%FOUND then
      fnd_message.set_name('PAY','HR_51023_HR_PATT_BIT');
      fnd_message.raise_error;
   end if;
   close c1;
END check_unique_patt_bit;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_pab_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
     check_unique_patt_bit (p_rec.pattern_bit_code);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_pab_shd.g_rec_type) is
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
Procedure delete_validate(p_rec in hr_pab_shd.g_rec_type) is
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
end hr_pab_bus;

/
