--------------------------------------------------------
--  DDL for Package PAY_SE_HOLIDAY_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_HOLIDAY_PAY" AUTHID CURRENT_USER AS
/*$Header: pyseholi.pkh 120.1 2007/06/28 17:28:04 rravi noship $*/
   FUNCTION get_earning_year_workingdays (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_assignment_action_id     IN       NUMBER
   )
      RETURN NUMBER;

   FUNCTION check_entitlement (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_pay_start_date           IN       DATE
     ,p_pay_end_date             IN       DATE
     ,p_earning_start_date       OUT NOCOPY DATE
     ,p_earning_end_date         OUT NOCOPY DATE
   )
      RETURN VARCHAR2;

   FUNCTION get_paid_unpaid_days (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_assignment_action_id     IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_earning_start_date       IN       DATE
     ,p_earning_end_date         IN       DATE
     ,p_paid_holiday_days        OUT NOCOPY NUMBER
     ,p_unpaid_holiday_days      OUT NOCOPY NUMBER
     ,p_total_working_days       OUT NOCOPY NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_vacation_days (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_payroll_start_date       IN       DATE
     ,p_payroll_end_date         IN       DATE
   )
      RETURN NUMBER;

   FUNCTION get_saved_year_limit_level (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_legal_employer           OUT NOCOPY VARCHAR2
     ,p_person                   OUT NOCOPY VARCHAR2
     ,p_assignment               OUT NOCOPY VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION element_exist (
      p_assignment_id            IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_element_name             IN       VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION get_calculation_option (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_local_unit_id            IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_absence_category         IN       VARCHAR2
     ,p_return_vacation          OUT NOCOPY VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION get_saved_holiday_limit (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
   )
      RETURN NUMBER;

   FUNCTION get_end_year (p_date_earned IN DATE, p_tax_unit_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_further_period_details (
      p_payroll_id               IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_pay_saved_holiday        OUT NOCOPY VARCHAR2
     ,p_no_of_saved_days         OUT NOCOPY NUMBER
     ,p_pay_remaining_saved_days OUT NOCOPY VARCHAR2
     ,p_pay_additional_holiday   OUT NOCOPY VARCHAR2
     ,p_no_of_additional_holiday OUT NOCOPY NUMBER
     ,p_pay_remaining_addl_holiday OUT NOCOPY VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION get_remaining_saved_pay (
      p_assignment_id            IN       NUMBER
     ,p_assignment_action_id     IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_payroll_id               IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_days_to_pay              OUT NOCOPY NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_hourly_salaried_code (
      p_assignment_id_id         IN       NUMBER
     ,p_date_earned              IN       DATE
   )
      RETURN VARCHAR2;

   FUNCTION update_entitlement_ran (p_tax_unit_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_calendar_days (
      p_date_earned              IN       DATE
     ,p_tax_unit_id              IN       NUMBER
     ,p_assignment_id            IN       NUMBER
     ,p_pay_proc_period_start_date IN     DATE
     ,p_pay_proc_period_end_date IN       DATE
     ,p_earn_end_date            OUT NOCOPY DATE
   )
      RETURN NUMBER;

   FUNCTION get_assg_status (
      p_business_group_id        IN       NUMBER
     ,p_asg_id                   IN       NUMBER
     ,p_pay_proc_period_start_date IN     DATE
     ,p_pay_proc_period_end_date IN       DATE
     ,p_termination_date         OUT NOCOPY DATE
   )
      RETURN VARCHAR2;

   FUNCTION compensation_entitlement (
      p_date_earned              IN       DATE
     ,p_tax_unit_id              IN       NUMBER
     ,p_assignment_id            IN       NUMBER
     ,p_assignment_action_id     IN       NUMBER
     ,p_pay_proc_period_start_date IN     DATE
     ,p_pay_proc_period_end_date IN       DATE
     ,p_paid_holiday_days        OUT NOCOPY NUMBER
     ,p_termination_date         IN       DATE
     ,p_earn_end_date            IN       DATE
   )
      RETURN NUMBER;

   FUNCTION get_sickness_days (
      p_assignment_action_id     IN       NUMBER
     ,p_assignment_id            IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_date_earned              IN       DATE
   )
      RETURN NUMBER;

   FUNCTION check_advance_holiday_limit (
      p_assignment_id            IN       NUMBER
     ,p_date_earned              IN       DATE
   )
      RETURN VARCHAR2;

   FUNCTION get_cy_start_date (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_payroll_start_date       IN       DATE
     ,p_payroll_end_date         IN       DATE
     ,p_cy_start_date            OUT NOCOPY DATE
     ,p_cy_end_date              OUT NOCOPY DATE
   )
      RETURN VARCHAR2;

   FUNCTION get_cy_paid_unpaid_days (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_assignment_action_id     IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_cy_start_date            IN       DATE
     ,p_cy_end_date              IN       DATE
     ,p_paid_holiday_days        OUT NOCOPY NUMBER
     ,p_unpaid_holiday_days      OUT NOCOPY NUMBER
   --p_total_working_days OUT nocopy NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_paid_days_limit (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_tax_unit_id              IN       NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_earning_year (p_date_earned IN DATE, p_tax_unit_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_employee_category_type (
      p_asg_id                   IN       NUMBER
     ,p_business_group_id        IN       NUMBER
     ,p_pay_proc_period_start_date IN     DATE
     ,p_tax_unit_id              IN       NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_coincident_holiday_year (
      p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_min_assignment_start (p_assignment_id IN NUMBER)
      RETURN DATE;

   FUNCTION part_time_employee (
      p_assignment_id            IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_full_time                OUT NOCOPY NUMBER
     ,p_days_week                OUT NOCOPY NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_holiday_pay_agreement_row (
      p_assignment_id            IN       NUMBER
     ,p_date_earned              IN       DATE
     ,p_business_group_id        IN       NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_avg_working_percentage (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_employee_age_experience (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
   )
      RETURN VARCHAR2;

   FUNCTION get_sdays_wrking_percentage (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_business_group_id        IN       NUMBER
     ,p_tax_unit_id              IN       NUMBER
     ,p_first_year               IN       NUMBER
     ,p_second_year              IN       NUMBER
     ,p_third_year               IN       NUMBER
     ,p_fourth_year              IN       NUMBER
     ,p_fifth_year               IN       NUMBER
     ,p_sixth_year               IN       NUMBER
     ,p_seventh_year             IN       NUMBER
     ,p_all_years                IN       NUMBER
     ,p_saved_days_taken         IN       NUMBER
     ,p_saved_days_availed       IN       NUMBER
   )
      RETURN NUMBER;
 PROCEDURE GET_WEEKEND_PUBLIC_HOLIDAYS(p_assignment_id in number
	,P_START_DATE in date
	,P_END_DATE in date
	,p_start_time in varchar2
	,p_end_time in varchar2
	,p_calc_type in varchar2
	,p_Total_holidays OUT NOCOPY NUMBER
	);
  FUNCTION get_avg_earning_year_hours (
      p_assignment_id       IN   NUMBER,
      p_effective_date      IN   DATE,
      p_business_group_id   IN   NUMBER,
      p_tax_unit_id         IN   NUMBER,
      p_total_absence       IN   Number
   )
      RETURN NUMBER;
  FUNCTION get_First_three_payroll_check (
      p_assignment_id        IN              NUMBER,
      p_effective_date       IN              DATE,
      p_business_group_id    IN              NUMBER,
      p_tax_unit_id          IN              NUMBER,
      p_pay_start_date       IN              DATE,
      p_pay_end_date         IN              DATE
   )
      RETURN VARCHAR2;
END pay_se_holiday_pay;

/
