--------------------------------------------------------
--  DDL for Package Body PSP_PSC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSC_BUS" as
/* $Header: PSPSCRHB.pls 120.1 2005/11/28 23:27 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_psc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_salary_cap_id               number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
-- This procedure is not being called since Salary Caps are not dependent on BG
/*
Procedure set_security_group_id
  (p_salary_cap_id                        in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- salary caps are global. BG check is not required

  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- psp_salary_caps and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from psp_salary_caps psc
      --   , per_business_groups_perf pbg
      --   , EDIT_HERE table_name(s) 333
     where psc.salary_cap_id = p_salary_cap_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'salary_cap_id'
    ,p_argument_value     => p_salary_cap_id
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
        => nvl(p_associated_column1,'SALARY_CAP_ID')
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
*/
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
-- This function is not being called since Salary Caps are not dependent on BG
/*
Function return_legislation_code
  (p_salary_cap_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- psp_salary_caps and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , psp_salary_caps psc
      --   , EDIT_HERE table_name(s) 333
     where psc.salary_cap_id = p_salary_cap_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'salary_cap_id'
    ,p_argument_value     => p_salary_cap_id
    );
  --
  if ( nvl(psp_psc_bus.g_salary_cap_id, hr_api.g_number)
       = p_salary_cap_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := psp_psc_bus.g_legislation_code;
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
    psp_psc_bus.g_salary_cap_id               := p_salary_cap_id;
    psp_psc_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
*/
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
  (p_rec in psp_psc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT psp_psc_shd.api_updating
      (p_salary_cap_id                     => p_rec.salary_cap_id
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
--

  PROCEDURE validate_dates( p_salary_cap_id		IN	NUMBER
                          , p_funding_source_code	IN	VARCHAR2
                          , p_start_date		IN	DATE
                          , p_end_date			IN	DATE
                          , p_currency_code		IN	VARCHAR2 ) IS
--When a record is being inserted or modified, check for the dates. The dates shouldn't overlap with the dates of
--previously entered accounts of this organization. If the start date is less than the start date of a previously
--entered account of this organization, end date must be entered else the period will overlap. Also, end date must be
--greater than the start date.

--Cursor date_selection_csr: Select the dates for the accounts(other than the current one) of this organization.

	CURSOR date_selection_csr IS
	SELECT start_date, end_date
	FROM   psp_salary_caps
	WHERE  funding_source_code = p_funding_source_code
	AND    currency_code = p_currency_code
	AND    salary_cap_id <> NVL(p_salary_cap_id,-999);


	l_start_date	DATE;
	l_end_date	DATE;
  BEGIN
	IF p_end_date < p_start_date THEN
		fnd_message.set_name ('PSP', 'PSP_ED_GREATERTHAN_BD');
		fnd_message.raise_error;
	END IF;

	OPEN date_selection_csr;
	LOOP
		fetch date_selection_csr INTO l_start_date, l_end_date;
		EXIT WHEN date_selection_csr%NOTFOUND;
		IF p_start_date BETWEEN l_start_date AND l_end_date THEN
			fnd_message.set_name ('PSP', 'PSP_SC_BEGINDATE_OVERLAP_SPONS');
			fnd_message.set_token('BEGIN_DATE', TO_CHAR(l_start_date));
			fnd_message.set_token('END_DATE', l_end_date);
			fnd_message.raise_error;
		END IF;
	END LOOP;
	CLOSE date_selection_csr;


	OPEN date_selection_csr;
	LOOP
		fetch date_selection_csr INTO l_start_date , l_end_date  ;
		EXIT WHEN date_selection_csr%NOTFOUND ;
		IF p_end_date BETWEEN l_start_date AND l_end_date THEN
			fnd_message.set_name('PSP', 'PSP_SC_ENDDATE_OVERLAP_SPONS');
			fnd_message.set_token('BEGIN_DATE', TO_CHAR(l_start_date ));
			fnd_message.set_token('END_DATE', l_end_date);
		        fnd_message.raise_error;
		ELSIF p_start_date < l_start_date AND p_end_date > l_end_date THEN
			fnd_message.set_name('PSP', 'PSP_SC_ENDDATE_OVERLAP_SPONS');
			fnd_message.set_token('BEGIN_DATE', TO_CHAR(l_start_date));
			fnd_message.set_token('END_DATE', l_end_date);
			fnd_message.raise_error;
		END IF;
	END LOOP;
	CLOSE date_selection_csr;
  END validate_dates;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in psp_psc_shd.g_rec_type
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
	validate_dates( p_salary_cap_id		=>	p_rec.salary_cap_id
                      , p_funding_source_code	=>	p_rec.funding_source_code
                      , p_start_date		=>	p_rec.start_date
                      , p_end_date		=>	p_rec.end_date
                      , p_currency_code		=>	p_rec.currency_code );

  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in psp_psc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  	validate_dates( p_salary_cap_id		=>	p_rec.salary_cap_id
                      , p_funding_source_code	=>	p_rec.funding_source_code
                      , p_start_date		=>	p_rec.start_date
                      , p_end_date		=>	p_rec.end_date
                      , p_currency_code		=>	p_rec.currency_code );

  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in psp_psc_shd.g_rec_type
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
--
end psp_psc_bus;

/
