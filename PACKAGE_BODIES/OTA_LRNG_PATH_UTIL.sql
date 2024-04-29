--------------------------------------------------------
--  DDL for Package Body OTA_LRNG_PATH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LRNG_PATH_UTIL" as
/* $Header: otlpswrs.pkb 120.0.12010000.5 2009/05/21 09:24:47 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)	:= 'ota_lrng_path_util.';  -- Global package name

--  ---------------------------------------------------------------------------
--  |----------------------< chk_complete_path_ok >--------------------------|
--  ---------------------------------------------------------------------------
--
Function chk_complete_path_ok(p_lp_enrollment_id in ota_lp_enrollments.lp_enrollment_id%type)
return varchar2
IS
/*
CURSOR is_path_completed IS
SELECT 1
  FROM ota_lp_enrollments lpe
 WHERE lpe.lp_enrollment_id = p_lp_enrollment_id
   AND lpe.no_of_mandatory_courses = lpe.no_of_completed_courses;

CURSOR one_child_completed IS
SELECT lme.lp_member_enrollment_id
  FROM ota_lp_member_enrollments lme,
       ota_lp_enrollments lpe
 WHERE lme.member_status_code = 'COMPLETED'
   AND lpe.lp_enrollment_id = lme.lp_enrollment_id
   AND lpe.lp_enrollment_id = p_lp_enrollment_id
   AND rownum = 1;
*/
-- Added for Bug#4052408
CURSOR csr_get_path_details IS
   SELECT lps.path_source_code, lps.source_function_code, lpe.path_status_code
   FROM ota_learning_paths lps,
        ota_lp_enrollments lpe
   WHERE lpe.lp_enrollment_id = p_lp_enrollment_id
      AND lpe.learning_path_id = lps.learning_path_id;
-- End of code added for bug#4052408

-- bug 7028384
CURSOR get_lp_section_details IS
   SELECT lps.completion_type_code, lps.learning_path_section_id, lps.no_of_mandatory_courses
   FROM ota_lp_sections lps, ota_lp_enrollments lpe
   WHERE lpe.lp_enrollment_id = p_lp_enrollment_id AND
         lpe.learning_path_id = lps.learning_path_id;

CURSOR get_lp_member_status(p_lp_section_id ota_lp_sections.learning_path_section_id%TYPE) IS
   SELECT  member_status_code FROM ota_lp_member_enrollments
   WHERE learning_path_section_id = p_lp_section_id AND
         lp_enrollment_id = p_lp_enrollment_id;
-- bug 7028384
    l_proc    VARCHAR2(72) := g_package ||'chk_complete_path_ok';
    l_exists  Number(9);
    l_complete Number(9);
    l_result  varchar2(3) :='F';
    l_path_source_code ota_learning_paths.path_source_code%TYPE;
    l_source_function_code ota_learning_paths.source_function_code%TYPE;
    l_path_status ota_lp_enrollments.path_status_code%TYPE;
    l_completed_course_count number := 0;

Begin

    hr_utility.set_location(' Entering:' || l_proc,10);

    -- Added for Bug#4052408
    -- Return F for Talent Management learning paths whose status is AWAITING_APPROVAL
    OPEN csr_get_path_details;
    FETCH csr_get_path_details into l_path_source_code, l_source_function_code, l_path_status;
    CLOSE csr_get_path_details;

    IF l_path_source_code = 'TALENT_MGMT'
        AND l_source_function_code = 'APPRAISAL'
          AND l_path_status = 'AWAITING_APPROVAL' THEN
            return l_result;
    END IF;
    -- End of code added for Bug#4052408

-- bug 7028384
  FOR lp_sec_details IN get_lp_section_details LOOP
    l_completed_course_count := 0;
    l_result := 'F';
   IF(lp_sec_details.completion_type_code = 'O')THEN --All optional
        l_result := 'S';
   ELSE
    FOR lp_mbr_status IN get_lp_member_status(lp_sec_details.learning_path_section_id) LOOP
        IF(lp_sec_details.completion_type_code = 'M') THEN --All Mandatory
            IF(lp_mbr_status.member_status_code <> 'COMPLETED') THEN
                return 'F';
            ELSE
                l_result := 'S';
            END IF;
        ELSE
           IF(lp_sec_details.completion_type_code = 'S')THEN --One or More Mandatory
                IF(lp_mbr_status.member_status_code = 'COMPLETED') THEN
                    l_completed_course_count := l_completed_course_count+1;
                    IF(l_completed_course_count >= lp_sec_details.no_of_mandatory_courses) THEN
                        l_result := 'S';
                    END IF;
                END IF;
           END IF;
        END IF;
    END LOOP;
    IF(l_result = 'F') THEN
        return l_result;
    END IF;
   END IF;
  END LOOP;

