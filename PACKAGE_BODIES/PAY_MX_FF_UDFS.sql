--------------------------------------------------------
--  DDL for Package Body PAY_MX_FF_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_FF_UDFS" AS
/* $Header: pymxudfs.pkb 120.16.12010000.9 2010/04/12 07:56:51 jdevasah ship $ */

/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   15-Nov-2004  vpandya     115.0            Created.
   28-Nov-2004  vpandya     115.1            Changed pkg name to pay_mx_ff..
                                             from hr_mx_ff_udfs.
   30-Nov-2004  vmehta      115.2            Added get_idw function
   02-Dec-2004  vmehta      115.2            Corrected the definition of
                                             lv_period_type
   21-Jan-2005  ardsouza    115.6  4129001   hr_mx_utility.get_gre_from_location
                                             call modified to pass BG.
   24-Feb-2005  vmehta      115.7            Changed effective_start_date to
                                             1900 for user tables etc.
   13-Apr-2005  vmehta      115.8  4283684   Modified create_idw_contract to
                                             use GRE: as a prefix when creating
                                             a GRE level contract.
   28-Apr-2005  kthirmiy    115.9            Added idw method B Factor
                                             Table method code logic in get_idw.
   17-Jun-2005  vmehta      115.10 4434889   round idw values up to two decimal
                                             places
   20-Jun-2005  vmehta      115.11 4444691   Round the seniority years to whole                                                                                           numbers
   18-Jul-2005  kthirmiy    115.13 4493980   Round the seniority years to the
                                             ceiling.
   17-Aug-2005  vmehta      115.14           Check for NO_DATA_FOUND when
                                             fetching run_results for variable
                                             IDW
   17-Aug-2005  vmehta      115.15 4559484   Passing translated meaning instead
                                             of English to get_historic_rates
                                             function
   03-Dec-2005  vmehta      115.16 4779627   Changes to get_idw function:
                                             derive idw_start_date so that
                                             we only look for run results within
                                             the reporting period.
                                             get_idw_last_action only looks
                                             within start date and report
                                             effective date (end of bi-month
                                             period)
   06-Dec-2005  vpandya     115.18           Added following functions:
                                             - get_base_pay
                                             - get_mx_historic_rate
   21-Dec-2005  vpandya     115.19           Added following functions:
                                             - get_base_pay_for_tax_calc
                                             Renamed function get_base_pay to
                                             get_daily_base_pay
   06-Jan-2006  vpandya     115.20          Using get_seniority_social_security
                                            function to get seniority years for
                                            IDW (changed get_idw).
   24-Apr-2006  vpandya     115.21 5179475  Changed get_idw and commented out
                                            raise_error when
                                            lv_idw_factor_tab_name is null.
   29-Jun-2006  vpandya     115.22 5365301  Added clean_dupl_user_table_rows
                                            into get_mx_historic_rate.
   07-Jun-2007  vpandya     115.23 6120352  Changed get_idw procedure:
                                            added c_idw_factor_table_US and
                                            c_idw_user_table_check cursor.
   15-Feb-2008  sivanara    115.24 6815180  Added fnd_number.canonical_to_number
                                            in tht function get_idw.
   15-Apr-2008  sivanara    115.25 6969326  Added the missed out parameter call
                                            while calling core package
					    pay_user_row_api.create_user_row
   13-Jun-2008  nragavar    115.26 7047220  Added fnd_number.canonical_to_number
                                            in tht function get_idw.
   09-Jul-2008  sivanara    115.27 7208623  Added fnd_number.canonical_to_number
                                            in tht function get_idw.get_contract_name
   04-Aug-2008  nragavar    115.28 7042174  Done changes as part of 10 day
                                            payroll frequency.
   20-Aug-2008  nragavar    115.29 7336646  no of days in pay period for 10 day
                                            added in get_contract_name procedure.
   30-Jul-2009  sjawid      115.30 6933682  Added new overloaded function get_idw
                                            with context p_payroll_action_id,
					    and new parameter p_execute_old_idw_code.
   03-Aug-2009  sjawid      115.31 6933682  Changed parameter name p_idw_flag
                                            to p_execute_old_idw_code in
					                                  get_idw function.
   25-Feb-2010  jdevasah    115.33 9386250  added conditions  to
                            115.34 9495744  c_get_last_idw_action.
*/


FUNCTION standard_hours_worked(
                                p_std_hrs        in NUMBER,
                                p_range_start    in DATE,
                                p_range_end      in DATE,
                                p_std_freq       in VARCHAR2) RETURN NUMBER IS

c_wkdays_per_week        NUMBER(5,2)                ;
c_wkdays_per_month        NUMBER(5,2)                ;
c_wkdays_per_year        NUMBER(5,2)                ;

/* 353434, 368242 : Fixed number width for total hours */
v_total_hours        NUMBER(15,7)        ;
v_wrkday_hours        NUMBER(15,7)         ;         -- std hrs/wk divided by 5 workdays/wk
v_curr_date        DATE;
v_curr_day        VARCHAR2(3); -- 3 char abbrev for day of wk.
v_day_no        NUMBER;

BEGIN -- standard_hours_worked

 /* Init */
c_wkdays_per_week := 5;
c_wkdays_per_month := 20;
c_wkdays_per_year := 250;
v_total_hours := 0;
v_wrkday_hours :=0;
v_curr_date := NULL;
v_curr_day :=NULL;

-- Check for valid range
hr_utility.trace('Entered standard_hours_worked');

IF p_range_start > p_range_end THEN
  hr_utility.trace('p_range_start greater than p_range_end');
  RETURN v_total_hours;
--  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
--  hr_utility.raise_error;
END IF;
--

IF UPPER(p_std_freq) = 'WEEK' THEN
  hr_utility.trace('p_std_freq = WEEK ');

  v_wrkday_hours := p_std_hrs / c_wkdays_per_week;

 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_week ='||to_number(c_wkdays_per_week));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSIF UPPER(p_std_freq) = 'MONTH' THEN

  hr_utility.trace('p_std_freq = MONTH ');

  v_wrkday_hours := p_std_hrs / c_wkdays_per_month;


 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_month ='||to_number(c_wkdays_per_month));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSIF UPPER(p_std_freq) = 'YEAR' THEN

  hr_utility.trace('p_std_freq = YEAR ');
  v_wrkday_hours := p_std_hrs / c_wkdays_per_year;

 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_year ='||to_number(c_wkdays_per_year));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSE
hr_utility.trace('p_std_freq in ELSE ');
  v_wrkday_hours := p_std_hrs;
END IF;

v_curr_date := p_range_start;

hr_utility.trace('v_curr_date is range start'||to_char(v_curr_date));


LOOP

  v_day_no := TO_CHAR(v_curr_date, 'D');


  IF v_day_no > 1 and v_day_no < 7 then


    v_total_hours := nvl(v_total_hours,0) + v_wrkday_hours;

   hr_utility.trace('  v_day_no  = '||to_char(v_day_no));
   hr_utility.trace('  v_total_hours  = '||to_char(v_total_hours));
  END IF;

  v_curr_date := v_curr_date + 1;
  EXIT WHEN v_curr_date > p_range_end;
END LOOP;
hr_utility.trace('  Final v_total_hours  = '||to_char(v_total_hours));
hr_utility.trace('  Leaving standard_hours_worked' );
--
RETURN v_total_hours;
--
END standard_hours_worked;
--

