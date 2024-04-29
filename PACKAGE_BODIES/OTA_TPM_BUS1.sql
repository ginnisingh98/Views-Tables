--------------------------------------------------------
--  DDL for Package Body OTA_TPM_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPM_BUS1" AS
/* $Header: ottpmrhi.pkb 120.1 2005/12/14 15:33:09 asud noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)	:= '  ota_tpm_bus1.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_training_plan_id>-------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_training_plan_id
  (p_training_plan_id          IN     ota_training_plan_members.training_plan_id%TYPE
  ,p_business_group_id         IN     ota_training_plan_members.business_group_id%TYPE
  )  IS
--
  l_exists VARCHAR2(1);
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_training_plan_id';
--
 CURSOR csr_training_plan_id IS
        SELECT NULL
        FROM OTA_TRAINING_PLANS
        WHERE training_plan_id    = p_training_plan_id
        AND   business_group_id   = p_business_group_id;
BEGIN
--
-- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  OPEN  csr_training_plan_id;
  FETCH csr_training_plan_id INTO l_exists;
  IF csr_training_plan_id%NOTFOUND THEN
    CLOSE csr_training_plan_id;
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13828_TPC_NO_TRAINING_PLAN');
    fnd_message.raise_error;
  ELSE
    hr_utility.set_location(' Step:'|| l_proc, 80);
    CLOSE csr_training_plan_id;
  END IF;
--
  hr_utility.set_location(' Leaving:'||l_proc, 90);

EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 92);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_training_plan_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_activity_definition_id>------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_activity_definition_id (
   p_training_plan_member_id   IN     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number     IN     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_definition_id    IN     ota_training_plan_members.activity_definition_id%TYPE
  ,p_business_group_id         IN     ota_training_plan_members.business_group_id%TYPE
  )  IS
--
  l_proc                VARCHAR2(72) :=      g_package|| 'activity_definition_id';
  l_api_updating        boolean;
  l_business_group_id   ota_training_plan_members.business_group_id%TYPE;
--
  CURSOR csr_activity_definition_id IS
        SELECT oad.business_group_id
        FROM OTA_ACTIVITY_DEFINITIONS  oad
        WHERE oad.activity_id = p_activity_definition_id;
--
BEGIN
--
-- check mandatory parameters have been set.
--
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  l_api_updating := ota_tpm_shd.api_updating
    (p_training_plan_member_id   => p_training_plan_member_id
    ,p_object_version_number     => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  IF p_activity_definition_id IS NOT NULL THEN
    IF ((l_api_updating AND
         NVL(ota_tpm_shd.g_old_rec.activity_definition_id, hr_api.g_number) <>
         NVL(p_activity_definition_id, hr_api.g_number) )
      OR (NOT l_api_updating) )
    THEN
      -- Check that the definition exists
      --
      hr_utility.set_location(' Step:'|| l_proc, 20);
      OPEN csr_activity_definition_id;
      FETCH csr_activity_definition_id INTO l_business_group_id;
      IF csr_activity_definition_id%NOTFOUND THEN
        CLOSE csr_activity_definition_id;
        fnd_message.set_name('OTA', 'OTA_13848_TPM_BAD_ACT_DEF');
        fnd_message.raise_error;
      ELSE
        IF l_business_group_id <> p_business_group_id THEN
          CLOSE csr_activity_definition_id;
          fnd_message.set_name('OTA', 'OTA_13849_TPM_WRONG_ACT_DEF');
          fnd_message.raise_error;
        ELSE
          hr_utility.set_location(' Step:'|| l_proc, 30);
          CLOSE csr_activity_definition_id;
        END IF;
      END IF;
    END IF;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);

EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_DEFINITION_ID') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_activity_definition_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_version_definition>----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_version_definition (
   p_training_plan_member_id   IN     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number     IN     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_version_id       IN     ota_training_plan_members.activity_version_id%TYPE
  ,p_activity_definition_id    IN     ota_training_plan_members.activity_definition_id%TYPE
  ,p_business_group_id         IN     ota_training_plan_members.business_group_id%TYPE
  ,p_training_plan_id          IN     ota_training_plan_members.training_plan_id%TYPE
  )  IS
--
  l_api_updating               boolean;
  l_exists VARCHAR2(1);
  l_proc   VARCHAR2(72) :=      g_package|| 'chk_version_definition';
--
 CURSOR csr_version_definition IS
        SELECT NULL
        FROM PER_BUDGET_ELEMENTS
        WHERE training_plan_member_id = p_training_plan_member_id
        AND   training_plan_id        = p_training_plan_id;
BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
--
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );
  --
  -- One and only one must be null;
  --
  IF (p_activity_definition_id IS NOT NULL AND p_activity_version_id IS NOT NULL)
  OR (p_activity_definition_id IS NULL AND p_activity_version_id IS NULL)
  THEN
     fnd_message.set_name('OTA', 'OTA_13877_TPM_ONE_MEMBER');
     fnd_message.raise_error;
  END IF;
  --
  --
  l_api_updating := ota_tpm_shd.api_updating
    (p_training_plan_member_id   => p_training_plan_member_id
    ,p_object_version_number     => p_object_version_number
    );
  --
  -- If this is a changing update, no budget records are allowed
  --
  IF  (l_api_updating AND
       (NVL(ota_tpm_shd.g_old_rec.activity_version_id, hr_api.g_number) <>
       NVL(p_activity_version_id, hr_api.g_number)
     OR NVL(ota_tpm_shd.g_old_rec.activity_definition_id, hr_api.g_number) <>
       NVL(p_activity_definition_id, hr_api.g_number) )) THEN
  --
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN  csr_version_definition;
    FETCH csr_version_definition INTO l_exists;
    IF csr_version_definition%FOUND THEN
      CLOSE csr_version_definition;
      hr_utility.set_location(' Step:'|| l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13845_TPM_HAS_BUDGET_RECS');
      fnd_message.raise_error;
    ELSE
      hr_utility.set_location(' Step:'|| l_proc, 70);
      CLOSE csr_version_definition;
    END IF;
  END IF;
--
  hr_utility.set_location(' Leaving:'||l_proc, 100);

EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_VERSION_ID'
                ,p_associated_column2   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_DEFINITION_ID') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 102);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 104);

END chk_version_definition;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_activity_version_id>---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_activity_version_id (
   p_training_plan_member_id   IN     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number     IN     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_version_id       IN     ota_training_plan_members.activity_version_id%TYPE
  ,p_business_group_id         IN     ota_training_plan_members.business_group_id%TYPE
  ,p_training_plan_id          IN     ota_training_plan_members.training_plan_id%TYPE
  ) IS
--
--
  l_proc               VARCHAR2(72) :=      g_package|| 'activity_definition_id';
  l_api_updating       BOOLEAN;
  l_business_group_id  ota_training_plan_members.business_group_id%TYPE;
  l_plan_start_date    ota_training_plans.start_date%TYPE;
  l_plan_end_date      ota_training_plans.end_date%TYPE;
  l_version_start_date DATE;
  l_version_end_date   DATE;
  l_exists             VARCHAR2(1);

--
 /* cursor csr_activity_version_id is
         select oav.business_group_id
         from   OTA_ACTIVITY_VERSIONS_V  oav
         where  oav.activity_version_id = p_activity_version_id;*/

  CURSOR csr_activity_version_id IS
  SELECT oad.business_group_id
    FROM ota_activity_versions  oav,
         ota_activity_definitions oad
   WHERE oav.activity_id = oad.activity_id
     AND oav.activity_version_id = p_activity_version_id;
  --
  CURSOR csr_version_date_range IS
  SELECT oav.start_date, oav.end_date
    FROM ota_activity_versions    oav
   WHERE oav.activity_version_id = p_activity_version_id;
  --
  CURSOR csr_plan_date_range IS
  SELECT otp.start_date, otp.end_date
    FROM ota_training_plans otp
   WHERE training_plan_id = p_training_plan_id;
  /*      select ptp.start_date, ptp.end_date
        from   per_time_periods ptp
              ,ota_training_plans tps
        where  tps.time_period_id   = ptp.time_period_id
        and    tps.training_plan_id = p_training_plan_id;*/
  --
