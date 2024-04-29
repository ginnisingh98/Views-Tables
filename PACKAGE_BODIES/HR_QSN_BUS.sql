--------------------------------------------------------
--  DDL for Package Body HR_QSN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSN_BUS" as
/* $Header: hrqsnrhi.pkb 120.4.12010000.3 2008/11/05 09:57:56 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsn_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code     varchar2(150)   default null;
g_questionnaire_template_id   number    default null;
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_questionnaire_template_id  in  number
  ,p_associated_column1         in  varchar2 default null
) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select inf.org_information14
      from hr_organization_information inf
         , hr_questionnaires                qsn
     where qsn.questionnaire_template_id = p_questionnaire_template_id
       and inf.organization_id   = qsn.business_group_id(+)
       and inf.org_information_context || '' = 'Business Group Information';
  -- order by per.effective_start_date;
  --
  -- Local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72) := g_package||'set_security_group_id';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'questionnaire_template_id',
                             p_argument_value => p_questionnaire_template_id);
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
    close csr_sec_grp;
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end set_security_group_id;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_non_updateable_args >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec    in hr_qsn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not hr_qsn_shd.api_updating
    (p_questionnaire_template_id   => p_rec.questionnaire_template_id
    ,p_object_version_number  => p_rec.object_version_number
    ) then
     fnd_message.set_name('PER','HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE',l_proc);
     fnd_message.set_token('STEP',20);
     fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  if nvl(p_rec.name,hr_api.g_varchar2) <> hr_qsn_shd.g_old_rec.name then
     hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'NAME'
      ,p_base_table => hr_qsn_shd.g_tab_nam
      );
  end if;
  hr_utility.set_location(l_proc,40);
  --
  /**
  if nvl(p_rec.text,hr_api.g_varchar2) <> hr_qsn_shd.g_old_rec.text then
     hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'TEXT'
      ,p_base_table => hr_qsn_shd.g_tab_nam
      );
  end if;
  hr_utility.set_location(l_proc,50);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     hr_qsn_shd.g_old_rec.business_group_id then
     hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'BUSINESS_GROUP_ID'
      ,p_base_table => hr_qsn_shd.g_tab_nam
      );
  end if;
  **/
  --
  hr_utility.set_location('Leaving: '|| l_proc,60);
  --
end chk_non_updateable_args;
-- --------------------------------------------------------------------------
-- |------------------------< chk_name >------------------------------------|
-- --------------------------------------------------------------------------
--
Procedure chk_name
  (p_name     in   hr_questionnaires.name%TYPE
  ,p_business_group_id   in  hr_questionnaires.name%TYPE
  )
  is
  --
  l_proc  varchar2(72) := g_package || 'chk_name';
  l_exists  varchar2(1);
  --
  -- Cursor to check that name is unique.
  --
  cursor csr_unique_name is
    select null
    from hr_questionnaires
    where name = p_name
    and ((p_business_group_id is null and business_group_id is null)
    or business_group_id = p_business_group_id);
  --
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_name is not null then
     -- Check that name is unique
     open csr_unique_name;
     fetch csr_unique_name into l_exists;
     if csr_unique_name%FOUND then
  -- Name is not unique - raise error by calling constraint error
  close csr_unique_name;
  hr_qsn_shd.constraint_error('HR_QUESTIONNAIRES_UK1');
     end if;
     close csr_unique_name;
  else
     -- Name is null - raise error
     fnd_message.set_name('PER','PER_52412_QSN_MAND_NAME');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving: '||l_proc, 50);
  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'HR_QUESTIONNAIRES.NAME'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_name;
--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_text >---------------------------------|
-- ---------------------------------------------------------------------------
--
Procedure chk_text
(p_text     in   hr_questionnaires.text%TYPE
)
is
  --
  c_max_size CONSTANT number := 27648;
  l_proc    varchar2(72) := g_package || 'chk_text';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_text is not null then
     -- Check the size of the text is less than max size
  --   if Length(p_text) > c_max_size then
  -- greater then max, so raise error
  -- fnd_message.set_name('PER','PER_52414_QSN_TEXT_OVERSIZED');
  -- fnd_message.raise_error;
  --   end if;
     null;
  else
     -- Text is mandatory, thus error
     fnd_message.set_name('PER','PER_52413_QSN_MAND_TEXT');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);
  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'HR_QUESTIONNAIRES.TEXT'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);

  --
