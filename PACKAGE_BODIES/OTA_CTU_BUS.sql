--------------------------------------------------------
--  DDL for Package Body OTA_CTU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CTU_BUS" as
/* $Header: otcturhi.pkb 120.2.12010000.2 2009/07/24 10:53:50 shwnayak ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_ctu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_category_usage_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_category_usage_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_category_usages ctu
     where ctu.category_usage_id = p_category_usage_id
       and pbg.business_group_id = ctu.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'category_usage_id'
    ,p_argument_value     => p_category_usage_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'CATEGORY_USAGE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
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
  (p_category_usage_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_category_usages ctu
     where ctu.category_usage_id = p_category_usage_id
       and pbg.business_group_id = ctu.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'category_usage_id'
    ,p_argument_value     => p_category_usage_id
    );
  --
  if ( nvl(ota_ctu_bus.g_category_usage_id, hr_api.g_number)
       = p_category_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_ctu_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    ota_ctu_bus.g_category_usage_id           := p_category_usage_id;
    ota_ctu_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
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
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in ota_ctu_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.category_usage_id is not null)  and (
    nvl(ota_ctu_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_ctu_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or (p_rec.category_usage_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_CATEGORY_USAGES'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- ----------------------< Chk_Parent_Category_Dates >------------------------|
-- ----------------------------------------------------------------------------
--

Procedure Chk_Parent_Category_Dates
  (
   p_parent_cat_usage_id    in    number
  ,p_start_date             in    date
  ,p_end_date               in    date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_par_cat_start_end_date is
    select
      ctu.start_date_active,
      nvl(ctu.end_date_active, hr_api.g_eot)
    from
      ota_category_usages ctu
    where
      ctu.category_usage_id = p_parent_cat_usage_id;
  --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'Chk_Parent_Category_Dates';
  l_par_cat_start_date        date;
  l_par_cat_end_date          date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
          (p_check_column1        => 'OTA_CATEGORY_USAGES.START_DATE_ACTIVE'
          ,p_check_column2        => 'OTA_CATEGORY_USAGES.END_DATE_ACTIVE'
          ,p_associated_column1   => 'OTA_CATEGORY_USAGES.START_DATE_ACTIVE'
          ,p_associated_column2   => 'OTA_CATEGORY_USAGES.END_DATE_ACTIVE'
          ) THEN
     --
     OPEN cur_par_cat_start_end_date;
     FETCH cur_par_cat_start_end_date into l_par_cat_start_date, l_par_cat_end_date;

     IF cur_par_cat_start_end_date%FOUND THEN
        CLOSE cur_par_cat_start_end_date;
        IF ( l_par_cat_start_date > p_start_date
             or l_par_cat_end_date < nvl(p_end_date, hr_api.g_eot)
           ) THEN
          --
          fnd_message.set_name      ( 'OTA','OTA_13742_CTU_PAR_CAT_DATES');
	      fnd_message.raise_error;
          --
        End IF;
     ELSE
        CLOSE cur_par_cat_start_end_date;
     End IF;
  End IF;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.START_DATE_ACTIVE'
                 ,p_associated_column2   => 'OTA_CATEGORY_USAGES.END_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_Parent_Category_Dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------< Chk_Child_Category_Dates >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_Child_Category_Dates
  (p_category_usage_id            in            number
  ,p_start_date                   in            date
  ,p_end_date                     in            date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category
  --
  CURSOR cur_child_cat_dates is
     select
       ccat.start_date_active,
       ccat.end_date_active
     from
       ota_category_usages ccat
     where
       ccat.parent_cat_usage_id =  p_category_usage_id;
  --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'Chk_Child_Category_Dates';
  v_start_date           ota_category_usages.start_date_active%TYPE;
  v_end_date             ota_category_usages.end_date_active%TYPE;
  l_obj_cat              varchar2(80);
  l_obj_child_cat        varchar2(80);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
     OPEN cur_child_cat_dates;
     FETCH cur_child_cat_dates into v_start_date,
                              v_end_date;
     LOOP
     Exit When cur_child_cat_dates%notfound OR cur_child_cat_dates%notfound is null;

    -- Assignment if v_start_date or v_end_date is null
    --
    If v_end_date is null  Then
      --
      v_end_date   :=  hr_api.g_eot;
      --
    End if;

    If ota_general.check_par_child_dates_fun( p_start_date
                                            , p_end_date
                                            , v_start_date
                                            , v_end_date ) then
      --
      l_obj_cat        := ota_utility.Get_lookup_meaning('OTA_OBJECT_TYPE','C',810);
      l_obj_child_cat  := ota_utility.Get_lookup_meaning('OTA_OBJECT_TYPE','CHC',810);
      fnd_message.set_name( 'OTA','OTA_443166_OBJ_CHILD_DATE');
      fnd_message.set_token('OBJECT_NAME', l_obj_cat );
      fnd_message.set_token('CHILD_OBJECT', l_obj_child_cat);
      fnd_message.raise_error;
      --
    End if;
    --
    Fetch cur_child_cat_dates into v_start_date
                           , v_end_date;
  End loop;
  --
  Close cur_child_cat_dates;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.START_DATE_ACTIVE'
                 ,p_associated_column2   => 'OTA_CATEGORY_USAGES.END_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_Child_Category_Dates;
--
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_Act_Start_End_Date >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_Act_Start_End_Date
  (p_category_usage_id            in            number
  ,p_start_date                   in            date
  ,p_end_date                     in            date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category
  --
  CURSOR cur_act_dates is
     select
       tav.start_date,
       tav.end_date
     from
       ota_activity_versions tav,
       ota_act_cat_inclusions aci
     where
       tav.activity_version_id = aci.activity_version_id
       and aci.primary_flag= 'Y'
       and aci.category_usage_id =  p_category_usage_id;
  --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'Chk_Act_Start_End_Date';
  v_start_date           ota_activity_versions.start_date%TYPE;
  v_end_date             ota_activity_versions.end_date%TYPE;
  l_obj_cat              varchar2(80);
  l_obj_act              varchar2(80);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
     OPEN cur_act_dates;
     FETCH cur_act_dates into v_start_date,
                              v_end_date;
     LOOP
     Exit When cur_act_dates%notfound OR cur_act_dates%notfound is null;

    -- Assignment if v_start_date or v_end_date is null
    --
    If v_start_date is null  Then
      --
      v_start_date   :=  p_start_date;
      --
    End if;
    --
    If v_end_date is null  Then
      --
      v_end_date   :=  hr_api.g_eot;
      --
    End if;

    If ota_general.check_par_child_dates_fun( p_start_date
                                            , p_end_date
                                            , v_start_date
                                            , v_end_date ) then
      --

        l_obj_cat  := ota_utility.Get_lookup_meaning('OTA_OBJECT_TYPE','C',810);
        l_obj_act := ota_utility.Get_lookup_meaning('OTA_CATALOG_OBJECT_TYPE','H',810);
  	fnd_message.set_name      ( 'OTA','OTA_443166_OBJ_CHILD_DATE');
        fnd_message.set_token('OBJECT_NAME', l_obj_cat );
        fnd_message.set_token('CHILD_OBJECT', l_obj_act);
  	fnd_message.raise_error;
      --
    End if;
    --
    Fetch cur_act_dates into v_start_date
                           , v_end_date;
  End loop;
  --
  Close cur_act_dates;


  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.START_DATE_ACTIVE'
                 ,p_associated_column2   => 'OTA_CATEGORY_USAGES.END_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_Act_Start_End_Date;
--
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_lp_Start_End_Date >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_lp_Start_End_Date
  (p_category_usage_id            in            number
  ,p_start_date                   in            date
  ,p_end_date                     in            date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category
  --
  CURSOR cur_lp_dates is
     select
       lps.start_date_active,
       lps.end_date_active
     from
       ota_learning_paths lps,
       ota_lp_cat_inclusions lci
     where
       lps.learning_path_id = lci.learning_path_id
       and lci.primary_flag= 'Y'
       and lci.category_usage_id =  p_category_usage_id;
  --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'Chk_lp_Start_End_Date';
  v_start_date           ota_learning_paths.start_date_active%TYPE;
  v_end_date             ota_learning_paths.end_date_active%TYPE;
  l_obj_cat              varchar2(80);
  l_obj_lp              varchar2(80);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
     OPEN cur_lp_dates;
     FETCH cur_lp_dates into v_start_date,
                              v_end_date;
     LOOP
     Exit When cur_lp_dates%notfound OR cur_lp_dates%notfound is null;

    -- Assignment if v_start_date or v_end_date is null
    --
    If v_start_date is null  Then
      --
      v_start_date   :=  p_start_date;
      --
    End if;
    --
    If v_end_date is null  Then
      --
      v_end_date   :=  hr_api.g_eot;
      --
    End if;

    If ota_general.check_par_child_dates_fun( p_start_date
                                            , p_end_date
                                            , v_start_date
                                            , v_end_date ) then
      --

     l_obj_cat  := ota_utility.Get_lookup_meaning('OTA_OBJECT_TYPE','C',810);
     l_obj_lp := ota_utility.Get_lookup_meaning('OTA_CATALOG_OBJECT_TYPE','CLP',810);
  	 fnd_message.set_name      ( 'OTA','OTA_443166_OBJ_CHILD_DATE');
     fnd_message.set_token('OBJECT_NAME', l_obj_cat );
     fnd_message.set_token('CHILD_OBJECT', l_obj_lp);
  	 fnd_message.raise_error;
      --
    End if;
    --
    Fetch cur_lp_dates into v_start_date
                           , v_end_date;
  End loop;
  --
  Close cur_lp_dates;


  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.START_DATE_ACTIVE'
                 ,p_associated_column2   => 'OTA_CATEGORY_USAGES.END_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_lp_Start_End_Date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_Root_Cat >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_Root_Cat
  (p_business_group_id            in            number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_root_category is
    select
      distinct 'found'
    From
      ota_category_usages ctu
    where
      ctu.business_group_id = p_business_group_id
      and ctu.parent_cat_usage_id is null
      and ctu.type = 'C';

  -- Variables for API Boolean parameters
  l_proc               varchar2(72) := g_package ||'Chk_Root_Cat';
  l_root_cat_flag      varchar2(10);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_root_category;
     FETCH cur_root_category into l_root_cat_flag;

     IF cur_root_category%FOUND then
        CLOSE cur_root_category;
  	fnd_message.set_name      ( 'OTA'     ,'OTA_443103_ROOT_OBJ_EXISTS');
  	fnd_message.raise_error;
     ELSE
        CLOSE cur_root_category;
     END IF;

  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.BUSINESS_GROUP_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_Root_Cat;
--
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_Off_Start_End_Date >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_Off_Start_End_Date
  (p_category_usage_id            in            number
  ,p_start_date                   in            date
  ,p_end_date                     in            date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_off_dates is
    select start_date,
           end_date
    from
      ota_offerings off
    where
      off.delivery_mode_id = p_category_usage_id;

  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'Chk_Off_Start_End_Date';
  v_start_date           ota_offerings.start_date%TYPE;
  v_end_date             ota_offerings.end_date%TYPE;
  l_obj_dm               VARCHAR2(80);
  l_obj_off              VARCHAR2(80);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_off_dates;
     FETCH cur_off_dates into v_start_date,
                              v_end_date;
     LOOP
     Exit When cur_off_dates%notfound OR cur_off_dates%notfound is null;

    -- Assignment if v_start_date or v_end_date is null
    --
    If v_start_date is null  Then
      --
      v_start_date   :=  p_start_date;
      --
    End if;
    --
    If v_end_date is null  Then
      --
      v_end_date   :=  hr_api.g_eot;
      --
    End if;
    If ota_general.check_par_child_dates_fun( p_start_date
                                            , p_end_date
                                            , v_start_date
                                            , v_end_date ) then
      --

        l_obj_dm  := ota_utility.Get_lookup_meaning('CATEGORY_TYPE','DM',800);
        l_obj_off := ota_utility.Get_lookup_meaning('OTA_OBJECT_TYPE','OFS',810);
  	fnd_message.set_name      ( 'OTA','OTA_443166_OBJ_CHILD_DATE');
  	fnd_message.set_token('OBJECT_NAME', l_obj_dm );
  	fnd_message.set_token('CHILD_OBJECT', l_obj_off);
  	fnd_message.raise_error;
      --
    End if;
    --
    Fetch cur_off_dates into v_start_date
                           , v_end_date;
  End loop;
  --
  Close cur_off_dates;


  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.START_DATE_ACTIVE'
                 ,p_associated_column2   => 'OTA_CATEGORY_USAGES.END_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_Off_Start_End_Date;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_Sync_Online_Flag >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_Sync_Online_Flag
  (p_category_usage_id            in            number
  ,p_online_flag                  in            varchar2
  ,p_synchronous_flag             in            varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_dm_offerings is
    select 'Y'
     From ota_offerings  off
    where off.delivery_mode_id = p_category_usage_id;

  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'Chk_Sync_Online_Flag';
  l_off_flag             varchar2(10);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_dm_offerings;
     FETCH cur_dm_offerings into l_off_flag;

     IF cur_dm_offerings%FOUND then
        CLOSE cur_dm_offerings;
  	fnd_message.set_name      ( 'OTA'     ,'OTA_443269_CTU_FLG_OFF_EXISTS');
  	fnd_message.raise_error;
     ELSE
        CLOSE cur_dm_offerings;
     END IF;

  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
  --
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.ONLINE_FLAG'
                 ,p_associated_column2   => 'OTA_CATEGORY_USAGES.SYNCHRONOUS_FLAG'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_Sync_Online_Flag;
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
  ,p_rec in ota_ctu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_ctu_shd.api_updating
      (p_category_usage_id                 => p_rec.category_usage_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< Chk_unique_category >-------------------------------|
--  ---------------------------------------------------------------------------
--
Procedure Chk_unique_category
  (p_category_usage_id                    in     number
  ,p_category                             in     varchar2
  ,p_business_group_id                    in     varchar2
  ,p_type                                 in     varchar2
  ,p_parent_cat_usage_id                  in     number
  )
  Is
  --
  -- Declare cursor
  --
  cursor csr_cat_name is
    select
        distinct ctu.type
    from
        ota_category_usages_vl ctu
    where
        ctu.category = p_category
        and (p_category_usage_id is null or ctu.category_usage_id <> p_category_usage_id)
        and (ctu.parent_cat_usage_id = p_parent_cat_usage_id or ctu.type <> 'C')
        and ctu.business_group_id = p_business_group_id
        and ctu.type =   p_type;

  --
  --
  -- Declare local variables
  --
  l_dup_cat_type      varchar2(30);
  l_proc              varchar2(72)  :=  g_package||'Chk_unique_category';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_cat_name;
  fetch csr_cat_name into l_dup_cat_type;
  --
  if csr_cat_name%found then
    --
    -- The category name cannot be duplicated therefore we must error
    --
    close csr_cat_name;
    if l_dup_cat_type = 'DM' then
      fnd_message.set_name('OTA','OTA_443388_CTU_DUP_DM');
    else
      fnd_message.set_name('OTA','OTA_443337_CTU_DUP_NAME');
    end if;
    hr_utility.set_location(l_proc,20);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
  close csr_cat_name;

  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end Chk_unique_category;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_ctu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_ctu_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  -- Validating category name to be unique
  --
    Chk_unique_category
    (p_category_usage_id     =>      p_rec.category_usage_id
    ,p_category              =>      p_rec.category
    ,p_business_group_id     =>      p_rec.business_group_id
    ,p_type                  =>      p_rec.type
    ,p_parent_cat_usage_id   =>      p_rec.parent_cat_usage_id
    );
  --
  If p_rec.type = 'C' then
    --
    If p_rec.parent_cat_usage_id is null Then
      --
      Chk_Root_Cat
      (p_business_group_id     =>     p_rec.business_group_id
      );
      --
    End If;
    --
    Chk_Parent_Category_Dates
    (p_parent_cat_usage_id      =>     p_rec.parent_cat_usage_id
    ,p_start_date               =>     p_rec.start_date_active
    ,p_end_date                 =>     p_rec.end_date_active
    );
    --
  End If;
  --
  Chk_online_flag
  (p_online_flag              =>     p_rec.online_flag
  ,p_type             	      =>     p_rec.type
  );
  --
  --
  Chk_synchronous_flag
  (p_synchronous_flag         =>     p_rec.synchronous_flag
  ,p_type             	      =>     p_rec.type
  );
  --
  --
  Chk_start_end_dates
  (p_start_date               =>     p_rec.start_date_active
  ,p_end_date                 =>     p_rec.end_date_active
  );
  --
   -- Bug 3456546 : dff available only for Category : type = C
      if p_rec.type = 'C' then
          ota_ctu_bus.chk_df(p_rec);
      end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_ctu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_ctu_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  -- Validating category name to be unique
  --
    Chk_unique_category
    (p_category_usage_id     =>      p_rec.category_usage_id
    ,p_category              =>      p_rec.category
    ,p_business_group_id     =>	     p_rec.business_group_id
    ,p_type                  =>	     p_rec.type
    ,p_parent_cat_usage_id   =>      p_rec.parent_cat_usage_id
    );
  --
  --
  -- Validating parent category for type category only
  IF p_rec.type = 'C' THEN
    ota_ctu_bus.Chk_valid_parent_category
    (p_parent_cat_usage_id      =>     p_rec.parent_cat_usage_id
    ,p_category_usage_id        =>     p_rec.category_usage_id
    );
  END IF;
  --
  --
  Chk_start_end_dates
  (p_start_date               =>     p_rec.start_date_active
  ,p_end_date                 =>     p_rec.end_date_active
  );
  --
  IF p_rec.type = 'C' THEN
    --
    Chk_Parent_Category_Dates
    (p_parent_cat_usage_id      =>     p_rec.parent_cat_usage_id
    ,p_start_date               =>     p_rec.start_date_active
    ,p_end_date                 =>     p_rec.end_date_active
    );
    --
    Chk_Act_Start_End_Date
    (p_category_usage_id        =>     p_rec.category_usage_id
    ,p_start_date               =>     p_rec.start_date_active
    ,p_end_date                 =>     p_rec.end_date_active
    );
   --
   Chk_lp_Start_End_Date
    (p_category_usage_id        =>     p_rec.category_usage_id
    ,p_start_date               =>     p_rec.start_date_active
    ,p_end_date                 =>     p_rec.end_date_active
    );
    --
   Chk_Child_Category_Dates
    (p_category_usage_id        =>     p_rec.category_usage_id
    ,p_start_date               =>     p_rec.start_date_active
    ,p_end_date                 =>     p_rec.end_date_active
    );
    --
  End IF;
  --
  IF p_rec.type = 'DM' THEN
    --
    Chk_Off_Start_End_Date
    (p_category_usage_id        =>     p_rec.category_usage_id
    ,p_start_date               =>     p_rec.start_date_active
    ,p_end_date                 =>     p_rec.end_date_active
    );
    --
    IF ( p_rec.online_flag <> ota_ctu_shd.g_old_rec.online_flag
      or p_rec.synchronous_flag <> ota_ctu_shd.g_old_rec.synchronous_flag )THEN
      --
      Chk_Sync_Online_Flag
      (p_category_usage_id     =>   p_rec.category_usage_id
      ,p_online_flag           =>   p_rec.online_flag
      ,p_synchronous_flag      =>   p_rec.synchronous_flag
       );
      --
    End IF;
    --
  End IF;
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
      -- Bug 3456546 : dff available only for Category : type = C
         if p_rec.type = 'C' then
            ota_ctu_bus.chk_df(p_rec);
	 end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_ctu_shd.g_rec_type
  ) is
--
  CURSOR cur_category_type is
    select
      ctu.type
    From
      ota_category_usages  ctu
    where
      ctu.category_usage_id = p_rec.category_usage_id;
--
  l_proc  varchar2(72) := g_package||'delete_validate';
  l_cat_type varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
     OPEN cur_category_type;
     FETCH cur_category_type into l_cat_type;
     CLOSE cur_category_type;

  --
  -- check for child category and Activity Association for type Category only
  IF l_cat_type = 'C' THEN
    Chk_child_category
    (p_category_usage_id        =>     p_rec.category_usage_id
    );
  --
    Chk_act_association
    (p_category_usage_id        =>     p_rec.category_usage_id
    );
  --
    Chk_lp_association
    (p_category_usage_id        =>     p_rec.category_usage_id
    );
  --
    Chk_act_def_for_org_tp
    (p_category_usage_id        =>     p_rec.category_usage_id
    );
  --
  -- check for offering Association for type Delivery Mode only
  ELSIF l_cat_type = 'DM' THEN
  --
    Chk_offering_association
    (p_category_usage_id        =>     p_rec.category_usage_id
    );
  --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
-- ----------------------------------------------------------------------------
-- |---------------------< Chk_valid_parent_category >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_valid_parent_category
  (p_parent_cat_usage_id           in     number
  ,p_category_usage_id             in     number
  )

  is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_parent_categories is
  select
      '1' Cat_exists
    From
      ota_category_usages  ctu1
    where
      ctu1.category_usage_id = p_category_usage_id
      and ctu1.category_usage_id in
      	(select
      		ctu2.parent_cat_usage_id
      	 From
      	 	ota_category_usages ctu2
           connect by ctu2.category_usage_id = prior ctu2.parent_cat_usage_id
           start with ctu2.category_usage_id = p_parent_cat_usage_id
         );


  l_proc                    varchar2(72) := g_package||'Chk_valid_parent_category';
  l_cat_flag                varchar2(10);
  l_result                  boolean := FALSE;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --

    IF (p_category_usage_id = p_parent_cat_usage_id) THEN
  	fnd_message.set_name      ( 'OTA'     ,'OTA_443200_CTU_CHILD_EXITS');
  	fnd_message.raise_error;
    ELSE

      OPEN cur_parent_categories;
      FETCH cur_parent_categories into l_cat_flag;

      IF cur_parent_categories%FOUND then
        CLOSE cur_parent_categories;
        fnd_message.set_name      ( 'OTA'     ,'OTA_443200_CTU_CHILD_EXITS');
  	    fnd_message.raise_error;
      ELSE
        CLOSE cur_parent_categories;
      END IF;
   END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES_TL.CATEGORY'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_valid_parent_category;
--
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_child_category >----------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_child_category
  (p_category_usage_id            in            number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_child_categories is
    select
      distinct 'found'
    From
      ota_category_usages  ctu
    where
      parent_cat_usage_id = p_category_usage_id;

  -- Variables for API Boolean parameters
  l_proc    varchar2(72) := g_package ||'Chk_child_category';
  l_cat_flag                varchar2(10);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_child_categories;
     FETCH cur_child_categories into l_cat_flag;

     IF cur_child_categories%FOUND then
        CLOSE cur_child_categories;
  	fnd_message.set_name      ( 'OTA' ,'OTA_443273_CTU_CHLD_CAT_EXISTS');
  	fnd_message.raise_error;
     ELSE
        CLOSE cur_child_categories;
     END IF;

  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
  --

Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.CATEGORY'
                 ,p_same_associated_columns  => 'Y'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --

End Chk_child_category;
--
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_act_association >----------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_act_association
  (p_category_usage_id            in            number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_cat_activities is
    select
      distinct 'found'
    From
      ota_act_cat_inclusions  cti
    where
      cti.category_usage_id = p_category_usage_id;

  -- Variables for API Boolean parameters
  l_proc    varchar2(72) := g_package ||'Chk_act_association';
  l_act_flag                varchar2(10);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_cat_activities;
     FETCH cur_cat_activities into l_act_flag;

     IF cur_cat_activities%FOUND then
        CLOSE cur_cat_activities;
  	fnd_message.set_name      ( 'OTA'     ,'OTA_443272_CTU_ACT_EXISTS');
  	fnd_message.raise_error;
     ELSE
        CLOSE cur_cat_activities;
     END IF;

  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.CATEGORY'
                 ,p_same_associated_columns  => 'Y'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_act_association;
--
-- ----------------------------------------------------------------------------
-- |---------------------< Chk_offering_association >-------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_offering_association
  (p_category_usage_id            in            number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_dm_offerings is
    select 'Y'
     From ota_offerings  off
    where off.delivery_mode_id = p_category_usage_id;

  -- Variables for API Boolean parameters
  l_proc    varchar2(72) := g_package ||'Chk_offering_association';
  l_off_flag                varchar2(10);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_dm_offerings;
     FETCH cur_dm_offerings into l_off_flag;

     IF cur_dm_offerings%FOUND then
        CLOSE cur_dm_offerings;
  	fnd_message.set_name      ( 'OTA'     ,'OTA_443271_CTU_OFF_EXISTS');
  	fnd_message.raise_error;
     ELSE
        CLOSE cur_dm_offerings;
     END IF;

  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
  --
End Chk_offering_association;
--
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_online_flag >----------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_online_flag
  (p_online_flag                  in     varchar2
  ,p_type                         in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category
  --
  l_proc    varchar2(72) := g_package ||'Chk_online_flag';

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

  IF p_type = 'DM' THEN
    IF p_online_flag is null THEN
      fnd_message.set_name      ( 'OTA'     ,'OTA_443268_CTU_ONLINE_FLAG');
      fnd_message.raise_error;
    END IF;
  END IF;

  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
  --
Exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.ONLINE_FLAG'
                 ) then
            hr_utility.set_location(' Leaving:'|| l_proc,20);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| l_proc,30);
End Chk_online_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_synchronous_flag >----------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_synchronous_flag
  (p_synchronous_flag                  in     varchar2
  ,p_type                         in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category
  --
  l_proc    varchar2(72) := g_package ||'Chk_synchronous_flag';

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

  IF p_type = 'DM' THEN
    IF p_synchronous_flag is null THEN
      fnd_message.set_name      ( 'OTA'     ,'OTA_443268_CTU_ONLINE_FLAG');
      fnd_message.raise_error;
    END IF;
  END IF;

  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
  --
Exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.SYNCHRONOUS_FLAG'
                 ) then
            hr_utility.set_location(' Leaving:'|| l_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| l_proc,80);
End Chk_synchronous_flag;
 --

-- ----------------------------------------------------------------------------
-- ---------------------------< Chk_start_end_dates >-------------------------|
-- ----------------------------------------------------------------------------
--
--	The start date must be less than, or equal to, the end date.
--
Procedure Chk_start_end_dates
  (p_start_date                         in date
  ,p_end_date                           in date
  ) is
  --
  l_proc                                        varchar2 (72)
        := g_package || 'Chk_start_end_dates';
  --
  --
  --
begin
  --
  hr_utility.set_location ('entering:' || l_proc, 5);
  --
  if (p_start_date
        > nvl (p_end_date, to_date ('31-12-4712', 'DD-MM-YYYY'))) then

  	fnd_message.set_name      ( 'OTA' ,'OTA_13312_GEN_DATE_ORDER');
  	fnd_message.raise_error;

  end if;
  --
  hr_utility.set_location (' leaving:' || l_proc, 10);
--
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.START_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --

End Chk_start_end_dates;
 --
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_lp_association >----------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_lp_association
  (p_category_usage_id            in            number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_cat_learning_paths is
    select
      distinct 'found'
    From
      ota_lp_cat_inclusions  lci
    where
      lci.category_usage_id = p_category_usage_id;

  -- Variables for API Boolean parameters
  l_proc    varchar2(72) := g_package ||'Chk_lp_association';
  l_lp_flag                varchar2(10);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_cat_learning_paths;
     FETCH cur_cat_learning_paths into l_lp_flag;

     IF cur_cat_learning_paths%FOUND then
        CLOSE cur_cat_learning_paths;
  	fnd_message.set_name      ( 'OTA'     ,'OTA_443350_CTU_LP_EXISTS');
  	fnd_message.raise_error;
     ELSE
        CLOSE cur_cat_learning_paths;
     END IF;

  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.CATEGORY'
                 ,p_same_associated_columns  => 'Y'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_lp_association;
--
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_act_def_for_org_tp >--------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_act_def_for_org_tp
  (p_category_usage_id            in            number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_act_def_org_tp is
    select
      distinct tad.name
    From
      ota_training_plan_members tpm,
      ota_activity_definitions_vl tad,
      ota_category_usages ctu
    where
      ctu.category_usage_id = tad.category_usage_id
      and tad.activity_id = tpm.activity_definition_id
      and ctu.category_usage_id = p_category_usage_id;

  -- Variables for API Boolean parameters
  l_proc          varchar2(72) := g_package ||'Chk_act_def_for_org_tp';
  l_act_def_name  varchar2(240);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_act_def_org_tp;
     FETCH cur_act_def_org_tp into l_act_def_name;

     IF cur_act_def_org_tp%FOUND then
        CLOSE cur_act_def_org_tp;
  	fnd_message.set_name      ( 'OTA','OTA_443097_CAT_TP_EXISTS');
        fnd_message.set_token('ACT_DEF_NAME', l_act_def_name);
  	fnd_message.raise_error;
     ELSE
        CLOSE cur_act_def_org_tp;
     END IF;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CATEGORY_USAGES.CATEGORY'
                 ,p_same_associated_columns  => 'Y'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_act_def_for_org_tp;
--
end ota_ctu_bus;

/
