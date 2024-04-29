--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_ACTIVITY_BASE_RT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_ACTIVITY_BASE_RT" as
/* $Header: benactbr.pkb 120.18.12010000.4 2009/11/05 13:17:27 pvelvano ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                     Copyright (c) 1997 Oracle Corporation                    |
|                        Redwood Shores, California, USA                       |
|                             All rights reserved.                             |
+==============================================================================+
Name: Determine Activity Base Rates

Purpose:
  This program Determines the Activity Base Rate.   Whether it be a Standard
  Rate, Flex Credit, or Imputed Income, the calculation and processing are
  the same.

History:
  Date             Who        Version    What?
  ----             ---        -------    -----
   7 May 98        Ty Hayden  110.0      Created.
  16 Jun 98        T Guy      110.1      Removed exception.
  18 Jun 98        Ty Hayden  110.2      Added p_rt_usg_cd
                                               p_bnft_prvdr_pool_id
                                               p_prtt_rt_val_id
  25 Jun 98        T Guy      110.3      Replaced all occurrences of
                                         'PER10' with 'PERTEN'
  15 Jul 98        Ty Hayden  110.4      Assign rt_usg_cd to output.
  21 Jul 98        T Guy      110.5      Removed return statements and
                                         replaced with hard errors for
                                         NULL l_compensation,
                                              l_actl_prem_value,
                                              l_prnt_rt_value.
  11 Aug 98        Ty Hayden  110.6      Added mlt_cd, val, and mn_mx edits.
   8 Oct 98        T Guy      115.1      Added error messages and set location
                                         calls.
  19 Oct 98        T Guy      115.2      Added ann_val, ann_mn-mx val, cmcd val
                                         mn - mx acty ref period cd,
                                         actl_prem_id, cvg_amt_cal_mthd_id
                                         bnft_rt_typ_cd, rt_typ_cd, rt_mlt_cd,
                                         comp_lvl_fctr_id, entr_ann_val_flag,
                                         ptd_comp_lvl_fctr_id, ann_dflt_val
                                         Put in rate calculated prior to enrollment
                                         logic.
                                         Added call to calculate rt_strt_dt and
                                         get rt_strt_dt_cd and rl.
                                         ben_determine_date.rate_and_coverage_dates
  25 Oct 98      T Guy        115.3      removed show errors
  27 Oct 98      T Guy        115.4      removed date track for ben_prtt_rt_val_f
  29 Oct 98      T Guy        115.5      fixed dflt_ann val
  12 Nov 98      T Guy        115.6      Implemented overall min/max val and
                                         rules
  24 Nov 98      T Guy        115.7      Fixed undefined upr/lwr rule checking
  02 Dec 98      T Guy        115.8      removed mlt_cd FLENR, this was replaced
                                         by entr_val_at_enrt_flag.
  02 Dec 98      T Guy        115.9      Put mlt_cd FLENR back in until form is
                                         fixed to handle enter val at enrt.
  02 Dec 98      T Guy        115.10     Version syncing.
  08 Dec 98      T Guy        115.11     added comp_lvl_fctr_id assignment when
                                         entr_at_enrt_flag = Y
  17-Dec-98      T Guy        115.12     Fixed bug 1582 - took out nocopy cursor c_btr
                                                 because comp_lvl_fctr_id is now
                                                 stored on acty_base_rt.
                                               bug 1589 - changed logic process
                                                 to check that actl_prem_id is
                                                 not null before calling actl_prem
  22-Dec-98      T Guy        115.13     Removed the FLENR mlt_cd and added
                                         entr_val_at_enrt_flag
  05-Jan-98      T Guy        115.14     Fixed cursor c_abr2
  18-Jan-99      G Perry      115.15     LED V ED
  24-Feb-99      T Guy        115.16     Added overide check
  09-Mar-99      G Perry      115.17     IS to AS.
  06-Apr-99      T Guy        115.18     Fixed the overide date check
  24-Apr-99      lmcdonal     115.19     prtt-rt-val now has a status code
                                         as does prtt_enrt_rslt.
  07-may-99      shdas        115.20     added parameters to genutils.formula.
  08-May-99      jcarpent     115.21     Pass greatest(elig_strt_dt,
                                         lf_evt_ocrd_dt)into start dt routines.
  27 May 99      maagrawa     115.22     Modified the procedure to be called
                                         without passing in the chc_id and pass
                                         in reqd. details instead.
  02 Jun 99      tguy         115.23     Modified the main procedure check that
                                         effective start date of acty_base_rt is
                                         >= enrt_perd_strt_dt for this chc.
  28 Jun 99      tguy         115.24     Made total premium changes
  02 Jul 99      lmcdonal     115.25     Make use of genutils limit_checks and
                                         rt_typ_calc.
  09 Jul 99      bbulusu      115.25     Added checks for backed out nocopy life evt.
  16 Jul 99      lmcdonal     115.26     limit_checks parms changed.
  20 JUL 99      Gperry       115.27     genutils -> benutils package rename.
  22 JUL 99      mhoyes       115.28   - Added trace messages.
                                       - Replace +0s.
  31 AUG 99      mhoyes       115.30   - Added trace messages.
  07 SEP 99      tguy         115.31     fixed call to
                                         pay_mag_utils.lookup_jurisdiction_code
  10-SEP-99      maagrawa     115.32     Bug 3109. enrt_perd_strt_dt to be
                                         effective date when no chc is passed.
  13-sep-99      jcarpent     115.33     Bug 3252. use only epe.bg_id not
                                         p_business_group_id, since may be null
                                         bug is that no current enrt found due
                                         to business group mismatch (null).
  13-sep-1999    jcarpent     115.34   - Patch on 115.29 for bug 3252.
  13-sep-1999    jcarpent     115.35   - Leapfrog. Same as version 115.33
                                         except comments.
  21-sep-1999    tguy         115.36     added check for dflt_enrt_cd for
                                         dflt_val assignemnt
  29-Sep-1999    lmcdonal     115.37     Call prorate_min_max and compare_balances.
  04-Oct-1999    tguy         115.38     added call to dt_fndate
  21-Oct-1999    pbodla       115.39     benutils.limit_checks: p_val is sent
                                         instead of l_rounded_value
  29-Oct-1999    lmcdonal     115.40     When the use calc acty bs rt flag is OFF
                                         do not calc the rate out, just send along
                                         the 'value' field.
                                         See bugs3549_3552.doc.
  14-Nov-1999    mhoyes       115.41   - Added trace messages.
  16-Nov-1999    pbodla       115.42   - Added acty_base_rt_id as context to
                                         val_calc_rl evaluation and to
                                         limit_checks, rate_and_coverage_dates
                                         calls.
  18-Nov-1999    pbodla       115.43   - Added p_elig_per_elctbl_chc_id as context to
                                         val_calc_rl evaluation , passed to limit_checks
  29-Nov-1999    jcarpent     115.44   - Added call to det._dflt_enrt_cd
  15-Dec-1999    lmcdonal     115.45     Do not force min and max values if the entr-
                                         ann-val-flag is on.
  17-Jan-00      tguy         115.46     Added check for rounding when vrbl
                                         rt trtmt cd = rplc do not round at
                                         value at this level
  20-Jan-00      maagrawa     115.47     Pass payroll_id to ben_distribute_rates
  20-Jan-00      lmcdonal     115.48     If enrt_bnft cvg val is null, use dflt
                                         val.  Bug 1118016.
  09-FEB-2000    pbodla       115.49   - Bug : 1169626 p_acty_base_rt_id is passed
                                         to formula instead of l_acty_base_rt_id
  18-FEB-2000    pbodla       115.50   - c_prv modified : order by clause added.
                                         When prv record is fetched it is fetching
                                         the first row. It should fetch the latest
                                         participant rate value record for a given
                                         enrollment result id.
  29-Mar-00      mmogel       115.51     I changed the message numbers from
                                         91382 to 91832 in the message name
                                         BEN_91382_PACKAGE_PARAM_NULL and the
                                         91383 to 92833 in the message name
                                         BEN_91833_CURSOR_RETURN_NO_ROW  and also
                                         added tokens to some other messages
   31-Mar-2000   jcarpent     115.52   - bug 1252087/4983. Fix dflt_val for
                                         dflt_enrt_cds of 'NSDCS','NNCS';
   19-Apr-2000   lmcdonal     115.53   - bug 5088, per gp, calls to dt_fndate.
                                       change_ses_date should be in the highest
                                       level batch processes (for rule calls)
                                       not in lower level procs like this one.

   10-MAY-200    Tilak        115.54     bug 4816 l_val is not rounded to hundredth fixd by
                                          correcting if condition. nvl added in l_vr_trtmt_cd
   12-MAY-2000   mhoyes       115.55  - Added messages for profiling.
   22-May-2000   lmcdonal     115.56     Leap frog of 52 with fix for 1295277:
                                        when checking to see if
                                        acty-base-rt is already a prtt-rt-val
                                        record, do not compare acty-typ-cd; this
                                        can come from the acty-base-rt row OR
                                        from vrbl-rt row.
   22-May-2000   lmcdonal     115.57    Bug 1295277: fix noted above.  This is
                                        leap from version 55.  'real' version.
   22-May-2000   lmcdonal     115.58    leap of version 56 to allow fido to fix
                                        aera data.
   22-May-20000  lmcdonal     115.59    'real' version....allow mis-matched
                                       acty-type and tax-type codes, causing
                                       update to be determined only by
                                       acty-base-rt-id.
   26-May-2000   shdas        115.60    round rates before variable
                                        rates applied--5152.
   29-May-2000   mhoyes       115.61   Added record structures to main.
   29-May-2000   mhoyes       115.62   Re-applied fix 5152.
   31-May-2000   mhoyes       115.63   Added enrt_perd_strt_dt to p_currepe_row.
   12-JUN-2000   tilak        115.64   acty_base_rt  >= enrt_perd_strt_dt condition
                                       is removed from c_abr cursor for bug 5173
                                       This conition return no row .when the enrollment for future
                                       period the date betwen chek the future period and this condion
                                       check the current period
   26-JUN-2000   shdas        115.65   added codes for new mlt_cd 'SAREC'.
   28-JUN-2000   mhoyes       115.66 - Fixed duplicate rate problem.
                                     - Tuned c_prv.
                                     - Bypassed c_current_elig when prtn_strt_dt
                                       is passed in.
   25-AUG-2000   pbodla       115.67 - Bug : 1386285 : When RT_OVRIDN_THRU_DT
                                       is null assume it as EOT.
   28-SEP-2000   stee         115.68 - Added p_cal_val for UK Select to
                                       calculate a child rate if the parent
                                       rate is calculate at enrollment.
   27-AUG-2000   RCHASE       115.69 - wwbug#1207803.999 - correct perfprv
                                       cursor to fetch rows when
                                       updates have been made to the enrollment
                                       result past the life event occured date.
                                       This is a leapfrog version based on
                                       115.67.
   29-AUG-2000   jcarpent     115.70 - Merge version based on 115.68 and
                                       115.69.
   06-Nov-2000   tilak        115.71   bug-1480407 calculation of rate for enter at entrolment is added
   06-nov-2000   tilak        115.72
   29-nov-2000   gperry       115.73   Added person_id to epe record so that
                                       rules work correctly in rate and
                                       coverage call. WWBUG 1510623.
   15-jan-2001   tilak        115.74   encremental chek is added to the rate
   22-jan-2001   tilak        115.75   p_parent_val added to calculate the parent value
                                       when the child recod called for calucaltion from
                                       enrollment and parent entr_val_at_entr is on
   07-mar-2001   tilak        115.76   bug : 1628762, when the premium based on coverage
                                       and coverage is range then benefit id reauired
                                       to get the premiuum value -c_enrt_prem cursor changed
   06-mar-2001   ikasire      115.77   bug 1650517 not passing p_complete_year_flag
                                       for SAREC condition for communicated amount
                                       calculation
  15-mar-2001    tilak        115.78   bun : 1676551  calling premium calcualtion
  21-mar-2001    tilak        115.79   ultmt_upr_lmt,ultmt_lwr_lmt is validated
  01-apr-2001    tilak        115.80   ultmt_upr_lmt_calc_rl ,ltmt_lwr_lmtcalc_rl is validated
  01-may-2001    kmahendr     115.81   Bug#1749068 - changed p_cal_val value depending on parent rate's
                                       enter value at enrollment flag
  03-may-2001    kmahendr     115.83   As version 115.82 was based on leapfrog of version 115.77,
                                       version 115.81 brought forward.
  13-Jul-2001    ikasire      115.84   bug 1834655 fixed the code for default enrollment
  13-Jul-2001    ikasire      115.85   removed the show errors
  18-Jul-2001    ikasire      115.86   bug 1834655 added ann_rt_val to prv and perfprv
                                       cursors
  27-Aug-2001    mhoyes       115.87 - Replaced generic error messages,
                                       - 91832 with 92748.
                                       - 91833 with 92743, 92738, 92739, 92740
                                         92741, 92742
                                       - 91835 with 92744, 92745, 92746, 92747
  29-aug-2001    tilak        115.88   bug:1949361 jurisdiction code is
                                              derived inside benutils.formula.
  27-Sep-2001    kmahendr     115.89   Bug#1981673-Added parameter ann_mn_elcn_val and
                                       ann_mx_elcn_val to ben_determine_variable_rates
                                       call and returned values assigned

  05-dec-2001    tjesumic     115.90   Add,mutltifly,substract added for vapro values
                                       bug:2112513
  05-Feb-2002    kmahendr     115.91   Bug#2207947-Added a cursor c_perfPrv_2 to get the
                                       prtt_rt_val_id if the coverage and rate starts in
                                       future
  05-Feb-2002    kmahendr     115.92   Added dbdrv : checkfile line
  06-Feb-2002    pabodla      115.93   Calculating cmcd_mn/mx values.
  07-Feb-2002    ikasire      115.94   Bug 2192102 Flex Credit fails in case of the
                                       Flex Credit or VAPRO associated with the FC is
                                       based on coverage calculation- fixed
  15-Nov-2001    dschwart/    115.95   Bug#1791203: altered estimate only functions to
                 gopal                 calculate correctly when frequency rules are
                                       altered to 24 pay periods. bug : 1794303
  26-Mar-2002    kmahendr     115.96   Bug#1833008 - Added parameter p_cal_for to the call
                                       determine_compensation to handle multi-assignment.
  18-Apr-2002    lmcdonal     115.97   l_coverage_val was not always being loaded
                                       from p_bnft_amt.  Needed for SS call to
                                       this package.
  30-Apr-2002    kmahendr     115.98   Added token to error message-91832.
  01 May 2002    lmcdonal     115.99   Bug 2048257 Added main_w.
  20-May-2002    pabodla      115.100  If this procedure is called from enrt
                                       process then validate value with
                                       enrt_rt table's min/max instead of
                                       standard rate min max values.

  23 May 2002    kmahendr     115.101  Added a parameter to main.
                              115.102  No changes
  03 Jun 2002    pabodla      115.103  Bug 2400850 : Checking prtt_enrt_rslt_id
                                       before assigning any values to p_dflt_val
  05 Jun 2002    pabodla      115.104  Bug 2403243 : If vapro and abr both has
                                       null values for min/max then assigning
                                       null to p_mn/max_elcn_val variables
                                       instead of zero
  08-Jun-2002    pabodla      115.105  Do not select the contingent worker
                                       assignment when assignment data is
                                       fetched.
  27-Jun-2002    Tilak        115.106  Bug  2438506: if vapro treatment code is
                                       multiply by and abr have null value
                                       then trat abr value as 1 else causes
                                       null rate value calculation.
  08-Jul-2002    ikasire      115.107  Bug 2445318 handling the p_dflt_val and
                                       p_ann_dflt_val cases
  12-Jul-2002    vsethi       115.108  Bug 1699585 added tokens for message BEN_91932_NOT_INCREMENT
  15-Jul-2002    vsethi       115.109  Wrong variable referenced in cursor c_pln
  04-sep-2002    kmahendr     115.111  Added new acty_ref_perd_cd - phr.
  17-Sep-2002    hnarayan     115.112  Bug 2569884 - communicated min and max values should
                       be calculated irrespective of whether calculate for
                       enrollment flag is checked or not
  11-Oct-2002    vsethi       115.113  Rates Sequence no enhancements. Modified to cater
                           to new column ord_num on ben_acty_base_rt_f
  24-Oct-2002    shdas        115.114  Added ben_env_object.init to main_w
  13-Nov-2002    vsethi       115.115  Bug 1210355, if variable rate is detected the mlt code
                       attached to the variable profile should be displayed
                       for the rate
  09-DEC-2002    hnarayan     115.116  Bug 2691169 - added order by clause to cursor c_asg
                    so that it retrieves assignmnets of type 'E' first
                    and then of type 'B'
  16 Dec 02      hnarayan     115.117  Added NOCOPY hint
  24 Dec 02      kmullapu     115.118   Added new cursor c_pl_opt_name to display pl-opt name
                                       in error messages. Bug 2385186
  27 Dec 02      ikasire      115.119  Bug 2677804 changes for override thru date
  23 Jan 03      ikasire      115.120  Bug 2149438 using to overloaded annual_to_period procedure
                                       and rounding to 4 digits to improve the precision.
  05-Feb-03      gjesumig     115.121  GSP enhancement, calculation added for  new mlt_cd  'PRV'
  12-Feb-03      tjesumic     115.122  2797031 , if premium value is null it is recaulcualted
                                       nvl added  to premium value
  13-Feb-03      kmahendr     115.123  Added a parameter - p_iss_val and codes for auto_distr
  22-May-03      kmahendr     115.124  Included ERL to evaluate formula
  06-Jun-03      kmahendr     115.125  Rt_mlt_cd is populated from variable rate only if the
                                       treatment code is Replace.Bug#2996378
  21-oct-03      hmani        115.126  Bug 3177401 - Changed p_date_mandatory_flag to 'Y'
  11-nov-03      hmani        115.127  Reversing back the previous fix
  12-Nov-03      ikasire      115.128  Bug 3253180 Defaults not working when enter value at
                                       enrollment annual flag is checked  for the current
                                       enrollment
  13-Nov-03      kmahendr     115.129  Bug#3254240 - added codes in main_w to get the
                                       communicated value
  23-Feb-04      stee         115.130  Bug 3457483 - Check the assignment to use code
                                       in activity base rate when selecting the
                                       assignment.
  14-Apr-04      mmudigon     115.132  FONM changes
  29-May-04      mmudigon     115.133  FONM changes continued
  05-Aug-04      tjesumic     115.134  FONM for ben_derive_factors fonm date paseed as param
  03-Sep-04      hmani        115.135  fixed cmcd_dflt_val issue Bug 3274902
  06-sep-04      hmani        115.136  Modified for annual value flag Bug 3274902
                                       Also fixed few missed out FONM issues.
  03-Dec-04      vvprabhu     115.137  Bug 3980063 - SSBEN Trace Enhancement
  03-Dec-04      ikasire      115.138  Added defaults to main_w as per main
  14-dec-04      nhunur       115.139  cwb now allows null values for min/max/incrmt val
                                       so no need to validate
  30-dec-2004    nhunur       115.140  4031733 - No need to open cursor c_state.
  24-Jan-2004    swjain       115.141   3981982 - Min Max Enhancement. Added code to evaluate
                                                        min max rule.
  27-Jan-2004  swjain        115.142   Updated the message number of the the message
                                                         BEN_XXXX_MN_MX_RL_OUT_ERR to
							 BEN_94130_MN_MX_RL_OUT_ERR
   31-Jan-2004  swjain        115.143  3981982 - Added more input paramters in call to
                                                        benutils.formula
   17-Feb-2004  vvprabhu      115.144  Bug 4143012 : Changes in procedure main_w
                                       to avoid value of cost1 being displayed for
				       cost2 when cost1 is 'SAREC'
   12-May-2005  ikasire       115.145  Moved the fnd_message binding into IF clause to avoid
                                       misleading error message from SSBEN
   23-May-2005  lakrish       115.146  4235088, do fnd_number.canonical_to_number() to the
                                       FF output before assigning to a number variable
   09-Jun-2005  nhunur        115.147  4383988, do fnd_number.canonical_to_number() to all
                                       FF that return a number variable
  05-Sep-05     swjain        115.148  Bug No 4538786 Per Pay Period with frequency rules
                                       changes in procedure main
   13-Sep-2005  rbingi        115.151  Bug-4604560 in procedure main, Added close for
                                       cursor get_rt_and_element
   28-Sep-2005  nhunur        115.152  Bug 4637525 : CWB- MULTIPLE OF COMPENSATION CHANGES.
   02-Feb-2006  stee          115.153  Bug 4873847. cwb:  Round the rec_val,
                                       rec_mn_val, rec_mx_val.
   24-Apr-2006  rgajula       115.154  Bug  5031047 Modified the order by clause to prv.rt_start_dt asecending
					                        and added the clause c_effective_date < prv.rt_end_dt for the cursors
					                        c_prv,c_perfprv,c_perfprv_2
   18-May-2006  rgajula       115.155  Bug 5225815 do not prorate if there are no prior elections
					                        or the l_rt_strt_dt is null
   07-Jul-2006  bmanyam       115.156  5371364 : Do not Operate (i.e multiply/divide..)
                                       the Increment Value.
   21-Sep-2006  vborkar       115.157  5534498 : Passed p_person_id and p_start_date(rt_strt_dt)
                                       parameters to annual_to_period for correct rate calculation
                                       on 'Recalculate'.
   25-Sep-2006  bmanyam       115.158  5557305 : Premium has to be recalculated everytime
                                       for rates of type 'Multiple of Premium'
   3-nov-2006   nhunur        115.159  c_perfprv,c_perfprv_2 to handle non recurrring

   1-Feb-2007   bmanyam       115.160  5748126: Update BEN_ENRT_RT with the
					                        latest PRV_ID, which occurs before the LE_OCRD_DT
   23-Feb-2006  bmanyam       115.161  5898039: same as above. [ON or before LE_OCRD_DT]

   22-Jan-2007  rtagarra      115.160  ICM Changes.

   19-Dec-2007  krupani       115.162  Changes against Bug 6015724 incorporated from 115.162.
													Forward port Bug is 6158436

   26-Dec-2007  krupani       115.164  Changes against Bug 6314463 and 6330056 incorporated from 115.164
													in R12 mainline
   17-Jun-2008  sagnanas      115.165  Bug 7154229
   11-Feb-2009  velvanop      115.166  Bug 7414757: Added parameter p_entr_val_at_enrt_flag.
	                                      VAPRO rates which are 'Enter value at Enrollment', Form field
					      should allow the user to enter a value during enrollment.
   25-Sep-2009  velvanop      115.167  Bug 8943410(11i): System applies rounding to rate value prior to the application of VAPRO
                                       factor. The fix is to apply rounding after the VAPRO has been applied
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_determine_activity_base_rt';
g_debug boolean := hr_utility.debug_enabled;
--
TYPE g_element_link_id_table IS TABLE OF pay_element_links_f.element_link_id%TYPE
   INDEX BY BINARY_INTEGER;
--
-------------------------------------------------------------------------------
--                            get_expr_val
-------------------------------------------------------------------------------
function get_expr_val(p_op       in varchar2,
                      p_oper1    in number,
                      p_oper2    in number)
return number is
  --
  l_proc           varchar2(80) := 'get_expr_val';
  l_oper1          number;
  l_oper2          number;
  l_ret_val        number := null;
  --
begin
  --
  l_oper1 := p_oper1;
  l_oper2 := p_oper2;
  --
  if p_oper1 is null and p_oper2 is null then
     --
     l_ret_val := null;
     return l_ret_val;
     --
  elsif p_oper1 is null then
     --
     l_oper1 := 0;
     --
  elsif p_oper2 is null then
     --
     l_oper2 := 0;
     --
  end if;
  --
  if p_op = '+' then
     --
     l_ret_val := l_oper1+l_oper2;
     --
  elsif p_op = '-' then
     --
     l_ret_val := l_oper1-l_oper2;
     --
  elsif p_op = '*' then
     --
     if p_oper1 is null then
        --
        l_oper1 := 1;
        --
     elsif p_oper2 is null then
        --
        l_oper2 := 1;
        --
     end if;
     --
     l_ret_val := l_oper1*l_oper2;
  end if;
  return l_ret_val;
  --
end get_expr_val;

PROCEDURE main
  (p_currepe_row                 in ben_determine_rates.g_curr_epe_rec
   := ben_determine_rates.g_def_curr_epe_rec
  ,p_per_row                     in per_all_people_F%rowtype
   := ben_determine_rates.g_def_curr_per_rec
  ,p_asg_row                     in per_all_assignments_f%rowtype
   := ben_determine_rates.g_def_curr_asg_rec
  ,p_ast_row                     in per_assignment_status_types%rowtype
   := ben_determine_rates.g_def_curr_ast_rec
  ,p_adr_row                     in per_addresses%rowtype
   := ben_determine_rates.g_def_curr_adr_rec
  ,p_person_id                   IN number
  ,p_elig_per_elctbl_chc_id      IN number
  ,p_enrt_bnft_id                IN number default null
  ,p_acty_base_rt_id             IN number
  ,p_effective_date              IN date
  ,p_lf_evt_ocrd_dt              IN date   default null
  ,p_perform_rounding_flg        IN boolean default true
  ,p_calc_only_rt_val_flag       in boolean default false
  ,p_pl_id                       in number  default null
  ,p_oipl_id                     in number  default null
  ,p_pgm_id                      in number  default null
  ,p_pl_typ_id                   in number  default null
  ,p_per_in_ler_id               in number  default null
  ,p_ler_id                      in number  default null
  ,p_bnft_amt                    in number  default null
  ,p_business_group_id           in number  default null
  ,p_cal_val                     in number  default null
  ,p_parent_val                  in number  default null
  ,p_called_from_ss              in boolean default false
  ,p_val                         OUT NOCOPY number
  ,p_mn_elcn_val                 OUT NOCOPY number
  ,p_mx_elcn_val                 OUT NOCOPY number
  ,p_ann_val                     OUT NOCOPY number
  ,p_ann_mn_elcn_val             OUT NOCOPY number
  ,p_ann_mx_elcn_val             OUT NOCOPY number
  ,p_cmcd_val                    OUT NOCOPY number
  ,p_cmcd_mn_elcn_val            OUT NOCOPY number
  ,p_cmcd_mx_elcn_val            OUT NOCOPY number
  ,p_cmcd_acty_ref_perd_cd       OUT NOCOPY varchar2
  ,p_incrmt_elcn_val             OUT NOCOPY number
  ,p_dflt_val                    OUT NOCOPY number
  ,p_tx_typ_cd                   OUT NOCOPY varchar2
  ,p_acty_typ_cd                 OUT NOCOPY varchar2
  ,p_nnmntry_uom                 OUT NOCOPY varchar2
  ,p_entr_val_at_enrt_flag       OUT NOCOPY varchar2
  ,p_dsply_on_enrt_flag          OUT NOCOPY varchar2
  ,p_use_to_calc_net_flx_cr_flag OUT NOCOPY varchar2
  ,p_rt_usg_cd                   OUT NOCOPY varchar2
  ,p_bnft_prvdr_pool_id          OUT NOCOPY number
  ,p_actl_prem_id                OUT NOCOPY number
  ,p_cvg_calc_amt_mthd_id        OUT NOCOPY number
  ,p_bnft_rt_typ_cd              OUT NOCOPY varchar2
  ,p_rt_typ_cd                   OUT NOCOPY varchar2
  ,p_rt_mlt_cd                   OUT NOCOPY varchar2
  ,p_comp_lvl_fctr_id            OUT NOCOPY number
  ,p_entr_ann_val_flag           OUT NOCOPY varchar2
  ,p_ptd_comp_lvl_fctr_id        OUT NOCOPY number
  ,p_clm_comp_lvl_fctr_id        OUT NOCOPY number
  ,p_ann_dflt_val                OUT NOCOPY number
  ,p_rt_strt_dt                  OUT NOCOPY date
  ,p_rt_strt_dt_cd               OUT NOCOPY varchar2
  ,p_rt_strt_dt_rl               OUT NOCOPY number
  ,p_prtt_rt_val_id              OUT NOCOPY number
  ,p_dsply_mn_elcn_val           OUT NOCOPY number
  ,p_dsply_mx_elcn_val           OUT NOCOPY number
  ,p_pp_in_yr_used_num           OUT NOCOPY number
  ,p_ordr_num                OUT NOCOPY number
  ,p_iss_val                     OUT NOCOPY number
  )
IS
  --
  l_value                 number;
  l_rounded_value         number;
  l_pl_id                 number;
  l_oipl_id               number;
  l_coverage_value        number;
  l_val                   number;
  l_dflt_val              number;
  l_compensation_value    number;
  l_actl_prem_value       number;
  l_prnt_rt_value         number;
  l_comp_lvl_fctr_id      number;
  l_actl_prem_id          number;
  l_acty_base_rt_id       number;
  l_dummy_num             number;
  l_dummy_char            varchar2(30);
  l_dummy_date            date;
  l_outputs               ff_exec.outputs_t;
  l_vr_val                number := null;
  l_vr_mn_elcn_val        number := null;
  l_vr_mx_elcn_val        number := null;
  l_vr_incrmt_elcn_val   number := null;
  l_vr_dflt_elcn_val      number := null;
  l_vr_tx_typ_cd          varchar2(30);
  l_vr_acty_typ_cd        varchar2(30);
  l_vr_trtmt_cd           varchar2(30);
  l_prtt_rt_val_id        number;
  l_bnft_prvdr_pool_id    number;
  l_rt_strt_dt            date;
  l_rt_strt_dt_cd         varchar2(30);
  l_rt_strt_dt_rl         number;
  l_ann_dflt_val          number;
  l_ann_val               number;
  l_cmcd_val              number;
  l_pl_opt_name           varchar2(600) := null;
  --
  -- For selfservice enhancement : Communicated values are required
  -- on self service pages.
  --
  l_cmcd_mn_val              number;
  l_cmcd_ann_mn_val              number;
  l_cmcd_mx_val              number;
  l_cmcd_ann_mx_val              number;
  --

 -- bug 3274092
  l_cmcd_dflt_val number;
  l_cmcd_ann_dflt_val number;
-- bug 3274092
  --
  l_cmcd_acty_ref_perd_cd varchar2(30);
  l_acty_ref_perd_cd      varchar2(30);
  l_enrt_info_rt_freq_cd  varchar2(30);
  l_cvg_calc_amt_mthd_id  varchar2(30);
  l_lwr_outputs           ff_exec.outputs_t;
  l_upr_outputs           ff_exec.outputs_t;
  l_rt_ovridn_flag        varchar2(15);
  l_rt_ovridn_thru_dt     date;
  l_rt_val                number;
  l_prtn_strt_dt          date;
  l_jurisdiction_code     varchar2(30);
  l_dflt_enrt_cd          varchar2(30);
  l_dflt_enrt_rl          number;
  l_ptd_balance           number;
  l_clm_balance           number;
  l_commit                number;
  l_ultmt_upr_lmt         number;
  l_ultmt_lwr_lmt         number;
  l_ultmt_upr_lmt_calc_rl number;
  l_ultmt_lwr_lmt_calc_rl number;
  l_vr_ann_mn_elcn_val       number;
  l_vr_ann_mx_elcn_val       number;
  l_enrt_bnft_id             number := p_enrt_bnft_id ;
  l_assignment_id         per_all_assignments_f.assignment_id%type;
  l_payroll_id            per_all_assignments_f.payroll_id%type;
  l_organization_id       per_all_assignments_f.organization_id%type;
  --
  -- Bug 4637525
  l_cwb_dflt_val        number;
  l_cwb_incrmt_elcn_val number;
  l_cwb_mx_elcn_val     number;
  l_cwb_mn_elcn_val     number;
  -- Bug 4637525
  l_package varchar2(80) := g_package||'.main';

  --
  -- open c_pl_opt_name cursor only if error needs to be displayed.
  --
    cursor c_pl_opt_name is
     select pln.name || ' '|| opt.name
     from   ben_elig_per_elctbl_chc epe,
            ben_pl_f                pln,
            ben_oipl_f              oipl,
            ben_opt_f               opt
     where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and    epe.pl_id                  = pln.pl_id
     and    epe.oipl_id                = oipl.oipl_id(+)
     and    oipl.opt_id                = opt.opt_id(+)
     and    p_effective_date between
            pln.effective_start_date and pln.effective_end_date
     and    p_effective_date between
            oipl.effective_start_date(+) and oipl.effective_end_date(+)
     and    p_effective_date between
            opt.effective_start_date(+) and opt.effective_end_date(+);

  cursor c_enrt_rt(p_elig_per_elctbl_chc_id in number,
                   p_enrt_bnft_id in number,
                   p_acty_base_rt_id in number)
  is
   select enrt.mn_elcn_val,
          enrt.mx_elcn_val,
          enrt.incrmt_elcn_val
   from ben_enrt_rt enrt
   where (enrt.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
         or enrt.enrt_bnft_id = p_enrt_bnft_id) and
         enrt.acty_base_rt_id = p_acty_base_rt_id;
   l_enrt_rt c_enrt_rt%rowtype;
  --
  -- commented out to fix bug 3457483

  /* cursor c_asg
    (c_effective_date in date
    )
  is
    select asg.assignment_id,
           asg.organization_id,
           asg.payroll_id,
           loc.region_2
    from   per_all_assignments_f asg,hr_locations_all loc
    where  asg.person_id = p_person_id
    and    asg.assignment_type <> 'C'
    and    asg.primary_flag = 'Y'
    and    asg.location_id  = loc.location_id(+)
    and    c_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date
    order by                -- bug fix 2691169
        asg.assignment_type desc;
  l_asg c_asg%rowtype; */
  -- end bug fix 3457483
  cursor c_epe
  is
    select epe.pl_id,
           epe.oipl_id,
           epe.pgm_id,
           epe.pl_typ_id,
           epe.business_group_id,
           epe.per_in_ler_id,
           epe.plip_id,
           epe.ptip_id,
           epe.prtt_enrt_rslt_id,
           epe.roll_crs_flag,
           epe.elctbl_flag,
           epe.enrt_cvg_strt_dt,
           epe.enrt_cvg_strt_dt_cd,
           epe.enrt_cvg_strt_dt_rl,
           epe.yr_perd_id,
	   epe.pl_ordr_num,
	   epe.oipl_ordr_num,
           pel.enrt_perd_id,
           pel.lee_rsn_id,
           pel.enrt_perd_strt_dt,
           pel.acty_ref_perd_cd,
           pil.person_id,
           pil.ler_id
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil,
           ben_pil_elctbl_chc_popl pel
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
      and  epe.per_in_ler_id = pil.per_in_ler_id
      and  epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
      and  epe.per_in_ler_id = pel.per_in_ler_id;
  l_epe c_epe%rowtype;
  --
  --
  cursor c_opt
    (c_effective_date in date
    )
  is
  select opt_id
  from ben_oipl_f oipl
  where oipl.oipl_id = l_epe.oipl_id
    and    c_effective_date
           between oipl.effective_start_date
           and     oipl.effective_end_date;


  l_opt c_opt%rowtype;

  cursor c_abr
    (c_effective_date in date
    )
  is
    select abr.rt_mlt_cd,
           abr.val,
           abr.mn_elcn_val,
           abr.mx_elcn_val,
           abr.incrmt_elcn_val,
           abr.dflt_val,
           abr.rndg_cd,
           abr.rndg_rl,
           abr.pl_id,
           abr.oipl_id,
           abr.pgm_id,
           abr.acty_typ_cd,
           abr.rt_typ_cd,
           abr.bnft_rt_typ_cd,
           abr.ptd_comp_lvl_fctr_id,
           abr.entr_val_at_enrt_flag,
           abr.clm_comp_lvl_fctr_id,
           abr.tx_typ_cd,
           abr.val_calc_rl,
           abr.nnmntry_uom,
           abr.entr_ann_val_flag,
           abr.comp_lvl_fctr_id,
           abr.dsply_on_enrt_flag,
           abr.use_to_calc_net_flx_cr_flag,
           abr.rt_usg_cd,
           abr.ann_mn_elcn_val,
           abr.ann_mx_elcn_val,
           abr.lwr_lmt_val,
           abr.lwr_lmt_calc_rl,
           abr.upr_lmt_val,
           abr.upr_lmt_calc_rl,
           abr.actl_prem_id,
           abr.use_calc_acty_bs_rt_flag ,
           abr.det_pl_ytd_cntrs_cd,  -- Bug#1791203: added
           abr.element_type_id,
           abr.pay_rate_grade_rule_id,
           abr.ordr_num,
           abr.rate_periodization_rl, --BUG 3463457
	   abr.mn_mx_elcn_rl,           -- Min Max Enhancement : 3981982
	   abr.input_va_calc_rl
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_id = p_acty_base_rt_id
    and    c_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date ;

  l_abr c_abr%rowtype;
  --
  cursor c_enb(p_enrt_bnft_id number)
  is
    select enb.val,
           enb.dflt_val
    from   ben_enrt_bnft enb
    where  enb.enrt_bnft_id = p_enrt_bnft_id;
  --
  --Bug 2192102 added new cursor to find the cvg at the same level
  cursor c_enb_fc is
    select
      enb.enrt_bnft_id
    from
      ben_enrt_bnft enb,
      ben_elig_per_elctbl_chc epe,
      ben_elig_per_elctbl_chc epe_fc
    where
      enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
    and epe.pgm_id = epe_fc.pgm_id
    and nvl(epe.oipl_id,-99999) = nvl(epe_fc.oipl_id,-99999)
    and nvl(epe.pl_id,-99999) = nvl(epe_fc.pl_id,-99999)
    and nvl(epe.plip_id,-99999) = nvl(epe_fc.plip_id,-99999)
    and nvl(epe.ptip_id,-99999) = nvl(epe_fc.ptip_id,-99999)
    and nvl(epe.pl_typ_id,-99999) = nvl(epe_fc.pl_typ_id,-99999)
    and epe.per_in_ler_id = epe_fc.per_in_ler_id
    and epe_fc.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id ;
  --
  l_enb_fc c_enb_fc%rowtype;
  --
  cursor c_cvg_pl
    (c_effective_date in date
    )
  is
     select ccm.cvg_amt_calc_mthd_id
     from   ben_cvg_amt_calc_mthd_f ccm,
            ben_pl_f pln
     where  pln.pl_id = l_epe.pl_id
     and    pln.pl_id = ccm.pl_id
     and    c_effective_date
            between pln.effective_start_date
     and            pln.effective_end_date
     and    c_effective_date
            between ccm.effective_start_date
     and            ccm.effective_end_date;

  cursor c_cvg_oipl
    (c_effective_date in date
    )
  is
     select ccm.cvg_amt_calc_mthd_id
     from   ben_cvg_amt_calc_mthd_f ccm,
            ben_oipl_f cop
     where  cop.oipl_id = l_epe.oipl_id
     and    cop.oipl_id = ccm.oipl_id
     and    c_effective_date
            between cop.effective_start_date
     and            cop.effective_end_date
     and    c_effective_date
            between ccm.effective_start_date
     and            ccm.effective_end_date;

  cursor c_abr2
    (c_effective_date in date
    )
  is
    select abr2.acty_base_rt_id,abr2.entr_val_at_enrt_flag
    from   ben_acty_base_rt_f abr,
           ben_acty_base_rt_f abr2
    where  abr.acty_base_rt_id = p_acty_base_rt_id
    and    abr2.acty_base_rt_id = abr.parnt_acty_base_rt_id
    and    abr2.parnt_chld_cd = 'PARNT'
    and    c_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    c_effective_date
           between abr2.effective_start_date
           and     abr2.effective_end_date;

  cursor c_pln
    (c_effective_date in date,
     c_pl_id          in number
    )
  is
    select pln.nip_acty_ref_perd_cd
           ,pln.nip_enrt_info_rt_freq_cd
           ,name
    from   ben_pl_f pln
    where  pln.pl_id = c_pl_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;

  l_pln c_pln%rowtype;
  l_pln2 c_pln%rowtype;
  cursor c_pgm
    (c_effective_date in date
    )
  is
    select pgm.acty_ref_perd_cd,
           pgm.enrt_info_rt_freq_cd
    from   ben_pgm_f pgm
    where  pgm.pgm_id = l_epe.pgm_id
    and    c_effective_date
           between pgm.effective_start_date
           and     pgm.effective_end_date;

  l_pgm c_pgm%rowtype;

  cursor c_abp
    (c_effective_date in date
    )
  is
    select abp.bnft_prvdr_pool_id
    from   ben_aplcn_to_bnft_pool_f abp
    where  abp.acty_base_rt_id = p_acty_base_rt_id
    and    c_effective_date
           between abp.effective_start_date
           and     abp.effective_end_date
    and    abp.bnft_prvdr_pool_id in
          (select epe.bnft_prvdr_pool_id
           from  ben_elig_per_elctbl_chc epe
           where epe.pgm_id = l_epe.pgm_id
           and   epe.per_in_ler_id = l_epe.per_in_ler_id);


