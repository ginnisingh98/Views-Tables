--------------------------------------------------------
--  DDL for Package OTA_LRNG_PATH_MEMBER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LRNG_PATH_MEMBER_UTIL" AUTHID CURRENT_USER AS
/* $Header: otlpmwrs.pkh 120.0.12010000.2 2009/05/21 11:48:52 pekasi ship $ */


-- ---------------------------------------------------------------------------
-- |----------------------< get_enrollment_status >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the enrollment status type or name in the order A P W R C
--   Used to determine the exact status of an learning path member based on
--   enrollments falling under it
--
--  Prerequisites:
--
--  In Arguments:
--    p_person_id
--    p_contact_id
--    p_activity_version_id
--    p_lp_member_enrollment_id
--    p_return_code   - can be TYPE or NAME
--
--
--  Post Success:
--    Enrollment status or meaning is returned to calling unit
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION get_enrollment_status(p_person_id                IN ota_learning_paths.person_id%TYPE,
			                   p_contact_id               IN ota_learning_paths.contact_id%TYPE,
                               p_activity_version_id      IN ota_learning_path_members.activity_version_id%TYPE,
                               p_lp_member_enrollment_id  IN ota_lp_member_enrollments.lp_member_enrollment_id%TYPE DEFAULT NULL,
                               p_return_code              IN VARCHAR2)
  RETURN VARCHAR2;

-- ---------------------------------------------------------------------------
-- |----------------------< get_enrollment_status >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the enrollment status and date_status changed as the out parameters
--    for the class in the order A P W R C
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_person_id
--    p_contact_id
--    p_lp_member_enrollment_id
--
--  Post Success:
--    Enrollment status, date_status changed is set as out parameters
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ----------------------------------------------------------------------------
PROCEDURE get_enrollment_status(p_person_id               IN ota_learning_paths.person_id%TYPE,
			                    p_contact_id 	          IN ota_learning_paths.contact_id%TYPE,
                                p_activity_version_id      IN ota_learning_path_members.activity_version_id%TYPE,
                                p_lp_member_enrollment_id IN ota_lp_member_enrollments.lp_member_enrollment_id%TYPE,
                                p_booking_status_type     OUT nocopy ota_booking_status_types.type%TYPE,
                                p_date_status_changed     OUT nocopy ota_delegate_bookings.date_status_changed%TYPE);

-- ---------------------------------------------------------------------------
-- |----------------------< chk_enrollment_exist >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Checks if an enrollment exists for the learning path member
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_person_id
--    p_contact_id
--    p_learning_path_member_id
--
--
--  Post Success:
--   True is return to indicate that an enrollment exists
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION chk_enrollment_exist(p_person_id               IN ota_learning_paths.person_id%TYPE,
		      	              p_contact_id              IN ota_learning_paths.contact_id%TYPE,
                              p_learning_path_member_id IN ota_learning_path_members.learning_path_member_id%TYPE)
RETURN boolean;


-- ---------------------------------------------------------------------------
-- |----------------------< calculate_lme_status >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_code
-- Called while creating/updating a learning path member enrollment with member
-- status not equal to 'PLANNED' to determine the exact status based on
-- enrollments falling under it
--
--  Prerequisites:
--
--  In Arguments:
--    p_activity_version_id
--    p_lp_enrollment_id
--    p_member_status_code
--
--  Post Success:
--    Member status is returned to calling unit
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE calculate_lme_status(p_activity_version_id      IN ota_activity_versions.activity_version_id%TYPE,
                               p_lp_enrollment_id         IN ota_lp_enrollments.lp_enrollment_id%TYPE,
                               p_member_status_code       OUT nocopy VARCHAR2,
                               p_completion_date          OUT nocopy DATE);


-- ---------------------------------------------------------------------------
-- |----------------------< get_lme_status >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_code
-- Called while creating/updating a learning path member enrollment with member
-- status not equal to 'PLANNED' to determine the exact status based on
-- enrollments falling under it
--
--  Prerequisites:
--
--  In Arguments:
--    p_activity_version_id
--    p_person_id
--    p_contact_id
--    p_member_status_code
--
--  Post Success:
--    Member status is returned to calling unit
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION get_lme_status(p_activity_version_id      IN ota_activity_versions.activity_version_id%TYPE,
                        p_person_id                  IN ota_learning_paths.person_id%TYPE,
                        p_contact_id                 IN ota_learning_paths.contact_id%TYPE)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- ---------------------------< get_valid_enroll >-----------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_code
-- returns E when enrollment status type is not Cancelled and an enrollment exists
-- returns S when no enrollment exists for the lpm
--
--  Prerequisites:
--
--  In Arguments:
--    p_person_id
--    p_contact_id
--    p_lp_member_enrollment_id
--    p_return_status
--
--  Post Success:
--    returns E or S based of whether enrollments exist or not
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE get_valid_enroll(p_person_id                  IN ota_learning_paths.person_id%TYPE
        			      ,p_contact_id                 IN ota_learning_paths.contact_id%TYPE
                          ,p_lp_member_enrollment_id    IN ota_lp_member_enrollments.lp_member_enrollment_id%TYPE
                          ,p_return_status              OUT nocopy varchar2);

--  ---------------------------------------------------------------------------
--  |----------------------< Update_lpe_lme_change >--------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_code
-- Called while creating/updating a learning path member enrollment with member
-- status not equal to 'PLANNED' to determine the exact status based on
-- enrollments falling under it
--
--  Prerequisites:
--
--  In Arguments:
--    p_activity_version_id
--    p_lp_enrollment_id
--    p_member_status_code
--
--  Post Success:
--    Member status is returned to calling unit
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ---------------------------------------------------------------------------
Procedure Update_lpe_lme_change
          (p_lp_member_enrollment_id ota_lp_member_enrollments.lp_member_enrollment_id%type);

