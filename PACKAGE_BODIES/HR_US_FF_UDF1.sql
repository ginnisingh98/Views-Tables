--------------------------------------------------------
--  DDL for Package Body HR_US_FF_UDF1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_FF_UDF1" AS
/* $Header: pyusudf1.pkb 120.49.12010000.32 2009/12/28 07:49:17 pbisht ship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : hr_us_ff_udf1
    Filename	: pyusudf1.pkb
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

    08-Aug-03   VMEHTA          115.5             Corrected the definition
                                                  (parameters) for
                                                  get_prev_ptd_values
    30-APR-04   TCLEWIS         115.6             Added functions
                                                  get_work_jurisdictions
                                                  and
                                                  Jurisdiction_processed
    07-JUL-04   TCLEWIS         115.9             Changed plsql tables to be
                                                  indexed by binary integer.
                                                  version 115.7 was leap
                                                  frogged to 115.9, so
                                                  implementd 115.7 change.
    02-AUN-04   TCLEWIS         115.10            ADDED GET_JD_PERCENT

    27-AUG-04   TCLEWIS         115.12            Added code to load the resident
                                                  jurisdiction to the Juridiction_code_tbl.
                                                  This is because when a person works and
                                                  lives in the same JD, we have to pass
                                                  both to vertex and vertex will determine
                                                  how to tax.
    23-SEP-04   FUSMAN          115.13  3909937   Changed the second cursor in function
                                                  get_prev_ptd_values to use
                                                  effective_date instead of date_earned.
    23-SEP-04   meshah          115.14  3909937   get_prev_ptd_values, made changes
    24-SEP-04   vmehta          115.15  3909937   get_prev_ptd_values, made
                                                  change to get full wages if
                                                  not processing home
                                                  jurisdiction (state), else get
                                                  only aggregate wages
    27-SEP-04   vmehta          115.16  3909937   Added a check for dates in
                                                  query for getting person
                                                  address.
    06-OCT-04   ppanda          115.17  3915176   Function GET_PRV_PTD_VALUES changed to
                                                  support previously withheld City, County
                                                  and School Dist Taxes
    27-DEC-04   ppanda          115.21  3861379   Rolled back the fix 3926044
                                                  For Georgia Supp SIT 3926044 fix cannot
                                                  be shipped
    09-APR-05   PPANDA         115.22   4241122   get_work_jurisdiction function
                                                  modified to support new value for
                                                  parameter p_INITIALIZE. Changes documented
                                                  above to the function definition.

                                                  A New function get_jurisdiction_type added

    02-MAY-05  PPANDA          115.23  4337890    Exception added to formula function
                                                  get_Work_jurisdiction
    27-MAY-05  SAIKRISH        115.25  4383819    Increase l_max_jurisdictions to 200
    01-JUN-05  PPANDA          115.26  4217503    in get_work_jurisdiction function
                                                  a new criteria added to handle
                                                  number of work jurisdiction
    02-JUN-05  ppanda         115.27   4374308    get_work_jurisdiction function
                                                  was using two local variables
                                                  to store the zip code of live and
                                                  work where size was not enough
                                                  when zip code had extension.
                                                  variable sizes increased.

    27-JUN-05  ppanda         115.28   4227824    get_work_jurisdiction function
                                                  modified to support Homeworker
    12-JUL-05 schauhan        115.29   4194339   Added function get_executive_status
    20-AUG-05 saikrish        115.30   4532107   Added get_it_work_jurisdictions,
                                                 get_jd_level_threshold,get_th_assignment for
                                                 Consultant Taxation.
    24-AUG-05 saikrish        115.31   4532107   Corrected Further Payroll DFF segment
                                                 columns in cursor csr_period_flag,
                                                 get_it_work_jurisdictions.
    31-AUG-05 saikrish        115.35   4532107   Defaulted Further Payroll DFF segment
                                                 Use Information Hours to P (Previous
                                                 Pay Period).
    05-SEP-05 saikrish        115.36   4590974   changed csr_it_element_entries
                                                 to query on end_date rather than
                                                 date_earned.
    08-SEP-05 saikrish        115.38   4532107   Removed to_char for character
                                                 trace variables.
    09-SEP-05 saikrish        115.39   4590974   Modified get_jd_tax_balances.
                                                 Corrected to 'State Tax Rules 2'
    15-SEP-05 saikrish        115.43   4532107   Replaced csr_balance_ro with
                                                 balance call, _ASG_JD_RTD dimension
    16-SEP-05 saikrish        115.44   4532107   Added message calls.
    19-SEP-05 saikrish        115.45   4532107   Restricting tokens to length of 50
    22-SEP-05 saikrish        115.46   4626170   Checking the termination of person
                                                 added cursor csr_term_date.
    23-SEP-05 saikrish        115.47   4626170   Checking the hiring of person
                                                 added cursor csr_eff_dates.
    29-SEP-05 saikrish        115.48   4638194   MOdified the dimension from
                                                 _ASG_JD_RTD to _PER_JD_GRE_RTD
    07-NOV-05 saikrish        115.49   4626170   Enabled checking of hire and
                                                 termination of asssignment.
    29-NOV-05 saikrish        115.50   4626170   Checking the termination date
                                                 based on date paid.
    01-DEC-05  ppanda         115.51   4758960   get_work_jurisdiction function
                                                 modified to return work jurisdiction
                                                 count correctly ignoring the resident
                                                 jurisdiction code which is always added
                                                 at the end when its not an work
                                                 jurisdiction
    03-APR-06 PPANDA          115.53   4715851  Few session variables were defined to fix
				                the Enhanced tax interface issue on local
						tax.
    02-MAY-06 PPANDA          115.55   5092586  get_work_jurisdiction function changed to
                                                use Date Earned instead of Date Paid while
						fetching VERTEX element entries.
    03-MAY-06 PPANDA          115.56   5227022  get_work_jurisdiction function changed
						When P_initialize flag was N, for information
						time processing code was having issue to
						fetch next jurisdiction from the pl/sql table
						used in enhanced tax interface.
    31-OCT-06 ssouresr        115.58   5602889  The function get_work_jurisdiction has been
                                       5515072  modified to ensure that a resident jurisdiction
                                                is not returned if the employee has not worked
                                                in that jurisdiction
    21-NOV-06 ssouresr        115.59            Added extra parameter to get_tax_exists
    23-JAN-07 saikrish        115.60   5722893  Added new function get_jit_data.
    07-MAR-07 SAIKRISH        115.62            Added new function get_rs_jd,get_wk_jd
    15-MAR-07 jdevasah        115.67   5648961  The function get_it_work_jurisdiction has been
                                                modified to assign null to l_start_date and
						l_end_date for the first pay period when
						l_pay_period_flag = 'P'.
    11-MAY-07 jdevasah        115.68   5981447  Modified the function get_it_work_jurisdiction
                                                with the following changes,
						1. changed definition of the cursor csr_term_dates
                                                   to fetch hired date.
						2. Added new date variables l_ws_start_date,
						   l_ws_end_date. These two variables are start and
						   end dates to calculate scheduled working hours
                                                3. logic to calculate start and end dates for capturing
						   information hours and tagged hours is modified.
    16-MAY-07 jdevasah        115.69   5981447  Added new condition in function get_jit_data to get
                                                default supplemental calc method.
    21-SEP-07 jdevasah        115.71   6371062  refined cdefiniton of cursor csr_term_dates in
                                                in order to pick only active records from period of
						service table.

    25-OCT-07 jdevasah        115.72   6524016  Added two newparameters to the cursor csr_term_dates.
                                                Pay period'start and end dates are passed to this
						cursor.

    14-NOV-07 jdevasah        115.73   6598477  Added new condition in get_it_jd_percent function
                                                to handle CITY.
    03-DEC-07 ssouresr        115.74   6495410  modified logic that was summing up percentages for
                                                County. This was causing problems when city tax in KY
                                                eliminates county tax.
    08-MAR-08 ssouresr        115.75   6794452  Backed out changes made in previous version of the file
    10-MAR-08 jdevasah        115.76   2122611  Added new function get_wc_flag.
    10-APR-08 sjawid          115.77   6899939  Added new function parameter p_get_regular_wage to
                              115.78            get_prev_ptd_values
    09-MAY-08 pannapur        115.79   5972214  Added function get_max_perc to find the city
                                                wherein more time is worked in case of multiple
                                                work jurisdictions
                              115.80   5972214  Removed get_max_perc
    12-MAY-08 jdevasah        115.81   6869097  Modified Threshold hours calculation logic in function
                                                get_it_work_jurisdiction.
    10-JUL-08 Pannapur        115.83   7238809  Modified get_prev_ptd_values
    10-JUL-08 Pannapur        115.84            Problem with ARCS .so arcsed in once again
    12-JUL-08 jdevasah        115.85   6957929  Modified get_it_work_jurisdiction function to make the
                                                functionality in sync with non EMJT. When work and
                                                resident locations are same jurisdiction_type in the
                                                pl/sql table must be 'RW'.
    14-JUL-08 pannapur         115.86           Reverted back the fix made in 115.83
    08-Aug-08 Pannapur         115.87   7238809 Added new function parameter per_adr_geocode to
                               115.88           get_prev_ptd_values
                               115.89           get_prev_ptd_values
    15-SEP-08 jdevasah         115.90   7114362 modified get_it_work_jurisdiction function to make
                                                payroll works for terminated assignments.
    05-NOV-08 jdevasah         115.97   7520832 Modified get_wc_flag function in order to deduct WC
                               115.98           amount on the pay period close as possible to end
                                                of the quarter.
    18-DEC-08 jdevasah         115.99   7655549 Modified CSR_GET_VALID_EMPLOYMENT cursor
                                                in GET_WC_FLAG function.
    19-DEC-08 emunisek         115.101  5972214 Created new function COLORADOCITY_HT_COLLECTORNOT
                                                to decide for a given coloradocity if the head tax
						can be deducted or not.It needs the payperiod to be the
						last one of the given month and the current city is with
						maximum time percentage of all the colorado head tax
						jurisdictions the assignment is related with.
    14-MAY-09 emunisek         115.103  8406097 Modified COLORADOCITY_HT_COLLECTORNOT function to
                                                consider average time percentage for work jurisdictions
						over a month to find the jurisdiction with maximum
						percentage.
						  Also introduced a check to see if the Date Paid and
						Date Earned are of different month for payrolls of period
						less than month and give out a warning if Head Tax gets
						skipped.

   16-Jun-09 jdevasah        115.104   8592027   Modified GET_WC_FLAG to use regular payment date
                                                 instead of date earned to determine the appropriate
                                                 pay period to deduct Workers compensation fee.
  24-Dec-09 tclewis          115.107   9232546   modified
get_it_work_jurisdictions
                                                 added code to att the primary
                                                 work JD to the staging table
                                                 if an entry doesnt exist.


*/

FUNCTION get_tax_jurisdiction(p_assignment_id  number
                              ,p_date_earned    date
                              )
  RETURN varchar2
IS

    l_return_value      varchar2(1);

BEGIN
    hr_utility.trace('BEGIN -> hr_us_ff_udf1.get_tax_jurisdiction ');
    select nvl(hoi.org_information16,'N')
      into l_return_value
      from per_assignments_f paf,
           hr_organization_information hoi,
           hr_soft_coding_keyflex hsk
     where paf.assignment_id = p_assignment_id
       and p_date_earned between paf.effective_start_date
                             and paf.effective_end_date
       and paf.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
       and hsk.segment1 = hoi.organization_id
       and hoi.org_information_context = 'W2 Reporting Rules';

    hr_utility.trace('get_tax_jurisdiction retrun_value = ' || l_return_value);
    hr_utility.trace('END -> hr_us_ff_udf1.get_tax_jurisdiction ');
    return (l_return_value);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         return ('N');
END get_tax_jurisdiction;

--
--
FUNCTION calc_earning (p_template_earning number,
                       p_addl_asg_gre_itd number,
                       p_neg_earn_asg_gre_itd number)
RETURN NUMBER
IS

 l_ret number;

BEGIN
  hr_utility.trace('tab.count = '||to_char(hr_us_ff_udf1.l_neg_earn_tab.count));

  IF hr_us_ff_udf1.l_neg_earn_tab.count <= 0 THEN
     hr_us_ff_udf1.l_neg_earn_tab(1).temp_earn := 0;
     hr_us_ff_udf1.l_neg_earn_tab(1).neg_earn_feed := 0;
     hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn := p_neg_earn_asg_gre_itd;
  END IF;

  hr_us_ff_udf1.l_neg_earn_tab(1).temp_earn :=  p_template_earning +
                                                p_addl_asg_gre_itd +
                     hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn;

  hr_utility.trace('temp_earn = '||
           to_char(hr_us_ff_udf1.l_neg_earn_tab(1).temp_earn));

  IF hr_us_ff_udf1.l_neg_earn_tab(1).temp_earn < 0 THEN
     hr_us_ff_udf1.l_neg_earn_tab(1).neg_earn_feed :=
            hr_us_ff_udf1.l_neg_earn_tab(1).temp_earn;
  ELSE
     IF (hr_us_ff_udf1.l_neg_earn_tab(1).temp_earn > 0) and
         ( hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn = 0 ) THEN
         hr_us_ff_udf1.l_neg_earn_tab(1).neg_earn_feed := 0;
     END IF;

     IF ( hr_us_ff_udf1.l_neg_earn_tab(1).temp_earn >= 0) and
         ( hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn < 0) THEN
          hr_us_ff_udf1.l_neg_earn_tab(1).neg_earn_feed :=
                ( -1 *  hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn);
     END IF;
  END IF;

  hr_utility.trace('neg_earn_feed = '||
           to_char(hr_us_ff_udf1.l_neg_earn_tab(1).neg_earn_feed));

  hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn
                  := hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn +
                    (-1 * hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn);

  hr_utility.trace('reduced_neg_earn = '||
           to_char(hr_us_ff_udf1.l_neg_earn_tab(1).reduced_neg_earn));

  l_ret := hr_us_ff_udf1.l_neg_earn_tab(1).temp_earn;

  return l_ret;
END calc_earning;
--
--
FUNCTION  neg_earning RETURN NUMBER is
  l_ret    number;
BEGIN
  l_ret := hr_us_ff_udf1.l_neg_earn_tab(1).neg_earn_feed;
  hr_utility.trace('hr_us_ff_udf1.neg_earning : neg_earn_feed = '||
                    to_char(l_ret));
  return l_ret;
END neg_earning;

/*Function added for 6899939*/
FUNCTION get_prev_ptd_values(
                   p_assignment_action_id     number,            -- Context
                   p_tax_unit_id              number,            -- Context
                   p_jurisdiction_code        varchar2,          -- Context
                   p_fed_or_state             varchar2,          -- Parameter
                   p_regular_aggregate        number,            -- Parameter
                   calc_PRV_GRS               OUT nocopy number, -- Paramter
                   calc_PRV_TAX               OUT nocopy number )

RETURN NUMBER IS
  BEGIN
  RETURN get_prev_ptd_values(
                       p_assignment_action_id
                       ,p_tax_unit_id
                       ,p_jurisdiction_code
                       ,p_fed_or_state
                       ,p_regular_aggregate
                       ,calc_PRV_GRS
                       ,calc_PRV_TAX
                       ,'N');
 END get_prev_ptd_values;

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

  RETURN NUMBER IS

CURSOR csr_l_home_juris (p_assignment_action_id IN NUMBER) IS

   SELECT hr_us_ff_udfs.addr_val(NVL(add_information17, region_2),
                                          NVL(add_information19, region_1),
                                          NVL(add_information18, town_or_city),
                                          NVL(add_information20, postal_code)
                                         )

            FROM per_addresses pad,
                 per_assignments_f paf,
                 pay_assignment_actions paa,
                 pay_payroll_actions ppa

            WHERE pad.primary_flag = 'Y'
            AND   pad.person_id = paf.person_id
            AND   ppa.date_earned BETWEEN pad.date_from
                                    AND NVL(pad.date_to, TO_DATE('12/31/4712',
                                                            'MM/DD/YYYY'))
            AND   ppa.date_earned BETWEEN paf.effective_start_date
                                    AND     paf.effective_end_date
            AND paf.assignment_id = paa.assignment_id
            AND paa.payroll_action_id = ppa.payroll_action_id
            AND paa.assignment_action_id = p_assignment_action_id;

 l_home_juris       varchar2(11);

  BEGIN

 OPEN csr_l_home_juris(p_assignment_action_id);
      FETCH csr_l_home_juris INTO l_home_juris;
      IF csr_l_home_juris%NOTFOUND THEN
         l_home_juris := '00-000-0000';
      END IF;
      CLOSE csr_l_home_juris;


  RETURN get_prev_ptd_values(
                       p_assignment_action_id
                       ,p_tax_unit_id
                       ,p_jurisdiction_code
                       ,p_fed_or_state
                       ,p_regular_aggregate
                       ,calc_PRV_GRS
                       ,calc_PRV_TAX
                       ,p_get_regular_wage
                       ,l_home_juris);
 END get_prev_ptd_values;


FUNCTION get_prev_ptd_values(
                       p_assignment_action_id     number, -- context
                       p_tax_unit_id              number,-- context
                       p_jurisdiction_code        varchar2, -- context
                       p_fed_or_state             varchar2,  -- parameter
                       p_regular_aggregate        number,
                       calc_PRV_GRS               OUT nocopy number,
                       calc_PRV_TAX               OUT nocopy number,
		                   p_get_regular_wage         varchar2,  -- Paramter /*6899939*/
                       per_adr_geocode            varchar2   -- Parameter /*7238809*/
                       )
    RETURN NUMBER IS

       l_defined_balance_tab             pay_balance_pkg.t_balance_value_tab;
       l_context_tab                     pay_balance_pkg.t_context_tab;
       l_bal_out_tab                  pay_balance_pkg.t_detailed_bal_out_tab;
       l_assignment_id    number;
       l_bal_assact       number;
       l_payroll_id       number;
       l_asg_type         varchar2(11)  := null;
       l_regular_aggregate number;
       l_get_full_wage    varchar2(1);


