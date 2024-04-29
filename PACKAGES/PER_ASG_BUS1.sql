--------------------------------------------------------
--  DDL for Package PER_ASG_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_BUS1" AUTHID CURRENT_USER as
/* $Header: peasgrhi.pkh 120.4.12010000.2 2009/11/20 06:56:26 sidsaxen ship $ */
--
-- ---------------------------------------------------------------------------+
-- |------------------------< set_security_group_id >-------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--  Sets the security_group_id in CLIENT_INFO for the assignment's business
--  group context.
--
-- Prerequisites:
--   None,
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   Assignment to use for
--                                                deriving the security group
--                                                context.
--
-- Post Success:
--   The security_group_id will be set in CLIENT_INFO.
--
-- Post Failure:
--   An error is raised if the assignment_id does not exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- ---------------------------------------------------------------------------+
procedure set_security_group_id
  (
   p_assignment_id             in per_all_assignments_f.assignment_id%TYPE
  ,p_associated_column1                   in varchar2 default null
  );
--
-- ---------------------------------------------------------------------------+
-- |----------------------< check_non_updateable_args >-----------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updatetable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (business_group_id, person_id, assignment_sequence, assignment_type,
--   period_of_service_id, primary_flag, or assignment_id) have been altered.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure check_non_updateable_args(p_rec in per_asg_shd.g_rec_type
                                   ,p_effective_date in date);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Pre Conditions:
--   This procedure is called from the delete_validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_assignment_id            in number,
             p_datetrack_mode           in varchar2,
             p_validation_start_date    in date,
             p_validation_end_date      in date);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Pre Conditions:
--   This procedure is called from the update_validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (p_payroll_id                    in number default hr_api.g_number,
             p_person_id                     in number default hr_api.g_number,
             p_datetrack_mode                in varchar2,
             p_validation_start_date         in date,
             p_validation_end_date           in date);
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
        (p_rec                        in out nocopy  per_asg_shd.g_rec_type,
         p_effective_date             in      date,
         p_datetrack_mode             in      varchar2,
         p_validation_start_date      in      date,
         p_validation_end_date        in      date,
         p_validate_df_flex           in      boolean,
         p_other_manager_warning      out nocopy     boolean,
         p_hourly_salaried_warning    out nocopy     boolean,
         p_inv_pos_grade_warning      out nocopy     boolean
);
--
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
        (p_rec                    in out nocopy      per_asg_shd.g_rec_type,
         p_effective_date             in      date,
         p_datetrack_mode             in      varchar2,
         p_validation_start_date      in      date,
         p_validation_end_date        in      date,
         p_payroll_id_updated         out nocopy     boolean,
         p_other_manager_warning      out nocopy     boolean,
         p_hourly_salaried_warning    out nocopy     boolean,
         p_no_managers_warning        out nocopy     boolean,
         p_org_now_no_manager_warning out nocopy     boolean,
         p_inv_pos_grade_warning      out nocopy     boolean
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
        (p_rec                        in per_asg_shd.g_rec_type,
         p_effective_date             in date,
         p_datetrack_mode             in varchar2,
         p_validation_start_date      in date,
         p_validation_end_date        in date,
         p_org_now_no_manager_warning out nocopy boolean,
         p_loc_change_tax_issues      OUT nocopy boolean,
         p_delete_asg_budgets         OUT nocopy boolean,
         p_element_salary_warning     OUT nocopy boolean,
         p_element_entries_warning    OUT nocopy boolean,
         p_spp_warning                OUT nocopy boolean,
         p_cost_warning               OUT nocopy boolean,
         p_life_events_exists         OUT nocopy boolean,
         p_cobra_coverage_elements    OUT nocopy boolean,
         p_assgt_term_elements        OUT nocopy boolean,
         ---
	 p_new_prim_ass_id            OUT nocopy number,
         p_prim_change_flag           OUT nocopy varchar2,
         p_new_end_date               OUT nocopy date,
         p_new_primary_flag           OUT nocopy varchar2,
         p_s_pay_id                   OUT nocopy number,
         p_cancel_atd                 OUT nocopy date,
         p_cancel_lspd                OUT nocopy date,
         p_reterm_atd                 OUT nocopy date,
         p_reterm_lspd                OUT nocopy date,
         ---
	 p_appl_asg_new_end_date      OUT nocopy date );
--
--  --------------------------------------------------------------------------+
--  |-----------------------< chk_application_id >----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates for the first applicant assignment for an applicant that when
--      set the application exists in PER_APPLICATIONS and the application date
--      received is the same as the assignment effective start date.
--    - Validates for all applicant assignments apart from the first and all the
--      offer assignments including the first that when set the application exists
--      in PER_APPLICATIONS and the applicant assignment effective start date is
--      between the date received and date end of the application when date end is set.
--    - Validates that for an applicant and an offer assignment the application is set.
--    - Validates that when inserting an employee assignment that the
--      application is not set.
--    - Validates that the application is not nullified for the update of an
--      employee assignment with an application which is already set.
--    - Validates that the business group of the application is the same as the
--      business group of the assignment.
--
--  Pre-conditions:
--    Valid assignment type
--    Valid business group
--
--  In Arguments:
--    p_assignment_id
--    p_assignment_type
--    p_business_group_id
--    p_application_id
--    p_effective_date
--    p_object_version_number
--    p_validation_start_date
--
--  Post Success:
--    Processing continues if:
--      - the application is set for the first applicant assignment and exists
--        in PER_APPLICATIONS and the application date received is the same as
--        the assignment effective start date.
--      - the application is set for an applicant assignment other than the first
--        applicant assignment and exists in PER_APPLICATIONS and the effective
--        start date of the applicant assignment is between the date received and
--        date end of the application when date end is set.
--        the assignment effective start date.
--      - the application is set for an applicant and an offer assignment.
--      - the application is not set for the insert of an employee assignment.
--      - the application is not nullified for the update of an employee
--        assignment with an existing set application.
--      - the application is in the same business group as the
--        assignment business group.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - the application is set for the first applicant assignment and does'nt
--        exist in PER_APPLICATIONS or the application date received is not the
--        same as the assignment effective start date.
--      - the application is set for an applicant assignment other than the first
--        applicant assignment and does'nt exist in PER_APPLICATIONS where the
--        effective start date of the applicant assignment is between the date
--        received and date end of the application when date end is set.
--      - the application is not set for an applicant or an offer assignment.
--      - the application is set for the insert of an employee assignment.
--      - the application is nullified for the update of an employee
--        assignment with an existing set application.
--      - the application is in a different business group as the
--        assignment business group.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_application_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type          in per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id        in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_sequence      in per_all_assignments_f.assignment_sequence%TYPE
  ,p_application_id           in per_all_assignments_f.application_id%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date    in date
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------< gen_chk_assignment_number >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates for applicant, benefits and offer assignments that assignment
--      number is not set.
--    - Validates for employee assignments that assignment number is set by
--      calling procedure hr_assignment.gen_new_ass_number to :
--      a) Generate a new assignment_number on insert. (Generation only
--         occurs when the user does not provide a value.)
--      b) Check the uniqueness of the assignment number on insert or
--         update.
--
--  Pre-conditions:
--    A valid business group
--    A valid assignment type
--    A valid assignment sequence
--    A valid person
--
--  In Arguments:
--    p_assignment_id
--    p_business_group_id
--    p_assignment_type
--    p_assignment_sequence
--    p_person
--    p_assignment_number
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--    - For applicant, benefits and offer assignments, the assignment number is not set.
--    - For employee assignments, the assignment number is set. On insert
--      if a null assignment_number is passed then in a new number is
--      generated and processing will continue. On update, if the new
--      assignment_number is valid after a uniqueness check then
--      processing continues.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--    - For applicant benefits and offer assignments, the assignment number is set.
--    - For employee assignments, the assignment number is not set. Hence,
--      an assignment number cannot be generated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure gen_chk_assignment_number
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_assignment_sequence   in per_all_assignments_f.assignment_sequence%TYPE
  ,p_assignment_number     in out nocopy per_all_assignments_f.assignment_number%TYPE
  ,p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_effective_date        in date
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  );
--
-- ---------------------------------------------------------------------------+
-- |----------------------< chk_assignment_status_type >----------------------|
-- ---------------------------------------------------------------------------+
--
--  Description:
--
--    If the assignment status type id is passed in, then it is validated
--    against the expected system status and business group, otherwise the
--    default assignment status type id for the specified system status,
--    business group and legislation code is returned.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_status_type_id
--    p_business_group_id
--    p_legislation_code
--    p_expected_system_status
--
--  Post Success:
--    If assignment_status_type_id is valid or can be derived then processing
--    continues
--
--  Post Failure:
--    If assignment_status_type_id is not valid or cannot be derived then an
--    application error is raised and processing is terminated
--
--  Access Status:
--    HR Development Use Only.
--
--
procedure chk_assignment_status_type
  (p_assignment_status_type_id in out nocopy number
  ,p_business_group_id         in     number
  ,p_legislation_code          in     varchar2
  ,p_expected_system_status    in     varchar2
  );
