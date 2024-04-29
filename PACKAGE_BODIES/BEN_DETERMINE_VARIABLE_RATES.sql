--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_VARIABLE_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_VARIABLE_RATES" AS
/* $Header: benvrbrt.pkb 120.10.12010000.6 2010/02/01 05:00:08 pvelvano ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA	  	           |
|			        All rights reserved.			           |
+==============================================================================+
Name
    Determine Variable Rates
Purpose:
      Determine Variable rates for activity base rates, coverages, and actl premiums.
      This process establishes if variable rate profiles or variable rate rules are
      used, if profiles are used call evaluate profile process to determine profile to
      use, if rules are used call fast formula to return value, and finally passes
      back the value information for the first profile/rule that passes.
History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        2 Jun 98         Ty Hayden  110.0      Created.
       16 Jun 98         T Guy      110.1     Removed other exception.
       18 Jun 98         Ty Hayden  110.2      Added p_rt_usg_cd
                                                    p_bnft_prvdr_pool_id
                                                    p_prtt_rt_val_id
                                               to call of determine_acty_base_rt
       25 Jun 98         T Guy      110.3      Replaced all occurrences of
                                               PER10 with PERTEN.
       25 Sep 98         T Guy      115.2      No change.
       07 Oct 98         T Guy      115.3      Implemented schema changes for
                                               ben_enrt_rt
       19 Oct 98         T Guy      115.4      Fixed call to ben_determine_acty_
                                               base_rt. Added p_ann_val
                                                              p_ann_mn_elcn_val
                                                              p_ann_mx_elcn_val
                                                              p_cmcd_val
                                                              p_cmcd_ann_mn_elcn_val
                                                              p_cmcd_ann_mx_elcn_val
                                                              p_cmcd_acty_ref_perd_cd
     21 Oct 98           T Guy      115.5      added  p_actl_prem_id
                                                      p_cvg_amt_cal_mthd_id
                                                      p_bnft_rt_typ_cd
                                                      p_rt_typ_cd
                                                      p_rt_mlt_cd
                                                      p_comp_lvl_fctr_id
                                                      p_entr_ann_val_flag
                                                      p_ptd_comp_lvl_fctr_id
                                                      p_ann_dflt_val
                                                      p_rt_strt_dt
                                                      p_rt_strt_dt_cd
                                                      p_rt_strt_dt_rl
                                               to call for ben_determine_acty_base_rt
     23 Oct 98           T Guy      115.6      added  p_dsply_mn_elcn_val
                                                      p_dsply_mx_elcn_val
                                               to call for ben_determine_acty_base_rt
     28 Oct 98           G Perry    115.7      Uncommented exit statement.
     05 Nov 98           T Guy      115.8      Changed comp_lvl_fctr_id logic to utilize
                                               new column in ben_vrbl_rt_f.
                                               Removed PRNT mlt cd and added FLFXPCL
     05 Nov 98           T Guy      115.9      No Change
     12 Nov 98           T Guy      115.10     Implemented overall min/max val and
                                               rules
     24 Nov 98           T Guy      115.11     Fixed upr/lwr undefined rule checking
     03 Dec 98           T Guy      115.12     Fixed version numbers.  We were out nocopy of
                                               sync.  115.9 was missing.
     22 Dec 98           T Guy      115.13     Removed FLENR mlt_cd and added
                                               entr_val_at_enrt_flag
     18 Jan 99           G Perry    115.14     LED V ED
     09 Mar 99           G Perry    115.15     IS to AS.
     28 Apr 99           Shdas      115.16     Added contexts to rule calls(genutils.formula).
     27 May 99           maagrawa   115.17     Modified the procedure to be called without
                                               chc_id and pass the reqd. parameters instead.
     21 Jun 99           lmcdonal   115.18     Moved limit check code into its own
                                               procedure.
      1 Jul 99           T Guy      115.19     Made total premium changes
      1 Jul 99           lmcdonal   115.20     Made use of genutils procs rt_typ_
                                               calc and limit_checks.
     16 Jul 99           lmcdonal   115.21     Don't call rules unless the rule
                                               is found in c_ava.
                                    115.22     load l_state.region_2 with null, change
                                               limit_check parms.
     20-JUL-99           Gperry     115.23     genutils -> benutils package
                                               rename.
     07-SEP-99           TGuy       115.24     fixed call to pay_mag_util
     15-Nov-99           mhoyes     115.25   - Added trace messages.
     17-Nov-99           pbodla     115.26   - Added acty_base_rt_id context to
                                               formula, limit_checks calls.
                                               This is only applicable for acty rates
                                               calculation.
     19-Nov-99           pbodla     115.27   - Added elig_per_elctbl_chc_id param
                                               context to benutils.formula
     02-DEC-99           pbodla     115.28   - If the rates are being calculated
                                               for dummy imputed income plan then
                                               do not raise error even if the
                                               enrollment benefit row is not created
                                               , let the enrt row have null val.
                                               On enrollment rate is recalculated.
     22-FEB-00           mmogel     115.29     Fixed bug 1197534 (added c_pgm and
                                               c_pln cursors to determine what
                                               acty_ref_perd the actual premium
                                               should be based on and then calcu-
                                               lated the actl_prem appropriately)
     31-MAR-00           mmogel     115.30   - added tokens to the messages so that
                                               they are more meaningful to the user
     29-May-00           mhoyes     115.31   - Added record parameters to main.
     28-Jun-00           mhoyes     115.32   - Added p_currepe_row to main.
                                             - Bypassed c_epe with p_currepe_row
                                               values when p_currepe_row is set.
     07-Nov-00           mhoyes     115.33   - Referenced electable choice context
                                              global.
     21-mar-01           tilak      115-34     param ultmt_upt_lmt,ultmt_lwr_lmt added
     01-apr-01           tilak      115-35     param ultmt_upt_lmt_calc_rl,ultmt_lwr_lmt_calc_rl added
     17-jul-01           tilak      115-36     cursor c_imp_inc_plan corrected for spouse code
     29-Aug-01           pbodla     115-37     bug:1949361 jurisdiction code is
                                               derived inside benutils.formula
     27-Sep-01           kmahendr   115.38     Added ann_mn_elcn_val, ann_mx_elcn_val param
     26-Mar-02           kmahendr   115.39     Bug#1833008 - Added parameter p_cal_for to the call
                                               determine_compensation to handle multi-assignment.
     26-Mar-02           pbodla     115.40     Bug#2260440 - While calling limit
                                               checks if assignment id is null
                                               fetch it and pass, as formulas
                                               may need it.
     08-Jun-02           pabodla    115.41     Do not select the contingent worker
                                               assignment when assignment data is
                                               fetched.
     04-Sep-02           kmahendr   115.42     Added new acty_ref_perd_cd - PHR.
     28-Oct-02           shdas      115.43     bug fix 2644319 -- initialize l_coverage_value before
                                               everything.
     13-Nov-2002         vsethi     115.44     Bug 1210355, if variable rate is calculated, store
     					       mlt_code in g_vrbl_mlt_code. The rates mlt_cd should
     					       be changed to mlt_cd of variable profile.
     23-Dec-2002         rpgupta    115.45     Nocopy changes
     09-Apr-2004         pbodla     115.46     FONM : Use rt or cvg start dates for
                                               processing.
     13-Aug-2004         tjesumic   115.47     FONM : dates are passed as param
     30-dec-2004         nhunur     115.48     4031733 - No need to open cursor c_state.
     28-Jun-2005         kmahendr   115.49     Bug#4422269 - nvl used to get default
                                               value of enrt bnft
     03-Oct-05           ssarkar    115.50     4644867 - Added order by clause to cursoe c_asg to Query 'E' assignment first
	                                               and then others .
     07-oct-05           nhunur     115.51     4657978 - added support for ben_actl_prem_vrbl_rt_rl_f.
     02-Feb-06           stee       115.52     Bug 4873847. CWB: If treatment code is RPLC,
                                               calculate the dflt_val, elcn_mn_val and elcn_mx_val if
                                               enter val at enrollment and mlt_cd is multiple of
                                               compensation.  Also round the values if rounding rule
                                               or code is not null.
     10-Mar-06           swjain     115.54    In cursor c_asg (procedure main), added condition to
                                               fetch active assignments only
     10-Apr-06           swjain     115.55    Updated cursor c_asg (procedure main)
     09-Aug-06           maagrawa   115.56    5371364.Copied fix from benactbr
     16-Jul-07           swjain     115.57    6219465 Updated the effective_date in benutils.formula call
                                              so that rule effective the latest coverage date should get
					      picked up for imputed income calculations
     14-Sep-07           rtagarra   115.58    Bug 6399423 removed the outer join in the cursor c_asg
     12-May-08		 dwkrishn   115.59    Bug 7003453 Recalculated the premium if the coverage is
					      Enterable at enrollment
     27-Aug-08           bachakra   115.60    Bug 7331668 If treatment code is RPLC,
                                              enter val at enrollment is 'Y' and mlt_cd is multiple of
                                              compensation, then assign dflt_val to p_val.
     20-Jan-09           stee       115.61    7728455  Remove fix for bug 6399423.  Cursor c_asg
                                              should include other assignment statuses.
     11-Feb-2009         velvanop   115.62    Bug 7414757: Added parameter p_entr_val_at_enrt_flag.
	                                      VAPRO rates which are 'Enter value at Enrollment', Form field
					      should allow the user to enter a value during enrollment.
     01-Feb-2010         velvanop   115.63    Bug 9306764 : VAPRO rates which are 'Enter value at Enrollment',
                                              Default value for the rate should be taken from the VAPRO.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_determine_variable_rates';
--
--------------------------------------------------------------------------------
--------------------------------- main -----------------------------------------
--------------------------------------------------------------------------------
PROCEDURE main
  (p_currepe_row            in ben_determine_rates.g_curr_epe_rec
   := ben_determine_rates.g_def_curr_epe_rec
  ,p_per_row                in per_all_people_F%rowtype
   := ben_determine_rates.g_def_curr_per_rec
  ,p_asg_row                in per_all_assignments_f%rowtype
   := ben_determine_rates.g_def_curr_asg_rec
  ,p_ast_row                in per_assignment_status_types%rowtype
   := ben_determine_rates.g_def_curr_ast_rec
  ,p_adr_row                in per_addresses%rowtype
   := ben_determine_rates.g_def_curr_adr_rec
  ,p_person_id              IN number
  ,p_elig_per_elctbl_chc_id IN number
  ,p_enrt_bnft_id           IN number default null
  ,p_actl_prem_id           IN number default null --\
  ,p_acty_base_rt_id        IN number default null -- Only one of these 3 have val.
  ,p_cvg_amt_calc_mthd_id   IN number default null --/
  ,p_effective_date         IN date
  ,p_lf_evt_ocrd_dt         IN date
  ,p_calc_only_rt_val_flag  in boolean default false
  ,p_pgm_id                 in number  default null
  ,p_pl_id                  in number  default null
  ,p_oipl_id                in number  default null
  ,p_pl_typ_id              in number  default null
  ,p_per_in_ler_id          in number  default null
  ,p_ler_id                 in number  default null
  ,p_business_group_id      in number  default null
  ,p_bnft_amt               in number  default null
  ,p_entr_val_at_enrt_flag  in out nocopy varchar2 -- Added parameter for Bug 7414757
  ,p_val                    out nocopy number
  ,p_mn_elcn_val            out nocopy number
  ,p_mx_elcn_val            out nocopy number
  ,p_incrmnt_elcn_val       out nocopy number
  ,p_dflt_elcn_val          out nocopy number
  ,p_tx_typ_cd              out nocopy varchar2
  ,p_acty_typ_cd            out nocopy varchar2
  ,p_vrbl_rt_trtmt_cd       out nocopy varchar2
  ,p_ultmt_upr_lmt          out nocopy number
  ,p_ultmt_lwr_lmt          out nocopy number
  ,p_ultmt_upr_lmt_calc_rl  out nocopy number
  ,p_ultmt_lwr_lmt_calc_rl  out nocopy number
  ,p_ann_mn_elcn_val        out nocopy number
  ,p_ann_mx_elcn_val        out nocopy number

  )
IS
  --
  l_package varchar2(80) := g_package||'.main';
  --
  l_vrbl_rt_prfl_id number;
  l_outputs  ff_exec.outputs_t;
  l_compensation_value number;
  l_coverage_value number  := null;
  l_actl_prem_value number;
  l_prnt_rt_value number;
  l_value number;
  l_comp_lvl_fctr_id number;
  l_actl_prem_id number;
  l_acty_base_rt_id number;
  l_acty_ref_perd_cd varchar2(30);
  l_dummy_num number;
  l_dummy_char varchar2(30);
  l_dummy_date date;
  l_avr_found boolean default false;
  l_apv_found boolean default false;
  l_bvr_found boolean default false;
  l_rounded_value  number;
  l_jurisdiction_code     varchar2(30);
  --
  -- Bug 4873847
  --
  l_cwb_dflt_val        number;
  l_cwb_incrmt_elcn_val number;
  l_cwb_mx_elcn_val     number;
  l_cwb_mn_elcn_val     number;
  --
  -- End Bug 4873847
  --
  -- FONM
  cursor c_asg(cv_effective_date date) is
    select asg.assignment_id,asg.organization_id
    from   per_all_assignments_f asg, per_assignment_status_types ast
    where  asg.person_id = p_person_id
    and   asg.assignment_type <> 'C'
    and    asg.primary_flag = 'Y'
    and    asg.assignment_status_type_id = ast.assignment_status_type_id(+)
    and    ast.per_system_status(+) = 'ACTIVE_ASSIGN' -- Bug 6399423 removed the outer join
                                                      -- Bug 7728455 Added back the outer join
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between asg.effective_start_date
           and     asg.effective_end_date
    order by assignment_type desc, effective_start_date desc; -- BUG 4644867
  --
  l_asg c_asg%rowtype;
  --
  -- FONM
  cursor c_avr(cv_effective_date date) is
    select avr.acty_vrbl_rt_id
    from   ben_acty_vrbl_rt_f avr
    where  avr.acty_base_rt_id = p_acty_base_rt_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between avr.effective_start_date
           and     avr.effective_end_date;
  --
  l_avr c_avr%rowtype;
  --
  --
  --
  -- FONM
  cursor c_avrl(cv_effective_date date) is
    select avr.formula_id, avr.RT_TRTMT_CD
    from   ben_actl_prem_vrbl_rt_rl_f avr
    where  avr.actl_prem_id = p_actl_prem_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between avr.effective_start_date
           and     avr.effective_end_date;
  --
  l_avrl c_avrl%rowtype;
  -- FONM
  --
  cursor c_vrr(cv_effective_date date) is
    select vrr.formula_id
    from   ben_vrbl_rt_rl_f vrr
    where  vrr.acty_base_rt_id = p_acty_base_rt_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between vrr.effective_start_date
           and     vrr.effective_end_date
    order by vrr.ordr_to_aply_num;
  --
  -- FONM
  cursor c_apv(cv_effective_date date) is
    select apv.actl_prem_vrbl_rt_id
    from   ben_actl_prem_vrbl_rt_f apv
    where  apv.actl_prem_id = p_actl_prem_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between apv.effective_start_date
           and     apv.effective_end_date;
  --
  l_apv c_apv%rowtype;
  --
  -- FONM
  cursor c_ava(cv_effective_date date) is
    select ava.vrbl_rt_add_on_calc_rl
    from   ben_actl_prem_f ava
    where  ava.actl_prem_id = p_actl_prem_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between ava.effective_start_date
           and     ava.effective_end_date;
  --
  l_ava c_ava%rowtype;
  --
  -- FONM
  cursor c_bvr(cv_effective_date date) is
    select bvr.bnft_vrbl_rt_id
    from   ben_bnft_vrbl_rt_f bvr
    where  bvr.cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between bvr.effective_start_date
           and     bvr.effective_end_date;
  --
  l_bvr c_bvr%rowtype;
  --
  -- FONM
  cursor c_brr(cv_effective_date date) is
    select brr.formula_id
    from   ben_bnft_vrbl_rt_rl_f brr
    where  brr.cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between brr.effective_start_date
           and     brr.effective_end_date
    order by brr.ordr_to_aply_num;
  --
  -- FONM
  cursor c_vpf(cv_effective_date date) is
    select vpf.val,
           vpf.val_calc_rl,
           vpf.mx_elcn_val,
           vpf.mn_elcn_val,
           vpf.dflt_elcn_val,
           vpf.incrmnt_elcn_val,
           vpf.mlt_cd,
           vpf.acty_typ_cd,
           vpf.rt_typ_cd,
           vpf.bnft_rt_typ_cd,
           vpf.tx_typ_cd,
           vpf.vrbl_rt_trtmt_cd,
           vpf.comp_lvl_fctr_id,
           vpf.lwr_lmt_val,
           vpf.lwr_lmt_calc_rl,
           vpf.upr_lmt_val,
           vpf.upr_lmt_calc_rl,
           vpf.rndg_cd,
           vpf.rndg_rl,
           vpf.ultmt_upr_lmt,
           vpf.ultmt_lwr_lmt,
           vpf.ultmt_upr_lmt_calc_rl,
           vpf.ultmt_lwr_lmt_calc_rl,
           vpf.ann_mn_elcn_val,
           vpf.ann_mx_elcn_val,
           vpf.no_mn_elcn_val_dfnd_flag
    from   ben_vrbl_rt_prfl_f vpf
    where  vpf.vrbl_rt_prfl_id = l_vrbl_rt_prfl_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between vpf.effective_start_date
           and     vpf.effective_end_date;
  --
  l_vpf c_vpf%rowtype;
  --
  cursor c_epe
  is
    select epe.pl_id,
           epe.pl_typ_id,
           epe.oipl_id,
           epe.pgm_id,
           epe.business_group_id,
           epe.per_in_ler_id,
           pil.ler_id
    from   ben_elig_per_elctbl_chc epe,ben_per_in_ler pil
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and    epe.per_in_ler_id = pil.per_in_ler_id;
  --
  -- FONM
  cursor c_opt(l_oipl_id number, cv_effective_date date) is
    select opt_id
    from ben_oipl_f  oipl
    where oipl_id = l_oipl_id
        and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between oipl.effective_start_date
           and     oipl.effective_end_date;
  l_epe c_epe%rowtype;
  l_opt c_opt%rowtype;
  --
  -- FONM
  Cursor c_state(cv_effective_date date) is
  select loc.region_2
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id = asg.location_id
  and asg.person_id = p_person_id
  and asg.assignment_type <> 'C'
  and asg.primary_flag = 'Y'
       and cv_effective_date -- FONM p_effective_date
           between
             asg.effective_start_date and asg.effective_end_date;

  l_state c_state%rowtype;

  -- FONM
  cursor c_apr2(cv_effective_date date) is
    select apr.actl_prem_id
    from   ben_actl_prem_f apr,
           ben_pl_f pln,
           ben_oipl_f cop
    where  ((pln.pl_id = l_epe.pl_id
    and    pln.actl_prem_id = apr.actl_prem_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pln.effective_start_date
           and     pln.effective_end_date)
    or     (cop.oipl_id = l_epe.oipl_id
    and    cop.actl_prem_id = apr.actl_prem_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between cop.effective_start_date
           and     cop.effective_end_date))
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between apr.effective_start_date
           and     apr.effective_end_date;
  --
  -- FONM
  cursor c_pln(cv_effective_date date) is
    select pln.nip_acty_ref_perd_cd
    from   ben_pl_f pln
    where  pln.pl_id = l_epe.pl_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pln.effective_start_date
           and     pln.effective_end_date;

    l_pln c_pln%rowtype;

  -- FONM
  cursor c_pgm(cv_effective_date date) is
    select pgm.acty_ref_perd_cd
    from   ben_pgm_f pgm
    where  pgm.pgm_id = l_epe.pgm_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pgm.effective_start_date
           and     pgm.effective_end_date;

  l_pgm c_pgm%rowtype;
  --
  cursor c_enb is
    select nvl(enb.val,enb.dflt_val)  -- used nvl to compute value based on default val
    from   ben_enrt_bnft enb
    where  enb.enrt_bnft_id = p_enrt_bnft_id;
  --
  -- FONM
  cursor c_abr(cv_effective_date date) is
    select abr2.acty_base_rt_id
    from   ben_acty_base_rt_f abr,
           ben_paird_rt_f prd,
           ben_acty_base_rt_f abr2
    where  abr.acty_base_rt_id = p_acty_base_rt_id
    and    abr.acty_base_rt_id = prd.chld_acty_base_rt_id
    and    abr2.acty_base_rt_id = prd.parnt_acty_base_rt_id
    and    abr2.parnt_chld_cd = 'PARNT'
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between prd.effective_start_date
           and     prd.effective_end_date
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr2.effective_start_date
           and     abr2.effective_end_date
    and    rownum = 1;
  --
  cursor c_prem_abr(cv_effective_date date) is
    select abr.actl_prem_id
      from ben_acty_base_rt_f abr
     where abr.acty_base_rt_id = p_acty_base_rt_id
       and cv_effective_date between abr.effective_start_date and
                                     abr.effective_end_date;
  --
  cursor c_enrt_prem is
    select ecr.val
    from   ben_enrt_prem ecr,
           ben_per_in_ler pil,
           ben_elig_per_elctbl_chc epe
    where  ecr.actl_prem_id = l_actl_prem_id
      and  ecr.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
      and  epe.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id
      and  pil.per_in_ler_id = epe.per_in_ler_id
      and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  -- FONM
  cursor c_imp_inc_plan(p_pl_id in number, cv_effective_date date) is
    select 'Y'
    from ben_pl_f pln
    where pln.imptd_incm_calc_cd in ('PRTT', 'SPS', 'DPNT') and
          pln.pl_stat_cd = 'A' and
          pln.pl_id = p_pl_id and
          pln.business_group_id = p_business_group_id and
          cv_effective_date -- FONM p_effective_date
          between pln.effective_start_date and
                                   pln.effective_end_date;

  --
  --   bug 7003453
  cursor c_entr_at_enrt_flag is
     select ENTR_VAL_AT_ENRT_FLAG
     from BEN_CVG_AMT_CALC_MTHD_f
     WHERE (pl_id = p_pl_id
     or oipl_id = p_oipl_id)
     and p_effective_date
	 between effective_start_date
	 and effective_end_date;

	l_entr_at_enrt_flag ben_cvg_amt_calc_mthd_f.entr_val_at_enrt_flag%type;

 --end  bug 7003453
  l_imp_inc_plan    varchar2(1) := 'N';
  l_pay_annualization_factor number;
  --
  -- FONM
  l_fonm_cvg_strt_dt   date;
  --
  -- Bug 4873847
  --
  l_env               ben_env_object.g_global_env_rec_type;
  l_mode                                l_env.mode_cd%TYPE;
  --
  -- End Bug 4873847
  --
BEGIN
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  ben_env_object.get(p_rec => l_env);
  --
  If (p_person_id is null) then
    --
    fnd_message.set_name('BEN','BEN_91554_BENVRBRT_INPT_PRSN');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',to_char(p_elig_per_elctbl_chc_id));
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.set_token('ACTL_PREM_ID',to_char(p_actl_prem_id));
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('CVG_AMT_CALC_MTHD_ID',to_char(p_cvg_amt_calc_mthd_id));
    fnd_message.raise_error;
    --
  end if;
  --
  -- Edit to insure that the input p_effective_date has a value
  If (p_effective_date is null) then
    --
    fnd_message.set_name('BEN','BEN_91555_BENVRBRT_INPT_EFFDT');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',to_char(p_elig_per_elctbl_chc_id));
    fnd_message.set_token('ACTL_PREM_ID',to_char(p_actl_prem_id));
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('CVG_AMT_CALC_MTHD_ID',to_char(p_cvg_amt_calc_mthd_id));
    fnd_message.raise_error;
    --
  end if;
  --
  -- Edit to insure that the input p_elig_per_elctbl_chc_id has a value
  If (p_elig_per_elctbl_chc_id is null) and not(p_calc_only_rt_val_flag) then
    --
    fnd_message.set_name('BEN','BEN_91556_BENVRBRT_INPT_EC');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('ACTL_PREM_ID',to_char(p_actl_prem_id));
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('CVG_AMT_CALC_MTHD_ID',to_char(p_cvg_amt_calc_mthd_id));
    fnd_message.raise_error;
    --
  end if;
  --
  -- Edit to ensure that one of the base table ids has a value
  If (p_acty_base_rt_id is null and
      p_actl_prem_id is null and
      p_cvg_amt_calc_mthd_id is null) then
     --
    fnd_message.set_name('BEN','BEN_91557_BENVRBRT_INPT_BT');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',to_char(p_elig_per_elctbl_chc_id));
    fnd_message.raise_error;
     --
  end if;
  -- bug 1210355
  g_vrbl_mlt_code := null;

  --
  -- FONM variables initialization
  --
  if ben_manage_life_events.fonm = 'Y' then
     --
     l_fonm_cvg_strt_dt := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                               ben_manage_life_events.g_fonm_cvg_strt_dt);
     --
  end if;
  --
  l_coverage_value        := p_bnft_amt;
  if p_calc_only_rt_val_flag then
     --
     l_epe.pl_id             := p_pl_id;
     l_epe.pgm_id            := p_pgm_id;
     l_epe.pl_typ_id         := p_pl_typ_id;
     l_epe.oipl_id           := p_oipl_id;
     l_epe.per_in_ler_id     := p_per_in_ler_id;
     l_epe.ler_id            := p_ler_id;
     l_epe.business_group_id := p_business_group_id;
     --
  --
  -- Check if the context global is populated
  --
  elsif ben_epe_cache.g_currepe_row.elig_per_elctbl_chc_id is not null
  then
    --
    l_epe.pgm_id            := ben_epe_cache.g_currepe_row.pgm_id;
    l_epe.pl_typ_id         := ben_epe_cache.g_currepe_row.pl_typ_id;
    l_epe.pl_id             := ben_epe_cache.g_currepe_row.pl_id;
    l_epe.oipl_id           := ben_epe_cache.g_currepe_row.oipl_id;
    l_epe.business_group_id := ben_epe_cache.g_currepe_row.business_group_id;
    l_epe.per_in_ler_id     := ben_epe_cache.g_currepe_row.per_in_ler_id;
    l_epe.ler_id            := ben_epe_cache.g_currepe_row.ler_id;
    --
  --
  -- Check if the context row is populated
  --
  elsif p_currepe_row.elig_per_elctbl_chc_id is not null
  then
    --
    l_epe.pgm_id            := p_currepe_row.pgm_id;
    l_epe.pl_typ_id         := p_currepe_row.pl_typ_id;
    l_epe.pl_id             := p_currepe_row.pl_id;
    l_epe.oipl_id           := p_currepe_row.oipl_id;
    l_epe.business_group_id := p_currepe_row.business_group_id;
    l_epe.per_in_ler_id     := p_currepe_row.per_in_ler_id;
    l_epe.ler_id            := p_currepe_row.ler_id;
    --
  else
     --
     open c_epe;
       --
       fetch c_epe into l_epe;
       --
       if c_epe%notfound then
         --
         close c_epe;
         fnd_message.set_name('BEN','BEN_91558_BENVRBRT_EPE_NF');
         fnd_message.set_token('PACKAGE',l_package);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.raise_error;
         --
       end if;
       --
     close c_epe;
     --
  end if;
  --
    hr_utility.set_location(l_package||' p_abr_id NN ',10);
  if p_acty_base_rt_id is not null then
    --
    -- FONM
    open c_avr(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)))
;
      --
      fetch c_avr into l_avr;
      --
      if c_avr%found then
        --
        l_avr_found := true;
        --
        open c_prem_abr(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
          fetch c_prem_abr into l_actl_prem_id;
        close c_prem_abr;
      --
      end if;
      --
    close c_avr;
    --
  end if;
  --
    hr_utility.set_location(l_package||' p_aprm_id NN ',10);
  if p_actl_prem_id is not null then
    --
    l_actl_prem_id := p_actl_prem_id;
    --
    open c_apv(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
      --
      fetch c_apv into l_apv;
      --
      if c_apv%found then
        --
        l_apv_found := true;
        --
      end if;
      --
    close c_apv;
    --
  end if;
  --
    hr_utility.set_location(l_package||' p_cacm_id NN ',10);
  if p_cvg_amt_calc_mthd_id is not null then
    --
    open c_bvr(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
      --
      fetch c_bvr into l_bvr;
      --
      if c_bvr%found then
        --
        l_bvr_found := true;
        --
      end if;
      --
    close c_bvr;
    --
  end if;
  --
  -- if one of these are found, then we are dealing with profiles, not rules.
  --
    hr_utility.set_location(l_package||' l_avr_found OR ',10);
  if l_avr_found or l_apv_found or l_bvr_found then
    --
      hr_utility.set_location(l_package||' BERP_MN ',10);
    ben_evaluate_rate_profiles.main
      (p_currepe_row               => p_currepe_row
      ,p_per_row                   => p_per_row
      ,p_asg_row                   => p_asg_row
      ,p_ast_row                   => p_ast_row
      ,p_adr_row                   => p_adr_row
      ,p_person_id                 => p_person_id
      ,p_acty_base_rt_id           => p_acty_base_rt_id
      ,p_actl_prem_id              => p_actl_prem_id
      ,p_cvg_amt_calc_mthd_id      => p_cvg_amt_calc_mthd_id
      ,p_elig_per_elctbl_chc_id    => p_elig_per_elctbl_chc_id
      ,p_effective_date            => p_effective_date -- FONM : benrtprf handles it.
      ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
      ,p_calc_only_rt_val_flag     => p_calc_only_rt_val_flag
      ,p_pgm_id                    => l_epe.pgm_id
      ,p_pl_id                     => l_epe.pl_id
      ,p_pl_typ_id                 => l_epe.pl_typ_id
      ,p_oipl_id                   => l_epe.oipl_id
      ,p_per_in_ler_id             => l_epe.per_in_ler_id
      ,p_ler_id                    => l_epe.ler_id
      ,p_business_group_id         => l_epe.business_group_id
      ,p_vrbl_rt_prfl_id           => l_vrbl_rt_prfl_id
      ); -- this is output
      hr_utility.set_location(l_package||' Dn BERP_MN ',10);
    --
    -- when l_vrbl_rt_prfl_id has no value in it, the person failed the criteria
    --   and get out!  So much for one exit point!
    --
    if l_vrbl_rt_prfl_id is null then
      --
      return;
      --
    end if;
    --
    -- All profile criteria was met!
    --
    if l_epe.oipl_id is not null then
    	open c_opt(l_epe.oipl_id, nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
    	fetch c_opt into l_opt;
        close c_opt;
    end if;
   --
    open c_vpf(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
      --
      fetch c_vpf into l_vpf;
      --
      if c_vpf%notfound then
        --
        close c_vpf;
        fnd_message.set_name('BEN','BEN_91559_BENVRBRT_VPF_NF');
        fnd_message.set_token('PACKAGE',l_package);
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
        fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
        fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
        fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
        fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.set_token('PER_IN_LER_ID',to_char(l_epe.per_in_ler_id));
        fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',
                               to_char(p_elig_per_elctbl_chc_id));
        fnd_message.raise_error;
        --
      end if;
      --
    close c_vpf;
      p_entr_val_at_enrt_flag := l_vpf.no_mn_elcn_val_dfnd_flag; -- Bug 7414757
      hr_utility.set_location(l_package||' close c_vpf ',10);
    --
    if l_vpf.mlt_cd in ('CVG','CLANDCVG','APANDCVG','PRNTANDCVG') then
     --
     -- If the rates are being calculated for dummy imputed
     -- income plan then do not raise error even if the
     -- enrollment benefit row is not created, let the enrt row have
     -- null val. On enrollment rate is recalculated anyway.
     --
     hr_utility.set_location(' plan id ' || p_pl_iD , 99);
     open c_imp_inc_plan(l_epe.pl_id,
                         nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
     fetch c_imp_inc_plan into l_imp_inc_plan;
     close c_imp_inc_plan;
     --
     hr_utility.set_location(' imp_inc_plan  ' || l_imp_inc_plan , 99);
     if l_imp_inc_plan = 'N' then
      --
      if l_coverage_value is null then
         --
         if p_enrt_bnft_id is null then
               --
               fnd_message.set_name('BEN','BEN_91560_BENVRBRT_INPT_EB');
               fnd_message.set_token('PACKAGE',l_package);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
               fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
               fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
               fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
               fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
               fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
               fnd_message.set_token('PER_IN_LER_ID',to_char(l_epe.per_in_ler_id));
               fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',
                                      to_char(p_elig_per_elctbl_chc_id));
               fnd_message.set_token('MLT_CD',l_vpf.mlt_cd);
               fnd_message.raise_error;
            --
         end if;
         --
         open c_enb;
           --
           fetch c_enb into l_coverage_value;
           --
           if c_enb%notfound then
             --
             close c_enb;
             fnd_message.set_name('BEN','BEN_91561_BENVRBRT_ENB_NF');
             fnd_message.set_token('PACKAGE',l_package);
             fnd_message.set_token('PERSON_ID',to_char(p_person_id));
             fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
             fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
             fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
             fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
             fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
             fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
             fnd_message.set_token('PER_IN_LER_ID',to_char(l_epe.per_in_ler_id));
             fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',
                                    to_char(p_elig_per_elctbl_chc_id));
             fnd_message.set_token('MLT_CD',l_vpf.mlt_cd);
             fnd_message.raise_error;
             --
           end if;
           --
         close c_enb;
         --
      end if;
      --
     end if;
     --
    end if;
    --
      hr_utility.set_location(l_package||' l_vpf.mlt_cd 1 ',10);
    if l_vpf.mlt_cd in ('CL','CLANDCVG','FLFXPCL') then
      --
      if l_vpf.comp_lvl_fctr_id is null then
        --
        fnd_message.set_name('BEN','BEN_91565_BENVRBRT_NULL_CLF');
        fnd_message.set_token('PACKAGE',l_package);
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
        fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
        fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
        fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
        fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.set_token('PER_IN_LER_ID',to_char(l_epe.per_in_ler_id));
        fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',
                               to_char(p_elig_per_elctbl_chc_id));
        fnd_message.set_token('MLT_CD',l_vpf.mlt_cd);
        fnd_message.raise_error;
        --
      end if;
      --
      ben_derive_factors.determine_compensation
        (p_comp_lvl_fctr_id     => l_vpf.comp_lvl_fctr_id,
         p_person_id            => p_person_id,
         p_pgm_id               => l_epe.pgm_id,
         p_pl_id                => l_epe.pl_id,
         p_oipl_id              => l_epe.oipl_id,
         p_per_in_ler_id        => l_epe.per_in_ler_id,
         p_business_group_id    => l_epe.business_group_id,
         p_perform_rounding_flg => true,
         p_effective_date       => p_effective_date, -- FONM : pass overloaded date
         p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
         p_cal_for              => 'R',
         p_value                => l_compensation_value,
         p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
         --
      if l_compensation_value is null then
        --
        return; -- for some reason this person has no comp so return
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('  checking if program or plan ',70);
    --
    if l_epe.pgm_id is not null then
      open c_pgm(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
      fetch c_pgm into l_pgm;
      if c_pgm%notfound then
        close c_pgm;
        fnd_message.set_name('BEN','BEN_92410_BENACTBR_PGM_NF');
        fnd_message.set_token('ID',to_char(l_epe.pgm_id));
        fnd_message.set_token('PACKAGE',l_package);
        fnd_message.raise_error;
      end if;
      close c_pgm;
      l_acty_ref_perd_cd := l_pgm.acty_ref_perd_cd;
    else
      hr_utility.set_location('  testing if plan ',80);
      open c_pln(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
        fetch c_pln into l_pln;
      if c_pln%notfound then
        close c_pln;
        fnd_message.set_name('BEN','BEN_92411_BENACTBR_PLN_NF');
        fnd_message.set_token('ID',to_char(l_epe.pl_id));
        fnd_message.set_token('PACKAGE',l_package);
        fnd_message.raise_error;
      end if;
      close c_pln;
      l_acty_ref_perd_cd := l_pln.nip_acty_ref_perd_cd;
    end if;
    --
    hr_utility.set_location(l_package||' l_vpf.mlt_cd 2 ',10);
    --
    if l_vpf.mlt_cd in ('AP','APANDCVG') then
      --
     open c_enrt_prem;
        fetch c_enrt_prem into l_actl_prem_value;
      close c_enrt_prem;
      --
  --- Recalculating the premium here instead of fetching from c_enrt_prem
  --- if the coverage is enterable at enrollment.
  --- Fix for bug 7003453
      open c_entr_at_enrt_flag;
      fetch c_entr_at_enrt_flag into l_entr_at_enrt_flag;
      close c_entr_at_enrt_flag;

      if l_entr_at_enrt_flag = 'Y' then

     begin
      ben_determine_actual_premium.g_computed_prem_val := null ;
        ben_determine_actual_premium.main
          (p_person_id         => p_person_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_calc_only_rt_val_flag => p_calc_only_rt_val_flag ,
           p_pgm_id                => p_pgm_id,
           p_pl_id                 => p_pl_id,
           p_pl_typ_id             => p_pl_typ_id,
           p_oipl_id               => p_oipl_id,
           p_per_in_ler_id         => p_per_in_ler_id,
           p_ler_id                => p_ler_id,
           p_bnft_amt              => p_bnft_amt,
           p_business_group_id     => p_business_group_id );

           hr_utility.set_location('premium re calculation over ',555666);
           l_actl_prem_value := ben_determine_actual_premium.g_computed_prem_val ;
           hr_utility.set_location('re calculation premium'||l_actl_prem_value,555666);
           ben_determine_actual_premium.g_computed_prem_val := null ;

     end;
     end if;
--- end Fix for bug 7003453
      if l_actl_prem_value is null then
        --
        return; -- -- soft error do not stop processing.
        --
      end if;
      --
      if l_acty_ref_perd_cd = 'PWK' then
         l_actl_prem_value := (l_actl_prem_value * 12) / 52;
      elsif l_acty_ref_perd_cd = 'BWK' then
         l_actl_prem_value := (l_actl_prem_value * 12) / 26;
      elsif l_acty_ref_perd_cd = 'MO' then
         null;  --  premiums are always monthly, so nothing to do
      elsif l_acty_ref_perd_cd = 'SMO' then
         l_actl_prem_value := (l_actl_prem_value * 12) / 6;
      elsif l_acty_ref_perd_cd = 'PQU' then
         l_actl_prem_value := (l_actl_prem_value * 12) / 4;
      elsif l_acty_ref_perd_cd = 'SAN' then
         l_actl_prem_value := (l_actl_prem_value * 12) / 2;
      elsif l_acty_ref_perd_cd = 'PYR' then
         l_actl_prem_value := l_actl_prem_value * 12;
      elsif l_acty_ref_perd_cd = 'PHR' then
       --
         l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
         if l_pay_annualization_factor is null then
           l_pay_annualization_factor := 2080;
         end if;
       --
         l_actl_prem_value := l_actl_prem_value * 12 / l_pay_annualization_factor;
       --

      else
         fnd_message.set_name('BEN','BEN_92412_UKN_ACTY_REF_PERD');
         fnd_message.set_token('PROC',l_package);
         fnd_message.set_token('VARIABLE',l_acty_ref_perd_cd);
         hr_utility.set_location ('  FNDMS_RE 2 ',150);
         fnd_message.raise_error;
      end if;
      --
    end if;
    --
    --
    -- We now should have everything to do the calculation
    --
    --  Flat Amount
    --
      hr_utility.set_location(l_package||' rt_typ_calc ELSIFs ',10);
    if l_vpf.mlt_cd = 'FLFX' then
      --
     /* Bug 9306764: Added if..else condition.If VAPRO is 'Enter value at Enrollment',then 'VAL' column will be NULL.
     Take the Default value of the VAPRO*/
     if(l_vpf.no_mn_elcn_val_dfnd_flag = 'Y' and l_vpf.val is null) then
         p_val  := l_vpf.dflt_elcn_val;
     else
         p_val  := l_vpf.val;
     end if;
      --
    elsif l_vpf.mlt_cd = 'CL' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.rt_typ_cd
           ,p_val            => l_vpf.val
           ,p_val_2          => l_compensation_value
           ,p_calculated_val => p_val);

    elsif l_vpf.mlt_cd = 'CVG' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.bnft_rt_typ_cd
           ,p_val            => l_vpf.val
           ,p_val_2          => l_coverage_value
           ,p_calculated_val => p_val);

    elsif l_vpf.mlt_cd = 'AP' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.rt_typ_cd
           ,p_val            => l_vpf.val
           ,p_val_2          => l_actl_prem_value
           ,p_calculated_val => p_val);


    elsif l_vpf.mlt_cd = 'FLFXPCL' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.rt_typ_cd
           ,p_val            => l_vpf.val
           ,p_val_2          => l_compensation_value
           ,p_calculated_val => p_val);

    elsif l_vpf.mlt_cd = 'CLANDCVG' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.rt_typ_cd
           ,p_val            => l_vpf.val
           ,p_val_2          => l_compensation_value
           ,p_calculated_val => l_value);

     --
     -- now take l_value and apply it against the coverage
     --
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.bnft_rt_typ_cd
           ,p_val            => l_value
           ,p_val_2          => l_coverage_value
           ,p_calculated_val => p_val);

   elsif l_vpf.mlt_cd = 'APANDCVG' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.rt_typ_cd
           ,p_val            => l_vpf.val
           ,p_val_2          => l_actl_prem_value
           ,p_calculated_val => l_value);

     --
     -- now take l_value and apply it against the coverage
     --
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.bnft_rt_typ_cd
           ,p_val            => l_value
           ,p_val_2          => l_coverage_value
           ,p_calculated_val => p_val);

   elsif l_vpf.mlt_cd = 'PRNTANDCVG' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.rt_typ_cd
           ,p_val            => l_vpf.val
           ,p_val_2          => l_prnt_rt_value
           ,p_calculated_val => l_value);

     --
     -- now take l_value and apply it against the coverage
     --
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_vpf.bnft_rt_typ_cd
           ,p_val            => l_value
           ,p_val_2          => l_coverage_value
           ,p_calculated_val => p_val);

     --
   elsif l_vpf.mlt_cd = 'RL' then
     --
     -- FONM
     open c_asg(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
       --
       fetch c_asg into l_asg;
       --
     close c_asg;
     --
/*  -- 4031733 - Cursor c_state populates l_state variable which is no longer
    -- used in the package. Cursor can be commented

     if p_person_id is not null then
      open c_state(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
      fetch c_state into l_state;
      close c_state;

      if l_state.region_2 is not null then

        l_jurisdiction_code :=
           pay_mag_utils.lookup_jurisdiction_code
             (p_state => l_state.region_2);

      end if;

     end if;
*/
     -- Call formula initialise routine
     --greatest
     l_outputs := benutils.formula
       (p_formula_id        => l_vpf.val_calc_rl,
        p_effective_date    => nvl(l_fonm_cvg_strt_dt,greatest(nvl(p_lf_evt_ocrd_dt,p_effective_date),p_effective_date)),   -- Bug 6219465
        p_business_group_id => l_epe.business_group_id,
        p_assignment_id     => l_asg.assignment_id,
        p_organization_id   => l_asg.organization_id,
        p_pgm_id	    => l_epe.pgm_id,
        p_pl_id		    => l_epe.pl_id,
        p_pl_typ_id	    => l_epe.pl_typ_id,
        p_opt_id	    => l_opt.opt_id,
        p_ler_id            => l_epe.ler_id,
        p_acty_base_rt_id   => p_acty_base_rt_id,
        p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
        p_jurisdiction_code => l_jurisdiction_code,
        -- FONM
        p_param1             => 'BEN_IV_RT_STRT_DT',
        p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
        p_param2             => 'BEN_IV_CVG_STRT_DT',
        p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt));
     --
     p_val := l_outputs(l_outputs.first).value;
     --
   else
     --
     fnd_message.set_name('BEN','BEN_91572_BENVRBRT_MLT_CD');
       hr_utility.set_location(l_package||' FND 91572 ',10);
     fnd_message.set_token('PACKAGE',l_package);
     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
     fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
     fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
     fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
     fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
     fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
     fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
     fnd_message.set_token('PER_IN_LER_ID',to_char(l_epe.per_in_ler_id));
     fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',
                            to_char(p_elig_per_elctbl_chc_id));
     fnd_message.set_token('MLT_CD',l_vpf.mlt_cd);
     fnd_message.raise_error;
     --
   end if;  -- mult_cd
   --
   -- assign other outputs
   --
   p_mx_elcn_val  :=  l_vpf.mx_elcn_val;
   p_mn_elcn_val  := l_vpf.mn_elcn_val;
   p_dflt_elcn_val := l_vpf.dflt_elcn_val;
   p_incrmnt_elcn_val := l_vpf.incrmnt_elcn_val;
   p_ultmt_upr_lmt    := l_vpf.ultmt_upr_lmt ;
   p_ultmt_lwr_lmt    := l_vpf.ultmt_lwr_lmt ;
   p_ultmt_upr_lmt_calc_rl  := l_vpf.ultmt_upr_lmt_calc_rl ;
   p_ultmt_lwr_lmt_calc_rl  := l_vpf.ultmt_lwr_lmt_calc_rl ;
   p_ann_mn_elcn_val        := l_vpf.ann_mn_elcn_val;
   p_ann_mx_elcn_val        := l_vpf.ann_mx_elcn_val;
   --
   p_tx_typ_cd         := l_vpf.tx_typ_cd;
   p_acty_typ_cd       := l_vpf.acty_typ_cd;
   p_vrbl_rt_trtmt_cd  := l_vpf.vrbl_rt_trtmt_cd;

   -- bug 1210355
   g_vrbl_mlt_code     := l_vpf.mlt_cd;
   --
 else -- profile not found so it uses rules.
   --
   -- FONM
   open c_asg(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)))