--  ---------------------------------------------------------------------------
--  |----------------------< Update_lpe_lme_change >--------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the member_status_code
-- Called while creating/updating a learning path member enrollment with member
-- status not equal to 'PLANNED' to determine the exact status based on
-- enrollments falling under it
--
--  Prerequisites:
--
--  In Arguments:
--    p_activity_version_id
--    p_lp_enrollment_id
--    p_member_status_code
--
--  Post Success:
--    Member status is returned to calling unit
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ---------------------------------------------------------------------------
Procedure Update_lpe_lme_change
(p_lp_member_enrollment_id ota_lp_member_enrollments.lp_member_enrollment_id%type,
 p_no_of_completed_courses ota_lp_enrollments.no_of_completed_courses%TYPE,
 p_lp_enrollment_ids OUT NOCOPY varchar2);

-- ---------------------------------------------------------------------------
-- |----------------------< update_lme_enroll_status_chg >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    when Enrollment status to an event changes the TPC's status attached to the
--  event also changes.
--  Called from ota_tdb_api_upd2.update_enrollment and ota_tdb_api_ins2.create_enrollment
--  Prerequisites:
--
--
--  In Arguments:
--    p_event_id
--    p_person_id
--
--  Post Success:
--    The attached TPC's status is updated
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE update_lme_enroll_status_chg (p_event_id          IN ota_events.event_id%TYPE,
                                        p_person_id         IN ota_lp_enrollments.person_id%TYPE,
               				            p_contact_id        IN ota_lp_enrollments.contact_id%TYPE,
                                        p_lp_enrollment_ids OUT NOCOPY varchar2);

-- ----------------------------------------------------------------------------
-- |----------------------<create_talent_mgmt_lpm>-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--
--
--
-- Post Success:
--
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
PROCEDURE create_talent_mgmt_lpm
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     DATE
  ,p_business_group_id            IN     NUMBER
  ,p_learning_path_id             IN     NUMBER    DEFAULT NULL
  ,p_lp_enrollment_id             IN     NUMBER    DEFAULT NULL
  ,p_learning_path_section_id     IN     NUMBER    DEFAULT NULL
  ,p_path_name         		  IN     VARCHAR2  DEFAULT NULL
  ,p_path_purpose      	          IN     VARCHAR2  DEFAULT NULL
  ,p_path_status_code     	  IN     VARCHAR2  DEFAULT NULL
  ,p_path_start_date_active       IN     DATE      DEFAULT NULL
  ,p_path_end_date_active         IN     DATE      DEFAULT NULL
  ,p_source_function_code         IN     VARCHAR2
  ,p_assignment_id	          IN 	 NUMBER    DEFAULT NULL
  ,p_source_id		          IN 	 NUMBER    DEFAULT NULL
  ,p_creator_person_id	          IN 	 NUMBER
  ,p_person_id		          IN     NUMBER
  ,p_display_to_learner_flag      IN     VARCHAR2
  ,p_activity_version_id          IN     NUMBER
  ,p_course_sequence              IN     NUMBER
  ,p_member_status_code	          IN     VARCHAR2  DEFAULT NULL
  ,p_completion_target_date       IN     DATE
  ,p_notify_days_before_target	  IN 	 NUMBER
  ,p_object_version_NUMBER        OUT NOCOPY NUMBER
  ,p_return_status                OUT NOCOPY VARCHAR2
  );


-- ----------------------------------------------------------------------------
-- |----------------------<update_talent_mgmt_lp>-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--
--
--
-- Post Success:
--
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
PROCEDURE update_talent_mgmt_lp
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     DATE
  ,p_mode                         IN     VARCHAR2
  ,p_learning_path_id             IN     NUMBER    DEFAULT NULL
  ,p_lp_enrollment_id             IN     NUMBER    DEFAULT NULL
  ,p_source_function_code	  IN     VARCHAR2
  ,p_assignment_id		  IN 	 NUMBER    DEFAULT NULL
  ,p_source_id		   	  IN 	 NUMBER    DEFAULT NULL
  ,p_person_id		          IN     NUMBER
  ,p_display_to_learner_flag      IN     VARCHAR2
  ,p_lps_ovn                      IN OUT NOCOPY NUMBER
  ,p_lpe_ovn                      IN OUT NOCOPY NUMBER
  ,p_return_status                OUT NOCOPY VARCHAR2
  );

-- ----------------------------------------------------------------------------
-- |-------------------< chk_no_of_mandatory_courses >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_no_of_mandatory_courses
  (p_learning_path_member_id    IN     ota_learning_path_members.learning_path_member_id%TYPE,
   p_return_status OUT NOCOPY VARCHAR2);

FUNCTION get_class_completion_date(p_event_id IN ota_events.event_id%type,
  			                       p_person_id	IN	NUMBER,
                                   p_contact_id IN ota_attempts.user_type%type)
RETURN DATE;

FUNCTION get_lp_completion_date(p_lp_enrollment_id ota_lp_enrollments.lp_enrollment_id%TYPE)
RETURN DATE;

FUNCTION get_lpm_completion_date(p_lp_member_enrollment_id ota_lp_member_enrollments.lp_member_enrollment_id%TYPE,
                                 p_activity_version_id ota_activity_versions.activity_version_id%TYPE,
                                 p_person_id  ota_lp_enrollments.person_id%TYPE,
			                     p_contact_id ota_lp_enrollments.contact_id%TYPE)
RETURN DATE;

END ota_lrng_path_member_util;


/
