--------------------------------------------------------
--  DDL for Package Body BEN_DERIVE_FACTORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DERIVE_FACTORS" as
/* $Header: bendefct.pkb 120.14.12010000.3 2009/11/21 10:17:08 krupani ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|           Copyright (c) 1997 Oracle Corporation              |
|              Redwood Shores, California, USA             |
|                   All rights reserved.                   |
+==============================================================================+
Name:
    Derive Factors (external version)
Purpose:
    This program determines values for the six 'derivable factors'
    for a given person.
    For example DETERMINE_AGE will calculate the input persons age
    as of the age factor date.
    Each procedure can be called externally.
History:
        Date          Who        Version    What?
        ----          ---        -------    -----
        21-May-1998   Ty Hayden  110.0      Created.
        16 Jun 98     T Guy      110.01     Removed other exception.
        27-Jul-98     T Guy      110.2      Changed stated salary cursor to
                                            changed_date <= l_date and commented
                                            out nocopy return statements and put in
                                            fnd messages and exceptions.
        24-AUG-98     JMohapat   115.2      Added los and comb_age_los
                                            Procedure to this Package.
        08-OCT-98     G Perry    115.3      Corrected error messages.
        25-OCT-98     G Perry    115.4      Added in benefits balance type
                                            compensation level.
        26-OCT-98     G Perry    115.5      Fixed ben_elig_per_f cursor so
                                            it works for plans and programs.
        04-DEC-98     jcarpent   115.6      Allow null per_in_ler_id.
                                            Won't always have per_in_ler for
                                            non-event dependent elig checking
        10-Dec-98     T Guy      115.7      Fixed c_stated_salary cursor in
                                            determine_compensation.
        20-Dec-98     G Perry    115.8      Added support for compensation
                                            balances.
        21-Dec-98     jcarpent   115.9      added change date to det age
        18 Jan 99     G Perry    115.10     LED V ED
        09 Apr 99     S Tee      115.11     New salary schema.  Changed
                                            proposed_salary to
                                            proposed_salary_n.
        28 Apr 99     Shdas      115.12     Added contexts to rule calls.
        14 May 99     T Guy      115.13     Added annualization and periodizing
                                            for compensation.  We need to determine
                                            how to handle pay_basis type of PERIOD.
                                            For now we are treating it as if it
                                            has been annualized already.
        12 Jul 99     jcarpent   115.14     Added checks for backed out nocopy pil
        20-JUL-99     Gperry     115.15     genutils -> benutils package rename.
        04-AUG-99     T Guy      115.16     spouse and dependent age calculation
                                            removed nvl() of lf_evt_ocrd_dt for
                                            performance issues.
        30-AUG-99     pbodla     115.17     If called from what if analysis then
                                            user specifies the compensations to
                                            use then return user specified value
        10-Sep-99     maagrawa   115.18     Added p_start_date to determine_los.
        27-Oct-99     lmcdonal   115.19     Added some debugging messages.
        18-Nov-99     gperry     115.20     Corrected error messages.
        19-Nov-99     gperry     115.21     Fixed bug 4000.
                                            set l_effective_date based on
                                            whether life event mode is being
                                            used.
        22-Nov-99     pbodla     115.22     Bug 3299 : Passed bnfts_bal_id
                                            to ben_determine_date.main when
                                            comp_lvl_det_cd is evaluated.
        11-Jan-00     pbodla     115.23     run_rule function added to evaluate
                                            los_calc_rl
        24-Jan-00     lmcdonal   115.24     Add:
                                            los ohd calc, Bug 4069.
                                            los date-to-use-rl, bug 1161293.
                                            comp_calc_rl, bug 1118118.
                                            los_calc_rl, bug 1161293.
                                            Modify run_rule to return date.
        27-Jan-00     tguy       115.25     bug 1167919/4470
        11-Feb-00     bbulusu    115.26     bug 4068
        18-Feb-00     maagrawa   115.27     Removed the error
                                            BEN_91849_COMP_OBJECT_VAL_NULL from
                                            determine_age and determine_los
                                            so as to run without any comp.
                                            object (1169627).
        22-Feb-00     gperry     115.28     Fixed WWBUG 1118118.
        23-Feb-00     tguy       115.29     Fixed WWBUG 1120685,1161287,1178659
        28-Feb-00     tguy       115.30     Fixed WWBUG 1161293
        29-Feb-00     tguy       115.31     Fixed WWBUG 1179545
        07-Mar-00     tguy       115.32     Fixed Inherited codes in LOS
                                            determination
        14-Mar-00     maagrawa   115.33     Added p_calc_bal_to_date to
                                            determine_compensation.
                                            If this date is not null, use
                                            it to calculate balances.
        29-Mar-00     mmogel     115.34     I changed the message numbers from
                                            91382 to 91832 in the message name
                                            BEN_91382_PACKAGE_PARAM_NULL and the
                                            91383 to 92833 in the message name
                                            BEN_91833_CURSOR_RETURN_NO_ROW and
                                            added tokens to other messages to
                                            enhance current error messages
        24-may-00     tmicheal   115.35     bug 4844 fixed by intialising local value
                                            l_value to  p_value
        29-may-00     mhoyes     115.36   - Added p_per_dob to determine_age.
        21-jun-00     gperry     115.37     Fixed WWBUG 1329380.
                                            Now drive off salary basis and if
                                            that doesn't exist then drive
                                            off normal hours and frequency.
        26-jun-00     gperry     115.38     Added p_parent_person_id to
                                            determine_age so we can drive off
                                            the parent person id for
                                            dependents.
        27-jun-00     gperry     115.39     Added age_calc_rl support
        25-aug-00     kmahendr   115.40     Fixed WWBUG 1386872
                                            If cmp_lvl_fct is stated compensation and determination code is
                                            Use previous October 1 and if the participant is not having salary
                                            for previous october, then current salary will be taken for coverage
                                            calculation
       11-sep-00      tilak      115.41     bug 1393301 compensation calacualtion used per_annualization_
                                            factor instead of hardcoded hour and weeks
       14-sep-00      rchase     115.42     Leapfrog version based on 115.40.
                                            Include person_id as input to formula call in run_rule.
                                            This allows for processing individuals without assignments
       14-sep-00      jcarpent   115.43     Merge version of 115.41 and 115.42
       28-nov-00      tilak      115.44     for determinfing date l_person passed as param
                                            bug : 1510665
       30-nov-00      gperry     115.45     Fixed WWBUG 1522319.
                                            For compensation if you can't find
                                            value as of determination date then
                                            use life event occurred date.
       04-dec-00      tilak      115.46     changed in 115.44 is reversed , the validation for the
                                            dependent is added in bendetdt
       07-dec-00      rchase     115.47     Bug 1518211. Determine age parm p_dob
                                            is now an in/out parm.
                                            Leapfrog version based on 115.43.
       07-dec-00      jcarpent   115.48     Merge version of 115.47+115.46.

       07-dec-00      TMathers   115.49     Backport of 115.45 fixes issue.

       12-jan-01      kmahendr   115.50     Merge version of 115.48+115.49
       13-feb-01      tilak      115.51     bug : 1632450 c_stated_salary cursor
                                            changed to retrive annaulizatin factor and
                                            prposed_salary from same period
       14-feb-01      tilak      115.53     brout forward of lattest version 51 with leapfrog of 52
       27-Aug-01      ikasire    115.54     Bug 1949361 fixes to jurisdiction code
       06-dec-01      tjesumic   115.55     Salary calcualtion date setermination changed , bug 2124453
       11-dec-01      tjesumic   115.55     Salary calcualtion date setermination changed , bug 2124453
       12-dec-01      tjesumic   115.56     approved='y' added in c_stated salary to fetch
                                            only approved salary
       10-Jan-01      ikasire    115.59     Bug-2168233 fixed-  determine_los - added order by clause
                                            to get the right records for adjested service date
       30-jan-02      tjesumic   115.60     bug 2180602 procedure set_taxunnit_context
                                            called to set the tax_unit_id
                                            context before calling get_value
       15-feb-02      pabodla    115.61     bug 2202764 fix: When determine_compensation procedure
                                            is called from CWB plan if salary not found then return
                                            salary as 0.
       26-Mar-02      kmahendr   115.62     Bug#1833008 - Added a parameter to determine_comp-
                                            sation and multiple assignment is handled.
       30-Apr-02      kmahendr   115.63     Added token to message 91832
       08-Jun-02      pabodla    115.64     Do not select the contingent worker
                                            assignment when assignment data is
                                            fetched.
       04-Sep-02      kmahendr   115.65     New acty_ref_perd_cd added.
       16 Dec 02      hnarayan   115.66     Added NOCOPY hint

       9-JAN-2002     glingapp   115.67     Bug 2519393
       					    Created new message 93298 to make message more informative.
       					    Changed the cursor 'c_opt_typ_cd'.
       28-APR-2003    rpgupta    115.69     Bug 2924077
       					    Added a check on effective dates while
       					    picking up details of the person's spouse
       					    The same chk has been added to all cursors
       					    using per_contact_relationships
       14-JUL-2003    glingapp   115.70     added outer join on per_periods_of_service in
					    cursor c_person of determine_los
       24-Sep-2003    ikasire    115.71     Bug 3151737 - made the join to pay_all_payrolls_f
                                            as outer join and added the effective date
                                            clause for the same table.
       25-Nov-2003    bmanyam	 115.72	    Bug:3265142. Changed the cursor c_stated_salary.
                                            Fetching salary from per_assignment_extra_info.
                                            aei_information6 column for 'Benefit Assignment'
                                            records (ie. assignment_type = 'B')
       16-Dec-2003    ikasire    115.73     Bug: 3315997 When salary is not defined return with NULL
       17-Dec-03      vvprabhu   115.74     Added the assignment for g_debug at the start
       08-Apr-04      pbodla     115.75     FONM : use cvg start date or rate start
                                            date from processing.
                                            p_effective_date is overloaded.
       18-Apr-04      mmudigon   115.76     Universal Eligibility
       13-Jul-04      rpgupta    115.77     3752107: If no salary/ benefit balance is found on
                                            the determine date, 1st look at the closest assignment
                                            after the determine date
       13-aug-04      tjesumic   115,78     fonm parameter added
       28-sep-04      kmahendr   115.79     Bug#3899510 - cursor c_stated_salary modified
                                            to take assignment_id
       13-Oct-04      mmudigon   115.80     Forward port from 115.74.11510.4
                                            Bug 3818453. Added call to get_latest_paa_id()
       17-Feb-05      ssarkar    115.81     Bug 4120426--Called load_warnings in proc determine_compensation.
       23-feb-05      ssarkar    115.82     changed to_char(p_effective_date, 'DD-MON-RRRR')
					                        to fnd_date.date_to_displaydate(p_effective_date).
       07-apr-05      nhunur     115.83     apply fnd_number on what FF returns in run_rule.
       27-Apr-05      mmudigon   115.84     OIC integration. Addition of the
                                            codes 'OICAMTEARNED' and'OICAMTPAID'
       02-May-05      bmanyam    115.85    	Bug 4343063. Fixed a Typo..

       07-Jul-05      Tmathers   115.86    	Bug 4455689. changed
                      asg.assignment_id = nvl(p_assignment_id,asg.assignment_id)
                      into
                      ((asg.assignment_id = p_assignment_id)
                        or (p_assignment_id is null))
                      to fixe performance issue in 9.2.0.5.0
      19-jul-05       ssarkar    115.87      Bug : 4500760 : determine_date.main should be bypassed for OIC.
      21-jul-05       ssarkar    115.88      Bug : 4500760 : l_clf.proration_flag mapped to 'T'/'F' for OIC evaluation.
      27-jul-05       pbodla     115.89      Bug : 4509422 : p_init_msg_list is
                                             passed oic procedure to clear message
                                             stack.
      08-sep-05       pbodla     115.90      Bug 4509422 : Even if the oic code
                                             errors still we need to continue with
                                             0 values populated to l_comp_earned, l_comp_paid
                                             This is temp fix, once iic code is changed
                                             to handle no person data or setup not found cases
                                             then this error can be un commented again.
      06-Mar-2005    bmanyam    115.91       5075001 - To calculate Hourly Compensation (PHR)
                                             divide the  ANNUAL_VALUE by profile BEN_HRLY_ANAL_FCTR.
      27-Mar-2006    abparekh   115.92       Bug 5118063 : CWB : Fixed issue : when there is single pay
                                                           proposal with salary as zero, then p_value
                                                           remains unassigned.
      23-May-2006    nhunur     115.93       5187379 : avoid using secure views.
      18-Aug-2006    kmahendr   115.94       5473471 - Output parameter is assigned
                                             a value before return in determine_compensation
      29-Mar-2007    rtagarra   115.95       Bug 5931412 : To take care of short months case.
      09-Apr-2007    rtagarra   115.96       Bug 5931412 : Leap Year Case.
      08-Jun-2007    sshetty    115.97       Bug 6067726. Annualization factor will be
                                             derived from per_time_periods based on
                                             the payroll info if the
                                             Pay Annualization Factor value on Salary
                                             basis is null.
      31-Oct-2007    rtagarra   115.98       Bug 6601294: Fixed cursor c_stated_salary.
      19-Nov-2007    rtagarra   115.99       Bug 6627329 : Fixed cursor c_stated_salary for Perform Issue.
      23-Sep-2008    velvanop   115.100      Bug 7313778 : For determining the compensation of a rehired employee,
                                             rehire date should be used instead of the hire date.
      21-Nov-2009    krupani    115.101      Bug 9143371 : In procedure determine_age, l_effective_date was not
                                             getting initialized while running Maintain Designee Eligibility. Fixed the same.
*/
--------------------------------------------------------------------------------
--
g_package  varchar2(30) := 'ben_derive_factors.';
g_debug boolean := hr_utility.debug_enabled;
--
procedure run_rule
  (p_formula_id        in  number,
   p_rule_type         in  varchar2 default 'NUMBER',
   p_effective_date    in  date,
   p_lf_evt_ocrd_dt    in  date,
   p_business_group_id in  number,
   p_person_id         in  number,
   p_pgm_id            in  number,
   p_pl_id             in  number,
   p_oipl_id           in  number,
   p_plip_id           in  number,
   p_ptip_id           in  number,
   p_ret_date          out nocopy date,
   p_ret_val           out nocopy number,
   p_fonm_cvg_strt_dt  in  date default null,
   p_fonm_rt_strt_dt   in  date default null) is
  --
  l_package            varchar2(80) := g_package||'.run_rule';
  l_result             number;
  l_outputs            ff_exec.outputs_t;
  l_loc_rec            hr_locations_all%rowtype;
  l_ass_rec            per_all_assignments_f%rowtype;
  l_pil_rec            ben_per_in_ler%rowtype;
  l_pl_rec             ben_pl_f%rowtype;
  l_oipl_rec           ben_oipl_f%rowtype;
  l_jurisdiction_code  varchar2(30);
  l_env                ben_env_object.g_global_env_rec_type;
  --
