--------------------------------------------------------
--  DDL for Package PER_PMP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PMP_BUS" AUTHID CURRENT_USER as
/* $Header: pepmprhi.pkh 120.2.12010000.3 2010/01/27 15:49:21 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< return_status_code >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Returns the plan's status.
--
-- Prerequisites:
--   The plan must already exist and p_plan_id must have a value.
--
-- In Arguments:
--   p_plan_id
--
-- Post Success:
--   The plan's status is returned as a varchar2.
--
-- Post Failure:
--   Null is returned.
--
-- Access Status:
--   Internal Oracle Use Only.
--
-- ----------------------------------------------------------------------------
function return_status_code
  (p_plan_id in number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< return_ovn >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Returns the plan's object version number.
--
-- Prerequisites:
--   The plan must already exist and p_plan_id must have a value.
--
-- In Arguments:
--   p_plan_id
--
-- Post Success:
--   The plan's OVN is returned as a number.
--
-- Post Failure:
--   Null is returned.
--
-- Access Status:
--   Internal Oracle Use Only.
--
-- ----------------------------------------------------------------------------
function return_ovn
  (p_plan_id in number) return number;
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
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pmp_shd.g_rec_type
  ,p_duplicate_name_warning       out nocopy boolean
  ,p_no_life_events_warning       out nocopy boolean
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
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pmp_shd.g_rec_type
  ,p_duplicate_name_warning       out nocopy boolean
  ,p_no_life_events_warning       out nocopy boolean
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
--   For delete, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in per_pmp_shd.g_rec_type
  );
--
end per_pmp_bus;

/