--
BEGIN
--
-- check mandatory parameters have been set.
--
  hr_utility.set_location(' Step:'|| l_proc, 10);

IF hr_multi_message.no_exclusive_error
    (p_check_column1    => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID'
    ,p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID') THEN

  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  l_api_updating := ota_tpm_shd.api_updating
    (p_training_plan_member_id   => p_training_plan_member_id
    ,p_object_version_number     => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  IF p_activity_version_id IS NOT NULL THEN
    IF (l_api_updating AND
         NVL(ota_tpm_shd.g_old_rec.activity_version_id, hr_api.g_number) <>
         NVL(p_activity_version_id, hr_api.g_number) )
      OR (NOT l_api_updating)
    THEN
      -- Check that the definition exists
      --
      hr_utility.set_location(' Step:'|| l_proc, 20);
      OPEN csr_activity_version_id;
      FETCH csr_activity_version_id INTO l_business_group_id;
      IF csr_activity_version_id%NOTFOUND THEN
        CLOSE csr_activity_version_id;
        fnd_message.set_name('OTA', 'OTA_13850_TPM_BAD_ACT_VER');
        fnd_message.raise_error;
      ELSE
        IF l_business_group_id <> p_business_group_id THEN
          CLOSE csr_activity_version_id;
          fnd_message.set_name('OTA', 'OTA_13851_TPM_WRONG_ACT_VER');
          fnd_message.raise_error;
        ELSE
          hr_utility.set_location(' Step:'|| l_proc, 30);
          CLOSE csr_activity_version_id;
        END IF;
      END IF;
      --
      -- Now test to see if the activity dates are in range
      -- Get the plan start dates
      --
      OPEN csr_plan_date_range;
      FETCH csr_plan_date_range  INTO l_plan_start_date, l_plan_end_date;
      CLOSE csr_plan_date_range;
      --
      -- Explicitly get the activity version start dates.
      --
      OPEN csr_version_date_range;
      FETCH csr_version_date_range  INTO l_version_start_date, l_version_end_date;
      CLOSE csr_version_date_range;
      --
      -- Test
      --
      IF NVL(l_version_end_date, hr_api.g_eot) < NVL(l_plan_start_date, hr_api.g_sot) THEN
           IF (OTA_TRNG_PLAN_UTIL_SS.is_personal_trng_plan(p_training_plan_id)) THEN
               fnd_message.set_name('OTA', 'OTA_443569_PLPM_VER_TOO_EARLY');
               fnd_message.set_token('TP_STARTDATE',l_plan_start_date);
	   ELSE
               fnd_message.set_name('OTA', 'OTA_13852_TPM_VER_TOO_EARLY');
           END IF;
          fnd_message.raise_error;
      ELSIF NVL(l_version_start_date, hr_api.g_sot) > NVL(l_plan_end_date, hr_api.g_eot) THEN
          fnd_message.set_name('OTA', 'OTA_13853_TPM_VER_TOO_LATE');
          fnd_message.raise_error;
      END IF;
    END IF;
  END IF;
  --

  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

        WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_same_associated_columns  => 'Y') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 42);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 44);


