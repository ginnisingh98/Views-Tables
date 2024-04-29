--------------------------------------------------------
--  DDL for Package HR_LOC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOC_BUS" AUTHID CURRENT_USER AS
/* $Header: hrlocrhi.pkh 120.1 2005/07/18 06:20:20 bshukla noship $ */
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific location
--
--  Prerequisites:
--    The location identified  already exists.
--
--  In Arguments:
--    p_location_id
--
--  Post Success:
--    If the location is found this function will return its business
--    group legislation code - unless its business_group_id is set to
--    null (indicating a location with global scope) in which case
--    the function returns null also.
--
--    This is NOT the standard return_legislation_code() - has been
--    modified to deal with null business_group_ids.
--
--  Post Failure:
--    An error is raised if the location does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
FUNCTION return_legislation_code
  (p_location_id              IN hr_locations.location_id%TYPE
  ) RETURN VARCHAR2;
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
PROCEDURE insert_validate
   ( p_rec               IN OUT NOCOPY hr_loc_shd.g_rec_type,
     p_effective_date    IN DATE,
     p_operating_unit_id IN NUMBER );
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
PROCEDURE update_validate
   ( p_rec IN OUT NOCOPY hr_loc_shd.g_rec_type,
     p_effective_date IN DATE,
     p_operating_unit_id IN NUMBER);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks to see if record can be deleted from
--   HR_LOCATIONS row.
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
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments
-- ----------------------------------------------------------------------------
PROCEDURE delete_validate
  ( p_rec         IN     hr_loc_shd.g_rec_type);
--
END hr_loc_bus;

 

/
