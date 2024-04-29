--------------------------------------------------------
--  DDL for Package HR_LOT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOT_BUS" AUTHID CURRENT_USER as
/* $Header: hrlotrhi.pkh 120.0 2005/05/31 01:22:20 appldev noship $ */
--
-- Added proc for Bug 957239
-- ----------------------------------------------------------------------------
-- |---------------------------< set_translation_globals >--------------------|
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                                  p_legislation_code IN VARCHAR2);

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_location_code >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the location code is unique within
--   its language and business_group (if set).  If the business_group_id is
--   null, the code must be unique within the language.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--
--     p_language_id
--     p_location_code
--     p_language
--     p_business_group_id
--     p_called_from_form    - affects which error message is used on error.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal Row handler use only.
--
procedure chk_location_code
  (
    p_location_id                       in  number,
    p_location_code                     in  varchar2,
    p_language                          in  varchar2,
    p_business_group_id                 in  number,
    p_called_from_form                  in  boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_location_code overload >----------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the location code is unique within
--   its language and business_group (if set).  If the business_group_id is
--   null, the code must be unique within the language.
--
--  This version is overloaded as this versions is used instead of
--  hr_location_api.validate_translation call in perwsloc.fmb
-- Pre Conditions
--   None.
--
-- In Parameters
--
--     language_id
--     location_code
--     language
--     description ( dummy param ,used to allow the form to compile )
--
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the client
--
-- Access Status
--   Used for call from Client code
--
procedure chk_location_code(location_id IN NUMBER,
                               language IN VARCHAR2,
                               location_code IN VARCHAR2,
                               description IN VARCHAR2);
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
Procedure insert_validate(p_rec                    in hr_lot_shd.g_rec_type,
			  p_business_group_id      in number);
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
Procedure update_validate( p_rec                   in hr_lot_shd.g_rec_type,
			   p_business_group_id     in number);
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
Procedure delete_validate(p_rec in hr_lot_shd.g_rec_type);
--
end hr_lot_bus;

 

/
