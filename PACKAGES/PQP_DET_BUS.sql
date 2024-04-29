--------------------------------------------------------
--  DDL for Package PQP_DET_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_DET_BUS" AUTHID CURRENT_USER as
/* $Header: pqdetrhi.pkh 120.0.12010000.1 2008/07/28 11:08:28 appldev ship $ */

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}

-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.

-- Prerequisites:
--   This private procedure is called from ins procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.

-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.

-- Access Status:
--   Internal Row Handler Use Only.

-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqp_det_shd.g_rec_type
                         ,p_effective_date in date);

-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}

-- Description:
--   This procedure controls the execution of all update business rules
--   validation.

-- Prerequisites:
--   This private procedure is called from upd procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.

-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.

-- Access Status:
--   Internal Row Handler Use Only.

-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqp_det_shd.g_rec_type
                         ,p_effective_date in date);

-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}

-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.

-- Prerequisites:
--   This private procedure is called from del procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.

-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.

-- Access Status:
--   Internal Row Handler Use Only.

-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqp_det_shd.g_rec_type
                         ,p_effective_date in date);

end pqp_det_bus;

/
