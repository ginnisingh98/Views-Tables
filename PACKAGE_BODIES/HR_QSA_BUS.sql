--------------------------------------------------------
--  DDL for Package Body HR_QSA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSA_BUS" as
/* $Header: hrqsarhi.pkb 115.12 2003/08/27 00:16:05 hpandya ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsa_bus.';  -- Global package name
--
--  The following two global variables are only to be used by the
--  return_legislation_code function.
--
g_legislation_code    varchar2(150)   default null;
g_questionnaire_answer_id  number    default null;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_security_group_id
(p_questionnaire_answer_id  in  hr_quest_answers.questionnaire_answer_id%TYPE
) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select inf.org_information14
      from hr_organization_information inf
         , hr_quest_answers                qsa
     where qsa.questionnaire_answer_id = p_questionnaire_answer_id
       and inf.organization_id   = qsa.business_group_id
       and inf.org_information_context || '' = 'Business Group Information';
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
                             p_argument       => 'questionnaire_answer_id',
                             p_argument_value => p_questionnaire_answer_id);
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  if csr_sec_grp%notfound then
    close csr_sec_grp;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message('PER', 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end set_security_group_id;
-- ----------------------------------------------------------------------------
-- |-------------------< chk_questionnaire_template_id >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that the questionnaire_template_id exists in HR_QUESTIONNAIRES.
--   Also, validates that the questionnaire_template_id is valid against the
--   PER_APPRAISAL_TEMPLATES table, when type = 'APPRAISAL', or valid against
--   the PER_APPRAISALS table when type = 'PARTICIPANT'.
--
-- Pre-requisites:
--   p_type, p_type_object_id and p_business_group_id are all valid.
--
-- IN Parameters:
--   p_questionnaire_template_id
--   p_type
--   p_type_object_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues if questionnaire_template_id is valid.
--
-- Post Failure:
--   An application error is raised, and processing is terminated if the
--   questionniare_template_id is invalid.
--
-- Developer/Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_questionnaire_template_id
  (p_questionnaire_template_id    in
  HR_QUEST_ANSWERS.questionnaire_template_id%TYPE
  ,p_type        in
  HR_QUEST_ANSWERS.type%TYPE
  ,p_type_object_id      in
  HR_QUEST_ANSWERS.type_object_id%TYPE
  ,p_business_group_id      in
  HR_QUEST_ANSWERS.business_group_id%TYPE
  )
  is
  --
  l_proc   varchar2(72) := 'chk_questionnaire_template_id';
  l_exists  varchar2(1);
  l_bus_grp_id  HR_QUEST_ANSWERS.business_group_id%TYPE;
  --
  -- Cursor to determins if questionnaire_template_id exists in
  -- HR_QUESTIONNAIRES.
  --
  cursor csr_id_exists is
    select business_group_id
      from hr_questionnaires qsn
     where qsn.questionnaire_template_id = p_questionnaire_template_id;
  --
  -- Cursor to determine if questionnaire_template_id is valid when
  -- the type = 'APPRAISAL'
  --
  cursor csr_appraisal_valid is
    select null
      from per_appraisal_templates pat,
     per_appraisals pa
     where p_questionnaire_template_id = pat.questionnaire_template_id
       and p_type_object_id = pa.appraisal_id
       and pa.appraisal_template_id = pat.appraisal_template_id;
  --
  --

  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  if p_questionnaire_template_id is null then
     -- Item is a mandatory parameter, thus error.
     fnd_message.set_name('PER','PER_52430_QSA_MAND_TEMPLATE');
     fnd_message.raise_error;
  else
     hr_utility.set_location(l_proc,20);
     --
     -- Check item exists in hr_questionnaires.
     open csr_id_exists;
     fetch csr_id_exists into l_bus_grp_id;
     if csr_id_exists%NOTFOUND then
  -- questionnaire_template_id doesnt exist in hr_questionnaires
  close csr_id_exists;
  hr_qsa_shd.constraint_error('HR_QUEST_ANSWERS_FK1');
     end if;
     close csr_id_exists;
     --
     hr_utility.set_location(l_proc,30);
     --
     if p_type = 'APPRAISAL' then
  -- Check that questionnaire_template_id is valid against
  -- PER_APPRAISAL_TEMPLATES
  open csr_appraisal_valid;
  fetch csr_appraisal_valid into l_exists;
  if csr_appraisal_valid%NOTFOUND then
     -- Invalid questionnaire_template_id, according to
     -- per_appraisal_templates and per_appraisals.
     close csr_appraisal_valid;
     fnd_message.set_name('PER','PER_52431_QSA_INVAL_TEMP_ID');
     fnd_message.raise_error;
  end if;
  close csr_appraisal_valid;
  --
  hr_utility.set_location(l_proc,40);
  --
     elsif p_type = 'PARTICIPANT' then
  --
  hr_utility.set_location(l_proc,50);
  --
  --
  hr_utility.set_location(l_proc,60);
  --
     else
  -- currently no other types, so do nothing.
  null;
     end if;
     -- rbanda
     -- disabling this check as Participants from different BG's
     -- will be taking part in the Appraisal process and when they
     -- answer Questionnaire the BGId will be the Participants BGId
     -- but the Questionnaire Template will be from Appraisals BG
     --
     -- Check that business group = questionnaire templates business group.
     /*
     if l_bus_grp_id <> p_business_group_id then
        -- Invalid business group
  fnd_message.set_name('PER','PER_52440_QSA_TEMPLT_NOT_IN_BG');
  fnd_message.raise_error;
     end if;
     */
     --
     hr_utility.set_location(l_proc,70);
     --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,80);
  --
