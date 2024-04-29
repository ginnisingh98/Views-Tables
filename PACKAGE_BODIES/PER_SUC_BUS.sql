--------------------------------------------------------
--  DDL for Package Body PER_SUC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUC_BUS" 
AS
/* $Header: pesucrhi.pkb 120.1.12010000.9 2010/02/22 20:28:53 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
   g_package   VARCHAR2 (33) := '  per_suc_bus.';                            -- Global package name

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_succession_plan_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the succession
--   planning table is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
--
   PROCEDURE chk_succession_plan_id (
      p_succession_plan_id      IN   NUMBER,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_succession_plan_id';
      l_api_updating   BOOLEAN;
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (    l_api_updating
          AND NVL (p_succession_plan_id, hr_api.g_number) <>
                                                            per_suc_shd.g_old_rec.succession_plan_id
         )
      THEN
         --
         -- raise error as PK has changed
         --
         per_suc_shd.constraint_error ('PER_SUCCESSION_PLANNING_PK');
      --
      ELSIF NOT l_api_updating
      THEN
         --
         -- check if PK is null
         --
         IF p_succession_plan_id IS NOT NULL
         THEN
            --
            -- raise error as PK is not null
            --
            per_suc_shd.constraint_error ('PER_SUCCESSION_PLANNING_PK');
         --
         END IF;
      --
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_succession_plan_id;

-- ----------------------------------------------------------------------------
-- |----------------------------< chk_person_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the person_id exists as of effective
--   date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   effective_date                     effective date
--   succession_plan_id                 PK of record being inserted or updated.
--   person_id                          id of person being inserted.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_person_id (
      p_effective_date          IN   DATE,
      p_succession_plan_id      IN   NUMBER,
      p_person_id               IN   NUMBER,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_person_id';
      l_api_updating   BOOLEAN;
      l_dummy          VARCHAR2 (1);

      --
      CURSOR c1
      IS
         SELECT NULL
           FROM per_people_f ppf, per_person_type_usages_f ptu, per_person_types ppt
          WHERE ppf.person_id = p_person_id
            AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
            AND ppf.person_id = ptu.person_id
            AND TRUNC (SYSDATE) BETWEEN ptu.effective_start_date AND ptu.effective_end_date
            AND ptu.person_type_id = ppt.person_type_id
            AND (   ppt.system_person_type = 'EMP'
                 OR ppt.system_person_type = 'APL'
                 OR ppt.system_person_type = 'CWK'
                );
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_person_id, hr_api.g_number) <>
                                              NVL (per_suc_shd.g_old_rec.person_id, hr_api.g_number)
          OR NOT l_api_updating
         )
      THEN
         --
         -- check if person_id is null
         --
         IF p_person_id IS NULL
         THEN
            --
            -- raise error as this a mandatory requirement
            --
            hr_utility.set_message (801, 'HR_52784_SUC_CHK_PERSON_ID');
            hr_utility.raise_error;
         --
         END IF;

         --
         /*if l_api_updating then
            --
            -- raise error as the person can not be updated.
            --
            hr_utility.set_message(801,'HR_52785_SUC_CHK_PERSON_UPDATE');
            hr_utility.raise_error;
            --
         end if;*/
         --
         -- check if the person_id exists as of effective date.
         --
         OPEN c1;

         --
         FETCH c1
          INTO l_dummy;

         --
         IF c1%NOTFOUND
         THEN
            --
            CLOSE c1;

            --
            -- raise error as person does not exist.
            --
            hr_utility.set_message (801, 'HR_52786_SUC_CHK_PERSON_EXISTS');
            hr_utility.raise_error;
         --
         END IF;

         --
         CLOSE c1;
      --
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_person_id;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_position_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the position_id exists as of
--   effective date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   effective_date                     effective date
--   succession_plan_id                 PK of record being inserted or updated.
--   position_id                        id of position being inserted.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_position_id (
      p_effective_date          IN   DATE,
      p_succession_plan_id      IN   NUMBER,
      p_position_id             IN   NUMBER,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_position_id';
      l_api_updating   BOOLEAN;
      l_dummy          VARCHAR2 (1);

      --
      -- Changes 12-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked positions req.
      --
      CURSOR c1
      IS
         SELECT NULL
           FROM hr_positions_f per
          WHERE per.position_id = NVL (p_position_id, -1)
            AND p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
            AND p_effective_date BETWEEN per.date_effective
                                     AND NVL (hr_general.get_position_date_end (per.position_id),
                                              hr_api.g_eot
                                             );
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_position_id, hr_api.g_number) <>
                                            NVL (per_suc_shd.g_old_rec.position_id, hr_api.g_number)
          OR NOT l_api_updating
         )
      THEN
           --
           -- check if position_id is null
           --
         /*  if p_position_id is null then
             --
             -- raise error as this a mandatory requirement
             --
             hr_utility.set_message(801,'HR_51998_SUC_CHK_POSITION_ID');
             hr_utility.raise_error;
             --
           end if;*/
           --
         IF l_api_updating
         THEN
            --
            -- raise error as the position_id can not be updated.
            --
            hr_utility.set_message (801, 'HR_51999_SUC_CHK_POS_UPDATE');
            hr_utility.raise_error;
         --
         END IF;

         --
         -- check if the position_id exists as of effective_date.
         --
         OPEN c1;

         --
         FETCH c1
          INTO l_dummy;

         --
         IF c1%NOTFOUND
         THEN
            --
            CLOSE c1;

            --
            -- raise error as position does not exist as of effective date.
            --
            per_suc_shd.constraint_error ('PER_SUCCESSION_PLANNING_FK1');
         --
         END IF;

         --
         CLOSE c1;
      --
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_position_id;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_job_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the job_id exists as of
--   effective date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   effective_date                     effective date
--   succession_plan_id                 PK of record being inserted or updated.
--   job_id                             id of job being inserted.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_job_id (
      p_effective_date          IN   DATE,
      p_succession_plan_id      IN   NUMBER,
      p_job_id                  IN   NUMBER,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_job_id';
      l_api_updating   BOOLEAN;
      l_dummy          VARCHAR2 (1);

      --
      --
      CURSOR c1
      IS
         SELECT NULL
           FROM per_jobs_vl per
          WHERE per.job_id = NVL (p_job_id, -1)
            AND p_effective_date BETWEEN per.date_from AND NVL (date_to, TRUNC (SYSDATE));
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_job_id, hr_api.g_number) <>
                                                 NVL (per_suc_shd.g_old_rec.job_id, hr_api.g_number)
          OR NOT l_api_updating
         )
      THEN
           --
           -- check if job_id is null
           --
         /*  if p_job_id is null then
             --
             -- raise error as this a mandatory requirement
             --
             hr_utility.set_message(801,'HR_XXXXX_SUC_CHK_JOB_ID');
             hr_utility.raise_error;
             --
           end if;*/
           --
         IF l_api_updating
         THEN
            --
            -- raise error as the job_id can not be updated.
            --
            hr_utility.set_message (801, 'HR_50493_SUC_CHK_JOB_UPDATE');
            hr_utility.raise_error;
         --
         END IF;

         --
         -- check if the job_id exists as of effective_date.
         --
         OPEN c1;

         --
         FETCH c1
          INTO l_dummy;

         --
         IF c1%NOTFOUND
         THEN
            --
            CLOSE c1;

            --
            -- raise error as job does not exist as of effective date.
            --
            per_suc_shd.constraint_error ('PER_SUCCESSION_PLANNING_FK2');
         --
         END IF;

         --
         CLOSE c1;
      --
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_job_id;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_successee >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the successee_id exists as of
--   effective date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   effective_date                     effective date
--   succession_plan_id                 PK of record being inserted or updated.
--   job_id                             id of job being inserted.
--   position_id                        id of position being inserted
--   successee_person_id                id of person being inserted (successee)
--   object_version_number              Object version number of record being
--                                      inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_successee (
      p_effective_date          IN   DATE,
      p_succession_plan_id      IN   NUMBER,
      p_job_id                  IN   NUMBER,
      p_position_id             IN   NUMBER,
      p_successee_person_id     IN   NUMBER,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_successee';
      l_api_updating   BOOLEAN;
      l_dummy          VARCHAR2 (1);
      l_type           VARCHAR2 (3);                                              --succession type
      l_notnulls       NUMBER        := 0;
   --
   --

   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (    l_api_updating
          AND NVL (p_successee_person_id, hr_api.g_number) <>
                                    NVL (per_suc_shd.g_old_rec.successee_person_id, hr_api.g_number)
         )
      THEN
         --
         -- raise error as the person can not be updated.
         --
         hr_utility.set_message (801, 'HR_50494_SUC_CHK_SUCC_UPDATE');
         hr_utility.raise_error;
      --
      END IF;

      --
      IF (p_job_id IS NOT NULL)
      THEN
         l_type                     := 'JOB';
         -- CHK_JOB_ID
         --
         chk_job_id (p_effective_date, p_succession_plan_id, p_job_id, p_object_version_number);
         l_notnulls                 := l_notnulls + 1;
      END IF;

      IF (p_position_id IS NOT NULL)
      THEN
         l_type                     := 'POS';
         -- CHK_POSITION_ID
         --
         chk_position_id (p_effective_date,
                          p_succession_plan_id,
                          p_position_id,
                          p_object_version_number
                         );
         l_notnulls                 := l_notnulls + 1;
      END IF;

      IF (p_successee_person_id IS NOT NULL)
      THEN
         l_type                     := 'EMP';
         -- CHK_SUCCESSEE_PERSON_ID
         --
         chk_person_id (p_effective_date,
                        p_succession_plan_id,
                        p_successee_person_id,
                        p_object_version_number
                       );
         l_notnulls                 := l_notnulls + 1;
      END IF;

      IF (l_notnulls = 0)
      THEN
         --
         -- raise error as JOB OR POSITION OR SUCCESSEE PERSON ID IS MANDATORY
         --
         per_suc_shd.constraint_error ('HR_50495_SUC_CHK_SUC_MISSING');
      ELSIF (l_notnulls > 1)
      THEN
         --
           -- raise error as MORE THAN ONE SUCCESSEE ID IS ENTERED
           --
         per_suc_shd.constraint_error ('HR_50496_SUC_CHK_SUC_EXIST');
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_successee;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_successor >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the successor exists as of
--   effective date and whether successee and successor are the same or login user is a successor
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   effective_date                     effective date
--   succession_plan_id                 PK of record being inserted or updated.
--   job_id                             id of job being inserted.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_successor (
      p_effective_date          IN   DATE,
      p_succession_plan_id      IN   NUMBER,
      p_person_id               IN   NUMBER,
      p_job_id                  IN   NUMBER,
      p_position_id             IN   NUMBER,
      p_person_rank             IN   NUMBER,
      p_successee_person_id     IN   NUMBER,
      p_object_version_number   IN   NUMBER,
      p_start_date              IN   DATE
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_successor';
      l_api_updating   BOOLEAN;
      l_dummy          VARCHAR2 (1);

       --
      -- cursor to check duplication of ranking for the same successee
      CURSOR c1
      IS
         SELECT NULL
           FROM per_succession_planning per
          WHERE per.succession_plan_id <> NVL (p_succession_plan_id, -1)
            AND (   (p_position_id IS NOT NULL AND per.position_id = p_position_id)
                 OR (p_job_id IS NOT NULL AND per.job_id = p_job_id)
                 OR (    p_successee_person_id IS NOT NULL
                     AND per.successee_person_id = p_successee_person_id
                    )
                )
            AND per.person_rank = p_person_rank
            AND p_start_date BETWEEN NVL (per.start_date, hr_api.g_eot)
                                 AND NVL (per.end_date, hr_api.g_eot);

      -- cursor to check duplication of successors for the same successee
      CURSOR c2
      IS
         SELECT NULL
           FROM per_succession_planning per
          WHERE per.succession_plan_id <> NVL (p_succession_plan_id, -1)
            AND (   (p_position_id IS NOT NULL AND per.position_id = p_position_id)
                 OR (p_job_id IS NOT NULL AND per.job_id = p_job_id)
                 OR (    p_successee_person_id IS NOT NULL
                     AND per.successee_person_id = p_successee_person_id
                    )
                )
            AND per.person_id = p_person_id
            AND p_start_date BETWEEN NVL (per.start_date, hr_api.g_eot)
                                 AND NVL (per.end_date, hr_api.g_eot);
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_person_id, hr_api.g_number) <>
                                              NVL (per_suc_shd.g_old_rec.person_id, hr_api.g_number)
          OR NOT l_api_updating
         )
      THEN
         --

         --
         IF l_api_updating
         THEN
            --
            -- raise error as the person_id can not be updated.
            --
            hr_utility.set_message (801, 'HR_50497_SUC_CHK_SUC_UPDATE');
            hr_utility.raise_error;
         --
         END IF;

         -- CHK_SUCCESSOR_ID
         --
         chk_person_id (p_effective_date, p_succession_plan_id, p_person_id,
                        p_object_version_number);

         IF (p_person_id = NVL (p_successee_person_id, -1))
         THEN
            --
              -- raise error as successee and successor are the same person
              --
            hr_utility.set_message (800, 'HR_50498_SUC_CHK_SAME_PERSON');
            hr_utility.raise_error;
         END IF;

         IF (p_person_id = fnd_global.employee_id)
         THEN
            --
              -- raise error as login user cannot make himself a successor
              --
            hr_utility.set_message (800, 'HR_50499_SUC_CHK_LOGIN_USE');
            hr_utility.raise_error;
         END IF;

         -- check duplication of ranking for the same successee
         OPEN c1;

         FETCH c1
          INTO l_dummy;

         IF c1%FOUND
         THEN
            CLOSE c1;

            -- raise error as succession plan records overlap.
            --
            hr_utility.set_message (800, 'HR_33467_SUC_CHK_SAME_RANK');
            hr_utility.raise_error;
         --
         END IF;

         --
         CLOSE c1;

         -- check duplication of successors for the same successee
         OPEN c2;

         FETCH c2
          INTO l_dummy;

         IF c2%FOUND
         THEN
            CLOSE c2;

            -- raise error as succession plan records overlap.
            --
            hr_utility.set_message (800, 'HR_33468_SUC_SAME_SUCCESSOR');
            hr_utility.raise_error;
         --
         END IF;

         --
         CLOSE c2;
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_successor;

