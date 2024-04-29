--------------------------------------------------------
--  DDL for Package Body PER_ASP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASP_BUS" as
/* $Header: peasprhi.pkb 115.15 2002/12/02 14:20:06 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_asp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_sec_profile_assignment_id >-----------------------------------|
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
--   sec_profile_assignment_id PK of record being inserted or updated.
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
Procedure chk_sec_profile_assignment_id(p_sec_profile_assignment_id in number,
                           p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sec_profile_assignment_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_asp_shd.api_updating
    (p_sec_profile_assignment_id => p_sec_profile_assignment_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_sec_profile_assignment_id,hr_api.g_number)
     <>  per_asp_shd.g_old_rec.sec_profile_assignment_id) then
    --
    -- raise error as PK has changed
    --
    per_asp_shd.constraint_error('PER_SEC_PROFILE_ASSIGNMENTS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_sec_profile_assignment_id is not null then
      --
      -- raise error as PK is not null
      --
      per_asp_shd.constraint_error('PER_SEC_PROFILE_ASSIGNMENTS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_sec_profile_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_security_profile_id >-----------------------------------------|
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
--   p_sec_profile_assignment_id PK
--   p_security_profile_id ID of FK column
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
Procedure chk_security_profile_id (p_sec_profile_assignment_id in number,
                            p_security_profile_id in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_security_profile_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_security_profiles a
    where  a.security_profile_id = p_security_profile_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_asp_shd.api_updating
     (p_sec_profile_assignment_id            => p_sec_profile_assignment_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_security_profile_id,hr_api.g_number)
     <> nvl(per_asp_shd.g_old_rec.security_profile_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if security_profile_id value exists in per_security_profiles table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_security_profiles
        -- table.
        --
        per_asp_shd.constraint_error('PER_SEC_PROFILE_ASSIGNMENTS_FK');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_security_profile_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_business_group_id >-------------------------------------------|
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
--   p_sec_profile_assignment_id PK
--   p_business_group_id ID of FK column
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
Procedure chk_business_group_id (p_sec_profile_assignment_id in number,
                            p_business_group_id in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_security_profile_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_organization_information h1
    where  h1.org_information_context = 'Business Group Information'
      and  h1.organization_id = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_asp_shd.api_updating
     (p_sec_profile_assignment_id            => p_sec_profile_assignment_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_business_group_id,hr_api.g_number)
     <> nvl(per_asp_shd.g_old_rec.business_group_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if business_group_id value exists in per_business_groups view
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_business_groups
        -- view
        --
        per_asp_shd.constraint_error('PER_SEC_PROFILE_ASSIGNMENTS_FK');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_business_group_id;
--
-- ----------------------------------------------------------------------------
-- |-< chk_non_updateable_args >----------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have not
--   been updated.  If an attribute has been updated an error is generated.
--
-- Prerequisites:
--
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not been
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updateable attributes
--   (listed below) have been changed.
--
--     sec_profile_assignment_id
--     user_id
--     security_group_id
--     business_group_id
--     security_profile_id
--     responsibility_id
--     responsibility_application_id
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_non_updateable_args
   (p_rec             IN per_asp_shd.g_rec_type
   )
IS
--
   l_proc      VARCHAR2 (72)  := g_package||'chk_non_updateable_args';
   l_error     EXCEPTION;
   l_argument  VARCHAR2 (30);
--
BEGIN
   hr_utility.set_location('Entering:'||l_proc, 10);
   --
   -- Only proceed with validation if a row exists for
   -- the current record in the HR Schema
   --
   IF NOT per_asp_shd.api_updating
            (p_sec_profile_assignment_id     => p_rec.sec_profile_assignment_id
            ,p_object_version_number         => p_rec.object_version_number
            )
   THEN
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', '20');
   END IF;
   --
   hr_utility.set_location(l_proc, 30);
   --
   IF p_rec.sec_profile_assignment_id
         <> per_asp_shd.g_old_rec.sec_profile_assignment_id
   THEN
      --
      l_argument := 'sec_profile_assignment_id';
      raise l_error;
      --
   END IF;
   --
   hr_utility.set_location(l_proc, 40);
   --
   IF p_rec.user_id
         <> per_asp_shd.g_old_rec.user_id
   THEN
      --
      l_argument := 'user_id';
      raise l_error;
      --
   END IF;
   --
   hr_utility.set_location(l_proc, 50);
   --
   IF p_rec.security_group_id
         <> per_asp_shd.g_old_rec.security_group_id
   THEN
      --
      l_argument := 'security_group_id';
      raise l_error;
      --
   END IF;
   --
   hr_utility.set_location(l_proc, 55);
   --
   IF p_rec.business_group_id
         <> per_asp_shd.g_old_rec.business_group_id
   THEN
      --
      l_argument := 'business_group_id';
      raise l_error;
      --
   END IF;
   --
   hr_utility.set_location(l_proc, 60);
   --
   IF p_rec.security_profile_id
         <> per_asp_shd.g_old_rec.security_profile_id
   THEN
      --
      l_argument := 'security_profile_id';
      raise l_error;
      --
   END IF;
   --
   hr_utility.set_location(l_proc, 70);
   --
   IF p_rec.responsibility_id
         <> per_asp_shd.g_old_rec.responsibility_id
   THEN
      --
      l_argument := 'responsibility_id';
      raise l_error;
      --
   END IF;
   --
   hr_utility.set_location(l_proc, 80);
   --
   IF p_rec.responsibility_application_id
         <> per_asp_shd.g_old_rec.responsibility_application_id
   THEN
      --
      l_argument := 'responsibility_application_id';
      raise l_error;
      --
   END IF;
   --
   hr_utility.set_location(l_proc, 90);
   --
EXCEPTION
   WHEN l_error THEN
      hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
   WHEN OTHERS THEN
      RAISE;
   hr_utility.set_location(' Leaving:'||l_proc, 100);
END chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-< chk_assignment_dates >-------------------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_assignment_dates
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   )
IS
--
CURSOR c_get_assignment_dates
IS
SELECT start_date
      ,end_date
  FROM fnd_user_resp_groups
 WHERE user_id = p_user_id
   AND responsibility_id = p_responsibility_id
   AND responsibility_application_id = p_application_id
   AND security_group_id = p_security_group_id;
--
BEGIN
   --
   -- check that the start date is not null
   --
   IF p_start_date IS NULL THEN
      --
      hr_utility.set_message
         (800
         ,'PER_52528_ASP_START_DATE_NULL'
         );
      hr_utility.raise_error;
      --
   END IF;
   --
   -- check that the start date is not on or more than the end date
   --
   IF p_start_date > NVL(p_end_date, hr_general.END_OF_TIME) THEN
      --
      hr_utility.set_message
         (800
         ,'PER_52525_ASP_DATE_ERROR'
         );
      hr_utility.raise_error;
      --
   END IF;
   --
END chk_assignment_dates;
--
-- ----------------------------------------------------------------------------
-- |-< chk_invalid_dates >----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that the start/end
--   dates of new/updated records cannot overlap both the start and the end
--   dates of existing records.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_invalid_dates
   (p_sec_profile_assignment_id
                  IN per_sec_profile_assignments.sec_profile_assignment_id%TYPE
                     DEFAULT NULL
   ,p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   ,p_security_profile_id
                  IN per_sec_profile_assignments.security_profile_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   )
IS
--
CURSOR c_chk_invalid_dates
IS
SELECT 'Y'
  FROM per_sec_profile_assignments s
 WHERE s.user_id = p_user_id
   AND s.responsibility_id = p_responsibility_id
   AND s.responsibility_application_id = p_application_id
   AND s.security_group_id = p_security_group_id
   AND s.business_group_id = p_business_group_id
   AND s.security_profile_id = p_security_profile_id
   AND s.start_date >= p_start_date
   AND NVL(s.end_date, hr_general.END_OF_TIME) <= NVL(p_end_date, hr_general.END_OF_TIME)
   AND (p_sec_profile_assignment_id IS NULL
        OR s.sec_profile_assignment_id <> p_sec_profile_assignment_id);
--
l_result  VARCHAR2 (1);
--
BEGIN
   --
   OPEN c_chk_invalid_dates;
   --
   FETCH c_chk_invalid_dates INTO l_result;
   --
   IF c_chk_invalid_dates%FOUND THEN
      --
      CLOSE c_chk_invalid_dates;
      --
      -- record found - raise an exception
      --
      hr_utility.set_message
         (800
         ,'PER_52529_ASP_ASN_DATE_ERROR'
         );
      hr_utility.raise_error;
   END IF;
   --
   CLOSE c_chk_invalid_dates;
   --
END chk_invalid_dates;
--
-- ----------------------------------------------------------------------------
-- |-< chk_duplicate_assignments >--------------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_duplicate_assignments
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   ,p_security_profile_id
                  IN per_sec_profile_assignments.security_profile_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   )
IS
--
CURSOR c_exists_duplicate_assignment
IS
SELECT 'Y'
  FROM per_sec_profile_assignments
 WHERE user_id = p_user_id
   AND responsibility_id = p_responsibility_id
   AND responsibility_application_id = p_application_id
   AND security_group_id = p_security_group_id
   AND business_group_id = p_business_group_id
   AND security_profile_id <> p_security_profile_id
   AND ( (start_date BETWEEN p_start_date
                        AND NVL(p_end_date, hr_general.END_OF_TIME))
      OR (NVL(end_date, hr_general.END_OF_TIME)
            BETWEEN p_start_date
                AND NVL(p_end_date, hr_general.END_OF_TIME))
      OR (    start_date < p_start_date
              AND NVL(end_date, hr_general.END_OF_TIME)
                     > NVL(p_end_date, hr_general.END_OF_TIME)));
--
l_exists  VARCHAR2(1);
--
BEGIN
   --
   OPEN c_exists_duplicate_assignment;
   --
   FETCH c_exists_duplicate_assignment INTO l_exists;
   --
   IF c_exists_duplicate_assignment%NOTFOUND THEN
      --
      CLOSE c_exists_duplicate_assignment;
      --
   ELSE
      --
      CLOSE c_exists_duplicate_assignment;
      --
      hr_utility.set_message
         (800
         ,'PER_52551_ASP_DUP_ASN_ERROR'
         );
      hr_utility.raise_error;
      --
   END IF;
   --
END chk_duplicate_assignments;
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_overlapping_dates
   (p_sec_profile_assignment_id
                  IN per_sec_profile_assignments.sec_profile_assignment_id%TYPE
                     DEFAULT NULL
   ,p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   ,p_security_profile_id
                  IN per_sec_profile_assignments.security_profile_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   )
IS
--
l_id          per_sec_profile_assignments.sec_profile_assignment_id%TYPE DEFAULT NULL;
l_ovn         per_sec_profile_assignments.object_version_number%TYPE DEFAULT NULL;
l_start_date  per_sec_profile_assignments.start_date%TYPE DEFAULT NULL;
l_end_date    per_sec_profile_assignments.end_date%TYPE DEFAULT NULL;
--
BEGIN
   --
   -- call the other chk_overlapping_dates procedure and raise the relavent exception
   -- if it returns anything
   --
   chk_overlapping_dates
      (p_sec_profile_assignment_id => p_sec_profile_assignment_id
      ,p_user_id => p_user_id
      ,p_responsibility_id => p_responsibility_id
      ,p_application_id => p_application_id
      ,p_security_group_id => p_security_group_id
      ,p_business_group_id => p_business_group_id
      ,p_security_profile_id => p_security_profile_id
      ,p_start_date => p_start_date
      ,p_end_date => p_end_date
      ,p_clashing_id => l_id
      ,p_clashing_ovn => l_ovn
      ,p_clashing_start_date => l_start_date
      ,p_clashing_end_date => l_end_date
      );
   --
   IF l_id IS NOT NULL THEN
      -- we need to work out which exception to raise....
      IF p_start_date >= l_start_date AND p_start_date <= l_end_date THEN
         --
         -- The start date of the inserted/updated record is in error
         --
         hr_utility.set_message
            (800
            ,'PER_52526_ASP_START_DATE_ERROR'
            );
         hr_utility.raise_error;
         --
      ELSIF p_end_date >= l_start_date AND p_end_date <= l_end_date THEN
         --
         -- The end date of the inserted/updated record is in error
         --
         hr_utility.set_message
            (800
            ,'PER_52527_ASP_END_DATE_ERROR'
            );
         hr_utility.raise_error;
         --
      END IF;
   END IF;
   --
END chk_overlapping_dates;
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_overlapping_dates
   (p_sec_profile_assignment_id
                  IN per_sec_profile_assignments.sec_profile_assignment_id%TYPE
                     DEFAULT NULL
   ,p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   ,p_security_profile_id
                  IN per_sec_profile_assignments.security_profile_id%TYPE
   ,p_start_date
                  IN per_sec_profile_assignments.start_date%TYPE
   ,p_end_date
                  IN per_sec_profile_assignments.end_date%TYPE
   ,p_clashing_id
                 OUT NOCOPY per_sec_profile_assignments.sec_profile_assignment_id%TYPE
   ,p_clashing_ovn
                 OUT NOCOPY per_sec_profile_assignments.object_version_number%TYPE
   ,p_clashing_start_date
                 OUT NOCOPY per_sec_profile_assignments.start_date%TYPE
   ,p_clashing_end_date
                 OUT NOCOPY per_sec_profile_assignments.end_date%TYPE
   )
IS
--
CURSOR c_chk_overlapping_dates
IS
SELECT s.sec_profile_assignment_id
      ,s.object_version_number
      ,s.start_date
      ,s.end_date
 FROM per_sec_profile_assignments s
 WHERE s.user_id = p_user_id
   AND s.responsibility_id = p_responsibility_id
   AND s.responsibility_application_id = p_application_id
   AND s.security_group_id = p_security_group_id
   AND s.business_group_id = p_business_group_id
   AND s.security_profile_id = p_security_profile_id
   AND NOT (   (s.start_date < p_start_date
                AND NVL(s.end_date, hr_general.END_OF_TIME) < p_start_date)
           OR  (s.start_date > p_end_date
                AND NVL(s.end_date, hr_general.END_OF_TIME) > NVL(p_end_date, hr_general.END_OF_TIME))
           )
   AND (p_sec_profile_assignment_id IS NULL
        OR s.sec_profile_assignment_id <> p_sec_profile_assignment_id);
--
BEGIN
   --
   OPEN c_chk_overlapping_dates;
   --
   FETCH c_chk_overlapping_dates INTO p_clashing_id
                                     ,p_clashing_ovn
                                     ,p_clashing_start_date
                                     ,p_clashing_end_date;
   --
   IF c_chk_overlapping_dates%NOTFOUND THEN
      p_clashing_id := NULL;
   END IF;
   --
   CLOSE c_chk_overlapping_dates;
   --
END chk_overlapping_dates;
--
-- ----------------------------------------------------------------------------
-- |-< chk_assignment_exists >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_assignment_exists
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   )
IS
--
BEGIN
   --
   IF NOT chk_assignment_exists
         (p_user_id
         ,p_responsibility_id
         ,p_application_id
         ,p_security_group_id
         )
   THEN
      --
      hr_utility.set_message
         (800
         ,'PER_52524_ASP_ASN_NOT_EXIST'
         );
      hr_utility.raise_error;
      --
   END IF;
   --
END chk_assignment_exists;
--
-- ----------------------------------------------------------------------------
-- |-< chk_assignment_exists >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION chk_assignment_exists
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ) RETURN BOOLEAN
IS
--
BEGIN
   --
   RETURN fnd_user_resp_groups_api.Assignment_Exists
            (user_id => p_user_id
            ,responsibility_id => p_responsibility_id
            ,responsibility_application_id => p_application_id
            ,security_group_id => p_security_group_id
            );
   --
END chk_assignment_exists;
--
-- ----------------------------------------------------------------------------
-- |-< get_security_group_id >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_security_group_id
   (p_business_group_id  IN NUMBER
   ) RETURN NUMBER
IS
--
CURSOR c_get_sg_id
IS
SELECT org_information14 security_group_id
  FROM hr_organization_information h1
 WHERE org_information_context = 'Business Group Information'
   AND h1.organization_id = p_business_group_id;
--
l_security_group_id  NUMBER;
l_exception          EXCEPTION;
--
BEGIN
   IF fnd_profile.value('ENABLE_SECURITY_GROUPS') = 'Y' THEN
      --
      -- Retrieve the security_group_id by querying the per_business_groups
      -- view with the business_group_id supplied.
      --
      OPEN c_get_sg_id;
      FETCH c_get_sg_id INTO l_security_group_id;
      IF c_get_sg_id%NOTFOUND THEN
         --
         -- Security group does not exist!  Raise an exception...
         --
         CLOSE c_get_sg_id;
         RAISE l_exception;
      END IF;
      --
      CLOSE c_get_sg_id;
   ELSE
      --
      -- if security groups are not enabled then just return 0 (ie. the
      -- standard security group)
      --
      l_security_group_id := 0;
   END IF;
   --
   RETURN l_security_group_id;
   --
END get_security_group_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_asp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_sec_profile_assignment_id
  (p_sec_profile_assignment_id => p_rec.sec_profile_assignment_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_security_profile_id
  (p_sec_profile_assignment_id => p_rec.sec_profile_assignment_id,
   p_security_profile_id => p_rec.security_profile_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_business_group_id
  (p_sec_profile_assignment_id => p_rec.sec_profile_assignment_id,
   p_business_group_id => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
   --
   chk_duplicate_assignments
      (p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      ,p_business_group_id => p_rec.business_group_id
      ,p_security_profile_id => p_rec.security_profile_id
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      );
  --
  -- Do some checks on the date of the assignment
  --
  chk_assignment_dates
      (p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      );
  --
  chk_invalid_dates
      (p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      ,p_business_group_id => p_rec.business_group_id
      ,p_security_profile_id => p_rec.security_profile_id
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      );
  --
  chk_overlapping_dates
      (p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      ,p_business_group_id => p_rec.business_group_id
      ,p_security_profile_id => p_rec.security_profile_id
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      );
   --
  --
  IF NOT chk_assignment_exists
            (p_user_id => p_rec.user_id
            ,p_responsibility_id => p_rec.responsibility_id
            ,p_application_id => p_rec.responsibility_application_id
            ,p_security_group_id => p_rec.security_group_id
            )
  THEN
     --
     -- The assignment does not exist, so create it....
     --
     fnd_user_resp_groups_api.Insert_Assignment
        (user_id => p_rec.user_id
        ,responsibility_id => p_rec.responsibility_id
        ,responsibility_application_id => p_rec.responsibility_application_id
        ,security_group_id => p_rec.security_group_id
        ,start_date => p_rec.start_date
        ,end_date => p_rec.end_date
        ,description => ' ' -- ### description was supposed to default
                            -- to null... but does not look like it has
        );
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_asp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args
   (p_rec
   );
  --
  chk_sec_profile_assignment_id
  (p_sec_profile_assignment_id          => p_rec.sec_profile_assignment_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_security_profile_id
  (p_sec_profile_assignment_id          => p_rec.sec_profile_assignment_id,
   p_security_profile_id          => p_rec.security_profile_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_business_group_id
  (p_sec_profile_assignment_id          => p_rec.sec_profile_assignment_id,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_duplicate_assignments
      (p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      ,p_business_group_id => p_rec.business_group_id
      ,p_security_profile_id => p_rec.security_profile_id
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      );
  --
  -- Do some checks on the date of the assignment
  --
  chk_assignment_dates
      (p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      );
  --
  chk_invalid_dates
      (p_sec_profile_assignment_id => p_rec.sec_profile_assignment_id
      ,p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      ,p_business_group_id => p_rec.business_group_id
      ,p_security_profile_id => p_rec.security_profile_id
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      );
  --
  chk_overlapping_dates
      (p_sec_profile_assignment_id => p_rec.sec_profile_assignment_id
      ,p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      ,p_business_group_id => p_rec.business_group_id
      ,p_security_profile_id => p_rec.security_profile_id
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      );
  --
  chk_assignment_exists
      (p_user_id => p_rec.user_id
      ,p_responsibility_id => p_rec.responsibility_id
      ,p_application_id => p_rec.responsibility_application_id
      ,p_security_group_id => p_rec.security_group_id
      );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |-< Synchronize_Assignment_Dates >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE Synchronize_Assignment_Dates
   (p_user_id
                  IN per_sec_profile_assignments.user_id%TYPE
   ,p_responsibility_id
                  IN per_sec_profile_assignments.responsibility_id%TYPE
   ,p_application_id
                  IN per_sec_profile_assignments.responsibility_application_id%TYPE
   ,p_security_group_id
                  IN per_sec_profile_assignments.security_group_id%TYPE
   ,p_business_group_id
                  IN per_sec_profile_assignments.business_group_id%TYPE
   )
IS
--
CURSOR c_get_minmax_dates
IS
SELECT MIN(s.start_date), MAX(s.end_date)
  FROM per_sec_profile_assignments s
 WHERE s.user_id = p_user_id
   AND s.responsibility_id = p_responsibility_id
   AND s.responsibility_application_id = p_application_id
   AND s.security_group_id = p_security_group_id
   AND s.business_group_id = p_business_group_id;
--
CURSOR c_chk_null_end_date
IS
SELECT 'Y'
  FROM per_sec_profile_assignments s
 WHERE s.user_id = p_user_id
   AND s.responsibility_id = p_responsibility_id
   AND s.responsibility_application_id = p_application_id
   AND s.security_group_id = p_security_group_id
   AND s.business_group_id = p_business_group_id
   AND s.end_date IS NULL;
--
l_exists    VARCHAR2 (1);
l_min_date  DATE;
l_max_date  DATE;
l_exception EXCEPTION;
--
BEGIN
   --
   OPEN c_get_minmax_dates;
   --
   FETCH c_get_minmax_dates INTO l_min_date, l_max_date;
   --
   IF c_get_minmax_dates%NOTFOUND THEN
      --
      -- Panic!
      --
      RAISE l_exception;
   END IF;
   --
   CLOSE c_get_minmax_dates;
   --
   --
   -- Commented the code out below for bug 1305436; end date should be
   -- kept as null rather than changed to EOT. If changed to EOT then
   -- the date 31-DEC-4712 shows up on FND User form IJH 8/6/00
   --
   -- This code has been uncommented due to the fact that eot must be
   -- stored in fnd_user_resp_groups if end_date is null or the security
   -- group will not be displayed in the responsibilities form.
   --
    OPEN c_chk_null_end_date;
   --
    FETCH c_chk_null_end_date INTO l_exists;
   --
    IF c_chk_null_end_date%FOUND THEN
      --
      -- A record that has not been end-dated exists..
      -- So set the end date in the fnd_user_resp_groups table to be the
      -- end of time...
       l_max_date := hr_general.END_OF_TIME;
    END IF;

    CLOSE c_chk_null_end_date;
   --
   --
   -- Now we have got the start and end dates, so lets update the
   -- fnd_user_resp_groups table.
   --
   fnd_user_resp_groups_api.Update_Assignment
      (user_id => p_user_id
      ,responsibility_id => p_responsibility_id
      ,responsibility_application_id => p_application_id
      ,security_group_id => p_security_group_id
      ,start_date => l_min_date
      ,end_date => l_max_date
      ,description => ' ' -- ### description was supposed to default
                          -- to null... but does not look like it has
      );
   --
END Synchronize_Assignment_Dates;
--
end per_asp_bus;

/