END chk_activity_version_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_member_status_type_id>-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_member_status_type_id
  (p_effective_date            IN     date
  ,p_member_status_type_id     IN     ota_training_plan_members.member_status_type_id%TYPE
  ,p_business_group_id         IN     ota_training_plan_members.business_group_id%TYPE
  ,p_training_plan_member_id   IN     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number     IN     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_version_id       IN     ota_training_plan_members.activity_version_id%TYPE
  ,p_activity_definition_id    IN     ota_training_plan_members.activity_definition_id%TYPE
  ,p_training_plan_id          IN     ota_training_plan_members.training_plan_id%TYPE
  ,p_target_completion_date    IN     ota_training_plan_members.target_completion_date%TYPE)
  IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_member_status_type_id';
  l_api_updating  boolean;
  l_exists VARCHAR2(1);
--
  CURSOR csr_seek_statuses IS
        SELECT NULL
        FROM OTA_ACTIVITY_DEFINITIONS  oad
            ,OTA_ACTIVITY_VERSIONS     oav
            ,OTA_TRAINING_PLAN_MEMBERS tpm
        WHERE ((oad.activity_id = p_activity_definition_id AND p_activity_definition_id IS NOT NULL)
           OR (oav.activity_version_id = p_activity_version_id AND p_activity_version_id IS NOT NULL))
        AND   oad.activity_id = oav.activity_id
        AND ( oav.activity_version_id = tpm.activity_version_id
         OR oav.activity_id = tpm.activity_definition_id )
        AND   tpm.member_status_type_id <> 'CANCELLED'
        AND   tpm.training_plan_id = p_training_plan_id
        AND (( p_training_plan_member_id IS NULL )
               OR (p_training_plan_member_id IS NOT NULL AND tpm.training_plan_member_id <> p_training_plan_member_id))
