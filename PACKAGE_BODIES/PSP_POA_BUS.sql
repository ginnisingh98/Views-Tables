--------------------------------------------------------
--  DDL for Package Body PSP_POA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_POA_BUS" as
/* $Header: PSPOARHB.pls 120.5 2006/09/05 11:10:12 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_poa_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_organization_account_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_organization_account_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , psp_organization_accounts poa
     where poa.organization_account_id = p_organization_account_id
       and pbg.business_group_id = poa.business_group_id;
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
    ,p_argument           => 'organization_account_id'
    ,p_argument_value     => p_organization_account_id
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
        => nvl(p_associated_column1,'ORGANIZATION_ACCOUNT_ID')
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
  (p_organization_account_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , psp_organization_accounts poa
     where poa.organization_account_id = p_organization_account_id
       and pbg.business_group_id = poa.business_group_id;
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
    ,p_argument           => 'organization_account_id'
    ,p_argument_value     => p_organization_account_id
    );
  --
  if ( nvl(psp_poa_bus.g_organization_account_id, hr_api.g_number)
       = p_organization_account_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := psp_poa_bus.g_legislation_code;
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
    psp_poa_bus.g_organization_account_id     := p_organization_account_id;
    psp_poa_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in psp_poa_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';

--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.organization_account_id is not null)  and (
    nvl(psp_poa_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(psp_poa_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) ))
    or (p_rec.organization_account_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PSP'
      ,p_descflex_name                   => 'Organization Accounts DF'
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
  (p_rec in psp_poa_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT psp_poa_shd.api_updating
      (p_organization_account_id           => p_rec.organization_account_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_dates >----------------------------|
-- ----------------------------------------------------------------------------

  PROCEDURE validate_dates( p_organization_id         in NUMBER
                          , p_account_type            in VARCHAR2
                          , p_start_date_active       in DATE
                          , p_end_date_active         in DATE
                          , p_per_business_group_id   in NUMBER
                          , p_gl_set_of_bks_id        in NUMBER
			  , p_organization_account_id in NUMBER
			  , p_funding_source_code     in VARCHAR2) IS
--When a record is being inserted or modified, check for the dates. The dates shouldn't overlap with the dates of
--previously entered accounts of this organization. If the start date is less than the start date of a previously
--entered account of this organization, end date must be entered else the period will overlap. Also, end date must be
--greater than the start date.

--Cursor date_selection_csr: Select the dates for the accounts(other than the current one) of this organization.

	CURSOR date_selection_csr IS
	SELECT start_date_active, end_date_active
	FROM   psp_organization_accounts
	WHERE  organization_id = p_organization_id
	AND    account_type_code = p_account_type
	AND    business_group_id = p_per_business_group_id
	AND    set_of_books_id   = p_gl_set_of_bks_id
	AND    organization_account_id <> NVL(p_organization_account_id,-999)
	AND    funding_source_code = p_funding_source_code;

	CURSOR organnization_name_csr IS
	SELECT name
	FROM   hr_organization_units
	WHERE  business_group_id = p_per_business_group_id
	AND    organization_id = p_organization_id
	AND    trunc(sysdate) between date_from and nvl(date_to,trunc(sysdate));

	l_start_date_active DATE;
	l_end_date_active		DATE;
	l_char_date         VARCHAR2(30);
	l_organization_name VARCHAR2(240);
  BEGIN
	OPEN date_selection_csr;
	LOOP
		fetch date_selection_csr INTO l_start_date_active, l_end_date_active ;
		EXIT WHEN date_selection_csr%NOTFOUND;
		IF p_start_date_active BETWEEN l_start_date_active AND NVL(l_end_date_active, to_date('31/12/4712','DD/MM/RRRR')) THEN
			IF l_end_date_active IS NULL THEN
				fnd_message.set_name('PSP','PSP_NO_END_DATE');
				l_char_date :=  fnd_message.get;
			ELSE
				l_char_date := TO_CHAR(l_end_date_active);
			END IF;
			OPEN organnization_name_csr;
			FETCH  organnization_name_csr INTO l_organization_name;
			CLOSE organnization_name_csr;

			fnd_message.set_name ('PSP', 'PSP_SC_BEGINDATE_OVERLAP_ACCT');
			fnd_message.set_token('BEGIN_DATE', TO_CHAR(l_start_date_active));
			fnd_message.set_token('END_DATE', l_char_date);
			fnd_message.set_token('ORGANIZATION_NAME', l_organization_name);
      fnd_message.raise_error;
		END IF;
	END LOOP;
	CLOSE date_selection_csr;

	IF p_end_date_active IS NULL THEN
		OPEN date_selection_csr;
		LOOP
			fetch date_selection_csr INTO l_start_date_active, l_end_date_active ;
			EXIT WHEN date_selection_csr%NOTFOUND;
			IF p_start_date_active < l_start_date_active THEN
				fnd_message.set_name('PSP', 'PSP_ENDDATE_MUST_ENTER');
        fnd_message.raise_error;
			END IF;
		END LOOP;
		CLOSE date_selection_csr;
	END IF;

	IF p_end_date_active < p_start_date_active THEN
			fnd_message.set_name ('PSP', 'PSP_ED_GREATERTHAN_BD');
      fnd_message.raise_error;
	END IF;

	OPEN date_selection_csr;
	LOOP
		fetch date_selection_csr INTO l_start_date_active, l_end_date_active ;
		EXIT WHEN date_selection_csr%NOTFOUND ;
		IF p_end_date_active BETWEEN l_start_date_active AND NVL(l_end_date_active, to_date('31/12/4712','DD/MM/RRRR')) THEN
			IF l_end_date_active IS NULL THEN
				fnd_message.set_name('PSP','PSP_NO_END_DATE');
				l_char_date :=  fnd_message.get;
			ELSE
				l_char_date := TO_CHAR(l_end_date_active);
			END IF;
			OPEN organnization_name_csr;
			FETCH  organnization_name_csr INTO l_organization_name;
			CLOSE organnization_name_csr;

			fnd_message.set_name('PSP', 'PSP_SC_ENDDATE_OVERLAP_ACCT');
			fnd_message.set_token('BEGIN_DATE', TO_CHAR(l_start_date_active));
			fnd_message.set_token('END_DATE', l_char_date);
			fnd_message.set_token('ORGANIZATION_NAME', l_organization_name);
      fnd_message.raise_error;
		ELSIF p_start_date_active < l_start_date_active AND p_end_date_active > NVL(l_end_date_active, to_date('31/12/4712','DD/MM/RRRR')) THEN
			IF l_end_date_active IS NULL THEN
				fnd_message.set_name('PSP','PSP_NO_END_DATE');
				l_char_date :=  fnd_message.get;
			ELSE
				l_char_date := TO_CHAR(l_end_date_active);
			END IF;
			OPEN organnization_name_csr;
			FETCH  organnization_name_csr INTO l_organization_name;
			CLOSE organnization_name_csr;

			fnd_message.set_name('PSP', 'PSP_SC_ENDDATE_OVERLAP_ACCT');
			fnd_message.set_token('BEGIN_DATE', TO_CHAR(l_start_date_active));
			fnd_message.set_token('END_DATE', l_char_date);
			fnd_message.set_token('ORGANIZATION_NAME',l_organization_name);
      fnd_message.raise_error;
		END IF;
	END LOOP;
	CLOSE date_selection_csr;
  END validate_dates;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_ptaoe >----------------------------|
-- ----------------------------------------------------------------------------
--

  PROCEDURE validate_ptaoe( p_project_id                  in NUMBER
                          , p_task_id                     in NUMBER
                          , p_award_id                    in NUMBER
                          , p_expenditure_organization_id in NUMBER
                          , p_start_date_active           in DATE
                          , p_end_date_active             in DATE) IS

--Give a warning if :
  --Project is not active for schedule begin date or
  --Task is not active for schedule begin date or
  --Award is not linked to Project.
--Give an error if expenditure organization is not valid for the period selected.
	l_proj_start_date	date;
	l_proj_end_date		date;
	l_task_start_date	date;
	l_task_end_date		date;
	l_count			number;
	l_exp_org_start_date	date;
	l_exp_org_end_date		date;
	l_gl_set_of_bks_id    NUMBER;
	l_business_group_id   NUMBER;
	l_operating_unit       NUMBER;
	l_pa_gms_install_options  VARCHAR2(30);

	CURSOR project_dates_csr IS
	SELECT start_date, completion_date
	FROM   gms_projects_expend_v
	WHERE  project_id = p_project_id;

	CURSOR task_dates_csr IS
	SELECT start_date, completion_date
	FROM   pa_tasks_expend_v
	WHERE  task_id = p_task_id;

	CURSOR award_linked_csr IS
	SELECT count(*)
	FROM   gms_awards_basic_v
	WHERE  project_id = p_project_id
	AND    award_id = p_award_id;

	CURSOR exp_org_dates_csr IS
	SELECT  date_from, date_to
	FROM    pa_all_organizations p,hr_all_organization_units h
	WHERE   p.organization_id = h.organization_id
    AND     p.pa_org_use_type = 'EXPENDITURES'
    AND     h.organization_id = p_expenditure_organization_id
    AND     h.business_group_id = l_business_group_id
--    AND     nvl(p.org_id, -9999) = nvl(l_operating_unit, -9999)
    AND ((mo_global.get_current_org_id is NULL and mo_global.check_access(p.org_id) = 'Y')
        or ( mo_global.get_current_org_id is NOT NULL and p.org_id = mo_global.get_current_org_id ))
    AND     NVL(inactive_date,to_date('31/12/4712','DD/MM/RRRR')) > p_start_date_active;


  BEGIN
    psp_general.multiorg_client_info(
					p_gl_set_of_bks_id 				=> l_gl_set_of_bks_id,
					p_business_group_id				=> l_business_group_id,
					p_operating_unit					=> l_operating_unit,
					p_pa_gms_install_options	=> l_pa_gms_install_options);

	IF l_pa_gms_install_options in ('PA_GMS','PA_ONLY') THEN
		IF p_project_id IS NOT NULL THEN
			OPEN  project_dates_csr;
			FETCH project_dates_csr into l_proj_start_date, l_proj_end_date ;
			CLOSE project_dates_csr;

				IF (p_start_date_active NOT BETWEEN l_proj_start_date AND
						NVL(l_proj_end_date, fnd_date.canonical_to_date('4712/12/31'))) OR
					(NVL(p_end_date_active, fnd_date.canonical_to_date('4712/12/31')) NOT BETWEEN l_proj_start_date AND
					NVL(l_proj_end_date, fnd_date.canonical_to_date('4712/12/31'))) THEN

					fnd_message.set_name('PSP','PSP_PROJECT_NOT_ACTIVE');
					fnd_message.raise_error;
				END IF;

			OPEN  task_dates_csr;
			FETCH task_dates_csr into l_task_start_date, l_task_end_date  ;
			CLOSE task_dates_csr;

			IF p_task_id is not null AND
			(p_start_date_active NOT BETWEEN l_task_start_date AND
				NVL(l_task_end_date, fnd_date.canonical_to_date('4712/12/31'))) OR
			(NVL(p_end_date_active, fnd_date.canonical_to_date('4712/12/31')) NOT BETWEEN l_task_start_date AND
				NVL(l_task_end_date, fnd_date.canonical_to_date('4712/12/31'))) THEN

				fnd_message.set_name('PSP','PSP_TASK_NOT_ACTIVE');
				fnd_message.raise_error;
			END IF;

			IF l_pa_gms_install_options = 'PA_GMS' THEN
				IF p_project_id is not null and p_award_id is not null then
					OPEN award_linked_csr;
					FETCH award_linked_csr INTO  l_count;
					CLOSE award_linked_csr;

					IF l_count = 0 THEN
						fnd_message.set_name('PSP','PSP_AWARD_NOT_LINKED');
						fnd_message.raise_error;
					END IF;

					IF NOT PSP_GENERAL.AWARD_DATE_VALIDATION(
										P_AWARD_ID,
										p_start_date_active,
										p_end_date_active)
					THEN
						fnd_message.set_name('PSP','PSP_AWARD_NOT_VALID');
						fnd_message.raise_error;
					END IF;
				END IF;
		     END IF;
		END IF;
	END IF;

	IF p_expenditure_organization_id IS NOT NULL THEN
		OPEN  exp_org_dates_csr;
		FETCH exp_org_dates_csr into l_exp_org_start_date, l_exp_org_end_date;
		CLOSE exp_org_dates_csr;

		IF (p_start_date_active NOT BETWEEN l_exp_org_start_date AND
                NVL(l_exp_org_end_date, to_date('31/12/4712', 'DD/MM/RRRR'))) OR
           (p_end_date_active NOT BETWEEN l_exp_org_start_date AND
                NVL(l_exp_org_end_date, to_date('31/12/4712', 'DD/MM/RRRR'))) then

                  fnd_message.set_name('PSP', 'PSP_EXP_ORG_INVALID');
                  fnd_message.raise_error;
        END IF;
	END IF;


  exception when others then
	fnd_message.raise_error;
  END validate_ptaoe ;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in psp_poa_shd.g_rec_type
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
    ,p_associated_column1 => psp_poa_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');


		validate_dates(  p_organization_id				=>  p_rec.organization_id
								 , p_account_type						=>	p_rec.account_type_code
                 , p_start_date_active			=>	p_rec.start_date_active
                 , p_end_date_active				=>	p_rec.end_date_active
                 , p_per_business_group_id	=>	p_rec.business_group_id
                 , p_gl_set_of_bks_id				=>	p_rec.set_of_books_id
				 , p_organization_account_id        =>  p_rec.organization_account_id
				 ,p_funding_source_code		=>	p_rec.funding_source_code);

		 validate_ptaoe( p_project_id						=>	p_rec.project_id
                          , p_task_id						=>	p_rec.task_id
                          , p_award_id						=>	p_rec.award_id
                          , p_expenditure_organization_id	=>	p_rec.expenditure_organization_id
                          , p_start_date_active				=>	p_rec.start_date_active
                          , p_end_date_active				=>	p_rec.end_date_active);

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
  psp_poa_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in psp_poa_shd.g_rec_type
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
    ,p_associated_column1 => psp_poa_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');


		validate_dates(  p_organization_id				=>  p_rec.organization_id
								 , p_account_type						=>	p_rec.account_type_code
                 , p_start_date_active			=>	p_rec.start_date_active
                 , p_end_date_active				=>	p_rec.end_date_active
                 , p_per_business_group_id	=>	p_rec.business_group_id
                 , p_gl_set_of_bks_id				=>	p_rec.set_of_books_id
				 , p_organization_account_id        =>  p_rec.organization_account_id
				 ,p_funding_source_code		=>	p_rec.funding_source_code);

		 validate_ptaoe( p_project_id						=>	p_rec.project_id
                          , p_task_id						=>	p_rec.task_id
                          , p_award_id						=>	p_rec.award_id
                          , p_expenditure_organization_id	=>	p_rec.expenditure_organization_id
                          , p_start_date_active				=>	p_rec.start_date_active
                          , p_end_date_active				=>	p_rec.end_date_active);


	--
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  psp_poa_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in psp_poa_shd.g_rec_type
  ) is
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


end psp_poa_bus;

/
