--------------------------------------------------------
--  DDL for Package Body OTA_TPS_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPS_BUS1" AS
/* $Header: ottpsrhi.pkb 120.2 2005/12/14 15:17:58 asud noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tps_bus1.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_unique>-----------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_unique
  (p_training_plan_id          IN     ota_training_plans.training_plan_id%TYPE
  ,p_object_version_number     IN     ota_training_plans.object_version_number%TYPE
  ,p_organization_id           IN     ota_training_plans.organization_id%TYPE
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_time_period_id            IN     ota_training_plans.time_period_id%TYPE
  ) IS
--
  l_proc  varchar2(72) :=      g_package|| 'chk_unique';
  l_exists varchar2(1);
  l_api_updating   boolean;
--
 CURSOR csr_unique IS
        SELECT NULL
        FROM OTA_TRAINING_PLANS
        WHERE training_plan_id   <> NVL(p_training_plan_id, -1)
        AND (   (p_organization_id IS NOT NULL AND organization_id = p_organization_id )
             OR (p_person_id IS NOT NULL AND person_id = p_person_id) )
        AND   time_period_id         = p_time_period_id;
--
BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 45);

IF hr_multi_message.no_exclusive_error
        (p_check_column1   => 'OTA_TRAINING_PLANS.TIME_PERIOD_ID'
        ,p_check_column2   => 'OTA_TRAINING_PLANS.PERSON_ID'
        ,p_check_column3   => 'OTA_TRAINING_PLANS.ORGANIZATION_ID'
        ,p_associated_column1   => 'OTA_TRAINING_PLANS.TIME_PERIOD_ID'
        ,p_associated_column2   => 'OTA_TRAINING_PLANS.PERSON_ID'
        ,p_associated_column3   => 'OTA_TRAINING_PLANS.ORGANIZATION_ID'
        ) THEN

  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_time_period_id'
    ,p_argument_value =>  p_time_period_id
    );
  --
  -- if time period is changing or is an insert,
  -- check the combination is unique
  --
  l_api_updating := ota_tps_shd.api_updating
    (p_training_plan_id        => p_training_plan_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If the time_period is changing
  -- or this is an insert
  --
  IF  (l_api_updating AND
        NVL(ota_tps_shd.g_old_rec.time_period_id, hr_api.g_number) <>
        NVL(p_time_period_id, hr_api.g_number) )
      OR (NOT l_api_updating)
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN  csr_unique;
    FETCH csr_unique INTO l_exists;
    IF csr_unique%FOUND THEN
      CLOSE csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13867_TPS_DUPLICATE_TP');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 70);
    END IF;
  END IF;
--
END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 90);

 --MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_same_associated_columns    => 'Y') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 92);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 95);

END chk_unique;

-- ----------------------------------------------------------------------------
-- |----------------------<chk_org_person>------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_org_person
  (p_organization_id           IN     ota_training_plans.organization_id%TYPE
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_contact_id              IN      ota_training_plans.contact_id%TYPE
  )  IS
--
  l_proc  varchar2(72) :=      g_package|| 'chk_org_person';
--
BEGIN
--
-- check mandatory parameters have been set
--
   hr_utility.set_location(' Entering:'||l_proc, 10);
   /*
  IF ( (p_organization_id IS NOT NULL AND p_person_id IS NOT NULL )
   OR (p_organization_id IS NULL AND p_person_id IS NULL) ) THEN
   */
   IF (  (p_organization_id IS NOT NULL AND (p_person_id IS NOT NULL OR p_contact_id IS NOT NULL))
   OR (p_organization_id IS NULL AND p_person_id IS NULL AND p_contact_id IS NULL)
   OR (p_organization_id IS NULL AND p_person_id IS NOT NULL AND p_contact_id IS NOT NULL)) THEN
    fnd_message.set_name('OTA', 'OTA_13858_TPS_ORG_OR_PERSON');
    fnd_message.raise_error;
  END IF;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 20);

--MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.ORGANIZATION_ID'
                    ,p_associated_column2    => 'OTA_TRAINING_PLANS.PERSON_ID'
		    ,p_associated_column3    =>  'OTA_TRAINING_PLANS.CONTACT_ID') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 22);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 25);

END chk_org_person;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_organization_id>-------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_organization_id
  (p_organization_id           IN     ota_training_plans.organization_id%TYPE
  ,p_business_group_id         IN     ota_training_plans.business_group_id%TYPE
  )  IS
--
  l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package|| 'chk_organization_id';
  l_business_group_id          ota_training_plans.business_group_id%TYPE;
--
 CURSOR csr_organization_id IS
        SELECT business_group_id
        FROM HR_ALL_ORGANIZATION_UNITS
        WHERE organization_id = p_organization_id;
BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  IF p_organization_id IS NOT NULL THEN
    OPEN  csr_organization_id;
    FETCH csr_organization_id INTO l_business_group_id;
    IF csr_organization_id%NOTFOUND THEN
      CLOSE csr_organization_id;
      hr_utility.set_location(' Step:'|| l_proc, 40);
      fnd_message.set_name('OTA', 'OTA_13859_TPS_BAD_ORG');
      fnd_message.raise_error;
    ELSIF l_business_group_id <> p_business_group_id THEN
      CLOSE csr_organization_id;
      fnd_message.set_name('OTA', 'OTA_13860_TPS_WRONG_ORG');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_organization_id;
    END IF;
  END IF;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 50);

--MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.ORGANIZATION_ID') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 52);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 55);


END chk_organization_id;

-- ----------------------------------------------------------------------------
-- |----------------------<chk_person_id>-------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_person_id
  (p_effective_date            IN     date
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_business_group_id         IN     ota_training_plans.business_group_id%TYPE
  )  IS
--
  l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package|| 'chk_person_id';
  l_business_group_id          ota_training_plans.business_group_id%TYPE;
--
 CURSOR csr_person_id IS
        SELECT business_group_id
        FROM PER_ALL_PEOPLE_F
        WHERE person_id = p_person_id;
BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  IF p_person_id IS NOT NULL THEN
    OPEN  csr_person_id;
    FETCH csr_person_id INTO l_business_group_id;
    IF csr_person_id%NOTFOUND THEN
      CLOSE csr_person_id;
      hr_utility.set_location(' Step:'|| l_proc, 40);
      fnd_message.set_name('OTA', 'OTA_13884_NHS_PERSON_INVALID');
      fnd_message.raise_error;
      /*
      selected person can be from a business group other than
      the one set up in the profiles.
    ELSIF l_business_group_id <> p_business_group_id THEN
      CLOSE csr_person_id;
      fnd_message.set_name('OTA', 'OTA_13862_TPS_WRONG_PERSON');
      fnd_message.raise_error;
      */
    ELSE
      CLOSE csr_person_id;
    END IF;
  END IF;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 50);

 --MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.PERSON_ID') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 52);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 55);

END chk_person_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_time_period_id>---------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_time_period_id
  (p_training_plan_id          IN     ota_training_plans.training_plan_id%TYPE
  ,p_object_version_number     IN     ota_training_plans.object_version_number%TYPE
  ,p_time_period_id            IN     ota_training_plans.time_period_id%TYPE
  ,p_business_group_id         IN     ota_training_plans.business_group_id%TYPE
  )  IS
--
  l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package|| 'chk_time_period_id';
  l_api_updating               boolean;
--
  CURSOR csr_time_period_id IS
        SELECT NULL
        FROM PER_TIME_PERIODS
        WHERE time_period_id = p_time_period_id;
  --
  CURSOR csr_members IS
        SELECT NULL
        FROM   OTA_TRAINING_PLAN_MEMBERS
        WHERE  training_plan_id = p_training_plan_id;
