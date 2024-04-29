--------------------------------------------------------
--  DDL for Package HR_US_FF_UDF1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_FF_UDF1" AUTHID CURRENT_USER AS
/* $Header: pyusudf1.pkh 120.15.12010000.10 2009/05/14 10:14:16 emunisek ship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : hr_us_ff_udf1
    Filename	: pyusudf1.pkh
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    19-AUG-02   TCLEWIS     	115.0             Created
    10-Oct-02   EKIM            115.2   2522002   Added functions
                                                  neg_earning, calc_earning
    06-Aug-03   VMEHTA          115.4             Corrected the definition
                                                  (parameters) for
                                                  get_prev_ptd_values
    15-APR-03   RMONGE          115.6  3562306    Added decimal places
                                                  to neg_earn_rec definition
                                                  for temp_earn,
                                                  reduced_neg_earn,
                                                  neg_earn_feed to 15,2
    30-APR-04   TCLEWIS         115.7             Added functions
                                                  get_work_jurisdictions
                                                  and
                                                  Jurisdiction_processed
    07-JUL-04   TCLEWIS        115.10             Changed plsql tables to be
                                                  indexed by binary integer.
                                                  version 115.7 was leap
                                                  frogged to 115.9, so
                                                  implementd 116.7 changes.

    02-AUG-04   TCLEWIS        115.11             Added GET_JD_PERCENT.
    09-APR-05   PPANDA         115.12  421122     New column jd_type added to record
                                                  type jd_record . This column will
                                                  denote types of jurisdiction associated
                                                  with the assignment.
                                                  JD_TYPE is added to deonte the Jurisdiction_Type
                                                 Following notation would be used for this
                                                 Residence                 -> RS
                                                 Work                      -> WK
                                                 Residence as well as Work -> RW
                                                 Residence as well as Tagged -> RT
                                                 Tagged Earnings           -> TG

                                                 A new function get_jurisdiction_type
                                                  added to fetch the value jurisdiction type
    12-JUN-05 SCHAUHAN        115.13   4194339  Added Function get_executive_status.
    20-AUG-05 SAIKRISH        115.14   4532107  Added get_it_work_jurisdictions,
                                                get_jd_level_threshold,get_th_assignment for
                                                Consultant Taxation.
    13-SEP-05 SAIKRISH        115.15   4532107  Added p_assignment_id parameter for
                                                get_jd_tax_balance.
    15-SEP-05 SAIKRISH        115.20   4532107  Changed spec for get_jd_tax_balance
    30-SEP-05 SAIKRISH        115.21   4638194  Added Person_id to get_person_it_hours
    03-APR-06 PPANDA          115.22   4715851  Few session variables were defined to fix the
                                                Enhanced tax interface issue on local tax.
    02-NOV-06 SSOURESR        115.24            Removed the variables from update 115.22
    23-JAN-07 SAIKRISH        115.25   5722893  Added new function get_jit_data.
    07-MAR-07 SAIKRISH        115.26            Added new function get_rs_jd,get_wk_jd
    10-MAR-08 jdevasah        115.76   2122611  Added new function get_wc_flag.
    10-APR-08 sjawid          115.77   6899939  Added new function parameter p_get_regular_wage to
                                                get_prev_ptd_values
    09-May-08 Pannapur        115.31   5972214  Added new function get_max_perc
    13-May-08 Pannapur        115.32            Reverted get_max_perc
    08-Aug-08 Pannapur        115.33   7238809 	Added new function parameter per_adr_geocode to
                                                 get_prev_ptd_values
    19-Dec-08 emunisek        115.34   5972214  Added new function coloradocity_ht_collectornot
    14-May-09 emunisek        115.36   8406097  Added new parameters p_payroll_action_id number,
				                p_monthly_gross to coloradocity_ht_collectornot
						function
    =============================================================================================

*/

