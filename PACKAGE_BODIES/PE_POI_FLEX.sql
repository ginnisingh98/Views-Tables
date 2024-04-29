--------------------------------------------------------
--  DDL for Package Body PE_POI_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_POI_FLEX" as
/* $Header: pepoifli.pkb 115.0 99/07/18 14:27:39 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '   pe_poi_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< df >-------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure df
  (p_rec   in pe_poi_shd.g_rec_type) is
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
    -- Reference field       => Information type
    -- Reference field value =>
    --
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
    -- that none of the information fields have
    -- been set
    --
  endif;
*/
    if p_rec.poei_attribute1 is not null then
      raise l_error;
    elsif p_rec.poei_attribute2 is not null then
      raise l_error;
    elsif p_rec.poei_attribute3 is not null then
      raise l_error;
    elsif p_rec.poei_attribute4 is not null then
      raise l_error;
    elsif p_rec.poei_attribute5 is not null then
      raise l_error;
    elsif p_rec.poei_attribute6 is not null then
      raise l_error;
    elsif p_rec.poei_attribute7 is not null then
      raise l_error;
    elsif p_rec.poei_attribute8 is not null then
      raise l_error;
    elsif p_rec.poei_attribute9 is not null then
      raise l_error;
    elsif p_rec.poei_attribute10 is not null then
      raise l_error;
    elsif p_rec.poei_attribute11 is not null then
      raise l_error;
    elsif p_rec.poei_attribute12 is not null then
      raise l_error;
    elsif p_rec.poei_attribute13 is not null then
      raise l_error;
    elsif p_rec.poei_attribute14 is not null then
      raise l_error;
    elsif p_rec.poei_attribute15 is not null then
      raise l_error;
    elsif p_rec.poei_attribute16 is not null then
      raise l_error;
    elsif p_rec.poei_attribute17 is not null then
      raise l_error;
    elsif p_rec.poei_attribute18 is not null then
      raise l_error;
    elsif p_rec.poei_attribute19 is not null then
      raise l_error;
    elsif p_rec.poei_attribute20 is not null then
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
end pe_poi_flex;

/
