--------------------------------------------------------
--  DDL for Package PER_SUC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUC_BUS" AUTHID CURRENT_USER AS
/* $Header: pesucrhi.pkh 120.1.12010000.3 2010/02/13 19:33:43 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_succession_plan_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_succession_plan_id (
      p_succession_plan_id      IN   NUMBER,
      p_object_version_number   IN   NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_person_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description
--   This procedure is used to check that the person_id exists as of the
--   effective date.
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_person_id (
      p_effective_date          IN   DATE,
      p_succession_plan_id      IN   NUMBER,
      p_person_id               IN   NUMBER,
      p_object_version_number   IN   NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_position_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_position_id (
      p_effective_date          IN   DATE,
      p_succession_plan_id      IN   NUMBER,
      p_position_id             IN   NUMBER,
      p_object_version_number   IN   NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_successee >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description
--   This procedure is used to check that the successee_id(job_id or position_id
--   or successe_person_id) exists as of effective date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   effective_date                     effective date
--   succession_plan_id                 PK of record being inserted or updated.
--   job_id                             id of job being inserted.
--   position_id                        id of position being inserted.
--   successe_person_id                 id of successee person being inserted.
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_successee (
      p_effective_date          IN   DATE,
      p_succession_plan_id      IN   NUMBER,
      p_job_id                  IN   NUMBER,
      p_position_id             IN   NUMBER,
      p_successee_person_id     IN   NUMBER,
      p_object_version_number   IN   NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_time_scale >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description
--   This procedure is used to check that the time_scale lookup falles within
--   the per_time_scales lookup.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   succession_plan_id                 PK of record being inserted or updated.
--   time_scale                         time_scale lookup.
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_time_scale (
      p_succession_plan_id      IN   NUMBER,
      p_time_scale              IN   VARCHAR2,
      p_object_version_number   IN   NUMBER,
      p_effective_date          IN   DATE
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_start_date >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_start_date (
      p_succession_plan_id      IN   NUMBER,
      p_start_date              IN   DATE,
      p_object_version_number   IN   NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_end_date >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_end_date (
      p_succession_plan_id      IN   NUMBER,
      p_start_date              IN   DATE,
      p_end_date                IN   DATE,
      p_object_version_number   IN   NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_available_for_promotion >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_available_for_promotion (
      p_succession_plan_id        IN   NUMBER,
      p_available_for_promotion   IN   VARCHAR2,
      p_object_version_number     IN   NUMBER,
      p_effective_date            IN   DATE
   );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_date >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_date (
      p_succession_plan_id      IN   NUMBER,
      p_position_id             IN   NUMBER,
      p_person_id               IN   NUMBER,
      p_start_date              IN   DATE,
      p_end_date                IN   DATE,
      p_object_version_number   IN   NUMBER,
      p_job_id                  IN   NUMBER,
      p_successee_person_id     IN   NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE insert_validate (p_rec IN per_suc_shd.g_rec_type, p_effective_date IN DATE);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE update_validate (p_rec IN per_suc_shd.g_rec_type, p_effective_date IN DATE);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE delete_validate (p_rec IN per_suc_shd.g_rec_type);

--

   ---- Bug#3207986 start
   PROCEDURE chk_person_start_date (
      p_person_id    per_people_f.person_id%TYPE,
      p_start_date   per_assignments_f.effective_start_date%TYPE
   );
---- Bug#3207986 end
END per_suc_bus;

/
