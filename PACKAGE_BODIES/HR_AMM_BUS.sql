--------------------------------------------------------
--  DDL for Package Body HR_AMM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AMM_BUS" as
/* $Header: hrammrhi.pkb 115.3 2002/12/05 12:45:03 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_amm_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_authoria_mapping_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_authoria_mapping_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'authoria_mapping_id'
    ,p_argument_value     => p_authoria_mapping_id
    );
  --
  -- CLIENT_INFO not set. No lookup validation or joins to HR_LOOKUPS.
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
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
  (p_rec in hr_amm_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_amm_shd.api_updating
      (p_authoria_mapping_id               => p_rec.authoria_mapping_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Add checks to ensure non-updateable args have not been updated.
  --
  -- all columns are updateable.
  --
End chk_non_updateable_args;

--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_pl_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that a pl_id exists in the table ben_pl_f
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_pl_id
--
--  Post Success :
--     If a row does exist in ben_pl_f for the given pl_id then
--     processing continues
--
--  Post Failure :
--       If a row does not exist in ben_pl_f for the given pl_id then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_pl_id
    (p_pl_id in number) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_pl_id';
--
  cursor csr_valid_plan is
	select 'Y'
	from ben_pl_f
	where pl_id = p_pl_id;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'pl_id',
       p_argument_value => p_pl_id
      );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the pl_id is in ben_pl_f
  --
  open csr_valid_plan;
  fetch csr_valid_plan into l_exists;
  if csr_valid_plan%notfound then
    close csr_valid_plan;
    hr_utility.set_message(801, 'HR_nnn_PLAN_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  close csr_valid_plan;
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_pl_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_plip_id >---------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that a plip_id exists in the table ben_pgm_f
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_plip_id
--
--  Post Success :
--     If a row does exist in ben_pgm_f for the given plip_id or the
--     plip_id is null then processing continues
--
--  Post Failure :
--       If a row does not exist in ben_pgm_f for the given plip_id then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_plip_id
    (p_plip_id in number) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_plip_id';
--
  cursor csr_valid_program is
	select 'Y'
	from ben_plip_f
	where plip_id = p_plip_id;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the plip_id is in ben_pgm_f
  -- unless the plip_id is null
  --
  if (p_plip_id is not null) then
    open csr_valid_program;
    fetch csr_valid_program into l_exists;
    if csr_valid_program%notfound then
      close csr_valid_program;
      hr_utility.set_message(801, 'HR_nnn_PROGRAM_NOT_EXIST');
      hr_utility.raise_error;
    end if;
    close csr_valid_program;
  end if;
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_plip_id;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_open_enrollment_flag >-------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that the open_enrollment_flag is either Y or N
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_open_enrollment_flag
--
--  Post Success :
--     If the open_enrollment_flag is either Y or N then
--     processing continues
--
--  Post Failure :
--       If the open_enrollment_flag is neither Y or N then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_open_enrollment_flag
    (p_open_enrollment_flag in varchar2) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_open_enrollment_flag';
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'open_enrollment_flag',
       p_argument_value => p_open_enrollment_flag
      );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the open_enrollment_flag is either Y or N
  --
  if not (p_open_enrollment_flag = 'Y'
          or
          p_open_enrollment_flag = 'N') then
    hr_utility.set_message(801, 'HR_nnn_FLAG_NOT_SET');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_open_enrollment_flag;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_target_page >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that the target_page is not null
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_target_page
--
--  Post Success :
--     If the target_page is non-null then
--     processing continues
--
--  Post Failure :
--       If the target_page is null then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_target_page
    (p_target_page in varchar2) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_target_page';
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'target_page',
       p_argument_value => p_target_page
      );
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_target_page;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_ins >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that the combination of pl_id,
--      plip_id and open_enrollment_flag is unique.
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_pl_id
--      p_plip_id
--      p_open_enrollment_flag
--
--  Post Success :
--     If the combination of pl_id,
--     plip_id and open_enrollment_flag is unique then
--     processing continues
--
--  Post Failure :
--     If the combination of pl_id,
--     plip_id and open_enrollment_flag is not unique then
--     an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_unique_ins
    (
     p_pl_id                 in number
    ,p_plip_id               in number
    ,p_open_enrollment_flag  in varchar2) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_unique_ins';

    cursor csr_chk_unique is
      select null
      from  hr_authoria_mappings
      where pl_id            = p_pl_id
        and nvl(plip_id,-924926578) = nvl(p_plip_id,-924926578)
        and open_enrollment_flag = p_open_enrollment_flag;

--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  open csr_chk_unique;
  fetch csr_chk_unique into l_exists;
  if csr_chk_unique%found then
    close csr_chk_unique;
    hr_utility.set_message(801, 'HR_nnn_MAPPING_EXISTS');
    hr_utility.raise_error;
  end if;
  close csr_chk_unique;
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_unique_ins;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_upd >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that the combination of pl_id,
--      plip_id and open_enrollment_flag is unique.
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_pl_id
--      p_plip_id
--      p_open_enrollment_flag
--
--  Post Success :
--     If the combination of pl_id,
--     plip_id and open_enrollment_flag is unique then
--     processing continues
--
--  Post Failure :
--     If the combination of pl_id,
--     plip_id and open_enrollment_flag is not unique then
--     an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_unique_upd
    (
     p_pl_id                 in number
    ,p_plip_id               in number
    ,p_open_enrollment_flag  in varchar2
    ,p_authoria_mapping_id   in number) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_unique_upd';

    cursor csr_chk_unique is
      select null
      from  hr_authoria_mappings
      where pl_id            = p_pl_id
        and nvl(plip_id,-924926578) = nvl(p_plip_id,-924926578)
        and open_enrollment_flag = p_open_enrollment_flag
        and authoria_mapping_id <> p_authoria_mapping_id;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  open csr_chk_unique;
  fetch csr_chk_unique into l_exists;
  if csr_chk_unique%found then
    close csr_chk_unique;
    hr_utility.set_message(801, 'HR_nnn_MAPPING_EXISTS');
    hr_utility.raise_error;
  end if;
  close csr_chk_unique;
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_unique_upd;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_amm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

  -- validate pl_id
  --
  chk_pl_id (p_pl_id => p_rec.pl_id);

  -- validate plip_id
  --
  chk_plip_id (p_plip_id => p_rec.plip_id);

  -- validate open_enrollment_flag
  --
  chk_open_enrollment_flag (
    p_open_enrollment_flag => p_rec.open_enrollment_flag);

  -- validate target_page
  --
  chk_target_page (p_target_page => p_rec.target_page);

  -- validate unique_ins
  --
  chk_unique_ins
    (
     p_pl_id            => p_rec.pl_id
    ,p_plip_id          => p_rec.plip_id
    ,p_open_enrollment_flag => p_rec.open_enrollment_flag
    );
  --
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_amm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

  -- validate pl_id
  --
  chk_pl_id (p_pl_id => p_rec.pl_id);

  -- validate plip_id
  --
  chk_plip_id (p_plip_id => p_rec.plip_id);

  -- validate open_enrollment_flag
  --
  chk_open_enrollment_flag (
    p_open_enrollment_flag => p_rec.open_enrollment_flag);

  -- validate target_page
  --
  chk_target_page (p_target_page => p_rec.target_page);

  -- validate unique_upd
  --
  chk_unique_upd
    (
     p_pl_id            => p_rec.pl_id
    ,p_plip_id          => p_rec.plip_id
    ,p_open_enrollment_flag => p_rec.open_enrollment_flag
    ,p_authoria_mapping_id  => p_rec.authoria_mapping_id
    );

  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
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
  (p_rec                          in hr_amm_shd.g_rec_type
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
end hr_amm_bus;

/