-- bug 7028384
/*
    open is_path_completed;
    fetch is_path_completed into l_exists;
    if is_path_completed%FOUND then
        open one_child_completed;
        fetch one_child_completed into l_complete;
        if one_child_completed%found then
            l_result :='S';
        end if;
        close one_child_completed;
    end if;
    close is_path_completed;
*/
    return l_result;


end chk_complete_path_ok;

--  ---------------------------------------------------------------------------
--  |----------------------< chk_login_person >--------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION chk_login_person(p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE)
RETURN VARCHAR2
IS

l_person_id         	ota_learning_paths.person_id%TYPE;
l_login_person      	ota_learning_paths.person_id%TYPE;
l_login_customer 	NUMBER;
l_contact_id         	ota_learning_paths.contact_id%TYPE;
l_proc              	VARCHAR2(72) :=      g_package|| 'chk_login_person';

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

   SELECT lpe.person_id,
          lpe.contact_id
     INTO l_person_id,
          l_contact_id
     FROM ota_lp_enrollments lpe
    WHERE lpe.lp_enrollment_id = p_lp_enrollment_id;

    SELECT employee_id,
           customer_id
      INTO l_login_person,
           l_login_customer
      FROM fnd_user
     WHERE user_id = fnd_profile.value('USER_ID');

    hr_utility.set_location(' Step:'|| l_proc, 20);
 IF l_login_person  IS NOT NULL THEN
      IF l_login_person = l_person_id THEN
        RETURN 'E';
    ELSE
        RETURN 'M';
    END IF;
  ELSIF l_login_customer IS NOT NULL THEN
      RETURN 'E';
  END IF;



    hr_utility.set_location(' Step:'|| l_proc, 30);
END chk_login_person;

-- ----------------------------------------------------------------------------
-- |---------------------------<  get_person_id  >----------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_person_id(p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE)
  RETURN number
IS

CURSOR csr_person_id IS
SELECT person_id
  FROM ota_lp_enrollments
 WHERE lp_enrollment_id = p_lp_enrollment_id;

l_person_id number(9) := 0;

BEGIN

    OPEN csr_person_id;
    FETCH csr_person_id INTO l_person_id;
    CLOSE csr_person_id;

    IF l_person_id is null then
    l_person_id := 0;
    END IF;

    RETURN l_person_id;

END get_person_id;

-- ----------------------------------------------------------------------------
-- |---------------------------<  complete_path     >-------------------------|
-- ----------------------------------------------------------------------------
Procedure complete_path(p_lp_enrollment_id 	ota_lp_enrollments.lp_enrollment_id%TYPE)
is

CURSOR csr_lpe_update(csr_lp_enrollment_id number)
    IS
    SELECT lpe.lp_enrollment_id,
           lpe.object_version_number
     FROM ota_lp_enrollments lpe
     WHERE lpe.lp_enrollment_id = csr_lp_enrollment_id;

  l_lp_enrollment_id       ota_lp_enrollments.lp_enrollment_id%TYPE;
  l_object_version_number  ota_lp_enrollments.object_version_number%type;
  l_path_status_code       ota_lp_enrollments.path_status_code%type;

BEGIN
        l_path_status_code := 'COMPLETED';

        OPEN csr_lpe_update(p_lp_enrollment_id);
        FETCH csr_lpe_update into l_lp_enrollment_id,l_object_version_number;
        IF csr_lpe_update%FOUND then
           CLOSE csr_lpe_update;
           ota_lp_enrollment_api.update_lp_enrollment
                       (p_effective_date               => sysdate
                       ,p_lp_enrollment_id             => p_lp_enrollment_id
                       ,p_object_version_number        => l_object_version_number
                       ,p_path_status_code             => l_path_status_code
                       ,p_completion_date              => ota_lrng_path_member_util.get_lp_completion_date(p_lp_enrollment_id));
        ELSE
          CLOSE csr_lpe_update;
        END IF;
END complete_path;
-- ----------------------------------------------------------------------------
-- |----------------------<get_no_of_mandatory_courses> -----------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_no_of_mandatory_courses(p_learning_path_id IN ota_learning_paths.learning_path_id%TYPE,
                                     p_path_source_code IN ota_learning_paths.path_source_code%TYPE)
RETURN number IS

