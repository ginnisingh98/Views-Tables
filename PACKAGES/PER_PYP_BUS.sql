--------------------------------------------------------
--  DDL for Package PER_PYP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PYP_BUS" AUTHID CURRENT_USER as
/* $Header: pepyprhi.pkh 120.6.12010000.3 2009/06/10 12:58:47 vkodedal ship $ */
--
--
g_validate_ss_change_pay  varchar2(10) := 'N';
--
-------------------------------------------------------------------------------
-------------------------------< gen_last_change_date >------------------------
-------------------------------------------------------------------------------
--
--
--  Description
--   - Generates the last change date for a salary proposal record.
--     It sets the last_change_date column to null if it is the first record.
--     It set it to previous change date for the subsequent records.
--
--  Pre_condition:
--    None
--
--  In Arguments:
--    p_rec
--
-- Access Status:
--   Internal Table Handler Use Only.
--
procedure  gen_last_change_date
  (p_rec        in out nocopy per_pyp_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
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
--   (business_group_id, pay_proposal_id, multiple_components, change_date,
--    or assignment_id) have been altered.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
--
--
--
Procedure check_non_updateable_args(p_rec in per_pyp_shd.g_rec_type);
--
-------------------------------------------------------------------------------
-------------------------------< chk_assignment_id_change_date >---------------
-------------------------------------------------------------------------------
--
--
--
--  Description:
--   - Validates that assignment_id exists and is date effctive on
--     per_assignmnets_f.
--   - Validates that the business group of the assignment is the same as the
--     business group of the pay proposal.
--   - Validates that the assignments has a valid pay_basis associated with it.
--   - Validates that the assingment system_status is not TERM_ASSIGN as of
--     change_date.
--   - Validates that the payroll status associated to the assignment is not
--     closed as of change_date.
--   - Validates that the change_date is after the last change_date.
--   - Validates that the change_date is unique
--     Note that the check for assignment type (i.e. TERM_ASSIG) and
--     valid pay_basis as of change date is done in chk_assignment.
--     validates that there is no other unapproved proposals
--     validates that the change_date is not updated if the proposal was --  Note: The chk_assignment_id and chk_change_date is merged into this procedure
--        because of close interrelations between assignment_id and change_date.
--
--  Pre_conditions:
--    A valid business_group_id
--
--
--  In Arguments:
--    p_pay_proposal_id
--    p_assignment_id
--    p_business_group_id
--    p_change_date
--    p_payroll_warning
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignmnet_id does not exist or is not date effective
--      - The business group of the assignment is invalid
--      - The assigment has not a pay_bases associated with it.
--      - The assignment system status is TERM_ASSIGN
--      - The change_date with the same date is already exists for the assinment.
--      - The change_date is before another existing change_date for the assignment.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--

procedure chk_assignment_id_change_date
  (p_pay_proposal_id            in      per_pay_proposals.pay_proposal_id%TYPE
  ,p_business_group_id          in      per_pay_proposals.business_group_id%TYPE
  ,p_assignment_id		in 	per_pay_proposals.assignment_id%TYPE
  ,p_change_date		in	per_pay_proposals.change_date%TYPE
  ,p_payroll_warning	 out nocopy     boolean
  ,p_object_version_number	in	per_pay_proposals.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_next_sal_review_date >-------------------------|
--  ---------------------------------------------------------------------------
--
--
--
--  Description:
--   - Validates that the next_sal_review_date is after the change_date.
--   - Set a warning flag if the assignment type is TERM_ASSIGN as of
--   - the next_sal_review_date.
--
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_business_group_id
--    p_assignment_id
--    p_change_date
--    p_next_sal_review_date
--    p_object_version_number
--    p_inv_next_sal_date_warning
--
--  Post Success:
--    Process continues if :
--    The next_sal_review_date is null or
--    the next_sal_review_date is a date for which the assignment type is
--    not TERM_ASSIGN
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment_id is null.
--      - The change_date is null.
--      - A warning flag is set if the next_sal_review_date is a date for which
--        the assignment type is TERM_ASSIGN.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_next_sal_review_date
  (p_pay_proposal_id		in     per_pay_proposals.pay_proposal_id%TYPE
  ,p_business_group_id          in     per_pay_proposals.business_group_id%TYPE
  ,p_assignment_id              in     per_pay_proposals.assignment_id%TYPE
  ,p_change_date		in     per_pay_proposals.change_date%TYPE
  ,p_next_sal_review_date       in     per_pay_proposals.next_sal_review_date%TYPE
  ,p_object_version_number      in     per_pay_proposals.object_version_number%TYPE
  ,p_inv_next_sal_date_warning     out nocopy boolean
  );

--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_pay_basis_change_date >-----------------|
--  ---------------------------------------------------------------------------
--
procedure  chk_pay_basis_change_date
              (p_assignment_id  in  per_pay_proposals.assignment_id%TYPE
              ,p_change_date    in  per_pay_proposals.change_date%TYPE
) ;



--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_chg_next_sal_review_date >-----------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:
--   - Derive the next_sal_review_date if the period and frequency information
--   - is set for the salary at the assignment level.
--
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_business_group_id
--    p_assignment_id
--    p_change_date
--    p_next_sal_review_date
--    p_object_version_number
--    p_inv_next_sal_date_warning
--
--  Post Success:
--    Process continues if :
--    The next_sal_review_date is null or
--    the next_sal_review_date is a date for which the assignment type is
--    not TERM_ASSIGN
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment_id is null.
--      - The change_date is null.
--      - A warning flag is set if the next_sal_review_date is a date for which
--        the assignment type is TERM_ASSIGN.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_chg_next_sal_review_date
 (p_pay_proposal_id	  in     per_pay_proposals.pay_proposal_id%TYPE
 ,p_business_group_id     in     per_pay_proposals.business_group_id%TYPE
 ,p_assignment_id         in     per_pay_proposals.assignment_id%TYPE
 ,p_change_date	   	  in     per_pay_proposals.change_date%TYPE
 ,p_next_sal_review_date  in out nocopy per_pay_proposals.next_sal_review_date%TYPE
 ,p_object_version_number in     per_pay_proposals.object_version_number%TYPE
 ,p_inv_next_sal_date_warning out nocopy boolean
  );
--
----------------------------------------------------------------------------
-- |--------------------------< chk_proposed_salary >-----------------------
----------------------------------------------------------------------------
--
--  Description:
--   - Check that the assignment's salary basis has an associated grade rate.
--   - If so, check if the assignment has a grade
--   - If so, check if the assignment has a rate assoiated with it.
--   - If so, check if the propoosed salary comes within the min and max
--   - specified for the grade and grade rate.
--   - If it doesn't, raise a warning to this effect.
--
--   - Validates that the proposed salary cannot be updated if the overall
--     proposal is approved (i.e. approved ='Y').
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_business_group_id
--    p_assignment_id
--    p_change_date
--    p_proposed_salary_n
--    p_object_version_number
--    p_proposed_salary_warning
--	  p_multiple_components
--  Post Success:
--    Process continues if :
--    The the assignment's salary basis has no garde assoicated with it or
--    the proposed salary is within the assignment's grade_rate.
--    The proposed salary has a valid currency_code associated with it.
--
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment_id is null.
--      - The change_date is null.
--      - A warning flag is set if the proposed salary is not within min
--	  and max of salary basis' grade rate.
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_proposed_salary
(p_pay_proposal_id        in     per_pay_proposals.pay_proposal_id%TYPE
 ,p_business_group_id     in     per_pay_proposals.business_group_id%TYPE
 ,p_assignment_id         in     per_pay_proposals.assignment_id%TYPE
 ,p_change_date           in     per_pay_proposals.change_date%TYPE
 ,p_proposed_salary_n     in     per_pay_proposals.proposed_salary_n%TYPE
 ,p_object_version_number in     per_pay_proposals.object_version_number%TYPE
 ,p_proposed_salary_warning  out nocopy boolean
-- vkodedal added on 19-feb-2008 to fix multiple component upload issue
 ,p_multiple_components   in     per_pay_proposals.multiple_components%TYPE
 );
procedure is_salary_in_range_int
  (p_organization_id             in  per_all_assignments_f.organization_id%TYPE
  ,p_pay_basis_id                in  per_all_assignments_f.pay_basis_id%TYPE
  ,p_position_id                 in  per_all_assignments_f.position_id%TYPE
  ,p_grade_id                    in  per_all_assignments_f.grade_id%TYPE
  ,p_normal_hours                in  per_all_assignments_f.normal_hours%TYPE
  ,p_frequency                   in  per_all_assignments_f.frequency%TYPE
  ,p_business_group_id           in  per_pay_proposals.business_group_id%TYPE
  ,p_change_date                 in  per_pay_proposals.change_date%TYPE
  ,p_proposed_salary_n           in  per_pay_proposals.proposed_salary_n%TYPE
  ,p_prop_salary_link_warning    out nocopy boolean
  ,p_prop_salary_ele_warning     out nocopy boolean
  ,p_prop_salary_grade_warning   out nocopy boolean
  --vkodedal 03-Jun-2009 8452388
  ,p_assignment_id               in  per_all_assignments_f.assignment_id%TYPE
   );

---vkodedal 8587143 10-Jun-2009
---over load the same to make sure old core hr forms won't fail
---PERWSQHM.fmb has a reference to this procedure and assignment id will be null
---when inserting
procedure is_salary_in_range_int
  (p_organization_id             in  per_all_assignments_f.organization_id%TYPE
  ,p_pay_basis_id                in  per_all_assignments_f.pay_basis_id%TYPE
  ,p_position_id                 in  per_all_assignments_f.position_id%TYPE
  ,p_grade_id                    in  per_all_assignments_f.grade_id%TYPE
  ,p_normal_hours                in  per_all_assignments_f.normal_hours%TYPE
  ,p_frequency                   in  per_all_assignments_f.frequency%TYPE
  ,p_business_group_id           in  per_pay_proposals.business_group_id%TYPE
  ,p_change_date                 in  per_pay_proposals.change_date%TYPE
  ,p_proposed_salary_n           in  per_pay_proposals.proposed_salary_n%TYPE
  ,p_prop_salary_link_warning    out nocopy boolean
  ,p_prop_salary_ele_warning     out nocopy boolean
  ,p_prop_salary_grade_warning   out nocopy boolean
   );
--
------------------------------------------------------------------------
-- |-----------------< chk_approved >-----------------------------------
------------------------------------------------------------------------
--
--  Description:
--    Validates that the approved can only have values of 'Y' and 'N'
--    Validates that it is a mandatory column
--    Checks the value of the approved flag is 'Y' for the first emp proposal
--    automatically.
--    Checks the value for an applicants proposal is 'N'
--    Validates that the approved flag can not be set to 'Y' if the proposed
--    salary is null.
--    Validates that when the approved flag is set to  'Y' if some unapproved
--    components then raising a warning message.
--    Validates that the approved falg can not be set to 'N' if the proposal
--    is not the latest proposals.
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_business_group_id
--    p_assignment_id
--    p_change_date
--    p_proposed_salary_n
--    p_object_version_number
--    p_approved_warning
--
--  Post Success:
--    Process continues if :
--    The value of the approved is 'Y' or 'N'
--    The proposed salary is not null when approved is set to 'Y'.
--
--
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment_id is null.
--      - The change_date is null.
--      - A warning flag is set if the approved flag is set to yes while
--      - there are some outstanding unapproved components.
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_approved
  (p_pay_proposal_id        in per_pay_proposals.pay_proposal_id%TYPE
  ,p_business_group_id      in per_pay_proposals.business_group_id%TYPE
  ,p_assignment_id	    in per_pay_proposals.assignment_id%TYPE
  ,p_change_date            in per_pay_proposals.change_date%TYPE
  ,p_proposed_salary_n	    in per_pay_proposals.proposed_salary_n%TYPE
  ,p_object_version_number  in per_pay_proposals.object_version_number%TYPE
  ,p_approved		    in per_pay_proposals.approved%TYPE
  ,p_approved_warning       out nocopy boolean
  );
--
-- -----------------------------------------------------------------------
-- |---------------------< chk_forced_ranking >--------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the forced ranking.
--
-- Pre-conditions:
--
--  In Arguments:
--    p_forced_ranking
--
--  Post Success:
--    Process continues if :
--    p_forced_ranking is a positive integer
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - p_forced_ranking is less than 1
--
--
procedure chk_forced_ranking
  (p_forced_ranking        in  per_pay_proposals.forced_ranking%TYPE);
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_performance_review_id >-----------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the value entered for performance_review_id is valid.
--
--  Pre-conditions:
--    p_assignment_id is valid
--
--  In Arguments:
--    p_pay_proposal_id
--    p_assignment_id
--    p_performance_review_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The performance_review_id value is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--      - The performance_review_id value is invalid
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_performance_review_id
  (p_pay_proposal_id	   in  per_pay_proposals.pay_proposal_id%TYPE
  ,p_assignment_id	   in  per_pay_proposals.assignment_id%TYPE
  ,p_performance_review_id in  per_pay_proposals.performance_review_id%TYPE
  ,p_object_version_number in  per_pay_proposals.object_version_number%TYPE
  );
--
-------------------------------------------------------------------------------
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
-- In Parameters:
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
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
        (p_rec                               in out nocopy  per_pyp_shd.g_rec_type
        ,p_inv_next_sal_date_warning            out nocopy  boolean
        ,p_proposed_salary_warning              out nocopy  boolean
        ,p_approved_warning                     out nocopy  boolean
        ,p_payroll_warning		 out nocopy  boolean
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
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
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
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
        (p_rec                               in out nocopy  per_pyp_shd.g_rec_type
        ,p_inv_next_sal_date_warning            out nocopy  boolean
        ,p_proposed_salary_warning              out nocopy  boolean
        ,p_approved_warning                     out nocopy  boolean
        ,p_payroll_warning		 out nocopy  boolean
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
-- In Parameters:
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
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
 (p_rec                in      per_pyp_shd.g_rec_type
 ,p_salary_warning     out nocopy     boolean
 );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_pay_proposal_id              in number
  ) return varchar2;
--
end per_pyp_bus;

/
