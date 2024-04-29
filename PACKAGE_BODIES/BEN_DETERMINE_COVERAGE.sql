--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_COVERAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_COVERAGE" as
/* $Header: bencvrge.pkb 120.31.12010000.13 2010/03/10 14:15:42 sagnanas ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name:
   Determine Coverage

Purpose:
   Determines proper coverages based on mlt_cd.  Writes to BEN_ENRT_BNFT table.

History:

        Date             Who        Version    What?
        ----             ---        -------    -----
        7 May 98        Ty Hayden   110.0      Created.
       16 Jun 98        Ty Hayden   110.1      Do not error when coverage
                                               not found.
       16 Jun 98        T Guy       110.2      Removed other exception.
       22 Jun 98        Ty Hayden   110.3      Added Mn,Mx,Incr,and Val edits.
       25 Jun 98        T Guy       110.4      Replaced all occurrences of
                                               PER10 with PERTEN.
       11 Aug 98        Ty Hayden   110.5      Added mlt cd NSVU
       08 Oct 98        T Guy       115.3      Added schema changes for ben_enrt_bnft
                                               Added message numbers and debugging
                                               messages.
       12 Oct 98        T Guy       115.4      Added mlt cd SAAEAR.  Added dflt_val
                                               logic.
       22 Oct 98        T Guy       115.5      removed show errors statement
       23 Oct 98        T Guy       115.6      added new column for write coverage
                                               p_comp_lvl_fctr_id
                                               p_cvg_mlt_cd
                                               p_entr_val_at_enrt_flag
                                               p_mx_val
                                               p_mn_val
                                               p_incrmt_val
                                               p_rt_typ_cd
       04 Nov 98        T Guy       115.7      fixed SAEER mlt_cd and local variable
                                               assignment in calculate_val (val2).
                                               Added g_record_error if person does
                                               not have compensation.  This will role
                                               back all records associated with this
                                               person.
      05 Nov 98         T Guy       115.8      Added logic to treat %RNG% mlt cd as
                                               FLFX when vr trtmnt cd is RPLC.
      16 Nov 98         T Guy       115.9      Added lower/upper limit value and rule
                                               checking.  Removed post_write Procedure
                                               as this logic has been added to the
                                               write_coverage procedure.
      24 Nov 98         T Guy       115.10     Fixed undefined upr/lwr rule checking
      02 Dec 98         T Guy       115.11     Fixed set_token error for null
                                               compensation
      16 Dec 98         T Guy       115.12     No Change.
      18 Dec 98         T Guy       115.13     Restructured looping for RNG cvg mlt cds
                                               Fixes bug 1568.
      18 Dec 98         T Guy       115.14     Removed ^m characters.
      22 Dec 98         T Guy       115.15     Fixed bug 1563. when val is null added
                                               check for entr_val_at_enrt_flag being off
      18 Jan 99         G Perry     115.16     LED V ED
      16 Feb 99         T Guy       115.17     Fixed bugs 1819, 1820
      16 Feb 99         T Guy       115.18     Took out nocopy show errors statement
      24 Feb 99         T Guy       115.19     Added level jumping and ctfn checking
      26 Feb 99         T Guy       115.20     Fixed NSVU for bug 1820.
      26 Feb 99         T Guy       115.21     Fixed error with ordr_num values
      09 Mar 99         G Perry     115.23     IS to AS.
      29 Mar 99         T Guy       115.24     Added default val to write_coverage
      28 Apr 99         Shdas       115.25     Added contexts to rule
                                               calls(genutils.formula).
      29 Apr 99         lmcdonal    115.26     prtt_enrt_rslt now has status code.
      07 may 99         Shdas       115.27     Added calls(genutils.formula) to
                                               mn_cvg_rl,mx_cvg_rl.
      14 May 99         G Perry     115.28     Added logic to check for PLIP
                                               and then PL if PLIP not found.
      17 May 99         T Guy       115.29     Fixed call to elctbl_chc_ctfn_api.
      19 May 99         T Guy       115.30     Make version match header. removed
                                               entr_val_at_enrt check for %RNG% codes
      19 May 99         T Guy       115.31     Write DFLT_VAL only when entr_val_at_enrt
                                               Fixed cursor to pick up dflt_flag from
                                               chc instead of cvg_calc_mthd.
       1 Jul 99         T Guy       115.32     Added rt_typ_cd of PERHNDRD
       1 Jul 99         lmcdonal    115.33     Moved check_val (limit_checks) and
                                               calcuate_val (rt_typ_calc)
                                               to genutils.
       9 Jul 99         mhoyes      115.34     Added trace messages.
      16 Jul 99        lmcdonal     115.35     limit_checks parms changed.
      20-JUL-99         Gperry      115.36     genutils -> benutils package
                                               rename.
      22-JUL-99         mhoyes      115.37   - Added new trace messages.
                                             - Replaced all + 0s.
      07-Sep-99         tguy        115.38     fixed calls to pay_mag_util
      21-sep-99         tguy        115.39     added check for dflt_enrt_cd for
                                               dflt_val assignemnt
      04-OCT-99         mhoyes      115.40   - Modified code BENEFIT to BNFT.
                                             - Tuned cursors. Replaced
                                               c_cvg_plip, c_cvg_pln and
                                               c_cvg_oipl with calls to
                                               ben_cvg_cache.epeplncvg_getdets.
      04-OCT-99         tguy        115.41   - added call to dt_fndate.
      13-OCT-99         tguy        115.42   - moved increment value outside of
                                               if statement. this fixed bug 3692
      14-OCT-99         maagrawa    115.43   Modified level jumping logic.
                                             Major change in chk_bnft_ctfn
                                             procedure.
      02-Nov-99         maagrawa    115.44   Made call to BEN_DETERMINE_CHC_CTFN
                                             .write_ctfn to write level jumping
                                             ctfns for the benefit records.
      15-Nov-99         mhoyes      115.45 - Added trace messages.
      19-Nov-99         pbodla      115.46 -  p_elig_per_elctbl_chc_id parameter
                                             passed to benutils.limit_checks
                                           - p_elig_per_elctbl_chc_id parameter
                                             added to chk_bnft_ctfn proc and all
                                             it's calls.
                                           - Passed p_elig_per_elctbl_chc_id to
                                             all benutils.formula calls.
      29-Nov-99         jcarpent    115.47 - Added call to det._dflt_enrt_cd
      07-Dec-99         jcarpent    115.48 - Assign defaults for flat fixed.
      06-Jan-00         maagrawa    115.49 Modified chk_bnft_ctfn to look for
                                           mx_cvg_alwd_amt for ctfns.(1142060)
      19-Jan-00         tguy        115.50   Added check for rounding when vrbl
                                             rt trtmt cd = rplc do not round at
                                             value at this level.  Fixed error
                                             message for null or zero comp.
      20-Jan-00         thayden     115.51   Added prtt_enrt_rslt_id. bug 1146784
      05-Feb-00         maagrawa    115.52   Fixed chk_bnft_ctfn (4392)
                                             shdas-(1166169)
      18-Feb-00         jcarpent    115.53   Make choice not eligible if bnft
                                             is at max. and already have bnft.
      22-Feb-00         shdas       115.54   Added codes for crntly_enrld_flag(1198551)
      25-Feb-00         jcarpent    115.55   Close cursor problem c_other_pl_cvg.
      26-Feb-00         thayden     115.56   If mlt_cd is Range, don't copy min,max,
                                             incrmt,dflt to enrt benefit.
      03-Mar-00         maagrawa    115.57   Created a new procedure write_ctfn
                                             within the procedure main.
                                             Always check for certs. when the
                                             min. and max. benefit amounts are
                                             defined.(1198549).
      16-Mar-00         jcarpent    115.58   Added logic to handle ptips which
                                             have plans with options and
                                             maximums are reached. (1238601)
      30-Mar-00         jcarpent    115.59   Cvg_mlt_cd's of saaear and nsvu
                                             always had dflt_flag of N, changed
                                             to use l_epe.dflt_flag.  Also
                                             was giving two default sometimes
                                             changed default conditions.
                                             bug 1252087/4983.
      31-Mar-00         mmogel      115.60   Added tokens to messages to make the
                                             messages more meaningful to the user
      14-Apr-00         jcarpent    115.61   For all but RNG, write coverage if
                                             it's above the max but then update
                                             the choice to be not electable. (5095)
      09-May-00         lmcdonal    115.62   ctfn's at the option level are written
                                             in benchctf.pkb. don't write them at
                                             the bnft level too.  Bug 1277371.
      12-May-00         lmcdonal    115.63   Bug 1249901 - when coverage is entered
                                             at enrollment, we don't know if ctfns
                                             are required until during enrt.  Write
                                             ctfn records, load new mx_wout_ctfn
                                             field.  Also override cvg-calc-mx
                                             with rstrn-mx-with-ctfn val when writing
                                             enrt-bnft row.
     14-May-00          shdas       115.64   Bug 5152.Moved rounding function from
                                             write coverage  to main so that cvg value gets
                                             rounded before applying variable profile.
     18-May-00          jcarpent    115.65   Bug 5209. If choice is updated to be
                                             not electable also make not the default.
                                             Also, deenroll from the result if
                                             above the max.
     24-May-00          tmicheal    115.66   bug 4844  fixd
     05-Jun-00          stee        115.67   When writing certifications, do
                                             not restrict by the
                                             bnft_or_option_retrctn_cd.  There
                                             is a check in the write_ctfn
                                             procedure for duplicate
                                             certification. wwbug #1308629.
    20-Jul-00           bbulusu     115.68   Bug Fix 5368. Was not checking
                                             for enter at enrollment when
                                             comparing enrolled benefit amount
                                             to null computed value.
    25 Sep 00           mhoyes      115.69 - Commented out nocopy highly executed hr_utility
                                             .set_locations.
    07 Nov 00           mhoyes      115.70 - Referenced electable choice performance
                                             APIs.
                                           - Referenced comp object loop electable
                                             choice context globals.
    22 Nov 00           mhoyes      115.71 - Forward port of 1473060 on 115.69.
    22 Nov 00           mhoyes      115.72 - Reinstated 115.70.
    21 Nov 00           jcarpent    115.73 - bug 1470467. Check for provided
                                             ctfns if over max.  Leapfrog
                                             based on 115.69
    22 Nov 00           jcarpent    115.74 - Merged version with 115.70 and 115.71.
    23-Jan-01           mhoyes      115.75 - Added calculate only mode for EFC.
    21-Feb-01           kmahendr    115.76 - Bug#1569790 - Benefit row is inserted
                                             for interim coverage if multi_cd is Flat
                                             amt with enter value at enrollment flag on
    22-Mar-01           mhoyes      115.77 - Called epecobjtree_getcvgdets to get l_cvg.
    27-mar-01           tilak       115.78 - bug : 1433393 ,ultm lwr limit and upr limit
                                             column added in vapro
                                             the resilt of vapro and cvg validated against the
                                             ultiamte limit
   03-apr-01           tilak        115.79   bug : 1712464 ultm lwr limit rl,and upr limit rl
                                             added
   02-Aug-01           ikasire      115.80   Bug 1895846 fixes for suspended enrollments
   02-Aug-01           ikasire      115.81   to add modification history for 115.80
   28-Aug-01           kmahendr     115.82   Bug#1936976-result_id is populated based on
                                             benefit amount
   29-aug-01           tilak        115.83   bug:1949361 jurisdiction code is
                                              derived inside benutils.formula.
   27-Sep-01           kmahendr     115.84   Bug#1981673-Added parameter ann_mn_elcn_val and
                                             ann_mx_elcn_val to ben_determine_variable_rates
                                             call
   02-nov-01           tjesumic     115.85   bug :  2083726 fixed , if variable rate define
                                             and the treatment code is replace then
                                            default valu , increment value , min , max taken from
                                            variable rate
   14-nov-01           tjesumic     115.86  DBDRV added
   21-nov-01           tjesumic     115.87  default valu , increment value , min , max taken from
                                            variable rat for REPLC , SF ,  ADDTO,MB
   21-nov-01           tjesumic     115.88  correction in REPLC , SF ,  ADDTO,MB calculation
   28-Dec-01           jcarpent     115.89 - Bug:2157614: Altered cursor
                                             c_other_oipls_in_plan_type for
                                             performance issue.
   28-Dec-01           jcarpent     115.90 - Bug#1910867: Fixed code to handle
                       dschwart/cdaniels     condition when the maximum amount is NULL.

   28-Dec-01           dschwart/    115.91 - Bug#2054078: Max Coverage without certification
                       BBurns/jcarpent       was not showing up on form because it was not
                                             being written to ben_enrt_bnft.  Made modifications
                                             to chk_bnft_ctfn_val parameters + related code to
                                             fix this.
   26-Mar-02           kmahendr     115.92 - Bug#1833008 - Added parameter p_cal_for to the call
                                             determine_compensation to handle multi-assignment.
   22-Apr-02           hnarayan     115.92   Bug 2319790 - changed chk_bnft_ctfn procedure
   29-May-02           shdas        115.93   Bug 2325109 - Message token not sho                                             wing values.
   08-Jun-02           pabodla      115.94   Do not select the contingent worker
                                             assignment when assignment data is
                                             fetched.
   08-AUg-02           ikasire      115.95   Bug 2502633 Interim Enhancements
                                             Added logic to create additional benefit
                                             row for the purpose of interim enrollment.
   03-Sep-02           ikasire      115.96   Bug 2543071 interim codes Current Same Option
                                             in plan typo.wrong parameter passed.
   05-Sep-02           ikasire      115.97   Bug 2551711 Getting default amount instead of
                                             getting min amount for interim
   06-Sep-02           ikasire      115.98   need to populate current pen_id on the
                                             enb record created for SAME case
   13-Sep-02           tjesumic     115.99   if the dflt enrt cd is rule and global variable
                                             g_dflt_elctn_val has the value  then the global
                                             value is used for default value,global value
                                             is populated in bendenrr # 2534744
   17-Sep-02           hnarayan     115.100  bug 2560721 - added code for setting dflt_flag
                         when coverage is Flat Range , for new enrollments
   28-Sep-02           ikasire      115.101  Bug 2600087 added nvl(p_lf_evt_ocrd_dt,
                                             p_effective_date) to the cursors
   18-Dec-02           mmudigon     115.102  Bug 2708100 Changes to Flat Range
                                             (FLRNG) calculations.
                                             Old Flat Rng :
                                             Min ---> Max
                                             New Flat Rng :
                                             Lower Limit --> Upper Limit
   23-DEC-02           lakrish      115.104  NOCOPY changes
   03-Jan-03           kmahendr     115.105  Bug#2708285 - the limit is checked after adding
                                             the flat amount for CLPFLRNG calculation
   15-Jan-03           tjesumic     115.106  bug#2736519 new parameter added in chk_bnft_ctfn
                                              p_no_mn_cvg_amt_apls_flag,p_no_mx_cvg_amt_apls_flag
                                             if the max is 'Y' the l_mx_amt is not validated
   10-Mar-03           pbodla       115.107  If the coverage calculation method
                                             is rule then pass the option id
                                             by fetching it if it's not already
                                             fetched.
   13-Aug-03           kmahendr     115.108  Added cvg_mlt_cd ERL
   14-Aug-03           vsethi       115.109  Bug#3095224 - the limit is checked after adding
                                             the flat amount for FLFXPCL, FLPCLRNG calculation
   25-Aug-03           kmahendr     115.111  Bug#3108422 - ctfn calls made for RL and ERL
   26-Aug-03           kmahendr     115.112  Bug#3108422 - ctfn_rqd_flag changed for ERL
   02-Oct-03           ikasire      115.113  Bug#3132792 - Enrollment is not suspending if
                                             certification was received for the plan in
                                             lower amount.
   31-Oct-03           kmahendr     115.114  Bug#3230649 - added primary_flag condition and
                                             order by in cursors c_asg.
   15-Mar-04           rpgupta      115.115  Bug 3497676 - Allow a 0 coverage to be created
   08-Apr-04           kmahendr     115.116  Bug3560065 - check for other_pl_cvg removed

   17-Mar-04           pbodla       115.117  FONM : use cvg_strt_dt changes .
   22-Apr-04           kmahendr     115.118  Bug#3585768 - limitation check removed
   01-Jul-04           ikasire      115.119  Bug 3695079 We need to take the min of
                                             mx with cert and increases plus current benefit
                                             amount in deriving the max with cert amount
   09-Aug-04           kmahendr     115.120  Bug#3772179 - Max without certification is
                                             assigned a value in chk_bnft_ctfn.
   05-Aug-04           tjesumic     115.121  FONM for ben_derive_factors fonm date paseed as param
   17-Aug-04           hmani        115.122  Added newly added lookup codes 3806262
   23-Aug-04           mmudigon     115.123  Excluding sspndd enrollmets in
                                             cursor c_current_enrt
                                             2534391 :NEED TO LEAVE ACTION ITEMS
   15-Nov-04           kmahendr     115.124  Unrest. enh changes
   01-Dec-04           abparekh     115.125  Bug 3828288 : For Flat Amount Calc Method consider Max Amount
                                             as minimum of CCM Max, PLN Max WCfn, ( Current + PLN Max Incr WCfn )
  01-dec-04            kmahendr     115.126  Unrest. enh changes
   27-Dec-04           abparekh     115.127  Bug 3828288 : For Flat Amount Calc Method consider Max Increase
                                             Amount only for Currently Enrolled records.
   11-Jan-05           ikasire      115.128  CF Interim Suspended BUG 4064635 Multiple Changes
   18-Jan-05           ikasire      115.129  CF Interim Suspended more changes
   01-Feb-05           ikasire      115.130  CF Changes for 'SM' case
   23-Feb-05           kmahendr     115.131  p_calculate_only_mode added not to
                                             create_enrt_bnft when the value is false
   07-Mar-05           ikasire      115.132  Bug 4223840 Flat Fixed Enter Value at enrollment
                                             issue with mx_wout_ctfn_val issue
   25-Mar-05           ikasire      115.133  Bug 4262970. Default is not identified properly in the
                                             subsequent life event.
   27-Mar-05           ikasire      115.134  Bug 4262970 - extend the fix to other flat range codes
   28-Mar-05           kmahendr     115.135  Bug#4256191 - least of max, upper_limit_value
                                             sent to get_least_val procedure
   30-Mar-05           kmahendr     115.136  Bug#4256191 - rule evaluated before
                                             determining the least amount
   18-Apr-05           ssarkar      115.137  Bug# 4275929 : max_witout_cert is passed to max_with_cert ,
                                             when null, while calling get_least_value proc.
   06-jun-05           nhunur       115.138  4383988 - apply fnd_number on what FF returns in numeric variable.
   30-Jun-05           ikasire      115.139  BUG 4449437 always setting the default flag to N for FLFXPCL
   19-jul-05	       rgajula      115.140  Bug 4436573 Added a new parameter p_cvg_mlt_cd to the
                                             ben_determine_coverage.chk_bnft_ctfn to perform few more
                                             validations to set the certification required flag of ben_enrt_bnft.
   25-Sep-05           kmahendr     115.141  Bug#4630782 - in unrestricted mode inelig
                                             process not called
   27-Sep-05           ikasire      115.142  Bug 4627840
   04-Oct-05           ikasire      115.143  Bug 4649262 ERL fix regression from 4436573
   20-oct-05           rgajula      115.144  Bug 4644489 Added an additional parameter p_rstrn_mn_cvg_rqd_amt
					     ben_determine_coverage.chk_bnft_ctfn to return the minimum coverage amount
					     as calculated by the minium rule in coverage restrictions, the out parameter will
					     will return the amount as calculated by the rule or the min value in the min feild in retrictions.
					     This returned value is used in the write record for Flat Amount Calculation method as
					     max(cvg_rstrn_amount,cvg_calc_mthd_min_amnt).
   16-Jan-06           abparekh     115.145  Bug 4954541 : Unrestricted : If coverage does not exist, then delete
                                                           corresponding BEN_ENRT_BNFT record
   11-Apr-06           bmanyam     115.147  5105118 changes (115.146) are undone
                                            This is leapfrog of 115.145.
                                            5105118 is not-a-bug.
   May 24, 2006        rgajula     115.148  Bug 5236985 Added the l_cvg_rstn_max_with_cert not null condition
  					    This necessary if the l_rstrn.mx_cvg_wcfn_amt is
					    made null in the subsequent life event
   28-Jun-2006         swjain      115.149  Bug 5331889 Added person_id param to mn_cvg_rl and mx_cvg_rl
                                            in procedure chk_bnft_ctfn
   11-Aug-2006         nhunur      115.150  Ult Lower limit value rule is not honoured
   28-sep-2006         ssarkar     115.151 bug 5529258 : interim rule to be evaluated
   29-sep-2006         ssarkar     115.152 5529258 : more fix
   4-Oct-2006          rgajula     115.154 Bug 5573274 : Populated the mx_wout_ctfn value for Flat Range.
   12-Oct-2006         ikasired    115.154 Bug 5596918 fix for 'SAME' part in carryforward. bnft amt null issue
   12-Oct-2006         ikasired    115.154 Bug 5596907 fix for carryforward to use right bnft record
   3-Nov-2006          rgajula     115.156 Bug 5637851 : Added nvl clauses in chk_bnft_ctfn.
   27-Nov-2006         rgajula     115.157 Bug 5679097: Fix of regression for bug 5637851
   23-Feb-2007         swjain      115.158 Bug 5887665: Passed ctfn_determine_cd in call to
                                           ben_determine_chc_ctfn.write_ctfn in procedure main
   02-Mar-2007         ssarkar     115.159 Bug 5900235 : write_ctfn to be called for RL if ctfn_rqd is true
   22-Mar-2007         rgajula     115.161 Bug 5942733 : Removed the NVL clause which was causing the max_wout_cert to be set to max and causing unnecessary UI issues.
   28-Mar-2007         swjain      115.162 Bug 5933576 : Added code in procedure main to check benefit certifications for 'NSVU' calculation method as well
   30-Mar-2007         swjain      115.163 Bug 5933576 : When vr_val is null, then set it to default val in procedure main
   17-May-2007         rtagarra    115.164 Bug 6054310 : Moved the condition added in 115.163 to NSVU Case only.
   22-may-2007         nhunur      115.165 6066580: FLFXPCL do rounding after addition of flat amount
   20-Jun-2007         rtagarra    115.166 Bug 6068097 : Made changes for the code NSDCS and NNCS.
   04-Jul-2007         rtagarra    115.167 Bug 6164688 : For codes 'INCRCTF','DECRCTF' no need to check for order_number for calculation.
   24-Oct-2007         bmanyam     115.168 6502657 :
                                   If Coverage of more than one option
                                   in same Plan is reduced due to
                                   Upper Limit, then only one of
                                   them is retained as Electable.
   25-Oct-2007         sshetty     Fixed bug 6523477
   12-May-2008                     For bug 7004909, changed the default value of coverage amount that was being passed to write coverages function for the type
                                    Multiple of compensation
   23-Jan-2009         sallumwa    Bug 7490759 :Modified the cursor c_cf_bnft_result to fetch the correct suspended
                                   result ID when FONM and Event date LE's are processed in the same month.
   02-Feb-2009         sallumwa    115.172    Bug 7704956 : Modified the procedure main to update the
                                              currently_enrld_flag in ben_enrt_bnft table to 'Y' when the
					      benefit amount matches if multiple rows are set to 'Y' corresponding
					      to one elig_per_elctbl_chc_id.
   11-Feb-2009         velvanop    115.173    Bug 7414757: Added parameter p_entr_val_at_enrt_flag.
	                                      VAPRO rates which are 'Enter value at Enrollment', Form field
					      should allow the user to enter a value during enrollment.
   04-May-2009	       sallumwa    115.174    Bug 8453712 : Modified cursor c_cf_bnft_result to carry forward the latest pen row.
   02-Jun-2009         sagnanas    115.175    8567963 - Modified cursor c_cf_bnft_result
   09-Jun-2009         krupani     115.176    Bug 8568862 : For NSVU, default cvg value was not getting considered. Fixed the same.
   29-Jun-2009         sallumwa  120.31.12010000.9             Bug 8716693 : Enhancement
                                              EOI Does not Carry Forward for Life Events that Dont have EOI Configuration
   05-Aug-2009         sallumwa  120.31.12010000.10   Bug 8767376 : Handled the Flat Range cases for the coverage for the above Enhancement
   20-Oct-2009         krupani   120.31.12010000.11   Bug 9008389 : 12.1 forward port of 8940075
   07-Feb-2009         sallumwa  120.31.12010000.12   Bug 9308931 : Extended the fix done for the bug 7704956 to
                                                      OAB life events also.
   10-Mar-2010         sagnanas  120.31.12010000.13   Bug 9434155 : Handled currently_enrld_flag and defaulting case for CLRNG
 */
-------------------------------------------------------------------------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_determine_coverage';
g_old_val number;
--
--
FUNCTION round_val
     (p_val                   in number,
     p_effective_date         in date,
     p_lf_evt_ocrd_dt         in date,
     p_rndg_cd                in varchar2,
     p_rndg_rl                in number) return number is
--
  l_package varchar2(80) := g_package||'.round_val';
  l_val number;
BEGIN
   --
   hr_utility.set_location ('Entering '||l_package,10);
   --
   if (p_rndg_cd is not null  or
       p_rndg_rl is not null) then
      --
      l_val := benutils.do_rounding
        (p_rounding_cd     => p_rndg_cd,
         p_rounding_rl     => p_rndg_rl,
         p_value           => p_val,
         p_effective_date  => nvl(p_lf_evt_ocrd_dt,p_effective_date));
     --
   else
     --
     l_val := p_val;
     --
   end if;
   return l_val;
   hr_utility.set_location ('Leaving '||l_package,10);
   --
END round_val;
--
------------------------------------------------------------------------------
--
-- PROCEDURE GET_LEAST_VALUE
-- Bug 3828288
-- This procedure will return following values :
--    p_mx_val_wcfn := Minimum ( p_ccm_max_val, p_cvg_rstn_max_with_cert, p_cvg_rstn_max_incr_with_cert  )
--    p_mx_val_wo_cfn := Minimum ( p_ccm_max_val, p_cvg_rstn_max_wout_cert, p_cvg_rstn_max_incr_wout_cert  )
--
------------------------------------------------------------------------------
PROCEDURE get_least_value ( p_ccm_max_val                 in number,
                  p_cvg_rstn_max_incr_with_cert in number,
                  p_cvg_rstn_max_with_cert      in number,
                  p_cvg_rstn_max_incr_wout_cert in number,
                  p_cvg_rstn_max_wout_cert      in number,
                  p_mx_val_wcfn                 out nocopy number,
                  p_mx_val_wo_cfn               out nocopy number
                 )
IS
BEGIN
  --
  --
  if p_ccm_max_val is not null
  then
    p_mx_val_wcfn := nvl ( least ( p_ccm_max_val, p_cvg_rstn_max_with_cert, p_cvg_rstn_max_incr_with_cert  ),
                           nvl ( least ( p_ccm_max_val, p_cvg_rstn_max_incr_with_cert ) ,
                                 nvl ( least ( p_ccm_max_val, p_cvg_rstn_max_with_cert ) ,
                                       p_ccm_max_val
                                     )
                                )
                          );
    p_mx_val_wo_cfn := nvl ( least ( p_ccm_max_val, p_cvg_rstn_max_wout_cert, p_cvg_rstn_max_incr_wout_cert  ),
                           nvl ( least ( p_ccm_max_val, p_cvg_rstn_max_incr_wout_cert ) ,
                                  least ( p_ccm_max_val, p_cvg_rstn_max_wout_cert )  -- Bug 5942733
                                )
                          );
  else
    p_mx_val_wcfn := nvl ( least ( p_cvg_rstn_max_with_cert, p_cvg_rstn_max_incr_with_cert  ),
                           nvl ( p_cvg_rstn_max_with_cert,
                                 p_cvg_rstn_max_incr_with_cert
                                )
                          );
    p_mx_val_wo_cfn := nvl ( least ( p_cvg_rstn_max_wout_cert, p_cvg_rstn_max_incr_wout_cert  ),
                           nvl ( p_cvg_rstn_max_wout_cert,
                                 p_cvg_rstn_max_incr_wout_cert
                                )
                          );
  end if;
  --
END;

