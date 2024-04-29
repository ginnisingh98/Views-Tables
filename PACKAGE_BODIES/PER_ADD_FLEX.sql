--------------------------------------------------------
--  DDL for Package Body PER_ADD_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ADD_FLEX" as
/* $Header: peaddfli.pkb 115.0 99/07/17 18:25:53 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_add_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< val_add_type_gb >-----------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Country where the value is 'GB' (Great Britain).
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of per_add_flex continues.
--
--  Post failure:
--    Processing will be suspended if the descriptive flexfield validation
--    fails.
--
--  Developer Implementation Notes:
--    Customer defined.
--
--  Access Status:
--    From df procedure only.
--
--  {End of Comments}
-- ----------------------------------------------------------------------------
Procedure val_add_type_gb
             (p_rec   in per_add_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_add_type_gb';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_add_type_gb;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< val_add_type_us >-----------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Country where the value is 'US' (USA).
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of per_add_flex continues.
--
--  Post failure:
--    Processing will be suspended if the descriptive flexfield validation
--    fails.
--
--  Developer Implementation Notes:
--    Customer defined.
--
--  Access Status:
--    From df procedure only.
--
--  {End of Comments}
-- ----------------------------------------------------------------------------
Procedure val_add_type_us
             (p_rec   in per_add_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_add_type_us';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_add_type_us;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< df >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure df
  (p_rec   in per_add_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'df';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
/*
  -- Check for value of reference field an then
  -- call relevant validation procedure.
  --
  if <reference field value> is not null then
    --
    -- Reference field       => Country
    -- Reference field value => 'GB' (Great Britain)
    --
    if <reference field value> is <value> then
      val_add_type_gb(p_rec => p_rec);
    --
    -- Reference field       => Country
    -- Reference field value => 'US' (USA)
    --
    elsif <reference field value> is <value> then
      val_add_type_us(p_rec => p_rec);
    else
      --
      -- Reference field values is not supported
      --
      hr_utility.set_message(801, 'HR_7438_FLEX_INV_REF_FIELD_VAL');
      hr_utility.raise_error;
    end if;
  else
*/
    --
    -- When the reference field is null, check
    -- that none of the attribute fields have
    -- been set
    --
    if p_rec.addr_attribute1 is not null then
      raise l_error;
    elsif p_rec.addr_attribute2 is not null then
      raise l_error;
    elsif p_rec.addr_attribute3 is not null then
      raise l_error;
    elsif p_rec.addr_attribute4 is not null then
      raise l_error;
    elsif p_rec.addr_attribute5 is not null then
      raise l_error;
    elsif p_rec.addr_attribute6 is not null then
      raise l_error;
    elsif p_rec.addr_attribute7 is not null then
      raise l_error;
    elsif p_rec.addr_attribute8 is not null then
      raise l_error;
    elsif p_rec.addr_attribute9 is not null then
      raise l_error;
    elsif p_rec.addr_attribute10 is not null then
      raise l_error;
    elsif p_rec.addr_attribute11 is not null then
      raise l_error;
    elsif p_rec.addr_attribute12 is not null then
      raise l_error;
    elsif p_rec.addr_attribute13 is not null then
      raise l_error;
    elsif p_rec.addr_attribute14 is not null then
      raise l_error;
    elsif p_rec.addr_attribute15 is not null then
      raise l_error;
    elsif p_rec.addr_attribute16 is not null then
      raise l_error;
    elsif p_rec.addr_attribute17 is not null then
      raise l_error;
    elsif p_rec.addr_attribute18 is not null then
      raise l_error;
    elsif p_rec.addr_attribute19 is not null then
      raise l_error;
    elsif p_rec.addr_attribute20 is not null then
      raise l_error;
    end if;
/*
  end if;
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(801, 'HR_7439_FLEX_INV_ATTRIBUTE_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
end df;
--
end per_add_flex;

/
