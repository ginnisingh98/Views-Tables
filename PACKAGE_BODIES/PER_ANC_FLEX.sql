--------------------------------------------------------
--  DDL for Package Body PER_ANC_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ANC_FLEX" as
/* $Header: peancfli.pkb 115.1 99/07/17 18:30:27 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_anc_flex.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |-------------------------------< kf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure kf
        (p_rec               in per_anc_shd.g_rec_type) is
--
  l_proc             varchar2(72) := g_package||'kf';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that p_rec.id_flex_num exists
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'id_flex_num',
     p_argument_value => p_rec.id_flex_num);
  --
  -- customer to supply branch logic on p_rec.id_flex_num
  --
  if p_rec.id_flex_num is not null then
    null;
  else
    hr_utility.set_message(801, 'HR_7439_FLEX_INV_ATTRIBUTE_ARG');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end kf;
--
end per_anc_flex;

/
