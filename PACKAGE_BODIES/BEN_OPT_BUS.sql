--------------------------------------------------------
--  DDL for Package Body BEN_OPT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPT_BUS" as
/* $Header: beoptrhi.pkb 120.0 2005/05/28 09:56:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_opt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_opt_id >------|
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
--   opt_id PK of record being inserted or updated.
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
Procedure chk_opt_id(p_opt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_opt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_opt_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_opt_id                => p_opt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_opt_id,hr_api.g_number)
     <>  ben_opt_shd.g_old_rec.opt_id) then
    --
    -- raise error as PK has changed
    --
    ben_opt_shd.constraint_error('BEN_OPT_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_opt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_opt_shd.constraint_error('BEN_OPT_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_opt_id;



Procedure chk_opt_group_child(p_opt_id  in number ,
                              p_name      in varchar2,         /* Bug 4057566 */
                             p_opt_typ_cd in varchar2 ,
                             p_effective_date        in date) is



 cursor c_opt_cwb is
  select opt_typ_cd
    from ben_pl_typ_f plt,
         ben_pl_typ_opt_typ_f  pto
   where pto.opt_id = p_opt_id
     and plt.pl_typ_id  = pto.pl_typ_id
     and p_effective_date between plt.effective_start_date
          and  plt.effective_end_Date
     and p_effective_date between pto.effective_start_date
          and  pto.effective_end_Date  ;
   --
cursor c_child_exist is
   select 'x'
     from  ben_opt_f
     where group_opt_id = p_opt_id
       and opt_id <> p_opt_id
       and effective_end_date > p_effective_date
   ;
     -- dont validate the date
  l_dummy  varchar2(1) ;
  l_opt_typ_cd  ben_pl_typ_f.opt_typ_cd%type ;
  l_proc         varchar2(72) := g_package||'chk_opt_group_child';

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  l_opt_typ_cd := p_opt_typ_cd ;
  if p_opt_typ_cd is null then
     open c_opt_cwb ;
     fetch c_opt_cwb into l_opt_typ_cd ;
     close c_opt_cwb ;
  end if ;
  if l_opt_typ_cd = 'CWB' then
     open c_child_exist ;
     fetch c_child_exist into l_dummy ;
     if  c_child_exist%found then
       close c_child_exist ;
       fnd_message.set_name('BEN','BEN_93724_CWB_CHILD_EXIST');
       fnd_message.set_name('NAME', p_name);                  /* Bug 4057566 */
       fnd_message.raise_error;
     end if ;
     close c_child_exist ;
  end if ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --

end chk_opt_group_child ;




Procedure chk_opt_group_id(p_opt_id                in number,
                           p_group_opt_id          in number,
                           p_effective_date       in date,
                           p_name                  in varchar2 default null
                          ) is
  --
  l_proc         varchar2(72) := g_package||'chk_opt_group_id';
  l_api_updating boolean;
  --
  cursor c_parent_opt is
   select 'x'
    from ben_opt_f
   where opt_id = p_group_opt_id
     and opt_id = group_opt_id
     and p_effective_date between effective_start_date
         and  effective_end_Date ;


  cursor c_opt_cwb is
  select opt_typ_cd
    from ben_pl_typ_opt_typ_f pto ,
         ben_pl_typ_f  plt
   where pto.opt_id     = p_opt_id
     and plt.pl_typ_id  = pto.pl_typ_id
     and plt.opt_typ_cd = 'CWB'
     and p_effective_date between plt.effective_start_date
          and  plt.effective_end_Date
     and p_effective_date between pto.effective_start_date
          and  pto.effective_end_Date  ;



 l_dummy  varchar2(1) ;
 l_opt_typ_cd  ben_pl_typ_f.opt_typ_cd%type ;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_group_opt_id:'||p_group_opt_id, 5);

  -- if the plan type is cwb and  group_pl_id null throw the error
  /* removed the validation as per ty
  open c_opt_cwb ;
  fetch c_opt_cwb into l_opt_typ_cd ;
  if c_opt_cwb%found then
     if p_group_opt_id is  null then
        close c_opt_cwb ;
        fnd_message.set_name('BEN','BEN_93725_CWB_GROUP_PLN_NULL');
        fnd_message.raise_error;
     end if ;
  end if ;
  close c_opt_cwb ;
 */

  if p_group_opt_id is not null then

     /*
     --check whether the option belongs to CWB if not throw the error
     open c_opt_cwb ;
     fetch c_opt_cwb into l_opt_typ_cd ;
     if c_opt_cwb%notfound then
        close c_opt_cwb ;
        fnd_message.set_name('BEN','BEN_93725_CWB_GROUP_PLN_NULL');
        fnd_message.raise_error;
     end if ;
     close c_opt_cwb ;
      */

     -- when the plan is child check the parent is real parent
     if p_opt_id <>  p_group_opt_id then
        open c_parent_opt ;
        fetch  c_parent_opt  into l_dummy ;
        if c_parent_opt%notfound then
           close c_parent_opt ;
           fnd_message.set_name('BEN','BEN_93726_CWB_PRTN_PLN_ERROR');
           fnd_message.raise_error;
        end if ;
        close c_parent_opt ;

        chk_opt_group_child(p_opt_id            => p_opt_id ,
                              p_name            => p_name,         /* Bug 4057566 */
                           p_opt_typ_cd       => l_opt_typ_cd ,
                           p_effective_date   => p_effective_date) ;
     end if ;

  end if ;
  -- if  the type got changed from cwb to non cwb validate the child
  if ben_opt_shd.g_old_rec.group_opt_id is not null and p_group_opt_id is null then
          chk_opt_group_child(p_opt_id          => p_opt_id ,
                              p_name            => p_name,       /* Bug 4057566 */
                           p_opt_typ_cd       => 'CWB' ,
                           p_effective_date   => p_effective_date) ;
  end  if ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_opt_group_id;


