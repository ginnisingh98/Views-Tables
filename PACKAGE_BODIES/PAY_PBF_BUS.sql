--------------------------------------------------------
--  DDL for Package Body PAY_PBF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PBF_BUS" as
/* $Header: pypbfrhi.pkb 120.1.12010000.2 2009/07/30 17:54:19 npannamp ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pbf_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_balance_feed_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_balance_feed_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,pbg.legislation_code
      from PER_BUSINESS_GROUPS_PERF pbg
         , pay_balance_feeds_f pbf
     where pbf.balance_feed_id = p_balance_feed_id
       and pbg.business_group_id = pbf.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_legislation_code  varchar2(150);
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
    ,p_argument           => 'balance_feed_id'
    ,p_argument_value     => p_balance_feed_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id,l_legislation_code;
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
         => nvl(p_associated_column1,'BALANCE_FEED_ID')
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
  (p_balance_feed_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_balance_feeds_f pbf
     where pbf.balance_feed_id = p_balance_feed_id
       and pbg.business_group_id (+) = pbf.business_group_id;
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
    ,p_argument           => 'balance_feed_id'
    ,p_argument_value     => p_balance_feed_id
    );
  --
  if ( nvl(pay_pbf_bus.g_balance_feed_id, hr_api.g_number)
       = p_balance_feed_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pbf_bus.g_legislation_code;
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
    pay_pbf_bus.g_balance_feed_id             := p_balance_feed_id;
    pay_pbf_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date  in date
  ,p_rec             in pay_pbf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_argument varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_pbf_shd.api_updating
      (p_balance_feed_id                  => p_rec.balance_feed_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location('Entering:'||l_proc, 6);

  if nvl(p_rec.business_group_id, hr_api.g_number) <>
         nvl(pay_pbf_shd.g_old_rec.business_group_id, hr_api.g_number) then
	     l_argument := 'business_group_id';
	     raise hr_api.argument_changed;
  end if;

  hr_utility.set_location('Entering:'||l_proc, 7);
  if nvl(p_rec.input_value_id, hr_api.g_number) <>
         nvl(pay_pbf_shd.g_old_rec.input_value_id, hr_api.g_number) then
	    l_argument := 'input_value_id';
	    raise hr_api.argument_changed;
  end if;

  hr_utility.set_location('Entering:'||l_proc, 8);
  if nvl(p_rec.balance_type_id, hr_api.g_number) <>
         nvl(pay_pbf_shd.g_old_rec.balance_type_id, hr_api.g_number) then
	    l_argument := 'balance_type_id';
	    raise hr_api.argument_changed;
  end if;

  hr_utility.set_location('Entering:'||l_proc, 9);
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
         nvl(pay_pbf_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
	    l_argument := 'legislation_code';
	    raise hr_api.argument_changed;
  end if;

  hr_utility.set_location('Entering:'||l_proc, 9);
  if nvl(p_rec.legislation_subgroup, hr_api.g_varchar2) <>
         nvl(pay_pbf_shd.g_old_rec.legislation_subgroup, hr_api.g_varchar2) then
	    l_argument := 'legislation_subgroup';
	    raise hr_api.argument_changed;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

  Exception
  When hr_api.argument_changed Then
  -- A non updatetable attribute has been changed therefore we
  -- must report this error
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => l_argument
     );

  --
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
  (p_balance_feed_id                  in number
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
      ,p_argument       => 'balance_feed_id'
      ,p_argument_value => p_balance_feed_id
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
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => FALSE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => FALSE
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
-- check procedures
-- ----------------------------------------------------------------------------
-- |------------------------< chk_business_group_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the business group id against the
--   parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_business_group_id
  (p_business_group_id in number
  ,p_input_value_id    in number
  ,p_effective_date    in date
  ) is
--
  l_proc               varchar2(72) := g_package||'chk_business_group_id';
  l_exists	       varchar2(1);
  l_balance_init_flag  number := 0;

  Cursor c_chk_bg_id
  is
    select '1'
      from hr_organization_units
     where business_group_id = p_business_group_id;
     -- and  ( l_balance_init_flag = 1 or
     --         ( p_effective_date between date_from
	 -- 	and nvl(date_to, hr_api.g_eot) ) );
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'input_value_id'
      ,p_argument_value => p_input_value_id
      );
  --

  if get_balance_init_flag ( p_input_value_id => p_input_value_id ) then
       l_balance_init_flag := 1;
  end if;

  If p_business_group_id is not null then
    Open c_chk_bg_id;
    Fetch c_chk_bg_id into l_exists;
    If c_chk_bg_id%notfound Then
      --
      Close c_chk_bg_id;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','BUSINESS_GROUP_ID');
      fnd_message.set_token('TABLE','HR_ORGANIZATION_UNITS');
      fnd_message.raise_error;
      --
    End If;
    Close c_chk_bg_id;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_legislation_code >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the legislation code against the
--   parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_legislation_code
  (p_legislation_code  in varchar2)
  is
--
  l_proc        varchar2(72) := g_package||'chk_legislation_code';
  l_exists	    varchar2(1);
  Cursor c_chk_leg_code
  is
    select '1'
      from fnd_territories
     where territory_code = p_legislation_code;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_legislation_code is not null then

  	Open c_chk_leg_code;
  	Fetch c_chk_leg_code into l_exists;
  	If c_chk_leg_code%notfound Then
  	  --
  	  Close c_chk_leg_code;
  	  fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
  	  fnd_message.set_token('COLUMN','LEGISLATION_CODE');
  	  fnd_message.set_token('TABLE','FND_TERRITORIES');
  	  fnd_message.raise_error;
  	  --
  	End If;
  	Close c_chk_leg_code;

  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_input_value_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the input value id against the
--   parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_input_value_id
  (p_input_value_id    in number
  ,p_business_group_id in pay_balance_feeds_f.business_group_id%type
  ,p_legislation_code  in pay_balance_feeds_f.legislation_code%type
  ) is
--
  l_proc             varchar2(72) := g_package||'chk_input_value_id';
  l_exists	     varchar2(1);
  l_legislation_code per_business_groups.legislation_code%type;

    cursor csr_ipv_id is
    select '1'
    from pay_input_values_f
    where input_value_id = p_input_value_id
    and nvl(legislation_code, nvl(l_legislation_code, hr_api.g_varchar2))
       = nvl(l_legislation_code, hr_api.g_varchar2)
    and nvl(business_group_id, nvl(p_business_group_id, hr_api.g_number))
       = nvl(p_business_group_id, hr_api.g_number);

    cursor csr_ipv_multiple_feeds is
    select null
    from pay_balance_feeds_f pbf
    where pbf.input_value_id = p_input_value_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_legislation_code := nvl(p_legislation_code
                           ,hr_api.return_legislation_code
                                (p_business_group_id));

  Open csr_ipv_id;
  Fetch csr_ipv_id into l_exists;
  If csr_ipv_id%notfound Then
    --
    Close csr_ipv_id;
    fnd_message.set_name('PAY','PAY_34154_LEG_BUS_MISMATCH');
    fnd_message.set_token('ENTITY1','INITIAL BALANCE FEED');
    fnd_message.set_token('ENTITY2','INPUT VALUE');
    fnd_message.raise_error;
    --
  End If;
  Close csr_ipv_id;

  -- no other balance feed must be created with the input value when creating
  -- initial balance feed.

  if get_balance_init_flag (p_input_value_id => p_input_value_id) then

	open csr_ipv_multiple_feeds;
	fetch csr_ipv_multiple_feeds into l_exists;

	if csr_ipv_multiple_feeds%found then

	    close csr_ipv_multiple_feeds;
	    fnd_message.set_name('PAY','PAY_33245_BIFEED_IPV_MUL_FEEDS');
	    fnd_message.raise_error;

	end if;

	close csr_ipv_multiple_feeds;

  end if;

  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_balance_type_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the balance type id against the
--   parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_balance_type_id
  (p_balance_type_id in number
  ,p_business_group_id in pay_balance_feeds_f.business_group_id%type
  ,p_legislation_code  in pay_balance_feeds_f.legislation_code%type
  ) is
--
  l_proc              varchar2(72) := g_package||'chk_balance_type_id';
  l_exists	      varchar2(1);
  l_legislation_code  per_business_groups.legislation_code%type;

    cursor csr_bal_type_id is
    select '1'
      from pay_balance_types
     where balance_type_id = p_balance_type_id
     and nvl(legislation_code, nvl(l_legislation_code, hr_api.g_varchar2))
        = nvl(l_legislation_code, hr_api.g_varchar2)
     and nvl(business_group_id, nvl(p_business_group_id, hr_api.g_number))
        = nvl(p_business_group_id, hr_api.g_number);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_legislation_code := nvl(p_legislation_code
                           ,hr_api.return_legislation_code
                               (p_business_group_id));

  Open csr_bal_type_id;
  Fetch csr_bal_type_id into l_exists;
  If csr_bal_type_id%notfound Then
    --
    Close csr_bal_type_id;
    fnd_message.set_name('PAY','PAY_34154_LEG_BUS_MISMATCH');
    fnd_message.set_token('ENTITY1','INITIAL BALANCE FEED');
    fnd_message.set_token('ENTITY2','BALANCE');
    fnd_message.raise_error;
    --
  End If;
  Close csr_bal_type_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------< chk_bal_class_exists >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that for a balance_type_id if there
--   already exists a balance classification that feeds the balance then the
--   insert/update/delete balance feed operation cannot be performed.
--
-- In Arguments:
--   The balance type id for which feed is being created/updated/deleted
--
-- Post Success:
--   Processing continues and balance feed is inserted/updated/deleted
--
-- Post Failure:
--   An application error is raised if a balance classification already exists
--   for the balance to which feed is being created/updated/deleted.
--
-- {End Of Comments}

procedure chk_bal_class_exists
           (p_balance_type_id number) is
--
l_proc        varchar2(72) := g_package||'chk_bal_class_exists';

   cursor csr_classifications_exist is
   select bcl.classification_id
     from pay_balance_classifications bcl
    where bcl.balance_type_id = p_balance_type_id;
--
   l_classification_id number;
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--
   open csr_classifications_exist;
   fetch csr_classifications_exist into l_classification_id;
   if csr_classifications_exist%found then
     close csr_classifications_exist;
     fnd_message.set_name('PAY','HR_7444_BAL_FEED_READ_ONLY');
     fnd_message.raise_error;
   else
     close csr_classifications_exist;
   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);
--
 end chk_bal_class_exists;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_initial_feed_exists >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that when creating a feed for a
--   balance, no initial balance feed already exists for that balance
--
-- In Arguments:
--   The balance type id for which feed is being created
--
-- Post Success:
--   Processing continues and balance feed is inserted
--
-- Post Failure:
--   An application error is raised if an initial feed already exists
--   for the balance to which feed is being created.
--
-- {End Of Comments}

procedure chk_initial_feed_exists
           (p_balance_type_id   in number
           ,p_business_group_id in pay_balance_feeds_f.business_group_id%type
           ,p_legislation_code  in pay_balance_feeds_f.legislation_code%type
           ) is
--
l_proc        varchar2(72) := g_package||'chk_initial_feed_exists';
l_legislation_code per_business_groups.legislation_code%type;

CURSOR csr_initial_feed_exist IS
SELECT 1
FROM   pay_balance_feeds_f         blf,
       pay_input_values_f          inv,
       pay_element_types_f         elt,
       pay_element_classifications ec
WHERE  blf.balance_type_id   = p_balance_type_id
AND    blf.input_value_id    = inv.input_value_id
AND    inv.element_type_id   = elt.element_type_id
AND    nvl(elt.legislation_code
          ,nvl(l_legislation_code, '~nvl~'))
         = nvl(l_legislation_code, '~nvl~')
AND    nvl(elt.business_group_id
          ,nvl(p_business_group_id, -1))
         = nvl(p_business_group_id, -1)
AND    elt.classification_id = ec.classification_id
AND    ec.balance_initialization_flag ='Y';

--
   l_balance_initialization_flag varchar2(30);
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--

   l_legislation_code := nvl(p_legislation_code
                           ,hr_api.return_legislation_code
                                (p_business_group_id));

   open csr_initial_feed_exist;
   fetch csr_initial_feed_exist into l_balance_initialization_flag;
   if csr_initial_feed_exist%found then
     close csr_initial_feed_exist;
     fnd_message.set_name('PAY','HR_7875_BAL_FEED_HAS_INIT_FEED');
     fnd_message.raise_error;
   else
     close csr_initial_feed_exist;
   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);
--
 end chk_initial_feed_exists;
--
-- ---------------------------------------------------------------------------
-- |-------------------------------< chk_uom >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure the UOM of the input value and the balance
--   must match ie. be in the same class
--
-- In Arguments:
--   The input value id and the balance type id for which feed is being created
--
-- Post Success:
--   Processing continues and balance feed is created.
--
-- Post Failure:
--   An application error is raised if the uom of the balance for which feed is
--   being created and that of the input value do not match.
--
-- {End Of Comments}
procedure chk_uom
           (p_input_value_id  number
	   ,p_balance_type_id number
	   ,p_effective_date  date) is
--
l_proc        varchar2(72) := g_package||'chk_uom';

CURSOR  csr_bal_uom IS
SELECT  pbt.balance_uom
FROM    pay_balance_types pbt
WHERE   pbt.balance_type_id = p_balance_type_id;
--
CURSOR  csr_ipv_uom IS
SELECT  piv.uom
FROM    pay_input_values_f piv
WHERE   piv.input_value_id = p_input_value_id
AND     p_effective_date between piv.effective_start_date
AND     piv.effective_end_date;
--
   l_bal_uom varchar2(30);
   l_ipv_uom varchar2(30);
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--
   open csr_bal_uom;
   fetch csr_bal_uom into l_bal_uom;
   close csr_bal_uom;
--
   open csr_ipv_uom;
   fetch csr_ipv_uom into l_ipv_uom;
   close csr_ipv_uom;
--
   if substr(l_bal_uom,1,1) <> substr(l_ipv_uom,1,1) then
      fnd_message.set_name('PAY','HR_6553_BAL_WRONG_UOM');
      fnd_message.raise_error;
   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);
--
 end chk_uom;
-- ---------------------------------------------------------------------------
-- |--------------------------< chk_currency_match >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure the output currency code of the input
--   value that feeds the balance and the currency code of the balance must
--   match if the UOM of the balance is of type 'Money'
--
-- In Arguments:
--   The input value id and the balance type id for which feed is being created
--
-- Post Success:
--   Processing continues and balance feed is created.
--
-- Post Failure:
--   An application error is raised if the currency codes do not match
--
-- {End Of Comments}

procedure chk_currency_match
           (p_input_value_id number
	   ,p_balance_type_id number) is
--
l_proc        varchar2(72) := g_package||'chk_currency_match';

CURSOR csr_balance_uom IS
SELECT balance_uom
FROM   pay_balance_types
WHERE  balance_type_id = p_balance_type_id;

CURSOR csr_currency_match IS
SELECT 1
FROM   pay_balance_types pbt,
       pay_input_values_f piv,
       pay_element_types_f pet
WHERE  pbt.balance_type_id = p_balance_type_id
AND    piv.input_value_id = p_input_value_id
AND    pet.element_type_id = piv.element_type_id
AND    pbt.currency_code = pet.output_currency_code;

--
   l_exists number;
   l_uom    varchar2(30);
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--
   open csr_balance_uom;
   fetch csr_balance_uom into l_uom;
   if csr_balance_uom%found then
      close csr_balance_uom;
      if (l_uom = 'M') then
         open csr_currency_match;
         fetch csr_currency_match into l_exists;
         if csr_currency_match%notfound then
            close csr_currency_match;
            fnd_message.set_name('PAY','PAY_33246_BF_CUR_MISMATCH');
            fnd_message.raise_error;
         else
            close csr_currency_match;
         end if;
      end if;
   else
      close csr_balance_uom;
   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);

end chk_currency_match;
--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_scale_value >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that valid value for Scale is entered for
--   the feed that is being created.
--
-- In Arguments:
--   The scale and the effective date on which feed is created or updated.
--
-- Post Success:
--   Processing continues and balance feed is created.
--
-- Post Failure:
--   An application error is raised if the value for scale does not exist in
--   hr_lookups table for lookup_type 'ADD_SUBTRACT'
--
-- {End Of Comments}

procedure chk_scale_value
           (p_scale          number
	   ,p_input_value_id number
	   ,p_effective_date date) is
--
l_proc        varchar2(72) := g_package||'chk_scale_value';

--
   l_exists number;
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--
   if hr_api.NOT_EXISTS_IN_HR_LOOKUPS
                    (p_effective_date => p_effective_date
		    ,p_lookup_type    => 'ADD_SUBTRACT'
		    ,p_lookup_code    => p_scale
		    )
   then
     fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
     fnd_message.raise_error;
   end if;

   --
   hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'input_value_id'
      ,p_argument_value => p_input_value_id
      );
   --

   -- Scale value must only be 1 when initial balance feed is being created

   if get_balance_init_flag (p_input_value_id => p_input_value_id)  and p_scale <> 1 then
        fnd_message.set_name('PAY','PAY_33242_BIFEED_INV_SCALE');
	fnd_message.raise_error;
   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);

end chk_scale_value;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< chk_bal_feed_unique >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that balance feeds are date-effectively
--   unique ie. an input value cannot have two balance feeds to the same balance
--   type at the same point in (date-effective) time
--
-- In Arguments:
--   The balance_type_id, input_value_id, effective_start_date and
--   effective_end_date on which feed is being created.
--
-- Post Success:
--   Processing continues and balance feed is created.
--
-- Post Failure:
--   An application error is raised if balance feed already exists for the input
--   value id in the same date-effective time.
--
-- {End Of Comments}

procedure chk_bal_feed_unique
           (p_input_value_id  number
	   ,p_balance_type_id number
	   ,p_effective_date  date) is
--
l_proc        varchar2(72) := g_package||'chk_bal_feed_unique';

CURSOR csr_bal_feed_unique IS
SELECT 1
FROM   pay_balance_feeds_f
WHERE  input_value_id = p_input_value_id
AND    balance_type_id =p_balance_type_id
AND    p_effective_date between effective_start_date and effective_end_date;

--
   l_exists number;
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--
   open csr_bal_feed_unique;
   fetch csr_bal_feed_unique into l_exists;
   if csr_bal_feed_unique%found then
     close csr_bal_feed_unique;
     fnd_message.set_name('PAY','HR_6109_BAL_UNI_FEED');
     fnd_message.raise_error;
   else
     close csr_bal_feed_unique;
   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);

end chk_bal_feed_unique;
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< chk_feed_ipv_life >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that balance feeds cannot be created
--   outside the life-time of the input value that feeds the balance.
--
-- In Arguments:
--   The input_value_id, and the effective_date on which feed is being created.
--
-- Post Success:
--   Processing continues and balance feed is created.
--
-- Post Failure:
--   An application error is raised if balance feed being created is outside the
--   the life-time of the input value that feeds the balance.
--
-- {End Of Comments}

procedure chk_feed_ipv_life
           (p_input_value_id       number
	   ,p_effective_date       date) is
--
l_proc        varchar2(72) := g_package||'chk_feed_ipv_life';

CURSOR csr_feed_ipv_value IS
SELECT 1
FROM   pay_input_values_f
WHERE  input_value_id = p_input_value_id
AND    p_effective_date between effective_start_date and effective_end_date;
--
  l_exists number;
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--
   open csr_feed_ipv_value;
   fetch csr_feed_ipv_value into l_exists;

   if(csr_feed_ipv_value%notfound) then
      close csr_feed_ipv_value;
   --raise error since balance feed is outside the life-time of the input value
      fnd_message.set_name('PAY','HR_7048_BAL_FEED_PAST_INP_VAL');
      fnd_message.raise_error;
   else
      close csr_feed_ipv_value;
   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);

end chk_feed_ipv_life;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< chk_dtupd_allowed >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that date effective update is not
--   allowed for initial balance feeds.
--
-- In Arguments:
--   Date track mode for the operation
--
-- Post Success:
--   Processing continues and balance feed is updated.
--
-- Post Failure:
--   An error is raised if date effective update is attempted on
--   an initial balance feed.
--
-- {End Of Comments}

procedure chk_dtupd_allowed
           (p_datetrack_mode  in varchar2
	   ,p_input_value_id  in number
	   ) is
--
l_proc        varchar2(72) := g_package||'chk_dtupd_allowed';
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--

   --
   hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'input_value_id'
      ,p_argument_value => p_input_value_id
      );
   --

   -- Date effective update must not be allowed for the initial balance feed.
   --

   if get_balance_init_flag (p_input_value_id => p_input_value_id) and
		p_datetrack_mode <> hr_api.g_correction then

      fnd_message.set_name('PAY','PAY_33244_BIFEED_INV_ACTION');
      fnd_message.set_token('ACTION', 'UPDATE');
      fnd_message.set_token('MODE', p_datetrack_mode);
      fnd_message.raise_error;

   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);

end chk_dtupd_allowed;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< chk_dtdel_allowed >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that date effective delete is not
--   allowed for initial balance feeds.
--
-- In Arguments:
--   Date track mode for the operation
--
-- Post Success:
--   Processing continues and balance feed is deleted.
--
-- Post Failure:
--   An error is raised if date effective delete is attempted on
--   an initial balance feed.
--
-- {End Of Comments}

procedure chk_dtdel_allowed
           (p_datetrack_mode  in varchar2
	   ,p_input_value_id  in number
	   ) is
--
l_proc        varchar2(72) := g_package||'chk_dtdel_allowed';
--
 begin

 hr_utility.set_location('Entering:'||l_proc, 5);
--

  --
  hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'input_value_id'
      ,p_argument_value => p_input_value_id
      );
  --

  --
  -- Date effective delete must not be allowed for the initial balance feed.
  --

   if get_balance_init_flag( p_input_value_id => p_input_value_id)
           and p_datetrack_mode <> hr_api.g_zap then

      fnd_message.set_name('PAY','PAY_33244_BIFEED_INV_ACTION');
      fnd_message.set_token('ACTION', 'DELETE');
      fnd_message.set_token('MODE', p_datetrack_mode);
      fnd_message.raise_error;

   end if;
--
   hr_utility.set_location(' Leaving:'||l_proc, 10);

end chk_dtdel_allowed;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_pbf_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_initial_feed	   in boolean
  ,p_exist_run_result_warning	out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
  l_validation_end_date date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Clearing the Global variable since the record may have been changed.
  --
  g_balance_init_flag := NULL;
  --

  --
  -- Call all supporting business operations
  --

  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_pbf_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Validate the following before actually inserting balance feed
  --
     pay_pbf_bus.chk_business_group_id
                 (p_business_group_id  => p_rec.business_group_id
		 ,p_input_value_id     => p_rec.input_value_id
		 ,p_effective_date     => p_effective_date
		 );
  --

     pay_pbf_bus.chk_legislation_code
                 (p_legislation_code   => p_rec.legislation_code
		 );
  --

     pay_pbf_bus.chk_input_value_id
                 (p_input_value_id     => p_rec.input_value_id
		 ,p_business_group_id  => p_rec.business_group_id
		 ,p_legislation_code    => p_rec.legislation_code
		 );
  --

     pay_pbf_bus.chk_balance_type_id
                 (p_balance_type_id    => p_rec.balance_type_id
 		 ,p_business_group_id  => p_rec.business_group_id
		 ,p_legislation_code    => p_rec.legislation_code
		 );
  --
     pay_pbf_bus.chk_uom
                 (p_input_value_id    => p_rec.input_value_id
		 ,p_balance_type_id   => p_rec.balance_type_id
		 ,p_effective_date    => p_effective_date
		 );
  --

     pay_pbf_bus.chk_currency_match
                 (p_input_value_id    => p_rec.input_value_id
		 ,p_balance_type_id   => p_rec.balance_type_id
		 );
  --

     pay_pbf_bus.chk_bal_feed_unique
                 (p_input_value_id       => p_rec.input_value_id
		 ,p_balance_type_id      => p_rec.balance_type_id
		 ,p_effective_date	 => p_effective_date
		 );
  --

     pay_pbf_bus.chk_bal_class_exists
                 (p_balance_type_id         => p_rec.balance_type_id);

  --
     -- When called from STARTUP Mode ignore this validation. Bug #8721639
     IF hr_startup_data_api_support.g_startup_mode NOT IN ('STARTUP') THEN
     -- If trying to create an initial feed then check no other initial feed
     -- already exists
     if (get_balance_init_flag (p_input_value_id => p_rec.input_value_id) ) then
         pay_pbf_bus.chk_initial_feed_exists
                     (p_balance_type_id    => p_rec.balance_type_id
        	     ,p_business_group_id  => p_rec.business_group_id
		     ,p_legislation_code    => p_rec.legislation_code
		     );
     end if;
     END IF; -- added for Bug #8721639

  --

     pay_pbf_bus.chk_feed_ipv_life
                 (p_input_value_id	    => p_rec.input_value_id
		 ,p_effective_date	    => p_effective_date
		 );

  --
     -- When creating a balance feed derive the end date
     -- ie. input value may be date effectively deleted in
     -- the future or there are future balance feeds.
     l_validation_end_date := hr_balance_feeds.bal_feed_end_date
                                  (null,
                                   p_rec.balance_type_id,
                                   p_rec.input_value_id,
                                   p_effective_date,
                                   p_validation_start_date);

     if hr_balance_feeds.bf_chk_proc_run_results
          ('BALANCE_FEED',
           'INSERT',
           null, null, null, null, null,
           p_rec.input_value_id,
           p_validation_start_date,
           l_validation_end_date) then

	   fnd_message.set_name('PAY','HR_7876_BAL_FEED_RESULTS_EXIST');
           p_exist_run_result_warning :=TRUE;

     end if;

     -- When called from STARTUP Mode ignore this validation. Bug #8721639
     IF hr_startup_data_api_support.g_startup_mode NOT IN ('STARTUP') THEN

     -- When initial balance feed is being created, the effective end date must be
     -- hr_api.g_eot.

     if get_balance_init_flag (p_input_value_id => p_rec.input_value_id)
               and l_validation_end_date <> hr_api.g_eot then
        fnd_message.set_name('PAY','PAY_33243_BIFEED_INV_EDATE');
	fnd_message.raise_error;
     end if;

     END IF; -- added for Bug #8721639

  --
  -- Validate Dependent Attributes
  --
     pay_pbf_bus.chk_scale_value
                 (p_scale          => p_rec.scale
		 ,p_input_value_id => p_rec.input_value_id
		 ,p_effective_date => p_effective_date
		 );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_pbf_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ,p_exist_run_result_warning out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  -- Clearing the Global variable since the record may have been changed.
  --
  g_balance_init_flag := NULL;
  --

  chk_dtupd_allowed ( p_datetrack_mode => p_datetrack_mode
                     ,p_input_value_id => p_rec.input_value_id );

  --
  -- Call all supporting business operations
  --
  -- Check that the fields which cannot be updated have not be changed

  chk_non_updateable_args(p_effective_date   => p_effective_date
		           ,p_rec            => p_rec
        		   );

  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_pbf_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate the following before actually updating balance feed
  --
    pay_pbf_bus.chk_bal_class_exists
      (p_balance_type_id         => p_rec.balance_type_id);
  --
    if hr_balance_feeds.bf_chk_proc_run_results
         ('BALANCE_FEED'
         ,'UPDATE_DELETE'
         ,null, null, null
         ,p_rec.balance_feed_id
         ,null, null
         ,p_validation_start_date
         ,p_validation_end_date
         ) then
       fnd_message.set_name('PAY','HR_7876_BAL_FEED_RESULTS_EXIST');
       p_exist_run_result_warning :=TRUE;
    end if;
  --
  -- Validate Dependent Attributes
  --
       pay_pbf_bus.chk_scale_value
                 (p_scale          => p_rec.scale
		 ,p_input_value_id => p_rec.input_value_id
		 ,p_effective_date => p_effective_date
		 );
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
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
  (p_rec                    in pay_pbf_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_exist_run_result_warning out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
  l_validation_end_date date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  -- Clearing the Global variable since the record may have been changed.
  --
  g_balance_init_flag := NULL;
  --

  --
  -- When called from STARTUP Mode ignore this validation. Bug #8721639
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('STARTUP') THEN
     chk_dtdel_allowed ( p_datetrack_mode => p_datetrack_mode
                     ,p_input_value_id => p_rec.input_value_id);
  END IF; -- added for Bug #8721639


  chk_startup_action(false
                    ,pay_pbf_shd.g_old_rec.business_group_id
                    ,pay_pbf_shd.g_old_rec.legislation_code
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

      -- If extending the lifetime of a balance feed derive the end date ie. input
     -- value may be date effectively deleted in the future or there are future
     -- future balance feeds.
     if (p_datetrack_mode = 'FUTURE_CHANGE' or
        (p_datetrack_mode = 'DELETE_NEXT_CHANGE' and
         p_validation_end_date = hr_api.g_eot)) then
       l_validation_end_date := hr_balance_feeds.bal_feed_end_date
                                    (p_rec.balance_feed_id,
                                     p_rec.balance_type_id,
                                     p_rec.input_value_id,
                                     p_effective_date,
                                     p_validation_start_date);
     end if;

     if hr_balance_feeds.bf_chk_proc_run_results
          ('BALANCE_FEED',
           'UPDATE_DELETE',
           null, null, null,
           p_rec.balance_feed_id,
           null, null,
           p_validation_start_date,
           l_validation_end_date) then

	   fnd_message.set_name('PAY','HR_7876_BAL_FEED_RESULTS_EXIST');
           p_exist_run_result_warning :=TRUE;

     end if;
 --

     pay_pbf_bus.chk_bal_class_exists
                 (p_balance_type_id         => p_rec.balance_type_id);

  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_balance_feed_id                  => p_rec.balance_feed_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------< get_balance_init_flag >-------------------------|
--  ---------------------------------------------------------------------------
--
Function get_balance_init_flag
  (p_input_value_id  in  number)
  Return boolean Is
  --
  -- Declare cursor
  --
  cursor csr_balance_init_flag is
	SELECT 1
	        FROM   pay_input_values_f     inv,
		       pay_element_types_f    elt,
		       pay_element_classifications ec
		WHERE  inv.input_value_id = p_input_value_id
		AND    inv.element_type_id = elt.element_type_id
		AND    elt.classification_id = ec.classification_id
		AND    ec.balance_initialization_flag = 'Y';

  --
  -- Declare local variables
  --
  l_exists varchar2(1);
  l_proc  varchar2(72)  :=  g_package||'get_balance_init_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
    if g_balance_init_flag is null then

	open  csr_balance_init_flag;
	fetch csr_balance_init_flag into l_exists;

	if csr_balance_init_flag%found then
		g_balance_init_flag := true;
	else
		g_balance_init_flag := false;
	end if;

	close csr_balance_init_flag;

    end if;

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return g_balance_init_flag;
  --
End get_balance_init_flag;
--
--
end pay_pbf_bus;

/
