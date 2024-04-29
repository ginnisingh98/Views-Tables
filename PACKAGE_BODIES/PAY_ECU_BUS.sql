--------------------------------------------------------
--  DDL for Package Body PAY_ECU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ECU_BUS" as
/* $Header: pyecurhi.pkb 120.2 2006/02/06 05:37 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_ecu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_element_class_usage_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_element_class_usage_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_element_class_usages_f ecu
     where ecu.element_class_usage_id = p_element_class_usage_id
       and pbg.business_group_id (+) = ecu.business_group_id;
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
    ,p_argument           => 'element_class_usage_id'
    ,p_argument_value     => p_element_class_usage_id
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
         => nvl(p_associated_column1,'ELEMENT_CLASS_USAGE_ID')
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
  (p_element_class_usage_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_element_class_usages_f ecu
     where ecu.element_class_usage_id = p_element_class_usage_id
       and pbg.business_group_id (+) = ecu.business_group_id;
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
    ,p_argument           => 'element_class_usage_id'
    ,p_argument_value     => p_element_class_usage_id
    );
  --
  if ( nvl(pay_ecu_bus.g_element_class_usage_id, hr_api.g_number)
       = p_element_class_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_ecu_bus.g_legislation_code;
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
    pay_ecu_bus.g_element_class_usage_id      := p_element_class_usage_id;
    pay_ecu_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_run_type_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    Checks the validity of the run_type_id enterend by carrying out
--    the following:
--      - check that the run_type_id exists
--      - check that the following rules apply:
--
--    Mode     Run Type     Available Components             Resulting usage
--    ------   -----------  -------------------------------  ---------------
--    USER     USER         USER, STARTUP, GENERIC           USER
--    USER     STARTUP      USER, STARTUP, GENERIC           USER
--    USER     GENERIC      USER, STARTUP, GENERIC           USER
--    STARTUP  USER         This mode cannot access USER     Error
--                          run types
--    STARTUP  STARTUP      STARTUP, GENERIC                 STARTUP
--    STARTUP  GENERIC      STARTUP, GENERIC                 STARTUP
--    GENERIC  USER         This mode cannot access USER     Error
--                          run types
--    GENERIC  STARTUP      This mode cannot access STARTUP  Error
--                          run types
--    GENERIC  GENERIC      GENERIC                          GENERIC
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
--
--
-- Post Failure:
--   An application error is raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_run_type_id
  (p_effective_date	in date
  ,p_element_class_usage_id in number default null
  ,p_run_type_id	in number
  ,p_business_group_id  in number
  ,p_legislation_code   in varchar2
   ) IS
--
CURSOR csr_chk_user_run_type(p_leg_code varchar2) is
select 'Y'
from   pay_run_types_f prt
where  prt.run_type_id = p_run_type_id
and    p_effective_date between prt.effective_start_date
                        and     prt.effective_end_date
and    ((prt.business_group_id is not null
       and prt.business_group_id = p_business_group_id)
or     (prt.legislation_code is not null
        and prt.legislation_code = p_leg_code)
or     (prt.business_group_id is null
       and prt.legislation_code is null));
--
CURSOR csr_chk_startup_run_type is
select 'Y'
from   pay_run_types_f prt
where  prt.run_type_id = p_run_type_id
and    p_effective_date between prt.effective_start_date
                        and     prt.effective_end_date
and    prt.business_group_id is null
and   ((p_legislation_code is not null
      and prt.legislation_code = p_legislation_code)
or    (prt.legislation_code is null));
--
CURSOR csr_chk_generic_run_type is
select 'Y'
from   pay_run_types_f prt
where  prt.run_type_id = p_run_type_id
and    p_effective_date between prt.effective_start_date
                        and     prt.effective_end_date
and    prt.business_group_id is null
and    prt.legislation_code is null;
--
--
l_exists		varchar2(2);
l_legislation_code      PAY_ELEMENT_CLASS_USAGES_F.legislation_code%TYPE;
l_proc                  varchar2(72) := g_package||'chk_run_type_id';
--
Begin
	hr_api.mandatory_arg_error
	(p_api_name       => l_proc
	,p_argument       => 'run_type_id'
	,p_argument_value => p_run_type_id
	);

	IF (p_run_type_id is not null) then
		IF hr_startup_data_api_support.g_startup_mode = 'GENERIC' THEN
			hr_utility.set_location(l_proc, 15);
		        OPEN csr_chk_generic_run_type;
		        FETCH csr_chk_generic_run_type INTO l_exists;
		        IF csr_chk_generic_run_type%NOTFOUND THEN
			--
				CLOSE csr_chk_generic_run_type;
				hr_utility.set_message(801, 'HR_33587_INVALID_RT_FOR_MODE');
				hr_utility.raise_error;
			--
			END IF;
			CLOSE csr_chk_generic_run_type;
		--
		ELSIF hr_startup_data_api_support.g_startup_mode = 'STARTUP' THEN
			hr_utility.set_location(l_proc, 20);
			OPEN  csr_chk_startup_run_type;
			FETCH csr_chk_startup_run_type INTO l_exists;
			IF csr_chk_startup_run_type%NOTFOUND THEN
			--
				CLOSE csr_chk_startup_run_type;
				hr_utility.set_message(801, 'HR_33587_INVALID_RT_FOR_MODE');
				hr_utility.raise_error;
			END IF;
			CLOSE csr_chk_startup_run_type;
		--
		ELSIF hr_startup_data_api_support.g_startup_mode = 'USER' THEN
			hr_utility.set_location(l_proc, 25);
			IF (p_element_class_usage_id is not null) then
				l_legislation_code := return_legislation_code(p_element_class_usage_id);
			ELSE
				l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
			END IF;
			OPEN  csr_chk_user_run_type(l_legislation_code);
			FETCH csr_chk_user_run_type INTO l_exists;
			IF csr_chk_user_run_type%NOTFOUND THEN
			--
				CLOSE csr_chk_user_run_type;
				hr_utility.set_message(801, 'PAY_33407_ECU_INVALID');
				hr_utility.raise_error;
			--
			END IF;
		CLOSE csr_chk_user_run_type;
		END IF;
	END IF;
       	--
	exception
	when app_exception.application_exception then
	if hr_multi_message.exception_add
	(p_associated_column1 =>
			'PAY_ELEMENT_CLASS_USAGES_F.RUN_TYPE_ID') then
		raise;
	 end if;
	when others then
	if csr_chk_generic_run_type%isopen then
		close csr_chk_generic_run_type;
	end if;
	if csr_chk_startup_run_type%isopen then
		close csr_chk_startup_run_type;
	end if;
	if csr_chk_user_run_type%isopen then
		close csr_chk_user_run_type;
	end if;
	raise;
--
End chk_run_type_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_classification_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks the validity of the classification_id enterend by carrying out
--    the following:
--      - check that the classification_id exists
--      - check that the following rules apply:
--
--    Mode     Run Type     Available Components             Resulting usage
--    ------   -----------  -------------------------------  ---------------
--    USER     USER         USER, STARTUP, GENERIC           USER
--    USER     STARTUP      USER, STARTUP, GENERIC           USER
--    USER     GENERIC      USER, STARTUP, GENERIC           USER
--    STARTUP  USER         This mode cannot access USER     Error
--                          classifications
--    STARTUP  STARTUP      STARTUP, GENERIC                 STARTUP
--    STARTUP  GENERIC      STARTUP, GENERIC                 STARTUP
--    GENERIC  USER         This mode cannot access USER     Error
--                          classifications
--    GENERIC  STARTUP      This mode cannot access STARTUP  Error
--                          classifications
--    GENERIC  GENERIC      GENERIC                          GENERIC
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
--
--
-- Post Failure:
--   An application error is raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_classification_id
  (p_effective_date	    in date
  ,p_element_class_usage_id in number default null
  ,p_classification_id      in number
  ,p_business_group_id	    in number
  ,p_legislation_code       in varchar2
  ) IS
--
CURSOR csr_chk_user_ele_class(p_leg_code varchar2) is
select 'Y'
from   pay_element_classifications ecl
where  ecl.classification_id = p_classification_id
and    ((ecl.business_group_id is not null
       and ecl.business_group_id = p_business_group_id)
or     (ecl.legislation_code is not null
        and ecl.legislation_code = p_leg_code)
or     (ecl.business_group_id is null
       and ecl.legislation_code is null));
--
CURSOR csr_chk_startup_ele_class is
select 'Y'
from   pay_element_classifications ecl
where  ecl.classification_id = p_classification_id
and    ecl.business_group_id is null
and   ((p_legislation_code is not null
      and ecl.legislation_code = p_legislation_code)
or    (ecl.legislation_code is null));
--
CURSOR csr_chk_generic_ele_class is
select 'Y'
from   pay_element_classifications ecl
where  ecl.classification_id = p_classification_id
and    ecl.business_group_id is null
and    ecl.legislation_code is null;
--


l_exists                varchar2(2);
l_legislation_code      PAY_ELEMENT_CLASS_USAGES_F.legislation_code%TYPE;
l_proc                  varchar2(72) := g_package||'chk_classification_id';
--
Begin
	hr_api.mandatory_arg_error
	(p_api_name       => l_proc
	,p_argument       => 'classification_id'
	,p_argument_value => p_classification_id
	);
	IF (p_classification_id is not null) then
		IF hr_startup_data_api_support.g_startup_mode = 'GENERIC' THEN
			hr_utility.set_location(l_proc, 15);
		        OPEN csr_chk_generic_ele_class;
		        FETCH csr_chk_generic_ele_class INTO l_exists;
		        IF csr_chk_generic_ele_class%NOTFOUND THEN
			--
				CLOSE csr_chk_generic_ele_class;
				hr_utility.set_message(801, 'PAY_33408_INV_ELE_CLS_FOR_MODE');
				hr_utility.raise_error;
			--
			END IF;
			CLOSE csr_chk_generic_ele_class;
		--
		ELSIF hr_startup_data_api_support.g_startup_mode = 'STARTUP' THEN
			hr_utility.set_location(l_proc, 20);
			OPEN  csr_chk_startup_ele_class;
			FETCH csr_chk_startup_ele_class INTO l_exists;
			IF csr_chk_startup_ele_class%NOTFOUND THEN
			--
				CLOSE csr_chk_startup_ele_class;
				hr_utility.set_message(801, 'PAY_33408_INV_ELE_CLS_FOR_MODE');
				hr_utility.raise_error;
			END IF;
			CLOSE csr_chk_startup_ele_class;
		--
		ELSIF hr_startup_data_api_support.g_startup_mode = 'USER' THEN
			hr_utility.set_location(l_proc, 25);
			IF (p_element_class_usage_id is not null) then
				l_legislation_code := return_legislation_code(p_element_class_usage_id);
			ELSE
				l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
			END IF;
			OPEN  csr_chk_user_ele_class(l_legislation_code);
			FETCH csr_chk_user_ele_class INTO l_exists;
			IF csr_chk_user_ele_class%NOTFOUND THEN
			--
				CLOSE csr_chk_user_ele_class;
				hr_utility.set_message(801, 'PAY_33407_ECU_INVALID');
				hr_utility.raise_error;
			--
			END IF;
		CLOSE csr_chk_user_ele_class;
		END IF;
	END IF;
       	--
	exception
	when app_exception.application_exception then
	if hr_multi_message.exception_add
			(p_associated_column1 =>
			'PAY_ELEMENT_CLASS_USAGES_F.CLASSIFICATION_ID') then
		raise;
	end if;
	when others then
	if csr_chk_generic_ele_class%isopen then
		close csr_chk_generic_ele_class;
	end if;
	if csr_chk_startup_ele_class%isopen then
		close csr_chk_startup_ele_class;
	end if;
	if csr_chk_user_ele_class%isopen then
		close csr_chk_user_ele_class;
	end if;
	raise;
End chk_classification_id;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_legislation_code>-------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the legislation code exists in fnd_territories
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
procedure chk_legislation_code
( p_legislation_code  in varchar2 )
is
--
cursor csr_legislation_code is
select null
from fnd_territories
where territory_code = p_legislation_code ;
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_legislation_code';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_legislation_code;
  fetch csr_legislation_code into l_exists ;

  if csr_legislation_code%notfound then
    close csr_legislation_code;
    fnd_message.set_name('PAY', 'PAY_33177_LEG_CODE_INVALID');
    fnd_message.raise_error;
  end if;
  close csr_legislation_code;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_ELEMENT_CLASS_USAGES_F.LEGISLATION_CODE'
       ) then
      raise;
    end if;
  when others then
    if csr_legislation_code%isopen then
      close csr_legislation_code;
    end if;
    raise;
end chk_legislation_code;
--
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
  (p_effective_date  in date
  ,p_rec             in pay_ecu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  hr_utility.set_location('Entering : '||l_proc, 5);
  IF NOT pay_ecu_shd.api_updating
      (p_element_class_usage_id           => p_rec.element_class_usage_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
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
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_ecu_shd.g_old_rec.business_group_id, hr_api.g_number) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'BUSINESS_GROUP_ID'
	      ,p_base_table => pay_ecu_shd.g_tab_nam
	      );
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_ecu_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'LEGISLATION_CODE'
	      ,p_base_table => pay_ecu_shd.g_tab_nam
	      );
  end if;
  hr_utility.set_location('Leaving : '||l_proc, 100);

End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
    --
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_element_class_usage_id           in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'element_class_usage_id'
      ,p_argument_value => p_element_class_usage_id
      );
    --
  --
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
  IF (p_insert) THEN
    if p_business_group_id is not null and p_legislation_code is not null then
	fnd_message.set_name('PAY', 'PAY_33179_BGLEG_INVALID');
        fnd_message.raise_error;
    end if;
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_ecu_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
  l_mode        varchar2(10);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  l_mode := hr_startup_data_api_support.g_startup_mode;
  IF l_mode NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     If (p_rec.business_group_id is not null) then
     --
	hr_api.validate_bus_grp_id
		(p_business_group_id => p_rec.business_group_id
	        ,p_associated_column1 => pay_ecu_shd.g_tab_nam
		                       || '.BUSINESS_GROUP_ID');
     --
     end if;
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
     hr_utility.set_location('chk_run_type : '||l_proc,10);
     if(p_rec.legislation_code is not null) then
	chk_legislation_code(p_legislation_code => p_rec.legislation_code);
     end if;
  --
     hr_utility.set_location('chk_classification_id : '||l_proc, 15);
     chk_classification_id(p_effective_date		=> p_effective_date
			  ,p_element_class_usage_id	=> p_rec.element_class_usage_id
			  ,p_classification_id		=> p_rec.classification_id
			  ,p_business_group_id		=> p_rec.business_group_id
			  ,p_legislation_code		=> p_rec.legislation_code);


     hr_utility.set_location('chk_run_type : '||l_proc, 20);
     chk_run_type_id(p_effective_date		=> p_effective_date
		    ,p_element_class_usage_id	=> p_rec.element_class_usage_id
		    ,p_run_type_id		=> p_rec.run_type_id
		    ,p_business_group_id	=> p_rec.business_group_id
		    ,p_legislation_code		=> p_rec.legislation_code);

  --
     hr_utility.set_location('chk_classification_id : '|| l_proc, 20);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_ecu_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
  l_mode        varchar2(10);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  l_mode := hr_startup_data_api_support.g_startup_mode;
  IF l_mode NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     If (p_rec.business_group_id is not null) then
     --
	hr_api.validate_bus_grp_id
		(p_business_group_id => p_rec.business_group_id
	        ,p_associated_column1 => pay_ecu_shd.g_tab_nam
		                       || '.BUSINESS_GROUP_ID');
     --
     end if;
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
     hr_utility.set_location('chk_run_type : '||l_proc,10);
     if(p_rec.legislation_code is not null) then
	chk_legislation_code(p_legislation_code => p_rec.legislation_code);
     end if;
  --
     hr_utility.set_location('chk_run_type : '||l_proc,15);
     chk_run_type_id(p_effective_date		=> p_effective_date
		    ,p_element_class_usage_id	=> p_rec.element_class_usage_id
		    ,p_run_type_id		=> p_rec.run_type_id
		    ,p_business_group_id	=> p_rec.business_group_id
		    ,p_legislation_code		=> p_rec.legislation_code);

  --
     hr_utility.set_location('chk_classification_id : '|| l_proc, 20);
     chk_classification_id(p_effective_date		=> p_effective_date
			  ,p_element_class_usage_id	=> p_rec.element_class_usage_id
			  ,p_classification_id		=> p_rec.classification_id
			  ,p_business_group_id		=> p_rec.business_group_id
			  ,p_legislation_code		=> p_rec.legislation_code);

  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_ecu_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  chk_startup_action(false
                    ,pay_ecu_shd.g_old_rec.business_group_id
                    ,pay_ecu_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_element_class_usage_id           => p_rec.element_class_usage_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_ecu_bus;

/
