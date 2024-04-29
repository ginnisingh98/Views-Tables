--------------------------------------------------------
--  DDL for Package Body PQP_AAD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAD_BUS" as
/* $Header: pqaadrhi.pkb 115.5 2003/02/17 22:13:35 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_aad_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_analyzed_data_id >------|
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
--   analyzed_data_id PK of record being inserted or updated.
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
Procedure chk_analyzed_data_id(p_analyzed_data_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_analyzed_data_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_aad_shd.api_updating
    (p_analyzed_data_id                => p_analyzed_data_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_analyzed_data_id,hr_api.g_number)
     <>  pqp_aad_shd.g_old_rec.analyzed_data_id) then
    --
    -- raise error as PK has changed
    --
    pqp_aad_shd.constraint_error('PQP_ANALYZED_ALIEN_DATA_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_analyzed_data_id is not null then
      --
      -- raise error as PK is not null
      --
      pqp_aad_shd.constraint_error('PQP_ANALYZED_ALIEN_DATA_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_analyzed_data_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_withldg_allow_elig_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_id PK of record being inserted or updated.
--   withldg_allow_eligible_flag Value of lookup code.
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
Procedure chk_withldg_allow_elig_flag(p_analyzed_data_id                in number,
                            p_withldg_allow_eligible_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_withldg_allow_elig_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqp_aad_shd.api_updating
    (p_analyzed_data_id                => p_analyzed_data_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_withldg_allow_eligible_flag
      <> nvl(pqp_aad_shd.g_old_rec.withldg_allow_eligible_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_withldg_allow_eligible_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_YES_NO',
           p_lookup_code    => p_withldg_allow_eligible_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'                );
        hr_utility.set_message_token('COLUMN','withldg_allow_eligible_flag' );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PQH_YES_NO'            );
        hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_withldg_allow_elig_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_current_residency_status >------| Added by Ashu Gupta 01-AUG-00
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   analyzed_data_id PK of record being inserted or updated.
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
PROCEDURE chk_current_residency_status(p_analyzed_data_id         IN NUMBER   ,
                                       p_current_residency_status IN VARCHAR2 ,
                                       p_effective_date           IN DATE     ,
                                       p_object_version_number    IN NUMBER   )
IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_current_residency_status';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
 l_api_updating := pqp_aad_shd.api_updating
                      (p_analyzed_data_id       => p_analyzed_data_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_current_residency_status
          <> nvl(pqp_aad_shd.g_old_rec.current_residency_status, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_current_residency_status IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_RES_STATUS'         ,
             p_lookup_code    => p_current_residency_status  ,
             p_effective_date => p_effective_date            ) THEN
      --
      -- raise error as does not exist as lookup
      --
        hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'             );
        hr_utility.set_message_token('COLUMN','current_residency_status' );
        hr_utility.set_message_token('LOOKUP_TYPE', 'PER_US_RES_STATUS'  );
        hr_utility.raise_error;
      --
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
--   p_analyzed_data_id PK of record being inserted or updated.
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
PROCEDURE chk_tax_residence_country_code(p_analyzed_data_id           IN NUMBER,
                                         p_tax_residence_country_code IN VARCHAR2 ,
                                         p_effective_date             IN DATE  ,
                                         p_object_version_number      IN NUMBER)
 IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_tax_residence_country_code';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    l_api_updating := pqp_aad_shd.api_updating
                      (p_analyzed_data_id       => p_analyzed_data_id     ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_tax_residence_country_code
          <> nvl(pqp_aad_shd.g_old_rec.tax_residence_country_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_tax_residence_country_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_COUNTRY_CODE'         ,
             p_lookup_code    => p_tax_residence_country_code  ,
             p_effective_date => p_effective_date              ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'              );
            hr_utility.set_message_token('COLUMN','tax_residence_country_code');
            hr_utility.set_message_token('LOOKUP_TYPE', 'PER_US_COUNTRY_CODE' );
            hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_tax_residence_country_code;
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
--   analyzed_data_id PK of record being inserted or updated.
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
PROCEDURE chk_record_source(p_analyzed_data_id       IN NUMBER   ,
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
    l_api_updating := pqp_aad_shd.api_updating
                      (p_analyzed_data_id   => p_analyzed_data_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_record_source
         <> nvl(pqp_aad_shd.g_old_rec.record_source, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_record_source IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_US_RECORD_SOURCE' ,
             p_lookup_code    => p_record_source        ,
             p_effective_date => p_effective_date       ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'              );
            hr_utility.set_message_token('COLUMN','record_source');
            hr_utility.set_message_token('LOOKUP_TYPE', 'PQP_US_RECORD_SOURCE');
            hr_utility.raise_error;
      --
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
--   analyzed_data_id PK of record being inserted or updated.
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
PROCEDURE chk_visa_type(p_analyzed_data_id      IN NUMBER   ,
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
    l_api_updating := pqp_aad_shd.api_updating
                      (p_analyzed_data_id       => p_analyzed_data_id ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_visa_type
          <> nvl(pqp_aad_shd.g_old_rec.visa_type, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_visa_type IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_VISA_TYPES' ,
             p_lookup_code    => p_visa_type         ,
             p_effective_date => p_effective_date    ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'              );
            hr_utility.set_message_token('COLUMN','visa_type');
            hr_utility.set_message_token('LOOKUP_TYPE', 'PER_US_VISA_TYPES');
            hr_utility.raise_error;
      --
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
--   analyzed_data_id PK of record being inserted or updated.
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
PROCEDURE chk_j_sub_type(p_analyzed_data_id       IN NUMBER   ,
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
    l_api_updating := pqp_aad_shd.api_updating
                      (p_analyzed_data_id       => p_analyzed_data_id     ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_j_sub_type
          <> nvl(pqp_aad_shd.g_old_rec.j_sub_type,hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_j_sub_type IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PER_US_VISA_CATEGORIES' ,
             p_lookup_code    => p_j_sub_type             ,
             p_effective_date => p_effective_date         ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'              );
            hr_utility.set_message_token('COLUMN','j_sub_type'                );
            hr_utility.set_message_token('LOOKUP_TYPE',
                                                      'PER_US_VISA_CATEGORIES');
            hr_utility.raise_error;
      --
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
--   analyzed_data_id PK of record being inserted or updated.
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
PROCEDURE chk_primary_activity(p_analyzed_data_id      IN NUMBER   ,
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
    l_api_updating := pqp_aad_shd.api_updating
                      (p_analyzed_data_id       => p_analyzed_data_id     ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_primary_activity
          <> nvl(pqp_aad_shd.g_old_rec.primary_activity, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_primary_activity IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'PQP_US_PRIMARY_ACTIVITY' ,
             p_lookup_code    => p_primary_activity        ,
             p_effective_date => p_effective_date          ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'              );
            hr_utility.set_message_token('COLUMN','primary_activity'          );
            hr_utility.set_message_token('LOOKUP_TYPE',
                                                     'PQP_US_PRIMARY_ACTIVITY');
            hr_utility.raise_error;
      --
        END IF;
    --
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
--   analyzed_data_id PK of record being inserted or updated.
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
PROCEDURE chk_non_us_country_code(p_analyzed_data_id      IN NUMBER   ,
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
    l_api_updating := pqp_aad_shd.api_updating
                      (p_analyzed_data_id       => p_analyzed_data_id     ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_non_us_country_code
          <> nvl(pqp_aad_shd.g_old_rec.non_us_country_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_non_us_country_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'FND_TERRITORIES_VL'   ,
             p_lookup_code    => p_non_us_country_code  ,
             p_effective_date => p_effective_date       ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_52966_INVALID_LOOKUP'            );
            hr_utility.set_message_token('COLUMN','non_us_country_code'     );
            hr_utility.set_message_token('LOOKUP_TYPE', '');
            hr_utility.raise_error;
      --
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
--   analyzed_data_id PK of record being inserted or updated.
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
PROCEDURE chk_citizenship_country_code(p_analyzed_data_id         IN NUMBER   ,
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
    l_api_updating := pqp_aad_shd.api_updating
                      (p_analyzed_data_id       => p_analyzed_data_id     ,
                       p_object_version_number  => p_object_version_number);
  --
    IF (l_api_updating AND
        p_citizenship_country_code
          <> nvl(pqp_aad_shd.g_old_rec.citizenship_country_code, hr_api.g_varchar2)
        OR NOT l_api_updating)
        AND p_citizenship_country_code IS NOT NULL THEN
    --
    -- check if value of lookup falls within lookup type.
    --
        IF hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'FND_TERRITORIES_VL'        ,
             p_lookup_code    => p_citizenship_country_code  ,
             p_effective_date => p_effective_date            ) THEN
      --
      -- raise error as does not exist as lookup
      --
            hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
            hr_utility.raise_error;
      --
        END IF;
    --
    END IF;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_citizenship_country_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqp_aad_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_analyzed_data_id
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_withldg_allow_elig_flag
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_withldg_allow_eligible_flag         => p_rec.withldg_allow_eligible_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_current_residency_status
  (p_analyzed_data_id              => p_rec.analyzed_data_id        ,
   p_current_residency_status      => p_rec.current_residency_status,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
  --
  chk_tax_residence_country_code
  (p_analyzed_data_id              => p_rec.analyzed_data_id        ,
   p_tax_residence_country_code    => p_rec.tax_residence_country_code,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
--  chk_record_source
--  (p_analyzed_data_id              => p_rec.analyzed_data_id        ,
--   p_record_source                 => p_rec.record_source             ,
--   p_effective_date                => p_effective_date                ,
--   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_visa_type
  (p_analyzed_data_id              => p_rec.analyzed_data_id        ,
   p_visa_type                     => p_rec.visa_type                 ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
  IF (p_rec.visa_type = 'J-1' OR
      p_rec.visa_type = 'J-2' ) THEN
  chk_j_sub_type
  (p_analyzed_data_id              => p_rec.analyzed_data_id        ,
   p_j_sub_type                    => p_rec.j_sub_type                ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 END IF;
 --
  chk_primary_activity
  (p_analyzed_data_id              => p_rec.analyzed_data_id        ,
   p_primary_activity              => p_rec.primary_activity          ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
--  chk_non_us_country_code
--  (p_analyzed_data_id              => p_rec.analyzed_data_id        ,
--   p_non_us_country_code           => p_rec.non_us_country_code       ,
--   p_effective_date                => p_effective_date                ,
--   p_object_version_number         => p_rec.object_version_number     ) ;
 --
--  chk_citizenship_country_code
--  (p_analyzed_data_id              => p_rec.analyzed_data_id        ,
--   p_citizenship_country_code      => p_rec.citizenship_country_code ,
--   p_effective_date                => p_effective_date               ,
--   p_object_version_number         => p_rec.object_version_number        )  ;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqp_aad_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_analyzed_data_id
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_withldg_allow_elig_flag
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_withldg_allow_eligible_flag         => p_rec.withldg_allow_eligible_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_current_residency_status
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_current_residency_status      => p_rec.current_residency_status,
   p_effective_date                => p_effective_date              ,
   p_object_version_number         => p_rec.object_version_number   );
  --
  chk_tax_residence_country_code
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_tax_residence_country_code    => p_rec.tax_residence_country_code,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
--  chk_record_source
--  (p_analyzed_data_id          => p_rec.analyzed_data_id,
--   p_record_source                 => p_rec.record_source             ,
--   p_effective_date                => p_effective_date                ,
--   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_visa_type
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_visa_type                     => p_rec.visa_type                 ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_j_sub_type
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_j_sub_type                    => p_rec.j_sub_type                ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
  chk_primary_activity
  (p_analyzed_data_id          => p_rec.analyzed_data_id,
   p_primary_activity              => p_rec.primary_activity          ,
   p_effective_date                => p_effective_date                ,
   p_object_version_number         => p_rec.object_version_number     );
 --
--  chk_non_us_country_code
--  (p_analyzed_data_id          => p_rec.analyzed_data_id,
--   p_non_us_country_code           => p_rec.non_us_country_code       ,
--   p_effective_date                => p_effective_date                ,
--   p_object_version_number         => p_rec.object_version_number     ) ;
 --
--  chk_citizenship_country_code
--  (p_analyzed_data_id          => p_rec.analyzed_data_id,
--   p_citizenship_country_code      => p_rec.citizenship_country_code ,
--   p_effective_date                => p_effective_date               ,
--   p_object_version_number         => p_rec.object_version_number    )  ;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqp_aad_shd.g_rec_type
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
end pqp_aad_bus;

/
