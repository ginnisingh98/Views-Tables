--------------------------------------------------------
--  DDL for Package Body BEN_OLA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OLA_BUS" as
/* $Header: beolarhi.pkb 120.0 2005/05/28 09:51:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ola_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_csr_activities_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   csr_activities_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
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
Procedure chk_csr_activities_id(p_csr_activities_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_csr_activities_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ola_shd.api_updating
    (p_csr_activities_id                => p_csr_activities_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_csr_activities_id,hr_api.g_number)
     <>  ben_ola_shd.g_old_rec.csr_activities_id) then
    --
    -- raise error as PK has changed
    --
    ben_ola_shd.constraint_error('BEN_CSR_ACTIVITIES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_csr_activities_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ola_shd.constraint_error('BEN_CSR_ACTIVITIES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_csr_activities_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_function_name >------|
-- ----------------------------------------------------------------------------
Procedure chk_function_name(p_csr_activities_id          in number,
                             p_function_name              in varchar2,
                             -- p_effective_date             in date,
                             p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_function_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_form_functions_vl ff
    where  ff.function_name = p_function_name;
    /*     ff.application_id = 810 */


  -- Bug 2382144 - Changes to handle Person form localizations
  -- The LOV for Function Name in the On Line Activity form will display
  -- all values for the Lookup Type 'BEN_ON_LINE_ACT' except
  -- the Lookup code 'PERWSHRG-403'.
  -- It will also display all the form function names which have been
  -- created for the Person form - PERWSHRG.

  cursor c2 is
     select null
     from hr_lookups
     where lookup_code  = p_function_name
     and lookup_type    = 'BEN_ON_LINE_ACT'
     and enabled_flag   = 'Y'
     and TRUNC(sysdate) between
           nvl(start_date_active, TRUNC(sysdate))
           and nvl(end_date_active, TRUNC(sysdate))
    union
    select null
    from   fnd_form frm,
           fnd_form_functions fnc
    where  frm.form_name      = 'PERWSHRG'
    and    frm.form_id        = fnc.form_id
    and    frm.application_id = fnc.application_id
    and    fnc.function_name  = p_function_name;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ola_shd.api_updating
    (p_csr_activities_id          => p_csr_activities_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_function_name,hr_api.g_varchar2)
      <> ben_ola_shd.g_old_rec.function_name
      or not l_api_updating)
      and p_function_name is not null then
    --
    -- check if value of function name is valid.
    --
    /* open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        hr_utility.set_message(801,'FUNCTION_DOES_NOT_EXIST');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    */


    -- Bug 2382144 start
    /*
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ON_LINE_ACT',
           p_lookup_code    => p_function_name,
           p_effective_date => sysdate) then
      --
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
        hr_utility.raise_error;
      --
    end if;
    --
    --
    */
    --
    -- check if value of function name is valid.
    --
    --
    open c2;
    --
    -- fetch value from cursor if it returns a record then the
    -- value is valid otherwise its invalid
    --
    fetch c2 into l_dummy;
    if c2%notfound then
    --
      close c2;
      --
      -- raise error
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    close c2;
    --

    -- Bug 2382144 end

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_function_name;
--
-- ----------------------------------------------------------------------------
-- |------< chk_function_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
Procedure chk_function_type(p_csr_activities_id                 in number,
                            p_function_type               in varchar2,
                            -- p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_function_type';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ola_shd.api_updating
    (p_csr_activities_id                => p_csr_activities_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_function_type
      <> nvl(ben_ola_shd.g_old_rec.function_type,hr_api.g_varchar2)
      or not l_api_updating)
      and p_function_type is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_FUNCTION_TYPE',
           p_lookup_code    => p_function_type,
           p_effective_date => sysdate) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_function_type;
--

-- ----------------------------------------------------------------------------
-- |------< chk_duplicate_function_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the duplicate function name and end date is
--   greater than start date


--
Procedure chk_duplicate_function_name(p_csr_activities_id in number,
                            p_function_name in varchar2,
                            p_effective_start_date in date,
                            p_effective_end_date in date,
                            p_business_group_id       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_duplicate_function_name';
  l_dummy        varchar2(1) ;
  Cursor c1 is select null
        from ben_csr_activities
        where (csr_activities_id <> p_csr_activities_id or p_csr_activities_id is null)and
              function_name = p_function_name and
              business_group_id = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 11);
  --
      --
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
         close c1;
      -- raise error as duplicate function name is entered

      --
         fnd_message.set_name('BEN','BEN_92502_BENOLLAC_DUP_FUNC');
         fnd_message.raise_error;
      end if;
      close c1;
      -- check end date is less than start date
      if p_effective_start_date is null and p_effective_end_date is not null then
           fnd_message.set_name('BEN','BEN_92503_END_DT_GRTR_STRT_DT');
           fnd_message.raise_error;
      elsif p_effective_start_date is not null and p_effective_end_date is not null then
          if p_effective_start_date > p_effective_end_date then
             fnd_message.set_name('BEN','BEN_92503_END_DT_GRTR_STRT_DT');
             fnd_message.raise_error;
          end if;
      end if;
      --
    --
  --
  hr_utility.set_location('Leaving:'||l_proc,11);
  --