end chk_text;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_available_flag >-----------------------------|
-- ---------------------------------------------------------------------------
--
Procedure chk_available_flag
  (p_available_flag  in hr_questionnaires.available_flag%TYPE
  ,p_effective_date   in date
  ,p_questionnaire_template_id in hr_questionnaires.questionnaire_template_id%TYPE
  ,p_object_version_number in hr_questionnaires.object_version_number%TYPE
  )
  is
  --
  l_proc  varchar2(72) := g_package ||'chk_available_flag';
  l_api_updating boolean;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  l_api_updating := hr_qsn_shd.api_updating
  (p_questionnaire_template_id => p_questionnaire_template_id
  ,p_object_version_number     => p_object_version_number);
  hr_utility.set_location(l_proc,20);
  --
  if l_api_updating AND
     (hr_qsn_shd.g_old_rec.available_flag
                        <> nvl(p_available_flag,hr_api.g_varchar2)) then
  -- During update, and available_flag has changed
  --
     if hr_api.not_exists_in_hr_lookups
    (p_effective_date => p_effective_date
    ,p_lookup_type => 'YES_NO'
    ,p_lookup_code => p_available_flag
    ) then
  -- Invalid lookup, raise error
  hr_qsn_shd.constraint_error('HR_QUEST_AVAILABLE_FLAG_CHK');
     end if;
  -- We are allowing users in V4 SSHR to publish the questionnaire
  -- during the process of creation itself. hence foll. check is not required
  /* elsif not l_api_updating then
  -- INSERT - validate that flag is 'N'
     if nvl(p_available_flag,hr_api.g_varchar2) <> 'N' then
  fnd_message.set_name('PER','PER_52415_QSN_INVAL_FLG_ON_INS');
  fnd_message.raise_error;
     end if; */
  else
    -- UPDATE and not changed - no need to validate
    null;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);
  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'HR_QUESTIONNAIRES.AVAILABLE_FLAG'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_available_flag;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_row_delete >-------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_row_delete
  (p_questionnaire_template_id in hr_questionnaires.questionnaire_template_id%TYPE)
  is
  --
  l_proc   varchar2(72) := g_package || 'chk_row_delete';
  l_exists  varchar2(1);
  --
  -- Cursor to check whether a child row exists in HR_QUEST_FIELDS
  --
  cursor csr_chk_child_row is
    select null
      from hr_quest_fields qsf
     where qsf.questionnaire_template_id = p_questionnaire_template_id;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'questionnaire_template_id'
    ,p_argument_value   => p_questionnaire_template_id
    );
  -- determine if a child row exists
  open csr_chk_child_row;
  fetch csr_chk_child_row into l_exists;
  if csr_chk_child_row%FOUND then
     -- Raise error, as child row exists
     close csr_chk_child_row;
     fnd_message.set_name('PER','PER_52442_QSA_CHILD_EXISTS');
     fnd_message.raise_error;
  end if;
  close csr_chk_child_row;
  --
  hr_utility.set_location('Leaving: '||l_proc, 20);
  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'HR_QUESTIONNAIRES.AVAILABLE_FLAG'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 30);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end chk_row_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_qsn_shd.g_rec_type
       ,p_effective_date in date
       ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  if p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id
    (p_rec.business_group_id
    ,p_associated_column1 => hr_qsn_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  end if;
  chk_name(p_name     => p_rec.name
    ,p_business_group_id   => p_rec.business_group_id
    );
  chk_available_flag(p_available_flag  => p_rec.available_flag
        ,p_effective_date  => p_effective_date
        ,p_questionnaire_template_id
          => p_rec.questionnaire_template_id
        ,p_object_version_number
          => p_rec.object_version_number
        );

  chk_text(p_text  => p_rec.text);

  hr_multi_message.end_validation_set;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_qsn_shd.g_rec_type
       ,p_effective_date in date
       ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => hr_qsn_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  end if;
  hr_multi_message.end_validation_set;

  chk_non_updateable_args(p_rec);

  chk_available_flag(p_rec.available_flag
        ,p_effective_date
        ,p_rec.questionnaire_template_id
        ,p_rec.object_version_number
        );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_qsn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_row_delete(p_questionnaire_template_id => p_rec.questionnaire_template_id);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------< return_legislation_code >---------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
   (p_questionnaire_template_id in hr_questionnaires.questionnaire_template_id%TYPE
   ) return varchar2 is
   --
   -- Cursor to find legislation code
   --
   cursor csr_leg_code is
     select pbg.legislation_code
       from per_business_groups pbg
    , hr_questionnaires qsn
      where qsn.questionnaire_template_id = p_questionnaire_template_id
  and pbg.business_group_id = qsn.business_group_id;
   --
   -- Declare local variables
   --
   l_legislation_code  varchar2(150);
   l_proc    varchar2(72) := 'return_legislation_code';
begin
  hr_utility.set_location('Entering: '||l_proc, 10);
  hr_api.mandatory_arg_error(p_api_name    => l_proc
          ,p_argument    => 'questionnaire_template_id'
          ,p_argument_value  => p_questionnaire_template_id
          );
  if nvl(g_questionnaire_template_id, hr_api.g_number)
     = p_questionnaire_template_id then
     --
     -- The legislation code has already been found with a previous
     -- call to this function.  Just return the value in the global
     -- variable.
     --
     l_legislation_code := g_legislation_code;
     hr_utility.set_location(l_proc,20);
  else
     --
     -- The ID is different to the last call to this function
     -- or this is the first call to this function.
     --
     open csr_leg_code;
     fetch csr_leg_code into l_legislation_code;
     if csr_leg_code%notfound then
       --
       -- The primary key is invalid therefore we must error
       --
       close csr_leg_code;
       fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
       fnd_message.raise_error;
     end if;
     hr_utility.set_location(l_proc, 30);
     --
     -- Set the global variables so the values are
     -- available for the next call to this function
     --
     close csr_leg_code;
     g_questionnaire_template_id := p_questionnaire_template_id;
     g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving: '||l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
end hr_qsn_bus;

/
