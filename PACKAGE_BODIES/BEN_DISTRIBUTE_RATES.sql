--------------------------------------------------------
--  DDL for Package Body BEN_DISTRIBUTE_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DISTRIBUTE_RATES" as
/* $Header: bendisrt.pkb 120.10.12010000.5 2010/02/04 11:55:10 sallumwa ship $ */
/*
--------------------------------------------------------------------------------
Name

Purpose


History
   Date        Who        Version   What?
   ----        ---        -------   -----
   23 Sep 98   maagrawa   115.0     Created.
   04 Nov 98   maagrawa   115.1     If activity period is yearly(PYR),
                                    then don't calculate no_of_periods
                                    in annual_to_period and
                                    period_to_annual functions.
   18 Jan 99   G Perry    115.3     LED V ED
   09 Apr 99   mhoyes     115.4     get_balance/c_pil
   28 Sep 99   lmcdonal   115.5     Added Compare_Balances,
                                    Prorate_min_max procedures.
                                    Add PP to get_periods_between.
                                    Change get_periods_between from
                                    rounding to 1 decimal point to
                                    truncating the value.
                                    Add payroll_id to annual_to_period
                                    and period_to_annual.
   02 Oct 99   lmcdonal   115.6     Fixed bugs in Compare_Balances,
                                    Prorate_min_max
   12 Oct 99   tguy       115.7     fixed bug 3637.  get_periods_between
                                    was returning wrong number of periods
   12-Nov-99   lmcdonal   115.8     Better debugging messages.
   14-Nov-99   pbodla     115.9     acty_base_rt is added as context to
                                    rule : prort_mn_ann_elcn_val_rl,
                                           prort_mx_ann_elcn_val_rl,
   17-Nov-99   pbodla     115.10    acty_base_rt is passed to
                                    ben_determine_date.main, This is
                                    applicable only for ecr.
   19-Nov-99   pbodla     115.11    p_elig_per_elctbl_chc_id is passed to
                                    formula.
   10-Dec-99   lmcdonal   115.12    In prorate_min_max, if input vals are
                                    null, do not perform proration.
                                    And in compare_balances, if p_ann_mn_val
                                    is null, do not load with 0.
   14-Mar-00   maagrawa   115.13    Modified the balance calculation process
                                    to also estimate balances, if required.
                                    Number of pay periods now calculated based
                                    on regular_payment_date rather than the
                                    period start and end date.(1237278).
   05-Apr-00   mmogel     115.14    Added tokens to message calls to make the
                                    messages more meaningful to the user
   21-Apr-00   jcarpent   115.15    Pass more args to ben_distribute_rates
                                    (1205931,4600)
   03-May-00   gperry     115.16    Added rounding logic to period_to_annual
                                    and annual_to_period. Fixes internal bug
                                    5148.
   28-Jun-00   shdas      115.17    set cmplt yr flag  based on det_pl_ytd_cntrs_cd
   29-Jun-00   mhoyes     115.18  - Bypassed calculations in annual_to_period and
                                    period_to_annual when amount is null.
   10-Aug-00   gperry     115.19    Fixed WWBUG 1309417.
                                    Only include time periods that are valid
                                    for the period in question.
   22 Sep 00   mhoyes     115.20  - Added function caching for period_to_annual and
                                    annual_to_period functions.
   25 Sep 00   mhoyes     115.21  - Removed dbms_outputs.
   23 Oct 00   kmahendr   115.22  - Corrected message_name for message_number 91824
                                    Bug#1471114
   07 Nov 00   mhoyes     115.23  - Added set_no_cache_context to turn caching off.
                                  - Referenced electable choice context global.
   03 jan 01   tilak      115.24  - p_end_dt parameter added get_balanc
   20 feb 01   kmahendr   115.25  - Bug#1628706 - check date is the criteria for
                                    computing no. of pay periods if it is not null
                                    -cursor in get_periods_between changed after
                                    going thro Bug#1309417 and 1237278 - also modified
                                    parameter value for opening cursor parse_period
   17-May-01   maagrawa   115.26  - Performance changes.
                                    Call hr_elements.check_element_freq only
                                    if the rule exists.
   29-Aug-01   pbodla     115.27  - bug:1949361 jurisdiction code is
                                    derived inside benutils.formula
   18-Sep-01   kmahendr   115.28  - bug-1996066-where clause in cursors c_parse_periods and
                                    c_count_periods changed to take end_date in place of
                                    regular_payment_date
   11-Nov-01   tmathers   115.29  - Test harness for get_periods between
                                    completed with no differnces.
   01-Dec-01   tmathers   115.30  - Fixed compliance error.
   27-Dec-01   ikasire    115.31    Bug 2151055 fixes to set_default_dates if the Coverage/rate
                                    starts in next calender year
   28-Dec-01   ikasire    115.32    Bug 2151055 more changes to get_periods_between not to return
                                    0 periods in case last month/pay period of the Year when
                                    complete year flag is N. This is for SAREC case
   31-Dec-01   ikasire    115.33    Bug 2164741 Wrong calculation of communication amount
                                    in subsequent enrollments because of using the
                                    cvg start date of epe
   21-Apr-02   ashrivas   115.34    Added convert_rates_w for self-service
   23-May-02   kmahendr   115.35    Added a procedure - annual_to_period_out
   23 May 02   kmahendr   115.36    No changes
   03 Jun 02   pabodla	  115.37    Bug 2367556 : Changed STANDARD.bitand to just bitand
   08-Jun-02   pabodla    115.38    Do not select the contingent worker
                                    assignment when assignment data is
                                    fetched.
   04-Sep-02   kmahendr   115.39    added codes in get_periods_between for new acty_ref_perd_cd.
   15-Oct-02   kmahendr   115.40    Added overloaded function - get_periods_between and parameter
                                    to annual_to_period - Bug#2556948
   07-jan-03   vsethi     115.41    No copy changes
   09-jan-03   kmahendr   115.42    Bug#2734491-Child rate is treated as parent- codes added in
                                    annual to period
   16-an-03    kmullapu   115.43    Bug 2745691. Added convert_pcr_rates_w
   23-Jan-03   ikasire    115.45    Bug 2149438 Added overloaded funcrtions for
                                    period_to_annual and annual_to_period to handle the
                                    rounding externally.
   13-feb-02   vsethi     115.31    Enclosed all hr_utility debug calls inside if
   17-Mar-03   kmullapu   115.47    Bug 2745691:modified convert_pcr_rates_w to set
                                   p_use_balance_flag:='Y'  only when parent rate is SAREC or SAAEAR
   26-Jun-03   lakrish    115.48    Bug 2992321, made ann_rt_val parameters
                                    as IN OUT in convert_pcr_rates_w
   12-Sep-03   rpillay    115.49    GRADE/STEP : Changes to set_default_dates to not throw error
                                    for G mode when year periods are not set up.
   26-Sep-03   rpillay    115.50    GRADE/STEP : Check for Grade Step program instead of
                                    looking for 'G' mode
   21-Oct-03   ikasire    115.51    BUG 3191928 fixes if the year period used it not right.
   22-Oct-03   ikasire    115.52    BUG 3191928 fixed the typo order of select clause list
   28-Oct-03   ikasire    115.53    BUG 3159774 c_count_periods_chq modified.see comments in the code
   31-Oct-03   kmahendr   115.54    Bug#3231548 - added additional parameter to get_periods
                                    between
   31-oct-03   kmahendr   115.55    Bug#3231548 - the condition added to another tot-periods
   28-jan-03   ikasire    115.56    Bug#3394862 - The estimate_balance procedure is calling
                                    get_periods_between with the new payroll_id for determining
                                    old periods in a different payroll. We need to use the one
                                    on element entries with a nvl getting from the p_payroll_id
                                    parameter.
   10-Feb-03   ikasire    115.57    Bug 3430334. Search with tag 3430334 for more details.
   12-Feb-03   ikasire    115.59    reverted the changes made in 115.58 until futher review by PM
                                    not to get into some other patch before we complete the
                                    review and testing.
   26-Apr-04   kmahendr   115.60    Bug#3510633 - Added parameter person_id to function
                                    annual_to_period
   21-Jun-04   bmanyam    115.62    Bug# 3704632 - Added NVL() to p_end_date parameter
                                    in the cursot to find number_of_periods in function get_periods_between().
   22-Jun-04   bmanyam    115.63    Bug# 3704632 - Removed the above change. Added
                                    select clause to fetch end-date of pay-year from per_time_periods
                                    for 'Calender Month' and 'Lunar Month'
  29-Nov-04    kmahendr   115.64    Codes added for new Rate Start date
  03-Dec-04    vvprabhu   115.65    Bug 3980063 SSBEN Trace Enhancement
  21-Dec-04    kmahendr   115.66    Bug#4037102 - nvl used to pass start date
  27-Apr-05    swjain       115.67   Bug#4290565 Modified procedure prorate_min_max
  25-Jul-05    kmahendr   115.68    Bug#4504449 - changed IYYY to YYYY in add_months
  27-Jul-05    kmahendr   115.69    Bug#4504449 - l_periods defaulted to 1 in the
                                    case of element with frequency rule in
                                    get_periods_between
  21-Mar-06    vborkar    115.70    5104247 Added p_child_rt_flag parameters to
                                    convert_pcr_rates_w procedure.
  27-Mar-06    kmahendr   115.71    Bug#5077258 - nvl added to return 0 for
                                    balance if null in get_balance func
  16-Aug-06    vborkar    115.72    5460638 For enterable rate, adjusted the defined rate(upto .01)
                                    when it falls outside min-max window due to rounding error.
  15-Nov-05    bmanyam    115.74    5642552 For Annual Rates, annual_to_period, the pay_period_amt
                                    should be evaluated from pay_period_start NOT yr_start_dt.
  20-Feb-07    rtagarra   115.75    ICM Changes
  04-Dec-07    krupani    115.76    Incorporated changes of secure views and Bug 6455096 from branchline to mainline
  12-Aug-08    ubhat      120.11    Forward port bug fix Bug 6830210:
  14-Aug-08    veparame   120.12    For FwdPort of Bug 6913654: Modified get_periods_function to return correct number of periods.
                                    Modified period_to_annual function to calculate correct annual rates for
				    'Estimate Only' rates
  09-aug-08    bachakra   115.80    Bug 7314120: changed cursor c_count_periods_chq in second get_periods_between
                                    function.
  15-sep-08    sallumwa   115.81    Bug 7196470 : Logic to fetch communicated amount from the ben_enrt_rt table
                                    has been removed.
  14-Apr-09    sallumwa   115.82    Bug 7395779 : Number of Pay periods are calculated based on the check date
                                    and not the rate start date when annual min max proration is done.
  27-Jan-10    sallumwa   115.83    Bug 9309878 : Modified the logic to evaluate the l_yr_start_dt which
                                    inturn evaluates the balance amount.
-- ==========================================================================================================
*/
--
--
g_package varchar2(80) := 'ben_distribute_rates';
--
g_hash_key number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
-- Function cache stuff
--
type g_period_to_annual_row is record
  (amount                 number
  ,enrt_rt_id             number
  ,elig_per_elctbl_chc_id number
  ,acty_ref_perd_cd       varchar2(30)
  ,business_group_id      number
  ,effective_date         date
  ,lf_evt_ocrd_dt         date
  ,complete_year_flag     varchar2(30)
  ,use_balance_flag       varchar2(30)
  ,start_date             date
  ,end_date               date
  ,payroll_id             number
  ,element_type_id        number
  ,annual_amt             number
  );
--
type g_period_to_annual_tbl is table of g_period_to_annual_row
  index by binary_integer;
--
type g_annual_to_period_row is record
  (amount                 number
  ,enrt_rt_id             number
  ,elig_per_elctbl_chc_id number
  ,acty_ref_perd_cd       varchar2(30)
  ,business_group_id      number
  ,effective_date         date
  ,lf_evt_ocrd_dt         date
  ,complete_year_flag     varchar2(30)
  ,use_balance_flag       varchar2(30)
  ,start_date             date
  ,end_date               date
  ,payroll_id             number
  ,element_type_id        number
  ,period_amt             number
  ,pp_in_yr_used_num      number
  );
--
type g_annual_to_period_tbl is table of g_annual_to_period_row
  index by binary_integer;
--
type g_element_pay_freq_periods is record
(element_type_id number
,payroll_id      number
,start_date      date
,end_date        date
,num_periods     number);
--
type g_element_pay_freq_periods_tbl is table of g_element_pay_freq_periods
  index by binary_integer;
--
g_period_to_annual_cache  g_period_to_annual_tbl;
g_period_to_annual_cached pls_integer := 0;
--
g_annual_to_period_cache  g_annual_to_period_tbl;
g_annual_to_period_cached pls_integer := 0;
--
g_element_pay_freq_perd_cache g_element_pay_freq_periods_tbl;
g_element_pay_freq_perd_cached pls_integer := 0;
--
g_debug boolean := hr_utility.debug_enabled;
--
---------------------------------------------------------------------------
-- GEVITY
-- This procedure returns the defined, communicated and annual amounts.
-- This uses a fast formula and user is completely responsible for returning
-- the right values
-- Scope of function: Call from external procedures allowed.
---------------------------------------------------------------------------
PROCEDURE periodize_with_rule
            (p_formula_id             in number,
             p_effective_date         in date,
             p_assignment_id          in number,
             p_convert_from_val       in number,
             p_convert_from           in varchar2,
             p_elig_per_elctbl_chc_id in number,
             p_acty_base_rt_id        in number,
             p_business_group_id      in number,
             p_enrt_rt_id             in number default null,
             p_ann_val                out nocopy number,
             p_cmcd_val               out nocopy number,
             p_val                    out nocopy number  ) IS
  --
  l_package varchar2(80) := g_package || '.periodize_with_rule';
  --
  l_outputs                 ff_exec.outputs_t;
  l_ann_val                 number;
  l_cmcd_val                number;
  l_val                number;
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering '||l_package, 10);
    hr_utility.set_location(' p_convert_from_val '||p_convert_from_val,10);
  end if;
  --
  --
  IF p_convert_from_val IS NOT NULL THEN
    --
    l_outputs := benutils.formula
      (p_formula_id       => p_formula_id,
       p_effective_date   => p_effective_date,
       p_assignment_id    => p_assignment_id,
       p_business_group_id=> p_business_group_id,
       p_param1           => 'BEN_IV_CONVERT_FROM',
       p_param1_value     => p_convert_from,
       p_param2           => 'BEN_IV_CONVERT_FROM_VAL',
       p_param2_value     => to_char(p_convert_from_val),
       p_param3           => 'BEN_ABR_IV_ACTY_BASE_RT_ID',
       p_param3_value     => to_char(p_acty_base_rt_id),
       p_param4           => 'BEN_EPE_IV_ELIG_PER_ELCTBL_CHC_ID',
       p_param4_value     => to_char(p_elig_per_elctbl_chc_id),
       p_param5           => 'BEN_ECR_IV_ENRT_RT_ID',
       p_param5_value     => to_char(p_enrt_rt_id)
      );
  --
  hr_utility.set_location('Done with Formula',10);
  --
  -- Loop through the returned table and make sure that the returned
  -- values have been found
  --
  for l_count in l_outputs.first..l_outputs.last loop
      --
      begin
        --
        if l_outputs(l_count).name = 'DFND_VAL' then
          --
          l_val := l_outputs(l_count).value;
          --
        elsif l_outputs(l_count).name = 'CMCD_VAL' then
          --
          l_cmcd_val := l_outputs(l_count).value;
          --
        elsif l_outputs(l_count).name = 'ANN_VAL' then
          --
          l_ann_val := l_outputs(l_count).value;
          --
        else
          --
          -- Account for cases where formula returns an unknown
          -- variable name
          hr_utility.set_location('In the Loop  wrong Name ',10);
          --
          fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM');
          fnd_message.set_token('PROC',l_package);
          fnd_message.set_token('FORMULA',p_formula_id);
          fnd_message.set_token('PARAMETER',l_outputs(l_count).name);
          fnd_message.raise_error;
          --
        end if;
        --
      exception when others then
        --
        hr_utility.set_location('BEN_92311_FORMULA_VAL_PARAM ',10);
        --
        fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
        fnd_message.set_token('PROC',l_package);
        fnd_message.set_token('FORMULA',p_formula_id);
        fnd_message.set_token('PARAMETER',l_outputs(l_count).name);
        fnd_message.raise_error;
        --
      end;
  end loop ;
  ELSE
    --
    if g_debug then
      hr_utility.set_location('p_convert_from_val IS NULL returning NULLS',10);
    end if;
    --
    l_val      := NULL;
    l_cmcd_val := NULL;
    l_ann_val  := NULL;
    --
  END IF;
  --
  p_val      := l_val;
  p_cmcd_val := l_cmcd_val;
  p_ann_val  := l_ann_val;
  if g_debug then
    hr_utility.set_location('Defined Amount '||p_val,110);
    hr_utility.set_location('Cmcd Amount    '||p_cmcd_val,110);
    hr_utility.set_location('Ann Amount     '||p_ann_val,110);
    hr_utility.set_location('Leaving '||l_package, 20);
  end if;
  --
END periodize_with_rule ;
---------------------------------------------------------------------------

-- Scope of function: Call from external procedures allowed.
---------------------------------------------------------------------------
function get_periods_between(
                            p_acty_ref_perd_cd in varchar2,
                            p_start_date       in date,
                            p_end_date         in date default null,
                            p_payroll_id       in number default null,
                            p_business_group_id in number default null,
                            p_element_type_id  in number default null,
                            p_enrt_rt_id       in number default null,
                            p_effective_date   in date   default null,
                            p_called_from_est  in boolean
                            ) return number is
   l_package varchar2(80) := g_package || '.get_periods_between';

   cursor c_get_element_type_id is
     select element_type_id
     from   ben_enrt_rt ert,
            ben_acty_base_rt_f abr
     where  ert.enrt_rt_id=p_enrt_rt_id and
            ert.business_group_id=p_business_group_id and
            abr.acty_base_rt_id=ert.acty_base_rt_id and
            p_effective_date between
              abr.effective_start_date and abr.effective_end_date;
   --
   l_element_type_id number;
   --
   cursor c_element_rule_exists is
      select  'Y'
      from    pay_ele_payroll_freq_rules   epf
      where   epf.element_type_id          = l_element_type_id
      and     epf.payroll_id               = p_payroll_id
      and     epf.business_group_id        = p_business_group_id;
   --
   l_element_rule_exists varchar2(1) := 'N';
   --
   -- Parse Periods gets the information about the
   -- number of pay_periods by start date
   -- for the rate.
   --
   cursor c_parse_periods1(v_payroll_id in number,
                          v_start_date in date,
                          v_end_date   in date) is
	select ptp.start_date,
               ptp.end_date
	from   per_time_periods ptp
	where  ptp.payroll_id     = v_payroll_id
          and  ptp.end_date between
               v_start_date and v_end_date;
   --
cursor get_period_type(p_payroll_id IN NUMBER
                      ,p_date IN DATE) is
select period_type
from   pay_all_payrolls_f
where  payroll_id = p_payroll_id
and    p_date between effective_start_date
and    effective_end_date;

--
l_period_type VARCHAR2(30);
--
cursor pay_freq_rule_exists(p_payroll_id IN NUMBER
                    ,p_element_type_id IN NUMBER) is
select sum(power(2,(FRP.period_no_in_reset_period) - 1))
,decode(epf.reset_period_type,'Year','YYYY','MM')
from   pay_ele_payroll_freq_rules EPF
,      pay_freq_rule_periods FRP
where  FRP.ele_payroll_freq_rule_id = EPF.ele_payroll_freq_rule_id
and    EPF.payroll_id               = p_payroll_id
and    EPF.element_type_id          = p_element_type_id
group  by epf.ele_payroll_freq_rule_id ,epf.reset_period_type;
--
 cursor parse_periods(p_payroll_id IN NUMBER
                    ,p_rt_start IN DATE
                    ,p_eoy IN DATE
                    ,p_reset IN VARCHAR2
                    ,p_frq_bitmap_no IN NUMBER) is
select sum(
ben_distribute_rates.decde_bits(
bitand(power(2,count(end_date )) -1,p_frq_bitmap_no)
))
from per_time_periods
where payroll_id = p_payroll_id
and   --end_date -- Bug 6830210
      regular_payment_date -- Bug 6830210
      between p_rt_start
      and     p_eoy
group by to_char(end_date,p_reset)
;

   cursor c_count_periods(v_payroll_id in number,
                          v_start_date in date,
                          v_end_date   in date) is
        select count(1)
        from   per_time_periods ptp
        where  ptp.payroll_id     = v_payroll_id
   --     and    nvl(ptp.regular_payment_date,ptp.end_date) between
        and    ptp.end_date between
               v_start_date and v_end_date;
 --       and    nvl(ptp.regular_payment_date,ptp.end_date) >= v_start_date;
   --
   l_periods   number := null;
   l_start_date  date;
   l_end_date  date;
   l_date      date;
   l_fortnight_end_date date;
   l_temp      varchar2(1);
   l_tot_perd  number := 0;
   l_skip_element varchar2(30);
   l_pay_freq_bitmap_no NUMBER;
   l_reset  VARCHAR2(30):= 'MM';
   l_pay_annualization_factor number ;
   l_max_end_date DATE;

begin
   --
   g_debug := hr_utility.debug_enabled;
   --
   if g_debug then
     hr_utility.set_location('Entering '||l_package, 10);
   end if;
   --
   hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_acty_ref_perd_cd',
                             p_argument_value => p_acty_ref_perd_cd);
   --
   hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_start_date',
                             p_argument_value => p_start_date);

   --
   if g_debug then
     hr_utility.set_location('p_acty_ref_perd_cd '||p_acty_ref_perd_cd,20);
     hr_utility.set_location('p_start_date '||to_char(p_start_date),30);
     hr_utility.set_location('p_end_date '||to_char(p_end_date),40);
   end if;
   --
   if p_end_date is null then
      --
      -- End of the year (of the start date)
      --
      l_end_date := add_months(trunc(p_start_date,'YYYY'),12);
      --
   else
      --
      -- Start Date should be less than end date.
      --
      if p_end_date < p_start_date then
         --
         fnd_message.set_name('BEN','BEN_91824_START_DT_AFTR_END_DT');
         fnd_message.set_token('PROC',l_package);
         fnd_message.set_token('START_DT',to_char(p_start_date));
         fnd_message.set_token('END_DT',to_char(p_end_date));
         fnd_message.raise_error;
         --
      else
         --
         --  need to add 1 day to correctly calc time between 2 dates.
         --  because we are truncating down we get the correct answer.
         --  ie months_between(1/1/99,12/31/99) = 11.999999999
         --  by adding 1 day to the end date we get the correct answer
         --  of 12
         --
         l_end_date := p_end_date + 1;
         --
      end if;
      --
   end if;
   --
   if g_debug then
     hr_utility.set_location(l_package,50);
   end if;
   --
   if p_acty_ref_perd_cd = 'PWK' then
      --
      -- Weekly
      --
      l_periods := trunc(((l_end_date - p_start_date)/7),0);
      --
   elsif p_acty_ref_perd_cd = 'PHR' then
     --
     l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
     if l_pay_annualization_factor is null then
       l_pay_annualization_factor := 2080;
     end if;
     --
     l_periods := trunc(((l_end_date - p_start_date)/365 * l_pay_annualization_factor),0);
     --
   elsif p_acty_ref_perd_cd = 'PP' or p_acty_ref_perd_cd = 'EPP'
          or p_acty_ref_perd_cd = 'PPF' then
      --
      -- Pay Period
      --
      hr_utility.set_location('Inside PP',2007);
      if p_element_type_id is not null then
          l_element_type_id:=p_element_type_id;
      else
        open c_get_element_type_id;
        -- ok to be null if p_enrt_rt_id is null
        fetch c_get_element_type_id into l_element_type_id;
        close c_get_element_type_id;
      end if;
      --
      l_periods := 0;
      --
      if p_payroll_id is null then
         fnd_message.set_name('BEN','BEN_92403_PAYROLL_ID_REQ');
         fnd_message.set_token('PROC',l_package);
         fnd_message.raise_error;
      end if;
      -- Check if period_type of the payroll is
      -- either Calendar or Lunar month
      -- Standard skip rules aren't applied to these
      --
      open get_period_type(p_payroll_id,p_start_date);
      fetch get_period_type into l_period_type;
      close get_period_type;
      --
      if l_period_type in ('Calendar Month','Lunar Month') then
           hr_utility.set_location('Inside Calendar Month',2007);
       -- 3704632 : Added IF-CLAUSE here.
        if (p_end_date is null) THEN
            select MAX(end_date)
              into l_max_end_date
              from per_time_periods
             where payroll_id = p_payroll_id
               and TO_CHAR(end_date,'YYYY') =
                    (SELECT TO_CHAR(end_date,'YYYY')
                       from per_time_periods
                      where payroll_id = p_payroll_id
                        and p_start_date between start_date and end_date
                      );
        END IF;
       -- 3704632 : End changes

        select count(*)
          into l_periods
          from per_time_periods
         where payroll_id = p_payroll_id
           and end_date between p_start_date and NVL(p_end_date,l_max_end_date);  -- 3704632 : Added NVL() here.

