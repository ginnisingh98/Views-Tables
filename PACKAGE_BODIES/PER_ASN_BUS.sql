--------------------------------------------------------
--  DDL for Package Body PER_ASN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASN_BUS" as
/* $Header: peasnrhi.pkb 115.11 2003/09/01 08:19:06 bdivvela ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_asn_bus.';  -- Global package name
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_assessment_id number default null;
g_legislation_code varchar2(150) default null;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
--
-- In the ASSESSMENT_ENTITY, there three non-updateable arguments :
--		business_group_id
--		person_id
--		assessor_person_id
--
Procedure chk_non_updateable_args(p_rec in per_asn_shd.g_rec_type) is
--
  l_proc        varchar2(72) := g_package||'chk_non_updateable_args';
  l_error       exception;
  l_argument    varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema.
  if not per_asn_shd.api_updating
  --
   (p_assessment_id		=> p_rec.assessment_id
   ,p_object_version_number	=> p_rec.object_version_number
   ) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location (l_proc, 6);
  --
  if p_rec.business_group_id <> per_asn_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  if p_rec.person_id <> per_asn_shd.g_old_rec.person_id then
    l_argument := 'person_id';
    raise l_error;
  end if;
  --
  if p_rec.assessor_person_id <> per_asn_shd.g_old_rec.assessor_person_id then
    l_argument := 'assessor_person_id';
    raise l_error;
  end if;
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         ,p_base_table => per_asn_shd.g_tab_nam);
    when others then
       raise;
    --
  hr_utility.set_location(' Leaving : '|| l_proc, 10);
--
end chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assessment_type_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   ASSESSMENT_TYPE_ID is a foreign key to the table PER_ASSESSMENT_TYPES.
--   The value can be updated only if there are no rows in
--   PER_COMPETENCE_ELEMENTS for the particular assessment ie. if the
--   assessment hasn't been filled in at all (no ratings assigned to the
--   competences), then the ASSESSMENT_TYPE_ID can be updated.
--
--   Also the assessment_date has to be between the date_from and the date_to.
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--   assessment_id (chk for referenced rows)
--   assessment_type_id
--   date_from
--   date_to
--   business_group_id (as the assesment_type has to belong to the same BG)
--
-- POST SUCCESS
--   Processing continues
--
-- POST FAILURE
--   Processing terminates and a relevent error message is displayed.
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_assessment_type_id
  (p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_assessment_type_id		in per_assessments.assessment_type_id%TYPE
  ,p_assessment_date		in per_assessments.assessment_date%TYPE
  ,p_business_group_id		in per_assessments.business_group_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_proc        varchar2(72):=g_package||'chk_assessment_type_id';
  l_exists      varchar2(1);
  l_api_updating        boolean;
--
-- DEFINE CURSORS and the variable to hold results of fetch (if any)
--
  cursor csr_ass_used_in_comp is
    select null
    from per_competence_elements
    where p_assessment_id = assessment_id;
--
  cursor csr_ast_date_from_date_to is
    select date_from , date_to
    from per_assessment_types
    where p_assessment_type_id = assessment_type_id
    and   p_business_group_id  = business_group_id;
--
  l_ast_date_from	per_assessment_types.date_from%TYPE;
  l_ast_date_to		per_assessment_types.date_to%TYPE;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  hr_utility.set_location('assessment_type_id = '|| p_assessment_type_id,1);
  --
  -- Processing continues if :
  --    a) The row is being inserted.
  --    b) The row is being updated and
  --  		1: The new value is different then the old value
  --
  l_api_updating := per_asn_shd.api_updating
    (p_assessment_id       => p_assessment_id
    ,p_object_version_number    => p_object_version_number
    );
  --
  if ((l_api_updating and nvl(per_asn_shd.g_old_rec.assessment_type_id,
				hr_api.g_number)
			<> nvl(p_assessment_type_id, hr_api.g_number))
    or (not l_api_updating)) then
    --
    --  If updating, check whether rows exist in PER_COMPETENCE_ELEMENTS
    --
    if (l_api_updating) then
      --
      open csr_ass_used_in_comp;
      fetch csr_ass_used_in_comp into l_exists;
      --
      if csr_ass_used_in_comp%found then
        --
        close csr_ass_used_in_comp;
        hr_utility.set_message(801, 'HR_51582_ASN_USED_IN_COMP_ELE');
        hr_utility.raise_error;
        --
      end if;
      --
      close csr_ass_used_in_comp;
      --
    end if;
    --
    --
/*
    --
    open csr_ast_date_from_date_to;
    fetch csr_ast_date_from_date_to into l_ast_date_from , l_ast_date_to;
    --
    if csr_ast_date_from_date_to%notfound then
      --
      close csr_ast_date_from_date_to;
      --
      per_asn_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENTS_FK1');
      --
    end if;
    --
    close csr_ast_date_from_date_to;
*/
    --
    -- For insert and update, check whether the assessment_type is active
    --
    if (((p_assessment_date < l_ast_date_from) and (l_ast_date_from is not null)) or ((p_assessment_date > l_ast_date_to) and (l_ast_date_to is not null))) then
      --
      hr_utility.set_message(801, 'HR_51584_ASN_AST_IS_INACTIVE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 1);

  EXCEPTION

  when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_ASSESSMENTS.ASSESSMENT_ID'
             ) then
          raise;
      end if;

