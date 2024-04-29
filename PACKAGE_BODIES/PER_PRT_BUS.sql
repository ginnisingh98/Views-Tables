--------------------------------------------------------
--  DDL for Package Body PER_PRT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PRT_BUS" as
/* $Header: peprtrhi.pkb 120.2 2006/05/03 18:37:44 kandra noship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_prt_bus.';  -- Global package name


-- -------------------------------------------------------------------+
-- --------------------< chk_non_updateable_args >--------------------+
-- -------------------------------------------------------------------+

procedure chk_non_updateable_args(p_rec in per_prt_shd.g_rec_type) is

  l_proc	varchar2(72)	:= g_package||'chk_non_updateable_args';
  l_error	exception;
  l_argument	varchar2(30);

begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  -- Only proceed with validation if a row exists for the current record
  -- in the HR schema

  if not per_prt_shd.api_updating
                     (p_performance_rating_id	=> p_rec.performance_rating_id
		     ,p_object_version_number	=> p_rec.object_version_number
		     ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', 20);
  end if;

  hr_utility.set_location(l_proc, 30);

  if p_rec.appraisal_id <> per_prt_shd.g_old_rec.appraisal_id then
    l_argument := 'appraisal_id';
    raise l_error;
  end if;

  hr_utility.set_location(l_proc, 40);

  if p_rec.objective_id <> per_prt_shd.g_old_rec.objective_id then
    l_argument := 'objective_id';
    raise l_error;
  end if;


  exception
    when l_error then
      hr_api.argument_changed_error
             (p_api_name => l_proc
             ,p_argument => l_argument
             ,p_base_table => per_prt_shd.g_tab_nam);
    when others then
      raise;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
end chk_non_updateable_args;


-- -------------------------------------------------------------------+
-- ------------------------< chk_appraisal_id >-----------------------+
-- -------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--  - Validates that the appraisal id exists in per_appraisals

-- Pre-requisites:
--  - None

-- In Arguments:
--   - p_appraisal_id

-- Post Success:
--   - Processing continues if the appraisal_id is valid.

-- Post Failure:
--   - An application error is raised and processing is terminated if
--     the appraisal_id is invalid.

-- Developer/Implementation Notes:
--   - None

-- Access Status:
--   - Internal table handler use only.


procedure chk_appraisal_id
	(p_appraisal_id 	in per_performance_ratings.appraisal_id%TYPE
  	,p_performance_rating_id	in per_performance_ratings.performance_rating_id%TYPE
        ,p_object_version_number	in per_performance_ratings.object_version_number%TYPE
)
	is

  -- Declare local variables

  l_api_updating       boolean;
  l_proc	varchar2(72)  :=  g_package||'chk_appraisal_id';
  l_exists	varchar2(1);

  -- Cursor to check that the specified appraisal_id exists in per_appraisals

  cursor csr_id_exists is
    select null
      from per_appraisals
     where appraisal_id = p_appraisal_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_appraisal_id is null then
    hr_utility.set_message(801, 'HR_51918_PRT_APR_MANDATORY');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 20);

  l_api_updating := per_prt_shd.api_updating
	(p_performance_rating_id	=> p_performance_rating_id
	,p_object_version_number	=> p_object_version_number);

  if (  (l_api_updating and nvl(per_prt_shd.g_old_rec.appraisal_id,
                                hr_api.g_number)
                        <> nvl(p_appraisal_id,hr_api.g_number)
         ) or
        (NOT l_api_updating)
      ) then

  open csr_id_exists;

  fetch csr_id_exists into l_exists;

  if csr_id_exists%notfound then
    close csr_id_exists;
    hr_utility.set_message(801, 'HR_51919_PRT_APR_NOT_EXIST');
    hr_utility.raise_error;
  end if;

  close csr_id_exists;

  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PERFORMANCE_RATINGS.APPRAISAL_ID'
             ) then
          raise;
        end if;

end chk_appraisal_id;


-- -------------------------------------------------------------------+
-- ------------------------< chk_objective_id >-----------------------+
-- -------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   - Checks that the specified objective_id exists in per_objectives
--     for the same business group.
--   - Checks that the appraisal date in per_appraisals is between the
--     effective start/end dates in per_objectives
--   - Validates that the objective_id is unique for the appraisal_id

-- Pre-requisites:
--  - None

-- In Arguments:
--   - p_performance_rating_id
--   - p_objective_id
--   - p_appraisal_id

-- Post Success:
--   - Process continues if:
--        * The objective_id exists in per_objectives
--        * The appraisal date is between the effective start and end dates
--        * The objective_id is unique for appraisal_id

-- Post Failure:
--   - An application error is raised and processing is terminated if any of
--     the following cases are found:
--        * The specified objective_id does not exists in per_objectives
--        * The appraisal date is not between the effective start and end dates
--        * The objective_id is not unique for the appraisal_id

-- Developer/Implementation Notes:
--   - None

-- Access Status:
--   - Internal table handler use only.


procedure chk_objective_id
        (p_objective_id 		in per_performance_ratings.objective_id%TYPE
	,p_appraisal_id			in per_performance_ratings.appraisal_id%TYPE
  	,p_performance_rating_id	in per_performance_ratings.performance_rating_id%TYPE
        ,p_object_version_number	in per_performance_ratings.object_version_number%TYPE
)
        is

  -- Declare local variables

  l_api_updating       boolean;
  l_proc		varchar2(72)  :=  g_package||'chk_objective_id';
  l_exists	  	varchar2(1);
  l_business_group_id	per_objectives.business_group_id%TYPE;

  -- Cursor to check that the specified objective_id exists in per_objectives
  -- where the business_group_id in per_objectives exists in per_appraisals

  cursor csr_id_exists is
    select o.business_group_id
      from per_objectives o
     where o.objective_id = p_objective_id;

  cursor csr_bg_exists (l_business_group_id IN per_objectives.business_group_id%TYPE) is
    select null
      from per_appraisals a
     where a.appraisal_id = p_appraisal_id
       and a.business_group_id = l_business_group_id;

  cursor csr_objective_id_exists is
    select null
      from per_performance_ratings p
     where objective_id = p_objective_id
       and appraisal_id = p_appraisal_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument         => 'appraisal_id'
    ,p_argument_value   => p_appraisal_id
    );

  if p_objective_id is null then
    hr_utility.set_message(801, 'HR_51920_PRT_OBJ_MANDATORY');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 20);

  l_api_updating := per_prt_shd.api_updating
	(p_performance_rating_id	=> p_performance_rating_id
	,p_object_version_number	=> p_object_version_number);

  if (  (l_api_updating and nvl(per_prt_shd.g_old_rec.objective_id,
                                hr_api.g_number)
                        <> nvl(p_objective_id,hr_api.g_number)
         ) or
        (NOT l_api_updating)
      ) then

  open csr_id_exists;

  fetch csr_id_exists into l_business_group_id;

  if csr_id_exists%notfound then
    close csr_id_exists;
    hr_utility.set_message(801, 'HR_51921_PRT_OBJ_NOT_EXIST');
    hr_utility.raise_error;
  end if;

  close csr_id_exists;

  hr_utility.set_location(l_proc, 30);

  -- Check the business group

  open csr_bg_exists(l_business_group_id);

  fetch csr_bg_exists into l_exists;

  if csr_bg_exists%notfound then
    close csr_bg_exists;
    hr_utility.set_message(801, 'HR_51922_PRT_OBJ_DIFF_BUS_GRP');
    hr_utility.raise_error;
  end if;

  close csr_bg_exists;

  hr_utility.set_location(l_proc, 40);

  hr_utility.set_location(l_proc, 60);

  /*
    Disable this check as we support multiple entries
    in this table marked by PERSON_ID
  open csr_objective_id_exists;

  fetch csr_objective_id_exists into l_exists;

  if csr_objective_id_exists%found then
    close csr_objective_id_exists;
    hr_utility.set_message(801, 'HR_51924_PRT_OBJ_NOT_UNIQUE');
    hr_utility.raise_error;
  end if;

  close csr_objective_id_exists;
  */
  end if; -- api_updating
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PERFORMANCE_RATINGS.OBJECTIVE_ID'
             ) then
          raise;
        end if;