else
      -- Check whether any element rule available for the element type.
      -- If not, do not call the payroll check routine.
      --
  open pay_freq_rule_exists(p_payroll_id,l_element_type_id);
  --
  fetch pay_freq_rule_exists into l_pay_freq_bitmap_no,l_reset;
  --
  if pay_freq_rule_exists%FOUND THEN
   --
   close pay_freq_rule_exists;
   --
   IF l_reset <>'MM' THEN -- Year
   hr_utility.set_location('Frequency Rule Year',2007);
     BEGIN
       FOR l_parse_periods IN c_parse_periods1(p_payroll_id,
                                      p_start_date,
                                      nvl(p_end_date,l_end_date))
        LOOP
          hr_elements.check_element_freq(
              p_payroll_id           =>p_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>TO_NUMBER(null),
              p_date_earned          =>l_parse_periods.end_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>l_skip_element);
          --
          IF l_skip_element='N' THEN
            -- count the rows found
            l_periods := l_periods + 1;
          END IF;
          --
          --
        END LOOP;
     END;
   ELSE -- Month

   --Bug 6913654, Added 'if..else' condition if p_start_date and p_end_date fall in the same month.Old code does not handle this.
   if TRUNC(p_start_date,l_reset) = TRUNC(p_end_date,l_reset) then
	      hr_utility.set_location('Frequency Rule Month',2007);
	     BEGIN
	       if g_debug then
		 hr_utility.set_location('get_periods_between ',10);
	       end if;
	       FOR l_parse_periods IN c_parse_periods1(p_payroll_id,
					      p_start_date,
					      p_end_date)
		LOOP
		  hr_elements.check_element_freq(
		      p_payroll_id           =>p_payroll_id,
		      p_bg_id                =>p_business_group_id,
		      p_pay_action_id        =>TO_NUMBER(null),
		      p_date_earned          =>l_parse_periods.end_date,
		      p_ele_type_id          =>l_element_type_id,
		      p_skip_element         =>l_skip_element);
		  --
		  IF l_skip_element='N' THEN
		    -- count the rows found
		    l_periods := l_periods + 1;
		  END IF;
		  --
		  --
		END LOOP;
		--dbms_output.put_line('10:start'||to_char(p_start_date)||' end '||to_char(ADD_MONTHS(TRUNC(p_start_date,l_reset),1)-1)||' periods '||to_char(l_periods));
	     END;
    else
   IF p_start_date <> TRUNC(p_start_date,l_reset) THEN
		   hr_utility.set_location('Frequency Rule Month',2007);
     BEGIN
       if g_debug then
         hr_utility.set_location('get_periods_between ',10);
       end if;
       FOR l_parse_periods IN c_parse_periods1(p_payroll_id,
                                      p_start_date,
                                      ADD_MONTHS(TRUNC(p_start_date,l_reset),1) -1)
        LOOP
          hr_elements.check_element_freq(
              p_payroll_id           =>p_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>TO_NUMBER(null),
              p_date_earned          =>l_parse_periods.end_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>l_skip_element);
          --
          IF l_skip_element='N' THEN
            -- count the rows found
            l_periods := l_periods + 1;
          END IF;
          --
          --
        END LOOP;
        --dbms_output.put_line('10:start'||to_char(p_start_date)||' end '||to_char(ADD_MONTHS(TRUNC(p_start_date,l_reset),1)-1)||' periods '||to_char(l_periods));

     l_start_date := ADD_MONTHS(TRUNC(p_start_date,l_reset),1);
     END;
   ELSE
     l_start_date := p_start_date;
   END IF;
   IF NVL(p_end_date, l_end_date) <> (ADD_MONTHS(TRUNC(NVL(p_end_date, l_end_date),l_reset),1) -1) THEN -- 3704632 : Added NVL() to p_end_date
		   hr_utility.set_location('Frequency Other1',2007);
     BEGIN
       if g_debug then
         hr_utility.set_location('get_periods_between ',15);
       end if;
       FOR l_parse_periods IN c_parse_periods1(p_payroll_id,
                                        TRUNC(NVL(p_end_date, l_end_date),l_reset), -- 3704632 : Added NVL() to p_end_date
                                        NVL(p_end_date, l_end_date)) -- 3704632 : Added NVL() to p_end_date
        LOOP
          hr_elements.check_element_freq(
              p_payroll_id           =>p_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>TO_NUMBER(null),
              p_date_earned          =>l_parse_periods.end_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>l_skip_element);
          --
          IF l_skip_element='N' THEN
            -- count the rows found
            l_periods := l_periods + 1;
          END IF;
          --
          --
        END LOOP;

        --dbms_output.put_line('15:start'||to_char(p_start_date)||' end '||to_char(ADD_MONTHS(TRUNC(p_start_date,l_reset),1)-1)||' periods '||to_char(l_periods));
       l_end_date := TRUNC(NVL(p_end_date, l_end_date),l_reset) - 1; -- 3704632 : Added NVL() to p_end_date
     END;
   ELSE
     l_end_date := NVL(p_end_date, l_end_date); -- 3704632 : Added NVL() to p_end_date
   END IF;
   IF (l_start_date <= l_end_date ) THEN
       if g_debug then
         hr_utility.set_location('get_periods_between ',20);
       end if;
   OPEN parse_periods(p_payroll_id => p_payroll_id
                     ,p_rt_start =>l_start_date
                     ,p_eoy =>l_end_date
                     ,p_reset =>l_reset
                     ,p_frq_bitmap_no => l_pay_freq_bitmap_no);
       --
   FETCH parse_periods INTO l_tot_perd;
       --
   CLOSE parse_periods;
--
		   hr_utility.set_location('Frequency Year others 2',2007);
       l_periods := l_periods + l_tot_perd;
       -- dbms_output.put_line('20:start'||to_char(l_start_Date)||' end '||to_char(l_end_date)||' periods '||to_char(l_periods));
   END IF; -- l_start_date <= l_end_date
   end if;

   END IF;
     --
     --bug#4504449 - defaulted to one to avoid error if not from estimate like
     --elements without frequency
     if (l_periods = 0 and not p_called_from_est) then
         --
         l_periods  := 1 ;
         --
      end if;
     --
   ELSE -- no pay frequency rules
     CLOSE pay_freq_rule_exists;
     --
     IF months_between(p_start_date,nvl(p_end_date,l_end_date)) =12
     THEN
       SELECT  TPT.number_per_fiscal_year
       INTO    l_periods
       FROM    per_time_period_types   TPT,
       pay_payrolls_f          PRL
       WHERE   TPT.period_type         = PRL.period_type
       AND     PRL.business_group_id   = p_business_group_id
       AND     PRL.payroll_id          = p_payroll_id;
     ELSE
       OPEN  c_count_periods(p_payroll_id,
                              p_start_date,
                              nvl(p_end_date,l_end_date));
        FETCH c_count_periods into l_tot_perd;
        CLOSE c_count_periods;
        --
        --Bug 2151055
        --
        if (l_tot_perd = 0 and not p_called_from_est) then
         --
         l_tot_perd := 1 ;
         --
        end if;
        --
	hr_utility.set_location('Frequency Year other3',2007);
        l_periods := l_tot_perd;
        --
     END IF;
   END IF;
  END IF;
  if g_debug then
    hr_utility.set_location(' Before if l_periods = 0 ',233);
  end if;
  --
      if l_periods = 0 or l_periods is null then
         l_periods := l_tot_perd;
     end if;

      if (l_tot_perd = 0 AND l_periods = 0 and not p_called_from_est) then
         --
         -- Raise error as payroll was not found.
         if g_debug then
           hr_utility.set_location('l_tot_perd = 0 and l_periods = 0 ' ,234);
         end if;
         --
         fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
         fnd_message.set_token('PROC',l_package);
         fnd_message.raise_error;
      end if;
      --
      if p_acty_ref_perd_cd = 'EPP' then
         --
         if l_period_type = 'Bi-Week' then
           --
           if l_periods > 26 then
             l_periods := 26;
           end if;
           --
         elsif l_period_type = 'Week' then
           --
           if l_periods > 52 then
             l_periods := 52;
           end if;
           --
         end if;
         --
      end if;
      --
  elsif p_acty_ref_perd_cd = 'PP1' then
      --
      -- Pay Period
      --
      if p_element_type_id is not null then
        l_element_type_id:=p_element_type_id;
      else
        open c_get_element_type_id;
        -- ok to be null if p_enrt_rt_id is null
        fetch c_get_element_type_id into l_element_type_id;
        close c_get_element_type_id;
      end if;
      --
      l_periods := 0;
      --
      if p_payroll_id is null then
         fnd_message.set_name('BEN','BEN_92403_PAYROLL_ID_REQ');
         fnd_message.set_token('PROC',l_package);
         fnd_message.raise_error;
      end if;
      --
      -- Check whether any element rule available for the element type.
      -- If not, do not call the payroll check routine.
      --
      if l_element_type_id is null then
        l_element_rule_exists := 'N';
      else
        open  c_element_rule_exists;
        fetch c_element_rule_exists into l_element_rule_exists;
        close c_element_rule_exists;
      end if;
      --
      if g_debug then
        hr_utility.set_location('Pay roll id'||p_payroll_id,111);
        hr_utility.set_location('start date '||p_start_date,111);
        hr_utility.set_location('end date '||l_end_date,111);
      end if;
      if l_element_rule_exists = 'Y' then
        --
        for l_parse_periods in c_parse_periods1(p_payroll_id,
                                               p_start_date,
                                               nvl(p_end_date,l_end_date))
        loop
          hr_elements.check_element_freq(
              p_payroll_id           =>p_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>to_number(null),
              p_date_earned          =>l_parse_periods.end_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>l_skip_element);
          --
          if l_skip_element='N' then
            -- count the rows found
            l_periods := l_periods + 1;
          end if;
          --
          -- removed as gives incorrect answers
          -- if we're in here then there's a frequency
          -- rule so we shouldn't be counting the periods
          -- as we get errors later.
          --l_tot_perd := l_tot_perd + 1;
          --
          --
        end loop;
        --
      else
        --
        open  c_count_periods(p_payroll_id,
                              p_start_date,
                              nvl(p_end_date,l_end_date));
        fetch c_count_periods into l_tot_perd;
        close c_count_periods;
        --
        l_periods := l_tot_perd;
        --
      end if;

      if l_periods = 0 or l_periods is null then
         l_periods := l_tot_perd;
     end if;

      if l_periods = 0 then
         --
         -- Raise error as payroll was not found.
         --
         fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
         fnd_message.set_token('PROC',l_package);
         fnd_message.raise_error;
      end if;


   elsif p_acty_ref_perd_cd = 'BWK' then
      --
      -- Bi-weekly
      --
      l_periods := trunc(((l_end_date - p_start_date)/14),0);
      --
   elsif p_acty_ref_perd_cd = 'SMO' then
      --
      -- Semi-monthly
      --
      l_periods := trunc((months_between(l_end_date, p_start_date) * 2),0);
      --
   elsif p_acty_ref_perd_cd = 'MO' then
      --
      -- Monthly
      --
      l_periods := trunc((months_between(l_end_date, p_start_date)),0);
      --
      --Bug 2151055
      --
      if (l_periods = 0 and not p_called_from_est) then
        --
        l_periods := 1 ;
        --
      end if;
      --
   elsif p_acty_ref_perd_cd = 'PQU' then
      --
      -- Per Quarter
      --
      l_periods := trunc((months_between(l_end_date, p_start_date)/3),0);
      --
   elsif p_acty_ref_perd_cd = 'SAN' then
      --
      -- Semi-Annual
      --
      l_periods := trunc((months_between(l_end_date, p_start_date)/6),0);
      --
   elsif p_acty_ref_perd_cd = 'PYR' then
      --
      -- Annual
      --
      l_periods := trunc((months_between(l_end_date, p_start_date)/12),0);
      --
   elsif p_acty_ref_perd_cd = 'LFT' then
      --
      -- Lifetime.
      --
      l_periods := 1;

   else
      --
      -- Invalid Activity reference period code.
      --
      fnd_message.set_name('BEN','BEN_91299_INV_ACTY_REF_PERD_CD');
      fnd_message.set_token('PROC',l_package);
      fnd_message.set_token('ACTY_REF_PERD_CD',p_acty_ref_perd_cd);
      fnd_message.raise_error;
      --
   end if;

   if g_debug then
     hr_utility.set_location('Number of Periods: '||to_char(l_periods), 90);
     hr_utility.set_location('Leaving '||l_package , 90);
   end if;

   return(l_periods);

exception
   --
   when others then
      fnd_message.raise_error;
   --
end get_periods_between;
--
--overloaded the function to calculate periods based on cheque dateS
--
--
function get_periods_between(
                            p_acty_ref_perd_cd in varchar2,
                            p_start_date       in date,
                            p_end_date         in date default null,
                            p_payroll_id       in number default null,
                            p_business_group_id in number default null,
                            p_element_type_id  in number default null,
                            p_enrt_rt_id       in number default null,
                            p_effective_date   in date   default null,
                            p_use_check_date   in boolean
                            ) return number is
   l_package varchar2(80) := g_package || '.get_periods_between';

   cursor c_get_element_type_id is
     select element_type_id
     from   ben_enrt_rt ert,
            ben_acty_base_rt_f abr
     where  ert.enrt_rt_id=p_enrt_rt_id and
            ert.business_group_id=p_business_group_id and
            abr.acty_base_rt_id=ert.acty_base_rt_id and
            p_effective_date between
              abr.effective_start_date and abr.effective_end_date;
   --
   l_element_type_id number;
   --
   cursor c_element_rule_exists is
      select  'Y'
      from    pay_ele_payroll_freq_rules   epf
      where   epf.element_type_id          = l_element_type_id
      and     epf.payroll_id               = p_payroll_id
      and     epf.business_group_id        = p_business_group_id;
   --
   l_element_rule_exists varchar2(1) := 'N';
   --
   -- Parse Periods gets the information about the
   -- number of pay_periods by start date
   -- for the rate.
   --
   cursor c_parse_periods1(v_payroll_id in number,
                          v_start_date in date,
                          v_end_date   in date) is
	select ptp.start_date,
               ptp.end_date
	from   per_time_periods ptp
	where  ptp.payroll_id     = v_payroll_id
          and  ptp.end_date between
               v_start_date and v_end_date;
   --
cursor get_period_type(p_payroll_id IN NUMBER
                      ,p_date IN DATE) is
select period_type
       ,pay_date_offset
from   pay_all_payrolls_f
where  payroll_id = p_payroll_id
and    p_date between effective_start_date
and    effective_end_date;

--
l_period_type VARCHAR2(30);
l_pay_date_offset  number;
--
cursor pay_freq_rule_exists(p_payroll_id IN NUMBER
                    ,p_element_type_id IN NUMBER) is
select sum(power(2,(FRP.period_no_in_reset_period) - 1))
,decode(epf.reset_period_type,'Year','YYYY','MM')
from   pay_ele_payroll_freq_rules EPF
,      pay_freq_rule_periods FRP
where  FRP.ele_payroll_freq_rule_id = EPF.ele_payroll_freq_rule_id
and    EPF.payroll_id               = p_payroll_id
and    EPF.element_type_id          = p_element_type_id
group  by epf.ele_payroll_freq_rule_id ,epf.reset_period_type;
--
 cursor parse_periods(p_payroll_id IN NUMBER
                    ,p_rt_start IN DATE
                    ,p_eoy IN DATE
                    ,p_reset IN VARCHAR2
                    ,p_frq_bitmap_no IN NUMBER) is
select sum(
ben_distribute_rates.decde_bits(
bitand(power(2,count(end_date )) -1,p_frq_bitmap_no)
))
from per_time_periods
where payroll_id = p_payroll_id
and   --end_date -- Bug 6830210
      regular_payment_date -- Bug 6830210
      between p_rt_start
      and     p_eoy
group by to_char(end_date,p_reset)
;

   cursor c_count_periods(v_payroll_id in number,
                          v_start_date in date,
                          v_end_date   in date) is
        select count(1)
        from   per_time_periods ptp
        where  ptp.payroll_id     = v_payroll_id
   --     and    nvl(ptp.regular_payment_date,ptp.end_date) between
        and    ptp.end_date between
               v_start_date and v_end_date;
 --       and    nvl(ptp.regular_payment_date,ptp.end_date) >= v_start_date;
  --
  -- BUG 3159774 looks like a typo- we shouldn't be having
  -- ptp.end_date condition and also nvl(ptp.regular_payment_date,ptp.end_date)
  -- condition which fails for cases like the one in the bug.
  --
   cursor c_count_periods_chq(v_payroll_id in number,
                          v_start_date in date,
                          v_end_date   in date) is
        select count(1)
        from   per_time_periods ptp
        where  ptp.payroll_id     = v_payroll_id
     --   and    ptp.end_date between
     --          v_start_date and v_end_date
     -- Bug 6455096
  --      and    ptp.end_date >= v_start_date
          -- bug 7314120
        and    ptp.regular_payment_date >= (select regular_payment_date
		                            from per_time_periods
					    where payroll_id = v_payroll_id
                                            and v_start_date between start_date
					                     and end_date)--v_start_date
-- bug 7314120
    -- Bug 6455096
        and    nvl(ptp.regular_payment_date,ptp.end_date) between
               v_start_date and v_end_date;
   --
   l_periods   number := null;
   l_start_date  date;
   l_end_date  date;
   l_date      date;
   l_fortnight_end_date date;
   l_temp      varchar2(1);
   l_tot_perd  number := 0;
   l_skip_element varchar2(30);
   l_pay_freq_bitmap_no NUMBER;
   l_reset  VARCHAR2(30):= 'MM';
   l_pay_annualization_factor number ;

begin
   --
   g_debug := hr_utility.debug_enabled;
   --
   if g_debug then
     hr_utility.set_location('Entering '||l_package, 11);
   end if;
   --
   hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_acty_ref_perd_cd',
                             p_argument_value => p_acty_ref_perd_cd);
   --
   hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_start_date',
                             p_argument_value => p_start_date);

   --
   if g_debug then
     hr_utility.set_location('p_acty_ref_perd_cd '||p_acty_ref_perd_cd,21);
     hr_utility.set_location('p_start_date '||to_char(p_start_date),31);
     hr_utility.set_location('p_end_date '||to_char(p_end_date),41);
   end if;
   --
   if p_end_date is null then
      --
      -- End of the year (of the start date)
      --
      l_end_date := add_months(trunc(p_start_date,'YYYY'),12);
      --
   else
      --
      -- Start Date should be less than end date.
      --
      if p_end_date < p_start_date then
         --
         fnd_message.set_name('BEN','BEN_91824_START_DT_AFTR_END_DT');
         fnd_message.set_token('PROC',l_package);
         fnd_message.set_token('START_DT',to_char(p_start_date));
         fnd_message.set_token('END_DT',to_char(p_end_date));
         fnd_message.raise_error;
         --
      else
         --
         --  need to add 1 day to correctly calc time between 2 dates.
         --  because we are truncating down we get the correct answer.
         --  ie months_between(1/1/99,12/31/99) = 11.999999999
         --  by adding 1 day to the end date we get the correct answer
         --  of 12
         --
         l_end_date := p_end_date + 1;
         --
      end if;
      --
   end if;
   --
   if g_debug then
     hr_utility.set_location(l_package,51);
   end if;
   --
   if p_acty_ref_perd_cd = 'PWK' then
      --
      -- Weekly
      --
      l_periods := trunc(((l_end_date - p_start_date)/7),0);
      --
   elsif p_acty_ref_perd_cd = 'PHR' then
     --
     l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
     if l_pay_annualization_factor is null then
       l_pay_annualization_factor := 2080;
     end if;
     --
     l_periods := trunc(((l_end_date - p_start_date)/365 * l_pay_annualization_factor),0);
     --
   elsif p_acty_ref_perd_cd = 'PP' or p_acty_ref_perd_cd = 'EPP'
          or p_acty_ref_perd_cd = 'PPF' then
      --
      -- Pay Period
      --
      if p_element_type_id is not null then
        l_element_type_id:=p_element_type_id;
      else
        open c_get_element_type_id;
        -- ok to be null if p_enrt_rt_id is null
        fetch c_get_element_type_id into l_element_type_id;
        close c_get_element_type_id;
      end if;
      --
      l_periods := 0;
      --
      if p_payroll_id is null then
         fnd_message.set_name('BEN','BEN_92403_PAYROLL_ID_REQ');
         fnd_message.set_token('PROC',l_package);
         fnd_message.raise_error;
      end if;
      -- Check if period_type of the payroll is
      -- either Calendar or Lunar month
      -- Standard skip rules aren't applied to these
      --
      open get_period_type(p_payroll_id,p_start_date);
      fetch get_period_type into l_period_type, l_pay_date_offset;
      close get_period_type;
      --
      if l_period_type in ('Calendar Month','Lunar Month') then
       if p_use_check_date then
          --
          OPEN  c_count_periods_chq(p_payroll_id,
                                    p_start_date,
                                    nvl(p_end_date,l_end_date));
          FETCH c_count_periods_chq into l_tot_perd;
          CLOSE c_count_periods_chq;
          --
       else
         --
          select count(*)
          into   l_periods
          from   per_time_periods
          where  payroll_id = p_payroll_id
          and    end_date
          between p_start_date
          and     p_end_date;
         --
       end if;
else
      -- Check whether any element rule available for the element type.
      -- If not, do not call the payroll check routine.
      --
  open pay_freq_rule_exists(p_payroll_id,l_element_type_id);
  --
  fetch pay_freq_rule_exists into l_pay_freq_bitmap_no,l_reset;
  --
  if pay_freq_rule_exists%FOUND THEN
   --
   close pay_freq_rule_exists;
   --
   IF l_reset <>'MM' THEN -- Year
     BEGIN
       FOR l_parse_periods IN c_parse_periods1(p_payroll_id,
                                      p_start_date,
                                      nvl(p_end_date,l_end_date))
        LOOP
          hr_elements.check_element_freq(
              p_payroll_id           =>p_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>TO_NUMBER(null),
              p_date_earned          =>l_parse_periods.end_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>l_skip_element);
          --
          IF l_skip_element='N' THEN
            -- count the rows found
            l_periods := l_periods + 1;
          END IF;
          --
          --
        END LOOP;
     END;
   ELSE -- Month

   --Bug 6913654, Added 'if..else' condition if p_start_date and p_end_date fall in the same month.Old code does not handle this.
   IF TRUNC(p_start_date,l_reset) = TRUNC(p_end_date,l_reset) THEN
     BEGIN
       if g_debug then
         hr_utility.set_location('get_periods_between ',10);
       end if;
       FOR l_parse_periods IN c_parse_periods1(p_payroll_id,
                                      p_start_date,
                                      p_end_date)
        LOOP
          hr_elements.check_element_freq(
              p_payroll_id           =>p_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>TO_NUMBER(null),
              p_date_earned          =>l_parse_periods.end_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>l_skip_element);
          --
          IF l_skip_element='N' THEN
            -- count the rows found
            l_periods := l_periods + 1;
          END IF;
          --
          --
        END LOOP;
	end;
   else
   IF p_start_date <> TRUNC(p_start_date,l_reset) THEN
     BEGIN
       if g_debug then
         hr_utility.set_location('get_periods_between ',10);
       end if;
       FOR l_parse_periods IN c_parse_periods1(p_payroll_id,
                                      p_start_date,
                                      ADD_MONTHS(TRUNC(p_start_date,l_reset),1) -1)
        LOOP
          hr_elements.check_element_freq(
              p_payroll_id           =>p_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>TO_NUMBER(null),
              p_date_earned          =>l_parse_periods.end_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>l_skip_element);
          --
          IF l_skip_element='N' THEN
            -- count the rows found
            l_periods := l_periods + 1;
          END IF;
          --
          --
        END LOOP;

     l_start_date := ADD_MONTHS(TRUNC(p_start_date,l_reset),1);
     END;
   ELSE
     l_start_date := p_start_date;
   END IF;
   IF p_end_date <> (ADD_MONTHS(TRUNC(p_end_date,l_reset),1) -1) THEN
     BEGIN
       if g_debug then
         hr_utility.set_location('get_periods_between ',15);
       end if;
       FOR l_parse_periods IN c_parse_periods1(p_payroll_id,
                                        TRUNC(p_end_date,l_reset),
                                        p_end_date)
        LOOP
          hr_elements.check_element_freq(
              p_payroll_id           =>p_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>TO_NUMBER(null),
              p_date_earned          =>l_parse_periods.end_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>l_skip_element);
          --
          IF l_skip_element='N' THEN
            -- count the rows found
            l_periods := l_periods + 1;
          END IF;
          --
          --
        END LOOP;

       l_end_date := TRUNC(p_end_date,l_reset) - 1;
     END;
   ELSE
     l_end_date := p_end_date;
   END IF;
   IF (l_start_date <= l_end_date ) THEN
       if g_debug then
         hr_utility.set_location('get_periods_between ',20);
       end if;
   OPEN parse_periods(p_payroll_id => p_payroll_id
                     ,p_rt_start =>l_start_date
                     ,p_eoy =>l_end_date
                     ,p_reset =>l_reset
                     ,p_frq_bitmap_no => l_pay_freq_bitmap_no);
       --
   FETCH parse_periods INTO l_tot_perd;
       --
   CLOSE parse_periods;