-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_time_scale >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the potential lookup falles within
--   the per_time_scales lookup.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   time_scale                         potential lookup.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--   effective_date                     effective date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal and External use.
--
   PROCEDURE chk_time_scale (
      p_succession_plan_id      IN   NUMBER,
      p_time_scale              IN   VARCHAR2,
      p_object_version_number   IN   NUMBER,
      p_effective_date          IN   DATE
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_time_scale';
      l_api_updating   BOOLEAN;
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      hr_utility.set_location ('p_effective_date:' || p_effective_date, 5);
      hr_utility.set_location ('p_time_scale:' || p_time_scale, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_time_scale, hr_api.g_varchar2) <>
                                           NVL (per_suc_shd.g_old_rec.time_scale, hr_api.g_varchar2)
          OR NOT l_api_updating
         )
      THEN
         --
         --
         -- check if value of time scale lookup falls within lookup.
         -- LOV name changed for bug 8478347
         IF     hr_api.not_exists_in_hr_lookups (p_lookup_type         => 'READINESS_LEVEL',
                                                 p_lookup_code         => p_time_scale,
                                                 p_effective_date      => p_effective_date
                                                )
            AND hr_api.not_exists_in_hr_lookups (p_lookup_type         => 'PER_TIME_SCALES',
                                                 p_lookup_code         => p_time_scale,
                                                 p_effective_date      => p_effective_date
                                                )
         THEN
            --
            -- raise error as does not exist as lookup
            --
            hr_utility.set_message (801, 'HR_52001_SUC_CHK_TIME_SCALE');
            hr_utility.raise_error;
         --
         END IF;
      --
      END IF;

      --
      hr_utility.set_location ('Leaving:' || l_proc, 10);
   --
   END chk_time_scale;

