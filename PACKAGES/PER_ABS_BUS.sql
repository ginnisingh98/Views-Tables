--------------------------------------------------------
--  DDL for Package PER_ABS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABS_BUS" AUTHID CURRENT_USER as
/* $Header: peabsrhi.pkh 120.3.12010000.3 2009/12/22 10:04:55 ghshanka ship $ */
--
--  ---------------------------------------------------------------------------
--  |---------------------<  get_running_totals  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    This procedure gets the year to date totals and running totals for
--    both days and hours.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
--    p_absence_attendance_type_id
--    p_effective_date
--
--  Out Arguments:
--    p_running_total_hours
--    p_running_total_days
--    p_year_to_date_hours
--    p_year_to_date_days
--
--  Post Success:
--    If validation passes, processing continues.
--
--  Post Failure:
--    If validation fails, an error is raised and processing stops.
--
--  Access Status:
--    Internal Table Handler Use Only. API updating is not required as this
--    is called from other chk procedures that use API updating.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure get_running_totals
  (p_person_id                  in  number
  ,p_absence_attendance_type_id in  number
  ,p_effective_date             in  date
  ,p_running_total_hours        out nocopy number
  ,p_running_total_days         out nocopy number
  ,p_year_to_date_hours         out nocopy number
  ,p_year_to_date_days          out nocopy number);
--
--  ---------------------------------------------------------------------------
--  |---------------------<  per_valid_for_absence  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    This function validates that the person exists and that they have
--    a valid period of service for the entire absence duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type
--    p_date_projected_start
--    p_date_projected_end
--    p_date_start
--    p_date_end
--
--  Post Success:
--    If validation passes, the function returns TRUE.
--
--  Post Failure:
--    IF validation fails, the function returns FALSE.
--
--  Access Status:
--    Internal Table Handler Use Only. API updating is not required as this
--    is called from other chk procedures that use API updating.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function per_valid_for_absence
  (p_person_id            in number
  ,p_business_group_id    in number
  ,p_date_projected_start in date
  ,p_date_projected_end   in date
  ,p_date_start           in date
  ,p_date_end             in date) return boolean;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  convert_to_minutes >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Converts two times into duration minutes.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_time_start
--    p_time_end
--
--  Post Success:
--    The function returns duration minutes and processing continues.
--
--  Post Failure:
--    The function errors and processing stops.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function convert_to_minutes
  (p_time_start in varchar2
  ,p_time_end   in varchar2) return number;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_time_format >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Checks that the time format is valid.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_time
--
--  Post Success:
--    If the time format is valid, processing continues.
--
--  Post Failure:
--    If the time format is invalid processing stops and an error is raised.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_time_format
  (p_time in varchar2);
--
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calculates the absence duration in hours and / or days and sets
--    the duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_start
--    p_date_end
--    p_time_start
--    p_time_end
--
--  Out Arguments:
--    p_absence_days
--    p_absence_hours
--    p_use_formula
--
--  Post Success:
--    The absence duration in days and hours is returned.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure calculate_absence_duration
 (p_absence_attendance_id      in  number
 ,p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_object_version_number      in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2
 ,p_absence_days               out nocopy number
 ,p_absence_hours              out nocopy number
 ,p_use_formula                out nocopy boolean);
