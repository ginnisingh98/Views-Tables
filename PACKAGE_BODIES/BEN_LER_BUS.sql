--------------------------------------------------------
--  DDL for Package Body BEN_LER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_BUS" as
/* $Header: belerrhi.pkb 120.2 2006/11/03 10:34:58 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ler_bus.';  -- Global package name
g_rows_exist	Exception;
---
-- added for Bug: 4651734
g_business_group_id number(15);    -- For validating translation;

PROCEDURE set_translation_globals(p_business_group_id IN NUMBER) IS
BEGIN
   g_business_group_id := p_business_group_id;
END;
--
procedure validate_translation(ler_id IN NUMBER,
			       language IN VARCHAR2,
			       ler_name IN VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL) IS
/*
This procedure fails if a Life event reason translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated names.
*/

--
cursor c_translation(p_language IN VARCHAR2,
                     p_ler_name IN VARCHAR2,
                     p_ler_id IN NUMBER,
                     p_bus_grp_id in number)  IS
       SELECT  1
	 FROM  ben_ler_f_tl ler_tl,
	       ben_ler_f ler
	 WHERE upper(ler.name)= upper(p_ler_name)
	 AND   ler.ler_id = ler_tl.ler_id
	 AND   ler_tl.language = p_language
	 AND   (ler_tl.ler_id <> p_ler_id OR p_ler_id IS NULL)
	 AND   (ler.business_group_id = p_bus_grp_id OR p_bus_grp_id IS NULL);

       l_package_name VARCHAR2(80) := 'BEN_LER_BUS.VALIDATE_TRANSLATION';
       l_business_group_id NUMBER := nvl(p_business_group_id, g_business_group_id);

g_dummy     NUmber(1);
BEGIN

   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, ler_name,ler_id,l_business_group_id);
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
--
-- change ended .. for bug 4651734
--

