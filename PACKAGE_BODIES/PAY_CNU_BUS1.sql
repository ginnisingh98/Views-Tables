--------------------------------------------------------
--  DDL for Package Body PAY_CNU_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CNU_BUS1" as
/* $Header: pycnurhi.pkb 120.0 2005/05/29 04:04:56 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cnu_bus1.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_element_name >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_element_name (
   p_element_name              in pay_fr_contribution_usages.element_name%TYPE
 ) Is
--
  l_proc      varchar2(72) :=      g_package|| ' chk_element_name';
--
Begin
--
  hr_utility.set_location(' Entering '||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_element_name'
    ,p_argument_value =>  p_element_name
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_element_name;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_contribution_usage_type >----------------|
-- ----------------------------------------------------------------------------
Procedure chk_contribution_usage_type (
   p_effective_date            in date
  ,p_contribution_usage_type   in pay_fr_contribution_usages.contribution_usage_type%TYPE
 ) Is
--
  l_proc      varchar2(72) :=      g_package|| ' chk_contribution_usage_type';
--
Begin
--
  hr_utility.set_location(' Entering '||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_contribution_usage_type'
    ,p_argument_value =>  p_contribution_usage_type
    );
  --
  If hr_api.not_exists_in_hr_lookups (
     p_effective_date =>  p_effective_date
    ,p_lookup_type    => 'FR_CONTRIBUTION_USAGE_TYPE'
    ,p_lookup_code    =>  p_contribution_usage_type)
  then
    fnd_message.set_name('PAY', 'PAY_74897_CNU_BAD_USAGE_TYPE');
    fnd_message.raise_error;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_contribution_usage_type;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_rate_type >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_rate_type (
   p_effective_date   in date
  ,p_rate_type        in pay_fr_contribution_usages.rate_type%TYPE
 ) Is
--
  l_proc      varchar2(72) :=      g_package|| ' chk_rate_type';
--
Begin
--
  hr_utility.set_location(' Entering '||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  If p_rate_type is not null
  then
    If hr_api.not_exists_in_hr_lookups (
       p_effective_date =>  p_effective_date
      ,p_lookup_type    => 'FR_CONTRIBUTION_RATE_TYPE'
      ,p_lookup_code    =>  p_rate_type)
    then
      fnd_message.set_name('PAY', 'PAY_74898_CNU_BAD_RATE_TYPE');
      fnd_message.raise_error;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_rate_type;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_process_type >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_process_type (
   p_effective_date    in date
  ,p_process_type        in pay_fr_contribution_usages.process_type%TYPE
 ) Is
--
  l_proc      varchar2(72) :=      g_package|| ' chk_process_type';
--
Begin
--
  hr_utility.set_location(' Entering '||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_process_type'
    ,p_argument_value =>  p_process_type
    );
  --
  If hr_api.not_exists_in_hr_lookups (
     p_effective_date =>  p_effective_date
    ,p_lookup_type    => 'FR_PROCESS_TYPE'
    ,p_lookup_code    =>  p_process_type)
  then
    fnd_message.set_name('PAY', 'PAY_74899_CNU_BAD_PROCESS');
    fnd_message.raise_error;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_process_type;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_lu_group_code >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_lu_group_code (
   p_effective_date    in date
  ,p_group_code        in pay_fr_contribution_usages.group_code%TYPE
 ) Is
--
  l_proc      varchar2(72) :=      g_package|| ' chk_lu_group_code';
--
-- The group code must be in either FR_ELEMENT_GROUP or USER_ELEMENT_GROUP
--
Begin
--
  hr_utility.set_location(' Entering '||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_group_code'
    ,p_argument_value =>  p_group_code
    );
  --
  If hr_api.not_exists_in_hr_lookups (
     p_effective_date =>  p_effective_date
    ,p_lookup_type    => 'FR_ELEMENT_GROUP'
    ,p_lookup_code    =>  p_group_code )
  then
    If hr_api.not_exists_in_hr_lookups (
       p_effective_date =>  p_effective_date
      ,p_lookup_type    => 'FR_USER_ELEMENT_GROUP'
      ,p_lookup_code    =>  p_group_code )
    then
      fnd_message.set_name('PAY', 'PAY_74900_CNU_BAD_GROUP_CODE');
      fnd_message.raise_error;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_lu_group_code;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_business_group_id >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_business_group_id (
   p_business_group_id     in pay_fr_contribution_usages.business_group_id%TYPE
 ) Is
--
  l_proc      varchar2(72) :=      g_package|| ' chk_business_group_id';
  l_leg_code  varchar2(30);
--
 -- The BG must have a French Legislation code
 --
 -- This can be called from insert, as BG is a non-updateable field
 --
 cursor csr_leg_code is
        select pbg.legislation_code
        from   per_business_groups pbg
        where  pbg.business_group_id = p_business_group_id;
--
Begin
--
  hr_utility.set_location(' Entering '||l_proc, 10);
  --
  -- Only test if not null
  --
  If p_business_group_id is not null
  then
    open  csr_leg_code;
    fetch csr_leg_code into l_leg_code;
    close csr_leg_code;
    If l_leg_code <> 'FR'
    then
      fnd_message.set_name('PAY', 'PAY_74901_CNU_BAD_LEGISLATION');
      fnd_message.raise_error;
    end if;
      hr_utility.set_location(' Step:'|| l_proc, 20);
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 30);
end chk_business_group_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_rate_category_type >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_rate_category_type (
  p_rate_category     in pay_fr_contribution_usages.rate_category%TYPE
 ,p_rate_type         in pay_fr_contribution_usages.rate_type%TYPE
 ) Is
--
  l_proc  varchar2(72) :=      g_package|| ' chk_rate_category_type';
--
Begin
--
  hr_utility.set_location(' Entering '||l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_rate_category'
    ,p_argument_value =>  p_rate_category
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  if (   (p_rate_category <> 'S')
      and(p_rate_category <> 'W')
      and(p_rate_category <> 'T')
      and(p_rate_category <> 'R')
      and(p_rate_category <> 'D')
      and(p_rate_category <> 'C')

     )
  then
    fnd_message.set_name('PAY', 'PAY_74902_CNU_BAD_RATE_CAT');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  if(   ( (   p_rate_category = 'W'
           OR p_rate_category = 'T'
           OR p_rate_category = 'R'
                                   )  and p_rate_type is not null)
     OR ( (   p_rate_category = 'S'
           OR p_rate_category = 'D'
           OR p_rate_category = 'C')  and p_rate_type is null)
    )
  then
    fnd_message.set_name('PAY', 'PAY_74903_CNU_BAD_RATE_STD');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_rate_category_type;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< is_numeric >---------------------------------|
-- ----------------------------------------------------------------------------
function is_numeric (p_one_char in VARCHAR2) RETURN varchar2
is
l_return varchar2(1);
BEGIN
l_return := '1';
  if (   (p_one_char <> '1')
      and(p_one_char <> '2')
      and(p_one_char <> '3')
      and(p_one_char <> '4')
      and(p_one_char <> '5')
      and(p_one_char <> '6')
      and(p_one_char <> '7')
      and(p_one_char <> '8')
      and(p_one_char <> '9')
      and(p_one_char <> '0')
     )
  then
    l_return := '0';
  end if;
  RETURN (l_return);
end is_numeric;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_validate_code >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_validate_code (
  p_code              in pay_fr_contribution_usages.contribution_code%TYPE
 ,p_contribution_type in pay_fr_contribution_usages.contribution_type%TYPE
 ,p_rate_category     in pay_fr_contribution_usages.rate_category%TYPE
 ) Is
--
  l_proc  varchar2(72) :=      g_package|| ' chk_validate_code';
  l_exists varchar2(1);
--
Begin
--
-- URSSAF
--
  hr_utility.set_location(' Entering '||l_proc, 10);
  if     p_contribution_type = 'URSSAF'
  and(  (substr(p_code, 1, 1) <> '1')
      OR(substr(p_code, 2, 2) <> 'XX')
      OR(     (substr(p_code, 7, 1) <> 'A')
          and (substr(p_code, 7, 1) <> 'D')
          and (substr(p_code, 7, 1) <> 'P')
          and (substr(p_code, 7, 1) <> 'T')
          and (substr(p_code, 7, 1) <> 'C')
          and (substr(p_code, 7, 1) <> 'N')
        )
      OR(is_numeric(substr(p_code, 4, 1)) <> '1')
      OR(is_numeric(substr(p_code, 5, 1)) <> '1')
      OR(is_numeric(substr(p_code, 6, 1)) <> '1')
      OR(length(p_code) <> 7 and length(p_code) <> 8)
     )
  then
    hr_utility.set_location(' Step:'|| l_proc, 20);
    fnd_message.set_name('PAY', 'PAY_74904_CNU_BAD_URSSAF');
    fnd_message.raise_error;
  end if;
 hr_utility.set_location(' Step:'|| l_proc, 30);
 --
 -- ASSEDIC
 --
  if     p_contribution_type = 'ASSEDIC'
  and(  (substr(p_code, 1, 1) <> '2')
      OR(substr(p_code, 2, 1) <> 'X')
      OR(     (substr(p_code, 3, 1) <> '1')
          and (substr(p_code, 3, 1) <> '2')
          and (substr(p_code, 3, 1) <> '3')
        )
      OR(substr(p_code, 4, 1) <> '0')
      OR(is_numeric(substr(p_code, 5, 1)) <> '1')
      OR(is_numeric(substr(p_code, 6, 1)) <> '1')
      OR(is_numeric(substr(p_code, 7, 1)) <> '1')
      OR(length(p_code) <> 7)
     )
  then
    fnd_message.set_name('PAY', 'PAY_74905_CNU_BAD_ASSEDIC');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Step:'|| l_proc, 50);
 --
 -- AGIRC
 --
  if     p_contribution_type = 'AGIRC'
  and(  (substr(p_code, 1, 1) <> '3')
      OR(substr(p_code, 2, 4) <> 'XXXX')
      OR(is_numeric(substr(p_code, 6, 1)) <> '1')
      OR(is_numeric(substr(p_code, 7, 1)) <> '1')
      OR(length(p_code) <> 7)
     )
  then
    fnd_message.set_name('PAY', 'PAY_74906_CNU_BAD_AGIRC');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Step:'|| l_proc, 60);
 --
 --
 -- ARRCO
 --
  if     p_contribution_type = 'ARRCO'
  and(  (substr(p_code, 1, 1) <> '4')
      OR(substr(p_code, 2, 4) <> 'XXXX' and substr(p_code, 2, 4) <> 'X260' and substr(p_code, 2, 4) <> 'X301' and substr(p_code, 2, 4) <> 'X201'and substr(p_code, 2, 4) <> 'X240'and substr(p_code, 2, 4) <> 'X203')
      OR(is_numeric(substr(p_code, 6, 1)) <> '1' and is_numeric(substr(p_code, 6, 1)) <> '0' and is_numeric(substr(p_code, 6, 1)) <> '3')
      OR(is_numeric(substr(p_code, 7, 1)) <> '1' and is_numeric(substr(p_code, 7, 1)) <> '2')
      OR(length(p_code) <> 7)
     )
  then
    fnd_message.set_name('PAY', 'PAY_74907_CNU_BAD_ARRCO');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
end chk_validate_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_contribution_codes >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_contribution_codes (
  p_contribution_usage_id   in pay_fr_contribution_usages.contribution_usage_id%TYPE
 ,p_object_version_number   in pay_fr_contribution_usages.object_version_number%TYPE
 ,p_contribution_type       in pay_fr_contribution_usages.contribution_type%TYPE
 ,p_contribution_code       in pay_fr_contribution_usages.contribution_code%TYPE
 ,p_retro_contribution_code in pay_fr_contribution_usages.retro_contribution_code%TYPE
 ,p_rate_category           in pay_fr_contribution_usages.rate_category%TYPE
 ) Is
--
  l_proc  varchar2(72) :=      g_package|| ' chk_contribution_codes';
  l_exists varchar2(1);
  l_api_updating   boolean;
--
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Entering '||l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_contribution_type'
    ,p_argument_value =>  p_contribution_type
    );

  -- main code can only be null if cont type is URSSAF
  --
  if   p_contribution_type <> 'URSSAF' and p_contribution_code is null and p_rate_category <> 'C'
  then
    hr_utility.set_location(' Step:'|| l_proc, 20);
    fnd_message.set_name('PAY', 'PAY_74908_CNU_MISSING_CODE');
    fnd_message.raise_error;
  end if;
  --
  l_api_updating := pay_cnu_shd.api_updating
    (p_contribution_usage_id   => p_contribution_usage_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If this is an update and retro is changing (and not changing to null) check.
  --
  if  (l_api_updating and
        nvl(pay_cnu_shd.g_old_rec.retro_contribution_code, hr_api.g_varchar2) <>
        nvl(p_retro_contribution_code, hr_api.g_varchar2) and p_retro_contribution_code is not null)
  then
    hr_utility.set_location(' Step:'|| l_proc, 30);
    pay_cnu_bus1.chk_validate_code( p_code              => p_retro_contribution_code
                                   ,p_contribution_type => p_contribution_type
                                   ,p_rate_category     => p_rate_category);
  end if;
  --
  -- If this is an insert and code is not null check.
  --
  if (NOT l_api_updating and p_contribution_code is not null)
  then
    hr_utility.set_location(' Step:'|| l_proc, 40);
    pay_cnu_bus1.chk_validate_code( p_code              => p_contribution_code
                                   ,p_contribution_type => p_contribution_type
                                   ,p_rate_category     => p_rate_category);
  end if;
    hr_utility.set_location(' Step:'|| l_proc, 45);
    --
    -- Check retro code
    --
  if (NOT l_api_updating and p_retro_contribution_code is not null)
  then
    pay_cnu_bus1.chk_validate_code( p_code              => p_retro_contribution_code
                                   ,p_contribution_type => p_contribution_type
                                   ,p_rate_category     => p_rate_category);
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
end chk_contribution_codes;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_contribution_type >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_contribution_type (
  p_contribution_type in pay_fr_contribution_usages.contribution_type%TYPE
 ) Is
--
  l_proc  varchar2(72) :=      g_package|| ' chk_contribution_type';
--
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Entering '||l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_contribution_type'
    ,p_argument_value =>  p_contribution_type
    );
  --
  if     p_contribution_type <> 'URSSAF'
    and  p_contribution_type <> 'ASSEDIC'
    and  p_contribution_type <> 'AGIRC'
    and  p_contribution_type <> 'ARRCO'
  then
    hr_utility.set_location(' Step:'|| l_proc, 20);
    fnd_message.set_name('PAY', 'PAY_74909_CNU_BAD_CONT_TYPE');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_contribution_type;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_group_code >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_group_code (
  p_group_code              in pay_fr_contribution_usages.group_code%TYPE
 ,p_process_type            in pay_fr_contribution_usages.process_type%TYPE
 ,p_element_name            in pay_fr_contribution_usages.element_name%TYPE
 ,p_contribution_usage_type in pay_fr_contribution_usages.contribution_usage_type%TYPE
 ,p_business_group_id       in pay_fr_contribution_usages.business_group_id%TYPE
 ) Is
--
  l_proc  varchar2(72) :=      g_package|| ' chk_group_code';
  l_cu_id  number;
--
 -- There can only be one group_code for a combination of element_name, process_type
 -- contribution_usage_type for :
 -- if p_bg is null, where bg is null
 -- if p_bg is not null, where bg = this bg, or bg is null
 --
 -- This can be called from insert (where ID and OVN are null)
 -- it is not possible to update these key values, so this test
 -- is not required during update_validate.
 --
 cursor csr_unique is
        select cnu.contribution_usage_id
        from   pay_fr_contribution_usages cnu
        where  cnu.group_code   <> p_group_code
          and  cnu.process_type = p_process_type
          and  cnu.element_name = p_element_name
          and  cnu.contribution_usage_type = p_contribution_usage_type
          and (  (p_business_group_id is null)
               or(p_business_group_id is not null
                   and (  (cnu.business_group_id = p_business_group_id )
                        or(cnu.business_group_id is null)
                       )
                 )
               );
--
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Entering '||l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_group_code'
    ,p_argument_value =>  p_group_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_process_type'
    ,p_argument_value =>  p_process_type
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_element_name'
    ,p_argument_value =>  p_element_name
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_contribution_usage_type'
    ,p_argument_value =>  p_contribution_usage_type
    );
  --
  -- This is an insert (not called for update or delete)
  -- check the combination is unique
  --
    hr_utility.set_location(' Step:'|| l_proc, 60);
    open  csr_unique;
    fetch csr_unique into l_cu_id;
    if csr_unique%FOUND then
      close csr_unique;
      fnd_message.set_name('PAY', 'PAY_74910_CNU_CHANGING_GROUP');
      fnd_message.raise_error;
    else
      close csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 80);
    end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_group_code;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dates >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_dates (
  p_contribution_usage_id   in pay_fr_contribution_usages.contribution_usage_id%TYPE
 ,p_object_version_number   in pay_fr_contribution_usages.object_version_number%TYPE
 ,p_date_from               in pay_fr_contribution_usages.date_from%TYPE
 ,p_date_to                 in pay_fr_contribution_usages.date_to%TYPE
 ,p_group_code              in pay_fr_contribution_usages.group_code%TYPE
 ,p_process_type            in pay_fr_contribution_usages.process_type%TYPE
 ,p_element_name            in pay_fr_contribution_usages.element_name%TYPE
 ,p_contribution_usage_type in pay_fr_contribution_usages.contribution_usage_type%TYPE
 ,p_business_group_id       in pay_fr_contribution_usages.business_group_id%TYPE
 ) Is
--
  l_proc  varchar2(72) :=      g_package|| ' chk_dates';
  l_exists varchar2(1);
  l_cu_id  number;
  l_api_updating   boolean;
--
 -- there cannot be a duplicate of date_from, date_to, group_code, process_type
 -- element_name, contribution_usage_type :
 --  if p_business_group_id is null, where BG is null
 --  if BG is not null, where BG = P_BG, and where BG is null
 -- covering any period in the date_from -> date_to date range.
 -- If p_date_to is null, use eot.
 --
 -- This can be called from insert (where ID and OVN are null)
 -- or
 -- from update, as date_to may have changed.
 -- Only test if new insert, or date_to is changing.
 --
 cursor csr_unique is
        select cnu.contribution_usage_id
        from   pay_fr_contribution_usages cnu
        where  cnu.group_code   = p_group_code
          and  cnu.process_type = p_process_type
          and  cnu.element_name = p_element_name
          and  cnu.contribution_usage_type = p_contribution_usage_type
          and (nvl(p_contribution_usage_id, -1) <> cnu.contribution_usage_id )
          and (  (p_business_group_id is null)
               or(p_business_group_id is not null
                   and (  (cnu.business_group_id = p_business_group_id )
                        or(cnu.business_group_id is null)
                       )
                 )
               )
          and ( ((nvl(p_date_to, hr_api.g_eot) <= nvl(cnu.date_to, hr_api.g_eot)
                and nvl(p_date_to, hr_api.g_eot) >= cnu.date_from))
           OR
              ( (p_date_from >= cnu.date_from)
               and p_date_from <= nvl(cnu.date_to, hr_api.g_eot))
           OR
              ( (p_date_from <= cnu.date_from)
                and nvl(p_date_to, hr_api.g_eot) >= nvl(cnu.date_to, hr_api.g_eot))
              );
--
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Entering '||l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_date_from'
    ,p_argument_value =>  p_date_from
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_group_code'
    ,p_argument_value =>  p_group_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_process_type'
    ,p_argument_value =>  p_process_type
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_element_name'
    ,p_argument_value =>  p_element_name
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_contribution_usage_type'
    ,p_argument_value =>  p_contribution_usage_type
    );
  --
  -- if is changing or is an insert,
  -- check the combination is unique
  --
  l_api_updating := pay_cnu_shd.api_updating
    (p_contribution_usage_id   => p_contribution_usage_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- Check that the date_from is before or on the date_to
  --
  if p_date_from > nvl(p_date_to, hr_api.g_eot) THEN
      hr_utility.set_location(' Step:'|| l_proc, 55);
      fnd_message.set_name('PAY', 'PAY_74911_CNU_DATE_FROM');
      fnd_message.raise_error;
  end if;
  --
  -- If the date_to is changing or if this is an insert
  --
  if  (l_api_updating and
        nvl(pay_cnu_shd.g_old_rec.date_to, hr_api.g_date) <>
        nvl(p_date_to, hr_api.g_date) )
      or (NOT l_api_updating)
  then
    hr_utility.set_location(' Step:'|| l_proc, 60);
    open  csr_unique;
    fetch csr_unique into l_cu_id;
    if csr_unique%FOUND then
      close csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 70);
      fnd_message.set_name('PAY', 'PAY_74912_CNU_DUPLICATE_USAGE');
      fnd_message.raise_error;
    else
      close csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 80);
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< LOAD_ROW >------------------------------------|
-- ----------------------------------------------------------------------------
Procedure load_row (
  p_date_from               in varchar2
 ,p_date_to                 in varchar2
 ,p_group_code              in pay_fr_contribution_usages.group_code%TYPE
 ,p_process_type            in pay_fr_contribution_usages.process_type%TYPE
 ,p_element_name            in pay_fr_contribution_usages.element_name%TYPE
 ,p_contribution_usage_type in pay_fr_contribution_usages.contribution_usage_type%TYPE
 ,p_rate_type               in pay_fr_contribution_usages.rate_type%TYPE
 ,p_rate_category           in pay_fr_contribution_usages.rate_category%TYPE
 ,p_contribution_code       in pay_fr_contribution_usages.contribution_code%TYPE
 ,p_contribution_type       in pay_fr_contribution_usages.contribution_type%TYPE
 ,p_retro_contribution_code in pay_fr_contribution_usages.retro_contribution_code%TYPE
 ,p_code_rate_id            in pay_fr_contribution_usages.code_Rate_id%TYPE
 ) is
  --
  l_existing_cu_id      number;
  l_existing_ovn_id     number;
  l_cu_id               number;
  l_ovn_id              number;
  l_code_Rate_id        number := p_code_Rate_id;
  l_new_date_from date := to_date(p_date_from,'DD/MM/YYYY');
  l_new_date_to   date := to_date(p_date_to,  'DD/MM/YYYY');
  --
  cursor csr_existing is
    select  cnu.contribution_usage_id, cnu.object_version_number
      from   pay_fr_contribution_usages cnu
     where  cnu.group_code   = p_group_code
       and  cnu.process_type = p_process_type
       and  cnu.element_name = p_element_name
       and  cnu.date_from    = l_new_date_from
       and  cnu.contribution_usage_type = p_contribution_usage_type
       and  cnu.business_group_id is null;
BEGIN
  open csr_existing;
  fetch csr_existing into l_existing_cu_id, l_existing_ovn_id;
  if csr_existing%FOUND
  then
    close csr_existing;
    pay_cnu_api.update_contribution_usage(
      p_validate                     => FALSE
     ,p_effective_date               => l_new_date_from
     ,p_date_to                      => l_new_date_to
     ,p_retro_contribution_code      => p_retro_contribution_code
     ,p_object_version_number        => l_existing_ovn_id
     ,p_contribution_usage_id        => l_existing_cu_id
     ,p_contribution_code            => p_contribution_code
     ,p_contribution_type            => p_contribution_type
     ,p_code_rate_id                 => p_code_rate_id
    );
  else
    close csr_existing;
    -- This is not an update
    -- call the create api, and allow it to adjust any
    -- existing rows if necessary.
    --
    pay_cnu_api.create_contribution_usage(
      p_validate                     => FALSE
     ,p_effective_date               => l_new_date_from
     ,p_date_from                    => l_new_date_from
     ,p_date_to                      => l_new_date_to
     ,p_group_code                   => p_group_code
     ,p_process_type                 => p_process_type
     ,p_element_name                 => p_element_name
     ,p_contribution_usage_type      => p_contribution_usage_type
     ,p_rate_type                    => p_rate_type
     ,p_rate_category                => p_rate_category
     ,p_contribution_code            => p_contribution_code
     ,p_contribution_type            => p_contribution_type
     ,p_retro_contribution_code      => p_retro_contribution_code
     ,p_business_group_id            => null
     ,p_object_version_number        => l_ovn_id
     ,p_contribution_usage_id        => l_cu_id
     ,p_code_Rate_id                 => l_code_rate_id
     );
  end if;
--
-- do not pass back any out parameters from the API calls
--
end load_row;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_code_rate_id >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_code_rate_id (
  p_code_rate_id            in out nocopy pay_fr_contribution_usages.code_rate_id%TYPE
 ,p_contribution_code       in pay_fr_contribution_usages.contribution_code%TYPE
 ,p_business_group_id       in pay_fr_contribution_usages.business_group_id%TYPE
 ,p_rate_type               in pay_fr_contribution_usages.rate_type%TYPE
 ,p_rate_category           in pay_fr_contribution_usages.rate_category%TYPE
 ) Is
--
  l_proc  varchar2(72) :=      g_package|| ' chk_code_rate_id';
  l_exists varchar2(1);
--
 -- There can only be one group_code for a combination of element_name, process_type
 -- contribution_usage_type for :
 -- if p_bg is null, where bg is null
 -- if p_bg is not null, where bg = this bg, or bg is null
 --
 -- This can be called from insert (where ID and OVN are null)
 -- it is not possible to update these key values, so this test
 -- is not required during update_validate.
 --
 cursor csr_chk_unique is
       select  null
         from  pay_fr_contribution_usages cnu
        where  cnu.contribution_code = p_contribution_code
          and  cnu.rate_type = p_rate_type
          and  cnu.code_rate_id  <> p_code_rate_id
          and  nvl(cnu.business_group_id,0) = nvl(p_business_group_id,0)
        UNION
       select  null
         from  pay_fr_contribution_usages cnu
        where cnu.code_rate_id   = p_code_rate_id
          and  nvl(cnu.business_group_id,0) = nvl(p_business_group_id,0)
          and  cnu.contribution_code = p_contribution_code
          and  cnu.rate_type <> p_rate_type;

 cursor csr_get_code_rate is
        select code_rate_id
        from   pay_fr_contribution_usages cnu
        where  cnu.contribution_code = p_contribution_code
          and  cnu.rate_type = p_rate_type
          and  cnu.business_group_id = p_business_group_id;

 cursor csr_new_code_rate is
        select nvl(max(code_rate_id),29) +1
        from   pay_fr_contribution_usages cnu
        where  cnu.contribution_code = p_contribution_code
          and  cnu.business_group_id = p_business_group_id;

--
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Entering '||l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_rate_category'
    ,p_argument_value =>  p_rate_category
    );
  --
  -- This is an insert (not called for update or delete)
  --
  -- check if code_rate_id is required
  --
  if p_rate_category in ('W', 'T') or p_contribution_code is null or p_rate_type is null then
      if p_code_rate_id is not null then
          fnd_message.set_name('PAY', 'PAY_75061_CNU_NOT_REQ_CODE_R');
          fnd_message.raise_error;
      end if;
  else
      if  (p_business_group_id is null and p_code_rate_id is null)
          or
          (p_business_group_id is not null and p_code_rate_id is not null)
      then
	      fnd_message.set_name('PAY', 'PAY_75062_CNU_BG_CODE_R');
	      fnd_message.raise_error;
      end if;
      --
      -- seeded code rate ids must be >=0, <30
      --
      if   p_business_group_id is null
	       and (p_code_rate_id < 0 OR p_code_rate_id >29)
      then
           fnd_message.set_name('PAY', 'PAY_75063_CNU_RGE_CODE_R');
           fnd_message.raise_error;
      end if;
      --
      -- get a code rate id for the business group id
      --
      if   p_business_Group_id is not null
      then
          open csr_get_code_rate;
          fetch csr_get_code_rate into p_code_rate_id;
          close csr_get_code_rate;
          if   p_code_rate_id is null
          then
               open csr_new_code_rate;
               fetch csr_new_code_rate into p_code_Rate_id;
               close csr_new_code_rate;
          end if;
      end if;
      --
      -- For both user and seeded rows check no duplicates exist
      --
      open csr_chk_unique;
      fetch csr_chk_unique into l_exists;
      if csr_chk_unique%FOUND then
          close csr_chk_unique;
          fnd_message.set_name('PAY', 'PAY_75064_CNU_UNQ_CODE_R');
          fnd_message.raise_error;
      else
          close csr_chk_unique;
      end if;
  End if;
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end chk_code_rate_id;
-------------------------------------------------------------------------------
end pay_cnu_bus1;

/
