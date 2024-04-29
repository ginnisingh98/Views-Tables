--------------------------------------------------------
--  DDL for Package Body BEN_BNR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNR_BUS" as
/* $Header: bebnrrhi.pkb 120.0 2005/05/28 00:46:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bnr_bus.';  -- Global package name
--
g_dummy	            number(1);
g_business_group_id number(15);    -- For validating translation;
g_legislation_code  varchar2(150); -- For validating translation;
--
--
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--
procedure validate_translation(rpt_grp_id IN NUMBER,
			       language IN VARCHAR2,
			       rpt_grp_name IN VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT null) IS
/*
This procedure fails if a reporting group translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated names.
*/

--
cursor c_translation(p_language IN VARCHAR2,
                     p_rpt_grp_name IN VARCHAR2,
                     p_rpt_grp_id IN NUMBER,
                     p_bus_grp_id in number ,
                     p_leg_code IN VARCHAR2)  IS
       SELECT  1
	 FROM  ben_rptg_grp_tl rtl,
	       ben_rptg_grp rgp
	 WHERE upper(rgp.name)= upper(p_rpt_grp_name)
	 AND   rgp.rptg_grp_id = rtl.rptg_grp_id
	 AND   rtl.language = p_language
	 AND   (rtl.rptg_grp_id <> p_rpt_grp_id OR p_rpt_grp_id IS NULL)
	 AND   (rgp.business_group_id = p_bus_grp_id OR p_bus_grp_id IS NULL)
	 AND   (rgp.legislation_code = p_leg_code OR p_leg_code IS NULL);

       l_package_name VARCHAR2(80) := 'BEN_BNR_BUS.VALIDATE_TRANSLATION';
       l_business_group_id NUMBER := nvl(p_business_group_id, g_business_group_id);
       l_legislation_code VARCHAR2(150) := nvl(p_legislation_code, g_legislation_code);

BEGIN
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, rpt_grp_name,rpt_grp_id,l_business_group_id,l_legislation_code );
   hr_utility.set_location (l_package_name,50);
   FETCH c_translation INTO g_dummy;

   IF c_translation%NOTFOUND THEN
      hr_utility.set_location (l_package_name,60);
      CLOSE c_translation;
   ELSE
       hr_utility.set_location (l_package_name,70);
       CLOSE c_translation;
       fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
       fnd_message.raise_error;
   END IF;
   hr_utility.set_location ('Leaving:'||l_package_name,80);
