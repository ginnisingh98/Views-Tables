--------------------------------------------------------
--  DDL for Package PAY_ZA_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_CALENDARS_PKG" AUTHID CURRENT_USER as
/* $Header: pyzapcal.pkh 120.2 2005/06/28 00:08:40 kapalani noship $ */
-- +======================================================================+
-- |       Copyright (c) 1998 Oracle Corporation South Africa Ltd         |
-- |                Cape Town, Western Cape, South Africa                 |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pyzapcal.pkh
-- Description          : This sql script seeds the za_pay_calendars
--                        package for the ZA localisation. This package
--                        creates the payroll calendars needed for ZA.
--
-- Change List:
-- ------------
--
-- Name           Date        Version Bug     Text
-- -------------- ----------  ------- ------- ------------------------------
-- F. Loubser     4-SEP-98    110.0           Initial Version
-- A.Mills        20-APR-99   110.1           Changed package name and
--                                            main interface procedure
--                                            (create_calendar) so that
--                                            dynamic call from core code
--                                            (hr_payrolls) will work.
--
-- J.N. Louw      24-Aug-2000 115.0           Updated for ZAPatch11i.01
-- L.J. Kloppers  22-Nov-2000 115.1           Move History Section into Package
-- Ghanshyam      07-Jul-2002 115.0           Moved the contents from
--					      $PER_TOP/patch/115/sql/hrzapcal.pkh
-- ========================================================================

procedure do
(
   p_payroll_name varchar2,
   p_effective_date date
);

procedure create_calendar
(
   p_payroll_id       in number,
   p_first_end_date   in date,
   p_last_end_date    in date,
   p_proc_period_type in varchar2,
   -- Parameters needed to call the core function add_multiple_of_base
   p_base_period_type in varchar2,
   p_multiple         in number,
   p_fpe_date         in date
);

function retrieve_tax_year_start return varchar2;

function retrieve_fiscal_year_start
(
   p_business_group_id in number
)
return date;

procedure create_za_payroll_month_ends
(
   p_payroll_id       in number,
   p_first_end_date   in date,
   p_last_end_date    in date,
   p_fiscal_start_day in number,
   -- Parameters needed to call the core function add_multiple_of_base
   p_base_period_type in varchar2,
   p_multiple         in number,
   p_fpe_date         in date
);

function generate_fiscal_month_start
(
   p_end_date         in date,
   p_fiscal_start_day in number
)
return date;

function next_lower_day
(
   p_fiscal_start_day in number,
   p_date             in date
)
return date;

function add_multiple_of_base
(
   p_target_date      in date,
   p_base_period_type in varchar2,
   p_multiple         in number,
   p_fpe_date         in date,
   p_regular_pay_mode boolean default false,
   p_pay_date_offset  number  default null
)
return date;

function next_semi_month
(
   p_semi_month_date in date,
   p_fpe_date        in date
)
return date;

function prev_semi_month
(
   p_semi_month_date in date,
   p_fpe_date        in date
)
return date;

procedure create_za_employee_tax_years
(
   p_payroll_id       in number,
   p_first_end_date   in date,
   p_last_end_date    in date,
   p_tax_year_start   in varchar2,
   p_proc_period_type in varchar2
);

procedure create_za_employee_cal_years
(
   p_payroll_id       in number,
   p_first_end_date   in date,
   p_last_end_date    in date,
   p_proc_period_type in varchar2
);

procedure create_za_tax_quarters
(
   p_payroll_id       in number,
   p_first_end_date   in date,
   p_last_end_date    in date
);

procedure create_za_period_numbers
(
   p_payroll_id       in number,
   p_first_end_date   in date,
   p_last_end_date    in date,
   p_proc_period_type in varchar2
);

end pay_za_calendars_pkg;

 

/
