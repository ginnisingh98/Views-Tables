--------------------------------------------------------
--  DDL for Package IRC_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: irutil.pkh 120.2.12010000.16 2010/05/20 06:57:32 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------<  SET_SAVEPOINT  >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper to be called from java code.  This sets a savepoint that can be rolled
-- back to.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

PROCEDURE SET_SAVEPOINT;


--
-- ----------------------------------------------------------------------------
-- |----------------------<  ROLLBACK_TO_SAVEPOINT  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper to be called from java code.  This rolls back to the savepoint. Used
-- after an api_validate.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

PROCEDURE ROLLBACK_TO_SAVEPOINT;

-- -------------------------------------------------------------------
-- |--------------------< get_home_page_function >-------------------|
-- -------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper to be called from java code.  This rerturns the function for the passed
-- in responsibility_id.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

procedure GET_HOME_PAGE_FUNCTION(p_responsibility_id in varchar2
                                ,p_function out nocopy varchar2);

function removeTags(p_in varchar2) return varchar2;
function removeTags(p_in clob) return varchar2;

-- ----------------------------------------------------------------------------
-- |-----------------------<  GET_CURRENT_EMPLOYER  >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions returns a person's current employer.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   A Person ID, and an effective date.
-- Post Success:
--   Returned varchar of current employer name.
-- Post Failure:
--   No explicit error catching occurs.  An empty string returns if no row found.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

FUNCTION GET_CURRENT_EMPLOYER  (p_person_id  per_all_people_f.person_id%TYPE default null,
                                p_eff_date  date  default trunc(sysdate))
  RETURN VARCHAR2;

FUNCTION GET_CURRENT_EMPLOYER_PTY  (p_party_id number,
                                p_eff_date  date  default trunc(sysdate))
  RETURN VARCHAR2;


-- ----------------------------------------------------------------------------
-- |-------------------------<  GET_MAX_QUAL_TYPE  >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions returns the highest ranking qualification that a person
--  posesses.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   A Person ID
-- Post Success:
--   Returned varchar of highest ranked qualification.
-- Post Failure:
--   No explicit error catching occurs.  An empty string returns if no row found.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

FUNCTION GET_MAX_QUAL_TYPE  (p_person_id  per_all_people_f.person_id%TYPE default null)
  RETURN VARCHAR2;
FUNCTION GET_MAX_QUAL_TYPE_PTY  (p_party_id NUMBER)
  RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |-----------------------<  GET_EMP_UPT_FOR_PERSON >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions returns a person's User Person Type if they are an employee.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   A Person ID, and an effective date.
-- Post Success:
--   Returned varchar of employee user person type.
-- Post Failure:
--   No explicit error catching occurs.  An empty string returns if no row found.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

FUNCTION GET_EMP_UPT_FOR_PERSON (p_person_id  per_all_people_f.person_id%TYPE default null,
                                p_eff_date  date  default trunc(sysdate))
  RETURN VARCHAR2;
--
FUNCTION GET_EMP_UPT_FOR_PARTY (p_party_id  number,
                                p_eff_date  date  default trunc(sysdate))
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |-----------------------<  GET_APL_UPT_FOR_PERSON  >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions returns a person's User Person Type if they are an applicant.
--  If they are also an employee and not in the person viewing's security profile,
--  an empty string will be returned.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   A Person ID, and an effective date.
-- Post Success:
--   Returned varchar of applicant user person type.
-- Post Failure:
--   No explicit error catching occurs.  An empty string returns if no row found.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

FUNCTION GET_APL_UPT_FOR_PERSON (
                                p_person_id  per_all_people_f.person_id%TYPE default null,
                                p_eff_date  date  default trunc(sysdate))
  RETURN VARCHAR2;
--
FUNCTION GET_APL_UPT_FOR_PARTY (
                                p_party_id  number,
                                p_eff_date  date  default trunc(sysdate))
  RETURN VARCHAR2;


-- ----------------------------------------------------------------------------
-- |-----------------------<  GET_EMP_SPT_FOR_PERSON >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions returns a person's Employee System Person Type
--
-- Prerequisites:
--   This is a public function, mainly called by VO's
--   in the iRecruitment web module.
--
-- In Parameters:
--   A Person ID, and an effective date.
-- Post Success:
--   Returned varchar of employee system person type.
-- Post Failure:
--   No explicit error catching occurs.  An empty string returns if no row found.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}

