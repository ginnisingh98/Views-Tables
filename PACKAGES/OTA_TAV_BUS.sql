--------------------------------------------------------
--  DDL for Package OTA_TAV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TAV_BUS" AUTHID CURRENT_USER as
/* $Header: ottav01t.pkh 120.1.12010000.4 2009/10/13 12:08:46 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_min_max_values >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The minimum attendees must be less then or equal to the maximum attendees.
--
Procedure check_min_max_values
  (
   p_min  in  number
  ,p_max  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_unique_name >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the unique key.
--
Procedure check_unique_name
  (
   p_business_group_id in number
  ,p_activity_id       in number
  ,p_version_name  in  varchar2
  ,p_activity_version_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_superseding_version >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   A activity version may not be superseded ba a activity whose end_date
--   is greater than it's own. The supersedinthg activity version must have
--   an end date greater than the end date of the activity it supersedes.
--
Procedure check_superseding_version
  (
   p_sup_act_vers_id in number
  ,p_end_date        in  date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_user_status >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The user status must be in the domain 'Activity User Status'.
--
Procedure check_user_status
  (
   p_user_status  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_success_criteria >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The success criteria must be in the domain 'Activity Success Criteria'.
--
Procedure check_success_criteria
  (
   p_succ_criteria  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_activity_version_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Return the surrogate key from a passed parameter
--
Function get_activity_version_id
  (
   p_activity_id      in     number
  ,p_version_name     in     varchar2
  )
   Return number;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_activity_version_name >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Ruturn the activity version name.
--
Function get_activity_version_name
  (
   p_activity_version_id   in   number
  )
   Return VARCHAR2;
--
pragma restrict_references ( get_activity_version_name, WNDS, WNPS);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_start_end_dates >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Startdate must be less than, or equal to, enddate.
--
Procedure check_start_end_dates
  (
   p_start_date     in     date
  ,p_end_date       in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_ple >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate valid pricing details
--   for this activity version.
--
Procedure check_dates_update_ple
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_tbd >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate booking deals
--   questions for this activity version.
--
Procedure check_dates_update_tbd
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_evt >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate events
--   for this activity version.
--   This requires a check to ensure that the activity version dates do not
--   invalidate the Event Booking DAtes or the Event Course Dates if either
--   have been entered.
--
Procedure check_dates_update_evt
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_evt_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_events exists.
--
Procedure check_if_evt_exists
  (
   p_activity_version_id  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_off_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_events exists.
--
Procedure check_if_off_exists
  (
   p_activity_version_id  in  number
  );
--

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tbd_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_booking_deals exists.
--
Procedure check_if_tbd_exists
  (
   p_activity_version_id  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_ple_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_price_lists_entries exists.
--
Procedure check_if_ple_exists
  (
   p_activity_version_id  in  number
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tpm_exists >--------------------------|
-- ----------------------------------------------------------------------------
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_training_plan_members exist.
--
Procedure check_if_tpm_exists
  (
   p_activity_version_id  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tav_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_activity_versions exists where this activity version has superseded
--   another earlier activity version.
--
Procedure check_if_tav_exists
  (
   p_activity_version_id  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_duration_units >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The duration units must be in the domain 'Units'.
--
Procedure check_duration_units
  (
   p_duration_units  in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_duration >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The duration must be a positive integer greater than zero.
--
Procedure check_duration
  (
   p_duration  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_language >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The language must be in the domain 'Languages'.
--
Procedure check_language
  (
   p_language_id  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_controlling_person >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The controlling person should exist as a valid person on the Validity
--   Start Date of the Activity Version.
--
Procedure check_controlling_person
  (
   p_person_id  in  number
  ,p_date       in  date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_multiple_con_version >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the Activity Definitions is specified with the
--   MULTIPLE_CON_VERSIONS_FLAG set to 'N' then Versions of the Activity may not
--   have overlapping validity dates.
--
Procedure check_multiple_con_version
  (
   p_activity_id    in  number,
   p_activity_version_id in number,
   p_start_date in date,
   p_end_date   in date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< check_version_after_supersede >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the Activity Definitions is specified with the
--   MULTIPLE_CON_VERSIONS_FLAG set to 'N' and the latest Activity Version has
--   been superseded by a Version of a different Activity, then new Version of
--   the Activity are not allowed (because there would be confusion over which
--   is the valid version of the activity, the new one or the superseding one).
--
Procedure check_version_after_supersede
  (
   p_activity_id    in  number
  );
--


-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_category >---------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check whether course is getting created under root category
--
--
--

PROCEDURE chk_category
 (
  p_activity_id                     IN number
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
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Arguments:
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
--   For insert, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_tav_shd.g_rec_type);
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
-- In Arguments:
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
--   For update, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ota_tav_shd.g_rec_type);
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
-- In Arguments:
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
--   For delete, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tav_shd.g_rec_type);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This function will be used by the user hooks. Currently this will be used
--   hr_competence_element_api business processes and in future will be made use
--   of by the user hooks of activity_versions business process.
--
-- Pre Conditions:
--   This function will be called by the user hook packages.
--
-- In Arguments:
--   Activity_version_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Errors out
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--------------------------------------------------------------------------------
--
Function return_legislation_code
         (  p_activity_version_id     in number
          ) return varchar2;
--
Procedure check_if_tsp_exists
  (
   p_activity_version_id  in  number
  );
--
  Procedure check_if_lpm_exists
  (
   p_activity_version_id  in  number
  );
--
 Procedure check_if_comp_exists
  (
   p_activity_version_id  in  number
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_noth_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_notrng_histories exists where this activity version.
--
Procedure check_if_noth_exists
  (
   p_activity_version_id  in  number
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_crt_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_certification_members exists where this activity version.
--
Procedure check_if_crt_exists
  (
   p_activity_version_id  in  number
  );

end ota_tav_bus;

/