CURSOR csr_s_lpm IS
SELECT sum(no_of_mandatory_courses)
  FROM ota_lp_sections
 WHERE learning_path_id = p_learning_path_id
   AND completion_type_code = 'S';

   CURSOR csr_m_lpm IS
SELECT count(lpm.learning_path_member_id)
  FROM ota_lp_sections lpc,
       ota_learning_path_members lpm
 WHERE lpc.learning_path_id = p_learning_path_id
   and lpm.learning_path_section_id = lpc.learning_path_section_id
   AND completion_type_code = 'M';

l_s_lpm       ota_lp_enrollments.no_of_mandatory_courses%TYPE;
l_m_lpm       ota_lp_enrollments.no_of_mandatory_courses%TYPE;
l_return      ota_lp_enrollments.no_of_mandatory_courses%TYPE := 0;

BEGIN
        OPEN csr_m_lpm;
       FETCH csr_m_lpm INTO l_m_lpm;
       CLOSE csr_m_lpm;

              IF l_m_lpm IS NULL THEN
                 l_m_lpm := 0;
             END IF;

    IF p_path_source_code = 'CATALOG' THEN

        OPEN csr_s_lpm;
       FETCH csr_s_lpm INTO l_s_lpm;
       CLOSE csr_s_lpm;
              IF l_s_lpm IS NULL THEN
                 l_s_lpm := 0;
             END IF;
             l_return := l_s_lpm + l_m_lpm;
    ELSE
             l_return := l_m_lpm;

    END IF;


    RETURN l_return;

END get_no_of_mandatory_courses;
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
RETURN number IS


CURSOR csr_sections IS
SELECT lpc.no_of_mandatory_courses,
       lpc.learning_path_section_id
  FROM ota_lp_enrollments lme,
       ota_lp_sections lpc
 WHERE lpc.learning_path_id = lme.learning_path_id
   AND lpc.completion_type_code = 'S'
   AND lme.lp_enrollment_id = p_lp_enrollment_id;

CURSOR csr_s_lpm(l_learning_path_section_id NUMBER) IS
SELECT count(lp_member_enrollment_id)
  FROM ota_lp_member_enrollments lme
 WHERE lme.learning_path_section_id = l_learning_path_section_id
   AND lme.member_status_code = 'COMPLETED'
   AND lme.lp_enrollment_id = p_lp_enrollment_id;

   CURSOR csr_m_lpm IS
SELECT count(lp_member_enrollment_id)
  FROM ota_lp_member_enrollments lme,
       ota_lp_sections lpc
 WHERE lpc.learning_path_section_id = lme.learning_path_section_id
   AND lpc.completion_type_code = 'M'
   AND lme.member_status_code = 'COMPLETED'
   AND lme.lp_enrollment_id = p_lp_enrollment_id;

l_no_of_mandatory_courses  ota_lp_sections.no_of_mandatory_courses%TYPE;

l_s_lpm                    ota_lp_enrollments.no_of_mandatory_courses%TYPE;
l_m_lpm                    ota_lp_enrollments.no_of_mandatory_courses%TYPE;
l_completed_courses        ota_lp_enrollments.no_of_mandatory_courses%TYPE := 0;
l_return                   ota_lp_enrollments.no_of_mandatory_courses%TYPE := 0;

BEGIN

        OPEN csr_m_lpm;
       FETCH csr_m_lpm INTO l_m_lpm;
       CLOSE csr_m_lpm;

              IF l_m_lpm IS NULL THEN
                 l_m_lpm := 0;
             END IF;

    IF p_path_source_code = 'CATALOG' THEN
        FOR rec_sections IN csr_sections
       LOOP
           l_no_of_mandatory_courses := rec_sections.no_of_mandatory_courses;

              IF l_no_of_mandatory_courses IS NULL THEN
                 l_no_of_mandatory_courses := 0;
             END IF;

            OPEN csr_s_lpm(rec_sections.learning_path_section_id);
           FETCH csr_s_lpm INTO l_s_lpm;
           CLOSE csr_s_lpm;

              IF l_s_lpm IS NULL THEN
                 l_s_lpm := 0;
             END IF;

                    IF l_s_lpm <= l_no_of_mandatory_courses THEN
                      l_completed_courses := l_completed_courses + l_s_lpm;
                 ELSE
                      l_completed_courses :=  l_completed_courses + l_no_of_mandatory_courses;
                  END IF;


        END LOOP;
                  l_return := l_completed_courses + l_m_lpm;

    ELSE
             l_return := l_m_lpm;

    END IF;


    RETURN l_return;