-- ----------------------------------------------------------------------------
-- |----------------------------< chk_start_date >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the start_date has been populated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   start_date                         start date of succession plan record.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_start_date (
      p_succession_plan_id      IN   NUMBER,
      p_start_date              IN   DATE,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_start_date';
      l_api_updating   BOOLEAN;
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_start_date, hr_api.g_date) <>
                                               NVL (per_suc_shd.g_old_rec.start_date, hr_api.g_date)
          OR NOT l_api_updating
         )
      THEN
         --
         -- check if start date is null
         --
         IF p_start_date IS NULL
         THEN
            --
            -- raise error as this a mandatory requirement
            --
            hr_utility.set_message (801, 'HR_52002_SUC_CHK_START_DATE');
            hr_utility.raise_error;
         --
         END IF;
      --
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_start_date;

-- ----------------------------------------------------------------------------
-- |----------------------------< chk_end_date >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the end date is later than the
--   start date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   start_date                         start date of succession plan record.
--   end_date                           end date of succession plan record.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_end_date (
      p_succession_plan_id      IN   NUMBER,
      p_start_date              IN   DATE,
      p_end_date                IN   DATE,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_end_date';
      l_api_updating   BOOLEAN;
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND (   NVL (p_start_date, hr_api.g_date) <>
                                               NVL (per_suc_shd.g_old_rec.start_date, hr_api.g_date)
                  OR NVL (p_end_date, hr_api.g_date) <>
                                                 NVL (per_suc_shd.g_old_rec.end_date, hr_api.g_date)
                 )
          OR NOT l_api_updating
         )
      THEN
         --
         -- check if end date is greater than start date
         --
         IF p_start_date > NVL (p_end_date, hr_api.g_eot)
         THEN
            --
            -- raise error as start date should be less than or equal to end date.
            --
            hr_utility.set_message (801, 'HR_52003_SUC_CHK_END_DATE');
            hr_utility.raise_error;
         --
         END IF;
      --
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_end_date;

