--------------------------------------------------------
--  DDL for Package Body BEN_CPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPR_BUS" as
/* $Header: becprrhi.pkb 115.12 2002/12/13 06:21:26 hmani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cpr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_popl_org_role_id >------|
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
--   popl_org_role_id PK of record being inserted or updated.
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
Procedure chk_popl_org_role_id(p_popl_org_role_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_popl_org_role_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_popl_org_role_id                => p_popl_org_role_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_popl_org_role_id,hr_api.g_number)
     <>  ben_cpr_shd.g_old_rec.popl_org_role_id) then
    --
    -- raise error as PK has changed
    --
    ben_cpr_shd.constraint_error('BEN_POPL_ORG_ROLE_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_popl_org_role_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cpr_shd.constraint_error('BEN_POPL_ORG_ROLE_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_popl_org_role_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_org_role_typ_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   popl_org_role_id               PK of record being inserted or updated.
--   org_role_typ_cd                Value of lookup code.
--   effective_date                 effective date
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
Procedure chk_org_role_typ_cd(p_popl_org_role_id           in number,
                              p_org_role_typ_cd            in varchar2,
                              p_popl_org_id                in number,
                              p_effective_date             in date,
                              p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_org_role_typ_cd';
  l_api_updating boolean;

  l_plnip        varchar2(1);
  cursor c1 is
       select 'x'
       from    ben_popl_org_f    pof
              ,ben_pl_f pln
       Where   pof.popl_org_id = p_popl_org_id
       and     p_effective_date between pof.effective_start_date
               and pof.effective_end_date
       and     pof.pl_id = pln.pl_id
       and     p_effective_date between pln.effective_start_date
               and pln.effective_end_date
       and     pln.pl_cd = 'MSTBPGM';  -- must be in program
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cpr_shd.api_updating
    (p_popl_org_role_id            => p_popl_org_role_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_org_role_typ_cd
      <> nvl(ben_cpr_shd.g_old_rec.org_role_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_org_role_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ORG_ROLE_TYP',
           p_lookup_code    => p_org_role_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_org_role_typ_cd');
      fnd_message.set_token('VALUE', p_org_role_typ_cd);
      fnd_message.set_token('TYPE','BEN_ORG_ROLE_TYP');
      fnd_message.raise_error;
    end if;

    -- This code is used to check that only program and plan-not-in-program
    -- can be attached with a popl-org-role of POPLOWNR
    if p_org_role_typ_cd = 'POPLOWNR' then
      open c1;
      fetch c1 into l_plnip;
      if c1%found then
        close c1;
         -- raise error as Plan is in Program
         fnd_message.set_name('BEN','BEN_92611_POPLOWNR_NO_PLIPS');
         fnd_message.raise_error;
      end if;
      close c1;
    end if;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_org_role_typ_cd;
-- --
--
-- ----------------------------------------------------------------------------
-- |------<  chk_uniq_org_role_typ >------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This procedure is used to check that only one popl_org can be created for a plan
-- with a popl-org-role of PCP
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_popl_org_id
--   p_effective_date
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--

Procedure chk_uniq_org_role_typ
          ( p_popl_org_id            in number,
            p_popl_org_role_id       in number,
            p_org_role_typ_cd        in varchar2,
            p_effective_date         in date,
            p_business_group_id      in number
           ) is

l_proc     varchar2(72) := g_package|| ' chk_uniq_org_role_typ';

l_pl_id       number;
l_num_of_pcps number;
l_plcy_r_grp  ben_popl_org_f.plcy_r_grp%TYPE; -- UTF8 varchar2(30);

-- get data for this popl-org
cursor get_grp_and_pl_id is
   select cpo.pl_id, cpo.plcy_r_grp
   from   ben_popl_org_f cpo
   where  cpo.popl_org_id = p_popl_org_id
     and  cpo.business_group_id = p_business_group_id
     and  p_effective_date between
          cpo.effective_start_date and cpo.effective_end_date;

-- how many pcp role rows exist for this plan?
cursor num_of_pcps (p_pl_id number) is
       select count('x')
       from    ben_popl_org_f      cpo
              ,ben_popl_org_role_f cpr
       Where   cpo.popl_org_id = cpr.popl_org_id
       and     cpo.pl_id = p_pl_id
       and     cpo.business_group_id = p_business_group_id
       and     cpr.org_role_typ_cd = 'PCP'
       and     (cpr.popl_org_role_id <> p_popl_org_role_id
               or p_popl_org_role_id is null)
       and     p_effective_date between cpo.effective_start_date
               and cpo.effective_end_date
       and     p_effective_date between cpr.effective_start_date
               and cpr.effective_end_date;

Begin
hr_utility.set_location('Entering:'||l_proc, 5);

if p_org_role_typ_cd = 'PCP' then
  open get_grp_and_pl_id;
  fetch get_grp_and_pl_id into l_pl_id, l_plcy_r_grp;
  close get_grp_and_pl_id;

  if l_plcy_r_grp is null then
     -- cannot have a pcp locator role without the product code for the
     -- pcp's external repository filled in the policy-or-group field.
     -- it's what the search page uses to pass to the external repository
     -- for the plan.
     fnd_message.set_name('BEN','BEN_92610_PCP_LOCATOR');
     fnd_message.raise_error;
  end if;

  -- no need to check for program rows....we should not have pcp roles for
  -- popl-orgs attached to programs.
  if l_pl_id is not null then
     open num_of_pcps(p_pl_id => l_pl_id);
     fetch num_of_pcps into l_num_of_pcps;
     close num_of_pcps;

     -- should not be any rows returned from cursor
     if l_num_of_pcps > 0 then
	 fnd_message.set_name('BEN','BEN_92578_POPL_ORG_ROLE');
       fnd_message.raise_error;
     end if;
  else
     -- can only attach pcp locator rows to plans
     fnd_message.set_name('BEN','BEN_92609_PCP_ONLY_PLNS');
     fnd_message.raise_error;
  end if;
end if;

hr_utility.set_location('Leaving:'||l_proc, 15);

End chk_uniq_org_role_typ;
--
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
            (
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
    --
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
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
            (p_popl_org_role_id		in number,
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
       p_argument       => 'popl_org_role_id',
       p_argument_value => p_popl_org_role_id);
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
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
	(p_rec 			 in ben_cpr_shd.g_rec_type,
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
  chk_popl_org_role_id
  (p_popl_org_role_id          => p_rec.popl_org_role_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_org_role_typ_cd(p_popl_org_role_id           => p_rec.popl_org_role_id,
                      p_org_role_typ_cd            => p_rec.org_role_typ_cd,
                      p_popl_org_id                => p_rec.popl_org_id,
                      p_effective_date             => p_effective_date,
                      p_object_version_number      => p_rec.object_version_number);

  --
  chk_uniq_org_role_typ
          ( p_popl_org_id           => p_rec.popl_org_id,
            p_popl_org_role_id      => p_rec.popl_org_role_id,
            p_org_role_typ_cd       => p_rec.org_role_typ_cd,
            p_business_group_id     => p_rec.business_group_id,
            p_effective_date        => p_effective_date);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_cpr_shd.g_rec_type,
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
  chk_popl_org_role_id
  (p_popl_org_role_id          => p_rec.popl_org_role_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_org_role_typ_cd(p_popl_org_role_id           => p_rec.popl_org_role_id,
                      p_org_role_typ_cd            => p_rec.org_role_typ_cd,
                      p_popl_org_id                => p_rec.popl_org_id,
                      p_effective_date             => p_effective_date,
                      p_object_version_number      => p_rec.object_version_number);
  --
  chk_uniq_org_role_typ
          ( p_popl_org_id           => p_rec.popl_org_id,
            p_popl_org_role_id      => p_rec.popl_org_role_id,
            p_org_role_typ_cd       => p_rec.org_role_typ_cd,
            p_business_group_id     => p_rec.business_group_id,
            p_effective_date        => p_effective_date);

  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
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
	(p_rec 			 in ben_cpr_shd.g_rec_type,
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
     p_popl_org_role_id		=> p_rec.popl_org_role_id);
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
  (p_popl_org_role_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_popl_org_role_f b
    where b.popl_org_role_id      = p_popl_org_role_id
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
                             p_argument       => 'popl_org_role_id',
                             p_argument_value => p_popl_org_role_id);
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
end ben_cpr_bus;

/