-- **********************************************************************
   FUNCTION Convert_Period_Type(
                    p_bus_grp_id            in NUMBER,
                    p_payroll_id            in NUMBER,
                    p_tax_unit_id           in NUMBER,
                    p_asst_work_schedule    in VARCHAR2,
                    p_asst_std_hours        in NUMBER,
                    p_figure                in NUMBER,
                    p_from_freq             in VARCHAR2,
                    p_to_freq               in VARCHAR2,
                    p_period_start_date     in DATE,
                    p_period_end_date       in DATE,
                    p_asst_std_freq         in VARCHAR2)
   RETURN NUMBER IS

   -- local vars
   v_calc_type                  VARCHAR2(50);
   v_from_stnd_factor           NUMBER(30,7);
   v_stnd_start_date            DATE;

   v_converted_figure           NUMBER(27,7);
   v_from_annualizing_factor    NUMBER(30,7);
   v_to_annualizing_factor      NUMBER(30,7);

   -- local fun

     FUNCTION Get_Annualizing_Factor(p_bg                    in NUMBER,
                                     p_payroll               in NUMBER,
                                     p_txu_id                in NUMBER,
                                     p_freq                  in VARCHAR2,
                                     p_asg_work_sched        in VARCHAR2,
                                     p_asg_std_hrs           in NUMBER,
                                     p_asg_std_freq          in VARCHAR2)
     RETURN NUMBER IS

       CURSOR c_period_type( cp_payroll_id NUMBER ) IS
         SELECT period_type
         FROM   pay_payrolls_f
         WHERE  payroll_id = cp_payroll_id;

       -- local constants

       c_weeks_per_year       NUMBER(3);
       c_days_per_year        NUMBER(3);
       c_months_per_year      NUMBER(3);

      -- local vars

       v_annualizing_factor       NUMBER(30,7);
       v_periods_per_fiscal_yr    NUMBER(5);
       v_hrs_per_wk               NUMBER(15,7);
       v_hrs_per_range            NUMBER(15,7);
       v_days_per_range           NUMBER(15,7);
       v_use_pay_basis            NUMBER(1);
       v_pay_basis                VARCHAR2(80);
       v_range_start              DATE;
       v_range_end                DATE;
       v_work_sched_name          VARCHAR2(80);
       v_ws_id                    NUMBER(9);
       v_period_hours             BOOLEAN;

       lv_period_type             varchar2(150);

     BEGIN -- Get_Annualizing_Factor

       /* Init */

       c_weeks_per_year   := 52;
       c_days_per_year    := 200;
       c_months_per_year  := 12;
       v_use_pay_basis    := 0;

       --
       -- Check for use of salary admin (ie. pay basis) as frequency.
       -- Selecting "count" because we want to continue processing even if
       -- the from_freq is not a pay basis.
       --

        hr_utility.trace('  Entered  Get_Annualizing_Factor ');

        BEGIN        -- Is Freq pay basis?

          --
          -- Decode pay basis and set v_annualizing_factor accordingly.
          -- PAY_BASIS "Meaning" is passed from FF !
          --

          hr_utility.trace('  Getting lookup code for lookup_type = PAY_BASIS');
          hr_utility.trace('  p_freq = '||p_freq);

          SELECT  lookup_code
          INTO    v_pay_basis
          FROM    hr_lookups lkp
          WHERE   lkp.application_id = 800
          AND     lkp.lookup_type    = 'PAY_BASIS'
          AND     lkp.meaning        = p_freq;

          hr_utility.trace('  Lookup_code ie v_pay_basis ='||v_pay_basis);

          v_use_pay_basis := 1;

          IF v_pay_basis = 'MONTHLY' THEN

             hr_utility.trace('  Entered for MONTHLY v_pay_basis');

             v_annualizing_factor := 12;

             hr_utility.trace(' v_annualizing_factor = 12 ');

          ELSIF v_pay_basis = 'HOURLY' THEN

             hr_utility.trace('  Entered for HOURLY v_pay_basis');

             IF p_period_start_date IS NOT NULL THEN

                hr_utility.trace('  p_period_start_date IS NOT NULL ' ||
                                 '  v_period_hours=T');

                v_range_start      := p_period_start_date;
                v_range_end        := p_period_end_date;
                v_period_hours     := TRUE;

             ELSE

                hr_utility.trace('  p_period_start_date IS NULL');

                v_range_start      := sysdate;
                v_range_end        := sysdate + 6;
                v_period_hours     := FALSE;

             END IF;

             IF UPPER(p_asg_work_sched) <> 'NOT ENTERED' THEN

                -- Hourly employee using work schedule.
                -- Get work schedule name

                hr_utility.trace('  Hourly employee using work schedule');
                hr_utility.trace('  Get work schedule name');

                v_ws_id := fnd_number.canonical_to_number(p_asg_work_sched);

                hr_utility.trace('  v_ws_id ='||to_number(v_ws_id));


                SELECT  user_column_name
                INTO    v_work_sched_name
                FROM    pay_user_columns
                WHERE   user_column_id                  = v_ws_id
                AND     NVL(business_group_id, p_bg)    = p_bg
                AND     NVL(legislation_code,'MX')      = 'MX';

                hr_utility.trace('  v_work_sched_name ='||v_work_sched_name);
                hr_utility.trace('  Calling Work_Sch_Total_Hours_or_Days');

                v_hrs_per_range :=
                                Work_Sch_Total_Hours_or_Days(p_bg,
                                                             v_work_sched_name,
                                                             v_range_start,
                                                             v_range_end);

             ELSE-- Hourly emp using Standard Hours on asg.

                hr_utility.trace('  Hourly emp using Standard Hours on asg');
                hr_utility.trace('  calling Standard_Hours_Worked');

                v_hrs_per_range := Standard_Hours_Worked(p_asg_std_hrs,
                                                         v_range_start,
                                                         v_range_end,
                                                         p_asg_std_freq);

             END IF;

             IF v_period_hours THEN

                hr_utility.trace('  v_period_hours is TRUE');

                SELECT TPT.number_per_fiscal_year
                INTO   v_periods_per_fiscal_yr
                FROM   pay_payrolls_f  PPF,
                       per_time_period_types TPT,
                       fnd_sessions fs
                WHERE  PPF.payroll_id = p_payroll
                AND    fs.session_id  = USERENV('SESSIONID')
                AND    fs.effective_date between PPF.effective_start_date
                                             and PPF.effective_end_date
                AND    TPT.period_type = PPF.period_type;

                v_annualizing_factor :=
                           v_hrs_per_range * v_periods_per_fiscal_yr;

             ELSE

                v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

             END IF;

         ELSIF v_pay_basis = 'PERIOD' THEN

            hr_utility.trace('  v_pay_basis = PERIOD');

            SELECT  TPT.number_per_fiscal_year
            INTO    v_annualizing_factor
            FROM    pay_payrolls_f          PRL,
                    per_time_period_types   TPT,
                    fnd_sessions            fs
            WHERE   TPT.period_type             = PRL.period_type
            and     fs.session_id               = USERENV('SESSIONID')
            and     fs.effective_date  BETWEEN PRL.effective_start_date
                                           AND PRL.effective_end_date
            AND     PRL.payroll_id              = p_payroll
            AND     PRL.business_group_id + 0   = p_bg;


         ELSIF v_pay_basis = 'ANNUAL' THEN


            hr_utility.trace('  v_pay_basis = ANNUAL');

            v_annualizing_factor := 1;

         ELSE

            -- Did not recognize "pay basis", return -999 as annualizing factor.
            -- Remember this for debugging when zeroes come out as results!!!

            hr_utility.trace('  Did not recognize pay basis');

            v_annualizing_factor := 0;

            RETURN v_annualizing_factor;

         END IF;

         EXCEPTION

         WHEN NO_DATA_FOUND THEN

           hr_utility.trace('  When no data found' );
           v_use_pay_basis := 0;

        END; /* SELECT LOOKUP CODE */

        IF v_use_pay_basis = 0 THEN

           hr_utility.trace('  Not using pay basis as frequency');

           -- Not using pay basis as frequency...

           IF (p_freq IS NULL)                  OR
              (UPPER(p_freq) = 'PERIOD')        OR
              (UPPER(p_freq) = 'NOT ENTERED')
           THEN

              -- Get "annuallizing factor" from period type of the payroll.

              hr_utility.trace('Get annuallizing factor from period '||
                               'type of the payroll');

               SELECT  TPT.number_per_fiscal_year
               INTO    v_annualizing_factor
               FROM    pay_payrolls_f          PRL,
                       per_time_period_types   TPT,
                       fnd_sessions            fs
               WHERE   TPT.period_type         = PRL.period_type
               AND     fs.session_id = USERENV('SESSIONID')
               AND     fs.effective_date  BETWEEN PRL.effective_start_date
                                              AND PRL.effective_end_date
               AND     PRL.payroll_id          = p_payroll
               AND     PRL.business_group_id + 0   = p_bg;

               hr_utility.trace('v_annualizing_factor ='||
                                to_number(v_annualizing_factor));

           ELSIF UPPER(p_freq) = 'DAILY' THEN

              hr_utility.trace('  Daily Employee');

              v_annualizing_factor :=
                  pay_mx_utility.get_days_in_year(p_bg, p_txu_id, p_payroll);


           ELSIF UPPER(p_freq) = 'HOURLY' THEN  -- Hourly employee...

               hr_utility.trace('  Hourly Employee');

               IF p_period_start_date IS NOT NULL THEN
                  v_range_start      := p_period_start_date;
                  v_range_end        := p_period_end_date;
                  v_period_hours     := TRUE;
               ELSE
                  v_range_start      := sysdate;
                  v_range_end        := sysdate + 6;
                  v_period_hours     := FALSE;
               END IF;

               IF UPPER(p_asg_work_sched) <> 'NOT ENTERED' THEN

                  -- Hourly emp using work schedule.
                  -- Get work schedule name:

                  v_ws_id := fnd_number.canonical_to_number(p_asg_work_sched);

                  SELECT user_column_name
                  INTO   v_work_sched_name
                  FROM   pay_user_columns
                  WHERE  user_column_id               = v_ws_id
                  AND    NVL(business_group_id, p_bg) = p_bg
                  AND    NVL(legislation_code,'MX')   = 'MX';


                  v_hrs_per_range := Work_Sch_Total_Hours_or_Days(
                                                         p_bg,
                                                         v_work_sched_name,
                                                         v_range_start,
                                                         v_range_end);

               ELSE-- Hourly emp using Standard Hours on asg.

                  hr_utility.trace('  Hourly emp using Standard Hours on asg');

                  hr_utility.trace('calling Standard_Hours_Worked');

                  v_hrs_per_range := Standard_Hours_Worked(p_asg_std_hrs,
                                                           v_range_start,
                                                           v_range_end,
                                                           p_asg_std_freq);

                  hr_utility.trace('returned Standard_Hours_Worked');
               END IF;


               IF v_period_hours THEN

                  hr_utility.trace('v_period_hours = TRUE');

                  SELECT TPT.number_per_fiscal_year
                  INTO   v_periods_per_fiscal_yr
                  FROM   pay_payrolls_f        ppf,
                         per_time_period_types tpt,
                         fnd_sessions          fs
                  WHERE  ppf.payroll_id    = p_payroll
                  AND    fs.session_id     = USERENV('SESSIONID')
                  AND    fs.effective_date BETWEEN ppf.effective_start_date
                                           AND ppf.effective_end_date
                  AND    tpt.period_type = ppf.period_type;

                  v_annualizing_factor :=
                                v_hrs_per_range * v_periods_per_fiscal_yr;

                  hr_utility.trace('v_hrs_per_range ='||
                                          to_number(v_hrs_per_range));
                  hr_utility.trace('v_periods_per_fiscal_yr ='||
                                          to_number(v_periods_per_fiscal_yr));
                  hr_utility.trace('v_annualizing_factor ='||
                                          to_number(v_annualizing_factor));

               ELSE

                  hr_utility.trace('v_period_hours = FALSE');

                  v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

                  hr_utility.trace('v_hrs_per_range ='||
                                          to_number(v_hrs_per_range));
                  hr_utility.trace('c_weeks_per_year ='||
                                          to_number(c_weeks_per_year));
                  hr_utility.trace('v_annualizing_factor ='||
                                          to_number(v_annualizing_factor));

               END IF;

           ELSE

                -- Not hourly, an actual time period type!

                hr_utility.trace('Not hourly - an actual time period type');

                BEGIN

                  hr_utility.trace(' selecting from per_time_period_types');

                  SELECT PT.number_per_fiscal_year
                  INTO   v_annualizing_factor
                  FROM   per_time_period_types PT
                  WHERE  UPPER(PT.period_type) = UPPER(p_freq);

                  hr_utility.trace('v_annualizing_factor ='||
                                    to_number(v_annualizing_factor));

                  EXCEPTION WHEN no_data_found THEN

                    -- Added as part of SALLY CLEANUP.
                    -- Could have been passed in an ASG_FREQ dbi which
                    -- might have the values of
                    -- 'Day' or 'Month' which do not map to a time period type.
                    -- So we'll do these by hand.

                    IF UPPER(p_freq) = 'DAY' THEN
                       hr_utility.trace('  p_freq = DAY');
                       v_annualizing_factor := c_days_per_year;
                    ELSIF UPPER(p_freq) = 'MONTH' THEN
                       v_annualizing_factor := c_months_per_year;
                       hr_utility.trace('  p_freq = MONTH');
                    END IF;

                END;

           END IF;

        END IF;        -- (v_use_pay_basis = 0)


        hr_utility.trace('  Getting out of Get_Annualizing_Factor for '||
                                           v_pay_basis);
        RETURN v_annualizing_factor;

     END Get_Annualizing_Factor;


   BEGIN                 -- Convert Figure

     --begin_convert_period_type

     --hr_utility.trace_on(null,'UDFS');

     hr_utility.trace('UDFS Entered Convert_Period_Type');

     hr_utility.trace('  p_bus_grp_id: '|| p_bus_grp_id);
     hr_utility.trace('  p_payroll_id: '||p_payroll_id);
     hr_utility.trace('  p_tax_unit_id: '||p_tax_unit_id);
     hr_utility.trace('  p_asst_work_schedule: '||p_asst_work_schedule);
     hr_utility.trace('  p_asst_std_hours: '||p_asst_std_hours);
     hr_utility.trace('  p_figure: '||p_figure);
     hr_utility.trace('  p_from_freq : '||p_from_freq);
     hr_utility.trace('  p_to_freq: '||p_to_freq);
     hr_utility.trace('  p_period_start_date: '||p_period_start_date);

     hr_utility.trace('  p_period_end_date: '||p_period_end_date);
     hr_utility.trace('  p_asst_std_freq: '||p_asst_std_freq);

     --
     -- If From_Freq and To_Freq are the same, then we're done.
     --

     IF NVL(p_from_freq, 'NOT ENTERED') = NVL(p_to_freq, 'NOT ENTERED')
     THEN

        RETURN p_figure;

     END IF;

     hr_utility.trace('Calling Get_Annualizing_Factor for FROM case');

     v_from_annualizing_factor := Get_Annualizing_Factor(
                                    p_bg               => p_bus_grp_id,
                                    p_payroll          => p_payroll_id,
                                    p_txu_id           => p_tax_unit_id,
                                    p_freq             => p_from_freq,
                                    p_asg_work_sched   => p_asst_work_schedule,
                                    p_asg_std_hrs      => p_asst_std_hours,
                                    p_asg_std_freq     => p_asst_std_freq);

     hr_utility.trace('Calling Get_Annualizing_Factor for TO case');

     v_to_annualizing_factor := Get_Annualizing_Factor(
                                    p_bg               => p_bus_grp_id,
                                    p_payroll          => p_payroll_id,
                                    p_txu_id           => p_tax_unit_id,
                                    p_freq             => p_to_freq,
                                    p_asg_work_sched   => p_asst_work_schedule,
                                    p_asg_std_hrs      => p_asst_std_hours,
                                    p_asg_std_freq     => p_asst_std_freq);

     --
     -- Annualize "Figure" and convert to To_Freq.
     --

     hr_utility.trace('v_from_annualizing_factor ='||
                              to_char(v_from_annualizing_factor));
     hr_utility.trace('v_to_annualizing_factor ='||
                              to_char(v_to_annualizing_factor));

     IF v_to_annualizing_factor = 0        OR
        v_to_annualizing_factor = -999     OR
        v_from_annualizing_factor = -999
     THEN

        hr_utility.trace(' v_to_ann =0 or -999 or v_from = -999');

        v_converted_figure := 0;

     ELSE

        hr_utility.trace(' v_to_ann NOT 0 or -999 or v_from = -999');

        hr_utility.trace('p_figure Monthly Salary = '||p_figure);
        hr_utility.trace('v_from_annualizing_factor = '||
                                 v_from_annualizing_factor);
        hr_utility.trace('v_to_annualizing_factor   = '||
                                 v_to_annualizing_factor);

        v_converted_figure :=
             (p_figure * v_from_annualizing_factor) / v_to_annualizing_factor;

        hr_utility.trace('conv figure is monthly_sal * ann_from div by ann to');

     END IF;


      hr_utility.trace('UDFS v_converted_figure := '||v_converted_figure);

      --hr_utility.trace_off;

      RETURN v_converted_figure;

   END Convert_Period_Type;

