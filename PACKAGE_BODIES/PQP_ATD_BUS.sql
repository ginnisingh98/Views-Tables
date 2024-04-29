--------------------------------------------------------
--  DDL for Package Body PQP_ATD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ATD_BUS" as
/* $Header: pqatdrhi.pkb 115.10 2003/02/17 22:13:56 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)  := '  pqp_atd_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_alien_transaction_id >------|
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
--   alien_transaction_id PK of record being inserted or updated.
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
PROCEDURE chk_alien_transaction_id(p_alien_transaction_id  IN NUMBER ,
                                   p_object_version_number IN NUMBER ) IS
  --
  l_proc         VARCHAR2(72) := g_package || 'chk_alien_transaction_id';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_atd_shd.api_updating
    (p_alien_transaction_id        => p_alien_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_alien_transaction_id,hr_api.g_number)
     <>  pqp_atd_shd.g_old_rec.alien_transaction_id) then
    --
    -- raise error as PK has changed
    --
    pqp_atd_shd.constraint_error('PQP_ALIEN_TRANSACTION_DATA_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_alien_transaction_id is not null then
      --
      -- raise error as PK is not null
      --
      pqp_atd_shd.constraint_error('PQP_ALIEN_TRANSACTION_DATA_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_alien_transaction_id;
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
--   alien_transaction_id PK of record being inserted or updated.
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
PROCEDURE chk_treaty_ben_allowed_flag(p_alien_transaction_id    in number   ,
                                      p_treaty_ben_allowed_flag in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_treaty_ben_allowed_flag';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                        (p_alien_transaction_id   => p_alien_transaction_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_treaty_ben_allowed_flag
         <> NVL(pqp_atd_shd.g_old_rec.treaty_ben_allowed_flag,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_treaty_ben_allowed_flag IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQH_YES_NO'               ,
             p_lookup_code    => p_treaty_ben_allowed_flag ,
             p_effective_date => p_effective_date          ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
          hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
          hr_utility.raise_error;  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'treaty_ben_allowed_flag = ' ||
                               p_treaty_ben_allowed_flag || ' is invalid )';

      --
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_treaty_ben_allowed_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_wthldg_allow_eligible_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_wthldg_allow_eligible_flag(p_alien_transaction_id     IN NUMBER  ,
                                       p_wthldg_allow_eligible_flag IN VARCHAR2,
                                       p_effective_date             IN DATE    ,
                                       p_object_version_number      IN NUMBER  )
                                                                            IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_wthldg_allow_eligible_flag';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_wthldg_allow_eligible_flag
          <> nvl(pqp_atd_shd.g_old_rec.wthldg_allow_eligible_flag,hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_wthldg_allow_eligible_flag IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'                 ,
           p_lookup_code    => p_wthldg_allow_eligible_flag,
           p_effective_date => p_effective_date) then
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'wthldg_allow_eligible_flag = ' ||
                               p_wthldg_allow_eligible_flag || ' is invalid )';
      --
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_wthldg_allow_eligible_flag;
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
--   alien_transaction_id PK of record being inserted or updated.
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
Procedure chk_addl_withholding_flag(p_alien_transaction_id                in number,
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
  l_api_updating := pqp_atd_shd.api_updating
    (p_alien_transaction_id                => p_alien_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_addl_withholding_flag
      <> nvl(pqp_atd_shd.g_old_rec.addl_withholding_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_addl_withholding_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'            ,
           p_lookup_code    => p_addl_withholding_flag,
           p_effective_date => p_effective_date) then
/*      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'addl_withholding_flag = ' ||
                               p_addl_withholding_flag || ' is invalid )';
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
--   alien_transaction_id PK of record being inserted or updated.
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
Procedure chk_retro_lose_ben_date_flag(p_alien_transaction_id                in number,
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
  l_api_updating := pqp_atd_shd.api_updating
    (p_alien_transaction_id                => p_alien_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_retro_lose_ben_date_flag
      <> nvl(pqp_atd_shd.g_old_rec.retro_lose_ben_date_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_retro_lose_ben_date_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'               ,
           p_lookup_code    => p_retro_lose_ben_date_flag,
           p_effective_date => p_effective_date) then
/*      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'retro_lose_ben_date_flag  = ' ||
                               p_retro_lose_ben_date_flag || ' is invalid )';
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_retro_lose_ben_date_flag;
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
--   alien_transaction_id PK of record being inserted or updated.
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
Procedure chk_retro_lose_ben_amt_flag(p_alien_transaction_id                in number,
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
  l_api_updating := pqp_atd_shd.api_updating
    (p_alien_transaction_id                => p_alien_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_retro_lose_ben_amt_flag
      <> nvl(pqp_atd_shd.g_old_rec.retro_lose_ben_amt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_retro_lose_ben_amt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'              ,
           p_lookup_code    => p_retro_lose_ben_amt_flag,
           p_effective_date => p_effective_date) then
/*      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'retro_lose_ben_amt_flag  = ' ||
                               p_retro_lose_ben_amt_flag || ' is invalid )';
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_retro_lose_ben_amt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_state_honors_treaty_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   state_honors_treaty_flag Value of lookup code.
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
Procedure chk_state_honors_treaty_flag(p_alien_transaction_id                in number,
                            p_state_honors_treaty_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_state_honors_treaty_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_atd_shd.api_updating
    (p_alien_transaction_id                => p_alien_transaction_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_state_honors_treaty_flag
      <> nvl(pqp_atd_shd.g_old_rec.state_honors_treaty_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_state_honors_treaty_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO'               ,
           p_lookup_code    => p_state_honors_treaty_flag,
           p_effective_date => p_effective_date) then
/*      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --  */
      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'state_honors_treaty_flag  = ' ||
                               p_state_honors_treaty_flag || ' is invalid )';
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_state_honors_treaty_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_student_exempt_from_fica >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   student_exempt_from_fica Value of lookup code.
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
PROCEDURE chk_student_exempt_from_fica(p_alien_transaction_id    in number   ,
                                      p_student_exempt_from_fica in varchar2 ,
                                      p_effective_date          in date     ,
                                      p_object_version_number   in number   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_student_exempt_from_fica';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                        (p_alien_transaction_id   => p_alien_transaction_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_student_exempt_from_fica
         <> NVL(pqp_atd_shd.g_old_rec.student_exempt_from_fica,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_student_exempt_from_fica IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQH_YES_NO'                ,
             p_lookup_code    => p_student_exempt_from_fica ,
             p_effective_date => p_effective_date          ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
          hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
          hr_utility.raise_error;
      --  */
      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'student_exempt_from_fica  = ' ||
                               p_student_exempt_from_fica || ' is invalid )';
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_student_exempt_from_fica;
--
-- |------< chk_nra_exempt_from_fica >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   nra_exempt_from_fica Value of lookup code.
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
PROCEDURE chk_nra_exempt_from_fica(p_alien_transaction_id    in number ,
                                   p_nra_exempt_from_fica in varchar2  ,
                                   p_effective_date          in date   ,
                                   p_object_version_number   in number ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_nra_exempt_from_fica';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                        (p_alien_transaction_id   => p_alien_transaction_id,
                         p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating            AND
        p_nra_exempt_from_fica
         <> NVL(pqp_atd_shd.g_old_rec.nra_exempt_from_fica,hr_api.g_varchar2)
       OR NOT l_api_updating)
       AND p_nra_exempt_from_fica IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQH_YES_NO'            ,
             p_lookup_code    => p_nra_exempt_from_fica ,
             p_effective_date => p_effective_date       ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
          hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
          hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'nra_exempt_from_fica = ' ||
                               p_nra_exempt_from_fica || ' is invalid )';
        END IF;
    --
    END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_nra_exempt_from_fica;
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
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_income_code(p_alien_transaction_id     IN NUMBER   ,
                          p_income_code              IN VARCHAR2 ,
                          p_effective_date           IN DATE     ,
                          p_object_version_number    IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_income_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_income_code
          <> nvl(pqp_atd_shd.g_old_rec.income_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_income_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_INCOME_TYPES' ,
             p_lookup_code    => p_income_code         ,
             p_effective_date => p_effective_date      )  THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */
      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'income_code = ' ||
                               p_income_code || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_income_code;
--
-- ----------------------------------------------------------------------------
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
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_income_code_sub_type(p_alien_transaction_id  IN NUMBER   ,
                                   p_income_code_sub_type  IN VARCHAR2 ,
                                   p_effective_date        IN DATE     ,
                                   p_object_version_number IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_income_code_sub_type';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_income_code_sub_type
          <> nvl(pqp_atd_shd.g_old_rec.income_code_sub_type, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_income_code_sub_type IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_US_INCOME_CODE_SUB_TYPE',
             p_lookup_code    => p_income_code_sub_type       ,
             p_effective_date => p_effective_date             ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'income_code_sub_type = ' ||
                               p_income_code_sub_type || ' is invalid )';
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
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_exemption_code(p_alien_transaction_id  IN NUMBER   ,
                             p_exemption_code        IN VARCHAR2 ,
                             p_effective_date        IN DATE     ,
                             p_object_version_number IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_exemption_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_exemption_code
          <> nvl(pqp_atd_shd.g_old_rec.exemption_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_exemption_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_US_EXEMPTION_CODE' ,
             p_lookup_code    => p_exemption_code        ,
             p_effective_date => p_effective_date        ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            --app_exception.raise_exception;
            hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'exemption_code = ' ||
                               p_exemption_code || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_exemption_code;
--
-- ----------------------------------------------------------------------------
-- |------< chk_current_residency_status >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_current_residency_status(p_alien_transaction_id     IN NUMBER   ,
                                       p_current_residency_status IN VARCHAR2 ,
                                       p_effective_date           IN DATE     ,
                                       p_object_version_number    IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_current_residency_status';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_current_residency_status
          <> nvl(pqp_atd_shd.g_old_rec.current_residency_status, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_current_residency_status IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_RES_STATUS'         ,
             p_lookup_code    => p_current_residency_status  ,
             p_effective_date => p_effective_date            ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'current_residency_status = ' ||
                               p_current_residency_status || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_current_residency_status;
--
-- ----------------------------------------------------------------------------
-- |------< chk_tax_residence_country_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_tax_residence_country_code(p_alien_transaction_id       IN NUMBER,
                                         p_tax_residence_country_code IN VARCHAR2 ,
                                         p_effective_date             IN DATE  ,
                                         p_object_version_number      IN NUMBER) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_tax_residence_country_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_tax_residence_country_code
          <> nvl(pqp_atd_shd.g_old_rec.tax_residence_country_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_tax_residence_country_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_COUNTRY_CODE'         ,
             p_lookup_code    => p_tax_residence_country_code  ,
             p_effective_date => p_effective_date              ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'tax_residence_country_code = ' ||
                               p_tax_residence_country_code || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_tax_residence_country_code;
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
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_addtnl_wthldng_amt_period(p_alien_transaction_id      IN NUMBER  ,
                                        p_addtnl_wthldng_amt_period IN VARCHAR2,
                                        p_effective_date            IN DATE    ,
                                        p_object_version_number     IN NUMBER  ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_addtnl_wthldng_amt_period';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_addtnl_wthldng_amt_period
          <> nvl(pqp_atd_shd.g_old_rec.addl_wthldng_amt_period_type, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_addtnl_wthldng_amt_period IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PROC_PERIOD_TYPE'          ,
             p_lookup_code    => p_addtnl_wthldng_amt_period ,
             p_effective_date => p_effective_date            ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'addl_wthldng_amt_period_type = ' ||
                               p_addtnl_wthldng_amt_period || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_addtnl_wthldng_amt_period;
-- ----------------------------------------------------------------------------
-- |------< chk_state_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_state_code(p_alien_transaction_id     IN NUMBER   ,
                         p_state_code               IN VARCHAR2 ,
                         p_effective_date           IN DATE     ,
                         p_object_version_number    IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_state_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_state_code
          <> nvl(pqp_atd_shd.g_old_rec.state_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_state_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'US_STATE'        ,
             p_lookup_code    => p_state_code      ,
             p_effective_date => p_effective_date  ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */
      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'state_code = ' ||
                               p_state_code || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_state_code;
--
-- ----------------------------------------------------------------------------
-- |------< chk_record_source >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_record_source(p_alien_transaction_id   IN NUMBER   ,
                            p_record_source          IN VARCHAR2 ,
                            p_effective_date         IN DATE     ,
                            p_object_version_number  IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_record_source';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_record_source
         <> nvl(pqp_atd_shd.g_old_rec.record_source, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_record_source IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_US_RECORD_SOURCE' ,
             p_lookup_code    => p_record_source        ,
             p_effective_date => p_effective_date       ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'record_source = ' ||
                               p_record_source || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_record_source;
--
-- ----------------------------------------------------------------------------
-- |------< chk_visa_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_visa_type(p_alien_transaction_id  IN NUMBER   ,
                        p_visa_type             IN VARCHAR2 ,
                        p_effective_date        IN DATE     ,
                        p_object_version_number IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_visa_type';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_visa_type
          <> nvl(pqp_atd_shd.g_old_rec.visa_type, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_visa_type IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_VISA_TYPES' ,
             p_lookup_code    => p_visa_type         ,
             p_effective_date => p_effective_date    ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'visa_type = ' ||
                               p_visa_type || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_visa_type;
--
-- ----------------------------------------------------------------------------
-- |------< chk_j_sub_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_j_sub_type(p_alien_transaction_id   IN NUMBER   ,
                         p_j_sub_type             IN VARCHAR2 ,
                         p_effective_date         IN DATE     ,
                         p_object_version_number  IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_j_sub_type';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_j_sub_type
          <> nvl(pqp_atd_shd.g_old_rec.j_sub_type, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_j_sub_type IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_VISA_CATEGORIES' ,
             p_lookup_code    => p_j_sub_type             ,
             p_effective_date => p_effective_date         ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */
      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'j_sub_type = ' ||
                               p_j_sub_type || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_j_sub_type;
--
-- ----------------------------------------------------------------------------
-- |------< chk_primary_activity >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_primary_activity(p_alien_transaction_id  IN NUMBER   ,
                               p_primary_activity      IN VARCHAR2 ,
                               p_effective_date        IN DATE     ,
                               p_object_version_number IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_primary_activity';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_primary_activity
          <> nvl(pqp_atd_shd.g_old_rec.primary_activity, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_primary_activity IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_US_PRIMARY_ACTIVITY' ,
             p_lookup_code    => p_primary_activity        ,
             p_effective_date => p_effective_date          ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */
      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'primary_activity = ' ||
                               p_primary_activity || ' is invalid )';
        END IF;

    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_primary_activity;
--
-- ----------------------------------------------------------------------------
-- |------< chk_non_us_country_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_non_us_country_code(p_alien_transaction_id  IN NUMBER   ,
                                  p_non_us_country_code   IN VARCHAR2 ,
                                  p_effective_date        IN DATE     ,
                                  p_object_version_number IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_non_us_country_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_non_us_country_code
          <> nvl(pqp_atd_shd.g_old_rec.non_us_country_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_non_us_country_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'FND_TERRITORIES_VL'   ,
             p_lookup_code    => p_non_us_country_code  ,
             p_effective_date => p_effective_date       ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */
      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'non_us_country_code = ' ||
                               p_non_us_country_code || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_non_us_country_code;
--
-- ----------------------------------------------------------------------------
-- |------< chk_citizenship_country_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   alien_transaction_id PK of record being inserted or updated.
--   wthldg_allow_eligible_flag Value of lookup code.
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
PROCEDURE chk_citizenship_country_code(p_alien_transaction_id     IN NUMBER   ,
                                       p_citizenship_country_code IN VARCHAR2 ,
                                       p_effective_date           IN DATE     ,
                                       p_object_version_number    IN NUMBER   ) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_citizenship_country_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_atd_shd.api_updating
                      (p_alien_transaction_id   => p_alien_transaction_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_citizenship_country_code
          <> nvl(pqp_atd_shd.g_old_rec.citizenship_country_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_citizenship_country_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'FND_TERRITORIES_VL'        ,
             p_lookup_code    => p_citizenship_country_code  ,
             p_effective_date => p_effective_date            ) THEN
/*      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --  */

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || '(' ||
                               'citizenship_country_code = ' ||
                               p_citizenship_country_code || ' is invalid )';
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_citizenship_country_code;
--
-- ----------------------------------------------------------------------------
-- |------< chk_benefit_amount_percent >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the both Maximum Benefit amount
--   and Withholding percaentage are not Non Zero.
--   Tmehra added the conditon to check if Maximum Benefit amount is 999999
--   then do not report the error.
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_withholding_rate        Withholding Rate
--     p_maximum_benefit_amount  Maximum Benefit Amount
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
PROCEDURE chk_benefit_amount_percent
       (p_withholding_rate        IN NUMBER ,
        p_maximum_benefit_amount  IN NUMBER )
IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_benefit_amount_percent';
  --
BEGIN
    hr_utility.set_location('Entering:'||l_proc,10);

    IF (NVL(p_withholding_rate      , 0) > 0  AND
        NVL(p_maximum_benefit_amount, 0) > 0  AND
        NVL(p_maximum_benefit_amount, 0) <> 999999 ) THEN

      -- Append the error message to the g_error_message

        g_error_message := g_error_message || 'Both Max Benefit Amount and ' ||
                              'Withholding Rate cannot be more than 0';
    END IF;

    hr_utility.set_location('Leaving:'||l_proc,10);
END chk_benefit_amount_percent;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqp_atd_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_alien_transaction_id
  (p_alien_transaction_id          => p_rec.alien_transaction_id  ,
   p_object_version_number         => p_rec.object_version_number );
 --
  chk_treaty_ben_allowed_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_treaty_ben_allowed_flag       => p_rec.treaty_ben_allowed_flag ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
  --
  chk_wthldg_allow_eligible_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id       ,
   p_wthldg_allow_eligible_flag    => p_rec.wthldg_allow_eligible_flag ,
   p_effective_date                => p_effective_date                 ,
   p_object_version_number         => p_rec.object_version_number      );
  --
  chk_addl_withholding_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id  ,
   p_addl_withholding_flag         => p_rec.addl_withholding_flag ,
   p_effective_date                => p_effective_date            ,
   p_object_version_number         => p_rec.object_version_number );
  --
  chk_retro_lose_ben_date_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id     ,
   p_retro_lose_ben_date_flag      => p_rec.retro_lose_ben_date_flag ,
   p_effective_date                => p_effective_date               ,
   p_object_version_number         => p_rec.object_version_number    );
  --
  chk_retro_lose_ben_amt_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_retro_lose_ben_amt_flag       => p_rec.retro_lose_ben_amt_flag ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
  --
  chk_state_honors_treaty_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id     ,
   p_state_honors_treaty_flag      => p_rec.state_honors_treaty_flag ,
   p_effective_date                => p_effective_date               ,
   p_object_version_number         => p_rec.object_version_number    );
  --
  chk_student_exempt_from_fica
  (p_alien_transaction_id          => p_rec.alien_transaction_id     ,
   p_student_exempt_from_fica      => p_rec.student_exempt_from_fica ,
   p_effective_date                => p_effective_date               ,
   p_object_version_number         => p_rec.object_version_number    );
 --
  chk_nra_exempt_from_fica
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_nra_exempt_from_fica          => p_rec.nra_exempt_from_fica    ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
  --
  chk_income_code
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_income_code                   => p_rec.income_code             ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
 --
  chk_income_code_sub_type
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_income_code_sub_type          => p_rec.income_code_sub_type    ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number  );
 --
  chk_exemption_code
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_exemption_code                => p_rec.exemption_code          ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
 --
  chk_current_residency_status
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_current_residency_status      => p_rec.current_residency_status,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
 --
  chk_tax_residence_country_code
  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
   p_tax_residence_country_code    => p_rec.tax_residence_country_code,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_addtnl_wthldng_amt_period
  (p_alien_transaction_id          => p_rec.alien_transaction_id         ,
   p_addtnl_wthldng_amt_period     => p_rec.addl_wthldng_amt_period_type ,
   p_effective_date                => p_effective_date                   ,
   p_object_version_number         => p_rec.object_version_number        );
 --
  chk_state_code
  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
   p_state_code                    => p_rec.state_code                ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
--  chk_record_source
--  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
--   p_record_source                 => p_rec.record_source             ,
--   p_effective_date                => p_effective_date                ,
--   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_visa_type
  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
   p_visa_type                     => p_rec.visa_type                 ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
  IF (p_rec.visa_type = 'J-1' OR
      p_rec.visa_type = 'J-2' ) THEN
      chk_j_sub_type
      (  p_alien_transaction_id          => p_rec.alien_transaction_id      ,
         p_j_sub_type                    => p_rec.j_sub_type                ,
         p_effective_date                => p_effective_date                ,
         p_object_version_number         => p_rec.object_version_number
      );
  END IF;
 --
  chk_primary_activity
  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
   p_primary_activity              => p_rec.primary_activity          ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_benefit_amount_percent
  ( p_withholding_rate             => p_rec.withholding_rate        ,
   p_maximum_benefit_amount        => p_rec.maximum_benefit_amount  );
--
--  chk_non_us_country_code
--  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
--   p_non_us_country_code           => p_rec.non_us_country_code       ,
--   p_effective_date                => p_effective_date                ,
--   p_object_version_number         => p_rec.object_version_number     ) ;
 --
--  chk_citizenship_country_code
--  (p_alien_transaction_id          => p_rec.alien_transaction_id     ,
--   p_citizenship_country_code      => p_rec.citizenship_country_code ,
--   p_effective_date                => p_effective_date               ,
--   p_object_version_number         => p_rec.object_version_number    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqp_atd_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_alien_transaction_id
  (p_alien_transaction_id          => p_rec.alien_transaction_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_treaty_ben_allowed_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id,
   p_treaty_ben_allowed_flag         => p_rec.treaty_ben_allowed_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wthldg_allow_eligible_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id,
   p_wthldg_allow_eligible_flag         => p_rec.wthldg_allow_eligible_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_addl_withholding_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id,
   p_addl_withholding_flag         => p_rec.addl_withholding_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_retro_lose_ben_date_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id,
   p_retro_lose_ben_date_flag         => p_rec.retro_lose_ben_date_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_retro_lose_ben_amt_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id,
   p_retro_lose_ben_amt_flag         => p_rec.retro_lose_ben_amt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_state_honors_treaty_flag
  (p_alien_transaction_id          => p_rec.alien_transaction_id,
   p_state_honors_treaty_flag         => p_rec.state_honors_treaty_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_student_exempt_from_fica
  (p_alien_transaction_id          => p_rec.alien_transaction_id     ,
   p_student_exempt_from_fica      => p_rec.student_exempt_from_fica ,
   p_effective_date                => p_effective_date               ,
   p_object_version_number         => p_rec.object_version_number    );
 --
  chk_nra_exempt_from_fica
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_nra_exempt_from_fica          => p_rec.nra_exempt_from_fica    ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
  --
  chk_income_code
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_income_code                   => p_rec.income_code             ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
 --
  chk_income_code_sub_type
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_income_code_sub_type          => p_rec.income_code_sub_type    ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number  );
 --
  chk_exemption_code
  (p_alien_transaction_id          => p_rec.alien_transaction_id    ,
   p_exemption_code                => p_rec.exemption_code          ,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
 --
  chk_current_residency_status
  (p_alien_transaction_id          => p_rec.alien_transaction_id     ,
   p_current_residency_status      => p_rec.current_residency_status ,
   p_effective_date                => p_effective_date               ,
   p_object_version_number         => p_rec.object_version_number    );
 --
  chk_tax_residence_country_code
  (p_alien_transaction_id          => p_rec.alien_transaction_id       ,
   p_tax_residence_country_code    => p_rec.tax_residence_country_code ,
   p_effective_date                => p_effective_date                 ,
   p_object_version_number         => p_rec.object_version_number      );
 --
  chk_addtnl_wthldng_amt_period
  (p_alien_transaction_id          => p_rec.alien_transaction_id         ,
   p_addtnl_wthldng_amt_period     => p_rec.addl_wthldng_amt_period_type ,
   p_effective_date                => p_effective_date                   ,
   p_object_version_number         => p_rec.object_version_number        );
 --
  chk_state_code
  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
   p_state_code                    => p_rec.state_code                ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
--  chk_record_source
--  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
--   p_record_source                 => p_rec.record_source             ,
--   p_effective_date                => p_effective_date                ,
--   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_visa_type
  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
   p_visa_type                     => p_rec.visa_type                 ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
  IF (p_rec.visa_type = 'J-1' OR
      p_rec.visa_type = 'J-2' ) THEN
      chk_j_sub_type
      (  p_alien_transaction_id          => p_rec.alien_transaction_id      ,
         p_j_sub_type                    => p_rec.j_sub_type                ,
         p_effective_date                => p_effective_date                ,
         p_object_version_number         => p_rec.object_version_number
      );
  END IF;
 --
  chk_primary_activity
  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
   p_primary_activity              => p_rec.primary_activity          ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_benefit_amount_percent
  ( p_withholding_rate             => p_rec.withholding_rate        ,
   p_maximum_benefit_amount       =>  p_rec.maximum_benefit_amount  );
--
--  chk_non_us_country_code
--  (p_alien_transaction_id          => p_rec.alien_transaction_id      ,
--   p_non_us_country_code           => p_rec.non_us_country_code       ,
--   p_effective_date                => p_effective_date                ,
--   p_object_version_number         => p_rec.object_version_number     );
 --
--  chk_citizenship_country_code
--  (p_alien_transaction_id          => p_rec.alien_transaction_id     ,
--   p_citizenship_country_code      => p_rec.citizenship_country_code ,
--   p_effective_date                => p_effective_date               ,
--   p_object_version_number         => p_rec.object_version_number    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqp_atd_shd.g_rec_type
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
end pqp_atd_bus;

/
