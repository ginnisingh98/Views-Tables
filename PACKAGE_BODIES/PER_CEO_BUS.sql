--------------------------------------------------------
--  DDL for Package Body PER_CEO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CEO_BUS" as
/* $Header: peceorhi.pkb 120.1.12000000.2 2007/04/16 11:05:48 arumukhe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ceo_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_comp_element_outcome_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_comp_element_outcome_id                           in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_comp_element_outcomes ceo
     where ceo.comp_element_outcome_id = p_comp_element_outcome_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'comp_element_outcome_id'
    ,p_argument_value     => p_comp_element_outcome_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'OUTCOME_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_comp_element_outcome_id                           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , per_comp_element_outcomes ceo
     where ceo.comp_element_outcome_id = p_comp_element_outcome_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'comp_element_outcome_id'
    ,p_argument_value     => p_comp_element_outcome_id
    );
  --
  if ( nvl(per_ceo_bus.g_comp_element_outcome_id, hr_api.g_number)
       = p_comp_element_outcome_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ceo_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    per_ceo_bus.g_comp_element_outcome_id                  := p_comp_element_outcome_id;
    per_ceo_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in per_ceo_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_ceo_shd.api_updating
      (p_comp_element_outcome_id           => p_rec.comp_element_outcome_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------< chk_comp_element_outcome_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_element_outcome_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--   inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_comp_element_outcome_id
 ( p_comp_element_outcome_id in  per_comp_element_outcomes.comp_element_outcome_id%TYPE
  ,p_object_version_number   in  per_comp_element_outcomes.object_version_number%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_element_outcome_id';
  l_api_updating boolean;
  --
Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_ceo_shd.api_updating
    (p_comp_element_outcome_id      => p_comp_element_outcome_id
    ,p_object_version_number        => p_object_version_number
   );
  --
  if (l_api_updating
     and nvl(p_comp_element_outcome_id,hr_api.g_number)
     <>  per_ceo_shd.g_old_rec.comp_element_outcome_id) then
    --
    -- raise error as PK has changed
    --
    per_ceo_shd.constraint_error('PER_COMP_ELEMENT_OUTCOMES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_comp_element_outcome_id is not null then
      --
      -- raise error as PK is not null
      --
      per_ceo_shd.constraint_error('PER_COMP_ELEMENT_OUTCOMES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_comp_element_outcome_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_competence_element_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that compence_element_id is mandatory and foreign key to
--    per_competence_elements table
--
--  Pre-conditions:
--
--
--  In Arguments :
--    p_comp_element_outcome_id
--    p_competence_element_id
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_competence_element_id
  (p_comp_element_outcome_id    in      number
  ,p_competence_element_id      in      number
  ,p_object_version_number      in      number
  ) is
--
  --
  -- Declare cursor
  --
   cursor csr_competence_element is
     select 'x' from per_competence_elements
     where  competence_element_id  = p_competence_element_id;

  --
  -- Declare local variables
  --
   l_proc          varchar2(72) := g_package||'chk_competence_element_id';
   l_api_updating  boolean;
   l_exists        varchar2(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --

  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'competence_element_id'
    ,p_argument_value   => p_competence_element_id
    );

  hr_utility.set_location(l_proc, 20);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_ceo_shd.api_updating
    (p_comp_element_outcome_id   => p_comp_element_outcome_id
    ,p_object_version_number     => p_object_version_number);
  --

  if ((l_api_updating and
       (per_ceo_shd.g_old_rec.competence_element_id <>
                p_competence_element_id)) or
       (NOT l_api_updating)) then

    --
    --   Check that competence_element_id is a foreign key
    --
    hr_utility.set_location(l_proc, 30);
    --
    open csr_competence_element;
    fetch csr_competence_element into l_exists;
    if csr_competence_element%NOTFOUND then
      close csr_competence_element;
      per_ceo_shd.constraint_error
      (
        p_constraint_name => 'PER_COMP_ELEMENT_OUTCOME_FK1'
      );
    end if;
    close csr_competence_element;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_competence_element_id;
--
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_outcome_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that compence_id is mandatory and foreign key to
--    per_competence_outcomes table
--
--  Pre-conditions:
--   None
--
--  In Arguments :
--    p_comp_element_outcome_id
--    p_outcome_id
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_outcome_id
  (p_comp_element_outcome_id    in      number
  ,p_outcome_id                 in      number
  ,p_object_version_number      in      number
  ) is
--
  --
  -- Declare cursor
  --
   cursor csr_competence_outcome is
     select 'x' from per_competence_outcomes
     where  outcome_id  = p_outcome_id;

  --
  -- Declare local variables
  --
   l_proc          varchar2(72) := g_package||'chk_outcome_id';
   l_api_updating  boolean;
   l_exists        varchar2(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --

  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'outcome_id'
    ,p_argument_value   => p_outcome_id
    );

  hr_utility.set_location(l_proc, 20);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_ceo_shd.api_updating
    (p_comp_element_outcome_id   => p_comp_element_outcome_id
    ,p_object_version_number     => p_object_version_number);
  --

  if ((l_api_updating and
       (per_ceo_shd.g_old_rec.outcome_id <> p_outcome_id)) or
       (NOT l_api_updating)) then

    --
    --   Check that outcome_id is a foreign key
    --
    hr_utility.set_location(l_proc, 30);
    --
    open csr_competence_outcome;
    fetch csr_competence_outcome into l_exists;
    if csr_competence_outcome%NOTFOUND then
      close csr_competence_outcome;
      per_ceo_shd.constraint_error
      (
        p_constraint_name => 'PER_COMP_ELEMENT_OUTCOME_FK2'
      );
    end if;
    close csr_competence_outcome;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_outcome_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_uniq_comp_element_outcome >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that a combination of COMPETENCE_ELEMENT_ID and OUTCOME_ID
--    is unique.
--
--  Pre-conditions:
--    competence_element_id and outcome_id are validated
--
--  In Arguments :
--    p_comp_element_outcome_id
--    p_competence_element_id
--    p_outcome_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_uniq_comp_element_outcome
  (p_comp_element_outcome_id    in      number
  ,p_competence_element_id      in      number
  ,p_outcome_id                 in      number
  ,p_date_from                  in      date
  ,p_date_to                    in      date
  ,p_object_version_number      in      number
  )      is
--
  --
  -- Declare cursor
  --
   cursor csr_uniq_comp_element_outcome is
     select 'x' from per_comp_element_outcomes o
     where  o.competence_element_id = p_competence_element_id
     and    o.outcome_id = p_outcome_id
     and    p_date_from < nvl(o.date_to,hr_api.g_eot)
     and    nvl(p_date_to,hr_api.g_eot) > o.date_from;

  /* cursor csr_upd_uniq_comp_ele_outcome is
     select 'x' from per_comp_element_outcomes o
     where  o.comp_element_outcome_id = p_comp_element_outcome_id
     and    o.competence_element_id = p_competence_element_id
     and    o.outcome_id = p_outcome_id
     and    p_date_from < nvl(o.date_to,hr_api.g_eot)
     and    nvl(p_date_to,hr_api.g_eot) > o.date_from;*/

      l_outcome_name per_competence_outcomes.name%type;

     cursor csr_upd_uniq_comp_ele_outcome(p_name per_competence_outcomes.name%type)is
       select 'x' from per_comp_element_outcomes o,per_competence_outcomes co
	       where o.comp_element_outcome_id <> p_comp_element_outcome_id
	       and    o.competence_element_id = p_competence_element_id
	       and    co.outcome_id = o.outcome_id
	       and    co.name = p_name
           and(p_date_from between o.date_from and nvl(o.date_to,hr_api.g_eot)
           or  p_date_to between o.date_from and nvl(o.date_to,hr_api.g_eot)
           or  o.date_from between p_date_from and p_date_to );


  --
  -- Declare local variables
  --
   l_proc          varchar2(72) := g_package||'chk_uniq_comp_element_outcome';
   l_api_updating  boolean;
   l_exists        varchar2(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_ceo_shd.api_updating
    (p_comp_element_outcome_id   => p_comp_element_outcome_id
    ,p_object_version_number     => p_object_version_number);
  --

  if (l_api_updating and
       (per_ceo_shd.g_old_rec.competence_element_id <>
                                 p_competence_element_id or
       per_ceo_shd.g_old_rec.outcome_id <> p_outcome_id or
       per_ceo_shd.g_old_rec.date_from  <> p_date_from  or
       nvl(per_ceo_shd.g_old_rec.date_to,hr_api.g_eot)  <>
           nvl(p_date_to,hr_api.g_eot))) then
    --
    --   Check that a combination is unique
    --

    hr_utility.set_location(l_proc, 20);

   select name
   into l_outcome_name
   from per_competence_outcomes
   where outcome_id = p_outcome_id;

    --
    open csr_upd_uniq_comp_ele_outcome(l_outcome_name);
    fetch csr_upd_uniq_comp_ele_outcome into l_exists;
    if csr_upd_uniq_comp_ele_outcome%FOUND then
      close csr_upd_uniq_comp_ele_outcome;
      hr_utility.set_message(800,'HR_449132_QUA_FWK_OUTCM_EXISTS');
      hr_multi_message.add
	  (p_associated_column1 => 'PER_COMP_ELEMENT_OUTCOMES.DATE_FROM');

      hr_utility.raise_error;
    end if;
    close csr_upd_uniq_comp_ele_outcome;
    --
  elsif (NOT l_api_updating) then
    hr_utility.set_location(l_proc, 30);

    --
    open csr_uniq_comp_element_outcome;
    fetch csr_uniq_comp_element_outcome into l_exists;
    if csr_uniq_comp_element_outcome%FOUND then
      close csr_uniq_comp_element_outcome;
      hr_utility.set_message(800,'HR_449132_QUA_FWK_OUTCM_EXISTS');
      hr_multi_message.add
	  (p_associated_column1 => 'PER_COMP_ELEMENT_OUTCOMES.DATE_FROM');

      hr_utility.raise_error;
    end if;
    close csr_uniq_comp_element_outcome;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_uniq_comp_element_outcome;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_dates >----------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates DATE_FROM is not null
--
--    Validates that DATE_FROM is less than or equal to the value for
--    DATE_TO on the same OUTCOME record
--
--  Pre-conditions:
--    Format of p_date_from must be correct
--
--  In Arguments :
--    p_comp_element_outcome_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_dates
  (p_comp_element_outcome_id    in      number
  ,p_outcome_id                 in      number
  ,p_date_from                  in      date
  ,p_date_to                    in      date
  ,p_object_version_number      in      number
  )      is
--

   cursor csr_get_outcome_active_date  is
    select date_from  from per_competence_outcomes cpo
           where cpo.outcome_id = p_outcome_id ;

   l_outcome_active_date  date ;
   l_proc                 varchar2(72) := g_package||'chk_dates';
   l_api_updating         boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --

  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'date_from'
    ,p_argument_value   => p_date_from
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_ceo_shd.api_updating
    (p_comp_element_outcome_id   => p_comp_element_outcome_id
    ,p_object_version_number     => p_object_version_number);
  --
  if (((l_api_updating and
       (nvl(per_ceo_shd.g_old_rec.date_to,hr_api.g_eot) <>
                                               nvl(p_date_to,hr_api.g_eot)) or
       (per_ceo_shd.g_old_rec.date_from <> p_date_from)) or
       (NOT l_api_updating))) then
    --
    --   Check that date_from <= date_to
    --
    hr_utility.set_location(l_proc, 30);
    --
    if p_date_from > nvl(p_date_to,hr_api.g_eot) then
      hr_utility.set_message(800,'HR_6758_APPL_DATE_FROM_CHK');
      hr_multi_message.add
	  (p_associated_column1 => 'PER_COMP_ELEMENT_OUTCOMES.DATE_FROM');
      hr_utility.raise_error;
    end if;
    --
    --
    --   Check that date_from >= date on which the outcome was defined in the system
    --
    hr_utility.set_location(l_proc, 50);
    --
    open csr_get_outcome_active_date ;
    fetch csr_get_outcome_active_date into l_outcome_active_date;
    close csr_get_outcome_active_date;

    if p_date_from < nvl( l_outcome_active_date,hr_api.g_eot) then
      hr_utility.set_message(800,'HR_34724_COMP_OUTCME_DATE_INVL');
      hr_multi_message.add
	  (p_associated_column1 => 'PER_COMP_ELEMENT_OUTCOMES.DATE_FROM');
      hr_utility.raise_error;
    end if;
    --

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in per_ceo_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.comp_element_outcome_id is not null)  and (
    nvl(per_ceo_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) ))
    or (p_rec.comp_element_outcome_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Comp Element Outcomes DDF'
      ,p_attribute_category              => p_rec.INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in per_ceo_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.comp_element_outcome_id is not null)  and (
    nvl(per_ceo_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_ceo_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.comp_element_outcome_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_COMP_ELEMENT_OUTCOMES'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_ceo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  --
  -- Validate comp_element_outcome_id
  --
  chk_comp_element_outcome_id
  (p_comp_element_outcome_id    => p_rec.comp_element_outcome_id
  ,p_object_version_number	=> p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 10);

  --
  -- Validate competence_element_id
  --
  chk_competence_element_id
  (p_comp_element_outcome_id    => p_rec.comp_element_outcome_id
  ,p_competence_element_id      => p_rec.competence_element_id
  ,p_object_version_number	=> p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 20);

  --
  -- Validate dates
  --
  chk_dates
  (p_comp_element_outcome_id    => p_rec.comp_element_outcome_id
  ,p_outcome_id                 => p_rec.outcome_id
  ,p_date_from             	=> p_rec.date_from
  ,p_date_to               	=> p_rec.date_to
  ,p_object_version_number	=> p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate a combination of competence_element_id and outcome_id is unique
  --
  chk_uniq_comp_element_outcome
  (p_comp_element_outcome_id    => p_rec.comp_element_outcome_id
  ,p_competence_element_id    	=> p_rec.competence_element_id
  ,p_outcome_id               	=> p_rec.outcome_id
  ,p_date_from             	=> p_rec.date_from
  ,p_date_to               	=> p_rec.date_to
  ,p_object_version_number	=> p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate Dependent Attributes
  --
  --
  per_ceo_bus.chk_df(p_rec);

  hr_utility.set_location(l_proc, 50);

  per_ceo_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_ceo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  --
  -- Validate comp_element_outcome_id
  --
  chk_comp_element_outcome_id
  (p_comp_element_outcome_id    => p_rec.comp_element_outcome_id
  ,p_object_version_number	=> p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 10);

  --
  -- Validate competence_element_id
  --
  chk_competence_element_id
  (p_comp_element_outcome_id    => p_rec.comp_element_outcome_id
  ,p_competence_element_id      => p_rec.competence_element_id
  ,p_object_version_number	=> p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 20);

  --
  -- Validate dates
  --
  chk_dates
  (p_comp_element_outcome_id    => p_rec.comp_element_outcome_id,
   p_outcome_id                 => p_rec.outcome_id,
   p_date_from             	=> p_rec.date_from,
   p_date_to               	=> p_rec.date_to,
   p_object_version_number 	=> p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate a combination of competence_element_id and outcome_id is unique
  --
  chk_uniq_comp_element_outcome
  (p_comp_element_outcome_id    => p_rec.comp_element_outcome_id
  ,p_competence_element_id    	=> p_rec.competence_element_id
  ,p_outcome_id               	=> p_rec.outcome_id
  ,p_date_from             	=> p_rec.date_from
  ,p_date_to               	=> p_rec.date_to
  ,p_object_version_number	=> p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
    ,p_rec                => p_rec
    );

  hr_utility.set_location(l_proc, 50);
  --
  per_ceo_bus.chk_df(p_rec);
  --
  hr_utility.set_location(l_proc, 60);

  per_ceo_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ceo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_ceo_bus.chk_df(p_rec);

  hr_utility.set_location(l_proc, 10);

  per_ceo_bus.chk_ddf(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_outcome_achieved >-------------------------|
-- ----------------------------------------------------------------------------
--
function check_outcome_achieved
  (p_effective_date              in     date
  ,p_competence_element_id       in     number
  ,p_competence_id               in     number
) return date
 as
  --
  -- Declare cursors and local variables
  --
  cursor csr_get_outcome_number is
    select count(cpo.outcome_id)  from per_competence_outcomes cpo
           where cpo.competence_id = p_competence_id
           and p_effective_date between date_from
           and nvl(date_to,hr_api.g_eot);

  cursor csr_get_achieved_number is
     select count(ceo.comp_element_outcome_id)
            ,max(ceo.date_from)
          from per_comp_element_outcomes ceo
          where ceo.competence_element_id = p_competence_element_id
          -- and p_effective_date between ceo.date_from
          -- and nvl(date_to,hr_api.g_eot)
          and ceo.outcome_id in (
              select cpo2.outcome_id from per_competence_outcomes cpo2
              where cpo2.competence_id = p_competence_id
              and p_effective_date between cpo2.date_from
                  and nvl(cpo2.date_to,hr_api.g_eot));

  --
  --
  l_proc            varchar2(72) := g_package||'check_outcome_achieved';
  l_exists          varchar2(1);
  l_return          date;
  l_outcome_number  number;
  l_achieved_number number;
  l_max_date_from   date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.trace('p_competence_id         : ' || p_competence_id);
  hr_utility.trace('p_competence_element_id : ' || p_competence_element_id);

  open csr_get_outcome_number;
  fetch csr_get_outcome_number into l_outcome_number;
  close csr_get_outcome_number;
  hr_utility.trace('l_outcome_number  : ' || l_outcome_number);

  open csr_get_achieved_number;
  fetch csr_get_achieved_number into l_achieved_number,l_max_date_from;
  close csr_get_achieved_number;
  hr_utility.trace('l_achieved_number : ' || l_achieved_number);
  hr_utility.trace('l_max_date_from   : ' || l_max_date_from);

  if l_outcome_number = l_achieved_number then
    l_return := l_max_date_from;
    hr_utility.set_location(l_proc, 20);
  else
    l_return := NULL;
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  hr_utility.set_location('Leaving:' || l_proc, 40);
  return(l_return);
  --
end check_outcome_achieved;
--
end per_ceo_bus;


/
