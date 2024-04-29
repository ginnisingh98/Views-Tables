--------------------------------------------------------
--  DDL for Package PER_PRV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PRV_BUS" AUTHID CURRENT_USER as
/* $Header: peprvrhi.pkh 120.0 2005/05/31 15:13:38 appldev noship $ */
--
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
-- g_legislation_code       varchar2(150) default null;
-- g_performance_review_id  number        default null;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id_date >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the person is an employee on the given date
--   and that the date is not a duplicate
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_performance_review_id
--     the performance review primary key
--   p_person_id
--     the person's id
--   p_review_date
--     the date of the performance review
--   p_object_version_number
--     the object version number
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
Procedure chk_person_id_date(p_performance_review_id in number
                            ,p_object_version_number in number
                            ,p_person_id             in number
                            ,p_review_date           in date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_next_perf_review_date >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the next performance review date is after the
--   current performance review date, and that the person exists as an
--   employee on that date
--
-- Pre-Conditions
--   review_date and person_id should have been validated
--
-- In Parameters
--   p_performance_review_id
--     the performance review primary key
--   p_next_perf_review_date
--     the date of the next performance review
--   p_person_id
--     the person's id
--   p_review_date
--     the date of the performance review
--   p_object_version_number
--     the object version number

--
-- Post Success
--   Processing continues
--
-- Post Failure
--   if the next date is before or on the current date, the
--   p_next_review_date_warning flag is set to true
--   if the person doesn't exist on the next date, an error is raised.

-- Access Status
--   Internal table handler use only.
--
Procedure chk_next_perf_review_date(p_performance_review_id in     number
                                   ,p_object_version_number in     number
                                   ,p_review_date           in     date
                                   ,p_next_perf_review_date in     date
                                   ,p_person_id             in     number
                                   ,p_next_review_date_warning out nocopy boolean);

--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_get_next_perf_review_date >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure gets the next performance review date if the assignment_id
--   is not null, and the review date has changed.
--
-- Pre-Conditions
--   review_date should have been validated
--
-- In Parameters
--   p_performance_review_id
--     the performance review primary key
--   p_next_perf_review_date
--     the date of the next performance review
--   p_assignment_id
--     the assignment id
--   p_review_date
--     the date of the performance review
--   p_object_version_number
--     the object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
---
-- Access Status
--   Internal table handler use only.
--
Procedure chk_get_next_perf_review_date(p_performance_review_id in     number
                                       ,p_object_version_number in     number
                                       ,p_review_date           in     date
                                       ,p_next_perf_review_date in out nocopy date
                                       ,p_assignment_id         in     number);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete_performance_review>-------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the performance review can be
--   deleted, i.e. that it is not associated with a salary proposal
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   performance_review_id PK of record being inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_delete_performance_review(p_performance_review_id in number);
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
Procedure insert_validate(p_rec in per_prv_shd.g_rec_type
                         ,p_next_review_date_warning out nocopy boolean);
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
Procedure update_validate(p_rec in per_prv_shd.g_rec_type
                         ,p_next_review_date_warning out nocopy boolean);
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
Procedure delete_validate(p_rec in per_prv_shd.g_rec_type);
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure returns the business group id of the parent row.
--
-- Pre Conditions:
--   That the performance review row has been created.
--
-- In Parameters:
--   Primary key for the per_performance_reviews table.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised.
--
-- Developer Implementation Notes:
--   This return_legislation_code function is slightly different from others in
--   that the cursor does a join on the parent table (in this case the parent
--   table is always PER_ALL_PEOPLE_F and retrieves the business_group_id from
--   there.
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_performance_review_id          in number
   ) return varchar2;
--
end per_prv_bus;

 

/
