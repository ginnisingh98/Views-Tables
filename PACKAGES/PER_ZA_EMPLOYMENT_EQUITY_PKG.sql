--------------------------------------------------------
--  DDL for Package PER_ZA_EMPLOYMENT_EQUITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_EMPLOYMENT_EQUITY_PKG" AUTHID CURRENT_USER as
/* $Header: perzaeer.pkh 120.3.12010000.4 2010/04/01 09:30:02 rbabla ship $ */
/*
==============================================================================
This package loads data into table per_za_employment_equity for use by
the Employment Equity Reports

MODIFICATION HISTORY
Name           Date        Version Bug     Text
-------------- ----------- ------- ------- -----------------------------
R. Kingham     22 May 2000   110.0         Initial Version
R. Kingham     15 Jun 2000   110.1         Added Extra functionality for EEQ.
D. Son         20 Jun 2001   110.2         Changed package to suit multiple
                                           Legal Entities and provide re-usable
                                           functions.
F.D. Loubser   11 Sep 2001   115.3         Almost complete rewrite for 11i.
F.D. Loubser   10 Dec 2001   115.5         Business_group_id on user table
F.D. Loubser    1 Feb 2002   115.6         Added checkfile
F.D. Loubser   14 Feb 2002   115.7         Added multiple legal entity
F.D. Loubser    9 May 2002   115.8         g_cat_flex variable too small
Nageswara      18 Nov 2004   115.9 3962073 GSCC Warnings removed
R V Pahune     24-Jul-2006   115.12 5406242 Employment equity enhancement
R Babla        24-Nov-2009   115.13 9112237 Added init_g_cat_lev_new_table and
                                            supporting procedures from
                                            reporting year 2009
NCHINNAM       01-Dec-2009   115.14 9112237 Added new procedures from
                                            reporting year 2009
R Babla        01-Apr-2010   115.16 9462039 Modified few procedures to add
                                            parameter p_year
==============================================================================
*/

-- This procedure resets the list of highest and lowest values.
procedure reset_high_low_lists;

-- This procedure returns the average of the 5 highes and lowest values from the lists.
procedure calc_highest_and_lowest_avg
(
   p_high_avg out nocopy number,
   p_low_avg  out nocopy number
);

-- This procedure maintains a list of the 5 highest and lowest values passed to it.
procedure get_highest_and_lowest(p_value in number);

-- This function returns the number of days the assignment's status was Active Assignment
-- Note: Suspended Assignment is not seen as active in this case, since it is not
--       income generating
function get_active_days
(
   p_assignment_id number,
   p_report_start  date,
   p_report_end    date
)  return number;

-- This function returns the termination reason from the user tables.
function get_termination_reason
(
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_reason_code       in per_periods_of_service.leaving_reason%type
)  return varchar2;

-- This procedure resets all the data structures for the Income Differentials report.
procedure reset_tables;

-- This function returns the average 5 highest paid employees per category or level.
function get_avg_5_highest_salary
(
   p_report_date            in per_all_assignments_f.effective_end_date%type,
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legent_param           in per_assignment_extra_info.aei_information7%type := null,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type := null,
   p_occupational_level_cat in hr_lookups.meaning%type,
   p_lookup_code            in hr_lookups.lookup_code%type,
   p_occupational_type      in varchar2, -- CAT = Occupational Category , LEV = Occupational Level
   p_salary_method          in varchar2  -- SAL = Salary Basis Method, BAL = Payroll Balances Method
)  return number;

-- This function returns the average 5 lowest paid employees per category or level.
function get_avg_5_lowest_salary
(
   p_report_date            in per_all_assignments_f.effective_end_date%type,
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legent_param           in per_assignment_extra_info.aei_information7%type := null,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type := null,
   p_occupational_level_cat in hr_lookups.meaning%type,
   p_lookup_code            in hr_lookups.lookup_code%type,
   p_occupational_type      in varchar2, -- CAT = Occupational Category , LEV = Occupational Level
   p_salary_method          in varchar2  -- SAL = Salary Basis Method, BAL = Payroll Balances Method
)  return number;

-- This function returns the person's legislated employment type (permanent or non-permanent)
function get_ee_employment_type_name
(
   p_report_date          in per_all_people_f.start_date%type,
   p_period_of_service_id in per_all_assignments_f.period_of_service_id%type
)  return varchar2;

-- This function returns the occupational categories from the user tables.
function get_occupational_category
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_assignment_id     in per_all_assignments_f.assignment_id%type,
   p_job_id            in per_all_assignments_f.job_id%type,
   p_grade_id          in per_all_assignments_f.grade_id%type,
   p_position_id       in per_all_assignments_f.position_id%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type
)  return varchar2;

