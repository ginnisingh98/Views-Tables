--------------------------------------------------------
--  DDL for Package Body BEN_AVR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AVR_BUS" as
/* $Header: beavrrhi.pkb 120.0.12010000.2 2008/08/05 14:04:44 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_avr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_acty_vrbl_rt_id >------|
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
--   acty_vrbl_rt_id PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_acty_vrbl_rt_id(p_acty_vrbl_rt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_vrbl_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_avr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_acty_vrbl_rt_id                => p_acty_vrbl_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_acty_vrbl_rt_id,hr_api.g_number)
     <>  ben_avr_shd.g_old_rec.acty_vrbl_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_avr_shd.constraint_error('BEN_ACTY_VRBL_RT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_acty_vrbl_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_avr_shd.constraint_error('BEN_ACTY_VRBL_RT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_acty_vrbl_rt_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------<chk_vrbl_rt_not_allowed >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  If Uses Variable Rate Falg set to "off", then acty variable rate rule or
--  variable rate rule must be blank for flex credit calculation.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_acty_base_rt_id
--     p_business_group_id
--     p_effective_date
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
Procedure chk_vrbl_rt_not_allowed
          ( p_acty_base_rt_id in number
           ,p_business_group_id in number
           ,p_effective_date in date
	   ,p_validation_start_date in date
	   ,p_validation_end_date  in date)
is
   l_proc  varchar2(72) := g_package||' chk_vrbl_rt_not_allowed ';
   l_dummy char(1);
   cursor c1 is select null
                from ben_acty_base_rt_f
                 where acty_base_rt_id = p_acty_base_rt_id
                   -- and flx_cr_rt_flag = 'Y'
                   and USES_VARBL_RT_FLAG = 'N'
                   and business_group_id + 0 = p_business_group_id
-- bug 3960628
                   and p_validation_start_date <= effective_end_date
                   and p_validation_end_date >= effective_start_date;
--
Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   if p_acty_base_rt_id is not null then
        open c1;
        fetch c1 into l_dummy;
        if c1%found then
               close c1;
               fnd_message.set_name('BEN','BEN_91420_VRBL_RT_RL_NOT_ALWD');
               fnd_message.raise_error;
        end if;
        close c1;
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 15);
   --
End chk_vrbl_rt_not_allowed;
--
-- ----------------------------------------------------------------------------
-- |-----------------<chk_vrbl_rl_rt_profile >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- Only one can attach to the standard rate Variable Rate Profile or
-- Variable Rule.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_acty_base_rt_id
--     p_business_group_id
--     p_effective_date
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
Procedure chk_vrbl_rl_rt_profile
          ( p_acty_base_rt_id in number
           ,p_business_group_id in number
           ,p_effective_date in date )
is
   l_proc  varchar2(72) := g_package||' chk_vrbl_rl_rt_profile ';
   l_dummy char(1);
   cursor c1 is select null
                from ben_vrbl_rt_rl_f
                 where acty_base_rt_id = p_acty_base_rt_id
                   and business_group_id  = p_business_group_id
                   and p_effective_date between effective_start_date
                                            and effective_end_date;
--
Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   if p_acty_base_rt_id is not null then
        open c1;
        fetch c1 into l_dummy;
        if c1%found then
               close c1;
               fnd_message.set_name('BEN','BEN_92987_CHK_FOR_RL_OR_RT');
               fnd_message.raise_error;
        end if;
        close c1;
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 15);
   --
End chk_vrbl_rl_rt_profile;


-- ----------------------------------------------------------------------------
-- --------< BUG 3960415    >----------

-- |------< chk_vrbl_rt_prfl_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that variable rate profile id should not be null.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_acty_vrbl_rt_id  PK
--   p_vrbl_rt_prfl_id

--   p_effective_date session date
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
Procedure chk_vrbl_rt_prfl_id(p_acty_vrbl_rt_id           in number,
                             p_vrbl_rt_prfl_id                 in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_rt_prfl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);


Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_avr_shd.api_updating
     (p_acty_vrbl_rt_id            => p_acty_vrbl_rt_id ,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_vrbl_rt_prfl_id ,hr_api.g_number)
     <> nvl(ben_avr_shd.g_old_rec.vrbl_rt_prfl_id,hr_api.g_number)
     or not l_api_updating) and p_vrbl_rt_prfl_id is null

     then
    --
    fnd_message.set_name('BEN','BEN_94106_VRBL_RT_PRFL_NULL');
    fnd_message.raise_error;

    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_vrbl_rt_prfl_id;



--
-- ---------------------------------------------------------------------------
-- |-----------------------< chk_ordr_num_unique >---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--   ensure that the Sequence Number is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_ordr_num         Sequence Number
--     p_acty_base_rt_id  Acty_Base_Rt_id
--     p_acty_vrbl_rt_id  acty_vrbl_rt_id
--     p_business_group_id
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
Procedure chk_ordr_num_unique
          ( p_acty_vrbl_rt_id      in   number
           ,p_acty_base_rt_id      in   number
           ,p_ordr_num             in   number
           ,p_business_group_id    in   number)
is
l_proc      varchar2(72) := g_package||'chk_ordr_num_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_acty_vrbl_rt_f
             Where  acty_vrbl_rt_id <> nvl(p_acty_vrbl_rt_id,-1)
             and    acty_base_rt_id = p_acty_base_rt_id
             and    ordr_num = p_ordr_num
             and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_ordr_num_unique;
--
-- ----------------------------------------------------------------------------
-- |-----------------<chk_vrbl_rt_cd_for_imput_pln >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  While attaching a vapro to imputed income plan, we need to check
--   whether the VAPRO is based on Flat amount. If not, throw an error.
--  Procedure added as part of bug# 3027365.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_acty_base_rt_id
--     p_vrbl_rt_prfl_id
--     p_business_group_id
--     p_effective_date
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
Procedure chk_vrbl_rt_cd_for_imput_pln
          ( p_acty_base_rt_id in number
           ,p_vrbl_rt_prfl_id in number
           ,p_business_group_id in number
           ,p_effective_date in date )
is
   l_proc  varchar2(72) := g_package||' chk_vrbl_rt_cd_for_imput_pln ';
   l_dummy char(1);
   cursor c1 is select
   		'Y' from ben_acty_base_rt_f abr
   		where abr.acty_base_rt_id=p_acty_base_rt_id
		and abr.business_group_id=p_business_group_id
		and abr.rt_usg_cd='IMPTDINC'
		and p_effective_date between effective_start_date and effective_end_date;

   cursor c2 is select null from ben_vrbl_rt_prfl_f where
	vrbl_rt_prfl_id=p_vrbl_rt_prfl_id
	and business_group_id=p_business_group_id
	and p_effective_date between effective_start_date and effective_end_date
	and mlt_cd in ('FLFX' , 'RL' ) and VRBL_RT_TRTMT_CD ='RPLC';
--
Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   if p_acty_base_rt_id is not null then
        open c1;
        fetch c1 into l_dummy;
        if c1%found then
   		hr_utility.set_location('   Inside:'||l_proc, 15);

               open c2;
               fetch c2 into l_dummy;
               if c2%notfound then
               close c1;
               close c2;
                -- raise error
	           --
	           fnd_message.set_name('BEN','BEN_93476_IMPUT_NOT_VAPRO');
	           fnd_message.raise_error;
    		--
    		end if;
    		close c2;
        end if;
        close c1;
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 15);
   --
End chk_vrbl_rt_cd_for_imput_pln;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_dup_vrbl_rt_prfl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the same variable rate profile is not
--   specified more than once for the same activity base rate
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_acty_vrbl_rt_id PK of record being inserted or updated.
--   p_acty_base_rt_id FK acty_base_rt_id
--   p_vrbl_rt_prfl_id The variable rate specified for this rate
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
Procedure chk_dup_vrbl_rt_prfl(p_acty_vrbl_rt_id       in number,
                               p_acty_base_rt_id       in number,
                               p_vrbl_rt_prfl_id       in number,
                               p_business_group_id     in number,
                               p_effective_date        in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_dup_vrbl_rt_prfl';
  l_dummy        char(1);
  --
  cursor c_dup_vrbl_rt_prfl is
    select null
      from ben_acty_vrbl_rt_f avr
     where avr.acty_base_rt_id = p_acty_base_rt_id
       and avr.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
       and avr.acty_vrbl_rt_id <> nvl(p_acty_vrbl_rt_id, hr_api.g_number)
       and avr.business_group_id = p_business_group_id
       and p_effective_date between avr.effective_start_date and avr.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check if the same variable rate profile is entered more than once
  -- for the same acty_base_rt_id
  --
  open c_dup_vrbl_rt_prfl;
  fetch c_dup_vrbl_rt_prfl into l_dummy;
  if c_dup_vrbl_rt_prfl%found then
    --
    close c_dup_vrbl_rt_prfl;
    --
    -- raise error as duplicate criteria has been entered
    --
    fnd_message.set_name('BEN','BEN_93367_DUP_VAPRO_RL_FOR_ABR');
    fnd_message.raise_error;
    --
  end if;
  --
  close c_dup_vrbl_rt_prfl;
  --
  hr_utility.set_location('Leaving:'||l_proc,15);
  --
end chk_dup_vrbl_rt_prfl;
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
            (p_acty_base_rt_id               in number default hr_api.g_number,
             p_vrbl_rt_prfl_id               in number default hr_api.g_number,
         p_datetrack_mode            in varchar2,
             p_validation_start_date         in date,
         p_validation_end_date       in date) Is
--
  l_proc        varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    If ((nvl(p_acty_base_rt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_acty_base_rt_f',
             p_base_key_column => 'acty_base_rt_id',
             p_base_key_value  => p_acty_base_rt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_vrbl_rt_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_vrbl_rt_prfl_f',
             p_base_key_column => 'vrbl_rt_prfl_id',
             p_base_key_value  => p_vrbl_rt_prfl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_vrbl_rt_prfl_f';
      Raise l_integrity_error;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    -- fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    -- fnd_message.set_token('TABLE_NAME', l_table_name);
    -- fnd_message.raise_error;
    ben_utility.parent_integrity_error(p_table_name => l_table_name);
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
            (p_acty_vrbl_rt_id      in number,
             p_datetrack_mode       in varchar2,
         p_validation_start_date    in date,
         p_validation_end_date  in date) Is
--
  l_proc    varchar2(72)    := g_package||'dt_delete_validate';
  l_rows_exist  Exception;
  l_table_name  all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'acty_vrbl_rt_id',
       p_argument_value => p_acty_vrbl_rt_id);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    /* fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;  */
    ben_utility.child_exists_error(p_table_name => l_table_name);
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
    (p_rec           in ben_avr_shd.g_rec_type,
     p_effective_date    in date,
     p_datetrack_mode    in varchar2,
     p_validation_start_date in date,
     p_validation_end_date   in date) is