BEGIN
--       hr_utility.trace_on(NULL,'ORCL');
       l_get_full_wage := 'Y';
       hr_utility.trace('Entering get_prev_ptd_values' );
       hr_utility.trace('p_regular_aggregate = ' ||
                                      to_char(p_regular_aggregate) );

            SELECT paa.assignment_id
            INTO   l_assignment_id
            FROM   pay_assignment_actions paa
            where  paa.assignment_action_id = p_assignment_action_id;


           /* commented for bug 7238809 .As fetching home jurisdiction using
           fnd sessions does not pick the correct value .
           SELECT hr_us_ff_udfs.addr_val(NVL(add_information17, region_2),
                                          NVL(add_information19, region_1),
                                          NVL(add_information18, town_or_city),
                                          NVL(add_information20, postal_code)
                                         )
            INTO l_home_juris
            FROM per_addresses pad,
                 per_assignments_f paf,
                 fnd_sessions fs
            WHERE pad.primary_flag = 'Y'
            AND   pad.person_id = paf.person_id
            AND   fs.effective_date BETWEEN pad.date_from
                                    AND NVL(pad.date_to, TO_DATE('12/31/4712',
                                                            'MM/DD/YYYY'))
            AND   fs.effective_date BETWEEN paf.effective_start_date
                                    AND     paf.effective_end_date
            AND   fs.session_id = USERENV('sessionid')
            AND   paf.assignment_id = l_assignment_id; */

            SELECT /*+ RULE */ paa1.assignment_action_id,
                               ppa1.payroll_id
            INTO   l_bal_assact,
                   l_payroll_id
            FROM   pay_assignment_Actions   paa1,
                   pay_payroll_actions      ppa1
            WHERE  paa1.assignment_id   = l_assignment_id
            AND    paa1.tax_unit_id     = p_tax_unit_id
            AND    paa1.action_sequence =
               (SELECT max(paa_prev.action_sequence)
                FROM    per_time_periods ptp
                      , pay_payroll_actions ppa
                      , pay_assignment_actions paa
                      , per_time_periods    ptp_prev
                      , pay_payroll_actions ppa_prev
                      , pay_assignment_actions paa_prev
                WHERE  paa.assignment_action_id = p_assignment_action_id
                AND    ppa.payroll_action_id    = paa.payroll_action_id
--              AND    ptp.time_period_id       = ppa.time_period_id
                AND    ppa.effective_date          between ptp.start_date /*Bug:3909937*/
                                                and     ptp.end_date
                AND    ptp.payroll_id           = ppa.payroll_id
                AND    ptp_prev.payroll_id      = ppa.payroll_id
                AND    ptp.start_date - 1       between ptp_prev.start_date
                                                and     ptp_prev.end_date
                AND    paa_prev.assignment_id   = paa.assignment_id
                AND    paa_prev.payroll_action_id = ppa_prev.payroll_action_id
                AND    ppa_prev.action_type     IN ('R', 'Q', 'B')
--                AND    ppa_prev.time_period_id  = ptp_prev.time_period_id)
                --AND    ppa_prev.date_earned     between ptp_prev.start_date
                AND    ppa_prev.effective_date     between ptp_prev.start_date
                                                and     ptp_prev.end_date)
                AND    paa1.payroll_action_id = ppa1.payroll_action_id  ;

            hr_utility.trace('Previous period AAID ' || to_char(l_bal_assact) );


            IF nvl(p_regular_aggregate,0)= 0 THEN
               hr_utility.trace('p_regular_aggregate = 0  asg_type = ASG' );

               l_asg_type := 'ASG';
            ELSE
               l_asg_type := 'PER_PAYROLL';

               hr_utility.trace('p_regular_aggregate not = 0  asg_type = PER_PAYROLL' );

               pay_balance_pkg.set_context('PAYROLL_ID',l_payroll_id);

            END IF;

            IF p_fed_or_state = 'FED' THEN

               hr_utility.trace('p_fed_or_state = FED' );

                -- MAY NEED FOR AGGREGATION.
                --pay_balance_pkg.set_context('PAYROLL_ID',l_payroll_id);

                SELECT  creator_id
                  INTO  l_defined_balance_tab(1).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'REGULAR_EARNINGS_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';

                l_defined_balance_tab(1).balance_value  := 0;

               hr_utility.trace('REGULAR_EARNINGS_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(1).defined_balance_id));

                l_context_tab(1).tax_unit_id            := p_tax_unit_id;
                l_context_tab(1).jurisdiction_code      := Null;
                l_context_tab(1).source_id              := null;
                l_context_tab(1).source_text            := null;
                l_context_tab(1).source_number          := null;
                l_context_tab(1).source_text2           := null;

                 SELECT  creator_id
                  INTO  l_defined_balance_tab(2).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';
                l_defined_balance_tab(2).balance_value  := 0;

               hr_utility.trace('REGULAR_EARNINGS_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(2).defined_balance_id));

                l_context_tab(2).tax_unit_id            := p_tax_unit_id;
                l_context_tab(2).jurisdiction_code      := null;
                l_context_tab(2).source_id              := null;
                l_context_tab(2).source_text            := null;
                l_context_tab(2).source_number          := null;
                l_context_tab(2).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(3).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'FIT_NON_AGGREGATE_RED_SUBJ_WHABLE_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';

                l_defined_balance_tab(3).balance_value  := 0;

               hr_utility.trace('FIT_NON_AGGREGATE_RED_SUBJ_WHABLE_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(3).defined_balance_id));


                l_context_tab(3).tax_unit_id            := p_tax_unit_id;
                l_context_tab(3).jurisdiction_code      := null;
                l_context_tab(3).source_id              := null;
                l_context_tab(3).source_text            := null;
                l_context_tab(3).source_number          := null;
                l_context_tab(3).source_text2           := null;

                 SELECT  creator_id
                  INTO  l_defined_balance_tab(4).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'DEF_COMP_401K_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';

                l_defined_balance_tab(4).balance_value  := 0;

               hr_utility.trace('DEF_COMP_401K_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(4).defined_balance_id));

                l_context_tab(4).tax_unit_id            := p_tax_unit_id;
                l_context_tab(4).jurisdiction_code      := null;
                l_context_tab(4).source_id              := null;
                l_context_tab(4).source_text            := null;
                l_context_tab(4).source_number          := null;
                l_context_tab(4).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(5).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'DEF_COMP_403B_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';

                l_defined_balance_tab(5).balance_value  := 0;

               hr_utility.trace('DEF_COMP_403B_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(5).defined_balance_id));

                l_context_tab(5).tax_unit_id            := p_tax_unit_id;
                l_context_tab(5).jurisdiction_code      := null;
                l_context_tab(5).source_id              := null;
                l_context_tab(5).source_text            := null;
                l_context_tab(5).source_number          := null;
                l_context_tab(5).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(6).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'DEF_COMP_457_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';

                l_defined_balance_tab(6).balance_value  := 0;

               hr_utility.trace('DEF_COMP_457_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(6).defined_balance_id));

                l_context_tab(6).tax_unit_id            := p_tax_unit_id;
                l_context_tab(6).jurisdiction_code      := null;
                l_context_tab(6).source_id              := null;
                l_context_tab(6).source_text            := null;
                l_context_tab(6).source_number          := null;
                l_context_tab(6).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(7).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'OTHER_PRETAX_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';

               hr_utility.trace('OTHER_PRETAX_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(7).defined_balance_id));

                l_defined_balance_tab(7).balance_value  := 0;

                l_context_tab(7).tax_unit_id            := p_tax_unit_id;
                l_context_tab(7).jurisdiction_code      := null;
                l_context_tab(7).source_id              := null;
                l_context_tab(7).source_text            := null;
                l_context_tab(7).source_number          := null;
                l_context_tab(7).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(8).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'SECTION_125_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';

               hr_utility.trace('SECTION_125_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(8).defined_balance_id));

                l_defined_balance_tab(8).balance_value  := 0;

                l_context_tab(8).tax_unit_id            := p_tax_unit_id;
                l_context_tab(8).jurisdiction_code      := null;
                l_context_tab(8).source_id              := null;
                l_context_tab(8).source_text            := null;
                l_context_tab(8).source_number          := null;
                l_context_tab(8).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(9).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'DEPENDENT_CARE_' || l_asg_type || '_GRE_PTD'
                   AND  legislation_code = 'US';

               hr_utility.trace('DEPENDENT_CARE_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(9).defined_balance_id));

                l_defined_balance_tab(9).balance_value  := 0;

                l_context_tab(9).tax_unit_id            := p_tax_unit_id;
                l_context_tab(9).jurisdiction_code      := null;
                l_context_tab(9).source_id              := null;
                l_context_tab(9).source_text            := null;
                l_context_tab(9).source_number          := null;
                l_context_tab(9).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(10).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'DEF_COMP_401K_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('DEF_COMP_401K_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(10).defined_balance_id));


            l_defined_balance_tab(10).balance_value  := 0;

            l_context_tab(10).tax_unit_id            := p_tax_unit_id;
            l_context_tab(10).jurisdiction_code      := null;
            l_context_tab(10).source_id              := null;
            l_context_tab(10).source_text            := null;
            l_context_tab(10).source_number          := null;
            l_context_tab(10).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(11).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'DEF_COMP_403B_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('DEF_COMP_403B_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(11).defined_balance_id));

            l_defined_balance_tab(11).balance_value  := 0;

            l_context_tab(11).tax_unit_id            := p_tax_unit_id;
            l_context_tab(11).jurisdiction_code      := null;
            l_context_tab(11).source_id              := null;
            l_context_tab(11).source_text            := null;
            l_context_tab(11).source_number          := null;
            l_context_tab(11).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(12).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'DEF_COMP_457_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('DEF_COMP_457_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(12).defined_balance_id));

            l_defined_balance_tab(12).balance_value  := 0;

            l_context_tab(12).tax_unit_id            := p_tax_unit_id;
            l_context_tab(12).jurisdiction_code      := null;
            l_context_tab(12).source_id              := null;
            l_context_tab(12).source_text            := null;
            l_context_tab(12).source_number          := null;
            l_context_tab(12).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(13).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'OTHER_PRETAX_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('OTHER_PRETAX_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(13).defined_balance_id));

            l_defined_balance_tab(13).balance_value  := 0;

            l_context_tab(13).tax_unit_id            := p_tax_unit_id;
            l_context_tab(13).jurisdiction_code      := null;
            l_context_tab(13).source_id              := null;
            l_context_tab(13).source_text            := null;
            l_context_tab(13).source_number          := null;
            l_context_tab(13).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(14).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'SECTION_125_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('SECTION_125_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(14).defined_balance_id));

            l_defined_balance_tab(14).balance_value  := 0;

            l_context_tab(14).tax_unit_id            := p_tax_unit_id;
            l_context_tab(14).jurisdiction_code      := null;
            l_context_tab(14).source_id              := null;
            l_context_tab(14).source_text            := null;
            l_context_tab(14).source_number          := null;
            l_context_tab(14).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(15).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'DEPENDENT_CARE_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('DEPENDENT_CARE_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(15).defined_balance_id));

            l_defined_balance_tab(15).balance_value  := 0;

            l_context_tab(15).tax_unit_id            := p_tax_unit_id;
            l_context_tab(15).jurisdiction_code      := null;
            l_context_tab(15).source_id              := null;
            l_context_tab(15).source_text            := null;
            l_context_tab(15).source_number          := null;
            l_context_tab(15).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(16).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'FIT_NON_W2_DEF_COMP_401_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('FIT_NON_W2_DEF_COMP_401_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(16).defined_balance_id));

            l_defined_balance_tab(16).balance_value  := 0;

            l_context_tab(16).tax_unit_id            := p_tax_unit_id;
            l_context_tab(16).jurisdiction_code      := null;
            l_context_tab(16).source_id              := null;
            l_context_tab(16).source_text            := null;
            l_context_tab(16).source_number          := null;
            l_context_tab(16).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(17).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'FIT_NON_W2_DEF_COMP_403_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('FIT_NON_W2_DEF_COMP_403_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(17).defined_balance_id));

            l_defined_balance_tab(17).balance_value  := 0;

            l_context_tab(17).tax_unit_id            := p_tax_unit_id;
            l_context_tab(17).jurisdiction_code      := null;
            l_context_tab(17).source_id              := null;
            l_context_tab(17).source_text            := null;
            l_context_tab(17).source_number          := null;
            l_context_tab(17).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(18).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'FIT_NON_W2_DEF_COMP_457_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('FIT_NON_W2_DEF_COMP_457_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(18).defined_balance_id));

            l_defined_balance_tab(18).balance_value  := 0;

            l_context_tab(18).tax_unit_id            := p_tax_unit_id;
            l_context_tab(18).jurisdiction_code      := null;
            l_context_tab(18).source_id              := null;
            l_context_tab(18).source_text            := null;
            l_context_tab(18).source_number          := null;
            l_context_tab(18).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(19).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'FIT_NON_W2_SECTION_125_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('FIT_NON_W2_SECTION_125_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(19).defined_balance_id));

            l_defined_balance_tab(19).balance_value  := 0;

            l_context_tab(19).tax_unit_id            := p_tax_unit_id;
            l_context_tab(19).jurisdiction_code      := null;
            l_context_tab(19).source_id              := null;
            l_context_tab(19).source_text            := null;
            l_context_tab(19).source_number          := null;
            l_context_tab(19).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(20).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'FIT_NON_W2_DEPENDENT_CARE_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('FIT_NON_W2_DEPENDENT_CARE_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(20).defined_balance_id));

            l_defined_balance_tab(20).balance_value  := 0;

            l_context_tab(20).tax_unit_id            := p_tax_unit_id;
            l_context_tab(20).jurisdiction_code      := null;
            l_context_tab(20).source_id              := null;
            l_context_tab(20).source_text            := null;
            l_context_tab(20).source_number          := null;
            l_context_tab(20).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(21).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'FIT_NON_W2_OTHER_PRETAX_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('FIT_NON_W2_OTHER_PRETAX_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(21).defined_balance_id));

            l_defined_balance_tab(21).balance_value  := 0;

            l_context_tab(21).tax_unit_id            := p_tax_unit_id;
            l_context_tab(21).jurisdiction_code      := null;
            l_context_tab(21).source_id              := null;
            l_context_tab(21).source_text            := null;
            l_context_tab(21).source_number          := null;
            l_context_tab(21).source_text2           := null;


            SELECT  creator_id
              INTO  l_defined_balance_tab(22).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'FIT_WITHHELD_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('FIT_WITHHELD_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(22).defined_balance_id));

            l_defined_balance_tab(22).balance_value  := 0;

            l_context_tab(22).tax_unit_id            := p_tax_unit_id;
            l_context_tab(22).jurisdiction_code      := null;
            l_context_tab(22).source_id              := null;
            l_context_tab(22).source_text            := null;
            l_context_tab(22).source_number          := null;
            l_context_tab(22).source_text2           := null;

            SELECT  creator_id
              INTO  l_defined_balance_tab(23).defined_balance_id
              FROM  ff_user_entities
             WHERE  user_entity_name = 'FIT_SUPP_WITHHELD_' || l_asg_type || '_GRE_PTD'
               AND  legislation_code = 'US';

               hr_utility.trace('FIT_SUPP_WITHHELD_' || l_asg_type || '_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(23).defined_balance_id));

            l_defined_balance_tab(23).balance_value  := 0;

            l_context_tab(23).tax_unit_id            := p_tax_unit_id;
            l_context_tab(23).jurisdiction_code      := null;
            l_context_tab(23).source_id              := null;
            l_context_tab(23).source_text            := null;
            l_context_tab(23).source_number          := null;
            l_context_tab(23).source_text2           := null;

                pay_balance_pkg.get_value (p_assignment_action_id => l_bal_assact,
                                 p_defined_balance_lst            => l_defined_balance_tab,
                                 p_context_lst                    => l_context_tab,
                                 p_get_rr_route                   => FALSE,
                                 p_get_rb_route                   => FALSE,
                                 p_output_table                   => l_bal_out_tab);

                hr_utility.trace('Return value from balance call');
                hr_utility.trace( 'REGULAR_EARNINGS_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(1).balance_value,0)));
                hr_utility.trace( 'SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(2).balance_value,0)));
                hr_utility.trace( 'FIT_NON_AGGREGATE_RED_SUBJ_WHABLE_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(3).balance_value,0)));
                hr_utility.trace( 'DEF_COMP_401K_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(4).balance_value,0)));
                hr_utility.trace( 'DEF_COMP_403B_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(5).balance_value,0)));
                hr_utility.trace( 'DEF_COMP_457_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(6).balance_value,0)));
                hr_utility.trace( 'OTHER_PRETAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(7).balance_value,0)));
                hr_utility.trace( 'SECTION_125_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(8).balance_value,0)));
                hr_utility.trace( 'DEPENDENT_CARE_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(9).balance_value,0)));

                hr_utility.trace( 'DEF_COMP_401K_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(10).balance_value,0)));
                hr_utility.trace( 'DEF_COMP_403B_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(11).balance_value,0)));
                hr_utility.trace( 'DEF_COMP_457_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(12).balance_value,0)));
                hr_utility.trace( 'OTHER_PRETAX_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(13).balance_value,0)));
                hr_utility.trace( 'SECTION_125_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(14).balance_value,0)));
                hr_utility.trace( 'DEPENDENT_CARE_FOR_FIT_SUBJECT_TO_TAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(15).balance_value,0)));

                hr_utility.trace( 'FIT_NON_W2_DEF_COMP_401_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(16).balance_value,0)));
                hr_utility.trace( 'FIT_NON_W2_DEF_COMP_403_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(17).balance_value,0)));
                hr_utility.trace( 'FIT_NON_W2_DEF_COMP_457_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(18).balance_value,0)));
                hr_utility.trace( 'FIT_NON_W2_SECTION_125_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(19).balance_value,0)));
                hr_utility.trace( 'FIT_NON_W2_DEPENDENT_CARE_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(20).balance_value,0)));
                hr_utility.trace( 'FIT_NON_W2_OTHER_PRETAX_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(21).balance_value,0)));

                hr_utility.trace( 'FIT_WITHHELD_' || l_asg_type || '_PTD = '|| to_char(nvl(l_bal_out_tab(22).balance_value,0)));
                hr_utility.trace( 'FIT_SUPP_WITHHELD_' || l_asg_type || '_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(23).balance_value,0)));



            calc_PRV_GRS := nvl(l_bal_out_tab(1).balance_value,0)        -- REGULAR_EARNINGS_ASG_GRE_PTD
                               +  nvl(l_bal_out_tab(2).balance_value,0)  -- SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_ASG_GRE_PTD
                               -  nvl(l_bal_out_tab(3).balance_value,0)  -- FIT_NON_AGGREGATE_RED_SUBJ_WHABLE_ASG_GRE_PTD
                               -  nvl(l_bal_out_tab(4).balance_value,0)  -- DEF_COMP_401K_ASG_GRE_PTD
                               -  nvl(l_bal_out_tab(5).balance_value,0)  -- DEF_COMP_403B_ASG_GRE_PTD
                               -  nvl(l_bal_out_tab(6).balance_value,0)  -- DEF_COMP_457_ASG_GRE_PTD
                               -  nvl(l_bal_out_tab(7).balance_value,0)  -- OTHER_PRETAX_ASG_GRE_PTD
                               -  nvl(l_bal_out_tab(8).balance_value,0)  -- SECTION_125_ASG_GRE_PTD
                               -  nvl(l_bal_out_tab(9).balance_value,0)  -- DEPENDENT_CARE_ASG_GRE_PTD

                               +  nvl(l_bal_out_tab(10).balance_value,0)  -- 'DEF_COMP_401K_FOR_FIT_SUBJECT_TO_TAX_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(11).balance_value,0)  -- 'DEF_COMP_403B_FOR_FIT_SUBJECT_TO_TAX_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(12).balance_value,0)  -- 'DEF_COMP_457_FOR_FIT_SUBJECT_TO_TAX_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(13).balance_value,0)  -- 'OTHER_PRETAX_FOR_FIT_SUBJECT_TO_TAX_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(14).balance_value,0)  -- 'SECTION_125_FOR_FIT_SUBJECT_TO_TAX_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(15).balance_value,0)  -- 'DEPENDENT_CARE_FOR_FIT_SUBJECT_TO_TAX_ASG_GRE_PTD'

                               +  nvl(l_bal_out_tab(16).balance_value,0)  -- 'FIT_NON_W2_DEF_COMP_401_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(17).balance_value,0)  -- 'FIT_NON_W2_DEF_COMP_403_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(18).balance_value,0)  -- 'FIT_NON_W2_DEF_COMP_457_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(19).balance_value,0)  -- 'FIT_NON_W2_SECTION_125_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(20).balance_value,0)  -- 'FIT_NON_W2_DEPENDENT_CARE_ASG_GRE_PTD'
                               +  nvl(l_bal_out_tab(21).balance_value,0);  -- 'FIT_NON_W2_OTHER_PRETAX_ASG_GRE_PTD'

              hr_utility.trace( 'calc_PRV_GRS = '|| to_char(nvl(calc_PRV_GRS,0)));

            calc_PRV_TAX := nvl(l_bal_out_tab(22).balance_value,0)        -- FIT_WITHHELD_ASG_PTD
                               -  nvl(l_bal_out_tab(23).balance_value,0);  -- FIT_SUPP_WITHHELD_ASG_GRE_PTD

              hr_utility.trace( 'calc_PRV_TAX = '|| to_char(nvl(calc_PRV_TAX,0)));

        ELSIF p_fed_or_state = 'STATE' THEN

           hr_utility.trace('p_fed_or_state = STATE');

                /*IF ((SUBSTR(l_home_juris, 1, 2)
                                           = SUBSTR(p_jurisdiction_code, 1, 2))
                 OR
                   p_get_regular_wage='Y')  6899939*/

              /* Modifed for both 6899939 and 7238809 .Finding home jurisdiction based on sessiondate does not
              fetch correct address in 7238809 */
              IF ((SUBSTR(per_adr_geocode, 1, 2)
                                           = SUBSTR(p_jurisdiction_code, 1, 2))
                 OR
                   p_get_regular_wage='Y')

                THEN
                   /*
                    * If we are processing home jurisdiction, then return
                    * only aggregate wages, otherwise return full wages
                    */
                   l_get_full_wage := 'N';
                END IF;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(1).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'SIT_SUBJ_WHABLE_' || l_asg_type || '_JD_GRE_PTD'
                   AND  legislation_code = 'US';

               hr_utility.trace('SIT_SUBJ_WHABLE_' || l_asg_type || '_JD_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(1).defined_balance_id));

                l_defined_balance_tab(1).balance_value  := 0;

                l_context_tab(1).tax_unit_id            := p_tax_unit_id;
                l_context_tab(1).jurisdiction_code      := p_jurisdiction_code;
                l_context_tab(1).source_id              := null;
                l_context_tab(1).source_text            := null;
                l_context_tab(1).source_number          := null;
                l_context_tab(1).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(2).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'SIT_NON_AGGREGATE_RED_SUBJ_WHABLE_' || l_asg_type || '_JD_GRE_PTD'
                   AND  legislation_code = 'US';

               hr_utility.trace('SIT_NON_AGGREGATE_RED_SUBJ_WHABLE_' || l_asg_type || '_JD_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(2).defined_balance_id));

                l_defined_balance_tab(2).balance_value  := 0;

                l_context_tab(2).tax_unit_id            := p_tax_unit_id;
                l_context_tab(2).jurisdiction_code      := p_jurisdiction_code;
                l_context_tab(2).source_id              := null;
                l_context_tab(2).source_text            := null;
                l_context_tab(2).source_number          := null;
                l_context_tab(2).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(3).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'SIT_PRE_TAX_REDNS_' || l_asg_type || '_JD_GRE_PTD'
                   AND  legislation_code = 'US';

               hr_utility.trace('SIT_PRE_TAX_REDNS_' || l_asg_type || '_JD_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(3).defined_balance_id));

                l_defined_balance_tab(3).balance_value  := 0;

                l_context_tab(3).tax_unit_id            := p_tax_unit_id;
                l_context_tab(3).jurisdiction_code      := p_jurisdiction_code;
                l_context_tab(3).source_id              := null;
                l_context_tab(3).source_text            := null;
                l_context_tab(3).source_number          := null;
                l_context_tab(3).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(4).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'SIT_WITHHELD_' || l_asg_type || '_JD_GRE_PTD'
                   AND  legislation_code = 'US';

               hr_utility.trace('SIT_WITHHELD_' || l_asg_type || '_JD_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(4).defined_balance_id));

                l_defined_balance_tab(5).balance_value  := 0;

                l_context_tab(4).tax_unit_id            := p_tax_unit_id;
                l_context_tab(4).jurisdiction_code      := p_jurisdiction_code;
                l_context_tab(4).source_id              := null;
                l_context_tab(4).source_text            := null;
                l_context_tab(4).source_number          := null;
                l_context_tab(4).source_text2           := null;

                SELECT  creator_id
                  INTO  l_defined_balance_tab(5).defined_balance_id
                  FROM  ff_user_entities
                 WHERE  user_entity_name = 'SIT_SUPP_WITHHELD_' || l_asg_type || '_JD_GRE_PTD'
                   AND  legislation_code = 'US';

               hr_utility.trace('SIT_SUPP_WITHHELD_' || l_asg_type || '_JD_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(5).defined_balance_id));

                l_defined_balance_tab(5).balance_value  := 0;

                l_context_tab(5).tax_unit_id            := p_tax_unit_id;
                l_context_tab(5).jurisdiction_code      := p_jurisdiction_code;
                l_context_tab(5).source_id              := null;
                l_context_tab(5).source_text            := null;
                l_context_tab(5).source_number          := null;
                l_context_tab(5).source_text2           := null;

                pay_balance_pkg.get_value (p_assignment_action_id => l_bal_assact,
                                 p_defined_balance_lst            => l_defined_balance_tab,
                                 p_context_lst                    => l_context_tab,
                                 p_get_rr_route                   => FALSE,
                                 p_get_rb_route                   => FALSE,
                                 p_output_table                   => l_bal_out_tab);

                hr_utility.trace('Return value from balance call');
                hr_utility.trace( 'SIT_SUBJ_WHABLE_' || l_asg_type || '_JD_GRE_PTD  = '|| to_char(nvl(l_bal_out_tab(1).balance_value,0)));
                hr_utility.trace( 'SIT_NON_AGGREGATE_RED_SUBJ_WHABLE_' || l_asg_type || '_JD_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(2).balance_value,0)));
                hr_utility.trace( 'SIT_PRE_TAX_REDNS_' || l_asg_type || '_JD_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(3).balance_value,0)));
                hr_utility.trace( 'SIT_WITHHELD_' || l_asg_type || '_JD_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(4).balance_value,0)));
                hr_utility.trace( 'SIT_SUPP_WITHHELD_' || l_asg_type || '_JD_GRE_PTD = '|| to_char(nvl(l_bal_out_tab(5).balance_value,0)));

                calc_PRV_GRS := nvl(l_bal_out_tab(1).balance_value,0)         -- SIT_SUBJ_WHABLE_ASG_JD_GRE_PTD
                                    -  nvl(l_bal_out_tab(3).balance_value,0); -- SIT_PRE_TAX_REDNS_ASG_JD_GRE_PTD


                calc_PRV_TAX := nvl(l_bal_out_tab(4).balance_value,0);          -- SIT_WITHHELD_ASG_JD_GRE_PTD

           IF (l_get_full_wage <> 'Y')
           THEN
              calc_PRV_GRS := calc_PRV_GRS
                             -NVL(l_bal_out_tab(2).balance_value,0);
                             -- SIT_NON_AGGREGATE_RED_SUBJ_WHABLE_ASG_JD_GRE_PTD
              calc_PRV_TAX := calc_PRV_TAX
                             -NVL(l_bal_out_tab(5).balance_value,0);
                                            -- SIT_SUPP_WITHHELD_ASG_JD_GRE_PTD
           END IF;

           hr_utility.trace( 'calc_PRV_GRS = '|| to_char(nvl(calc_PRV_GRS,0)));
           hr_utility.trace( 'calc_PRV_TAX = '|| to_char(nvl(calc_PRV_TAX,0)));
-- End of State Level Balance Fetch
--
--{
--  This piece of code added for determining the Previous Pay Period City Level balances
--  For fixing bug # 3915176
--  Only City Tax withheld is derived from this piece of code not City level Wages
--  Code needs modification for deriving City level wages
--
        ELSIF p_fed_or_state = 'CITY' THEN
           hr_utility.trace('p_fed_or_state = CITY');
           SELECT  creator_id
             INTO  l_defined_balance_tab(1).defined_balance_id
             FROM  ff_user_entities
            WHERE  user_entity_name = 'CITY_WITHHELD_' || l_asg_type || '_JD_GRE_PTD'
              AND  legislation_code = 'US';

           hr_utility.trace('CITY_WITHHELD_' || l_asg_type || '_JD_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(1).defined_balance_id));

           l_defined_balance_tab(1).balance_value  := 0;
           l_context_tab(1).tax_unit_id            := p_tax_unit_id;
           l_context_tab(1).jurisdiction_code      := p_jurisdiction_code;
           l_context_tab(1).source_id              := null;
           l_context_tab(1).source_text            := null;
           l_context_tab(1).source_number          := null;
           l_context_tab(1).source_text2           := null;

           pay_balance_pkg.get_value (p_assignment_action_id => l_bal_assact,
                            p_defined_balance_lst            => l_defined_balance_tab,
                            p_context_lst                    => l_context_tab,
                            p_get_rr_route                   => FALSE,
                            p_get_rb_route                   => FALSE,
                            p_output_table                   => l_bal_out_tab);
           calc_PRV_GRS := 0;
           calc_PRV_TAX := NVL(l_bal_out_tab(1).balance_value,0);

           hr_utility.trace( 'CITY calc_PRV_GRS = '|| to_char(nvl(calc_PRV_GRS,0)));
           hr_utility.trace( 'CITY calc_PRV_TAX = '|| to_char(nvl(calc_PRV_TAX,0)));
--}
--{
--  This piece of code added for determining the Previous Pay Period County Level balances
--  For fixing bug # 3915176
--  Only County Tax withheld is derived from this piece of code not County level Wages
--  Code needs modification for deriving County level wages
--
        ELSIF p_fed_or_state = 'COUNTY' THEN
                hr_utility.trace('p_fed_or_state = COUNTY');
           SELECT  creator_id
             INTO  l_defined_balance_tab(1).defined_balance_id
             FROM  ff_user_entities
            WHERE  user_entity_name = 'COUNTY_WITHHELD_' || l_asg_type || '_JD_GRE_PTD'
              AND  legislation_code = 'US';

           hr_utility.trace('COUNTY_WITHHELD_' || l_asg_type || '_JD_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(1).defined_balance_id));

           l_defined_balance_tab(1).balance_value  := 0;
           l_context_tab(1).tax_unit_id            := p_tax_unit_id;
           l_context_tab(1).jurisdiction_code      := p_jurisdiction_code;
           l_context_tab(1).source_id              := null;
           l_context_tab(1).source_text            := null;
           l_context_tab(1).source_number          := null;
           l_context_tab(1).source_text2           := null;

           pay_balance_pkg.get_value (p_assignment_action_id => l_bal_assact,
                            p_defined_balance_lst            => l_defined_balance_tab,
                            p_context_lst                    => l_context_tab,
                            p_get_rr_route                   => FALSE,
                            p_get_rb_route                   => FALSE,
                            p_output_table                   => l_bal_out_tab);
           calc_PRV_GRS := 0;
           calc_PRV_TAX := NVL(l_bal_out_tab(1).balance_value,0);

           hr_utility.trace( 'COUNTY calc_PRV_GRS = '|| to_char(nvl(calc_PRV_GRS,0)));
           hr_utility.trace( 'COUNTY calc_PRV_TAX = '|| to_char(nvl(calc_PRV_TAX,0)));
--}
--{
--  This piece of code added for determining the Previous Pay Period School
--  District Level balances.  For fixing bug # 3915176
--  Only School Dist. Tax withheld is derived from this piece of code not School Dist. level Wages
--  Code needs modification for deriving School Dist. level wages
--
        ELSIF p_fed_or_state = 'SCHOOL' THEN
           hr_utility.trace('p_fed_or_state = SCHOOL');
           SELECT  creator_id
             INTO  l_defined_balance_tab(1).defined_balance_id
             FROM  ff_user_entities
            WHERE  user_entity_name = 'SCHOOL_WITHHELD_' || l_asg_type || '_JD_GRE_PTD'
              AND  legislation_code = 'US';

           hr_utility.trace('SCHOOL_WITHHELD_' || l_asg_type || '_JD_GRE_PTD' || ' = '
                  || to_char(l_defined_balance_tab(1).defined_balance_id));

           l_defined_balance_tab(1).balance_value  := 0;
           l_context_tab(1).tax_unit_id            := p_tax_unit_id;
           l_context_tab(1).jurisdiction_code      := p_jurisdiction_code;
           l_context_tab(1).source_id              := null;
           l_context_tab(1).source_text            := null;
           l_context_tab(1).source_number          := null;
           l_context_tab(1).source_text2           := null;

           pay_balance_pkg.get_value (p_assignment_action_id => l_bal_assact,
                            p_defined_balance_lst            => l_defined_balance_tab,
                            p_context_lst                    => l_context_tab,
                            p_get_rr_route                   => FALSE,
                            p_get_rb_route                   => FALSE,
                            p_output_table                   => l_bal_out_tab);
           calc_PRV_GRS := 0;
           calc_PRV_TAX := NVL(l_bal_out_tab(1).balance_value,0);

           hr_utility.trace( 'School Dist. calc_PRV_GRS = '|| to_char(nvl(calc_PRV_GRS,0)));
           hr_utility.trace( 'School Dist. calc_PRV_TAX = '|| to_char(nvl(calc_PRV_TAX,0)));
--}

        END IF;

        hr_utility.trace('End of GET_PRV_PTD_VALUES');
      return 0;
    --
EXCEPTION
     WHEN OTHERS THEN
          hr_utility.trace('Exception handler');
          hr_utility.trace('SQLCODE = ' || SQLCODE);
          hr_utility.trace('SQLERRM = ' || SUBSTR(SQLERRM,1,80));
          calc_PRV_GRS := 0;
          calc_PRV_TAX := 0;
          RETURN 0;
END get_prev_ptd_values;

/* This Function used to manage pl/table for work/tagged/home jurisdictions
   associated with an assignment

   Parameter        Purpose
   ---------        -------
   p_INITIALIZE     This parmaeter determines to process the pl/table
                    jurisdiction_codes_tbl. This parameter expects one of 3
                    values. (Y, N, F)
                    Y denotes  Initialize and populate the pl table
                    N denotes  Fetch jurisction that is stored next to the
                               jurisdiction assigned to p_jurisdiction_code
                    F denotes  Fecth the First jurisdiction stored in the pl
                               table

   This function is being called from US_TAX_VERTEX2 formula with P_INITIALIZE
   value as 'Y'. PL table is always initialized for each assignment.

   This function is called from US_TAX_VERTEX_HOME2 formula with P_INITIALIZE
   value as 'F'.

   This function is repeatedly called from US_TAX_VERTEX_WORK2 depending on the
   number of work jurisdiction stored in the pl table.For this call P_INITIALIZE
   value is set as 'N'.
*/
FUNCTION get_work_jurisdictions(p_assignment_action_id   number
                               ,p_INITIALIZE        in varchar2
                               ,p_jurisdiction_code in out NOCOPY varchar2
                               ,p_percentage        out NOCOPY number
                               )
RETURN varchar2
IS

     TOO_MANY_JURISDICTIONS    EXCEPTION;

     /*************************************************************
     * Maximum number of Work Jurisdictions that Quantum can Handle
     *************************************************************/
     /* bug 4383819, Changed max_jurisdiction to 200*/
     l_max_jurisdictions     number := 200;
     l_assignment_id         number;
     l_date_paid             date;
     l_date_earned           date;

     l_ee_id                 number;
     l_jurisdiction_code     varchar2(11);
     l_res_jurisdiction_code varchar2(11);
     l_jd_type               varchar2(2);

     l_percentage            number;
     p_array_count           number;
     l_index_value           number;

     l_jd_found              varchar2(1);
     l_return_value          varchar2(28);

     l_state                 varchar2(2);
     l_county                varchar2(120);
     l_city                  varchar2(30);
     l_zip_code              varchar2(10);

     l_res_state             varchar2(2);
     l_res_county            varchar2(120);
     l_res_city              varchar2(100);
     l_res_zip               varchar2(10);

     l_wah                   Varchar2(1);
     cnt                     number;
     l_counter               INTEGER;

     Cursor  Vertex_EE_Cursor is
        select pev1.element_entry_id,
               pev1.screen_entry_value    Jurisdiction_code,
               pev2.screen_entry_value    Percentage
        from   pay_element_entry_values_f pev1,
               pay_element_entry_values_f pev2,
               pay_element_entries_f pee,
               pay_element_links_f pel,
               pay_element_types_f pet,
               pay_input_values_f piv1,
               pay_input_values_f piv2
        where  pee.assignment_id        =  l_assignment_id
--        and  l_date_paid between pee.effective_start_date
          and  l_date_earned            between pee.effective_start_date
                                            and pee.effective_end_date
          and  pee.element_link_id      = pel.element_link_id
          and  pee.effective_start_date between pel.effective_start_date
                                            and pel.effective_end_date
          and  pel.element_type_id      = pet.element_type_id
          and  pet.element_name         = 'VERTEX'
          and  pee.effective_start_date between  pet.effective_start_date
                                            and pet.effective_end_date
          and  pee.element_entry_id     = pev1.element_entry_id
          and  pee.effective_start_date between  pev1.effective_start_date
                                            and pev1.effective_end_date
          and  pev1.input_value_id      = piv1.input_value_id
          and  pee.effective_start_date between  piv1.effective_start_date
                                            and piv1.effective_end_date
          and  piv1.name                = 'Jurisdiction'
          and  pee.element_entry_id     = pev2.element_entry_id
          and  pee.effective_start_date between pev2.effective_start_date
                                            and pev2.effective_end_date
          and  pev2.input_value_id      = piv2.input_value_id
          and  pee.effective_start_date between  piv2.effective_start_date
                                            and piv2.effective_end_date
          and  piv2.name                = 'Percentage';

     Cursor  tagged_earnings_Cursor is
        select /*+ INDEX (paa pay_assignment_actions_n51) */ distinct
              peev.element_entry_id,
              peev.screen_entry_value
         from pay_element_classifications pec
             ,pay_element_types_f         pet
             ,pay_element_entries_f       pee
             ,pay_element_links_f         pel
             ,pay_input_values_f          piv
             ,pay_element_entry_values_f  peev
        where pec.classification_name in
                   ( 'Earnings', 'Supplemental Earnings','Imputed Earnings' )
          and pet.classification_id      = pec.classification_id
          and pee.effective_start_date   between pet.effective_start_date
                                             and pet.effective_end_date
          and pee.assignment_id          = l_assignment_id
          and l_date_earned              between pee.effective_start_date
                                             and pee.effective_end_date
          and pet.element_type_id        = pel.element_type_id
          and pel.element_link_id        = pee.element_link_id
          and pee.effective_start_date   between pel.effective_start_date
                                             and pel.effective_end_date
          and pet.element_type_id        = piv.element_type_id
          and piv.name                   = 'Jurisdiction'
          and pee.effective_start_date   between piv.effective_start_date
                                             and piv.effective_end_date
          and pee.element_entry_id       = peev.element_entry_id
          and peev.input_value_id        = piv.input_value_id
          and pee.effective_start_date   between peev.effective_start_date
                                             and peev.effective_end_date
          and peev.screen_entry_value    is not null;

	  -- Get flag to determine assignment has only IT time.
	  CURSOR csr_use_it_flag (p_assignment_action_id IN NUMBER) IS
          SELECT   NVL(fed.fed_information1,'N'),paa.assignment_id
            FROM   pay_us_emp_fed_tax_rules_f fed,
                   pay_assignment_actions     paa,
	           pay_payroll_actions        ppa
           WHERE  paa.assignment_id = fed.assignment_id
             AND  paa.assignment_action_id = p_assignment_action_id
             AND  paa.payroll_action_id    = ppa.payroll_action_id
             AND  NVL(ppa.date_earned,ppa.effective_date)
	          BETWEEN fed.effective_start_date AND fed.effective_end_date;

	   l_use_it_flag       pay_us_emp_fed_tax_rules_f.fed_information1%TYPE;
	   l_payroll_id        pay_payrolls_f.payroll_id%TYPE;
	   l_time_period_id    pay_payroll_actions.time_period_id%TYPE;
	   l_return_flag       VARCHAR2(2);
           l_business_group_id NUMBER;
	   l_tax_unit_id       NUMBER;

BEGIN
--      hr_utility.trace_on(NULL,'SK_hr_us_ff_udf1');
      hr_utility.trace('Begin get_work_jurisdictions');
      hr_utility.trace('get_work_jurisdictions query 1');
      hr_utility.trace('Fetch Payroll Details ');

      SELECT    paa.assignment_id,
                ppa.EFFECTIVE_DATE,
                ppa.date_earned,
		ppa.time_period_id,
		ppa.payroll_id,
		ppa.business_group_id,
		paa.tax_unit_id
        INTO    l_assignment_id,
                l_date_paid,
                l_date_earned,
		l_time_period_id,
		l_payroll_id,
		l_business_group_id,
		l_tax_unit_id
        FROM pay_assignment_actions paa,
             pay_payroll_actions    ppa
       WHERE paa.assignment_action_id = p_assignment_action_id
         AND ppa.payroll_action_id    = paa.payroll_action_id;

      hr_utility.trace('Assignment_Action_Id :'||to_char(p_assignment_action_id));
      hr_utility.trace('Assignment_ID        :'||to_char(l_assignment_id));
      hr_utility.trace('Jurisdiction Code    :'||p_jurisdiction_code);
      hr_utility.trace('Initialize Flag      :'||p_initialize);
      hr_utility.trace('Date Earned          :'||to_char(l_date_earned,'dd-mon-yyyy'));
      hr_utility.trace('Date Paid            :'||to_char(l_date_paid,'dd-mon-yyyy'));

      OPEN csr_use_it_flag(p_assignment_action_id);
      FETCH csr_use_it_flag INTO l_use_it_flag,
                                 l_assignment_id;
      IF csr_use_it_flag%NOTFOUND THEN
         l_use_it_flag := 'N';
      END IF;
      CLOSE csr_use_it_flag;

      hr_utility.trace('Process Information Hours : '||l_use_it_flag);

      IF l_use_it_flag = 'Y' AND p_initialize = 'Y' THEN
      --{
        g_use_it_flag := 'Y';
        hr_utility.trace('EMJT: Calling get_it_work_jurisdiction to process Information Hours');
        l_return_flag := get_it_work_jurisdictions
	                          (p_assignment_action_id => p_assignment_action_id
				  ,p_initialize           => p_initialize
				  ,p_jurisdiction_code    => p_jurisdiction_code
				  ,p_percentage           => p_percentage
				  ,p_assignment_id        => l_assignment_id
				  ,p_date_paid            => l_date_paid
				  ,p_date_earned          => l_date_earned
				  ,p_time_period_id       => l_time_period_id
				  ,p_payroll_id           => l_payroll_id
				  ,p_business_group_id    => l_business_group_id
				  ,p_tax_unit_id          => l_tax_unit_id
				  );
           p_jurisdiction_code := 'NULL';
           p_percentage := 0;
	   hr_utility.trace(' Returning after call to get_it_work_jurisdiction');
        RETURN('0');
      --}
      END IF; -- l_use_it_flag = 'Y'


      IF l_use_it_flag = 'N' THEN
      --{
      hr_utility.trace('Taxation would use W-4% configured for the assignment ');
      cnt :=0;
      IF p_initialize = 'Y' THEN
      -- LOAD the pl Table and return only NULL jurisdiction
      --{
         hr_utility.trace('get_work_jurisdictions || p_initialize = Y');
	 g_use_it_flag := 'N';
         --
         -- initialize the PL/SQL tables
         --
         jurisdiction_codes_tbl.delete;
         res_jurisdiction_codes_tbl.delete;  -- Added for Bug # 4715851
         state_processed_tbl.delete;
         county_processed_tbl.delete;
         city_processed_tbl.delete;

         hr_utility.trace('get_work_jurisdictions plsql tables cleared');

    --   GET the RESIDENT jurisdictions and load in to the *_processed_tables
    --
        hr_utility.trace('2nd Query in get_work_jurisdictions for fetching '
                         ||' resident address details');
        SELECT nvl(ADDR.add_information17,ADDR.region_2)  state,
               nvl(ADDR.add_information19,ADDR.region_1)  county,
               nvl(ADDR.add_information18,ADDR.town_or_city) city,
               nvl(ADDR.add_information20,ADDR.postal_code)  zip,
               nvl(ASSIGN.work_at_home,'N')
        INTO   l_res_state,
               l_res_county,
               l_res_city,
               l_res_zip,
               l_wah
        FROM   per_addresses                        ADDR
              ,per_all_assignments_f                  ASSIGN
        WHERE  l_date_earned BETWEEN ASSIGN.effective_start_date
                                 AND ASSIGN.effective_end_date
        and    ASSIGN.assignment_id = l_assignment_id
        and    ADDR.person_id	    = ASSIGN.person_id
        and    ADDR.primary_flag    = 'Y'
        and    l_date_earned        BETWEEN nvl(ADDR.date_from, l_date_earned)
        			        AND nvl(ADDR.date_to, l_date_earned);

        hr_utility.trace('2nd query returned res address details');
        l_res_jurisdiction_code := hr_us_ff_udfs.addr_val(l_res_state
                                                        , l_res_county
                                                        , l_res_city
                                                        , l_res_zip);

        -- IF this is a user defined city IE: city_code = 'U***' the change
        -- the city code to all 0 (zeros)

        IF substr(l_res_jurisdiction_code,8,1) = 'U' THEN
           l_res_jurisdiction_code := substr(l_res_jurisdiction_code,1,7) ||
                                                                       '0000' ;
        END IF;

        hr_utility.trace('Resident Jurisdiction Code  = ' ||
                                                       l_res_jurisdiction_code);
        hr_utility.trace('Home Workers Flag           = ' || l_wah);

        IF l_wah = 'N' THEN
        --{
        -- Get the vertex element Entries
           OPEN Vertex_EE_Cursor;
           FETCH Vertex_EE_Cursor into
                 l_ee_id,
                 l_jurisdiction_code,
                 l_percentage;

           hr_utility.trace('open fetch vertex_ee_cursor');
           LOOP
               hr_utility.trace('Processing Tagged Jurisdiction Code'||
                                                           l_jurisdiction_code);
               EXIT WHEN Vertex_EE_Cursor%NOTFOUND;
               -- IF this is a user defined city IE: city_code = 'U***' the
               -- change the city code to all 0 (zeros)
               if substr(l_jurisdiction_code,8,1) = 'U' then
                  l_jurisdiction_code := substr(l_jurisdiction_code,1,7) ||
                                                                        '0000' ;
               end if;
               IF nvl(l_percentage,0) <> 0 THEN
               --{
                  IF  jurisdiction_codes_tbl.count >= l_max_jurisdictions THEN
                         raise TOO_MANY_JURISDICTIONS;
                         hr_utility.trace('too many jurisdictions');
                  END IF;
                  hr_utility.trace('Jurisdiction Code'|| l_jurisdiction_code ||
                                       ' loaded into pl table');
                  jurisdiction_codes_tbl( to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                    ).jurisdiction_code := l_jurisdiction_code;
                  jurisdiction_codes_tbl( to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                        ).percentage :=  l_percentage;
                  jurisdiction_codes_tbl( to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                        ).hours := 0;
                  jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                       ).jd_type := 'WK';
               --}
               END IF;
               FETCH Vertex_EE_Cursor into
                     l_ee_id,
                     l_jurisdiction_code,
                     l_percentage;
           END LOOP;
           hr_utility.trace('end of loop 1 vertex_ee_cursor');
           CLOSE Vertex_EE_Cursor;
        --}
        END IF;   -- if l_wah = 'N' then

        --   Look for and load tagged earnings;
        OPEN tagged_earnings_Cursor;
        FETCH tagged_earnings_Cursor into
              l_ee_id,
              l_jurisdiction_code;

        hr_utility.trace(' open fetch tagged_earnings_cursor');
        hr_utility.trace('loop tagged earnings cursor');

        LOOP
              hr_utility.trace('Processing Tagged Jurisdiction Code'||
                                                           l_jurisdiction_code);
              EXIT WHEN tagged_earnings_Cursor%NOTFOUND;
              -- IF this is a user defined city IE: city_code = 'U***' the
              -- change the city code to all 0 (zeros)

              IF substr(l_jurisdiction_code,8,1) = 'U' then
                        l_jurisdiction_code := substr(l_jurisdiction_code,1,7)
                                                                     || '0000' ;
              END IF;
              --  1) see if JD exists in plsql table
              --  2) if not add the JD, to the plsql table with a 0 percent.
              IF jurisdiction_codes_tbl.EXISTS(
                                    to_number(substr(l_jurisdiction_code,1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                               substr(l_jurisdiction_code,8,4) )
                                             ) THEN
              --{
                    NULL;
              --}
              ELSE
              --{
                 IF  jurisdiction_codes_tbl.count >= l_max_jurisdictions THEN
                     raise TOO_MANY_JURISDICTIONS;
                     hr_utility.trace('too many jurisdictions');
                 END IF;
                 hr_utility.trace('Jurisdiction Code'|| l_jurisdiction_code ||
                                       ' loaded into pl table');

                 jurisdiction_codes_tbl( to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                     ).jurisdiction_code := l_jurisdiction_code;
                 jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                       ).percentage :=  0;
                  jurisdiction_codes_tbl( to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                        ).hours := 0;

              --}
              END IF;
              -- This is set JD_TYPE for Tagged earnings
              if l_jurisdiction_code = l_res_jurisdiction_code  then
                    jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                       ).jd_type := 'RT';
              else
                    jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                       ).jd_type := 'TG';
              end if;

              FETCH tagged_earnings_Cursor into
                    l_ee_id,
                    l_jurisdiction_code;
                 hr_utility.trace('fetch 2 from cursor tagged_earnings_Cursor');

        END LOOP;
        hr_utility.trace('end of loop 2 tagged_earnings_Cursor');
        CLOSE tagged_earnings_Cursor;
        --
        -- This section is determine Primary Work Jurisdiction for the assignment
        --
        IF l_wah = 'N' THEN  -- Home Workers flag is set to NO
             --{
             -- Find and load the primary Work location to the jurisdiction.
                SELECT nvl(HRLOC.loc_information18,HRLOC.town_or_city),
                           nvl(HRLOC.loc_information19,HRLOC.region_1),
                           nvl(HRLOC.loc_information17,HRLOC.region_2),
                           substr(nvl(HRLOC.loc_information20,HRLOC.postal_code)
                                                                           ,1,5)
                  INTO   l_city,
                         l_county,
                         l_state,
                         l_zip_code
                  FROM   hr_locations             HRLOC
                       , hr_soft_coding_keyflex   HRSCKF
                       , per_all_assignments_f    ASSIGN
                 WHERE   l_date_earned BETWEEN ASSIGN.effective_start_date
                                           AND ASSIGN.effective_end_date
                   AND   ASSIGN.assignment_id          = l_assignment_id
                   AND   ASSIGN.soft_coding_keyflex_id = HRSCKF.soft_coding_keyflex_id
                   AND   nvl(HRSCKF.segment18,
                                   ASSIGN.location_id) = HRLOC.location_id;
                 l_jd_found := 'N';
                 hr_utility.trace('Primary work location query');
                 l_jurisdiction_code := hr_us_ff_udfs.addr_val(l_state,
                                                               l_county,
                                                               l_city,
                                                               l_zip_code);
                 hr_utility.trace('Primary work loc JD CODE = ' ||
                                                           l_jurisdiction_code);

                 -- IF this is a user defined city IE: city_code = 'U***' the
                 -- change the city code to all 0 (zeros)
                 if substr(l_jurisdiction_code,8,1) = 'U' then
                    l_jurisdiction_code := substr(l_jurisdiction_code,1,7) ||
                                                                        '0000' ;
                 end if;

                 IF jurisdiction_codes_tbl.EXISTS(
                                    to_number(substr(l_jurisdiction_code,1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                               substr(l_jurisdiction_code,8,4) )
                                             ) THEN
                 --{
                    hr_utility.trace('Work Jurisdiction already loaded.'||
                                    ' Updating JD_Type');
                    if l_jurisdiction_code = l_res_jurisdiction_code  then
                       jurisdiction_codes_tbl(to_number(substr(
                                                    l_jurisdiction_code, 1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                       ).jd_type := 'RW';
                    else
                       jurisdiction_codes_tbl(to_number(substr(
                                                    l_jurisdiction_code, 1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                             ).jd_type := 'WK';
                    end if;
                 --}
                 ELSE
                 --{
                   hr_utility.trace('Jurisdiction Code'|| l_jurisdiction_code ||
                                       ' loaded into pl table');
                    IF  jurisdiction_codes_tbl.count >= l_max_jurisdictions THEN
                        raise TOO_MANY_JURISDICTIONS;
                        hr_utility.trace('too many jurisdictions');
                    END IF;
                    hr_utility.trace('Populating table with Pri work location');
                    jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                      1,2) || substr(l_jurisdiction_code,4,3) ||
                                               substr(l_jurisdiction_code,8,4) )
                                     ).jurisdiction_code := l_jurisdiction_code;
                    jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                      1,2) || substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                       ).percentage :=  0;
                    jurisdiction_codes_tbl(to_number(substr(
                                                    l_jurisdiction_code, 1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                       ).jd_type := 'WK';
                    jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                                                         1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                        ).hours := 0;

                 --}
                 END IF;
        --}
        END IF;   -- if l_wah = 'N' then
        --   Load the resident jurisdiction if not already loaded via one of the
        --   other queries.  Note the resident jurisdiction is querried at the
        --   begining of this function.
        hr_utility.trace('Processing Resident jurisdiction ');
        IF jurisdiction_codes_tbl.EXISTS(
                                    to_number(substr(l_res_jurisdiction_code,
                                                                         1,2) ||
                                          substr(l_res_jurisdiction_code,4,3) ||
                                          substr(l_res_jurisdiction_code,8,4) )
                                        ) THEN
        --{
           hr_utility.trace('Resident jurisdiction exist in pl table');
           IF (l_wah = 'N')  THEN
	   --{
	      IF (jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code, 1,2) ||
                                                   substr(l_res_jurisdiction_code, 4,3) ||
                                                   substr(l_res_jurisdiction_code, 8,4) )
                                   ).jd_type <> 'RT')
	      THEN
                  jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code, 1,2) ||
                                                   substr(l_res_jurisdiction_code, 4,3) ||
                                                   substr(l_res_jurisdiction_code, 8,4) )
                                   ).jd_type := 'RW';
	      END IF;
           --}
	   ELSE
	   --{
  	      jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code, 1,2) ||
                                               substr(l_res_jurisdiction_code, 4,3) ||
                                               substr(l_res_jurisdiction_code, 8,4) )
                                   ).jd_type := 'HW';
           --}
	   END IF;
	--}
        ELSE
        --{
        --  If Residence jurisdiction does not exist in the pl/sql table
           IF  jurisdiction_codes_tbl.count >= l_max_jurisdictions THEN
               raise TOO_MANY_JURISDICTIONS;
               hr_utility.trace('too many jurisdictions');
           END IF;
           hr_utility.trace('Populating pl table for Resident Jurisdiction');
	   --
	   -- For bug 4715851 res_jurisdiction_codes_tbl used
	   --    in place of jurisdiction_codes_tbl
           IF l_wah = 'N' THEN
           --{
             res_jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code,1,2) ||
                                                substr(l_res_jurisdiction_code,4,3) ||
                                                substr(l_res_jurisdiction_code,8,4) )
                                 ).jurisdiction_code := l_res_jurisdiction_code;

             res_jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code,1,2) ||
                                                  substr(l_res_jurisdiction_code,4,3) ||
                                                  substr(l_res_jurisdiction_code,8,4) )
                                       ).percentage :=  0;
             res_jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code,1,2) ||
                                                  substr(l_res_jurisdiction_code,4,3) ||
                                                  substr(l_res_jurisdiction_code,8,4))
                                       ).jd_type := 'RS';
             res_jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code,1,2) ||
                                                  substr(l_res_jurisdiction_code, 4,3) ||
                                                  substr(l_res_jurisdiction_code, 8,4))
                                       ).hours := 0;
           --}
           ELSE
           --{
             jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code,1,2) ||
                                                substr(l_res_jurisdiction_code,4,3) ||
                                                substr(l_res_jurisdiction_code,8,4) )
                                 ).jurisdiction_code := l_res_jurisdiction_code;

             jurisdiction_codes_tbl( to_number(substr(l_res_jurisdiction_code,
                                                                         1,2) ||
                                          substr(l_res_jurisdiction_code,4,3) ||
                                          substr(l_res_jurisdiction_code,8,4) )
                                   ).percentage :=  100;
             jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code, 1,2) ||
                                              substr(l_res_jurisdiction_code, 4,3) ||
                                              substr(l_res_jurisdiction_code, 8,4) )
                                   ).jd_type := 'HW';
             jurisdiction_codes_tbl(to_number(substr(l_res_jurisdiction_code, 1,2) ||
                                              substr(l_res_jurisdiction_code, 4,3) ||
                                              substr(l_res_jurisdiction_code, 8,4) )
                                   ).hours := 0;
           --}
           END IF; --l_wah = 'N'
	--}
        END IF;
        hr_utility.trace('Jurisdiction Table count = '||
                                         to_char(jurisdiction_codes_tbl.COUNT));
        hr_utility.trace('Return section begin');
        --As Initialize section doesn't expect the return value
        p_jurisdiction_code := 'NULL';
        p_percentage := 0;
	RETURN('0');

      --}End of Initialize = 'Y'
      END IF;
      --}
      END IF; --l_use_it_flag = 'N' THEN

      IF p_initialize = 'F' THEN
      -- This is to get first jurisdiction loaed into pl table
      --                                                  jurisdiction_codes_tbl
      -- BEGIN
        IF jurisdiction_codes_tbl.COUNT = 0 THEN
        --{
           hr_utility.trace('Table count = 0');
           p_jurisdiction_code := '';
           p_percentage := 0;
        --}
        ELSE
	--{
           hr_utility.trace('Table count <> 0');
           p_jurisdiction_code :=
                jurisdiction_codes_tbl(jurisdiction_codes_tbl.FIRST).jurisdiction_code;
           p_percentage :=
                jurisdiction_codes_tbl(jurisdiction_codes_tbl.FIRST).percentage;
        --}
        END IF;
        hr_utility.trace('p_jurisdiction_code = ' || p_jurisdiction_code);
        hr_utility.trace('p_percentage        = ' || to_char(p_percentage));
	hr_utility.trace('Done with p_initialize F');
      --
      --} End of Initialize = 'F'
      ELSIF p_initialize = 'C' THEN
      -- This is to get the number of jurisdiction associated with
      -- a given assignment
      -- BEGIN
        hr_utility.trace('This is to count no of jurisdiction associated with');
        hr_utility.trace('all the element entries defined for the assignment ');
        cnt := 0;
        IF jurisdiction_codes_tbl.COUNT >= 1
	THEN
        --{
           cnt       := jurisdiction_codes_tbl.COUNT;
           l_counter := NULL;
           l_counter := jurisdiction_codes_tbl.FIRST;
           WHILE l_counter IS NOT NULL
	   LOOP
                 if (jurisdiction_codes_tbl(l_counter).jd_type = 'RS')
		 then
	            cnt := cnt - 1;
		 end if;
                 l_counter := jurisdiction_codes_tbl.NEXT(l_counter);
           END LOOP;
	   p_percentage := cnt;
        --}
        END IF;
        hr_utility.trace('Work Jurisdiction Table Count = '||to_char(cnt));
	hr_utility.trace('Done with p_initialize=C');

      --} End of Initialize = 'C'
      ELSIF p_initialize = 'N' THEN

        hr_utility.trace('Initialize = n');
        hr_utility.trace('Fetching Next Jurisdiction stored in PL Table');
        IF jurisdiction_codes_tbl.EXISTS(
                                    to_number(substr(p_jurisdiction_code,1,2) ||
                                              substr(p_jurisdiction_code,4,3) ||
                                              substr(p_jurisdiction_code,8,4) )
                                        ) THEN

          IF jurisdiction_codes_tbl.NEXT(to_number(substr(p_jurisdiction_code,1,2) ||
                                                   substr(p_jurisdiction_code,4,3) ||
                                                   substr(p_jurisdiction_code,8,4) )
                                        ) is NULL THEN
                 p_jurisdiction_code := 'NULL';
                 p_percentage := 0;
                 hr_utility.trace('Next jurisdiction is NULL');
          ELSE -- When next jurisdiction is Not Null
	  --{
	  -- This is to fetch next jurisdiction from the pl table
	  -- when information time is being processed
	  --{
              hr_utility.trace('Fetching Next Jurisdiction');
	      l_index_value :=jurisdiction_codes_tbl.next (
                                to_number(substr(p_jurisdiction_code,1,2) ||
                                          substr(p_jurisdiction_code,4,3) ||
                                          substr(p_jurisdiction_code,8,4) )
                                         );
              p_jurisdiction_code :=
                  jurisdiction_codes_tbl(l_index_value).jurisdiction_code;
              p_percentage := jurisdiction_codes_tbl(l_index_value).percentage;
          --}
          END IF;
        --}
        ELSE -- if jurisdiction code passed does not exist in PL table
        --{
             hr_utility.trace('Jurisdiction Code '||p_jurisdiction_code||
                              ' passed does not exist in PL table ');
                   p_jurisdiction_code := 'NULL';
                   p_percentage := 0;
                   hr_utility.trace('Next jurisdiction is NULL');
        --}
        END IF;
        hr_utility.trace('p_jurisdiction_code = ' || p_jurisdiction_code);
        hr_utility.trace('p_percentage        = ' || to_char(p_percentage));
        hr_utility.trace('End of get_work_jurisdictions for p_initialize=N');
      --}
      END IF;
      --
      -- This section is used only for debug
      hr_utility.trace('======================================================');
      IF jurisdiction_codes_tbl.COUNT > 0 THEN
            hr_utility.trace('Display the value of jurisdiction_codes_tbl');
         l_jurisdiction_code :=
         jurisdiction_codes_tbl(jurisdiction_codes_tbl.FIRST).jurisdiction_code;
         l_percentage :=
                jurisdiction_codes_tbl(jurisdiction_codes_tbl.FIRST).percentage;
         l_jd_type := jurisdiction_codes_tbl(jurisdiction_codes_tbl.FIRST).jd_type;
         hr_utility.trace('Jurisdiction_code 1st = '|| l_jurisdiction_code);
         hr_utility.trace('Percentage        1st = '|| to_char(l_percentage));
         hr_utility.trace('JD_Type           1st = '|| l_jd_type);
         l_jurisdiction_code :=
         jurisdiction_codes_tbl(jurisdiction_codes_tbl.LAST).jurisdiction_code;
         l_percentage :=
                 jurisdiction_codes_tbl(jurisdiction_codes_tbl.LAST).percentage;
         l_jd_type :=  jurisdiction_codes_tbl(jurisdiction_codes_tbl.LAST).jd_type;

         hr_utility.trace('Jurisdiction_code last = '|| l_jurisdiction_code);
         hr_utility.trace('Percentage        last = '|| to_char(l_percentage));
         hr_utility.trace('JD_Type           last = '|| l_jd_type);
         hr_utility.trace('======================================================');
         --
         -- End of pl/sql table debug messages
         --
         hr_utility.trace('Display the value of jurisdiction_codes_tbl');
         hr_utility.trace('End get_work_jurisdictions');

       END IF; --jurisdiction_codes_tbl.COUNT > 0

      RETURN ('0');
  /*EXCEPTION
    WHEN NO_DATA_FOUND THEN
       hr_utility.trace('Exception raised NO_DATA_FOUND in '||
                                                      'get_work_jurisdictions');
       p_jurisdiction_code := 'NULL';
       p_percentage := 0;
       return ('0');
  WHEN TOO_MANY_JURISDICTIONS THEN
       hr_utility.set_message(801, 'PAY_75242_PAY_TOO_MANY_JD');
       hr_utility.set_message_token('MAX_WORK_JDS', l_max_jurisdictions);
       hr_utility.raise_error;       -- create a new message--
       raise;
  WHEN OTHERS THEN
       hr_utility.trace('Exception raised OTHERS in '||
                                                      'get_work_jurisdictions');
       hr_utility.trace('Mesg: '||substr(sqlerrm,1,45));
       p_jurisdiction_code := 'NULL';
       p_percentage := 0;
       return ('0');*/

