--------------------------------------------------------
--  DDL for Package Body HXC_ULA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULA_BUS" as
/* $Header: hxcularhi.pkb 120.3 2005/09/23 05:57:47 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ula_bus.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_layout >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_layout
   (p_layout_id        IN NUMBER    DEFAULT NULL
   ,p_layout_name      IN VARCHAR2
   ,p_application_id   IN NUMBER
   )
IS
--
CURSOR csr_chk_layout_unique IS
SELECT 1
  FROM hxc_layouts
 WHERE layout_name = p_layout_name
   AND p_application_id = application_id
   AND (p_layout_id IS NULL
       OR layout_id <> p_layout_id);
--
l_result  NUMBER;
--
BEGIN
   --
   OPEN csr_chk_layout_unique;
   --
   FETCH csr_chk_layout_unique INTO l_result;
   --
   IF csr_chk_layout_unique%FOUND THEN
      CLOSE csr_chk_layout_unique;
      fnd_message.set_name('HXC', 'HXC_xxxxx_LAYOUT_NOT_UNIQUE');
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_chk_layout_unique;
   --
END chk_layout;
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
  (p_rec in hxc_ula_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the hxc Schema.
  --
  IF NOT hxc_ula_shd.api_updating
      (p_layout_id                            => p_rec.layout_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_ula_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'insert_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Check that layout_name and application_id are unique
  --
  chk_layout
   (p_layout_name => p_rec.layout_name
   ,p_application_id => p_rec.application_id);
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hxc_ula_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'update_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  -- Check that layout_name and application_id are unique
  --
  chk_layout
   (p_layout_id => p_rec.layout_id
   ,p_layout_name => p_rec.layout_name
   ,p_application_id => p_rec.application_id);
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_ula_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'delete_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_ula_bus;

/