END get_no_of_completed_courses;

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

PROCEDURE Update_lpe_lpm_changes( p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE,
				 --Modified for Bug#3891087
                                  --p_path_source_code IN ota_learning_paths.path_source_code%TYPE,
                                  p_completion_target_date IN ota_lp_enrollments.completion_target_date%TYPE,
                                  p_return_status OUT NOCOPY VARCHAR2)
is

CURSOR one_child_completed IS
SELECT lme.lp_member_enrollment_id
  FROM ota_lp_member_enrollments lme,
       ota_lp_enrollments lpe
 WHERE lme.member_status_code = 'COMPLETED'
   AND lpe.lp_enrollment_id = lme.lp_enrollment_id
   AND lpe.lp_enrollment_id = p_lp_enrollment_id
   AND rownum = 1;

CURSOR csr_lpe_update(csr_lp_enrollment_id number)
    IS
    SELECT lpe.lp_enrollment_id,
           lpe.learning_path_id,
           lpe.completion_target_date,
           lpe.object_version_number
     FROM ota_lp_enrollments lpe
     WHERE lpe.lp_enrollment_id = csr_lp_enrollment_id;

 CURSOR csr_get_path_source_code
 IS
   -- Modified for Bug#4052408
   --SELECT lps.path_source_code
    SELECT lps.path_source_code, lps.source_function_code, lpe.path_status_code
    FROM ota_learning_paths lps, ota_lp_enrollments lpe
    WHERE lps.learning_path_id = lpe.learning_path_id
	        AND lpe.lp_enrollment_id = p_lp_enrollment_id;

  l_lp_enrollment_id       ota_lp_enrollments.lp_enrollment_id%TYPE;
  l_learning_path_id       ota_learning_paths.learning_path_id%TYPE;
  l_object_version_number  ota_lp_enrollments.object_version_number%type;
  l_path_status_code       ota_lp_enrollments.path_status_code%type;
  l_no_of_completed_courses ota_lp_enrollments.no_of_completed_courses%type;
  l_no_of_mandatory_courses ota_lp_enrollments.no_of_mandatory_courses%type;
  l_completion_target_date  ota_lp_enrollments.completion_target_date%TYPE;
  l_result  varchar2(3) :='F';
  l_complete Number(9);
  l_return_status varchar2(3) :='';
  l_path_source_code ota_learning_paths.path_source_code%TYPE;
  l_source_function_code ota_learning_paths.source_function_code%TYPE;


BEGIN
    OPEN csr_get_path_source_code;
    FETCH csr_get_path_source_code INTO l_path_source_code, l_source_function_code, l_path_status_code;
    CLOSE csr_get_path_source_code;

    OPEN csr_lpe_update(p_lp_enrollment_id);
    FETCH csr_lpe_update into l_lp_enrollment_id,l_learning_path_id, l_completion_target_date, l_object_version_number;
    CLOSE csr_lpe_update;

  	l_no_of_completed_courses := get_no_of_completed_courses(p_lp_enrollment_id,
								 l_path_source_code);
	l_no_of_mandatory_courses := get_no_of_mandatory_courses(l_learning_path_id,
    							 l_path_source_code);

    IF (p_completion_target_date IS NOT NULL AND l_completion_target_date IS NOT NULL) THEN
        IF (p_completion_target_date > l_completion_target_date) THEN
            l_completion_target_date := p_completion_target_date;
        END IF;
    ELSIF p_completion_target_date IS NOT NULL THEN
            l_completion_target_date := p_completion_target_date;
    END IF;

   -- Added for Bug#4052408
   IF l_path_source_code = 'TALENT_MGMT'
        AND l_source_function_code = 'APPRAISAL'
          AND l_path_status_code = 'AWAITING_APPROVAL' THEN
            l_result := 'F';
   ELSE

	if l_no_of_completed_courses = l_no_of_mandatory_courses then
  		open one_child_completed;
        	fetch one_child_completed into l_complete;
        	if one_child_completed%found then
        	    l_result :='S';
        	end if;
        	close one_child_completed;
        end if;
  END IF;

        IF l_result = 'S' THEN
           l_path_status_code := 'COMPLETED';
           ota_lp_enrollment_api.update_lp_enrollment
	                          (p_effective_date               => sysdate
	                          ,p_lp_enrollment_id             => p_lp_enrollment_id
	                          ,p_object_version_number        => l_object_version_number
				              ,p_no_of_completed_courses      => l_no_of_completed_courses
            				  ,p_no_of_mandatory_courses      => l_no_of_mandatory_courses
                              ,p_completion_target_date       => l_completion_target_date
	                          ,p_path_status_code             => l_path_status_code
                        	  ,p_completion_date              => ota_lrng_path_member_util.get_lp_completion_date(p_lp_enrollment_id));
           --set the return flag as completed
           l_return_status := 'C';
        ELSE
    	   ota_lp_enrollment_api.update_lp_enrollment
	                          (p_effective_date               => sysdate
	                          ,p_lp_enrollment_id             => p_lp_enrollment_id
	                          ,p_object_version_number        => l_object_version_number
	                          ,p_no_of_completed_courses      => l_no_of_completed_courses
				              ,p_no_of_mandatory_courses      => l_no_of_mandatory_courses
                              ,p_completion_target_date       => l_completion_target_date);
           --set the return flag as successful
           l_return_status := 'S';
	END IF;

    p_return_status := l_return_status;

