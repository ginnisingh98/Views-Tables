--------------------------------------------------------
--  DDL for Package Body GHR_REI_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_REI_FLEX" as
/* $Header: ghreifli.pkb 120.0.12010000.2 2009/05/26 10:48:12 vmididho noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '   ghr_rei_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< df >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure df
  (p_rec   in ghr_rei_shd.g_rec_type) is
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
      hr_utility.set_message(8301, 'GHR_38123_FLEX_INV_REF_FIELD_V');
      hr_utility.raise_error;
    end if;
  else
    --
    -- When the reference field is null, check
    -- that none of the attribute fields have
    -- been set
    --
  endif;
*/
    if p_rec.rei_attribute1 is not null then
      raise l_error;
    elsif p_rec.rei_attribute2 is not null then
      raise l_error;
    elsif p_rec.rei_attribute3 is not null then
      raise l_error;
    elsif p_rec.rei_attribute4 is not null then
      raise l_error;
    elsif p_rec.rei_attribute5 is not null then
      raise l_error;
    elsif p_rec.rei_attribute6 is not null then
      raise l_error;
    elsif p_rec.rei_attribute7 is not null then
      raise l_error;
    elsif p_rec.rei_attribute8 is not null then
      raise l_error;
    elsif p_rec.rei_attribute9 is not null then
      raise l_error;
    elsif p_rec.rei_attribute10 is not null then
      raise l_error;
    elsif p_rec.rei_attribute11 is not null then
      raise l_error;
    elsif p_rec.rei_attribute12 is not null then
      raise l_error;
    elsif p_rec.rei_attribute13 is not null then
      raise l_error;
    elsif p_rec.rei_attribute14 is not null then
      raise l_error;
    elsif p_rec.rei_attribute15 is not null then
      raise l_error;
    elsif p_rec.rei_attribute16 is not null then
      raise l_error;
    elsif p_rec.rei_attribute17 is not null then
      raise l_error;
    elsif p_rec.rei_attribute18 is not null then
      raise l_error;
    elsif p_rec.rei_attribute19 is not null then
      raise l_error;
    elsif p_rec.rei_attribute20 is not null then
      raise l_error;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(8301, 'GHR_38124_FLEX_INV_ATTRIB_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
end df;

end ghr_rei_flex;

/