--
       l_periods := l_periods + l_tot_perd;
   END IF; -- l_start_date <= l_end_date
   end if;
   END IF;
   ELSE -- no pay frequency rules
     CLOSE pay_freq_rule_exists;
     --
/*     IF months_between(p_start_date,nvl(p_end_date,l_end_date)) =12
     THEN
       SELECT  TPT.number_per_fiscal_year
       INTO    l_periods
       FROM    per_time_period_types   TPT,
       pay_payrolls_f          PRL
       WHERE   TPT.period_type         = PRL.period_type
       AND     PRL.business_group_id   = p_business_group_id
       AND     PRL.payroll_id          = p_payroll_id;
*/
       OPEN  c_count_periods_chq(p_payroll_id,
                              p_start_date,
                              nvl(p_end_date,l_end_date));
        FETCH c_count_periods_chq into l_tot_perd;
        CLOSE c_count_periods_chq;
        --
        --Bug 2151055
        --
        if l_tot_perd = 0 then
         --
         l_tot_perd := 1 ;
         --
        end if;
        --
        l_periods := l_tot_perd;
        --
   END IF;
  END IF;
  if g_debug then
    hr_utility.set_location(' Before if l_periods = 0 ',233);
  end if;
  --
      if l_periods = 0 or l_periods is null then
         l_periods := l_tot_perd;
     end if;

      if (l_tot_perd = 0 AND l_periods = 0) then
         --
         -- Raise error as payroll was not found.
         if g_debug then
           hr_utility.set_location('l_tot_perd = 0 and l_periods = 0 ' ,234);
         end if;
         --
         fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
         fnd_message.set_token('PROC',l_package);
         fnd_message.raise_error;
      end if;
      --
      if p_acty_ref_perd_cd = 'EPP' then
         --
         if l_period_type = 'Bi-Week' then
           --
           if l_periods > 26 then
             l_periods := 26;
           end if;
           --
         elsif l_period_type = 'Week' then
           --
           if l_periods > 52 then
             l_periods := 52;
           end if;
           --
         end if;
         --
      end if;
      --

   elsif p_acty_ref_perd_cd = 'BWK' then
      --
      -- Bi-weekly
      --
      l_periods := trunc(((l_end_date - p_start_date)/14),0);
      --
   elsif p_acty_ref_perd_cd = 'SMO' then
      --
      -- Semi-monthly
      --
      l_periods := trunc((months_between(l_end_date, p_start_date) * 2),0);
      --
   elsif p_acty_ref_perd_cd = 'MO' then
      --
      -- Monthly
      --
      l_periods := trunc((months_between(l_end_date, p_start_date)),0);
      --
      --Bug 2151055
      --
      if l_periods = 0 then
        --
        l_periods := 1 ;
        --
      end if;
      --
   elsif p_acty_ref_perd_cd = 'PQU' then
      --
      -- Per Quarter
      --
      l_periods := trunc((months_between(l_end_date, p_start_date)/3),0);
      --
   elsif p_acty_ref_perd_cd = 'SAN' then
      --
      -- Semi-Annual
      --
      l_periods := trunc((months_between(l_end_date, p_start_date)/6),0);
      --
   elsif p_acty_ref_perd_cd = 'PYR' then
      --
      -- Annual
      --
      l_periods := trunc((months_between(l_end_date, p_start_date)/12),0);
      --
   elsif p_acty_ref_perd_cd = 'LFT' then
      --
      -- Lifetime.
      --
      l_periods := 1;

   else
      --
      -- Invalid Activity reference period code.
      --
      fnd_message.set_name('BEN','BEN_91299_INV_ACTY_REF_PERD_CD');
      fnd_message.set_token('PROC',l_package);
      fnd_message.set_token('ACTY_REF_PERD_CD',p_acty_ref_perd_cd);
      fnd_message.raise_error;
      --
   end if;

   if g_debug then
     hr_utility.set_location('Number of Periods: '||to_char(l_periods), 90);
     hr_utility.set_location('Leaving '||l_package , 90);
   end if;

   return(l_periods);

exception
   --
   when others then
      fnd_message.raise_error;
   --
end get_periods_between;
--
---------------------------------------------------------------------------
-- This procedure is used to estimate the balance for the activity base rate
-- for the peiod defined by p_date_from and p_date_to.
-- The estimation is based on element entries and their corresponding values.
--
-- Scope of function: Internal.
---------------------------------------------------------------------------
procedure estimate_balance
            (p_person_id             in number,
             p_acty_base_rt_id       in number,
             p_payroll_id            in number,
             p_effective_date        in date,
             p_business_group_id     in number,
             p_date_from             in date,
             p_date_to               in date,
             p_balance               out nocopy number) is
  --
  -- This cursor gets all the possible element entries which can in the
  -- date range of p_date_from and p_date_to.
  --
  cursor c_element is
     select to_number(evl.screen_entry_value) entry_value,
            evl.effective_start_date,
            evl.effective_end_date,
            ety.processing_type,
            asg.payroll_id,
            eln.element_type_id
     from   ben_prtt_rt_val            prv,
            ben_per_in_ler             pil,
            pay_element_entry_values_f evl,
            per_all_assignments_f          asg,
            pay_element_entries_f      een,
            pay_element_links_f        eln,
            pay_element_types_f        ety
     where  prv.acty_base_rt_id        = p_acty_base_rt_id
     and    prv.per_in_ler_id          = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and    prv.element_entry_value_id = evl.element_entry_value_id
     and    evl.element_entry_id       = een.element_entry_id
     and    een.assignment_id          = asg.assignment_id
     and    asg.person_id              = p_person_id
     and    een.element_link_id        = eln.element_link_id
     and    eln.element_type_id        = ety.element_type_id
     and    prv.prtt_rt_val_stat_cd is null
     and    prv.business_group_id = p_business_group_id
     and    evl.effective_start_date <= p_date_to
     and    evl.effective_end_date >= p_date_from
     and    evl.effective_start_date between
            prv.rt_strt_dt and prv.rt_end_dt
     and    evl.effective_start_date between
            asg.effective_start_date and asg.effective_end_date
     and    evl.effective_start_date between
            een.effective_start_date and een.effective_end_date
     and    evl.effective_start_date between
            eln.effective_start_date and eln.effective_end_date
     and    evl.effective_start_date between
            ety.effective_start_date and ety.effective_end_date;
  --
  l_estimate    number := 0;
  l_start_date  date;
  l_end_date    date;
  l_periods     number;
  l_package varchar2(80) := g_package || '.estimate_balance';
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering '||l_package, 10);
  end if;
  --
  for l_element in c_element loop
    --
    if l_element.processing_type = 'R' then
      --
      -- If the amount is recurring, multiply by number of pay periods.
      --
      l_start_date := l_element.effective_start_date;
      l_end_date   := l_element.effective_end_date;
      --
      -- The start date of element should not be less than the p_date_from.
      -- If it is less than that, we make the start date as the p_date_from
      -- as we are only interested after the p_date_from.
      --
      if l_start_date < p_date_from then
        --
        l_start_date := p_date_from;
        --
      end if;
      --
      -- Similar logic applies to the end date.
      --
      if l_end_date > p_date_to then
        --
        l_end_date := p_date_to;
        --
      end if;
      --
      if g_debug then
       hr_utility.set_location('strt dt '||to_char(l_start_date), 110);
       hr_utility.set_location('end dt '||to_char(l_end_date), 110);
      end if;
      l_periods := get_periods_between
                    (p_start_date       => l_start_date,
                     p_end_date         => l_end_date,
                     p_acty_ref_perd_cd => 'PP',
           /* Bug 3394862 We need to get the l_element.payroll_id first
              if null then get from p_payroll_id .. Why do you have null...
                     p_payroll_id       => nvl(p_payroll_id,
                                               l_element.payroll_id), */
                     p_payroll_id        => nvl(l_element.payroll_id,p_payroll_id),
                     p_business_group_id => p_business_group_id,
                     p_element_type_id   => l_element.element_type_id,
                     p_effective_date    => p_effective_date,
                     p_called_from_est   => true
      );
      --
      l_estimate := l_estimate + (l_periods * l_element.entry_value) + 0;
      --
    else
      --
      l_estimate := l_estimate + l_element.entry_value + 0;
      --
    end if;
    --
  end loop;
  --
  p_balance := nvl(l_estimate,0);
  --
  if g_debug then
    hr_utility.set_location('Estimated Balance'||p_balance,11);
    hr_utility.set_location('Leaving '||l_package, 10);
  end if;
  --
end estimate_balance;
--
---------------------------------------------------------------------------
-- The function calculates the balance as of effective date.
--
-- Scope of function: Internal only.
---------------------------------------------------------------------------
function get_balance
                   (p_enrt_rt_id           in number   default null,
                    p_person_id            in number   default null,
                    p_per_in_ler_id        in number   default null,
                    p_pgm_id               in number   default null,
                    p_pl_id                in number   default null,
                    p_oipl_id              in number   default null,
                    p_enrt_perd_id         in number   default null,
                    p_lee_rsn_id           in number   default null,
                    p_acty_base_rt_id      in number   default null,
                    p_payroll_id           in number   default null,
                    p_ptd_comp_lvl_fctr_id in number   default null,
                    p_det_pl_ytd_cntrs_cd  in varchar2 default null,
                    p_lf_evt_ocrd_dt       in date default null,
                    p_business_group_id    in number,
                    p_start_date           in date,
                    p_end_date             in date     default null,
                    p_effective_date       in date)
return number
is
   --
   cursor c_ecr is
     select ecr.ptd_comp_lvl_fctr_id,
            ecr.elig_per_elctbl_chc_id,
            ecr.enrt_bnft_id,
            ecr.acty_base_rt_id,
            abr.det_pl_ytd_cntrs_cd,
            abr.parnt_chld_cd
     from   ben_enrt_rt        ecr,
            ben_acty_base_rt_f abr
     where  ecr.enrt_rt_id        = p_enrt_rt_id
     and    ecr.business_group_id = p_business_group_id
     and    ecr.acty_base_rt_id   = abr.acty_base_rt_id
     and    p_effective_date between
            abr.effective_start_date and abr.effective_end_date;
   --
   l_ecr      c_ecr%rowtype;
   --
   cursor c_epe is
     select epe.per_in_ler_id,
            epe.pgm_id,
            epe.pl_id,
            epe.oipl_id,
            pel.lee_rsn_id,
            pel.enrt_perd_id,
            pil.person_id,
            pil.lf_evt_ocrd_dt
     from   ben_elig_per_elctbl_chc epe,
            ben_pil_elctbl_chc_popl pel,
            ben_per_in_ler          pil
     where  epe.elig_per_elctbl_chc_id = l_ecr.elig_per_elctbl_chc_id
     and    epe.per_in_ler_id          = pil.per_in_ler_id
     and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and    pel.per_in_ler_id          = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
    UNION
     select epe.per_in_ler_id,
            epe.pgm_id,
            epe.pl_id,
            epe.oipl_id,
            pel.lee_rsn_id,
            pel.enrt_perd_id,
            pil.person_id,
            pil.lf_evt_ocrd_dt
     from   ben_enrt_bnft           enb,
            ben_elig_per_elctbl_chc epe,
            ben_pil_elctbl_chc_popl pel,
            ben_per_in_ler          pil
     where  enb.enrt_bnft_id           = l_ecr.enrt_bnft_id
     and    epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
     and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and    pel.per_in_ler_id          = pil.per_in_ler_id
     and    epe.per_in_ler_id          = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
   --
   l_epe      c_epe%rowtype;
   --
   cursor c_clf is
      select clf.comp_src_cd,
             clf.defined_balance_id
      from   ben_comp_lvl_fctr clf
      where  clf.comp_lvl_fctr_id  = l_ecr.ptd_comp_lvl_fctr_id
      and    clf.business_group_id = p_business_group_id;
   --
   l_clf   c_clf%rowtype;
   --
   -- This cursor gets the date till which balances are found.
   --
   cursor c_bal_date(v_start_date date, v_end_date in date) is
      select max(pac.effective_date) + 1
      from   pay_person_latest_balances plb,
             per_all_assignments_f          asg,
             pay_assignment_actions     paa,
             pay_payroll_actions        pac
      where  plb.person_id          = l_epe.person_id
      and    asg.assignment_type <> 'C'
      and    plb.defined_balance_id = l_clf.defined_balance_id
      and    asg.person_id          = l_epe.person_id
      and    asg.primary_flag       = 'Y'
      and    asg.assignment_id      = paa.assignment_id
      and    paa.payroll_action_id  = pac.payroll_action_id
      and    asg.business_group_id  = p_business_group_id
      and    p_effective_date between
             asg.effective_start_date and asg.effective_end_date
      and    pac.effective_date between
             v_start_date and  v_end_date;
   --
    cursor c_abr2
    (c_effective_date in date,
     c_acty_base_rt_id in number
      )
    is
    select abr2.det_pl_ytd_cntrs_cd
    from   ben_acty_base_rt_f abr,
           ben_acty_base_rt_f abr2
    where  abr.acty_base_rt_id = c_acty_base_rt_id
    and    abr2.acty_base_rt_id = abr.parnt_acty_base_rt_id
    and    abr2.parnt_chld_cd = 'PARNT'
    and    c_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    c_effective_date
           between abr2.effective_start_date
           and  abr2.effective_end_date;



   l_enrt_cvg_strt_dt            date;
   l_enrt_cvg_end_dt             date;
   l_rt_strt_dt                  date;
   l_rt_end_dt                   date;
   l_enrt_cvg_strt_dt_cd         varchar2(30);
   l_enrt_cvg_end_dt_cd          varchar2(30);
   l_rt_strt_dt_cd               varchar2(30);
   l_rt_end_dt_cd                varchar2(30);
   l_enrt_cvg_strt_dt_rl         number;
   l_enrt_cvg_end_dt_rl          number;
   l_rt_strt_dt_rl               number;
   l_rt_end_dt_rl                number;
   --
   l_start_date                  date   := p_start_date;
   l_balance_amt                 number := 0;
   l_estimated_bal               number := 0;
   --
   l_package varchar2(80) := g_package || '.get_balance';
   --
begin
   --
   if g_debug then
     hr_utility.set_location('Entering '||l_package, 10);
   end if;
   --
   if p_enrt_rt_id is not null then
     --
     open c_ecr;
     fetch c_ecr into l_ecr;
     close c_ecr;
     --
     if l_ecr.det_pl_ytd_cntrs_cd is null and l_ecr.parnt_chld_cd = 'CHLD' then
        --
        open c_abr2(p_effective_date, l_ecr.acty_base_rt_id);
        fetch c_abr2 into l_ecr.det_pl_ytd_cntrs_cd;
        close c_abr2;
     end if;
     --
     open  c_epe;
     fetch c_epe into l_epe;
     close c_epe;
     --
   else
     --
     l_epe.person_id            := p_person_id;
     l_epe.per_in_ler_id        := p_per_in_ler_id;
     l_epe.lf_evt_ocrd_dt       := p_lf_evt_ocrd_dt;
     l_epe.pgm_id               := p_pgm_id;
     l_epe.pl_id                := p_pl_id;
     l_epe.oipl_id              := p_oipl_id;
     l_epe.lee_rsn_id           := p_lee_rsn_id;
     l_epe.enrt_perd_id         := p_enrt_perd_id;
     l_ecr.ptd_comp_lvl_fctr_id := p_ptd_comp_lvl_fctr_id;
     l_ecr.acty_base_rt_id      := p_acty_base_rt_id;
     l_ecr.det_pl_ytd_cntrs_cd  := p_det_pl_ytd_cntrs_cd;
     --
   end if;
   --
   if l_ecr.det_pl_ytd_cntrs_cd is null or
      l_start_date is null then
     --
     if g_debug then
       hr_utility.set_location('Leaving '||l_package , 91);
     end if;
     return(0);
     --
   end if;
   --
   -- Get the rate end date.
   --
   ben_determine_date.rate_and_coverage_dates
     (p_which_dates_cd         => 'R'
     ,p_date_mandatory_flag    => 'N'
     ,p_compute_dates_flag     => 'Y'
     ,p_business_group_id      => p_business_group_id
     ,P_PER_IN_LER_ID          => l_epe.per_in_ler_id
     ,P_PERSON_ID              => l_epe.person_id
     ,P_PGM_ID                 => l_epe.pgm_id
     ,P_PL_ID                  => l_epe.pl_id
     ,P_OIPL_ID                => l_epe.oipl_id
     ,P_LEE_RSN_ID             => l_epe.lee_rsn_id
     ,P_ENRT_PERD_ID           => l_epe.enrt_perd_id
     ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt
     ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd
     ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl
     ,p_rt_strt_dt             => l_rt_strt_dt
     ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
     ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
     ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt
     ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd
     ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl
     ,p_rt_end_dt              => l_rt_end_dt
     ,p_rt_end_dt_cd           => l_rt_end_dt_cd
     ,p_rt_end_dt_rl           => l_rt_end_dt_rl
     ,p_effective_date         => p_effective_date
     ,p_lf_evt_ocrd_dt         => l_epe.lf_evt_ocrd_dt
     );
   -- when this function called from reimbursement reqist
   --- the end date is sent as parameter bug : 1182293

   if p_end_date is not null then
      l_rt_end_dt := p_end_date ;
   end if ;
   ---
   if g_debug then
     hr_utility.set_location('yr start date ' || l_start_date , 293);
     hr_utility.set_location('l_rt_strt_dt '|| l_rt_strt_dt, 293);
     hr_utility.set_location('end date ' || l_rt_end_dt , 293);
     hr_utility.set_location('level facotr ' || l_ecr.ptd_comp_lvl_fctr_id , 293);
   end if;


   if l_rt_end_dt is null or
      l_start_date > l_rt_end_dt then
     --
     -- As the year period start date is greater than the rate
     -- end date, you might be in the new year. So no YTD balances
     -- available.
     -- For e.g: Year start date is 1/1/90 and the rate end date
     -- calculated is 12/31/89. Here the old rate will belong in the
     -- previous year (1989) and should not be used for current year (1990)
     --
     if g_debug then
       hr_utility.set_location('Leaving '||l_package , 92);
     end if;
     return(0);
     --
   end if;
   --
   open  c_clf;
   fetch c_clf into l_clf;
   close c_clf;
   --
   if l_ecr.det_pl_ytd_cntrs_cd in ('BALONLY', 'BALTHENEST','BTDADDEST') and
      l_ecr.ptd_comp_lvl_fctr_id is not null then
     --
     -- Balances.
     --
     ben_derive_factors.determine_compensation
         (p_comp_lvl_fctr_id     => l_ecr.ptd_comp_lvl_fctr_id,
          p_person_id            => l_epe.person_id,
          p_pgm_id               => l_epe.pgm_id,
          p_pl_id                => l_epe.pl_id,
          p_oipl_id              => l_epe.oipl_id,
          p_per_in_ler_id        => l_epe.per_in_ler_id,
          p_business_group_id    => p_business_group_id,
          p_perform_rounding_flg => TRUE,
          p_effective_date       => p_effective_date,
          p_lf_evt_ocrd_dt       => l_epe.lf_evt_ocrd_dt,
          p_calc_bal_to_date     => l_rt_end_dt,
          p_value                => l_balance_amt);
     --
     -- Get the date till which balances have been found.
     -- We require this date only when balance to-date is added to estimate
     -- (BTDADDEST)
     -- This date also makes sense only for defined balances (BALTYP).
     --
     if g_debug then
       hr_utility.set_location('balance  '||l_balance_amt , 92);
     end if;
     if l_clf.comp_src_cd = 'BALTYP'            and
        l_ecr.det_pl_ytd_cntrs_cd = 'BTDADDEST' and
        l_balance_amt > 0 then
       --
       open  c_bal_date(l_start_date,l_rt_end_dt);
       fetch c_bal_date into l_start_date;
       close c_bal_date;
       --
     end if;
     --
   end if;
   --
   -- Compute estimates in three cases.
   -- 1. Only Estimtes  (ESTONLY)
   -- 2. To-date balances to be added to estimates. Do this only when
   --    we are dealing with defined balances.(BTDADDEST)
   -- 3. If balances are not available, we need the estimates.(BALTHENEST)
   --
   if (l_ecr.det_pl_ytd_cntrs_cd = 'ESTONLY')   OR
      (l_ecr.det_pl_ytd_cntrs_cd = 'BTDADDEST'
       and l_rt_end_dt > l_start_date
       and l_clf.comp_src_cd = 'BALTYP')          OR
      (l_ecr.det_pl_ytd_cntrs_cd = 'BALTHENEST'
       and nvl(l_balance_amt,0) = 0) then
      --
      -- Bug 3430334 The estimate balance is from the Yr Period start Date to the new
      -- Rate start Date. So the parametes should be Yr Period Start Date for p_date_from
      -- For p_date_to it has to be one day before the new rate start date.
      -- if l_rt_end_dt is greater than the rate start date, we need to take the rates
      -- rate start date - 1 else take the rate end end date.
      --
      if g_debug then
        hr_utility.set_location(' p_date_to '||least(l_rt_strt_dt-1, l_rt_end_dt),10);
        hr_utility.set_location(' l_start_date'||l_start_date,10);
      end if;
      --
      estimate_balance(p_person_id         => l_epe.person_id,
                      p_acty_base_rt_id   => l_ecr.acty_base_rt_id,
                      p_payroll_id        => p_payroll_id,
                      p_effective_date    => p_effective_date,
                      p_business_group_id => p_business_group_id,
                      p_date_from         => l_start_date,
                      p_date_to           => least(l_rt_strt_dt-1, l_rt_end_dt) , --Bug 3430334
                      p_balance           => l_estimated_bal);
     --
   end if;
   --
   if g_debug then
     hr_utility.set_location('Leaving '||l_package , 99);
   end if;
   --
   return(nvl(l_balance_amt,0) +l_estimated_bal);
   --
exception
   --
   when others then
      fnd_message.raise_error;
   --
