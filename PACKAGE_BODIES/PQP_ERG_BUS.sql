--------------------------------------------------------
--  DDL for Package Body PQP_ERG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ERG_BUS" as
/* $Header: pqergrhi.pkb 115.9 2003/02/19 02:25:55 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_erg_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_exception_group_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_exception_group_id                   in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqp_exception_report_groups erg
         , pqp_exception_reports exr
     where erg.exception_group_id = p_exception_group_id
     and   pbg.business_group_id = exr.business_group_id
     and   exr.exception_report_id = erg.exception_report_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'exception_group_id'
    ,p_argument_value     => p_exception_group_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
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
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_exception_group_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pqp_exception_report_groups erg
         , pqp_exception_reports exr
     where erg.exception_group_id = p_exception_group_id
     and   exr.exception_report_id = erg.exception_report_id
     and   pbg.business_group_id = exr.business_group_id;
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
    ,p_argument           => 'exception_group_id'
    ,p_argument_value     => p_exception_group_id
    );
  --
  if ( nvl(pqp_erg_bus.g_exception_group_id, hr_api.g_number)
       = p_exception_group_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_erg_bus.g_legislation_code;
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
    pqp_erg_bus.g_exception_group_id          := p_exception_group_id;
    pqp_erg_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in pqp_erg_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_erg_shd.api_updating
      (p_exception_group_id                   => p_rec.exception_group_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
       nvl (pqp_erg_shd.g_old_rec.business_group_id, hr_api.g_number) THEN
     l_argument := 'business_group_id';
     RAISE l_error;
  END IF;

  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
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
  IF (p_insert) THEN
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_exception_report_id >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_exception_group_id PK
--   p_exception_report_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_exception_report_id (p_exception_group_id		in number
				  ,p_exception_report_id	in number
				  ,p_object_version_number	in number
				  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_exception_report_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqp_exception_reports a
    where  a.exception_report_id = p_exception_report_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqp_erg_shd.api_updating
     (p_exception_group_id	=> p_exception_group_id,
      p_object_version_number	=> p_object_version_number);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EXCEPTION_REPORT_ID'
    ,p_argument_value     => p_exception_report_id
    );
  --
  if (l_api_updating
     and nvl(p_exception_report_id,hr_api.g_number)
     <> nvl(pqp_erg_shd.g_old_rec.exception_report_id,hr_api.g_number)
     or not l_api_updating) and
     p_exception_report_id is not null then
    --
    -- check if exception_report_id value exists in pqp_exception_reports table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqp_exception_reports
        -- table.
        --
        pqp_erg_shd.constraint_error('PQP_REPORT_GROUPS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_exception_report_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_consolidation_set_id >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_exception_group_id PK
--   p_consolidation_set_id ID of FK column
--   p_business_group_id ID of business group
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_consolidation_set_id(p_exception_group_id		in number
				  ,p_consolidation_set_id	in number
				  ,p_business_group_id		in number
				  ,p_object_version_number	in number
				  ) is
  --
  l_proc         varchar2(72) := g_package||'chk_consolidation_set_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_consolidation_sets a
    where  a.consolidation_set_id = p_consolidation_set_id
      and  a.business_group_id	  = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqp_erg_shd.api_updating
     (p_exception_group_id	=> p_exception_group_id,
      p_object_version_number	=> p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_consolidation_set_id,hr_api.g_number)
     <> nvl(pqp_erg_shd.g_old_rec.consolidation_set_id,hr_api.g_number)
     or not l_api_updating) and
     p_consolidation_set_id is not null then
    --
    -- check if consolidation_set_id value exists in pqp_exception_reports table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqp_exception_reports
        -- table.
        --
        pqp_erg_shd.constraint_error('PQP_REPORT_GROUPS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_consolidation_set_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_payroll_id >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_exception_group_id PK
--   p_payroll_id ID of FK column
--   p_business_group_id ID of business group
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_payroll_id(p_exception_group_id		in number
                        ,p_payroll_id			in number
                        ,p_business_group_id		in number
                        ,p_object_version_number	in number
                        ) is
  --
  l_proc         varchar2(72) := g_package||'chk_payroll_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_payrolls_f a
    where  a.payroll_id = p_payroll_id
      and  a.business_group_id	  = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqp_erg_shd.api_updating
     (p_exception_group_id	=> p_exception_group_id,
      p_object_version_number	=> p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_payroll_id,hr_api.g_number)
     <> nvl(pqp_erg_shd.g_old_rec.payroll_id,hr_api.g_number)
     or not l_api_updating) and
     p_payroll_id is not null then
    --
    -- check if payroll_id value exists in pqp_exception_reports table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqp_exception_reports
        -- table.
        --
        pqp_erg_shd.constraint_error('PQP_REPORT_GROUPS_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_payroll_id;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_group_name_unique >---------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the group must have a name and it is not the same as a seeded group name
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_exception_group_name is the group name
--     p_exception_group_id is exception group id
--     p_legislation_code
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
-- ----------------------------------------------------------------------------
Procedure chk_group_name_unique
           (p_exception_group_id	in number
           ,p_exception_group_name	in   varchar2
           ,p_business_group_id		in number
           ) is

l_proc	    varchar2(72) := g_package||'chk_exception_group_name_unique';
l_dummy    char(10);
l_leg_code VARCHAR2(20);

cursor c1(p_legislation_code VARCHAR2) is select null
               from pqp_exception_report_groups
              Where exception_group_id <> nvl(p_exception_group_id,-1)
                and exception_group_name = p_exception_group_name
               and (legislation_code is not null and
                   legislation_code = p_legislation_code)
		    ;
cursor c2 is
SELECT pbg.legislation_code
FROM per_business_groups pbg where pbg.business_group_id=p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EXCEPTION_GROUP_NAME'
    ,p_argument_value     => p_exception_group_name
    );
  --
  open c2;
  loop
  fetch c2 into l_leg_code;
  exit when c2%NOTFOUND;
  end loop;
  close c2;
  open c1(l_leg_code);
  fetch c1 into l_dummy;
  if c1%found then
      close c1;

      pqp_erg_shd.constraint_error('PQP_REPORT_GROUPS_NAMECHK');
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_group_name_unique;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_comp_key_unique >---------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the group must have a name and it is not the same as a seeded group name
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_exception_group_name is the group name
--     p_exception_group_id is exception group id
--     p_business_group_id is then Id of Business Group
--     p_exception_report_id is the Id from (virtual) parent record.
--     p_legislation_code
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
-- ----------------------------------------------------------------------------
Procedure chk_comp_key_unique
           (p_exception_group_id	in number
           ,p_exception_group_name	in varchar2
           ,p_business_group_id		in number
           ,p_legislation_code		in varchar2
           ,p_exception_report_id	in number
           ) is

l_proc	    varchar2(72) := g_package||'chk_comp_key_unique';
l_dummy    char(1);
l_legislation_code pqp_exception_report_groups.legislation_code%TYPE;

cursor c1 is select null
               from pqp_exception_report_groups
              Where exception_group_id <> nvl(p_exception_group_id,-1)
                and exception_group_name = p_exception_group_name
                and exception_report_id  = p_exception_report_id
		and ((legislation_code is not null
		   	    and legislation_code = NVL(p_legislation_code,l_legislation_code))
		      or (business_group_id is not null
			    and business_group_id = p_business_group_id)
		    );
cursor c2 is
SELECT pbg.legislation_code
FROM per_business_groups pbg where pbg.business_group_id=p_business_group_id;

--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
open c2;
  loop
  fetch c2 into l_legislation_code;
  exit when c2%NOTFOUND;
  end loop;
  close c2;

  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      pqp_erg_shd.constraint_error('PQP_REPORT_GROUPS_COMPKEY');
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_comp_key_unique;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pqp_erg_shd.g_rec_type
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
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  chk_exception_report_id (p_exception_group_id		=> p_rec.exception_group_id
  			  ,p_exception_report_id	=> p_rec.exception_report_id
  			  ,p_object_version_number	=> p_rec.object_version_number
  			  );
  --
  chk_consolidation_set_id (p_exception_group_id	=> p_rec.exception_group_id
  			   ,p_consolidation_set_id	=> p_rec.consolidation_set_id
  			   ,p_business_group_id		=> p_rec.business_group_id
  			   ,p_object_version_number	=> p_rec.object_version_number
  			   );
  --
  chk_payroll_id (p_exception_group_id		=> p_rec.exception_group_id
  		 ,p_payroll_id			=> p_rec.payroll_id
  		 ,p_business_group_id		=> p_rec.business_group_id
  		 ,p_object_version_number	=> p_rec.object_version_number
  		 );
  --
  chk_group_name_unique (p_exception_group_id	=> p_rec.exception_group_id
  			,p_exception_group_name	=> p_rec.exception_group_name
  		        ,p_business_group_id	=> p_rec.business_group_id
  			);
  --
  chk_comp_key_unique (p_exception_group_id	=> p_rec.exception_group_id
  		      ,p_exception_group_name	=> p_rec.exception_group_name
  		      ,p_business_group_id	=> p_rec.business_group_id
  		      ,p_legislation_code	=> p_rec.legislation_code
  		      ,p_exception_report_id	=> p_rec.exception_report_id
  		      );
  --
  -- set_security_group_id(p_rec.exception_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pqp_erg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --

  -- set_security_group_id(p_rec.exception_group_id);
  --
  chk_non_updateable_args
      (p_rec              => p_rec
    );
  --
  chk_exception_report_id (p_exception_group_id		=> p_rec.exception_group_id
  			  ,p_exception_report_id	=> p_rec.exception_report_id
  			  ,p_object_version_number	=> p_rec.object_version_number
  			  );
  --
  chk_consolidation_set_id (p_exception_group_id	=> p_rec.exception_group_id
  			   ,p_consolidation_set_id	=> p_rec.consolidation_set_id
  			   ,p_business_group_id		=> p_rec.business_group_id
  			   ,p_object_version_number	=> p_rec.object_version_number
  			   );
  --
  chk_payroll_id (p_exception_group_id		=> p_rec.exception_group_id
  		 ,p_payroll_id			=> p_rec.payroll_id
  		 ,p_business_group_id		=> p_rec.business_group_id
  		 ,p_object_version_number	=> p_rec.object_version_number
  		 );
  --
  chk_group_name_unique (p_exception_group_id	=> p_rec.exception_group_id
  			,p_exception_group_name	=> p_rec.exception_group_name
  		        ,p_business_group_id		=> p_rec.business_group_id
  			);
  --
  chk_comp_key_unique (p_exception_group_id	=> p_rec.exception_group_id
  		      ,p_exception_group_name	=> p_rec.exception_group_name
  		      ,p_business_group_id	=> p_rec.business_group_id
  		      ,p_legislation_code	=> p_rec.legislation_code
  		      ,p_exception_report_id	=> p_rec.exception_report_id
  		      );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqp_erg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  chk_startup_action(false
                    ,pqp_erg_shd.g_old_rec.business_group_id
                    ,pqp_erg_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqp_erg_bus;

/
