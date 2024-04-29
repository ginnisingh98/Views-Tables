--------------------------------------------------------
--  DDL for Package Body PQH_PSU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PSU_BUS" as
/* $Header: pqpsurhi.pkb 120.0 2005/05/29 02:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_psu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_emp_stat_situation_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_statutory_situation_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqh_fr_stat_situations sts
     where
      sts.statutory_situation_id = p_statutory_situation_id
      and pbg.business_group_id = sts.business_group_id;
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
    ,p_argument           => 'statutory_situation_id'
    ,p_argument_value     => p_statutory_situation_id
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
        => nvl(p_associated_column1,'STATUTORY_SITUATION_ID')
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
  (p_emp_stat_situation_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , pqh_fr_emp_stat_situations psu
         , pqh_fr_stat_situations sts
     where psu.emp_stat_situation_id = p_emp_stat_situation_id
       and psu.statutory_situation_id = sts.statutory_situation_id
       and pbg.business_group_id = sts.business_group_id;
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
    ,p_argument           => 'emp_stat_situation_id'
    ,p_argument_value     => p_emp_stat_situation_id
    );
  --
  if ( nvl(pqh_psu_bus.g_emp_stat_situation_id, hr_api.g_number)
       = p_emp_stat_situation_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_psu_bus.g_legislation_code;
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
    pqh_psu_bus.g_emp_stat_situation_id       := p_emp_stat_situation_id;
    pqh_psu_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pqh_psu_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.emp_stat_situation_id is not null)  and (
    nvl(pqh_psu_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(pqh_psu_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.emp_stat_situation_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQH'
      ,p_descflex_name                   => 'ADDL_EMP_SITUATION_INFO'
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
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
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
  ,p_rec in pqh_psu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_psu_shd.api_updating
      (p_emp_stat_situation_id             => p_rec.emp_stat_situation_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
	  if nvl(p_rec.statutory_situation_id, hr_api.g_number) <>
	     nvl(pqh_psu_shd.g_old_rec.statutory_situation_id
	        ,hr_api.g_number
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'STATUTORY_SITUATION_ID'
	      ,p_base_table => pqh_psu_shd.g_tab_nam
	      );
	  end if;
	  if nvl(p_rec.person_id, hr_api.g_number) <>
	     nvl(pqh_psu_shd.g_old_rec.person_id
	        ,hr_api.g_number
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'PERSON_ID'
	      ,p_base_table => pqh_psu_shd.g_tab_nam
	      );
	  end if;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id >------------------------------|
-- ----------------------------------------------------------------------------
Procedure   chk_person_id(p_person_id IN NUMBER) IS
CURSOR csr_valid_emp(p_person_id IN NUMBER) IS
 SELECT 'X'
 FROM   per_all_people_f
 WHERE  person_id = p_person_id
 AND    TRUNC(SYSDATE) between effective_start_date and effective_end_date
 AND    PER_INFORMATION15 = '01'
 AND    current_employee_flag = 'Y';
 l_valid_emp varchar2(10);
BEGIN
OPEN csr_valid_emp(p_person_id);
FETCH csr_valid_emp INTO l_valid_emp;
IF csr_valid_emp%NOTFOUND THEN
  fnd_message.set_name('PQH','FR_PQH_STAT_SIT_INVALID_EMP');
  hr_multi_message.add
         (p_associated_column1
          => 'PERSON_ID'
         );
END IF;
CLOSE csr_valid_emp;
END;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_statutory_situation >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_statutory_situation(p_statutory_situation_id IN NUMBER) IS
  CURSOR csr_valid_stat_sit(p_statutory_situation_id IN NUMBER) IS
  SELECT 'X'
  FROM   pqh_fr_stat_situations
  WHERE  statutory_situation_id = p_statutory_situation_id
  AND    TRUNC(SYSDATE) BETWEEN date_from and NVL(date_to,TRUNC(SYSDATE));
  l_valid_sit varchar2(10);
BEGIN
  OPEN csr_valid_stat_sit(p_statutory_situation_id);
  FETCH csr_valid_stat_sit INTO l_valid_sit;
  IF csr_valid_stat_sit%NOTFOUND THEN
    fnd_message.set_name('PQH','FR_PQH_STAT_SIT_INVALID_SIT');
    hr_multi_message.add
           (p_associated_column1
            =>'STATUTORY_SITUATION_ID'
           );
  END IF;
  CLOSE csr_valid_stat_sit;
END;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_renew_situation >--------------------------|
-- ----------------------------------------------------------------------------
/* deenath - This procedure has been replaced by new procedure having same name.
             The new procedure is listed immediately after this commented block.
  PROCEDURE chk_renew_situation(p_rec IN pqh_psu_shd.g_rec_type) IS
  --
  --Cursor to fetch Renew Details for the Situation Id.
    CURSOR csr_renew_dtls IS
    SELECT frequency,
           NVL(renewable_allowed,'N'),
           NVL(max_no_of_renewals,0),
           NVL(max_duration_per_renewal,0),
           NVL(max_tot_continuous_duration,0)
      FROM pqh_fr_stat_situations
     WHERE statutory_situation_id = p_rec.statutory_situation_id;
  --
  --Cursor to fetch continous renewal duration,
    CURSOR csr_cont_renewals(p_date DATE) IS
    SELECT NVL(actual_start_date,provisional_start_date),
           NVL(actual_end_date,provisional_end_date)-NVL(actual_start_date,provisional_start_date) days
      FROM pqh_fr_emp_stat_situations
     WHERE person_id              = p_rec.person_id
       AND statutory_situation_id = p_rec.statutory_situation_id
       AND emp_stat_situation_id <> NVL(p_rec.emp_stat_situation_id,-1)
       AND((NVL(renewal_flag,'N') = 'N' AND emp_stat_situation_id   = p_rec.renew_stat_situation_id)
        OR (NVL(renewal_flag,'N') = 'Y' AND renew_stat_situation_id = p_rec.renew_stat_situation_id))
       AND TRUNC(NVL(actual_end_date,provisional_end_date)) = TRUNC(p_date);
  --
  --Variable Declarations.
    l_renewable         VARCHAR2(10);
    l_freq              VARCHAR2(10);
    l_max_renewals      NUMBER(10) := 0;
    l_no_of_renewals    NUMBER(10) := 0;
    l_max_dur_per_renew NUMBER(10) := 0;
    l_max_tot_cont_dur  NUMBER(10) := 0;
    l_day_factor        NUMBER(10) := 0;
    l_date              DATE;
    l_days              NUMBER(10) := 0;
    l_cont_days         NUMBER(10) := 0;
    l_duration_days     NUMBER(10) := 0;
  --
  BEGIN
  --
    IF p_rec.renewal_flag = 'Y' THEN
     --
       OPEN csr_renew_dtls;
       FETCH csr_renew_dtls INTO l_freq, l_renewable, l_max_renewals, l_max_dur_per_renew, l_max_tot_cont_dur;
       CLOSE csr_renew_dtls;
     --
       IF l_renewable = 'N' THEN
          FND_MESSAGE.set_name('PQH','FR_PQH_STAT_SIT_NOT_RENEWABLE');
          HR_MULTI_MESSAGE.add;
       END IF;
     --
       l_no_of_renewals := pqh_fr_stat_sit_util.get_num_renewals(p_rec.emp_stat_situation_id,p_rec.renew_stat_situation_id);
     --
       IF l_no_of_renewals >= l_max_renewals THEN
          FND_MESSAGE.set_name('PQH','FR_PQH_MAX_RENEWALS_REACHED');
          HR_MULTI_MESSAGE.add;
       END IF;
    --
      IF l_freq = 'BM' THEN
         l_day_factor := 60;
      ELSIF l_freq = 'CM' THEN
         l_day_factor := 30;
      ELSIF l_freq = 'F' THEN
         l_day_factor := 14;
      ELSIF l_freq = 'LM' THEN
         l_day_factor := 15;
      ELSIF l_freq = 'Q' THEN
         l_day_factor := 90;
      ELSIF l_freq = 'SM' THEN
         l_day_factor := 15;
      ELSIF l_freq = 'SY' THEN
         l_day_factor := 182;
      ELSIF l_freq = 'W' THEN
         l_day_factor := 7;
      ELSIF l_freq = 'Y' THEN
         l_day_factor := 365;
      END IF;
    --
      l_duration_days := p_rec.provisional_end_date - p_rec.provisional_start_date;
    --
      IF l_duration_days > (l_max_dur_per_renew*l_day_factor) THEN
         FND_MESSAGE.set_name ('PQH','FR_PQH_RENEW_OUT_OF_MAX_RANGE');
         HR_MULTI_MESSAGE.add;
      END IF;
    --
      l_date := p_rec.provisional_start_date;
      WHILE l_date IS NOT NULL
      LOOP
          OPEN csr_cont_renewals(l_date-1);
          FETCH csr_cont_renewals INTO l_date,l_days;
          IF csr_cont_renewals%FOUND THEN
             l_cont_days := l_cont_days + l_days;
          END IF;
          IF csr_cont_renewals%NOTFOUND THEN
             l_date := NULL;
          END IF;
          CLOSE csr_cont_renewals;
      END LOOP;
    --
      IF (l_duration_days+NVL(l_cont_days,0)) > (l_max_tot_cont_dur*l_day_factor) THEN
         FND_MESSAGE.set_name ('PQH', 'FR_PQH_RENEW_TOT_CONT_RANGE');
         HR_MULTI_MESSAGE.add;
      END IF;
    --
    END IF;
  --
  END;
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_renew_situation >--------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE chk_renew_situation(p_rec IN pqh_psu_shd.g_rec_type) IS
  --
  --Cursor to fetch Renew Details for the Situation Id.
    CURSOR csr_renew_dtls IS
    SELECT frequency,
           NVL(renewable_allowed,'N'),
           max_no_of_renewals,
           max_duration_per_renewal,
           max_tot_continuous_duration
      FROM pqh_fr_stat_situations
     WHERE statutory_situation_id = p_rec.statutory_situation_id;
  --
  --Cursor to fetch continous renewal duration,
    CURSOR csr_cont_renewals(p_date DATE) IS
    SELECT NVL(actual_start_date,provisional_start_date),
           (NVL(actual_end_date,provisional_end_date)-NVL(actual_start_date,provisional_start_date)+1) days
      FROM pqh_fr_emp_stat_situations
     WHERE person_id              = p_rec.person_id
       AND statutory_situation_id = p_rec.statutory_situation_id
       AND emp_stat_situation_id <> NVL(p_rec.emp_stat_situation_id,-1)
       AND((NVL(renewal_flag,'N') = 'N' AND emp_stat_situation_id   = p_rec.renew_stat_situation_id)
        OR (NVL(renewal_flag,'N') = 'Y' AND renew_stat_situation_id = p_rec.renew_stat_situation_id))
       AND TRUNC(NVL(actual_end_date,provisional_end_date)) = TRUNC(p_date);
  --
  --Variable Declarations.
    l_renewable         VARCHAR2(10);
    l_freq              VARCHAR2(10);
    l_max_renewals      NUMBER(10);
    l_no_of_renewals    NUMBER(10);
    l_max_dur_per_renew NUMBER(10);
    l_max_tot_cont_dur  NUMBER(10);
    l_day_factor        NUMBER(10);
    l_date              DATE;
    l_days              NUMBER(10);
    l_cont_days         NUMBER(10);
    l_duration_days     NUMBER(10);
    l_start_date        DATE;
    l_mdpr              DATE;
    l_mtcd              DATE;
  --
  BEGIN
  --
    IF NVL(p_rec.renewal_flag,'N') = 'Y' THEN
     --
       OPEN csr_renew_dtls;
       FETCH csr_renew_dtls INTO l_freq, l_renewable, l_max_renewals, l_max_dur_per_renew, l_max_tot_cont_dur;
       CLOSE csr_renew_dtls;
     --
       IF l_renewable = 'N' THEN
          FND_MESSAGE.set_name('PQH','FR_PQH_STAT_SIT_NOT_RENEWABLE');
          FND_MESSAGE.raise_error;--HR_MULTI_MESSAGE.add;
       END IF;
     --
       l_no_of_renewals := pqh_fr_stat_sit_util.get_num_renewals(p_rec.emp_stat_situation_id,p_rec.renew_stat_situation_id);
     --
       IF l_max_renewals IS NOT NULL AND NVL(l_no_of_renewals,0) >= l_max_renewals THEN
          FND_MESSAGE.set_name('PQH','FR_PQH_MAX_RENEWALS_REACHED');
          FND_MESSAGE.raise_error;--HR_MULTI_MESSAGE.add;
       END IF;
     --
       l_start_date := TRUNC(NVL(p_rec.actual_start_date,p_rec.provisional_start_date));
     --
       IF l_freq = 'Y' THEN
          l_mdpr    := TRUNC(ADD_MONTHS(l_start_date,l_max_dur_per_renew*12));
          l_mtcd    := TRUNC(ADD_MONTHS(l_start_date,l_max_tot_cont_dur*12));
       ELSIF l_freq = 'SY' THEN
          l_mdpr    := TRUNC(ADD_MONTHS(l_start_date,l_max_dur_per_renew*6));
          l_mtcd    := TRUNC(ADD_MONTHS(l_start_date,l_max_tot_cont_dur*6));
       ELSIF l_freq = 'Q' THEN
          l_mdpr    := TRUNC(ADD_MONTHS(l_start_date,l_max_dur_per_renew*3));
          l_mtcd    := TRUNC(ADD_MONTHS(l_start_date,l_max_tot_cont_dur*3));
       ELSIF l_freq = 'BM' THEN
          l_mdpr    := TRUNC(ADD_MONTHS(l_start_date,l_max_dur_per_renew*2));
          l_mtcd    := TRUNC(ADD_MONTHS(l_start_date,l_max_tot_cont_dur*2));
       ELSIF l_freq = 'CM' THEN
          l_mdpr    := TRUNC(ADD_MONTHS(l_start_date,l_max_dur_per_renew));
          l_mtcd    := TRUNC(ADD_MONTHS(l_start_date,l_max_tot_cont_dur));
       ELSIF l_freq = 'LM' THEN
          l_mdpr    := TRUNC(l_start_date+(l_max_dur_per_renew*28));
          l_mtcd    := TRUNC(l_start_date+(l_max_tot_cont_dur*28));
       ELSIF l_freq = 'F' THEN
          l_mdpr    := TRUNC(l_start_date+(l_max_dur_per_renew*14));
          l_mtcd    := TRUNC(l_start_date+(l_max_tot_cont_dur*14));
       ELSIF l_freq = 'W' THEN
          l_mdpr    := TRUNC(l_start_date+(l_max_dur_per_renew*7));
          l_mtcd    := TRUNC(l_start_date+(l_max_tot_cont_dur*7));
       ELSIF l_freq = 'SM' THEN
          l_mdpr := l_start_date;
          FOR i IN 1..NVL(l_max_dur_per_renew,0)
          LOOP
              l_mdpr := TRUNC(l_mdpr+TRUNC(((ADD_MONTHS(l_mdpr,1)-l_mdpr)/2)));
          END LOOP;
        --
          l_mtcd := l_start_date;
          FOR i IN 1..NVL(l_max_tot_cont_dur,0)
          LOOP
              l_mtcd := TRUNC(l_mtcd+TRUNC(((ADD_MONTHS(l_mtcd,1)-l_mtcd)/2)));
          END LOOP;
        --
       ELSE
          l_mdpr := HR_GENERAL.end_of_time;
          l_mtcd := HR_GENERAL.end_of_time;
       END IF;
     --
       IF NVL(l_mdpr,l_start_date) = l_start_date THEN
          l_mdpr := HR_GENERAL.end_of_time;
       END IF;
     --
       IF NVL(l_mtcd,l_start_date) = l_start_date THEN
          l_mtcd := HR_GENERAL.end_of_time;
       END IF;
     --
       IF l_max_dur_per_renew IS NOT NULL AND NVL(p_rec.actual_end_date,p_rec.provisional_end_date) >= l_mdpr THEN
          FND_MESSAGE.set_name ('PQH','FR_PQH_RENEW_OUT_OF_MAX_RANGE');
          FND_MESSAGE.raise_error;--HR_MULTI_MESSAGE.add;
       END IF;
     --
       l_cont_days := 0;
       l_date      := p_rec.provisional_start_date;
       WHILE l_date IS NOT NULL
       LOOP
           OPEN csr_cont_renewals(l_date-1);
           FETCH csr_cont_renewals INTO l_date,l_days;
           IF csr_cont_renewals%FOUND THEN
              l_cont_days := l_cont_days+l_days;
           END IF;
           IF csr_cont_renewals%NOTFOUND THEN
              l_date := NULL;
           END IF;
           CLOSE csr_cont_renewals;
       END LOOP;
     --
     --Use (l_mtcd-1) because l_mtcd calculation adds one more day.
       IF l_max_tot_cont_dur IS NOT NULL AND
         (TRUNC(NVL(p_rec.actual_end_date,p_rec.provisional_end_date)+NVL(l_cont_days,0)) > (l_mtcd-1)) THEN
          FND_MESSAGE.set_name ('PQH', 'FR_PQH_RENEW_TOT_CONT_RANGE');
          FND_MESSAGE.raise_error;--HR_MULTI_MESSAGE.add;
       END IF;
     --
    END IF;
  --
  END chk_renew_situation;
--
-- ---------------------------------------------------------------------------
-- ------------------------< chk_dates >--------------------------------------
-- --------------------------------------------------------------------------
Procedure chk_dates(p_person_id in NUMBER,
                    p_statutory_situation_id IN NUMBER,
                    p_provisional_start_date IN Date,
                    p_provisional_end_date IN Date )
IS
--
Cursor csr_person_info IS
Select original_date_of_hire
from per_all_people_f
where person_id = p_person_id
and trunc(sysdate) between effective_start_date and effective_end_date;
--
Cursor csr_situation_info IS
Select nvl(date_to,hr_general.end_of_time)
from pqh_fr_stat_situations
where statutory_situation_id = p_statutory_situation_id;
l_original_hire_date date;
l_situ_end_date date;
Begin
 --
     if (p_provisional_start_date > p_provisional_end_date ) then
      --
         fnd_message.set_name('PQH','PQH_FR_NO_GRT_STARTDT');
         hr_multi_message.add();
     --
    End If;
    Open csr_person_info;
      Fetch csr_person_info into l_original_hire_date;
    Close csr_person_info;
    If (p_provisional_start_date< l_original_hire_date ) Then
    --
        fnd_message.set_name('PQH','PQH_FR_NOSIT_BFOR_HIREDT');
        hr_multi_message.add();
    --
   End If;
   Open csr_situation_info;
    Fetch csr_situation_info into l_situ_end_date;
   Close csr_situation_info;
   If (p_provisional_end_date > l_situ_end_date ) Then
   --
       fnd_message.set_name('PQH','PQH_FR_SITU_ENDDT_IS_LESS');
       hr_multi_message.add;
   --
  End If;
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_situation_dates >----------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE chk_situation_dates(p_rec IN pqh_psu_shd.g_rec_type)
  IS
  --
    CURSOR csr_default_sit IS
    SELECT 'x' FROM DUAL
     WHERE EXISTS(SELECT statutory_situation_id
                    FROM pqh_fr_stat_situations
                   WHERE statutory_situation_id = p_rec.statutory_situation_id
                     AND situation_type         = 'IA'
                     AND sub_type               = 'IA_N'
                     AND business_group_id      = HR_GENERAL.get_business_group_id
                     AND default_flag           = 'Y'
                     AND TRUNC(SYSDATE)   BETWEEN date_from AND NVL(date_to,HR_GENERAL.end_of_time));
  --
    CURSOR csr_overlap_dates(p_provisional_start     DATE,
                             p_provisional_end       DATE,
                             p_actual_start          DATE,
                             p_actual_end            DATE,
                             p_person_id             NUMBER,
                             p_emp_stat_situation_id NUMBER) IS
    SELECT 'x'
      FROM DUAL
     WHERE EXISTS(SELECT 'x'
                    FROM pqh_fr_emp_stat_situations
                   WHERE person_id                        = p_person_id
                     AND emp_stat_situation_id           <> NVL(p_emp_stat_situation_id,-1)
--                     AND NVL(renew_stat_situation_id,-2) <> NVL(p_emp_stat_situation_id,-1)    --commented by deenath
                     AND statutory_situation_id          <>
                        (SELECT statutory_situation_id
                           FROM pqh_fr_stat_situations_v sit,
                                per_shared_types_vl sh
                          WHERE sh.shared_type_id     = type_of_ps
                            AND sh.system_type_cd     = NVL(PQH_FR_UTILITY.get_bg_type_of_ps,sh.system_type_cd)
                            AND sit.business_group_id = HR_GENERAL.get_business_group_id
                            AND sit.default_flag      = 'Y'
                            AND sit.situation_type    = 'IA'
                            AND sit.sub_type          = 'IA_N'
                            AND TRUNC(SYSDATE) BETWEEN date_from AND NVL(date_to,HR_GENERAL.end_of_time))
       AND(NVL(p_actual_start,p_provisional_start) BETWEEN NVL(actual_start_date,provisional_start_date)
                                                       AND NVL(actual_end_date,NVL(provisional_end_date,hr_general.end_of_time))
        OR NVL(p_actual_end,p_provisional_end)     BETWEEN NVL(actual_end_date,provisional_end_date)
                                                       AND NVL(actual_end_date,NVL(provisional_end_date,hr_general.end_of_time))));
  --
    l_default_sit VARCHAR2(10);
    l_valid       VARCHAR2(10);
  --
  BEGIN
  --
    IF (p_rec.renew_stat_situation_id IS NOT NULL) THEN
       RETURN;
    END IF;
  --
    IF p_rec.emp_stat_situation_id IS NOT NULL THEN
       OPEN csr_default_sit;
       FETCH csr_default_sit INTO l_default_sit;
       IF csr_default_sit%FOUND THEN
          CLOSE csr_default_sit;
          RETURN; --Return because we dont want to check overlaps if Sit being created/updated is Default In Activity Normal Situation
       END IF;
       IF csr_default_sit%ISOPEN THEN
          CLOSE csr_default_sit;
       END IF;
    END IF;
  --
    OPEN csr_overlap_dates(p_rec.provisional_start_date,p_rec.provisional_end_date,
                           p_rec.actual_start_date,p_rec.actual_end_date,
                           p_rec.person_id,p_rec.emp_stat_situation_id);
    FETCH csr_overlap_dates INTO l_valid;
    IF csr_overlap_dates%FOUND THEN
       CLOSE csr_overlap_dates;
       FND_MESSAGE.set_name('PQH','FR_PQH_STAT_SIT_OVERLAP_DATES');
       HR_MULTI_MESSAGE.add(p_associated_column1 => 'PROVISIONAL_START_DATE'
                           ,p_associated_column2 => 'PROVISIONAL_END_DATE'
                           ,p_associated_column3 => 'ACTUAL_START_DATE'
                           ,p_associated_column4 => 'ACTUAL_END_DATE');
    END IF;
    IF csr_overlap_dates%ISOPEN THEN
       CLOSE csr_overlap_dates;
    END IF;
  --
  END chk_situation_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_contact_details >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_contact_details(p_rec IN pqh_psu_shd.g_rec_type) IS
 CURSOR csr_contact_dtls(p_contact_person_id NUMBER,
                         p_person_id NUMBER,
                         p_contact_relationship VARCHAR2) IS
   SELECT date_start,date_end
   FROM   per_contact_relationships
   WHERE  contact_person_id = p_contact_person_id
   AND    person_id = p_person_id
   AND    contact_type = p_contact_relationship;
 lr_contact csr_contact_dtls%ROWTYPE;
BEGIN
    If (p_rec.contact_person_id IS NOT NULL and p_rec.contact_relationship IS NOT NULL) Then
   --
   OPEN  Csr_contact_dtls(p_rec.contact_person_id, p_rec.person_id,p_rec.contact_relationship);
   FETCH csr_contact_dtls INTO lr_contact.date_start, lr_contact.date_end;
   IF csr_contact_dtls%NOTFOUND THEN
    CLOSE csr_contact_dtls;
    fnd_message.set_name('PQH','FR_PQH_STAT_SIT_INVALID_CNTCT');
    hr_multi_message.add
           (p_associated_column1
            => 'CONTACT_PERSON_ID'
           ,p_associated_column2
            => 'CONTACT_RELATIONSHIP'
           );
   END IF;
   IF csr_contact_dtls%ISOPEN THEN
     CLOSE csr_contact_dtls;
   END IF;
   End If;
END;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_duration_date >-------------------------------|
-- ----------------------------------------------------------------------------
/* deenath - This procedure has been replaced by new procedure having same name.
             The new procedure is listed immediately after this commented block.
  PROCEDURE chk_duration_date(p_rec IN pqh_psu_shd.g_rec_type)
  IS
  --
  --Cursor to check if Situation exists for Person. Modified by deenath added emp_stat_sit clause.
    CURSOR csr_emp_stat_situation IS
    SELECT 'X' x
      FROM pqh_fr_emp_stat_situations
     WHERE person_id              = p_rec.person_id
       AND emp_stat_situation_id <> NVL(p_rec.emp_stat_situation_id,-1)
       AND statutory_situation_id = p_rec.statutory_situation_id;
  --
  --Cursor to get Situation Durations.
    CURSOR csr_stat_situation IS
    SELECT frequency,
           first_period_max_duration,
           min_duration_per_request,
           max_duration_per_request,
           max_duration_whole_career
      FROM pqh_fr_stat_situations
     WHERE statutory_situation_id = p_rec.statutory_situation_id;
  --
  --Cursor to fetch total duration for the person. Modified by deenath added emp_stat_sit clause.
    CURSOR csr_duration_days IS
    SELECT SUM(days) total_duration_days
      FROM(SELECT NVL(actual_end_date,provisional_end_date)-NVL(actual_start_date,provisional_start_date) days
             FROM pqh_fr_emp_stat_situations
            WHERE person_id              = p_rec.person_id
              AND emp_stat_situation_id <> NVL(p_rec.emp_stat_situation_id,-1)
              AND statutory_situation_id = p_rec.statutory_situation_id);
  --
  --Variable Declarations
    lr_previous_exist       csr_emp_stat_situation%ROWTYPE;
    lr_stat_sit_rec         csr_stat_situation%ROWTYPE;
    l_duration_days         NUMBER;
    l_day_factor            NUMBER;
    l_proc                  VARCHAR2(72) := g_package||'chk_duration_date';
    l_total_duration_days   NUMBER;
  --
  BEGIN
  --
    HR_UTILITY.set_location ('Entering:' || l_proc, 5);
  --
    OPEN csr_emp_stat_situation;
    FETCH csr_emp_stat_situation INTO lr_previous_exist;
    CLOSE csr_emp_stat_situation;
  --
    OPEN csr_stat_situation;
    FETCH csr_stat_situation INTO lr_stat_sit_rec;
    CLOSE csr_stat_situation;
  --
    OPEN csr_duration_days;
    FETCH csr_duration_days INTO l_total_duration_days;
    CLOSE csr_duration_days;
  --
  --Codes and its Equalient Days
  --BM - 60
  --CM - 30
  --F  - 14
  --LM - 15
  --Q  - 90
  --SM - 15
  --SY -182
  --W  -  7
  --Y  -365
  --
    IF lr_stat_sit_rec.frequency = 'BM' THEN
       l_day_factor := 60;
    ELSIF lr_stat_sit_rec.frequency = 'CM' THEN
       l_day_factor := 30;
    ELSIF lr_stat_sit_rec.frequency = 'F' THEN
       l_day_factor := 14;
    ELSIF lr_stat_sit_rec.frequency = 'LM' THEN
       l_day_factor := 15;
    ELSIF lr_stat_sit_rec.frequency = 'Q' THEN
       l_day_factor := 90;
    ELSIF lr_stat_sit_rec.frequency = 'SM' THEN
       l_day_factor := 15;
    ELSIF lr_stat_sit_rec.frequency = 'SY' THEN
       l_day_factor := 182;
    ELSIF lr_stat_sit_rec.frequency = 'W' THEN
       l_day_factor := 7;
    ELSIF lr_stat_sit_rec.frequency = 'Y' THEN
       l_day_factor := 365;
    END IF;
  --
    l_duration_days := p_rec.provisional_end_date - p_rec.provisional_start_date;
  --
  --If Situation does not exist.
    IF lr_previous_exist.x IS NULL THEN
       IF l_duration_days > (lr_stat_sit_rec.first_period_max_duration*l_day_factor)  THEN
          FND_MESSAGE.set_name ('PQH','FR_PQH_EXCEEDS_FIRST_DURATION');
          HR_MULTI_MESSAGE.add;
       END IF;
  --If Situation exists.
    ELSIF l_duration_days > (lr_stat_sit_rec.max_duration_per_request*l_day_factor) THEN
       FND_MESSAGE.set_name ('PQH', 'FR_PQH_PERIOD_OUT_OF_MAX_RANGE');
       HR_MULTI_MESSAGE.add;
    END IF;
  --
  --Modified by deenath. Moved below condition out of "If Situation Exists" condition.
    IF l_duration_days < (lr_stat_sit_rec.min_duration_per_request*l_day_factor) THEN
       FND_MESSAGE.set_name ('PQH', 'FR_PQH_PERIOD_OUT_OF_MIN_RANGE');
       HR_MULTI_MESSAGE.add;
    END IF;
  --
    IF l_duration_days+NVL(l_total_duration_days,0) > (lr_stat_sit_rec.max_duration_whole_career*l_day_factor) THEN
       FND_MESSAGE.set_name ('PQH', 'FR_PQH_DURATION_LIMIT_EXCEEDS');
       HR_MULTI_MESSAGE.add;
    END IF;
  --
    HR_UTILITY.set_location ('Leaving: '||l_proc,5);
  --
  END chk_duration_date;
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_duration_date >-------------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE chk_duration_date(p_rec IN pqh_psu_shd.g_rec_type)
  IS
  --
  --Cursor to check if Situation exists for Person. Modified by deenath added emp_stat_sit clause.
    CURSOR csr_emp_stat_situation IS
    SELECT 'Y'
      FROM pqh_fr_emp_stat_situations
     WHERE person_id              = p_rec.person_id
       AND emp_stat_situation_id <> NVL(p_rec.emp_stat_situation_id,-1)
       AND statutory_situation_id = p_rec.statutory_situation_id;
  --
  --Cursor to get Situation Durations.
    CURSOR csr_stat_situation IS
    SELECT situation_type,
           sub_type,
           frequency,
           first_period_max_duration,
           max_duration_whole_career,
           max_duration_per_request,
           min_duration_per_request
      FROM pqh_fr_stat_situations
     WHERE statutory_situation_id = p_rec.statutory_situation_id;
  --
  --Cursor to fetch total duration for the person. Modified by deenath added emp_stat_sit clause.
    CURSOR csr_duration_days IS
    SELECT NVL(SUM(days),0) total_duration_days
      FROM(SELECT (NVL(actual_end_date,provisional_end_date)-NVL(actual_start_date,provisional_start_date)+1) days
             FROM pqh_fr_emp_stat_situations
            WHERE person_id              = p_rec.person_id
              AND emp_stat_situation_id <> NVL(p_rec.emp_stat_situation_id,-1)
              AND statutory_situation_id = p_rec.statutory_situation_id);
  --
  --Variable Declarations
    l_previous_exist        VARCHAR2(01);
    lr_stat_sit_rec         csr_stat_situation%ROWTYPE;
    l_duration_days         NUMBER;
    l_day_factor            NUMBER;
    l_proc                  VARCHAR2(72) := g_package||'chk_duration_date';
    l_total_duration_days   NUMBER;
    l_start_date            DATE;
    l_fpmd                  DATE;
    l_mdwc                  DATE;
    l_max_dpr               DATE;
    l_min_dpr               DATE;
  --
  BEGIN
  --
    HR_UTILITY.set_location ('Entering:' || l_proc, 5);
  --
    OPEN csr_emp_stat_situation;
    FETCH csr_emp_stat_situation INTO l_previous_exist;
    CLOSE csr_emp_stat_situation;
  --
    OPEN csr_stat_situation;
    FETCH csr_stat_situation INTO lr_stat_sit_rec;
    CLOSE csr_stat_situation;
  --
    OPEN csr_duration_days;
    FETCH csr_duration_days INTO l_total_duration_days;
    CLOSE csr_duration_days;
  --
    IF lr_stat_sit_rec.situation_type = 'IA' AND lr_stat_sit_rec.sub_type = 'IA_N' THEN
       RETURN;
    END IF;
  --
    l_start_date := TRUNC(NVL(p_rec.actual_start_date,p_rec.provisional_start_date));
  --
    IF lr_stat_sit_rec.frequency = 'Y' THEN --Year (12 months)
     --
       l_fpmd    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.first_period_max_duration*12));
       l_mdwc    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_whole_career*12));
       l_max_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_per_request*12));
       l_min_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.min_duration_per_request*12));
     --
    ELSIF lr_stat_sit_rec.frequency = 'SY' THEN  --Semi Year (6 months)
     --
       l_fpmd    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.first_period_max_duration*6));
       l_mdwc    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_whole_career*6));
       l_max_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_per_request*6));
       l_min_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.min_duration_per_request*6));
     --
    ELSIF lr_stat_sit_rec.frequency = 'Q' THEN  --Quarter (3 months)
     --
       l_fpmd    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.first_period_max_duration*3));
       l_mdwc    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_whole_career*3));
       l_max_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_per_request*3));
       l_min_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.min_duration_per_request*3));
     --
    ELSIF lr_stat_sit_rec.frequency = 'BM' THEN  --BiMonthly (2 months)
     --
       l_fpmd    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.first_period_max_duration*2));
       l_mdwc    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_whole_career*2));
       l_max_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_per_request*2));
       l_min_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.min_duration_per_request*2));
     --
    ELSIF lr_stat_sit_rec.frequency = 'CM' THEN  --Calendar Month (1 month)
     --
       l_fpmd    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.first_period_max_duration));
       l_mdwc    := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_whole_career));
       l_max_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.max_duration_per_request));
       l_min_dpr := TRUNC(ADD_MONTHS(l_start_date,lr_stat_sit_rec.min_duration_per_request));
     --
    ELSIF lr_stat_sit_rec.frequency = 'LM' THEN  --Lunar Month (28 days)
     --
       l_fpmd    := TRUNC(l_start_date+(lr_stat_sit_rec.first_period_max_duration*28));
       l_mdwc    := TRUNC(l_start_date+(lr_stat_sit_rec.max_duration_whole_career*28));
       l_max_dpr := TRUNC(l_start_date+(lr_stat_sit_rec.max_duration_per_request*28));
       l_min_dpr := TRUNC(l_start_date+(lr_stat_sit_rec.min_duration_per_request*28));
     --
    ELSIF lr_stat_sit_rec.frequency = 'F' THEN  --Bi Weekly (14 days)
     --
       l_fpmd    := TRUNC(l_start_date+(lr_stat_sit_rec.first_period_max_duration*14));
       l_mdwc    := TRUNC(l_start_date+(lr_stat_sit_rec.max_duration_whole_career*14));
       l_max_dpr := TRUNC(l_start_date+(lr_stat_sit_rec.max_duration_per_request*14));
       l_min_dpr := TRUNC(l_start_date+(lr_stat_sit_rec.min_duration_per_request*14));
     --
    ELSIF lr_stat_sit_rec.frequency = 'W' THEN  --Weekly (7 days)
     --
       l_fpmd    := TRUNC(l_start_date+(lr_stat_sit_rec.first_period_max_duration*7));
       l_mdwc    := TRUNC(l_start_date+(lr_stat_sit_rec.max_duration_whole_career*7));
       l_max_dpr := TRUNC(l_start_date+(lr_stat_sit_rec.max_duration_per_request*7));
       l_min_dpr := TRUNC(l_start_date+(lr_stat_sit_rec.min_duration_per_request*7));
     --
    ELSIF lr_stat_sit_rec.frequency = 'SM' THEN  --Semi Month
     --
       l_fpmd := l_start_date;
       FOR i IN 1..NVL(lr_stat_sit_rec.first_period_max_duration,0)
       LOOP
           l_fpmd := TRUNC(l_fpmd+TRUNC(((ADD_MONTHS(l_fpmd,1)-l_fpmd)/2)));
       END LOOP;
     --
       l_mdwc := l_start_date;
       FOR i IN 1..NVL(lr_stat_sit_rec.max_duration_whole_career,0)
       LOOP
           l_mdwc := TRUNC(l_mdwc+TRUNC(((ADD_MONTHS(l_mdwc,1)-l_mdwc)/2)));
       END LOOP;
     --
       l_max_dpr := l_start_date;
       FOR i IN 1..NVL(lr_stat_sit_rec.max_duration_per_request,0)
       LOOP
           l_max_dpr := TRUNC(l_max_dpr+TRUNC(((ADD_MONTHS(l_max_dpr,1)-l_max_dpr)/2)));
       END LOOP;
     --
       l_min_dpr := l_start_date;
       FOR i IN 1..NVL(lr_stat_sit_rec.min_duration_per_request,0)
       LOOP
           l_min_dpr := TRUNC(l_min_dpr+TRUNC(((ADD_MONTHS(l_min_dpr,1)-l_min_dpr)/2)));
       END LOOP;
     --
    ELSE
     --
       l_fpmd    := HR_GENERAL.end_of_time;
       l_min_dpr := l_start_date;
       l_max_dpr := HR_GENERAL.end_of_time;
       l_mdwc    := HR_GENERAL.end_of_time;
     --
    END IF;
  --
    IF NVL(l_fpmd,l_start_date) = l_start_date THEN
       l_fpmd := HR_GENERAL.end_of_time;
    END IF;
  --
    IF NVL(l_mdwc,l_start_date) = l_start_date THEN
       l_mdwc := HR_GENERAL.end_of_time;
    END IF;
  --
    IF NVL(l_max_dpr,l_start_date) = l_start_date THEN
       l_max_dpr := HR_GENERAL.end_of_time;
    END IF;
  --
    IF NVL(l_min_dpr,HR_GENERAL.end_of_time) = HR_GENERAL.end_of_time THEN
       l_min_dpr := l_start_date;
    END IF;
  --
    IF NVL(l_previous_exist,'N') = 'Y' THEN   --If Situation exists.
     --
       IF NVL(p_rec.actual_end_date,p_rec.provisional_end_date) >= l_max_dpr THEN
          FND_MESSAGE.set_name('PQH','FR_PQH_PERIOD_OUT_OF_MAX_RANGE');
          FND_MESSAGE.raise_error;--HR_MULTI_MESSAGE.add;
       END IF;
     --
    ELSE                                      --If Situation does not exist.
     --
       IF NVL(p_rec.actual_end_date,p_rec.provisional_end_date) >= l_fpmd  THEN
          FND_MESSAGE.set_name ('PQH','FR_PQH_EXCEEDS_FIRST_DURATION');
          FND_MESSAGE.raise_error;--HR_MULTI_MESSAGE.add;
       END IF;
     --
    END IF;
  --
  --Use (l_min_dpr-1) because Calculated Date is one day more than valid Minimum Start Date.
    IF NVL(p_rec.actual_end_date,p_rec.provisional_end_date) < TRUNC(l_min_dpr-1) THEN
       FND_MESSAGE.set_name ('PQH','FR_PQH_PERIOD_OUT_OF_MIN_RANGE');
       FND_MESSAGE.raise_error;--HR_MULTI_MESSAGE.add;
    END IF;
  --
  --Use (l_mdwc-1) because Calculated Date is one day more than valid Maximum Duration Whole Career.
    IF TRUNC(NVL(p_rec.actual_end_date,p_rec.provisional_end_date)+NVL(l_total_duration_days,0)) > TRUNC(l_mdwc-1) THEN
       FND_MESSAGE.set_name ('PQH','FR_PQH_DURATION_LIMIT_EXCEEDS');
       FND_MESSAGE.raise_error;--HR_MULTI_MESSAGE.add;
    END IF;
  --
    HR_UTILITY.set_location ('Leaving: '||l_proc,5);
  --
  END chk_duration_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE insert_validate(p_effective_date IN DATE
                           ,p_rec            IN pqh_psu_shd.g_rec_type)
  IS
  --
    l_proc  varchar2(72) := g_package||'insert_validate';
  --
  BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc,5);
  --
  --Call all supporting business operations
    chk_person_id(p_rec.person_id);
    chk_statutory_situation(p_rec.statutory_situation_id);
    chk_renew_situation(p_rec);
    chk_situation_dates(p_rec);
    chk_contact_details(p_rec);
    chk_dates(p_rec.person_id,p_rec.statutory_situation_id,
              p_rec.provisional_start_date,p_rec.provisional_end_date);
    chk_duration_date(p_rec);
  --
    pqh_psu_bus.set_security_group_id(p_rec.statutory_situation_id);
  --
  --Validate Dependent Attributes
    pqh_psu_bus.chk_df(p_rec);
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
  END insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE update_validate(p_effective_date IN DATE
                           ,p_rec            IN pqh_psu_shd.g_rec_type)
  IS
  --
    l_proc  varchar2(72) := g_package||'update_validate';
  --
  BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --Call all supporting business operations
    chk_person_id(p_rec.person_id);
    chk_statutory_situation(p_rec.statutory_situation_id);
    chk_renew_situation(p_rec);  --Added by deenath for Renew duration checks.
    chk_situation_dates(p_rec);
    chk_contact_details(p_rec);
    chk_dates(p_rec.person_id,p_rec.statutory_situation_id,
              p_rec.provisional_start_date,p_rec.provisional_end_date);
    chk_duration_date(p_rec);
  --
    pqh_psu_bus.set_security_group_id(p_rec.statutory_situation_id);
  --
  --Validate Dependent Attributes
    chk_non_updateable_args(p_effective_date => p_effective_date
                           ,p_rec            => p_rec);
  --
    pqh_psu_bus.chk_df(p_rec);
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  END update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE delete_validate(p_rec IN pqh_psu_shd.g_rec_type)
  IS
  --
    l_proc  varchar2(72) := g_package||'delete_validate';
  --
  BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --Call all supporting business operations
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  END delete_validate;
--
end pqh_psu_bus;

/
