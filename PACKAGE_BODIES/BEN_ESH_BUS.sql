--------------------------------------------------------
--  DDL for Package Body BEN_ESH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ESH_BUS" as
/* $Header: beeshrhi.pkb 120.0 2005/05/28 02:56:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_esh_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_elig_schedd_hrs_prte_id >------|
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
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
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
Procedure chk_elig_schedd_hrs_prte_id(p_elig_schedd_hrs_prte_id     in number,
                                      p_effective_date              in date,
                                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_schedd_hrs_prte_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_schedd_hrs_prte_id                => p_elig_schedd_hrs_prte_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_schedd_hrs_prte_id,hr_api.g_number)
     <>  ben_esh_shd.g_old_rec.elig_schedd_hrs_prte_id) then
    --
    -- raise error as PK has changed
    --
    ben_esh_shd.constraint_error('BEN_ELIG_SCH_HRS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_elig_schedd_hrs_prte_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_esh_shd.constraint_error('BEN_ELIG_SCH_HRS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_elig_schedd_hrs_prte_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_excld_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
--   excld_flag Value of lookup code.
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
Procedure chk_excld_flag(p_elig_schedd_hrs_prte_id                in number,
                            p_excld_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_excld_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id                => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_excld_flag
      <> nvl(ben_esh_shd.g_old_rec.excld_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_excld_flag,
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
end chk_excld_flag;

-- ---------------------------------------------------------------------------
-- |-----------------------< chk_duplicate_ordr_num >---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--   Ensure that the Sequence Number is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_elig_schedd_hrs_prte_id    p_elig_schedd_hrs_prte_id
--   p_eligy_prfl_id        eligy_prfl_id
--   p_ordr_num             Sequence Number
--   p_business_group_id    Business Group id.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only
--
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_ordr_num
          ( p_elig_schedd_hrs_prte_id     in   number
           ,p_eligy_prfl_id         in   number
           ,p_ordr_num              in   number
           ,p_business_group_id     in   number)
is
  l_proc     varchar2(72) := g_package||'chk_duplicate_ordr_num';
  l_dummy    char(1);
  cursor c1 is
    select null
    from   ben_elig_schedd_hrs_prte_f
    where  elig_schedd_hrs_prte_id <> nvl(p_elig_schedd_hrs_prte_id,-1)
    and    eligy_prfl_id = p_eligy_prfl_id
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
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_duplicate_ordr_num;
--

-- ----------------------------------------------------------------------------
-- |------< chk_dup_criteria >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check for duplicate criteria.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
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
Procedure chk_dup_criteria(p_elig_schedd_hrs_prte_id     in number,
                      p_freq_cd                     in varchar2,
                      p_hrs_num                     in number,
                      p_max_hrs_num                 in number,
                      p_schedd_hrs_rl               in number,
                      p_eligy_prfl_id               in number,
                      p_validation_start_date       in date,
                      p_validation_end_date         in date,
                      p_business_group_id           in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dup_criteria';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor c3 is
     select null
       from ben_elig_schedd_hrs_prte_f
         where nvl(freq_cd,hr_api.g_number) = nvl(p_freq_cd,hr_api.g_number)
           and nvl(hrs_num,hr_api.g_number) = nvl(p_hrs_num,hr_api.g_number)
           and nvl(max_hrs_num,hr_api.g_number) = nvl(p_max_hrs_num,hr_api.g_number)
           and nvl(schedd_hrs_rl,hr_api.g_number) = nvl(p_schedd_hrs_rl,hr_api.g_number)
           and eligy_prfl_id = p_eligy_prfl_id
           and elig_schedd_hrs_prte_id <> nvl(p_elig_schedd_hrs_prte_id,hr_api.g_number)
           and business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= effective_end_date
           and p_validation_end_date >= effective_start_date
           ;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id     => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
 /* if (l_api_updating
      and p_freq_cd
      <> nvl(ben_esh_shd.g_old_rec.freq_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_freq_cd is not null then
   */
    --
            --
    open c3;
    fetch c3 into l_exists;
    if c3%found then
      close c3;
      --
      -- raise error as this criteria already exists for this profile
      --
     fnd_message.set_name('BEN', 'BEN_91349_DUP_ELIG_CRITERIA');
     fnd_message.raise_error;
    --
    end if;
    close c3;
    --
  -- end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dup_criteria;