-- This function returns the occupational levels from the user tables.
function get_occupational_level
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_assignment_id     in per_all_assignments_f.assignment_id%type,
   p_job_id            in per_all_assignments_f.job_id%type,
   p_grade_id          in per_all_assignments_f.grade_id%type,
   p_position_id       in per_all_assignments_f.position_id%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_year              in number default 2000
)  return varchar2;

-- This function retrieves the occupational data via dynamic sql from the appropriate flexfield segment
function get_occupational_data
(
   p_type        in varchar2,
   p_flex        in varchar2,
   p_segment     in varchar2,
   p_job_id      in per_all_assignments_f.job_id%type,
   p_grade_id    in per_all_assignments_f.grade_id%type,
   p_position_id in per_all_assignments_f.position_id%type
)  return varchar2;

-- This procedure caches the location of the occupational category and level data.
procedure cache_occupational_location
(
   p_report_date       in date,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_year              in number default 2000
);

-- This function returns the lookup_code from the user tables.
function get_lookup_code
(
   p_meaning in hr_lookups.meaning%type
)  return varchar2;

-- This function populates an entity's sex and race and category matches.
procedure populate_ee_table
(
   p_report_code       in varchar2,
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id   in per_assignment_extra_info.aei_information7%type := null
);

-- This function retrieves the functional data via dynamic sql from the appropriate flexfield segment
function get_functional_data
(
   p_flex        in varchar2,
   p_segment     in varchar2,
   p_job_id      in per_all_assignments_f.job_id%type,
   p_grade_id    in per_all_assignments_f.grade_id%type,
   p_position_id in per_all_assignments_f.position_id%type
)  return varchar2;


function get_functional_type
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_assignment_id     in per_all_assignments_f.assignment_id%type,
   p_job_id            in per_all_assignments_f.job_id%type,
   p_grade_id          in per_all_assignments_f.grade_id%type,
   p_position_id       in per_all_assignments_f.position_id%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_year              in number default 2000
)  return varchar2;

-- Report will call this procedure which n terms call the populate_ee_table
procedure populate_ee_table_EEWF
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id   in per_assignment_extra_info.aei_information7%type := null
);


PROCEDURE ins_g_Enc_Diff_table(p_mi_inc     IN number
                             , p_mc_inc     IN number
                             , p_ma_inc     IN number
                             , p_mw_inc     IN number
                             , p_fa_inc     IN number
                             , p_fc_inc     IN number
                             , p_fi_inc     IN number
                             , p_fw_inc     IN number
                             , p_total_inc  IN number
                             , p_ma         IN number
                             , p_mc         IN number
                             , p_mi         IN number
                             , p_mw         IN number
                             , p_fa         IN number
                             , p_fc         IN number
                             , p_fi         IN number
                             , p_fw         IN number
                             , p_total      IN number
                             , p_cat_index  IN number
                             , p_lev_index  IN number
                             , p_legal_entity_id IN hr_all_organization_units.organization_id%type
                             , p_occupational_level IN hr_lookups.meaning%type
                             , p_occupational_category IN hr_lookups.meaning%type
                             , p_occupational_level_id IN hr_lookups.lookup_code%type
                             , p_occupational_category_id IN hr_lookups.lookup_code%type
                              );

Procedure cat_lev_data ( p_legal_entity_id IN hr_all_organization_units.organization_id%type
                       , p_occupational_level IN hr_lookups.meaning%type
                       , p_occupational_category IN hr_lookups.meaning%type
                       , p_race IN per_all_people_f.per_information4%type
                       , p_sex IN per_all_people_f.sex%type
                       , p_income IN number
                       , p_occupational_level_id IN hr_lookups.lookup_code%type
                       , p_occupational_category_id IN hr_lookups.lookup_code%type
                       ) ;

procedure init_g_cat_lev_table
(
   p_report_date            in per_all_assignments_f.effective_end_date%type,
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type := null,
   p_salary_method          in varchar2  -- SAL = Salary Basis Method, BAL = Payroll Balances Method
);

procedure init_g_cat_lev_new_table
(
   p_report_date            in per_all_assignments_f.effective_end_date%type,
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type := null,
   p_salary_method          in varchar2  -- SAL = Salary Basis Method, BAL = Payroll Balances Method
);

function get_termination_reason_new
(
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_reason_code       in per_periods_of_service.leaving_reason%type
)  return varchar2;

procedure populate_ee_table_new
(
   p_report_code       in varchar2,
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id   in per_assignment_extra_info.aei_information7%type := null
);

procedure populate_ee_table_EEWF_new
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id   in per_assignment_extra_info.aei_information7%type := null
);

end per_za_employment_equity_pkg;

/