--Bug  5031047
--Modified the order by clause to prv.rt_Start_dt asecending
--and added the clause c_effective_date < prv.rt_end_dt
--for the below 3 prv cursors

  cursor c_prv
    (c_effective_date         in date
    ,c_acty_base_rt_id        in number
    ,c_elig_per_elctbl_chc_id in number
    )
  is
    select prv.prtt_rt_val_id,
           prv.rt_ovridn_flag,
           prv.rt_ovridn_thru_dt,
           prv.rt_val,
           prv.ann_rt_val,
	   prv.cmcd_rt_val,                -- Bug 6015724
	   prv.rt_strt_dt,
           prv.rt_end_dt
    from   ben_prtt_rt_val prv,
           ben_prtt_enrt_rslt_f pen,
           ben_elig_per_elctbl_chc epe
    where  epe.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
    and    epe.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    prv.prtt_rt_val_stat_cd is null
    and    prv.acty_base_rt_id = c_acty_base_rt_id
    and    c_effective_date
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    --and    prv.acty_typ_cd = l_abr.acty_typ_cd  bug 1295277 comment out.
    --and    prv.tx_typ_cd = l_abr.tx_typ_cd
    and    c_effective_date
           between pen.effective_start_date
           and     pen.effective_end_date
    /* get the latest prv for the enrollment result id */
    and ((c_effective_date <= prv.rt_end_dt) or (prv.rt_strt_dt = prv.rt_end_dt))
    order by prv.rt_strt_dt desc; -- 5748126 Changed ORDER-BY from ASC to DESC

  cursor c_perfprv
    (c_effective_date         in date
    ,c_acty_base_rt_id        in number
    ,c_prtt_enrt_rslt_id      in number
    )
  is
    select prv.prtt_rt_val_id,
           prv.rt_ovridn_flag,
           prv.rt_ovridn_thru_dt,
           prv.rt_val,
           prv.ann_rt_val,
	   prv.cmcd_rt_val,                -- Bug 6015724
	   prv.rt_strt_dt,
           prv.rt_end_dt
    from   ben_prtt_rt_val prv,
           ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    prv.prtt_rt_val_stat_cd is null
    and    prv.acty_base_rt_id = c_acty_base_rt_id
    and    c_effective_date
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    --RCHASE wwbug#1207803.999 - correct perfprv cursor to fetch rows when
    --                           updates have been made to the enrollment
    --                           result past the life event occured date
    --and    c_effective_date
    --       between pen.effective_start_date
    --       and     pen.effective_end_date
    and    pen.effective_end_date = hr_api.g_eot
    and ((c_effective_date <= prv.rt_end_dt) or (prv.rt_strt_dt = prv.rt_end_dt))
    --RCHASE end
    order by prv.rt_strt_dt desc; -- 5748126 Changed ORDER-BY from ASC to DESC

  -- if the coverage starts in future to the life event occurred date like coverage code 'First of
  -- next month' - 2 life events occurs in the same month
   cursor c_perfprv_2
    (c_effective_date         in date
    ,c_acty_base_rt_id        in number
    ,c_prtt_enrt_rslt_id      in number
    )
  is
    select prv.prtt_rt_val_id,
           prv.rt_ovridn_flag,
           prv.rt_ovridn_thru_dt,
           prv.rt_val,
           prv.ann_rt_val,
	   prv.cmcd_rt_val,                -- Bug 6015724
	   prv.rt_strt_dt,
           prv.rt_end_dt
    from   ben_prtt_rt_val prv,
           ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    prv.prtt_rt_val_stat_cd is null
    and    prv.acty_base_rt_id = c_acty_base_rt_id
    and    c_effective_date <  pen.enrt_cvg_thru_dt
    and    pen.effective_end_date = hr_api.g_eot
    and ((c_effective_date <= prv.rt_end_dt) or (prv.rt_strt_dt = prv.rt_end_dt))
    order by prv.rt_strt_dt desc; -- 5748126 Changed ORDER-BY from ASC to DESC


