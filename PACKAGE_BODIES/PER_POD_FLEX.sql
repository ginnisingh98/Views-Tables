--------------------------------------------------------
--  DDL for Package Body PER_POD_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POD_FLEX" as
/* $Header: pepodfli.pkb 115.0 99/07/18 14:27:13 porting ship $ */
--
-- ---------------------------------------------------------------------------
-- |                     Private Global Definitions                          |
-- ---------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pod_flex.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |-------------------------------< kf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure kf
        (p_rec               in per_pod_shd.g_rec_type) is
--
  l_proc             varchar2(72) := g_package||'kf';
  l_legislation_code per_business_groups.legislation_code%type;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that p_rec.id_flex_num is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'P_ID_FLEX_NUM',
     p_argument_value => p_rec.id_flex_num);
  --
  -- branch on id_flex_num. this will be modified by users.
  --
  if (p_rec.id_flex_num is not null) then
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
end per_pod_flex;

/