--
-- **********************************************************************
--

   FUNCTION Work_Sch_Total_Hours_or_Days( p_bg_id          in NUMBER
                                         ,p_ws_name        in VARCHAR2
                                         ,p_range_start    in DATE
                                         ,p_range_end      in DATE
                                         ,p_mode           in VARCHAR2 )
   RETURN NUMBER IS

     -- local constants

     c_ws_tab_name        VARCHAR2(80)        ;

     -- local variables

     v_total_units    NUMBER(15,7);
     v_unit           NUMBER(15,7);
     v_week_work_days NUMBER(15,7);
     v_range_start    DATE;
     v_range_end      DATE;
     v_curr_date      DATE;
     v_curr_day       VARCHAR2(3);        -- 3 char abbrev for day of wk.
     v_ws_name        VARCHAR2(80);        -- Work Schedule Name.
     v_gtv_hours      VARCHAR2(80);        -- get_table_value returns varchar2
                     -- Remember to FND_NUMBER.CANONICAL_TO_NUMBER result.
     v_fnd_sess_row   VARCHAR2(1);
     l_exists         VARCHAR2(1);
     v_day_no         NUMBER;

   BEGIN -- Work_Sch_Total_Hours_or_Days

     --hr_utility.trace_on(null,'UDFS');
     hr_utility.trace('p_bg_id '||p_bg_id);
     hr_utility.trace('p_ws_name '||p_ws_name);
     hr_utility.trace('p_range_start '||p_range_start);
     hr_utility.trace('p_range_end '||p_range_end);
     hr_utility.trace('p_mode '||p_mode);

     /* Init */

     v_total_units  := 0;
     c_ws_tab_name  := 'COMPANY WORK SCHEDULES';

     -- Changed to select the work schedule defined
     -- at the Organization level the default work
     -- schedule (COMPANY WORK SCHEDULES ) to the
     -- variable  c_ws_tab_name

     BEGIN
       SELECT put.user_table_name
       INTO   c_ws_tab_name
       FROM   hr_organization_information hoi
             ,pay_user_tables put
      WHERE   hoi.organization_id         = p_bg_id
        AND   hoi.org_information_context = 'Work Schedule'
        AND   hoi.org_information1        = put.user_table_id ;

       EXCEPTION WHEN no_data_found THEN
           null;
     END;


     v_range_start := NVL(p_range_start, sysdate);
     v_range_end   := NVL(p_range_end, sysdate + 6);

     IF v_range_start > v_range_end THEN
        --
        RETURN v_total_units;
        --
     END IF;

     --
     -- Get_Table_Value requires row in FND_SESSIONS.  We must insert this
     -- record if one doe not already exist.
     --

     SELECT  DECODE(COUNT(session_id), 0, 'N', 'Y')
     INTO    v_fnd_sess_row
     FROM    fnd_sessions
     WHERE   session_id      = userenv('sessionid');

     --

     IF v_fnd_sess_row = 'N' THEN

        dt_fndate.set_effective_date(trunc(sysdate));

     END IF;

     --
     -- Track range dates:
     --
     -- Check if the work schedule is an id or a name.  If the work
     -- schedule does not exist, then return 0.
     --
     BEGIN

       SELECT 'Y'
       INTO   l_exists
       FROM   pay_user_tables put,
              pay_user_columns puc
       WHERE  puc.user_column_name                 = p_ws_name
       AND    nvl(puc.business_group_id, p_bg_id)  = p_bg_id
       AND    nvl(puc.legislation_code,'MX')       = 'MX'
       AND    puc.user_table_id                    = put.user_table_id
       AND    put.user_table_name                  = c_ws_tab_name;


       EXCEPTION WHEN no_data_found THEN
                 NULL;

     END;

     IF l_exists = 'Y' then
        v_ws_name := p_ws_name;
     ELSE

        BEGIN
          SELECT puc.user_column_name
          INTO   v_ws_name
          FROM   pay_user_tables put,
                 pay_user_columns puc
          WHERE  puc.user_column_id                  = p_ws_name
          AND    nvl(puc.business_group_id, p_bg_id) = p_bg_id
          AND    nvl(puc.legislation_code,'MX')      = 'MX'
          AND    puc.user_table_id                   = PUT.user_table_id
          AND    put.user_table_name                 = c_ws_tab_name;


          EXCEPTION WHEN NO_DATA_FOUND THEN
                     RETURN v_total_units;
        END;

     END IF;

     --

     v_curr_date := v_range_start;

     --
     --
     LOOP

       v_day_no := TO_CHAR(v_curr_date, 'D');


       SELECT decode(v_day_no,1,'SUN',2,'MON',3,'TUE',
                                  4,'WED',5,'THU',6,'FRI',7,'SAT')
       INTO v_curr_day
       FROM DUAL;

       --
       --

       v_unit := FND_NUMBER.CANONICAL_TO_NUMBER(
                            hruserdt.get_table_value(p_bg_id
                                                    ,c_ws_tab_name
                                                    ,v_ws_name
                                                    ,v_curr_day));

       /***********************************************************
       ** Consider 1 day when v_unit is non zero FOR Days X Rate
       ** i.e. p_mode = DAYS
       ***********************************************************/

       IF p_mode = 'DAYS' AND v_unit <> 0 THEN

          v_unit := 1;

       END IF;

       v_total_units := v_total_units + v_unit;

        hr_utility.trace('v_day_no '||v_day_no);
        hr_utility.trace('v_unit '||v_unit);
        hr_utility.trace('v_total_units '||v_total_units);

       v_curr_date := v_curr_date + 1;

       --
       --

       EXIT WHEN v_curr_date > v_range_end;

       --

     END LOOP;

     --

     --hr_utility.trace_off;

     RETURN v_total_units;

     --

   END Work_Sch_Total_Hours_or_Days;


   FUNCTION Work_Sch_Total_Hours_or_Days( p_bg_id          in NUMBER,
                                          p_ws_name        in VARCHAR2,
                                          p_range_start    in DATE,
                                          p_range_end      in DATE)
   RETURN NUMBER IS

     ln_days number;

   BEGIN --Work_Sch_Total_Hours_or_Days

     ln_days:=  Work_Sch_Total_Hours_or_Days( p_bg_id       => p_bg_id
                                             ,p_ws_name     => p_ws_name
                                             ,p_range_start => p_range_start
                                             ,p_range_end   => p_range_end
                                             ,p_mode        => 'HOURS' );

     RETURN ln_days;

   END Work_Sch_Total_Hours_or_Days;

