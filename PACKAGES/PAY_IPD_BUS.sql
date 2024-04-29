--------------------------------------------------------
--  DDL for Package PAY_IPD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IPD_BUS" AUTHID CURRENT_USER as
/* $Header: pyipdrhi.pkh 120.0 2005/05/29 05:59:14 appldev noship $ */
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
--    The primary key identified by p_paye_details_id
--     already exists.
--
--  In Arguments:
--    p_paye_details_id
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
  (p_paye_details_id                      in number
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
--    The primary key identified by p_paye_details_id
--     already exists.
--
--  In Arguments:
--    p_paye_details_id
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
  (p_paye_details_id                      in     number
  ) RETURN varchar2;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_assignment_id >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if assignment already exists and valid as of the effectuve date
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the assignment does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_assignment_id
  (p_effective_date IN DATE
     , p_assignment_id IN NUMBER
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_info_source >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if info_source already exists in lookup_type IE_PAYE_INFO_SOURCE
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_info_source
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the info_source does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_info_source
  (p_effective_date IN DATE
     , p_info_source IN VARCHAR2
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< get_comm_period_no >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Derive value of comm_period_no
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignemnt_id
--
--
--  Post Success:
--    returns value of commencement period number.
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION get_comm_period_no
   ( p_effective_date IN DATE
     , p_assignment_id IN NUMBER ) RETURN NUMBER;
--
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_comm_period_no >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if comm_period_no is valid
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_comm_period_no
--    p_assignment_id
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the comm_period_no is not valid
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_comm_period_no
  (p_effective_date IN DATE
     , p_comm_period_no IN NUMBER
     , p_assignment_id IN NUMBER
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_tax_basis >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if tax_basis already exists in lookup_type IE_PAYE_TAX_BASIS
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_tax_basis
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the info_source does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_tax_basis
  (p_effective_date IN DATE
     , p_tax_basis IN VARCHAR2
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_tax_assess_basis >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if tax_assess_basis already exists in lookup_type IE_PAYE_ASSESS_BASIS
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_tax_assess_basis
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the info_source does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_tax_assess_basis
  (p_effective_date IN DATE
     , p_tax_assess_basis IN VARCHAR2
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_cert_start_end_dates >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if certificate start dates is before or equal to certificate end date
--
--  Prerequisites:
--
--  In Arguments:
--    p_certificate_start_date
--    p_certificate_end_date
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the certificate_start_date is after
--    certificate_end_Date
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_cert_start_end_dates
  (p_certificate_start_date IN DATE
     , p_certificate_end_date IN DATE
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_duplicate_record >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if PAYE record already exists for the assignment
--
--  Prerequisites:
--
--  In Arguments:
--    p_assignment_id
--
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if PAYE record already exists for the assignment
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_duplicate_record
  ( p_assignment_id IN NUMBER
  , p_validation_start_date IN DATE
  , p_validation_end_date IN DATE --Bug 4154171 Added new parameter p_effective_date
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_tax_basis_amounts >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if amounts are valid for the given tax basis, for 'Emergency'
--    tax basis weekly and monthly tax credits ans std rate cut-off amounts must
--    be null and for other values of tax basis weekly or monthly amounts
--    (depending on payroll frequency) must be not null.
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--    p_tax_basis
--    p_weekly_tax_credit
--    p_weekly_std_rate_cut_off
--    p_monthly_tax_credit
--    p_monthly_std_rate_cut_off
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if amonts are not valid for the given tax basis and payroll
--    frequency
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_tax_basis_amounts
  (p_effective_date IN DATE
    , p_assignment_id IN NUMBER
     , p_tax_basis IN VARCHAR2
     , p_weekly_tax_credit IN NUMBER
     , p_weekly_std_rate_cut_off IN NUMBER
     , p_monthly_tax_credit IN NUMBER
     , p_monthly_std_rate_cut_off IN NUMBER
  );
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
Procedure insert_validate
  (p_rec                   in pay_ipd_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
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
Procedure update_validate
  (p_rec                     in pay_ipd_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
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
Procedure delete_validate
  (p_rec                   in pay_ipd_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
end pay_ipd_bus;

 

/