END Update_lpe_lpm_changes;


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

FUNCTION get_lpe_crse_compl_status_msg(no_of_completed_courses IN number,
                                                no_of_mandatory_courses IN number)
RETURN varchar2 IS

l_return_msg          varchar2(200);

BEGIN

     fnd_message.set_name('OTA', 'OTA_13081_LPE_CRS_CMPL_STATUS');
     fnd_message.set_token('NO_OF_COMPLETED_COURSES', no_of_completed_courses);
     fnd_message.set_token('NO_OF_MANDATORY_COURSES', no_of_mandatory_courses);
     l_return_msg := fnd_message.get;

    RETURN l_return_msg;

END get_lpe_crse_compl_status_msg;


--  ---------------------------------------------------------------------------
--  |----------------------< get_talent_mgmt_lp >--------------------------|
--  ---------------------------------------------------------------------------
--

FUNCTION get_talent_mgmt_lp(p_person_id             IN ota_lp_enrollments.person_id%TYPE
                           ,p_source_function_code  IN ota_learning_paths.source_function_code%TYPE
                           ,p_source_id             IN ota_learning_paths.source_id%TYPE
                           ,p_assignment_id         IN ota_learning_paths.assignment_id%TYPE
                           ,p_business_group_id     IN NUMBER)
RETURN number
IS

CURSOR csr_get_lp IS
SELECT learning_path_id
  FROM ota_learning_paths
 WHERE source_function_code = p_source_function_code
   AND business_group_id = p_business_group_id
   AND person_id = p_person_id
   AND (p_source_id IS NULL OR (p_source_id IS NOT NULL AND source_id = p_source_id))
   AND (p_assignment_id IS NULL OR (p_assignment_id IS NOT NULL AND assignment_id = p_assignment_id));

l_proc  VARCHAR2(72) :=      g_package|| 'get_talent_mgmt_lp';

l_learning_path_id  ota_learning_paths.learning_path_id%TYPE := 0;

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

     OPEN csr_get_lp ;
    FETCH csr_get_lp INTO l_learning_path_id;
    CLOSE csr_get_lp;
   RETURN l_learning_path_id;


END get_talent_mgmt_lp;

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
RETURN number
IS
CURSOR csr_lps IS
SELECT learning_path_id,
       no_of_mandatory_courses,
       completion_type_code
  FROM ota_lp_sections
 WHERE learning_path_section_id = p_learning_path_section_id;

CURSOR csr_m_lpm IS
SELECT count(learning_path_member_id)
  FROM ota_learning_path_members lpm,
       ota_lp_sections lpc
 WHERE lpc.learning_path_section_id = p_learning_path_section_id
   AND lpm.learning_path_section_id = lpc.learning_path_section_id
   AND lpc.completion_type_code = 'M';

CURSOR csr_mand_crs_cmpl_count(l_learning_path_id NUMBER)  IS
select count(*)
from ota_lp_member_enrollments lme,
     ota_lp_enrollments lpe
where
     lpe.learning_path_id = l_learning_path_id
     and lme.learning_path_section_id = p_learning_path_section_id
     and (lpe.person_id = p_person_id or lpe.contact_id = p_contact_id)
     and lpe.PATH_STATUS_CODE in ('ACTIVE', 'COMPLETED')
     and lme.member_status_code like 'COMPLETED'
     and lme.LP_ENROLLMENT_ID = lpe.LP_ENROLLMENT_ID;

l_learning_path_id  ota_lp_sections.learning_path_id%TYPE;
l_no_of_mandatory_courses  ota_lp_sections.no_of_mandatory_courses%TYPE;
l_completion_type_code  ota_lp_sections.completion_type_code%TYPE;
l_mand_crse_compl_count NUMBER:= 0;
l_mand_crse_count NUMBER:= 0;