--


--
-- ----------------------------------------------------------------------------
-- |------< chk_freq_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
--   freq_cd Value of lookup code.
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
Procedure chk_freq_cd(p_elig_schedd_hrs_prte_id     in number,
                      p_freq_cd                     in varchar2,
                      p_hrs_num                     in number,
                      p_max_hrs_num                 in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_freq_cd';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id     => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_freq_cd
      <> nvl(ben_esh_shd.g_old_rec.freq_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_freq_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'FREQUENCY',
           p_lookup_code    => p_freq_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
    if p_hrs_num is null and p_max_hrs_num is null then
    	fnd_message.set_name('BEN','BEN_93222_MIN_MAX_HRS_NOT_NULL');
      	fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_freq_cd;
--

-- ----------------------------------------------------------------------------
-- |------< check_determination_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
--   determination_cd Value of lookup code.
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
Procedure check_determination_cd(p_elig_schedd_hrs_prte_id     in number,
                      p_determination_cd                     in varchar2,
                      p_determination_rl                     in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'check_determination_cd';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id     => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_determination_cd
      <> nvl(ben_esh_shd.g_old_rec.determination_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_determination_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LOS_DET',
           p_lookup_code    => p_determination_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
     if nvl(p_determination_cd,hr_api.g_number)='RL' and p_determination_rl is null then
         -- raise error as rule is specified, but code is not 'RL'
            --
         fnd_message.set_name('BEN','BEN_91098_LOS_DET_RL_NULL');
         fnd_message.raise_error;
            --
      end if;

      if p_determination_rl is not null and nvl(p_determination_cd,hr_api.g_varchar2) <> 'RL' then
         -- raise error as rule is specified, but code is not 'RL'
         --
          fnd_message.set_name('BEN','BEN_91071_LOS_DET_RL_NOT_NULL');
          fnd_message.raise_error;
          --
       end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end check_determination_cd;
--




-- ----------------------------------------------------------------------------
-- |------< check_rounding_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
--   rounding_cd Value of lookup code.
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
Procedure check_rounding_cd(p_elig_schedd_hrs_prte_id     in number,
                      p_rounding_cd                     in varchar2,
                      p_rounding_rl                     in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'check_rounding_cd';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id     => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rounding_cd
      <> nvl(ben_esh_shd.g_old_rec.rounding_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rounding_cd is not null then
    --
    if nvl(p_rounding_cd,hr_api.g_number)='RL' and p_rounding_rl is null then
         -- raise error as rule is specified, but code is not 'RL'
          --
             fnd_message.set_name('BEN','BEN_91733_RNDG_RULE');
             fnd_message.raise_error;
           --
      end if;

     if p_rounding_rl is not null and nvl(p_rounding_cd,hr_api.g_varchar2) <> 'RL' then
          -- raise error as rule is specified, but code is not 'RL'
            --
               fnd_message.set_name('BEN','BEN_91043_RNDG_RL_NOT_NULL');
               fnd_message.raise_error;
            --
      end if;


      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'BEN_RNDG',
             p_lookup_code    => p_rounding_cd,
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
end check_rounding_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< match_formula_type >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--              To check that the rule is of the correct type
-- Prerequisites:
--              None
-- In Parameters:
--      p_formula_id    - formula_number of the corresponding rule
--      p_formula_type_id       - formula_type required
--      p_effective_date - effective date
-- Returns:
--              boolean (true -> if the formula_type_id matches with the DB values
--                               false -> otherwise)
-- Post Success:
--              processing continues.
-- Post Failure:
--              error handled by procedure
-- Developer Implementation Notes:
--              Select the rule type from DB based on the number provided.
--              if the rule type matches return true, else false
-- Access Status:
--      Internal table handler use only.
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Function match_formula_type
 (p_rl			number,
  p_formula_type_id	number,
  p_effective_date 	date)
Return Boolean
is
  l_proc	varchar2(72) := g_package||'match_formula_type';
  l_formula_type_id	ff_formula_types.formula_type_id%type;
  l_exists       varchar2(1);
  cursor c_rule is
  	select null
  	  from ff_formulas_f ff
  	 where ff.formula_id = p_rl
  	   and ff.formula_type_id = p_formula_type_id
  	   and p_effective_date
  	   between ff.effective_start_date and ff.effective_end_date;
--
Begin

open c_rule;
    fetch c_rule into l_exists;
    if c_rule%notfound then
	close c_rule;
	hr_utility.set_location(' Leaving:'||l_proc, 10);
	return false;
    end if;
hr_utility.set_location(' Leaving:'||l_proc, 10);
close c_rule;
return true;
--


End match_formula_type;




-- ----------------------------------------------------------------------------
-- |------< check_determination_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
--   determination_rl - Value of Determination Rule.
--   determination_cd - Value of the determination Code
--   effective_date - effective date
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
Procedure check_determination_rl(p_elig_schedd_hrs_prte_id     in number,
                      p_determination_rl                     in number,
                      p_determination_cd	    in varchar2,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'check_determination_rl';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id     => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_determination_rl
      <> nvl(ben_esh_shd.g_old_rec.determination_rl,hr_api.g_number)
      or not l_api_updating)
    --  and p_determination_cd is not null
      and p_determination_rl is not null then
    --
    -- check if formula exists.
    --
     if p_determination_rl is not null and nvl(p_determination_cd,hr_api.g_varchar2) <> 'RL' then
        -- raise error as rule is specified, but code is not 'RL'
  	   --
           fnd_message.set_name('BEN','BEN_91071_LOS_DET_RL_NOT_NULL');
    	   fnd_message.raise_error;
    	      --
      end if;

     if nvl(p_determination_cd,hr_api.g_number)='RL' and p_determination_rl is null then
       	-- raise error as rule is specified, but code is not 'RL'
          --
  	   fnd_message.set_name('BEN','BEN_91098_LOS_DET_RL_NULL');
	   fnd_message.raise_error;
	  --
      end if;

      if nvl(p_determination_cd,hr_api.g_varchar2)='RL' then
    	        if not match_formula_type(p_rl => p_determination_rl,
    			p_formula_type_id => -170,p_effective_date => p_effective_date) then
    	      --
    	      -- raise error as forumula type not exists

    	      	fnd_message.set_name('BEN','BEN_91066_INVLD_LOS_DET_RL');
    	     	 fnd_message.raise_error;
    	    	 end if;
    	     --
        end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end check_determination_rl;
--

--


-- ----------------------------------------------------------------------------
-- |------< check_rounding_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
--   rounding_rl - Value of rounding Rule.
--   rounding_cd - Value of the rounding Code
--   effective_date - effective date
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
Procedure check_rounding_rl(p_elig_schedd_hrs_prte_id     in number,
                      p_rounding_rl                     in number,
                      p_rounding_cd	    in varchar2,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'check_rounding_rl';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id     => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rounding_rl
      <> nvl(ben_esh_shd.g_old_rec.rounding_rl,hr_api.g_number)
      or not l_api_updating)
    --  and p_rounding_cd is not null
      and p_rounding_rl is not null then
    --

     if p_rounding_rl is not null and nvl(p_rounding_cd,hr_api.g_varchar2) <> 'RL' then
         -- raise error as rule is specified, but code is not 'RL'

        	 fnd_message.set_name('BEN','BEN_91043_RNDG_RL_NOT_NULL');
        	 fnd_message.raise_error;
        	    --
      end if;

      if nvl(p_rounding_cd,hr_api.g_number)='RL' and p_rounding_rl is null then
     	  -- raise error as rule is specified, but code is not 'RL'
     	     --
     	        fnd_message.set_name('BEN','BEN_91733_RNDG_RULE');
     	        fnd_message.raise_error;
             --
       end if;

      if nvl(p_rounding_cd,hr_api.g_varchar2)='RL' then
               if not match_formula_type(p_rl => p_rounding_rl,
         			p_formula_type_id => -169,p_effective_date => p_effective_date) then
         	      -- raise error as forumula type not exists
         	      --
         	      fnd_message.set_name('BEN','BEN_91042_INVALID_RNDG_RL');
         	      fnd_message.raise_error;
         	     end if;
         	     --
        end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end check_rounding_rl;
--

-- ----------------------------------------------------------------------------
-- |------< check_schedd_hrs_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
--   schedd_hrs_rl - Value of schedd_hrs Rule.
--   schedd_hrs_cd - Value of the schedd_hrs Code
--   effective_date - effective date
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
Procedure check_schedd_hrs_rl(p_elig_schedd_hrs_prte_id     in number,
                      p_schedd_hrs_rl                     in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'check_schedd_hrs_rl';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id     => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_schedd_hrs_rl
      <> nvl(ben_esh_shd.g_old_rec.schedd_hrs_rl,hr_api.g_number)
      or not l_api_updating)
      and p_schedd_hrs_rl is not null then
    --
    -- check if formula exists.
    --
    if match_formula_type(p_rl => p_schedd_hrs_rl,p_formula_type_id => -548,
    p_effective_date => p_effective_date) then
      --
      -- raise error as forumula type not exists
      --
      fnd_message.set_name('BEN','BEN_93221_SCH_HRS_RL_INVALID');
      fnd_message.raise_error;
      --
    end if;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end check_schedd_hrs_rl;
--

-- ----------------------------------------------------------------------------
-- |------< check_min_or_max >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_schedd_hrs_prte_id PK of record being inserted or updated.
--   p_hrs_num and p_max_hrs_num
--   p_freq_cd
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
Procedure check_min_or_max(p_elig_schedd_hrs_prte_id     in number,
                      p_hrs_num                     in number,
                      p_max_hrs_num		    in number,
                      p_freq_cd			    in varchar2,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'check_min_or_max';
  l_api_updating boolean;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_esh_shd.api_updating
    (p_elig_schedd_hrs_prte_id     => p_elig_schedd_hrs_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating and p_hrs_num <> nvl(ben_esh_shd.g_old_rec.hrs_num,hr_api.g_number))
      or (l_api_updating and p_max_hrs_num <> nvl(ben_esh_shd.g_old_rec.max_hrs_num,hr_api.g_number))
      or (l_api_updating and p_freq_cd <> nvl(ben_esh_shd.g_old_rec.freq_cd,hr_api.g_varchar2))
      or not l_api_updating
      or (nvl(p_hrs_num,hr_api.g_number) is not null and nvl(p_max_hrs_num,hr_api.g_number) is not null) then
    --
	hr_utility.set_location('Inside:'||l_proc,8);

    -- check if min or max is null, if freq_cd is specified
    -- note that this check is also there in the chk_freq_cd procedure.
    if (p_hrs_num is null and p_max_hrs_num is null) then
	if p_freq_cd is not null then
		fnd_message.set_name('BEN', 'BEN_93222_MIN_MAX_HRS_NOT_NULL');
      		fnd_message.raise_error;
      	end if;
    end if;
    --

    -- check if freq_cd is not given
    if (p_hrs_num is not null or p_max_hrs_num is not null) and p_freq_cd is null then
    		fnd_message.set_name('BEN', 'BEN_93220_MIN_MAX_HRS_OR_RULE');
          	fnd_message.raise_error;

    end if;



    -- check if value of min hours is greater than max hours
    if not (p_hrs_num is null or p_max_hrs_num is null) then
    	if nvl(p_hrs_num,hr_api.g_number) > nvl(p_max_hrs_num,hr_api.g_number) then
		fnd_message.set_name('BEN', 'BEN_91069_INVALID_MIN_MAX');
		fnd_message.raise_error;
	    end if;

    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end check_min_or_max;
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
            (p_eligy_prfl_id                 in number default hr_api.g_number,
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
    If ((nvl(p_eligy_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_eligy_prfl_f',
             p_base_key_column => 'eligy_prfl_id',
             p_base_key_value  => p_eligy_prfl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_eligy_prfl_f';
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
            (p_elig_schedd_hrs_prte_id		in number,
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
       p_argument       => 'elig_schedd_hrs_prte_id',
       p_argument_value => p_elig_schedd_hrs_prte_id);
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
	(p_rec 			 in ben_esh_shd.g_rec_type,
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
  chk_elig_schedd_hrs_prte_id
  (p_elig_schedd_hrs_prte_id          => p_rec.elig_schedd_hrs_prte_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_elig_schedd_hrs_prte_id => p_rec.elig_schedd_hrs_prte_id,
   p_excld_flag              => p_rec.excld_flag,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_duplicate_ordr_num
      (p_elig_schedd_hrs_prte_id     => p_rec.elig_schedd_hrs_prte_id,
       p_eligy_prfl_id       	     => p_rec.eligy_prfl_id,
       p_ordr_num           	     => p_rec.ordr_num,
     p_business_group_id  	     => p_rec.business_group_id);
  --
/*
chk_dup_criteria(p_elig_schedd_hrs_prte_id      => p_rec.elig_schedd_hrs_prte_id,
                          p_freq_cd                 => p_rec.freq_cd,
                          p_hrs_num                 => p_rec.hrs_num,
                          p_max_hrs_num             => p_rec.max_hrs_num,
                          p_schedd_hrs_rl           => p_rec.schedd_hrs_rl,
                          p_eligy_prfl_id           => p_rec.eligy_prfl_id,
                          p_validation_start_date   => p_validation_start_date,
                          p_validation_end_date     => p_validation_end_date,
                          p_business_group_id       => p_rec.business_group_id,
                          p_effective_date          => p_effective_date,
                          p_object_version_number   => p_rec.object_version_number);
*/

  --
  chk_freq_cd
  (p_elig_schedd_hrs_prte_id => p_rec.elig_schedd_hrs_prte_id,
   p_freq_cd                 => p_rec.freq_cd,
   p_hrs_num                 => p_rec.hrs_num,
   p_max_hrs_num             => p_rec.max_hrs_num,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  check_determination_cd
    (p_elig_schedd_hrs_prte_id => p_rec.elig_schedd_hrs_prte_id,
     p_determination_cd        => p_rec.determination_cd,
     p_determination_rl          => p_rec.determination_rl,
     p_effective_date          => p_effective_date,
     p_object_version_number      => p_rec.object_version_number);
  --
  check_rounding_cd
      (p_elig_schedd_hrs_prte_id => p_rec.elig_schedd_hrs_prte_id,
       p_rounding_cd             => p_rec.rounding_cd,
       p_rounding_rl          => p_rec.rounding_rl,
       p_effective_date          => p_effective_date,
       p_object_version_number      => p_rec.object_version_number);
  --
  check_determination_rl
      (p_elig_schedd_hrs_prte_id   => p_rec.elig_schedd_hrs_prte_id,
       p_determination_rl          => p_rec.determination_rl,
       p_determination_cd	   => p_rec.determination_cd,
       p_effective_date           => p_effective_date,
       p_object_version_number    => p_rec.object_version_number);
  --
  check_rounding_rl
        (p_elig_schedd_hrs_prte_id   => p_rec.elig_schedd_hrs_prte_id,
         p_rounding_rl               => p_rec.rounding_rl,
         p_rounding_cd	             => p_rec.rounding_cd,
         p_effective_date            => p_effective_date,
         p_object_version_number     => p_rec.object_version_number);
  --
  check_schedd_hrs_rl
  	(p_elig_schedd_hrs_prte_id   => p_rec.elig_schedd_hrs_prte_id,
         p_schedd_hrs_rl             => p_rec.rounding_rl,
         p_effective_date            => p_effective_date,
         p_object_version_number     => p_rec.object_version_number);
  --
  check_min_or_max
  (p_elig_schedd_hrs_prte_id => p_rec.elig_schedd_hrs_prte_id,
   p_hrs_num                 => p_rec.hrs_num,
   p_max_hrs_num	     => p_rec.max_hrs_num,
   p_freq_cd		     => p_rec.freq_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_esh_shd.g_rec_type,
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
  chk_elig_schedd_hrs_prte_id
  (p_elig_schedd_hrs_prte_id          => p_rec.elig_schedd_hrs_prte_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_elig_schedd_hrs_prte_id          => p_rec.elig_schedd_hrs_prte_id,
   p_excld_flag            => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
    chk_duplicate_ordr_num
    (p_elig_schedd_hrs_prte_id      => p_rec.elig_schedd_hrs_prte_id,
     p_eligy_prfl_id       	    => p_rec.eligy_prfl_id,
     p_ordr_num           	    => p_rec.ordr_num,
     p_business_group_id  	    => p_rec.business_group_id);
  --
/*
  chk_dup_criteria(p_elig_schedd_hrs_prte_id      => p_rec.elig_schedd_hrs_prte_id,
                        p_freq_cd                 => p_rec.freq_cd,
                        p_hrs_num                 => p_rec.hrs_num,
                        p_max_hrs_num             => p_rec.max_hrs_num,
                        p_schedd_hrs_rl           => p_rec.schedd_hrs_rl,
                        p_eligy_prfl_id           => p_rec.eligy_prfl_id,
                        p_validation_start_date   => p_validation_start_date,
                        p_validation_end_date     => p_validation_end_date,
                        p_business_group_id       => p_rec.business_group_id,
                        p_effective_date          => p_effective_date,
                        p_object_version_number   => p_rec.object_version_number);
*/
  --
  chk_freq_cd
  (p_elig_schedd_hrs_prte_id => p_rec.elig_schedd_hrs_prte_id,
   p_freq_cd                 => p_rec.freq_cd,
   p_hrs_num                 => p_rec.hrs_num,
   p_max_hrs_num             => p_rec.max_hrs_num,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  check_determination_cd
      (p_elig_schedd_hrs_prte_id => p_rec.elig_schedd_hrs_prte_id,
       p_determination_cd        => p_rec.determination_cd,
       p_determination_rl          => p_rec.determination_rl,
       p_effective_date          => p_effective_date,
       p_object_version_number   => p_rec.object_version_number);
  --
    check_rounding_cd
        (p_elig_schedd_hrs_prte_id => p_rec.elig_schedd_hrs_prte_id,
         p_rounding_cd             => p_rec.rounding_cd,
         p_rounding_rl          => p_rec.rounding_rl,
         p_effective_date          => p_effective_date,
         p_object_version_number   => p_rec.object_version_number);
  --
  check_determination_rl
        (p_elig_schedd_hrs_prte_id   => p_rec.elig_schedd_hrs_prte_id,
         p_determination_rl          => p_rec.determination_rl,
         p_determination_cd	   => p_rec.determination_cd,
         p_effective_date           => p_effective_date,
         p_object_version_number    => p_rec.object_version_number);
  --
    check_rounding_rl
          (p_elig_schedd_hrs_prte_id   => p_rec.elig_schedd_hrs_prte_id,
           p_rounding_rl          => p_rec.rounding_rl,
           p_rounding_cd	   => p_rec.rounding_cd,
           p_effective_date           => p_effective_date,
         p_object_version_number    => p_rec.object_version_number);
--
  check_schedd_hrs_rl
  	(p_elig_schedd_hrs_prte_id   => p_rec.elig_schedd_hrs_prte_id,
         p_schedd_hrs_rl             => p_rec.rounding_rl,
         p_effective_date            => p_effective_date,
         p_object_version_number     => p_rec.object_version_number);
  --
 check_min_or_max
  (p_elig_schedd_hrs_prte_id  => p_rec.elig_schedd_hrs_prte_id,
   p_hrs_num                 => p_rec.hrs_num,
   p_max_hrs_num	     => p_rec.max_hrs_num,
   p_freq_cd		     => p_rec.freq_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);

  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_eligy_prfl_id                 => p_rec.eligy_prfl_id,
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
	(p_rec 			 in ben_esh_shd.g_rec_type,
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
     p_elig_schedd_hrs_prte_id		=> p_rec.elig_schedd_hrs_prte_id);
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
  (p_elig_schedd_hrs_prte_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_elig_schedd_hrs_prte_f b
    where b.elig_schedd_hrs_prte_id      = p_elig_schedd_hrs_prte_id
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
                             p_argument       => 'elig_schedd_hrs_prte_id',
                             p_argument_value => p_elig_schedd_hrs_prte_id);
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
end ben_esh_bus;

/