--
BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  l_api_updating := ota_tps_shd.api_updating
    (p_training_plan_id        => p_training_plan_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If the time_period is changing
  -- or this is an insert
  --
  IF  (l_api_updating AND
        (NVL(ota_tps_shd.g_old_rec.time_period_id, hr_api.g_number) <>
         NVL(p_time_period_id, hr_api.g_number) )
      OR (NOT l_api_updating))
  THEN
  --
  --  The time period_id must exist in per_time_periods
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  OPEN  csr_time_period_id;
    FETCH csr_time_period_id INTO l_exists;
    IF csr_time_period_id%NOTFOUND THEN
      CLOSE csr_time_period_id;
      fnd_message.set_name('OTA', 'OTA_13865_TPS_BAD_TIME_PERIOD');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_time_period_id;
    END IF;
  END IF;
  --
  -- If it is a changing update, no members are allowed
  -- in OTA_TRAINING_PLAN_MEMBERS
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  IF  l_api_updating AND
        NVL(ota_tps_shd.g_old_rec.time_period_id, hr_api.g_number) <>
         NVL(p_time_period_id, hr_api.g_number)  THEN
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN  csr_members;
    FETCH csr_members INTO l_exists;
    IF csr_members%FOUND THEN
      CLOSE csr_members;
      fnd_message.set_name('OTA', 'OTA_13866_TPS_NO_CHANGE_TIME');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_members;
    END IF;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 60);

--MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.TIME_PERIOD_ID') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 62);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 65);


END chk_time_period_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_plan_status_type_id>---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_plan_status_type_id
  (p_effective_date            IN     date
  ,p_plan_status_type_id       IN     ota_training_plans.plan_status_type_id%TYPE
  ) IS
--
  l_proc  varchar2(72) :=      g_package|| 'chk_plan_status_type_id';
--
BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_plan_status_type_id'
    ,p_argument_value =>   p_plan_status_type_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  IF hr_api.not_exists_in_hr_lookups
    (p_effective_date   =>   p_effective_date
    ,p_lookup_type      =>   'OTA_PLAN_USER_STATUS_TYPE'
    ,p_lookup_code      =>   p_plan_status_type_id
    ) THEN
    -- Error, lookup not available
    If (OTA_TRNG_PLAN_UTIL_SS.is_personal_trng_plan()) THEN
        fnd_message.set_name('OTA', 'OTA_13864_TPS_BAD_PLAN_STATUS');
    Else
        fnd_message.set_name('OTA', 'OTA_13864_TPS_BAD_PLAN_STATUS');
    END IF;
    fnd_message.raise_error;
  END IF;
  --
--
  hr_utility.set_location(' Leaving:'||l_proc, 30);

--MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.PLAN_STATUS_TYPE_ID') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 32);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 35);

END chk_plan_status_type_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_period_overlap>---------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_period_overlap
  (p_training_plan_id          IN     ota_training_plans.training_plan_id%TYPE
  ,p_object_version_number     IN     ota_training_plans.object_version_number%TYPE
  ,p_plan_status_type_id       IN     ota_training_plans.plan_status_type_id%TYPE
  ,p_time_period_id            IN     ota_training_plans.time_period_id%TYPE
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_organization_id           IN     ota_training_plans.organization_id%TYPE
  ) IS
--
  l_exists             varchar2(1);
  l_proc  varchar2(72) :=      g_package|| 'chk_period_overlap';
  l_start_date         date;
  l_end_date           date;
  l_api_updating       boolean;
--
--
  CURSOR csr_get_dates IS
        SELECT start_date, end_date
        FROM PER_TIME_PERIODS
        WHERE time_period_id = p_time_period_id;
  --
  CURSOR csr_plan_overlap IS
        SELECT NULL
        FROM   PER_TIME_PERIODS ptp
              ,OTA_TRAINING_PLANS tps
        WHERE ( (p_person_id IS NOT NULL AND tps.person_id = p_person_id )
             OR (p_organization_id IS NOT NULL AND tps.organization_id = p_organization_id) )
        AND (NVL(p_training_plan_id, -1) <> training_plan_id)
        AND   tps.plan_status_type_id <> 'CANCELLED'
        AND tps.time_period_id = ptp.time_period_id
        AND (   (l_start_date >= ptp.start_date
                 AND
                 l_start_date <= ptp.end_date)
              OR
                (l_end_date >= ptp.start_date
                 AND
                 l_end_date <= ptp.end_date)
              OR
                (l_start_date <= ptp.start_date
                 AND
                 l_end_date >= ptp.end_date)
             );