BEGIN

    OPEN csr_lps;
    FETCH csr_lps into l_learning_path_id, l_no_of_mandatory_courses, l_completion_type_code;
    CLOSE csr_lps;

    IF l_completion_type_code = 'M' THEN

       OPEN csr_mand_crs_cmpl_count(l_learning_path_id);
       FETCH csr_mand_crs_cmpl_count into l_mand_crse_compl_count;
       CLOSE csr_mand_crs_cmpl_count;

       OPEN csr_m_lpm;
       FETCH csr_m_lpm into l_mand_crse_count;
       CLOSE csr_m_lpm;

       IF l_mand_crse_compl_count > l_mand_crse_count THEN
          l_mand_crse_compl_count := l_mand_crse_count;
       END IF;

    ELSIF l_completion_type_code = 'S' THEN

       OPEN csr_mand_crs_cmpl_count(l_learning_path_id);
       FETCH csr_mand_crs_cmpl_count into l_mand_crse_compl_count;
       CLOSE csr_mand_crs_cmpl_count;

       IF l_mand_crse_compl_count > l_no_of_mandatory_courses THEN
         l_mand_crse_compl_count := l_no_of_mandatory_courses;
       END IF;

    ELSIF l_completion_type_code = 'S' THEN
       l_mand_crse_compl_count := 0;
    END IF;

    RETURN l_mand_crse_compl_count;

END get_no_of_mand_compl_courses;

Function is_path_successful(p_lp_enrollment_id in ota_lp_enrollments.lp_enrollment_id%type)
return varchar2
IS
l_learning_path_id number;
l_path_status varchar2(30);
l_person_id number;
l_contact_id number;
l_exists number;

CURSOR csr_get_lpe_info IS
 select lpe.learning_path_id,lpe.path_status_code, lpe.person_id, lpe.contact_id
 FROM ota_lp_enrollments lpe
 where lpe.lp_enrollment_id = p_lp_enrollment_id;

CURSOR csr_chk_person IS
select
     sum( decode(tdb.successful_attendance_flag, 'Y',1,0)) completed_courses,
     max(lpc.no_of_mandatory_courses) no_of_courses
  from ota_lp_sections lpc
    , ota_learning_path_members lpm
    , ota_events evt
    , ota_delegate_bookings tdb
    , ota_lp_enrollments lpe
    , ota_booking_status_types bst
 where lpc.learning_path_id         = lpe.learning_path_id
   and lpm.learning_path_section_id = lpc.learning_path_section_id
   and lpm.activity_version_id      = evt.activity_version_id
   and tdb.event_id                 = evt.event_id
   and lpc.completion_type_code     = 'S'
   and tdb.delegate_person_id       = lpe.person_id
   and lpe.lp_enrollment_id         = p_lp_enrollment_id
   and lpe.path_status_code         = 'COMPLETED'
   and tdb.booking_status_type_id = bst.booking_status_type_id
   and bst.type = 'A'
 group by lpc.learning_path_section_id

UNION ALL

  select
     sum( decode(tdb.successful_attendance_flag, 'Y',1,0)) completed_courses,
     sum(1) no_of_courses
  from ota_lp_sections lpc
    , ota_learning_path_members lpm
    , ota_events evt
    , ota_delegate_bookings tdb
    , ota_lp_enrollments lpe
    , ota_booking_status_types bst
 where lpc.learning_path_id         = lpe.learning_path_id
   and lpm.learning_path_section_id = lpc.learning_path_section_id
   and lpm.activity_version_id      = evt.activity_version_id
   and tdb.event_id                 = evt.event_id
   and lpc.completion_type_code     = 'M'
   and tdb.delegate_person_id       = lpe.person_id
   and lpe.lp_enrollment_id         = p_lp_enrollment_id
   and lpe.path_status_code         = 'COMPLETED'
   and tdb.booking_status_type_id = bst.booking_status_type_id
   and bst.type = 'A'
 group by lpc.learning_path_section_id;

 CURSOR csr_chk_contact IS