end chk_assessment_type_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_assessment_date >-------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   ASSESSMENT_DATE cannot be NULL
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--  assessment_date
--
-- POST SUCCESS
--   Processing continues
--
-- POST FAILURE
--   Processing terminates
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_assessment_date
  (p_assessment_date    in  per_assessments.assessment_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_api_updating        boolean;
  l_proc        varchar2(72):=g_package||'chk_assessment_date';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  l_api_updating := per_asn_shd.api_updating
    (p_assessment_id       => p_assessment_id
    ,p_object_version_number    => p_object_version_number
    );

--
  if ((l_api_updating and nvl(per_asn_shd.g_old_rec.assessment_date,
				hr_api.g_date)
			<> nvl(p_assessment_date, hr_api.g_date))
    or (not l_api_updating)) then

  if (p_assessment_date is NULL) then
    hr_utility.set_message(801, 'HR_51784_ASN_DATE_NULL');
    hr_utility.raise_error;
  end if;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 1);

  EXCEPTION

    when app_exception.application_exception then
          if hr_multi_message.exception_add
               (p_associated_column1      => 'PER_ASSESSMENTS.ASSESSMENT_DATE'
               ) then
            raise;
      end if;

end chk_assessment_date;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_person_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   PERSON_ID must be of the same business group and must exist on the
--   assessment date.  More rules to come
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--  person_id
--  business_group_id
--  assessment_date
--
-- POST SUCCESS
--   Processing continues
--
-- POST FAILURE
--   Processing terminates
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_person_id
  (p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_person_id 		in  per_assessments.person_id%TYPE
  ,p_business_group_id  in  per_assessments.business_group_id%TYPE
  ,p_assessment_date    in  per_assessments.assessment_date%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_proc        varchar2(72):=g_package||'chk_person_id';
--
-- Define cursors and their necessary variables
--
  cursor csr_chk_person_sta_date is
    select distinct(min(effective_start_date)), business_group_id
    from per_all_people_f per
    where per.person_id = p_person_id
    group by business_group_id;
--
  l_ASN_PERS_STA_DATE	per_people_f.start_date%TYPE;
  l_ASN_PERS_BG		per_people_f.business_group_id%TYPE;
--
  l_api_updating		boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --

    open csr_chk_person_sta_date;
    fetch csr_chk_person_sta_date into l_ASN_PERS_STA_DATE, l_ASN_PERS_BG;
    --
    if (csr_chk_person_sta_date%notfound or l_ASN_PERS_STA_DATE is null) then
      --
      close csr_chk_person_sta_date;
      --
      -- raise an error as the person_id doesn't exist
      --
      hr_utility.set_message(801, 'HR_51586_ASN_PER_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    close csr_chk_person_sta_date;
    --
    -- The person has to be in the correct business group
    --
    if (l_ASN_PERS_BG <> p_business_group_id) then
      --
      -- raise an error as the person is in the wrong business_group
      --
      hr_utility.set_message(801, 'HR_51806_ASN_PER_NOT_BG');
      hr_utility.raise_error;
      --
    end if;
    --
    -- The assessment_date has to be on or after the person start date
    --
    if (p_assessment_date < l_ASN_PERS_STA_DATE) then
      --
      hr_utility.set_message(801, 'HR_51587_ASN_PER_NOT_EXIST_DA');
      hr_utility.raise_error;
      --
    end if;
    --
  hr_utility.set_location('Leaving:'|| l_proc, 1);

EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.PERSON_ID'
         ) then
      raise;
    end if;

end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_assessor_person_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   ASSESSOR_PERSON_ID must be of the same business group and must exist on
--   the assessment date.
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--  assessor_person_id
--  business_group_id
--  assessment_date
--
-- POST SUCCESS
--   Processing continues
--
-- POST FAILURE
--   Processing terminates
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_assessor_person_id
  (p_assessor_person_id	in  per_assessments.assessor_person_id%TYPE
  ,p_business_group_id  in  per_assessments.business_group_id%TYPE
  ,p_assessment_date    in  per_assessments.assessment_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_proc        varchar2(72):=g_package||'chk_assessor_person_id';
--
  lv_cross_business_group varchar2(10); -- bug 1980440 fix
--
  cursor csr_chk_assessper_sta_date is
    select distinct(min(effective_start_date)), business_group_id
    from per_all_people_f per
    where per.person_id = p_assessor_person_id
    group by business_group_id;
 -- Fix 3122878. Using per_all_people_f instead of per_people_f.
--
  l_ASN_ASSPERS_STA_DATE	per_people_f.start_date%TYPE;
  l_ASN_ASSPERS_BG		per_people_f.business_group_id%TYPE;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

--
-- Tests are carried out on insert, and update (even if values haven't changed)
-- as data in the referenced table may have.
--
  open csr_chk_assessper_sta_date;
  fetch csr_chk_assessper_sta_date into l_ASN_ASSPERS_STA_DATE,l_ASN_ASSPERS_BG;
--
  if (csr_chk_assessper_sta_date%notfound or l_ASN_ASSPERS_STA_DATE is NULL) then
    --
    close csr_chk_assessper_sta_date;
    --
    -- raise an error as the person_id doesn't exist
    --
    hr_utility.set_message(801, 'HR_51588_ASN_ASSPER_NOT_EXIST');
    hr_utility.raise_error;
    --
  end if;
  close csr_chk_assessper_sta_date;
  --
  -- The person has to be in the correct business group
  --
  -- bug 1980440 fix starts
  -- if CROSS_BUSINESS_GROUP option is enabled we shouldn't do a comparison
  -- between Assessment BG and Assessor BG as they may be different
  lv_cross_business_group := fnd_profile.value('HR_CROSS_BUSINESS_GROUP');

    if lv_cross_business_group <> 'Y' THEN
        if (l_ASN_ASSPERS_BG <> p_business_group_id) then
        --
        -- raise an error as the person is in the wrong business_group
        --
        hr_utility.set_message(801, 'HR_51808_ASN_ASSPER_NOT_BG');
        hr_utility.raise_error;
        --
        end if;
    end if;
  -- bug 1980440 fix ends

  -- The assessment_date has to be on or after the assessors start date
  --
  if (p_assessment_date < l_ASN_ASSPERS_STA_DATE) then
    --
    hr_utility.set_message(801, 'HR_51589_ASN_ASSPER_NO_XIST_DA');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 1);
  --
EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.ASSESSOR_PERSON_ID'
         ) then
      raise;
    end if;

end chk_assessor_person_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_group_date_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   If the GROUP_INITIATOR_ID is not null, the GROUP_DATE must also be not null
--   and vica versa.
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--  group_initiator_id
--  group_date
--
-- POST SUCCESS
--   Processing continues
--
-- POST FAILURE
--   Processing terminates
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_group_date_id
  (p_group_initiator_id	in  per_assessments.group_initiator_id%TYPE
  ,p_group_date    in  per_assessments.group_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_api_updating        boolean;
  l_proc        varchar2(72):=g_package||'chk_group_date_id';
--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
--
-- Tests are carried out on insert only.
--
--
  l_api_updating := per_asn_shd.api_updating
    (p_assessment_id       => p_assessment_id
    ,p_object_version_number    => p_object_version_number
    );

  if ((l_api_updating and nvl(per_asn_shd.g_old_rec.group_initiator_id,
				hr_api.g_number)
			<> nvl(p_group_initiator_id, hr_api.g_number))
    or (not l_api_updating)) then

  If ((p_group_initiator_id is not null And p_group_date is null) Or
      (p_group_initiator_id is null And p_group_date is not null)) Then
    --
    -- raise an error as the either both should exist or neither should.
    --
    hr_utility.set_message(801, 'HR_52308_CM_GPR_DATE_ID_PROB');
    hr_utility.raise_error;
    --
  end if;
  --
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 2);
  --
EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.GROUP_INITIATOR_ID'
         ,p_associated_column2      => 'PER_ASSESSMENTS.P_GROUP_DATE'
         ) then
      raise;
    end if;