--
  TYPE neg_earn_rec IS RECORD
   ( temp_earn         number(15,2),
     reduced_neg_earn  number(15,2),
     neg_earn_feed     number(15,2));

  TYPE neg_earn_tab IS TABLE OF neg_earn_rec
   INDEX BY BINARY_INTEGER;

  l_neg_earn_tab neg_earn_tab;

  type jd_record is record (
          Jurisdiction_code  pay_us_emp_state_tax_rules_f.jurisdiction_code%type
         ,percentage            NUMBER
         ,jd_type               VARCHAR2(2)
	 ,hours                 NUMBER
	 ,wages_to_accrue_flag  VARCHAR2(4)
	 ,tg_hours              NUMBER
	 ,other_pay_hours       NUMBER
                            );
  --
  -- JD_TYPE is added to deonte the Jurisdiction_Type
  -- Following notation would be used for this
  --           Residence                   -> RS
  --           Work                        -> WK
  --           Residence as well as Work   -> RW
  --           Residence as well as Tagged -> RT
  --           Tagged Earnings             -> TG
  --           Informational Time          -> IT
  --
  -- wages_to_accrue_flag
  --
  --    AIHW    -> Accumulate Information Hours and Wage
  --    AIHO    -> Accumulate only Information Hours
  --    IHNA    -> Accumulation of Information Hours Not Applicable

     type jurisdiction_table
     is table of jd_record
         index by BINARY_INTEGER;

     type state_processed_table
     is table of varchar2(1)
         index by BINARY_INTEGER;

     type county_processed_table
     is table of varchar2(1)
         index by BINARY_INTEGER;

     type city_processed_table
     is table of varchar2(1)
         index by BINARY_INTEGER;

     state_processed_tbl     state_processed_table;
     county_processed_tbl    county_processed_table;
     city_processed_tbl      city_processed_table;

     jurisdiction_codes_tbl            jurisdiction_table;
     jurisdiction_codes_tbl_stg        jurisdiction_table;

     res_jurisdiction_codes_tbl        jurisdiction_table;

     /* For threshold following details are defined */
     jd_codes_tbl_city_stg             jurisdiction_table;

     type inform_hour_jd_record is record (
          Jurisdiction_code  pay_us_emp_state_tax_rules_f.jurisdiction_code%type
         ,percentage            NUMBER
	 ,hours                 NUMBER
	 ,wages_to_accrue_flag  VARCHAR2(4)
	 ,calc_percent          varchar2(10)
	 ,threshold_hours       NUMBER);

     type inform_hours_summary_table
       is table of inform_hour_jd_record
          index by BINARY_INTEGER;

     jd_codes_tbl_state_stg    inform_hours_summary_table;
     jd_codes_tbl_state        inform_hours_summary_table;
     jd_codes_tbl_county_stg   inform_hours_summary_table;
     jd_codes_tbl_county       inform_hours_summary_table;

-- This flag to be used in get_jd_percent to branch the code for deriving W4 percentage
-- or information hours percentage. This flag would be set to true when assignment is
-- configured for processing information hours element entries
--
  g_use_it_flag             VARCHAR2(1):= 'N';

  FUNCTION calc_earning(p_template_earning     number,           -- Parameter
                        p_addl_asg_gre_itd     number,           -- Parameter
                        p_neg_earn_asg_gre_itd number)           -- Parameter
  RETURN NUMBER;

  FUNCTION neg_earning RETURN NUMBER;

/*Function added for 6899939*/
  FUNCTION get_prev_ptd_values(
                   p_assignment_action_id     number,            -- Context
                   p_tax_unit_id              number,            -- Context
                   p_jurisdiction_code        varchar2,          -- Context
                   p_fed_or_state             varchar2,          -- Parameter
                   p_regular_aggregate        number,            -- Parameter
                   calc_PRV_GRS               OUT nocopy number, -- Paramter
                   calc_PRV_TAX               OUT nocopy number )
  RETURN NUMBER;

  /*Function added for 7238809*/
    FUNCTION get_prev_ptd_values(
                   p_assignment_action_id     number,            -- Context
                   p_tax_unit_id              number,            -- Context
                   p_jurisdiction_code        varchar2,          -- Context
                   p_fed_or_state             varchar2,          -- Parameter
                   p_regular_aggregate        number,            -- Parameter
                   calc_PRV_GRS               OUT nocopy number, -- Paramter
                   calc_PRV_TAX               OUT nocopy number,
                   p_get_regular_wage         varchar2 )
    RETURN NUMBER;

  FUNCTION get_prev_ptd_values(
                   p_assignment_action_id     number,            -- Context
                   p_tax_unit_id              number,            -- Context
                   p_jurisdiction_code        varchar2,          -- Context
                   p_fed_or_state             varchar2,          -- Parameter
                   p_regular_aggregate        number,            -- Parameter
                   calc_PRV_GRS               OUT nocopy number, -- Paramter
                   calc_PRV_TAX               OUT nocopy number,
		               p_get_regular_wage         varchar2,          -- Paramter /*6899939*/
                   per_adr_geocode             varchar2          )  -- Parameter /*7238809*/
  RETURN NUMBER;

  FUNCTION get_work_jurisdictions(
                   p_assignment_action_id number                 -- Formula Context
                  ,p_INITIALIZE           in            varchar2 -- Parameter
                  ,p_jurisdiction_code    in out nocopy varchar2 -- Parameter
                  ,p_percentage           out    nocopy number   -- Parameter
                                 )
  RETURN varchar2;

  FUNCTION get_it_work_jurisdictions(p_assignment_action_id   NUMBER
                                    ,p_initialize             IN VARCHAR2
                                    ,p_jurisdiction_code      IN OUT NOCOPY VARCHAR2
                                    ,p_percentage             OUT NOCOPY NUMBER
				    ,p_assignment_id          IN  NUMBER
				    ,p_date_paid              IN  DATE
		                    ,p_date_earned            IN  DATE
				    ,p_time_period_id         IN  NUMBER
				    ,p_payroll_id             IN  NUMBER
				    ,p_business_group_id      IN  NUMBER
				    ,p_tax_unit_id            IN  NUMBER
                                    )
  RETURN VARCHAR2;

  FUNCTION Jurisdiction_processed (
                   p_jurisdiction_code    in varchar2            -- Paramter
                  ,p_jd_level             in varchar             -- Paramter
                                 )
  RETURN varchar2;

  FUNCTION get_fed_prev_ptd_values(
                       p_assignment_action_id number,            -- Context
                       p_tax_unit_id          number,            -- Context
                       p_fed_or_state         varchar2,          -- Parameter
                       p_regular_aggregate    number,            -- Parameter
                       calc_PRV_GRS           OUT nocopy number, -- Parameter
                       calc_PRV_TAX           OUT nocopy number) -- Parameter
  RETURN NUMBER;

  FUNCTION get_jd_percent(p_jurisdiction_code                VARCHAR2           -- Parameter
                         ,p_jd_level                         VARCHAR2           -- Parameter
			 ,p_hours_to_accumulate   OUT nocopy NUMBER             -- Parameter
		         ,p_wages_to_accrue_flag  OUT nocopy VARCHAR2           -- Parameter
                         )
  RETURN number;

  FUNCTION get_tax_jurisdiction(
                          p_assignment_id             number             -- Context
                         ,p_date_earned               date               -- Parameter
                               )
  RETURN varchar2;
  --
  -- This function used to fetch the JD_TYPE set in the pl table for a given
  -- jurisdiction
  --
  FUNCTION get_jurisdiction_type(p_jurisdiction_code varchar2           -- Parameter
                                )
  RETURN varchar2;

  --
  -- This function is used to fetch the status of Employee. It is used for determining
  -- whether executive weekly maximum should be applicable for a employee.
  --
  FUNCTION get_executive_status(p_assignment_id number,
                              p_date_earned date,
			      p_jurisdiction_code varchar2
			      )
  RETURN varchar2;

  FUNCTION get_wc_flag(p_assignment_id number,
                              p_date_earned date,
			      p_wc_flat_rate_period varchar2
			      )
  RETURN varchar2;

  --Function to return threshold informational hours for a given jurisdiction.
  FUNCTION get_jd_level_threshold(p_tax_unit_id       NUMBER
                                 ,p_jurisdiction_code VARCHAR2
                                 ,p_jd_level          VARCHAR2)
  RETURN NUMBER;