-- End of Function get_work_jurisdictions
END get_work_jurisdictions;
--

FUNCTION Jurisdiction_processed( p_jurisdiction_code in varchar2
                                 ,p_jd_level          in varchar
                               )
  RETURN varchar2
  IS
BEGIN
  IF p_jd_level = 'STATE' THEN
     IF state_processed_tbl.EXISTS( to_number(substr(p_jurisdiction_code,1,2))
                                  ) THEN
        RETURN 'Y';
     ELSE -- Added this state Jurisdiction to the state_processed_tbl table
     state_processed_tbl( to_number(substr(p_jurisdiction_code,1,2))
                        ) := 'Y';
        RETURN 'N';
     END IF;
  ELSIF p_jd_level = 'COUNTY' THEN
     IF county_processed_tbl.EXISTS(to_number(substr(p_jurisdiction_code,1,2) ||
                                              substr(p_jurisdiction_code,4,3) )
                                   ) THEN
        RETURN 'Y';
     ELSE -- Added this state Jurisdiction to the county_processed_tbl table
        county_processed_tbl(to_number(substr(p_jurisdiction_code,1,2) ||
                                       substr(p_jurisdiction_code,4,3) )
                             ) := 'Y';
        RETURN 'N';
     END IF;
  ELSIF p_jd_level = 'CITY' THEN

    IF city_processed_tbl.EXISTS( to_number(substr(p_jurisdiction_code,1,2) ||
                                            substr(p_jurisdiction_code,4,3) ||
                                            substr(p_jurisdiction_code,8,4) )
                                  ) THEN
        RETURN 'Y';
    ELSE -- Added this state Jurisdiction to the city_processed_tbl table
        city_processed_tbl( to_number(substr(p_jurisdiction_code,1,2) ||
                                      substr(p_jurisdiction_code,4,3) ||
                                      substr(p_jurisdiction_code,8,4) )
                          ) := 'Y';
        RETURN 'N';
    END IF;

  ELSE
     return('N');
  END IF;

EXCEPTION
WHEN OTHERS THEN
     return ('N');
END Jurisdiction_processed;

FUNCTION get_fed_prev_ptd_values(
                       p_assignment_action_id     number,           -- context
                       p_tax_unit_id              number,           -- context
                       p_fed_or_state             varchar2,         -- parameter
                       p_regular_aggregate        number,           -- parameter
                       calc_PRV_GRS               OUT nocopy number,-- parameter
                       calc_PRV_TAX               OUT nocopy number)-- parameter
RETURN NUMBER IS
   l_dummy_value   number;
BEGIN
--{
    l_dummy_value  := hr_us_ff_udf1.get_prev_ptd_values(p_assignment_action_id
                                                       ,p_tax_unit_id
                                                       ,'00-000-0000'
                                                       ,p_fed_or_state
                                                       ,p_regular_aggregate
                                                       ,calc_PRV_GRS
                                                       ,calc_PRV_TAX );

    return 0;
    --
EXCEPTION
WHEN OTHERS THEN
     hr_utility.trace('Exception handler');
     hr_utility.trace('SQLCODE = ' || SQLCODE);
     hr_utility.trace('SQLERRM = ' || SUBSTR(SQLERRM,1,80));
     calc_PRV_GRS := 0;
     calc_PRV_TAX := 0;
     RETURN 0;
--}
END get_fed_prev_ptd_values;

FUNCTION get_jd_percent(p_jurisdiction_code                VARCHAR2 -- Parameter
                       ,p_jd_level                         VARCHAR2 -- Parameter
                       ,p_hours_to_accumulate   OUT nocopy NUMBER   -- Parameter
		       ,p_wages_to_accrue_flag  OUT nocopy VARCHAR2 -- Parameter
                         )
RETURN NUMBER
IS
  l_jd_level    number;
  l_pad         number;
  l_entry_jd    number;
  l_max_jd      number;
  l_temp_jd     number;
  l_percentage  number;
  l_index_value number;
  l_return      number;
begin
--{
hr_utility.trace('IN get_jd_percent');
hr_utility.trace('get_jd_percent Use Information Hours Flag =>'||hr_us_ff_udf1.g_use_it_flag);
IF hr_us_ff_udf1.g_use_it_flag = 'Y'  THEN
--{
   hr_utility.trace('get_jd_percent Calling Function get_it_jd_percent');
   l_percentage :=
     hr_us_ff_udf1.get_it_jd_percent(p_jurisdiction_code    => p_jurisdiction_code
				    ,p_jd_level             => p_jd_level
                                    ,p_hours_to_accumulate  => p_hours_to_accumulate
                                    ,p_wages_to_accrue_flag => p_wages_to_accrue_flag
				    );
   hr_utility.trace('get_it_jd_percent Percentage Returned for '
                                            ||p_jd_level||' => '||to_char(l_percentage));
--   RETURN l_percentage;
--}
ELSE
--{
      hr_utility.trace('get_jd_percent p_jd_level = ' || p_jd_level) ;
      if p_jd_level = 'COUNTY' THEN
         l_jd_level := 5;
      else
         l_jd_level := 2;
      end if;

      if substr(p_jurisdiction_code,1,1) = 0 then
         l_pad := 8;
         l_jd_level := l_jd_level - 1;
      else
         l_pad := 9;
      end if;

      hr_utility.trace('get_jd_percent l_pad      = ' || to_char(l_pad)) ;
      hr_utility.trace('get_jd_percent l_jd_level = ' || to_char(l_jd_level)) ;

      l_entry_jd := to_number(substr(p_jurisdiction_code,1,2) ||
                              substr(p_jurisdiction_code,4,3) ||
                              substr(p_jurisdiction_code,8,4) );

      l_temp_jd  := rpad(substr(l_entry_jd,1,l_jd_level),l_pad,0);
      l_max_jd   := rpad(substr(l_entry_jd,1,l_jd_level),l_pad,9);

      hr_utility.trace('get_jd_percent l_temp_jd = ' || to_char(l_temp_jd)) ;
      hr_utility.trace('get_jd_percent l_max_jd  = ' || to_char(l_max_jd)) ;
      hr_utility.trace('get_jd_percent next      = ' || to_char(jurisdiction_codes_tbl.NEXT(l_temp_jd -1 ))) ;

     if jurisdiction_codes_tbl.NEXT(l_temp_jd -1 ) is NULL
        OR jurisdiction_codes_tbl.NEXT(l_temp_jd -1 ) > l_max_jd  THEN
     --{
          l_percentage := 0;
     --}
     else
     --{
          l_percentage := 0;
          l_index_value := jurisdiction_codes_tbl.NEXT(l_temp_jd - 1 );
          WHILE l_index_value is not null LOOP
          --{
             l_percentage := l_percentage + jurisdiction_codes_tbl(l_index_value).percentage;

             IF jurisdiction_codes_tbl.NEXT(l_index_value) is NULL
                OR jurisdiction_codes_tbl.NEXT(l_index_value) > l_max_jd  THEN
             --{
                l_index_value := NULL;
             --}
             ELSE
             --{
                l_index_value := jurisdiction_codes_tbl.NEXT(l_index_value);
             --}
             END IF;
          --}
          END LOOP;
     --}
     end if;
     hr_utility.trace('get_jd_percent Percentage Returned for '
                                            ||p_jd_level||' => '||to_char(l_percentage));
--     RETURN l_percentage;

END IF;--IF g_use_it_flag = 'Y'
RETURN l_percentage;
EXCEPTION
     WHEN OTHERS THEN
          RETURN 0;
--}
end get_jd_percent;
--
-- This function would be used to fetch Jurisdiction type stored against a
-- jurisdiction in the pl table jurisdiction_codes_tbl. This pl table is
-- populated in function get_work_jurisdiction
--
FUNCTION get_jurisdiction_type(p_jurisdiction_code varchar2)
  RETURN varchar2
IS
l_jurisdiction_code	varchar2(100);
l_jd_type           varchar2(100);
BEGIN
--{
    l_jurisdiction_code	:= p_jurisdiction_code;
    l_jd_type := 'NL';
    IF jurisdiction_codes_tbl.EXISTS(
                                    to_number(substr(l_jurisdiction_code,1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                               substr(l_jurisdiction_code,8,4) )
                                    ) THEN
    --{
      l_jd_type := jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                                                        1,2) ||
                                             substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                           ).jd_type;
    --}
    ELSIF res_jurisdiction_codes_tbl.EXISTS(
                                    to_number(substr(l_jurisdiction_code,1,2) ||
                                              substr(l_jurisdiction_code,4,3) ||
                                               substr(l_jurisdiction_code,8,4) )
                                    ) THEN
    --{
      l_jd_type := res_jurisdiction_codes_tbl(to_number(substr(l_jurisdiction_code,
                                                                        1,2) ||
                                             substr(l_jurisdiction_code,4,3) ||
                                              substr(l_jurisdiction_code,8,4) )
                                           ).jd_type;
    --}
    ELSE
    --{
        l_jd_type := 'NL';
    --}
    END IF;
    return(l_jd_type);

EXCEPTION
WHEN OTHERS THEN
     return ('NL');
--}
END get_jurisdiction_type;

--
  -- This function is used to fetch the status of Employee. It is used for determining
  -- whether executive weekly maximum should be applicable for a employee.
--
FUNCTION get_executive_status(p_assignment_id number,
                              p_date_earned date,
			      p_jurisdiction_code varchar2
			      )
  RETURN varchar2
IS

CURSOR get_executive_status
 IS
 select sta_information2
   from pay_us_emp_state_tax_rules_f
  where assignment_id = p_assignment_id
   and  p_date_earned between effective_start_date and effective_end_date
   and  jurisdiction_code = p_jurisdiction_code;

l_executive_status varchar2(1) := 'N';
BEGIN

 OPEN get_executive_status;
  FETCH get_executive_status INTO  l_executive_status;
 CLOSE get_executive_status;
  return(nvl(l_executive_status,'N'));
EXCEPTION
WHEN OTHERS THEN
     return ('N');

END get_executive_status;

-- Bug#2122611
  -- This function used for determining whether Workers compensation
  -- amount should be deducted in the current pay period or not.
--

FUNCTION get_wc_flag(p_assignment_id number,
                              p_date_earned date,
			      p_wc_flat_rate_period varchar2
			      )
  RETURN varchar2
IS

l_last_period_for_wc varchar2(1) := 'N';
l_pay_period_start_date date;
l_pay_period_end_date date;
l_payroll_id number(9); /*7520832*/
l_person_id number(10);
l_date date;

/* Bug#8592027: Changes start */
l_regular_payment_date date;
--l_nearest_end_date date;
l_nearest_check_date date;
/* Bug#8592027: Changes end */

l_valid number(1);

-- Get start and end dates of the pay period for the given date_earned
CURSOR csr_get_period_dates IS
select ptp.start_date,
       ptp.end_date,
       ptp.regular_payment_date, /* Bug#8592027 */
       ptp.payroll_id,  /*7520832*/
       paaf.person_id   /* 765549 */
  from per_all_assignments_f paaf,
       pay_all_payrolls_f papf,
       per_time_periods ptp
 where paaf.payroll_id = papf.payroll_id
   and papf.payroll_id = ptp.payroll_id
   and assignment_id   = p_assignment_id
   and p_date_earned between ptp.start_date
                         and ptp.end_date
   and p_date_earned between papf.effective_start_date
                         and papf.effective_end_date
   and p_date_earned between paaf.effective_start_date
                         and paaf.effective_end_date;

/* Checks whether the employee is valid as of last date of the pay period.
   Bug#7655549: per_periods_of_service should be used to check employee's
                Validity.  */
CURSOR CSR_GET_VALID_EMPLOYMENT IS
 select 1
   from per_periods_of_service
  where person_id = l_person_id
    and l_date between date_start and nvl(actual_termination_date,to_date('12/31/4712','MM/DD/YYYY'));


/*7520832: Cursor to fetch nearest pay period to the WC effective date*/
CURSOR CSR_GET_NEAREST_PERIOD IS
  select max(nvl(regular_payment_date,end_date))
    from per_time_periods
   where payroll_id = l_payroll_id
     and nvl(regular_payment_date,end_date) <= l_date;

BEGIN

 hr_utility.trace('In hr_us_ff_udf1.get_wc_flag() function');
 hr_utility.trace('**PARAMETERS**');
 hr_utility.trace('p_assignment_id: ' || to_char(p_assignment_id));
 hr_utility.trace('p_date_earned: ' || to_char(p_date_earned));
 hr_utility.trace('p_wc_flat_rate_period: ' || p_wc_flat_rate_period);
 OPEN csr_get_period_dates;

 FETCH csr_get_period_dates INTO  l_pay_period_start_date,l_pay_period_end_date,
                                  l_regular_payment_date,
                                  l_payroll_id,l_person_id; /*7520832*/
 IF csr_get_period_dates%NOTFOUND THEN
  hr_utility.trace('Pay period for the given date_earned is NOT found');
  CLOSE csr_get_period_dates;
  return (l_last_period_for_wc);
 END IF;

 IF (p_wc_flat_rate_period = 'YEAR') THEN
   l_date := to_date( '31-12-' || to_char(l_pay_period_start_date,'yyyy'),'DD-MM-YYYY');
  -- last day of the year

 ELSIF (p_wc_flat_rate_period = 'MONTH')  THEN
   l_date := last_day(l_pay_period_start_date);
  -- last day of the month

 ELSIF (p_wc_flat_rate_period = 'QUARTER') THEN
   l_date := add_months(trunc(l_pay_period_start_date,'YY'),3*to_number(to_char(l_pay_period_start_date,'Q')))-1;
     -- last day of the Quarter
 END IF;
   hr_utility.trace('Date to check the Validity: ' || to_char(l_date));
/*7520832: Changes starts*/

/*
if (l_date between l_pay_period_start_date and l_pay_period_end_date ) then
   l_last_period_for_wc := 'Y'; -- deduct WC in the current pay period.
else
   l_last_period_for_wc := 'N';
end if;
  */
OPEN CSR_GET_NEAREST_PERIOD;

 --FETCH CSR_GET_NEAREST_PERIOD INTO  l_nearest_end_date;
 FETCH CSR_GET_NEAREST_PERIOD INTO  l_nearest_check_date;

 IF CSR_GET_NEAREST_PERIOD%NOTFOUND THEN
  hr_utility.trace('Nearest WC Pay period for the given date_earned is NOT found');
  CLOSE CSR_GET_NEAREST_PERIOD;
  CLOSE csr_get_period_dates;
  return (l_last_period_for_wc);
 END IF;
 /*IF current pay period is the nearest one to the WC effective date then
    deduct WC in the current payroll <=>l_last_period_for_wc := 'Y' */
 --if ( l_nearest_end_date = l_pay_period_end_date ) then
 if ( l_nearest_check_date = nvl(l_regular_payment_date,l_pay_period_end_date) ) then
   l_last_period_for_wc := 'Y';
 else
   l_last_period_for_wc := 'N';
 end if;

 hr_utility.trace('Should deduct WC in this pay period? ' || l_last_period_for_wc);
 CLOSE CSR_GET_NEAREST_PERIOD;
 /*7520832: Changes ends*/
 CLOSE csr_get_period_dates;


-- Check the assignment's validity as of last date of the pay period.
OPEN CSR_GET_VALID_EMPLOYMENT;
FETCH CSR_GET_VALID_EMPLOYMENT into l_valid;

 IF CSR_GET_VALID_EMPLOYMENT%NOTFOUND THEN
  CLOSE CSR_GET_VALID_EMPLOYMENT;
  hr_utility.trace('Assignment is not valid for WC deduction');
  return ('N');
 END IF;
 CLOSE CSR_GET_VALID_EMPLOYMENT;
    return(l_last_period_for_wc);
EXCEPTION
WHEN OTHERS THEN
     return ('N');

END get_wc_flag;

--
-- FUNCTION get_it_work_jurisdictions
--
/* This Function used to manage pl/table for work/tagged/home jurisdictions
   associated with an assignment

   Parameter        Purpose
   ---------        -------
   p_INITIALIZE     This parmaeter determines to process the pl/table
                    jurisdiction_codes_tbl. This parameter expects one of 3
                    values. (Y, N, F)
                    Y denotes  Initialize and populate the pl table
                    N denotes  Fetch jurisction that is stored next to the
                               jurisdiction assigned to p_jurisdiction_code
                    F denotes  Fecth the First jurisdiction stored in the pl
                               table

   This function is being called from US_TAX_VERTEX2 formula with P_INITIALIZE
   value as 'Y'. PL table is always initialized for each assignment.

   This function is called from US_TAX_VERTEX_HOME2 formula with P_INITIALIZE
   value as 'F'.

   This function is repeatedly called from US_TAX_VERTEX_WORK2 depending on the
   number of work jurisdiction stored in the pl table.For this call P_INITIALIZE
   value is set as 'N'.
*/
FUNCTION get_it_work_jurisdictions(p_assignment_action_id IN NUMBER
                                  ,p_initialize           IN VARCHAR2
                                  ,p_jurisdiction_code    IN OUT NOCOPY VARCHAR2
                                  ,p_percentage           OUT NOCOPY NUMBER
                                  ,p_assignment_id        IN  NUMBER
                                  ,p_date_paid            IN  DATE
                                  ,p_date_earned          IN  DATE
                                  ,p_time_period_id       IN  NUMBER
                                  ,p_payroll_id           IN  NUMBER
                                  ,p_business_group_id    IN  NUMBER
				  ,p_tax_unit_id          IN  NUMBER
                                  )