end chk_group_date_id;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_group_initiator_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   GROUP_INITIATOR_ID must be of the same business group and must exist on
--   the group_date.
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--  group_initiator_id
--  business_group_id
--  group_date
--
-- POST SUCCESS
--   Processing continues
--
-- POST FAILURE
--   Processing terminates
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_group_initiator_id
  (p_group_initiator_id	in  per_assessments.group_initiator_id%TYPE
  ,p_business_group_id  in  per_assessments.business_group_id%TYPE
  ,p_group_date    in  per_assessments.group_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_api_updating        boolean;
  l_proc        varchar2(72):=g_package||'chk_group_initiator_id';
--
  cursor csr_chk_grp_per_sta_date is
    select distinct(min(effective_start_date)), business_group_id
    from per_all_people_f per
    where per.person_id = p_group_initiator_id
    group by business_group_id;
--
  l_asn_grp_pers_sta_date	per_people_f.start_date%TYPE;
  l_asn_grp_pers_bg		per_people_f.business_group_id%TYPE;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
--
  l_api_updating := per_asn_shd.api_updating
    (p_assessment_id       => p_assessment_id
    ,p_object_version_number    => p_object_version_number
    );

--
-- Tests are carried out on insert only.
--
  if ((l_api_updating and nvl(per_asn_shd.g_old_rec.group_initiator_id,
				hr_api.g_number)
			<> nvl(p_group_initiator_id, hr_api.g_number))
    or (not l_api_updating)) then

  IF p_group_initiator_id is not null THEN
    --
    open csr_chk_grp_per_sta_date;
    fetch csr_chk_grp_per_sta_date into l_asn_grp_pers_sta_date,l_asn_grp_pers_bg;
--
    if (csr_chk_grp_per_sta_date%notfound or l_asn_grp_pers_sta_date IS NULL) then
      --
      close csr_chk_grp_per_sta_date;
      --
      -- raise an error as the person_id doesn't exist
      --
      hr_utility.set_message(801, 'HR_52305_ASN_GRPPER_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    close csr_chk_grp_per_sta_date;
    --
    -- The person has to be in the correct business group
    --
    IF (l_asn_grp_pers_bg <> p_business_group_id) THEN
      --
      -- raise an error as the person is in the wrong business_group
      --
      hr_utility.set_message(801, 'HR_52306_ASN_GRPPER_NOT_BG');
      hr_utility.raise_error;
      --
    END IF;
    --
    -- The group_date has to be on or after the group initiators start date
    --
    IF (p_group_date < l_asn_grp_pers_sta_date) then
      --
      hr_utility.set_message(801, 'HR_52307_ASN_GRPPER_NO_XIST_DA');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 1);
  --
EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.GROUP_INITIATOR_ID'
         ) then
      raise;
    end if;