--End Bug  5031047

  -- Determines the current eligibility for an option
  --
  cursor c_current_elig
    (c_person_id      in number
    ,c_pgm_id         in number
    ,c_pl_id          in number
    ,c_opt_id         in number
    ,c_nvlopt_id      in number
    ,c_effective_date in date
    )
  is
       select epo.prtn_strt_dt
       from   ben_elig_per_f ep,
              ben_elig_per_opt_f epo,
              ben_per_in_ler pil
       where  ep.person_id=c_person_id
       and    nvl(ep.pgm_id,-1)=c_pgm_id
       and    ep.pl_id=c_pl_id
       and    epo.opt_id=c_opt_id
       and    c_effective_date
         between ep.effective_start_date and ep.effective_end_date
       and    ep.elig_per_id=epo.elig_per_id
       and    c_effective_date
         between epo.effective_start_date and epo.effective_end_date
       and    pil.per_in_ler_id(+) = ep.per_in_ler_id
       and    (   pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
               or
                  pil.per_in_ler_stat_cd is null)
       union
       select prtn_strt_dt
       from   ben_elig_per_f ep,
              ben_per_in_ler pil
       where  ep.person_id=c_person_id
       and    nvl(ep.pgm_id,-1)=c_pgm_id
       and    ep.pl_id=c_pl_id
       and    c_effective_date
         between ep.effective_start_date and ep.effective_end_date
       and    pil.per_in_ler_id(+) = ep.per_in_ler_id
       and    (   pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
               or pil.per_in_ler_stat_cd is null)
       and    c_nvlopt_id=hr_api.g_number;

  cursor c_enrt_prem(p_actl_prem_id in number)
  is
    select ecr.val
    from   ben_enrt_prem ecr,
           ben_per_in_ler pil,
           ben_elig_per_elctbl_chc epe
    where  ecr.actl_prem_id = p_actl_prem_id
      and  ecr.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
      and  epe.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id
      and  pil.per_in_ler_id = epe.per_in_ler_id
      --- when the premium depend on coverage , coverage inturn  multi rance
      --- benefit is is required to find the correct row : bug 1628762
      and  (ecr.enrt_bnft_id is null  or nvl(ecr.enrt_bnft_id ,0) = nvl(p_enrt_bnft_id ,0) )
      and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

  Cursor c_state
  is
    select region_2
    from   hr_locations_all loc,per_all_assignments_f asg
    where  loc.location_id = asg.location_id
      and   asg.assignment_type <> 'C'
      and  asg.person_id = p_person_id
      and  asg.primary_flag = 'Y'
      and  p_effective_date between
           asg.effective_start_date and asg.effective_end_date;

  l_state c_state%rowtype;
  --
  Cursor c_pgr (c_pay_rate_grade_rule_id    in number
               ,c_effective_date           in date ) is
  select   value
    from   pay_grade_rules_f  pgr
    where  grade_rule_id = c_pay_rate_grade_rule_id
      and  c_effective_date between
           pgr.effective_start_date and pgr.effective_end_date;
  --
  cursor c_pln_auto_distr (p_elig_per_elctbl_chc_id number)
    is
    select auto_distr_flag
    from ben_enrt_perd enp,
         ben_pil_elctbl_chc_popl pel,
         ben_elig_per_elctbl_chc epe
    where enp.enrt_perd_id = pel.enrt_perd_id
    and   pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
    and   epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --  and   enp.business_group_id = p_business_group_id;
--
-- Bug No 4538786 Added cursor to fetch the rate and element id
-- of the Flex Shell plan instead of the flex credits
--
   cursor get_rt_and_element(c_pgm_id in number,
                             c_per_in_ler_id in number) is
      select  abr.acty_base_rt_id, abr.element_type_id, epe.elig_per_elctbl_chc_id
        from ben_elig_per_elctbl_chc epe, ben_acty_base_rt_f abr
           where (epe.pl_id = abr.pl_id or epe.plip_id = abr.plip_id)
             and  epe.pgm_id = c_pgm_id and epe.per_in_ler_id = c_per_in_ler_id
             and epe.comp_lvl_cd = 'PLANFC';
   l_rt_and_element get_rt_and_element%rowtype;

--
  --6314463
  cursor c_force_prem_calc(p_actl_prem_id number) is
    select 'Y'
    from ben_actl_prem_f
    where actl_prem_id = p_actl_prem_id
    and (mlt_cd in ('CVG', 'NSVU') or
         exists (select null from ben_actl_prem_vrbl_rt_f
                 where actl_prem_id = p_actl_prem_id));
  l_force_prem_calc varchar2(30);

-- End Bug No 4538786

--ICM Changes
 --
 cursor c_abr_level is
   select pl_id,oipl_id
   from   ben_acty_base_rt_f abr
   where  abr.acty_base_rt_id = p_acty_base_rt_id
   and    p_effective_date between abr.effective_start_date
		     and abr.effective_end_date;
 --
 l_abr_level c_abr_level%ROWTYPE;
 --
 cursor c_elem_link(p_element_type_id number) is
   select p.element_link_id
   from   pay_element_links_f p
   where  element_type_id = p_element_type_id
    and   p_effective_date between p.effective_start_date
		     and p.effective_end_date;
 --
l_elem_link pay_element_links_f.element_link_id%TYPE;
 --
l_element_link_id_table  g_element_link_id_table;
 --
l_input_value_id pay_input_values_f.input_value_id%TYPE;
 --
cursor c_pl_typ(p_pl_id number) is
  select opt_typ_cd
  from   ben_pl_typ_f ptp,
         ben_pl_f pln
  where  pln.pl_id = p_pl_id
  and	 ptp.pl_typ_id = pln.pl_typ_id;
 --
l_opt_typ_cd ben_pl_typ_f.opt_typ_cd%TYPE;
 --
cursor c_input_values(p_element_link_id number) is
select p.input_value_id,p.default_value
from pay_link_input_values_f p
   where element_link_id = p_element_link_id
     and p_effective_date between
           effective_start_date and effective_end_date
    order by input_value_id	   ;
--
l_ext_inpval c_input_values%ROWTYPE;
--
l_element_link_id number;
--
cursor c_ext_inpval(p_abr_id in number)
  is
    select eiv.extra_input_value_id,
           eiv.input_value_id,
           eiv.acty_base_rt_id,
           eiv.input_text,
           eiv.return_var_name,
           eiv.upd_when_ele_ended_cd
    from   ben_extra_input_values  eiv
    where  eiv.acty_base_rt_id = p_abr_id;
 --
 l_ext_inpval_rec c_ext_inpval%rowtype;
 --
 l_param_tab               ff_exec.outputs_t;
 l_counter                 number;
  --
l_cnt_inp_vals number;
l_cnt_links number;
-- End Of ICM Changes

  l_effective_date date;
  l_calc_val number;
  l_prnt_entr_val_at_enrt_flag varchar2(30);
  l_cal_val  number;
  l_ann_rt_val number;
  l_cmcd_rt_val number;   -- Bug 6015724
  l_element_type_id   number;
  l_pay_annualization_factor number;
  l_pln_auto_distr_flag      varchar2(1):= 'N';
  --GEVITY
  l_dfnd_dummy number;
  l_ann_dummy  number;
  l_cmcd_dummy number;
  --END GEVITY
  l_cvg_eff_dt date;
  l_fonm_rt_strt_dt date;

  -- Getting mode for bug 3274902
  l_env               ben_env_object.g_global_env_rec_type;
  l_mode 				l_env.mode_cd%TYPE;
  l_prv_rt_strt_dt date; -- 5748126
  l_prv_rt_end_dt date; -- 5748126

function get_input_value_id(p_extra_input_value_id number)
 return number is
 cursor c_input_value_id is
 select input_value_id
 from   ben_extra_input_values
 where  extra_input_value_id = p_extra_input_value_id;
 --
 l_input_value_id number;
 --
 begin
 --
 open c_input_value_id;
  fetch c_input_value_id into l_input_value_id;
 close c_input_value_id;
 --
 return l_input_value_id;
 end;
--
begin
 --
  g_debug := hr_utility.debug_enabled;
  hr_utility.set_location ('Entering '||l_package,10);
  --
  l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date));
  l_cvg_eff_dt := nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date));
  l_fonm_rt_strt_dt := ben_manage_life_events.g_fonm_rt_strt_dt;
  --
  hr_utility.set_location('l_effective_date'||l_effective_date,10);
  hr_utility.set_location('p_acty_base_rt_id'||p_acty_base_rt_id,20);
  hr_utility.set_location('p_person_id '||p_person_id,20);
  hr_utility.set_location('p_effective_date'||p_effective_date,20);
  hr_utility.set_location(' p_elig_per_elctbl_chc_id'||p_elig_per_elctbl_chc_id,20);
  if p_calc_only_rt_val_flag then
       hr_utility.set_location(' p_calc_only_rt_val_flag',10);
  end if ;
  --
  -- Ensure relevant parameters have been populated with values
  --
  if p_acty_base_rt_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PROC','Standard Rates');
    fnd_message.set_token('PARAM','p_acty_base_rt_id');
    fnd_message.raise_error;
  elsif p_person_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PROC','Standard Rates');
    fnd_message.set_token('PARAM','p_person_id');
    fnd_message.raise_error;
  elsif p_effective_date is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PROC','Standard Rates');
    fnd_message.set_token('PARAM','p_effective_date');
    fnd_message.raise_error;
  elsif p_elig_per_elctbl_chc_id is null and not(p_calc_only_rt_val_flag) then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PROC','Standard Rates');
    fnd_message.set_token('PARAM','p_elig_per_elctbl_chc_id');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location ('  Checking Electable Choice ',20);
  --
  -- Populate electable choice information
  --
  l_coverage_value        := p_bnft_amt;
  if p_calc_only_rt_val_flag then
     --
     l_epe.pl_id             := p_pl_id;
     l_epe.pgm_id            := p_pgm_id;
     l_epe.oipl_id           := p_oipl_id;
     l_epe.pl_typ_id         := p_pl_typ_id;
     l_epe.per_in_ler_id     := p_per_in_ler_id;
     l_epe.ler_id            := p_ler_id;
     l_epe.business_group_id := p_business_group_id;
     l_epe.enrt_perd_strt_dt := p_effective_date;
     l_epe.person_id         := p_person_id;
  --
  -- Check if the context row is populated
  --
  elsif p_currepe_row.elig_per_elctbl_chc_id is not null
  then
    --
    l_epe.pgm_id              := p_currepe_row.pgm_id;
    l_epe.pl_typ_id           := p_currepe_row.pl_typ_id;
    l_epe.ptip_id             := p_currepe_row.ptip_id;
    l_epe.pl_id               := p_currepe_row.pl_id;
    l_epe.plip_id             := p_currepe_row.plip_id;
    l_epe.oipl_id             := p_currepe_row.oipl_id;
    l_epe.per_in_ler_id       := p_currepe_row.per_in_ler_id;
    l_epe.ler_id              := p_currepe_row.ler_id;
    l_epe.business_group_id   := p_currepe_row.business_group_id;
    l_epe.enrt_perd_id        := p_currepe_row.enrt_perd_id;
    l_epe.lee_rsn_id          := p_currepe_row.lee_rsn_id;
    l_epe.enrt_perd_strt_dt   := p_currepe_row.enrt_perd_strt_dt;
    l_epe.prtt_enrt_rslt_id   := p_currepe_row.prtt_enrt_rslt_id;
    --
    l_epe.enrt_cvg_strt_dt    := p_currepe_row.enrt_cvg_strt_dt;
    l_epe.enrt_cvg_strt_dt_cd := p_currepe_row.enrt_cvg_strt_dt_cd;
    l_epe.enrt_cvg_strt_dt_rl := p_currepe_row.enrt_cvg_strt_dt_rl;
    l_epe.yr_perd_id          := p_currepe_row.yr_perd_id;
    l_epe.person_id           := p_person_id;
    --
  else
    open c_epe;
    fetch c_epe into l_epe;
    if c_epe%notfound then
      close c_epe;
      fnd_message.set_name('BEN','BEN_92743_NO_ABR_EPE_EXISTS');
      fnd_message.raise_error;
    end if;
    close c_epe;
  end if;
  hr_utility.set_location ('Dn Pop EPE'||l_package,10);
  --
  -- Get related information from either the context record or
  --
  if p_currepe_row.oipl_id is not null
  then
    --
    l_opt.opt_id := p_currepe_row.opt_id;
    --
  elsif l_epe.oipl_id is not null
  then
    --
    open c_opt
      (c_effective_date => l_effective_date
      );
    fetch c_opt into l_opt;
    close c_opt;
    --
  end if;
  --
  open c_abr
    (c_effective_date => l_effective_date
    );
  fetch c_abr into l_abr;
  if c_abr%notfound then
    close c_abr;
    fnd_message.set_name('BEN','BEN_92738_NO_ABR_EXISTS');
    fnd_message.raise_error;
  end if;
  close c_abr;
  --
  if l_abr.acty_typ_cd in ('CWBWB','CWBDB') then
    open c_pln_auto_distr (p_currepe_row.elig_per_elctbl_chc_id);
    fetch c_pln_auto_distr into l_pln_auto_distr_flag;
    close c_pln_auto_distr;
  end if;
  hr_utility.set_location('Roundng'||l_abr.rndg_cd,951);
  --
  -- get values for rules and limit checking
  --
  -- bug fix 3457483
  /* open c_asg
    (c_effective_date => l_effective_date
    );
  fetch c_asg into l_asg;
  close c_asg; */
  ben_element_entry.get_abr_assignment
  (p_person_id       => p_person_id
  ,p_effective_date  => l_effective_date
  ,p_acty_base_rt_id => p_acty_base_rt_id
  ,p_organization_id => l_organization_id
  ,p_payroll_id      => l_payroll_id
  ,p_assignment_id   => l_assignment_id
  );
 --
-- ICM Changes
--   l_element_link_id_table.DELETE;

--
   OPEN c_pl_typ (l_epe.pl_id);

   --
   FETCH c_pl_typ
    INTO l_opt_typ_cd;

   --
   CLOSE c_pl_typ;

   --
   hr_utility.set_location ('l_input_value_id' || l_input_value_id, 33);

   IF l_opt_typ_cd = 'ICM'
   THEN
      --
      OPEN c_abr_level;

      FETCH c_abr_level
       INTO l_abr_level;

      CLOSE c_abr_level;

      --
      IF l_abr_level.pl_id IS NOT NULL
      THEN
         hr_utility.set_location ('PL LEVEL' || l_abr_level.pl_id, 32);
      ELSIF l_abr_level.oipl_id IS NOT NULL
      THEN
         hr_utility.set_location ('OIPL LEVEL' || l_abr_level.oipl_id, 32);
      END IF;

--  To find the eligible element link for the element attached to a Rate
      OPEN c_elem_link (l_abr.element_type_id);

      --
      LOOP
         --
         FETCH c_elem_link
          INTO l_input_value_id;

         EXIT WHEN c_elem_link%NOTFOUND;
         hr_utility.set_location ('l_input_value_id' || l_input_value_id, 32);
         --
         ben_element_entry.get_link
                                 (p_assignment_id          => l_assignment_id,
                                  p_element_type_id        => l_abr.element_type_id,
                                  p_business_group_id      => p_business_group_id,
                                  p_input_value_id         => l_input_value_id,
                                  p_effective_date         => p_effective_date,
                                  p_element_link_id        => l_element_link_id
                                 );

         --
         IF l_element_link_id = l_input_value_id
         THEN
            --
            hr_utility.set_location ('l_element_link_id' || l_element_link_id,
                                     321
                                    );
            l_element_link_id_table (l_element_link_id_table.COUNT + 1) :=
                                                             l_element_link_id;
         --
         END IF;
      --
      END LOOP;

      --
--MAA
      IF l_abr.input_va_calc_rl IS NOT NULL
      THEN
         --
         l_outputs.DELETE;
         hr_utility.set_location (   'l_abr.input_va_calc_rl'
                                  || l_abr.input_va_calc_rl,
                                  13
                                 );
         -- getting the values returned by rule

         BEGIN
            --
            l_outputs :=
               benutils.formula (p_formula_id             => l_abr.input_va_calc_rl,
                                 p_effective_date         => l_effective_date,
                                 p_business_group_id      => p_business_group_id,
                                 p_assignment_id          => l_assignment_id,
                                 p_organization_id        => l_organization_id,
                                 p_pl_id                  => l_epe.pl_id,
                                 p_pl_typ_id              => l_epe.pl_typ_id,
                                 p_acty_base_rt_id        => p_acty_base_rt_id
                                );
            --
            hr_utility.set_location ('l_count' || l_outputs.COUNT, 321);
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               fnd_message.set_name ('BEN', 'BEN_92311_FORMULA_VAL_PARAM');
               fnd_message.set_token ('PROC', l_package);
               fnd_message.set_token ('FORMULA', l_abr.input_va_calc_rl);
               fnd_message.set_token ('PARAMETER',
                                      l_outputs (l_outputs.COUNT).NAME
                                     );
               fnd_message.raise_error;
         END;
      --
      END IF;

      hr_utility.set_location (   'l_element_link_id_table.LAST'
                               || l_element_link_id_table.LAST,
                               23
                              );
      --
      l_counter := 0;
      --
      l_cnt_links := 0;
      l_cnt_inp_vals := 0;
      hr_utility.set_location (l_element_link_id_table.FIRST, 1121);

      -- putting all the default values in an element link to a table that will be used to insert values in ben_icd_chc_rates
      IF l_element_link_id_table.COUNT > 0
      THEN
         --
         FOR i IN
            l_element_link_id_table.FIRST .. l_element_link_id_table.LAST
         --
         LOOP
            hr_utility.set_location (   'l_element_link_id_table (i)'
                                     || l_element_link_id_table (i),
                                     11
                                    );
IF NOT l_icd_chc_rates_tab.EXISTS(1) THEN
      --
      l_cnt_links  := 1;
    --
    ELSE
      --
      l_cnt_links  := l_icd_chc_rates_tab.LAST + 1;
    --
    END IF;
   --
--	    l_cnt_links := 1;
hr_utility.set_location('l_cnt_links'||l_cnt_links,14);
            --
            -- creating row for icd pl sql table
            l_icd_chc_rates_tab (l_cnt_links).element_link_id :=
                                                   l_element_link_id_table (i);

            --
            IF l_abr_level.pl_id IS NULL
            THEN
               hr_utility.set_location ('PLAN', 23);
	       l_icd_chc_rates_tab (l_cnt_links).l_level := 'O';
      --         l_icd_chc_rates_tab (l_cnt_links).pl_id := NULL;
    --           l_icd_chc_rates_tab (l_cnt_links).oipl_id := l_epe.oipl_id;
            ELSIF l_abr_level.oipl_id IS NULL
            THEN
               hr_utility.set_location ('OIPL', 23);
		l_icd_chc_rates_tab (l_cnt_links).l_level := 'P';
--               l_icd_chc_rates_tab (l_cnt_links).pl_id := l_epe.pl_id;
  --             l_icd_chc_rates_tab (l_cnt_links).oipl_id := NULL;
            END IF;
            l_icd_chc_rates_tab (l_cnt_links).pl_id := l_epe.pl_id;
            l_icd_chc_rates_tab (l_cnt_links).oipl_id := l_epe.oipl_id;
            l_icd_chc_rates_tab (l_cnt_links).l_assignment_id :=
                                                               l_assignment_id;
            l_icd_chc_rates_tab (l_cnt_links).pl_typ_id := l_epe.pl_typ_id;
            l_icd_chc_rates_tab (l_cnt_links).opt_id := l_opt.opt_id;
            l_icd_chc_rates_tab (l_cnt_links).pl_ordr_num := l_epe.pl_ordr_num;
            l_icd_chc_rates_tab (l_cnt_links).oipl_ordr_num :=
                                                           l_epe.oipl_ordr_num;
            l_icd_chc_rates_tab (l_cnt_links).pl_ordr_num := l_epe.pl_ordr_num;
            l_icd_chc_rates_tab (l_cnt_links).element_type_id :=
                                                         l_abr.element_type_id;
            l_icd_chc_rates_tab (l_cnt_links).acty_base_rt_id :=
                                                             p_acty_base_rt_id;
            --
            BEGIN
               --
               OPEN c_input_values (l_element_link_id_table (i));

               -- fetching default values defined in element link
               l_cnt_inp_vals := 1;

               --
               LOOP
                  FETCH c_input_values
                   INTO l_ext_inpval;

                  --
                  EXIT WHEN c_input_values%NOTFOUND;
                       -- assigning default values
                  --
                  hr_utility.set_location ('l_cnt_inp_vals' || l_cnt_inp_vals,
                                           21
                                          );

                  IF l_cnt_inp_vals = 1
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id1 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value1 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 2
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id2 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value2 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 3
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id3 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value3 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 4
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id4 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value4 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 5
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id5 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value5 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 6
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id6 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value6 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 7
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id7 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value7 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 8
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id8 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value8 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 9
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id9 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value9 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 10
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id10 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value10 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 11
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id11 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value11 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 12
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id12 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value12 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 13
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id13 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value13 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 14
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id14 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value14 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  ELSIF l_cnt_inp_vals = 15
                  THEN
                     l_icd_chc_rates_tab (l_cnt_links).input_value_id15 :=
                                                  l_ext_inpval.input_value_id;
                     l_icd_chc_rates_tab (l_cnt_links).input_value15 :=
                                                   l_ext_inpval.DEFAULT_VALUE;
                  END IF;

                  --
                  l_cnt_inp_vals := l_cnt_inp_vals + 1;
               --
               END LOOP;

               --
               CLOSE c_input_values;

               --
