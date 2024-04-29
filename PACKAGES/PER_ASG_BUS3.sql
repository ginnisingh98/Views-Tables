--------------------------------------------------------
--  DDL for Package PER_ASG_BUS3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_BUS3" AUTHID CURRENT_USER as
/* $Header: peasgrhi.pkh 120.4.12010000.2 2009/11/20 06:56:26 sidsaxen ship $ */
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is a contingent worker assignment.
--    - Validates that the Supplier is effective and enabled.
--
--  Pre-conditions:
--    A valid assignment type.
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_vendor_id
  (p_assignment_id          IN NUMBER
  ,p_assignment_type        IN VARCHAR2
  ,p_vendor_id              IN NUMBER
  ,p_business_group_id      IN NUMBER
  ,p_object_version_number  IN NUMBER
  ,p_effective_date         IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_site_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is a contingent worker assignment.
--    - Validates that the Supplier Site exists in po_vendor_sites_all.
--
--  Pre-conditions:
--    A valid assignment type.
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_vendor_site_id
  (p_assignment_id          IN NUMBER
  ,p_assignment_type        IN VARCHAR2
  ,p_vendor_site_id         IN NUMBER
  ,p_object_version_number  IN NUMBER
  ,p_effective_date         IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_po_header_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is a contingent worker assignment.
--    - Validates that Services Procurement is installed.
--    - Validates that the PO is a Services Procurement PO, that it is of
--      a valid status (for example, Approved), that it exists within the
--      business group and that there is at least one purchase order line
--      which is of a Services Procurement line type and is unassigned
--      to any other HR assignment.
--
--  Pre-conditions:
--    A valid assignment type.
--    A valid business group.
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_po_header_id
  (p_assignment_id          IN NUMBER
  ,p_assignment_type        IN VARCHAR2
  ,p_po_header_id           IN NUMBER
  ,p_business_group_id      IN NUMBER
  ,p_object_version_number  IN NUMBER
  ,p_effective_date         IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_po_line_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is a contingent worker assignment.
--    - Validates that Services Procurement is installed.
--    - Validates that the PO Line has at least one purchase order line
--      which is of a Services Procurement line type and is unassigned
--      to any other HR assignment.
--
--  Pre-conditions:
--    A valid assignment type.
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_po_line_id
  (p_assignment_id          IN NUMBER
  ,p_assignment_type        IN VARCHAR2
  ,p_po_line_id             IN NUMBER
  ,p_object_version_number  IN NUMBER
  ,p_effective_date         IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_projected_assignment_end >-----------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is a contingent worker assignment.
--    - Validates that the Projected Assignment End is not earlier than
--      the assignment effective start date.
--
--  Pre-conditions:
--    A valid effective_start_date
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_projected_assignment_end
  (p_assignment_id            IN NUMBER
  ,p_assignment_type          IN VARCHAR2
  ,p_effective_start_date     IN DATE
  ,p_projected_assignment_end IN DATE
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_id_site_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the Supplier Site belongs to the given Supplier.
--
--  Pre-conditions:
--    - Vendor_id has been validated.
--    - Vendor_site_id has been validated.
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_vendor_id_site_id
  (p_assignment_id            IN NUMBER
  ,p_vendor_id                IN NUMBER
  ,p_vendor_site_id           IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_po_header_id_line_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the Purchase Order Line exists within the Purchase Order.
--
--  Pre-conditions:
--    - Purchase Order has been validated.
--    - Purchase Order line has been validated.
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_po_header_id_line_id
  (p_assignment_id            IN NUMBER
  ,p_po_header_id             IN NUMBER
  ,p_po_line_id               IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_po_match >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the Supplier and Supplier Site on the assignment is the
--      same as the Supplier on the Purchase Order.
--
--  Pre-conditions:
--    A valid Supplier.
--    A valid Supplier Site.
--    A valid Purchase Order header.
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_vendor_po_match
  (p_assignment_id            IN NUMBER
  ,p_vendor_id                IN NUMBER
  ,p_vendor_site_id           IN NUMBER
  ,p_po_header_id             IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_po_job_match >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the job on the assignment matches the job on the
--      Purchase Order Line.
--
--  Pre-conditions:
--    A valid Job.
--    A valid Purchase Order line.
--
--  In Arguments:
--    As below.
--
--  Post Success:
--    Processing continues if the above validation passes and no
--    error is raised.
--
--  Post Failure:
--    If the above validation fails, an error is raised and processing
--    halts.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
PROCEDURE chk_po_job_match
  (p_assignment_id            IN NUMBER
  ,p_job_id                   IN NUMBER
  ,p_po_line_id               IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE);
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_employee_number >-------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is an non payrolled worker assignment.
--    - Validates that the vendor employee number is set for an NPW assignment.
--
--  Pre-conditions:
--    A valid assignment type
--    A Valid business group
--
--  In Arguments:
--    p_assignment_id
--    p_business_group_id
--    p_vendor_employee_number
--    p_assignment_type
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an NPW assignment.
--      - vendor empoyee number is set for an NPW assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is not an NPW assignment.
--      - vendor employee number is not set for a NPW assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
PROCEDURE chk_vendor_employee_number
  (p_assignment_id          IN per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type        IN per_all_assignments_f.assignment_type%TYPE
  ,p_vendor_employee_number IN per_all_assignments_f.vendor_employee_number%TYPE
  ,p_business_group_id      IN per_assignments_f.business_group_id%TYPE
  ,p_object_version_number  IN per_all_assignments_f.object_version_number%TYPE
  ,p_effective_date         IN DATE);
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_vendor_assignment_number >-------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is an non payrolled worker assignment.
--    - Validates that the vendor assignment number is set for an NPW assignment.
--
--  Pre-conditions:
--    A valid assignment type
--    A Valid business group
--
--  In Arguments:
--    p_assignment_id
--    p_business_group_id
--    p_vendor_assignment_number
--    p_assignment_type
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an NPW assignment.
--      - vendor assignment number is set for an NPW assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is not an NPW assignment.
--      - vendor assignment number is not set for a NPW assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
PROCEDURE chk_vendor_assignment_number
  (p_assignment_id            IN per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type          IN per_all_assignments_f.assignment_type%TYPE
  ,p_vendor_assignment_number IN per_all_assignments_f.vendor_assignment_number%TYPE
  ,p_business_group_id        IN per_assignments_f.business_group_id%TYPE
  ,p_object_version_number    IN per_all_assignments_f.object_version_number%TYPE
  ,p_effective_date           IN DATE);
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_pop_date_start >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is an non payrolled worker assignment.
--    - Validates that the period of placement date start is set for
--      an NPW assignment.
--    - Validates that the period of placement date start exists in
--      PER_PERIODS_OF_PLACEMENTS between the period of service date start
--      and actual termination date and for the person id.
--    - Validates that the business_group_id of the Assignment is the same as
--      that of the period of placement.
--    - Validates that the effective start date of the assignment is between
--      the date start and actual termination date of the period of placement.
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
--    p_pop_date_start
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an NPW assignment.
--      - period of placement is set for an NPW assignment.
--      - period of placement exists in PER_PERIODS_OF_PLACMENT between
--        date start and actual termination date and for the person id.
--      - the period of placment is in the same business group as the
--        assignment business group.
--      - the effective start date of the assignment is between date start
--        and actual termination date of the period of placement.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is not an NPW assignment.
--      - period of placement is not set for a NPW assignment.
--      - period of placement does'nt exist in PER_PERIODS_OF_PLACEMENT between
--        date start and actual termination date and for the person_id
--      - the period of placement is in a different business group to
--        the assignment business group.
--      - the effective start date of the assignment is not between date
--        start and actual termination date of the period of placement.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
PROCEDURE chk_pop_date_start
  (p_assignment_id          IN per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id      IN per_all_assignments_f.business_group_id%TYPE
  ,p_person_id              IN per_all_assignments_f.person_id%TYPE
  ,p_assignment_type        IN per_all_assignments_f.assignment_type%TYPE
  ,p_pop_date_start         IN per_periods_of_placement.date_start%TYPE
  ,p_validation_start_date  IN DATE
  ,p_validation_end_date    IN DATE
  ,p_effective_date         IN DATE
  ,p_object_version_number  IN per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_cagr_grade_def_id  >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment cagr_grade_def_id is valid.
--
--  Pre-conditions:
--    A valid cagr_id_flex_num
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--    p_cagr_grade_def_id
--    p_collective_agreement_id
--    p_cagr_id_flex_num
--
--  Post Success:
--    Processing continues if:
--      - the cagr_grade_def_id is valid for an employee assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the cagr_grade_def_id / p_collective_agreement_id combination is
--        invalid.
--      - The user has tried to insert a new grade, hwen only reference grades
--        are allowed.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_cagr_grade_def_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_cagr_grade_def_id       in per_all_assignments_f.cagr_grade_def_id%TYPE
  ,p_collective_agreement_id in per_all_assignments_f.collective_agreement_id%TYPE
  ,p_cagr_id_flex_num        in per_all_assignments_f.cagr_id_flex_num%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_cagr_id_flex_num  >----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment cagr_id_flex_num is valid.
--
--  Pre-conditions:
--   A validated collective_agreement_id
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--    p_cagr_id_flex_num
--    p_collective_agreement_id
--
--  Post Success:
--    Processing continues if:
--      - the cagr_id_flex_num is valid for an assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the cagr_id_flex_num is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_cagr_id_flex_num
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_cagr_id_flex_num        in per_all_assignments_f.cagr_id_flex_num%TYPE
  ,p_collective_agreement_id in per_all_assignments_f.collective_agreement_id%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_contract_id >----------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment contract_id is valid.
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--    p_contract_id
--    p_validation_start_date
--    p_business_group_id
--
--
--  Post Success:
--    Processing continues if:
--      - the chk_contract_id is valid for an assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the chk_contract_id is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_contract_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_contract_id             in per_all_assignments_f.contract_id%TYPE
  ,p_person_id               in per_all_assignments_f.person_id%TYPE
  ,p_validation_start_date   in date
  ,p_business_group_id       in per_all_assignments_f.business_group_id%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_collective_agreement_id >----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment collective_agreement_id is valid.
--
--  Pre-conditions:
--   A validated establishment_id
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--    p_collective_agreement_id
--    p_business_group_id
--    p_establishment_id
--
--  Post Success:
--    Processing continues if:
--      - the collective_agreement_id is valid for an assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the collective_agreement_id is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_collective_agreement_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_collective_agreement_id in per_all_assignments_f.collective_agreement_id%TYPE
  ,p_business_group_id       in per_all_assignments_f.business_group_id%TYPE
  ,p_establishment_id        in per_all_assignments_f.establishment_id%TYPE
  );
--  --------------------------------------------------------------------------+
--  |--------------------< chk_establishment_id >-----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the assignment establishment_id is valid.
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--    p_establishment_id
--    p_business_group_id
--
--  Post Success:
--    Processing continues if:
--      - the establishment_id is valid for an assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the establishment_id is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_establishment_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_establishment_id        in per_all_assignments_f.establishment_id%TYPE
  ,p_assignment_type         in per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id       in per_all_assignments_f.business_group_id%TYPE
   );

--  --------------------------------------------------------------------------+
--  |--------------------< chk_notice_period >-----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the notice_period is valid.
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_assignment_id
--    p_notice_period

--
--  Post Success:
--    Processing continues if:
--      - the notice_period is valid.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the notice_period is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_notice_period
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_notice_period           in per_all_assignments_f.notice_period%TYPE
   );

--  --------------------------------------------------------------------------+
--  |--------------------< chk_notice_period_uom >-----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the notice_period_uom is valid.
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_assignment_id
--    p_notice_period
--    p_notice_period_uom
--    p_effective_date
--
--  Post Success:
--    Processing continues if:
--      - the notice_period_uom is valid.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the notice_period_uom is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_notice_period_uom
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_notice_period           in per_all_assignments_f.notice_period%TYPE
  ,p_notice_period_uom       in per_all_assignments_f.notice_period_uom%TYPE
  ,p_effective_date          in date
  ,p_validation_start_date      IN DATE
  ,P_VALIDATION_END_DATE                IN DATE
   );

--  --------------------------------------------------------------------------+
--  |--------------------< chk_work_at_home >-----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the work_at_home is valid.
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_assignment_id
--    p_work_at_home
--    p_effective_date
--
--  Post Success:
--    Processing continues if:
--      - the work_at_home is valid.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the work_at_home is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_work_at_home
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_work_at_home            in per_all_assignments_f.work_at_home%TYPE
  ,p_effective_date          in date
  ,p_validation_start_date      IN DATE
  ,P_VALIDATION_END_DATE                IN DATE
   );

--  --------------------------------------------------------------------------+
--  |--------------------< chk_employee_category >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the employee_category is valid.
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_assignment_id
--    p_employee_category
--    p_effective_date
--
--  Post Success:
--    Processing continues if:
--      - the employee_category is valid.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the employee_category is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_employee_category
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_employee_category       in per_all_assignments_f.employee_category%TYPE
  ,p_effective_date          in date
   ,p_validation_start_date     IN DATE
  ,P_VALIDATION_END_DATE                IN DATE
   );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_grade_ladder_pgm_id >--------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the grade_ladder_pgm_id is valid.
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_grade_id
--    p_grade_ladder_pgm_id
--    p_business_group_id
--    p_effective_date
--
--  Post Success:
--    Processing continues if:
--      - the grade_ladder_pgm_id is valid.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the grade_ladder_pgm_id is invalid.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
 procedure chk_grade_ladder_pgm_id
  ( p_grade_id            in  per_all_assignments_f.grade_id%TYPE
   ,p_grade_ladder_pgm_id in  per_all_assignments_f.grade_ladder_pgm_id%TYPE
   ,p_business_group_id   in  per_all_assignments_f.business_group_id%TYPE
   ,p_effective_date      in  date
  ) ;
--
--  --------------------------------------------------------------------------+
--  |--------------------< access_to_primary_asg >----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Determines whether the primary assignment is visible to the current
--      session.
--
--  Pre-conditions:
--    Security should have been initialised using fnd_global.apps_initialise.
--
--  In Arguments:
--    p_person_id
--    p_effective_date
--    p_assignment_type
--
--  Post Success:
--    The function returns TRUE.
--
--  Post Failure:
--    The function returns FALSE.
--
--  Access Status:
--    Internal Development Use Only.
--
 FUNCTION access_to_primary_asg
  (p_person_id       IN NUMBER
  ,p_effective_date  IN DATE
  ,p_assignment_type IN VARCHAR2)
 RETURN BOOLEAN;
--
end per_asg_bus3;


/
