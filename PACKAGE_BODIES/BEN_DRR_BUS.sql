--------------------------------------------------------
--  DDL for Package Body BEN_DRR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DRR_BUS" as
/* $Header: bedrrrhi.pkb 120.0 2005/05/28 01:40:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_drr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_dsgn_rqmt_rlshp_typ_id >-----------------------|
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
--   dsgn_rqmt_rlshp_typ_id PK of record being inserted or updated.
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
Procedure chk_dsgn_rqmt_rlshp_typ_id
             (p_dsgn_rqmt_rlshp_typ_id      in number,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dsgn_rqmt_rlshp_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_drr_shd.api_updating
    (p_dsgn_rqmt_rlshp_typ_id                => p_dsgn_rqmt_rlshp_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dsgn_rqmt_rlshp_typ_id,hr_api.g_number)
     <>  ben_drr_shd.g_old_rec.dsgn_rqmt_rlshp_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_drr_shd.constraint_error('BEN_DSGN_RQMT_RLSHP_TYP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_dsgn_rqmt_rlshp_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_drr_shd.constraint_error('BEN_DSGN_RQMT_RLSHP_TYP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dsgn_rqmt_rlshp_typ_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_dsgn_rqmt_id >-----------------------------|
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
--   p_dsgn_rqmt_rlshp_typ_id PK
--   p_dsgn_rqmt_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_dsgn_rqmt_id (p_dsgn_rqmt_rlshp_typ_id   in number,
                            p_dsgn_rqmt_id             in number,
                            p_effective_date           in date,
                            p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dsgn_rqmt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_dsgn_rqmt_f a
    where  a.dsgn_rqmt_id = p_dsgn_rqmt_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_drr_shd.api_updating
     (p_dsgn_rqmt_rlshp_typ_id            => p_dsgn_rqmt_rlshp_typ_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dsgn_rqmt_id,hr_api.g_number)
     <> nvl(ben_drr_shd.g_old_rec.dsgn_rqmt_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if dsgn_rqmt_id value exists in ben_dsgn_rqmt_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_dsgn_rqmt_f
        -- table.
        --
        ben_drr_shd.constraint_error('BEN_DSGN_RQMT_RLSHP_TYP_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_dsgn_rqmt_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_rlshp_typ_cd >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_rlshp_typ_id PK of record being inserted or updated.
--   rlshp_typ_cd Value of lookup code.
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
Procedure chk_rlshp_typ_cd
             (p_dsgn_rqmt_rlshp_typ_id      in number,
              p_rlshp_typ_cd                in varchar2,
              p_effective_date              in date,
              p_business_group_id           in number,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rlshp_typ_cd';
  l_api_updating boolean;
  --
  -- Bug 3686523
  -- We need to validate the lookup values against the security group
  --
  l_dummy        VARCHAR2(1);
  --
  CURSOR c_lookup_exists (
     cv_business_group_id   NUMBER,
     cv_lookup_code         VARCHAR2,
     cv_effective_date      DATE
  )
  IS
     SELECT NULL
       FROM fnd_lookup_types_vl flt, fnd_lookup_values_vl flv
      WHERE flt.lookup_type = 'CONTACT'
        AND (   flv.security_group_id = 0
             OR flv.security_group_id IN (
                    SELECT security_group_id
                      FROM fnd_security_groups
                     WHERE security_group_key =
                                               TO_CHAR (cv_business_group_id))
            )
        AND flt.lookup_type = flv.lookup_type
        AND flt.security_group_id = flv.security_group_id
        AND flv.lookup_code = cv_lookup_code
        AND cv_effective_date BETWEEN NVL (flv.start_date_active,
                                           cv_effective_date
                                          )
                                  AND NVL (flv.end_date_active,
                                           cv_effective_date
                                          );
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_drr_shd.api_updating
    (p_dsgn_rqmt_rlshp_typ_id      => p_dsgn_rqmt_rlshp_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rlshp_typ_cd
      <> nvl(ben_drr_shd.g_old_rec.rlshp_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rlshp_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    /* Commented the following code for Bug 3686523
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'CONTACT',
           p_lookup_code    => p_rlshp_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      --Bug 2736727 Changed parameter to 805 frm 'BEN' in hr_utility call.

      hr_utility.set_message(805,'BEN_91964_INVLD_RLSHP_TYP');
      hr_utility.raise_error;
      --
    end if;
    */
    open c_lookup_exists (cv_business_group_id => p_business_group_id,
                          cv_lookup_code       => p_rlshp_typ_cd,
                          cv_effective_date    => p_effective_date );
      --
      fetch c_lookup_exists into l_dummy;
      --
      if c_lookup_exists%notfound
      then
        --
        close c_lookup_exists;
        --
        fnd_message.set_name('BEN', 'BEN_91964_INVLD_RLSHP_TYP');
        fnd_message.raise_error;
        --
      end if;
      --
    close c_lookup_exists;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rlshp_typ_cd;