--               l_cnt_links := l_cnt_links + 1;
            --
            EXCEPTION
               WHEN OTHERS
               THEN
                  hr_utility.set_location (SQLERRM, 23);
            END;
         --
         END LOOP;
      --
      END IF;

      hr_utility.set_location ('Default values assigned ', 5);
      hr_utility.set_location (   l_icd_chc_rates_tab.FIRST
                               || 'f counts'
                               || l_icd_chc_rates_tab.LAST,
                               121
                              );

      --
      --
      IF     l_abr.input_va_calc_rl IS NOT NULL
         AND l_icd_chc_rates_tab.COUNT > 0
         AND l_outputs.COUNT > 0
      THEN
         --
         l_counter := 0;

         --
/*	 IF NOT l_icd_chc_rates_tab.EXISTS(1) THEN
	 --
	     l_cnt_links  := 1;
	 --
	 ELSE
          --
             l_cnt_links  := l_icd_chc_rates_tab.LAST + 1;
          --
         END IF;*/

         -- putting all the values returned by forumula in the table that will be used to insert values in ben_icd_chc_rates
         FOR l_cnt IN l_icd_chc_rates_tab.FIRST .. l_icd_chc_rates_tab.LAST
         -- change default values to formula returned value for every link
         LOOP
            hr_utility.set_location (' in loop ', 121);

            --   FOR l_cnt IN l_icd_chc_rates_tab.FIRST .. l_icd_chc_rates_tab.LAST
            FOR l_count IN l_outputs.FIRST .. l_outputs.LAST
            LOOP
               --
               BEGIN
                  --
                  OPEN c_ext_inpval (p_acty_base_rt_id);

                  LOOP
                     FETCH c_ext_inpval
                      INTO l_ext_inpval_rec;

                     EXIT WHEN c_ext_inpval%NOTFOUND;
                     --
                     hr_utility.set_location
                                            (   ' l_outputs (l_count).NAME '
                                             || l_outputs (l_count).NAME,
                                             121
                                            );
                     hr_utility.set_location
                                     (   ' l_ext_inpval_rec.return_var_name '
                                      || l_ext_inpval_rec.return_var_name,
                                      121
                                     );

                     IF l_outputs (l_count).NAME =
                                              l_ext_inpval_rec.return_var_name
                     THEN
                        --
                        l_counter := l_counter + 1;
                        hr_utility.set_location
                                         ('Before assign extra inputs cache',
                                          11
                                         );
                        --
                        hr_utility.set_location
                                  (   'l_ext_inpval_rec.extra_input_value_id'
                                   || l_ext_inpval_rec.extra_input_value_id,
                                   132
                                  );
                        --
                        hr_utility.set_location('l_cnt_links'||l_cnt_links,1231);
                        l_input_value_id :=
                           get_input_value_id
                                        (l_ext_inpval_rec.extra_input_value_id);

                        --
                    /*    IF l_outputs (l_count).VALUE IS NOT NULL
                        THEN
                           --
                           IF l_icd_chc_rates_tab (l_cnt).input_value_id1 =
                                                             l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value1 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id2 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value2 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id3 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value3 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id4 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value4 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id5 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value5 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id6 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value6 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id7 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value7 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id8 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value8 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id9 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value9 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id10 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value10 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id11 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value11 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id12 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value12 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id13 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value13 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id14 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value14 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id15 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).default_value15 :=
                                                    l_outputs (l_count).VALUE;
                           END IF;*/
                        --

-- my change
 IF l_outputs (l_count).VALUE IS NOT NULL
                        THEN
                           --
                           IF l_icd_chc_rates_tab (l_cnt_links).input_value_id1 =
                                                             l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value1 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id2 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value2 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id3 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value3 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id4 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value4 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id5 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value5 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id6 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value6 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id7 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value7 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id8 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value8 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id9 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value9 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id10 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value10 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id11 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt).input_value11 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt).input_value_id12 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value12 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id13 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value13 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id14 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value14 :=
                                                    l_outputs (l_count).VALUE;
                           ELSIF l_icd_chc_rates_tab (l_cnt_links).input_value_id15 =
                                                              l_input_value_id
                           THEN
                              l_icd_chc_rates_tab (l_cnt_links).input_value15 :=
                                                    l_outputs (l_count).VALUE;
                           END IF;
--my change
                        END IF;
                     --
                     END IF;

                     --
                  END LOOP;

                  --
                  CLOSE c_ext_inpval;
               --
               END;
            END LOOP;
         END LOOP;
      END IF;
   --
   END IF;                                                             -- ICM;


--
-- Enhancement No 3981982 - Min Max Rule
 --
if (l_abr.mn_mx_elcn_rl IS NOT NULL) then
	 l_outputs := benutils.formula(	     p_formula_id           => l_abr.mn_mx_elcn_rl,
    	                                     p_effective_date     => NVL(p_lf_evt_ocrd_dt, l_effective_date),
					     p_assignment_id       => l_assignment_id,
                                             p_organization_id     => l_organization_id,
                                             p_pgm_id                  => l_epe.pgm_id,
                                             p_pl_id                     => l_epe.pl_id,
                                             p_pl_typ_id              => l_epe.pl_typ_id,
                                             p_opt_id                   => l_opt.opt_id,
					     p_jurisdiction_code  => l_jurisdiction_code,
					     p_ler_id                    => l_epe.ler_id,
                                             p_business_group_id => l_epe.business_group_id,
    				             p_param1                   => 'BEN_IV_PERSON_ID',
                                             p_param1_value         => to_char(p_person_id)
                                            );
hr_utility.set_location('l_outputs.count'||l_outputs.count,951);
if (l_outputs.count >= 4) then
    for l_count in l_outputs.first..l_outputs.last loop
               begin
                	if l_outputs(l_count).name = 'L_MN_ELCN_VAL' then
				l_abr.mn_elcn_val := fnd_number.canonical_to_number(l_outputs(l_count).value);
			elsif l_outputs(l_count).name = 'L_MX_ELCN_VAL' then
				l_abr.mx_elcn_val := fnd_number.canonical_to_number(l_outputs(l_count).value);
			elsif l_outputs(l_count).name = 'L_INCRMT_VAL' then
				l_abr.incrmt_elcn_val := fnd_number.canonical_to_number(l_outputs(l_count).value);
			elsif l_outputs(l_count).name = 'L_DFLT_VAL' then
				l_abr.dflt_val := fnd_number.canonical_to_number(l_outputs(l_count).value);
			end if;
		exception
			when others then
			   	fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
				fnd_message.set_token('PROC',l_package);
				fnd_message.set_token('FORMULA',l_abr.mn_mx_elcn_rl);
				fnd_message.set_token('PARAMETER',l_outputs(l_count).name);
			       fnd_message.raise_error;
		end;
	end loop;
	else
		fnd_message.set_name('BEN','BEN_94130_MN_MX_RL_OUT_ERR');
		fnd_message.raise_error;
	end if;
--hr_utility.set_location('mn_elcn_val is '||l_abr.mn_elcn_val,951);
--hr_utility.set_location('mx_elcn_val is '||l_abr.mx_elcn_val,951);
--hr_utility.set_location('incrmt_elcn_val is '||l_abr.incrmt_elcn_val,951);
--hr_utility.set_location('dflt_val is '||l_abr.dflt_val,951);
end if;
--

  -- end bug fix 3457483
/* -- 4031733 - Cursor used to populate l_state.region_2 param for benutils.limit_checks
   -- which is not used down the line
   --
  open c_state;
  fetch c_state into l_state;
  close c_state;
*/
  hr_utility.set_location ('  Checking rate multiplier code ',40);
  if l_abr.rt_mlt_cd is null then
    fnd_message.set_name('BEN','BEN_91834_BASE_RATE_COLUMN_ERR');
    fnd_message.set_token('COLUMN','rt_mlt_cd');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.raise_error;
  end if;
  hr_utility.set_location ('  Checking rate multiplier code others',50);
  if l_abr.rt_mlt_cd in ('FLFX','CL','AP','CVG','PRNT','CLANDCVG',
                         'APANDCVG','PRNTANDCVG') then
    if l_abr.val is null and l_abr.entr_val_at_enrt_flag = 'N' then
      --
      fnd_message.set_name('BEN','BEN_91834_BASE_RATE_COLUMN_ERR');
      fnd_message.set_token('COLUMN','val');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
      fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
      fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
      fnd_message.set_token('PL_ID',to_char(p_pl_id));
      fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location ('  Checking acty base rate values ',60);
  --
  -- cwb now allows null values for min/max/incrmt so no need to validate
  --
  ben_env_object.get(p_rec => l_env);
  if (l_abr.entr_val_at_enrt_flag = 'Y' and l_abr.entr_ann_val_flag = 'N')
    and  nvl(l_env.mode_cd,'~') <> 'W' then

    if l_abr.mn_elcn_val is null then
      hr_utility.set_location ('  BEN_91834_BASE_RATE_COLUMN_ERR ',61);
      fnd_message.set_name('BEN','BEN_91834_BASE_RATE_COLUMN_ERR');
      fnd_message.set_token('COLUMN','mn_elcn_val');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
      fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
      fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
      fnd_message.set_token('PL_ID',to_char(p_pl_id));
      fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
      fnd_message.raise_error;

    elsif l_abr.mx_elcn_val is null then
      hr_utility.set_location ('  BEN_91834_BASE_RATE_COLUMN_ERR ',62);
      fnd_message.set_name('BEN','BEN_91834_BASE_RATE_COLUMN_ERR');
      fnd_message.set_token('COLUMN','mx_elcn_val');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
      fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
      fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
      fnd_message.set_token('PL_ID',to_char(p_pl_id));
      fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
      fnd_message.raise_error;
    elsif l_abr.incrmt_elcn_val is null then
      hr_utility.set_location ('  BEN_91834_BASE_RATE_COLUMN_ERR ',63);
      fnd_message.set_name('BEN','BEN_91834_BASE_RATE_COLUMN_ERR');
      fnd_message.set_token('COLUMN','incrmt_elcn_val');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
      fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
      fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
      fnd_message.set_token('PL_ID',to_char(p_pl_id));
      fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
      fnd_message.raise_error;
    end if;
  end if;

  hr_utility.set_location('  checking if program or plan ',70);
     hr_utility.set_location ('BRRRRRP '||l_package||to_char(l_coverage_value),333);

  if l_epe.pgm_id is not null then
    open c_pgm
      (c_effective_date => l_effective_date
      );
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
    l_enrt_info_rt_freq_cd := l_pgm.enrt_info_rt_freq_cd;
  else
    hr_utility.set_location('  testing if plan ',80);
    hr_utility.set_location(' l_epe.pl_id'||l_epe.pl_id,80);
    open c_pln
      (c_effective_date => l_effective_date,
      c_pl_id => l_epe.pl_id
      );
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
    l_enrt_info_rt_freq_cd := l_pln.nip_enrt_info_rt_freq_cd;
  end if;
--
-- Bug No 4538786
--
/*  hr_utility.set_location('PPF changes: input epe id'||p_elig_per_elctbl_chc_id,99);
   hr_utility.set_location('PPF changes: element type id before changes'||l_abr.element_type_id,99); */
   if l_abr.rt_usg_cd = 'FLXCR' and l_enrt_info_rt_freq_cd = 'PPF' then
--      hr_utility.set_location('PPF changes: fetching the element type id...',99);
      open get_rt_and_element(l_epe.pgm_id, l_epe.per_in_ler_id);
      fetch get_rt_and_element into l_rt_and_element;
      if get_rt_and_element%FOUND then
	 l_abr.element_type_id := l_rt_and_element.element_type_id;
      end if;
      Close get_rt_and_element; -- Close added during bug fix 4604560
   end if;
--   hr_utility.set_location('PPF changes: afterwards element type id'||l_abr.element_type_id,99);
--
-- End Bug No 4538786
--
  -- get the dflt_enrt_cd/rule
  --
  hr_utility.set_location ('BER_DDEC '||l_package,10);
  ben_env_object.get(p_rec => l_env);
  hr_utility.set_location('l_env.mode_cd' || l_env.mode_cd,13);
  if nvl(l_env.mode_cd,'~') <> 'D' then --cant set this code in 'D' Plans -- ICM
  --
  ben_enrolment_requirements.determine_dflt_enrt_cd
    (p_oipl_id           =>l_epe.oipl_id
    ,p_plip_id           =>l_epe.plip_id
    ,p_pl_id             =>l_epe.pl_id
    ,p_ptip_id           =>l_epe.ptip_id
    ,p_pgm_id            =>l_epe.pgm_id
    ,p_ler_id            =>l_epe.ler_id
    ,p_dflt_enrt_cd      =>l_dflt_enrt_cd
    ,p_dflt_enrt_rl      =>l_dflt_enrt_rl
    ,p_business_group_id =>l_epe.business_group_id
    ,p_effective_date    =>l_cvg_eff_dt
    );
     hr_utility.set_location ('BRRRRRP '||l_package||to_char(l_coverage_value),299);
 --
 end if;
  if l_abr.rt_mlt_cd in ('CVG','CLANDCVG','APANDCVG','PRNTANDCVG','SAREC') then
    --
    --Bug 2192102 if the rate is of Flex credit letus get the associated enrt bnft id
    if l_abr.rt_usg_cd = 'FLXCR' then
      --
      hr_utility.set_location (' Before FLXCR  l_enrt_bnft_id '||l_enrt_bnft_id, 19);
      --
      open c_enb_fc ;
        fetch c_enb_fc into l_enrt_bnft_id  ;
      close c_enb_fc;
      --
      hr_utility.set_location (' After FLXCR  l_enrt_bnft_id '||l_enrt_bnft_id, 19);
    end if;
    --
    if l_coverage_value is null then
       if l_enrt_bnft_id is null then
         fnd_message.set_name('BEN','BEN_92748_ABR_ENBID_NULL');
         fnd_message.set_token('PACKAGE',l_package);
         fnd_message.set_token('PARAM','p_enrt_bnft_id');
         fnd_message.raise_error;
       end if;
       open c_enb(l_enrt_bnft_id);
         fetch c_enb  into l_val, l_dflt_val;
         if c_enb%notfound then
           close c_enb;
           fnd_message.set_name('BEN','BEN_92739_NO_ABR_ENB_EXISTS');
           fnd_message.raise_error;
         end if;
       close c_enb;
       --
       l_coverage_value := nvl(l_val, l_dflt_val);
       --
    end if;
    if l_epe.oipl_id is not NULL then
       open c_cvg_oipl
         (c_effective_date => l_effective_date
         );
       fetch c_cvg_oipl into l_cvg_calc_amt_mthd_id;
       if c_cvg_oipl%notfound then
         close c_cvg_oipl;
         fnd_message.set_name('BEN','BEN_92740_NO_OIPL_CCM_ATTACH');
         fnd_message.raise_error;
       end if;
       close c_cvg_oipl;
    elsif l_epe.pl_id is not NULL then
       open c_cvg_pl
         (c_effective_date => l_effective_date
         );
       fetch c_cvg_pl into l_cvg_calc_amt_mthd_id;
       if c_cvg_pl%notfound then
         close c_cvg_pl;
         fnd_message.set_name('BEN','BEN_92741_NO_PLN_CCM_ATTACH');
         fnd_message.raise_error;
       end if;
       close c_cvg_pl;
    else
       fnd_message.set_name('BEN','BEN_92744_ABR_ENB_NULL');
       fnd_message.raise_error;
    end if;
    p_cvg_calc_amt_mthd_id := l_cvg_calc_amt_mthd_id;
  end if;
  hr_utility.set_location ('ABR_RTMLTCD CL'||l_package,10);
  if l_abr.rt_mlt_cd in ('CL','CLANDCVG') then
    if l_abr.comp_lvl_fctr_id is null then
      fnd_message.set_name('BEN','BEN_92745_NO_ABR_CLF_EXISTS');
      fnd_message.raise_error;
    end if;
    p_comp_lvl_fctr_id := l_abr.comp_lvl_fctr_id;
    ben_derive_factors.determine_compensation
     (p_comp_lvl_fctr_id     => l_abr.comp_lvl_fctr_id,
      p_person_id            => p_person_id,
      p_pgm_id               => l_epe.pgm_id,
      p_pl_id                => l_epe.pl_id,
      p_oipl_id              => l_epe.oipl_id,
      p_per_in_ler_id        => l_epe.per_in_ler_id,
      p_business_group_id    => l_epe.business_group_id,
      p_perform_rounding_flg => true,
      p_effective_date       => p_effective_date,
      p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
      p_cal_for              => 'R',
      p_value                => l_compensation_value,
      p_fonm_cvg_strt_dt  => l_cvg_eff_dt,
      p_fonm_rt_strt_dt   => l_fonm_rt_strt_dt  );


    if l_compensation_value is null then
      fnd_message.set_name('BEN','BEN_92746_ABR_COMP_NULL');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('VARIABLE','l_compensation_value');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location ('ABR_RTMLTCD AP '||l_package,10);
  if l_abr.rt_mlt_cd in ('AP','APANDCVG') then
    p_actl_prem_id := l_abr.actl_prem_id;
    open c_enrt_prem(l_abr.actl_prem_id);
      fetch c_enrt_prem into l_actl_prem_value;
    close c_enrt_prem;
    hr_utility.set_location ('  Dn c_enrt_prem ',120);
    --6314463
    l_force_prem_calc := 'N';
    open c_force_prem_calc(p_actl_prem_id);
    fetch c_force_prem_calc into l_force_prem_calc;
    close c_force_prem_calc;
    --- if premium is null it will calcualte again 2797031
    -- 5557305 : Recalculate 'Actual Premium' irrespective of current value
    -- as value might have changed, Hence commented the below condition
 if nvl(l_env.mode_cd,'~') <> 'D' then
  --
    if /*nvl(l_actl_prem_value,0)  = 0 and  */ p_calc_only_rt_val_flag
      or (l_force_prem_calc = 'Y' and p_called_from_ss) then
        hr_utility.set_location('premium re calculation ',551);
        ben_determine_actual_premium.g_computed_prem_val := null ;
        ben_determine_actual_premium.main
          (p_person_id         => p_person_id,
           p_effective_date    => l_cvg_eff_dt,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_calc_only_rt_val_flag => true , --6314463 As we have already decided to calculate premium for the rate
                                             --let's not allow this flag to impact the premium computation
           p_pgm_id                => l_epe.pgm_id,
           p_pl_id                 => l_epe.pl_id,
           p_pl_typ_id             => l_epe.pl_typ_id,
           p_oipl_id               => l_epe.oipl_id,
           p_per_in_ler_id         => l_epe.per_in_ler_id,
           p_ler_id                => l_epe.ler_id,
           p_bnft_amt              => l_coverage_value,
           p_business_group_id     => l_epe.business_group_id );

           hr_utility.set_location('premium re calculation over ',551);
           hr_utility.set_location('Required actl_prem_id ' || l_abr.actl_prem_id,551);
           --
            -- 6330056 : Match the actl_prem_id for the evaluated
            -- premiums to get the correct required value.
            --
            if (ben_determine_actual_premium.g_computed_prem_tbl.COUNT > 0) then
                --
                for idx IN ben_determine_actual_premium.g_computed_prem_tbl.FIRST..
                                ben_determine_actual_premium.g_computed_prem_tbl.LAST loop
                    --
                    hr_utility.set_location('Calculated actl_prem_id ' ||
                      ben_determine_actual_premium.g_computed_prem_tbl(idx).actl_prem_id,551);
                    if (ben_determine_actual_premium.g_computed_prem_tbl(idx).actl_prem_id
                            = l_abr.actl_prem_id) then
                        --
                        l_actl_prem_value :=
                           ben_determine_actual_premium.g_computed_prem_tbl(idx).val;
                        --
                    end if;
                    --
                end loop;
                --
            end if;
           --
           hr_utility.set_location('l_actl_prem_value ' || l_actl_prem_value,100);
           --l_actl_prem_value := ben_determine_actual_premium.g_computed_prem_val;
           hr_utility.set_location('re calculation premium'||l_actl_prem_value,551);
           ben_determine_actual_premium.g_computed_prem_val := null;
           --
    end if;

    if l_actl_prem_value is null then
      fnd_message.set_name('BEN','BEN_92747_ABR_APR_NULL');
      hr_utility.set_location ('  FNDMS_RE 1 ',130);
      fnd_message.raise_error;
    end if;
    hr_utility.set_location ('  Convert prem rate (monthly) to acty_ref_perd',140);
    hr_utility.set_location ('  l_acty_ref_perd_cd -> '||l_acty_ref_perd_cd,140);
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
    end if; --'D'
  end if;
  hr_utility.set_location ('ABR_RTMLTCD PRNT '||l_package,10);
  if l_abr.rt_mlt_cd in ('PRNT','PRNTANDCVG') then
    open c_abr2
      (c_effective_date => l_effective_date
      );
    fetch c_abr2 into l_acty_base_rt_id ,l_prnt_entr_val_at_enrt_flag;
    if c_abr2%notfound then
      close c_abr2;
      fnd_message.set_name('BEN','BEN_92742_NO_PRNT_ABR_EXISTS');
      fnd_message.raise_error;
    end if;
    close c_abr2;
