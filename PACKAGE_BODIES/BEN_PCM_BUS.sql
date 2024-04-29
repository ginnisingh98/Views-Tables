--------------------------------------------------------
--  DDL for Package Body BEN_PCM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCM_BUS" as
/* $Header: bepcmrhi.pkb 115.13 2002/12/16 11:58:35 vsethi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pcm_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_per_cm_id >------|
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
--   per_cm_id PK of record being inserted or updated.
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
Procedure chk_per_cm_id(p_per_cm_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_per_cm_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcm_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_per_cm_id                => p_per_cm_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_per_cm_id,hr_api.g_number)
     <>  ben_pcm_shd.g_old_rec.per_cm_id) then
    --
    -- raise error as PK has changed
    --
    ben_pcm_shd.constraint_error('BEN_PER_CM_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_per_cm_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pcm_shd.constraint_error('BEN_PER_CM_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_per_cm_id;
--
-- -------------------------------------------------------------------------
-- |------< chk_cm_typ_rl >------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to call the cm_typ rule to determine
--   if this person can be sent this particular communication.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   person_id
--   effective_date Effective Date of session
--   cm_typ_id
--   business_group_id
--
Procedure chk_cm_typ_rl (p_person_id         in number,
                         p_effective_date    in date,
                         p_cm_typ_id         in number,
                         p_business_group_id in number) is
--
  l_proc       varchar2(80) := g_package||'chk_cm_typ_rl';
  l_outputs       ff_exec.outputs_t;
  l_return        varchar2(30);
  l_assignment_id number;
  l_cm_typ_rl     number;
--
  cursor   c_asg  is
    select asg.assignment_id
    from   per_all_assignments_f asg
    where  person_id = p_person_id and
           primary_flag='Y' and
           asg.assignment_type <> 'C' and
           p_effective_date between
             asg.effective_start_date and asg.effective_end_date;
--
  cursor   c_cmtyp is
    select cmt.cm_typ_rl
    from   ben_cm_typ_f cmt
    where  cmt.cm_typ_id = p_cm_typ_id and
           cmt.business_group_id = p_business_group_id and
           p_effective_date between
           cmt.effective_start_date and cmt.effective_end_date;
begin
     hr_utility.set_location ('Entering '||l_proc,10);
      --
      -- Get assignment ID from per_all_assignments_f table.
      --
      open c_asg;
      fetch c_asg into l_assignment_id;
--      if c_asg%notfound then
         --
         -- Defensive coding
         --
--         close c_asg;
--      end if;
--      close c_asg;
      --
      -- Get cm_typ_rl from ben_cm_typ_f table.
      --
      open c_cmtyp;
      fetch c_cmtyp into l_cm_typ_rl;
      close c_cmtyp;
     --
     -- Call formula initialise routine
     --
     if l_cm_typ_rl is not null then
        l_outputs := benutils.formula
                      (p_formula_id     => l_cm_typ_rl
                      ,p_effective_date => p_effective_date
                      ,p_assignment_id  => l_assignment_id);
     --
     -- Formula will return Y or N
     --
        l_return := l_outputs(l_outputs.first).value;

        if upper(l_return) not in ('Y', 'N')  then
         --
         -- Just return 'Y' .
         --
         l_return := 'Y';
         --
        end if;
    else
       l_return := 'Y';
    end if;
    --
    if upper(l_return) = 'N' then
      --
      -- Now display the message based on the message type
      --
      fnd_message.set_name('BEN','BEN_92467_CM_TYP_RULE');
      fnd_message.raise_error;
      --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end chk_cm_typ_rl;
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
            (p_cm_typ_id                     in number default hr_api.g_number,
             p_prtt_enrt_actn_id             in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
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
    If ((nvl(p_cm_typ_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_cm_typ_f',
             p_base_key_column => 'cm_typ_id',
             p_base_key_value  => p_cm_typ_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_cm_typ_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_prtt_enrt_actn_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_prtt_enrt_actn_f',
             p_base_key_column => 'prtt_enrt_actn_id',
             p_base_key_value  => p_prtt_enrt_actn_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_prtt_enrt_actn_f';
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
            (p_per_cm_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
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
       p_argument       => 'per_cm_id',
       p_argument_value => p_per_cm_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_per_cm_prvdd_f',
           p_base_key_column => 'per_cm_id',
           p_base_key_value  => p_per_cm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_per_cm_prvdd_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_per_cm_trgr_f',
           p_base_key_column => 'per_cm_id',
           p_base_key_value  => p_per_cm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_per_cm_trgr_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_per_cm_usg_f',
           p_base_key_column => 'per_cm_id',
           p_base_key_value  => p_per_cm_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_per_cm_usg_f';
      Raise l_rows_exist;
    End If;
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
	(p_rec 			 in ben_pcm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_per_cm_id
  (p_per_cm_id          => p_rec.per_cm_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cm_typ_rl
  (p_person_id         => p_rec.person_id,
   p_effective_date    => p_effective_date,
   p_cm_typ_id         => p_rec.cm_typ_id,
   p_business_group_id => p_rec.business_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_pcm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_per_cm_id
  (p_per_cm_id          => p_rec.per_cm_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_cm_typ_id                     => p_rec.cm_typ_id,
             p_prtt_enrt_actn_id             => p_rec.prtt_enrt_actn_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_pcm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_per_cm_id		=> p_rec.per_cm_id);
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
  (p_per_cm_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_per_cm_f b
    where b.per_cm_id      = p_per_cm_id
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
                             p_argument       => 'per_cm_id',
                             p_argument_value => p_per_cm_id);
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
end ben_pcm_bus;

/
