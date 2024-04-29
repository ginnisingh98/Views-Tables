--------------------------------------------------------
--  DDL for Package PER_PER_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PER_BUS1" AUTHID CURRENT_USER as
/* $Header: peperrhi.pkh 120.2.12010000.1 2008/07/28 05:14:29 appldev ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------<  df_update_validate  >---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Calls the descriptive flex validation stub (per_per_flex.df) if either
--   the attribute_category or attribute1..30 have changed.
--
-- Pre-conditions:
--   Can only be called from update_validate
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the attribute_category and attribute1.30 haven't changed then the
--   validation is not performed and the processing continues.
--   If the attribute_category or attribute1.30 have changed then the
--   per_per_flex.df validates the descriptive flex. If an exception is
--   not raised then processing continues.
--
-- Post Failure:
--   If an exception is raised within this procedure or lower
--   procedure calls then it is raised through the normal exception
--   handling mechanism.
--
-- Access Status:
--   Internal Table Handler Use Only.
-- ---------------------------------------------------------------------------
procedure df_update_validate
  (p_rec in per_per_shd.g_rec_type
  );
--
--  ---------------------------------------------------------------------------
--  |------------------<  chk_unsupported_attributes  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that all unsupported attributes are set to null.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_fast_path_employee
--    p_order_name
--    p_projected_start_date
--    p_rehire_authorizor
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - All unsupported attributes are set to null.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Any of the unsupported attributes are set to null;
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_unsupported_attributes
  (p_person_id               in     per_all_people_f.person_id%TYPE
  ,p_fast_path_employee      in     per_all_people_f.fast_path_employee%TYPE
  ,p_order_name              in     per_all_people_f.order_name%TYPE
  ,p_projected_start_date    in     per_all_people_f.projected_start_date%TYPE
  ,p_rehire_authorizor       in     per_all_people_f.rehire_authorizor%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_correspondence_language  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the Correspondence language is a valid LANGUAGE_CODE
--      in the table FND_LANGUAGES.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_effective_date
--    p_correspondence_language
--    p_object_version_number
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_correspondence_language
  (p_person_id               in     per_all_people_f.person_id%TYPE
  ,p_effective_date          in     date
  ,p_correspondence_language in     per_all_people_f.correspondence_language%TYPE
  ,p_object_version_number   in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_coord_ben_med_cvg_dates  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the coverage end date is after the coverage start date.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_coord_ben_med_cvg_strt_dt
--    p_coord_ben_med_cvg_end_dt
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_coord_ben_med_cvg_dates
  (p_coord_ben_med_cvg_strt_dt in  date
  ,p_coord_ben_med_cvg_end_dt  in  date
  );
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_coord_ben_med_details  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the benefit medical details if entered must include
--       at minimum the insurer carrier name.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_coord_ben_med_cvg_strt_dt
--    p_coord_ben_med_cvg_strt_dt
--    p_coord_ben_med_ext_er
--    p_coord_ben_med_pl_name
--    p_coord_ben_med_insr_crr_name
--    p_coord_ben_med_insr_ident
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_coord_ben_med_details
  (p_coord_ben_med_cvg_strt_dt    in  date
  ,p_coord_ben_med_cvg_end_dt     in  date
  ,p_coord_ben_med_ext_er         in  varchar2
  ,p_coord_ben_med_pl_name        in  varchar2
  ,p_coord_ben_med_insr_crr_name  in  varchar2
  ,p_coord_ben_med_insr_crr_ident in  varchar2
  );
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_other_coverages  >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the no coverage flag is set correctly whenever another
--      benefit coverage is defined.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_attribute10
--    p_coord_ben_med_insr_crr_name
--    p_coord_ben_med_cvg_end_dt
--    p_coord_ben_no_cvg_flag
--    p_effective_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_other_coverages
  (p_attribute10                 in varchar2
  ,p_coord_ben_med_insr_crr_name in varchar2
  ,p_coord_ben_med_cvg_end_dt    in date
  ,p_coord_ben_no_cvg_flag       in varchar2
  ,p_effective_date              in date
  );
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_fte_capacity  >----------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the fte capacity is inthe range 0.0 to 100.0
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
--    p_fte_capacity
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_fte_capacity
  (p_person_id               in     per_all_people_f.person_id%TYPE
  ,p_effective_date          in     date
  ,p_fte_capacity            in     per_all_people_f.fte_capacity%TYPE
  ,p_object_version_number   in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_background_check_status  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the Background Check Status exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'YES_NO' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_background_check_status
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Background Check Status exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Background Check Status does'nt exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'YES_NO' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_background_check_status
  (p_person_id               in     per_all_people_f.person_id%TYPE
  ,p_background_check_status in     per_all_people_f.background_check_status%TYPE
  ,p_effective_date          in     date
  ,p_validation_start_date   in     date
  ,p_validation_end_date     in     date
  ,p_object_version_number   in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_blood_type  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the Blood Type exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'BLOOD_TYPE' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_blood_type
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Blood Type exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'BLOOD_TYPE' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Blood Type does'nt exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'BLOOD_TYPE' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_blood_type
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_blood_type            in     per_all_people_f.blood_type%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_student_status  >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the Student Status exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'STUDENT_STATUS' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_student_status
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Student Status exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'STUDENT_STATUS' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Student Status doesn't exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'STUDENT_STATUS' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_student_status
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_student_status        in     per_all_people_f.student_status%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_work_schedule  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the Work Schedule exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'WORK_SCHEDULE' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_work_schedule
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Work Schedule exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'WORK_SCHEDULE' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Work Schedule does'nt exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'WORK_SCHEDULE' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_work_schedule
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_work_schedule         in     per_all_people_f.work_schedule%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_rehire_recommendation  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the Rehire Recommendation exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'YES_NO' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_rehire_recommendation
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Rehire Recommendation exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Rehire Recommendation does'nt exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'YES_NO' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_rehire_recommendation
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_rehire_recommendation in     per_all_people_f.rehire_recommendation%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_benefit_group_id  >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that benefit_group_id exists in BEN_BENFTS_GRP where
--      on the effective date.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_benefit_group_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - benefit_group_id = benfts_grp_id in the BEN_BENFTS_GRP on the
--        effective date.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Benefit group id doesn't exist in BEN_BENFTS_GRP on the
--        effective date.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_benefit_group_id
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_benefit_group_id      in     per_all_people_f.benefit_group_id%TYPE
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  );

--  ---------------------------------------------------------------------------
--  |--------------------<  chk_date_death_and_rcpt_cert  >-------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that if the date of death is null the date of recipt of death
--      certificate is also null. Also validates that the date the death
--      certificate is received is the same or later than the date of death.
--
--  Pre-conditions:
--    Valid p_person_id
--
--  In Arguments:
--    p_person_id
--    p_receipt_of_death_cert_date
--    p_effective_date
--    p_date_of_death
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - date_of_death is null and the receipt_of_death_cert_date is null.
--      - receipt_of_death_cert_date is on or later than the date_of_death.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - The receipt_of_death_cert date is not null and the date_of_death is null.
--      - The receipt_of_death_cert_date is earlier than the date_of_death.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_date_death_and_rcpt_cert
  (p_person_id                  in     per_all_people_f.person_id%TYPE
  ,p_receipt_of_death_cert_date in     per_all_people_f.receipt_of_death_cert_date%TYPE
  ,p_effective_date             in     date
  ,p_object_version_number      in     per_all_people_f.object_version_number%TYPE
  ,p_date_of_death              in     date
  );

--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_birth_adoption_date  >-------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that  if the date of birth is null then the dependent's adoption
--      date is also null. Also validates that the dependent's date of adoption
--      is the same or later than the date of birth.
--
--  Pre-conditions:
--    Valid p_person_id
--
--  In Arguments:
--    p_person_id
--    p_dpdnt_adoption_date
--    p_effective_date
--    p_date_of_birth
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - dpdnt_adoption_date is null if date_of_birth is null
--      - dpdnt_adoption_date is on or later than the date_of_birth.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - The dpdnt_adoption_date is not null and the date_of_birth is null.
--      - The dpdnt_adoption_date is earlier than the date_of_birth.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_birth_adoption_date
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_dpdnt_adoption_date   in     per_all_people_f.dpdnt_adoption_date%TYPE
  ,p_date_of_birth         in     date
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  );
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_rd_flag >-------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that registered disabled exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'REGISTERED_DISABLED' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_registered_disabled_flag
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Registered Disabled exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'REGISTERED_DISABLED' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Registered_disabled doesn't exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'REGISTERED_DISABLED' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_rd_flag
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_registered_disabled_flag in     per_all_people_f.registered_disabled_flag%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  );

--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_date_of_death  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the date of death is the same or later than the
--      date of birth.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_date_of_death
--    p_effective_date
--    p_date_of_birth
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - date_of_death is on or later than the date_of_birth.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - The date_of_death is earlier than the date_of_birth.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_date_of_death
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_date_of_death         in     per_all_people_f.date_of_death%TYPE
  ,p_date_of_birth         in     per_all_people_f.date_of_birth%TYPE
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_uses_tobacco >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that Uses Tobacco exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'TOBACCO_USER' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_uses_tobacco_flag
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Uses tobacco exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'TOBACCO_USER' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Uses Tobacco doesn't exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'TOBACCO_USER' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_uses_tobacco
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_uses_tobacco_flag        in     per_all_people_f.uses_tobacco_flag%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
   );
--
end per_per_bus1;

/
