--------------------------------------------------------
--  DDL for Package PER_ASG_BUS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_BUS2" AUTHID CURRENT_USER as
/* $Header: peasgrhi.pkh 120.4.12010000.2 2009/11/20 06:56:26 sidsaxen ship $ */
--
--  --------------------------------------------------------------------------+
--  |------------------------< chk_pay_basis_id >-----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that when pay basis is not null, Pay basis exists in
--    PER_PAY_BASES.
--
--    Validates that the pay basis is in the same business group as the
--    assignment being validated.
--
--    Validates on update that no pay proposals with change dates after the
--    validation start date for the assignment exist.
--
--    Validates that the pay basis is being set for an employee or applicant
--    or benefit or offer assignment.
--
--  Pre-conditions:
--    A valid business group
--    A valid assignment type
--
--  In Arguments:
--    p_assignment_id
--    p_pay_basis_id
--    p_assignment_type
--    p_business_group_id
--    p_effective_date
--    p_validation_start_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - pay basis is not null and exists in PER_PAY_BASES.
--      - the pay basis is in the same business group as the assignment
--        pay basis.
--      - on update, all pay proposals for the assignment have change dates
--        equal to or before the validation start date of the assignment.
--      - pay basis is set for an employee or applicant or benefit or offer assignment.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - pay basis is not null but does'nt exist in PER_PAY_BASES.
--      - the pay basis is in a different business group to the assignment
--        pay basis.
--      - on update, pay proposals exist for the assignment which have a
--        change date after the validation start date for the assignment.
--      - pay basis is set for a non employee or applicant or benefit or offer assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_pay_basis_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_pay_basis_id             in per_all_assignments_f.pay_basis_id%TYPE
  ,p_assignment_type          in per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id        in per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date           in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_start_date    in per_all_assignments_f.effective_start_date%TYPE
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |------------------------< chk_payroll_id >-------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the payroll exists in PAY_PAYROLLS_F and the effective
--      start date of the assignment is the same as or after the effective start
--      date of the payroll. Also the effective end date of the assignment is
--      the same as or before the effective end date of the payroll.
--
--    - Validates that payroll_id cannot be set for an assignment which is
--      linked to an employee whose D.O.B. details have not been recorded.
--
--    - Validates that the business group of the payroll is the same as that
--      of the assignment.
--
--    - Validates that the assignment is an employee or applicant or benefits
--      or offer assignment.
--
--    - validates that the employee assignment has a primary address if
--      payroll is installed. If the address style is US then the address
--      must have a county.
--
--  Pre-conditions:
--    A valid Assignment Business Group
--    A valid Person
--    A valid assignment type.
--
--  In Arguments:
--    p_assignment_id
--    p_business_group_id
--    p_person_id
--    p_assignment_type
--    p_payroll_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_datetrack_mode
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - the payroll exists in PAY_PAYROLLS_F where the effective start
--        date of the assignment is the same as or after the effective
--        start date of the payroll. Also the effective end date of the
--        assignment is the same as or before the effective end date of
--        the payroll.
--      - The business group of the payroll is the same as the
--        business group of the assignment.
--      - The payroll_id is set and the D.O.B. has been recorded
--        for the person (employee only)
--      - the assignment is an employee or applicant or benefit or offer assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the payroll does'nt exist in PAY_PAYROLLS_F where the effective
--        start date of the assignment is the same as or after the
--        effective start date of the payroll. Also the effective end date
--        of the assignment is the same as or before the effective end
--        date of the payroll.
--      - The business group of the payroll is invalid
--      - The person has no D.O.B recorded (employee only)
--      - the assignment is not an employee or applicant or benefit or offer assignment.
--      - the employee does not have a primary address.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_payroll_id
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_payroll_id            in per_all_assignments_f.payroll_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_payroll_id_updated    out nocopy boolean
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |----------------------< chk_payroll_id_int >------------------------------|
--  --------------------------------------------------------------------------+
--
procedure chk_payroll_id_int
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_payroll_id            in per_all_assignments_f.payroll_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_address_line1            in per_addresses.address_line1%type
  ,p_date_of_birth         in per_all_people_f.date_of_birth%type
  ,p_payroll_id_updated    out nocopy boolean
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |----------------------< chk_posting_content_id >-------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment is an applicant assignment if specified
--    - Validates that (if specified) posting_content_id exists in
--                   irc_posting_contents
--  In Arguments:
--  p_posting_content_id
--  p_assignment_type

procedure chk_posting_content_id
  (p_posting_content_id     in  number
  ,p_assignment_type        in  varchar2
  ,p_assignment_id          in  per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date         in  date
  ,p_object_version_number  in  per_all_assignments_f.object_version_number%TYPE);

--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_applicant_rank >--------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment is an applicant assignment if specified
--    - Validates that (if specified) applicant rank is between 0 and 100 inc.
--
--  In Arguments:
--  p_applicant_rank
--  p_assignment_type

procedure chk_applicant_rank
  (p_applicant_rank         in  number
  ,p_assignment_type        in  varchar2
  ,p_assignment_id          in  per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date         in  date
  ,p_object_version_number  in  per_all_assignments_f.object_version_number%TYPE);


--  --------------------------------------------------------------------------+
--  |-----------------------< chk_people_group_id >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the people group exists in PAY_PEOPLE_GROUPS.
--    - Validates that the id_flex_num value of the people group is the same as
--      the people group structure of the assignment business group.
--    - Validates that the enabled flag is set to 'Y' for the people group.
--    - Validates that the effective start date of the assignment is between
--      the start date active and end date active of the people group.
--
--  Pre-conditions:
--    A valid business group
--    A valid assignment type
--    A valid vacancy
--
--  In Arguments:
--    p_assignment_id
--    p_business_group_id
--    p_assignment_type
--    p_people_group_id
--    p_vacancy_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The people group exists in PAY_PEOPLE_GROUPS.
--      - The id flex num of the people group is the same as the people group
--        structure for the business group of the assignment.
--      - enabled flag for the people group is set to 'Y'.
--      - the effective start date of the assignment is between start date active
--        and end date active of the people group.
--
--  Post Failure:
--       An application error is raised and processing ends if:
--      - The people group does'nt exist in PAY_PEOPLE_GROUPS.
--      - The id flex num of the people group is different to the people group
--        structure for the business group of the assignment.
--      - enabled flag for the people group is not set to 'Y'.
--      - the effective start date of the assignment is not between start date
--        active and end date active of the people group.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_people_group_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id       in     per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_people_group_id         in     per_all_assignments_f.people_group_id%TYPE
  ,p_vacancy_id              in     per_all_assignments_f.vacancy_id%TYPE
  ,p_validation_start_date   in     per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date     in     per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------< chk_perf_review_period_freq >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the performance review period frequency exists as a