select
     sum( decode(tdb.successful_attendance_flag, 'Y',1,0)) completed_courses,
     max(lpc.no_of_mandatory_courses) no_of_courses
  from ota_lp_sections lpc
    , ota_learning_path_members lpm
    , ota_events evt
    , ota_delegate_bookings tdb
    , ota_lp_enrollments lpe
    , ota_booking_status_types bst
 where lpc.learning_path_id         = lpe.learning_path_id
   and lpm.learning_path_section_id = lpc.learning_path_section_id
   and lpm.activity_version_id      = evt.activity_version_id
   and tdb.event_id                 = evt.event_id
   and lpc.completion_type_code     = 'S'
   and tdb.delegate_contact_id      = lpe.contact_id
   and lpe.lp_enrollment_id         = p_lp_enrollment_id
   and lpe.path_status_code         = 'COMPLETED'
   and tdb.booking_status_type_id = bst.booking_status_type_id
   and bst.type = 'A'
 group by lpc.learning_path_section_id

UNION ALL

  select
     sum( decode(tdb.successful_attendance_flag, 'Y',1,0)) completed_courses,
     sum(1) no_of_courses
  from ota_lp_sections lpc
    , ota_learning_path_members lpm
    , ota_events evt
    , ota_delegate_bookings tdb
    , ota_lp_enrollments lpe
    , ota_booking_status_types bst
 where lpc.learning_path_id         = lpe.learning_path_id
   and lpm.learning_path_section_id = lpc.learning_path_section_id
   and lpm.activity_version_id      = evt.activity_version_id
   and tdb.event_id                 = evt.event_id
   and lpc.completion_type_code     = 'M'
   and tdb.delegate_contact_id      = lpe.contact_id
   and lpe.lp_enrollment_id         = p_lp_enrollment_id
   and lpe.path_status_code         = 'COMPLETED'
   and tdb.booking_status_type_id = bst.booking_status_type_id
   and bst.type = 'A'
 group by lpc.learning_path_section_id;

 l_lpc_rec csr_chk_person%ROWTYPE;
 l_lpc_rec2 csr_chk_contact%ROWTYPE;

BEGIN
   OPEN csr_get_lpe_info;
   FETCH csr_get_lpe_info INTO l_learning_path_id, l_path_status, l_person_id, l_contact_id;
   CLOSE csr_get_lpe_info;

   IF l_path_status <> 'COMPLETED' THEN
      return 'N';
   END IF;

   IF l_person_id IS NOT NULL THEN
    FOR l_lpc_rec IN csr_chk_person LOOP
      IF l_lpc_rec.completed_courses < l_lpc_rec.no_of_courses THEN
         return 'N';
      END IF;
    END LOOP;

   ELSIF l_contact_id IS NOT NULL THEN
      FOR l_lpc_rec2 IN csr_chk_contact LOOP
      IF l_lpc_rec2.completed_courses < l_lpc_rec.no_of_courses THEN
         return 'N';
      END IF;
    END LOOP;
   END IF;
return 'Y';
END is_path_successful;

Procedure Start_comp_proc_success_attnd(p_person_id 	in number ,
            p_event_id       in ota_Events.event_id%type)
is

cursor get_lp_enroll is
select lp_enrollment_id, lpe.learning_path_id
From  ota_learning_path_members lpm
    , ota_events evt
        , ota_lp_enrollments lpe
        where evt.activity_version_id = lpm.activity_version_id
    and lpm.learning_path_id = lpe.learning_path_id
    and evt.event_id = p_event_id
    and lpe.person_id = p_person_id;

l_sucessful varchar(2) := 'N';

l_item_key wf_items.item_key%type;

begin

For rec in get_lp_enroll
loop

l_sucessful := is_path_successful(rec.lp_enrollment_id);

 if l_sucessful = 'Y' then

    ota_competence_ss.create_wf_process(p_process		=> 'OTA_COMPETENCE_UPDATE_JSP_PRC',
                                                  p_itemtype		=> 'HRSSA',
                                                  p_person_id 		=> p_person_id,
                                                  p_eventid		=> null,
                                                  p_learningpath_ids	=> to_char(rec.learning_path_id),
                                                  p_itemkey		=> l_item_key);

 end if;
end loop;

end Start_comp_proc_success_attnd;

-- Added this function for  Bug# 7430475
FUNCTION get_no_of_mand_compl_courses(p_lp_enrollment_id IN ota_lp_enrollments.lp_enrollment_id%TYPE)
RETURN number is

cursor get_lp_mand_completed is
select sum(OTA_LRNG_PATH_UTIL.get_no_of_mand_compl_courses(ols.learning_path_section_id, ole.person_id, ole.contact_id))
from ota_lp_enrollments ole, ota_lp_sections ols
where ole.learning_path_id = ols.learning_path_id
and ole.lp_enrollment_id = p_lp_enrollment_id;

