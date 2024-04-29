--------------------------------------------------------
--  DDL for Package Body PER_ASG_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASG_FLEX" as
/* $Header: peasgfli.pkb 115.0 99/07/17 18:37:59 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_asg_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< val_asg_type_a >------------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Assignment Type where the value is 'A' (Applicant).
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of per_asg_flex continues.
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
Procedure val_asg_type_a
             (p_rec   in per_asg_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_asg_type_a';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_asg_type_a;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< val_asg_type_e >------------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Assignment Type where the value is 'E' (Employee).
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of per_asg_flex continues.
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
Procedure val_asg_type_e
             (p_rec   in per_asg_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_asg_type_e';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_asg_type_e;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< df >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure df
  (p_rec   in per_asg_shd.g_rec_type) is
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
    -- Reference field       => Assignment type
    -- Reference field value => 'A' (Applicant assignment)
    --
    if <reference field value> is <value> then
      val_asg_type_a(p_rec => p_rec);
    --
    -- Reference field       => Assignment type
    -- Reference field value => 'E' (Employee assignment)
    --
    elsif <reference field value> is <value> then
      val_asg_type_e(p_rec => p_rec);
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
    if p_rec.ass_attribute1 is not null then
      raise l_error;
    elsif p_rec.ass_attribute2 is not null then
      raise l_error;
    elsif p_rec.ass_attribute3 is not null then
      raise l_error;
    elsif p_rec.ass_attribute4 is not null then
      raise l_error;
    elsif p_rec.ass_attribute5 is not null then
      raise l_error;
    elsif p_rec.ass_attribute6 is not null then
      raise l_error;
    elsif p_rec.ass_attribute7 is not null then
      raise l_error;
    elsif p_rec.ass_attribute8 is not null then
      raise l_error;
    elsif p_rec.ass_attribute9 is not null then
      raise l_error;
    elsif p_rec.ass_attribute10 is not null then
      raise l_error;
    elsif p_rec.ass_attribute11 is not null then
      raise l_error;
    elsif p_rec.ass_attribute12 is not null then
      raise l_error;
    elsif p_rec.ass_attribute13 is not null then
      raise l_error;
    elsif p_rec.ass_attribute14 is not null then
      raise l_error;
    elsif p_rec.ass_attribute15 is not null then
      raise l_error;
    elsif p_rec.ass_attribute16 is not null then
      raise l_error;
    elsif p_rec.ass_attribute17 is not null then
      raise l_error;
    elsif p_rec.ass_attribute18 is not null then
      raise l_error;
    elsif p_rec.ass_attribute19 is not null then
      raise l_error;
    elsif p_rec.ass_attribute20 is not null then
      raise l_error;
    elsif p_rec.ass_attribute21 is not null then
      raise l_error;
    elsif p_rec.ass_attribute22 is not null then
      raise l_error;
    elsif p_rec.ass_attribute23 is not null then
      raise l_error;
    elsif p_rec.ass_attribute24 is not null then
      raise l_error;
    elsif p_rec.ass_attribute25 is not null then
      raise l_error;
    elsif p_rec.ass_attribute26 is not null then
      raise l_error;
    elsif p_rec.ass_attribute27 is not null then
      raise l_error;
    elsif p_rec.ass_attribute28 is not null then
      raise l_error;
    elsif p_rec.ass_attribute29 is not null then
      raise l_error;
    elsif p_rec.ass_attribute30 is not null then
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
end per_asg_flex;

/
