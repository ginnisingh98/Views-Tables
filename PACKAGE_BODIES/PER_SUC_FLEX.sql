--------------------------------------------------------
--  DDL for Package Body PER_SUC_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUC_FLEX" as
/* $Header: pesucfli.pkb 115.0 99/07/18 15:15:05 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_suc_flex.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< df >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure df
  (p_rec   in per_suc_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'df';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when l_error then
    hr_utility.set_message(801, 'HR_7439_FLEX_INV_ATTRIBUTE_ARG');
    hr_utility.raise_error;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
end df;
--
end per_suc_flex;

/
