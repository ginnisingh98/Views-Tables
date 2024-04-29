--------------------------------------------------------
--  DDL for Package PER_PPC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PPC_BUS" AUTHID CURRENT_USER as
/* $Header: peppcrhi.pkh 120.1 2006/03/14 18:16:34 scnair noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code  varchar2(150) default null;
g_component_id      number        default null;
--
--
----------------------------------------------------------------------
-- |---------------< chk_approved >-----------------------------------
----------------------------------------------------------------------
--
--  Description:
--    - Validates that it cannot be set to 'Y' if the change amount
--      or change_percentage is null.
--
--  Pre-condition
--    A valid pay_proposal_id
--    The Change_amount and the Change_percentage have been validated
--    or derived as appropriate.
--
--  In arguments:
--    p_component_id
--    p_change_amount_n
--    p_change_percentage
--    p_component_reason
--    p_object_version_number
--
--  Post_success
--    Process continues if:
--    The change_amount_n and change_percentage are not null.
--
--  Post-Failure:
--    An application error is raised and processing is terminated
--    if any of the following cases are found :
--    - The change_amount_n or change_percentage are null.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
--
procedure chk_approved
  (p_component_id
  in 	per_pay_proposal_components.component_id%TYPE
  ,p_approved
  in  per_pay_proposal_components.approved%TYPE
  ,p_component_reason
  in  per_pay_proposal_components.component_reason%TYPE
  ,p_change_amount_n
  in  per_pay_proposal_components.change_amount_n%TYPE
  ,p_change_percentage
  in	per_pay_proposal_components.change_percentage%TYPE
  ,p_object_version_number
  in  per_pay_proposal_components.object_version_number%TYPE
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
Procedure insert_validate(p_rec in out nocopy per_ppc_shd.g_rec_type
                         ,p_validation_strength in varchar2 default 'STRONG');
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
Procedure update_validate(p_rec in out nocopy per_ppc_shd.g_rec_type
                         ,p_validation_strength in varchar2 default 'STRONG');
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--   p_validation_strength can be set to determine if the components of an
--   approved proposal can be deleted. This is so that a whole approved
--   proposal can be deleted.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--   p_validation_strength
--     Determines how strong the validation should be. Should always be set
--     to STRONG unless called from the delete proposal api which is trying
--     to delete a whole proposal and it's components. In this case it should
--     be set to WEAK and the condition that you cannot delete the components
--     of an approved proposal will be ignored.
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
Procedure delete_validate(p_rec in per_ppc_shd.g_rec_type
                         ,p_validation_strength in varchar2 default 'STRONG');
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_component_id              in number
  ) return varchar2;
--
end per_ppc_bus;

 

/