end chk_group_initiator_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_status >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   The status flag is based on a user-defined lookup,
--   APPRAISAL_ASSESSMENT_STATUS.  At the moment there is no validation on
--   this (only that the value exists in hr-lookups)
--   it can be null
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--    p_effective_date
-- POST SUCCESS
--    Processing continues
--
-- POST FAILURE
--    Prcessing halts and a suitable error is raised.
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_status
  (p_status 		in 	per_assessments.status%TYPE
  ,p_effective_date	in 	date
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_api_updating        boolean;
  l_proc        varchar2(72):=g_package||'chk_status';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  l_api_updating := per_asn_shd.api_updating
    (p_assessment_id       => p_assessment_id
    ,p_object_version_number    => p_object_version_number
    );
  if ((l_api_updating and nvl(per_asn_shd.g_old_rec.status,
				hr_api.g_varchar2)
			<> nvl(p_status, hr_api.g_varchar2))
    or (not l_api_updating)) then

  --
  -- Check that the value in p_status exist in hr_lookups
  --
  if p_status is not Null Then
    hr_utility.set_location(l_proc||':Value>'||p_status, 5);
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date => p_effective_date
      ,p_lookup_type    => 'APPRAISAL_ASSESSMENT_STATUS'
      ,p_lookup_code    => p_status
      ) then
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_message(801,'HR_51585_ASN_COMPLETE_INVAL');
      hr_utility.raise_error;
    end if;
  end if;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.STATUS'
         ) then
      raise;
    end if;