end chk_duplicate_function_name;
--

-- |------------------------< chk_seq_num_unique >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the activity seqeuence number is
--   unique within a business group for a given date range.
--
-- Pre Conditions
--   chk_duplicate_function_name function already called so as to be sure
--   that start_date is not greater than end_date.
--
-- In Parameters
--   p_csr_activities_id     PK of record being inserted or updated.
--   p_ordr_num              Sequence no.
--   p_business_group_id     Business group id of record being inserted.
--   p_object_version_number Object version number of record being
--                           inserted or updated.
--   p_csr_start_date        Start Date of the record
--   p_csr_end_date          End Date of the record
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
Procedure chk_seq_num_unique(p_csr_activities_id         in number,
                             p_ordr_num                  in number,
                             p_business_group_id         in number,
                             p_object_version_number     in number,
                             p_csr_start_date            in date,
                             p_csr_end_date              in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_seq_num_unique';
  l_dup_rec      number;
  l_api_updating boolean;
  --
  cursor c1 is
    select 1
    from   BEN_CSR_ACTIVITIES bca
    where  bca.business_group_id +0 = p_business_group_id
    and    bca.csr_activities_id <> nvl(p_csr_activities_id,-1)
    and    bca.ordr_num = p_ordr_num
    and	   nvl(bca.end_date, hr_api.g_eot) >= nvl(p_csr_start_date, hr_api.g_sot)
    and    nvl(bca.start_date, hr_api.g_sot) <= nvl(p_csr_end_date, hr_api.g_eot);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ola_shd.api_updating
    (p_csr_activities_id           => p_csr_activities_id,
     p_object_version_number       => p_object_version_number);
  --
  --We need to check the duplicate seq no. when
  --Inserting a new record or
  --Updating ordr_num/start_date/end_date
  --
  if ((l_api_updating
     and ((nvl(p_ordr_num,hr_api.g_number)
	  <> nvl(ben_ola_shd.g_old_rec.ordr_num,hr_api.g_number)) or
	  (nvl(p_csr_start_date,hr_api.g_date)
	  <> nvl(ben_ola_shd.g_old_rec.start_date,hr_api.g_date)) or
	  (nvl(p_csr_end_date,hr_api.g_date)
	  <> nvl(ben_ola_shd.g_old_rec.end_date,hr_api.g_date))
	 ))
     or not l_api_updating) then
    --
    -- Check if order no. is unique
    --
    open c1;
    --
    fetch c1 into l_dup_rec;
    if c1%found then
      close c1;
      --
      -- raise an error for duplicate order no
      --
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
      --
    end if;
    close c1;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_seq_num_unique;
--


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_ola_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_csr_activities_id
  (p_csr_activities_id          => p_rec.csr_activities_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_function_name
  (p_csr_activities_id           => p_rec.csr_activities_id ,
   p_function_name               => p_rec.function_name,
   -- p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_function_type
  (p_csr_activities_id           => p_rec.csr_activities_id,
   p_function_type               => p_rec.function_type,
   -- p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
   chk_duplicate_function_name
                    (p_csr_activities_id => p_rec.csr_activities_id,
                     p_function_name => p_rec.function_name,
                     p_effective_start_date => p_rec.start_date,
                     p_effective_end_date => p_rec.end_date,
                     p_business_group_id => p_rec.business_group_id);
  --
   chk_seq_num_unique
                    (p_csr_activities_id 	=> p_rec.csr_activities_id,
		     p_ordr_num		 	 	=> p_rec.ordr_num,
		     p_business_group_id 	=> p_rec.business_group_id,
		     p_object_version_number=> p_rec.object_version_number,
                     p_csr_start_date 	 	=> p_rec.start_date,
                     p_csr_end_date 	 	=> p_rec.end_date);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_ola_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_csr_activities_id
  (p_csr_activities_id          => p_rec.csr_activities_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_function_name
  (p_csr_activities_id           => p_rec.csr_activities_id ,
   p_function_name               => p_rec.function_name,
   -- p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_function_type
  (p_csr_activities_id           => p_rec.csr_activities_id,
   p_function_type               => p_rec.function_type,
   -- p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
   chk_duplicate_function_name
                    (p_csr_activities_id => p_rec.csr_activities_id,
                     p_function_name => p_rec.function_name,
                     p_effective_start_date => p_rec.start_date,
                     p_effective_end_date => p_rec.end_date,
                     p_business_group_id => p_rec.business_group_id);
  --
   chk_seq_num_unique
                    (p_csr_activities_id 	=> p_rec.csr_activities_id,
		     p_ordr_num		 	 	=> p_rec.ordr_num,
		     p_business_group_id 	=> p_rec.business_group_id,
		     p_object_version_number=> p_rec.object_version_number,
                     p_csr_start_date 	 	=> p_rec.start_date,
                     p_csr_end_date 	 	=> p_rec.end_date);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_ola_shd.g_rec_type) is
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_csr_activities_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_csr_activities b
    where b.csr_activities_id      = p_csr_activities_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'csr_activities_id',
                             p_argument_value => p_csr_activities_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_ola_bus;

/