begin
  --
  if g_debug then
    hr_utility.set_location ('Entering '||l_package,10);
    hr_utility.set_location('fonm_cvg :'||p_fonm_cvg_strt_dt  ,10);
    hr_utility.set_location('fonm_rt  :'||p_fonm_cvg_strt_dt,10);
  end if;
  --
  if p_oipl_id is not null then
    --
    ben_comp_object.get_object(p_rec     => l_oipl_rec,
                               p_oipl_id => p_oipl_id);
    --
  end if;
  --
  if p_pl_id is not null then
    --
    ben_comp_object.get_object(p_rec   => l_pl_rec,
                               p_pl_id => p_pl_id);
    --
  end if;
  --
  -- Call formula initialise routine
  --
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_ass_rec);
  --
  if l_ass_rec.assignment_id is null then
    --
    ben_person_object.get_benass_object(p_person_id => p_person_id,
                                        p_rec       => l_ass_rec);
    --
  end if;
  --
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_pil_rec);
  --
  if l_ass_rec.location_id is not null then
    --
    ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                   p_rec         => l_loc_rec);
    --
 --Bug 1949361 commented the following code
/*
    if l_loc_rec.region_2 is not null then
      --
      l_jurisdiction_code :=
         pay_mag_utils.lookup_jurisdiction_code
          (p_state => l_loc_rec.region_2);
      --
    end if;
*/
    --
  end if;
  --
  l_outputs := benutils.formula
    (p_formula_id        => p_formula_id,
     p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_assignment_id     => l_ass_rec.assignment_id,
     p_organization_id   => l_ass_rec.organization_id,
     p_business_group_id => p_business_group_id,
     p_pgm_id            => p_pgm_id,
     p_pl_id             => p_pl_id,
     p_pl_typ_id         => l_pl_rec.pl_typ_id,
     p_opt_id            => l_oipl_rec.opt_id,
     p_ler_id            => l_pil_rec.ler_id,
     p_jurisdiction_code => l_jurisdiction_code,
     --RCHASE Bug Fix - Include person_id for evaluating other than participants
     p_param1            => 'PERSON_ID',
     p_param1_value      => to_char(p_person_id),
     p_param2             => 'BEN_IV_RT_STRT_DT' ,
     p_param2_value       => fnd_date.date_to_canonical(p_fonm_rt_strt_dt) ,
     p_param3             => 'BEN_IV_CVG_STRT_DT' ,
     p_param3_value       => fnd_date.date_to_canonical(p_fonm_cvg_strt_dt)
     );
  --
  if p_rule_type = 'NUMBER' then
    --
    begin
      --
      p_ret_val := fnd_number.canonical_to_number(l_outputs(l_outputs.first).value);
      p_ret_date := null;
      --
    exception
      --
      when others then
        --
        fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
        fnd_message.set_token('PROC',l_package);
        fnd_message.set_token('FORMULA',p_formula_id);
        fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
        fnd_message.raise_error;
        --
    end;
    --
  elsif p_rule_type = 'DATE' then
    --
    begin
      --
      p_ret_date :=
      fnd_date.canonical_to_date(l_outputs(l_outputs.first).value);
      p_ret_val := null;
      --
    exception
      --
      when others then
        --
        fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
        fnd_message.set_token('PROC',l_package);
        fnd_message.set_token('FORMULA',p_formula_id);
        fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
        fnd_message.raise_error;
        --
    end;
    --
  else
    --
    if g_debug then
      hr_utility.set_location ('INVALID RULE TYPE PASSED'||l_package,99);
    end if;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,99);
  end if;
  --
exception
  --
  when others then
    --
    p_ret_date := null;
    p_ret_val  := null;
    raise;
end;
--
PROCEDURE determine_compensation
     (p_comp_lvl_fctr_id     in number,
      p_person_id            in number,
      p_pgm_id               in number    default null,
      p_pl_id                in number    default null,
      p_oipl_id              in number    default null,
      p_comp_obj_mode        in boolean   default true,
      p_per_in_ler_id        in number,
      p_business_group_id    in number,
      p_perform_rounding_flg in boolean default true,
      p_effective_date       in date,
      p_lf_evt_ocrd_dt       in date default null,
      p_fonm_cvg_strt_dt     in date default null,
      p_fonm_rt_strt_dt      in date default null,
      p_calc_bal_to_date     in date default null,
      p_cal_for              in varchar2  default null,
      p_value                out nocopy number) IS
  --
  l_proc varchar2(100) := g_package||'determine_compensation';
  l_effective_date date;
  l_comp_lvl_uom varchar2(30);
  l_comp_src_cd varchar2(30);
  l_comp_lvl_det_cd varchar2(30);
  l_comp_lvl_det_rl varchar2(30);
  l_rndg_cd varchar2(30);
  l_rndg_rl number;
  l_date date;
  l_value number;
  l_dummy_date date;
  --
  cursor c_clf is
    select clf.comp_lvl_uom,
           clf.comp_src_cd,
           clf.comp_lvl_det_cd,
           clf.comp_lvl_det_rl,
           clf.rndg_cd,
           clf.rndg_rl,
           clf.bnfts_bal_id,
           clf.defined_balance_id,
           clf.sttd_sal_prdcty_cd,
           clf.comp_calc_rl,
           clf.start_day_mo,
           clf.end_day_mo,
           clf.start_year,
           clf.end_year,
           clf.proration_flag
    from   ben_comp_lvl_fctr clf
    where  p_comp_lvl_fctr_id = clf.comp_lvl_fctr_id;
  --
  l_clf c_clf%rowtype;
  --
  -- cursor modified to get salary across all the assignments
  --
  --bug#3899510 - to fix rehire issue assignment id is added
  cursor c_stated_salary (p_primary_flag varchar2, p_assignment_id number) is
    select ppp.proposed_salary_n proposed_salary,
           ppb.pay_basis,
           ppb.pay_annualization_factor,
           paf.period_type payroll,
           asg.normal_hours,
           asg.payroll_id,
           asg.frequency,
           asg.assignment_id,
           ppp.change_date -- Bug:3265142. Added this for order-by clause
    from   per_pay_proposals ppp,
--           per_assignments_f asg,
	   per_all_assignments_f asg,
           per_pay_bases ppb,
           pay_all_payrolls_f paf,
           per_all_people_f per
    where  per.person_id = p_person_id

    /* Bug:3265142 Start: Fetching salary from per_pay_proposals for assignment_type = 'E'
     and per_assignment_extra_info.aei_information6 assignment_type = 'B' (Refer UNIONed-query).
    */
    --and   asg.assignment_type <> 'C'
    and    asg.assignment_type = 'E'
    -- Bug:3265142 End

    and    asg.person_id = per.person_id
-- 4455689
    and    ((asg.assignment_id = p_assignment_id)
          or (p_assignment_id is null))
   -- and    asg.primary_flag = 'Y'
    and    ((asg.primary_flag = p_primary_flag)
       or   ( p_primary_flag is null))
-- End of 4455689
    and    ppb.pay_basis_id = asg.pay_basis_id
    and    asg.payroll_id = paf.payroll_id(+)  -- Bug 3151737 Why do we need payroll here???
    and    l_date
           between nvl(paf.effective_start_date,l_date)
               and nvl(paf.effective_end_date,l_date)
    AND    nvl(ppp.approved,'N') =  'Y'
    --  and    l_effective_date
    and    l_date
           between asg.effective_start_date
           and     asg.effective_end_date
    and    l_date -- l_effective_date
           between per.effective_start_date
           and     per.effective_end_date
    and    asg.assignment_id = ppp.assignment_id
    and    ppp.change_date <= l_date
/* Bug:3265142 Start: Fetching salary from per_pay_proposals for assignment_type = 'E'
 and per_assignment_extra_info.aei_information6 assignment_type = 'B' (Refer UNIONed-query).
*/
UNION
    select fnd_number.canonical_to_number(aei.aei_information6) proposed_salary,
           ppb.pay_basis,
           ppb.pay_annualization_factor,
           paf.period_type payroll,
           asg.normal_hours,
           asg.payroll_id,
           asg.frequency,
           asg.assignment_id assignment_id,
		   fnd_date.canonical_to_date(aei.aei_information8) change_date
    from   --per_assignments_f asg,
	   per_all_assignments_f asg,
    	   per_assignment_extra_info aei,
           per_pay_bases ppb,
           pay_all_payrolls_f paf,
           per_all_people_f per
    where  per.person_id = p_person_id
	and    asg.assignment_type = 'B'
    and    asg.person_id = per.person_id
-- 4455689
    and    ((asg.assignment_id = p_assignment_id)
          or (p_assignment_id is null))
    and    ((asg.primary_flag = p_primary_flag)
       or   ( p_primary_flag is null))
-- End of 4455689
    and    ppb.pay_basis_id = asg.pay_basis_id
    and    asg.payroll_id = paf.payroll_id(+)
    and    l_date between nvl(paf.effective_start_date,l_date)and nvl(paf.effective_end_date,l_date)
    and    l_date between asg.effective_start_date and asg.effective_end_date -- 3752107
    --and    l_date <= asg.effective_end_date
    and    l_date between per.effective_start_date and per.effective_end_date
    and    asg.assignment_id = aei.assignment_id
    and not exists (select 1
					from  per_all_assignments_f asg,
					      per_all_people_f per
					where per.person_id = p_person_id
					and   asg.assignment_type = 'E'
					and   asg.person_id = per.person_id
					and   l_date between  asg.effective_start_date and asg.effective_end_date
					and   l_date  between per.effective_start_date and per.effective_end_date)
