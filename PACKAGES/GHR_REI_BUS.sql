--------------------------------------------------------
--  DDL for Package GHR_REI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_REI_BUS" AUTHID CURRENT_USER as
/* $Header: ghreirhi.pkh 120.1.12010000.1 2008/07/28 10:38:38 appldev ship $ */
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ghr_rei_shd.g_rec_type);
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ghr_rei_shd.g_rec_type);
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_rei_shd.g_rec_type);
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< chk_ddf_extra_val >--------------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    developer descriptive flexfields by calling the relevant validation
--    procedures. These are called dependant on the value of the relevant
--    entity reference field value.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Arguments:
--    p_rec (Record structure for relevant entity).
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    A failure can only occur under two circumstances:
--    1) The value of reference field is not supported.
--    2) If when the refence field value is null and not all
--       the attribute arguments are not null(i.e. attribute
--       arguments cannot be set without a corresponding reference
--       field value).
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure chk_ddf_extra_val
  (p_rec   in ghr_rei_shd.g_rec_type
  );
--
-- -----------------------------------------------------------------------------------------
-- |--------------------------< chk_reason_for_submission >--------------------------------|
-- -----------------------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure validates the descriptive flexfield containing the information about reason
--    for submission. An error message is returned if this validation fails.
--
--  Pre Conditions:
--    None.
--
--  In Arguments:
--    p_pa_request_extra_info_id
--    p_reason_for_submission
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    Processing stops and error raised.
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
--
procedure chk_reason_for_submission
  (p_pa_request_extra_info_id    in  ghr_pa_request_extra_info.pa_request_extra_info_id%TYPE
  ,p_reason_for_submission       in  ghr_pa_request_extra_info.rei_information3%TYPE
  ,p_effective_date              in  date
  ,p_object_version_number       in  number
  );

-- -----------------------------------------------------------------------------------------
-- |-----------------------------------< chk_explanation >---------------------------------|
-- -----------------------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure validates the descriptive flexfield containing the information about
--    explanation. An error message is returned if this validation fails.
--
--  Pre Conditions:
--    None.
--
--  In Arguments:
--    p_reason_for_sbmission
--    p_pa_request_extra_info_id
--    p_explanation
--    p_object_version_number
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    Processing stops and error raised.
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
--
procedure chk_explanation
  (p_reason_for_submission       in  ghr_pa_request_extra_info.rei_information3%TYPE
  ,p_pa_request_extra_info_id    in  ghr_pa_request_extra_info.pa_request_extra_info_id%TYPE
  ,p_explanation                 in  ghr_pa_request_extra_info.rei_information4%TYPE
  ,p_object_version_number       in  number
  );
--
-- -----------------------------------------------------------------------------------------
-- |-----------------------------------< chk_service>--------------------------------------|
-- -----------------------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure validates the descriptive flexfield containing the information about service.
--    An error message is returned if this validation fails.
--
--  Pre Conditions:
--    None.
--
--  In Arguments:
--    p_pa_request_extra_info_id
--    p_service
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    Processing stops and error raised.
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
--

procedure chk_service
  (p_pa_request_extra_info_id    in  ghr_pa_request_extra_info.pa_request_extra_info_id%TYPE
  ,p_service                     in  ghr_pa_request_extra_info.rei_information5%TYPE
  ,p_effective_date              in  date
  ,p_object_version_number       in  number
  );
end ghr_rei_bus;

/