--
BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);


   --MULTI MESSAGE SUPPORT

  IF hr_multi_message.no_exclusive_error
        (p_check_column1   => 'OTA_TRAINING_PLANS.TIME_PERIOD_ID'
        ,p_check_column2   => 'OTA_TRAINING_PLANS.PERSON_ID'
        ,p_check_column3   => 'OTA_TRAINING_PLANS.ORGANIZATION_ID'
        ,p_check_column4   => 'OTA_TRAINING_PLANS.PLAN_STATUS_TYPE_ID'
        ,p_associated_column1   => 'OTA_TRAINING_PLANS.TIME_PERIOD_ID'
        ,p_associated_column2   => 'OTA_TRAINING_PLANS.PERSON_ID'
        ,p_associated_column3   => 'OTA_TRAINING_PLANS.ORGANIZATION_ID'
        ,p_associated_column4   => 'OTA_TRAINING_PLANS.PLAN_STATUS_TYPE_ID'
        ) THEN

  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_plan_status_type_id'
    ,p_argument_value =>  p_plan_status_type_id
    );
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'p_time_period_id'
    ,p_argument_value =>   p_time_period_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  --
  l_api_updating := ota_tps_shd.api_updating
    (p_training_plan_id        => p_training_plan_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If the status is changing away from cancelled
  -- or the time period is changing
  -- or this is an insert and its not cancelled
  --
  IF  (l_api_updating AND
        (NVL(ota_tps_shd.g_old_rec.time_period_id, hr_api.g_number) <>
         NVL(p_time_period_id, hr_api.g_number)
             AND p_plan_status_type_id <> 'CANCELLED' )
        OR (NVL(ota_tps_shd.g_old_rec.plan_status_type_id, hr_api.g_varchar2) <>
            NVL(p_plan_status_type_id, hr_api.g_varchar2)
            AND
           (p_plan_status_type_id <> 'CANCELLED') )
      OR (NOT l_api_updating AND p_plan_status_type_id <> 'CANCELLED'))
  THEN
  --
  -- Fetch the plan dates
  --
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN csr_get_dates;
    FETCH csr_get_dates INTO l_start_date, l_end_date;
    CLOSE csr_get_dates;
    --
    -- Look for duplicates
    --
    hr_utility.set_location(' Step:'|| l_proc, 60);
    OPEN  csr_plan_overlap;
    FETCH csr_plan_overlap INTO l_exists;
    IF csr_plan_overlap%FOUND THEN
      CLOSE csr_plan_overlap;
      hr_utility.set_location(' Step:'|| l_proc, 70);
      fnd_message.set_name('OTA', 'OTA_13863_TPS_OVERLAP_PLANS');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_plan_overlap;
    END IF;
  END IF;
  --
END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 80);

EXCEPTION

        WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_same_associated_columns  => 'Y') THEN

               hr_utility.set_location(' Leaving:'||l_proc, 82);
               RAISE;
            END IF;

    hr_utility.set_location(' Leaving:'||l_proc, 85);


END chk_period_overlap;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_currency_code>---------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_currency_code
  ( p_budget_currency        IN ota_training_plans.budget_currency%TYPE
   ,p_training_plan_id       IN ota_training_plans.training_plan_id%TYPE
   ,p_business_group_id      IN ota_training_plans.business_group_id%TYPE
   ,p_object_version_number  IN ota_training_plans.object_version_number%TYPE
  )IS
--
  l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package|| 'chk_currency_value';
  l_api_updating  boolean;
--
 CURSOR csr_currency_code IS
        SELECT NULL
        FROM FND_CURRENCIES
        WHERE currency_code = p_budget_currency;