RETURN VARCHAR2
IS

     TOO_MANY_JURISDICTIONS   EXCEPTION;
     l_max_jurisdictions      NUMBER;
     l_assignment_id          NUMBER;
     l_date_paid              DATE;
     l_date_earned            DATE;

     l_ee_id                  NUMBER;
     l_jurisdiction_code      VARCHAR2(11);
     l_res_jurisdiction_code  VARCHAR2(11);
     l_work_jurisdiction_code VARCHAR2(11);
     l_wk_jurisdiction_code   VARCHAR2(11);
     l_jd_type                VARCHAR2(2);

     l_percentage             NUMBER;
     p_array_count            NUMBER;
     l_index_value            NUMBER;

     l_jd_found               VARCHAR2(1);
     l_return_value           VARCHAR2(28);

     l_state                  VARCHAR2(2);
     l_county                 VARCHAR2(120);
     l_city                   VARCHAR2(30);
     l_zip_code               VARCHAR2(10);

     l_res_state              VARCHAR2(2);
     l_res_county             VARCHAR2(120);
     l_res_city               VARCHAR2(100);
     l_res_zip                VARCHAR2(10);
     l_wah                    VARCHAR2(1);

     cnt                      NUMBER;

     -- Get Further Payroll Information , Use Informational Hours From flag.
     -- Current_pay_period (C)  or Previous_pay_period(P)
     CURSOR  csr_period_flag (p_assignment_action_id IN NUMBER) IS
     SELECT  NVL(prl_information12 ,'P') --Defaulted to Previous
            ,NVL(prl_information13 ,'YTD') --defaulted to Tax Year
       FROM  pay_payrolls_f           payroll,
             pay_assignment_actions   paa,
	     pay_payroll_actions      ppa
      WHERE  ppa.payroll_id           = payroll.payroll_id
        AND  paa.payroll_action_id    = ppa.payroll_action_id
        AND  paa.assignment_action_id = p_assignment_action_id
        AND  NVL(ppa.date_earned,ppa.effective_date)
                        	     BETWEEN payroll.effective_start_date
                                     AND     payroll.effective_end_date;

     l_pay_period_flag   pay_payrolls_f.prl_information11%TYPE;
     l_threshold_basis   pay_payrolls_f.prl_information13%TYPE;

     -- Cursor to get all the informational time element entries
     -- Jurisdiction Code and Hours screen entry values are retrieved
	-- All element entries are considered based on the start date and end date.
	-- Hours are summed for each jurisdiction.
	--
	CURSOR  csr_it_element_entries(p_start_date     IN DATE,
	                               p_end_date       IN DATE,
                                       p_assignment_id  IN NUMBER,
                                       p_date_earned    IN DATE) IS
        SELECT  pev1.screen_entry_value      Jurisdiction,
                SUM(pev2.screen_entry_value) Hours
         FROM   pay_element_entry_values_f   pev1,
                pay_element_entry_values_f   pev2,
                pay_element_entries_f        pee,
                pay_element_links_f          pel,
                pay_element_types_f          pet,
                pay_input_values_f           piv1,
                pay_input_values_f           piv2,
                pay_element_type_extra_info  extra
        WHERE   extra.information_type     = 'PAY_US_INFORMATION_TIME'
          AND   extra.eei_information1     = 'Y'
          AND   extra.element_type_id      = pet.element_type_id
          AND   pet.element_type_id        = pel.element_type_id
          AND   p_end_date              BETWEEN pet.effective_start_date
                                               AND pet.effective_end_date
          AND   pel.element_link_id        = pee.element_link_id
          AND   p_end_date              BETWEEN pel.effective_start_date
                                               AND pel.effective_end_date
          AND   pee.assignment_id          =  p_assignment_id
          AND   ( (pee.effective_start_date   BETWEEN p_start_date
	                                       AND p_end_date)
                   OR
		   (pee.effective_end_date   BETWEEN p_start_date
	                                       AND p_end_date)
                )
          AND   pee.element_entry_id       = pev1.element_entry_id
          AND   p_end_date              BETWEEN pee.effective_start_date
                                               AND pee.effective_end_date
          AND   pev1.input_value_id        = piv1.input_value_id
          AND   p_end_date             BETWEEN pev1.effective_start_date
                                               AND pev1.effective_end_date
          AND   piv1.name                  = 'Jurisdiction'
          AND   p_end_date              BETWEEN piv1.effective_start_date
                                               AND piv1.effective_end_date
          AND   pee.element_entry_id       = pev2.element_entry_id
          AND   p_end_date              BETWEEN pee.effective_start_date
                                               AND pee.effective_end_date
          AND   pev2.input_value_id        = piv2.input_value_id
          AND   piv2.name                  = 'Hours'
          AND   p_end_date              BETWEEN piv2.effective_start_date
                                               AND piv2.effective_end_date
          AND   pev1.screen_entry_value    IS NOT NULL
          AND   pev2.screen_entry_value    IS NOT NULL
          GROUP BY pev1.screen_entry_value;

      l_sum_hours                     NUMBER;
      l_scheduled_work_hours          NUMBER;
      l_total_hours                   NUMBER;
      l_work_hours                    NUMBER;
      l_remaining_hours               NUMBER;
      l_jd_hours                      NUMBER;
      l_end_date                      DATE;
      l_start_date                    DATE;
      l_time_period_id                pay_payroll_actions.time_period_id%TYPE;
      l_counter                       INTEGER;
      l_tg_jurisdiction_code          VARCHAR2(20);
      l_tg_sum_hours                  NUMBER;
      l_tg_total_hours                NUMBER;
      l_tg_hours_fetched              NUMBER;
      l_tg_jd_code_fetched            VARCHAR2(20);
      l_it_hours_fetched              NUMBER;
      l_hours_fetched                 NUMBER;
      l_tg_hours                      NUMBER;
      l_ws_name                       VARCHAR2(200);
      l_total_percent                 NUMBER;
      l_primary_work_jd_flag          VARCHAR2(1);
      l_primary_work_jd_index_value   NUMBER;
      l_extra_percent                 NUMBER;
      l_last_jd_index_value           NUMBER;
      l_denominator                   NUMBER;

      -- Get start_date, end_date for the given time_period_id and payroll_id
      --
      CURSOR csr_time_period(p_time_period_id IN NUMBER,
	                     p_payroll_id     IN NUMBER) IS
      SELECT end_date,
             start_date
	FROM per_time_periods
       WHERE time_period_id = p_time_period_id
         AND payroll_id     = p_payroll_id;


      -- Get start_date, end_date for the given time_period_id and payroll_id
      --
      CURSOR csr_time_period_prev(p_prev_end_date  IN DATE,
	                          p_payroll_id     IN NUMBER) IS
      SELECT end_date,
             start_date
	FROM per_time_periods
       WHERE end_date       = p_prev_end_date
         AND payroll_id     = p_payroll_id;

      -- Get Work Jurisdiction  for the assignment
      --
      CURSOR csr_work_jd (p_date_earned IN DATE, p_assignment_id IN NUMBER) IS
         SELECT NVL(hrloc.loc_information18,hrloc.town_or_city),
                NVL(hrloc.loc_information19,hrloc.region_1),
                NVL(hrloc.loc_information17,hrloc.region_2),
                SUBSTR(NVL(hrloc.loc_information20,hrloc.postal_code),1,5)
           FROM hr_locations             hrloc
               ,hr_soft_coding_keyflex   hrsckf
               ,per_all_assignments_f    assign
          WHERE p_date_earned            BETWEEN assign.effective_start_date
                                             AND assign.effective_end_date
            AND assign.assignment_id           = p_assignment_id
            AND assign.soft_coding_keyflex_id  = hrsckf.soft_coding_keyflex_id
            AND NVL(hrsckf.segment18,
			        assign.location_id)        = hrloc.location_id;
/*
      --Get the Positive Pay entries(same as Tagged Entries)
      --
      CURSOR  csr_tagged_entries(p_start_date IN DATE,
	                         p_end_date   IN DATE,
		                 p_assignment_id  IN NUMBER,
                                 p_date_earned IN DATE) IS
         SELECT pev1.screen_entry_value         Jurisdiction,
                SUM(pev2.screen_entry_value)    Hours
           FROM pay_element_entry_values_f  pev1,
                pay_element_entry_values_f  pev2,
                pay_element_entries_f       pee,
                pay_element_links_f         pel,
                pay_element_types_f         pet,
                pay_input_values_f          piv1,
                pay_input_values_f          piv2,
                pay_element_classifications pec
        WHERE   pec.classification_name IN ( 'Earnings', 'Supplemental Earnings','Imputed Earnings' )
          AND   pec.legislation_code       = 'US'
          AND   pec.classification_id      = pet.classification_id
          AND   pet.element_type_id        = pel.element_type_id
          AND   p_date_earned              BETWEEN pet.effective_start_date
                                               AND pet.effective_end_date
          AND   pel.element_link_id        = pee.element_link_id
          AND   p_date_earned              BETWEEN pel.effective_start_date
                                               AND pel.effective_end_date
          AND   pee.assignment_id          =  p_assignment_id
          AND   pee.effective_start_date   BETWEEN p_start_date
	                                       AND p_end_date
          AND   pee.element_entry_id       = pev1.element_entry_id
          AND   p_date_earned              BETWEEN pee.effective_start_date
                                               AND pee.effective_end_date
          AND   pev1.input_value_id        = piv1.input_value_id
          AND   p_date_earned             BETWEEN pev1.effective_start_date
                                               AND pev1.effective_end_date
          AND   piv1.name                  = 'Jurisdiction'
          AND   p_date_earned              BETWEEN piv1.effective_start_date
                                               AND piv1.effective_end_date
          AND   pee.element_entry_id       = pev2.element_entry_id
          AND   p_date_earned              BETWEEN pee.effective_start_date
                                               AND pee.effective_end_date
          AND   pev2.input_value_id        = piv2.input_value_id
          AND   piv2.name                  = 'Hours'
          AND   p_date_earned              BETWEEN piv2.effective_start_date
                                               AND piv2.effective_end_date
          AND   pev1.screen_entry_value    IS NOT NULL
          AND   pev2.screen_entry_value    IS NOT NULL
          GROUP BY pev1.screen_entry_value;
  */

    CURSOR  csr_tagged_entries(p_start_date    IN DATE,
	                       p_end_date      IN DATE,
		               p_assignment_id IN NUMBER,
                               p_date_earned   IN DATE)
    IS
        SELECT /*+ INDEX (paa pay_assignment_actions_n51) */ DISTINCT
              peev.screen_entry_value Jurisdiction,
	      0                       Hours
         FROM pay_element_classifications pec
             ,pay_element_types_f         pet
             ,pay_element_entries_f       pee
             ,pay_element_links_f         pel
             ,pay_input_values_f          piv
             ,pay_element_entry_values_f  peev
        WHERE pec.classification_name in
                   ( 'Earnings', 'Supplemental Earnings','Imputed Earnings' )
          AND pec.legislation_code       = 'US'
          AND pet.classification_id      = pec.classification_id
          AND (( pee.effective_start_date   BETWEEN p_start_date
	                                    AND     p_end_date)
                OR
		( pee.effective_end_date   BETWEEN p_start_date
	                                   AND     p_end_date)
               )
          AND p_end_date                 BETWEEN pet.effective_start_date
                                         AND     pet.effective_end_date
          AND pee.assignment_id          = p_assignment_id
          AND pet.element_type_id        = pel.element_type_id
          AND pel.element_link_id        = pee.element_link_id
          AND p_end_date                 BETWEEN pel.effective_start_date
                                         AND     pel.effective_end_date
          AND pet.element_type_id        = piv.element_type_id
          AND piv.name                   = 'Jurisdiction'
          AND pee.effective_start_date   BETWEEN piv.effective_start_date
                                         AND     piv.effective_end_date
          AND pee.element_entry_id       = peev.element_entry_id
          AND peev.input_value_id        = piv.input_value_id
          AND pee.effective_start_date   BETWEEN peev.effective_start_date
                                         AND     peev.effective_end_date
          AND peev.screen_entry_value    IS NOT NULL;


      -- Get work schedule details
      --
      CURSOR csr_ws(p_assignment_id IN NUMBER,p_date_earned IN DATE) IS
         SELECT segment4
           FROM hr_soft_coding_keyflex   target,
                per_all_assignments_f    assign
          WHERE ASSIGN.assignment_id             = p_assignment_id
            AND target.soft_coding_keyflex_id    = ASSIGN.soft_coding_keyflex_id
            AND target.enabled_flag              = 'Y'
            AND p_date_earned              BETWEEN assign.effective_start_date
                                               AND assign.effective_end_date;

      CURSOR csr_resident_jd(p_assignment_id IN NUMBER,p_date_earned IN DATE) IS
      SELECT NVL(addr.add_information17,addr.region_2)  state,
             NVL(addr.add_information19,addr.region_1)  county,
             NVL(addr.add_information18,addr.town_or_city) city,
             NVL(addr.add_information20,addr.postal_code)  zip,
             NVL(assign.work_at_home,'N')
       FROM  per_addresses          addr
            ,per_all_assignments_f  assign
      WHERE  p_date_earned   BETWEEN assign.effective_start_date
                                 AND assign.effective_end_date
        AND  assign.assignment_id   = p_assignment_id
        AND  addr.person_id	    = assign.person_id
        AND  addr.primary_flag      = 'Y'
        AND  p_date_earned BETWEEN NVL(addr.date_from, p_date_earned)
                               AND NVL(addr.date_to, p_date_earned);

      -- Get Full Name, Assignment Number
      CURSOR csr_person_details(p_assignment_id IN NUMBER,p_date_paid IN DATE) IS
        SELECT ppf.full_name, paf.assignment_number
          FROM per_all_people_f ppf,
	       per_all_assignments_f paf
         WHERE ppf.person_id = paf.person_id
           AND paf.assignment_id = p_assignment_id
	   AND p_date_paid  BETWEEN paf.effective_start_date
	                        AND paf.effective_end_date
           AND p_date_paid  BETWEEN ppf.effective_start_date
                                AND ppf.effective_end_date;

    l_full_name               per_all_people_f.full_name%TYPE;
    l_assignment_number       per_all_assignments_f.assignment_number%TYPE;

    -- Get actual_termination_date for the person
    CURSOR csr_eff_dates(p_assignment_id IN NUMBER, p_date_paid IN DATE ) IS
      SELECT paa.effective_start_date,
             paa.effective_end_date
        FROM per_all_assignments_f  paa
       WHERE paa.assignment_id   = p_assignment_id
	 AND p_date_paid    BETWEEN paa.effective_start_date
	                        AND paa.effective_end_date;

    l_effective_start_date    DATE;
    l_max_start_date          DATE;
    l_effective_end_date      DATE;
    l_max_end_date          DATE;
    l_actual_termination_date per_periods_of_service.actual_termination_date%TYPE;

    -- Get actual_termination_date for the person
CURSOR csr_term_dates(p_assignment_id IN NUMBER, p_date_earned IN DATE,p_date_start IN DATE,p_date_end IN DATE ) IS
      SELECT pps.actual_termination_date,pps.date_start
        FROM per_periods_of_service  pps,
             per_all_assignments_f paa
       WHERE paa.assignment_id   = p_assignment_id
         AND paa.person_id       = pps.person_id
    	 AND p_date_earned BETWEEN paa.effective_start_date
	                       AND paa.effective_end_date
         AND p_date_end >= pps.date_start
	 AND p_date_start <= NVL(pps.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY'));


    -- Get
    CURSOR csr_person_id (p_assignment_id IN NUMBER) IS
      SELECT person_id
        FROM per_all_assignments_f
       WHERE assignment_id = p_assignment_id;

    l_person_id               per_all_assignments_f.person_id%TYPE;

    l_jurisdiction            VARCHAR2(20);
    l_calc_percent            VARCHAR2(10);
    l_threshold_hours_state   NUMBER;
    l_threshold_hours_county  NUMBER;
    l_threshold_hours_city    NUMBER;
    l_sit_withheld            NUMBER;
    l_county_withheld         NUMBER;
    l_city_withheld           NUMBER;
    l_ih_excluding_pay_period NUMBER;
    l_ih_above_threshold      NUMBER;
    l_ih_for_primary_wk       NUMBER;
    l_state_ih_logged         NUMBER;
    l_county_ih_logged        NUMBER;
    l_city_ih_logged          NUMBER;
    l_total_state_hours       NUMBER;
    l_total_county_hours      NUMBER;
    l_total_state_percent     NUMBER;
    l_total_county_percent    NUMBER;
    l_in_counter              INTEGER;
    l_prev_end_date           DATE;
    /*Bug#5981447: Variables to hold start and end dates
                   to calculate work schduled hours */
    l_ws_start_date           DATE;
    l_ws_end_date             DATE;
    /*Bug#5981447: Ends here */
    l_sit_city_withheld       NUMBER;
    l_county_city_withheld    NUMBER;
    l_sit_county_withheld     NUMBER;

    l_spelled_jd_code         VARCHAR2(200);

BEGIN
      --{
      l_max_jurisdictions    := 200;
      l_total_hours          := 0;
      l_work_hours           := 0;
      l_remaining_hours      := 0;
      l_jd_hours             := 0;
      l_counter              := NULL;
      l_tg_total_hours       := 0;
      l_total_percent        := 0;
      l_primary_work_jd_flag := 'N';
      l_extra_percent        := 0;
      l_denominator          := 0;

      l_total_state_hours    := 0;
      l_total_county_hours   := 0;
      l_total_state_percent  := 0;
      l_total_county_percent := 0;

      l_sit_city_withheld    := 0;
      l_county_city_withheld := 0;
      l_sit_county_withheld  := 0;

      hr_utility.trace('EMJT : Begin get_it_work_jurisdictions');
      hr_utility.trace('EMJT : p_assignment_action_id    -> '
	                                         ||to_char(p_assignment_action_id));
      hr_utility.trace('EMJT : p_assignment_id           -> '||
	                                                  to_char(p_assignment_id));
      hr_utility.trace('EMJT : p_date_earned             -> '||to_char(p_date_earned));
      hr_utility.trace('EMJT : p_date_paid               -> '||to_char(p_date_paid));
      hr_utility.trace('EMJT : p_time_period_id          -> '||
	                                                 to_char(p_time_period_id));
      hr_utility.trace('EMJT : p_payroll_id              -> '||to_char(p_payroll_id));
      hr_utility.trace('EMJT : =====================================================');


      OPEN csr_person_id (p_assignment_id);
      FETCH csr_person_id INTO l_person_id;
      IF  csr_person_id%NOTFOUND THEN
          hr_utility.trace('EMJT: Person Id not found');
      END IF;

      CLOSE csr_person_id;

      --
      -- Determine the pay period, whether it is current or previous
      -- This is used to fetch element entries for the user configured period
      --
      OPEN csr_period_flag(p_assignment_action_id);
      FETCH csr_period_flag INTO l_pay_period_flag,
                                 l_threshold_basis;
      CLOSE csr_period_flag;
      hr_utility.trace('EMJT : l_pay_period_flag -> '|| l_pay_period_flag );
      hr_utility.trace('EMJT : l_threshold_basis -> '|| l_threshold_basis );
   /*   IF l_pay_period_flag = 'C' THEN  --Current Pay Period
         OPEN csr_time_period(p_time_period_id, p_payroll_id);
      ELSIF l_pay_period_flag = 'P' THEN --Previous Pay Period
      --   l_time_period_id  := p_time_period_id - 1;
      --   IF l_time_period_id <= 0 THEN
      --      l_time_period_id := p_time_period_id;
      --   END IF;
         OPEN csr_time_period(l_time_period_id,p_payroll_id);
      END IF; --l_pay_period_flag = 'C'
     */
      OPEN csr_time_period(p_time_period_id, p_payroll_id);
      FETCH csr_time_period INTO l_end_date,
                                 l_start_date;
      CLOSE csr_time_period;
      /* Assign current pay period's start and end dates */
      l_ws_start_date := l_start_date;
      l_ws_end_date   := l_end_date;

      OPEN csr_term_dates (p_assignment_id, p_date_earned,l_start_date,l_end_date);
      FETCH csr_term_dates INTO l_effective_end_date,l_effective_start_date;
      CLOSE csr_term_dates;

      l_effective_end_date := NVL( l_effective_end_date,to_date('12/31/4712','mm/dd/yyyy'));

      hr_utility.trace('EMJT : l_effective_start_date -> '|| l_effective_start_date);
      hr_utility.trace('EMJT : l_effective_end_date   -> '|| l_effective_end_date);

      IF l_pay_period_flag = 'P' THEN

         l_prev_end_date := l_start_date - 1;

	 OPEN csr_time_period_prev(l_prev_end_date, p_payroll_id);
	 FETCH csr_time_period_prev INTO l_end_date, l_start_date;

	 /*There is no previous pay period available.
	   Assign null to l_start_Date and l_end_date */

	 IF csr_time_period_prev%NOTFOUND THEN
	   l_start_date :=null;
           l_end_date   :=null;
         ELSIF l_effective_start_date >=l_end_date or l_effective_end_date <= l_start_date THEN
	 /* no previous pay period exists for the assignment */
	   l_start_date :=null;
           l_end_date   :=null;
         ELSE
           l_ws_start_date := l_start_date;
           l_ws_end_date   := l_end_date;
	 END IF;

	 CLOSE csr_time_period_prev;

      END IF;

      hr_utility.trace('EMJT : After csr_time_period -> ');
      hr_utility.trace('EMJT : l_end_date              -> '||to_char(l_end_date));
      hr_utility.trace('EMJT : l_start_date            -> '||to_char(l_start_date));
      hr_utility.trace('EMJT : l_ws_end_date           -> '||to_char(l_ws_end_date));
      hr_utility.trace('EMJT : l_ws_start_date         -> '||to_char(l_ws_start_date));

      -- Need to fetch scheduled hours configured for the assignment for the
      -- current pay period.
      OPEN csr_ws(p_assignment_id,
	          p_date_earned);
      FETCH csr_ws INTO l_ws_name;
      IF csr_ws%NOTFOUND THEN
         hr_utility.trace('EMJT : get_id_work_jurisdiction Work Scheduled Not Found ');
      END IF;
      CLOSE csr_ws;

      /* Start and end dates for the work scheduled hours calculation */
      /*Bug#7114362: l_ws_start_date should not be NULL even when l_effective_start_date is
       NULL*/
      l_ws_start_date := greatest ( NVL(l_effective_start_date,to_date('01-01-0001','DD-MM-YYYY')), l_ws_start_date);
      l_ws_end_date   := least ( l_effective_end_date, l_ws_end_date);

      /* Start and end dates for fetching information and tagged hours */
      IF l_start_date is null and l_end_date is null THEN
      /* There is no Previous pay period available.
         No need to process information and tagged hours */
        l_max_start_date := null;
        l_max_end_Date   := null;
      ELSE
        l_max_start_date := l_ws_start_date;
        l_max_end_Date   := l_ws_end_date;
      END IF;

      hr_utility.trace('EMJT : l_max_start_date        -> '|| l_max_start_date);
      hr_utility.trace('EMJT : l_max_end_date          -> '|| l_max_end_date);
      hr_utility.trace('EMJT : l_ws_end_date           -> '||to_char(l_ws_end_date));
      hr_utility.trace('EMJT : l_ws_start_date         -> '||to_char(l_ws_start_date));

      /* need to use l_ws_start_date and l_ws_end_date for work scheduled hours calculation */

      l_scheduled_work_hours :=
            hr_us_ff_udfs.work_schedule_total_hours(p_business_group_id,
                                                    l_ws_name,
                                                    l_ws_start_date,
                                                    l_ws_end_date);

      IF l_ws_start_date = l_ws_end_date AND
         NVL(l_scheduled_work_hours,0) <= 0 THEN

	 l_scheduled_work_hours :=
            hr_us_ff_udfs.work_schedule_total_hours(p_business_group_id,
                                                    l_ws_name,
                                                    l_ws_start_date,
                                                    l_ws_end_date);
         IF l_scheduled_work_hours = 0  THEN
             hr_utility.trace('EMJT : Scheduled hours set to 8');
            l_scheduled_work_hours := 8; -- Defaulted to 8 hours
      END IF;
      END IF;


      hr_utility.trace('EMJT : Scheduled Hours for the assignment -> '||
	                                           to_char(l_scheduled_work_hours));
      IF p_initialize = 'Y' THEN
      --{
      -- pl/sql table initialized for all twork location where Information Time
      -- and Positive Pay hours are logged. This call initiated from the
      -- US_TAX_VERTEX2 fast formula

         hr_utility.trace('EMJT : get_it_work_jurisdictions || p_initialize = Y');
         jurisdiction_codes_tbl.delete;
         state_processed_tbl.delete;
         county_processed_tbl.delete;
         city_processed_tbl.delete;

	 jurisdiction_codes_tbl_stg.delete;

      --   GET the RESIDENT jurisdictions and load in to the *_processed_tables
      --
        hr_utility.trace('EMJT : get_work_jurisdictions Get Resident Address details');

	OPEN csr_resident_jd(p_assignment_id,p_date_earned);
	FETCH csr_resident_jd INTO l_res_state,
                                   l_res_county,
                                   l_res_city,
                                   l_res_zip,
                                   l_wah;

        CLOSE csr_resident_jd;

        hr_utility.trace('EMJT : get_it_work_jurisdictions Resident Address Fetched');
        l_res_jurisdiction_code := hr_us_ff_udfs.addr_val(l_res_state
                                                        , l_res_county
                                                        , l_res_city
                                                        , l_res_zip);

        -- IF this is a user defined city IE: city_code = 'U***' the change
        -- the city code to all 0 (zeros)

        IF SUBSTR(l_res_jurisdiction_code,8,1) = 'U' THEN
           l_res_jurisdiction_code := SUBSTR(l_res_jurisdiction_code,1,7) ||
                                                                       '0000' ;
        END IF;
        hr_utility.trace('EMJT : Resident Jurisdiction Code  -> ' ||
                                                       l_res_jurisdiction_code);
        hr_utility.trace('EMJT : Home Workers Flag           -> ' || l_wah);

         --
         -- Determine the address components of primary work jurisdiction.
         --
         hr_utility.trace('EMJT : get_it_work_jurisdictions Fetch Primary Work Location');
         OPEN csr_work_jd(p_date_earned,
		                  p_assignment_id);
	 FETCH csr_work_jd  INTO l_city,
                                 l_county,
                                 l_state,
                                 l_zip_code;

         IF csr_work_jd%NOTFOUND THEN
            hr_utility.trace('EMJT : Primary Work Location address componets NOT Found');
	 END IF;
	 CLOSE csr_work_jd;
	 hr_utility.trace('EMJT : Determine Jurisdiction Code for Primary Work Location');
         l_work_jurisdiction_code := hr_us_ff_udfs.addr_val(l_state,
                                                            l_county,
                                                            l_city,
                                                            l_zip_code);

         hr_utility.trace('EMJT : Primary work Jursdiction CODE  -> '
		                                           || l_work_jurisdiction_code);

         -- Check to see whether employee is configured as "Home Worker"
         -- If employee is a Home worker use resident jurisdiction as primary
         -- work jurisdiction code instead of actual primary work jurisdiction
         -- available for the assignment

         IF l_wah = 'Y' THEN
            l_work_jurisdiction_code := l_res_jurisdiction_code;
            hr_utility.trace('EMJT : As assignment is configured as Home Worker ');
	    hr_utility.trace('EMJT : Residence Jurisdiction overrides the Primary Work Jurisdiction');
            hr_utility.trace('EMJT : Primary work Jursdiction CODE  -> '
		                                           || l_work_jurisdiction_code);
         END IF;

         -- Fetch all the informational time element entries logged for the
         -- Pay period being processed
         hr_utility.trace('EMJT :  Fetching all Information Hours Element Entris for Assignment');
         hr_utility.trace('EMJT :  For Assignment '||to_char(p_assignment_id));
         hr_utility.trace('EMJT :      Start Date '||to_char(l_start_date,'dd-mon-yyyy'));
         hr_utility.trace('EMJT :      End Date   '||to_char(l_end_date,'dd-mon-yyyy'));
	 BEGIN
/*         OPEN csr_it_element_entries(l_start_date,
		                     l_end_date,
                                     p_assignment_id,
                                     p_date_earned);
*/

         OPEN csr_it_element_entries(l_max_start_date, --l_start_date,
		                     l_max_end_date,   --l_end_date,
                                     p_assignment_id,
                                     p_date_earned);

         FETCH csr_it_element_entries INTO l_jurisdiction_code,
		                           l_sum_hours;
         hr_utility.trace('EMJT :  1st Information Time JD Code fetched-> '||l_jurisdiction_code);
         hr_utility.trace('EMJT :  1st Information Time Hours          -> '||to_char(l_sum_hours));
	 LOOP
         --{
            EXIT WHEN csr_it_element_entries%NOTFOUND;

            jurisdiction_codes_tbl_stg( TO_NUMBER(SUBSTR(l_jurisdiction_code,1,2) ||
                                              SUBSTR(l_jurisdiction_code,4,3) ||
                                              SUBSTR(l_jurisdiction_code,8,4) )
                                  ).jurisdiction_code := l_jurisdiction_code;

            jurisdiction_codes_tbl_stg( TO_NUMBER(SUBSTR(l_jurisdiction_code,1,2) ||
                                              SUBSTR(l_jurisdiction_code,4,3) ||
                                              SUBSTR(l_jurisdiction_code,8,4) )
                                  ).hours := l_sum_hours;

            jurisdiction_codes_tbl_stg( TO_NUMBER(SUBSTR(l_jurisdiction_code,1,2) ||
                                              SUBSTR(l_jurisdiction_code,4,3) ||
                                              SUBSTR(l_jurisdiction_code,8,4) )
                                  ).jd_type := 'IT'; --Informational Time

            jurisdiction_codes_tbl_stg( TO_NUMBER(SUBSTR(l_jurisdiction_code,1,2) ||
                                              SUBSTR(l_jurisdiction_code,4,3) ||
                                              SUBSTR(l_jurisdiction_code,8,4) )
                                  ).tg_hours := 0; --Initialize Tagged Hours

            hr_utility.trace('EMJT : ===============================================');
            hr_utility.trace('EMJT : Information Hours entry tagged to JD Code  -> ' ||l_jurisdiction_code);
            hr_utility.trace('EMJT : Information Hours logged                   -> ' ||to_char(l_sum_hours));
            hr_utility.trace('EMJT : ===============================================');
            -- Add information time logged to local variable to compute the
            -- the total information time hours logged for the assignment
            l_total_hours := l_total_hours + l_sum_hours;
            --
	    -- If hours entered for jurisdiction is primary work jurisdiction
	    -- set the flag to Yes
	    IF l_work_jurisdiction_code = l_jurisdiction_code THEN
   	       l_primary_work_jd_flag := 'Y';
	       l_primary_work_jd_index_value :=
	                               TO_NUMBER(SUBSTR(l_jurisdiction_code,1,2) ||
                                                 SUBSTR(l_jurisdiction_code,4,3) ||
                                                 SUBSTR(l_jurisdiction_code,8,4));
	    END IF;
            -- Fetch the next jurisdiction and hours from cursor csr_it_element_entries
	    --
            FETCH csr_it_element_entries INTO l_jurisdiction_code,
                                              l_sum_hours;
         --}
    	 END LOOP;
         CLOSE csr_it_element_entries;
         EXCEPTION
	     WHEN OTHERS THEN
                  hr_utility.trace('EMJT : ERROR Encountered while processing Information Hours EE');
                  hr_utility.trace(substr(sqlerrm,1,45));
                  hr_utility.trace(substr(sqlerrm,46,45));
	 END;
         hr_utility.trace('EMJT : Information Hours Element Entries fetched and loaded ');
	 hr_utility.trace('EMJT : Total no. of Jurisdiction loaded in to pl/sql table ->'||
		                            to_char(jurisdiction_codes_tbl_stg.COUNT));
         hr_utility.trace('EMJT : Total Information Hours logged     -> ' ||to_char(l_total_hours));

         -- Determine whether total hours match against scheduled hours.
         -- In case total hours fall less than scheduled hours, add the
         -- remaining hours to primary work jurisdiction.
         --
         IF l_total_hours < l_scheduled_work_hours THEN
	 --{
               l_remaining_hours := l_scheduled_work_hours - l_total_hours;
 	       hr_utility.trace('EMJT : Total Hours entered '||to_char(l_total_hours)||
			                         ' less than Scheduled Hours '||
                                               to_char(l_scheduled_work_hours));
               hr_utility.trace('EMJT : Entered Hours short of Sheduled Hours ' ||
			                      to_char(l_remaining_hours));
               -- Check whether work jurisdiction is available in pl table.
  	       -- If yes, add l_remaining_hours to the hours logged against work
	       -- jurisdiction Else assign l_remaining_hours to the work jurisdiction.
  	       IF jurisdiction_codes_tbl_stg.EXISTS(
			                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                     SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                     SUBSTR(l_work_jurisdiction_code,8,4) )
                                           ) THEN
               --{
	          l_work_hours := jurisdiction_codes_tbl_stg(
			                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                     SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                     SUBSTR(l_work_jurisdiction_code,8,4) )
                                                    ).hours;
                  jurisdiction_codes_tbl_stg(
			                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                     SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                     SUBSTR(l_work_jurisdiction_code,8,4) )
                                    ).hours := l_work_hours + l_remaining_hours;
                  l_primary_work_jd_flag := 'Y';
		  --
  	          l_primary_work_jd_index_value :=
	                               TO_NUMBER(SUBSTR(l_jurisdiction_code,1,2) ||
                                                 SUBSTR(l_jurisdiction_code,4,3) ||
                                                 SUBSTR(l_jurisdiction_code,8,4));

                  hr_utility.trace('EMJT : l_work_hours ' || to_char(l_work_hours));
               --}
               ELSE
	       --{
                 -- No Informational Time logged against work location.
	         -- Insert work jurisdiction into pl table with jd_type as WK
 	         jurisdiction_codes_tbl_stg(
		                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                             SUBSTR(l_work_jurisdiction_code,4,3) ||
                                             SUBSTR(l_work_jurisdiction_code,8,4) )
                                   ).jurisdiction_code := l_work_jurisdiction_code;
        /*Bug#6957929: Jurisdiction type must be 'RW' when work and resident
          jurisdictions are same.*/
           if l_res_jurisdiction_code = l_work_jurisdiction_code then
                 jurisdiction_codes_tbl_stg(
			           TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                             SUBSTR(l_work_jurisdiction_code,4,3) ||
                                             SUBSTR(l_work_jurisdiction_code,8,4) )
                                   ).jd_type   := 'RW'; --Work Location
           else
                                jurisdiction_codes_tbl_stg(
			           TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                             SUBSTR(l_work_jurisdiction_code,4,3) ||
                                             SUBSTR(l_work_jurisdiction_code,8,4) )
                                   ).jd_type   := 'WK'; --Work Location
           end if;
           /*
                 jurisdiction_codes_tbl_stg(
			           TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                             SUBSTR(l_work_jurisdiction_code,4,3) ||
                                             SUBSTR(l_work_jurisdiction_code,8,4) )
                                   ).jd_type   := 'WK'; --Work Location
           */
           /*Bug#6957929: Changes end here*/

                 jurisdiction_codes_tbl_stg(
			           TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                             SUBSTR(l_work_jurisdiction_code,4,3) ||
                                             SUBSTR(l_work_jurisdiction_code,8,4) )
                                   ).hours     := l_remaining_hours;

                 jurisdiction_codes_tbl_stg(
                                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                             SUBSTR(l_work_jurisdiction_code,4,3) ||
                                             SUBSTR(l_work_jurisdiction_code,8,4) )
                                    ).tg_hours := 0; --Initialize Tagged Hours
                 l_primary_work_jd_flag        := 'Y';
                 l_primary_work_jd_index_value :=
                                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                             SUBSTR(l_work_jurisdiction_code,4,3) ||
                                             SUBSTR(l_work_jurisdiction_code,8,4));
               --}
               END IF; -- jurisdiction_codes_tbl_stg.EXISTS

               hr_utility.trace('EMJT : Hours logged to primary Work Jurisdiction           ->'||
	                                                           to_char(l_work_hours));
               hr_utility.trace('EMJT : Total no. of Jurisdiction loaded in to pl/sql table ->'||
		                            to_char(jurisdiction_codes_tbl_stg.COUNT));
         --}
         ELSE  -- Check to see if there is an entry in the stg table for primary
               -- work jurisdiction if not add it.
 	          IF jurisdiction_codes_tbl_stg.EXISTS(
			                      TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
||
                                                        SUBSTR(l_work_jurisdiction_code,4,3)
||
                                                        SUBSTR(l_work_jurisdiction_code,8,4)
)
                                              ) THEN
                NULL;
            ELSE
 	         jurisdiction_codes_tbl_stg(
		                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
||
                                             SUBSTR(l_work_jurisdiction_code,4,3)
||
                                             SUBSTR(l_work_jurisdiction_code,8,4)
)
                                   ).jurisdiction_code :=
