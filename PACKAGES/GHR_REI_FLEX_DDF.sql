--------------------------------------------------------
--  DDL for Package GHR_REI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_REI_FLEX_DDF" AUTHID CURRENT_USER as
/* $Header: ghreiddf.pkh 120.0.12010000.3 2009/05/26 12:03:21 utokachi noship $ */
-- -----------------------------------------------------------------------------
-- |-------------------------------< ddf >--------------------------------------|
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
procedure ddf
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
end ghr_rei_flex_ddf;

/