----------
/* new get_idw overloaded function with new context payroll_action id.
   Added new parameter p_execute_old_idw_code to control the new logic and old logic of
   get_idw function, if this parameter value is 'Y' then the code check for the
   'variable IDW' and 'var expirtation date' which is entered manually, if the value is 'N'
   code behave normally with old logic and it doesn't check for the manual input values.

 */

FUNCTION get_idw(p_assignment_id  per_all_assignments_f.assignment_id%TYPE,
                  p_tax_unit_id    hr_organization_units.organization_id%TYPE,
                  p_effective_date DATE,
                  p_payroll_action_id NUMBER,
                  p_mode           VARCHAR2,
                  p_fixed_idw      OUT NOCOPY NUMBER,
                  p_variable_idw   OUT NOCOPY NUMBER,
		  p_execute_old_idw_code           VARCHAR2)
RETURN NUMBER IS

ln_idw NUMBER;
ln_variable_idw NUMBER;
ln_date_paid DATE;
ln_var_expiration_date DATE;

CURSOR c_get_var_expiration_date (cp_asg_id pay_element_entries_f.assignment_id%TYPE,
                                  cp_eff_date DATE)
IS
select nvl(FND_DATE.CANONICAL_TO_DATE(pev.SCREEN_ENTRY_VALUE),hr_general.end_of_time)
from pay_element_types_f pet,
     pay_input_values_f  piv,
     pay_element_entries_f pee,
     pay_element_entry_values_f pev
where pet.element_name='Integrated Daily Wage'
and  piv.element_type_id = pet.element_type_id
and  piv.name ='Var Expiration Date'
and  pee.element_type_id = pet.element_type_id
and  pee.assignment_id = cp_asg_id
and  pev.element_entry_id = pee.element_entry_id
and  pev.input_value_id = piv.input_value_id
and  cp_eff_date between pet.effective_start_date and pet.effective_end_date
and  cp_eff_date between piv.effective_start_date and piv.effective_end_date
and  cp_eff_date between pee.effective_start_date and pee.effective_end_date
and  cp_eff_date between pev.effective_start_date and pev.effective_end_date ;


CURSOR c_get_variable_idw_value (cp_asg_id pay_element_entries_f.assignment_id%TYPE,
                                  cp_eff_date DATE)
IS
select nvl(FND_NUMBER.CANONICAL_TO_NUMBER(pev.SCREEN_ENTRY_VALUE),0)
from pay_element_types_f pet,
     pay_input_values_f  piv,
     pay_element_entries_f pee,
     pay_element_entry_values_f pev
where pet.element_name='Integrated Daily Wage'
and  piv.element_type_id = pet.element_type_id
and  piv.name ='Variable IDW'
and  pee.element_type_id = pet.element_type_id
and  pee.assignment_id = cp_asg_id
and  pev.element_entry_id = pee.element_entry_id
and  pev.input_value_id = piv.input_value_id
and  cp_eff_date between pet.effective_start_date and pet.effective_end_date
and  cp_eff_date between piv.effective_start_date and piv.effective_end_date
and  cp_eff_date between pee.effective_start_date and pee.effective_end_date
and  cp_eff_date between pev.effective_start_date and pev.effective_end_date ;

BEGIN
  IF p_execute_old_idw_code = 'Y' THEN

    ln_idw := get_idw( p_assignment_id  => p_assignment_id
                      ,p_tax_unit_id    => p_tax_unit_id
                      ,p_effective_date => p_effective_date
                      ,p_mode           => p_mode
                      ,p_fixed_idw      => p_fixed_idw
                      ,p_variable_idw   => p_variable_idw );


        IF p_payroll_action_id IS NOT NULL THEN
           ln_date_paid := get_date_paid(p_payroll_action_id);

            IF ln_date_paid is null then
            ln_date_paid := p_effective_date;
            END IF;
        ELSE
            ln_date_paid := p_effective_date;
        END IF;