end chk_status;
-- ----------------------------------------------------------------------------
-- |------------------------< CHK_ASSESSMENT_PERIOD >-------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--    Perform check to make sure that :
--	1) If the ASSESSMENT_PERIOD_END exists, the ASSESSMENT_PERIOD_START
--         date also exists
--      2) The ASSESSMENT_PERIOD_END is >= ASSESSMENT_PERIOD_START
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--   p_assessment_period_start_date
--   p_assessment_period_end_date
--
-- POST SUCCESS
--   Processing continues.
--
-- POST FAILURE
--   Processing halts.
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_assessment_period
  (p_assessment_period_start_date in per_assessments.assessment_period_start_date%TYPE
  ,p_assessment_period_end_date in per_assessments.assessment_period_end_date%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_api_updating        boolean;
  l_proc        varchar2(72):=g_package||'chk_assessment_period';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  l_api_updating := per_asn_shd.api_updating
    (p_assessment_id       => p_assessment_id
    ,p_object_version_number    => p_object_version_number
    );

--
  if ((l_api_updating
  and (nvl(per_asn_shd.g_old_rec.assessment_period_start_date,
				hr_api.g_date)
			<> nvl(p_assessment_period_start_date, hr_api.g_date)
      or nvl(per_asn_shd.g_old_rec.assessment_period_end_date,
				hr_api.g_date)
			<> nvl(p_assessment_period_end_date, hr_api.g_date)))
    or (not l_api_updating)) then

  if (p_assessment_period_end_date is not null) then
    --
    -- As end_date <> NULL, start_date becomes mandatory
    --
    if (p_assessment_period_start_date is NULL) then
      --
      per_asn_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENTS_DATE_END_CHK');
      --
    end if;
    --
    --  The end date has to be >= the start date, else error.
    --
    if (p_assessment_period_start_date > p_assessment_period_end_date) then
      --
      per_asn_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENTS_DATE_CHK');
      --
    end if;
    --
  end if;
  --
  end if;
EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.ASSESSMENT_PERIOD_START_DATE'
         ,p_associated_column2      => 'PER_ASSESSMENTS.ASSESSMENT_PERIOD_END_DATE'
         ) then
      raise;
    end if;

end chk_assessment_period;
--
-- ----------------------------------------------------------------------------
-- |------------------------< CHK_UNIQUE_COMBINATION >------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
-- The fields assessment_type, assessment_date, assessor_person_id, person_id,
-- and group_date have to be unique.
--  The column ASSESSMENT_GROUP is no longer used for holding the fk to
--  the assessment_group, so the column group_date will uniquely identify
--  the group.
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--   p_assessment_id
--   p_assessment_type_id
--   p_assessment_date
--   p_person_id
--   p_assessor_person_id
--   p_group_date
--
-- POST SUCCESS
--  Processing continues
--
-- POST FAILURE
--  Processing halts
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_unique_combination
  (p_assessment_id  in per_assessments.assessment_id%TYPE
  ,p_assessment_type_id  in per_assessments.assessment_type_id%TYPE
  ,p_assessment_date	 in per_assessments.assessment_date%TYPE
  ,p_person_id		 in per_assessments.person_id%TYPE
  ,p_assessor_person_id  in per_assessments.assessor_person_id%TYPE
  ,p_group_date 	 in per_assessments.group_date%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is
--
  l_proc        varchar2(72):=g_package||'chk_unique_combination';
--
-- Create a cursor to get duplicate rows
--
  cursor csr_duplicate_rows is
    select null
    from per_assessments
    where  assessment_type_id   = p_assessment_type_id
      and  assessment_date      = p_assessment_date
      and  person_id  	        = p_person_id
      and  assessor_person_id   = p_assessor_person_id
      and  group_date     	= group_date
      and (assessment_id	<> p_assessment_id
	   OR p_assessment_id  is NULL);
--
  l_exists	varchar2(1);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
--
-- always check ins upd even if values not changed


--
  /* Disabling this validation as we now allow multiple assessments
     to be created by same person on same dates. This is done for new
     Appraisals build
  open csr_duplicate_rows;
  fetch csr_duplicate_rows into l_exists;
  --
  if csr_duplicate_rows%found then
    hr_utility.set_location('Dup.found:'|| l_proc, 3);
    close csr_duplicate_rows;
    --
    per_asn_shd.constraint_error
      (p_constraint_name => 'PER_ASSESSMENTS_UK1');
      --
  end if;
  close csr_duplicate_rows;
  */
  --

EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.ASSESSMENT_TYPE_ID'
         ,p_associated_column2      => 'PER_ASSESSMENTS.ASSESSMENT_DATE'
         ,p_associated_column3      => 'PER_ASSESSMENTS.PERSON_ID'
         ,p_associated_column4      => 'PER_ASSESSMENTS.ASSESSOR_PERSON_ID'
         ) then
      raise;
    end if;

