--------------------------------------------------------
--  DDL for Package OTA_TCC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TCC_BUS" AUTHID CURRENT_USER as
/* $Header: ottccrhi.pkh 120.0 2005/05/29 07:36:55 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_cross_charge_id
--     already exists.
--
--  In Arguments:
--    p_cross_charge_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_cross_charge_id                      in number
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_cross_charge_id
--     already exists.
--
--  In Arguments:
--    p_cross_charge_id
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
  (p_cross_charge_id                      in     number
  ) RETURN varchar2;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_overlap_cc_def>----------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_overlap_cc_def
(p_cross_charge_id    in number
 ,p_start_date_active  in date
 ,p_end_date_active    in date
 ,p_gl_set_of_books_id in number
 ,p_from_to            in varchar2
 ,p_type               in varchar2
 ,p_business_group_id  in number
) ;

-- ----------------------------------------------------------------------------
-- |-------------------------< chk_end_date_ext>------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_end_date_ext
(p_cross_charge_id    in number
 ,p_end_date_active    in date
);

--
-- ----------------------------------------------------------------------------
-- |------------------------------<  chk_type  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_type
  (p_cross_charge_id			in number
   ,p_type	 		       	in varchar2
   ,p_effective_date			in date) ;

-- ----------------------------------------------------------------------------
-- |------------------------------<  chk_from_to  >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_from_to
  (p_cross_charge_id			in number
   ,p_from_to	 		      in varchar2
   ,p_effective_date			in date) ;
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
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_tcc_shd.g_rec_type
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
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_tcc_shd.g_rec_type
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
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
--
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in ota_tcc_shd.g_rec_type
  );
--
end ota_tcc_bus;

 

/
