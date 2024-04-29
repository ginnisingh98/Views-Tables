--------------------------------------------------------
--  DDL for Package Body PER_CTR_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTR_FLEX" as
/* $Header: pectrfli.pkb 115.0 99/07/17 18:53:05 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ctr_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< df >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure df
  (p_rec   in per_ctr_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'df';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- When the reference field is null, check
    -- that none of the attribute fields have
    -- been set
    --
    if p_rec.cont_attribute1 is not null then
      raise l_error;
    elsif p_rec.cont_attribute2 is not null then
      raise l_error;
    elsif p_rec.cont_attribute3 is not null then
      raise l_error;
    elsif p_rec.cont_attribute4 is not null then
      raise l_error;
    elsif p_rec.cont_attribute5 is not null then
      raise l_error;
    elsif p_rec.cont_attribute6 is not null then
      raise l_error;
    elsif p_rec.cont_attribute7 is not null then
      raise l_error;
    elsif p_rec.cont_attribute8 is not null then
      raise l_error;
    elsif p_rec.cont_attribute9 is not null then
      raise l_error;
    elsif p_rec.cont_attribute10 is not null then
      raise l_error;
    elsif p_rec.cont_attribute11 is not null then
      raise l_error;
    elsif p_rec.cont_attribute12 is not null then
      raise l_error;
    elsif p_rec.cont_attribute13 is not null then
      raise l_error;
    elsif p_rec.cont_attribute14 is not null then
      raise l_error;
    elsif p_rec.cont_attribute15 is not null then
      raise l_error;
    elsif p_rec.cont_attribute16 is not null then
      raise l_error;
    elsif p_rec.cont_attribute17 is not null then
      raise l_error;
    elsif p_rec.cont_attribute18 is not null then
      raise l_error;
    elsif p_rec.cont_attribute19 is not null then
      raise l_error;
    elsif p_rec.cont_attribute20 is not null then
      raise l_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(801, 'HR_7439_FLEX_INV_ATTRIBUTE_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
end df;
--
end per_ctr_flex;

/