END validate_translation;
-- ----------------------------------------------------------------------------
-- |------< chk_rptg_grp_id >------|
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
--   rptg_grp_id PK of record being inserted or updated.
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
Procedure chk_rptg_grp_id(p_rptg_grp_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rptg_grp_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bnr_shd.api_updating
    (p_rptg_grp_id                => p_rptg_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_rptg_grp_id,hr_api.g_number)
     <>  ben_bnr_shd.g_old_rec.rptg_grp_id) then
    --
    -- raise error as PK has changed
    --
    ben_bnr_shd.constraint_error('BEN_RPTG_GRP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_rptg_grp_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bnr_shd.constraint_error('BEN_RPTG_GRP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_rptg_grp_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rptg_prps_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rptg_grp_id PK of record being inserted or updated.
--   rptg_prps_cd Value of lookup code.
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
Procedure chk_rptg_prps_cd(p_rptg_grp_id                in number,
                            p_rptg_prps_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rptg_prps_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bnr_shd.api_updating
    (p_rptg_grp_id                => p_rptg_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rptg_prps_cd
      <> nvl(ben_bnr_shd.g_old_rec.rptg_prps_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rptg_prps_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RPTG_PRPS',
           p_lookup_code    => p_rptg_prps_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91087_INVLD_RPTG_PRPS_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rptg_prps_cd;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_irec_plans >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to ensure that when purpose of reporting group is changed
--   to iRecruitment, none of the Plans attached to the reporting group should be
--   of Option Type other than "Individual Compensation Distribution"
--   Called from update_validate.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rptg_grp_id           PK of record being inserted or updated.
--   rptg_prps_cd          Reporting Group Purpose Code
--   effective_date        effective date
--   business_group_id     business group id (null value indicated global reporting group)
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
Procedure chk_irec_plans (  p_rptg_grp_id                in number,
                            p_rptg_prps_cd               in varchar2,
			    p_business_group_id          in number,
                            p_effective_date             in date,
                            p_object_version_number      in number) is
  --
  cursor c1 is
    select null
    from ben_popl_rptg_grp_f rgr, ben_pl_f pln, ben_pl_typ_f ptp
    where rgr.rptg_grp_id = p_rptg_grp_id
    and rgr.pl_id = pln.pl_id
    and rgr.effective_start_date <= pln.effective_end_date
    and rgr.effective_end_date >= pln.effective_start_date
    and pln.pl_typ_id = ptp.pl_typ_id
    and ptp.business_group_id = rgr.business_group_id
    and greatest(rgr.effective_start_date, pln.effective_start_date) <= ptp.effective_end_date
    and least(rgr.effective_end_date, pln.effective_end_date) >= ptp.effective_start_date
    and ptp.opt_typ_cd <> 'COMP';
  --
  cursor c2 is
    select null
    from ben_popl_rptg_grp_f rgr
    where rgr.rptg_grp_id = p_rptg_grp_id
    and rgr.pgm_id is not null;
  --
  l_proc         varchar2(72) := g_package||'chk_irec_plans ';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bnr_shd.api_updating
    (p_rptg_grp_id                => p_rptg_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rptg_prps_cd
      <> nvl(ben_bnr_shd.g_old_rec.rptg_prps_cd,hr_api.g_varchar2))
      and p_rptg_prps_cd is not null then
    --
    if p_rptg_prps_cd = 'IREC' then
      --
      if p_business_group_id is null then
        --
	-- Raise error message : to uncheck the Global flag and then change purpose to IREC
	--
	fnd_message.set_name ('BEN','BEN_93918_RPTG_GRP_GLOBAL');
	fnd_message.raise_error;
        --
      end if;
      --
      open c1;
      fetch c1 into l_dummy;
      if c1%found
      then
        --
	close c1;
        -- Raise error : as non iRec plans are attached to current reporting group
        --
        fnd_message.set_name('BEN','BEN_93920_RPTG_IREC_NONICD_PLN');
        fnd_message.raise_error;
        --
      end if;
      --
      close c1;
      --
      open c2;
      fetch c2 into l_dummy;
      if c2%found
      then
        --
	close c2;
	--Raise error : as programs are also attached to the current reporting group
	--
	fnd_message.set_name('BEN','BEN_93919_RPTG_IREC_PGM_EXIST');
	fnd_message.raise_error;
	--
      end if;
      close c2;
      --
    end if;
    --
  end if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_irec_plans ;
--
------------------------------------------------------------------------
----
-- |------< chk_name >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Name is unique in a business
--   group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rptg_grp_id PK of record being inserted or updated.
--   name Value of Name.
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
Procedure chk_name(p_rptg_grp_id                in number,
                         p_business_group_id    in number,
                         p_name                 in varchar2,
                         p_effective_date       in date,
                         p_object_version_number in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  -- added nvl for CWB Changes
  cursor c1 is
    select null
    from   ben_rptg_grp bnr
    ------ business group valiadted for global and non global
    where  nvl(bnr.business_group_id,nvl(p_business_group_id,-1)) =
           nvl(p_business_group_id,nvl(bnr.business_group_id,-1))
           ---  changes of busienss group  from non glbaol to gloabl
           ---  without changes in name may violate the uniqness
           ---  so allway chke the id
      and  bnr.rptg_grp_id <> nvl( p_rptg_grp_id , -1)
      and bnr.name = p_name;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('business:'||p_business_group_id, 5);
  --
  l_api_updating := ben_bnr_shd.api_updating
    (p_rptg_grp_id                => p_rptg_grp_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  -- Check whether name is null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'name',
                             p_argument_value => p_name);
  --

  if ((l_api_updating
      and nvl(p_name,hr_api.g_varchar2)
      <> ben_bnr_shd.g_old_rec.name
      or not l_api_updating)
     OR
      (l_api_updating
      and nvl(p_business_group_id,hr_api.g_number)
      <> ben_bnr_shd.g_old_rec.business_group_id
      or not l_api_updating)
     )
      and p_name is not null then
    --
    -- check if name already used.
    --
    open c1;
      --
      --
      -- fetch value from cursor if it returns a record then the
      -- name is invalid otherwise its valid
      --
      hr_utility.set_location(' comming for  update ' || p_rptg_grp_id, 99 );
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_name;
--
----
-- |------< chk_child_exist_in_other_bg >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that there are no child records exist for
--   for the Record in other business group ONLY if the business_group_id is
--   not null ( CWB Changes )
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rptg_grp_id PK of record being inserted or updated.
--   business_group_id may be null
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
Procedure chk_child_exist_in_other_bg
                        (p_rptg_grp_id           in number,
                         p_business_group_id     in number,
                         p_effective_date        in date,
                         p_object_version_number in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_exist_in_other_bg';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_popl_rptg_grp prg
    where  prg.business_group_id <> p_business_group_id
      and  prg.rptg_grp_id = p_rptg_grp_id
    union
    select null
    from   ben_pl_regy_bod_f prb
    where  prb.business_group_id <> p_business_group_id
      and  prb.rptg_grp_id = p_rptg_grp_id
    union
    select null
    from   ben_pl_regn_f pre
    where  pre.business_group_id <> p_business_group_id
      and  pre.rptg_grp_id = p_rptg_grp_id;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_business_group_id is not null then
    --
    open c1;
    --
    -- fetch value from cursor if it returns a record then the
    --
    fetch c1 into l_dummy;
    if c1%found then
       --
       close c1;
       --
       -- raise error
       -- Change this message
       fnd_message.set_name('BEN','BEN_92775_CHILD_REC_EXISTS');
       fnd_message.raise_error;
       --
     end if;
     --
    close c1;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_child_exist_in_other_bg;
--
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
            (p_rptg_grp_id		in number,
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
       p_argument       => 'rptg_grp_id',
       p_argument_value => p_rptg_grp_id);


    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_regn_f',
           p_base_key_column => 'rptg_grp_id',
           p_base_key_value  => p_rptg_grp_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then

      	   l_table_name := 'ben_pl_regn_f';
           Raise l_rows_exist;
    End If;

    If (dt_api.rows_exist
              (p_base_table_name => 'ben_pl_regy_bod_f',
               p_base_key_column => 'rptg_grp_id',
               p_base_key_value  => p_rptg_grp_id,
               p_from_date       => p_validation_start_date,
               p_to_date         => p_validation_end_date)) Then
          l_table_name := 'ben_pl_regy_bod_f';
          Raise l_rows_exist;
    End If;

    If (dt_api.rows_exist
              (p_base_table_name => 'ben_popl_rptg_grp_f',
               p_base_key_column => 'rptg_grp_id',
               p_base_key_value  => p_rptg_grp_id,
               p_from_date       => p_validation_start_date,
               p_to_date         => p_validation_end_date)) Then
         l_table_name := 'ben_popl_rptg_grp_f';
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

    --

  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', sqlerrm);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_bnr_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CWB Changes
  if p_rec.business_group_id is not null then
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  end if;
  --
  chk_rptg_grp_id
  (p_rptg_grp_id          => p_rec.rptg_grp_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_rptg_grp_id              => p_rec.rptg_grp_id,
   p_business_group_id        => p_rec.business_group_id,
   p_name                     => p_rec.name,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --

  chk_rptg_prps_cd
  (p_rptg_grp_id          => p_rec.rptg_grp_id,
   p_rptg_prps_cd         => p_rec.rptg_prps_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_child_exist_in_other_bg
  (p_rptg_grp_id           => p_rec.rptg_grp_id,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number) ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_bnr_shd.g_rec_type
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
  if p_rec.business_group_id is not null then
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  end if;
  --
  chk_rptg_grp_id
  (p_rptg_grp_id          => p_rec.rptg_grp_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_rptg_grp_id              => p_rec.rptg_grp_id,
   p_business_group_id        => p_rec.business_group_id,
   p_name                     => p_rec.name,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  --
  chk_rptg_prps_cd
  (p_rptg_grp_id          => p_rec.rptg_grp_id,
   p_rptg_prps_cd         => p_rec.rptg_prps_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --iRec
  chk_irec_plans
  (p_rptg_grp_id          => p_rec.rptg_grp_id,
   p_rptg_prps_cd         => p_rec.rptg_prps_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --iRec
  --
  chk_child_exist_in_other_bg
  (p_rptg_grp_id           => p_rec.rptg_grp_id,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number) ;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_bnr_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

-- Bug 2660590

/* Checking the child record exist or not
   BEN_PRTG_GRP is not date tracked. So using ZAP for date track mode
   and 01-JAN-1900 and 31-DEC-4712 as parameters */

  dt_delete_validate
     (p_rptg_grp_id		=> p_rec.rptg_grp_id,
      p_datetrack_mode		=> 'ZAP',
     p_validation_start_date	=> to_date('01/01/1900','DD/MM/YYYY'),
     p_validation_end_date	=> to_date('31/12/4712','DD/MM/YYYY'));

-- End of Bug 2660590

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
  (p_rptg_grp_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_rptg_grp b
    where b.rptg_grp_id      = p_rptg_grp_id
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
                             p_argument       => 'rptg_grp_id',
                             p_argument_value => p_rptg_grp_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
/** CWB Changes
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
*/
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_bnr_bus;

/