/*
    --
    -- MH - removed this could never occur because BEN_92742_NO_PRNT_ABR_EXISTS
    --      would be raised
    --
    if l_acty_base_rt_id is null then
      fnd_message.set_name('BEN','BEN_91835_VARIABLE_VALUE_NULL');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('VARIABLE','l_acty_base_rt_id');
      fnd_message.raise_error;
    end if;
*/
    hr_utility.set_location ('St BDABR_MN Sub '||l_package,10);
    if l_prnt_entr_val_at_enrt_flag = 'Y' then
       l_cal_val := null;
    else
       l_cal_val := p_cal_val;
    end if;
    if p_parent_val is not null then
       l_prnt_rt_value := p_parent_val ;
    else
       ben_determine_activity_base_rt.main
         (p_person_id                   => p_person_id
         ,p_per_row                     => p_per_row
         ,p_asg_row                     => p_asg_row
         ,p_ast_row                     => p_ast_row
         ,p_adr_row                     => p_adr_row
         ,p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id
         ,p_enrt_bnft_id                => l_enrt_bnft_id
         ,p_acty_base_rt_id             => l_acty_base_rt_id
         ,p_effective_date              => p_effective_date
         ,p_lf_evt_ocrd_dt              => p_lf_evt_ocrd_dt
         ,p_perform_rounding_flg        => true
         ,p_calc_only_rt_val_flag       => p_calc_only_rt_val_flag
         ,p_pl_id                       => l_epe.pl_id
         ,p_pgm_id                      => l_epe.pgm_id
         ,p_oipl_id                     => l_epe.oipl_id
         ,p_pl_typ_id                   => l_epe.pl_typ_id
         ,p_per_in_ler_id               => l_epe.per_in_ler_id
         ,p_ler_id                      => l_epe.ler_id
         ,p_bnft_amt                    => l_coverage_value
         ,p_business_group_id           => l_epe.business_group_id
         ,p_cal_val                     => l_cal_val/* to handle net credit method for flex credit */
         ,p_val                         => l_prnt_rt_value
         ,p_mn_elcn_val                 => l_dummy_num
         ,p_mx_elcn_val                 => l_dummy_num
         ,p_ann_val                     => l_dummy_num
         ,p_ann_mn_elcn_val             => l_dummy_num
         ,p_ann_mx_elcn_val             => l_dummy_num
         ,p_dsply_mn_elcn_val           => l_dummy_num
         ,p_dsply_mx_elcn_val           => l_dummy_num
         ,p_cmcd_val                    => l_dummy_num
         ,p_cmcd_mn_elcn_val            => l_dummy_num
         ,p_cmcd_mx_elcn_val            => l_dummy_num
         ,p_cmcd_acty_ref_perd_cd       => l_dummy_char
         ,p_incrmt_elcn_val             => l_dummy_num
         ,p_dflt_val                    => l_dummy_num
         ,p_tx_typ_cd                   => l_dummy_char
         ,p_acty_typ_cd                 => l_dummy_char
         ,p_nnmntry_uom                 => l_dummy_char
         ,p_entr_val_at_enrt_flag       => l_dummy_char
         ,p_dsply_on_enrt_flag          => l_dummy_char
         ,p_use_to_calc_net_flx_cr_flag => l_dummy_char
         ,p_rt_usg_cd                   => l_dummy_char
         ,p_bnft_prvdr_pool_id          => l_dummy_num
         ,p_actl_prem_id                => l_dummy_num
         ,p_cvg_calc_amt_mthd_id        => l_dummy_num
         ,p_bnft_rt_typ_cd              => l_dummy_char
         ,p_rt_typ_cd                   => l_dummy_char
         ,p_rt_mlt_cd                   => l_dummy_char
         ,p_comp_lvl_fctr_id            => l_dummy_num
         ,p_entr_ann_val_flag           => l_dummy_char
         ,p_ptd_comp_lvl_fctr_id        => l_dummy_num
         ,p_clm_comp_lvl_fctr_id        => l_dummy_num
         ,p_ann_dflt_val                => l_dummy_num
         ,p_rt_strt_dt                  => l_dummy_date
         ,p_rt_strt_dt_cd               => l_dummy_char
         ,p_rt_strt_dt_rl               => l_dummy_num
         ,p_prtt_rt_val_id              => l_dummy_num
         ,p_pp_in_yr_used_num           => l_dummy_num
         ,p_ordr_num                    => l_dummy_num
         ,p_iss_val                     => l_dummy_num
         );
    end if ;
    hr_utility.set_location ('Dn BDABR_MN Sub '||l_package,10);
    --bug :1555624 when the parent defiend as enter at enrollment  then vlue
    -- may be returend as null or 0 this will be calcualtead in post enrollement
    -- process
    if l_prnt_rt_value is null
      and nvl(l_prnt_entr_val_at_enrt_flag,'N') <> 'Y'
    then
      fnd_message.set_name('BEN','BEN_91835_VARIABLE_VALUE_NULL');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('VARIABLE','l_prnt_rt_value');
      fnd_message.raise_error;
    end if;
    --
  end if;

  p_entr_val_at_enrt_flag := l_abr.entr_val_at_enrt_flag;

  hr_utility.set_location('  l_abr.rt_mlt_cd:'||l_abr.rt_mlt_cd,170);
  hr_utility.set_location('  cal val :'|| p_cal_val,170);
  --- bug 1480407
  -- when entr_val_at_enrt_flag and use_calc_acty_bs_rt_flag is true this calculation will be called
  -- after enrolement with the entered rate so the calulatiuon is to be done for incomming value
  --- also validate the min max with the ammount entered , thi validation will be skipped in Rhi for
  --- calcualted amonut
  IF l_abr.entr_val_at_enrt_flag = 'Y' and l_abr.use_calc_acty_bs_rt_flag = 'Y' and
     p_cal_val is not null then
     --
     open c_enrt_rt(p_elig_per_elctbl_chc_id,p_enrt_bnft_id, p_acty_base_rt_id);
     fetch c_enrt_rt into l_enrt_rt;
     close c_enrt_rt;
     --

     if ((nvl(l_enrt_rt.mn_elcn_val,l_abr.mn_elcn_val) is not NULL
            and p_cal_val < nvl(l_enrt_rt.mn_elcn_val,l_abr.mn_elcn_val))
          or (nvl(l_enrt_rt.mx_elcn_val,l_abr.mx_elcn_val)  is not NULL
                and p_cal_val > nvl(l_enrt_rt.mx_elcn_val,l_abr.mx_elcn_val))) then

        open  c_pl_opt_name;
        fetch c_pl_opt_name into l_pl_opt_name;
        close c_pl_opt_name;

        fnd_message.set_name('BEN','BEN_91939_NOT_IN_RANGE');
        fnd_message.set_token('MIN',nvl(l_enrt_rt.mn_elcn_val,l_abr.mn_elcn_val));
        fnd_message.set_token('MAX',nvl(l_enrt_rt.mx_elcn_val,l_abr.mx_elcn_val));
        fnd_message.set_token('PLOPT',l_pl_opt_name);
        fnd_message.raise_error;

     elsif (mod(p_cal_val,nvl(l_enrt_rt.incrmt_elcn_val,l_abr.incrmt_elcn_val))
                           <>0) then
        --
        -- raise error is not multiple of increment
        --

        -- bug # 1699585 passing the plan name in the error message
       open  c_pl_opt_name;
               fetch c_pl_opt_name into l_pl_opt_name;
        close c_pl_opt_name;
    -- end # 1699585

        fnd_message.set_name('BEN','BEN_91932_NOT_INCREMENT');
        fnd_message.set_token('INCREMENT', nvl(l_enrt_rt.incrmt_elcn_val,l_abr.incrmt_elcn_val));
        fnd_message.set_token('PLAN', l_pl_opt_name);
        fnd_message.raise_error;

      End if;


     l_abr.val :=  p_cal_val;
     hr_utility.set_location(' incomming value ' || l_abr.val , 407);
  end if ;

  /* Bug 6015724 */
  l_prv_rt_strt_dt := null; -- 5748126
  l_prv_rt_end_dt := null;
  --
  -- Modified for performance.
  --
  -- When the passed in EPE prtt_enrt_rslt_id is set then do not perform
  -- SQL. Nullify PRV values
  --
  if p_currepe_row.elig_per_elctbl_chc_id is not null
    and p_currepe_row.prtt_enrt_rslt_id is null
  then
    --
    l_prtt_rt_val_id    := null;
    l_rt_ovridn_flag    := null;
    l_rt_ovridn_thru_dt := null;
    l_rt_val            := null;
  --
  -- When the EPE prtt_enrt_rslt_id is set then perform performance PRV cursor
  --
  elsif l_epe.prtt_enrt_rslt_id is not null
  then
    --
    open c_perfprv
      (c_effective_date    => l_effective_date
      ,c_acty_base_rt_id   => p_acty_base_rt_id
      ,c_prtt_enrt_rslt_id => l_epe.prtt_enrt_rslt_id
      );
    loop -- 5748126: Added LOOP to fetch the Latest PRV which occurs before eff_dt
        fetch c_perfprv into l_prtt_rt_val_id,
                     l_rt_ovridn_flag,
                     l_rt_ovridn_thru_dt,
                     l_rt_val,
                     l_ann_rt_val,
		     l_cmcd_rt_val,
                     l_prv_rt_strt_dt,
                     l_prv_rt_end_dt;
                     --
        if (g_debug) then
            hr_utility.set_location(' l_prtt_rt_val_id: '|| l_prtt_rt_val_id
                           ||':'|| l_prv_rt_strt_dt ||':'|| l_prv_rt_end_dt, 10);
        end if;
        --
        exit when (c_perfprv%notfound or l_prv_rt_strt_dt <= l_effective_date); -- 5898039: Changed from < to <=
    end loop;
    if l_prv_rt_strt_dt is null then
       --
        open c_perfprv_2
          (c_effective_date    => l_effective_date
          ,c_acty_base_rt_id   => p_acty_base_rt_id
          ,c_prtt_enrt_rslt_id => l_epe.prtt_enrt_rslt_id
          );
        loop -- 5748126: Added LOOP to fetch the Latest PRV which occurs before eff_dt
            fetch c_perfprv_2 into l_prtt_rt_val_id,
                     l_rt_ovridn_flag,
                     l_rt_ovridn_thru_dt,
                     l_rt_val,
                     l_ann_rt_val,
		     l_cmcd_rt_val,
                     l_prv_rt_strt_dt,
                     l_prv_rt_end_dt;
                     --
        if (g_debug) then
            hr_utility.set_location(' l_prtt_rt_val_id: '|| l_prtt_rt_val_id
                           ||':'|| l_prv_rt_strt_dt ||':'|| l_prv_rt_end_dt, 10);
        end if;
        --
        exit when (c_perfprv_2%notfound or l_prv_rt_strt_dt <= l_effective_date); -- 5898039: Changed from < to <=
        end loop;
       close c_perfprv_2;

       --
    end if;

    close c_perfprv;
    --
  --
  -- This was left here to support for calls from outside of benmngle
  --
  else
    --
    open c_prv
      (c_effective_date         => l_effective_date
      ,c_acty_base_rt_id        => p_acty_base_rt_id
      ,c_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
      );
    loop -- 5748126: Added LOOP to fetch the Latest PRV which occurs before eff_dt
        fetch c_prv into l_prtt_rt_val_id,
                     l_rt_ovridn_flag,
                     l_rt_ovridn_thru_dt,
                     l_rt_val,
                     l_ann_rt_val,
		     l_cmcd_rt_val,
                     l_prv_rt_strt_dt,
                     l_prv_rt_end_dt;
                     --
        if (g_debug) then
            hr_utility.set_location(' l_prtt_rt_val_id: '|| l_prtt_rt_val_id
                           ||':'|| l_prv_rt_strt_dt ||':'|| l_prv_rt_end_dt, 10);
        end if;
        --
        exit when c_prv%notfound or l_prv_rt_strt_dt <= l_effective_date; -- 5898039: Changed from < to <=
    end loop;
    close c_prv;
    --
  end if;
  hr_utility.set_location ('Cl c_prv '||l_package,10);

  p_prtt_rt_val_id := l_prtt_rt_val_id;
  /* End Bug 6015724 */
  --
  --  Flat Amount
  --
  if l_abr.rt_mlt_cd = 'FLFX' or l_abr.use_calc_acty_bs_rt_flag = 'N' then
    if p_cal_val is not null then
      l_val := p_cal_val;
    else
      l_val  := l_abr.val;
    end if;
    --
  elsif l_abr.rt_mlt_cd = 'CL' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.rt_typ_cd
           ,p_val            => l_abr.val
           ,p_val_2          => l_compensation_value
           ,p_calculated_val => l_val);

  elsif l_abr.rt_mlt_cd = 'CVG' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.bnft_rt_typ_cd
           ,p_val            => l_abr.val
           ,p_val_2          => l_coverage_value
           ,p_calculated_val => l_val);
          /* : 1791203:  added                   */
         /*
          if  nvl(l_abr.det_pl_ytd_cntrs_cd,'X') = 'ESTONLY' then
              l_val := ben_distribute_rates.estonly_pp_to_period
                                            (p_business_group_id,
                                             p_person_id,
                                             p_effective_date ,
                                             p_acty_base_rt_id,
                                             p_elig_per_elctbl_chc_id,
                                             l_abr.element_type_id,
                                             l_payroll_id,
                                             l_val
                                             );
          end if;
         */


  elsif l_abr.rt_mlt_cd = 'AP' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.rt_typ_cd
           ,p_val            => l_abr.val
           ,p_val_2          => l_actl_prem_value
           ,p_calculated_val => l_val);

  elsif l_abr.rt_mlt_cd = 'PRNT' then

     hr_utility.set_location(' abr  value ' || l_abr.val , 407);
     hr_utility.set_location(' parent ' || l_prnt_rt_value , 407);
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.rt_typ_cd
           ,p_val            => l_abr.val
           ,p_val_2          => l_prnt_rt_value
           ,p_calculated_val => l_val);
       if l_val is null then
         l_val := 0;
       end if;
       hr_utility.set_location(' result ' || l_val , 407);
  elsif l_abr.rt_mlt_cd = 'CLANDCVG' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.rt_typ_cd
           ,p_val            => l_abr.val
           ,p_val_2          => l_compensation_value
           ,p_calculated_val => l_value);

    --
    -- now take l_value and apply it against the coverage
    --
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.bnft_rt_typ_cd
           ,p_val            => l_value
           ,p_val_2          => l_coverage_value
           ,p_calculated_val => l_val);

  elsif l_abr.rt_mlt_cd = 'APANDCVG' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.rt_typ_cd
           ,p_val            => l_abr.val
           ,p_val_2          => l_actl_prem_value
           ,p_calculated_val => l_value);

    --
    -- now take l_value and apply it against the coverage
    --
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.bnft_rt_typ_cd
           ,p_val            => l_value
           ,p_val_2          => l_coverage_value
           ,p_calculated_val => l_val);

  elsif l_abr.rt_mlt_cd = 'PRNTANDCVG' then
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.rt_typ_cd
           ,p_val            => l_abr.val
           ,p_val_2          => l_prnt_rt_value
           ,p_calculated_val => l_value);

    --
    -- now take l_value and apply it against the coverage
    --
       benutils.rt_typ_calc
           (p_rt_typ_cd      => l_abr.bnft_rt_typ_cd
           ,p_val            => l_value
           ,p_val_2          => l_coverage_value
           ,p_calculated_val => l_val);

  elsif l_abr.rt_mlt_cd in ('RL','ERL') then -- added ERL for canon fix
    --
    -- Call formula initialise routine
    --
    if l_assignment_id is not null then

      --if l_asg.region_2 is not null then
      -- l_jurisdiction_code :=
      --      pay_mag_utils.lookup_jurisdiction_code
      --       (p_state => l_asg.region_2);

      --end if;

      l_outputs := benutils.formula
        (p_formula_id        => l_abr.val_calc_rl,
         p_effective_date    => nvl(p_lf_evt_ocrd_dt,l_effective_date),
         p_assignment_id     => l_assignment_id,
         p_acty_base_rt_id   => p_acty_base_rt_id,
         p_organization_id   => l_organization_id,
         p_business_group_id => l_epe.business_group_id,
         p_pgm_id            => l_epe.pgm_id,
         p_pl_id             => l_epe.pl_id,
         p_pl_typ_id         => l_epe.pl_typ_id,
         p_opt_id            => l_opt.opt_id,
         p_ler_id            => l_epe.ler_id,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_jurisdiction_code => l_jurisdiction_code,
         p_param1             => 'RT_STRT_DT',
         p_param1_value       => fnd_date.date_to_canonical(l_fonm_rt_strt_dt),
         p_param2             => 'CVG_STRT_DT',
         p_param2_value       => fnd_date.date_to_canonical(l_cvg_eff_dt)
);
      l_val := fnd_number.canonical_to_number(l_outputs(l_outputs.first).value); --bug4235088
    else
      l_val := 0;
    end if;

  elsif l_abr.rt_mlt_cd = 'SAREC' then
    hr_utility.set_location ('BDR_ATP '||l_package||to_char(l_coverage_value),299);
    --ikasire -- not passing the p_complete_year_flag per bug 1650517
    /* Bug 6015724 */
     if l_rt_ovridn_flag = 'Y' and nvl(l_rt_ovridn_thru_dt, hr_api.g_eot) >= l_effective_date then
      --
       p_ann_val:= l_ann_rt_val;  -- ikasire
       p_val := l_rt_val;
       p_cmcd_val := l_cmcd_rt_val;
     --
     else
    p_ann_val := l_coverage_value;
    --
    --
    --GEVITY
    --
    IF l_abr.rate_periodization_rl IS NOT NULL THEN
      --
      ben_distribute_rates.periodize_with_rule
            (p_formula_id             => l_abr.rate_periodization_rl -- in number,
            ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date) --in date,
            ,p_assignment_id          => l_assignment_id            --in number,
            ,p_convert_from_val       => l_coverage_value           -- in number,
            ,p_convert_from           => 'ANNUAL'                  -- in varchar2,
            ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id   -- in number,
            ,p_acty_base_rt_id        => p_acty_base_rt_id          -- in number,
            ,p_business_group_id      => l_epe.business_group_id    -- in number,
            ,p_enrt_rt_id             => NULL                       -- in number default null,
            ,p_ann_val                => p_ann_val                  -- out nocopy number,
            ,p_cmcd_val               => p_cmcd_val                 -- out nocopy number,
            ,p_val                    => l_val                      -- out nocopy number
      );
      --
    ELSE
      if l_enrt_info_rt_freq_cd = 'PPF' then
         l_element_type_id := l_abr.element_type_id;
      else
         l_element_type_id := null;
      end if;
      --
      l_val := ben_distribute_rates.annual_to_period
                  (p_amount                  => p_ann_val,
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   --1791203
                   p_payroll_id              => l_payroll_id,
                   p_element_type_id         => l_element_type_id,
                   p_rounding_flag           => 'N' );  --Bug 2149438
       --
       --Bug 2149438
       l_val := round(l_val,4);
       --
       hr_utility.set_location ('BDR_ATP '||l_package,291);
/**************************************/
       /* --Bug 2149438
       l_calc_val := ben_distribute_rates.period_to_annual
                  (p_amount                  => l_val,
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id);
       */
       l_calc_val := p_ann_val ;
       --

       if l_enrt_info_rt_freq_cd = 'PPF' then
          l_element_type_id := l_abr.element_type_id;
       else
          l_element_type_id := null;
       end if;
       --
       p_cmcd_val := ben_distribute_rates.annual_to_period_out
                  (p_amount                  => l_calc_val,
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_enrt_info_rt_freq_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
             --    p_complete_year_flag      => 'Y',
                  /* Start of Changes for WWBUG: 1791203                 */
                   p_payroll_id              => l_payroll_id,
                   p_element_type_id         => l_element_type_id,
                   p_pp_in_yr_used_num       => p_pp_in_yr_used_num);
     END IF; --GEVITY
     --
     end if;    -- end if for if l_rt_ovridn_flag = 'Y'
     /* End Bug 6015724 */
     --
     p_cmcd_acty_ref_perd_cd  := l_enrt_info_rt_freq_cd;
     hr_utility.set_location ('BDR_ATP '||to_char(p_ann_val),222);
     hr_utility.set_location ('BDR_ATP '||to_char(l_cmcd_val),223);
     hr_utility.set_location ('BDR_ATP '||to_char(l_val),224);
  elsif l_abr.rt_mlt_cd = 'NSVU' then
    null;  -- do nothing if 'no standard value used'
  elsif l_abr.rt_mlt_cd  = 'PRV' then
        --- for grade step progression
        hr_utility.set_location('GSP  mulsti code PRV  ',551) ;
        open c_pgr (l_abr.pay_rate_grade_rule_id , l_effective_date ) ;
        fetch c_pgr into l_val ;
        close c_pgr ;
        hr_utility.set_location('GSP value  '|| l_val ,551) ;

  else
    fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
    fnd_message.set_token('PROC',l_package);
    fnd_message.set_token('CODE1',l_abr.rt_mlt_cd);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location ('Dn ABR_RTMLTCDS '||l_package,10);
  --
  -- set some of the outputs
  --
  hr_utility.set_location('  set outputs ',180);
  p_tx_typ_cd := l_abr.tx_typ_cd;
  p_acty_typ_cd := l_abr.acty_typ_cd;
  p_nnmntry_uom := l_abr.nnmntry_uom;
  p_dsply_on_enrt_flag := l_abr.dsply_on_enrt_flag;
  p_use_to_calc_net_flx_cr_flag := l_abr.use_to_calc_net_flx_cr_flag;
  p_rt_usg_cd := l_abr.rt_usg_cd;
  p_mx_elcn_val  :=  l_abr.mx_elcn_val;
  p_mn_elcn_val  := l_abr.mn_elcn_val;
  p_incrmt_elcn_val := l_abr.incrmt_elcn_val;
  p_ordr_num        := l_abr.ordr_num;

  hr_utility.set_location('p_ordr_num ='||p_ordr_num,181);

  -- get default value from the right place depending on dflt code