--
BEGIN
--
-- check mandatory parameters have been set. Currency code can
-- be null, so it is not mandatory.
--
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_budget_currency'
    ,p_argument_value =>  p_budget_currency
    );
  --
  l_api_updating := ota_tps_shd.api_updating
    (p_training_plan_id        => p_training_plan_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  IF ((l_api_updating AND
       NVL(ota_tps_shd.g_old_rec.budget_currency, hr_api.g_varchar2) <>
       NVL(p_budget_currency, hr_api.g_varchar2) )
      OR (NOT l_api_updating))
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 50);
    IF p_budget_currency IS NOT NULL THEN
      OPEN  csr_currency_code;
      FETCH csr_currency_code INTO l_exists;
      IF csr_currency_code%NOTFOUND THEN
        CLOSE csr_currency_code;
        fnd_message.set_name('AOL', 'MC_INVALID_CURRENCY');
        fnd_message.set_token('CODE', p_budget_currency);
        fnd_message.raise_error;
      ELSE
        CLOSE csr_currency_code;
      END IF;
    END IF;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);

--MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.BUDGET_CURRENCY') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 92);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 95);

END chk_currency_code;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_name>-------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_name
  (p_name                      IN     ota_training_plans.name%TYPE
  ,p_training_plan_id          IN     ota_training_plans.training_plan_id%TYPE
  ,p_person_id                 IN     ota_training_plans.person_id%TYPE
  ,p_contact_id                IN      ota_training_plans.contact_id%TYPE
  ,p_business_group_id         IN     ota_training_plans.business_group_id%TYPE
  ,p_object_version_number     IN     ota_training_plans.object_version_number%TYPE ) IS
--
  l_proc  varchar2(72) :=      g_package||'chk_name';
  l_api_updating  boolean;
  l_exists        varchar2(1);
--
 CURSOR csr_name IS
        SELECT NULL
        FROM OTA_TRAINING_PLANS
        WHERE NVL(p_training_plan_id, -1) <> training_plan_id
        AND   name = p_name
        AND   business_group_id = p_business_group_id;
--
--Bug#3484692
 CURSOR csr_plp_name IS
        SELECT NULL
        FROM OTA_TRAINING_PLANS
        WHERE NVL(p_training_plan_id, -1) <> training_plan_id
        AND   name = p_name
	-- Modified for bug#3855813
          AND   ((p_person_id IS NOT NULL AND person_id = p_person_id)
            OR (p_contact_id IS NOT NULL AND contact_id = p_contact_id))
        AND   business_group_id = p_business_group_id;
--
--
BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_name'
    ,p_argument_value =>  p_name
    );
  --
  --
     l_api_updating := ota_tps_shd.api_updating
       (p_training_plan_id        => p_training_plan_id
       ,p_object_version_number   => p_object_version_number
       );
  --
  --
  -- If this is a changing update, or a new insert, test
  --
  IF ((l_api_updating AND
       NVL(ota_tps_shd.g_old_rec.name, hr_api.g_varchar2) <>
       NVL(p_name, hr_api.g_varchar2) )
      OR (NOT l_api_updating))
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 50);
    IF p_name IS NOT NULL THEN
      --Bug#3484692
      --check if lp is org or non-org
      IF (OTA_TRNG_PLAN_UTIL_SS.is_personal_trng_plan()) THEN
         OPEN  csr_plp_name;
         FETCH csr_plp_name INTO l_exists;
         IF csr_plp_name%FOUND THEN
            CLOSE csr_plp_name;
            fnd_message.set_name('OTA', 'OTA_443572_PLP_UNIQUE_NAME');
            fnd_message.raise_error;
         ELSE
            CLOSE csr_plp_name;
         END IF;
      ELSE
         OPEN  csr_name;
         FETCH csr_name INTO l_exists;
         IF csr_name%FOUND THEN
            CLOSE csr_name;
            fnd_message.set_name('OTA', 'OTA_13897_TPS_UNIQUE_NAME');
            fnd_message.raise_error;
         ELSE
            CLOSE csr_name;
         END IF;
      END IF;
    END IF;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 10);

  --MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.NAME') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 12);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 15);
--
END chk_name;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_del_training_plan_id>---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_del_training_plan_id
  (p_training_plan_id     IN     ota_training_plans.training_plan_id%TYPE
  ) IS
