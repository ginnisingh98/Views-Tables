--------------------------------------------------------
--  DDL for Package OTA_TRNG_PLAN_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRNG_PLAN_UTIL_SS" AUTHID CURRENT_USER as
/* $Header: ottpswrs.pkh 115.8 2004/04/01 19:18:39 cmora noship $ */

-- global variable
   g_is_per_trng_plan     boolean := false;

-- ---------------------------------------------------------------------------
-- |----------------------< is_personal_trng_plan >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks whether this is a Personal Training Plan
--
--  Prerequisites:
--
--
--  In Arguments:
--  None
--
--  Post Success:
--    'TRUE' is returned for Personal Training Plan
--    'FALSE' is returned for Organization Training Plan
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

FUNCTION is_personal_trng_plan
RETURN BOOLEAN;


-- ---------------------------------------------------------------------------
-- |----------------------< is_personal_trng_plan >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks whether this is a Personal Training Plan
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_training_plan_id
--
--
--  Post Success:
--    'TRUE' is returned for Personal Training Plan
--    'FALSE' is returned for Organization Training Plan
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

FUNCTION is_personal_trng_plan ( p_training_plan_id IN ota_training_plans.training_plan_id%TYPE)
RETURN BOOLEAN;

--  ---------------------------------------------------------------------------
--  |----------------------< chk_cancel_plan_ok >--------------------------|
--  ---------------------------------------------------------------------------
--
Function chk_cancel_plan_ok(p_training_plan_id in ota_training_plans.training_plan_id%type)
return varchar2;
--  ---------------------------------------------------------------------------
--  |----------------------< chk_complete_plan_ok >--------------------------|
--  ---------------------------------------------------------------------------
--

Function chk_complete_plan_ok(p_training_plan_id in ota_training_plans.training_plan_id%type)
return varchar2;
-- ---------------------------------------------------------------------------
-- |----------------------< get_enroll_status >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the enrollment status of the event in the order A P W R Z
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_training_plan_member_id
--    p_person_id
--
--
--  Post Success:
--    Enrollment status is returned to calling unit
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------


FUNCTION get_enroll_status(p_person_id               IN ota_training_plans.person_id%TYPE,
							-- Modified for Bug#3479186
						       p_contact_id IN ota_training_plans.contact_id%TYPE,
                           p_training_plan_member_id IN ota_training_plan_members.training_plan_member_id%TYPE)
RETURN VARCHAR2;

-- ---------------------------------------------------------------------------
-- |----------------------< chk_login_person >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks whether the login person is Manager or employee
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_training_plan_id
--
--
--  Post Success:
--    'M' is returned for Manager
--    'E' is returned for employee
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

FUNCTION chk_login_person ( p_training_plan_id IN ota_training_plans.training_plan_id%TYPE)
RETURN VARCHAR2;

