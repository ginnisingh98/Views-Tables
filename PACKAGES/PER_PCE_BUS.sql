--------------------------------------------------------
--  DDL for Package PER_PCE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PCE_BUS" AUTHID CURRENT_USER as
/* $Header: pepcerhi.pkh 120.0 2005/05/31 12:56:18 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id IN CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_cagr_entitlement_id
--     already exists.
--
--  In Arguments:
--    p_cagr_entitlement_id
--
--
--  Post Success:
--    The security_group_id will be set IN CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE set_security_group_id
  (p_cagr_entitlement_id     IN NUMBER
  ,p_collective_agreement_id IN per_cagr_entitlements.collective_agreement_ID%TYPE
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    RETURN the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_cagr_entitlement_id
--     already exists.
--
--  In Arguments:
--    p_cagr_entitlement_id
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
  (p_cagr_entitlement_id     IN NUMBER
  ,p_collective_agreement_id IN per_cagr_entitlements.collective_agreement_ID%TYPE
  )
  RETURN VARCHAR2 ;
--
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
PROCEDURE insert_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN per_pce_shd.g_rec_type
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
PROCEDURE update_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN per_pce_shd.g_rec_type
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
PROCEDURE delete_validate
  (p_rec              IN per_pce_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_start_date >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the start date
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
--   If the validation fails a error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_start_date
  (p_cagr_entitlement_id     IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_start_date              IN per_cagr_entitlements.start_date%TYPE
  ,p_end_date                IN per_cagr_entitlements.end_date%TYPE
  ,p_collective_Agreement_id IN per_cagr_entitlements.collective_agreement_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_end_date >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the end date
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
--   If the validation fails a error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_end_date
  (p_cagr_entitlement_id     IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_start_date              IN per_cagr_entitlements.start_date%TYPE
  ,p_end_date                IN per_cagr_entitlements.end_date%TYPE
  ,p_effective_date          IN DATE
  );
END per_pce_bus;

 

/