--Function to get balance value
FUNCTION get_jd_tax_balance(p_threshold_basis        IN VARCHAR2
                          ,p_assignment_action_id   IN NUMBER
                          ,p_jurisdiction_code      IN VARCHAR2
                          ,p_tax_unit_id            IN NUMBER
                          ,p_jurisdiction_level     IN VARCHAR2
			  ,p_effective_date         IN DATE
                          ,p_assignment_id          IN NUMBER
                          ) RETURN  NUMBER;

--Function to get Informational Hours logged by the assignment for
--each jurisdiction code in the pl table.
FUNCTION get_person_it_hours(p_person_id            IN NUMBER
                            ,p_assignment_id        IN NUMBER
                            ,p_jurisdiction_code    IN VARCHAR2
                            ,p_jd_level             IN VARCHAR2 --2,6,11
			    ,p_threshold_basis      IN VARCHAR2 --YTD,RTD
			    ,p_effective_date       IN DATE
			    ,p_end_date             IN DATE) RETURN NUMBER;

--
-- This function would be used for fetching percentage to be used STATE and
-- COUNTY level percentage to be used for distributing wages over different
-- jurisdictions when assignment is configured to process information hours
--
FUNCTION get_it_jd_percent(p_jurisdiction_code               VARCHAR2 -- parameter
                          ,p_jd_level                        VARCHAR2 -- parameter
                          ,p_hours_to_accumulate  OUT nocopy NUMBER   -- parameter
                          ,p_wages_to_accrue_flag OUT nocopy VARCHAR2 -- parameter
                          )
RETURN NUMBER;

FUNCTION across_calendar_years(p_payroll_action_id  in number)
RETURN varchar2;

FUNCTION get_work_state (p_jurisdiction_code  in varchar2)
RETURN varchar2;

--Function to return the SUI Wage Limits.
FUNCTION get_jit_data(p_jurisdiction_code IN VARCHAR2
                     ,p_date_earned       IN DATE
		     ,p_jit_type          IN VARCHAR2)
RETURN NUMBER;

FUNCTION  get_rs_jd (p_assignment_id  IN  NUMBER,
                     p_date_earned    IN  DATE)
RETURN VARCHAR2;

FUNCTION  get_wk_jd (p_assignment_id   IN  NUMBER,
                    p_date_earned     IN  DATE,
                    p_jurisdiction_code IN VARCHAR2)
RETURN VARCHAR2;

--Function to check if head tax can be deducted or not for the given Colorado City
FUNCTION coloradocity_ht_collectornot(p_assignment_id number, --Context
                                      p_date_earned date,     --Context
				      p_payroll_action_id number, --Context Added for bug#8406097
                                      p_jurisdiction_code      VARCHAR2, --parameter
                                      p_prim_jurisdiction_code VARCHAR2, --parameter
				      p_monthly_gross          NUMBER) --parameter Added for bug#8406097
RETURN NUMBER;

END hr_us_ff_udf1;

/