end chk_objective_id;

-- -------------------------------------------------------------------+
-- -------------------< chk_performance_level_id >--------------------+
-- -------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   - Checks that the specified rating_level_id exists in per_rating_levels
--     for the same business group.
--   - Checks that the rating scale in per_rating_levels also exists in
--     per_appraisal_templates

-- Pre-requisites:
--  - None

-- In Arguments:
--   - p_performance_rating_id
--   - p_performance_level_id
--   - p_appraisal_id
--   - p_object_version_number

-- Post Success:
--   - Processing continues if:
--        * The performance_level_id exists in per_rating_levels
--        * The rating scale in per_rating_levels also exists in
--          per_appraisal_templates

-- Post Failure:
--   - An application error is raised and processing is terminated if any of
--     the following cases are found:
--        * The specified performance_level_id does not exists in
--          per_rating_levels
--        * The rating scale in per_rating levels does not exist in
--          per_appraisal_templates

-- Developer/Implementation Notes:
--   - None

-- Access Status:
--   - Internal table handler use only.


procedure chk_performance_level_id
  	(p_performance_rating_id	in per_performance_ratings.performance_rating_id%TYPE
        ,p_performance_level_id 	in per_performance_ratings.performance_level_id%TYPE
	,p_appraisal_id			in per_performance_ratings.appraisal_id%TYPE
        ,p_object_version_number	in per_performance_ratings.object_version_number%TYPE)
        is

  -- Declare local variables

  l_proc		varchar2(72)  :=  g_package||'chk_performance_level_id';
  l_exists		varchar2(1);
  l_api_updating	boolean;
  l_business_group_id   per_rating_levels.business_group_id%TYPE;

  -- Cursor to check if the rating_level_id exists for the same business group

  cursor csr_id_exists is
    select r.business_group_id
      from per_rating_levels r
     where r.rating_level_id = p_performance_level_id;

  -- Cursor to check if the appraisal_id exists for the same business group

  cursor csr_bg_exists (l_business_group_id in per_rating_levels.business_group_id%TYPE) is
    select null
      from per_appraisals a
     where a.appraisal_id = p_appraisal_id
       and a.business_group_id = l_business_group_id;

  -- Cursor to check if the rating_scale_id exists in per_appraisal_templates

  cursor csr_check_rating_scale_id is
    select null
      from per_rating_levels r,
           per_appraisal_templates t,
           per_appraisals p,
           per_assessment_types a
     where p.appraisal_id = p_appraisal_id
       and p.appraisal_template_id = t.appraisal_template_id
       and t.objective_asmnt_type_id = a.assessment_type_id(+)
       and r.rating_scale_id = decode(t.objective_asmnt_type_id, null, t.rating_scale_id, a.rating_scale_id)
       and r.rating_level_id = p_performance_level_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument         => 'appraisal_id'
    ,p_argument_value   => p_appraisal_id
    );

  -- check if the record is being updated

  l_api_updating := per_prt_shd.api_updating
	(p_performance_rating_id	=> p_performance_rating_id
	,p_object_version_number	=> p_object_version_number);

  hr_utility.set_location(l_proc, 20);

  -- Only proceed with validation if:
  -- a) The current g_old_rec is current and
  -- b) The value for the rating_level_id has changed

  if ((l_api_updating AND
       nvl(per_prt_shd.g_old_rec.performance_level_id, hr_api.g_number)
      <> nvl(p_performance_level_id, hr_api.g_number))
     or (not l_api_updating))
  then

    hr_utility.set_location(l_proc, 30);
   IF p_performance_level_id IS NOT NULL THEN

    open csr_id_exists;

    fetch csr_id_exists into l_business_group_id;

    if csr_id_exists%notfound then
      close csr_id_exists;
      hr_utility.set_message(801, 'HR_51925_PRT_RLI_NOT_EXIST');
      hr_utility.raise_error;
    end if;

    close csr_id_exists;