FUNCTION GET_EMP_SPT_FOR_PERSON (
                                p_person_id  per_all_people_f.person_id%TYPE default null,
                                p_eff_date  date  default trunc(sysdate))
  RETURN VARCHAR2;

--
-- -------------------------------------------------------------------------
-- |----------------------< get_recruitment_person_id >--------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions returns the recruitment person id. It first checks if
--  the party has a person with a notification preference. If it doesn't
--  find a record it then checks if a person exists in the default
--  business group for the party. If not, the person with the earliest
--  start date is returned.
--
-- Prerequisites:
--
-- In Parameters:
--   A Person ID,
-- Post Success:
--   Returned person ID
-- Post Failure:
--   No explicit error catching occurs.  A null returns if no row found.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
--
--
FUNCTION GET_RECRUITMENT_PERSON_ID
   (p_person_id                 IN     per_all_people_f.person_id%TYPE,
        p_effective_date            IN     per_all_people_f.effective_start_date%TYPE default trunc(sysdate))
  RETURN per_all_people_f.person_id%TYPE;

-- ----------------------------------------------------------------------------
-- |-----------------------< IS_OPEN_PARTY >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION IS_OPEN_PARTY (p_party_id  number
                       ,p_eff_date  date  )
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |-----------------------< is_internal_person >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION is_internal_person (p_person_id  number
                            ,p_eff_date   date)
  RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |-----------------------< is_internal_email >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION is_internal_email (p_email_address varchar2
                           ,p_eff_date      date)
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |-----------------------< is_internal_person >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION is_internal_person (p_user_name varchar2
                            ,p_eff_date  date  )
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |-----------------------< is_function_allowed >-------------------------|
-- ----------------------------------------------------------------------------
--
-- TEST
--   Test if function is accessible under current responsibility.
-- IN
--   function_name - function to test
--   p_test_maint_availability-   'Y' (default) means check if available for
--                             current value of profile APPS_MAINTENANCE_MODE
--                             'N' means the caller is checking so it's
--                             unnecessary to check.
-- RETURNS
--  TRUE if function is accessible
FUNCTION is_function_allowed(p_function_name varchar2
                            ,p_test_maint_availability in varchar2 default 'Y')
  RETURN VARCHAR2;


-- ----------------------------------------------------------------------------
-- |-----------------------<  GET_LAST_QUAL_PTY  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This functions returns a person's latest qualifications associated to esablishment.
--
-- Prerequisites:
--   This is a public function, mainly called by VO's representing search results
--   in the iRecruitment web module.
--
-- In Parameters:
--   A Party ID.
--   Effective Date.
-- Post Success:
--   Returned varchar of latest qualification title.
-- Post Failure:
--   No explicit error catching occurs.  An empty string returns if no row found.
--
-- Developer Implementation Notes:
-- Added GET_LAST_QUAL_PTY by deenath to fix Bug #4726469
--
-- {End Of Comments}
FUNCTION GET_LAST_QUAL_PTY(p_party_id NUMBER,
                           p_eff_date DATE   DEFAULT TRUNC(SYSDATE))
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |-----------------------<  irc_applicant_tracking  >-----------------------|
-- ----------------------------------------------------------------------------
procedure irc_applicant_tracking(
 p_person_id             in         number
,p_apl_profile_access_id in         number
,p_object_version_number out nocopy number
);

-- ----------------------------------------------------------------------------
-- |-----------------------<  irc_mark_appl_considered  >---------------------|
-- ----------------------------------------------------------------------------
procedure irc_mark_appl_considered(
p_effective_date               in     date
,p_assignment_id                in     number
,p_attempt_id                   in     number
,p_assignment_details_id        in     number
,p_qualified                    in     varchar2
,p_considered                   in     varchar2
,p_update_mode                  in     varchar2
,p_details_version              out nocopy number
,p_effective_start_date         out nocopy date
,p_effective_end_date           out nocopy date
,p_object_version_number        out nocopy number
);

-- ----------------------------------------------------------------------------
-- |-----------------------<  irc_mark_appl_considered  >---------------------|
-- ----------------------------------------------------------------------------
procedure irc_mark_appl_considered(
p_assignment_id                in     number
);