l_work_jurisdiction_code;
        /*Bug#6957929: Jurisdiction type must be 'RW' when work and resident
 *           jurisdictions are same.*/
           if l_res_jurisdiction_code = l_work_jurisdiction_code then
                 jurisdiction_codes_tbl_stg(
			           TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
||
                                             SUBSTR(l_work_jurisdiction_code,4,3)
||
                                             SUBSTR(l_work_jurisdiction_code,8,4)
)
                                   ).jd_type   := 'RW'; --Work Location
           else
                                jurisdiction_codes_tbl_stg(
			           TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
||
                                             SUBSTR(l_work_jurisdiction_code,4,3)
||
                                             SUBSTR(l_work_jurisdiction_code,8,4)
)
                                   ).jd_type   := 'WK'; --Work Location
           end if;
           /*
 *                  jurisdiction_codes_tbl_stg(
 *                  			           TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
 *                  			           ||
 *                  			                                                        SUBSTR(l_work_jurisdiction_code,4,3)
 *                  			                                                        ||
 *                  			                                                                                                     SUBSTR(l_work_jurisdiction_code,8,4)
 *                  			                                                                                                     )
 *                  			                                                                                                                                        ).jd_type
 *                  			                                                                                                                                        :=
 *                  			                                                                                                                                        'WK';
 *                  			                                                                                                                                        --Work
 *                  			                                                                                                                                        Location
 *                  			                                                                                                                                                   */
           /*Bug#6957929: Changes end here*/

                 jurisdiction_codes_tbl_stg(
			           TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
||
                                             SUBSTR(l_work_jurisdiction_code,4,3)
||
                                             SUBSTR(l_work_jurisdiction_code,8,4)
)
                                   ).hours     := 0;

                 jurisdiction_codes_tbl_stg(
                                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
||
                                             SUBSTR(l_work_jurisdiction_code,4,3)
||
                                             SUBSTR(l_work_jurisdiction_code,8,4)
)
                                    ).tg_hours := 0; --Initialize Tagged Hours
                 l_primary_work_jd_flag        := 'Y';
                 l_primary_work_jd_index_value :=
                                   TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
||
                                             SUBSTR(l_work_jurisdiction_code,4,3)
||
                                             SUBSTR(l_work_jurisdiction_code,8,4));
               --}
               END IF; -- jurisdiction_codes_tbl_stg.EXISTS


         END IF; --l_total_hours < l_scheduled_work_hours


         hr_utility.trace('EMJT : Fetching Tagged and/or Positive Pay Hours Element Entries ');
	 --
         -- Processing Tagged Entries for the assignment
         --
      BEGIN
         -- For tagged eearnings start and date date change fir fixing issue 4626170
	 --
/*         OPEN csr_tagged_entries(l_start_date,
                                 l_end_date,
                                 p_assignment_id,
                                 p_date_earned);
*/
         OPEN csr_tagged_entries(l_max_start_date,
                                 l_max_end_date,
                                 p_assignment_id,
                                 p_date_earned);
         --{
         FETCH csr_tagged_entries INTO l_tg_jurisdiction_code,
	                               l_tg_sum_hours;
         LOOP
         --{
            EXIT WHEN csr_tagged_entries%NOTFOUND;

            IF jurisdiction_codes_tbl_stg.EXISTS(
                                 TO_NUMBER(SUBSTR(l_tg_jurisdiction_code,1,2) ||
                                           SUBSTR(l_tg_jurisdiction_code,4,3) ||
                                           SUBSTR(l_tg_jurisdiction_code,8,4) )
                                            ) THEN
            --{
              l_hours_fetched := jurisdiction_codes_tbl_stg(
                                 TO_NUMBER(SUBSTR(l_tg_jurisdiction_code,1,2) ||
                                           SUBSTR(l_tg_jurisdiction_code,4,3) ||
                                           SUBSTR(l_tg_jurisdiction_code,8,4) )
                                                       ).hours;

              jurisdiction_codes_tbl_stg(
                                 TO_NUMBER(SUBSTR(l_tg_jurisdiction_code,1,2) ||
                                           SUBSTR(l_tg_jurisdiction_code,4,3) ||
                                           SUBSTR(l_tg_jurisdiction_code,8,4) )
                                    ).hours := l_hours_fetched + l_tg_sum_hours;

              jurisdiction_codes_tbl_stg(
                                 TO_NUMBER(SUBSTR(l_tg_jurisdiction_code,1,2) ||
                                           SUBSTR(l_tg_jurisdiction_code,4,3) ||
                                           SUBSTR(l_tg_jurisdiction_code,8,4) )
                                    ).tg_hours := l_tg_sum_hours;
            --}
            ELSE
	    --{
              jurisdiction_codes_tbl_stg(
                                 TO_NUMBER(SUBSTR(l_tg_jurisdiction_code,1,2) ||
                                           SUBSTR(l_tg_jurisdiction_code,4,3) ||
                                           SUBSTR(l_tg_jurisdiction_code,8,4) )
                                  ).jurisdiction_code := l_tg_jurisdiction_code;

              jurisdiction_codes_tbl_stg(
                                 TO_NUMBER(SUBSTR(l_tg_jurisdiction_code,1,2) ||
                                           SUBSTR(l_tg_jurisdiction_code,4,3) ||
                                           SUBSTR(l_tg_jurisdiction_code,8,4) )
                                    ).hours := l_tg_sum_hours;

              jurisdiction_codes_tbl_stg(
                                 TO_NUMBER(SUBSTR(l_tg_jurisdiction_code,1,2) ||
                                           SUBSTR(l_tg_jurisdiction_code,4,3) ||
                                           SUBSTR(l_tg_jurisdiction_code,8,4) )
                                    ).tg_hours := l_tg_sum_hours;

              jurisdiction_codes_tbl_stg(
                                 TO_NUMBER(SUBSTR(l_tg_jurisdiction_code,1,2) ||
                                           SUBSTR(l_tg_jurisdiction_code,4,3) ||
                                           SUBSTR(l_tg_jurisdiction_code,8,4) )
                                    ).jd_type := 'TG'; --Informational Time

            --}
            END IF;

            hr_utility.trace('EMJT : ===============================================');
            hr_utility.trace('EMJT : Tagged Jurisdiction Code  -> ' ||
			                                l_tg_jurisdiction_code);
            hr_utility.trace('EMJT : Tagged/Positive_Pay Hours -> ' ||
                                                       to_char(l_tg_sum_hours));
            hr_utility.trace('EMJT : ===============================================');

            FETCH csr_tagged_entries INTO l_tg_jurisdiction_code,
	                                  l_tg_sum_hours;
         --}
         END LOOP;
         CLOSE csr_tagged_entries;
      EXCEPTION
      WHEN OTHERS THEN
                  hr_utility.trace('EMJT : ERROR Encountered while processing Tagged EE');
                  hr_utility.trace(substr(sqlerrm,1,45));
                  hr_utility.trace(substr(sqlerrm,46,45));
      END;
      hr_utility.trace('EMJT : Tagged and/or Positive Pay Hours Element Entries Fetched and Loaded');

      --Just to print the contents of jurisdiction_codes_tbl_stg
      l_counter := jurisdiction_codes_tbl_stg.FIRST;
      l_last_jd_index_value := jurisdiction_codes_tbl_stg.LAST;
      WHILE l_counter IS NOT NULL LOOP
         hr_utility.trace('EMJT : =========================================================');
         hr_utility.trace('EMJT : jurisdiction_codes_tbl_stg('||to_char(l_counter)||').hours            ->'
                        || jurisdiction_codes_tbl_stg(l_counter).hours);
         hr_utility.trace('EMJT : jurisdiction_codes_tbl_stg('||to_char(l_counter)||').tg_hours         ->'
                        || jurisdiction_codes_tbl_stg(l_counter).tg_hours);
         hr_utility.trace('EMJT : jurisdiction_codes_tbl_stg('||to_char(l_counter)||').jurisdiction_code->'
                        || jurisdiction_codes_tbl_stg(l_counter).jurisdiction_code);
         hr_utility.trace('EMJT : jurisdiction_codes_tbl_stg('||to_char(l_counter)||').percentage       ->'
                        || jurisdiction_codes_tbl_stg(l_counter).percentage);
         hr_utility.trace('EMJT : jurisdiction_codes_tbl_stg('||to_char(l_counter)||').jd_type          ->'
                        || jurisdiction_codes_tbl_stg(l_counter).jd_type);
         hr_utility.trace('EMJT : =========================================================');
         l_counter := jurisdiction_codes_tbl_stg.NEXT(l_counter);
       END LOOP; --WHILE l_counter

--============================================================================================
--This part of the code is used to populate state, county and city level pl tables

-- State pl tables -> jd_codes_tbl_state_STG (STAGING) and jd_codes_tbl_state (MAIN)
-- County pl tables -> jd_codes_tbl_county_STG (STAGING) and jd_codes_tbl_county (MAIN)
-- City pl tables -> jd_codes_tbl_city_STG (STAGING) and jd_codes_tbl_city (MAIN)

--
-- This is to upload the primary work jurisdiction entered hours into staging table
-- created for threshold purpose
--

--Initialize the state and county pl tables.
--Purge all the staging pl/sql table used for Threshold
  hr_utility.trace('EMJT:  Purge All pl/sql table used for Threshold ');
  jd_codes_tbl_state_stg.delete;
  jd_codes_tbl_state.delete;
  jd_codes_tbl_county_stg.delete;
  jd_codes_tbl_county.delete;
  jd_codes_tbl_city_stg.delete;
  hr_utility.trace('EMJT:  PL/SQL tables are purged');
-- Loop thru the staging table to see whether any of the jurisdiction under threshold for taxing
-- Get the hours for each jurisdiction

--Start processing state data, populating the jd_codes_tbl_state.

 l_counter             := jurisdiction_codes_tbl_stg.FIRST;
 l_last_jd_index_value := jurisdiction_codes_tbl_stg.LAST;
 hr_utility.trace('EMJT:  First JD Code '||to_char(l_counter));
 hr_utility.trace('EMJT:  Last  JD Code '||to_char(l_last_jd_index_value));
 WHILE l_counter IS NOT NULL LOOP
 BEGIN
 --{
    l_jurisdiction := jurisdiction_codes_tbl_stg(l_counter).jurisdiction_code ;
    l_jd_hours     := jurisdiction_codes_tbl_stg(l_counter).hours ;
    hr_utility.trace('EMJT:  l_jurisdiction '|| l_jurisdiction);
    hr_utility.trace('EMJT:  l_counter '|| to_char(l_counter));
    --Processing For State
    IF jd_codes_tbl_state_stg.EXISTS(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||'0000000')
                                    ) THEN
    --{
       jd_codes_tbl_state_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||'0000000')).hours
          := jd_codes_tbl_state_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||'0000000')).hours
           + l_jd_hours;
       hr_utility.trace('EMJT:  State JD Code Exists in State Stg PL table');
    --}
    ELSE
    --{
       hr_utility.trace('EMJT:  State JD Code doesnot Exists in State Stage pl/sql table');
       jd_codes_tbl_state_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||'0000000')).jurisdiction_code
          := SUBSTR(l_jurisdiction,1,2)||'-000-0000';
       jd_codes_tbl_state_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||'0000000')).hours
          :=  l_jd_hours;

       IF l_jd_hours > 0 THEN
          jd_codes_tbl_state_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||'0000000')).calc_percent
	                             := 'Y';
       ELSE
          jd_codes_tbl_state_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||'0000000')).calc_percent
	                             := 'N';
       END IF;
       hr_utility.trace('EMJT:  State JD Code '|| SUBSTR(l_jurisdiction,1,2)||'-000-0000'
                        ||' loaded to pl/sql table');
    --}
    END IF;
    --End of processing for state

  hr_utility.trace('EMJT : =======================================================================');
  hr_utility.trace('EMJT : jd_codes_tbl_state_stg.count ->' || jd_codes_tbl_state_stg.COUNT);
  hr_utility.trace('EMJT : l_counter ->'||l_counter);

/*  hr_utility.trace('EMJT : jd_codes_tbl_state_stg.jurisdiction_code->' || jd_codes_tbl_state_stg(l_counter).jurisdiction_code);
  hr_utility.trace('EMJT : jd_codes_tbl_state_stg('||to_char(l_counter)||').hours            ->'
                  || jd_codes_tbl_state_stg(l_counter).hours);
  hr_utility.trace('EMJT : jd_codes_tbl_state_stg('||to_char(l_counter)||').percentage       ->'
                  || jd_codes_tbl_state_stg(l_counter).percentage);
  hr_utility.trace('EMJT : jd_codes_tbl_state_stg('||to_char(l_counter)||').calc_percent     ->'
                  || jd_codes_tbl_state_stg(l_counter).calc_percent);*/
  hr_utility.trace('EMJT : ========================================================================');

    --Processing For County
    IF jd_codes_tbl_county_stg.EXISTS(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
                                                SUBSTR(l_jurisdiction,4,3)||
                                               '0000')
                                      ) THEN
    --{
       jd_codes_tbl_county_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
                                         SUBSTR(l_jurisdiction,4,3)||'0000')).hours
            := jd_codes_tbl_county_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
                                                 SUBSTR(l_jurisdiction,4,3)||'0000')).hours
             + l_jd_hours;
       hr_utility.trace('EMJT:  County JD Code Exists in State Stage pl/sql table');
     --}
     ELSE
     --{
        hr_utility.trace('EMJT:  County JD Code doesnot Exists in County Stg pl table');
        hr_utility.trace('EMJT:  County JD Code '||SUBSTR(l_jurisdiction,1,7)||'0000');
        jd_codes_tbl_county_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
                                          SUBSTR(l_jurisdiction,4,3)||
                                         '0000')).jurisdiction_code
      			                := SUBSTR(l_jurisdiction,1,7)||'0000';

        jd_codes_tbl_county_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
                                          SUBSTR(l_jurisdiction,4,3)||
                                          '0000')
                                ).hours := l_jd_hours;

        IF l_jd_hours > 0 THEN
         jd_codes_tbl_county_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
                                           SUBSTR(l_jurisdiction,4,3)||
                                           '0000')
                                 ).calc_percent := 'Y';
        ELSE
         jd_codes_tbl_county_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
                                           SUBSTR(l_jurisdiction,4,3)||
                                           '0000')
                                ).calc_percent := 'N';
        END IF;
        hr_utility.trace('EMJT:  County JD Code '|| SUBSTR(l_jurisdiction,1,7)||'0000'
                     ||' loaded to pl/sql table');

       --}
     END IF;
     --End of processing for county.

     l_counter := jurisdiction_codes_tbl_stg.NEXT(l_counter);
  --}
  EXCEPTION
  WHEN OTHERS THEN
              hr_utility.trace('EMJT:  ERROR in populating State/County Stg Pl Table');
              hr_utility.trace(substr(sqlerrm,1,45));
              hr_utility.trace(substr(sqlerrm,46,45));
	      RAISE;
  END;
  END LOOP;
  hr_utility.trace('EMJT:  Staging table jd_codes_tbl_state_stg populated sucessfully');
  hr_utility.trace('EMJT:  Staging table jd_codes_tbl_county_stg populated sucessfully');
  l_counter   := NULL;
  --
  --This part of the code populates the MAIN STATE PL TABLE that will be used in get_jd_percent
  --FROM jd_codes_tbl_state_stg INTO jd_codes_tbl_state
  --
  hr_utility.trace('EMJT STATE:==============================================================');
  hr_utility.trace('EMJT STATE:  Main State Processing');
  l_counter             := jd_codes_tbl_state_stg.FIRST;
  l_last_jd_index_value := jd_codes_tbl_state_stg.LAST;
  hr_utility.trace('EMJT STATE:  State First JD Code '||to_char(l_counter));
  hr_utility.trace('EMJT STATE:  State Last  JD Code '||to_char(l_last_jd_index_value));

  WHILE l_counter IS NOT NULL LOOP
  --{
     l_jurisdiction := jd_codes_tbl_state_stg(l_counter).jurisdiction_code ;
     l_jd_hours     := jd_codes_tbl_state_stg(l_counter).hours ;
     l_calc_percent := jd_codes_tbl_state_stg(l_counter).calc_percent ;
     hr_utility.trace('EMJT STATE:  State l_counter            ->'|| l_counter);
     hr_utility.trace('EMJT STATE:  State Jurisdiction Code    =>'|| l_jurisdiction);
     hr_utility.trace('EMJT STATE:  State Hours                =>'|| to_char(l_jd_hours));
     hr_utility.trace('EMJT STATE:  State Calculate Percentage =>'|| l_calc_percent);
     -- When Jurisdiction state is same as primary work state no thresholding
     IF l_calc_percent = 'N' THEN
     --{
        hr_utility.trace('EMJT STATE:  Thresholding Not required load in jd_codes_tbl_state');
        jd_codes_tbl_state(l_counter).jurisdiction_code := l_jurisdiction;
        jd_codes_tbl_state(l_counter).hours             := l_jd_hours;
	jd_codes_tbl_state(l_counter).calc_percent      := l_calc_percent;
     --}
     ELSE
     --{
       IF SUBSTR(l_jurisdiction,1,2) = SUBSTR(l_work_jurisdiction_code,1,2) THEN
       --{
        hr_utility.trace('EMJT STATE:  Work state is same as Primary Work State');
	hr_utility.trace('EMJT STATE:  Threshold check not required load in jd_codes_tbl_state');
         IF jd_codes_tbl_state.EXISTS(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||'0000000'))
         THEN
         --{
	 hr_utility.trace('EMJT STATE: HERE in if');
	 hr_utility.trace('EMJT STATE: TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||''0000000'')-> '||TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||'0000000'));
	 hr_utility.trace('EMJT STATE: l_counter '|| to_char(l_counter));
	    jd_codes_tbl_state(l_counter).hours
                := NVL(jd_codes_tbl_state(l_counter).hours,0) + l_jd_hours;
         --}
         ELSE
         --{
	 hr_utility.trace('EMJT STATE: IN ELSE');
	    jd_codes_tbl_state(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_state(l_counter).hours             := l_jd_hours;
	    jd_codes_tbl_state(l_counter).calc_percent      := l_calc_percent;
 	    hr_utility.trace('EMJT STATE:  Primary Work State JD loaded into jd_codes_tbl_state');
         --}
	 END IF;
       --}
       ELSE --SUBSTR(l_jurisdiction,1,2) = SUBSTR(l_work_jurisdiction_code,1,2)
       --{
         hr_utility.trace('EMJT STATE:  Work state is NOT same as Primar Work State');
         --Fetch State level Threshold
         hr_utility.trace('EMJT STATE:  Fetching Threshold Hours configured for State ');
         hr_utility.trace('EMJT STATE:  Processing State JD Code '||l_jurisdiction);
         l_threshold_hours_state := get_jd_level_threshold(p_tax_unit_id
                                                          ,l_jurisdiction
                                                          ,'STATE');
         hr_utility.trace('EMJT STATE:  Threshold_Hours_State '|| to_char(l_threshold_hours_state));
         IF l_threshold_hours_state > 0 THEN
         --{
         -- Fetch the state level tax balance accrued for the person
	 -- If Tax balance found then tax the state as per hours logged for the state
	 -- otherwise hours will be accounted to primary work state
	 -- for SIT Witheld and/or SIT Supp Witheld
           hr_utility.trace('EMJT STATE:  Threshold_Hours_State > 0 so Fetch SIT Witheld for Assignment');



      /* Bug 6869097:The following code checks whether SIT is withheld already for the
         assignment and if it finds SIT is withheld already it assumes that the
         assignemnt has crossed the threshold limit already and inserts the
         current record. But there are some situations where tax is withheld
         for an assignment even before the threshold limit is reached. So commented
         the following code so that it can go on with threshold checking irrespective
         of SIT Withheld balance.
      */

      /*     l_sit_withheld :=
	        hr_us_ff_udf1.get_jd_tax_balance(p_threshold_basis      => l_threshold_basis
                                               ,p_assignment_action_id => p_assignment_action_id
                                               ,p_jurisdiction_code    => l_jurisdiction
                                               ,p_tax_unit_id          => p_tax_unit_id
                                               ,p_jurisdiction_level   => 'STATE'
                                               ,p_effective_date       => p_date_paid
					       ,p_assignment_id        => p_assignment_id);
           hr_utility.trace('EMJT STATE:  SIT Withheld for Assignment -> '|| to_char(l_sit_withheld));
	   IF l_sit_withheld > 0 THEN
           --{
              hr_utility.trace('EMJT STATE:  As Tax Withheld previously in State NO THRESHOLD CHECK');
              jd_codes_tbl_state(l_counter).jurisdiction_code := l_jurisdiction;
              jd_codes_tbl_state(l_counter).hours             := l_jd_hours;
              jd_codes_tbl_state(l_counter).calc_percent      := l_calc_percent;
              hr_utility.trace('EMJT STATE:  State JD '||l_jurisdiction||' loaded in jd_codes_tbl_state ');
           --}
	   ELSE --l_sit_withheld > 0 */

	   /*Bug#6869097: changes end here*/
           --{
	   -- Fetch Information Hours logged for the person depending on the payroll effective date
	   -- call to get_th_assignment for the STATE
             hr_utility.trace('EMJT STATE:  Fetch Information Hours Logged for Assignment ');
	     l_state_ih_logged
                   := hr_us_ff_udf1.get_person_it_hours(p_person_id        => l_person_id
		                                       ,p_assignment_id     => p_assignment_id
                                                       ,p_jurisdiction_code => l_jurisdiction
                                                       ,p_jd_level          => 2
                                                       ,p_threshold_basis   => l_threshold_basis
                                                       ,p_effective_date    => l_max_end_date  -- p_date_paid
					               ,p_end_date          => l_end_date);
             hr_utility.trace('EMJT STATE: Information Hours Logged for Assignment for State => '
                                               || to_char(l_state_ih_logged));
             IF l_state_ih_logged >= l_threshold_hours_state THEN
             --{
               hr_utility.trace('EMJT STATE:  Information Hours Logged > Threshold_Hours_State ');
               l_ih_excluding_pay_period := l_state_ih_logged - l_jd_hours;
               hr_utility.trace('EMJT STATE:  Information Hours Processed Prior This Pay Period -> '
	                                || to_char(l_ih_excluding_pay_period));
               -- if information hours processed till last payroll run is greater than the
               -- threshold limit configured at the State level then hours logged for the state
               -- would be accounted for that state
               --
               IF l_ih_excluding_pay_period >= l_threshold_hours_state THEN
               --{
                  hr_utility.trace('EMJT STATE:  Hours till last Pay Period > Threshold_Hours_State');
                  jd_codes_tbl_state(l_counter).jurisdiction_code := l_jurisdiction;
                  jd_codes_tbl_state(l_counter).hours             := l_jd_hours;
                  jd_codes_tbl_state(l_counter).calc_percent      := l_calc_percent;
                  hr_utility.trace('EMJT STATE:  State JD loaded into jd_codes_tbl_state '|| l_jurisdiction);
                  hr_utility.trace('EMJT STATE:  Hours    loaded into jd_codes_tbl_state '|| to_char(l_jd_hours));
	       --}
               ELSE  --l_ih_excluding_pay_period >= l_threshold_hours_state
               --{
               -- if information hours processed till last payroll run is less than the
               -- threshold limit configured at the State level
               -- Calculate information hours that is exceeds threshold limit
	       --
                  l_ih_above_threshold := l_state_ih_logged - l_threshold_hours_state;
                  hr_utility.trace('EMJT STATE:  Information Hours Above Threshold -> '
		                                                 || to_char(l_ih_above_threshold));
               --
               -- Calculate information hours that would be accounted to primary work location
               -- due to threshold
	       hr_utility.trace('EMJT STATE: l_jurisdiction -> '|| l_jurisdiction);
               hr_utility.trace('EMJT STATE: l_counter -> '|| to_char(l_counter));

                 l_ih_for_primary_wk  :=
		           jd_codes_tbl_state_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
   		                           '0000000')).hours - l_ih_above_threshold;
                 hr_utility.trace('EMJT STATE:  Hours Accounted for Primary Work Location '
		                                                 ||to_char(l_ih_for_primary_wk));

               -- if information hours logged for the state is more than threshold
               -- configured for the state, only exceeded hours would be accounted for that
               -- state
                 IF l_ih_above_threshold > 0 THEN
                    IF jd_codes_tbl_state.EXISTS(
                                TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||'0000000'))
                    THEN
		      jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_jurisdiction_code,1,2)
		                         ||'0000000')).hours :=
                         jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
			                 ||'0000000')).hours + l_ih_above_threshold ;
                      jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)
		                         ||'0000000')).calc_percent := l_calc_percent;
    		    ELSE
                        jd_codes_tbl_state(l_counter).jurisdiction_code := l_jurisdiction;
                        jd_codes_tbl_state(l_counter).hours             := l_ih_above_threshold ;
                        jd_codes_tbl_state(l_counter).calc_percent      := l_calc_percent;
                    END IF;
                 END IF;
               -- When Total information hours logged for the person is above threshold
               -- but there are some information hours need to accounted to primary
               -- work location due to threshold limit
               -- This is determine if part of information hours entered for the processing pay
               -- period need to be accounted to primary work location due to
               --
                 IF l_ih_for_primary_wk > 0 THEN
                 --{
		   hr_utility.trace(' EMJT STATE: l_ih_for_primary_wk -> ' || to_char(l_ih_for_primary_wk));
                   IF jd_codes_tbl_state.EXISTS(
                                TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||'0000000'))
                   THEN
                   --{
		      jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
		               ||'0000000')).hours :=
                         jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
			                ||'0000000')).hours + l_ih_for_primary_wk ;
                      hr_utility.trace('EMJT STATE:  Hours accounted for Primary WK JD State in IF '
		                        || to_char(l_ih_for_primary_wk));
                   --}
                   ELSE
                   --{
	              jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
                                                     ||'0000000')).jurisdiction_code
                               := SUBSTR(l_work_jurisdiction_code,1,2)||'-000-0000';
                      jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
                                                     ||'0000000')).hours        := l_ih_for_primary_wk;
                      jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
                                                     ||'0000000')).calc_percent := l_calc_percent;
                      hr_utility.trace('EMJT STATE:  Primary WK JD State loaded into pl table jd_codes_tbl_state');
                      hr_utility.trace('EMJT STATE:  Hours accounted for Primary WK JD State in ELSE '
		                        ||to_char(l_ih_for_primary_wk));
                   --}
	           END IF;
                 --}
                 END IF; --l_ih_for_primary_wk > 0
               --}
               END IF; --l_ih_excluding_pay_period >= l_threshold_hours_state
             --}
	     ELSE
	     --{
	     -- If Information Hours Logged for the assignment is less than Threshold Hours
	     -- configured for the state, information hours would be accounted to primary work
	     -- State
                IF jd_codes_tbl_state.EXISTS(
                             TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||'0000000'))
                THEN
                --{
		hr_utility.trace('EMJT STATE: l_jd_hours -> '|| to_char(l_jd_hours) );
		      jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
		               ||'0000000')).hours :=
                         jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
			                ||'0000000')).hours + l_jd_hours ;
                      hr_utility.trace('EMJT STATE:  Hours accounted for Primary WK JD State in IF l_jd_hours'
		                        || to_char(l_jd_hours));
                --}
                ELSE
                --{
                   hr_utility.trace('EMJT STATE: l_work_jurisdiction_code -> '|| l_work_jurisdiction_code);
                   hr_utility.trace('EMJT STATE: l_counter -> '|| to_char(l_counter));
                   hr_utility.trace('EMJT STATE: l_calc_percent -> '|| l_calc_percent);
	           jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
		                   ||'0000000')).jurisdiction_code
                                   := SUBSTR(l_work_jurisdiction_code,1,2)||'-000-0000';
                   jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
		                   ||'0000000')).hours        := l_jd_hours;
                   jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)
		                   ||'0000000')).calc_percent := l_calc_percent;
                   hr_utility.trace('EMJT STATE:  Primary WK JD State loaded into pl table jd_codes_tbl_state');
                   hr_utility.trace('EMJT STATE:  Hours accounted for Primary WK JD State in ELSE l_jd_hours '
		                        ||to_char(l_jd_hours));
                --}
	        END IF;
	     --}
             END IF; --l_state_ih_logged > l_threshold_hours_state
	   --}
--	   END IF;--l_sit_withheld > 0 /*6869097*/
         --}
         ELSE
	 -- If Threshold Hours not logged for a State load Jurisdiction into jd_codes_tbl_state
	 --
         --{
 	    jd_codes_tbl_state(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_state(l_counter).hours             := l_jd_hours;
	    jd_codes_tbl_state(l_counter).calc_percent      := l_calc_percent;
            hr_utility.trace('EMJT STATE:  Work JD State loaded into jd_codes_tbl_state =>'
	                    ||l_jurisdiction);
            hr_utility.trace('EMJT STATE:  Hours accounted for Primary WK JD State '
		                        ||to_char(l_ih_for_primary_wk));
	 --}
         END IF;--l_threshold_hours_state > 0
       --}
       END IF; --SUBSTR(l_jurisdiction,1,2) = SUBSTR(l_work_jurisdiction_code,1,2)
     --}
     END IF; --l_calc_percent = 'N'

/*     hr_utility.trace('EMJT:Testing =================================================');
     l_in_counter := NULL;
     l_in_counter := jd_codes_tbl_state.FIRST;
     WHILE l_in_counter IS NOT NULL LOOP
        hr_utility.trace('EMJT: jd_codes_tbl_state.jurisdiction_code -> '||jd_codes_tbl_state(l_in_counter).jurisdiction_code);
        hr_utility.trace('EMJT: jd_codes_tbl_state.hours             -> '||jd_codes_tbl_state(l_in_counter).hours);
	l_in_counter := jd_codes_tbl_state.NEXT(l_in_counter);
     END LOOP;
     hr_utility.trace('EMJT:=================================================');*/

  hr_utility.trace('EMJT STATE:  Setting the Index counter to fetch next JD State ');
  l_counter := jd_codes_tbl_state_stg.NEXT(l_counter);
  hr_utility.trace('EMJT STATE:  Next Index Counter Value '||to_char(l_counter));
  --}
  END LOOP;
  hr_utility.trace('EMJT STATE: Final jd_codes_tbl_state.count ->' || jd_codes_tbl_state.COUNT);
  hr_utility.trace('EMJT STATE:  PL Table jd_codes_tbl_state_stg processed Successfully');
  --Done with populating the jd_codes_tbl_state.


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   l_counter := NULL;
   l_counter := jd_codes_tbl_state.FIRST;
   l_last_jd_index_value := jd_codes_tbl_state.LAST;
   hr_utility.trace('EMJT STATE: jd_codes_tbl_state.FIRST->' || jd_codes_tbl_state.FIRST);
   hr_utility.trace('EMJT STATE: jd_codes_tbl_state.LAST->' || jd_codes_tbl_state.LAST);

   WHILE l_counter IS NOT NULL LOOP
         hr_utility.trace('EMJT STATE: =========================================================');
         hr_utility.trace('EMJT STATE: jd_codes_tbl_state('||to_char(l_counter)||').hours            ->'
                        || jd_codes_tbl_state(l_counter).hours);
         hr_utility.trace('EMJT STATE: jd_codes_tbl_state('||to_char(l_counter)||').jurisdiction_code->'
                        || jd_codes_tbl_state(l_counter).jurisdiction_code);
         hr_utility.trace('EMJT STATE: jd_codes_tbl_state('||to_char(l_counter)||').percentage       ->'
                        || jd_codes_tbl_state(l_counter).percentage);
         hr_utility.trace('EMJT STATE: =========================================================');
     l_total_state_hours := l_total_state_hours + NVL(jd_codes_tbl_state(l_counter).hours,0);
     l_counter := jd_codes_tbl_state.NEXT(l_counter);
   END LOOP;

   hr_utility.trace('EMJT STATE: Final l_total_state_hours  ->' || to_char(l_total_state_hours) );
   hr_utility.trace('EMJT STATE: Final l_scheduled_work_hours  ->' || to_char(l_scheduled_work_hours) );

   IF l_total_state_hours <= l_scheduled_work_hours THEN
      l_denominator := l_scheduled_work_hours;
   ELSIF l_total_state_hours > l_scheduled_work_hours THEN
      l_denominator := l_total_state_hours;
   END IF;

   hr_utility.trace('EMJT STATE: Final l_denominator  ->' || to_char(l_denominator) );

   l_counter := NULL;
   l_counter := jd_codes_tbl_state.FIRST;
   l_last_jd_index_value := jd_codes_tbl_state.LAST;
   WHILE l_counter IS NOT NULL LOOP
         l_jd_hours := jd_codes_tbl_state(l_counter).hours ;
         jd_codes_tbl_state(l_counter).percentage :=
                    ROUND((l_jd_hours/l_denominator) * 100);
        /* hr_utility.trace('EMJT: =========================================================');
         hr_utility.trace('EMJT: jd_codes_tbl_state('||to_char(l_counter)||').hours            ->'
                        || jd_codes_tbl_state(l_counter).hours);
         hr_utility.trace('EMJT: jd_codes_tbl_state('||to_char(l_counter)||').jurisdiction_code->'
                        || jd_codes_tbl_state(l_counter).jurisdiction_code);
         hr_utility.trace('EMJT: jd_codes_tbl_state('||to_char(l_counter)||').percentage       ->'
                        || jd_codes_tbl_state(l_counter).percentage);
         hr_utility.trace('EMJT: =========================================================');*/
         l_total_state_percent := l_total_state_percent
                          + jd_codes_tbl_state(l_counter).percentage;
         l_counter := jd_codes_tbl_state.NEXT(l_counter);
   END LOOP; --WHILE l_counter

hr_utility.trace('EMJT STATE: (TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||''0000000'')) '||
                        TO_CHAR(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||'0000000')));
   IF l_total_state_percent > 100 THEN
   --{
      l_extra_percent := l_total_state_percent - 100;
      IF l_primary_work_jd_flag = 'Y' THEN
         jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||'0000000')).percentage
	      := jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||'0000000')).percentage
	       - l_extra_percent;
      ELSE
	 jd_codes_tbl_state(l_last_jd_index_value).percentage
	     := jd_codes_tbl_state(l_last_jd_index_value).percentage
	       - l_extra_percent;
      END IF;
   --}
   ELSIF l_total_state_percent < 100 THEN
   --{
      l_extra_percent := 100 - l_total_state_percent;
      IF l_primary_work_jd_flag = 'Y' THEN
         jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||'0000000')).percentage
            := jd_codes_tbl_state(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||'0000000')).percentage
	    + l_extra_percent;
      ELSE
	 jd_codes_tbl_state(l_last_jd_index_value).percentage
            := jd_codes_tbl_state(l_last_jd_index_value).percentage
	     + l_extra_percent;
      END IF;
   --}
   END IF; --l_total_state_percent > 100


   l_counter := NULL;
   l_counter := jd_codes_tbl_state.FIRST;
 --  l_last_jd_index_value := jd_codes_tbl_state.LAST;
   hr_utility.trace('EMJT STATE: jd_codes_tbl_state.FIRST->' || jd_codes_tbl_state.FIRST);
   hr_utility.trace('EMJT STATE: jd_codes_tbl_state.LAST->' || jd_codes_tbl_state.LAST);
   WHILE l_counter IS NOT NULL LOOP
         hr_utility.trace('EMJT STATE: Final State Table');
         hr_utility.trace('EMJT STATE: =========================================================');
         hr_utility.trace('EMJT STATE: jd_codes_tbl_state('||to_char(l_counter)||').hours            ->'
                        || jd_codes_tbl_state(l_counter).hours);
         hr_utility.trace('EMJT STATE: jd_codes_tbl_state('||to_char(l_counter)||').jurisdiction_code->'
                        || jd_codes_tbl_state(l_counter).jurisdiction_code);
         hr_utility.trace('EMJT STATE: jd_codes_tbl_state('||to_char(l_counter)||').percentage       ->'
                        || jd_codes_tbl_state(l_counter).percentage);
         hr_utility.trace('EMJT STATE: =========================================================');