-- ----------------------------------------------------------------------------
-- |----------------------< chk_available_for_promotion >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the available_for_promotion field
--   falls within the 'YES_NO' lookup.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   available_for_promotion            available_for_promotion lookup.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--   effective_date                     effective date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal and External use.
--
   PROCEDURE chk_available_for_promotion (
      p_succession_plan_id        IN   NUMBER,
      p_available_for_promotion   IN   VARCHAR2,
      p_object_version_number     IN   NUMBER,
      p_effective_date            IN   DATE
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_available_for_promotion';
      l_api_updating   BOOLEAN;
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_available_for_promotion, hr_api.g_varchar2) <>
                                                       per_suc_shd.g_old_rec.available_for_promotion
          OR NOT l_api_updating
         )
      THEN
         --
         -- check if value of available for promotion scale lookup falls within
         -- lookup.
         --
         IF p_available_for_promotion IS NOT NULL
         THEN
            --
            IF hr_api.not_exists_in_hr_lookups (p_lookup_type         => 'YES_NO',
                                                p_lookup_code         => p_available_for_promotion,
                                                p_effective_date      => p_effective_date
                                               )
            THEN
               --
               -- raise error as does not exist as lookup
               --
               per_suc_shd.constraint_error ('PER_SUC_AVAIL_FOR_PROMOTION');
            --
            END IF;
         --
         END IF;
      --
      END IF;

      --
      hr_utility.set_location ('Leaving:' || l_proc, 10);
   --
   END chk_available_for_promotion;