end get_balance;
---------------------------------------------------------------------------
-- This procedure set the start date, end date, activity reference
-- period code if they are not supplied. To set these parameters
-- it uses the enrt_rt_id or elig_per_elctbl_chc_id. The parameters are
-- set only if they are null. But when complete year flag is on, then
-- the start date and end date are always set using plan year period.
-- To get what sets what, refer to the following logic.
--
-- Priority 1:
-- p_complete_year_flag = 'Y'
--      p_start_date is set to ben_yr_perd.start_date
--      p_end_date   is set to ben_yr_perd.end_date
-- In this case, the start date and end date values are overridden
-- even if these date parameters are not null.
--
-- Priority 2:
-- p_enrt_rt_id is not null
--     p_start_date     is set to ben_enrt_rt.rt_strt_dt
--     p_end_date       is set to ben_yr_perd.end_date
--     p_acty_ref_perd_cd is set to ben_pil_elctbl_chc_popl.acty_ref_perd_cd
-- In this case, the parameters are set only if they are null.
--
-- Priority 3:
-- p_elig_per_elctbl_chc_id is not null
--      p_start_date    is set to ben_elig_per_elctbl_chc.enrt_cvg_strt_dt
--      p_end_date      is set to ben_yr_perd.end_date
--      p_acty_ref_perd_cd is set to ben_pil_elctbl_chc_popl.acty_ref_perd_cd
-- In this case, the parameters are set only if they are null.
---------------------------------------------------------------------------
procedure set_default_dates(p_enrt_rt_id  in number,
                            p_elig_per_elctbl_chc_id in number,
                            p_business_group_id in number,
                            p_complete_year_flag in varchar2,
                            p_effective_date     in date,
                            p_payroll_id         in number default null,
                            p_lf_evt_ocrd_dt     in date default null,
                            p_start_date        in out nocopy date,
                            p_end_date          in out nocopy date,
                            p_acty_ref_perd_cd  in out nocopy varchar2,
                            p_yr_start_date     out nocopy date)
is
   --
   l_package                  varchar2(80) := g_package ||'.set_default_dates';
   l_elig_per_elctbl_chc_id   number       := p_elig_per_elctbl_chc_id;
   l_start_date               date         := p_start_date;
   l_acty_ref_perd_cd         varchar2(30) := p_acty_ref_perd_cd;
   l_start_date_cd            varchar2(30);
   l_start_date_rl            number;
   l_acty_base_rt_id          number;
   l_enrt_perd_start_dt       date;
   l_yr_perd_id               number;
   l_start_date_nc_buffer     date := p_start_date;  -- no copy changes
   l_end_date_nc_buffer	      date := p_end_date;    -- no copy changes
   --START 3191928
   l_enrt_cvg_strt_dt            date;
   l_enrt_cvg_end_dt             date;
   l_rt_strt_dt                  date;
   l_rt_end_dt                   date;
   l_enrt_cvg_strt_dt_cd         varchar2(30);
   l_enrt_cvg_end_dt_cd          varchar2(30);
   l_rt_strt_dt_cd               varchar2(30);
   l_rt_end_dt_cd                varchar2(30);
   l_enrt_cvg_strt_dt_rl         number;
   l_enrt_cvg_end_dt_rl          number;
   l_rt_strt_dt_rl               number;
   l_rt_end_dt_rl                number;
   --
   l_per_in_ler_id               number;
   l_pgm_id                      number;
   l_pl_id                       number;
   l_oipl_id                     number;
   l_lee_rsn_id                  number;
   l_enrt_perd_id                number;
   l_person_id                   number;
   l_lf_evt_ocrd_dt              date;
   --END

   --
   cursor c_epe is
      select epe.enrt_cvg_strt_dt,
             epe.enrt_cvg_strt_dt_cd,
             epe.enrt_cvg_strt_dt_rl,
             pel.enrt_perd_strt_dt,
             epe.yr_perd_id,
             pel.acty_ref_perd_cd,
             --BUG 3191928
             epe.per_in_ler_id,
             epe.pgm_id,
             epe.pl_id,
             epe.oipl_id,
             pel.lee_rsn_id,
             pel.enrt_perd_id,
             pil.person_id,
             pil.lf_evt_ocrd_dt,
             --END BUG 3191928
	     epe.pl_typ_id   -- ICM
      from   ben_elig_per_elctbl_chc epe,
             ben_pil_elctbl_chc_popl pel,
             ben_per_in_ler pil
      where  epe.elig_per_elctbl_chc_id  = p_elig_per_elctbl_chc_id
      and    epe.business_group_id = p_business_group_id
      and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
      and    pel.per_in_ler_id          = pil.per_in_ler_id
      and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
   --
   l_epe   c_epe%rowtype;
   --
   cursor c_ecr is
      select ecr.rt_strt_dt,
             ecr.rt_strt_dt_cd,
             ecr.rt_strt_dt_rl,
             pel.enrt_perd_strt_dt,
             epe.elig_per_elctbl_chc_id,
             epe.yr_perd_id,
             pel.acty_ref_perd_cd,
             ecr.acty_base_rt_id,
             --BUG 3191928
             epe.per_in_ler_id,
             epe.pgm_id,
             epe.pl_id,
             epe.oipl_id,
             pel.lee_rsn_id,
             pel.enrt_perd_id,
             pil.person_id,
             pil.lf_evt_ocrd_dt
             --END BUG 3191928
      from   ben_enrt_rt          ecr,
             ben_enrt_bnft        enb,
             ben_elig_per_elctbl_chc epe,
             ben_pil_elctbl_chc_popl pel,
             ben_per_in_ler pil
      where  ecr.enrt_rt_id = p_enrt_rt_id
      and    ecr.business_group_id = p_business_group_id
      and    decode(ecr.enrt_bnft_id, null, ecr.elig_per_elctbl_chc_id,
                    enb.elig_per_elctbl_chc_id) =
             epe.elig_per_elctbl_chc_id
      and    enb.enrt_bnft_id (+) = ecr.enrt_bnft_id
      and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
      and    pel.per_in_ler_id          = pil.per_in_ler_id
      and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
   --
   l_ecr    c_ecr%rowtype;
   --
   -- Get the popl_yr_perd record for program or plan.
   -- If plan is part of a program, get the popl_yr_perd for program.
   -- If plan not in program, get the pol_yr_perd for the plan.
   --
   cursor c_yrp is
      select yrp.end_date end_date,
             yrp.start_date start_date
      from   ben_yr_perd yrp
      where  yrp.yr_perd_id = l_yr_perd_id
      and    yrp.business_group_id = p_business_group_id;
   --
   l_yrp     c_yrp%rowtype;
   --
   --BUG 3191928 fixes
   --
   CURSOR c_pl_popl_yr_period_current IS
      SELECT   yp.end_date end_date,
               yp.start_date start_date
      FROM     ben_popl_yr_perd pyp,
               ben_yr_perd yp
      WHERE    pyp.pl_id = l_pl_id
      AND      pyp.yr_perd_id = yp.yr_perd_id
      AND      pyp.business_group_id = p_business_group_id
      AND      l_start_date between yp.start_date AND yp.end_date
      AND      yp.business_group_id = p_business_group_id ;
   --
   -- Parse Periods gets the information about the
   -- number of pay_periods by start date
   -- for the rate.
   -- 2164741
   --
   cursor c_parse_periods(v_payroll_id in number,
                          v_start_date in date,
                          v_end_date in date  ) is
        select min(ptp.start_date)
        from   per_time_periods ptp
        where  ptp.payroll_id     = v_payroll_id
          and  ptp.start_date between
               v_start_date and v_end_date;
   --

   cursor c_pgm_typ_cd(v_elig_per_elctbl_chc_id in number) is
   select pgm.pgm_typ_cd
   from   ben_pgm_f pgm,
          ben_elig_per_elctbl_chc epe
   where  epe.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
   and    pgm.pgm_id = epe.pgm_id
   and    p_effective_date between pgm.effective_start_date
          and pgm.effective_end_date;
   --
   --ICM Changes
   cursor c_opt_typ_cd(p_pl_typ_id number) is
   --
    select ptp.opt_typ_cd
    from   ben_pl_typ_f ptp
    where  ptp.pl_typ_id = p_pl_typ_id
     and   p_effective_date between ptp.effective_start_date
          and ptp.effective_end_date;
   --
   l_opt_typ_cd ben_pl_typ_f.opt_typ_cd%TYPE;
   --
   --ICM Changes
   l_batch_param_rec       benutils.g_batch_param_rec;
   l_year                  varchar2(30);
   l_pgm_typ_cd            ben_pgm_f.pgm_typ_cd%type;
   --
   l_benmngle_parm_rec    benutils.g_batch_param_rec;
   l_env_rec               ben_env_object.g_global_env_rec_type;
   --
begin
   --
  hr_utility.set_location('Entering '||l_package, 10);
   --
   g_debug := hr_utility.debug_enabled;
   --
   p_yr_start_date := p_start_date;
   --
  ben_env_object.get(p_rec => l_env_rec);
  benutils.get_batch_parameters(p_benefit_action_id => l_env_rec.benefit_action_id
                                ,p_rec => l_benmngle_parm_rec);
   --
   if p_start_date is null
     or p_end_date is null
     or p_acty_ref_perd_cd is null
     or p_complete_year_flag = 'Y'
   then
     --
     if p_enrt_rt_id is not null then
       --
       open  c_ecr;
       fetch c_ecr into l_ecr;
       --
       if c_ecr%notfound then
         --
         close c_ecr;
         fnd_message.set_name('BEN','BEN_91825_ENRT_RT_NOT_FOUND');
         fnd_message.set_token('PROC',l_package);
         fnd_message.set_token('ENRT_RT_ID',to_char(p_enrt_rt_id));
         fnd_message.set_token('BG_ID',to_char(p_business_group_id));
         fnd_message.raise_error;
         --
       else
         --
         close c_ecr;
         l_elig_per_elctbl_chc_id := l_ecr.elig_per_elctbl_chc_id;
         --
       end if;
       --
       l_elig_per_elctbl_chc_id := l_ecr.elig_per_elctbl_chc_id;
       l_acty_ref_perd_cd       := l_ecr.acty_ref_perd_cd;
       l_start_date             := l_ecr.rt_strt_dt;
       l_start_date_cd          := l_ecr.rt_strt_dt_cd;
       l_start_date_rl          := l_ecr.rt_strt_dt_rl;
       l_enrt_perd_start_dt     := l_ecr.enrt_perd_strt_dt;
       l_yr_perd_id             := l_ecr.yr_perd_id;
       l_acty_base_rt_id        := l_ecr.acty_base_rt_id;
       --BUG 3191928
       l_per_in_ler_id          := l_ecr.per_in_ler_id;
       l_pgm_id                 := l_ecr.pgm_id;
       l_pl_id                  := l_ecr.pl_id;
       l_oipl_id                := l_ecr.oipl_id;
       l_lee_rsn_id             := l_ecr.lee_rsn_id;
       l_enrt_perd_id           := l_ecr.enrt_perd_id;
       l_person_id              := l_ecr.person_id;
       l_lf_evt_ocrd_dt         := l_ecr.lf_evt_ocrd_dt;
       --
     --
     -- Check if the epe context global is set
     --
     elsif ben_epe_cache.g_currepe_row.elig_per_elctbl_chc_id is not null
     then
       --
       l_elig_per_elctbl_chc_id := ben_epe_cache.g_currepe_row.elig_per_elctbl_chc_id;
       l_acty_ref_perd_cd       := ben_epe_cache.g_currepe_row.acty_ref_perd_cd;
       l_start_date             := ben_epe_cache.g_currepe_row.enrt_cvg_strt_dt;
       l_start_date_cd          := ben_epe_cache.g_currepe_row.enrt_cvg_strt_dt_cd;
       l_start_date_rl          := ben_epe_cache.g_currepe_row.enrt_cvg_strt_dt_rl;
       l_enrt_perd_start_dt     := ben_epe_cache.g_currepe_row.enrt_perd_strt_dt;
       l_yr_perd_id             := ben_epe_cache.g_currepe_row.yr_perd_id;
       --
       l_per_in_ler_id          := ben_epe_cache.g_currepe_row.per_in_ler_id;
       l_pgm_id                 := ben_epe_cache.g_currepe_row.pgm_id;
       l_pl_id                  := ben_epe_cache.g_currepe_row.pl_id;
       l_oipl_id                := ben_epe_cache.g_currepe_row.oipl_id;
       l_lee_rsn_id             := ben_epe_cache.g_currepe_row.lee_rsn_id;
       l_enrt_perd_id           := ben_epe_cache.g_currepe_row.enrt_perd_id;
       l_person_id              := ben_epe_cache.g_currepe_row.person_id;
       l_lf_evt_ocrd_dt         := ben_epe_cache.g_currepe_row.lf_evt_ocrd_dt;
       --
     elsif p_elig_per_elctbl_chc_id is not null then
       --
       open c_epe;
       fetch c_epe into l_epe;
       --
       if c_epe%notfound then
         --
         close c_epe;
         --  hr_utility.set_location('BEN_91457_ELCTBL_CHC_NOT_FOUND ID:'||
         --      to_char(p_elig_per_elctbl_chc_id), 50);
         fnd_message.set_name('BEN','BEN_91457_ELCTBL_CHC_NOT_FOUND');
         fnd_message.set_token('ID',to_char(p_elig_per_elctbl_chc_id));
         fnd_message.set_token('PROC',l_package);
         fnd_message.raise_error;
         --
       else
         --
         close c_epe;
         --
       end if;
       --
       l_acty_ref_perd_cd       := l_epe.acty_ref_perd_cd;
       l_start_date             := l_epe.enrt_cvg_strt_dt;
       l_start_date_cd          := l_epe.enrt_cvg_strt_dt_cd;
       l_start_date_rl          := l_epe.enrt_cvg_strt_dt_rl;
       l_enrt_perd_start_dt     := l_epe.enrt_perd_strt_dt;
       l_yr_perd_id             := l_epe.yr_perd_id;
       l_elig_per_elctbl_chc_id := p_elig_per_elctbl_chc_id;
       --
       l_per_in_ler_id          := l_epe.per_in_ler_id;
       l_pgm_id                 := l_epe.pgm_id;
       l_pl_id                  := l_epe.pl_id;
       l_oipl_id                := l_epe.oipl_id;
       l_lee_rsn_id             := l_epe.lee_rsn_id;
       l_enrt_perd_id           := l_epe.enrt_perd_id;
       l_person_id              := l_epe.person_id;
       l_lf_evt_ocrd_dt         := l_epe.lf_evt_ocrd_dt;
       --
     else
       --
     --  hr_utility.set_location('BEN_91884_CHC_N_RT_NOT_FOUND:', 50);
       fnd_message.set_name('BEN','BEN_91884_CHC_N_RT_NOT_FOUND');
       fnd_message.set_token('PROC',l_package);
       fnd_message.raise_error;
       --
     end if;
     --
   --end if;
   --
   --BUG 3191928 Determining the rate start date to make sure we are determining the
   --right year periods.
   --
     if l_start_date is null then
       --
       ben_determine_date.rate_and_coverage_dates
       (p_which_dates_cd         => 'R'
       ,p_date_mandatory_flag    => 'N'
       ,p_compute_dates_flag     => 'Y'
       ,p_business_group_id      => p_business_group_id
       ,P_PER_IN_LER_ID          => l_per_in_ler_id
       ,P_PERSON_ID              => l_person_id
       ,P_PGM_ID                 => l_pgm_id
       ,P_PL_ID                  => l_pl_id
       ,P_OIPL_ID                => l_oipl_id
       ,P_LEE_RSN_ID             => l_lee_rsn_id
       ,P_ENRT_PERD_ID           => l_enrt_perd_id
       ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt
       ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd
       ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl
       ,p_rt_strt_dt             => l_start_date -- l_rt_strt_dt
       ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
       ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
       ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt
       ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd
       ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl
       ,p_rt_end_dt              => l_rt_end_dt
       ,p_rt_end_dt_cd           => l_rt_end_dt_cd
       ,p_rt_end_dt_rl           => l_rt_end_dt_rl
       ,p_effective_date         => p_effective_date
       ,p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt
       );
     --
     end if;
     --
   end if;
   --
   if p_end_date is null or
      p_complete_year_flag = 'Y' or
      p_yr_start_date is null then
      --
      open c_yrp;
      fetch c_yrp into l_yrp;
      --
      if c_yrp%notfound and l_benmngle_parm_rec.mode_cd <> 'D' then --ICM Changes
         --
         close c_yrp;
       --  hr_utility.set_location('BEN_91334_PLAN_YR_PERD', 50);

         -- GRADE/STEP Do not throw error for GSP programs
         -- Use the Start and End Dates of the year in which
         -- the Effective Date falls

             open c_pgm_typ_cd(l_elig_per_elctbl_chc_id);
             fetch c_pgm_typ_cd into l_pgm_typ_cd;
             if c_pgm_typ_cd%notfound then
               l_pgm_typ_cd := null;
             end if;
             close c_pgm_typ_cd;
             if l_pgm_typ_cd ='GSP' then
               --
               l_year := TO_CHAR(p_effective_date,'YYYY');
               l_yrp.start_date := TO_DATE('1/1/'||l_year,'MM/DD/YYYY');
               l_yrp.end_date   := TO_DATE('12/31/'||l_year,'MM/DD/YYYY');
               --
             else
               --
               fnd_message.set_name('BEN','BEN_91334_PLAN_YR_PERD');
               fnd_message.set_token('PROC',l_package);
               fnd_message.raise_error;
               --
             end if;
         --
      end if;
      --BUG 3191928 fixes
      if l_yrp.end_date < l_start_date then
         hr_utility.set_location('strt dt is'||to_char(l_start_date),123);
         open c_pl_popl_yr_period_current;
         fetch c_pl_popl_yr_period_current into l_yrp;
         close c_pl_popl_yr_period_current;
      end if;
      --
      p_yr_start_date := l_yrp.start_date;
      p_end_date      := l_yrp.end_date;
      --
      if p_complete_year_flag = 'Y' then
         --
         p_start_date := l_yrp.start_date;
         hr_utility.set_location('strt dt is'||to_char(p_start_date),123);
         --
      end if;
      --
   end if;
   --
   -- Bug 2164741 we are getting the first enrt_cvg_strt_dt from
   -- epe which is causing this problem.
   -- To avoid this if p_complete_year_flag is 'N' and
   -- the start_date is less that the p_yr_start_date then we derive the start_date
   if p_complete_year_flag = 'N' and nvl(p_start_date,l_start_date) < p_yr_start_date  then
     --
     if g_debug then
       hr_utility.set_location(' p_complete_year_flag =  N ',123);
     end if;
     if p_acty_ref_perd_cd = 'PP' then
       --
       open c_parse_periods(p_payroll_id,p_yr_start_date,p_end_date  );
       fetch c_parse_periods into p_start_date ;
       close c_parse_periods ;
       --
     elsif p_acty_ref_perd_cd = 'MO' then
       --
       p_start_date := p_yr_start_date ;
       --
     end if;
     --
   end if;
   --
   hr_utility.set_location('IK RT STRT p_start_date'||p_start_date,111);
   if p_start_date is null then
      --
      if l_start_date is null then
         --
         -- Determine the start date using the codes and rules.
         --
         ben_determine_date.main(
           p_date_cd                => l_start_date_cd,
           p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id,
           p_business_group_id      => p_business_group_id,
           p_effective_date         => p_effective_date,
           p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
           p_formula_id             => l_start_date_rl,
           p_returned_date          => l_start_date,
           p_acty_base_rt_id        => l_acty_base_rt_id,
           p_start_date             => l_enrt_perd_start_dt);
         --
      end if;
      --
      p_start_date := l_start_date;
      --
   end if;
   --Bug 2151055
   hr_utility.set_location('IK RT STRT p_start_date'||p_start_date,112);
   --
   if p_start_date > p_end_date and p_yr_start_date < p_start_date then
     --
     p_start_date := p_yr_start_date ;
     --
   end if ;
   --
   --
   if p_acty_ref_perd_cd is null then
      --
      p_acty_ref_perd_cd := l_acty_ref_perd_cd;
      --
   end if;
   --
 --  hr_utility.set_location('Leaving '||l_package , 99);
   --
exception
   --
   when others then
      if g_debug then
        hr_utility.set_location('WHEN OTHERS: '||l_package, 100);
      end if;
      p_start_date := l_start_date_nc_buffer;  -- no copy changes
      p_end_date := l_end_date_nc_buffer;      -- no copy changes
      p_yr_start_date := null; -- no copy changes
      fnd_message.raise_error;
   --
end set_default_dates;
--
---------------------------------------------------------------------------
-- This function is used to convert the period amount to annual amount
-- The annual period is computed as the period between the start date
-- and end date. When the complete year flag is on, the start date and
-- end date are overridden by plan year start and end date respectively.
---------------------------------------------------------------------------
-- !!! THIS IS OVERLOADED - MAKE CHANGES IN BOTH THE FUNCTIONS !!!
--------------------------------------------------------------------------
function period_to_annual(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null)
return number
is
   --
   l_hv                   pls_integer;
   --
   l_period_amt           number := p_amount;
   l_balance_amt          number := 0;
   l_annual_amt           number := 0;
   l_start_date           date   := p_start_date;
   l_end_date             date   := p_end_date;
   l_yr_start_date        date   := null;
   l_acty_ref_perd_cd     varchar2(30) := p_acty_ref_perd_cd;
   l_no_of_periods        number := 1;
   l_package varchar2(80) := g_package || '.period_to_annual';
   l_cmplt_yr_flag        varchar2(20) := p_complete_year_flag;
   --
   cursor c_cd is
     select
            abr.det_pl_ytd_cntrs_cd
     from   ben_enrt_rt        ecr,
            ben_acty_base_rt_f abr
     where  ecr.enrt_rt_id        = p_enrt_rt_id
     and    ecr.business_group_id = p_business_group_id
     and    ecr.acty_base_rt_id   = abr.acty_base_rt_id
     and    p_effective_date between
            abr.effective_start_date and abr.effective_end_date;

      --Added for Bug 6913654
      ---no need to get the value from ben_enrt_rt as it fetches "0",if cvg is
      ---enterable and rate is multiple of coverage,Bug 7196470
     /* cursor c_get_cmmd_amt is
           select cmcd_val
	    from  ben_enrt_rt        ecr
	     where  ecr.enrt_rt_id        = p_enrt_rt_id
	     and    ecr.business_group_id = p_business_group_id; */

     l_cd   ben_acty_base_rt_f.det_pl_ytd_cntrs_cd%TYPE := null;
     l_call_balance         boolean;
     --End of code for Bug 6913654

begin
  --
