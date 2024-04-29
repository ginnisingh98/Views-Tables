--------------------------------------------------------
--  DDL for Package Body HR_FDG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FDG_BUS" as
/* $Header: hrfdgrhi.pkb 115.4 2002/12/03 10:53:27 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_fdg_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_form_data_group_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_form_data_group_id                   in number
  ) is
  --
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- No business group context. Security group is not applicable.
  --
  null;
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
  (p_form_data_group_id                   in     number
  )
  Return Varchar2 Is
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Legislation code not available for form data groups
  --
  l_legislation_code := null;
  --
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
  (p_rec in hr_fdg_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_fdg_shd.api_updating
      (p_form_data_group_id                   => p_rec.form_data_group_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.application_id,hr_api.g_number) <>
      nvl(hr_fdg_shd.g_old_rec.application_id,hr_api.g_number)
     ) THEN
     l_argument := 'application_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.form_id,hr_api.g_number) <>
      nvl(hr_fdg_shd.g_old_rec.form_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_id';
     RAISE l_error;
  END IF;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_application_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_application_id
  (p_form_data_group_id           in number
  ,p_object_version_number        in number
  ,p_application_id               in number
  ) is
  l_check number;
  CURSOR cur_chk_app_id
  IS
  SELECT 1
  FROM fnd_application
  WHERE application_id = p_application_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_application_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'application_id'
    ,p_argument_value               => p_application_id
    );
  --
  OPEN cur_chk_app_id;
  FETCH cur_chk_app_id INTO l_check;
  IF cur_chk_app_id%NOTFOUND THEN
    CLOSE cur_chk_app_id;
-- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;
  CLOSE cur_chk_app_id;

  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_application_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_form_id >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_id
  (p_form_data_group_id           in number
  ,p_object_version_number        in number
  ,p_form_id                      in number
  ,p_application_id               in number
  ) is
  --
  l_check number;
  CURSOR cur_chk_form_id
  IS
  SELECT 1
  FROM fnd_form
  WHERE form_id = p_form_id
  AND application_id = p_application_id;
  l_proc                         varchar2(72) := g_package || 'chk_form_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'form_id'
    ,p_argument_value               => p_form_id
    );
  --
  OPEN cur_chk_form_id;
  FETCH cur_chk_form_id INTO l_check;
  IF cur_chk_form_id%NOTFOUND THEN
    CLOSE cur_chk_form_id;
-- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;
  CLOSE cur_chk_form_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_data_group_name >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_data_group_name
  (p_form_data_group_id           in number
  ,p_object_version_number        in number
  ,p_data_group_name              in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_data_group_name';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'data_group_name'
    ,p_argument_value               => p_data_group_name
    );
  --
  -- Check value is in uppercase
  --
  if p_data_group_name <> upper(p_data_group_name) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_data_group_name;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_fdg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- No additional validation required
  --
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_fdg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  chk_application_id
    (p_form_data_group_id           => p_rec.form_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_form_id
    (p_form_data_group_id           => p_rec.form_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_id                      => p_rec.form_id
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_data_group_name
    (p_form_data_group_id           => p_rec.form_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_data_group_name              => p_rec.data_group_name
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_fdg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  chk_non_updateable_args
    (p_rec                          => p_rec
    );
  --
  chk_application_id
    (p_form_data_group_id           => p_rec.form_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_form_id
    (p_form_data_group_id           => p_rec.form_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_id                      => p_rec.form_id
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_data_group_name
    (p_form_data_group_id           => p_rec.form_data_group_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_data_group_name              => p_rec.data_group_name
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_fdg_shd.g_rec_type
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
    (p_rec                          => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_fdg_bus;

/