-- ----------------------------------------------------------------------------
-- |----------------------< chk_plan_status >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the plan_status field
--   falls within the 'SUCCESSION_PLAN_STATUS' lookup.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   plan_status                        plan_status lookup.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
--   effective_date                     effective date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal and External use.
--
   PROCEDURE chk_plan_status (
      p_succession_plan_id      IN   NUMBER,
      p_plan_status             IN   VARCHAR2,
      p_object_version_number   IN   NUMBER,
      p_effective_date          IN   DATE
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_plan_status';
      l_api_updating   BOOLEAN;
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_plan_status, hr_api.g_varchar2) <> per_suc_shd.g_old_rec.plan_status
          OR NOT l_api_updating
         )
      THEN
         --
         -- check if value of plan status lookup falls within
         -- lookup.
         --
         IF p_plan_status IS NOT NULL
         THEN
            --
            IF hr_api.not_exists_in_hr_lookups (p_lookup_type         => 'SUCCESSION_PLAN_STATUS',
                                                p_lookup_code         => p_plan_status,
                                                p_effective_date      => p_effective_date
                                               )
            THEN
               --
               -- raise error as does not exist as lookup
               --
            hr_utility.set_message (800, 'HR_51934_SUC_CHK_STATUS');
            hr_utility.raise_error;
            --
            END IF;
         --
         END IF;
      --
      END IF;

      --
      hr_utility.set_location ('Leaving:' || l_proc, 10);
   --
   END chk_plan_status;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_readiness_percentage >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the readiness_percentage is a number between
--   0 and 100.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   readiness_percentage               readiness_percentage being inserted.
--   object_version_number              Object version number of record being
--                                      inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_readiness_percentage (
      p_succession_plan_id      IN   NUMBER,
      p_readiness_percentage    IN   NUMBER,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_readiness_percentage';
      l_api_updating   BOOLEAN;
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND NVL (p_readiness_percentage, hr_api.g_number) <>
                                   NVL (per_suc_shd.g_old_rec.readiness_percentage, hr_api.g_number)
          OR NOT l_api_updating
         )
      THEN
         --
         -- check if the readiness_percentage is a number between 0 and 100.
         --
         IF (p_readiness_percentage > 100 OR p_readiness_percentage < 0)
         THEN
            --
            -- raise error as position does not exist as of effective date.
            --
            hr_utility.set_message (800, 'HR_51935_SUC_CHK_PERCENT');
            hr_utility.raise_error;
         END IF;
      --
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_readiness_percentage;

-- ----------------------------------------------------------------------------
-- |--------------------------< chk_person_start_date >------------------------|
-- ----------------------------------------------------------------------------
--
--- Bug#3207986 start
-- Description
--   This procedure is used to check that the earliest date entered is later
--   than the start date of the employee for the current position
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_person_id                        person_id of the person on which
--                                      the transaction is being done.
--   p_start_date                       the effective date entered
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal and External use.
--
------------------------------------------------------------------------
   PROCEDURE chk_person_start_date (
      p_person_id    per_people_f.person_id%TYPE,
      p_start_date   per_assignments_f.effective_start_date%TYPE
   )
   IS
      l_curr_position_id   hr_positions.position_id%TYPE;

      CURSOR person_start_details (
         p_person_id    per_people_f.person_id%TYPE,
         p_start_date   per_assignments_f.effective_start_date%TYPE
      )
      IS
         SELECT paf.position_id
           FROM per_assignments_f paf
          WHERE paf.person_id = p_person_id
            AND (SYSDATE BETWEEN paf.effective_start_date AND NVL (paf.effective_end_date, SYSDATE)
                )
            AND paf.effective_start_date <= p_start_date;
   BEGIN
      OPEN person_start_details (p_person_id => p_person_id, p_start_date => p_start_date);

      FETCH person_start_details
       INTO l_curr_position_id;

      IF (person_start_details%NOTFOUND)
      THEN
         CLOSE person_start_details;

         hr_utility.set_message (801, 'HR_52005_SUC_CHK_DATE');
         hr_utility.raise_error;
      ELSE
         CLOSE person_start_details;
      END IF;
   END;