/*
  if l_dflt_enrt_cd in ('NSDCS','NNCS') then
     p_dflt_val := l_rt_val;
     l_abr.dflt_val:=l_rt_val;
  else
     p_dflt_val := l_abr.dflt_val;
  end if;
*/
  -- Bug 1834655
  -- Bug 2400850 : Checking prtt_enrt_rslt_id before assigning
  --               values to p_dflt_val
  if l_dflt_enrt_cd in ('NSDCS','NNCS')
     and p_currepe_row.prtt_enrt_rslt_id is not null
     -- Bug 2677804 if there was a overriden rate and you are processing the
     -- enrollment after the overrident thru date dont default from the
     -- previous enorllment. Instead get it from the abr.
     and l_effective_date <= nvl( l_rt_ovridn_thru_dt,l_effective_date + 1 ) then
     --
       p_dflt_val := l_rt_val;
       l_abr.dflt_val:=l_rt_val;
       p_ann_dflt_val:= l_ann_rt_val;  -- ikasire
     --
  end if;
  --
  open c_abp
    (c_effective_date => l_effective_date
    );
  fetch c_abp into l_bnft_prvdr_pool_id;
  close c_abp;

  p_bnft_prvdr_pool_id := l_bnft_prvdr_pool_id;


  --bug : 1433393 Value us validated befoe calcualting the
  --variable rate riable rate with value us validated agains the ulitmate values of
  -- VAPRO
  hr_utility.set_location ('Lim Chk '||l_package,10);
  benutils.limit_checks
           (p_upr_lmt_val       => l_abr.upr_lmt_val,
            p_lwr_lmt_val       => l_abr.lwr_lmt_val,
            p_upr_lmt_calc_rl   => l_abr.upr_lmt_calc_rl,
            p_lwr_lmt_calc_rl   => l_abr.lwr_lmt_calc_rl,
            p_effective_date    => nvl(p_lf_evt_ocrd_dt,l_effective_date),
            p_business_group_id => l_epe.business_group_id,
            p_assignment_id     => l_assignment_id,
            p_acty_base_rt_id   => p_acty_base_rt_id,
            p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
            p_organization_id   => l_organization_id,
            p_pgm_id            => l_epe.pgm_id,
            p_pl_id             => l_epe.pl_id,
            p_pl_typ_id         => l_epe.pl_typ_id,
            p_opt_id            => l_opt.opt_id,
            p_ler_id            => l_epe.ler_id,
            p_state             => l_state.region_2,
            p_val               => l_val); -- l_rounded_value);




  if l_abr.use_calc_acty_bs_rt_flag = 'N' then
     -- if we are not to calculate a rate, do not perform the variable rates
     -- code, rounding.
     p_val := l_val;
     --- this variable used for in out parameter so intialised here
     l_vr_ann_mn_elcn_val  := l_abr.ann_mn_elcn_val;
     l_vr_ann_mx_elcn_val  := l_abr.ann_mx_elcn_val;

     -- bug 1210355 safe coding make the global variable g_vrbl_mlt_code null
     -- if no variable rate is attached
     ben_determine_variable_rates.g_vrbl_mlt_code := null;
     --

  else
    --Bug 2192102 if the rate is of Flex credit letus get the associated enrt bnft id
    if l_enrt_bnft_id is null and l_abr.rt_usg_cd = 'FLXCR' then
      --
      hr_utility.set_location (' Before FLXCR  l_enrt_bnft_id '||l_enrt_bnft_id, 19);
      --
      open c_enb_fc ;
        fetch c_enb_fc into l_enrt_bnft_id  ;
      close c_enb_fc;
      --
      hr_utility.set_location (' After FLXCR  l_enrt_bnft_id '||l_enrt_bnft_id, 19);
    end if;
    --
    hr_utility.set_location ('BDVR_MN '||l_package,10);
    ben_determine_variable_rates.main
      (p_currepe_row            => p_currepe_row
      ,p_per_row                => p_per_row
      ,p_asg_row                => p_asg_row
      ,p_ast_row                => p_ast_row
      ,p_adr_row                => p_adr_row
      ,p_person_id              => p_person_id
      ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id           => l_enrt_bnft_id
      ,p_acty_base_rt_id        => p_acty_base_rt_id
      ,p_effective_date         => p_effective_date
      ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
      ,p_calc_only_rt_val_flag  => p_calc_only_rt_val_flag
      ,p_pgm_id                 => l_epe.pgm_id
      ,p_pl_id                  => l_epe.pl_id
      ,p_oipl_id                => l_epe.oipl_id
      ,p_pl_typ_id              => l_epe.pl_typ_id
      ,p_per_in_ler_id          => l_epe.per_in_ler_id
      ,p_ler_id                 => l_epe.ler_id
      ,p_business_group_id      => l_epe.business_group_id
      ,p_bnft_amt               => l_coverage_value
      ,p_entr_val_at_enrt_flag  => p_entr_val_at_enrt_flag -- Bug 7414757
      ,p_val                    => l_vr_val
      ,p_mn_elcn_val            => l_vr_mn_elcn_val
      ,p_mx_elcn_val            => l_vr_mx_elcn_val
      ,p_incrmnt_elcn_val       => l_vr_incrmt_elcn_val
      ,p_dflt_elcn_val          => l_vr_dflt_elcn_val
      ,p_tx_typ_cd              => l_vr_tx_typ_cd
      ,p_acty_typ_cd            => l_vr_acty_typ_cd
      ,p_vrbl_rt_trtmt_cd       => l_vr_trtmt_cd
      ,p_ultmt_upr_lmt          => l_ultmt_upr_lmt
      ,p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt
      ,p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl
      ,p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl
      ,p_ann_mn_elcn_val        => l_vr_ann_mn_elcn_val
      ,p_ann_mx_elcn_val        => l_vr_ann_mx_elcn_val
      );

    hr_utility.set_location('  after ben_determine_variable_rates ',200);
    --if l_val is null then
    --  l_vr_trtmt_cd := 'RPLC';
    --end if;
     -- Bug 8943410:Moved this code after the variable rate is treated on std rate
    -- and final rate value is derived
    /*if (l_abr.rndg_cd is not null or
        l_abr.rndg_rl is not null) and
        p_perform_rounding_flg
        and l_val is not null and
        nvl(l_vr_trtmt_cd,' ') <> 'RPLC' then

      l_rounded_value := benutils.do_rounding
        (p_rounding_cd     => l_abr.rndg_cd,
         p_rounding_rl     => l_abr.rndg_rl,
         p_value           => l_val,
         p_effective_date  => l_effective_date);
      l_val := l_rounded_value;
    end if;*/
    -- End of change for Bug 8943410

    hr_utility.set_location('rounded value rate  : ' ||to_char(l_val)  ,954);
    hr_utility.set_location('variable rate  : ' ||l_vr_val  ,954);
    hr_utility.set_location('treatement  : ' ||l_vr_trtmt_cd  ,954);
    --
    -- Tilak Bug 2438506 : if the abr have null values then treat as 1 for
    -- multiply
    -- as 0 for add or subtract.
    --
    if l_vr_val is not null then
      if l_vr_trtmt_cd = 'RPLC' then
        l_val := l_vr_val;
      elsif l_vr_trtmt_cd = 'MB' then
        l_val := nvl(l_val,1) * l_vr_val;
      elsif l_vr_trtmt_cd = 'SF' then
        l_val := nvl(l_val,0) - l_vr_val;
      elsif l_vr_trtmt_cd = 'ADDTO' then
        l_val := nvl(l_val,0) + l_vr_val;
      else
        l_val := l_vr_val;
      end if;
    end if;

     -- Bug 8943410: Variable rate is treated on std rate
    -- and final rate value is derived
    if (l_abr.rndg_cd is not null or
        l_abr.rndg_rl is not null) and
        p_perform_rounding_flg
        and l_val is not null and
        nvl(l_vr_trtmt_cd,' ') <> 'RPLC' then

      l_rounded_value := benutils.do_rounding
        (p_rounding_cd     => l_abr.rndg_cd,
         p_rounding_rl     => l_abr.rndg_rl,
         p_value           => l_val,
         p_effective_date  => l_effective_date);
      l_val := l_rounded_value;
    end if;
     -- End of change for Bug 8943410

    hr_utility.set_location('l_val2  : ' ||l_val  ,954);

    if  l_vr_trtmt_cd is not null  then
     --- Tilak : this code is not validating whether the enter at enrollemt is defined
     --- in either side ,(rate,VAPRO), this just work on the treatment code
     ---  the User has to make sure both the side has the same setup like enter at enrollemt
     --
     if l_vr_trtmt_cd = 'RPLC' then
        l_vr_mn_elcn_val      := nvl(l_vr_mn_elcn_val,l_abr.mn_elcn_val) ;
        l_vr_mx_elcn_val      := nvl(l_vr_mx_elcn_val,l_abr.mx_elcn_val) ;
        l_vr_incrmt_elcn_val  := nvl(l_vr_incrmt_elcn_val,l_abr.incrmt_elcn_val );
        l_vr_dflt_elcn_val    := nvl(l_vr_dflt_elcn_val , l_abr.dflt_val );
        l_vr_ann_mn_elcn_val  := nvl(l_vr_ann_mn_elcn_val,l_abr.ann_mn_elcn_val);
        l_vr_ann_mx_elcn_val  := nvl(l_vr_ann_mx_elcn_val,l_abr.ann_mx_elcn_val);
     -- Bug 2403243 - Assigning zero to the variables if vapro is returnd null
     -- and also l_abr values also null, which is worng.
    /*
     elsif  l_vr_trtmt_cd = 'ADDTO' then

        l_vr_mn_elcn_val      := nvl(l_vr_mn_elcn_val,0)+ nvl(l_abr.mn_elcn_val,0) ;
        l_vr_mx_elcn_val      := nvl(l_vr_mx_elcn_val,0)+ nvl(l_abr.mx_elcn_val,0) ;
        l_vr_incrmt_elcn_val  := nvl(l_vr_incrmt_elcn_val,0)+ nvl(l_abr.incrmt_elcn_val,0);
        l_vr_dflt_elcn_val    := nvl(l_vr_dflt_elcn_val,0)+ nvl(l_abr.dflt_val,0 );
        l_vr_ann_mn_elcn_val  := nvl(l_vr_ann_mn_elcn_val,0)+nvl(l_abr.ann_mn_elcn_val,0);
        l_vr_ann_mx_elcn_val  := nvl(l_vr_ann_mx_elcn_val,0)+nvl(l_abr.ann_mx_elcn_val,0);

     elsif l_vr_trtmt_cd = 'SF' then
        l_vr_mn_elcn_val      := nvl(l_abr.mn_elcn_val,0)    - nvl(l_vr_mn_elcn_val,0) ;
        l_vr_mx_elcn_val      := nvl(l_abr.mx_elcn_val,0)    - nvl(l_vr_mx_elcn_val,0) ;
        l_vr_incrmt_elcn_val  := nvl(l_abr.incrmt_elcn_val,0)- nvl(l_vr_incrmt_elcn_val,0);
        l_vr_dflt_elcn_val    := nvl(l_abr.dflt_val,0 )      - nvl(l_vr_dflt_elcn_val,0);
        l_vr_ann_mn_elcn_val  := nvl(l_abr.ann_mn_elcn_val,0)- nvl(l_vr_ann_mn_elcn_val,0);
        l_vr_ann_mx_elcn_val  := nvl(l_abr.ann_mx_elcn_val,0)- nvl(l_vr_ann_mx_elcn_val,0);

     elsif l_vr_trtmt_cd = 'MB' then

        l_vr_mn_elcn_val      := nvl(l_abr.mn_elcn_val,0)*nvl(l_vr_mn_elcn_val,0) ;
        l_vr_mx_elcn_val      := nvl(l_abr.mx_elcn_val,0)*nvl(l_vr_mx_elcn_val,0) ;
        l_vr_incrmt_elcn_val  := nvl(l_abr.incrmt_elcn_val,0)*nvl(l_vr_incrmt_elcn_val,0);
        l_vr_dflt_elcn_val    := nvl(l_abr.dflt_val,0 )*nvl(l_vr_dflt_elcn_val,0);
        l_vr_ann_mn_elcn_val  := nvl(l_vr_ann_mn_elcn_val,0)*nvl(l_abr.ann_mn_elcn_val,0);
        l_vr_ann_mx_elcn_val  := nvl(l_vr_ann_mx_elcn_val,0)*nvl(l_abr.ann_mx_elcn_val,0);
        */
      elsif  l_vr_trtmt_cd = 'ADDTO' then

        l_vr_mn_elcn_val      := get_expr_val('+', l_vr_mn_elcn_val,l_abr.mn_elcn_val);
        l_vr_mx_elcn_val      := get_expr_val('+', l_vr_mx_elcn_val,l_abr.mx_elcn_val);
        l_vr_incrmt_elcn_val  := get_expr_val('+', l_vr_incrmt_elcn_val,l_abr.incrmt_elcn_val);
        l_vr_dflt_elcn_val    := get_expr_val('+', l_vr_dflt_elcn_val,l_abr.dflt_val);
        l_vr_ann_mn_elcn_val  := get_expr_val('+', l_vr_ann_mn_elcn_val,l_abr.ann_mn_elcn_val);
        l_vr_ann_mx_elcn_val  := get_expr_val('+', l_vr_ann_mx_elcn_val,l_abr.ann_mx_elcn_val);

     elsif l_vr_trtmt_cd = 'SF' then
        l_vr_mn_elcn_val      := get_expr_val('-', l_abr.mn_elcn_val,l_vr_mn_elcn_val);
        l_vr_mx_elcn_val      := get_expr_val('-', l_abr.mx_elcn_val,l_vr_mx_elcn_val);
        l_vr_incrmt_elcn_val  := get_expr_val('-', l_abr.incrmt_elcn_val,l_vr_incrmt_elcn_val);
        l_vr_dflt_elcn_val    := get_expr_val('-', l_abr.dflt_val,l_vr_dflt_elcn_val);
        l_vr_ann_mn_elcn_val  := get_expr_val('-', l_abr.ann_mn_elcn_val,l_vr_ann_mn_elcn_val);
        l_vr_ann_mx_elcn_val  := get_expr_val('-', l_abr.ann_mx_elcn_val,l_vr_ann_mx_elcn_val);

     elsif l_vr_trtmt_cd = 'MB' then

        l_vr_mn_elcn_val      := get_expr_val('*', l_abr.mn_elcn_val,l_vr_mn_elcn_val);
        l_vr_mx_elcn_val      := get_expr_val('*', l_abr.mx_elcn_val,l_vr_mx_elcn_val) ;
        l_vr_incrmt_elcn_val  := get_expr_val('*', l_abr.incrmt_elcn_val,l_vr_incrmt_elcn_val);
        l_vr_dflt_elcn_val    := get_expr_val('*', l_abr.dflt_val,l_vr_dflt_elcn_val);
        l_vr_ann_mn_elcn_val  := get_expr_val('*', l_abr.ann_mn_elcn_val,l_vr_ann_mn_elcn_val);
        l_vr_ann_mx_elcn_val  := get_expr_val('*', l_abr.ann_mx_elcn_val,l_vr_ann_mx_elcn_val);

     else
        l_vr_mn_elcn_val      := l_abr.mn_elcn_val ;
        l_vr_mx_elcn_val      := l_abr.mx_elcn_val ;
        l_vr_dflt_elcn_val    := l_abr.dflt_val ;
        l_vr_incrmt_elcn_val  := l_abr.incrmt_elcn_val ;
        --
        -- For selfservice enhancement :
        -- Should assign l_abr.ann_mn_elcn_val not l_abr.ann_mx_elcn_val
        --
        l_vr_ann_mn_elcn_val  := l_abr.ann_mn_elcn_val;
        l_vr_ann_mx_elcn_val  := l_abr.ann_mx_elcn_val;

     end if;
  else
        l_vr_mn_elcn_val      := l_abr.mn_elcn_val ;
        l_vr_mx_elcn_val      := l_abr.mx_elcn_val ;
        l_vr_dflt_elcn_val    := l_abr.dflt_val ;
        l_vr_incrmt_elcn_val  := l_abr.incrmt_elcn_val ;
        --
        -- For selfservice enhancement :
        -- Should assign l_abr.ann_mn_elcn_val not l_abr.ann_mx_elcn_val
        --
        l_vr_ann_mn_elcn_val  := l_abr.ann_mn_elcn_val;
        l_vr_ann_mx_elcn_val  := l_abr.ann_mx_elcn_val;

     ---
  end if ;
  --
  l_abr.dflt_val := nvl(l_vr_dflt_elcn_val,l_abr.dflt_val);
  --
  hr_utility.set_location(' l_vr_dflt_elcn_val ' ||l_abr.dflt_val  , 199);

  hr_utility.set_location(' mn_elcn_va '      || l_vr_mn_elcn_val , 199);
    p_val := l_val;
    hr_utility.set_location('valiable and rate   : ' ||to_char(l_val)  ,954);
   if l_ultmt_upr_lmt is not null or l_ultmt_lwr_lmt is not null
     OR  l_ultmt_upr_lmt_calc_rl is not null or l_ultmt_lwr_lmt_calc_rl is not null then
        hr_utility.set_location(' calling ultmate check rate ' ,393);
        hr_utility.set_location('upper '|| l_ultmt_upr_lmt ||' Lower' || l_ultmt_lwr_lmt,393);
        hr_utility.set_location('ammount '|| p_val ,393);

       benutils.limit_checks
           (p_upr_lmt_val       => l_ultmt_upr_lmt,
            p_lwr_lmt_val       => l_ultmt_lwr_lmt,
            p_upr_lmt_calc_rl   => l_ultmt_upr_lmt_calc_rl,
            p_lwr_lmt_calc_rl   => l_ultmt_lwr_lmt_calc_rl,
            p_effective_date    => l_effective_date,
            p_business_group_id => l_epe.business_group_id,
            p_assignment_id     => l_assignment_id,
            p_acty_base_rt_id   => p_acty_base_rt_id,
            p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
            p_organization_id   => l_organization_id,
            p_pgm_id            => l_epe.pgm_id,
            p_pl_id             => l_epe.pl_id,
            p_pl_typ_id         => l_epe.pl_typ_id,
            p_opt_id            => l_opt.opt_id,
            p_ler_id            => l_epe.ler_id,
            p_state             => l_state.region_2,
            p_val               => p_val); -- l_rounded_value);
        hr_utility.set_location('ammount '|| p_val ,393);

   end if ;
    --
 end if;
  --
  -- Start 6015724
  --
    if l_rt_ovridn_flag = 'Y' and
     nvl(l_rt_ovridn_thru_dt, hr_api.g_eot) >= l_effective_date then -- p_effective_date then
     p_val := l_rt_val;
  end if;
  --
  -- End 6015724
  --
  --
  -- The rate value has been calculated. All the value
  -- related processing is done.
  -- Hence, if the p_calc_only_rt_flag is ON, then
  -- we should just return.
  -- Bug 2677804 use l_effective_date to handle open enrollment also
  if p_calc_only_rt_val_flag then
    /* 6015724 - Commenting out this code as we are already doing this calculation before now
     if l_rt_ovridn_flag = 'Y' and
        nvl(l_rt_ovridn_thru_dt, hr_api.g_eot) >= l_effective_date then -- p_effective_date then
        p_val := l_rt_val;
     end if; */
     return;
  end if;