AND (
                (p_target_completion_date IS NOT NULL AND tpm.target_completion_date = p_target_completion_date)
             or p_target_completion_date is null);--
--
-- Following two cursor statements disused
--
-- cursor csr_parents is
--         select null
--         from   ota_training_plan_members
--         where  business_group_id = p_business_group_id
--         and    member_status_type_id <> 'CANCELLED'
--         and  ( nvl(training_plan_member_id, -1)  <> nvl(p_training_plan_member_id, -1) )
--         and   activity_version_id in (
--                    select activity_version_id
--                    from    ota_activity_versions
--                    connect by PRIOR activity_version_id = superseded_by_act_version_id
--                    start   with activity_version_id = p_activity_version_id);
--
--  cursor csr_children is
--         select null
--         from  ota_training_plan_members
--         where business_group_id = p_business_group_id
--         and   member_status_type_id <> 'CANCELLED'
--         and  ( nvl(training_plan_member_id, -1)  <> nvl(p_training_plan_member_id, -1) )         and   activity_version_id in (
--                select  activity_version_id
--                from    ota_activity_versions
--                connect by activity_version_id = PRIOR superseded_by_act_version_id
--                start   with activity_version_id = p_activity_version_id);
--
BEGIN
--
-- check mandatory parameters have been set.
--
  hr_utility.set_location(' Step:'|| l_proc, 30);

IF hr_multi_message.no_exclusive_error
    (p_check_column1    => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID'
    ,p_check_column2    => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_VERSION_ID'
    ,p_check_column3    => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_DEFINITION_ID'
    ,p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID'
    ,p_associated_column2   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_VERSION_ID'
    ,p_associated_column3   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_DEFINITION_ID') THEN


  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_member_status_type_id'
    ,p_argument_value =>  p_member_status_type_id
    );
 --
  hr_utility.set_location(' Step:'|| l_proc, 45);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
 --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );
 --
 l_api_updating := ota_tpm_shd.api_updating
    (p_training_plan_member_id   => p_training_plan_member_id
    ,p_object_version_number     => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test status is valid
  --
  IF (l_api_updating AND
       NVL(ota_tpm_shd.g_old_rec.member_status_type_id, hr_api.g_VARCHAR2) <>
       NVL(p_member_status_type_id, hr_api.g_VARCHAR2) )
    OR (NOT l_api_updating)
  THEN
    -- Check that the lookup code is valid
    --
    hr_utility.set_location(' Step:'|| l_proc, 55);
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date   =>   p_effective_date
      ,p_lookup_type      =>   'OTA_MEMBER_USER_STATUS_TYPE'
      ,p_lookup_code      =>   p_member_status_type_id
      ) THEN
      -- Error, lookup not available
      fnd_message.set_name('OTA', 'OTA_13843_TPM_BAD_STATUS');
      fnd_message.raise_error;
    END IF;
    --
    -- If the status is not CANCELLED, test no parents (children) are in
    -- the same plan, whose status is also not cancelled.
    --
    IF p_member_status_type_id <> 'CANCELLED' THEN
      OPEN csr_seek_statuses;
      FETCH csr_seek_statuses INTO l_exists;
      IF csr_seek_statuses%FOUND THEN
        CLOSE csr_seek_statuses;
        hr_utility.set_location(' Step:'|| l_proc, 60);
        IF p_activity_version_id IS NOT NULL THEN
           IF (OTA_TRNG_PLAN_UTIL_SS.is_personal_trng_plan(p_training_plan_id)) THEN
               fnd_message.set_name('OTA', 'OTA_443567_PLPM_OTHER_MEM_V');
           Else
               fnd_message.set_name('OTA', 'OTA_13846_TPM_OTHER_MEMBERS_V');
           END IF;
          fnd_message.raise_error;
        ELSE
           IF (OTA_TRNG_PLAN_UTIL_SS.is_personal_trng_plan(p_training_plan_id)) THEN
               fnd_message.set_name('OTA', 'OTA_443568_PLPM_OTHER_MEM_D');
           Else
               fnd_message.set_name('OTA', 'OTA_13847_TPM_OTHER_MEMBERS_D');
           END IF;
          fnd_message.set_name('OTA', 'OTA_13847_TPM_OTHER_MEMBERS_D');
          fnd_message.raise_error;
        END IF;
      ELSE
        hr_utility.set_location(' Step:'|| l_proc, 70);
        CLOSE csr_seek_statuses;
      END IF;
    END IF;
  END IF;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 80);

 EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_same_associated_columns  => 'Y') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 82);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 84);


