--------------------------------------------------------
--  DDL for Package HR_SECURITY_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_INTERNAL" AUTHID CURRENT_USER as
/* $Header: pesecbsi.pkh 120.0.12010000.2 2009/04/24 14:04:22 rnemani ship $ */

--
-- Package global user-defined types.
--
SUBTYPE g_sec_prof_r IS per_security_profiles%ROWTYPE;
TYPE g_boolean_t  IS TABLE OF BOOLEAN INDEX BY binary_integer;
TYPE g_number_t   IS TABLE OF NUMBER  INDEX BY binary_integer;
TYPE g_per_ids_t  IS TABLE OF per_all_assignments_f.assignment_id%TYPE;


TYPE g_assignments_t IS TABLE OF per_all_assignments_f%ROWTYPE
                        INDEX BY binary_integer;

--
-- Package global constants.
--
g_NONE         CONSTANT NUMBER := 0;
g_ALL          CONSTANT NUMBER := 1;
g_ORG_SEC_ONLY CONSTANT NUMBER := 2;
g_POS_SEC_ONLY CONSTANT NUMBER := 3;
g_PAY_SEC_ONLY CONSTANT NUMBER := 4;
g_PER_SEC_ONLY CONSTANT NUMBER := 5;

g_NO_DEBUG     CONSTANT NUMBER := 0;
g_PIPE         CONSTANT NUMBER := 1;
g_FND_LOG      CONSTANT NUMBER := 2;

--
-- Package global variables.
--
-- The boolean value is irrelevant as
-- inaccessible rows are not added to the tables.
--
g_org_tbl g_boolean_t;
g_pos_tbl g_boolean_t;
g_pay_tbl g_boolean_t;
g_per_tbl g_boolean_t;
g_vac_per_tbl g_boolean_t; -- Added for Bug 8353429
--
-- The index stores the assignment_id
-- and the column value stores the person_id.
--
g_asg_tbl g_number_t;
g_vac_asg_tbl g_number_t; -- Added for Bug 8353429
--
-- ----------------------------------------------------------------------------
-- |--------------------------< evaluate_custom >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Routine to evaluate whether custom restriction is valid for the assignment.
--
-- Prerequisites:
--   A person record must have an assignment
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_restriction_text             Yes  VARCAHR2 The custom restriction.
--   p_assignment_id                Yes  NUMBER   The person's assignment id.
--   p_effective_date               Yes  DATE     The effective date of the
--                                                PERSLM run.
--
-- Post Success:
--   processing continues without commiting. Returns TRUE if restriction is
--   satisfied otherwise returns FALSE.
--
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function evaluate_custom
   (p_assignment_id    in number,
    p_restriction_text in varchar2,
    p_effective_date   in date) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< populate_new_payroll >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process inserts a payroll in to the pay_payroll_list table for