-- ----------------------------------------------------------------------------
-- |------< chk_ler_id >------|
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
--   ler_id PK of record being inserted or updated.
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
Procedure chk_ler_id(p_ler_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_id                => p_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_id,hr_api.g_number)
     <>  ben_ler_shd.g_old_rec.ler_id) then
    --
    -- raise error as PK has changed
    --
    ben_ler_shd.constraint_error('BEN_LER_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ler_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ler_shd.constraint_error('BEN_LER_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler_id;
-- ----------------------------------------------------------------------------
-- |------< chk_child_rows >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if there are any child rows for the parent
--   ben_ler record that is either being deleted or is having it's typ_cd updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--           p_ler_id                   pk value being check
--           p_validation_start_date    date range to check for.
--           p_validation_end_date      date range to check for.
-- Out Parameters
--           p_table_name               the table that contains child rows.
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
Procedure chk_child_rows
           (p_ler_id                     in number,
           p_validation_start_date       in date,
           p_validation_end_date         in date,
           p_delete_flag                 in  varchar2 default 'N',
           p_table_name                  out nocopy varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_child_rows';
  l_table_name   all_tables.table_name%TYPE := null;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_lee_rsn_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_lee_rsn_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_plip_enrt_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_plip_enrt_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_pl_nip_enrt_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_pl_nip_enrt_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_oipl_enrt_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_oipl_enrt_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_to_prte_rsn_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_to_prte_rsn_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_dpnt_cvg_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_dpnt_cvg_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_per_info_cs_ler_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_per_info_cs_ler_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_rltd_per_cs_ler_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_rltd_per_cs_ler_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_css_rltd_per_per_in_ler_f',
           p_base_key_column => 'ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_css_rltd_per_per_in_ler_f';
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_css_rltd_per_per_in_ler_f',
           p_base_key_column => 'rsltg_ler_id',
           p_base_key_value  => p_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_css_rltd_per_per_in_ler_f';
    End If;

    if l_table_name is not null then
       if p_delete_flag = 'Y' then
          ben_utility.child_exists_error(p_table_name => l_table_name);
       else
          fnd_message.set_name('BEN', 'BEN_91040_CAN_NOT_CHG_TYPE');
          fnd_message.raise_error;
       end if;
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_child_rows;

--
Procedure chk_seeded_life
           (p_ler_id in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_seeded_life';
  dummy          varchar2(10);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  select null into dummy from ben_ler_f ler
    where ler.ler_id = p_ler_id and ler.typ_cd in
    (select typ_cd from ben_startup_lers);
--  fnd_message.set_name('BEN','BEN_92490_CANNOT_DELETE_LER');
      fnd_message.set_name('BEN','BEN_92490_CANNOT_DELETE_LER');
  fnd_message.raise_error;
  hr_utility.set_location('Leaving:'||l_proc,10);
Exception
  When no_data_found then
    null;
End chk_seeded_life;

--
-- ----------------------------------------------------------------------------
-- |------< chk_whn_to_prcs_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   whn_to_prcs_cd Value of lookup code.
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
Procedure chk_whn_to_prcs_cd(p_ler_id                in number,
                            p_whn_to_prcs_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_whn_to_prcs_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_whn_to_prcs_cd
      <> nvl(ben_ler_shd.g_old_rec.whn_to_prcs_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_whn_to_prcs_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_WHN_TO_PRCS_LER',
           p_lookup_code    => p_whn_to_prcs_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91010_INV_WHN_TO_PRCS_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_whn_to_prcs_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_eval_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   ler_eval_rl Value of formula rule id.
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
Procedure chk_ler_eval_rl(p_ler_id                      in number,
                             p_ler_eval_rl              in number,
                             p_business_group_id        in number,
                             p_effective_date           in date,
                             p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_eval_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_ler_eval_rl
    and    ff.formula_type_id = -157   -- Life Event Evaluation
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) = p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) = pbg.legislation_code
    and    p_effective_date between ff.effective_start_date
           and    ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_ler_eval_rl,hr_api.g_number)
      <> ben_ler_shd.g_old_rec.ler_eval_rl
      or not l_api_updating)
      and p_ler_eval_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91007_INVALID_RULE');
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
end chk_ler_eval_rl;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ptnl_ler_trtmt_cd >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   ptnl_ler_trtmt_cd Value of lookup code.
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
Procedure chk_ptnl_ler_trtmt_cd(p_ler_id                  in number,
                                p_ptnl_ler_trtmt_cd       in varchar2,
                                p_effective_date          in date,
                                p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptnl_ler_trtmt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_ptnl_ler_trtmt_cd
      <> nvl(ben_ler_shd.g_old_rec.ptnl_ler_trtmt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ptnl_ler_trtmt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PTNL_LER_TRTMT',
           p_lookup_code    => p_ptnl_ler_trtmt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_ptnl_ler_trtmt_cd');
      fnd_message.set_token('TYPE','BEN_PTNL_LER_TRTMT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ptnl_ler_trtmt_cd;
--
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_ptnl_ler_trtmt_cd_seed_ler >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that for only seeded temporal life events the
--   the life event treatment code can be "Never detect this temporal life event".
--   Bug : 3575124
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id                  PK of record being inserted or updated.
--   ptnl_ler_trtmt_cd       Value of lookup code.
--   effective_date          effective date
--   object_version_number   Object version number of record being
--                           inserted or updated.
--   typ_cd                  Type code of LER
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
Procedure chk_ptnl_ler_trtmt_cd_seed_ler(p_ler_id                  in number,
                                         p_ptnl_ler_trtmt_cd       in varchar2,
                                         p_effective_date          in date,
                                         p_object_version_number   in number,
					 p_typ_cd                  in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptnl_ler_trtmt_cd_seed_ler';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if ( ( l_api_updating
        and ( p_ptnl_ler_trtmt_cd
              <> nvl(ben_ler_shd.g_old_rec.ptnl_ler_trtmt_cd,hr_api.g_varchar2)
             or p_typ_cd
              <> nvl(ben_ler_shd.g_old_rec.typ_cd,hr_api.g_varchar2)
	     )
        )
       or not l_api_updating)
      and p_ptnl_ler_trtmt_cd is not null then
    --
    if p_typ_cd not in ('DRVDAGE', 'DRVDCAL', 'DRVDCMP', 'DRVDLOS', 'DRVDHRW', 'DRVDTPF')
       and p_ptnl_ler_trtmt_cd = 'IGNRTHIS'
    then
      --
      fnd_message.set_name('BEN','BEN_93957_LER_TRTMT_SEED_ERR');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ptnl_ler_trtmt_cd_seed_ler;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_lf_evt_oper_cd >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   lf_evt_oper_cd Value of lookup code.
--   business_group_id
--   effective_date
--   validation_sdtart_date
--   validation_end_date
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
Procedure chk_lf_evt_oper_cd(p_ler_id                in number,
                             p_lf_evt_oper_cd        in varchar2,
                             p_business_group_id     in number,
                             p_effective_date        in date,
                             p_object_version_number in number,
                             p_validation_start_date in date,
                             p_validation_end_date   in date,
			     p_typ_cd                in varchar2) is
  cursor c1 is
  select null
    from ben_ler_f
   where lf_evt_oper_cd = p_lf_evt_oper_cd
     and ler_id <> nvl(p_ler_id,-1)
     and business_group_id      = p_business_group_id
     and effective_end_date     >= p_validation_start_date
     and effective_start_date   <= p_validation_end_date  ;
  --
  l_dummy        varchar2(1);
  l_proc         varchar2(72) := g_package||'chk_lf_evt_oper_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- GSP Rate Synchronization : Check if Operation Code is not null for LER type = GSP and ABSENCES
  if p_typ_cd in ('GSP', 'ABS') and p_lf_evt_oper_cd is null then
    --
    fnd_message.set_name('BEN', 'BEN_94032_GSP_OPER_CD_NULL');
    fnd_message.raise_error;
    --
  end if;
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_lf_evt_oper_cd
      <> nvl(ben_ler_shd.g_old_rec.lf_evt_oper_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_lf_evt_oper_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LF_EVT_OPER',
           p_lookup_code    => p_lf_evt_oper_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','lf_evt_oper_cd');
      fnd_message.set_token('TYPE','BEN_LF_EVT_OPER');
      fnd_message.raise_error;
      --
    end if;
    --
    -- GSP Rate Synchronization
    if p_typ_cd = 'ABS' and p_lf_evt_oper_cd not in ('START', 'END', 'DELETE') then
      --
      fnd_message.set_name('BEN', 'BEN_94033_ABS_OPER_CD_FALSE');
      fnd_message.raise_error;
      --
    elsif p_typ_cd = 'GSP' and p_lf_evt_oper_cd not in ('PROG', 'SYNC') then
      --
      fnd_message.set_name('BEN', 'BEN_94034_GSP_OPER_CD_FALSE');
      fnd_message.raise_error;
      --
    end if;
    --
    -- Bug 2851090 Added checks for duplicate Start and End
    -- Life Event Operation Codes
    --
    if p_lf_evt_oper_cd = 'START' then
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        close c1;
        fnd_message.set_name('BEN','BEN_93362_DUP_START_LF_EVT');
        fnd_message.raise_error;
      end if;
      close c1;
    elsif p_lf_evt_oper_cd = 'END' then
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        close c1;
        fnd_message.set_name('BEN','BEN_93363_DUP_END_LF_EVT');
        fnd_message.raise_error;
      end if;
      close c1;
    elsif p_lf_evt_oper_cd = 'DELETE' then
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        close c1;
        fnd_message.set_name('BEN','BEN_93145_DUP_DEL_LF_EVT');
        fnd_message.raise_error;
      end if;
      close c1;
    elsif p_lf_evt_oper_cd = 'PROG' then -- GSP Rate Synchronization
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        close c1;
        fnd_message.set_name('BEN','BEN_94030_DUP_PROG_LF_EVT');
        fnd_message.raise_error;
      end if;
      close c1;
    elsif p_lf_evt_oper_cd = 'SYNC' then
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        close c1;
        fnd_message.set_name('BEN','BEN_94031_DUP_SYNC_LF_EVT');
        fnd_message.raise_error;
      end if;
      close c1;                         -- GSP Rate Synchronization
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_lf_evt_oper_cd;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_slctbl_slf_svc_cd >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   slctbl_slf_svc_cd Value of lookup code.
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
Procedure chk_slctbl_slf_svc_cd (p_ler_id                  in number,
                                p_slctbl_slf_svc_cd        in varchar2,
                                p_effective_date           in date,
                                p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_slctbl_slf_svc_cd' ;
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_slctbl_slf_svc_cd
      <> nvl(ben_ler_shd.g_old_rec.slctbl_slf_svc_cd ,hr_api.g_varchar2)
      or not l_api_updating)
      and p_slctbl_slf_svc_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_SLCTBL_SLF_SVC_CD',
           p_lookup_code    => p_slctbl_slf_svc_cd ,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_slctbl_slf_svc_cd');
      fnd_message.set_token('TYPE','BEN_SLCTBL_SLF_SVC_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_slctbl_slf_svc_cd ;

-- ----------------------------------------------------------------------------
-- |------< chk_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   typ_cd Value of lookup code.
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
Procedure chk_typ_cd(p_ler_id                  in number,
                     p_typ_cd                  in varchar2,
                     p_business_group_id       in number,
                     p_effective_date          in date,
                     p_object_version_number   in number,
                     p_validation_start_date   in date,
                     p_validation_end_date     in date)  is
  --
CURSOR l_csr_ler  IS
    SELECT  'x'
    FROM    ben_ler_f
    WHERE   typ_cd                    = nvl(p_typ_cd, hr_api.g_varchar2)
    AND     business_group_id + 0     = p_business_group_id
    AND     effective_end_date       >= p_validation_start_date
    AND     effective_start_date     <= p_validation_end_date  ;
  --
  l_db_ler_row   l_csr_ler%rowtype;
  l_proc         varchar2(72) := g_package||'chk_typ_cd';
  l_api_updating boolean;
  l_table_name	all_tables.table_name%TYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
    if (l_api_updating and
        ben_ler_shd.g_old_rec.typ_cd in ('DRVDAGE', 'DRVDLOS', 'DRVDCAL',
                'DRVDHRW', 'DRVDCMP', 'DRVDTPF', 'QMSCOCO', 'QDROCOU', 'QUAINGR')
        and nvl(p_typ_cd,hr_api.g_varchar2) <> ben_ler_shd.g_old_rec.typ_cd) then
        --
        -- The user is not allowed to change Life Event TYPE of derived types.
        --
        fnd_message.set_name('BEN','BEN_91423_DELIVERED_TYPE_CHG');
        fnd_message.raise_error;
    end if;

    if nvl(p_typ_cd,hr_api.g_varchar2)
       <> nvl(ben_ler_shd.g_old_rec.typ_cd,hr_api.g_varchar2)
        and
        p_typ_cd in ('DRVDAGE', 'DRVDLOS', 'DRVDCAL',
                    'DRVDHRW', 'DRVDCMP', 'DRVDTPF',  'SCHEDDO','SCHEDDA','SCHEDDU',
                    'QMSCOCO', 'QDROCOU', 'QUAINGR') then   -- GSP Rate Synchronization : Removed GSP
        --
        -- Check to see if a ler already exists of this type.  If so, do not
        -- allow creation of it.  If not, allow creation, since this program is
        -- called by the process used to seed these life events.
        --
        open l_csr_ler ;
        fetch l_csr_ler into l_db_ler_row;
        if l_csr_ler%found then
           close l_csr_ler;
           --
           -- The user is not allowed to create Life Events of these derived types.
           -- GRADE/STEP : Only one Grade/step life event is allowed.
           --
           if p_typ_cd = 'GSP' then
              fnd_message.set_name('BEN','BEN_93619_ONLY_1_GSP_LE_ALWD');
           else
              fnd_message.set_name('BEN','BEN_91424_DERIV_TYPE_INS');
           end if;
           fnd_message.raise_error;
        else
           close l_csr_ler;
        end if;
    end if;


  if (l_api_updating
      and p_typ_cd
      <> nvl(ben_ler_shd.g_old_rec.typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LER_TYP',
           p_lookup_code    => p_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91011_INVALID_TYPE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- Only allow the Type Code to change if the record is not being used in any
  -- foreign keys.  CAN change the type from null to something though.
  if (l_api_updating
      and nvl(p_typ_cd,hr_api.g_varchar2)
      <> nvl(ben_ler_shd.g_old_rec.typ_cd,hr_api.g_varchar2)
      and ben_ler_shd.g_old_rec.typ_cd is not null) then
    --
    -- Call a routine to check to see if any child rows exist.  This
    -- procedure will return an error message if any children exist.
    --
    chk_child_rows
          (p_ler_id              => p_ler_id,
           p_validation_start_date       => p_validation_start_date,
           p_validation_end_date         => p_validation_end_date,
           p_table_name                  => l_table_name );
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_typ_cd_not_null >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the typ_cd is not null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   typ_cd Value of lookup code.
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
Procedure chk_typ_cd_not_null(p_ler_id         in number,
                     p_typ_cd                  in varchar2,
                     p_effective_date          in date,
                     p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_typ_cd_not_null';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                      => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating and p_typ_cd is null ) then
    --
    fnd_message.set_name('BEN','BEN_91011_INVALID_TYPE');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_typ_cd_not_null;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_irec_typ_cd_uniq_in_bg >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that no other Life event of type = 'iRecruitment'
--   exists in the same Business Group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id			PK of record being inserted or updated.
--   typ_cd			Value of lookup code.
--   effective_date		effective date
--   business_group_id          Business Group Id of the life event
--   object_version_number	Object version number of record being
--				inserted or updated.
--   validation_start_date      validation start date of the record
--   validation_end_date        validation end date of the record
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
Procedure chk_irec_typ_cd_uniq_in_bg(p_ler_id                  in number,
                                     p_typ_cd                  in varchar2,
				     p_business_group_id       in number,
				     p_effective_date          in date,
				     p_object_version_number   in number,
				     p_validation_start_date   in date,
				     p_validation_end_date     in date)  is
  --
  cursor l_csr_ler  is
    select  null
    from    ben_ler_f ler
    where   ler.typ_cd                    = 'IREC'
    and     ler.ler_id                   <> nvl(p_ler_id, -1)
    and     ler.business_group_id + 0     = p_business_group_id
    and     p_validation_start_date      <= ler.effective_end_date
    and     p_validation_end_date        >= ler.effective_start_date;
  --
  l_proc         varchar2(72) := g_package||'chk_irec_typ_cd_uniq_in_bg';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                      => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
    if (  (l_api_updating
          and nvl(p_typ_cd,hr_api.g_varchar2) <> ben_ler_shd.g_old_rec.typ_cd
	  or not l_api_updating )
       and p_typ_cd = 'IREC' )
    then
      --
      open l_csr_ler;
      fetch l_csr_ler into l_dummy;
      if l_csr_ler%found
      then
        --
	close l_csr_ler;
	--
        --Raise error : Life event of Type = 'iRecruitment' already exists for the Business Group
        --
        fnd_message.set_name('BEN','BEN_93924_IREC_LER_EXIST_IN_BG');
        fnd_message.raise_error;
	--
      end if;
      --
      close l_csr_ler;
    --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_irec_typ_cd_uniq_in_bg;
--

--
-- ----------------------------------------------------------------------------
-- |------< chk_ck_rltd_per_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   ck_rltd_per_elig_flag Value of lookup code.
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
Procedure chk_ck_rltd_per_elig_flag(p_ler_id                in number,
                            p_ck_rltd_per_elig_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ck_rltd_per_elig_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ck_rltd_per_elig_flag
      <> nvl(ben_ler_shd.g_old_rec.ck_rltd_per_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ck_rltd_per_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ck_rltd_per_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91014_INV_CHK_RLTD_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ck_rltd_per_elig_flag;
-- ----------------------------------------------------------------------------
-- |------< chk_cm_aply_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   cm_aply_flag Value of lookup code.
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
Procedure chk_cm_aply_flag(p_ler_id                in number,
                            p_cm_aply_flag         in varchar2,
                            p_typ_cd                      in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cm_aply_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cm_aply_flag
      <> nvl(ben_ler_shd.g_old_rec.cm_aply_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cm_aply_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_cm_aply_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91013_INV_CM_APLY_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- If type-code is not 'Personal' then communications flag must be off.
  --
  if (p_typ_cd <> 'PRSNL' or p_typ_cd is null) and p_cm_aply_flag = 'Y' then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91012_CM_APLY_FLAG_OFF');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cm_aply_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the name field is unique.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   name Name of record being inserted or updated.
--   business_group_id business_group
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
Procedure chk_name(p_ler_id              in number,
                   p_name                in varchar2,
                   p_business_group_id   in number,
                   p_effective_date        in date,
                   p_validation_start_date in date,
                   p_validation_end_date   in date,
                   p_object_version_number       in number) is

-- Cursor selects non-unique names
-- Note, we are allowing records with different keys to have the same
-- name value as long as the two records are not 'effective' at any
-- one time.
CURSOR l_csr_ler  IS
    SELECT  name
    FROM    ben_ler_f
    WHERE   ler_id                    <> nvl(p_ler_id, hr_api.g_number)
    AND     name                      = p_name
    AND     business_group_id + 0     = p_business_group_id
    AND     effective_end_date       >= p_validation_start_date
    AND     effective_start_date     <= p_validation_end_date  ;
  --
  l_db_ler_row   l_csr_ler%rowtype;
  l_proc         varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                      => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);

  if (l_api_updating
     and nvl(p_name,hr_api.g_varchar2)
     <>  ben_ler_shd.g_old_rec.name
     or not l_api_updating) then

     open l_csr_ler ;
     fetch l_csr_ler into l_db_ler_row;
     if l_csr_ler%found then
        close l_csr_ler;
        --
        -- raise error as there is another record in database with same name.
        --
        ben_ler_shd.constraint_error('BEN_LER_UK1');
     end if;
    close l_csr_ler;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_name;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_ovridg_le_flag >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the ovridg_le_flag is in lookup
--   YES_NO
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   ovridg_le_flag flag
--   business_group_id business_group
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
Procedure chk_ovridg_le_flag(p_ler_id                in number,
                             p_ovridg_le_flag        in varchar2,
                             p_effective_date        in date,
                             p_object_version_number in number) is

  --
  l_proc         varchar2(72) := g_package||'chk_ovridg_le_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                      => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);

  if (l_api_updating
     and nvl(p_ovridg_le_flag,hr_api.g_varchar2)
     <>  ben_ler_shd.g_old_rec.ovridg_le_flag
     or not l_api_updating) then
     --
     -- check if value of lookup falls within lookup type.
     --
     if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_ovridg_le_flag,
            p_effective_date => p_effective_date) then
       --
       -- raise error as does not exist as lookup
       --
       fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
       fnd_message.set_token('FIELD','p_ovridg_le_flag');
       fnd_message.set_token('TYPE', 'YES_NO');
       fnd_message.raise_error;
       --
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ovridg_le_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_qualg_evt_flag >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the qualg_evt_flag is in lookup
--   YES_NO
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   qualg_evt_flag flag
--   business_group_id business_group
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
Procedure chk_qualg_evt_flag(p_ler_id                in number,
                             p_qualg_evt_flag        in varchar2,
                             p_effective_date        in date,
                             p_object_version_number in number) is

  --
  l_proc         varchar2(72) := g_package||'chk_qualg_evt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                      => p_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);

  if (l_api_updating
     and nvl(p_qualg_evt_flag,hr_api.g_varchar2)
     <>  ben_ler_shd.g_old_rec.qualg_evt_flag
     or not l_api_updating) then
     --
     -- check if value of lookup falls within lookup type.
     --
     if hr_api.not_exists_in_hr_lookups
           (p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_qualg_evt_flag,
            p_effective_date => p_effective_date) then
       --
       -- raise error as does not exist as lookup
       --
       fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
       fnd_message.set_token('FIELD','p_qualg_evt_flag');
       fnd_message.set_token('TYPE', 'YES_NO');
       fnd_message.raise_error;
       --
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_qualg_evt_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_tmlns_eval_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   tmlns_eval_cd Value of lookup code.
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
Procedure chk_tmlns_eval_cd(p_ler_id                  in number,
                            p_tmlns_eval_cd           in varchar2,
                            p_effective_date          in date,
                            p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tmlns_eval_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_tmlns_eval_cd
      <> nvl(ben_ler_shd.g_old_rec.tmlns_eval_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tmlns_eval_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LER_TMLNS_EVAL',
           p_lookup_code    => p_tmlns_eval_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_tmlns_eval_cd');
      fnd_message.set_token('TYPE','BEN_LER_TMLNS_EVAL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tmlns_eval_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_tmlns_perd_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   tmlns_perd_cd Value of lookup code.
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
Procedure chk_tmlns_perd_cd(p_ler_id                  in number,
                            p_tmlns_perd_cd           in varchar2,
                            p_effective_date          in date,
                            p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tmlns_perd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_tmlns_perd_cd
      <> nvl(ben_ler_shd.g_old_rec.tmlns_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tmlns_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LER_TMLNS_PERD',
           p_lookup_code    => p_tmlns_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_tmlns_perd_cd');
      fnd_message.set_token('TYPE','BEN_LER_TMLNS_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tmlns_perd_cd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_tmlns_perd_rl >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   tmlns_perd_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_tmlns_perd_rl(p_ler_id                in number,
                            p_tmlns_perd_rl         in number,
                            p_business_group_id     in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tmlns_perd_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                      => p_ler_id,
     p_object_version_number       => p_object_version_number,
     p_effective_date              => p_effective_date);
  --
  if (l_api_updating
      and nvl(p_tmlns_perd_rl,hr_api.g_number)
      <> ben_ler_shd.g_old_rec.tmlns_perd_rl
      or not l_api_updating)
      and p_tmlns_perd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_tmlns_perd_rl,
        p_formula_type_id   => -453,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_tmlns_perd_rl);
      fnd_message.set_token('TYPE_ID',-453);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tmlns_perd_rl;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_slf_svc_cd_qlfg_evt >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the qlfg evt flag is set when slf svc cd is COBRA , REGCOBRA
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_id PK of record being inserted or updated.
--   slctbl_slf_svc_cd Value of lookup code.
--   qualg_evt_flag  .
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
Procedure chk_slf_svc_cd_qlfg_evt (p_ler_id                   in number,
                                   p_slctbl_slf_svc_cd        in varchar2,
                                   p_qualg_evt_flag            in varchar2 ,
                                   p_effective_date           in date,
                                   p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_slf_svc_cd_qlfg_evt' ;
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ler_shd.api_updating
    (p_ler_id                => p_ler_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and ( p_slctbl_slf_svc_cd <> nvl(ben_ler_shd.g_old_rec.slctbl_slf_svc_cd ,hr_api.g_varchar2)
            or p_qualg_evt_flag <> nvl(ben_ler_shd.g_old_rec.qualg_evt_flag , hr_api.g_varchar2) )
      or not l_api_updating)
      and p_slctbl_slf_svc_cd is not null then
    --
    -- if value of p_slctbl_slf_svc_cd is in (COBRA , REGCOBRA) then p_qualg_evt_flag should be Y , else throw  an error.
    --
       if p_slctbl_slf_svc_cd in ('COBRA' , 'REGCOBRA' ) then
          if  p_qualg_evt_flag = 'N' then
          --
          -- raise error
          --
          fnd_message.set_name('BEN','BEN_92959_QLFG_EVT_FLAG_UNCHK');
          fnd_message.raise_error;
          --
          else
          --  valid data entered
              null ;
          end if;
      end if ;
  end if ;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_slf_svc_cd_qlfg_evt ;
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
            (p_formula_id           in number default hr_api.g_number,
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
    If ((nvl(p_formula_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_formula_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
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
            (p_ler_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
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
       p_argument       => 'ler_id',
       p_argument_value => p_ler_id);
    --
    -- Check whether the row being deleted is a seeded life event.  If yes, the procedure
    -- will return an error messge.
    chk_seeded_life(p_ler_id);
    -- Call a routine to check to see if any child rows exist.  This
    -- procedure will return an error message if any children exist.
    --
    chk_child_rows
          (p_ler_id              => p_ler_id,
           p_validation_start_date       => p_validation_start_date,
           p_validation_end_date         => p_validation_end_date,
           p_delete_flag                 => 'Y',
           p_table_name                  => l_table_name);

    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  WHEN hr_utility.hr_error THEN
       raise;
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
	(p_rec 			 in ben_ler_shd.g_rec_type,
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
  chk_ler_id
  (p_ler_id          => p_rec.ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_whn_to_prcs_cd
  (p_ler_id                => p_rec.ler_id,
   p_whn_to_prcs_cd        => p_rec.whn_to_prcs_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmlns_eval_cd
  (p_ler_id                => p_rec.ler_id,
   p_tmlns_eval_cd         => p_rec.tmlns_eval_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmlns_perd_cd
  (p_ler_id                => p_rec.ler_id,
   p_tmlns_perd_cd         => p_rec.tmlns_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmlns_perd_rl
  (p_ler_id                => p_rec.ler_id,
   p_tmlns_perd_rl         => p_rec.tmlns_perd_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_eval_rl
  (p_ler_id                => p_rec.ler_id,
   p_ler_eval_rl           => p_rec.ler_eval_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ptnl_ler_trtmt_cd
  (p_ler_id                => p_rec.ler_id,
   p_ptnl_ler_trtmt_cd     => p_rec.ptnl_ler_trtmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ptnl_ler_trtmt_cd_seed_ler
  (p_ler_id                => p_rec.ler_id,
   p_ptnl_ler_trtmt_cd     => p_rec.ptnl_ler_trtmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_typ_cd                => p_rec.typ_cd);
  --
  chk_lf_evt_oper_cd
  (p_ler_id                => p_rec.ler_id,
   p_lf_evt_oper_cd        => p_rec.lf_evt_oper_cd,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_typ_cd                => p_rec.typ_cd);
  --
  chk_slctbl_slf_svc_cd
  (p_ler_id                => p_rec.ler_id,
   p_slctbl_slf_svc_cd     => p_rec.slctbl_slf_svc_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_typ_cd_not_null
  (p_ler_id                => p_rec.ler_id,
   p_typ_cd                => p_rec.typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_typ_cd
  (p_ler_id                => p_rec.ler_id,
   p_typ_cd                => p_rec.typ_cd,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date);
  --
  --iRec
  chk_irec_typ_cd_uniq_in_bg
  (p_ler_id                => p_rec.ler_id,
   p_typ_cd                => p_rec.typ_cd,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date);
  --iRec
  --
   chk_ck_rltd_per_elig_flag
  (p_ler_id          => p_rec.ler_id,
   p_ck_rltd_per_elig_flag         => p_rec.ck_rltd_per_elig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- we will be deleting this flag after beta 1, don't check it's value.
  --chk_cm_aply_flag
  --(p_ler_id                => p_rec.ler_id,
  -- p_cm_aply_flag          => p_rec.cm_aply_flag,
  -- p_typ_cd                => p_rec.typ_cd,
  -- p_effective_date        => p_effective_date,
  -- p_object_version_number => p_rec.object_version_number);
 --
  chk_name
  (p_ler_id                => p_rec.ler_id,
   p_name                  => p_rec.name,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ovridg_le_flag
  (p_ler_id                => p_rec.ler_id,
   p_ovridg_le_flag        => p_rec.ovridg_le_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_qualg_evt_flag
  (p_ler_id                => p_rec.ler_id,
   p_qualg_evt_flag        => p_rec.qualg_evt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_slf_svc_cd_qlfg_evt
   (p_ler_id                   => p_rec.ler_id,
    p_slctbl_slf_svc_cd        => p_rec.slctbl_slf_svc_cd,
    p_qualg_evt_flag           => p_rec.qualg_evt_flag,
    p_effective_date           => p_effective_date,
    p_object_version_number    => p_rec.object_version_number) ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ler_shd.g_rec_type,
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
  chk_ler_id
  (p_ler_id                => p_rec.ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_whn_to_prcs_cd
  (p_ler_id                => p_rec.ler_id,
   p_whn_to_prcs_cd        => p_rec.whn_to_prcs_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmlns_eval_cd
  (p_ler_id                => p_rec.ler_id,
   p_tmlns_eval_cd         => p_rec.tmlns_eval_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmlns_perd_cd
  (p_ler_id                => p_rec.ler_id,
   p_tmlns_perd_cd         => p_rec.tmlns_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tmlns_perd_rl
  (p_ler_id                => p_rec.ler_id,
   p_tmlns_perd_rl         => p_rec.tmlns_perd_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_eval_rl
  (p_ler_id                => p_rec.ler_id,
   p_ler_eval_rl           => p_rec.ler_eval_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ptnl_ler_trtmt_cd
  (p_ler_id                => p_rec.ler_id,
   p_ptnl_ler_trtmt_cd     => p_rec.ptnl_ler_trtmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ptnl_ler_trtmt_cd_seed_ler
  (p_ler_id                => p_rec.ler_id,
   p_ptnl_ler_trtmt_cd     => p_rec.ptnl_ler_trtmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_typ_cd                => p_rec.typ_cd);
  --
  chk_lf_evt_oper_cd
  (p_ler_id                => p_rec.ler_id,
   p_lf_evt_oper_cd        => p_rec.lf_evt_oper_cd,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_typ_cd                => p_rec.typ_cd);  --
  chk_slctbl_slf_svc_cd
  (p_ler_id                => p_rec.ler_id,
   p_slctbl_slf_svc_cd     => p_rec.slctbl_slf_svc_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  --
  chk_typ_cd
  (p_ler_id                => p_rec.ler_id,
   p_typ_cd                => p_rec.typ_cd,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date);
  --
  --iRec
  chk_irec_typ_cd_uniq_in_bg
  (p_ler_id                => p_rec.ler_id,
   p_typ_cd                => p_rec.typ_cd,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date);
  --iRec

  --
   chk_ck_rltd_per_elig_flag
  (p_ler_id                => p_rec.ler_id,
   p_ck_rltd_per_elig_flag => p_rec.ck_rltd_per_elig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --chk_cm_aply_flag
  --(p_ler_id                => p_rec.ler_id,
  -- p_cm_aply_flag          => p_rec.cm_aply_flag,
  -- p_typ_cd                => p_rec.typ_cd,
  -- p_effective_date        => p_effective_date,
  -- p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_ler_id                => p_rec.ler_id,
   p_name                  => p_rec.name,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ovridg_le_flag
  (p_ler_id                => p_rec.ler_id,
   p_ovridg_le_flag        => p_rec.ovridg_le_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
   --
  chk_qualg_evt_flag
  (p_ler_id                => p_rec.ler_id,
   p_qualg_evt_flag        => p_rec.qualg_evt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
   --
  chk_slf_svc_cd_qlfg_evt
   (p_ler_id                   => p_rec.ler_id,
    p_slctbl_slf_svc_cd        => p_rec.slctbl_slf_svc_cd,
    p_qualg_evt_flag           => p_rec.qualg_evt_flag,
    p_effective_date           => p_effective_date,
    p_object_version_number    => p_rec.object_version_number) ;
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_formula_id           => p_rec.ler_eval_rl,
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
	(p_rec 			 in ben_ler_shd.g_rec_type,
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
     p_ler_id		=> p_rec.ler_id);
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
  (p_ler_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ler_f b
    where b.ler_id      = p_ler_id
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
                             p_argument       => 'ler_id',
                             p_argument_value => p_ler_id);
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

--
end ben_ler_bus;

/
