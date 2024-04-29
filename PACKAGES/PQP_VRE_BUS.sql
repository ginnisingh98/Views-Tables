--------------------------------------------------------
--  DDL for Package PQP_VRE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VRE_BUS" AUTHID CURRENT_USER as
/* $Header: pqvrerhi.pkh 120.0.12010000.1 2008/07/28 11:26:09 appldev ship $ */
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
--    The primary key identified by p_vehicle_repository_id
--     already exists.
--
--  In Arguments:
--    p_vehicle_repository_id
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
  (p_vehicle_repository_id                IN NUMBER
  ,p_associated_column1                   IN VARCHAR2 DEFAULT null
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
--    The primary key identified by p_vehicle_repository_id
--     already exists.
--
--  In Arguments:
--    p_vehicle_repository_id
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
  (p_vehicle_repository_id                IN     NUMBER
  ) RETURN varchar2;
--
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< pqp_get_config_value >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--   Returns the configuration value for businessGroupId/legistionId
--
--  Prerequisites:
--    The primary key identified by p_vehicle_repository_id
--     already exists.
--
--  In Arguments:
--  p_business_group_id ,p_legislation_code,p_seg_col_name
--  p_table_name,p_information_category
--
--
--  Post Success:
--    The Configuration value will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
  FUNCTION pqp_get_config_value (
                  p_business_group_id    IN  NUMBER,
                  p_legislation_code     IN  VARCHAR2,
                  p_seg_col_name         IN  VARCHAR2,
                  p_table_name           IN  VARCHAR2,
                  p_information_category IN VARCHAR2 )
         RETURN VARCHAR2;
--
--
--

-- ---------------------------------------------------------------------------
-- |---------------------< get_uom_fiscal_ratings >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--   Returns the fiscal ratings for businessGroupId
--
--  Prerequisites:
--    The primary key identified by p_business_group_id
--     already exists.
--
--  In Arguments:
--   p_business_group_id
--
--
--  Post Success:
--    The fiscal rating value will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
  PROCEDURE get_uom_fiscal_ratings
       (p_business_group_id  IN   NUMBER
       ,p_meaning           OUT   NOCOPY VARCHAR2);
--
-- ---------------------------------------------------------------------------
-- |---------------------< get_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a business groupId
--
--  In Arguments:
--    business_group_id
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
FUNCTION get_legislation_code
           (p_business_group_id IN NUMBER) RETURN VARCHAR2;
--
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
  (p_rec                   IN pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
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
  (p_rec                     IN pqp_vre_shd.g_rec_type
  ,p_effective_date          IN DATE
  ,p_datetrack_mode          IN VARCHAR2
  ,p_validation_start_date   IN DATE
  ,p_validation_end_date     IN DATE
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_validate
  (p_rec                   IN pqp_vre_shd.g_rec_type
  ,p_effective_date        IN DATE
  ,p_datetrack_mode        IN VARCHAR2
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE
  );
--
end pqp_vre_bus;

/