--  hr_utility.set_location('Entering '||l_package, 10);
  --
  -- Check for a null amount. Assumption is that a calculation
  -- cannot be performed on a null amount.
  --
  if p_amount is null then
    --
    return null;
    --
  end if;
  --
  if g_period_to_annual_cached > 0 then
    --
    begin
      --
      l_hv := mod(nvl(p_amount,1)
                 +nvl(p_enrt_rt_id,2)
                 +nvl(p_elig_per_elctbl_chc_id,3)
                 +nvl(p_start_date-hr_api.g_sot,4)
                 +nvl(p_end_date-hr_api.g_sot,5)
                 +nvl(p_payroll_id,6)
                 +nvl(p_element_type_id,7)
                 ,ben_hash_utility.get_hash_key);
      --
      if nvl(g_period_to_annual_cache(l_hv).amount,-1) = nvl(p_amount,-1)
        and nvl(g_period_to_annual_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
        and nvl(g_period_to_annual_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
        and nvl(g_period_to_annual_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
        and nvl(g_period_to_annual_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
        and nvl(g_period_to_annual_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
        and nvl(g_period_to_annual_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
        and nvl(g_period_to_annual_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
        and nvl(g_period_to_annual_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
        and nvl(g_period_to_annual_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
        and nvl(g_period_to_annual_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
        and nvl(g_period_to_annual_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
        and nvl(g_period_to_annual_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
      then
        --
        null;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
        loop
          --
          if nvl(g_period_to_annual_cache(l_hv).amount,-1) = nvl(p_amount,-1)
            and nvl(g_period_to_annual_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
            and nvl(g_period_to_annual_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
            and nvl(g_period_to_annual_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
            and nvl(g_period_to_annual_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
            and nvl(g_period_to_annual_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
            and nvl(g_period_to_annual_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
            and nvl(g_period_to_annual_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
            and nvl(g_period_to_annual_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
            and nvl(g_period_to_annual_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
            and nvl(g_period_to_annual_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
            and nvl(g_period_to_annual_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
            and nvl(g_period_to_annual_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
          then
            --
            exit;
            --
          else
            --
            l_hv := l_hv+g_hash_jump;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    exception
      when no_data_found then
        --
        l_hv := null;
    end;
    --
    if l_hv is not null then
      --
      return g_period_to_annual_cache(l_hv).annual_amt;
      --
    end if;
    --
  end if;
  --
  if p_use_balance_flag = 'Y' then
    l_call_balance := true;
    if p_enrt_rt_id is not null then
      open  c_cd;
      fetch c_cd into l_cd;
      close c_cd;
      if l_cd is null then
        l_call_balance := false;
      else
        l_cmplt_yr_flag := 'N';
      end if;
    end if;
  end if;
  --
  set_default_dates(p_enrt_rt_id       => p_enrt_rt_id,
                    p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                    p_business_group_id  => p_business_group_id,
                    p_complete_year_flag => l_cmplt_yr_flag,
                    p_effective_date     => p_effective_date,
                    p_payroll_id         => p_payroll_id,
                    p_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt,
                    p_start_date         => l_start_date,
                    p_end_date           => l_end_date,
                    p_acty_ref_perd_cd   => l_acty_ref_perd_cd,
                    p_yr_start_date      => l_yr_start_date);
  --
  -- Compute balances only if use_balance_flag is ON.
  --
  if l_call_balance then
    --
    l_balance_amt := get_balance
                     (p_enrt_rt_id        => p_enrt_rt_id,
                      p_payroll_id        => p_payroll_id,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_start_date        => l_yr_start_date);
    --
  end if;
  --
  if l_acty_ref_perd_cd = 'PYR' then
    --
    -- If Annually, don't need to get number of periods.
    --
    l_no_of_periods := 1;
    --
  else
    --
           --Bug 6913654, for estimate only rates no of periods should be calculated based on the remaining
	   --Per Pay periods. Get the communicated amount and multiply it with the periods obtained to get the
	   --amount to be paid for the remaining periods.
	    if l_cd = 'ESTONLY' then
                       l_no_of_periods := get_periods_between
					 (p_acty_ref_perd_cd => 'PP',
					  p_start_date       => l_start_date,
					  p_end_date         => l_end_date,
					  p_payroll_id       => p_payroll_id,
					  p_business_group_id => p_business_group_id,
					  p_enrt_rt_id       => p_enrt_rt_id,
					  p_element_type_id  => p_element_type_id,
					  p_effective_date   => p_effective_date
			);
		        --hr_utility.set_location('Inside period ESTONLY periods: '||l_no_of_periods, 9999);
			--hr_utility.set_location('Inside period ESTONLY enrt_id: '||p_enrt_rt_id, 9999);
		        ---Bug 7196470
		      /*  open c_get_cmmd_amt ;
		        fetch c_get_cmmd_amt into l_period_amt;
		        close c_get_cmmd_amt;*/
		        --hr_utility.set_location('Inside period ESTONLY amt: '||l_period_amt, 9999);
	    else
    l_no_of_periods := get_periods_between
                         (p_acty_ref_perd_cd => l_acty_ref_perd_cd,
                          p_start_date       => l_start_date,
                          p_end_date         => l_end_date,
                          p_payroll_id       => p_payroll_id,
                          p_business_group_id => p_business_group_id,
                          p_enrt_rt_id       => p_enrt_rt_id,
                          p_element_type_id  => p_element_type_id,
                          p_effective_date   => p_effective_date
    );
            end if;
    --
  end if;
  --
  l_annual_amt := (l_period_amt * l_no_of_periods) + l_balance_amt;
--  hr_utility.set_location('perd amt '||to_char(l_period_amt), 11);
--  hr_utility.set_location('perd no '||to_char(l_no_of_periods), 11);
--  hr_utility.set_location('bal amt '||to_char(l_balance_amt), 11);
  --
  l_annual_amt := round(l_annual_amt,2);
  --
  if g_period_to_annual_cached > 0 then
    --
    -- Only store the
    --
    l_hv := mod(nvl(p_amount,1)
               +nvl(p_enrt_rt_id,2)
               +nvl(p_elig_per_elctbl_chc_id,3)
               +nvl(p_start_date-hr_api.g_sot,4)
               +nvl(p_end_date-hr_api.g_sot,5)
               +nvl(p_payroll_id,6)
               +nvl(p_element_type_id,7)
               ,ben_hash_utility.get_hash_key);
    --
    while g_period_to_annual_cache.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    g_period_to_annual_cache(l_hv).amount                  := p_amount;
    g_period_to_annual_cache(l_hv).enrt_rt_id              := p_enrt_rt_id;
    g_period_to_annual_cache(l_hv).elig_per_elctbl_chc_id  := p_elig_per_elctbl_chc_id;
    g_period_to_annual_cache(l_hv).acty_ref_perd_cd        := p_acty_ref_perd_cd;
    g_period_to_annual_cache(l_hv).business_group_id       := p_business_group_id;
    g_period_to_annual_cache(l_hv).effective_date          := p_effective_date;
    g_period_to_annual_cache(l_hv).lf_evt_ocrd_dt          := p_lf_evt_ocrd_dt;
    g_period_to_annual_cache(l_hv).complete_year_flag      := p_complete_year_flag;
    g_period_to_annual_cache(l_hv).use_balance_flag        := p_use_balance_flag;
    g_period_to_annual_cache(l_hv).start_date              := p_start_date;
    g_period_to_annual_cache(l_hv).end_date                := p_end_date;
    g_period_to_annual_cache(l_hv).payroll_id              := p_payroll_id;
    g_period_to_annual_cache(l_hv).element_type_id         := p_element_type_id;
    g_period_to_annual_cache(l_hv).annual_amt              := l_annual_amt;
    --
  end if;
  --
--  hr_utility.set_location('Leaving '||l_package , 90);
  --
  return(l_annual_amt);
  --
exception
   --
   when others then
      fnd_message.raise_error;
   --
end period_to_annual;

--
---------------------------------------------------------------------------
-- This function is used to convert the period amount to annual amount
-- The annual period is computed as the period between the start date
-- and end date. When the complete year flag is on, the start date and
-- end date are overridden by plan year start and end date respectively.
---------------------------------------------------------------------------
-- !!! THIS IS OVERLOADED - MAKE CHANGES IN BOTH THE FUNCTIONS !!!
---------------------------------------------------------------------------
function period_to_annual(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_rounding_flag          in varchar2  )
return number
is
   --
   l_hv                   pls_integer;
   --
   l_period_amt           number := p_amount;
   l_balance_amt          number := 0;
   l_annual_amt           number := 0;
   l_start_date           date   := p_start_date;
   l_end_date             date   := p_end_date;
   l_yr_start_date        date   := null;
   l_acty_ref_perd_cd     varchar2(30) := p_acty_ref_perd_cd;
   l_no_of_periods        number := 1;
   l_package varchar2(80) := g_package || '.period_to_annual';
   l_cmplt_yr_flag        varchar2(20) := p_complete_year_flag;
   --
   cursor c_cd is
     select
            abr.det_pl_ytd_cntrs_cd
     from   ben_enrt_rt        ecr,
            ben_acty_base_rt_f abr
     where  ecr.enrt_rt_id        = p_enrt_rt_id
     and    ecr.business_group_id = p_business_group_id
     and    ecr.acty_base_rt_id   = abr.acty_base_rt_id
     and    p_effective_date between
            abr.effective_start_date and abr.effective_end_date;

  ---no need to get the value from ben_enrt_rt as it fetches "0",if cvg is
  ---enterable and rate is multiple of coverage,Bug 7196470
 /* cursor c_get_cmmd_amt is
           select cmcd_val
	    from  ben_enrt_rt        ecr
	     where  ecr.enrt_rt_id        = p_enrt_rt_id
	     and    ecr.business_group_id = p_business_group_id;*/

     l_cd   ben_acty_base_rt_f.det_pl_ytd_cntrs_cd%TYPE := null;
     l_call_balance         boolean;
begin
  --
--  hr_utility.set_location('Entering '||l_package, 10);
  --
  -- Check for a null amount. Assumption is that a calculation
  -- cannot be performed on a null amount.
  --
  if p_amount is null then
    --
    return null;
    --
  end if;
  --
  if g_period_to_annual_cached > 0 then
    --
    begin
      --
      l_hv := mod(nvl(p_amount,1)
                 +nvl(p_enrt_rt_id,2)
                 +nvl(p_elig_per_elctbl_chc_id,3)
                 +nvl(p_start_date-hr_api.g_sot,4)
                 +nvl(p_end_date-hr_api.g_sot,5)
                 +nvl(p_payroll_id,6)
                 +nvl(p_element_type_id,7)
                 ,ben_hash_utility.get_hash_key);
      --
      if nvl(g_period_to_annual_cache(l_hv).amount,-1) = nvl(p_amount,-1)
        and nvl(g_period_to_annual_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
        and nvl(g_period_to_annual_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
        and nvl(g_period_to_annual_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
        and nvl(g_period_to_annual_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
        and nvl(g_period_to_annual_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
        and nvl(g_period_to_annual_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
        and nvl(g_period_to_annual_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
        and nvl(g_period_to_annual_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
        and nvl(g_period_to_annual_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
        and nvl(g_period_to_annual_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
        and nvl(g_period_to_annual_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
        and nvl(g_period_to_annual_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
      then
        --
        null;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
        loop
          --
          if nvl(g_period_to_annual_cache(l_hv).amount,-1) = nvl(p_amount,-1)
            and nvl(g_period_to_annual_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
            and nvl(g_period_to_annual_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
            and nvl(g_period_to_annual_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
            and nvl(g_period_to_annual_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
            and nvl(g_period_to_annual_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
            and nvl(g_period_to_annual_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
            and nvl(g_period_to_annual_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
            and nvl(g_period_to_annual_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
            and nvl(g_period_to_annual_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
            and nvl(g_period_to_annual_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
            and nvl(g_period_to_annual_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
            and nvl(g_period_to_annual_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
          then
            --
            exit;
            --
          else
            --
            l_hv := l_hv+g_hash_jump;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    exception
      when no_data_found then
        --
        l_hv := null;
    end;
    --
    if l_hv is not null then
      --
      return g_period_to_annual_cache(l_hv).annual_amt;
      --
    end if;
    --
  end if;
  --
  if p_use_balance_flag = 'Y' then
    l_call_balance := true;
    if p_enrt_rt_id is not null then
      open  c_cd;
      fetch c_cd into l_cd;
      close c_cd;
      if l_cd is null then
        l_call_balance := false;
      else
        l_cmplt_yr_flag := 'N';
      end if;
    end if;
  end if;
  --
  set_default_dates(p_enrt_rt_id       => p_enrt_rt_id,
                    p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                    p_business_group_id  => p_business_group_id,
                    p_complete_year_flag => l_cmplt_yr_flag,
                    p_effective_date     => p_effective_date,
                    p_payroll_id         => p_payroll_id,
                    p_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt,
                    p_start_date         => l_start_date,
                    p_end_date           => l_end_date,
                    p_acty_ref_perd_cd   => l_acty_ref_perd_cd,
                    p_yr_start_date      => l_yr_start_date);
  --
  -- Compute balances only if use_balance_flag is ON.
  --
  if l_call_balance then
    --
    l_balance_amt := get_balance
                     (p_enrt_rt_id        => p_enrt_rt_id,
                      p_payroll_id        => p_payroll_id,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_start_date        => l_yr_start_date);
    --
  end if;
  --
  if l_acty_ref_perd_cd = 'PYR' then
    --
    -- If Annually, don't need to get number of periods.
    --
    l_no_of_periods := 1;
    --
  else
    --
           --Bug 6913654, for estimate only rates no of periods should be calculated based on the remaining
	   --Per Pay periods. Get the communicated amount and multiply it with the periods obtained to get the
	   --amount to be paid for the remaining periods.
            if l_cd = 'ESTONLY' then
	              l_no_of_periods := get_periods_between
					 (p_acty_ref_perd_cd => 'PP',
					  p_start_date       => l_start_date,
					  p_end_date         => l_end_date,
					  p_payroll_id       => p_payroll_id,
					  p_business_group_id => p_business_group_id,
					  p_enrt_rt_id       => p_enrt_rt_id,
					  p_element_type_id  => p_element_type_id,
					  p_effective_date   => p_effective_date
			);
		        --hr_utility.set_location('Inside period ETONLY periods: '||l_no_of_periods, 9999);
			--hr_utility.set_location('Inside period ETONLY enrt_id: '||p_enrt_rt_id, 9999);
		    	---Bug 7196470
		      /*  open c_get_cmmd_amt ;
		        fetch c_get_cmmd_amt into l_period_amt;
		        close c_get_cmmd_amt;*/
		        --hr_utility.set_location('Inside period ETONLY amt: '||l_period_amt, 9999);
	    else
    l_no_of_periods := get_periods_between
                         (p_acty_ref_perd_cd => l_acty_ref_perd_cd,
                          p_start_date       => l_start_date,
                          p_end_date         => l_end_date,
                          p_payroll_id       => p_payroll_id,
                          p_business_group_id => p_business_group_id,
                          p_enrt_rt_id       => p_enrt_rt_id,
                          p_element_type_id  => p_element_type_id,
                          p_effective_date   => p_effective_date
    );
           end if;
    --
  end if;
  --
  l_annual_amt := (l_period_amt * l_no_of_periods) + l_balance_amt;
--  hr_utility.set_location('perd amt '||to_char(l_period_amt), 11);
--  hr_utility.set_location('perd no '||to_char(l_no_of_periods), 11);
--  hr_utility.set_location('bal amt '||to_char(l_balance_amt), 11);
  --
  if p_rounding_flag = 'Y' then
    --
    l_annual_amt := round(l_annual_amt,2);
    --
  end if;
  --
  if g_period_to_annual_cached > 0 then
    --
    -- Only store the
    --
    l_hv := mod(nvl(p_amount,1)
               +nvl(p_enrt_rt_id,2)
               +nvl(p_elig_per_elctbl_chc_id,3)
               +nvl(p_start_date-hr_api.g_sot,4)
               +nvl(p_end_date-hr_api.g_sot,5)
               +nvl(p_payroll_id,6)
               +nvl(p_element_type_id,7)
               ,ben_hash_utility.get_hash_key);
    --
    while g_period_to_annual_cache.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    g_period_to_annual_cache(l_hv).amount                  := p_amount;
    g_period_to_annual_cache(l_hv).enrt_rt_id              := p_enrt_rt_id;
    g_period_to_annual_cache(l_hv).elig_per_elctbl_chc_id  := p_elig_per_elctbl_chc_id;
    g_period_to_annual_cache(l_hv).acty_ref_perd_cd        := p_acty_ref_perd_cd;
    g_period_to_annual_cache(l_hv).business_group_id       := p_business_group_id;
    g_period_to_annual_cache(l_hv).effective_date          := p_effective_date;
    g_period_to_annual_cache(l_hv).lf_evt_ocrd_dt          := p_lf_evt_ocrd_dt;
    g_period_to_annual_cache(l_hv).complete_year_flag      := p_complete_year_flag;
    g_period_to_annual_cache(l_hv).use_balance_flag        := p_use_balance_flag;
    g_period_to_annual_cache(l_hv).start_date              := p_start_date;
    g_period_to_annual_cache(l_hv).end_date                := p_end_date;
    g_period_to_annual_cache(l_hv).payroll_id              := p_payroll_id;
    g_period_to_annual_cache(l_hv).element_type_id         := p_element_type_id;
    g_period_to_annual_cache(l_hv).annual_amt              := l_annual_amt;
    --
  end if;
  --
--  hr_utility.set_location('Leaving '||l_package , 90);
  --
  return(l_annual_amt);
  --
exception
   --
   when others then
      fnd_message.raise_error;
   --
end period_to_annual;

--

--
---------------------------------------------------------------------------
-- This function is used to convert the annual amount to period amount
-- The annual period is computed as the period between the start date
-- and end date. When the complete year flag is on, the start date and
-- end date are overridden by plan year start and end date respectively.
---------------------------------------------------------------------------
-- !!! THIS IS OVERLOADED - MAKE CHANGES IN BOTH THE FUNCTIONS !!!
---------------------------------------------------------------------------
function annual_to_period(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_annual_target          in boolean default false,
                          p_person_id              in number  default null)
return number is
   --
   l_hv                   pls_integer;
   --
   l_period_amt           number := 0;
   l_balance_amt          number := 0;
   l_annual_amt           number := p_amount;
   l_no_of_periods        number := 1;
   l_start_date           date   := p_start_date;
   l_end_date             date   := p_end_date;
   l_yr_start_date        date   := null;
   l_acty_ref_perd_cd     varchar2(30) := p_acty_ref_perd_cd;
   l_package varchar2(80) := g_package || '.annual_to_period';
   l_cmplt_yr_flag        varchar2(20) := p_complete_year_flag;
   --
   cursor c_cd is
     select
            abr.det_pl_ytd_cntrs_cd,
            abr.entr_ann_val_flag,
            abr.rt_mlt_cd
     from   ben_enrt_rt        ecr,
            ben_acty_base_rt_f abr
     where  ecr.enrt_rt_id        = p_enrt_rt_id
     and    ecr.business_group_id = p_business_group_id
     and    ecr.acty_base_rt_id   = abr.acty_base_rt_id
     and    p_effective_date between
            abr.effective_start_date and abr.effective_end_date;
     --
   l_prnt_ann_rt   varchar2(1):= 'N';
      --
     cursor c_payroll (p_payroll_id number,
                       p_effective_date date) is
       select pay_date_offset
       from   pay_all_payrolls_f prl
       where  prl.payroll_id = p_payroll_id
       and    p_effective_date between prl.effective_start_date
              and prl.effective_end_date;
   --
     cursor c_first_payroll (p_person_id number,
                             p_effective_date date) is
       select payroll_id
       from   per_all_assignments_f ass
       where  ass.person_id = p_person_id
       and    ass.primary_flag = 'Y'
       and    ass.assignment_type <> 'C'
       and    p_effective_date between ass.effective_start_date
              and ass.effective_end_date
       order  by decode(ass.assignment_type, 'E',1,'B',2,3);




     l_cd   ben_acty_base_rt_f.det_pl_ytd_cntrs_cd%TYPE := null;
     l_entr_ann_val_flag       varchar2(30);
     l_rt_mlt_cd               varchar2(30);
     l_call_balance            boolean;
     l_pay_date_offset         number;
     l_first_payroll_id        number;
     l_first_pay_date_offset   number;
     l_start_date_check        date;
   --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering '||l_package, 10);
  end if;
  hr_utility.set_location('Annual Amount in Annual to Period '||p_amount, 10);
  --
  -- Check for a null amount. Assumption is that a calculation
  -- cannot be performed on a null amount.
  --
  if p_amount is null then
    --
    return null;
    --
  end if;
  --
  open c_payroll (p_payroll_id, p_effective_date);
  fetch c_payroll into l_pay_date_offset;
  close c_payroll;
  --
  if g_annual_to_period_cached > 0 then
    --
    begin
      --
      l_hv := mod(nvl(p_amount,1)
                 +nvl(p_enrt_rt_id,2)
                 +nvl(p_elig_per_elctbl_chc_id,3)
                 +nvl(p_start_date-hr_api.g_sot,4)
                 +nvl(p_end_date-hr_api.g_sot,5)
                 +nvl(p_payroll_id,6)
                 +nvl(p_element_type_id,7)
                 ,ben_hash_utility.get_hash_key);
      --
      if nvl(g_annual_to_period_cache(l_hv).amount,-1) = nvl(p_amount,-1)
        and nvl(g_annual_to_period_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
      then
        --
        null;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
        loop
          --
          if nvl(g_annual_to_period_cache(l_hv).amount,-1) = nvl(p_amount,-1)
            and nvl(g_annual_to_period_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
          then
            --
            exit;
            --
          else
            --
            l_hv := l_hv+g_hash_jump;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    exception
      when no_data_found then
        --
        l_hv := null;
    end;
    --
    if l_hv is not null then
      --
      return g_annual_to_period_cache(l_hv).period_amt;
      --
    end if;
    --
  end if;
  --
  if p_use_balance_flag = 'Y' then
    l_call_balance := true;
    if p_enrt_rt_id is not null then
      open  c_cd;
      fetch c_cd into l_cd, l_entr_ann_val_flag,l_rt_mlt_cd;
      close c_cd;
      if l_cd is null then
         if l_rt_mlt_cd = 'PRNT' then
            l_cmplt_yr_flag := 'N';
            l_prnt_ann_rt   := 'Y';
         else
           l_call_balance := false;
         end if;
     --   l_call_balance := false;
      else
        l_cmplt_yr_flag := 'N';
      end if;
    end if;
  end if;
  --
  set_default_dates(p_enrt_rt_id         => p_enrt_rt_id,
                   p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                   p_business_group_id  => p_business_group_id,
                   p_complete_year_flag => l_cmplt_yr_flag,
                   p_effective_date     => p_effective_date,
                   p_payroll_id         => p_payroll_id,
                   p_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt,
                   p_start_date         => l_start_date,
                   p_end_date           => l_end_date,
                   p_acty_ref_perd_cd   => l_acty_ref_perd_cd,
                   p_yr_start_date      => l_yr_start_date);
  --
  -- Compute balances only if use_balance_flag is ON.
  --
  -- bug#3510633
  if (l_entr_ann_val_flag = 'Y' or l_rt_mlt_cd = 'SAREC' or
      p_annual_target or l_prnt_ann_rt = 'Y') and
       p_person_id is not null then
     --
     open c_first_payroll (p_person_id, (l_yr_start_date - 1));
     fetch c_first_payroll into l_first_payroll_id;
     close c_first_payroll;
     --
     if l_first_payroll_id is not null then
       --
       open c_payroll(l_first_payroll_id, (l_yr_start_date - 1));
       fetch c_payroll into l_first_pay_date_offset;
       close c_payroll;
       --
     end if;
     --
   end if;

   --  	5642552 : Evem of check_offset is 0, start annual-rates as of the period start.
      -- l_first_pay_date_offset <> 0 and
    l_start_date_check := l_start_date;
    --
   if (l_entr_ann_val_flag = 'Y' or l_rt_mlt_cd = 'SAREC' or
       p_annual_target or l_prnt_ann_rt = 'Y') then
      --
     if p_start_date is not null and p_start_date < l_yr_start_date then
       --
       l_start_date_check :=  p_start_date;
       --
     else
        l_yr_start_date := l_yr_start_date - NVL(l_first_pay_date_offset,0); -- 5642552: Added NVL.
        l_start_date_check := l_start_date;
     end if;
       if g_debug then
         hr_utility.set_location('Pay Date Offset'||l_first_pay_date_offset,11);
       end if;
   end if;
   --

  if l_call_balance then
    --
    l_balance_amt := get_balance
                     (p_enrt_rt_id        => p_enrt_rt_id,
                      p_payroll_id        => p_payroll_id,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_start_date        => l_yr_start_date);
    --
  end if;
  --
  if l_acty_ref_perd_cd = 'PYR' then
    --
    -- If Annualy, don't need to get number of periods.
    --
    l_no_of_periods  := 1;
    --
  else
    if l_pay_date_offset <> 0 and (l_entr_ann_val_flag = 'Y' or l_rt_mlt_cd = 'SAREC' or
                                    p_annual_target or l_prnt_ann_rt = 'Y') then
       l_no_of_periods := get_periods_between
                         (p_acty_ref_perd_cd => l_acty_ref_perd_cd,
                          p_start_date       => nvl(l_start_date_check,l_start_date),
                          p_end_date         => l_end_date,
                          p_payroll_id       => p_payroll_id,
                          p_business_group_id => p_business_group_id,
                          p_enrt_rt_id       => p_enrt_rt_id,
                          p_element_type_id  => p_element_type_id,
                          p_effective_date   => p_effective_date,
                          p_use_check_date  => true
                          );

    --
    else
      --
      l_no_of_periods := get_periods_between
                         (p_acty_ref_perd_cd => l_acty_ref_perd_cd,
                          p_start_date       => l_start_date_check, -- 5642552: Replaced l_start_date.
                          p_end_date         => l_end_date,
                          p_payroll_id       => p_payroll_id,
                          p_business_group_id => p_business_group_id,
                          p_enrt_rt_id       => p_enrt_rt_id,
                          p_element_type_id  => p_element_type_id,
                          p_effective_date   => p_effective_date
                          );
    --
    end if;
    --
  end if;
  --
  l_period_amt := (l_annual_amt - l_balance_amt)/l_no_of_periods;
  hr_utility.set_location('Annual to Period Amount '||l_period_amt , 90);
  --
  l_period_amt := round(l_period_amt,2);
  --
  if g_annual_to_period_cached > 0 then
    --
    -- Only store the
    --
    l_hv := mod(nvl(p_amount,1)
               +nvl(p_enrt_rt_id,2)
               +nvl(p_elig_per_elctbl_chc_id,3)
               +nvl(p_start_date-hr_api.g_sot,4)
               +nvl(p_end_date-hr_api.g_sot,5)
               +nvl(p_payroll_id,6)
               +nvl(p_element_type_id,7)
               ,ben_hash_utility.get_hash_key);
    --
    while g_annual_to_period_cache.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    g_annual_to_period_cache(l_hv).amount                  := p_amount;
    g_annual_to_period_cache(l_hv).enrt_rt_id              := p_enrt_rt_id;
    g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id  := p_elig_per_elctbl_chc_id;
    g_annual_to_period_cache(l_hv).acty_ref_perd_cd        := p_acty_ref_perd_cd;
    g_annual_to_period_cache(l_hv).business_group_id       := p_business_group_id;
    g_annual_to_period_cache(l_hv).effective_date          := p_effective_date;
    g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt          := p_lf_evt_ocrd_dt;
    g_annual_to_period_cache(l_hv).complete_year_flag      := p_complete_year_flag;
    g_annual_to_period_cache(l_hv).use_balance_flag        := p_use_balance_flag;
    g_annual_to_period_cache(l_hv).start_date              := p_start_date;
    g_annual_to_period_cache(l_hv).end_date                := p_end_date;
    g_annual_to_period_cache(l_hv).payroll_id              := p_payroll_id;
    g_annual_to_period_cache(l_hv).element_type_id         := p_element_type_id;
    g_annual_to_period_cache(l_hv).period_amt              := l_period_amt;
    g_annual_to_period_cache(l_hv).pp_in_yr_used_num       := l_no_of_periods;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_package , 90);
  --
  return(l_period_amt);
  --
exception
   --
   when others then
      fnd_message.raise_error;
   --
end annual_to_period;
--
---------------------------------------------------------------------------
-- This function is used to convert the annual amount to period amount
-- The annual period is computed as the period between the start date
-- and end date. When the complete year flag is on, the start date and
-- end date are overridden by plan year start and end date respectively.
---------------------------------------------------------------------------
-- !!! THIS IS OVERLOADED - MAKE CHANGES IN BOTH THE FUNCTIONS !!!
---------------------------------------------------------------------------
function annual_to_period(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_annual_target          in boolean default false,
                          p_rounding_flag          in varchar2,
                          p_person_id              in number default null )
return number is
   --
   l_hv                   pls_integer;
   --
   l_period_amt           number := 0;
   l_balance_amt          number := 0;
   l_annual_amt           number := p_amount;
   l_no_of_periods        number := 1;
   l_start_date           date   := p_start_date;
   l_end_date             date   := p_end_date;
   l_yr_start_date        date   := null;
   l_acty_ref_perd_cd     varchar2(30) := p_acty_ref_perd_cd;
   l_package varchar2(80) := g_package || '.annual_to_period';
   l_cmplt_yr_flag        varchar2(20) := p_complete_year_flag;
   --
   cursor c_cd is
     select
            abr.det_pl_ytd_cntrs_cd,
            abr.entr_ann_val_flag,
            abr.rt_mlt_cd
     from   ben_enrt_rt        ecr,
            ben_acty_base_rt_f abr
     where  ecr.enrt_rt_id        = p_enrt_rt_id
     and    ecr.business_group_id = p_business_group_id
     and    ecr.acty_base_rt_id   = abr.acty_base_rt_id
     and    p_effective_date between
            abr.effective_start_date and abr.effective_end_date;
     --
   l_prnt_ann_rt   varchar2(1):= 'N';
      --
     cursor c_payroll (p_payroll_id number,
                       p_effective_date date) is
       select pay_date_offset
       from   pay_all_payrolls_f prl
       where  prl.payroll_id = p_payroll_id
       and    p_effective_date between prl.effective_start_date
              and prl.effective_end_date;
   --
    cursor c_first_payroll (p_person_id number,
                             p_effective_date date) is
       select payroll_id
       from   per_all_assignments_f ass
       where  ass.person_id = p_person_id
       and    ass.primary_flag = 'Y'
       and    ass.assignment_type <> 'C'
       and    p_effective_date between ass.effective_start_date
              and ass.effective_end_date
       order  by decode(ass.assignment_type, 'E',1,'B',2,3);


     l_cd   ben_acty_base_rt_f.det_pl_ytd_cntrs_cd%TYPE := null;
     l_entr_ann_val_flag       varchar2(30);
     l_rt_mlt_cd               varchar2(30);
     l_call_balance            boolean;
     l_pay_date_offset         number;
     l_first_payroll_id        number;
     l_first_pay_date_offset   number;
   --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering '||l_package, 10);
  end if;
  hr_utility.set_location('Annual Amount in Annual to Period '||p_amount, 10);

  --
  -- Check for a null amount. Assumption is that a calculation
  -- cannot be performed on a null amount.
  --
  if p_amount is null then
    --
    return null;
    --
  end if;
  --
  open c_payroll (p_payroll_id, p_effective_date);
  fetch c_payroll into l_pay_date_offset;
  close c_payroll;
  --
  if g_annual_to_period_cached > 0 then
    --
    begin
      --
      l_hv := mod(nvl(p_amount,1)
                 +nvl(p_enrt_rt_id,2)
                 +nvl(p_elig_per_elctbl_chc_id,3)
                 +nvl(p_start_date-hr_api.g_sot,4)
                 +nvl(p_end_date-hr_api.g_sot,5)
                 +nvl(p_payroll_id,6)
                 +nvl(p_element_type_id,7)
                 ,ben_hash_utility.get_hash_key);
      --
      if nvl(g_annual_to_period_cache(l_hv).amount,-1) = nvl(p_amount,-1)
        and nvl(g_annual_to_period_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
      then
        --
        null;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
        loop
          --
          if nvl(g_annual_to_period_cache(l_hv).amount,-1) = nvl(p_amount,-1)
            and nvl(g_annual_to_period_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
          then
            --
            exit;
            --
          else
            --
            l_hv := l_hv+g_hash_jump;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    exception
      when no_data_found then
        --
        l_hv := null;
    end;
    --
    if l_hv is not null then
      --
      return g_annual_to_period_cache(l_hv).period_amt;
      --
    end if;
    --
  end if;
  --
  if p_use_balance_flag = 'Y' then
    l_call_balance := true;
    if p_enrt_rt_id is not null then
      open  c_cd;
      fetch c_cd into l_cd, l_entr_ann_val_flag,l_rt_mlt_cd;
      close c_cd;
      if l_cd is null then
         if l_rt_mlt_cd = 'PRNT' then
            l_cmplt_yr_flag := 'N';
            l_prnt_ann_rt   := 'Y';
         else
           l_call_balance := false;
         end if;
     --   l_call_balance := false;
      else
        l_cmplt_yr_flag := 'N';
      end if;
    end if;
  end if;
  --
  set_default_dates(p_enrt_rt_id         => p_enrt_rt_id,
                   p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                   p_business_group_id  => p_business_group_id,
                   p_complete_year_flag => l_cmplt_yr_flag,
                   p_effective_date     => p_effective_date,
                   p_payroll_id         => p_payroll_id,
                   p_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt,
                   p_start_date         => l_start_date,
                   p_end_date           => l_end_date,
                   p_acty_ref_perd_cd   => l_acty_ref_perd_cd,
                   p_yr_start_date      => l_yr_start_date);
  --
  -- Compute balances only if use_balance_flag is ON.
  --
  -- bug#3510633
  if (l_entr_ann_val_flag = 'Y' or l_rt_mlt_cd = 'SAREC' or
                                    p_annual_target or l_prnt_ann_rt = 'Y') and
       p_person_id is not null then
     --
     open c_first_payroll (p_person_id, (l_yr_start_date - 1));
     fetch c_first_payroll into l_first_payroll_id;
     close c_first_payroll;
     --
     if l_first_payroll_id is not null then
       --
       open c_payroll(l_first_payroll_id, (l_yr_start_date - 1));
       fetch c_payroll into l_first_pay_date_offset;
       close c_payroll;
       --
     end if;
     --
   end if;
   --  	5642552 : Evem of check_offset is 0, start annual-rates as of the period start.
   -- l_first_pay_date_offset <> 0 and
    --
   if (l_entr_ann_val_flag = 'Y' or l_rt_mlt_cd = 'SAREC' or
       p_annual_target or l_prnt_ann_rt = 'Y') then
        --
        -- 5642552: Added this.
        if p_start_date is not null and p_start_date < l_yr_start_date then
            l_start_date :=  p_start_date;
        --Bug 9309878
      --  end if;
        -- 5642552: End.
        else
          l_yr_start_date := l_yr_start_date - NVL(l_first_pay_date_offset,0); -- 5642552: Added NVL.
        end if;
       --Bug 9309878
       if g_debug then
         hr_utility.set_location('Pay Date Offset'||l_pay_date_offset,11);
       end if;
   end if;
   --

  if l_call_balance then
    --
    l_balance_amt := get_balance
                     (p_enrt_rt_id        => p_enrt_rt_id,
                      p_payroll_id        => p_payroll_id,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_start_date        => l_yr_start_date);
    --
  end if;
  --
  if l_acty_ref_perd_cd = 'PYR' then
    --
    -- If Annualy, don't need to get number of periods.
    --
    l_no_of_periods  := 1;
    --
  else
    if l_pay_date_offset <> 0 and (l_entr_ann_val_flag = 'Y' or l_rt_mlt_cd = 'SAREC' or
                                    p_annual_target or l_prnt_ann_rt = 'Y') then
       l_no_of_periods := get_periods_between
                         (p_acty_ref_perd_cd => l_acty_ref_perd_cd,
                          p_start_date       => l_start_date,
                          p_end_date         => l_end_date,
                          p_payroll_id       => p_payroll_id,
                          p_business_group_id => p_business_group_id,
                          p_enrt_rt_id       => p_enrt_rt_id,
                          p_element_type_id  => p_element_type_id,
                          p_effective_date   => p_effective_date,
                          p_use_check_date  => true
                          );

    --
    else
      --
      l_no_of_periods := get_periods_between
                         (p_acty_ref_perd_cd => l_acty_ref_perd_cd,
                          p_start_date       => l_start_date,
                          p_end_date         => l_end_date,
                          p_payroll_id       => p_payroll_id,
                          p_business_group_id => p_business_group_id,
                          p_enrt_rt_id       => p_enrt_rt_id,
                          p_element_type_id  => p_element_type_id,
                          p_effective_date   => p_effective_date
                          );
    --
    end if;
    --
  end if;
  --
  l_period_amt := (l_annual_amt - l_balance_amt)/l_no_of_periods;
  --
  if p_rounding_flag = 'Y' then
    --
    l_period_amt := round(l_period_amt,2);
    --
  end if;
  --
  if g_annual_to_period_cached > 0 then
    --
    -- Only store the
    --
    l_hv := mod(nvl(p_amount,1)
               +nvl(p_enrt_rt_id,2)
               +nvl(p_elig_per_elctbl_chc_id,3)
               +nvl(p_start_date-hr_api.g_sot,4)
               +nvl(p_end_date-hr_api.g_sot,5)
               +nvl(p_payroll_id,6)
               +nvl(p_element_type_id,7)
               ,ben_hash_utility.get_hash_key);
    --
    while g_annual_to_period_cache.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    g_annual_to_period_cache(l_hv).amount                  := p_amount;
    g_annual_to_period_cache(l_hv).enrt_rt_id              := p_enrt_rt_id;
    g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id  := p_elig_per_elctbl_chc_id;
    g_annual_to_period_cache(l_hv).acty_ref_perd_cd        := p_acty_ref_perd_cd;
    g_annual_to_period_cache(l_hv).business_group_id       := p_business_group_id;
    g_annual_to_period_cache(l_hv).effective_date          := p_effective_date;
    g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt          := p_lf_evt_ocrd_dt;
    g_annual_to_period_cache(l_hv).complete_year_flag      := p_complete_year_flag;
    g_annual_to_period_cache(l_hv).use_balance_flag        := p_use_balance_flag;
    g_annual_to_period_cache(l_hv).start_date              := p_start_date;
    g_annual_to_period_cache(l_hv).end_date                := p_end_date;
    g_annual_to_period_cache(l_hv).payroll_id              := p_payroll_id;
    g_annual_to_period_cache(l_hv).element_type_id         := p_element_type_id;
    g_annual_to_period_cache(l_hv).period_amt              := l_period_amt;
    g_annual_to_period_cache(l_hv).pp_in_yr_used_num       := l_no_of_periods;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_package , 90);
  --
  return(l_period_amt);
  --
exception
   --
   when others then
      fnd_message.raise_error;
   --
end annual_to_period;
function annual_to_period_out(p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_pp_in_yr_used_num      out nocopy number)
return number is
   --
   l_hv                   pls_integer;
   --
   l_period_amt           number := 0;
   l_balance_amt          number := 0;
   l_annual_amt           number := p_amount;
   l_no_of_periods        number := 1;
   l_start_date           date   := p_start_date;
   l_end_date             date   := p_end_date;
   l_yr_start_date        date   := null;
   l_acty_ref_perd_cd     varchar2(30) := p_acty_ref_perd_cd;
   l_package varchar2(80) := g_package || '.annual_to_period';
   l_cmplt_yr_flag        varchar2(20) := p_complete_year_flag;
   --
   cursor c_cd is
     select
            abr.det_pl_ytd_cntrs_cd,
            abr.entr_ann_val_flag,
            abr.rt_mlt_cd
     from   ben_enrt_rt        ecr,
            ben_acty_base_rt_f abr
     where  ecr.enrt_rt_id        = p_enrt_rt_id
     and    ecr.business_group_id = p_business_group_id
     and    ecr.acty_base_rt_id   = abr.acty_base_rt_id
     and    p_effective_date between
            abr.effective_start_date and abr.effective_end_date;
   --
   cursor c_payroll is
     select pay_date_offset
     from   pay_all_payrolls_f prl
     where  prl.payroll_id = p_payroll_id
     and    p_effective_date between prl.effective_start_date
            and prl.effective_end_date;
   --
     l_cd   ben_acty_base_rt_f.det_pl_ytd_cntrs_cd%TYPE := null;
     l_entr_ann_val_flag       varchar2(30);
     l_rt_mlt_cd               varchar2(30);
     l_call_balance            boolean;
     l_pay_date_offset         number;
   --
begin
  --
--  hr_utility.set_location('Entering '||l_package, 10);
  --
  -- Check for a null amount. Assumption is that a calculation
  -- cannot be performed on a null amount.
  --
  if p_amount is null then
    --
    return null;
    --
  end if;
  --
  open c_payroll;
  fetch c_payroll into l_pay_date_offset;
  close c_payroll;
  --
  if g_annual_to_period_cached > 0 then
    --
    begin
      --
      l_hv := mod(nvl(p_amount,1)
                 +nvl(p_enrt_rt_id,2)
                 +nvl(p_elig_per_elctbl_chc_id,3)
                 +nvl(p_start_date-hr_api.g_sot,4)
                 +nvl(p_end_date-hr_api.g_sot,5)
                 +nvl(p_payroll_id,6)
                 +nvl(p_element_type_id,7)
                 ,ben_hash_utility.get_hash_key);
      --
      if nvl(g_annual_to_period_cache(l_hv).amount,-1) = nvl(p_amount,-1)
        and nvl(g_annual_to_period_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
        and nvl(g_annual_to_period_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
        and nvl(g_annual_to_period_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
        and nvl(g_annual_to_period_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
      then
        --
        null;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
        loop
          --
          if nvl(g_annual_to_period_cache(l_hv).amount,-1) = nvl(p_amount,-1)
            and nvl(g_annual_to_period_cache(l_hv).enrt_rt_id,-1) = nvl(p_enrt_rt_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id,-1) = nvl(p_elig_per_elctbl_chc_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).acty_ref_perd_cd,hr_api.g_varchar2) = nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).business_group_id,-1) = nvl(p_business_group_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).effective_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt,hr_api.g_sot) = nvl(p_lf_evt_ocrd_dt,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).complete_year_flag,hr_api.g_varchar2) = nvl(p_complete_year_flag,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).use_balance_flag,hr_api.g_varchar2) = nvl(p_use_balance_flag,hr_api.g_varchar2)
            and nvl(g_annual_to_period_cache(l_hv).start_date,hr_api.g_sot) = nvl(p_start_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).end_date,hr_api.g_sot) = nvl(p_end_date,hr_api.g_sot)
            and nvl(g_annual_to_period_cache(l_hv).payroll_id,-1) = nvl(p_payroll_id,-1)
            and nvl(g_annual_to_period_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
          then
            --
            exit;
            --
          else
            --
            l_hv := l_hv+g_hash_jump;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    exception
      when no_data_found then
        --
        l_hv := null;
    end;
    --
    if l_hv is not null then
      --
      p_pp_in_yr_used_num := g_annual_to_period_cache(l_hv).pp_in_yr_used_num;
      return g_annual_to_period_cache(l_hv).period_amt;
      --
    end if;
    --
  end if;
  --
  if p_use_balance_flag = 'Y' then
    l_call_balance := true;
    if p_enrt_rt_id is not null then
      open  c_cd;
      fetch c_cd into l_cd,l_entr_ann_val_flag,l_rt_mlt_cd;
      close c_cd;
      if l_cd is null then
        l_call_balance := false;
      else
        l_cmplt_yr_flag := 'N';
      end if;
    end if;
  end if;
  --
  set_default_dates(p_enrt_rt_id         => p_enrt_rt_id,
                   p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                   p_business_group_id  => p_business_group_id,
                   p_complete_year_flag => l_cmplt_yr_flag,
                   p_effective_date     => p_effective_date,
                   p_payroll_id         => p_payroll_id,
                   p_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt,
                   p_start_date         => l_start_date,
                   p_end_date           => l_end_date,
                   p_acty_ref_perd_cd   => l_acty_ref_perd_cd,
                   p_yr_start_date      => l_yr_start_date);
  --
  -- Compute balances only if use_balance_flag is ON.
  --
  if l_call_balance then
    --
    l_balance_amt := get_balance
                     (p_enrt_rt_id        => p_enrt_rt_id,
                      p_payroll_id        => p_payroll_id,
                      p_business_group_id => p_business_group_id,
                      p_effective_date    => p_effective_date,
                      p_start_date        => l_yr_start_date);
    --
  end if;
  --
  if l_acty_ref_perd_cd = 'PYR' then
    --
    -- If Annualy, don't need to get number of periods.
    --
    l_no_of_periods  := 1;
    --
  else
    --
    if l_pay_date_offset <> 0 and (l_entr_ann_val_flag = 'Y' or l_rt_mlt_cd = 'SAREC') then
       l_no_of_periods := get_periods_between
                         (p_acty_ref_perd_cd => l_acty_ref_perd_cd,
                          p_start_date       => l_start_date,
                          p_end_date         => l_end_date,
                          p_payroll_id       => p_payroll_id,
                          p_business_group_id => p_business_group_id,
                          p_enrt_rt_id       => p_enrt_rt_id,
                          p_element_type_id  => p_element_type_id,
                          p_effective_date   => p_effective_date,
                          p_use_check_date  => true
                          );
    else
      l_no_of_periods := get_periods_between
                         (p_acty_ref_perd_cd => l_acty_ref_perd_cd,
                          p_start_date       => l_start_date,
                          p_end_date         => l_end_date,
                          p_payroll_id       => p_payroll_id,
                          p_business_group_id => p_business_group_id,
                          p_enrt_rt_id       => p_enrt_rt_id,
                          p_element_type_id  => p_element_type_id,
                          p_effective_date   => p_effective_date
      );
    --
   end if;
   --
  end if;
  --
  l_period_amt := (l_annual_amt - l_balance_amt)/l_no_of_periods;
  --
  l_period_amt := round(l_period_amt,2);
  --
  if g_annual_to_period_cached > 0 then
    --
    -- Only store the
    --
    l_hv := mod(nvl(p_amount,1)
               +nvl(p_enrt_rt_id,2)
               +nvl(p_elig_per_elctbl_chc_id,3)
               +nvl(p_start_date-hr_api.g_sot,4)
               +nvl(p_end_date-hr_api.g_sot,5)
               +nvl(p_payroll_id,6)
               +nvl(p_element_type_id,7)
               ,ben_hash_utility.get_hash_key);
    --
    while g_annual_to_period_cache.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    g_annual_to_period_cache(l_hv).amount                  := p_amount;
    g_annual_to_period_cache(l_hv).enrt_rt_id              := p_enrt_rt_id;
    g_annual_to_period_cache(l_hv).elig_per_elctbl_chc_id  := p_elig_per_elctbl_chc_id;
    g_annual_to_period_cache(l_hv).acty_ref_perd_cd        := p_acty_ref_perd_cd;
    g_annual_to_period_cache(l_hv).business_group_id       := p_business_group_id;
    g_annual_to_period_cache(l_hv).effective_date          := p_effective_date;
    g_annual_to_period_cache(l_hv).lf_evt_ocrd_dt          := p_lf_evt_ocrd_dt;
    g_annual_to_period_cache(l_hv).complete_year_flag      := p_complete_year_flag;
    g_annual_to_period_cache(l_hv).use_balance_flag        := p_use_balance_flag;
    g_annual_to_period_cache(l_hv).start_date              := p_start_date;
    g_annual_to_period_cache(l_hv).end_date                := p_end_date;
    g_annual_to_period_cache(l_hv).payroll_id              := p_payroll_id;
    g_annual_to_period_cache(l_hv).element_type_id         := p_element_type_id;
    g_annual_to_period_cache(l_hv).period_amt              := l_period_amt;
    g_annual_to_period_cache(l_hv).pp_in_yr_used_num       := l_no_of_periods;
    --
  end if;
  --
--  hr_utility.set_location('Leaving '||l_package , 90);
  --
  p_pp_in_yr_used_num := l_no_of_periods;
  return(l_period_amt);
  --
exception
   --
   when others then
      p_pp_in_yr_used_num := null; -- no copy changes
      fnd_message.raise_error;
   --
end annual_to_period_out;
---------------------------------------------------------------------------
--                              compare_balances
--
-- Find a person's period-to-date balance and their claims-to-date balance.
-- Return new min or max annual value based upon these balances.
--
-- This procedure can be called to just obtain the ptd and clm balances.
-- Just call with req parms and zero p_ann_mn_val and p_ann_mx_val values.
-- If there are no balances, null will be returned.
--
-- you can call this will elig_per_elctbl_chc_id or ALL of the following:
--          ,p_lf_evt_ocrd_dt
--          ,p_pgm_id and/or ,p_pl_id and/or ,p_oipl_id
--          ,p_per_in_ler_id
--          ,p_business_group_id
--
---------------------------------------------------------------------------
procedure compare_balances
          (p_person_id            in number
          ,p_effective_date       in date
          ,p_lf_evt_ocrd_dt       in date default null
          ,p_elig_per_elctbl_chc_id in number default null
          ,p_pgm_id               in number default null
          ,p_pl_id                in number default null
          ,p_oipl_id              in number default null
          ,p_per_in_ler_id        in number default null
          ,p_business_group_id    in number default null
          ,p_acty_base_rt_id      in number
          ,p_perform_edit_flag    in varchar2 default 'N'
          ,p_entered_ann_val      in number default null
          ,p_ann_mn_val           in out nocopy number
          ,p_ann_mx_val           in out nocopy number
          ,p_ptd_balance          out nocopy number
          ,p_clm_balance          out nocopy number) is

   l_package varchar2(80) := g_package || '.compare_balances';
 --
 cursor c_pel is
    select pel.enrt_perd_id,
           pel.lee_rsn_id,
           epe.yr_perd_id
    from   ben_pil_elctbl_chc_popl pel,
           ben_elig_per_elctbl_chc epe
    where  pel.per_in_ler_id          = p_per_in_ler_id
    and    pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
    and    pel.per_in_ler_id          = epe.per_in_ler_id
    and    ((p_pgm_id is not null and
             pel.pgm_id = p_pgm_id)
            OR
            (p_pgm_id is null and
             pel.pl_id = p_pl_id));
 --
 cursor get_epe is
   select pil.lf_evt_ocrd_dt,
          epe.pgm_id,
          epe.pl_id,
          epe.oipl_id,
          epe.per_in_ler_id,
          epe.yr_perd_id,
          pel.enrt_perd_id,
          pel.lee_rsn_id,
          pil.business_group_id
   from   ben_elig_per_elctbl_chc epe,
          ben_pil_elctbl_chc_popl pel,
          ben_per_in_ler          pil
   where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
   and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
   and    pel.per_in_ler_id          = pil.per_in_ler_id;
  --
  l_get_epe get_epe%rowtype;
  --
  cursor c_yrp is
     select yrp.start_date
     from   ben_yr_perd yrp
     where  yrp.yr_perd_id        = l_get_epe.yr_perd_id
     and    yrp.business_group_id = l_get_epe.business_group_id;
  --
  l_yr_start_date   date;
  --
  cursor abr_balance is
     select abr.ptd_comp_lvl_fctr_id,
            abr.clm_comp_lvl_fctr_id,
            abr.det_pl_ytd_cntrs_cd
     from   ben_acty_base_rt_f abr
     where  abr.acty_base_rt_id = p_acty_base_rt_id
     and    p_effective_date between
            abr.effective_start_date and abr.effective_end_date;
  --
  l_abr_balance abr_balance%rowtype;
  --
begin
    --
    g_debug := hr_utility.debug_enabled;
    --
   if g_debug then
     hr_utility.set_location('Entering '||l_package , 10);
   end if;

  if p_elig_per_elctbl_chc_id is not null then
     -- get needed values
     open get_epe;
     fetch get_epe into l_get_epe;
     close get_epe;
  elsif  (p_pgm_id is null and p_pl_id is null and p_oipl_id is null)
       or p_per_in_ler_id is null or p_business_group_id is null
       or p_lf_evt_ocrd_dt is null then
     fnd_message.set_name('BEN','BEN_92404_NEED_MORE_VARS');
     fnd_message.set_token('PROC',l_package);
     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
     fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
     fnd_message.set_token('PL_ID',to_char(p_pl_id));
     fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
     fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
     fnd_message.set_token('BG_ID',to_char(p_business_group_id));
     fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
     fnd_message.raise_error;
  else
    --
    open  c_pel;
    fetch c_pel into l_get_epe.enrt_perd_id,
                     l_get_epe.lee_rsn_id,
                     l_get_epe.yr_perd_id;
    close c_pel;
    --
    l_get_epe.lf_evt_ocrd_dt    := p_lf_evt_ocrd_dt;
    l_get_epe.pgm_id            := p_pgm_id;
    l_get_epe.pl_id             := p_pl_id;
    l_get_epe.oipl_id           := p_oipl_id;
    l_get_epe.per_in_ler_id     := p_per_in_ler_id;
    l_get_epe.business_group_id := p_business_group_id;
    --
  end if;

  if p_entered_ann_val is null and p_perform_edit_flag = 'Y' then
     fnd_message.set_name('BEN','BEN_92405_NEED_ENTERED_VAL');
     fnd_message.set_token('PROC',l_package);
     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
     fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
     fnd_message.set_token('PL_ID',to_char(p_pl_id));
     fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
     fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
     fnd_message.set_token('BG_ID',to_char(p_business_group_id));
     fnd_message.raise_error;
  end if;

  p_ptd_balance := null;
  p_clm_balance := null;

  open abr_balance;
  fetch abr_balance into l_abr_balance;
  close abr_balance;

  if l_abr_balance.det_pl_ytd_cntrs_cd is not null then
     --
     open  c_yrp;
     fetch c_yrp into l_yr_start_date;
     close c_yrp;
     --
     p_ptd_balance := get_balance
               (p_person_id            => p_person_id,
                p_per_in_ler_id        => l_get_epe.per_in_ler_id,
                p_pgm_id               => l_get_epe.pgm_id,
                p_pl_id                => l_get_epe.pl_id,
                p_oipl_id              => l_get_epe.oipl_id,
                p_enrt_perd_id         => l_get_epe.enrt_perd_id,
                p_lee_rsn_id           => l_get_epe.lee_rsn_id,
                p_acty_base_rt_id      => p_acty_base_rt_id,
                p_ptd_comp_lvl_fctr_id => l_abr_balance.ptd_comp_lvl_fctr_id,
                p_det_pl_ytd_cntrs_cd  => l_abr_balance.det_pl_ytd_cntrs_cd,
                p_lf_evt_ocrd_dt       => l_get_epe.lf_evt_ocrd_dt,
                p_business_group_id    => l_get_epe.business_group_id,
                p_start_date           => l_yr_start_date,
                p_effective_date       => p_effective_date);

    if p_ptd_balance is not null and p_entered_ann_val < p_ptd_balance and
       p_perform_edit_flag = 'Y' then
       -- The period-to-date is what the prtt has already paid into this plan.
       -- Do not allow their elected annual value to fall below the ptd-balance.
       fnd_message.set_name('BEN','BEN_92406_BELOW_PTD');
       fnd_message.set_token('PROC',l_package);
       fnd_message.set_token('PERSON_ID',to_char(p_person_id));
       fnd_message.set_token('ANN_VAL',to_char(p_entered_ann_val));
       fnd_message.set_token('PTD_BAL',to_char(p_ptd_balance));
       fnd_message.raise_error;
    end if;
  end if;

  if l_abr_balance.clm_comp_lvl_fctr_id is not null then
    -- Get claims to date.
    ben_derive_factors.determine_compensation
         (p_comp_lvl_fctr_id     => l_abr_balance.clm_comp_lvl_fctr_id,
          p_person_id            => p_person_id,
          p_pgm_id               => l_get_epe.pgm_id,
          p_pl_id                => l_get_epe.pl_id,
          p_oipl_id              => l_get_epe.oipl_id,
          p_per_in_ler_id        => l_get_epe.per_in_ler_id,
          p_business_group_id    => l_get_epe.business_group_id,
          p_perform_rounding_flg => TRUE,
          p_effective_date       => p_effective_date,
          p_lf_evt_ocrd_dt       => l_get_epe.lf_evt_ocrd_dt,
          p_value                => p_clm_balance);

    if p_clm_balance is not null and p_entered_ann_val < p_clm_balance and
       p_perform_edit_flag = 'Y' then
       --The claims-to-date is what the prtt has already claimed against the FSA
       --Do not allow their elected annual value to fall below the clm-balance.
       fnd_message.set_name('BEN','BEN_92407_BELOW_CLM');
       fnd_message.set_token('PROC',l_package);
       fnd_message.set_token('PERSON_ID',to_char(p_person_id));
       fnd_message.set_token('ANN_VAL',to_char(p_entered_ann_val));
       fnd_message.set_token('CLM_BAL',to_char(p_clm_balance));
       fnd_message.raise_error;
    end if;
  end if;

  if g_debug then
    hr_utility.set_location('p_clm_balance '||to_char(p_clm_balance)||
                          ' p_ptd_balance '||to_char(p_ptd_balance) , 97);
  end if;

  -- the minimum that the prtt can select is the higher of payments-to-date,
  -- claims-to-date or the already computed minimum that was passed in.
  if p_ann_mn_val is not null or p_clm_balance is not null or p_ptd_balance
     is not null then
     p_ann_mn_val := greatest(nvl(p_ann_mn_val,0), nvl(p_clm_balance,0),
                  nvl(p_ptd_balance,0));
  end if;

  -- if the re-computed min val is greater than the previously computed max
  -- val, raise the max val.
  if p_ann_mx_val is not null and nvl(p_ann_mn_val,0) > p_ann_mx_val then
     p_ann_mx_val := p_ann_mn_val;
  end if;

  if g_debug then
    hr_utility.set_location('p_ann_mn_val '||to_char(p_ann_mn_val)||
                          ' p_ann_mx_val '||to_char(p_ann_mx_val) , 97);
    hr_utility.set_location('Leaving '||l_package , 99);
  end if;
end compare_balances;

---------------------------------------------------------------------------
--                  prorate_min_max
--
-- Recompute a person's prorated minimum and maximum rate values.
-- Return new min or max annual value based upon these balances.
-- Optionally, edit the entered value against these min's and max's.
---------------------------------------------------------------------------
procedure prorate_min_max
          (p_person_id                in number
          ,p_effective_date           in date
          ,p_elig_per_elctbl_chc_id   in number
          ,p_acty_base_rt_id          in number
          ,p_rt_strt_dt               in date
          ,p_ann_mn_val               in out nocopy number
          ,p_ann_mx_val               in out nocopy number ) is

   l_package varchar2(80) := g_package || '.prorate_min_max';

cursor get_cds is
  select abr.prort_mn_ann_elcn_val_cd
         ,abr.prort_mx_ann_elcn_val_cd
         ,abr.prort_mn_ann_elcn_val_rl
         ,abr.prort_mx_ann_elcn_val_rl
         ,abr.element_type_id
  from   ben_acty_base_rt_f abr
  where  abr.acty_base_rt_id = p_acty_base_rt_id
  and    p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
l_get_cds get_cds%rowtype;

cursor get_epe_pl_yr is
  select yrp.start_date, yrp.end_date, epe.pgm_id, epe.pl_id,
         epe.pl_typ_id, epe.business_group_id, pil.ler_id,
         oipl.opt_id
  from   ben_yr_perd yrp
        ,ben_elig_per_elctbl_chc epe
        ,ben_per_in_ler pil
        ,ben_oipl_f oipl
  where epe.yr_perd_id = yrp.yr_perd_id
  and   epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
  and   epe.per_in_ler_id = pil.per_in_ler_id
  and   epe.oipl_id = oipl.oipl_id(+)
  and    p_effective_date between
         nvl(oipl.effective_start_date, p_effective_date)
         and nvl(oipl.effective_end_date, p_effective_date);
l_get_epe_pl_yr get_epe_pl_yr%rowtype;

cursor get_pgm_acty_ref_cd (p_pgm_id number) is
  select pgm.acty_ref_perd_cd
  from   ben_pgm_f pgm
  where  pgm.pgm_id = p_pgm_id
  and    p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;

cursor get_pl_acty_ref_cd (p_pl_id number) is
  select pl.nip_acty_ref_perd_cd
  from   ben_pl_f pl
  where  pl.pl_id = p_pl_id
  and    p_effective_date between
         pl.effective_start_date and pl.effective_end_date;


cursor get_asg_info is
    select asg.assignment_id, asg.organization_id, loc.region_2 state, asg.location_id,
           asg.payroll_id
      from hr_locations_all loc, per_all_assignments_f asg
      where asg.person_id = p_person_id
      and   asg.assignment_type <> 'C'
      and   asg.primary_flag = 'Y'
      and   loc.location_id(+) = asg.location_id
      and   p_effective_date between
            asg.effective_start_date and asg.effective_end_date
      order by 1;
l_get_asg_info get_asg_info%rowtype;

-----Bug 7395779
cursor c_check_date(p_payroll_id number,
                    p_date date)
    is
 SELECT prd.regular_payment_date
  FROM per_time_periods prd
 WHERE prd.payroll_id = p_payroll_id
   AND p_date BETWEEN prd.start_date
                            AND prd.end_date;
l_check_date date;
l_12_months_back   date;
l_dividend         number;
l_divisor          number;
l_percent          number;
l_periods          number := null;
l_acty_ref_perd_cd varchar2(30);
l_outputs          ff_exec.outputs_t;
l_jurisdiction PAY_CA_EMP_PROV_TAX_INFO_F.JURISDICTION_CODE%type := null;

begin
    --
    g_debug := hr_utility.debug_enabled;
    --
  if g_debug then
    hr_utility.set_location ('Entering '||l_package,10);
  end if;

  open get_cds;
  fetch get_cds into l_get_cds;
  close get_cds;

  if g_debug then
    hr_utility.set_location('prort_mn_ann_elcn_val_cd '||
         l_get_cds.prort_mn_ann_elcn_val_cd,20);
  end if;

  if g_debug then
    hr_utility.set_location('prort_mx_ann_elcn_val_cd '||
             l_get_cds.prort_mx_ann_elcn_val_cd,20);
  end if;

  -- do not prorate null values.
  if p_ann_mn_val is null then
     l_get_cds.prort_mn_ann_elcn_val_cd := null;
  end if;
  if p_ann_mx_val is null then
     l_get_cds.prort_mx_ann_elcn_val_cd := null;
  end if;

  if l_get_cds.prort_mn_ann_elcn_val_cd is not null
     or l_get_cds.prort_mx_ann_elcn_val_cd is not null then
     open get_epe_pl_yr;
     fetch get_epe_pl_yr into l_get_epe_pl_yr;
     if get_epe_pl_yr%NOTFOUND or get_epe_pl_yr%NOTFOUND is null then
          close get_epe_pl_yr;
          fnd_message.set_name('BEN','BEN_92408_EPE_PL_YR_NOTF');
          fnd_message.set_token('PROC',l_package);
          fnd_message.set_token('PERSON_ID',to_char(p_person_id));
          fnd_message.set_token('CHC',to_char(p_elig_per_elctbl_chc_id));
          fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
          fnd_message.raise_error;
     end if;
     close get_epe_pl_yr;
     --
     -- Bug No 4290565
     -- Added 1 to l_12_months_back as add_months is counting the last day of the previous year also
     --
     l_12_months_back := (add_months(l_get_epe_pl_yr.end_date,-12)) + 1;
  end if;

  if l_get_cds.prort_mn_ann_elcn_val_cd = 'DR'
     or l_get_cds.prort_mx_ann_elcn_val_cd  = 'DR' then

     -- number of days from rate start to end of plan year.
     l_dividend := l_get_epe_pl_yr.end_date - p_rt_strt_dt;
     -- number of days in 12 months ending with end of plan year.
     l_divisor := l_get_epe_pl_yr.end_date - l_12_months_back;

     l_percent := l_dividend/l_divisor;
     if l_get_cds.prort_mn_ann_elcn_val_cd = 'DR' then
        p_ann_mn_val := l_percent * p_ann_mn_val;
     end if;
     if l_get_cds.prort_mx_ann_elcn_val_cd = 'DR' then
        p_ann_mx_val := l_percent * p_ann_mx_val;
     end if;
  end if;

  if l_get_cds.prort_mn_ann_elcn_val_cd = 'FPR'
     or l_get_cds.prort_mx_ann_elcn_val_cd = 'FPR' then

     if l_get_epe_pl_yr.pgm_id is not null then
        open get_pgm_acty_ref_cd(p_pgm_id=> l_get_epe_pl_yr.pgm_id);
        fetch get_pgm_acty_ref_cd into l_acty_ref_perd_cd;
        close get_pgm_acty_ref_cd;
     else
        open get_pl_acty_ref_cd(p_pl_id=> l_get_epe_pl_yr.pl_id);
        fetch get_pl_acty_ref_cd into l_acty_ref_perd_cd;
        close get_pl_acty_ref_cd;
     end if;
     -- number of periods between rate start and end of plan year.
     l_dividend := get_periods_between
                  (p_acty_ref_perd_cd => l_acty_ref_perd_cd
                  ,p_start_date       => p_rt_strt_dt
                  ,p_end_date         => l_get_epe_pl_yr.end_date
                  ,p_business_group_id => l_get_epe_pl_yr.business_group_id
                  ,p_element_type_id  => l_get_cds.element_type_id
                  ,p_effective_date   => p_effective_date
     );
     -- number of periods from 12 months before end of plan year to end of plan year.
     l_divisor := get_periods_between
                  (p_acty_ref_perd_cd => l_acty_ref_perd_cd
                  ,p_start_date       => l_12_months_back
                  ,p_end_date         => l_get_epe_pl_yr.end_date
                  ,p_business_group_id => l_get_epe_pl_yr.business_group_id
                  ,p_element_type_id  => l_get_cds.element_type_id
                  ,p_effective_date   => p_effective_date
     );
     l_percent := l_dividend/l_divisor;
     if l_get_cds.prort_mn_ann_elcn_val_cd = 'FPR' then
        p_ann_mn_val := l_percent * p_ann_mn_val;
     end if;
     if l_get_cds.prort_mx_ann_elcn_val_cd = 'FPR' then
        p_ann_mx_val := l_percent * p_ann_mx_val;
     end if;
  end if;

  if l_get_cds.prort_mn_ann_elcn_val_cd = 'FPPR'
     or l_get_cds.prort_mx_ann_elcn_val_cd = 'FPPR'
     or l_get_cds.prort_mn_ann_elcn_val_cd = 'RL'
     or l_get_cds.prort_mx_ann_elcn_val_cd = 'RL' then
     -- Find the person's assignment info
     open get_asg_info;
     fetch get_asg_info into l_get_asg_info;
     if get_asg_info%NOTFOUND or get_asg_info%NOTFOUND is null then
          close get_asg_info;
          fnd_message.set_name('BEN','BEN_92409_ASG_NOT_FOUND');
          fnd_message.set_token('PROC',l_package);
          fnd_message.set_token('PERSON',to_char(p_person_id));
          fnd_message.raise_error;
     end if;
     close get_asg_info;
  end if;

  if l_get_cds.prort_mn_ann_elcn_val_cd = 'FPPR'
     or l_get_cds.prort_mx_ann_elcn_val_cd = 'FPPR' then

     ---------Bug 7395779
     open c_check_date(l_get_asg_info.payroll_id,p_rt_strt_dt);
     fetch c_check_date into l_check_date;
     close c_check_date;
     -- number of pay periods between rate start and end of plan year.
     l_dividend := get_periods_between
                  (p_acty_ref_perd_cd => 'PP'
                  ,p_start_date       => /*p_rt_strt_dt*/ l_check_date ---------Bug 7395779
                  ,p_end_date         => l_get_epe_pl_yr.end_date
                  ,p_payroll_id       => l_get_asg_info.payroll_id
                  ,p_business_group_id => l_get_epe_pl_yr.business_group_id
                  ,p_element_type_id  => l_get_cds.element_type_id
                  ,p_effective_date   => p_effective_date
     );
     -- number of pay periods from 12 months before end of plan year to end of plan year.
     l_divisor := get_periods_between
                  (p_acty_ref_perd_cd => 'PP'
                  ,p_start_date       => l_12_months_back
                  ,p_end_date         => l_get_epe_pl_yr.end_date
                  ,p_payroll_id       => l_get_asg_info.payroll_id
                  ,p_business_group_id => l_get_epe_pl_yr.business_group_id
                  ,p_element_type_id  => l_get_cds.element_type_id
                  ,p_effective_date   => p_effective_date
     );

     l_percent := l_dividend/l_divisor;
     if l_get_cds.prort_mn_ann_elcn_val_cd = 'FPPR' then
        p_ann_mn_val := l_percent * p_ann_mn_val;
     end if;
     if l_get_cds.prort_mx_ann_elcn_val_cd = 'FPPR' then
        p_ann_mx_val := l_percent * p_ann_mx_val;
     end if;
  end if;


  if l_get_cds.prort_mn_ann_elcn_val_cd = 'RL' then
            /*
            if l_get_asg_info.state is not null then
               l_jurisdiction := pay_mag_utils.lookup_jurisdiction_code
                               (p_state => l_get_asg_info.state);
            end if;
            */
            -- this rule returns an amount.
            l_outputs := benutils.formula
              (p_formula_id         => l_get_cds.prort_mn_ann_elcn_val_rl,
               p_effective_date     => p_effective_date,
               p_business_group_id  => l_get_epe_pl_yr.business_group_id,
               p_assignment_id      => l_get_asg_info.assignment_id,
               p_organization_id    => l_get_asg_info.organization_id,
               p_acty_base_rt_id    => p_acty_base_rt_id,
               p_elig_per_elctbl_chc_id    => p_elig_per_elctbl_chc_id,
               p_pgm_id	            => l_get_epe_pl_yr.pgm_id,
               p_pl_id		        => l_get_epe_pl_yr.pl_id,
               p_pl_typ_id	        => l_get_epe_pl_yr.pl_typ_id,
               p_opt_id	            => l_get_epe_pl_yr.opt_id,
               p_ler_id	            => l_get_epe_pl_yr.ler_id,
               p_jurisdiction_code  => l_jurisdiction);
            p_ann_mn_val := l_outputs(l_outputs.first).value;
  end if;
  if l_get_cds.prort_mx_ann_elcn_val_cd = 'RL' then
            /*
            if l_get_asg_info.state is not null then
               l_jurisdiction := pay_mag_utils.lookup_jurisdiction_code
                               (p_state => l_get_asg_info.state);
            end if;
            */
            -- this rule returns an amount.
            l_outputs := benutils.formula
              (p_formula_id         => l_get_cds.prort_mx_ann_elcn_val_rl,
               p_effective_date     => p_effective_date,
               p_business_group_id  => l_get_epe_pl_yr.business_group_id,
               p_assignment_id      => l_get_asg_info.assignment_id,
               p_organization_id    => l_get_asg_info.organization_id,
               p_acty_base_rt_id    => p_acty_base_rt_id,
               p_elig_per_elctbl_chc_id    => p_elig_per_elctbl_chc_id,
               p_pgm_id	            => l_get_epe_pl_yr.pgm_id,
               p_pl_id		        => l_get_epe_pl_yr.pl_id,
               p_pl_typ_id	        => l_get_epe_pl_yr.pl_typ_id,
               p_opt_id	            => l_get_epe_pl_yr.opt_id,
               p_ler_id	            => l_get_epe_pl_yr.ler_id,
               p_jurisdiction_code  => l_jurisdiction);
            p_ann_mx_val := l_outputs(l_outputs.first).value;
  end if;
  if g_debug then
    hr_utility.set_location('p_ann_mn_val '||to_char(p_ann_mn_val)||
                          ' p_ann_mx_val '||to_char(p_ann_mx_val) , 97);
  end if;

  p_ann_mn_val := round(p_ann_mn_val,2);
  p_ann_mx_val := round(p_ann_mx_val,2);

  if g_debug then
    hr_utility.set_location('p_ann_mn_val '||to_char(p_ann_mn_val)||
                          ' p_ann_mx_val '||to_char(p_ann_mx_val) , 98);
    hr_utility.set_location('Leaving '||l_package , 99);
  end if;
end prorate_min_max;
--
-- 0 - Always refresh
-- 1 - Initialise cache
-- 2 - Cache hit
--
procedure clear_down_cache
is

begin
  --
  g_period_to_annual_cache.delete;
  g_period_to_annual_cached := 1;
  --
  g_annual_to_period_cache.delete;
  g_annual_to_period_cached := 1;
  --
end clear_down_cache;
--
procedure set_no_cache_context
is

begin
  --
  g_period_to_annual_cache.delete;
  g_period_to_annual_cached := 0;
  --
  g_annual_to_period_cache.delete;
  g_annual_to_period_cached := 0;
  --
end set_no_cache_context;
--
-------------------------------------------------------------------------------
-- Scope of function: Call from Internal procedures allowed.
--
function decde_bits(p_number IN NUMBER) return NUMBER is
/*
,1,1,2,1,4,1,8,1,16,1,32,1,64,1
,3,2,5,2,6,2,9,2,10,2,12,2,17,2,18,2,20,2,24,2,33,2,34,2,36,2,40,2,48,2
,7,3,11,3,14,3,13,3,19,3,21,3,22,3
,25,3,26,3,28,3,35,3,37,3,38,3,41,3,42,3,44,3,49,3,50,3,52,3,56,3
,15,4,23,4,27,4,29,4,30,4,39,4,43,4,45,4,46,4,51,4,53,4,54,4,57,4,58,4,60,4
,31,5,47,5,55,5,59,5,61,5,62,5
,63,6
,power(2,count(start_date )) -1)
*/
l_number NUMBER;
begin
 if
  p_number in (1,2,4,8,16,32,64)
 then
  l_number := 1;
 elsif
  p_number in (3,5,6,9,10,12,17,18,20,24,33,34,36,40,48)
 then
  l_number := 2;
 elsif
  p_number in (15,23,27,29,30,39,43,45,46,51,53,54,57,58,60)
 then
  l_number := 4;
 elsif
  p_number in (31,47,55,59,61,62)
 then
  l_number := 5;
 elsif
  p_number = 63
 then
  l_number := 6;
 elsif p_number between 1 and 64 then
  l_number := 3;
 elsif p_number >64 then
  l_number :=power(2,p_number -1);
 else
  l_number := p_number;
 end if;
 return l_number;
end decde_bits;
--
procedure convert_rates_w(p_person_id		   in number,
			  p_amount                 in number,
                          p_enrt_rt_id             in number default null,
                          p_elig_per_elctbl_chc_id in number default null,
                          p_acty_ref_perd_cd       in varchar2 default null,
                          p_cmcd_acty_ref_perd_cd  in varchar2 default null,
                          p_business_group_id      in number default null,
                          p_effective_date         in date default null,
                          p_lf_evt_ocrd_dt         in date default null,
                          p_complete_year_flag     in varchar2 default 'N',
                          p_use_balance_flag       in varchar2 default 'N',
                          p_start_date             in date default null,
                          p_end_date               in date default null,
                          p_payroll_id             in number default null,
                          p_element_type_id        in number default null,
                          p_convert_from_rt        in varchar2,
                          p_ann_rt_val             out nocopy number,
                          p_cmcd_rt_val            out nocopy number,
                          p_val                    out nocopy number  )
is
 /*
   cursor c_payroll_id is
      select payroll_id from
            per_all_assignments_f
            where person_id = p_person_id
            and   assignment_type <> 'C'
            and p_effective_date between effective_start_date and effective_end_date
            and primary_flag = 'Y';
   l_payroll_id per_all_assignments_f.payroll_id%type;
  */
 --GEVITY
 cursor c_abr(cv_enrt_rt_id number,cv_effective_date date )
 is select abr.rate_periodization_rl, ecr.acty_base_rt_id
      from ben_enrt_rt ecr,
           ben_acty_base_rt_f abr
     where ecr.enrt_rt_id      = cv_enrt_rt_id
       and abr.acty_base_rt_id = ecr.acty_base_rt_id
       and cv_effective_date between abr.effective_start_date
                                and abr.effective_end_date ;
 --
 l_rate_periodization_rl NUMBER;
 l_acty_base_rt_id       NUMBER;
 --
 cursor c_legislation_code is
  select pbg.legislation_code
  from   per_business_groups pbg
  where  pbg.business_group_id = p_business_group_id;
 --
 l_legislation_code varchar2(30);
 --
 cursor c_ecr_rates is
  select mn_elcn_val, mx_elcn_val
  from   ben_enrt_rt ecr
  where  ecr.enrt_rt_id = p_enrt_rt_id;
 --
 l_min_val number;
 l_max_val number;
 --
 l_dfnd_dummy number;
 l_ann_dummy  number;
 l_cmcd_dummy number;
 l_assignment_id                 per_all_assignments_f.assignment_id%type;
 l_payroll_id                    per_all_assignments_f.payroll_id%type;
 l_organization_id               per_all_assignments_f.organization_id%type;
 --GEVITY
 not_supported exception;
 l_trace_param          varchar2(30);
 l_trace_on             boolean;
 l_proc                 varchar2(200) := 'ben_distribute_rates.convert_rates_w';

begin
   /*
    if p_payroll_id is null then
      open c_payroll_id;
      fetch c_payroll_id into l_payroll_id;
      close c_payroll_id;
    else
      l_payroll_id := p_payroll_id;
    end if;
    */
    --GEVITY
--  hr_utility.trace_on(null,'BENDISRT');
  l_trace_param := null;
  l_trace_on := false;
  --
  l_trace_param := fnd_profile.value('BEN_SS_TRACE_VALUE');
  --
  if l_trace_param = 'BENDISRT' then
     l_trace_on := true;
  else
     l_trace_on := false;
  end if;
  --
  if l_trace_on then
    hr_utility.trace_on(null,'BENDISRT');
  end if;
    hr_utility.set_location('l_trace_param : '|| l_trace_param, 5);
    hr_utility.set_location ('Entering '||l_proc,10);

    open c_abr(p_enrt_rt_id,nvl(p_lf_evt_ocrd_dt,p_effective_date)) ;
      fetch c_abr into l_rate_periodization_rl,l_acty_base_rt_id;
    close c_abr;
    --
    ben_element_entry.get_abr_assignment
        (p_person_id       => p_person_id
        ,p_effective_date  => nvl(p_lf_evt_ocrd_dt,p_effective_date)
        ,p_acty_base_rt_id => l_acty_base_rt_id
        ,p_organization_id => l_organization_id
        ,p_payroll_id      => l_payroll_id
        ,p_assignment_id   => l_assignment_id
        );
    --
    --END GEVITY
    -- Based on the conversion required, need to call different routines.
    if p_convert_from_rt = 'ANNUAL'then
    -- call the annual to periods function
      p_ann_rt_val  :=   p_amount;
      --
      IF l_rate_periodization_rl IS NOT NULL THEN
              --
              l_ann_dummy := p_amount;
              --
              ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,p_effective_date)
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_ann_dummy
                  ,p_convert_from           => 'ANNUAL'
                  ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => l_acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => p_ann_rt_val
                  ,p_cmcd_val               => p_cmcd_rt_val
                  ,p_val                    => p_val
              );
              --
      ELSE
        --
        p_cmcd_rt_val :=   annual_to_period
                         (p_amount                  =>p_amount,
                          p_enrt_rt_id              =>p_enrt_rt_id,
                          p_elig_per_elctbl_chc_id  =>p_elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd        =>p_cmcd_acty_ref_perd_cd,
                          p_business_group_id       =>p_business_group_id,
                          p_effective_date          =>p_effective_date,
                          p_lf_evt_ocrd_dt          =>p_lf_evt_ocrd_dt,
                          p_complete_year_flag      =>p_complete_year_flag,
                          p_use_balance_flag        =>p_use_balance_flag,
                          p_start_date              =>p_start_date,
                          p_end_date                =>p_end_date,
                          p_payroll_id              =>l_payroll_id,
                          p_element_type_id         =>p_element_type_id);
        --
        p_val    :=   annual_to_period
                         (p_amount                  =>p_amount,
                          p_enrt_rt_id              =>p_enrt_rt_id,
                          p_elig_per_elctbl_chc_id  =>p_elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd        =>p_acty_ref_perd_cd,
                          p_business_group_id       =>p_business_group_id,
                          p_effective_date          =>p_effective_date,
                          p_lf_evt_ocrd_dt          =>p_lf_evt_ocrd_dt,
                          p_complete_year_flag      =>p_complete_year_flag,
                          p_use_balance_flag        =>p_use_balance_flag,
                          p_start_date              =>p_start_date,
                          p_end_date                =>p_end_date,
                          p_payroll_id              =>l_payroll_id,
                          p_element_type_id         =>p_element_type_id);
        --
      END IF; --GEVITY
    elsif p_convert_from_rt = 'CMCD'then
    -- call the period to annual function
      IF l_rate_periodization_rl IS NOT NULL THEN
              --
              l_cmcd_dummy := p_amount;
              --
              ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,p_effective_date)
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_cmcd_dummy
                  ,p_convert_from           => 'CMCD'
                  ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => l_acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => p_ann_rt_val
                  ,p_cmcd_val               => p_cmcd_rt_val
                  ,p_val                    => p_val
              );
              --
      ELSE
        p_ann_rt_val :=   period_to_annual
                         (p_amount                  =>p_amount,
                          p_enrt_rt_id              =>p_enrt_rt_id,
                          p_elig_per_elctbl_chc_id  =>p_elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd        =>p_cmcd_acty_ref_perd_cd,
                          p_business_group_id       =>p_business_group_id,
                          p_effective_date          =>p_effective_date,
                          p_lf_evt_ocrd_dt          =>p_lf_evt_ocrd_dt,
                          p_complete_year_flag      =>p_complete_year_flag,
                          p_use_balance_flag        =>p_use_balance_flag,
                          p_start_date              =>p_start_date,
                          p_end_date                =>p_end_date,
                          p_payroll_id              =>l_payroll_id,
                          p_element_type_id         =>p_element_type_id);
        -- convert the annual to defined rate
        p_val    :=   annual_to_period
                         (p_amount                  =>p_ann_rt_val,
                          p_enrt_rt_id              =>p_enrt_rt_id,
                          p_elig_per_elctbl_chc_id  =>p_elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd        =>p_acty_ref_perd_cd,
                          p_business_group_id       =>p_business_group_id,
                          p_effective_date          =>p_effective_date,
                          p_lf_evt_ocrd_dt          =>p_lf_evt_ocrd_dt,
                          p_complete_year_flag      =>p_complete_year_flag,
                          p_use_balance_flag        =>p_use_balance_flag,
                          p_start_date              =>p_start_date,
                          p_end_date                =>p_end_date,
                          p_payroll_id              =>l_payroll_id,
                          p_element_type_id         =>p_element_type_id);
        p_cmcd_rt_val := p_amount;

        --start 5460638 : Adjust the defined rate when
        --1) It is different from communicated rate
        --2) Legislation code is 'US' and
        --3) It falls out of min-max window by <= .01
        if p_cmcd_rt_val <> p_val then
          open c_legislation_code;
          fetch c_legislation_code into l_legislation_code;
          close c_legislation_code;

          if l_legislation_code = 'US' then
            open c_ecr_rates;
            fetch c_ecr_rates into l_min_val, l_max_val;
            close c_ecr_rates;

            if l_min_val is not null and p_val < l_min_val and
              (l_min_val - p_val) <= 0.01 then
              p_val := l_min_val;
              hr_utility.set_location('Rounding error adjustment in defined rate. value='|| p_val,15.1);
            elsif l_max_val is not null and p_val > l_max_val and
              (p_val - l_max_val) <= 0.01 then
              p_val := l_max_val;
              hr_utility.set_location('Rounding error adjustment in defined rate. value='|| p_val,15.2);
            end if;
          end if;
        end if;
        --end 5460638

			END IF; --GEVITY
      --
    elsif p_convert_from_rt = 'DEFINED'then
      -- call the period to annual function
      IF l_rate_periodization_rl IS NOT NULL THEN
              --
              l_dfnd_dummy := p_amount;
              --
              ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,p_effective_date)
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_dfnd_dummy
                  ,p_convert_from           => 'DEFINED'
                  ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => l_acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => p_ann_rt_val
                  ,p_cmcd_val               => p_cmcd_rt_val
                  ,p_val                    => p_val
              );
        --
      ELSE
        --
        p_ann_rt_val :=   period_to_annual
                         (p_amount                  =>p_amount,
                          p_enrt_rt_id              =>p_enrt_rt_id,
                          p_elig_per_elctbl_chc_id  =>p_elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd        =>p_acty_ref_perd_cd,
                          p_business_group_id       =>p_business_group_id,
                          p_effective_date          =>p_effective_date,
                          p_lf_evt_ocrd_dt          =>p_lf_evt_ocrd_dt,
                          p_complete_year_flag      =>p_complete_year_flag,
                          p_use_balance_flag        =>p_use_balance_flag,
                          p_start_date              =>p_start_date,
                          p_end_date                =>p_end_date,
                          p_payroll_id              =>l_payroll_id,
                          p_element_type_id         =>p_element_type_id);
        -- convert the annual to communicated rate
        p_cmcd_rt_val  :=   annual_to_period
                         (p_amount                  =>p_ann_rt_val,
                          p_enrt_rt_id              =>p_enrt_rt_id,
                          p_elig_per_elctbl_chc_id  =>p_elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd        =>p_cmcd_acty_ref_perd_cd,
                          p_business_group_id       =>p_business_group_id,
                          p_effective_date          =>p_effective_date,
                          p_lf_evt_ocrd_dt          =>p_lf_evt_ocrd_dt,
                          p_complete_year_flag      =>p_complete_year_flag,
                          p_use_balance_flag        =>p_use_balance_flag,
                          p_start_date              =>p_start_date,
                          p_end_date                =>p_end_date,
                          p_payroll_id              =>l_payroll_id,
                          p_element_type_id         =>p_element_type_id);
         p_val := p_amount;
      END IF; --GEVITY
    else -- this is not supported
    raise not_supported;
    end if;

  hr_utility.set_location ('Leaving '||l_proc,20);
  if l_trace_on then
    hr_utility.trace_off;
    l_trace_param := null;
    l_trace_on := false;
  end if;
--
exception
  when not_supported then
  	-- This should never happen
     if l_trace_on then
       hr_utility.trace_off;
       l_trace_param := null;
       l_trace_on := false;
     end if;
     raise;
  when others then
     p_ann_rt_val    := null; -- no copy changes
     p_cmcd_rt_val   := null; -- no copy changes
     p_val           := null; -- no copy changes
     if l_trace_on then
       hr_utility.trace_off;
       l_trace_param := null;
       l_trace_on := false;
     end if;

     raise;
end convert_rates_w ;
--------------------------------------------------------------------------------------------------------
-- Procedure to re-calculate Child rates also if Parent Rate value is modified
--------------------------------------------------------------------------------------------------------
procedure convert_pcr_rates_w(
                           p_person_id              in number,
                           p_amount                 in number,
                           p_rate_index             in number,
                           p_prnt_acty_base_rt_id   in number,
                           p_enrt_rt_id             in number default null,
                           p_enrt_rt_id2            in number default null,
                           p_enrt_rt_id3            in number default null,
                           p_enrt_rt_id4            in number default null,
                           p_elig_per_elctbl_chc_id in number default null,
                           p_acty_ref_perd_cd       in varchar2 default null,
                           p_cmcd_acty_ref_perd_cd  in varchar2 default null,
                           p_business_group_id      in number default null,
                           p_effective_date         in date default null,
                           p_lf_evt_ocrd_dt         in date default null,
                           p_use_balance_flag       in varchar2 default 'N',
                           p_start_date             in date default null,
                           p_end_date               in date default null,
                           p_payroll_id             in number default null,
                           p_element_type_id        in number default null,
                           p_convert_from_rt        in varchar2,
                           p_ann_rt_val             in out nocopy number,
                           p_cmcd_rt_val            out nocopy number,
                           p_val                    out nocopy number,
                           p_child_rt_flag          out nocopy varchar2, --5104247
                           p_ann_rt_val2            in out nocopy number,
                           p_cmcd_rt_val2           out nocopy number,
                           p_val2                   out nocopy number,
                           p_child_rt_flag2         out nocopy varchar2,
                           p_ann_rt_val3            in out nocopy number,
                           p_cmcd_rt_val3           out nocopy number,
                           p_val3                   out nocopy number,
                           p_child_rt_flag3         out nocopy varchar2,
                           p_ann_rt_val4            in out nocopy number,
                           p_cmcd_rt_val4           out nocopy number,
                           p_val4                   out nocopy number,
                           p_child_rt_flag4         out nocopy varchar2  ) is
--
--If the rate setup is either Enter annual value or Set Annual Rate Equal to coverage we calculate the
--communicated amount and defined amount for that Rate and its child rates based on the
--remaining pay periods in the year.
--
cursor c_cmplt_year is
Select 'N'
From  ben_acty_base_rt_f
Where acty_base_rt_id=p_prnt_acty_base_rt_id
  and p_effective_date between effective_start_date and effective_end_date
  and (nvl(rt_mlt_cd,'XX')='SAREC' or entr_ann_val_flag='Y');
--
-- Find if enrt_rt_id is child of parent rate
--
cursor csr_is_child(c_enrt_rate_id number) is
select
     abr.val
    ,abr.RT_TYP_CD
    ,ecr.cmcd_acty_ref_perd_cd
from ben_acty_base_rt_f abr,
     ben_enrt_rt        ecr
where
      abr.PARNT_ACTY_BASE_RT_ID= p_prnt_acty_base_rt_id
  and abr.rt_mlt_cd='PRNT'
  and abr.ACTY_BASE_RT_ID = ecr.ACTY_BASE_RT_ID
  and ecr.enrt_rt_id=c_enrt_rate_id
  and p_effective_date between effective_start_date and effective_end_date;
--
-- Local variables
--
l_enrt_rt_id   number;
l_ann_rt_val   number;
l_cmcd_rt_val  number;
l_rt_val       number;
l_prnt_rt_value number;
l_chld_rt_value number;

l_operand             number;
l_operator            varchar2(30);
l_complete_year_flag  varchar2(10);
l_use_balance_flag    varchar2(10) :='N';
l_prnt_cmplt_year     varchar2(10);
l_cmcd_perd_cd        ben_enrt_rt.cmcd_acty_ref_perd_cd%TYPE;

l_trace_param          varchar2(30);
l_trace_on             boolean;
l_proc                 varchar2(200) := 'ben_distribute_rates.convert_pcr_rates_w';
--
BEGIN
--  hr_utility.trace_on(null,'BENDISRT');
  l_trace_param := null;
  l_trace_on := false;
  --
  l_trace_param := fnd_profile.value('BEN_SS_TRACE_VALUE');
  --
  if l_trace_param = 'BENDISRT' then
     l_trace_on := true;
  else
     l_trace_on := false;
  end if;
  --
  if l_trace_on then
    hr_utility.trace_on(null,'BENDISRT');
  end if;
  --
  hr_utility.set_location('l_trace_param : '|| l_trace_param, 5);
  hr_utility.set_location ('Entering '||l_proc,10);
  --
OPEN c_cmplt_year;
Fetch c_cmplt_year into l_complete_year_flag;
if c_cmplt_year%NOTFOUND
  THEN
    l_complete_year_flag :='Y';
end if;
l_prnt_cmplt_year :='Y';
if p_convert_from_rt = 'ANNUAL' AND l_complete_year_flag='N' then
    l_prnt_cmplt_year :='N';
end if;

if    p_rate_index =1 THEN l_enrt_rt_id :=p_enrt_rt_id;
elsif p_rate_index =2 THEN l_enrt_rt_id :=p_enrt_rt_id2;
elsif p_rate_index =3 THEN l_enrt_rt_id :=p_enrt_rt_id3;
elsif p_rate_index =4 THEN l_enrt_rt_id :=p_enrt_rt_id4;
end if;
          convert_rates_w(p_person_id		      				=> p_person_id,
			  									p_amount                    => p_amount,
                          p_enrt_rt_id                => l_enrt_rt_id,
                          p_elig_per_elctbl_chc_id    => p_elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd          => p_acty_ref_perd_cd,
                          p_cmcd_acty_ref_perd_cd     => p_cmcd_acty_ref_perd_cd,
                          p_business_group_id         => p_business_group_id,
                          p_effective_date            => p_effective_date,
                          p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt,
                          p_complete_year_flag        => l_prnt_cmplt_year,
                          p_use_balance_flag          => p_use_balance_flag,
                          p_start_date                => p_start_date,
                          p_end_date                  => p_end_date ,
                          p_payroll_id                => p_payroll_id ,
                          p_element_type_id           => p_element_type_id,
                          p_convert_from_rt           => p_convert_from_rt ,
                          p_ann_rt_val                => l_ann_rt_val,
                          p_cmcd_rt_val               => l_cmcd_rt_val ,
                          p_val                       => l_rt_val);
if    p_rate_index =1  THEN
      p_ann_rt_val  := l_ann_rt_val;
      p_cmcd_rt_val := l_cmcd_rt_val;
      p_val         := l_rt_val;
elsif p_rate_index =2  THEN
      p_ann_rt_val2  := l_ann_rt_val;
      p_cmcd_rt_val2 := l_cmcd_rt_val;
      p_val2         := l_rt_val;
elsif p_rate_index =3  THEN
      p_ann_rt_val3  := l_ann_rt_val;
      p_cmcd_rt_val3 := l_cmcd_rt_val;
      p_val3         := l_rt_val;
elsif p_rate_index =4  THEN
      p_ann_rt_val4  := l_ann_rt_val;
      p_cmcd_rt_val4 := l_cmcd_rt_val;
      p_val4         := l_rt_val;
end if;
l_prnt_rt_value :=l_ann_rt_val;
--
-- use balances only if parent is SAAEAR or SAREC
--
if l_complete_year_flag='N' then l_use_balance_flag :='Y'; end if;

-- 5104247 Set the child rate flags to 'N' by default
p_child_rt_flag  := 'N';
p_child_rt_flag2 := 'N';
p_child_rt_flag3 := 'N';
p_child_rt_flag4 := 'N';

--
-- We have right now only four rates displayed in SSBEN
--
For i in 1..4
LOOP
IF i <> p_rate_index THEN
    if    i =1 THEN l_enrt_rt_id :=p_enrt_rt_id;
    elsif i =2 THEN l_enrt_rt_id :=p_enrt_rt_id2;
    elsif i =3 THEN l_enrt_rt_id :=p_enrt_rt_id3;
    elsif i =4 THEN l_enrt_rt_id :=p_enrt_rt_id4;
    end if;

   --
   --If this rate is null, that means we have no further rates
   --
   if l_enrt_rt_id is null then exit; end if;
   OPEN csr_is_child(l_enrt_rt_id);
   FETCH csr_is_child into l_operand,l_operator,l_cmcd_perd_cd;
   IF csr_is_child%FOUND THEN
    benutils.rt_typ_calc
           (p_rt_typ_cd      => l_operator
           ,p_val            => l_operand
           ,p_val_2          => l_prnt_rt_value
           ,p_calculated_val => l_chld_rt_value);
    convert_rates_w(
                p_person_id		    					=>p_person_id,
								p_amount                    => l_chld_rt_value,
                p_enrt_rt_id                => l_enrt_rt_id,
                p_elig_per_elctbl_chc_id    => p_elig_per_elctbl_chc_id,
                p_acty_ref_perd_cd          => p_acty_ref_perd_cd,
                p_cmcd_acty_ref_perd_cd     => l_cmcd_perd_cd,
                p_business_group_id         => p_business_group_id,
                p_effective_date            => p_effective_date,
                p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt,
                p_complete_year_flag        => l_complete_year_flag,
                p_use_balance_flag          => l_use_balance_flag,
                p_start_date                => p_start_date,
                p_end_date                  => p_end_date,
                p_payroll_id                => p_payroll_id,
                p_element_type_id           => p_element_type_id,
                p_convert_from_rt           => 'ANNUAL',
                p_ann_rt_val                => l_ann_rt_val,
                p_cmcd_rt_val               => l_cmcd_rt_val,
                p_val                       => l_rt_val);
    if    i =1  THEN
      p_ann_rt_val  := l_ann_rt_val;
      p_cmcd_rt_val := l_cmcd_rt_val;
      p_val         := l_rt_val;
			p_child_rt_flag := 'Y'; -- 5104247
    elsif i=2  THEN
      p_ann_rt_val2  := l_ann_rt_val;
      p_cmcd_rt_val2 := l_cmcd_rt_val;
      p_val2         := l_rt_val;
			p_child_rt_flag2 := 'Y';
    elsif i =3  THEN
      p_ann_rt_val3  := l_ann_rt_val;
      p_cmcd_rt_val3 := l_cmcd_rt_val;
      p_val3         := l_rt_val;
			p_child_rt_flag3 := 'Y';
    elsif i =4  THEN
      p_ann_rt_val4  := l_ann_rt_val;
      p_cmcd_rt_val4 := l_cmcd_rt_val;
      p_val4         := l_rt_val;
			p_child_rt_flag4 := 'Y';
   end if;
  END IF; -- cursor found
  CLOSE csr_is_child;
 END IF; -- i <> p_rate_index
END LOOP;
--
  hr_utility.set_location ('Leaving '||l_proc,20);
  if l_trace_on then
    hr_utility.trace_off;
    l_trace_param := null;
    l_trace_on := false;
  end if;
--
EXCEPTION
When others then
     p_ann_rt_val    := null; -- no copy changes
     p_cmcd_rt_val   := null; -- no copy changes
     p_val           := null;
     p_ann_rt_val2    := null; -- no copy changes
     p_cmcd_rt_val2   := null; -- no copy changes
     p_val2           := null;
     p_ann_rt_val3    := null; -- no copy changes
     p_cmcd_rt_val3   := null; -- no copy changes
     p_val3           := null;
     p_ann_rt_val4    := null; -- no copy changes
     p_cmcd_rt_val4   := null; -- no copy changes
     p_val4           := null;
     if l_trace_on then
       hr_utility.trace_off;
       l_trace_param := null;
       l_trace_on := false;
     end if;
     raise;
END convert_pcr_rates_w;

end ben_distribute_rates;

/
