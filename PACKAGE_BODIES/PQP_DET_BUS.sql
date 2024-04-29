--------------------------------------------------------
--  DDL for Package Body PQP_DET_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_DET_BUS" as
/* $Header: pqdetrhi.pkb 115.8 2003/02/17 22:14:03 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_det_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_analyzed_data_details_id >------|
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
--   analyzed_data_details_id PK of record being inserted or updated.
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
Procedure chk_analyzed_data_details_id(p_analyzed_data_details_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_analyzed_data_details_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_det_shd.api_updating
    (p_analyzed_data_details_id                => p_analyzed_data_details_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_analyzed_data_details_id,hr_api.g_number)
     <>  pqp_det_shd.g_old_rec.analyzed_data_details_id) then
    --
    -- raise error as PK has changed
    --
    pqp_det_shd.constraint_error('PQP_ANALYZED_ALIEN_DETAILS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_analyzed_data_details_id is not null then
      --
      -- raise error as PK is not null
      --
      pqp_det_shd.constraint_error('PQP_ANALYZED_ALIEN_DETAILS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_analyzed_data_details_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_analyzed_data_id >------|
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
--   p_analyzed_data_details_id PK
--   p_analyzed_data_id ID of FK column
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
Procedure chk_analyzed_data_id (p_analyzed_data_details_id          in number,
                            p_analyzed_data_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_analyzed_data_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqp_analyzed_alien_data a
    where  a.analyzed_data_id = p_analyzed_data_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqp_det_shd.api_updating
     (p_analyzed_data_details_id            => p_analyzed_data_details_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_analyzed_data_id,hr_api.g_number)
     <> nvl(pqp_det_shd.g_old_rec.analyzed_data_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if analyzed_data_id value exists in pqp_analyzed_alien_data table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqp_analyzed_alien_data
        -- table.
        --
        pqp_det_shd.constraint_error('PQP_ANALYZED_ALIEN_DATA_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_analyzed_data_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_retro_lose_ben_amt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   retro_lose_ben_amt_flag Value of lookup code.
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
Procedure chk_retro_lose_ben_amt_flag(p_analyzed_data_details_id                in number,
                            p_retro_lose_ben_amt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_retro_lose_ben_amt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_det_shd.api_updating
    (p_analyzed_data_details_id                => p_analyzed_data_details_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_retro_lose_ben_amt_flag
      <> nvl(pqp_det_shd.g_old_rec.retro_lose_ben_amt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_retro_lose_ben_amt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'              ,
           p_lookup_code    => p_retro_lose_ben_amt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'            );
        hr_utility.set_message_token('COLUMN','retro_lose_ben_amt_flag' );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PQH_YES_NO'        );
        hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_retro_lose_ben_amt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_treaty_ben_allowed_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   treaty_ben_allowed_flag Value of lookup code.
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
Procedure chk_treaty_ben_allowed_flag(p_analyzed_data_details_id                in number,
                            p_treaty_ben_allowed_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_treaty_ben_allowed_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_det_shd.api_updating
    (p_analyzed_data_details_id                => p_analyzed_data_details_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_treaty_ben_allowed_flag
      <> nvl(pqp_det_shd.g_old_rec.treaty_ben_allowed_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_treaty_ben_allowed_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'              ,
           p_lookup_code    => p_treaty_ben_allowed_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'            );
        hr_utility.set_message_token('COLUMN','treaty_ben_allowed_flag' );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PQH_YES_NO'        );
        hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_treaty_ben_allowed_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_addl_withholding_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   addl_withholding_flag Value of lookup code.
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
Procedure chk_addl_withholding_flag(p_analyzed_data_details_id                in number,
                            p_addl_withholding_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_addl_withholding_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_det_shd.api_updating
    (p_analyzed_data_details_id                => p_analyzed_data_details_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_addl_withholding_flag
      <> nvl(pqp_det_shd.g_old_rec.addl_withholding_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_addl_withholding_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'            ,
           p_lookup_code    => p_addl_withholding_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'            );
        hr_utility.set_message_token('COLUMN','addl_withholding_flag'   );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PQH_YES_NO'        );
        hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_addl_withholding_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_retro_lose_ben_date_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   retro_lose_ben_date_flag Value of lookup code.
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
Procedure chk_retro_lose_ben_date_flag(p_analyzed_data_details_id                in number,
                            p_retro_lose_ben_date_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_retro_lose_ben_date_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_det_shd.api_updating
    (p_analyzed_data_details_id                => p_analyzed_data_details_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_retro_lose_ben_date_flag
      <> nvl(pqp_det_shd.g_old_rec.retro_lose_ben_date_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_retro_lose_ben_date_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'               ,
           p_lookup_code    => p_retro_lose_ben_date_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'             );
        hr_utility.set_message_token('COLUMN','retro_lose_ben_date_flag' );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PQH_YES_NO'         );
        hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_retro_lose_ben_date_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_student_exempt_from_ss >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   student_exempt_from_ss Value of lookup code.
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
PROCEDURE chk_student_exempt_from_ss(p_analyzed_data_details_id    in number ,
                                      p_student_exempt_from_ss in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_student_exempt_from_ss';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_det_shd.api_updating
                        (p_analyzed_data_details_id=>p_analyzed_data_details_id,
                         p_object_version_number   => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_student_exempt_from_ss
         <> NVL(pqp_det_shd.g_old_rec.student_exempt_from_ss,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_student_exempt_from_ss IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQH_YES_NO'                ,
             p_lookup_code    => p_student_exempt_from_ss ,
             p_effective_date => p_effective_date          ) THEN
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'             );
        hr_utility.set_message_token('COLUMN','student_exempt_from_ss' );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PQH_YES_NO'         );
        hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_student_exempt_from_ss;
--
-- ----------------------------------------------------------------------------
-- |------< chk_nra_exempt_from_ss >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   nra_exempt_from_ss Value of lookup code.
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
PROCEDURE chk_nra_exempt_from_ss(p_analyzed_data_details_id    in number ,
                                      p_nra_exempt_from_ss in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_nra_exempt_from_ss';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_det_shd.api_updating
                        (p_analyzed_data_details_id=>p_analyzed_data_details_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_nra_exempt_from_ss
         <> NVL(pqp_det_shd.g_old_rec.nra_exempt_from_ss,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_nra_exempt_from_ss IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQH_YES_NO'                ,
             p_lookup_code    => p_nra_exempt_from_ss ,
             p_effective_date => p_effective_date          ) THEN
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'             );
        hr_utility.set_message_token('COLUMN','nra_exempt_from_ss'       );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PQH_YES_NO'         );
        hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_nra_exempt_from_ss;
--
-- ----------------------------------------------------------------------------
-- |------< chk_nra_exempt_from_medicare >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   nra_exempt_from_medicare Value of lookup code.
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
PROCEDURE chk_nra_exempt_from_medicare(p_analyzed_data_details_id    in number ,
                                      p_nra_exempt_from_medicare in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_nra_exempt_from_medicare';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_det_shd.api_updating
                        (p_analyzed_data_details_id=>p_analyzed_data_details_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_nra_exempt_from_medicare
         <> NVL(pqp_det_shd.g_old_rec.nra_exempt_from_medicare,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_nra_exempt_from_medicare IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQH_YES_NO'                ,
             p_lookup_code    => p_nra_exempt_from_medicare ,
             p_effective_date => p_effective_date           ) THEN
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'             );
        hr_utility.set_message_token('COLUMN','nra_exempt_from_medicare' );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PQH_YES_NO'         );
        hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_nra_exempt_from_medicare;
--
-- ----------------------------------------------------------------------------
-- |------< chk_income_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   income_code Value of lookup code.
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
PROCEDURE chk_income_code(p_analyzed_data_details_id    in number ,
                                      p_income_code in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_income_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_det_shd.api_updating
                        (p_analyzed_data_details_id=>p_analyzed_data_details_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_income_code
         <> NVL(pqp_det_shd.g_old_rec.income_code,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_income_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_INCOME_TYPES' ,
             p_lookup_code    => p_income_code         ,
             p_effective_date => p_effective_date      ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801, 'HR_52966_INVALID_LOOKUP'             );
            hr_utility.set_message_token('COLUMN', 'income_code'              );
            hr_utility.set_message_token('LOOKUP_TYPE',
                                       'PER_US_INCOME_TYPES'          );
            hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_income_code;
--
-- |------< chk_income_code_sub_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   income_code_sub_type Value of lookup code.
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
PROCEDURE chk_income_code_sub_type(p_analyzed_data_details_id    in number ,
                                      p_income_code_sub_type in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_income_code_sub_type';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_det_shd.api_updating
                        (p_analyzed_data_details_id=>p_analyzed_data_details_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_income_code_sub_type
         <> NVL(pqp_det_shd.g_old_rec.income_code_sub_type,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_income_code_sub_type IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_US_INCOME_CODE_SUB_TYPE' ,
             p_lookup_code    => p_income_code_sub_type        ,
             p_effective_date => p_effective_date              ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801, 'HR_52966_INVALID_LOOKUP'             );
            hr_utility.set_message_token('COLUMN', 'income_code_sub_type'     );
            hr_utility.set_message_token('LOOKUP_TYPE',
                                              'PQP_US_INCOME_CODE_SUB_TYPE'   );
            hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_income_code_sub_type;
--
-- ----------------------------------------------------------------------------
-- |------< chk_exemption_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   exemption_code Value of lookup code.
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
PROCEDURE chk_exemption_code(p_analyzed_data_details_id    in number ,
                                      p_exemption_code in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_exemption_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_det_shd.api_updating
                        (p_analyzed_data_details_id=>p_analyzed_data_details_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_exemption_code
         <> NVL(pqp_det_shd.g_old_rec.exemption_code,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_exemption_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_US_EXEMPTION_CODE' ,
             p_lookup_code    => p_exemption_code        ,
             p_effective_date => p_effective_date        ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801, 'HR_52966_INVALID_LOOKUP'       );
            hr_utility.set_message_token('COLUMN', 'exemption_code'     );
            hr_utility.set_message_token('LOOKUP_TYPE',
                                              'PQP_US_EXEMPTION_CODE'   );
            hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_exemption_code;
--
-- ----------------------------------------------------------------------------
-- |------< chk_addl_wthldng_amt_period >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_details_id PK of record being inserted or updated.
--   addl_wthldng_amt_period_type Value of lookup code.
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
PROCEDURE chk_addl_wthldng_amt_period(p_analyzed_data_details_id    in number ,
                                      p_addl_wthldng_amt_period_type in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_addl_wthldng_amt_period_type';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_det_shd.api_updating
                        (p_analyzed_data_details_id=>p_analyzed_data_details_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_addl_wthldng_amt_period_type
         <> NVL(pqp_det_shd.g_old_rec.addl_wthldng_amt_period_type,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_addl_wthldng_amt_period_type IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PROC_PERIOD_TYPE'             ,
             p_lookup_code    => p_addl_wthldng_amt_period_type ,
             p_effective_date => p_effective_date               ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801, 'HR_52966_INVALID_LOOKUP'       );
            hr_utility.set_message_token('COLUMN',
                                           'addl_wthldng_amt_period_type'     );
            hr_utility.set_message_token('LOOKUP_TYPE',
                                           'PROC_PERIOD_TYPE'   );
            hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_addl_wthldng_amt_period;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqp_det_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_analyzed_data_details_id
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_analyzed_data_id
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_retro_lose_ben_amt_flag
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_retro_lose_ben_amt_flag         => p_rec.retro_lose_ben_amt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_treaty_ben_allowed_flag
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_treaty_ben_allowed_flag         => p_rec.treaty_ben_allowed_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_addl_withholding_flag
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_addl_withholding_flag         => p_rec.addl_withholding_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_retro_lose_ben_date_flag
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_retro_lose_ben_date_flag         => p_rec.retro_lose_ben_date_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_student_exempt_from_ss
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_student_exempt_from_ss    =>  p_rec.student_exempt_from_ss,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_nra_exempt_from_ss
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_nra_exempt_from_ss          =>  p_rec.nra_exempt_from_ss      ,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_nra_exempt_from_medicare
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_nra_exempt_from_medicare    =>  p_rec.nra_exempt_from_medicare,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_income_code
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_income_code                 =>  p_rec.income_code             ,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_income_code_sub_type
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_income_code_sub_type        =>  p_rec.income_code_sub_type    ,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_exemption_code
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_exemption_code                 =>  p_rec.exemption_code             ,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_addl_wthldng_amt_period
  (p_analyzed_data_details_id     => p_rec.analyzed_data_details_id    ,
   p_addl_wthldng_amt_period_type => p_rec.addl_wthldng_amt_period_type,
   p_effective_date               => p_effective_date                  ,
   p_object_version_number        => p_rec.object_version_number      );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqp_det_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_analyzed_data_details_id
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_analyzed_data_id
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_retro_lose_ben_amt_flag
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_retro_lose_ben_amt_flag         => p_rec.retro_lose_ben_amt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_treaty_ben_allowed_flag
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_treaty_ben_allowed_flag         => p_rec.treaty_ben_allowed_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_addl_withholding_flag
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_addl_withholding_flag         => p_rec.addl_withholding_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_retro_lose_ben_date_flag
  (p_analyzed_data_details_id          => p_rec.analyzed_data_details_id,
   p_retro_lose_ben_date_flag         => p_rec.retro_lose_ben_date_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_student_exempt_from_ss
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_student_exempt_from_ss    =>  p_rec.student_exempt_from_ss,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_nra_exempt_from_ss
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_nra_exempt_from_ss          =>  p_rec.nra_exempt_from_ss      ,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_nra_exempt_from_medicare
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_nra_exempt_from_medicare    =>  p_rec.nra_exempt_from_medicare,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_income_code
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_income_code                 =>  p_rec.income_code             ,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_income_code_sub_type
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_income_code_sub_type        =>  p_rec.income_code_sub_type    ,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_exemption_code
  (p_analyzed_data_details_id    =>  p_rec.analyzed_data_details_id,
   p_exemption_code                 =>  p_rec.exemption_code             ,
   p_effective_date              =>  p_effective_date              ,
   p_object_version_number       =>  p_rec.object_version_number   );
  --
  chk_addl_wthldng_amt_period
  (p_analyzed_data_details_id     => p_rec.analyzed_data_details_id    ,
   p_addl_wthldng_amt_period_type => p_rec.addl_wthldng_amt_period_type,
   p_effective_date               => p_effective_date                  ,
   p_object_version_number        => p_rec.object_version_number      );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqp_det_shd.g_rec_type
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
end pqp_det_bus;

/
