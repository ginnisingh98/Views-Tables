--------------------------------------------------------
--  DDL for Package PER_CAG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAG_BUS" AUTHID CURRENT_USER as
/* $Header: pecagrhi.pkh 120.0 2005/05/31 06:22:21 appldev noship $ */
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_cag_shd.g_rec_type);
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_cag_shd.g_rec_type);
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_cag_shd.g_rec_type);

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the validity of the start_date and end_date according to the business rule.
--   The start_date should be lower than the end_date.
--   v
--
-- Prerequisites:
--   This private procedure is called from the Collective_Agreement Form and from the Collective_Agreement API.
--
-- In Parameters:
--   Collective_Agreement start_date and end_date.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will by handled by this procedure.
--
--
-- Developer Implementation Notes:
--
--
--
--
-- Access Status:
--   Internal and External Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_date_validate
   (p_start_date in date,
    p_end_date   in date
   );

-- ----------------------------------------------------------------------------
-- |---------------------------< status_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the validity of the Category Status according to the business rule.
--   The status should be existing in CAGR_STATUS hr_lookups.
--
-- Prerequisites:
--   This private procedure is called from the Collective_Agreement Form and from the Collective_Agreement API.
--
-- In Parameters:
--   Collective_Agreement status.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will by handled by this procedure.
--
--
-- Developer Implementation Notes:
--
--
--
--
-- Access Status:
--   Internal and External Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_status_validate
   (p_status in  varchar2
   );


Procedure chk_employer_organization_id
   (p_collective_agreement_id   in number,
    p_employer_organization_id  in number,
    p_business_group_id         in number);


Procedure chk_bargaining_organization_id
   (p_collective_agreement_id    in number,
    p_bargaining_organization_id in number,
    p_business_group_id          in number);

--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific person
--
--  Prerequisites:
--    The contract identified by p_contract_id already exists.
--
--  In Arguments:
--    p_contract_id
--
--  Post Success:
--    If the contract is found this function will return the contract's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the contract does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_collective_agreement_id              in number
  ) return varchar2;
--
--
end per_cag_bus;

 

/
