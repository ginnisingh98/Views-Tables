--------------------------------------------------------
--  DDL for Package OTA_TFH_API_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFH_API_BUS" AUTHID CURRENT_USER as
/* $Header: ottfh01t.pkh 120.0 2005/05/29 07:40:27 appldev noship $ */
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate( p_rec              in out nocopy ota_tfh_api_shd.g_rec_type
                         , p_transaction_type in varchar2);
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate( p_rec              in out nocopy ota_tfh_api_shd.g_rec_type
                         , p_transaction_type in varchar2);
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tfh_api_shd.g_rec_type);
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
--    The primary key identified by p_finance_header_id
--     already exists.
--
--  In Arguments:
--    p_finance_header_id
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
  (p_finance_header_id				in number
  ,p_associated_column1                   in varchar2 default null
  );
--

--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This function will be used by the user hooks. This will be  used
--   of by the user hooks of ota_finance_headers business process.
--
-- Pre Conditions:
--   This function will be called by the user hook packages.
--
-- In Arguments:
--   p_finance_header_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Errors out
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--------------------------------------------------------------------------------
--

Function return_legislation_code
         (  p_finance_header_id     in number
          ) return varchar2;



end ota_tfh_api_bus;

 

/