--
   /*get the value for Variable IDW input value which has entered manually*/

            OPEN c_get_variable_idw_value (p_assignment_id,
                                            p_effective_date );
            FETCH c_get_variable_idw_value INTO ln_variable_idw;
            hr_utility.trace('ln_variable_idw  '|| ln_variable_idw);

            CLOSE c_get_variable_idw_value ;
   /* get the value for var_expiration_date input value */

       IF ln_variable_idw > 0 THEN
            OPEN c_get_var_expiration_date (p_assignment_id,
                                            p_effective_date );
            FETCH c_get_var_expiration_date INTO ln_var_expiration_date;
            hr_utility.trace('ln_var_expiration_date  '|| ln_var_expiration_date);

            CLOSE c_get_var_expiration_date ;
--

         IF   ln_var_expiration_date > ln_date_paid then
           ln_idw := ln_idw - p_variable_idw + ln_variable_idw;
           hr_utility.trace('ln_idw  300 '|| ln_idw);
           hr_utility.trace('p_variable_idw 300 '|| p_variable_idw);
           hr_utility.trace('ln_variable_idw '|| ln_variable_idw);
           p_variable_idw := ln_variable_idw;
         END IF;
           hr_utility.trace('p_variable_idw 310 '|| p_variable_idw);
           hr_utility.trace('p_fixed_idw    310 '|| p_fixed_idw);
           hr_utility.trace('ln_idw 310 '|| ln_idw);
           hr_utility.trace('ln_var_expiration_date 310 '|| ln_var_expiration_date);
           hr_utility.trace('ln_date_paid 310 '|| ln_date_paid);
       END IF;
     ELSE

     /* old logic of get_idw executes here if p_execute_old_idw_code not equal to 'Y' */

         ln_idw := get_idw( p_assignment_id  => p_assignment_id
                      ,p_tax_unit_id    => p_tax_unit_id
                      ,p_effective_date => p_effective_date
                      ,p_mode           => p_mode
                      ,p_fixed_idw      => p_fixed_idw
                      ,p_variable_idw   => p_variable_idw );

     END IF; /*p_execute_old_idw_code */

     return ln_idw;
   --
END; /* get_idw */

/* old get_idw function */
----------
FUNCTION get_idw (p_assignment_id  per_all_assignments_f.assignment_id%TYPE,
                  p_tax_unit_id    hr_organization_units.organization_id%TYPE,
                  p_effective_date DATE,
                  p_mode           VARCHAR2,
                  p_fixed_idw      OUT NOCOPY NUMBER,
                  p_variable_idw   OUT NOCOPY NUMBER)
RETURN NUMBER IS

CURSOR c_get_all_assignments
IS
SELECT a.assignment_id,
       a.soft_coding_keyflex_id,
       a.location_id,
       a.payroll_id,
       a.business_group_id,
       a.person_id
FROM per_all_assignments_f a,
     per_all_assignments_f b
WHERE b.person_id = a.person_id
AND   b.assignment_id = p_assignment_id
AND   p_effective_date BETWEEN a.effective_start_date
                       AND     a.effective_end_date
AND   p_effective_date BETWEEN b.effective_start_date
                       AND     b.effective_end_date;

CURSOR
c_get_last_idw_action(cp_asg_id pay_assignment_actions.assignment_id%TYPE,
                      cp_idw_report_date DATE,
                      cp_idw_start_date DATE) IS
SELECT assignment_action_id
FROM pay_assignment_actions aa,
     pay_payroll_actions pa
WHERE assignment_id = cp_asg_id
AND   tax_unit_id = p_tax_unit_id
/*Bug#9386250,9495744 : Changes start here*/
AND   pa.action_type IN ('R','Q')
AND   (pa.run_type_id is NULL OR aa.source_action_id IS NOT NULL)
/*Bug#9386250:Changes end here*/
AND   aa.payroll_action_id = pa.payroll_action_id
AND   pa.effective_date BETWEEN cp_idw_start_date AND cp_idw_report_date
ORDER BY aa.action_sequence desc;

-- cursor to get the IDW Calc method
CURSOR c_get_idw_calc_method (cp_org_id hr_organization_units.organization_id%TYPE,
                              cp_eff_date DATE )
IS
select hoi.org_information10
from hr_organization_units hou,
     hr_organization_information hoi
where hou.organization_id = cp_org_id
and hoi.org_information_context ='MX_SOC_SEC_DETAILS'
and hou.organization_id = hoi.organization_id
and cp_eff_date between hou.date_from and nvl(hou.date_to,cp_eff_date) ;

-- cursor to get the IDW factor table name
CURSOR c_get_idw_factor_tab_name (cp_asg_id pay_element_entries_f.assignment_id%TYPE,
                                  cp_eff_date DATE )
IS
select hrl.lookup_code
      ,hrl.meaning
from pay_element_types_f pet,
     pay_input_values_f  piv,
     pay_element_entries_f pee,
     pay_element_entry_values_f pev,
     hr_lookups hrl
where pet.element_name='Integrated Daily Wage'
and  piv.element_type_id = pet.element_type_id
and  piv.name ='IDW Factor Table'
and  pee.element_type_id = pet.element_type_id
and  pee.assignment_id = cp_asg_id
and  pev.element_entry_id = pee.element_entry_id
and  pev.input_value_id = piv.input_value_id
and  hrl.lookup_type = 'MX_IDW_FACTOR_TABLES'
and  hrl.lookup_code = pev.screen_entry_value
and  cp_eff_date between pet.effective_start_date and pet.effective_end_date
and  cp_eff_date between piv.effective_start_date and piv.effective_end_date
and  cp_eff_date between pee.effective_start_date and pee.effective_end_date
and  cp_eff_date between pev.effective_start_date and pev.effective_end_date ;

CURSOR c_idw_user_table_check( cp_idw_user_table_name IN VARCHAR2 ) IS
SELECT 'Y'
FROM   pay_user_tables
WHERE  user_table_name = cp_idw_user_table_name;

CURSOR c_idw_factor_table_US ( cp_idw_lookup_code IN VARCHAR2 ) IS
SELECT meaning
FROM   fnd_lookup_values flv
WHERE  flv.lookup_type = 'MX_IDW_FACTOR_TABLES'
AND    flv.lookup_code = cp_idw_lookup_code
AND    flv.language    = 'US';

lv_idw_user_table_found VARCHAR2(80);
lv_idw_factor_table_US  VARCHAR2(240);

rn_idw                 NUMBER;
ln_rate                NUMBER;
ln_variable_idw        NUMBER;
ln_last_idw_action     pay_assignment_actions.assignment_action_id%TYPE;
ln_asg_tuid            pay_assignment_actions.tax_unit_id%TYPE;
ln_idw_ele_id          pay_element_types_f.element_type_id%TYPE;
ln_idw_inp_id          pay_input_values_f.input_value_id%TYPE;
lb_gre_ambiguous       BOOLEAN;
lb_gre_missing         BOOLEAN;
lv_period_type         pay_all_payrolls_f.period_type%TYPE;
lv_contract_name       VARCHAR2(240);
ld_idw_report_date     DATE;
ld_idw_start_date      DATE;

lv_idw_calc_method     VARCHAR2(30);
lv_idw_factor_tab_name VARCHAR2(80);
lv_idw_lookup_code     VARCHAR2(80);
ld_adj_svc_date        DATE ;
ld_seniority_from      DATE ;
ln_seniority_years     NUMBER;
ln_idw_factor          NUMBER;
ln_basepay_rate        NUMBER;
lv_basepay_rate_name   hr_lookups.meaning%TYPE;
lv_fixedidw_rate_name  hr_lookups.meaning%TYPE;

FUNCTION get_fixed_idw (p_asg_id  per_all_assignments_f.assignment_id%TYPE,
                        p_calculation_date DATE,
                        p_name VARCHAR2,
                        p_contract_name VARCHAR2)
RETURN NUMBER IS

ln_retstat NUMBER;
rn_rate    NUMBER;
lv_err_mesg  VARCHAR2(240);
BEGIN
   rn_rate := pqp_rates_history_calc.get_historic_rate(
                    p_assignment_id              => p_asg_id,
                    p_rate_name                  => p_name,
                    p_effective_date             => p_calculation_date,
                    p_time_dimension             => 'D',
                    p_rate_type_or_element       => 'R',
                    p_contract_type              => p_contract_name);


   RETURN rn_rate;

EXCEPTION WHEN OTHERS
THEN
   hr_utility.raise_error;
   RETURN rn_rate;
END get_fixed_idw;