end chk_questionnaire_template_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_type >------------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_type
  (p_type in HR_QUEST_ANSWERS.TYPE%TYPE
  ,p_effective_date in date
  )
  is
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
        ,p_lookup_type    => 'QUEST_OBJECT_TYPE'
        ,p_lookup_code    => p_type
        ) then
       -- p_type does not exist in lookup
       hr_qsa_shd.constraint_error('HR_QUEST_ANS_TYPE_CHK');
    end if;
  else
    -- p_type is null
    fnd_message.set_name('PER','PER_52432_QSA_MAND_TYPE');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end chk_type;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_type_object_id >------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_type_object_id
  (p_type_object_id   in HR_QUEST_ANSWERS.type_object_id%TYPE
  ,p_type    in HR_QUEST_ANSWERS.type%TYPE
  ,p_business_group_id  in HR_QUEST_ANSWERS.business_group_id%TYPE
  )
  is
  --
  l_proc  varchar2(72):= g_package || 'chk_type_object_id';
  l_bus_grp_id  HR_QUEST_ANSWERS.business_group_id%TYPE;
  l_part_in_tab PER_PARTICIPANTS.participation_in_table%TYPE;
  l_part_in_col PER_PARTICIPANTS.participation_in_column%TYPE;
  l_exists   varchar2(1);
  lv_cross_business_group VARCHAR2(10); -- bug 1980440 fix
  --
  -- Cursor to determine if type_object_id is valid when
  -- type = 'APPRAISAL'
  --
  cursor csr_type_appraisal is
     select business_group_id
       from per_appraisals pa
      where p_type_object_id = pa.appraisal_id;
  --
  -- Cursor to determine if type_object_id is valid when
  -- type = 'PARTICIPANT'
  --
  cursor csr_type_participant is
     select business_group_id, participation_in_table, participation_in_column
       from per_participants pp
      where p_type_object_id = pp.participant_id;
  --
  -- Cursor to check that type_object_id is unique
  -- for the given type.
  --
  cursor csr_unique_id is
    select null
      from hr_quest_answers qsa
     where qsa.type_object_id = p_type_object_id
       and qsa.type = p_type;
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  if p_type_object_id is null then
    -- type_object_id is mandatory, thus raise error.
    fnd_message.set_name('PER','PER_52433_QSA_MAND_OBJECT_ID');
    fnd_message.raise_error;
  else
    -- Check that type_object_id is unique.
    open csr_unique_id;
    fetch csr_unique_id into l_exists;
    if csr_unique_id%FOUND then
       close csr_unique_id;
       hr_qsa_shd.constraint_error('HR_QUEST_ANSWERS_UK1');
    end if;
    close csr_unique_id;
    --
    hr_utility.set_location(l_proc,20);
    --
    if p_type = 'APPRAISAL' then
       --
       hr_utility.set_location(l_proc,30);
       --
       -- Check type_object_id for APPRAISAL
       open csr_type_appraisal;
       fetch csr_type_appraisal into l_bus_grp_id;
       if csr_type_appraisal%NOTFOUND then
    -- type_object_id doesnt exist as an appraisal_id
    close csr_type_appraisal;
    fnd_message.set_name('PER','PER_52434_QSA_INVAL_TYPE_OBJ');
    fnd_message.raise_error;
       else
   --
   hr_utility.set_location(l_proc,40);
   --
   close csr_type_appraisal;
   if l_bus_grp_id <> p_business_group_id then
      -- Appraisal doesnt exist in the given business group
      fnd_message.set_name('PER','PER_52435_QSA_OBJ_NOT_IN_BG');
      fnd_message.raise_error;
         end if;
       end if;
    elsif p_type = 'PARTICIPANT' then
       --
       hr_utility.set_location(l_proc,50);
       --
       lv_cross_business_group := fnd_profile.value('HR_CROSS_BUSINESS_GROUP'); -- bug 1980440 fix
       -- Check type_object_id for PARTICIPANT
       open csr_type_participant;
       fetch csr_type_participant
    into l_bus_grp_id, l_part_in_tab, l_part_in_col;
       if csr_type_participant%NOTFOUND then
    -- type object_id doesnt exist as a participant_id
            close csr_type_participant;
            fnd_message.set_name('PER','PER_52436_QSA_OBJ_ID_INVALID');
            fnd_message.raise_error;
       else
            close csr_type_participant;
    --
        hr_utility.set_location(l_proc,60);
    -- bug 1980440 fix starts
        if lv_cross_business_group <> 'Y' THEN
            if l_bus_grp_id <> p_business_group_id then
                -- Participant doesnt exist in the given business group
                fnd_message.set_name('PER','PER_52437_QSA_OBJ_NOT_IN_BG');
                fnd_message.raise_error;
            end if;
         end if;
    -- bug 1980440 fix ends
    --
    hr_utility.set_location(l_proc,70);
    --
    if (l_part_in_tab <> 'PER_APPRAISALS') and
       (l_part_in_col <> 'APPRAISAL_ID') then
       -- Invalid combination, raise error.
       fnd_message.set_name('PER','PER_52438_QSA_OBJ_NOT_IN_APR');
       fnd_message.raise_error;
          end if;
      end if;
    else
        --
  hr_utility.set_location(l_proc,80);
  --
  fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
  fnd_message.set_token('PROCEDURE',l_proc);
  fnd_message.set_token('STEP','80');
  fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,90);
  end if;
  --