END chk_member_status_type_id;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_unique>-----------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_unique
  (p_training_plan_member_id    IN     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number      IN     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_definition_id     IN     ota_training_plan_members.activity_definition_id%TYPE
  ,p_activity_version_id        IN     ota_training_plan_members.activity_version_id%TYPE
  ,p_training_plan_id           IN     ota_training_plan_members.training_plan_id%TYPE
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_unique';
  l_exists VARCHAR2(1);
  l_api_updating  boolean;
--
 CURSOR csr_unique IS
        SELECT NULL
        FROM OTA_TRAINING_PLAN_MEMBERS
        WHERE training_plan_id       = p_training_plan_id
        AND ( (p_activity_version_id IS NOT NULL AND
               p_activity_version_id = activity_version_id)
        OR    (p_activity_definition_id IS NOT NULL AND
               p_activity_definition_id = activity_definition_id) );
BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);

IF hr_multi_message.no_exclusive_error
    (p_check_column1    => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID'
    ,p_check_column2    => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_VERSION_ID'
    ,p_check_column3    => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_DEFINITION_ID'
    ,p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID'
    ,p_associated_column2   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_VERSION_ID'
    ,p_associated_column3   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_DEFINITION_ID') THEN


  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );

  l_api_updating := ota_tpm_shd.api_updating
    (p_training_plan_member_id   => p_training_plan_member_id
    ,p_object_version_number     => p_object_version_number);
  --
  -- Check if anything is changing, or this is an insert
  --
  IF (l_api_updating AND
       NVL(ota_tpm_shd.g_old_rec.activity_version_id, hr_api.g_number) <>
       NVL(p_activity_version_id, hr_api.g_number)
    OR NVL(ota_tpm_shd.g_old_rec.activity_definition_id, hr_api.g_number) <>
       NVL(p_activity_definition_id, hr_api.g_number))
    OR (NOT l_api_updating)  THEN
    --
    -- check the combination is unique
    --
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN  csr_unique;
    FETCH csr_unique INTO l_exists;
    IF csr_unique%FOUND THEN
      CLOSE csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13844_TPM_NOT_UNIQUE');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_unique;
      hr_utility.set_location(' Step:'|| l_proc, 70);
    END IF;
  END IF;
--
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_same_associated_columns  => 'Y') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);

END chk_unique;

-- ----------------------------------------------------------------------------
-- |----------------------<chk_unique1>-----------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_unique1
  (p_training_plan_member_id    IN     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_object_version_number      IN     ota_training_plan_members.object_version_number%TYPE
  ,p_activity_definition_id     IN     ota_training_plan_members.activity_definition_id%TYPE
  ,p_activity_version_id        IN     ota_training_plan_members.activity_version_id%TYPE
  ,p_training_plan_id           IN     ota_training_plan_members.training_plan_id%TYPE
  ,p_target_completion_date     IN     ota_training_plan_members.target_completion_date%TYPE
  ) IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_unique1';
  l_exists VARCHAR2(1);
  l_api_updating  boolean;
  l_member_status_type_id varchar2(30);
--
 CURSOR csr_unique IS
 SELECT 1,member_status_type_id
   FROM ota_training_plan_members
  WHERE training_plan_id       = p_training_plan_id
    AND ( (p_activity_version_id IS NOT NULL AND
        p_activity_version_id = activity_version_id)
     OR (p_activity_definition_id IS NOT NULL AND
        p_activity_definition_id = activity_definition_id))
    AND (p_target_completion_date IS NOT NULL AND
        p_target_completion_date = target_completion_date);
 --   AND member_status_type_id <> 'CANCELLED' ;


BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);

  IF hr_multi_message.no_exclusive_error
    (p_check_column1    => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID'
    ,p_check_column2    => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_VERSION_ID'
    ,p_check_column3    => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_DEFINITION_ID'
    ,p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID'
    ,p_associated_column2   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_VERSION_ID'
    ,p_associated_column3   => 'OTA_TRAINING_PLAN_MEMBERS.ACTIVITY_DEFINITION_ID') THEN


  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );

  l_api_updating := ota_tpm_shd.api_updating
    (p_training_plan_member_id   => p_training_plan_member_id
    ,p_object_version_number     => p_object_version_number);
  --
  -- Check if anything is changing, or this is an insert
  --
  IF (l_api_updating AND
       NVL(ota_tpm_shd.g_old_rec.activity_version_id, hr_api.g_number) <>
       NVL(p_activity_version_id, hr_api.g_number)
    OR NVL(ota_tpm_shd.g_old_rec.activity_definition_id, hr_api.g_number) <>
       NVL(p_activity_definition_id, hr_api.g_number)
    OR NVL(ota_tpm_shd.g_old_rec.target_completion_date, hr_api.g_date) <>
       NVL(p_target_completion_date, hr_api.g_date))
    OR (NOT l_api_updating)  THEN
    --
    -- check the combination is unique
    --
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN  csr_unique;
    FETCH csr_unique INTO l_exists,l_member_status_type_id;
    IF csr_unique%FOUND THEN
       CLOSE csr_unique;
             hr_utility.set_location(' Step:'|| l_proc, 60);
             if l_member_status_type_id = 'CANCELLED' then
                fnd_message.set_name('OTA', 'OTA_13189_TPM_CANCEL_EXISTS');
             else
                fnd_message.set_name('OTA', 'OTA_13182_TPM_ACT_NOT_UNIQUE');
             end if;
             fnd_message.raise_error;
    ELSE
       CLOSE csr_unique;
             hr_utility.set_location(' Step:'|| l_proc, 70);
    END IF;

  END IF;
--
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 90);

  EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_same_associated_columns  => 'Y') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);



END chk_unique1;



-- ----------------------------------------------------------------------------
-- |----------------------<chk_delete>----------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_delete (
   p_training_plan_member_id   IN     ota_training_plan_members.training_plan_member_id%TYPE
  ,p_training_plan_id          IN     ota_training_plan_members.training_plan_id%TYPE
  )  IS
--
  l_api_updating               boolean;
  l_exists VARCHAR2(1);
  l_proc   VARCHAR2(72) :=      g_package|| 'chk_delete';
--
 CURSOR csr_chk_delete IS
        SELECT NULL
        FROM PER_BUDGET_ELEMENTS
        WHERE training_plan_member_id = p_training_plan_member_id
        AND   training_plan_id        = p_training_plan_id;
BEGIN
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);

IF hr_multi_message.no_exclusive_error
    (p_check_column1    => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID'
    ,p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.TRAINING_PLAN_ID') THEN


  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_member_id'
    ,p_argument_value =>  p_training_plan_member_id
    );
  --
--
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );
  --
  --
  --
    hr_utility.set_location(' Step:'|| l_proc, 50);
    OPEN  csr_chk_delete;
    FETCH csr_chk_delete INTO l_exists;
    IF csr_chk_delete%FOUND THEN
      CLOSE csr_chk_delete;
      hr_utility.set_location(' Step:'|| l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13845_TPM_HAS_BUDGET_RECS');
      fnd_message.raise_error;
    ELSE
      hr_utility.set_location(' Step:'|| l_proc, 70);
      CLOSE csr_chk_delete;
    END IF;
  --
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 100);

 EXCEPTION

  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_same_associated_columns  => 'Y') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 102);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 104);

END chk_delete;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_source_function  >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_source_function
  (p_training_plan_member_id 		IN NUMBER
   ,p_source_function	 			IN VARCHAR2
   ,p_effective_date			    IN DATE) IS

--
  l_proc  VARCHAR2(72) := g_package||'chk_source_function';
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

IF (((p_training_plan_member_id IS NOT NULL) AND
        NVL(ota_tpm_shd.g_old_rec.source_function,hr_api.g_VARCHAR2) <>
        NVL(p_source_function,hr_api.g_VARCHAR2))
     OR
       (p_training_plan_member_id IS  NULL)) THEN

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --

       --
       IF p_source_function IS NOT NULL THEN
          IF hr_api.not_exists_in_hr_lookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_PLAN_COMPONENT_SOURCE'
              ,p_lookup_code => p_source_FUNCTION) THEN
              fnd_message.set_name('OTA','OTA_13178_TPM_SRC_FUNC_INVLD');
               fnd_message.raise_error;
          END IF;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       END IF;

   END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.SOURCE_FUNCTION') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_source_function;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_cancellation_reason  >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_cancellation_reason (p_training_plan_member_id 		IN number
                                  ,p_cancellation_reason	 		IN VARCHAR2
                                  ,p_effective_date			        IN date) IS