--
-- 70.3 change c end.
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_assignment_status_type_id >--------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--
--    - Validates that the assignment status type is set.
--    - Validates that the assignment status type exists in
--      PER_ASSIGNMENT_STATUS_TYPES.
--    - Validates that the assignment status type active flag is set to 'Y'.
--      When an assignment status type(ASS_STATUS_TYPE_AMEND_ID) exists in
--      PER_ASS_STATUS_TYPE_AMENDS for the assignment business group then
--      active flag is validated against PER_ASS_STATUS_TYPE_AMENDS. When the
--      assignment status type does'nt exist in PER_ASS_STATUS_TYPE_AMENDS for
--      the assignment business group then active flag is validated against
--      PER_ASSIGNMENT_STATUS_TYPES.
--    - Validates that when the business group is set for the assignment status
--      type that the assignment status type is in the same business group
--      as the assignment.
--    - Validates on update of employee assignments, that when the assignment
--      status type PER_SYSTEM_STATUS is 'TERM_ASSIGN' no other attributes on
--      the employee assignment can be updated and the new PER_SYSTEM_STATUS
--      must also be 'TERM_ASSIGN'.
--    - Validates on update of employee assignments, that PER_SYSTEM_STATUS
--      for the assignment status type is either 'ACTIVE_ASSIGN', 'SUSP_ASSIGN'
--      or 'TERM_ASSIGN'.
--    - Validates on update of employee assignments and when the new
--      assignment status type PER_SYSTEM_STATUS is 'ACTIVE_ASSIGN' that an
--      assignment status type PER_SYSTEM_STATUS of 'ACTIVE_ASSIGN' exists
--      before the validation start date of the assignment.
--    - Validates on insert of employee assignments that the assignment
--      status type PER_SYSTEM_STATUS is 'ACTIVE_ASSIGN'.
--    - Validates on update of an applicant assignment that the assignment status
--      type PER_SYSTEM_STATUS is either 'ACTIVE_APL', 'OFFER' or 'ACCEPTED'.
--    - Validates on insert or update in datetrack 'CORRECTION' mode of applicant
--      assignments that the assignment status type PER_SYSTEM_STATUS is
--      'ACTIVE_APL'.
--    - Validates on update that the first datetracked instance of an applicant
--      assignment does not have an assignment status type PER_SYSTEM_STATUS of
--      'TERM_APL'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_rec
--    p_effective_date
--    p_validation_start_date
--
--  Post Success:
--    Processing continues if:
--
--      - the assignment status type is set.
--      - the assignment status type exists in PER_ASSIGNMENT_STATUS_TYPES.
--      - the assignment status type active flag is set to 'Y' in
--        PER_ASS_STATUS_TYPE_AMENDS or PER_ASSIGNMENT_STATUS_TYPES.
--      - when set the assignment status type business group is the same as the
--        assignment business group.
--      - the assignment status type is being updated for an employee assignment
--        and the existing assignment status type PER_SYSTEM_STATUS is
--        'TERM_ASSIGN' but no other employee assignment attribute values have
--        been modified.
--      - the assignment status type is being updated for an employee assignment
--        and the existing assignment status type PER_SYSTEM_STATUS is
--        'TERM_ASSIGN' and the new PER_SYSTEM_STATUS of the assignment status
--        type is 'TERM_ASSIGN'.
--      - the assignment status type is being updated for an employee assignment
--        and PER_SYSTEM_STATUS for the assignment status type is either
--        'ACTIVE_ASSIGN', 'SUSP_ASSIGN' or 'TERM_ASSIGN'.
--      - the assignment status type is being updated for an employee assignment
--        and the new assignment status type PER_SYSTEM_STATUS is 'ACTIVE_ASSIGN'
--        and a assignment status type PER_SYSTEM_STATUS exists before the
--        validation start date of the assignment.
--      - the assignment status type is being inserted for an employee assignment
--        and the PER_SYSTEM_STATUS of the assignment status type is 'ACTIVE_ASSIGN'.
--      - the assignment status type is being updated for an applicant assignment
--        and the PER_SYSTEM_STATUS of the assignment status type is either
--        'ACTIVE_APL', 'OFFER' or 'ACCEPTED'.
--      - the assignment status type is being inserted or updated in datetrack
--        'CORRECTION' mode for an applicant assignment and the PER_SYSTEM_STATUS
--        of the assignment status type is 'ACTIVE_APL'.
--      - the existing assignment status type PER_SYSTEM_STATUS is not 'TERM_APL'
--        on update.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--
--      - assignment status type is not set.
--      - assignment status type does not exist in PER_ASSIGNMENT_STATUS_TYPES.
--      - assignment status type active flag is not set to 'Y' in
--        PER_ASS_STATUS_TYPE_AMENDS or PER_ASSIGNMENT_STATUS_TYPES.
--      - when set the assignment status type business group is not the same as the
--        assignment business group.
--      - the assignment status type is being updated for an employee assignment
--        and the existing assignment status type is 'TERM_ASSIGN' but other
--        employee assignment attribute values have been modified.
--      - the assignment status type is being updated for an employee assignment
--        and the existing assignment status type PER_SYSTEM_STATUS is
--        'TERM_ASSIGN' and the new PER_SYSTEM_STATUS of the assignment status
--        type is not 'TERM_ASSIGN'.
--      - the assignment status type is being updated for an employee assignment
--        and PER_SYSTEM_STATUS for the assignment status type is not either
--        'ACTIVE_ASSIGN', 'SUSP_ASSIGN' or 'TERM_ASSIGN'.
--      - the assignment status type is being updated for an employee assignment
--        and the new assignment status type PER_SYSTEM_STATUS is 'ACTIVE_ASSIGN'
--        and a assignment status type PER_SYSTEM_STATUS does'nt exist before the
--        validation start date of the assignment.
--      - the assignment status type is being inserted for an employee assignment
--        and the PER_SYSTEM_STATUS of the assignment status type is not
--        'ACTIVE_ASSIGN'.
--      - the assignment status type is being updated for an applicant assignment
--        and the PER_SYSTEM_STATUS of the assignment status type is not either
--        'ACTIVE_APL', 'OFFER' or 'ACCEPTED'.
--      - the assignment status type is being inserted for an applicant assignment
--        and the PER_SYSTEM_STATUS of the assignment status type is not 'ACTIVE_APL'.
--      - the existing assignment status type PER_SYSTEM_STATUS is 'TERM_APL'
--        on update.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_assignment_status_type_id
  (p_rec                       in per_asg_shd.g_rec_type
  ,p_effective_date            in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_start_date     in per_all_assignments_f.effective_start_date%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_assignment_category >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    - Validates that the assignment is an non payrolled worker assignment.
--    - Validates that the assignment category number is set
--      for an NPW assignment.
--    - Validates that the assignment category exists in HR_LOOKUPS for the
--      LOOKUP_TYPE = 'NPW_ASG_CATEGORY'
--
--  Pre-conditions:
--    A valid assignment type
--    A Valid business group
--
--  In Arguments:
--    p_assignment_id
--    p_assignment_type
--    p_person_id
--    p_effective_date
--    p_assignment_category
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - the assignment is an NPW assignment.
--      - assignment category is set for an NPW assignment.
--      - assignment cateogry exists in 'NPW_ASG_CATEGORY' lookup.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment is not an NPW assignment.
--      - assignment category is set for a non NPW assignment.
--      - assignment cateogry does not exists in 'NPW_ASG_CATEGORY' lookup.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
PROCEDURE chk_assignment_category
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type       in     per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date        in     date
  ,p_assignment_category   in     per_assignments_f.assignment_category%TYPE
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date);
--
--  --------------------------------------------------------------------------+
--  |-----------------------< chk_assignment_type >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--
--    - Validates that assignment type is set to either 'A' or 'E' or 'C' or 'B' or 'O'
--    - Validates when assignment type is 'A' or 'O' that the system person
--      type of the person is either 'APL', 'APL_EX_APL', 'EMP_APL',
--      'EX_EMP_APL'.
--    - Validates when assignment type is 'E' that the system person
--      type of the person is either 'EMP', 'EMP_APL' or 'EX_EMP'.
--
--  Pre-conditions:
--    - A valid person
--
--  In Arguments:
--    p_assignment_type
--    p_person_id
--
--  Post Success:
--      - assignment type is set and is either 'A' or 'E' or 'C' or 'B' or 'O'.
--      - assignment type is 'A' or 'O' and the system person type of the person
--        is either 'APL', 'APL_EX_APL', 'EMP_APL', 'EX_EMP_APL'.
--      - assignment type is 'E' and the system person type of the person
--        is either 'EMP', 'EMP_APL' or 'EX_EMP'.
--
--  Post Failure:
--      - assignment type is set and is not either 'A' or 'E' or 'C' or 'B' or 'O'.
--      - assignment type is 'A' or 'O' and the system person type of the person
--        is not either 'APL', 'APL_EX_APL', 'EMP_APL', 'EX_EMP_APL'.
--      - assignment type is 'E' and the system person type of the person
--        is not either 'EMP', 'EMP_APL' or 'EX_EMP'.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_assignment_type
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type       in     per_all_assignments_f.assignment_type%TYPE
  ,p_person_id             in     per_all_assignments_f.person_id%TYPE
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date in     date
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_change_reason >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that for an employee assignment the change reason exists as a
--      lookup code on HR_LOOKUPS for the lookup type 'EMP_ASSIGN_REASON' with
--      an enabled flag set to 'Y' and the effective start date of the assignment
--      between start date active and end date active on HR_LOOKUPS.
--    - Validates that for an applicant assignment the change reason exists as a
--      lookup code on HR_LOOKUPS for the lookup type 'APL_ASSIGN_REASON' with
--      an enabled flag set to 'Y' and the effective start date of the assignment
--      between start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    A valid assignment_type
--
--  In Arguments:
--    p_assignment_id
--    p_assignment_type
--    p_change_reason
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - for employee assignments, change reason exists as a lookup code in
--        HR_LOOKUPS for the lookup type 'EMP_ASSIGN_REASON' where the
--        enabled flag is 'Y' and the effective start date of the assignment
--        is between start date active and end date active on HR_LOOKUPS.
--      - for applicant assignments, change reason exists as a lookup code in
--        HR_LOOKUPS for the lookup type 'APL_ASSIGN_REASON' where the
--        enabled flag is 'Y' and the effective start date of the assignment
--        is between start date active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - for employee assignments, change reason does'nt exist as a lookup
--        code in HR_LOOKUPS for the lookup type 'EMP_ASSIGN_REASON' where
--        the enabled flag is 'Y' and the effective start date of the
--        assignment is between start date active and end date active
--        on HR_LOOKUPS.
--      - for applicant assignments, change reason does'nt exist as a lookup
--        code in HR_LOOKUPS for the lookup type 'APL_ASSIGN_REASON' where
--        the enabled flag is 'Y' and the effective start date of the
--        assignment is between start date active and end date active
--        on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_change_reason
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE
  ,p_change_reason          in     per_all_assignments_f.change_reason%TYPE
  ,p_effective_date         in     date
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_contig_ass >------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that if an attempt is made to date effectively delete
--    a primary assignment, another contiguous non-primary assignment must
--    exist in order to be converted to a primary assignment.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_primary_flag
--    p_person_id
--    p_effective_date
--    p_datetrack_mode
--
--  Post Success:
--    If a contiguous non-primary assignment can be found then processing
--    continues.
--
--  Post Failure:
--    If no contiguous non-primary assignments can be found then an
--    application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_contig_ass
  (p_primary_flag   in per_all_assignments_f.primary_flag%TYPE
  ,p_person_id      in per_all_assignments_f.person_id%TYPE
  ,p_effective_date in date
  ,p_datetrack_mode in varchar2
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------< chk_date_probation_end >--------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--
--    Validates that date probation end should be after the earliest effective
--    start date for the assignment.
--
--    On insert and when date probation end, probation period and probation
--    unit are all not null and the value of probation unit is not 'H' the
--    value of date probation end is calculated.
--
--  Pre-conditions:
--    Valid assignment type
--    Valid probation period
--    Valid probation unit
--
--  In Arguments:
--    p_assignment_id
--    p_date_probation_end
--    p_assignment_type
--    p_probation_period
--    p_probation_unit
--    p_primary_flag
--    p_validation_start_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - date probation end is null.
--      - date probation end is not null and employee type is employee.
--      - date probation end is not null and after the earliest effective
--        start date for the assignment.
--      - on update, date probation end is the same as or after the validation
--        start date for the assignment.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - date probation end is not null and the assignment type is not of
--        employee.
--      - date probation end is not null but is before the earliest effective
--        start date for the assignment.
--      - on update, date probation end is not null but is before the
--        validation start date of the assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_date_probation_end
  (p_assignment_id             in     per_all_assignments_f.assignment_id%TYPE
  ,p_date_probation_end        in     per_all_assignments_f.date_probation_end%TYPE
  ,p_assignment_type           in     per_all_assignments_f.assignment_type%TYPE
  ,p_probation_period          in     per_all_assignments_f.probation_period%TYPE
  ,p_probation_unit            in     per_all_assignments_f.probation_unit%TYPE
  ,p_validation_start_date     in     date
  ,p_effective_date            in     date
  ,p_object_version_number     in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_default_code_comb_id >-------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that when default code comb is not null, default code comb
--      exists in GL_CODE_COMBINATIONS.
--    - Validates that the default code comb is being set for an employee
--      or applicant or offer assignment.
--    - Validates that the enabled flag is set to 'Y' for the default code
--      combination.
--    - Validates that the effective start date of the assignment is between
--      the start date active and end date active of the default code
--      combination.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_default_code_comb_id
--    p_assignment_type
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - default code comb is null.
--      - default code comb is not null and exists in GL_CODE_COMBINATIONS.
--      - default code comb is set for an employee or applicant or offer assignment.
--      - enabled flag for the default code combination is set to 'Y'.
--      - the effective start date of the assignment is between start date
--        active and end date active of the default code combination.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - default code comb is not null but does'nt exist in
--        GL_CODE_COMBINATIONS.
--      - default code comb is set for a non employee or non applicant or non
--        offer assignment.
--      - enabled flag for the default code combination is not set to 'Y'.
--      - the effective start date of the assignment is not between start
--        date active and end date active of the default code combination.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_default_code_comb_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_default_code_comb_id    in     per_all_assignments_f.default_code_comb_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date          in     date
  ,p_validation_start_date   in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |----------------------< chk_del_organization_id >------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Checks to see if manager_flag is set to 'Y' on delete whether another
--    assignment also has the manager_flag set within the same organization.
--
--  Pre-conditions:
--    A valid Organization ID
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_manager_flag
--    p_organization_id
--
--  Post Success:
--    Boolean flags set as approrpiate.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--    of the following cases are found :
--      - The organization_id is does not exists or is not date effective
--      - The business group of the organization is invalid
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_del_organization_id
  (p_assignment_id              in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date             in date
  ,p_manager_flag               in per_all_assignments_f.manager_flag%TYPE
  ,p_organization_id            in per_all_assignments_f.organization_id%TYPE
  ,p_org_now_no_manager_warning in out nocopy boolean
  );
--  --------------------------------------------------------------------------+
--  |-----------------------< chk_employment_category >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the employment category exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'EMP_CAT' with an enabled flag set to
--      'Y' and the effective start date of the assignment between start date
--      active and end date active on HR_LOOKUPS.
--    - Validates that the assignment is an employee or applicant or benefit or
--      offer assignment.
--
--  Pre-conditions:
--    A valid assignment type.
--
--  In Arguments:
--    p_assignment_id
--    p_assignment_type
--    p_employment_category
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - employment category exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'EMP_CAT' where the enabled flag is 'Y'
--        and the effective start date of the assignment is between
--        start date active and end date active on HR_LOOKUPS.
--      - the assignment is an employee or applicant or benefit or offer assignment.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - employment category does'nt exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'EMP_CAT' where the enabled flag is 'Y'
--        and the effective start date of the assignment is between
--        start date active and end date active on HR_LOOKUPS.
--      - the assignment is'nt an employee or applicant or benefit or offer assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_employment_category
 (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
 ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE
 ,p_employment_category    in     per_all_assignments_f.employment_category%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
 );
--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_frequency >-------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the frequency exists as a lookup code on HR_LOOKUPS for
--      the lookup type 'FREQUENCY' with an enabled flag set to 'Y' and the
--      effective start date of the assignment between start date active
--      and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_frequency
--    p_effective_date
--    p_object_version_number
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if :
--      - frequency exists as a lookup code in HR_LOOKUPS for the
--        lookup type 'FREQUENCY' where the enabled flag is 'Y'
--        and the effective start date of the assignment is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - frequency does'nt exist as a lookup code in HR_LOOKUPS for the
--        lookup type 'FREQUENCY' where the enabled flag is 'Y'
--        and the effective start date of the assignment is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_frequency
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_frequency             in     per_all_assignments_f.frequency%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |------------------------< chk_future_primary >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that a non-primary assignment cannot be date effectively
--    deleted if it is update to a primary assignment in the future.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_primary_flag
--    p_effective_date
--
--  Post Success:
--    If the non-primary assignment does not become primary in the future
--    then processing continues.
--
--  Post Failure:
--    If the non-primary assignment becomes primary in the future then an
--    application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_future_primary
  (p_assignment_id     in per_all_assignments_f.assignment_id%TYPE
  ,p_primary_flag      in per_all_assignments_f.primary_flag%TYPE
  ,p_datetrack_mode    in varchar2
  ,p_effective_date    in date
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------------< chk_grade_id >------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the grade exists in PER_GRADES where the effective start
--      date of the assignment is between date from and date to of the grade.
--    - Validates that the business group of the grade is the same as the
--      business group of the assignment.
--    - Validates when the grade is not set that the special ceiling step is
--      not set.
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
--    p_grade_id
--    p_vacancy_id
--    p_special_ceiling_step_id
--    p_effective_date
--    p_object_version_number
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if :
--      - the grade exists in PER_GRADES where the effective start date of
--        the assignment is between date from and date to of the grade.
--      - the business group of the grade is the same as the business group
--        of the assignment.
--      - the grade and special ceiling step are both not set.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the grade does'nt exist in PER_GRADES where the effective start
--        date of the assignment is between date from and date to of the
--        grade.
--      - the business group of the grade is different to the business group
--        of the assignment.
--      - the grade is not set but the special ceiling step is set.
--
procedure chk_grade_id
  (p_assignment_id            in     per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id        in     per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type          in     per_all_assignments_f.assignment_type%TYPE
  ,p_grade_id                 in     per_all_assignments_f.grade_id%TYPE
  ,p_vacancy_id               in     per_all_assignments_f.vacancy_id%TYPE
  ,p_special_ceiling_step_id  in     per_all_assignments_f.special_ceiling_step_id%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date      in     per_all_assignments_f.effective_end_date%TYPE
  ,p_object_version_number    in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-----------------------------< chk_job_id >------------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the job exists in PER_JOBS.
--    - Validates that the end date of the job is the same as or after the
--      validation start date of the assignment.
--    - Validates that the business group of the assignment is the same as the
--      business group of the job.
--
--  Pre-conditions:
--    Valid business group
--    Valid assignment type
--    Valid vacancy
--
--  In Arguments:
--    p_job_id
--    p_business_group_id
--    p_assignment_type
--    p_vacancy_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if:
--      - the job exists and is date effective in PER_JOBS.
--      - the job end date is the same as or after the validation start
--        date of the assignment.
--      - the business group of the job is the same as the business group
--        of the assignment.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - the job does not exist or is not date effective in PER_JOBS.
--      - the job end date is not the same as or after the validation start
--        date of the assignment.
--      - the business group of the job is different to the business group
--        of the assignment.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_job_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id       in     per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_job_id                  in     per_all_assignments_f.job_id%TYPE
  ,p_vacancy_id              in     per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date          in     date
  ,p_validation_start_date   in     date
  ,p_validation_end_date     in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |----------------------< chk_job_id_grade_id >----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Validates that the job_id and grade_id combination in per_valid_grades
--    matches the combination for the assignment.
--
--  Pre-conditions:
--    A valid job_id
--    A valid grade_id
--
--  In Arguments:
--    p_job_id
--    p_grade_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Out Arguments:
--    p_inv_job_grade_warning
--
--  Post Success:
--    Processing continues if:
--      - The <validation attribute 1> and <validation attribute 2>
--        combination in <Child Table> matches the corresponding combination
--        for the <entity> date effectively.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - A flag (p_inv_<val. attr. 1>_<val. attr. 2>_warning) is set to true
--        when the <val. attr. 1> and <val. attr. 2> combination do not match
--        with a combination in <Child Table>. This flag is set to false when
--        the combination does exist. The flag will always be false when
--        <val. attr. 1> and <val. attr. 2> are not modified in this
--        transaction.
--
procedure chk_job_id_grade_id
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_job_id                 in     per_all_assignments_f.job_id%TYPE
  ,p_grade_id               in     per_all_assignments_f.grade_id%TYPE
  ,p_effective_date         in     date
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_inv_job_grade_warning     out nocopy boolean
  );
--  --------------------------------------------------------------------------+
--  |--------------------------< chk_location_id >----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that the location_id exists in HR_LOCATIONS.
--    - Validates that when location inactive date is set that the inactive
--      date is after the validation end date for the assignment.
--
--  Pre-conditions:
--    A valid assignment_type
--    A valid vacancy_id
--
--  In Arguments:
--    p_assignment_id
--    p_location_id
--    p_assignment_type
--    p_vacancy_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    - If the location_id exists and is 'active' on hr_locations then
--      processing continues.
--    - the location inactive date is set after the validation end date of
--      the assignment.
--
--  Post Failure:
--    - If the location_id does not exist or is 'inactive' on hr_locations
--      then an application_error is raised and processing is terminated.
--    - the location inactive date is not set after the validation end date of
--      the assignment.
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_location_id
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_location_id           in per_all_assignments_f.location_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_vacancy_id            in per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date        in date
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |-------------------------< chk_manager_flag >----------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that manager flag is set to either 'A' or 'E'.
--    - Checks to see if manager flag is set to 'Y' on insert of an employee
--      assignment whether another assignment also has the manager_flag set
--      within the same organization.
--
--    - Checks to see if manager flag is changed from 'Y' to 'N' on update
--      of an employee assignment whether other 'managers' exist within the
--      same organization.
--
--  Pre-conditions:
--    A valid assignment type.
--    A valid Organization
--
--  In Arguments:
--    p_assignment_id
--    p_assignment_type
--    p_manager_flag
--    p_organization_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - manager flag is set and is either 'Y' or 'N'.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - manager flag is set and is not either 'Y' or 'N'.
--
--    Warning flags are set if,
--      - a manager already exists in the organisation on insert
--        of an assignment or if manager exists in the
--        organisation on update.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_manager_flag
  (p_assignment_id         in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type       in     per_all_assignments_f.assignment_type%TYPE
  ,p_organization_id       in     per_all_assignments_f.organization_id%TYPE
  ,p_manager_flag          in     per_all_assignments_f.manager_flag%TYPE
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_assignments_f.object_version_number%TYPE
  ,p_other_manager_warning in out nocopy boolean
  ,p_no_managers_warning   in out nocopy boolean
  );
--
--  --------------------------------------------------------------------------+
--  |--------------------< chk_frequency_normal_hours >-----------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    - Validates that frequency and normal hours are either set or not set.
--    - Validates that value for normal_hours does not exceed the maximum for
--      the frequency.
--
--  Pre-conditions:
--    A valid Frequency
--
--  In Arguments:
--    p_assignment_id
--    p_frequency
--    p_normal_hours
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - frequency and normal hours are both set or not set.
--      - The value for normal_hours does not exceed the corresponding
--        frequency.
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - frequency and normal hours are not both set or not set.
--      - The value for normal_hours exceeds the frequency.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_frequency_normal_hours
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_frequency              in     per_all_assignments_f.frequency%TYPE
  ,p_normal_hours           in     per_all_assignments_f.normal_hours%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  );
--  --------------------------------------------------------------------------+
--  |-----------------------< chk_organization_id >---------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--   - Validates that organization exists and that the effective start date of
--     the assignment is between date from and date to of the organization in
--     HR_ORGANIZATION_UNITS.
--   - Validates that business group of the organization is the same as
--     the business group of the assignment.
--   - Validates for non primary employee assignments and all applicant assignments
--     other than the first that the organization exists in PER_ORGANIZATION_UNITS.
--   - Validates that when inserting a primary assignment that the organization
--     exists in HR_ORGANIZATION_UNITS between date from and date to.
--   - Validates that when inserting or updating a non primary assignment that
--     the organization exists in PER_ORGANIZATION_UNITS between date from and
--     date to.
--
--  Pre-conditions:
--    A valid primary flag
--    A valid business group
--    A valid assignment type
--    A valid vacancy
--
--  In Arguments:
--    p_primary_flag
--    p_assignment_id
--    p_organization_id
--    p_business_group_id
--    p_assignment_type
--    p_vacancy_id
--    p_validation_start_date
--    p_validation_end_date
--    p_effective_date
--    p_manager_flag
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The organization exists in HR_ORGANIZATION_UNITS and the effective
--        start date of the assignment is between date from and date to of the
--        organization.
--      - The business group of the organization matches the business group
--        of the assignment.
--      - The organization exists in PER_ORGANIZATION_UNITS for non primary
--        employee assignments and all other applicant assignments apart
--        from the first.
--      - when inserting a primary assignment the organization exists in
--        HR_ORGANIZATION_UNITS between date from and date to.
--      - when inserting or updating a primary assignment the organization
--        exists in PER_ORGANIZATION_UNITS between date from and date to.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--    of the following cases are found :
--      - The organization does'nt exist in HR_ORGANIZATION_UNITS or the effective
--        start date of the assignment is not between date from and date to of the
--        organization.
--      - The business group of the organization does not match the business group
--        of the assignment.
--      - The organization does'nt exist in PER_ORGANIZATION_UNITS for non primary
--        employee assignments and all other applicant assignments apart
--        from the first.
--      - when inserting a primary assignment the organization does'nt exist
--        in HR_ORGANIZATION_UNITS between date from and date to.
--      - when inserting or updating a primary assignment the organization
--        does'nt exist in PER_ORGANIZATION_UNITS between date from and date to.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_organization_id
  (p_primary_flag            in  per_all_assignments_f.primary_flag%TYPE
  ,p_assignment_id           in  per_all_assignments_f.assignment_id%TYPE
  ,p_organization_id         in  per_all_assignments_f.organization_id%TYPE
  ,p_business_group_id       in  per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type         in  per_all_assignments_f.assignment_type%TYPE
  ,p_vacancy_id              in  per_all_assignments_f.vacancy_id%TYPE
  ,p_validation_start_date   in  per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date     in  per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date          in  date
  ,p_object_version_number   in  per_all_assignments_f.object_version_number%TYPE
  ,p_manager_flag               in  per_all_assignments_f.manager_flag%TYPE
  ,p_org_now_no_manager_warning in out nocopy boolean
  ,p_other_manager_warning      in out nocopy boolean
  );
--
-- ---------------------------------------------------------------------------+
-- |----------------------< chk_bargaining_unit_code >------------------------|
-- ---------------------------------------------------------------------------+
--  Description:
--     Validates that the bargaining_unit_code entered exists in fnd_common_lookups
--     on the effective date.
--
--  Pre-conditions:
--    A valid bargaining_unit_code
--
--  In Arguments:
--    p_assignment_id
--    p_bargaining_unit_code
--    p_effective_date
--    p_object_version_number
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    Processing continues if :
--      - the bargaining_unit_code is valid
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the bargaining_unit_code does not exist in fnd_common_lookups on the
--        effective date.
--
--  Access Status:
--    Internal Table Handler Use Only
--
--
procedure chk_bargaining_unit_code
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_bargaining_unit_code   in     per_all_assignments_f.bargaining_unit_code%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  );
--
-- ---------------------------------------------------------------------------+
-- |----------------------< chk_hourly_salaried_code >------------------------|
-- ---------------------------------------------------------------------------+
--  Description:
--     Validates that the hourly_salaried_code entered exists in fnd_common_lookups
--     on the effective date.
--
--  Pre-conditions:
--    A valid hourly_salaried_code
--
--  In Arguments:
--    p_assignment_id
--    p_hourly_salaried_code
--    p_effective_date
--    p_object_version_number
--    p_validation_start_date
--    p_validation_end_date
--    p_pay_basis_id
--  Out Argument:
--    p_hourly_salaried_warning
--
--  Post Success:
--    Processing continues if :
--      - the hourly_salaried_code is valid
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the hourly_salaried_code does not exist in fnd_common_lookups on the
--        effective date.
--
--  Access Status:
--    Internal Table Handler Use Only
--
--
procedure chk_hourly_salaried_code
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_hourly_salaried_code    in     per_all_assignments_f.hourly_salaried_code%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date   in     date
  ,p_validation_end_date     in     date
  ,p_pay_basis_id            in     per_all_assignments_f.pay_basis_id%TYPE
  ,p_hourly_salaried_warning in out nocopy boolean
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  );
--
--  --------------------------------------------------------------------------+
--  |---------------------< return_legislation_code >-------------------------|
--  --------------------------------------------------------------------------+
--
--  Description:
--    Return the legislation code for a specific assignment
--
--  Prerequisites:
--    The assignment identified by p_assignment_id already exists.
--
--  In Arguments:
--    p_assignment_id
--
--  Post Success:
--    If the assignment is found this function will return the assignment's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the assignment does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_assignment_id            in number
  ) return varchar2;