---------------------------------------------------
--
--  Write ben_enrt_bnft
--
---------------------------------------------------
--
PROCEDURE write_coverage
  (p_calculate_only_mode    in     boolean default false
  ,p_bndry_perd_cd          in     varchar2
  ,p_bnft_typ_cd            in     varchar2
  ,p_val                    in     number
  ,p_dflt_flag              in     varchar2
  ,p_nnmntry_uom            in     varchar2
  ,p_elig_per_elctbl_chc_id in     number
  ,p_business_group_id      in     number
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date
  ,p_person_id              in     number
  ,p_lwr_lmt_val            in     number
  ,p_lwr_lmt_calc_rl        in     number
  ,p_upr_lmt_val            in     number
  ,p_upr_lmt_calc_rl        in     number
  ,p_rndg_cd                in     varchar2
  ,p_rndg_rl                in     number
  ,p_comp_lvl_fctr_id       in     number
  ,p_cvg_mlt_cd             in     varchar2
  ,p_entr_val_at_enrt_flag  in     varchar2
  ,p_mx_val                 in     number
  ,p_mx_wout_ctfn_val       in     number
  ,p_mn_val                 in     number
  ,p_incrmt_val             in     number
  ,p_dflt_val               in     number
  ,p_rt_typ_cd              in     varchar2
  ,p_perform_rounding_flg   in     boolean
  ,p_ordr_num               in     number
  ,p_ctfn_rqd_flag          in     varchar2
  --
  ,p_enrt_bnft_id              out nocopy number
  ,p_enb_valrow                out nocopy ben_determine_coverage.ENBValType
  --
  ,p_ultmt_upr_lmt          in    number   default null
  ,p_ultmt_lwr_lmt          in    number   default null
  ,p_ultmt_upr_lmt_calc_rl  in    number   default null
  ,p_ultmt_lwr_lmt_calc_rl  in    number   default null
  ,p_bnft_amount            in    number   default null
  ,p_vapro_exist            in    varchar2 default null
  )
is
  --
  l_enrt_bnft_id number;
  l_object_version_number number;
  l_package varchar2(80) := g_package||'.write_coverage';
  l_old_val number;
  l_val number;
  l_other_cvg number;
  --
  cursor c_asg(cv_effective_date date) is -- FONM
    select asg.assignment_id,asg.organization_id
    from   per_all_assignments_f asg
    where  asg.person_id = p_person_id
    and    asg.primary_flag = 'Y'
    and    asg.assignment_type <> 'C'
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between asg.effective_start_date
           and    asg.effective_end_date
    order  by decode(asg.assignment_type, 'E',1,'B',2,3);
  --
  l_asg c_asg%rowtype;
  --
  cursor c_epe is
    select epe.business_group_id,
           epe.pgm_id,
           epe.pl_id,
           epe.pl_typ_id,
           epe.ptip_id,
           epe.plip_id,
           epe.oipl_id,
           epe.prtt_enrt_rslt_id,
           pil.ler_id,
           epe.object_version_number,
           epe.elctbl_flag,
           epe.per_in_ler_id
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and    epe.per_in_ler_id = pil.per_in_ler_id;
  --
  l_epe c_epe%rowtype;
  --
  /*
  cursor c_det_crnt_enrt(l_rslt_id number) is
     select pen.bnft_amt,
            pen.bnft_ordr_num
     from ben_prtt_enrt_rslt_f pen,
          ben_elig_per_elctbl_chc epe
     where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and    epe.prtt_enrt_rslt_id = l_rslt_id
     and    pen.prtt_enrt_rslt_id = l_rslt_id;
  --
  -- l_det_crnt_enrt c_det_crnt_enrt%rowtype;
  */
  l_crnt_enrld_flag varchar2(30) := 'N';
  --
  -- FONM
  cursor c_opt(cv_oipl_id number, cv_effective_date date) is
    select oipl.opt_id
    from   ben_oipl_f oipl
    where  oipl.oipl_id = cv_oipl_id
    and    cv_effective_date
           between oipl.effective_start_date
           and    oipl.effective_end_date;
  --
  l_opt c_opt%rowtype;
  --
  cursor c_state(cv_effective_date date) is -- FONM
    select region_2
    from   hr_locations_all loc,
           per_all_assignments_f asg
    where  loc.location_id = asg.location_id
    and    asg.person_id = p_person_id
    and    asg.primary_flag = 'Y'
    and    asg.assignment_type <> 'C'
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between asg.effective_start_date
           and     asg.effective_end_date
    and    asg.business_group_id =p_business_group_id
    order  by decode(asg.assignment_type, 'E',1,'B',2,3);
  --
  l_state c_state%rowtype;
  --
  cursor c_other_oipl_cvg is
    select enb.val
    from   ben_elig_per_elctbl_chc epe,
           ben_enrt_bnft enb
    where  epe.pl_id=l_epe.pl_id
       and nvl(epe.pgm_id,-1)=nvl(l_epe.pgm_id,-1)
       and epe.per_in_ler_id=l_epe.per_in_ler_id
       and epe.business_group_id=l_epe.business_group_id
       and enb.elig_per_elctbl_chc_id=epe.elig_per_elctbl_chc_id
       and enb.cvg_mlt_cd=p_cvg_mlt_cd
       and enb.business_group_id=epe.business_group_id
       and enb.val=l_val
    ;
  --
  cursor c_other_pl_cvg is
    select enb.val
    from   ben_elig_per_elctbl_chc epe,
           ben_enrt_bnft enb
    where  epe.ptip_id=l_epe.ptip_id
       and nvl(epe.pgm_id,-1)=nvl(l_epe.pgm_id,-1)
       and epe.per_in_ler_id=l_epe.per_in_ler_id
       and epe.business_group_id=l_epe.business_group_id
       and enb.elig_per_elctbl_chc_id=epe.elig_per_elctbl_chc_id
       and enb.cvg_mlt_cd=p_cvg_mlt_cd
       and enb.business_group_id=epe.business_group_id
       and enb.val=l_val
    ;
  --
  cursor c_other_pl_in_ptip_cvg(cv_effective_date date) is
    select enb.val
    from   ben_elig_per_elctbl_chc epe,
           ben_oipl_f oipl,
           ben_oipl_f oipl2,
           ben_enrt_bnft enb
    where  epe.ptip_id=l_epe.ptip_id
       and nvl(epe.pgm_id,-1)=nvl(l_epe.pgm_id,-1)
       and epe.pl_typ_id=l_epe.pl_typ_id
       and epe.per_in_ler_id=l_epe.per_in_ler_id
       and epe.business_group_id=l_epe.business_group_id
       and oipl.oipl_id=epe.oipl_id
       and oipl.business_group_id=epe.business_group_id
       and cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between
           oipl.effective_start_date and oipl.effective_end_date
       and oipl2.oipl_id=l_epe.oipl_id
       and oipl2.business_group_id=p_business_group_id
       and cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between
           oipl2.effective_start_date and oipl2.effective_end_date
       and oipl2.opt_id=oipl.opt_id  -- why we join to oipls
       and enb.elig_per_elctbl_chc_id=epe.elig_per_elctbl_chc_id
       and enb.cvg_mlt_cd=p_cvg_mlt_cd
       and enb.business_group_id=epe.business_group_id
       and enb.val=l_val
    ;
  --
  cursor c_pl_typ_plip_enrt_limit(cv_effective_date date) is
    select '1', mx_enrd_alwd_ovrid_num
    from ben_ptip_f
    where ptip_id=l_epe.ptip_id
      and business_group_id=l_epe.business_group_id
      and cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between
          effective_start_date and effective_end_date
      and mx_enrd_alwd_ovrid_num is not null
    union
    select '2', mx_enrl_alwd_num
    from ben_pl_typ_f
    where pl_typ_id=l_epe.pl_typ_id
      and business_group_id=l_epe.business_group_id
      and cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
          between
          effective_start_date and effective_end_date
      and mx_enrl_alwd_num is not null
    order by 1
    ;
  /*********************************
        CODE PRIOR TO WWBUG: 2157614
  cursor c_other_oipls_in_plan_type is
    select 'Y'
    from   ben_elig_per_elctbl_chc epe
    where  epe.pl_typ_id=l_epe.pl_typ_id
      and  epe.pl_id<>l_epe.pl_id
      and  nvl(epe.pgm_id,-1)=nvl(l_epe.pgm_id,-1)
      and  epe.oipl_id is not null
      and  epe.business_group_id=p_business_group_id
    ;
   ***************************/
  /* Start of Changes for WWBUG: 2157614                */
  cursor c_other_oipls_in_plan_type(cv_effective_date date) is
    select 'Y'
    from   ben_pl_f pln,
           ben_oipl_f oipl
    where  pln.pl_typ_id=l_epe.pl_typ_id
      and  pln.pl_id<>l_epe.pl_id
      and  cv_effective_date between -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date) between
              pln.effective_start_date and pln.effective_end_date
      and  pln.business_group_id=p_business_group_id
      and  oipl.pl_id=pln.pl_id
      and  oipl.business_group_id=p_business_group_id
      and  cv_effective_date between -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date) between
              oipl.effective_start_date and oipl.effective_end_date
    ;
  /* End of Changes for WWBUG: 2157614          */
  --Unrestricted enh
  cursor c_unrest(p_ler_id  number)  is
    select 'Y'
    from ben_ler_f ler
    where ler.typ_cd = 'SCHEDDU'
    and   ler.ler_id = p_ler_id
    and   p_effective_date between ler.effective_start_date
         and ler.effective_end_date;
  --
  --CF Susp Interim Enhancement
  --
  cursor c_cf_bnft_result(cv_effective_date date) is
  SELECT  pen.prtt_enrt_rslt_id,
          pen.bnft_amt,
          pen.bnft_ordr_num
      FROM     ben_prtt_enrt_rslt_f pen,
               ben_ler_f ler
      WHERE    pen.ler_id = ler.ler_id
      AND      pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      --AND      pen.effective_end_date = hr_api.g_eot
      --8567963
      AND      ((pen.effective_end_date = hr_api.g_eot
      and      ler.typ_cd <> 'SCHEDDU')
       or      ( cv_effective_date between pen.effective_start_date and pen.effective_end_date
      and       ler.typ_cd = 'SCHEDDU'))
      --8567963
      AND      cv_effective_date <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      NVL(l_epe.oipl_id,-1) = NVL(pen.oipl_id,-1)
      AND      l_epe.pl_id   = pen.pl_id
      AND      NVL(l_epe.pgm_id,-1)  = NVL(pen.pgm_id,-1)
      AND      ( pen.bnft_ordr_num = p_ordr_num OR
                 pen.bnft_amt = p_val )
      ----------Bug 7490759
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
  --  order by pen.enrt_cvg_strt_dt,decode(pen.sspndd_flag,'Y',1,2);  --Bug 8453712
  order by pen.enrt_cvg_strt_dt desc,decode(pen.sspndd_flag,'Y',1,2);
  --
  l_cf_bnft_result  c_cf_bnft_result%ROWTYPE;
  --
  l_dummy             varchar2(1);
  l_other_oipls_exist varchar2(30);
  l_enrt_limit        number;
  l_level             varchar2(30);
  l_over_max_level    boolean  := false ;
  l_prtt_enrt_rslt_id  number;
  -- FONM
  l_fonm_cvg_strt_dt   date;


BEGIN
   --
   hr_utility.set_location ('Entering '||l_package,10);
   --
   -- FONM
   if ben_manage_life_events.fonm = 'Y' then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt;
     --
   end if;
   --
   l_val := p_val;
   --
   open c_state(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
     --
     fetch c_state into l_state;
     --
   close c_state;
   hr_utility.set_location ('close c_state ',10);
   --
   open c_asg(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
     --
     fetch c_asg into l_asg;  -- doesn't matter if null
     --
   close c_asg;
   hr_utility.set_location ('close c_asg ',10);
   --
   if p_elig_per_elctbl_chc_id is not null then
     --
     open c_epe;
       --
       fetch c_epe into l_epe;
       --
     close c_epe;
     hr_utility.set_location ('close c_epe ',10);
     --
   end if;
   --
   if l_epe.oipl_id is not null then
     --
     open c_opt(l_epe.oipl_id, nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
       --
       fetch c_opt into l_opt;
       --
     close c_opt;
     hr_utility.set_location ('close c_opt ',10);
     --
   end if;
   --
   -- check boundaries
   --
   hr_utility.set_location ('limit_checks ',10);
   l_old_val:=l_val;
   --- bug:1433393 when the vapro not exist then the benefir amount assigned to the
   --- old_val,
   --- whne there is no vapro the max limit of benefit is validated to decide
   --- whether the electable is allowd or not
   --- the benefit amount (l_val) is after the limit_check so the beneft amount
   --- (before limit check) assigned to old val
   if nvl(p_vapro_exist,'N') <> 'Y' then
     l_old_val := p_bnft_amount ;
   end if ;
   ---
   ---validatiting ultmt lowr limit and ultimate upper limit
   if p_ultmt_lwr_lmt is not null or p_ultmt_upr_lmt is not null
     OR p_ultmt_lwr_lmt_calc_rl is not null or p_ultmt_upr_lmt_calc_rl is not null  then
      benutils.limit_checks
        (p_lwr_lmt_val       => p_ultmt_lwr_lmt,
         p_lwr_lmt_calc_rl   => p_ultmt_lwr_lmt_calc_rl,
         p_upr_lmt_val       => p_ultmt_upr_lmt,
         p_upr_lmt_calc_rl   => p_ultmt_upr_lmt_calc_rl,
         p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date), -- FONM : no need to pass the cvg or rt dates.
         p_assignment_id     => l_asg.assignment_id,
         p_organization_id   => l_asg.organization_id,
         p_business_group_id => l_epe.business_group_id,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_pgm_id            => l_epe.pgm_id,
         p_pl_id             => l_epe.pl_id,
         p_pl_typ_id         => l_epe.pl_typ_id,
         p_opt_id            => l_opt.opt_id,
         p_ler_id            => l_epe.ler_id,
         p_val               => l_val,
         p_state             => l_state.region_2);
        hr_utility.set_location ('Dn limit_checks ',10);
    end if ;
   --
   -- If the value has been changed due to limits
   -- and the value has been lowered then we have
   -- hit the max.  Check if another benefit has been
   -- written at this same level.  If so make this electable
   -- choice not electable.  Do this only for the non Range
   -- cvg_mlt_cd's.
   --
   hr_utility.set_location('old='||l_old_val||' new='||
                           l_val||' limit='|| p_ultmt_upr_lmt,31);
   hr_utility.set_location('per in ler id '|| l_epe.per_in_ler_id,31);
   hr_utility.set_location('mult code '|| p_cvg_mlt_cd,31);
   hr_utility.set_location('pl  '|| l_epe.pl_id,31);
   hr_utility.set_location('pgm  '|| l_epe.pgm_id,31);

   if l_val<l_old_val and
      p_cvg_mlt_cd not like '%RNG' and
      l_epe.elctbl_flag='Y' then

     if l_epe.plip_id is not null or
        l_epe.oipl_id is not null then
       if l_epe.oipl_id is not null then
         --
         -- Check if it is the only plan within the plan type that has opts
         --
         -- 6502657 The c_other_oipls_in_plan_type check is not correct.
         -- It checks on ben_pl_f and ben_oipl_f tables only
         -- and this does not ensure Active/ Eligible/Electable Plans.
         -- A better approach is to check for options only in current Plan
         /*
         l_other_oipls_exist:='N';
         open c_other_oipls_in_plan_type(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM;
         fetch c_other_oipls_in_plan_type into l_other_oipls_exist;
         close c_other_oipls_in_plan_type;
         if l_other_oipls_exist<>'Y' then
         */
           --
           -- Case of one plan with options
           --
          -- 6502657 : This check will ensure, if Coverage of
          -- more than one option in same Plan is reduced
          -- due to Upper Limit, then only one of them is retained
          -- as Electable.
          --
          hr_utility.set_location('other oipl ' ,90);
           open c_other_oipl_cvg;
           fetch c_other_oipl_cvg into l_other_cvg;
           close c_other_oipl_cvg;
         /* Bug#3585768 - Enrollment limitation will be enforced at the time of enrollment
         else
           l_enrt_limit:=null;
           open c_pl_typ_plip_enrt_limit(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM;
           fetch c_pl_typ_plip_enrt_limit into l_level,l_enrt_limit;
           close c_pl_typ_plip_enrt_limit;
           if l_enrt_limit>1 then
             --
             -- Case of can enroll in many plans
             -- Note: same logic as one plan with options
             --
             open c_other_oipl_cvg;
             fetch c_other_oipl_cvg into l_other_cvg;
             close c_other_oipl_cvg;
           elsif l_enrt_limit=1 then
             --
             -- Case of many plans same options and can only choose one
             --
             open c_other_pl_in_ptip_cvg(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
             fetch c_other_pl_in_ptip_cvg into l_other_cvg;
             close c_other_pl_in_ptip_cvg;
           else
             --
             -- No limits no restriction
             --
             null;
           end if;
         */
        --  end if; 6502657
       /* Bug3560065 : If there are setups to have two plans with same coverage,
          this fails
       elsif l_epe.plip_id is not null then
         --
         -- Case of no options
         --
         open c_other_pl_cvg;
         fetch c_other_pl_cvg into l_other_cvg;
         close c_other_pl_cvg;
       */
       end if;
       hr_utility.set_location(' other cal ' || l_other_cvg,99);
       if l_other_cvg=l_val then
         --
         open c_unrest(l_epe.ler_id);
         fetch c_unrest into l_dummy;
         close c_unrest;
         if l_dummy = 'Y' then
           null;
         else
           --
           if not p_calculate_only_mode then
             --
             -- This coverage is above the max
             -- Update the electable choice to be not electable
             --
             ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc(
               p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
               p_elctbl_flag             => 'N',
               p_dflt_flag               => 'N',
               p_object_version_number   => l_epe.object_version_number,
               p_effective_date          => p_effective_date, -- FONM : no need to send the cvg strt dt
               p_program_application_id  => fnd_global.prog_appl_id,
               p_program_id              => fnd_global.conc_program_id,
               p_request_id              => fnd_global.conc_request_id,
               p_program_update_date     => sysdate
             );
             --
             -- If enrolled will deenroll.
             --
             ben_newly_ineligible.main(
                p_person_id           => p_person_id,
                p_pgm_id              => l_epe.pgm_id,
                p_pl_id               => l_epe.pl_id,
                p_oipl_id             => l_epe.oipl_id,
                p_business_group_id   => p_business_group_id,
                p_ler_id              => l_epe.ler_id,
                p_effective_date      => p_effective_date -- FONM : no need to pass cvg or rt dates.
             );
            --
            l_epe.elctbl_flag:='N';
            hr_utility.set_location('Electable choice was made not electable by bencvrge',29);
           end if;
          end if;
       end if;
     end if;
   end if;
   --
   -- Note: g_old_val is for RNG cvg_mlt_cd's, withing comp objects.
   --       l_old_val and l_other_cvg are used for non RNG types
   --       i.e., across oipls or plips.
   --
   open c_cf_bnft_result(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))) ;
     fetch c_cf_bnft_result into l_cf_bnft_result ;
   close c_cf_bnft_result ;
   hr_utility.set_location('l_cf_bnft_result.prtt_enrt_rslt_id '||l_cf_bnft_result.prtt_enrt_rslt_id,39);
   hr_utility.set_location('l_epe.prtt_enrt_rslt_id '||l_epe.prtt_enrt_rslt_id,39);
   --
   l_prtt_enrt_rslt_id := NVL(l_cf_bnft_result.prtt_enrt_rslt_id,l_epe.prtt_enrt_rslt_id);
   --
   if g_old_val <> nvl(l_val,-1) or
      l_epe.elctbl_flag='N'
      -- ERL changes
      or p_cvg_mlt_cd = 'ERL' then
      --
      -- if l_epe.prtt_enrt_rslt_id is not null then
      /* NEED TO BE TRASHED NEVER WORKS FOR FLAT RANGE
      if l_prtt_enrt_rslt_id is not null then
         open c_det_crnt_enrt(l_prtt_enrt_rslt_id);
         fetch c_det_crnt_enrt into l_det_crnt_enrt;
         if c_det_crnt_enrt%notfound then
            l_crnt_enrld_flag := 'N';
         else
            if(l_val = l_det_crnt_enrt.bnft_amt or
               p_entr_val_at_enrt_flag = 'Y'or l_det_crnt_enrt.bnft_ordr_num = p_ordr_num) then
               l_crnt_enrld_flag := 'Y';
            else
               l_crnt_enrld_flag := 'N';
               l_prtt_enrt_rslt_id := null;
            end if;
         end if;
         close c_det_crnt_enrt;
      end if;
      */
      if l_cf_bnft_result.prtt_enrt_rslt_id is not null then
        --
        if (l_val = l_cf_bnft_result.bnft_amt or
            p_entr_val_at_enrt_flag = 'Y'or
            l_cf_bnft_result.bnft_ordr_num = p_ordr_num) then
          --
          l_crnt_enrld_flag := 'Y';
          --
        else
          --
          l_crnt_enrld_flag := 'N';
          l_prtt_enrt_rslt_id := null;
          --
        end if;
        --
      else
        --
        l_crnt_enrld_flag := 'N';
        l_prtt_enrt_rslt_id := null;
        --
      end if;
      --
      hr_utility.set_location('l_prtt_enrt_rslt_id '||l_prtt_enrt_rslt_id,39);
      hr_utility.set_location('l_crnt_enrld_flag'||l_crnt_enrld_flag,39);
      --
      if not p_calculate_only_mode then
        --
        open c_unrest(l_epe.ler_id);
        fetch c_unrest into l_dummy;
        close c_unrest;
        if l_dummy = 'Y' then
          l_enrt_bnft_id := ben_manage_unres_life_events.enb_exists
                            (p_elig_per_elctbl_chc_id,p_ordr_num);
        end if;
        if l_enrt_bnft_id is not null then
          ben_manage_unres_life_events.update_enrt_bnft
           (
             p_dflt_flag              => p_dflt_flag,
             p_val_has_bn_prortd_flag => 'N',
             p_bndry_perd_cd          => p_bndry_perd_cd,
             p_bnft_typ_cd            => p_bnft_typ_cd,
             p_val                    => l_val,
             p_nnmntry_uom            => p_nnmntry_uom,
             p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
             p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id,
             p_business_group_id      => p_business_group_id,
             p_effective_date         => nvl(p_lf_evt_ocrd_dt,p_effective_date),
             p_program_application_id => fnd_global.prog_appl_id,
             p_program_id             => fnd_global.conc_program_id,
             p_request_id             => fnd_global.conc_request_id,
             p_comp_lvl_fctr_id       => p_comp_lvl_fctr_id,
             p_cvg_mlt_cd             => p_cvg_mlt_cd,
             p_crntly_enrld_flag      => l_crnt_enrld_flag,
             p_ctfn_rqd_flag          => p_ctfn_rqd_flag,
             p_entr_val_at_enrt_flag  => p_entr_val_at_enrt_flag,
             p_mx_val                 => p_mx_val,
             p_mx_wout_ctfn_val       => p_mx_wout_ctfn_val,
             p_mn_val                 => p_mn_val,
             p_incrmt_val             => p_incrmt_val,
             p_dflt_val               => p_dflt_val,
             p_rt_typ_cd              => p_rt_typ_cd,
             p_program_update_date    => sysdate,
             p_enrt_bnft_id           => l_enrt_bnft_id,
             p_ordr_num               => p_ordr_num);
        else
          --
          ben_enrt_bnft_api.create_enrt_bnft
         (p_validate               => false,
          p_dflt_flag              => p_dflt_flag,
          p_val_has_bn_prortd_flag => 'N',        -- change when prorating
          p_bndry_perd_cd          => p_bndry_perd_cd,
          p_bnft_typ_cd            => p_bnft_typ_cd,
          p_val                    => l_val,
          p_nnmntry_uom            => p_nnmntry_uom,
          p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
          p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id, --l_epe.prtt_enrt_rslt_id,
          p_business_group_id      => p_business_group_id,
          p_effective_date         => nvl(p_lf_evt_ocrd_dt,p_effective_date), -- FONM : No need to pass the cvg date.
          p_program_application_id => fnd_global.prog_appl_id,
          p_program_id             => fnd_global.conc_program_id,
          p_request_id             => fnd_global.conc_request_id,
          p_comp_lvl_fctr_id       => p_comp_lvl_fctr_id,
          p_cvg_mlt_cd             => p_cvg_mlt_cd,
          p_crntly_enrld_flag      => l_crnt_enrld_flag,
          p_ctfn_rqd_flag          => p_ctfn_rqd_flag,
          p_entr_val_at_enrt_flag  => p_entr_val_at_enrt_flag,
          p_mx_val                 => p_mx_val,  -- max with ctfn
          p_mx_wout_ctfn_val       => p_mx_wout_ctfn_val,  -- max without ctfn
          p_mn_val                 => p_mn_val,
          p_incrmt_val             => p_incrmt_val,
          p_dflt_val               => p_dflt_val,
          p_rt_typ_cd              => p_rt_typ_cd,
          p_program_update_date    => sysdate,
          p_enrt_bnft_id           => l_enrt_bnft_id,
          p_object_version_number  => l_object_version_number,
          p_ordr_num               => p_ordr_num);
        --
         end if;
      end if;
      --
   end if;
   --
   -- Set OUT parameters
   --
   g_old_val := l_val;
   p_enrt_bnft_id := l_enrt_bnft_id;
   --
   p_enb_valrow.enrt_bnft_id     := l_enrt_bnft_id;
   p_enb_valrow.val              := l_val;
   p_enb_valrow.mn_val           := p_mn_val;
   p_enb_valrow.mx_val           := p_mx_val;
   p_enb_valrow.mx_wout_ctfn_val := p_mx_wout_ctfn_val;
   p_enb_valrow.incrmt_val       := p_incrmt_val;
   p_enb_valrow.dflt_val         := p_dflt_val;
   --
   hr_utility.set_location ('Leaving '||l_package,10);
   --