--
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration -new >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calculates the absence duration in hours and / or days and sets
--    the duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_start
--    p_date_end
--    p_time_start
--    p_time_end
--    p_ABS_INFORMATION_CATEGORY
--    p_ABS_INFORMATION1
--    p_ABS_INFORMATION2
--    p_ABS_INFORMATION3
--    p_ABS_INFORMATION4
--    p_ABS_INFORMATION5
--    p_ABS_INFORMATION6
--
--  Out Arguments:
--    p_absence_days
--    p_absence_hours
--    p_use_formula
--
--  Post Success:
--    The absence duration in days and hours is returned.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure calculate_absence_duration
 (p_absence_attendance_id      in  number
 ,p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_object_version_number      in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2
 ,p_ABS_INFORMATION_CATEGORY   in varchar2
 ,p_ABS_INFORMATION1          in varchar2
 ,p_ABS_INFORMATION2          in varchar2
 ,p_ABS_INFORMATION3          in varchar2
 ,p_ABS_INFORMATION4          in varchar2
 ,p_ABS_INFORMATION5          in varchar2
 ,p_ABS_INFORMATION6          in varchar2
 ,p_absence_days               out nocopy number
 ,p_absence_hours              out nocopy number
 ,p_use_formula                out nocopy boolean);
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the person exists, that they have a valid period of
--    service and that they match the business group id being passed.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_attendance_id
--    p_person_id
--    p_business_group_id
--
--  Post Success:
--    If the person and their period of service are valid, processing
--    continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_person_id
  (p_absence_attendance_id in number
  ,p_person_id             in number
  ,p_business_group_id     in number
  ,p_object_version_number in number
  ,p_date_projected_start  in date
  ,p_date_projected_end    in date
  ,p_date_start            in date
  ,p_date_end              in date);
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_absence_attendance_type_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the absence_attendance_type_id exists in
--    per_absence_attendance_types for the same business group and that it
--    is effective for the entire absence duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_business_group_id
--    p_absence_attendance_type_id
--    p_object_version_number
--
--  Post Success:
--    If absence_attendance_type_id exists and is valid,
--    processing continues.
--
--  Post Failure:
--    If absence_attendance_type_id is invalid,
--    an application error is raised and processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_absence_attendance_type_id
 (p_absence_attendance_id      in  number
 ,p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_object_version_number      in  number
 ,p_date_projected_start       in  date
 ,p_date_projected_end         in  date
 ,p_date_start                 in  date
 ,p_date_end                   in  date);
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_abs_attendance_reason_id >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that an abs_attendance_reason_id exists in table
--    per_abs_attendance_reasons, also valid in hr_lookups
--    where lookup_type is 'ABSENCE_REASON' and enabled_flag is 'Y'
--    and effective_date is between the active dates (if they are not null).
--
--  Pre-conditions:
--    absence_attendance_type_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_abs_attendance_reason_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    If a row does exist; processing continues.
--
--  Post Failure:
--    If a row does not exist in per_abs_attendance_reason and hr_lookups for
--    a given reason id then an error will be raised and processing terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_abs_attendance_reason_id
  (p_absence_attendance_id      in number
  ,p_absence_attendance_type_id in number
  ,p_abs_attendance_reason_id   in number
  ,p_business_group_id          in number
  ,p_object_version_number      in number
  ,p_effective_date             in date);
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_absence_period --new >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the projected dates, actual dates, times and the duration.
--
--  Pre-conditions:
--    absence_attendance_type_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_projected_start
--    p_time_projected_start
--    p_date_projected_end
--    p_time_projected_end
--    p_date_start
--    p_time_start
--    p_date_end
--    p_time_end
--    p_ABS_INFORMATION_CATEGORY
--    p_ABS_INFORMATION1
--    p_ABS_INFORMATION2
--    p_ABS_INFORMATION3
--    p_ABS_INFORMATION4
--    p_ABS_INFORMATION5
--    p_ABS_INFORMATION6
--
--  In Out Arguments:
--    p_absence_days
--    p_absence_hours
--
--  Post Success:
--    If validation passes, processing continues.
--
--  Post Failure:
--    IF validation fails, the appropriate error or warning is raised.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_absence_period
  (p_absence_attendance_id      in     number
  ,p_absence_attendance_type_id in     number
  ,p_business_group_id          in     number
  ,p_object_version_number      in     number
  ,p_effective_date             in     date
  ,p_person_id                  in     number
  ,p_date_projected_start       in     date
  ,p_time_projected_start       in     varchar2
  ,p_date_projected_end         in     date
  ,p_time_projected_end         in     varchar2
  ,p_date_start                 in     date
  ,p_time_start                 in     varchar2
  ,p_date_end                   in     date
  ,p_time_end                   in     varchar2
  ,p_ABS_INFORMATION_CATEGORY   in varchar2
  ,p_ABS_INFORMATION1          in varchar2
  ,p_ABS_INFORMATION2          in varchar2
  ,p_ABS_INFORMATION3          in varchar2
  ,p_ABS_INFORMATION4          in varchar2
  ,p_ABS_INFORMATION5          in varchar2
  ,p_ABS_INFORMATION6          in varchar2
  ,p_absence_days               in out nocopy number
  ,p_absence_hours              in out nocopy number
  ,p_dur_dys_less_warning       out nocopy    boolean
  ,p_dur_hrs_less_warning       out nocopy    boolean
  ,p_exceeds_pto_entit_warning  out nocopy    boolean
  ,p_exceeds_run_total_warning  out nocopy    boolean
  ,p_abs_overlap_warning        out nocopy    boolean
  ,p_abs_day_after_warning      out nocopy    boolean
  ,p_dur_overwritten_warning    out nocopy    boolean);
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_absence_period -- old>---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the projected dates, actual dates, times and the duration.
--
--  Pre-conditions:
--    absence_attendance_type_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_projected_start
--    p_time_projected_start
--    p_date_projected_end
--    p_time_projected_end
--    p_date_start
--    p_time_start
--    p_date_end
--    p_time_end
--
--  In Out Arguments:
--    p_absence_days
--    p_absence_hours
--
--  Post Success:
--    If validation passes, processing continues.
--
--  Post Failure:
--    IF validation fails, the appropriate error or warning is raised.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_absence_period
  (p_absence_attendance_id      in     number
  ,p_absence_attendance_type_id in     number
  ,p_business_group_id          in     number
  ,p_object_version_number      in     number
  ,p_effective_date             in     date
  ,p_person_id                  in     number
  ,p_date_projected_start       in     date
  ,p_time_projected_start       in     varchar2
  ,p_date_projected_end         in     date
  ,p_time_projected_end         in     varchar2
  ,p_date_start                 in     date
  ,p_time_start                 in     varchar2
  ,p_date_end                   in     date
  ,p_time_end                   in     varchar2

  ,p_absence_days               in out nocopy number
  ,p_absence_hours              in out nocopy number
  ,p_dur_dys_less_warning       out nocopy    boolean
  ,p_dur_hrs_less_warning       out nocopy    boolean
  ,p_exceeds_pto_entit_warning  out nocopy    boolean
  ,p_exceeds_run_total_warning  out nocopy    boolean
  ,p_abs_overlap_warning        out nocopy    boolean
  ,p_abs_day_after_warning      out nocopy    boolean
  ,p_dur_overwritten_warning    out nocopy    boolean);
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_replacement_person_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the person exists, that they have a valid period of
--    service and that they match the business group id being passed.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_attendance_id
--    p_replacement_person_id
--    p_business_group_id
--
--  Post Success:
--    If the person and their period of service are valid, processing
--    continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_replacement_person_id
  (p_absence_attendance_id in number
  ,p_replacement_person_id in number
  ,p_business_group_id     in number
  ,p_object_version_number in number
  ,p_date_projected_start  in date
  ,p_date_projected_end    in date
  ,p_date_start            in date
  ,p_date_end              in date);
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_authorising_person_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the person exists, that they have a valid period of
--    service and that they match the business group id being passed.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_attendance_id
--    p_replacement_person_id
--    p_business_group_id
--
--  Post Success:
--    If the person and their period of service are valid, processing
--    continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_authorising_person_id
  (p_absence_attendance_id in number
  ,p_authorising_person_id in number
  ,p_business_group_id     in number
  ,p_object_version_number in number
  ,p_date_projected_start  in date
  ,p_date_projected_end    in date
  ,p_date_start            in date
  ,p_date_end              in date);
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_absence_attendance_id
--     already exists.
--
--  In Arguments:
--    p_absence_attendance_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_absence_attendance_id                in number
  );
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_absence_attendance_id
--     already exists.
--
--  In Arguments:
--    p_absence_attendance_id
--
--
--  Post Success:
--    The business group's legislation code will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION return_legislation_code
  (p_absence_attendance_id                in     number
  ) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Out Parameters:
--   p_dur_dys_less_warning  - true, when HR_EMP_ABS_SHORT_DURATION warning
--                             is raised.
--   p_dur_hrs_less_warning  - true, when HR_ABS_HOUR_LESS_DURATION warning
--                             is raised.
--   p_exceeds_pto_entit_warning - true, when HR_EMP_NOT_ENTITLED warning
--                             is raised.
--   p_exceeds_run_total_warning - true, when HR_ABS_DET_RUNNING_ZERO warning
--                             is raised.
--   p_abs_overlap_warning   - true, when HR_ABS_DET_OVERLAP warning is
--                             raised.
--   p_abs_day_after_warning - true, when HR_ABS_DET_ABS_DAY_AFTER warning
--                             is raised.
--   p_dur_overwritten_warning true, when the absence durations have been
--                             overwritten by the Fast Formula values.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_abs_shd.g_rec_type
  ,p_dur_dys_less_warning         out nocopy boolean
  ,p_dur_hrs_less_warning         out nocopy boolean
  ,p_exceeds_pto_entit_warning    out nocopy boolean
  ,p_exceeds_run_total_warning    out nocopy boolean
  ,p_abs_overlap_warning          out nocopy boolean
  ,p_abs_day_after_warning        out nocopy boolean
  ,p_dur_overwritten_warning      out nocopy boolean
  );
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
-- Prerequisites:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Out Parameters:
--   p_dur_dys_less_warning  - true, when HR_EMP_ABS_SHORT_DURATION warning
--                             is raised.
--   p_dur_hrs_less_warning  - true, when HR_ABS_HOUR_LESS_DURATION warning
--                             is raised.
--   p_exceeds_pto_entit_warning - true, when HR_EMP_NOT_ENTITLED warning
--                             is raised.
--   p_exceeds_run_total_warning - true, when HR_ABS_DET_RUNNING_ZERO warning
--                             is raised.
--   p_abs_overlap_warning   - true, when HR_ABS_DET_OVERLAP warning is
--                             raised.
--   p_abs_day_after_warning - true, when HR_ABS_DET_ABS_DAY_AFTER warning
--                             is raised.
--   p_dur_overwritten_warning true, when the absence durations have been
--                             overwritten by the Fast Formula values.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_abs_shd.g_rec_type
  ,p_dur_dys_less_warning         out nocopy boolean
  ,p_dur_hrs_less_warning         out nocopy boolean
  ,p_exceeds_pto_entit_warning    out nocopy boolean
  ,p_exceeds_run_total_warning    out nocopy boolean
  ,p_abs_overlap_warning          out nocopy boolean
  ,p_abs_day_after_warning        out nocopy boolean
  ,p_dur_overwritten_warning      out nocopy boolean
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
-- Prerequisites:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in per_abs_shd.g_rec_type
  );
--
end per_abs_bus;

/