--- Bug#3207986 end
------------------------------------------------------------------------------

   -- ----------------------------------------------------------------------------
-- |----------------------------< chk_date >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the record being inserted or
--   updated is unique.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   person_id                          id of person being inserted.
--   position_id                        id of position being inserted.
--   start_date                         start date of succession plan record
--   end_date                           end date of succession plan record
--   object_version_number              Object version number of record being
--                                      inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal and External use.
   PROCEDURE chk_date (
      p_succession_plan_id      IN   NUMBER,
      p_position_id             IN   NUMBER,
      p_person_id               IN   NUMBER,
      p_start_date              IN   DATE,
      p_end_date                IN   DATE,
      p_object_version_number   IN   NUMBER,
      p_job_id                  IN   NUMBER,
      p_successee_person_id     IN   NUMBER
   )
   IS
      --
      l_proc           VARCHAR2 (72) := g_package || 'chk_date';
      l_api_updating   BOOLEAN;
      l_dummy          VARCHAR2 (1);

      --
      CURSOR c1
      IS
         SELECT NULL
           FROM per_succession_planning per
          WHERE per.person_id = p_person_id
            AND per.succession_plan_id <> NVL (p_succession_plan_id, -1)
            AND (   (p_position_id IS NOT NULL AND per.position_id = p_position_id)
                 OR (p_job_id IS NOT NULL AND per.job_id = p_job_id)
                 OR (    p_successee_person_id IS NOT NULL
                     AND per.successee_person_id = p_successee_person_id
                    )
                )
            AND (   per.start_date BETWEEN p_start_date AND NVL (p_end_date, hr_api.g_eot)
                 OR NVL (per.end_date, hr_api.g_eot) BETWEEN p_start_date
                                                         AND NVL (p_end_date, hr_api.g_eot)
                );
   --
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      l_api_updating             :=
         per_suc_shd.api_updating (p_succession_plan_id         => p_succession_plan_id,
                                   p_object_version_number      => p_object_version_number
                                  );

      --
      IF (       l_api_updating
             AND (   NVL (p_start_date, hr_api.g_date) <>
                                               NVL (per_suc_shd.g_old_rec.start_date, hr_api.g_date)
                  OR NVL (p_end_date, hr_api.g_date) <>
                                                 NVL (per_suc_shd.g_old_rec.end_date, hr_api.g_date)
                 )
          OR NOT l_api_updating
         )
      THEN
         --
         -- check if succession plans overlap
         --
         OPEN c1;

         --
         FETCH c1
          INTO l_dummy;

         --
         IF c1%FOUND
         THEN
            --
            CLOSE c1;

            --
            -- raise error as succession plan records overlap.
            --
            per_suc_shd.constraint_error ('PER_SUCCESSION_PLANNING_UK');
         --
         END IF;

         --
         CLOSE c1;
      --
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   --
   END chk_date;

