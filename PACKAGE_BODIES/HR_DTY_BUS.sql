--------------------------------------------------------
--  DDL for Package Body HR_DTY_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DTY_BUS" as
/* $Header: hrdtyrhi.pkb 120.0.12010000.2 2008/08/06 08:36:25 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_dty_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_document_type_id            number         default null;
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
  ,p_rec in hr_dty_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_dty_shd.api_updating
      (p_document_type_id                  => p_rec.document_type_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  --Check for Non- updation of Legislation Code
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     hr_dty_shd.g_old_rec.legislation_code then

    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'LEGISLATION_CODE'
    ,p_base_table => hr_dei_shd.g_tab_nam
    );
  end if;
  --
  --Check for Non- updation of Multiple Occurences Flag
  --
    if nvl(p_rec.multiple_occurences_flag, hr_api.g_varchar2) <>
     hr_dty_shd.g_old_rec.multiple_occurences_flag then

    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'MULTIPLE_OCCURENCES_FLAG'
    ,p_base_table => hr_dei_shd.g_tab_nam
    );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_category_code >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that category_code value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_category_code
--
-- Post Success:
--   Processing continues if category_code is valid and if updating,
--   old_rec.category_code is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_category_code
  (
   p_category_code    in     hr_document_types.category_code%TYPE
  ,p_legislation_code in     hr_document_types.legislation_code%TYPE
  )
  is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_category_code';
  l_api_updating  boolean;
  l_category_code varchar2(50);

 -- Cursor for Validating Category Code


    cursor csr_valid_category_code(p_category_cd varchar2,p_legislation_code varchar2)
    is
    SELECT 'X'
    FROM   FND_LOOKUP_VALUES FLV
    WHERE  FLV.lookup_type = 'DOCUMENT_CATEGORY'
    and    FLV.lookup_code = p_category_cd
    AND    FLV.LANGUAGE = userenv('LANG')
    and    FLV.VIEW_APPLICATION_ID = 3
    and    FLV.SECURITY_GROUP_ID = decode(substr(userenv('CLIENT_INFO'),55,1), ' ', 0, NULL, 0, '0', 0, fnd_global.lookup_security_group(FLV.LOOKUP_TYPE,FLV.VIEW_APPLICATION_ID))
    and    decode(FLV.TAG, NULL, 'Y',
                           decode(substr(FLV.TAG,1,1), '+', decode(sign(instr(FLV.TAG,  p_legislation_code)), 1, 'Y', 'N'),
                                                   '-', decode(sign(instr(FLV.TAG,  p_legislation_code)), 1, 'N', 'Y'), 'Y' ) ) = 'Y';
  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'category_code'
    ,p_argument_value => p_category_code
    );

    --
    -- Check that the Category Code
    -- exists in fnd_lookup_types
    --

     open csr_valid_category_code(p_category_code,p_legislation_code);
        fetch csr_valid_category_code into l_category_code;

        if csr_valid_category_code%notfound then
        close csr_valid_category_code;
        hr_utility.set_message(800, 'HR_449711_DOR_INVL_COND_VAL');
        hr_utility.set_message_token('OBJECT', 'CATEGORY_CODE');
        hr_utility.set_message_token('TABLE', 'FND_LOOKUP_VALUES');
        hr_utility.set_message_token('CONDITION', 'lookup type "DOCUMENT CATEGORY"');
        hr_utility.raise_error;
        hr_utility.set_location(l_proc, 10);
        --
        else
    close csr_valid_category_code;

    end if;
    hr_utility.set_location(l_proc, 20);
    --

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'hr_document_types.category_code'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_category_code;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_sub_category_code >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that sub_category_code value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_category_code
--  p_sub_category_code
--
-- Post Success:
--   Processing continues if category_code is valid and if updating,
--   old_rec.category_code is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_sub_category_code
  (
   p_category_code        in     hr_document_types.category_code%TYPE
  ,p_sub_category_code    in     hr_document_types.sub_category_code%TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_sub_category_code';
  l_api_updating  boolean;
  l_sub_category_code varchar2(50);

 -- Cursor for Validating Sub Category Code

  cursor csr_valid_sub_category_code(p_sub_category_cd varchar2)
   is
    select 'X'
    from   per_shared_types_vl pst
    where  pst.lookup_type = 'DOCUMENT_CATEGORY'
    and    pst.system_type_cd = p_category_code
    and    pst.shared_type_code = p_sub_category_cd;
  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);


    --
    -- Check that the Category Code
    -- exists in per_shared_types
    --
 if(p_sub_category_code is NOT NULL) then
    open csr_valid_sub_category_code(p_sub_category_code);
    fetch csr_valid_sub_category_code into l_sub_category_code;


    if csr_valid_sub_category_code%notfound then
    close csr_valid_sub_category_code;

   hr_utility.set_message(800, 'HR_449711_DOR_INVL_COND_VAL');
   hr_utility.set_message_token('OBJECT', 'SUB_CATEGORY_CODE');
   hr_utility.set_message_token('TABLE', 'PER_SHARED_TYPES');
   hr_utility.set_message_token('CONDITION', 'lookup type "DOCUMENT CATEGORY"');
   hr_utility.raise_error;
   hr_utility.set_location(l_proc, 10);
    --
    else
    close csr_valid_sub_category_code;

    end if;
    end if;
    hr_utility.set_location(l_proc, 20);
    --

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'hr_document_types.sub_category_code'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_sub_category_code;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_active_flag >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that active_inactive_flag value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_active_flag
--  p_document_type_id
--
-- Post Success:
--   Processing continues if category_code is valid and if updating,
--   old_rec.category_code is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_active_flag
  (
   p_active_flag          in     hr_document_types.active_inactive_flag%TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_active_flag';
  l_api_updating  boolean;
  l_active_flag   varchar2(10);

    cursor csr_valid_active_flag(p_active_flg varchar2)
    is
    select 'X'
    from   hr_standard_lookups
    where  lookup_type = 'YES_NO'
    and    lookup_code = p_active_flg;


  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);


    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'active_inactive_flag'
    ,p_argument_value => p_active_flag
    );
    --

    open csr_valid_active_flag(p_active_flag);
    fetch csr_valid_active_flag into l_active_flag;
    if csr_valid_active_flag%notfound then
    close csr_valid_active_flag;
    hr_utility.set_message(800, 'HR_449711_DOR_INVL_COND_VAL');
    hr_utility.set_message_token('OBJECT', 'ACTIVE_FLAG');
    hr_utility.set_message_token('TABLE', 'HR_STANDARD_LOOKUPS');
    hr_utility.set_message_token('CONDITION', 'lookup type "YES_NO"');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 10);
    --
    else
    close csr_valid_active_flag;
    end if;
    hr_utility.set_location(l_proc, 20);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_same_associated_columns =>  'Y'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_active_flag;
--

--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_multiple_occurence_flag >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that multiple_occurences_flag value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_multiple_occurence_flag
--
-- Post Success:
--   Processing continues if category_code is valid and if updating,
--   old_rec.category_code is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_multiple_occurence_flag
  (
   p_multiple_occurence_flag  in  hr_document_types.multiple_occurences_flag%TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_multiple_occurence_flag';
  l_api_updating  boolean;
  l_multiple_occurence_flag varchar2(10);

 -- Cursor for Validating Multiple Occurences Flag

    cursor csr_valid_mul_occurence_flag(p_mul_occ_flag varchar2)
    is
    select 'X'
    from   hr_standard_lookups
    where  lookup_type = 'YES_NO'
    and    lookup_code = p_mul_occ_flag;

  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);


   hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'MULTIPLE_OCCURENCES_FLAG'
    ,p_argument_value => p_multiple_occurence_flag
    );

    --

    open csr_valid_mul_occurence_flag(p_multiple_occurence_flag);
    fetch csr_valid_mul_occurence_flag into l_multiple_occurence_flag;
    if csr_valid_mul_occurence_flag%notfound then
    close csr_valid_mul_occurence_flag;

    hr_utility.set_message(800, 'HR_449711_DOR_INVL_COND_VAL');
    hr_utility.set_message_token('OBJECT', 'MULTIPLE_OCCURENCES_FLAG');
    hr_utility.set_message_token('TABLE', 'HR_STANDARD_LOOKUPS');
    hr_utility.set_message_token('CONDITION', 'lookup type "YES_NO"');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 10);
    --
    else
    close csr_valid_mul_occurence_flag;

    end if;
    hr_utility.set_location(l_proc, 20);
    --

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_same_associated_columns =>  'Y'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_multiple_occurence_flag;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_legislation_code >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that legislation_code value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
-- p_legislation_code
--
-- Post Success:
--   Processing continues if category_code is valid and if updating,
--   old_rec.category_code is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_legislation_code
  (
   p_legislation_code  in  hr_document_types.legislation_code%TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_legislation_code';
  l_api_updating  boolean;
  l_legislation_code varchar2(10);

 -- Cursor for Validating Legislation Code

    cursor csr_valid_leg_code is
    select 'X'
    from   fnd_territories
    where  TERRITORY_CODE = p_legislation_code;

  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);

    --
  if(p_legislation_code is NOT NULL) then
    open csr_valid_leg_code;
    fetch csr_valid_leg_code into l_legislation_code;
    if csr_valid_leg_code%notfound then
    close csr_valid_leg_code;
    hr_utility.set_message(800, 'HR_449710_DOR_INVL_VAL');
    hr_utility.set_message_token('OBJECT', 'LEGISLATION_CODE');
    hr_utility.set_message_token('TABLE', 'FND_TERRITORIES');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 10);
    --
    else
    close csr_valid_leg_code;

    end if;
    end if;
    hr_utility.set_location(l_proc, 20);
    --

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_same_associated_columns =>  'Y'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_authorization_code >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that authorization_code value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_authorization_code
--
-- Post Success:
--   Processing continues if category_code is valid and if updating,
--   old_rec.category_code is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_authorization_required
  (
   p_authorization_required  in  hr_document_types.authorization_required%TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_authorization_code';
  l_api_updating  boolean;
  l_auth_code varchar2(10);

 -- Cursor for Validating Multiple Occurences Flag

    cursor csr_valid_auth_code(p_auth_code varchar2)
    is
    select 'X'
    from   hr_standard_lookups
    where  lookup_type = 'YES_NO'
    and    lookup_code = p_auth_code;

  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);


   hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'AUTHORIZATION_REQUIRED'
    ,p_argument_value => p_authorization_required
    );

    --

    open csr_valid_auth_code(p_authorization_required);
    fetch csr_valid_auth_code into l_auth_code;
    if csr_valid_auth_code%notfound then
    close csr_valid_auth_code;
    hr_utility.set_message(800, 'HR_449711_DOR_INVL_COND_VAL');
    hr_utility.set_message_token('OBJECT', 'AUTHORIZATION_REQUIRED');
    hr_utility.set_message_token('TABLE', 'HR_STANDARD_LOOKUPS');
    hr_utility.set_message_token('CONDITION', 'lookup type "YES_NO"');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 10);
    --
    else
    close csr_valid_auth_code;

    end if;
    hr_utility.set_location(l_proc, 20);
    --

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_same_associated_columns =>  'Y'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_authorization_required;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_document_type_delete >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures an document type can't be deleted if it is referenced by
--   HR_DOCUMENT_EXTRA_INFO
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_authorization_code
--
-- Post Success:
--   Processing continues if category_code is valid and if updating,
--   old_rec.category_code is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_document_type_delete
  (
   p_document_type  in  hr_document_types.document_type_id%TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_document_type_delete';
  l_api_updating  boolean;
  l_doc_type varchar2(10);
  l_document_type varchar2(30);

 -- Cursor for Validating Deletion of Document Type Id
      cursor get_document_type(p_document_type_id number)
      is
      select document_type
      from hr_document_types_v
      where document_type_id=p_document_type_id;


    cursor csr_doc_type_delete
    is
    select 'X'
    from   hr_document_extra_info hdei
    where  hdei.document_type_id = p_document_type;

  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);

    --
    open get_document_type(p_document_type_id =>p_document_type);
    fetch get_document_type into l_document_type;
    close get_document_type;

    open csr_doc_type_delete;
    fetch csr_doc_type_delete into l_doc_type;
    if csr_doc_type_delete%found then
    close csr_doc_type_delete;

    hr_utility.set_message(800, 'HR_449715_DOR_DOC_TYP_DEL_VAL');
    hr_utility.set_message_token('TYPE', l_document_type);
    hr_utility.set_message_token('TABLE', 'HR_DOCUMENT_EXTRA_INFO');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 10);
    --
    else
    close csr_doc_type_delete;

    end if;
    hr_utility.set_location(l_proc, 20);
    --

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_same_associated_columns =>  'Y'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_document_type_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hr_dty_shd.g_rec_type
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
  --
  -- Validate Dependent Attributes
  --
  --
  -- Validate Category Code

  chk_category_code
  (p_category_code    => p_rec.category_code
  ,p_legislation_code => p_rec.legislation_code
  );
  -- Valid Sub Category ID

  chk_sub_category_code
  (p_category_code    => p_rec.category_code
  ,p_sub_category_code => p_rec.sub_category_code
  );
  -- Valid Active Flag

  chk_active_flag
  (p_active_flag => p_rec.active_inactive_flag
  );
  --Valid Multiple Occurences Flag

  chk_multiple_occurence_flag
  (p_multiple_occurence_flag => p_rec.multiple_occurences_flag
  );
  --Valid Legislation Code

  chk_legislation_code
  (
  p_legislation_code => p_rec.legislation_code
  );
  --Valid Authorization Required

  chk_authorization_required
  (
  p_authorization_required => p_rec.authorization_required
  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hr_dty_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date      => p_effective_date
      ,p_rec              => p_rec
    );

  -- Valid Category Code
  chk_category_code
    (p_category_code    => p_rec.category_code
    ,p_legislation_code => p_rec.legislation_code
  );

  --Valid Sub Category code
   chk_sub_category_code
  (p_category_code    => p_rec.category_code
  ,p_sub_category_code => p_rec.sub_category_code
  );
  -- Valid Active Flag
  chk_active_flag
  (p_active_flag => p_rec.active_inactive_flag
  );
  -- Valid Multiple Occurences Flag
  chk_multiple_occurence_flag
  (p_multiple_occurence_flag => p_rec.multiple_occurences_flag
  );
   --Valid Authorization Required
  chk_authorization_required
  (
  p_authorization_required => p_rec.authorization_required
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_dty_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  chk_document_type_delete
  (
   p_document_type => p_rec.document_type_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_dty_bus;


/