--
--
-- ---------------------------------------------------------------------------+
-- |-------------------------< chk_frozen_single_pos >------------------------|
-- ---------------------------------------------------------------------------+
--
--  Description:
--     Validates that the whether another assignment exists for a Single Position
--     on the effective date.
--
--  Pre-conditions:
--    A valid position_id
--
--  In Arguments:
--    p_assignment_id
--    p_position_id
--    p_effective_date
--
--  Post Success:
--    Processing continues if :
--      - the no assignment exist if the position is Single position
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment exists and the position is Single position
--        as of effective date.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_frozen_single_pos
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_position_id            in     per_all_assignments_f.position_id%TYPE
  ,p_effective_date         in     date
  ,p_assignment_type        in     varchar2 default 'E'
  );
  --
-- ---------------------------------------------------------------------------+
-- |-------------------------< chk_single_position >------------------------|
-- ---------------------------------------------------------------------------+
--
--  Description:
--     Validates that the whether another assignment exists for a Single Position
--     on the effective date.
--
--  Pre-conditions:
--    A valid position_id
--
--  In Arguments:
--    p_assignment_id
--    p_position_id
--    p_effective_date
--
--  Post Success:
--    Processing continues if :
--      - the no assignment exist if the position is Single position
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      - the assignment exists and the position is Single position
--        as of effective date.
--
--  Access Status:
--    Internal Table Handler Use Only
--
procedure chk_single_position
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_position_id            in     per_all_assignments_f.position_id%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%type default 'E'
  );
--
--
--
-- ---------------------------------------------------------------------------+
-- |----------------------< pos_assignments_exists >--------------------------|
-- ---------------------------------------------------------------------------+
--
--  Description:
--     Returns whether the assignment exists for the position passed or not as of
--       effective_date
--
--  Pre-conditions:
--    A valid position_id
--
--  In Arguments:
--    p_position_id
--    p_effective_date
--
--  Post Success:
--    Returns true is assignment exists otherwise false
--
--  Post Failure:
--    An application error is raised and processing ends if:
--      No failure
--
--  Access Status:
--    Internal Table Handler Use Only
--
function pos_assignments_exists(
        p_position_id number,
        p_effective_date date,
        p_except_assignment_id number) return boolean;
--
end per_asg_bus1;

/