--
  if l_pln_auto_distr_flag = 'Y' then
    p_iss_val := p_val;
  end if;
  --
  -- Get the participation start date to use in
  -- ben_determine_date.
  -- Note: don't check for notfound because
  --
  --   1) will handle null anyway.
  --   2) any eligibility requirements are already handled in bendenrr
  --      don't want to second guess it here
  --
  -- Check if the context information for the EPE is set. When it is
  -- there is no need to fire cursor because the information is pre
  -- derived.
  --
  if ben_manage_life_events.fonm = 'Y' then
     l_rt_strt_dt := l_fonm_rt_strt_dt;
     p_rt_strt_dt    := l_rt_strt_dt;
  else
     if p_currepe_row.prtn_strt_dt is not null then
       --
       l_prtn_strt_dt := p_currepe_row.prtn_strt_dt;
       --
     else
       --
       open c_current_elig
         (c_person_id      => p_person_id
         ,c_pl_id          => l_epe.pl_id
         ,c_pgm_id         => nvl(l_epe.pgm_id,-1)
         ,c_opt_id         => l_opt.opt_id
         ,c_nvlopt_id      => nvl(l_opt.opt_id,hr_api.g_number)
         ,c_effective_date => l_effective_date
         );
       fetch c_current_elig into l_prtn_strt_dt;
       close c_current_elig;
       --
     end if;
     hr_utility.set_location ('BDD_RACD '||l_package,10);
     ben_determine_date.rate_and_coverage_dates
       (p_cache_mode             => TRUE
       ,p_par_ptip_id            => l_epe.ptip_id
       ,p_par_plip_id            => l_epe.plip_id
       ,p_person_id              => l_epe.person_id
       ,p_per_in_ler_id          => l_epe.per_in_ler_id
       ,p_pgm_id                 => l_epe.pgm_id
       ,p_pl_id                  => l_epe.pl_id
       ,p_oipl_id                => l_epe.oipl_id
       ,p_enrt_perd_id           => l_epe.enrt_perd_id
       ,p_lee_rsn_id             => l_epe.lee_rsn_id
       --
       ,p_which_dates_cd         => 'R'
           ,p_date_mandatory_flag => 'N'
       ,p_compute_dates_flag     => 'Y'
   /*
          ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
   */
       ,p_business_group_id      => l_epe.business_group_id
       ,p_acty_base_rt_id        => p_acty_base_rt_id
       ,p_effective_date         => p_effective_date
       ,p_lf_evt_ocrd_dt         => greatest
                                      (nvl(p_lf_evt_ocrd_dt,l_prtn_strt_dt)
                                      ,nvl(l_prtn_strt_dt,p_lf_evt_ocrd_dt))
       ,p_rt_strt_dt             => l_rt_strt_dt
       ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
       ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
       ,p_enrt_cvg_strt_dt       => l_dummy_date
       ,p_enrt_cvg_strt_dt_cd    => l_dummy_char
       ,p_enrt_cvg_strt_dt_rl    => l_dummy_num
       ,p_enrt_cvg_end_dt        => l_dummy_date
       ,p_enrt_cvg_end_dt_cd     => l_dummy_char
       ,p_enrt_cvg_end_dt_rl     => l_dummy_num
       ,p_rt_end_dt              => l_dummy_date
       ,p_rt_end_dt_cd           => l_dummy_char
       ,p_rt_end_dt_rl           => l_dummy_num
       );
     hr_utility.set_location ('Dn BDD_RACD '||l_package,10);
     p_rt_strt_dt    := l_rt_strt_dt;
     p_rt_strt_dt_cd := l_rt_strt_dt_cd;
     p_rt_strt_dt_rl := l_rt_strt_dt_rl;
  end if;

  p_entr_ann_val_flag := l_abr.entr_ann_val_flag;
  p_ptd_comp_lvl_fctr_id := l_abr.ptd_comp_lvl_fctr_id;
  p_clm_comp_lvl_fctr_id := l_abr.clm_comp_lvl_fctr_id;
  --

  -- bug 1210355, if variable rate is detected use the mlt code attached to the variable profile
  if l_vr_trtmt_cd = 'RPLC' then
     p_rt_mlt_cd     := nvl(ben_determine_variable_rates.g_vrbl_mlt_code,l_abr.rt_mlt_cd);
  else
     p_rt_mlt_cd := l_abr.rt_mlt_cd;
  end if;
  --

  --
  --  compute annual val and communicated values
  --
 if l_abr.rt_mlt_cd <> 'SAREC' then
  if l_abr.bnft_rt_typ_cd = 'PCT'  or l_abr.use_calc_acty_bs_rt_flag = 'N' then
    -- Percents and non-calculated rates should not have computed communicated
    -- nor annual values.
    -- bug 1834655
    if l_dflt_enrt_cd in ('NSDCS','NNCS') and
       p_currepe_row.prtt_enrt_rslt_id is not null then
      --
      null ;
      --
    else
      if l_abr.entr_ann_val_flag = 'Y' then
        p_ann_dflt_val           := l_abr.dflt_val;
      else
        p_dflt_val               := l_abr.dflt_val;
      end if;
    end if;
    -- p_ann_dflt_val        := l_abr.dflt_val;
    p_ann_val                := p_val;
    p_ann_mn_elcn_val        := l_vr_ann_mn_elcn_val;
    p_ann_mx_elcn_val        := l_vr_ann_mx_elcn_val;
    p_cmcd_val               := p_val;
    p_cmcd_mn_elcn_val       := nvl(l_vr_ann_mn_elcn_val,l_abr.ann_mn_elcn_val);
    p_cmcd_mx_elcn_val       := nvl(l_vr_ann_mx_elcn_val,l_abr.ann_mx_elcn_val);
    p_cmcd_acty_ref_perd_cd  := l_enrt_info_rt_freq_cd;

  else
    hr_utility.set_location ('BDR_PTA '||l_package,10);
    hr_utility.set_location (' l_abr.dflt_val '||l_abr.dflt_val,22);
    hr_utility.set_location (' p_elig_per_elctbl_chc_id '||p_elig_per_elctbl_chc_id,22);
    --
    --Bug 2445318 We need to see whether to assign the l_abr.dflt_val to
    -- p_ann_dflt_val or p_dflt_val
    --
    --BUG 3253180 We dont need to do this for current enrollment
    --
--    if nvl(l_env.mode_cd,'~') <> 'D' then
    --
    if l_dflt_enrt_cd in ('NSDCS','NNCS') and
       p_currepe_row.prtt_enrt_rslt_id is not null then
      --
      null ;
    else
      --
      if l_abr.dflt_val is not null then
        if p_entr_ann_val_flag = 'Y' then
          --
          p_ann_dflt_val := l_abr.dflt_val ;
          --
        else
          --GEVITY
          IF l_abr.rate_periodization_rl IS NOT NULL THEN
            --
            ben_distribute_rates.periodize_with_rule
              (p_formula_id             => l_abr.rate_periodization_rl
              ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date)
              ,p_assignment_id          => l_assignment_id
              ,p_convert_from_val       => l_abr.dflt_val
              ,p_convert_from           => 'DEFINED'
              ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
              ,p_acty_base_rt_id        => p_acty_base_rt_id
              ,p_business_group_id      => l_epe.business_group_id
              ,p_enrt_rt_id             => NULL
              ,p_ann_val                => p_ann_dflt_val
              ,p_cmcd_val               => l_cmcd_dummy
              ,p_val                    => l_dfnd_dummy
              );
            --
          ELSE
            --
            p_ann_dflt_val := ben_distribute_rates.period_to_annual
                       (p_amount                  => l_abr.dflt_val,
                        p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                        p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
                        p_business_group_id       => l_epe.business_group_id,
                        p_effective_date          => l_effective_date,
                        p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                        p_complete_year_flag      => 'Y',
                        p_payroll_id              => l_payroll_id);
            p_dflt_val := l_abr.dflt_val;
            --
          END IF; --GEVITY
        end if;
      end if;
    end if;
    --
-- end if; -- 'D' Mode
    hr_utility.set_location (' p_dflt_val '||p_dflt_val,23);
    hr_utility.set_location (' p_ann_dflt_val '||p_ann_dflt_val,23);
    hr_utility.set_location (' l_ann_dflt_val '||l_ann_dflt_val,22);
    --GEVITY
    IF l_abr.rate_periodization_rl IS NOT NULL THEN
       --
       l_dfnd_dummy  := p_val ;
       --
       ben_distribute_rates.periodize_with_rule
              (p_formula_id             => l_abr.rate_periodization_rl
              ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date)
              ,p_assignment_id          => l_assignment_id
              ,p_convert_from_val       => l_dfnd_dummy
              ,p_convert_from           => 'DEFINED'
              ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
              ,p_acty_base_rt_id        => p_acty_base_rt_id
              ,p_business_group_id      => l_epe.business_group_id
              ,p_enrt_rt_id             => NULL
              ,p_ann_val                => l_ann_val
              ,p_cmcd_val               => l_cmcd_val
              ,p_val                    => p_val
              );
      --
      l_dfnd_dummy := NULL ;
      --
    ELSE
      --
      l_ann_val := ben_distribute_rates.period_to_annual
                  (p_amount                  => p_val,
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id);
      hr_utility.set_location ('BDR_PTA '||l_package,290);
      --
      l_calc_val := ben_distribute_rates.period_to_annual
                  (p_amount                  => p_val,
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id);
      --
      if l_enrt_info_rt_freq_cd = 'PPF' then
        l_element_type_id := l_abr.element_type_id;
      else
        l_element_type_id := null;
      end if;
      --
      l_cmcd_val := ben_distribute_rates.annual_to_period_out
                  (p_amount                  => l_calc_val,
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_enrt_info_rt_freq_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   /* Start of Changes for WWBUG: 1791203                 */
                   p_payroll_id              => l_payroll_id,
                   p_element_type_id         => l_element_type_id,
                   p_pp_in_yr_used_num       => p_pp_in_yr_used_num);
    END IF; --GEVITY
    --
    p_ann_val                := l_ann_val;
    p_cmcd_val               := l_cmcd_val;
    p_cmcd_acty_ref_perd_cd  := l_enrt_info_rt_freq_cd;
    --
    --Bug 5225815 do not prorate if there are no prior elections
    --or the l_rt_strt_dt is null
    if l_abr.entr_ann_val_flag = 'Y' and l_rt_strt_dt is not null then
        -- Before assigning the annual min and max, try to prorate the values.
        ben_distribute_rates.prorate_min_max
          (p_person_id                => p_person_id
          ,p_effective_date           => l_effective_date
          ,p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id
          ,p_acty_base_rt_id          => p_acty_base_rt_id
          ,p_rt_strt_dt               => l_rt_strt_dt
          ,p_ann_mn_val               => l_vr_ann_mn_elcn_val
          ,p_ann_mx_val               => l_vr_ann_mx_elcn_val ) ;
        -- Also, check that their period-to-date payments and claims do not
        -- force the minimum and maximum to be different.
        ben_distribute_rates.compare_balances
          (p_person_id            => p_person_id
          ,p_effective_date       => l_effective_date
          ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
          ,p_pgm_id               => l_epe.pgm_id
          ,p_pl_id                => l_epe.pl_id
          ,p_oipl_id              => l_epe.oipl_id
          ,p_per_in_ler_id        => l_epe.per_in_ler_id
          ,p_business_group_id    => l_epe.business_group_id
          ,p_acty_base_rt_id      => p_acty_base_rt_id
          ,p_ann_mn_val           => l_vr_ann_mn_elcn_val
          ,p_ann_mx_val           => l_vr_ann_mx_elcn_val
          ,p_ptd_balance          => l_ptd_balance -- outputs not used here.
          ,p_clm_balance          => l_clm_balance ) ;
    end if;
    --
    p_ann_mn_elcn_val        := nvl(l_vr_ann_mn_elcn_val,l_abr.ann_mn_elcn_val);
    p_ann_mx_elcn_val        := nvl(l_vr_ann_mx_elcn_val,l_abr.ann_mx_elcn_val);
    hr_utility.set_location ('BDR_ATP '||l_package,290);
    hr_utility.set_location ('Dn BDR_ATP '||l_package,290);
    --
  end if;
  --
  -- bug fix 2569884 - Communicated Min and Max values are needed for self service
  -- irrespective of whether calculate for enrollment flag is checked or not.
  -- Hence, moving the logic of calculating l_cmcd_mn_val/l_cmcd_mx_val outside the
  -- if condition of use_calc_acty_bs_rt_flag (above).
  -- The communicated Min/Max are to be calculated only when rate is
  -- 'Enter Value at enrollment'
  --
  if l_abr.entr_val_at_enrt_flag = 'Y' then
     --
     -- For selfservice enhancement : Communicated values are required
     -- on self service pages.
     --
     if(l_abr.entr_ann_val_flag = 'Y') then
          --
       if nvl(l_vr_ann_mn_elcn_val,l_abr.ann_mn_elcn_val) is not null then
          --
          if l_enrt_info_rt_freq_cd = 'PPF' then
              l_element_type_id := l_abr.element_type_id;
          else
              l_element_type_id := null;
          end if;
          --
          IF l_abr.rate_periodization_rl IS NOT NULL THEN
            --
            ben_distribute_rates.periodize_with_rule
              (p_formula_id             => l_abr.rate_periodization_rl
              ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date)
              ,p_assignment_id          => l_assignment_id
              ,p_convert_from_val       => nvl(l_vr_ann_mn_elcn_val,l_abr.ann_mn_elcn_val)
              ,p_convert_from           => 'ANNUAL'
              ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
              ,p_acty_base_rt_id        => p_acty_base_rt_id
              ,p_business_group_id      => l_epe.business_group_id
              ,p_enrt_rt_id             => NULL
              ,p_ann_val                => l_ann_dummy
              ,p_cmcd_val               => l_cmcd_mn_val
              ,p_val                    => l_dfnd_dummy
              );
            --
          ELSE
            --
            l_cmcd_mn_val := ben_distribute_rates.annual_to_period
                  (p_amount                  => nvl(l_vr_ann_mn_elcn_val,l_abr.ann_mn_elcn_val),
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_enrt_info_rt_freq_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id,
                   p_element_type_id         => l_element_type_id);
          END IF; --GEVITY
       end if;

       if nvl(l_vr_ann_mx_elcn_val,l_abr.ann_mx_elcn_val) is not null then
         --GEVITY
         IF l_abr.rate_periodization_rl IS NOT NULL THEN
           --
           ben_distribute_rates.periodize_with_rule
              (p_formula_id             => l_abr.rate_periodization_rl
              ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date)
              ,p_assignment_id          => l_assignment_id
              ,p_convert_from_val       =>  nvl(l_vr_ann_mx_elcn_val,l_abr.ann_mx_elcn_val)
              ,p_convert_from           => 'ANNUAL'
              ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
              ,p_acty_base_rt_id        => p_acty_base_rt_id
              ,p_business_group_id      => l_epe.business_group_id
              ,p_enrt_rt_id             => NULL
              ,p_ann_val                => l_ann_dummy
              ,p_cmcd_val               => l_cmcd_mx_val
              ,p_val                    => l_dfnd_dummy
              );
           --
         ELSE
           --
           if l_enrt_info_rt_freq_cd = 'PPF' then
	       l_element_type_id := l_abr.element_type_id;
           else
	        l_element_type_id := null;
           end if;
           --
           l_cmcd_mx_val := ben_distribute_rates.annual_to_period
                  (p_amount                  =>nvl(l_vr_ann_mx_elcn_val,l_abr.ann_mx_elcn_val),
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_enrt_info_rt_freq_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id,
                   p_element_type_id         => l_element_type_id);
         END IF; --GEVITY
       end if;

       -- hmani

	          if l_abr.dflt_val is not null then
	          hr_utility.set_location ('HMANI '||l_abr.dflt_val,290.3);
	   	            --GEVITY
	   	            IF l_abr.rate_periodization_rl IS NOT NULL THEN
	   	              --
	   	              --null;

	   	             ben_distribute_rates.periodize_with_rule
	   	                 (p_formula_id             => l_abr.rate_periodization_rl
	   	                 ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date)
	   	                 ,p_assignment_id          => l_assignment_id
	   	                 ,p_convert_from_val       =>  p_ann_dflt_val
	   	                 ,p_convert_from           => 'ANNUAL'
	   	                 ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
	   	                 ,p_acty_base_rt_id        => p_acty_base_rt_id
	   	                 ,p_business_group_id      => l_epe.business_group_id
	   	                 ,p_enrt_rt_id             => NULL
	   	                 ,p_ann_val                => l_ann_dummy
	   	                 ,p_cmcd_val               => l_cmcd_dflt_val
	   	                 ,p_val                    => l_dfnd_dummy
	   	                 );
	   	              --

	   	            ELSE
	   	              --
	   	              if l_enrt_info_rt_freq_cd = 'PPF' then
	   	                l_element_type_id := l_abr.element_type_id;
	   	              else
	   	                l_element_type_id := null;
	   	              end if;
	   	              --
	   	              hr_utility.set_location ('HMANI  Me here'||l_cmcd_dflt_val,290.3);
	   	              l_cmcd_dflt_val := ben_distribute_rates.annual_to_period
	   	                     (p_amount                  => p_ann_dflt_val,
	   	                      p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
	   	                      p_acty_ref_perd_cd        => l_enrt_info_rt_freq_cd,
	   	                      p_business_group_id       => l_epe.business_group_id,
	   	                      p_effective_date          => l_effective_date,
	   	                      p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
	   	                      p_complete_year_flag      => 'Y',
	   	                      p_payroll_id              => l_payroll_id,
	   	                      p_element_type_id         => l_element_type_id);

				     --7154229
				     if(p_cmcd_val is null) then
					p_cmcd_val := l_cmcd_dflt_val;
	                             end if;
                                     hr_utility.set_location ('HMANI '||l_cmcd_dflt_val,290.3);
	   	            END IF; --GEVITY
	          end if;

       -- End of hmani

     else
        --
        --  When  enter annual value flag is 'N', we need to
        --  convert defined values into annual values
        --  and then covert them into communicated min max values
        --
       if (nvl(l_vr_mn_elcn_val,l_abr.mn_elcn_val)) is not null then
         --GEVITY
         IF l_abr.rate_periodization_rl IS NOT NULL THEN
           --
           ben_distribute_rates.periodize_with_rule
              (p_formula_id             => l_abr.rate_periodization_rl
              ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date)
              ,p_assignment_id          => l_assignment_id
              ,p_convert_from_val       => nvl(l_vr_mn_elcn_val,l_abr.mn_elcn_val)
              ,p_convert_from           => 'DEFINED'
              ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
              ,p_acty_base_rt_id        => p_acty_base_rt_id
              ,p_business_group_id      => l_epe.business_group_id
              ,p_enrt_rt_id             => NULL
              ,p_ann_val                => l_cmcd_ann_mn_val
              ,p_cmcd_val               => l_cmcd_mn_val
              ,p_val                    => l_dfnd_dummy
              );
           --
         ELSE
           --
              l_cmcd_ann_mn_val := ben_distribute_rates.period_to_annual
                  (p_amount                  => nvl(l_vr_mn_elcn_val,l_abr.mn_elcn_val),
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id);
              --
              if l_enrt_info_rt_freq_cd = 'PPF' then
                 l_element_type_id := l_abr.element_type_id;
              else
                 l_element_type_id := null;
              end if;
              --
              l_cmcd_mn_val := ben_distribute_rates.annual_to_period
                  (p_amount                  =>l_cmcd_ann_mn_val ,
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_enrt_info_rt_freq_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id,
                   p_element_type_id         => l_element_type_id);
           --
         END IF;  --GEVITY
       end if;

       if (nvl(l_vr_mx_elcn_val,l_abr.mx_elcn_val)) is not null then
         --GEVITY
         IF l_abr.rate_periodization_rl IS NOT NULL THEN
           --
           ben_distribute_rates.periodize_with_rule
              (p_formula_id             => l_abr.rate_periodization_rl
              ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date)
              ,p_assignment_id          => l_assignment_id
              ,p_convert_from_val       => nvl(l_vr_mx_elcn_val,l_abr.mx_elcn_val)
              ,p_convert_from           => 'DEFINED'
              ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
              ,p_acty_base_rt_id        => p_acty_base_rt_id
              ,p_business_group_id      => l_epe.business_group_id
              ,p_enrt_rt_id             => NULL
              ,p_ann_val                => l_cmcd_ann_mx_val
              ,p_cmcd_val               => l_cmcd_mx_val
              ,p_val                    => l_dfnd_dummy
              );
           --
         ELSE
           --
              --
              l_cmcd_ann_mx_val := ben_distribute_rates.period_to_annual
                  (p_amount                  => nvl(l_vr_mx_elcn_val,l_abr.mx_elcn_val),
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id);
              --

              if l_enrt_info_rt_freq_cd = 'PPF' then
                 l_element_type_id := l_abr.element_type_id;
              else
                 l_element_type_id := null;
              end if;
              --
              l_cmcd_mx_val := ben_distribute_rates.annual_to_period
                  (p_amount                  =>l_cmcd_ann_mx_val,
                   p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_enrt_info_rt_freq_cd,
                   p_business_group_id       => l_epe.business_group_id,
                   p_effective_date          => l_effective_date,
                   p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id,
                   p_element_type_id         => l_element_type_id);
              --
         END IF; --GEVITY
       end if;

	--hmani -- 3274902
        if l_abr.dflt_val is not null then
	            --GEVITY
	            IF l_abr.rate_periodization_rl IS NOT NULL THEN
	              --
	              ben_distribute_rates.periodize_with_rule
	                 (p_formula_id             => l_abr.rate_periodization_rl
	                 ,p_effective_date         => nvl(p_lf_evt_ocrd_dt,l_effective_date)
	                 ,p_assignment_id          => l_assignment_id
	                 ,p_convert_from_val       => l_abr.dflt_val
	                 ,p_convert_from           => 'DEFINED'
	                 ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
	                 ,p_acty_base_rt_id        => p_acty_base_rt_id
	                 ,p_business_group_id      => l_epe.business_group_id
	                 ,p_enrt_rt_id             => NULL
	                 ,p_ann_val                => l_cmcd_ann_dflt_val
	                 ,p_cmcd_val               => l_cmcd_dflt_val
	                 ,p_val                    => l_dfnd_dummy
	                 );
	              --
	            ELSE
	              --
	                 --
	                 l_cmcd_ann_dflt_val := ben_distribute_rates.period_to_annual
	                     (p_amount                  => l_abr.dflt_val,
	                      p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
	                      p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
	                      p_business_group_id       => l_epe.business_group_id,
	                      p_effective_date          => l_effective_date,
	                      p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
	                      p_complete_year_flag      => 'Y',
	                      p_payroll_id              => l_payroll_id);
	                 --

	                 if l_enrt_info_rt_freq_cd = 'PPF' then
	                    l_element_type_id := l_abr.element_type_id;
	                 else
	                    l_element_type_id := null;
	                 end if;
	                 --
	                 l_cmcd_dflt_val := ben_distribute_rates.annual_to_period
	                     (p_amount                  =>l_cmcd_ann_dflt_val,
	                      p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
	                      p_acty_ref_perd_cd        => l_enrt_info_rt_freq_cd,
	                      p_business_group_id       => l_epe.business_group_id,
	                      p_effective_date          => l_effective_date,
	                      p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
	                      p_complete_year_flag      => 'Y',
	                      p_payroll_id              => l_payroll_id,
	                      p_element_type_id         => l_element_type_id);
				hr_utility.set_location ('HMANI '||l_cmcd_dflt_val,290.678);
	                 --
	            END IF; --GEVITY
       end if;

       --End of 3274902 hmani

     end if;
     ---

     p_cmcd_mn_elcn_val       := l_cmcd_mn_val;
     p_cmcd_mx_elcn_val       :=l_cmcd_mx_val;
     p_cmcd_val		      := l_cmcd_dflt_val;
     --
     -- For selfservice enhancement : Communicated values are required
     -- on self service pages.
     --
  end if;
  --
  -- end fix 2569884
 end if;
  --
  -- 3274902
  -- Cmcd_dflt_val is not getting calculated or returned since there is no
  -- parameter added to the benrates package.
  -- As a workaround to fix the issue with minimal code impact, p_iss_val paramter
  -- has been chosen and the l_cmcd_dflt val has been returned in the p_iss_val
  -- We here check that the mode is not CWB since CWB only uses iss_val

   ben_env_object.get(p_rec => l_env);
      hr_utility.set_location(' ben_env_object: Mode ' || l_env.mode_cd, 10);

	if l_env.mode_cd <> 'W' and p_iss_val is null then
		p_iss_val := l_cmcd_dflt_val ;
    end if;

  -- End of 3274902


  -- set remaining outputs, variable rate outputs override abr outputs.
  --
  if l_abr.entr_val_at_enrt_flag = 'Y' then
     p_bnft_rt_typ_cd := l_abr.bnft_rt_typ_cd;
     p_rt_typ_cd := l_abr.rt_typ_cd;
     -- p_dflt_val := l_abr.dflt_val; -- 2445318
  else
     p_bnft_rt_typ_cd := null;
     p_rt_typ_cd := null;
  end if;

  if l_vr_mn_elcn_val is not null then
    p_mn_elcn_val := l_vr_mn_elcn_val;
  end if;

  if l_vr_mx_elcn_val is not null then
    p_mx_elcn_val := l_vr_mx_elcn_val;
  end if;

  if l_vr_incrmt_elcn_val is not null then
    p_incrmt_elcn_val := l_vr_incrmt_elcn_val;
  end if;
  -- 2445318 Already handled
  --if l_vr_dflt_elcn_val is not null then
  --  p_dflt_val := l_vr_dflt_elcn_val;
  --end if;

  if l_vr_tx_typ_cd is not null then
    p_tx_typ_cd := l_vr_tx_typ_cd;
  end if;

  if l_vr_acty_typ_cd is not null then
    p_acty_typ_cd := l_vr_acty_typ_cd;
  end if;

  if l_vr_ann_mn_elcn_val is not null then
    p_ann_mn_elcn_val := l_vr_ann_mn_elcn_val;
    --
    -- For selfservice enhancement : Communicated values are required
    -- on self service pages.
    --
    p_cmcd_mn_elcn_val := l_cmcd_mn_val;

  end if;

  if l_vr_ann_mx_elcn_val is not null then
    p_ann_mx_elcn_val := l_vr_ann_mx_elcn_val;
    --
    -- For selfservice enhancement : Communicated values are required
    -- on self service pages.
    --
    p_cmcd_mx_elcn_val := l_cmcd_mx_val;
    --
  end if;
  -- Bug 4637525
  --
  hr_utility.set_location('ACE l_abr.rt_mlt_cd = ' || l_abr.rt_mlt_cd , 9898);
  hr_utility.set_location('ACE l_env.mode_cd = ' || l_env.mode_cd , 9898);
  hr_utility.set_location('ACE l_abr.entr_val_at_enrt_flag = ' || l_abr.entr_val_at_enrt_flag , 9898);
  hr_utility.set_location('ACE l_abr.acty_typ_cd = ' || l_abr.acty_typ_cd , 9898);
  hr_utility.set_location('ACE l_compensation_value = ' || l_compensation_value , 9898);
  --
  if nvl(l_env.mode_cd,'~') = 'W' and
     l_abr.entr_val_at_enrt_flag = 'Y' and
     l_abr.rt_mlt_cd in ('CL' ) and
     l_abr.acty_typ_cd like 'CWB%' and
     l_compensation_value is not null  and
     nvl(l_vr_trtmt_cd,' ') <> 'RPLC'
  then
     --
     benutils.rt_typ_calc
                  (p_rt_typ_cd      => l_abr.rt_typ_cd
                  ,p_val            => p_mn_elcn_val
                  ,p_val_2          => l_compensation_value
                  ,p_calculated_val => l_cwb_mn_elcn_val);
     --
     hr_utility.set_location('l_cwb_mn_elcn_val is '||l_cwb_mn_elcn_val,951);
     --
     --
     benutils.rt_typ_calc
                  (p_rt_typ_cd      => l_abr.rt_typ_cd
                  ,p_val            => p_mx_elcn_val
                  ,p_val_2          => l_compensation_value
                  ,p_calculated_val => l_cwb_mx_elcn_val);
     --
     hr_utility.set_location('l_cwb_mx_elcn_val is '|| l_cwb_mx_elcn_val,951);
     --
     -- 5371364 : Do not Operate (i.e multiply/divide..) the Increment Value.
     l_cwb_incrmt_elcn_val := p_incrmt_elcn_val;
     /*
     benutils.rt_typ_calc
                  (p_rt_typ_cd      => l_abr.rt_typ_cd
                  ,p_val            => p_incrmt_elcn_val
                  ,p_val_2          => l_compensation_value
                  ,p_calculated_val => l_cwb_incrmt_elcn_val);
     */
     --

     hr_utility.set_location('l_cwb_incrmt_elcn_val is '|| l_cwb_incrmt_elcn_val,951);
     --
     benutils.rt_typ_calc
                  (p_rt_typ_cd      => l_abr.rt_typ_cd
                  ,p_val            => l_vr_dflt_elcn_val
                  ,p_val_2          => l_compensation_value
                  ,p_calculated_val => l_cwb_dflt_val);
     --
     hr_utility.set_location('l_cwb_dflt_val is '|| l_cwb_dflt_val,951);
     --
     --
     --  Round the values. Bug 4873847.
     --
     if (l_abr.rndg_cd is not null or
         l_abr.rndg_rl is not null) and
         p_perform_rounding_flg then

       if l_cwb_mn_elcn_val is not null then
         l_rounded_value := benutils.do_rounding
           (p_rounding_cd     => l_abr.rndg_cd,
            p_rounding_rl     => l_abr.rndg_rl,
            p_value           => l_cwb_mn_elcn_val,
            p_effective_date  => l_effective_date);
         l_cwb_mn_elcn_val := l_rounded_value;
       end if;
       --
       if l_cwb_mx_elcn_val is not null then
         l_rounded_value := benutils.do_rounding
           (p_rounding_cd     => l_abr.rndg_cd,
            p_rounding_rl     => l_abr.rndg_rl,
            p_value           => l_cwb_mx_elcn_val,
            p_effective_date  => l_effective_date);
         l_cwb_mx_elcn_val := l_rounded_value;
       end if;
       --
       if l_cwb_dflt_val is not null then
         l_rounded_value := benutils.do_rounding
           (p_rounding_cd     => l_abr.rndg_cd,
            p_rounding_rl     => l_abr.rndg_rl,
            p_value           => l_cwb_dflt_val,
            p_effective_date  => l_effective_date);
         l_cwb_dflt_val := l_rounded_value;
       end if;
     end if;
     --
     p_mx_elcn_val         := nvl(l_cwb_mx_elcn_val, p_mx_elcn_val);
     p_mn_elcn_val         := nvl(l_cwb_mn_elcn_val, p_mn_elcn_val);
     p_incrmt_elcn_val     := nvl(l_cwb_incrmt_elcn_val,p_incrmt_elcn_val);
     l_vr_dflt_elcn_val    := nvl(l_cwb_dflt_val, l_vr_dflt_elcn_val );
     p_dflt_val            := l_vr_dflt_elcn_val;
     --
     hr_utility.set_location('ACE p_mn_elcn_val = ' || p_mn_elcn_val , 9898);
     hr_utility.set_location('ACE p_mx_elcn_val = ' || p_mx_elcn_val , 9898);
     hr_utility.set_location('ACE p_incrmt_elcn_val = ' || p_incrmt_elcn_val , 9898);
     hr_utility.set_location('ACE l_vr_dflt_elcn_val = ' || l_vr_dflt_elcn_val , 9898);
     --
  end if;
  --
  -- Bug 4637525

  if l_abr.entr_ann_val_flag = 'Y' then
     p_dsply_mn_elcn_val := nvl(l_vr_ann_mx_elcn_val,l_abr.ann_mn_elcn_val);
     p_dsply_mx_elcn_val := nvl(l_vr_ann_mx_elcn_val,l_abr.ann_mx_elcn_val);
     p_comp_lvl_fctr_id  := l_abr.comp_lvl_fctr_id;
  else
     p_dsply_mn_elcn_val := p_mn_elcn_val;
     p_dsply_mx_elcn_val := p_mx_elcn_val;
  end if;

  /* Bg 6015724 : Shifting this code part above
  --Bug 2677804. Use l_effective_date to resolve the open enrollment issue.
  if l_rt_ovridn_flag = 'Y' and
     nvl(l_rt_ovridn_thru_dt, hr_api.g_eot) >= l_effective_date then -- p_effective_date then
     p_val := l_rt_val;
  end if;
 */

  hr_utility.set_location ('Leaving '||l_package,999);