order  by 8, 9 desc;  -- Bug 6601294
--order  by asg.assignment_id,ppp.change_date desc;
-- Bug:3265142 End

  --
  l_salary c_stated_salary%rowtype;

  --
  --Bug 2202764
  --
  /*cursor c_opt_typ_cd is
   select opt.OPT_TYP_CD
   from BEN_PL_F pln, BEN_PL_TYP_f opt
   where opt.pl_typ_id = pln.pl_typ_id
   and   opt.OPT_TYP_CD = 'CWB'
   and   l_date
         between pln.effective_start_date
         and     pln.effective_end_date
   and   l_effective_date
         between opt.effective_start_date
   and   opt.effective_end_date;*/

   /*  Bug2519393  Changed the cursor c_opt_typ_cd.
       The old cursor was not using any of the parameters 'pgm_id','pl_id', 'oipl_id' and the cursor always
       returned 'CWB' as option type. The if condition using this cursor always passes as true irrespective of whether
       the plan type is CWB or not.
   */

   cursor c_opt_typ_cd is
   select distinct ptp.OPT_TYP_CD
      from BEN_PL_TYP_f ptp
      where ( p_pl_id is null
              or exists ( select 1
   		          from ben_pl_f pl1
   			  where pl1.pl_id = p_pl_id
   			   and  ptp.OPT_TYP_CD = 'CWB'
   			   and  pl1.pl_typ_id = ptp.pl_typ_id
   			   and  pl1.business_group_id = p_business_group_id
   			   and  l_effective_date between pl1.effective_start_date and   pl1.effective_end_date))
       and  ( p_oipl_id is null
              or exists ( select 1
   		          from ben_pl_f pl2 , ben_oipl_f oipl2
   			  where oipl2.oipl_id = p_oipl_id
   			   and  ptp.OPT_TYP_CD = 'CWB'
   			   and  pl2.pl_id  = oipl2.pl_id
   			   and  pl2.pl_typ_id = ptp.pl_typ_id
   			   and  pl2.business_group_id = p_business_group_id
   			   and  oipl2.business_group_id = p_business_group_id
   			   and  l_effective_date between oipl2.effective_start_date and   oipl2.effective_end_date
   			   and  l_effective_date between pl2.effective_start_date and   pl2.effective_end_date) )
       and  ( p_pgm_id is null
              or exists ( select 1
   		          from ben_ptip_f ptip
   			  where ptip.pgm_id = p_pgm_id
   			   and  ptp.OPT_TYP_CD = 'CWB'
   			   and  ptip.pl_typ_id  = ptp.pl_typ_id
   			   and  ptip.business_group_id = p_business_group_id
   			   and  l_effective_date between ptip.effective_start_date and   ptip.effective_end_date) )
       and  ptp.business_group_id = p_business_group_id
       and  l_effective_date between ptp.effective_start_date and   ptp.effective_end_date;

   --
   l_opt_typ_cd c_opt_typ_cd%rowtype;
   --

  cursor c_person_balance(p_date date) is
    select pbb.val, bnb.name
    from   ben_per_bnfts_bal_f pbb,
           ben_bnfts_bal_f bnb
    where  pbb.person_id = p_person_id
    and    pbb.business_group_id = p_business_group_id
    and    pbb.bnfts_bal_id = bnb.bnfts_bal_id
    and    p_date
           between bnb.effective_start_date
           and     bnb.effective_end_date
    and    p_date
           between pbb.effective_start_date
           and     pbb.effective_end_date
    and    pbb.bnfts_bal_id = l_clf.bnfts_bal_id;
  --
  l_person_balance c_person_balance%rowtype;
  --
  cursor c_assignment is
    select assignment_id
    from   per_all_assignments_f paf
    where  primary_flag = 'Y'
    and    person_id = p_person_id
    and    paf.assignment_type <> 'C'
    and    business_group_id = p_business_group_id
    and    l_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date
  order by decode(paf.assignment_type, 'E',1,2);

  Cursor c_ass is
      select min(effective_start_date)
      From  per_all_assignments_f ass
      where person_id = p_person_id
      and   ass.assignment_type <> 'C'
      and primary_flag = 'Y' ;

  -- 3752197
  Cursor c_ass_after_detdt is
      select min(effective_start_date)
      From  per_all_assignments_f ass
      where person_id = p_person_id
      and   ass.assignment_type <> 'C'
      and primary_flag = 'Y'
      and effective_start_Date >= l_date;
  --

  --
  cursor c_pgm is
     select uses_all_asmts_for_rts_flag
     from   ben_pgm_f pgm
     where  pgm.pgm_id = p_pgm_id
     and    l_effective_date between
            pgm.effective_start_date and pgm.effective_end_date;
  --
  cursor c_pln is
     select use_all_asnts_for_rt_flag
     from   ben_pl_f pln
     where  pln.pl_id = p_pl_id
     and    p_effective_date between
            pln.effective_start_date and pln.effective_end_date;

  cursor c_get_period_num (cp_payroll_id number,
                           cp_effective_date date) is
  select ptp.period_num  period_num
   from per_time_periods ptp
   where payroll_id=cp_payroll_id
     and to_char(cut_off_date,'RRRR')= to_char(cp_effective_date,'RRRR')
     order by 1 desc;
  --
  l_get_period_num c_get_period_num%rowtype;
  l_rate_flag   varchar2(200) := 'N';
  l_assignment c_assignment%rowtype;
  l_not_found boolean := false;
  l_bnb_rec           ben_bnfts_bal_f%ROWTYPE;
  l_primary_flag   varchar2(1):= 'Y';
  l_assignment_id  number := 0;
  l_pay_annualization_factor  number ;
  l_assignment_action_id  number;
  --
  -- FONM
  l_orig_effective_date   date;
  --
  l_start_date       date;
  l_end_date         date;
  l_ret_status       varchar2(30);
  l_msg_count        number;
  l_msg_data         varchar2(2000);
  l_comp_paid        number;
  l_comp_earned      number;
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering :'||l_proc,10);
    hr_utility.set_location('fonm_cvg :'||p_fonm_cvg_strt_dt  ,10);
    hr_utility.set_location('fonm_rt  :'||p_fonm_cvg_strt_dt,10);
  end if;
  --
  if p_effective_date is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_effective_date');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_person_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_person_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_comp_lvl_fctr_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_comp_lvl_fctr_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_business_group_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_business_group_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  end if;
  --
  if (p_comp_obj_mode and
      p_pl_id is null and
      p_oipl_id is null and
      p_pgm_id is null) then
    fnd_message.set_name('BEN','BEN_91849_COMP_OBJECT_VAL_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('BUSINESS_GROUP_ID',p_business_group_id);
    fnd_message.set_token('PER_IN_LER_ID',p_per_in_ler_id);
    fnd_message.raise_error;
  end if;
  --
   -- FONM
  --if ben_manage_life_events.fonm = 'Y' then
     --
      -- FONM : calling procedures pass the p_effective_date as
     -- nvl of fonm_rt_strt_dt, fonm_cvg_strt_dt, effective_date
     -- tilak : new fonm paramter passes the value no more overring the dates
     l_effective_date := nvl(nvl(p_fonm_rt_Strt_dt, p_fonm_cvg_strt_dt), p_lf_evt_ocrd_dt);
     --

     /* Bug 7313778: While determining the Compensation Level Derived factor eligibility of a Rehired Employee,
        l_effective_date is set to null, because of which assignment is not picked and Compensation is
	determined as of Hire Date instead of Rehire date*/
     if(l_effective_date is null) then
       l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     end if;


     l_orig_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --  else
     --
     --     l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --     l_orig_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --  end if;

  --
  open c_clf;
    --
    fetch c_clf into l_clf;
    if c_clf%notfound then
      close c_clf;
      fnd_message.set_name('BEN','BEN_91833_CURSOR_RETURN_NO_ROW');
      fnd_message.set_token('PACKAGE',l_proc);
      fnd_message.set_token('CURSOR','c_clf');
      fnd_message.raise_error;
    end if;
    --
  close c_clf;
  --
  --
  if p_cal_for = 'R' then
    --
    if p_pgm_id is not null then
       --
       open c_pgm;
       fetch c_pgm into l_rate_flag;
       close c_pgm;
       --
    end if;
    if l_rate_flag = 'N' then
       --
       open c_pln;
       fetch c_pln into l_rate_flag;
       close c_pln;
       --
    end if;
    --
  end if;
  --
  open c_assignment;
  --
  fetch c_assignment into l_assignment;
  --
  close c_assignment;
  --
  -- if the setup says sum all assignments then assign null to primary flag
  if l_rate_flag = 'Y' then
    --
    l_primary_flag := null;
    --
  end if;
  -- calculate date to be used in calculation.
  --
 if l_clf.comp_src_cd not in ('OICAMTEARNED','OICAMTPAID') then  --bug 4500760
  ben_determine_date.main
    (p_date_cd           => l_clf.comp_lvl_det_cd,
     p_per_in_ler_id     => p_per_in_ler_id,
     p_person_id         => p_person_id,
     p_pgm_id            => p_pgm_id,
     p_pl_id             => p_pl_id,
     p_oipl_id           => p_oipl_id,
     p_comp_obj_mode     => p_comp_obj_mode,
     p_business_group_id => p_business_group_id,
     p_formula_id        => l_clf.comp_lvl_det_rl,
     p_bnfts_bal_id      => l_clf.bnfts_bal_id,
     p_effective_date    => l_orig_effective_date, -- FONM
     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
     p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt,
     p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt,
     p_returned_date     => l_date);
  end if;
  --
  if l_date is null then
    --
    l_date := l_effective_date;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('l_date :'||l_date,450);
  end if;
  if g_debug then
    hr_utility.set_location('l_clf.comp_src_cd :'||l_clf.comp_src_cd,12);
  end if;
  if g_debug then
    hr_utility.set_location('p_comp_lvl_fctr_id :'||p_comp_lvl_fctr_id,12);
  end if;
  if g_debug then
    hr_utility.set_location('l_clf.bnfts_bal_id :'||l_clf.bnfts_bal_id,12);
  end if;
  --
  if l_clf.comp_calc_rl is not null then
    --
    run_rule
      (p_formula_id        => l_clf.comp_calc_rl,
       p_effective_date    => l_date,
       p_lf_evt_ocrd_dt    => l_date, -- nvl(p_lf_evt_ocrd_dt, l_date), -- FONM why pass l_date 999
       p_business_group_id => p_business_group_id,
       p_person_id         => p_person_id,
       p_pgm_id            => p_pgm_id,
       p_pl_id             => p_pl_id,
       p_oipl_id           => p_oipl_id,
       p_plip_id           => null,
       p_ptip_id           => null,
       p_ret_date          => l_dummy_date,
       p_ret_val           => p_value,
       p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt,
       p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt);
    --
    l_value := p_value;
    --
    if l_value is null then
      --
      fnd_message.set_name('BEN','BEN_92319_SAL_BALANCE_NULL');
      fnd_message.set_token('DATE',l_date);
      benutils.write(p_text=> fnd_message.get);
      --
      -- try with todays date
      --
      run_rule
        (p_formula_id        => l_clf.comp_calc_rl,
         p_effective_date    => l_orig_effective_date, -- FONM
         p_lf_evt_ocrd_dt    => p_effective_date, -- FONM : why p_effective_date as ???
         p_business_group_id => p_business_group_id,
         p_person_id         => p_person_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_oipl_id           => p_oipl_id,
         p_plip_id           => null,
         p_ptip_id           => null,
         p_ret_date          => l_dummy_date,
         p_ret_val           => p_value,
         p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt);
      --
      l_value := p_value;
      --
      IF l_value IS NULL THEN
        --
        fnd_message.set_name('BEN','BEN_92319_SAL_BALANCE_NULL');
        fnd_message.set_token('DATE',p_effective_date);
        benutils.write(p_text=> fnd_message.get);
        return;
        --
      END IF;
      --
    end if;
    --
  elsif l_clf.comp_src_cd in ('OICAMTEARNED','OICAMTPAID') then

    hr_utility.set_location('Inside OIC call',20);
    declare

    begin
       l_start_date := to_date(l_clf.start_day_mo||nvl(l_clf.start_year,to_char(l_date,'YYYY')),'DDMMYYYY');
       l_end_date := to_date(l_clf.end_day_mo||nvl(l_clf.end_year,to_char(l_date,'YYYY')),'DDMMYYYY');
    exception
       when others then
          fnd_message.set_name('BEN','BEN_92603_INVALID_DATE');
          fnd_message.raise_error;
    end;

    if l_start_date > l_end_date then
       fnd_message.set_name('BEN','BEN_91824_START_DT_AFTR_END_DT');
       fnd_message.set_token('PROC',l_proc);
       fnd_message.set_token('START_DT',l_start_date);
       fnd_message.set_token('END_DT',l_end_date);
       fnd_message.raise_error;
    end if;

    -- 4500760
    if l_clf.proration_flag = 'Y' then
       l_clf.proration_flag := FND_API.G_TRUE;
    else
	l_clf.proration_flag := FND_API.G_FALSE;
    end if;
   -- 4500760

    cn_get_comm_pmt_paid_grp.get_comm_and_paid_pmt
    (p_api_version            => 1
    ,p_person_id              => p_person_id
    ,p_start_date             => l_start_date
    ,p_end_date               => l_end_date
    ,p_target_currency_code   => l_clf.comp_lvl_uom
    ,p_proration_flag         => l_clf.proration_flag
    ,p_init_msg_list          => FND_API.G_TRUE -- 'TRUE'
    ,x_return_status          => l_ret_status
    ,x_msg_count              => l_msg_count
    ,x_msg_data               => l_msg_data
    ,x_comp_earned            => l_comp_earned
    ,x_comp_paid              => l_comp_paid
    ,x_new_start_date         => l_dummy_date
    ,x_new_end_date           => l_dummy_date);

    hr_utility.set_location('msg = '||substr(l_msg_data,1,100), 999);
    hr_utility.set_location('l_start_date = '||l_start_date, 999);
    hr_utility.set_location('l_end_date = '||l_end_date, 999);
    hr_utility.set_location('l_clf.comp_lvl_uom = '||l_clf.comp_lvl_uom, 999);
    hr_utility.set_location('l_clf.proration_flag = '||l_clf.proration_flag, 999);
    hr_utility.set_location('l_msg_count = '||l_msg_count, 999);
    if l_ret_status in ('E','U') then
       -- Bug 4509422 : Even if the oic code errors still we need to
       -- continue with 0 values populated to l_comp_earned, l_comp_paid
       -- This is temp fix, once iic code is changed to handle no person data
       -- or setup not found cases then this error can be un commented again.
       --
       /*
       fnd_message.set_name('BEN','BEN_93934_CWB_EMP_SAVE_API_ERR');
       fnd_message.set_token('NAME','CN_GET_COMM_PMT_PAID_GRP');
       fnd_message.set_token('MESSAGE',substr(l_msg_data,1,100));
       fnd_message.raise_error;
       */
       benutils.write(p_text=> substr(l_msg_data,1,100));
       l_comp_earned := 0;
       l_comp_paid   := 0;
       --
    end if;

    if l_clf.comp_src_cd = 'OICAMTEARNED' then
       l_value := l_comp_earned;
    else
       l_value := l_comp_paid;
    end if;
    --
    IF l_value IS NULL THEN
      --
      hr_utility.set_location('null value returned ',20);
      return;
      --
    END IF;
    --
  elsif l_clf.comp_src_cd = 'STTDCOMP' then
    --
    if ben_whatif_elig.g_stat_comp is not null then
      --
      -- This is the case where benmngle is called from the
      -- watif form and user wants to simulate compensation level
      -- changed. Use the user supplied compensation value rather
      -- than the fetched value.
      --
      l_value := ben_whatif_elig.g_stat_comp;
      --
    else
      --
      open c_stated_salary (l_primary_flag, l_assignment.assignment_id);
        --
        fetch c_stated_salary into l_salary;
        if c_stated_salary%NOTFOUND then
          --
          -- then take current salary
          --
          l_not_found := true;
          --
        end if;
        --
      close c_stated_salary;
      ---if date code is
      -- first of year,half year,quarter,month,semi month,previos oct 1
      -- then take the first salary

      if l_not_found then

         if l_clf.comp_lvl_det_cd in
              ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then
              -- 3752107
              -- Find the sal on the min ass start date after the determined date
              open c_ass_after_detdt;
              fetch c_ass_after_detdt into l_date;
              close c_ass_after_detdt;
              --
              hr_utility.set_location('next date after det date is:'||l_date, 233);

              --
              -- there is an assignment after the det dt, find the sal as of that date
              -- else, l_not_found would anyway remain true and it would call c_ass

              if l_date is not null then
                open c_stated_salary (l_primary_flag, l_assignment.assignment_id);
                fetch c_stated_salary into l_salary;
                hr_utility.set_location('l_salary with nxt dt is:'||l_salary.proposed_salary, 234);
                if c_stated_salary%NOTFOUND then
                  l_not_found := true;
                  --
                else
                  l_not_found := false;
                end if;
                close c_stated_salary;
              end if;

              if l_not_found then
              hr_utility.set_location('no sal found - resort to old means:'||l_salary.proposed_salary, 234);
              -- end 3752107
                open c_ass ;
                fetch c_ass into l_date ;
                close c_ass ;
                hr_utility.set_location('min l_date is:'||l_date, 234);

                 open c_stated_salary (l_primary_flag, l_assignment.assignment_id);
                 fetch c_stated_salary into l_salary;
                 hr_utility.set_location('l_salary with min dt is:'||l_salary.proposed_salary, 234);
                 if c_stated_salary%NOTFOUND then
                     -- then take current salary
                     l_not_found := true;
                     --
                 else
                  l_not_found := false;
                 end if;

              --
                close c_stated_salary;
              --
              end if;


          end if ;


      end if ;

      if l_not_found then
        --
        l_date := l_effective_date;
        --
        open c_stated_salary (l_primary_flag , l_assignment.assignment_id);
          --
          fetch c_stated_salary into l_salary;
          --
          if c_stated_salary%NOTFOUND then
            --
            --Bug 2202764
            --
            l_opt_typ_cd.opt_typ_cd := 'YYY';
            open c_opt_typ_cd;
            fetch c_opt_typ_cd into l_opt_typ_cd;
            close c_opt_typ_cd;
            if nvl(l_opt_typ_cd.opt_typ_cd, 'YYY') ='CWB' then
             l_value := 0;
             l_salary.proposed_salary := 0;
            else
              fnd_message.set_name('BEN','BEN_93298_SAL_NOT_DFND');
                                 --Bug 2519393 Message made more clear.
              -- start bug # 4185334 -- changed the tokens --
		fnd_message.set_token('PARMA','c_stated_salary');
                fnd_message.set_token('PARMB',l_proc);
		fnd_message.set_token('PARMC',fnd_date.date_to_displaydate(p_effective_date));
                fnd_message.set_token('PARM1',p_person_id);
              --- end bug  # 4185334
              /*
              fnd_message.raise_error;
              */
              --
              -- BUG 3315997
              --
              l_value := NULL ;
              p_value := l_value ;
              --
	      --start bug # 4185334 -- called load_warnings
	      ben_warnings.load_warning
               (p_application_short_name  => 'BEN',
                p_message_name            => 'BEN_93298_SAL_NOT_DFND',
		p_parma                   => 'c_stated_salary',
		p_parmb                   => l_proc,
		p_parmc                   => fnd_date.date_to_displaydate(p_effective_date),
		p_parm1                   => p_person_id,
                p_person_id               => p_person_id);
              -- end bug # 4185334
              benutils.write(p_text=> fnd_message.get);
              return;
              --
            end if;
            --
          end if;
          --
        close c_stated_salary;
        --
      end if;
      --
      if g_debug then
        hr_utility.set_location('Primary flag'||l_primary_flag,100);
      end if;
      if g_debug then
        hr_utility.set_location('l_effective_date'||l_effective_date,101);
      end if;
      for i in c_stated_salary (l_primary_flag, null)
      loop
        --
        exit when l_salary.proposed_salary = 0;
        --
        if i.assignment_id <> l_assignment_id then
         if g_debug then
           hr_utility.set_location('Pay basis'|| i.pay_basis, 102);
         end if;
          if i.pay_basis is not null then
            --
            -- Assumption no multi assignment for annualization factor
            l_pay_annualization_factor  := i.pay_annualization_factor;
            --fix for bug#6067726.
            --Considering that the value entered
            -- in pay annualization_factor in salary basis form
            -- always overrides the period number of payroll

            if l_pay_annualization_factor is null then
            open c_get_period_num (i.payroll_id, l_effective_date);
             fetch c_get_period_num into l_get_period_num;
            close c_get_period_num;
            l_pay_annualization_factor := l_get_period_num.period_num;
            end if;
            l_value := i.proposed_salary *
                       nvl(l_pay_annualization_factor,1) + nvl(l_value,0);
            --
          elsif i.frequency is not null and
            i.normal_hours is not null then
            --
            if i.frequency = 'D' then
              --
              -- assumption is 5 days a week * 52 weeks in a year = 260 working days
              --
              l_value := i.proposed_salary * (i.normal_hours*260) + nvl(l_value,0);
              --
            elsif i.frequency = 'W' then
              --
              l_value := i.proposed_salary * (i.normal_hours*52) + nvl(l_value,0);
              --
            elsif i.frequency = 'M' then
              --
              l_value := i.proposed_salary * (i.normal_hours*12) + nvl(l_value,0);
              --
            elsif i.frequency = 'Y' then
              --
              l_value := i.proposed_salary + nvl(l_value,0);
              --
            else
              --
              fnd_message.set_name('BEN','BEN_92463_INVALID_FREQUENCY');
              fnd_message.set_token('PACKAGE',l_proc);
              fnd_message.set_token('PERSON_ID',p_person_id);
              fnd_message.set_token('BUSINESS_GROUP_ID',p_business_group_id);
              fnd_message.set_token('COMP_LVL_FCTR_ID',p_comp_lvl_fctr_id);
              fnd_message.set_token('PGM_ID',p_pgm_id);
              fnd_message.set_token('PL_ID',p_pl_id);
              fnd_message.set_token('OIPL_ID',p_oipl_id);
              fnd_message.raise_error;
              --
            end if;
            --
          end if;
          --
        end if;
        l_assignment_id := i.assignment_id;
        --
      end loop;
      --
      /* Bug 5118063 : If there is only one proposal which is zero, then l_value returns as
                       unassigned, so set it properly
      */
      if l_salary.proposed_salary = 0 and l_value is null
      then
        --
        l_value := l_salary.proposed_salary ;
        --
      end if;
      --
    end if; -- what if end if
    --
    -- if the annualization factor is null get it from profile
/*  5075001 -- Commented this part.
    if l_pay_annualization_factor is null then
       l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
       if l_pay_annualization_factor is null then
         l_pay_annualization_factor := 2080;
       end if;
    end if;
*/
    --  Now take annualized salary and translate it into the appropriate
    --  acty ref period as defined by the plan or program
    --
    --  Per Week
    --
    if g_debug then
      hr_utility.set_location('l_clf.sttd_sal_prdcty_cd :'||l_clf.sttd_sal_prdcty_cd,18);
    end if;
    if l_clf.sttd_sal_prdcty_cd = 'PWK' then
      --
      l_value := l_value/52;
      --
      --  Bi-Weekly
      --
    elsif l_clf.sttd_sal_prdcty_cd = 'BWK' then
      --
      l_value := l_value/26;
      --
      --  Semi-Monthly
      --
    elsif l_clf.sttd_sal_prdcty_cd = 'SMO' then
      --
      l_value := l_value/24;
      --
      --  Per Quarter
      --
    elsif l_clf.sttd_sal_prdcty_cd = 'PQU' then
      --
      l_value := l_value/4;
      --
      --  Per Year
      --   don't really need to do this since l_value is already periodized,
      --   but to make it easier to read we'll go ahead and go through the
      --   motions.
      --
    elsif l_clf.sttd_sal_prdcty_cd = 'PYR' then
      --
      l_value := l_value;
      --
      --  Semi-Annual
      --
    elsif l_clf.sttd_sal_prdcty_cd = 'SAN' then
      --
      l_value := l_value/2;
      --
      --  Monthly
      --
    elsif l_clf.sttd_sal_prdcty_cd = 'MO' then
      --
      l_value := l_value/12;
      --
      --
    elsif l_clf.sttd_sal_prdcty_cd = 'PHR' then
       --
       -- 5075001 : Hourly Compensation. Get from Profile
       -- Else, default to 2080.
       --
       l_pay_annualization_factor := NVL(to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR')),2080);
       --
       l_value := l_value/l_pay_annualization_factor;
       --
      --  Unknown periodicity, Error out
    else
      --
      fnd_message.set_name('BEN','BEN_92465_INVALID_PRDCTY_CD');
      fnd_message.set_token('PACKAGE',l_proc);
      fnd_message.set_token('PERSON_ID',p_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',p_business_group_id);
      fnd_message.set_token('COMP_LVL_FCTR_ID',p_comp_lvl_fctr_id);
      fnd_message.set_token('PGM_ID',p_pgm_id);
      fnd_message.set_token('PL_ID',p_pl_id);
      fnd_message.set_token('OIPL_ID',p_oipl_id);
      fnd_message.raise_error;
      --
    end if;
    --
  elsif l_clf.comp_src_cd = 'BALTYP' then
    --
    if ben_whatif_elig.g_bal_comp is not null then
      --
      -- This is the case where benmngle is called from the
      -- watif form and user wants to simulate compensation level
      -- changed. Use the user supplied compensation value rather
      -- than the fetched value.
      --
      l_value := ben_whatif_elig.g_bal_comp;
      --
    else


        ben_derive_part_and_rate_facts.set_taxunit_context
            (p_person_id           =>     p_person_id
            ,p_business_group_id   =>     p_business_group_id
            ,p_effective_date      =>     l_effective_date
             ) ;

      --
      open c_assignment;
        --
        fetch c_assignment into l_assignment;
        --
      close c_assignment;
        --
        -- Bug 3818453. Pass assignment_action_id to get_value() to
        -- improve performance
        --
        l_assignment_action_id :=
                          ben_derive_part_and_rate_facts.get_latest_paa_id
                          (p_person_id         => p_person_id
                          ,p_business_group_id => p_business_group_id
                          ,p_effective_date    => nvl(p_calc_bal_to_date,l_date));

        if l_assignment_action_id is not null then
           --
           begin
              l_value  :=
              pay_balance_pkg.get_value(l_clf.defined_balance_id
              ,l_assignment_action_id);
           exception
             when others then
             l_value := null ;
           end ;
           --
          --
        end if ;

        if l_value is null then
           fnd_message.set_name('BEN' ,'BEN_92318_BEN_BALANCE_NULL');
           fnd_message.set_token('DATE' ,nvl(p_calc_bal_to_date,l_date));
           benutils.write(p_text=> fnd_message.get);
           return;
        end if;

        --
        -- old code prior to 3818453
        --
/* ---- exception is not handled in the function
      begin
         l_value := pay_balance_pkg.get_value
            (l_clf.defined_balance_id,
             l_assignment.assignment_id,
             nvl(p_calc_bal_to_date,l_date));
      exception
         when others then
             l_value := null ;
      end ;
      --
      IF l_value IS NULL THEN
         begin
            if l_clf.comp_lvl_det_cd in
              ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then

              -- 3752107
              -- Find the bal on the min ass start date after the determined date
              open c_ass_after_detdt;
              fetch c_ass_after_detdt into l_date;
              close c_ass_after_detdt;

              -- there is an assignment after the det dt, find the sal as of that date
              -- else, l_not_found would anyway remain true and it would call c_ass

              if l_date is not null then
              begin
                l_value := pay_balance_pkg.get_value
                  (l_clf.defined_balance_id,
                  l_assignment.assignment_id,
                  l_date);
              exception
              when others then
                l_value := null;
              end;
              end if; -- l_date is not null

              if l_value is null then
              -- end 3752107

                open c_ass ;
                fetch c_ass into l_date ;
                close c_ass ;
                if g_debug then
                  hr_utility.set_location( ' in first of year ' || l_clf.comp_lvl_det_cd || l_date, 450);
                end if;
                l_value := pay_balance_pkg.get_value
                  (l_clf.defined_balance_id,
                  l_assignment.assignment_id,
                  l_date);

              end if ;--l_value is null
            end if;--l_clf.comp_lvl_det_cd in
           exception
             when others then
                 l_value := null ;
           end ;

         Begin

            IF l_value IS NULL THEN
            --
            -- Person does not have a balance, recheck if they have a balance
            -- as of the life event occurred date or effective date.
            -- Fix for bug 216.
            --
            fnd_message.set_name('BEN','BEN_92318_BEN_BALANCE_NULL');
            fnd_message.set_token('DATE',l_date);
            benutils.write(p_text=> fnd_message.get);
            l_value :=
              pay_balance_pkg.get_value(l_clf.defined_balance_id,
                                    l_assignment.assignment_id,
                                    p_effective_date);
            --
            IF l_value IS NULL THEN
              --
              fnd_message.set_name('BEN','BEN_92318_BEN_BALANCE_NULL');
              fnd_message.set_token('DATE',p_effective_date);
              benutils.write(p_text=> fnd_message.get);
              RETURN;
              --
            END IF;
            --
          END IF;
          --
         exception
           when others then
              fnd_message.set_name('BEN','BEN_92318_BEN_BALANCE_NULL');
              fnd_message.set_token('DATE',p_effective_date);
              benutils.write(p_text=> fnd_message.get);
              RETURN;
         end ;

      End If ; */
    end if;
    --
  elsif l_clf.comp_src_cd = 'BNFTBALTYP' then
    --
    if ben_whatif_elig.g_bnft_bal_comp is not null then
      --
      -- This is the case where benmngle is called from the
      -- watif form and user wants to simulate compensation level
      -- changed. Use the user supplied compensation value rather
      -- than the fetched value.
      --
      l_value := ben_whatif_elig.g_bnft_bal_comp;
      --
    else
      --
      if g_debug then
        hr_utility.set_location( ' calc_bal_date ' || p_calc_bal_to_date,450) ;
      end if;
      if g_debug then
        hr_utility.set_location( ' l_date ' || l_date,450) ;
      end if;
      open c_person_balance(nvl(p_calc_bal_to_date,l_date));
      --
      fetch c_person_balance into l_person_balance;
      l_value := l_person_balance.val;
        --
      close c_person_balance;
      --
      if l_value is null then
         if l_clf.comp_lvl_det_cd in
            ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then

              -- 3752107
              -- Find the per bal on the min ass start date after the determined date
              open c_ass_after_detdt;
              fetch c_ass_after_detdt into l_date;
              close c_ass_after_detdt;

              -- there is an assignment after the det dt, find the sal as of that date
              -- else, l_not_found would anyway remain true and it would call c_ass

              if l_date is not null then
                open c_person_balance(l_date);
                --
                fetch c_person_balance into l_person_balance;
                l_value := l_person_balance.val;
                --
                close c_person_balance;
              end if;

              if l_value is null then
              -- end 3752107
            -- end paste

                open c_ass ;
                fetch c_ass into l_date ;
                close c_ass ;
                if g_debug then
                  hr_utility.set_location( ' in first of year ' || l_clf.comp_lvl_det_cd || l_date, 450);
                end if;
                open c_person_balance(l_date);
                --
                fetch c_person_balance into l_person_balance;
                l_value := l_person_balance.val;
                --
                close c_person_balance;
              end if;  --l_value is null -- 3752107
         end if;--l_clf.comp_lvl_det_cd in

         if l_value is null then
            --
            -- FONM : This cache routine should fetch the data as of
            -- cvg based effective_date.
            --
            ben_person_object.get_object(p_bnfts_bal_id => l_clf.bnfts_bal_id,
                                     p_rec          => l_bnb_rec);
            --
            fnd_message.set_name('BEN','BEN_92317_PER_BALANCE_NULL');
            fnd_message.set_token('NAME',l_bnb_rec.name);
            fnd_message.set_token('DATE',l_date);
            benutils.write(p_text=> fnd_message.get);
            --
            l_date := l_effective_date;
            --
            open c_person_balance(l_date);
            --
            fetch c_person_balance into l_person_balance;
            l_value := l_person_balance.val;
            --
            close c_person_balance;
            --
            IF l_value IS NULL THEN
              --
              --Bug 2202764
              l_opt_typ_cd.opt_typ_cd := 'YYY';
              open c_opt_typ_cd;
              fetch c_opt_typ_cd into l_opt_typ_cd;
              close c_opt_typ_cd;
              if nvl(l_opt_typ_cd.opt_typ_cd, 'YYY') ='CWB' then
                l_value := 0;
                p_value := l_value;
              else
                fnd_message.set_name('BEN','BEN_92317_PER_BALANCE_NULL');
                fnd_message.set_token('NAME',l_bnb_rec.name);
                fnd_message.set_token('DATE',p_effective_date);
                benutils.write(p_text=> fnd_message.get);
              end if;
              RETURN;
              --
            END IF;
            --
         end if;
         --
      End if ;
    end if;
    --
  end if;
  --
  -- perform appropriate rounding based on the source table.
  -- rounding_cd or rule cannot both be null, perform_rounding_flag
  -- must be true....
  --
  if (l_clf.rndg_cd is not null or
      l_clf.rndg_rl is not null) and
      p_perform_rounding_flg = true
      and l_value is not null then
    --
    p_value := benutils.do_rounding
             (p_rounding_cd     => l_clf.rndg_cd,
              p_rounding_rl     => l_clf.rndg_rl,
              p_value           => l_value,
              p_effective_date  => nvl(p_lf_evt_ocrd_dt,p_effective_date));
    --
  else
    --
    p_value := l_value;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('p_value :'||p_value,10);
  end if;
  if g_debug then
    hr_utility.set_location('Leaving :'||l_proc,10);
  end if;
  --
exception
  --
  when others then
    --
    p_value := null;
    raise;
    --
end determine_compensation;
--
---------------------------------------------------------------------------
--
PROCEDURE determine_age
  (p_person_id         in number
  --RCHASE add out
  ,p_per_dob           in out nocopy date
  --End RCHASE
  ,p_age_fctr_id       in number
  ,p_pgm_id            in number    default null
  ,p_pl_id             in number    default null
  ,p_oipl_id           in number    default null
  ,p_comp_obj_mode     in boolean   default true
  ,p_per_in_ler_id     in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date default null
  ,p_fonm_cvg_strt_dt  in date default null
  ,p_fonm_rt_strt_dt   in date default null
  ,p_business_group_id in number
  ,p_perform_rounding_flg in boolean default true
  ,p_value             out nocopy number
  ,p_change_date       out nocopy date
  ,p_parent_person_id  in number default null
  )
is
  --
  l_value            number;
  l_date             date;
  l_proc             varchar2(80) := g_package||'determine_age';
  l_effective_date   date;
  l_person_id        number;
  -- FONM
  l_orig_effective_date   date;
  -- FONM
  --
  cursor   c_per is
    select per.date_of_birth
    from   per_all_people_f per
    where  per.person_id = p_person_id
    and    per.business_group_id = p_business_group_id
    and    l_effective_date
           between per.effective_start_date
           and     per.effective_end_date;
  --

  cursor  c_per_spouse(l_person_id number) is
    select per.date_of_birth
      from per_contact_relationships ctr,
           per_all_people_f per
     where ctr.person_id = l_person_id
       and per.person_id = ctr.contact_person_id
       and per.business_group_id = p_business_group_id
       and ctr.personal_flag = 'Y'
       and ctr.contact_type = 'S'
       and l_effective_date
           between per.effective_start_date
           and     per.effective_end_date
       /* bug 2924077 */
       and l_effective_date
           between nvl(ctr.date_start, hr_api.g_sot)
           and     nvl(ctr.date_end, hr_api.g_eot);
  --
  cursor  c_per_depen_first(l_person_id number) is
    select per.date_of_birth
      from per_contact_relationships ctr,
           per_all_people_f per
     where ctr.person_id = l_person_id
       and per.person_id = ctr.contact_person_id
       and per.business_group_id = p_business_group_id
       and ctr.personal_flag = 'Y'
       and ctr.dependent_flag = 'Y'
       and l_effective_date
           between per.effective_start_date
           and     per.effective_end_date
       /* bug 2924077 */
       and l_effective_date
           between nvl(ctr.date_start, hr_api.g_sot)
           and     nvl(ctr.date_end, hr_api.g_eot);

  --
  cursor  c_per_child_first(l_person_id number) is
    select per.date_of_birth
      from per_contact_relationships ctr,
           per_all_people_f per
     where ctr.person_id = l_person_id
       and per.person_id = ctr.contact_person_id
       and per.business_group_id = p_business_group_id
       and ctr.personal_flag = 'Y'
       and ctr.contact_type in ('C','O','A','T')
       and l_effective_date
           between per.effective_start_date
           and     per.effective_end_date
       /* bug 2924077 */
       and l_effective_date
           between nvl(ctr.date_start, hr_api.g_sot)
           and     nvl(ctr.date_end, hr_api.g_eot);

  --
  cursor  c_per_depen_oldest(l_person_id number) is
    select min(per.date_of_birth)
      from per_contact_relationships ctr,
           per_all_people_f per
     where ctr.person_id = l_person_id
       and per.person_id = ctr.contact_person_id
       and per.business_group_id = p_business_group_id
       and ctr.personal_flag = 'Y'
       and ctr.dependent_flag = 'Y'
       and l_effective_date
           between per.effective_start_date
           and     per.effective_end_date
       /* bug 2924077 */
       and l_effective_date
           between nvl(ctr.date_start, hr_api.g_sot)
           and     nvl(ctr.date_end, hr_api.g_eot)
     order by per.date_of_birth;
  --
  cursor  c_per_child_oldest(l_person_id number) is
    select min(per.date_of_birth)
      from per_contact_relationships ctr,
           per_all_people_f per
     where ctr.person_id = l_person_id
       and per.person_id = ctr.contact_person_id
       and per.business_group_id = p_business_group_id
       and ctr.personal_flag = 'Y'
       and ctr.contact_type in ('C','O','A','T')
       and l_effective_date
           between per.effective_start_date
           and     per.effective_end_date
       /* bug 2924077 */
       and l_effective_date
           between nvl(ctr.date_start, hr_api.g_sot)
           and     nvl(ctr.date_end, hr_api.g_eot)
     order by per.date_of_birth;
  --
  cursor  c_per_depen_young(l_person_id number) is
    select max(per.date_of_birth)
      from per_contact_relationships ctr,
           per_all_people_f per
     where ctr.person_id = l_person_id
       and per.person_id = ctr.contact_person_id
       and per.business_group_id = p_business_group_id
       and ctr.personal_flag = 'Y'
       and ctr.dependent_flag = 'Y'
       and l_effective_date
           between per.effective_start_date
           and     per.effective_end_date
       /* bug 2924077 */
       and l_effective_date
           between nvl(ctr.date_start, hr_api.g_sot)
           and     nvl(ctr.date_end, hr_api.g_eot)
     order by per.date_of_birth;
  --
  cursor  c_per_child_young(l_person_id number) is
    select max(per.date_of_birth)
      from per_contact_relationships ctr,
           per_all_people_f per
     where ctr.person_id = l_person_id
       and per.business_group_id = p_business_group_id
       and per.person_id = ctr.contact_person_id
       and ctr.personal_flag = 'Y'
       and ctr.contact_type in ('C','O','A','T')
       and l_effective_date
           between per.effective_start_date
           and     per.effective_end_date
       /* bug 2924077 */
       and l_effective_date
           between nvl(ctr.date_start, hr_api.g_sot)
           and     nvl(ctr.date_end, hr_api.g_eot)
     order by per.date_of_birth;
  --
  l_per c_per%rowtype;
  --
  cursor   c_per_extra (p_person_id in number) is
    select aei.aei_information1
    from   per_all_assignments_f asg,
           per_assignment_extra_info aei
    where  asg.person_id = p_person_id
    and    asg.assignment_id = aei.assignment_id
    and    asg.primary_flag = 'Y'
    and    asg.assignment_type = 'B'
    and    asg.business_group_id = p_business_group_id
    and    aei.information_type = 'BEN_DERIVED'
    and    l_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date;
  --
  l_per_extra c_per_extra%rowtype;
  --
  cursor c_agf is
    select agf.age_det_rl,
           agf.age_det_cd,
           agf.age_to_use_cd,
           agf.age_uom,
           agf.rndg_cd,
           agf.rndg_rl,
           agf.age_calc_rl
    from   ben_age_fctr agf
    where  agf.age_fctr_id = p_age_fctr_id;
  --
  l_agf c_agf%rowtype;
  --
  l_per_dob date;
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('fonm_cvg :'||p_fonm_cvg_strt_dt  ,10);
    hr_utility.set_location('fonm_rt  :'||p_fonm_cvg_strt_dt,10);
  end if;
  --
  l_per_dob := p_per_dob;
  --
  if p_effective_date is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_effective_date');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_person_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_person_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_age_fctr_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_age_fctr_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_business_group_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_business_group_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  end if;
  --
  /*
  if (p_pl_id is null and p_oipl_id is null and p_pgm_id is null) then
    fnd_message.set_name('BEN','BEN_91849_COMP_OBJECT_VAL_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('BUSINESS_GROUP_ID',p_business_group_id);
    fnd_message.set_token('PER_IN_LER_ID',p_per_in_ler_id);
    fnd_message.raise_error;
  end if;
  */
  --
  -- We need to drive off the correct person id when we are coming in from
  -- dependent eligibility since then we are passing the contact and not
  -- the person therefore we want to drive off the real person.
  --
  if p_parent_person_id is not null then
    --
    l_person_id := p_parent_person_id;
    --
  else
    --
    l_person_id := p_person_id;
    --
  end if;
  --
  --
  -- FONM
  --if ben_manage_life_events.fonm = 'Y' then
     --
     -- FONM : calling procedures pass the p_effective_date as
     -- nvl of fonm_rt_strt_dt, fonm_cvg_strt_dt, effective_date
     -- tilak : new fonm paramter passes the value no more overring the dates

     -- Bug 9143371: If p_lf_evt_ocrd_dt is null, consider p_effective_date
     l_effective_date := nvl(nvl(nvl(p_fonm_rt_Strt_dt, p_fonm_cvg_strt_dt), p_lf_evt_ocrd_dt),p_effective_date);
     --
     l_orig_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --  else
     --
     --     l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --     l_orig_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --  end if;
  --
  open c_agf;
    fetch c_agf into l_agf;
    --
    if c_agf%notfound then
      close c_agf;
      fnd_message.set_name('BEN','BEN_91833_CURSOR_RETURN_NO_ROW');
      fnd_message.set_token('PACKAGE',l_proc);
      fnd_message.set_token('CURSOR','c_agf');
      fnd_message.raise_error;
    end if;
  close c_agf;
  --
--  hr_utility.set_location('l_agf.age_to_use_cd -> '||l_agf.age_to_use_cd,511);
--  hr_utility.set_location('p_person_id -> '||p_person_id,511);
  --
  if l_agf.age_to_use_cd = 'P' and l_agf.age_calc_rl is null then
    --
    -- Check if the date of birth is passed in
    --
    if p_per_dob is null then
      --
      open c_per;
      fetch c_per into l_per;
      close c_per;
      --
    else
      --
      l_per.date_of_birth := p_per_dob;
      --
    end if;
    --
    if l_per.date_of_birth is null then
      --
      p_value := null;
      return;
      --
    end if;
    --
  elsif l_agf.age_calc_rl is not null then
    --
    run_rule(p_formula_id        => l_agf.age_calc_rl,
             p_rule_type         => 'DATE',
             p_effective_date    => l_orig_effective_date, -- FONM
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_business_group_id => p_business_group_id,
             p_person_id         => p_person_id,
             p_pgm_id            => p_pgm_id,
             p_pl_id             => p_pl_id,
             p_oipl_id           => p_oipl_id,
             p_plip_id           => null,
             p_ptip_id           => null,
             p_ret_date          => l_per.date_of_birth,
             p_ret_val           => l_value,
             p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt);
    --
    if l_per.date_of_birth is null then
      --
      p_value := null;
      return;
      --
    --RCHASE
    else
      p_per_dob:=l_per.date_of_birth;
    --End RCHASE
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_per.date_of_birth,10);
    end if;
    --
  elsif l_agf.age_to_use_cd = 'PS' then
  --
     open c_per_spouse(l_person_id);
     --
       fetch c_per_spouse into l_per;
     --
     close c_per_spouse;
     --
     if l_per.date_of_birth is null then
     --
       p_value := null;
       return;
     --
     end if;
  --
  elsif l_agf.age_to_use_cd = 'PD1' then
  --
     open c_per_depen_first(l_person_id);
     --
       fetch c_per_depen_first into l_per;
     --
     close c_per_depen_first;
     --
     if l_per.date_of_birth is null then
     --
       p_value := null;
       return;
     --
     end if;
  --
  elsif l_agf.age_to_use_cd = 'PC1' then
  --
     open c_per_child_first(l_person_id);
     --
       fetch c_per_child_first into l_per;
     --
     close c_per_child_first;
     --
     if l_per.date_of_birth is null then
     --
       p_value := null;
       return;
     --
     end if;
  --
  elsif l_agf.age_to_use_cd = 'PDO' then
  --
     open c_per_depen_oldest(l_person_id);
     --
       fetch c_per_depen_oldest into l_per;
     --
     close c_per_depen_oldest;
     --
     if l_per.date_of_birth is null then
     --
       p_value := null;
       return;
     --
     end if;
  --
  elsif l_agf.age_to_use_cd = 'PCO' then
  --
     open c_per_child_oldest(l_person_id);
     --
       fetch c_per_child_oldest into l_per;
     --
     close c_per_child_oldest;
     --
     if l_per.date_of_birth is null then
     --
       p_value := null;
       return;
     --
     end if;
  --
  elsif l_agf.age_to_use_cd = 'PDY' then
  --
     open c_per_depen_young(l_person_id);
     --
       fetch c_per_depen_young into l_per;
     --
     close c_per_depen_young;
     --
     if l_per.date_of_birth is null then
     --
       p_value := null;
       return;
     --
     end if;
  --
  elsif l_agf.age_to_use_cd = 'PCY' then
  --
     open c_per_child_young(l_person_id);
     --
       fetch c_per_child_young into l_per;
     --
     close c_per_child_young;
     --
     if l_per.date_of_birth is null then
     --
       p_value := null;
       return;
     --
     end if;
  --
  elsif l_agf.age_to_use_cd = 'IA' then
  --
     open c_per_extra(p_person_id);
     --
       fetch c_per_extra into l_per_extra;
     --
     close c_per_extra;
     --
     if l_per_extra.aei_information1 is null then
     --
       p_value := null;
       return;
     --
     else
     --
       if l_agf.age_uom = 'YR' then
         l_value := to_number(l_per_extra.aei_information1);
       elsif l_agf.age_uom = 'MO' then
         l_value := to_number(l_per_extra.aei_information1)*12;
       elsif l_agf.age_uom = 'WK' then
         l_value := (to_number(l_per_extra.aei_information1)*365) / 7;
       elsif l_agf.age_uom = 'DY' then
         l_value := to_number(l_per_extra.aei_information1)*365;
       else
         l_value := to_number(l_per_extra.aei_information1);
       end if;
      --
    end if;
    --
  end if;
  --
--  hr_utility.set_location('l_per.date_of_birth -> '||l_per.date_of_birth ,511);
--  hr_utility.set_location('l_agf.age_det_cd -> '||l_agf.age_det_cd,511);
  --
  if l_agf.age_to_use_cd <> 'IA' or l_agf.age_calc_rl is not null then
  --
         ben_determine_date.main
           (p_date_cd           => l_agf.age_det_cd,
            p_per_in_ler_id     => p_per_in_ler_id,
            p_person_id         => p_person_id ,
            p_pgm_id            => p_pgm_id,
            p_pl_id             => p_pl_id,
            p_oipl_id           => p_oipl_id,
            p_comp_obj_mode     => p_comp_obj_mode,
            p_business_group_id => p_business_group_id,
            p_formula_id        => l_agf.age_det_rl,
            p_effective_date    => l_orig_effective_date, -- FONM
            p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
            p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt,
            p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt,
            p_returned_date     => l_date,
            p_parent_person_id  => p_parent_person_id );

   if l_date is null then
    --
      l_date := l_effective_date;
    --
    end if;
    --
    -- Set return change date
    --
    p_change_date:=l_date;
    --
    -- Calculate in form of UOM
    --
    if g_debug then
      hr_utility.set_location('DOB'||l_per.date_of_birth,10);
    end if;
    if g_debug then
      hr_utility.set_location('DATE'||l_date,10);
    end if;
    if l_agf.age_uom = 'YR' then
      l_value := months_between(l_date,l_per.date_of_birth)/12;
    elsif l_agf.age_uom = 'MO' then
      l_value := months_between(l_date,l_per.date_of_birth);
      --
-- months_between fails when calculated between 29th Jan,30th Jan AND 28th Feb,
-- for months_between('28-Feb-RRRR','28-Jan-RRRR') it gives 1 but for months_between('28-Feb-RRRR','29/30-Jan-RRRR')
-- it gives < 1 and again as per functionality of months_between for months_between('28-Feb-RRRR','31-Jan-RRRR') it gives 1.
-- So code is made to work for this specific case.
--Bug 5931412
  if substr(to_char(l_date,'DD-MON-YYYY'),4,3) = 'FEB'
     and substr(to_char(l_per.date_of_birth,'DD-MON-YYYY'),1,2) > '28'
       and substr(to_char(l_date,'DD-MON-YYYY'),1,2) in ('28','29') then
     --
        l_value := ceil(l_value);
     --
   end if;
--Bug 5931412

    elsif l_agf.age_uom = 'WK' then
      l_value := to_number(l_date - l_per.date_of_birth) / 7;
    elsif l_agf.age_uom = 'DY' then
      l_value := to_number(l_date - l_per.date_of_birth);
    else
      l_value := months_between(l_per.date_of_birth,l_date)/12;
    end if;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('VALUE is '||l_value,10);
  end if;
  -- perform appropriate rounding based on the source table.
  -- rounding_cd or rule cannot both be null, perform_rounding_flag
  -- must be true....
  --
  if (l_agf.rndg_cd is not null or
      l_agf.rndg_rl is not null) and
      p_perform_rounding_flg = true
      and l_value is not null then
    --
    p_value := benutils.do_rounding
                   (p_rounding_cd     => l_agf.rndg_cd,
                    p_rounding_rl     => l_agf.rndg_rl,
                    p_value           => l_value,
                    p_effective_date  => l_effective_date);
  else
    --
    p_value := l_value;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
exception
  --
  when others then
    --
    p_per_dob := l_per_dob;
    p_value := null;
    p_change_date  := null;
    raise;
    --
end determine_age;
-----------------------------------------------------------------------------
procedure determine_los
  (p_person_id            in  number,
   p_los_fctr_id          in  number,
   p_pgm_id               in  number  default null,
   p_pl_id                in  number  default null,
   p_oipl_id              in  number  default null,
   p_comp_obj_mode        in  boolean default true,
   p_per_in_ler_id        in  number,
   p_effective_date       in  date,
   p_lf_evt_ocrd_dt       in  date,
   p_fonm_cvg_strt_dt     in date default null,
   p_fonm_rt_strt_dt      in date default null,
   p_business_group_id    in  number,
   p_perform_rounding_flg in  boolean default true,
   p_value                out nocopy number,
   p_start_date           out nocopy date) is
  --
  l_proc             varchar2(80) := g_package||'determine_los';
  l_effective_date   date;
  l_value            number;
  l_date             date;
  l_start_date       date;
  l_end_date         date;
  l_dummy_num        number;
  l_dummy_date       date;
  --
  -- FONM
  l_orig_effective_date   date;
  --
  cursor c_person is
    select pps.date_start,
           pps.adjusted_svc_date,
           ppf.original_date_of_hire
    from   per_all_people_f ppf,
           per_periods_of_service pps
    where  pps.person_id(+) = ppf.person_id
    and    ppf.person_id = p_person_id
    and    ppf.business_group_id = p_business_group_id
    and    l_effective_date
           between ppf.effective_start_date
           and     ppf.effective_end_date
    --Bug2168233 to get the right record from per_periods_of_service
    and    l_effective_date >= pps.date_start(+)  /*Bug 2973791 outer join added*/
    order by pps.date_start desc   ;
  --
  l_person  c_person%rowtype;
  --
  cursor c_elig_per is
    select pep.ovrid_svc_dt
    from   ben_elig_per_f pep,
           ben_per_in_ler pil
    where  pep.person_id = p_person_id
    and    pep.business_group_id = p_business_group_id
    and    nvl(pep.pl_id,-1) = nvl(p_pl_id,-1)
    and    nvl(pep.pgm_id,-1) = nvl(p_pgm_id,-1)
    and    l_effective_date
           between pep.effective_start_date
           and     pep.effective_end_date
    and pil.per_in_ler_id(+)=pep.per_in_ler_id
    and pil.business_group_id(+)=pep.business_group_id
    and (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
         or pil.per_in_ler_stat_cd is null                  -- outer join condition
        )
  ;
  --
  l_elig_per   c_elig_per%rowtype;
  --
  cursor c_lsf is
    select lsf.los_det_rl,
       lsf.los_det_cd,
       lsf.los_uom,
       lsf.rndg_cd,
       lsf.rndg_rl,
           lsf.use_overid_svc_dt_flag,
           lsf.los_dt_to_use_cd,
           lsf.los_dt_to_use_rl,
       lsf.los_calc_rl
    from   ben_los_fctr lsf
    where  lsf.los_fctr_id = p_los_fctr_id
    and    lsf.business_group_id  = p_business_group_id;
  --
  l_lsf c_lsf%rowtype;
  --
  cursor c_person_extra is
    select aei.aei_information2 iasd,
           aei.aei_information13 idoh,
           aei.aei_information3 iohd
    from   per_all_assignments_f asg,
           per_assignment_extra_info aei
    where  asg.person_id = p_person_id
    and    asg.assignment_id = aei.assignment_id
    and    asg.primary_flag = 'Y'
    and    asg.assignment_type = 'B'
    and    asg.business_group_id = p_business_group_id
    and    aei.information_type = 'BEN_DERIVED'
    and    l_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date;
  --
  l_person_extra  c_person_extra%rowtype;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
   hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('fonm_cvg :'||p_fonm_cvg_strt_dt  ,10);
    hr_utility.set_location('fonm_rt  :'||p_fonm_cvg_strt_dt,10);

  end if;
  if p_effective_date is null then
    if g_debug then
      hr_utility.set_location('BEN_91832_PACKAGE_PARAM_NULL',10);
    end if;
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_effective_date');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_person_id is null then
    if g_debug then
      hr_utility.set_location('BEN_91832_PACKAGE_PARAM_NULL',10);
    end if;
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_person_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_los_fctr_id is null then
    if g_debug then
      hr_utility.set_location('BEN_91832_PACKAGE_PARAM_NULL',10);
    end if;
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_los_fctr_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  elsif p_business_group_id is null then
    if g_debug then
      hr_utility.set_location('BEN_91832_PACKAGE_PARAM_NULL',10);
    end if;
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PARAM','p_business_group_id');
    fnd_message.set_token('PROC','Derived Factors');
    fnd_message.raise_error;
  end if;
  --
  /*
  if (p_pl_id is null and p_oipl_id is null and p_pgm_id is null) then
    if g_debug then
      hr_utility.set_location('BEN_91849_COMP_OBJECT_VAL_NULL',10);
    end if;
    fnd_message.set_name('BEN','BEN_91849_COMP_OBJECT_VAL_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('BUSINESS_GROUP_ID',p_business_group_id);
    fnd_message.set_token('PER_IN_LER_ID',p_per_in_ler_id);
    fnd_message.raise_error;
  end if;
  */


   -- FONM
  --if ben_manage_life_events.fonm = 'Y' then
     --
     -- FONM : calling procedures pass the p_effective_date as
     -- nvl of fonm_rt_strt_dt, fonm_cvg_strt_dt, effective_date
     -- tilak : new fonm paramter passes the value no more overring the dates
     l_effective_date := nvl(nvl(p_fonm_rt_Strt_dt, p_fonm_cvg_strt_dt), p_lf_evt_ocrd_dt);
     --
     l_orig_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --  else
     --
     --     l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --     l_orig_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
     --
     --  end if;

  --

  open c_lsf;
    fetch c_lsf into l_lsf;
    if c_lsf%notfound then
      close c_lsf;
      if g_debug then
        hr_utility.set_location('BEN_91833_CURSOR_RETURN_NO_ROW',10);
      end if;
      fnd_message.set_name('BEN','BEN_91833_CURSOR_RETURN_NO_ROW');
      fnd_message.set_token('PACKAGE',l_proc);
      fnd_message.set_token('CURSOR','c_lsf');
      fnd_message.raise_error;
    end if;
  close c_lsf;

  ben_determine_date.main
   (p_date_cd           => l_lsf.los_det_cd,
    p_per_in_ler_id     => p_per_in_ler_id,
    p_person_id         => p_person_id,
    p_pgm_id            => p_pgm_id,
    p_pl_id             => p_pl_id,
    p_oipl_id           => p_oipl_id,
    p_comp_obj_mode     => p_comp_obj_mode,
    p_business_group_id => p_business_group_id,
    p_formula_id        => l_lsf.los_det_rl,
    p_effective_date    => l_orig_effective_date, -- FONM
    p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
    p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt,
    p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt,
    p_returned_date     => l_date);
  --
  if l_date is null then
     l_date := l_effective_date;
  end if;
  --
  open c_person;
    fetch c_person into l_person;
    if c_person%notfound then
      close c_person;
      if g_debug then
        hr_utility.set_location('BEN_91833_CURSOR_RETURN_NO_ROW',20);
      end if;
      fnd_message.set_name('BEN','BEN_91833_CURSOR_RETURN_NO_ROW');
      fnd_message.set_token('PACKAGE',l_proc);
      fnd_message.set_token('CURSOR','c_person');
      fnd_message.raise_error;
    end if;
  close c_person;
  --
  open c_person_extra;
    fetch c_person_extra into l_person_extra;
  close c_person_extra;
  --
  open c_elig_per;
  fetch c_elig_per into l_elig_per;
  close c_elig_per;
  --
  if l_lsf.los_calc_rl is not null then
     run_rule(
             p_formula_id        => l_lsf.los_calc_rl,
             p_rule_type         => 'DATE',
             p_effective_date    => l_orig_effective_date, -- FONM
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_business_group_id => p_business_group_id,
             p_person_id         => p_person_id,
             p_pgm_id            => p_pgm_id,
             p_pl_id             => p_pl_id,
             p_oipl_id           => p_oipl_id,
             p_plip_id           => null,
             p_ptip_id           => null,
             p_ret_date          => l_dummy_date,
             p_ret_val           => p_value,
             p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt);
  else
  --
    if l_lsf.los_dt_to_use_cd = 'OHD' then
       -- Original hire date
       if l_person.original_date_of_hire is not null then
          l_start_date := l_person.original_date_of_hire;
       else
          l_start_date := l_person.date_start;
       end if;
    elsif l_lsf.los_dt_to_use_cd ='DOH' then
      if l_lsf.use_overid_svc_dt_flag = 'Y' then
        if l_elig_per.ovrid_svc_dt is not null then
          l_start_date := l_elig_per.ovrid_svc_dt ;
        else
          l_start_date := l_person.date_start;
        end if;
      else
        l_start_date := l_person.date_start;
      end if;
    elsif l_lsf.los_dt_to_use_cd ='ASD' then
      if l_lsf.use_overid_svc_dt_flag = 'Y' then
        l_start_date := l_elig_per.ovrid_svc_dt;
      elsif l_person.adjusted_svc_date is not null then
        l_start_date := l_person.adjusted_svc_date ;
      else
        l_start_date := l_person.date_start;
      end if;
    --
    elsif l_lsf.los_dt_to_use_cd ='IASD' then
    --
    -- inherited adjusted start date
    --
      if l_lsf.use_overid_svc_dt_flag = 'Y' then
        l_start_date := l_elig_per.ovrid_svc_dt;
        if l_start_date is null then
           l_start_date := fnd_date.canonical_to_date(l_person_extra.iasd);
        end if;
      else
        l_start_date := fnd_date.canonical_to_date(l_person_extra.iasd);
      end if;
    --
    elsif l_lsf.los_dt_to_use_cd ='IDOH' then
    --
    -- inherited date of hire
    --
      if l_lsf.use_overid_svc_dt_flag = 'Y' then
        l_start_date := l_elig_per.ovrid_svc_dt;
        if l_start_date is null then
           l_start_date := fnd_date.canonical_to_date(l_person_extra.idoh);
        end if;
      else
        l_start_date := fnd_date.canonical_to_date(l_person_extra.idoh);
      end if;
    --
    elsif l_lsf.los_dt_to_use_cd ='IOHD' then
    --
    -- inherited original hire date
    --
      l_start_date := fnd_date.canonical_to_date(l_person_extra.iohd);
    --
    elsif l_lsf.los_dt_to_use_cd ='RL' then
      run_rule(
         p_formula_id        => l_lsf.los_dt_to_use_rl,
         p_rule_type         => 'DATE',
         p_effective_date    => l_orig_effective_date, -- FONM
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_business_group_id => p_business_group_id,
         p_person_id         => p_person_id,
         p_pgm_id            => p_pgm_id,
         p_pl_id             => p_pl_id,
         p_oipl_id           => p_oipl_id,
         p_plip_id           => null,
         p_ptip_id           => null,
         p_ret_date          => l_start_date,
         p_ret_val           => l_dummy_num,
         p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt);
    else
      if g_debug then
        hr_utility.set_location('BEN_91342_UNKNOWN_CODE_1',20);
      end if;
      fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('CODE1',l_lsf.los_dt_to_use_cd);
      raise ben_manage_life_events.g_record_error;
    end if;

    p_start_date := l_start_date;

    if l_start_date is null then
      p_value := null;
    else
      if l_lsf.los_uom = 'YR' then
        l_value := months_between(l_date,l_start_date)/12;
      elsif l_lsf.los_uom = 'QT' then
        l_value := months_between(l_date,l_start_date)/4;
      elsif l_lsf.los_uom = 'MO' then
        l_value := months_between(l_date,l_start_date);
        --
-- months_between fails when calculated between 29th Jan,30th Jan AND 28th Feb,
-- for months_between('28-Feb-RRRR','28-Jan-RRRR') it gives 1 but for months_between('28-Feb-RRRR','29/30-Jan-RRRR')
-- it gives < 1 and again as per functionality of months_between for months_between('28-Feb-RRRR','31-Jan-RRRR') it gives 1.
-- So code is made to work for this specific case.
 --Bug 5931412
  if substr(to_char(l_date,'DD-MON-YYYY'),4,3) = 'FEB'
     and substr(to_char(l_start_date,'DD-MON-YYYY'),1,2) > '28'
       and substr(to_char(l_date,'DD-MON-YYYY'),1,2) in ('28','29') then
     --
        l_value := ceil(l_value);
     --
   end if;
     --
--Bug 5931412
      elsif l_lsf.los_uom = 'WK' then
        l_value := (l_date-l_start_date) / 7;
      elsif l_lsf.los_uom = 'DY' then
        l_value := l_date-l_start_date;
      else  -- return years
        l_value := months_between(l_date,l_start_date)/12;
      end if;
    end if;

    if (l_lsf.rndg_cd is not null or
        l_lsf.rndg_rl is not null) and
        p_perform_rounding_flg = true
        and l_value is not null then

      p_value := benutils.do_rounding
                  (p_rounding_cd     => l_lsf.rndg_cd,
                   p_rounding_rl     => l_lsf.rndg_rl,
                   p_value           => l_value,
                   p_effective_date  => l_effective_date);
    else
      p_value := l_value;
    end if;
  end if;
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,99);
  end if;
exception
  --
  when others then
    --
    p_value      := null;
    p_start_date := null;
    raise;
    --
end determine_los;


procedure determine_comb_age_los
  (p_person_id            in number,
   p_cmbn_age_los_fctr_id in number,
   p_pgm_id               in number,
   p_pl_id                in number,
   p_oipl_id              in number,
   p_comp_obj_mode        in boolean  default true,
   p_per_in_ler_id        in number,
   p_effective_date       in date,
   p_lf_evt_ocrd_dt       in date,
   p_fonm_cvg_strt_dt     in date default null,
   p_fonm_rt_strt_dt      in date default null,
   p_business_group_id    in number,
   p_value                out nocopy number) is
  --
  l_result           number;
  l_age_val          number;
  l_los_val          number;
  l_proc             varchar2(80) := g_package||'determine_los';
  l_elig_change_dt   date;
  l_start_date       date;
  --RCHASE
  l_dob              date:=null;
  --End RCHASE
  --
  cursor c_cla_elig1 is
    select cla.los_fctr_id ,
           cla.age_fctr_id
    from   ben_cmbn_age_los_fctr cla
    where  cla.cmbn_age_los_fctr_id = p_cmbn_age_los_fctr_id
    and    cla.business_group_id = p_business_group_id;
  --
  l_cla_elig1 c_cla_elig1%rowtype;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,10);
    hr_utility.set_location('fonm_cvg :'||p_fonm_cvg_strt_dt  ,10);
    hr_utility.set_location('fonm_rt  :'||p_fonm_cvg_strt_dt,10);
  end if;
  --
  open c_cla_elig1;
    --
    fetch c_cla_elig1 into l_cla_elig1;
    if c_cla_elig1%notfound then
      --
      close c_cla_elig1;
      fnd_message.set_name('BEN','BEN_91833_CURSOR_RETURN_NO_ROW');
      fnd_message.set_token('PACKAGE',l_proc);
      fnd_message.set_token('CURSOR','c_cla_elig1');
      fnd_message.raise_error;
      --
    end if;
    --
  close c_cla_elig1;
  --
  ben_derive_factors.determine_los
    (p_person_id            => p_person_id,
     p_los_fctr_id          => l_cla_elig1.los_fctr_id,
     p_pgm_id               => p_pgm_id ,
     p_pl_id                => p_pl_id ,
     p_oipl_id              => p_oipl_id ,
     p_comp_obj_mode        => p_comp_obj_mode,
     p_per_in_ler_id        => p_per_in_ler_id ,
     p_effective_date       => p_effective_date,
     p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
     p_business_group_id    => p_business_group_id ,
     p_perform_rounding_flg => TRUE ,
     p_value                => l_los_val,
     p_start_date           => l_start_date,
     p_fonm_cvg_strt_dt     => p_fonm_cvg_strt_dt,
     p_fonm_rt_strt_dt      => p_fonm_rt_strt_dt) ;
  --
  ben_derive_factors.determine_age
    (p_person_id            => p_person_id,
     --RCHASE
     p_per_dob              => l_dob,
     --End RCHASE
     p_age_fctr_id          => l_cla_elig1.age_fctr_id,
     p_pgm_id               => p_pgm_id ,
     p_pl_id                => p_pl_id ,
     p_oipl_id              => p_oipl_id ,
     p_comp_obj_mode        => p_comp_obj_mode,
     p_per_in_ler_id        => p_per_in_ler_id ,
     p_effective_date       => p_effective_date,
     p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
     p_business_group_id    => p_business_group_id ,
     p_perform_rounding_flg => TRUE,
     p_value                => l_age_val,
     p_change_date          => l_elig_change_dt,
     p_fonm_cvg_strt_dt     => p_fonm_cvg_strt_dt,
     p_fonm_rt_strt_dt      => p_fonm_rt_strt_dt) ;
  --
  l_result := l_age_val + l_los_val;
  p_value := l_result;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
