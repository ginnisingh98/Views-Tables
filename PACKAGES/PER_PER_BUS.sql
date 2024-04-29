--------------------------------------------------------
--  DDL for Package PER_PER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PER_BUS" AUTHID CURRENT_USER as
/* $Header: peperrhi.pkh 120.2.12010000.1 2008/07/28 05:14:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
--
-- Following used to keep track of system_person_type derived by
-- return_system_person_type function when called multiple times
-- in same pass through validation procedures.
--
g_previous_sys_per_type per_person_types.system_person_type%TYPE;
--
-- Following used to allow omitting validation on employee number when a
-- global transfer is being processed
--
g_global_transfer_in_process    boolean;
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
-- Validate Important Attributes
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			     in out nocopy per_per_shd.g_rec_type,
	 p_effective_date	     in date,
	 p_datetrack_mode	     in varchar2,
	 p_validation_start_date     in date,
	 p_validation_end_date	     in date,
         p_name_combination_warning  out nocopy boolean,
         p_dob_null_warning          out nocopy boolean,
         p_orig_hire_warning         out nocopy boolean);
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
-- Validate Important Attributes
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in out nocopy per_per_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date,
         p_name_combination_warning   out nocopy boolean,
         p_dob_null_warning           out nocopy boolean,
         p_orig_hire_warning          out nocopy boolean
);
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in per_per_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific person
--
--  Prerequisites:
--    The person identified by p_person_id already exists.
--
--  In Arguments:
--    p_person_id
--
--  Post Success:
--    If the person is found this function will return the person's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the person does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_person_id              in number
  ) return varchar2;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_system_pers_type >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks if the system person type has been changed between the
--    validation start date and validation end date.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_validation_start_date
--    p_validation_end_date
--    p_datetrack_mode
--    p_effective_date
--
--  Post Success:
--    If no system person type changes exist between the validation start
--    date and validation end date then processing continues.
--
--  Post Failure:
--    If the system person type changes in the future an application error
--    is raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_system_pers_type
  (p_person_id              in number
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_datetrack_mode         in varchar2
  ,p_effective_date         in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CHK_PERSON_TYPE >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure first checks that the specified business group exists.
--   Then, if a person type has been specified, it checks that it is valid,
--   active, in the correct business group and for the correct system person
--   type. If a person type has not been specified, then this procedure will
--   determine the default for the current business group and system person
--   type.
--
--   The procedure is called from various Person-related business processes.
--
-- Pre Conditions:
--   p_business_group_id is known to be an existing business group.
--   p_expected_sys_type is either APL, APL_EX_APL, EMP, EMP_APL, EX_APL,
--   EX_EMP, EX_EMP_APL or OTHER.
--
-- In Arguments:
--   p_person_type_id
--   p_business_group_id
--   p_expected_sys_type
--
-- Post Success:
--   If p_person_type_id is null it will be set to the default type for
--   p_expected_sys_type in the business group.
--
-- Post Failure:
--   Raises an application error if any of the following cases are found:
--     a) p_person_type_id does not exist.
--     b) p_person_type_id does exist but not in the same business group.
--     c) p_person_type_id does exist but the corresponding system person
--        type is not p_expected_sys_type.
--     d) p_person_type_id is not active.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
  procedure chk_person_type
  (p_person_type_id     in out nocopy number
  ,p_business_group_id  in     number
  ,p_expected_sys_type  in     varchar2);
  --
  --  -------------------------------------------------------------------------
  --  ------------------------<  chk_start_date >------------------------------|
  --  -------------------------------------------------------------------------
  --
  --  Description:
  --    Checks that a start date value is valid
  --
  --  Pre-conditions:
  --
  --  In Arguments:
  --    p_person_id
  --    p_start_date
  --    p_effective_date
  --    p_object_version_number
  --
  --  Post Success:
  --    On insert if a start date is the same as effective date then
  --    processing continues
  --
  --   On update if a start date is the same as the minimum effective start date
  --    then processing continues
  --
  --  Post Failure:
  --    On insert if a start date is not the same as the effective
  --    date then an application error will be raised and processing is
  --    terminated
  --
  --    On update if a start date is not the same as the minimum effective start
  --    date then an application error will be raised and processing is
  --    terminated
  --
  --  Access Status:
  --    Internal Table Handler Use Only.
  --
  procedure chk_start_date
    (p_person_id                in per_all_people_f.person_id%TYPE
    ,p_start_date               in date
    ,p_effective_date           in date
    ,p_object_version_number    in per_all_people_f.object_version_number%TYPE);
--
procedure chk_party_id
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_party_id                 in     number
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  );
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_orig_and_start_dates >----------------------|
--  -------------------------------------------------------------------------
--
--
--  Description:
--    - Validates that for person type of 'EMP','EMP_APL','EX_EMP' or
--      'EX_EMP_APL' the original date of hire is the same or earlier
--      than the earliest per_periods_of_service start date. For any
--      other person type a warning is raised if an original date of
--      hire is entered.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_person_type_id
--    p_business_group_id
--    p_original_date_of_hire
--    p_effective_date
--    p_start_date
--    p_object_version_number
--
--  Out Arguments:
--    p_orig_hire_warning
--
--  Post Success:
--    Processing continues if:
--      - person type is 'EMP','EMP_APL','EX_EMP' or 'EX_EMP_APL' and
--        original_date_of_hire is on or before the start_date
--      - person type is not 'EMP','EMP_APL','EX_EMP' or 'EX_EMP_APL'
--        and original_date_of_hire is not entered
--      - person type is not 'EMP','EMP_APL','EX_EMP' or 'EX_EMP_APL'
--        and original_date_of_hire is entered and the warning
--        message is acknowledged.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - person type is 'EMP','EMP_APL','EX_EMP' or 'EX_EMP_APL' and
--        the original_date_of_hire is later than the start date.
--
--  Access Status:
--
--    Internal Table Handler Use Only.
--
procedure chk_orig_and_start_dates
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_person_type_id        in     per_all_people_f.person_type_id%TYPE
  ,p_business_group_id     in     per_all_people_f.business_group_id%TYPE
  ,p_original_date_of_hire in     per_all_people_f.original_date_of_hire%TYPE
  ,p_start_date            in     per_all_people_f.start_date%TYPE
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  ,p_orig_hire_warning     out nocopy    boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This is a stub routine to provide dual maintainance
--  for release 11.5 and will Set the security_group_id in CLIENT_INFO for the person's business
--  group context.
--
-- Prerequisites:
--   None,
--
-- In Parameters:
--  This is a parameterless procedure for release 11.0
--  for release 11.5
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  Number   Person to use for
--                                                deriving the security group
--                                                context.
--
-- Post Success:
--  for release 11.5 The security_group_id will be set in CLIENT_INFO.
--
-- Post Failure:
--   for release 11.5 An error is raised if the person does not exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
procedure set_security_group_id
  (
   p_person_id in per_all_people_f.person_id%TYPE
  ,p_associated_column1 in varchar2 default null
  );
--
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_date_of_birth  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a date of birth value is valid
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_person_type_id
--    p_business_group_id
--    p_start_date
--    p_date_of_birth
--    p_effective_date
--    p_object_version_number
--
--  Out Arguments
--    p_dob_null_warning
--
--  Post Success:
--    If a date of birth <= the start date then
--    processing continues
--
--    If date of birth is null on insert when system person type is 'EMP' then
--    a warning is flagged and processing continues
--
--    If the persons age is between the minimum and maximum ages defined
--    for the business group then
--    processing continues
--
--  Post Failure:
--    If a date of birth > the start date then
--    an application error will be raised and processing is terminated
--
--    If the persons age is not between the minimum and maximum ages defined
--    for the business group then
--    an application error will be raised and processing is terminated
--
--    If the person type is EMP, and any assignment has its payroll component
--    set, then an application error will be raised and processing terminated
--    if the date of birth is updated to null.
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_date_of_birth
  (p_person_id                in  per_all_people_f.person_id%TYPE
  ,p_person_type_id           in  per_all_people_f.person_type_id%TYPE
  ,p_business_group_id        in  per_all_people_f.business_group_id%TYPE
  ,p_start_date               in  date
  ,p_date_of_birth            in  date
  ,p_dob_null_warning         out nocopy boolean
  ,p_effective_date           in  date
  ,p_validation_start_date    in  date
  ,p_validation_end_date      in  date
  ,p_object_version_number    in  per_all_people_f.object_version_number%TYPE);
--
--start for bug  6241572
--
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_national_identifier  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calls process hr_person.validate_national_identifier
--
--  Pre-conditions:
--    Business Group id must be valid
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_national_identifier
--    p_date_of_birth
--    p_sex
--    p_effective_date
--    p_object_version_number
--    p_legislation_code
--    p_person_type_id
--
--for bug 6241572
--    p_region_of_birth
--    p_country_of_birth
--    p_nationality

 --  Post Success:
--    If the national identifier is valid then
--    processing continues
--
--  Post Failure:
--    If the national identifier is not valid then
--    an application error is raised and processing is terminated
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_national_identifier
  (p_person_id                in  per_all_people_f.person_id%TYPE
  ,p_business_group_id        in  per_all_people_f.business_group_id%TYPE
  ,p_national_identifier      in  per_all_people_f.national_identifier%TYPE
  ,p_date_of_birth            in  date
  ,p_sex                      in  per_all_people_f.sex%TYPE
  ,p_effective_date           in  date
  ,p_object_version_number    in  per_all_people_f.object_version_number%TYPE
  ,p_legislation_code         in  per_business_groups.legislation_code%TYPE
  ,p_person_type_id           in  per_all_people_f.person_type_id%TYPE
  ,p_region_of_birth          in  per_all_people_f.region_of_birth%TYPE default NULL
  ,p_country_of_birth         in  per_all_people_f.country_of_birth%TYPE default NULL
  ,p_nationality              in  per_all_people_f.nationality%TYPE);

--end for bug 6241572
--
--
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_national_identifier  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calls process hr_person.validate_national_identifier
--
--  Pre-conditions:
--    Business Group id must be valid
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_national_identifier
--    p_date_of_birth
--    p_sex
--    p_effective_date
--    p_object_version_number
--    p_legislation_code
--    p_person_type_id       - Bug 1642707
--
--  Post Success:
--    If the national identifier is valid then
--    processing continues
--
--  Post Failure:
--    If the national identifier is not valid then
--    an application error is raised and processing is terminated
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_national_identifier
  (p_person_id                in  per_all_people_f.person_id%TYPE
  ,p_business_group_id        in  per_all_people_f.business_group_id%TYPE
  ,p_national_identifier      in  per_all_people_f.national_identifier%TYPE
  ,p_date_of_birth            in  date
  ,p_sex                      in  per_all_people_f.sex%TYPE
  ,p_effective_date           in  date
  ,p_object_version_number    in  per_all_people_f.object_version_number%TYPE
  ,p_legislation_code         in  per_business_groups.legislation_code%TYPE
  ,p_person_type_id           in  per_all_people_f.person_type_id%TYPE);
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_employee_number  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that an employee value is valid
--
--  Pre-conditions:
--    p_person_type_id must be valid
--    p_business_group_id must be valid for p_person_id
--    p_national_identifier must be valid
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type_id
--    p_employee_number
--    p_national_identifier
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If system person type is 'EMP', 'EX_EMP', 'EMP_APL' or 'EX_EMP_APL' then
--    employee number is defined based on employee number generation method as
--    follows :
--
--        If employee number is not null and employee number generation method
--        is 'Manual' then processing continues.
--        If employee number is null and employee number generation method is
--        'Automatic' then employee number is generated and processing
--        continues.
--        If employee number is null and national identifier is not null and
--        the employee number generation method is 'National identifier' then
--        employee number is set to national identifier and processing
--        continues.
--
--    If the employee number is unique within the business group then
--    processing continues
--
--  Post Failure:
--    If system person type is 'EMP', 'EX_EMP', 'EMP_APL' or 'EX_EMP_APL' then
--    If employee number is null then
--    an application error will be raised and processing is terminated
--
--    If system person type is anything other than 'EMP', 'EX_EMP', 'EMP_APL'
--    or 'EX_EMP_APL' then
--    If employee number is not null then
--    an application error will be raised and processing is terminated
--
--    If the employee number is not unique within the business group then
--    an application error will be raised and processing is terminated
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_employee_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPE
  ,p_employee_number          in out nocopy per_all_people_f.employee_number%TYPE
  ,p_national_identifier      in     per_all_people_f.national_identifier%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE);
--
procedure chk_employee_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPE
  ,p_employee_number          in out nocopy per_all_people_f.employee_number%TYPE
  ,p_national_identifier      in     per_all_people_f.national_identifier%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  ,p_party_id                 in     per_all_people_f.party_id%TYPE
  ,p_date_of_birth            in     per_all_people_f.date_of_birth%TYPE
  ,p_start_date               in     per_periods_of_service.date_start%TYPE);
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_npw_number  >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that cwk number value is valid
--
--  Pre-conditions:
--    p_person_type_id must be valid
--    p_business_group_id must be valid for p_person_id
--    p_national_identifier must be valid
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_current_npw_flag
--    p_npw_number
--    p_national_identifier
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If current_npw_flag = Y or there exists a previous CWK record on PTU,
--    npw number is defined based on cwk number generation method as
--    follows :
--
--        If npw number is not null and cwk number generation method
--        is 'Manual' then processing continues.
--        If npw number is null and cwk number generation method is
--        'Automatic' then npw number is generated and processing
--        continues.
--        If npw number is null and national identifier is not null and
--        the cwk number generation method is 'National identifier' then
--        npw number is set to national identifier and processing
--        continues.
--
--    If the npw number is unique within the business group then
--    processing continues
--
--  Post Failure:
--    If current_npw_flag = 'Y' or there exists a previous CWK record on PTU
--    If npw number is null then
--    an application error will be raised and processing is terminated
--
--    If current_npw_flag = N or (is null and no previous CWK record exists on PTU)
--    If npw number is not null then
--    an application error will be raised and processing is terminated
--
--    If the npw number is not unique within the business group then
--    an application error will be raised and processing is terminated
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_npw_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_current_npw_flag         in     per_all_people_f.current_npw_flag%TYPE
  ,p_npw_number               in out nocopy per_all_people_f.npw_number%TYPE
  ,p_national_identifier      in     per_all_people_f.national_identifier%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE);
--
procedure chk_npw_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_current_npw_flag         in     per_all_people_f.current_npw_flag%TYPE
  ,p_npw_number               in out nocopy per_all_people_f.npw_number%TYPE
  ,p_national_identifier      in     per_all_people_f.national_identifier%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  ,p_party_id                 in     per_all_people_f.party_id%TYPE
  ,p_date_of_birth            in     per_all_people_f.date_of_birth%TYPE
  ,p_start_date               in     date);
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_sex_title  >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the sex exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'SEX' with an enabled
--      flag set to 'Y' and the effective start date of the person between
--      start date active and end date active on HR_LOOKUPS.
--    - Validates that the title exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'TITLE' with an enabled
--      flag set to 'Y' and the effective start date of the person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    A valid person type
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type_id
--    p_title
--    p_sex
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - a sex exists as a lookup code in HR_LOOKUPS for the lookup type
--        'SEX' where the enabled flag is 'Y' and the effective start
--        date of the person is between start date active and end date
--        active on HR_LOOKUPS.
--      - a title exists as a lookup code in HR_LOOKUPS for the lookup type
--        'TITLE' where the enabled flag is 'Y' and the effective start
--        date of the person is between start date active and end date
--        active on HR_LOOKUPS.
--      - a sex value is 'M' and the title value is not 'MISS','MRS.',
--        'MS.'
--      - a sex value is 'F' and the title value is 'MR'.
--      - the related system person type is 'EMP' and a sex value is
--        set.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - a sex does'nt exist as a lookup code in HR_LOOKUPS for the lookup
--        type 'SEX' where the enabled flag is 'Y' and the effective start
--        date of the person is between start date active and end date
--        active on HR_LOOKUPS.
--      - a title does'nt exist as a lookup code in HR_LOOKUPS for the lookup
--        type 'TITLE' where the enabled flag is 'Y' and the effective start
--        date of the person is between start date active and end date
--        active on HR_LOOKUPS.
--      - a sex value is 'M' and the title value is 'MISS','MRS.', 'MS.'
--      - a sex value is 'F' and the title value is 'MR.'
--      - the related system person type is 'EMP' and a sex value is not
--        set.
--
--  Access Status:
--    Internal Developer Use Only.
--
procedure chk_sex_title
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPe
  ,p_title                    in     per_all_people_f.title%TYPE
  ,p_sex                      in     per_all_people_f.sex%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_applicant_number  >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that applicant number is valid on insert and delete based on
--    applicant number generation method.
--
--    Some specific tests are performed in this procedure and then if all
--    is still okay the hr_person.generate_number routine is called to
--    finish of the validation/generation process.
--
--  Pre-conditions:
--    Valid person_id
--    Valid current_applicant_flag
--    Valid current_employee_flag
--    Valid business_group_id
--    Valid person_type_id
--
--  In Arguments:
--    p_person_id
--    p_applicant_number
--    p_business_group_id
--    p_current_applicant
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--
--  If the following conditions apply then an applicant_number is generated
--  and processing continues :
--
--   a) Applicant number must be not null if system person type is 'APL',
--      'APL_EX_APL','EMP_APL','EX_EMP_APL'.
--
--   b) Applicant number must not be modified to null if the system person
--      type is 'EMP' or 'EX_EMP' and the applicant number is not null
--
--   c) Applicant number must be null if the system person type is 'EMP' and
--      no previous changes to system person type exist
--
--   d) Applicant number must be null if the system person type is 'OTHER'
--
--   e) Applicant number is mandatory in Manual generation mode
--
--   f) Number generation mode of associated business group id can only
--      be 'A' or 'M'
--
--   g) Applicant number can only be updated in generation mode 'M'
--
--   h) Applicant number must be unique within the business group
--
--  Post Failure:
--
--  If the following conditions apply then processing fails :
--
--   a) Applicant number is not null, system person type is 'OTHER'
--
--   b) Applicant number has changed from not null to null and the system
--      person type is 'EMP' or 'EX_EMP'
--
--   c) Applicant number updated when generation mode is 'A'
--
--   d) Applicant number is not null, system person type is 'EMP' and
--      no historic changes in system person type exist for this person.
--      i.e they are 'EMP' now and have always been an 'EMP'.
--
--   e) Applicant number is null when generation mode is 'M'
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_applicant_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_applicant_number         in out nocopy per_all_people_f.applicant_number%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_current_applicant        in     per_all_people_f.current_applicant_flag%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
);
--
procedure chk_applicant_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_applicant_number         in out nocopy per_all_people_f.applicant_number%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_current_applicant        in     per_all_people_f.current_applicant_flag%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  ,p_party_id                 in     per_all_people_f.party_id%TYPE
  ,p_date_of_birth            in     per_all_people_f.date_of_birth%TYPE
  ,p_start_date               in     date
  );
--
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_date_emp_data_verified  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that date employee data verified is always null on insert. On
--    update date employee data verified cannot be set to a not null value.
--    However, a not null value for date employee data verified is permissable
--    when other attributes apart from date employee data verified are being
--    set.
--
--  Pre-conditions:
--    Valid person_id
--
--  In Arguments:
--    p_person_id
--    p_date_employee_data_verified
--    p_effective_start_date
--    p_object_version_number
--
--  Post Success:
--    If date_employee_data_verified is after the effective_start_date
--    of the person record then process succeeds
--
--  Post Failure:
--    If date_employee_data_verified is before the effective_start_date of
--    the person record an application error will be raised and processing
--    is terminated
--
--  Access Status:
--    Internal Developer Use Only.
--
procedure chk_date_emp_data_verified
  (p_person_id                   in per_all_people_f.person_id%TYPE
  ,p_date_employee_data_verified in
   per_all_people_f.date_employee_data_verified%TYPE
  ,p_effective_start_date        in date
  ,p_object_version_number       in per_all_people_f.object_version_number%TYPE
  );
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_vendor_id  >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that vendor id is valid.
--
--  Pre-conditions:
--    Valid person_id
--
--  In Arguments:
--    p_person_id
--    p_vendor_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If vendor id is null and system person type is not one of  'EMP',
--    'EMP_APL','EX_EMP',EX_EMP_APL then process succeeds.
--    If vendor id is not null, system person type is one of 'EMP','EMP_APL',
--    'EX_EMP','EX_EMP_APL' and vendor id exists in lookup table then process
--    succeeds.
--
--  Post Failure:
--    If vendor id is not null and system person type is not one of  'EMP',
--    'EMP_APL','EX_EMP',EX_EMP_APL then process is terminated.
--    If vendor id is not null, system person type is one of 'EMP','EMP_APL',
--    'EX_EMP','EX_EMP_APL' and vendor id does not exists in lookup table then
--    process is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_vendor_id
  (p_person_id                in per_all_people_f.person_id%TYPE
  ,p_vendor_id                in per_all_people_f.vendor_id%TYPE
  ,p_person_type_id           in per_all_people_f.person_type_id%TYPE
  ,p_business_group_id        in per_all_people_f.business_group_id%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_people_f.object_version_number%TYPE
  );
--
 end per_per_bus;

/