--
-- ----------------------------------------------------------------------------
-- |------< chk_invk_wv_opt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   opt_id PK of record being inserted or updated.
--   invk_wv_opt_flag Value of lookup code.
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
Procedure chk_invk_wv_opt_flag(p_opt_id                in number,
                            p_invk_wv_opt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_invk_wv_opt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_opt_shd.api_updating
    (p_opt_id                => p_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_invk_wv_opt_flag
      <> nvl(ben_opt_shd.g_old_rec.invk_wv_opt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_invk_wv_opt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_invk_wv_opt_flag,
           p_effective_date => p_effective_date) then
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
end chk_invk_wv_opt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_perd_enrt_nenrt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   opt_id PK of record being inserted or updated.
--   rqd_perd_enrt_nenrt_rl Value of formula rule id.
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
Procedure chk_rqd_perd_enrt_nenrt_rl(p_opt_id                in number,
                             p_rqd_perd_enrt_nenrt_rl              in number,
                             p_effective_date              in date,
                             p_object_version_number       in number,
                             p_business_group_id           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_perd_enrt_nenrt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_rqd_perd_enrt_nenrt_rl
    and    ff.formula_type_id = -513
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id,p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code,pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_opt_shd.api_updating
    (p_opt_id                => p_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rqd_perd_enrt_nenrt_rl,hr_api.g_number)
      <> nvl(ben_opt_shd.g_old_rec.rqd_perd_enrt_nenrt_rl,hr_api.g_number)
      or not l_api_updating)
      and p_rqd_perd_enrt_nenrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
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
        hr_utility.set_message(801,'FORMULA_DOES_NOT_EXIST');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rqd_perd_enrt_nenrt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_perd_enrt_nenrt_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   opt_id PK of record being inserted or updated.
--   rqd_perd_enrt_nenrt_uom Value of lookup code.
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
Procedure chk_rqd_perd_enrt_nenrt_uom(p_opt_id                in number,
                            p_rqd_perd_enrt_nenrt_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_perd_enrt_nenrt_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_opt_shd.api_updating
    (p_opt_id                => p_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rqd_perd_enrt_nenrt_uom
      <> nvl(ben_opt_shd.g_old_rec.rqd_perd_enrt_nenrt_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rqd_perd_enrt_nenrt_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RQD_PERD_ENRT_NENRT_TM_UOM',
           p_lookup_code    => p_rqd_perd_enrt_nenrt_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91230_INV_RQD_PRD_ENRT_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rqd_perd_enrt_nenrt_uom;
--
-- ----------------------------------------------------------------------------
-- |------< chk_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the name fiels is unique within busine
--   :ss group
--   on insert and update.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   opt_id PK of record being inserted or updated
--   name for the record beeing inserted or updated
--   business_group_id  of the record beeing inserted or updated
--   effective_date effective date of the session
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
Procedure chk_name(p_name                        in varchar2,
                   p_opt_id                      in number,
                   p_effective_date              in date,
                   p_validation_start_date       in date,
                   p_validation_end_date         in date,
                   p_business_group_id           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor csr_name is
     select null
        from ben_opt_f
        where name = p_name
          and business_group_id  = p_business_group_id
          and opt_id <> nvl(p_opt_id,-1)
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- check if this name already exist
    --
    open csr_name;
    fetch csr_name into l_exists;
    if csr_name%found then
      --
      -- raise error as UK1 is violated
      --
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
      --ben_opt_shd.constraint_error('BEN_OPT_UK1');
      --
    end if;
    --
    close csr_name;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_name;
--

-- ----------------------------------------------------------------------------
-- |------< chk_comp_reason >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   opt_id PK of record being inserted or updated.
--   component_reason Value of lookup code.
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
Procedure chk_comp_reason  (p_opt_id                in number,
                            p_component_reason      in varchar2,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_reason';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_opt_shd.api_updating
					(p_opt_id   => p_opt_id,
					 p_effective_date      => p_effective_date,
					 p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
      and p_component_reason
      <> nvl(ben_opt_shd.g_old_rec.component_reason,hr_api.g_varchar2)
      or not l_api_updating)
      and p_component_reason is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PROPOSAL_REASON',
           p_lookup_code    => p_component_reason,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_comp_reason;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mapping_table_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   opt_id PK of record being inserted or updated.
--   mapping_table_name Value of lookup code.
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
Procedure chk_mapping_table_name(p_opt_id                in number,
                            p_mapping_table_name         in varchar2,
                            p_effective_date             in date,
                            p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mapping_table_name';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_opt_shd.api_updating
    (p_opt_id                => p_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mapping_table_name
      <> nvl(ben_opt_shd.g_old_rec.mapping_table_name,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mapping_table_name is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_MAPPING_OPTION_TABLE',
           p_lookup_code    => p_mapping_table_name,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_mapping_table_name');
      fnd_message.set_token('VALUE', p_mapping_table_name);
      fnd_message.set_token('TYPE', 'BEN_MAPPING_OPTION_TABLE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mapping_table_name;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mapping_table_pk_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Mapping Table Primary Key Id is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   opt_id PK of record being inserted or updated.
--   mapping_table_pk_id Value of primary key id of mapping table.
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
Procedure chk_mapping_table_pk_id(p_opt_id                in number,
                             p_mapping_table_pk_id        in number,
                             p_mapping_table_name         in varchar2,
                             p_effective_date             in date,
                             p_object_version_number      in number,
                             p_business_group_id          in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mapping_table_pk_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c_per_spinal_points is
    select null
    from   per_spinal_points spt
    where  spt.spinal_point_id = p_mapping_table_pk_id
    and    spt.business_group_id = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_opt_shd.api_updating
    (p_opt_id                => p_opt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mapping_table_pk_id,hr_api.g_number)
      <> nvl(ben_opt_shd.g_old_rec.mapping_table_pk_id,hr_api.g_number)
      or not l_api_updating)
      and p_mapping_table_pk_id is not null then
    --
    -- check if value of Mapping Table Primary Key Id is valid.
    --

    if p_mapping_table_name = 'PER_SPINAL_POINTS' then
      open c_per_spinal_points;
        --
        -- fetch value from cursor if it returns a record then the
        -- mapping_table_pk_id is valid otherwise its invalid
        --
        fetch c_per_spinal_points into l_dummy;
        if c_per_spinal_points%notfound then
          --
          close c_per_spinal_points;
          --
          -- raise error
          --
          hr_utility.set_message(805,'BEN_93322_INV_SPINAL_POINT_ID');
          hr_utility.raise_error;
          --
        end if;
        --
      close c_per_spinal_points;
      --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mapping_table_pk_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_mapping_unique >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that only one option is linked to a given
--   mapping_table_name, mapping_table_pk_id and effective_date
--   on insert and update.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   opt_id PK of record being inserted or updated
--   mapping_table_name for the record beeing inserted or updated
--   mapping_table_pk_id for the record beeing inserted or updated
--   business_group_id  of the record beeing inserted or updated
--   effective_date effective date of the session
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
Procedure chk_mapping_unique(
                   p_mapping_table_name          in varchar2,
                   p_mapping_table_pk_id         in number,
                   p_opt_id                      in number,
                   p_effective_date              in date,
                   p_validation_start_date       in date,
                   p_validation_end_date         in date,
                   p_business_group_id           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mapping_unique';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor csr_mapping is
     select null
        from ben_opt_f
        where mapping_table_name = p_mapping_table_name
          and mapping_table_pk_id = p_mapping_table_pk_id
          and opt_id <> nvl(p_opt_id,-1)
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- check if this mapping already exists
    --
    open csr_mapping;
    fetch csr_mapping into l_exists;
    if csr_mapping%found then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_93323_OPT_MAPPING_NOT_UNIQ');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_mapping;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_mapping_unique;
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
            (p_cmbn_ptip_opt_id              in number default hr_api.g_number,
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
   /* If ((nvl(p_cmbn_ptip_opt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_cmbn_ptip_opt_f',
             p_base_key_column => 'cmbn_ptip_opt_id',
             p_base_key_value  => p_cmbn_ptip_opt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_cmbn_ptip_opt_f';
      Raise l_integrity_error;
    End If;*/
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
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
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
            (p_opt_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date,
             p_name                     in varchar2) Is
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
       p_argument       => 'opt_id',
       p_argument_value => p_opt_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_opt_f',
           p_base_key_column => 'opt_id',
           p_base_key_value  => p_opt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_opt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_oipl_f',
           p_base_key_column => 'opt_id',
           p_base_key_value  => p_opt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_oipl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_dsgn_rqmt_f',
           p_base_key_column => 'opt_id',
           p_base_key_value  => p_opt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_dsgn_rqmt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_typ_opt_typ_f',
           p_base_key_column => 'opt_id',
           p_base_key_value  => p_opt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_typ_opt_typ_f';
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
    ben_utility.child_exists_error(p_table_name               => l_table_name,
                                   p_parent_table_name        => 'BEN_OPT_F',      /* Bug 4057566 */
                                   p_parent_entity_name       => p_name);          /* Bug 4057566 */
    --
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_opt_shd.g_rec_type,
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
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_opt_id
  (p_opt_id          => p_rec.opt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_invk_wv_opt_flag
  (p_opt_id          => p_rec.opt_id,
   p_invk_wv_opt_flag         => p_rec.invk_wv_opt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_perd_enrt_nenrt_rl
  (p_opt_id          => p_rec.opt_id,
   p_rqd_perd_enrt_nenrt_rl        => p_rec.rqd_perd_enrt_nenrt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rqd_perd_enrt_nenrt_uom
  (p_opt_id          => p_rec.opt_id,
   p_rqd_perd_enrt_nenrt_uom         => p_rec.rqd_perd_enrt_nenrt_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name(p_name    => p_rec.name,
         p_opt_id                 => p_rec.opt_id,
         p_effective_date       => p_effective_date,
         p_validation_start_date  => p_validation_start_date,
         p_validation_end_date    => p_validation_end_date,
         p_business_group_id      => p_rec.business_group_id);
  --
  chk_comp_reason (p_opt_id               => p_rec.opt_id,
                  p_component_reason      => p_rec.component_reason,
                  p_effective_date        => p_effective_date,
                  p_object_version_number =>p_rec.object_version_number);

  --
  chk_mapping_table_name(p_opt_id                 => p_rec.opt_id,
                         p_mapping_table_name     => p_rec.mapping_table_name,
                         p_effective_date         => p_effective_date,
                         p_object_version_number  => p_rec.object_version_number);
  --
  chk_mapping_table_pk_id(p_opt_id                => p_rec.opt_id,
                          p_mapping_table_pk_id   => p_rec.mapping_table_pk_id,
                          p_mapping_table_name    => p_rec.mapping_table_name,
                          p_effective_date        => p_effective_date,
                          p_object_version_number => p_rec.object_version_number,
                          p_business_group_id     => p_rec.business_group_id);
  --
  chk_mapping_unique(p_mapping_table_name          => p_rec.mapping_table_name,
                     p_mapping_table_pk_id         => p_rec.mapping_table_pk_id,
                     p_opt_id                      => p_rec.opt_id,
                     p_effective_date              => p_effective_date,
                     p_validation_start_date       => p_validation_start_date,
                     p_validation_end_date         => p_validation_end_date,
                     p_business_group_id           => p_rec.business_group_id);

  chk_opt_group_id   (p_opt_id               =>  p_rec.opt_id,
                      p_group_opt_id         => p_rec.group_opt_id,
                      p_effective_date       => p_effective_date,
                      p_name                 => p_rec.name
                     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_opt_shd.g_rec_type,
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
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_opt_id
  (p_opt_id          => p_rec.opt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_invk_wv_opt_flag
  (p_opt_id          => p_rec.opt_id,
   p_invk_wv_opt_flag         => p_rec.invk_wv_opt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_perd_enrt_nenrt_rl
  (p_opt_id          => p_rec.opt_id,
   p_rqd_perd_enrt_nenrt_rl        => p_rec.rqd_perd_enrt_nenrt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_rqd_perd_enrt_nenrt_uom
  (p_opt_id          => p_rec.opt_id,
   p_rqd_perd_enrt_nenrt_uom         => p_rec.rqd_perd_enrt_nenrt_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name(p_name    => p_rec.name,
         p_opt_id                 => p_rec.opt_id,
         p_effective_date       => p_effective_date,
         p_validation_start_date  => p_validation_start_date,
         p_validation_end_date    => p_validation_end_date,
         p_business_group_id      => p_rec.business_group_id);

  chk_comp_reason (p_opt_id                => p_rec.opt_id,
                  p_component_reason      => p_rec.component_reason,
                  p_effective_date        => p_effective_date,
                  p_object_version_number =>p_rec.object_version_number);

  --
  chk_mapping_table_name(p_opt_id                 => p_rec.opt_id,
                         p_mapping_table_name     => p_rec.mapping_table_name,
                         p_effective_date         => p_effective_date,
                         p_object_version_number  => p_rec.object_version_number);
  --
  chk_mapping_table_pk_id(p_opt_id                => p_rec.opt_id,
                          p_mapping_table_pk_id   => p_rec.mapping_table_pk_id,
                          p_mapping_table_name    => p_rec.mapping_table_name,
                          p_effective_date        => p_effective_date,
                          p_object_version_number => p_rec.object_version_number,
                          p_business_group_id     => p_rec.business_group_id);
  --
  chk_mapping_unique(p_mapping_table_name          => p_rec.mapping_table_name,
                     p_mapping_table_pk_id         => p_rec.mapping_table_pk_id,
                     p_opt_id                      => p_rec.opt_id,
                     p_effective_date              => p_effective_date,
                     p_validation_start_date       => p_validation_start_date,
                     p_validation_end_date         => p_validation_end_date,
                     p_business_group_id           => p_rec.business_group_id);

  chk_opt_group_id (p_opt_id               =>  p_rec.opt_id,
                    p_group_opt_id         => p_rec.group_opt_id,
                    p_effective_date       => p_effective_date,
                    p_name                 => p_rec.name
                   );

  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_cmbn_ptip_opt_id              => p_rec.cmbn_ptip_opt_id,
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
	(p_rec 			 in ben_opt_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
  l_opt_name    ben_opt_f.name%type;
   --
   -- Bug 4057566
   --
   CURSOR c_opt_name
   IS
      SELECT opt.NAME
        FROM ben_opt_f opt
       WHERE opt.opt_id = p_rec.opt_id
         AND p_effective_date BETWEEN opt.effective_start_date
                                  AND opt.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Bug 4057566
  --
  open c_opt_name ;
    --
    fetch c_opt_name into l_opt_name;
    --
  close c_opt_name;
  --
  --
  -- Call all supporting business operations
  --

   chk_opt_group_id (p_opt_id               =>  p_rec.opt_id,
                     p_name                 => l_opt_name,
                     p_group_opt_id         => p_rec.group_opt_id,
                     p_effective_date       => p_effective_date
                    );

  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_name                     => l_opt_name,
     p_opt_id		        => p_rec.opt_id);


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
  (p_opt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_opt_f b
    where b.opt_id      = p_opt_id
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
                             p_argument       => 'opt_id',
                             p_argument_value => p_opt_id);
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
end ben_opt_bus;

/