--
--
-- bug 2837189
-- validate dupliaction of records
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_dsgn_rqmt_rlshp_uniq >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to enforce uniquness of the relationship type
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_rlshp_typ_id		PK of record being inserted or updated
--   rlshp_typ_cd			Relationship type code
--   dsgn_rqmt_id			Foreign key of parent record
--   business_group_id			Business group id
--   object_version_number 		Object version number of record being
--                         		inserted or updated.
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
Procedure chk_dsgn_rqmt_rlshp_uniq
			   (p_dsgn_rqmt_rlshp_typ_id   in number,
			    p_rlshp_typ_cd	       in varchar2,
                            p_dsgn_rqmt_id             in number,
                            p_business_group_id        in number,
                            p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dsgn_rqmt_rlshp_uniq';
  l_dummy        varchar2(1);
  --
  cursor c_chk_uniq_dsgn_rqmt is
    select 'X'
    from   ben_dsgn_rqmt_rlshp_typ
    where  dsgn_rqmt_id = p_dsgn_rqmt_id
    and    rlshp_typ_cd = p_rlshp_typ_cd
    and    business_group_id = p_business_group_id
    and    dsgn_rqmt_rlshp_typ_id <> nvl(p_dsgn_rqmt_rlshp_typ_id, -999);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
    --
    -- check if dsgn_rqmt_id value exists in ben_dsgn_rqmt_f table
    --
    open c_chk_uniq_dsgn_rqmt;
    --
    fetch c_chk_uniq_dsgn_rqmt into l_dummy;
    --
    close c_chk_uniq_dsgn_rqmt;

      if l_dummy is not null then
        -- raise error
        --
            fnd_message.set_name('BEN','BEN_93355_RLSHP_TYP_UNIQUE');
            fnd_message.raise_error;

        --
      end if;
      --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_dsgn_rqmt_rlshp_uniq;
--
-- end bug 2837189

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_drr_shd.g_rec_type
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
  chk_dsgn_rqmt_rlshp_typ_id
  (p_dsgn_rqmt_rlshp_typ_id          => p_rec.dsgn_rqmt_rlshp_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rlshp_typ_cd
  (p_dsgn_rqmt_rlshp_typ_id          => p_rec.dsgn_rqmt_rlshp_typ_id,
   p_rlshp_typ_cd         => p_rec.rlshp_typ_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --bug 2837189
  chk_dsgn_rqmt_rlshp_uniq
  (p_dsgn_rqmt_rlshp_typ_id  => p_rec.dsgn_rqmt_rlshp_typ_id,
   p_rlshp_typ_cd	     => p_rec.rlshp_typ_cd,
   p_dsgn_rqmt_id            => p_rec.dsgn_rqmt_id,
   p_business_group_id       => p_rec.business_group_id,
   p_object_version_number   => p_rec.object_version_number );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_drr_shd.g_rec_type
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
  chk_dsgn_rqmt_rlshp_typ_id
  (p_dsgn_rqmt_rlshp_typ_id          => p_rec.dsgn_rqmt_rlshp_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rlshp_typ_cd
  (p_dsgn_rqmt_rlshp_typ_id          => p_rec.dsgn_rqmt_rlshp_typ_id,
   p_rlshp_typ_cd         => p_rec.rlshp_typ_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --bug 2837189
    chk_dsgn_rqmt_rlshp_uniq
    (p_dsgn_rqmt_rlshp_typ_id  => p_rec.dsgn_rqmt_rlshp_typ_id,
     p_rlshp_typ_cd	       => p_rec.rlshp_typ_cd,
     p_dsgn_rqmt_id            => p_rec.dsgn_rqmt_id,
     p_business_group_id       => p_rec.business_group_id,
     p_object_version_number   => p_rec.object_version_number );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_drr_shd.g_rec_type
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
  (p_dsgn_rqmt_rlshp_typ_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_dsgn_rqmt_rlshp_typ b
    where b.dsgn_rqmt_rlshp_typ_id      = p_dsgn_rqmt_rlshp_typ_id
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
                             p_argument       => 'dsgn_rqmt_rlshp_typ_id',
                             p_argument_value => p_dsgn_rqmt_rlshp_typ_id);
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
end ben_drr_bus;

/