--
  l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package||'chk_del_training_plan_id';

 CURSOR csr_del_training_plan_id IS
        SELECT NULL
        FROM   OTA_TRAINING_PLAN_MEMBERS tpm
        WHERE  tpm.training_plan_id = p_training_plan_id
        UNION
        SELECT NULL
        FROM   OTA_TRAINING_PLAN_COSTS tpc
        WHERE  tpc.training_plan_id = p_training_plan_id
        UNION
        SELECT NULL
        FROM  PER_BUDGET_ELEMENTS pbe
        WHERE pbe.training_plan_id    = p_training_plan_id;

BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );
  --
  -- Check that the code can be deleted
  --
  OPEN  csr_del_training_plan_id;
  FETCH csr_del_training_plan_id INTO l_exists;
  IF csr_del_training_plan_id%FOUND THEN
    CLOSE csr_del_training_plan_id;
    hr_utility.set_location(' Step:'|| l_proc, 10);
    fnd_message.set_name('OTA', 'OTA_13868_TPS_CHILD_RECORDS');
    fnd_message.raise_error;
  END IF;
  CLOSE csr_del_training_plan_id;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
END chk_del_training_plan_id;
--

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_plan_source  >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_plan_source
  (p_training_plan_id 				IN number
   ,p_plan_source	 			IN varchar2
   ,p_effective_date			IN date) IS

--
  l_proc  varchar2(72) := g_package||'chk_plan_source';
  l_api_updating boolean;

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
     ,p_argument		=> 'effective_date'
     ,p_argument_value  => p_effective_date);

IF (((p_training_plan_id IS NOT NULL) AND
        NVL(ota_tps_shd.g_old_rec.plan_source,hr_api.g_varchar2) <>
        NVL(p_plan_source,hr_api.g_varchar2))
     OR
       (p_training_plan_id IS  NULL)) THEN

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --

       --
       IF p_plan_source IS NOT NULL THEN
          IF hr_api.not_exists_in_hr_lookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_TRAINING_PLAN_SOURCE'
              ,p_lookup_code => p_plan_source) THEN
              fnd_message.set_name('OTA','OTA_13176_TPM_PLN_SRC_INVLD');
               fnd_message.raise_error;
          END IF;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       END IF;

   END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

     --MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.PLAN_SOURCE') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 42);
                   RAISE;

               END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 45);


END chk_plan_source;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_tp_date_range  >----------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE chk_tp_date_range (p_training_plan_id         IN ota_training_plans.training_plan_id%TYPE
                             ,p_start_date              IN ota_training_plans.start_date%TYPE
                             ,p_end_date                IN ota_training_plans.end_date%TYPE DEFAULT NULL
                             ,p_object_version_number   IN ota_training_plans.object_version_number%TYPE)
IS

l_proc  VARCHAR2(72) :=      g_package|| 'chk_tp_date_range';

  CURSOR csr_get_tpm IS
  SELECT training_plan_member_id
    FROM ota_training_plan_members
   WHERE training_plan_id = p_training_plan_id
     AND ( earliest_start_date < p_start_date
      OR ( p_end_date IS NOT NULL AND target_completion_date > p_end_date) )
     and member_status_type_id <>'CANCELLED'
     AND ROWNUM = 1;

  CURSOR csr_max_tpm_tcd IS
  SELECT max(target_completion_date)
    FROM ota_training_plan_members
   WHERE training_plan_id = p_training_plan_id
     and member_status_type_id <>'CANCELLED';

  l_exists          NUMBER(9);
  l_api_updating    BOOLEAN;
  l_flag            VARCHAR2(30);
  l_end_date        date;
  l_target_completion_date date := '';

