--------------------------------------------------------
--  DDL for Package Body GHR_CUSTOM_AWARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CUSTOM_AWARD" as
/* $Header: ghcusawd.pkb 120.0.12000000.1 2007/04/25 09:16:24 utokachi noship $ */
-- -----------------------------------------------------------------------------
-- |-----------------------------< custom_award_salary >-----------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure is provided for the customer to update to allow them to
--    add there own routines to determine at the Award Salary. It is called
--    from the award_amount_calc procedure.
--
--
--  In Arguments:
--    p_position_id     -- Position ID associated with the current assignment
--    p_person_id       -- Person ID as on the effective Date
--    p_prd				-- Pay Rate Determinant of the current assignment
--    p_pay_basis       -- Pay Basis of the current assignment
--    p_pay_plan		-- Pay Plan associated with the current assignment
--    p_user_table_id	-- Pay Table ID associated with the current assignment
--    p_grade_or_level	-- Grade or Level associated with the current assignment
--    p_effective_date	-- Effective date of the Award Action
--    p_basic_pay		-- Basic Pay as on the Award RPA effective date
--    p_adj_basic_pay	-- Adjusted Basic Pay as on the Award RPA effective date
--    p_duty_station_id	-- Duty station ID associated with the position

--
--  OUT Arguments:
--    p_award_salary
--
--  Post Success:
--    Processing goes back to the award_amount_calc process.
--    If the customer calculated award salary, they have to set
--    the p_award_salary with the calculated value.
--
--  Post Failure:
--    SQL failure:
--      Processing goes back to the award_amount_calc process:
--      The initial value of the p_award_salary will be returned
--      as the result.
--  Developer Implementation Notes:
--    Customer defined.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'ghr_custom_award.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< custom_award_salary >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure custom_award_salary
                        (p_position_id              IN NUMBER
                        ,p_person_id                IN per_people_f.person_id%TYPE
                        ,p_prd						IN ghr_pa_requests.pay_rate_determinant%TYPE
						,p_pay_basis                IN VARCHAR2
                        ,p_pay_plan					IN VARCHAR2
                        ,p_user_table_id			IN NUMBER
						,p_grade_or_level			IN VARCHAR2
						,p_effective_date			IN DATE
						,p_basic_pay				IN NUMBER
						,p_adj_basic_pay			IN NUMBER
						,p_duty_station_id			IN ghr_duty_stations_f.duty_station_id%TYPE
						,p_award_salary				IN OUT NOCOPY NUMBER
  ) IS
--
  l_proc       varchar2(72) := g_package||'custom_award_salary';
  l_award_salary   NUMBER;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_award_salary := p_award_salary;
  --
  /*************** Add custom code here **************/

    --  /**************** EXAMPLE *********************************
  -- below is an example of what you may code if you knew how
  -- to calculate for example a pay plan of 'GL' . Hopefully it would be a bit more
  -- complicated than this otherwise we could have done it!!!!
  -- NOTE: You need to set ALL out parameters
  -- l_award_salary := p_award_salary;
  --IF p_pay_plan = 'GL' THEN
  -- l_award_salary  = l_award_salary + (l_award_salary * 0.1)  --Giving 10% increase
  --END IF;
  --  ***********************************************************/
  --
  --
  p_award_salary := NVL(l_award_salary,p_award_salary);
  hr_utility.set_location('Leaving:'||l_proc, 10);
end custom_award_salary;
--
end ghr_custom_award;

/