--     l_total_state_hours := l_total_state_hours + jd_codes_tbl_state(l_counter).hours;
     l_counter := jd_codes_tbl_state.NEXT(l_counter);
   END LOOP;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  hr_utility.trace('EMJT COUNTY:==============================================================');
  hr_utility.trace('EMJT COUNTY:  Main COUNTY Processing');

  --Starting processing the county, populating jd_codes_tbl_county.
  --
  --This part of the code populates the MAIN COUNTY PL TABLE from the staging county pl table.
  --INTO jd_codes_tbl_county
  --FROM jd_codes_tbl_county_stg
  --
  l_counter   := NULL;
  l_counter             := jd_codes_tbl_county_stg.FIRST;
  l_last_jd_index_value := jd_codes_tbl_county_stg.LAST;
  hr_utility.trace('EMJT COUNTY:  l_counter First JD Code -> '|| to_char(l_counter));
  hr_utility.trace('EMJT COUNTY:  Last  JD Code ->'|| to_char(l_last_jd_index_value));
  WHILE l_counter IS NOT NULL LOOP
  --{
    l_jurisdiction := jd_codes_tbl_county_stg(l_counter).jurisdiction_code ;
    l_jd_hours     := jd_codes_tbl_county_stg(l_counter).hours ;
    l_calc_percent := jd_codes_tbl_county_stg(l_counter).calc_percent ;
    hr_utility.trace('EMJT COUNTY:  Jurisdiction Code    =>'|| l_jurisdiction);
    hr_utility.trace('EMJT COUNTY:  l_jd_hours           =>'|| to_char(l_jd_hours));
    hr_utility.trace('EMJT COUNTY:  Calculate Percenrage =>'|| l_calc_percent);

  -- When Jurisdiction county is same as primary work county no thresholding
  IF l_calc_percent = 'N' THEN
  --{
    hr_utility.trace('EMJT COUNTY:  Thresholding Not required load in jd_codes_tbl_county');
    jd_codes_tbl_county(l_counter).jurisdiction_code := l_jurisdiction;
    jd_codes_tbl_county(l_counter).hours             := l_jd_hours;
    jd_codes_tbl_county(l_counter).calc_percent      := l_calc_percent;
  --}
  ELSE
  --{
    IF SUBSTR(l_jurisdiction,1,2)||SUBSTR(l_jurisdiction,4,3) =
       SUBSTR(l_work_jurisdiction_code,1,2)||SUBSTR(l_work_jurisdiction_code,4,3) THEN
    --{
      hr_utility.trace('EMJT COUNTY:  Work County is same as Primar Work County');
      hr_utility.trace('EMJT COUNTY:  Threshold check not required to load in jd_codes_tbl_county');
      IF jd_codes_tbl_county.EXISTS(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
                                              SUBSTR(l_jurisdiction,4,3) ||'0000'))
      THEN
      --{
         jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
	                              SUBSTR(l_jurisdiction,4,3) ||
                                      '0000')).hours
                := jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
                                                 SUBSTR(l_jurisdiction,4,3) ||
                                                 '0000')).hours + l_jd_hours;
      --}
      ELSE
      --{
         jd_codes_tbl_county(l_counter).jurisdiction_code := l_jurisdiction;
         jd_codes_tbl_county(l_counter).hours             := l_jd_hours;
         jd_codes_tbl_county(l_counter).calc_percent      := l_calc_percent;
         hr_utility.trace('EMJT COUNTY:  Primary Work State JD loaded into jd_codes_tbl_state');
      --}
      END IF;
    --}
    ELSE --SUBSTR(l_jurisdiction,1,2) = SUBSTR(l_work_jurisdiction_code,1,2)
    --{
       --Fetch County level threshold
       hr_utility.trace('EMJT COUNTY:  Work County is NOT same as Primary Work County');
       hr_utility.trace('EMJT COUNTY:  Fetching Threshold Hours configured for County ');
       hr_utility.trace('EMJT COUNTY:  Processing County JD Code '|| l_jurisdiction);

       l_threshold_hours_county := get_jd_level_threshold(p_tax_unit_id
                                                         ,l_jurisdiction
                                                         ,'COUNTY');
       hr_utility.trace('EMJT COUNTY:  Threshold_Hours_County '|| to_char(l_threshold_hours_county));
       IF l_threshold_hours_county > 0 THEN
       --{
         -- Fetch the county level tax balance accrued for the person
         -- If Tax balance found then tax the county as per hours logged for the county
         -- otherwise hours will be accounted to primary work county
         hr_utility.trace('EMJT COUNTY:  Threshold_Hours_County > 0 so Fetch County Witheld for Assignment');

      /* Bug#6869097:The following code checks whether county tax is withheld already
         for the assignment and if it finds SIT is withheld already it assumes that
         the assignemnt has crossed the threshold limit already and inserts the
         current record. Commented the following code so that it can go on with
         threshold checking irrespective of county tax Withheld balance.
      */

        /* l_county_withheld :=
	        hr_us_ff_udf1.get_jd_tax_balance(p_threshold_basis     => l_threshold_basis
                                               ,p_assignment_action_id=> p_assignment_action_id
                                               ,p_jurisdiction_code   => l_jurisdiction
                                               ,p_tax_unit_id         => p_tax_unit_id
                                               ,p_jurisdiction_level  => 'COUNTY'
                                               ,p_effective_date      => p_date_paid
					       ,p_assignment_id       => p_assignment_id);
         hr_utility.trace('EMJT COUNTY:  County Withheld for Assignment '|| to_char(l_county_withheld));
         hr_utility.trace('EMJT COUNTY:  jd_codes_tbl_county.COUNT -> '|| jd_codes_tbl_county.COUNT);

--=============================================================================
          IF l_county_withheld = 0 THEN

           l_sit_county_withheld :=
	        hr_us_ff_udf1.get_jd_tax_balance(p_threshold_basis      => l_threshold_basis
                                               ,p_assignment_action_id => p_assignment_action_id
                                               ,p_jurisdiction_code    => l_jurisdiction
                                               ,p_tax_unit_id          => p_tax_unit_id
                                               ,p_jurisdiction_level   => 'STATE'
                                               ,p_effective_date       => p_date_paid
					       ,p_assignment_id        => p_assignment_id);
           hr_utility.trace('EMJT: l_sit_county_withheld -> '||to_char(l_sit_county_withheld));
          END IF;
--=============================================================================

         IF l_county_withheld > 0 THEN
         --{
            hr_utility.trace('EMJT COUNTY:  As Tax Withheld previously in County NO THRESHOLD CHECK');
            hr_utility.trace('EMJT COUNTY: l_county_withheld > 0 ');
            jd_codes_tbl_county(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_county(l_counter).hours             := l_jd_hours;
            jd_codes_tbl_county(l_counter).calc_percent      := l_calc_percent;
            hr_utility.trace('EMJT COUNTY:  County JD '||l_jurisdiction||' loaded in jd_codes_tbl_county ');
         --}
         ELSIF l_county_withheld = 0 AND l_sit_county_withheld > 0 THEN
         --{
            hr_utility.trace('EMJT COUNTY: l_county_withheld = 0 AND l_sit_county_withheld > 0 ');
            jd_codes_tbl_county(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_county(l_counter).hours             := l_jd_hours;
            jd_codes_tbl_county(l_counter).calc_percent      := l_calc_percent;
            hr_utility.trace('EMJT COUNTY:  County JD '||l_jurisdiction||' loaded in jd_codes_tbl_county ');
         --}
      --   ELSE --l_county_withheld > 0 */

      /*Bug#6869097: changes end here*/
         --{
         -- Fetch Information Hours logged for the person depending on the payroll effective date
	 -- call to get_th_assignment for the COUNTY
            hr_utility.trace('EMJT COUNTY:  Fetch Information Hours Logged for Assignment ');
	    l_county_ih_logged
	     := hr_us_ff_udf1.get_person_it_hours(p_person_id         => l_person_id
	                                         ,p_assignment_id     => p_assignment_id
                                                 ,p_jurisdiction_code => l_jurisdiction
                                                 ,p_jd_level          => 6
                                                 ,p_threshold_basis   => l_threshold_basis
                                                 ,p_effective_date    => l_max_end_date --p_date_paid
						 ,p_end_date          => l_end_date);
           hr_utility.trace('EMJT COUNTY:  Information Hours Logged for Assignment => '|| to_char(l_county_ih_logged));
           IF l_county_ih_logged >= l_threshold_hours_county THEN
           --{
             hr_utility.trace('EMJT COUNTY:  Information Hours Logged > Threshold_Hours_County ');
             l_ih_excluding_pay_period := l_county_ih_logged
                                        - l_jd_hours;
             hr_utility.trace('EMJT COUNTY:  Information Hours Processed Prior This Pay Period '
	                                                       || to_char(l_ih_excluding_pay_period));
             -- if information hours processed till last payroll run is greater than the
             -- threshold limit configured at the County level then hours logged for the county
             -- would be accounted for that county
             --
             IF l_ih_excluding_pay_period >= l_threshold_hours_county THEN
             --{
                hr_utility.trace('EMJT COUNTY:  Hours till last Pay Period > Threshold_Hours_State');
                jd_codes_tbl_county(l_counter).jurisdiction_code := l_jurisdiction;
                jd_codes_tbl_county(l_counter).hours             := l_jd_hours;
                jd_codes_tbl_county(l_counter).calc_percent      := l_calc_percent;
                hr_utility.trace('EMJT COUNTY:  County JD loaded into jd_codes_tbl_county '|| l_jurisdiction);
                hr_utility.trace('EMJT COUNTY:  Hours     loaded into jd_codes_tbl_county '|| to_char(l_jd_hours));

             --}
             ELSE  --l_ih_excluding_pay_period >= l_threshold_hours_county
             --{
                -- if information hours processed till last payroll run is less than the
                -- threshold limit configured at the county level
                -- Calculate information hours that is exceeds threshold limit
                l_ih_above_threshold := l_county_ih_logged - l_threshold_hours_county;
                hr_utility.trace('EMJT COUNTY:  Information Hours Above Threshold '
		                                                 || to_char(l_ih_above_threshold));

                -- Calculate information hours that would be accounted to primary work location
                -- due to threshold
                l_ih_for_primary_wk  := jd_codes_tbl_county_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
                                                                     SUBSTR(l_jurisdiction,4,3) ||
					                             '0000')
                                                           ).hours - l_ih_above_threshold;
                hr_utility.trace('EMJT COUNTY:  Hours Accounted for Primary Work Location '
		                                                 || to_char(l_ih_for_primary_wk));

                -- if information hours logged for the county is more than threshold
                -- configured for the county, only exceeded hours would be accounted for that
                -- county
                IF l_ih_above_threshold > 0 THEN
                   IF jd_codes_tbl_county.EXISTS(
                                TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
 				          SUBSTR(l_jurisdiction,4,3) ||'0000'))
                    THEN
		      jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
   			  SUBSTR(l_jurisdiction,4,3)||'0000')).hours :=
                             jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
   				                   SUBSTR(l_jurisdiction,4,3)||'0000')).hours
                           + l_ih_above_threshold ;
                      jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_jurisdiction,1,2)||
		          SUBSTR(l_jurisdiction,4,3) ||'0000')).calc_percent := l_calc_percent;
    		    ELSE
                    --{
                      jd_codes_tbl_county(l_counter).jurisdiction_code := l_jurisdiction;
                      jd_codes_tbl_county(l_counter).hours             := l_ih_above_threshold ;
                      jd_codes_tbl_county(l_counter).calc_percent      := l_calc_percent;
		    --}
		    END IF;
               END IF;
               -- When Total information hours logged for the person is above threshold
               -- but there are some information hours need to accounted to primary
               -- work location due to threshold limit
               -- This is determine if part of information hours entered for the processing pay
               -- period need to be accounted to primary work location due to
               --
               IF l_ih_for_primary_wk > 0 THEN
               --{
                 IF jd_codes_tbl_county.EXISTS(
                                TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
				          SUBSTR(l_work_jurisdiction_code,4,3) ||
					  '0000'))
                 THEN
                 --{
                   jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                 SUBSTR(l_work_jurisdiction_code,4,3) ||
					         '0000')
                                      ).hours :=
                   jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                 SUBSTR(l_work_jurisdiction_code,4,3) ||
					         '0000')
                                      ).hours + l_ih_for_primary_wk ;
                   hr_utility.trace('EMJT COUNTY:  Hours accounted for Primary WK JD County '
		                        || to_char(l_ih_for_primary_wk));

                 --}
                 ELSE
                 --{
                   jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                 SUBSTR(l_work_jurisdiction_code,4,3) ||
					         '0000')).jurisdiction_code
                                         := SUBSTR(l_work_jurisdiction_code,1,7)||'0000';
                    jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                 SUBSTR(l_work_jurisdiction_code,4,3) ||
					         '0000')).hours
				         := l_ih_for_primary_wk;
                    jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                 SUBSTR(l_work_jurisdiction_code,4,3) ||
					         '0000')).calc_percent
					 := l_calc_percent;
                    hr_utility.trace('EMJT COUNTY:  Primary WK JD State loaded into pl table jd_codes_tbl_county');
                    hr_utility.trace('EMJT COUNTY:  Hours accounted for Primary WK JD County '
		                        ||to_char(l_ih_for_primary_wk));
                 --}
	         END IF;
               --}
               END IF; --l_ih_for_primary_wk > 0
             --}
             END IF; --l_ih_excluding_pay_period >= l_threshold_hours_county
           --}
	   ELSE -- l_county_ih_logged >= l_threshold_hours_county
	   --{
	     -- If Information Hours Logged for the assignment is less than Threshold Hours
	     -- configured for the County, information hours would be accounted to primary work
	     -- County
                IF jd_codes_tbl_county.EXISTS(
                             TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                       SUBSTR(l_work_jurisdiction_code,4,3) ||
				       '0000'))
                THEN
                --{
		      jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                    '0000')).hours :=
                         jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                       SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                       '0000')).hours + l_jd_hours ;
                      hr_utility.trace('EMJT COUNTY:  Hours accounted for Primary WK JD County '
		                        ||to_char(l_jd_hours));
                --}
                ELSE
                --{
	              jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                   '0000')).jurisdiction_code
                               := SUBSTR(l_work_jurisdiction_code,1,7)||'0000';
                      jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                    '0000')).hours        := l_jd_hours;
                      jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                    '0000')).calc_percent := l_calc_percent;
                      hr_utility.trace('EMJT COUNTY:  Primary WK JD County loaded into pl table jd_codes_tbl_county');
                      hr_utility.trace('EMJT COUNTY:  Hours accounted for Primary WK JD County '
		                        ||to_char(l_jd_hours));
                --}
	        END IF;
	   --}
           END IF;
	 --}
--	 END IF;--l_county_withheld > 0  /*Bug#6869097*/
       --}
       ELSE
	 -- If Threshold Hours not logged for the County load Jurisdiction into jd_codes_tbl_state
	 --
         --{
 	    jd_codes_tbl_county(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_county(l_counter).hours             := l_jd_hours;
	    jd_codes_tbl_county(l_counter).calc_percent      := l_calc_percent;
            hr_utility.trace('EMJT COUNTY:  Work JD State loaded into jd_codes_tbl_state =>'
	                    ||l_jurisdiction);
            hr_utility.trace('EMJT COUNTY:  Hours accounted for Primary WK JD State '
		                        ||to_char(l_ih_for_primary_wk));
	 --}
       END IF;--l_threshold_hours_county > 0
     --}
     END IF; --SUBSTR(l_jurisdiction,1,2) = SUBSTR(l_work_jurisdiction_code,1,2)
   --}
   END IF; --l_calc_percent = 'N'
 --}
  hr_utility.trace('EMJT COUNTY: =======================================================================');
  hr_utility.trace('EMJT COUNTY: jd_codes_tbl_county.COUNT -> '|| jd_codes_tbl_county.COUNT);
/*  hr_utility.trace('EMJT : jd_codes_tbl_county('||to_char(l_counter)||').hours            ->'
                  || jd_codes_tbl_county(l_counter).hours);
  hr_utility.trace('EMJT : jd_codes_tbl_county('||to_char(l_counter)||').jurisdiction_code->'
                  || jd_codes_tbl_county(l_counter).jurisdiction_code);
  hr_utility.trace('EMJT : jd_codes_tbl_county('||to_char(l_counter)||').percentage       ->'
                  || jd_codes_tbl_county(l_counter).percentage);
  hr_utility.trace('EMJT : jd_codes_tbl_county('||to_char(l_counter)||').calc_percent     ->'
                  || jd_codes_tbl_county(l_counter).calc_percent);*/
  hr_utility.trace('EMJT COUNTY: ========================================================================');
  hr_utility.trace('EMJT COUNTY:  Setting the Index counter to fetch next JD County ');
   l_counter := jd_codes_tbl_county_stg.NEXT(l_counter);
   hr_utility.trace('EMJT COUNTY:  Next Index Counter Value '||to_char(l_counter));
 END LOOP;
 --Done with populating the jd_codes_tbl_county
 hr_utility.trace('EMJT COUNTY:  PL Table jd_codes_tbl_county_stg processed Successfully');
 hr_utility.trace('EMJT COUNTY:  PL Table jd_codes_tbl_county populated with required County details');


 --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   l_counter := NULL;
   l_counter := jd_codes_tbl_county.FIRST;
   l_last_jd_index_value := jd_codes_tbl_county.LAST;
   hr_utility.trace('EMJT COUNTY: jd_codes_tbl_county.FIRST->' || jd_codes_tbl_county.FIRST);
   hr_utility.trace('EMJT COUNTY: jd_codes_tbl_county.LAST->' || jd_codes_tbl_county.LAST);

   WHILE l_counter IS NOT NULL LOOP
      /*   hr_utility.trace('EMJT: =========================================================');
         hr_utility.trace('EMJT: jd_codes_tbl_county('||to_char(l_counter)||').hours            ->'
                        || jd_codes_tbl_county(l_counter).hours);
         hr_utility.trace('EMJT: jd_codes_tbl_county('||to_char(l_counter)||').jurisdiction_code->'
                        || jd_codes_tbl_county(l_counter).jurisdiction_code);
         hr_utility.trace('EMJT: jd_codes_tbl_county('||to_char(l_counter)||').percentage       ->'
                        || jd_codes_tbl_county(l_counter).percentage);
         hr_utility.trace('EMJT: =========================================================');*/
     l_total_county_hours := l_total_county_hours + NVL(jd_codes_tbl_county(l_counter).hours,0);
     l_counter := jd_codes_tbl_county.NEXT(l_counter);
   END LOOP;

   hr_utility.trace('EMJT COUNTY: l_total_county_hours  ->' || to_char(l_total_county_hours) );

   IF l_total_county_hours <= l_scheduled_work_hours THEN
      l_denominator := l_scheduled_work_hours;
   ELSIF l_total_county_hours > l_scheduled_work_hours THEN
      l_denominator := l_total_county_hours;
   END IF;

   l_counter := NULL;
   l_counter := jd_codes_tbl_county.FIRST;
   l_last_jd_index_value := jd_codes_tbl_county.LAST;
   WHILE l_counter IS NOT NULL LOOP
         l_jd_hours := jd_codes_tbl_county(l_counter).hours ;
         jd_codes_tbl_county(l_counter).percentage :=
                    ROUND((l_jd_hours/l_denominator) * 100);
   /*      hr_utility.trace('EMJT: =========================================================');
         hr_utility.trace('EMJT: jd_codes_tbl_county('||to_char(l_counter)||').hours            ->'
                        || jd_codes_tbl_county(l_counter).hours);
         hr_utility.trace('EMJT: jd_codes_tbl_county('||to_char(l_counter)||').jurisdiction_code->'
                        || jd_codes_tbl_county(l_counter).jurisdiction_code);
         hr_utility.trace('EMJT: jd_codes_tbl_county('||to_char(l_counter)||').percentage       ->'
                        || jd_codes_tbl_county(l_counter).percentage);
         hr_utility.trace('EMJT: =========================================================');*/
         l_total_county_percent := l_total_county_percent
                          + jd_codes_tbl_county(l_counter).percentage;
         l_counter := jd_codes_tbl_county.NEXT(l_counter);
   END LOOP; --WHILE l_counter

   l_extra_percent := 0;
   IF l_total_county_percent > 100 THEN
   --{
      l_extra_percent := l_total_county_percent - 100;
      IF l_primary_work_jd_flag = 'Y' THEN
         jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||
                                       SUBSTR(l_work_jurisdiction_code,4,3)||'0000')).percentage
	      := jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||
	                                       SUBSTR(l_work_jurisdiction_code,4,3)||'0000')).percentage
	       - l_extra_percent;
      ELSE
	 jd_codes_tbl_county(l_last_jd_index_value).percentage
	     := jd_codes_tbl_county(l_last_jd_index_value).percentage
	       - l_extra_percent;
      END IF;
   --}
   ELSIF l_total_county_percent < 100 THEN
   --{
      l_extra_percent := 100 - l_total_county_percent;
      IF l_primary_work_jd_flag = 'Y' THEN
         jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||
                                       SUBSTR(l_work_jurisdiction_code,4,3)||'0000')).percentage
	      := jd_codes_tbl_county(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2)||
	                                       SUBSTR(l_work_jurisdiction_code,4,3)||'0000')).percentage
	       + l_extra_percent;
      ELSE
	 jd_codes_tbl_county(l_last_jd_index_value).percentage
	     := jd_codes_tbl_county(l_last_jd_index_value).percentage
	      + l_extra_percent;
      END IF;
   --}
   END IF; --l_total_county_percent > 100


   l_counter := NULL;
   l_counter := jd_codes_tbl_county.FIRST;
--   l_last_jd_index_value := jd_codes_tbl_county.LAST;
--   hr_utility.trace('EMJT: jd_codes_tbl_county.FIRST->' || jd_codes_tbl_county.FIRST);
--   hr_utility.trace('EMJT: jd_codes_tbl_county.LAST->' || jd_codes_tbl_county.LAST);

  WHILE l_counter IS NOT NULL LOOP
         hr_utility.trace('EMJT COUNTY: Final County Table ');
         hr_utility.trace('EMJT COUNTY: =========================================================');
         hr_utility.trace('EMJT COUNTY: jd_codes_tbl_county('||to_char(l_counter)||').hours            ->'
                        || jd_codes_tbl_county(l_counter).hours);
         hr_utility.trace('EMJT COUNTY: jd_codes_tbl_county('||to_char(l_counter)||').jurisdiction_code->'
                        || jd_codes_tbl_county(l_counter).jurisdiction_code);
         hr_utility.trace('EMJT COUNTY: jd_codes_tbl_county('||to_char(l_counter)||').percentage       ->'
                        || jd_codes_tbl_county(l_counter).percentage);
         hr_utility.trace('EMJT COUNTY: =========================================================');
--     l_total_county_hours := l_total_county_hours + jd_codes_tbl_county(l_counter).hours;
     l_counter := jd_codes_tbl_county.NEXT(l_counter);
   END LOOP;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

hr_utility.trace('EMJT CITY :===========================================================');
hr_utility.trace('EMJT CITY: Main City Processing');

 --Starting processing the city, populating jurisdiction_codes_tbl.
 l_counter   := NULL;
 --
 --This part of the code populates the MAIN COUNTY PL TABLE from the staging city pl table.
 --INTO jurisdiction_codes_tbl
 --FROM jd_codes_tbl_city_stg
 -- l_primary_work_jd_index_value
 l_counter             := jurisdiction_codes_tbl_stg.FIRST;
 l_last_jd_index_value := jurisdiction_codes_tbl_stg.LAST;
 hr_utility.trace('EMJT CITY:  First JD Code '||to_char(l_counter));
 hr_utility.trace('EMJT CITY:  Last  JD Code '||to_char(l_last_jd_index_value));

 WHILE l_counter IS NOT NULL LOOP
 --{
    l_jurisdiction := jurisdiction_codes_tbl_stg(l_counter).jurisdiction_code ;
    l_jd_hours     := jurisdiction_codes_tbl_stg(l_counter).hours ;
    hr_utility.trace('EMJT CITY:  l_counter    =>'|| to_char(l_counter));
    hr_utility.trace('EMJT CITY:  Jurisdiction Code    =>'|| l_jurisdiction);
    hr_utility.trace('EMJT CITY:  l_jd_hours             =>'|| to_char(l_jd_hours));
    hr_utility.trace('EMJT CITY:  l_work_jurisdiction_code '|| l_work_jurisdiction_code);

    IF SUBSTR(l_jurisdiction,1,2) ||
       SUBSTR(l_jurisdiction,4,3) ||
       SUBSTR(l_jurisdiction,8,4) =
       SUBSTR(l_work_jurisdiction_code,1,2) ||
       SUBSTR(l_work_jurisdiction_code,4,3) ||
       SUBSTR(l_work_jurisdiction_code,8,4)
    THEN
    --{

      IF jd_codes_tbl_city_stg.EXISTS(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
                                                 SUBSTR(l_jurisdiction,4,3) ||
                                                 SUBSTR(l_jurisdiction,8,4) ))
      THEN
      --{
        hr_utility.trace('EMJT CITY:  Primary WK JD already in jd_codes_tbl_city_stg');
        hr_utility.trace('EMJT CITY:  Add This JD Hours to Primary Work Location');
        jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
	                                 SUBSTR(l_jurisdiction,4,3) ||
                                         SUBSTR(l_jurisdiction,8,4))).hours
                := jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
                                                    SUBSTR(l_jurisdiction,4,3) ||
                                                    SUBSTR(l_jurisdiction,8,4) )
                                         ).hours + l_jd_hours;
      --}
      ELSE
      --{
        hr_utility.trace('EMJT CITY:  Primary work jurisidction loaded in jd_codes_tbl_city_stg');
        jd_codes_tbl_city_stg(l_counter).jurisdiction_code := l_jurisdiction;
        jd_codes_tbl_city_stg(l_counter).hours             := l_jd_hours;
        jd_codes_tbl_city_stg(l_counter).jd_type           :=
	                       jurisdiction_codes_tbl_stg(l_counter).jd_type;
      --}
      END IF;
    --}
    ELSE --SUBSTR(l_jurisdiction,1,2) = SUBSTR(l_work_jurisdiction_code,1,2)
    --{
     hr_utility.trace('EMJT CITY:  l_counter not work_jd '|| l_work_jurisdiction_code);

     IF l_jd_hours = 0 AND jurisdiction_codes_tbl_stg(l_counter).jd_type = 'TG' THEN
     --{
        IF jd_codes_tbl_city_stg.EXISTS(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
                                                  SUBSTR(l_jurisdiction,4,3) ||
                                                  SUBSTR(l_jurisdiction,8,4) ))
        THEN
        --{
           hr_utility.trace('EMJT CITY:  This is a Tagged Jurisdiction which is already loaded');
        --}
        ELSE
        --{
           hr_utility.trace('EMJT CITY:  Load Tagged Jurisdiction into jd_codes_tbl_city_stg');
           jd_codes_tbl_city_stg(l_counter).jurisdiction_code := l_jurisdiction;
           jd_codes_tbl_city_stg(l_counter).hours             := l_jd_hours;
           jd_codes_tbl_city_stg(l_counter).jd_type           :=
	                       jurisdiction_codes_tbl_stg(l_counter).jd_type;
        --}
        END IF;
     --}
     ELSE --l_jd_hours = 0 and jd_codes_tbl_city_stg(l_counter).jd_type = 'TG'
       --Fetch City level threshold
       hr_utility.trace('EMJT CITY:  Fetch Threshold Hours for City');
       l_threshold_hours_city := get_jd_level_threshold(p_tax_unit_id
                                                       ,l_jurisdiction
                                                       ,'CITY');
       hr_utility.trace('EMJT CITY:  Threshold Hours for City '||to_char(l_threshold_hours_city));
       IF l_threshold_hours_city > 0 THEN
       --{
          -- Fetch the city level tax balance accrued for the person
          -- If Tax balance found then tax the city as per hours logged for the city
          -- otherwise hours will be accounted to primary work city
          hr_utility.trace('EMJT CITY:  Fetch City level Tax Withheld for Assignment');


      /* Bug#6869097:The following code checks whether city tax is withheld already
         for the assignment and if it finds city tax is withheld already it assumes that
         the assignemnt has crossed the threshold limit already and inserts the
         current record. Commented the following code so that it can go on with
         threshold checking irrespective of city tax Withheld balance.
      */

/*          l_city_withheld :=
	        hr_us_ff_udf1.get_jd_tax_balance(p_threshold_basis     => l_threshold_basis
                                                ,p_assignment_action_id=> p_assignment_action_id
                                                ,p_jurisdiction_code   => l_jurisdiction
                                                ,p_tax_unit_id         => p_tax_unit_id
                                                ,p_jurisdiction_level  => 'CITY'
                                                ,p_effective_date      => p_date_paid
                                                ,p_assignment_id       => p_assignment_id);
         hr_utility.trace('EMJT CITY:  City level Tax Withheld for Assignment '||
	                                                     to_char(l_city_withheld));

--=============================================================================
         IF l_city_withheld = 0 THEN

         l_county_city_withheld :=
	        hr_us_ff_udf1.get_jd_tax_balance(p_threshold_basis     => l_threshold_basis
                                               ,p_assignment_action_id=> p_assignment_action_id
                                               ,p_jurisdiction_code   => l_jurisdiction
                                               ,p_tax_unit_id         => p_tax_unit_id
                                               ,p_jurisdiction_level  => 'COUNTY'
                                               ,p_effective_date      => p_date_paid
					       ,p_assignment_id       => p_assignment_id);
           hr_utility.trace('EMJT: l_county_city_withheld -> '||to_char(l_county_city_withheld));

	   IF l_county_city_withheld = 0 THEN

           l_sit_city_withheld :=
	        hr_us_ff_udf1.get_jd_tax_balance(p_threshold_basis      => l_threshold_basis
                                               ,p_assignment_action_id => p_assignment_action_id
                                               ,p_jurisdiction_code    => l_jurisdiction
                                               ,p_tax_unit_id          => p_tax_unit_id
                                               ,p_jurisdiction_level   => 'STATE'
                                               ,p_effective_date       => p_date_paid
					       ,p_assignment_id        => p_assignment_id);
           hr_utility.trace('EMJT: l_sit_city_withheld -> '||to_char(l_sit_city_withheld));
           END IF;

          END IF;


--=============================================================================
         IF l_city_withheld > 0 THEN
         --{
            hr_utility.trace('EMJT CITY:  As City level Tax is Withheld previously ');
            hr_utility.trace('EMJT CITY:  NO THRESHOLD Validation required for the City');
            jd_codes_tbl_city_stg(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_city_stg(l_counter).hours             := l_jd_hours;
            jd_codes_tbl_city_stg(l_counter).jd_type           :=
                                   jurisdiction_codes_tbl_stg(l_counter).jd_type;
         --}
	 ELSIF l_city_withheld = 0 AND l_county_city_withheld > 0 THEN
         --{
            hr_utility.trace('EMJT CITY:  l_city_withheld = 0 AND l_county_city_withheld > 0 ');
            jd_codes_tbl_city_stg(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_city_stg(l_counter).hours             := l_jd_hours;
            jd_codes_tbl_city_stg(l_counter).jd_type           :=
                                   jurisdiction_codes_tbl_stg(l_counter).jd_type;
         --}
        ELSIF l_city_withheld = 0 AND l_county_city_withheld = 0 AND l_sit_city_withheld > 0 THEN
         --{
            hr_utility.trace('EMJT CITY: l_city_withheld = 0 l_county_city_withheld = 0 l_sit_city_withheld > 0');
            jd_codes_tbl_city_stg(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_city_stg(l_counter).hours             := l_jd_hours;
            jd_codes_tbl_city_stg(l_counter).jd_type           :=
                                   jurisdiction_codes_tbl_stg(l_counter).jd_type;
         --}
	 ELSE --l_city_withheld > 0 */
         --{

   /*Bug#6869097:Changes end here*/

	 -- Fetch Information Hours logged for the person depending on the payroll effective date
	 -- call to get_th_assignment for the CITY
            hr_utility.trace('EMJT CITY:  Fetch Information Hours Logged for the CITY JD');
	    l_city_ih_logged
	       := hr_us_ff_udf1.get_person_it_hours(p_person_id         => l_person_id
	                                           ,p_assignment_id     => p_assignment_id
                                                   ,p_jurisdiction_code => l_jurisdiction
                                                   ,p_jd_level          => 11
                                                   ,p_threshold_basis   => l_threshold_basis
                                                   ,p_effective_date    => l_max_end_date --p_date_paid
		                                   ,p_end_date          => l_end_date);
           hr_utility.trace('EMJT CITY:  Information Hours logged for the assignment '
	                 ||to_char(l_city_ih_logged));
           IF l_city_ih_logged > l_threshold_hours_city THEN
           --{
             hr_utility.trace('EMJT CITY:  City Information Hours logged > Threshold_Hours_City');
             l_ih_excluding_pay_period := l_city_ih_logged
                                        - l_jd_hours;
             hr_utility.trace('EMJT CITY:  City Information Hours till last Pay period'
	                      ||to_char(l_ih_excluding_pay_period));
             -- if information hours processed till last payroll run is greater than the
             -- threshold limit configured at the City level then hours logged for the city
             -- would be accounted for that city
             --
             IF l_ih_excluding_pay_period >= l_threshold_hours_city THEN
             --{
               hr_utility.trace('EMJT CITY:  Information Hours excluding Current Pay Period');
               hr_utility.trace('EMJT CITY:  >= Threshold Hours configured for the city');
               --
               jd_codes_tbl_city_stg(l_counter).jurisdiction_code := l_jurisdiction;
               jd_codes_tbl_city_stg(l_counter).hours             := l_jd_hours;
               jd_codes_tbl_city_stg(l_counter).jd_type           :=
                                   jurisdiction_codes_tbl_stg(l_counter).jd_type;
               hr_utility.trace('EMJT CITY:  Information Hours accounted to logged JD '||l_jurisdiction);
             --}
             ELSE  --l_ih_excluding_pay_period >= l_threshold_hours_city
             --{
             -- if information hours processed till last payroll run is less than the
             -- threshold limit configured at the city level
             -- Calculate information hours that is exceeds threshold limit
               l_ih_above_threshold := l_city_ih_logged - l_threshold_hours_city;
               hr_utility.trace('EMJT CITY:  Information Hours above City Threshold '
	                      ||to_char(l_ih_above_threshold));
             -- Calculate information hours that would be accounted to primary work location
             -- due to threshold
               l_ih_for_primary_wk  :=
	             jurisdiction_codes_tbl_stg(TO_NUMBER(SUBSTR(l_jurisdiction,1,2) ||
                                                          SUBSTR(l_jurisdiction,4,3) ||
			                                  SUBSTR(l_jurisdiction,8,4) )
                                                         ).hours - l_ih_above_threshold;
               hr_utility.trace('EMJT CITY:  Information Hours to be logged for Primar Work '
	                      ||to_char(l_ih_for_primary_wk));
               -- if information hours logged for the city is more than threshold
               -- configured for the city, only exceeded hours would be accounted for that
               -- city
               IF l_ih_above_threshold > 0 THEN
                  jd_codes_tbl_city_stg(l_counter).jurisdiction_code := l_jurisdiction;
                  jd_codes_tbl_city_stg(l_counter).hours := l_ih_above_threshold ;
                  jd_codes_tbl_city_stg(l_counter).jd_type           :=
                                   jurisdiction_codes_tbl_stg(l_counter).jd_type;
                  hr_utility.trace('EMJT CITY:  As Information Hours above Threshold ');
                  hr_utility.trace('EMJT CITY:  Log Hours '||to_char(l_ih_for_primary_wk)
      	                         ||' to JD '||l_jurisdiction);
               END IF;
               -- When Total information hours logged for the person is above threshold
               -- but there are some information hours need to accounted to primary
               -- work location due to threshold limit
               -- This is determine if part of information hours entered for the processing pay
               -- period need to be accounted to primary work location due to
               --
               IF l_ih_for_primary_wk > 0 THEN
               --{
                 IF jd_codes_tbl_city_stg.EXISTS(
                                TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
				          SUBSTR(l_work_jurisdiction_code,4,3) ||
					  SUBSTR(l_work_jurisdiction_code,8,4) ) )
                 THEN
                 --{
                   hr_utility.trace('EMJT CITY:  Hours Added to Primary Work Jurisdiction '
		                  ||to_char(l_ih_for_primary_wk));
                   jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
					            SUBSTR(l_work_jurisdiction_code,8,4) )
                                      ).hours :=
                   jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
					            SUBSTR(l_work_jurisdiction_code,8,4) )
                                      ).hours + l_ih_for_primary_wk ;
                 --}
                 ELSE
                 --{
                   jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
					            SUBSTR(l_work_jurisdiction_code,8,4) )
                                          ).jurisdiction_code
                                          := l_work_jurisdiction_code;
                    jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
			            SUBSTR(l_work_jurisdiction_code,8,4) )).hours
				          := l_ih_for_primary_wk;
                    jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                    SUBSTR(l_work_jurisdiction_code,4,3) ||
			            SUBSTR(l_work_jurisdiction_code,8,4) )).jd_type
				          := jurisdiction_codes_tbl_stg(l_counter).jd_type;
                    hr_utility.trace('EMJT CITY:  Hours logged for Primary Work Jurisdiction '
		                  ||to_char(l_ih_for_primary_wk));

                 --}
	         END IF;
               --}
               END IF; --l_ih_for_primary_wk > 0
             --}
             END IF;
           --}
	   ELSE --l_ih_excluding_pay_period >= l_threshold_hours_state
	   --{
	     -- If Information Hours Logged for the assignment is less than Threshold Hours
	     -- configured for the City, information hours would be accounted to primary work
	     -- State
	     hr_utility.trace('EMJT CITY : l_work_jurisdiction_code ->'|| l_work_jurisdiction_code);
	     hr_utility.trace('EMJT CITY : l_counter ->'|| l_counter);
                IF jd_codes_tbl_city_stg.EXISTS(
                             TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                       SUBSTR(l_work_jurisdiction_code,4,3) ||
                                       SUBSTR(l_work_jurisdiction_code,8,4) ))
                THEN
                --{
                      hr_utility.trace('EMJT CITY : IN IF l_counter ->'|| l_counter);
		      jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                       SUBSTR(l_work_jurisdiction_code,4,3) ||
                                       SUBSTR(l_work_jurisdiction_code,8,4) )).hours :=
                      jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                       SUBSTR(l_work_jurisdiction_code,4,3) ||
                                       SUBSTR(l_work_jurisdiction_code,8,4) )).hours + l_jd_hours ;
                      hr_utility.trace('EMJT CITY:  Hours accounted for Primary WK JD State '
		                        ||to_char(l_jd_hours));
                --}
                ELSE
                --{
                   hr_utility.trace('EMJT CITY : IN ELSE l_counter ->'|| l_counter);
                   jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                   SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                   SUBSTR(l_work_jurisdiction_code,8,4) )
                                          ).jurisdiction_code
                                          := l_work_jurisdiction_code;
                   jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                   SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                   SUBSTR(l_work_jurisdiction_code,8,4) )).hours
				          := l_jd_hours;
                   jd_codes_tbl_city_stg(TO_NUMBER(SUBSTR(l_work_jurisdiction_code,1,2) ||
                                                   SUBSTR(l_work_jurisdiction_code,4,3) ||
                                                   SUBSTR(l_work_jurisdiction_code,8,4) )).jd_type
                                          := 'WK';
                   hr_utility.trace('EMJT CITY:  Primary WK JD City loaded into jd_codes_tbl_city_stg');
                   hr_utility.trace('EMJT CITY:  Hours accounted for Primary WK JD City '
		                        ||to_char(l_jd_hours));
                --}
	        END IF;
	   --}
           END IF; --l_city_ih_logged > l_threshold_hours_city
	 --}
	-- END IF;--l_city_withheld > 0  /*6869097*/
       --}
       ELSE
       --{
	 -- If Threshold Hours not logged for a City load Jurisdiction into jd_codes_tbl_city_stg
	 --
 	    jd_codes_tbl_city_stg(l_counter).jurisdiction_code := l_jurisdiction;
            jd_codes_tbl_city_stg(l_counter).hours             := l_jd_hours;
            jd_codes_tbl_city_stg(l_counter).jd_type           :=
                                   jurisdiction_codes_tbl_stg(l_counter).jd_type;
            hr_utility.trace('EMJT CITY:  Work City JD loaded into jd_codes_tbl_city_stg =>'
	                    ||l_jurisdiction);
       --}
       END IF;--l_threshold_hours_city > 0
      --}
      END IF; --l_jd_hours = 0 and jd_codes_tbl_city_stg(l_counter).jd_type = 'TG'
     --}
     END IF; --SUBSTR(l_jurisdiction,1,2) = SUBSTR(l_work_jurisdiction_code,1,2)
 --}
     hr_utility.trace('EMJT CITY:  Setting the Index counter to fetch next JD City ');
     l_counter := jurisdiction_codes_tbl_stg.NEXT(l_counter);
     hr_utility.trace('EMJT CITY:  Next Index Counter Value '||to_char(l_counter));

 END LOOP;
 --Done with populating the jurisdiction_codes_tbl
 hr_utility.trace('EMJT CITY:  PL Table jd_codes_tbl_city_stg processed Successfully');