END IF;
    hr_utility.set_location(l_proc, 40);
    -- ngundura changes done for pa requirements
    -- put this if conditions
    if l_business_group_id is not null then
    	open csr_bg_exists(l_business_group_id);

    	if csr_bg_exists%notfound then
          close csr_bg_exists;
          hr_utility.set_message(801, 'HR_51926_PRT_RLI_DIFF_BUS_GRP');
          hr_utility.raise_error;
        end if;

        close csr_bg_exists;
    end if;
    -- ngundura end of changes
    hr_utility.set_location(l_proc, 50);

  end if;

  hr_utility.set_location(l_proc, 60);

  l_api_updating := per_prt_shd.api_updating
	(p_performance_rating_id	=> p_performance_rating_id
	,p_object_version_number	=> p_object_version_number);

  hr_utility.set_location(l_proc, 70);

  -- Only proceed with validation if:
  -- a) The current g_old_rec is current and
  -- b) The value for the rating_level_id has changed

  if ((l_api_updating AND
       nvl(per_prt_shd.g_old_rec.performance_level_id, hr_api.g_number)
      <> nvl(p_performance_level_id, hr_api.g_number))
     or (not l_api_updating))
  then

    hr_utility.set_location(l_proc, 80);
IF p_performance_level_id IS NOT NULL THEN

    open csr_check_rating_scale_id;

    fetch csr_check_rating_scale_id into l_exists;

    if csr_check_rating_scale_id%notfound then
      close csr_check_rating_scale_id;
      hr_utility.set_message(801, 'HR_51927_PRT_RSI_NOT_EXIST');
      hr_utility.raise_error;
    end if;

    close csr_check_rating_scale_id;
