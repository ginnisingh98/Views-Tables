--------------------------------------------------------
--  DDL for Package Body HR_OTY_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OTY_BUS" as
/* $Header: hrotyrhi.pkb 115.0 2004/01/09 02:19 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_oty_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_option_type_id              number         default null;
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
  (p_rec in hr_oty_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_oty_shd.api_updating
      (p_option_type_id                    => p_rec.option_type_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  if nvl(p_rec.option_type_key, hr_api.g_varchar2) <>
       nvl(hr_oty_shd.g_old_rec.option_type_key
           ,hr_api.g_varchar2
           ) then
      hr_api.argument_changed_error
        (p_api_name   => l_proc
        ,p_argument   => 'OPTION_TYPE_KEY'
        ,p_base_table => hr_oty_shd.g_tab_nam
        );
  end if;

End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_OPTION_TYPE_KEY>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid option type key is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_option_type_key
-- Post Success:
--   Processing continues if option type key is not null and unique
--
-- Post Failure:
--   An application error is raised if option type key is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_option_type_key
  (p_option_type_key     in varchar2

  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_OPTION_TYPE_KEY';
  l_key     varchar2(1) ;
  cursor csr_key is
         select null
           from hr_ki_option_types
          where  option_type_key = p_option_type_key;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'OPTION_TYPE_KEY'
  ,p_argument_value     => p_option_type_key
  );

  hr_utility.set_location('Opening cursor:'||l_proc,20);
    open csr_key;
    fetch csr_key into l_key;
    if (csr_key%found)
    then
      close csr_key;
      fnd_message.set_name('PER','PER_449945_OTY_OPTION_KEY_DUP');
      fnd_message.raise_error;
    end if;
    close csr_key;

  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_OPTION_TYPES.OPTION_TYPE_KEY'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_option_type_key;



-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_DISPLAY_TYPE>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a display type is entered in correct format,
--   Also If display type is lookup then VOName is entered or not.
--   Format is
--   textfield
--   OR
--   lookup:<VOName which populates lookup>
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_display_type
-- Post Success:
--   Processing continues if display type is valid.
--
-- Post Failure:
--   An application error is raised if display type is in invalid format
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_DISPLAY_TYPE
  (p_display_type     in varchar2

  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_DISPLAY_TYPE';
  l_text     varchar2(20) :='TEXTFIELD';
  l_lookup   varchar2(20) :='LOOKUP#';
  l_view_name     varchar2(100):='';

--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'DISPLAY_TYPE'
  ,p_argument_value     => p_display_type
  );

  hr_utility.set_location('Display type is not null'||l_proc,20);

  IF upper(p_display_type) =l_text  THEN
     --display type is textfield no validations are required
    null;

  ELSIF (instr(upper(p_display_type),l_lookup) > 0) THEN

  l_view_name:=substr(upper(p_display_type),length(l_lookup)+1);


           if l_view_name is null then
              fnd_message.set_name ( 'PER','PER_449947_OTY_DIS_TY_NOVO');
              -- Specify VOName for lookup
               fnd_message.raise_error;
          end if;

  ELSE
     fnd_message.set_name      ( 'PER' ,'PER_449946_OTY_DIS_TY_INVALID');
     --Please specify display type as either textfield or lookup:<VOName>
      fnd_message.raise_error;
  END IF;

  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_OPTION_TYPES.DISPLAY_TYPE'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_DISPLAY_TYPE;

-- ----------------------------------------------------------------------------
-- -------------------------------< CHK_DELETE>--------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a delete occurs only if there are no child
--   rows for a record in hr_ki_option_types. The tables that contain child
--   rows are hr_ki_option_types_tl,hr_ki_options.
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_integration_id

-- Post Success:
--   Processing continues if there are no child records.
--
-- Post Failure:
--   An application error is raised if there are any child rows from any of the
--   above mentioned tables.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_delete
  (p_option_type_id                        in number
  )
  is
  --
  -- Declare local variables
  --
  l_proc              varchar2(72) :=  g_package||'chk_delete';
  l_exists            varchar2(1);
  l_exists_tl         varchar2(1);
  --
  --  Cursor to check that if maintenance rows type exists.
  --
  cursor csr_maintenance_option is
    select null
      from hr_ki_options
     where option_type_id          = p_option_type_id         ;

  cursor csr_maintenance_tl is
    select null
      from hr_ki_option_types_tl
     where option_type_id          = p_option_type_id         ;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Can always execute the cursor as chk_delete
  -- will only be called for delete validation
  -- from within the row handler.
  --
  open csr_maintenance_option;
  fetch csr_maintenance_option into l_exists;
  if csr_maintenance_option%found then
    close csr_maintenance_option;
    fnd_message.set_name('PER', 'PER_449948_OTY_OPT_MAIN_EXIST');
    fnd_message.raise_error;
  end if;
  close csr_maintenance_option;

  hr_utility.set_location('Checking for TL:'|| l_proc, 20);
  open csr_maintenance_tl;
  fetch csr_maintenance_tl into l_exists_tl;
  if csr_maintenance_tl%found then
    close csr_maintenance_tl;
    fnd_message.set_name('PER', 'PER_449949_OTY_OP_TL_EXIST');
    fnd_message.raise_error;
  end if;
  close csr_maintenance_tl;

  hr_utility.set_location(' Leaving:'|| l_proc, 30);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
          (p_associated_column1 => 'HR_KI_OPTION_TYPES.option_type_id'
          ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_delete;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_oty_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  -- Call for attribute validations
  CHK_OPTION_TYPE_KEY
    (
     p_option_type_key  => p_rec.option_type_key

    );

  CHK_DISPLAY_TYPE
    (
    p_display_type  => p_rec.display_type
    );

  --end call for attribute validations

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_oty_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --check for display type validation
  HR_OTY_BUS.CHK_DISPLAY_TYPE
    (
    p_display_type  => p_rec.display_type
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
  (p_rec                          in hr_oty_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
    HR_OTY_BUS.chk_delete
    (p_option_type_id       =>     p_rec.option_type_id
    );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_oty_bus;

/