--
  l_proc    varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_acty_vrbl_rt_id
  (p_acty_vrbl_rt_id          => p_rec.acty_vrbl_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_vrbl_rt_not_allowed
  ( p_acty_base_rt_id   => p_rec.acty_base_rt_id
    ,p_business_group_id => p_rec.business_group_id
    ,p_effective_date    => p_effective_date
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date => p_validation_end_date);
  --
  chk_vrbl_rl_rt_profile
  ( p_acty_base_rt_id   => p_rec.acty_base_rt_id
    ,p_business_group_id => p_rec.business_group_id
    ,p_effective_date    => p_effective_date );
  --
  -- bug 3960415
 chk_vrbl_rt_prfl_id
  (p_acty_vrbl_rt_id           => p_rec.acty_vrbl_rt_id ,
   p_vrbl_rt_prfl_id           => p_rec.vrbl_rt_prfl_id ,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
--
  chk_ordr_num_unique
  (p_acty_vrbl_rt_id   => p_rec.acty_vrbl_rt_id,
   p_acty_base_rt_id   => p_rec.acty_base_rt_id,
   p_ordr_num          => p_rec.ordr_num,
   p_business_group_id => p_rec.business_group_id);
  --
  chk_dup_vrbl_rt_prfl
  (p_acty_vrbl_rt_id   => p_rec.acty_vrbl_rt_id,
   p_acty_base_rt_id   => p_rec.acty_base_rt_id,
   p_vrbl_rt_prfl_id   => p_rec.vrbl_rt_prfl_id,
   p_business_group_id => p_rec.business_group_id,
   p_effective_date    => p_effective_date);

   chk_vrbl_rt_cd_for_imput_pln
   (p_acty_base_rt_id   => p_rec.acty_base_rt_id,
    p_vrbl_rt_prfl_id   => p_rec.vrbl_rt_prfl_id,
    p_business_group_id => p_rec.business_group_id,
    p_effective_date    => p_effective_date);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
    (p_rec           in ben_avr_shd.g_rec_type,
     p_effective_date    in date,
     p_datetrack_mode    in varchar2,
     p_validation_start_date in date,
     p_validation_end_date   in date) is
--
  l_proc    varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_acty_vrbl_rt_id
  (p_acty_vrbl_rt_id          => p_rec.acty_vrbl_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_vrbl_rt_not_allowed
  ( p_acty_base_rt_id   => p_rec.acty_base_rt_id
    ,p_business_group_id => p_rec.business_group_id
    ,p_effective_date    => p_effective_date
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date => p_validation_end_date);
  --
   -- bug 3960415
  chk_vrbl_rt_prfl_id
  (p_acty_vrbl_rt_id           => p_rec.acty_vrbl_rt_id ,
   p_vrbl_rt_prfl_id           => p_rec.vrbl_rt_prfl_id ,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
--
  chk_ordr_num_unique
  (p_acty_vrbl_rt_id   => p_rec.acty_vrbl_rt_id,
   p_acty_base_rt_id   => p_rec.acty_base_rt_id,
   p_ordr_num          => p_rec.ordr_num,
   p_business_group_id => p_rec.business_group_id);
  --
  chk_dup_vrbl_rt_prfl
  (p_acty_vrbl_rt_id   => p_rec.acty_vrbl_rt_id,
   p_acty_base_rt_id   => p_rec.acty_base_rt_id,
   p_vrbl_rt_prfl_id   => p_rec.vrbl_rt_prfl_id,
   p_business_group_id => p_rec.business_group_id,
   p_effective_date    => p_effective_date);

   chk_vrbl_rt_cd_for_imput_pln
    (p_acty_base_rt_id   => p_rec.acty_base_rt_id,
     p_vrbl_rt_prfl_id   => p_rec.vrbl_rt_prfl_id,
     p_business_group_id => p_rec.business_group_id,
     p_effective_date    => p_effective_date);
  --
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_acty_base_rt_id               => p_rec.acty_base_rt_id,
     p_vrbl_rt_prfl_id               => p_rec.vrbl_rt_prfl_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date         => p_validation_start_date,
     p_validation_end_date       => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
    (p_rec           in ben_avr_shd.g_rec_type,
     p_effective_date    in date,
     p_datetrack_mode    in varchar2,
     p_validation_start_date in date,
     p_validation_end_date   in date) is
--
  l_proc    varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode       => p_datetrack_mode,
     p_validation_start_date    => p_validation_start_date,
     p_validation_end_date  => p_validation_end_date,
     p_acty_vrbl_rt_id      => p_rec.acty_vrbl_rt_id);
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
  (p_acty_vrbl_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_acty_vrbl_rt_f b
    where b.acty_vrbl_rt_id      = p_acty_vrbl_rt_id
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
                             p_argument       => 'acty_vrbl_rt_id',
                             p_argument_value => p_acty_vrbl_rt_id);
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
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
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
end ben_avr_bus;

/