--      lookup code on HR_LOOKUPS for the lookup type 'FREQUENCY' with an
--      enabled flag set to 'Y' and the effective start date of the assignment
--      between start date active and end date active on HR_LOOKUPS.
--
--    - Validates that the performance review period frequency is being set for
--      an employee or applicant or benefit or offer assignment.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_perf_review_period_frequency
--    p_assignment_type
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - performance review period frequency is set.
--      - performance review period frequency exists as a lookup code
--        in HR_LOOKUPS for the lookup type 'FREQUENCY' where the enabled
--        flag is 'Y' and the effective start date of the assignment
--        is between start date active and end date active on HR_LOOKUPS.
--      - performance review period frequency is set for an employee
--        or applicant or benefit or offer assignment.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - performance review period frequency does'nt exist as a lookup code
--        in HR_LOOKUPS for the lookup type 'FREQUENCY' where the enabled
--        flag is 'Y' and the effective start date of the assignment
--        is between start date active and end date active on HR_LOOKUPS.
--      - performance review period frequency is set for a non employee
--        or applicant or benefit or offer assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_perf_review_period_freq
  (p_assignment_id                in     per_all_assignments_f.assignment_id%TYPE
  ,p_perf_review_period_frequency in     per_all_assignments_f.perf_review_period_frequency%TYPE
  ,p_assignment_type              in     per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date               in     date
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  ,p_object_version_number        in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-----------------------< chk_perf_review_period >------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--
--    Validates that the perf review period is being set for an employee
--    or applicant or benefit or offer assignment.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_perf_review_period
--    p_assignment_type
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - perf review period is null.
--      - perf review period frequency is set for an employee or applicant
--        or benefit or offer assignment.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - perf review period frequency is set for a non employee or applicant
--        or benefit or offer assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_perf_review_period
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_perf_review_period           in per_all_assignments_f.perf_review_period%TYPE
  ,p_assignment_type              in per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------< chk_perf_rp_freq_perf_rp >--------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that when perf review period frequency is not null then
--    perf review period is also not null,
--
--  Pre-conditions:
--    Valid perf review period frequency
--    Valid perf review period
--
--  In Arguments:
--    p_assignment_id
--    p_perf_review_period_frequency
--    p_perf_review_period
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - perf review period frequency and perf review period are both null.
--      - perf review period frequency and perf review period are both not
--        null.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - perf review period frequency or perf review period are not null.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_perf_rp_freq_perf_rp
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_perf_review_period_frequency in per_all_assignments_f.perf_review_period_frequency%TYPE
  ,p_perf_review_period           in per_all_assignments_f.perf_review_period%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------< chk_period_of_service_id >------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--
--    - Validates that the assignment is an employee assignment.
--    - Validates that the period of service is set for an employee assignment.
--    - Validates that the period of service exists in PER_PERIODS_OF_SERVICE
--      between the period of service date start and actual termination date.
--    - Validates that the business_group_id of the Assignment is the same as
--      that of the period of service.
--    - Validates that the effective start date of the assignment is between
--      the date start and actual termination date of the period of service.
--
--  Pre-conditions:
--    A valid Person
--    A valid assignment type
--    A Valid business group
--
--  In Arguments:
--    p_assignment_id
--    p_business_group_id
--    p_person_id
--    p_assignment_type
--    p_period_of_service_id
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an employee assignment.
--      - period of service is set for an employee assignment.
--      - period of service exists in PER_PERIODS_OF_SERVICE between
--        date start and actual termination date.
--      - the period of service is in the same business group as the
--        assignment business group.
--      - the effective start date of the assignment is between date start
--        and actual termination date of the period of service.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is not an employee assignment.
--      - period of service is not set for a employee assignment.
--      - period of service does'nt exist in PER_PERIODS_OF_SERVICE between
--        date start and actual termination date.
--      - the period of service is in a different business group to
--        the assignment business group.
--      - the effective start date of the assignment is not between date
--        start and actual termination date of the period of service.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_period_of_service_id
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id      in     per_all_assignments_f.business_group_id%TYPE
  ,p_person_id              in     per_all_assignments_f.person_id%TYPE
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE
  ,p_period_of_service_id   in     per_all_assignments_f.period_of_service_id%TYPE
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------------< chk_person_id >------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that the business group of the person is the same as
--    the business group of the assignment.
--
--  Pre-conditions:
--    A valid Assignment Business Group
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--
--  Post Success:
--    Processing continues if :
--      - The business group validation succeeds
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--    of the following cases are found :
--      - The business group validation fails
--
--  Access status:
--    Internal Table Handler Use Only.
--
-- 70.2 change b start.
--
procedure chk_person_id
  (p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date        in per_all_assignments_f.effective_start_date%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------< chk_person_referred_by_id >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment is an applicant or offer assignment.
--    - Validates that the person referred by exists in PER_PEOPLE_F and
--      the effective start date of the assignment is between the effective
--      start date and effective end date of the person referred by.
--    - Validates that the person referred by is in the same business group
--      as the assignment.
--    - Validates that the person referred by is not the same as the person
--      of the assignment..
--    - Validates that the person referred by is an employee.
--
--  Pre-conditions:
--    A valid assignment type
--    A Valid business group
--    A valid person
--
--  In Arguments:
--    p_person_referred_by_id
--    p_assignment_type
--    p_business_group_id
--    p_person_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an applicant or offer assignment.
--      - the person referred by exists in PER_PEOPLE_F where the effective
--        start date of the assignment is between the effective start
--        date and effective end date of the person referred by.
--      - the person referred by is in the same business group as the
--        assignment business group.
--      - the person referred by is not the person of the assignment.
--      - the current employee flag of the person referred by in
--        PER_PEOPLE_F is set to 'Y'.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is not an applicant or offer assignment.
--      - the person referred by does'nt exist in PER_PEOPLE_F where the
--        effective start date of the assignment is between the effective
--        start date and effective end date of the person referred by.
--      - the person referred by is in a different business group to
--        the assignment business group.
--      - the person referred by is the person of the assignment.
--      - the current employee flag of the person referred by in
--        PER_PEOPLE_F is not set to 'Y'.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_person_referred_by_id
  (p_assignment_id             in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type           in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id         in     per_all_assignments_f.business_group_id%TYPE
  ,p_person_id                 in     per_all_assignments_f.person_id%TYPE
  ,p_person_referred_by_id     in     per_all_assignments_f.person_referred_by_id%TYPE
  ,p_effective_date            in     date
  ,p_object_version_number     in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date     in     date
  ,p_validation_end_date       in     date
  );
--
--  --------------------------------------------------------------------------+
--  |------------------------< chk_position_id >------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the position_id exists in per_positions date
--      effectively.
--    - Validates that the business_group_id in per_positions matches
--      the assignment business group date effectively.
--
--  Pre-conditions:
--    A valid business_group_id
--    A valid assignment type
--    A valid vacancy_id
--
--  In Arguments:
--    p_assignment_id
--    p_position_id
--    p_business_group_id
--    p_assignment_type
--    p_vacancy_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The position exists and is date effective in per_positions.
--      - The business group of the position is the same as the assignment's
--        business group date effectively.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The position_id does not exist or is not date effective in
--        per_positions.
--      - The business_group_id in per_positions does not match the assignment
--        business_group_id or is not date effective.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_position_id
  (p_assignment_id          in per_all_assignments_f.assignment_id%TYPE
   ,p_position_id           in per_all_assignments_f.position_id%TYPE
   ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
   ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
   ,p_vacancy_id            in per_all_assignments_f.vacancy_id%TYPE
   ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
   ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
   ,p_effective_date        in date
   ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
   );
-----------------------------------------------------------------------------+
-------------------< chk_position_id_grade_id >------------------------------+
-----------------------------------------------------------------------------+
--
--  Description:
--    Validates that the position_id and grade_id combination in
--    per_valid_grades matches the combination for the assignment.
--
--  Pre-conditions:
--    A valid position_id
--    A valid grade_id
--
--  In Arguments:
--    p_assignment_id
--    p_position_id
--    p_grade_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_object_version_number
--
--  Out Arguments:
--    p_inv_pos_grade_warning
--
--  Post Success:
--    Processing continues if :
--      - The position_id and grade_id combination in per_valid_grades
--        matches the corresponding combination for the assignment date
--        effectively.
--
--  Post Failure:
--    A flag (p_inv_pos_grade_warning) is set to true when the position_id and
--    grade_id combination do not match with a combination in per_valid_grades.
--    This flag is set to false when the combination does exist. The flag will
--    always be false when position_id and grade_id are not modified in this
--    transaction.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_position_id_grade_id
  (p_assignment_id          in per_all_assignments_f.assignment_id%TYPE
   ,p_position_id           in per_all_assignments_f.position_id%TYPE
   ,p_grade_id              in per_all_assignments_f.grade_id%TYPE
   ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
   ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
   ,p_effective_date        in date
   ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
   ,p_inv_pos_grade_warning out nocopy boolean
   );
-----------------------------------------------------------------------------+
--------------------------< chk_position_id_org_id >-------------------------+
-----------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the position and organization combination in
--      per_positions matches the combination for the assignment.
--
--  Pre-conditions:
--    A valid position_id
--    A valid organization_id
--
--  In Arguments:
--    p_assignment_id
--    p_position_id
--    p_organization_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The assignment's position and organization combination matches the
--        same combination for the position in PER_POSITIONS date effectively.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment's position and organization combination does not
--        match the combination in PER_POSITIONS date effectively.
--
--  Access Status:
--    Internal Table Handler Use Only
procedure chk_position_id_org_id
  (p_assignment_id          in per_all_assignments_f.assignment_id%TYPE
   ,p_position_id           in per_all_assignments_f.position_id%TYPE
   ,p_organization_id       in per_all_assignments_f.organization_id%TYPE
   ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
   ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
   ,p_effective_date        in date
   ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
   );
-----------------------------------------------------------------------------+
-------------------------< chk_position_id_job_id >--------------------------+
-----------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the job for the assignment's job and position
--      combination is not null.
--    - Validates that the position and job combination in
--      per_positions matches the combination for the assignment.
--
--  Pre-conditions:
--    A valid position_id
--    A valid job_id
--
--  In Arguments:
--    p_assignment_id
--    p_position_id
--    p_job_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The job of the assignment position and job combination is not null.
--      - The assignment's position and job combination matches the
--        same combination for the position in PER_POSITIONS date effectively.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The job of the assignment position and job combination is
--        null.
--        null.
--      - The assignment's position and job combination does not
--        match the combination in PER_POSITIONS date effectively.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_position_id_job_id
  (p_assignment_id          in per_all_assignments_f.assignment_id%TYPE
   ,p_position_id           in per_all_assignments_f.position_id%TYPE
   ,p_job_id                in per_all_assignments_f.job_id%TYPE
   ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
   ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
   ,p_effective_date        in date
   ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
   );
--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_primary_flag >----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that primary flag is set to either 'Y' or 'N'.
--    - Validates that there is only one occurrence of an assignment where
--      the primary flag is set to 'Y' for a given person for a given
--      period of service.
--
--    - Validates that on insert of a non primary employee assignment, a primary
--      employee assignment must exist for the entire date range of the non primary.
--
--    - Validates that for applicant and offer assignments the primary flag is not set
--     to 'Y'.
--
--    - Validates that on insert of primary assignments that the effective end date
--      of the assignment is the end of time.
--
--  Pre-conditions:
--    A valid Person ID
--    A valid Period of Service ID
--    A valid Assignment Type
--
--  In Arguments:
--    p_primary_flag
--    p_assignment_type
--    p_person_id
--    p_period_of_service_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if:
--      - primary flag is either 'Y' or 'N'.
--      - No other primary assignment exists on insert of a primary.
--      - A primary employee assignment exists for the same date range as
--        the non-primary employee assignment to be inserted.
--      - For an applicant or offer assignment the primary flag is not set to 'Y'.
--      - On insert of primary assignments, the effective start date of
--        the assignment is the end of time.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - primary flag is either 'Y' or 'N'.
--      - On insert of a primary assignment, another primary already
--        exists.
--      - A primary employee assignment does'nt exist for the same date
--        range as the non-primary employee assignment to be inserted.
--      - For an applicant or offer assignment the primary flag is set to 'Y'.
--      - On insert of primary assignments, the effective start date of
--        the assignment is not the end of time.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_primary_flag
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_primary_flag          in per_all_assignments_f.primary_flag%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_period_of_service_id  in per_all_assignments_f.period_of_service_id%TYPE
  ,p_pop_date_start        in DATE
  ,p_effective_date        in date
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |----------------------< chk_probation_period >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that probation period is in the range of 0 to 9999.99.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_probation_period
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - probation period is null.
--      - probation period is not null and within the range 0 to 9999.99
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - probation period is outside of the range 0 to 9999.99
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_probation_period
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_probation_period             in per_all_assignments_f.probation_period%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |------------------------< chk_probation_unit >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the probation unit exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'QUALIFYING_UNITS' with an enabled flag set to 'Y'
--      and the effective start date of the assignment between start date active
--      and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_probation_unit
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - probation unit is null.
--      - probation unit exists as a lookup code in HR_LOOKUPS for
--        the lookup type 'QUALIFYING_UNITS' where the enabled flag is
--        'Y' and the effective start date of the assignment is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - probation unit does'nt exist as a lookup code in HR_LOOKUPS for
--        the lookup type 'QUALIFYING_UNITS' where the enabled flag is
--        'Y' and the effective start date of the assignment is between
--        start date active and end date active on HR_LOOKUPS.
--
procedure chk_probation_unit
  (p_assignment_id                in     per_all_assignments_f.assignment_id%TYPE
  ,p_probation_unit               in     per_all_assignments_f.probation_unit%TYPE
  ,p_effective_date               in     date
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  ,p_object_version_number        in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------< chk_prob_unit_prob_period >-------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that when probation unit is not null then probation period is
--    also not null,
--
--  Pre-conditions:
--    Valid probation unit
--    Valid probation period
--
--  In Arguments:
--    p_assignment_id
--    p_probation_unit
--    p_probation_period
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Probation unit and probation period are both not null.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Probation unit or probation period are not null.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_prob_unit_prob_period
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_probation_unit               in per_all_assignments_f.probation_unit%TYPE
  ,p_probation_period             in per_all_assignments_f.probation_period%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |------------------------< chk_recruiter_id >-----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment is an applicant or offer assignment.
--    - Validates that the recruiter is not the same as the person.
--    - Validates that the recruiter exists in PER_PEOPLE_F
--      between the effective start date and effective end date
--      of the assignment.
--    - Validates that the recruiter is an employee.
--    - Validates that the recruiter is in the same business group
--      as the applicant assignment.
--
--  Pre-conditions:
--    A valid person
--    A valid assignment type
--    A valid business group
--    A valid vacancy
--
--  In Arguments:
--    p_assignment_id
--    p_person_id
--    p_assignment_type
--    p_business_group_id
--    p_recruiter_id
--    p_vacancy_id
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an applicant, employee or offer assignment.
--      - the recruiter is not the person.
--      - the recruiter exists in PER_PEOPLE_F between the
--        effective start date and effective end date of the
--        assignment.
--      - the CURRENT_EMPLOYEE_FLAG of the recruiter in PER_PEOPLE_F is
--        set to 'Y'
--      - the recruiter is in the same business group as the assignment
--        business group.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is not an applicant or offer or employee assignment.
--      - the recruiter is the person.
--      - the recruiter does'nt exist in PER_PEOPLE_F between the
--        effective start date and effective end date of the
--        assignment.
--      - the CURRENT_EMPLOYEE_FLAG of the recruiter in PER_PEOPLE_F is
--        not set to 'Y'
--      - the recruiter is in a different business group to the assignment
--        business group.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_recruiter_id
  (p_assignment_id                in     per_all_assignments_f.assignment_id%TYPE
  ,p_person_id                    in     per_all_assignments_f.person_id%TYPE
  ,p_assignment_type              in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id            in     per_all_assignments_f.business_group_id%TYPE
  ,p_recruiter_id                 in     per_all_assignments_f.recruiter_id%TYPE
  ,p_vacancy_id                   in     per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date               in     date
  ,p_object_version_number        in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_recruitment_activity_id >----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment is an applicant or offer assignment.
--    - Validates that the recruitment activity exists in
--      PER_RECRUITMENT_ACTIVITIES and the effective start date of the
--      assignment is between the date start and date end of the recruitment
--      activity.
--    - Validates that the recruitment activity is in the same business group
--      as the assignment.
--
--  Pre-conditions:
--    A valid assignment type
--    A Valid business group
--
--  In Arguments:
--    p_recruitment_activity_id
--    p_assignment_type
--    p_business_group_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an applicant or offer assignment.
--      - the recruitment activity exists in PER_RECRUITMENT_ACTIVITIES
--        where the effective start date of the assignment is between the
--        date start and date end of the recruitment activity.
--      - the recruitment activity is in the same business group as the
--        assignment business group.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is not an applicant or offer assignment.
--      - the recruitment activity does'nt exist in PER_RECRUITMENT_ACTIVITIES
--        where the effective start date of the assignment is between the
--        date start and date end of the recruitment activity.
--      - the recruitment activity is in a different business group to
--        the assignment business group.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_recruitment_activity_id
  (p_assignment_id             in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type           in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id         in     per_all_assignments_f.business_group_id%TYPE
  ,p_recruitment_activity_id   in     per_all_assignments_f.recruitment_activity_id%TYPE
  ,p_effective_date            in     date
  ,p_object_version_number     in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date     in     date
  ,p_validation_end_date       in     date
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_ref_int_del >-----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that an assignment cannot be purged if foreign key
--    references exist to any of the following tables :
--
--               - PER_EVENTS
--               - PER_LETTER_REQUEST_LINES
--               - PAY_COST_ALLOCATIONS_F
--               - PAY_PAYROLL_ACTIONS
--               - PAY_PERSONAL_PAYMENT_METHODS_F
--               - PAY_ASSIGNMENT_ACTIONS
--               - PER_COBRA_COV_ENROLLMENTS
--               - PER_COBRA_COVERAGE_BENEFITS_F
--               - PER_ASSIGNMENTS_EXTRA_INFO
--               - HR_ASSIGNMENT_SET_AMENDMENTS
--               - PER_SECONDARY_ASS_STATUSES
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_validation_start_date
--    p_validation_end_date
--    p_datetrack_mode
--
--  Post Success:
--    If no child rows exist in the table listed above then processing
--    continues.
--
--  Post Failure:
--    If child rows exist in any of the tables listed above, an application
--    error is raised and processing is terminated.
--
procedure chk_ref_int_del
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_datetrack_mode        in varchar2
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------< chk_sal_review_period_freq >----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the salary review period frequency exists as a lookup
--      code on HR_LOOKUPS for the lookup type 'FREQUENCY' with an enabled
--      flag set to 'Y' and the effective start date of the assignment between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_sal_review_period_frequency
--    p_assignment_type
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - sal review period frequency is null.
--      - salary review period frequency exists as a lookup code in
--        HR_LOOKUPS for the lookup type 'FREQUENCY' where the enabled flag
--        is 'Y' and the effective start date of the assignment is between
--        start date active and end date active on HR_LOOKUPS.
--      - sal review period frequency is set for an employee or applicant
--        or benefit or offer assignment.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - salary review period frequency does'nt exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'FREQUENCY' where the enabled flag
--        is 'Y' and the effective start date of the assignment is between
--        start date active and end date active on HR_LOOKUPS.
--      - sal review period frequency is set for a non employee or applicant
--        or benefit or offer assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_sal_review_period_freq
  (p_assignment_id                in     per_all_assignments_f.assignment_id%TYPE
  ,p_sal_review_period_frequency  in
                          per_all_assignments_f.sal_review_period_frequency%TYPE
  ,p_assignment_type              in     per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date               in     date
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  ,p_object_version_number        in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-----------------------< chk_sal_review_period >------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--
--    Validates that the sal review period is being set for an employee
--    or applicant or benefit or offer assignment.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_sal_review_period
--    p_assignment_type
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - sal review period is null.
--      - sal review period frequency is set for an employee or applicant
--        or benefit or offer assignment.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - sal review period frequency is set for a non employee or applicant
--        or benefit or offer assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_sal_review_period
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_sal_review_period            in per_all_assignments_f.sal_review_period%TYPE
  ,p_assignment_type              in per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------< chk_sal_rp_freq_sal_rp >--------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that when sal review period frequency is not null then
--    sal review period is also not null,
--
--  Pre-conditions:
--    Valid sal review period frequency
--    Valid sal review period
--
--  In Arguments:
--    p_assignment_id
--    p_sal_review_period_frequency
--    p_sal_review_period
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - sal review period frequency and sal review period are both null.
--      - sal review period frequency and sal review period are both not
--        null.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - sal review period frequency or sal review period are not null.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_sal_rp_freq_sal_rp
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_sal_review_period_frequency  in per_all_assignments_f.sal_review_period_frequency%TYPE
  ,p_sal_review_period            in per_all_assignments_f.sal_review_period%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-----------------------< chk_set_of_books_id >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that on insert when set of books is not null, set of books
--      exists in GL_SETS_OF_BOOKS.
--    - Validates when set of books is set that it exists in
--      FINANCIALS_SYSTEM_PARAMS_ALL in the same business group as the
--      assignment business group.
--
--    Validates that set of books cannot be updated for the assignment.
--
--    Validates that the set of books is being set for an employee
--    or applicant or offer assignment.
--
--  Pre-conditions:
--    A Valid business group
--
--  In Arguments:
--    p_assignment_id
--    p_assignment_type
--    p_business_group_id
--    p_set_of_books_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - set of books is null.
--      - set of books is not null and exists in GL_SETS_OF_BOOKS.
--      - set of books is set for an employee or applicant or
--        offer assignment.
--      - set of books exists in FINANCIALS_SYSTEM_PARAMS_ALL and the
--        business group for the assignment is the same as the business
--        group for the financial system parameter.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - set of books is not null and does'nt exist in GL_SETS_OF_BOOKS.
--      - set of books is set for a non employee or non applicant or
--        non offer assignment.
--      - set of books exists in FINANCIALS_SYSTEM_PARAMS_ALL and the
--        business group for the assignment is different to the business
--        group for the financial system parameter.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_set_of_books_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id       in     per_all_assignments_f.business_group_id%TYPE
  ,p_set_of_books_id         in     per_all_assignments_f.set_of_books_id%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_soft_coding_keyflex_id >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment is an employee assignment.
--    - Validates that the soft coding keyflex exists on
--      hr_soft_coding_keyflex.
--    - Validates that the enabled flag is set to 'Y' for the soft coding
--      keyflex.
--    - Validates that the effective start date of the assignment is between
--      the start date active and end date active of the soft coding keyflex.
--    - Refer to the chk_scl_segments procedure for further soft_coding_keyflex
--      validation.
--    - Where payroll_id is not null, population of soft_coded_key_flex_id is
--      mandatory legislation code is 'US' or a rule exists in pay_legislation_rules
--
--  Pre-conditions:
--    A valid business group.
--    A valid assignment type.
--
--  In Arguments:
--    p_assignment_id
--    p_business_group_id
--    p_assignment_type
--    p_soft_coding_keyflex_id
--    p_effective_date
--    p_validation_start_date
--    p_object_version_number
--    p_payroll_id
--    p_business_group_id
--
--  Post Success:
--    Processing continues if:
--      - the soft coding keyflex is not set.
--      - the soft coding keyflex is set for an employee or applicant
--        assignment.
--      - the soft coding keyflex is set and exists in
--        hr_soft_coding_keyflex table.
--      - the enabled flag for the soft coding keyflex is set to 'Y'.
--      - the effective start date of the assignment is between start
--        date active and end date active of the soft coding keyflex.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the soft coding keyflex is not set for an employee or applicant
--        assignment.
--      - the soft coding keyflex_id is set and does not exist in
--        hr_soft_coding_keyflex.
--      - the enabled flag for the soft coding keyflex is not set to 'Y'.
--      - the effective start date of the assignment is not between start
--        date active and end date active of the soft coding keyflex.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_soft_coding_keyflex_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type         in per_all_assignments_f.assignment_type%TYPE
  ,p_soft_coding_keyflex_id  in per_all_assignments_f.soft_coding_keyflex_id%TYPE
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_payroll_id              in per_all_assignments_f.payroll_id%TYPE
  ,p_business_group_id       in per_all_assignments_f.business_group_id%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_source_organization_id >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that on insert of an employee assignment that source
--      organization is not set. Also on update of an employee assignment
--      when source organization is set then checks that the existing
--      source organization is the same as the set source organization.
--    - Validates that the source organization exists in PER_ORGANIZATION_UNITS
--      and the effective start date of the assignment is between the date from
--      and date to of the source organization.
--    - Validates that the source organization is in the same business group
--      as the assignment.
--
--  Pre-conditions:
--    A valid assignment type
--    A Valid business group
--
--  In Arguments:
--    p_assignment_type
--    p_business_group_id
--    p_source_organization_id
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an employee assignment and is not set on insert.
--        Or on update of an employee assignment when source organization
--        is set, the existing source organization is the same as the set
--        source organization.
--      - the source organization exists in PER_ORGANIZATION_UNITS where the
--        effective start date of the assignment is between the date from and
--        date to of the source organization.
--      - the source organization is in the same business group as the
--        assignment business group.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is an employee assignment and is set on insert.
--        Or on update of an employee assignment when source organization
--        is set, the existing source organization is different to the set
--        source organization.
--      - the source organization does'nt exist in PER_ORGANIZATION_UNITS
--        where the effective start date of the assignment is between the
--        date from and date to of the source organization.
--      - the source organization is in a different business group to
--        the assignment business group.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_source_organization_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id       in     per_all_assignments_f.business_group_id%TYPE
  ,p_source_organization_id  in     per_all_assignments_f.source_organization_id%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date   in     date
  ,p_validation_end_date     in     date
  );
--
--  --------------------------------------------------------------------------+
--  |------------------------< chk_source_type >------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the source type exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'REC_TYPE' with an enabled flag set to 'Y' and
--      the effective start date of the assignment between start date active
--      and end date active on HR_LOOKUPS.
--
--    - Validates when the recruitment activity is set that the source type
--      is the same as the type of the recruitment activity type.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_source_type
--    p_recruitment_activity_id
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - source type is set.
--      - source type exists as a lookup code in HR_LOOKUPS for the
--        lookup type 'REC_TYPE' where the enabled flag is 'Y' and the
--        effective start date of the assignment is between start date
--        active and end date active on HR_LOOKUPS.
--      - recruitment activity is set and the source type is the same as
--        the type of the recruitment activity.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - source type does'nt exist as a lookup code in HR_LOOKUPS for
--        the lookup type 'REC_TYPE' where the enabled flag is 'Y' and
--        the effective start date of the assignment is between start
--        date active and end date active on HR_LOOKUPS.
--      - recruitment activity is set and the source type is different
--        to the type of the recruitment activity.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_source_type
  (p_assignment_id            in     per_all_assignments_f.assignment_id%TYPE
  ,p_source_type              in     per_all_assignments_f.source_type%TYPE
  ,p_recruitment_activity_id  in     per_all_assignments_f.recruitment_activity_id%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------< chk_special_ceiling_step_id >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the special_ceiling_step_id exists and is date effective
--      for the assignment.
--
--    - Validates that the business group of the special_ceiling_step_id on
--      per_grade_spines is the same as the assignment business group.
--
--    - Validates when special ceiling step is set that grade is also set
--      and is valid for the grade.
--
--    - Validates that if the value for the assignment grade_id is null
--      then the value for special_ceiling_step_id should also be null.
--
--    - Validates that if the value for special_ceiling_step_id is lower
--      than the spinal point placement specified fo the assignment, the
--      special_ceiling_step_id cannot be selected.
--
--    - Validates that the assignment is an employee or applicant or offer or
--      benefit assignment.
--
--  Pre-conditions:
--    A valid Assignment Business Group.
--    A valid assignment type.
--
--  In Arguments:
--    p_assignment_id
--    p_assignment_type
--    p_special_ceiling_step_id
--    p_grade_id
--    p_business_group_id
--    p_effective_start_date
--    p_effective_end_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The special_ceiling_step_id exists and is date effective
--      - The business group of the special_ceiling_step_id
--        is the same as that of the assignment
--      - The special ceiling step is set and the grade is also set and
--        valid in per_grade_spines.
--      - The special_ceiling_step_id is >= than the spinal_point_placement
--        specified for the assignment
--      - the assignment is an employee or applicant or offer or benefit assignment.
--
--  Post Failure:
--    An application error will be raised and processing terminated if any
--    of the following cases are found :
--      - The special_ceiling_step_id does not exist or is not date effective
--      - The business group of the special_ceiling_step_id is not the same
--        as that of the assignment
--      - The special ceiling step is set and the grade is not set or valid
--        in per_grade_spines.
--      - The value for grade_id is not null and the special_ceiling_step_id
--        is not valid for the grade on per_grade_spines
--      - The special_ceiling_step_id is < than the spinal_point_placement(s)
--        specified for the assignment.
--      - the assignment is not an employee or applicant or offer or benefit assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_special_ceiling_step_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type          in per_all_assignments_f.assignment_type%TYPE
  ,p_special_ceiling_step_id  in per_all_assignments_f.special_ceiling_step_id%TYPE
  ,p_grade_id                 in per_all_assignments_f.grade_id%TYPE
  ,p_business_group_id        in per_all_assignments_f.business_group_id%TYPE
  ,p_validation_start_date    in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date      in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------------< chk_supervisor_id >--------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the supervisor is'nt the same as the person of the
--      assignment.
--    - Validates that the supervisor is date effectively valid for the
--      validation period of the assignment.
--    - Validates that the supervisor is in the same business group as the
--      assignment being validated.
--    - Validates that the supervisor is being set for an employee assignment.
--    - Validates that the supervisor is an employee.
--
--  Pre-conditions:
--    A valid person
--    A valid business group
--
--  In Arguments:
--    p_assignment_id
--    p_supervisor_id
--    p_person_id
--    p_business_group_id
--    p_validation_start_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the supervisor is null.
--      - the supervisor is not equal to the assignment person_id.
--      - the supervisor exists and is date effective for the validation
--        period of the assignment.
--      - the supervisor is in the same business group as the assignment
--        person.
--      - the supervisor is set for an employee assignment.
--      - the current employee flag of the supervisor in PER_PEOPLE_F
--        is set to 'Y'.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - the supervisor_id is equal to the assignment person_id.
--      - the supervisor_id does'nt exist or is not date effective for the
--        validation period of the assignment.
--      - the supervisor_id is in a different business group to the assignment
--        person_id.
--      - the supervisor is set for a non employee assignment.
--      - the current employee flag of the supervisor in PER_PEOPLE_F
--        is not set to 'Y'.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_supervisor_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_supervisor_id            in per_all_assignments_f.supervisor_id%TYPE
  ,p_person_id                in per_all_assignments_f.person_id%TYPE
  ,p_business_group_id        in per_all_assignments_f.business_group_id%TYPE
  ,p_validation_start_date    in per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |------------------< chk_supervisor_assignment_id >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the supervisor assignment belongs to the supervisor.
--    - Validates that the supervisor assignment is date effectively valid for
--      the validation period of the assignment.
--    - Validates that the supervisor is for an employee or contingent
--      worker assignment.
--
--  Pre-conditions:
--    A valid supervisor
--
--  In Arguments:
--    p_assignment_id
--    p_supervisor_id
--    p_supervisor_assignment_id
--    p_validation_start_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the supervisor assignment is null.
--      - the supervisor assignment belongs to the supervisor and is effective.
--      - the supervisor assignment is an employee or contingent worker
--      -- assignment.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - the supervisor assignment does not belong to the supervisor
--      - the supervisor assignment is not effective
--      - the supervisor is not an employee or contingent worker assignment
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_supervisor_assignment_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_supervisor_id            in per_all_assignments_f.supervisor_id%TYPE
  ,p_supervisor_assignment_id in out nocopy per_all_assignments_f.supervisor_assignment_id%TYPE
  ,p_validation_start_date    in per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-----------------------< chk_system_pers_type >--------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that system person type has not changed in the future
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
--    If no system person type changes exist in the future then processing
--    continues.
--
--  Post Failure:
--    If the system person type changes in the future an application error
--    is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_system_pers_type
  (p_person_id              in per_all_assignments_f.person_id%TYPE
  ,p_validation_start_date  in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date    in per_all_assignments_f.effective_end_date%TYPE
  ,p_datetrack_mode         in varchar2
  ,p_effective_date         in date
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_term_status >-----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates an assignment cannot be deleted using the following datetrack
--    modes :
--                     - DELETE_NEXT_CHANGE
--                     - DELETE_FUTURE_CHANGE
--                     - UPDATE_OVERRIDE
--
--    if the assignment is terminated in the future, i.e. Assignment Status
--    Type set to 'TERM_ASSIGN'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_validation_start_date
--    p_datetrack_mode
--
--  Post Success:
--    If assignment is not terminated in the future then processing
--    continues.
--
--  Post Failure:
--    If the assignment is terminated in the future then an
--    application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_term_status
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  );
--
-- 70.1 change d start.
--
--  --------------------------------------------------------------------------+
--  |---------------------< chk_time_normal_finish >--------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that the time_normal_finish is a valid format.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_time_normal_finish
--
--  Post Success:
--    If time_normal_finish is a valid format then processing continues
--
--  Post Failure:
--    If time_normal_finish is not a valid format then an application error is
--    raised
--    and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_time_normal_finish
  (p_time_normal_finish in per_all_assignments_f.time_normal_finish%TYPE
  );
--
--
procedure chk_time_finish_formatted
  (p_time_normal_finish in out nocopy per_all_assignments_f.time_normal_finish%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------< chk_time_normal_start >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that the time_normal_start is a valid format.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_time_normal_start
--
--  Post Success:
--    If time_normal_start is a valid format then processing continues
--
--  Post Failure:
--    If time_normal_start is not a valid format then an application error is
--    raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_time_normal_start
  (p_time_normal_start in per_all_assignments_f.time_normal_start%TYPE
  );
--
--
procedure chk_time_start_formatted
  (p_time_normal_start in out nocopy per_all_assignments_f.time_normal_start%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |------------------------< chk_dup_apl_vacancy >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates this application to see if it is a duplicate for an existing open
--    vacancy that has already been applied for by this person. This check is done
--    only for applicant assignments.
--
--  Pre-conditions:
--    The assignment should be an Applicant Assignment.
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_vacancy_id
--    p_effective_date
--    p_assignment_type
--
--  Post Success:
--    If condition not met then processing continues
--
--  Post Failure:
--    If condition met then an application error is raised
--    and processing is terminated
--
procedure chk_dup_apl_vacancy
   (p_person_id              in per_all_assignments_f.person_id%type
   ,p_business_group_id      in per_all_assignments_f.business_group_id%type
   ,p_vacancy_id             in per_all_assignments_f.vacancy_id%type
   ,p_effective_date         in date
   ,p_assignment_type        in per_all_assignments_f.assignment_type%TYPE default null
   );
--
--  Start changes for bug 8687386
--  --------------------------------------------------------------------------+
--  |------------------------< chk_dup_apl_vacancy >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates this application to see if it is a duplicate for an existing open
--    vacancy that has already been applied for by this person. This check is done
--    only for applicant assignments. For update cases, it will validate the vacancy_id
--    with the other applicant applications except the current applicant application.
--
--  Pre-conditions:
--    The assignment should be an Applicant Assignment.
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_vacancy_id
--    p_effective_date
--    p_assignment_type
--    p_assignment_id
--    p_validation_start_date
--    p_validation_end_date
--    p_datetrack_mode
--
--  Post Success:
--    If condition not met then processing continues
--
--  Post Failure:
--    If condition met then an application error is raised
--    and processing is terminated
--
procedure chk_dup_apl_vacancy
   (p_person_id              in per_all_assignments_f.person_id%type
   ,p_business_group_id      in per_all_assignments_f.business_group_id%type
   ,p_vacancy_id             in per_all_assignments_f.vacancy_id%type
   ,p_effective_date         in date
   ,p_assignment_type        in per_all_assignments_f.assignment_type%TYPE default null
   ,p_assignment_id          in per_all_assignments_f.assignment_id%TYPE
   ,p_validation_start_date  in per_all_assignments_f.effective_start_date%TYPE
   ,p_validation_end_date    in per_all_assignments_f.effective_end_date%TYPE
   ,p_datetrack_mode         in varchar2
   );
--  End changes for bug 8687386
--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_vacancy_id >------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that on insert of an employee assignment that
--      vacancy is not set. Also on update of an employee assignment
--      when vacancy is set then checks that the existing vacancy
--      is the same as the set vacancy.
--    - Validates that the vacancy exists in PER_VACANCIES and the effective
--      start date is between the date from and date to of the vacancy.
--    - If the assignment is of type Offers, validates that the vacancy exists
--      in PER_VACANCIES
--    - Validates that the vacancy is in the same business group as the assignment.
--
--  Pre-conditions:
--    A valid assignment type
--    A valid business group
--
--  In Arguments:
--    p_vacancy_id
--    p_assignment_type
--    p_business_group_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an employee assignment and is not set on insert.
--        Or on update of an employee assignment when vacancy is set, the
--        existing vacancy is the same as the set vacancy.
--      - the vacancy exists in PER_VACANCIES where the effective start date of
--        the assignment is between the date from and date to of the vacancy.
--      - the vacancy is in the same business group as the assignment business
--        group.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is an employee assignment and is set on insert.
--        Or on update of an employee assignment when vacancy
--        is set, the existing vacancy is different to the set vacancy.
--      - the vacancy does'nt exist in PER_VACANCIES where the effective start
--        date of the assignment is between the date from and date to of the
--        vacancy. This will fail for all assignment types except for Offer.
--      - the vacancy is in a different business group to the assignment
--        business group.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_vacancy_id
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id      in     per_all_assignments_f.business_group_id%TYPE
  ,p_vacancy_id             in     per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  );
--
--  --------------------------------------------------------------------------+
--  |----------------------< gen_assignment_sequence >------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that the assignment_sequence is generated on insert only
--    and then cannot be updated. It is generated using the next unique
--    assignment sequence for a given combination of person_id and
--    assignment_type (which should always be 'E' as per Royal Navy
--    requirements).
--
--  Pre-conditions:
--    A valid person_id
--    A valid assignment_type
--
--  In Arguments:
--    p_assignment_type
--    p_person_id
--
--  Post Success:
--    This procedure should always succeed as the assignment_type and
--    person_id are validated prior to the execution of the procedure.
--
--  Post Failure:
--    This procedure should not fail as the assignment_type and person_id
--    are validated prior to the execution of the procedure.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure gen_assignment_sequence
  (p_assignment_type     in per_all_assignments_f.assignment_type%TYPE
  ,p_person_id           in per_all_assignments_f.person_id%TYPE
  ,p_assignment_sequence in out nocopy per_all_assignments_f.assignment_sequence%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-----------------------< other_managers_in_org >-------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Checks to see if any other current assignments for the same organization
--    have the manager_flag set to 'Y', and returns the appropriate boolean
--    result.
--
--  Pre-conditions:
--    A valid Organization ID
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_organization_id
--
--  Post Success:
--    TRUE if other managers found, FALSE otherwise.
--
--  Post Failure:
--    If the cursor raises an error, it will be passed back to the calling
--    routine as an unhandled exception.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
function other_managers_in_org
  (p_organization_id            in per_all_assignments_f.organization_id%TYPE
  ,p_assignment_id              in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date             in date
  ) return boolean;
--
--  --------------------------------------------------------------------------+
--  |-----------------------< gen_date_probation_end >------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--
--    Checks that when date probation end is not null that a value is not
--    calculated and the parameter value is used. When date probation end is
--    null then providing that probation period and probation unit are both
--    not null and probation unit does not have the value of 'H' then date
--    probation end is calculated based on the value of probation unit.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_probation_unit
--    p_probation_period
--    p_validation_start_date
--    p_object_version_number
--    p_date_probation_end
--
--  Out Arguments:
--    p_date_probation_end
--
--  Post Success:
--    If date probation end is not null then this not null value is passed out
--    in the parameter date probation end.
--
--    If date probation end is null and probation unit and probation period
--    are both not null and probation unit is not 'H' then date probation end
--    is calculated and passed out in the parameter date probation end.
--
--  Post Failure:
--    If any errors are raised they will be passed back to the calling routine
--    as an unhandled exception.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure gen_date_probation_end
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date         in     date
  ,p_probation_unit         in     per_all_assignments_f.probation_unit%TYPE
  ,p_probation_period       in     per_all_assignments_f.probation_period%TYPE
  ,p_validation_start_date  in     per_all_assignments_f.effective_start_date%TYPE
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_date_probation_end     in out nocopy per_all_assignments_f.date_probation_end%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_internal_address_line  >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment is an employee or applicant or offer assignment.
--    - Temporary: Validates that the <Val. attr.> is null or
--      unchanged on insert.
--
--  Pre-conditions:
--    A valid assignment type.
--
--  In Arguments:
--    p_assignment_id
--    p_assignment_type
--    p_internal_address_line
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the internal address line is set for an employee or applicant or
--        offer assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the internal address line is set for a non employee or
--        applicant or offer assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_internal_address_line
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type         in per_all_assignments_f.assignment_type%TYPE
  ,p_internal_address_line   in per_all_assignments_f.internal_address_line%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  );
end per_asg_bus2;

/