end chk_unique_combination;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_ASSESSMENT_GROUP_ID >------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   ASSESSMENT_GROUP is a foreign key to the table PER_ASSESSMENT_GROUPS.
--   If ASSESSMENT_GROUP is NOT NULL, then the value must exist in the
--   referenced table with the same business group.
-- PRE-REQUISITES
--
-- IN PARAMETERS
--   p_assessment_group_id
--   p_business_group_id
-- POST SUCCESS
--   Processing continues
-- POST FAILURE
--   Processing halts
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_assessment_group_id
  (p_assessment_group_id	in per_assessments.assessment_group_id%TYPE
  ,p_business_group_id  in per_assessments.business_group_id%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
 is

--
  l_api_updating        boolean;
  l_proc        varchar2(72):=g_package||'chk_assessment_group_id';
--
-- Define the necessary cursor
--
  cursor csr_chk_ass_group_id is
    select null
    from per_assessment_groups
    where assessment_group_id = p_assessment_group_id
    and   business_group_id   = p_business_group_Id;

  l_exists	varchar2(1);

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  l_api_updating := per_asn_shd.api_updating
    (p_assessment_id       => p_assessment_id
    ,p_object_version_number    => p_object_version_number
    );
  if ((l_api_updating and nvl(per_asn_shd.g_old_rec.assessment_group_id,
				hr_api.g_number)
			<> nvl(p_assessment_group_id, hr_api.g_number))
    or (not l_api_updating)) then

  --
  if (p_assessment_group_id is not null) then
  hr_utility.set_location('assessment_group_id must be NULL:'|| l_proc, 1);
    --
    open csr_chk_ass_group_id;
    fetch csr_chk_ass_group_id into l_exists;
    --
    -- If the group isn't in the referenced table, raise an error
    --
    hr_utility.set_location('assessment_group_id :'|| p_assessment_group_id, 1);
    if (csr_chk_ass_group_id%notfound) then
      close csr_chk_ass_group_id;
      --
      per_asn_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENTS_FK3');
      --
    end if;
    close csr_chk_ass_group_id;
  end if;
  end if;
  --
 EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.ASSESSMENT_GROUP_ID'
         ) then
      raise;
    end if;

end chk_assessment_group_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CHK_APPRAISAL_ID >---------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   APPRAISAL_ID is a foreign key to the table PER_APPRAISALS.
--   If APPRAISAL_ID is NOT NULL, then the value must exist in the
--   referenced table with the same business group.
-- PRE-REQUISITES
--
-- IN PARAMETERS
--   p_appraisal_id
--   p_business_group_id
--
-- POST SUCCESS
--   Processing continues
-- POST FAILURE
--   Processing halts
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_appraisal_id
  (p_appraisal_id	in per_assessments.assessment_group_id%TYPE
  ,p_business_group_id  in per_assessments.business_group_id%TYPE
  ,p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number	in per_assessments.object_version_number%TYPE
  )
is

--
  l_api_updating        boolean;
  l_proc        varchar2(72):=g_package||'chk_appraisal_id';
--
-- Define the necessary cursor
--
  cursor csr_chk_appraisal_id is
    select null
    from per_appraisals
    where appraisal_id = p_appraisal_id
    and   business_group_id   = p_business_group_id;

  l_exists	varchar2(1);

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  l_api_updating := per_asn_shd.api_updating
    (p_assessment_id       => p_assessment_id
    ,p_object_version_number    => p_object_version_number
    );
  if ((l_api_updating and nvl(per_asn_shd.g_old_rec.appraisal_id,
				hr_api.g_number)
			<> nvl(p_appraisal_id, hr_api.g_number))
    or (not l_api_updating)) then

  --
  if (p_appraisal_id is NOT NULL) then
    --
    open csr_chk_appraisal_id;
    fetch csr_chk_appraisal_id into l_exists;
    --
    -- If the group isn't in the referenced table, raise an error
    --
    if (csr_chk_appraisal_id%notfound) then
      close csr_chk_appraisal_id;
      --
      per_asn_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENTS_FK4');
      --
    end if;
    close csr_chk_appraisal_id;
  end if;
  --
  end if;
 EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.ASSESSMENT_GROUP_ID'
         ) then
      raise;
    end if;

end chk_appraisal_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< CHK_COMP_ELEMENTS >--------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   Used to validate before the delete.  This process checks to make sure that
--   no rows exist in the PER_COMPETENCE_ELEMENTS table
-- PRE-REQUISITES
--
-- IN PARAMETERS
--   p_assessment_id
--   p_object_version_number
-- POST SUCCESS
--   Processing continues
-- POST FAILURE
--   Processing fails.
-- ACCESS STATUS
--  Internal Development Use Only
Procedure chk_comp_elements
  (p_assessment_id		in per_assessments.assessment_id%TYPE
  ,p_object_version_number 	in per_assessments.object_version_number%TYPE
  ) is
--
  l_proc        varchar2(72):=g_package||'chk_comp_elements';