exception
  --
  when others then
    --
    p_val                         := null;
    p_mn_elcn_val                 := null;
    p_mx_elcn_val                 := null;
    p_ann_val                     := null;
    p_ann_mn_elcn_val             := null;
    p_ann_mx_elcn_val             := null;
    p_cmcd_val                    := null;
    p_cmcd_mn_elcn_val            := null;
    p_cmcd_mx_elcn_val            := null;
    p_cmcd_acty_ref_perd_cd       := null;
    p_incrmt_elcn_val             := null;
    p_dflt_val                    := null;
    p_tx_typ_cd                   := null;
    p_acty_typ_cd                 := null;
    p_nnmntry_uom                 := null;
    p_entr_val_at_enrt_flag       := null;
    p_dsply_on_enrt_flag          := null;
    p_use_to_calc_net_flx_cr_flag := null;
    p_rt_usg_cd                   := null;
    p_bnft_prvdr_pool_id          := null;
    p_actl_prem_id                := null;
    p_cvg_calc_amt_mthd_id        := null;
    p_bnft_rt_typ_cd              := null;
    p_rt_typ_cd                   := null;
    p_rt_mlt_cd                   := null;
    p_comp_lvl_fctr_id            := null;
    p_entr_ann_val_flag           := null;
    p_ptd_comp_lvl_fctr_id        := null;
    p_clm_comp_lvl_fctr_id        := null;
    p_ann_dflt_val                := null;
    p_rt_strt_dt                  := null;
    p_rt_strt_dt_cd               := null;
    p_rt_strt_dt_rl               := null;
    p_prtt_rt_val_id              := null;
    p_dsply_mn_elcn_val           := null;
    p_dsply_mx_elcn_val           := null;
    p_pp_in_yr_used_num           := null;
    p_ordr_num                := null;

    raise;

end main;

--------------------------------------------------------------------------------
--                                 Main_w
--------------------------------------------------------------------------------
PROCEDURE main_w
  (p_person_id                   IN number
  ,p_elig_per_elctbl_chc_id      IN number
  ,p_enrt_bnft_id                IN number default null
  ,p_acty_base_rt_id             IN number
  ,p_effective_date              IN date
  ,p_lf_evt_ocrd_dt              IN date   default null
  ,p_calc_only_rt_val_flag       in varchar2 default 'N'
  ,p_pl_id                       in number   default null
  ,p_oipl_id                     in number   default null
  ,p_pgm_id                      in number   default null
  ,p_pl_typ_id                   in number   default null
  ,p_per_in_ler_id               in number   default null
  ,p_ler_id                      in number   default null
  ,p_bnft_amt                    in number   default null
  ,p_business_group_id           in number   default null
  ,p_val                         OUT NOCOPY number
  ,p_ann_val                     OUT NOCOPY number
  ,p_cmcd_val                    OUT NOCOPY number)     is

  l_package varchar2(80) := g_package||'.main_w';

  l_calc_only_rt_val_flag boolean := false;
  l_dummy_char varchar2(200);
  l_dummy_num  number;
  l_dummy_date date;
  l_element_type_id  number;
  l_effective_date date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
  cursor c_enrt_rt is
    select ecr.rt_mlt_cd,
           ecr.enrt_rt_id,
           ecr.cmcd_acty_ref_perd_cd,
           enb.elig_per_elctbl_chc_id,
           ecr.acty_base_rt_id,
           ecr.business_group_id
    from ben_enrt_rt ecr,
         ben_enrt_bnft enb
    where enb.enrt_bnft_id = p_enrt_bnft_id
      and ecr.enrt_bnft_id = enb.enrt_bnft_id
      and ecr.acty_base_rt_id = p_acty_base_rt_id;  --Bug 4143012 get the correct rate
   --
   cursor c_acty_base_rt  is
     select element_type_id,rate_periodization_rl
     from   ben_acty_base_rt_f abr
     where  abr.acty_base_rt_id = p_acty_base_rt_id
     and    l_effective_date between abr.effective_start_date
            and abr.effective_end_date;
  --
  cursor c_rt_strt_dt(p_enrt_rt_id NUMBER) is
    select enr.rt_strt_dt
    from ben_enrt_rt enr
    where enrt_rt_id = p_enrt_rt_id;
  l_rt_strt_dt date;
  --

  l_enrt_rt    c_enrt_rt%rowtype;
  l_global_asg_rec ben_global_enrt.g_global_asg_rec_type;
  --GEVITY
  l_assignment_id   NUMBER;
  l_payroll_id      NUMBER;
  l_organization_id NUMBER;
  l_rate_periodization_rl NUMBER;
  l_dfnd_dummy number;
  l_ann_dummy  number;
  l_cmcd_dummy number;
  --END GEVITY
  l_trace_param          varchar2(30);
  l_trace_on             boolean;
  --
begin
  l_trace_param := null;
  l_trace_on := false;
  --
  l_trace_param := fnd_profile.value('BEN_SS_TRACE_VALUE');
  --
  if l_trace_param = 'BENACTBR' then
     l_trace_on := true;
  else
     l_trace_on := false;
  end if;
  --
  if l_trace_on then
    hr_utility.trace_on(null,'BENACTBR');
  end if;
  --
  hr_utility.set_location('l_trace_param : '|| l_trace_param, 5);
  hr_utility.set_location ('Entering '||l_package,10);
  --
  ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);

  if p_calc_only_rt_val_flag = 'Y' then
     l_calc_only_rt_val_flag := true;
  end if;
  -- This procedure calls the date calculation routine to get the defined, annual
  -- and communicated rate values when a coverage value was entered in self-service.

  ben_determine_activity_base_rt.main
  (p_person_id                  => p_person_id
  ,p_elig_per_elctbl_chc_id     => p_elig_per_elctbl_chc_id
  ,p_enrt_bnft_id               => p_enrt_bnft_id
  ,p_acty_base_rt_id            => p_acty_base_rt_id
  ,p_effective_date             => p_effective_date
  ,p_lf_evt_ocrd_dt             => p_lf_evt_ocrd_dt
  ,p_perform_rounding_flg       => true
  ,p_calc_only_rt_val_flag      => l_calc_only_rt_val_flag -- to get cmcd, must be false.
  ,p_pl_id                      => p_pl_id    -- when calc_only_rt_val_flag is false,
  ,p_oipl_id                    => p_oipl_id  -- pl, oipl, pl_typ id's can be null.
  ,p_pgm_id                     => p_pgm_id
  ,p_pl_typ_id                  => p_pl_typ_id
  ,p_per_in_ler_id              => p_per_in_ler_id
  ,p_ler_id                     => p_ler_id
  ,p_bnft_amt                   => p_bnft_amt
  ,p_business_group_id          => p_business_group_id
  ,p_called_from_ss             => true --6314463
  ,p_val                        =>  p_val
  ,p_mn_elcn_val                => l_dummy_num
  ,p_mx_elcn_val                => l_dummy_num
  ,p_ann_val                    =>  p_ann_val
  ,p_ann_mn_elcn_val            => l_dummy_num
  ,p_ann_mx_elcn_val            => l_dummy_num
  ,p_cmcd_val                   =>  p_cmcd_val
  ,p_cmcd_mn_elcn_val           => l_dummy_num
  ,p_cmcd_mx_elcn_val           => l_dummy_num
  ,p_cmcd_acty_ref_perd_cd      => l_dummy_char
  ,p_incrmt_elcn_val            => l_dummy_num
  ,p_dflt_val                   => l_dummy_num
  ,p_tx_typ_cd                  => l_dummy_char
  ,p_acty_typ_cd                => l_dummy_char
  ,p_nnmntry_uom                => l_dummy_char
  ,p_entr_val_at_enrt_flag      => l_dummy_char
  ,p_dsply_on_enrt_flag         => l_dummy_char
  ,p_use_to_calc_net_flx_cr_flag=> l_dummy_char
  ,p_rt_usg_cd                  => l_dummy_char
  ,p_bnft_prvdr_pool_id         => l_dummy_num
  ,p_actl_prem_id               => l_dummy_num
  ,p_cvg_calc_amt_mthd_id       => l_dummy_num
  ,p_bnft_rt_typ_cd             => l_dummy_char
  ,p_rt_typ_cd                  => l_dummy_char
  ,p_rt_mlt_cd                  => l_dummy_char
  ,p_comp_lvl_fctr_id           => l_dummy_num
  ,p_entr_ann_val_flag          => l_dummy_char
  ,p_ptd_comp_lvl_fctr_id       => l_dummy_num
  ,p_clm_comp_lvl_fctr_id       => l_dummy_num
  ,p_ann_dflt_val               => l_dummy_num
  ,p_rt_strt_dt                 => l_dummy_date
  ,p_rt_strt_dt_cd              => l_dummy_char
  ,p_rt_strt_dt_rl              => l_dummy_num
  ,p_prtt_rt_val_id             => l_dummy_num
  ,p_dsply_mn_elcn_val          => l_dummy_num
  ,p_dsply_mx_elcn_val          => l_dummy_num
  ,p_pp_in_yr_used_num          => l_dummy_num
  ,p_ordr_num                   => l_dummy_num
  ,p_iss_val                    => l_dummy_num);

  hr_utility.set_location ('Output Values From  ben_determine_activity_base_rt.main '||l_package,900);
  hr_utility.set_location ('  p_val: '||p_val,900);
  hr_utility.set_location ('  p_ann_val: '||p_ann_val,900);
  hr_utility.set_location ('  p_cmcd_val: '||p_cmcd_val,900);

  --
  if p_enrt_bnft_id is not null then
     --
     open c_enrt_rt;
     fetch c_enrt_rt into l_enrt_rt;
     close c_enrt_rt;
     if l_enrt_rt.rt_mlt_cd = 'SAREC' then
       --
       open c_acty_base_rt;
         fetch c_acty_base_rt into l_element_type_id,l_rate_periodization_rl;
       close c_acty_base_rt;
       /* Replaced with ben_element_entry.get_abr_assignment call
       ben_global_enrt.get_asg  -- assignment
         (p_person_id              => p_person_id
         ,p_effective_date         => l_effective_date -- Bug 2407041 p_effective_date
         ,p_global_asg_rec         => l_global_asg_rec);
       */
       --
       ben_element_entry.get_abr_assignment
         (p_person_id       => p_person_id
         ,p_effective_date  => l_effective_date
         ,p_acty_base_rt_id => p_acty_base_rt_id
         ,p_organization_id => l_organization_id
         ,p_payroll_id      => l_payroll_id
         ,p_assignment_id   => l_assignment_id
         );
       --
       --GEVITY
       IF l_rate_periodization_rl IS NOT NULL THEN
         --
         ben_distribute_rates.periodize_with_rule
              (p_formula_id             => l_rate_periodization_rl
              ,p_effective_date         => l_effective_date
              ,p_assignment_id          => l_assignment_id
              ,p_convert_from_val       => p_bnft_amt
              ,p_convert_from           => 'ANNUAL'
              ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
              ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
              ,p_business_group_id      => l_enrt_rt.business_group_id
              ,p_enrt_rt_id             => l_enrt_rt.enrt_rt_id
              ,p_ann_val                => l_dfnd_dummy
              ,p_cmcd_val               => p_cmcd_val
              ,p_val                    => l_dfnd_dummy
              );
         --
       ELSE
         -- 5534498
         open c_rt_strt_dt(l_enrt_rt.enrt_rt_id);
         fetch c_rt_strt_dt into l_rt_strt_dt;
         close c_rt_strt_dt;
         --
         p_cmcd_val := ben_distribute_rates.annual_to_period
              (p_amount                  => p_bnft_amt,
               p_enrt_rt_id              => l_enrt_rt.enrt_rt_id,
               p_acty_ref_perd_cd        => l_enrt_rt.cmcd_acty_ref_perd_cd,
               p_business_group_id       => p_business_group_id,
               p_effective_date          => p_effective_date,
               p_use_balance_flag        => 'Y',
               p_payroll_id              => l_payroll_id,
               p_element_type_id         => l_element_type_id,
               -- 5534498
               p_person_id               => p_person_id,
               p_start_date              => l_rt_strt_dt
              );
         --
       END IF; --GEVITY
      --
    end if;
    --
  end if;

  hr_utility.set_location ('Output Values: '||l_package,900);
  hr_utility.set_location ('  p_val: '||p_val,900);
  hr_utility.set_location ('  p_ann_val: '||p_ann_val,900);
  hr_utility.set_location ('  p_cmcd_val: '||p_cmcd_val,900);

  hr_utility.set_location ('Leaving '|| l_package,999);
  --
  if l_trace_on then
    hr_utility.trace_off;
    l_trace_param := null;
    l_trace_on := false;
  end if;

exception
  --
  when others then
    --
    p_val            := null;
    p_ann_val        := null;
    p_cmcd_val       := null;
    fnd_msg_pub.add;
    if l_trace_on then
      hr_utility.trace_off;
      l_trace_on := false;
      l_trace_param := null;
    end if;
end main_w;
end ben_determine_activity_base_rt;

/