BEGIN
--{
   rn_idw := 0;
   p_fixed_idw := 0;
   p_variable_idw := 0;
   FOR asg_rec in c_get_all_assignments
   LOOP
   --{
      ln_asg_tuid := NULL;
      ln_asg_tuid :=
                 hr_mx_utility.get_gre_from_scl(
                    p_soft_coding_keyflex_id => asg_rec.soft_coding_keyflex_id);

      IF (ln_asg_tuid IS NULL)
      THEN
      --{
         -- Bug 4129001 - Added p_business_group_id parameter
         --
         ln_asg_tuid := hr_mx_utility.get_gre_from_location(
                           p_location_id       => asg_rec.location_id,
                           p_business_group_id => asg_rec.business_group_id,
                           p_session_date      => p_effective_date,
                           p_is_ambiguous      => lb_gre_ambiguous,
                           p_missing_gre       => lb_gre_missing);

         IF (lb_gre_ambiguous = TRUE OR lb_gre_missing = TRUE)
         THEN
         --{
            ln_asg_tuid := NULL;
         --}
         END IF;
      --}
      END IF;
      IF (ln_asg_tuid = p_tax_unit_id)
      THEN
      --{

         --
         -- IDW Factor Table Method Modification
         --
         -- Get the idw calc method
         hr_utility.trace('Get IDW Calc Method ');
         hr_utility.trace('p_tax_unit_id ='||to_char(p_tax_unit_id));
         hr_utility.trace('p_effective_date ='||to_char(p_effective_date));

         lv_idw_calc_method := 'A';
         OPEN c_get_idw_calc_method (p_tax_unit_id,
                                     p_effective_date );
         FETCH c_get_idw_calc_method INTO lv_idw_calc_method;
         CLOSE c_get_idw_calc_method;

         hr_utility.trace('lv_idw_calc_method = '|| nvl(lv_idw_calc_method,'null'));

         IF lv_idw_calc_method is null or lv_idw_calc_method ='A' then

            hr_utility.trace('calculating using Method A Earnings Method' );

            -- calculate using Method A Earnings Method
            ln_rate := 0;
            ln_rate := get_mx_historic_rate (
                           p_business_group_id  => asg_rec.business_group_id
                          ,p_assignment_id      => asg_rec.assignment_id
                          ,p_tax_unit_id        => p_tax_unit_id
                          ,p_payroll_id         => asg_rec.payroll_id
                          ,p_effective_date     => p_effective_date
                          ,p_rate_code          => 'MX_IDWF' );

         ELSIF lv_idw_calc_method ='B' then

            hr_utility.trace('calculating using Method B Factor Table Method' );
            hr_utility.trace('Get IDW Factor Table Name' );
            hr_utility.trace('assignment_id  ='||to_char(asg_rec.assignment_id));

            -- calculate using Method B IDW Factor Method
            -- Get the IDW Factor table name entered in
            -- Integrated Daily Wage element
            OPEN c_get_idw_factor_tab_name (asg_rec.assignment_id,
                                            p_effective_date );
            FETCH c_get_idw_factor_tab_name INTO lv_idw_lookup_code
                                                ,lv_idw_factor_tab_name;
            CLOSE c_get_idw_factor_tab_name ;

            hr_utility.trace('lv_idw_factor_tab_name='||lv_idw_factor_tab_name);

            IF lv_idw_factor_tab_name is null then
               --hr_utility.raise_error;
               RETURN rn_idw;
            END IF;

            -- Check user table exists or not for lv_idw_factor_tab_name
            -- if exists then use lv_idw_factor_tab_name otherwise
            -- get idw factor table name fnd_lookups for 'US' languge
            -- Return 0 if idw factor table for 'US' not exists

            lv_idw_user_table_found := 'N';

            OPEN  c_idw_user_table_check( lv_idw_factor_tab_name );
            FETCH c_idw_user_table_check INTO lv_idw_user_table_found;
            CLOSE c_idw_user_table_check;

            IF lv_idw_user_table_found = 'N' THEN

               lv_idw_factor_table_US := NULL;

               OPEN  c_idw_factor_table_US( lv_idw_lookup_code );
               FETCH c_idw_factor_table_US INTO lv_idw_factor_table_US;
               CLOSE c_idw_factor_table_US;


               IF lv_idw_factor_table_US IS NOT NULL THEN

                  lv_idw_factor_tab_name := lv_idw_factor_table_US;

               ELSE

                  -- Incorrect setup as IDW Factor Table is not found
                  -- in US English or Spanish or any other language

                  RETURN rn_idw;

               END IF;

            END IF;

            -- get the seniority
            hr_utility.trace('Get Seniority' );

            ln_seniority_years := hr_mx_utility.get_seniority_social_security(
                                      p_person_id      => asg_rec.person_id
                                     ,p_effective_date => p_effective_date);

            hr_utility.trace('ln_seniority_years = '||ln_seniority_years);

            -- get the FACTOR from the table
            -- by passing seniority years,
	    -- Added fnd_number.canonical_to_number for bug 6815180
            ln_idw_factor := FND_NUMBER.CANONICAL_TO_NUMBER(hruserdt.get_table_value(
                             p_bus_group_id   => asg_rec.business_group_id,
                             p_table_name     => lv_idw_factor_tab_name,
                             p_col_name       => 'Factor',
                             p_row_value      => ln_seniority_years,
                             p_effective_date => p_effective_date));

            hr_utility.trace('ln_idw_factor = '||to_char(ln_idw_factor));

            hr_utility.trace('Get Base Pay ');
            hr_utility.trace('lv_contract_name =' || lv_contract_name );

            -- Get the Base Pay using historic rates
            ln_basepay_rate := 0;
            ln_basepay_rate := get_daily_base_pay (
                           p_business_group_id  => asg_rec.business_group_id
                          ,p_assignment_id      => asg_rec.assignment_id
                          ,p_tax_unit_id        => p_tax_unit_id
                          ,p_payroll_id         => asg_rec.payroll_id
                          ,p_effective_date     => p_effective_date);


            hr_utility.trace('ln_basepay_rate = '||to_char(ln_basepay_rate));

            -- Calculate the fixed portion of idw
            ln_rate := ln_basepay_rate * ln_idw_factor ;

            hr_utility.trace('fixed portion of idw ln_rate = '||to_char(ln_rate));

         END IF ; -- lv_idw_calc_method

         p_fixed_idw := p_fixed_idw + ln_rate;
         rn_idw := rn_idw + ln_rate;

         IF (p_mode LIKE '%REPORT')
         THEN
         --{
            SELECT
            DECODE(p_mode,
                   'REPORT',
                       ADD_MONTHS(TRUNC(p_effective_date, 'Y'),
                       TO_CHAR(p_effective_date, 'MM') -
                       DECODE(MOD(TO_NUMBER(TO_CHAR(p_effective_date,'MM')),2),
                              1, 1,
                              0, 2)
                              ) - 1,
                   'BIMONTH_REPORT',
                       p_effective_date)
            INTO ld_idw_report_date
            FROM DUAL;

            SELECT ADD_MONTHS(ld_idw_report_date, -2) + 1
              INTO ld_idw_start_date
            FROM DUAL;

            ln_last_idw_action := -1;

            OPEN  c_get_last_idw_action(asg_rec.assignment_id,
                                        ld_idw_report_date,
                                        ld_idw_start_date);

            FETCH c_get_last_idw_action
            INTO ln_last_idw_action;
            CLOSE c_get_last_idw_action;

            IF (ln_last_idw_action <> -1)
            THEN
            --{
               ln_idw_ele_id := -1;
               ln_idw_inp_id := -1;
               SELECT iv.element_type_id,
                      input_value_id
               INTO ln_idw_ele_id,
                    ln_idw_inp_id
               FROM pay_element_types_f et,
                    pay_input_values_f iv
               WHERE element_name = 'Integrated Daily Wage'
               AND   et.legislation_code = 'MX'
               AND   p_effective_date BETWEEN et.effective_start_date
                                      AND     et.effective_end_date
               AND   et.element_type_id = iv.element_type_id
               AND   iv.name = 'Variable IDW'
               AND   p_effective_date BETWEEN iv.effective_start_date
                                      AND     iv.effective_end_date;
               BEGIN

                  ln_variable_idw := 0;
                  SELECT fnd_number.canonical_to_number(result_value)
                  INTO ln_variable_idw
                  FROM pay_run_result_values rrv,
                       pay_run_results rr
                  WHERE assignment_action_id = ln_last_idw_action
                  AND element_type_id = ln_idw_ele_id
                  AND rr.run_result_id = rrv.run_result_id
                  AND rrv.input_value_id = ln_idw_inp_id;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  /*
                   * This can happen when earnings that contribute to
                   * Variable IDW have never been processed for a person
                   */
                  NULL;
               END;

               rn_idw := rn_idw + ln_variable_idw;
               p_variable_idw := p_variable_idw + ln_variable_idw;
            --}
            END IF;
         --}
         ELSIF (p_mode = 'CALC')
         THEN
         --{
            p_variable_idw := 0;
         --}
         END IF;
      --}
      END IF;
   --}
   END LOOP;

   /*
    * Need to maintain IDW accuracy up to 2 decimal places - Bug 4434889
    */
   p_variable_idw := round(p_variable_idw, 2);
   p_fixed_idw := round(p_fixed_idw, 2);
   RETURN round(rn_idw, 2);
--}

  EXCEPTION
    WHEN others THEN
      RAISE;