--
  l_proc  VARCHAR2(72) := g_package||'chk_cancellation_reason';
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

IF (((p_training_plan_member_id IS NOT NULL) AND
        NVL(ota_tpm_shd.g_old_rec.cancellation_reason,hr_api.g_VARCHAR2) <>
        NVL(p_cancellation_reason,hr_api.g_VARCHAR2))
     OR
       (p_training_plan_member_id IS  NULL)) THEN

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --

       --
       IF p_cancellation_reason IS NOT NULL THEN
          IF hr_api.not_exists_in_hr_lookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_PLAN_CANCELLATION_SOURCE'
              ,p_lookup_code => p_cancellation_reason) THEN
              fnd_message.set_name('OTA','OTA_13177_TPM_CANCL_RSN_INVLD');
               fnd_message.raise_error;
          END IF;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       END IF;

   END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.CANCELLATION_REASON') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_cancellation_reason;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_tpc_tp_actver_dates  >----------------------------|
-- ----------------------------------------------------------------------------


PROCEDURE chk_tpc_tp_actver_dates (p_training_plan_id           IN ota_training_plans.training_plan_id%TYPE
                                   ,p_training_plan_member_id    IN ota_training_plan_members.training_plan_member_id%TYPE
                                   ,p_activity_version_id       IN ota_training_plan_members.activity_version_id%TYPE
                                   ,p_earliest_start_date       IN ota_training_plan_members.earliest_start_date%TYPE
                                   ,p_target_completion_date    IN  ota_training_plan_members.target_completion_date%TYPE
                                   ,p_object_version_number     IN ota_training_plan_members.object_version_number%TYPE)
IS

l_proc  VARCHAR2(72) :=      g_package|| 'chk_tpc_tp_actver_dates';

 CURSOR csr_comp_tpc_tp_dates IS
 SELECT 1,otp.start_date,decode(otp.end_date,null,'',otp.end_date)
   FROM ota_training_plans otp
  WHERE otp.training_plan_id = p_training_plan_id
    AND ( otp.start_date > p_earliest_start_date
     OR ( otp.end_date IS NOT NULL
    AND otp.end_date < p_target_completion_date) );

 CURSOR csr_tpm_overlap IS
 SELECT NULL
   FROM ota_training_plan_members
  WHERE training_plan_id      = p_training_plan_id
    AND activity_version_id = p_activity_version_id
    AND target_completion_date >= p_earliest_start_date
    AND earliest_start_date <= p_target_completion_date
    AND member_status_type_id <> 'CANCELLED'
    and (p_training_plan_member_id is null
         or training_plan_member_id<> p_training_plan_member_id
         ) ;
  --
  CURSOR csr_version_date_range IS
  SELECT oav.start_date, oav.end_date
    FROM ota_activity_versions    oav
   WHERE oav.activity_version_id = p_activity_version_id;

  l_exists              NUMBER(9);
  l_api_updating        BOOLEAN;
  l_flag                VARCHAR2(30);
  l_version_start_date  DATE;
  l_version_end_date    DATE;
  l_start_Date          Date;
  l_end_date            Date;

BEGIN

    -- check mandatory parameters have been set