--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
   PROCEDURE chk_df (p_rec IN per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'chk_df';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);

      --
      IF    (    (p_rec.succession_plan_id IS NOT NULL)
             AND (   NVL (per_suc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
                                                   NVL (p_rec.attribute_category, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute1, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute2, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute3, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute4, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute5, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute6, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute7, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute8, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
                                                           NVL (p_rec.attribute9, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute10, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute11, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute12, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute13, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute14, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute15, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute16, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute17, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute18, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute19, hr_api.g_varchar2)
                  OR NVL (per_suc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
                                                          NVL (p_rec.attribute20, hr_api.g_varchar2)
                 )
            )
         OR (p_rec.succession_plan_id IS NULL)
      THEN
         --
         -- Only execute the validation if absolutely necessary:
         -- a) During update, the structure column value or any
         --    of the attribute values have actually changed.
         -- b) During insert.
         --
         hr_dflex_utility.ins_or_upd_descflex_attribs
                                                 (p_appl_short_name         => 'PER',
                                                  p_descflex_name           => 'PER_SUCCESSION_PLANNING',
                                                  p_attribute_category      => p_rec.attribute_category,
                                                  p_attribute1_name         => 'ATTRIBUTE1',
                                                  p_attribute1_value        => p_rec.attribute1,
                                                  p_attribute2_name         => 'ATTRIBUTE2',
                                                  p_attribute2_value        => p_rec.attribute2,
                                                  p_attribute3_name         => 'ATTRIBUTE3',
                                                  p_attribute3_value        => p_rec.attribute3,
                                                  p_attribute4_name         => 'ATTRIBUTE4',
                                                  p_attribute4_value        => p_rec.attribute4,
                                                  p_attribute5_name         => 'ATTRIBUTE5',
                                                  p_attribute5_value        => p_rec.attribute5,
                                                  p_attribute6_name         => 'ATTRIBUTE6',
                                                  p_attribute6_value        => p_rec.attribute6,
                                                  p_attribute7_name         => 'ATTRIBUTE7',
                                                  p_attribute7_value        => p_rec.attribute7,
                                                  p_attribute8_name         => 'ATTRIBUTE8',
                                                  p_attribute8_value        => p_rec.attribute8,
                                                  p_attribute9_name         => 'ATTRIBUTE9',
                                                  p_attribute9_value        => p_rec.attribute9,
                                                  p_attribute10_name        => 'ATTRIBUTE10',
                                                  p_attribute10_value       => p_rec.attribute10,
                                                  p_attribute11_name        => 'ATTRIBUTE11',
                                                  p_attribute11_value       => p_rec.attribute11,
                                                  p_attribute12_name        => 'ATTRIBUTE12',
                                                  p_attribute12_value       => p_rec.attribute12,
                                                  p_attribute13_name        => 'ATTRIBUTE13',
                                                  p_attribute13_value       => p_rec.attribute13,
                                                  p_attribute14_name        => 'ATTRIBUTE14',
                                                  p_attribute14_value       => p_rec.attribute14,
                                                  p_attribute15_name        => 'ATTRIBUTE15',
                                                  p_attribute15_value       => p_rec.attribute15,
                                                  p_attribute16_name        => 'ATTRIBUTE16',
                                                  p_attribute16_value       => p_rec.attribute16,
                                                  p_attribute17_name        => 'ATTRIBUTE17',
                                                  p_attribute17_value       => p_rec.attribute17,
                                                  p_attribute18_name        => 'ATTRIBUTE18',
                                                  p_attribute18_value       => p_rec.attribute18,
                                                  p_attribute19_name        => 'ATTRIBUTE19',
                                                  p_attribute19_value       => p_rec.attribute19,
                                                  p_attribute20_name        => 'ATTRIBUTE20',
                                                  p_attribute20_value       => p_rec.attribute20
                                                 );
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 20);
   END chk_df;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE insert_validate (p_rec IN per_suc_shd.g_rec_type, p_effective_date IN DATE)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'insert_validate';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      hr_api.validate_bus_grp_id (p_rec.business_group_id);                     -- Validate Bus Grp
--
-- Call all supporting business operations
--
-- Business Rule Mapping
-- =====================
-- CHK_SUCCESSION_PLANN_ID
--
      chk_succession_plan_id (p_rec.succession_plan_id, p_rec.object_version_number);
--
-- Business Rule Mapping
-- =====================
-- CHK_PERSON_ID
--
      chk_successor (p_effective_date,
                     p_rec.succession_plan_id,
                     p_rec.person_id,
                     p_rec.job_id,
                     p_rec.position_id,
                     p_rec.person_rank,
                     p_rec.successee_person_id,
                     p_rec.object_version_number,
                     p_rec.start_date
                    );
--
-- Business Rule Mapping
-- =====================
-- CHK_SUCCESSEE
--
      chk_successee (p_effective_date,
                     p_rec.succession_plan_id,
                     p_rec.job_id,
                     p_rec.position_id,
                     p_rec.successee_person_id,
                     p_rec.object_version_number
                    );
--
-- Business Rule Mapping
-- =====================
-- CHK_TIME_SCALE
--
      chk_time_scale (p_rec.succession_plan_id,
                      p_rec.time_scale,
                      p_rec.object_version_number,
                      p_effective_date
                     );
--
-- Business Rule Mapping
-- =====================
-- CHK_START_DATE
--
      chk_start_date (p_rec.succession_plan_id, p_rec.start_date, p_rec.object_version_number);
--
-- Business Rule Mapping
-- =====================
-- CHK_END_DATE
--
      chk_end_date (p_rec.succession_plan_id,
                    p_rec.start_date,
                    p_rec.end_date,
                    p_rec.object_version_number
                   );
--
-- Business Rule Mapping
-- =====================
-- CHK_AVAILABLE_FOR_PROMOTION
--
      chk_available_for_promotion (p_rec.succession_plan_id,
                                   p_rec.available_for_promotion,
                                   p_rec.object_version_number,
                                   p_effective_date
                                  );
--
-- Business Rule Mapping
-- =====================
-- CHK_PLAN_STATUS
--
      chk_plan_status (p_rec.succession_plan_id,
                       p_rec.plan_status,
                       p_rec.object_version_number,
                       p_effective_date
                      );