exception
  --
  when others then
    --
    p_value      := null;
    raise;
    --
end DETERMINE_COMB_AGE_LOS;
--
procedure determine_hours_worked
  (p_person_id            in number,
   p_assignment_id        in number,
   p_hrs_wkd_in_perd_fctr_id in number,
   p_pgm_id               in number default null,
   p_pl_id                in number default null,
   p_oipl_id              in number default null,
   p_comp_obj_mode        in boolean  default true,
   p_per_in_ler_id        in number default null,
   p_effective_date       in date,
   p_lf_evt_ocrd_dt       in date,
   p_fonm_cvg_strt_dt     in date default null,
   p_fonm_rt_strt_dt      in date default null,
   p_business_group_id    in number,
   p_value                out nocopy number) is
    --
    l_package           VARCHAR2(80) := g_package || '.determine_hours_worked';
    l_start_date        DATE;
    l_result            NUMBER;
    l_bal_rec           ben_per_bnfts_bal_f%ROWTYPE;
    l_bnb_rec           ben_bnfts_bal_f%ROWTYPE;
    l_jurisdiction_code VARCHAR2(30);
    l_min_ass_date      date ;
     l_effective_date  date ;

  cursor c_ass is
    select min(effective_start_date)
    from  per_all_assignments_f ass
    where person_id = p_person_id
    and   (assignment_id = p_assignment_id or
           (p_assignment_id is null and
            ass.primary_flag = 'Y' and
            ass.assignment_type <> 'C'));

  cursor c_assignment is
    select assignment_id
    from   per_all_assignments_f paf
    where  person_id = p_person_id
    and    (assignment_id = p_assignment_id or
            (p_assignment_id is null and
             primary_flag = 'Y' and
             paf.assignment_type <> 'C'))
    and    business_group_id = p_business_group_id
    and    l_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
  l_assignment  c_assignment%rowtype;

  cursor c_hwf is
    select hwf.hrs_wkd_in_perd_fctr_id
          ,hwf.hrs_src_cd
          ,hwf.hrs_wkd_det_cd
          ,hwf.hrs_wkd_det_rl
          ,hwf.rndg_cd
          ,hwf.rndg_rl
          ,hwf.defined_balance_id
          ,hwf.bnfts_bal_id
          ,hwf.mn_hrs_num
          ,hwf.mx_hrs_num
          ,hwf.once_r_cntug_cd
          ,hwf.hrs_wkd_calc_rl
    from   ben_hrs_wkd_in_perd_fctr hwf
    where  hwf.hrs_wkd_in_perd_fctr_id = p_hrs_wkd_in_perd_fctr_id
    and    hwf.business_group_id  = p_business_group_id;
  --
  l_hwf c_hwf%rowtype;

  --
  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    hr_utility.set_location('fonm_cvg :'||p_fonm_cvg_strt_dt  ,10);
    hr_utility.set_location('fonm_rt  :'||p_fonm_cvg_strt_dt,10);
    end if;

     -- tilak : new fonm paramter passes the value no more overring the dates
     l_effective_date := nvl(nvl(p_fonm_rt_Strt_dt, p_fonm_cvg_strt_dt), p_lf_evt_ocrd_dt);
     --



    open c_hwf;
    fetch c_hwf into l_hwf;
    --
    if c_hwf%notfound then
      close c_hwf;
      fnd_message.set_name('BEN','BEN_91833_CURSOR_RETURN_NO_ROW');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('CURSOR','c_hwf');
      fnd_message.raise_error;
    end if;
    close c_hwf;
    --
    -- Steps to perform process
    --
    -- 1) Work out the start date
    -- 2) Perform Rounding
    --
    ben_determine_date.main(p_date_cd=> l_hwf.hrs_wkd_det_cd
     ,p_formula_id        => l_hwf.hrs_wkd_det_rl
     ,p_person_id         => p_person_id
     ,p_bnfts_bal_id      => l_hwf.bnfts_bal_id
     ,p_pgm_id            => p_pgm_id
     ,p_pl_id             => p_pl_id
     ,p_oipl_id           => p_oipl_id
     ,p_comp_obj_mode     => p_comp_obj_mode
     ,p_business_group_id => p_business_group_id
     ,p_returned_date     => l_start_date
     ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
     ,p_effective_date    => NVL(p_lf_evt_ocrd_dt,p_effective_date)
     ,p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt
     ,p_fonm_rt_strt_dt   => p_fonm_rt_strt_dt
     );
    --
    if g_debug then
      hr_utility.set_location('l_hwf.hrs_src_cd '||l_hwf.hrs_src_cd ,20);
    end if;
    IF l_hwf.hrs_src_cd = 'BNFTBALTYP' THEN
      --
      IF ben_whatif_elig.g_bnft_bal_hwf_val IS NOT NULL THEN
        --
        -- This is the case where benmngle is called from the
        -- watif form and user wants to simulate hours worked
        -- changed. Use the user supplied simulate hours value rather
        -- than the fetched value.
        --
        l_result  := ben_whatif_elig.g_bnft_bal_hwf_val;
      --
      ELSE
        --
        -- Get the persons balance
        if g_debug then
          hr_utility.set_location(' l_hwf.bnfts_bal_id '||l_hwf.bnfts_bal_id , 30);
          hr_utility.set_location(' p_person_id '||p_person_id , 30);
          hr_utility.set_location(' l_start_date '||l_start_date, 30);
        end if;
        --
        ben_person_object.get_object(p_person_id=> p_person_id
         ,p_effective_date => l_start_date
         ,p_bnfts_bal_id   => l_hwf.bnfts_bal_id
         ,p_rec            => l_bal_rec);
        --
        l_result  := l_bal_rec.val;
        --
        IF l_result IS NULL THEN

           if l_hwf.hrs_wkd_det_cd in
              ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then

              open c_ass ;
              fetch c_ass into l_min_ass_date ;
              close c_ass ;

              if g_debug then
                hr_utility.set_location('l_min_ass_date ' || l_min_ass_date,19);
              end if;
              if l_min_ass_date  is not null then
                 ben_person_object.get_object(p_person_id=> p_person_id
                       ,p_effective_date => l_min_ass_date
                       ,p_bnfts_bal_id   => l_hwf.bnfts_bal_id
                       ,p_rec            => l_bal_rec);
                 --
                 l_result  := l_bal_rec.val;
              end if ;
           end if ;

        end if ;

        IF l_result IS NULL THEN
          --
          if g_debug then
            hr_utility.set_location(' Person does not have a balance ',40);
          end if;
          --
          -- Person does not have a balance, recheck if they have a balance
          -- as of the life event occurred date or effective date.
          -- Fix for bug 216.
          --
          ben_person_object.get_object(p_bnfts_bal_id=> l_hwf.bnfts_bal_id
           ,p_rec          => l_bnb_rec);
          --
          fnd_message.set_name('BEN'
           ,'BEN_92317_PER_BALANCE_NULL');
          fnd_message.set_token('NAME'
           ,l_bnb_rec.name);
          fnd_message.set_token('DATE'
           ,l_start_date);
          benutils.write(p_text=> fnd_message.get);
          --
          ben_person_object.get_object(p_person_id=> p_person_id
           ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                 ,p_effective_date)
           ,p_bnfts_bal_id   => l_hwf.bnfts_bal_id
           ,p_rec            => l_bal_rec);
          --
          l_result  := l_bal_rec.val;
          if g_debug then
            hr_utility.set_location(' Person does not l_bal_rec.val  '||l_bal_rec.val ,50);
          end if;
          --
          IF l_result IS NULL THEN
            --
            fnd_message.set_name('BEN'
             ,'BEN_92317_PER_BALANCE_NULL');
            fnd_message.set_token('NAME'
             ,l_bnb_rec.name);
            fnd_message.set_token('DATE'
             ,NVL(p_lf_evt_ocrd_dt
               ,p_effective_date));
            benutils.write(p_text=> fnd_message.get);
            RETURN;
          --
          END IF;
        --
        END IF;
      --
      END IF;                           -- whatif hours worked existence check
    --
    ELSIF l_hwf.hrs_src_cd = 'BALTYP' THEN
      --
      IF ben_whatif_elig.g_bal_hwf_val IS NOT NULL THEN
        --
        -- This is the case where benmngle is called from the
        -- watif form and user wants to simulate hours worked
        -- changed. Use the user supplied simulate hours value rather
        -- than the fetched value.
        --
        l_result  := ben_whatif_elig.g_bal_hwf_val;
      --
      ELSE
        --
        -- Get the persons balance
        --
        if p_assignment_id is null then
           --
           open c_assignment;
           fetch c_assignment into l_assignment;
           close c_assignment;
           --
        else
           --
           l_assignment.assignment_id := p_assignment_id;
           --
        end if;
        --
        -- before calling the get_value set the tax_unit_id context
        --
        ben_derive_part_and_rate_facts.set_taxunit_context
            (p_person_id           =>     p_person_id
            ,p_business_group_id   =>     p_business_group_id
            ,p_effective_date      =>     p_effective_date
             ) ;
        --
        begin
           l_result  :=
           pay_balance_pkg.get_value(l_hwf.defined_balance_id
           ,l_assignment.assignment_id
           ,l_start_date);
        exception
          when others then
          l_result := null ;
        end ;

        IF l_result IS NULL THEN
            if l_hwf.hrs_wkd_det_cd in
                 ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then
                 open c_ass ;
                 fetch c_ass into l_min_ass_date ;
                 close c_ass ;
                 if g_debug then
                   hr_utility.set_location (' l_min_ass_date ' || l_min_ass_date, 1999);
                 end if;
                 l_result  :=
                     pay_balance_pkg.get_value(l_hwf.defined_balance_id
                    ,l_assignment.assignment_id
                    ,l_min_ass_date);

              end if ;
        end if ;

        --
        IF l_result IS NULL THEN
          --
          -- Person does not have a balance, recheck if they have a balance
          -- as of the life event occurred date or effective date.
          -- Fix for bug 216.
          --
          fnd_message.set_name('BEN'
           ,'BEN_92318_BEN_BALANCE_NULL');
          fnd_message.set_token('DATE'
           ,l_start_date);
          benutils.write(p_text=> fnd_message.get);
          --
          l_result  :=
            pay_balance_pkg.get_value(l_hwf.defined_balance_id
             ,l_assignment.assignment_id
             ,l_effective_date
              );
          --
          IF l_result IS NULL THEN
            --
            fnd_message.set_name('BEN'
             ,'BEN_92318_BEN_BALANCE_NULL');
            fnd_message.set_token('DATE'
             , l_effective_date);
            benutils.write(p_text=> fnd_message.get);
            RETURN ;
          --
          END IF;
        --
        END IF;
      --
      END IF;                          -- whatif hours worked existence check.
    --
    END IF;
    --
    IF    l_hwf.rndg_cd IS NOT NULL
       OR l_hwf.rndg_rl IS NOT NULL THEN
      --
      l_result  :=
        benutils.do_rounding(p_rounding_cd=> l_hwf.rndg_cd
         ,p_rounding_rl    => l_hwf.rndg_rl
         ,p_value          => l_result
         ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                               ,p_effective_date));
    --
    END IF;
    --
    p_value := l_result;

    if g_debug then
      hr_utility.set_location(' End of hours_calculation l_result '||l_result, 50);
    end if;
    --
  --