--
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_training_plan_id'
    ,p_argument_value =>  p_training_plan_id
    );

     l_api_updating := ota_tpm_shd.api_updating
       (p_training_plan_member_id => p_training_plan_member_id
       ,p_object_version_number   => p_object_version_number
       );
  --
  --
  -- If this is a changing update, or a new insert, test
  --
 IF ((l_api_updating AND
       NVL(ota_tpm_shd.g_old_rec.earliest_start_date, hr_api.g_date) <>
       NVL(p_earliest_start_date, hr_api.g_date)
       OR NVL(ota_tpm_shd.g_old_rec.target_completion_date, hr_api.g_date) <>
       NVL(p_target_completion_date, hr_api.g_date) )
      OR (NOT l_api_updating))
  THEN
    hr_utility.set_location(' Step:'|| l_proc, 20);

 /* IF( NOT l_api_updating
   or NVL(ota_tpm_shd.g_old_rec.earliest_start_date, hr_api.g_date) <>
       NVL(p_earliest_start_date, hr_api.g_date)) THEN

    IF ( p_earliest_start_date < TRUNC(SYSDATE))THEN
        l_flag := 'START_DATE';
        fnd_message.set_name('OTA', 'OTA_13179_TPM_STRT_DATE');
        fnd_message.raise_error;

    END IF;

  END IF;*/


          IF ( p_target_completion_date >= p_earliest_start_date ) THEN

              OPEN csr_comp_tpc_tp_dates;
             FETCH csr_comp_tpc_tp_dates INTO l_exists,l_start_date,l_end_date;
                IF csr_comp_tpc_tp_dates%FOUND THEN
                    CLOSE csr_comp_tpc_tp_dates;

                   fnd_message.set_name('OTA', 'OTA_13994_TPS_TPM_DATES');
                   fnd_message.set_token('TP_STARTDATE',l_start_date);
                   fnd_message.set_token('TP_ENDDATE',l_end_date);
                   fnd_message.raise_error;
               ELSE

                    CLOSE csr_comp_tpc_tp_dates;
               END IF;
             -- Explicitly get the activity version start dates.
             --
              OPEN csr_version_date_range;
             FETCH csr_version_date_range  INTO l_version_start_date, l_version_end_date;
             CLOSE csr_version_date_range;
      --
               IF NVL(l_version_end_date, hr_api.g_eot) < NVL(p_earliest_start_date, hr_api.g_sot) THEN
                  fnd_message.set_name('OTA', 'OTA_13181_TPM_ACT_VRSN_EARLY');
                  fnd_message.raise_error;
            ELSIF NVL(l_version_start_date, hr_api.g_sot) > NVL(p_target_completion_date, hr_api.g_eot) THEN
                  fnd_message.set_name('OTA', 'OTA_13180_TPM_ACT_VRSN_LATE');
                  fnd_message.raise_error;
             elsif (l_version_start_date>p_earliest_start_date) or (l_version_end_date<p_target_completion_date) then
                  fnd_message.set_name('OTA', 'OTA_13188_TPM_DATES_RANGE');
                  fnd_message.raise_error;
              END IF;

              OPEN csr_tpm_overlap;
             FETCH csr_tpm_overlap INTO l_exists;
                IF csr_tpm_overlap%FOUND THEN
                    CLOSE csr_tpm_overlap;

                   fnd_message.set_name('OTA', 'OTA_13184_TPM_DATES_OVERLAP');
                   fnd_message.raise_error;
               ELSE

                    CLOSE csr_tpm_overlap;
               END IF;


            ELSE
                 l_flag := 'END_DATE';
                 fnd_message.set_name('OTA', 'OTA_13993_TPM_DATES');
                 fnd_message.raise_error;
             END IF;


END IF;

    hr_utility.set_location(' Step:'|| l_proc, 30);

       --MULTI MESSAGE SUPPORT
EXCEPTION

        WHEN app_exception.application_exception THEN

           IF l_flag ='END_DATE' THEN
    /*           IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLAN_MEMBERS.EARLIEST_START_DATE') THEN
             --       ,p_associated_column2   => 'OTA_TRAINING_PLAN_MEMBERS.TARGET_COMPLETION_DATE') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 32);
                   RAISE;

               END IF;
           ELSIF l_flag = 'END_DATE' THEN */
                IF hr_multi_message.exception_add(
                 --   p_associated_column1    => 'OTA_TRAINING_PLAN_MEMBERS.EARLIEST_START_DATE') THEN
                   p_associated_column1   => 'OTA_TRAINING_PLAN_MEMBERS.TARGET_COMPLETION_DATE') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 35);
                   RAISE;

               END IF;
           ELSE
                IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_TRAINING_PLAN_MEMBERS.EARLIEST_START_DATE'
                   ,p_associated_column2   => 'OTA_TRAINING_PLAN_MEMBERS.TARGET_COMPLETION_DATE') THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 36);
                   RAISE;

               END IF;

           END IF;
                hr_utility.set_location(' Leaving:'||l_proc, 37);

END chk_tpc_tp_actver_dates;






END ota_tpm_bus1;

/