BEGIN

    -- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 10);

  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_start_date'
    ,p_argument_value =>  p_start_date
    );

     l_api_updating := ota_tps_shd.api_updating
       (p_training_plan_id        => p_training_plan_id
       ,p_object_version_number   => p_object_version_number
       );
  --
  --
  -- If this is a changing update, or a new insert, test
  --
  IF ((l_api_updating AND
       NVL( ota_tps_shd.g_old_rec.start_date, hr_api.g_date ) <>
       NVL( p_start_date, hr_api.g_date )
       OR NVL( ota_tps_shd.g_old_rec.end_date, hr_api.g_date ) <>
       NVL( p_end_date, hr_api.g_date) )
      OR ( NOT l_api_updating) )
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 20);

 /* IF ( NOT l_api_updating
  or NVL( ota_tps_shd.g_old_rec.start_date, hr_api.g_date ) <>
       NVL( p_start_date, hr_api.g_date )) THEN

        IF ( p_start_date < TRUNC(SYSDATE) ) THEN
            l_flag :='START_DATE';
            fnd_message.set_name('OTA', 'OTA_13999_TPS_STRT_DATE');
            fnd_message.raise_error;
        END IF;

  END IF;*/
          if p_end_date is not null then
            l_end_date:=p_end_date;
          else
            l_end_date :='';
          end if;
    /*
    IF ( p_end_date is null or p_end_date >= p_start_date ) THEN
      OPEN  csr_get_tpm;
      FETCH csr_get_tpm INTO l_exists;
      IF csr_get_tpm%FOUND THEN
        CLOSE csr_get_tpm;

        OPEN csr_max_tpm_tcd;
        FETCH csr_max_tpm_tcd into l_target_completion_date;
        CLOSE csr_max_tpm_tcd;
        fnd_message.set_name('OTA', 'OTA_443687_TPS_MAX_TPM_DATE');
        fnd_message.set_token('MAX_TPC_TARGET_DATE',l_target_completion_date);
        fnd_message.raise_error;
      ELSE
        CLOSE csr_get_TPM;
      END IF;
    -- Bug 3529382 ELSIF ( p_start_date > p_end_date ) THEN
   ELSE
        l_flag :='END_DATE';
        fnd_message.set_name('OTA', 'OTA_13992_TPS_DATES');
        -- Bug 3484721
        fnd_message.set_token('TP_STARTDATE',p_start_date);
        fnd_message.raise_error;

    END IF;
   */

      OPEN  csr_get_tpm;
      FETCH csr_get_tpm INTO l_exists;

      --Throw error if the completion target is less than any components TCD,
      --or if its less than the path start date.
      IF csr_get_tpm%FOUND THEN
        CLOSE csr_get_tpm;

        OPEN csr_max_tpm_tcd;
        FETCH csr_max_tpm_tcd into l_target_completion_date;
        CLOSE csr_max_tpm_tcd;
        l_flag :='END_DATE';
        fnd_message.set_name('OTA', 'OTA_443687_TPS_MAX_TPM_DATE');
        fnd_message.set_token('MAX_TPC_TARGET_DATE',l_target_completion_date);
        fnd_message.raise_error;
      --When there are no components created yet
      ELSIF (p_end_date < p_start_date) THEN
        CLOSE csr_get_TPM;
        l_flag :='END_DATE';
        fnd_message.set_name('OTA', 'OTA_13992_TPS_DATES');
        fnd_message.set_token('TP_STARTDATE',p_start_date);
        fnd_message.raise_error;
      ELSE
        CLOSE csr_get_TPM;
      END IF;


  END IF;

    hr_utility.set_location(' Step:'|| l_proc, 30);


   --MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

            IF l_flag = 'END_DATE' THEN

       /*        IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.START_DATE') THEN
                   hr_utility.set_location(' Leaving:'||l_proc, 32);
                   RAISE;

               END IF;
            ELSIF l_flag = 'END_DATE' THEN */

                IF hr_multi_message.exception_add(
                    p_associated_column1   => 'OTA_TRAINING_PLANS.END_DATE') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 34);
                   RAISE;

               END IF;

            ELSE

                IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLANS.START_DATE'
                    ,p_associated_column2   => 'OTA_TRAINING_PLANS.END_DATE') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 36);
                   RAISE;

               END IF;

            END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 38);

END chk_tp_date_range;

END ota_tps_bus1;

/