end determine_hours_worked;

procedure determine_pct_fulltime
  (p_person_id            in number,
   p_assignment_id        in number,
   p_pct_fl_tm_fctr_id    in number,
   p_effective_date       in date,
   p_lf_evt_ocrd_dt       in date,
   p_fonm_cvg_strt_dt     in date default null,
   p_fonm_rt_strt_dt      in date default null,
   p_comp_obj_mode        in boolean,
   p_business_group_id    in number,
   p_value                out nocopy number) is
    --
  l_package        VARCHAR2(80) := g_package || '.determine_pct_fulltime';
  l_result         NUMBER;
  l_rec            ben_person_object.g_person_fte_info_rec;
  l_effective_date date ;

  cursor c_assignment is
    select assignment_id
    from   per_all_assignments_f paf
    where  primary_flag = 'Y'
    and    person_id = p_person_id
    and    paf.assignment_type <> 'C'
    and    business_group_id = p_business_group_id
    and    l_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
  l_assignment  c_assignment%rowtype;

  cursor c_pff is
    select  pff.pct_fl_tm_fctr_id
           ,pff.use_prmry_asnt_only_flag
           ,pff.use_sum_of_all_asnts_flag
           ,pff.rndg_cd
           ,pff.rndg_rl
           ,pff.mn_pct_val
           ,pff.mx_pct_val
      from ben_pct_fl_tm_fctr pff
     where pff.pct_fl_tm_fctr_id = p_pct_fl_tm_fctr_id
       and pff.business_group_id  = p_business_group_id;
  l_pff c_pff%rowtype;

