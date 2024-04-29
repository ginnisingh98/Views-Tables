--------------------------------------------------------
--  DDL for Package Body BEN_BBP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BBP_BUS" as
/* $Header: bebbprhi.pkb 120.0 2005/05/28 00:34:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bbp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_batch_parameter_id >-----------------------|
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
--   batch_parameter_id PK of record being inserted or updated.
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
Procedure chk_batch_parameter_id(p_batch_parameter_id          in number,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_batch_parameter_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bbp_shd.api_updating
    (p_batch_parameter_id          => p_batch_parameter_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_batch_parameter_id,hr_api.g_number)
     <>  ben_bbp_shd.g_old_rec.batch_parameter_id) then
    --
    -- raise error as PK has changed
    --
    ben_bbp_shd.constraint_error('BEN_BATCH_PARAMETER_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_batch_parameter_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bbp_shd.constraint_error('BEN_BATCH_PARAMETER_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_batch_parameter_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_batch_exe_cd >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_parameter_id PK of record being inserted or updated.
--   batch_exe_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_batch_exe_cd(p_batch_parameter_id         in number,
                           p_batch_exe_cd               in varchar2,
                           p_effective_date             in date,
                           p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_batch_exe_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bbp_shd.api_updating
    (p_batch_parameter_id          => p_batch_parameter_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_batch_exe_cd
      <> nvl(ben_bbp_shd.g_old_rec.batch_exe_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_batch_exe_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BATCH_EXE',
           p_lookup_code    => p_batch_exe_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_batch_exe_cd');
      fnd_message.set_token('TYPE','BEN_BATCH_EXE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_batch_exe_cd;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_batch_parameters >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_parameter_id    PK of record being inserted or updated.
--   thread_cnt_num        Number of threads.
--   max_err_num           Max number of errors.
--   chunk_size            Chunk size of threads.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_batch_parameters(p_batch_parameter_id    in number,
                               p_object_version_number in number,
                               p_thread_cnt_num        in number,
                               p_max_err_num           in number,
                               p_chunk_size            in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_batch_parameters';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bbp_shd.api_updating
    (p_batch_parameter_id          => p_batch_parameter_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_thread_cnt_num
      <> nvl(ben_bbp_shd.g_old_rec.thread_cnt_num,hr_api.g_number)
      or not l_api_updating)
      and p_thread_cnt_num is not null then
    --
    -- check if thread count between 1 and 80.
    --
    if p_thread_cnt_num not between 1 and 80 then
      --
      -- raise error as too large a value for the number of threads.
      --
      fnd_message.set_name('BEN','BEN_91934_NUMBER_OF_THREADS');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_max_err_num
      <> nvl(ben_bbp_shd.g_old_rec.max_err_num,hr_api.g_number)
      or not l_api_updating)
      and p_max_err_num is not null then
    --
    -- check if thread count between 1 and 80.
    --
    if p_max_err_num not between 0 and 90000 then
      --
      -- raise error as too large a value for the number of errors.
      --
      fnd_message.set_name('BEN','BEN_91935_MAX_NUMBER_ERRORS');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_chunk_size
      <> nvl(ben_bbp_shd.g_old_rec.chunk_size,hr_api.g_number)
      or not l_api_updating)
      and p_chunk_size is not null then
    --
    -- check if thread count between 1 and 80.
    --
    if p_chunk_size not between 1 and 200 then
      --
      -- raise error as too large a value for the number of threads.
      --
      fnd_message.set_name('BEN','BEN_91936_CHUNK_SIZE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_batch_parameters;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_batch_exe_cd_unique >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the executable parameters have been
--   set once per business group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   batch_parameter_id    PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--   batch_exe_cd          executable lookup code
--   business_group_id     business group.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_batch_exe_cd_unique(p_batch_parameter_id    in number,
                                  p_object_version_number in number,
                                  p_batch_exe_cd          in varchar2,
                                  p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_batch_exe_cd_unique';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_batch_parameter
    where  business_group_id = p_business_group_id
    and    batch_exe_cd = p_batch_exe_cd
    and    batch_parameter_id <> nvl(p_batch_parameter_id,-1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bbp_shd.api_updating
    (p_batch_parameter_id          => p_batch_parameter_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_batch_exe_cd
      <> nvl(ben_bbp_shd.g_old_rec.batch_exe_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_batch_exe_cd is not null then
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_91937_RECORD_ALREADY_SAVED');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_batch_exe_cd_unique;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_bbp_shd.g_rec_type
                         ,p_effective_date in date) is
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
  chk_batch_parameter_id
  (p_batch_parameter_id    => p_rec.batch_parameter_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_batch_exe_cd
  (p_batch_parameter_id    => p_rec.batch_parameter_id,
   p_batch_exe_cd          => p_rec.batch_exe_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_batch_parameters
  (p_batch_parameter_id    => p_rec.batch_parameter_id,
   p_object_version_number => p_rec.object_version_number,
   p_thread_cnt_num        => p_rec.thread_cnt_num,
   p_max_err_num           => p_rec.max_err_num,
   p_chunk_size            => p_rec.chunk_size);
  --
  chk_batch_exe_cd_unique
  (p_batch_parameter_id    => p_rec.batch_parameter_id,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id,
   p_batch_exe_cd          => p_rec.batch_exe_cd);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_bbp_shd.g_rec_type
                         ,p_effective_date in date) is
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
  chk_batch_parameter_id
  (p_batch_parameter_id    => p_rec.batch_parameter_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_batch_exe_cd
  (p_batch_parameter_id    => p_rec.batch_parameter_id,
   p_batch_exe_cd          => p_rec.batch_exe_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_batch_parameters
  (p_batch_parameter_id    => p_rec.batch_parameter_id,
   p_object_version_number => p_rec.object_version_number,
   p_thread_cnt_num        => p_rec.thread_cnt_num,
   p_max_err_num           => p_rec.max_err_num,
   p_chunk_size            => p_rec.chunk_size);
  --
  chk_batch_exe_cd_unique
  (p_batch_parameter_id    => p_rec.batch_parameter_id,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id,
   p_batch_exe_cd          => p_rec.batch_exe_cd);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_bbp_shd.g_rec_type
                         ,p_effective_date in date) is
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
  (p_batch_parameter_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_batch_parameter b
    where b.batch_parameter_id      = p_batch_parameter_id
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
                             p_argument       => 'batch_parameter_id',
                             p_argument_value => p_batch_parameter_id);
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
end ben_bbp_bus;

/