;
     --
     fetch c_asg into l_asg;
     --
   close c_asg;
   --

/* -- 4031733 - Cursor c_state populates l_state variable which is no longer
   -- used in the package. Cursor can be commented

   if p_person_id is not null then

     open c_state(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
     fetch c_state into l_state;
     close c_state;

     if l_state.region_2 is not null then

       l_jurisdiction_code :=
          pay_mag_utils.lookup_jurisdiction_code
            (p_state => l_state.region_2);
     end if;
   end if;
*/

   if p_acty_base_rt_id is not null then
     --
     for l_vrr in c_vrr(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))) loop
       --
       -- Call formula initialise routine
       --
       l_outputs := benutils.formula
         (p_formula_id     => l_vrr.formula_id,
          p_effective_date => nvl(p_lf_evt_ocrd_dt,p_effective_date),
          p_business_group_id => l_epe.business_group_id,
          p_assignment_id  => l_asg.assignment_id,
          p_organization_id  => l_asg.organization_id,
          p_pgm_id	=> l_epe.pgm_id,
          p_pl_id		=> l_epe.pl_id,
          p_pl_typ_id	=> l_epe.pl_typ_id,
          p_opt_id	=> l_opt.opt_id,
          p_ler_id	=> l_epe.ler_id,
          p_acty_base_rt_id   => p_acty_base_rt_id,
          p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
          p_jurisdiction_code => l_jurisdiction_code,
          p_param1             => 'BEN_IV_RT_STRT_DT',
          p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
          p_param2             => 'BEN_IV_CVG_STRT_DT',
          p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt));
       --
       if l_outputs(l_outputs.first).value is not null then
         --
         p_val := l_outputs(l_outputs.first).value;
         exit;
         --
       end if;
       --
     end loop;
     --
   elsif p_actl_prem_id is not null then
     --
       -- Call formula initialise routine
       --
       open c_ava(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
       fetch c_ava into l_ava;
       if l_ava.vrbl_rt_add_on_calc_rl is not null then

         l_outputs := benutils.formula
         (p_formula_id        => l_ava.vrbl_rt_add_on_calc_rl,
          p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
          p_business_group_id => l_epe.business_group_id,
          p_assignment_id     => l_asg.assignment_id,
          p_organization_id   => l_asg.organization_id,
          p_pgm_id	      => l_epe.pgm_id,
          p_pl_id             => l_epe.pl_id,
          p_pl_typ_id	      => l_epe.pl_typ_id,
          p_opt_id	      => l_opt.opt_id,
          p_ler_id	      => l_epe.ler_id,
          p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
          p_jurisdiction_code =>  l_jurisdiction_code,
          p_param1             => 'BEN_IV_RT_STRT_DT',
          p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
          p_param2             => 'BEN_IV_CVG_STRT_DT',
          p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt));

         if l_outputs(l_outputs.first).value is not null then
           p_val := l_outputs(l_outputs.first).value;
         end if;
       end if;
       close c_ava;
       --
       -- Call formula initialise routine nmh
       --
       for l_avrl in c_avrl(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)))
       loop
       if l_avrl.formula_id is not null then

         l_outputs := benutils.formula
         (p_formula_id        => l_avrl.formula_id,
          p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
          p_business_group_id => l_epe.business_group_id,
          p_assignment_id     => l_asg.assignment_id,
          p_organization_id   => l_asg.organization_id,
          p_pgm_id	          => l_epe.pgm_id,
          p_pl_id             => l_epe.pl_id,
          p_pl_typ_id	      => l_epe.pl_typ_id,
          p_opt_id	          => l_opt.opt_id,
          p_ler_id	          => l_epe.ler_id,
          p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
          p_jurisdiction_code  =>  l_jurisdiction_code,
          p_param1             => 'BEN_IV_RT_STRT_DT',
          p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
          p_param2             => 'BEN_IV_CVG_STRT_DT',
          p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt));

         if l_outputs(l_outputs.first).value is not null then
           p_val := fnd_number.canonical_to_number(l_outputs(l_outputs.first).value);
	   p_vrbl_rt_trtmt_cd  := l_avrl.rt_trtmt_cd ;
	   exit ;
         end if;
       end if;
       end loop;
       --  nmh
       --
   elsif p_cvg_amt_calc_mthd_id is not null then
     --
     for l_brr in c_brr(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))) loop
       --
       -- Call formula initialise routine
       --
       l_outputs := benutils.formula
         (p_formula_id        => l_brr.formula_id,
          p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
          p_business_group_id => l_epe.business_group_id,
          p_assignment_id     => l_asg.assignment_id,
          p_organization_id   => l_asg.organization_id,
          p_pgm_id	      => l_epe.pgm_id,
          p_pl_id	      => l_epe.pl_id,
          p_pl_typ_id	      => l_epe.pl_typ_id,
          p_opt_id            => l_opt.opt_id,
          p_ler_id	      => l_epe.ler_id,
          p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
          p_jurisdiction_code =>  l_jurisdiction_code,
          p_param1             => 'BEN_IV_RT_STRT_DT',
          p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
          p_param2             => 'BEN_IV_CVG_STRT_DT',
          p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt));
       --
       if l_outputs(l_outputs.first).value is not null then
         --
         p_val := l_outputs(l_outputs.first).value;
         exit;
         --
       end if;
       --
     end loop;
     --
   end if;
   --
 end if;
 --
 --  Bug 4873847.  Calculate CWB values.
 --
 if nvl(l_env.mode_cd,'~') = 'W' and
     l_vpf.no_mn_elcn_val_dfnd_flag = 'Y' and
     l_vpf.mlt_cd in ('CL' ) and
     l_vpf.acty_typ_cd like 'CWB%' and
     l_compensation_value is not null  and
     l_vpf.vrbl_rt_trtmt_cd =  'RPLC'
 then
     benutils.rt_typ_calc
                  (p_rt_typ_cd      => l_vpf.rt_typ_cd
                  ,p_val            => p_mn_elcn_val
                  ,p_val_2          => l_compensation_value
                  ,p_calculated_val => l_cwb_mn_elcn_val);
     --
     hr_utility.set_location('l_cwb_mn_elcn_val is '||l_cwb_mn_elcn_val,951);
     --
     benutils.rt_typ_calc
                  (p_rt_typ_cd      => l_vpf.rt_typ_cd
                  ,p_val            => p_mx_elcn_val
                  ,p_val_2          => l_compensation_value
                  ,p_calculated_val => l_cwb_mx_elcn_val);
     --
     hr_utility.set_location('l_cwb_mx_elcn_val is '|| l_cwb_mx_elcn_val,951);
     --
     -- 5371364 : Do not Operate (i.e multiply/divide..) the Increment Value.
     l_cwb_incrmt_elcn_val := p_incrmnt_elcn_val;
     /*
     benutils.rt_typ_calc
                  (p_rt_typ_cd      => l_vpf.rt_typ_cd
                  ,p_val            => p_incrmnt_elcn_val
                  ,p_val_2          => l_compensation_value
                  ,p_calculated_val => l_cwb_incrmt_elcn_val);
     */
     --
     hr_utility.set_location('l_cwb_incrmt_elcn_val is '|| l_cwb_incrmt_elcn_val,951);
     --
     benutils.rt_typ_calc
                  (p_rt_typ_cd      => l_vpf.rt_typ_cd
                  ,p_val            => p_dflt_elcn_val
                  ,p_val_2          => l_compensation_value
                  ,p_calculated_val => l_cwb_dflt_val);
     --
     hr_utility.set_location('l_cwb_dflt_val is '|| l_cwb_dflt_val,951);
     --
     if (l_vpf.rndg_cd is not null or
         l_vpf.rndg_rl is not null) then

       if l_cwb_mn_elcn_val is not null then
         l_rounded_value := benutils.do_rounding
           (p_rounding_cd     => l_vpf.rndg_cd,
            p_rounding_rl     => l_vpf.rndg_rl,
            p_value           => l_cwb_mn_elcn_val,
            p_effective_date  => nvl(p_lf_evt_ocrd_dt,p_effective_date));
         l_cwb_mn_elcn_val := l_rounded_value;
       end if;
       --
       if l_cwb_mx_elcn_val is not null then
         l_rounded_value := benutils.do_rounding
           (p_rounding_cd     => l_vpf.rndg_cd,
            p_rounding_rl     => l_vpf.rndg_rl,
            p_value           => l_cwb_mx_elcn_val,
            p_effective_date  => nvl(p_lf_evt_ocrd_dt,p_effective_date));
         l_cwb_mx_elcn_val := l_rounded_value;
       end if;
       --
       if l_cwb_dflt_val is not null then
         l_rounded_value := benutils.do_rounding
           (p_rounding_cd     => l_vpf.rndg_cd,
            p_rounding_rl     => l_vpf.rndg_rl,
            p_value           => l_cwb_dflt_val,
            p_effective_date  => nvl(p_lf_evt_ocrd_dt,p_effective_date));
         l_cwb_dflt_val := l_rounded_value;
       end if;
     end if;
     --
     p_mx_elcn_val         := nvl(l_cwb_mx_elcn_val, p_mx_elcn_val);
     p_mn_elcn_val         := nvl(l_cwb_mn_elcn_val, p_mn_elcn_val);
     p_incrmnt_elcn_val    := nvl(l_cwb_incrmt_elcn_val,p_incrmnt_elcn_val);
     p_dflt_elcn_val       := nvl(l_cwb_dflt_val, p_dflt_elcn_val);
     p_val                 := p_dflt_elcn_val; -- Bug 7331668
     --
 end if;
 --
 -- End Bug 4873847.
 --
 hr_utility.set_location('doing rounding '||l_package,10);
 --
 if (l_vpf.rndg_cd is not null or
     l_vpf.rndg_rl is not null)
     and p_val is not null then
   --
   l_rounded_value := benutils.do_rounding
     (p_rounding_cd     => l_vpf.rndg_cd,
      p_rounding_rl     => l_vpf.rndg_rl,
      p_value           => p_val,
      p_effective_date  => nvl(p_lf_evt_ocrd_dt,p_effective_date));
   --
   p_val := l_rounded_value;
   --
 end if;
  --
  -- Bug 2260440 : determine assignment id, as it may be used by formula.
  --
  if l_asg.assignment_id is null and
    (l_vpf.upr_lmt_calc_rl is not null or l_vpf.lwr_lmt_calc_rl is not null )
  then
     -- FONM
     open c_asg(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
     --
     fetch c_asg into l_asg;
     --
     close c_asg;
  end if;
  --
  hr_utility.set_location('Floor/Ceiling Rule Checking'||l_package,30);
  benutils.limit_checks
    (p_upr_lmt_val       => l_vpf.upr_lmt_val,
    p_lwr_lmt_val        => l_vpf.lwr_lmt_val,
    p_upr_lmt_calc_rl    => l_vpf.upr_lmt_calc_rl,
    p_lwr_lmt_calc_rl    => l_vpf.lwr_lmt_calc_rl,
    p_effective_date     => nvl(p_lf_evt_ocrd_dt,p_effective_date),
    p_business_group_id  => l_epe.business_group_id,
    p_assignment_id      => l_asg.assignment_id,
    p_organization_id    => l_asg.organization_id,
    p_pgm_id	         => l_epe.pgm_id,
    p_pl_id		 => l_epe.pl_id,
    p_pl_typ_id	         => l_epe.pl_typ_id,
    p_opt_id	         => l_opt.opt_id,
    p_ler_id	         => l_epe.ler_id,
    p_state              => l_state.region_2,
    p_acty_base_rt_id    => p_acty_base_rt_id,
    p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
    p_val                => p_val);
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
  end main;
  --
end ben_determine_variable_rates;

/