l_mand_courses_completed number := 0;

begin
    open get_lp_mand_completed;
    fetch get_lp_mand_completed into l_mand_courses_completed;
    close get_lp_mand_completed;

    return l_mand_courses_completed;

end get_no_of_mand_compl_courses;

function get_lp_current_status(p_lp_enrollment_id in ota_lp_enrollments.lp_enrollment_id%type)
return varchar2 is

CURSOR lp_members IS
	SELECT lpe.lp_enrollment_id,
	       lpe.person_id,
	       lpe.contact_id,
	       lpe.learning_path_id,
	       lpe.path_status_code,
	       lpm.learning_path_member_id,
	       lpm.activity_version_id,
	       lpm.business_group_id,
	       lpm.learning_path_section_id,
	       lpme.lp_member_enrollment_id
	 FROM ota_lp_enrollments lpe,
	      ota_learning_path_members lpm,
	      ota_lp_member_enrollments lpme
	 WHERE lpe.lp_enrollment_id = p_lp_enrollment_id
	       AND lpe.learning_path_id = lpm.learning_path_id
	       --AND lpe.path_status_code <> 'CANCELLED'
	       AND lpe.lp_enrollment_id = lpme.lp_enrollment_id
	       AND lpm.learning_path_member_id = lpme.learning_path_member_id ;

	CURSOR enrolled_class(p_person_id IN ota_learning_paths.person_id%TYPE,
				          p_contact_id IN ota_learning_paths.contact_id%TYPE,
	                      p_activity_version_id IN ota_learning_path_members.activity_version_id%TYPE) IS
	SELECT oav.activity_version_id,
	       evt.event_id,
	       evt.course_start_date,
	       evt.course_start_time,
	       evt.course_end_date,
	       evt.course_end_time,
	       tdb.date_status_changed,
	       tdb.booking_status_type_id,
	       tdb.delegate_person_id,
	       tdb.delegate_contact_id
	  FROM ota_activity_versions oav,
	       ota_events evt,
	       ota_delegate_bookings tdb,
	       ota_booking_status_types bst
	 WHERE oav.activity_version_id = p_activity_version_id
	   AND oav.activity_version_id = evt.activity_version_id
	   AND evt.event_id = tdb.event_id
	   AND bst.booking_status_type_id = tdb.booking_status_type_id
	   AND bst.type = 'P'
	   AND ((p_person_id IS NOT NULL AND tdb.delegate_person_id = p_person_id)
	                   OR (p_contact_id IS NOT NULL AND tdb.delegate_contact_id = p_contact_id));

	l_path_status_code VARCHAR2(30);
	l_enroll_type    VARCHAR2(30);
	l_date_status_changed DATE;

	begin
	if(ota_lrng_path_util.is_path_successful(p_lp_enrollment_id => p_lp_enrollment_id) = 'Y') then
	    return  ota_utility.get_lookup_meaning('OTA_LP_CURRENT_STATUS', 'COMPLETED', 810);
	else
	    for lp_mbr_rec in lp_members loop
	       if(lp_mbr_rec.path_status_code = 'CANCELLED') then
			return ota_utility.get_lookup_meaning('OTA_LP_CURRENT_STATUS', 'CANCELLED', 810);
	       end if;
	      OTA_LRNG_PATH_MEMBER_UTIL.get_enrollment_status(p_person_id => lp_mbr_rec.person_id,
	                               p_contact_id              => lp_mbr_rec.contact_id,
	                               p_activity_version_id     => lp_mbr_rec.activity_version_id,
	                               p_lp_member_enrollment_id => lp_mbr_rec.lp_member_enrollment_id,
	                               p_booking_status_type     => l_enroll_type,
	                               p_date_status_changed     => l_date_status_changed);
	         if(l_enroll_type = 'P') then
	            for lp_cls_rec in enrolled_class(lp_mbr_rec.person_id, lp_mbr_rec.contact_id, lp_mbr_rec.activity_version_id)
	            loop
	                if(trunc(sysdate) <= trunc(nvl(lp_cls_rec.course_end_date, sysdate+1))) then
	                    l_path_status_code := 'ONPLAN';
	                else
	                    l_path_status_code := 'NOTONPLAN';
                    end if;
	            end loop;
	         else
	            l_path_status_code := 'SUBSCRIBED';
	         end if;
	    end loop;
	end if;
	return ota_utility.get_lookup_meaning('OTA_LP_CURRENT_STATUS', l_path_status_code, 810);
end get_lp_current_status;

--
END ota_lrng_path_util;


/
