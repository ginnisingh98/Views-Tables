--------------------------------------------------------
--  DDL for Package OTA_TAV_API_BUSINESS_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TAV_API_BUSINESS_RULES" AUTHID CURRENT_USER as
/* $Header: ottav02t.pkh 120.2 2005/08/11 13:56:56 dhmulia noship $ */
--
--
--
--    Global variables
--
g_version_start_date date :=null;
g_version_end_date  date  :=null;
--
--
--
------------------------------------------------------------------------------
-- |--------------------< set_globals >--------------------------------------|
------------------------------------------------------------------------------
--
procedure set_globals(start_date in date
                     , end_date in date);
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_currency  >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_currency(p_currency_code in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_vendor    >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_vendor (p_vendor_id in number);
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_cost_vals >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_cost_vals
              (p_budget_currency_code in varchar2
              ,p_budget_cost in number
              ,p_actual_cost in number);
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_professional_credit_vals >-------------------|
-- ----------------------------------------------------------------------------
--
procedure check_professional_credit_vals
              (p_professional_credit_type in varchar2
              ,p_professional_credits     in number);
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_professional_credit_type >-------------------|
-- ----------------------------------------------------------------------------
--
procedure check_professional_credit_type
              (p_professional_credit_type in varchar2);
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
-- ---------------------------------------------------------------------------
-- |-----------------------< find_overlapping_versions >---------------------|
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Checks to see if an Activity has overlapping versions. If a version has a
--   start date between another version's start date and end date then
--   overlapping versions exist.
--
Procedure find_overlapping_versions
   (
     p_activity_id in number
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
   Return varchar2;
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
-- |-------------------------< check_dates_update_rud >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate valid resoruce usages
--   for this activity version.
--
Procedure check_dates_update_rud
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ,p_old_start_date        in    date
  ,p_old_end_date          in    date
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
-- |--------------------------< Check_category_dates >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate with respect to category dates.
--
Procedure Check_category_dates
  (p_activity_version_id    in    number
  ,p_start_date             in    date
  ,p_end_date               in    date
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
-- |-------------------------< check_if_tpm_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_training_plan_members  exists.
--
Procedure check_if_tpm_exists
  (
   p_activity_version_id  in  number
  );
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
-- |--------------------< set_superseding_start_date >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--  If the previous version has an end date, the start date defaults to the end
--  date of the previous version plus one
--
Function set_superseding_start_date
  (
   p_activity_id    in  number
  ) Return date;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_multiple_con_version >-----------------------|
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
--
-- ----------------------------------------------------------------------------
-- |--------------------< set_superseding_version >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the Activity Definitions is specified with the
--   MULTIPLE_CON_VERSIONS_FLAG set to 'N' and a new version is created for
--  that activity, the superseded by field on the previous version must be
--  populated with the name of the new version
--
Procedure set_superseding_version
  (
   p_activity_id    in  number
  ,p_activity_version_id in number
  ,p_start_date     in date
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
-- |-----------------------------< check_OE_Lines_exist>----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If The inventory id that link to this Activity has been ordered through
--   Order Line than user cannot change the inventory id.
--
--
Procedure check_OE_lines_exist
(
p_activity_version_id in number,
p_inventory_item_id  in number,
p_organization_id    in number

);

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_Inventory_item_id>-------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If The inventory id is not a valid inventory id in MTL_SYSTEM_ITEMS_B table
--   then user has to provide the correct one.
--
--
--
Procedure check_Inventory_item_id
(
p_activity_version_id in number,
p_inventory_item_id  in number,
p_organization_id    in number
);

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_unique_rco_id>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check uniqueness of rco_id
--
--
--
--
Procedure check_unique_rco_id
(
p_activity_version_id in number,
p_rco_id  		    in number
);

Procedure check_if_tsp_exists
  (
   p_activity_version_id  in  number
  );

-----------------------------------------------------------------------------
-- |-----------------------------< check_if_lpm_exists>-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_learning_path_members exist.
--
  Procedure check_if_lpm_exists
  (
   p_activity_version_id  in  number
  );
  Procedure check_if_comp_exists
  (
   p_activity_version_id  in  number
  );
  Procedure check_if_off_exists
  (
   p_activity_version_id  in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_course_lp_dates>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check dates of Course and Learning Path
--
--
--
--
Procedure check_course_lp_dates
(
p_activity_version_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE);


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

-- ----------------------------------------------------------------------------
-- |-----------------------------< check_course_crt_dates>---------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check dates of Course and certification
--
--
--
--
Procedure check_course_crt_dates
(
p_activity_version_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE);

end ota_tav_api_business_rules;


 

/
