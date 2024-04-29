--------------------------------------------------------
--  DDL for Package Body HR_AVM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AVM_BUS" as
/* $Header: hravmrhi.pkb 115.1 2002/12/02 15:47:59 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_avm_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_ath_variablemap_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ath_variablemap_id                   in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  --
  -- Declare local variables
  --
  l_security_group_id number;
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
    ,p_argument           => 'ath_variablemap_id'
    ,p_argument_value     => p_ath_variablemap_id
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
  (p_rec in hr_avm_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_avm_shd.api_updating
      (p_ath_variablemap_id                => p_rec.ath_variablemap_id
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
-- |---------------------------< chk_ath_dsn >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that the ath_dsn is not null
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_ath_dsn
--
--  Post Success :
--     If the ath_dsn is non-null then
--     processing continues
--
--  Post Failure :
--       If the ath_dsn is null then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_ath_dsn
    (p_ath_dsn in varchar2) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_ath_dsn';
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'ath_dsn',
       p_argument_value => p_ath_dsn
      );
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_ath_dsn;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ath_tablename >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that the ath_tablename is not null
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_ath_tablename
--
--  Post Success :
--     If the ath_tablename is non-null then
--     processing continues
--
--  Post Failure :
--       If the ath_tablename is null then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_ath_tablename
    (p_ath_tablename in varchar2) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_ath_tablename';
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'ath_tablename',
       p_argument_value => p_ath_tablename
      );
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_ath_tablename;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ath_columnname >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that the ath_columnname is not null
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_ath_columnname
--
--  Post Success :
--     If the ath_columnname is non-null then
--     processing continues
--
--  Post Failure :
--       If the ath_columnname is null then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_ath_columnname
    (p_ath_columnname in varchar2) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_ath_columnname';
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'ath_columnname',
       p_argument_value => p_ath_columnname
      );
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_ath_columnname;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ath_varname >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that the ath_varname is not null
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_ath_varname
--      p_ath_dsn
--      p_ath_tablename
--      p_ath_columnname
--
--  Post Success :
--     If the ath_varname is non-null then
--     processing continues
--
--  Post Failure :
--       If the ath_varname is null then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure  chk_ath_varname
    (p_ath_varname in varchar2
    ,p_ath_dsn in varchar2
    ,p_ath_tablename in varchar2
    ,p_ath_columnname in varchar2) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_ath_varname';
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'ath_varname',
       p_argument_value => p_ath_varname
      );
  --
  hr_utility.set_location(l_proc, 2);
  --
  hr_utility.set_location(l_proc, 3);
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_ath_varname;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_avm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

  -- validate ath_dsn
  --
  chk_ath_dsn (p_ath_dsn => p_rec.ath_dsn);

  -- validate ath_tablename
  --
  chk_ath_tablename (p_ath_tablename => p_rec.ath_tablename);

  -- validate ath_columnname
  --
  chk_ath_columnname (p_ath_columnname => p_rec.ath_columnname);

  -- validate ath_varname
  --
  chk_ath_varname (p_ath_varname => p_rec.ath_varname
                  ,p_ath_dsn => p_rec.ath_dsn
                  ,p_ath_tablename => p_rec.ath_tablename
                  ,p_ath_columnname => p_rec.ath_columnname);

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
  (p_rec                          in hr_avm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

  -- validate ath_dsn
  --
  chk_ath_dsn (p_ath_dsn => p_rec.ath_dsn);

  -- validate ath_tablename
  --
  chk_ath_tablename (p_ath_tablename => p_rec.ath_tablename);

  -- validate ath_columnname
  --
  chk_ath_columnname (p_ath_columnname => p_rec.ath_columnname);

  -- validate ath_varname
  --
  chk_ath_varname (p_ath_varname => p_rec.ath_varname
                  ,p_ath_dsn => p_rec.ath_dsn
                  ,p_ath_tablename => p_rec.ath_tablename
                  ,p_ath_columnname => p_rec.ath_columnname);


  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
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
  (p_rec                          in hr_avm_shd.g_rec_type
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
end hr_avm_bus;

/
