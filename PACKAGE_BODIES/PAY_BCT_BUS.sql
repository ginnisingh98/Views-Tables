--------------------------------------------------------
--  DDL for Package Body PAY_BCT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BCT_BUS" as
/* $Header: pybctrhi.pkb 120.0.12000000.4 2007/08/20 08:21:49 ayegappa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_bct_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_batch_control_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_batch_control_id                     in number
  ) is
  --
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- pay_batch_control_totals and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_batch_control_totals bct
         , pay_batch_headers bth
     where bct.batch_control_id = p_batch_control_id
       and bth.batch_id = bct.batch_id
       and pbg.business_group_id = bth.business_group_id;
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
    ,p_argument           => 'batch_control_id'
    ,p_argument_value     => p_batch_control_id
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
  (p_batch_control_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- pay_batch_control_totals and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pay_batch_control_totals bct
         , pay_batch_headers bth
     where bct.batch_control_id = p_batch_control_id
       and bth.batch_id = bct.batch_id
       and pbg.business_group_id = bth.business_group_id;
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
    ,p_argument           => 'batch_control_id'
    ,p_argument_value     => p_batch_control_id
    );
  --
  if ( nvl(pay_bct_bus.g_batch_control_id, hr_api.g_number)
       = p_batch_control_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_bct_bus.g_legislation_code;
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
    pay_bct_bus.g_batch_control_id  := p_batch_control_id;
    pay_bct_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_bct_shd.g_rec_type
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
  IF NOT pay_bct_shd.api_updating
      (p_batch_control_id                     => p_rec.batch_control_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.batch_id, hr_api.g_number) <>
     pay_bct_shd.g_old_rec.batch_id then
     l_argument := 'batch_id';
     raise l_error;
  end if;
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
-- |-----------------------< chk_transferred_status >-------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Check whether the existing batch control is transferred or not. If it
--    is transferred then raise error.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_control_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_transferred_status (p_batch_control_id number) Is
--
  cursor csr_status is
     select 'Y'
       from pay_batch_control_totals pct
      where pct.batch_control_id = p_batch_control_id
        and pct.control_status = 'T';
  --
  l_transferred varchar2(1);
  --
Begin
  --
  open csr_status;
  fetch csr_status into l_transferred;
  if csr_status%found then
     close csr_status;
     Fnd_Message.Set_Name('PER', 'HR_289754_BEE_REC_TRANSFERRED');
     fnd_message.raise_error;
  end if;
  --
  close csr_status;
  --
End chk_transferred_status;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_batch_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert BATCH_ID is not null and that
--    it exists in pay_batch_headers.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_control_id
--    p_batch_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_batch_id
  (p_batch_control_id      in    pay_batch_control_totals.batch_control_id%TYPE,
   p_batch_id           in    pay_batch_control_totals.batch_id%TYPE
   ) is
--
 l_proc  varchar2(72) := g_package||'chk_batch_id';
 l_dummy number;
--
 cursor csr_batch_id_exists is
    select null
    from pay_batch_headers bth
    where bth.batch_id = p_batch_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory batch_id is set
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'BATCH_ID'
    ,p_argument_value     => p_batch_id
    );
  --
  hr_utility.set_location(l_proc, 5);
  --
  --
  --
  -- Only proceed with validation if :
  -- a) on insert (non-updateable param)
  --
  if (p_batch_control_id is null) then
     --
     hr_utility.set_location(l_proc, 10);
     --
     -- Check that the batch_id is in the pay_batch_headers.
     --
       open csr_batch_id_exists;
       fetch csr_batch_id_exists into l_dummy;
       if csr_batch_id_exists%notfound then
          close csr_batch_id_exists;
          pay_bct_shd.constraint_error('PAY_BATCH_CONTROL_TOTALS_FK1');
       end if;
       close csr_batch_id_exists;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_batch_id;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< chk_control_status >-----------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update control_status is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'BATCH_STATUS'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_control_status
--    p_session_date
--    p_batch_control_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_control_status
  (p_control_status        in    pay_batch_control_totals.control_status%TYPE,
   p_session_date          in    date,
   p_batch_control_id      in    pay_batch_control_totals.batch_control_id%TYPE,
   p_object_version_number in    pay_batch_control_totals.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_control_status';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory batch_name exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'control_status'
    ,p_argument_value               => p_control_status
    );
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bct_shd.api_updating
    (p_batch_control_id           => p_batch_control_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bct_shd.g_old_rec.control_status,hr_api.g_varchar2) <>
       nvl(p_control_status,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     --    Validate against the hr_lookup.
     --
     if hr_api.not_exists_in_hr_lookups
        (p_effective_date => p_session_date,
         p_lookup_type    => 'BATCH_STATUS',
         p_lookup_code    => p_control_status) then
         pay_bct_shd.constraint_error('PAY_BCHTOT_CONTROL_STATUS_CHK');
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_control_status;
--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_control_type >-------------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate control_type against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'CONTROL_TYPE'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_control_type
--    p_session_date
--    p_batch_control_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_control_type
  (p_control_type          in    pay_batch_control_totals.control_type%TYPE,
   p_session_date          in    date,
   p_batch_control_id      in    pay_batch_control_totals.batch_control_id%TYPE,
   p_object_version_number in    pay_batch_control_totals.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_control_type';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bct_shd.api_updating
    (p_batch_control_id           => p_batch_control_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bct_shd.g_old_rec.control_type,hr_api.g_varchar2) <>
       nvl(p_control_type,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     --    Validate against the hr_lookup.
     --
     if (p_control_type is not null) then
        --
        hr_utility.set_location(l_proc,35);
        --
        --    Validate against the hr_lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_session_date,
            p_lookup_type    => 'CONTROL_TYPE',
            p_lookup_code    => p_control_type) then
            fnd_message.set_name('PAY','HR_7462_PLK_INVLD_VALUE');
            fnd_message.set_token('COLUMN_NAME','CONTROL_TYPE');
            fnd_message.raise_error;
        end if;
        --
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_control_type;
--
-- added for bug 6013383
-- checks for the format of the number passed as control total
-- User can enter value in display format (e.g. 99,999.9 OR 99.999,99 depending upon the ICX format)
-- it checks for the correct format and gives error if format is Invalid.
-- In insert_dml() and update_dml() , it is converted to database format (99999.99)
--
-- ---------------------------------------------------------------------------
procedure chk_control_total
  (p_control_type          in    pay_batch_control_totals.control_type%TYPE,
   p_control_total         in    pay_batch_control_totals.control_total%TYPE,
   p_batch_id		   in    pay_batch_headers.batch_id%TYPE
 ) is
--
  l_proc  varchar2(72) := g_package||'chk_control_total';
  l_api_updating        boolean;
  l_curr_code		varchar2(10);
  l_control_total_dup	pay_batch_control_totals.control_total%TYPE;
  l_control_total_dup1	pay_batch_control_totals.control_total%TYPE;

  l_range_flag varchar2(2):='F';

--
begin

  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_control_total_dup := p_control_total ;

 -- gets currency_code
  select CURRENCY_CODE into l_curr_code
  from PER_BUSINESS_GROUPS perbg,
      pay_batch_headers pybeeh
  where perbg.BUSINESS_GROUP_ID = pybeeh.BUSINESS_GROUP_ID and
	pybeeh.batch_id = p_batch_id;
  --

  if p_control_type like '%_TOTAL_%' OR p_control_type like '%_COUNT_%' then

     hr_utility.set_location('Validating Control_Total Number format' || l_proc ,20) ;

	hr_chkfmt.checkformat ( l_control_total_dup  ,
                       'NUMBER' ,
                       l_control_total_dup1,
                       null ,
                       null ,
		       'N'  ,
		       l_range_flag,
                       null );

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
end chk_control_total;
--
-- ---------------------------------------------------------------------------
-- |-------------------------------< chk_delete >----------------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Check if there is no child row exists in
--    PAY_MESSAGE_LINES.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_control_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_delete
  (p_batch_control_id                    in    pay_batch_control_totals.batch_control_id%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_exists   varchar2(1);
--
  cursor csr_message_lines is
    select null
    from   pay_message_lines pml
    where  pml.source_id = p_batch_control_id
    and    pml.source_type = 'C';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'batch_control_id'
    ,p_argument_value               => p_batch_control_id
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_message_lines;
  --
  fetch csr_message_lines into l_exists;
  --
  If csr_message_lines%found Then
    --
    close csr_message_lines;
    --
    fnd_message.set_name('PAY','PAY_34576_BHT_CHILD_EXISTS');
    fnd_message.raise_error;
    --
  End If;
  --
  close csr_message_lines;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_session_date                 in date,
   p_rec                          in pay_bct_shd.g_rec_type
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
  hr_utility.set_location(l_proc, 10);
  --
  chk_batch_id(p_batch_control_id => p_rec.batch_control_id
                  ,p_batch_id => p_rec.batch_id);
  --
  pay_bth_bus.set_security_group_id(p_batch_id => p_rec.batch_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_control_status(p_control_status => p_rec.control_status
                  ,p_session_date => p_session_date
                  ,p_batch_control_id => p_rec.batch_control_id
                  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_control_type(p_control_type => p_rec.control_type
                  ,p_session_date => p_session_date
                  ,p_batch_control_id => p_rec.batch_control_id
                  ,p_object_version_number => p_rec.object_version_number);
  --
 -- added for bug 6013383
  chk_control_total
  (p_control_type          => p_rec.control_type,
   p_control_total         => p_rec.control_total,
   p_batch_id		   => p_rec.batch_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_session_date                 in date,
   p_rec                          in pay_bct_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  pay_bct_bus.set_security_group_id(p_batch_control_id => p_rec.batch_control_id);
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  chk_transferred_status(p_batch_control_id => p_rec.batch_control_id);
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_control_status(p_control_status => p_rec.control_status
                  ,p_session_date => p_session_date
                  ,p_batch_control_id => p_rec.batch_control_id
                  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_control_type(p_control_type => p_rec.control_type
                  ,p_session_date => p_session_date
                  ,p_batch_control_id => p_rec.batch_control_id
                  ,p_object_version_number => p_rec.object_version_number);
  --
  -- added for bug 6013383
  chk_control_total
  (p_control_type          => p_rec.control_type,
   p_control_total         => p_rec.control_total,
   p_batch_id		   => p_rec.batch_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_bct_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  if payplnk.g_payplnk_call <> true then
     chk_transferred_status(p_batch_control_id => p_rec.batch_control_id);
  end if;
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_delete(p_batch_control_id => p_rec.batch_control_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_bct_bus;

/