--  all restricted payroll security profiles within the business group or for
--  global profiles. This should be run when a new payroll is created so that
--  all secure users can initially see it.
--
-- Prerequisites:
--   A person record must have been entered in to pay_all_payrolls_f
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  NUMBER   The person's business group
--   p_payroll_id                   Yes  NUMBER   The payroll's id.
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If the person is already in the list, or no appropriate security profiles
--   exist,  no action is taken.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure populate_new_payroll
  (p_business_group_id             in     number
  ,p_payroll_id                    in     number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< populate_new_contact >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process inserts a person in to the per_person_list table for all
--  restricted contact security profiles within their business group or global
--  profiles. This should be run when a new contact is created so that all secure
--  users can initially see them.
--
-- Prerequisites:
--   A person record must have been entered in to per_all_people_f
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  NUMBER   The person's business group
--   p_person_id                    Yes  NUMBER   The person's id.
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If the person is already in the list, or no appropriate security profiles
--   exist,  no action is taken.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure populate_new_contact
  (p_business_group_id             in     number
  ,p_person_id                     in     number);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< populate_new_person >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process inserts a person in to the per_person_list table for all
--  non-view-all security profiles within their business group and global
--  profiles. This should be run when a new employee, applicant or contingent
--  worker is created so that all secure users can initially see them.
--
-- Prerequisites:
--   A person record must have been entered in to per_all_people_f
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  NUMBER   The person's business group
--   p_person_id                    Yes  NUMBER   The person's id.
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If the person is already in the list, or no appropriate security profiles
--   exist,  no action is taken.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure populate_new_person
  (p_business_group_id             in     number
  ,p_person_id                     in     number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< clear_from_person_list >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process clears all of a persons data from the per_person_list
--  table. This should be run to remove the access to a person from secure
--  users before re-populating the list with new settings.
--
-- Prerequisites:
--   A person record must have been entered in to per_all_people_f
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  NUMBER   The person's id.
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If there are no existing records,  no action is taken.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure clear_from_person_list
  (p_person_id             in     number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< add_to_person_list >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process inserts a person in to the per_person_list table for the
--  security profiles that match the assignment. This should be run when an
--  employee's or applicant's assignment is changed.
--  The person is not deleted from the old list, so no access is removed.
--
-- Prerequisites:
--   A person record must have been entered in to per_all_people_f
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     The date of the assignment details
--   p_assignment_id                Yes  NUMBER   The person's assignment id.
--   p_business_group_id            No   NUMBER   The BG ID if we are doing
--                                                profiles in a BG
--   p_generation_scope             No   VARCAHR2 Scope of generation process.
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If the person is already in the list, or no appropriate security profiles
--   exist,  no action is taken.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure add_to_person_list
  (p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number   default null
  ,p_generation_scope              in     varchar2 default 'ALL_PROFILES');
--
-- ----------------------------------------------------------------------------
-- |--------------------< clear_from_person_list_changes >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process clears all of a persons data from the per_person_list_changes
--  table. This should be run when an ex-employee or ex-applicant become a current
--  employee or applicant so that the security lists are based on the new assignments.
--
-- Prerequisites:
--   A person record must have been entered in to per_all_people_f
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  NUMBER   The person's id.
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If there are no existing records,  no action is taken.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure clear_from_person_list_changes
  (p_person_id             in     number);
--
-- ----------------------------------------------------------------------------
-- |---------------------< re_enter_person_list_changes >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process inserts a person in to the per_person_list_changes table
--  for the security profiles that match the their last employee or applicant
--  assignment. This should be run when a re-hire or re-application is canceled so
--  that the ex-employee or ex-applicant is visible as of their old details.
--  The person is not deleted from per_person_list, so this should be done seperatly.
--
-- Prerequisites:
--   A person record must have been entered in to per_all_people_f
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  NUMBER   The person's id.
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If the person is already in the list, or no appropriate security profiles
--   exist, or they do not have an old assignment,  no action is taken.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure re_enter_person_list_changes
  (p_person_id             in     number);
----
-- ----------------------------------------------------------------------------
-- |----------------------< copy_to_person_list_changes >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process inserts a person in to the per_person_list_changes table
--  for every row in the per_person_list table. This should be run when employment
--  or an application is terminated so that the ex-employee or ex-applicant is
--  visible as of their last details.
--  The person is not deleted from per_person_list.
--
-- Prerequisites:
--   A person record must have been entered in to per_all_people_f
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  NUMBER   The person's id.
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If the person is already in the list, or there are no entries in per_person_list,
--   no action is taken.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure copy_to_person_list_changes
  (p_person_id             in     number);
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< grant_access_to_person >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process inserts a row in to the per_person_list table
--  to allow a grantee to see a person outside of their security profile.
--
-- Prerequisites:
--   A person record must have been entered in to per_all_people_f
--   The granted user must have the a security profile assigned to them in some
--   responsibility which allows granted users.
--   The security profile must allow granted users.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  NUMBER   The person's id.
--   p_granted_user_id              Yes  NUMBER   The id of the user who is
--                                                granted access to the person
--
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If the user already has access then no action is taken.
--   If the person or granted user do not exist then an error
--   will be raised.
--   If the security profile does not exist for the grantee which allows
--   granted users then an error will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure grant_access_to_person
  (p_person_id             in     number
  ,p_granted_user_id       in     number);
--
-- ----------------------------------------------------------------------------
-- |----------------------< revoke_access_from_person >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This support process deletes a row from the per_person_list table
--  to revoke access for a grantee to see a person outside of their security
--  profile. If no single grantee is explicitly identified then revoke access
--  for all grantees.
--
-- Prerequisites:
--   The grantee must have access to see the person
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  NUMBER   The person's id.
--   p_granted_user_id              Yes  NUMBER   The id of the user who is
--                                                granted access to the person
--
--
-- Post Success:
--   processing continues without commiting.
--
--
-- Post Failure:
--   If the granted_user did not have access to see the person then an error
--   will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure revoke_access_from_person
  (p_person_id             in     number
  ,p_granted_user_id       in     number default null);
--
-- ----------------------------------------------------------------------------
-- |----------------------< op >----------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This is a wrapper debug utility for hr_utility.trace and concurrent
--  request logging.  PYUPIP can not easily be enabled for concurrent
--  requests because each thread uses a different SQL session ID; this
--  wrapper utility writes output to concurrent request logs making
--  debugging easier.
--
-- Prerequisites:
--   If using PYUPIP, it must be enabled.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_msg                          Yes  VARCHAR2 The debug output.
--
-- Post Success:
--   Processing continues without commiting.
--
-- Post Failure:
--   This procedure should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE op
    (p_msg            IN VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |----------------------< op >----------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This is an overloaded version of the above procedure. This takes
--  one additional parameter that specifies the location of the code.
--
-- Prerequisites:
--   If using PYUPIP, it must be enabled.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_msg                          Yes  VARCHAR2 The debug output.
--   p_location                     Yes  NUMBER   Location of code.
--
-- Post Success:
--   Processing continues without commiting.
--
-- Post Failure:
--   This procedure should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE op
    (p_msg            IN VARCHAR2
    ,p_location       IN NUMBER);
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_assignments >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Given a person, this function returns a PL/SQL table of records
--  detailing the person's employee and contingent worker assignments.
--  The assignment details are cached to prevent unncessary queries.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  NUMBER   ID of person.
--   p_effective_date               Yes  DATE     Effective date on which
--                                                to get the assignments.
--
-- Post Success:
--   Processing continues without commiting.
--
-- Post Failure:
--   The function returns a null PL/SQL table; no error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION get_assignments
    (p_person_id      IN NUMBER
    ,p_effective_date IN DATE)
RETURN g_assignments_t;
--
-- ----------------------------------------------------------------------------
-- |----------------------< org_access_known >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Returns a boolean to indicate whether the organization security
--  permissions for the user concerned have already been evaluated
--  and cached.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   Processing continues without commiting.
--
-- Post Failure:
--   The function should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION org_access_known
RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |----------------------< pos_access_known >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Returns a boolean to indicate whether the position security
--  permissions for the user concerned have already been evaluated
--  and cached.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   Processing continues without commiting.
--
-- Post Failure:
--   The function should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION pos_access_known
RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |----------------------< pay_access_known >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Returns a boolean to indicate whether the payroll security
--  permissions for the user concerned have already been evaluated
--  and cached.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   Processing continues without commiting.
--
-- Post Failure:
--   The function should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION pay_access_known
RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |----------------------< per_access_known >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Returns a boolean to indicate whether the person security
--  permissions for the user concerned have already been evaluated
--  and cached.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   Processing continues without commiting.
--
-- Post Failure:
--   The function should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION per_access_known
RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |----------------------< show_organization >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Returns a TRUE/FALSE VARCHAR2 that determines whether the specified
--  organization can be seen for the given security profile cache.  This
--  function simply checks the cached org table and so if the profile is
--  "view all orgs" no organizations will exist in the table.  Before using
--  this function, check whether the profile restricts by organization first.
--
-- Prerequisites:
--   Verify that the profile restricts by organization prior to calling this
--   procedure: it will return FALSE if called with a View All or View All
--   Orgs profile context.
--
-- In Parameters:
--   p_organization_id: uniquely identifies the organization for which access
--                      is being checked.
--
-- Post Success:
--   The function returns 'TRUE' or 'FALSE'.
--
-- Post Failure:
--   The function should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION show_organization
    (p_organization_id IN NUMBER)
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< show_position >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Returns a TRUE/FALSE VARCHAR2 that determines whether the specified
--  position can be seen for the given security profile cache.  This
--  function simply checks the cached pos table and so if the profile is
--  "view all pos" no positions will exist in the table.  Before using
--  this function, check whether the profile restricts by position first.
--
-- Prerequisites:
--   Verify that the profile restricts by position prior to calling this
--   procedure: it will return FALSE if called with a View All or View All
--   Pos profile context.
--
-- In Parameters:
--   p_position_id: uniquely identifies the position for which access
--                  is being checked.
--
-- Post Success:
--   The function returns 'TRUE' or 'FALSE'.
--
-- Post Failure:
--   The function should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION show_position
    (p_position_id IN NUMBER)
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< show_payroll >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Returns a TRUE/FALSE VARCHAR2 that determines whether the specified
--  payroll can be seen for the given security profile cache.  This
--  function simply checks the cached pay table and so if the profile is
--  "view all pay" no payrolls will exist in the table.  Before using
--  this function, check whether the profile restricts by payroll first.
--
-- Prerequisites:
--   Verify that the profile restricts by payroll prior to calling this
--   procedure: it will return FALSE if called with a View All or View All
--   Pay profile context.
--
-- In Parameters:
--   p_payroll_id: uniquely identifies the payroll for which access
--                 is being checked.
--
-- Post Success:
--   The function returns 'TRUE' or 'FALSE'.
--
-- Post Failure:
--   The function should not fail.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION show_payroll
    (p_payroll_id IN NUMBER)
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< evaluate_access >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Evaluates security for a particular user and security profile pair.
--  The permissions are stored in cache and used by the secure views
--  for fast access.
--
-- Prerequisites:
--  When user-based security is used, the application contexts should be set,
--  for example, by virtue of starting an applications session or by
--  running fnd_global.apps_initialize.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   Number   ID of person.
--   p_user_id                      Yes  Number   ID of user; user's person
--                                                should match the ID
--                                                above.
--   p_effective_date               Yes  Date     Effective date on which
--                                                to evaluate security.
--   p_sec_prof_rec                 Yes  Record   PL/SQL record of security
--                                                profile, used to evaluate
--                                                security.
--   p_what_to_evaluate             No   Number   Indicates what security
--                                                should be assessed to
--                                                avoid unncessarily
--                                                evaluating security at
--                                                sign-on.
--   p_use_static_lists             No   Boolean  If the static lists
--                                                are not used
--                                                (created using PERSLM)
--                                                permissions are
--                                                evaluated dynamically.
--   p_update_static_lists          No   Boolean  Static lists can be
--                                                automatically updated
--                                                instead of updating through
--                                                PERSLM.
--   p_debug                        No   Number   Indicates the type of
--                                                debugging to use: PIPE
--                                                or concurrent request.
--
-- Post Success:
--   Permissions are cached; processing continues.
--
-- Post Failure:
--   Permissions are not cached; no error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE evaluate_access
    (p_user_id             IN NUMBER
    ,p_effective_date      IN DATE
    ,p_sec_prof_rec        IN g_sec_prof_r
    ,p_person_id           IN NUMBER       DEFAULT NULL
    ,p_what_to_evaluate    IN NUMBER       DEFAULT g_PER_SEC_ONLY
    ,p_use_static_lists    IN BOOLEAN      DEFAULT TRUE
    ,p_update_static_lists IN BOOLEAN      DEFAULT FALSE
    ,p_debug               IN NUMBER       DEFAULT g_NO_DEBUG);
--
-- ----------------------------------------------------------------------------
-- |----------------------< user_in_static_lists >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Returns a boolean to indicate whether the specified user has
--  permissions stored in any of the static lists.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_user_id                      Yes  Number   ID of user.
--   p_security_profile_id          Yes  Number   ID of security profile.
--
-- Post Success:
--   A boolean is returned to indicate whether this user has any permissions
--   stored in static lists for this security profile.
--
-- Post Failure:
--   The boolean returns FALSE.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION user_in_static_lists
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_static_lists_for_user >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Deletes the static lists for a specified user and specified security
--  profile. No commit is issued.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_user_id                      Yes  Number   ID of user.
--   p_security_profile_id          Yes  Number   ID of security profile.
--
-- Post Success:
--   Static list permissions are deleted for the specified user and
--   security profile.
--
-- Post Failure:
--   The permissions are not deleted; no error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
PROCEDURE delete_static_lists_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER);
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_effective_date >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Fetch the effective date used to assess security.  This defaults
--  to the system date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None
--
-- Post Success:
--   Returns the effective date.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
FUNCTION get_effective_date RETURN DATE;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_what_to_evaluate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Fetch the "what to evaluate" security type.  This allows the assessment
--  of security permissions to be delayed from sign-on to on-demand.
--  Alternatively, it allows all permissions to be evaluated on the spot.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None
--
-- Post Success:
--   Returns the what to evaluate type.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
FUNCTION get_what_to_evaluate RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_use_static_lists >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Determines whether static lists should be used or not.  This only
--   applies where appropriate, for example, user-based security does not
--   use static lists unless the user has had static lists built.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None
--
-- Post Success:
--   Returns a boolean indicating whether static lists should be used.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
FUNCTION get_use_static_lists RETURN BOOLEAN;
--

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_security_list_for_bg >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Deletes all the entries for a given business group from the following
--   security list tables:
--
--           pay_security_payrolls
--           pay_payroll_list
--           per_person_list
--           per_position_list
--           per_organization_list
--           per_security_profiles
--
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            YES  Number   ID of Business Group.

--
-- Post Success:
--   All entries for a business group in the security list tables are removed.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
  PROCEDURE delete_security_list_for_bg(p_business_group_id number);
--
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_per_from_security_list >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Removes a person entries from static security list.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name               Reqd   Type     Description
--   p_person_id        YES    Number   ID of Person.
--
-- Post Success:
--   A person entries are deleted from per_person_list table.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
 PROCEDURE delete_per_from_security_list(p_person_id  in number);
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_org_to_security_list >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Adds an organization entry for a security profile to static
--   security list.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                    Reqd   Type     Description
--   P_Security_Profile_Id   YES    Number   ID of security Profile
--   p_organization_id       YES    Number   ID of Person.
--
-- Post Success:
--   An organization entry is added for a security profile in the
--   per_organization_list table.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
  PROCEDURE add_org_to_security_list(p_security_profile_id  in number,
                                     p_organization_id      in number);
--
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_org_from_security_list >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Removes organization entries for specified organization from the static
--   security list.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name               Reqd   Type     Description
--   p_organization_id  YES    Number   ID of Person.
--
-- Post Success:
--   An organization entries are deleted from per_organization_list table
--   for a specified organization_id.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
  PROCEDURE delete_org_from_security_list(p_organization_id    in number);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< add_pos_to_security_list >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Adds a position entry for a security profile to static
--   security list.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                    Reqd   Type     Description
--   P_Security_Profile_Id   YES    Number   ID of security Profile
--   p_position_id           YES    Number   ID of Position
--
-- Post Success:
--   An position entry is added for a security profile in the
--   per_position_list table.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
  PROCEDURE add_pos_to_security_list(p_security_profile_id  in number,
                                     p_position_id          in number);
--
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_pos_from_security_list >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Removes position entries for specified position from the static
--   security list.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name               Reqd   Type     Description
--   p_position_id      YES    Number   ID of Position.
--
-- Post Success:
--   A position entries are deleted from per_position_list table
--   for a specified position_id.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
  PROCEDURE delete_pos_from_security_list(p_position_id    in number);
--
--
-- ----------------------------------------------------------------------------
-- |----------------- delete_payroll_from_security_list >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Removes payroll entries for specified payroll from the static
--   security list.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name               Reqd   Type     Description
--   p_payroll_id       YES    Number   ID of Payroll.
--
-- Post Success:
--   A payroll entries are deleted from pay_payroll_list table
--   for a specified payroll_id.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
  PROCEDURE delete_pay_from_security_list(p_payroll_id     number);
--
END hr_security_internal;

/