--
  cursor csr_comp_elements_usage is
    select null
    from per_competence_elements
    where assessment_id = p_assessment_id;
--
  l_exists	 varchar2(1);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check that the assessment is not referenced by a competence element
  --
  open csr_comp_elements_usage;
  fetch csr_comp_elements_usage into l_exists;
  if csr_comp_elements_usage%found then
    close csr_comp_elements_usage;
    --
    hr_utility.set_location(l_proc,5);
    hr_utility.set_message (801, 'HR_51812_ASN_REF_BY_COMP');
    hr_utility.raise_error;
    --
  end if;
  close csr_comp_elements_usage;
  --
EXCEPTION

  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ASSESSMENTS.ASSESSMENT_ID'
         ) then
      raise;
    end if;
end chk_comp_elements;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_df
  (p_rec in per_asn_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.assessment_id is not null) and (
    nvl(per_asn_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_asn_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.assessment_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_ASSESSMENTS'
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
      ,p_attribute20_value  => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);

end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec 		in per_asn_shd.g_rec_type
  ,p_effective_date	in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations.  Mapping to the appropiate
  -- Business Rules in perasn.bru is provided.
  --
  -- VALIDATE BUSINESS_GROUP_ID
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_BUSINESS_GROUP_ID a
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_asn_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID');  -- Validate Bus Grp


  hr_multi_message.end_validation_set;
  --
  -- VALIDATE ASSESSMENT_DATE
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_ASSESSMENT_DATE a)
  --
  per_asn_bus.chk_assessment_date
    (p_assessment_date   => p_rec.assessment_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );

  --
  -- VALIDATE STATUS
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_STATUS a)
  --
  per_asn_bus.chk_status
    (p_status	  	=> p_rec.status
    ,p_effective_date   => p_effective_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  --
  -- VALIDATE CHK_ASSESSMENT_GROUP_ID
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_ASSESSMENT_GROUP_ID a)
  --
  per_asn_bus.chk_assessment_group_id
    (p_assessment_group_id      => p_rec.assessment_group_id
    ,p_business_group_id	=> p_rec.business_group_id
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- VALIDATE CHK_ASSESSMENT_TYPE_ID
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_ASSESSMENT_TYPE_ID a,b,c,d
  --
  per_asn_bus.chk_assessment_type_id
    (p_assessment_id		=> p_rec.assessment_id
    ,p_assessment_type_id	=> p_rec.assessment_type_id
    ,p_assessment_date		=> p_rec.assessment_date
    ,p_business_group_id	=> p_rec.business_group_id
    ,p_object_version_number	=> p_rec.object_version_number
    );
  --
  -- VALIDATE CHK_PERSON_ID
  --   Business Rule Mapping
  --   =====================
  --     Rule CHK_PERSON_ID a,b,c
  --
  per_asn_bus.chk_person_id
    (p_assessment_id		=> p_rec.assessment_id
    ,p_person_id		=> p_rec.person_id
    ,p_business_group_id	=> p_rec.business_group_id
    ,p_assessment_date		=> p_rec.assessment_date
    ,p_object_version_number	=> p_rec.object_version_number
    );
  --
  -- VALIDATE CHK_ASSESSOR_PERSON_ID
  --  	Business Rule Mapping
  --    =====================
  --      Rule CHK_ASSESSOR_PERSON_ID a
  --
  per_asn_bus.chk_assessor_person_id
    (p_assessor_person_id	=> p_rec.assessor_person_id
    ,p_business_group_id	=> p_rec.business_group_id
    ,p_assessment_date		=> p_rec.assessment_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- VALIDATE CHK_APPRAISAL_ID
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_APPRAISAL_ID a) b)
  --
  per_asn_bus.chk_appraisal_id
    (p_appraisal_id	=> p_rec.appraisal_id
    ,p_business_group_id  => p_rec.business_group_id
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- VALIDATE CHK_ASSESSMENT_PERIOD
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_ASSESSMENT_PERIOD a,b
  --
  per_asn_bus.chk_assessment_period
    (p_assessment_period_start_date 	=> p_rec.assessment_period_start_date
    ,p_assessment_period_end_date	=> p_rec.assessment_period_end_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- VALIDATE CHK_UNIQUE_COMBINATION
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_UNIQUE_COMBINATION a
  --
  per_asn_bus.chk_unique_combination
    (p_assessment_id		=> p_rec.assessment_id
    ,p_assessment_type_id	=> p_rec.assessment_type_id
    ,p_assessment_date		=> p_rec.assessment_date
    ,p_person_id		=> p_rec.person_id
    ,p_assessor_person_id       => p_rec.assessor_person_id
    ,p_group_date		=> p_rec.group_date
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  --
  per_asn_bus.chk_group_date_id
    (p_group_initiator_id	=> p_rec.group_initiator_id
    ,p_group_date    		=> p_rec.group_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  per_asn_bus.chk_group_initiator_id
    (p_group_initiator_id	=> p_rec.group_initiator_id
    ,p_business_group_id  	=> p_rec.business_group_id
    ,p_group_date    		=> p_rec.group_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- Call descriptive flexfield validation routines
  --
  per_asn_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec in per_asn_shd.g_rec_type
  ,p_effective_date  in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations.  Mapping to the appropiate
  -- business rules provided.
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_asn_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID');  -- Validate Business Group
  hr_multi_message.end_validation_set;
  --
  -- VALIDATE CHK_NON_UPDATABLE_ARGS
  --     Check those columns which cannot be updated have not changed.
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_BUSINESS_GROUP_ID a
  --   Rule CHK_PERSON_ID c
  --   Rule CHK_ASSESSOR_PERSON_ID b
  --
  per_asn_bus.chk_non_updateable_args
    (p_rec      =>  p_rec);
  --
  -- VALIDATE ASSESSMENT_DATE
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_ASSESSMENT_DATE a)
  --
  per_asn_bus.chk_assessment_date
    (p_assessment_date   => p_rec.assessment_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );

  --
  -- VALIDATE CHK_ASSESSMENT_GROUP_ID
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_ASSESSMENT_GROUP_ID a)
  --
  per_asn_bus.chk_assessment_group_id
    (p_assessment_group_id      => p_rec.assessment_group_id
    ,p_business_group_id	=> p_rec.business_group_id
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- VALIDATE STATUS
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_STATUS a)
  --
  per_asn_bus.chk_status
    (p_status         => p_rec.status
    ,p_effective_date   => p_effective_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- VALIATE CHK_ASSESSMENT_TYPE_ID
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_ASSESSMENT_TYPE_ID a,b,c,d
  --
  per_asn_bus.chk_assessment_type_id
    (p_assessment_id            => p_rec.assessment_id
    ,p_assessment_type_id       => p_rec.assessment_type_id
    ,p_assessment_date		=> p_rec.assessment_date
    ,p_business_group_id        => p_rec.business_group_id
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  -- VALIDATE CHK_ASSESSMENT_PERIOD
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_ASSESSMENT_PERIOD a,b
  --
  per_asn_bus.chk_assessment_period
    (p_assessment_period_start_date     => p_rec.assessment_period_start_date
    ,p_assessment_period_end_date       => p_rec.assessment_period_end_date
    ,p_assessment_id => p_rec.assessment_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- VALIDATE CHK_UNIQUE_COMBINATION
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_UNIQUE_COMBINATION a
  --
  per_asn_bus.chk_unique_combination
    (p_assessment_id            => p_rec.assessment_id
    ,p_assessment_type_id       => p_rec.assessment_type_id
    ,p_assessment_date          => p_rec.assessment_date
    ,p_person_id                => p_rec.person_id
    ,p_assessor_person_id       => p_rec.assessor_person_id
    ,p_group_date   	        => p_rec.group_date
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- Call descriptive flexfield validation routines
  --
  per_asn_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_asn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations and show mapping
  --
  per_asn_bus.chk_comp_elements
    (p_assessment_id		=> p_rec.assessment_id
    ,p_object_version_number	=> p_rec.object_version_number
    );
    --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
         (  p_assessment_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups pbg,
                 per_assessments     pas
          where  pas.assessment_id     = p_assessment_id
            and  pbg.business_group_id = pas.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'assessment_id',
                              p_argument_value => p_assessment_id );

    if nvl(g_assessment_id, hr_api.g_number) = p_assessment_id then
        --
        -- The legislation code has already been found with a previous
        -- call to this function. Just return the value in the global
        -- variable.
        --
        l_legislation_code := g_legislation_code;
        hr_utility.set_location(l_proc, 15);
    else
        --
        -- The ID is different to the last call to this function
        -- or this is the first call to this function.
        --
         open csr_leg_code;
         fetch csr_leg_code into l_legislation_code;
         if csr_leg_code%notfound then
            close csr_leg_code;
            --
            -- The primary key is invalid therefore we must error out
            --
            hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
            hr_utility.raise_error;
         end if;
         --
         close csr_leg_code;
      --
      g_assessment_id := p_assessment_id;
      g_legislation_code := l_legislation_code;
    end if;
  --
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
End return_legislation_code;
--
--
end per_asn_bus;

/
