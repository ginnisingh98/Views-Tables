--------------------------------------------------------
--  DDL for Package PQP_FEDHR_USPAY_INT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_FEDHR_USPAY_INT_UTILS" AUTHID CURRENT_USER AS
/* $Header: pqpfhexr.pkh 120.0 2005/05/29 01:57:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_new_element_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns a new element name if an entry is present in
--    pqp_configuration_values table. Otherwise this function returns the
--    same element name as passed to it as input parameter.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return an element name.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION return_new_element_name
(
  p_fedhr_element_name  IN VARCHAR2,
  p_business_group_id   IN NUMBER,
  p_effective_date      IN DATE,
  p_pay_basis           IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;

--
-- ----------------------------------------------------------------------------
-- |---------------------< return_new_element_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns a new element name if an entry is present in
--    pqp_configuration_values table. Otherwise this function returns the
--    same element name as passed to it as input parameter.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return an element name.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION return_new_element_name
(
  p_assignment_id     IN VARCHAR2 ,
  p_business_group_id IN NUMBER   ,
  p_effective_date    IN DATE
) RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |---------------------< return_new_element_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns a new element name if an entry is present in
--    pqp_configuration_values table. Otherwise this function returns the
--    same element name as passed to it as input parameter.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return an element name.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION return_new_element_name
(
  p_salary_basis      IN VARCHAR2 ,
  p_business_group_id IN NUMBER   ,
  p_effective_date    IN DATE
) RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< is_script_run >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function return a TRUE if rows are present in pqp_configuration_values
--   table. Otherwise this function returns false.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return a TRUE or FALSE.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION is_script_run
(
  p_fedhr_element_name IN VARCHAR2,
  p_business_group_id  IN NUMBER
) RETURN BOOLEAN;

--
-- ----------------------------------------------------------------------------
-- |---------------------------is_ele_link_exists >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function return a TRUE if the element link exists.
--   Otherwise this function returns false.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return a TRUE or FALSE.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

FUNCTION is_ele_link_exists
(
   p_ele_name         IN VARCHAR2,
   p_legislation_code IN VARCHAR2 DEFAULT NULL,
   p_bg_id            IN NUMBER   DEFAULT NULL
) RETURN BOOLEAN;

--
-- ----------------------------------------------------------------------------
-- |---------------------< pay_basis_to_sal_basis >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function return the mapping of Pay Basis to Salary Basis.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function  returns Pay basis Mapping to Sal Basis.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

FUNCTION pay_basis_to_sal_basis
(
  p_pay_basis IN  VARCHAR2,
  p_sal_basis OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |---------------------< return_old_element_name >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function returns federal element name if an entry is present in
--    pqp_configuration_values table. Otherwise this function returns the
--    same element name as passed to it as input parameter.
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--  This function will return federal element name.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION return_old_element_name
(
  p_agency_element_name  IN VARCHAR2 ,
  p_business_group_id    IN NUMBER   ,
  p_effective_date       IN DATE
) RETURN VARCHAR2;

END pqp_fedhr_uspay_int_utils;

 

/