--=============================================================================================

   hr_utility.trace('EMJT CITY: Total Informational Time Hours entered -> '||to_char(l_total_hours));
   IF l_total_hours <= l_scheduled_work_hours THEN
      l_denominator := l_scheduled_work_hours;
   ELSIF l_total_hours > l_scheduled_work_hours THEN
      l_denominator := l_total_hours;
   END IF;

   l_counter := NULL;
   l_counter := jd_codes_tbl_city_stg.FIRST;
   l_last_jd_index_value := jd_codes_tbl_city_stg.LAST;
   WHILE l_counter IS NOT NULL LOOP
         l_jd_hours := jd_codes_tbl_city_stg(l_counter).hours ;
         jd_codes_tbl_city_stg(l_counter).percentage :=
                    ROUND((l_jd_hours/l_denominator) * 100);
         hr_utility.trace('EMJT CITY: =========================================================');
         hr_utility.trace('EMJT CITY: jd_codes_tbl_city_stg('||to_char(l_counter)||').hours            ->'
                        || jd_codes_tbl_city_stg(l_counter).hours);
         hr_utility.trace('EMJT CITY: jd_codes_tbl_city_stg('||to_char(l_counter)||').tg_hours         ->'
                        || jd_codes_tbl_city_stg(l_counter).tg_hours);
         hr_utility.trace('EMJT CITY: jd_codes_tbl_city_stg('||to_char(l_counter)||').jurisdiction_code->'
                        || jd_codes_tbl_city_stg(l_counter).jurisdiction_code);
         hr_utility.trace('EMJT CITY: jd_codes_tbl_city_stg('||to_char(l_counter)||').percentage       ->'
                        || jd_codes_tbl_city_stg(l_counter).percentage);
         hr_utility.trace('EMJT CITY: jd_codes_tbl_city_stg('||to_char(l_counter)||').jd_type          ->'
                        || jd_codes_tbl_city_stg(l_counter).jd_type);
         hr_utility.trace('EMJT CITY: =========================================================');
         l_total_percent := l_total_percent
                          + jd_codes_tbl_city_stg(l_counter).percentage;
         l_counter := jd_codes_tbl_city_stg.NEXT(l_counter);
   END LOOP; --WHILE l_counter


   IF l_total_percent > 100 THEN
   --{
      l_extra_percent := l_total_percent - 100;
      IF l_primary_work_jd_flag = 'Y' THEN
         jd_codes_tbl_city_stg(l_primary_work_jd_index_value).percentage
	      := jd_codes_tbl_city_stg(l_primary_work_jd_index_value).percentage
	       - l_extra_percent;
      ELSE
	 jd_codes_tbl_city_stg(l_last_jd_index_value).percentage
	     := jd_codes_tbl_city_stg(l_last_jd_index_value).percentage
	       - l_extra_percent;
      END IF;
   --}
   ELSIF l_total_percent < 100 THEN
   --{
      l_extra_percent := 100 - l_total_percent;
      IF l_primary_work_jd_flag = 'Y' THEN
         jd_codes_tbl_city_stg(l_primary_work_jd_index_value).percentage
            := jd_codes_tbl_city_stg(l_primary_work_jd_index_value).percentage
	    + l_extra_percent;
      ELSE
	 jd_codes_tbl_city_stg(l_last_jd_index_value).percentage
            := jd_codes_tbl_city_stg(l_last_jd_index_value).percentage
	     + l_extra_percent;
      END IF;
   --}
   END IF; --l_total_percent > 100

--========================================================================
   OPEN csr_person_details(p_assignment_id, p_date_paid);
   FETCH csr_person_details INTO l_full_name, l_assignment_number;
   CLOSE csr_person_details;
--========================================================================
 hr_utility.trace('EMJT Full Name -> '|| l_full_name );
 hr_utility.trace('EMJT Assignment Number -> '|| l_assignment_number );
   --
   --Populate jurisdiction_codes_tbl
   --
   l_counter := jd_codes_tbl_city_stg.FIRST;
   WHILE l_counter IS NOT NULL LOOP
      jurisdiction_codes_tbl(l_counter).jurisdiction_code
          := jd_codes_tbl_city_stg(l_counter).jurisdiction_code;
      jurisdiction_codes_tbl(l_counter).percentage
          := jd_codes_tbl_city_stg(l_counter).percentage;
      jurisdiction_codes_tbl(l_counter).jd_type
          := jd_codes_tbl_city_stg(l_counter).jd_type;
      jurisdiction_codes_tbl(l_counter).hours
          := jd_codes_tbl_city_stg(l_counter).hours;
      jurisdiction_codes_tbl(l_counter).wages_to_accrue_flag
          := jd_codes_tbl_city_stg(l_counter).wages_to_accrue_flag;
      jurisdiction_codes_tbl(l_counter).tg_hours
          := jd_codes_tbl_city_stg(l_counter).tg_hours;
      jurisdiction_codes_tbl(l_counter).other_pay_hours
          := jd_codes_tbl_city_stg(l_counter).other_pay_hours;
      hr_utility.trace('EMJT CITY: ===================================================');
      hr_utility.trace('EMJT CITY: jurisdiction_codes_tbl('||to_char(l_counter)||').jurisdiction_code->'
                        || jurisdiction_codes_tbl(l_counter).jurisdiction_code);
      hr_utility.trace('EMJT CITY: jurisdiction_codes_tbl('||to_char(l_counter)||').hours            ->'
                        || jurisdiction_codes_tbl(l_counter).hours);
      hr_utility.trace('EMJT CITY: jurisdiction_codes_tbl('||to_char(l_counter)||').tg_hours         ->'
                        || jurisdiction_codes_tbl(l_counter).tg_hours);
      hr_utility.trace('EMJT CITY: jurisdiction_codes_tbl('||to_char(l_counter)||').percentage       ->'
                        || jurisdiction_codes_tbl(l_counter).percentage);
      hr_utility.trace('EMJT CITY: jurisdiction_codes_tbl('||to_char(l_counter)||').jd_type          ->'
                        || jurisdiction_codes_tbl(l_counter).jd_type);
      hr_utility.trace('EMJT CITY: ===================================================');
--================================================================================================
      l_spelled_jd_code :=
                pay_us_employee_payslip_web.get_full_jurisdiction_name(
		                  jd_codes_tbl_city_stg(l_counter).jurisdiction_code);
      hr_utility.trace('EMJT spelled jd code  -> '|| l_spelled_jd_code );

      pay_core_utils.push_message(801,'PAY_US_EMJT_EMPLOYEE_INFO','P');
      pay_core_utils.push_token('EMPLOYEE_NAME',SUBSTR(l_full_name,1,50));
      pay_core_utils.push_token('ASSIGNMENT_NUMBER',SUBSTR(l_assignment_number,1,50));
      pay_core_utils.push_token('JURISDICTION_NAME',SUBSTR(l_spelled_jd_code,1,50));
      pay_core_utils.push_token('HOURS',SUBSTR(jd_codes_tbl_city_stg(l_counter).hours,1,50));
      pay_core_utils.push_token('PERCENTAGE',SUBSTR(jd_codes_tbl_city_stg(l_counter).percentage,1,50));
--================================================================================================
      l_counter := jd_codes_tbl_city_stg.NEXT(l_counter);
   END LOOP; --WHILE l_counter
   --}
   END IF; --p_initialize = 'Y'
   RETURN ('0');
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       hr_utility.trace('Exception raised NO_DATA_FOUND in '||'get_it_work_jurisdictions');
       p_jurisdiction_code := 'NULL';
       p_percentage := 0;
       RETURN ('0');
  WHEN TOO_MANY_JURISDICTIONS THEN
       hr_utility.set_message(801, 'PAY_75242_PAY_TOO_MANY_JD');
       hr_utility.set_message_token('MAX_WORK_JDS', l_max_jurisdictions);
       hr_utility.raise_error;
       RAISE;
  WHEN OTHERS THEN
       hr_utility.trace('Exception raised OTHERS in '||'get_it_work_jurisdictions');
       hr_utility.trace('Mesg: '||substr(sqlerrm,1,45));
       p_jurisdiction_code := 'NULL';
       p_percentage := 0;
       RETURN ('0');
-- End of Function get_it_work_jurisdictions
--}
END get_it_work_jurisdictions;

--Function to get balance value
FUNCTION get_jd_tax_balance(p_threshold_basis        IN VARCHAR2
                           ,p_assignment_action_id   IN NUMBER
                           ,p_jurisdiction_code      IN VARCHAR2
                           ,p_tax_unit_id            IN NUMBER
                           ,p_jurisdiction_level     IN VARCHAR2
			   ,p_effective_date         IN DATE
			   ,p_assignment_id          IN NUMBER
                           ) RETURN  NUMBER AS

l_value   NUMBER;

    CURSOR csr_defined_balance_id(p_balance_name IN VARCHAR2
                                 ,p_database_item_suffix IN VARCHAR2) IS
    SELECT pdb.defined_balance_id, pbt.balance_type_id
      FROM pay_defined_balances pdb,
           pay_balance_types pbt,
           pay_balance_dimensions pbd
     WHERE pdb.balance_dimension_id = pbd.balance_dimension_id
       AND pdb.balance_type_id      = pbt.balance_type_id
       AND pbt.balance_name         = p_balance_name
       AND pbd.database_item_suffix = p_database_item_suffix
       AND pdb.legislation_code     = 'US';

l_defined_balance_id pay_defined_balances.defined_balance_id%TYPE;
l_balance_type_id    pay_balance_types.balance_type_id%TYPE;
l_state_flag         VARCHAR2(1);
l_state_tax_flag     VARCHAR2(1);
l_county_tax_flag    VARCHAR2(1);
l_city_tax_flag      VARCHAR2(1);

l_jurisdiction_level NUMBER;

BEGIN
  hr_utility.trace('EMJT: ================================================================');
  hr_utility.trace('EMJT: In get_jd_tax_balance');
  hr_utility.trace('EMJT: p_threshold_basis -> '||p_threshold_basis);
  hr_utility.trace('EMJT: p_jurisdiction_level -> '||p_jurisdiction_level);
  hr_utility.trace('EMJT: p_jurisdiction_code -> '||p_jurisdiction_code);
  hr_utility.trace('EMJT: p_tax_unit_id -> '||p_tax_unit_id);
  hr_utility.trace('EMJT: p_assignment_action_id -> '|| p_assignment_action_id);

  l_value := 0;
  l_state_tax_flag  := 'N';
  l_county_tax_flag := 'N';
  l_city_tax_flag   := 'N';

  IF p_jurisdiction_level = 'STATE' THEN

    l_state_tax_flag :=
       pay_get_tax_exists_pkg.get_tax_exists(p_juri_code   => p_jurisdiction_code,
                                             p_date_earned => p_effective_date,
                                             p_tax_unit_id => p_tax_unit_id,
                                             p_assign_id   => p_assignment_id,
                                             p_pact_id     => NULL,
                                             p_type        => 'SIT_WK',
                                             p_call        => 'F');

    hr_utility.trace('EMJT: l_state_tax_flag  -> '|| l_state_tax_flag);
  ELSIF p_jurisdiction_level = 'COUNTY' THEN
    l_county_tax_flag :=
       pay_get_tax_exists_pkg.get_tax_exists(p_juri_code   => p_jurisdiction_code,
                                             p_date_earned => p_effective_date,
                                             p_tax_unit_id => p_tax_unit_id,
                                             p_assign_id   => p_assignment_id,
                                             p_pact_id     => NULL,
                                             p_type        => 'COUNTY_WK',
                                             p_call        => 'F');

    hr_utility.trace('EMJT: l_county_tax_flag  -> '|| l_county_tax_flag);
  ELSIF p_jurisdiction_level ='CITY' THEN
    l_city_tax_flag :=
       pay_get_tax_exists_pkg.get_tax_exists(p_juri_code   => p_jurisdiction_code,
                                             p_date_earned => p_effective_date,
                                             p_tax_unit_id => p_tax_unit_id,
                                             p_assign_id   => p_assignment_id,
                                             p_pact_id     => NULL,
                                             p_type        => 'CITY_WK',
                                             p_call        => 'F');
    hr_utility.trace('EMJT: l_city_tax_flag  -> '|| l_city_tax_flag);
  END IF; --p_jurisdiction_level = 'STATE'


  IF l_state_tax_flag = 'Y' THEN
  --{

    IF p_threshold_basis = 'YTD' THEN
    --{
      hr_utility.trace('EMJT: Getting SIT Withheld for YTD');
      OPEN csr_defined_balance_id('SIT Withheld','_PER_JD_GRE_YTD');
      hr_utility.trace('EMJT: Fetching  SIT Withheld _PER_JD_GRE_YTD ');
      FETCH csr_defined_balance_id INTO l_defined_balance_id,l_balance_type_id;
      CLOSE csr_defined_balance_id;

      hr_utility.trace('EMJT: STATE l_defined_balance_id -> '|| l_defined_balance_id);
      hr_utility.trace('EMJT: STATE l_balance_type_id    -> '|| l_balance_type_id);

      pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
      pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
      pay_balance_pkg.set_context('JURISDICTION_CODE',p_jurisdiction_code);

      l_value :=  NVL(pay_balance_pkg.get_value
                     (p_defined_balance_id => l_defined_balance_id
                     ,p_assignment_action_id => p_assignment_action_id)
                     ,0);

      IF l_value = 0 THEN
      --{
         OPEN csr_defined_balance_id('SIT Supp Withheld','_PER_JD_GRE_YTD');
         hr_utility.trace('EMJT: Fetching  SIT Supp Withheld_PER_JD_GRE_YTD for YTD ');
         FETCH csr_defined_balance_id INTO l_defined_balance_id,l_balance_type_id;
         CLOSE csr_defined_balance_id;
         l_value :=  NVL(pay_balance_pkg.get_value
                         (p_defined_balance_id => l_defined_balance_id
                         ,p_assignment_action_id => p_assignment_action_id)
                         ,0);
      --}
      END IF;
   --}
   ELSIF p_threshold_basis = 'RTD' THEN
   --{

     OPEN csr_defined_balance_id('SIT Withheld','_PER_JD_GRE_RTD');
     hr_utility.trace('EMJT: Fetching  SIT Withheld _PER_JD_GRE_RTD ');
     FETCH csr_defined_balance_id INTO l_defined_balance_id,l_balance_type_id;
     CLOSE csr_defined_balance_id;

      pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
      pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
      pay_balance_pkg.set_context('JURISDICTION_CODE',p_jurisdiction_code);
      l_value :=  NVL(pay_balance_pkg.get_value
                     (p_defined_balance_id => l_defined_balance_id
                     ,p_assignment_action_id => p_assignment_action_id)
                     ,0);

      IF l_value = 0 THEN
      --{
	OPEN csr_defined_balance_id('SIT Supp Withheld','_PER_JD_GRE_RTD');
        hr_utility.trace('EMJT: Fetching  SIT Supp Withheld_PER_JD_GRE_RTD for RTD');
        FETCH csr_defined_balance_id INTO l_defined_balance_id,l_balance_type_id;
        CLOSE csr_defined_balance_id;

        l_value :=  NVL(pay_balance_pkg.get_value
                       (p_defined_balance_id   => l_defined_balance_id
                       ,p_assignment_action_id => p_assignment_action_id)
                       ,0);
      --}
      END IF; --l_value = 0
    --}
    END IF; --p_threshold_basis = 'YTD'
  --}
  END IF; --l_state_tax_flag = 'Y'


  IF l_county_tax_flag = 'Y' THEN
  --{

     IF p_threshold_basis = 'YTD' THEN
     --{
       OPEN csr_defined_balance_id('County Withheld','_PER_JD_GRE_YTD');
       hr_utility.trace('EMJT: Fetching  County Withheld_PER_JD_GRE_YTD ');
       FETCH csr_defined_balance_id INTO l_defined_balance_id,l_balance_type_id;
       CLOSE csr_defined_balance_id;

       hr_utility.trace('EMJT: COUNTY l_defined_balance_id -> '|| l_defined_balance_id);
       hr_utility.trace('EMJT: COUNTY l_balance_type_id    -> '|| l_balance_type_id);

       pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
       pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
       pay_balance_pkg.set_context('JURISDICTION_CODE',p_jurisdiction_code);
       hr_utility.trace('EMJT: p_threshold_basis = YTD');
       l_value :=  NVL(pay_balance_pkg.get_value
                      (p_defined_balance_id => l_defined_balance_id
                      ,p_assignment_action_id => p_assignment_action_id)
                      ,0);

     --}
     ELSIF p_threshold_basis = 'RTD' THEN
     --{
        hr_utility.trace('EMJT COUNTY: p_threshold_basis = RTD');
       OPEN csr_defined_balance_id('County Withheld','_PER_JD_GRE_RTD');
       hr_utility.trace('EMJT: Fetching  County Withheld_PER_JD_GRE_RTD ');
       FETCH csr_defined_balance_id INTO l_defined_balance_id,l_balance_type_id;
       CLOSE csr_defined_balance_id;

       hr_utility.trace('EMJT: COUNTY l_defined_balance_id -> '|| l_defined_balance_id);
       hr_utility.trace('EMJT: COUNTY l_balance_type_id    -> '|| l_balance_type_id);

       pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
       pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
       pay_balance_pkg.set_context('JURISDICTION_CODE',p_jurisdiction_code);
       l_value :=  NVL(pay_balance_pkg.get_value
                      (p_defined_balance_id => l_defined_balance_id
                      ,p_assignment_action_id => p_assignment_action_id)
                      ,0);
     --}
     END IF; --p_threshold_basis = 'YTD'

  --}
  END IF; --l_county_tax_flag = 'Y'

  IF l_city_tax_flag = 'Y' THEN
  --{

     IF p_threshold_basis = 'YTD' THEN
     --{
        hr_utility.trace('EMJT CITY: p_threshold_basis = YTD');
        OPEN csr_defined_balance_id('City Withheld','_PER_JD_GRE_YTD');
        hr_utility.trace('EMJT : Fetching City Withheld_PER_JD_GRE_YTD');
        FETCH csr_defined_balance_id INTO l_defined_balance_id,l_balance_type_id;
        CLOSE csr_defined_balance_id;

        hr_utility.trace('EMJT: CITY l_defined_balance_id -> '|| l_defined_balance_id);
        hr_utility.trace('EMJT: CITY l_balance_type_id    -> '|| l_balance_type_id);

        pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
        pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
        pay_balance_pkg.set_context('JURISDICTION_CODE',p_jurisdiction_code);

        l_value :=  NVL(pay_balance_pkg.get_value
                       (p_defined_balance_id => l_defined_balance_id
                       ,p_assignment_action_id => p_assignment_action_id)
                       ,0);

      --}
      ELSIF p_threshold_basis = 'RTD' THEN
      --{
         hr_utility.trace('EMJT CITY : p_threshold_basis = RTD');

         OPEN csr_defined_balance_id('City Withheld','_PER_JD_GRE_RTD');
         hr_utility.trace('EMJT CITY: Fetching City Withheld_PER_JD_GRE_RTD');
         FETCH csr_defined_balance_id INTO l_defined_balance_id,l_balance_type_id;
         CLOSE csr_defined_balance_id;

	 hr_utility.trace('EMJT: CITY RTD l_defined_balance_id -> '|| l_defined_balance_id);
         hr_utility.trace('EMJT: CITY RTD l_balance_type_id    -> '|| l_balance_type_id);

         pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
         pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
         pay_balance_pkg.set_context('JURISDICTION_CODE',p_jurisdiction_code);

         l_value :=  NVL(pay_balance_pkg.get_value
                        (p_defined_balance_id => l_defined_balance_id
                        ,p_assignment_action_id => p_assignment_action_id)
                        ,0);

      --}
      END IF; --p_threshold_basis = 'YTD'
  --}
  END IF; --l_city_tax_flag = 'Y'

  hr_utility.trace('EMJT: l_value from get_jd_tax_balance ->'|| to_char(l_value));
  hr_utility.trace('EMJT: ================================================================');
  RETURN l_value;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Exception handler');
    hr_utility.trace('SQLCODE = ' || SQLCODE);
    hr_utility.trace('SQLERRM = ' || SUBSTR(SQLERRM,1,80));
    hr_utility.trace('EMJT: Exception OTHERS in get_jd_tax_balance, returning 0');
    RETURN 0;
END get_jd_tax_balance;


--Function to get IT threshold hours for a given Jurisdiction
FUNCTION get_jd_level_threshold(p_tax_unit_id       NUMBER
                               ,p_jurisdiction_code VARCHAR2
                               ,p_jd_level          VARCHAR2) RETURN NUMBER AS

     --Threshold hours at state level
     CURSOR csr_state_rules(p_tax_unit_id IN NUMBER
                           ,p_state_code IN VARCHAR2) IS
    SELECT  NVL(org_information2,0)
      FROM  hr_organization_information hoi,
            pay_us_states pus
     WHERE  hoi.organization_id = p_tax_unit_id
       AND  hoi.org_information_context = 'State Tax Rules 2'
       AND  hoi.org_information1 = pus.state_abbrev
       AND  pus.state_code  = p_state_code;

     --Threshold hours at Local level
     CURSOR csr_local_rules(p_tax_unit_id IN NUMBER
                           ,p_jurisdiction_code IN VARCHAR2) IS
    SELECT  NVL(org_information4,0)
      FROM  hr_organization_information
     WHERE  organization_id = p_tax_unit_id
       AND  org_information_context = 'Local Tax Rules'
       AND  org_information1 = p_jurisdiction_code;

       l_state_threshold VARCHAR2(10);
       l_local_threshold VARCHAR2(10);

BEGIN

   hr_utility.trace('EMJT: ================================================================');
   hr_utility.trace('EMJT: In get_jd_level_threshold');
   IF p_jd_level = 'STATE' THEN
      OPEN csr_state_rules(p_tax_unit_id,
                           SUBSTR(p_jurisdiction_code,1,2));
      FETCH csr_state_rules INTO l_state_threshold;
      CLOSE csr_state_rules;
      hr_utility.trace('EMJT: SUBSTR(p_jurisdiction_code,1,2) -> ' || SUBSTR(p_jurisdiction_code,1,2));
      hr_utility.trace('EMJT: l_state_threshold from get_jd_level_threshold -> '
                                                    || l_state_threshold);
      hr_utility.trace('EMJT: ================================================================');
      RETURN TO_NUMBER(l_state_threshold);

   ELSIF p_jd_level = 'COUNTY' THEN
      OPEN csr_local_rules(p_tax_unit_id,
                           substr(p_jurisdiction_code,1,7)||'0000'
			  );
      FETCH csr_local_rules INTO l_local_threshold;
      CLOSE csr_local_rules;
      hr_utility.trace('EMJT: substr(p_jurisdiction_code,1,7)||''0000'' -> ' || substr(p_jurisdiction_code,1,7)||'0000');
      hr_utility.trace('EMJT: l_county_threshold from get_jd_level_threshold -> '
                                                    || NVL(l_local_threshold,0));

      IF NVL(l_local_threshold,0) = 0 THEN
        OPEN csr_state_rules(p_tax_unit_id, SUBSTR(p_jurisdiction_code,1,2));
        FETCH csr_state_rules INTO l_state_threshold;
        CLOSE csr_state_rules;
        hr_utility.trace('EMJT: l_state_threshold from get_jd_level_threshold -> '
                                                    || l_state_threshold);
	hr_utility.trace('EMJT: ================================================================');
        RETURN TO_NUMBER(NVL(l_state_threshold,0));
      ELSE
        RETURN TO_NUMBER(NVL(l_local_threshold,0));
      END IF;


   ELSIF p_jd_level = 'CITY' THEN
      OPEN csr_local_rules(p_tax_unit_id,
                           p_jurisdiction_code);
      FETCH csr_local_rules INTO l_local_threshold;
      CLOSE csr_local_rules;
      hr_utility.trace('EMJT: p_jurisdiction_code -> ' || p_jurisdiction_code);
      hr_utility.trace('EMJT: l_local_threshold from get_jd_level_threshold -> '
                                     || NVL(l_local_threshold,0));
      hr_utility.trace('EMJT: ================================================');
      IF NVL(l_local_threshold,0) = 0 THEN
        OPEN csr_state_rules(p_tax_unit_id, SUBSTR(p_jurisdiction_code,1,2));
        FETCH csr_state_rules INTO l_state_threshold;
        CLOSE csr_state_rules;
        hr_utility.trace('EMJT: l_state_threshold from get_jd_level_threshold -> '
                                                    || l_state_threshold);
	hr_utility.trace('EMJT: ================================================================');
        RETURN TO_NUMBER(NVL(l_state_threshold,0));
      ELSE
        RETURN TO_NUMBER(NVL(l_local_threshold,0));
      END IF;

   END IF;
EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace('EMJT: Exception OTHERS in get_jd_level_threshold, returning 0');
   RETURN 0;
END get_jd_level_threshold;

--Function to get Informational Hours logged by the assignment for
--each jurisdiction code in the pl table.
FUNCTION get_person_it_hours(p_person_id            IN NUMBER
                            ,p_assignment_id        IN NUMBER
                            ,p_jurisdiction_code    IN VARCHAR2
                            ,p_jd_level             IN VARCHAR2 --2,6,11
			    ,p_threshold_basis      IN VARCHAR2 --YTD,RTD
			    ,p_effective_date       IN DATE
			    ,p_end_date             IN DATE) RETURN NUMBER AS

     -- Cursor to get all the informational time element entries
     -- Jurisdiction Code and Hours screen entry values are retrieved
     -- All element entries are considered based on the start date and end date.
     -- Hours are summed for each jurisdiction.
     -- pev1.screen_entry_value      Jurisdiction,
	CURSOR  csr_element_entries(p_start_date     IN DATE,
	                            p_end_date       IN DATE,
				    p_person_id      IN NUMBER,
                                    p_assignment_id  IN NUMBER,
                                    p_effective_date IN DATE,
                                    p_jurisdiction_code IN VARCHAR2,
                                    p_jd_level       IN NUMBER) IS
        SELECT  SUM(pev2.screen_entry_value) Hours
         FROM   pay_element_entry_values_f   pev1,
                pay_element_entry_values_f   pev2,
                pay_element_entries_f        pee,
                pay_element_links_f          pel,
                pay_element_types_f          pet,
                pay_input_values_f           piv1,
                pay_input_values_f           piv2,
                pay_element_type_extra_info  extra,
		per_assignments_f            paf
        WHERE   extra.information_type     = 'PAY_US_INFORMATION_TIME'
          AND   extra.eei_information1     = 'Y'
          AND   extra.element_type_id      = pet.element_type_id
          AND   pet.element_type_id        = pel.element_type_id
          AND   pee.effective_start_date   BETWEEN pet.effective_start_date
                                               AND pet.effective_end_date
          AND   pel.element_link_id        = pee.element_link_id
          AND   pee.effective_start_date   BETWEEN pel.effective_start_date
                                               AND pel.effective_end_date
          AND   pee.effective_start_date   BETWEEN p_start_date
	                                       AND p_end_date
          AND   paf.assignment_id          =  pee.assignment_id
          AND   pee.effective_start_date   BETWEEN paf.effective_start_date
                                               AND paf.effective_end_date
          AND   paf.person_id              =  p_person_id
	  AND   pee.element_entry_id       = pev1.element_entry_id
          AND   pee.effective_start_date   BETWEEN pee.effective_start_date
                                               AND pee.effective_end_date
          AND   pev1.input_value_id        = piv1.input_value_id
          AND   pee.effective_start_date   BETWEEN pev1.effective_start_date
                                               AND pev1.effective_end_date
          AND   piv1.name                  = 'Jurisdiction'
          AND   pee.effective_start_date   BETWEEN piv1.effective_start_date
                                               AND piv1.effective_end_date
          AND   pee.element_entry_id       = pev2.element_entry_id
          AND   pee.effective_start_date   BETWEEN pee.effective_start_date
                                               AND pee.effective_end_date
          AND   pev2.input_value_id        = piv2.input_value_id
          AND   piv2.name                  = 'Hours'
          AND   pee.effective_start_date   BETWEEN piv2.effective_start_date
                                               AND piv2.effective_end_date
          AND   SUBSTR(pev1.screen_entry_value,1,p_jd_level)
                                           = SUBSTR(p_jurisdiction_code,1,p_jd_level);

