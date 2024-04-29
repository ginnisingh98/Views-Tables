--------------------------------------------------------
--  DDL for Package PAY_PYR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYR_BUS" AUTHID CURRENT_USER as
/* $Header: pypyrrhi.pkh 120.0 2005/05/29 08:11:24 appldev noship $ */
--
--  ---------------------------------------------------------------------------
--  |--------------------------------< chk_name >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate name is mandatory
--    Validate name, rate_type is unique for rate_type <> 'A'
--    Validate name, rate_type, asg_rate_type is unique for rate_type='A'
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_name
--    p_rate_type
--    p_asg_rate_type
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_name
  (p_name                  IN pay_rates.name%TYPE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_business_group_id     IN pay_rates.business_group_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE
  ,p_rate_type             IN pay_rates.rate_type%TYPE
  ,p_asg_rate_type         IN pay_rates.asg_rate_type%TYPE);
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_rate_basis >---------------------------|
--  ---------------------------------------------------------------------------
--
--
--  Desciption :
--
--    Validate rate_basis exists in hr_lookups for lookup_type RATE_BASIS
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_rate_basis
--    p_effective_date
--    p_rate_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
PROCEDURE chk_rate_basis
  (p_rate_basis            IN pay_rates.rate_basis%TYPE
  ,p_effective_date        IN DATE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE);
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_rate_uom >----------------------------|
--  ---------------------------------------------------------------------------
--
--
--  Desciption :
--
--    Validate rate_uom exists in hr_lookups for lookup_type RATE_UOM
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_rate_uom
--    p_effective_date
--    p_rate_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
PROCEDURE chk_rate_uom
  (p_rate_uom              IN pay_rates.rate_uom%TYPE
  ,p_effective_date        IN DATE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE);
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_rate_type >----------------------------|
--  ---------------------------------------------------------------------------
--
--
--  Desciption :
--
--    Validate rate_type exists in hr_lookups for lookup_type RATE_TYPE
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_rate_type
--    p_effective_date
--    p_rate_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
PROCEDURE chk_rate_type
  (p_rate_type             IN pay_rates.rate_type%TYPE
  ,p_effective_date        IN DATE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE);
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_parent_spine_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate parent_spine_id is refrenced from per_parent_spines_f.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_rate_type
--    p_rate_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_parent_spine_id
  (p_parent_spine_id       IN pay_rates.parent_spine_id%TYPE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE );
  --
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
--    The primary key identified by p_rate_id
--     already exists.
--
--  In Arguments:
--    p_rate_id
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
  (p_rate_id                              IN NUMBER
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
--    RETURN the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_rate_id
--     already exists.
--
--  In Arguments:
--    p_rate_id
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
  (p_rate_id                              IN     NUMBER
  ) RETURN VARCHAR2;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This PROCEDURE controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private PROCEDURE is called from ins PROCEDURE.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this PROCEDURE
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this PROCEDURE
--   and should ideally (unless really necessary) just be straight PROCEDURE
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE insert_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN pay_pyr_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This PROCEDURE controls the execution of all update business rules
--   validation.
--
-- Prerequisites:
--   This private PROCEDURE is called from upd PROCEDURE.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this PROCEDURE
--   unless explicity coded.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN pay_pyr_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This PROCEDURE controls the execution of all delete business rules
--   validation.
--
-- Prerequisites:
--   This private PROCEDURE is called from del PROCEDURE.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this PROCEDURE
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this PROCEDURE
--   and should ideally (unless really necessary) just be straight PROCEDURE
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_validate
  (p_rec              IN pay_pyr_shd.g_rec_type
  );
--
END pay_pyr_bus;

 

/
