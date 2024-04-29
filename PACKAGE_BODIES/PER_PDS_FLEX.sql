--------------------------------------------------------
--  DDL for Package Body PER_PDS_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDS_FLEX" as
/* $Header: pepdsfli.pkb 115.0 99/07/18 14:12:35 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pds_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< val_leav_reas_d >------------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Leaving Reason where the value is 'D' (Deceased).
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of per_pds_flex continues.
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
Procedure val_leav_reas_d
             (p_rec   in per_pds_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_leav_reas_d';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_leav_reas_d;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< val_leav_reas_x >------------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Leaving Reason where the value is 'X' (A valid value).
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of per_pds_flex continues.
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
Procedure val_leav_reas_x
             (p_rec   in per_pds_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_leav_reas_x';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_leav_reas_x;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< df >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure df
  (p_rec   in per_pds_shd.g_rec_type) is
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
    -- Reference field       => Leaving reason
    -- Reference field value => 'D' (Deceased)
    --
    if <reference field value> is <value> then
      val_leav_reas_d(p_rec => p_rec);
    --
    -- Reference field       => Assignment type
    -- Reference field value => 'X' (Another valid value)
    --
    elsif <reference field value> is <value> then
      val_leav_reas_x(p_rec => p_rec);
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
    if p_rec.attribute1 is not null then
      raise l_error;
    elsif p_rec.attribute2 is not null then
      raise l_error;
    elsif p_rec.attribute3 is not null then
      raise l_error;
    elsif p_rec.attribute4 is not null then
      raise l_error;
    elsif p_rec.attribute5 is not null then
      raise l_error;
    elsif p_rec.attribute6 is not null then
      raise l_error;
    elsif p_rec.attribute7 is not null then
      raise l_error;
    elsif p_rec.attribute8 is not null then
      raise l_error;
    elsif p_rec.attribute9 is not null then
      raise l_error;
    elsif p_rec.attribute10 is not null then
      raise l_error;
    elsif p_rec.attribute11 is not null then
      raise l_error;
    elsif p_rec.attribute12 is not null then
      raise l_error;
    elsif p_rec.attribute13 is not null then
      raise l_error;
    elsif p_rec.attribute14 is not null then
      raise l_error;
    elsif p_rec.attribute15 is not null then
      raise l_error;
    elsif p_rec.attribute16 is not null then
      raise l_error;
    elsif p_rec.attribute17 is not null then
      raise l_error;
    elsif p_rec.attribute18 is not null then
      raise l_error;
    elsif p_rec.attribute19 is not null then
      raise l_error;
    elsif p_rec.attribute20 is not null then
      raise l_error;
    end if;
/*
  end if;
  --
*/
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(801, 'HR_7439_FLEX_INV_ATTRIBUTE_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
end df;
--
end per_pds_flex;

/