--
-- Business Rule Mapping
-- =====================
-- CHK_READINESS_PERCENTAGE
--
      chk_readiness_percentage(p_rec.succession_plan_id,
                               p_rec.readiness_percentage,
                               p_rec.object_version_number
                              );
--
-- Business Rule Mapping
-- =====================
-- CHK_PERSON_START_DATE
--
-- Bug#3207986
      chk_person_start_date (p_rec.person_id, p_rec.start_date);
--
-- Business Rule Mapping
-- =====================
-- CHK_DATE
--
      chk_date (p_rec.succession_plan_id,
                p_rec.position_id,
                p_rec.person_id,
                p_rec.start_date,
                p_rec.end_date,
                p_rec.object_version_number,
                p_rec.job_id,
                p_rec.successee_person_id
               );
  --
  -- Descriptive flex check
  -- ======================
  --
/*
  IF hr_general.get_calling_context <>'FORMS' THEN
    per_suc_flex.df(p_rec => p_rec);
  END IF;
*/
  --
  -- call descriptive flexfield validation routines
  --
      per_suc_bus.chk_df (p_rec => p_rec);
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END insert_validate;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE update_validate (p_rec IN per_suc_shd.g_rec_type, p_effective_date IN DATE)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'update_validate';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      hr_api.validate_bus_grp_id (p_rec.business_group_id);                     -- Validate Bus Grp
--
-- Call all supporting business operations
--
-- Business Rule Mapping
-- =====================
-- CHK_SUCCESSION_PLANN_ID
--
      chk_succession_plan_id (p_rec.succession_plan_id, p_rec.object_version_number);
--
-- Business Rule Mapping
-- =====================
-- CHK_PERSON_ID
--
      chk_successor (p_effective_date,
                     p_rec.succession_plan_id,
                     p_rec.person_id,
                     p_rec.job_id,
                     p_rec.position_id,
                     p_rec.person_rank,
                     p_rec.successee_person_id,
                     p_rec.object_version_number,
                     p_rec.start_date
                    );
--
-- Business Rule Mapping
-- =====================
-- CHK_SUCCESSEE
--
      chk_successee (p_effective_date,
                     p_rec.succession_plan_id,
                     p_rec.job_id,
                     p_rec.position_id,
                     p_rec.successee_person_id,
                     p_rec.object_version_number
                    );
--
--
--
-- Business Rule Mapping
-- =====================
-- CHK_TIME_SCALE
--
      chk_time_scale (p_rec.succession_plan_id,
                      p_rec.time_scale,
                      p_rec.object_version_number,
                      p_effective_date
                     );
--
-- Business Rule Mapping
-- =====================
-- CHK_START_DATE
--
      chk_start_date (p_rec.succession_plan_id, p_rec.start_date, p_rec.object_version_number);
--
-- Business Rule Mapping
-- =====================
-- CHK_END_DATE
--
      chk_end_date (p_rec.succession_plan_id,
                    p_rec.start_date,
                    p_rec.end_date,
                    p_rec.object_version_number
                   );
--
-- Business Rule Mapping
-- =====================
-- CHK_AVAILABLE_FOR_PROMOTION
--
      chk_available_for_promotion (p_rec.succession_plan_id,
                                   p_rec.available_for_promotion,
                                   p_rec.object_version_number,
                                   p_effective_date
                                  );
--
-- Business Rule Mapping
-- =====================
-- CHK_PLAN_STATUS
--
      chk_plan_status (p_rec.succession_plan_id,
                       p_rec.plan_status,
                       p_rec.object_version_number,
                       p_effective_date
                      );
--
-- Business Rule Mapping
-- =====================
-- CHK_READINESS_PERCENTAGE
--
      chk_readiness_percentage(p_rec.succession_plan_id,
                               p_rec.readiness_percentage,
                               p_rec.object_version_number
                              );
--
-- Business Rule Mapping
-- =====================
-- CHK_PERSON_START_DATE
--
-- Bug#3207986
      chk_person_start_date (p_rec.person_id, p_rec.start_date);
--
-- Business Rule Mapping
-- =====================
-- CHK_DATE
--
      chk_date (p_rec.succession_plan_id,
                p_rec.position_id,
                p_rec.person_id,
                p_rec.start_date,
                p_rec.end_date,
                p_rec.object_version_number,
                p_rec.job_id,
                p_rec.successee_person_id
               );
  --
  -- Descriptive flex check
  -- ======================
  --
/*
  IF hr_general.get_calling_context <>'FORMS' THEN
    per_suc_flex.df(p_rec => p_rec);
  END IF;
*/
  --
  -- call descriptive flexfield validation routines
  --
      per_suc_bus.chk_df (p_rec => p_rec);
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END update_validate;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE delete_validate (p_rec IN per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'delete_validate';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- Call all supporting business operations
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END delete_validate;
--
END per_suc_bus;

/
