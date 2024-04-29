--------------------------------------------------------
--  DDL for Package Body HR_PDC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PDC_BUS" as
/* $Header: hrpdcrhi.pkb 120.1 2005/09/27 06:23 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_pdc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_person_deplymt_contact_id   number         default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_person_deplymt_contact_id            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , hr_person_deplymt_contacts pdc
         , hr_person_deployments pdt
     where pdc.person_deplymt_contact_id = p_person_deplymt_contact_id
       and pdc.person_deployment_id = pdt.person_deployment_id
       and pbg.business_group_id = pdt.to_business_group_id;
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
    ,p_argument           => 'person_deplymt_contact_id'
    ,p_argument_value     => p_person_deplymt_contact_id
    );
  --
  if ( nvl(hr_pdc_bus.g_person_deplymt_contact_id, hr_api.g_number)
       = p_person_deplymt_contact_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_pdc_bus.g_legislation_code;
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
    hr_pdc_bus.g_person_deplymt_contact_id   := p_person_deplymt_contact_id;
    hr_pdc_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hr_pdc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error       exception;
  l_argument    varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_pdc_shd.api_updating
      (p_person_deplymt_contact_id         => p_rec.person_deplymt_contact_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location (l_proc, 20);
  --
  if nvl(p_rec.person_deployment_id,hr_api.g_number)
        <> nvl(hr_pdc_shd.g_old_rec.person_deployment_id,hr_api.g_number) then
     l_argument := 'person_deployment_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.contact_relationship_id,hr_api.g_number)
        <> nvl(hr_pdc_shd.g_old_rec.contact_relationship_id,hr_api.g_number) then
     l_argument := 'contact_relationship_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Leaving : '|| l_proc, 30);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_person_deployment_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the person deployment id exists on the
--    HR_PERSON_DEPLOYMENTS table
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_person_deployment_id
--
--  Post Success :
--    Processing continues if the person deployment id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    person deployment id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_person_deployment_id
  (p_person_deployment_id in hr_person_deplymt_eits.person_deployment_id%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_person_deployment_id';
  l_dummy       number;
  --
  cursor csr_deployment is
  select 1
  from hr_person_deployments
  where person_deployment_id = p_person_deployment_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'person_deployment_id',
     p_argument_value   => p_person_deployment_id
    );
  --
  open csr_deployment;
  fetch csr_deployment into l_dummy;
  if csr_deployment%notfound then
     close csr_deployment;
     fnd_message.set_name('PER','HR_44609_DPL_NOT_EXIST');
     fnd_message.raise_error;
  else
     close csr_deployment;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end chk_person_deployment_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_contact_relationship_id >------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the personcontact relationship id exists on the
--    PER_CONTACT_RELATIONSHIPS table
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_contact_relationship_id
--
--  Post Success :
--    Processing continues if the contact relationship id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    contact relationship is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_contact_relationship_id
  (p_contact_relationship_id  in  hr_person_deplymt_contacts.contact_relationship_id%type
  ,p_person_deployment_id     in  hr_person_deplymt_contacts.person_deployment_id%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_person_extra_info_id';
  l_dummy       number;
  --
  cursor csr_contact_rel is
  select 1
  from per_contact_relationships
  where contact_relationship_id = p_contact_relationship_id;
  --
  cursor csr_check_person is
  select ctr.person_id
  from   per_contact_relationships ctr,
         hr_person_deployments pdt
  where  pdt.person_deployment_id = p_person_deployment_id
  and    ctr.contact_relationship_id = p_contact_relationship_id
  and    pdt.from_person_id = ctr.person_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'person_deployment_id',
     p_argument_value   => p_person_deployment_id
    );
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'contact_relationship_id',
     p_argument_value   => p_contact_relationship_id
    );
  --
  open csr_contact_rel;
  fetch csr_contact_rel into l_dummy;
  if csr_contact_rel%found then
     close csr_contact_rel;
     --
     open csr_check_person;
     fetch csr_check_person into l_dummy;
     if csr_check_person%notfound then
        close csr_check_person;
        --
        fnd_message.set_name('PER','HR_449610_PDC_WRONG_PERSON');
        fnd_message.raise_error;
     else         --relationship does not belong to right person
        close csr_check_person;
     end if;
  else       --relationship does not exist
      close csr_contact_rel;
      --
      fnd_message.set_name('PER','HR_449611_PDC_REL_NOT_EXIST');
      fnd_message.raise_error;
  end if;
  --
end chk_contact_relationship_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_pdc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS

  -- Validate Dependent Attributes
  --
  hr_pdc_bus.chk_person_deployment_id
    (p_person_deployment_id   =>   p_rec.person_deployment_id);
  --
  hr_pdc_bus.chk_contact_relationship_id
    (p_contact_relationship_id =>   p_rec.contact_relationship_id
    ,p_person_deployment_id    =>   p_rec.person_deployment_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_pdc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_pdc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_pdc_bus;

/
