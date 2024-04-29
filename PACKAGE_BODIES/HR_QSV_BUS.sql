--------------------------------------------------------
--  DDL for Package Body HR_QSV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSV_BUS" as
/* $Header: hrqsvrhi.pkb 115.9 2003/08/27 00:17:34 hpandya ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsv_bus.';  -- Global package name
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_legislation_code  varchar2(150)  default null;
g_quest_answer_val_id  number    default null;
g_questionnaire_template_id hr_quest_fields.questionnaire_template_id%TYPE;
--

-- ----------------------------------------------------------------------------
-- |------------------------< chk_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args
  (p_rec   in   hr_qsv_shd.g_rec_type
  )
  is
  --
  l_proc   varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error  exception;
  l_argument    varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Only proceed with validation if a row exists for the
  -- current record in the HR Schema.
  --
  if not hr_qsv_shd.api_updating
    (p_quest_answer_val_id    => p_rec.quest_answer_val_id
    ,p_object_version_number => p_rec.object_version_number
    ) then
     fnd_message.set_name('PER','HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE',l_proc);
     fnd_message.set_token('STEP',20);
     fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.questionnaire_answer_id, hr_api.g_number)
      <> hr_qsv_shd.g_old_rec.questionnaire_answer_id then
     l_argument := 'questionnaire_answer_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 40);
  --
  if nvl(p_rec.field_id, hr_api.g_number) <> hr_qsv_shd.g_old_rec.field_id then
     l_argument := 'field_id';
     raise l_error;
  end if;
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
exception
    when l_error then
       hr_api.argument_changed_error
   (p_api_name => l_proc
   ,p_argument => l_argument
   );
    when others then
       raise;
  --
end chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_questionnaire_answer_id >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_questionnaire_answer_id
  (p_questionnaire_answer_id
       in hr_quest_answer_values.questionnaire_answer_id%TYPE
  )
  is
  --
  l_proc   varchar2(72) := g_package || 'chk_questionnaire_answer_id';
  l_exists  varchar2(1);
  --
  -- Cursor to check if questionnaire_answer_id exists
  --
  cursor csr_id_exists is
    select qsa.questionnaire_template_id
      from hr_quest_answers qsa
     where qsa.questionnaire_answer_id = p_questionnaire_answer_id;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_questionnaire_answer_id is null then
     -- error, as this cannot be null
     fnd_message.set_name('PER','PER_52446_QSV_MAND_ANS_ID');
     fnd_message.raise_error;
  else
     -- Check that id exists in HR_QUEST_ANSWERS table
     open csr_id_exists;
     -- Fetch questionnaire_template_id for later use.
     fetch csr_id_exists into g_questionnaire_template_id;
     if csr_id_exists%NOTFOUND then
  -- id doent exist, so error.
  close csr_id_exists;
  hr_qsv_shd.constraint_error('HR_QUEST_ANSWER_VALUES_FK1');
     end if;
     close csr_id_exists;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end chk_questionnaire_answer_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_field_id >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_field_id
  (p_field_id   in  hr_quest_answer_values.field_id%TYPE
  ,p_questionnaire_answer_id
    in   hr_quest_answer_values.questionnaire_answer_id%TYPE
  )
  is
  --
  l_proc  varchar2(72) := g_package || 'chk_field_id';
  l_exists      varchar2(1);
  l_qsa_qu_temp_id  hr_quest_answers.questionnaire_template_id%TYPE;
  l_questionnaire_template_id  hr_quest_fields.questionnaire_template_id%TYPE;
  --
  -- Cursor to check that field_id exists in HR_QUEST_FIELDS
  --
  cursor csr_id_exists is
    select qsf.questionnaire_template_id
      from hr_quest_fields qsf
     where qsf.field_id = p_field_id;
  --
  -- Cursor to determine if id is unique for the given questionnaire_answer_id
  --
  cursor csr_chk_unique is
    select null
      from hr_quest_answer_values qsv
     where qsv.questionnaire_answer_id = p_questionnaire_answer_id
       and qsv.field_id = p_field_id;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if p_field_id is null then
     -- Error, as this is mandatory
     fnd_message.set_name('PER','PER_52447_QSV_MAND_FIELD_ID');
     fnd_message.raise_error;
  else
     -- determine if id exists in HR_QUEST_FIELDS
     open csr_id_exists;
     fetch csr_id_exists into l_questionnaire_template_id;
     if csr_id_exists%NOTFOUND then
  -- Id does not exist, so error.
  close csr_id_exists;
  hr_qsv_shd.constraint_error('HR_QUEST_ANSWER_VALUES_FK2');
     end if;
     close csr_id_exists;
     --
     hr_utility.set_location(l_proc,20);
     --
     -- Check that field_id is unique for the given questionnaire_answer_id
     --
     open csr_chk_unique;
     fetch csr_chk_unique into l_exists;
     if csr_chk_unique%FOUND then
  -- field_id is not unique, so error
  close csr_chk_unique;
  hr_qsv_shd.constraint_error('HR_QUEST_ANSWER_VALUES_UK1');
     end if;
     close csr_chk_unique;
     --
     hr_utility.set_location(l_proc,30);
     --
     -- Check that qsf.questionnaire_template_id is the same as
     --   qsa.questionnaire_template_id.
     --
     if l_questionnaire_template_id <> g_questionnaire_template_id then
  -- field is not a part of the questionnaire being answered.
  fnd_message.set_name('PER','PER_52448_QSV_INVAL_FIELD_ID');
  fnd_message.raise_error;
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end chk_field_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete_allowed >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_delete_allowed
  (p_value in hr_quest_answer_values.value%TYPE
  )
  is
  --
  l_proc   varchar2(72) := g_package || 'chk_delete_allowed';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
 -- Deleted check on p_value to see if it is not null and raise
 -- error PER_52449_QSV_ANSWER_NOT_NULL, as this is required
 -- for appraisal deletion using API, to clean up appraisals.
 -- Bug 3104804.
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end chk_delete_allowed;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_qsv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Set the business group id
  --
  hr_qsa_bus.set_security_group_id
    (p_questionnaire_answer_id=> p_rec.questionnaire_answer_id);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Reset global g_questionnaire_template_id
  --
  g_questionnaire_template_id := null;
  --
  -- Call all supporting business operations
  --
  chk_questionnaire_answer_id
    (p_questionnaire_answer_id   => p_rec.questionnaire_answer_id);
  --
  chk_field_id
    (p_field_id   =>  p_rec.field_id
    ,p_questionnaire_answer_id  => p_rec.questionnaire_answer_id
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_qsv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Set the business group id
  --
  hr_qsa_bus.set_security_group_id
    (p_questionnaire_answer_id=> p_rec.questionnaire_answer_id);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Reset global g_questionnaire_template_id to null
  --
  g_questionnaire_template_id := null;
  --
  -- Call all supporting business operations
  --
  hr_qsv_bus.chk_non_updateable_args(p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_qsv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete_allowed
    (p_value =>  hr_qsv_shd.g_old_rec.value);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_legislation_code >--------------------------|
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_quest_answer_val_id in hr_quest_answer_values.quest_answer_val_id%TYPE
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
   , hr_quest_answers qsa
   , hr_quest_answer_values qsv
     where p_quest_answer_val_id = qsv.quest_answer_val_id
       and qsv.questionnaire_answer_id = qsa.questionnaire_answer_id
       and qsa.business_group_id = pbg.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc    varchar2(72) := 'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  hr_api.mandatory_arg_error(p_api_name    => l_proc
          ,p_argument   => 'quest_answer_val_id'
          ,p_argument_value  => p_quest_answer_val_id
          );
  if nvl(g_quest_answer_val_id, hr_api.g_number)
     = p_quest_answer_val_id then
     --
     -- The legislation code has already been found with a previous call
     -- to this function.  Just return the value in the global variable.
     --
     l_legislation_code := g_legislation_code;
     hr_utility.set_location(l_proc,20);
  else
     --
     -- The ID is different to the last call to this function, or this
     -- is the first call to this function.
     --
     open csr_leg_code;
     fetch csr_leg_code into l_legislation_code;
     if csr_leg_code%NOTFOUND then
  --
  -- The primary key is invalid therefore we must error
  --
  close csr_leg_code;
  fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
  fnd_message.raise_error;
     end if;
     hr_utility.set_location(l_proc,30);
     --
     -- Set the global variables so the values are available for the
     -- next call to this function.
     --
     close csr_leg_code;
     g_quest_answer_val_id := p_quest_answer_val_id;
     g_legislation_code    := l_legislation_code;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end hr_qsv_bus;

/
