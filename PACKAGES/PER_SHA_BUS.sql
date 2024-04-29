--------------------------------------------------------
--  DDL for Package PER_SHA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SHA_BUS" AUTHID CURRENT_USER as
/* $Header: pesharhi.pkh 120.0 2005/05/31 21:03:59 appldev noship $ */
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_non_updateable_args >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--    Ensure that no updateable arguments are not being updated
--
--  Pre-conditions :
--    None
--
--  In Arguments :
--    p_rec
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_non_updateable_args
  (p_rec              in    per_sha_shd.g_rec_type);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_date_not_taken >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--    DATE_NOT_TAKEN is mandatory
--    DATE_NOT_TAKEN cannot be updated if the ACTUAL_DATE_TAKEN is not NULL
--
--  Pre-conditions :
--    Format for date_not_taken must be correct
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_date_not_taken
--    p_actual_date_taken
--    p_expired
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_date_not_taken
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_date_not_taken          in	per_std_holiday_absences.date_not_taken%TYPE
  ,p_actual_date_taken	     in	per_std_holiday_absences.actual_date_taken%TYPE
  ,p_expired      	     in	per_std_holiday_absences.expired%TYPE
  ,p_object_version_number   in per_std_holiday_absences.object_version_number%TYPE
    );
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_person_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--    PERSON_ID is mandatory
--    PERSON_ID must exist in PER_PEOPLE_F for the date_of the holiday,
--     DATE_NOT_TAKEN
--
--  Pre-conditions :
--    None
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_person_id
--    p_date_not_taken
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_person_id
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_person_id   	     in	per_std_holiday_absences.person_id%TYPE
  ,p_date_not_taken          in	per_std_holiday_absences.date_not_taken%TYPE
    );
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_standard_holiday_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--    STANDARD_HOLIDAY_ID is mandatory
--    STANDARD_HOLIDAY_ID must exist in PER_STANDARD_HOLIDAYS
--
--  Pre-conditions :
--    None
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_standard_holiday_id
--    p_actual_date_taken
--    p_expired
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_standard_holiday_id
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_standard_holiday_id     in	per_std_holiday_absences.standard_holiday_id%TYPE
  ,p_actual_date_taken	     in	per_std_holiday_absences.actual_date_taken%TYPE
  ,p_expired                 in	per_std_holiday_absences.expired%TYPE
  ,p_object_version_number   in per_std_holiday_absences.object_version_number%TYPE
    );
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_actual_date_taken >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--    ACTUAL_DATE_TAKEN must not overlap with any of the Standard Holidays
--    defined for the current Legislation/Sub-legislation
--
--  Pre-conditions :
--    None
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_actual_date_taken
--    p_person_id
--    p_expired
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_actual_date_taken
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_actual_date_taken	     in	per_std_holiday_absences.actual_date_taken%TYPE
  ,p_person_id       	     in	per_std_holiday_absences.person_id%TYPE
  ,p_expired        	     in	per_std_holiday_absences.expired%TYPE
  ,p_object_version_number   in per_std_holiday_absences.object_version_number%TYPE
    );
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_expired >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--    EXPIRED cannot be entered if the ACTUAL_DATE_TAKEN is not NULL
--
--  Pre-conditions :
--    This must be either 'Y' or 'N'
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_expired
--    p_actual_date_taken
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_expired
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_expired                 in	per_std_holiday_absences.expired%TYPE
  ,p_actual_date_taken	     in	per_std_holiday_absences.actual_date_taken%TYPE
  ,p_object_version_number   in per_std_holiday_absences.object_version_number%TYPE
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
Procedure insert_validate(p_rec in per_sha_shd.g_rec_type);
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
Procedure update_validate(p_rec in per_sha_shd.g_rec_type);
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
Procedure delete_validate(p_rec in per_sha_shd.g_rec_type);
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific person
--
--  Prerequisites:
--    The person identified by p_person_id already exists.
--
--  In Arguments:
--    p_person_id
--
--  Post Success:
--    If the person is found this function will return the person's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the person does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_std_holiday_absences_id             in number
  ) return varchar2;
--
end per_sha_bus;

 

/
