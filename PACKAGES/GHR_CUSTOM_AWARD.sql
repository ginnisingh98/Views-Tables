--------------------------------------------------------
--  DDL for Package GHR_CUSTOM_AWARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CUSTOM_AWARD" AUTHID CURRENT_USER as
/* $Header: ghcusawd.pkh 120.0.12000000.1 2007/04/25 09:16:07 utokachi noship $ */
--
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
procedure custom_award_salary
                        (p_position_id              IN NUMBER
                        ,p_person_id                IN per_people_f.person_id%TYPE
                        ,p_prd						IN ghr_pa_requests.pay_rate_determinant%type
						,p_pay_basis                IN VARCHAR2
                        ,p_pay_plan					IN VARCHAR2
                        ,p_user_table_id			IN NUMBER
						,p_grade_or_level			IN VARCHAR2
						,p_effective_date			IN DATE
						,p_basic_pay				IN NUMBER
						,p_adj_basic_pay			IN NUMBER
						,p_duty_station_id			IN ghr_duty_stations_f.duty_station_id%TYPE
						,p_award_salary				IN OUT NOCOPY NUMBER
                        );
--
end ghr_custom_award;

 

/
