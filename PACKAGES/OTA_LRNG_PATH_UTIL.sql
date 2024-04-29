--------------------------------------------------------
--  DDL for Package OTA_LRNG_PATH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LRNG_PATH_UTIL" AUTHID CURRENT_USER as
/* $Header: otlpswrs.pkh 120.0.12010000.3 2009/05/07 11:42:22 pekasi ship $ */

--  ---------------------------------------------------------------------------
--  |----------------------< chk_complete_path_ok >--------------------------|
--  ---------------------------------------------------------------------------
--

-- {Start Of Comments}
--
--  Description:
--
--  Prerequisites:
--
--
--  In Arguments:
--
--
--  Post Success:
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ---------------------------------------------------------------------------
Function chk_complete_path_ok(p_lp_enrollment_id in ota_lp_enrollments.lp_enrollment_id%type)
return varchar2;

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
--    p_lp_enrollment_id
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

FUNCTION chk_login_person ( p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE)
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |----------------------<get_person_id>-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the person_id associated with the learning path
--
-- Prerequisites:
--
--
-- In Parameters:
--
--   p_lp_enrollment_id
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

FUNCTION get_person_id(p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE)
RETURN number;

--  ---------------------------------------------------------------------------
--  |----------------------< complete_path >--------------------------|
--  ---------------------------------------------------------------------------
--

PROCEDURE complete_path(p_lp_enrollment_id in ota_lp_enrollments.lp_enrollment_id%type);

-- ----------------------------------------------------------------------------
-- |----------------------<get_no_of_mandatory_courses> -----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the number of mandatory courses for a learning path
--
-- Prerequisites:
--
--
-- In Parameters:
--
--   p_learning_path_id
--
-- Post Success:
--  Returns the number of mandatory courses for a learning path
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

FUNCTION get_no_of_mandatory_courses(p_learning_path_id IN ota_learning_paths.learning_path_id%TYPE,
                                     p_path_source_code IN ota_learning_paths.path_source_code%TYPE)
RETURN number;


-- ----------------------------------------------------------------------------
-- |----------------------<get_no_of_completed_courses> -----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the number of completed courses for a learning path
--
-- Prerequisites:
--
--
-- In Parameters:
--
--   p_lp_enrollment_id
--   p_path_source_code
--
-- Post Success:
--  Returns the number of completed courses for an lp enrollment
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

FUNCTION get_no_of_completed_courses(p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE,
                                     p_path_source_code IN ota_learning_paths.path_source_code%TYPE)
RETURN number;

-- ---------------------------------------------------------------------------
-- |----------------------< Update_lpe_lpm_changes >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Updates no_of_completed_courses and no_of_mandatory_courses for the
-- p_lp_enrollment_id passed, and marks the path completed if it meets the
-- completion criteria.
--
--  Prerequisites:
--
--
--  In Arguments:
--    p_lp_enrollment_id
--    p_completion_target_date new completion_target_date
--
--
--  Post Success:
--    'S' is returned for successful update of no_of_completed_courses and
--    no_of_mandatory_courses
--    'C' is returned for successful completion of path.
--    'F' is returned for no update.
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure Update_lpe_lpm_changes( p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE,
				  --Modified for Bug#3891087
                                  --p_path_source_code IN ota_learning_paths.path_source_code%TYPE,
                                  p_completion_target_date IN ota_lp_enrollments.completion_target_date%TYPE,
                                  p_return_status OUT NOCOPY VARCHAR2);

-- ---------------------------------------------------------------------------
-- |----------------------< get_lpe_crse_compl_status_msg >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Retrieves tokenized message for displaying Learning Path course completion
--    status.
--
--  Prerequisites:
--
--
--  In Arguments:
--    no_of_completed_courses
--    no_of_mandatory_courses
--
--  Post Success:
--    Return of form of tokenized "no_of_completed_courses of no_of_mandatory_courses
--    courses completed."
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION get_lpe_crse_compl_status_msg(no_of_completed_courses IN number, no_of_mandatory_courses IN number)
RETURN varchar2;

--  ---------------------------------------------------------------------------
--  |----------------------< get_talent_mgmt_lp >--------------------------|
--  ---------------------------------------------------------------------------
--

FUNCTION get_talent_mgmt_lp(p_person_id             IN ota_lp_enrollments.person_id%TYPE
                           ,p_source_function_code  IN ota_learning_paths.source_function_code%TYPE
                           ,p_source_id             IN ota_learning_paths.source_id%TYPE
                           ,p_assignment_id         IN ota_learning_paths.assignment_id%TYPE
                           ,p_business_group_id     IN NUMBER)
RETURN NUMBER;


-- ----------------------------------------------------------------------------
-- |----------------------<get_no_of_mand_compl_courses> ----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the number of mandatory completed courses for a learning path section
--
-- Prerequisites:
--
--
-- In Parameters:
--
--   p_learning_path_section_id
--   p_person_id
--   p_contact_id
--
-- Post Success:
--  Returns the number of mand completed courses for a learning path section
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

FUNCTION get_no_of_mand_compl_courses(p_learning_path_section_id IN ota_lp_sections.learning_path_section_id%TYPE,
                                      p_person_id               IN ota_learning_paths.person_id%TYPE,
                       		          p_contact_id 	          IN ota_learning_paths.contact_id%TYPE)
RETURN number;

Function is_path_successful(p_lp_enrollment_id in ota_lp_enrollments.lp_enrollment_id%type)
return varchar2;

Procedure Start_comp_proc_success_attnd(p_person_id 	in number ,
            p_event_id       in ota_Events.event_id%type);

-- Added this function for  Bug# 7430475
FUNCTION get_no_of_mand_compl_courses(p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE)
RETURN number;

function get_lp_current_status(p_lp_enrollment_id in ota_lp_enrollments.lp_enrollment_id%type)
return varchar2 ;


END ota_lrng_path_util;


/
