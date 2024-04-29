--------------------------------------------------------
--  DDL for Package Body HR_LEI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEI_FLEX_DDF" as
/* $Header: hrleiddf.pkb 115.0 99/07/17 16:40:26 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= 'hr_lei_flex_ddf.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< val_info_type_y >------------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Information Type where the value is 'Y'.
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of hr_lei_flex_ddf continues.
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
Procedure val_info_type_y
             (p_rec   in per_asg_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_info_type_y';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_info_type_y;
-- ----------------------------------------------------------------------------
-- |--------------------------< val_info_type_x >------------------------------|
-- ----------------------------------------------------------------------------
--  {Start of Comments}
--
--  Description:
--    This procedure performs the descriptive flexfield validation for the
--    reference field - Information Type where the value is 'X'.
--
--  Pre Conditions:
--    None
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    Processing of hr_lei_flex_ddf continues.
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
Procedure val_info_type_x
             (p_rec   in per_asg_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'val_info_type_x';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Enter procedure code here
  --
  hr_utility.set_location(' Leaving:'||l_proc, 2);
end val_info_type_x;
-- ----------------------------------------------------------------------------
-- |-------------------------------< ddf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure ddf
  (p_rec   in hr_lei_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'ddf';
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
    -- Reference field       => Information type
    -- Reference field value => 'X'
    --
    if <reference field value> is <value> then
      val_info_type_x(p_rec => p_rec);
    --
    -- Reference field       => Information type
    -- Reference field value => 'Y'
    --
    elsif <reference field value> is <value> then
      val_info_type_x(p_rec => p_rec);
    else
      --
      -- Reference field values is not supported
      --
      hr_utility.set_message(801, 'HR_7438_FLEX_INV_REF_FIELD_VAL');
      hr_utility.raise_error;
    end if;
  else
    --
    -- When the reference field is null, check
    -- that none of the attribute fields have
    -- been set
    --
*/
    if p_rec.lei_information1 is not null then
      raise l_error;
    elsif p_rec.lei_information2 is not null then
      raise l_error;
    elsif p_rec.lei_information3 is not null then
      raise l_error;
    elsif p_rec.lei_information4 is not null then
      raise l_error;
    elsif p_rec.lei_information5 is not null then
      raise l_error;
    elsif p_rec.lei_information6 is not null then
      raise l_error;
    elsif p_rec.lei_information7 is not null then
      raise l_error;
    elsif p_rec.lei_information8 is not null then
      raise l_error;
    elsif p_rec.lei_information9 is not null then
      raise l_error;
    elsif p_rec.lei_information10 is not null then
      raise l_error;
    elsif p_rec.lei_information11 is not null then
      raise l_error;
    elsif p_rec.lei_information12 is not null then
      raise l_error;
    elsif p_rec.lei_information13 is not null then
      raise l_error;
    elsif p_rec.lei_information14 is not null then
      raise l_error;
    elsif p_rec.lei_information15 is not null then
      raise l_error;
    elsif p_rec.lei_information16 is not null then
      raise l_error;
    elsif p_rec.lei_information17 is not null then
      raise l_error;
    elsif p_rec.lei_information18 is not null then
      raise l_error;
    elsif p_rec.lei_information19 is not null then
      raise l_error;
    elsif p_rec.lei_information20 is not null then
      raise l_error;
    elsif p_rec.lei_information21 is not null then
      raise l_error;
    elsif p_rec.lei_information22 is not null then
      raise l_error;
    elsif p_rec.lei_information23 is not null then
      raise l_error;
    elsif p_rec.lei_information24 is not null then
      raise l_error;
    elsif p_rec.lei_information25 is not null then
      raise l_error;
    elsif p_rec.lei_information26 is not null then
      raise l_error;
    elsif p_rec.lei_information27 is not null then
      raise l_error;
    elsif p_rec.lei_information28 is not null then
      raise l_error;
    elsif p_rec.lei_information29 is not null then
      raise l_error;
    elsif p_rec.lei_information30 is not null then
      raise l_error;
    end if;
  --
  /*
  endif;
  */
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception
  when l_error then
    hr_utility.set_message(801, 'HR_7439_FLEX_INV_ATTRIBUTE_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);

end ddf;
--
end hr_lei_flex_ddf;

/