-- ----------------------------------------------------------------------------
-- |-----------------------<  getAMETxnDetailsForOffer  >---------------------|
-- ----------------------------------------------------------------------------
function getAMETxnDetailsForOffer (p_offerId in varchar2)
return varchar2;

-- ----------------------------------------------------------------------------
-- |-----------------------<  copy_candidate_details  >---------------------|
-- ----------------------------------------------------------------------------
procedure copy_candidate_details (
p_assignment_id                in     number
);

-- ----------------------------------------------------------------------------
-- |---------------------------<  get_fte_factor  >---------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_fte_factor(p_assignment_id number
                       ,p_asg_hours_per_year NUMBER
                       ,p_position_id NUMBER
                       ,p_organization_id NUMBER
                       ,p_business_group_id NUMBER
                       ,p_effective_date IN DATE)
RETURN NUMBER;


--
--
-- ----------------------------------------------------------------------------
-- |---------------------< getVacancyRunFunctionUrl >--------------------------|
-- ----------------------------------------------------------------------------
--
function getVacancyRunFunctionUrl(
                                  p_function_id number,
                                  p_vacancy_id number,
                                  p_posting_id number,
                                  p_site_id number
                                 ) return varchar2 ;
--
--

-- ----------------------------------------------------------------------------
-- |-----------------------<  getJobSearchItems  >-----------------------------|
-- ----------------------------------------------------------------------------

 function getJobSearchItems(l_keyword varchar2 default null,
l_job varchar2 default null,
l_employee varchar2 default null,
l_contractor varchar2 default null,
l_dateposted varchar2 default null,
l_travelpercent number default null,
l_workathome varchar2 default null,
l_employmentstatus varchar2 default null,
l_min_salary  in varchar2 default null,
l_currency in varchar2 default null,
l_lat in varchar2 default null,
l_long in varchar2 default null,
l_dist in varchar2 default null,
l_location in varchar2 default null,
l_attribute_category in varchar2 default null,
l_attribute1 in varchar2 default null,
l_attribute2 in varchar2 default null,
l_attribute3 in varchar2 default null,
l_attribute4 in varchar2 default null,
l_attribute5 in varchar2 default null,
l_attribute6 in varchar2 default null,
l_attribute7 in varchar2 default null,
l_attribute8 in varchar2 default null,
l_attribute9 in varchar2 default null,
l_attribute10 in varchar2 default null,
l_attribute11 in varchar2 default null,
l_attribute12 in varchar2 default null,
l_attribute13 in varchar2 default null,
l_attribute14 in varchar2 default null,
l_attribute15 in varchar2 default null,
l_attribute16 in varchar2 default null,
l_attribute17 in varchar2 default null,
l_attribute18 in varchar2 default null,
l_attribute19 in varchar2 default null,
l_attribute20 in varchar2 default null,
l_attribute21 in varchar2 default null,
l_attribute22 in varchar2 default null,
l_attribute23 in varchar2 default null,
l_attribute24 in varchar2 default null,
l_attribute25 in varchar2 default null,
l_attribute26 in varchar2 default null,
l_attribute27 in varchar2 default null,
l_attribute28 in varchar2 default null,
l_attribute29 in varchar2 default null,
l_attribute30 in varchar2 default null,
langcode in varchar2 default null,
enterprise in varchar2 default null,
l_drvdlocal in varchar2 default null,
l_locid in varchar2 default null)
return clob;

-- ----------------------------------------------------------------------------
-- |-----------------------<  getJobSearchChannel  >--------------------------|
-- ----------------------------------------------------------------------------

function getJobSearchChannel(langcode in varchar2 default null,
enterprise in varchar2 default null)
return clob;


FUNCTION GET_RATE_SQL
   (l_from_currency               IN     varchar2,
    l_to_currency                 IN     varchar2,
    l_exchange_date               IN     date)
 RETURN number;

function get_exchange_date(profile_date varchar2,
                           l_from_currency varchar2)
return date;

function is_salary_basis_required(p_business_group_id  in number,
                                    p_organization_id  in number,
                                    p_position_id in number,
                                    p_grade_id in number,
                                    p_job_id in number
                                    )
return varchar2;
FUNCTION is_proposed_salary_required
                                    (
                                            p_salary_basis_id   IN NUMBER
                                    )
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< GET_PERSON_TYPE >----------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_person_type (p_party_id  number
                         ,p_eff_date  date  )
  RETURN VARCHAR2;
--
END IRC_UTILITIES_PKG;

/
