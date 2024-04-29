--------------------------------------------------------
--  DDL for Package Body HR_QSF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSF_BUS" as
/* $Header: hrqsfrhi.pkb 115.11 2003/08/27 00:16:45 hpandya ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsf_bus.';  -- Global package name
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_legislation_code  varchar2(150)  default null;
g_field_id    number    default null;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec      in hr_qsf_shd.g_rec_type
  ,p_effective_date    in date
  )
  is
  --
  l_proc  varchar2(72) := g_package || 'chk_non_updateable_args';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema
  --
  if not hr_qsf_shd.api_updating
      (p_field_id  => p_rec.field_id
      ,p_object_version_number   => p_rec.object_version_number
      ) then
     fnd_message.set_name('PER','HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE',l_proc);
     fnd_message.set_token('STEP','20');
     fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  if nvl(p_rec.questionnaire_template_id,hr_api.g_number) <>
     hr_qsf_shd.g_old_rec.questionnaire_template_id then

     hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'QUESTIONNAIRE_TEMPLATE_ID'
	      ,p_base_table => hr_qsf_shd.g_tab_nam
	      );
  end if;
  hr_utility.set_location(l_proc,40);
  --
  if nvl(p_rec.name,hr_api.g_varchar2) <> hr_qsf_shd.g_old_rec.name then

     hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'NAME'
	      ,p_base_table => hr_qsf_shd.g_tab_nam
	      );
  end if;
  hr_utility.set_location(l_proc,50);
  --
  if nvl(p_rec.type,hr_api.g_varchar2) <> hr_qsf_shd.g_old_rec.type then

     hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'TYPE'
	      ,p_base_table => hr_qsf_shd.g_tab_nam
	      );
  end if;
  hr_utility.set_location(l_proc,60);
  --
  if nvl(p_rec.html_text,hr_api.g_varchar2)
      <> hr_qsf_shd.g_old_rec.html_text then

     hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'HTML_TEXT'
	      ,p_base_table => hr_qsf_shd.g_tab_nam
	      );
  end if;
  hr_utility.set_location(l_proc,70);
  --
  if nvl(p_rec.sql_required_flag,hr_api.g_varchar2)
      <> hr_qsf_shd.g_old_rec.sql_required_flag then

     hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'SQL_REQUIRED_FLAG'
	      ,p_base_table => hr_qsf_shd.g_tab_nam
	      );
  end if;
  hr_utility.set_location('Leaving: '||l_proc,80);
  --
end chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_questionnaire_template_id >----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_questionnaire_template_id
   (p_questionnaire_template_id
       in hr_quest_fields.questionnaire_template_id%TYPE
   )
   is
   --
   l_proc  varchar2(72) := g_package || 'chk_questionnaire_template_id';
   l_exists  varchar2(1);
   --
   -- Cursor to check that questionnaire_template_id exists
   --
   cursor csr_id_exists is
     select null
     from hr_questionnaires
     where questionnaire_template_id = p_questionnaire_template_id;
   --
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_questionnaire_template_id is not null then
     -- check that it exists
     open csr_id_exists;
     fetch csr_id_exists into l_exists;
     if csr_id_exists%notfound then
  -- Questionnaire template id not found - raise error
  close csr_id_exists;
  hr_qsf_shd.constraint_error('HR_QUEST_FIELDS_FK');
     end if;
     close csr_id_exists;
  else
     -- Questionnaire template id is null - raise error
     fnd_message.set_name('PER','PER_52419_QSF_MAND_TEMPLATE_ID');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);

  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'HR_QUEST_FIELDS.QUESTIONNAIRE_TEMPLATE_ID'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_questionnaire_template_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_name >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_name
  (p_name   in  hr_quest_fields.name%TYPE
  )
  is
  --
  l_proc  varchar2(72) := g_package || 'chk_name';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_name is null then
     -- Raise error, since name is a mandatory column.
     fnd_message.set_name('PER','PER_52423_QSF_MAND_NAME');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);

  exception when app_exception.application_exception then
	if hr_multi_message.exception_add
	         (p_associated_column1      => 'HR_QUEST_FIELDS.NAME'
	         ) then
	      hr_utility.set_location(' Leaving:'|| l_proc, 30);
	      raise;
	    end if;
	    hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end chk_name;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_type >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_type
  (p_type  in   hr_quest_fields.type%TYPE
  ,p_effective_date  in  date
  ) is
  --
  l_proc  varchar2(72) := g_package || 'chk_type';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_type is not null then
    -- Check that p_type exists in lookup
    if hr_api.not_exists_in_hr_lookups
    (p_effective_date => p_effective_date
    ,p_lookup_type    => 'QUEST_FIELD_TYPE'
    ,p_lookup_code    => p_type
    ) then
       -- p_type does not exist in lookup
       hr_qsf_shd.constraint_error('HR_QUEST_FIELDS_TYPE_CHK');
     end if;
  else
    -- p_type is null
    fnd_message.set_name('PER','PER_52426_QSF_MAND_TYPE');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);

  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'HR_QUEST_FIELDS.TYPE'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 30);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end chk_type;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_html_text >----------------------------------|
-- ---------------------------------------------------------------------------
--
Procedure chk_html_text
  (p_html_text   in  hr_quest_fields.html_text%TYPE
  )
  is
  --
  c_max_size CONSTANT number := 27648;
  l_proc  varchar2(72) := g_package || 'chk_html_text';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_html_text is not null then
     -- Check that the size of the text is less than max_size
     -- if Length(p_html_text) > c_max_size then
     -- Greater than max, so error
     -- fnd_message.set_name('PER','PER_52420_QSF_HTML_TXT_OVRSZD');
     -- fnd_message.raise_error;
     -- end if;
     null;
  else
     -- html_text is null
     fnd_message.set_name('PER','PER_52421_QSF_MAND_HTML_TEXT');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);

  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'HR_QUEST_FIELDS.HTML_TEXT'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 30);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end chk_html_text;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_sql_required_flag >--------------------------|
-- ---------------------------------------------------------------------------
--
Procedure chk_sql_required_flag
  (p_sql_required_flag  in   hr_quest_fields.sql_required_flag%TYPE
  ,p_effective_date  in   date
  ) is
  --
  l_proc  varchar2(72) := g_package || 'chk_sql_required_flag';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_sql_required_flag is not null then
     -- Check that it exists in HR_LOOKUPS
     if hr_api.not_exists_in_hr_lookups
   (p_effective_date => p_effective_date
   ,p_lookup_type     => 'YES_NO'
   ,p_lookup_code    => p_sql_required_flag
   ) then
        -- Doesnt exist in lookups, so error
  hr_qsf_shd.constraint_error('HR_QUEST_FIELDS_SQL_FLAG_CHK');
      end if;
  else
    -- p_sql_required flag is null, yet is a mandatory column
    fnd_message.set_name('PER','PER_52422_QSF_MAND_REQD_FLAG');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);

  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'HR_QUEST_FIELDS.SQL_REQUIRED_FLAG'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 30);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end chk_sql_required_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_qsf_shd.g_rec_type,
        p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_qsn_bus.set_security_group_id
   (p_questionnaire_template_id => p_rec.questionnaire_template_id);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  -- Call all supporting business operations
  --
  chk_questionnaire_template_id(p_rec.questionnaire_template_id);
  chk_name(p_rec.name);
  chk_type(p_rec.type, p_effective_date);
  chk_sql_required_flag(p_rec.sql_required_flag, p_effective_date);
  chk_html_text(p_rec.html_text);

  hr_multi_message.end_validation_set;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_qsf_shd.g_rec_type
       ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_qsn_bus.set_security_group_id
   (p_questionnaire_template_id => p_rec.questionnaire_template_id
   ,p_associated_column1 => hr_qsn_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
   );

  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  -- Call all supporting business operations
  --
  chk_non_updateable_args
    (p_rec => p_rec
    ,p_effective_date => p_effective_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_qsf_shd.g_rec_type) is
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
-- ----------------------------------------------------------------------------
-- |--------------------< return_legislation_code >---------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
  (p_field_id in hr_quest_fields.field_id%TYPE
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
    from per_business_groups pbg
       , hr_questionnaires qsn
       , hr_quest_fields qsf
    where qsf.field_id = p_field_id
      and qsn.questionnaire_template_id = qsf.questionnaire_template_id
      and qsn.business_group_id = pbg.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code    varchar2(150);
  l_proc    varchar2(72) := 'return_legislation_code';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  hr_api.mandatory_arg_error(p_api_name  => l_proc
          ,p_argument => 'field_id'
          ,p_argument_value => p_field_id
          );
  if nvl(g_field_id, hr_api.g_number) = p_field_id then
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
  -- The primary key is invalid, therefore we must error
  --
  close csr_leg_code;
  fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
  fnd_message.raise_error;
     end if;
     hr_utility.set_location(l_proc,30);
     --
     -- Set the global variables so the values are available
     -- for the next call to this function.
     --
     close csr_leg_code;
     g_field_id := p_field_id;
     g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving: '||l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end hr_qsf_bus;

/
