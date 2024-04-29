--------------------------------------------------------
--  DDL for Package PAY_NL_LSS_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_LSS_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pynllssf.pkh 120.1 2007/04/11 04:58:12 rlingama noship $ */


-- ----------------------------------------------------------------------------
-- |---------------------< Get_Day_of_Week >--------------------------|
-- ----------------------------------------------------------------------------
--
Function Get_Day_of_Week(p_date date)
         RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |-------------------------< prorate_amount >-------------------------------|
-- ----------------------------------------------------------------------------
--
Function Get_Wage_Days(p_start_date date
                      ,p_end_date date)
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Prorate_Amount >---------------------------|
-- ----------------------------------------------------------------------------
--
Function Get_Prorate_Amount(p_assignment_id        IN NUMBER,
                            p_business_group       IN NUMBER,
                            p_application_date     IN DATE,
                            p_period_start_date    IN DATE,
                            p_period_end_date      IN DATE,
                            p_pay_periods_per_year IN NUMBER,
                            p_amount               IN OUT NOCOPY NUMBER)
RETURN NUMBER ;

-- ----------------------------------------------------------------------------
-- |-----------------------< Get_Prev_Yr_Sal >-----------------------------|
-- ----------------------------------------------------------------------------
--

FUNCTION Get_Previous_Year_Sal (p_assignment_id        IN NUMBER,
                          p_business_group       IN NUMBER,
                          p_date_earned          IN DATE,
                          p_previous_er_column_6 IN NUMBER,
                          p_prev_year_sal        OUT NOCOPY NUMBER,
                          p_error_msg     OUT NOCOPY VARCHAR2,
                          p_opt_num_in    IN NUMBER DEFAULT 0,
                          p_opt_date_in   IN DATE DEFAULT NULL)

RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Or_Life_Savings_Basis >-------------------|
-- ----------------------------------------------------------------------------
Function Get_Or_Life_Savings_Basis
   (p_assignment_id   IN NUMBER,
    p_business_group  IN NUMBER,
    p_date_earned     IN DATE,
    p_override_basis OUT NOCOPY NUMBER,
    p_error_message  OUT NOCOPY VARCHAR)

RETURN NUMBER ;

-- ----------------------------------------------------------------------------
-- |--------------------------< Get_LCLD_Limit >-------------------|
-- ----------------------------------------------------------------------------

FUNCTION Get_LCLD_Limit ( p_date_earned IN DATE,
                          p_assignment_id IN NUMBER,
                          p_num_saved_yrs IN Number,
                          p_lcld_limit IN OUT NOCOPY NUMBER,
                          p_error_msg IN OUT NOCOPY VARCHAR2)
RETURN NUMBER;


END pay_nl_lss_functions;
--

/
