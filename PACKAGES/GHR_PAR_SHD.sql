--------------------------------------------------------
--  DDL for Package GHR_PAR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PAR_SHD" AUTHID CURRENT_USER as
/* $Header: ghparrhi.pkh 120.5.12010000.1 2008/07/28 10:35:39 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  pa_request_id                     number(15),
  pa_notification_id                number(22),
  noa_family_code                   varchar2(30),
  routing_group_id                  number(15),
  proposed_effective_asap_flag      varchar2(9),      -- Increased length
  academic_discipline               varchar2(30),
  additional_info_person_id         per_people_f.person_id%type,
  additional_info_tel_number        varchar2(60),
  agency_code                       varchar2(30),
  altered_pa_request_id             number(15),
  annuitant_indicator               varchar2(30),
  annuitant_indicator_desc          varchar2(80),
  appropriation_code1               varchar2(30),
  appropriation_code2               varchar2(30),
  approval_date                     date,
  approving_official_full_name      varchar2(240),
  approving_official_work_title     varchar2(60),
  sf50_approval_date		    date,
  sf50_approving_ofcl_full_name     varchar2(240),
  sf50_approving_ofcl_work_title    varchar2(60),
  authorized_by_person_id           per_people_f.person_id%type,
  authorized_by_title               varchar2(240),
  award_amount                      number(15,5),
  award_uom                         varchar2(30),
  bargaining_unit_status            varchar2(30),
  citizenship                       varchar2(30),
  concurrence_date                  date,
  custom_pay_calc_flag              varchar2(9),
  duty_station_code                 varchar2(9),
  duty_station_desc                 varchar2(150),
  duty_station_id                   number(15),
  duty_station_location_id          number(15),
  education_level                   varchar2(30),
  effective_date                    date,
  employee_assignment_id            number(15),
  employee_date_of_birth            date,
  employee_dept_or_agency           varchar2(80),
  employee_first_name               varchar2(150),
  employee_last_name                varchar2(150),
  employee_middle_names             varchar2(60),
  employee_national_identifier      varchar2(30),
  fegli                             varchar2(30),
  fegli_desc                        varchar2(80),
  first_action_la_code1             varchar2(30),
  first_action_la_code2             varchar2(30),
  first_action_la_desc1             varchar2(240),
  first_action_la_desc2             varchar2(240),
  first_noa_cancel_or_correct       varchar2(10),
  first_noa_code                    varchar2(9),      -- Increased length
  first_noa_desc                    varchar2(240),
  first_noa_id                      number(15),
  first_noa_pa_request_id           number(15),
  flsa_category                     varchar2(30),
  forwarding_address_line1          varchar2(240),
  forwarding_address_line2          varchar2(240),
  forwarding_address_line3          varchar2(240),
  forwarding_country                varchar2(60),
  forwarding_country_short_name     varchar2(80),
  forwarding_postal_code            varchar2(30),
  forwarding_region_2               varchar2(120),
  forwarding_town_or_city           varchar2(30),
  from_adj_basic_pay                number(15,5),
  from_agency_code                  varchar2(30),
  from_agency_desc                  varchar2(80),
  from_basic_pay                    number(15,5),
  from_grade_or_level               varchar2(30),
  from_locality_adj                 number(15,5),
  from_occ_code                     varchar2(150),
  from_office_symbol                varchar2(30),
  from_other_pay_amount             number(15,5),
  from_pay_basis                    varchar2(30),
  from_pay_plan                     varchar2(9),  -- Increased length
  -- FWFA Changes Bug#4444609
  input_pay_rate_determinant        VARCHAR2(30),
  from_pay_table_identifier         number(9),
  -- FWFA Changes
  from_position_id                  number(15),
  from_position_org_line1           varchar2(40),
  from_position_org_line2           varchar2(40),
  from_position_org_line3           varchar2(40),
  from_position_org_line4           varchar2(40),
  from_position_org_line5           varchar2(40),
  from_position_org_line6           varchar2(40),
  from_position_number              varchar2(15),
  from_position_seq_no              number(15),
  from_position_title               varchar2(240),
  from_step_or_rate                 varchar2(30),
  from_total_salary                 number(15,5),
  functional_class                  varchar2(30),
  notepad                           varchar2(2000),
  part_time_hours                   number(11,2),      -- Increased length (generated by Row handler was 9,2 .Had to increase it to 11)
  pay_rate_determinant              varchar2(30),
  personnel_office_id               varchar2(30),
  person_id                       per_people_f.person_id%type,
  position_occupied                 varchar2(30),
  proposed_effective_date           date,
  requested_by_person_id           per_people_f.person_id%type,
  requested_by_title                varchar2(240),
  requested_date                    date,
  requesting_office_remarks_desc    varchar2(2000),
  requesting_office_remarks_flag    varchar2(9),      -- Increased length
  request_number                    varchar2(25),
  resign_and_retire_reason_desc     varchar2(2000),
  retirement_plan                   varchar2(30),
  retirement_plan_desc              varchar2(80),
  second_action_la_code1            varchar2(30),
  second_action_la_code2            varchar2(30),
  second_action_la_desc1            varchar2(240),
  second_action_la_desc2            varchar2(240),
  second_noa_cancel_or_correct      varchar2(10),
  second_noa_code                   varchar2(30),
  second_noa_desc                   varchar2(240),
  second_noa_id                     number(15),
  second_noa_pa_request_id          number(15),
  service_comp_date                 date,
  status                            varchar2(30),
  supervisory_status                varchar2(30),
  tenure                            varchar2(30),
  to_adj_basic_pay                  number(15,5),
  to_basic_pay                      number(15,5),
  to_grade_id                       number(15),
  to_grade_or_level                 varchar2(30),
  to_job_id                         number(15),
  to_locality_adj                   number(15,5),
  to_occ_code                       varchar2(30),
  to_office_symbol                  varchar2(30),
  to_organization_id                number(15),
  to_other_pay_amount               number(15,5),
  to_au_overtime                    number(15,2),
  to_auo_premium_pay_indicator      varchar2(30),
  to_availability_pay               number(15,2),
  to_ap_premium_pay_indicator       varchar2(30),
  to_retention_allowance            number(15,2),
  to_supervisory_differential       number(15,2),
  to_staffing_differential          number(15,2),
  to_pay_basis                      varchar2(30),
  to_pay_plan                       varchar2(9),  -- Increased pay_plan
  -- FWFA Changes Bug#4444609
  to_pay_table_identifier           NUMBER(9),
  -- FWFA Changes
  to_position_id                    number(15),
  to_position_org_line1             varchar2(40),
  to_position_org_line2             varchar2(40),
  to_position_org_line3             varchar2(40),
  to_position_org_line4             varchar2(40),
  to_position_org_line5             varchar2(40),
  to_position_org_line6             varchar2(40),
  to_position_number                varchar2(15),
  to_position_seq_no                number(15),
  to_position_title                 varchar2(240),
  to_step_or_rate                   varchar2(30),
  to_total_salary                   number(15,5),
  veterans_preference               varchar2(30),
  veterans_pref_for_rif             varchar2(30),
  veterans_status                   varchar2(30),
  work_schedule                     varchar2(30),
  work_schedule_desc                varchar2(80),
  year_degree_attained              number(9),        -- Increased length
  first_noa_information1            varchar2(240),
  first_noa_information2            varchar2(150),
  first_noa_information3            varchar2(150),
  first_noa_information4            varchar2(150),
  first_noa_information5            varchar2(150),
  second_lac1_information1          varchar2(240),
  second_lac1_information2          varchar2(150),
  second_lac1_information3          varchar2(150),
  second_lac1_information4          varchar2(150),
  second_lac1_information5          varchar2(150),
  second_lac2_information1          varchar2(240),
  second_lac2_information2          varchar2(150),
  second_lac2_information3          varchar2(150),
  second_lac2_information4          varchar2(150),
  second_lac2_information5          varchar2(150),
  second_noa_information1           varchar2(240),
  second_noa_information2           varchar2(150),
  second_noa_information3           varchar2(150),
  second_noa_information4           varchar2(150),
  second_noa_information5           varchar2(150),
  first_lac1_information1           varchar2(240),
  first_lac1_information2           varchar2(150),
  first_lac1_information3           varchar2(150),
  first_lac1_information4           varchar2(150),
  first_lac1_information5           varchar2(150),
  first_lac2_information1           varchar2(240),
  first_lac2_information2           varchar2(150),
  first_lac2_information3           varchar2(150),
  first_lac2_information4           varchar2(150),
  first_lac2_information5           varchar2(150),
  attribute_category                varchar2(30),
  attribute1                        varchar2(150),
  attribute2                        varchar2(150),
  attribute3                        varchar2(150),
  attribute4                        varchar2(150),
  attribute5                        varchar2(150),
  attribute6                        varchar2(150),
  attribute7                        varchar2(150),
  attribute8                        varchar2(150),
  attribute9                        varchar2(150),
  attribute10                       varchar2(150),
  attribute11                       varchar2(150),
  attribute12                       varchar2(150),
  attribute13                       varchar2(150),
  attribute14                       varchar2(150),
  attribute15                       varchar2(150),
  attribute16                       varchar2(150),
  attribute17                       varchar2(150),
  attribute18                       varchar2(150),
  attribute19                       varchar2(150),
  attribute20                       varchar2(150),
  first_noa_canc_pa_request_id      number(15),
  second_noa_canc_pa_request_id     number(15),
  to_retention_allow_percentage     number(11,2),
  to_supervisory_diff_percentage    number(11,2),
  to_staffing_diff_percentage       number(11,2),
  award_percentage                  number(11,2),
  rpa_type                          varchar2(30),
  mass_action_id                    number(15),
  mass_action_eligible_flag         varchar2(9),
  mass_action_select_flag           varchar2(9),
  mass_action_comments              varchar2(255),
  -- Bug#   RRR Changes
  payment_option                    varchar2(30),
  award_salary                      number(15,5),
  -- Bug#   RRR Changes
  object_version_number             number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
--

-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Prerequisites:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which corresponds with a constraint error.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_pa_request_id                      in number,
  p_object_version_number              in number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
--
-- Prerequisites:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Parameters:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_pa_request_id                      in number,
  p_routing_group_id                   in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pa_request_id                 in number,
	p_pa_notification_id            in number,
	p_noa_family_code               in varchar2,
	p_routing_group_id              in number,
	p_proposed_effective_asap_flag  in varchar2,
	p_academic_discipline           in varchar2,
	p_additional_info_person_id     in number,
	p_additional_info_tel_number    in varchar2,
	p_agency_code                   in varchar2,
	p_altered_pa_request_id         in number,
	p_annuitant_indicator           in varchar2,
	p_annuitant_indicator_desc      in varchar2,
	p_appropriation_code1           in varchar2,
	p_appropriation_code2           in varchar2,
	p_approval_date                 in date,
    p_approving_official_full_name  in varchar2,
	p_approving_official_work_titl  in varchar2,
	p_sf50_approval_date            in date,
    p_sf50_approving_ofcl_full_nam  in varchar2,
	p_sf50_approving_ofcl_work_tit  in varchar2,
	p_authorized_by_person_id       in number,
	p_authorized_by_title           in varchar2,
	p_award_amount                  in number,
	p_award_uom                     in varchar2,
	p_bargaining_unit_status        in varchar2,
	p_citizenship                   in varchar2,
	p_concurrence_date              in date,
    p_custom_pay_calc_flag          in varchar2,
	p_duty_station_code             in varchar2,
	p_duty_station_desc             in varchar2,
	p_duty_station_id               in number,
	p_duty_station_location_id      in number,
	p_education_level               in varchar2,
	p_effective_date                in date,
	p_employee_assignment_id        in number,
	p_employee_date_of_birth        in date,
	p_employee_dept_or_agency       in varchar2,
	p_employee_first_name           in varchar2,
	p_employee_last_name            in varchar2,
	p_employee_middle_names         in varchar2,
	p_employee_national_identifier  in varchar2,
	p_fegli                         in varchar2,
	p_fegli_desc                    in varchar2,
	p_first_action_la_code1         in varchar2,
	p_first_action_la_code2         in varchar2,
	p_first_action_la_desc1         in varchar2,
	p_first_action_la_desc2         in varchar2,
	p_first_noa_cancel_or_correct   in varchar2,
	p_first_noa_code                in varchar2,
	p_first_noa_desc                in varchar2,
	p_first_noa_id                  in number,
	p_first_noa_pa_request_id       in number,
	p_flsa_category                 in varchar2,
	p_forwarding_address_line1      in varchar2,
	p_forwarding_address_line2      in varchar2,
	p_forwarding_address_line3      in varchar2,
	p_forwarding_country            in varchar2,
    p_forwarding_country_short_nam  in varchar2,
	p_forwarding_postal_code        in varchar2,
	p_forwarding_region_2           in varchar2,
	p_forwarding_town_or_city       in varchar2,
	p_from_adj_basic_pay            in number,
	p_from_agency_code              in varchar2,
	p_from_agency_desc              in varchar2,
	p_from_basic_pay                in number,
	p_from_grade_or_level           in varchar2,
	p_from_locality_adj             in number,
	p_from_occ_code                 in varchar2,
	p_from_office_symbol            in varchar2,
    p_from_other_pay_amount         in number,
	p_from_pay_basis                in varchar2,
	p_from_pay_plan                 in varchar2,
    -- FWFA Changes Bug#4444609
    p_input_pay_rate_determinant      in varchar2,
    p_from_pay_table_identifier     in number,
    -- FWFA Changes
    p_from_position_id              in number,
      p_from_position_org_line1       in varchar2,
      p_from_position_org_line2       in varchar2,
      p_from_position_org_line3       in varchar2,
      p_from_position_org_line4       in varchar2,
      p_from_position_org_line5       in varchar2,
      p_from_position_org_line6       in varchar2,
	p_from_position_number          in varchar2,
	p_from_position_seq_no          in number,
	p_from_position_title           in varchar2,
	p_from_step_or_rate             in varchar2,
	p_from_total_salary             in number,
	p_functional_class              in varchar2,
	p_notepad                       in varchar2,
	p_part_time_hours               in number,
	p_pay_rate_determinant          in varchar2,
	p_personnel_office_id           in varchar2,
	p_person_id                     in number,
	p_position_occupied             in varchar2,
	p_proposed_effective_date       in date,
	p_requested_by_person_id        in number,
	p_requested_by_title            in varchar2,
	p_requested_date                in date,
	p_requesting_office_remarks_de  in varchar2,
	p_requesting_office_remarks_fl  in varchar2,
	p_request_number                in varchar2,
	p_resign_and_retire_reason_des  in varchar2,
	p_retirement_plan               in varchar2,
	p_retirement_plan_desc          in varchar2,
	p_second_action_la_code1        in varchar2,
	p_second_action_la_code2        in varchar2,
	p_second_action_la_desc1        in varchar2,
	p_second_action_la_desc2        in varchar2,
	p_second_noa_cancel_or_correct  in varchar2,
	p_second_noa_code               in varchar2,
	p_second_noa_desc               in varchar2,
	p_second_noa_id                 in number,
	p_second_noa_pa_request_id      in number,
	p_service_comp_date             in date,
      p_status                        in varchar2,
	p_supervisory_status            in varchar2,
	p_tenure                        in varchar2,
	p_to_adj_basic_pay              in number,
	p_to_basic_pay                  in number,
	p_to_grade_id                   in number,
	p_to_grade_or_level             in varchar2,
	p_to_job_id                     in number,
	p_to_locality_adj               in number,
	p_to_occ_code                   in varchar2,
	p_to_office_symbol              in varchar2,
	p_to_organization_id            in number,
	p_to_other_pay_amount           in number,
      p_to_au_overtime                in number,
      p_to_auo_premium_pay_indicator  in varchar2,
      p_to_availability_pay           in number,
      p_to_ap_premium_pay_indicator   in varchar2,
      p_to_retention_allowance        in number,
      p_to_supervisory_differential   in number,
      p_to_staffing_differential      in number,
	p_to_pay_basis                  in varchar2,
	p_to_pay_plan                   in varchar2,
    -- FWFA Changes Bug#4444609
    p_to_pay_table_identifier       in number,
    -- FWFA Changes
	p_to_position_id                in number,
      p_to_position_org_line1         in varchar2,
      p_to_position_org_line2         in varchar2,
      p_to_position_org_line3         in varchar2,
      p_to_position_org_line4         in varchar2,
      p_to_position_org_line5         in varchar2,
      p_to_position_org_line6         in varchar2,
	p_to_position_number            in varchar2,
	p_to_position_seq_no            in number,
	p_to_position_title             in varchar2,
	p_to_step_or_rate               in varchar2,
	p_to_total_salary               in number,
	p_veterans_preference           in varchar2,
	p_veterans_pref_for_rif         in varchar2,
	p_veterans_status               in varchar2,
	p_work_schedule                 in varchar2,
	p_work_schedule_desc            in varchar2,
	p_year_degree_attained          in number,
	p_first_noa_information1        in varchar2,
	p_first_noa_information2        in varchar2,
	p_first_noa_information3        in varchar2,
	p_first_noa_information4        in varchar2,
	p_first_noa_information5        in varchar2,
	p_second_lac1_information1      in varchar2,
	p_second_lac1_information2      in varchar2,
	p_second_lac1_information3      in varchar2,
	p_second_lac1_information4      in varchar2,
	p_second_lac1_information5      in varchar2,
	p_second_lac2_information1      in varchar2,
	p_second_lac2_information2      in varchar2,
	p_second_lac2_information3      in varchar2,
	p_second_lac2_information4      in varchar2,
	p_second_lac2_information5      in varchar2,
	p_second_noa_information1       in varchar2,
	p_second_noa_information2       in varchar2,
	p_second_noa_information3       in varchar2,
	p_second_noa_information4       in varchar2,
	p_second_noa_information5       in varchar2,
	p_first_lac1_information1       in varchar2,
	p_first_lac1_information2       in varchar2,
	p_first_lac1_information3       in varchar2,
	p_first_lac1_information4       in varchar2,
	p_first_lac1_information5       in varchar2,
	p_first_lac2_information1       in varchar2,
	p_first_lac2_information2       in varchar2,
	p_first_lac2_information3       in varchar2,
	p_first_lac2_information4       in varchar2,
	p_first_lac2_information5       in varchar2,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
        p_first_noa_canc_pa_request_id  in number  ,
        p_second_noa_canc_pa_request_i  in number  ,
        p_to_retention_allow_percentag  in number  ,
        p_to_supervisory_diff_percenta  in number  ,
        p_to_staffing_diff_percentage   in number  ,
        p_award_percentage              in number  ,
        p_rpa_type                      in varchar2,
        p_mass_action_id                in number  ,
        p_mass_action_eligible_flag     in varchar2,
        p_mass_action_select_flag       in varchar2,
        p_mass_action_comments          in varchar2,
	-- Bug#    RRR Changes
	p_payment_option                in varchar2,
	p_award_salary                  in number,
	-- Bug#    RRR Changes
	p_object_version_number         in number
      )
	Return g_rec_type;
--
end ghr_par_shd;

/