l_start_date DATE;
l_end_date   DATE;
l_hours      NUMBER;

BEGIN
    hr_utility.trace('EMJT: ================================================================');
    hr_utility.trace('EMJT: In get_person_it_hours');
    hr_utility.trace('EMJT: Jurisdiction Code       -> '||p_jurisdiction_code);
    hr_utility.trace('EMJT: Threshold Basis         -> '||p_threshold_basis);
    hr_utility.trace('EMJT: Jurisdiction Level      -> '||p_jd_level);
    hr_utility.trace('EMJT: Payroll Effective Date  -> '||to_char(p_effective_date,'DD-MON-YYYY'));
    hr_utility.trace('EMJT: Payroll Period End Date -> '||to_char(p_end_date,'DD-MON-YYYY'));

    --p_effective_date - pay_payroll_actions.effective_date;
    --p_date_earned    - pay_payroll_actions.date_earned;

    IF p_threshold_basis = 'YTD' THEN
       l_start_date := TRUNC(p_effective_date,'Y');
       l_end_date   := p_effective_date;
    ELSIF p_threshold_basis = 'RTD' THEN
       l_start_date := ADD_MONTHS(p_end_date, -12);
       l_end_date   := p_end_date;
    END IF;

    hr_utility.trace('EMJT: p_effective_date -> '|| p_effective_date );
    hr_utility.trace('EMJT: l_start_date     -> '|| l_start_date );
    hr_utility.trace('EMJT: l_end_date       -> '|| l_end_date );

    OPEN csr_element_entries(l_start_date
			    ,l_end_date
			    ,p_person_id
                            ,p_assignment_id
                            ,p_effective_date
                            ,p_jurisdiction_code
                            ,p_jd_level );

    FETCH csr_element_entries INTO l_hours;
    CLOSE csr_element_entries;

    hr_utility.trace('EMJT: l_hours -> '|| to_char(l_hours ) );
    hr_utility.trace('EMJT: ========================================================');

    RETURN l_hours;

END get_person_it_hours;
--
-- This function would be used for fetching percentage to be used STATE and
-- COUNTY level percentage to be used for distributing wages over different
-- jurisdictions when assignment is configured to process information hours
--
FUNCTION get_it_jd_percent(p_jurisdiction_code               VARCHAR2  -- parameter
                          ,p_jd_level                        VARCHAR2  -- parameter
                          ,p_hours_to_accumulate  OUT nocopy NUMBER    -- parameter
                          ,p_wages_to_accrue_flag OUT nocopy VARCHAR2  -- parameter
                          )
RETURN NUMBER
IS
  l_jd_level    number;
  l_pad         number;
  l_entry_jd    number;
  l_temp_jd     number;
  l_percentage  number;
  l_return      number;
BEGIN
--{
   hr_utility.trace('EMJT: ================================================================');
   hr_utility.trace('EMJT: IN get_it_jd_percent ') ;
--
-- This flag is set to Y when assignment is configured to process information
-- hours for deriving the percentage of wages to be distributed over various
-- jurisidictions person worked during the payroll period
--
      hr_utility.trace('EMJT: get_it_jd_percent Jurisdiction Level = ' || p_jd_level) ;
      hr_utility.trace('EMJT: get_it_jd_percent Jurisdiction Code  = ' || p_jurisdiction_code) ;
      IF p_jd_level = 'COUNTY' THEN
         l_jd_level := 5;
      ELSIF p_jd_level = 'STATE' THEN
         l_jd_level := 2;
      END IF;

      IF SUBSTR(p_jurisdiction_code,1,1) = 0 THEN
         l_pad := 8;
         l_jd_level := l_jd_level - 1;
      ELSE
         l_pad := 9;
      END IF;

      hr_utility.trace('EMJT: get_it_jd_percent l_pad      = ' || to_char(l_pad)) ;
      hr_utility.trace('EMJT: get_it_jd_percent l_jd_level = ' || to_char(l_jd_level)) ;

      l_entry_jd := TO_NUMBER(SUBSTR(p_jurisdiction_code,1,2) ||
                              SUBSTR(p_jurisdiction_code,4,3) ||
                              SUBSTR(p_jurisdiction_code,8,4) );

      l_temp_jd  := RPAD(SUBSTR(l_entry_jd,1,l_jd_level),l_pad,0);

      hr_utility.trace('EMJT: get_it_jd_percent l_temp_jd = ' || to_char(l_temp_jd)) ;

    --Fetch the percentage stored for the State
    --
    IF p_jd_level = 'STATE' THEN
    --{
        IF jd_codes_tbl_state.EXISTS(TO_NUMBER(l_temp_jd))
        THEN
          l_percentage := jd_codes_tbl_state(TO_NUMBER(l_temp_jd)).percentage;
        ELSE
           l_percentage := 0;
        END IF;
    --} end of p_jd_level = 'STATE'
    ELSIF p_jd_level = 'COUNTY' THEN
    --{
        IF jd_codes_tbl_county.EXISTS(TO_NUMBER(l_temp_jd))
        THEN
           l_percentage := jd_codes_tbl_county(TO_NUMBER(l_temp_jd)).percentage;
        ELSE
           l_percentage := 0;
        END IF;
    --}end of p_jd_level = 'COUNTY'
    /*Bug#6598477 begins*/
     ELSIF p_jd_level = 'CITY' THEN
    --{
        IF jurisdiction_codes_tbl.EXISTS(TO_NUMBER(l_temp_jd))
        THEN
           l_percentage := jurisdiction_codes_tbl(TO_NUMBER(l_temp_jd)).percentage;
        ELSE
           l_percentage := 0;
        END IF;
       --}end of p_jd_level = 'CITY'
    /*Bug#6598477 ends*/
    END IF;
    hr_utility.trace('EMJT: get_it_jd_percent Percentage Derived for Jurisdiction = '
                                                     || to_char(l_percentage)) ;
    -- Dummy values assigned to the OUT variables
    p_hours_to_accumulate  := 0;
    p_wages_to_accrue_flag := 'AIHW';
    --
    -- Percentage returned based on the jurisidction level and jurisdiction code passed
    --
    hr_utility.trace('EMJT: l_percentage from get_it_jd_percent ->'|| to_char(l_percentage));
    hr_utility.trace('EMJT: ================================================================');
    RETURN l_percentage;
EXCEPTION
     WHEN OTHERS THEN
          hr_utility.trace('EMJT: Exception OTHERS in get_it_jd_percent, returning 0');
          RETURN 0;
--}
END get_it_jd_percent;

function across_calendar_years(p_payroll_action_id  in number)
return varchar2 is

 l_date_earned     date;
 l_date_paid       date;
 l_check_years     varchar2(1);

 cursor csr_get_dates is
 select effective_date,
        date_earned
 from pay_payroll_actions
 where payroll_action_id = p_payroll_action_id;

begin

  open csr_get_dates;
  fetch csr_get_dates
  into l_date_paid,
       l_date_earned;
  close csr_get_dates;

  if to_char(l_date_paid,'YYYY') = to_char(l_date_earned,'YYYY') then
    l_check_years := 'N';
  else
    l_check_years := 'Y';
  end if;

  return l_check_years;

end across_calendar_years;


FUNCTION get_work_state (p_jurisdiction_code  in varchar2)
RETURN varchar2 IS

l_exists         varchar2(2);
i                number;
BEGIN
  l_exists := 'N';

  IF jurisdiction_codes_tbl.COUNT > 0 THEN

     i := jurisdiction_codes_tbl.FIRST;  -- get subscript of first element
     WHILE i IS NOT NULL LOOP

        hr_utility.trace('plsql table='||substr(jurisdiction_codes_tbl(i).jurisdiction_code,1,2));
        IF p_jurisdiction_code = substr(jurisdiction_codes_tbl(i).jurisdiction_code,1,2)
        THEN
           l_exists := 'Y';
           EXIT;
        END IF;

        i := jurisdiction_codes_tbl.NEXT(i);  -- get subscript of next element
     END LOOP;

  END IF;

  RETURN l_exists;

END get_work_state;

--Function to return the SUI Wage Limits.
FUNCTION get_jit_data(p_jurisdiction_code IN VARCHAR2
                     ,p_date_earned       IN DATE
		     ,p_jit_type          IN VARCHAR2)
RETURN NUMBER IS

CURSOR csr_sui_er_wage_limit(p_jurisdiction_code IN VARCHAR2,p_date_earned IN DATE) IS
SELECT NVL(sui_er_wage_limit,0)
FROM   pay_us_state_tax_info_f
WHERE  state_code = SUBSTR(p_jurisdiction_code,1,2)
AND    p_date_earned BETWEEN effective_start_date AND effective_end_date;

l_sui_er_wage_limit pay_us_state_tax_info_f.sui_er_wage_limit%TYPE;

CURSOR csr_sui_ee_wage_limit(p_jurisdiction_code IN VARCHAR2,p_date_earned IN DATE) IS
SELECT NVL(sui_ee_wage_limit,0)
FROM   pay_us_state_tax_info_f
WHERE  state_code = SUBSTR(p_jurisdiction_code,1,2)
AND    p_date_earned BETWEEN effective_start_date AND effective_end_date;

l_sui_ee_wage_limit pay_us_state_tax_info_f.sui_ee_wage_limit%TYPE;

CURSOR csr_supp_calc_method(p_jurisdiction_code IN VARCHAR2,p_date_earned IN DATE) IS
SELECT NVL(sta_information18,' ')
FROM   pay_us_state_tax_info_f
WHERE  state_code = SUBSTR(p_jurisdiction_code,1,2)
AND    p_date_earned BETWEEN effective_start_date AND effective_end_date;

l_supp_calc_meth pay_us_state_tax_info_f.sta_information18%TYPE;

l_return_value NUMBER;

BEGIN

hr_utility.trace('hr_us_ff_udf1.get_jit_date');
hr_utility.trace('p_jurisdiction_code --> '|| p_jurisdiction_code);
hr_utility.trace('p_date_earned --> '|| p_date_earned);
hr_utility.trace('p_jit_type --> '|| p_jit_type);

IF p_jit_type = 'SUI_ER_WAGE_LIMIT' THEN
   OPEN csr_sui_er_wage_limit(p_jurisdiction_code,p_date_earned);
   FETCH csr_sui_er_wage_limit INTO l_sui_er_wage_limit;
   CLOSE csr_sui_er_wage_limit;
   l_return_value := l_sui_er_wage_limit;
   hr_utility.trace('l_sui_er_wage_limit  --> '|| l_sui_er_wage_limit);

END IF; /* SUI_ER_WAGE_LIMIT */

IF p_jit_type = 'SUI_EE_WAGE_LIMIT' THEN

   OPEN csr_sui_ee_wage_limit(p_jurisdiction_code,p_date_earned);
   FETCH csr_sui_ee_wage_limit INTO l_sui_ee_wage_limit;
   CLOSE csr_sui_ee_wage_limit;
   l_return_value := l_sui_ee_wage_limit;
   hr_utility.trace('l_sui_ee_wage_limit  --> '|| l_sui_ee_wage_limit);

END IF; /* SUI_EE_WAGE_LIMIT */

IF p_jit_type = 'DEFAULT_SUPP_CALC_METH' THEN

  OPEN csr_supp_calc_method(p_jurisdiction_code,p_date_earned);
  FETCH csr_supp_calc_method INTO l_supp_calc_meth;
  CLOSE csr_supp_calc_method;
  l_return_value := l_supp_calc_meth;
  hr_utility.trace('DEFAULT_SUPP_CALC_METH  --> '|| l_supp_calc_meth);
END IF; /* DEFAULT_SUPP_CALC_METH */

hr_utility.trace('l_return_value  --> '|| l_return_value);
RETURN l_return_value;

END get_jit_data;

FUNCTION  get_rs_jd (p_assignment_id  IN  NUMBER,
                     p_date_earned     IN DATE)
RETURN VARCHAR2 IS

CURSOR c_override_jd (p_assignment_id IN NUMBER,p_date_earned IN DATE) IS
SELECT puc.state_code || '-' || puc.county_code || '-' ||pucty.city_code
FROM   pay_us_counties puc,
       pay_us_states pus,
       pay_us_city_names pucty,
       per_addresses pa,
       per_assignments_f paf
WHERE  paf.assignment_id = p_assignment_id
AND    paf.person_id     = pa.person_id
AND    p_date_earned BETWEEN paf.effective_start_date AND paf.effective_end_date
AND    paf.primary_flag = 'Y'
AND    paf.assignment_type = 'E'
AND    pa.primary_flag   = 'Y'
AND    pa.country = 'US'
AND    pa.style = 'US'
AND    TO_DATE('01-01-'||TO_CHAR(p_date_earned,'YYYY'), 'DD-MM-YYYY') BETWEEN
       pa.date_from AND NVL(pa.date_to,to_date('31-12-4712','DD-MM-YYYY'))
AND    pus.state_abbrev  = pa.add_information17 --override state
AND    puc.state_code    = pus.state_code
AND    puc.county_name   = pa.add_information19 --Override County
AND    pucty.state_code  = pus.state_code
AND    pucty.county_code = puc.county_code
AND    pucty.city_name   = pa.add_information18; -- Override City.


CURSOR c_jd (p_assignment_id IN NUMBER,p_date_earned IN DATE) IS
SELECT puc.state_code || '-' || puc.county_code || '-' ||pucty.city_code
FROM   pay_us_counties puc,
       pay_us_states pus,
       pay_us_city_names pucty,
       per_addresses pa,
       per_assignments_f paf
WHERE  paf.assignment_id = p_assignment_id
AND    paf.person_id     = pa.person_id
AND    p_date_earned BETWEEN paf.effective_start_date AND paf.effective_end_date
AND    paf.primary_flag = 'Y'
AND    paf.assignment_type = 'E'
AND    pa.primary_flag   = 'Y'
AND    pa.country = 'US'
AND    pa.style = 'US'
AND    TO_DATE('01-01-'||TO_CHAR(p_date_earned,'YYYY'), 'DD-MM-YYYY') BETWEEN
       pa.date_from AND NVL(pa.date_to,to_date('31-12-4712','DD-MM-YYYY'))
AND    pus.state_abbrev  = pa.region_2 --Regular state
AND    puc.state_code    = pus.state_code
AND    puc.county_name   = pa.region_1 --Regular County
AND    pucty.state_code  = pus.state_code
AND    pucty.county_code = puc.county_code
AND    pucty.city_name   = pa.town_or_city; -- Regular City.


l_rs_jd VARCHAR2(200);

BEGIN

OPEN c_override_jd(p_assignment_id,p_date_earned);
FETCH c_override_jd  INTO l_rs_jd;
IF c_override_jd%NOTFOUND THEN

   OPEN c_jd(p_assignment_id,p_date_earned);
   FETCH c_jd INTO l_rs_jd;
   IF c_jd%NOTFOUND THEN
      l_rs_jd := NULL;
   END IF;
   CLOSE c_jd;

END IF;
CLOSE c_override_jd;

hr_utility.trace('hr_us_ff_udf1.get_rs_jd');
--hr_utility.trace('p_jurisdiction_code --> '|| p_jurisdiction_code);
hr_utility.trace('p_date_earned --> '|| p_date_earned);
--hr_utility.trace('p_jit_type --> '|| p_jit_type);

hr_utility.trace('l_rs_jd --> '|| l_rs_jd );
--dbms_output.put_line('l_rs_jd --> '|| l_rs_jd);

RETURN l_rs_jd;


END get_rs_jd;

FUNCTION  get_wk_jd(p_assignment_id    IN NUMBER,
                    p_date_earned      IN DATE,
                    p_jurisdiction_code IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_override_wk_jd (p_assignment_id IN NUMBER,
                         p_date_earned IN DATE,
                         p_jurisdiction_code IN VARCHAR2) IS
SELECT puc.state_code || '-' || puc.county_code || '-' ||pucty.city_code
FROM   pay_us_counties puc,
       pay_us_states pus,
       pay_us_city_names pucty,
       hr_locations hl,
       per_assignments_f paf
WHERE paf.assignment_id = p_assignment_id
AND   TO_DATE('01-01-'||TO_CHAR(p_date_earned,'YYYY'), 'DD-MM-YYYY') BETWEEN
      paf.effective_start_date AND paf.effective_end_date
AND   paf.location_id = hl.location_id
AND   hl.loc_information17 = pus.state_abbrev --override state
AND   puc.state_code = pus.state_code
AND   hl.loc_information19 = puc.county_name --override county
AND   puc.state_code = SUBSTR(p_jurisdiction_code, 1, 2)
AND   puc.county_code  = SUBSTR(p_jurisdiction_code, 4, 3)
AND   hl.loc_information18 = pucty.city_name --override city
AND   pucty.state_code = SUBSTR(p_jurisdiction_code, 1, 2)
AND   pucty.county_code  = SUBSTR(p_jurisdiction_code, 4, 3)
AND   pucty.city_code  = SUBSTR(p_jurisdiction_code, 8, 4);

CURSOR c_reg_wk_jd (p_assignment_id IN NUMBER,
                         p_date_earned IN DATE,
                         p_jurisdiction_code IN VARCHAR2) IS
SELECT puc.state_code || '-' || puc.county_code || '-' ||pucty.city_code
FROM   pay_us_counties puc,
       pay_us_states pus,
       pay_us_city_names pucty,
       hr_locations hl,
       per_assignments_f paf
WHERE paf.assignment_id = p_assignment_id
AND   TO_DATE('01-01-'||TO_CHAR(p_date_earned,'YYYY'), 'DD-MM-YYYY') BETWEEN
      paf.effective_start_date AND paf.effective_end_date
AND   paf.location_id = hl.location_id
AND   hl.region_2 = pus.state_abbrev --reg state
AND   puc.state_code = pus.state_code
AND   hl.region_1 = puc.county_name --reg county
AND   puc.state_code = SUBSTR(p_jurisdiction_code, 1, 2)
AND   puc.county_code  = SUBSTR(p_jurisdiction_code, 4, 3)
AND   hl.town_or_city = pucty.city_name --reg city
AND   pucty.state_code = SUBSTR(p_jurisdiction_code, 1, 2)
AND   pucty.county_code  = SUBSTR(p_jurisdiction_code, 4, 3)
AND   pucty.city_code  = SUBSTR(p_jurisdiction_code, 8, 4);

l_wk_jd VARCHAR2(200);

BEGIN


OPEN c_override_wk_jd (p_assignment_id,p_date_earned,p_jurisdiction_code);
FETCH c_override_wk_jd INTO l_wk_jd;
IF c_override_wk_jd%NOTFOUND THEN
   OPEN c_reg_wk_jd(p_assignment_id,p_date_earned,p_jurisdiction_code);
   FETCH c_reg_wk_jd INTO l_wk_jd;
   IF c_reg_wk_jd%NOTFOUND THEN
      l_wk_jd := NULL;
   END IF;
   CLOSE c_reg_wk_jd;
END IF;
CLOSE c_override_wk_jd;


hr_utility.trace('hr_us_ff_udf1.get_wk_jd');
hr_utility.trace('p_jurisdiction_code --> '|| p_jurisdiction_code);
hr_utility.trace('p_date_earned --> '|| p_date_earned);
--hr_utility.trace('p_jit_type --> '|| p_jit_type);

hr_utility.trace('l_wk_jd --> '|| l_wk_jd );

--dbms_output.put_line('l_wk_jd --> '|| l_wk_jd);

RETURN l_wk_jd;

END get_wk_jd;


/*Function created for Bug 5972214
 This function is used to check for a given Colorado Jurisdiction, the Head
 tax can be deducted or not.
 For the city with Head tax to be able to collect Head(OPT) tax it needs
 to satisfy these conditions
 1)The current payperiod must be the last one of the present month
 2)The city should have the maximum time percentage of all the Colorado
 jurisdictions in which the Employee works
 3)If two jurisdictions are with same percentage, then primary is given
 priority if it is one of them.If none of them are primary,pick one of them
 which is based on the order in which the same percentage jurisdictions
 present in the pl/sql table.This table order is employed to make sure
 only one city is selected to collect head tax.
 4)For a payroll with duration less than a month, use of Date Paid in different
 month will cause Head Tax to be skipped in some cases.A warning message
 will be thrown in the Concurrent Request Log file for such assignments
 with Assignment ID,Assignment Number,Jurisdiction code to help customer to
 do Balance adjustment for skipped assignments.
*/
FUNCTION coloradocity_ht_collectornot(
                 p_assignment_id              NUMBER,
                 p_date_earned                DATE,
		 p_payroll_action_id          NUMBER,
                 p_jurisdiction_code          VARCHAR2,
                 p_prim_jurisdiction_code     VARCHAR2,
		 p_monthly_gross              NUMBER )
  RETURN NUMBER
IS

l_max_jd_code   VARCHAR2(11); --Jurisdiction for City with maximum percentage
l_max_percent   NUMBER(3); --Maximum Percentage
l_max_jd_code1   VARCHAR2(11); --Jurisdiction for City with maximum percentage
l_max_percent1   NUMBER(3); --Maximum Percentage
l_collect_ht    NUMBER(1); -- Flag to decide Head Tax to be collected or not
l_counter         NUMBER(1);
l_pay_period_start_date DATE;
l_pay_period_end_date DATE;
l_payroll_id NUMBER(9);
l_date DATE;
l_nearest_end_date DATE;
l_date_paid DATE;

-- Get start and end dates of the pay period for the given date_earned
CURSOR csr_get_period_dates IS
select ptp.start_date,
       ptp.end_date,
       ptp.payroll_id
  from per_all_assignments_f paaf,
       pay_all_payrolls_f papf,
       per_time_periods ptp
 where paaf.payroll_id = papf.payroll_id
   and papf.payroll_id = ptp.payroll_id
   and assignment_id   = p_assignment_id
   and p_date_earned between ptp.start_date
                         and ptp.end_date
   and p_date_earned between papf.effective_start_date
                         and papf.effective_end_date
   and p_date_earned between paaf.effective_start_date
                         and paaf.effective_end_date;

--Cursor to fetch nearest pay period to the WC effective date
CURSOR CSR_GET_NEAREST_PERIOD IS
  select max(end_date)
    from per_time_periods
   where payroll_id = l_payroll_id
     and end_date <= l_date;

--Cursor to fetch the average percentage of employee's time in each of
--his Colorado work Jurisdictions.The cursor fetches the jurisdictions
--in the descending order of its percentage,in ascending order of
--Jurisdictions for those with same percentage
CURSOR JURISDICTION_PERCENTAGE IS
  select jurisdiction_code,
         round(sum(percentage*days)/(last_day(p_date_earned)-trunc(p_date_earned,'MONTH')+1),2) percentage
    from
      ( select pev1.element_entry_id,
               pev1.screen_entry_value    Jurisdiction_code,
               pev2.screen_entry_value    Percentage,
               least(last_day(p_date_earned),pee.effective_end_date)
               -greatest(pee.effective_start_date,trunc(p_date_earned,'MONTH') )+1  days
        from   pay_element_entry_values_f pev1,
               pay_element_entry_values_f pev2,
               pay_element_entries_f pee,
               pay_element_links_f pel,
               pay_element_types_f pet,
               pay_input_values_f piv1,
               pay_input_values_f piv2
        where  pee.assignment_id        =  p_assignment_id
          and  pee.effective_start_date<=last_day(p_date_earned)
          and pee.effective_end_date>=trunc(p_date_earned,'MONTH')
          and  pee.element_link_id      = pel.element_link_id
          and  pee.effective_start_date between pel.effective_start_date
                                            and pel.effective_end_date
          and  pel.element_type_id      = pet.element_type_id
          and  pet.element_name         = 'VERTEX'
          and  pee.effective_start_date between  pet.effective_start_date
                                            and pet.effective_end_date
          and  pee.element_entry_id     = pev1.element_entry_id
          and  pee.effective_start_date between  pev1.effective_start_date
                                            and pev1.effective_end_date
          and  pev1.input_value_id      = piv1.input_value_id
          and  pee.effective_start_date between  piv1.effective_start_date
                                            and piv1.effective_end_date
          and  piv1.name                = 'Jurisdiction'
          and  pee.element_entry_id     = pev2.element_entry_id
          and  pee.effective_start_date between pev2.effective_start_date
                                            and pev2.effective_end_date
          and  pev2.input_value_id      = piv2.input_value_id
          and  pee.effective_start_date between  piv2.effective_start_date
                                            and piv2.effective_end_date
          and  piv2.name                = 'Percentage'
          and  pev1.screen_entry_value in ('06-001-0030','06-005-0030',
					   '06-035-0030','06-005-0870',
					   '06-031-0140','06-005-0450',
					   '06-005-0850'))
 group by jurisdiction_code order by percentage desc,jurisdiction_code;

-- Get the Date Paid for the current run
CURSOR csr_get_date_paid IS
select effective_date
  from pay_payroll_actions
 where payroll_action_id = p_payroll_action_id;

--To print the Warning message for an assignment whose possible Head Tax
--might not be withheld due to Date Paid in different month than that of
--Date Earned.
PROCEDURE print_warning(p_pay_period_end_date  DATE,
                         p_date_paid           DATE,
                         p_assignment_id      NUMBER,
			 p_payroll_id         NUMBER,
			 p_jurisdiction_code  VARCHAR2,
			 p_monthly_gross         NUMBER)
IS

CURSOR get_number_periods_per_year IS
SELECT number_per_fiscal_year
  FROM per_time_period_types pttt,
       pay_all_payrolls_f papf
 WHERE pttt.period_type=papf.period_type
   AND papf.payroll_id=p_payroll_id;

CURSOR get_assignment_number IS
SELECT assignment_number
  FROM per_all_assignments_f
 WHERE assignment_id=p_assignment_id;

l_num_periods_per_year per_time_period_types.number_per_fiscal_year%TYPE;
l_assignment_number per_all_assignments_f.assignment_number%TYPE;
l_ht_deducted NUMBER;

BEGIN


  OPEN get_number_periods_per_year;
  FETCH get_number_periods_per_year INTO l_num_periods_per_year;

  OPEN get_assignment_number;
  FETCH get_assignment_number INTO l_assignment_number;

  l_ht_deducted :=0;

  /*To ensure warning will not be thrown if Head Tax gets deducted
  with current earnings alone */

  IF ((p_jurisdiction_code = '06-001-0030') OR  /* Aurora */
      (p_jurisdiction_code = '06-005-0030') OR  /* Aurora */
      (p_jurisdiction_code = '06-035-0030') OR  /* Aurora */
      (p_jurisdiction_code = '06-005-0870') )  /* Greenwood Village */
  THEN

    IF p_monthly_gross >= 250
    THEN
       l_ht_deducted :=1;
    END IF;

  ELSIF ((p_jurisdiction_code = '06-031-0140') or /* Denver */
         (p_jurisdiction_code = '06-005-0450') ) /* Sheridan */
  THEN

    IF p_monthly_gross >= 500
    THEN
       l_ht_deducted :=1;
    END IF;

  ELSE /*Glendale*/

    IF p_monthly_gross >= 750
    THEN
       l_ht_deducted :=1;
    END IF;

  END IF;

/*Warning shown only if Payperiod duration is less than Month */
  IF TRUNC(p_pay_period_end_date,'MONTH')<>TRUNC(p_date_paid,'MONTH')
    AND l_num_periods_per_year > 12 AND l_ht_deducted = 0
  THEN
     fnd_file.put_line(FND_FILE.LOG,'WARNING: For Assignment with Assignment ID '||
        TO_CHAR(p_assignment_id)||' Assignment Number '||TO_CHAR(l_assignment_number)||
        ' Head Tax is not withheld for Jurisdiction '||p_jurisdiction_code||' as Date Paid'||
	' Paid and Date Earned are in different months.');
  END IF;

  CLOSE get_number_periods_per_year;
  CLOSE get_assignment_number;

END print_warning;

BEGIN

hr_utility.trace('IN coloradocity_ht_collectornot');
hr_utility.trace('p_assignment_id: ' || to_char(p_assignment_id));
hr_utility.trace('p_date_earned: ' || to_char(p_date_earned));
hr_utility.trace('Current Jurisdiction'||p_jurisdiction_code);
hr_utility.trace('Primary Work Jurisdiction of the Assignment'||
                                              p_prim_jurisdiction_code);

l_collect_ht :=0;

/*Check if the current payperiod is last payperiod of the month*/

/*Get the Start date and End date of Current Payperiod using the Date Earned*/
 OPEN csr_get_period_dates;
 FETCH csr_get_period_dates INTO
                l_pay_period_start_date,l_pay_period_end_date,l_payroll_id;
 IF csr_get_period_dates%NOTFOUND THEN
  hr_utility.trace('Pay period for the given date_earned is NOT found');
  CLOSE csr_get_period_dates;
  return (l_collect_ht);
 END IF;

/*Get the Last day of the month in which current payperiod is present*/
l_date := last_day(l_pay_period_end_date);

/*Get the nearest pay period end date to the Last of the month */
OPEN CSR_GET_NEAREST_PERIOD;
 FETCH CSR_GET_NEAREST_PERIOD INTO  l_nearest_end_date;
 IF CSR_GET_NEAREST_PERIOD%NOTFOUND THEN
  hr_utility.trace('Nearest Pay period for the given date_earned is NOT found');
  CLOSE CSR_GET_NEAREST_PERIOD;
  CLOSE csr_get_period_dates;
  return (l_collect_ht);
END IF;

/*To check if a null value is returned for nearest pay period enddate of month*/
IF l_nearest_end_date IS NULL
THEN
  hr_utility.trace('Null value returned for nearest payperiod end date');
  hr_utility.trace('So returning '||to_char(l_collect_ht));
  return(l_collect_ht);
END IF;

/*To check if the current payperiod is the last payperiod of the month*/
if ( l_nearest_end_date <> l_pay_period_end_date ) then
     hr_utility.trace('Present Payperiod is not the lastone of the month');
     hr_utility.trace('So returning '||to_char(l_collect_ht));
     return(l_collect_ht);
 end if;

/* Get the Date Paid for the current run */
OPEN CSR_GET_DATE_PAID;
 FETCH CSR_GET_DATE_PAID INTO l_date_paid;
CLOSE CSR_GET_DATE_PAID;

/*Get the Jurisdiction with maximum percentage*/
OPEN jurisdiction_percentage;
FETCH jurisdiction_percentage INTO l_max_jd_code,l_max_percent;

/*Check if the current jurisdiction has maximum percentage*/
/*Return 0 if the current jurisdiction does not have maximum
percentage and the maximum jurisdiction code is greater than
current jurisdiction*/

IF l_max_jd_code <> p_jurisdiction_code
  AND least(p_jurisdiction_code,l_max_jd_code)=p_jurisdiction_code
THEN
    hr_utility.trace('To collect Head Tax for Colorado or not'||to_char(l_collect_ht));
    RETURN l_collect_ht;
END IF;

/*Return 1 if the current jurisdiction has maximum
percentage and it is the primary work jurisdiction*/

IF l_max_jd_code = p_jurisdiction_code
  AND p_jurisdiction_code = p_prim_jurisdiction_code
THEN
  print_warning(l_pay_period_end_date,l_date_paid,p_assignment_id,l_payroll_id,p_jurisdiction_code,p_monthly_gross);
  l_collect_ht :=1;
  hr_utility.trace('To collect Head Tax for Colorado or not'||to_char(l_collect_ht));
  RETURN l_collect_ht;
END IF;

l_counter :=0;
WHILE l_counter IS NOT NULL
LOOP

  FETCH jurisdiction_percentage INTO l_max_jd_code1,l_max_percent1;

  IF jurisdiction_percentage%FOUND AND l_max_percent1 = l_max_percent THEN

  /*Return 1 only for primary work jurisdiction if multiple jurisdictions have
   same high percentage as primary.For others return 0*/

   IF l_max_jd_code1 = p_prim_jurisdiction_code THEN
     IF p_jurisdiction_code = p_prim_jurisdiction_code THEN
      CLOSE jurisdiction_percentage;
      print_warning(l_pay_period_end_date,l_date_paid,p_assignment_id,l_payroll_id,p_jurisdiction_code,p_monthly_gross);
      l_collect_ht :=1;
      hr_utility.trace('To collect Head Tax for Colorado or not'||to_char(l_collect_ht));
      RETURN l_collect_ht;
     ELSE
      CLOSE jurisdiction_percentage;
      hr_utility.trace('To collect Head Tax for Colorado or not'||to_char(l_collect_ht));
      RETURN l_collect_ht;
     END IF;
   END IF;

  ELSE

    l_counter := NULL;

  END IF;

END LOOP;

CLOSE jurisdiction_percentage;

IF l_max_jd_code = p_jurisdiction_code THEN
   print_warning(l_pay_period_end_date,l_date_paid,p_assignment_id,l_payroll_id,p_jurisdiction_code,p_monthly_gross);
   l_collect_ht := 1;
   hr_utility.trace('To collect Head Tax for Colorado or not'||to_char(l_collect_ht));
   RETURN l_collect_ht;
END IF;
hr_utility.trace('To collect Head Tax for Colorado or not'||to_char(l_collect_ht));
RETURN l_collect_ht;

END coloradocity_ht_collectornot;

END hr_us_ff_udf1;

/