-- ---------------------------------------------------------------------------
-- |----------------------< chk_src_func_tlntmgt >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    checks if plan_source of type TALENT MANAGMENT already exists for the
--  Training plan member being added (based on it's dates)
--
--  Prerequisites:
--
--  In Arguments:
--    p_person_id
--    p_earliest_start_date
--    p_target_completion_date
--    p_business_group_id
--
--  Post Success:
--   returns the required training plan id number
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

FUNCTION chk_src_func_tlntmgt(p_person_id               IN ota_training_plans.person_id%TYPE,
                              p_earliest_start_date     IN ota_training_plan_members.earliest_start_date%TYPE,
                              p_target_completion_date  IN ota_training_plan_members.target_completion_date%TYPE,
                              --Added for Bug#3108246
                              p_business_group_id       IN number)
RETURN number ;

-- ---------------------------------------------------------------------------
-- |----------------------< chk_valid_act_version_dates >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    checks when the activity dates are changed there are no training plan members getting affected
-- called from ota_tav_bus.update_validate
--  Prerequisites:
--
--
--  In Arguments:
--    p_activity_version_id
--    p_start_date
--    p_end_date
--
--  Post Success:
--    Activity dates are allowed to be changed
--
--  Post Failure:
--    Error is thrown
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE chk_valid_act_version_dates (p_activity_version_id IN ota_activity_versions.activity_version_id%TYPE,
                                       p_start_date          IN ota_activity_versions.start_date%TYPE,
                                       p_end_date            IN ota_activity_versions.end_date%TYPE DEFAULT NULL);

-- ---------------------------------------------------------------------------
-- |----------------------< chk_enrollment_exist >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks if there are any enrollments for the person
-- for the training plan member
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_person_id
--    p_training_plan_member_id
--
--  Post Success:
--    Enrollment icon is either enabled or disabled
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION chk_enrollment_exist ( p_person_id               IN ota_training_plans.person_id%TYPE,
								-- Modified for Bug#3479186
							        p_contact_id IN ota_training_plans.contact_id%TYPE,
                                p_training_plan_member_id IN ota_training_plan_members.training_plan_member_id%TYPE)
RETURN boolean;

-- ---------------------------------------------------------------------------
-- |----------------------< get_enroll_status >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the enrollment status of the event in the order A P W R Z
-- Overloaded function.Called while creating a TPC with member_status_TYPE_ID
-- 'OTA_PLANNED' to determine the exact ststus of TPC based on enrollments falling under it
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_earliest_start_date
--    p_target_completion_date
--    p_person_id
--    p_training_plan_id
--    p_action
--
--
--  Post Success:
--    Enrollment status is returned to calling unit
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

FUNCTION get_enroll_status(p_person_id IN ota_training_plans.person_id%TYPE,
			-- Modified for Bug#3479186
			   p_contact_id IN ota_training_plans.contact_id%TYPE,
                           p_earliest_start_date IN ota_training_plan_members.earliest_start_date%TYPE,
                           p_target_completion_date IN ota_training_plan_members.target_completion_date%TYPE,
                           p_activity_version_id IN ota_training_plan_members.activity_version_id%TYPE,
                           p_training_plan_id   IN ota_training_plans.training_plan_id%TYPE,
                           p_action IN VARCHAR2)
RETURN varchar2 ;

-- ---------------------------------------------------------------------------
-- |----------------------< modify_tpc_status_on_create >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_type_id
-- Called while creating a TPC with member_status_TYPE_ID
-- 'OTA_PLANNED' to determine the exact ststus of TPC based on enrollments falling under it
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_earliest_start_date
--    p_target_completion_date
--    p_person_id
--    p_activity_version_id
--    p_training_plan_id
--
--
--  Post Success:
--    Member status is returned to calling unit
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE modify_tpc_status_on_create(--p_person_id               IN ota_training_plans.person_id%TYPE,
											-- Modified for Bug#3479186
                                      p_earliest_start_date     IN ota_training_plan_members.earliest_start_date%TYPE,
                                      p_target_completion_date  IN ota_training_plan_members.target_completion_date%TYPE,
                                      p_activity_version_id     IN ota_activity_versions.activity_version_id%TYPE,
                                      p_training_plan_id        IN ota_training_plans.training_plan_id%TYPE,
                                      p_member_status_id        OUT nocopy VARCHAR2);

-- ---------------------------------------------------------------------------
-- |----------------------< modify_tpc_status_on_update >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_type_id
-- Called while creating a TPC with member_status_TYPE_ID
-- not equal 'OTA_CANCELLED' to determine the exact ststus of TPC based on enrollments falling under it
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_earliest_start_date
--    p_target_completion_date
--    p_person_id
--    p_activity_version_id
--    p_training_plan_id
--
--
--  Post Success:
--    Member status is returned to calling unit
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE modify_tpc_status_on_update(--p_person_id               IN ota_training_plans.person_id%TYPE,
											-- Modified for Bug#3479186
                                      p_earliest_start_date     IN ota_training_plan_members.earliest_start_date%TYPE,
                                      p_target_completion_date  IN ota_training_plan_members.target_completion_date%TYPE,
                                      p_activity_version_id     IN ota_activity_versions.activity_version_id%TYPE,
                                      p_training_plan_id        IN ota_training_plans.training_plan_id%TYPE,
                                      p_member_status_id        OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------------
-- |----------------------<get_person_id>-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the person_id associated with the training plan
--
-- Prerequisites:
--
--
-- In Parameters:
--
--   p_training_plan_id
--
-- Post Success:
--   Processing continues if the the dates are legal.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

FUNCTION get_person_id(p_training_plan_id IN ota_training_plans.training_plan_id%TYPE)
RETURN number;

-- ----------------------------------------------------------------------------

-- ---------------------------< get_valid_enroll >-----------------------------
-- ----------------------------------------------------------------------------

PROCEDURE get_valid_enroll(p_person_id                  IN ota_training_plans.person_id%TYPE
			-- Modified for Bug#3479186
			  ,p_contact_id IN ota_training_plans.contact_id%TYPE
                          ,p_training_plan_member_id    IN ota_training_plan_members.training_plan_member_id%TYPE
                          ,p_return_status              OUT nocopy varchar2);


--  ---------------------------------------------------------------------------
--  |----------------------< complete_plan >--------------------------|
--  ---------------------------------------------------------------------------
--

PROCEDURE complete_plan(p_training_plan_id in ota_training_plans.training_plan_id%type);
-- ---------------------------------------------------------------------------


END ota_trng_plan_util_ss;

 

/