end chk_type_object_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_row_delete >-------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_row_delete
  (p_questionnaire_answer_id
    in  hr_quest_answers.questionnaire_answer_id%TYPE
  )
  is
  --
  l_proc   varchar2(72) := g_package || 'chk_row_delete';
  l_exists  varchar2(1);
  --
  -- Cursor to check whether a child row exists in HR_QUEST_ANSWER_VALUES
  --
  cursor csr_chk_child_row is
    select null
      from hr_quest_answer_values qsv
     where qsv.questionnaire_answer_id = p_questionnaire_answer_id;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'questionnaire_answer_id'
    ,p_argument_value   => p_questionnaire_answer_id
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
  --
end chk_row_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_qsa_shd.g_rec_type
       ,p_effective_date in date
       ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_type(p_type    => p_rec.type
    ,p_effective_date   => p_effective_date
    );
  --
  chk_type_object_id(p_type_object_id    => p_rec.type_object_id
        ,p_type      => p_rec.type
        ,p_business_group_id  => p_rec.business_group_id
        );
  --
  chk_questionnaire_template_id
    (p_questionnaire_template_id  => p_rec.questionnaire_template_id
    ,p_type        => p_rec.type
    ,p_type_object_id      => p_rec.type_object_id
    ,p_business_group_id    => p_rec.business_group_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_qsa_shd.g_rec_type
       ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_qsa_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_row_delete(p_questionnaire_answer_id
      => p_rec.questionnaire_answer_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------< return_legislation_code >---------------------------|
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_questionnaire_answer_id in hr_quest_answers.questionnaire_answer_id%TYPE
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , hr_quest_answers qsa
     where qsa.questionnaire_answer_id = p_questionnaire_answer_id
       and pbg.business_group_id = qsa.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc    varchar2(72) := 'return_legislation_code';
begin
  hr_utility.set_location('Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error(p_api_name    => l_proc
          ,p_argument   => 'questionnaire_answer_id'
          ,p_argument_value  => p_questionnaire_answer_id
          );
  --
  if nvl(g_questionnaire_answer_id, hr_api.g_number)
  = p_questionnaire_answer_id then
     --
     -- The legislation code has already been found with a previous call
     -- to this function  Just return the value in the global variable.
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
     -- Set the global variable so the values are available for the
     -- next call to this function.
     --
     close csr_leg_code;
     g_questionnaire_answer_id := p_questionnaire_answer_id;
     g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location('Leaving: '||l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end hr_qsa_bus;

/