END IF;
    hr_utility.set_location(l_proc, 90);

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 100);
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_PERFORMANCE_RATINGS.PERFORMANCE_LEVEL_ID'
             ) then
          raise;
        end if;

end chk_performance_level_id;


-- -------------------------------------------------------------------+
-- ----------------------< chk_for_duplicates >-----------------------+
-- -------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   - Checks for any duplicate per_performance_rating records for the combination
--     of appraisal_id, objective_id and person_id. Throws error if found.

-- Pre-requisites:
--  - None

-- In Arguments:
--   - p_appraisal_id
--   - p_objective_id
--   - p_person_id
--   - p_object_version_number

-- Post Success:
--   - Processing continues if:
--        * There is only are no records existing for the combination of
--          appraisal_id, objective_id and person_id

-- Post Failure:
--   - An application error is raised and processing is terminated if any of
--     the following cases are found:
--        * A record is found for the combination of appraisal_id, objective_id
--          and person_id

-- Developer/Implementation Notes:
--   - None

-- Access Status:
--   - Internal table handler use only.

procedure chk_for_duplicates
        (p_appraisal_id                 in per_performance_ratings.appraisal_id%TYPE
        ,p_objective_id         	in per_performance_ratings.objective_id%TYPE
        ,p_person_id         		in per_performance_ratings.person_id%TYPE
        ,p_object_version_number        in per_performance_ratings.object_version_number%TYPE)
        is
  -- Declare local variables
  l_proc                varchar2(72)  :=  g_package||'chk_for_duplicates';
  l_exists              varchar2(1);

  -- Cursor to check if there are no multiple rows for a combination of
  -- appraisal_id, objective_id and person_id
  cursor csr_num_rows is
    select 'Y'
      from per_performance_ratings ppr
     where ppr.appraisal_id = p_appraisal_id
       and ppr.objective_id = p_objective_id
       and ppr.person_id = p_person_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'appraisal_id'
    ,p_argument_value   => p_appraisal_id
    );

  hr_utility.set_location(l_proc, 20);

  -- Validate if the number rows for the combination of appraisal_id, objective_id
  -- and person_id is 1

  open csr_num_rows;

  fetch csr_num_rows into l_exists;

  if nvl(l_exists,'N') = 'Y' then
    hr_utility.set_message(800, 'HR_DUPL_PERF_RATING');
    hr_utility.set_location('Appraisal Id:'|| p_appraisal_id, 22);
    hr_utility.set_location('Objective Id:'|| p_objective_id, 24);
    hr_utility.set_location('Person Id:'|| p_person_id, 26);
    hr_utility.raise_error;
  end if;

  close csr_num_rows;

  hr_utility.set_location('Leaving:'|| l_proc, 30);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1      => 'PER_PERFORMANCE_RATINGS.APPRAISAL_ID'
       ,p_associated_column2      => 'PER_PERFORMANCE_RATINGS.OBJECTIVE_ID'
       ,p_associated_column3      => 'PER_PERFORMANCE_RATINGS.PERSON_ID'
       ) then
      raise;
    end if;
end chk_for_duplicates;


-- ----------------------------------------------------------------------+
-- |------------------------------< chk_df >-----------------------------|
-- ----------------------------------------------------------------------+

-- Description:
--   Validates the all Descriptive Flexfield values.

-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.

-- In Arguments:
--   p_rec

-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.

-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.

-- Access Status:
--   Internal Row Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+

procedure chk_df
  (p_rec in per_prt_shd.g_rec_type) is

  l_proc    varchar2(72) := g_package||'chk_df';

begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  if ((p_rec.performance_rating_id is not null) and (
     nvl(per_prt_shd.g_old_rec.person_id, hr_api.g_number) <>
     nvl(p_rec.person_id, hr_api.g_number) or
     nvl(per_prt_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_prt_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.performance_rating_id is null) then

    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PERFORMANCE_RATINGS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20);
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;

-- ---------------------------------------------------------------------------+
-- |---------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure insert_validate(p_rec in per_prt_shd.g_rec_type, p_effective_date in date) is

  l_proc  varchar2(72) := g_package||'insert_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  per_apr_bus.set_security_group_id
    (
     p_appraisal_id             => p_rec.appraisal_id
     ,p_associated_column1 => per_prt_shd.g_tab_nam || '.APPRAISAL_ID');

   --
         hr_multi_message.end_validation_set;
   --
   hr_utility.set_location('Entering:'||l_proc, 15);

  -- Call all supporting business operations

  -- validate the appraisal_id

  per_prt_bus.chk_appraisal_id
    (p_appraisal_id	        => p_rec.appraisal_id
    ,p_performance_rating_id	=> p_rec.performance_rating_id
    ,p_object_version_number	=> p_rec.object_version_number);

  hr_utility.set_location(l_proc, 20);

  -- validate the objective_id

  per_prt_bus.chk_objective_id
    (p_objective_id		=> p_rec.objective_id
    ,p_appraisal_id		=> p_rec.appraisal_id
    ,p_performance_rating_id	=> p_rec.performance_rating_id
    ,p_object_version_number	=> p_rec.object_version_number);

  hr_utility.set_location(l_proc, 30);


  -- validate performance_level_id

  per_prt_bus.chk_performance_level_id
    (p_performance_rating_id	=> p_rec.performance_rating_id
    ,p_performance_level_id	=> p_rec.performance_level_id
    ,p_appraisal_id		=> p_rec.appraisal_id
    ,p_object_version_number	=> p_rec.object_version_number);

  hr_utility.set_location(l_proc, 40);

  -- validate that there are no records in per_performance_ratings for the combination
  -- of appraisal_id, objective_id and person_id

  per_prt_bus.chk_for_duplicates
    (p_appraisal_id             => p_rec.appraisal_id
    ,p_objective_id             => p_rec.objective_id
    ,p_person_id	        => p_rec.person_id
    ,p_object_version_number    => p_rec.object_version_number);

  hr_utility.set_location(l_proc, 45);

  -- call descriptive flexfield validation routines

  per_prt_bus.chk_df(p_rec => p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 50);

End insert_validate;

-- ---------------------------------------------------------------------------+
-- |---------------------------< update_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure update_validate(p_rec in per_prt_shd.g_rec_type, p_effective_date in date) is

  l_proc  varchar2(72) := g_package||'update_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  per_apr_bus.set_security_group_id
    (
     p_appraisal_id             => p_rec.appraisal_id
     ,p_associated_column1 => per_prt_shd.g_tab_nam || '.APPRAISAL_ID');

  --
        hr_multi_message.end_validation_set;
  --

  hr_utility.set_location('Entering:'||l_proc, 15);

  -- Call all supporting business operations

  -- Check that the non-updateable columns have not changed

  chk_non_updateable_args(p_rec);


  hr_utility.set_location(l_proc, 20);

  -- validate performance_level_id

  per_prt_bus.chk_performance_level_id
    (p_performance_rating_id	=> p_rec.performance_rating_id
    ,p_performance_level_id	=> p_rec.performance_level_id
    ,p_appraisal_id		=> p_rec.appraisal_id
    ,p_object_version_number	=> p_rec.object_version_number);

  hr_utility.set_location(l_proc, 30);

  -- call descriptive flexfield validation routines

  per_prt_bus.chk_df(p_rec => p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 50);

End update_validate;

-- ---------------------------------------------------------------------------+
-- |---------------------------< delete_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure delete_validate(p_rec in per_prt_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'delete_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  -- Call all supporting business operations

  hr_utility.set_location(' Leaving:'||l_proc, 20);

End delete_validate;

-- ---------------------------------------------------------------------------+
-- |-----------------------< return_legislation_code >------------------------|
-- ---------------------------------------------------------------------------+
Function return_legislation_code
         (  p_performance_rating_id     in number
          ) return varchar2 is

-- Declare cursor

   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups      pbg,
                 per_performance_ratings  ppr,
                 per_objectives           pob
          where  ppr.performance_rating_id = p_performance_rating_id
            and  ppr.objective_id          = pob.objective_id
            and  pbg.business_group_id     = pob.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Ensure that all the mandatory parameters are not null

  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'performance_rating_id',
                              p_argument_value => p_performance_rating_id );
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;

     -- The primary key is invalid therefore we must error out

     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;

  close csr_leg_code;
  return l_legislation_code;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End return_legislation_code;



-- flemonni

FUNCTION Get_PR_Data
  ( p_objective_id	IN per_objectives.objective_id%TYPE
  )
RETURN r_objpr_rec
IS
  l_record	r_objpr_rec;
  CURSOR csr_objpr
           ( p_objective_id per_objectives.objective_id%TYPE
           )
  IS
    SELECT performance_rating_id, object_version_number
    FROM   per_performance_ratings
    WHERE  objective_id    = p_objective_id;
BEGIN
  OPEN csr_objpr
         ( p_objective_id => p_objective_id
         );
  FETCH csr_objpr INTO l_record;
  CLOSE csr_objpr;

  RETURN l_record;
END Get_PR_Data;

end per_prt_bus;

/
