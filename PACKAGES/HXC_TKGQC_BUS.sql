--------------------------------------------------------
--  DDL for Package HXC_TKGQC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TKGQC_BUS" AUTHID CURRENT_USER as
/* $Header: hxctkgqcrhi.pkh 120.0 2005/05/29 06:15:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_tkgqc_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hxc_tkgqc_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in hxc_tkgqc_shd.g_rec_type
  );
--
end hxc_tkgqc_bus;

 

/