END get_idw;

  FUNCTION get_mx_historic_rate (
                     p_business_group_id          NUMBER
                    ,p_assignment_id              NUMBER
                    ,p_tax_unit_id                NUMBER
                    ,p_payroll_id                 NUMBER
                    ,p_effective_date             DATE
                    ,p_rate_code                  VARCHAR2)
  RETURN NUMBER IS

    /*
     * Cursor to get Rate Name based on Code
     */
    CURSOR c_get_rate_name(cp_lookup_code VARCHAR2) IS
    SELECT meaning
    FROM   hr_lookups
    WHERE  lookup_type = 'PQP_RATE_TYPE'
    AND    lookup_code = cp_lookup_code;

    lv_rate_name       VARCHAR2(240);
    lv_contract_name   VARCHAR2(240);
    ln_rate            NUMBER;

    PROCEDURE clean_dupl_user_table_rows ( p_user_table_name IN VARCHAR2
                                          ,p_row_value       IN VARCHAR2)
    IS

      CURSOR c_usr_tbl_rows ( cp_contract_name   VARCHAR2
                             ,cp_user_table_id   NUMBER)  IS
        SELECT user_row_id
          FROM pay_user_rows_f
         WHERE row_low_range_or_name = cp_contract_name
           AND user_table_id         = cp_user_table_id
         ORDER BY user_row_id;


      ln_user_table_id NUMBER;
      ln_count         NUMBER;
      i                NUMBER;

    BEGIN

       SELECT user_table_id
         INTO ln_user_table_id
         FROM pay_user_tables
        WHERE user_table_name = p_user_table_name
          AND ( legislation_code is NULL OR
                legislation_code = 'MX');

       SELECT count(*)
         INTO ln_count
         FROM pay_user_rows_f
        WHERE row_low_range_or_name = p_row_value
          AND user_table_id         = ln_user_table_id;


       IF ln_count > 1 THEN

          i := 1;

          FOR rw in c_usr_tbl_rows( p_row_value, ln_user_table_id )
          LOOP

             IF ( i <> ln_count ) THEN

                DELETE pay_user_column_instances_f
                 WHERE user_row_id = rw.user_row_id;

                DELETE pay_user_rows_f
                 WHERE user_row_id = rw.user_row_id;

             END IF;

             i := i + 1;

          END LOOP;

       END IF;

    END clean_dupl_user_table_rows;

    PROCEDURE create_contract (p_business_group_id       IN NUMBER,
                               p_contract_name           IN VARCHAR2,
                               p_days_in_year            IN NUMBER,
                               p_exists                  IN BOOLEAN)
    IS

     TYPE user_col_rec is RECORD (
          col_name pay_user_columns.user_column_name%TYPE,
          value    pay_user_column_instances_f.value%TYPE);

     TYPE col_tab IS TABLE OF user_col_rec
                   INDEX BY BINARY_INTEGER;

     lt_col_det_tab col_tab;

     ld_eff_date         DATE;
     ld_eff_start_date   DATE;
     ld_eff_end_date     DATE;

     ln_user_table_id    pay_user_tables.user_table_id%TYPE;
     ln_usr_col_inst_id  pay_user_column_instances.user_column_instance_id%TYPE;
     ln_user_row_id      pay_user_rows_f.user_row_id%TYPE;
     ln_dsp_seq          pay_user_rows_f.display_sequence%TYPE;
     ln_user_column_id   pay_user_columns.user_column_id%TYPE;
     ln_ovn              NUMBER;

    BEGIN
    --{

       ld_eff_date := fnd_date.canonical_to_date('1900/01/01 00:00:00');

       lt_col_det_tab(1).col_name := 'Monthly Payroll Divisor';
       lt_col_det_tab(1).value    := 12;
       lt_col_det_tab(2).col_name := 'Weekly Payroll Divisor';
       lt_col_det_tab(2).value    := 52;
       lt_col_det_tab(3).col_name := 'Days Divisor';
       lt_col_det_tab(3).value    := p_days_in_year;
       lt_col_det_tab(4).col_name := 'Annual Hours';
       lt_col_det_tab(4).value    := p_days_in_year * 8;

       SELECT user_table_id
       INTO ln_user_table_id
       FROM pay_user_tables
       WHERE user_table_name = 'PQP_CONTRACT_TYPES'
       AND (legislation_code is NULL
            OR legislation_code = 'MX');

       IF (p_exists = FALSE)
       THEN
       --{
          SELECT NVL(max(display_sequence), 0)+1
          INTO ln_dsp_seq
          FROM pay_user_rows_f
          WHERE user_table_id = ln_user_table_id;

          pay_user_row_api.create_user_row(
   	         p_validate              => FALSE,
                 p_effective_date        => ld_eff_date,
                 p_user_table_id         => ln_user_table_id,
                 p_row_low_range_or_name => p_contract_name,
                 p_display_sequence      => ln_dsp_seq,
                 p_business_group_id     => p_business_group_id,
                 p_legislation_code      => NULL,
                 p_disable_range_overlap_check => FALSE,
                 p_disable_units_check   => FALSE,
                 p_row_high_range        => NULL,
                 p_user_row_id           => ln_user_row_id,
                 p_object_version_number => ln_ovn,
                 p_effective_start_date  => ld_eff_start_date,
                 p_effective_end_date    => ld_eff_end_date,
		 p_base_row_low_range_or_name => p_contract_name);
       --}
       ELSE
       --{
            SELECT user_row_id
            INTO ln_user_row_id
            FROM pay_user_rows_f
            WHERE row_low_range_or_name = p_contract_name
            AND   user_table_id = ln_user_table_id
            AND   ROWNUM = 1;

            DELETE pay_user_column_instances_f
            WHERE user_row_id = ln_user_row_id;

       --}
       END IF;


       FOR i in lt_col_det_tab.FIRST..lt_col_det_tab.LAST
       LOOP
       --{
          SELECT user_column_id
          INTO ln_user_column_id
          FROM pay_user_columns
          WHERE user_table_id = ln_user_table_id
          AND   user_column_name = lt_col_det_tab(i).col_name;

          pay_user_column_instance_api.create_user_column_instance(
                   p_effective_date => ld_eff_date,
                   p_user_row_id    => ln_user_row_id,
                   p_user_column_id => ln_user_column_id,
                   p_value          => lt_col_det_tab(i).value,
                   p_business_group_id => p_business_group_id,
                   p_user_column_instance_id => ln_usr_col_inst_id,
                   p_object_version_number   => ln_ovn,
                   p_effective_start_date    => ld_eff_start_date,
                   p_effective_end_date      => ld_eff_end_date);
       --}
       END LOOP;
    --}
    END create_contract;

    FUNCTION get_contract_name(p_business_group_id  NUMBER,
                               p_tax_unit_id        NUMBER,
                               p_payroll_id         NUMBER,
                               p_calculation_date   DATE)

    RETURN VARCHAR2 IS

    ln_days_year         NUMBER;
    ln_days_month        NUMBER;
    ln_legal_emp_id      hr_all_organization_units.organization_id%TYPE;
    ln_contract_days     pay_user_column_instances_f.value%TYPE;

    lv_period_type       pay_all_payrolls_f.period_type%TYPE;
    rv_contract_name     VARCHAR2(80);

    lb_contract_exists   BOOLEAN;
    BEGIN
    --{

       lb_contract_exists := TRUE;
      hr_utility.trace('Entering pay_mx_ff_udfs.get_contract_name');
       pay_mx_utility.get_no_of_days_for_org(
                         p_business_group_id => p_business_group_id,
                         p_org_id            => p_tax_unit_id,
                         p_gre_or_le         => 'GRE',
                         p_days_year         => ln_days_year,
                         p_days_month        => ln_days_month);


       IF (ln_days_year is NULL)
       THEN
       --{
          ln_legal_emp_id := hr_mx_utility.get_legal_employer(
                               p_business_group_id => p_business_group_id,
                               p_tax_unit_id => p_tax_unit_id);

          pay_mx_utility.get_no_of_days_for_org(
                            p_business_group_id => p_business_group_id,
                            p_org_id            => ln_legal_emp_id,
                            p_gre_or_le         => 'LE',
                            p_days_year         => ln_days_year,
                            p_days_month        => ln_days_month);

           hr_utility.trace('ln_days_year = '|| to_char(ln_days_year));
          IF (ln_days_year IS NULL)
          THEN
          --{
             SELECT period_type
             INTO lv_period_type
             FROM pay_all_payrolls_f ppf,
                  fnd_sessions fs
             WHERE payroll_id = p_payroll_id
             AND   fs.effective_date BETWEEN ppf.effective_start_date
                                     AND     ppf.effective_end_date
             AND   fs.session_id = USERENV('sessionid');

             IF (lv_period_type like '%Week%')
             THEN
             --{
                 rv_contract_name := 'IDW CALCULATION (WEEKLY PAYROLL)';
             --}
             ELSIF (lv_period_type like '%Month%')
             THEN
             --{
                 rv_contract_name := 'IDW CALCULATION (MONTHLY PAYROLL)';
             --}
             ELSIF (lv_period_type = 'Ten Days')
             THEN
             --{
                 rv_contract_name := 'IDW CALCULATION (Ten Days PAYROLL)';
             --}
             ELSE
             --{
                 hr_utility.raise_error;
             --}
             END IF;

          --}
          ELSE
          --{
             rv_contract_name := 'IDW CALCULATION (LE:'||
                                     TO_CHAR(ln_legal_emp_id)||')';
          --}
          END IF;
       --{
       ELSE
       --{
          rv_contract_name := 'IDW CALCULATION (GRE:'||
                                  TO_CHAR(p_tax_unit_id)||')';
       --}
       END IF;

       clean_dupl_user_table_rows( p_user_table_name => 'PQP_CONTRACT_TYPES'
                                  ,p_row_value       => rv_contract_name );

       BEGIN
       --{
          ln_contract_days := NULL;
          hr_utility.trace('Getting contract days..');
          ln_contract_days  := fnd_number.canonical_to_number(hruserdt.get_table_value(
                                  p_bus_group_id   => p_business_group_id,
                                  p_table_name     => 'PQP_CONTRACT_TYPES',
                                  p_col_name       => 'Days Divisor',
                                  p_row_value      => rv_contract_name,
                                  p_effective_date => p_calculation_date));
          hr_utility.trace('ln_contract_days = '|| TO_CHAR (ln_contract_days));
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          lb_contract_exists := FALSE;
       --}
       END;

       IF (lb_contract_exists = FALSE OR ln_contract_days <> ln_days_year)
       THEN
       --{
          create_contract(p_business_group_id => p_business_group_id,
                          p_contract_name     => rv_contract_name,
                          p_days_in_year      => ln_days_year,
                          p_exists            => lb_contract_exists);
       --}
       END IF;
     hr_utility.trace('leaving pay_mx_ff_udfs.get_contract_name');
       RETURN rv_contract_name;
    --}

    END get_contract_name;

  BEGIN

    OPEN  c_get_rate_name(p_rate_code);
    FETCH c_get_rate_name INTO lv_rate_name;
    CLOSE c_get_rate_name;

    lv_contract_name := get_contract_name(
                            p_business_group_id => p_business_group_id,
                            p_tax_unit_id       => p_tax_unit_id,
                            p_payroll_id        => p_payroll_id,
                            p_calculation_date  => p_effective_date);
     hr_utility.trace('before getting the rate from pqp..');
    ln_rate := pqp_rates_history_calc.get_historic_rate(
                    p_assignment_id              => p_assignment_id,
                    p_rate_name                  => lv_rate_name,
                    p_effective_date             => p_effective_date,
                    p_time_dimension             => 'D',
                    p_rate_type_or_element       => 'R',
                    p_contract_type              => lv_contract_name);
    hr_utility.trace('pqp_rates_history_calc.get_historic_rate');
    RETURN ln_rate;

    EXCEPTION
      WHEN others THEN
        RAISE;

  END get_mx_historic_rate;

  FUNCTION get_daily_base_pay ( p_business_group_id          NUMBER
                               ,p_assignment_id              NUMBER
                               ,p_tax_unit_id                NUMBER
                               ,p_payroll_id                 NUMBER
                               ,p_effective_date             DATE )
  RETURN NUMBER IS

    ln_daily_base_pay        NUMBER;

  BEGIN

    hr_utility.trace('Get Daily Base Pay ');

    -- Get the Base Pay using historic rates
    ln_daily_base_pay := 0;
    ln_daily_base_pay := get_mx_historic_rate (
                           p_business_group_id  => p_business_group_id
                          ,p_assignment_id      => p_assignment_id
                          ,p_tax_unit_id        => p_tax_unit_id
                          ,p_payroll_id         => p_payroll_id
                          ,p_effective_date     => p_effective_date
                          ,p_rate_code          => 'MX_BASE' );

    hr_utility.trace('ln_daily_base_pay = '||to_char(ln_daily_base_pay));

    RETURN ln_daily_base_pay;

    EXCEPTION
      WHEN others THEN
        RAISE;

  END get_daily_base_pay;

  FUNCTION get_base_pay_for_tax_calc ( p_business_group_id          NUMBER
                                      ,p_assignment_id              NUMBER
                                      ,p_tax_unit_id                NUMBER
                                      ,p_payroll_id                 NUMBER
                                      ,p_effective_date             DATE
                                      ,p_month_or_pay_period        VARCHAR2 )
  RETURN NUMBER IS

    ln_base_pay            NUMBER;
    ln_daily_base_pay      NUMBER;
    ln_days_in_a_month     NUMBER;
    lv_period_type         pay_all_payrolls_f.period_type%TYPE;

  BEGIN
    hr_utility.trace('Begin Get Base Pay for Tax Calculation');

    -- Get the Base Pay using historic rates
    ln_daily_base_pay := 0;
    ln_daily_base_pay := get_daily_base_pay (
                           p_business_group_id  => p_business_group_id
                          ,p_assignment_id      => p_assignment_id
                          ,p_tax_unit_id        => p_tax_unit_id
                          ,p_payroll_id         => p_payroll_id
                          ,p_effective_date     => p_effective_date);

    hr_utility.trace('ln_daily_base_pay = '||ln_daily_base_pay);

    IF p_month_or_pay_period = 'MONTH' THEN

       ln_days_in_a_month := pay_mx_utility.get_days_in_month(
                                 p_business_group_id => p_business_group_id
                                ,p_tax_unit_id       => p_tax_unit_id
                                ,p_payroll_id        => p_payroll_id);

       ln_base_pay := ln_daily_base_pay * ln_days_in_a_month;

    ELSE

       SELECT period_type
         INTO lv_period_type
         FROM pay_all_payrolls_f ppf,
             fnd_sessions fs
        WHERE payroll_id = p_payroll_id
          AND   fs.effective_date BETWEEN ppf.effective_start_date
                                  AND     ppf.effective_end_date
          AND   fs.session_id = USERENV('sessionid');

       IF lv_period_type = 'Week' THEN

          ln_base_pay := ln_daily_base_pay * 7;

       ELSIF lv_period_type = 'Bi-Week' THEN

          ln_base_pay := ln_daily_base_pay * 14;

       ELSIF lv_period_type = 'Calendar Month' THEN

          ln_days_in_a_month := pay_mx_utility.get_days_in_month(
                                    p_business_group_id => p_business_group_id
                                   ,p_tax_unit_id       => p_tax_unit_id
                                   ,p_payroll_id        => p_payroll_id);

          ln_base_pay := ln_daily_base_pay * ln_days_in_a_month;

       ELSIF lv_period_type = 'Semi-Month' THEN

          ln_base_pay := ln_daily_base_pay * 15;

       ELSIF lv_period_type = 'Ten Days' THEN

          ln_base_pay := ln_daily_base_pay * 10;

       END IF;


    END IF;

    hr_utility.trace('ln_base_pay = '|| ln_base_pay);
    hr_utility.trace('End Get Base Pay for Tax Calculation');

    RETURN ( ln_base_pay );

    EXCEPTION
      WHEN others THEN
        RAISE;
  END get_base_pay_for_tax_calc;

/* GET_PAY_DATE FUNCTION */
FUNCTION get_date_paid(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)

RETURN DATE IS
ln_date_paid  DATE ;

BEGIN

  SELECT effective_date
  INTO ln_date_paid from pay_payroll_actions
  WHERE payroll_action_id=p_payroll_action_id;


  hr_utility.trace('assignment date paid '||ln_date_paid);
  return ln_date_paid;
EXCEPTION
 WHEN OTHERS THEN
    hr_utility.trace('No paid date for assignment '||ln_date_paid );
    return null;
END; /* get_date_paid */

END pay_mx_ff_udfs;

/