END write_coverage;
--
------------------------------------------------------------------------
PROCEDURE combine_with_variable_val
            (p_vr_val           in number,
             p_val              in number,
             p_vr_trtmt_cd      in varchar2,
             p_combined_val     out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.combine_with_variable_val';
  --
BEGIN
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  if p_vr_val is null then
    --
    p_combined_val := p_val;
    return;
    --
  end if;
  --
  if p_val is null then
    --
    p_combined_val := p_vr_val;
    return;
    --
  end if;
  --
  -- Replace
  --
  if p_vr_trtmt_cd = 'RPLC' then
    --
    p_combined_val := p_vr_val;
    --
    -- Multiply By
    --
  elsif p_vr_trtmt_cd = 'MB' then
    --
    p_combined_val := p_val * p_vr_val;
    --
    -- Subtract From
    --
  elsif p_vr_trtmt_cd = 'SF' then
    --
    p_combined_val := p_val - p_vr_val;
    --
    -- Add To
    --
  elsif p_vr_trtmt_cd = 'ADDTO' then
    --
    p_combined_val := p_val + p_vr_val;
    --
  else -- Replace
    --
    p_combined_val := p_vr_val;
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
END combine_with_variable_val;
--
----------------------------------------------------------------------------
--
procedure chk_bnft_ctfn(p_mx_cvg_wcfn_amt          in  number default null,
                        p_mx_cvg_wcfn_mlt_num      in  number default null,
                        p_mx_cvg_mlt_incr_num      in  number default null,
                        p_mx_cvg_mlt_incr_wcf_num  in  number default null,
                        p_mx_cvg_incr_alwd_amt     in  number default null,
                        p_mx_cvg_incr_wcf_alwd_amt in  number default null,
                        p_mn_cvg_rqd_amt           in  number default null,
                        p_mx_cvg_alwd_amt          in  number default null,
                        p_mx_cvg_rl                in  number default null,
                        p_mn_cvg_rl                in  number default null,
                        p_combined_val             in  number default null,
                        p_crnt_bnft_amt            in  number default null,
                        p_ordr_num                 in  number default null,
                        p_crnt_ordr_num            in  number default null,
                        p_no_mn_cvg_amt_apls_flag  in  varchar2 default null,
                        p_no_mx_cvg_amt_apls_flag  in  varchar2 default null,
                        p_effective_date           in  date,
                        p_assignment_id            in  number default null,
                        p_organization_id          in  number default null,
                        p_business_group_id        in  number default null,
                        p_pgm_id                   in  number default null,
                        p_pl_id                    in  number default null,
                        p_pl_typ_id                in  number default null,
                        p_opt_id                   in  number default null,
                        p_ler_id                   in  number default null,
                        p_elig_per_elctbl_chc_id   in  number default null,
                        p_entr_val_at_enrt_flag    in  varchar2 default null,
                        p_jurisdiction_code        in  varchar2 default null,
--Bug No:4436573 Created another default null parameter for passing the  p_cvg_mlt_cd
-- to perform the necessary validation
			p_cvg_mlt_cd		   in  varchar2 default null,
--End Bug No:4436573
                        p_ctfn_rqd                 out nocopy varchar2,
                        p_write_rec                out nocopy boolean,
                        p_check_received           out nocopy boolean,
                        /* Start of Changes for WWBUG: 2054078: added parameter */
                        p_mx_cvg_wout_ctfn_val     out nocopy number,
                        /* End of Changes for WWBUG: 2054078: added parameter */
			p_rstrn_mn_cvg_rqd_amt     out nocopy number)
			/*Bug 4644489 - parameter to return the minimum coverage required amount as calculated by the
			minimum rule of static value defined in the min field in coverage restrictions*/
is
  --
  l_package           varchar2(80) := g_package||'.chk_bnft_ctfn';
  l_max_possible_amt  number := null;
  l_mn_amt            number := null;
  l_mx_amt            number := null;
  --
  l_mn_outputs ff_exec.outputs_t;
  l_mx_outputs ff_exec.outputs_t;
  --Bug No:4436573 Creating another variable to concatenate
  -- all the feilds in PLN and LBR blocks of coverage restriction form
  l_pln_lbr_itms varchar2(500) := null;
  --End Bug No:4436573
  --
  /* Bug 5331889 */
  cursor fetch_person_id is
  select person_id
    from per_all_assignments_f
      where assignment_id = p_assignment_id;
  l_person_id number;

BEGIN
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  l_max_possible_amt := p_mx_cvg_wcfn_amt;
  l_mn_amt           := p_mn_cvg_rqd_amt;
  l_mx_amt           := p_mx_cvg_alwd_amt;
  --bug#3772179
  if ((l_mx_amt is null) and ((p_mx_cvg_incr_alwd_amt is not null) or (p_mx_cvg_wcfn_amt is not null) ) )then --Bug 5679097
    l_mx_amt := p_crnt_bnft_amt + nvl(p_mx_cvg_incr_alwd_amt,0);    /* Bug 3828288 */  -- Bug 5637851
  end if;
  p_mx_cvg_wout_ctfn_val  := l_mx_amt;
  --
  --Bug 3695079
  --l_max_possible_amt amount should be the min of p_mx_cvg_wcfn_amt and  p_mx_cvg_incr_wcf_alwd_amt
  --p_mx_cvg_incr_wcf_alwd_amt is defined otherwise we need to take only p_mx_cvg_wcfn_amt
  --
  hr_utility.set_location ('l_max_possible_amt '||l_max_possible_amt,111);
  hr_utility.set_location ('p_mx_cvg_incr_wcf_alwd_amt '||p_mx_cvg_incr_wcf_alwd_amt,111);
  if p_mx_cvg_incr_wcf_alwd_amt IS NOT NULL then
    --
    if l_max_possible_amt IS NULL OR
       nvl(l_max_possible_amt,0) > (p_mx_cvg_incr_wcf_alwd_amt + nvl(p_crnt_bnft_amt,0)) then
      l_max_possible_amt := p_mx_cvg_incr_wcf_alwd_amt + nvl(p_crnt_bnft_amt,0);
      hr_utility.set_location ('l_max_possible_amt inside '||l_max_possible_amt,111);
    end if;
    --
  end if;
  --
  open fetch_person_id;       -- Bug 5331889
  fetch fetch_person_id into l_person_id;
  close fetch_person_id;
  --
  if p_mn_cvg_rl is not NULL then
   --
   l_mn_outputs := benutils.formula
                    (p_formula_id          => p_mn_cvg_rl,
                     p_effective_date      => p_effective_date,
                     p_assignment_id       => p_assignment_id,
                     p_organization_id     => p_organization_id,
                     p_business_group_id   => p_business_group_id,
                     p_pgm_id              => p_pgm_id,
                     p_pl_id               => p_pl_id,
                     p_pl_typ_id           => p_pl_typ_id,
                     p_opt_id              => p_opt_id,
                     p_ler_id              => p_ler_id,
                     p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                     -- FONM
                     p_param1             => 'BEN_IV_RT_STRT_DT',
                     p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                     p_param2             => 'BEN_IV_CVG_STRT_DT',
                     p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
		     p_param3             => 'BEN_IV_PERSON_ID',           -- Bug 5331889
                     p_param3_value       => to_char(l_person_id),
                     p_jurisdiction_code  => p_jurisdiction_code);
    --
    if l_mn_outputs(l_mn_outputs.first).value is not null then
       --
       l_mn_amt := fnd_number.canonical_to_number(l_mn_outputs(l_mn_outputs.first).value);
       --
--Bug 4644489
       p_rstrn_mn_cvg_rqd_amt := l_mn_amt;
-- Returing the mn_cvg_rqd_amt as defined by the rule
--End Bug 4644489
    end if;
    --
  end if;
  --
  if p_mx_cvg_rl is not NULL then
    --
    l_mx_outputs := benutils.formula
                     (p_formula_id          => p_mx_cvg_rl,
                      p_effective_date      => p_effective_date,
                      p_assignment_id       => p_assignment_id,
                      p_organization_id     => p_organization_id,
                      p_business_group_id   => p_business_group_id,
                      p_pgm_id              => p_pgm_id,
                      p_pl_id               => p_pl_id,
                      p_pl_typ_id           => p_pl_typ_id,
                      p_opt_id              => p_opt_id,
                      p_ler_id              => p_ler_id,
                      p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                      -- FONM
                      p_param1             => 'BEN_IV_RT_STRT_DT',
                      p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                      p_param2             => 'BEN_IV_CVG_STRT_DT',
                      p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
       		      p_param3             => 'BEN_IV_PERSON_ID',           -- Bug 5331889
                      p_param3_value       => to_char(l_person_id),
                      p_jurisdiction_code   => p_jurisdiction_code);
    --
    if l_mx_outputs(l_mx_outputs.first).value is not null then
       --
       l_mx_amt := fnd_number.canonical_to_number(l_mx_outputs(l_mx_outputs.first).value);
       --
      /* Start of Changes for WWBUG: 2054078: added             */
       p_mx_cvg_wout_ctfn_val := l_mx_amt;
      /* Ended of Changes for WWBUG: 2054078: added             */
       --
    end if;
    --
  end if;
  --

  hr_utility.set_location ('Plan PL_ID                 -> '||p_pl_id                  ,33);
  hr_utility.set_location ('p_mx_cvg_wcfn_amt          -> '||p_mx_cvg_wcfn_amt         ,33);
  hr_utility.set_location ('p_mx_cvg_wcfn_mlt_num      -> '||p_mx_cvg_wcfn_mlt_num     ,33);
  hr_utility.set_location ('p_mx_cvg_mlt_incr_num      -> '||p_mx_cvg_mlt_incr_num     ,33);
  hr_utility.set_location ('p_mx_cvg_mlt_incr_wcf_num  -> '||p_mx_cvg_mlt_incr_wcf_num ,33);
  hr_utility.set_location ('p_mx_cvg_incr_alwd_amt     -> '||p_mx_cvg_incr_alwd_amt    ,33);
  hr_utility.set_location ('p_mx_cvg_incr_wcf_alwd_amt -> '||p_mx_cvg_incr_wcf_alwd_amt,33);
  hr_utility.set_location ('p_mx_cvg_rl                -> '||p_mx_cvg_rl               ,33);
  hr_utility.set_location ('p_mn_cvg_rl                -> '||p_mn_cvg_rl               ,33);
  hr_utility.set_location ('p_combined_val             -> '||p_combined_val            ,33);
  hr_utility.set_location ('p_crnt_bnft_amt            -> '||p_crnt_bnft_amt           ,33);
  hr_utility.set_location ('p_ordr_num                 -> '||p_ordr_num                ,33);
  hr_utility.set_location ('p_crnt_ordr_num            -> '||p_crnt_ordr_num           ,33);
  --Bug No:4436573 Debugging purpose
  hr_utility.set_location ('p_cvg_mlt_cd               -> '||p_cvg_mlt_cd              ,33);
  --End Bug No:4436573
  --
  if p_combined_val is null then
     --
     p_ctfn_rqd  := 'N';
     p_write_rec := true;
     --
  elsif p_combined_val > l_max_possible_amt then
     --
     p_ctfn_rqd  := 'N';
     p_write_rec := false;
     --
  elsif p_ordr_num > p_mx_cvg_wcfn_mlt_num then
     --
     p_ctfn_rqd  := 'N';
     p_write_rec := false;
     --
  elsif p_combined_val < l_mn_amt then
     --
     p_ctfn_rqd  := 'N';
     p_write_rec := false;
     --
  elsif p_crnt_bnft_amt is null and
        p_crnt_ordr_num is null then
     --
     p_ctfn_rqd  := 'N';
     p_write_rec := true;
     --
  elsif (p_combined_val - nvl(p_crnt_bnft_amt,0))
                          > p_mx_cvg_incr_wcf_alwd_amt then
    --
    p_ctfn_rqd  := 'N';
    p_write_rec := false;
    --
  elsif (p_ordr_num - nvl(p_crnt_ordr_num,0)) > p_mx_cvg_mlt_incr_wcf_num then
    --
    p_ctfn_rqd  := 'N';
    p_write_rec := false;
    --
  elsif (p_combined_val - nvl(p_crnt_bnft_amt,0))
                         <= p_mx_cvg_incr_alwd_amt then
     --
     p_ctfn_rqd  := 'N';
     p_write_rec := true;
     --
  elsif (p_ordr_num - nvl(p_crnt_ordr_num,0)) <= p_mx_cvg_mlt_incr_num then
    --
    p_ctfn_rqd  := 'N';
    p_write_rec := true;
    --
  elsif (p_combined_val - nvl(p_crnt_bnft_amt,0))
                           <= p_mx_cvg_incr_wcf_alwd_amt then
    --
    hr_utility.set_location(' IK1 p_combined_val - nvl(p_crnt_bnft_amt,0))'||(p_combined_val - nvl(p_crnt_bnft_amt,0)),99);
     hr_utility.set_location('IK1 p_mx_cvg_incr_wcf_alwd_amt'||p_mx_cvg_incr_wcf_alwd_amt,99);
    p_ctfn_rqd  := 'Y';
    p_write_rec := true;
    --
  elsif (p_ordr_num - nvl(p_crnt_ordr_num,0))<= p_mx_cvg_mlt_incr_wcf_num then
    --
    p_ctfn_rqd  := 'Y';
    p_write_rec := true;
    --
  else
    --
    p_ctfn_rqd  := 'N';
    p_write_rec := true;
    --
  end if;
  --
  if p_write_rec  then
     hr_utility.set_location (' p_write_rec  ',10);
  end if ;

  hr_utility.set_location (' p_no_mx_cvg_amt_apls_flag'|| p_no_mx_cvg_amt_apls_flag,10);

  -- This Certification condition is not based on increases,
  -- but based on a fixed amount. (Bug 1142060)
  -- no max flag is validated for # 2736519
  --
  -- Bug 3132792 if certifications is already provided for a benefit amount
  -- we don't need certifications upto that amount.
  -- Max without cert 50,000. Max with Cert is 100,000.
  -- In the first life event customer provided a certification for the
  -- benefit amount of 75,000. Now we need certification only for the
  -- amount more than 75,000 even if there are no increases defined by
  -- the customer.
  --
  hr_utility.set_location ('IK l_mx_amt '||l_mx_amt,20);
  hr_utility.set_location ('IK p_crnt_bnft_amt '||p_crnt_bnft_amt,20);
  --
  if p_entr_val_at_enrt_flag = 'N' then
    --
    l_mx_amt := greatest(l_mx_amt,nvl(p_crnt_bnft_amt,0));
    --
  end if;
  --
  if p_write_rec and
     ( p_combined_val > l_mx_amt or p_no_mx_cvg_amt_apls_flag = 'Y')  then
     --
     hr_utility.set_location ('IK I am Here'||p_combined_val,99);
     hr_utility.set_location ('IK l_mx_amt'||l_mx_amt ,99);
     p_check_received:=true;
     p_ctfn_rqd := 'Y';
     --
  end if;
  --
  hr_utility.set_location ('p_ctfn_rqd '||p_ctfn_rqd,09);
  --
  if p_write_rec and p_entr_val_at_enrt_flag = 'Y' and
     (l_mx_amt < l_max_possible_amt
     or l_max_possible_amt is not null)
     then
      hr_utility.set_location ('IK ENTRVALENRT case',99);
     p_ctfn_rqd := 'Y';
  end if;
  --
  if p_cvg_mlt_cd = 'ERL' then
     l_pln_lbr_itms := p_mx_cvg_wcfn_amt ||p_mx_cvg_wcfn_mlt_num || p_mx_cvg_mlt_incr_num;
     l_pln_lbr_itms := l_pln_lbr_itms ||  p_mx_cvg_mlt_incr_wcf_num || p_mx_cvg_incr_alwd_amt;
     l_pln_lbr_itms := l_pln_lbr_itms || p_mx_cvg_incr_wcf_alwd_amt || p_mn_cvg_rqd_amt;
     l_pln_lbr_itms := l_pln_lbr_itms || p_mx_cvg_alwd_amt || p_mx_cvg_rl ||p_mn_cvg_rl ;
     --
     IF l_pln_lbr_itms is not null then
       p_ctfn_rqd := 'Y';
     ELSE
       p_ctfn_rqd :='N';
     END if;
     --
  END if;
  --
  hr_utility.set_location ('p_ctfn_rqd '||p_ctfn_rqd,10);
  hr_utility.set_location ('Leaving '||l_package,10);
  --
END chk_bnft_ctfn;
--
------------------------------------------------------------------------------
--
PROCEDURE main
  (p_calculate_only_mode    in     boolean
  ,p_elig_per_elctbl_chc_id IN     number
  ,p_effective_date         IN     date
  ,p_lf_evt_ocrd_dt         IN     date
  ,p_perform_rounding_flg   IN     boolean
  --
  ,p_enb_valrow                out nocopy ben_determine_coverage.ENBValType
  )
is
  --
  l_package varchar2(80) := g_package||'.main';
  l_object_version_number number;
  l_value number;
  l_compensation_value number;
  l_dummy_number number;
  l_dummy_char varchar2(30);
  l_combined_val number;
  l_calculated_val number;
  l_vr_val number;
  l_vr_trtmt_cd varchar2(30);
  l_outputs  ff_exec.outputs_t;
  l_dflt_flag varchar2(30) := 'N';
  i number;
  l_incr_r_decr_cd varchar2(15);
  l_order_number number := 1;
  l_crnt_ordr_num number := null;
  l_bnft_amt number := null;
  l_write_rec boolean := true;
  l_ctfn_rqd varchar2(15) := 'N';
  l_ctfn_rqd2 varchar2(15) := 'N';
  l_elctbl_chc_ctfn_id    number;
  l_rstrn_found boolean := false;
  l_oipl_id varchar2(30);
  l_business_group_id varchar2(30);
  l_pl_id varchar2(30);
  l_ler_id varchar2(30);
  l_ler_bnft_rstrn_id varchar2(30);
  l_person_id varchar2(30);
  l_enrt_bnft_id number;
  l_dflt_val number;
  l_dflt_enrt_cd varchar2(30);
  l_dflt_enrt_rl number;
  l_jurisdiction_code     varchar2(30);
  l_effective_date        date;
  -- FONM
  l_fonm_cvg_strt_dt          date;
  l_perform_rounding_flg boolean := p_perform_rounding_flg;
  l_ultmt_upr_lmt         number ;
  l_ultmt_lwr_lmt         number ;
  l_ultmt_upr_lmt_calc_rl number ;
  l_ultmt_lwr_lmt_calc_rl number ;
  l_vapro_exist           varchar2(30) ;
  l_cvg_amount            number ;
  l_vr_ann_mn_elcn_val    number;
  l_vr_ann_mx_elcn_val    number;
  l_mn_elcn_val           number;
  l_mx_elcn_val           number;
  l_incrmnt_elcn_val      number;
  l_dflt_elcn_val         number;
  l_interim_bnft_val      number; /*ENH*/
  l_upr_val               number;
  l_lwr_val               number;
  l_upr_outputs           ff_exec.outputs_t;
  l_lwr_outputs           ff_exec.outputs_t;
  l_ult_lwr_outputs       ff_exec.outputs_t;
  --
  /* Start of Changes for WWBUG: 2054078                */
  l_mx_cvg_wout_ctfn_val  number;
  /* End of Changes for WWBUG: 2054078                  */
  --
  l_inst_count pls_integer;

  --Bug 4644489
  l_rstrn_mn_cvg_rqd_amt number;
--End Bug 4644489

-- 5529258
     l_dflt_to_asn_pndg_ctfn_cd  ben_pl_f.DFLT_TO_ASN_PNDG_CTFN_CD%type;
     l_INTERIM_ELCTBL_CHC_ID number;
     l_INTERIM_BNFT_AMT number;

-- ends 5529258
  --
  cursor c_epe is
    select pil.person_id,
           epe.prtt_enrt_rslt_id, --5529258
           epe.pgm_id,
           epe.pl_id,
           epe.pl_typ_id,
           epe.oipl_id,
           epe.plip_id,
           epe.ptip_id,
           epe.dflt_flag,
           pil.per_in_ler_id,
           pil.ler_id,
           epe.business_group_id,
           epe.crntly_enrd_flag,
           epe.elctbl_flag,
           epe.object_version_number
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and    epe.per_in_ler_id = pil.per_in_ler_id ;
  --
  --bug 1895846 to check for the pending work flow or suspended enrollment results
  --
  cursor c_epe_in_pndg is
    select null
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and    epe.per_in_ler_id = pil.per_in_ler_id
    and    nvl(epe.in_pndg_wkflow_flag,'N') <> 'N' ;
  --
  l_dummy  varchar2(30):= null ;

  l_epe c_epe%rowtype;
  --
  -- FONM
  cursor c_opt(rqd_oipl_id number, cv_effective_date date) is
    select opt_id
    from   ben_oipl_f
    where  oipl_id = rqd_oipl_id
    and    cv_effective_date -- nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between effective_start_date
           and     effective_end_date;
  --
  l_opt c_opt%rowtype;
  --


  cursor c_ler_rstrn(cv_effective_date date) is -- FONM
    select rstrn.ler_bnft_rstrn_id,
           rstrn.pl_id,
           rstrn.cvg_incr_r_decr_only_cd,
           rstrn.mx_cvg_wcfn_amt,
           rstrn.mx_cvg_wcfn_mlt_num,
           rstrn.mx_cvg_mlt_incr_num,
           rstrn.mx_cvg_mlt_incr_wcf_num,
           rstrn.mx_cvg_incr_alwd_amt,
           rstrn.mx_cvg_incr_wcf_alwd_amt,
           rstrn.mn_cvg_amt mn_cvg_rqd_amt,
           rstrn.mx_cvg_alwd_amt,
           rstrn.mx_cvg_rl,
           rstrn.mn_cvg_rl,
           rstrn.no_mn_cvg_incr_apls_flag no_mn_cvg_amt_apls_flag,
           rstrn.no_mx_cvg_amt_apls_flag no_mx_cvg_amt_apls_flag,
           rstrn.dflt_to_asn_pndg_ctfn_cd, /*ENH*/
           rstrn.dflt_to_asn_pndg_ctfn_rl -- 5529258
    from   ben_ler_bnft_rstrn_f rstrn
    where  rstrn.ler_id = l_ler_id
    and    rstrn.pl_id  = l_pl_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between rstrn.effective_start_date
           and     rstrn.effective_end_date;
  --
  cursor c_pl_rstrn(cv_effective_date date) is -- FONM
    select null ler_bnft_rstrn_id,
           pln.pl_id,
           pln.cvg_incr_r_decr_only_cd,
           pln.mx_cvg_wcfn_amt,
           pln.mx_cvg_wcfn_mlt_num,
           pln.mx_cvg_mlt_incr_num,
           pln.mx_cvg_mlt_incr_wcf_num,
           pln.mx_cvg_incr_alwd_amt,
           pln.mx_cvg_incr_wcf_alwd_amt,
           pln.mn_cvg_rqd_amt,
           pln.mx_cvg_alwd_amt,
           pln.mx_cvg_rl,
           pln.mn_cvg_rl,
           pln.no_mn_cvg_amt_apls_flag,
           pln.no_mx_cvg_amt_apls_flag,
           pln.dflt_to_asn_pndg_ctfn_cd, /*ENH*/
	   pln.dflt_to_asn_pndg_ctfn_rl  --5529258
    from   ben_pl_f pln
    where  pln.pl_id = l_pl_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pln.effective_start_date
           and     pln.effective_end_date;
  --
  l_rstrn c_ler_rstrn%rowtype;
  --
  cursor c_ler_rstrn_ctfn(cv_effective_date date) is -- FONM
    select ctfn.rqd_flag,
           ctfn.enrt_ctfn_typ_cd,
           ctfn.ctfn_rqd_when_rl,
           lbr.ctfn_determine_cd
    from   ben_ler_bnft_rstrn_ctfn_f ctfn, ben_ler_bnft_rstrn_f lbr     -- Bug 5887665
    where  ctfn.ler_bnft_rstrn_id = l_ler_bnft_rstrn_id
    and    ctfn.ler_bnft_rstrn_id = lbr.ler_bnft_rstrn_id
    and    ctfn.business_group_id = l_business_group_id
    and    lbr.business_group_id = l_business_group_id
    and    cv_effective_date
           between lbr.effective_start_date
           and     lbr.effective_end_date
    and    cv_effective_date      -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between ctfn.effective_start_date
           and     ctfn.effective_end_date;
  --
  cursor c_pl_rstrn_ctfn(cv_effective_date date) is -- FONM
    select ctfn.rqd_flag,
           ctfn.enrt_ctfn_typ_cd,
           ctfn.ctfn_rqd_when_rl,
           pln.ctfn_determine_cd
    from   ben_bnft_rstrn_ctfn_f ctfn, ben_pl_f pln       -- Bug 5887675
    where  ctfn.pl_id = l_pl_id
    and    ctfn.pl_id = pln.pl_id
    and    ctfn.business_group_id = l_business_group_id
    and    pln.business_group_id = l_business_group_id
    and    cv_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between ctfn.effective_start_date
           and     ctfn.effective_end_date;
  --
  l_cvg    ben_cvg_cache.g_epeplncvg_cache;
  --
  cursor c_asg(cv_effective_date date) is -- FONM
    select asg.assignment_id,asg.organization_id
    from   per_all_assignments_f asg
    where  asg.person_id = l_epe.person_id
    and    asg.primary_flag = 'Y'
    and    asg.assignment_type <> 'C'
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between asg.effective_start_date
           and    asg.effective_end_date
    order  by decode(asg.assignment_type, 'E',1,'B',2,3);
  --
  l_asg c_asg%rowtype;
  --
  cursor c_state (cv_effective_date date) is -- FONM
    select region_2
    from   hr_locations_all loc,
           per_all_assignments_f asg
    where  loc.location_id = asg.location_id
    and    asg.person_id = l_epe.person_id
    and    asg.primary_flag = 'Y'
    and    asg.assignment_type <> 'C'
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between asg.effective_start_date
           and     asg.effective_end_date
    order  by decode(asg.assignment_type, 'E',1,'B',2,3);
  --
  l_state c_state%rowtype;
  --
  -- bug 2560721 - added another return value from the cursor c_current_enrt to determine
  -- if the person is previously enrolled or New enrollment, becos bnft_amt and bnft_ordr_num
  -- can both be null even if the person is enrolled. This might occur when the coverage is
  -- not defined for the plan during his previous enrollment.
  --
  l_current_enrt_present char;
  --
  cursor c_current_enrt(cv_effective_date date) is -- FONM
    select bnft_ordr_num,
           bnft_amt,
           'Y'
    from   ben_prtt_enrt_rslt_f
    where  business_group_id = l_business_group_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between enrt_cvg_strt_dt
           and     enrt_cvg_thru_dt
    and    enrt_cvg_thru_dt <= effective_end_date
    and    prtt_enrt_rslt_stat_cd is null
    and    sspndd_flag = 'N'
    and    l_person_id = person_id
    and    l_pl_id = pl_id
    and    ((l_oipl_id is null and oipl_id is null) or
            l_oipl_id = oipl_id)
    order by decode(sspndd_flag,'Y',1,2) ; --CF Changes
  --
  cursor c_current_enrt_sspndd(cv_effective_date date) is -- FONM
    select bnft_ordr_num,
           bnft_amt,
           'Y'
    from   ben_prtt_enrt_rslt_f
    where  business_group_id = l_business_group_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between enrt_cvg_strt_dt
           and     enrt_cvg_thru_dt
    and    enrt_cvg_thru_dt <= effective_end_date
    and    prtt_enrt_rslt_stat_cd is null
    and    sspndd_flag = 'Y'
    and    l_person_id = person_id
    and    l_pl_id = pl_id
    and    ((l_oipl_id is null and oipl_id is null) or
            l_oipl_id = oipl_id)
    order by decode(sspndd_flag,'Y',1,2) ; --CF Changes
  --
  l_current_enrt_sspndd c_current_enrt_sspndd%rowtype;
  --
  /*ENH*/
  cursor c_current_enrt_in_pl_typ(c_pl_typ_id number,cv_effective_date date) is -- FONM
    select pl_id,oipl_id
    from   ben_prtt_enrt_rslt_f
    where  business_group_id = l_business_group_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between enrt_cvg_strt_dt
           and     enrt_cvg_thru_dt
    and    enrt_cvg_thru_dt <= effective_end_date
    and    sspndd_flag = 'N'
    and    prtt_enrt_rslt_stat_cd is null
    and    l_person_id = person_id
    and    c_pl_typ_id = pl_typ_id ;
  --
  cursor c_current_enrt_in_pln( c_pl_id number,cv_effective_date date ) is -- FONM
    select pl_id,oipl_id
    from   ben_prtt_enrt_rslt_f
    where  business_group_id = l_business_group_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between enrt_cvg_strt_dt
           and     enrt_cvg_thru_dt
    and    enrt_cvg_thru_dt <= effective_end_date
    and    sspndd_flag = 'N'
    and    prtt_enrt_rslt_stat_cd is null
    and    l_person_id = person_id
    and    c_pl_id = pl_id ;
  --
  cursor c_current_enrt_in_oipl( c_oipl_id number, cv_effective_date date ) is -- FONM
    select pl_id,oipl_id
    from   ben_prtt_enrt_rslt_f
    where  business_group_id = l_business_group_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between enrt_cvg_strt_dt
           and     enrt_cvg_thru_dt
    and    enrt_cvg_thru_dt <= effective_end_date
    and    sspndd_flag = 'N'
    and    prtt_enrt_rslt_stat_cd is null
    and    l_person_id = person_id
    and    c_oipl_id = oipl_id ;
  --
  -- CF Changes
  cursor c_current_enb(c_pl_id number,c_oipl_id number, cv_effective_date date ) is -- FONM
    select
           pen.bnft_amt,
           enb.*
    from   ben_prtt_enrt_rslt_f pen,
           ben_enrt_bnft enb,
           ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  pen.business_group_id = l_business_group_id
    and    cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.sspndd_flag = 'N' ---CF Changes
    and    l_person_id = pen.person_id
    and    c_pl_id = pen.pl_id
    and    ((c_oipl_id is null and pen.oipl_id is null) or
            c_oipl_id = pen.oipl_id)
    and    pen.prtt_enrt_rslt_id = enb.prtt_enrt_rslt_id
    and    pen.bnft_ordr_num     = enb.ordr_num
    and    enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
    and    epe.per_in_ler_id  = pil.per_in_ler_id
    and    pil.per_in_ler_stat_cd = 'PROCD'
    and    pil.person_id = l_person_id ;
  --
  l_current_enb   c_current_enb%rowtype;
  --
  cursor c_clf(p_comp_lvl_fctr_id in number) is
    select clf.comp_src_cd,
           clf.name
    from   ben_comp_lvl_fctr clf
    where  p_comp_lvl_fctr_id = clf.comp_lvl_fctr_id;
  --
  l_clf c_clf%rowtype;
  --
  l_not_found boolean;
  --
  l_commit number;
  l_val number;
  --
  l_check_received boolean:=false;
  l_ctfn_received varchar2(30) := 'N';
  l_interim_cd varchar2(30) :=  'DF' ;  /*ENH I am defaulting to Default Val */
  l_current_level_cd varchar2(30) := null;
  l_create_current_enb boolean := false ;
  l_current_plan_id   number := null;
  l_current_oipl_id number := null;
  l_entr_val_at_enrt_flag  varchar2(10); -- Bug 7414757

  --
cursor c_ctfn_received(
            p_pgm_id           in number,
            p_pl_id            in number,
            p_enrt_ctfn_typ_cd in varchar2,
            p_person_id        in number,
            cv_effective_date   in date ) is -- FONM
    select 'Y'
    from
         ben_prtt_enrt_rslt_f pen,
         ben_prtt_enrt_actn_f pea,
         ben_per_in_ler pil,
         ben_prtt_enrt_ctfn_prvdd_f ecp
   where
          -- pen
          pen.person_id=p_person_id
      and pen.business_group_id = l_business_group_id
      and cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date) between
          between pen.effective_start_date and pen.effective_end_date
      and pen.pl_id=p_pl_id
      and nvl(pen.pgm_id,-1)=nvl(p_pgm_id,-1)
      and pen.prtt_enrt_rslt_stat_cd is null
          -- pea
      and pea.prtt_enrt_rslt_id=pen.prtt_enrt_rslt_id
      and pea.business_group_id=pen.business_group_id
      and pea.pl_bnf_id is null
      and pea.elig_cvrd_dpnt_id is null
      and cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
          between pea.effective_start_date
          and pea.effective_end_date
          -- pil
      and pil.per_in_ler_id=pea.per_in_ler_id
      and pil.business_group_id=pea.business_group_id
      and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
          -- ecp
      and ecp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and ecp.prtt_enrt_actn_id=pea.prtt_enrt_actn_id
      and ecp.enrt_ctfn_recd_dt is not null
      and ecp.business_group_id = pen.business_group_id
      and cv_effective_date -- FONM nvl(p_lf_evt_ocrd_dt,p_effective_date)
          between ecp.effective_start_date
                               and ecp.effective_end_date
      and ecp.enrt_ctfn_typ_cd=p_enrt_ctfn_typ_cd
      --Bug 3132792 only if the benefit amount is more that the combined value
      -- we need to return 'Y' for the certification received flag
      and pen.bnft_amt >= l_combined_val
    ;
   l_tot_val number;
    --Unrestricted enh
  cursor c_unrest(p_ler_id  number)  is
    select 'Y'
    from ben_ler_f ler
    where ler.typ_cd = 'SCHEDDU'
    and   ler.ler_id = p_ler_id
    and   p_effective_date between ler.effective_start_date
         and ler.effective_end_date;
  --
  -- Bug 3828288
  l_mx_val_wcfn                 number;
  l_mx_val_wo_cfn               number;
  l_ccm_max_val                 number;
  l_cvg_rstn_max_incr_wout_cert number;
  l_cvg_rstn_max_incr_with_cert number;
  l_cvg_rstn_max_wout_cert      number;
  l_cvg_rstn_max_with_cert      number;
  -- Bug 3828288
  --
  ----Bug 7704956
  cursor c_check_dup_enb_enr(p_epe_id number) is
  SELECT enb.*
  FROM ben_enrt_bnft enb
 WHERE  elig_per_elctbl_chc_id = p_epe_id
   AND crntly_enrld_flag = 'Y';

  l_check_dup_enb_enr   c_check_dup_enb_enr%rowtype;
  l_dup_enr_count  number := 0;
  l_chk_bnft_id    number;

  cursor c_get_prev_bnft(cv_effective_date date) is
  SELECT  pen.prtt_enrt_rslt_id,
          pen.bnft_amt,
          pen.bnft_ordr_num
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.prtt_enrt_rslt_id = l_epe.prtt_enrt_rslt_id
      and      pen.business_group_id = l_epe.business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      cv_effective_date <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      NVL(l_epe.oipl_id,-1) = NVL(pen.oipl_id,-1)
      AND      l_epe.pl_id   = pen.pl_id
      AND      NVL(l_epe.pgm_id,-1)  = NVL(pen.pgm_id,-1)
      AND      (pen.sspndd_flag = 'N'
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
    order by pen.enrt_cvg_strt_dt;
  l_get_prev_bnft  c_get_prev_bnft%rowtype;

  ---------Enhancement	8716693
  cursor c_get_pil_elctbl is
  SELECT pil.per_in_ler_id,
         epe.pl_id,
	 epe.oipl_id,
	 epe.pgm_id,
	 epe.pl_typ_id
  FROM ben_per_in_ler pil,
       ben_elig_per_elctbl_chc epe
 WHERE pil.business_group_id = epe.business_group_id
   AND pil.per_in_ler_id = epe.per_in_ler_id
   AND epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
   AND epe.crntly_enrd_flag = 'Y';

  l_get_pil_elctbl   c_get_pil_elctbl%rowtype;

  cursor c_get_prev_pil(p_person_id number) is
  SELECT pil.*
    FROM ben_per_in_ler pil,
         ben_ler_f ler
   WHERE pil.person_id = p_person_id
     AND pil.ler_id = ler.ler_id
     AND ler.business_group_id = pil.business_group_id
     AND ler.typ_cd NOT IN ('IREC','GSP','COMP','ABS','SCHEDDU')
     AND pil.per_in_ler_stat_cd = 'PROCD'
     AND pil.lf_evt_ocrd_dt < p_lf_evt_ocrd_dt
 ORDER BY pil.lf_evt_ocrd_dt  desc;

  l_get_prev_pil   c_get_prev_pil%rowtype;

  cursor c_chk_prev_sus_enr( p_pil_id number,
                             p_pgm_id number,
			     p_pl_id number,
			     p_oipl_id number) is
  SELECT null
  FROM ben_prtt_enrt_rslt_f pen
 WHERE pen.per_in_ler_id = p_pil_id
   AND pen.sspndd_flag = 'Y'
   AND pen.prtt_enrt_rslt_stat_cd IS NULL
   AND Nvl(pen.pgm_id,-1) = nvl(p_pgm_id,-1)
   AND pen.pl_id = p_pl_id
   AND Nvl(pen.oipl_id,-1) = nvl(p_oipl_id,-1)
   and pen.enrt_cvg_thru_dt = hr_api.g_eot
   and pen.effective_end_date  = hr_api.g_eot;

  l_chk_prev_sus_enr   c_chk_prev_sus_enr%rowtype;

  cursor c_get_cvg_rstr(p_prev_pil_id number) is
  SELECT enb1.*
    FROM ben_elig_per_elctbl_chc epe,
         ben_elig_per_elctbl_chc epe1,
         ben_enrt_bnft enb1
   WHERE epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     AND epe.crntly_enrd_flag = 'Y'
     AND epe1.per_in_ler_id = p_prev_pil_id
     AND epe1.pl_id = epe.pl_id
     AND Nvl(epe1.oipl_id,-1) = Nvl(epe.oipl_id,-1)
     AND epe1.pgm_id = epe.pgm_id
     AND epe1.business_group_id = epe.business_group_id
     AND enb1.elig_per_elctbl_chc_id = epe1.elig_per_elctbl_chc_id
     AND enb1.business_group_id = epe.business_group_id;

   l_get_cvg_rstr  c_get_cvg_rstr%rowtype;
   l_force_rstr    boolean := false;
   l_cert_rstr  c_ler_rstrn_ctfn%rowtype;

  -- cursor c_prev_le_cert(p_business_group_id number,p_epe_id number) is
  ---Bug 8767376
  cursor c_prev_le_cert(p_business_group_id number,p_epe_id number,p_val number) is
   SELECT ecc.*
    FROM ben_elctbl_chc_ctfn ecc
   WHERE ecc.business_group_id = p_business_group_id
     AND ecc.elig_per_elctbl_chc_id = p_epe_id
     ---Added for the bug 8767376
     and l_cvg(0).cvg_mlt_cd not in  ('CLRNG','FLPCLRNG','CLPFLRNG','FLRNG')
   union
   SELECT ecc.*
    FROM ben_elctbl_chc_ctfn ecc,
         ben_enrt_bnft enb
   WHERE ecc.elig_per_elctbl_chc_id = p_epe_id
     AND ecc.business_group_id = p_business_group_id
     AND enb.business_group_id = ecc.business_group_id
     AND enb.elig_per_elctbl_chc_id = ecc.elig_per_elctbl_chc_id
     AND enb.enrt_bnft_id = ecc.enrt_bnft_id
     AND nvl(enb.val,-1) = nvl(p_val,-1)
     AND ecc.enrt_bnft_id IS NOT NULL
     and  l_cvg(0).cvg_mlt_cd in ('CLRNG','FLPCLRNG','CLPFLRNG','FLRNG');

   l_prev_le_cert   c_prev_le_cert%rowtype;

   cursor c_chk_bnft_cert(p_business_group_id number) is
   SELECT NULL
    FROM ben_elctbl_chc_ctfn ecc,
         ben_enrt_bnft enb   ---Added for the bug 8767376
   WHERE ecc.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     AND ecc.business_group_id = p_business_group_id
      ---Added for the bug 8767376
     AND enb.business_group_id = ecc.business_group_id
     AND enb.elig_per_elctbl_chc_id = ecc.elig_per_elctbl_chc_id
     AND enb.enrt_bnft_id = ecc.enrt_bnft_id
     AND enb.crntly_enrld_flag = 'Y'
     AND ecc.enrt_bnft_id IS NOT NULL;

   l_chk_bnft_cert   c_chk_bnft_cert%rowtype;
   l_carry_fwd_cert   varchar2(1) := 'N';
  ---------------Enhancement 8716693

  procedure write_ctfn is
  begin
    --
    -- ctfn's at the option level are written in benchctf.pkb
    -- don't write them at the bnft level too.  Bug 1277371.
    --
    hr_utility.set_location('IK l_combined_val '||l_combined_val,20);
    hr_utility.set_location('IK l_enrt_bnft_id '||l_enrt_bnft_id,20);
    hr_utility.set_location('IK p_elig_per_elctbl_chc_id '||p_elig_per_elctbl_chc_id,20);
    --
    if l_ler_bnft_rstrn_id is not null  then
      for l_ctfn in c_ler_rstrn_ctfn(nvl(l_fonm_cvg_strt_dt,l_effective_date)) loop -- FONM
        l_ctfn_received:='N';
        if l_check_received then
          open c_ctfn_received(
            p_pgm_id           =>l_epe.pgm_id,
            p_pl_id            =>l_epe.pl_id,
            p_enrt_ctfn_typ_cd =>l_ctfn.enrt_ctfn_typ_cd,
            p_person_id        =>l_epe.person_id,
            cv_effective_date   =>nvl(l_fonm_cvg_strt_dt, l_effective_date) -- FONM
          );
          fetch c_ctfn_received into l_ctfn_received;
          close c_ctfn_received;
        end if;
        if l_ctfn_received='N' then
          ben_determine_chc_ctfn.write_ctfn
           (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
            p_enrt_bnft_id           => l_enrt_bnft_id,
            p_enrt_ctfn_typ_cd       => l_ctfn.enrt_ctfn_typ_cd,
            p_rqd_flag               => l_ctfn.rqd_flag,
            p_ctfn_rqd_when_rl       => l_ctfn.ctfn_rqd_when_rl,
            p_business_group_id      => l_epe.business_group_id,
            p_effective_date         => l_effective_date, -- FONM  nvl(p_lf_evt_ocrd_dt,p_effective_date),
            p_assignment_id          => l_asg.assignment_id,
            p_organization_id        => l_asg.organization_id,
            p_jurisdiction_code      => l_jurisdiction_code,
            p_pgm_id                 => l_epe.pgm_id,
            p_pl_id                  => l_epe.pl_id,
            p_pl_typ_id              => l_epe.pl_typ_id,
            p_opt_id                 => l_opt.opt_id,
            p_ler_id                 => l_epe.ler_id,
	    p_ctfn_determine_cd      => l_ctfn.ctfn_determine_cd);     -- Bug 5887665
        end if;
      end loop;
      --
    else
      hr_utility.set_location('IK Else Write CTFN',99);
      --
      for l_ctfn in c_pl_rstrn_ctfn ( nvl(l_fonm_cvg_strt_dt, l_effective_date)) loop -- FONM
        l_ctfn_received:='N';
        if l_check_received then
          hr_utility.set_location('IK Check ctfn TRUE',89);
          open c_ctfn_received(
            p_pgm_id           =>l_epe.pgm_id,
            p_pl_id            =>l_epe.pl_id,
            p_enrt_ctfn_typ_cd =>l_ctfn.enrt_ctfn_typ_cd,
            p_person_id        =>l_epe.person_id,
            cv_effective_date  => nvl(l_fonm_cvg_strt_dt,l_effective_date) -- FONM
          );
          fetch c_ctfn_received into l_ctfn_received;
          close c_ctfn_received;
        end if;
        if l_ctfn_received='N' then
          --
          hr_utility.set_location('IK l_ctfn_received=N',99) ;
          --
          ben_determine_chc_ctfn.write_ctfn
           (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
            p_enrt_bnft_id           => l_enrt_bnft_id,
            p_enrt_ctfn_typ_cd       => l_ctfn.enrt_ctfn_typ_cd,
            p_rqd_flag               => l_ctfn.rqd_flag,
            p_ctfn_rqd_when_rl       => l_ctfn.ctfn_rqd_when_rl,
            p_business_group_id      => l_epe.business_group_id,
            p_effective_date         => l_effective_date, -- FONM  nvl(p_lf_evt_ocrd_dt,p_effective_date),
            p_assignment_id          => l_asg.assignment_id,
            p_organization_id        => l_asg.organization_id,
            p_jurisdiction_code      => l_jurisdiction_code,
            p_pgm_id                 => l_epe.pgm_id,
            p_pl_id                  => l_epe.pl_id,
            p_pl_typ_id              => l_epe.pl_typ_id,
            p_opt_id                 => l_opt.opt_id,
            p_ler_id                 => l_epe.ler_id,
	    p_ctfn_determine_cd      => l_ctfn.ctfn_determine_cd);     -- Bug 5887665
         end if;
       end loop;
    end if;
    ----Enhancement 8716693

    if l_force_rstr and nvl(l_carry_fwd_cert,'N') = 'Y' then
       ---Check if there is any electable choice certification created for the current epe
       open c_chk_bnft_cert(l_epe.business_group_id);
       fetch c_chk_bnft_cert into l_chk_bnft_cert;
       if c_chk_bnft_cert%notfound then
          hr_utility.set_location('bnft cert not found',99) ;
	  hr_utility.set_location('get the previous LE cert',99) ;
          for l_prev_le_cert in c_prev_le_cert( l_get_cvg_rstr.business_group_id,
	                                        l_get_cvg_rstr.elig_per_elctbl_chc_id,l_combined_val) loop --Bug 8767376
	     hr_utility.set_location('l_get_cvg_rstr.elig_per_elctbl_chc_id : '||l_get_cvg_rstr.elig_per_elctbl_chc_id,99) ;

	     l_ctfn_received:='N';
	     open c_ctfn_received(
                 p_pgm_id           =>l_epe.pgm_id,
		 p_pl_id            =>l_epe.pl_id,
		 p_enrt_ctfn_typ_cd =>l_prev_le_cert.enrt_ctfn_typ_cd,
		 p_person_id        =>l_epe.person_id,
		 cv_effective_date   =>nvl(l_fonm_cvg_strt_dt, l_effective_date) -- FONM
				   );
	      fetch c_ctfn_received into l_ctfn_received;
              close c_ctfn_received;
	      hr_utility.set_location('l_ctfn_received : '||l_ctfn_received,99) ;
              if l_ctfn_received='N' then

		 hr_utility.set_location('IK l_ctfn_received=N',99) ;
                 --
		 hr_utility.set_location('p_elig_per_elctbl_chc_id : '||p_elig_per_elctbl_chc_id,99) ;
		 hr_utility.set_location('l_prev_le_cert.enrt_ctfn_typ_cd : '||l_prev_le_cert.enrt_ctfn_typ_cd,99) ;
		 hr_utility.set_location('l_enrt_bnft_id : '||l_enrt_bnft_id,99) ;
		 hr_utility.set_location('l_prev_le_cert.enrt_ctfn_typ_cd : '||l_prev_le_cert.enrt_ctfn_typ_cd,99) ;
		 ben_determine_chc_ctfn.write_ctfn
			(p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
			 p_enrt_bnft_id           => l_enrt_bnft_id,
			p_enrt_ctfn_typ_cd       => l_prev_le_cert.enrt_ctfn_typ_cd,
			p_rqd_flag               => l_prev_le_cert.rqd_flag,
			p_ctfn_rqd_when_rl       => null,
			p_business_group_id      => l_epe.business_group_id,
			p_effective_date         => l_effective_date,
			p_assignment_id          => l_asg.assignment_id,
			p_organization_id        => l_asg.organization_id,
			p_jurisdiction_code      => l_jurisdiction_code,
			p_pgm_id                 => l_epe.pgm_id,
			p_pl_id                  => l_epe.pl_id,
			p_pl_typ_id              => l_epe.pl_typ_id,
			p_opt_id                 => l_opt.opt_id,
			p_ler_id                 => l_epe.ler_id,
			p_ctfn_determine_cd      => l_prev_le_cert.ctfn_determine_cd);
	      end if;
	  end loop;
       end if;
       close c_chk_bnft_cert;
    end if;
    --------Enhancement	8716693

  end write_ctfn;
  --
BEGIN
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  --
  -- Bug 1895846
  open c_epe_in_pndg ;
    --
    fetch c_epe_in_pndg into l_dummy ;
    if c_epe_in_pndg%found then
      --
      hr_utility.set_location ('Suspended or Pending work flow records exist ' , 10);
      hr_utility.set_location ('Leaving '||l_package,10);
      close c_epe_in_pndg ;
      return ;
      --
    end if;
    close c_epe_in_pndg ;
    --
  -- put a row in fnd_sessions
  --
  g_old_val := hr_api.g_number; /*0;changed for 3497676 */

      /* when the 1st coverage is calculated as 0, the enrt bnft row was not
      being created because g_old_val is initialised to 0 */
  --
  -- Edit to insure that the input p_effective_date has a value
  --
  If (p_effective_date is null) then
    --
    fnd_message.set_name('BEN','BEN_91837_BENCVRGE_INPT_EFFDT');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',
                           to_char(p_elig_per_elctbl_chc_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.raise_error;
    --
  end if;
  --
  -- Edit to insure that the input p_elig_per_elctbl_chc_id has a value
  --
  If (p_elig_per_elctbl_chc_id is null) then
    --
    fnd_message.set_name('BEN','BEN_91838_BENCVRGE_INPT_EC');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.raise_error;
    --
  end if;
  --
  -- Deduce effective date
  --
  if p_lf_evt_ocrd_dt is not null then
    --
    l_effective_date := p_lf_evt_ocrd_dt;
    --
  else
    --
    l_effective_date := p_effective_date;
    --
  end if;
  -- FONM
  if ben_manage_life_events.fonm = 'Y' then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt;
     --
  end if;
  --
  -- put a row into fnd_sessions
  --
  dt_fndate.change_ses_date
    (p_ses_date => p_effective_date,
     p_commit   => l_commit);
  --
  l_not_found := false;
  --
  -- Walk the comp object tree for the electable choice and get
  -- the appropriate coverage details
  --
  hr_utility.set_location ('pl_id  '||ben_epe_cache.g_currcobjepe_row.pl_id,10);
  hr_utility.set_location ('elig choice id'||p_elig_per_elctbl_chc_id,11);
  ben_cvg_cache.epecobjtree_getcvgdets
    (p_epe_id         => p_elig_per_elctbl_chc_id
    ,p_epe_pl_id      => ben_epe_cache.g_currcobjepe_row.pl_id
    ,p_epe_plip_id    => ben_epe_cache.g_currcobjepe_row.plip_id
    ,p_epe_oipl_id    => ben_epe_cache.g_currcobjepe_row.oipl_id
    ,p_effective_date => nvl(l_fonm_cvg_strt_dt, l_effective_date) -- FONM  need to use new date
    --
    ,p_cvg_set        => l_cvg
    );
  --
/*  if l_cvg.count = 0 then
    --
    return;
    --
  end if;
*/
  --
  hr_utility.set_location ('open c_epe ',10);
  open c_epe;
    --
    fetch c_epe into l_epe;
    --
    if c_epe%notfound then
      --
      close c_epe;
      fnd_message.set_name('BEN','BEN_91839_BENCVRGE_EPE_NF');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',
                             to_char(p_elig_per_elctbl_chc_id));
      fnd_message.raise_error;
      --
    end if;
    --
  close c_epe;
  hr_utility.set_location ('close c_epe ',10);
  hr_utility.set_location ('pl_id'||l_epe.pl_id,10);
  if p_calculate_only_mode then
    ben_cvg_cache.epecobjtree_getcvgdets
      (p_epe_id         => p_elig_per_elctbl_chc_id
      ,p_epe_pl_id      => l_epe.pl_id
      ,p_epe_plip_id    => l_epe.plip_id
      ,p_epe_oipl_id    => l_epe.oipl_id
      ,p_effective_date => nvl(l_fonm_cvg_strt_dt, l_effective_date) -- FONM need to pass new date
      ,p_cvg_set        => l_cvg
      );
  end if;
      --
  if l_cvg.count = 0 then
    --
    -- Bug 4954541 - For unrestricted, if no coverage found, then we should delete ENB record
    --               which we would have reused otherwise. If we dont delete ENB, then the rate
    --               gets tied to the ENB (which gets deleted later in bebmures.clear_cache()
    --               This leads to dangling ECR.
    --
    l_dummy := null;
    open c_unrest(l_epe.ler_id);
       fetch c_unrest into l_dummy;
    close c_unrest;
    --
    if l_dummy = 'Y'
    then
      --
      hr_utility.set_location('No Coverage For EPE_ID = ' || p_elig_per_elctbl_chc_id, 8787);
      l_enrt_bnft_id := ben_manage_unres_life_events.enb_exists(p_elig_per_elctbl_chc_id,1);
      hr_utility.set_location('l_enrt_bnft_id = ' || l_enrt_bnft_id, 8787);
      --
      IF l_enrt_bnft_id is not null
      THEN
         --
         delete from ben_enrt_Bnft
         where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
         --
      END IF;
      --
    end if;
    --
    return;
    --
  end if;
  --
  l_person_id := l_epe.person_id;
  --
  if l_cvg(0).cvg_mlt_cd is null then
    --
    fnd_message.set_name('BEN','BEN_91840_BENCVRGE_MLT_CD_RQD');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',to_char(l_epe.person_id));
    fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
    fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
    fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
    fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
    fnd_message.set_token('PLIP_ID',to_char(l_epe.plip_id));
    fnd_message.set_token('PTIP_ID',to_char(l_epe.ptip_id));
    fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',
                           to_char(p_elig_per_elctbl_chc_id));
    fnd_message.raise_error;
    --
  end if;
  --
  if l_cvg(0).cvg_mlt_cd in ('FLFX','CL','FLPCLRNG','CLPFLRNG','FLFXPCL') then
    --
    if l_cvg(0).val is null and l_cvg(0).entr_val_at_enrt_flag = 'N' then
      --
      fnd_message.set_name('BEN','BEN_91841_BENCVRGE_VAL_RQD');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('PERSON_ID',to_char(l_epe.person_id));
      fnd_message.set_token('CALC_MTHD',l_cvg(0).cvg_mlt_cd);
      fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
      fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
      fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
      fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
      fnd_message.set_token('PLIP_ID',to_char(l_epe.plip_id));
      fnd_message.set_token('PTIP_ID',to_char(l_epe.ptip_id));
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if l_cvg(0).cvg_mlt_cd in ('CLRNG','FLPCLRNG','CLPFLRNG','FLRNG') then
    --
    if l_cvg(0).mn_val is null or
       l_cvg(0).mx_val is null or
       l_cvg(0).incrmt_val is null then
      --
      fnd_message.set_name('BEN','BEN_91842_BENCVRGE_MX_MN_INC_R');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('PERSON_ID',to_char(l_epe.person_id));
      fnd_message.set_token('CALC_MTHD',l_cvg(0).cvg_mlt_cd);
      fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
      fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
      fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
      fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
      fnd_message.set_token('PLIP_ID',to_char(l_epe.plip_id));
      fnd_message.set_token('PTIP_ID',to_char(l_epe.ptip_id));
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if l_cvg(0).cvg_mlt_cd in ('CL','CLRNG','FLFXPCL','FLPCLRNG','CLPFLRNG') then
    --
    if l_cvg(0).comp_lvl_fctr_id is null then
      --
      fnd_message.set_name('BEN','BEN_91843_BENCVRGE_NULL_CLF');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('PERSON_ID',to_char(l_epe.person_id));
      fnd_message.set_token('CALC_MTHD',l_cvg(0).cvg_mlt_cd);
      fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
      fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
      fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
      fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
      fnd_message.set_token('PLIP_ID',to_char(l_epe.plip_id));
      fnd_message.set_token('PTIP_ID',to_char(l_epe.ptip_id));
      fnd_message.raise_error;
      --
    end if;
    --
    ben_derive_factors.determine_compensation
     (p_comp_lvl_fctr_id     => l_cvg(0).comp_lvl_fctr_id,
      p_person_id            => l_epe.person_id,
      p_pgm_id               => l_epe.pgm_id ,
      p_pl_id                => l_epe.pl_id,
      p_oipl_id              => l_epe.oipl_id,
      p_per_in_ler_id        => l_epe.per_in_ler_id,
      p_business_group_id    => l_epe.business_group_id,
      p_perform_rounding_flg => true,
      p_effective_date       => nvl(p_lf_evt_ocrd_dt,p_effective_date),
      p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
      p_calc_bal_to_date     => null ,
      p_cal_for              => 'R',
      p_value                => l_compensation_value,
      p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt);
    --
    if l_compensation_value is null /*or l_compensation_value = 0 commented for 3497676 */ then
      --
      open c_clf(l_cvg(0).comp_lvl_fctr_id);
      fetch c_clf into l_clf;
      close c_clf;

      --
      fnd_message.set_name('BEN','BEN_92488_BENCVRGE_INVALID_VAL');
      fnd_message.set_token('PERSON_ID',l_epe.person_id);
      /*
      if l_clf.comp_src_cd = 'STTDCOMP' then

         fnd_message.set_token('COMP_CODE',' stated Salary, '||l_clf.name);

      elsif l_clf.comp_src_cd = 'BALTYP' then

         fnd_message.set_token('COMP_CODE',' benefits balance, '||l_clf.name);

      elsif  l_clf.comp_src_cd = 'BNFTBALTYP' then

         fnd_message.set_token('COMP_CODE',' defined balance, '||l_clf.name);

      end if;
      */
      --
      fnd_message.set_token('COMP_FCTR',hr_general.decode_lookup
                                           ( p_lookup_type => 'BEN_COMP_SRC' ,
                                             p_lookup_code => l_clf.comp_src_cd
                                             )
                                );

      fnd_message.set_token('COMP_CODE',l_clf.name);
      fnd_message.set_token('PACKAGE',l_package);
      raise ben_manage_life_events.g_record_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location (' BDVR_MN ',10);

  ben_determine_variable_rates.main -- FONM procedure have to take care of it
    (p_person_id              => l_epe.person_id,
     p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
     p_cvg_amt_calc_mthd_id   => l_cvg(0).cvg_amt_calc_mthd_id,
     p_effective_date         => p_effective_date,
     p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
     p_entr_val_at_enrt_flag  => l_entr_val_at_enrt_flag, -- Bug 7414757
     p_val                    => l_vr_val,        -- output
     p_mn_elcn_val            => l_mn_elcn_val ,
     p_mx_elcn_val            => l_mx_elcn_val,
     p_incrmnt_elcn_val       => l_incrmnt_elcn_val,
     p_dflt_elcn_val          => l_dflt_elcn_val ,  -- in coverage
     p_tx_typ_cd              => l_dummy_char,
     p_acty_typ_cd            => l_dummy_char,
     p_vrbl_rt_trtmt_cd       => l_vr_trtmt_cd,
     p_ann_mn_elcn_val        => l_vr_ann_mn_elcn_val,
     p_ann_mx_elcn_val        => l_vr_ann_mx_elcn_val,
     p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
     p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
     p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
     p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl );  -- output
     hr_utility.set_location (' Dn BDVR_MN ',10);
  -- this variabl intialisation used to chek whether the benefit crossed the max limit
  -- in benefit write. if the vapro defined then then ultimate level is used
  -- if there is no vapro then benefit level used for the validation bug:1433393

  hr_utility.set_location(' treatment code ' || l_vr_trtmt_cd  ||' ' || l_vr_val , 999);

  if l_vr_val is not null  or l_vr_trtmt_cd is not null  then
     l_vapro_exist := 'Y' ;
     --- Tilak : this code is not validating whether the enter at enrollemt is defined
     --- in either side ,(Coverage,VAPRO), this just work on the treatment code
     ---  the User has to make sure both the side has the same setup like enter at enrollemt
     --
     if l_vr_trtmt_cd = 'RPLC' then
        l_perform_rounding_flg := false;
        l_mn_elcn_val      := nvl(l_mn_elcn_val,l_cvg(0).mn_val) ;
        l_mx_elcn_val      := nvl(l_mx_elcn_val,l_cvg(0).mx_val) ;
        l_incrmnt_elcn_val := nvl(l_incrmnt_elcn_val,l_cvg(0).incrmt_val );
        l_dflt_elcn_val    := nvl(l_dflt_elcn_val , l_cvg(0).dflt_val );

     elsif  l_vr_trtmt_cd = 'ADDTO' then

        l_mn_elcn_val      := nvl(l_mn_elcn_val,0)+ nvl(l_cvg(0).mn_val,0) ;
        l_mx_elcn_val      := nvl(l_mx_elcn_val,0)+ nvl(l_cvg(0).mx_val,0) ;
        l_incrmnt_elcn_val := nvl(l_incrmnt_elcn_val,0)+ nvl(l_cvg(0).incrmt_val,0);
        l_dflt_elcn_val    := nvl(l_dflt_elcn_val,0)+ nvl(l_cvg(0).dflt_val,0 );
     elsif l_vr_trtmt_cd = 'SF' then
        l_mn_elcn_val      := nvl(l_cvg(0).mn_val,0)-nvl(l_mn_elcn_val,0) ;
        l_mx_elcn_val      := nvl(l_cvg(0).mx_val,0)-nvl(l_mx_elcn_val,0) ;
        l_incrmnt_elcn_val := nvl(l_cvg(0).incrmt_val,0)-nvl(l_incrmnt_elcn_val,0);
        l_dflt_elcn_val    := nvl(l_cvg(0).dflt_val,0 )-nvl(l_dflt_elcn_val,0);
     elsif l_vr_trtmt_cd = 'MB' then
        -- here the code doesnt bother to check values are defined in both
        -- coverage and vapro, if the value are not defined either side
        -- multiply will return 0 , consider as setup error

        l_mn_elcn_val      := nvl(l_cvg(0).mn_val,0)*nvl(l_mn_elcn_val,0) ;
        l_mx_elcn_val      := nvl(l_cvg(0).mx_val,0)*nvl(l_mx_elcn_val,0) ;
        l_incrmnt_elcn_val := nvl(l_cvg(0).incrmt_val,0)*nvl(l_incrmnt_elcn_val,0);
        l_dflt_elcn_val    := nvl(l_cvg(0).dflt_val,0 )*nvl(l_dflt_elcn_val,0);
     else
        l_mn_elcn_val      := l_cvg(0).mn_val ;
        l_mx_elcn_val      := l_cvg(0).mx_val ;
        l_dflt_elcn_val    := l_cvg(0).dflt_val ;
        l_incrmnt_elcn_val := l_cvg(0).incrmt_val ;
     end if;
  else
        l_mn_elcn_val      := l_cvg(0).mn_val ;
        l_mx_elcn_val      := l_cvg(0).mx_val ;
        l_dflt_elcn_val    := l_cvg(0).dflt_val ;
        l_incrmnt_elcn_val := l_cvg(0).incrmt_val ;

     ---
  end if ;

  hr_utility.set_location('min max ' || l_mn_elcn_val  ||' ' || l_mx_elcn_val|| ' '|| l_vapro_exist , 999);
  --
  l_ccm_max_val := l_mx_elcn_val; /* Bug 3828288 */
  --
--Bug 6054310 -- This condition should only be there for NSVU
  --l_vr_val := nvl(l_vr_val, l_dflt_elcn_val);      /* 5933576 - When vr_val is null, then set it to default val */
--Bug 6054310
  --
  open c_asg(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
  fetch c_asg into l_asg;
  close c_asg;

  open c_state(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
  fetch c_state into l_state;
  close c_state;

--  if l_state.region_2 is not null then
--    l_jurisdiction_code :=
--       pay_mag_utils.lookup_jurisdiction_code
--         (p_state => l_state.region_2);
--  end if;

  hr_utility.set_location ('l_ler_id '||l_ler_id,55);
  hr_utility.set_location ('l_pl_id '||l_pl_id,55);
  hr_utility.set_location ('l_oipl_id '||l_oipl_id,55);
  hr_utility.set_location ('l_business_group_id '||l_business_group_id,55);
  hr_utility.set_location ('l_cvg(0).bnft_or_option_rstrctn_cd '||
  l_cvg(0).bnft_or_option_rstrctn_cd,33);

  l_pl_id             := l_epe.pl_id;
  l_ler_id            := l_epe.ler_id;
  l_oipl_id           := l_epe.oipl_id;
  l_business_group_id := l_epe.business_group_id;
  --
  -- We fetch Restrictions of both types 'BNFT' and 'OPT' as we always want
  -- to check the min/max benefit amount, even if the restriction says
  -- "Option Restriction Applies". (1198549)
  --
  open c_ler_rstrn( nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
  fetch c_ler_rstrn into l_rstrn;
  if c_ler_rstrn%notfound then
    hr_utility.set_location ('c_ler_rstrn not found ',33);
    close c_ler_rstrn;

    open c_pl_rstrn( nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM;
    fetch c_pl_rstrn into l_rstrn;

    if c_pl_rstrn%notfound then
      hr_utility.set_location ('c_pl_rstrn not found ',33);
      l_rstrn_found := false;
    else
      hr_utility.set_location ('c_pl_rstrn found ',33);
      hr_utility.set_location ('l_rstrn.ler_bnft_rstrn_id '||l_rstrn.ler_bnft_rstrn_id,33);
      l_rstrn_found := true;
    end if;
    close c_pl_rstrn;
  else
    hr_utility.set_location ('c_ler_rstrn found ',33);
    hr_utility.set_location ('l_rstrn.ler_bnft_rstrn_id '||l_rstrn.ler_bnft_rstrn_id,33);
    l_ler_bnft_rstrn_id := l_rstrn.ler_bnft_rstrn_id;
    l_rstrn_found := true;
    close c_ler_rstrn;
  end if;
  --
  -----------------Enhancement	8716693
   ----Get the profile value
   l_carry_fwd_cert := 'N';
   l_carry_fwd_cert := fnd_profile.value('BEN_CARRY_FWD_CERT');
   hr_utility.set_location ('l_carry_fwd_cert,enh : '||l_carry_fwd_cert,5345324);
   if nvl(l_carry_fwd_cert,'N') = 'Y' then
     l_force_rstr := false;
     hr_utility.set_location ('enh',5345324);
     hr_utility.set_location ('l_rstrn.mx_cvg_wcfn_amt : '||l_rstrn.mx_cvg_wcfn_amt,5345324);
     hr_utility.set_location ('l_rstrn.mx_cvg_alwd_amt : '||l_rstrn.mx_cvg_alwd_amt,5345324);
     -------check if the current LE has electability or not
     open c_get_pil_elctbl;
     fetch c_get_pil_elctbl into l_get_pil_elctbl;
     if c_get_pil_elctbl%found then  ---Fetch the electable choice info.
        if l_rstrn.mx_cvg_alwd_amt is null and l_rstrn.mx_cvg_wcfn_amt is null then

     open c_get_prev_pil(l_person_id);
     fetch c_get_prev_pil into l_get_prev_pil;
     if c_get_prev_pil%found then
        hr_utility.set_location ('prev pil found',53453245);
	hr_utility.set_location ('l_get_prev_pil.per_in_ler_id : '||l_get_prev_pil.per_in_ler_id,5345324);
	---Check if the election is suspended in the Prev LE or not.
        open c_chk_prev_sus_enr(l_get_prev_pil.per_in_ler_id,l_get_pil_elctbl.pgm_id,l_get_pil_elctbl.pl_id,l_get_pil_elctbl.oipl_id);
	fetch c_chk_prev_sus_enr into l_chk_prev_sus_enr;
	   if c_chk_prev_sus_enr%found then
	   hr_utility.set_location ('prev election suspended',5345324);
	   ---If suspended,then get the previous LE cvg restrictions.
	   open c_get_cvg_rstr(l_get_prev_pil.per_in_ler_id);
	   fetch c_get_cvg_rstr into l_get_cvg_rstr;
	   ---get the LE which has cvg set-up
            hr_utility.set_location ('cvg rstr found',53453245);
	    l_rstrn_found := true;
	    l_force_rstr := true;
            l_rstrn.mx_cvg_wcfn_amt := l_get_cvg_rstr.MX_VAL;
            l_rstrn.mx_cvg_alwd_amt := l_get_cvg_rstr.MX_WOUT_CTFN_VAL;
	    hr_utility.set_location ('l_rstrn.dflt_to_asn_pndg_ctfn_cd : '||l_rstrn.dflt_to_asn_pndg_ctfn_cd,53453245);
	    hr_utility.set_location ('l_rstrn.mx_cvg_wcfn_amt : '||l_get_cvg_rstr.MX_VAL,53453245);
	    hr_utility.set_location ('l_rstrn.mx_cvg_alwd_amt : '||l_get_cvg_rstr.MX_WOUT_CTFN_VAL,53453245);
	    close c_get_cvg_rstr;
	   -- close c_ler_rstrn;
           end if;
	close c_chk_prev_sus_enr;

     end if;
     close c_get_prev_pil;
     end if;
     end if;
     close c_get_pil_elctbl;

   end if;
     -------------------Enhancement 8716693
  --
  /*
  l_cvg_rstn_max_wout_cert := l_rstrn.mx_cvg_alwd_amt;   Bug 3828288
  l_cvg_rstn_max_with_cert := l_rstrn.mx_cvg_wcfn_amt;   Bug 3828288
  */
  --
   /* Supriya Starts bug 5529258 */

  l_DFLT_TO_ASN_PNDG_CTFN_CD := l_rstrn.dflt_to_asn_pndg_ctfn_cd;

  If (l_DFLT_TO_ASN_PNDG_CTFN_CD = 'RL') then

    if l_epe.oipl_id is not null
    then

       open c_opt(l_epe.oipl_id, nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
       fetch c_opt into l_opt;
       close c_opt;
    end if;



      l_dflt_to_asn_pndg_ctfn_cd :=
        ben_sspndd_enrollment.get_dflt_to_asn_pndg_ctfn_cd
          (p_dflt_to_asn_pndg_ctfn_rl => l_rstrn.dflt_to_asn_pndg_ctfn_rl
          ,p_person_id                => l_epe.person_id
          ,p_per_in_ler_id            => l_epe.per_in_ler_id
          ,p_assignment_id            => l_asg.assignment_id
          ,p_organization_id          => l_asg.organization_id
          ,p_business_group_id        => l_epe.business_group_id
          ,p_pgm_id                   => l_epe.pgm_id
          ,p_pl_id                    => l_epe.pl_id
          ,p_pl_typ_id                => l_epe.pl_typ_id
          ,p_opt_id                   => l_opt.opt_id
          ,p_ler_id                   => l_epe.ler_id
          ,p_jurisdiction_code        => l_jurisdiction_code  -- not needed just dummy
          ,p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id
          ,p_effective_date           => p_effective_date
          ,p_prtt_enrt_rslt_id        => l_epe.prtt_enrt_rslt_id
          ,p_interim_epe_id           => l_interim_elctbl_chc_id
          ,p_interim_bnft_amt         => l_interim_bnft_amt
          );

      hr_utility.set_location(' l_dflt_to_asn_pndg_ctfn_cd ' || l_dflt_to_asn_pndg_ctfn_cd,99095);

       IF l_interim_elctbl_chc_id IS NOT NULL THEN
        --
          l_dflt_to_asn_pndg_ctfn_cd := null;
	   hr_utility.set_location(' l_dflt_to_asn_pndg_ctfn_cd ' || l_dflt_to_asn_pndg_ctfn_cd,99096);
        --
       END IF;
       --
     l_rstrn.dflt_to_asn_pndg_ctfn_cd  := l_DFLT_TO_ASN_PNDG_CTFN_CD ;

      hr_utility.set_location('SSARAKR l_dflt_to_asn_pndg_ctfn_cd ' || l_rstrn.dflt_to_asn_pndg_ctfn_cd,99097);

    End if;

  /* Supriya Ends bug 5529258  */

  if l_rstrn_found and l_rstrn.cvg_incr_r_decr_only_cd is not null then
    l_incr_r_decr_cd := l_rstrn.cvg_incr_r_decr_only_cd;
  else
    l_incr_r_decr_cd := l_cvg(0).cvg_incr_r_decr_only_cd;
  end if;

  hr_utility.set_location ('l_incr_r_decr_cd '||l_incr_r_decr_cd,33);
  --
  -- We check increases only if the restriction code is 'BNFT', so make
  -- the "increases" values nulll.
  --
  if l_rstrn_found and
     (l_cvg(0).bnft_or_option_rstrctn_cd is null or
      l_cvg(0).bnft_or_option_rstrctn_cd = 'OPT') then
    --
    l_rstrn.mx_cvg_mlt_incr_num      := null;
    l_rstrn.mx_cvg_mlt_incr_wcf_num  := null;
    l_rstrn.mx_cvg_incr_alwd_amt     := null;
    l_rstrn.mx_cvg_incr_wcf_alwd_amt := null;
    --
  end if;
  --
  hr_utility.set_location (' open c_current_enrt ',10);
  open c_current_enrt(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM;
  fetch c_current_enrt into l_crnt_ordr_num,
                               l_bnft_amt,
                               l_current_enrt_present;
  close c_current_enrt;
  --
  if NVL(l_current_enrt_present,'N') = 'N' then
    --
    open c_current_enrt_sspndd(nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
    fetch c_current_enrt_sspndd into l_current_enrt_sspndd ;
    close c_current_enrt_sspndd;
    --
  end if;
  -- get the dflt_enrt_cd/rule
  --
  ben_enrolment_requirements.determine_dflt_enrt_cd(
      p_oipl_id           =>l_epe.oipl_id,
      p_plip_id           =>l_epe.plip_id,
      p_pl_id             =>l_epe.pl_id,
      p_ptip_id           =>l_epe.ptip_id,
      p_pgm_id            =>l_epe.pgm_id,
      p_ler_id            =>l_epe.ler_id,
      p_dflt_enrt_cd      =>l_dflt_enrt_cd,
      p_dflt_enrt_rl      =>l_dflt_enrt_rl,
      p_business_group_id =>l_epe.business_group_id,
      p_effective_date    => nvl(l_fonm_cvg_strt_dt, l_effective_date) -- FONM how this is used.
  );

  --- the dflt_enrt_cd is rule and global variable g_dflt_elcn_val has got value
  --- then use the value for l_dflt_elcn_val
  if l_dflt_enrt_cd = 'RL'  and ben_enrolment_requirements.g_dflt_elcn_val is not null then
     l_dflt_elcn_val:=ben_enrolment_requirements.g_dflt_elcn_val;
     --- once the value used nullify the value
     hr_utility.set_location ('formula default='||ben_enrolment_requirements.g_dflt_elcn_val,744);
     ben_enrolment_requirements.g_dflt_elcn_val := null ;
  end if ;
  --
  -- if this choice is a default and dflt_enrt_cd says
  -- keep same coverage then use the current benefit amount
  -- as the default.
  --
  if (l_dflt_enrt_cd in ('NSDCS','NNCS') and
      l_epe.dflt_flag='Y' and
      l_bnft_amt is not null) then
    hr_utility.set_location ('dflt_val='||l_bnft_amt,10);
    l_dflt_elcn_val:= l_bnft_amt;
  end if;
  --
  l_cvg_amount  := l_bnft_amt;
  hr_utility.set_location (' Dn EPE ELSIFs ',10);
  if l_cvg(0).cvg_mlt_cd = 'FLFX' then
    --
    l_ctfn_rqd  := 'N';
    l_write_rec := true;
    --
    l_val := round_val(
              p_val                    => l_cvg(0).val,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl
              );
    l_cvg_amount := l_val ;
    --
    ---bug validate the limit for benefir amount
    hr_utility.set_location ('limit_checks ' ,10);
    benutils.limit_checks
      (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
       p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
       p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
       p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
       p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
       p_assignment_id     => l_asg.assignment_id,
       p_organization_id   => l_asg.organization_id,
       p_business_group_id => l_epe.business_group_id,
       p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
       p_pgm_id            => l_epe.pgm_id,
       p_pl_id             => l_epe.pl_id,
       p_pl_typ_id         => l_epe.pl_typ_id,
       p_opt_id            => l_opt.opt_id,
       p_ler_id            => l_epe.ler_id,
       p_val               => l_val,
       p_state             => l_state.region_2);

    hr_utility.set_location (' CMC FLFX ',10);
    --
    ben_determine_coverage.combine_with_variable_val
      (p_vr_val           => l_vr_val,
       p_val              => l_val,
       p_vr_trtmt_cd      => l_vr_trtmt_cd,
       p_combined_val     => l_combined_val);
    --
--rtagarra
    --
    hr_utility.set_location ('l_dflt_enrt_cd'||l_dflt_enrt_cd,353235);
    hr_utility.set_location ('FLAG' || l_cvg(0).entr_val_at_enrt_flag,23542345);
    hr_utility.set_location ('l_bnft_amt ' ||l_bnft_amt,34534);
    hr_utility.set_location ('l_combined_val ' || l_combined_val,345345);
    --
    if l_dflt_enrt_cd in ('NSDCS','NNCS','NDCSEDR','NNCSEDR') and l_cvg(0).entr_val_at_enrt_flag = 'Y'  then
     --
     	hr_utility.set_location ('INSIDE 1 IF',53453245);
     --
      if l_bnft_amt is not null then
       --
	hr_utility.set_location ('INSIDE 2 IF',53453245);
	if l_bnft_amt between l_cvg(0).mn_val and l_cvg(0).mx_val then
	--
	hr_utility.set_location ('INSIDE 3 IF',53453245);
	  l_combined_val := l_bnft_amt ;
        --
        end if;
      --
     end if;
     --
   end if;
--rtagarra
    if l_rstrn_found then
      --
      ben_determine_coverage.chk_bnft_ctfn
         (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
          p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
          p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
          p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
          p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
          p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
          p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
          p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
          p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
          p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
          p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
          p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
          p_combined_val             => l_combined_val,
          p_crnt_bnft_amt            => l_bnft_amt,
          p_ordr_num                 => l_order_number,
          p_crnt_ordr_num            => l_crnt_ordr_num,
          p_ctfn_rqd                 => l_ctfn_rqd,
          p_write_rec                => l_write_rec,
          p_effective_date           => nvl(p_lf_evt_ocrd_dt,
                                            p_effective_date),
          p_assignment_id            => l_asg.assignment_id,
          p_organization_id          => l_asg.organization_id,
          p_business_group_id        => l_epe.business_group_id,
          p_pgm_id                   => l_epe.pgm_id,
          p_pl_id                    => l_epe.pl_id,
          p_pl_typ_id                => l_epe.pl_typ_id,
          p_opt_id                   => l_opt.opt_id,
          p_ler_id                   => l_epe.ler_id,
          p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
          p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
          p_jurisdiction_code        => l_jurisdiction_code,
          p_check_received           => l_check_received,
          /* Start of Changes for WWBUG: 2054708    added parameter   */
          p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
          /* End of Changes for WWBUG: 2054708    added parameter   */
--Bug 4644489
  	  p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
--End Bug 4644489
       --
    end if;
    --
    --BUG 4627840 -- We are ignoring the rule here.
    --
    hr_utility.set_location(' l_rstrn.mx_cvg_alwd_amt '||l_rstrn.mx_cvg_alwd_amt,189);
    hr_utility.set_location(' l_mx_cvg_wout_ctfn_val '||l_mx_cvg_wout_ctfn_val,189);
    hr_utility.set_location(' l_rstrn.mx_cvg_wcfn_amt '||l_rstrn.mx_cvg_wcfn_amt,189);
    --
    l_cvg_rstn_max_wout_cert := nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val);
    l_cvg_rstn_max_with_cert := l_rstrn.mx_cvg_wcfn_amt;
    --
/* if already enrolled, check there is any increases restriction */
    if l_write_rec then
       if l_bnft_amt is not null then
          --BUG 4223840

          --Bug 5236985 Added the l_cvg_rstn_max_with_cert not null condition
          --This necessary if the l_rstrn.mx_cvg_wcfn_amt is made null in the subsequent life events
          if l_cvg(0).entr_val_at_enrt_flag = 'Y' and l_bnft_amt > l_cvg_rstn_max_wout_cert and l_cvg_rstn_max_with_cert is not null then
            l_cvg_rstn_max_wout_cert := l_bnft_amt ;
            hr_utility.set_location('l_bnft_amt '||l_bnft_amt,188);
            hr_utility.set_location('l_cvg_rstn_max_wout_cert '||l_cvg_rstn_max_wout_cert,188);
          end if;
          --
          if l_rstrn.mx_cvg_incr_alwd_amt is not null then
             l_cvg_rstn_max_wout_cert  := l_bnft_amt + l_rstrn.mx_cvg_incr_alwd_amt;
             l_cvg_rstn_max_incr_wout_cert := l_bnft_amt + l_rstrn.mx_cvg_incr_alwd_amt;     /* Bug 3828288 */
          end if;
          if l_rstrn.mx_cvg_incr_wcf_alwd_amt is not null then
             l_rstrn.mx_cvg_wcfn_amt := l_bnft_amt + l_rstrn.mx_cvg_incr_wcf_alwd_amt ;
	     l_cvg_rstn_max_with_cert := l_rstrn.mx_cvg_wcfn_amt; ----Enhancement 8716693
             l_cvg_rstn_max_incr_with_cert := l_bnft_amt + l_rstrn.mx_cvg_incr_wcf_alwd_amt ; /* Bug 3828288 */
          end if;
       end if;
    end if;
    hr_utility.set_location('crtfn  ' || l_rstrn.mx_cvg_wcfn_amt,199);
    hr_utility.set_location('min val ' || l_mn_elcn_val,199);
    hr_utility.set_location('max val ' || l_mx_elcn_val,199);
    --
    if l_write_rec then
      --
      -- Bug 3828288
      -- For Flat Amount Calc Method consider
      --  Max Amount (L_MX_VAL_WO_CFN) as minimum of
      --      (1) P_CCM_MAX_VAL - Coverage Calc Method Max Value
      --      (2) P_CVG_RSTN_MAX_WOUT_CERT - Plan Coverage Restrictions - Max ,
      --      (3) P_CVG_RSTN_MAX_INCR_WOUT_CERT - Current + Plan Coverage Restriction Max Increase
      --  Max Amount With Certification (L_MX_VAL_WCFN) as minimum of
      --      (1) P_CCM_MAX_VAL - Coverage Calc Method Max Value
      --      (2) P_CVG_RSTN_MAX_WITH_CERT - Plan Coverage Restrictions - Max with Certification ,
      --      (3) P_CVG_RSTN_MAX_INCR_WITH_CERT - Current + Plan Coverage Restriction Max Increase with Certification
      --
      --bug#4256191 least of ultmt_upr_lmt, max value passed
      if l_ultmt_upr_lmt_calc_rl is not null then
        --
        l_upr_outputs := benutils.formula
                   (p_formula_id        => l_ultmt_upr_lmt_calc_rl,
                    p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
                    p_assignment_id     => l_asg.assignment_id,
                    p_organization_id   => l_asg.organization_id,
                    p_business_group_id => l_epe.business_group_id,
                    p_pgm_id            => l_epe.pgm_id,
                    p_pl_id             => l_epe.pl_id,
                    p_pl_typ_id         => l_epe.pl_typ_id,
                    p_opt_id            => l_opt.opt_id,
                    p_ler_id            => l_epe.ler_id,
                    -- FONM
                    p_param1             => 'BEN_IV_RT_STRT_DT',
                    p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                    p_param2             => 'BEN_IV_CVG_STRT_DT',
                    p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
                    p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id);
        --
        if l_upr_outputs(l_upr_outputs.first).value is not null then
          --
          l_ultmt_upr_lmt := fnd_number.canonical_to_number(l_upr_outputs(l_upr_outputs.first).value);
          --
        end if;
        --

      end if;
      get_least_value ( p_ccm_max_val                 =>
                                   least(l_ccm_max_val,nvl(l_ultmt_upr_lmt,l_ccm_max_val)),
                        p_cvg_rstn_max_incr_with_cert => nvl(l_cvg_rstn_max_incr_with_cert,l_cvg_rstn_max_incr_wout_cert),/* bug 4275929 ::max_incr_with_cert= max_incr_wout_certificate when max_incr_with_certificate is NUll */
                        p_cvg_rstn_max_with_cert      => nvl(l_cvg_rstn_max_with_cert,l_cvg_rstn_max_wout_cert),/* bug 4275929 :: max_with_certificate= max_wout_certificate when max_with_certificate is NUll */
                        p_cvg_rstn_max_incr_wout_cert => l_cvg_rstn_max_incr_wout_cert,
                        p_cvg_rstn_max_wout_cert      => l_cvg_rstn_max_wout_cert,
                        p_mx_val_wcfn                 => l_mx_val_wcfn,
                        p_mx_val_wo_cfn               => l_mx_val_wo_cfn
                       );
      hr_utility.set_location('l_ultmt_lwr_lmt_calc_rl = ' || l_ultmt_lwr_lmt_calc_rl, 9999);
      if l_ultmt_lwr_lmt_calc_rl is not null then
        --
        l_ult_lwr_outputs := benutils.formula
                   (p_formula_id        => l_ultmt_lwr_lmt_calc_rl,
                    p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
                    p_assignment_id     => l_asg.assignment_id,
                    p_organization_id   => l_asg.organization_id,
                    p_business_group_id => l_epe.business_group_id,
                    p_pgm_id            => l_epe.pgm_id,
                    p_pl_id             => l_epe.pl_id,
                    p_pl_typ_id         => l_epe.pl_typ_id,
                    p_opt_id            => l_opt.opt_id,
                    p_ler_id            => l_epe.ler_id,
                    -- FONM
                    p_param1             => 'BEN_IV_RT_STRT_DT',
                    p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                    p_param2             => 'BEN_IV_CVG_STRT_DT',
                    p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
                    p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id);
        --
        if l_ult_lwr_outputs(l_ult_lwr_outputs.first).value is not null then
          --
          l_ultmt_lwr_lmt := fnd_number.canonical_to_number(l_ult_lwr_outputs(l_ult_lwr_outputs.first).value);
          --
        end if;
        --
      end if;

      l_mn_elcn_val :=
	  greatest(l_mn_elcn_val, greatest(nvl(l_rstrn_mn_cvg_rqd_amt,l_mn_elcn_val),nvl(l_ultmt_lwr_lmt,l_mn_elcn_val)));

--Bug 4644489
--Write to the Benifts record the minimum coverage value as max(cvg_restrn_mn_amnt,cvg_calc_method)
	-- if (l_rstrn_mn_cvg_rqd_amt > l_mn_elcn_val) then
	--	l_mn_elcn_val := l_rstrn_mn_cvg_rqd_amt;
	-- end if;
--End Bug 4644489
      hr_utility.set_location('l_mn_elcn_val = ' || l_mn_elcn_val, 9999);
      hr_utility.set_location('l_ultmt_lwr_lmt = ' || l_ultmt_lwr_lmt, 9999);
      hr_utility.set_location('l_rstrn_mn_cvg_rqd_amt = ' || l_rstrn_mn_cvg_rqd_amt, 9999);
      hr_utility.set_location('l_mx_val_wcfn = ' || l_mx_val_wcfn, 9999);
      hr_utility.set_location('l_mx_val_wo_cfn = ' || l_mx_val_wo_cfn, 9999);
      -- Bug 3828288
      hr_utility.set_location('l_combined_val = ' || l_combined_val, 9999);
      hr_utility.set_location('l_cvg_amount = ' || l_cvg_amount, 9999);
      hr_utility.set_location('l_dflt_elcn_val = ' || l_dflt_elcn_val, 9999);
      --
      ben_determine_coverage.write_coverage
        (p_calculate_only_mode    => p_calculate_only_mode,
         p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
         p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
         p_val                    => l_combined_val,
         p_dflt_flag              => l_epe.dflt_flag,
         p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_business_group_id      => l_cvg(0).business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_person_id              => l_epe.person_id,
         p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
         p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
         p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
         p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
         p_rndg_cd                => l_cvg(0).rndg_cd,
         p_rndg_rl                => l_cvg(0).rndg_rl,
         p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
         p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
         p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         /* Code Prior To 3828288 Fix
         p_mx_val                 => nvl(l_rstrn.mx_cvg_wcfn_amt,l_mx_elcn_val),--mx withctfn,vapro
         */
         p_mx_val                 => l_mx_val_wcfn,                      /* Bug 3828288 */
         /*
                CODE PRIOR TO WWBUG: 2054078
         p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
         */
         /* Start of Changes for WWBUG: 2054078         */
         /* Code Prior To 3828288 Fix
         p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
         */
         p_mx_wout_ctfn_val       => l_mx_val_wo_cfn,                    /* Bug 3828288 */
         /* End of Changes for WWBUG: 2054078           */
         p_mn_val                 => l_mn_elcn_val,
         p_incrmt_val             => l_incrmnt_elcn_val,
         p_dflt_val               => l_dflt_elcn_val,
         p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
         p_perform_rounding_flg   => l_perform_rounding_flg,
         p_ordr_num               => l_order_number,
         p_ctfn_rqd_flag          => l_ctfn_rqd,
         p_enrt_bnft_id           => l_enrt_bnft_id,
         p_enb_valrow             => p_enb_valrow,
         p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
         p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
         p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
         p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
         p_bnft_amount            => l_cvg_amount,
         p_vapro_exist            => l_vapro_exist
         );
      --
      if l_ctfn_rqd = 'Y' then
        --
        write_ctfn;
        --
      end if;


           hr_utility.set_location('benefit row'||l_cvg(0).bnft_or_option_rstrctn_cd,111);
           hr_utility.set_location('oipl id '||l_epe.oipl_id,111);

      if l_rstrn_found and l_cvg(0).bnft_or_option_rstrctn_cd = 'BNFT' and
         l_cvg(0).entr_val_at_enrt_flag = 'Y' then
       --  if l_epe.oipl_id is null then /*ENH*/
           -- This is required only for enter value at enrollment case
           -- ENH We need to populate the right bnft_amout depending on the
           -- Interim Codes Min,Next Lower and Default Codes defined at the
           -- Plan Level . We will determine
           --
         l_interim_cd := substr(l_rstrn.dflt_to_asn_pndg_ctfn_cd,4,2) ;
         l_current_level_cd := substr(l_rstrn.dflt_to_asn_pndg_ctfn_cd,2,2);
         --
         l_current_plan_id := null ;
         l_current_oipl_id := null ;
         l_create_current_enb := false ;
             --
             if l_current_level_cd = 'AS' then
               --
               open c_current_enrt_in_pl_typ(l_epe.pl_typ_id,
                 nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))) ; -- FONM
               fetch c_current_enrt_in_pl_typ into l_current_plan_id,l_current_oipl_id ;
               if c_current_enrt_in_pl_typ%found then
                 l_create_current_enb := true ;
               end if;
               close c_current_enrt_in_pl_typ;
               --
             elsif l_current_level_cd = 'SE' then
               open c_current_enrt_in_pln(l_epe.pl_id, nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))) ; -- FONM
               fetch c_current_enrt_in_pln into l_current_plan_id,l_current_oipl_id ;
               if c_current_enrt_in_pln%found then
                 l_create_current_enb := true ;
               end if;
               close c_current_enrt_in_pln;
             elsif l_current_level_cd = 'SO' then
               -- Bug 2543071 changed the l_epe.pl_id to l_epe.oipl_id and added
               -- the if condition.
               if l_epe.oipl_id is not null then
                 open c_current_enrt_in_oipl(l_epe.oipl_id, nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))) ; -- FONM
                 fetch c_current_enrt_in_oipl into l_current_plan_id,l_current_oipl_id ;
                 if c_current_enrt_in_oipl%found then
                   l_create_current_enb := true ;
                 end if;
                 close c_current_enrt_in_oipl;
               end if;
             end if;
           ---------------
           hr_utility.set_location (' open c_current_enrt ',10);
           --open c_current_enrt_in_pln(l_epe.pl_id) ;
           --  fetch c_current_enrt_in_pln into l_current_plan_id,l_current_oipl_id ;
             --
             -- if c_current_enrt_in_pln%found then
             if l_create_current_enb then
               -- Take the current case
               l_interim_cd := substr(l_rstrn.dflt_to_asn_pndg_ctfn_cd,4,2);
             else
               -- Take the new case
               l_interim_cd := substr(l_rstrn.dflt_to_asn_pndg_ctfn_cd,7,2);
             end if;
             --
             if l_interim_cd = 'MN' then
               l_interim_bnft_val :=  l_mn_elcn_val ;
             elsif l_interim_cd = 'NL' then
               l_interim_bnft_val := nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val) ;
             elsif l_interim_cd = 'DF' then
               l_interim_bnft_val := l_dflt_elcn_val ;
             else -- for Same and Nothing we need not populate this amount
               l_interim_bnft_val := null ; -- l_dflt_elcn_val ;
             end if ;
           --close c_current_enrt_in_pln;
           --
           hr_utility.set_location('interim row',111);
           --CF Changes
           --
           if l_current_plan_id = l_epe.pl_id and
              nvl(l_current_oipl_id,-1) = nvl(l_epe.oipl_id,-1) then
             --
             open c_current_enb(l_epe.pl_id,l_epe.oipl_id,
                                nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))) ;
               fetch c_current_enb into l_current_enb ;
             --
             close c_current_enb ;
             --
           end if;
           --
           l_enrt_bnft_id :=  null;
           open c_unrest(l_epe.ler_id);
           fetch c_unrest into l_dummy;
           close c_unrest;
           if l_dummy = 'Y' then
             l_enrt_bnft_id := ben_manage_unres_life_events.enb_exists
                            (p_elig_per_elctbl_chc_id,0);
           end if;
           if not p_calculate_only_mode then
            --
             if l_enrt_bnft_id is not null then
             --
               ben_manage_unres_life_events.update_enrt_bnft
              (p_dflt_flag              => 'N',
               p_val_has_bn_prortd_flag => 'N',        -- change when prorating
               p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
               p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
               p_val                    => l_interim_bnft_val, -- l_rstrn.mx_cvg_alwd_amt, /*ENH */
               p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
               p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
               p_prtt_enrt_rslt_id      => null,
               p_business_group_id      => l_cvg(0).business_group_id,
               p_effective_date         => nvl(p_lf_evt_ocrd_dt,p_effective_date),
               p_program_application_id => fnd_global.prog_appl_id,
               p_program_id             => fnd_global.conc_program_id,
               p_request_id             => fnd_global.conc_request_id,
               p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
               p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
               p_crntly_enrld_flag      => 'N',
               p_ctfn_rqd_flag          => 'N',
               p_entr_val_at_enrt_flag  => 'N',
               p_mx_val                 => null,  -- max with ctfn
               p_mx_wout_ctfn_val       => null,  -- max without ctfn
               p_mn_val                 => null,
               p_incrmt_val             => null,
               p_dflt_val               => null,
               p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
               p_mx_wo_ctfn_flag        => 'Y',
               p_program_update_date    => sysdate,
               p_enrt_bnft_id           => l_enrt_bnft_id,
               p_ordr_num               => 0);
              --
             else
               --
               ben_enrt_bnft_api.create_enrt_bnft
              (p_validate               => false,
               p_dflt_flag              => 'N',
               p_val_has_bn_prortd_flag => 'N',        -- change when prorating
               p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
               p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
               p_val                    => l_interim_bnft_val, -- l_rstrn.mx_cvg_alwd_amt, /*ENH */
               p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
               p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
               p_prtt_enrt_rslt_id      => l_current_enb.prtt_enrt_rslt_id , -- CF null,
               p_business_group_id      => l_cvg(0).business_group_id,
               p_effective_date         => nvl(p_lf_evt_ocrd_dt,p_effective_date),
               p_program_application_id => fnd_global.prog_appl_id,
               p_program_id             => fnd_global.conc_program_id,
               p_request_id             => fnd_global.conc_request_id,
               p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
               p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
               p_crntly_enrld_flag      => 'N',
               p_ctfn_rqd_flag          => 'N',
               p_entr_val_at_enrt_flag  => 'N',
               p_mx_val                 => null,  -- max with ctfn
               p_mx_wout_ctfn_val       => null,  -- max without ctfn
               p_mn_val                 => null,
               p_incrmt_val             => null,
               p_dflt_val               => null,
               p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
               p_mx_wo_ctfn_flag        => 'Y',
               p_program_update_date    => sysdate,
               p_enrt_bnft_id           => l_enrt_bnft_id,
               p_object_version_number  => l_object_version_number,
               p_ordr_num               => 0);
              --
             end if;
             --
            end if;
          --
     end if;
      --
      l_current_enb := null ;
      --
    else
      --
      -- Update the electable choice to be not electable
      --
      if l_epe.elctbl_flag='Y' then
        --
        -- Check for calculate only mode
        --
        if not p_calculate_only_mode then
          --
          ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc(
             p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
             p_elctbl_flag             => 'N',
             p_dflt_flag               => 'N',
             p_object_version_number   => l_epe.object_version_number,
             p_effective_date          => p_effective_date,
             p_program_application_id  => fnd_global.prog_appl_id,
             p_program_id              => fnd_global.conc_program_id,
             p_request_id              => fnd_global.conc_request_id,
             p_program_update_date     => sysdate
          );
           --
           -- If enrolled will deenroll.
           --
           ben_newly_ineligible.main(
              p_person_id           => l_epe.person_id,
              p_pgm_id              => l_epe.pgm_id,
              p_pl_id               => l_epe.pl_id,
              p_oipl_id             => l_epe.oipl_id,
              p_business_group_id   => l_epe.business_group_id,
              p_ler_id              => l_epe.ler_id,
              p_effective_date      => p_effective_date -- FONM proc take care of it.
           );
          --
        end if;
        l_epe.elctbl_flag:='N';
        hr_utility.set_location('Electable choice was made not electable by bencvrge',29);
      end if;
      ben_determine_coverage.write_coverage
        (p_calculate_only_mode    => p_calculate_only_mode,
         p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
         p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
         p_val                    => l_combined_val,
         p_dflt_flag              => l_epe.dflt_flag,
         p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_business_group_id      => l_cvg(0).business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_person_id              => l_epe.person_id,
         p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
         p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
         p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
         p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
         p_rndg_cd                => l_cvg(0).rndg_cd,
         p_rndg_rl                => l_cvg(0).rndg_rl,
         p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
         p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
         p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         p_mx_val      => nvl(l_rstrn.mx_cvg_wcfn_amt, l_mx_elcn_val),  -- mx with ctfn
         /*
              CODE PRIOR TO WWBUG: 2054078
         p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
         */
         /* Start of Changes for WWBUG: 2054078         */
         p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
         /* End of Changes for WWBUG: 2054078           */
         p_mn_val                 => l_mn_elcn_val,
         p_incrmt_val             => l_incrmnt_elcn_val,
         p_dflt_val               => l_dflt_elcn_val,
         p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
         p_perform_rounding_flg   => l_perform_rounding_flg,
         p_ordr_num               => l_order_number,
         p_ctfn_rqd_flag          => l_ctfn_rqd,
         p_enrt_bnft_id           => l_enrt_bnft_id,
         p_enb_valrow             => p_enb_valrow,
         p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
         p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
         p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
         p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
         p_bnft_amount            => l_cvg_amount,
         p_vapro_exist            => l_vapro_exist
         );
      --
    end if;
    --
  elsif l_cvg(0).cvg_mlt_cd = 'CL' then
    --
    l_ctfn_rqd  := 'N';
    l_write_rec := true;
    --
    hr_utility.set_location (' CMC CL ',10);
    benutils.rt_typ_calc
      (p_val                    => l_cvg(0).val,
       p_val_2                  => l_compensation_value,
       p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
       p_calculated_val         => l_calculated_val);
    --
    l_val := round_val(
              p_val                    => l_calculated_val,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl
              );
    --
     l_cvg_amount := l_val ;
    ---bug validate the limit for benefir amount
    hr_utility.set_location ('limit_checks ',10);
    benutils.limit_checks
      (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
       p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
       p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
       p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
       p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
       p_assignment_id     => l_asg.assignment_id,
       p_organization_id   => l_asg.organization_id,
       p_business_group_id => l_epe.business_group_id,
       p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
       p_pgm_id            => l_epe.pgm_id,
       p_pl_id             => l_epe.pl_id,
       p_pl_typ_id         => l_epe.pl_typ_id,
       p_opt_id            => l_opt.opt_id,
       p_ler_id            => l_epe.ler_id,
       p_val               => l_val,
       p_state             => l_state.region_2);

    ---
    hr_utility.set_location (' rndg is'||l_val,10);
    ben_determine_coverage.combine_with_variable_val
      (p_vr_val                 => l_vr_val,
       p_val                    => l_val,
       p_vr_trtmt_cd            => l_vr_trtmt_cd,
       p_combined_val           => l_combined_val);
    --
    hr_utility.set_location (' varb is'||l_combined_val,10);
    --
    if l_rstrn_found then
      --
      ben_determine_coverage.chk_bnft_ctfn
         (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
          p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
          p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
          p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
          p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
          p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
          p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
          p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
          p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
          p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
          p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
          p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
          p_combined_val             => l_combined_val,
          p_crnt_bnft_amt            => l_bnft_amt,
          p_ordr_num                 => l_order_number,
          p_crnt_ordr_num            => l_crnt_ordr_num,
          p_ctfn_rqd                 => l_ctfn_rqd,
          p_write_rec                => l_write_rec,
          p_effective_date           => nvl(p_lf_evt_ocrd_dt,
                                            p_effective_date),
          p_assignment_id            => l_asg.assignment_id,
          p_organization_id          => l_asg.organization_id,
          p_business_group_id        => l_epe.business_group_id,
          p_pgm_id                   => l_epe.pgm_id,
          p_pl_id                    => l_epe.pl_id,
          p_pl_typ_id                => l_epe.pl_typ_id,
          p_opt_id                   => l_opt.opt_id,
          p_ler_id                   => l_epe.ler_id,
          p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
          p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
          p_jurisdiction_code        => l_jurisdiction_code,
          p_check_received           => l_check_received,
          /* Start of Changes for WWBUG: 2054078   added parameter */
          p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
          /* End of Changes for WWBUG: 2054078   added parameter */
--Bug 4644489
  	  p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
--End Bug 4644489
       --
    end if;
    --
    if l_write_rec then
      --
      ben_determine_coverage.write_coverage
        (p_calculate_only_mode    => p_calculate_only_mode,
         p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
         p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
         p_val                    => l_combined_val,
         p_dflt_flag              => l_epe.dflt_flag,
         p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_business_group_id      => l_cvg(0).business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_person_id              => l_epe.person_id,
         p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
         p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
         p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
         p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
         p_rndg_cd                => l_cvg(0).rndg_cd,
         p_rndg_rl                => l_cvg(0).rndg_rl,
         p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
         p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
         p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         p_mx_val      => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
         /*
             CODE PRIOR TO WWBUG: 2054078
         p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
         */
         /* Start of Changes for WWBUG: 2054078   */
         p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
         /* End of Changes for WWBUG: 2054078   */
         p_mn_val                 => l_cvg(0).mn_val,
         p_incrmt_val             => l_cvg(0).incrmt_val,
         p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
         p_dflt_val               => NVL(l_dflt_elcn_val,l_cvg(0).dflt_val),
         p_perform_rounding_flg   => l_perform_rounding_flg,
         p_ordr_num               => l_order_number,
         p_ctfn_rqd_flag          => l_ctfn_rqd,
         p_enrt_bnft_id           => l_enrt_bnft_id,
         p_enb_valrow             => p_enb_valrow,
         p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
         p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
         p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
         p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
         p_bnft_amount            => l_cvg_amount,
         p_vapro_exist            => l_vapro_exist
         );
      --
      if l_ctfn_rqd = 'Y'
        and not p_calculate_only_mode
      then
        --
        write_ctfn;
        --
      end if;
      --
    else
      --
      -- Update the electable choice to be not electable
      --
      if l_epe.elctbl_flag='Y' then
        --
        if not p_calculate_only_mode then
          --
          ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc(
             p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
             p_elctbl_flag             => 'N',
             p_dflt_flag               => 'N',
             p_object_version_number   => l_epe.object_version_number,
             p_effective_date          => p_effective_date,
             p_program_application_id  => fnd_global.prog_appl_id,
             p_program_id              => fnd_global.conc_program_id,
             p_request_id              => fnd_global.conc_request_id,
             p_program_update_date     => sysdate
          );
           --
           -- If enrolled will deenroll.
           --
           ben_newly_ineligible.main(
              p_person_id           => l_epe.person_id,
              p_pgm_id              => l_epe.pgm_id,
              p_pl_id               => l_epe.pl_id,
              p_oipl_id             => l_epe.oipl_id,
              p_business_group_id   => l_epe.business_group_id,
              p_ler_id              => l_epe.ler_id,
              p_effective_date      => p_effective_date
           );
          --
        end if;
        --
        l_epe.elctbl_flag:='N';
        hr_utility.set_location('Electable choice was made not electable by bencvrge',29);
      end if;
      ben_determine_coverage.write_coverage
        (p_calculate_only_mode    => p_calculate_only_mode,
         p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
         p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
         p_val                    => l_combined_val,
         p_dflt_flag              => l_epe.dflt_flag,
         p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_business_group_id      => l_cvg(0).business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_person_id              => l_epe.person_id,
         p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
         p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
         p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
         p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
         p_rndg_cd                => l_cvg(0).rndg_cd,
         p_rndg_rl                => l_cvg(0).rndg_rl,
         p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
         p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
         p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         p_mx_val      => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
         /*
              CODE PRIOR TO WWBUG: 2054078
         p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
         */
         /*   Start of Changes for WWBUG: 2054078               */
         p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
         /*   End of Changes for WWBUG: 2054078         */
         p_mn_val                 => l_cvg(0).mn_val,
         p_incrmt_val             => l_cvg(0).incrmt_val,
         p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
         p_dflt_val               => l_cvg(0).dflt_val,
         p_perform_rounding_flg   => l_perform_rounding_flg,
         p_ordr_num               => l_order_number,
         p_ctfn_rqd_flag          => l_ctfn_rqd,
         p_enrt_bnft_id           => l_enrt_bnft_id,
         p_enb_valrow             => p_enb_valrow,
         p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
         p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
         p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
         p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
         p_bnft_amount            => l_cvg_amount,
         p_vapro_exist            => l_vapro_exist
         );
      --
    end if;
    --
  elsif l_cvg(0).cvg_mlt_cd = 'FLRNG' then
    --
      hr_utility.set_location (' CMC FLRNG ',10);
    --
    hr_utility.set_location ('l_cvg-0.mx_val '||l_cvg(0).mx_val,33);
    hr_utility.set_location ('l_cvg-0.mn_val '||l_cvg(0).mn_val,33);
    --
    if l_cvg(0).lwr_lmt_calc_rl is not NULL then
      --
      l_lwr_outputs := benutils.formula
                   (p_formula_id        => l_cvg(0).lwr_lmt_calc_rl,
                    p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
                    p_assignment_id     => l_asg.assignment_id,
                    p_organization_id   => l_asg.organization_id,
                    p_business_group_id => l_epe.business_group_id,
                    p_pgm_id            => l_epe.pgm_id,
                    p_pl_id             => l_epe.pl_id,
                    p_pl_typ_id         => l_epe.pl_typ_id,
                    p_opt_id            => l_opt.opt_id,
                    p_ler_id            => l_epe.ler_id,
                    -- FONM
                    p_param1             => 'BEN_IV_RT_STRT_DT',
                    p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                    p_param2             => 'BEN_IV_CVG_STRT_DT',
                    p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
                    p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id);
      l_lwr_val := fnd_number.canonical_to_number(l_lwr_outputs(l_lwr_outputs.first).value);
      --
    elsif l_cvg(0).lwr_lmt_val is not null then
      l_lwr_val := l_cvg(0).lwr_lmt_val;
    end if;

    if l_cvg(0).upr_lmt_calc_rl is not NULL then
      --
      l_upr_outputs := benutils.formula
                   (p_formula_id        => l_cvg(0).upr_lmt_calc_rl,
                    p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
                    p_assignment_id     => l_asg.assignment_id,
                    p_organization_id   => l_asg.organization_id,
                    p_business_group_id => l_epe.business_group_id,
                    p_pgm_id            => l_epe.pgm_id,
                    p_pl_id             => l_epe.pl_id,
                    p_pl_typ_id         => l_epe.pl_typ_id,
                    p_opt_id            => l_opt.opt_id,
                    p_ler_id            => l_epe.ler_id,
                    -- FONM
                    p_param1             => 'BEN_IV_RT_STRT_DT',
                    p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                    p_param2             => 'BEN_IV_CVG_STRT_DT',
                    p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
                    p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id);
      l_upr_val := fnd_number.canonical_to_number(l_upr_outputs(l_upr_outputs.first).value);
      --
    elsif l_cvg(0).upr_lmt_val is not null then
      l_upr_val := l_cvg(0).upr_lmt_val;
    end if;

    i := nvl(l_lwr_val,l_cvg(0).mn_val);

    hr_utility.set_location ('l_lwr_val :'||l_lwr_val,32);
    hr_utility.set_location ('l_upr_val :'||l_upr_val,32);

    while i <= nvl(l_upr_val,l_cvg(0).mx_val) loop
      --
      hr_utility.set_location ('i = '||i,33);
      --
      l_ctfn_rqd  := 'N';
      l_write_rec := true;
      --
      if l_incr_r_decr_cd is null or
        ((l_incr_r_decr_cd='INCRO' and
          l_order_number > nvl(l_crnt_ordr_num,0)) or
         (l_incr_r_decr_cd='EQINCR' and
          l_order_number >=  nvl(l_crnt_ordr_num,0)) or
         (l_incr_r_decr_cd='DECRO' and
          l_order_number < nvl(l_crnt_ordr_num,0)) or
         (l_incr_r_decr_cd='EQDECR' and
          l_order_number <=  nvl(l_crnt_ordr_num,0))  or
          -- Start of 3806262
          l_incr_r_decr_cd='INCRCTF' or
	  --and l_order_number >  nvl(l_crnt_ordr_num,0)) or  -- Bug 6164688
          l_incr_r_decr_cd='DECRCTF'
	  --and l_order_number < nvl(l_crnt_ordr_num,0))      -- Bug 6164688
          ) then
          -- End of 3806262
          l_val := round_val(
              p_val                    => i,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl
              );
           l_cvg_amount := l_val ;
          --validate the limit for benefir amount
          hr_utility.set_location ('limit_checks ',10);
          benutils.limit_checks
          (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
              p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
              p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
              p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
              p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
              p_assignment_id     => l_asg.assignment_id,
              p_organization_id   => l_asg.organization_id,
              p_business_group_id => l_epe.business_group_id,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_pgm_id            => l_epe.pgm_id,
              p_pl_id             => l_epe.pl_id,
              p_pl_typ_id         => l_epe.pl_typ_id,
              p_opt_id            => l_opt.opt_id,
              p_ler_id            => l_epe.ler_id,
              p_val               => l_val,
              p_state             => l_state.region_2);

         --
         ben_determine_coverage.combine_with_variable_val
           (p_vr_val             => l_vr_val,
            p_val                => l_val,
            p_vr_trtmt_cd        => l_vr_trtmt_cd,
            p_combined_val       => l_combined_val);
         --
	 -- Bug 8940075 / 9008389 : Exchanged the code between if and the first elsif below

         if (l_dflt_enrt_cd in ('NSDCS','NNCS')
--                and i = nvl(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or
                  and l_combined_val = nvl(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or -- Bug 6068097
               (l_dflt_enrt_cd in ('NSDCS','NNCS')
                             and l_crnt_ordr_num = l_order_number) then
             l_dflt_flag := 'Y';
            --
         --
         -- bug fix 2560721
         -- for New Enrollments the bnft row corresponding to dflt_val should have
         -- the dflt_flag set to Y, when default enrollment code is 'NSDCS'.
         -- l_current_enrt_present will be null if the enrollment is New, refer to
         -- c_current_enrt cursor above
         --
         elsif (l_dflt_enrt_cd in ('NSDCS','NNCS') and
--                            i <> NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or
                l_combined_val <> NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or -- Bug 6068097
               (l_dflt_enrt_cd in ('NSDCS','NNCS') and
                            l_crnt_ordr_num <> l_order_number) then
             l_dflt_flag := 'N';
         elsif l_dflt_enrt_cd in ('NSDCS') and
            nvl(l_current_enrt_present,'N') = 'N' and
            i = l_cvg(0).dflt_val then
            --
            l_dflt_flag := 'Y';
            --
         --
         -- end fix 2560721
         --
         elsif l_dflt_enrt_cd not in ('NSDCS','NNCS') and
               i = l_cvg(0).dflt_val then
            --
            l_dflt_flag := 'Y';
            --
         else
            l_dflt_flag := 'N';

         end if;

         if l_rstrn_found then

           ben_determine_coverage.chk_bnft_ctfn
            (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
             p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
             p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
             p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
             p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
             p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
             p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
             p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
             p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
             p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
             p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
             p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
             p_combined_val             => l_combined_val,
             p_crnt_bnft_amt            => l_bnft_amt,
             p_ordr_num                 => l_order_number,
             p_crnt_ordr_num            => l_crnt_ordr_num,
             p_ctfn_rqd                 => l_ctfn_rqd,
             p_write_rec                => l_write_rec,
             p_effective_date           => nvl(p_lf_evt_ocrd_dt,
                                               p_effective_date),
             p_assignment_id            => l_asg.assignment_id,
             p_organization_id          => l_asg.organization_id,
             p_business_group_id        => l_epe.business_group_id,
             p_pgm_id                   => l_epe.pgm_id,
             p_pl_id                    => l_epe.pl_id,
             p_pl_typ_id                => l_epe.pl_typ_id,
             p_opt_id                   => l_opt.opt_id,
             p_ler_id                   => l_epe.ler_id,
             p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
             p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
             p_jurisdiction_code        => l_jurisdiction_code,
             p_check_received           => l_check_received,
             /* Start of Changes for WWBUG: 2054078             */
             p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
             /* End of Changes for WWBUG: 2054078               */
--Bug 4644489
  	  p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
--End Bug 4644489
           --
         end if;
         --
         if l_write_rec then
           --
           hr_utility.set_location('Writing coverage ',35);
           --
           ben_determine_coverage.write_coverage
             (p_calculate_only_mode    => p_calculate_only_mode,
              p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
              p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
              p_val                    => l_combined_val,
              p_dflt_flag              => l_dflt_flag,
              p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_business_group_id      => l_cvg(0).business_group_id,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_person_id              => l_epe.person_id,
              p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
              p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
              p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
              p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl,
              p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
              p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
              p_entr_val_at_enrt_flag  => 'N',--l_cvg(0).entr_val_at_enrt_flag,
  --Bug 5573274
         p_mx_val      => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
         /*
             CODE PRIOR TO WWBUG: 2054078
         p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
         */
         /* Start of Changes for WWBUG: 2054078   */
         p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
         /* End of Changes for WWBUG: 2054078   */
  --End Bug 5573274
              p_mn_val                 => null, --l_cvg(0).mn_val,
              p_incrmt_val             => null, --l_cvg(0).incrmt_val,
              p_dflt_val               => null, --l_cvg(0).dflt_val,
              p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
              p_perform_rounding_flg   => l_perform_rounding_flg,
              p_ordr_num               => l_order_number,
              p_ctfn_rqd_flag          => l_ctfn_rqd,
              p_enrt_bnft_id           => l_enrt_bnft_id,
              p_enb_valrow             => p_enb_valrow,
              p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
              p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
              p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
              p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
              p_bnft_amount            => l_cvg_amount,
              p_vapro_exist            => l_vapro_exist
              );
           --
           if l_ctfn_rqd = 'Y'
             and not p_calculate_only_mode
           then
             --
             write_ctfn;
             --
           end if;
           --
         end if;
         --
         --  if l_vr_trtmt_cd is RPLC treat as FLFX
         --
         if l_vr_trtmt_cd = 'RPLC' then
           --
           exit;
           --
         end if;

      end if;
      --
      i := i + l_cvg(0).incrmt_val;
      l_order_number := l_order_number + 1;
      --
    end loop;
    --
    open c_unrest(l_epe.ler_id);
       fetch c_unrest into l_dummy;
    close c_unrest;
    -----Bug 7704956
      --Bug 9308931,Fix for the bug 7704596 is extended for the OAB life events also.
 --   if l_dummy = 'Y' then
       l_dup_enr_count := 0;
       for l_check in c_check_dup_enb_enr(p_elig_per_elctbl_chc_id) loop
       l_dup_enr_count := l_dup_enr_count + 1;
       hr_utility.set_location ('count : '||l_dup_enr_count,10);
       if l_dup_enr_count > 1 then
          exit;
       end if;
       end loop;

       if (l_dup_enr_count > 1) then
          --fetch the bnft amount
	  open c_get_prev_bnft(p_effective_date);
	  fetch c_get_prev_bnft into l_get_prev_bnft;
	  close c_get_prev_bnft;
          for l_check in c_check_dup_enb_enr(p_elig_per_elctbl_chc_id) loop
	     --update enb table if order number matches.
             if l_get_prev_bnft.bnft_amt <> l_check.val then
		ben_enrt_bnft_api.update_enrt_bnft
				 (p_enrt_bnft_id                  => l_check.enrt_bnft_id
                                 ,p_dflt_flag                     => 'N'   ---l_check.dflt_flag,Bug 9308931
                                 ,p_val_has_bn_prortd_flag        => l_check.val_has_bn_prortd_flag
                                 ,p_bndry_perd_cd                 => l_check.bndry_perd_cd
                                 ,p_val                           => l_check.val
                                 ,p_nnmntry_uom                   => l_check.nnmntry_uom
                                 ,p_bnft_typ_cd                   => l_check.bnft_typ_cd
                                 ,p_entr_val_at_enrt_flag         => l_check.entr_val_at_enrt_flag
                                 ,p_mn_val                        => l_check.mn_val
                                 ,p_mx_val                        => l_check.mx_val
                                 ,p_incrmt_val                    => l_check.incrmt_val
                                 ,p_dflt_val                      => l_check.dflt_val
                                 ,p_rt_typ_cd                     => l_check.rt_typ_cd
                                 ,p_cvg_mlt_cd                    => l_check.cvg_mlt_cd
                                 ,p_ctfn_rqd_flag                 => l_check.ctfn_rqd_flag
                                 ,p_ordr_num                      => l_check.ordr_num
                                 ,p_crntly_enrld_flag             => 'N'
                                 ,p_elig_per_elctbl_chc_id        => l_check.elig_per_elctbl_chc_id
                                 ,p_prtt_enrt_rslt_id             => null
                                 ,p_comp_lvl_fctr_id              => l_check.comp_lvl_fctr_id
                                 ,p_business_group_id             => l_check.business_group_id
                                 ,p_enb_attribute_category        => l_check.enb_attribute_category
                                 ,p_enb_attribute1                => l_check.enb_attribute1
                                 ,p_enb_attribute2                => l_check.enb_attribute2
                                 ,p_enb_attribute3                => l_check.enb_attribute3
                                 ,p_enb_attribute4                => l_check.enb_attribute4
                                 ,p_enb_attribute5                => l_check.enb_attribute5
                                 ,p_enb_attribute6                => l_check.enb_attribute6
                                 ,p_enb_attribute7                => l_check.enb_attribute7
                                 ,p_enb_attribute8                => l_check.enb_attribute8
                                 ,p_enb_attribute9                => l_check.enb_attribute9
                                 ,p_enb_attribute10               => l_check.enb_attribute10
                                 ,p_enb_attribute11               => l_check.enb_attribute11
                                 ,p_enb_attribute12               => l_check.enb_attribute12
                                 ,p_enb_attribute13               => l_check.enb_attribute13
                                 ,p_enb_attribute14               => l_check.enb_attribute14
                                 ,p_enb_attribute15               => l_check.enb_attribute15
                                 ,p_enb_attribute16               => l_check.enb_attribute16
                                 ,p_enb_attribute17               => l_check.enb_attribute17
                                 ,p_enb_attribute18               => l_check.enb_attribute18
                                 ,p_enb_attribute19               => l_check.enb_attribute19
                                 ,p_enb_attribute20               => l_check.enb_attribute20
                                 ,p_enb_attribute21               => l_check.enb_attribute21
                                 ,p_enb_attribute22               => l_check.enb_attribute22
                                 ,p_enb_attribute23               => l_check.enb_attribute23
                                 ,p_enb_attribute24               => l_check.enb_attribute24
                                 ,p_enb_attribute25               => l_check.enb_attribute25
                                 ,p_enb_attribute26               => l_check.enb_attribute26
                                 ,p_enb_attribute27               => l_check.enb_attribute27
                                 ,p_enb_attribute28               => l_check.enb_attribute28
                                 ,p_enb_attribute29               => l_check.enb_attribute29
                                 ,p_enb_attribute30               => l_check.enb_attribute30
                                 ,p_request_id                    => l_check.request_id
                                 ,p_program_application_id        => l_check.program_application_id
                                 ,p_program_id                    => l_check.program_id
                                 ,p_program_update_date           => l_check.program_update_date
                                 ,p_mx_wout_ctfn_val              => l_check.mx_wout_ctfn_val
                                 ,p_mx_wo_ctfn_flag               => l_check.mx_wo_ctfn_flag
                                 ,p_object_version_number         => l_check.object_version_number
                                 ,p_effective_date                => trunc(p_effective_date));
	     end if;
	  end loop;
	  end if;
   -- end if;  Bug 9308931

  elsif l_cvg(0).cvg_mlt_cd = 'CLRNG' then
    --
      hr_utility.set_location (' CMC CLRNG ',10);
    i := l_cvg(0).mn_val;
    --
    while i <= l_cvg(0).mx_val loop
      --
      l_ctfn_rqd := 'N';
      l_write_rec := true;
      --
      if l_incr_r_decr_cd is null or
          ((l_incr_r_decr_cd='INCRO' and
            l_order_number > nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='EQINCR' and
            l_order_number >=  nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='DECRO' and
            l_order_number < nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='EQDECR' and
            l_order_number <=  nvl(l_crnt_ordr_num,0))) then
        --
        benutils.rt_typ_calc
          (p_val              => i,
           p_val_2            => l_compensation_value,
           p_rt_typ_cd        => l_cvg(0).rt_typ_cd,
           p_calculated_val   => l_calculated_val);
        --
          l_val := round_val(
              p_val                    => l_calculated_val,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl
              );
          l_cvg_amount := l_val ;
         --validate the limit for benefir amount
         hr_utility.set_location ('limit_checks ',10);
         benutils.limit_checks
        (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
           p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
           p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
           p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
           p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
           p_assignment_id     => l_asg.assignment_id,
           p_organization_id   => l_asg.organization_id,
           p_business_group_id => l_epe.business_group_id,
           p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
           p_pgm_id            => l_epe.pgm_id,
           p_pl_id             => l_epe.pl_id,
           p_pl_typ_id         => l_epe.pl_typ_id,
           p_opt_id            => l_opt.opt_id,
           p_ler_id            => l_epe.ler_id,
           p_val               => l_val,
           p_state             => l_state.region_2);

        ben_determine_coverage.combine_with_variable_val
          (p_vr_val           => l_vr_val,
           p_val              => l_val,
           p_vr_trtmt_cd      => l_vr_trtmt_cd,
           p_combined_val     => l_combined_val);
        --
	--9434155
           if (l_dflt_enrt_cd in ('NSDCS','NNCS')
--                  and i <> NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or
                  and l_combined_val = NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or --Bug 6068097
              (l_dflt_enrt_cd in ('NSDCS','NNCS') and l_crnt_ordr_num = l_order_number)
           then
             l_dflt_flag := 'Y';

           elsif (l_dflt_enrt_cd in ('NSDCS','NNCS')
--                  and i = NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or
                  and l_combined_val <> NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or --Bug 6068097
                 (l_dflt_enrt_cd in ('NSDCS','NNCS') and l_crnt_ordr_num <> l_order_number)
           then
             l_dflt_flag := 'N';

           elsif l_dflt_enrt_cd not in ('NSDCS','NNCS') and
                 i = l_cvg(0).dflt_val then

             l_dflt_flag := 'Y';

           else

             l_dflt_flag := 'N';

           end if;

        if l_rstrn_found then
          --
          ben_determine_coverage.chk_bnft_ctfn
            (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
             p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
             p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
             p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
             p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
             p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
             p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
             p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
             p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
             p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
             p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
             p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
             p_combined_val             => l_combined_val,
             p_crnt_bnft_amt            => l_bnft_amt,
             p_ordr_num                 => l_order_number,
             p_crnt_ordr_num            => l_crnt_ordr_num,
             p_ctfn_rqd                 => l_ctfn_rqd,
             p_write_rec                => l_write_rec,
             p_effective_date           => nvl(p_lf_evt_ocrd_dt,p_effective_date),
             p_assignment_id            => l_asg.assignment_id,
             p_organization_id          => l_asg.organization_id,
             p_business_group_id        => l_epe.business_group_id,
             p_pgm_id                   => l_epe.pgm_id,
             p_pl_id                    => l_epe.pl_id,
             p_pl_typ_id                => l_epe.pl_typ_id,
             p_opt_id                   => l_opt.opt_id,
             p_ler_id                   => l_epe.ler_id,
             p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
             p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
             p_jurisdiction_code        => l_jurisdiction_code,
             p_check_received           => l_check_received,
             /* Start of Changes for WWBUG: 2054078  added parameter */
             p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
             /* End of Changes for WWBUG: 2054078  added parameter */
--Bug 4644489
  	  p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
--End Bug 4644489
          --
        end if;
        --
        if l_write_rec then
          --
          if l_epe.oipl_id is not null then
            --
            open c_opt(l_epe.oipl_id,
              nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
              --
              fetch c_opt into l_opt;
              --
            close c_opt;
            --
          end if;
          --
          ben_determine_coverage.write_coverage
            (p_calculate_only_mode    => p_calculate_only_mode,
             p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
             p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
             p_val                    => l_combined_val,
             p_dflt_flag              => l_dflt_flag,
             p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
             p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
             p_business_group_id      => l_cvg(0).business_group_id,
             p_effective_date         => p_effective_date,
             p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
             p_person_id              => l_epe.person_id,
             p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
             p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
             p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
             p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
             p_rndg_cd                => l_cvg(0).rndg_cd,
             p_rndg_rl                => l_cvg(0).rndg_rl,
             p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
             p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
             p_entr_val_at_enrt_flag  => 'N',--l_cvg(0).entr_val_at_enrt_flag,
             p_mx_val                 => null,--l_cvg(0).mx_val,
             p_mx_wout_ctfn_val       => null, --l_rstrn.mx_cvg_alwd_amt
             p_mn_val                 => null,--l_cvg(0).mn_val,
             p_dflt_val               => null,--l_dflt_val,
             p_incrmt_val             => null,--l_cvg(0).incrmt_val,
             p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
             p_perform_rounding_flg   => l_perform_rounding_flg,
             p_ordr_num               => l_order_number,
             p_ctfn_rqd_flag          => l_ctfn_rqd,
             p_enrt_bnft_id           => l_enrt_bnft_id,
             p_enb_valrow             => p_enb_valrow,
             p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
             p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
             p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
             p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
             p_bnft_amount            => l_cvg_amount,
             p_vapro_exist            => l_vapro_exist
             );

          if l_ctfn_rqd = 'Y'
            and not p_calculate_only_mode
          then
            --
            write_ctfn;
            --
          end if;
          --
        end if;
        --
        --  if l_vr_trtmt_cd is RPLC treat as FLFX
        --
        if l_vr_trtmt_cd = 'RPLC' then
          --
          exit;
          --
        end if;
        --
      end if;
      --
      i := i + l_cvg(0).incrmt_val;
      l_order_number := l_order_number + 1;
      --
    end loop;
    --
           --9434155

       l_dup_enr_count := 0;
       for l_check in c_check_dup_enb_enr(p_elig_per_elctbl_chc_id) loop
       l_dup_enr_count := l_dup_enr_count + 1;
       hr_utility.set_location ('count : '||l_dup_enr_count,10);
       if l_dup_enr_count > 1 then
          exit;
       end if;
       end loop;

       if (l_dup_enr_count > 1) then
	  open c_get_prev_bnft(p_effective_date);
	  fetch c_get_prev_bnft into l_get_prev_bnft;
	  close c_get_prev_bnft;
          for l_check in c_check_dup_enb_enr(p_elig_per_elctbl_chc_id) loop
             if l_get_prev_bnft.bnft_amt <> l_check.val then
		ben_enrt_bnft_api.update_enrt_bnft
				 (p_enrt_bnft_id                  => l_check.enrt_bnft_id
                                 ,p_dflt_flag                     => 'N'
                                 ,p_val_has_bn_prortd_flag        => l_check.val_has_bn_prortd_flag
                                 ,p_bndry_perd_cd                 => l_check.bndry_perd_cd
                                 ,p_val                           => l_check.val
                                 ,p_nnmntry_uom                   => l_check.nnmntry_uom
                                 ,p_bnft_typ_cd                   => l_check.bnft_typ_cd
                                 ,p_entr_val_at_enrt_flag         => l_check.entr_val_at_enrt_flag
                                 ,p_mn_val                        => l_check.mn_val
                                 ,p_mx_val                        => l_check.mx_val
                                 ,p_incrmt_val                    => l_check.incrmt_val
                                 ,p_dflt_val                      => l_check.dflt_val
                                 ,p_rt_typ_cd                     => l_check.rt_typ_cd
                                 ,p_cvg_mlt_cd                    => l_check.cvg_mlt_cd
                                 ,p_ctfn_rqd_flag                 => l_check.ctfn_rqd_flag
                                 ,p_ordr_num                      => l_check.ordr_num
                                 ,p_crntly_enrld_flag             => 'N'
                                 ,p_elig_per_elctbl_chc_id        => l_check.elig_per_elctbl_chc_id
                                 ,p_prtt_enrt_rslt_id             => null
                                 ,p_comp_lvl_fctr_id              => l_check.comp_lvl_fctr_id
                                 ,p_business_group_id             => l_check.business_group_id
                                 ,p_enb_attribute_category        => l_check.enb_attribute_category
                                 ,p_enb_attribute1                => l_check.enb_attribute1
                                 ,p_enb_attribute2                => l_check.enb_attribute2
                                 ,p_enb_attribute3                => l_check.enb_attribute3
                                 ,p_enb_attribute4                => l_check.enb_attribute4
                                 ,p_enb_attribute5                => l_check.enb_attribute5
                                 ,p_enb_attribute6                => l_check.enb_attribute6
                                 ,p_enb_attribute7                => l_check.enb_attribute7
                                 ,p_enb_attribute8                => l_check.enb_attribute8
                                 ,p_enb_attribute9                => l_check.enb_attribute9
                                 ,p_enb_attribute10               => l_check.enb_attribute10
                                 ,p_enb_attribute11               => l_check.enb_attribute11
                                 ,p_enb_attribute12               => l_check.enb_attribute12
                                 ,p_enb_attribute13               => l_check.enb_attribute13
                                 ,p_enb_attribute14               => l_check.enb_attribute14
                                 ,p_enb_attribute15               => l_check.enb_attribute15
                                 ,p_enb_attribute16               => l_check.enb_attribute16
                                 ,p_enb_attribute17               => l_check.enb_attribute17
                                 ,p_enb_attribute18               => l_check.enb_attribute18
                                 ,p_enb_attribute19               => l_check.enb_attribute19
                                 ,p_enb_attribute20               => l_check.enb_attribute20
                                 ,p_enb_attribute21               => l_check.enb_attribute21
                                 ,p_enb_attribute22               => l_check.enb_attribute22
                                 ,p_enb_attribute23               => l_check.enb_attribute23
                                 ,p_enb_attribute24               => l_check.enb_attribute24
                                 ,p_enb_attribute25               => l_check.enb_attribute25
                                 ,p_enb_attribute26               => l_check.enb_attribute26
                                 ,p_enb_attribute27               => l_check.enb_attribute27
                                 ,p_enb_attribute28               => l_check.enb_attribute28
                                 ,p_enb_attribute29               => l_check.enb_attribute29
                                 ,p_enb_attribute30               => l_check.enb_attribute30
                                 ,p_request_id                    => l_check.request_id
                                 ,p_program_application_id        => l_check.program_application_id
                                 ,p_program_id                    => l_check.program_id
                                 ,p_program_update_date           => l_check.program_update_date
                                 ,p_mx_wout_ctfn_val              => l_check.mx_wout_ctfn_val
                                 ,p_mx_wo_ctfn_flag               => l_check.mx_wo_ctfn_flag
                                 ,p_object_version_number         => l_check.object_version_number
                                 ,p_effective_date                => trunc(p_effective_date));
	     end if;
	  end loop;
	  end if;
    --9434155
  elsif l_cvg(0).cvg_mlt_cd = 'FLFXPCL' then
      hr_utility.set_location (' CMC FLFXPCL ',10);
    --
    l_ctfn_rqd := 'N';
    l_write_rec := true;
    --
    benutils.rt_typ_calc
      (p_val              => l_cvg(0).mn_val,
       p_val_2            => l_compensation_value,
       p_rt_typ_cd        => l_cvg(0).rt_typ_cd,
       p_calculated_val   => l_calculated_val);
    --
       hr_utility.set_location (' l_calculated_val ' || l_calculated_val,10);
       hr_utility.set_location (' l_cvg(0).val '|| l_cvg(0).val,10);
    --
       l_calculated_val := l_calculated_val + l_cvg(0).val;
    --
       l_val := round_val(
              p_val                    => l_calculated_val,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl
              );
          l_cvg_amount := l_val ;
          --validate the limit for benefir amount
          hr_utility.set_location ('limit_checks ',10);

          l_tot_val := l_val ;
          --
          hr_utility.set_location (' l_tot_val ' || l_tot_val,10);
          --
          benutils.limit_checks
          (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
              p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
              p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
              p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
              p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
              p_assignment_id     => l_asg.assignment_id,
              p_organization_id   => l_asg.organization_id,
              p_business_group_id => l_epe.business_group_id,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_pgm_id            => l_epe.pgm_id,
              p_pl_id             => l_epe.pl_id,
              p_pl_typ_id         => l_epe.pl_typ_id,
              p_opt_id            => l_opt.opt_id,
              p_ler_id            => l_epe.ler_id,
              p_val               => l_tot_val,   -- 3095224,
              p_state             => l_state.region_2);

    ben_determine_coverage.combine_with_variable_val
      (p_vr_val           => l_vr_val,
       p_val              => l_tot_val, -- 3095224 l_val+l_cvg(0).val,
       p_vr_trtmt_cd      => l_vr_trtmt_cd,
       p_combined_val     => l_combined_val);
    --
    if l_rstrn_found then
      --
      ben_determine_coverage.chk_bnft_ctfn
         (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
          p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
          p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
          p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
          p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
          p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
          p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
          p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
          p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
          p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
          p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
          p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
          p_combined_val             => l_combined_val,
          p_crnt_bnft_amt            => l_bnft_amt,
          p_ordr_num                 => l_order_number,
          p_crnt_ordr_num            => l_crnt_ordr_num,
          p_ctfn_rqd                 => l_ctfn_rqd,
          p_write_rec                => l_write_rec,
          p_effective_date           => nvl(p_lf_evt_ocrd_dt,
                                            p_effective_date),
          p_assignment_id            => l_asg.assignment_id,
          p_organization_id          => l_asg.organization_id,
          p_business_group_id        => l_epe.business_group_id,
          p_pgm_id                   => l_epe.pgm_id,
          p_pl_id                    => l_epe.pl_id,
          p_pl_typ_id                => l_epe.pl_typ_id,
          p_opt_id                   => l_opt.opt_id,
          p_ler_id                   => l_epe.ler_id,
          p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
          p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
          p_jurisdiction_code        => l_jurisdiction_code,
          p_check_received           => l_check_received,
          /* Start of Changes for WWBUG: 2054078  added parameter */
          p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
          /* End of Changes for WWBUG: 2054078  added parameter */
--Bug 4644489
  	  p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
--End Bug 4644489
       --
    end if;
    --
    if l_write_rec then
      --
      ben_determine_coverage.write_coverage
        (p_calculate_only_mode    => p_calculate_only_mode,
         p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
         p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
         p_val                    => l_combined_val,
         p_dflt_flag              => l_epe.dflt_flag,  --BUG 4449437
         p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_business_group_id      => l_cvg(0).business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_person_id              => l_epe.person_id,
         p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
         p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
         p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
         p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
         p_rndg_cd                => l_cvg(0).rndg_cd,
         p_rndg_rl                => l_cvg(0).rndg_rl,
         p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
         p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
         p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         p_mx_val      => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
         /* CODE PRIOR TO WWBUG: 2054078
         p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
         */
         /* Start of Changes for WWBUG: 2054078         */
         p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
         /* End of Changes for WWBUG: 2054078           */
         p_mn_val                 => null, -- l_cvg(0).mn_val, Commented for bug 3102355
         p_dflt_val               => l_cvg(0).dflt_val,
         p_incrmt_val             => l_cvg(0).incrmt_val,
         p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
         p_perform_rounding_flg   => l_perform_rounding_flg,
         p_ordr_num               => l_order_number,
         p_ctfn_rqd_flag          => l_ctfn_rqd,
         p_enrt_bnft_id           => l_enrt_bnft_id,
         p_enb_valrow             => p_enb_valrow ,
         p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
         p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
         p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
         p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
         p_bnft_amount            => l_cvg_amount,
         p_vapro_exist            => l_vapro_exist
         );
      --
      if l_ctfn_rqd = 'Y'
        and not p_calculate_only_mode
      then
        --
        write_ctfn;
        --
      end if;
      --
    else
      --
      -- Update the electable choice to be not electable
      --
      if l_epe.elctbl_flag='Y' then
        --
        if not p_calculate_only_mode then
          --
          ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc(
             p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
             p_elctbl_flag             => 'N',
             p_dflt_flag               => 'N',
             p_object_version_number   => l_epe.object_version_number,
             p_effective_date          => p_effective_date,
             p_program_application_id  => fnd_global.prog_appl_id,
             p_program_id              => fnd_global.conc_program_id,
             p_request_id              => fnd_global.conc_request_id,
             p_program_update_date     => sysdate
             );
           --
           -- If enrolled will deenroll.
           --
           ben_newly_ineligible.main(
              p_person_id           => l_epe.person_id,
              p_pgm_id              => l_epe.pgm_id,
              p_pl_id               => l_epe.pl_id,
              p_oipl_id             => l_epe.oipl_id,
              p_business_group_id   => l_epe.business_group_id,
              p_ler_id              => l_epe.ler_id,
              p_effective_date      => p_effective_date
           );
          --
        end if;
        l_epe.elctbl_flag:='N';
        hr_utility.set_location('Electable choice was made not electable by bencvrge',29);
      end if;
      ben_determine_coverage.write_coverage
        (p_calculate_only_mode    => p_calculate_only_mode,
         p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
         p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
         p_val                    => l_combined_val,
         p_dflt_flag              => l_dflt_flag,
         p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_business_group_id      => l_cvg(0).business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_person_id              => l_epe.person_id,
         p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
         p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
         p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
         p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
         p_rndg_cd                => l_cvg(0).rndg_cd,
         p_rndg_rl                => l_cvg(0).rndg_rl,
         p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
         p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
         p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         p_mx_val      => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
         /*
            CODE PRIOR TO WWBUG: 2054078
         p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
         */
         /* Start of Changes for WWBUG: 2054078         */
         p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
         /* End of Changes for WWBUG: 2054078           */
         p_mn_val                 => null, -- l_cvg(0).mn_val, For Bug 3102355
         p_dflt_val               => l_cvg(0).dflt_val,
         p_incrmt_val             => l_cvg(0).incrmt_val,
         p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
         p_perform_rounding_flg   => l_perform_rounding_flg,
         p_ordr_num               => l_order_number,
         p_ctfn_rqd_flag          => l_ctfn_rqd,
         p_enrt_bnft_id           => l_enrt_bnft_id,
         p_enb_valrow             => p_enb_valrow ,
         p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
         p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
         p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
         p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
         p_bnft_amount            => l_cvg_amount,
         p_vapro_exist            => l_vapro_exist
         );
      --
    end if;
    --
  elsif l_cvg(0).cvg_mlt_cd = 'FLPCLRNG' then
      hr_utility.set_location (' CMC FLPCLRNG ',10);
  --
     i := l_cvg(0).mn_val;
     --
     while i <= l_cvg(0).mx_val loop
       --
       l_ctfn_rqd := 'N';
       l_write_rec := true;
       --
       if l_incr_r_decr_cd is null or
          ((l_incr_r_decr_cd='INCRO' and
            l_order_number > nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='EQINCR' and
            l_order_number >=  nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='DECRO' and
            l_order_number < nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='EQDECR' and
            l_order_number <=  nvl(l_crnt_ordr_num,0))) then
         --
         benutils.rt_typ_calc
           (p_val              => i,
            p_val_2            => l_compensation_value,
            p_rt_typ_cd        => l_cvg(0).rt_typ_cd,
            p_calculated_val   => l_calculated_val);
         --_
         l_val := round_val(
              p_val                    => l_calculated_val,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl
              );
          l_cvg_amount := l_val ;
          --validate the limit for benefir amount

          l_tot_val := l_val+l_cvg(0).val; -- 3095224


          hr_utility.set_location ('limit_checks ',10);
          benutils.limit_checks
          (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
              p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
              p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
              p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
              p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
              p_assignment_id     => l_asg.assignment_id,
              p_organization_id   => l_asg.organization_id,
              p_business_group_id => l_epe.business_group_id,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_pgm_id            => l_epe.pgm_id,
              p_pl_id             => l_epe.pl_id,
              p_pl_typ_id         => l_epe.pl_typ_id,
              p_opt_id            => l_opt.opt_id,
              p_ler_id            => l_epe.ler_id,
              p_val               => l_tot_val , -- 3095224 l_val,
              p_state             => l_state.region_2);



         ben_determine_coverage.combine_with_variable_val
           (p_vr_val           => l_vr_val,
            p_val              => l_tot_val, -- 3095224 l_val+l_cvg(0).val,
            p_vr_trtmt_cd      => l_vr_trtmt_cd,
            p_combined_val     => l_combined_val);
         --
           if (l_dflt_enrt_cd in ('NSDCS','NNCS')
--                 and i <> NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or
                   and l_combined_val <> NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or -- Bug 6068097
              (l_dflt_enrt_cd in ('NSDCS','NNCS') and l_crnt_ordr_num <> l_order_number)
           then
             l_dflt_flag := 'N';

           elsif (l_dflt_enrt_cd in ('NSDCS','NNCS')
--                    and i = NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or
                    and l_combined_val = NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or -- Bug 6068097
                 (l_dflt_enrt_cd in ('NSDCS','NNCS') and l_crnt_ordr_num = l_order_number)
           then

             l_dflt_flag := 'Y';

           elsif l_dflt_enrt_cd not in ('NSDCS','NNCS') and
                 i = l_cvg(0).dflt_val then

             l_dflt_flag := 'Y';

           else

             l_dflt_flag := 'N';

           end if;

         if l_rstrn_found then
           --
           ben_determine_coverage.chk_bnft_ctfn
             (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
              p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
              p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
              p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
              p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
              p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
              p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
              p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
              p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
              p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
              p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
              p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
              p_combined_val             => l_combined_val,
              p_crnt_bnft_amt            => l_bnft_amt,
              p_ordr_num                 => l_order_number,
              p_crnt_ordr_num            => l_crnt_ordr_num,
              p_ctfn_rqd                 => l_ctfn_rqd,
              p_write_rec                => l_write_rec,
              p_effective_date           => nvl(p_lf_evt_ocrd_dt,
                                                p_effective_date),
              p_assignment_id            => l_asg.assignment_id,
              p_organization_id          => l_asg.organization_id,
              p_business_group_id        => l_epe.business_group_id,
              p_pgm_id                   => l_epe.pgm_id,
              p_pl_id                    => l_epe.pl_id,
              p_pl_typ_id                => l_epe.pl_typ_id,
              p_opt_id                   => l_opt.opt_id,
              p_ler_id                   => l_epe.ler_id,
              p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
              p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
              p_jurisdiction_code        => l_jurisdiction_code,
              p_check_received           => l_check_received,
              /* Start of Changes for WWBUG: 2054078            */
              p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
              /* End of Changes for WWBUG: 2054078              */
--Bug 4644489
  	  p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
--End Bug 4644489
           --
         end if;
         --
         if l_write_rec then
           --
           if l_epe.oipl_id is not null then
             --
             open c_opt(l_epe.oipl_id, nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
               --
               fetch c_opt into l_opt;
               --
             close c_opt;
             --
           end if;
           --
           ben_determine_coverage.write_coverage
             (p_calculate_only_mode    => p_calculate_only_mode,
              p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
              p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
              p_val                    => l_combined_val,
              p_dflt_flag              => l_dflt_flag,
              p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_business_group_id      => l_cvg(0).business_group_id,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_person_id              => l_epe.person_id,
              p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
              p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
              p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
              p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl,
              p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
              p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
              p_entr_val_at_enrt_flag  => 'N',--l_cvg(0).entr_val_at_enrt_flag,
              p_mx_val                 => null,--l_cvg(0).mx_val,
              p_mx_wout_ctfn_val       => null, --l_rstrn.mx_cvg_alwd_amt
              p_mn_val                 => null,--l_cvg(0).mn_val,
              p_incrmt_val             => null,--l_cvg(0).incrmt_val,
              p_dflt_val               => null,--l_dflt_val,
              p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
              p_perform_rounding_flg   => l_perform_rounding_flg,
              p_ordr_num               => l_order_number,
              p_ctfn_rqd_flag          => l_ctfn_rqd,
              p_enrt_bnft_id           => l_enrt_bnft_id,
              p_enb_valrow             => p_enb_valrow,
              p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
              p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
              p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
              p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
              p_bnft_amount            => l_cvg_amount,
              p_vapro_exist            => l_vapro_exist
              );
           --
           if l_ctfn_rqd = 'Y'
             and not p_calculate_only_mode
           then
             --
             write_ctfn;
             --
           end if;
           --
         end if;
         --
         --  if l_vr_trtmt_cd is RPLC treat as FLFX
         --
         if l_vr_trtmt_cd = 'RPLC' then
           --
           exit;
           --
         end if;
         --
       end if;
       --
       i := i + l_cvg(0).incrmt_val;
       l_order_number := l_order_number + 1;
       --
     end loop;
    --
  elsif l_cvg(0).cvg_mlt_cd = 'CLPFLRNG' then
      hr_utility.set_location (' CMC CLPFLRNG ',10);
    --
    benutils.rt_typ_calc
      (p_val              => l_cvg(0).val,
       p_val_2            => l_compensation_value,
       p_rt_typ_cd        => l_cvg(0).rt_typ_cd,
       p_calculated_val   => l_calculated_val);
    --
    l_val := round_val(
              p_val                    => l_calculated_val,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl
              );
     i := l_cvg(0).mn_val;
     l_cvg_amount := l_val ;

      /*  moved the limit check to inside the loop to enforce the limit on compensation + range
          --validate the limit for benefir amount
          hr_utility.set_location ('limit_checks ',10);
          benutils.limit_checks
          (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
              p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
              p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
              p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
              p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
              p_assignment_id     => l_asg.assignment_id,
              p_organization_id   => l_asg.organization_id,
              p_business_group_id => l_epe.business_group_id,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_pgm_id            => l_epe.pgm_id,
              p_pl_id             => l_epe.pl_id,
              p_pl_typ_id         => l_epe.pl_typ_id,
              p_opt_id            => l_opt.opt_id,
              p_ler_id            => l_epe.ler_id,
              p_val               => l_val,
              p_state             => l_state.region_2);
       */

    --
    while i <= l_cvg(0).mx_val loop
      --
      l_ctfn_rqd := 'N';
      l_write_rec := true;
      --
      if l_incr_r_decr_cd is null or
          ((l_incr_r_decr_cd='INCRO' and
            l_order_number > nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='EQINCR' and
            l_order_number >=  nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='DECRO' and
            l_order_number < nvl(l_crnt_ordr_num,0)) or
           (l_incr_r_decr_cd='EQDECR' and
            l_order_number <=  nvl(l_crnt_ordr_num,0))) then
        --bug#2708285 - limit checked for the compensation plus flat amount
          l_tot_val  := l_val + i;
          benutils.limit_checks
          (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
              p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
              p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
              p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
              p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
              p_assignment_id     => l_asg.assignment_id,
              p_organization_id   => l_asg.organization_id,
              p_business_group_id => l_epe.business_group_id,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_pgm_id            => l_epe.pgm_id,
              p_pl_id             => l_epe.pl_id,
              p_pl_typ_id         => l_epe.pl_typ_id,
              p_opt_id            => l_opt.opt_id,
              p_ler_id            => l_epe.ler_id,
              p_val               => l_tot_val,
              p_state             => l_state.region_2);



        ben_determine_coverage.combine_with_variable_val
          (p_vr_val           => l_vr_val,
           p_val              => l_tot_val, --l_val+i,
           p_vr_trtmt_cd      => l_vr_trtmt_cd,
           p_combined_val     => l_combined_val);
        --
           if (l_dflt_enrt_cd in ('NSDCS','NNCS')
--                      and i <> NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or
                        and  l_combined_val <> NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or -- Bug 6068097
              (l_dflt_enrt_cd in ('NSDCS','NNCS') and l_crnt_ordr_num <> l_order_number)
           then
             l_dflt_flag := 'N';

           elsif (l_dflt_enrt_cd in ('NSDCS','NNCS')
--                       and i = NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or
                         and l_combined_val = NVL(l_bnft_amt,l_current_enrt_sspndd.bnft_amt)) or -- Bug 6068097
                 (l_dflt_enrt_cd in ('NSDCS','NNCS') and l_crnt_ordr_num = l_order_number)
           then

             l_dflt_flag := 'Y';

           elsif l_dflt_enrt_cd not in ('NSDCS','NNCS') and
                 i = l_cvg(0).dflt_val then

             l_dflt_flag := 'Y';

           else

             l_dflt_flag := 'N';

           end if;

        if l_rstrn_found then
          --
          ben_determine_coverage.chk_bnft_ctfn
            (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
             p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
             p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
             p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
             p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
             p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
             p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
             p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
             p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
             p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
             p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
             p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
             p_combined_val             => l_combined_val,
             p_crnt_bnft_amt            => l_bnft_amt,
             p_ordr_num                 => l_order_number,
             p_crnt_ordr_num            => l_crnt_ordr_num,
             p_ctfn_rqd                 => l_ctfn_rqd,
             p_write_rec                => l_write_rec,
             p_effective_date           => nvl(p_lf_evt_ocrd_dt,p_effective_date),
             p_assignment_id            => l_asg.assignment_id,
             p_organization_id          => l_asg.organization_id,
             p_business_group_id        => l_epe.business_group_id,
             p_pgm_id                   => l_epe.pgm_id,
             p_pl_id                    => l_epe.pl_id,
             p_pl_typ_id                => l_epe.pl_typ_id,
             p_opt_id                   => l_opt.opt_id,
             p_ler_id                   => l_epe.ler_id,
             p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
             p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
             p_jurisdiction_code        => l_jurisdiction_code,
             p_check_received           => l_check_received,
             /* Start of Changes for WWBUG: 2054078:  added parameter   */
             p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
             /* End of Changes for WWBUG: 2054078:  added parameter     */
--Bug 4644489
  	  p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
--End Bug 4644489
          --
        end if;

        if l_write_rec then
          if l_epe.oipl_id is not null then
            open c_opt(l_epe.oipl_id, nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
            fetch c_opt into l_opt;
            close c_opt;
          end if;

          ben_determine_coverage.write_coverage
            (p_calculate_only_mode    => p_calculate_only_mode,
             p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
             p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
             p_val                    => l_combined_val,
             p_dflt_flag              => l_dflt_flag,
             p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
             p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
             p_business_group_id      => l_cvg(0).business_group_id,
             p_effective_date         => p_effective_date,
             p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
             p_person_id              => l_epe.person_id,
             p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
             p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
             p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
             p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
             p_rndg_cd                => l_cvg(0).rndg_cd,
             p_rndg_rl                => l_cvg(0).rndg_rl,
             p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
             p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
             p_entr_val_at_enrt_flag  => 'N',--l_cvg(0).entr_val_at_enrt_flag,
             p_mx_val                 => null,--l_cvg(0).mx_val,
             p_mx_wout_ctfn_val       => null, --l_rstrn.mx_cvg_alwd_amt
             p_mn_val                 => null,--l_cvg(0).mn_val,
             p_dflt_val               => null,--l_dflt_val,
             p_incrmt_val             => null,--l_cvg(0).incrmt_val,
             p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
             p_perform_rounding_flg   => l_perform_rounding_flg,
             p_ordr_num               => l_order_number,
             p_ctfn_rqd_flag          => l_ctfn_rqd,
             p_enrt_bnft_id           => l_enrt_bnft_id,
             p_enb_valrow             => p_enb_valrow,
             p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
             p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
             p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
             p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
             p_bnft_amount            => l_cvg_amount,
             p_vapro_exist            => l_vapro_exist
             );

          if l_ctfn_rqd = 'Y'
            and not p_calculate_only_mode
          then
            write_ctfn;
          end if;

        end if;
        --
        --  if l_vr_trtmt_cd is RPLC treat as FLFX
        --
        if l_vr_trtmt_cd = 'RPLC' then
          exit;
        end if;

      end if;
      i := i + l_cvg(0).incrmt_val;
      l_order_number := l_order_number + 1;

    end loop;

  elsif l_cvg(0).cvg_mlt_cd = 'SAAEAR' then
    hr_utility.set_location (' CMC SAAEAR ',10);
    l_ctfn_rqd := 'N';
    l_write_rec := true;

    ben_determine_coverage.write_coverage
      (p_calculate_only_mode    => p_calculate_only_mode,
       p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
       p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
       p_val                    => null,
       p_dflt_flag              => l_epe.dflt_flag,
       p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
       p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
       p_business_group_id      => l_cvg(0).business_group_id,
       p_effective_date         => p_effective_date,
       p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
       p_person_id              => l_epe.person_id,
       p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
       p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
       p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
       p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
       p_rndg_cd                => l_cvg(0).rndg_cd,
       p_rndg_rl                => l_cvg(0).rndg_rl,
       p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
       p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
       p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         p_mx_val      => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
       /*
             CODE PRIOR TO WWBUG: 2054078
       p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
       */
       /* Start of Changes for WWBUG: 2054078   */
       p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
       /* End of Changes for WWBUG: 2054078     */
       p_mn_val                 => l_cvg(0).mn_val,
       p_dflt_val               => l_cvg(0).dflt_val,
       p_incrmt_val             => l_cvg(0).incrmt_val,
       p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
       p_perform_rounding_flg   => l_perform_rounding_flg,
       p_ordr_num               => l_order_number,
       p_ctfn_rqd_flag          => l_ctfn_rqd,
       p_enrt_bnft_id           => l_enrt_bnft_id,
       p_enb_valrow             => p_enb_valrow,
       p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
       p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
       p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
       p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
       p_bnft_amount            => l_cvg_amount,
       p_vapro_exist            => l_vapro_exist
       );
    --
  elsif l_cvg(0).cvg_mlt_cd = 'NSVU' then
    --
    hr_utility.set_location (' CMC NSVU ',10);
    --
    l_ctfn_rqd := 'N';
    l_write_rec := true;
    --
--Bug 6054310
    l_vr_val := nvl(l_vr_val, l_dflt_elcn_val);
    --
--Bug 6054310
    ben_determine_coverage.combine_with_variable_val
      (p_vr_val           => l_vr_val,
       p_val              => l_cvg(0).val,    -- 5933576 Removed l_calculated_val from here
       p_vr_trtmt_cd      => l_vr_trtmt_cd,
       p_combined_val     => l_combined_val);
    --
    if l_combined_val is null or l_combined_val = 0 then
      --
      fnd_message.set_name('BEN','BEN_91841_BENCVRGE_VAL_RQD');
      fnd_message.set_token('PACKAGE',l_package);
      fnd_message.set_token('PERSON_ID',to_char(l_epe.person_id));
      fnd_message.set_token('CALC_MTHD',l_cvg(0).cvg_mlt_cd);
      fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
      fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
      fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
      fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
      fnd_message.set_token('PLIP_ID',to_char(l_epe.plip_id));
      fnd_message.set_token('PTIP_ID',to_char(l_epe.ptip_id));
      fnd_message.raise_error;
      --
    end if;
    --
    --Bug 5933576 Adding chk_bnft_ctfn for NSVU as well
    --
    if l_rstrn_found then
      --
      ben_determine_coverage.chk_bnft_ctfn
         (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
          p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
          p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
          p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
          p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
          p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
          p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
          p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
          p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
          p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
          p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
          p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
          p_combined_val             => l_combined_val,
          p_crnt_bnft_amt            => l_bnft_amt,
          p_ordr_num                 => l_order_number,
          p_crnt_ordr_num            => l_crnt_ordr_num,
          p_ctfn_rqd                 => l_ctfn_rqd,
          p_write_rec                => l_write_rec,
          p_effective_date           => nvl(p_lf_evt_ocrd_dt, p_effective_date),
          p_assignment_id            => l_asg.assignment_id,
          p_organization_id          => l_asg.organization_id,
          p_business_group_id        => l_epe.business_group_id,
          p_pgm_id                   => l_epe.pgm_id,
          p_pl_id                    => l_epe.pl_id,
          p_pl_typ_id                => l_epe.pl_typ_id,
          p_opt_id                   => l_opt.opt_id,
          p_ler_id                   => l_epe.ler_id,
          p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
          p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
          p_jurisdiction_code        => l_jurisdiction_code,
          p_check_received           => l_check_received,
          p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
          p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
      --
    end if;
    --
    if l_write_rec then
    --
    ben_determine_coverage.write_coverage
      (p_calculate_only_mode    => p_calculate_only_mode,
       p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
       p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
       p_val                    => l_combined_val,
       p_dflt_flag              => l_epe.dflt_flag,
       p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
       p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
       p_business_group_id      => l_cvg(0).business_group_id,
       p_effective_date         => p_effective_date,
       p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
       p_person_id              => l_epe.person_id,
       p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
       p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
       p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
       p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
       p_rndg_cd                => l_cvg(0).rndg_cd,
       p_rndg_rl                => l_cvg(0).rndg_rl,
       p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
       p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
       p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
       p_mx_val                 => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
       p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
       p_mn_val                 => l_cvg(0).mn_val,
       p_dflt_val               => NVL(l_dflt_elcn_val,l_cvg(0).dflt_val),  -- bug 8568862
       p_incrmt_val             => l_cvg(0).incrmt_val,
       p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
       p_perform_rounding_flg   => l_perform_rounding_flg,
       p_ordr_num               => l_order_number,
       p_ctfn_rqd_flag          => l_ctfn_rqd,
       p_enrt_bnft_id           => l_enrt_bnft_id,
       p_enb_valrow             => p_enb_valrow,
       p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
       p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
       p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
       p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
       p_bnft_amount            => l_cvg_amount,
       p_vapro_exist            => l_vapro_exist
       );
      --
      if l_ctfn_rqd = 'Y' and not p_calculate_only_mode then
        --
        write_ctfn;
        --
      end if;
      --
    else
      --
      -- Update the electable choice to be not electable
      --
      if l_epe.elctbl_flag='Y' then
        --
        if not p_calculate_only_mode then
          --
          ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc(
             p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
             p_elctbl_flag             => 'N',
             p_dflt_flag               => 'N',
             p_object_version_number   => l_epe.object_version_number,
             p_effective_date          => p_effective_date,
             p_program_application_id  => fnd_global.prog_appl_id,
             p_program_id              => fnd_global.conc_program_id,
             p_request_id              => fnd_global.conc_request_id,
             p_program_update_date     => sysdate
          );
           --
           -- If enrolled will deenroll.
           --
           ben_newly_ineligible.main(
              p_person_id           => l_epe.person_id,
              p_pgm_id              => l_epe.pgm_id,
              p_pl_id               => l_epe.pl_id,
              p_oipl_id             => l_epe.oipl_id,
              p_business_group_id   => l_epe.business_group_id,
              p_ler_id              => l_epe.ler_id,
              p_effective_date      => p_effective_date
           );
          --
        end if;
        --
        l_epe.elctbl_flag:='N';
        hr_utility.set_location('Electable choice was made not electable by bencvrge',29);
      end if;
      ben_determine_coverage.write_coverage
        (p_calculate_only_mode    => p_calculate_only_mode,
         p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
         p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
         p_val                    => l_combined_val,
         p_dflt_flag              => l_epe.dflt_flag,
         p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_business_group_id      => l_cvg(0).business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_person_id              => l_epe.person_id,
         p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
         p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
         p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
         p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
         p_rndg_cd                => l_cvg(0).rndg_cd,
         p_rndg_rl                => l_cvg(0).rndg_rl,
         p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
         p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
         p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         p_mx_val                 => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
         p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
         p_mn_val                 => l_cvg(0).mn_val,
         p_incrmt_val             => l_cvg(0).incrmt_val,
         p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
         p_dflt_val               => l_cvg(0).dflt_val,
         p_perform_rounding_flg   => l_perform_rounding_flg,
         p_ordr_num               => l_order_number,
         p_ctfn_rqd_flag          => l_ctfn_rqd,
         p_enrt_bnft_id           => l_enrt_bnft_id,
         p_enb_valrow             => p_enb_valrow,
         p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
         p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
         p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
         p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
         p_bnft_amount            => l_cvg_amount,
         p_vapro_exist            => l_vapro_exist
         );
      --
    end if;
  --
  --End Bug 5933576
  --
  elsif l_cvg(0).cvg_mlt_cd in ('RL','ERL') then
      hr_utility.set_location (' CMC RL ',10);
    --
    if l_epe.oipl_id is not null and l_opt.opt_id is null
    then
       open c_opt(l_epe.oipl_id, nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date))); -- FONM
       fetch c_opt into l_opt;
       close c_opt;
    end if;
    --
    l_ctfn_rqd := 'N';
    l_write_rec := true;
    --
    -- Call formula initialise routine
    --
    l_outputs := benutils.formula
         (p_formula_id        => l_cvg(0).val_calc_rl,
          p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
          p_business_group_id => l_epe.business_group_id,
          p_assignment_id     => l_asg.assignment_id,
          p_organization_id   => l_asg.organization_id,
          p_pgm_id            => l_epe.pgm_id,
          p_pl_id             => l_epe.pl_id,
          p_pl_typ_id         => l_epe.pl_typ_id,
          p_opt_id            => l_opt.opt_id,
          p_ler_id            => l_epe.ler_id,
          p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
          -- FONM
          p_param1             => 'BEN_IV_RT_STRT_DT',
          p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
          p_param2             => 'BEN_IV_CVG_STRT_DT',
          p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
          p_jurisdiction_code => l_jurisdiction_code);
    --
    l_value := fnd_number.canonical_to_number(l_outputs(l_outputs.first).value);
    --
    l_val := round_val(
              p_val                    => l_value,
              p_effective_date         => p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_rndg_cd                => l_cvg(0).rndg_cd,
              p_rndg_rl                => l_cvg(0).rndg_rl
              );
    l_cvg_amount := l_val ;
          --validate the limit for benefir amount
          hr_utility.set_location ('limit_checks ',10);
          benutils.limit_checks
          (p_lwr_lmt_val       => l_cvg(0).lwr_lmt_val,
              p_lwr_lmt_calc_rl   => l_cvg(0).lwr_lmt_calc_rl,
              p_upr_lmt_val       => l_cvg(0).upr_lmt_val,
              p_upr_lmt_calc_rl   => l_cvg(0).upr_lmt_calc_rl,
              p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
              p_assignment_id     => l_asg.assignment_id,
              p_organization_id   => l_asg.organization_id,
              p_business_group_id => l_epe.business_group_id,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_pgm_id            => l_epe.pgm_id,
              p_pl_id             => l_epe.pl_id,
              p_pl_typ_id         => l_epe.pl_typ_id,
              p_opt_id            => l_opt.opt_id,
              p_ler_id            => l_epe.ler_id,
              p_val               => l_val,
              p_state             => l_state.region_2);




    ben_determine_coverage.combine_with_variable_val
      (p_vr_val           => l_vr_val,
       p_val              => l_val,
       p_vr_trtmt_cd      => l_vr_trtmt_cd,
       p_combined_val     => l_combined_val);
    --

    if l_rstrn_found then
          --
          ben_determine_coverage.chk_bnft_ctfn
            (p_mx_cvg_wcfn_amt          => l_rstrn.mx_cvg_wcfn_amt,
             p_mx_cvg_wcfn_mlt_num      => l_rstrn.mx_cvg_wcfn_mlt_num,
             p_mx_cvg_mlt_incr_num      => l_rstrn.mx_cvg_mlt_incr_num,
             p_mx_cvg_mlt_incr_wcf_num  => l_rstrn.mx_cvg_mlt_incr_wcf_num,
             p_mx_cvg_incr_alwd_amt     => l_rstrn.mx_cvg_incr_alwd_amt,
             p_mx_cvg_incr_wcf_alwd_amt => l_rstrn.mx_cvg_incr_wcf_alwd_amt,
             p_mn_cvg_rqd_amt           => l_rstrn.mn_cvg_rqd_amt,
             p_mx_cvg_alwd_amt          => l_rstrn.mx_cvg_alwd_amt,
             p_mx_cvg_rl                => l_rstrn.mx_cvg_rl,
             p_mn_cvg_rl                => l_rstrn.mn_cvg_rl,
             p_no_mn_cvg_amt_apls_flag  => l_rstrn.no_mn_cvg_amt_apls_flag,
             p_no_mx_cvg_amt_apls_flag  => l_rstrn.no_mx_cvg_amt_apls_flag,
             p_combined_val             => l_combined_val,
             p_crnt_bnft_amt            => l_bnft_amt,
             p_ordr_num                 => l_order_number,
             p_crnt_ordr_num            => l_crnt_ordr_num,
             p_ctfn_rqd                 => l_ctfn_rqd,
             p_write_rec                => l_write_rec,
             p_effective_date           => nvl(p_lf_evt_ocrd_dt,p_effective_date),
             p_assignment_id            => l_asg.assignment_id,
             p_organization_id          => l_asg.organization_id,
             p_business_group_id        => l_epe.business_group_id,
             p_pgm_id                   => l_epe.pgm_id,
             p_pl_id                    => l_epe.pl_id,
             p_pl_typ_id                => l_epe.pl_typ_id,
             p_opt_id                   => l_opt.opt_id,
             p_ler_id                   => l_epe.ler_id,
             p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
             p_entr_val_at_enrt_flag    => l_cvg(0).entr_val_at_enrt_flag,
             p_jurisdiction_code        => l_jurisdiction_code,
             p_check_received           => l_check_received,
             p_mx_cvg_wout_ctfn_val     => l_mx_cvg_wout_ctfn_val,
	     p_cvg_mlt_cd		=> l_cvg(0).cvg_mlt_cd,
	     --Bug 4644489
  	  p_rstrn_mn_cvg_rqd_amt => l_rstrn_mn_cvg_rqd_amt);
--End Bug 4644489
             --
    end if;
    --
    ben_determine_coverage.write_coverage
      (p_calculate_only_mode    => p_calculate_only_mode,
       p_bndry_perd_cd          => l_cvg(0).bndry_perd_cd,
       p_bnft_typ_cd            => l_cvg(0).bnft_typ_cd,
       p_val                    => l_combined_val,
       p_dflt_flag              => l_epe.dflt_flag,
       p_nnmntry_uom            => l_cvg(0).nnmntry_uom,
       p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
       p_business_group_id      => l_cvg(0).business_group_id,
       p_effective_date         => p_effective_date,
       p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
       p_person_id              => l_epe.person_id,
       p_lwr_lmt_val            => l_cvg(0).lwr_lmt_val,
       p_lwr_lmt_calc_rl        => l_cvg(0).lwr_lmt_calc_rl,
       p_upr_lmt_val            => l_cvg(0).upr_lmt_val,
       p_upr_lmt_calc_rl        => l_cvg(0).upr_lmt_calc_rl,
       p_rndg_cd                => l_cvg(0).rndg_cd,
       p_rndg_rl                => l_cvg(0).rndg_rl,
       p_comp_lvl_fctr_id       => l_cvg(0).comp_lvl_fctr_id,
       p_cvg_mlt_cd             => l_cvg(0).cvg_mlt_cd,
       p_entr_val_at_enrt_flag  => l_cvg(0).entr_val_at_enrt_flag,
         p_mx_val      => nvl(l_rstrn.mx_cvg_wcfn_amt, l_cvg(0).mx_val),  -- mx with ctfn
       /*
           CODE PRIOR TO WWBUG: 2054078
       p_mx_wout_ctfn_val       => l_rstrn.mx_cvg_alwd_amt,
       */
       /* Start of Changes for WWBUG: 2054078           */
       p_mx_wout_ctfn_val       => nvl(l_rstrn.mx_cvg_alwd_amt,l_mx_cvg_wout_ctfn_val),
       /* End of Changes for WWBUG: 2054078             */
       p_mn_val                 => l_cvg(0).mn_val,
       p_dflt_val               => l_cvg(0).dflt_val,
       p_incrmt_val             => l_cvg(0).incrmt_val,
       p_rt_typ_cd              => l_cvg(0).rt_typ_cd,
       p_perform_rounding_flg   => l_perform_rounding_flg,
       p_ordr_num               => l_order_number,
       p_ctfn_rqd_flag          => l_ctfn_rqd,
       p_enrt_bnft_id           => l_enrt_bnft_id,
       p_enb_valrow             => p_enb_valrow,
       p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
       p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
       p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
       p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl,
       p_bnft_amount            => l_cvg_amount,
       p_vapro_exist            => l_vapro_exist
       );
    -- bug 5900235
    if l_cvg(0).cvg_mlt_cd = 'RL'
     then

      if  l_ctfn_rqd = 'Y'  and not p_calculate_only_mode
           then
          --

          write_ctfn;
          --
       end if;  -- end 5900235
    else
       if not p_calculate_only_mode and l_rstrn_found
           then
          --
          write_ctfn;
          --
       end if;
    end if;
  --
  else
    --
    fnd_message.set_name('BEN','BEN_91844_BENCVRGE_MLT_CD');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',to_char(l_epe.person_id));
    fnd_message.set_token('CALC_MTHD',l_cvg(0).cvg_mlt_cd);
    fnd_message.set_token('PGM_ID',to_char(l_epe.pgm_id));
    fnd_message.set_token('PL_ID',to_char(l_epe.pl_id));
    fnd_message.set_token('PL_TYP_ID',to_char(l_epe.pl_typ_id));
    fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
    fnd_message.set_token('PLIP_ID',to_char(l_epe.plip_id));
    fnd_message.set_token('PTIP_ID',to_char(l_epe.ptip_id));
    fnd_message.raise_error;
    --
  end if;
  --
  -- This following routine need to create an additional benefit row, if
  -- tne interim enrollment code is 'Same'
  -- this row will be used for assigning the interim coverage
  --
  hr_utility.set_location (' Current Same Calculations ',10);

  l_interim_cd := substr(l_rstrn.dflt_to_asn_pndg_ctfn_cd,4,2) ;
  l_current_level_cd := substr(l_rstrn.dflt_to_asn_pndg_ctfn_cd,2,2);
  --
  hr_utility.set_location (' l_interim_cd '||l_interim_cd,22);
  hr_utility.set_location (' l_current_level_cd '||l_current_level_cd,22);
  --
  l_current_plan_id := null ;
  l_current_oipl_id := null ;
  --
  if l_interim_cd = 'SM' then
    --
    if l_current_level_cd = 'AS' then
      --
      open c_current_enrt_in_pl_typ(l_epe.pl_typ_id,
                 nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))) ; -- FONM
      fetch c_current_enrt_in_pl_typ into l_current_plan_id,l_current_oipl_id ;
      if c_current_enrt_in_pl_typ%found then
        hr_utility.set_location(' l_create_current_enb := true PLTYP',222);
        l_create_current_enb := true ;
      end if;
      close c_current_enrt_in_pl_typ;
      --
    elsif l_current_level_cd = 'SE' then
      open c_current_enrt_in_pln(l_epe.pl_id,
                 nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))) ; -- FONM
      fetch c_current_enrt_in_pln into l_current_plan_id,l_current_oipl_id ;
      if c_current_enrt_in_pln%found then
        l_create_current_enb := true ;
      end if;
      close c_current_enrt_in_pln;
    elsif l_current_level_cd = 'SO' then
      -- Bug 2543071 changed the l_epe.pl_id to l_epe.oipl_id and added
      -- the if condition.
      if l_epe.oipl_id is not null then
        open c_current_enrt_in_oipl(l_epe.oipl_id,
                 nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))) ; -- FONM
        fetch c_current_enrt_in_oipl into l_current_plan_id,l_current_oipl_id ;
        if c_current_enrt_in_oipl%found then
          l_create_current_enb := true ;
        end if;
        close c_current_enrt_in_oipl;
      end if;
    end if;
    --
    hr_utility.set_location (' l_current_plan_id '||l_current_plan_id,222);
    hr_utility.set_location (' l_epe.pl_id '||l_epe.pl_id,222);
    hr_utility.set_location (' l_current_oipl_id '||l_current_oipl_id,222);
    hr_utility.set_location (' l_epe.oipl_id '||l_epe.oipl_id,222);
    hr_utility.set_location (' Date '||nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date)),222);
    --
    if l_create_current_enb and l_current_plan_id = l_epe.pl_id
                            and nvl(l_current_oipl_id,-1) = nvl(l_epe.oipl_id,-1) then
      --
      hr_utility.set_location ('l_person_id '||l_person_id,222);
      --
      open c_current_enb(l_epe.pl_id,l_epe.oipl_id,
                 nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))) ; -- FONM
      fetch c_current_enb into l_current_enb ;
      if c_current_enb%found  and not p_calculate_only_mode then
        hr_utility.set_location('SAME  interim row',111);
        ben_enrt_bnft_api.create_enrt_bnft
         (p_validate               => false,
          p_dflt_flag              => 'N',
          p_val_has_bn_prortd_flag => 'N',        -- change when prorating
          p_bndry_perd_cd          => l_current_enb.bndry_perd_cd, -- l_cvg(0).bndry_perd_cd,
          p_bnft_typ_cd            => l_current_enb.bnft_typ_cd,   -- l_cvg(0).bnft_typ_cd,
          p_val                    => l_current_enb.bnft_amt,  -- l_rstrn.mx_cvg_alwd_amt, /*ENH */
          p_nnmntry_uom            => l_current_enb.nnmntry_uom, -- l_cvg(0).nnmntry_uom,
          p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
          p_prtt_enrt_rslt_id      => l_current_enb.prtt_enrt_rslt_id,
          p_business_group_id      => l_current_enb.business_group_id, -- l_cvg(0).business_group_id,
          p_effective_date         => nvl(p_lf_evt_ocrd_dt,p_effective_date),
          p_program_application_id => fnd_global.prog_appl_id,
          p_program_id             => fnd_global.conc_program_id,
          p_request_id             => fnd_global.conc_request_id,
          p_comp_lvl_fctr_id       => l_current_enb.comp_lvl_fctr_id, --l_cvg(0).comp_lvl_fctr_id,
          p_cvg_mlt_cd             => l_current_enb.cvg_mlt_cd,       -- l_cvg(0).cvg_mlt_cd,
          p_crntly_enrld_flag      => 'N',
          p_ctfn_rqd_flag          => 'N',
          p_entr_val_at_enrt_flag  => 'N',
          p_mx_val                 => null,  -- max with ctfn
          p_mx_wout_ctfn_val       => null,  -- max without ctfn
          p_mn_val                 => null,
          p_incrmt_val             => null,
          p_dflt_val               => null,
          p_rt_typ_cd              => l_current_enb.rt_typ_cd, -- l_cvg(0).rt_typ_cd,
          p_mx_wo_ctfn_flag        => 'Y',
          p_program_update_date    => sysdate,
          p_enrt_bnft_id           => l_enrt_bnft_id,
          p_object_version_number  => l_object_version_number,
          p_ordr_num               => -1);
      end if;
      close c_current_enb ;
    end if;
    --
  end if;
  hr_utility.set_location ('Leaving '||l_package,10);
  --
 end main;
 --
end ben_determine_coverage;

/