begin
  --
  hr_utility.set_location('Entering ' || l_package,10);
    hr_utility.set_location('fonm_cvg :'||p_fonm_cvg_strt_dt  ,10);
    hr_utility.set_location('fonm_rt  :'||p_fonm_cvg_strt_dt,10);
  --
  -- tilak : new fonm paramter passes the value no more overring the dates
  l_effective_date := nvl(nvl(p_fonm_rt_Strt_dt, p_fonm_cvg_strt_dt), p_lf_evt_ocrd_dt);
  --

  open c_pff;
  fetch c_pff into l_pff;
  --
  if c_pff%notfound then
    close c_pff;
    fnd_message.set_name('BEN','BEN_91833_CURSOR_RETURN_NO_ROW');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('CURSOR','c_pff');
    fnd_message.raise_error;
  end if;
  close c_pff;

  if p_assignment_id is null then
     --
     open c_assignment;
     fetch c_assignment into l_assignment;
     close c_assignment;
     --
  else
     --
     l_assignment.assignment_id := p_assignment_id;
     --
  end if;

  if l_assignment.assignment_id is not null then
     --
    ben_person_object.get_object
     (p_assignment_id=> l_assignment.assignment_id
     ,p_rec           => l_rec);
    --
    -- Get percent fulltime values
    --
    if l_pff.use_prmry_asnt_only_flag ='Y' then
       l_result  := l_rec.fte;
    else
       l_result  := l_rec.total_fte;
    end if;
            --
    if l_pff.rndg_cd is not null
       or l_pff.rndg_rl is not null then
      --
      l_result  :=
        benutils.do_rounding(p_rounding_cd=> l_pff.rndg_cd
         ,p_rounding_rl    => l_pff.rndg_rl
         ,p_value          => l_result
         ,p_effective_date => l_effective_date);
    --
    end if;
    --
  end if;

  p_value := l_result;

  if g_debug then
     hr_utility.set_location('Leaving ' || l_package,10);
  end if;
  --
end determine_pct_fulltime;
end ben_derive_factors;

/
