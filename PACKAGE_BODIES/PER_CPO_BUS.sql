--------------------------------------------------------
--  DDL for Package Body PER_CPO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPO_BUS" as
/* $Header: pecporhi.pkb 115.0 2004/03/17 10:23 ynegoro noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cpo_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_outcome_id                  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_outcome_id                           in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_competence_outcomes cpo
     where cpo.outcome_id = p_outcome_id;
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
    ,p_argument           => 'outcome_id'
    ,p_argument_value     => p_outcome_id
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
  (p_outcome_id                           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , per_competence_outcomes cpo
     where cpo.outcome_id = p_outcome_id;
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
    ,p_argument           => 'outcome_id'
    ,p_argument_value     => p_outcome_id
    );
  --
  if ( nvl(per_cpo_bus.g_outcome_id, hr_api.g_number)
       = p_outcome_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_cpo_bus.g_legislation_code;
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
    per_cpo_bus.g_outcome_id                  := p_outcome_id;
    per_cpo_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in per_cpo_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_cpo_shd.api_updating
      (p_outcome_id                        => p_rec.outcome_id
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
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_outcome_id >----------------------------|
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
--   outcome_id PK of record being inserted or updated.
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
Procedure chk_outcome_id
 ( p_outcome_id            in  per_competence_outcomes.outcome_id%TYPE
  ,p_object_version_number in  per_competence_outcomes.object_version_number%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_outcome_id';
  l_api_updating boolean;
  --
Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_cpo_shd.api_updating
    (p_outcome_id                   => p_outcome_id
    ,p_object_version_number        => p_object_version_number
   );
  --
  if (l_api_updating
     and nvl(p_outcome_id,hr_api.g_number)
     <>  per_cpo_shd.g_old_rec.outcome_id) then
    --
    -- raise error as PK has changed
    --
    per_cpo_shd.constraint_error('PER_COMPETENCE_OUTCOMES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_outcome_id is not null then
      --
      -- raise error as PK is not null
      --
      per_cpo_shd.constraint_error('PER_COMPETENCE_OUTCOMES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_outcome_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_competence_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that compence_id is mandatory and foreign key to
--    per_competences table
--
--  Pre-conditions:
--
--
--  In Arguments :
--    p_outcome_id
--    p_competence_id
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
procedure chk_competence_id
  (p_outcome_id                 in      number
  ,p_competence_id              in      number
  ,p_object_version_number      in      number
  ) is
--
  --
  -- Declare cursor
  --
   cursor csr_competence is
     select '1' from per_competences
     where  competence_id  = p_competence_id;

  --
  -- Declare local variables
  --
   l_proc          varchar2(72) := g_package||'chk_competence_id';
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
    ,p_argument         => 'competence_id'
    ,p_argument_value   => p_competence_id
    );

  hr_utility.set_location(l_proc, 20);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_cpo_shd.api_updating
    (p_outcome_id                => p_outcome_id
    ,p_object_version_number     => p_object_version_number);
  --

  if ((l_api_updating and
       (per_cpo_shd.g_old_rec.competence_id <> p_competence_id)) or
       (NOT l_api_updating)) then

    --
    --   Check that competence_id is a foreign key
    --
    hr_utility.set_location(l_proc, 30);
    --
    open csr_competence;
    fetch csr_competence into l_exists;
    if csr_competence%NOTFOUND then
      close csr_competence;
      per_cpo_shd.constraint_error
      (
        p_constraint_name => 'PER_COMPETENCE_OUTCOME_FK1'
      );
    end if;
    close csr_competence;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_competence_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_outcome_number>------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that a OUTCOME_NUMBER is unique within a COMEPTENCE_ID
--
--  Pre-conditions:
--   None.
--
--  In Arguments :
--    p_outcome_id
--    p_competence_id
--    p_outcome_number
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
procedure chk_outcome_number
  (p_outcome_id                 in      number
  ,p_competence_id              in      number
  ,p_outcome_number             in      number
  ,p_date_from                  in      date
  ,p_date_to                    in      date
  ,p_object_version_number      in      number
  )  is
--
  --
  -- Declare cursor
  --
   cursor csr_outcome_number is
     select null from per_competence_outcomes
     where  competence_id = p_competence_id
     and    outcome_number = p_outcome_number
     and   (p_date_from <= nvl(date_to, hr_api.g_eot)
             and NVL(p_date_to, hr_api.g_eot) >= date_from);

   cursor csr_upd_outcome_number is
     select null from per_competence_outcomes
     where   outcome_id <> p_outcome_id
     and     competence_id = p_competence_id
     and     outcome_number = p_outcome_number
     and    (p_date_from <= nvl(date_to, hr_api.g_eot)
              and NVL(p_date_to, hr_api.g_eot) >= date_from);

  --
  -- Declare local variables
  --
   l_proc          varchar2(72) := g_package||'chk_outcome_number';
   l_api_updating  boolean;
   l_exists        varchar2(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_utility.trace('outcome_id     : ' || p_outcome_id);
  hr_utility.trace('date_from      : ' || p_date_from);
  hr_utility.trace('date_to        : ' || p_date_to);
  hr_utility.trace('outcome_number : ' || p_outcome_number);
  hr_utility.trace('competence_id  : ' || p_competence_id);
  --
  --    Check mandatory parameters have been set
  --

  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'outcome_number'
    ,p_argument_value   => p_outcome_number
    );

  hr_utility.set_location(l_proc, 20);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_cpo_shd.api_updating
    (p_outcome_id                => p_outcome_id
    ,p_object_version_number     => p_object_version_number);
  --

  if (l_api_updating and
       (per_cpo_shd.g_old_rec.outcome_number <> p_outcome_number or
       per_cpo_shd.g_old_rec.date_from <> p_date_from or
       nvl(per_cpo_shd.g_old_rec.date_to,hr_api.g_eot) <>
                                               nvl(p_date_to,hr_api.g_eot)))
  then
    --
    --   Check that outcome_number is unique
    --
    hr_utility.set_location(l_proc, 30);
    open csr_upd_outcome_number;
    fetch csr_upd_outcome_number into l_exists;
    if csr_upd_outcome_number%FOUND then
      close csr_upd_outcome_number;
      hr_utility.set_message(800, 'HR_449129_QUA_FWK_NUMBER_EXIST');
      hr_utility.raise_error;
    end if;
    close csr_upd_outcome_number;
    --
  elsif (NOT l_api_updating) then
    hr_utility.set_location(l_proc, 35);
    open csr_outcome_number;
    fetch csr_outcome_number into l_exists;
    if csr_outcome_number%FOUND then
      close csr_outcome_number;
      hr_utility.set_message(800, 'HR_449129_QUA_FWK_NUMBER_EXIST');
      hr_utility.raise_error;
    end if;
    close csr_outcome_number;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_outcome_number;
--
--  ---------------------------------------------------------------------------
--  |------------------------------< chk_name >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that a NAME is unique within a COMEPTENCE_ID
--
--  Pre-conditions:
--   None.
--
--  In Arguments :
--    p_outcome_id
--    p_competence_id
--    p_name
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
procedure chk_name
  (p_outcome_id                 in      number
  ,p_competence_id              in      number
  ,p_name                       in      varchar2
  ,p_date_from                  in      date
  ,p_date_to                    in      date
  ,p_object_version_number      in      number
  )  is
--
  --
  -- Declare cursor
  --
   cursor csr_name is
     select null from per_competence_outcomes
     where  competence_id = p_competence_id
     and    name = p_name
     and   (p_date_from <= nvl(date_to, hr_api.g_eot)
             and NVL(p_date_to, hr_api.g_eot) >= date_from);

   cursor csr_upd_name is
     select null from per_competence_outcomes
     where  outcome_id <> p_outcome_id
     and    competence_id = p_competence_id
     and    name = p_name
     and   (p_date_from <= nvl(date_to, hr_api.g_eot)
             and NVL(p_date_to, hr_api.g_eot) >= date_from);

  --
  -- Declare local variables
  --
   l_proc          varchar2(72) := g_package||'chk_name';
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
    ,p_argument         => 'name'
    ,p_argument_value   => p_name
    );

  hr_utility.set_location(l_proc, 20);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed

  l_api_updating := per_cpo_shd.api_updating
    (p_outcome_id                => p_outcome_id
    ,p_object_version_number     => p_object_version_number);
  --

  if (l_api_updating and
       per_cpo_shd.g_old_rec.name <> p_name or
       per_cpo_shd.g_old_rec.date_from <> p_date_from or
       nvl(per_cpo_shd.g_old_rec.date_to,hr_api.g_eot) <>
                                               nvl(p_date_to,hr_api.g_eot))
  then
    --
    --   Check that outcome_number is unique
    --
    hr_utility.set_location(l_proc, 30);
    open csr_upd_name;
    fetch csr_upd_name into l_exists;
    if csr_upd_name%FOUND then
      close csr_upd_name;
      hr_utility.set_message(800, 'HR_449130_QUA_FWK_NAME_EXISTS');
      hr_utility.raise_error;
    end if;
    close csr_upd_name;
    --
  elsif (NOT l_api_updating) then
    hr_utility.set_location(l_proc, 35);
    open csr_name;
    fetch csr_name into l_exists;
    if csr_name%FOUND then
      close csr_name;
      hr_utility.set_message(800, 'HR_449130_QUA_FWK_NAME_EXISTS');
      hr_utility.raise_error;
    end if;
    close csr_name;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_name;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_dates >---------------------------------|
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
procedure chk_dates
  (p_outcome_id                 in      number default null
  ,p_date_from                  in      date
  ,p_date_to                    in      date
  ,p_object_version_number      in number default null
  )      is
--
   l_proc          varchar2(72) := g_package||'chk_dates';
   l_api_updating  boolean;
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
  l_api_updating := per_cpo_shd.api_updating
    (p_outcome_id                => p_outcome_id
    ,p_object_version_number     => p_object_version_number);
  --
  if (((l_api_updating and
       (nvl(per_cpo_shd.g_old_rec.date_to,hr_api.g_eot) <>
                                               nvl(p_date_to,hr_api.g_eot)) or
       (per_cpo_shd.g_old_rec.date_from <> p_date_from)) or
       (NOT l_api_updating))) then
    --
    --   Check that date_from <= date_to
    --
    hr_utility.set_location(l_proc, 30);
    --
    if p_date_from > nvl(p_date_to,hr_api.g_eot) then
      hr_utility.set_message(800,'HR_6758_APPL_DATE_FROM_CHK');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_dates;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_delete >--------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that there are no values in
--   per_comp_element_outcomes.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_outcome_id
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
--
PROCEDURE chk_delete(
   p_outcome_id         in per_competence_outcomes.outcome_id%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_delete';
  l_exists       varchar2(1);
  --
cursor csr_outcome is
           select 'x'
           FROM per_comp_element_outcomes
           WHERE outcome_id = p_outcome_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --  Check there are no values in per_comp_element_outcomes
  --
  open csr_outcome;
  --
  fetch csr_outcome into l_exists;
  --
    If csr_outcome%found Then
    --
      close csr_outcome;
      --
      hr_utility.set_message(800, 'HR_449131_QUA_FWK_DEL_OUTCOME');
      fnd_message.raise_error;
      --
    End If;
  --
  close csr_outcome;
  --
  hr_utility.set_location('Leaving:' || l_proc, 40);
  --
end chk_delete;
--
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
  (p_rec in per_cpo_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.outcome_id is not null)  and (
    nvl(per_cpo_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) ))
    or (p_rec.outcome_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Competence Outcomes DDF'
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
  (p_rec in per_cpo_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.outcome_id is not null)  and (
    nvl(per_cpo_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_cpo_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.outcome_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_COMPETENCE_OUTCOMES'
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
  ,p_rec                          in per_cpo_shd.g_rec_type
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
  -- Validate outcome_id
  --
  chk_outcome_id
  (p_outcome_id            => p_rec.outcome_id
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 10);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate competence_id
  --
  chk_competence_id
  (p_outcome_id            => p_rec.outcome_id
  ,p_competence_id         => p_rec.competence_id
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 20);

  --
  -- Validate dates
  --
  chk_dates
  (p_outcome_id            => p_rec.outcome_id
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  ,p_object_version_number => p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate outcome_number
  --
  chk_outcome_number
  (p_outcome_id            => p_rec.outcome_id
  ,p_competence_id         => p_rec.competence_id
  ,p_outcome_number        => p_rec.outcome_number
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate name
  --
  chk_name
  (p_outcome_id            => p_rec.outcome_id
  ,p_competence_id         => p_rec.competence_id
  ,p_name                  => p_rec.name
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 50);


  --
  -- Validate Dependent Attributes
  --
  --
  per_cpo_bus.chk_df(p_rec);

  hr_utility.set_location(l_proc, 60);

  per_cpo_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_cpo_shd.g_rec_type
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
  -- Validate outcome_id
  --
  chk_outcome_id
  (p_outcome_id            => p_rec.outcome_id
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 10);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate competence_id
  --
  chk_competence_id
  (p_outcome_id            => p_rec.outcome_id
  ,p_competence_id         => p_rec.competence_id
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 20);

  --
  -- Validate date effective
  --
  chk_dates
  (p_outcome_id            => p_rec.outcome_id
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  ,p_object_version_number => p_rec.object_version_number
   );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate outcome_number
  --
  chk_outcome_number
  (p_outcome_id            => p_rec.outcome_id
  ,p_competence_id         => p_rec.competence_id
  ,p_outcome_number        => p_rec.outcome_number
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate name
  --
  chk_name
  (p_outcome_id            => p_rec.outcome_id
  ,p_competence_id         => p_rec.competence_id
  ,p_name                  => p_rec.name
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 50);

  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date      => p_effective_date
      ,p_rec               => p_rec
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  per_cpo_bus.chk_df(p_rec);

  hr_utility.set_location(l_proc, 70);

  per_cpo_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_cpo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete
  (p_outcome_id    => p_rec.outcome_id
  );

  hr_utility.set_location(l_proc, 10);

  per_cpo_bus.chk_df(p_rec);

  hr_utility.set_location(l_proc, 20);

  per_cpo_bus.chk_ddf(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 30);
End delete_validate;
--
end per_cpo_bus;

/
