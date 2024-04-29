--------------------------------------------------------
--  DDL for Package Body BEN_BACK_OUT_LIFE_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BACK_OUT_LIFE_EVENT" as
/* $Header: benbolfe.pkb 120.28.12010000.24 2010/01/08 13:31:10 pvelvano ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Back Out Life Event
Purpose
        This package is used to back out all information that is related to
        a particular life event.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        07-JUN-1998      GPERRY     110.0      Created.
                                               Waiting for element_entries
                                               API call from TM.
        12-JUN-1998      GPERRY     110.1      Added in Element Entries API
                                               Call.
        14-JUN-1998      GPERRY     110.2      Fixed type in if statement.
        22-SEP-1998      GPERRY     115.3      Fixed error in SQL statements
                                               where previously looking for
                                               per_in_ler_stat_cd = 'A' now
                                               per_in_ler_stat_cd = 'STRTD'.
        12-OCT-1998      MAAGRAWA   115.4      Added parameter business_group_id
                                               in calls to delete procedures
                                               for elig_cvrd_dpnt and pl_bnf.
        26-OCT-1998      JCARPENT   115.5      Made prv non datetracked
        30-OCT-1998      GPERRY     115.6      Performance changes, made all
                                               SQL statements use unions
                                               instead of exists, that way we
                                               can use the indexes.
       30-Oct-1998      lmcdonal    115.7      The delete-choice api now deletes
                                               associated ctfn, rates and bnfts
                                               so removed those deletes from here.
                                               Also removed the join from choice
                                               to result from the choice cursor.
       30-Oct-1998      lmcdonal    115.8      Remove ben_enrt_cm_prvdd logic.
                                               We need to replace with new cm
                                               tables.
                                               Added multi-row parm to rslt call
       31-Dec-98        maagrawa    115.9      Added new delete sections for
                                               BEN_PIL_ELCTBL_CHC_POPL
                                               BEN_PER_CM_F
                                                   - BEN_PER_CM_PRVDD_F
                                                   - BEN_PER_CM_TRGR_F
                                                   - BEN_PER_CM_USG_F
                                               BEN_BNFT_PRVDD_LDGR_F
                                               BEN_PRMRY_CARE_PRVDR_F
                                               Delete logic changed for
                                                 BEN_PRTT_ENRT_RSLT_F
                                                 BEN_ELIG_CVRD_DPNT_F
                                                 BEN_PL_BNF_F
                                                 BEN_PRTT_RT_VAL and
                                                 communication tables
                                               to use datetrack mode as future
                                               delete if past records exist
                                               for a different per_in_ler.
      12-Jan-99        maagrawa   115.10       p_acty_base_rt_id removed from
                                               delete_prtt_rt_val.
      01-Feb-99        jcarpent   115.11       Changed update_prtt_rt_val to use
                                               ended_per_in_ler_id.
      09-Apr-99        jcarpent   115.12       Only communication with
                                               to_be_sent_dt >= today deleted
                                               removed per_cm_usg/trgr delete
                                               since per_cm api cascade deletes
      24-Apr-99        lmcdonal   115.13       prtt-rt-val now has a status code.
      11-May-99        lmcdonal   115.14       1. Check status of per-in-ler before
                                               backing it out.
                                               2. When looking for children to
                                               delete or backout, do not check for
                                               per-in-ler-status of 'STRTD'.
                                               3. Remove per-in-ler parm from
                                               c_prv_of_previous_pil cursor.
                                               4. We are no longer zapping results,
                                               rates, dpnts, bnfs, actns, ctfns when
                                               backing out a life event.  We either
                                               mark it as 'backed out' or we leave the
                                               data alone, if it's parent is marked
                                               'backed out'.  Issue_97.doc.
      25-jun-99        jcarpent   115.15       Back out bpl using pil_id.
      08-jul-99        jcarpent   115.16       Added ben_prtt_prem, ben_elig_per,
                                               ben_elig_per_opt.  Removed ben_epe,
                                               bnft_prvdd_ldgr, prtt_enrt_actn,
                                               prtt_enrt_ctfn_prvdd,cvrd_dpnt_ctfn_prvdd,
                                               pl_bnf_ctfn_prvdd,all per_cm% tables.
                                               Removed because of per_in_ler status checks
      08-jul-99        pbodla     115.17       Code to backup data from ben_pl_bnf_f, BEN_PRTT_RT_VAL,
                                               ben_prtt_prem, ben_elig_per, ben_elig_per_opt
                                               ben_elig_cvrd_dpnt_f, ben_pil_elctbl_chc_popl,
                                               ben_prtt_enrt_rslt_f added.
      09-jul-99        shdas      115.18       Moved unprocess_ptnl_ler proc here from benptnle.
      15-jul-99        jcarpent   115.19       Added calls to ben_ext_chlg.log_benefit_chg
      24-Aug-99        maagrawa   115.20       Dependents table changes.
      31-Aug-99        gperry     115.21       Changed call to ptnl_ler_for_per
      22-Sep-99        pbodla     115.22       per in ler which causes this
                                               per in ler to back out is
                                               (bckt_per_in_ler_id) added.
      04-Oct-99        Gperry     115.23       Added p_bckt_stat_cd to
                                               unprocess_ptnl_ler procedure.
      12-Oct-99        Tmathers   115.24       removed val form ben_prtt_prem_f
      12-Oct-99        pbodla     115.25       Added code to insert link data
                                                between pen and epe into lcr
                                                table when the enrt results are
                                                deleted.
      25-Oct-99        pbodla     115.26       When backing out epe data
                                               l_epe.elig_per_elctbl_chc_id,is
                                               passed as bkup_tbl_id
      11-Nov-99        pbodla     115.27       When prv data written to lcr
                                               per_in_ler_id is also written.
      13-Nov-99        pbodla     115.28       When backing out epe data
                                               l_epe.elig_per_elctbl_chc_id,is
                                               passed as bkup_tbl_id
      14-Nov-99        pbodla     115.29       When prv data is backed out, write
                                               ecr data to backup table to restore
                                               the ecr data when bchdt row is reinstated.
                                               dt_api.object... function used to get
                                               the latest object version number.
      29-Nov-99        jcarpent   115.30     - Added person_id to call to update_prv
      15-Dec-99        maagrawa   115.31     - Function used to fetch the
                                               object version number for prv
                                               record moved up, before insert
                                               into temporary table.
      17-Jan-00        pbodla     115.32     - Bug : 1143673(4287) changes look in the
                                               code for further comments.
      25-Jan-00        thayden    115.33     - Add parameters to call to ben_ext_chlg.
      05-Feb-00        stee       115.34     - Back out cobra qualified
                                               beneficiary. WWBUG#1178633.
                                             - Bug 4661 : When rates are backed out
                                               use the effective_start_date of the
                                               enrollment result as p_effective_date.
      16-Feb-00        stee       115.35     - Back out all cobra qualified
                                               beneficiaries.
      26-Feb-00        pbodla     115.36     - Bug 4785 Fixed, see comment below
      01-MAR-00        pbodla     115.37     - Bug 4186 : Added procedure
                                               p_backout_contact_pils to back out
                                               the related person life events.
      03-MAR-00        pbodla     115.38     - Bug : 4822 when past pil records's max esd
                                               is fetched do not use the effective_date
      04-APR-00        mmogel     115.39     - Added tokens to messages to make
                                               the messages more meaningful to
                                               the user
      15-APR-00        pbodla     115.40     - Bug Reported by Fidelity :
                                               When date track rows are deleted
                                               by future change, this should
                                               happen only once for a given
                                               primary key. See example below.

row   per_in_ler_id   enrt_rslt_id  ovn effective_start_date effective_end_date

1     1               9             1   01/01/00             01/15/00
2     2               9             2   01/16/00             01/25/00
3     2               9             3   01/26/00             EOT

   When per in ler 2 is backed out row 1 is un end dated and rows 2 and 3
   are deleted by using the FUTURE_CHANGE logic. When cursor like c_prtt_enrt_rslt_f
   hits row 2, due to FUTURE_CHANGE delete on row 1, row 2 and 3 are deleted.
   When cursor next fetches row 3, just skip the FUTURE_CHANGE delete logic.

      24-APR-00        pbodla     115.41     - Bug 5138 : c_prv_of_previous_pil
                                               select only null status records.
      05-JUN-00        pbodla     115.42     - Bug 5222 : Removed the effective date check.
      19-JUN-00        pbodla     115.43     - Bug 1146792 (4285) : If a
                                               potential for given lf_evt_ocrd_dt,
                                               ler_id, ntfn_dt exists then
                                               voidd the potetial associated
                                               with the backing out per in ler.
                                             - In other words, do not make it
                                               unprocessed potential.
      22-JUN-00        pbodla     115.44     - Fixed the c_ptnl_exist cursor :
                                               used the person_id.
      19-JUL-00        pbodla     115.45     - Bug 5372 Code which writes the link between
                                               elig per elctbl chc and enrollment
                                               results into ben_le_clps_n_rstr is
                                               removed as it's no longer needed.
      21-JUL-00        rchase     115.47     - Bug#5364
                                               Update elig cursors in delete_routine
                                               to use lf_evt_ocrd_dt instead
                                               of p_effective date
      28-JUL-00        rchase     115.48     - Bug#5364 continuation
                                               Update the c_epo_max_esd_of_past_pil
                                               cursor in the delete_routine
                                               to fetch the appropriate
                                               dates for deleting ben_elig_per_opt_f
                                               rows
      03-AUG-00        pbodla     115.49     - Removed the effective date usage
                                               from the cursors -
                                               c_ben_ELIG_PER_OPT_f,
                                               c_epo_max_esd_of_past_pil,
                                               c_ben_elig_per_f,
                                               c_ben_prtt_prem_f,
                                               c_ben_pl_bnf_f,
                                               c_ben_prmry_care_prvdr_f
      31-AUG-00       jcarpent    115.50       OraBug# 4988. Added logic to
                      cdaniels                 skip the call to the delete
                                               routine associated with most
                                               of the p_routines when
                                               l_effective_date passed is
                                               not EOT.
                                               Affect p_routines:
                                               BEN_ELIG_CVRD_DPNT_F
                                               BEN_ELIG_PER_F
                                               BEN_ELIG_PER_OPT_F
                                               BEN_PRTT_PREM_F
                                               BEN_PL_BNF_F
                                               BEN_PRTT_ENRT_RSLT_F
      14-Sep-2000     jcarpent    115.51       Bug 1269016.  added bolfe
                                               effective_date global.
      27-SEP-2000     cdaniels    115.52     - Tar# 1090241.996. Eliminated test
                                               for not NULL l_person_id prior to
                                               opening cursor c_prv_of_previous_
                                               pil. Also modified c_prv_of_
                                               previous_pil to include join to
                                               ben_per_in_ler to get l_person_id
                                               based on this cursor rather than
                                               c_ben_prtt_rt_val.
      03-JAN-01        tilak      115.53     - Bug 1182293  reimburement reqist table added
      09-feb-01        ikasire    115.54       Bug 1627373 and 1584238 to fix the
                                               issue - can't backout if the
                                               rate start date < life event occured date

      15-FEB-2001     pbodla      115.56     - Fix in 115.55 is put back in.
                                               This is next version of 115.54
      21-MAR-2001     kmahendr    115.57     - Bug 1690358 - for ben_prmry_care_prvdr_f delete
                                               routine, effective_start_date of the row is sent
                                               as effective_date
      15-May-2001     kmahendr    115.58     - Bug#1653733 - Rate change only event is not cal-
                                               culating prtt_rt_val if event is backed out and
                                               reprocessed - added delete_routine for the table
                                               ben_bnft_prvdd_ldgr_f
      06-Jun-2001     pbodla      115.59     - Bug 1814166 : Causing primary key violation.
                                               Commented pep, epo backup as data is not used
                                               by benleclr.pkb
      16-Jul-01       kmahendr    115.60     - Unrestricted life event not be backedout - added
                                               cursor c_ler_typ
      19-jul-01       tilak       115.61     - typo in closing the cursor c_ler_typ corrected
      06-Nov-01       pbbodla     115.62     - bug 2097880 :Before writing into backup tables
                                               check whether rows already exists.
      13-Nov-01       tjesumic    115.63     - l_ecr.enrt_rt_id is intialised before the
                                               c_ecr cursor to avoid the old data carried forward
                                               if c_ecr fails
     14-Dec-01        kmahendr    115.64     - initialise g_backout_flag
     22-Jan-02        kmahendr    115.65     - Added if condition to check previous pk id
                                               before calling delete_benefit_ledger-
                                               bug#2194632
     04-Mar-02        shdas       115.66     - Created self-service wrapper for
                                               running backout life events.
     13-Mar-02        ikasire     115.67       UTF8 Changes
     18-May-02	      hnarayan    115.69     - Bug 2223214 - added condition in cursor c_prc
     					       of delete_routine procedure to not consider
     					       voided claims during backout
     30-May-02        ikasire     115.70       Bug 2386000 Added p_called_from parameter to
                                               delete_elig_cvrd_dpnt calll
     22-Aug-02        ikasire     115.71       Bug 2526994 g_backout_flag needs to be reset
     23-Aug-02	      hnarayan    115.72     - Bug 2518955 - modified delete_routine for
     						BEN_PRTT_REIMBMT_RQST_F to show custom message
     12-sep-02        vsethi      115.73     - Bug 2552295 to ben_plan_beneficiary_api passing
				    	       p_multi_row_actn as False.
     24-Sep-02        kmahendr    115.74     -Bug2592783 - per_in_stat_cd added to cursor
                                              c_bpl_max_esd_of_past_pil.
     10-oct-02        tjesumic    115.75     -Bug 2546259 When the Result is future dated  and
                                  115.76      Deenrolled, the cverd dpnd is deleted with
                                  115,77      Delete  mode, this result into single row
                                              with effective end date to effective date
                                              PDP table does not have any status to track
                                              if the LE which end date the result is backedout
                                              the Covered Dpnt row left as it is without extending
                                              End date to EOT. This is because the PDP row is not
                                              date tracked and there is relation between the PIL
                                              and end dated PDP row. To extend the Effective end
                                              date  new cursor added in delte_rutine procedure
    28-oct-02         kmahendr    115.78      Bug#2646851 - cursor modified with order by clause and
                                              max function removed

    28-dec-2002       nhunur      115.79      nocopy changes.
    31-dec-2002       pbodla      115.80      Bug 2712602 CWB : When comp per in
                                              ler is backed out modify and
                                              remove heirarchy data.
    11-mar-2003       kmahendr    115.81      Bug#2821279 : Removed the max functions and logic
                                              is based on order by clause.
    10-mar-2003       pbodla      115.82      Bug 2695023 CWB : If pay proposal is
                                              associated with rate remove it also.
    20-mar-2003       ikasire     115.83      Bug 2847654 adding more hr_utility to isolate
                                              an issue in the hrqa115m which is not replicable
    20-mar-2003       ikasire     115.84      Bug 2847654 fix removed the use of p_effective_date
                                              removed the hr_utility
    16-Apr-2003       tjesumic    115.85      Bug # 2899702 manage_per_type_usage is called while
                                              deleting result to delete the parttn usage
    24-Jun-2003       tjesumic    115,86      c_futur_del_dpnt cursor is closed
    28-Aug-2003       tjesumic    115.87      bug # 3086161 whne the open LE reprocessed on the same day of
                                              the previous LE process date. the previous LE result are
                                              updated with open per in ler id. if the open LE is backedout
                                              then the result of  previous LE are lost. this is
                                              fixed by copying the result of  LE to backop table and copy
                                              back to result when the opne is backed out
                                              New three cursor created for copying back result , dpnt and bnf
    03-Sep-2003       rpgupta     115.88      3136058 Grade Step Backout
    26-Sep-2003       kmahendr    115.89      Modified cursor c_ben_prtt_rt_val for GHR fix
    29-Oct-2003       tjesumic    115.90      #  2982606 Result level backup added, new parameter
                                              p_bckdt_prtt_enrt_rslt_id added for the purpose. if the param is not null
                                              only the result of the p_bckdt_prtt_enrt_rslt_id is backed out
                                              if the per_in_ler careated the result level backout then
                                              backing out the per inler reinstate the result
                                              realted chagnes in bendenrr , benelinf ,benleclr
   30-Oct-2003        tjesumic    115.91      fix of 3086161 not allowing to reinstate the per in ler id which
                                              created the corrected result, this results are required to
                                              restore the corrected per_in_ler_id. # 3175382 fix allows to
                                              created the result into backout table but not allows to be deleted
                                              new cursor c_corr_rslt_esist creted
    03-Sep-2003       rpgupta     115.92      CWBGLOBAL : CWB Global backout changes
    20-Feb-2004       kmahendr    115.94      Bug#3442729 - cursor c_ppe_max_esd_of_past_pi
                                              modified and l_effective_date initialised
    09-Mar-2004       ikasire     115.95      Bug 3495372 We can have multiple tables with coverage
                                              restrictions when there is an interim with the
                                              same comp object. This happens when the coverage is
                                              enter value at enrollment.
    15-Mar-2004       ikasire     115.96      Bug 3507554 performance changes
    04-Apr-2004       ikasire     115.97      Bug 3550789 Added two new procedures
                                              restore_prev_pep and restore_prev_epo
    21-Apr-2004       ikasire     115.98      Bug 3550789 Added datetrack mode for PEP and EPO
                                              corrections. also two more missing paramaters in the
                                              PEP and EPO calls
    23-May-2004       ikasire     115.99      CWBGLOBAL changes should not go into
                                              2004 july FP and 11.5.10 so, CWBGLOBAL
                                              changes are commented.
    21 Jun 2004       kmahendr    115.100     Bug#3702033 - when backed out result is
                                              corrected with previous per in ler, the row in
                                              ben_le_cl_n_rstr updated
    29 Jun 2004       ikasire     115.101     Bug3709516 we are zaping ben_prmry_care_prvdr_f
                                              commented the delete_routine for this as we
                                              need to reinstate them.
    15 Jul 2004       kmahendr    115.102     Bug#3702090 - added exists condition for
                                              c_ben_bnft_prvdd_ldgr_f
    16 Aug 2004       pbodla      115.103     IREC : Avoid backing out contact pils
                                              iRec mode p_backout_contact_pils
    25 Aug 2004       pbodla      115.104     CFW : 2534391 :NEED TO LEAVE ACTION
                                              ITEMS CERTIFICATIONS on subsequent
                                              events
    30 Aug 2004       pbodla      115.105     CFW : modified cursor c_get_past_pil
                                              not to consider backed out event
    31 Aug 2004       pbodla      115.106     CFW : sspnd_flag is fetched from
                                              old result.
    02 Sep 2004       pbodla      115.107     CFW : Removed usage of
                                              l_sspnd_flag
    16 Sep 2004       mmudigon    115.108     Bug fix 3859152
    30-Sep-2004       hmani       115.109     If iRec then backout to VOIDD
    30-Nov-2004       kmahendr    115.110     Bug#3964234 - Modified cursor
                                              c_BEN_LE_CLSN_N_RSTR_corr
    20-Dec-2004       tjesumic    115.111     cursor  c_BEN_LE_CLSN_N_RSTR_dpnt modifued to
                                              use table instead of view
    08-Feb-2005       tjesumic    115.112     copy_oly parameter added to copy the date to backup table
                                              #4118315
    15-Feb-2005       kmahendr    115.113     Bug#4172989 - multi_row_actn parameter added
                                              to delete_elig_cvrd_dpnt
    16-Feb-2005       mmudigon    115.114     Bug 4157759. Changes to
                                              cursor c_prv_of_previous_pil
    09-Mar-2005       kmahendr    115.115     Bug#4206567 - rate update is called only
                                              if result exists
    28-mar-2005       ikasire     115.116     Bug 4241413
    23-Aug-2005       pbodla      115.117     Bug 4396096 - Many delete procedures
                                              are not relevant for CWB and GSP
                                              life events.
    31-Aug-2005       ikasire     115.118     BUG 4558512 need to process the completed action items
                                              properly in the reinstate
    15-Sep-2005       kmahendr    115.119     Bug#4597122 - modified cursor c_get
                                              _contact_pils to use lf_evt_ocrd_dt
    22-Sep-2005       kmahendr    115.120     Bug#4597122 - modified cursor c_ler_typ
                                              to use lf_evt_ocrd_dt
    30-sep-05         ssarkar     115.121    Bug : 4615207 - Mulitple Rate chk to be performed only for GHR
    06-Oct-2005       abparekh    115.123     Bug 4642315 : In procedure UNPROCESS_SUSP_ENRT_PAST_PIL,
                                                            while deleting PEA, call API only once for
                                                            every PEA_Id
    06-Oct-2005       stee        115.124     Bug Bug#4486609 - Back up the quald_bnf_flag
                                              and inelg_rsn_cd for BEN_CBR_QUALD_BNF.  Also,
                                              set the quald_bnf_flag = 'Y' and inelg_rsn_cd
                                              to null when an event is backed out.
   07-oct-05         ssarkar     115.125     bug: 4615207 - Mulitple Rate chk to be performed only for GHR
   02-Jan-2006       abparekh    115.126     Bug 4919951 : Reset G_BACKOUT_FLAG in case of any exception
   10-Feb-2006       kmahendr    115.127     Bug#5032364-added delete_enrollment
                                             to ben_prtt_enrt_rslt_F delete routine
   28-Feb-2006       kmahendr    115.128     Added cursor c_BEN_LE_CLSN_N_RSTR_del
   08-mar-2006       nhunur      115.129     skip pep, epo for cwb global backout.
   11-Apr-2006       rbingi      115.130     5148936: Added order by to cursor c_actn_item_for_past_pil
   27-apr-06         ssarkar     115.131     5187145 : added sub_query to cursor c_actn_item_for_past_pil
   06-Sep-2006       abparekh    115.132     Bug 5500864 : Added code for reinstatement of BPL records
   29-Sep-2006       kmahendr    115.133     Added Adj_prv_rate for Fidelity Enh
   08-Nov-2006       ssarkar     115.134     bug 5649636 c_pbn_max_esd_of_past_pil is modified
   28-Nov-2006       gsehgal     115.135     bug 5668052 deleting person type usage for beneficiary
   23-feb-2007       ssarkar     115.136     bug 5895645 typo fix for c_pbn_max_esd_of_past_pil
   	                                         and dependent when back out life event
   09-May-2007       swjain      115.137     Bug 6034585: Updated procedure delete_routine -
                                             p_routine = 'BEN_PRTT_ENRT_RSLT_F'
   11-May-2007       ikasired    115.138     Bug 5985777 Added new procedure to reinstate the
                                             completed actions items from the last life event.
   26-Jun-2007       mkommuri    115.139     Bug6152593 updated cursor
                                             c_pep_max_esd_of_past_pil
   16-Jul-2007       sshetty     115.140     Bug 6216828, Added a cursor to
                                             fetch future dated LE.
   26-Jul-2007       sshetty     115.141     Bug 6216828, Fixed status code
                                             issue in enrollment results table
   04-Sep-2007       swjain      115.142     Bug 6376239 : Made changes in delete_routine for
                                             p_routine = 'BEN_BNFT_PRVDD_LDGR_F'
   07-Dec-2007       rtagarra    115.143     Bug 6489602 :Modified the cursor c_BEN_LE_CLSN_N_RSTR_corr.
   22-Feb-2008       rtagarra    115.144     6840074
   29-feb-2008       bachakra    115.146     Bug 6620291: Modified Cursor get_contacts_pils.
   03-mar-2008       bachakra    115.147     Bug 6632568: Modified Cursor c_corr_result_exist
                                             so that when _corr result exisits for previous pil,
					     current pil pen records get backed out correctly.

   18-mar-2008       bachakra    115.148     Bug 6882159: Added order by clause in cursor
                                             get_fut_dtd_cntct_pils, to ensure the backing out
					     of life events in correct order.
   17-Jun-2008       bachakra    115.154     Bug 7137371: Enrollment method code are not updated corectly
                                                          from the backup table where a correction result exists.
   19-Jun-2008       bachakra    115.155     Bug 7039025: Insert a correction row before updation as if,
					     the enrollments were corrected by the next pil. On top of bug 6903766
					     where enrollments were not getting restored if an intervening life
					     event did not offer electability to a plan type enrolled in the
					     previous life event.
   16-jul-2008       bachakra                Bug 7176884: after corrected rows are rstored for backing
                                             out subsequent life event, they are updated instead of deleting.
                                             Removed a part of 6034585 fix for this.
   24-jul-2008       bachakra                Bug 7206471: Added Adj_pen_cvg to handle overlapping coverages.
   06-oct-2008       sallumwa    115.156     Bug 7133998:Handled Backout process for premium records.
   15-oct-2008       stee        115.157     Bug 7197868: If there is a correction and an update
                                             to the enrollment results, delete future dated rows.
   16-Feb-2009       velvanop    115.158     Bug 8234902: When the certification is received, a new rate is created and
                                             existing rates for current life event get ended by same life event.
                                             Hence while backing out the life event these ended rates are reopened
					     till EOT causing valid rates to be tied to backed out event.
   19-Feb-2009       stee        115.159     Bug 8199189:  When correction rows are updated, also update
   21-Mar-2009       stee        115.160     Bug 8199189:  Remove the per_in_ler_id and prtt_enrt_rslt_stat_cd
                                                           from c_get_cvg_thru_dt.
   11-May-2009       velvanop    115.161     Bug 8495014:  Potential life  event on the dependent is voided when a life event is
                                             processed on the participant on a date prior to the dependent's potential
					     life event occurred date.
   25-May-2009       velvanop    115.162     Bug 8507247: Fixes done on top of Bug 7206471
   17-Aug-2009       velvanop    115.163     Bug 8604243: When a lifeevent is being backed out and the previous LE
                                             does not have electability and there are no enrollment results for the
					     previous LE, enrollments results of the LE for which enrollments are ended should
					     be reopened. In this case previous LE status will not be updated to 'STARTED' status and then
					     FORCE close the LE.
   11-Nov-2009       velvanop    115.165     Bug 9095753: APP-PAY-07187 error when backing out the Life Event.
                                             Fixed cursor c_future_pen to check whether future enrolments exists for
					     previous Life Event.
   18-Nov-2009       velvanop    115.166     Bug 8984394: Update the prtt_enrt_rslt_id on epe_id of previous pil epe's
                                             when results of previous pil are reopened after backing out the LE
   08-Jan-2010       velvanop    115.167     Bug 9236429: Update the prtt_enrt_rslt_id on the epe table for the previous Life Event
			                     when the present life event is backedout
   */
----------------------------------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_back_out_life_event';

procedure p_backout_contact_pils(p_person_id          in number,
                                 p_business_group_id  in number,
                                 p_per_in_ler_id      in number,
                                 p_bckt_stat_cd       in varchar2,
                                 p_csd_by_ptnl_ler_for_per_id in number,
                                 p_effective_date     in date) is
  --
  cursor get_contacts_pils(cv_person_id in number,
                           cv_csd_by_ptnl_ler_for_per_id in number) is
  select pil.*
  from per_contact_relationships pcr,
       ben_per_in_ler pil,
       ben_PTNL_LER_FOR_PER ppl
  where --pcr.contact_person_id   = cv_person_id
        pcr.person_id   = cv_person_id -- Bug 6620291
    and pcr.business_group_id   = p_business_group_id
    and pil.lf_evt_ocrd_dt between nvl(pcr.date_start,pil.lf_evt_ocrd_dt)
                             and nvl(pcr.date_end,pil.lf_evt_ocrd_dt)
    and pcr.personal_flag       = 'Y'
    --and pil.person_id           = pcr.person_id
    and pil.person_id           = pcr.contact_person_id -- Bug 6620291
    and pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
    and pil.ptnl_ler_for_per_id = ppl.ptnl_ler_for_per_id
    and ppl.ptnl_ler_for_per_src_cd in ('SYSGND')
    and ppl.csd_by_ptnl_ler_for_per_id = cv_csd_by_ptnl_ler_for_per_id;
  --

-- Bug:6216828 This cursor is added for fidelity bug where the future date
--Life event for the contacts are checked and backed out
--when the participant's life event that triggered temporal life event
--for the contacts and participant's LE is backed out.

   cursor get_fut_dtd_cntct_pils(cv_person_id in number
                           ) is
   select pil.*
  from per_contact_relationships pcr,
       ben_per_in_ler pil,
       ben_PTNL_LER_FOR_PER ppl
  where pcr.contact_person_id   = cv_person_id
    and pcr.business_group_id   = p_business_group_id
    and pil.lf_evt_ocrd_dt > (Select pil1.lf_evt_ocrd_dt
                                 from ben_per_in_ler pil1
                                where pil1.per_in_ler_id= p_per_in_ler_id)
    and pcr.personal_flag       = 'Y'
    and pil.person_id           = pcr.person_id
    and pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
    and pil.ptnl_ler_for_per_id = ppl.ptnl_ler_for_per_id
  order by pil.lf_evt_ocrd_dt desc; -- Bug 6882159

  cursor get_contacts_ptnls(cv_person_id in number,
                            cv_csd_by_ptnl_ler_for_per_id in number) is
  select con_ppl.*
  from ben_ptnl_ler_for_per con_ppl,
       per_contact_relationships pcr
  where con_ppl.csd_by_ptnl_ler_for_per_id = cv_csd_by_ptnl_ler_for_per_id
    and con_ppl.PERSON_ID       =  pcr.person_id
    and con_ppl.ptnl_ler_for_per_src_cd in ('SYSGND')
    and pcr.contact_person_id   = p_person_id;
  --
  l_ptnls_procd boolean;
  l_le_evt_ocrd_dt date;
  l_proc        varchar2(72) := g_package||'p_backout_contact_pils';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('p_bckt_stat_cd:'|| p_bckt_stat_cd, 10);
  hr_utility.set_location('p_csd_by_ptnl_ler_for_per_id:'|| p_csd_by_ptnl_ler_for_per_id, 10);
  --
  -- First check any potentials of detected or unprocessed
  -- exists. then void them.
  --
  for l_con_ptnls_rec in get_contacts_ptnls(p_person_id, p_csd_by_ptnl_ler_for_per_id)
  loop
      --
      if l_con_ptnls_rec.ptnl_ler_for_per_stat_cd in ('UNPROCD', 'DTCTD') then
         --
         -- Give messages idicating related potentials are voided
         -- due to back out of pil which created them.
         --
	 hr_utility.set_location(' In VOIDD loop '|| l_con_ptnls_rec.ptnl_ler_for_per_id, 10);
	 /*Bug 8495014: Potential LE's triggered on the dependent should not be backedout to VOID'ed state
	  while backing out the LifeEvent the on the Pariticipant.
	  Commented the call to 'update_ptnl_ler_for_per_perf' */

	 /*ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
          (p_validate                 => false
          ,p_ptnl_ler_for_per_id      => l_con_ptnls_rec.ptnl_ler_for_per_id
          ,p_ptnl_ler_for_per_stat_cd => 'VOIDD'
          ,p_object_version_number    => l_con_ptnls_rec.object_version_number
          ,p_effective_date           => p_effective_date
          ,p_program_application_id   => fnd_global.prog_appl_id
          ,p_program_id               => fnd_global.conc_program_id
          ,p_request_id               => fnd_global.conc_request_id
          ,p_program_update_date      => sysdate
          ,p_voidd_dt                 => p_effective_date);
         --
         -- write log message indicating related person potentials are
         -- are voided.
         --
         fnd_message.set_name('BEN','BEN_92507_CON_PTNLS_VOIDD');
         benutils.write(p_text => fnd_message.get);*/
         --
      elsif l_con_ptnls_rec.ptnl_ler_for_per_stat_cd in
                              ('VOIDD',  'MNL', 'BCKDT', 'MNLO')
         then
         --
         -- Give messages idicating related potentials are already voided
         -- It may be due to collapse of LE for contact or time out or
         -- used explicitly set it to void.
         -- so manual interpretation required to deal with them.
         --
         -- write log message indicating some of the related person potentials are
         -- are already set to voided or manual or manual override or backed out.
         --
         fnd_message.set_name('BEN','BEN_92508_CON_PTNLS_VMBMO');
         benutils.write(p_text => fnd_message.get);
         --
      elsif l_con_ptnls_rec.ptnl_ler_for_per_stat_cd = 'PROCD'
         then
         --
         l_ptnls_procd := TRUE;
         --
      end if;
      --
  end loop;
  --
  -- Now check any pils exists, if so back out them.
  --
  if l_ptnls_procd then
     --
     --Bug 6216828 change made by sshetty

     for l_fut_dtd_cntct_pils_rec in get_fut_dtd_cntct_pils
                                    (p_person_id)
     loop
      ben_back_out_life_event.back_out_life_events
        (p_per_in_ler_id         => l_fut_dtd_cntct_pils_rec.per_in_ler_id,
         p_bckt_per_in_ler_id    => p_per_in_ler_id,
         p_bckt_stat_cd          => p_bckt_stat_cd,
         p_business_group_id     => p_business_group_id,
         p_effective_date        => p_effective_date);
      end loop;

     for l_contacts_pils_rec in  get_contacts_pils(p_person_id, p_csd_by_ptnl_ler_for_per_id)
     loop
        --
        ben_back_out_life_event.back_out_life_events
        (p_per_in_ler_id         => l_contacts_pils_rec.per_in_ler_id,
         p_bckt_per_in_ler_id    => p_per_in_ler_id,
         p_bckt_stat_cd          => p_bckt_stat_cd,
         p_business_group_id     => p_business_group_id,
         p_effective_date        => p_effective_date);
        --
        -- write log message indicating some of the related person
        -- per in lers are backed out.
        --
        fnd_message.set_name('BEN','BEN_92509_CON_PILS_VOIDD');
        benutils.write(p_text => fnd_message.get);
        --
     end loop;


     --
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end p_backout_contact_pils;
--
-- ----------------------------------------------------------------------------
-- |------------------------< unprocess_ptnl_ler >-----------------------------|
-- ----------------------------------------------------------------------------
procedure unprocess_ptnl_ler(p_per_in_ler in  out nocopy BEN_PER_IN_LER%ROWTYPE
                            ,p_bckt_stat_cd   in varchar2
                            ,p_effective_date in date) is
  --
  l_proc varchar2(72) := g_package||'unprocess_ptnl_ler';
  --
  l_mnl_dt     date;
  l_unprocd_dt date;
  l_voidd_dt   date;
  l_object_version_number number;
  --
  cursor c_ptnl is
     select ppl.*
     from   ben_ptnl_ler_for_per ppl
     where  ppl.ptnl_ler_for_per_id = p_per_in_ler.ptnl_ler_for_per_id
     and    ppl.business_group_id = p_per_in_ler.business_group_id;
  --
  l_procd_ppl_rec c_ptnl%rowtype;
  --
  -- Bug 1146792 (4285) : If a potential for given
  -- lf_evt_ocrd_dt, ler_id, ntfn_dt exists then voidd the
  -- potetial associated with the backing out per in ler.
  -- In other words, do not make it unprocessed potential.
  --
  cursor c_ptnl_exist(cv_lf_evt_ocrd_dt date,
                      cv_business_group_id number,
                      cv_ler_id number,
                      cv_ntfn_dt date,
                      cv_procd_ptnl_ler_for_per_id number)
  is
     select ppl.*
     from   ben_ptnl_ler_for_per ppl
     where  ppl.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
       and  ppl.business_group_id = cv_business_group_id
       and  ppl.ler_id = cv_ler_id
       and  ppl.ptnl_ler_for_per_id <> cv_procd_ptnl_ler_for_per_id
       and  ppl.person_id = p_per_in_ler.person_id
       -- and  nvl(ppl.ntfn_dt, trunc(sysdate)) = nvl(cv_ntfn_dt, trunc(sysdate))
       and  ppl.PTNL_LER_FOR_PER_STAT_CD in ('DTCTD', 'UNPROCD', 'MNL', 'MNLO');
  --
  l_existing_ppl_rec c_ptnl_exist%rowtype;
  l_bckt_stat_cd hr_lookups.lookup_code%TYPE  := p_bckt_stat_cd; --UTF8
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_unprocd_dt := trunc(sysdate);
  --
  open  c_ptnl;
    --
    fetch c_ptnl into l_procd_ppl_rec;
    --
  close c_ptnl;
  --
  open c_ptnl_exist(l_procd_ppl_rec.lf_evt_ocrd_dt,
                    l_procd_ppl_rec.business_group_id,
                    l_procd_ppl_rec.ler_id,
                    l_procd_ppl_rec.ntfn_dt,
                    l_procd_ppl_rec.ptnl_ler_for_per_id);
  fetch c_ptnl_exist into l_existing_ppl_rec;
  --
  if c_ptnl_exist%found then
     --
     -- A similar potential already exists, so just
     -- void the current potential, instead of making it
     -- into unprocessed.
     --
     hr_utility.set_location('Changing status to VOIDD as a potential ' ||
                             'already exists',10);
     l_bckt_stat_cd := 'VOIDD';
     --
  end if;
  close c_ptnl_exist;
  --

  if l_bckt_stat_cd = 'UNPROCD' then
    --
    l_unprocd_dt := p_effective_date;
    --
  elsif l_bckt_stat_cd = 'VOIDD' then
    --
    l_voidd_dt := p_effective_date;
    --
  elsif l_bckt_stat_cd = 'MNL' then
    --
    l_mnl_dt := p_effective_date;
    --
  end if;
  --
  hr_utility.set_location('Setting status to '||l_bckt_stat_cd,10);
  ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
    (p_validate                 => false
    ,p_ptnl_ler_for_per_id      => p_per_in_ler.ptnl_ler_for_per_id
    ,p_ptnl_ler_for_per_stat_cd => l_bckt_stat_cd
    ,p_object_version_number    => l_procd_ppl_rec.object_version_number
    ,p_effective_date           => p_effective_date
    ,p_program_application_id   => fnd_global.prog_appl_id
    ,p_program_id               => fnd_global.conc_program_id
    ,p_request_id               => fnd_global.conc_request_id
    ,p_program_update_date      => sysdate
    ,p_unprocd_dt               => l_unprocd_dt
    ,p_voidd_dt                 => l_voidd_dt
    ,p_mnl_dt                   => l_mnl_dt);
  --
  hr_utility.set_location('Leaving:'|| l_proc, 90);
  --
end unprocess_ptnl_ler;
--

--
procedure restore_prev_pep
  (p_per_in_ler_id in number
  ) is
    --
    l_proc varchar2(72) := g_package||'restore_prev_pep';
    --
    cursor c_restore_pep( p_pil_id number ) IS
      select *
        from ben_le_clsn_n_rstr elig
       where elig.per_in_ler_ended_id = p_pil_id
         and elig.BKUP_TBL_TYP_CD = 'BEN_ELIG_PER_F_CORRECT' ;
    --
    cursor c_pep(p_elig_per_id number,p_effective_date date) IS
      select object_version_number
        from ben_elig_per_f pep
       where pep.elig_per_id = p_elig_per_id
         and p_effective_date between pep.effective_start_date
                                  and pep.effective_end_date ;
    --
    l_effective_date date ;
    l_correction                boolean;
    l_update                    boolean;
    l_update_override           boolean;
    l_update_change_insert      boolean;
    l_datetrack_mode            varchar2(100);
    --
  begin
    --
    hr_utility.set_location ('Entering '||l_proc,10);
    --
    FOR l_rec IN c_restore_pep(p_per_in_ler_id) LOOP
      --
      l_effective_date := l_rec.effective_start_date;
      --
      open c_pep(l_rec.BKUP_TBL_ID,l_effective_date);
      fetch c_pep INTO l_rec.object_version_number;
      IF c_pep%FOUND THEN
      --Get the Datetrack Mode
      dt_api.find_dt_upd_modes
        (p_effective_date       => l_effective_date,
         p_base_table_name      => 'BEN_ELIG_PER_F',
         p_base_key_column      => 'elig_per_id',
         p_base_key_value       => l_rec.BKUP_TBL_ID,
         p_correction           => l_correction,
         p_update               => l_update,
         p_update_override      => l_update_override,
         p_update_change_insert => l_update_change_insert);
      --
      if l_update_override then
        --
        l_datetrack_mode := hr_api.g_update_override;
        --
      elsif l_update then
        --
        l_datetrack_mode := hr_api.g_update;
        --
      else
        --
        l_datetrack_mode := hr_api.g_correction;
        --
      end if;
      --
      ben_Eligible_Person_perf_api.update_perf_Eligible_Person
        (p_validate                     => FALSE,
         p_elig_per_id                  => l_rec.BKUP_TBL_ID,
         p_per_in_ler_id                => l_rec.per_in_ler_id,
         p_effective_start_date         => l_rec.effective_start_date,
         p_effective_end_date           => l_rec.effective_end_date,
         p_elig_flag                    => l_rec.elig_flag,
         p_prtn_strt_dt                 => l_rec.prtn_strt_dt,
         p_prtn_end_dt                  => l_rec.prtn_end_dt,
         p_prtn_ovridn_flag             => l_rec.prtn_ovridn_flag,
         p_prtn_ovridn_thru_dt          => l_rec.prtn_ovridn_thru_dt,
         p_rt_comp_ref_amt              => l_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => l_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => l_rec.rt_comp_ref_uom,
         p_rt_age_val                   => l_rec.rt_age_val,
         p_rt_los_val                   => l_rec.rt_los_val,
         p_rt_hrs_wkd_val               => l_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => l_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => l_rec.rt_age_uom,
         p_rt_los_uom                   => l_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => l_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => l_rec.rt_frz_los_flag, -- 'N',
         p_rt_frz_age_flag              => l_rec.rt_frz_age_flag, --'N',
         p_rt_frz_cmp_lvl_flag          => l_rec.rt_frz_cmp_lvl_flag, -- 'N',
         p_rt_frz_pct_fl_tm_flag        => l_rec.rt_frz_pct_fl_tm_flag, -- 'N',
         p_rt_frz_hrs_wkd_flag          => l_rec.rt_frz_hrs_wkd_flag, -- 'N',
         p_rt_frz_comb_age_and_los_flag => l_rec.rt_frz_comb_age_and_los_flag, -- 'N',
         p_once_r_cntug_cd              => l_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => l_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => l_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => l_rec.comp_ref_uom,
         p_age_val                      => l_rec.age_val,
         p_los_val                      => l_rec.los_val,
         p_hrs_wkd_val                  => l_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => l_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => l_rec.age_uom,
         p_los_uom                      => l_rec.los_uom,
         p_pct_fl_tm_val                => l_rec.pct_fl_tm_val,
         p_frz_los_flag                 => l_rec.frz_los_flag, -- 'N',
         p_frz_age_flag                 => l_rec.frz_age_flag, -- 'N',
         p_frz_cmp_lvl_flag             => l_rec.frz_cmp_lvl_flag, -- 'N',
         p_frz_pct_fl_tm_flag           => l_rec.frz_pct_fl_tm_flag, -- 'N',
         p_frz_hrs_wkd_flag             => l_rec.frz_hrs_wkd_flag, -- 'N',
         p_frz_comb_age_and_los_flag    => l_rec.frz_comb_age_and_los_flag, -- 'N',
     --    p_wait_perd_cmpltn_dt          => l_wait_perd_cmpltn_dt,
     --    p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
         p_object_version_number        => l_rec.object_version_number,
         --
         p_effective_date               => l_effective_date,
         p_datetrack_mode               => l_datetrack_mode,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate);
         --
      ELSE
        NULL;
        --Do we need to Create one ?
        --
      END IF;
      --
      close c_pep;
      --
    END LOOP;
    --
    --Now Delete the records from ben_le_clsn_n_rstr
    --
    delete from ben_le_clsn_n_rstr elig
     where elig.per_in_ler_ended_id = p_per_in_ler_id
       and elig.BKUP_TBL_TYP_CD = 'BEN_ELIG_PER_F_CORRECT' ;
    --
    hr_utility.set_location ('Leaving '||l_proc,10);
    --
end restore_prev_pep ;
--
procedure restore_cert_completion
  (p_per_in_ler_id in number
  ) is
    --
    l_proc varchar2(72) := g_package||'restore_cert_completion';
    --
    cursor c_restore_pcs( p_pil_id number) IS
     select pcs.*
        from ben_le_clsn_n_rstr pcs,
             ben_le_clsn_n_rstr pea
       where pcs.per_in_ler_ended_id = p_pil_id
         and pea.per_in_ler_ended_id = p_pil_id
         and pea.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_ACTN_F_UPD'
         and pcs.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_CTFN_PRVDD_F_UPD'
         and pea.BKUP_TBL_ID = pcs.PGM_ID ; --PRTT_ENRT_ACTN_ID
    --
    cursor c_pcs(p_prtt_enrt_ctfn_prvdd_id number,
                 p_effective_date date ) IS
      select pcs.object_version_number
        from ben_prtt_enrt_ctfn_prvdd_f pcs,
             ben_prtt_enrt_actn_f pea
       where pcs.prtt_enrt_ctfn_prvdd_id = p_prtt_enrt_ctfn_prvdd_id
         and pea.prtt_enrt_actn_id = pcs.prtt_enrt_actn_id
         and p_effective_date between pcs.effective_start_date
                                  and pcs.effective_end_date
         and p_effective_date between pea.effective_start_date
                                  and pea.effective_end_date;
    --
    l_object_version_number     number;
    l_effective_date date ;
    l_correction                boolean;
    l_update                    boolean;
    l_update_override           boolean;
    l_update_change_insert      boolean;
    l_datetrack_mode            varchar2(100);
    --
  begin
    --
    hr_utility.set_location ('Entering '||l_proc,10);
    --
    FOR l_rec IN c_restore_pcs(p_per_in_ler_id) LOOP
      --
      l_effective_date := l_rec.effective_start_date;
      --
      open c_pcs(l_rec.BKUP_TBL_ID,l_effective_date);
      fetch c_pcs INTO l_rec.object_version_number;
      IF c_pcs%FOUND THEN
        --Get the Datetrack Mode
        dt_api.find_dt_upd_modes
          (p_effective_date       => l_effective_date,
           p_base_table_name      => 'BEN_PRTT_ENRT_CTFN_PRVDD_F',
           p_base_key_column      => 'PRTT_ENRT_CTFN_PRVDD_ID',
           p_base_key_value       => l_rec.BKUP_TBL_ID,
           p_correction           => l_correction,
           p_update               => l_update,
           p_update_override      => l_update_override,
           p_update_change_insert => l_update_change_insert);
        --
        if l_update_override then
          --
          l_datetrack_mode := hr_api.g_update_override;
          --
        elsif l_update then
          --
          l_datetrack_mode := hr_api.g_update;
          --
        else
          --
          l_datetrack_mode := hr_api.g_correction;
          --
        end if;
        --
        BEN_prtt_enrt_ctfn_prvdd_API.update_prtt_enrt_ctfn_prvdd
          (p_validate => FALSE
          ,p_PRTT_ENRT_CTFN_PRVDD_ID => l_rec.BKUP_TBL_ID
          ,p_EFFECTIVE_START_DATE =>    l_rec.EFFECTIVE_START_DATE
          ,p_EFFECTIVE_END_DATE =>      l_rec.EFFECTIVE_END_DATE
          ,p_ENRT_CTFN_RQD_FLAG =>      l_rec.PRTT_IS_CVRD_FLAG
          ,p_ENRT_CTFN_TYP_CD =>        l_rec.COMP_LVL_CD
          ,p_ENRT_CTFN_RECD_DT =>       l_rec.ENRT_CVG_THRU_DT
          ,p_ENRT_CTFN_DND_DT =>        l_rec.ENRT_OVRID_THRU_DT
          ,p_ENRT_R_BNFT_CTFN_CD =>     l_rec.BNFT_TYP_CD
          ,p_PRTT_ENRT_RSLT_ID =>       l_rec.PRTT_ENRT_RSLT_ID
          ,p_PRTT_ENRT_ACTN_ID =>       l_rec.PGM_ID
          ,p_BUSINESS_GROUP_ID =>       l_rec.BUSINESS_GROUP_ID
          ,p_PCS_ATTRIBUTE_CATEGORY =>  l_rec.LCR_ATTRIBUTE_CATEGORY
          ,p_PCS_ATTRIBUTE1 =>          l_rec.LCR_ATTRIBUTE1
          ,p_PCS_ATTRIBUTE2 =>          l_rec.LCR_ATTRIBUTE2
          ,p_PCS_ATTRIBUTE3 =>          l_rec.LCR_ATTRIBUTE3
          ,p_PCS_ATTRIBUTE4 =>          l_rec.LCR_ATTRIBUTE4
          ,p_PCS_ATTRIBUTE5 =>          l_rec.LCR_ATTRIBUTE5
          ,p_PCS_ATTRIBUTE6 =>          l_rec.LCR_ATTRIBUTE6
          ,p_PCS_ATTRIBUTE7 =>          l_rec.LCR_ATTRIBUTE7
          ,p_PCS_ATTRIBUTE8 =>          l_rec.LCR_ATTRIBUTE8
          ,p_PCS_ATTRIBUTE9 =>          l_rec.LCR_ATTRIBUTE9
          ,p_PCS_ATTRIBUTE10 =>         l_rec.LCR_ATTRIBUTE10
          ,p_PCS_ATTRIBUTE11 =>         l_rec.LCR_ATTRIBUTE11
          ,p_PCS_ATTRIBUTE12 =>         l_rec.LCR_ATTRIBUTE12
          ,p_PCS_ATTRIBUTE13 =>         l_rec.LCR_ATTRIBUTE13
          ,p_PCS_ATTRIBUTE14 =>         l_rec.LCR_ATTRIBUTE14
          ,p_PCS_ATTRIBUTE15 =>         l_rec.LCR_ATTRIBUTE15
          ,p_PCS_ATTRIBUTE16 =>         l_rec.LCR_ATTRIBUTE16
          ,p_PCS_ATTRIBUTE17 =>         l_rec.LCR_ATTRIBUTE17
          ,p_PCS_ATTRIBUTE18 =>         l_rec.LCR_ATTRIBUTE18
          ,p_PCS_ATTRIBUTE19 =>         l_rec.LCR_ATTRIBUTE19
          ,p_PCS_ATTRIBUTE20 =>         l_rec.LCR_ATTRIBUTE20
          ,p_PCS_ATTRIBUTE21 =>         l_rec.LCR_ATTRIBUTE21
          ,p_PCS_ATTRIBUTE22 =>         l_rec.LCR_ATTRIBUTE22
          ,p_PCS_ATTRIBUTE23 =>         l_rec.LCR_ATTRIBUTE23
          ,p_PCS_ATTRIBUTE24 =>         l_rec.LCR_ATTRIBUTE24
          ,p_PCS_ATTRIBUTE25 =>         l_rec.LCR_ATTRIBUTE25
          ,p_PCS_ATTRIBUTE26 =>         l_rec.LCR_ATTRIBUTE26
          ,p_PCS_ATTRIBUTE27 =>         l_rec.LCR_ATTRIBUTE27
          ,p_PCS_ATTRIBUTE28 =>         l_rec.LCR_ATTRIBUTE28
          ,p_PCS_ATTRIBUTE29 =>         l_rec.LCR_ATTRIBUTE29
          ,p_PCS_ATTRIBUTE30 =>         l_rec.LCR_ATTRIBUTE30
          ,p_OBJECT_VERSION_NUMBER =>   l_rec.object_version_number
          ,p_effective_date =>          l_effective_date
          ,p_datetrack_mode =>          l_datetrack_mode
        );
        --
      ELSE
        NULL;
        --Do we need to Create one ?
        --
      END IF;
      --
      close c_pcs;
      --
    END LOOP;
    --
    --Now Delete the records from ben_le_clsn_n_rstr
    --
    delete from ben_le_clsn_n_rstr pcs
     where pcs.per_in_ler_ended_id = p_per_in_ler_id
       and pcs.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_CTFN_PRVDD_F_UPD' ;
    --
    delete from ben_le_clsn_n_rstr pcs
     where pcs.per_in_ler_ended_id = p_per_in_ler_id
       and pcs.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_ACTN_F_UPD' ;
    --
    hr_utility.set_location ('Leaving '||l_proc,10);
    --
end restore_cert_completion ;
--
--
procedure restore_prev_epo
  (p_per_in_ler_id in number
  ) is
    --
    l_proc varchar2(72) := g_package||'restore_prev_epo';
    --
    cursor c_restore_epo( p_pil_id number ) IS
      select *
        from ben_le_clsn_n_rstr elig
       where elig.per_in_ler_ended_id = p_pil_id
         and elig.BKUP_TBL_TYP_CD = 'BEN_ELIG_PER_OPT_F_CORRECT' ;
    --
    cursor c_epo(p_elig_per_opt_id number,p_effective_date date) IS
      select object_version_number
        from ben_elig_per_opt_f epo
       where epo.elig_per_opt_id = p_elig_per_opt_id
         and p_effective_date between epo.effective_start_date
                                  and epo.effective_end_date ;
    --
    l_effective_date date ;
    l_correction                boolean;
    l_update                    boolean;
    l_update_override           boolean;
    l_update_change_insert      boolean;
    l_datetrack_mode            varchar2(100);
    --
  begin
    --
    hr_utility.set_location ('Entering '||l_proc,10);
    --
    FOR l_rec IN c_restore_epo(p_per_in_ler_id) LOOP
      --
      l_effective_date := l_rec.effective_start_date;
      --
      open c_epo(l_rec.BKUP_TBL_ID,l_effective_date);
      fetch c_epo INTO l_rec.object_version_number;
      IF c_epo%FOUND THEN
      --
      --Get the Datetrack Mode
      dt_api.find_dt_upd_modes
        (p_effective_date       => l_effective_date,
         p_base_table_name      => 'BEN_ELIG_PER_OPT_F',
         p_base_key_column      => 'elig_per_opt_id',
         p_base_key_value       => l_rec.BKUP_TBL_ID,
         p_correction           => l_correction,
         p_update               => l_update,
         p_update_override      => l_update_override,
         p_update_change_insert => l_update_change_insert);
      --
      if l_update_override then
        --
        l_datetrack_mode := hr_api.g_update_override;
        --
      elsif l_update then
        --
        l_datetrack_mode := hr_api.g_update;
        --
      else
        --
        l_datetrack_mode := hr_api.g_correction;
        --
      end if;
      --
      ben_Eligible_Person_perf_api.update_perf_Elig_Person_Option
        (p_validate                     => FALSE,
         p_elig_per_opt_id              => l_rec.BKUP_TBL_ID,
         p_elig_per_id                  => l_rec.elig_per_id,
         p_effective_start_date         => l_rec.effective_start_date,
         p_effective_end_date           => l_rec.effective_end_date,
         p_per_in_ler_id                => l_rec.per_in_ler_id,
         p_elig_flag                    => l_rec.elig_flag,
         p_prtn_strt_dt                 => l_rec.prtn_strt_dt,
         p_prtn_end_dt                  => l_rec.prtn_end_dt,
         p_prtn_ovridn_flag             => l_rec.prtn_ovridn_flag,
         p_prtn_ovridn_thru_dt          => l_rec.prtn_ovridn_thru_dt,
         p_rt_comp_ref_amt              => l_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => l_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => l_rec.rt_comp_ref_uom,
         p_rt_age_val                   => l_rec.rt_age_val,
         p_rt_los_val                   => l_rec.rt_los_val,
         p_rt_hrs_wkd_val               => l_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => l_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => l_rec.rt_age_uom,
         p_rt_los_uom                   => l_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => l_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => l_rec.rt_frz_los_flag, -- 'N',
         p_rt_frz_age_flag              => l_rec.rt_frz_age_flag, -- 'N',
         p_rt_frz_cmp_lvl_flag          => l_rec.rt_frz_cmp_lvl_flag, -- 'N',
         p_rt_frz_pct_fl_tm_flag        => l_rec.rt_frz_pct_fl_tm_flag, -- 'N',
         p_rt_frz_hrs_wkd_flag          => l_rec.rt_frz_hrs_wkd_flag, -- 'N',
         p_rt_frz_comb_age_and_los_flag => l_rec.rt_frz_comb_age_and_los_flag, -- 'N',
         p_once_r_cntug_cd              => l_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => l_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => l_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => l_rec.comp_ref_uom,
         p_age_val                      => l_rec.age_val,
         p_los_val                      => l_rec.los_val,
         p_hrs_wkd_val                  => l_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => l_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => l_rec.age_uom,
         p_los_uom                      => l_rec.los_uom,
         p_pct_fl_tm_val                => l_rec.pct_fl_tm_val,
         p_frz_los_flag                 => l_rec.frz_los_flag, -- 'N',
         p_frz_age_flag                 => l_rec.frz_age_flag, -- 'N',
         p_frz_cmp_lvl_flag             => l_rec.frz_cmp_lvl_flag, -- 'N',
         p_frz_pct_fl_tm_flag           => l_rec.frz_pct_fl_tm_flag, -- 'N',
         p_frz_hrs_wkd_flag             => l_rec.frz_hrs_wkd_flag, -- 'N',
         p_frz_comb_age_and_los_flag    => l_rec.frz_comb_age_and_los_flag, -- 'N',
      --   p_wait_perd_cmpltn_dt          => l_rec.wait_perd_cmpltn_dt,
      --   p_wait_perd_strt_dt            => l_rec.wait_perd_strt_dt,
         --
         p_effective_date               => l_effective_date,
         p_object_version_number        => l_rec.object_version_number,
         p_datetrack_mode               => l_datetrack_mode,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate);
      ELSE
        NULL;
        --Do we need to Create one ?
        --
      END IF;
      --
      close c_epo;
      --
    END LOOP;
    --
    --
    --Now Delete the records from ben_le_clsn_n_rstr
    --
    delete from ben_le_clsn_n_rstr elig
          where elig.per_in_ler_ended_id = p_per_in_ler_id
            and elig.BKUP_TBL_TYP_CD = 'BEN_ELIG_PER_OPT_F_CORRECT';
    --
    hr_utility.set_location ('Leaving '||l_proc,10);
    --
END  restore_prev_epo ;
--
-- This procedure is the main call that does the calls to back out the
-- neccessary information due to a life event being removed.
--
procedure back_out_life_events
  (p_per_in_ler_id         in number,
   p_bckt_per_in_ler_id    in number ,
   p_bckt_stat_cd          in varchar2 ,
   p_business_group_id     in number,
   p_bckdt_prtt_enrt_rslt_id in number default null,
   p_copy_only              in varchar2  default null,
   p_effective_date        in date
   ) is
   ---- two plan 2982606 column added
   cursor c_pil_stat is
    select pil.per_in_ler_stat_cd,
           pil.object_version_number,
           pil.ptnl_ler_for_per_id,
           pil.person_id,
           pil.lf_evt_ocrd_dt,
           pil.ler_id
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id;



  cursor c_get_all_per_in_ler is
    select *
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id and
           pil.business_group_id=p_business_group_id
    ;

  cursor c_get_ler_info(v_ler_id number) is
    select ler.typ_cd
    from   ben_ler_f ler
    where  ler.ler_id = v_ler_id
   /* and    ler.business_group_id = p_business_group_id*/ -- CWBGLOBAL
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date;
--
  cursor c_ler_typ is
    select ler.typ_cd
    from   ben_ler_f ler,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    ler.ler_id = pil.ler_id
    /*and    ler.business_group_id = p_business_group_id*/ --CWBGLOBAL
    and    pil.lf_evt_ocrd_Dt between
           ler.effective_start_date and ler.effective_end_date;

  --
  -- CWB Bug 2712602
  --
  cursor c_pel is
    select pil_elctbl_chc_popl_id
          from ben_pil_elctbl_chc_popl
          where per_in_ler_id =  p_per_in_ler_id;
  --
  l_pil_elctbl_chc_popl_id number;

  --
  -- 2982606
  cursor c_prev_pil_id (p_person_id  number, p_lf_evt_ocrd_dt date) is
  select per_in_ler_id ,
         lf_evt_ocrd_dt
    from ben_per_in_ler
   where per_in_ler_id <> p_per_in_ler_id
     and per_in_ler_stat_cd = 'PROCD'
     and person_id          =  p_person_id
     and lf_evt_ocrd_dt    <= p_lf_evt_ocrd_dt
     order by lf_evt_ocrd_dt desc ;
  --
   cursor c_prv_rslt_lvl_bckdt( p_pil_id number,
                               p_lf_evt_ocrd_dt date) is
   select effective_start_date
     from  ben_le_clsn_n_rstr  pen
    where  per_in_ler_id = p_pil_id
      AND  pen.business_group_id = p_business_group_id
      AND  pen.prtt_enrt_rslt_stat_cd IS NULL
      AND  pen.effective_end_date = hr_api.g_eot
      AND  pen.enrt_cvg_strt_dt > p_lf_evt_ocrd_dt
      AND  pen.enrt_cvg_strt_dt < pen.effective_end_date;

 /* Added for Bug 8604243 */

 cursor c_chk_enrt_prev_le(c_per_in_ler_id number) is
 select 'Y' from ben_prtt_enrt_rslt_f pen
 where prtt_enrt_rslt_stat_cd is null
       and per_in_ler_id = c_per_in_ler_id
       and enrt_cvg_strt_dt < enrt_cvg_thru_dt;

 cursor c_prv_pil(p_person_id  number, p_lf_evt_ocrd_dt date) is
  select per_in_ler_id ,
         lf_evt_ocrd_dt
    from ben_per_in_ler pil,
          ben_ler_f ler
   where per_in_ler_id <> p_per_in_ler_id
     and per_in_ler_stat_cd = 'PROCD'
     and person_id          =  p_person_id
     and lf_evt_ocrd_dt    <= p_lf_evt_ocrd_dt
     and pil.ler_id = ler.ler_id
     and p_effective_date between
           ler.effective_start_date and ler.effective_end_date
     and  ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
     and exists
          (select 'Y' from ben_prtt_enrt_rslt_f pen
            where pen.per_in_ler_id = pil.per_in_ler_id
            and pen.prtt_enrt_rslt_stat_cd is null
            and pen.enrt_cvg_strt_dt < pen.enrt_cvg_thru_dt)
     order by lf_evt_ocrd_dt desc ;

  l_exists_flag varchar2(1) default 'N';
  l_new_prev_pil number;
  l_new_date date;

  /* End of Bug 8604243 */


 -- added here bug 7039025

      cursor c_prior_to_prv_rslt_lvl_bckdt( p_pil_id number,
                               p_lf_evt_ocrd_dt date) is
   select leclr.*
     from  ben_le_clsn_n_rstr  leclr,
           ben_prtt_enrt_rslt_f pen
    where  leclr.per_in_ler_id <> p_pil_id
      AND  leclr.business_group_id = p_business_group_id
      AND  leclr.prtt_enrt_rslt_stat_cd IS NULL
      AND  leclr.effective_end_date = hr_api.g_eot
      AND  leclr.enrt_cvg_strt_dt > p_lf_evt_ocrd_dt
      AND  leclr.enrt_cvg_strt_dt < leclr.effective_end_date
      AND  leclr.bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_RSLT_F'
      AND  leclr.bkup_tbl_id = pen.prtt_enrt_rslt_id
      AND  pen.per_in_ler_id = p_per_in_ler_id
      AND  pen.prtt_enrt_rslt_stat_cd = 'BCKDT'
      AND  pen.effective_end_date = hr_api.g_eot
      AND  pen.enrt_cvg_strt_dt > p_lf_evt_ocrd_dt
      AND  pen.enrt_cvg_strt_dt < pen.effective_end_date;

     --
     -- added till here bug 7039025


  --  2982606
  cursor c_chr is
    select rowid
        from ben_cwb_hrchy
        where mgr_pil_elctbl_chc_popl_id = l_pil_elctbl_chc_popl_id;
  --
  l_pil_stat c_pil_stat%rowtype;
  l_per_in_ler c_get_all_per_in_ler%rowtype;
  l_ler_info  c_get_ler_info%rowtype;
  l_date      date;
  l_ler_typ   varchar2(200);
  l_package   varchar2(80) := g_package||'.back_out_life_events';
  -- 2982606
  l_prv_per_in_ler_id  number ;
  l_prv_lf_evt_ocrd_dt       date ;
  l_prv_effective_start_date date ;
  l_dummy              varchar2(1) ;

  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  -- unrestricted life event not to be backed out
  open  c_ler_typ;
  fetch c_ler_typ into l_ler_typ;
  close c_ler_typ;
  if l_ler_typ = 'SCHEDDU' then
    -- do nothing
    return;
  end if;


  -- There are a series of deleting steps and these muse be done in
  -- order as otherwise we will get foreign key issues and the like.
  --
  -- Tables that will be deleted from include and must be deleted from in
  -- a bottom to top fashion :
  --
  -- BEN_PER_IN_LER (PIL)
  -- BEN_PRTT_ENRT_RSLT_F (PEN)
  -- BEN_PL_BNF_F (PBN) (join to pil to check status)
  -- BEN_PRTT_ENRT_ACTN_F (PEA) (join to pil to check status)
  -- BEN_BNFT_PRVDD_LDGR_F (BPL)(join to pil to check status)
  -- BEN_PRTT_RT_VAL (PRV)
  -- BEN_PRTT_REIMBMT_RQST_F
  -- BEN_PL_BNF_CTFN_PRVDD_F (PBC)(join to pil to check status)
  -- BEN_PRTT_ENRT_CTFN_PRVDD_F (PCS)(join to pil to check status)
  -- BEN_ELIG_PER_ELCTBL_CHC (EPE) (not deleted, join to pil to check status)
     -- BEN_ENRT_BNFT (ENB)          (cascade delete in epe api, but epe not deleted)
     -- BEN_ENRT_RT (ECR)            (cascade delete in epe api, but epe not deleted)
     -- BEN_ENRT_CVG_N_RT_CTFN (ECC) (cascade delete in epe api, but epe not deleted)
  -- BEN_ELIG_CVRD_DPNT_F (PDP)
  -- BEN_ELIG_PER_F (PEP)
  -- BEN_ELIG_PER_OPT_F (EPO)
  -- BEN_CVRD_DPNT_CTFN_PRVDD_F (CCP)
  -- BEN_PER_CM_F (PCM) (join to pil to check status)
     -- BEN_PER_CM_USG_F (PCU) (join to pil to check status)
     -- BEN_PER_CM_TRGR_F (PCR) (join to pil to check status)
     -- BEN_PER_CM_PRVDD_F (PCD) (join to pil to check status)
  -- PAY_ELEMENT_ENTRIES_F (PEE)
  -- PAY_ELEMENT_ENTRY_VALUES_F (PEV)
  -- BEN_PRTT_PREM_F (PPE)
  -- BEN_CBR_QUALD_BNF (CQB) - (not deleted, if it is the initial qualifying event, join
  --                            to pil to check status. If it is not the initial
  --                            qualifying event, restore the prior eligibility end date.)
  -- BEN_CBR_PER_IN_LER (CRP) - (not deleted, join to pil to check status).
  --
  --                     PIL
  --                      |
  --    ---------------------------------
  --    |                               |
  --    |                              PEN
  --    |                               |
  --    |--------------------------------------------------------------
  --    | |  |      |                   |         |       |     |     |
  --    | | PRV    PBN                 PEA        |      PEE   PPE    |
  --    | |  |      |                   |         |                   |
  --    | |  |      | --------------------------- |                   |
  --    | |  |      | |                 |       | |                   |
  --    | |  |      PBC                 |       PCS                   |
  --    | |  |                          |                             |
  --    EPE  |                          |                             |
  --     |   |                          |                             |
  --   ---------------------------------------------------------------|
  --   |  |  |                          |                             |
  -- ENB  |  |                          |---------------------------- PDP
  --   |  |  |                                                      | |
  --  --- | /                                                       CCP
  --  | | |/
  --  | ECR
  --  | |
  --  ECC
  --
  --
  --
  --
  -- first check that per in ler is not already backed out.
  --

  open c_pil_stat;
  fetch c_pil_stat into l_pil_stat;
  close c_pil_stat;
  --
  if l_pil_stat.per_in_ler_stat_cd <> 'BCKDT' then


      -- 2982606 if any results backed out  restore the  results
      open c_prev_pil_id (l_pil_stat.person_id , l_pil_stat.lf_evt_ocrd_dt)  ;
      fetch c_prev_pil_id into l_prv_per_in_ler_id,l_prv_lf_evt_ocrd_dt ;
      close c_prev_pil_id ;

        hr_utility.set_location ('prv_per_in_ler_id' || l_prv_per_in_ler_id, 99 );
        hr_utility.set_location ('l_lf_evt_ocrd_dt'  || l_prv_lf_evt_ocrd_dt, 99 );
     -- First back out contact persons per in ler's
     -- if they are created by the per in ler which is
     -- # 2982606 Total of Two Plan Resulkt level backedout introduced
     if  p_bckdt_prtt_enrt_rslt_id is null then
         -- 3136058
        -- Dont backout in case ler is of type grade step.
        if l_ler_typ not in ('GSP','IREC', 'COMP', 'ABS') then
           p_backout_contact_pils(p_person_id         => l_pil_stat.person_id
                              ,p_business_group_id => p_business_group_id
                              ,p_per_in_ler_id     => p_per_in_ler_id
                              ,p_bckt_stat_cd      => p_bckt_stat_cd
                              ,p_csd_by_ptnl_ler_for_per_id => l_pil_stat.ptnl_ler_for_per_id
                              ,p_effective_date    => p_effective_date);
        end if;
     end if ;
     --
     -- un-end dependents that have been ended.  Leave other dependents
     -- alone, they will be ignored if their per-in-ler is 'backed out'
     -- g_backout_flag is assigned value to bypass suspend enrollment
     g_backout_flag  := 'Y';
     --
     --CWBGLOBAL : No need to backout in case of CWB backout
     if l_ler_typ not in ('GSP', 'COMP') then
       -- CFW
       IF fnd_global.conc_request_id = -1 THEN
         --
         ben_env_object.init(p_business_group_id  => p_business_group_id,
                             p_effective_date     => p_effective_date,
                             p_thread_id          => 1,
                             p_chunk_size         => 1,
                             p_threads            => 1,
                             p_max_errors         => 1,
                             p_benefit_action_id  => NULL);
         --
       END IF ;
       -- CFW
       delete_routine(p_routine           => 'BEN_ELIG_CVRD_DPNT_F',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_bckdt_prtt_enrt_rslt_id => p_bckdt_prtt_enrt_rslt_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);

       --  (404) Until we recognize that pcp's aren't valid if their per-in-ler isn't
       -- we need to still delete them.  Need to change views?  or add per in ler id.
       hr_utility.set_location('Effective Date'||p_effective_date,10);

       delete_routine(p_routine           => 'BEN_PRMRY_CARE_PRVDR_F',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_bckdt_prtt_enrt_rslt_id => p_bckdt_prtt_enrt_rslt_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);

        -- un-end beneficiaries that have been ended.  Leave other beneficiaries
        -- alone, they will be ignored if their per-in-ler is 'backed out'
        delete_routine(p_routine           => 'BEN_PL_BNF_F',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_bckdt_prtt_enrt_rslt_id => p_bckdt_prtt_enrt_rslt_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);



        delete_routine(p_routine          => 'BEN_PRTT_REIMBMT_RQST',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_bckdt_prtt_enrt_rslt_id => p_bckdt_prtt_enrt_rslt_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);

        -- delete credit ledger rows
        delete_routine(p_routine           => 'BEN_BNFT_PRVDD_LDGR_F',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_bckdt_prtt_enrt_rslt_id => p_bckdt_prtt_enrt_rslt_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);

        hr_utility.set_location('BEN_PRTT_RT_VAL p_effective_date'||p_effective_date,1999);
        -- mark rates 'backed out'
        delete_routine(p_routine           => 'BEN_PRTT_RT_VAL',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_bckdt_prtt_enrt_rslt_id => p_bckdt_prtt_enrt_rslt_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);

       -- mark prtt_prem's 'backed out'
       delete_routine(p_routine           => 'BEN_PRTT_PREM_F',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_bckdt_prtt_enrt_rslt_id => p_bckdt_prtt_enrt_rslt_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);

       -- mark results 'backed out'
       delete_routine(p_routine           => 'BEN_PRTT_ENRT_RSLT_F',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_bckdt_prtt_enrt_rslt_id => p_bckdt_prtt_enrt_rslt_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);
     end if;

     if  p_bckdt_prtt_enrt_rslt_id is null then
         -- mark pil popl's 'backed out'
         delete_routine(p_routine           => 'BEN_PIL_ELCTBL_CHC_POPL',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);

         --CWBGLOBAL : No need to backout in case of CWB backout
         if l_ler_typ not in ('COMP') then
         -- mark elig_per opts's 'backed out'
         delete_routine(p_routine           => 'BEN_ELIG_PER_OPT_F',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);

         -- mark elig_per's 'backed out'
         delete_routine(p_routine           => 'BEN_ELIG_PER_F',
                 p_per_in_ler_id     => p_per_in_ler_id,
                 p_business_group_id => p_business_group_id,
                 p_copy_only         =>  p_copy_only,
                 p_effective_date    => p_effective_date);
         end if;
         --
         if l_ler_typ not in ('GSP', 'ABS', 'IREC', 'COMP') then
            --
            -- If applicable, update the eligibility end date to the eligibility
            -- end date of the prior event.
            --
            delete_routine(p_routine           => 'BEN_CBR_QUALD_BNF',
                    p_per_in_ler_id     => p_per_in_ler_id,
                    p_business_group_id => p_business_group_id,
                    p_copy_only         =>  p_copy_only,
                    p_effective_date    => p_effective_date);

         end if;



         -- update ptnl to unprocessed, when the ler is not unrestricted.
            --
            open c_get_all_per_in_ler;
            fetch c_get_all_per_in_ler into l_per_in_ler;
            close c_get_all_per_in_ler;
           --
            open  c_get_ler_info(l_per_in_ler.ler_id);
            fetch c_get_ler_info into l_ler_info;
            close c_get_ler_info;
            --
            if l_ler_info.typ_cd =  'SCHEDDU' then
               --
               -- Unrestricted ler, so nothing needs to be done.
               --
               null;
               --
            else
               --
               -- Update ptnl as unprocessed.
               --
               unprocess_ptnl_ler
                 (p_per_in_ler     => l_per_in_ler
                 ,p_bckt_stat_cd   => p_bckt_stat_cd
                 ,p_effective_date => p_effective_date);
               --
            end if;

         -- 3136058
         -- In case ler is of type grade step, mark it as voided, else backed out  -- Added IREC
         if l_ler_typ in ( 'GSP', 'IREC')  then
            ben_Person_Life_Event_api.update_person_life_event
              (p_per_in_ler_id         => p_per_in_ler_id
              ,p_bckt_per_in_ler_id    => p_bckt_per_in_ler_id
              ,p_per_in_ler_stat_cd    => 'VOIDD'
              ,p_prvs_stat_cd          => l_pil_stat.per_in_ler_stat_cd
              ,p_object_version_number => l_pil_stat.object_version_number
              ,p_effective_date        => p_effective_date
              ,P_PROCD_DT              => l_date  -- outputs
              ,P_STRTD_DT              => l_date
              ,P_VOIDD_DT              => l_date  );

         else
            --
            -- Finally, mark the per-in-ler as backed out.
            ben_Person_Life_Event_api.update_person_life_event
              (p_per_in_ler_id         => p_per_in_ler_id
              ,p_bckt_per_in_ler_id    => p_bckt_per_in_ler_id
              ,p_per_in_ler_stat_cd    => 'BCKDT'
              ,p_prvs_stat_cd          => l_pil_stat.per_in_ler_stat_cd
              ,p_object_version_number => l_pil_stat.object_version_number
              ,p_effective_date        => p_effective_date
              ,P_PROCD_DT              => l_date  -- outputs
              ,P_STRTD_DT              => l_date
              ,P_VOIDD_DT              => l_date  );
         end if;
        --

        -- Bug 2526994 This needs to be reset once the process is done.
        g_backout_flag  := null ;

        /*
        -- 2982606 if any results backed out  restore the  results
        open c_prev_pil_id (l_pil_stat.person_id , l_pil_stat.lf_evt_ocrd_dt)  ;
        fetch c_prev_pil_id into l_prv_per_in_ler_id,l_prv_lf_evt_ocrd_dt ;
        close c_prev_pil_id ;
        */

        hr_utility.set_location ('prv_per_in_ler_id' || l_prv_per_in_ler_id, 199 );
        hr_utility.set_location ('l_lf_evt_ocrd_dt'  || l_prv_lf_evt_ocrd_dt, 199 );
        --
        --IK START
        -- Get all the BEN_ELIG_PER_F_CORRECTION and BEN_ELIG_PER_OPT_F_CORRECTION
        -- records from BEN_LE_CLSN_N_RSTR table for the per_in_ler being backed out
        -- and update the records with PEP and EPO records with the restored date
        -- in correction mode.
        -- After API call to Corrrect the PEP and EPO records delete the data from
        -- Collapse and restore table.
        IF p_per_in_ler_id IS NOT NULL  and l_ler_typ not in ('COMP', 'ABS', 'GSP', 'IREC') THEN
          --
          restore_prev_pep(p_per_in_ler_id);
          restore_prev_epo(p_per_in_ler_id);
          --
        END IF;
        --IK END
        if l_prv_per_in_ler_id is not null
           and l_ler_typ not in ('COMP', 'ABS', 'GSP', 'IREC')
        then
           -- Look if there is any backedout result for the future dated coverage

	      /*Bug 8604243: Added 'if' condition. While backing out a LE,if previous LE does not have
              electability and no enrollments results then previous per_in_ler_id should be
	      of the LE for which enrollment results are ended. Check if enrollments results exists for previous LE
	      (Cursor c_chk_enrt_prev_le). If enrollment results does not exist the get the per_in_ler_id of the LE
              for which enrollment results are ended (Cursor c_prv_pil);
	      */

           /* Commented below code for Bug 8604243*/
	   /*open c_prv_rslt_lvl_bckdt(l_prv_per_in_ler_id,l_prv_lf_evt_ocrd_dt );
           fetch c_prv_rslt_lvl_bckdt into l_prv_effective_start_date ;
           close c_prv_rslt_lvl_bckdt ;*/


	   g_no_reopen_flag := 'N';
	   open c_chk_enrt_prev_le(l_prv_per_in_ler_id);
	   fetch c_chk_enrt_prev_le into l_exists_flag;
	   if(c_chk_enrt_prev_le%notfound) then
	      l_new_prev_pil := l_prv_per_in_ler_id;
	      l_new_date := l_prv_lf_evt_ocrd_dt;

	      open c_prv_pil(l_pil_stat.person_id , l_pil_stat.lf_evt_ocrd_dt);
	      fetch c_prv_pil into l_prv_per_in_ler_id,l_prv_lf_evt_ocrd_dt;
	      close c_prv_pil;

	       -- Look if there is any backedout result for the future dated coverage
	       open c_prv_rslt_lvl_bckdt(l_prv_per_in_ler_id,l_prv_lf_evt_ocrd_dt );
	       fetch c_prv_rslt_lvl_bckdt into l_prv_effective_start_date ;
	       close c_prv_rslt_lvl_bckdt ;
	       hr_utility.set_location ('l_prv_effective_start_date'  || l_prv_effective_start_date, 99 );
	       g_no_reopen_flag := 'Y';
	    else
               open c_prv_rslt_lvl_bckdt(l_prv_per_in_ler_id,l_prv_lf_evt_ocrd_dt );
               fetch c_prv_rslt_lvl_bckdt into l_prv_effective_start_date ;
               close c_prv_rslt_lvl_bckdt ;
	       hr_utility.set_location ('l_prv_effective_start_date'  || l_prv_effective_start_date, 199 );
	    end if;
	   close c_chk_enrt_prev_le;
	   /* Ended for Bug 8604243*/

           hr_utility.set_location ('l_prv_eff dt'  || l_prv_effective_start_date, 99 );
           hr_utility.set_location ('l_prv_per_in_ler_id'  || l_prv_per_in_ler_id, 99 );

           if l_prv_effective_start_date is not null then
              hr_utility.set_location ('status to started' , 99 );

	       -- added here bug 7039025
	   For l_prior_to_prv_rslt_lvl_bckdt in c_prior_to_prv_rslt_lvl_bckdt(l_prv_per_in_ler_id,l_prv_lf_evt_ocrd_dt)
	   loop
	   --
           hr_utility.set_location ('prior to prev life event found in bkup table',44333);
           --
	   -- Insert a correction row before updation as if, the enrollments were corrected by the next pil.
           INSERT INTO ben_le_clsn_n_rstr
		(COMP_LVL_CD,
		DSPLY_ON_ENRT_FLAG,
		RT_OVRIDN_FLAG,
		ACTY_REF_PERD_CD,
		ACTY_TYP_CD,
		ANN_RT_VAL,
		BNFT_RT_TYP_CD,
		CMCD_REF_PERD_CD,
		CMCD_RT_VAL,
		ELCNS_MADE_DT,
		MLT_CD,
		PRTT_RT_VAL_STAT_CD,
		RT_OVRIDN_THRU_DT,
		RT_VAL,
		TX_TYP_CD,
		INELG_RSN_CD,
		RT_COMP_REF_AMT,
		RT_CMBN_AGE_N_LOS_VAL,
		RT_COMP_REF_UOM,
		RT_AGE_VAL,
		RT_LOS_VAL,
		RT_HRS_WKD_VAL,
		RT_HRS_WKD_BNDRY_PERD_CD,
		RT_AGE_UOM,
		RT_LOS_UOM,
		RT_PCT_FL_TM_VAL,
		RT_FRZ_LOS_FLAG,
		RT_FRZ_AGE_FLAG,
		RT_FRZ_CMP_LVL_FLAG,
		RT_FRZ_PCT_FL_TM_FLAG,
		RT_FRZ_HRS_WKD_FLAG,
		RT_FRZ_COMB_AGE_AND_LOS_FLAG,
		AGE_UOM,
		AGE_VAL,
		CMBN_AGE_N_LOS_VAL,
		COMP_REF_AMT,
		COMP_REF_UOM,
		DPNT_OTHER_PL_CVRD_RL_FLAG,
		DSTR_RSTCN_FLAG,
		FRZ_AGE_FLAG,
		FRZ_CMP_LVL_FLAG,
		FRZ_COMB_AGE_AND_LOS_FLAG,
		FRZ_HRS_WKD_FLAG,
		FRZ_LOS_FLAG,
		FRZ_PCT_FL_TM_FLAG,
		HRS_WKD_BNDRY_PERD_CD,
		HRS_WKD_VAL,
		LOS_UOM,
		LOS_VAL,
		NO_MX_PRTN_OVRID_THRU_FLAG,
		OVRID_SVC_DT,
		PCT_FL_TM_VAL,
		PL_HGHLY_COMPD_FLAG,
		PL_KEY_EE_FLAG,
		PL_WVD_FLAG,
		PRTN_END_DT,
		PRTN_OVRIDN_FLAG,
		PRTN_OVRIDN_RSN_CD,
		PRTN_OVRIDN_THRU_DT,
		PRTN_STRT_DT,
		WAIT_PERD_CMPLTN_DT,
		WV_CTFN_TYP_CD,
		WV_PRTN_RSN_CD,
		PERSON_ID,
		PL_ID,
		LER_ID,
		PTIP_ID,
		PLIP_ID,
		OTHR_PL_ENRLD_ID,
		PGM_ID,
		ELIG_PER_ID,
		OPT_ID,
		ORGANIZATION_ID,
		PRTT_ENRT_RSLT_ID,
		PERSON_TTEE_ID,
		ELIG_PER_ELCTBL_CHC_ID,
		PERSON_DPNT_ID,
		ELEMENT_ENTRY_VALUE_ID,
		PER_IN_LER_ENDED_ID,
		CVG_AMT_CALC_MTHD_ID,
		ENRT_RT_ID,
		ACTY_BASE_RT_ID,
		OIPL_ID,
		COMP_LVL_FCTR_ID,
		PL_TYP_ID,
		ACTL_PREM_ID,
		PRTT_ENRT_RSLT_SSPNDD_ID,
		ASSIGNMENT_ID,
		ENRT_BNFT_ID,
		BUSINESS_GROUP_ID,
		LCR_ATTRIBUTE_CATEGORY,
		LCR_ATTRIBUTE1,
		LCR_ATTRIBUTE2,
		LCR_ATTRIBUTE3,
		LCR_ATTRIBUTE4,
		LCR_ATTRIBUTE5,
		LCR_ATTRIBUTE6,
		LCR_ATTRIBUTE7,
		LCR_ATTRIBUTE8,
		LCR_ATTRIBUTE9,
		LCR_ATTRIBUTE10,
		LCR_ATTRIBUTE11,
		LCR_ATTRIBUTE12,
		LCR_ATTRIBUTE13,
		LCR_ATTRIBUTE14,
		LCR_ATTRIBUTE15,
		LCR_ATTRIBUTE16,
		LCR_ATTRIBUTE17,
		LCR_ATTRIBUTE18,
		LCR_ATTRIBUTE19,
		LCR_ATTRIBUTE20,
		LCR_ATTRIBUTE21,
		LCR_ATTRIBUTE22,
		LCR_ATTRIBUTE23,
		LCR_ATTRIBUTE24,
		LCR_ATTRIBUTE25,
		LCR_ATTRIBUTE26,
		LCR_ATTRIBUTE27,
		LCR_ATTRIBUTE28,
		LCR_ATTRIBUTE29,
		BKUP_TBL_ID,
		BKUP_TBL_TYP_CD,
		PER_IN_LER_ID,
		EFFECTIVE_START_DATE,
		EFFECTIVE_END_DATE,
		ENRT_CVG_STRT_DT,
		ENRT_CVG_THRU_DT,
		BNFT_AMT,
		BNFT_NNMNTRY_UOM,
		BNFT_ORDR_NUM,
		BNFT_TYP_CD,
		ENRT_MTHD_CD,
		ENRT_OVRID_RSN_CD,
		ENRT_OVRID_THRU_DT,
		ENRT_OVRIDN_FLAG,
		ERLST_DEENRT_DT,
		NO_LNGR_ELIG_FLAG,
		ORGNL_ENRT_DT,
		PRTT_ENRT_RSLT_STAT_CD,
		PRTT_IS_CVRD_FLAG,
		SSPNDD_FLAG,
		UOM,
		ADDL_INSTRN_TXT,
		AMT_DSGD_VAL,
		AMT_DSGD_UOM,
		DSGN_STRT_DT,
		DSGN_THRU_DT,
		PCT_DSGD_NUM,
		PRMRY_CNTNGNT_CD,
		CVG_PNDG_FLAG,
		CVRD_FLAG,
		ELIG_FLAG,
		OVRDN_FLAG,
		CVG_STRT_DT,
		CVG_THRU_DT,
		ELIG_STRT_DT,
		ELIG_THRU_DT,
		OVRDN_THRU_DT,
		RT_STRT_DT,
		RT_END_DT,
		LCR_ATTRIBUTE30,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATION_DATE,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		OBJECT_VERSION_NUMBER,
		TTEE_PERSON_ID,
		DPNT_PERSON_ID,
		ONCE_R_CNTUG_CD,
		DPNT_OTHR_PL_CVRD_RL_FLAG,
		MUST_ENRL_ANTHR_PL_ID,
		PL_ORDR_NUM,
		PLIP_ORDR_NUM,
		PTIP_ORDR_NUM,
		OIPL_ORDR_NUM,
		BNF_PERSON_ID,
		RPLCS_SSPNDD_RSLT_ID,
		VAL,
		STD_PREM_VAL,
		STD_PREM_UOM)
	VALUES
	       (l_prior_to_prv_rslt_lvl_bckdt.COMP_LVL_CD,
		l_prior_to_prv_rslt_lvl_bckdt.DSPLY_ON_ENRT_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.RT_OVRIDN_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.ACTY_REF_PERD_CD,
		l_prior_to_prv_rslt_lvl_bckdt.ACTY_TYP_CD,
		l_prior_to_prv_rslt_lvl_bckdt.ANN_RT_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.BNFT_RT_TYP_CD,
		l_prior_to_prv_rslt_lvl_bckdt.CMCD_REF_PERD_CD,
		l_prior_to_prv_rslt_lvl_bckdt.CMCD_RT_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.ELCNS_MADE_DT,
		l_prior_to_prv_rslt_lvl_bckdt.MLT_CD,
		l_prior_to_prv_rslt_lvl_bckdt.PRTT_RT_VAL_STAT_CD,
		l_prior_to_prv_rslt_lvl_bckdt.RT_OVRIDN_THRU_DT,
		l_prior_to_prv_rslt_lvl_bckdt.RT_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.TX_TYP_CD,
		l_prior_to_prv_rslt_lvl_bckdt.INELG_RSN_CD,
		l_prior_to_prv_rslt_lvl_bckdt.RT_COMP_REF_AMT,
		l_prior_to_prv_rslt_lvl_bckdt.RT_CMBN_AGE_N_LOS_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.RT_COMP_REF_UOM,
		l_prior_to_prv_rslt_lvl_bckdt.RT_AGE_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.RT_LOS_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.RT_HRS_WKD_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.RT_HRS_WKD_BNDRY_PERD_CD,
		l_prior_to_prv_rslt_lvl_bckdt.RT_AGE_UOM,
		l_prior_to_prv_rslt_lvl_bckdt.RT_LOS_UOM,
		l_prior_to_prv_rslt_lvl_bckdt.RT_PCT_FL_TM_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.RT_FRZ_LOS_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.RT_FRZ_AGE_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.RT_FRZ_CMP_LVL_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.RT_FRZ_PCT_FL_TM_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.RT_FRZ_HRS_WKD_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.RT_FRZ_COMB_AGE_AND_LOS_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.AGE_UOM,
		l_prior_to_prv_rslt_lvl_bckdt.AGE_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.CMBN_AGE_N_LOS_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.COMP_REF_AMT,
		l_prior_to_prv_rslt_lvl_bckdt.COMP_REF_UOM,
		l_prior_to_prv_rslt_lvl_bckdt.DPNT_OTHER_PL_CVRD_RL_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.DSTR_RSTCN_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.FRZ_AGE_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.FRZ_CMP_LVL_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.FRZ_COMB_AGE_AND_LOS_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.FRZ_HRS_WKD_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.FRZ_LOS_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.FRZ_PCT_FL_TM_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.HRS_WKD_BNDRY_PERD_CD,
		l_prior_to_prv_rslt_lvl_bckdt.HRS_WKD_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.LOS_UOM,
		l_prior_to_prv_rslt_lvl_bckdt.LOS_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.NO_MX_PRTN_OVRID_THRU_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.OVRID_SVC_DT,
		l_prior_to_prv_rslt_lvl_bckdt.PCT_FL_TM_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.PL_HGHLY_COMPD_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.PL_KEY_EE_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.PL_WVD_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.PRTN_END_DT,
		l_prior_to_prv_rslt_lvl_bckdt.PRTN_OVRIDN_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.PRTN_OVRIDN_RSN_CD,
		l_prior_to_prv_rslt_lvl_bckdt.PRTN_OVRIDN_THRU_DT,
		l_prior_to_prv_rslt_lvl_bckdt.PRTN_STRT_DT,
		l_prior_to_prv_rslt_lvl_bckdt.WAIT_PERD_CMPLTN_DT,
		l_prior_to_prv_rslt_lvl_bckdt.WV_CTFN_TYP_CD,
		l_prior_to_prv_rslt_lvl_bckdt.WV_PRTN_RSN_CD,
		l_prior_to_prv_rslt_lvl_bckdt.PERSON_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PL_ID,
		l_prior_to_prv_rslt_lvl_bckdt.LER_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PTIP_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PLIP_ID,
		l_prior_to_prv_rslt_lvl_bckdt.OTHR_PL_ENRLD_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PGM_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ELIG_PER_ID,
		l_prior_to_prv_rslt_lvl_bckdt.OPT_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ORGANIZATION_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PRTT_ENRT_RSLT_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PERSON_TTEE_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ELIG_PER_ELCTBL_CHC_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PERSON_DPNT_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ELEMENT_ENTRY_VALUE_ID,
		l_prv_per_in_ler_id,
		l_prior_to_prv_rslt_lvl_bckdt.CVG_AMT_CALC_MTHD_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ENRT_RT_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ACTY_BASE_RT_ID,
		l_prior_to_prv_rslt_lvl_bckdt.OIPL_ID,
		l_prior_to_prv_rslt_lvl_bckdt.COMP_LVL_FCTR_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PL_TYP_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ACTL_PREM_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PRTT_ENRT_RSLT_SSPNDD_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ASSIGNMENT_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ENRT_BNFT_ID,
		l_prior_to_prv_rslt_lvl_bckdt.BUSINESS_GROUP_ID,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE_CATEGORY,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE1,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE2,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE3,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE4,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE5,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE6,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE7,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE8,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE9,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE10,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE11,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE12,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE13,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE14,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE15,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE16,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE17,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE18,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE19,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE20,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE21,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE22,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE23,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE24,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE25,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE26,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE27,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE28,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE29,
		l_prior_to_prv_rslt_lvl_bckdt.BKUP_TBL_ID,
		'BEN_PRTT_ENRT_RSLT_F_CORR',
		l_prior_to_prv_rslt_lvl_bckdt.PER_IN_LER_ID,
		l_prior_to_prv_rslt_lvl_bckdt.EFFECTIVE_START_DATE,
		l_prior_to_prv_rslt_lvl_bckdt.EFFECTIVE_END_DATE,
		l_prior_to_prv_rslt_lvl_bckdt.ENRT_CVG_STRT_DT,
		l_prior_to_prv_rslt_lvl_bckdt.ENRT_CVG_THRU_DT,
		l_prior_to_prv_rslt_lvl_bckdt.BNFT_AMT,
		l_prior_to_prv_rslt_lvl_bckdt.BNFT_NNMNTRY_UOM,
		l_prior_to_prv_rslt_lvl_bckdt.BNFT_ORDR_NUM,
		l_prior_to_prv_rslt_lvl_bckdt.BNFT_TYP_CD,
		l_prior_to_prv_rslt_lvl_bckdt.ENRT_MTHD_CD,
		l_prior_to_prv_rslt_lvl_bckdt.ENRT_OVRID_RSN_CD,
		l_prior_to_prv_rslt_lvl_bckdt.ENRT_OVRID_THRU_DT,
		l_prior_to_prv_rslt_lvl_bckdt.ENRT_OVRIDN_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.ERLST_DEENRT_DT,
		l_prior_to_prv_rslt_lvl_bckdt.NO_LNGR_ELIG_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.ORGNL_ENRT_DT,
		l_prior_to_prv_rslt_lvl_bckdt.PRTT_ENRT_RSLT_STAT_CD,
		l_prior_to_prv_rslt_lvl_bckdt.PRTT_IS_CVRD_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.SSPNDD_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.UOM,
		l_prior_to_prv_rslt_lvl_bckdt.ADDL_INSTRN_TXT,
		l_prior_to_prv_rslt_lvl_bckdt.AMT_DSGD_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.AMT_DSGD_UOM,
		l_prior_to_prv_rslt_lvl_bckdt.DSGN_STRT_DT,
		l_prior_to_prv_rslt_lvl_bckdt.DSGN_THRU_DT,
		l_prior_to_prv_rslt_lvl_bckdt.PCT_DSGD_NUM,
		l_prior_to_prv_rslt_lvl_bckdt.PRMRY_CNTNGNT_CD,
		l_prior_to_prv_rslt_lvl_bckdt.CVG_PNDG_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.CVRD_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.ELIG_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.OVRDN_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.CVG_STRT_DT,
		l_prior_to_prv_rslt_lvl_bckdt.CVG_THRU_DT,
		l_prior_to_prv_rslt_lvl_bckdt.ELIG_STRT_DT,
		l_prior_to_prv_rslt_lvl_bckdt.ELIG_THRU_DT,
		l_prior_to_prv_rslt_lvl_bckdt.OVRDN_THRU_DT,
		l_prior_to_prv_rslt_lvl_bckdt.RT_STRT_DT,
		l_prior_to_prv_rslt_lvl_bckdt.RT_END_DT,
		l_prior_to_prv_rslt_lvl_bckdt.LCR_ATTRIBUTE30,
		l_prior_to_prv_rslt_lvl_bckdt.LAST_UPDATE_DATE,
		l_prior_to_prv_rslt_lvl_bckdt.LAST_UPDATED_BY,
		l_prior_to_prv_rslt_lvl_bckdt.LAST_UPDATE_LOGIN,
		l_prior_to_prv_rslt_lvl_bckdt.CREATED_BY,
		l_prior_to_prv_rslt_lvl_bckdt.CREATION_DATE,
		l_prior_to_prv_rslt_lvl_bckdt.REQUEST_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PROGRAM_APPLICATION_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PROGRAM_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PROGRAM_UPDATE_DATE,
		l_prior_to_prv_rslt_lvl_bckdt.OBJECT_VERSION_NUMBER,
		l_prior_to_prv_rslt_lvl_bckdt.TTEE_PERSON_ID,
		l_prior_to_prv_rslt_lvl_bckdt.DPNT_PERSON_ID,
		l_prior_to_prv_rslt_lvl_bckdt.ONCE_R_CNTUG_CD,
		l_prior_to_prv_rslt_lvl_bckdt.DPNT_OTHR_PL_CVRD_RL_FLAG,
		l_prior_to_prv_rslt_lvl_bckdt.MUST_ENRL_ANTHR_PL_ID,
		l_prior_to_prv_rslt_lvl_bckdt.PL_ORDR_NUM,
		l_prior_to_prv_rslt_lvl_bckdt.PLIP_ORDR_NUM,
		l_prior_to_prv_rslt_lvl_bckdt.PTIP_ORDR_NUM,
		l_prior_to_prv_rslt_lvl_bckdt.OIPL_ORDR_NUM,
		l_prior_to_prv_rslt_lvl_bckdt.BNF_PERSON_ID,
		l_prior_to_prv_rslt_lvl_bckdt.RPLCS_SSPNDD_RSLT_ID,
		l_prior_to_prv_rslt_lvl_bckdt.VAL,
		l_prior_to_prv_rslt_lvl_bckdt.STD_PREM_VAL,
		l_prior_to_prv_rslt_lvl_bckdt.STD_PREM_UOM);
		--
		hr_utility.set_location('Inserted corrected Row', 44333);
		--
	   UPDATE ben_le_clsn_n_rstr
	   SET    per_in_ler_id = l_prv_per_in_ler_id
	   WHERE  per_in_ler_id = l_prior_to_prv_rslt_lvl_bckdt.per_in_ler_id
	   AND    bkup_tbl_id = l_prior_to_prv_rslt_lvl_bckdt.bkup_tbl_id
	   AND    bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_RSLT_F'
	   AND    business_group_id = p_business_group_id
	   AND    prtt_enrt_rslt_stat_cd IS NULL
	   AND    effective_end_date = hr_api.g_eot
           AND    enrt_cvg_strt_dt > l_prv_lf_evt_ocrd_dt
           AND    enrt_cvg_strt_dt <  effective_end_date;
	   --
	   hr_utility.set_location ('updated bkup table table with prev per_in_ler', 44333);
	   --

	 end loop;

	      -- added till here bug 7039025


              hr_utility.set_location ('restoring result ' , 99 );
              ben_lf_evt_clps_restore.reinstate_the_prev_enrt_rslt(
                             p_person_id           => l_pil_stat.person_id
                            ,p_business_group_id   => p_business_group_id
                            ,p_ler_id              => l_pil_stat.ler_id
                            ,p_effective_date      => l_prv_lf_evt_ocrd_dt
                            ,p_per_in_ler_id       => l_prv_per_in_ler_id
                            ,p_bckdt_per_in_ler_id => l_prv_per_in_ler_id
                           )  ;
              -- once the result level backedout data is restored
              -- delete the data from the backout table
              delete from  ben_le_clsn_n_rstr
              where  per_in_ler_id = l_prv_per_in_ler_id
              AND  business_group_id = p_business_group_id ;


              hr_utility.set_location ('status to closed' , 99 );
           end if ;
           --
           --Restore Future completed Action Items
           --
           restore_cert_completion(p_per_in_ler_id);
           --
        end if ;
        -- 2982606

      end if;  -- p_bckdt_prtt_enrt_rslt_id
      -- Bug 2526994 This needs to be reset once the process is done.
      g_backout_flag  := null ;
      --
  end if;
  hr_utility.set_location ('Leaving '||l_package,99);
  --
exception
  when others then
      --
      -- Bug 4919951 - Reset the flag if any exception raised
      --
      g_backout_flag  := null ;
      hr_utility.set_location('Flag g_backout_flag Reset', 9999);
      raise;
      --
   --
end back_out_life_events;
--
procedure unprocess_susp_enrt_past_pil(p_prtt_enrt_rslt_id in number,
                                       p_per_in_ler_id     in number,
                                       p_business_group_id in number) is
--
  cursor c_get_past_pil (p_per_in_ler_id number) is
  select max(pea.per_in_ler_id)
  from   ben_prtt_enrt_actn_f pea,
         ben_per_in_ler pil
  where  pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    pea.per_in_ler_id <> p_per_in_ler_id
  and    pea.business_group_id = p_business_group_id
  and    pea.per_in_ler_id = pil.per_in_ler_id
  and    pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD');
  --bug 5187145 added subquery
  CURSOR c_actn_item_for_past_pil (p_per_in_ler_id NUMBER)
   IS
      SELECT   prtt_enrt_actn_id, effective_start_date,
               object_version_number
          FROM ben_prtt_enrt_actn_f
         WHERE per_in_ler_id = p_per_in_ler_id
           AND prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
           AND effective_end_date < hr_api.g_eot
           AND business_group_id = p_business_group_id
           AND prtt_enrt_actn_id not in
                  (SELECT prtt_enrt_actn_id
                     FROM ben_prtt_enrt_actn_f
                    WHERE per_in_ler_id = p_per_in_ler_id
                      AND prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
                      AND cmpltd_dt IS NOT NULL)
      ORDER BY prtt_enrt_actn_id;
  l_actn_item                     c_actn_item_for_past_pil%rowtype;
  --
  cursor c_enrt_ctfn_for_past_pil (p_prtt_enrt_actn_id number) is
  select prtt_enrt_ctfn_prvdd_id, effective_start_date, object_version_number
  from   ben_prtt_enrt_ctfn_prvdd_f
  where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    prtt_enrt_actn_id = p_prtt_enrt_actn_id
  and    effective_end_date < hr_api.g_eot
  and    business_group_id = p_business_group_id;
  l_enrt_ctfn                     c_enrt_ctfn_for_past_pil%rowtype;
  --
  cursor c_check_prem_active is
  select 1
  from   ben_prtt_prem_f
  where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    effective_end_date = hr_api.g_eot;
  l_check_prem_active             c_check_prem_active%rowtype;
  --
  cursor c_ended_prem_details is
  select ppm.prtt_prem_id, ppm.effective_start_date, ppm.object_version_number
  from   ben_prtt_prem_f ppm
  where  ppm.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    ppm.effective_end_date <> hr_api.g_eot
  and    not exists (select 1
                     from   ben_prtt_prem_f ppm2
                     where  ppm2.prtt_prem_id = ppm.prtt_prem_id
                     and    ppm2.effective_end_date > ppm.effective_end_date)
  order by effective_start_date desc;
  l_ended_prem_details            c_ended_prem_details%rowtype;
  --
  l_proc                          varchar2(80) := g_package||'.unprocess_susp_enrt_past_pil';
  l_per_in_ler_id                 number;
  l_prtt_enrt_actn_id             number;
  l_effective_start_date          date;
  l_effective_end_date            date;
  l_object_version_number         number;
  l_ppe_object_version_number     number;
  l_prev_prtt_enrt_actn_id        number;
  l_prev_enrt_ctfn_prvdd_id       number;
  --
begin
  --
  hr_utility.set_location ('Entering ' || l_proc , 1230);
  l_per_in_ler_id := p_per_in_ler_id;
  --
  l_prev_prtt_enrt_actn_id := -1;
  l_prev_enrt_ctfn_prvdd_id := -1;
  --
  for l_actn_item in c_actn_item_for_past_pil (l_per_in_ler_id) loop
  --
     l_prtt_enrt_actn_id := l_actn_item.prtt_enrt_actn_id;
     --
     -- Un-enddate action item record
     --
     l_object_version_number := l_actn_item.object_version_number;
     --
     hr_utility.set_location('ACE l_prev_prtt_enrt_actn_id = ' || l_prev_prtt_enrt_actn_id, 9999);
     hr_utility.set_location('ACE l_prtt_enrt_actn_id = ' || l_prtt_enrt_actn_id, 9999);
     if l_prev_prtt_enrt_actn_id <> l_prtt_enrt_actn_id
     then
       --
       -- Bug 4642315 : Cursor C_ACTN_ITEM_FOR_PAST_PIL will pick up multiple datetracked
       --               records for same PRTT_ENRT_ACTN_ID. So once we modify one PEA record
       --               it will be valid till EOT and other datetracked records would have
       --               been deleted. Hence call DEL only once for a PEA_Id
       --
       l_prev_prtt_enrt_actn_id := l_prtt_enrt_actn_id;
       --
       ben_pea_del.del(
                       p_prtt_enrt_actn_id => l_actn_item.prtt_enrt_actn_id,
                       p_effective_start_date => l_effective_start_date,
                       p_effective_end_date => l_effective_end_date,
                       p_object_version_number => l_object_version_number,
                       p_effective_date => l_actn_item.effective_start_date,
                       p_datetrack_mode => hr_api.g_future_change);
       --
     end if;
     --
     hr_utility.set_location('ACE l_actn_item.prtt_enrt_actn_id = ' || l_actn_item.prtt_enrt_actn_id, 8888);
     --
     -- Un-enddate enrollment certification record(s)
     --
     l_prev_enrt_ctfn_prvdd_id := -1;
     --
     for l_enrt_ctfn in c_enrt_ctfn_for_past_pil (l_prtt_enrt_actn_id) loop
     --
        l_object_version_number := l_enrt_ctfn.object_version_number;
        --
        if l_prev_enrt_ctfn_prvdd_id <> l_enrt_ctfn.prtt_enrt_ctfn_prvdd_id
        then
          --
          -- Bug Bug 4642315 :
          --
          l_prev_enrt_ctfn_prvdd_id := l_enrt_ctfn.prtt_enrt_ctfn_prvdd_id;
          --
          ben_pcs_del.del(
                          p_prtt_enrt_ctfn_prvdd_id => l_enrt_ctfn.prtt_enrt_ctfn_prvdd_id,
                          p_effective_start_date => l_effective_start_date,
                          p_effective_end_date => l_effective_end_date,
                          p_object_version_number => l_object_version_number,
                          p_effective_date => l_enrt_ctfn.effective_start_date,
                          p_datetrack_mode => hr_api.g_future_change);
          --
        end if;
        --
     --
     end loop;
  --
  end loop;
  --
  -- Process premium, if ended (will be needed for ineligible/due date past cases)
  --
  open c_check_prem_active;
  fetch c_check_prem_active into l_check_prem_active;
  if c_check_prem_active%notfound then
     --
     -- Unend most recent premiums
     --
     for l_ended_prem_details in c_ended_prem_details loop
        l_ppe_object_version_number := l_ended_prem_details.object_version_number;
        ben_ppe_del.del(
                        p_prtt_prem_id => l_ended_prem_details.prtt_prem_id,
                        p_effective_start_date => l_effective_start_date,
                        p_effective_end_date => l_effective_end_date,
                        p_object_version_number => l_ppe_object_version_number,
                        p_effective_date => l_ended_prem_details.effective_start_date,
                        p_datetrack_mode => hr_api.g_future_change);
     end loop;
     --
  end if;
  close c_check_prem_active;
  --
  hr_utility.set_location ('Leaving ' || l_proc, 1230);
end unprocess_susp_enrt_past_pil;
-- CFW
--
-- This function has been added as part of fix for bug 2518955
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_msg_name  >---------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_msg_name RETURN VARCHAR2 IS

  l_encoded_msg		VARCHAR2(3000);
  l_msg_name		VARCHAR2(30);
  l_msg_app		VARCHAR2(50);
  l_proc 		VARCHAR2(72) := g_package||'get_msg_name';

BEGIN
  -- hr_utility.set_location('Entering:'|| l_proc, 10);

  l_encoded_msg := fnd_message.get_encoded();
  fnd_message.parse_encoded(
                	    encoded_message => l_encoded_msg
                	   ,app_short_name  => l_msg_app      -- OUT
                	   ,message_name    => l_msg_name     -- OUT
                	   );

  -- hr_utility.set_location('Leaving:'|| l_proc, 20);

  RETURN l_msg_name;

END; -- get_msg_name

procedure adj_prv_rate (p_person_id  number,
                        p_prtt_rt_val_id  number,
                        p_rt_end_dt     date,
                        p_object_version_number number,
                        p_business_group_id number,
                        p_effective_date date) is
--
 cursor c_future_prv is
   select prv.*
   from ben_prtt_rt_val prv,
        ben_prtt_enrt_rslt_f pen,
        ben_acty_base_rt_f abr
   where prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
   and   pen.person_id = p_person_id
   and   prv.prtt_rt_val_stat_cd is null
   and   prv.rt_strt_dt > p_rt_end_dt
   and   pen.prtt_enrt_rslt_stat_cd is null
   and   prv.acty_base_rt_id = abr.acty_base_rt_id
   and   abr.element_type_id =
        (select element_type_id  from ben_acty_base_rt_f abr2,
                                      ben_prtt_rt_val prv2
         where abr2.acty_base_rt_id = prv2.acty_base_rt_id
         and   prv2.prtt_rt_val_id = p_prtt_rt_val_id
         and   prv2.rt_strt_dt between abr2.effective_start_date
               and abr2.effective_end_date)
  and   prv.rt_strt_dt between abr.effective_start_date
               and abr.effective_end_date
  and   pen.effective_end_Date = hr_api.g_eot;
 --
 l_prv  c_future_prv%rowtype;
 --
 cursor c_element (p_element_entry_value_id number) is
   select pee.element_entry_id,
          pee.effective_start_date,
          pee.effective_end_date,
          pee.object_version_number
   from   pay_element_entries_f pee,
       pay_element_entry_values_f pev
   where pev.element_entry_value_id = p_element_entry_value_id
   and   pev.element_entry_id = pee.element_entry_id
   order by pee.effective_start_date;
 --
 l_element   c_element%rowtype;
 l_delete_warning  boolean;
 l_object_version_number number;
 l_dummy_number    number;
 l_element_start_date date;
 --
begin
  --
  hr_utility.set_location('Entering Adj Prv rate',10);
  open c_future_prv;
  fetch c_future_prv into l_prv;
  close c_future_prv;
  --
  if l_prv.element_entry_value_id is not null then
     --
     hr_utility.set_location('value Id is not null',11);
     open c_element (l_prv.element_entry_value_id);
     fetch c_element into l_element;
     close c_element;
     --
     hr_utility.set_location('effective date'||l_element.effective_start_date,10);
     l_element_start_date := l_element.effective_start_date;
     py_element_entry_api.delete_element_entry
        (p_validate => false
        ,p_datetrack_delete_mode => hr_api.g_zap
        ,p_effective_date        => l_element_start_date
        ,p_element_entry_id      => l_element.element_entry_id
        ,p_object_version_number => l_element.object_version_number
        ,p_effective_start_date  => l_element.effective_start_date
        ,p_effective_end_date    => l_element.effective_end_date
        ,p_delete_warning        => l_delete_warning
        );
    --
  end if;
  -- adjust the rate
  l_object_version_number := p_object_version_number;
  hr_utility.set_location ('Adjust old rate',12);
  ben_prtt_rt_val_api.update_prtt_rt_val
           (P_PRTT_RT_VAL_ID          => p_prtt_rt_val_id
           ,P_RT_END_DT               => p_rt_END_DT
           ,p_person_id               => p_person_id
           ,p_business_group_id       => p_business_group_id
           ,P_OBJECT_VERSION_NUMBER   => l_object_version_number
           ,P_EFFECTIVE_DATE          => p_effective_date
           );
        --

  if l_prv.element_entry_value_id is not null then
    --
    hr_utility.set_location ('Recreate element ',14);
    ben_element_entry.create_enrollment_element
     (p_business_group_id        => p_business_group_id
     ,p_prtt_rt_val_id           => l_prv.prtt_rt_val_id
     ,p_person_id                => p_person_id
     ,p_acty_ref_perd            => l_prv.acty_ref_perd_cd
     ,p_acty_base_rt_id          => l_prv.acty_base_rt_id
     ,p_enrt_rslt_id             => l_prv.prtt_enrt_rslt_id
     ,p_rt_start_date            => l_prv.rt_strt_dt
     ,p_rt                       => l_prv.rt_val
     ,p_cmncd_rt                 => l_prv.cmcd_rt_val
     ,p_ann_rt                   => l_prv.ann_rt_val
    -- ,p_input_value_id           => p_input_value_id
    -- ,p_element_type_id          => p_element_type_id
     ,p_prv_object_version_number=> l_prv.object_version_number
     ,p_effective_date           => l_prv.rt_strt_dt
     ,p_eev_screen_entry_value   => l_dummy_number
     ,p_element_entry_value_id   => l_dummy_number
      );
    --
  end if;
  hr_utility.set_location ('Leaving Adjust rate',15);
end;
--
-- Added for bug 7206471
--
procedure adj_pen_cvg (p_person_id  number,
                        p_prtt_enrt_rslt_id number,
                        p_cvg_end_dt     date,
                        p_object_version_number number,
                        p_business_group_id number,
                        p_effective_date date) is
  --

  --
 l_object_version_number number;
 l_dummy_number          number;
 l_effective_start_date  date;
 l_effective_end_date    date;
 --
 --
begin
  --
  hr_utility.set_location('Entering Adj Pen Cvg',44333);
  --
  --
-- adjust the coverage
  l_object_version_number := p_object_version_number;
  hr_utility.set_location ('Adjust old coverage',44333);
 ben_prtt_enrt_result_api.update_prtt_enrt_result
              (p_validate                 => FALSE,
               p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
               p_effective_start_date     => l_effective_start_date,
               p_effective_end_date       => l_effective_end_date,
               p_business_group_id        => p_business_group_id,
               p_object_version_number    => l_object_version_number,
               p_effective_date           => p_effective_date,
               p_datetrack_mode           => hr_api.g_correction,
               p_multi_row_validate       => FALSE,
	       p_enrt_cvg_thru_dt         => p_cvg_end_dt
               );
        --
hr_utility.set_location ('Leaving Adj Pen Cvg',44333);
end;
-- End bug 7206471

-- When  Open LE processed then a LE processed before open starts
-- then Open is reprocessed on the same date LE is processed
-- open enrolled in the same date. in this case LE result is
-- updated with Open PIL_ID. if open  backedout again, result of the LE
-- is last. this is fixed by copying LE result into backup table
-- and copied back if open is backedout  - tilak


--
-- Split the routine into operations that way it can be called by any
-- external routine. Simply pass the tablename and the deletes will
-- happen, a tad dangerous as you must do the deletes in the correct
-- order as otherwise FK's will be hanging.
--
procedure delete_routine(p_routine                in varchar2,
                         p_per_in_ler_id          in number,
                         p_business_group_id      in number,
                         p_bckdt_prtt_enrt_rslt_id in number default null,
                         p_copy_only               in varchar2 default null,
                         p_effective_date          in date) is
  --
  l_package   varchar2(80) := g_package||'.delete_routine';
  --
  --
  -- START ----> DELETE ROUTINE FOR BEN_ELIG_PER_OPT_F
  --
  -- Source Table
  -- BEN_PER_IN_LER
  --
  cursor c_ben_ELIG_PER_OPT_f is
    select epo.ELIG_PER_OPT_id,
           epo.object_version_number
    from   ben_ELIG_PER_OPT_f epo,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    epo.per_in_ler_id = pil.per_in_ler_id
    and    epo.business_group_id = pil.business_group_id
    --
    -- Do not use the effective date check, see
    -- comments at c_ben_prtt_enrt_rslt_f
    -- Rows should be selected based on per in ler only.
    --
    /*
    -- RCHASE Bug#5364 Must use pil.lf_evt_ocrd_dt instead of p_effective_date
    -- and    p_effective_date
    and    pil.lf_evt_ocrd_dt
           between epo.effective_start_date
           and     epo.effective_end_date */
    order by 1;
  --
  -- The cursor gets the maximum effective end date for the dependents
  -- with past per_in_ler 's
  --
  -- RCHASE 5364 - Update cursor to fetch appropriate rows
  -- Previous cursor definition
  --cursor c_epo_max_esd_of_past_pil(v_ELIG_PER_OPT_id in number) is
  --  select max(effective_end_date), max(object_version_number)
  --  from   ben_ELIG_PER_OPT_f
  --  where  ELIG_PER_OPT_id       =  v_ELIG_PER_OPT_id
  --  and    nvl(per_in_ler_id , -1) <> p_per_in_ler_id
  --  and    business_group_id   =  p_business_group_id;
    -- and    effective_end_date      <  p_effective_date;
  -- New cursor definition
/*
    cursor c_epo_max_esd_of_past_pil(v_ELIG_PER_OPT_id in number) is
    select max(epo.effective_end_date), max(epo.object_version_number)
    from   ben_ELIG_PER_OPT_f epo
    where  epo.ELIG_PER_OPT_id       =  v_ELIG_PER_OPT_id
    --RCHASE 5364
    and    nvl(per_in_ler_id , -1) <> p_per_in_ler_id
    and    epo.business_group_id   =  p_business_group_id;
    --
    -- Do not use the effective date check, see
    -- comments at c_ben_prtt_enrt_rslt_f
    -- Rows should be selected based on per in ler only.
    --
*/
    /*
    --RCHASE 5364
    and    epo.effective_end_date <= (select lf_evt_ocrd_dt
                                        from ben_per_in_ler
                                       where per_in_ler_id = p_per_in_ler_id); */
  --
  cursor c_epo_max_esd_of_past_pil(v_ELIG_PER_OPT_id in number) is
     select epo.effective_end_date, epo.object_version_number
     from   ben_ELIG_PER_OPT_f epo,
            ben_per_in_ler pil
     where  epo.ELIG_PER_OPT_id       =  v_ELIG_PER_OPT_id
     and    nvl(epo.per_in_ler_id , -1) <> p_per_in_ler_id
     and    epo.business_group_id   =  p_business_group_id
     and    epo.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     order by epo.effective_end_date desc;

  --
  -- Move deleted records to backup table
  --
  cursor c_deleted_epo(v_elig_per_opt_id in number,
                       v_effective_date    in date) is
    select *
    from   ben_elig_per_opt_f
    where  elig_per_opt_id         =  v_elig_per_opt_id
    and    nvl(per_in_ler_id , -1) =  p_per_in_ler_id
    and    business_group_id   =  p_business_group_id
    and    effective_end_date      > v_effective_date;


  --
  -- END ----> DELETE ROUTINE FOR BEN_ELIG_PER_OPT_F
  --
  -- START ----> DELETE ROUTINE FOR BEN_ELIG_PER_F
  --
  -- Source Table
  -- BEN_PER_IN_LER
  --
  cursor c_ben_elig_per_f is
    select pep.elig_per_id,
           pep.object_version_number
    from   ben_elig_per_f pep,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pep.per_in_ler_id = pil.per_in_ler_id
    and    pep.business_group_id = pil.business_group_id
    --
    -- Do not use the effective date check, see
    -- comments at c_ben_prtt_enrt_rslt_f
    -- Rows should be selected based on per in ler only.
    --
    /*
    -- RCHASE Bug#5364 Must use pil.lf_evt_ocrd_dt instead of p_effective_date
    -- and    p_effective_date
    and    pil.lf_evt_ocrd_dt
           between pep.effective_start_date
           and     pep.effective_end_date
    */
    order by 1;
  --
  -- The cursor gets the maximum effective end date for the dependents
  -- with past per_in_ler 's
  --
/*
  cursor c_pep_max_esd_of_past_pil(v_elig_per_id in number) is
    select max(effective_end_date), max(object_version_number)
    from   ben_elig_per_f
    where  elig_per_id       =  v_elig_per_id
    and    nvl(per_in_ler_id , -1) <> p_per_in_ler_id
    and    business_group_id   =  p_business_group_id;
    -- and    effective_end_date      <  p_effective_date;
*/
  cursor c_pep_max_esd_of_past_pil(v_elig_per_id in number) is
     select pep.effective_end_date, pep.object_version_number
     from   ben_elig_per_f pep,
            ben_per_in_ler pil
     where  pep.elig_per_id       =  v_elig_per_id
     and ((pep.per_in_ler_id <> p_per_in_ler_id
         and pep.per_in_ler_id is not null)
       or
         (pep.per_in_ler_id is null)
        )
     and    pep.business_group_id   =  p_business_group_id
     and    pep.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     order by pep.effective_end_date desc;

-- changed 7176884 begin
Cursor c_get_enrt_mthd_cd(c_prtt_enrt_rslt_id in number) is
select enrt_mthd_cd
from ben_prtt_enrt_rslt_f
where prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
and   per_in_ler_id     = p_per_in_ler_id
and   business_group_id = p_business_group_id
and   prtt_enrt_rslt_stat_cd is null
order by effective_start_date desc;

l_get_enrt_mthd_cd ben_prtt_enrt_rslt_f.enrt_mthd_cd%type;
-- changed 7176884 end
--
--  Bug 8199189
--
Cursor c_get_cvg_thru_dt (p_prtt_enrt_rslt_id in number
                         ,p_effective_date in date) is
select enrt_cvg_thru_dt
      ,prtt_enrt_rslt_stat_cd
from ben_prtt_enrt_rslt_f pen
where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
and   pen.business_group_id = p_business_group_id
and   pen.enrt_cvg_thru_dt <> hr_api.g_eot
-- and   pen.prtt_enrt_rslt_stat_cd is null
and   p_effective_date
between  pen.effective_start_date
         and pen.effective_end_date;

l_cvg_thru_dt ben_prtt_enrt_rslt_f.enrt_cvg_thru_dt%type;
l_prtt_enrt_rslt_stat_cd ben_prtt_enrt_rslt_f.prtt_enrt_rslt_stat_cd%type;
--   end 8199189
  --
  -- Move deleted records to backup table
  --
  cursor c_deleted_pep(v_elig_per_id in number,
                       v_effective_date    in date) is
    select *
    from   ben_elig_per_f
    where  elig_per_id             =  v_elig_per_id
    and    nvl(per_in_ler_id , -1) =  p_per_in_ler_id
    and    business_group_id   =  p_business_group_id
    and    effective_end_date      > v_effective_date;
  --
  -- END ----> DELETE ROUTINE FOR BEN_ELIG_PER_F
  -- START ----> DELETE ROUTINE FOR BEN_PRTT_PREM_F
  --
  -- Source Table
  -- BEN_PER_IN_LER
  --
  ----7133998
  cursor c_ben_prtt_prem_f_corr is
    select ppe.*
    from   ben_prtt_prem_f ppe,
           ben_per_in_ler pil,
	   BEN_LE_CLSN_N_RSTR bkup
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    ppe.per_in_ler_id = pil.per_in_ler_id
    and    ppe.business_group_id = pil.business_group_id
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = ppe.prtt_enrt_rslt_id
          )
    AND   bkup.BKUP_TBL_TYP_CD = 'BEN_PRTT_PREM_F_CORR'
    AND   bkup.BKUP_TBL_ID = ppe.prtt_prem_id
    and   bkup.effective_start_date = ppe.effective_start_date
    and   bkup.effective_end_date = ppe.effective_end_date
    and   bkup.per_in_ler_ended_id = pil.per_in_ler_id;

  cursor c_bkp_prem_row(cv_BKUP_TBL_TYP_CD in varchar2,
               cv_BKUP_TBL_ID     in number,
               cv_effective_start_date in date,
	       cv_effective_end_date in date) is
    select bkup.*,bkup.rowid
    from BEN_LE_CLSN_N_RSTR bkup
    where BKUP_TBL_TYP_CD = cv_BKUP_TBL_TYP_CD
      and BKUP_TBL_ID     = cv_BKUP_TBL_ID
      and effective_start_date = cv_effective_start_date
      and effective_end_date = cv_effective_end_date
      and per_in_ler_ended_id = p_per_in_ler_id
    order by effective_start_date;
  --------7133998
  cursor c_ben_prtt_prem_f is
    select ppe.prtt_prem_id,
           ppe.object_version_number
    from   ben_prtt_prem_f ppe,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    ppe.per_in_ler_id = pil.per_in_ler_id
    and    ppe.business_group_id = pil.business_group_id
    --
    -- Do not use the effective date check, see
    -- comments at c_ben_prtt_enrt_rslt_f
    -- Rows should be selected based on per in ler only.
    --
    /*
    and    p_effective_date
           between ppe.effective_start_date
           and     ppe.effective_end_date */
    --    # 2982606 added for result level backout
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = ppe.prtt_enrt_rslt_id
          )
    order by 1;
  --
  -- The cursor gets the maximum effective end date for the dependents
  -- with past per_in_ler 's
  --
  /*
  cursor c_ppe_max_esd_of_past_pil(v_prtt_prem_id in number) is
    select max(effective_end_date), max(object_version_number)
    from   ben_prtt_prem_f
    where  prtt_prem_id       =  v_prtt_prem_id
    and    nvl(per_in_ler_id , -1) <> p_per_in_ler_id
    and    business_group_id   =  p_business_group_id;
    -- and    effective_end_date      <  p_effective_date;
 */
  cursor c_ppe_max_esd_of_past_pil(v_prtt_prem_id in number) is
    select prm.effective_end_date, prm.object_version_number
    from   ben_prtt_prem_f prm,
           ben_per_in_ler pil
     where  prm.prtt_prem_id  =  v_prtt_prem_id
     and    nvl(prm.per_in_ler_id , -1) <> p_per_in_ler_id
     and    prm.business_group_id   =  p_business_group_id
     and    prm.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     order by prm.effective_end_date desc;


  cursor c_deleted_ppe(v_prtt_prem_id in number,
                       v_effective_date    in date) is
    select *
    from   ben_prtt_prem_f
    where  prtt_prem_id            =  v_prtt_prem_id
    and    nvl(per_in_ler_id , -1) =  p_per_in_ler_id
    and    business_group_id   =  p_business_group_id
    and    effective_end_date      > v_effective_date;

  --
  -- END ----> DELETE ROUTINE FOR BEN_PRTT_PREM_F
  --
  -- START ----> DELETE ROUTINE FOR BEN_ELIG_CVRD_DPNT_F
  --
  -- Source Table
  -- BEN_PER_IN_LER
  --
  -- Bug 5222 : Removed the effective date check.
  -- See comments at c_ben_prtt_enrt_rslt_f cursor.
  --
  cursor c_ben_elig_cvrd_dpnt_f is
    select pdp.elig_cvrd_dpnt_id,
           pdp.object_version_number,
					 -- bug 5668052
					 pdp.effective_start_date
    from   ben_elig_cvrd_dpnt_f pdp,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pdp.per_in_ler_id = pil.per_in_ler_id
    and    pdp.business_group_id = pil.business_group_id
    --    # 2982606 added for result level backout
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
          )
    order by 1;
		-- bug 5668052
		l_dpnt_eff_start_date date;
  --
  -- The cursor gets the maximum effective end date for the dependents
  -- with past per_in_ler 's
  --
/*
  cursor c_pdp_max_esd_of_past_pil(v_elig_cvrd_dpnt_id in number) is
    select max(effective_end_date), max(object_version_number)
    from   ben_elig_cvrd_dpnt_f
    where  elig_cvrd_dpnt_id       =  v_elig_cvrd_dpnt_id
    and    nvl(per_in_ler_id , -1) <> p_per_in_ler_id
    and    business_group_id   =  p_business_group_id;
    -- and    effective_end_date      <  p_effective_date;
*/
   cursor c_pdp_max_esd_of_past_pil(v_elig_cvrd_dpnt_id in number) is
     select pdp.effective_end_date, pdp.object_version_number
     from   ben_elig_cvrd_dpnt_f pdp,
            ben_per_in_ler pil
     where  pdp.elig_cvrd_dpnt_id       =  v_elig_cvrd_dpnt_id
     and    nvl(pdp.per_in_ler_id , -1) <> p_per_in_ler_id
     and    pdp.business_group_id   =  p_business_group_id
     and    pdp.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     order by pdp.effective_end_date desc;

  --
  -- Move deleted records to backup table
  --
  cursor c_deleted_pdp(v_elig_cvrd_dpnt_id in number,
                       v_effective_date    in date) is
    select *
    from   ben_elig_cvrd_dpnt_f
    where  elig_cvrd_dpnt_id       =  v_elig_cvrd_dpnt_id
    and    nvl(per_in_ler_id , -1) =  p_per_in_ler_id
    and    business_group_id   =  p_business_group_id
    and    effective_end_date      > v_effective_date;

  --
  -- END ----> DELETE ROUTINE FOR BEN_ELIG_CVRD_DPNT_F
  --
  -- START ----> DELETE ROUTINE FOR BEN_PL_BNF_F
  --
  -- Source Table
  -- BEN_PER_IN_LER
  --
  cursor c_ben_pl_bnf_f is
    select pbn.pl_bnf_id,
           pbn.object_version_number,
					 -- bug 5668052
					 pbn.effective_start_date
    from   ben_pl_bnf_f pbn,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pbn.per_in_ler_id = pil.per_in_ler_id
    and    pbn.business_group_id = pil.business_group_id
    --
    -- Do not use the effective date check, see
    -- comments at c_ben_prtt_enrt_rslt_f
    -- Rows should be selected based on per in ler only.
    --
    /*
    and    p_effective_date
           between pbn.effective_start_date
           and     pbn.effective_end_date
    */
    --    # 2982606 added for result level backout
    and    (p_bckdt_prtt_enrt_rslt_id is null
            or p_bckdt_prtt_enrt_rslt_id = pbn.prtt_enrt_rslt_id
           )
    order by 1;
		-- bug 5668052
		l_bnf_effective_start_date date;
  --
  -- The cursor gets the maximum effective end date for the beneficiary
  -- with past per_in_ler 's
  --
  -- 5649636 : c_pbn_max_esd_of_past_pil is modified
  /* cursor c_pbn_max_esd_of_past_pil(v_pl_bnf_id in number) is
    select max(effective_end_date), max(object_version_number)
    from   ben_pl_bnf_f
    where  pl_bnf_id       =  v_pl_bnf_id
    and    nvl(per_in_ler_id , -1) <> p_per_in_ler_id
    and    business_group_id   =  p_business_group_id;
    -- and    effective_end_date      <  p_effective_date;
    */
   -- 5895645 : typo fix
cursor c_pbn_max_esd_of_past_pil(v_pl_bnf_id in number) is
     select pbn.effective_end_date, pbn.object_version_number
     from   ben_pl_bnf_f pbn,
            ben_per_in_ler pil
     where  pbn.pl_bnf_id           =  v_pl_bnf_id
     and    nvl(pbn.per_in_ler_id , -1) <> p_per_in_ler_id
     and    pbn.business_group_id   =  p_business_group_id
     and    pbn.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     order by pbn.effective_end_date desc;

  --
  -- Move deleted records to backup table
  --
  cursor c_deleted_pbn(v_pl_bnf_id in number,
                       v_effective_date    in date) is
    select *
    from   ben_pl_bnf_f
    where  pl_bnf_id               =  v_pl_bnf_id
    and    nvl(per_in_ler_id , -1) =  p_per_in_ler_id
    and    business_group_id   =  p_business_group_id
    and    effective_end_date      > v_effective_date;
  --
  --
  -- END ----> DELETE ROUTINE FOR BEN_PL_BNF_F
  --
  -- START ----> DELETE ROUTINE FOR BEN_PRMRY_CARE_PRVDR_F
  --
  -- Source Table
  -- BEN_PER_IN_LER
  -- Drive Routes
  -- BEN_PRTT_ENRT_RSLT_F
  --
  --
  cursor c_ben_prmry_care_prvdr_f is
    select ppr.prmry_care_prvdr_id,
           ppr.effective_start_date,
           ppr.object_version_number
    from   ben_prmry_care_prvdr_f ppr,
           ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pen.per_in_ler_id = pil.per_in_ler_id
    and    pen.business_group_id = pil.business_group_id
    and    ppr.effective_start_date
           between pen.effective_start_date
           and     pen.effective_end_date
    and    ppr.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    and    ppr.business_group_id = pen.business_group_id
    --
    -- Do not use the effective date check, see
    -- comments at c_ben_prtt_enrt_rslt_f
    -- Rows should be selected based on per in ler only.
    --
    /*
    and    p_effective_date
           between ppr.effective_start_date
           and     ppr.effective_end_date
    */
    --    # 2982606 added for result level backout
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = ppr.prtt_enrt_rslt_id
          )
    order by 1;
  --
  -- END ----> DELETE ROUTINE FOR BEN_PRMRY_CARE_PRVDR_F
  --
  -- START ----> DELETE ROUTINE FOR BEN_PRTT_RT_VAL
  --
  -- Source Table
  -- BEN_PER_IN_LER
  --
  cursor c_ben_prtt_rt_val is
    select prv.prtt_rt_val_id,
           prv.object_version_number,
           pil.person_id,
           prv.rt_strt_dt,
           prv.acty_ref_perd_cd,
           prv.prtt_enrt_rslt_id,
           prv.pk_id,
           prv.pk_id_table_name
    from   ben_prtt_rt_val prv,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    prv.prtt_rt_val_stat_cd is null
    and    prv.per_in_ler_id = pil.per_in_ler_id
    and    prv.business_group_id = pil.business_group_id
    --    # 2982606 added for result level backout
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
          )
    order  by prv.rt_strt_dt desc;
  --
  cursor c_prv_of_previous_pil is
    select prv.prtt_rt_val_id,
           prv.object_version_number,
           prv.rt_end_dt,
           prv.rt_strt_dt,
           prv.per_in_ler_id,
           prv.prtt_enrt_rslt_id,
           prv.acty_base_rt_id,
           pil.person_id
    from   ben_prtt_rt_val  prv,
           ben_per_in_ler pil
    where  prv.ended_per_in_ler_id = pil.per_in_ler_id
    and    prv.ended_per_in_ler_id = p_per_in_ler_id
    and    prv.per_in_ler_id <> p_per_in_ler_id -- Bug 8234902, not to consider the
                                                -- rates of backed out LifeEvent when determining previous pil
    and    nvl(prv.prtt_rt_val_stat_cd,'BCKDT') ='BCKDT'
    and    prv.business_group_id = p_business_group_id
    and    prv.business_group_id = pil.business_group_id
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id)
  order by prv.acty_base_rt_id,prv.rt_strt_dt asc;
  --
  l_prv_bckdt      c_prv_of_previous_pil%rowtype;
  --
  cursor c_next_prv is
    select prv.prtt_rt_val_id,
           prv.rt_strt_dt,
           prv.per_in_ler_id
    from   ben_prtt_rt_val  prv
    where  prv.ended_per_in_ler_id = p_per_in_ler_id
    and    prv.prtt_rt_val_stat_cd ='BCKDT'
    and    prv.per_in_ler_id <> p_per_in_ler_id -- Bug 8234902, not to consider the rates of backed out LifeEvent
    and    prv.prtt_enrt_rslt_id = l_prv_bckdt.prtt_enrt_rslt_id
    and    prv.acty_base_rt_id = l_prv_bckdt.acty_base_rt_id
    and    prv.prtt_rt_val_id <> l_prv_bckdt.prtt_rt_val_id
    and    prv.rt_strt_dt >= l_prv_bckdt.rt_strt_dt
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id)
  order by prv.rt_strt_dt asc;
  l_next_prv      c_next_prv%rowtype;
  --
  cursor c_prtt_rt_val_adj (p_per_in_ler_id number) is
   select *
   from ben_le_clsn_n_rstr
   where BKUP_TBL_TYP_CD = 'BEN_PRTT_RT_VAL_ADJ'
   AND   PER_IN_LER_ID  = p_per_in_ler_id;
  --
  l_rt_adj  c_prtt_rt_val_adj%rowtype;
  --
  cursor c_prv_ovn (p_prtt_rt_val_id in number) is
    select object_version_number
    from ben_prtt_rt_val
    where prtt_rt_val_id = p_prtt_rt_val_id;
    --
    -- Added for bug 7206471
  cursor c_prtt_enrt_rslt_adj (p_per_in_ler_id in number) is
	   select *
	   from ben_le_clsn_n_rstr
	   where BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F_ADJ'
	   AND   PER_IN_LER_ID  = p_per_in_ler_id;
	   --
	   l_cvg_adj  c_prtt_enrt_rslt_adj%rowtype;
	   --
  cursor c_pen_ovn (p_prtt_enrt_rslt_id in number) is
	    select object_version_number,
	    effective_start_date -- Bug 8507247:
	    --APP-PAY-07155 error on backing out the life event which has created coverage adjustment records if
	    --there are date track records for the enrollment after SYSDATE
	    from ben_prtt_enrt_rslt_f
	    where prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
	    and   effective_end_date = hr_api.g_eot
	    and   prtt_enrt_rslt_stat_cd is null;
  -- End bug 7206471
  --
  -- Bug : 4661 Cursor to select the prtt_enrt_rslt record associated
  -- with current prtt_rt_val record, this records effective_start_date
  -- is used as effective_date for rate val record.
  --
  cursor c_prv_pen(cp_prtt_enrt_rslt_id in number, cv_rt_strt_dt in date) is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number,
           pen.effective_end_date,
           pen.effective_start_date
    from   ben_prtt_enrt_rslt_f pen
    where  pen.business_group_id = p_business_group_id
    and    pen.prtt_enrt_rslt_id = cp_prtt_enrt_rslt_id
-- Commented per bug 1584238 and 1627373
--    and    cv_rt_strt_dt >= pen.enrt_cvg_strt_dt
    and   pen.prtt_enrt_rslt_stat_cd is null
    order by pen.effective_start_date asc;
  --
  -- Bug 3495372 We can have multiple tables with coverage restrictions
  -- when there is an interim with the same comp object. This happens
  -- when the coverage is enter value at enrollment
  --
  /* BUG 3507554 Performance Changes
  cursor c_multiple_rate is
    select 'Y'
    from   ben_prtt_rt_val prv,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    prv.prtt_rt_val_stat_cd is null
    and    prv.per_in_ler_id = pil.per_in_ler_id
    and    prv.business_group_id = pil.business_group_id
    --START BUG 3495372
    and    prv.prtt_enrt_rslt_id in
              (select prtt_enrt_rslt_id
                 from  ben_prtt_enrt_rslt_f
                 where prtt_enrt_rslt_stat_cd is not null
                   and sspndd_flag = 'N'
                      ) -- to leave out Suspended results
    --END BUG 3495372
    and    not exists (select null from ben_prtt_enrt_rslt_f where
                   prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
                    and prtt_enrt_rslt_stat_cd is not null ) -- to leave out VOIDD results
    group by prv.acty_base_rt_id
    having count(*) > 1;
  */
  --
  --BUG 3507554 Performance Changes
  --
  cursor c_multiple_rate is
    select 'Y'
    from   ben_prtt_rt_val prv
    where  prv.per_in_ler_id = p_per_in_ler_id
    and    prv.prtt_rt_val_stat_cd is null
    and    exists (select null
                     from ben_prtt_enrt_rslt_f pen
                    where pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
                      and pen.prtt_enrt_rslt_stat_cd is null
                      and pen.sspndd_flag = 'N' ) -- to select only not voided and unsuspended results
    group by prv.acty_base_rt_id,prv.rt_strt_dt   --BUG 4558512 otherwise.. we get into issue with FLAT RANGE
                                                  --and Enter Benefit at enrollment cert completion cases
    having count(*) > 1;
  --
  l_multiple_rate        varchar2(1) := 'N';
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_oracle_schema		varchar2(30);

  l_prv_pen      c_prv_pen%rowtype;
  --
  -- Pbodla : Link between prv and ecr needs to be stored as this
  -- information is required to restore the enrollment data as
  -- part of life event restoration.
  -- Get the ecr info to store the link between ecr and prv rows.
  --
  cursor c_ecr(v_prtt_rt_val_id in number) is
     select ecr.*
     from   ben_enrt_rt ecr
     where  ecr.prtt_rt_val_id      =  v_prtt_rt_val_id
     and    ecr.business_group_id   =  p_business_group_id;
  --
  l_ecr      c_ecr%rowtype;



  --
  --
  -- END ----> DELETE ROUTINE FOR BEN_PRTT_RT_VAL
  --
  -- START ----> DELETE ROUTINE FOR BEN_PRTT_ENRT_RSLT_F
  --
  -- Source Table
  -- BEN_PER_IN_LER
  --

  /*Bug 8984394*/
  /* Bug 8984394: Get the pil_id and epe_id of the reopened result*/
  cursor c_get_pil_id(c_prtt_enrt_rslt_id number) is
  select pen.per_in_ler_id,
         epe.elig_per_elctbl_chc_id,
	 epe.object_version_number,
	 epe.prtt_enrt_rslt_id
    from
         ben_prtt_enrt_rslt_f pen,
	 ben_per_in_ler pil,
	 ben_elig_per_elctbl_chc epe
  where pen.prtt_enrt_rslt_id  = c_prtt_enrt_rslt_id
       and pen.effective_end_date = hr_api.g_eot
       and pen.enrt_cvg_thru_dt = hr_api.g_eot
       and pen.prtt_enrt_rslt_stat_cd is null
       and pen.per_in_ler_id = pil.per_in_ler_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
       and epe.per_in_ler_id = pil.per_in_ler_id
       and nvl(epe.pgm_id,-1) = nvl(pen.pgm_id,-1)
       and epe.pl_id = pen.pl_id
       and epe.pl_typ_id = pen.pl_typ_id
       and nvl(epe.oipl_id,-1) = nvl(pen.oipl_id,-1);

  l_upd_epe c_get_pil_id%rowtype;

 /* Get the previous pil_id*/
  cursor c_prev_pil_id  is
  select per_in_ler_id
    from ben_per_in_ler pil,
         ben_ler_f ler
   where pil.per_in_ler_id <> p_per_in_ler_id
     and pil.per_in_ler_stat_cd not in  ('VOIDD','BCKDT')
     and pil.person_id  =  (select person_id from ben_per_in_ler where
                             per_in_ler_id = p_per_in_ler_id)
     and pil.ler_id = ler.ler_id
     and ler.typ_cd not in ('COMP', 'ABS', 'GSP', 'IREC')
     and p_effective_date between ler.effective_start_date and ler.effective_end_date
     order by lf_evt_ocrd_dt desc ;

 l_prev_pil_id number;
 /*End of Bug 8984394*/

  cursor c_ben_prtt_enrt_rslt_f is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number,
           pen.pl_id,
           pen.oipl_id,
           pen.enrt_cvg_strt_dt,
           pen.person_id,
           pen.enrt_cvg_thru_dt,
           pen.effective_end_date,
           pen.effective_start_date,
           pen.per_in_ler_id
           ,pil.lf_evt_ocrd_dt
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pen.per_in_ler_id = pil.per_in_ler_id
    and    pen.business_group_id = pil.business_group_id
    --    # 2982606 added for result level backout
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
          )
    order by 1;

    ---  make sure results of prev per in ler id
    ---  currected by curr per_in_ler_id due to same date enrollment
    ---  are not backedout  bug # 3086161
    ---  after the # 3175382 new cursor created and the validation moved
    --  from c_ben_prtt_enrt_rslt_f. because for current per in ler id the backout entry has to be created
    --- unless the current per_in_ler can not be reinstated. so the cursor created to  validate
    --- the delting part ofthe result. the result can not be deleted because the prev correctecd
    --- result has to be restored with the prev per in ler id

    cursor  c_corr_result_exist (l_per_in_ler_id     number ,
                                 l_prtt_enrt_rslt_id number ) is
    select 'x'
    from BEN_LE_CLSN_N_RSTR  lcnr
         ,BEN_PRTT_ENRT_RSLT_F pen   -- Bug 6632568
    where lcnr.bkup_tbl_id          = pen.prtt_enrt_rslt_id -- Bug 6632568
      and pen.prtt_enrt_rslt_id     = l_prtt_enrt_rslt_id  -- Bug 6632568
      and lcnr.BKUP_TBL_TYP_CD      = 'BEN_PRTT_ENRT_RSLT_F_CORR'
      and lcnr.enrt_cvg_thru_dt = hr_api.g_eot  --bug#5032364
      and  lcnr.per_in_ler_ended_id = pen.per_in_ler_id -- Bug 6632568
      and  pen.per_in_ler_id  = l_per_in_ler_id -- Bug 6632568
      and  lcnr.effective_start_date between pen.effective_start_date  -- Bug 6632568
				     and  pen.effective_end_date;


    /* -- Bug : 1143673(4287)
       -- No ed clause required. Consider the following scenario.
          result 1 created as of 06/16/99,
          result 2 created as of 06/17/99,
          result 3 created as of 06/18/99 - EOT.
          If the back out with effective date of 06/20/99 is
          called from BENDSPLE to voidd the potential,
          then this process only catches the 3rd record, other two
          stays as. If a life event is processed as of 06/17/99 then
          a result will be created with cvg_strt_dt and orgnl_strt_dt
          of 06/16/99. To avoid this set all the results to BCKDT.
       --
    and    p_effective_date
           between pen.effective_start_date
           and     pen.effective_end_date;
    */
   -- bug # 3086161
   cursor c_BEN_LE_CLSN_N_RSTR_corr  (c_pil_id  number)
          is
    select lcnr.bkup_tbl_id,
           lcnr.effective_start_date,
           lcnr.effective_end_date,
           lcnr.per_in_ler_id,
           lcnr.ler_id,
           lcnr.enrt_cvg_thru_dt,
           lcnr.prtt_enrt_rslt_stat_cd,
           lcnr.sspndd_flag,
	   lcnr.enrt_mthd_cd, -- Bug 7137371
           pen.effective_end_date pen_effective_end_date, -- Bug 7197868
           pen.object_version_number
    from   BEN_LE_CLSN_N_RSTR lcnr,
           ben_prtt_enrt_rslt_f  pen
    where  lcnr.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F_CORR'
      and  lcnr.Per_in_ler_ended_id = c_pil_id
      and  pen.prtt_enrt_rslt_id = lcnr.bkup_tbl_id
      --bug#5032364
      --and  (pen.per_in_ler_id     =  lcnr.per_in_ler_ended_id
      --      or pen.per_in_ler_id = lcnr.per_in_ler_id)
 --Bug 6489602
      and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
          )
  --Bug 6489602
      and  lcnr.effective_start_date between
           pen.effective_start_date and pen.effective_end_date
     order by lcnr.bkup_tbl_id;
   --

   cursor c_BEN_LE_CLSN_N_RSTR_del  (c_pil_id  number)
          is
    select lcnr.bkup_tbl_id,
           lcnr.effective_start_date,
           lcnr.effective_end_date,
           lcnr.per_in_ler_id,
           lcnr.ler_id,
           lcnr.enrt_cvg_thru_dt,
           lcnr.prtt_enrt_rslt_stat_cd,
           lcnr.sspndd_flag,
           pen.object_version_number
    from   BEN_LE_CLSN_N_RSTR lcnr,
           ben_prtt_enrt_rslt_f  pen
    where  lcnr.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F_DEL'
      and  lcnr.Per_in_ler_ended_id = c_pil_id
      and  pen.prtt_enrt_rslt_id = lcnr.bkup_tbl_id
      --bug#5032364
      --and  (pen.per_in_ler_id     =  lcnr.per_in_ler_ended_id
      --      or pen.per_in_ler_id = lcnr.per_in_ler_id)
      and  lcnr.effective_start_date between
           pen.effective_start_date and pen.effective_end_date
     order by lcnr.bkup_tbl_id;


     cursor c_BEN_LE_CLSN_N_RSTR_dpnt  (c_pil_id  number)
          is
    select lcnr.bkup_tbl_id,
           pdp.effective_start_date,
           pdp.effective_end_date,
           lcnr.per_in_ler_id,
           lcnr.ler_id,
           lcnr.enrt_cvg_thru_dt,
           lcnr.prtt_enrt_rslt_stat_cd,
           lcnr.effective_start_date bkp_effective_start_date, -- 7197868
           lcnr.effective_end_date bkp_effective_end_date, -- 7197868
           pdp.object_version_number,
           pdp.elig_cvrd_dpnt_id
    from   BEN_LE_CLSN_N_RSTR lcnr,
           ben_elig_cvrd_dpnt_f  pdp
    where  lcnr.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F_CORR'
      and  lcnr.Per_in_ler_ended_id = c_pil_id
      and  pdp.prtt_enrt_rslt_id = lcnr.bkup_tbl_id
      and  (pdp.per_in_ler_id     =  lcnr.per_in_ler_ended_id
           or  pdp.per_in_ler_id     =  lcnr.per_in_ler_id )
      and  pdp.prtt_enrt_rslt_id =  lcnr.bkup_tbl_id
      and  lcnr.effective_start_date between
           pdp.effective_start_date and pdp.effective_end_date
      order by pdp.elig_cvrd_dpnt_id;

  cursor c_BEN_LE_CLSN_N_RSTR_pbn  (c_pil_id  number)
          is
    select lcnr.bkup_tbl_id,
           pbn.effective_start_date,
           pbn.effective_end_date,
           lcnr.per_in_ler_id,
           lcnr.ler_id,
           lcnr.enrt_cvg_thru_dt,
           lcnr.prtt_enrt_rslt_stat_cd,
           pbn.object_version_number,
           pbn.pl_bnf_id
    from   BEN_LE_CLSN_N_RSTR lcnr,
           ben_pl_bnf_f  pbn
    where  lcnr.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F_CORR'
      and  lcnr.Per_in_ler_ended_id = c_pil_id
      and  pbn.prtt_enrt_rslt_id = lcnr.bkup_tbl_id
      and  (pbn.per_in_ler_id     =  lcnr.per_in_ler_ended_id
           or  pbn.per_in_ler_id     =  lcnr.per_in_ler_id )
      and  pbn.prtt_enrt_rslt_id =  lcnr.bkup_tbl_id
      and  lcnr.effective_start_date between
           pbn.effective_start_date and pbn.effective_end_date;



  --
  -- The cursor gets the maximum effective end date for the enrollment
  -- result with past per_in_ler 's
  --
  -- Bug#2821279 : Removed the max functions and logic is based
  -- on order by clause.
  cursor c_pen_max_esd_of_past_pil(v_prtt_enrt_rslt_id in number) is
    select pen.effective_end_date,pen.object_version_number, pen.per_in_ler_id
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  prtt_enrt_rslt_id       =  v_prtt_enrt_rslt_id
    and    nvl(pen.per_in_ler_id , -1) <> p_per_in_ler_id
    and    pen.business_group_id   =  p_business_group_id
    and    pen.per_in_ler_id = pil.per_in_ler_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
    order by pen.effective_end_date desc;
  --
    --
    l_prev_per_in_ler_id             ben_prtt_enrt_rslt_f.per_in_ler_id%type;
    --
    -- CFW
  -- Move deleted records to backup table
  --
  cursor c_deleted_pen(v_prtt_enrt_rslt_id in number,
                       v_effective_date    in date) is
    select *
    from   ben_prtt_enrt_rslt_f
    where  prtt_enrt_rslt_id       =  v_prtt_enrt_rslt_id
    and    nvl(per_in_ler_id , -1) =  p_per_in_ler_id
    and    business_group_id   =  p_business_group_id
    and    effective_end_date      > v_effective_date;
   --
   -- Pbodla : Link between pen and epe needs to be stored as this
   -- information is required to restore the enrollment data as
   -- part of life event restoration.
   -- Get the epe info to store the link between epe and pen rows.
   --
   cursor c_epe(v_prtt_enrt_rslt_id in number, v_per_in_ler_id in number) is
     select epe.*
     from   ben_elig_per_elctbl_chc epe
     where  epe.prtt_enrt_rslt_id       =  v_prtt_enrt_rslt_id
     and    nvl(epe.per_in_ler_id , -1) =  nvl(v_per_in_ler_id, -1)
     and    epe.business_group_id   =  p_business_group_id;
   --
   l_epe      c_epe%rowtype;
   --
  --
  -- END ----> DELETE ROUTINE FOR BEN_PRTT_ENRT_RSLT_F
  --
  --
  -- START ----> DELETE ROUTINE FOR BEN_BNFT_PRVDD_LDGR_F
   cursor c_ben_bnft_prvdd_ldgr_f(p_bnft_prvdd_ldgr_id number) is
    select bpl.bnft_prvdd_ldgr_id,
           bpl.object_version_number,
           bpl.acty_base_rt_id,
           bpl.effective_end_date,
           bpl.effective_start_date,
           bpl.per_in_ler_id
    from   ben_bnft_prvdd_ldgr_f  bpl,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    bpl.per_in_ler_id = pil.per_in_ler_id
    and    bpl.business_group_id = pil.business_group_id
    --    # 2982606 added for result level backout
    --    # Bug 6376239 Instead of pen_id, check against bpl_id passed
    and   (p_bnft_prvdd_ldgr_id is null
           or p_bnft_prvdd_ldgr_id = bpl.bnft_prvdd_ldgr_id
          )
    --bug#3702090
    and   exists (select null from ben_prtt_enrt_rslt_f pen
                  where pen.prtt_enrt_rslt_id = bpl.prtt_enrt_rslt_id)
    order by 1;
    --
    l_bpl      c_ben_bnft_prvdd_ldgr_f%rowtype;
    --
    -- Bug 6376239
    cursor c_bpl_from_pen is
    select bpl.bnft_prvdd_ldgr_id
      from ben_bnft_prvdd_ldgr_f bpl, ben_prtt_rt_val prv
     where prv.prtt_enrt_rslt_id = p_bckdt_prtt_enrt_rslt_id
       and prv.acty_base_rt_id = bpl.acty_base_rt_id
       and bpl.per_in_ler_id = p_per_in_ler_id
       and prv.per_in_ler_id = bpl.per_in_ler_id
       and bpl.business_group_id = p_business_group_id
       and prv.business_group_id = p_business_group_id;
    prev_bnft_prvdd_ldgr_id number;
    -- End 6376239
    --
    -- Bug 5500864
    --
    CURSOR c_bpl_from_backup
    IS
       SELECT bpl.*
         FROM ben_le_clsn_n_rstr bpl
        WHERE bkup_tbl_typ_cd = 'BEN_BNFT_PRVDD_LDGR_F'
          AND per_in_ler_id = p_per_in_ler_id
          AND effective_end_date = hr_api.g_eot;
    --
    l_bpl_from_backup   c_bpl_from_backup%ROWTYPE;
    --
    -- Bug 5500864
    --
   -- Bug#2592783 - per_in_ler_stat_cd is checked
   -- Bug#2646851 - cursor modified with order by clause and max function removed
   cursor c_bpl_max_esd_of_past_pil(v_bnft_prvdd_ldgr_id in number) is
      select bpl.effective_end_date, bpl.object_version_number
      from   ben_bnft_prvdd_ldgr_f bpl,
             ben_per_in_ler pil
      where  bpl.bnft_prvdd_ldgr_id       =  v_bnft_prvdd_ldgr_id
      and    nvl(bpl.per_in_ler_id , -1) <> p_per_in_ler_id
      and    bpl.business_group_id   =  p_business_group_id
      and    bpl.per_in_ler_id = pil.per_in_ler_id
      and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
      order by bpl.effective_end_date desc;
  -- END   ---> DELETE ROUTINE FOR BEN_BNFT_PRVDD_LDGR_F

  -- START ----> DELETE ROUTINE FOR BEN_PIL_ELCTBL_CHC_POPL
  -- -- Source Table -- BEN_PER_IN_LER --
  cursor c_ben_pil_elctbl_chc_popl is
    select pel.pil_elctbl_chc_popl_id,
           pel.object_version_number
    from   ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pel.per_in_ler_id = pil.per_in_ler_id
    and    pel.business_group_id = pil.business_group_id;
  --
  -- END ----> DELETE ROUTINE FOR BEN_PIL_ELCTBL_CHC_POPL
  --
  -- BEN_CBR_QUALD_BNF
  --
  cursor c_get_cbr_quald_bnf is
    select cqb.*,crp.prvs_elig_perd_end_dt
    from   ben_cbr_quald_bnf cqb
          ,ben_cbr_per_in_ler crp
    where  cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
    and    cqb.business_group_id = p_business_group_id
    and    cqb.business_group_id = crp.business_group_id
    and    crp.per_in_ler_id = p_per_in_ler_id
    and    crp.init_evt_flag = 'N';

  -- PRTT_REIMBMT_RQST
  -- bug fix 2223214
  -- added a condition to ignore VOIDED participant reimbursement claims
  -- since it prevents backout
  --
  cursor c_prc is
    select prc.PRTT_REIMBMT_RQST_ID
          ,prc.OBJECT_VERSION_NUMBER
          ,prc.effective_start_date
          ,pil.person_id
    from  ben_prtt_reimbmt_rqst_f prc
         ,ben_prtt_rt_val prv
         ,ben_per_in_ler pil
    where prv.per_in_ler_id = p_per_in_ler_id
    and   prv.PRTT_REIMBMT_RQST_id = prc.PRTT_REIMBMT_RQST_id
    and   pil.per_in_ler_id = p_per_in_ler_id
    -- hnarayan -- bug 2223214
    and   prc.prtt_reimbmt_rqst_stat_cd not in ('VOIDED')
    --    # 2982606 added for result level backout
    and   (p_bckdt_prtt_enrt_rslt_id is null
           or p_bckdt_prtt_enrt_rslt_id = prc.prtt_enrt_rslt_id
          )
 ;
  --
  --
  -- Check existence of backup data
  --
  cursor c_bkp_row(cv_BKUP_TBL_TYP_CD in varchar2,
               cv_PER_IN_LER_ID   in number,
               cv_BKUP_TBL_ID     in number,
               cv_object_version_number in number) is
    select rowid
    from BEN_LE_CLSN_N_RSTR
    where BKUP_TBL_TYP_CD = cv_BKUP_TBL_TYP_CD
      and PER_IN_LER_ID   = cv_PER_IN_LER_ID
      and BKUP_TBL_ID     = cv_BKUP_TBL_ID
      and object_version_number = cv_object_version_number;

  --# bug 2546259 this cursor find the result voided by the LE

  cursor c_futur_pen is
  select pen.prtt_enrt_rslt_id  from  ben_prtt_enrt_rslt_f pen
  where per_in_ler_id = p_per_in_ler_id
    and pen.prtt_enrt_rslt_stat_cd = 'VOIDD'
    and pen.effective_start_date < pen.enrt_cvg_strt_dt
    /* Bug 9095753: When checking for future pen records check whether the enrollments of previous life event are end dated.
    If Open is the first LE,pen.effective_start_date < pen.enrt_cvg_strt_dt holds good for enrollment records that are VOIDD and tries to do delete future
    changes which raises APP-PAY-07187  error.So check whether enrolment records exists for previous LE*/
    and exists
             (select '1' from ben_prtt_enrt_rslt_f pen1,
	                      (select per_in_ler_id from ben_per_in_ler pil,
				      ben_ler_f ler
				      where pil.person_id = (select person_id
                                                            from ben_per_in_ler pil2
                                                            where pil2.per_in_ler_id=p_per_in_ler_id)
				      and pil.per_in_ler_id <> p_per_in_ler_id
				      and pil.ler_id = ler.ler_id
				      and p_effective_date between
					  ler.effective_start_date and ler.effective_end_date
				      and pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
				      and ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
				      and pil.lf_evt_ocrd_dt < (select lf_evt_ocrd_dt from
							       ben_per_in_ler pil1
							       where pil1.per_in_ler_id = p_per_in_ler_id)
				      order by per_in_ler_id desc) prev_pil
                where pen1.per_in_ler_id = prev_pil.per_in_ler_id
		      and pen1.effective_start_date < pen1.enrt_cvg_strt_dt
		      and pen1.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
	      );

 -- # bug 2546259 this cursor find the dpnt row end dated by the LE
  cursor c_futur_del_dpnt (v_prtt_enrt_rslt_id number) is
  select pdp.elig_cvrd_dpnt_id,
         pdp.object_version_number,
         pdp.effective_end_date
    from   ben_elig_cvrd_dpnt_f pdp
    where  pdp.effective_end_date  <>  hr_api.g_eot
    and    pdp.prtt_enrt_rslt_id  = v_prtt_enrt_rslt_id
    and    pdp.business_group_id = p_business_group_id
    order by 1;

  --
  cursor c_pay_proposal (cv_pay_proposal_id number) is
  select ppp.object_version_number
    from per_pay_proposals ppp
    where ppp.pay_proposal_id = cv_pay_proposal_id;
  --
  cursor c_pen_sus is
  select pen.prtt_enrt_rslt_id,
         pen.per_in_ler_id
    from ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil
   where pen.sspndd_flag = 'Y'
     and pen.per_in_ler_id <> pil.per_in_ler_id
     and pil.per_in_ler_id = p_per_in_ler_id
     and pen.person_id = pil.person_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and pen.effective_end_date = hr_api.g_eot
     and pen.enrt_cvg_thru_dt = hr_api.g_eot;
  l_pen_sus c_pen_sus%rowtype;


  l_salary_warning             boolean;
  l_salary_proposal_ovn        number;
  l_row_id                     rowid;
  --
  l_pk_id                      number;
  l_pil_id                     number;
  l_rt_end_dt                  date;
  l_person_id                  number;
  l_acty_base_rt_id            number;
  l_acty_ref_perd_cd           hr_lookups.lookup_code%TYPE; -- UTF8
  l_business_group_id          number;
  l_object_version_number      number;
  l_effective_start_date       date;
  l_effective_end_date         date;
  l_prtt_enrt_rslt_id          number;
  l_rslt_object_version_number number;
  l_effective_date             date;
  l_max_object_version_number  number;
  l_datetrack_mode             varchar2(80) := null;
  l_cm_object_version_number   number;
  l_lf_evt_ocrd_dt             date;
  l_per_in_ler_id              number;
  l_to_be_sent_date            date;
  l_child_left                 boolean;
  l_rt_strt_dt                 date;
  l_prv_prtt_enrt_rslt_id      number;
  l_ref_obj_pk_id              number;
  l_ref_obj_table_name         varchar2(100);
  l_pl_id                      number;
  l_oipl_id                    number;
  l_enrt_cvg_strt_dt           date;
  l_pen_eed                    date;
  l_pen_esd                    date;
  l_pen_pil_id                 number;
  l_enrt_cvg_thru_dt           date;
  l_prv_effective_date         date;
  l_prev_pk_id                 number;
  l_prc_rec                    c_prc%rowtype ;
  l_bpl_effective_date         date;
  l_dummy                      varchar2(1) ;
  l_prev_elig_cvrd_dpnt_id     number := 0;
  l_prev_bkup_tbl_id           number := 0;
  l_ended_per_in_ler_id        number;
  l_cvg_adj_effective_date date;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  hr_utility.set_location ('Start of '||p_routine,10);
  --
  -- check which routine we are calling
  --
  if p_routine = 'BEN_ELIG_CVRD_DPNT_F' then

    -- For dependents, we want to 'un-end' any dpnt records that were ENDED
    -- due to the per-in-ler.  The 'future-change' date track mode will do that
    -- for us.
    -- Other dpnts can be left alone because their FK to per-in-ler will indicate
    -- that they are really 'backed out'.

    l_prev_pk_id := -1; -- like null

    --
    open c_ben_elig_cvrd_dpnt_f;
      --
      loop
        --
        fetch c_ben_elig_cvrd_dpnt_f into l_pk_id,
                                          l_object_version_number,
																					-- bug 5668052
																					l_dpnt_eff_start_date;
        exit when c_ben_elig_cvrd_dpnt_f%notfound;
        --
        -- Get the maximum of effective end date for the dependents
        -- with past per_in_ler 's.
        --
        hr_utility.set_location ('with in loop  '||l_pk_id,10);
        --
        l_effective_date := null;

        open  c_pdp_max_esd_of_past_pil(l_pk_id);
        fetch c_pdp_max_esd_of_past_pil into l_effective_date,
                                             l_max_object_version_number;
        close c_pdp_max_esd_of_past_pil;
        --
        -- The group function "max" returns null when no records found,
        -- so check l_effective_date is null to find whether any
        -- past records were found.
        --
        --
        if l_effective_date is not null then

         --
         -- Do not process the row as it is already processed(deleted).
         --
         if l_prev_pk_id <> l_pk_id then

           -- now backup all the deleted enrollment rows
           --
           for l_deleted_pdp_rec in c_deleted_pdp(l_pk_id, l_effective_date)
           loop
              --
              open c_bkp_row('BEN_ELIG_CVRD_DPNT_F',
                             l_deleted_pdp_rec.per_in_ler_id,
                             l_deleted_pdp_rec.ELIG_CVRD_DPNT_ID,
                             l_deleted_pdp_rec.object_version_number);
              fetch c_bkp_row into l_row_id;
              --
              if c_bkp_row%notfound
              then
                  hr_utility.set_location ('backup notfound  '||l_effective_date,10);
                  --
                  close c_bkp_row;
                  --
                  insert into BEN_LE_CLSN_N_RSTR (
                     BKUP_TBL_TYP_CD,
                     CVG_STRT_DT,
                     CVG_THRU_DT,
                     CVG_PNDG_FLAG,
                     OVRDN_FLAG,
                     OVRDN_THRU_DT,
                     PRTT_ENRT_RSLT_ID,
                     DPNT_PERSON_ID,
                     PER_IN_LER_ID,
                     BUSINESS_GROUP_ID,
                     LCR_ATTRIBUTE_CATEGORY,
                     LCR_ATTRIBUTE1,
                     LCR_ATTRIBUTE2,
                     LCR_ATTRIBUTE3,
                     LCR_ATTRIBUTE4,
                     LCR_ATTRIBUTE5,
                     LCR_ATTRIBUTE6,
                     LCR_ATTRIBUTE7,
                     LCR_ATTRIBUTE8,
                     LCR_ATTRIBUTE9,
                     LCR_ATTRIBUTE10,
                     LCR_ATTRIBUTE11,
                     LCR_ATTRIBUTE12,
                     LCR_ATTRIBUTE13,
                     LCR_ATTRIBUTE14,
                     LCR_ATTRIBUTE15,
                     LCR_ATTRIBUTE16,
                     LCR_ATTRIBUTE17,
                     LCR_ATTRIBUTE18,
                     LCR_ATTRIBUTE19,
                     LCR_ATTRIBUTE20,
                     LCR_ATTRIBUTE21,
                     LCR_ATTRIBUTE22,
                     LCR_ATTRIBUTE23,
                     LCR_ATTRIBUTE24,
                     LCR_ATTRIBUTE25,
                     LCR_ATTRIBUTE26,
                     LCR_ATTRIBUTE27,
                     LCR_ATTRIBUTE28,
                     LCR_ATTRIBUTE29,
                     LCR_ATTRIBUTE30,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_LOGIN,
                     CREATED_BY,
                     CREATION_DATE,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE,
                     OBJECT_VERSION_NUMBER,
                     BKUP_TBL_ID,
                     EFFECTIVE_START_DATE,
                     EFFECTIVE_END_DATE)
                 values (
                     'BEN_ELIG_CVRD_DPNT_F',
                    l_deleted_pdp_rec.CVG_STRT_DT,
                    l_deleted_pdp_rec.CVG_THRU_DT,
                    l_deleted_pdp_rec.CVG_PNDG_FLAG,
                    l_deleted_pdp_rec.OVRDN_FLAG,
                    l_deleted_pdp_rec.OVRDN_THRU_DT,
                    l_deleted_pdp_rec.PRTT_ENRT_RSLT_ID,
                    l_deleted_pdp_rec.DPNT_PERSON_ID,
                    l_deleted_pdp_rec.PER_IN_LER_ID,
                    l_deleted_pdp_rec.BUSINESS_GROUP_ID,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE_CATEGORY,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE1,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE2,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE3,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE4,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE5,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE6,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE7,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE8,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE9,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE10,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE11,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE12,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE13,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE14,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE15,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE16,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE17,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE18,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE19,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE20,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE21,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE22,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE23,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE24,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE25,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE26,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE27,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE28,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE29,
                    l_deleted_pdp_rec.PDP_ATTRIBUTE30,
                    l_deleted_pdp_rec.LAST_UPDATE_DATE,
                    l_deleted_pdp_rec.LAST_UPDATED_BY,
                    l_deleted_pdp_rec.LAST_UPDATE_LOGIN,
                    l_deleted_pdp_rec.CREATED_BY,
                    l_deleted_pdp_rec.CREATION_DATE,
                    l_deleted_pdp_rec.REQUEST_ID,
                    l_deleted_pdp_rec.PROGRAM_APPLICATION_ID,
                    l_deleted_pdp_rec.PROGRAM_ID,
                    l_deleted_pdp_rec.PROGRAM_UPDATE_DATE,
                    l_deleted_pdp_rec.OBJECT_VERSION_NUMBER,
                    l_deleted_pdp_rec.ELIG_CVRD_DPNT_ID,
                    l_deleted_pdp_rec.EFFECTIVE_START_DATE,
                    l_deleted_pdp_rec.EFFECTIVE_END_DATE
                  );
                  --
              else
                  --
                  close c_bkp_row;
                  --
                  update BEN_LE_CLSN_N_RSTR set
                     -- BKUP_TBL_TYP_CD          = 'BEN_ELIG_CVRD_DPNT_F'
                     CVG_STRT_DT              = l_deleted_pdp_rec.CVG_STRT_DT,
                     CVG_THRU_DT              = l_deleted_pdp_rec.CVG_THRU_DT,
                     CVG_PNDG_FLAG            = l_deleted_pdp_rec.CVG_PNDG_FLAG,
                     OVRDN_FLAG               = l_deleted_pdp_rec.OVRDN_FLAG,
                     OVRDN_THRU_DT            = l_deleted_pdp_rec.OVRDN_THRU_DT,
                     PRTT_ENRT_RSLT_ID        = l_deleted_pdp_rec.PRTT_ENRT_RSLT_ID,
                     DPNT_PERSON_ID           = l_deleted_pdp_rec.DPNT_PERSON_ID,
                     -- PER_IN_LER_ID            = l_deleted_pdp_rec.PER_IN_LER_ID,
                     BUSINESS_GROUP_ID        = l_deleted_pdp_rec.BUSINESS_GROUP_ID,
                     LCR_ATTRIBUTE_CATEGORY   = l_deleted_pdp_rec.PDP_ATTRIBUTE_CATEGORY,
                     LCR_ATTRIBUTE1           = l_deleted_pdp_rec.PDP_ATTRIBUTE1,
                     LCR_ATTRIBUTE2           = l_deleted_pdp_rec.PDP_ATTRIBUTE2,
                     LCR_ATTRIBUTE3           = l_deleted_pdp_rec.PDP_ATTRIBUTE3,
                     LCR_ATTRIBUTE4           = l_deleted_pdp_rec.PDP_ATTRIBUTE4,
                     LCR_ATTRIBUTE5           = l_deleted_pdp_rec.PDP_ATTRIBUTE5,
                     LCR_ATTRIBUTE6           = l_deleted_pdp_rec.PDP_ATTRIBUTE6,
                     LCR_ATTRIBUTE7           = l_deleted_pdp_rec.PDP_ATTRIBUTE7,
                     LCR_ATTRIBUTE8           = l_deleted_pdp_rec.PDP_ATTRIBUTE8,
                     LCR_ATTRIBUTE9           = l_deleted_pdp_rec.PDP_ATTRIBUTE9,
                     LCR_ATTRIBUTE10          = l_deleted_pdp_rec.PDP_ATTRIBUTE10,
                     LCR_ATTRIBUTE11          = l_deleted_pdp_rec.PDP_ATTRIBUTE11,
                     LCR_ATTRIBUTE12          = l_deleted_pdp_rec.PDP_ATTRIBUTE12,
                     LCR_ATTRIBUTE13          = l_deleted_pdp_rec.PDP_ATTRIBUTE13,
                     LCR_ATTRIBUTE14          = l_deleted_pdp_rec.PDP_ATTRIBUTE14,
                     LCR_ATTRIBUTE15          = l_deleted_pdp_rec.PDP_ATTRIBUTE15,
                     LCR_ATTRIBUTE16          = l_deleted_pdp_rec.PDP_ATTRIBUTE16,
                     LCR_ATTRIBUTE17          = l_deleted_pdp_rec.PDP_ATTRIBUTE17,
                     LCR_ATTRIBUTE18          = l_deleted_pdp_rec.PDP_ATTRIBUTE18,
                     LCR_ATTRIBUTE19          = l_deleted_pdp_rec.PDP_ATTRIBUTE19,
                     LCR_ATTRIBUTE20          = l_deleted_pdp_rec.PDP_ATTRIBUTE20,
                     LCR_ATTRIBUTE21          = l_deleted_pdp_rec.PDP_ATTRIBUTE21,
                     LCR_ATTRIBUTE22          = l_deleted_pdp_rec.PDP_ATTRIBUTE22,
                     LCR_ATTRIBUTE23          = l_deleted_pdp_rec.PDP_ATTRIBUTE23,
                     LCR_ATTRIBUTE24          = l_deleted_pdp_rec.PDP_ATTRIBUTE24,
                     LCR_ATTRIBUTE25          = l_deleted_pdp_rec.PDP_ATTRIBUTE25,
                     LCR_ATTRIBUTE26          = l_deleted_pdp_rec.PDP_ATTRIBUTE26,
                     LCR_ATTRIBUTE27          = l_deleted_pdp_rec.PDP_ATTRIBUTE27,
                     LCR_ATTRIBUTE28          = l_deleted_pdp_rec.PDP_ATTRIBUTE28,
                     LCR_ATTRIBUTE29          = l_deleted_pdp_rec.PDP_ATTRIBUTE29,
                     LCR_ATTRIBUTE30          = l_deleted_pdp_rec.PDP_ATTRIBUTE30,
                     LAST_UPDATE_DATE         = l_deleted_pdp_rec.LAST_UPDATE_DATE,
                     LAST_UPDATED_BY          = l_deleted_pdp_rec.LAST_UPDATED_BY,
                     LAST_UPDATE_LOGIN        = l_deleted_pdp_rec.LAST_UPDATE_LOGIN,
                     CREATED_BY               = l_deleted_pdp_rec.CREATED_BY,
                     CREATION_DATE            = l_deleted_pdp_rec.CREATION_DATE,
                     REQUEST_ID               = l_deleted_pdp_rec.REQUEST_ID,
                     PROGRAM_APPLICATION_ID   = l_deleted_pdp_rec.PROGRAM_APPLICATION_ID,
                     PROGRAM_ID               = l_deleted_pdp_rec.PROGRAM_ID,
                     PROGRAM_UPDATE_DATE      = l_deleted_pdp_rec.PROGRAM_UPDATE_DATE,
                     -- OBJECT_VERSION_NUMBER    = l_deleted_pdp_rec.OBJECT_VERSION_NUMBER,
                     -- BKUP_TBL_ID              = l_deleted_pdp_rec.CVG_STRT_DT,
                     EFFECTIVE_START_DATE     = l_deleted_pdp_rec.EFFECTIVE_START_DATE,
                     EFFECTIVE_END_DATE       = l_deleted_pdp_rec.EFFECTIVE_END_DATE
                 where rowid = l_row_id;
              end if;
           end loop;
           --
           -- Past records exist. So datetrack mode FUTURE_CHANGE.
           --
           l_datetrack_mode := hr_api.g_future_change;
           l_object_version_number := l_max_object_version_number;
           --
           -- pass the real effective_date also
           --
           g_bolfe_effective_date:=p_effective_date;
           --
           -- Delete from the appropriate API.
           --
           if l_effective_date <> hr_api.g_eot and nvl(p_copy_only,'N') <>  'Y' then
             ben_elig_cvrd_dpnt_api.delete_elig_cvrd_dpnt
              (p_validate                => false,
               p_elig_cvrd_dpnt_id       => l_pk_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_object_version_number,
               p_business_group_id       => p_business_group_id,
               p_effective_date          => l_effective_date,
               p_datetrack_mode          => l_datetrack_mode,
               p_multi_row_actn          =>  false,
               p_called_from             => 'benbolfe');
           end if;
           --
           -- null out to prevent bleeding.
           -- also do this in the error handler.
           --
           g_bolfe_effective_date:=null;
           --
           l_prev_pk_id := l_pk_id;
           --
           end if; -- l_prev_pk_id <> l_pk_id
          -- bud 5668052
         else
				  hr_utility.set_location('Effective date is null ',121);
          BEN_ELIG_CVRD_DPNT_API.remove_usage(
					        p_validate              => FALSE
                 ,p_elig_cvrd_dpnt_id     => l_pk_id
                 ,p_cvg_thru_dt           => NULL
                 ,p_effective_date        => l_dpnt_eff_start_date
                 ,p_datetrack_mode        => hr_api.g_zap
                 );

        end if;
        --
      end loop;
      --
      --
      ---- # bug 2546259 when the PEN coverage is future dated and
      ---  deenreolled, the pen result is voided  and PDP result is
      ---  End dated in Delete mode, so no date track record is created
      ---  there is no relation between PIL and the end dated PDP is maintained
      ---  PDP does not have any status too
      ---- when the LE is backedout  the PDP is not reinstated becasue there is not
      ---- relation between PIL and the PDP record. This fix reinstate the PDP record
      ---- first cursor find all the result voided by the PIL and coverage is future dtd
      ---- Second cursor find the PDP record end dated for the result
      if   nvl(p_copy_only,'N') <>  'Y' then
        for l_f_pen  in  c_futur_pen  loop
           hr_utility.set_location ('with in future loop  '||l_f_pen.prtt_enrt_rslt_id,10);
           open c_futur_del_dpnt (l_f_pen.prtt_enrt_rslt_id ) ;
           Loop
              fetch c_futur_del_dpnt into l_pk_id,l_object_version_number,l_effective_date ;
              exit when c_futur_del_dpnt%notfound;


              l_datetrack_mode := hr_api.g_future_change;
               ben_elig_cvrd_dpnt_api.delete_elig_cvrd_dpnt
                 (p_validate                => false,
                  p_elig_cvrd_dpnt_id       => l_pk_id,
                  p_effective_start_date    => l_effective_start_date,
                  p_effective_end_date      => l_effective_end_date,
                  p_object_version_number   => l_object_version_number,
                  p_business_group_id       => p_business_group_id,
                  p_effective_date          => l_effective_date,
                  p_datetrack_mode          => l_datetrack_mode,
                  p_called_from             => 'benbolfe');


           end loop ;
           close c_futur_del_dpnt ;
        --

        end loop  ;
     end if ;

      ---- if any of the result in corrected and stored in backp table for correction
      ---- correct the per_in_ler_id of related the dpnt table too  bug # 3086161

      for i in c_BEN_LE_CLSN_N_RSTR_dpnt(p_per_in_ler_id )
      Loop
          if l_prev_elig_cvrd_dpnt_id <> i.elig_cvrd_dpnt_id then
               l_object_version_number := i.object_version_number ;
                 hr_utility.set_location(' correcting  ' || i.elig_cvrd_dpnt_id, 999 );
               ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
                  (p_validate                => FALSE
                  ,p_business_group_id       => p_business_group_id
                  ,p_elig_cvrd_dpnt_id       => i.elig_cvrd_dpnt_id
                  ,p_effective_start_date    => l_effective_start_date
                  ,p_effective_end_date      => l_effective_end_date
                  ,p_cvg_thru_dt             => i.enrt_cvg_thru_dt
                  ,p_per_in_ler_id           => i.per_in_ler_id
                  ,p_object_version_number   => l_object_version_number
                  ,p_effective_date          => i.effective_start_date
                  ,p_datetrack_mode          => hr_api.g_correction
                  ,p_multi_row_actn          => FALSE);
           l_prev_elig_cvrd_dpnt_id := i.elig_cvrd_dpnt_id;
               --
               --  Correct the effective end date.  7197868
               --
               if (i.bkp_effective_end_date =  hr_api.g_eot
                   and i.effective_end_date <> i.bkp_effective_end_date) then
                 --
                 --  Delete future dated rows.
                 --
                 ben_elig_cvrd_dpnt_api.delete_elig_cvrd_dpnt
                   (p_validate                => false,
                    p_elig_cvrd_dpnt_id       => i.elig_cvrd_dpnt_id,
                    p_effective_start_date    => l_effective_start_date,
                    p_effective_end_date      => l_effective_end_date,
                    p_object_version_number   => l_object_version_number,
                    p_business_group_id       => p_business_group_id,
                    p_effective_date          => i.bkp_effective_start_date,
                    p_datetrack_mode          => hr_api.g_future_change,
                    p_called_from             => 'benbolfe');
               end if;
                 --
                 --   End 7197868
                 --
          end if;
      --


      end loop ;



      l_prev_pk_id := -1;
      --

    close c_ben_elig_cvrd_dpnt_f;
    --
  elsif p_routine = 'BEN_ELIG_PER_F' then

    -- For elig_per, we want to 'un-end' any records that were ENDED
    -- due to the per-in-ler.  The 'future-change' date track mode will do that
    -- for us.
    -- Others can be left alone because their FK to per-in-ler will indicate
    -- that they are really 'backed out'.

    l_prev_pk_id := -1; -- like null

    --
    open c_ben_elig_per_f;
      --
      loop
        --
        fetch c_ben_elig_per_f into l_pk_id,
                                          l_object_version_number;
        exit when c_ben_elig_per_f%notfound;
        --
        -- Get the maximum of effective end date
        -- with past per_in_ler 's.
        --
        l_effective_date := null;
        open  c_pep_max_esd_of_past_pil(l_pk_id);
        fetch c_pep_max_esd_of_past_pil into l_effective_date,
                                             l_max_object_version_number;
        close c_pep_max_esd_of_past_pil;
        --
        -- The group function "max" returns null when no records found,
        -- so check l_effective_date is null to find whether any
        -- past records were found.
        --
        --
        if l_effective_date is not null then

         --
         -- Do not process the row as it is already processed(deleted).
         --
         if l_prev_pk_id <> l_pk_id then
           --
           -- Bug 1814166 : Causing primary key violation
           -- Commented as the data is not used by benleclr.pkb
           --
           null;
           --
           /*
           -- now backup all the deleted enrollment rows
           --
           for l_deleted_pep_rec in c_deleted_pep(l_pk_id, l_effective_date)
           loop
             --
              insert into BEN_LE_CLSN_N_RSTR (
                  BKUP_TBL_TYP_CD,
                  PLIP_ID,
                  PTIP_ID,
                  WAIT_PERD_CMPLTN_DT,
                  PER_IN_LER_ID,
                  RT_FRZ_PCT_FL_TM_FLAG,
                  RT_FRZ_HRS_WKD_FLAG,
                  RT_FRZ_COMB_AGE_AND_LOS_FLAG,
                  ONCE_R_CNTUG_CD,
                  BKUP_TBL_ID,         -- ELIG_PER_ID,
                  EFFECTIVE_START_DATE,
                  EFFECTIVE_END_DATE,
                  BUSINESS_GROUP_ID,
                  PL_ID,
                  PGM_ID,
                  LER_ID,
                  PERSON_ID,
                  DPNT_OTHR_PL_CVRD_RL_FLAG,
                  PRTN_OVRIDN_THRU_DT,
                  PL_KEY_EE_FLAG,
                  PL_HGHLY_COMPD_FLAG,
                  ELIG_FLAG,
                  COMP_REF_AMT,
                  CMBN_AGE_N_LOS_VAL,
                  COMP_REF_UOM,
                  AGE_VAL,
                  LOS_VAL,
                  PRTN_END_DT,
                  PRTN_STRT_DT,
                  WV_CTFN_TYP_CD,
                  HRS_WKD_VAL,
                  HRS_WKD_BNDRY_PERD_CD,
                  PRTN_OVRIDN_FLAG,
                  NO_MX_PRTN_OVRID_THRU_FLAG,
                  PRTN_OVRIDN_RSN_CD,
                  AGE_UOM,
                  LOS_UOM,
                  OVRID_SVC_DT,
                  FRZ_LOS_FLAG,
                  FRZ_AGE_FLAG,
                  FRZ_CMP_LVL_FLAG,
                  FRZ_PCT_FL_TM_FLAG,
                  FRZ_HRS_WKD_FLAG,
                  FRZ_COMB_AGE_AND_LOS_FLAG,
                  DSTR_RSTCN_FLAG,
                  PCT_FL_TM_VAL,
                  WV_PRTN_RSN_CD,
                  PL_WVD_FLAG,
                  LCR_ATTRIBUTE_CATEGORY,
                  LCR_ATTRIBUTE1,
                  LCR_ATTRIBUTE2,
                  LCR_ATTRIBUTE3,
                  LCR_ATTRIBUTE4,
                  LCR_ATTRIBUTE5,
                  LCR_ATTRIBUTE6,
                  LCR_ATTRIBUTE7,
                  LCR_ATTRIBUTE8,
                  LCR_ATTRIBUTE9,
                  LCR_ATTRIBUTE10,
                  LCR_ATTRIBUTE11,
                  LCR_ATTRIBUTE12,
                  LCR_ATTRIBUTE13,
                  LCR_ATTRIBUTE14,
                  LCR_ATTRIBUTE15,
                  LCR_ATTRIBUTE16,
                  LCR_ATTRIBUTE17,
                  LCR_ATTRIBUTE18,
                  LCR_ATTRIBUTE19,
                  LCR_ATTRIBUTE20,
                  LCR_ATTRIBUTE21,
                  LCR_ATTRIBUTE22,
                  LCR_ATTRIBUTE23,
                  LCR_ATTRIBUTE24,
                  LCR_ATTRIBUTE25,
                  LCR_ATTRIBUTE26,
                  LCR_ATTRIBUTE27,
                  LCR_ATTRIBUTE28,
                  LCR_ATTRIBUTE29,
                  LCR_ATTRIBUTE30,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN,
                  CREATED_BY,
                  CREATION_DATE,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE,
                  OBJECT_VERSION_NUMBER,
                  MUST_ENRL_ANTHR_PL_ID,
                  RT_COMP_REF_AMT,
                  RT_CMBN_AGE_N_LOS_VAL,
                  RT_COMP_REF_UOM,
                  RT_AGE_VAL,
                  RT_LOS_VAL,
                  RT_HRS_WKD_VAL,
                  RT_HRS_WKD_BNDRY_PERD_CD,
                  RT_AGE_UOM,
                  RT_LOS_UOM,
                  RT_PCT_FL_TM_VAL,
                  RT_FRZ_LOS_FLAG,
                  RT_FRZ_AGE_FLAG,
                  RT_FRZ_CMP_LVL_FLAG,
                  INELG_RSN_CD,
                  PL_ORDR_NUM,
                  PLIP_ORDR_NUM,
                  PTIP_ORDR_NUM  )
              values (
                 'BEN_ELIG_PER_F',
                 l_deleted_pep_rec.PLIP_ID,
                 l_deleted_pep_rec.PTIP_ID,
                 l_deleted_pep_rec.WAIT_PERD_CMPLTN_DT,
                 l_deleted_pep_rec.PER_IN_LER_ID,
                 l_deleted_pep_rec.RT_FRZ_PCT_FL_TM_FLAG,
                 l_deleted_pep_rec.RT_FRZ_HRS_WKD_FLAG,
                 l_deleted_pep_rec.RT_FRZ_COMB_AGE_AND_LOS_FLAG,
                 l_deleted_pep_rec.ONCE_R_CNTUG_CD,
                 l_deleted_pep_rec.ELIG_PER_ID,
                 l_deleted_pep_rec.EFFECTIVE_START_DATE,
                 l_deleted_pep_rec.EFFECTIVE_END_DATE,
                 l_deleted_pep_rec.BUSINESS_GROUP_ID,
                 l_deleted_pep_rec.PL_ID,
                 l_deleted_pep_rec.PGM_ID,
                 l_deleted_pep_rec.LER_ID,
                 l_deleted_pep_rec.PERSON_ID,
                 l_deleted_pep_rec.DPNT_OTHR_PL_CVRD_RL_FLAG,
                 l_deleted_pep_rec.PRTN_OVRIDN_THRU_DT,
                 l_deleted_pep_rec.PL_KEY_EE_FLAG,
                 l_deleted_pep_rec.PL_HGHLY_COMPD_FLAG,
                 l_deleted_pep_rec.ELIG_FLAG,
                 l_deleted_pep_rec.COMP_REF_AMT,
                 l_deleted_pep_rec.CMBN_AGE_N_LOS_VAL,
                 l_deleted_pep_rec.COMP_REF_UOM,
                 l_deleted_pep_rec.AGE_VAL,
                 l_deleted_pep_rec.LOS_VAL,
                 l_deleted_pep_rec.PRTN_END_DT,
                 l_deleted_pep_rec.PRTN_STRT_DT,
                 l_deleted_pep_rec.WV_CTFN_TYP_CD,
                 l_deleted_pep_rec.HRS_WKD_VAL,
                 l_deleted_pep_rec.HRS_WKD_BNDRY_PERD_CD,
                 l_deleted_pep_rec.PRTN_OVRIDN_FLAG,
                 l_deleted_pep_rec.NO_MX_PRTN_OVRID_THRU_FLAG,
                 l_deleted_pep_rec.PRTN_OVRIDN_RSN_CD,
                 l_deleted_pep_rec.AGE_UOM,
                 l_deleted_pep_rec.LOS_UOM,
                 l_deleted_pep_rec.OVRID_SVC_DT,
                 l_deleted_pep_rec.FRZ_LOS_FLAG,
                 l_deleted_pep_rec.FRZ_AGE_FLAG,
                 l_deleted_pep_rec.FRZ_CMP_LVL_FLAG,
                 l_deleted_pep_rec.FRZ_PCT_FL_TM_FLAG,
                 l_deleted_pep_rec.FRZ_HRS_WKD_FLAG,
                 l_deleted_pep_rec.FRZ_COMB_AGE_AND_LOS_FLAG,
                 l_deleted_pep_rec.DSTR_RSTCN_FLAG,
                 l_deleted_pep_rec.PCT_FL_TM_VAL,
                 l_deleted_pep_rec.WV_PRTN_RSN_CD,
                 l_deleted_pep_rec.PL_WVD_FLAG,
                 l_deleted_pep_rec.PEP_ATTRIBUTE_CATEGORY,
                 l_deleted_pep_rec.PEP_ATTRIBUTE1,
                 l_deleted_pep_rec.PEP_ATTRIBUTE2,
                 l_deleted_pep_rec.PEP_ATTRIBUTE3,
                 l_deleted_pep_rec.PEP_ATTRIBUTE4,
                 l_deleted_pep_rec.PEP_ATTRIBUTE5,
                 l_deleted_pep_rec.PEP_ATTRIBUTE6,
                 l_deleted_pep_rec.PEP_ATTRIBUTE7,
                 l_deleted_pep_rec.PEP_ATTRIBUTE8,
                 l_deleted_pep_rec.PEP_ATTRIBUTE9,
                 l_deleted_pep_rec.PEP_ATTRIBUTE10,
                 l_deleted_pep_rec.PEP_ATTRIBUTE11,
                 l_deleted_pep_rec.PEP_ATTRIBUTE12,
                 l_deleted_pep_rec.PEP_ATTRIBUTE13,
                 l_deleted_pep_rec.PEP_ATTRIBUTE14,
                 l_deleted_pep_rec.PEP_ATTRIBUTE15,
                 l_deleted_pep_rec.PEP_ATTRIBUTE16,
                 l_deleted_pep_rec.PEP_ATTRIBUTE17,
                 l_deleted_pep_rec.PEP_ATTRIBUTE18,
                 l_deleted_pep_rec.PEP_ATTRIBUTE19,
                 l_deleted_pep_rec.PEP_ATTRIBUTE20,
                 l_deleted_pep_rec.PEP_ATTRIBUTE21,
                 l_deleted_pep_rec.PEP_ATTRIBUTE22,
                 l_deleted_pep_rec.PEP_ATTRIBUTE23,
                 l_deleted_pep_rec.PEP_ATTRIBUTE24,
                 l_deleted_pep_rec.PEP_ATTRIBUTE25,
                 l_deleted_pep_rec.PEP_ATTRIBUTE26,
                 l_deleted_pep_rec.PEP_ATTRIBUTE27,
                 l_deleted_pep_rec.PEP_ATTRIBUTE28,
                 l_deleted_pep_rec.PEP_ATTRIBUTE29,
                 l_deleted_pep_rec.PEP_ATTRIBUTE30,
                 l_deleted_pep_rec.LAST_UPDATE_DATE,
                 l_deleted_pep_rec.LAST_UPDATED_BY,
                 l_deleted_pep_rec.LAST_UPDATE_LOGIN,
                 l_deleted_pep_rec.CREATED_BY,
                 l_deleted_pep_rec.CREATION_DATE,
                 l_deleted_pep_rec.REQUEST_ID,
                 l_deleted_pep_rec.PROGRAM_APPLICATION_ID,
                 l_deleted_pep_rec.PROGRAM_ID,
                 l_deleted_pep_rec.PROGRAM_UPDATE_DATE,
                 l_deleted_pep_rec.OBJECT_VERSION_NUMBER,
                 l_deleted_pep_rec.MUST_ENRL_ANTHR_PL_ID,
                 l_deleted_pep_rec.RT_COMP_REF_AMT,
                 l_deleted_pep_rec.RT_CMBN_AGE_N_LOS_VAL,
                 l_deleted_pep_rec.RT_COMP_REF_UOM,
                 l_deleted_pep_rec.RT_AGE_VAL,
                 l_deleted_pep_rec.RT_LOS_VAL,
                 l_deleted_pep_rec.RT_HRS_WKD_VAL,
                 l_deleted_pep_rec.RT_HRS_WKD_BNDRY_PERD_CD,
                 l_deleted_pep_rec.RT_AGE_UOM,
                 l_deleted_pep_rec.RT_LOS_UOM,
                 l_deleted_pep_rec.RT_PCT_FL_TM_VAL,
                 l_deleted_pep_rec.RT_FRZ_LOS_FLAG,
                 l_deleted_pep_rec.RT_FRZ_AGE_FLAG,
                 l_deleted_pep_rec.RT_FRZ_CMP_LVL_FLAG,
                 l_deleted_pep_rec.INELG_RSN_CD,
                 l_deleted_pep_rec.PL_ORDR_NUM,
                 l_deleted_pep_rec.PLIP_ORDR_NUM,
                 l_deleted_pep_rec.PTIP_ORDR_NUM
               );

             --
           end loop;
           */
           --
           -- Past records exist. So datetrack mode FUTURE_CHANGE.
           --
           l_datetrack_mode := hr_api.g_delete_next_change;
           l_object_version_number := l_max_object_version_number;
          --
          -- Delete from the appropriate API.
          --
          if l_effective_date <> hr_api.g_eot  and nvl(p_copy_only,'N') <>  'Y'  then
            ben_eligible_person_api.delete_eligible_person
              (p_validate                => false,
               p_elig_per_id       => l_pk_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_object_version_number,
               p_effective_date          => l_effective_date,
               p_datetrack_mode          => l_datetrack_mode);
          end if;
          --
          l_prev_pk_id := l_pk_id;
          --
         end if; -- l_prev_pk_id <> l_pk_id

        end if;
        --
      end loop;
      --
      --
      l_prev_pk_id := -1;
      --

    close c_ben_elig_per_f;
    --
  elsif p_routine = 'BEN_ELIG_PER_OPT_F'
  then
    -- we want to 'un-end' any records that were ENDED
    -- due to the per-in-ler.  The 'future-change' date track mode will do that
    -- for us.
    -- Others can be left alone because their FK to per-in-ler will indicate
    -- that they are really 'backed out'.

    l_prev_pk_id := -1; -- like null

    --
    open c_ben_elig_per_opt_f;
      --
      loop
        --
        fetch c_ben_elig_per_opt_f into l_pk_id,
                                          l_object_version_number;
        exit when c_ben_elig_per_opt_f%notfound;
        --
        -- Get the maximum of effective end date for the dependents
        -- with past per_in_ler 's.
        --
        l_effective_date := null;
        open  c_epo_max_esd_of_past_pil(l_pk_id);
        fetch c_epo_max_esd_of_past_pil into l_effective_date,
                                             l_max_object_version_number;
        close c_epo_max_esd_of_past_pil;
        --
        -- The group function "max" returns null when no records found,
        -- so check l_effective_date is null to find whether any
        -- past records were found.
        --
        --
        if l_effective_date is not null then
         --
         -- Do not process the row as it is already processed(deleted).
         --
         if l_prev_pk_id <> l_pk_id then
           --
           -- Bug 1814166 : Causing primary key violation
           -- Commented as the data is not used by benleclr.pkb
           --
           null;
           --
           /*
           -- now backup all the to be deleted enrollment rows
           --
           for l_deleted_epo_rec in c_deleted_epo(l_pk_id, l_effective_date)
           loop
             --
             insert into BEN_LE_CLSN_N_RSTR (
                 BKUP_TBL_TYP_CD,
                 INELG_RSN_CD,
                 PER_IN_LER_ID,
                 AGE_UOM,
                 LOS_UOM,
                 FRZ_LOS_FLAG,
                 FRZ_AGE_FLAG,
                 FRZ_CMP_LVL_FLAG,
                 FRZ_PCT_FL_TM_FLAG,
                 FRZ_HRS_WKD_FLAG,
                 FRZ_COMB_AGE_AND_LOS_FLAG,
                 OVRID_SVC_DT,
                 WAIT_PERD_CMPLTN_DT,
                 COMP_REF_AMT,
                 CMBN_AGE_N_LOS_VAL,
                 COMP_REF_UOM,
                 AGE_VAL,
                 LOS_VAL,
                 HRS_WKD_VAL,
                 HRS_WKD_BNDRY_PERD_CD,
                 RT_COMP_REF_AMT,
                 RT_CMBN_AGE_N_LOS_VAL,
                 RT_COMP_REF_UOM,
                 RT_AGE_VAL,
                 RT_LOS_VAL,
                 RT_HRS_WKD_VAL,
                 RT_HRS_WKD_BNDRY_PERD_CD,
                 RT_AGE_UOM,
                 RT_LOS_UOM,
                 RT_PCT_FL_TM_VAL,
                 RT_FRZ_LOS_FLAG,
                 RT_FRZ_AGE_FLAG,
                 RT_FRZ_CMP_LVL_FLAG,
                 RT_FRZ_PCT_FL_TM_FLAG,
                 RT_FRZ_HRS_WKD_FLAG,
                 RT_FRZ_COMB_AGE_AND_LOS_FLAG,
                 BKUP_TBL_ID,   -- ELIG_PER_OPT_ID,
                 ELIG_PER_ID,
                 EFFECTIVE_START_DATE,
                 EFFECTIVE_END_DATE,
                 PRTN_OVRIDN_FLAG,
                 PRTN_OVRIDN_THRU_DT,
                 NO_MX_PRTN_OVRID_THRU_FLAG,
                 ELIG_FLAG,
                 PRTN_STRT_DT,
                 PRTN_OVRIDN_RSN_CD,
                 PCT_FL_TM_VAL,
                 OPT_ID,
                 BUSINESS_GROUP_ID,
                 LCR_ATTRIBUTE_CATEGORY,
                 LCR_ATTRIBUTE1,
                 LCR_ATTRIBUTE2,
                 LCR_ATTRIBUTE3,
                 LCR_ATTRIBUTE4,
                 LCR_ATTRIBUTE5,
                 LCR_ATTRIBUTE6,
                 LCR_ATTRIBUTE7,
                 LCR_ATTRIBUTE8,
                 LCR_ATTRIBUTE9,
                 LCR_ATTRIBUTE10,
                 LCR_ATTRIBUTE11,
                 LCR_ATTRIBUTE12,
                 LCR_ATTRIBUTE13,
                 LCR_ATTRIBUTE14,
                 LCR_ATTRIBUTE15,
                 LCR_ATTRIBUTE16,
                 LCR_ATTRIBUTE17,
                 LCR_ATTRIBUTE18,
                 LCR_ATTRIBUTE19,
                 LCR_ATTRIBUTE20,
                 LCR_ATTRIBUTE21,
                 LCR_ATTRIBUTE22,
                 LCR_ATTRIBUTE23,
                 LCR_ATTRIBUTE24,
                 LCR_ATTRIBUTE25,
                 LCR_ATTRIBUTE26,
                 LCR_ATTRIBUTE27,
                 LCR_ATTRIBUTE28,
                 LCR_ATTRIBUTE29,
                 LCR_ATTRIBUTE30,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATED_BY,
                 CREATION_DATE,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 OBJECT_VERSION_NUMBER,
                 ONCE_R_CNTUG_CD,
                 OIPL_ORDR_NUM,
                 PRTN_END_DT  )
             values (
                'BEN_ELIG_PER_OPT_F',
                l_deleted_epo_rec.INELG_RSN_CD,
                l_deleted_epo_rec.PER_IN_LER_ID,
                l_deleted_epo_rec.AGE_UOM,
                l_deleted_epo_rec.LOS_UOM,
                l_deleted_epo_rec.FRZ_LOS_FLAG,
                l_deleted_epo_rec.FRZ_AGE_FLAG,
                l_deleted_epo_rec.FRZ_CMP_LVL_FLAG,
                l_deleted_epo_rec.FRZ_PCT_FL_TM_FLAG,
                l_deleted_epo_rec.FRZ_HRS_WKD_FLAG,
                l_deleted_epo_rec.FRZ_COMB_AGE_AND_LOS_FLAG,
                l_deleted_epo_rec.OVRID_SVC_DT,
                l_deleted_epo_rec.WAIT_PERD_CMPLTN_DATE,
                l_deleted_epo_rec.COMP_REF_AMT,
                l_deleted_epo_rec.CMBN_AGE_N_LOS_VAL,
                l_deleted_epo_rec.COMP_REF_UOM,
                l_deleted_epo_rec.AGE_VAL,
                l_deleted_epo_rec.LOS_VAL,
                l_deleted_epo_rec.HRS_WKD_VAL,
                l_deleted_epo_rec.HRS_WKD_BNDRY_PERD_CD,
                l_deleted_epo_rec.RT_COMP_REF_AMT,
                l_deleted_epo_rec.RT_CMBN_AGE_N_LOS_VAL,
                l_deleted_epo_rec.RT_COMP_REF_UOM,
                l_deleted_epo_rec.RT_AGE_VAL,
                l_deleted_epo_rec.RT_LOS_VAL,
                l_deleted_epo_rec.RT_HRS_WKD_VAL,
                l_deleted_epo_rec.RT_HRS_WKD_BNDRY_PERD_CD,
                l_deleted_epo_rec.RT_AGE_UOM,
                l_deleted_epo_rec.RT_LOS_UOM,
                l_deleted_epo_rec.RT_PCT_FL_TM_VAL,
                l_deleted_epo_rec.RT_FRZ_LOS_FLAG,
                l_deleted_epo_rec.RT_FRZ_AGE_FLAG,
                l_deleted_epo_rec.RT_FRZ_CMP_LVL_FLAG,
                l_deleted_epo_rec.RT_FRZ_PCT_FL_TM_FLAG,
                l_deleted_epo_rec.RT_FRZ_HRS_WKD_FLAG,
                l_deleted_epo_rec.RT_FRZ_COMB_AGE_AND_LOS_FLAG,
                l_deleted_epo_rec.ELIG_PER_OPT_ID,
                l_deleted_epo_rec.ELIG_PER_ID,
                l_deleted_epo_rec.EFFECTIVE_START_DATE,
                l_deleted_epo_rec.EFFECTIVE_END_DATE,
                l_deleted_epo_rec.PRTN_OVRIDN_FLAG,
                l_deleted_epo_rec.PRTN_OVRIDN_THRU_DT,
                l_deleted_epo_rec.NO_MX_PRTN_OVRID_THRU_FLAG,
                l_deleted_epo_rec.ELIG_FLAG,
                l_deleted_epo_rec.PRTN_STRT_DT,
                l_deleted_epo_rec.PRTN_OVRIDN_RSN_CD,
                l_deleted_epo_rec.PCT_FL_TM_VAL,
                l_deleted_epo_rec.OPT_ID,
                l_deleted_epo_rec.BUSINESS_GROUP_ID,
                l_deleted_epo_rec.EPO_ATTRIBUTE_CATEGORY,
                l_deleted_epo_rec.EPO_ATTRIBUTE1,
                l_deleted_epo_rec.EPO_ATTRIBUTE2,
                l_deleted_epo_rec.EPO_ATTRIBUTE3,
                l_deleted_epo_rec.EPO_ATTRIBUTE4,
                l_deleted_epo_rec.EPO_ATTRIBUTE5,
                l_deleted_epo_rec.EPO_ATTRIBUTE6,
                l_deleted_epo_rec.EPO_ATTRIBUTE7,
                l_deleted_epo_rec.EPO_ATTRIBUTE8,
                l_deleted_epo_rec.EPO_ATTRIBUTE9,
                l_deleted_epo_rec.EPO_ATTRIBUTE10,
                l_deleted_epo_rec.EPO_ATTRIBUTE11,
                l_deleted_epo_rec.EPO_ATTRIBUTE12,
                l_deleted_epo_rec.EPO_ATTRIBUTE13,
                l_deleted_epo_rec.EPO_ATTRIBUTE14,
                l_deleted_epo_rec.EPO_ATTRIBUTE15,
                l_deleted_epo_rec.EPO_ATTRIBUTE16,
                l_deleted_epo_rec.EPO_ATTRIBUTE17,
                l_deleted_epo_rec.EPO_ATTRIBUTE18,
                l_deleted_epo_rec.EPO_ATTRIBUTE19,
                l_deleted_epo_rec.EPO_ATTRIBUTE20,
                l_deleted_epo_rec.EPO_ATTRIBUTE21,
                l_deleted_epo_rec.EPO_ATTRIBUTE22,
                l_deleted_epo_rec.EPO_ATTRIBUTE23,
                l_deleted_epo_rec.EPO_ATTRIBUTE24,
                l_deleted_epo_rec.EPO_ATTRIBUTE25,
                l_deleted_epo_rec.EPO_ATTRIBUTE26,
                l_deleted_epo_rec.EPO_ATTRIBUTE27,
                l_deleted_epo_rec.EPO_ATTRIBUTE28,
                l_deleted_epo_rec.EPO_ATTRIBUTE29,
                l_deleted_epo_rec.EPO_ATTRIBUTE30,
                l_deleted_epo_rec.LAST_UPDATE_DATE,
                l_deleted_epo_rec.LAST_UPDATED_BY,
                l_deleted_epo_rec.LAST_UPDATE_LOGIN,
                l_deleted_epo_rec.CREATED_BY,
                l_deleted_epo_rec.CREATION_DATE,
                l_deleted_epo_rec.REQUEST_ID,
                l_deleted_epo_rec.PROGRAM_APPLICATION_ID,
                l_deleted_epo_rec.PROGRAM_ID,
                l_deleted_epo_rec.PROGRAM_UPDATE_DATE,
                l_deleted_epo_rec.OBJECT_VERSION_NUMBER,
                l_deleted_epo_rec.ONCE_R_CNTUG_CD,
                l_deleted_epo_rec.OIPL_ORDR_NUM,
                l_deleted_epo_rec.PRTN_END_DT
             );
             --
           end loop;
           */
           --
           -- Past records exist. So datetrack mode FUTURE_CHANGE.
           --
           l_datetrack_mode := hr_api.g_future_change;
           l_object_version_number := l_max_object_version_number;
          --
          -- Delete from the appropriate API.
          --
          if l_effective_date <> hr_api.g_eot  and nvl(p_copy_only,'N') <>  'Y'  then
            ben_elig_person_option_api.delete_elig_person_option
              (p_validate                => false,
               p_elig_per_opt_id       => l_pk_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_object_version_number,
               p_effective_date          => l_effective_date,
               p_datetrack_mode          => l_datetrack_mode);
          end if;
          --
          l_prev_pk_id := l_pk_id;
          --

         end if; -- l_prev_pk_id <> l_pk_id

        end if;
        --
      end loop;
      --
      l_prev_pk_id := -1;
      --

    close c_ben_elig_per_opt_f;
    --
  elsif p_routine = 'BEN_PRTT_PREM_F' then
    -------------Bug 7133998
    for l_prtt_prem_corr in c_ben_prtt_prem_f_corr loop
      hr_utility.set_location('l_prtt_prem_corr.PRTT_PREM_ID : '||l_prtt_prem_corr.PRTT_PREM_ID,1);
      hr_utility.set_location('ESD : '||l_prtt_prem_corr.effective_start_date,1);
      hr_utility.set_location('EED : '||l_prtt_prem_corr.effective_end_date,1);
      for l_bkp_prem_row in c_bkp_prem_row('BEN_PRTT_PREM_F_CORR',
                             l_prtt_prem_corr.PRTT_PREM_ID,
                             l_prtt_prem_corr.effective_start_date,
			     l_prtt_prem_corr.effective_end_date) loop
	  hr_utility.set_location('ESD,in loop : '||l_prtt_prem_corr.effective_start_date,1);
          ben_prtt_prem_api.update_prtt_prem
                ( p_validate                => FALSE
                 ,p_prtt_prem_id            => l_prtt_prem_corr.prtt_prem_id
                 ,p_effective_start_date    => l_effective_start_date
                 ,p_effective_end_date      => l_effective_end_date
                 ,p_per_in_ler_id           => l_bkp_prem_row.per_in_ler_id
                 ,p_business_group_id       => l_prtt_prem_corr.business_group_id
                 ,p_object_version_number   => l_prtt_prem_corr.object_version_number
		 ,p_prtt_enrt_rslt_id       => l_bkp_prem_row.PRTT_ENRT_RSLT_ID
                 ,p_request_id              => fnd_global.conc_request_id
                 ,p_program_application_id  => fnd_global.prog_appl_id
                 ,p_program_id              => fnd_global.conc_program_id
                 ,p_program_update_date     => sysdate
                 ,p_effective_date           => l_prtt_prem_corr.effective_start_date
                 ,p_datetrack_mode          => 'CORRECTION'

             );
	   --delete the rows from back-up table once the record is restored
	   delete from ben_le_clsn_n_rstr cls
	     where  rowid = l_bkp_prem_row.rowid;
      end loop;
     end loop;
  -----------7133998
    -- we want to 'un-end' any records that were ENDED
    -- due to the per-in-ler.  The 'future-change' date track mode will do that
    -- for us.
    -- Others can be left alone because their FK to per-in-ler will indicate
    -- that they are really 'backed out'.

    l_prev_pk_id := -1; -- like null

    --
    open c_ben_prtt_prem_f;
      --
      loop
        --
        fetch c_ben_prtt_prem_f into l_pk_id,
                                          l_object_version_number;
        exit when c_ben_prtt_prem_f%notfound;
        --
        -- Get the maximum of effective end date for the dependents
        -- with past per_in_ler 's.
        --
        l_effective_date := null;
        open  c_ppe_max_esd_of_past_pil(l_pk_id);
        fetch c_ppe_max_esd_of_past_pil into l_effective_date,
                                             l_max_object_version_number;
        close c_ppe_max_esd_of_past_pil;
        --
        -- The group function "max" returns null when no records found,
        -- so check l_effective_date is null to find whether any
        -- past records were found.
        --
        --
        if l_effective_date is not null then
         --
         -- Do not process the row as it is already processed(deleted).
         --
         if l_prev_pk_id <> l_pk_id then

           -- now backup all the deleted enrollment rows
           --
           for l_deleted_ppe_rec in c_deleted_ppe(l_pk_id, l_effective_date)
           loop
              --
              open c_bkp_row('BEN_PRTT_PREM_F',
                             l_deleted_ppe_rec.per_in_ler_id,
                             l_deleted_ppe_rec.PRTT_PREM_ID,
                             l_deleted_ppe_rec.object_version_number);
              fetch c_bkp_row into l_row_id;
              --
              if c_bkp_row%notfound
              then
                  --
                  close c_bkp_row;
                  --
                  insert into BEN_LE_CLSN_N_RSTR (
                      BKUP_TBL_TYP_CD,
                      LCR_ATTRIBUTE6,
                      LCR_ATTRIBUTE7,
                      LCR_ATTRIBUTE8,
                      LCR_ATTRIBUTE9,
                      LCR_ATTRIBUTE10,
                      LCR_ATTRIBUTE11,
                      LCR_ATTRIBUTE12,
                      LCR_ATTRIBUTE13,
                      LCR_ATTRIBUTE14,
                      LCR_ATTRIBUTE15,
                      LCR_ATTRIBUTE16,
                      LCR_ATTRIBUTE17,
                      LCR_ATTRIBUTE18,
                      LCR_ATTRIBUTE19,
                      LCR_ATTRIBUTE20,
                      LCR_ATTRIBUTE21,
                      LCR_ATTRIBUTE22,
                      LCR_ATTRIBUTE23,
                      LCR_ATTRIBUTE24,
                      LCR_ATTRIBUTE25,
                      LCR_ATTRIBUTE26,
                      LCR_ATTRIBUTE27,
                      LCR_ATTRIBUTE28,
                      LCR_ATTRIBUTE29,
                      LCR_ATTRIBUTE30,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      CREATED_BY,
                      CREATION_DATE,
                      OBJECT_VERSION_NUMBER,
                      REQUEST_ID,
                      PROGRAM_APPLICATION_ID,
                      PROGRAM_ID,
                      PROGRAM_UPDATE_DATE,
                      PER_IN_LER_ID,
                      BKUP_TBL_ID, -- PRTT_PREM_ID,
                      EFFECTIVE_START_DATE,
                      EFFECTIVE_END_DATE,
                      STD_PREM_UOM,
                      STD_PREM_VAL,
                      ACTL_PREM_ID,
                      PRTT_ENRT_RSLT_ID,
                      BUSINESS_GROUP_ID,
                      LCR_ATTRIBUTE_CATEGORY,
                      LCR_ATTRIBUTE1,
                      LCR_ATTRIBUTE2,
                      LCR_ATTRIBUTE3,
                      LCR_ATTRIBUTE4,
                      LCR_ATTRIBUTE5
                      )
                  values (
                      'BEN_PRTT_PREM_F',
                     l_deleted_ppe_rec.PPE_ATTRIBUTE6,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE7,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE8,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE9,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE10,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE11,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE12,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE13,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE14,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE15,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE16,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE17,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE18,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE19,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE20,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE21,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE22,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE23,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE24,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE25,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE26,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE27,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE28,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE29,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE30,
                     l_deleted_ppe_rec.LAST_UPDATE_DATE,
                     l_deleted_ppe_rec.LAST_UPDATED_BY,
                     l_deleted_ppe_rec.LAST_UPDATE_LOGIN,
                     l_deleted_ppe_rec.CREATED_BY,
                     l_deleted_ppe_rec.CREATION_DATE,
                     l_deleted_ppe_rec.OBJECT_VERSION_NUMBER,
                     l_deleted_ppe_rec.REQUEST_ID,
                     l_deleted_ppe_rec.PROGRAM_APPLICATION_ID,
                     l_deleted_ppe_rec.PROGRAM_ID,
                     l_deleted_ppe_rec.PROGRAM_UPDATE_DATE,
                     l_deleted_ppe_rec.PER_IN_LER_ID,
                     l_deleted_ppe_rec.PRTT_PREM_ID,
                     l_deleted_ppe_rec.EFFECTIVE_START_DATE,
                     l_deleted_ppe_rec.EFFECTIVE_END_DATE,
                     l_deleted_ppe_rec.STD_PREM_UOM,
                     l_deleted_ppe_rec.STD_PREM_VAL,
                     l_deleted_ppe_rec.ACTL_PREM_ID,
                     l_deleted_ppe_rec.PRTT_ENRT_RSLT_ID,
                     l_deleted_ppe_rec.BUSINESS_GROUP_ID,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE_CATEGORY,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE1,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE2,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE3,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE4,
                     l_deleted_ppe_rec.PPE_ATTRIBUTE5
                  );
                  --
              else
                  --
                  close c_bkp_row;
                  --
                  update BEN_LE_CLSN_N_RSTR set
                      -- BKUP_TBL_TYP_CD,
                      LCR_ATTRIBUTE6         = l_deleted_ppe_rec.PPE_ATTRIBUTE6,
                      LCR_ATTRIBUTE7         = l_deleted_ppe_rec.PPE_ATTRIBUTE7,
                      LCR_ATTRIBUTE8         = l_deleted_ppe_rec.PPE_ATTRIBUTE8,
                      LCR_ATTRIBUTE9         = l_deleted_ppe_rec.PPE_ATTRIBUTE9,
                      LCR_ATTRIBUTE10         = l_deleted_ppe_rec.PPE_ATTRIBUTE10,
                      LCR_ATTRIBUTE11         = l_deleted_ppe_rec.PPE_ATTRIBUTE11,
                      LCR_ATTRIBUTE12         = l_deleted_ppe_rec.PPE_ATTRIBUTE12,
                      LCR_ATTRIBUTE13         = l_deleted_ppe_rec.PPE_ATTRIBUTE13,
                      LCR_ATTRIBUTE14         = l_deleted_ppe_rec.PPE_ATTRIBUTE14,
                      LCR_ATTRIBUTE15         = l_deleted_ppe_rec.PPE_ATTRIBUTE15,
                      LCR_ATTRIBUTE16         = l_deleted_ppe_rec.PPE_ATTRIBUTE16,
                      LCR_ATTRIBUTE17         = l_deleted_ppe_rec.PPE_ATTRIBUTE17,
                      LCR_ATTRIBUTE18         = l_deleted_ppe_rec.PPE_ATTRIBUTE18,
                      LCR_ATTRIBUTE19         = l_deleted_ppe_rec.PPE_ATTRIBUTE19,
                      LCR_ATTRIBUTE20         = l_deleted_ppe_rec.PPE_ATTRIBUTE20,
                      LCR_ATTRIBUTE21         = l_deleted_ppe_rec.PPE_ATTRIBUTE21,
                      LCR_ATTRIBUTE22         = l_deleted_ppe_rec.PPE_ATTRIBUTE22,
                      LCR_ATTRIBUTE23         = l_deleted_ppe_rec.PPE_ATTRIBUTE23,
                      LCR_ATTRIBUTE24         = l_deleted_ppe_rec.PPE_ATTRIBUTE24,
                      LCR_ATTRIBUTE25         = l_deleted_ppe_rec.PPE_ATTRIBUTE25,
                      LCR_ATTRIBUTE26         = l_deleted_ppe_rec.PPE_ATTRIBUTE26,
                      LCR_ATTRIBUTE27         = l_deleted_ppe_rec.PPE_ATTRIBUTE27,
                      LCR_ATTRIBUTE28         = l_deleted_ppe_rec.PPE_ATTRIBUTE28,
                      LCR_ATTRIBUTE29         = l_deleted_ppe_rec.PPE_ATTRIBUTE29,
                      LCR_ATTRIBUTE30         = l_deleted_ppe_rec.PPE_ATTRIBUTE30,
                      LAST_UPDATE_DATE        =l_deleted_ppe_rec.LAST_UPDATE_DATE,
                      LAST_UPDATED_BY         =l_deleted_ppe_rec.LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN       =l_deleted_ppe_rec.LAST_UPDATE_LOGIN,
                      CREATED_BY              =l_deleted_ppe_rec.CREATED_BY,
                      CREATION_DATE           =l_deleted_ppe_rec.CREATION_DATE,
                      -- OBJECT_VERSION_NUMBER   =l_deleted_ppe_rec.OBJECT_VERSION_NUMBER,
                      REQUEST_ID              =l_deleted_ppe_rec.REQUEST_ID,
                      PROGRAM_APPLICATION_ID  =l_deleted_ppe_rec.PROGRAM_APPLICATION_ID,
                      PROGRAM_ID              =l_deleted_ppe_rec.PROGRAM_ID,
                      PROGRAM_UPDATE_DATE     =l_deleted_ppe_rec.PROGRAM_UPDATE_DATE,
                      -- PER_IN_LER_ID           =l_deleted_ppe_rec.PER_IN_LER_ID,
                      -- BKUP_TBL_ID, -- PRTT_PREM_ID,
                      EFFECTIVE_START_DATE    =l_deleted_ppe_rec.EFFECTIVE_START_DATE,
                      EFFECTIVE_END_DATE      =l_deleted_ppe_rec.EFFECTIVE_END_DATE,
                      STD_PREM_UOM            =l_deleted_ppe_rec.STD_PREM_UOM,
                      STD_PREM_VAL            =l_deleted_ppe_rec.STD_PREM_VAL,
                      ACTL_PREM_ID            =l_deleted_ppe_rec.ACTL_PREM_ID,
                      PRTT_ENRT_RSLT_ID       =l_deleted_ppe_rec.PRTT_ENRT_RSLT_ID,
                      BUSINESS_GROUP_ID       =l_deleted_ppe_rec.BUSINESS_GROUP_ID,
                      LCR_ATTRIBUTE_CATEGORY  =l_deleted_ppe_rec.PPE_ATTRIBUTE_CATEGORY,
                      LCR_ATTRIBUTE1          =l_deleted_ppe_rec.PPE_ATTRIBUTE1,
                      LCR_ATTRIBUTE2          =l_deleted_ppe_rec.PPE_ATTRIBUTE2,
                      LCR_ATTRIBUTE3          =l_deleted_ppe_rec.PPE_ATTRIBUTE3,
                      LCR_ATTRIBUTE4          =l_deleted_ppe_rec.PPE_ATTRIBUTE4,
                      LCR_ATTRIBUTE5          = l_deleted_ppe_rec.PPE_ATTRIBUTE5
                   where rowid = l_row_id;
              end if;
           end loop;
           --
           -- Past records exist. So datetrack mode FUTURE_CHANGE.
           --
           l_datetrack_mode := hr_api.g_future_change;
           l_object_version_number := l_max_object_version_number;
          --
          -- Delete from the appropriate API.
          --
          if l_effective_date <> hr_api.g_eot  and nvl(p_copy_only,'N') <>  'Y'  then
            ben_prtt_prem_api.delete_prtt_prem
              (p_validate                => false,
               p_prtt_prem_id       => l_pk_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_object_version_number,
               p_effective_date          => l_effective_date,
               p_datetrack_mode          => l_datetrack_mode);
          end if;
          --
          l_prev_pk_id := l_pk_id;
          --

         end if; -- l_prev_pk_id <> l_pk_id

        end if;
        --
      end loop;
      --
      l_prev_pk_id := -1;
      --

    close c_ben_prtt_prem_f;
    --
  elsif p_routine = 'BEN_PL_BNF_F' then


    -- For beneficiaries, we want to 'un-end' any bnf records that were ENDED
    -- due to the per-in-ler.  The 'future-change' date track mode will do that
    -- for us.
    -- Other bnfs can be left alone because their FK to per-in-ler
    -- will indicate that they are really 'backed out'.

    l_prev_pk_id := -1; -- like null

    open c_ben_pl_bnf_f;

      loop

        fetch c_ben_pl_bnf_f into l_pk_id,
                                  l_object_version_number,
																	l_bnf_effective_start_date;
        exit when c_ben_pl_bnf_f%notfound;
        --
        -- Get the maximum of effective end date for the beneficiary
        -- with past per_in_ler 's.
        --
        l_effective_date := null;
        open  c_pbn_max_esd_of_past_pil(l_pk_id);
        fetch c_pbn_max_esd_of_past_pil into l_effective_date,
                                             l_max_object_version_number;
        close c_pbn_max_esd_of_past_pil;
        --
        -- The group function "max" returns null when no records found,
        -- so check l_effective_date is null to find whether any
        -- past records were found.
        --
        --
        if l_effective_date is not null then
         --
         -- Do not process the row as it is already processed(deleted).
         --
         if l_prev_pk_id <> l_pk_id then

           -- now backup all the deleted pbn rows
           --
           for l_deleted_pbn_rec in c_deleted_pbn(l_pk_id, l_effective_date)
           loop
              --
              --
              open c_bkp_row('BEN_PL_BNF_F',
                             l_deleted_pbn_rec.per_in_ler_id,
                             l_deleted_pbn_rec.PL_BNF_ID,
                             l_deleted_pbn_rec.object_version_number);
              fetch c_bkp_row into l_row_id;
              --
              if c_bkp_row%notfound
              then
                 --
                 close c_bkp_row;
                 --
                 insert into BEN_LE_CLSN_N_RSTR (
                  BKUP_TBL_TYP_CD,
                  LCR_ATTRIBUTE1,
                  LCR_ATTRIBUTE2,
                  LCR_ATTRIBUTE3,
                  LCR_ATTRIBUTE4,
                  LCR_ATTRIBUTE5,
                  LCR_ATTRIBUTE6,
                  LCR_ATTRIBUTE7,
                  LCR_ATTRIBUTE8,
                  LCR_ATTRIBUTE9,
                  LCR_ATTRIBUTE10,
                  LCR_ATTRIBUTE11,
                  LCR_ATTRIBUTE12,
                  LCR_ATTRIBUTE13,
                  LCR_ATTRIBUTE14,
                  LCR_ATTRIBUTE15,
                  LCR_ATTRIBUTE16,
                  LCR_ATTRIBUTE17,
                  LCR_ATTRIBUTE18,
                  LCR_ATTRIBUTE19,
                  LCR_ATTRIBUTE20,
                  LCR_ATTRIBUTE21,
                  LCR_ATTRIBUTE22,
                  LCR_ATTRIBUTE23,
                  LCR_ATTRIBUTE24,
                  LCR_ATTRIBUTE25,
                  LCR_ATTRIBUTE26,
                  LCR_ATTRIBUTE27,
                  LCR_ATTRIBUTE28,
                  LCR_ATTRIBUTE29,
                  LCR_ATTRIBUTE30,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN,
                  CREATED_BY,
                  CREATION_DATE,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE,
                  OBJECT_VERSION_NUMBER,
                  BKUP_TBL_ID, -- PL_BNF_ID,
                  EFFECTIVE_START_DATE,
                  EFFECTIVE_END_DATE,
                  PRMRY_CNTNGNT_CD,
                  PCT_DSGD_NUM,
                  AMT_DSGD_VAL,
                  AMT_DSGD_UOM,
                  ADDL_INSTRN_TXT,
                  DSGN_THRU_DT,
                  DSGN_STRT_DT,
                  PRTT_ENRT_RSLT_ID,
                  ORGANIZATION_ID,
                  BNF_PERSON_ID,
                  PERSON_TTEE_ID,  -- TTEE_PERSON_ID,
                  BUSINESS_GROUP_ID,
                  PER_IN_LER_ID,
                  LCR_ATTRIBUTE_CATEGORY )
             values (
                 'BEN_PL_BNF_F',
                 l_deleted_pbn_rec.PBN_ATTRIBUTE1,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE2,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE3,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE4,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE5,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE6,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE7,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE8,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE9,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE10,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE11,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE12,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE13,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE14,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE15,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE16,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE17,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE18,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE19,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE20,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE21,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE22,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE23,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE24,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE25,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE26,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE27,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE28,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE29,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE30,
                 l_deleted_pbn_rec.LAST_UPDATE_DATE,
                 l_deleted_pbn_rec.LAST_UPDATED_BY,
                 l_deleted_pbn_rec.LAST_UPDATE_LOGIN,
                 l_deleted_pbn_rec.CREATED_BY,
                 l_deleted_pbn_rec.CREATION_DATE,
                 l_deleted_pbn_rec.REQUEST_ID,
                 l_deleted_pbn_rec.PROGRAM_APPLICATION_ID,
                 l_deleted_pbn_rec.PROGRAM_ID,
                 l_deleted_pbn_rec.PROGRAM_UPDATE_DATE,
                 l_deleted_pbn_rec.OBJECT_VERSION_NUMBER,
                 l_deleted_pbn_rec.PL_BNF_ID,
                 l_deleted_pbn_rec.EFFECTIVE_START_DATE,
                 l_deleted_pbn_rec.EFFECTIVE_END_DATE,
                 l_deleted_pbn_rec.PRMRY_CNTNGNT_CD,
                 l_deleted_pbn_rec.PCT_DSGD_NUM,
                 l_deleted_pbn_rec.AMT_DSGD_VAL,
                 l_deleted_pbn_rec.AMT_DSGD_UOM,
                 l_deleted_pbn_rec.ADDL_INSTRN_TXT,
                 l_deleted_pbn_rec.DSGN_THRU_DT,
                 l_deleted_pbn_rec.DSGN_STRT_DT,
                 l_deleted_pbn_rec.PRTT_ENRT_RSLT_ID,
                 l_deleted_pbn_rec.ORGANIZATION_ID,
                 l_deleted_pbn_rec.BNF_PERSON_ID,
                 l_deleted_pbn_rec.TTEE_PERSON_ID,
                 l_deleted_pbn_rec.BUSINESS_GROUP_ID,
                 l_deleted_pbn_rec.PER_IN_LER_ID,
                 l_deleted_pbn_rec.PBN_ATTRIBUTE_CATEGORY
              );
              --
            else
              --
              close c_bkp_row;
              --
              update BEN_LE_CLSN_N_RSTR set
                  LCR_ATTRIBUTE1         = l_deleted_pbn_rec.PBN_ATTRIBUTE1,
                  LCR_ATTRIBUTE2         = l_deleted_pbn_rec.PBN_ATTRIBUTE2,
                  LCR_ATTRIBUTE3         = l_deleted_pbn_rec.PBN_ATTRIBUTE3,
                  LCR_ATTRIBUTE4         = l_deleted_pbn_rec.PBN_ATTRIBUTE4,
                  LCR_ATTRIBUTE5         = l_deleted_pbn_rec.PBN_ATTRIBUTE5,
                  LCR_ATTRIBUTE6         = l_deleted_pbn_rec.PBN_ATTRIBUTE6,
                  LCR_ATTRIBUTE7         = l_deleted_pbn_rec.PBN_ATTRIBUTE7,
                  LCR_ATTRIBUTE8         = l_deleted_pbn_rec.PBN_ATTRIBUTE8,
                  LCR_ATTRIBUTE9         = l_deleted_pbn_rec.PBN_ATTRIBUTE9,
                  LCR_ATTRIBUTE10        = l_deleted_pbn_rec.PBN_ATTRIBUTE10,
                  LCR_ATTRIBUTE11        = l_deleted_pbn_rec.PBN_ATTRIBUTE11,
                  LCR_ATTRIBUTE12        = l_deleted_pbn_rec.PBN_ATTRIBUTE12,
                  LCR_ATTRIBUTE13        = l_deleted_pbn_rec.PBN_ATTRIBUTE13,
                  LCR_ATTRIBUTE14        = l_deleted_pbn_rec.PBN_ATTRIBUTE14,
                  LCR_ATTRIBUTE15        = l_deleted_pbn_rec.PBN_ATTRIBUTE15,
                  LCR_ATTRIBUTE16        = l_deleted_pbn_rec.PBN_ATTRIBUTE16,
                  LCR_ATTRIBUTE17        = l_deleted_pbn_rec.PBN_ATTRIBUTE17,
                  LCR_ATTRIBUTE18        = l_deleted_pbn_rec.PBN_ATTRIBUTE18,
                  LCR_ATTRIBUTE19        = l_deleted_pbn_rec.PBN_ATTRIBUTE19,
                  LCR_ATTRIBUTE20        = l_deleted_pbn_rec.PBN_ATTRIBUTE20,
                  LCR_ATTRIBUTE21        = l_deleted_pbn_rec.PBN_ATTRIBUTE21,
                  LCR_ATTRIBUTE22        = l_deleted_pbn_rec.PBN_ATTRIBUTE22,
                  LCR_ATTRIBUTE23        = l_deleted_pbn_rec.PBN_ATTRIBUTE23,
                  LCR_ATTRIBUTE24        = l_deleted_pbn_rec.PBN_ATTRIBUTE24,
                  LCR_ATTRIBUTE25        = l_deleted_pbn_rec.PBN_ATTRIBUTE25,
                  LCR_ATTRIBUTE26        = l_deleted_pbn_rec.PBN_ATTRIBUTE26,
                  LCR_ATTRIBUTE27        = l_deleted_pbn_rec.PBN_ATTRIBUTE27,
                  LCR_ATTRIBUTE28        = l_deleted_pbn_rec.PBN_ATTRIBUTE28,
                  LCR_ATTRIBUTE29        = l_deleted_pbn_rec.PBN_ATTRIBUTE29,
                  LCR_ATTRIBUTE30        = l_deleted_pbn_rec.PBN_ATTRIBUTE30,
                  LAST_UPDATE_DATE       = l_deleted_pbn_rec.LAST_UPDATE_DATE,
                  LAST_UPDATED_BY        = l_deleted_pbn_rec.LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN      = l_deleted_pbn_rec.LAST_UPDATE_LOGIN,
                  CREATED_BY             = l_deleted_pbn_rec.CREATED_BY,
                  CREATION_DATE          = l_deleted_pbn_rec.CREATION_DATE,
                  REQUEST_ID             = l_deleted_pbn_rec.REQUEST_ID,
                  PROGRAM_APPLICATION_ID = l_deleted_pbn_rec.PROGRAM_APPLICATION_ID,
                  PROGRAM_ID             = l_deleted_pbn_rec.PROGRAM_ID,
                  PROGRAM_UPDATE_DATE    = l_deleted_pbn_rec.PROGRAM_UPDATE_DATE,
                  -- OBJECT_VERSION_NUMBER  = l_deleted_pbn_rec.OBJECT_VERSION_NUMBER,
                  -- BKUP_TBL_ID         = l_deleted_pbn_rec.PL_BNF_ID,
                  EFFECTIVE_START_DATE   = l_deleted_pbn_rec.EFFECTIVE_START_DATE,
                  EFFECTIVE_END_DATE     = l_deleted_pbn_rec.EFFECTIVE_END_DATE,
                  PRMRY_CNTNGNT_CD       = l_deleted_pbn_rec.PRMRY_CNTNGNT_CD,
                  PCT_DSGD_NUM           = l_deleted_pbn_rec.PCT_DSGD_NUM,
                  AMT_DSGD_VAL           = l_deleted_pbn_rec.AMT_DSGD_VAL,
                  AMT_DSGD_UOM           = l_deleted_pbn_rec.AMT_DSGD_UOM,
                  ADDL_INSTRN_TXT        = l_deleted_pbn_rec.ADDL_INSTRN_TXT,
                  DSGN_THRU_DT           = l_deleted_pbn_rec.DSGN_THRU_DT,
                  DSGN_STRT_DT           = l_deleted_pbn_rec.DSGN_STRT_DT,
                  PRTT_ENRT_RSLT_ID      = l_deleted_pbn_rec.PRTT_ENRT_RSLT_ID,
                  ORGANIZATION_ID        = l_deleted_pbn_rec.ORGANIZATION_ID,
                  BNF_PERSON_ID          = l_deleted_pbn_rec.BNF_PERSON_ID,
                  PERSON_TTEE_ID         = l_deleted_pbn_rec.TTEE_PERSON_ID,
                  BUSINESS_GROUP_ID      = l_deleted_pbn_rec.BUSINESS_GROUP_ID,
                  --PER_IN_LER_ID          = l_deleted_pbn_rec.PER_IN_LER_ID,
                  LCR_ATTRIBUTE_CATEGORY = l_deleted_pbn_rec.PBN_ATTRIBUTE_CATEGORY
               where rowid = l_row_id;
            end if;
           end loop;
           --
           -- Past records exist. So datetrack mode FUTURE_CHANGE.
           --
           l_datetrack_mode := hr_api.g_future_change;
           l_object_version_number := l_max_object_version_number;
          --
          -- Delete from the appropriate API.
          --
          if l_effective_date <> hr_api.g_eot  and nvl(p_copy_only,'N') <>  'Y'  then
            ben_plan_beneficiary_api.delete_plan_beneficiary
              (p_validate                => false,
               p_pl_bnf_id               => l_pk_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_object_version_number,
               p_business_group_id       => p_business_group_id,
               p_effective_date          => l_effective_date,
               p_datetrack_mode          => l_datetrack_mode,
               p_multi_row_actn          => FALSE);  -- 2552295
          end if;
          --
          l_prev_pk_id := l_pk_id;
          --
         end if; -- l_prev_pk_id <> l_pk_id
				else
				 -- -- bug 5668052
				 hr_utility.set_location('effective date null  ' ,12.12);
				 			BEN_PLAN_BENEFICIARY_API.remove_usage (
										 p_validate          => FALSE
										,p_pl_bnf_id         => l_pk_id
										,p_effective_date    => l_bnf_effective_start_date
										,p_datetrack_mode    => hr_api.g_zap
										,p_business_group_id => p_business_group_id
										,p_dsgn_thru_dt      => NULL);


        end if;
      end loop;


     --
     -- if any of the result in corrected and stored in backp table for corrn
     -- correct the per_in_ler_id of related the dpnt table too bug # 3086161

      for i in c_BEN_LE_CLSN_N_RSTR_pbn(p_per_in_ler_id )
      Loop
               l_object_version_number := i.object_version_number ;
               ben_plan_beneficiary_api.update_plan_beneficiary
                  (p_validate                => FALSE
                  ,p_business_group_id       => p_business_group_id
                  ,p_pl_bnf_id               => i.pl_bnf_id
                  ,p_effective_start_date    => l_effective_start_date
                  ,p_effective_end_date      => l_effective_end_date
                  ,p_dsgn_thru_dt            => i.enrt_cvg_thru_dt
                  ,p_per_in_ler_id           => i.per_in_ler_id
                  ,p_object_version_number   => l_object_version_number
                  ,p_effective_date          => i.effective_start_date
                  ,p_datetrack_mode          => hr_api.g_correction
                  ,p_multi_row_actn          => FALSE);

      end loop ;


      --
      l_prev_pk_id := -1;
      --

    close c_ben_pl_bnf_f;
  elsif p_routine = 'BEN_PRMRY_CARE_PRVDR_F' then
    --
    l_prev_pk_id := -1; -- like null
    --
    /* Why are we deleting these records. Bug 3709516
    --
    open c_ben_prmry_care_prvdr_f;
      --
      loop
        --
        fetch c_ben_prmry_care_prvdr_f into l_pk_id,l_effective_date,
                                            l_object_version_number;
        exit when c_ben_prmry_care_prvdr_f%notfound;
        --
        -- Do not process the row as it is already processed(deleted).
        --
        if l_prev_pk_id <> l_pk_id  and nvl(p_copy_only,'N') <>  'Y'  then

           --
           -- Delete from the appropriate API.
           --
           ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
             (p_validate                => false,
              p_prmry_care_prvdr_id     => l_pk_id,
              p_effective_start_date    => l_effective_start_date,
              p_effective_end_date      => l_effective_end_date,
              p_object_version_number   => l_object_version_number,
              p_effective_date          => l_effective_date,
              p_datetrack_mode          => 'ZAP');
           --
           l_prev_pk_id := l_pk_id;
           --
        end if; -- l_prev_pk_id <> l_pk_id
      --
      end loop;
      --
      l_prev_pk_id := -1;
      --
    close c_ben_prmry_care_prvdr_f;
    */

  elsif p_routine = 'BEN_PRTT_REIMBMT_RQST' then
     open c_prc ;
     --
     -- bug 2518955 - added exception handling for showing customized message
     -- for specific case of presence of Approved claims preventing back-out of LE
     --
     -- enclosed the loop with a begin - exception - end block and check for
     -- BEN_92705_REIMB_RQST_APPROVD message in exception and show the message
     -- BEN_93185_APRVD_CLM_NO_BCKOUT instead of that.
     declare
       l_msg_name  varchar2(80);
       l_err_num   number;
     begin
       loop
          fetch c_prc into l_prc_rec ;
          exit when c_prc%notfound ;
          hr_utility.set_location('calling date ' || p_effective_date , 293);
          hr_utility.set_location('calling id  ' || l_prc_rec.PRTT_REIMBMT_RQST_ID , 293);

          BEN_prtt_reimbmt_rqst_API.delete_prtt_reimbmt_rqst
                                  (p_validate => FALSE
                                  ,p_PRTT_REIMBMT_RQST_ID => l_prc_rec.PRTT_REIMBMT_RQST_ID
                                  ,p_EFFECTIVE_START_DATE => l_effective_start_date
                                  ,p_EFFECTIVE_END_DATE   => l_effective_end_date
                                  ,p_OBJECT_VERSION_NUMBER=> l_prc_rec.OBJECT_VERSION_NUMBER
                                  ,p_effective_date       => l_prc_rec.effective_start_date
                                  ,p_datetrack_mode       => 'ZAP'
                                  ,p_SUBMITTER_PERSON_ID  => l_prc_rec.person_id );

       end loop ;
       --
     exception
       --
       when OTHERS then  -- exception number raised when FND_MESSAGE.raise_error is called
         --
         l_err_num := SQLCODE ;
         --
         if l_err_num = -20001 then
           --
           l_msg_name := get_msg_name();

           if l_msg_name = 'BEN_92705_REIMB_RQST_APPROVD' then
             --
             -- set our own message name and raise the exception again
             --
             fnd_message.set_name('BEN', 'BEN_93188_APRVD_CLM_NO_BCKOUT');
             fnd_message.raise_error;
             --
           else
             --
             fnd_message.raise_error;
             --
           end if;
           --
         end if;
         --
     end;
     --
     -- end fix 2518955
     --
     close c_prc;

    --
  elsif p_routine = 'BEN_PRTT_RT_VAL' then

    -- Rates need to be marked 'backed out' if they were created due to this per-in-ler.
    -- the first loop does that.
    -- The second loop handles 'un-ending' rates that were ended due to this per-in-ler.

    -- -- bug 4615207 : added GHR product installation chk -Multiple Rate chk to be performed only for GHR

   IF (fnd_installation.get_app_info('GHR',l_status, l_industry, l_oracle_schema)) THEN

    if l_status = 'I' then
    hr_utility.set_location('FOUND GHR',9909);
    open c_multiple_rate;
    fetch c_multiple_rate into l_multiple_rate;
    if c_multiple_rate%found then
      --
      hr_utility.set_location('Multiple rate',111);
      insert into BEN_LE_CLSN_N_RSTR (
                    BKUP_TBL_TYP_CD,
                    BKUP_TBL_ID,
                    per_in_ler_id,
                    business_group_id,
                    object_version_number)
                  values (
                    'MULTIPLE_RATE',
                    9999999999,
                    p_per_in_ler_id,
                    p_business_group_id,
                    999999999
                  );
    end if;
    close c_multiple_rate;
    end if; --if l_status
   end if;

    --
    open c_ben_prtt_rt_val;
      loop
        fetch c_ben_prtt_rt_val into l_pk_id,
                                     l_object_version_number,
                                     l_person_id,
                                     l_rt_strt_dt,
                                     l_acty_ref_perd_cd,
                                     l_prv_prtt_enrt_rslt_id,
                                     l_ref_obj_pk_id,
                                     l_ref_obj_table_name;
        exit when c_ben_prtt_rt_val%notfound;
        --
        -- Pbodla : Now insert the link between ben_enrt_rt and
        -- ben_prtt_rt_val into bacup table lcr
        -- as this info is lost when the prv rows are set to BCKDT status.
        --tilak: in case the cursor fails the previous data carried forward
        -- to avoid this the data is initialised
        l_ecr.enrt_rt_id := null ;
        open c_ecr(l_pk_id);
        fetch c_ecr into l_ecr;
        close c_ecr;
        --
        -- Bug 4661 : update the rate value as of the effective_start_date of
        -- the concerned result row.
        -- Consider the following scenario :
        -- Result row with PK id 1 - (01-jan-00 to 14-jan-00)
        -- Above result have one rate row attached.
        -- Result row with PK id 1 - (15-jan-00 to 24-jan-00)
        -- Above result have one rate row attached.
        -- Result row with PK id 1 - (25-jan-00 to EOT)
        -- Above result have one rate row attached.
        -- When Result row 1's rate row is backed out it checks
        -- whether the result row is suspended. So we need to pass
        -- result rows effective_start date to correctly identify it.
        --
        open c_prv_pen(l_prv_prtt_enrt_rslt_id, l_rt_strt_dt);
        fetch c_prv_pen into l_prv_pen;
        close c_prv_pen;
        --
        -- Bug : 4785.
        -- Using just l_prv_pen.effective_start_date to update
        -- rate value causes problem for backing out of open
        -- enrollment per in ler's. Result effective start date
        -- may be 11-nov-99, but the rate may start on 01-jan-00.
        -- Passing 11-nov-99 as effective date may cause no
        -- element entry row found problems.
        --
        hr_utility.set_location('l_prv_pen.effective_start_date'||l_prv_pen.effective_start_date,1999);
        hr_utility.set_location('l_rt_strt_dt'||l_rt_strt_dt,1999);
        if l_prv_pen.effective_start_date < l_rt_strt_dt then
           l_prv_effective_date := l_rt_strt_dt;
        else
           l_prv_effective_date := l_prv_pen.effective_start_date;
        end if;
        --
        -- Delete from the appropriate API.
        --
        if  nvl(p_copy_only,'N') <>  'Y' then
          ben_prtt_rt_val_api.update_prtt_rt_val
          (p_validate                => false,
           p_business_group_id       => p_business_group_id,
           p_prtt_rt_val_id          => l_pk_id,
           p_rt_end_dt               => (l_rt_strt_dt -1),
           p_prtt_rt_val_stat_cd     => 'BCKDT',
           p_acty_ref_perd_cd        => l_acty_ref_perd_cd,
           p_person_id               => l_person_id,
           p_object_version_number   => l_object_version_number,
           p_effective_date          => l_prv_effective_date);
        --
          if l_ref_obj_pk_id is not null and l_ref_obj_table_name = 'PER_PAY_PROPOSALS'
            then
           --
           l_salary_proposal_ovn := null;
           open c_pay_proposal(l_ref_obj_pk_id);
           fetch c_pay_proposal into l_salary_proposal_ovn;
           close c_pay_proposal;
           --
           if l_salary_proposal_ovn is not null then
             --
             -- Delete the per pay proposals.
             --
             hr_maintain_proposal_api.delete_salary_proposal(
                p_pay_proposal_id       => l_ref_obj_pk_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => l_salary_proposal_ovn
               ,p_validate              => FALSE
               ,p_salary_warning        => l_salary_warning);
             --
           end if;
           --
          end if;

        end if ;  --- p_copy only
        --
        if l_ecr.enrt_rt_id is not null  then
           --
           -- Get the object version number for the update
           --
           l_ecr.object_version_number :=
                        dt_api.get_object_version_number
                         (p_base_table_name => 'ben_enrt_rt',
                          p_base_key_column => 'enrt_rt_id',
                          p_base_key_value  => l_ecr.enrt_rt_id)-1;

          --
          open c_bkp_row('BEN_ENRT_RT',
                         p_per_in_ler_id,
                         l_ecr.enrt_rt_id,
                         l_ecr.object_version_number);
          fetch c_bkp_row into l_row_id;
          --
          if c_bkp_row%notfound
          then
            --
            close c_bkp_row;
            --
            insert into BEN_LE_CLSN_N_RSTR (
                    BKUP_TBL_TYP_CD,
                    BKUP_TBL_ID,
                    prtt_enrt_rslt_id, -- Used for prtt_rt_val_id,
                    per_in_ler_id,
                    business_group_id,
                    object_version_number)
                  values (
                    'BEN_ENRT_RT',
                    l_ecr.enrt_rt_id,
                    l_ecr.prtt_rt_val_id,
                    p_per_in_ler_id,
                    l_ecr.business_group_id,
                    l_ecr.object_version_number
                  );
           else
                  --
                  close c_bkp_row;
                  --
                 update BEN_LE_CLSN_N_RSTR set
                     prtt_enrt_rslt_id = l_ecr.prtt_rt_val_id,
                     business_group_id = l_ecr.business_group_id
                 where rowid = l_row_id;
                 --
           end if;
           --
        end if;
        --
      end loop;

    close c_ben_prtt_rt_val;

    /* Bug 8507247:First Adjust the rates and then open the backed out rates till EOT. This issue resolves Bug 8293106.
     Fix for Bug 8293106 is handled through Bug 8507247*/

   -- adjust the rate end for already adjusted rate
    open c_prtt_rt_val_adj (p_per_in_ler_id);
    loop
      fetch c_prtt_rt_val_adj into l_rt_adj;
      if c_prtt_rt_val_adj%found then
        --
        open c_prv_ovn (l_rt_adj.bkup_tbl_id);
        fetch c_prv_ovn into l_object_version_number;
        close c_prv_ovn;
        hr_utility.set_location('Ajdust rate end date'||l_rt_adj.bkup_tbl_id,10);
	hr_utility.set_location('p_effective_date '||p_effective_date,10);
	hr_utility.set_location('l_rt_adj'||l_rt_adj.effective_start_date,10);
	hr_utility.set_location('l_object_version_number'||l_object_version_number,10);
        --
        adj_prv_rate (p_person_id  => l_rt_adj.person_id,
                        p_prtt_rt_val_id  => l_rt_adj.bkup_tbl_id,
                        p_rt_end_dt =>    l_rt_adj.RT_END_DT,
                        p_object_version_number => l_object_version_number,
                        p_business_group_id => p_business_group_id,
                        p_effective_date => p_effective_date);
        --
      else   --not found
        exit;
      end if;
    end loop;
    close c_prtt_rt_val_adj;
    /* End of Bug 8507247*/

    --
    -- Reset the rate end date for the original rates.
    --
    l_prv_bckdt := null;
    l_ended_per_in_ler_id := null;

    open  c_prv_of_previous_pil;
    loop
       fetch c_prv_of_previous_pil into l_prv_bckdt;
       exit when c_prv_of_previous_pil%notfound;
       --
       hr_utility.set_location('prv 0 '||l_prv_bckdt.prtt_rt_val_id,10);
       hr_utility.set_location('prv 1 '||l_prv_bckdt.acty_base_rt_id,10);
       l_prv_pen.effective_start_date := null;
       open c_prv_pen(l_prv_bckdt.prtt_enrt_rslt_id, l_prv_bckdt.rt_strt_dt);
       fetch c_prv_pen into l_prv_pen;
       close c_prv_pen;
       --update only if the result exists - bug#4206567
      if l_prv_pen.effective_start_date is not null then
       -- Update rate end date to end of time.
       --
        if  nvl(p_copy_only,'N') <>  'Y'  then

          l_next_prv := null;
          open c_next_prv;
          fetch c_next_prv into l_next_prv;
          close c_next_prv;

/*
          if l_prev_prv_bckdt.acty_base_rt_id = l_prv_bckdt.acty_base_rt_id then
              l_rt_end_dt := l_prev_prv_bckdt.rt_strt_dt -1;
              l_ended_per_in_ler_id := l_prev_prv_bckdt.per_in_ler_id;
          else
              l_rt_end_dt := hr_api.g_eot;
              l_ended_per_in_ler_id := null;
          end if;
*/

           if l_next_prv.prtt_rt_val_id is not null then
              l_rt_end_dt := l_next_prv.rt_strt_dt -1;
              l_ended_per_in_ler_id := l_next_prv.per_in_ler_id;
           else
              l_rt_end_dt := hr_api.g_eot;
              l_ended_per_in_ler_id := null;
           end if;

           ben_prtt_rt_val_api.update_prtt_rt_val
          (p_validate               => FALSE
          ,p_prtt_rt_val_id         => l_prv_bckdt.prtt_rt_val_id
          ,p_object_version_number  => l_prv_bckdt.object_version_number
          ,p_rt_end_dt              => l_rt_end_dt
          ,p_prtt_rt_val_stat_cd    => null
          ,p_ended_per_in_ler_id    => l_ended_per_in_ler_id
          ,p_person_id              => l_prv_bckdt.person_id
          ,p_business_group_id      => p_business_group_id
          ,p_effective_date         => l_prv_pen.effective_start_date);

       end if ; -- p_copy only
       --
      end if;


    end loop;
    close c_prv_of_previous_pil;

    /* Bug 8507247: Commented the code here and moved it before the reopening the dates to EOT.
     First Adjust the rates and then open the backed out rates till EOT. This issue resolves Bug 8293106.
     Fix for Bug 8293106 is handled through Bug 8507247*/

    /*-- adjust the rate end for already adjusted rate
    open c_prtt_rt_val_adj (p_per_in_ler_id);
    loop
      fetch c_prtt_rt_val_adj into l_rt_adj;
      if c_prtt_rt_val_adj%found then
        --
        open c_prv_ovn (l_rt_adj.bkup_tbl_id);
        fetch c_prv_ovn into l_object_version_number;
        close c_prv_ovn;
        hr_utility.set_location('Ajdust rate end date'||l_rt_adj.bkup_tbl_id,10);
        --
        adj_prv_rate (p_person_id  => l_rt_adj.person_id,
                        p_prtt_rt_val_id  => l_rt_adj.bkup_tbl_id,
                        p_rt_end_dt =>    l_rt_adj.RT_END_DT,
                        p_object_version_number => l_object_version_number,
                        p_business_group_id => p_business_group_id,
                        p_effective_date => p_effective_date);
        --
      else   --not found
        exit;
      end if;
    end loop;
    close c_prtt_rt_val_adj;*/
    --

  elsif p_routine = 'BEN_PRTT_ENRT_RSLT_F' then

     hr_utility.set_location( 'backing out BEN_PRTT_ENRT_RSLT_F ' || p_per_in_ler_id   , 99 );
     hr_utility.set_location( 'p_bckdt_prtt_enrt_rslt_id ' || p_bckdt_prtt_enrt_rslt_id , 99 );
    -- Results need to be 'un-ended' if they were ended due to this
    -- per-in-ler.  The 'future change' date track mode handles that.

    -- Results that were created due to this per-in-ler need to be marked 'backed out'.
    --
    -- CFW. As Action items are always end dated when benmngle is run for the
    -- subsequent LE, they need to be re-opened. This is for the case when pen
    -- is not updated with subsequent LE but pea are end dated.
    --
    if  nvl(p_copy_only,'N') <>  'Y' then
    open c_pen_sus;
    loop
         fetch c_pen_sus into l_pen_sus;
         if c_pen_sus%notfound then
            exit;
         end if;

         unprocess_susp_enrt_past_pil
         (l_pen_sus.prtt_enrt_rslt_id,
          l_pen_sus.per_in_ler_id,
          p_business_group_id);

    end loop;
    close c_pen_sus;
    end if ;

    l_prev_pk_id := -1; -- like null
    g_enrt_made_flag := 'N';
    open c_ben_prtt_enrt_rslt_f;
      loop

        fetch c_ben_prtt_enrt_rslt_f into l_pk_id,
                                          l_object_version_number,
                                          l_pl_id,
                                          l_oipl_id,
                                          l_enrt_cvg_strt_dt,
                                          l_person_id,
                                          l_enrt_cvg_thru_dt,
                                          l_pen_eed,
                                          l_pen_esd,
                                          l_pen_pil_id,
                                          -- CFW
                                          l_lf_evt_ocrd_dt;
                                          -- CFW
        if c_ben_prtt_enrt_rslt_f%found then
           g_enrt_made_flag := 'Y';
        end if;
        exit when c_ben_prtt_enrt_rslt_f%notfound;

        -- Get the maximum of effective end date for the enrollment
        -- result with past per_in_ler 's.
        --
        l_effective_date := null;
        open  c_pen_max_esd_of_past_pil(l_pk_id);
        fetch c_pen_max_esd_of_past_pil into l_effective_date,
                                             l_max_object_version_number,
                                             l_prev_per_in_ler_id;
        close c_pen_max_esd_of_past_pil;

        -- Group function removed
        -- The group function "max" returns null when no records found,
        -- so check l_effective_date is null to find whether any
        -- past records were found.
        --
        hr_utility.set_location( 'Effective_date ' || l_effective_date , 99 );
        hr_utility.set_location( 'l_prev_pk_id ' || l_prev_pk_id , 99 );
        hr_utility.set_location( 'l_pk_id ' || l_pk_id , 99 );
	 -- changed 7176884 begin
	  --
	  hr_utility.set_location( 'p_per_in_ler_id ' ||  p_per_in_ler_id , 44333 );
	  hr_utility.set_location( 'l_pk_id ' ||  l_pk_id , 44333 );
	  --
	  open c_get_enrt_mthd_cd(l_pk_id);
	  fetch c_get_enrt_mthd_cd into l_get_enrt_mthd_cd;
	  close c_get_enrt_mthd_cd;
	  --
	  hr_utility.set_location( 'l_get_enrt_mthd_cd ' ||  l_get_enrt_mthd_cd , 44333 );
	  -- changed 7176884 end

        if l_effective_date is not null then
         --
         -- Do not process the row as it is already processed(deleted).
         --
         if l_prev_pk_id <> l_pk_id then

           hr_utility.set_location('l_prev_pk_id <> l_pk_id = ' || l_prev_pk_id || ' <> ' ||  l_pk_id, 999);
           hr_utility.set_location( 'l_effective_date ' || l_effective_date , 99 );

           -- now backup all the deleted enrollment rows
           --
           for l_deleted_pen_rec in c_deleted_pen(l_pk_id, l_effective_date)
           loop
              --
              --
               hr_utility.set_location( ' backup pil  ' ||  l_deleted_pen_rec.PER_IN_LER_ID , 99 );
               hr_utility.set_location( ' backup pen  ' ||  l_deleted_pen_rec.PRTT_ENRT_RSLT_ID , 99 );
              open c_bkp_row('BEN_PRTT_ENRT_RSLT_F',
                             l_deleted_pen_rec.PER_IN_LER_ID,
                             l_deleted_pen_rec.PRTT_ENRT_RSLT_ID,
                             l_deleted_pen_rec.object_version_number);
              fetch c_bkp_row into l_row_id;
              --
              if c_bkp_row%notfound
              then
                  --
                   hr_utility.set_location( ' copying ' ||  l_deleted_pen_rec.PRTT_ENRT_RSLT_ID , 99 );
                  close c_bkp_row;
                  --
                  insert into BEN_LE_CLSN_N_RSTR (
                   BKUP_TBL_TYP_CD,
                   COMP_LVL_CD,
                   LCR_ATTRIBUTE16,
                   LCR_ATTRIBUTE17,
                   LCR_ATTRIBUTE18,
                   LCR_ATTRIBUTE19,
                   LCR_ATTRIBUTE20,
                   LCR_ATTRIBUTE21,
                   LCR_ATTRIBUTE22,
                   LCR_ATTRIBUTE23,
                   LCR_ATTRIBUTE24,
                   LCR_ATTRIBUTE25,
                   LCR_ATTRIBUTE26,
                   LCR_ATTRIBUTE27,
                   LCR_ATTRIBUTE28,
                   LCR_ATTRIBUTE29,
                   LCR_ATTRIBUTE30,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATED_BY,
                   CREATION_DATE,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   OBJECT_VERSION_NUMBER,
                   BKUP_TBL_ID, -- PRTT_ENRT_RSLT_ID,
                   EFFECTIVE_START_DATE,
                   EFFECTIVE_END_DATE,
                   ENRT_CVG_STRT_DT,
                   ENRT_CVG_THRU_DT,
                   SSPNDD_FLAG,
                   PRTT_IS_CVRD_FLAG,
                   BNFT_AMT,
                   BNFT_NNMNTRY_UOM,
                   BNFT_TYP_CD,
                   UOM,
                   ORGNL_ENRT_DT,
                   ENRT_MTHD_CD,
                   ENRT_OVRIDN_FLAG,
                   ENRT_OVRID_RSN_CD,
                   ERLST_DEENRT_DT,
                   ENRT_OVRID_THRU_DT,
                   NO_LNGR_ELIG_FLAG,
                   BNFT_ORDR_NUM,
                   PERSON_ID,
                   ASSIGNMENT_ID,
                   PGM_ID,
                   PRTT_ENRT_RSLT_STAT_CD,
                   PL_ID,
                   OIPL_ID,
                   PTIP_ID,
                   PL_TYP_ID,
                   LER_ID,
                   PER_IN_LER_ID,
                   RPLCS_SSPNDD_RSLT_ID,
                   BUSINESS_GROUP_ID,
                   LCR_ATTRIBUTE_CATEGORY,
                   LCR_ATTRIBUTE1,
                   LCR_ATTRIBUTE2,
                   LCR_ATTRIBUTE3,
                   LCR_ATTRIBUTE4,
                   LCR_ATTRIBUTE5,
                   LCR_ATTRIBUTE6,
                   LCR_ATTRIBUTE7,
                   LCR_ATTRIBUTE8,
                   LCR_ATTRIBUTE9,
                   LCR_ATTRIBUTE10,
                   LCR_ATTRIBUTE11,
                   LCR_ATTRIBUTE12,
                   LCR_ATTRIBUTE13,
                   LCR_ATTRIBUTE14,
                   LCR_ATTRIBUTE15 ,
                   PL_ORDR_NUM,
                   PLIP_ORDR_NUM,
                   PTIP_ORDR_NUM,
                   OIPL_ORDR_NUM)
              values (
                  'BEN_PRTT_ENRT_RSLT_F',
                  l_deleted_pen_rec.COMP_LVL_CD,
                  l_deleted_pen_rec.PEN_ATTRIBUTE16,
                  l_deleted_pen_rec.PEN_ATTRIBUTE17,
                  l_deleted_pen_rec.PEN_ATTRIBUTE18,
                  l_deleted_pen_rec.PEN_ATTRIBUTE19,
                  l_deleted_pen_rec.PEN_ATTRIBUTE20,
                  l_deleted_pen_rec.PEN_ATTRIBUTE21,
                  l_deleted_pen_rec.PEN_ATTRIBUTE22,
                  l_deleted_pen_rec.PEN_ATTRIBUTE23,
                  l_deleted_pen_rec.PEN_ATTRIBUTE24,
                  l_deleted_pen_rec.PEN_ATTRIBUTE25,
                  l_deleted_pen_rec.PEN_ATTRIBUTE26,
                  l_deleted_pen_rec.PEN_ATTRIBUTE27,
                  l_deleted_pen_rec.PEN_ATTRIBUTE28,
                  l_deleted_pen_rec.PEN_ATTRIBUTE29,
                  l_deleted_pen_rec.PEN_ATTRIBUTE30,
                  l_deleted_pen_rec.LAST_UPDATE_DATE,
                  l_deleted_pen_rec.LAST_UPDATED_BY,
                  l_deleted_pen_rec.LAST_UPDATE_LOGIN,
                  l_deleted_pen_rec.CREATED_BY,
                  l_deleted_pen_rec.CREATION_DATE,
                  l_deleted_pen_rec.REQUEST_ID,
                  l_deleted_pen_rec.PROGRAM_APPLICATION_ID,
                  l_deleted_pen_rec.PROGRAM_ID,
                  l_deleted_pen_rec.PROGRAM_UPDATE_DATE,
                  l_deleted_pen_rec.OBJECT_VERSION_NUMBER,
                  l_deleted_pen_rec.PRTT_ENRT_RSLT_ID,
                  l_deleted_pen_rec.EFFECTIVE_START_DATE,
                  l_deleted_pen_rec.EFFECTIVE_END_DATE,
                  l_deleted_pen_rec.ENRT_CVG_STRT_DT,
                  l_deleted_pen_rec.ENRT_CVG_THRU_DT,
                  l_deleted_pen_rec.SSPNDD_FLAG,
                  l_deleted_pen_rec.PRTT_IS_CVRD_FLAG,
                  l_deleted_pen_rec.BNFT_AMT,
                  l_deleted_pen_rec.BNFT_NNMNTRY_UOM,
                  l_deleted_pen_rec.BNFT_TYP_CD,
                  l_deleted_pen_rec.UOM,
                  l_deleted_pen_rec.ORGNL_ENRT_DT,
                  l_deleted_pen_rec.ENRT_MTHD_CD,
                  l_deleted_pen_rec.ENRT_OVRIDN_FLAG,
                  l_deleted_pen_rec.ENRT_OVRID_RSN_CD,
                  l_deleted_pen_rec.ERLST_DEENRT_DT,
                  l_deleted_pen_rec.ENRT_OVRID_THRU_DT,
                  l_deleted_pen_rec.NO_LNGR_ELIG_FLAG,
                  l_deleted_pen_rec.BNFT_ORDR_NUM,
                  l_deleted_pen_rec.PERSON_ID,
                  l_deleted_pen_rec.ASSIGNMENT_ID,
                  l_deleted_pen_rec.PGM_ID,
                  l_deleted_pen_rec.PRTT_ENRT_RSLT_STAT_CD,
                  l_deleted_pen_rec.PL_ID,
                  l_deleted_pen_rec.OIPL_ID,
                  l_deleted_pen_rec.PTIP_ID,
                  l_deleted_pen_rec.PL_TYP_ID,
                  l_deleted_pen_rec.LER_ID,
                  l_deleted_pen_rec.PER_IN_LER_ID,
                  l_deleted_pen_rec.RPLCS_SSPNDD_RSLT_ID,
                  l_deleted_pen_rec.BUSINESS_GROUP_ID,
                  l_deleted_pen_rec.PEN_ATTRIBUTE_CATEGORY,
                  l_deleted_pen_rec.PEN_ATTRIBUTE1,
                  l_deleted_pen_rec.PEN_ATTRIBUTE2,
                  l_deleted_pen_rec.PEN_ATTRIBUTE3,
                  l_deleted_pen_rec.PEN_ATTRIBUTE4,
                  l_deleted_pen_rec.PEN_ATTRIBUTE5,
                  l_deleted_pen_rec.PEN_ATTRIBUTE6,
                  l_deleted_pen_rec.PEN_ATTRIBUTE7,
                  l_deleted_pen_rec.PEN_ATTRIBUTE8,
                  l_deleted_pen_rec.PEN_ATTRIBUTE9,
                  l_deleted_pen_rec.PEN_ATTRIBUTE10,
                  l_deleted_pen_rec.PEN_ATTRIBUTE11,
                  l_deleted_pen_rec.PEN_ATTRIBUTE12,
                  l_deleted_pen_rec.PEN_ATTRIBUTE13,
                  l_deleted_pen_rec.PEN_ATTRIBUTE14,
                  l_deleted_pen_rec.PEN_ATTRIBUTE15,
                  l_deleted_pen_rec.PL_ORDR_NUM,
                  l_deleted_pen_rec.PLIP_ORDR_NUM,
                  l_deleted_pen_rec.PTIP_ORDR_NUM,
                  l_deleted_pen_rec.OIPL_ORDR_NUM
              );
             --
            else
              --
              close c_bkp_row;
              --
              update BEN_LE_CLSN_N_RSTR set
                   COMP_LVL_CD                  = l_deleted_pen_rec.COMP_LVL_CD,
                   LCR_ATTRIBUTE16              = l_deleted_pen_rec.PEN_ATTRIBUTE16,
                   LCR_ATTRIBUTE17              = l_deleted_pen_rec.PEN_ATTRIBUTE17,
                   LCR_ATTRIBUTE18              = l_deleted_pen_rec.PEN_ATTRIBUTE18,
                   LCR_ATTRIBUTE19              = l_deleted_pen_rec.PEN_ATTRIBUTE19,
                   LCR_ATTRIBUTE20              = l_deleted_pen_rec.PEN_ATTRIBUTE20,
                   LCR_ATTRIBUTE21              = l_deleted_pen_rec.PEN_ATTRIBUTE21,
                   LCR_ATTRIBUTE22              = l_deleted_pen_rec.PEN_ATTRIBUTE22,
                   LCR_ATTRIBUTE23              = l_deleted_pen_rec.PEN_ATTRIBUTE23,
                   LCR_ATTRIBUTE24              = l_deleted_pen_rec.PEN_ATTRIBUTE24,
                   LCR_ATTRIBUTE25              = l_deleted_pen_rec.PEN_ATTRIBUTE25,
                   LCR_ATTRIBUTE26              = l_deleted_pen_rec.PEN_ATTRIBUTE26,
                   LCR_ATTRIBUTE27              = l_deleted_pen_rec.PEN_ATTRIBUTE27,
                   LCR_ATTRIBUTE28              = l_deleted_pen_rec.PEN_ATTRIBUTE28,
                   LCR_ATTRIBUTE29              = l_deleted_pen_rec.PEN_ATTRIBUTE29,
                   LCR_ATTRIBUTE30              = l_deleted_pen_rec.PEN_ATTRIBUTE30,
                   LAST_UPDATE_DATE             = l_deleted_pen_rec.LAST_UPDATE_DATE,
                   LAST_UPDATED_BY              = l_deleted_pen_rec.LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN            = l_deleted_pen_rec.LAST_UPDATE_LOGIN,
                   CREATED_BY                   = l_deleted_pen_rec.CREATED_BY,
                   CREATION_DATE                = l_deleted_pen_rec.CREATION_DATE,
                   REQUEST_ID                   = l_deleted_pen_rec.REQUEST_ID,
                   PROGRAM_APPLICATION_ID       = l_deleted_pen_rec.PROGRAM_APPLICATION_ID,
                   PROGRAM_ID                   = l_deleted_pen_rec.PROGRAM_ID,
                   PROGRAM_UPDATE_DATE          = l_deleted_pen_rec.PROGRAM_UPDATE_DATE,
                   EFFECTIVE_START_DATE         = l_deleted_pen_rec.EFFECTIVE_START_DATE,
                   EFFECTIVE_END_DATE           = l_deleted_pen_rec.EFFECTIVE_END_DATE,
                   ENRT_CVG_STRT_DT             = l_deleted_pen_rec.ENRT_CVG_STRT_DT,
                   ENRT_CVG_THRU_DT             = l_deleted_pen_rec.ENRT_CVG_THRU_DT,
                   SSPNDD_FLAG                  = l_deleted_pen_rec.SSPNDD_FLAG,
                   PRTT_IS_CVRD_FLAG            = l_deleted_pen_rec.PRTT_IS_CVRD_FLAG,
                   BNFT_AMT                     = l_deleted_pen_rec.BNFT_AMT,
                   BNFT_NNMNTRY_UOM             = l_deleted_pen_rec.BNFT_NNMNTRY_UOM,
                   BNFT_TYP_CD                  = l_deleted_pen_rec.BNFT_TYP_CD,
                   UOM                          = l_deleted_pen_rec.UOM,
                   ORGNL_ENRT_DT                = l_deleted_pen_rec.ORGNL_ENRT_DT,
                   ENRT_MTHD_CD                 = l_deleted_pen_rec.ENRT_MTHD_CD,
                   ENRT_OVRIDN_FLAG             = l_deleted_pen_rec.ENRT_OVRIDN_FLAG,
                   ENRT_OVRID_RSN_CD            = l_deleted_pen_rec.ENRT_OVRID_RSN_CD,
                   ERLST_DEENRT_DT              = l_deleted_pen_rec.ERLST_DEENRT_DT,
                   ENRT_OVRID_THRU_DT           = l_deleted_pen_rec.ENRT_OVRID_THRU_DT,
                   NO_LNGR_ELIG_FLAG            = l_deleted_pen_rec.NO_LNGR_ELIG_FLAG,
                   BNFT_ORDR_NUM                = l_deleted_pen_rec.BNFT_ORDR_NUM,
                   PERSON_ID                    = l_deleted_pen_rec.PERSON_ID,
                   ASSIGNMENT_ID                = l_deleted_pen_rec.ASSIGNMENT_ID,
                   PGM_ID                       = l_deleted_pen_rec.PGM_ID,
                   PRTT_ENRT_RSLT_STAT_CD       = l_deleted_pen_rec.PRTT_ENRT_RSLT_STAT_CD,
                   PL_ID                        = l_deleted_pen_rec.PL_ID,
                   OIPL_ID                      = l_deleted_pen_rec.OIPL_ID,
                   PTIP_ID                      = l_deleted_pen_rec.PTIP_ID,
                   PL_TYP_ID                    = l_deleted_pen_rec.PL_TYP_ID,
                   LER_ID                       = l_deleted_pen_rec.LER_ID,
                   RPLCS_SSPNDD_RSLT_ID         = l_deleted_pen_rec.RPLCS_SSPNDD_RSLT_ID,
                   BUSINESS_GROUP_ID            = l_deleted_pen_rec.BUSINESS_GROUP_ID,
                   LCR_ATTRIBUTE_CATEGORY       = l_deleted_pen_rec.PEN_ATTRIBUTE_CATEGORY,
                   LCR_ATTRIBUTE1               = l_deleted_pen_rec.PEN_ATTRIBUTE1,
                   LCR_ATTRIBUTE2               = l_deleted_pen_rec.PEN_ATTRIBUTE2,
                   LCR_ATTRIBUTE3               = l_deleted_pen_rec.PEN_ATTRIBUTE3,
                   LCR_ATTRIBUTE4               = l_deleted_pen_rec.PEN_ATTRIBUTE4,
                   LCR_ATTRIBUTE5               = l_deleted_pen_rec.PEN_ATTRIBUTE5,
                   LCR_ATTRIBUTE6               = l_deleted_pen_rec.PEN_ATTRIBUTE6,
                   LCR_ATTRIBUTE7               = l_deleted_pen_rec.PEN_ATTRIBUTE7,
                   LCR_ATTRIBUTE8               = l_deleted_pen_rec.PEN_ATTRIBUTE8,
                   LCR_ATTRIBUTE9               = l_deleted_pen_rec.PEN_ATTRIBUTE9,
                   LCR_ATTRIBUTE10              = l_deleted_pen_rec.PEN_ATTRIBUTE10,
                   LCR_ATTRIBUTE11              = l_deleted_pen_rec.PEN_ATTRIBUTE11,
                   LCR_ATTRIBUTE12              = l_deleted_pen_rec.PEN_ATTRIBUTE12,
                   LCR_ATTRIBUTE13              = l_deleted_pen_rec.PEN_ATTRIBUTE13,
                   LCR_ATTRIBUTE14              = l_deleted_pen_rec.PEN_ATTRIBUTE14,
                   LCR_ATTRIBUTE15              = l_deleted_pen_rec.PEN_ATTRIBUTE15,
                   PL_ORDR_NUM                  = l_deleted_pen_rec.PL_ORDR_NUM,
                   PLIP_ORDR_NUM                = l_deleted_pen_rec.PLIP_ORDR_NUM,
                   PTIP_ORDR_NUM                = l_deleted_pen_rec.PTIP_ORDR_NUM,
                   OIPL_ORDR_NUM                = l_deleted_pen_rec.OIPL_ORDR_NUM
              where rowid = l_row_id;
              --
            end if;
           end loop;

           -- Past records exist. So datetrack mode FUTURE_CHANGE.
           --
           l_datetrack_mode := hr_api.g_future_change;
           l_object_version_number := l_max_object_version_number;
           --

          -- Delete from the appropriate API.
          --
          --
          -- if the same result in the corrected result row dont delete the resutl
          -- that will be updated with the previous per_ler_id to reinstate the previous
          --  per_in_ler id of the same date. # 3086161
          l_dummy := null ;
          open  c_corr_result_exist (p_per_in_ler_id ,
                                   l_pk_id  ) ;
          fetch c_corr_result_exist into l_dummy ;
          close c_corr_result_exist ;
          hr_utility.set_location( 'corrected result exist ' ||  l_dummy , 99 );

          if l_effective_date <> hr_api.g_eot and l_dummy is null  and nvl(p_copy_only,'N') <>  'Y'  then
            ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate                => false,
               p_prtt_enrt_rslt_id       => l_pk_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_object_version_number,
               p_effective_date          => l_effective_date,
               p_datetrack_mode          => l_datetrack_mode,
               p_multi_row_validate      => FALSE);
          end if;

	   /* Added for Bug 8984394 */
	   hr_utility.set_location( 'l_pk_id ' ||  l_pk_id , 1999 );
	   hr_utility.set_location( 'l_effective_end_date ' ||  l_effective_end_date , 1999 );
	  if(l_effective_end_date = hr_api.g_eot) then
		  open c_get_pil_id(l_pk_id);
		  fetch  c_get_pil_id into l_upd_epe;
                  if(c_get_pil_id%found) then
		          hr_utility.set_location( 'epe found ', 1999 );
		          open c_prev_pil_id;
			  fetch c_prev_pil_id into l_prev_pil_id;
			  close c_prev_pil_id;
			  hr_utility.set_location( 'l_prev_pil_id '||l_prev_pil_id, 1999 );
			  hr_utility.set_location( 'l_upd_epe.per_in_ler_id '||l_upd_epe.per_in_ler_id, 1999 );
			  hr_utility.set_location( 'l_upd_epe.prtt_enrt_rslt_id '||l_upd_epe.prtt_enrt_rslt_id, 1999 );
			  if(l_prev_pil_id <> l_upd_epe.per_in_ler_id) then
				  hr_utility.set_location( 'l_pil_id '||l_upd_epe.per_in_ler_id,101);
				  hr_utility.set_location( 'l_epe_id '||l_upd_epe.elig_per_elctbl_chc_id,101);
				  hr_utility.set_location( 'l_epe_ovn '||l_upd_epe.object_version_number,101);

				  ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
						(p_validate                => FALSE
						 ,p_elig_per_elctbl_chc_id  => l_upd_epe.elig_per_elctbl_chc_id
						 ,p_prtt_enrt_rslt_id       => l_pk_id
						 ,p_object_version_number   => l_upd_epe.object_version_number
						 ,p_effective_date          => l_effective_start_date
						 );
                          /* Bug 9236429: Update the prtt_enrt_rslt_id on the epe table for the previous Life Event
			         when the present life event is backedout*/
			  elsif(l_prev_pil_id = l_upd_epe.per_in_ler_id and l_upd_epe.prtt_enrt_rslt_id is null) then
				  hr_utility.set_location( 'l_pil_id '||l_upd_epe.per_in_ler_id,102);
				  hr_utility.set_location( 'l_epe_id '||l_upd_epe.elig_per_elctbl_chc_id,102);
				  hr_utility.set_location( 'l_epe_ovn '||l_upd_epe.object_version_number,102);

				  ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
						(p_validate                => FALSE
						 ,p_elig_per_elctbl_chc_id  => l_upd_epe.elig_per_elctbl_chc_id
						 ,p_prtt_enrt_rslt_id       => l_pk_id
						 ,p_object_version_number   => l_upd_epe.object_version_number
						 ,p_effective_date          => l_effective_start_date
						 );

			end if;
		 end if;
		 close c_get_pil_id;
	  end if;
	  /* End of Bug 8984394 */

          --
          l_prev_pk_id := l_pk_id;
          --
          -- check if the cvg was ended or the row was just dt ended
          --
          if nvl(l_enrt_cvg_thru_dt,hr_api.g_eot)<>hr_api.g_eot or
             l_pen_eed<>hr_api.g_eot  and nvl(p_copy_only,'N') <>  'Y'  then
            --
            -- The ended row is being removed, effectively creating it.
            -- else it's just and update.
            --
            ben_ext_chlg.log_benefit_chg(
               p_action                      => 'CREATE'
              ,p_pl_id                       =>  l_pl_id
              ,p_oipl_id                     =>  l_oipl_id
              ,p_enrt_cvg_strt_dt            =>  l_enrt_cvg_strt_dt
              ,p_prtt_enrt_rslt_id           =>  l_pk_id
              ,p_per_in_ler_id               =>  l_pen_pil_id
              ,p_person_id                   =>  l_person_id
              ,p_business_group_id           =>  p_business_group_id
              ,p_effective_date              =>  l_effective_date
            );
          end if;
          -- CFW
          -- Unprocess for past pil after future_change delete is over
          --
          unprocess_susp_enrt_past_pil (l_pk_id,
                                        l_prev_per_in_ler_id,
                                        p_business_group_id);
          -- CFW

         end if; -- l_prev_pk_id <> l_pk_id
        else
           --
           -- No past records, so just update the record to 'backed out'.
           --
/*
           -- This call is commented as the result rows are always updated with correction
           --
           ben_prtt_enrt_result_api.get_ben_pen_upd_dt_mode
           (p_effective_date         => p_effective_date
           ,p_base_key_value         => l_pk_id
           ,P_desired_datetrack_mode => hr_api.g_update
           ,P_datetrack_allow        => l_datetrack_mode
           );
*/

          -- 2982606 if the update for the result level then copy the  record to the
          -- backup table
          if p_bckdt_prtt_enrt_rslt_id is not null then
                hr_utility.set_location('l_pk_id = ' || l_pk_id ,99);
                hr_utility.set_location('l_pen_esd = ' || l_pen_esd ,99);

                -- now backup all the deleted enrollment rows
                --
                for l_deleted_pen_rec in c_deleted_pen(l_pk_id, l_pen_esd)
                loop
                   --
                   --
                   open c_bkp_row('BEN_PRTT_ENRT_RSLT_F',
                             l_deleted_pen_rec.PER_IN_LER_ID,
                             l_deleted_pen_rec.PRTT_ENRT_RSLT_ID,
                             l_deleted_pen_rec.object_version_number);
                   fetch c_bkp_row into l_row_id;
                   --
                   if c_bkp_row%notfound
                   then
                       --
                     close c_bkp_row;
                       hr_utility.set_location(' creating backup  ' ||  l_pk_id, 999);
                       insert into BEN_LE_CLSN_N_RSTR (
                        BKUP_TBL_TYP_CD,
                        COMP_LVL_CD,
                        LCR_ATTRIBUTE16,
                        LCR_ATTRIBUTE17,
                        LCR_ATTRIBUTE18,
                        LCR_ATTRIBUTE19,
                        LCR_ATTRIBUTE20,
                        LCR_ATTRIBUTE21,
                        LCR_ATTRIBUTE22,
                        LCR_ATTRIBUTE23,
                        LCR_ATTRIBUTE24,
                        LCR_ATTRIBUTE25,
                        LCR_ATTRIBUTE26,
                        LCR_ATTRIBUTE27,
                        LCR_ATTRIBUTE28,
                        LCR_ATTRIBUTE29,
                        LCR_ATTRIBUTE30,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        CREATED_BY,
                        CREATION_DATE,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        OBJECT_VERSION_NUMBER,
                        BKUP_TBL_ID, -- PRTT_ENRT_RSLT_ID,
                        EFFECTIVE_START_DATE,
                        EFFECTIVE_END_DATE,
                        ENRT_CVG_STRT_DT,
                        ENRT_CVG_THRU_DT,
                        SSPNDD_FLAG,
                        PRTT_IS_CVRD_FLAG,
                        BNFT_AMT,
                        BNFT_NNMNTRY_UOM,
                        BNFT_TYP_CD,
                        UOM,
                        ORGNL_ENRT_DT,
                        ENRT_MTHD_CD,
                        ENRT_OVRIDN_FLAG,
                        ENRT_OVRID_RSN_CD,
                        ERLST_DEENRT_DT,
                        ENRT_OVRID_THRU_DT,
                        NO_LNGR_ELIG_FLAG,
                        BNFT_ORDR_NUM,
                        PERSON_ID,
                        ASSIGNMENT_ID,
                        PGM_ID,
                        PRTT_ENRT_RSLT_STAT_CD,
                        PL_ID,
                        OIPL_ID,
                        PTIP_ID,
                        PL_TYP_ID,
                        LER_ID,
                        PER_IN_LER_ID,
                        RPLCS_SSPNDD_RSLT_ID,
                        BUSINESS_GROUP_ID,
                        LCR_ATTRIBUTE_CATEGORY,
                        LCR_ATTRIBUTE1,
                        LCR_ATTRIBUTE2,
                        LCR_ATTRIBUTE3,
                        LCR_ATTRIBUTE4,
                        LCR_ATTRIBUTE5,
                        LCR_ATTRIBUTE6,
                        LCR_ATTRIBUTE7,
                        LCR_ATTRIBUTE8,
                        LCR_ATTRIBUTE9,
                        LCR_ATTRIBUTE10,
                        LCR_ATTRIBUTE11,
                        LCR_ATTRIBUTE12,
                        LCR_ATTRIBUTE13,
                        LCR_ATTRIBUTE14,
                        LCR_ATTRIBUTE15 ,
                        PL_ORDR_NUM,
                        PLIP_ORDR_NUM,
                        PTIP_ORDR_NUM,
                        OIPL_ORDR_NUM)
                   values (
                       'BEN_PRTT_ENRT_RSLT_F',
                       l_deleted_pen_rec.COMP_LVL_CD,
                       l_deleted_pen_rec.PEN_ATTRIBUTE16,
                       l_deleted_pen_rec.PEN_ATTRIBUTE17,
                       l_deleted_pen_rec.PEN_ATTRIBUTE18,
                       l_deleted_pen_rec.PEN_ATTRIBUTE19,
                       l_deleted_pen_rec.PEN_ATTRIBUTE20,
                       l_deleted_pen_rec.PEN_ATTRIBUTE21,
                       l_deleted_pen_rec.PEN_ATTRIBUTE22,
                       l_deleted_pen_rec.PEN_ATTRIBUTE23,
                       l_deleted_pen_rec.PEN_ATTRIBUTE24,
                       l_deleted_pen_rec.PEN_ATTRIBUTE25,
                       l_deleted_pen_rec.PEN_ATTRIBUTE26,
                       l_deleted_pen_rec.PEN_ATTRIBUTE27,
                       l_deleted_pen_rec.PEN_ATTRIBUTE28,
                       l_deleted_pen_rec.PEN_ATTRIBUTE29,
                       l_deleted_pen_rec.PEN_ATTRIBUTE30,
                       l_deleted_pen_rec.LAST_UPDATE_DATE,
                       l_deleted_pen_rec.LAST_UPDATED_BY,
                       l_deleted_pen_rec.LAST_UPDATE_LOGIN,
                       l_deleted_pen_rec.CREATED_BY,
                       l_deleted_pen_rec.CREATION_DATE,
                       l_deleted_pen_rec.REQUEST_ID,
                       l_deleted_pen_rec.PROGRAM_APPLICATION_ID,
                       l_deleted_pen_rec.PROGRAM_ID,
                       l_deleted_pen_rec.PROGRAM_UPDATE_DATE,
                       l_deleted_pen_rec.OBJECT_VERSION_NUMBER,
                       l_deleted_pen_rec.PRTT_ENRT_RSLT_ID,
                       l_deleted_pen_rec.EFFECTIVE_START_DATE,
                       l_deleted_pen_rec.EFFECTIVE_END_DATE,
                       l_deleted_pen_rec.ENRT_CVG_STRT_DT,
                       l_deleted_pen_rec.ENRT_CVG_THRU_DT,
                       l_deleted_pen_rec.SSPNDD_FLAG,
                       l_deleted_pen_rec.PRTT_IS_CVRD_FLAG,
                       l_deleted_pen_rec.BNFT_AMT,
                       l_deleted_pen_rec.BNFT_NNMNTRY_UOM,
                       l_deleted_pen_rec.BNFT_TYP_CD,
                       l_deleted_pen_rec.UOM,
                       l_deleted_pen_rec.ORGNL_ENRT_DT,
                       l_deleted_pen_rec.ENRT_MTHD_CD,
                       l_deleted_pen_rec.ENRT_OVRIDN_FLAG,
                       l_deleted_pen_rec.ENRT_OVRID_RSN_CD,
                       l_deleted_pen_rec.ERLST_DEENRT_DT,
                       l_deleted_pen_rec.ENRT_OVRID_THRU_DT,
                       l_deleted_pen_rec.NO_LNGR_ELIG_FLAG,
                       l_deleted_pen_rec.BNFT_ORDR_NUM,
                       l_deleted_pen_rec.PERSON_ID,
                       l_deleted_pen_rec.ASSIGNMENT_ID,
                       l_deleted_pen_rec.PGM_ID,
                       l_deleted_pen_rec.PRTT_ENRT_RSLT_STAT_CD,
                       l_deleted_pen_rec.PL_ID,
                       l_deleted_pen_rec.OIPL_ID,
                       l_deleted_pen_rec.PTIP_ID,
                       l_deleted_pen_rec.PL_TYP_ID,
                       l_deleted_pen_rec.LER_ID,
                       l_deleted_pen_rec.PER_IN_LER_ID,
                       l_deleted_pen_rec.RPLCS_SSPNDD_RSLT_ID,
                       l_deleted_pen_rec.BUSINESS_GROUP_ID,
                       l_deleted_pen_rec.PEN_ATTRIBUTE_CATEGORY,
                       l_deleted_pen_rec.PEN_ATTRIBUTE1,
                       l_deleted_pen_rec.PEN_ATTRIBUTE2,
                       l_deleted_pen_rec.PEN_ATTRIBUTE3,
                       l_deleted_pen_rec.PEN_ATTRIBUTE4,
                       l_deleted_pen_rec.PEN_ATTRIBUTE5,
                       l_deleted_pen_rec.PEN_ATTRIBUTE6,
                       l_deleted_pen_rec.PEN_ATTRIBUTE7,
                       l_deleted_pen_rec.PEN_ATTRIBUTE8,
                       l_deleted_pen_rec.PEN_ATTRIBUTE9,
                       l_deleted_pen_rec.PEN_ATTRIBUTE10,
                       l_deleted_pen_rec.PEN_ATTRIBUTE11,
                       l_deleted_pen_rec.PEN_ATTRIBUTE12,
                       l_deleted_pen_rec.PEN_ATTRIBUTE13,
                       l_deleted_pen_rec.PEN_ATTRIBUTE14,
                       l_deleted_pen_rec.PEN_ATTRIBUTE15,
                       l_deleted_pen_rec.PL_ORDR_NUM,
                       l_deleted_pen_rec.PLIP_ORDR_NUM,
                       l_deleted_pen_rec.PTIP_ORDR_NUM,
                       l_deleted_pen_rec.OIPL_ORDR_NUM
                   );
                  --
                 else
                   --
                   close c_bkp_row;
                   --
                   update BEN_LE_CLSN_N_RSTR set
                        COMP_LVL_CD                  = l_deleted_pen_rec.COMP_LVL_CD,
                        LCR_ATTRIBUTE16              = l_deleted_pen_rec.PEN_ATTRIBUTE16,
                        LCR_ATTRIBUTE17              = l_deleted_pen_rec.PEN_ATTRIBUTE17,
                        LCR_ATTRIBUTE18              = l_deleted_pen_rec.PEN_ATTRIBUTE18,
                        LCR_ATTRIBUTE19              = l_deleted_pen_rec.PEN_ATTRIBUTE19,
                        LCR_ATTRIBUTE20              = l_deleted_pen_rec.PEN_ATTRIBUTE20,
                        LCR_ATTRIBUTE21              = l_deleted_pen_rec.PEN_ATTRIBUTE21,
                        LCR_ATTRIBUTE22              = l_deleted_pen_rec.PEN_ATTRIBUTE22,
                        LCR_ATTRIBUTE23              = l_deleted_pen_rec.PEN_ATTRIBUTE23,
                        LCR_ATTRIBUTE24              = l_deleted_pen_rec.PEN_ATTRIBUTE24,
                        LCR_ATTRIBUTE25              = l_deleted_pen_rec.PEN_ATTRIBUTE25,
                        LCR_ATTRIBUTE26              = l_deleted_pen_rec.PEN_ATTRIBUTE26,
                        LCR_ATTRIBUTE27              = l_deleted_pen_rec.PEN_ATTRIBUTE27,
                        LCR_ATTRIBUTE28              = l_deleted_pen_rec.PEN_ATTRIBUTE28,
                        LCR_ATTRIBUTE29              = l_deleted_pen_rec.PEN_ATTRIBUTE29,
                        LCR_ATTRIBUTE30              = l_deleted_pen_rec.PEN_ATTRIBUTE30,
                        LAST_UPDATE_DATE             = l_deleted_pen_rec.LAST_UPDATE_DATE,
                        LAST_UPDATED_BY              = l_deleted_pen_rec.LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN            = l_deleted_pen_rec.LAST_UPDATE_LOGIN,
                        CREATED_BY                   = l_deleted_pen_rec.CREATED_BY,
                        CREATION_DATE                = l_deleted_pen_rec.CREATION_DATE,
                        REQUEST_ID                   = l_deleted_pen_rec.REQUEST_ID,
                        PROGRAM_APPLICATION_ID       = l_deleted_pen_rec.PROGRAM_APPLICATION_ID,
                        PROGRAM_ID                   = l_deleted_pen_rec.PROGRAM_ID,
                        PROGRAM_UPDATE_DATE          = l_deleted_pen_rec.PROGRAM_UPDATE_DATE,
                        EFFECTIVE_START_DATE         = l_deleted_pen_rec.EFFECTIVE_START_DATE,
                        EFFECTIVE_END_DATE           = l_deleted_pen_rec.EFFECTIVE_END_DATE,
                        ENRT_CVG_STRT_DT             = l_deleted_pen_rec.ENRT_CVG_STRT_DT,
                        ENRT_CVG_THRU_DT             = l_deleted_pen_rec.ENRT_CVG_THRU_DT,
                        SSPNDD_FLAG                  = l_deleted_pen_rec.SSPNDD_FLAG,
                        PRTT_IS_CVRD_FLAG            = l_deleted_pen_rec.PRTT_IS_CVRD_FLAG,
                        BNFT_AMT                     = l_deleted_pen_rec.BNFT_AMT,
                        BNFT_NNMNTRY_UOM             = l_deleted_pen_rec.BNFT_NNMNTRY_UOM,
                        BNFT_TYP_CD                  = l_deleted_pen_rec.BNFT_TYP_CD,
                        UOM                          = l_deleted_pen_rec.UOM,
                        ORGNL_ENRT_DT                = l_deleted_pen_rec.ORGNL_ENRT_DT,
                        ENRT_MTHD_CD                 = l_deleted_pen_rec.ENRT_MTHD_CD,
                        ENRT_OVRIDN_FLAG             = l_deleted_pen_rec.ENRT_OVRIDN_FLAG,
                        ENRT_OVRID_RSN_CD            = l_deleted_pen_rec.ENRT_OVRID_RSN_CD,
                        ERLST_DEENRT_DT              = l_deleted_pen_rec.ERLST_DEENRT_DT,
                        ENRT_OVRID_THRU_DT           = l_deleted_pen_rec.ENRT_OVRID_THRU_DT,
                        NO_LNGR_ELIG_FLAG            = l_deleted_pen_rec.NO_LNGR_ELIG_FLAG,
                        BNFT_ORDR_NUM                = l_deleted_pen_rec.BNFT_ORDR_NUM,
                        PERSON_ID                    = l_deleted_pen_rec.PERSON_ID,
                        ASSIGNMENT_ID                = l_deleted_pen_rec.ASSIGNMENT_ID,
                        PGM_ID                       = l_deleted_pen_rec.PGM_ID,
                        PRTT_ENRT_RSLT_STAT_CD       = l_deleted_pen_rec.PRTT_ENRT_RSLT_STAT_CD,
                        PL_ID                        = l_deleted_pen_rec.PL_ID,
                        OIPL_ID                      = l_deleted_pen_rec.OIPL_ID,
                        PTIP_ID                      = l_deleted_pen_rec.PTIP_ID,
                        PL_TYP_ID                    = l_deleted_pen_rec.PL_TYP_ID,
                        LER_ID                       = l_deleted_pen_rec.LER_ID,
                        RPLCS_SSPNDD_RSLT_ID         = l_deleted_pen_rec.RPLCS_SSPNDD_RSLT_ID,
                        BUSINESS_GROUP_ID            = l_deleted_pen_rec.BUSINESS_GROUP_ID,
                        LCR_ATTRIBUTE_CATEGORY       = l_deleted_pen_rec.PEN_ATTRIBUTE_CATEGORY,
                        LCR_ATTRIBUTE1               = l_deleted_pen_rec.PEN_ATTRIBUTE1,
                        LCR_ATTRIBUTE2               = l_deleted_pen_rec.PEN_ATTRIBUTE2,
                        LCR_ATTRIBUTE3               = l_deleted_pen_rec.PEN_ATTRIBUTE3,
                        LCR_ATTRIBUTE4               = l_deleted_pen_rec.PEN_ATTRIBUTE4,
                        LCR_ATTRIBUTE5               = l_deleted_pen_rec.PEN_ATTRIBUTE5,
                        LCR_ATTRIBUTE6               = l_deleted_pen_rec.PEN_ATTRIBUTE6,
                        LCR_ATTRIBUTE7               = l_deleted_pen_rec.PEN_ATTRIBUTE7,
                        LCR_ATTRIBUTE8               = l_deleted_pen_rec.PEN_ATTRIBUTE8,
                        LCR_ATTRIBUTE9               = l_deleted_pen_rec.PEN_ATTRIBUTE9,
                        LCR_ATTRIBUTE10              = l_deleted_pen_rec.PEN_ATTRIBUTE10,
                        LCR_ATTRIBUTE11              = l_deleted_pen_rec.PEN_ATTRIBUTE11,
                        LCR_ATTRIBUTE12              = l_deleted_pen_rec.PEN_ATTRIBUTE12,
                        LCR_ATTRIBUTE13              = l_deleted_pen_rec.PEN_ATTRIBUTE13,
                        LCR_ATTRIBUTE14              = l_deleted_pen_rec.PEN_ATTRIBUTE14,
                        LCR_ATTRIBUTE15              = l_deleted_pen_rec.PEN_ATTRIBUTE15,
                        PL_ORDR_NUM                  = l_deleted_pen_rec.PL_ORDR_NUM,
                        PLIP_ORDR_NUM                = l_deleted_pen_rec.PLIP_ORDR_NUM,
                        PTIP_ORDR_NUM                = l_deleted_pen_rec.PTIP_ORDR_NUM,
                        OIPL_ORDR_NUM                = l_deleted_pen_rec.OIPL_ORDR_NUM
                   where rowid = l_row_id;
                   --
                 end if;
             end loop;
          end if ;
          --
          -- Bug : 1143673 : use correction and use records eed as effective
          -- date to do it. If UPDATE mode is used as determined by
          -- get_ben_pen_upd_dt_mode, then one row will sit with status code as
          -- null, which causes the above bug situation.
          --
         if   nvl(p_copy_only,'N') <>  'Y' then
          --
          --  If corrected row exist, do not update the enrollment result.
          --  Bug 7197868
          --
          l_dummy := null;
          open  c_corr_result_exist (p_per_in_ler_id ,
                                   l_pk_id  ) ;
          fetch c_corr_result_exist into l_dummy ;
          close c_corr_result_exist ;
          if l_dummy is null then
          ben_prtt_enrt_result_api.update_prtt_enrt_result
            (p_validate               => FALSE
            ,p_prtt_enrt_rslt_id      => l_pk_id
            ,p_effective_start_date   => l_effective_start_date
            ,p_effective_end_date     => l_effective_end_date
            ,p_business_group_id      => p_business_group_id
            ,p_object_version_number  => l_object_version_number
            ,p_prtt_enrt_rslt_stat_cd => 'BCKDT'
            ,p_effective_date         => l_pen_esd  --  p_effective_date
            ,p_datetrack_mode         => hr_api.g_correction -- l_datetrack_mode
            ,p_multi_row_validate     => FALSE);
          --
          ben_ext_chlg.log_benefit_chg(
            p_action                      => 'DELETE'
           ,p_old_pl_id                   =>  l_pl_id
           ,p_old_oipl_id                 =>  l_oipl_id
           ,p_old_enrt_cvg_strt_dt        =>  l_enrt_cvg_strt_dt
           ,p_old_enrt_cvg_end_dt         =>  l_enrt_cvg_thru_dt
           ,p_pl_id                       =>  l_pl_id
           ,p_oipl_id                     =>  l_oipl_id
           ,p_enrt_cvg_strt_dt            =>  l_enrt_cvg_strt_dt
           ,p_enrt_cvg_end_dt             =>  (l_enrt_cvg_strt_dt-1)
           ,p_prtt_enrt_rslt_id           =>  l_pk_id
           ,p_per_in_ler_id               =>  l_pen_pil_id
           ,p_person_id                   =>  l_person_id
           ,p_business_group_id           =>  p_business_group_id
           ,p_effective_date              =>  l_pen_eed
          );
           end if; -- l_dummy is null
        end if ; --- copy only

        end if;

      end loop;
      --
      l_prev_pk_id := -1;
      --
    close c_ben_prtt_enrt_rslt_f;
    -- after result backed out  determine the person type usage
    -- since the backout not calling the multiedit
    -- person type usage is not updated  # 2899702
    ben_pen_bus.manage_per_type_usages
                 ( p_person_id          => l_person_id
                  ,p_business_group_id  => p_business_group_id
                  ,p_effective_date     => p_effective_date
                  ) ;
      --
      l_prev_pk_id := -1;


     --- if result for the per_in_ler_id is found in 'BEN_PRTT_ENRT_RSLT_F_CORR
     --- correct the result with  with per_in_ler_id and coverage dates bug # 3086161
     for i  in  c_BEN_LE_CLSN_N_RSTR_corr(p_per_in_ler_id)
     Loop
          --
          --  Get the enrollment coverage end date --  bug 8199189
          --
          open c_get_cvg_thru_dt(i.bkup_tbl_id
                                ,i.effective_start_date);
          fetch c_get_cvg_thru_dt into l_cvg_thru_dt, l_prtt_enrt_rslt_stat_cd;
          if c_get_cvg_thru_dt%notfound then
            hr_utility.set_location(' not found ' || l_cvg_thru_dt, 99 );
            l_cvg_thru_dt := i.enrt_cvg_thru_dt;
            l_prtt_enrt_rslt_stat_cd := i.prtt_enrt_rslt_stat_cd;
          end if;
          close c_get_cvg_thru_dt;
          --
         hr_utility.set_location(' l_cvg_thru_dt ' || l_cvg_thru_dt, 99 );
         hr_utility.set_location(' l_prtt_enrt_rslt_stat_cd' || l_prtt_enrt_rslt_stat_cd, 99 );
          --
          -- end 8199189
          --
         hr_utility.set_location(' corrected result ' || i.bkup_tbl_id, 99 );
        if l_prev_bkup_tbl_id <> i.bkup_tbl_id  and nvl(p_copy_only,'N') <>  'Y'  then

          l_object_version_number := i.object_version_number ;
         --bug#5032364
         if i.enrt_cvg_thru_dt <> hr_api.g_eot then
           --
           ben_prtt_enrt_result_api.delete_enrollment
           (p_validate              => false ,
           p_prtt_enrt_rslt_id     => i.bkup_tbl_id,
             p_per_in_ler_id         => i.per_in_ler_id,
           p_business_group_id     => p_business_group_id ,
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_object_version_number => l_object_version_number,
           p_effective_date        => i.effective_start_date,
           p_datetrack_mode        => 'DELETE',
           p_enrt_cvg_thru_dt     => i.enrt_cvg_thru_dt,
           p_multi_row_validate    => false);


         else
           --
           --  When updating the corrected row, also correct the effective end date.
           --  Bug 7197868
           --
           if (i.effective_end_date =  hr_api.g_eot
               and i.pen_effective_end_date <> i.effective_end_date) then
             hr_utility.set_location(' correcting  ' || i.bkup_tbl_id, 999 );
             --
             --  Bug 7197868
             --
             -- Delete future dated records.
             --
             ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate              => false ,
               p_prtt_enrt_rslt_id     => i.bkup_tbl_id,
               p_effective_start_date  => l_effective_start_date,
               p_effective_end_date    => l_effective_end_date,
               p_object_version_number => l_object_version_number,
               p_effective_date        => i.effective_start_date,
               p_datetrack_mode        => hr_api.g_future_change,
               p_multi_row_validate    => false);
           end if;
           --
           ben_prtt_enrt_result_api.update_prtt_enrt_result
               (p_validate                => FALSE
               ,p_prtt_enrt_rslt_id       => i.bkup_tbl_id
               ,p_effective_start_date    => l_effective_start_date
               ,p_effective_end_date      => l_effective_end_date
               ,p_per_in_ler_id           => i.per_in_ler_id
               ,p_ler_id                  => i.ler_id
               ,p_enrt_cvg_thru_dt        => i.enrt_cvg_thru_dt
               ,p_object_version_number   => l_object_version_number
               ,p_effective_date          => i.effective_start_date
               ,p_prtt_enrt_rslt_stat_cd  => i.prtt_enrt_rslt_stat_cd
	       ,p_enrt_mthd_cd            => i.enrt_mthd_cd -- Bug 7137371
               ,p_datetrack_mode          => hr_api.g_correction
               ,p_sspndd_flag            => i.sspndd_flag
               ,p_multi_row_validate      => FALSE
               ,p_business_group_id       => p_business_group_id
            );
          end if;
	  --
          -- Bug 6034585 Moved delete code inside the if so that it execute
	  -- only when p_copy_only = 'N' and l_prev_bkup_tbl_id <> i.bkup_tbl_id
	  --changed 7176884 begin
          -- delete the row from the  backup table  -- 7197868
          --
          if ((i.effective_end_date = hr_api.g_eot
               and i.pen_effective_end_date <> i.effective_end_date)
              or (l_prtt_enrt_rslt_stat_cd = 'VOIDD')) then  -- 8199189
             hr_utility.set_location(' correcting  ' || i.bkup_tbl_id, 999 );
             hr_utility.set_location(' i.per_in_ler_id  ' || i.per_in_ler_id, 999 );
             hr_utility.set_location(' p_per_in_ler_id  ' || p_per_in_ler_id, 999 );
             delete from ben_le_clsn_n_rstr cqb
                   where cqb.per_in_ler_id       = i.per_in_ler_id
                     and cqb.per_in_ler_ended_id = p_per_in_ler_id
                     and cqb.bkup_tbl_id         = i.bkup_tbl_id ;
          else
             hr_utility.set_location(' enrt_rslt_id' || i.bkup_tbl_id, 999 );
             hr_utility.set_location(' p_per_in_ler_id  ' || p_per_in_ler_id, 999 );
             hr_utility.set_location(' i.effective_start_date  ' || i.effective_start_date, 999 );
	--
        update ben_le_clsn_n_rstr cqb
        set    cqb.per_in_ler_id       = p_per_in_ler_id
	       , cqb.per_in_ler_ended_id = null
	       , cqb.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F'
	       , cqb.enrt_mthd_cd    = l_get_enrt_mthd_cd
               , cqb.enrt_cvg_thru_dt = l_cvg_thru_dt  -- Bug 8199189
	where  cqb.per_in_ler_id       = i.per_in_ler_id
        and    cqb.per_in_ler_ended_id = p_per_in_ler_id
        and    cqb.bkup_tbl_id         = i.bkup_tbl_id ;
          end if;  -- bug 7197868
	-- changed 7176884 end
          end if;
          l_prev_bkup_tbl_id := i.bkup_tbl_id;
	  --
    /* Bug 6034585 : Commented out the update statement as it was
       updating per_in_ler_id field with the incorrect per_in_ler_id
     --bug#3702033 - for reinstate retain the row with necessary updates
      update ben_le_clsn_n_rstr cqb
          set cqb.per_in_ler_id = p_per_in_ler_id,
              cqb.per_in_ler_ended_id = null,
              cqb.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F'
          where cqb.per_in_ler_id       = i.per_in_ler_id
          and cqb.per_in_ler_ended_id = p_per_in_ler_id
          and cqb.bkup_tbl_id         = i.bkup_tbl_id ;
      --
     */
     end loop ;
     --
     l_prev_bkup_tbl_id := -1;
     --
     for i  in  c_BEN_LE_CLSN_N_RSTR_del(p_per_in_ler_id)
     Loop
         hr_utility.set_location(' delete result ' || i.bkup_tbl_id, 99 );
        if l_prev_bkup_tbl_id <> i.bkup_tbl_id  then

          l_object_version_number := i.object_version_number ;
         --bug#5032364
           --
           ben_prtt_enrt_result_api.delete_enrollment
           (p_validate              => false ,
           p_prtt_enrt_rslt_id     => i.bkup_tbl_id,
           p_per_in_ler_id         => i.per_in_ler_id,
           p_business_group_id     => p_business_group_id ,
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_object_version_number => l_object_version_number,
           p_effective_date        => i.effective_start_date,
           p_datetrack_mode        => 'DELETE',
           p_enrt_cvg_thru_dt     => i.enrt_cvg_thru_dt,
           p_multi_row_validate    => false);
           --
        end if;
        --
        l_prev_bkup_tbl_id := i.bkup_tbl_id;
        --
    end loop;
    --
    -- Added for bug 7206471
    -- adjust the coverage end for already adjusted coverage
	open c_prtt_enrt_rslt_adj (p_per_in_ler_id);
	loop
	      fetch c_prtt_enrt_rslt_adj into l_cvg_adj;
	      --
	      if c_prtt_enrt_rslt_adj%found then
	        --
		open c_pen_ovn (l_cvg_adj.bkup_tbl_id);
		fetch c_pen_ovn into l_object_version_number,l_cvg_adj_effective_date;
		close c_pen_ovn;
		hr_utility.set_location('Ajdust coverage for '||l_cvg_adj.bkup_tbl_id,44333);
		hr_utility.set_location('l_rt_adj'||l_cvg_adj_effective_date,44333);
	        hr_utility.set_location('l_object_version_number'||l_object_version_number,44333);
		--
		--
		adj_pen_cvg (p_person_id  => l_cvg_adj.person_id,
			        p_prtt_enrt_rslt_id  => l_cvg_adj.bkup_tbl_id,
				p_cvg_end_dt =>    l_cvg_adj.enrt_cvg_thru_dt,
				p_object_version_number => l_object_version_number,
				p_business_group_id => p_business_group_id,
				p_effective_date => l_cvg_adj_effective_date); -- Bug 8507247:
		/* Changed parameter value passed to l_cvg_adj_effective_date.Effective start datewhich is picked
		for Adjustment should be passed to 'adj_pen_cvg' instead of p_effective_date*/
		--
		else   --not found
		exit;
	      end if;
	    end loop;
	    close c_prtt_enrt_rslt_adj;
    --
    -- End bug 7206471

  elsif p_routine = 'BEN_BNFT_PRVDD_LDGR_F' then
    --
    -- Bug 5500864
    -- This part of code has been added to take care of reinstatements of BPLs that have been END-DATED
    -- Such BPL Records have been backed up in BEN_LE_CLSN_N_RSTR. See BEN_BPL_DEL.POST_DELETE
    -- The part of the code below (which queries cursor c_ben_bnft_prvdd_ldgr_f) takes care of rest
    -- of the scenarios and voiding of BPL associated with the life-event being backed out.
    --
    hr_utility.set_location('ACE p_per_in_ler_id = ' || p_per_in_ler_id, 9999);
    --
    for l_bpl_from_backup in c_bpl_from_backup
    loop
      --
      hr_utility.set_location('ACE l_bpl_from_backup.bnft_prvdd_ldgr_id = ' || l_bpl_from_backup.BKUP_TBL_ID, 9999);
      --
      ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger
               (
                p_bnft_prvdd_ldgr_id      => l_bpl_from_backup.BKUP_TBL_ID,
                p_effective_start_date    => l_effective_start_date,
                p_effective_end_date      => l_effective_end_date,
                p_object_version_number   => l_bpl_from_backup.object_version_number,
                p_effective_date          => l_bpl_from_backup.effective_start_date,
                p_datetrack_mode          => hr_api.g_FUTURE_CHANGE,
                p_business_group_id       => p_business_group_id
               );
      hr_utility.set_location('ACE Reopened = ' || l_bpl_from_backup.BKUP_TBL_ID, 9999);
      --
      -- Bug 6376239 : Remove the rows from backup table once the ledger rows are restored
      --
      delete from ben_le_clsn_n_rstr cls
             where cls.per_in_ler_id      = l_bpl_from_backup.per_in_ler_id
              and cls.bkup_tbl_id         = l_bpl_from_backup.bkup_tbl_id
	      and cls.bkup_tbl_typ_cd     = 'BEN_BNFT_PRVDD_LDGR_F'
	      and effective_start_date    = l_bpl_from_backup.effective_start_date
              and effective_end_date      = hr_api.g_eot;
    --
    -- End Bug 6376239
    --
    end loop;
    --
    -- Bug 5500864
    --
    l_prev_pk_id := -1; -- like null
    --
    -- Start Bug 6376239
    --
    if p_bckdt_prtt_enrt_rslt_id is not null then
       open c_bpl_from_pen;
       fetch c_bpl_from_pen into prev_bnft_prvdd_ldgr_id;
       close c_bpl_from_pen;
    end if;
    --
    -- End Bug 6376239
    --
    open c_ben_bnft_prvdd_ldgr_f(prev_bnft_prvdd_ldgr_id);
    loop
       l_effective_date := null;
       fetch c_ben_bnft_prvdd_ldgr_f into l_bpl;
       exit when c_ben_bnft_prvdd_ldgr_f%notfound;
       l_pk_id := l_bpl.bnft_prvdd_ldgr_id;
       open  c_bpl_max_esd_of_past_pil(l_pk_id);
       fetch c_bpl_max_esd_of_past_pil into l_effective_date,
                                             l_max_object_version_number;
       close c_bpl_max_esd_of_past_pil;
       if l_effective_date is not null then
         if l_prev_pk_id <> l_pk_id then
           -- Past records exist. So datetrack mode FUTURE_CHANGE.
           --
             l_datetrack_mode := hr_api.g_future_change;
             l_object_version_number := l_max_object_version_number;
             --
             if l_effective_date <> hr_api.g_eot  and nvl(p_copy_only,'N') <>  'Y'  then
               --
               hr_utility.set_location('Deleting ledger='||to_char(l_bpl.bnft_prvdd_ldgr_id), 50);
               --
               ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
                 p_bnft_prvdd_ldgr_id      => l_bpl.bnft_prvdd_ldgr_id,
                 p_effective_start_date    => l_bpl.effective_start_date,
                 p_effective_end_date      => l_bpl.effective_end_date,
                 p_object_version_number   => l_max_object_version_number,
                 p_effective_date          => l_effective_date,
                 p_datetrack_mode          => l_datetrack_mode,
                 p_business_group_id       => p_business_group_id
                 );

             end if;
             l_prev_pk_id := l_pk_id;
          end if;
        else
           --
           --
           -- added if condition to check if there is any update for the same per_in_ler
           if l_prev_pk_id <> l_pk_id  and nvl(p_copy_only,'N') <>  'Y' then
             --
               l_bpl_effective_date := l_bpl.effective_start_date ;
               hr_utility.set_location('ledger Id'||l_bpl.bnft_prvdd_ldgr_id,11);
               hr_utility.set_location('ovn Id'||l_bpl.object_version_number,11);
               --
               ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
                 p_bnft_prvdd_ldgr_id      => l_bpl.bnft_prvdd_ldgr_id,
                 p_effective_start_date    => l_bpl.effective_start_date,
                 p_effective_end_date      => l_bpl.effective_end_date,
                 p_object_version_number   => l_bpl.object_version_number,
                 p_effective_date          => l_bpl_effective_date,
                 p_datetrack_mode          => hr_api.g_zap,
                 p_business_group_id       => p_business_group_id
                 );
               l_prev_pk_id := l_pk_id;
           end if;
        end if;
     end loop;
     --
     close c_ben_bnft_prvdd_ldgr_f;
     --
  elsif p_routine = 'BEN_PIL_ELCTBL_CHC_POPL' then

    -- pil popl's are updated to 'backed out'
   if  nvl(p_copy_only,'N') <>  'Y' then
    open c_ben_pil_elctbl_chc_popl;

      loop

        fetch c_ben_pil_elctbl_chc_popl into l_pk_id,
                                             l_object_version_number;
        exit when c_ben_pil_elctbl_chc_popl%notfound;
        --
        -- Delete from the appropriate API.
        --
        ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
          (p_validate                => false,
           p_pil_elctbl_chc_popl_id  => l_pk_id,
           p_pil_elctbl_popl_stat_cd => 'BCKDT',
           p_object_version_number   => l_object_version_number,
           p_effective_date          => p_effective_date);

      end loop;

    close c_ben_pil_elctbl_chc_popl;
  end if ;
  --
  elsif p_routine = 'BEN_CBR_QUALD_BNF' then
    --
    -- Restore prior cobra eligibility end date.
    --

    for l_cqb_rec in c_get_cbr_quald_bnf loop
      --
      l_object_version_number := l_cqb_rec.object_version_number;
      --
     if  nvl(p_copy_only,'N') <>  'Y' then
      ben_cbr_quald_bnf_api.update_cbr_quald_bnf
        (p_validate              => false
        ,p_cbr_quald_bnf_id      => l_cqb_rec.cbr_quald_bnf_id
        ,p_quald_bnf_flag        => 'Y'
        ,p_cbr_elig_perd_end_dt  => l_cqb_rec.prvs_elig_perd_end_dt
        ,p_cbr_inelg_rsn_cd      => null
        ,p_business_group_id     => p_business_group_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_date        => p_effective_date
        );
      --
      --  Copy to backup table to restore if neccessary.
      --
      --
     end if ;
      open c_bkp_row('BEN_CBR_QUALD_BNF',
                     p_per_in_ler_id,
                     l_cqb_rec.cbr_quald_bnf_id,
                     l_object_version_number);
      fetch c_bkp_row into l_row_id;
      --
      if c_bkp_row%notfound
      then
        --
        close c_bkp_row;
        --
        insert into BEN_LE_CLSN_N_RSTR(
        bkup_tbl_typ_cd,
        bkup_tbl_id,
        elig_flag,
        elig_strt_dt,
        elig_thru_dt,
        inelg_rsn_cd,
        per_in_ler_id,
        business_group_id,
        object_version_number
        )
        values (
        'BEN_CBR_QUALD_BNF',
        l_cqb_rec.cbr_quald_bnf_id,
        l_cqb_rec.quald_bnf_flag,
        l_cqb_rec.cbr_elig_perd_strt_dt,
        l_cqb_rec.cbr_elig_perd_end_dt,
        l_cqb_rec.cbr_inelg_rsn_cd,
        p_per_in_ler_id,
        l_cqb_rec.business_group_id,
        l_object_version_number
        );
      --
     else
      --
      close c_bkp_row;
      --
      update BEN_LE_CLSN_N_RSTR set
        elig_flag = l_cqb_rec.quald_bnf_flag,
        elig_strt_dt = l_cqb_rec.cbr_elig_perd_strt_dt,
        elig_thru_dt = l_cqb_rec.cbr_elig_perd_end_dt,
        inelg_rsn_cd = l_cqb_rec.cbr_inelg_rsn_cd,
        business_group_id = l_cqb_rec.business_group_id
      where rowid = l_row_id;
     end if;
    end loop;
    --

  else
    fnd_message.set_name('BEN','BEN_92535_UNKNOWN_DELETE_RTN');
    fnd_message.set_token('PROC',l_package);
    fnd_message.set_token('ROUTINE',p_routine);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('BG_ID',to_char(p_business_group_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    raise ben_manage_life_events.g_record_error;

  end if;
  --
  hr_utility.set_location ('End of '||p_routine,10);
  hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  when others then
    --
    -- null out to prevent bleeding.
    -- also do this in the error handler.
    --
    g_bolfe_effective_date:=null;
    --
    -- Handle closing of cursors in case of exception in delete routines
    --
    if c_ben_elig_cvrd_dpnt_f%isopen then
      --
      close c_ben_elig_cvrd_dpnt_f;
      --
    end if;
    --
    if c_ben_elig_per_f%isopen then
      --
      close c_ben_elig_per_f;
      --
    end if;
    --
    if c_ben_elig_per_opt_f%isopen then
      --
      close c_ben_elig_per_opt_f;
      --
    end if;
    --
    if c_ben_prtt_prem_f%isopen then
      --
      close c_ben_prtt_prem_f;
      --
    end if;
    --
    if c_ben_pl_bnf_f%isopen then
      --
      close c_ben_pl_bnf_f;
      --
    end if;
    --
    if c_ben_prmry_care_prvdr_f%isopen then
      --
      close c_ben_prmry_care_prvdr_f;
      --
    end if;
    --
    if c_ben_prtt_rt_val%isopen then
      --
      close c_ben_prtt_rt_val;
      --
    end if;
    --
    if c_prv_of_previous_pil%isopen then
      --
      close c_prv_of_previous_pil;
      --
    end if;
    --
    if c_ben_prtt_enrt_rslt_f%isopen then
      --
      close c_ben_prtt_enrt_rslt_f;
      --
    end if;
    --
    if c_ben_pil_elctbl_chc_popl%isopen then
      --
      close c_ben_pil_elctbl_chc_popl;
      --
    end if;
    --
    raise;
    --
end delete_routine;

--
-- self-service wrapper to run backout
--
procedure back_out_life_events_ss
  (p_per_in_ler_id         in number,
   p_bckt_per_in_ler_id    in number ,
   p_bckt_stat_cd          in varchar2 ,
   p_business_group_id     in number,
   p_effective_date        in date) is
  --
begin
 back_out_life_events
  (p_per_in_ler_id         =>p_per_in_ler_id,
   p_bckt_per_in_ler_id    =>p_bckt_per_in_ler_id,
   p_bckt_stat_cd          =>p_bckt_stat_cd,
   p_business_group_id     =>p_business_group_id,
   p_effective_date        =>p_effective_date);
--
commit;
--
exception
  when others then
    fnd_msg_pub.add;
--
end back_out_life_events_ss;
--
end ben_back_out_life_event;

/
