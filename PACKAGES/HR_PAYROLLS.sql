--------------------------------------------------------
--  DDL for Package HR_PAYROLLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAYROLLS" AUTHID CURRENT_USER as
/* $Header: pypyroll.pkh 120.0.12010000.1 2008/07/27 23:31:39 appldev ship $ */
--
--
-- The record fields are self-explanatory, with the exception of:
--
--     base_period_type     - the base period type of the processing period
--                            type (weekly, semi-monthly or monthly).
--     multiple             - multiple of base period type in period type.
--                            Has special meaning for Semi-Monthly, adding
--                            periods if +ve, else subtracting.
--     first_start_date     - start date of the very first period either
--                            generated or to be generated for the payroll.
--     first_end_date       - end date of the very first period either
--                            generated or to be generated for the payroll.
--     first_gen_start_date - start date of the first period to be generated
--                            in this invocation (= first_start_date if no
--                            periods currently exist).
--     first_gen_end_date   - end date of the first period to be generated
--                            in this invocation (= first_end_date if no
--                            periods currently exist).
--
type payroll_rec_type is record
(
  payroll_id                 pay_all_payrolls_f.payroll_id%type,
  legislation_code           fnd_territories_vl.territory_code%type,
  no_years                   pay_all_payrolls_f.number_of_years%type,
  period_type                pay_all_payrolls_f.period_type%type,
  pay_date_offset            pay_all_payrolls_f.pay_date_offset%type,
  cut_off_date_offset        pay_all_payrolls_f.cut_off_date_offset%type,
  pay_advice_date_offset     pay_all_payrolls_f.pay_advice_date_offset%type,
  direct_deposit_date_offset pay_all_payrolls_f.direct_deposit_date_offset%type,
  base_period_type           varchar2(1),
  multiple                   number,
  first_start_date           date,
  first_end_date             date,
  first_gen_start_date       date,
  first_gen_end_date         date,
  period_reset_years         pay_all_payrolls_f.period_reset_years%type,
  payslip_view_date_offset   pay_all_payrolls_f.payslip_view_date_offset%type
);
--
-- The entry point to the package, both for initial creation of
-- periods and creaion of further periods.
--
procedure create_payroll_proc_periods (p_payroll_id in number,
                                       p_last_update_date   in date,
                                       p_last_updated_by    in number,
                                       p_last_update_login  in number,
                                       p_created_by         in number,
                                       p_creation_date      in date);
--
--This is a overloaded version of create_payroll_proc_periods with
--additional parameter p_effective_date and  using  PAY_ALL_PAYROLLS_F
--table instead of PAY_ALL_PAYROLLS view.
--
procedure create_payroll_proc_periods (p_payroll_id in number,
                                       p_last_update_date   in date,
                                       p_last_updated_by    in number,
                                       p_last_update_login  in number,
                                       p_created_by         in number,
                                       p_creation_date      in date,
                                       p_effective_date     in date );
--
-- This procedure does not currently use PER_TIME_PERIOD_RULES, since that
-- table is subject to some change.
--
procedure get_period_details (p_proc_period_type in varchar2,
                              p_base_period_type out nocopy varchar2,
                              p_multiple out nocopy number);
--
-- This function displays the correct format of period_name
-- depending on ACTION_TYPE.
--
FUNCTION display_period_name (p_payroll_action_id in number)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(display_period_name,WNDS,WNPS);
--
-- Added by Ed Jones 12/3/2001
PROCEDURE enable_display_fetch(p_mode IN BOOLEAN);
FUNCTION display_period_name_forced(p_payroll_action_id IN NUMBER)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(display_period_name_forced,WNDS,WNPS);
--
procedure derive_payroll_dates(p_pay_det in out nocopy payroll_rec_type);
--
procedure get_warnings ( p_weeks_reset_warn       IN OUT nocopy boolean
			,p_end_date_changed_warn  IN OUT nocopy boolean
			,p_no_of_weeks_reset      IN OUT nocopy number
			,p_reset_period_name      IN OUT nocopy per_time_periods.period_name%type
			,p_new_end_date	          IN OUT nocopy per_time_periods.end_date%type );
--
procedure clear_warnings ;
--
procedure set_globals ( p_constant_end_date in boolean ) ;
--
function prev_semi_month(p_semi_month_date in date, p_fpe_date in date)
                         return date;
--
function next_semi_month(p_semi_month_date in date, p_fpe_date in date)
                         return date;
--
end hr_payrolls;

/
