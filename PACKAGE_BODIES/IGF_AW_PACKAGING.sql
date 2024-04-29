--------------------------------------------------------
--  DDL for Package Body IGF_AW_PACKAGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_PACKAGING" AS
/* $Header: IGFAW03B.pls 120.28 2006/08/04 07:37:00 veramach ship $ */

  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose    : Main Packaging process does all fund checks
  ||  Known limitations, enhancements or remarks :
  ||
  ||  (reverse chronological order - newest change first)
  ||  who           WHEN            what
  ------------------------------------------------------------------------------------
  ||  museshad      24-Apr-2006    Bug 5116534. Modified the logic to apply NSLDS date
  ||                               offset to the disb date in post_award().
  ||  museshad      17-Apr-2006    Bug 5039489.
  ||                               1) Negative entry was NOT getting posted to Student a/c when a
  ||                                  disb gets cancelled during repackaging. This was
  ||                                  happening bcoz disb_net_amt was NOT getting set to 0 while
  ||                                  cancelling extra disb in the old award during repackaging.
  ||                                  Note, this issue is applicable to awards from all funds.
  ||                                  Also not directly relating to this bug, disb_paid_amt was
  ||                                  getting  set to 0 in this case which should not happen actually.
  ||                                  Fixed these issues in post_award().
  ||                               2) Fixed the ORDER BY sequence in merge_funds().
  ||                               3) In cancel_invalid_award(), passed 0 to disb_gross_amt in
  ||                                  igf_aw_awd_disb_pkg.update_row() call.
  ||                               Note: Issues 2 and 3 are additional fixes not directly related to the bug.
  ||  museshad      14-Apr-2006    Bug 5042136.
  ||                               Origination Fee, Guarantor Fee, Interest Rebate Amount should
  ||                               become 0 when a disb gets cancelled. Fixed this in -
  ||                               cancel_invalid_award() and post_award().
  || veramach      19/July/2005    Bug # 3392043 FA 140 Student SS Build
  ||                               Added option to publish/hide packaged/repackaged awards to Student SS
  ||                               Exclusive Inclusive funds checks now work for Repackaging too - Rejoice!!!!!
  ||                               Yet another indicator added for temporary awards - AR - which indicates an award
  ||                               cancelled due to exclusive inclusive checks
  || museshad      11-Jul-2005     Build FA 157.
  ||                               1) Disbursement Rounding
  ||                               2) Validate program eligibility
  ||                               3) Use anticipated data
  ||                               4) Cancel ineligible awards in Repackaging
  || veramach      April 2005      bug # 4274177
  ||                               Paid amount was getting reset to zero on repackaging. Fixed this - repackaging
  ||                               now does not update paid amount
  || veramach      Oct/Nov 2004    FA 152 - Automatic Repackaging
  ||                               FA 137 - COA Enhancements
  ||                               Modified logic to bring in packaging per awarding period rather than the whole award year
  ||                               Modified logic to allow repackage existing awards
  ||                               Added new functions and modified signatures of existing functions
  || ayedubat      12-OCT-2004     Changed the post_award procedure for FA 149 build bug # 3416863
  ||                               Fixed the GSCC warning "File.Sql.35 261, 2047, 3229, 7461-7462 - Do not assign default
  ||                               values in PL/SQL initialization or declaration" except for line number: 261
  || veramach      July 2004       FA 151 HR integration (bug # 3709292)
  ||                               Impact of obsoleting columns from igf_aw_awd_disb_pkg
  -- sjadhav     04-Aug-2004   Corrected Group By
  --
  || veramach       30-Jun-2004     bug 3709109 - Added call to function check_disb to enforce the rule that FWS funds can
  ||                                have only one disbursement per term
  || veramach      11-Jun-2004      bug # 3684031 Added a check so that packaging does not put holds on any award-packaging, as per
  ||                                current logic, does not overaward. Single-fund packaging does impose overaward holds if it overawards.
  || veramach      04-Mar-2004      bug # 3484438 - Changed cursor cur_new_awards to properly join on igf_aw_fund_mast_all
  || veramach      16-Feb-2004      bug # 3446214 - removed code from process_single_fund which uses award group.
  || cdcruz        04-Dec-2003      FA 131 COD Updates
  ||                                Modified the pell wrapper used to calculate pell amount. one more return parameter added
  ||                                Pell Schedule Code
  ||                                Modified  igf_sl_roundoff_digits_pkg.gross_fees_roundoff , as the package dropped a parameter
  ||                                Modified igf_sl_roundoff_digits_pkg.cl_gross_fees_roundoff , as the pkg dropped 2 parameters
  || veramach      03-Dec-2003      FA 131 COD Updates
  ||                                Modifies the pell wrapper used to calculate pell amount. The same wrapper returns the disbursements
  ||                                get_disbursements uses this disbursements and not calculate disbursements
  || veramach      20-NOV-2003      Added check_plan,get_plan_desc procedures
  || veramach      10-NOV-2003     Added debug statements
  || ugumall         30 OCT 03      Bug 3102439. Removed code references of IGF_AP_FA_SETUP
  ||                                commented code related to FISAP since the implementation
  ||                                is not being supported. Done as part of FA126 Build
  ||                                Commented the declarations of the following variables
  ||                                l_method, l_pct, l_fseog_cnt, l_fseog_sum,
  ||                                l_match_pct, cursor c_match_method
  ||                                and cursor variable l_method_rec.
  || veramach       13-OCT-2003     FA 124 Build Remove ISIR Requirement for Awarding
  ||                                1.Added logic to insert 2 rows into igf_aw_award_t table which holds IM/FM needs in calc_need
  ||                                2.Added logic to error out if a student does not have active ISIR in multiple fund packaging in stud_run
  ||                                3.Added logic as specified in the logic flow specified in the TD in process_stud
  ||                                4.Added logic for validations on g_sf_max_award_amt,g_sf_min_award_amt,g_allow_to_exceed in run
  ||                                5.Removed p_grp_code parameter and added p_sf_min_amount,p_sf_max_amount,p_allow_to_exceed in pkg_single_fund
  || bkkumar         30-sep-2003    FA 122 Loans Enhancemnts
  ||                                Added base_id to the get_loan_fee1 and
  ||                                get_loan_fee2 and added l_auto_late_ind
  ||                                for teh CL Loans
  ||  ugummall      25-SEP-2003     FA 126 - Multiple FA Offices.
  ||                                added new parameter assoc_org_num to
  ||                                igf_ap_fa_base_rec_pkg.update_row call.
  ||
      bkkumar       27-Aug-2003     Bug# 3071157 Added explicit date format mask to the
                                    to_date() function.
      sjadhav       06-Aug-2003     Bug 3062062
                                    Modified  post_award.
                                    Added check to not create award if there
                                    are no disbursements
  ||  sjadhav       24-Jun-2003     Bug 2983181. elig status populated with 'N'
  ||  bkkumar         04-jun-2003   Bug #2858504
  ||                                Added legacy_record_flag,award_number_txt
  ||                                in the table handler calls for
  ||                                igf_aw_award_pkg.insert_row
  ||                                Added legacy_record_flag
  ||                                in the table handler calls for igf_ap_td_item_inst_pkg.insert_row
  ||
  ||  rasahoo       19-May-2003     Bug # 2860836
  ||                                Added exception handling for resolving
  ||                                locking problem created by fund manager
  ||  brajendr      07-Mar-2003     Bug # 2829487
  ||                                Added the call to update the Process status of the student after adding the TO Do Items
  ||
  ||  brajendr      27-Feb-2003     Bug # 2662487
  ||                                Modified the rounding off logic.
  ||
  ||  cdcruz        05-Feb-2003     Bug # 2758804
  ||                                Modified the ISIR record being picked as part of FACR105
  ||
  ||  brajendr      08-Jan-2003     Bug # 2762648
  ||                                Removed Function validate_student_efc call as this validation is necessary only for Packaging Process
  ||
  ||  brajendr      09-Jan-2003     Bug # 2740222
  ||                                Added different messages for each validation and gave more clarity in the log file.
  ||
  ||  brajendr      09-Jan-2003     Bug # 2733847 Modified the code for calculating the Running Totals and Last Disbursement.
  ||                                Bug # 2742000 Modified the logic for updating Notification Status.
  ||                                Earlier notification status is done only for Auto Packaging
  ||
  ||  brajendr      08-Jan-2003     Bug # 2710314
  ||                                Added a Function validate_student_efc
  ||                                for checking the validity of EFC
  ||
  ||  brajendr      18-Dec-2002     Bug # 2711114
  ||                                Added a new token for message IGF_AW_AWD_FUND_HOLD_FAIL
  ||
  ||  brajendr      18-Dec-2002     Bug # 2691832
  ||                                Modified the logic for updating the Packaging Status.
  ||
  ||  brajendr      17-Dec-2002     Bug # 2686797
  ||                                Modified the logic to round off the Amounts to 2 decimals before creating the disbursements.
  ||                                Last disb amouts are calculated using the remaining amount at the award level.
  ||
  ||  brajendr      10-Dec-2002     Bug # 2701470
  ||                                Modified the logic for not validating the packaging status for single fund process
  ||
  ||  brajendr      09-Dec-2002     Bug # 2676394
  ||                                Removed the referrences of the EFC from igf_ap_efc_det table to igf_ap_isir_matched table.
  ||                                Used igf_aw_packng_subfns.get_fed_efc to calculate the EFC
  ||
  ||  brajendr      07-NOV-2002     Bug # 2613536
  ||                                Added the code to skip the fund if there are holds for the person
  ||
  ||  brajendr      24-Oct-2002     FA105 / FA108 Builds
  ||                                Refer TDs for the changes
  ||
  ||  CDCRUZ        22-Oct-2002     FA105 / FA108 Build
  ||                                removes a parameter from igf_ap_efc_calc.get_efc_no_of_months
  ||
  ||  brajendr      18-Oct-2002     Bug : 2591643
  ||                                Modified the chk_todo_result for FA104 - To Do Enhancements
  ||
  ||  sjadhav                       Bug 2411031
  ||                                Changed sequence of calling igf_sl_award.get_loan_amts and
  ||                                igf_sl_roundoff_digits_pkg.gross_fees_roundoff. This is done
  ||                                becuase first round off disbursement gross amount should be
  ||                                calculated first and then net amount / fee amount etc
  ||
  ||  CDCRUZ        12-JUN-2002     Bug ID  : 2412897
  ||                                Prkins loan was still included for Stafford Loan Limits chk
  ||
  ||
  ||  CDCRUZ        07-JUN-2002     Bug ID  : 2405510
  ||                                Students with Packaging Hold should not be packaged
  ||
  ||  CDCRUZ        05-JUN-2002     Bug ID  : 2400556
  ||                                The group level maximum limits running totals were getting updated
  ||                                only for Non Entitlement Funds .
  ||                                Even though Entitlement bypasses this validation the running total
  ||                                As a result of this entitlement has to be updated for future funds.
  ||
  ||  adhawan       02-may-2002     Bug ID  : 2330105
  ||                                Removed the logic , {If the Individual Packaging is set to "Y"
  ||                                and manually packaged is set to "N" then Packaging should skip that fund}
  ||
  ||  sjadhav       12-sep-2001     Bug ID  : 1978618
  ||                                added exception param_err
  ||                                removed hard coded messages
  ||
  ||  sjadhav       24-jul-2001     Bug ID  : 1818617
  ||                                added parameter p_get_recent_info
  ||
  ||  skoppula      26-apr-2002     Bug :2317853
  ||                                Changed the cursor in process_stud that is raising invalid
  ||                                NUMBER exception
  ||
  ||  pmarada       14-feb-2002     FACR008-correspondence Build,2213043
  ||                                Added a  p_upd_awd_notif_status parameter in run and post_award.
  ||                                as part of FACR008-Correspondence build.
  ||
  ||  ssawhney      31-Oct-2001     Introduce changes in packaging due to FISAP.
  ||                                Check the percentage of matching funds for an FSEOG fund
  ||                                Modified process_stud () and update_fund ().
  ||
  ||  pmarada       23-Jul-2001     Bug ID : 1818617
  ||                                OSS Interface usage was changde to pick the
  ||                                attributes from FA-Base-History record
  ||
  ||  sjadhav       May-21-2001     Bug ID : 1747948
  ||                                1.  Added one more parameter Group_Code in the callable 'run'
  ||                                2.  Added new cursor to get enrollment details from
  ||                                    OSS Interface table
  ||                                3.  In Stud_Run, a student is skipped if it fails conditions
  ||
  ||  avenkatr      15-May-2001     Bug Id : 1755969 Maximum NUMBER of terms
  ||                                1. Added check to test if Aid exceeds Max Award
  ||                                   amount given in Fund manager in stud_run procedure.
  ||
  ||  avenkatr      01-May-2001     Bug Id : 1755969 Maximum NUMBER of terms
  ||                                1. Corrected the check for Max NUMBER of terms of a fund.
  ||
  ||  avenkatr      01-May-2001     Bug Id : 1754396 General Award Issues
  ||                                1. Added check to continue awarding for 'Replace FC'
  ||                                   funds even WHEN Need is over.
  ||                                2. Corrected the 'OverAward' check for funds.
  ||                                3. Updated the remaining amt of the fund if the awards are
  ||                                   packaged
  ||
  ||  avenkatr      25-APR-2001     Bug Id : 1750254 Self Help Limits.
  ||                                1. Corrected the variable used for checking self help in
  ||                                   procedure stud_run.
  ||                                2. Added clear_simulation in stud_run procedure
  ||
  ||  avenkatr      19-APR-2001     Bug Id : 1726280 Rounding off process for Direct Loans.
  ||                                1. Corrected the variable used for printing
  ||                                   the Disbursement Gross amount.
  ||
  ||  mesriniv      20-APR-2001     Bug Id : 1723272 Process Requests.
  ||                                1.In the Procedure post_award,Added a cursor c_person_number
  ||                                  to fetch the person number for the Base Id.
  ||                                2.Changed the Prompt and variable (l_base_id)
  ||                                  for Display of Person number.
  ||
  ||  avenkatr      19-APR-2001     Bug Id : 1726280 Rounding off process for Direct Loans.
  ||                                1. Corrected the variable used for printing the
  ||                                   Disbursement Gross amount.
  ||                                2. Corrected the NVL(offered_amt, accepted_amt) to
  ||                                   NVL( accepted_amt, offered_amt) in procedures
  ||                                   stud_run and post_award.
  ||                                3. Removed the NVL for accepted_amt in the c_awd_grp
  ||                                   cursor of stud_run procedure.
  ||
  ||  prchandr      06-APR-2001     Bug Id : 1726280 Rounding off process for Direct Loans.
  ||                                In procedure "post_award", a call is made to
  ||                                round off procedure incase of direct loans.
  ||                                Rounding off process. A call is made to roundoff process package
  ||

  || The Packaging for a Run Code/Target Group/Individual Student is done in this pkg
  ||
  || Pre-requisites
  || The following tables have to be populated before calling this process
  || igf_fa_base_rec
  || igf_aw_fund_mast
  || igf_aw_ssn_tp
  ||
  || The Cost of Attendance Process must be run before Running Packaging


    -------------------------------------------------------------------------------
    Important : The following are the statuses present for the igf_aw_award_t.flag
    -------------------------------------------------------------------------------
    AA - Already Awarded fund to the student.(Will exist only if the student has awards)
    AW - Selected for Award, before Fund checks.
    CF - Initial loaded INTO the temporary table.
    DB - Disbursements of the Fund.
    FL - Final Indication : Fund Ready to award after fund validations.
    LD - Load Calendar details of the Fund.
    ND - Need Calculated for the Fund.(Will exist only if the student does not have existing awards
    OV - Over Award Indicator of the Fund.
    RF - Rejected fund while Exclusive and Inclusive checks.
    ST - Loaded students as per decreaseing need
    AL - Awards loaded for the student and locked.
    AU - Awards which are candidates for repackaging(Awards which are unlocked)
    AC - Awards cancelled due to some reason,during repackaging
    AR - Awards cancelled due to Exclusive Inclusive Checks
    -------------------------------------------------------------------------------
  */

  g_sf_min_amount         NUMBER;
  g_sf_max_amount         NUMBER;
  g_persid_grp            NUMBER := NULL;
  g_over_awd              VARCHAR2(30);
  g_upd_awd_notif_status  VARCHAR2(30);
  g_verif_stat            VARCHAR2(10);
--  g_sf_packaging          VARCHAR2(1) := 'F';
  g_sf_packaging          VARCHAR2(1);
  g_allow_to_exceed       igf_lookups_view.lookup_code%TYPE;
  g_fm_fc_methd           igf_aw_fund_mast_all.fm_fc_methd%TYPE;
  g_ci_cal_type           igs_ca_inst_all.cal_type%TYPE;
  g_ci_sequence           igs_ca_inst_all.sequence_number%TYPE;
  g_sf_fund               igf_aw_fund_mast_all.fund_id%TYPE;

  g_pell_tab       igf_gr_pell_calc.pell_tab := igf_gr_pell_calc.pell_tab();

  PARAM_ERR          EXCEPTION;
  NON_MERGABLE_FUNDS EXCEPTION;
  INVALID_DISTR_PLAN EXCEPTION;
  INV_FWS_AWARD      EXCEPTION;
  PELL_NO_REPACK     EXCEPTION;

  TYPE std_awards IS RECORD(
                            award_id      NUMBER,
                            award         NUMBER,
                            fund_id       NUMBER,
                            replace_fc    igf_aw_fund_mast_all.replace_fc%TYPE,
                            update_need   igf_aw_fund_mast_all.update_need%TYPE,
                            entitlement   igf_aw_fund_mast_all.entitlement%TYPE,
                            fed_fund_code igf_aw_fund_cat_all.fed_fund_code%TYPE,
                            fm_fc_methd   igf_aw_fund_mast_all.fm_fc_methd%TYPE
                           );


  TYPE std_aid IS RECORD(
                         base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                         need_f       igf_ap_fa_base_rec_all.need_f%TYPE,
                         awarded_aid  igf_aw_award_all.offered_amt%TYPE
                        );

  TYPE std_aid_tab IS TABLE OF std_aid;

  TYPE fund_awd IS RECORD(
                         base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                         fund_id    igf_aw_fund_mast_all.fund_id%TYPE,
                         awd_prct   NUMBER
                        );

  TYPE std_fund_awd IS TABLE OF fund_awd;

  g_fund_awd_prct         std_fund_awd := std_fund_awd();
  g_awarded_aid           std_aid_tab  := std_aid_tab();

  FUNCTION check_disb(
                      p_base_id     igf_ap_fa_base_rec_all.base_id%TYPE,
                      p_adplans_id  igf_aw_awd_dist_plans.adplans_id%TYPE,
                      p_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                     ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 21-Jun-2004
  --
  --Purpose:
  -- bug 3709109 -> FWS funds can have only one disbursement per term
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  CURSOR c_term_wcoa(
                     cp_adplans_id  igf_aw_awd_dist_plans.adplans_id%TYPE,
                     cp_award_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                    ) IS
    SELECT COUNT(tp.adteach_id) tp,
           COUNT(DISTINCT terms.adterms_id) terms
      FROM igf_aw_dp_teach_prds tp,
           igf_aw_dp_terms terms,
           igf_aw_awd_dist_plans dp,
           igf_aw_awd_prd_term aprd
     WHERE terms.adterms_id = tp.adterms_id
       AND terms.adplans_id = cp_adplans_id
       AND terms.adplans_id = dp.adplans_id
       AND dp.cal_type = aprd.ci_cal_type
       AND dp.sequence_number = aprd.ci_sequence_number
       AND aprd.ld_cal_type = terms.ld_cal_type
       AND aprd.ld_sequence_number = terms.ld_sequence_number
       AND aprd.award_prd_cd = cp_award_prd_code;

  CURSOR c_term(
                cp_base_id     igf_ap_fa_base_rec_all.base_id%TYPE,
                cp_adplans_id  igf_aw_awd_dist_plans.adplans_id%TYPE,
                cp_award_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
               ) IS
    SELECT COUNT(tp.adteach_id) tp,
           COUNT(DISTINCT terms.adterms_id) terms
      FROM igf_aw_dp_teach_prds tp,
           igf_aw_dp_terms terms,
           (SELECT   base_id,
                     ld_cal_type,
                     ld_sequence_number
                FROM igf_aw_coa_itm_terms
               WHERE base_id = cp_base_id
            GROUP BY base_id, ld_cal_type, ld_sequence_number) coaterms,
            igf_aw_awd_prd_term aprd,
            igf_aw_awd_dist_plans dp
     WHERE terms.adterms_id = tp.adterms_id
       AND terms.adplans_id = cp_adplans_id
       AND coaterms.ld_cal_type = terms.ld_cal_type
       AND coaterms.ld_sequence_number = terms.ld_sequence_number
       AND coaterms.base_id = cp_base_id
       AND dp.adplans_id = terms.adplans_id
       AND dp.cal_type = aprd.ci_cal_type
       AND dp.sequence_number = aprd.ci_sequence_number
       AND aprd.ld_cal_type = terms.ld_cal_type
       AND aprd.ld_sequence_number = terms.ld_sequence_number
       AND aprd.award_prd_cd = cp_award_prd_code;

  l_tot_teach_prds      NUMBER;
  l_tot_terms           NUMBER;

  BEGIN
      IF NOT igf_aw_gen_003.check_coa(p_base_id,p_awd_prd_code) THEN
        OPEN c_term_wcoa(p_adplans_id,p_awd_prd_code);
        FETCH c_term_wcoa INTO l_tot_teach_prds,l_tot_terms;
        CLOSE c_term_wcoa;
      ELSE
        OPEN c_term(p_base_id,p_adplans_id,p_awd_prd_code);
        FETCH c_term INTO l_tot_teach_prds,l_tot_terms;
        CLOSE c_term;
      END IF;

      IF l_tot_teach_prds <> l_tot_terms THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
  END check_disb;

  FUNCTION get_fed_fund_code(
                             p_fund_id NUMBER
                            ) RETURN VARCHAR2 IS
    CURSOR cur_get_fund  (p_fund_id NUMBER)
    IS
    SELECT fcat.fed_fund_code
    FROM   igf_aw_fund_cat fcat,
           igf_aw_fund_mast fmast
   WHERE   fcat.fund_code = fmast.fund_code
     AND   fmast.fund_id = p_fund_id;

    get_fund_rec cur_get_fund%ROWTYPE;

  BEGIN
    OPEN  cur_get_fund(p_fund_id);
    FETCH cur_get_fund INTO get_fund_rec;
    CLOSE cur_get_fund;

    RETURN get_fund_rec.fed_fund_code;

  END get_fed_fund_code;

  FUNCTION get_sys_fund_type(
                             p_fund_id NUMBER
                            ) RETURN VARCHAR2 IS
    CURSOR cur_get_fund_type(
                             p_fund_id NUMBER
                            ) IS
    SELECT fcat.sys_fund_type
      FROM igf_aw_fund_cat fcat,
           igf_aw_fund_mast fmast
     WHERE fcat.fund_code = fmast.fund_code
       AND fmast.fund_id = p_fund_id;

    get_fund_rec cur_get_fund_type%ROWTYPE;

  BEGIN
    OPEN  cur_get_fund_type(p_fund_id);
    FETCH cur_get_fund_type INTO get_fund_rec;
    CLOSE cur_get_fund_type;
    RETURN get_fund_rec.sys_fund_type;
  END get_sys_fund_type;

  FUNCTION get_disb_round_factor(
                                  p_fund_id   IN igf_aw_fund_mast.fund_id%TYPE
                                )
  RETURN VARCHAR2
  IS
        /*
        ||  Created By : museshad
        ||  Created On : 05-Jun-2005
        ||  Purpose :   Build# FA157 - Bug# 4382371
        ||              Returns the disbursement rounding factor setup
        ||              for the given fund
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             WHEN            What
        ||  (reverse chronological order - newest change first)
        */
      CURSOR c_get_disb_round_factor(cp_fund_id igf_aw_fund_mast.fund_id%TYPE)
      IS
          SELECT disb_rounding_code
          FROM igf_aw_fund_mast
          WHERE fund_id = cp_fund_id;

      l_get_disb_round_factor c_get_disb_round_factor%ROWTYPE;
      l_disb_round_factor igf_aw_fund_mast.disb_rounding_code%TYPE := NULL;
  BEGIN
      OPEN c_get_disb_round_factor(p_fund_id);
      FETCH c_get_disb_round_factor INTO l_get_disb_round_factor;

      IF (c_get_disb_round_factor%NOTFOUND) THEN
          l_disb_round_factor := NULL;
      ELSE
          l_disb_round_factor := l_get_disb_round_factor.disb_rounding_code;
      END IF;

      RETURN l_disb_round_factor;
  END get_disb_round_factor;

  FUNCTION get_prog_elig(
                          p_prog_cd     IN    igs_ps_ver_v.course_cd%type,
                          p_prog_ver    IN    igs_ps_ver_v.version_number%type,
                          p_fund_source IN    igf_aw_fund_cat_all.fund_source%type
                        )
  RETURN BOOLEAN
  IS
      ------------------------------------------------------------------
      --Created by  : museshad
      --Date created: 14-Jun-2005
      --
      --Purpose:  Build# FA157 - Bug# 4382371.
      --          Checks if the Program is eligible for the given fund.
      --          When the Program details are got from actual data, the
      --          version number of the program is also taken into consideration
      --          to determine the eligibility. However, if the program details
      --          are got from anticipated data, then the version details are not
      --          available, bcoz the anticipated data does not define it.
      --          In this case, if any one version of the program is eligible for
      --          the fund, then the program is considered to be eligible.
      --Known limitations/enhancements and/or remarks:
      --
      --Change History:
      --Who         When            What
      -------------------------------------------------------------------

      -- Check program eligibility for actual data
      CURSOR c_chk_prog_elig_with_ver(
                                        cp_stud_program_cd  igs_ps_ver_v.course_cd%type,
                                        cp_stud_program_ver igs_ps_ver_v.version_number%type,
                                        cp_fund_source      igf_aw_fund_cat_all.fund_source%type
                                      )
      IS
          SELECT DECODE(cp_fund_source,
                        'STATE', UPPER(state_financial_aid),
                        'FEDERAL', UPPER(federal_financial_aid),
                        'INSTITUTIONAL', UPPER(institutional_financial_aid),
                        NULL) prog_eligibility
          FROM IGS_PS_VER_V
          WHERE course_cd       = cp_stud_program_cd AND
                version_number  = cp_stud_program_ver;

      l_chk_prog_elig_with_ver c_chk_prog_elig_with_ver%ROWTYPE;

      -- Check program eligibility for anticipated data
      CURSOR c_chk_prog_elig_wout_ver(
                                        cp_stud_program_cd  igs_ps_ver_v.course_cd%type,
                                        cp_fund_source      igf_aw_fund_cat_all.fund_source%type
                                      )
      IS
          SELECT 'x' FROM dual
          WHERE EXISTS
                      ( SELECT * FROM IGS_PS_VER_V
                        WHERE course_cd = cp_stud_program_cd AND
                              DECODE(cp_fund_source,
                                    'STATE', UPPER(state_financial_aid),
                                    'FEDERAL', UPPER(federal_financial_aid),
                                    'INSTITUTIONAL', UPPER(institutional_financial_aid),
                                     NULL)  = 'Y'
                      );

      l_chk_prog_elig_wout_ver c_chk_prog_elig_wout_ver%ROWTYPE;
      l_prog_eligibility BOOLEAN;

  BEGIN

      -- When the Program details are got from actual data, the version
      -- details are available
      IF p_prog_ver IS NOT NULL THEN        -- p_prog_ver
         OPEN c_chk_prog_elig_with_ver(p_prog_cd, p_prog_ver, p_fund_source);
         FETCH c_chk_prog_elig_with_ver INTO l_chk_prog_elig_with_ver;

        IF (c_chk_prog_elig_with_ver%FOUND) THEN      -- l_chk_prog_elig_with_ver
          IF l_chk_prog_elig_with_ver.prog_eligibility = 'Y' THEN
            l_prog_eligibility := TRUE;
          ELSE
            l_prog_eligibility := FALSE;
          END IF;
        END IF;     -- End of l_chk_prog_elig_with_ver
        CLOSE c_chk_prog_elig_with_ver;

      -- When the Program details are got from anticipated data, the version
      -- details are not available
      ELSE
        OPEN c_chk_prog_elig_wout_ver(p_prog_cd, p_fund_source);
        FETCH c_chk_prog_elig_wout_ver INTO l_chk_prog_elig_wout_ver;

        IF (c_chk_prog_elig_wout_ver%FOUND) THEN
          l_prog_eligibility := TRUE;
        ELSE
          l_prog_eligibility := FALSE;
        END IF;
        CLOSE c_chk_prog_elig_wout_ver;
      END IF;       -- End of p_prog_ver

      RETURN l_prog_eligibility;
  END get_prog_elig;

  FUNCTION get_term_start_date(
                               p_base_id            IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_ld_cal_type        IN    igs_ca_inst.cal_type%TYPE,
                               p_ld_sequence_number IN    igs_ca_inst.sequence_number%TYPE
                              )
  RETURN DATE
  IS
      ------------------------------------------------------------------
      --Created by    :   museshad
      --Date created  :   29-Jun-2005
      --
      --Purpose       :   Build# FA157 - Bug# 4382371.
      --                  Returns the start date of the term passed as parameter

      --Known limitations/enhancements and/or remarks:
      --
      --Change History:
      --Who         When            What
      -------------------------------------------------------------------
      l_program_cd          igs_ps_ver_all.course_cd%TYPE;
      l_version_num         igs_ps_ver_all.version_number%TYPE;
      l_program_type        igs_ps_ver_all.course_type%TYPE;
      l_org_unit            igs_ps_ver_all.responsible_org_unit_cd%TYPE;
      l_term_start_date     DATE := NULL;
      l_term_end_date       DATE := NULL;

  BEGIN

      -- Log values
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,
                       'igf.plsql.igf_aw_packaging.get_term_start_date.debug '|| g_req_id,
                       'IGF_AP_GEN_001.get_term_dates called with the following parameters: p_base_id/p_ld_cal_type/p_ld_sequence_number = ' ||p_base_id|| '/' ||p_ld_cal_type|| '/' ||p_ld_sequence_number);
      END IF;

      -- Get term's start date
      IGF_AP_GEN_001.get_term_dates (
                                      p_base_id,
                                      p_ld_cal_type,
                                      p_ld_sequence_number,
                                      l_term_start_date,
                                      l_term_end_date
                                    );

      -- Log Values
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_packaging.get_term_start_date.debug '|| g_req_id,
                        'After calling igs_ca_compute_da_val_pkg.cal_da_elt_val -> Start date of term ld_cal_type: ' ||p_ld_cal_type|| ', ld_sequence_number: ' ||p_ld_sequence_number|| ' is ' ||l_term_start_date
                        );
      END IF;

    RETURN l_term_start_date;
  END get_term_start_date;

  PROCEDURE get_plan_desc(
                          p_adplans_id  IN          igf_aw_awd_dist_plans.adplans_id%TYPE,
                          p_method_name OUT NOCOPY  igf_aw_awd_dist_plans.awd_dist_plan_cd_desc%TYPE,
                          p_method_desc OUT NOCOPY  igf_aw_awd_dist_plans_v.dist_plan_method_code_desc%TYPE
                         ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  -- Get get plan desc
  CURSOR c_plan(
                cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
               ) IS
    SELECT awd_dist_plan_cd_desc,
           dist_plan_method_code_desc
      FROM igf_aw_awd_dist_plans_v
     WHERE adplans_id = cp_adplans_id;
  l_plan c_plan%ROWTYPE;

  BEGIN
    OPEN c_plan(p_adplans_id);
    FETCH c_plan INTO l_plan;
    CLOSE c_plan;

    IF l_plan.awd_dist_plan_cd_desc IS NOT NULL AND l_plan.dist_plan_method_code_desc IS NOT NULL THEN
      p_method_name := l_plan.awd_dist_plan_cd_desc;
      p_method_desc := l_plan.dist_plan_method_code_desc;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.GET_PLAN_DESC '|| SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.get_plan_desc.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;
  END get_plan_desc;

  PROCEDURE setAPProcStat(
                          p_base_id              igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_award_prd_cd         igf_aw_award_prd.award_prd_cd%TYPE,
                          p_awd_proc_status_code igf_aw_award_all.awd_proc_status_code%TYPE
                         ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 10/September/2005
  --
  --Purpose:
  --   Sets the award process status for an awarding period
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  l_ci_cal_type        igs_ca_inst_all.cal_type%TYPE;
  l_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE;

  CURSOR c_awards IS
    SELECT awd.ROWID row_id,
           awd.*
      FROM igf_aw_award_all awd,
           igf_aw_fund_mast_all fmast
     WHERE fmast.ci_cal_type = l_ci_cal_type
       AND fmast.ci_sequence_number = l_ci_sequence_number
       AND awd.fund_id = fmast.fund_id
       AND awd.base_id = p_base_id
       AND NOT EXISTS(
              SELECT disb.ld_cal_type,
                     disb.ld_sequence_number
                FROM igf_aw_awd_disb_all disb
               WHERE disb.award_id = awd.award_id
              MINUS
              SELECT ld_cal_type,
                     ld_sequence_number
                FROM igf_aw_awd_prd_term apt
               WHERE apt.ci_cal_type = l_ci_cal_type
                 AND apt.ci_sequence_number = l_ci_sequence_number
                 AND apt.award_prd_cd = p_award_prd_cd);


  CURSOR c_cal IS
    SELECT fa.ci_cal_type,
           fa.ci_sequence_number
      FROM igf_ap_fa_base_rec_all fa
     WHERE fa.base_id = p_base_id;

  BEGIN

    OPEN c_cal;
    FETCH c_cal INTO l_ci_cal_type,l_ci_sequence_number;
    CLOSE c_cal;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.setAPProcStat.debug '|| g_req_id,'l_ci_cal_type:'||l_ci_cal_type||' l_ci_sequence_number:'||l_ci_sequence_number);
    END IF;

    FOR l_awards IN c_awards LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.setAPProcStat.debug '|| g_req_id,'l_awards.award_id:'||l_awards.award_id);
      END IF;
      igf_aw_award_pkg.update_row(
                                  x_rowid              => l_awards.row_id,
                                  x_award_id           => l_awards.award_id,
                                  x_fund_id            => l_awards.fund_id,
                                  x_base_id            => l_awards.base_id,
                                  x_offered_amt        => l_awards.offered_amt,
                                  x_accepted_amt       => l_awards.accepted_amt,
                                  x_paid_amt           => l_awards.paid_amt,
                                  x_packaging_type     => l_awards.packaging_type,
                                  x_batch_id           => l_awards.batch_id,
                                  x_manual_update      => l_awards.manual_update,
                                  x_rules_override     => l_awards.rules_override,
                                  x_award_date         => l_awards.award_date,
                                  x_award_status       => l_awards.award_status,
                                  x_attribute_category => l_awards.attribute_category,
                                  x_attribute1         => l_awards.attribute1,
                                  x_attribute2         => l_awards.attribute2,
                                  x_attribute3         => l_awards.attribute3,
                                  x_attribute4         => l_awards.attribute4,
                                  x_attribute5         => l_awards.attribute5,
                                  x_attribute6         => l_awards.attribute6,
                                  x_attribute7         => l_awards.attribute7,
                                  x_attribute8         => l_awards.attribute8,
                                  x_attribute9         => l_awards.attribute9,
                                  x_attribute10        => l_awards.attribute10,
                                  x_attribute11        => l_awards.attribute11,
                                  x_attribute12        => l_awards.attribute12,
                                  x_attribute13        => l_awards.attribute13,
                                  x_attribute14        => l_awards.attribute14,
                                  x_attribute15        => l_awards.attribute15,
                                  x_attribute16        => l_awards.attribute16,
                                  x_attribute17        => l_awards.attribute17,
                                  x_attribute18        => l_awards.attribute18,
                                  x_attribute19        => l_awards.attribute19,
                                  x_attribute20        => l_awards.attribute20,
                                  x_rvsn_id            => l_awards.rvsn_id,
                                  x_alt_pell_schedule  => l_awards.alt_pell_schedule,
                                  x_mode               => 'R',
                                  x_award_number_txt   => l_awards.award_number_txt,
                                  x_legacy_record_flag => l_awards.legacy_record_flag,
                                  x_adplans_id         => l_awards.adplans_id,
                                  x_lock_award_flag    => l_awards.lock_award_flag,
                                  x_app_trans_num_txt  => l_awards.app_trans_num_txt,
                                  x_awd_proc_status_code => 'AWARDED',
                                  x_notification_status_code => l_awards.notification_status_code,
                                  x_notification_status_date => l_awards.notification_status_date,
                                  x_publish_in_ss_flag => l_awards.publish_in_ss_flag
                                 );
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.setAPProcStat '|| SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.setAPProcStat.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;
  END setAPProcStat;

  PROCEDURE calc_students_needs(
                                p_base_id           igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_coa               igf_ap_fa_base_rec_all.coa_f%TYPE
                               ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who          When            What
    ||  brajendr     09-Dec-2002     Bug # 2676394
    ||                               Removed the referrences of the EFC from igf_ap_efc_det table to igf_ap_isir_matched table.
    ||                               Used igf_aw_packng_subfns.get_fed_efc to calculate the EFC
    ||  (reverse chronological order - newest change first)
    */
   l_efc_months   NUMBER;
   lv_rowid       ROWID;
   l_sl_number    NUMBER;
   l_normal_efc   igf_ap_isir_matched_all.paid_efc%TYPE  := 0;
   l_pell_efc     igf_ap_isir_matched_all.paid_efc%TYPE  := 0;
   l_efc_ay       NUMBER := 0;
  BEGIN

    -- Get the month for which EFC should be calcualted
    l_efc_months :=  igf_aw_coa_gen.coa_duration(p_base_id,g_awd_prd);

    IF l_efc_months > 12 OR l_efc_months < 0 THEN
      l_efc_months := 12;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_students_need.debug '|| g_req_id,' Calculating students need for l_efc_months: '||l_efc_months);
    END IF;

    -- Get the EFC value for Federal Methodology
    igf_aw_packng_subfns.get_fed_efc(
                                     p_base_id,
                                     g_awd_prd,
                                     l_normal_efc,
                                     l_pell_efc,
                                     l_efc_ay
                                    );

    -- Insert the Student into Temp Table.
    lv_rowid    := NULL;
    l_sl_number := NULL;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_students_need.debug '|| g_req_id,'Calculated NEED values are l_normal_efc: '||l_normal_efc||' and p_coa : '||p_coa);
    END IF;

    igf_aw_award_t_pkg.insert_row(
                                  x_rowid              => lv_rowid ,
                                  x_process_id         => l_process_id ,
                                  x_sl_number          => l_sl_number,
                                  x_fund_id            => NULL,
                                  x_base_id            => p_base_id,
                                  x_offered_amt        => NULL,
                                  x_accepted_amt       => NULL,
                                  x_paid_amt           => NULL,
                                  x_need_reduction_amt => NULL,
                                  x_flag               => 'ST',
                                  x_temp_num_val1      => l_normal_efc,           -- Students EFC
                                  x_temp_num_val2      => p_coa - l_normal_efc,   -- Students Need
                                  x_temp_char_val1     => NULL,
                                  x_tp_cal_type        => NULL,
                                  x_tp_sequence_number => NULL,
                                  x_ld_cal_type        => NULL,
                                  x_ld_sequence_number => NULL,
                                  x_mode               => 'R',
                                  x_adplans_id         => NULL,
                                  x_app_trans_num_txt  => NULL,
                                  x_award_id           => NULL,
                                  x_lock_award_flag    => NULL,
                                  x_temp_val3_num      => NULL,
                                  x_temp_val4_num      => NULL,
                                  x_temp_char2_txt     => NULL,
                                  x_temp_char3_txt     => NULL
                                 );

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.CALC_STUDENTS_NEEDS '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.calc_students_need.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;

  END calc_students_needs;

  PROCEDURE check_plan(
                       p_adplans_id    IN          igf_aw_awd_dist_plans.adplans_id%TYPE,
                       p_result        OUT NOCOPY  VARCHAR2,
                       p_method_code   OUT NOCOPY  igf_aw_awd_dist_plans.dist_plan_method_code%TYPE
                      ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 20-NOV-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    --cursor to get distribution plan code
    CURSOR cur_get_plan_cd(
                           cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                          ) IS
      SELECT awd_dist_plan_cd,
             awd_dist_plan_cd_desc,
             dist_plan_method_code
        FROM igf_aw_awd_dist_plans
       WHERE adplans_id = cp_adplans_id;
    l_get_plan_cd cur_get_plan_cd%ROWTYPE;

  BEGIN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.check_plan.debug '|| g_req_id,'p_adplans_id:'||p_adplans_id);
    END IF;
    p_result := 'TRUE';

    OPEN cur_get_plan_cd(p_adplans_id);
    FETCH cur_get_plan_cd INTO l_get_plan_cd;

    IF cur_get_plan_cd%NOTFOUND THEN
      p_result := 'IGF_AW_DIST_CODE_FAIL';
      CLOSE cur_get_plan_cd;
    ELSE
      CLOSE cur_get_plan_cd;
      igf_aw_gen.check_ld_cal_tps(p_adplans_id,p_result);
      IF p_result = 'TRUE' THEN
        p_method_code := l_get_plan_cd.dist_plan_method_code;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.check_plan.debug '|| g_req_id,'p_method_code:'||p_method_code);
        END IF;
      END IF;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.check_plan.exception '|| g_req_id,'sql error:'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_PACKAGING.CHECK_PLAN '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END check_plan;

  PROCEDURE group_run(
                      l_group_code         IN VARCHAR2,
                      l_ci_cal_type        IN VARCHAR2 ,
                      l_ci_sequence_number IN NUMBER,
                      l_post               IN VARCHAR2,
                      l_run_mode           IN VARCHAR2
                     ) IS
    /*
    ||  Created By : cdcruz
    ||  Created On : 14-NOV-2000
    ||  Purpose : Packages for each student in the given group
    ||            This Target Group is attached for each student in the Base Record.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    */

    -- All students who fall within the current Target group are processed
    CURSOR c_group(
                   x_group_code         igf_aw_target_grp_all.group_cd%TYPE ,
                   x_ci_cal_type        igf_ap_fa_base_rec_all.ci_cal_type%TYPE ,
                   x_ci_sequence_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                  ) IS
    SELECT fa_detail.base_id,
           igf_aw_coa_gen.coa_amount(fa_detail.base_id,g_awd_prd) coa_f
      FROM igf_ap_fa_base_rec fa_detail
     WHERE fa_detail.ci_cal_type        = x_ci_cal_type
       AND fa_detail.ci_sequence_number = x_ci_sequence_number
       AND fa_detail.target_group       = x_group_code;

    l_group c_group%ROWTYPE;

    -- Get the details of students from the Temp Table in the descending order of their needs
    CURSOR c_ordered_stdnts IS
    SELECT base_id
      FROM igf_aw_award_t
     WHERE flag = 'ST'
       AND process_id = l_process_id
     ORDER BY temp_num_val2 DESC;

    l_error_code NUMBER;

  BEGIN

    get_process_id;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.group_run.debug '|| g_req_id,'starting group_run with l_group_code:'||l_group_code||' l_ci_cal_type:'||l_ci_cal_type||' l_ci_sequence_number:'||l_ci_sequence_number);
    END IF;

    OPEN c_group(
                 l_group_code ,
                 l_ci_cal_type ,
                 l_ci_sequence_number
                );
    FETCH c_group INTO l_group;
    IF ( c_group%NOTFOUND ) THEN
      fnd_message.set_name('IGF','IGF_AW_NO_STUDENTS');
      fnd_message.set_token('CODE', l_group_code );
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log,' ');

    ELSE

      -- Run for each student in the Given group. Insert the Calculated Need into the Temp Table. After calculating the
      -- Need for all students, Fetch the students from the Temp table in the decending order of their Federal Need.
      -- This is to ensure that "Students who is having more need will get awarded first"
      LOOP
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.group_run.debug '|| g_req_id,'inside c_group%FOUND');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.group_run.debug '|| g_req_id,'calling calc_students_need');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.group_run.debug '|| g_req_id,'l_group.base_id:'||l_group.base_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.group_run.debug '|| g_req_id,'l_group.coa_f:'||l_group.coa_f);
        END IF;
        calc_students_needs(
                            l_group.base_id,
                            l_group.coa_f
                           );
        FETCH c_group INTO l_group;
        EXIT WHEN c_group%NOTFOUND;
      END LOOP;

      -- Fetch the students as per the decreasing order of their need.
      FOR c_ordered_stdnts_rec IN c_ordered_stdnts LOOP

        -- Process for the student in the decending order of their needs
        g_over_awd := NULL;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.group_run.debug '|| g_req_id,'inside for loop of c_ordered_stdnts');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.group_run.debug '|| g_req_id,'calling stud_run with c_ordered_stdnts_rec.base_id:'||c_ordered_stdnts_rec.base_id);
        END IF;
        stud_run(
                 c_ordered_stdnts_rec.base_id,
                 l_post,
                 l_run_mode
                );
        IF l_post = 'N' THEN
          COMMIT;
        ELSE
          BEGIN
            ROLLBACK TO IGFAW03B_POST_AWARD;
            EXCEPTION
              WHEN OTHERS THEN
                l_error_code := SQLCODE;
                IF l_error_code = -1086 THEN
                  --savepoint not established error
                  --post_award was not called from stud_run as stud_run returned without processing the student
                  --rollback to savepoint established in stud_run
                  ROLLBACK TO STUD_SP;
                ELSE
                  RAISE;
                END IF;
          END;
        END IF;
      END LOOP;


    END IF;  -- End of c_group FOUND check
    CLOSE c_group;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.GROUP_RUN '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.group_run.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;
  END group_run;


  PROCEDURE clear_simulation( l_base_id IN NUMBER ) IS
    /*
    ||  Created By : cdcruz
    ||  Created On : 14-NOV-2000
    ||  Purpose : Clears all Simulation Awards and its Disburesement records that have created
    ||            during the previous Simulation run
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    */

    -- Retrieves all simulated disbursement records
    CURSOR c_sim_adisb ( cp_award_id igf_aw_award_all.award_id%TYPE ) IS
    SELECT adisb.rowid row_id
      FROM igf_aw_awd_disb_all adisb
     WHERE adisb.award_id   = cp_award_id;

    -- Retrieves all simulated award records
    CURSOR c_sim_awd ( cp_base_id igf_aw_award_all.base_id%TYPE ) IS
    SELECT awd.rowid row_id,
           awd.award_id
      FROM igf_aw_award_all awd
     WHERE awd.base_id      = cp_base_id
       AND awd.award_status = 'SIMULATED';

  BEGIN

    -- Remove all the Simualated disbursements first and then Remove all Simulated Awards.
    -- These simulated awards should be removed for all selected students before re-processing
    -- the packing process, so that Award amounts can be recalculated as on date
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.clear_simulation.debug '|| g_req_id,'clearing simulation records for l_base_id:'||l_base_id);
    END IF;

    FOR l_sim_awd IN c_sim_awd(l_base_id) LOOP
      FOR l_sim_adisb IN c_sim_adisb(l_sim_awd.award_id) LOOP
        igf_aw_awd_disb_pkg.delete_row(l_sim_adisb.row_id);
      END LOOP;
      igf_aw_award_pkg.delete_row(l_sim_awd.row_id);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.CLEAR_SIMULATION '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.clear_simulation.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;
  END clear_simulation;

  FUNCTION get_coa_lock_prof_val RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 25-Oct-2004
  --
  --Purpose:
  --   Returns the value of the profile 'IGF: Lock COA Budget for Student'
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  lv_profile_value fnd_profile_option_values.profile_option_value%TYPE;
  BEGIN
    fnd_profile.get('IGF_AW_LOCK_COA',lv_profile_value);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_coa_lock_prof_val.debug '|| g_req_id,'lv_profile_value:'||lv_profile_value);
    END IF;
    RETURN lv_profile_value;
  END get_coa_lock_prof_val;

  PROCEDURE update_pell_orig_stat(
                                  p_award_id igf_aw_award_all.award_id%TYPE,
                                  p_amount   igf_aw_award_all.offered_amt%TYPE
                                 ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 05-Nov-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get pell orig
  CURSOR c_pell_orig(
                     cp_award_id igf_aw_award_all.award_id%TYPE,
                     cp_amount   igf_aw_award_all.offered_amt%TYPE
                    ) IS
    SELECT rfms.rowid row_id,
           rfms.*
      FROM igf_gr_rfms_all rfms
     WHERE award_id = cp_award_id
       AND pell_amount <> cp_amount
       AND orig_action_code <> 'S';
  l_orig_action_code igf_gr_rfms_all.orig_action_code%TYPE;

  BEGIN
    FOR l_pell_orig IN c_pell_orig(p_award_id,p_amount) LOOP
      IF l_pell_orig.orig_action_code = 'N' THEN
        l_orig_action_code := 'N';
      ELSE
        l_orig_action_code := 'R';
      END IF;
      igf_gr_rfms_pkg.update_row(
                                 x_rowid                   => l_pell_orig.row_id,
                                 x_origination_id          => l_pell_orig.origination_id,
                                 x_ci_cal_type             => l_pell_orig.ci_cal_type,
                                 x_ci_sequence_number      => l_pell_orig.ci_sequence_number,
                                 x_base_id                 => l_pell_orig.base_id,
                                 x_award_id                => l_pell_orig.award_id,
                                 x_rfmb_id                 => l_pell_orig.rfmb_id,
                                 x_sys_orig_ssn            => l_pell_orig.sys_orig_ssn,
                                 x_sys_orig_name_cd        => l_pell_orig.sys_orig_name_cd,
                                 x_transaction_num         => l_pell_orig.transaction_num,
                                 x_efc                     => l_pell_orig.efc,
                                 x_ver_status_code         => l_pell_orig.ver_status_code,
                                 x_secondary_efc           => l_pell_orig.secondary_efc,
                                 x_secondary_efc_cd        => l_pell_orig.secondary_efc_cd,
                                 x_pell_amount             => p_amount,--update with new award amount
                                 x_pell_profile            => l_pell_orig.pell_profile,
                                 x_enrollment_status       => l_pell_orig.enrollment_status,
                                 x_enrollment_dt           => l_pell_orig.enrollment_dt,
                                 x_coa_amount              => l_pell_orig.coa_amount,
                                 x_academic_calendar       => l_pell_orig.academic_calendar,
                                 x_payment_method          => l_pell_orig.payment_method,
                                 x_total_pymt_prds         => l_pell_orig.total_pymt_prds,
                                 x_incrcd_fed_pell_rcp_cd  => l_pell_orig.incrcd_fed_pell_rcp_cd,
                                 x_attending_campus_id     => l_pell_orig.attending_campus_id,
                                 x_est_disb_dt1            => l_pell_orig.est_disb_dt1,
                                 x_orig_action_code        => l_orig_action_code,--update to 'Ready to Send' or 'Not Ready'
                                 x_orig_status_dt          => TRUNC(SYSDATE),--update origination status date
                                 x_orig_ed_use_flags       => l_pell_orig.orig_ed_use_flags,
                                 x_ft_pell_amount          => l_pell_orig.ft_pell_amount,
                                 x_prev_accpt_efc          => l_pell_orig.prev_accpt_efc,
                                 x_prev_accpt_tran_no      => l_pell_orig.prev_accpt_tran_no,
                                 x_prev_accpt_sec_efc_cd   => l_pell_orig.prev_accpt_sec_efc_cd,
                                 x_prev_accpt_coa          => l_pell_orig.prev_accpt_coa,
                                 x_orig_reject_code        => l_pell_orig.orig_reject_code,
                                 x_wk_inst_time_calc_pymt  => l_pell_orig.wk_inst_time_calc_pymt,
                                 x_wk_int_time_prg_def_yr  => l_pell_orig.wk_int_time_prg_def_yr,
                                 x_cr_clk_hrs_prds_sch_yr  => l_pell_orig.cr_clk_hrs_prds_sch_yr,
                                 x_cr_clk_hrs_acad_yr      => l_pell_orig.cr_clk_hrs_acad_yr,
                                 x_inst_cross_ref_cd       => l_pell_orig.inst_cross_ref_cd,
                                 x_low_tution_fee          => l_pell_orig.low_tution_fee,
                                 x_rec_source              => l_pell_orig.rec_source,
                                 x_pending_amount          => l_pell_orig.pending_amount,
                                 x_mode                    => 'R',
                                 x_birth_dt                => l_pell_orig.birth_dt,
                                 x_last_name               => l_pell_orig.last_name,
                                 x_first_name              => l_pell_orig.first_name,
                                 x_middle_name             => l_pell_orig.middle_name,
                                 x_current_ssn             => l_pell_orig.current_ssn,
                                 x_legacy_record_flag      => l_pell_orig.legacy_record_flag,
                                 x_reporting_pell_cd       => l_pell_orig.reporting_pell_cd,
                                 x_rep_entity_id_txt       => l_pell_orig.rep_entity_id_txt,
                                 x_atd_entity_id_txt       => l_pell_orig.atd_entity_id_txt,
                                 x_note_message            => l_pell_orig.note_message,
                                 x_full_resp_code          => l_pell_orig.full_resp_code,
                                 x_document_id_txt         => l_pell_orig.document_id_txt
                                );
      fnd_message.set_name('IGF','IGF_GR_REORIG_PELL');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END LOOP;
  END update_pell_orig_stat;

  PROCEDURE update_loan_stat(
                             p_award_id igf_aw_award_all.award_id%TYPE,
                             p_amount   igf_aw_award_all.offered_amt%TYPE
                            ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-Dec-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  -- Get loan
  CURSOR c_loan(
                cp_award_id igf_aw_award_all.award_id%TYPE,
                cp_amount   igf_aw_award_all.offered_amt%TYPE
               ) IS
    SELECT loan.ROWID row_id,
           loan.*
      FROM igf_sl_loans_all loan,
           igf_aw_award_all awd
     WHERE loan.award_id = cp_award_id
       AND loan.award_id = awd.award_id
       AND awd.offered_amt <> cp_amount
       AND loan.loan_status <> 'S';
  l_loan_status igf_sl_loans_all.loan_status%TYPE;

  BEGIN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_loan_stat.debug '|| g_req_id,'starting update_loan_stat with award_id:'||p_award_id||
                     'amount:'||p_amount);
    END IF;
    FOR l_loan IN c_loan(p_award_id,p_amount) LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_loan_stat.debug '|| g_req_id,'l_loan.loan_status:'||l_loan.loan_status);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_loan_stat.debug '|| g_req_id,'l_loan.loan_status_date:'||l_loan.loan_status_date);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_loan_stat.debug '|| g_req_id,'l_loan.loan_chg_status:'||l_loan.loan_chg_status);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_loan_stat.debug '|| g_req_id,'l_loan.loan_chg_status_date:'||l_loan.loan_chg_status_date);
      END IF;

      IF l_loan.loan_status = 'N' THEN
        --when the loan is not ready, keep it in not ready status
        l_loan.loan_status := 'N';
        l_loan.loan_status_date := TRUNC(SYSDATE);

      ELSIF l_loan.loan_status = 'A' THEN
        --when the loan has been accepted, change loan_chg_status
        IF l_loan.loan_chg_status = 'N' THEN
          l_loan.loan_chg_status := 'N';
          l_loan.loan_chg_status_date := TRUNC(SYSDATE);
        ELSE
          l_loan.loan_chg_status := 'G';
          l_loan.loan_chg_status_date := TRUNC(SYSDATE);
        END IF;
      ELSE
        --any other status, flip the status to ready
        l_loan.loan_status := 'G';
        l_loan.loan_status_date := TRUNC(SYSDATE);
      END IF;

      igf_sl_loans_pkg.update_row(
                                  x_rowid                => l_loan.row_id,
                                  x_loan_id              => l_loan.loan_id,
                                  x_award_id             => l_loan.award_id,
                                  x_seq_num              => l_loan.seq_num,
                                  x_loan_number          => l_loan.loan_number,
                                  x_loan_per_begin_date  => l_loan.loan_per_begin_date,
                                  x_loan_per_end_date    => l_loan.loan_per_end_date,
                                  x_loan_status          => l_loan.loan_status,
                                  x_loan_status_date     => l_loan.loan_status_date,
                                  x_loan_chg_status      => l_loan.loan_chg_status,
                                  x_loan_chg_status_date => l_loan.loan_chg_status_date,
                                  x_active               => l_loan.active,
                                  x_active_date          => l_loan.active_date,
                                  x_borw_detrm_code      => l_loan.borw_detrm_code,
                                  x_mode                 => 'R',
                                  x_legacy_record_flag   => l_loan.legacy_record_flag,
                                  x_external_loan_id_txt => l_loan.external_loan_id_txt,
                                  x_called_from          => 'IGFAW03B'
                                 );
    END LOOP;
  END update_loan_stat;

  PROCEDURE cancel_invalid_award(
                                 p_award_id igf_aw_award_all.award_id%TYPE
                                ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 27-Oct-2004
  --
  --Purpose: to cancel an existing award and its disbursements
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --museshad    14-Apr-2006     Bug 5042136.
  --                            When an award is cancelled- Origination Fee,
  --                            Guarantor Fee, Interest Rebate Amount in the disb
  --                            should become 0. Fixed this.
  --museshad    18-Jul-2005     Build FA 157.
  --                            Passed 'A' for x_elig_status and TRUNC(SYSDATE)
  --                            for x_elig_status_date whiile updating the
  --                            disbursements for a cancelled award.
  -------------------------------------------------------------------

  -- Get an award
  CURSOR c_award(
                 cp_award_id igf_aw_award_all.award_id%TYPE
                ) IS
    SELECT awd.rowid row_id,
           awd.*
      FROM igf_aw_award_all awd
     WHERE award_id = cp_award_id
       AND award_status <> 'CANCELLED';

  -- Get disbursements for an award
  CURSOR c_disb(
                cp_award_id igf_aw_award_all.award_id%TYPE
               ) IS
    SELECT disb.rowid row_id,
           disb.*
      FROM igf_aw_awd_disb_all disb
     WHERE award_id = cp_award_id;

  -- Get Fund Code from fund_id
  CURSOR c_fund_code(
                     cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE
                    ) IS
    SELECT fund_code
      FROM igf_aw_fund_mast_all
     WHERE fund_id = cp_fund_id;
  l_fund_code igf_aw_fund_mast_all.fund_code%TYPE;

  lv_rowid ROWID;
  l_amount igf_aw_award_all.offered_amt%TYPE;

  -- Get total amount already sent to COD
  CURSOR c_rfms_disb(
                     cp_award_id igf_aw_award_all.award_id%TYPE
                    ) IS
    SELECT SUM(disb.disb_amt)
      FROM igf_gr_rfms_all rfms,
           igf_gr_rfms_disb_all disb
     WHERE rfms.award_id = cp_award_id
       AND rfms.origination_id = disb.origination_id
       AND disb.disb_ack_act_status IN ('S','A','D','C');

  -- Get last disb
  CURSOR c_last_disb(
                     cp_award_id igf_aw_award_all.award_id%TYPE
                    ) IS
      SELECT disb_num,
             tp_cal_type,
             tp_sequence_number,
             ld_cal_type,
             ld_sequence_number,
             show_on_bill,
             base_attendance_type_code
        FROM igf_aw_awd_disb disb
       WHERE disb.award_id = p_award_id
         AND ROWNUM = 1
    ORDER BY disb_num DESC;
  l_last_disb c_last_disb%ROWTYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.cancel_invalid_award.debug '|| g_req_id,'starting cancel_invalid_award with award_id:'||p_award_id);
    END IF;

    FOR awd_rec IN c_award(p_award_id) LOOP

      fnd_message.set_name('IGF','IGF_AW_AWARD_CANCELLED');
      fnd_message.set_token('AWD',TO_CHAR(p_award_id));
      l_fund_code := NULL;
      OPEN c_fund_code(awd_rec.fund_id);
      FETCH c_fund_code INTO l_fund_code;
      CLOSE c_fund_code;
      fnd_message.set_token('FUND',l_fund_code);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      FOR disb_rec IN c_disb(p_award_id) LOOP

        igf_aw_awd_disb_pkg.update_row(
                                       x_rowid                => disb_rec.row_id,
                                       x_award_id             => disb_rec.award_id,
                                       x_disb_num             => disb_rec.disb_num,
                                       x_tp_cal_type          => disb_rec.tp_cal_type,
                                       x_tp_sequence_number   => disb_rec.tp_sequence_number,
                                       x_disb_gross_amt       => 0,
                                       x_fee_1                => 0,
                                       x_fee_2                => 0,
                                       x_disb_net_amt         => 0,
                                       x_disb_date            => disb_rec.disb_date,
                                       x_trans_type           => 'C',
                                       x_elig_status          => 'A',
                                       x_elig_status_date     => TRUNC(SYSDATE),
                                       x_affirm_flag          => disb_rec.affirm_flag,
                                       x_hold_rel_ind         => disb_rec.hold_rel_ind,
                                       x_manual_hold_ind      => disb_rec.manual_hold_ind,
                                       x_disb_status          => disb_rec.disb_status,
                                       x_disb_status_date     => disb_rec.disb_status_date,
                                       x_late_disb_ind        => disb_rec.late_disb_ind,
                                       x_fund_dist_mthd       => disb_rec.fund_dist_mthd,
                                       x_prev_reported_ind    => disb_rec.prev_reported_ind,
                                       x_fund_release_date    => disb_rec.fund_release_date,
                                       x_fund_status          => disb_rec.fund_status,
                                       x_fund_status_date     => disb_rec.fund_status_date,
                                       x_fee_paid_1           => disb_rec.fee_paid_1,
                                       x_fee_paid_2           => disb_rec.fee_paid_2,
                                       x_cheque_number        => disb_rec.cheque_number,
                                       x_ld_cal_type          => disb_rec.ld_cal_type,
                                       x_ld_sequence_number   => disb_rec.ld_sequence_number,
                                       x_disb_accepted_amt    => 0,
                                       x_disb_paid_amt        => disb_rec.disb_paid_amt,
                                       x_rvsn_id              => disb_rec.rvsn_id,
                                       x_int_rebate_amt       => 0,
                                       x_force_disb           => disb_rec.force_disb,
                                       x_min_credit_pts       => disb_rec.min_credit_pts,
                                       x_disb_exp_dt          => disb_rec.disb_exp_dt,
                                       x_verf_enfr_dt         => disb_rec.verf_enfr_dt,
                                       x_fee_class            => disb_rec.fee_class,
                                       x_show_on_bill         => disb_rec.show_on_bill,
                                       x_mode                 => 'R',
                                       x_attendance_type_code => disb_rec.attendance_type_code,
                                       x_base_attendance_type_code => disb_rec.base_attendance_type_code,
                                       x_payment_prd_st_date       => disb_rec.payment_prd_st_date,
                                       x_change_type_code          => disb_rec.change_type_code,
                                       x_fund_return_mthd_code     => disb_rec.fund_return_mthd_code,
                                       x_direct_to_borr_flag       => disb_rec.direct_to_borr_flag
                                       );

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.cancel_invalid_award.debug '|| g_req_id,'updated disbursement number '||disb_rec.disb_num);
        END IF;

      END LOOP;

      igf_aw_award_pkg.update_row(
                                  x_rowid              => awd_rec.row_id,
                                  x_award_id           => awd_rec.award_id,
                                  x_fund_id            => awd_rec.fund_id,
                                  x_base_id            => awd_rec.base_id,
                                  x_offered_amt        => 0,
                                  x_accepted_amt       => 0,
                                  x_paid_amt           => awd_rec.paid_amt,
                                  x_packaging_type     => awd_rec.packaging_type,
                                  x_batch_id           => awd_rec.batch_id,
                                  x_manual_update      => awd_rec.manual_update,
                                  x_rules_override     => awd_rec.rules_override,
                                  x_award_date         => awd_rec.award_date,
                                  x_award_status       => 'CANCELLED',
                                  x_attribute_category => awd_rec.attribute_category,
                                  x_attribute1         => awd_rec.attribute1,
                                  x_attribute2         => awd_rec.attribute2,
                                  x_attribute3         => awd_rec.attribute3,
                                  x_attribute4         => awd_rec.attribute4,
                                  x_attribute5         => awd_rec.attribute5,
                                  x_attribute6         => awd_rec.attribute6,
                                  x_attribute7         => awd_rec.attribute7,
                                  x_attribute8         => awd_rec.attribute8,
                                  x_attribute9         => awd_rec.attribute9,
                                  x_attribute10        => awd_rec.attribute10,
                                  x_attribute11        => awd_rec.attribute11,
                                  x_attribute12        => awd_rec.attribute12,
                                  x_attribute13        => awd_rec.attribute13,
                                  x_attribute14        => awd_rec.attribute14,
                                  x_attribute15        => awd_rec.attribute15,
                                  x_attribute16        => awd_rec.attribute16,
                                  x_attribute17        => awd_rec.attribute17,
                                  x_attribute18        => awd_rec.attribute18,
                                  x_attribute19        => awd_rec.attribute19,
                                  x_attribute20        => awd_rec.attribute20,
                                  x_rvsn_id            => awd_rec.rvsn_id,
                                  x_alt_pell_schedule  => awd_rec.alt_pell_schedule,
                                  x_mode               => 'R',
                                  x_award_number_txt   => awd_rec.award_number_txt,
                                  x_legacy_record_flag => awd_rec.legacy_record_flag,
                                  x_adplans_id         => awd_rec.adplans_id,
                                  x_lock_award_flag    => awd_rec.lock_award_flag,
                                  x_app_trans_num_txt  => awd_rec.app_trans_num_txt,
                                  x_awd_proc_status_code => 'AWARDED',
                                  x_notification_status_code	=> awd_rec.notification_status_code,
                                  x_notification_status_date	=> awd_rec.notification_status_date,
                                  x_publish_in_ss_flag        => awd_rec.publish_in_ss_flag
                                 );
      IF get_fed_fund_code(awd_rec.fund_id) ='PELL' AND g_phasein_participant THEN
        update_pell_orig_stat(awd_rec.award_id,0); --uodate the pell origination status with zero amount and 'Ready to Send' status

        --get total amount already sent from igf_gr_rfms_disb
        l_amount := NULL;
        OPEN c_rfms_disb(awd_rec.award_id);
        FETCH c_rfms_disb INTO l_amount;
        CLOSE c_rfms_disb;
        IF l_amount IS NOT NULL THEN
          --create a new disbursement record with total amount already sent
          --copy values from the last disb
          OPEN c_last_disb(awd_rec.award_id);
          FETCH c_last_disb INTO l_last_disb;
          CLOSE c_last_disb;

          l_amount := -1 * l_amount;
          lv_rowid := NULL;

          igf_aw_awd_disb_pkg.insert_row(
                                         x_rowid                       => lv_rowid,
                                         x_award_id                    => awd_rec.award_id,
                                         x_disb_num                    => (l_last_disb.disb_num + 1),
                                         x_tp_cal_type                 => l_last_disb.tp_cal_type,
                                         x_tp_sequence_number          => l_last_disb.tp_sequence_number,
                                         x_disb_gross_amt              => l_amount,
                                         x_fee_1                       => 0,
                                         x_fee_2                       => 0,
                                         x_disb_net_amt                => l_amount,
                                         x_disb_date                   => SYSDATE,
                                         x_trans_type                  => 'P',
                                         x_elig_status                 => 'N',
                                         x_elig_status_date            => TRUNC(SYSDATE),
                                         x_affirm_flag                 => 'N',
                                         x_hold_rel_ind                => 'N',
                                         x_manual_hold_ind             => 'N',
                                         x_disb_status                 => NULL,
                                         x_disb_status_date            => NULL,
                                         x_late_disb_ind               => 'N',
                                         x_fund_dist_mthd              => 'E',
                                         x_prev_reported_ind           => 'N',
                                         x_fund_release_date           => NULL,
                                         x_fund_status                 => NULL,
                                         x_fund_status_date            => NULL,
                                         x_fee_paid_1                  => 0,
                                         x_fee_paid_2                  => 0,
                                         x_cheque_number               => NULL,
                                         x_ld_cal_type                 => l_last_disb.ld_cal_type,
                                         x_ld_sequence_number          => l_last_disb.ld_sequence_number,
                                         x_disb_accepted_amt           => 0,
                                         x_disb_paid_amt               => 0,
                                         x_rvsn_id                     => NULL,
                                         x_int_rebate_amt              => 0,
                                         x_force_disb                  => NULL,
                                         x_min_credit_pts              => 0,
                                         x_disb_exp_dt                 => NULL,
                                         x_verf_enfr_dt                => NULL,
                                         x_fee_class                   => NULL,
                                         x_show_on_bill                => l_last_disb.show_on_bill,
                                         x_attendance_type_code        => NULL,
                                         x_mode                        => 'R',
                                         x_base_attendance_type_code   => l_last_disb.base_attendance_type_code,
                                         x_payment_prd_st_date         => NULL,
                                         x_change_type_code            => NULL,
                                         x_fund_return_mthd_code       => NULL,
                                         x_direct_to_borr_flag         => 'N'
                                        );
        END IF;
      END IF;
    END LOOP;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.cancel_invalid_award.debug '|| g_req_id,'finsihed cancel_invalid_award for award_id:'||p_award_id);
    END IF;
  END cancel_invalid_award;

  PROCEDURE cancel_awards(
                          p_process_id igf_aw_award_t.process_id%TYPE,
                          p_base_id    igf_ap_fa_base_rec_all.base_id%TYPE
                         ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 27-Oct-2004
  --
  --Purpose: Cancels any invalid awards
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get cancelled awards
  CURSOR c_cancelled_awards(
                            cp_process_id igf_aw_award_t.process_id%TYPE,
                            cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE
                           ) IS
    SELECT awdt.award_id
      FROM igf_aw_award_t awdt
     WHERE process_id = cp_process_id
       AND base_id = cp_base_id
       AND flag IN ('AC','AR');

  BEGIN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.cancel_awards.debug '|| g_req_id,'starting cancel awards with base_id:'||p_base_id);
    END IF;

    FOR l_cancelled_awards IN c_cancelled_awards(p_process_id,p_base_id) LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.cancel_awards.debug '|| g_req_id,'cancelling award:'||l_cancelled_awards.award_id);
      END IF;
      cancel_invalid_award(l_cancelled_awards.award_id);
    END LOOP;
  END cancel_awards;

  PROCEDURE round_off_disbursements(
                                      p_fund_id             IN  igf_aw_award_t_all.fund_id%TYPE,
                                      p_base_id             IN  igf_aw_award_t_all.base_id%TYPE,
                                      p_process_id          IN  igf_aw_award_t_all.process_id%TYPE,
                                      p_award_id            IN  igf_aw_award_t_all.award_id%TYPE,
                                      p_adplans_id          IN  igf_aw_award_t_all.adplans_id%TYPE,
                                      p_offered_amt         IN  igf_aw_award_t_all.offered_amt%TYPE,
                                      p_dist_plan_code      IN  igf_aw_awd_dist_plans.dist_plan_method_code%TYPE,
                                      p_disb_count          IN  NUMBER
                                    )
  IS
        /*
        ||  Created By : museshad
        ||  Created On : 05-Jun-2005
        ||  Purpose :   Build# FA157 - Bug# 4382371
        ||              Calculates the disbursement amount based on the
        ||              disbursement rounding factor. The procedure fills the
        ||              PL/SQL table 'l_disb_structure_tab' with the disbursement
        ||              amounts. This PL/SQL table is then used to update the
        ||              IGF_AW_AWARD_T table.
        ||
        ||              Note, this procedure holds good only for non-PELL funds.
        ||              Disbursement rounding for Pell is handled in IGFGR11B.pls
        ||
        ||              Note, with the 'Equal' distribution method, the extra disbursement
        ||              amount is shared with the possible disbursements starting from
        ||              the last/first disbursement. But with 'Match COA'
        ||              and 'Manual' distribution the extra disbursement amount is not
        ||              shared with each disbursement but it is fully given either to
        ||              the first/last disbursement.
        ||
        ||              Description of the main variables used -
        ||              l_disb_amt                Normal disbursement amount
        ||
        ||              l_disb_diff               Holds the extra disbursement amount that needs to be shared
        ||                                        with the disbursements
        ||
        ||              l_extra_factor            In 'Equal Distribution' this variables gives the share of the
        ||                                        extra amount for each disbursement. For ONES rounding it is 1
        ||                                        and for DECIMALS rounding it is 0.01.
        ||
        ||              l_disb_amt_extra          In 'Equal Distribution', the extra disbursement amount is shared with the
        ||                                        possible disbursements. This variable holds (l_disb_amt + l_extra_factor)
        ||
        ||              l_trunc_factor            The trunc factor to be used for rounding the decimal portion in the disbursement amount.
        ||                                        For ONES rounding this is 0 and for DECIMALS rounding this is 2
        ||
        ||              l_disb_no                 Holds the disbursement number that is currently being processed.
        ||
        ||              l_special_disb_no         In 'Match COA' distribution the extra amount is fully given to either
        ||                                        first/last disbursement depending on the disbursement rounding value.
        ||                                        This variable is either 1/p_disb_count
        ||
        ||              l_disb_limt1,             All these three variable form the loop attributes.
        ||              l_disb_limt2,             If l_step = 1, the loop runs from l_disb_limt1 to l_disb_limt2.
        ||              l_step                    If l_step = -1, the loop runs from l_disb_limt2 to l_disb_limt1.
        ||
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             WHEN            What
        ||  (reverse chronological order - newest change first)
        */

      -- Returns all the disbursements in the temporary table
      -- The ORDER BY clause ensures that the disbursements are returned
      -- in the order of their creation
      CURSOR cur_get_all_disb (
                                cp_fund_id      igf_aw_award_t_all.fund_id%TYPE,
                                cp_base_id      igf_aw_award_t_all.base_id%TYPE,
                                cp_process_id   igf_aw_award_t_all.process_id%TYPE,
                                cp_adplans_id   igf_aw_award_t_all.adplans_id%TYPE,
                                p_award_id      igf_aw_award_t_all.award_id%TYPE
                              )
      IS
          SELECT awd_t.rowid, awd_t.*
          FROM igf_aw_award_t_all awd_t
          WHERE
                base_id = p_base_id AND
                fund_id = p_fund_id AND
                process_id = p_process_id AND
                NVL(adplans_id,-1) = NVL(p_adplans_id,-1) AND
                NVL(award_id,-1) = NVL(p_award_id,-1) AND
                flag = 'DB'
          ORDER BY fnd_date.chardate_to_date(temp_char_val1) ASC;

      l_disb_amt            NUMBER        := 0;
      l_disb_prelim_amt     NUMBER        := 0;
      l_disb_amt_extra      NUMBER        := 0;
      l_disb_inter_sum_amt  NUMBER        := 0;
      l_disb_diff           NUMBER        := 0;
      l_trunc_factor        NUMBER        := 0;
      l_extra_factor        NUMBER        := 0;
      l_disb_no             NUMBER        := 0;
      l_special_disb_no     NUMBER        := 0;
      l_disb_limit1         NUMBER        := 0;
      l_disb_limit2         NUMBER        := 0;
      l_step                NUMBER        := 0;
      l_disb_round_factor   igf_aw_fund_mast.disb_rounding_code%TYPE := NULL;

    TYPE l_disb_structure IS RECORD(
                                     fund_id    igf_aw_fund_mast.fund_id%TYPE,
                                     disb_num   NUMBER,
                                     disb_amt   NUMBER
                                   );
    TYPE l_disb_structure_tab IS TABLE OF l_disb_structure INDEX BY BINARY_INTEGER;
    l_disb_structure_rec l_disb_structure_tab;

  BEGIN
      l_disb_round_factor := get_disb_round_factor(p_fund_id);
      IF l_disb_round_factor IN ('ONE_FIRST', 'DEC_FIRST', 'ONE_LAST', 'DEC_LAST') THEN  -- disb_round_factor

          -- Log useful values
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,'Into round_off_disbursements. Parameters received ...');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,'Fund id: '||p_fund_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,'Award amount: '||p_offered_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,'Number of disbursements: '||p_disb_count);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,'Disbursement rounding factor: '||l_disb_round_factor);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,'Distribution plan code: ' || UPPER(p_dist_plan_code));
          END IF;

          -- Set the attributes common to ONEs rounding factor
          IF l_disb_round_factor = 'ONE_FIRST' OR l_disb_round_factor = 'ONE_LAST' THEN
            l_trunc_factor      :=    0;
            l_extra_factor      :=    1;
          -- Set the attributes common to DECIMALs rounding factor
          ELSIF l_disb_round_factor = 'DEC_FIRST' OR l_disb_round_factor = 'DEC_LAST' THEN
            l_trunc_factor      :=    2;
            l_extra_factor      :=    0.01;
          END IF;

          -- Set the attributes common to FIRST rounding factor
          IF l_disb_round_factor = 'ONE_FIRST' OR l_disb_round_factor = 'DEC_FIRST' THEN
            IF UPPER(p_dist_plan_code) = 'E' THEN
              l_disb_limit1     :=    1;
              l_disb_limit2     :=    p_disb_count;
              l_step            :=    1;
              l_disb_no         :=    l_disb_limit1;
           ELSIF UPPER(p_dist_plan_code) IN ('C', 'M') THEN
              l_special_disb_no :=    1;
            END IF;

          -- Set the attributes common to LAST rounding factor
          ELSIF l_disb_round_factor = 'ONE_LAST' OR l_disb_round_factor = 'DEC_LAST' THEN
            IF UPPER(p_dist_plan_code) = 'E' THEN
              l_disb_limit1     :=    1;
              l_disb_limit2     :=    p_disb_count;
              l_step            :=    -1;
              l_disb_no         :=    l_disb_limit2;
            ELSIF UPPER(p_dist_plan_code) IN ('C', 'M') THEN
              l_special_disb_no :=    p_disb_count;
            END IF;
          END IF;

          -- Log values
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_trunc_factor: ' ||l_trunc_factor);
            fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_extra_factor: ' ||l_extra_factor);
          END IF;

          ------------------------------------
          -- EVEN Distribution
          ------------------------------------
          IF UPPER(p_dist_plan_code) = 'E' THEN                              -- p_dist_plan_code

              -- Normal disbursement amount
              l_disb_amt := TRUNC(NVL((p_offered_amt/p_disb_count), 0), l_trunc_factor);
              -- Preliminary disbursement amount
              l_disb_prelim_amt := TRUNC(NVL((p_offered_amt - (l_disb_amt * (p_disb_count-1))), 0), l_trunc_factor);

              -- Difference in disbursement amount
              l_disb_diff := TRUNC(NVL((l_disb_prelim_amt - l_disb_amt), 0), l_trunc_factor);

              -- Extra disbursement amount
              IF l_disb_diff > 0 THEN
                  l_disb_amt_extra := TRUNC(NVL((l_disb_amt + l_extra_factor), 0), l_trunc_factor);
              ELSIF l_disb_diff < 0 THEN
                  l_disb_amt_extra := TRUNC(NVL((l_disb_amt - l_extra_factor), 0), l_trunc_factor);
              ELSE
                  l_disb_amt_extra := TRUNC(NVL(l_disb_amt, 0), l_trunc_factor);
              END IF;

              -- Get the absolute difference value between preliminary and normal disbursement amount
              l_disb_diff := ABS(l_disb_diff);

              -- Log values
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_disb_diff: ' ||l_disb_diff);
                fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_disb_prelim_amt: ' ||l_disb_prelim_amt);
                fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_disb_amt_extra: ' ||l_disb_amt_extra);
                fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_disb_amt: ' ||l_disb_amt);
                fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_disb_limit1: ' ||l_disb_limit1);
                fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_disb_limit2: ' ||l_disb_limit2);
                fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'l_step: ' ||l_step);
              END IF;

              -- Calculate each disbursement and distribute the extra
              -- amount starting from the first/last disbursement
              WHILE l_disb_no BETWEEN l_disb_limit1 AND l_disb_limit2
              LOOP
                  l_disb_structure_rec(l_disb_no).disb_num := l_disb_no;

                  IF l_disb_diff >= l_extra_factor THEN
                      l_disb_structure_rec(l_disb_no).disb_amt := l_disb_amt_extra;
                      l_disb_diff := NVL((l_disb_diff - l_extra_factor), 0);
                  ELSE
                      l_disb_structure_rec(l_disb_no).disb_amt := l_disb_amt;
                  END IF;

                  -- Log useful values
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,
                                  'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,
                                  'Disbursement number: '||l_disb_structure_rec(l_disb_no).disb_num || '       Disbursement amount: ' ||  to_char(l_disb_structure_rec(l_disb_no).disb_amt));
                  END IF;

                  l_disb_no := NVL(l_disb_no, 0) + l_step;
              END LOOP;

          ------------------------------------
          -- MATCH COA/MANUAL Distribution
          ------------------------------------
          ELSIF UPPER(p_dist_plan_code) IN ('C', 'M') THEN

            -- Log values
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'Special disbursement No: ' ||l_special_disb_no);
            END IF;

            -- Initialize disbursement counter
            l_disb_no := 1;

            -- Loop thru all the disbursement records and round the disbursement amount
            FOR l_disb_rec_all IN cur_get_all_disb(p_fund_id, p_base_id, p_process_id, p_adplans_id, p_award_id)
            LOOP

                -- Skip the first/last disbursement
                IF l_disb_no <> l_special_disb_no THEN

                    -- Calculate disbursement amount truncated to correct decimal place
                    l_disb_amt := TRUNC(NVL(l_disb_rec_all.temp_num_val1, 0), l_trunc_factor);

                    -- Add the disbursement to PL/SQL table
                    l_disb_structure_rec(l_disb_no).disb_num    :=  l_disb_no;
                    l_disb_structure_rec(l_disb_no).disb_amt    :=  l_disb_amt;

                    l_disb_inter_sum_amt := NVL((l_disb_inter_sum_amt + l_disb_amt), 0);

                    -- Log useful values
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,
                                      'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,
                                      'Disbursement number: '||l_disb_structure_rec(l_disb_no).disb_num || '       Disbursement amount: ' ||  to_char(l_disb_structure_rec(l_disb_no).disb_amt));
                    END IF;
                END IF;

                l_disb_no := NVL(l_disb_no, 0) + 1;
            END LOOP;

            -- Calculate first/last disbursement. Unlike other disbursements,
            -- this is not got from temporary table, but is claculated here
            l_disb_amt := TRUNC(NVL((p_offered_amt - l_disb_inter_sum_amt), 0), l_trunc_factor);

            -- Add the first/last disbursement to PL/SQL table
            l_disb_structure_rec(l_special_disb_no).disb_num    :=  l_special_disb_no;
            l_disb_structure_rec(l_special_disb_no).disb_amt    :=  l_disb_amt;

            -- Log useful values
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                            'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,
                            'Disbursement number(Special Case): '|| l_disb_structure_rec(l_special_disb_no).disb_num || '       Disbursement amount: ' ||  to_char(l_disb_structure_rec(l_special_disb_no).disb_amt));
            END IF;

          END IF; -- End of p_dist_plan_code

      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,
                        'Invalid disbursement rounding factor in fund id: ' ||p_fund_id|| '. Cannot compute disbursement rounding');
        END IF;
      END IF; -- End of disb_round_factor

      -- Log values
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id, 'Updating temp table(igf_aw_award_t) with the rounded disbursement amounts.');
      END IF;

      -- All the rounded disbursement amounts are now available in the PL/SQL table
      -- Update these to the temporary table
      l_disb_no := 0;

      FOR l_disb_rec IN cur_get_all_disb(p_fund_id, p_base_id, p_process_id, p_adplans_id, p_award_id)
      LOOP            -- Get all disbursements
          l_disb_no := NVL(l_disb_no, 0) + 1;

          -- Check if the PL/SQL table has got a valid value for that disbursement number
          IF l_disb_structure_rec.EXISTS(l_disb_no) THEN        -- Disbursement existence check

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,
                              'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,
                              'Disbursement amounts before and after applying rounding logic');

                fnd_log.string(fnd_log.level_statement,
                              'igf.plsql.igf_aw_packaging.round_off_disbursements.debug '|| g_req_id,
                              'Disbursement number: ' ||l_disb_no|| '       Old Disbursement amount: ' ||l_disb_rec.temp_num_val1|| '       New disbursement amount after applying rounding logic: ' ||NVL(l_disb_structure_rec(l_disb_no).disb_amt, 0));
              END IF;

              igf_aw_award_t_pkg.update_row(
                                              x_rowid               => l_disb_rec.rowid,
                                              x_process_id          => l_disb_rec.process_id,
                                              x_sl_number           => l_disb_rec.sl_number,
                                              x_fund_id             => l_disb_rec.fund_id,
                                              x_base_id             => l_disb_rec.base_id,
                                              x_offered_amt         => NVL(l_disb_structure_rec(l_disb_no).disb_amt, 0),
                                              x_accepted_amt        => l_disb_rec.accepted_amt,
                                              x_paid_amt            => l_disb_rec.paid_amt,
                                              x_need_reduction_amt  => l_disb_rec.need_reduction_amt,
                                              x_flag                => l_disb_rec.flag,
                                              x_temp_num_val1       => NVL(l_disb_structure_rec(l_disb_no).disb_amt, 0),
                                              x_temp_num_val2       => l_disb_rec.temp_num_val2,
                                              x_temp_char_val1      => l_disb_rec.temp_char_val1,
                                              x_tp_cal_type         => l_disb_rec.tp_cal_type,
                                              x_tp_sequence_number  => l_disb_rec.tp_sequence_number,
                                              x_ld_cal_type         => l_disb_rec.ld_cal_type,
                                              x_ld_sequence_number  => l_disb_rec.ld_sequence_number,
                                              x_mode                => 'R',
                                              x_adplans_id          => l_disb_rec.adplans_id,
                                              x_app_trans_num_txt   => l_disb_rec.app_trans_num_txt,
                                              x_award_id            => l_disb_rec.award_id,
                                              x_lock_award_flag     => l_disb_rec.lock_award_flag,
                                              x_temp_val3_num       => l_disb_rec.temp_val3_num,
                                              x_temp_val4_num       => l_disb_rec.temp_val4_num,
                                              x_temp_char2_txt      => l_disb_rec.temp_char2_txt,
                                              x_temp_char3_txt      => l_disb_rec.temp_char3_txt
                                           );
          END IF;             -- End of Disbursement existence check
      END LOOP;               -- End of Get all disbursements loop

      EXCEPTION
        WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGF_AW_PACKAGING.ROUND_OFF_DISBURSEMENTS '||SQLERRM);
            igs_ge_msg_stack.add;

            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.round_off_disbursements.exception '|| g_req_id,'sql error message: '||SQLERRM);
            END IF;

            app_exception.raise_exception;
  END round_off_disbursements;

  -- This process posts records in the Awards and Disbursements Table
  PROCEDURE post_award(
                       l_base_id              IN NUMBER,
                       l_process_id           IN NUMBER,
                       l_post                 IN VARCHAR2,
                       l_called_from          IN VARCHAR2,
                       l_upd_awd_notif_status IN VARCHAR2,
                       l_ret_status           OUT NOCOPY VARCHAR2
                      ) IS
    /*
    || Created By : cdcruz
    || Created On : 14-NOV-2000
    || Purpose :
    || Known limitations, enhancements or remarks :
    || Change History :
    || Who             WHEN            What
    || (reverse chronological order - newest change first)
    ||  museshad       24-Apr-2006     Bug 5116534.
    ||                                 1. Modified cursor c_nslds to chk for valid nslds_loan_prog_code_1 data.
    ||                                 2. Modified the logic used to derive lb_disb_update
    ||  museshad       17-Apr-2006     Bug 5039489.
    ||                                 Negative entry was NOT getting posted to Student a/c when a
    ||                                 disb gets cancelled during repackaging process. This was
    ||                                 happening bcoz disb_net_amt was NOT getting set to 0 while
    ||                                 cancelling extra disb in the old award during repackaging.
    ||                                 Note, this issue is applicable to awards from all funds.
    ||                                 Also not directly relating to this bug, disb_paid_amt was
    ||                                 getting  set to 0 in this case which should not happen actually.
    ||                                 Fixed these issues.
    ||  museshad       14-Apr-2006     Bug 5042136.
    ||                                 When a disb is cancelled- Origination Fee, Guarantor Fee,
    ||                                 Interest Rebate Amount should become 0. Fixed this.
    ||                                 Note, in repackaging when there are extra disb of the old
    ||                                 award they are cancelled.
    ||  museshad       02-Jun-2005     Build# FA157 - Bug# 4382371.
    ||                                 As per the new logic 'Award Notification Status' and 'Award Notification
    ||                                 Status Date' are got at the award level (from IGF_AW_AWARD_ALL table).
    ||                                 Previously they were got from IGF_AP_FA_BASE_REC_ALL table. Passed
    ||                                 NULL to these columns in the TBH call for
    ||                                 IGF_AP_FA_BASE_REC_ALL table.
    ||  ayedubat       12-OCT-04       Changed the TBH calls of igf_aw_awd_disb_pkg package to add a new column,
    ||                                 PAYMENT_PRD_ST_DATE as part of FA 149 build bug # 3416863
    ||  bkkumar        02-04-04        FACR116 - Added the new paramter p_alt_rel_code to the
    ||                                 get_loan_fee1 , get_loan_fee2 , get_cl_hold_rel_ind
    ||                                 ,get_cl_auto_late_ind
    || veramach        03-Dec-2003     FA 131 COD Updates
    ||                                 Adds cursor c_trans_num which is used to populate payment ISIR transaction number
    || veramach        20-NOV-2003     c_awd_tot cursor select adplans_id also
    ||                                 c_awd_disb,c_awd_disb_cnt choose adplans_id
    ||                                 Added cursor c_disb. This is used to apply NSLDS offset to first disb of the student
    || bkkumar         30-sep-2003     Added base_id to the get_loan_fee1 and
    ||                                 get_loan_fee2 and added l_auto_late_ind
    ||                                 for teh CL Loans
    || ugummall        25-SEP-2003     FA 126 - Multiple FA Offices.
    ||                                 added new parameter assoc_org_num to
    ||                                 igf_ap_fa_base_rec_pkg.update_row call.
    ||  rasahoo        23-Apl-2003     Bug # 2860836
    ||                                 Added exception handling for resolving
    ||                                 locking problem created by fund manager
    || brajendr        07-Mar-2003     Bug # 2829487
    ||                                 Added the call to update the Process status of the student after adding the TO Do Items
    ||
    || masehgal        25-Feb-2003     Bug # 2662487 Introduced Logic to Round Off amounts for CL as well
    ||                                 Removed Hard Coded check for Fund Types
    ||
    || brajendr        09-Jan-2003     Bug # 2742000 Modified the logic for updating Notification Status.
    ||                                 Earlier notification status is done only for Auto Packaging
    ||
    || brajendr        18-Dec-2002     Bug # 2691832
    ||                                 Modified the logic for updating the Packaging Status.
    ||
    || masehgal        11-Nov-2002     FA 101 - SAP Obsoletion   Removed packaging hold
    ||
    || pmarada         13-Feb-2002     Modified as part of FACR008-correspondence build, updateing fabase rec.
    */

    -- Get all the awards which can be awarded to the students
    CURSOR c_awd_tot( x_process_id igf_aw_award_t.process_id%TYPE,
                      x_base_id    igf_aw_award_t.base_id%TYPE )   IS
    SELECT awdt.fund_id,
           awdt.adplans_id,
           NVL(awdt.offered_amt,0) offered_amt,
           NVL(awdt.accepted_amt,0) accepted_amt,
           temp_char_val1 over_award,
           temp_num_val1 common_perct,
           award_id,
           lock_award_flag
      FROM igf_aw_award_t awdt
     WHERE awdt.process_id = x_process_id
       AND awdt.base_id    = x_base_id
       AND awdt.flag       = 'FL';

    l_awd_tot c_awd_tot%ROWTYPE;

    -- Get the details of the Fund which are necessary while creating Awards and Disbursements
    CURSOR c_fmast ( x_fund_id  igf_aw_fund_mast.fund_id%TYPE ) IS
    SELECT fmast.pckg_awd_stat,
           fmast.ci_cal_type,
           fmast.ci_sequence_number,
           fmast.nslds_disb_da,
           fmast.disb_exp_da,
           fmast.disb_verf_Da,
           fmast.fee_type,
           fmast.fund_code,
           fmast.show_on_bill,
           fmast.entitlement,
           fcat.fund_source,
           fcat.fed_fund_code,
           fcat.sys_fund_type
      FROM igf_aw_fund_mast_all fmast,
           igf_aw_fund_cat_all fcat
     WHERE fund_id = x_fund_id
       AND fcat.fund_code = fmast.fund_code;

    l_fmast  c_fmast%ROWTYPE;

    -- Get the Person Number and SSN of the student, used to log the messages in the log file
    CURSOR c_person_number IS
    SELECT person_number, ssn, person_id
      FROM igf_ap_fa_con_v  faconv
     WHERE faconv.base_id = l_base_id;

    l_person_number  c_person_number%ROWTYPE;

    -- Get the list of disbursements of an award from the same fund of a student
    CURSOR c_awd_disb(
                      x_base_id     NUMBER,
                      x_fund_id     NUMBER,
                      x_process_id  NUMBER,
                      x_adplans_id  NUMBER,
                      x_award_id    NUMBER
                     ) IS
    SELECT awdt.*
      FROM igf_aw_award_t awdt
     WHERE base_id = x_base_id
       AND fund_id = x_fund_id
       AND process_id = x_process_id
       AND NVL(award_id,-1) = NVL(x_award_id,-1)
       AND flag = 'DB'
       AND NVL(adplans_id,-1) = NVL(x_adplans_id,-1)
     ORDER BY fnd_date.chardate_to_date(awdt.temp_char_val1);

    l_awd_disb c_awd_disb%ROWTYPE;

    -- Get the count of number of Disbursements
    CURSOR c_awd_disb_cnt(
                           x_base_id NUMBER,
                           x_fund_id in NUMBER,
                           x_process_id NUMBER,
                           x_adplans_id  NUMBER,
                           x_award_id NUMBER
                         ) IS
    SELECT COUNT(*)
      FROM igf_aw_award_t awdt
     WHERE base_id = x_base_id
       AND fund_id = x_fund_id
       AND process_id = x_process_id
       AND flag = 'DB'
       AND NVL(adplans_id,-1) = NVL(x_adplans_id,-1)
       AND NVL(award_id,-1) = NVL(x_award_id,-1);

    -- Get the NSLDS details of the student, used while creating the Loan Awards
    -- Student should be having at least one loan award in his student life.
    -- so person id was used to check the existance in diferent awd years
    CURSOR c_nslds ( cp_person_id   igf_ap_fa_base_rec_all.person_id%TYPE ) IS
    SELECT  'x'
    FROM    igf_ap_nslds_data nslds,
            igf_ap_fa_base_rec_all fabase
    WHERE   fabase.base_id = nslds.base_id    AND
            fabase.person_id = cp_person_id   AND
            nslds.nslds_loan_prog_code_1 IS NOT NULL;

    x_nslds c_nslds%ROWTYPE;

    -- Select all the detials of the student whose Notification is not 'Ready' OR 'Do not send'
    -- Used to create award / disbursement notifiactions for the student when there is change in Existing awards or new awards
    CURSOR c_fabase(cp_baseid  igf_ap_fa_base_rec.base_id%TYPE) IS
    SELECT fabase.*
      FROM igf_ap_fa_base_rec fabase
     WHERE base_id = cp_baseid
       AND (notification_status NOT IN ('R','D') OR notification_status IS NULL);

    l_fabase             c_fabase%ROWTYPE;

    -- Get a specific disbursment for an award
    CURSOR c_disb(
                  cp_award_id igf_aw_award_all.award_id%TYPE,
                  cp_disb_num igf_aw_awd_disb_all.disb_num%TYPE
                 ) IS
      SELECT rowid row_id,
             disb.*
        FROM igf_aw_awd_disb_all disb
       WHERE award_id = cp_award_id
         AND disb_num = cp_disb_num;

    l_disb c_disb%ROWTYPE;
    l_award_status         VARCHAR2(30);
    lv_rowid               ROWID;
    lv_method_name         VARCHAR2(80);
    lv_method_desc         VARCHAR2(100);
    l_award_id             NUMBER;
    l_fee1                 NUMBER(12,2);
    l_fee2                 NUMBER(12,2);
    l_fee_paid1            NUMBER(12,2);
    l_fee_paid2            NUMBER(12,2);
    l_fee_amt1             NUMBER(12,2);
    l_fee_amt2             NUMBER(12,2);
    ln_dummy_net_amt       NUMBER(12,2);
    ln_dummy_fee_1         NUMBER(12,2);
    l_disb_date            DATE;
    l_disb_date1           DATE;
    l_disb_num             NUMBER;
    l_flag                 VARCHAR2(30);
    l_hold_rel_ind         igf_aw_awd_disb.hold_rel_ind%TYPE;
    lb_disb_update         BOOLEAN := FALSE;
    l_auto_late_ind        igf_sl_cl_setup.auto_late_disb_ind%TYPE; -- FA 122 Loans Enhancements
    l_log_mesg             VARCHAR2(300);
    l_disb_dates           disb_dt_tab := disb_dt_tab();
    l_cnt                  NUMBER;
    l_nslds_dt             DATE;
    l_verf_dt              DATE;
    l_exp_dt               DATE;
    l_hld_flg              VARCHAR2(1);
    l_hold_id              igf_db_disb_holds.hold_id%TYPE;
    l_rebate               NUMBER;
    l_net                  NUMBER;
    l_credits              NUMBER;
    ln_total_disb          NUMBER;
    ln_db_run_gross_amt    NUMBER(12,2) := 0;  -- Declared as 12,2 for rounding the Amount to 2 precision values.
    ln_db_act_gross_amt    NUMBER(12,2) := 0;
    ln_db_run_accpt_amt    NUMBER(12,2) := 0;
    ln_db_act_accpt_amt    NUMBER(12,2) := 0;
    ln_com_perct           NUMBER;
    l_alt_pell_schedule    igf_aw_award_all.alt_pell_schedule%TYPE;
    lb_awards_created      BOOLEAN;
    lv_update_notif_stat   VARCHAR(2);
    l_attendance_type_code igf_aw_awd_disb_all.attendance_type_code%TYPE;
    l_base_attendance_type_code igf_aw_awd_disb_all.base_attendance_type_code%TYPE;
    ln_total_disb_num      NUMBER;
    lv_awd_notif_status    VARCHAR2(1);
    SKIP_RECORD            EXCEPTION;

    lv_app_trans_num_txt   igf_aw_award_all.app_trans_num_txt%TYPE;
    lv_result              VARCHAR2(80);
    lv_method_code         igf_aw_awd_dist_plans.dist_plan_method_code%TYPE;

    -- Get payment ISIR transaction number
    CURSOR c_trans_num(
                       cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                      ) IS
      SELECT transaction_num
        FROM igf_ap_isir_matched_all
       WHERE base_id = cp_base_id
         AND system_record_type = 'ORIGINAL'
         AND payment_isir = 'Y';
    l_trans_num       c_trans_num%ROWTYPE;

    l_app  VARCHAR2(80);
    l_name VARCHAR2(80);


    -- Get award details
    CURSOR c_award_det(
                       cp_award_id igf_aw_award_all.award_id%TYPE
                      ) IS
      SELECT awd.ROWID row_id,awd.*
        FROM igf_aw_award_all awd
       WHERE award_id = cp_award_id;
    l_award_det c_award_det%ROWTYPE;

    -- Get disbursements which should be cancelled
    CURSOR c_disb_cancel(
                         cp_award_id    igf_aw_award_all.award_id%TYPE,
                         cp_disb_num    igf_aw_awd_disb_all.disb_num%TYPE
                        ) IS
      SELECT *
        FROM igf_aw_awd_disb
       WHERE award_id = cp_award_id
         AND disb_num > cp_disb_num;

  lv_locking_success VARCHAR2(1);

  -- Get pell disb orig
  CURSOR c_pell_disb_orig(
                          cp_award_id igf_aw_award_all.award_id%TYPE,
                          cp_disb_num igf_aw_awd_disb_all.disb_num%TYPE
                         ) IS
    SELECT rfmd.ROWID row_id,
           rfmd.*
      FROM igf_gr_rfms_all rfms,
           igf_gr_rfms_disb_all rfmd
     WHERE rfms.origination_id = rfmd.origination_id
       AND rfms.award_id = cp_award_id
       AND rfmd.disb_ref_num = cp_disb_num;
  l_pell_disb_orig c_pell_disb_orig%ROWTYPE;

  lv_row_id  VARCHAR2(25);
  lv_rfmd_id igf_gr_rfms_disb_all.rfmd_id%TYPE;
  l_orig_id  igf_gr_rfms_all.origination_id%TYPE;

  -- Get origination id for a PELL award
  CURSOR c_orig_id(
                   cp_award_id igf_aw_award_all.award_id%TYPE
                  ) IS
    SELECT rfms.origination_id
      FROM igf_gr_rfms_all rfms
     WHERE rfms.award_id = cp_award_id;

  BEGIN

    lb_awards_created := FALSE;
    lv_update_notif_stat := 'F';
    lv_awd_notif_status  := 'D';

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'----------------------starting post_award--------------------------------------');
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'starting post_award with l_process_id:'||l_process_id ||' l_base_id:'||l_base_id);
    END IF;

    SAVEPOINT IGFAW03B_POST_AWARD;
    -- Process each award from the Temporary table for this Base_id and Process_id
    OPEN c_awd_tot( l_process_id, l_base_id);
    LOOP

      BEGIN

           SAVEPOINT disb_not_found;

           FETCH c_awd_tot INTO l_awd_tot;
           EXIT WHEN c_awd_tot%NOTFOUND;


           lb_awards_created := TRUE;


           -- Re-Initialize all the variables
           -- Running Totals and Actual Totals should be reinitialized.
           ln_db_run_gross_amt  := 0;
           ln_db_act_gross_amt  := 0;
           ln_db_run_accpt_amt  := 0;
           ln_db_act_accpt_amt  := 0;
           ln_com_perct         := NVL(l_awd_tot.common_perct,100);

           -- Get the Fund details of the context award
           OPEN c_fmast( l_awd_tot.fund_id );
           FETCH c_fmast INTO l_fmast;
           IF c_fmast%NOTFOUND THEN
              CLOSE c_fmast;
              RAISE NO_DATA_FOUND;
           END IF;
           CLOSE c_fmast;

           -- Initialize the Packaging Status.set the default status which is set at the fund level
           l_award_status := l_fmast.pckg_awd_stat;

           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'set l_award_status:'||l_award_status||' after checking againt l_post:'||l_post);
           END IF;

           -- For all PELL awards, Indicate whether the award is created using Alternate schedule or Regular matrix.
           -- And for other awards Initilize with NULL
           IF l_fmast.fed_fund_code = 'PELL' THEN
              l_alt_pell_schedule := g_alt_pell_schedule;

              OPEN c_trans_num(l_base_id);
              FETCH c_trans_num INTO l_trans_num;
              CLOSE c_trans_num;

              lv_app_trans_num_txt := l_trans_num.transaction_num;
           ELSE
              l_alt_pell_schedule  := NULL;
              lv_app_trans_num_txt := NULL;
           END IF;

           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'inserting into igf_aw_award');
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_tot.fund_id:'||l_awd_tot.fund_id);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_tot.offered_amt:'||l_awd_tot.offered_amt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_tot.accepted_amt:'||l_awd_tot.accepted_amt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_tot.adplans_id:'||l_awd_tot.adplans_id);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'lv_app_trans_num_txt:'||lv_app_trans_num_txt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_tot.award_id:'||l_awd_tot.award_id);
           END IF;

           lv_rowid   := NULL;
           l_award_id := NULL;

           -- Set the award notification status code based on the user value for the parameter
           IF l_upd_awd_notif_status = 'Y' THEN
            lv_awd_notif_status :=  'R';
           END IF;

           IF l_awd_tot.award_id IS NULL THEN --insert award only if the award is packaged.
             igf_aw_award_pkg.insert_row(
                                         x_rowid                  => lv_rowid,
                                         x_award_id               => l_award_id,
                                         x_fund_id                => l_awd_tot.fund_id,
                                         x_base_id                => l_base_id,
                                         x_offered_amt            => l_awd_tot.offered_amt * ln_com_perct / 100,
                                         x_accepted_amt           => l_awd_tot.accepted_amt * ln_com_perct / 100,
                                         x_paid_amt               => 0,
                                         x_packaging_type         => 'B',
                                         x_batch_id               => l_process_id,
                                         x_manual_update          => 'N',
                                         x_rules_override         => NULL,
                                         x_award_date             => TRUNC(SYSDATE),
                                         x_award_status           => l_award_status,
                                         x_attribute_category     => NULL,
                                         x_attribute1             => NULL,
                                         x_attribute2             => NULL,
                                         x_attribute3             => NULL,
                                         x_attribute4             => NULL,
                                         x_attribute5             => NULL,
                                         x_attribute6             => NULL,
                                         x_attribute7             => NULL,
                                         x_attribute8             => NULL,
                                         x_attribute9             => NULL,
                                         x_attribute10            => NULL,
                                         x_attribute11            => NULL,
                                         x_attribute12            => NULL,
                                         x_attribute13            => NULL,
                                         x_attribute14            => NULL,
                                         x_attribute15            => NULL,
                                         x_attribute16            => NULL,
                                         x_attribute17            => NULL,
                                         x_attribute18            => NULL,
                                         x_attribute19            => NULL,
                                         x_attribute20            => NULL,
                                         x_rvsn_id                => NULL,
                                         x_mode                   => 'R',
                                         x_alt_pell_schedule      => l_alt_pell_schedule,
                                         x_award_number_txt       => NULL,
                                         x_legacy_record_flag     => NULL,
                                         x_adplans_id             => l_awd_tot.adplans_id,
                                         x_lock_award_flag        => NVL(l_awd_tot.lock_award_flag,'N'),
                                         x_app_trans_num_txt      => lv_app_trans_num_txt,
                                         x_awd_proc_status_code   => 'AWARDED',
                                         x_notification_status_code	=> lv_awd_notif_status,
                                         x_notification_status_date	=> TRUNC(sysdate),
                                         x_publish_in_ss_flag       => g_publish_in_ss_flag
                                        );
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'-----new award--------');
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'award_id:'||l_award_id);
             END IF;
             -- Once the Award is successfully created, Attach all the To Do which are defined at the fund level
             -- to the student from the given fund.
             IF l_post <> 'Y' THEN
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'calling add_todo as l_post <> Y');
                END IF;
                add_todo(l_awd_tot.fund_id, l_base_id);

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'calling igf_ap_batch_ver_prc_pkg.update_process_status as l_post <> Y');
                END IF;
                -- Change the Application Process status of student accordingly after ToDo Items are added.
                igf_ap_batch_ver_prc_pkg.update_process_status(l_base_id, NULL);
             END IF;

             --Open the Cursor to fetch Person number for the Base Id l_base_id
             OPEN  c_person_number;
             FETCH c_person_number INTO l_person_number;
             CLOSE c_person_number;

             -- Log the Award details of the student in the OUTPUT file
             get_plan_desc(l_awd_tot.adplans_id,lv_method_name,lv_method_desc);

             fnd_file.put_line(fnd_file.output,' ' );
             fnd_file.put_line(fnd_file.output,' ' );
             fnd_message.set_name('IGF','IGF_AW_AWD_DTLS');
             fnd_file.put_line(fnd_file.output,RPAD('-',10,'-') ||'  '|| RPAD(fnd_message.get,20) ||'  '|| RPAD('-',10,'-'));

             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG', 'PERSON_NUMBER'), 40, ' ') || '    :  ' || l_person_number.person_number );
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG', 'SSN'), 40, ' ')           || '    :  ' || l_person_number.ssn );
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG', 'FUND_CODE'), 40, ' ')     || '    :  ' || l_fmast.fund_code);
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG', 'OFFERED_AMT'), 40,  ' ')  || '    :  ' || TO_CHAR(l_awd_tot.offered_amt * ln_com_perct/100) );
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWD_DIST_PLAN'), 40, ' ')   || '    :  ' || lv_method_name);
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','DIST_PLAN_METHOD'),40,' ')  || '    :  ' || lv_method_desc);
             fnd_file.put_line(fnd_file.output,' ' );

             l_fee1 := NULL;
             l_fee2 := NULL;

             -- FA 122  Loan Enhancents 30-sep-2003  Added the base_id parameter to the get_loan_fee1 , get_loan_fee1 calls

             -- Get the Direct and Federal/Common Loan limit Amounts
             IF    igf_sl_gen.chk_dl_fed_fund_code (l_fmast.fed_fund_code) = 'TRUE'
                OR igf_sl_gen.chk_cl_fed_fund_code (l_fmast.fed_fund_code) = 'TRUE'  THEN
                   l_fee1 :=  igf_sl_award.get_loan_fee1 ( l_fmast.fed_fund_code,
                                                           l_fmast.ci_cal_type ,
                                                           l_fmast.ci_sequence_number,
                                                           l_base_id,
                                                           igf_sl_award.get_alt_rel_code(l_fmast.fund_code));
             END IF;

             -- Get the Guarantor fee % for Commonline Loans
             IF igf_sl_gen.chk_cl_fed_fund_code (l_fmast.fed_fund_code) = 'TRUE' THEN
                l_fee2 :=  igf_sl_award.get_loan_fee2( l_fmast.fed_fund_code,
                                                       l_fmast.ci_cal_type ,
                                                       l_fmast.ci_sequence_number,
                                                       l_base_id,
                                                       igf_sl_award.get_alt_rel_code(l_fmast.fund_code));
             END IF;

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'called got loan limits');
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_fee1:'||l_fee1);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_fee2:'||l_fee2);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'calling get_disbursements');
             END IF;

             -- Create the Disbursements for this particualr Award
             -- This procedure call creates disbursements INTO temporay table
             get_disbursements(
                               l_awd_tot.fund_id,
                               l_awd_tot.offered_amt,
                               l_base_id,
                               l_process_id,
                               l_awd_tot.accepted_amt,
                               l_called_from,
                               l_fmast.nslds_disb_da,
                               l_fmast.disb_exp_da,
                               l_fmast.disb_verf_da,
                               l_disb_dates,
                               l_awd_tot.adplans_id,
                               NULL
                               );

             -- Flag verifing for over award holds, Initialize the Disbursement Hold flag
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after calling get_disbursements l_awd_tot.over_award:'||l_awd_tot.over_award);
             END IF;
             IF l_awd_tot.over_award = 'HOLD' THEN
                l_hld_flg := 'Y';
             ELSE
                l_hld_flg := 'N';
             END IF;

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_hld_flg:'||l_hld_flg||' as l_awd_tot.over_award:'||l_awd_tot.over_award);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_cnt:'||l_disb_dates.count);
             END IF;

             l_disb_num := NULL;
             l_cnt      := l_disb_dates.count;

             -- Get the Total Number of disbursements which needs to be created
             ln_db_run_gross_amt := 0;
             ln_total_disb   := 0;

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'opening c_awd_disb_cnt with adplans_id:'||l_awd_tot.adplans_id||' award_id:'||l_awd_tot.award_id);
             END IF;
             OPEN  c_awd_disb_cnt( l_base_id, l_awd_tot.fund_id, l_process_id,l_awd_tot.adplans_id,l_awd_tot.award_id );
             FETCH c_awd_disb_cnt INTO ln_total_disb;
             CLOSE c_awd_disb_cnt;

             -- Bug  3062062
             IF ln_total_disb = 0 THEN
               ROLLBACK TO disb_not_found;
               l_ret_status      := 'D'; -- No disbursements created
               fnd_message.set_name('IGF','IGF_AW_SKP_FUND');
               fnd_message.set_token('FUND',l_fmast.fund_code);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'raising skip_record as total disbursements is 0');
               END IF;
               RAISE SKIP_RECORD;
             END IF;

             -- Round disbursement amount for non-Pell funds.
             -- Pell disbursement rounding is handled separately in IGFGR11B
            IF get_fed_fund_code(p_fund_id => l_awd_tot.fund_id) <> 'PELL'  THEN
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,
                                'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,
                                'Calling round_off_disbursements with fund_id:'||l_awd_tot.fund_id||', base_id:'||l_base_id||
                                ', l_process_id: ' ||l_process_id||', Award_Id: '||l_awd_tot.award_id||', adplans_id: '||l_awd_tot.adplans_id||
                                ', offered_amt: '||l_awd_tot.offered_amt||', g_method_cd: '||g_method_cd||', ln_total_disb: '||ln_total_disb);
               END IF;

               round_off_disbursements(
                                        l_awd_tot.fund_id,
                                        l_base_id,
                                        l_process_id,
                                        l_awd_tot.award_id,
                                        l_awd_tot.adplans_id,
                                        l_awd_tot.offered_amt,
                                        g_method_cd,
                                        ln_total_disb
                                      );
            END IF;

             IF l_fmast.entitlement = 'Y' AND l_hld_flg = 'Y' THEN
               /*
                Since the fund is an entitlement, we should not insert overaward holds on the award.
                we show a message to the user saying that this award will result in an overaward, but we are not
                inserting overaward holds as the fund is an entitlement
               */
               fnd_message.set_name('IGF','IGF_AW_ENTITLE_OVAWD');
               fnd_message.set_token('FUND_CODE',l_fmast.fund_code);
               fnd_message.set_token('AWD',TO_CHAR(l_awd_tot.offered_amt * ln_com_perct / 100));
               fnd_file.put_line(fnd_file.log,fnd_message.get);
             END IF;

             IF g_sf_packaging = 'F' AND l_hld_flg = 'Y' AND l_fmast.entitlement <> 'Y' THEN
               /*
                 Packaging process always gives upto the need of the student.
                 So, a hold is not really necessary.
                 This check is necessary in single-fund-packaging where overaward will occur.
               */
               l_hld_flg := 'N';
             END IF;


             --
             -- Get the total number of disbursements
             --
             ln_total_disb_num := ln_total_disb;

             -- Get Disbursement records for this award that were calculated above in "get_disbursements" procedure
             OPEN  c_awd_disb( l_base_id, l_awd_tot.fund_id, l_process_id,l_awd_tot.adplans_id,l_awd_tot.award_id );
             LOOP
               FETCH c_awd_disb INTO l_awd_disb;

               EXIT WHEN c_awd_disb%NOTFOUND;

               -- Initialize the Disbursement Number. Increment this counter for each disbursement
               -- This Dusbursement Number is unique in each Award.
               -- Initialize the Disbursement date with the calculated value
               l_disb_num  := NVL(l_disb_num,0) + 1;
               l_disb_date := fnd_date.chardate_to_date(l_awd_disb.temp_char_val1);

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'$$$$$$ l_disb_num:'||l_disb_num||' $$$$$$');
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_date:'||l_disb_date);
               END IF;
               -- Initialize the Disbursement Verification dates, Expiration date, NSLDS dates
               -- for each disbursement number
               FOR i IN 1..l_disb_dates.COUNT LOOP

                 IF     l_disb_dates(i).process_id = l_awd_disb.process_id
                    AND l_disb_dates(i).sl_no = l_awd_disb.sl_number THEN
                        l_nslds_dt             := l_disb_dates(i).nslds_disb_date;
                        l_verf_dt              := l_disb_dates(i).disb_verf_dt;
                        l_exp_dt               := l_disb_dates(i).disb_exp_dt;
                        l_credits              := l_disb_dates(i).min_credit_pts;
                        l_attendance_type_code := l_disb_dates(i).attendance_type_code;
                        l_base_attendance_type_code := l_disb_dates(i).base_attendance_type_code;

                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Get data from disb PL-SQL Table, l_disb_dates('||i||').process_id: '||l_disb_dates(i).process_id);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').sl_no: '||l_disb_dates(i).sl_no);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_disb.process_id '||l_awd_disb.process_id );
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_disb.sl_number  '||l_awd_disb.sl_number);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').nslds_disb_date:'||l_disb_dates(i).nslds_disb_date);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').disb_verf_dt:'||l_disb_dates(i).disb_verf_dt);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').disb_exp_dt:'||l_disb_dates(i).disb_exp_dt);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').min_credit_pts:'||l_disb_dates(i).min_credit_pts);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').attendance_type_code:'||l_disb_dates(i).attendance_type_code);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').base_attendance_type:'||l_disb_dates(i).base_attendance_type_code);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates - l_attendance_type_code : '||l_attendance_type_code);
                        END IF;
                 END IF;
               END LOOP;

               -- Delay Disb date by the "disb_delay_days" if necessary
               -- Check for disbursement delay days linked to NSLDS only for the first disbusement
               -- Note- NSLDS is applicable only for DL and CL loans
               IF (l_disb_num = 1)  AND
                  ( (igf_sl_gen.chk_dl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE') OR
                    (igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE')
                  ) THEN

                   l_disb_date1 := NULL;
                   OPEN  c_nslds ( l_person_number.person_id );
                   FETCH c_nslds INTO x_nslds;

                   IF c_nslds%NOTFOUND THEN
                      -- No NSLDS History exists for current student, so delay the disbursement to NSLDS Date
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'no NSLDS history for the student, so apply NSLDS date offset to delay disb date.');
                      END IF;

                      IF l_nslds_dt IS NOT NULL THEN
                         l_disb_date1 := l_nslds_dt; --to be changed by disbursements build
                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Disb date after applying NSLDS offset, l_disb_date1: '||l_disb_date1);
                         END IF;
                      ELSE
                        -- l_nslds_dt is NULL
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,
                                         'Cannot compute NSLDS offset date. Either NSLDS offset has not been setup in Fund Manager or some error in computing NSLDS offset date. So using the actual disb date.');
                        END IF;
                      END IF;
                   ELSE
                      -- NSLDS history exists for the student, so do NOT delay disb date
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Person# ' ||l_person_number.person_number|| ' has NSLDS history, so NOT applying NSLDS date offset.');
                      END IF;
                   END IF;

                   CLOSE c_nslds;
               END IF; -- First Disbursement

               -- Get the Origination fee for Direct/Commonline Loans
               l_fee_paid1 := NULL;
               l_fee_paid2 := NULL;
               l_fee_amt1  := NULL;
               l_fee_amt2  := NULL;

               -- masehgal    TRUNC these values also .. then use these for "other than" dl computations
               IF igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE'   THEN
                 l_fee_amt1 :=  NVL(l_awd_disb.offered_amt,0) * (NVL(l_fee1,0) / 100) ;
                 l_fee_amt1 :=  TRUNC(l_fee_amt1);
               ELSE
                 l_fee_amt1 := 0;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after truncating, l_fee_amt1 is '||l_fee_amt1);
               END IF;
               -- Get the Guarantor fee for Commonline Loans
               IF igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE'  THEN
                 l_fee_amt2 :=  NVL(l_awd_disb.offered_amt,0) * (NVL(l_fee2,0) / 100) ;
                 l_fee_amt2 :=  TRUNC(l_fee_amt2);
               ELSE
                 l_fee_amt2 := 0;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after truncating l_fee_amt2 is '||l_fee_amt2);
               END IF;

               -- For LOANs, get the Hold Release Indicator which is defined at the fund level
               -- FA 122 Loans Enhancemnets added the l_auto_late_ind variable to get the auto_late_ind
               IF igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE' THEN
                 l_hold_rel_ind := igf_sl_award.get_cl_hold_rel_ind(
                                                                    l_fmast.fed_fund_code,
                                                                    l_fmast.ci_cal_type,
                                                                    l_fmast.ci_sequence_number,
                                                                    l_base_id,
                                                                    igf_sl_award.get_alt_rel_code(l_fmast.fund_code)
                                                                   );
                 l_auto_late_ind := igf_sl_award.get_cl_auto_late_ind(
                                                                    l_fmast.fed_fund_code,
                                                                    l_fmast.ci_cal_type,
                                                                    l_fmast.ci_sequence_number,
                                                                    l_base_id,
                                                                    igf_sl_award.get_alt_rel_code(l_fmast.fund_code)
                                                                   );
               ELSE
                 l_hold_rel_ind := NULL;
                 l_auto_late_ind := NULL;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_hold_rel_ind:'||l_hold_rel_ind);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_auto_late_ind:'||l_auto_late_ind);
               END IF;
               -- For the Last disbursement insert the remaining disbursement amount of the fund
               -- Update the Running Totals of Gross Amount and Net Amount
               -- This is necessary as to avoid truncation fraction of amounts when there is decimals.
               IF l_disb_num = ln_total_disb THEN
                 ln_db_act_gross_amt  := ( l_awd_tot.offered_amt * ln_com_perct / 100 )- ln_db_run_gross_amt;

                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_award_id: '||l_award_id);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_num: '||l_disb_num);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'ln_db_act_gross_amt: '||ln_db_act_gross_amt);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'ln_db_run_gross_amt: '||ln_db_run_gross_amt);
                 END IF;

               ELSE
                 -- Update the running totals
                 ln_db_act_gross_amt  :=  l_awd_disb.offered_amt;

                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'ln_db_act_gross_amt:'||ln_db_act_gross_amt);
                 END IF;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'for last disb insert remaining amount!ln_db_act_gross_amt:'||ln_db_act_gross_amt);
               END IF;
               -- Incase of Direct Loans round off amounts
               IF igf_sl_gen.chk_dl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE'  THEN
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'igf_sl_gen.chk_dl_fed_fund_code('||l_fmast.fed_fund_code||')=TRUE');
                  END IF;
                  -- sjadhav Bug 2411031
                  -- Changed sequence of calling igf_sl_award.get_loan_amts and igf_sl_roundoff_digits_pkg.gross_fees_roundoff.
                  -- This is done becuase first round off disbursement gross amount should be calculated first and then net amount / fee amount etc

                  -- we are passing dummys here for Net and Fee amount as they will be calculated later on

                  igf_sl_roundoff_digits_pkg.gross_fees_roundoff(p_last_disb_num      => ln_total_disb_num,
                                                                 p_offered_amt        => l_awd_tot.offered_amt,
                                                                 p_fee_perct          => l_fee1,
                                                                 p_disb_gross_amt     => ln_db_act_gross_amt,
                                                                 p_disb_net_amt       => ln_dummy_net_amt,
                                                                 p_fee                => ln_dummy_fee_1
                                                                );




                   -- This routine will return Net Amount/ Fee Amounts / Interest Rebate Amount
                   igf_sl_award.get_loan_amts(
                                              l_fmast.ci_cal_type,
                                              l_fmast.ci_sequence_number,
                                              l_fmast.fed_fund_code,
                                              NVL(ln_db_act_gross_amt,0),
                                              l_rebate,
                                              l_fee_amt1,
                                              l_net
                                             );

                   l_awd_disb.temp_num_val1 := NVL(l_net,0);

                   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after calling igf_sl_award.get_loan_amts,l_awd_disb.temp_num_val1:'||l_awd_disb.temp_num_val1);
                   END IF;

               -- masehgal    rounding off for CL
               ELSIF igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE'  THEN
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'igf_sl_gen.chk_cl_fed_fund_code('||l_fmast.fed_fund_code||')=TRUE');
                  END IF;
                  -- we are passing dummys here for Net and Fee amount as they will be calculated later on
                  igf_sl_roundoff_digits_pkg.cl_gross_fees_roundoff(
                                                                    p_last_disb_num      => ln_total_disb_num,
                                                                    p_offered_amt        => l_awd_tot.offered_amt,
                                                                    p_disb_gross_amt     => ln_db_act_gross_amt );

                  l_awd_disb.temp_num_val1  := NVL(ln_db_act_gross_amt, 0) -
                                               NVL( l_fee_amt1, 0 )        -
                                               NVL( l_fee_amt2, 0 );

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after calling igf_sl_roundoff_digits_pkg.cl_gross_fees_roundoff,l_awd_disb.temp_num_val1:'||l_awd_disb.temp_num_val1);
                  END IF;

                  l_rebate := NULL;

               ELSE
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'igf_sl_gen.chk_dl_fed_fund_code('||l_fmast.fed_fund_code||')=FALSE');
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'igf_sl_gen.chk_cl_fed_fund_code('||l_fmast.fed_fund_code||')=FALSE');
                  END IF;
                  -- For funds other than the loans, calculate the Total Net amount
                  l_awd_disb.temp_num_val1  := NVL(ln_db_act_gross_amt, 0);
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_disb.temp_num_val1 = NVL(ln_db_act_gross_amt, 0) = '||l_awd_disb.temp_num_val1);
                  END IF;
                  l_rebate   := NULL;
                  l_fee_amt1 := NULL;
                  l_fee_amt2 := NULL;
               END IF;

               ln_db_run_gross_amt  :=  ln_db_run_gross_amt + ln_db_act_gross_amt;
               IF l_fmast.pckg_awd_stat = 'ACCEPTED' THEN
                 ln_db_act_accpt_amt  :=  ln_db_act_gross_amt;
               ELSE
                 ln_db_act_accpt_amt  :=  0;
               END IF;
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after checking awd_initial_status, ln_db_act_accpt_amt:'||ln_db_act_accpt_amt);
               END IF;

               IF l_disb_date1 IS NOT NULL AND l_disb_num = 1 THEN
                 -- No NSLDS history. Apply NSLDS date offset to delay disbursement date
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,
                                  'l_disb_date1 IS NOT NULL and l_disb_num = 1. So, setting lb_disb_update to TRUE to apply NSLDS offset');
                 END IF;
                 lb_disb_update := TRUE;
               ELSIF l_disb_num = 1 THEN
                 -- NSLDS history exists (or) NSLDS history does not exist, but the NSLDS date offset is not set (i.e. l_disb_date1 is null) (or) it is a non DL/CL fund
                 -- In both cases, we must NOT delay disbursement date
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,
                                  'l_disb_date1 IS NULL and l_disb_num = 1. So, setting lb_disb_update to FALSE so that NSLDS offset is NOT applied');
                 END IF;
                 lb_disb_update := FALSE;
               END IF;

               lv_rowid   := NULL;
               IF l_fmast.fed_fund_code IN ('FWS')  THEN
                 l_attendance_type_code      := NULL;
                 l_base_attendance_type_code := NULL;
               END IF;

               IF l_fmast.entitlement = 'Y' THEN
                 --make l_hld_flg to 'N'
                 --this is necessary as there has to be no holds on an entitlement
                 l_hld_flg := 'N';
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Before inserting into igf_aw_awd_disb table with l_attendance_type_code : '||l_attendance_type_code);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'inserting into igf_aw_awd_disb table with manual_hold_ind:'||l_hld_flg);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Before inserting into igf_aw_awd_disb table with l_base_attendance_type_code : '||l_base_attendance_type_code);
               END IF;

               IF     (l_fmast.fed_fund_code = 'PELL' AND
                      igf_sl_dl_validation.check_full_participant (l_fmast.ci_cal_type,l_fmast.ci_sequence_number,'PELL'))
                   OR (l_fmast.fed_fund_code IN ('DLP','DLS','DLU') AND
                      igf_sl_dl_validation.check_full_participant (l_fmast.ci_cal_type,l_fmast.ci_sequence_number,'DL'))
                   THEN
                 l_hold_rel_ind := 'FALSE';
               END IF;

               igf_aw_awd_disb_pkg.insert_row(
                                              x_rowid                  => lv_rowid,
                                              x_award_id               => l_award_id,
                                              x_disb_num               => l_disb_num,
                                              x_tp_cal_type            => l_awd_disb.tp_cal_type,
                                              x_tp_sequence_number     => l_awd_disb.tp_sequence_number,
                                              x_disb_gross_amt         => ln_db_act_gross_amt ,
                                              x_fee_1                  => NVL(l_fee_amt1, 0),
                                              x_fee_2                  => NVL(l_fee_amt2, 0),
                                              x_disb_net_amt           => NVL(l_awd_disb.temp_num_val1,0),
                                              x_disb_date              => l_disb_date,
                                              x_trans_type             => 'P',
                                              x_elig_status            => 'N',
                                              x_elig_status_date       => TRUNC(SYSDATE),
                                              x_affirm_flag            => 'N',
                                              x_hold_rel_ind           => l_hold_rel_ind,
                                              x_manual_hold_ind        => l_hld_flg,
                                              x_disb_status            => NULL,
                                              x_disb_status_date       => NULL,
                                              x_late_disb_ind          => l_auto_late_ind, -- FA 122 Added l_auto_late_ind
                                              x_fund_dist_mthd         => 'E',
                                              x_prev_reported_ind      => 'N',
                                              x_fund_release_date      => NULL,
                                              x_fund_status            => NULL,
                                              x_fund_status_date       => NULL,
                                              x_fee_paid_1             => NVL(l_fee_paid1, 0),
                                              x_fee_paid_2             => NVL(l_fee_paid2, 0),
                                              x_cheque_number          => NULL,
                                              x_ld_cal_type            => l_awd_disb.ld_cal_type,
                                              x_ld_sequence_number     => l_awd_disb.ld_sequence_number,
                                              x_disb_accepted_amt      => ln_db_act_accpt_amt,
                                              x_disb_paid_amt          => l_awd_disb.paid_amt,
                                              x_rvsn_id                => NULL,
                                              x_int_rebate_amt         => NVL(l_rebate, 0),
                                              x_force_disb             => NULL,
                                              x_min_credit_pts         => l_credits,
                                              x_disb_exp_dt            => l_exp_dt,
                                              x_verf_enfr_dt           => l_verf_dt,
                                              x_fee_class              => NULL,
                                              x_show_on_bill           => l_fmast.show_on_bill,
                                              x_attendance_type_code   => l_attendance_type_code,
                                              x_mode                   => 'R',
                                              x_base_attendance_type_code   => l_base_attendance_type_code,
                                              x_payment_prd_st_date    => NULL,
                                              x_change_type_code          => NULL,
                                              x_fund_return_mthd_code     => NULL,
                                              x_direct_to_borr_flag       => 'N'
                                             );

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after inserting into disb table....l_hld_flg: '||l_hld_flg);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after inserting into disb table....l_attendance_type_code: '||l_attendance_type_code);
               END IF;
               -- If Over Award Hold is present at the award, then create 'SYSTEM' Hold for each disbursement of the Award
               IF l_hld_flg = 'Y' THEN

                 l_hold_id := NULL;
                 lv_rowid  := NULL;


                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'inserting into igf_db_disb_holds table');
                 END IF;
                 igf_db_disb_holds_pkg.insert_row(
                                                  x_rowid              =>  lv_rowid,
                                                  x_hold_id            =>  l_hold_id,
                                                  x_award_id           =>  l_award_id,
                                                  x_disb_num           =>  l_disb_num,
                                                  x_hold               =>  'OVERAWARD',
                                                  x_hold_date          =>  TRUNC(SYSDATE),
                                                  x_hold_type          =>  'SYSTEM',
                                                  x_release_date       =>  NULL,
                                                  x_release_flag       =>  'N',
                                                  x_release_reason     =>  NULL,
                                                  x_mode               =>  'R'
                                                 );
               END IF;
             END LOOP;--end loop for c_awd_disb
             IF c_awd_disb%ISOPEN THEN
               CLOSE c_awd_disb;
             END IF;

             IF lb_disb_update THEN

               OPEN c_disb(l_award_id,1);
               FETCH c_disb INTO l_disb;
               CLOSE c_disb;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id, 'Flag set - updating disb num 1 with disb date delayed by NSLDS offset: ' ||l_disb_date1);
               END IF;

               igf_aw_awd_disb_pkg.update_row(
                                              x_mode                       => 'R',
                                              x_rowid                      => l_disb.row_id,
                                              x_award_id                   => l_disb.award_id,
                                              x_disb_num                   => l_disb.disb_num,
                                              x_tp_cal_type                => l_disb.tp_cal_type,
                                              x_tp_sequence_number         => l_disb.tp_sequence_number,
                                              x_disb_gross_amt             => l_disb.disb_gross_amt,
                                              x_fee_1                      => l_disb.fee_1,
                                              x_fee_2                      => l_disb.fee_2,
                                              x_disb_net_amt               => l_disb.disb_net_amt,
                                              x_disb_date                  => l_disb_date1,
                                              x_trans_type                 => l_disb.trans_type,
                                              x_elig_status                => l_disb.elig_status,
                                              x_elig_status_date           => l_disb.elig_status_date,
                                              x_affirm_flag                => l_disb.affirm_flag,
                                              x_hold_rel_ind               => l_disb.hold_rel_ind,
                                              x_manual_hold_ind            => l_disb.manual_hold_ind,
                                              x_disb_status                => l_disb.disb_status,
                                              x_disb_status_date           => l_disb.disb_status_date,
                                              x_late_disb_ind              => l_disb.late_disb_ind,
                                              x_fund_dist_mthd             => l_disb.fund_dist_mthd,
                                              x_prev_reported_ind          => l_disb.prev_reported_ind ,
                                              x_fund_release_date          => l_disb.fund_release_date,
                                              x_fund_status                => l_disb.fund_status,
                                              x_fund_status_date           => l_disb.fund_status_date,
                                              x_fee_paid_1                 => l_disb.fee_paid_1,
                                              x_fee_paid_2                 => l_disb.fee_paid_2,
                                              x_cheque_number              => l_disb.cheque_number,
                                              x_ld_cal_type                => l_disb.ld_cal_type,
                                              x_ld_sequence_number         => l_disb.ld_sequence_number,
                                              x_disb_accepted_amt          => l_disb.disb_accepted_amt,
                                              x_disb_paid_amt              => l_disb.disb_paid_amt,
                                              x_rvsn_id                    => l_disb.rvsn_id,
                                              x_int_rebate_amt             => l_disb.int_rebate_amt,
                                              x_force_disb                 => l_disb.force_disb,
                                              x_min_credit_pts             => l_disb.min_credit_pts,
                                              x_disb_exp_dt                => l_disb.disb_exp_dt,
                                              x_verf_enfr_dt               => l_disb.verf_enfr_dt,
                                              x_fee_class                  => l_disb.fee_class,
                                              x_show_on_bill               => l_disb.show_on_bill,
                                              x_attendance_type_code       => l_disb.attendance_type_code,
                                              x_base_attendance_type_code  => l_disb.base_attendance_type_code,
                                              x_payment_prd_st_date        => l_disb.payment_prd_st_date,
                                              x_change_type_code           => l_disb.change_type_code,
                                              x_fund_return_mthd_code      => l_disb.fund_return_mthd_code,
                                              x_direct_to_borr_flag        => l_disb.direct_to_borr_flag
                                             );
             END IF;
          ELSE -- l_awd_tot.award_id is not null check
            --update the award here. this award has been repackaged
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'starting repackaging for award_id:'||l_awd_tot.award_id);
            END IF;
            OPEN c_award_det(l_awd_tot.award_id);
            FETCH c_award_det INTO l_award_det;
            CLOSE c_award_det;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'c_award_Det fetched rowid:'||l_award_det.row_id);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'-----old award--------');
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'award_id:'||l_award_det.award_id);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_tot.offered_amt:'||l_awd_tot.offered_amt);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_tot.accepted_amt:'||l_awd_tot.accepted_amt);
            END IF;

            -- here, a check is made on the fed_fund_code of the fund and paid_amt.
            IF l_fmast.fed_fund_code = 'FWS' AND l_award_det.paid_amt > l_awd_tot.offered_amt THEN
              --skip the student
              fnd_message.set_name('IGF','IGF_AW_INV_FWS_AWD');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              RAISE INV_FWS_AWARD;
            END IF;

            IF l_award_det.award_status = 'CANCELLED' THEN
              l_award_status := l_fmast.pckg_awd_stat;
            ELSE
              l_award_status := l_award_det.award_status;
            END IF;

            IF l_fmast.fed_fund_code = 'PELL' AND g_phasein_participant THEN
              l_awd_tot.adplans_id := l_award_det.adplans_id;
            END IF;

            IF l_fmast.fed_fund_code = 'PELL' THEN
              /*
                Ask user to re-originate PELL
              */
              update_pell_orig_stat(l_award_det.award_id,l_awd_tot.offered_amt);
            END IF;

            IF l_fmast.sys_fund_type = 'LOAN' AND l_fmast.fed_fund_code IN ('DLS','DLU','DLP') THEN
              update_loan_stat(l_award_det.award_id,l_awd_tot.offered_amt);
            END IF;
            igf_aw_award_pkg.update_row(
                                        x_rowid                  => l_award_det.row_id,
                                        x_award_id               => l_award_det.award_id,
                                        x_fund_id                => l_award_det.fund_id,
                                        x_base_id                => l_award_det.base_id,
                                        x_offered_amt            => l_awd_tot.offered_amt,
                                        x_accepted_amt           => l_awd_tot.accepted_amt,
                                        x_paid_amt               => l_award_det.paid_amt,
                                        x_packaging_type         => l_award_det.packaging_type,
                                        x_batch_id               => l_award_det.batch_id,
                                        x_manual_update          => l_award_det.manual_update,
                                        x_rules_override         => l_award_det.rules_override,
                                        x_award_date             => l_award_det.award_date,
                                        x_award_status           => l_award_status,
                                        x_attribute_category     => l_award_det.attribute_category,
                                        x_attribute1             => l_award_det.attribute1,
                                        x_attribute2             => l_award_det.attribute2,
                                        x_attribute3             => l_award_det.attribute3,
                                        x_attribute4             => l_award_det.attribute4,
                                        x_attribute5             => l_award_det.attribute5,
                                        x_attribute6             => l_award_det.attribute6,
                                        x_attribute7             => l_award_det.attribute7,
                                        x_attribute8             => l_award_det.attribute8,
                                        x_attribute9             => l_award_det.attribute9,
                                        x_attribute10            => l_award_det.attribute10,
                                        x_attribute11            => l_award_det.attribute11,
                                        x_attribute12            => l_award_det.attribute12,
                                        x_attribute13            => l_award_det.attribute13,
                                        x_attribute14            => l_award_det.attribute14,
                                        x_attribute15            => l_award_det.attribute15,
                                        x_attribute16            => l_award_det.attribute16,
                                        x_attribute17            => l_award_det.attribute17,
                                        x_attribute18            => l_award_det.attribute18,
                                        x_attribute19            => l_award_det.attribute19,
                                        x_attribute20            => l_award_det.attribute20,
                                        x_rvsn_id                => l_award_det.rvsn_id,
                                        x_mode                   => 'R',
                                        x_alt_pell_schedule      => l_award_det.alt_pell_schedule,
                                        x_award_number_txt       => l_award_det.award_number_txt,
                                        x_legacy_record_flag     => l_award_det.legacy_record_flag,
                                        x_adplans_id             => l_awd_tot.adplans_id,
                                        x_lock_award_flag        => NVL(l_awd_tot.lock_award_flag,'N'),
                                        x_app_trans_num_txt      => l_award_det.app_trans_num_txt,
                                        x_awd_proc_status_code   => 'AWARDED',
                                        x_notification_status_code	=> lv_awd_notif_status,
                                        x_notification_status_date	=> TRUNC(sysdate),
                                        x_publish_in_ss_flag        => g_publish_in_ss_flag
                                       );
             --Open the Cursor to fetch Person number for the Base Id l_base_id
             OPEN  c_person_number;
             FETCH c_person_number INTO l_person_number;
             CLOSE c_person_number;

             -- Log the Award details of the student in the OUTPUT file
             get_plan_desc(l_awd_tot.adplans_id,lv_method_name,lv_method_desc);

             fnd_file.put_line(fnd_file.output,' ' );
             fnd_file.put_line(fnd_file.output,' ' );
             fnd_message.set_name('IGF','IGF_AW_AWD_DTLS');
             fnd_file.put_line(fnd_file.output,RPAD('-',10,'-') ||'  '|| RPAD(fnd_message.get,20) ||'  '|| RPAD('-',10,'-'));

             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG', 'PERSON_NUMBER'), 40, ' ') || '    :  ' || l_person_number.person_number );
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG', 'SSN'), 40, ' ')           || '    :  ' || l_person_number.ssn );
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG', 'FUND_CODE'), 40, ' ')     || '    :  ' || l_fmast.fund_code);
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG', 'OFFERED_AMT'), 40,  ' ')  || '    :  ' || TO_CHAR(l_awd_tot.offered_amt * ln_com_perct/100) );
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWD_DIST_PLAN'), 40, ' ')   || '    :  ' || lv_method_name);
             fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','DIST_PLAN_METHOD'),40,' ')  || '    :  ' || lv_method_desc);
             fnd_file.put_line(fnd_file.output,' ' );

             l_fee1 := NULL;
             l_fee2 := NULL;

             -- FA 122  Loan Enhancents 30-sep-2003  Added the base_id parameter to the get_loan_fee1 , get_loan_fee1 calls

             -- Get the Direct and Federal/Common Loan limit Amounts
             IF    igf_sl_gen.chk_dl_fed_fund_code (l_fmast.fed_fund_code) = 'TRUE'
                OR igf_sl_gen.chk_cl_fed_fund_code (l_fmast.fed_fund_code) = 'TRUE'  THEN
                   l_fee1 :=  igf_sl_award.get_loan_fee1 ( l_fmast.fed_fund_code,
                                                           l_fmast.ci_cal_type ,
                                                           l_fmast.ci_sequence_number,
                                                           l_base_id,
                                                           igf_sl_award.get_alt_rel_code(l_fmast.fund_code));
             END IF;

             -- Get the Guarantor fee % for Commonline Loans
             IF igf_sl_gen.chk_cl_fed_fund_code (l_fmast.fed_fund_code) = 'TRUE' THEN
                l_fee2 :=  igf_sl_award.get_loan_fee2( l_fmast.fed_fund_code,
                                                       l_fmast.ci_cal_type ,
                                                       l_fmast.ci_sequence_number,
                                                       l_base_id,
                                                       igf_sl_award.get_alt_rel_code(l_fmast.fund_code));
             END IF;

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'called got loan limits');
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_fee1:'||l_fee1);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_fee2:'||l_fee2);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'calling get_disbursements');
             END IF;

             -- Create the Disbursements for this particualr Award
             -- This procedure call creates disbursements INTO temporay table
             get_disbursements(
                               l_awd_tot.fund_id,
                               l_awd_tot.offered_amt,
                               l_base_id,
                               l_process_id,
                               l_awd_tot.accepted_amt,
                               l_called_from,
                               l_fmast.nslds_disb_da,
                               l_fmast.disb_exp_da,
                               l_fmast.disb_verf_da,
                               l_disb_dates,
                               l_awd_tot.adplans_id,
                               l_award_det.award_id
                               );
             l_disb_num := NULL;
             l_cnt      := l_disb_dates.COUNT;

             -- Get the Total Number of disbursements which needs to be created
             ln_db_run_gross_amt := 0;
             ln_total_disb   := 0;
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'opening c_awd_disb_cnt with adplans_id:'||l_awd_tot.adplans_id||' award_id:'||l_awd_tot.award_id);
             END IF;
             OPEN  c_awd_disb_cnt( l_base_id, l_awd_tot.fund_id, l_process_id,l_awd_tot.adplans_id,l_awd_tot.award_id);
             FETCH c_awd_disb_cnt INTO ln_total_disb;
             CLOSE c_awd_disb_cnt;

             -- Bug  3062062
             IF ln_total_disb = 0 THEN
               ROLLBACK TO disb_not_found;
               l_ret_status      := 'D'; -- No disbursements created
               fnd_message.set_name('IGF','IGF_AW_SKP_FUND');
               fnd_message.set_token('FUND',l_fmast.fund_code);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'raising skip_record as total disbursements is 0');
               END IF;
               RAISE SKIP_RECORD;
             END IF;

             -- Round disbursement amount for non-Pell funds.
             -- Pell disbursement rounding is handled separately in IGFGR11B
             IF get_fed_fund_code(p_fund_id => l_awd_tot.fund_id) <> 'PELL'  THEN
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,
                                  'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,
                                  'Calling round_off_disbursements with fund_id:'||l_awd_tot.fund_id||', base_id:'||l_base_id||
                                  ', l_process_id: ' ||l_process_id||', Award_Id: '||l_awd_tot.award_id||', adplans_id: '||l_awd_tot.adplans_id||
                                  ', offered_amt: '||l_awd_tot.offered_amt||', g_method_cd: '||g_method_cd||', ln_total_disb: '||ln_total_disb);
                 END IF;

                 round_off_disbursements(
                                          l_awd_tot.fund_id,
                                          l_base_id,
                                          l_process_id,
                                          l_awd_tot.award_id,
                                          l_awd_tot.adplans_id,
                                          l_awd_tot.offered_amt,
                                          g_method_cd,
                                          ln_total_disb
                                        );
             END IF;

             IF l_fmast.entitlement = 'Y' AND l_hld_flg = 'Y' THEN
               /*
                Since the fund is an entitlement, we should not insert overaward holds on the award.
                we show a message to the user saying that this award will result in an overaward, but we are not
                inserting overaward holds as the fund is an entitlement
               */
               fnd_message.set_name('IGF','IGF_AW_ENTITLE_OVAWD');
               fnd_message.set_token('FUND_CODE',l_fmast.fund_code);
               fnd_message.set_token('AWD',TO_CHAR(l_awd_tot.offered_amt * ln_com_perct / 100));
               fnd_file.put_line(fnd_file.log,fnd_message.get);
             END IF;

             IF g_sf_packaging = 'F' AND l_hld_flg = 'Y' AND l_fmast.entitlement <> 'Y' THEN
               /*
                 Packaging process always gives upto the need of the student.
                 So, a hold is not really necessary.
                 This check is necessary in single-fund-packaging where overaward will occur.
               */
               l_hld_flg := 'N';
             END IF;


             --
             -- Get the total number of disbursements
             --
             ln_total_disb_num := ln_total_disb;

             -- Get Disbursement records for this award that were calculated above in "get_disbursements" procedure
             OPEN  c_awd_disb( l_base_id, l_awd_tot.fund_id, l_process_id,l_awd_tot.adplans_id,l_awd_tot.award_id  );
             LOOP
               FETCH c_awd_disb INTO l_awd_disb;

               EXIT WHEN c_awd_disb%NOTFOUND;

               -- Initialize the Disbursement Number. Increment this counter for each disbursement
               -- This Dusbursement Number is unique in each Award.
               -- Initialize the Disbursement date with the calculated value
               l_disb_num  := NVL(l_disb_num,0) + 1;
               l_disb_date := fnd_date.chardate_to_date(l_awd_disb.temp_char_val1);

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'$$$$$$ l_disb_num:'||l_disb_num||' $$$$$$');
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_date: '||l_disb_date);
               END IF;
               -- Initialize the Disbursement Verification dates, Expiration date, NSLDS dates
               -- for each disbursement number
               FOR i IN 1..l_disb_dates.COUNT LOOP

                 IF     l_disb_dates(i).process_id = l_awd_disb.process_id
                    AND l_disb_dates(i).sl_no = l_awd_disb.sl_number THEN
                        l_nslds_dt             := l_disb_dates(i).nslds_disb_date;
                        l_verf_dt              := l_disb_dates(i).disb_verf_dt;
                        l_exp_dt               := l_disb_dates(i).disb_exp_dt;
                        l_credits              := l_disb_dates(i).min_credit_pts;
                        l_attendance_type_code := l_disb_dates(i).attendance_type_code;
                        l_base_attendance_type_code := l_disb_dates(i).base_attendance_type_code;

                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Get data from disb PL-SQL Table, l_disb_dates('||i||').process_id: '||l_disb_dates(i).process_id);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').sl_no: '||l_disb_dates(i).sl_no);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_disb.process_id '||l_awd_disb.process_id );
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_disb.sl_number  '||l_awd_disb.sl_number);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').nslds_disb_date:'||l_disb_dates(i).nslds_disb_date);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').disb_verf_dt:'||l_disb_dates(i).disb_verf_dt);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').disb_exp_dt:'||l_disb_dates(i).disb_exp_dt);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').min_credit_pts:'||l_disb_dates(i).min_credit_pts);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').attendance_type_code:'||l_disb_dates(i).attendance_type_code);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates('||i||').base_attendance_type:'||l_disb_dates(i).base_attendance_type_code);
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_dates - l_attendance_type_code : '||l_attendance_type_code);
                        END IF;
                 END IF;
               END LOOP;

               -- Delay Disb date by the "disb_delay_days" if necessary
               -- Check for disbursement delay days linked to NSLDS only for the first disbusement
               -- Note- NSLDS is applicable only for DL and CL loans
               IF (l_disb_num = 1) AND
                  ( (igf_sl_gen.chk_dl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE') OR
                    (igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE')
                  ) THEN

                   l_disb_date1 := NULL;
                   OPEN  c_nslds ( l_person_number.person_id );
                   FETCH c_nslds INTO x_nslds;

                   IF c_nslds%NOTFOUND THEN
                      -- No NSLDS History exists for current student, so delay the disbursement to NSLDS Date
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'no NSLDS history for the student, so apply NSLDS date offset to delay disb date.');
                      END IF;

                      IF l_nslds_dt IS NOT NULL THEN
                         l_disb_date1 := l_nslds_dt; --to be changed by disbursements build

                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'NSLDS disb date offset, l_disb_date1:'||l_disb_date1);
                         END IF;
                      ELSE
                        -- l_nslds_dt is NULL
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,
                                         'Cannot compute NSLDS offset date. Either NSLDS offset has not been setup in Fund Manager or some error in computing NSLDS offset date. So using the actual disb date.');
                        END IF;
                      END IF;
                   ELSE
                      -- NSLDS history exists for the student, so do NOT delay disb date
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Person# ' ||l_person_number.person_number|| ' has NSLDS history, so NOT applying NSLDS date offset.');
                      END IF;
                   END IF;

                   CLOSE c_nslds;
               END IF; -- First Disbursement

               -- Get the Origination fee for Direct/Commonline Loans
               l_fee_paid1 := NULL;
               l_fee_paid2 := NULL;
               l_fee_amt1  := NULL;
               l_fee_amt2  := NULL;

               -- masehgal    TRUNC these values also .. then use these for "other than" dl computations
               IF igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE'   THEN
                 l_fee_amt1 :=  NVL(l_awd_disb.offered_amt,0) * (NVL(l_fee1,0) / 100) ;
                 l_fee_amt1 :=  TRUNC(l_fee_amt1);
               ELSE
                 l_fee_amt1 := 0;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after truncating, l_fee_amt1 is '||l_fee_amt1);
               END IF;
               -- Get the Guarantor fee for Commonline Loans
               IF igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE'  THEN
                 l_fee_amt2 :=  NVL(l_awd_disb.offered_amt,0) * (NVL(l_fee2,0) / 100) ;
                 l_fee_amt2 :=  TRUNC(l_fee_amt2);
               ELSE
                 l_fee_amt2 := 0;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after truncating l_fee_amt2 is '||l_fee_amt2);
               END IF;

               -- For LOANs, get the Hold Release Indicator which is defined at the fund level
               -- FA 122 Loans Enhancemnets added the l_auto_late_ind variable to get the auto_late_ind
               IF igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE' THEN
                 l_hold_rel_ind := igf_sl_award.get_cl_hold_rel_ind(
                                                                    l_fmast.fed_fund_code,
                                                                    l_fmast.ci_cal_type,
                                                                    l_fmast.ci_sequence_number,
                                                                    l_base_id,
                                                                    igf_sl_award.get_alt_rel_code(l_fmast.fund_code)
                                                                   );
                 l_auto_late_ind := igf_sl_award.get_cl_auto_late_ind(
                                                                    l_fmast.fed_fund_code,
                                                                    l_fmast.ci_cal_type,
                                                                    l_fmast.ci_sequence_number,
                                                                    l_base_id,
                                                                    igf_sl_award.get_alt_rel_code(l_fmast.fund_code)
                                                                   );
               ELSE
                 l_hold_rel_ind := NULL;
                 l_auto_late_ind := NULL;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_hold_rel_ind:'||l_hold_rel_ind);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_auto_late_ind:'||l_auto_late_ind);
               END IF;
               -- For the Last disbursement insert the remaining disbursement amount of the fund
               -- Update the Running Totals of Gross Amount and Net Amount
               -- This is necessary as to avoid truncation fraction of amounts when there is decimals.
               IF l_disb_num = ln_total_disb THEN
                 ln_db_act_gross_amt  := ( l_awd_tot.offered_amt * ln_com_perct / 100 )- ln_db_run_gross_amt;

                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_award_det.award_id: '||l_award_det.award_id);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_num: '||l_disb_num);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'ln_db_act_gross_amt: '||ln_db_act_gross_amt);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'ln_db_run_gross_amt: '||ln_db_run_gross_amt);
                 END IF;

               ELSE
                 -- Update the running totals
                 ln_db_act_gross_amt  :=  l_awd_disb.offered_amt;

                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'ln_db_act_gross_amt:'||ln_db_act_gross_amt);
                 END IF;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'for last disb insert remaining amount!ln_db_act_gross_amt:'||ln_db_act_gross_amt);
               END IF;
               -- Incase of Direct Loans round off amounts
               IF igf_sl_gen.chk_dl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE'  THEN
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'igf_sl_gen.chk_dl_fed_fund_code('||l_fmast.fed_fund_code||')=TRUE');
                  END IF;
                  -- sjadhav Bug 2411031
                  -- Changed sequence of calling igf_sl_award.get_loan_amts and igf_sl_roundoff_digits_pkg.gross_fees_roundoff.
                  -- This is done becuase first round off disbursement gross amount should be calculated first and then net amount / fee amount etc

                  -- we are passing dummys here for Net and Fee amount as they will be calculated later on

                  igf_sl_roundoff_digits_pkg.gross_fees_roundoff(p_last_disb_num      => ln_total_disb_num,
                                                                 p_offered_amt        => l_awd_tot.offered_amt,
                                                                 p_fee_perct          => l_fee1,
                                                                 p_disb_gross_amt     => ln_db_act_gross_amt,
                                                                 p_disb_net_amt       => ln_dummy_net_amt,
                                                                 p_fee                => ln_dummy_fee_1
                                                                );

                   -- This routine will return Net Amount/ Fee Amounts / Interest Rebate Amount
                   igf_sl_award.get_loan_amts(
                                              l_fmast.ci_cal_type,
                                              l_fmast.ci_sequence_number,
                                              l_fmast.fed_fund_code,
                                              NVL(ln_db_act_gross_amt,0),
                                              l_rebate,
                                              l_fee_amt1,
                                              l_net
                                             );

                   l_awd_disb.temp_num_val1 := NVL(l_net,0);

                   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after calling igf_sl_award.get_loan_amts,l_awd_disb.temp_num_val1:'||l_awd_disb.temp_num_val1);
                   END IF;

               -- masehgal    rounding off for CL
               ELSIF igf_sl_gen.chk_cl_fed_fund_code(l_fmast.fed_fund_code) = 'TRUE'  THEN
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'igf_sl_gen.chk_cl_fed_fund_code('||l_fmast.fed_fund_code||')=TRUE');
                  END IF;
                  -- we are passing dummys here for Net and Fee amount as they will be calculated later on
                  igf_sl_roundoff_digits_pkg.cl_gross_fees_roundoff(
                                                                    p_last_disb_num      => ln_total_disb_num,
                                                                    p_offered_amt        => l_awd_tot.offered_amt,
                                                                    p_disb_gross_amt     => ln_db_act_gross_amt );

                  l_awd_disb.temp_num_val1  := NVL(ln_db_act_gross_amt, 0) -
                                               NVL( l_fee_amt1, 0 )        -
                                               NVL( l_fee_amt2, 0 );

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after calling igf_sl_roundoff_digits_pkg.cl_gross_fees_roundoff,l_awd_disb.temp_num_val1:'||l_awd_disb.temp_num_val1);
                  END IF;

                  l_rebate := NULL;

               ELSE
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'igf_sl_gen.chk_dl_fed_fund_code('||l_fmast.fed_fund_code||')=FALSE');
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'igf_sl_gen.chk_cl_fed_fund_code('||l_fmast.fed_fund_code||')=FALSE');
                  END IF;
                  -- For funds other than the loans, calculate the Total Net amount
                  l_awd_disb.temp_num_val1  := NVL(ln_db_act_gross_amt, 0);
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_awd_disb.temp_num_val1 = NVL(ln_db_act_gross_amt, 0) = '||l_awd_disb.temp_num_val1);
                  END IF;

                  l_rebate    := NULL;
                  l_fee_amt1  := NULL;
                  l_fee_amt2  := NULL;
               END IF;

               ln_db_run_gross_amt  :=  ln_db_run_gross_amt + ln_db_act_gross_amt;
               IF l_award_status = 'ACCEPTED' THEN
                 ln_db_act_accpt_amt  :=  ln_db_act_gross_amt;
               ELSE
                 ln_db_act_accpt_amt  :=  0;
               END IF;
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after checking awd_initial_status, ln_db_act_accpt_amt:'||ln_db_act_accpt_amt);
               END IF;

               -- Setting lb_disb_update to update disbursement date accordingly
               IF l_disb_date1 IS NOT NULL AND l_disb_num = 1 THEN
                 -- No NSLDS history. Apply NSLDS date offset to delay disbursement date
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Setting lb_disb_update to TRUE');
                 END IF;

                 lb_disb_update := TRUE;
               ELSIF l_disb_num = 1 THEN
                 -- NSLDS history exists (or) NSLDS history does not exist, but the NSLDS date offset is not set (i.e. l_disb_date1 is null) (or) it is a non DL/CL fund
                 -- In both cases, we must NOT delay disbursement date
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Setting lb_disb_update to FALSE');
                 END IF;

                 lb_disb_update := FALSE;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'Before inserting into igf_aw_awd_disb table with l_attendance_type_code : '||l_attendance_type_code);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'inserting into igf_aw_awd_disb table with manual_hold_ind:'||l_hld_flg);
               END IF;

               lv_rowid   := NULL;
               IF l_fmast.fed_fund_code IN ('FWS')  THEN
                 l_attendance_type_code      := NULL;
                 l_base_attendance_type_code := NULL;
               END IF;

               IF l_fmast.entitlement = 'Y' THEN
                 --make l_hld_flg to 'N'
                 --this is necessary as there has to be no holds on an entitlement
                 l_hld_flg := 'N';
               END IF;

               OPEN c_disb(l_award_det.award_id,l_disb_num);
               FETCH c_disb INTO l_disb;
               IF c_disb%FOUND THEN
                 --disbursement exists
                 --so update
                 CLOSE c_disb;
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'calling igf_aw_awd_disb_pkg.update_row');
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb.award_id:'||l_disb.award_id);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb.disb_num:'||l_disb.disb_num);
                 END IF;

                 IF l_disb.trans_type = 'C' THEN
                  l_disb.trans_type := 'P';
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'...changing trans_type of disb:'||l_disb.disb_num||'to P...');
                  END IF;
                 END IF;

                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb.trans_type:'||l_disb.trans_type);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb.tp_cal_type:'||l_disb.tp_cal_type);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb.tp_sequence_number:'||l_disb.tp_sequence_number);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_base_attendance_type_code:'||l_base_attendance_type_code);
                 END IF;

                 IF     (l_fmast.fed_fund_code = 'PELL' AND
                        igf_sl_dl_validation.check_full_participant (l_fmast.ci_cal_type,l_fmast.ci_sequence_number,'PELL'))
                     OR (l_fmast.fed_fund_code IN ('DLP','DLS','DLU') AND
                        igf_sl_dl_validation.check_full_participant (l_fmast.ci_cal_type,l_fmast.ci_sequence_number,'DL'))
                     THEN
                   l_hold_rel_ind := NVL(l_disb.hold_rel_ind,'FALSE');
                 END IF;

                 igf_aw_awd_disb_pkg.update_row(
                                                x_mode                       => 'R',
                                                x_rowid                      => l_disb.row_id,
                                                x_award_id                   => l_disb.award_id,
                                                x_disb_num                   => l_disb.disb_num,
                                                x_tp_cal_type                => l_awd_disb.tp_cal_type,
                                                x_tp_sequence_number         => l_awd_disb.tp_sequence_number,
                                                x_disb_gross_amt             => ln_db_act_gross_amt ,
                                                x_fee_1                      => NVL(l_fee_amt1, 0),
                                                x_fee_2                      => NVL(l_fee_amt2, 0),
                                                x_disb_net_amt               => NVL(l_awd_disb.temp_num_val1,0),
                                                x_disb_date                  => l_disb_date,
                                                x_trans_type                 => l_disb.trans_type,
                                                x_elig_status                => l_disb.elig_status,
                                                x_elig_status_date           => l_disb.elig_status_date,
                                                x_affirm_flag                => l_disb.affirm_flag,
                                                x_hold_rel_ind               => l_hold_rel_ind,
                                                x_manual_hold_ind            => l_hld_flg,
                                                x_disb_status                => l_disb.disb_status,
                                                x_disb_status_date           => l_disb.disb_status_date,
                                                x_late_disb_ind              => l_auto_late_ind,
                                                x_fund_dist_mthd             => l_disb.fund_dist_mthd,
                                                x_prev_reported_ind          => l_disb.prev_reported_ind ,
                                                x_fund_release_date          => l_disb.fund_release_date,
                                                x_fund_status                => l_disb.fund_status,
                                                x_fund_status_date           => l_disb.fund_status_date,
                                                x_fee_paid_1                 => NVL(l_fee_paid1, 0),
                                                x_fee_paid_2                 => NVL(l_fee_paid2, 0),
                                                x_cheque_number              => l_disb.cheque_number,
                                                x_ld_cal_type                => l_awd_disb.ld_cal_type,
                                                x_ld_sequence_number         => l_awd_disb.ld_sequence_number,
                                                x_disb_accepted_amt          => ln_db_act_accpt_amt,
                                                x_disb_paid_amt              => l_disb.disb_paid_amt,
                                                x_rvsn_id                    => l_disb.rvsn_id,
                                                x_int_rebate_amt             => NVL(l_rebate, 0),
                                                x_force_disb                 => l_disb.force_disb,
                                                x_min_credit_pts             => l_credits,
                                                x_disb_exp_dt                => l_exp_dt,
                                                x_verf_enfr_dt               => l_verf_dt,
                                                x_fee_class                  => l_disb.fee_class,
                                                x_show_on_bill               => l_fmast.show_on_bill,
                                                x_attendance_type_code       => l_disb.attendance_type_code,
                                                x_base_attendance_type_code  => l_base_attendance_type_code,
                                                x_payment_prd_st_date        => l_disb.payment_prd_st_date,
                                                x_change_type_code           => l_disb.change_type_code,
                                                x_fund_return_mthd_code      => l_disb.fund_return_mthd_code,
                                                x_direct_to_borr_flag        => l_disb.direct_to_borr_flag
                                               );
                 IF g_phasein_participant AND l_fmast.fed_fund_code = 'PELL' THEN
                   /*
                     Update the Pell Disbursement Origination Record, if it exists
                   */
                   OPEN c_pell_disb_orig(l_disb.award_id,l_disb.disb_num);
                   FETCH c_pell_disb_orig INTO l_pell_disb_orig;
                   IF c_pell_disb_orig%NOTFOUND THEN
                     -- do nothing
                     CLOSE c_pell_disb_orig;
                   ELSE
                     -- update the record
                     CLOSE c_pell_disb_orig;
                     l_pell_disb_orig.disb_dt := l_disb_date;
                     l_pell_disb_orig.disb_amt := ln_db_act_gross_amt;
                     IF l_pell_disb_orig.disb_amt >= 0 THEN
                       l_pell_disb_orig.db_cr_flag       := 'P' ;
                     ELSE
                       l_pell_disb_orig.db_cr_flag       := 'N' ;
                     END IF;
                     l_pell_disb_orig.disb_ack_act_status     := 'R' ;
                     l_pell_disb_orig.disb_status_dt          := TRUNC(SYSDATE);
                     l_pell_disb_orig.disb_accpt_amt          := NULL ;
                     l_pell_disb_orig.accpt_db_cr_flag        := NULL ;
                     l_pell_disb_orig.disb_ytd_amt            := NULL ;
                     l_pell_disb_orig.pymt_prd_start_dt       := NULL ;
                     l_pell_disb_orig.accpt_pymt_prd_start_dt := NULL ;
                     l_pell_disb_orig.edit_code               := NULL ;
                     l_pell_disb_orig.rfmb_id                 := NULL ;

                     igf_gr_rfms_disb_pkg.update_row(
                                                     x_rowid                   => l_pell_disb_orig.row_id,
                                                     x_rfmd_id                 => l_pell_disb_orig.rfmd_id,
                                                     x_origination_id          => l_pell_disb_orig.origination_id,
                                                     x_disb_ref_num            => l_pell_disb_orig.disb_ref_num,
                                                     x_disb_dt                 => l_pell_disb_orig.disb_dt,
                                                     x_disb_amt                => l_pell_disb_orig.disb_amt,
                                                     x_db_cr_flag              => l_pell_disb_orig.db_cr_flag,
                                                     x_disb_ack_act_status     => l_pell_disb_orig.disb_ack_act_status,
                                                     x_disb_status_dt          => l_pell_disb_orig.disb_status_dt,
                                                     x_accpt_disb_dt           => l_pell_disb_orig.accpt_disb_dt,
                                                     x_disb_accpt_amt          => l_pell_disb_orig.disb_accpt_amt,
                                                     x_accpt_db_cr_flag        => l_pell_disb_orig.accpt_db_cr_flag,
                                                     x_disb_ytd_amt            => l_pell_disb_orig.disb_ytd_amt,
                                                     x_pymt_prd_start_dt       => l_pell_disb_orig.pymt_prd_start_dt,
                                                     x_accpt_pymt_prd_start_dt => l_pell_disb_orig.accpt_pymt_prd_start_dt,
                                                     x_edit_code               => l_pell_disb_orig.edit_code,
                                                     x_rfmb_id                 => l_pell_disb_orig.rfmb_id,
                                                     x_mode                    => 'R',
                                                     x_ed_use_flags            => l_pell_disb_orig.ed_use_flags
                                                    );
                   END IF;
                 END IF;
               ELSE
                 --disbursement non-existent
                 --so insert
                 CLOSE c_disb;
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'calling igf_aw_awd_disb_pkg.insert_row');
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb.award_id:'||l_award_det.award_id);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_disb_num:'||l_disb_num);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'l_base_attendance_type_code:'||l_base_attendance_type_code);
                 END IF;
                 IF     (l_fmast.fed_fund_code = 'PELL' AND
                        igf_sl_dl_validation.check_full_participant (l_fmast.ci_cal_type,l_fmast.ci_sequence_number,'PELL'))
                     OR (l_fmast.fed_fund_code IN ('DLP','DLS','DLU') AND
                        igf_sl_dl_validation.check_full_participant (l_fmast.ci_cal_type,l_fmast.ci_sequence_number,'DL'))
                     THEN
                   l_hold_rel_ind := 'FALSE';
                 END IF;
                 igf_aw_awd_disb_pkg.insert_row(
                                                x_rowid                  => lv_rowid,
                                                x_award_id               => l_award_det.award_id,
                                                x_disb_num               => l_disb_num,
                                                x_tp_cal_type            => l_awd_disb.tp_cal_type,
                                                x_tp_sequence_number     => l_awd_disb.tp_sequence_number,
                                                x_disb_gross_amt         => ln_db_act_gross_amt ,
                                                x_fee_1                  => NVL(l_fee_amt1, 0),
                                                x_fee_2                  => NVL(l_fee_amt2, 0),
                                                x_disb_net_amt           => NVL(l_awd_disb.temp_num_val1,0),
                                                x_disb_date              => l_disb_date,
                                                x_trans_type             => 'P',
                                                x_elig_status            => 'N',
                                                x_elig_status_date       => TRUNC(SYSDATE),
                                                x_affirm_flag            => 'N',
                                                x_hold_rel_ind           => l_hold_rel_ind,
                                                x_manual_hold_ind        => l_hld_flg,
                                                x_disb_status            => NULL,
                                                x_disb_status_date       => NULL,
                                                x_late_disb_ind          => l_auto_late_ind, -- FA 122 Added l_auto_late_ind
                                                x_fund_dist_mthd         => 'E',
                                                x_prev_reported_ind      => 'N',
                                                x_fund_release_date      => NULL,
                                                x_fund_status            => NULL,
                                                x_fund_status_date       => NULL,
                                                x_fee_paid_1             => NVL(l_fee_paid1, 0),
                                                x_fee_paid_2             => NVL(l_fee_paid2, 0),
                                                x_cheque_number          => NULL,
                                                x_ld_cal_type            => l_awd_disb.ld_cal_type,
                                                x_ld_sequence_number     => l_awd_disb.ld_sequence_number,
                                                x_disb_accepted_amt      => ln_db_act_accpt_amt,
                                                x_disb_paid_amt          => l_awd_disb.paid_amt,
                                                x_rvsn_id                => NULL,
                                                x_int_rebate_amt         => NVL(l_rebate, 0),
                                                x_force_disb             => NULL,
                                                x_min_credit_pts         => l_credits,
                                                x_disb_exp_dt            => l_exp_dt,
                                                x_verf_enfr_dt           => l_verf_dt,
                                                x_fee_class              => NULL,
                                                x_show_on_bill           => l_fmast.show_on_bill,
                                                x_attendance_type_code   => l_attendance_type_code,
                                                x_mode                   => 'R',
                                                x_base_attendance_type_code   => l_base_attendance_type_code,
                                                x_payment_prd_st_date    => NULL,
                                                x_change_type_code       => NULL,
                                                x_fund_return_mthd_code  => NULL,
                                                x_direct_to_borr_flag    => 'N'
                                               );
                 IF g_phasein_participant AND l_fmast.fed_fund_code = 'PELL' THEN
                   l_orig_id := NULL;

                   OPEN c_orig_id(l_award_det.award_id);
                   FETCH c_orig_id INTO l_orig_id;
                   CLOSE c_orig_id;

                   IF l_orig_id IS NOT NULL THEN
                     /* this PELL award has been already originated.
                        so insert a disbursement origination record for this new disbursement
                        we do this only for phase-in participant years - for full participant years,
                        there will no IGF_GR_RFMS_DISB record. While sending the origination, the data
                        is directly picked from the IGF_AW_AWD_DISB_ALL table.
                     */
                     lv_row_id  := NULL;
                     lv_rfmd_id := NULL;

                     igf_gr_rfms_disb_pkg.insert_row(
                                                     x_mode                    => 'R',
                                                     x_rowid                   => lv_row_id,
                                                     x_rfmd_id                 => lv_rfmd_id,
                                                     x_origination_id          => l_orig_id,
                                                     x_disb_ref_num            => l_disb_num,
                                                     x_disb_dt                 => l_disb_date,
                                                     x_disb_amt                => ln_db_act_gross_amt,
                                                     x_db_cr_flag              => 'P',
                                                     x_disb_ack_act_status     => 'R',
                                                     x_disb_status_dt          => TRUNC(SYSDATE) ,
                                                     x_accpt_disb_dt           => NULL,
                                                     x_disb_accpt_amt          => NULL,
                                                     x_accpt_db_cr_flag        => NULL,
                                                     x_disb_ytd_amt            => NULL,
                                                     x_pymt_prd_start_dt       => NULL,
                                                     x_accpt_pymt_prd_start_dt => NULL,
                                                     x_edit_code               => NULL,
                                                     x_rfmb_id                 => NULL,
                                                     x_ed_use_flags            => NULL
                                                    );
                   END IF;
                 END IF;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after inserting into disb table....l_hld_flg: '||l_hld_flg);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after inserting into disb table....l_attendance_type_code: '||l_attendance_type_code);
               END IF;
               -- If Over Award Hold is present at the award, then create 'SYSTEM' Hold for each disbursement of the Award
               IF l_hld_flg = 'Y' THEN

                 l_hold_id := NULL;
                 lv_rowid  := NULL;


                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'inserting into igf_db_disb_holds table');
                 END IF;
                 igf_db_disb_holds_pkg.insert_row(
                                               x_rowid              =>  lv_rowid,
                                               x_hold_id            =>  l_hold_id,
                                               x_award_id           =>  l_award_det.award_id,
                                               x_disb_num           =>  l_disb_num,
                                               x_hold               =>  'OVERAWARD',
                                               x_hold_date          =>  TRUNC(SYSDATE),
                                               x_hold_type          =>  'SYSTEM',
                                               x_release_date       =>  NULL,
                                               x_release_flag       =>  'N',
                                               x_release_reason     =>  NULL,
                                               x_mode               =>  'R'
                                              );
               END IF;
             END LOOP;--end loop for c_awd_disb
             IF c_awd_disb%ISOPEN THEN
               CLOSE c_awd_disb;
             END IF;
             --after this,if more disbursements exist, delete those
             FOR disb_cancel_rec IN c_disb_cancel(l_award_det.award_id,l_disb_num) LOOP

                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'cancelling awd_disb for award_id:'||l_award_det.award_id||' disb_num:'||disb_cancel_rec.disb_num);
                 END IF;

                 -- cancel the disbursement
                 igf_aw_awd_disb_pkg.update_row(
                                                x_rowid                     => disb_cancel_rec.row_id,
                                                x_award_id                  => disb_cancel_rec.award_id,
                                                x_disb_num                  => disb_cancel_rec.disb_num,
                                                x_tp_cal_type               => disb_cancel_rec.tp_cal_type,
                                                x_tp_sequence_number        => disb_cancel_rec.tp_sequence_number,
                                                x_disb_gross_amt            => 0,
                                                x_fee_1                     => 0,
                                                x_fee_2                     => 0,
                                                x_disb_net_amt              => 0,
                                                x_disb_date                 => disb_cancel_rec.disb_date,
                                                x_trans_type                => 'C',
                                                x_elig_status               => disb_cancel_rec.elig_status,
                                                x_elig_status_date          => disb_cancel_rec.elig_status_date,
                                                x_affirm_flag               => disb_cancel_rec.affirm_flag,
                                                x_hold_rel_ind              => disb_cancel_rec.hold_rel_ind,
                                                x_manual_hold_ind           => disb_cancel_rec.manual_hold_ind,
                                                x_disb_status               => disb_cancel_rec.disb_status,
                                                x_disb_status_date          => disb_cancel_rec.disb_status_date,
                                                x_late_disb_ind             => disb_cancel_rec.late_disb_ind,
                                                x_fund_dist_mthd            => disb_cancel_rec.fund_dist_mthd,
                                                x_prev_reported_ind         => disb_cancel_rec.prev_reported_ind,
                                                x_fund_release_date         => disb_cancel_rec.fund_release_date,
                                                x_fund_status               => disb_cancel_rec.fund_status,
                                                x_fund_status_date          => disb_cancel_rec.fund_status_date,
                                                x_fee_paid_1                => disb_cancel_rec.fee_paid_1,
                                                x_fee_paid_2                => disb_cancel_rec.fee_paid_2,
                                                x_cheque_number             => disb_cancel_rec.cheque_number,
                                                x_ld_cal_type               => disb_cancel_rec.ld_cal_type,
                                                x_ld_sequence_number        => disb_cancel_rec.ld_sequence_number,
                                                x_disb_accepted_amt         => 0,
                                                x_disb_paid_amt             => disb_cancel_rec.disb_paid_amt,
                                                x_rvsn_id                   => disb_cancel_rec.rvsn_id,
                                                x_int_rebate_amt            => 0,
                                                x_force_disb                => disb_cancel_rec.force_disb,
                                                x_min_credit_pts            => disb_cancel_rec.min_credit_pts,
                                                x_disb_exp_dt               => disb_cancel_rec.disb_exp_dt,
                                                x_verf_enfr_dt              => disb_cancel_rec.verf_enfr_dt,
                                                x_fee_class                 => disb_cancel_rec.fee_class,
                                                x_show_on_bill              => disb_cancel_rec.show_on_bill,
                                                x_mode                      => 'R',
                                                x_attendance_type_code      => disb_cancel_rec.attendance_type_code,
                                                x_base_attendance_type_code => disb_cancel_rec.base_attendance_type_code,
                                                x_payment_prd_st_date       => disb_cancel_rec.payment_prd_st_date,
                                                x_change_type_code          => disb_cancel_rec.change_type_code,
                                                x_fund_return_mthd_code     => disb_cancel_rec.fund_return_mthd_code,
                                                x_direct_to_borr_flag       => disb_cancel_rec.direct_to_borr_flag
                                               );
             END LOOP;

             IF lb_disb_update THEN

               OPEN c_disb(l_award_det.award_id,1);
               FETCH c_disb INTO l_disb;
               CLOSE c_disb;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','Flag set - updating disb num 1 with disb date delayed by NSLDS offset: ' ||l_disb_date1);
               END IF;

               igf_aw_awd_disb_pkg.update_row(
                                              x_mode                       => 'R',
                                              x_rowid                      => l_disb.row_id,
                                              x_award_id                   => l_disb.award_id,
                                              x_disb_num                   => l_disb.disb_num,
                                              x_tp_cal_type                => l_disb.tp_cal_type,
                                              x_tp_sequence_number         => l_disb.tp_sequence_number,
                                              x_disb_gross_amt             => l_disb.disb_gross_amt,
                                              x_fee_1                      => l_disb.fee_1,
                                              x_fee_2                      => l_disb.fee_2,
                                              x_disb_net_amt               => l_disb.disb_net_amt,
                                              x_disb_date                  => l_disb_date1,
                                              x_trans_type                 => l_disb.trans_type,
                                              x_elig_status                => l_disb.elig_status,
                                              x_elig_status_date           => l_disb.elig_status_date,
                                              x_affirm_flag                => l_disb.affirm_flag,
                                              x_hold_rel_ind               => l_disb.hold_rel_ind,
                                              x_manual_hold_ind            => l_disb.manual_hold_ind,
                                              x_disb_status                => l_disb.disb_status,
                                              x_disb_status_date           => l_disb.disb_status_date,
                                              x_late_disb_ind              => l_disb.late_disb_ind,
                                              x_fund_dist_mthd             => l_disb.fund_dist_mthd,
                                              x_prev_reported_ind          => l_disb.prev_reported_ind ,
                                              x_fund_release_date          => l_disb.fund_release_date,
                                              x_fund_status                => l_disb.fund_status,
                                              x_fund_status_date           => l_disb.fund_status_date,
                                              x_fee_paid_1                 => l_disb.fee_paid_1,
                                              x_fee_paid_2                 => l_disb.fee_paid_2,
                                              x_cheque_number              => l_disb.cheque_number,
                                              x_ld_cal_type                => l_disb.ld_cal_type,
                                              x_ld_sequence_number         => l_disb.ld_sequence_number,
                                              x_disb_accepted_amt          => l_disb.disb_accepted_amt,
                                              x_disb_paid_amt              => l_disb.disb_paid_amt,
                                              x_rvsn_id                    => l_disb.rvsn_id,
                                              x_int_rebate_amt             => l_disb.int_rebate_amt,
                                              x_force_disb                 => l_disb.force_disb,
                                              x_min_credit_pts             => l_disb.min_credit_pts,
                                              x_disb_exp_dt                => l_disb.disb_exp_dt,
                                              x_verf_enfr_dt               => l_disb.verf_enfr_dt,
                                              x_fee_class                  => l_disb.fee_class,
                                              x_show_on_bill               => l_disb.show_on_bill,
                                              x_attendance_type_code       => l_disb.attendance_type_code,
                                              x_base_attendance_type_code  => l_disb.base_attendance_type_code,
                                              x_payment_prd_st_date        => l_disb.payment_prd_st_date,
                                              x_change_type_code           => l_disb.change_type_code,
                                              x_fund_return_mthd_code      => l_disb.fund_return_mthd_code,
                                              x_direct_to_borr_flag        => l_disb.direct_to_borr_flag
                                             );
             END IF;

          END IF;

      EXCEPTION
      WHEN SKIP_RECORD THEN
        NULL;

      END;
    END LOOP;


    CLOSE c_awd_tot; -- Completed Creation of Awards and Disbursements with the content from the Temporary Table

    --check if there were any cancelled awards.
    --post those awards too
    cancel_awards(l_process_id,l_base_id);

    -- If Awards are Created then Update the Packaging Status and also the Award Amounts at the student level
    IF lb_awards_created = TRUE THEN

       -- Update Student FA Base record with the Total Offered Amount, Accepted Amount and the Packaging status
       -- Update Notification status if the process is run in Single Fund or Autio Packaged.
       IF g_sf_packaging = 'T' THEN
          igf_aw_gen.update_fabase_awds( l_base_id, 'SINGLE' );
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'called igf_aw_gen.update_fabase_awds with SINGLE');
          END IF;
          lv_update_notif_stat := 'T';
       ELSIF ( l_post = 'Y' ) THEN
          igf_aw_gen.update_fabase_awds( l_base_id, 'SIMULATED' );
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'called igf_aw_gen.update_fabase_awds with SIMULATED');
          END IF;
          lv_update_notif_stat := 'F';
       ELSE
          igf_aw_gen.update_fabase_awds( l_base_id, 'AUTO_PACKAGED' );
          lv_update_notif_stat := 'T';
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'called igf_aw_gen.update_fabase_awds with AUTO_PACKAGED');
          END IF;
       END IF;  -- Notification End

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after update_fabase_awds , lv_update_notif_stat:'||lv_update_notif_stat);
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'after update_fabase_awds , l_upd_awd_notif_status:'||l_upd_awd_notif_status);
       END IF;
       --Added as part of FACR008-Correspondence Build,pmarada
       --updateing the fa base record with the notification status
       IF l_upd_awd_notif_status = 'Y' AND lv_update_notif_stat = 'T' THEN
          OPEN  c_fabase(l_base_id );
          FETCH c_fabase INTO l_fabase;
          IF c_fabase%FOUND THEN
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'updating fa base table');
             END IF;
             igf_ap_fa_base_rec_pkg.update_row(
                                          x_rowid                        => l_fabase.row_id,
                                          x_base_id                      => l_fabase.base_id,
                                          x_ci_cal_type                  => l_fabase.ci_cal_type,
                                          x_person_id                    => l_fabase.person_id,
                                          x_ci_sequence_number           => l_fabase.ci_sequence_number,
                                          x_org_id                       => l_fabase.org_id,
                                          x_coa_pending                  => l_fabase.coa_pending,
                                          x_verification_process_run     => l_fabase.verification_process_run,
                                          x_inst_verif_status_date       => l_fabase.inst_verif_status_date,
                                          x_manual_verif_flag            => l_fabase.manual_verif_flag,
                                          x_fed_verif_status             => l_fabase.fed_verif_status,
                                          x_fed_verif_status_date        => l_fabase.fed_verif_status_date,
                                          x_inst_verif_status            => l_fabase.inst_verif_status,
                                          x_nslds_eligible               => l_fabase.nslds_eligible,
                                          x_ede_correction_batch_id      => l_fabase.ede_correction_batch_id,
                                          x_fa_process_status_date       => l_fabase.fa_process_status_date,
                                          x_isir_corr_status             => l_fabase.isir_corr_status,
                                          x_isir_corr_status_date        => l_fabase.isir_corr_status_date,
                                          x_isir_status                  => l_fabase.isir_status,
                                          x_isir_status_date             => l_fabase.isir_status_date,
                                          x_coa_code_f                   => l_fabase.coa_code_f,
                                          x_coa_code_i                   => l_fabase.coa_code_i,
                                          x_coa_f                        => l_fabase.coa_f,
                                          x_coa_i                        => l_fabase.coa_i,
                                          x_disbursement_hold            => l_fabase.disbursement_hold,
                                          x_fa_process_status            => l_fabase.fa_process_status,
                                          x_packaging_status             => l_fabase.packaging_status,
                                          x_packaging_status_date        => l_fabase.packaging_status_date,
                                          x_total_package_accepted       => l_fabase.total_package_accepted,
                                          x_total_package_offered        => l_fabase.total_package_offered,
                                          x_admstruct_id                 => l_fabase.admstruct_id,
                                          x_admsegment_1                 => l_fabase.admsegment_1,
                                          x_admsegment_2                 => l_fabase.admsegment_2,
                                          x_admsegment_3                 => l_fabase.admsegment_3,
                                          x_admsegment_4                 => l_fabase.admsegment_4,
                                          x_admsegment_5                 => l_fabase.admsegment_5,
                                          x_admsegment_6                 => l_fabase.admsegment_6,
                                          x_admsegment_7                 => l_fabase.admsegment_7,
                                          x_admsegment_8                 => l_fabase.admsegment_8,
                                          x_admsegment_9                 => l_fabase.admsegment_9,
                                          x_admsegment_10                => l_fabase.admsegment_10,
                                          x_admsegment_11                => l_fabase.admsegment_11,
                                          x_admsegment_12                => l_fabase.admsegment_12,
                                          x_admsegment_13                => l_fabase.admsegment_13,
                                          x_admsegment_14                => l_fabase.admsegment_14,
                                          x_admsegment_15                => l_fabase.admsegment_15,
                                          x_admsegment_16                => l_fabase.admsegment_16,
                                          x_admsegment_17                => l_fabase.admsegment_17,
                                          x_admsegment_18                => l_fabase.admsegment_18,
                                          x_admsegment_19                => l_fabase.admsegment_19,
                                          x_admsegment_20                => l_fabase.admsegment_20,
                                          x_packstruct_id                => l_fabase.packstruct_id,
                                          x_packsegment_1                => l_fabase.packsegment_1,
                                          x_packsegment_2                => l_fabase.packsegment_2,
                                          x_packsegment_3                => l_fabase.packsegment_3,
                                          x_packsegment_4                => l_fabase.packsegment_4,
                                          x_packsegment_5                => l_fabase.packsegment_5,
                                          x_packsegment_6                => l_fabase.packsegment_6,
                                          x_packsegment_7                => l_fabase.packsegment_7,
                                          x_packsegment_8                => l_fabase.packsegment_8,
                                          x_packsegment_9                => l_fabase.packsegment_9,
                                          x_packsegment_10               => l_fabase.packsegment_10,
                                          x_packsegment_11               => l_fabase.packsegment_11,
                                          x_packsegment_12               => l_fabase.packsegment_12,
                                          x_packsegment_13               => l_fabase.packsegment_13,
                                          x_packsegment_14               => l_fabase.packsegment_14,
                                          x_packsegment_15               => l_fabase.packsegment_15,
                                          x_packsegment_16               => l_fabase.packsegment_16,
                                          x_packsegment_17               => l_fabase.packsegment_17,
                                          x_packsegment_18               => l_fabase.packsegment_18,
                                          x_packsegment_19               => l_fabase.packsegment_19,
                                          x_packsegment_20               => l_fabase.packsegment_20,
                                          x_miscstruct_id                => l_fabase.miscstruct_id,
                                          x_miscsegment_1                => l_fabase.miscsegment_1,
                                          x_miscsegment_2                => l_fabase.miscsegment_2,
                                          x_miscsegment_3                => l_fabase.miscsegment_3,
                                          x_miscsegment_4                => l_fabase.miscsegment_4,
                                          x_miscsegment_5                => l_fabase.miscsegment_5,
                                          x_miscsegment_6                => l_fabase.miscsegment_6,
                                          x_miscsegment_7                => l_fabase.miscsegment_7,
                                          x_miscsegment_8                => l_fabase.miscsegment_8,
                                          x_miscsegment_9                => l_fabase.miscsegment_9,
                                          x_miscsegment_10               => l_fabase.miscsegment_10,
                                          x_miscsegment_11               => l_fabase.miscsegment_11,
                                          x_miscsegment_12               => l_fabase.miscsegment_12,
                                          x_miscsegment_13               => l_fabase.miscsegment_13,
                                          x_miscsegment_14               => l_fabase.miscsegment_14,
                                          x_miscsegment_15               => l_fabase.miscsegment_15,
                                          x_miscsegment_16               => l_fabase.miscsegment_16,
                                          x_miscsegment_17               => l_fabase.miscsegment_17,
                                          x_miscsegment_18               => l_fabase.miscsegment_18,
                                          x_miscsegment_19               => l_fabase.miscsegment_19,
                                          x_miscsegment_20               => l_fabase.miscsegment_20,
                                          x_prof_judgement_flg           => l_fabase.prof_judgement_flg,
                                          x_nslds_data_override_flg      => l_fabase.nslds_data_override_flg,
                                          x_target_group                 => l_fabase.target_group,
                                          x_coa_fixed                    => l_fabase.coa_fixed,
                                          x_coa_pell                     => l_fabase.coa_pell,
                                          x_mode                         => 'R',
                                          x_profile_status               => l_fabase.profile_status,
                                          x_profile_status_date          => l_fabase.profile_status_date,
                                          x_profile_fc                   => l_fabase.profile_fc,
                                          x_tolerance_amount             => l_fabase.tolerance_amount,
                                          x_manual_disb_hold             => l_fabase.manual_disb_hold,
                                          x_pell_alt_expense             => l_fabase.pell_alt_expense,
                                          x_assoc_org_num                => l_fabase.assoc_org_num,
                                          x_award_fmly_contribution_type => l_fabase.award_fmly_contribution_type,
                                          x_isir_locked_by               => l_fabase.isir_locked_by,
                                          x_lock_awd_flag                => l_fabase.lock_awd_flag,
                                          x_lock_coa_flag                => l_fabase.lock_coa_flag,
                                          x_adnl_unsub_loan_elig_flag    => l_fabase.adnl_unsub_loan_elig_flag,
                                          x_notification_status          => NULL,
                                          x_notification_status_date     => NULL
                                          );
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.post_award.debug '|| g_req_id,'updated FA Base');
             END IF;
           END IF;
           CLOSE c_fabase;
      END IF; -- End of l-post check

      --check for COA Lock profile i.e. 'IGF: Lock COA Budget for Student'
      IF get_coa_lock_prof_val = 'AWARDED' THEN
        IF NOT igf_aw_coa_gen.isCOALocked(l_base_id) THEN
          lv_locking_success := igf_aw_coa_gen.doLock(l_base_id);
        END IF;
      END IF;

      /*
        bug 4601747 - award process status should get set to AWARDED when the student is packaged or repackaged.
        Since some awards may be skipped during repackaged, we have to call the set_awd_proc_status wrapper to get
        all the awards to AWARDED status-This is because AWARDED status has a higher priority over AWARDED status
        and so, the award process status for the awarding period would still remain in READY
      */
      setAPProcStat(l_base_id,g_awd_prd,'AWARDED');
    END IF; -- Awards Created Check.

  EXCEPTION
    WHEN INV_FWS_AWARD THEN
      IF (c_awd_tot%ISOPEN) THEN
       CLOSE c_awd_tot;
      END IF;
      IF (c_fmast%ISOPEN) THEN
        CLOSE c_fmast;
      END IF;
      IF (c_person_number%ISOPEN) THEN
        CLOSE c_person_number;
      END IF;
      IF (c_awd_disb_cnt%ISOPEN) THEN
        CLOSE c_awd_disb_cnt;
      END IF;
      IF (c_awd_disb%ISOPEN) THEN
        CLOSE c_awd_disb;
      END IF;
      IF (c_nslds%ISOPEN) THEN
        CLOSE c_nslds;
      END IF;
      IF (c_fabase%ISOPEN) THEN
        CLOSE c_fabase;
      END IF;
      IF c_disb%ISOPEN THEN
        CLOSE c_disb;
      END IF;
      IF c_award_det%ISOPEN THEN
        CLOSE c_award_det;
      END IF;
      RAISE;
  WHEN OTHERS THEN

      fnd_message.parse_encoded(fnd_message.get_encoded,l_app,l_name);
      IF l_name = 'IGF_AW_FUND_LOCK_ERR' THEN
        l_ret_status := 'L';

        IF (c_awd_tot%ISOPEN) THEN
                CLOSE c_awd_tot;
         END IF;

         IF (c_fmast%ISOPEN) THEN
                CLOSE c_fmast;
         END IF;

         IF (c_person_number%ISOPEN) THEN
              CLOSE c_person_number;
          END IF;

         IF (c_awd_disb_cnt%ISOPEN) THEN
                      CLOSE c_awd_disb_cnt;
                END IF;
         IF (c_awd_disb%ISOPEN) THEN
                      CLOSE c_awd_disb;
                END IF;

         IF (c_nslds%ISOPEN) THEN
                      CLOSE c_nslds;
                END IF;

         IF (c_fabase%ISOPEN) THEN
                      CLOSE c_fabase;
          END IF;



      RETURN;
      ELSE
       l_ret_status := 'E';
       IF c_awd_tot%ISOPEN THEN
                      CLOSE c_awd_tot;
                END IF;

         IF c_fmast%ISOPEN THEN
                      CLOSE c_fmast;
                END IF;

         IF c_person_number%ISOPEN THEN
                      CLOSE c_person_number;
                END IF;
         IF c_awd_disb_cnt%ISOPEN THEN
                      CLOSE c_awd_disb_cnt;
                END IF;
         IF c_awd_disb%ISOPEN THEN
                      CLOSE c_awd_disb;
                END IF;

         IF c_nslds%ISOPEN THEN
                      CLOSE c_nslds;
                END IF;

         IF c_fabase%ISOPEN THEN
                      CLOSE c_fabase;
                END IF;
       END IF;

        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AW_PACKAGING.POST_AWARD' ||SQLERRM);
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.post_award.exception '|| g_req_id,'sql error message: '||SQLERRM);
        END IF;
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;

  END post_award;

  FUNCTION actualDisbExist(
                           p_award_id igf_aw_award_all.award_id%TYPE
                          ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 13-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_adisb IS
    SELECT 'x'
      FROM igf_aw_awd_disb_all
     WHERE award_id = p_award_id
       AND trans_type = 'A'
       AND ROWNUM = 1;
  l_adisb c_adisb%ROWTYPE;

  BEGIN
    OPEN c_adisb;
    FETCH c_adisb INTO l_adisb;
    IF c_adisb%FOUND THEN
      CLOSE c_adisb;
      RETURN TRUE;
    ELSE
      CLOSE c_adisb;
      RETURN FALSE;
    END IF;
  END actualDisbExist;

  FUNCTION awardsExist(
                       p_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                       p_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                       p_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                       p_fund_id            igf_aw_fund_mast_all.fund_id%TYPE,
                       p_awd_prd_code       igf_aw_awd_prd_term.award_prd_cd%TYPE
                      ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 13-Oct-2004
  --
  --Purpose: Returns true if atleast one award exists for the base_id/fund_id combination
  -- which lies partly or entirely within the award period passed and the award is not already
  -- loaded into the temporary table
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_awd IS
    SELECT 'x'
      FROM igf_aw_award_all awd,
           igf_aw_awd_disb_all disb,
           igf_aw_awd_prd_term aprd
     WHERE awd.fund_id = p_fund_id
       AND awd.base_id = p_base_id
       AND awd.award_status IN ('ACCEPTED','OFFERED','CANCELLED')
       AND awd.award_id = disb.award_id
       AND disb.ld_cal_type = aprd.ld_cal_type
       AND disb.ld_sequence_number = aprd.ld_sequence_number
       AND aprd.award_prd_cd = p_awd_prd_code
       AND aprd.ci_cal_type = p_ci_cal_type
       AND aprd.ci_sequence_number = p_ci_sequence_number
       AND ROWNUM = 1;
  l_awd c_awd%ROWTYPE;

  CURSOR c_awd_pell IS
    SELECT 'x'
      FROM igf_aw_award_all
     WHERE fund_id = p_fund_id
       AND base_id = p_base_id
       AND award_status IN ('ACCEPTED','OFFERED','CANCELLED')
       AND ROWNUM = 1;
  l_awd_pell c_awd_pell%ROWTYPE;

  BEGIN
    IF get_fed_fund_code(p_fund_id) <> 'PELL' THEN
      OPEN c_awd;
      FETCH c_awd INTO l_awd;
      IF c_awd%FOUND THEN
        CLOSE c_awd;
        RETURN TRUE;
      ELSE
        CLOSE c_awd;
        RETURN FALSE;
      END IF;
    ELSE
      /*
        Award period does not apply for PELL
      */
      OPEN c_awd_pell;
      FETCH c_awd_pell INTO l_awd_pell;
      IF c_awd_pell%FOUND THEN
        CLOSE c_awd_pell;
        RETURN TRUE;
      ELSE
        CLOSE c_awd_pell;
        RETURN FALSE;
      END IF;
    END IF;
  END awardsExist;

  FUNCTION isOriginated(
                        p_fund_id  igf_aw_fund_mast_all.fund_id%TYPE,
                        p_award_id igf_aw_award_all.award_id%TYPE
                       ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 13-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get loan status
  CURSOR c_loan IS
    SELECT 'x'
      FROM igf_sl_loans
     WHERE award_id = p_award_id
       AND loan_status NOT IN ('G','N');--ready to send and not ready to send
  l_loan c_loan%ROWTYPE;

  -- Get pell status
  CURSOR c_pell IS
    SELECT 'x'
      FROM igf_gr_rfms_all
     WHERE award_id = p_award_id
       AND orig_action_code NOT IN ('R','N','A','D','C');--ready to send and not ready to send
  l_pell c_pell%ROWTYPE;
  BEGIN
    IF get_fed_fund_code(p_fund_id) = 'PELL' THEN
      OPEN c_pell;
      FETCH c_pell INTO l_pell;
      IF c_pell%FOUND THEN
        CLOSE c_pell;
        RETURN TRUE;
      ELSE
        CLOSE c_pell;
        RETURN FALSE;
      END IF;
    ELSE
      OPEN c_loan;
      FETCH c_loan INTO l_loan;
      IF c_loan%FOUND THEN
        CLOSE c_loan;
        RETURN TRUE;
      ELSE
        CLOSE c_loan;
        RETURN FALSE;
      END IF;
    END IF;
  END isOriginated;

  FUNCTION getFedVerifStatus(
                             p_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                            ) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 13-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_verif IS
    SELECT fed_verif_status
      FROM igf_ap_fa_base_rec_all
     WHERE base_id = p_base_id;
  l_verif_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE;
  BEGIN
    l_verif_status := NULL;
    OPEN c_verif;
    FETCH c_verif INTO l_verif_status;
    CLOSE c_verif;
    RETURN l_verif_status;
  END getFedVerifStatus;

  FUNCTION doesAwardSpanOutsideAP(
                                  p_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                                  p_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                                  p_award_id           igf_aw_award_all.award_id%TYPE,
                                  p_awd_prd_code       igf_aw_awd_prd_term.award_prd_cd%TYPE
                                 ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 13-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_terms IS
    SELECT 'x'
      FROM DUAL
     WHERE EXISTS(
              SELECT 'x'
                FROM igf_aw_awd_disb_all
               WHERE award_id = p_award_id
                 AND (ld_cal_type, ld_sequence_number) IN(
                        SELECT ld_cal_type,
                               ld_sequence_number
                          FROM igf_aw_awd_prd_term
                         WHERE ci_cal_type = p_ci_cal_type
                           AND ci_sequence_number = p_ci_sequence_number
                           AND award_prd_cd = p_awd_prd_code))
       AND EXISTS(
              SELECT 'x'
                FROM igf_aw_awd_disb_all
               WHERE award_id = p_award_id
                 AND (ld_cal_type, ld_sequence_number) NOT IN(
                        SELECT ld_cal_type,
                               ld_sequence_number
                          FROM igf_aw_awd_prd_term
                         WHERE ci_cal_type = p_ci_cal_type
                           AND ci_sequence_number = p_ci_sequence_number
                           AND award_prd_cd = p_awd_prd_code));
  l_terms c_terms%ROWTYPE;
  BEGIN
    OPEN c_terms;
    FETCH c_terms INTO l_terms;
    IF c_terms%FOUND THEN
      CLOSE c_terms;
      RETURN TRUE;
    ELSE
      CLOSE c_terms;
      RETURN FALSE;
    END IF;
  END doesAwardSpanOutsideAP;

  FUNCTION chk_gplus_loan_limits (
                                    p_base_id         IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                                    p_fed_fund_code   IN          igf_aw_fund_cat_all.fed_fund_code%TYPE,
                                    p_adplans_id      IN          igf_aw_awd_dist_plans.adplans_id%TYPE,
                                    p_aid             IN          NUMBER,
                                    p_std_loan_tab    IN          igf_aw_packng_subfns.std_loan_tab,
                                    p_msg_name        OUT NOCOPY  fnd_new_messages.message_name%TYPE
                                  )
  RETURN BOOLEAN
  IS
    /*
    ||  Created By : museshad
    ||  Created On : 25-JUL-2006
    ||  Purpose    : Build FA 163(Bug 5337551).
    ||               Graduate PLUS loans (GPLUSDL, GPLUSFL) can be awarded only if the student has already been
    ||               awarded his full Stafford Loan eligibility for the award year. Note that aggregate limit checks
    ||               are not applicable here.
    ||  Known limitations, enhancements or remarks  :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    lv_fed_fund_code     igf_aw_fund_cat_all.fed_fund_code%TYPE;
    lv_aid               NUMBER := 0;
    lv_msg_name          fnd_new_messages.message_name%TYPE := NULL;
    lv_ret_status        BOOLEAN := FALSE;
  BEGIN
    lv_aid := p_aid;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'Parameter list - START' ||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'p_base_id: ' ||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'p_fed_fund_code: ' ||p_fed_fund_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'p_adplans_id: ' ||p_adplans_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'Parameter list - END' ||p_base_id);
    END IF;

    -- Check if Stafford loan limit is exhausted for the corresponding Unsubsidized loan.
    IF p_fed_fund_code = 'GPLUSDL' THEN
      lv_fed_fund_code := 'DLU';
    ELSIF p_fed_fund_code = 'GPLUSFL' THEN
      lv_fed_fund_code := 'FLU';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'Calling check_loan_limits for ' ||lv_fed_fund_code);
    END IF;

    igf_aw_packng_subfns.check_loan_limits(
                                            l_base_id         =>  p_base_id,
                                            fund_type         =>  lv_fed_fund_code,
                                            l_award_id        =>  NULL,
                                            l_adplans_id      =>  p_adplans_id,
                                            l_aid             =>  lv_aid,
                                            l_std_loan_tab    =>  p_std_loan_tab,
                                            p_msg_name        =>  lv_msg_name,
                                            p_chk_aggr_limit  =>  'N'  -- do not do Aggr limit checks
                                          );
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'After Calling check_loan_limits: lv_aid= ' ||lv_aid|| 'p_msg_name= ' ||p_msg_name);
    END IF;

    IF lv_aid < 0 THEN
      -- Student has got loans (Subs+Unsubz) more than his Annual Stafford loan limit, so he is eligible for Graduate PLUS loan.
      lv_ret_status := TRUE;
      lv_msg_name := NULL;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'Stafford loan limit exhausted for ' ||lv_fed_fund_code);
      END IF;

    ELSIF lv_aid = 0 THEN
      IF lv_msg_name IS NOT NULL THEN
        -- Some err like- not able to derive Class Standing or Class Standing Mapping not defined etc.
        lv_ret_status := FALSE;
      ELSE
        -- Stafford loan limit exhausted. Student is eligible for Graduate PLUS loan
        lv_ret_status := TRUE;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'Stafford loan limit exhausted for ' ||lv_fed_fund_code);
        END IF;
      END IF;

    ELSIF lv_aid > 0 THEN
      -- Stafford loan limit NOT exhausted yet, not eligible for Graduate PLUS loan.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.debug '|| g_req_id,'Stafford loan limit NOT exhausted for ' ||lv_fed_fund_code|| '. Cannot award ' ||p_fed_fund_code);
      END IF;

      lv_msg_name := 'IGF_AW_LOAN_LMT_NOT_EXHST';
      lv_ret_status := FALSE;
    END IF;     -- <<lv_aid = 0>>

    p_msg_name := lv_msg_name;
    RETURN lv_ret_status;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.chk_gplus_loan_limits '||SQLERRM);
      igs_ge_msg_stack.add;

      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.chk_gplus_loan_limits.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;

      p_msg_name := NULL;
      RETURN FALSE;
  END chk_gplus_loan_limits;

  PROCEDURE merge_funds(
                        p_target_group       IN igf_ap_fa_base_rec_all.target_group%TYPE,
                        p_ci_cal_type        IN igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        p_ci_sequence_number IN igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                        p_base_id            IN igf_ap_fa_base_rec_all.base_id%TYPE
                      ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 19-Oct-2004
  --
  --Purpose:
  --   To merge awards of award group and non award group funds
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --museshad    17-Apr-2006     Awards were not getting repackaged in the order defined in
  --                            Repackage priority sequence setup. Fixed this by modifying
  --                            the ORDER BY in c_merge.
  -------------------------------------------------------------------

  -- Get funds which are not from the award group and are candidates for re-packaging
  CURSOR c_rep_funds(
                     cp_target_group       igf_ap_fa_base_rec_all.target_group%TYPE,
                     cp_ci_cal_type        igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                     cp_ci_sequence_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                     cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE
                    ) IS
    SELECT 'x'
      FROM igf_aw_award_t
     WHERE base_id = cp_base_id
       AND process_id = l_process_id
       AND flag = 'AU'
       AND fund_id NOT IN (SELECT fund_id
                             FROM igf_aw_awd_frml_det
                            WHERE formula_code = cp_target_group
                              AND ci_cal_type = cp_ci_cal_type
                              AND ci_sequence_number = cp_ci_sequence_number);
  l_rep_funds c_rep_funds%ROWTYPE;

  --check if there are non-mergable funds. If seq_no is null means the fund is not from the target group
  CURSOR c_non_merge(
                     cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                    ) IS
    SELECT awd.fund_id
      FROM igf_aw_award_t awd
     WHERE awd.temp_char_val1 IS NULL
       AND awd.flag IN ('CF','AU')
       AND awd.base_id = cp_base_id
       AND awd.process_id = l_process_id
       AND NOT EXISTS (SELECT 'x'
                         FROM igf_aw_fn_rpkg_prty
                        WHERE fund_id = awd.fund_id);
  l_non_merge c_non_merge%ROWTYPE;

  -- Get priorities for all funds
  CURSOR c_merge(
                 cp_ci_cal_type        igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                 cp_ci_sequence_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                 cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE
                ) IS
    SELECT ROWNUM priority,
           awd.*
      FROM igf_aw_fn_rpkg_prty prty,
           igf_aw_award_t awd
     WHERE awd.base_id = cp_base_id
       AND awd.process_id = l_process_id
       AND awd.flag IN ('CF','AU')
       AND awd.fund_id = prty.fund_id
       AND prty.ci_cal_type = cp_ci_cal_type
       AND prty.ci_sequence_number = cp_ci_sequence_number
     ORDER BY prty.fund_order_num, awd.award_id;

  -- Get fund_code
  CURSOR c_fund(
                cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE
               ) IS
    SELECT fund_code
      FROM igf_aw_fund_mast_all
     WHERE fund_id = cp_fund_id;
  l_fund_code igf_aw_fund_mast_all.fund_code%TYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'starting merge_funds');
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'p_target_group:'||p_target_group);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'p_ci_cal_type:'||p_ci_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'p_ci_sequence_number:'||p_ci_sequence_number);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'p_base_id:'||p_base_id);
    END IF;

    OPEN c_rep_funds(p_target_group,p_ci_cal_type,p_ci_sequence_number,p_base_id);
    FETCH c_rep_funds INTO l_rep_funds;
    IF c_rep_funds%NOTFOUND THEN
      --got nothing to merge.
      --quit merging
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'no funds to merge');
      END IF;
      CLOSE c_rep_funds;
      RETURN;
    END IF;
    CLOSE c_rep_funds;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'have funds to merge');
    END IF;

    OPEN c_non_merge(p_base_id);
    FETCH c_non_merge INTO l_non_merge;
    IF c_non_merge%FOUND THEN
      CLOSE c_non_merge;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'unable to merge.quitting...');
      END IF;
      fnd_message.set_name('IGF','IGF_AW_FUND_NO_MERGE');
      l_fund_code := NULL;
      OPEN c_fund(l_non_merge.fund_id);
      FETCH c_fund INTO l_fund_code;
      CLOSE c_fund;
      fnd_message.set_token('FUND_CODE',l_fund_code);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE NON_MERGABLE_FUNDS;
    END IF;

    --at this point, we know there are funds to be merged and all those can be merged.
    FOR l_merge IN c_merge(p_ci_cal_type,p_ci_sequence_number,p_base_id) LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.merge_funds.debug '|| g_req_id,'updating fund_id:'||l_merge.fund_id||
                                               ' base_id:'||l_merge.base_id||
                                               ' with priority:'||l_merge.priority||
                                               ' l_merge.temp_val3_num:'||l_merge.temp_val3_num||
                                               'l_merge.temp_val4_num:'||l_merge.temp_val4_num
                      );
      END IF;
      igf_aw_award_t_pkg.update_row(
                                    x_rowid                => l_merge.row_id,
                                    x_process_id           => l_merge.process_id,
                                    x_sl_number            => l_merge.sl_number,
                                    x_fund_id              => l_merge.fund_id,
                                    x_base_id              => l_merge.base_id,
                                    x_offered_amt          => l_merge.offered_amt,
                                    x_accepted_amt         => l_merge.accepted_amt,
                                    x_paid_amt             => l_merge.paid_amt,
                                    x_need_reduction_amt   => l_merge.need_reduction_amt,
                                    x_flag                 => l_merge.flag,
                                    x_temp_num_val1        => l_merge.temp_num_val1,
                                    x_temp_num_val2        => l_merge.temp_num_val2,
                                    x_temp_char_val1       => TO_CHAR(l_merge.priority),
                                    x_tp_cal_type          => l_merge.tp_cal_type,
                                    x_tp_sequence_number   => l_merge.tp_sequence_number,
                                    x_ld_cal_type          => l_merge.ld_cal_type,
                                    x_ld_sequence_number   => l_merge.ld_sequence_number,
                                    x_mode                 => 'R',
                                    x_adplans_id           => l_merge.adplans_id,
                                    x_app_trans_num_txt    => l_merge.app_trans_num_txt,
                                    x_award_id             => l_merge.award_id,
                                    x_lock_award_flag      => l_merge.lock_award_flag,
                                    x_temp_val3_num        => l_merge.temp_val3_num,
                                    x_temp_val4_num        => l_merge.temp_val4_num,
                                    x_temp_char2_txt       => l_merge.temp_char2_txt,
                                    x_temp_char3_txt       => l_merge.temp_char3_txt
                                   );
    END LOOP;

  END merge_funds;

  PROCEDURE load_awards(
                        p_ci_cal_type          igs_ca_inst.cal_type%TYPE,
                        p_ci_sequence_number   igs_ca_inst.sequence_number%TYPE,
                        p_award_prd_code       igf_aw_awd_prd_term.award_prd_cd%TYPE,
                        p_base_id              igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_fund_id              igf_aw_fund_mast_all.fund_id%TYPE,
                        p_lock_award_flag      igf_aw_fund_mast_all.lock_award_flag%TYPE,
                        p_re_pkg_verif_flag    igf_aw_fund_mast_all.re_pkg_verif_flag%TYPE,
                        p_donot_repkg_if_code  igf_aw_fund_mast_all.donot_repkg_if_code%TYPE,
                        p_adplans_id           igf_aw_awd_dist_plans.adplans_id%TYPE,
                        p_max_award_amt        igf_aw_fund_mast_all.max_award_amt%TYPE,
                        p_min_award_amt        igf_aw_fund_mast_all.min_award_amt%TYPE,
                        p_seq_no               NUMBER
                       ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 25-Oct-2004
  --
  --Purpose:
  --   Loads awards from a given fund, which lie partly
  --   or entirely within the passed award period,after imposing restrictions
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  lv_fed_fund_code igf_aw_fund_cat_all.fed_fund_code%TYPE;
  -- Get awards from a fund
  CURSOR c_awds(
                cp_ci_cal_type          igs_ca_inst.cal_type%TYPE,
                cp_ci_sequence_number   igs_ca_inst.sequence_number%TYPE,
                cp_award_prd_code       igf_aw_awd_prd_term.award_prd_cd%TYPE,
                cp_base_id              igf_ap_fa_base_rec_all.base_id%TYPE,
                cp_fund_id              igf_aw_fund_mast_all.fund_id%TYPE
               ) IS
    SELECT awd.award_id,
           awd.offered_amt,
           awd.paid_amt,
           awd.lock_award_flag,
           awd.adplans_id,
           fmast.auto_pkg,
           NVL(p_max_award_amt, fmast.max_award_amt) max_award_amt,
           NVL(p_min_award_amt, fmast.min_award_amt) min_award_amt,
           fmast.allow_overaward,
           fmast.over_award_amt,
           fmast.over_award_perct,
           fmast.available_amt,
           fmast.remaining_amt
      FROM igf_aw_award_all awd, igf_aw_fund_mast_all fmast
     WHERE awd.base_id = cp_base_id
       AND awd.fund_id = cp_fund_id
       AND awd.award_status IN('OFFERED', 'ACCEPTED', 'CANCELLED')
       AND fmast.fund_id = awd.fund_id
       AND lv_fed_fund_code <> 'PELL'
       AND awd.award_id IN(
              SELECT DISTINCT awd.award_id
                         FROM igf_aw_award_all awd,
                              igf_aw_awd_disb_all disb,
                              igf_aw_awd_prd_term aprd
                        WHERE awd.fund_id = cp_fund_id
                          AND awd.base_id = cp_base_id
                          AND awd.award_id = disb.award_id
                          AND disb.ld_cal_type = aprd.ld_cal_type
                          AND disb.ld_sequence_number = aprd.ld_sequence_number
                          AND aprd.award_prd_cd = cp_award_prd_code
                          AND aprd.ci_cal_type = cp_ci_cal_type
                          AND aprd.ci_sequence_number = cp_ci_sequence_number)
    UNION ALL
    SELECT awd.award_id,
           awd.offered_amt,
           awd.paid_amt,
           awd.lock_award_flag,
           awd.adplans_id,
           fmast.auto_pkg,
           NVL(p_max_award_amt, fmast.max_award_amt) max_award_amt,
           NVL(p_min_award_amt, fmast.min_award_amt) min_award_amt,
           fmast.allow_overaward,
           fmast.over_award_amt,
           fmast.over_award_perct,
           fmast.available_amt,
           fmast.remaining_amt
      FROM igf_aw_award_all awd, igf_aw_fund_mast_all fmast
     WHERE awd.base_id = cp_base_id
       AND awd.fund_id = cp_fund_id
       AND awd.award_status IN('OFFERED', 'ACCEPTED', 'CANCELLED')
       AND fmast.fund_id = awd.fund_id
       AND lv_fed_fund_code = 'PELL';

  -- Get loan status
  CURSOR c_loan_status(
                       cp_award_id igf_aw_award_all.award_id%TYPE
                      ) IS
    SELECT loan_status,
           loan_chg_status
      FROM igf_sl_loans
     WHERE award_id = cp_award_id;
  l_loan_status igf_sl_loans.loan_status%TYPE;
  l_loan_chg_status igf_sl_loans.loan_chg_status%TYPE;

  CURSOR c_pell_orig_stat(
                          cp_award_id igf_aw_award_all.award_id%TYPE
                         ) IS
    SELECT orig_action_code
      FROM igf_gr_rfms_all
     WHERE award_id = cp_award_id;
  l_pell_orig_stat igf_gr_rfms_all.orig_action_code%TYPE;

  lb_awards_locked BOOLEAN;

	-- Get pell disb orig status
 	CURSOR c_pell_disb_orig_stat(
 	                             cp_award_id igf_aw_award_all.award_id%TYPE
 	                            ) IS
 	  SELECT disb.disb_ack_act_status
 	    FROM igf_gr_rfms_disb_all disb,
 	         igf_gr_rfms_all rfms
 	   WHERE rfms.origination_id = disb.origination_id
 	     AND rfms.award_id = cp_award_id
 	     AND disb.disb_ack_act_status = 'S'
 	     AND ROWNUM = 1;
 	l_pell_disb_orig_stat igf_gr_rfms_disb_all.disb_ack_act_status%TYPE;

  lv_rowid     VARCHAR2(25);
  l_sl_number  NUMBER(15);

  -- Check for locked awards for the Student in the current fund
  CURSOR c_chk_locked_award(
                              cp_fund_id           igf_aw_fund_mast_all.fund_id%TYPE,
                              cp_base_id           igf_ap_fa_base_rec_all.base_id%TYPE
                           )
  IS
      SELECT 'x'
      FROM igf_aw_award_t_all
      WHERE
          process_id = l_process_id   AND
          fund_id = cp_fund_id        AND
          base_id = cp_base_id        AND
          flag = 'AL';
  l_chk_locked_award c_chk_locked_award%ROWTYPE;

  -- Returns all existing awards which are not locked
  CURSOR c_get_unlocked_award (
                                cp_fund_id           igf_aw_fund_mast_all.fund_id%TYPE,
                                cp_base_id           igf_ap_fa_base_rec_all.base_id%TYPE
                              )
  IS
      SELECT awd_t.rowid, awd_t.*
      FROM igf_aw_award_t_all awd_t
      WHERE
            awd_t.flag = 'AU'           AND
            process_id = l_process_id   AND
            fund_id = cp_fund_id        AND
            base_id = cp_base_id;


    -- Get the Over Award records from the temporary table.
    CURSOR c_ov_fund( x_fund_id igf_aw_fund_mast.fund_id%TYPE ) IS
    SELECT row_id
      FROM igf_aw_award_t awdt
     WHERE fund_id = x_fund_id
       AND flag = 'OV'
       AND process_id = l_process_id;

    l_ov_fund    c_ov_fund%ROWTYPE;
    l_overaward  NUMBER;

  CURSOR c_pell_cnt(
                    cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
                    cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                   ) IS
    SELECT SUM(DECODE(awd.award_status,'CANCELLED',1,0)) cancelled_awd,
           SUM(DECODE(awd.award_status,'OFFERED',1,'ACCEPTED',1,0)) off_acc_awd
      FROM igf_aw_award_t_all awdt,
           igf_aw_award_all awd
     WHERE awdt.fund_id = cp_fund_id
       AND awdt.base_id = cp_base_id
       AND awdt.process_id = l_process_id
       AND awdt.flag = 'AU'
       AND awdt.award_id = awd.award_id;
  l_pell_cnt  c_pell_cnt%ROWTYPE;

  CURSOR c_lock_pell_awd(
                         cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
                         cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
    SELECT awdt.ROWID row_id,
           awdt.*
      FROM igf_aw_award_t_all awdt,
           igf_aw_award_all awd
     WHERE awdt.award_id    = awd.award_id
       AND awdt.fund_id     = cp_fund_id
       AND awdt.base_id     = cp_base_id
       AND awdt.process_id  = l_process_id
       AND awd.award_status = 'CANCELLED';
  l_lock_pell_awd c_lock_pell_awd%ROWTYPE;

  CURSOR c_lock_pell_awd1(
                          cp_fund_id  igf_aw_fund_mast_all.fund_id%TYPE,
                          cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE,
                          cp_award_id igf_aw_award_all.award_id%TYPE
                         ) IS
    SELECT awdt.ROWID row_id,
           awdt.*
      FROM igf_aw_award_t_all awdt
     WHERE awdt.award_id <> cp_award_id
       AND awdt.base_id = cp_base_id
       AND awdt.fund_id = cp_fund_id
       AND awdt.process_id = l_process_id;

  CURSOR c_latest_awd(
                      cp_fund_id  igf_aw_fund_mast_all.fund_id%TYPE,
                      cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                     ) IS
    SELECT awd.award_id
      FROM igf_aw_award_t_all awdt,
           igf_aw_award_all awd
     WHERE awdt.award_id    = awd.award_id
       AND awdt.fund_id     = cp_fund_id
       AND awdt.base_id     = cp_base_id
       AND awdt.process_id  = l_process_id
       AND awd.award_status = 'CANCELLED'
       AND awdt.flag        = 'AU'
     ORDER BY awd.award_id DESC;
  l_latest_awd c_latest_awd%ROWTYPE;

  BEGIN
    lv_fed_fund_code := get_fed_fund_code(p_fund_id);
    FOR l_awds IN c_awds(p_ci_cal_type,p_ci_sequence_number,p_award_prd_code,p_base_id,p_fund_id) LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'****processing award_id:'||l_awds.award_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_base_id:'||p_base_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_fund_id:'||p_fund_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_lock_award_flag:'||p_lock_award_flag);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_re_pkg_verif_flag:'||p_re_pkg_verif_flag);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_donot_repkg_if_code:'||p_donot_repkg_if_code);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_adplans_id:'||p_adplans_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_max_award_amt:'||p_max_award_amt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_min_award_amt:'||p_min_award_amt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'p_seq_no:'||p_seq_no);
      END IF;

      /*
        First check to see if the current fund has a OV record. Else, put it into the temp table
      */
      OPEN c_ov_fund(p_fund_id);
      FETCH c_ov_fund INTO l_ov_fund;
      IF c_ov_fund%FOUND THEN
        CLOSE c_ov_fund;
        --nothing to do. the record exists
      ELSE
        CLOSE c_ov_fund;
        --got to insert the record

        l_overaward := 0;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'c_ov_fund%NOTFOUND!l_overaward:'||l_overaward);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'l_awds.allow_overaward:'||l_awds.allow_overaward);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'l_awds.over_award_amt:'||l_awds.over_award_amt);
        END IF;

        IF ( l_awds.allow_overaward = 'Y' ) THEN

          IF NVL(l_awds.over_award_amt,0) > 0 THEN
            l_overaward := l_awds.over_award_amt;

          ELSIF NVL(l_awds.over_award_perct,0) > 0 THEN
            l_overaward := ( l_awds.available_amt * l_awds.over_award_perct/100 );
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'set l_overaward to '||l_overaward);
          END IF;

        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'inserting into igf_aw_award_t with flag:OV for fund:'||p_fund_id||' and base_id:'||p_base_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'l_awds.remaining_amt:'||l_awds.remaining_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'l_overaward:'||l_overaward);
        END IF;
        igf_aw_award_t_pkg.insert_row(
                                      x_rowid              => lv_rowid ,
                                      x_process_id         => l_process_id ,
                                      x_sl_number          => l_sl_number,
                                      x_fund_id            => p_fund_id,
                                      x_base_id            => p_base_id,
                                      x_offered_amt        => 0 ,
                                      x_accepted_amt       => 0 ,
                                      x_paid_amt           => 0  ,
                                      x_need_reduction_amt => NULL,
                                      x_flag               => 'OV',
                                      x_temp_num_val1      => l_awds.remaining_amt,
                                      x_temp_num_val2      => l_overaward,
                                      x_temp_char_val1     => NULL,
                                      x_tp_cal_type        => NULL,
                                      x_tp_sequence_number => NULL,
                                      x_ld_cal_type        => NULL,
                                      x_ld_sequence_number => NULL,
                                      x_mode               => 'R',
                                      x_adplans_id         => NULL,
                                      x_app_trans_num_txt  => NULL,
                                      x_lock_award_flag    => NULL,
                                      x_temp_val3_num      => NULL,
                                      x_temp_val4_num      => NULL,
                                      x_temp_char2_txt     => NULL,
                                      x_temp_char3_txt     => NULL
                                     );
      END IF;

      lb_awards_locked := FALSE;

      --Fund should be auto-packagable
      IF NVL(l_awds.auto_pkg,'N') = 'N' THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'fund cannot be auto-packaged');
        END IF;
        lb_awards_locked := TRUE;
      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'passed auto-package validation');
        END IF;
      END IF;
      --1.award should exist within the current awarding period
      IF lv_fed_fund_code <> 'PELL' AND doesAwardSpanOutsideAP(p_ci_cal_type,p_ci_sequence_number,l_awds.award_id,g_awd_prd) THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'award spans outside AP');
        END IF;
        lb_awards_locked := TRUE;
      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'award lies within AP');
        END IF;
      END IF;

      --2.award's lock status
      IF NVL(l_awds.lock_award_flag,'N') = 'Y' THEN
        lb_awards_locked := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'award locked');
        END IF;
      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'award not locked');
        END IF;
      END IF;

      --3. check on donot_rpkg_if_code
      IF p_donot_repkg_if_code = 'ACTUAL_DISB_EXISTS' THEN
        IF actualDisbExist(l_awds.award_id) THEN
          --skip this award from repackaging
          --this would contribute only to need
          lb_awards_locked := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'fails actual_disb_exist');
          END IF;
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'no actual disb');
          END IF;
        END IF;
      ELSIF p_donot_repkg_if_code = 'ORIGINATED' THEN
        --means this can be a loan or PELL
        IF isOriginated(p_fund_id,l_awds.award_id) THEN
          lb_awards_locked := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'fails originated chk');
          END IF;
          /*
            If fund is PELL,print a message
          */
          IF lv_fed_fund_code = 'PELL' THEN
            fnd_message.set_name('IGF','IGF_GR_ORIG_SENT_NO_RECALC');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          END IF;
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'not originated');
          END IF;
        END IF;
      ELSIF p_donot_repkg_if_code = 'ORIG_OR_ACTUAL' THEN
        IF isOriginated(p_fund_id,l_awds.award_id) OR actualDisbExist(l_awds.award_id) THEN
          lb_awards_locked := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'fails orig_or_actual chk');
          END IF;
          /*
            IF fund is PELL,print a message
          */
          IF lv_fed_fund_code = 'PELL' AND isOriginated(p_fund_id,l_awds.award_id) THEN
            fnd_message.set_name('IGF','IGF_GR_ORIG_SENT_NO_RECALC');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          END IF;
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'passed orig_or_actual chk');
          END IF;
        END IF;
      END IF;

      --4.Verification status
      IF NVL(p_re_pkg_verif_flag,'N') = 'N' AND getFedVerifStatus(p_base_id)= 'ACCURATE' THEN
        lb_awards_locked := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'fails verification status');
        END IF;
      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'passed verification status chk');
        END IF;
      END IF;

      --5. FFELP loans whose loan status is ACCEPTED must be skipped.
      IF lv_fed_fund_code IN ('FLS','FLU','FLP','GPLUSFL') THEN
        OPEN c_loan_status(l_awds.award_id);
        FETCH c_loan_status INTO l_loan_status,l_loan_chg_status;
        IF c_loan_status%FOUND AND l_loan_status IN ('A','S') THEN
          CLOSE c_loan_status;
          lb_awards_locked := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'fails FFELP with accepted origination chk. Cannot repackage.');
          END IF;
        ELSE
          CLOSE c_loan_status;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'passed FFELP with accepted origination chk');
          END IF;
        END IF;
      END IF;

      --6.sponsorhsips will only be resources. they cannot be repackaged
      IF lv_fed_fund_code = 'SPNSR' THEN
        lb_awards_locked := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'fails sponsot chk');
        END IF;
      END IF;

      --7.PELL or LOANS,if in transit,cannot be repackaged
      IF lv_fed_fund_code = 'PELL' THEN
        l_pell_orig_stat := NULL;
        OPEN c_pell_orig_stat(l_awds.award_id);
        FETCH c_pell_orig_stat INTO l_pell_orig_stat;
        CLOSE c_pell_orig_stat;
        IF l_pell_orig_stat IS NOT NULL AND l_pell_orig_stat = 'S' THEN
          lb_awards_locked := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'PELL in sent status.cannot repackage');
          END IF;
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'PELL passed SENT status chk');
          END IF;
        END IF;
      ELSIF get_sys_fund_type(p_fund_id) = 'LOAN' THEN
        l_loan_status     := NULL;
        l_loan_chg_status := NULL;
        OPEN c_loan_status(l_awds.award_id);
        FETCH c_loan_status INTO l_loan_status,l_loan_chg_status;
        CLOSE c_loan_status;
        IF l_loan_status IS NOT NULL AND (l_loan_status IN ('S', 'C', 'R', 'T') OR (l_loan_status = 'A' AND NVL(l_loan_chg_status,'G') IN ('S','R'))) THEN
          lb_awards_locked := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'LOAN in sent/cancelled/terminated/rejected status.cannot repackage');
          END IF;
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'LOAN passed sent/cancelled/terminated/rejected status chk');
          END IF;
        END IF;
      END IF;

	    --8.PELL Grant cannot be repackage, when disbursement record is sent (only for phase-in participant)
 	    IF g_phasein_participant AND lv_fed_fund_code = 'PELL' THEN
 	      l_pell_disb_orig_stat := NULL;
 	      OPEN c_pell_disb_orig_stat(l_awds.award_id);
 	      FETCH c_pell_disb_orig_stat INTO l_pell_disb_orig_stat;
 	      CLOSE c_pell_disb_orig_stat;
 	      IF l_pell_disb_orig_stat IS NOT NULL AND l_pell_disb_orig_stat = 'S' THEN
 	       lb_awards_locked := TRUE;
 	       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
 	         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'PELL Disb in sent status.cannot repackage');
 	       END IF;
 	      ELSE
 	       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
 	         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'PELL passed DISB SENT chk');
          END IF;
        END IF;
      END IF;

      lv_rowid    := NULL;
      l_sl_number := NULL;
      IF lb_awards_locked THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'created locked award');
        END IF;
        igf_aw_award_t_pkg.insert_row(
                                      x_rowid              => lv_rowid ,
                                      x_process_id         => l_process_id ,
                                      x_sl_number          => l_sl_number,
                                      x_fund_id            => p_fund_id,
                                      x_base_id            => p_base_id,
                                      x_offered_amt        => igf_aw_coa_gen.award_amount(p_base_id,g_awd_prd,l_awds.award_id),
                                      x_accepted_amt       => 0,
                                      x_paid_amt           => 0,
                                      x_need_reduction_amt => NULL,
                                      x_flag               => 'AL',
                                      x_temp_num_val1      => NULL,
                                      x_temp_num_val2      => NULL,
                                      x_temp_char_val1     => NULL,
                                      x_tp_cal_type        => NULL,
                                      x_tp_sequence_number => NULL,
                                      x_ld_cal_type        => NULL,
                                      x_ld_sequence_number => NULL,
                                      x_mode               => 'R',
                                      x_adplans_id         => l_awds.adplans_id,
                                      x_app_trans_num_txt  => NULL,
                                      x_award_id           => l_awds.award_id,
                                      x_lock_award_flag    => p_lock_award_flag,
                                      x_temp_val3_num      => NULL,
                                      x_temp_val4_num      => NULL,
                                      x_temp_char2_txt     => NULL,
                                      x_temp_char3_txt     => NULL
                                     );
      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'created unlocked award');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'l_awds.max_award_amt:'||l_awds.max_award_amt||',l_awds.min_award_amt:'||l_awds.min_award_amt);
        END IF;

        igf_aw_award_t_pkg.insert_row(
                                      x_rowid              => lv_rowid ,
                                      x_process_id         => l_process_id ,
                                      x_sl_number          => l_sl_number,
                                      x_fund_id            => p_fund_id,
                                      x_base_id            => p_base_id,
                                      x_offered_amt        => igf_aw_coa_gen.award_amount(p_base_id,g_awd_prd,l_awds.award_id),
                                      x_accepted_amt       => 0,
                                      x_paid_amt           => 0,
                                      x_need_reduction_amt => NULL,
                                      x_flag               => 'AU',
                                      x_temp_num_val1      => NULL,
                                      x_temp_num_val2      => NULL,
                                      x_temp_char_val1     => p_seq_no,
                                      x_tp_cal_type        => NULL,
                                      x_tp_sequence_number => NULL,
                                      x_ld_cal_type        => NULL,
                                      x_ld_sequence_number => NULL,
                                      x_mode               => 'R',
                                      x_adplans_id         => NVL(p_adplans_id,g_plan_id),
                                      x_app_trans_num_txt  => NULL,
                                      x_award_id           => l_awds.award_id,
                                      x_lock_award_flag    => p_lock_award_flag,
                                      x_temp_val3_num      => l_awds.max_award_amt,
                                      x_temp_val4_num      => l_awds.min_award_amt,
                                      x_temp_char2_txt     => NULL,
                                      x_temp_char3_txt     => NULL
                                     );
      END IF;
    END LOOP;

    -- Check if there are any existing awards in locked ('AL') status
    OPEN c_chk_locked_award(p_fund_id, p_base_id);
    FETCH c_chk_locked_award INTO l_chk_locked_award;
    IF (c_chk_locked_award%FOUND) THEN
        -- There are existing locked award(s)
        -- Mark all existing awards as locked. Re-packaging cannot happen
        -- for the fund when there are any existing locked awards from that
        -- fund
        FOR l_exist_awd IN c_get_unlocked_award(p_fund_id, p_base_id)
        LOOP
          igf_aw_award_t_pkg.update_row(
                                        x_rowid                 =>    l_exist_awd.rowid,
                                        x_process_id            =>    l_exist_awd.process_id,
                                        x_sl_number             =>    l_exist_awd.sl_number,
                                        x_fund_id               =>    l_exist_awd.fund_id,
                                        x_base_id               =>    l_exist_awd.base_id,
                                        x_offered_amt           =>    l_exist_awd.offered_amt,
                                        x_accepted_amt          =>    l_exist_awd.accepted_amt,
                                        x_paid_amt              =>    l_exist_awd.paid_amt,
                                        x_need_reduction_amt    =>    l_exist_awd.need_reduction_amt,
                                        x_flag                  =>    'AL',
                                        x_temp_num_val1         =>    l_exist_awd.temp_num_val1,
                                        x_temp_num_val2         =>    l_exist_awd.temp_num_val2,
                                        x_temp_char_val1        =>    l_exist_awd.temp_char_val1,
                                        x_tp_cal_type           =>    l_exist_awd.tp_cal_type,
                                        x_tp_sequence_number    =>    l_exist_awd.tp_sequence_number,
                                        x_ld_cal_type           =>    l_exist_awd.ld_cal_type,
                                        x_ld_sequence_number    =>    l_exist_awd.ld_sequence_number,
                                        x_mode                  =>    'R',
                                        x_adplans_id            =>    l_exist_awd.adplans_id,
                                        x_app_trans_num_txt     =>    l_exist_awd.app_trans_num_txt,
                                        x_award_id              =>    l_exist_awd.award_id,
                                        x_lock_award_flag       =>    l_exist_awd.lock_award_flag,
                                        x_temp_val3_num         =>    l_exist_awd.temp_val3_num,
                                        x_temp_val4_num         =>    l_exist_awd.temp_val4_num,
                                        x_temp_char2_txt        =>    l_exist_awd.temp_char2_txt,
                                        x_temp_char3_txt        =>    l_exist_awd.temp_char3_txt
                                       );
        END LOOP;

        -- Log message that all existing awards have been locked
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,
                        'Base Id: ' ||p_base_id|| ', Fund Id: ' ||p_fund_id|| '. Found an existing award that is locked. So locked all other existing awards.');
        END IF;
    END IF;

    IF lv_fed_fund_code = 'PELL' THEN
      l_pell_cnt := NULL;
      OPEN c_pell_cnt(p_fund_id,p_base_id);
      FETCH c_pell_cnt INTO l_pell_cnt;
      CLOSE c_pell_cnt;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'l_pell_cnt.cancelled_awd:'||l_pell_cnt.cancelled_awd);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'l_pell_cnt.off_acc_awd:'||l_pell_cnt.off_acc_awd);
      END IF;

      IF l_pell_cnt.cancelled_awd > 0  AND l_pell_cnt.off_acc_awd = 1 THEN
        --logic comes in here if the student has 1 offered/accepted PELL award and multiple cancelled PELL awards
        --oh dear....we are into problems
        --update all cancelled awards to locked
        FOR l_lock_pell_awd IN c_lock_pell_awd(p_fund_id,p_base_id) LOOP
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'locked award_id:'||l_lock_pell_awd.award_id);
          END IF;
          igf_aw_award_t_pkg.update_row(
                                        x_rowid              => l_lock_pell_awd.row_id,
                                        x_process_id         => l_lock_pell_awd.process_id,
                                        x_sl_number          => l_lock_pell_awd.sl_number,
                                        x_fund_id            => l_lock_pell_awd.fund_id,
                                        x_base_id            => l_lock_pell_awd.base_id,
                                        x_offered_amt        => l_lock_pell_awd.offered_amt,
                                        x_accepted_amt       => l_lock_pell_awd.accepted_amt,
                                        x_paid_amt           => l_lock_pell_awd.paid_amt,
                                        x_need_reduction_amt => l_lock_pell_awd.need_reduction_amt,
                                        x_flag               => 'AL',
                                        x_temp_num_val1      => l_lock_pell_awd.temp_num_val1,
                                        x_temp_num_val2      => l_lock_pell_awd.temp_num_val2,
                                        x_temp_char_val1     => l_lock_pell_awd.temp_char_val1,
                                        x_tp_cal_type        => l_lock_pell_awd.tp_cal_type,
                                        x_tp_sequence_number => l_lock_pell_awd.tp_sequence_number,
                                        x_ld_cal_type        => l_lock_pell_awd.ld_cal_type,
                                        x_ld_sequence_number => l_lock_pell_awd.ld_sequence_number,
                                        x_mode               => 'R',
                                        x_adplans_id         => l_lock_pell_awd.adplans_id,
                                        x_app_trans_num_txt  => l_lock_pell_awd.app_trans_num_txt,
                                        x_award_id           => l_lock_pell_awd.award_id,
                                        x_lock_award_flag    => l_lock_pell_awd.lock_award_flag,
                                        x_temp_val3_num      => l_lock_pell_awd.temp_val3_num,
                                        x_temp_val4_num      => l_lock_pell_awd.temp_val4_num,
                                        x_temp_char2_txt     => l_lock_pell_awd.temp_char2_txt,
                                        x_temp_char3_txt     => l_lock_pell_awd.temp_char3_txt
                                       );
        END LOOP;
      ELSIF l_pell_cnt.off_acc_awd = 0 AND l_pell_cnt.cancelled_awd > 0 THEN
        --logic comes in here if the student has 0 offered/accepted PELL award and multiple cancelled PELL awards
        --oh dear....more problems
        --there are PELL awards but all of them are cancelled
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'all PELL awards are CANCELLED');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'update the latest PELL to re-packagable');
        END IF;
        OPEN c_latest_awd(p_fund_id,p_base_id);
        FETCH c_latest_awd INTO l_latest_awd;
        CLOSE c_latest_awd;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'l_latest_awd.award_id:'||l_latest_awd.award_id);
        END IF;

        FOR l_lock_pell_awd IN c_lock_pell_awd1(p_fund_id,p_base_id,l_latest_awd.award_id) LOOP
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_awards.debug '|| g_req_id,'locked award_id:'||l_lock_pell_awd.award_id);
          END IF;
          igf_aw_award_t_pkg.update_row(
                                        x_rowid              => l_lock_pell_awd.row_id,
                                        x_process_id         => l_lock_pell_awd.process_id,
                                        x_sl_number          => l_lock_pell_awd.sl_number,
                                        x_fund_id            => l_lock_pell_awd.fund_id,
                                        x_base_id            => l_lock_pell_awd.base_id,
                                        x_offered_amt        => l_lock_pell_awd.offered_amt,
                                        x_accepted_amt       => l_lock_pell_awd.accepted_amt,
                                        x_paid_amt           => l_lock_pell_awd.paid_amt,
                                        x_need_reduction_amt => l_lock_pell_awd.need_reduction_amt,
                                        x_flag               => 'AL',
                                        x_temp_num_val1      => l_lock_pell_awd.temp_num_val1,
                                        x_temp_num_val2      => l_lock_pell_awd.temp_num_val2,
                                        x_temp_char_val1     => l_lock_pell_awd.temp_char_val1,
                                        x_tp_cal_type        => l_lock_pell_awd.tp_cal_type,
                                        x_tp_sequence_number => l_lock_pell_awd.tp_sequence_number,
                                        x_ld_cal_type        => l_lock_pell_awd.ld_cal_type,
                                        x_ld_sequence_number => l_lock_pell_awd.ld_sequence_number,
                                        x_mode               => 'R',
                                        x_adplans_id         => l_lock_pell_awd.adplans_id,
                                        x_app_trans_num_txt  => l_lock_pell_awd.app_trans_num_txt,
                                        x_award_id           => l_lock_pell_awd.award_id,
                                        x_lock_award_flag    => l_lock_pell_awd.lock_award_flag,
                                        x_temp_val3_num      => l_lock_pell_awd.temp_val3_num,
                                        x_temp_val4_num      => l_lock_pell_awd.temp_val4_num,
                                        x_temp_char2_txt     => l_lock_pell_awd.temp_char2_txt,
                                        x_temp_char3_txt     => l_lock_pell_awd.temp_char3_txt
                                       );
        END LOOP;
      END IF;
    END IF;
  END load_awards;

  PROCEDURE load_funds(
                       l_target_group       IN igf_ap_fa_base_rec_all.target_group%TYPE,
                       l_ci_cal_type        IN igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                       l_ci_sequence_number IN igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                       l_base_id            IN igf_ap_fa_base_rec_all.base_id%TYPE,
                       l_person_id          IN igf_ap_fa_base_rec_all.person_id%TYPE
                      ) IS
    /*
    ||  Created By : cdcruz
    ||  Created On : 14-NOV-2000
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    ||  ridas         08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
    ||  museshad      01-Jun-2005     Build# FA157 - Bug# 4382371.
    ||                                1)  Validate Program eligibility.
    ||                                    Check if the fund can sponsor the student's
    ||                                    program or not.
    ||                                2)  Determine fund eligibility during Repackaging.
    ||                                    When an award from a fund is given to a student
    ||                                    during Packaging, but for some reason the student later
    ||                                    loses his eligibility for the fund. These awards need to
    ||                                    cancelled, when the student is repackaged the next time.
    ||                                    Implemented this functionality
    || veramach       30-Jun-2004     bug 3709109 - Added call to function check_disb to enforce the rule that FWS funds can
    ||                                have only one disbursement per term
    ||  bkkumar         05-Apr-04       FACR116 Added the check that if the fund is of type 'ALT' then
    ||                                  check if the relationship code assosiated with it has a set up in the
    ||                                  context award year.
    ||  veramach        08-Dec-2003     FA 131 COD Updates
    ||                                  Added validations so that funds with no matching terms of the distribution plan and COA
    ||                                  for the student are not loaded
    ||  veramach        20-NOV-2003     FA 125 multiple distr methods
    ||                                  1.changed cursor c_fund_ld to fetch adplans_id,
    ||                                    max_num_disb,min_num_disb
    ||                                  2.Added validations to reject a fund if the distribution will result in
    ||                                    disbursements whose number is not within the max/min levels set in fund manager
    */

    -- Retrieves all the funds that are part of the Formula Code in Sequence and loads the temporary table
    -- If this procedure being called from Single Fund, then retrive the details of fund directly.
    -- If not called from Single fund, then load all the funds which are linked to the given group code
    CURSOR c_fund_ld(
                     x_group_code         igf_aw_awd_frml_det_all.formula_code%TYPE,
                     x_ci_cal_type        igf_aw_awd_frml_det_all.ci_cal_type%TYPE,
                     x_ci_sequence_number igf_aw_awd_frml_det_all.ci_sequence_number%TYPE
                    ) IS
    SELECT fmdet.fund_id fund_id,
           fmast.fund_code,
           fmdet.seq_no seq_no,
           fmdet.max_award_amt max_award_amt,
           fmdet.min_award_amt min_award_amt,
           fmdet.replace_fc replace_fc,
           fmast.allow_overaward allow_overaward,
           fmast.over_award_amt over_award_amt,
           fmast.over_award_perct over_award_perct,
           fmast.available_amt available_amt,
           fmast.remaining_amt remaining_amt,
           fmast.max_num_disb max_num_disb,
           fmast.min_num_disb min_num_disb,
           fmast.donot_repkg_if_code donot_repkg_if_code,
           fmdet.pe_group_id pe_group_id,
           fmdet.adplans_id adplans_id,
           fmast.re_pkg_verif_flag re_pkg_verif_flag,
           NVL(fmdet.lock_award_flag,fmast.lock_award_flag) lock_award_flag
      FROM igf_aw_awd_frml_det fmdet,
           igf_aw_fund_mast_all fmast
     WHERE fmdet.formula_code = x_group_code
       AND fmdet.ci_cal_type = x_ci_cal_type
       AND fmdet.ci_sequence_number = x_ci_sequence_number
       AND fmdet.fund_id = fmast.fund_id
       AND fmast.discontinue_fund <> 'Y'
       AND g_sf_packaging =  'F'
     UNION
    SELECT fmast.fund_id fund_id,
           fmast.fund_code,
           1 seq_no,
           fmast.max_award_amt max_award_amt,
           fmast.min_award_amt min_award_amt,
           fmast.replace_fc replace_fc,
           fmast.allow_overaward allow_overaward,
           fmast.over_award_amt over_award_amt,
           fmast.over_award_perct over_award_perct,
           fmast.available_amt available_amt,
           fmast.remaining_amt remaining_amt,
           fmast.max_num_disb max_num_disb,
           fmast.min_num_disb min_num_disb,
           fmast.donot_repkg_if_code donot_repkg_if_code,
           0 pe_group_id,
           g_plan_id adplans_id,
           fmast.re_pkg_verif_flag re_pkg_verif_flag,
           NVL(g_lock_award,fmast.lock_award_flag) lock_award_flag
      FROM igf_aw_fund_mast_all fmast
     WHERE fmast.discontinue_fund  <> 'Y'
       AND g_sf_packaging = 'T'
       AND fund_id = g_sf_fund
     ORDER BY 3;

    l_fund_ld c_fund_ld%ROWTYPE;

    -- Get the Over Award records from the temporary table.
    CURSOR c_ovr_awd( x_fund_id igf_aw_fund_mast.fund_id%TYPE ) IS
    SELECT row_id
      FROM igf_aw_award_t awdt
     WHERE fund_id = x_fund_id
       AND flag = 'OV'
       AND process_id = l_process_id;

    l_ovr_awd    c_ovr_awd%ROWTYPE;
    lv_rowid     VARCHAR2(25);
    l_sl_number  NUMBER(15);
    l_overaward  NUMBER(12,2);

    -- Remove the funds from the students list who does not belong to the Person ID group defined at the Traget group funds.

    CURSOR c_rmv_funds(
                       cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                       cp_fund_id            igf_aw_fund_mast_all.fund_id%TYPE,
                       cp_seq_no             igf_aw_awd_frml_det_all.seq_no%TYPE,
                       cp_formula_code       igf_aw_awd_frml_det_all.formula_code%TYPE,
                       cp_ci_cal_type        igf_aw_awd_frml_det_all.ci_cal_type%TYPE,
                       cp_ci_sequence_number igf_aw_awd_frml_det_all.ci_sequence_number%TYPE
                      ) IS
      SELECT fmdet.seq_no, fmdet.pe_group_id, grp.group_cd
        FROM igf_aw_awd_frml_det fmdet,
             igf_aw_fund_mast fmast,
             igs_pe_all_persid_group_v grp
       WHERE fmast.fund_id = cp_fund_id
         AND fmdet.fund_id = fmast.fund_id
         AND fmdet.seq_no  = cp_seq_no
         AND fmdet.pe_group_id IS NOT NULL
         AND fmdet.pe_group_id = grp.group_id
         AND fmdet.formula_code = cp_formula_code
         AND fmdet.ci_cal_type = cp_ci_cal_type
         AND fmdet.ci_sequence_number = cp_ci_sequence_number;

    lc_rmv_funds     c_rmv_funds%ROWTYPE;

    -- Variables for the dynamic person id group
    lv_status     VARCHAR2(1);
    lv_sql_stmt   VARCHAR(32767) ;

    TYPE CrmvFundsCurTyp IS REF CURSOR ;
    c_rmv_funds_check CrmvFundsCurTyp ;
    lv_rmv_funds_check  NUMBER(1);

    lb_create_funds  BOOLEAN;
    lb_elig_funds    BOOLEAN;
    lv_message_str   VARCHAR2(1000);

    l_terms           NUMBER;
    lv_fed_fund_code  VARCHAR2(30);

    lv_result         VARCHAR2(80);
    lv_method_code    igf_aw_awd_dist_plans.dist_plan_method_code%TYPE;

    lv_name           igf_aw_awd_dist_plans.awd_dist_plan_cd_desc%TYPE;
    lv_desc           igf_aw_awd_dist_plans_v.dist_plan_method_code_desc%TYPE;
    --FACR116
    l_rel_code     igf_sl_cl_setup.relationship_cd%TYPE;
    ln_person_id   igf_sl_cl_pref_lenders.person_id%TYPE;
    l_party_id     igf_sl_cl_setup.party_id%TYPE;
    l_alt_rel_code igf_sl_cl_setup.relationship_cd%TYPE;

    CURSOR c_dp_ap(
                   cp_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                   cp_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                   cp_adplans_id         igf_aw_awd_dist_plans.adplans_id%TYPE,
                   cp_award_prd_code     igf_aw_awd_prd_term.award_prd_cd%TYPE
                  ) IS
      SELECT 'x'
        FROM dual
       WHERE EXISTS (
                     SELECT DISTINCT ld_cal_type,ld_sequence_number
                       FROM igf_aw_dp_terms
                      WHERE adplans_id = cp_adplans_id

                     MINUS

                     SELECT ld_cal_type,ld_sequence_number
                       FROM igf_aw_awd_prd_term
                      WHERE ci_cal_type = cp_ci_cal_type
                        AND ci_sequence_number = cp_ci_sequence_number
                        AND award_prd_cd = cp_award_prd_code
                      );
    l_dp_ap c_dp_ap%ROWTYPE;

  CURSOR c_other_awards(
                        cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE,
			cp_group_code         igf_aw_awd_frml_det_all.formula_code%TYPE,
                        cp_ci_cal_type        igf_aw_awd_frml_det_all.ci_cal_type%TYPE,
                        cp_ci_sequence_number igf_aw_awd_frml_det_all.ci_sequence_number%TYPE
                       ) IS
    SELECT DISTINCT fmast.fund_id,
           fmast.lock_award_flag,
           fmast.re_pkg_verif_flag,
           fmast.donot_repkg_if_code
      FROM igf_aw_award_all awd,
           igf_aw_fund_mast_all fmast,
           igf_aw_awd_disb_all disb,
           igf_aw_awd_prd_term aprd
     WHERE fmast.fund_id = awd.fund_id
       AND awd.base_id = cp_base_id
       AND awd.award_id = disb.award_id
       AND disb.ld_cal_type = aprd.ld_cal_type
       AND disb.ld_sequence_number = aprd.ld_sequence_number
       AND aprd.ci_cal_type = fmast.ci_cal_type
       AND aprd.ci_sequence_number = fmast.ci_sequence_number
       AND aprd.award_prd_cd = cp_awd_prd_code
       AND awd.fund_id NOT IN (SELECT fmdet.fund_id
                                  FROM igf_aw_awd_frml_det_all fmdet
                                 WHERE fmdet.formula_code = cp_group_code
                                   AND fmdet.ci_cal_type = cp_ci_cal_type
                                   AND fmdet.ci_sequence_number = cp_ci_sequence_number);

    l_stud_program_cd   igs_ps_ver_v.course_cd%TYPE;
    l_stud_program_ver  igs_ps_ver_v.version_number%TYPE;
    l_ld_cal_type       igs_ca_inst.cal_type%TYPE;
    l_ld_seq_num        igs_ca_inst.sequence_number%TYPE;

    -- Returns the fund source of the given fund
    CURSOR c_get_fund_source(
                              cp_fund_code IGF_AW_FUND_CAT_ALL.FUND_CODE%TYPE
                            )
    IS
        SELECT fund_source
        FROM IGF_AW_FUND_CAT_ALL
        WHERE fund_code = cp_fund_code;
    l_get_fund_source c_get_fund_source%ROWTYPE;

   -- Scans the terms (starting from the earliest) in the awarding period
   -- for a valid key program. The first term that has a valid anticipated
   -- key program data is taken into consideration.
   CURSOR c_get_ant_prog(
                          cp_ci_cal_type      igs_ca_inst.cal_type%TYPE,
                          cp_sequence_number  igs_ca_inst.sequence_number%TYPE,
                          cp_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                          cp_awd_per          igf_aw_awd_prd_term.award_prd_cd%TYPE
                        )
   IS
      SELECT ant_data.program_cd prog,
             ant_data.ld_cal_type load_cal_type,
             ant_data.ld_sequence_number load_seq_num
      FROM
            igf_aw_awd_prd_term awd_per,
            igs_ca_inst_all cal_inst,
            igf_ap_fa_ant_data ant_data,
            igs_ps_ver prog
      WHERE
            awd_per.ld_cal_type         =   cal_inst.cal_type           AND
            awd_per.ld_sequence_number  =   cal_inst.sequence_number    AND
            ant_data.ld_cal_type        =   awd_per.ld_cal_type         AND
            ant_data.ld_sequence_number =   awd_per.ld_sequence_number  AND
            awd_per.ci_cal_type         =   cp_ci_cal_type              AND
            awd_per.ci_sequence_number  =   cp_sequence_number          AND
            awd_per.award_prd_cd        =   cp_awd_per                  AND
            ant_data.base_id            =   cp_base_id                  AND
            ant_data.program_cd         =   prog.course_cd              AND
            prog.course_status          =   'ACTIVE'                    AND
            ant_data.program_cd IS NOT NULL
      ORDER BY get_term_start_date(cp_base_id, awd_per.ld_cal_type, awd_per.ld_sequence_number) ASC,
      prog.version_number DESC;

   l_ant_prog_rec c_get_ant_prog%ROWTYPE;

    -- Gets all the existing awards for a particular fund for a particular student
    CURSOR c_get_cancel_awds(
                              cp_fund_id        igf_aw_fund_mast_all.fund_id%TYPE,
                              cp_base_id        igf_ap_fa_base_rec_all.base_id%TYPE,
                              cp_process_id     igf_aw_award_t_all.process_id%TYPE
                            )
    IS
      SELECT awd_t.rowid, awd_t.*
      FROM igf_aw_award_t_all awd_t
      WHERE
            base_id     =   cp_base_id    AND
            fund_id     =   cp_fund_id    AND
            process_id  =   cp_process_id AND
            flag <> 'AL';

    -- Get Key program data from Admissions
    -- A student can have more than one record in Admissions. But we will
    -- consider only those students who have a single Admission record.
    -- The 'COUNT(person_id)' predicate is used to implement this
    CURSOR c_get_prog_frm_adm(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
        SELECT adm.course_cd key_prog, adm.crv_version_number key_prog_ver
        FROM
              igs_ad_ps_appl_inst_all adm,
              igs_ad_ou_stat s_adm_st,
              igf_ap_fa_base_rec_all fabase
        WHERE
              adm.person_id = fabase.person_id AND
              fabase.base_id = cp_base_id AND
              adm.adm_outcome_status = s_adm_st.adm_outcome_status  AND
              s_adm_st.s_adm_outcome_status IN ('OFFER', 'COND-OFFER') AND
              adm.course_cd IS NOT NULL AND
              1 = (SELECT COUNT(person_id)
                   FROM igs_ad_ps_appl_inst_all adm1, igs_ad_ou_stat s_adm_st1
                   WHERE
                        adm1.person_id = adm.person_id AND
                        adm1.adm_outcome_status = s_adm_st1.adm_outcome_status AND
                        s_adm_st1.s_adm_outcome_status IN ('OFFER', 'COND-OFFER') AND
                        adm1.course_cd IS NOT NULL);

    l_adm_rec         c_get_prog_frm_adm%ROWTYPE;
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

  BEGIN
    lv_status := 'S';   -- Defaulted to 'S' and the function will return 'F' in case of failure

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'starting load_funds with l_target_group:'||l_target_group||' l_ci_cal_type:'||l_ci_cal_type||' l_ci_sequence_number:'||l_ci_sequence_number);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'g_sf_packaging:'||g_sf_packaging);
    END IF;
    --Load all funds INTO the temporary table with a flag of 'CF'
    --Indicating this is not an award
    OPEN c_fund_ld(
                   l_target_group,
                   l_ci_cal_type,
                   l_ci_sequence_number
                  );
    LOOP
      FETCH c_fund_ld INTO l_fund_ld;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'opened and fetched c_fund_ld');
      END IF;
      EXIT WHEN c_fund_ld%NOTFOUND;

      lc_rmv_funds    := NULL;
      lb_create_funds := TRUE;
      lb_elig_funds   := TRUE;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'opened c_fund_ld and it fetched l_fund_ld.fund_id:'||l_fund_ld.fund_id||' l_fund_ld.seq_no:'||l_fund_ld.seq_no||
                                               ',adplans_id:'||l_fund_ld.adplans_id);
      END IF;
      -- For packaging process check whether the student is present in the Person ID Group which is
      -- defined against the fund instance in the Target groups. If present load that fund else skip
      -- that fund instance from the target group
      IF g_sf_packaging = 'F' THEN
        OPEN c_rmv_funds(
                         l_base_id,
                         l_fund_ld.fund_id,
                         l_fund_ld.seq_no,
                         l_target_group,
                         l_ci_cal_type,
                         l_ci_sequence_number
                        );
        FETCH c_rmv_funds INTO lc_rmv_funds;

        IF c_rmv_funds%FOUND THEN
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'c_rmv_funds%FOUND=TRUE');
           END IF;

          -- To check that the person does not exist in the group
          -- Bug #5021084
          lv_sql_stmt := igf_ap_ss_pkg.get_pid(lc_rmv_funds.pe_group_id,lv_status,lv_group_type);

          --Bug #5021084. Passing Group ID if the group type is STATIC.
          IF lv_group_type = 'STATIC' THEN
            OPEN  c_rmv_funds_check FOR 'SELECT 1
                                           FROM igf_ap_fa_base_rec fabase
                                          WHERE fabase.base_id   = :base_id
                                            AND fabase.person_id in ( '||lv_sql_stmt||') ' USING  l_base_id, lc_rmv_funds.pe_group_id;
          ELSIF lv_group_type = 'DYNAMIC' THEN
            OPEN  c_rmv_funds_check FOR 'SELECT 1
                                           FROM igf_ap_fa_base_rec fabase
                                          WHERE fabase.base_id   = :base_id
                                            AND fabase.person_id in ( '||lv_sql_stmt||') ' USING  l_base_id;
          END IF;

          FETCH c_rmv_funds_check INTO lv_rmv_funds_check;

          IF c_rmv_funds_check%NOTFOUND THEN
            lb_create_funds := FALSE;
            lb_elig_funds   := FALSE;
            lv_message_str  := NULL;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'c_rmv_funds_check%NOTFOUND=TRUE');
            END IF;
            -- Log the message in the log file
            fnd_file.put_line(fnd_file.log,' ');
            fnd_message.set_name('IGF','IGF_AW_SKIP_REC');
            lv_message_str := fnd_message.get;
            lv_message_str := lv_message_str || l_fund_ld.fund_code || '. ';

            fnd_message.set_name('IGF','IGF_AP_STUD_NOT_QLFY_GRP');
            fnd_message.set_token('GROUP',lc_rmv_funds.group_cd);

            lv_message_str := lv_message_str || fnd_message.get;
            fnd_file.put_line(fnd_file.log,lv_message_str);
            fnd_file.put_line(fnd_file.log,' ');
           END IF;
        END IF;
        CLOSE c_rmv_funds;

      END IF;

      -- Check whether the fund can be awarded to the Person, if not skip the fund
      IF igf_aw_gen_005.get_stud_hold_effect( 'A', l_person_id, l_fund_ld.fund_code ) = 'F'  THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'after c_remv_funds cursor loop,igf_aw_gen_005.get_stud_hold_effect(A,'||l_person_id||','||l_fund_ld.fund_code||'=F');
        END IF;
        fnd_message.set_name('IGF','IGF_AW_AWD_FUND_HOLD_FAIL');
        fnd_message.set_token('FUND',l_fund_ld.fund_code);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        lb_create_funds := FALSE;
        lb_elig_funds   := FALSE;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'l_fund_ld.adplans_id:   '||l_fund_ld.adplans_id || 'g_plan_id : '||g_plan_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'l_fund_ld.max_num_disb: '||l_fund_ld.max_num_disb);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'l_fund_ld.min_num_disb: '||l_fund_ld.min_num_disb);
      END IF;
      igf_aw_gen_003.check_common_terms(NVL(l_fund_ld.adplans_id,g_plan_id),l_base_id,l_terms);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'l_terms:'||l_terms);
      END IF;

      IF l_terms = 0 THEN
        /*
           when no common terms exist between the COA of the student and
           in single fund packaging, the allow_to_exceed is set to COA,
           then load the fund if the distribution plan is not 'Match COA'
           else dont load the fund
        */
        IF igf_aw_gen_003.check_coa(l_base_id) = FALSE AND g_sf_packaging = 'T' AND NVL(g_allow_to_exceed,'*') = 'COA' THEN
          --check the distribution type
          check_plan(NVL(l_fund_ld.adplans_id,g_plan_id),lv_result,lv_method_code);
          IF lv_result = 'TRUE' AND lv_method_code = 'C' THEN
            lb_create_funds := FALSE;

            fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
            fnd_message.set_token('FUND',l_fund_ld.fund_code);
            fnd_file.put_line(fnd_file.log,fnd_message.get);

            fnd_message.set_name('IGF','IGF_AW_COA_COMMON_TERMS_FAIL');
            get_plan_desc(l_fund_ld.adplans_id,lv_name,lv_desc);
            fnd_message.set_token('PLAN_CD',lv_name);
            fnd_file.put_line(fnd_file.log,fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'not loading fund '||l_fund_ld.fund_code||' as common terms failed for the MATCH COA distribution');
            END IF;

          ELSE
            lb_create_funds := TRUE;
          END IF;
        ELSE

          lb_create_funds := FALSE;

          fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
          fnd_message.set_token('FUND',l_fund_ld.fund_code);
          fnd_file.put_line(fnd_file.log,fnd_message.get);

          fnd_message.set_name('IGF','IGF_AW_COA_COMMON_TERMS_FAIL');
          get_plan_desc(NVL(l_fund_ld.adplans_id,g_plan_id),lv_name,lv_desc);
          fnd_message.set_token('PLAN_CD',lv_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'not loading fund '||l_fund_ld.fund_code||' as common terms = 0');
          END IF;

        END IF;

      ELSIF l_fund_ld.max_num_disb IS NOT NULL AND l_terms > l_fund_ld.max_num_disb THEN

        fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
        fnd_message.set_token('FUND',l_fund_ld.fund_code);
        fnd_file.put_line(fnd_file.log,fnd_message.get);

        fnd_message.set_name('IGF','IGF_AW_MAX_NUM_DISB_EXCEEDED');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        lb_create_funds := FALSE;
      ELSIF l_fund_ld.min_num_disb IS NOT NULL AND l_terms < l_fund_ld.min_num_disb THEN

        fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
        fnd_message.set_token('FUND',l_fund_ld.fund_code);
        fnd_file.put_line(fnd_file.log,fnd_message.get);

        fnd_message.set_name('IGF','IGF_AW_MIN_NUM_DISB_NOT_EXCEED');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        lb_create_funds := FALSE;
      END IF;

      IF l_fund_ld.max_num_disb IS NULL THEN

        lv_fed_fund_code := get_fed_fund_code(l_fund_ld.fund_id);

        IF lv_fed_fund_code IN ('DLP','FLP') THEN   -- PLUS
          IF l_terms  > 4 THEN
             fnd_message.set_name('IGF','IGF_AW_PLUS_DISB');
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             lb_create_funds := FALSE;
          END IF;

        ELSIF lv_fed_fund_code IN ('DLS','FLS','DLU','FLU') THEN   -- S.UNS.
          IF l_terms  > 20 THEN
             fnd_message.set_name('IGF','IGF_AW_SUNS_DISB');
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             lb_create_funds := FALSE;
          END IF;

        ELSIF  lv_fed_fund_code = 'PELL' THEN
          --
          -- If the maximum disb num is not specified, for Pell it can be 90
          --
          IF l_terms > 90 THEN
            fnd_message.set_name('IGF','IGF_AW_PELL_DISB');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            lb_create_funds := FALSE;
          END IF;

        END IF;
      END IF;

      l_rel_code     := NULL;
      ln_person_id   := NULL;
      l_party_id     := NULL;
      l_alt_rel_code := NULL;

      -- FACR116
      IF get_fed_fund_code(l_fund_ld.fund_id) = 'ALT' THEN
         l_alt_rel_code  := igf_sl_award.get_alt_rel_code(l_fund_ld.fund_code);
          -- get the rel_code assosiated with the fund_code and check if the set up is present
        IF l_alt_rel_code IS NULL THEN
           fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
           fnd_message.set_token('FUND',l_fund_ld.fund_code);
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           fnd_message.set_name('IGF','IGF_AW_NO_ALT_LOAN_CD');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           lb_create_funds := FALSE;
           lb_elig_funds   := FALSE;
        ELSE
           -- this will ensure whether that relationship code has a set up for the context award year
           igf_sl_award.pick_setup(l_base_id,l_ci_cal_type,l_ci_sequence_number,l_rel_code,ln_person_id,l_party_id,l_alt_rel_code);
           IF l_rel_code IS NULL AND l_party_id IS NULL THEN
              fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
              fnd_message.set_token('FUND',l_fund_ld.fund_code);
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              fnd_message.set_name('IGF','IGF_SL_NO_ALT_SETUP');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              lb_create_funds := FALSE;
              lb_elig_funds   := FALSE;
           END IF;
         END IF;
      END IF;

      IF get_fed_fund_code(l_fund_ld.fund_id) = 'FWS' THEN
        IF NOT check_disb(l_base_id,NVL(l_fund_ld.adplans_id,g_plan_id),g_awd_prd) THEN
          fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
          fnd_message.set_token('FUND',l_fund_ld.fund_code);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          fnd_message.set_name('IGF','IGF_SE_MAX_TP_SETUP');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          lb_create_funds := FALSE;
        END IF;
      END IF;

      --here, we have to check if the distr plan would cause the award to span outside the current awarding period.
      --if yes, the whole student should be skipped.
      --this would happen only for packaging.
      --for single fund, this validation is enforced in the parameters screen itself
      IF g_sf_packaging = 'F' THEN
        OPEN c_dp_ap(l_ci_cal_type,l_ci_sequence_number,NVL(l_fund_ld.adplans_id,g_plan_id),g_awd_prd);
        FETCH c_dp_ap INTO l_dp_ap;
        IF c_dp_ap%FOUND THEN
          CLOSE c_dp_ap;
          fnd_message.set_name('IGF','IGF_AW_INV_DIST_PLAN');
          lv_name := NULL;
          lv_desc := NULL;
          get_plan_desc(NVL(l_fund_ld.adplans_id,g_plan_id),lv_name,lv_desc);
          fnd_message.set_token('DISTRPLAN',lv_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE INVALID_DISTR_PLAN;
        END IF;
        CLOSE c_dp_ap;
      END IF;

      -- Build# FA157 - Bug# 4382371
      -- Validate Program Eligibility: Check if the Fund Source is eligible to
      -- provide aid for Student's Key Program. If not, skip the fund.
      -- Key program information is got by looking in this order -
      --    (a) Enrollment data (Actual data)
      --    (b) Admissions data
      --    (c) FA Anticipated data

      -- (a) Get the Student's Key Program from Enrollment (Actual data)
      IGF_AP_GEN_001.get_key_program( cp_base_id        =>    l_base_id,
                                      cp_course_cd      =>    l_stud_program_cd,
                                      cp_version_number =>    l_stud_program_ver);

      IF l_stud_program_cd IS NULL THEN -- Enrollment

          -- (b) Key Prog not defined in Enrollment. Get the Student's Key Program from Admissions data
          OPEN c_get_prog_frm_adm(cp_base_id => l_base_id);
          FETCH c_get_prog_frm_adm INTO l_adm_rec;

          IF (c_get_prog_frm_adm%FOUND) THEN
            l_stud_program_cd   :=  l_adm_rec.key_prog;
            l_stud_program_ver  :=  l_adm_rec.key_prog_ver;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id, 'Getting key program details from Admissions. Key program: ' ||l_stud_program_cd|| ', Version: ' ||l_stud_program_ver);
            END IF;

          END IF;
          CLOSE c_get_prog_frm_adm;

          IF l_stud_program_cd IS NULL THEN -- Admission

              -- (c) Key Prog not defined in Admissions. Get the Student's Key Program from FA anticipated data
              -- Anticipated data is defined at the term level. But the Packaging concurrent process
              -- works at the awarding period level. We will consider the earliest term in the
              -- awarding period that has a valid anticipated key program data.
              -- Note, if we are getting the Key Program details from anticipated data
              -- the version number is not available

              IF igf_aw_coa_gen.canUseAnticipVal THEN
                OPEN c_get_ant_prog (
                                      cp_ci_cal_type      =>  l_ci_cal_type,
                                      cp_sequence_number  =>  l_ci_sequence_number,
                                      cp_base_id          =>  l_base_id,
                                      cp_awd_per          =>  g_awd_prd
                                    );
                FETCH c_get_ant_prog INTO l_ant_prog_rec;

                IF (c_get_ant_prog%FOUND) THEN
                  -- Anticipated KeyProgram data found
                  l_stud_program_cd   :=  l_ant_prog_rec.prog;
                  l_stud_program_ver  :=  NULL;

                  -- Log message
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,
                                  'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,
                                  'Actual key program data not available, but found anticipated key program.');
                    fnd_log.string(fnd_log.level_statement,
                                  'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,
                                  'Anticipated key program=' ||l_stud_program_cd|| ', Term cal type=' ||l_ant_prog_rec.load_cal_type|| ', Term sequence number=' ||l_ant_prog_rec.load_seq_num|| ', Base_id=' ||l_base_id);
                  END IF;

                ELSE
                  -- Anticipated data is not avaiable, there is no way we can get the Key Program details.
                  -- Log message and skip fund
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,
                                   'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,
                                   'Key program details are not available in both actual and anticipated data for fund: ' ||l_fund_ld.fund_code|| ', base_id ' ||l_base_id|| '. But still continue to award the student.');
                  END IF;
                END IF;
                CLOSE c_get_ant_prog;
            ELSE
                -- Profile setting does not permit to look into anticipated data
                -- Log message and skip fund
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,
                                 'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,
                                 'Key program details are not available in both actual and anticipated data for fund: ' ||l_fund_ld.fund_code|| ', base_id ' ||l_base_id|| '. But still continue to award the student.');
                END IF;
            END IF;     -- End igf_aw_coa_gen.canUseAnticipVal
          END IF;       -- l_stud_program_cd IS NULL (Admissions)
      END IF;           -- l_stud_program_cd IS NULL (Enrollment)

      -- Get the Fund Source of the current Fund code
      OPEN c_get_fund_source(l_fund_ld.fund_code);
      FETCH c_get_fund_source INTO l_get_fund_source;
      CLOSE c_get_fund_source;

      -- Check program eligibility.
      -- If the fund source is FEDERAL/INSTITUTIONAL/STATE
      -- then check if the fund is eligible to sponsor the program
      -- Note, for other fund sources, this check is not required
      IF l_get_fund_source.fund_source IN ('FEDERAL', 'INSTITUTIONAL', 'STATE') AND (l_stud_program_cd IS NOT NULL) THEN
        -- Log values
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id, 'Calling get_prog_elig to check the eligiblity of the program: ' ||l_stud_program_cd|| ' for the fund: ' ||l_fund_ld.fund_code);
        END IF;

        IF get_prog_elig(l_stud_program_cd, l_stud_program_ver, l_get_fund_source.fund_source) THEN
          -- Eligible
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id, 'Fund Code: ' ||l_fund_ld.fund_code|| ' is eligible to sponsor the program: ' ||l_stud_program_cd);
          END IF;
        ELSE
          -- Not Eligible
          fnd_message.set_name('IGF','IGF_AW_FND_NOT_ELIGIBLE');
          fnd_message.set_token('PROGRAM',l_stud_program_cd);
          fnd_message.set_token('FUND',(l_fund_ld.fund_code));
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          lb_create_funds := FALSE;
          lb_elig_funds   := FALSE;

          -- Log values
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id, 'Fund Code: ' ||l_fund_ld.fund_code|| ' is NOT eligible to sponsor the program: ' ||l_stud_program_cd);
          END IF;
        END IF;
      END IF;

      -- If students passes person id group check then load the fund into temp table.
      -- Person id check is not necessary for single fund process
      IF lb_create_funds THEN
        -- Log values
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id, 'lb_create_funds is TRUE');
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'calling awardsExist with '||
                         'p_ci_cal_type:'||l_ci_cal_type||
                         'p_ci_sequence_number:'||l_ci_sequence_number||
                         'p_base_id:'||l_base_id||
                         'p_fund_id:'||l_fund_ld.fund_id||
                         'p_awd_prd_code:'||g_awd_prd
                        );
        END IF;

        IF awardsExist(
                       p_ci_cal_type        => l_ci_cal_type,
                       p_ci_sequence_number => l_ci_sequence_number,
                       p_base_id            => l_base_id,
                       p_fund_id            => l_fund_ld.fund_id,
                       p_awd_prd_code       => g_awd_prd
                      ) THEN
          --oops.we are into repackaging
          --we have to load the awards into the igf_aw_award_t table

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'calling load_awards for fund:'||l_fund_ld.fund_id||
                                                   'base_id:'||l_base_id||
                                                   'seq_no:'||l_fund_ld.seq_no||
                                                   'max_award_amt:'||l_fund_ld.max_award_amt||
                                                   'min_award_amt:'||l_fund_ld.min_award_amt
                          );
          END IF;
          --but first, impose repackaging rules for all awards from the fund
          load_awards(
                      p_ci_cal_type         => l_ci_cal_type,
                      p_ci_sequence_number  => l_ci_sequence_number,
                      p_award_prd_code      => g_awd_prd,
                      p_base_id             => l_base_id,
                      p_fund_id             => l_fund_ld.fund_id,
                      p_lock_award_flag     => l_fund_ld.lock_award_flag,
                      p_re_pkg_verif_flag   => l_fund_ld.re_pkg_verif_flag,
                      p_donot_repkg_if_code => l_fund_ld.donot_repkg_if_code,
                      p_adplans_id          => l_fund_ld.adplans_id,
                      p_max_award_amt       => l_fund_ld.max_award_amt,
                      p_min_award_amt       => l_fund_ld.min_award_amt,
                      p_seq_no              => l_fund_ld.seq_no
                     );
        ELSE
          lv_rowid    := NULL;
          l_sl_number := NULL;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'inserting into igf_aw_award_t with flag:CF for fund:'||l_fund_ld.fund_id||' and base_id:'||l_base_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'also g_plan_id:'||g_plan_id||',l_fund_ld.fund_id:'||l_fund_ld.adplans_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'also l_fund_ld.max_award_amt:'||l_fund_ld.max_award_amt||',l_fund_ld.min_award_amt:'||l_fund_ld.min_award_amt);
          END IF;

          igf_aw_award_t_pkg.insert_row(
                                        x_rowid              => lv_rowid ,
                                        x_process_id         => l_process_id ,
                                        x_sl_number          => l_sl_number,
                                        x_fund_id            => l_fund_ld.fund_id,
                                        x_base_id            => l_base_id,
                                        x_offered_amt        => 0,
                                        x_accepted_amt       => 0,
                                        x_paid_amt           => 0,
                                        x_need_reduction_amt => NULL,
                                        x_flag               => 'CF',
                                        x_temp_num_val1      => NULL,
                                        x_temp_num_val2      => NULL,
                                        x_temp_char_val1     => TO_CHAR(l_fund_ld.seq_no),
                                        x_tp_cal_type        => NULL,
                                        x_tp_sequence_number => NULL,
                                        x_ld_cal_type        => NULL,
                                        x_ld_sequence_number => NULL,
                                        x_mode               => 'R',
                                        x_adplans_id         => NVL(l_fund_ld.adplans_id,g_plan_id),
                                        x_app_trans_num_txt  => NULL,
                                        x_award_id           => NULL,
                                        x_lock_award_flag    => l_fund_ld.lock_award_flag,
                                        x_temp_val3_num      => l_fund_ld.max_award_amt,
                                        x_temp_val4_num      => l_fund_ld.min_award_amt,
                                        x_temp_char2_txt     => NULL,
                                        x_temp_char3_txt     => NULL
                                       );
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'opening c_ovr_awd');
        END IF;
        -- If OverAward is allowed for a fund, maintain overaward details in the Temporary table ( with flag 'OV' )
        -- This record will be inserted only once for the fund irrespective of students and the
        -- remaining total will be decreasing for every award created
        OPEN c_ovr_awd( l_fund_ld.fund_id );
        FETCH c_ovr_awd INTO l_ovr_awd;

        IF ( c_ovr_awd%NOTFOUND ) THEN
          l_overaward := 0;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'c_ovr_awd%NOTFOUND!l_overaward:'||l_overaward);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'l_fund_ld.allow_overaward:'||l_fund_ld.allow_overaward);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'l_fund_ld.over_award_amt:'||l_fund_ld.over_award_amt);
          END IF;

          IF ( l_fund_ld.allow_overaward = 'Y' ) THEN

            IF NVL(l_fund_ld.over_award_amt,0) > 0 THEN
              l_overaward := l_fund_ld.over_award_amt;

            ELSIF NVL(l_fund_ld.over_award_perct,0) > 0 THEN
              l_overaward := ( l_fund_ld.available_amt * l_fund_ld.over_award_perct/100 );
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'set l_overaward to '||l_overaward);
            END IF;

          END IF;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'inserting into igf_aw_award_t with flag:OV for fund:'||l_fund_ld.fund_id||' and base_id:'||l_base_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'l_fund_ld.remaining_amt:'||l_fund_ld.remaining_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'l_overaward:'||l_overaward);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'adplans_id:'||NVL(l_fund_ld.adplans_id,g_plan_id));
          END IF;
          igf_aw_award_t_pkg.insert_row(
                                        x_rowid              => lv_rowid ,
                                        x_process_id         => l_process_id ,
                                        x_sl_number          => l_sl_number,
                                        x_fund_id            => l_fund_ld.fund_id,
                                        x_base_id            => l_base_id,
                                        x_offered_amt        => 0 ,
                                        x_accepted_amt       => 0 ,
                                        x_paid_amt           => 0  ,
                                        x_need_reduction_amt => NULL,
                                        x_flag               => 'OV',
                                        x_temp_num_val1      => l_fund_ld.remaining_amt,
                                        x_temp_num_val2      => l_overaward,
                                        x_temp_char_val1     => NULL,
                                        x_tp_cal_type        => NULL,
                                        x_tp_sequence_number => NULL,
                                        x_ld_cal_type        => NULL,
                                        x_ld_sequence_number => NULL,
                                        x_mode               => 'R',
                                        x_adplans_id         => NULL,
                                        x_app_trans_num_txt  => NULL,
                                        x_lock_award_flag    => NULL,
                                        x_temp_val3_num      => NULL,
                                        x_temp_val4_num      => NULL,
                                        x_temp_char2_txt     => NULL,
                                        x_temp_char3_txt     => NULL
                                       );

        END IF;
        CLOSE c_ovr_awd;

      ELSE
        -- museshad (Build# FA 157): This ELSE part holds good only for Repackaging.
        -- This part comes into context when an award from a fund was given to a
        -- student during Packaging, but for some reason the student later
        -- lost his eligibility for the fund. In such cases, we need to cancel
        -- the award that was given to the student earlier during Packaging.

        -- Check if Repackaging
        IF awardsExist(
                       p_ci_cal_type        => l_ci_cal_type,
                       p_ci_sequence_number => l_ci_sequence_number,
                       p_base_id            => l_base_id,
                       p_fund_id            => l_fund_ld.fund_id,
                       p_awd_prd_code       => g_awd_prd
                      ) THEN

          IF NOT lb_elig_funds THEN

            -- Log Values
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                             'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,
                             'Both lb_create_funds and lb_elig_funds are FALSE. Base id: ' ||l_base_id|| ' is not eligible for fund: ' ||l_fund_ld.fund_id|| '. Cancelling all existing awards.');
            END IF;

            -- Student not eligible for fund. Load existing awards given to the
            -- student from the fund
            load_awards(
                        p_ci_cal_type         => l_ci_cal_type,
                        p_ci_sequence_number  => l_ci_sequence_number,
                        p_award_prd_code      => g_awd_prd,
                        p_base_id             => l_base_id,
                        p_fund_id             => l_fund_ld.fund_id,
                        p_lock_award_flag     => l_fund_ld.lock_award_flag,
                        p_re_pkg_verif_flag   => l_fund_ld.re_pkg_verif_flag,
                        p_donot_repkg_if_code => l_fund_ld.donot_repkg_if_code,
                        p_adplans_id          => l_fund_ld.adplans_id,
                        p_max_award_amt       => l_fund_ld.max_award_amt,
                        p_min_award_amt       => l_fund_ld.min_award_amt,
                        p_seq_no              => l_fund_ld.seq_no
                       );

            -- Loop thru each existing award and cancel it
            FOR l_cancel_awd_rec IN c_get_cancel_awds(cp_fund_id      =>  l_fund_ld.fund_id,
                                                      cp_base_id      =>  l_base_id,
                                                      cp_process_id   =>  l_process_id)
            LOOP
              -- Cancel awards
              igf_aw_award_t_pkg.update_row(
                                              x_rowid               => l_cancel_awd_rec.rowid,
                                              x_process_id          => l_cancel_awd_rec.process_id,
                                              x_sl_number           => l_cancel_awd_rec.sl_number,
                                              x_fund_id             => l_cancel_awd_rec.fund_id,
                                              x_base_id             => l_cancel_awd_rec.base_id,
                                              x_offered_amt         => 0,
                                              x_accepted_amt        => l_cancel_awd_rec.accepted_amt,
                                              x_paid_amt            => l_cancel_awd_rec.paid_amt,
                                              x_need_reduction_amt  => l_cancel_awd_rec.need_reduction_amt,
                                              x_flag                => 'AC',
                                              x_temp_num_val1       => 0,
                                              x_temp_num_val2       => l_cancel_awd_rec.temp_num_val2,
                                              x_temp_char_val1      => l_cancel_awd_rec.temp_char_val1,
                                              x_tp_cal_type         => l_cancel_awd_rec.tp_cal_type,
                                              x_tp_sequence_number  => l_cancel_awd_rec.tp_sequence_number,
                                              x_ld_cal_type         => l_cancel_awd_rec.ld_cal_type,
                                              x_ld_sequence_number  => l_cancel_awd_rec.ld_sequence_number,
                                              x_mode                => 'R',
                                              x_adplans_id          => l_cancel_awd_rec.adplans_id,
                                              x_app_trans_num_txt   => l_cancel_awd_rec.app_trans_num_txt,
                                              x_award_id            => l_cancel_awd_rec.award_id,
                                              x_lock_award_flag     => l_cancel_awd_rec.lock_award_flag,
                                              x_temp_val3_num       => l_cancel_awd_rec.temp_val3_num,
                                              x_temp_val4_num       => l_cancel_awd_rec.temp_val4_num,
                                              x_temp_char2_txt      => l_cancel_awd_rec.temp_char2_txt,
                                              x_temp_char3_txt      => l_cancel_awd_rec.temp_char3_txt
                                           );
              -- Log values
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,
                               'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,
                               'Cancelled award id: ' ||l_cancel_awd_rec.award_id|| ' for fund: ' ||l_cancel_awd_rec.fund_id|| ' and base_id: ' ||l_cancel_awd_rec.base_id);
              END IF;
            END LOOP;
          END IF; -- End lb_elig_funds
        END IF; -- End awardsExist
      END IF; -- End OV loading funds

    END LOOP;
    CLOSE c_fund_ld;

    IF g_sf_packaging <> 'T' THEN
      --load awards from funds which are not in the award group also
       FOR l_other_awards IN c_other_awards(l_base_id,g_awd_prd,l_target_group,l_ci_cal_type,l_ci_sequence_number) LOOP
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'calling load_awards with fund_id:'||l_other_awards.fund_id);
        END IF;

        load_awards(
                    p_ci_cal_type         => l_ci_cal_type,
                    p_ci_sequence_number  => l_ci_sequence_number,
                    p_award_prd_code      => g_awd_prd,
                    p_base_id             => l_base_id,
                    p_fund_id             => l_other_awards.fund_id,
                    p_lock_award_flag     => l_other_awards.lock_award_flag,
                    p_re_pkg_verif_flag   => l_other_awards.re_pkg_verif_flag,
                    p_donot_repkg_if_code => l_other_awards.donot_repkg_if_code,
                    p_adplans_id          => g_plan_id,
                    p_max_award_amt       => NULL,
                    p_min_award_amt       => NULL,
                    p_seq_no              => NULL
                   );
      END LOOP;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.load_funds.debug '|| g_req_id,'calling merge_funds');
      END IF;
      --call merge_funds only if running in re-packaging mode
      merge_funds(
                  l_target_group,
                  l_ci_cal_type,
                  l_ci_sequence_number,
                  l_base_id
                 );
    END IF;

  EXCEPTION
    WHEN INVALID_DISTR_PLAN THEN
      IF c_fund_ld%ISOPEN THEN
        CLOSE c_fund_ld;
      END IF;
      RAISE;
    WHEN NON_MERGABLE_FUNDS THEN
      RAISE;
    WHEN OTHERS THEN

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.LOAD_FUNDS '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.load_funds.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;
  END load_funds;


  PROCEDURE excl_incl_check(
                            l_process_no IN NUMBER,
                            l_base_id    IN NUMBER,
                            l_run_mode   IN VARCHAR2
                           ) IS
    /*
    ||  Created By : avenkatr
    ||  Created On : 08-JUN-2001
    ||  Purpose    : This procedure checks for Exclusive and Inclusive fund cheks for already loaded
    ||               Funds in the temp table. There are two cycles of checking as
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    || veramach      04-Mar-2004      bug # 3484438 - Changed cursor cur_new_awards to properly join on igf_aw_fund_mast_all
    ||  veramach        20-NOV-2003     FA 125 - Modified cur_new_awards to use adplans_id instead of fund_id
    */

    -- Get all the funds which were rejected earlier for reconsidering
    CURSOR c_init_flag(
                       x_process_is NUMBER,
                       x_base_id igf_ap_fa_base_rec.base_id%TYPE
                      ) IS
    SELECT *
      FROM igf_aw_award_t
     WHERE process_id = x_process_is
       AND base_id    = x_base_id
       AND flag       IN ('RF','AR');

    l_init_flag  c_init_flag%ROWTYPE;

    -- Get all the Active funds from Temp table for checking Inclusive and Exclusive
    CURSOR c_fund_chk(
                      x_process_id  NUMBER,
                      x_base_id     NUMBER
                     ) IS
    SELECT awdt.*
      FROM igf_aw_award_t awdt
     WHERE awdt.process_id = x_process_id
       AND awdt.base_id    = x_base_id
       AND awdt.flag       IN ('CF','AU')
     ORDER BY TO_NUMBER(awdt.temp_char_val1);  -- Sequence order of the fund in Temp table

    l_fund_chk c_fund_chk%ROWTYPE;

    -- Get all the Exclusive funds for a given fund
    CURSOR c_fund_ex (x_fund_id igf_aw_fund_excl.fund_id%TYPE ) IS
    SELECT fexc.fund_code
      FROM igf_aw_fund_excl fexc
     WHERE fexc.fund_id = x_fund_id;

    l_fund_ex c_fund_ex%ROWTYPE;

    -- Get all the Inclusive funds for a given fund
    CURSOR c_fund_in (x_fund_id igf_aw_fund_incl.fund_id%TYPE ) IS
    SELECT finc.fund_code
      FROM igf_aw_fund_incl finc
     WHERE finc.fund_id = x_fund_id;

    l_fund_in c_fund_in%ROWTYPE;

    -- Get the count of all the funds from the Temp Table for a given fund code and base_id
    -- Here the checking for the fund for the same TERMs occurances
    CURSOR cur_new_awards(
                        x_fund_code   igf_aw_fund_cat.fund_code%TYPE,
                        x_base_id     igf_aw_award_t.base_id%TYPE,
                        x_process_id  igf_aw_award_t.base_id%TYPE,
                        x_award_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                       ) IS
      SELECT COUNT(awdt.fund_id) ftotal
        FROM igf_aw_award_t awdt,
             igf_aw_fund_mast_all fmast,
             igf_aw_dp_terms adterms,
             igf_aw_awd_prd_term aprd
        WHERE fmast.fund_code          = x_fund_code
          AND awdt.base_id             = x_base_id
          AND awdt.process_id          = x_process_id
          AND awdt.fund_id             = fmast.fund_id
          AND awdt.flag                = 'CF'
          AND awdt.adplans_id          = adterms.adplans_id
          AND aprd.ld_cal_type        = adterms.ld_cal_type
          AND aprd.ld_sequence_number = adterms.ld_sequence_number
          AND aprd.award_prd_cd       = x_award_prd_code
          AND aprd.ci_cal_type        = fmast.ci_cal_type
          AND aprd.ci_sequence_number = fmast.ci_sequence_number;

    new_awards_rec cur_new_awards%ROWTYPE;

    -- Get the count of the Active Awards of the student for a given fund

    CURSOR cur_prior_awards(
                         x_fund_code   igf_aw_fund_cat.fund_code%TYPE,
                         x_base_id     igf_aw_award_t.base_id%TYPE,
                         x_award_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                        ) IS
    SELECT COUNT(fmast.fund_code) ftotal
      FROM igf_aw_award_all awd,
           igf_aw_awd_disb_all disb,
           igf_aw_fund_mast_all fmast,
           igf_aw_awd_prd_term aprd
     WHERE fmast.fund_code = x_fund_code
       AND awd.base_id     = x_base_id
       AND awd.fund_id     = fmast.fund_id
       AND awd.award_id    = disb.award_id
       AND disb.ld_cal_type = aprd.ld_cal_type
       AND disb.ld_sequence_number = aprd.ld_sequence_number
       AND aprd.award_prd_cd = x_award_prd_code
       AND aprd.ci_cal_type = fmast.ci_cal_type
       AND aprd.ci_sequence_number = fmast.ci_sequence_number
       AND awd.award_status  IN ('OFFERED','ACCEPTED')
       AND disb.trans_type <> 'C';

    prior_awards_rec cur_prior_awards%ROWTYPE;

    CURSOR c_fund_cd(cp_fund_id igf_aw_fund_mast.fund_id%TYPE) IS
    SELECT fund_code
      FROM igf_aw_fund_mast
     WHERE fund_id = cp_fund_id;

    l_fund_cd     c_fund_cd%ROWTYPE;

    l_flag        igf_aw_award_t.flag%TYPE;
  BEGIN

    -- Initialise the previously rejected funds back so that they too are considered
    OPEN c_init_flag( l_process_id, l_base_id );
    LOOP
      FETCH c_init_flag INTO l_init_flag;
      EXIT WHEN c_init_flag%NOTFOUND;

      -- Log messages if the selected parameter is 'Detail Mode'
      IF ( l_run_mode = 'D' ) THEN

        OPEN c_fund_cd(l_init_flag.fund_id);
        FETCH c_fund_cd INTO l_fund_cd;
        CLOSE c_fund_cd;

        fnd_message.set_name('IGF','IGF_AW_RECONSIDER_FUND');
        fnd_message.set_token('FUND', l_fund_cd.fund_code );
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'c_fund_cd%FOUND - reconsidering fund:'||l_fund_cd.fund_code);
        END IF;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'updating igf_aw_award_t for fund_id:'||l_init_flag.fund_id||' with flag:CF,adplans_id:'||l_init_flag.adplans_id);
      END IF;
      /*
        If the record was a rejected fund, make it a considered fund.
        If the record was a rejected award, make it a repackagable candidate.
      */
      l_flag := NULL;
      IF l_init_flag.flag = 'RF' THEN
        l_flag := 'CF';
      ELSIF l_init_flag.flag = 'AR' THEN
        l_flag := 'AU';
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'updating fund_id:'|| l_init_flag.fund_id||
                                               ' base_id:'||l_init_flag.base_id||' to flag:'||l_flag
                      );
      END IF;

      igf_aw_award_t_pkg.update_row(
                                    x_rowid                => l_init_flag.row_id,
                                    x_process_id           => l_init_flag.process_id,
                                    x_sl_number            => l_init_flag.sl_number,
                                    x_fund_id              => l_init_flag.fund_id,
                                    x_base_id              => l_init_flag.base_id,
                                    x_offered_amt          => l_init_flag.offered_amt,
                                    x_accepted_amt         => l_init_flag.accepted_amt,
                                    x_paid_amt             => l_init_flag.paid_amt ,
                                    x_need_reduction_amt   => l_init_flag.need_reduction_amt,
                                    x_flag                 => l_flag,
                                    x_temp_num_val1        => l_init_flag.temp_num_val1,
                                    x_temp_num_val2        => l_init_flag.temp_num_val2,
                                    x_temp_char_val1       => l_init_flag.temp_char_val1,
                                    x_tp_cal_type          => l_init_flag.tp_cal_type,
                                    x_tp_sequence_number   => l_init_flag.tp_sequence_number,
                                    x_ld_cal_type          => l_init_flag.ld_cal_type,
                                    x_ld_sequence_number   => l_init_flag.ld_sequence_number,
                                    x_mode                 => 'R',
                                    x_adplans_id           => l_init_flag.adplans_id,
                                    x_app_trans_num_txt    => l_init_flag.app_trans_num_txt,
                                    x_award_id             => l_init_flag.award_id,
                                    x_lock_award_flag      => l_init_flag.lock_award_flag,
                                    x_temp_val3_num        => l_init_flag.temp_val3_num,
                                    x_temp_val4_num        => l_init_flag.temp_val4_num,
                                    x_temp_char2_txt       => l_init_flag.temp_char2_txt,
                                    x_temp_char3_txt       => l_init_flag.temp_char3_txt
                                   );
    END LOOP;
    CLOSE c_init_flag;

    -- Execute the below loop for two time, bcoz some funds might funds get excluded / included in first cycle
    -- These needs to re checked for the second time for perfect match
    FOR i IN 1..2 LOOP

      --Excl/Incl Fund check first cycle
      OPEN c_fund_chk( l_process_id, l_base_id);
      LOOP
        FETCH c_fund_chk INTO l_fund_chk;
        EXIT WHEN c_fund_chk%NOTFOUND;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'fetched c_fund_chk: it fetched l_fund_chk.fund_id:'||l_fund_chk.fund_id);
        END IF;


        --Check for exclusive funds
        OPEN c_fund_ex ( l_fund_chk.fund_id );
        LOOP
          FETCH c_fund_ex INTO l_fund_ex;
          EXIT WHEN c_fund_ex%NOTFOUND;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'fetched c_fund_ex:it fetched l_fund_ex.fund_code:'||l_fund_ex.fund_code);
          END IF;
          -- Get the count of Exclusive funds whihc are already loaded INTO the Temp Table
          OPEN cur_new_awards(
                            l_fund_ex.fund_code,
                            l_base_id,
                            l_process_id,
                            g_awd_prd
                           );
          FETCH cur_new_awards INTO new_awards_rec;
          CLOSE cur_new_awards;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'new_awards_rec.ftotal:'||new_awards_rec.ftotal);
          END IF;

          -- Get the count of Awards which were awarded to the student from the Exclusive fund
          OPEN cur_prior_awards(l_fund_ex.fund_code, l_base_id,g_awd_prd);
          FETCH cur_prior_awards INTO prior_awards_rec;
          CLOSE cur_prior_awards;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'prior_awards_rec.ftotal:'||prior_awards_rec.ftotal);
          END IF;

          -- If the Exclusive fund is already loaded INTO the Temp table or
          -- If the student gets any awards from the Exclusive funds then skip the fund.
          IF new_awards_rec.ftotal >= 1 OR prior_awards_rec.ftotal >= 1 THEN

            IF ( l_run_mode = 'D' ) THEN
              OPEN c_fund_cd(l_fund_chk.fund_id);
              FETCH c_fund_cd INTO l_fund_cd;
              CLOSE c_fund_cd;

              fnd_message.set_name('IGF','IGF_AW_PK_EX_FND_FAIL');
              fnd_message.set_token('FUND', l_fund_cd.fund_code );
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'updating igf_aw_award_t for fund_id:'||l_fund_chk.fund_id||' with flag:RF,adplans_id:'||l_fund_chk.adplans_id);
            END IF;

            -- Update the Fund status as 'REJECTED' in the Temp Table.
            -- This can used while reconsidering later in different Incl or Excl CHECK
            /*
              If the record was a rejected fund, make it a considered fund.
              If the record was a rejected award, make it a repackagable candidate.
            */
            l_flag := NULL;
            IF l_fund_chk.flag = 'CF' THEN
              l_flag := 'RF';
            ELSIF l_fund_chk.flag = 'AU' THEN
              l_flag := 'AR';
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'updating fund_id:'|| l_fund_chk.fund_id||
                                                     ' base_id:'||l_fund_chk.base_id||' to flag:'||l_flag
                            );
            END IF;

            igf_aw_award_t_pkg.update_row(
                                          x_rowid                => l_fund_chk.row_id,
                                          x_process_id           => l_fund_chk.process_id,
                                          x_sl_number            => l_fund_chk.sl_number,
                                          x_fund_id              => l_fund_chk.fund_id,
                                          x_base_id              => l_fund_chk.base_id,
                                          x_offered_amt          => l_fund_chk.offered_amt,
                                          x_accepted_amt         => l_fund_chk.accepted_amt,
                                          x_paid_amt             => l_fund_chk.paid_amt ,
                                          x_need_reduction_amt   => l_fund_chk.need_reduction_amt,
                                          x_flag                 => l_flag,
                                          x_temp_num_val1        => l_fund_chk.temp_num_val1,
                                          x_temp_num_val2        => l_fund_chk.temp_num_val2,
                                          x_temp_char_val1       => l_fund_chk.temp_char_val1,
                                          x_tp_cal_type          => l_fund_chk.tp_cal_type,
                                          x_tp_sequence_number   => l_fund_chk.tp_sequence_number,
                                          x_ld_cal_type          => l_fund_chk.ld_cal_type,
                                          x_ld_sequence_number   => l_fund_chk.ld_sequence_number,
                                          x_mode                 => 'R',
                                          x_adplans_id           => l_fund_chk.adplans_id,
                                          x_app_trans_num_txt    => l_fund_chk.app_trans_num_txt,
                                          x_award_id             => l_fund_chk.award_id,
                                          x_lock_award_flag      => l_fund_chk.lock_award_flag,
                                          x_temp_val3_num        => l_fund_chk.temp_val3_num,
                                          x_temp_val4_num        => l_fund_chk.temp_val4_num,
                                          x_temp_char2_txt       => l_fund_chk.temp_char2_txt,
                                          x_temp_char3_txt       => l_fund_chk.temp_char3_txt
                                         );
          END IF;
        END LOOP; -- c_fund_exc loop
        CLOSE c_fund_ex;

        -- Check for Inclusive Fund
        OPEN c_fund_in ( l_fund_chk.fund_id );
        LOOP
          FETCH c_fund_in INTO l_fund_in;
          EXIT WHEN c_fund_in%NOTFOUND;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'fetched c_fund_in:it fetched l_fund_in.fund_code:'||l_fund_in.fund_code);
          END IF;

          -- Get the count of Inclusive funds whihc are already loaded INTO the Temp Table
          OPEN cur_new_awards(
                            l_fund_in.fund_code,
                            l_base_id,
                            l_process_id,
                            g_awd_prd
                           );
          FETCH cur_new_awards INTO new_awards_rec;
          CLOSE cur_new_awards;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'new_awards_rec.ftotal:'||new_awards_rec.ftotal);
          END IF;

          -- Get the count of Awards which were awarded to the student from the Inclusive fund
          OPEN cur_prior_awards(l_fund_in.fund_code, l_base_id,g_awd_prd);
          FETCH cur_prior_awards INTO prior_awards_rec;
          CLOSE cur_prior_awards;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'prior_awards_rec.ftotal:'||prior_awards_rec.ftotal);
          END IF;

          -- If the Inclusive fund was not already loaded INTO the Temp table or
          -- If the student is not having any awards from the Inclusive funds then skip the fund.
          IF NVL(new_awards_rec.ftotal,0) + NVL(prior_awards_rec.ftotal,0) < 1 THEN

            IF ( l_run_mode = 'D' ) THEN
              OPEN c_fund_cd(l_fund_chk.fund_id);
              FETCH c_fund_cd INTO l_fund_cd;
              CLOSE c_fund_cd;

              fnd_message.set_name('IGF','IGF_AW_PK_IN_FND_FAIL');
              fnd_message.set_token('FUND', l_fund_cd.fund_code );
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'updating igf_aw_award_t for fund_id:'||l_fund_chk.fund_id||' with flag:RF');
            END IF;

            -- Update the Fund status as 'REJECTED' in the Temp Table.
            -- This can used while reconsidering later in different Incl or Excl CHECK
            /*
              If the record was a rejected fund, make it a considered fund.
              If the record was a rejected award, make it a repackagable candidate.
            */
            l_flag := NULL;
            IF l_fund_chk.flag = 'CF' THEN
              l_flag := 'RF';
            ELSIF l_fund_chk.flag = 'AU' THEN
              l_flag := 'AR';
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.excl_incl_check.debug '|| g_req_id,'updating fund_id:'|| l_fund_chk.fund_id||
                                                     ' base_id:'||l_fund_chk.base_id||' to flag:'||l_flag
                            );
            END IF;

            igf_aw_award_t_pkg.update_row(
                                          x_rowid                => l_fund_chk.row_id,
                                          x_process_id           => l_fund_chk.process_id,
                                          x_sl_number            => l_fund_chk.sl_number,
                                          x_fund_id              => l_fund_chk.fund_id,
                                          x_base_id              => l_fund_chk.base_id,
                                          x_offered_amt          => l_fund_chk.offered_amt,
                                          x_accepted_amt         => l_fund_chk.accepted_amt,
                                          x_paid_amt             => l_fund_chk.paid_amt ,
                                          x_need_reduction_amt   => l_fund_chk.need_reduction_amt,
                                          x_flag                 => l_flag,
                                          x_temp_num_val1        => l_fund_chk.temp_num_val1,
                                          x_temp_num_val2        => l_fund_chk.temp_num_val2,
                                          x_temp_char_val1       => l_fund_chk.temp_char_val1,
                                          x_tp_cal_type          => l_fund_chk.tp_cal_type,
                                          x_tp_sequence_number   => l_fund_chk.tp_sequence_number,
                                          x_ld_cal_type          => l_fund_chk.ld_cal_type,
                                          x_ld_sequence_number   => l_fund_chk.ld_sequence_number,
                                          x_mode                 => 'R',
                                          x_adplans_id           => l_fund_chk.adplans_id,
                                          x_app_trans_num_txt    => l_fund_chk.app_trans_num_txt,
                                          x_award_id             => l_fund_chk.award_id,
                                          x_lock_award_flag      => l_fund_chk.lock_award_flag,
                                          x_temp_val3_num        => l_fund_chk.temp_val3_num,
                                          x_temp_val4_num        => l_fund_chk.temp_val4_num,
                                          x_temp_char2_txt       => l_fund_chk.temp_char2_txt,
                                          x_temp_char3_txt       => l_fund_chk.temp_char3_txt
                                        );
          END IF;
        END LOOP; -- c_fund_incl loop
        CLOSE c_fund_in;

      END LOOP;
      CLOSE c_fund_chk;

    END LOOP; -- End of Looping cycle ( 2 times )

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.EXCL_INCL_CHECK '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.excl_incl_check.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;
  END excl_incl_check;


  PROCEDURE calc_need(
                      p_base_id      IN NUMBER,
                      p_coa_f        IN igf_ap_fa_base_rec.coa_f%TYPE,
                      p_awds         IN OUT NOCOPY std_awards
                     ) IS
    /*
    ||  Created By : skoppula
    ||  Created On : 02-JAN-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    --veramach    20-NOV-2003    FA 125 Build -Removed p_coa_i,p_need_f as parameters
    --veramach    13-OCT-2003    FA 124 Build -Added logic to insert 2 rows into igf_aw_award_t table which holds IM/FM needs
    --rasahoo     05-Aug-2003    #3024112 Changed the parameters in call igf_ap_efc_calc.get_efc_no_of_months
    --
    */

    /* This procedure calculates the NET NEED of the student by substracting the already
    aided award (which are not eligible for Repackaging) to the student and his efc from his cost of attendance COA. The net efc and
    need values are loaded INTO the temporary table and are used in 'process student' procedure
    to calculate the need
    Net Need = COA - (Already Awards which are not eligible for Repkg + EFC)
    */
    CURSOR c_rem_efc IS
    SELECT *
      FROM igf_aw_award_t
     WHERE process_id = l_process_id
       AND base_id = p_base_id
       AND flag = 'AA';

    TYPE efc_cur IS REF CURSOR;

    l_efc_cur       c_rem_efc%ROWTYPE;
    l_new_efc       efc_cur;
    l_emulate_fed   VARCHAR2(30);
    l_inst_method   VARCHAR2(30);
    l_need_f        NUMBER;
    l_need          NUMBER;
    l_efc_f         NUMBER;
    l_need_i        NUMBER;
    l_efc           NUMBER;
    l_efc_i         NUMBER;
    lv_rowid        VARCHAR2(30);
    l_sl_number     NUMBER;
    l_efc_months    NUMBER;
    l_efc_qry       VARCHAR2(1500);
    l_cnt           NUMBER;
    l_rec_fnd       BOOLEAN := FALSE;
    l_rem_efc_f     NUMBER := 0;
    l_rem_efc_i     NUMBER := 0;
    l_rem_efc       NUMBER := 0;
    l_dummy_efc     NUMBER;
    l_efc_ay        NUMBER := 0;
    l_need_VB_AC    NUMBER := 0;
    l_need_VB_AC_f  NUMBER := 0;
    l_need_VB_AC_i  NUMBER := 0;

    -- Get efc for Institutional methodology
    CURSOR c_efc_i(
                    cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                  ) IS
      SELECT coa_duration_efc_amt
        FROM igf_ap_css_profile_all
       WHERE active_profile = 'Y'
         AND base_id        = cp_base_id;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Info - START');
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'p_base_id= ' ||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'p_coa_f= ' ||p_coa_f);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'fed_fund_code= ' ||p_awds.fed_fund_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'award_id= ' ||p_awds.award_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Info - END');
    END IF;

    OPEN c_rem_efc;
    FETCH c_rem_efc INTO l_efc_cur;

    IF c_rem_efc%FOUND THEN
      WHILE c_rem_efc%FOUND LOOP
        l_need := l_efc_cur.temp_num_val2;
        l_need_VB_AC := l_efc_cur.temp_val3_num;
        l_efc  := l_efc_cur.temp_num_val1;
        l_rem_efc := NVL(l_efc,0);  -- Initialize to total remaining efc

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Getting previous calculated value for l_need, l_need_VB_AC, l_efc');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need= ' ||l_need|| ' l_need_VB_AC= ' ||l_need_VB_AC|| ' l_efc= ' ||l_efc);
        END IF;

        -- If Fund has both the Replcae EFC and Replace NEED are checked then calculate new EFC and NEED
        -- If any of the above are set at the fund level, then calculte only that
        IF p_awds.replace_fc = 'Y' AND p_awds.update_need = 'Y' THEN
          l_rem_efc := NVL(l_efc,0) - NVL(p_awds.award,0);

          -- EFC cannot be less than zero as the contribution can be always greater than zero
          IF l_rem_efc < 0 THEN
            l_rem_efc := 0;
          END IF;

          -- Calculated the Remaining Need (update also the -ve EFC )
          l_need := NVL(l_need,0) - (NVL(p_awds.award,0) - (NVL(l_efc,0) - NVL(l_rem_efc,0)));

          -- l_need_VB_AC stores the Need without taking into account VA30 and Americorps awards.
          -- This is needed bcoz for subsidized loans (DLS, FLS), VA30 and Americorps awards should NOT be considered as a resource.
          IF p_awds.fed_fund_code NOT IN ('VA30', 'AMERICORPS') THEN
            l_need_VB_AC := NVL(l_need_VB_AC,0) - (NVL(p_awds.award,0) - (NVL(l_efc,0) - NVL(l_rem_efc,0)));
          ELSE
            -- Award is VA30/Americorps, l_need_VB_AC is NOT reduced
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'This is a VA30/AMERICORPS award. l_need_VB_AC is NOT touched');
            END IF;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Replace_EFC and Update_Need set in Fund Mgr for fund ' ||p_awds.fed_fund_code|| '. Updated EFC and Need.');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_rem_efc= ' ||l_rem_efc);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need= ' ||l_need);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need_VB_AC= ' ||l_need_VB_AC);
          END IF;

        ELSIF p_awds.replace_fc ='Y' THEN
          l_rem_efc := NVL(l_efc,0) - NVL(p_awds.award,0);

          IF l_rem_efc < 0 THEN
            l_need := l_need + l_rem_efc;
            l_rem_efc := 0;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Replace_EFC set in Fund Mgr for fund ' ||p_awds.fed_fund_code|| '. Updated EFC.');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_rem_efc= ' ||l_rem_efc);
          END IF;

        ELSIF p_awds.update_need = 'Y' THEN
          l_need := NVL(l_need,0) - NVL(p_awds.award,0);

          -- l_need_VB_AC stores the Need without taking into account VA30 and Americorps awards.
          -- This is needed bcoz for subsidized loans (DLS, FLS) VA30 and Americorps awards should NOT be considered as a resource.
          IF p_awds.fed_fund_code NOT IN ('VA30', 'AMERICORPS') THEN
            l_need_VB_AC := NVL(l_need_VB_AC,0) - NVL(p_awds.award,0);
          ELSE
            -- Award is VA30/Americorps, l_need_VB_AC is NOT reduced
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'This is a VA30/AMERICORPS award. l_need_VB_AC is NOT touched');
            END IF;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Update_Need set in Fund Mgr for fund ' ||p_awds.fed_fund_code|| '. Updated Need.');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need= ' ||l_need);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need_VB_AC= ' ||l_need_VB_AC);
          END IF;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'c_rem_efc%FOUND - so updating values with '||' l_need:'||l_need||' l_efc:'||l_efc||' l_rem_efc:'||l_rem_efc||' l_need_VB_AC: '||l_need_VB_AC);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'p_awds.replace_fc:'||p_awds.replace_fc||' p_awds.update_need:'||p_awds.update_need||'adplans_id:'||l_efc_cur.adplans_id);
        END IF;

        igf_aw_award_t_pkg.update_row(
                                      x_rowid              => l_efc_cur.row_id ,
                                      x_process_id         => l_efc_cur.process_id ,
                                      x_sl_number          => l_efc_cur.sl_number,
                                      x_fund_id            => l_efc_cur.fund_id,
                                      x_base_id            => l_efc_cur.base_id,
                                      x_offered_amt        => l_efc_cur.offered_amt,
                                      x_accepted_amt       => l_efc_cur.accepted_amt,
                                      x_paid_amt           => l_efc_cur.paid_amt,
                                      x_need_reduction_amt => l_efc_cur.need_reduction_amt,
                                      x_flag               => l_efc_cur.flag,
                                      x_temp_num_val1      => l_rem_efc,
                                      x_temp_num_val2      => l_need,
                                      x_temp_char_val1     => l_efc_cur.temp_char_val1,
                                      x_tp_cal_type        => l_efc_cur.tp_cal_type,
                                      x_tp_sequence_number => l_efc_cur.tp_sequence_number,
                                      x_ld_cal_type        => l_efc_cur.ld_cal_type,
                                      x_ld_sequence_number => l_efc_cur.ld_sequence_number,
                                      x_mode               => 'R',
                                      x_adplans_id         => l_efc_cur.adplans_id,
                                      x_app_trans_num_txt  => l_efc_cur.app_trans_num_txt,
                                      x_award_id           => l_efc_cur.award_id,
                                      x_lock_award_flag    => l_efc_cur.lock_award_flag,
                                      x_temp_val3_num      => l_need_VB_AC,
                                      x_temp_val4_num      => l_efc_cur.temp_val4_num,
                                      x_temp_char2_txt     => l_efc_cur.temp_char2_txt,
                                      x_temp_char3_txt     => l_efc_cur.temp_char3_txt
                                     );
        FETCH c_rem_efc INTO l_efc_cur;
      END LOOP;

    ELSIF  c_rem_efc%NOTFOUND  THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'c_rem_efc%NOTFOUND-so calculating values');
      END IF;

      -- Get the month for which EFC should be calcualted
      l_efc_months :=  igf_aw_coa_gen.coa_duration(p_base_id,g_awd_prd);
      IF l_efc_months > 12 OR l_efc_months < 0 THEN
        l_efc_months := 12;
      END IF;

      -- Get the EFC value for Federal Methodology
      igf_aw_packng_subfns.get_fed_efc(
                                       p_base_id,
                                       g_awd_prd,
                                       l_efc_f,
                                       l_dummy_efc,
                                       l_efc_ay
                                      );


      -- Get the EFC values from the Awarding PROFILE record.
      OPEN c_efc_i(p_base_id);
      FETCH c_efc_i INTO l_efc_i;
      IF c_efc_i%NOTFOUND THEN
        l_efc_i := NULL;
      END IF;
      CLOSE c_efc_i;


      -- If the Selected methodology is Emulate Fed then use Federal COA else use Institutional COA for calculating NEED
      -- This is an initial need without considering the existing awards, existing awards are seperated below
      l_need_f := NVL(p_coa_f,0) - NVL(l_efc_f,0);
      l_need_i := NVL(p_coa_f,0) - NVL(l_efc_i,0);
      l_need_VB_AC_f := l_need_f;
      l_need_VB_AC_i := l_need_i;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need_f= ' ||l_need_f|| ' l_need_i= ' ||l_need_i|| ' l_need_VB_AC_f= ' ||l_need_VB_AC_f|| ' l_need_VB_AC_i= ' ||l_need_VB_AC_i);
      END IF;

      -- Initialize to total efc
      -- This is an initial efc without considering the existing awards with replace FC, existing awards FC are seperated below
      l_rem_efc_f := NVL(l_efc_f,0);
      l_rem_efc_i := NVL(l_efc_i,0);

      IF p_coa_f IS NOT NULL AND l_efc_f IS NOT NULL AND p_coa_f > 0 AND p_coa_f < l_efc_f THEN
        l_rem_efc_f := p_coa_f;
      END IF;

      -- If Fund has both the Replcae EFC and Replace NEED are checked then calculate new EFC and NEED
      -- If any of the above are set at the fund level, then calculte only that
      IF NVL(p_awds.replace_fc,'N') = 'Y' AND NVL(p_awds.update_need,'N') = 'Y' THEN
        l_rem_efc_f := NVL(l_efc_f,0) - NVL(p_awds.award,0);
        l_rem_efc_i := NVL(l_efc_i,0) - NVL(p_awds.award,0);

        -- Always EFC cannot be lesser than ZERO
        IF l_rem_efc_f < 0 THEN
          l_rem_efc_f := 0;
        END IF;

        IF l_rem_efc_i < 0 THEN
          l_rem_efc_i := 0;
        END IF;

        -- Calculated the Remaining Need
        l_need_f := NVL(l_need_f,0) - (NVL(p_awds.award,0) - (NVL(l_efc_f,0) - NVL(l_rem_efc_f,0)));
        l_need_i := NVL(l_need_i,0) - (NVL(p_awds.award,0) - (NVL(l_efc_i,0) - NVL(l_rem_efc_i,0)));

        -- l_need_VB_AC_f/l_need_VB_AC_i stores the Need without taking into account VA30 and Americorps awards.
        -- This is needed bcoz for subsidized loans (DLS, FLS), VA30 and Americorps awards should NOT be considered as a resource.
        IF p_awds.fed_fund_code NOT IN ('VA30', 'AMERICORPS') THEN
          l_need_VB_AC_f := NVL(l_need_VB_AC_f,0) - (NVL(p_awds.award,0) - (NVL(l_efc_f,0) - NVL(l_rem_efc_f,0)));
          l_need_VB_AC_i := NVL(l_need_VB_AC_i,0) - (NVL(p_awds.award,0) - (NVL(l_efc_i,0) - NVL(l_rem_efc_i,0)));
        ELSE
          -- Award is VA30/Americorps, l_need_VB_AC_f/l_need_VB_AC_i is NOT reduced
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'This is a VA30/AMERICORPS award. l_need_VB_AC_f/l_need_VB_AC_i is NOT touched');
          END IF;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Replace_EFC and Update_Need set in Fund Mgr for fund ' ||p_awds.fed_fund_code|| '. Updated EFC and Need.');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_rem_efc_f= ' ||l_rem_efc_f|| ' l_rem_efc_i= ' ||l_rem_efc_i);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need_f= ' ||l_need_f|| ' l_need_i= ' ||l_need_i);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need_VB_AC_f= ' ||l_need_VB_AC_f|| ' l_need_VB_AC_i= ' ||l_need_VB_AC_i);
        END IF;

      -- If only Replace EFC is present
      ELSIF p_awds.replace_fc ='Y' THEN

        l_rem_efc_f := NVL(l_efc_f,0) - NVL(p_awds.award,0);
        IF l_rem_efc_f < 0 THEN
          l_need_f := l_need_f + l_rem_efc_f;
          l_rem_efc_f := 0;
        END IF;

        l_rem_efc_i := NVL(l_efc_i,0) - NVL(p_awds.award,0);
        IF l_rem_efc_i < 0 THEN
          l_need_i := l_need_i + l_rem_efc_i;
          l_rem_efc_i := 0;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Replace_EFC set in Fund Mgr for fund ' ||p_awds.fed_fund_code|| '. Updated EFC.');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_rem_efc_f= ' ||l_rem_efc_f|| ' l_rem_efc_i= ' ||l_rem_efc_i);
        END IF;

      -- If only Replace Need is present
      ELSIF p_awds.update_need ='Y' THEN

        l_need_f := NVL(l_need_f,0) - NVL(p_awds.award,0);
        l_need_i := NVL(l_need_i,0) - NVL(p_awds.award,0);

        -- l_need_VB_AC_f/l_need_VB_AC_i stores the Need without taking into account VA30 and Americorps awards.
        -- This is needed bcoz for subsidized loans (DLS, FLS), VA30 and Americorps awards should NOT be considered as a resource.
        IF p_awds.fed_fund_code NOT IN ('VA30', 'AMERICORPS') THEN
          l_need_VB_AC_f := NVL(l_need_VB_AC_f,0) - NVL(p_awds.award,0);
          l_need_VB_AC_i := NVL(l_need_VB_AC_i,0) - NVL(p_awds.award,0);
        ELSE
          -- Award is VA30/Americorps, l_need_VB_AC_f/l_need_VB_AC_i is NOT reduced
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'This is a VA30/AMERICORPS award. l_need_VB_AC_f/l_need_VB_AC_i is NOT touched');
          END IF;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Update_Need set in Fund Mgr for fund ' ||p_awds.fed_fund_code|| '. Updated Need.');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need_f= ' ||l_need_f|| ' l_need_i= ' ||l_need_i);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need_VB_AC_f= ' ||l_need_VB_AC_f|| ' l_need_VB_AC_i= ' ||l_need_VB_AC_i);
        END IF;
      END IF;

      fnd_message.set_name('IGF','IGF_AW_PKG_EFC_MONTH');
      fnd_message.set_token('MONTH',l_efc_months);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'fund Setup values are, Award ID : '||p_awds.award_id||' Fund Id: '||p_awds.fund_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,' p_awds.replace_fc : '||p_awds.replace_fc||' p_awds.update_need: '||p_awds.update_need);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'Calculated values are: '||' l_efc_months: '||l_efc_months);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,' l_efc_f:'||l_efc_f||' l_efc_i:'||l_efc_i||' l_rem_efc_f:'||l_rem_efc_f||' l_rem_efc_i:'||l_rem_efc_i);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'l_need_f:'||l_need_f||' l_need_i:'||l_need_i||' l_need_VB_AC_f:'||l_need_VB_AC_f|| ' l_need_VB_AC_i:' ||l_need_VB_AC_i);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'inserting calculated values into igf_aw_award_t with x_temp_char_val1=FEDERAL');
      END IF;
        -- insert the record into Temp table
        igf_aw_award_t_pkg.insert_row(
                                      x_rowid              => lv_rowid ,
                                      x_process_id         => l_process_id ,
                                      x_sl_number          => l_sl_number,
                                      x_fund_id            => NULL,
                                      x_base_id            => p_base_id,
                                      x_offered_amt        => NULL,
                                      x_accepted_amt       => NULL,
                                      x_paid_amt           => NULL ,
                                      x_need_reduction_amt => NULL,
                                      x_flag               => 'AA',      -- Allready awarded either manually or in prior runs.
                                      x_temp_num_val1      => l_rem_efc_f, -- efc to be passed
                                      x_temp_num_val2      => l_need_f,    -- need to be passed
                                      x_temp_char_val1     => 'FEDERAL',
                                      x_tp_cal_type        => NULL,
                                      x_tp_sequence_number => NULL,
                                      x_ld_cal_type        => NULL,
                                      x_ld_sequence_number => NULL,
                                      x_mode               => 'R',
                                      x_adplans_id         => NULL,
                                      x_app_trans_num_txt  => NULL,
                                      x_award_id           => NULL,
                                      x_lock_award_flag    => NULL,
                                      x_temp_val3_num      => l_need_VB_AC_f,
                                      x_temp_val4_num      => NULL,
                                      x_temp_char2_txt     => NULL,
                                      x_temp_char3_txt     => NULL
                                     );
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.calc_need.debug '|| g_req_id,'inserting  calculating values into igf_aw_award_t with x_temp_char_val1=INSTITUTIONAL');
        END IF;
        -- insert the record into Temp table
        igf_aw_award_t_pkg.insert_row(
                                      x_rowid              => lv_rowid ,
                                      x_process_id         => l_process_id ,
                                      x_sl_number          => l_sl_number,
                                      x_fund_id            => NULL,
                                      x_base_id            => p_base_id,
                                      x_offered_amt        => NULL,
                                      x_accepted_amt       => NULL,
                                      x_paid_amt           => NULL ,
                                      x_need_reduction_amt => NULL,
                                      x_flag               => 'AA',      -- Allready awarded either manually or in prior runs.
                                      x_temp_num_val1      => l_rem_efc_i, -- efc to be passed
                                      x_temp_num_val2      => l_need_i,    -- need to be passed
                                      x_temp_char_val1     => 'INSTITUTIONAL',
                                      x_tp_cal_type        => NULL,
                                      x_tp_sequence_number => NULL,
                                      x_ld_cal_type        => NULL,
                                      x_ld_sequence_number => NULL,
                                      x_mode               => 'R',
                                      x_adplans_id         => NULL,
                                      x_app_trans_num_txt  => NULL,
                                      x_award_id           => NULL,
                                      x_lock_award_flag    => NULL,
                                      x_temp_val3_num      => l_need_VB_AC_i,
                                      x_temp_val4_num      => NULL,
                                      x_temp_char2_txt     => NULL,
                                      x_temp_char3_txt     => NULL
                                     );


    END IF; -- Fetch IF
    CLOSE c_rem_efc;

    --
    -- The following logic stores the already awarded aid of the student INTO a plsql table
    -- It updates the plsql table to hold all the aid awarded for a student. This is used
    -- later in process_stud to calculate over award
    --

    l_cnt := g_awarded_aid.COUNT;

    -- If plsql table is not alread created, create it and load the Aid details
    IF NVL(l_cnt,0) = 0 THEN
      l_cnt := 1;
      g_awarded_aid.EXTEND(1);
      g_awarded_aid(l_cnt).base_id     := p_base_id;
      g_awarded_aid(l_cnt).need_f      := NVL(l_need_f,0);
      g_awarded_aid(l_cnt).awarded_aid := NVL(p_awds.award,0);

    -- If the table is already populated then search for that record and add increase the aid amount with the new award amount
    ELSIF l_cnt > 0 THEN
      l_cnt := 0;
      FOR i in 1..g_awarded_aid.COUNT LOOP
        l_cnt := l_cnt + 1;

        IF g_awarded_aid(i).base_id = p_base_id THEN

          g_awarded_aid(i).awarded_aid := g_awarded_aid(i).awarded_aid + NVL(p_awds.award,0);
          l_rec_fnd := TRUE;
          EXIT;

        ELSE
         l_rec_fnd := FALSE;
        END IF;

      END LOOP;

      -- If record is not found, then load the table with the Aid deatils
      IF NOT l_rec_fnd THEN
        l_cnt := l_cnt + 1;
        g_awarded_aid.EXTEND(1);
        g_awarded_aid(l_cnt).base_id     := p_base_id;
        g_awarded_aid(l_cnt).need_f      := NVL(l_need_f,0);
        g_awarded_aid(l_cnt).awarded_aid := NVL(p_awds.award,0);
      END IF;
    END IF;    -- End of logic to populate the student aid INTO plsql table
  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.calc_need.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      RAISE;
  END calc_need;

  FUNCTION hasActiveIsir(
                         p_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) RETURN NUMBER AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 14-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get active isir
  CURSOR c_active_isir IS
    SELECT isir_id
      FROM igf_ap_isir_matched_all
     WHERE base_id = p_base_id
       AND active_isir = 'Y';
  l_isir_id igf_ap_isir_matched_all.isir_id%TYPE;
  BEGIN
    l_isir_id := NULL;
    OPEN c_active_isir;
    FETCH c_active_isir INTO l_isir_id;
    CLOSE c_active_isir;
    RETURN l_isir_id;
  END hasActiveIsir;

  FUNCTION hasActiveProfile(
                            p_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                           ) RETURN NUMBER AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 14-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get active isir
  CURSOR c_active_profile IS
    SELECT cssp_id
      FROM igf_ap_css_profile_all
     WHERE base_id = p_base_id
       AND active_profile = 'Y';
  l_css_id igf_ap_css_profile_all.cssp_id%TYPE;
  BEGIN
    l_css_id := NULL;
    OPEN c_active_profile;
    FETCH c_active_profile INTO l_css_id;
    CLOSE c_active_profile;
    RETURN l_css_id;
  END hasActiveProfile;

  FUNCTION get_award_process_status(
                                    p_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                                    p_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                                    p_award_prd_code     igf_aw_awd_prd_term.award_prd_cd%TYPE,
                                    p_base_id            igf_ap_fa_base_rec_all.base_id%TYPE
                                  ) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 25-Oct-2004
  --
  --Purpose: Returns the award processing status for a student
  --         in a award year's awarding period
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_award_process_status IS
    SELECT DECODE(
              MAX(status_order),
              0, NULL,
              1, 'AWARDED',
              2, 'READY',
              3, 'REVIEW',
              4, 'DO_NOT_REPKG'
           ) award_processing_status
      FROM (SELECT awd.award_id,
                   awd_proc_status_code,
                   DECODE(
                      awd.awd_proc_status_code,
                      NULL, 0,
                      'AWARDED', 1,
                      'READY', 2,
                      'REVIEW', 3,
                      'DO_NOT_REPKG', 4
                   ) status_order
              FROM igf_aw_award_all awd,
                   igf_aw_fund_mast_all fmast
             WHERE fmast.ci_cal_type = p_ci_cal_type
               AND fmast.ci_sequence_number = p_ci_sequence_number
               AND awd.fund_id = fmast.fund_id
               AND awd.base_id = p_base_id
               AND NOT EXISTS(
                      SELECT disb.ld_cal_type,
                             disb.ld_sequence_number
                        FROM igf_aw_awd_disb_all disb
                       WHERE disb.award_id = awd.award_id
                      MINUS
                      SELECT ld_cal_type,
                             ld_sequence_number
                        FROM igf_aw_awd_prd_term apt
                       WHERE apt.ci_cal_type = p_ci_cal_type
                         AND apt.ci_sequence_number = p_ci_sequence_number
                         AND apt.award_prd_cd = p_award_prd_code));
  l_award_process_status igf_aw_award_all.awd_proc_status_code%TYPE;

  BEGIN
    l_award_process_status := NULL;
    OPEN c_award_process_status;
    FETCH c_award_process_status INTO l_award_process_status;
    IF c_award_process_status%FOUND THEN
      RETURN l_award_process_status;
    ELSE
      RETURN NULL;
    END IF;
  END get_award_process_status;

  PROCEDURE stud_run(
                     l_base_id        IN NUMBER,
                     l_post           IN VARCHAR2,
                     l_run_mode       IN VARCHAR2
                    ) IS
    /*
    ||  Created By : cdcruz
    ||  Created On : 14-NOV-2000
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who          WHEN            What
    ||  (reverse chronological order - newest change first)
    ||  veramach      20-NOV-2003    FA 125 multiple distribution methods
    ||                               Added call to check_plan and error out if check_plan returns failure
    ||  veramach      13-OCT2-03     FA 124 Build - Added logic to error out if a student does not have active ISIR in multiple fund packaging
    ||  rasahoo       27-Aug-2003    Removed call to get_oss_details as part of obsoletion of FA base record history.
    ||  rasahoo       23-Apl-2003      Bug # 2860836
    ||                               Added rollback  for resolving
    ||                               locking problem created by fund manager
    ||
    ||  cdcruz       05-Feb-2003     Bug # 2758804
    ||                               FACR105 - ISIR picked is the active ISIR-CURSOR c_get_isir
    ||
    ||  brajendr     08-Jan-2003     Bug # 2762648
    ||                               Removed Function validate_student_efc call as this validation is necessary only for Packaging Process
    ||
    ||  brajendr     08-Jan-2003     Bug # 2710314
    ||                               Added a Function validate_student_efc
    ||                               for checking the validity of EFC
    ||
    ||  brajendr     10-Dec-2002     Bug # 2701470
    ||                               Modified the logic for not validating the packaging status for single fund process
    ||
    ||  brajendr     18-OCT-2002     Bug # 2591643
    ||                               Modified the logic for fetching the Context ISIR
    */

    -- Get the student existing award Details

    CURSOR c_awds ( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE )
    IS
    SELECT awd.award_id,
           awd.offered_amt award,
           fm.fund_id fund_id,
           fm.replace_fc            replace_fc,
           fm.update_need           update_need,
           NVL(fm.entitlement,'N')  entitlement,
           fcat.fed_fund_code       fed_fund_code,
           fm.fm_fc_methd           fm_fc_methd
      FROM igf_aw_award_all         awd,
           igf_aw_fund_mast_all     fm,
           igf_aw_fund_cat_all      fcat
     WHERE base_id       = cp_base_id
       AND awd.fund_id   = fm.fund_id
       AND fm.fund_code  = fcat.fund_code
       AND awd.award_status IN ('ACCEPTED','OFFERED')
       AND awd.award_id NOT IN ( SELECT award_id
                                   FROM igf_aw_award_t
                                  WHERE base_id = cp_base_id
                                    AND process_id = l_process_id
                                    AND flag = 'AU'); -- AU is it is a candidate for repackaging

    l_awds  std_awards;

    -- Get the person Number for log
    CURSOR c_person_number( x_base_id igf_ap_fa_con_v.base_id%TYPE ) IS
    SELECT pe.party_number person_number, fa.packaging_status
      FROM igf_ap_fa_base_rec_all fa,
           hz_parties pe
     WHERE fa.base_id = x_base_id
       AND pe.party_id = fa.person_id;

    l_person_number c_person_number%ROWTYPE;

    -- Get the Base record details
    CURSOR c_fabase ( x_base_id  igf_ap_fa_base_rec.base_id%TYPE ) IS
    SELECT fabase.*
      FROM igf_ap_fa_base_rec fabase
     WHERE fabase.base_id = x_base_id;

    l_fabase c_fabase%ROWTYPE;

    -- Retrieves all the Formula Policies
    CURSOR c_frml_plcy(
                       x_group_cd           igf_aw_target_grp_all.group_cd%TYPE,
                       x_ci_cal_type        igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                       x_ci_sequence_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                      ) IS
    SELECT tgrp.*
      FROM igf_aw_target_grp_all tgrp
     WHERE tgrp.cal_type          = x_ci_cal_type
       AND tgrp.sequence_number   = x_ci_sequence_number
       AND tgrp.group_cd          = x_group_cd;

    l_frml_plcy c_frml_plcy%ROWTYPE;

    -- Get the funds from the Temp table which are not yet awarded
    CURSOR c_rem_fund(x_base_id  igf_ap_fa_base_rec.base_id%TYPE) IS
    SELECT COUNT(*)
      FROM igf_aw_award_t
     WHERE process_id = l_process_id
       AND base_id = x_base_id
       AND flag IN ('CF','AU');

    l_rem_cnt          NUMBER;
    l_coa_months       NUMBER;
    l_skip_fund        BOOLEAN;
    l_fund_fail        BOOLEAN;
    l_fund_id          igf_aw_fund_mast_all.fund_id%TYPE;
    l_aid              NUMBER(12,2);
    l_accepted_amt     NUMBER(12,2);
    l_seq_no           NUMBER;
    l_pers_num         igf_ap_fa_con_v.person_number%TYPE;
    lv_rowid           VARCHAR2(30);
    l_sl_number        NUMBER;
    l_chk              NUMBER;
    l_ret_status       VARCHAR2(3);


    lv_result      VARCHAR2(80) := NULL;
    lv_method_code VARCHAR2(80) := NULL;

    lv_name  igf_aw_awd_dist_plans.awd_dist_plan_cd_desc%TYPE        := NULL;
    lv_desc  igf_aw_awd_dist_plans_v.dist_plan_method_code_desc%TYPE := NULL;

    l_failed_award_id igf_aw_award_all.award_id%TYPE;

  BEGIN
    l_ret_status :='S';
    l_failed_award_id := NULL;

    get_process_id;

    -- Savepoint to Rollback changes if the base id raises Exception
    SAVEPOINT  STUD_SP;

    -- get person NUMBER for base id
    OPEN c_person_number(l_base_id );
    FETCH c_person_number INTO l_person_number;
    CLOSE c_person_number;
    l_pers_num := l_person_number.person_number;

    -- Log a message stating that : Process Person : Person Number
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'************* Student : '||l_person_number.person_number||' *************');
    END IF;
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'------------------------------------------------- ');
    fnd_message.set_name('IGF','IGF_AW_PROCESS_STUD');
    fnd_message.set_token('STUD', l_person_number.person_number );
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,'------------------------------------------------- ');


    -- Check for the valid EFC of the student. If no valid EFC, show message and stop processing
    IF g_sf_packaging <> 'T' THEN
      IF igf_aw_gen_005.validate_student_efc(l_base_id,g_awd_prd) = 'F' THEN
        fnd_message.set_name('IGF','IGF_AW_NO_VALID_EFC');
        fnd_message.set_token('STDNT', l_pers_num );
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'no valid efc for '||l_pers_num);
        END IF;
        RETURN;
      END IF;
    END IF;

    --check if student has awarding isir in multiple fund packaging.if not error out
    IF g_sf_packaging <> 'T' THEN

      IF hasActiveIsir(l_base_id) IS NULL THEN
        fnd_message.set_name('IGF','IGF_AW_NO_ISIR');
        fnd_message.set_token('STDNT',l_person_number.person_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'no active ISIR for '||l_person_number.person_number);
        END IF;
        RETURN;
      END IF;

      --Cbeck if student has valid COA in multiple fund packaging.if not error out

      IF NOT igf_aw_gen_003.check_coa(l_base_id,g_awd_prd) THEN
        fnd_message.set_name('IGF','IGF_AW_PK_COA_NULL');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'no COA for '||l_person_number.person_number);
        END IF;
        RETURN;
      END IF;
    END IF;

    IF g_sf_packaging = 'T' THEN

      IF g_allow_to_exceed IS NULL THEN
        -- If COA Value is not set, then cannot proceed further
        -- Log a message and exit from the Job
        IF NOT igf_aw_gen_003.check_coa(l_base_id,g_awd_prd) THEN

          --get the plan name for the token
          get_plan_desc(g_plan_id,lv_name,lv_desc);

          fnd_message.set_name('IGF','IGF_AW_COA_COMMON_TERMS_FAIL');
          fnd_message.set_token('PLAN_CD',lv_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'no COA for '||l_pers_num||' and allow_to_exceed=NULL');
          END IF;
          RETURN;
        END IF;

      ELSIF g_allow_to_exceed = 'NEED' THEN

        IF NOT igf_aw_gen_003.check_coa(l_base_id,g_awd_prd) THEN
          fnd_message.set_name('IGF','IGF_AW_PK_COA_NULL');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'no COA for '||l_person_number.person_number ||' and allow_to_exceed=NEED');
          END IF;
          RETURN;
        END IF;
      END IF;

    END IF;

    -- Initialize all the amounts
    l_grant_amt   :=0;
    l_loan_amt    :=0;
    l_work_amt    :=0;
    l_shelp_amt   :=0;
    l_gift_amt    :=0;
    l_schlp_amt   :=0;
    l_gap_amt     :=0;
    l_coa_months  :=0;
    l_efc_f       :=0;
    l_efc_i       :=0;
    l_pell_efc    :=0;

    -- This below LOOP will be executed for only once, Here is loop is used to come out the from the middle to the end of the logic
    OPEN c_fabase (l_base_id );
    LOOP
      FETCH c_fabase INTO l_fabase;
      EXIT WHEN c_fabase%NOTFOUND;

      -- Check whether are there any package hold are present at the student level, if not continue the packaging
      IF igf_aw_gen_005.get_stud_hold_effect('A', l_fabase.person_id, NULL ) = 'F'  THEN
        fnd_message.set_name('IGF','IGF_AW_AWD_PACK_HOLD_FAIL');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        CLOSE c_fabase;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'igf_aw_gen_005.get_stud_hold_effect(A,'||l_fabase.person_id||',NULL=F');
        END IF;
        RETURN;
      END IF;

      /*
        FA 152 Change - If award processing status for the student is not 'READY' or NULL,
        then skip the student.
      */
      IF get_award_process_status(l_fabase.ci_cal_type,l_fabase.ci_sequence_number,g_awd_prd,l_fabase.base_id) IN ('AWARDED','REVIEW','DO_NOT_REPKG') THEN
        fnd_message.set_name('IGF','IGF_AW_CANNOT_REPACKAGE');
        fnd_message.set_token('PERSON', l_person_number.person_number );
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RETURN;
      END IF;

      IF NVL(l_fabase.lock_awd_flag,'N') = 'Y' THEN
        fnd_message.set_name('IGF','IGF_AW_LOCK_AWD');
        fnd_message.set_token('PERSON', l_person_number.person_number );
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RETURN;
      END IF;
      -- Clear old simualted records for the student which were created in the previous run
      clear_simulation( l_base_id );

      /* Get the students COA Months. Get the students efc.  */
      l_efc_i := l_pell_efc;

      l_fabase.coa_f     := igf_aw_coa_gen.coa_amount(l_fabase.base_id,g_awd_prd);
      l_fabase.coa_i     := l_fabase.coa_f;
      l_fabase.coa_fixed := igf_aw_coa_gen.coa_amount(l_fabase.base_id,g_awd_prd,'Y');

      -- If the process is not run for the Single fund, then Load all Formula Group Policies
      -- Get all the overrides set at the formula levels and load the Temp table
      IF g_sf_packaging = 'F' THEN
        OPEN c_frml_plcy(
                         l_fabase.target_group,
                         l_fabase.ci_cal_type,
                         l_fabase.ci_sequence_number
                        );
        FETCH c_frml_plcy INTO l_frml_plcy;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'opened c_frml_policy');
        END IF;
        -- If Formula policys were not present then log a message and skip the formula checks
        IF c_frml_plcy%NOTFOUND THEN
          fnd_message.set_name('IGF','IGF_AW_PK_FRML_PLCY');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          CLOSE c_frml_plcy;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'no formula policies available');
          END IF;
          RETURN;
        END IF;
        CLOSE c_frml_plcy;

        IF ( l_run_mode = 'D') THEN
          fnd_message.set_name('IGF','IGF_AW_PKG_AWD_GRP');
          fnd_message.set_token('AWDGRP',l_fabase.target_group);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'after closing c_frml_policy packaging award group '||l_fabase.target_group);
          END IF;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'calling check_plan with adplans_id:'||l_frml_plcy.adplans_id);
        END IF;
        check_plan(l_frml_plcy.adplans_id,lv_result,lv_method_code);
        IF lv_result <> 'TRUE' THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'check_plan did not return true-it returned '||lv_result);
          END IF;
          fnd_message.set_name('IGF',lv_result);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RETURN;
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'check_plan returned TRUE with g_plan_id:'||g_plan_id||',g_method_cd:'||g_method_cd);
          END IF;
          g_plan_id     := l_frml_plcy.adplans_id;
          g_method_cd   := lv_method_code;
        END IF;

        -- Calculate the Max Loan Amt ( directly from the loan amt or from the % defined at the Frml Policy level)
        IF l_frml_plcy.max_loan_amt IS NOT NULL THEN
          l_loan_amt := l_frml_plcy.max_loan_amt;
        ELSIF l_frml_plcy.max_loan_perct IS NULL THEN
          l_loan_amt := 0;
        ELSE
          l_loan_amt := get_perct_amt(l_frml_plcy.max_loan_perct_fact,l_frml_plcy.max_loan_perct,l_base_id,igf_aw_gen_004.efc_f(l_base_id,g_awd_prd),g_awd_prd);
        END IF;

        -- Calculate the Max Grant Amt ( directly from the grant amt or grom the % defined at the Frml Policy level)
        IF l_frml_plcy.max_grant_amt IS NOT NULL THEN
          l_grant_amt := l_frml_plcy.max_grant_amt;

        ELSIF l_frml_plcy.max_grant_perct IS NULL THEN
          l_grant_amt := 0;
        ELSE
          l_grant_amt := get_perct_amt(l_frml_plcy.max_grant_perct_fact,l_frml_plcy.max_grant_perct,l_base_id,igf_aw_gen_004.efc_f(l_base_id,g_awd_prd),g_awd_prd);
        END IF;

        -- Calculate the Max Work Amt ( directly from the work amt or from the % defined at the Frml Policy level)
        IF l_frml_plcy.max_work_amt IS NOT NULL THEN
          l_work_amt := l_frml_plcy.max_work_amt;

        ELSIF l_frml_plcy.max_work_perct IS NULL THEN
          l_work_amt := 0;
        ELSE
          l_work_amt := get_perct_amt(l_frml_plcy.max_work_perct_fact,l_frml_plcy.max_work_perct,l_base_id,igf_aw_gen_004.efc_f(l_base_id,g_awd_prd),g_awd_prd);
        END IF;

        -- Calculate the Max Self Help Amt
        IF l_frml_plcy.max_shelp_amt IS NOT NULL THEN
          l_shelp_amt := l_frml_plcy.max_shelp_amt;

        ELSIF l_frml_plcy.max_shelp_perct IS NULL THEN
          l_shelp_amt := 0;
        ELSE
          l_shelp_amt := get_perct_amt(l_frml_plcy.max_shelp_perct_fact,l_frml_plcy.max_shelp_perct,l_base_id,igf_aw_gen_004.efc_f(l_base_id,g_awd_prd),g_awd_prd);
        END IF;

        -- Calculate the Max Gift Aid Amt
        IF l_frml_plcy.max_gift_amt IS NOT NULL THEN
          l_gift_amt := l_frml_plcy.max_gift_amt;

        ELSIF l_frml_plcy.max_gift_perct IS NULL THEN
          l_gift_amt := 0;
        ELSE
          l_gift_amt := get_perct_amt(l_frml_plcy.max_gift_perct_fact,l_frml_plcy.max_gift_perct,l_base_id,igf_aw_gen_004.efc_f(l_base_id,g_awd_prd),g_awd_prd);
        END IF;

        -- Calculate the Max Scholarship Amt
        IF l_frml_plcy.max_schlrshp_amt IS NOT NULL THEN
          l_schlp_amt := l_frml_plcy.max_schlrshp_amt;

        ELSIF l_frml_plcy.max_schlrshp_perct IS NULL THEN
          l_schlp_amt := 0;
        ELSE
          l_schlp_amt := get_perct_amt(l_frml_plcy.max_schlrshp_perct_fact,l_frml_plcy.max_schlrshp_perct,l_base_id,igf_aw_gen_004.efc_f(l_base_id,g_awd_prd),g_awd_prd);
        END IF;

        -- Calculate the Gap Amount
        IF l_frml_plcy.max_gap_amt IS NOT NULL THEN
          l_gap_amt := l_frml_plcy.max_gap_amt;
        ELSIF l_frml_plcy.max_gap_perct IS NULL THEN

          l_gap_amt := 0;
        ELSE
          l_gap_amt := get_perct_amt(l_frml_plcy.max_gap_perct_fact,l_frml_plcy.max_gap_perct,l_base_id,igf_aw_gen_004.efc_f(l_base_id,g_awd_prd),g_awd_prd);
        END IF;

        -- Get the Max Aid Package
        l_max_aid_pkg := l_frml_plcy.max_aid_pkg;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'data fetched from c_frml_policy l_loan_amt:'||l_loan_amt||' l_grant_amt:'||l_grant_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'l_work_amt:'||l_work_amt||' l_shelp_amt:'||l_shelp_amt||' l_gift_amt:'||l_gift_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'l_schlp_amt:'||l_schlp_amt||' l_gap_amt:'||l_gap_amt||' l_max_aid_pkg:'||l_max_aid_pkg);
        END IF;
      END IF; -- End if for Formula Policies

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'after calculating max limits for loan,etc.calling load_funds');
      END IF;
      -- Load all the Funds INTO the Tempoary Table with the flag 'CF'
      -- If running for single fund, it loads only that fund using the gloabal variable value

      load_funds(
                 l_fabase.target_group,
                 l_fabase.ci_cal_type,
                 l_fabase.ci_sequence_number,
                 l_fabase.base_id,
                 l_fabase.person_id
                );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'after calling load_funds, calling excl_incl_check');
      END IF;
      -- Check for Exclusive and Inclusive funds and get only valid ones INTO the Temp Table
      excl_incl_check( l_process_id, l_base_id , l_run_mode);

      /*
        FA 152 Changes.
        Need should be calculated after the awards are loaded into the temporary table.
        This ensures that awards which are candidates for repackaging are NOT considered
        for calculation of need. Modified CURSOR c_awds accordingly to select awards which cannot be re-packaged.
      */
      /* If Student is awarded already then his resources need to be considered
         Earlier logic of ignoring earlier awards is changed. Logic to calculate
         COA is also removed as the COA is now changed
      */

      -- Get all the awards which are already awarded to the students and update the Temp table
      -- with the fund details, EFC and Need with the status as 'AA' - Already Awarded
      OPEN c_awds( l_fabase.base_id);
      LOOP
        FETCH c_awds INTO l_awds;
        EXIT WHEN c_awds%NOTFOUND;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'opened c_awds for l_fabase.base_id:'||l_fabase.base_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'calling calc_need using l_fabase.coa_f:'||l_fabase.coa_f||' l_fabase.coa_i:'||l_fabase.coa_i);
        END IF;
        l_awds.award := igf_aw_coa_gen.award_amount(l_fabase.base_id,g_awd_prd,l_awds.award_id);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'Calling calc_need');
        END IF;
        calc_need(
                  l_fabase.base_id,
                  igf_aw_coa_gen.coa_amount(l_fabase.base_id,g_awd_prd),
                  l_awds
                 );
      END LOOP;
      CLOSE c_awds;

      -- Once all the data is set in the Temp table. Start awarding funds to the students

      l_chk := 0;
      LOOP  -- This loop is to repackage a student if a fund fails
        SAVEPOINT START_PACK;
        l_fund_fail := FALSE;

        IF l_chk = 0 THEN
          fnd_message.set_name('IGF','IGF_AW_PKG_EXCL_FND_CHK');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        ELSE
          fnd_file.put_line(fnd_file.log,' ');
          fnd_file.put_line(fnd_file.log,'------------------------------------------------- ');
          fnd_message.set_name('IGF','IGF_AW_PKG_EXCL_FND_RE_CHK');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'after calling excl_incl_check, calling process_stud with fund_id:'||l_fund_id);
        END IF;
        process_stud(
                     l_fabase,
                     l_frml_plcy.use_fixed_costs,
                     l_post,
                     l_run_mode,
                     l_fund_id,
                     l_seq_no,
                     l_failed_award_id,
                     l_fund_fail
                    );

        -- Fund failed for some reason. So repackage student
        IF ( l_fund_fail = TRUE ) THEN

          ROLLBACK TO START_PACK;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'after process_stud,fund '||l_fund_id||' failed');
          END IF;
          -- Delete failed fund from the Temp Table
          update_fund( l_fund_id, l_seq_no, l_process_id, l_base_id ,l_failed_award_id);

          -- Rerun Exclusive and Inclsive checks for remaining funds. This is necessary as there are
          -- chances that earlier rejected funds might get added/ existing funds might get removed,
          -- bcoz of the removal of the obove failed fund
          excl_incl_check( l_process_id, l_base_id, l_run_mode );

          -- Exit from the loop If there are no funds remaining in the Temp table for awarding to the student.
          OPEN c_rem_fund(l_fabase.base_id);
          FETCH c_rem_fund INTO l_rem_cnt;
          CLOSE c_rem_fund;

          IF NVL(l_rem_cnt,0) = 0 THEN
            EXIT;
          END IF;

        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'inside loop,after process_stud fund '||l_fund_id||' suceeded');
          END IF;
          EXIT;
        END IF;

        l_chk := l_chk +1;
        IF l_chk > 100 THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'inside loop,l_chk > 100.exiting loop');
          END IF;
          EXIT;
        END IF;

        EXIT WHEN l_fund_fail = FALSE;

      END LOOP;  -- End of loop that is used to repackage a student if a fund fails

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'after loop, calling post_award');
      END IF;
      -- Post the Award INTO the Actual tables
      -- Added g_upd_awd_notif_status parameter, as part of FACR008-Correspondence build,pmarada
      post_award(
                 l_fabase.base_id,
                 l_process_id,
                 l_post,
                 'P',
                 g_upd_awd_notif_status,
                 l_ret_status
                );
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'post_award returned successfully');
      END IF;
  IF l_ret_status = 'L' THEN
    ROLLBACK TO STUD_SP ;

       --FUND MANAGER HAS BEEN LOCKED SKIPPING STUDENT

      fnd_message.set_name('IGF', 'IGF_AW_AWARD_NOT_CREATED');
      fnd_file.put_line(fnd_file.output,fnd_message.get);

      fnd_message.set_name('IGF', 'IGF_AW_FUND_LOCK_ERR');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'fund has been locked');
      END IF;

    EXIT;

    ELSIF l_ret_status = 'E' THEN

      ROLLBACK TO STUD_SP;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.STUD_RUN ' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.stud_run.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');

   END IF;


  END LOOP; -- End of student loop
  CLOSE c_fabase;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'closed c_fabase. stud_run returning');
  END IF;
  EXCEPTION

    WHEN NON_MERGABLE_FUNDS THEN
      ROLLBACK TO STUD_SP;
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.put_line(fnd_file.log,fnd_message.get || igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER') || ' : ' || l_pers_num);
      fnd_file.new_line(fnd_file.log,1);

    WHEN INVALID_DISTR_PLAN THEN
      ROLLBACK TO STUD_SP;
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.put_line(fnd_file.log,fnd_message.get || igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER') || ' : ' || l_pers_num);
      fnd_file.new_line(fnd_file.log,1);

    WHEN INV_FWS_AWARD THEN
      ROLLBACK TO STUD_SP;
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.put_line(fnd_file.log,fnd_message.get || igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER') || ' : ' || l_pers_num);
      fnd_file.new_line(fnd_file.log,1);

    WHEN PELL_NO_REPACK THEN
      ROLLBACK TO STUD_SP;
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.put_line(fnd_file.log,fnd_message.get || igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER') || ' : ' || l_pers_num);
      fnd_file.new_line(fnd_file.log,1);

    WHEN OTHERS THEN
      ROLLBACK TO STUD_SP;
      fnd_file.put_line(fnd_file.log,SQLERRM);
      fnd_file.put_line(fnd_file.log,' ');
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.STUD_RUN ' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.stud_run.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.put_line(fnd_file.log,fnd_message.get || igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER') || ' : ' || l_pers_num);
      fnd_file.put_line(fnd_file.log,' ');

      -------------------------------------------------------------------------
      -- Important : Do not remove these comments
      -- APP_EXCEPTION.RAISE_EXCEPTION;
      -- As stud_run is called in loop; if a student fails any of the criteria
      -- then we should skip that record
      -- and proceed to the next record
      -- control should not come out NOCOPY at this point
      -- changes done for processing this record is rolled back
      -- upto savepoint STUD_SP

  END stud_run;

  FUNCTION isPhaseInParticipant(
                                p_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                                p_ci_sequence_number igs_ca_inst.sequence_number%TYPE
                               ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 25-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get pell participation type
  CURSOR c_pell_particip(
                         cp_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                         cp_ci_sequence_number igs_ca_inst.sequence_number%TYPE
                        ) IS
    SELECT pell_participant_code
      FROM igf_ap_batch_aw_map_all
     WHERE ci_cal_type = cp_ci_cal_type
       AND ci_sequence_number = cp_ci_sequence_number;
   l_pell_participant_code  igf_ap_batch_aw_map_all.pell_participant_code%TYPE;

  BEGIN
    l_pell_participant_code := NULL;
    OPEN c_pell_particip(p_ci_cal_type,p_ci_sequence_number);
    FETCH c_pell_particip INTO l_pell_participant_code;
    CLOSE c_pell_particip;
    IF l_pell_participant_code = 'PHASE_IN_PARTICIPANT' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END isPhaseInParticipant;

  PROCEDURE process_stud(
                         l_fabase          IN  igf_ap_fa_base_rec%ROWTYPE,
                         l_use_fixed_costs IN  VARCHAR2,
                         l_post            IN  VARCHAR2,
                         l_run_mode        IN  VARCHAR2,
                         l_fund_id         OUT NOCOPY NUMBER,
                         l_seq_no          OUT NOCOPY NUMBER,
                         l_award_id        OUT NOCOPY NUMBER,
                         l_fund_fail       OUT NOCOPY BOOLEAN
                        ) IS
    /*
    ||  Created By : avenkatr
    ||  Created On : 11-JUN-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  museshad        15-Jun-2005     Build# FA157 - Bug# 4382371.
    ||                                  1)Added the parameters - awarding period, 'PACKAGING' in the call to
    ||                                  igf_aw_packng_subfns.check_loan_limits(). This procedure computes
    ||                                  the class standing. These two parameters are added, so that it
    ||                                  gets the Class Standing from anticipated data, if actual data is
    ||                                  not available. Note, that as of now only the Packaging process
    ||                                  passes these two parameters.
    ||                                  2) Modified the award amount rounding logic
    ||  veramach        14-Jun-2004     bug 3684031 - Added a check in cursor 'cur_fund_awd_exist' so that cancelled awards
    ||                                  are reconsidered while awarding
    ||  veramach        08-Dec-2003     FA 131 COD Updates
    ||                                  Added validations so that the pell wrapper is called with different parameters
    ||                                  when student has COA and student does not have COA
    ||                                  This is required for the pell wrapper to distribute the award
    ||  veramach        03-Dec-2003     FA 131 COD Updates
    ||                                  Modifies the pell wrapper used to calculate pell award amount
    ||  veramach        20-NOV-2003     FA 125 Build - cursor c_fund selects adplans_id also
    ||                                  cursor c_get_term_prsnt uses adplans_id instead of fund_id to find matching terms %
    ||                                  c_awd_grp cursor selects adplans_id
    ||  veramach        13-OCT-2003     FA 124 Build - Added logic as specified in the logic flow specified in the TD
    ||  rasahoo         01-09-2003      Removed Cursor C_ENROLL_STATUS  as part of FA-114 (Obsoletion
    ||                                  of base record history)
    ||  brajendr        09-Dec-2002     Bug # 2676394
    ||                                  Modified the logic for calculating the EFC value. Code for retriving
    ||                                  the value from efc_det table is replaced with igf_aw_packng_subfns.get_fed_efc
    ||
    ||  ssawhney        31october       introduce check for FSEOG matching fund percentage
    ||  (reverse chronological order - newest change first)
    */

    -- Retrieves all the funds that are part of the Formula Code in Sequence
    -- It has a link to igf_aw_award_t with a flag = 'CF' ie the valid funds
    CURSOR c_fund(
                  x_group_code         igf_aw_target_grp_all.group_cd%TYPE,
                  x_ci_cal_type        igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                  x_ci_sequence_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                  x_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                  x_process_id         NUMBER
                 ) IS
    SELECT TO_NUMBER(awt.temp_char_val1) seq_no,
           awt.fund_id fund_id,
           awt.temp_val3_num max_award_amt,
           awt.temp_val4_num min_award_amt,
           awt.adplans_id adplans_id,
           fmast.replace_fc replace_fc,
           fmast.fund_code,
           awt.lock_award_flag,
           fmast.fm_fc_methd,
           fcat.fund_source fund_source,
           awt.award_id,
           awt.offered_amt
      FROM igf_aw_award_t awt,
           igf_aw_fund_mast_all fmast,
           igf_aw_fund_cat_all fcat
     WHERE awt.fund_id     = fmast.fund_id
       AND fmast.fund_code = fcat.fund_code
       AND awt.base_id     = x_base_id
       AND awt.flag        IN ('CF','AU')
       AND process_id      = l_process_id
       AND g_sf_packaging  = 'F'

    UNION
    SELECT 1 seq_no,
           fmast.fund_id fund_id,
           max_award_amt,
           min_award_amt,
           awt1.adplans_id,
           replace_fc,
           fmast.fund_code,
           awt1.lock_award_flag,
           fmast.fm_fc_methd,
           fcat.fund_source fund_source,
           awt1.award_id,
           awt1.offered_amt
      FROM igf_aw_fund_mast_all fmast ,
           igf_aw_award_t awt1,
           igf_aw_fund_cat_all fcat
     WHERE g_sf_packaging  = 'T'
       AND fmast.fund_id   = g_sf_fund
       AND fmast.fund_id   = awt1.fund_id
       AND fmast.fund_code = fcat.fund_code
       AND awt1.flag       IN ('CF','AU')
       AND awt1.process_id = x_process_id
       AND awt1.base_id    = x_base_id
     ORDER BY 1;

    l_fund c_fund%ROWTYPE;

    -- Retrieves fund Properties
    CURSOR c_fmast ( cp_fund_id igf_aw_fund_mast.fund_id%TYPE ) IS
      SELECT fmast.*,
             fcat.fund_type,
             fcat.fund_source,
             fcat.fed_fund_code,
             fcat.sys_fund_type,
             'Y' emulate_fed,
             DECODE(fmast.fm_fc_methd,'INSTITUTIONAL','Y','N') inst_method
       FROM igf_aw_fund_mast_all fmast ,
            igf_aw_fund_cat fcat
      WHERE fmast.fund_id  = cp_fund_id
        AND fcat.fund_code = fmast.fund_code;

    l_fmast c_fmast%ROWTYPE;

    -- Gets the Total amount awarded for a fund from the temporary table
    CURSOR c_temp(
                  x_process_id   igf_aw_award_t.process_id%TYPE ,
                  x_fund_id      igf_aw_award_t.fund_id%TYPE,
                  x_base_id      igf_aw_award_t.base_id%TYPE
                 ) IS
    SELECT NVL(SUM(offered_amt),0) offered
      FROM igf_aw_award_t awdt
     WHERE awdt.base_id    = x_base_id
       AND awdt.fund_id    = x_fund_id
       AND awdt.process_id = x_process_id
       AND awdt.flag       = 'AW';

    l_temp c_temp%ROWTYPE;

    -- Check whether the fund is resulted in over award or not
    CURSOR c_cur_ovr_awd ( x_fund_id igf_aw_fund_mast.fund_id%TYPE ) IS
    SELECT awdt.*
      FROM igf_aw_award_t awdt
     WHERE awdt.fund_id = x_fund_id
       AND flag = 'OV'
       AND process_id = l_process_id;

    l_cur_ovr_awd c_cur_ovr_awd%ROWTYPE;

    -- Get the Pell Attendance code for a given attendance type
    CURSOR c_enrollment (cp_derived VARCHAR2) IS
    SELECT pell_att_code
      FROM igf_ap_attend_map
     WHERE attendance_type = cp_derived;

    l_enroll_st_rec     c_enrollment%ROWTYPE;
    l_enroll_st_rec_d   c_enrollment%ROWTYPE;

    -- Enhancement bug no 1818617, pmarada
    -- Get the Maximum Year Amount which is award to a student for a given fund
    -- ???? Common Terms
    CURSOR c_max_yr_amt(
                        cp_fund_id  igf_aw_award_all.fund_id%TYPE,
                        cp_base_id  igf_aw_award_all.base_id%TYPE
                       ) IS
    SELECT SUM(disb.disb_gross_amt) yr_total
      FROM igf_aw_awd_disb_all  disb,
           igf_aw_award_all     awd,
           igf_aw_fund_mast_all fmast
     WHERE disb.award_id            = awd.award_id
       AND fmast.fund_id            = awd.fund_id
       AND fmast.fund_id            = cp_fund_id
       AND awd.base_id              = cp_base_id
       AND awd.award_status IN ('OFFERED','ACCEPTED')
       AND disb.trans_type <> 'C';

    l_max_yr_amt c_max_yr_amt%ROWTYPE;

    --Cursor to fetch the Person Number for the base id.
    CURSOR c_person_number( cp_base_id igf_ap_fa_base_rec.base_id%TYPE ) IS
    SELECT pe.party_number person_number
      FROM hz_parties pe,
           igf_ap_fa_base_rec_all fabase
     WHERE fabase.base_id = cp_base_id
       AND pe.party_id = fabase.person_id;

    l_person_number  c_person_number%ROWTYPE;

--
-- Gets the max amt + max terms the student got a fund in a lifetime
--
    -- ???? Common Terms
    CURSOR cur_max_lf_count ( cp_fund_code   igf_aw_fund_mast_all.fund_code%TYPE ,
                              cp_person_id   igf_ap_fa_base_rec_all.person_id%TYPE)
    IS
    SELECT
    NVL(SUM(NVL(disb.disb_gross_amt,0)),0) lf_total,
    COUNT(DISTINCT awd.award_id)      lf_count
    FROM
    igf_aw_awd_disb_all  disb,
    igf_aw_award_all     awd,
    igf_aw_fund_mast_all fmast,
    igf_ap_fa_base_rec_all fabase
    WHERE fmast.fund_code  = cp_fund_code
      AND disb.award_id    = awd.award_id
      AND awd.fund_id      = fmast.fund_id
      AND awd.base_id      = fabase.base_id
      AND fabase.person_id = cp_person_id
      AND disb.trans_type <> 'C'
      AND awd.award_status IN ('OFFERED', 'ACCEPTED');

    max_lf_count_rec      cur_max_lf_count%ROWTYPE;

--
-- Cursor to Aggregate Award and Count
--
    CURSOR cur_agg_lf_count ( cp_fund_code   igf_aw_fund_mast_all.fund_code%TYPE ,
                              cp_person_id   igf_ap_fa_base_rec_all.person_id%TYPE)
    IS
    SELECT NVL(SUM(NVL(awd.offered_amt,0)),0) lf_total,
           COUNT(awd.award_id)           lf_count
      FROM igf_aw_award_all          awd,
           igf_aw_fund_mast_all      fmast,
           igf_ap_fa_base_rec        fabase,
           igf_ap_batch_aw_map_all   bam
    WHERE fmast.fund_code  = cp_fund_code
      AND awd.fund_id      = fmast.fund_id
      AND awd.base_id      = fabase.base_id
      AND fabase.person_id = cp_person_id
      AND fabase.ci_cal_type         = bam.ci_cal_type
      AND fabase.ci_sequence_number  = bam.ci_sequence_number
      AND awd.award_status IN ('OFFERED', 'ACCEPTED')
      AND bam.award_year_status_code IN ('LA','LE');

    agg_lf_count_rec      cur_agg_lf_count%ROWTYPE;

    -- Get all the funds from te temp table whose consolidated records are calculated
    CURSOR c_awd_grp_funds(
                           x_fund_id    igf_aw_award_t.fund_id%TYPE,
                           x_base_id    igf_aw_award_t.base_id%TYPE,
                           x_process_id igf_aw_award_t.process_id%TYPE
                          ) IS
    SELECT awdt.row_id row_id
      FROM igf_aw_award_t awdt
     WHERE awdt.process_id = x_process_id
       AND awdt.base_id    = x_base_id
       AND awdt.fund_id    = x_fund_id
       AND flag = 'AW';

    l_awd_grp_funds c_awd_grp_funds%ROWTYPE;
/*
    -- ssawhney FISAP DLD
    -- first cursor to get the fund matching method and percentage details.
    -- it is assumed that there will always be only one record in the FA SETUP
    -- CURSOR c_match_method IS
    -- SELECT fa.fseog_match_mthd, fa.fseog_fed_pct
    --  FROM igf_ap_fa_setup fa;

    -- l_method_rec c_match_method%ROWTYPE;

    -- now select whether there is any FSEOG Fund Type in the passed combination of
    -- of process_id and base_id, No need to check for calendar details.
    CURSOR c_find_fseog(
                        cp_base_id  igf_aw_award_t.base_id%TYPE ,
                        cp_process_id igf_aw_award_t.process_id%TYPE
                       ) IS
    SELECT COUNT(*) cnt, fm.fund_id
      FROM igf_aw_fund_mast_all fm,
           igf_aw_fund_cat_all ca
     WHERE fm.fund_code = ca.fund_code
       AND ca.fed_fund_code ='FSEOG'
       AND fm.fund_id IN ( SELECT awdt.fund_id
                             FROM igf_aw_award_t awdt
                            WHERE awdt.process_id = cp_process_id
                              AND awdt.base_id    = cp_base_id )
     GROUP BY fm.fund_id;

     l_fseog_rec c_find_fseog%ROWTYPE;

    -- now get the matching fund ids for the FSEOG Fund in that award year
    -- note this table will have all match funds for the FSEOG fund type in that award yr
    -- but it doesnt store the FSEOG Fund_id
    CURSOR c_find_match(
                        cp_ci_cal_type        igf_aw_fseog_match.ci_cal_type%TYPE,
                        cp_ci_sequence_number igf_aw_fseog_match.ci_sequence_number%TYPE
                       ) IS
    SELECT fsm.fund_id
      FROM igf_aw_fseog_match fsm
     WHERE fsm.ci_cal_type = cp_ci_cal_type
       AND fsm.ci_sequence_number = cp_ci_sequence_number
     ORDER BY fsm.fund_id;

    -- get the sum of offered amout of fund passed as variable.
    CURSOR c_get_fund_sum(
                          cp_fund_id igf_aw_award_t.fund_id%TYPE ,
                          cp_base_id  igf_aw_award_t.base_id%TYPE ,
                          cp_process_id igf_aw_award_t.process_id%TYPE
                         ) IS
    SELECT NVL(SUM(awdt.offered_amt),0) offered_amt
      FROM igf_aw_award_t awdt
     WHERE awdt.fund_id= cp_fund_id
       AND awdt.process_id = cp_process_id
       AND awdt.base_id    = cp_base_id
       AND awdt.flag = 'AW'
     UNION ALL
    SELECT NVL(SUM(awd.offered_amt),0) offered_amt
      FROM igf_aw_award_all awd
     WHERE awd.fund_id = cp_fund_id
       AND awd.base_id=cp_base_id
       AND award_status NOT IN ('DECLINED','CANCELLED','STOPPED');
commented for FISAP
*/

    -- Get the remaining EFC of the student from the Temp Table
    CURSOR c_rem_efc IS
    SELECT *
      FROM igf_aw_award_t
     WHERE process_id = l_process_id
       AND base_id    = l_fabase.base_id
       AND flag IN ('ND','AA');

    l_rem_efc   c_rem_efc%ROWTYPE;

    --
    -- Get the total number of NON Simulated Awards of a student  for a fund
    -- This cursor is used to know if the person is having awards from the
    -- fund, if there are awards then do not re-package
    --     -- ???? Common Terms
    CURSOR cur_fund_awd_exist (cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
                               cp_base_id igf_aw_award_all.base_id%TYPE)
    IS
    SELECT COUNT(award_id) cnt
      FROM igf_aw_award_all
     WHERE base_id = cp_base_id
       AND fund_id = cp_fund_id
       AND award_status NOT IN ('SIMULATED','CANCELLED');

    l_chk_fund          NUMBER;

    -- Get all the Loan Awards of the students which were already awarded or yet to be awarded
    CURSOR c_std_ln_awd(
                        cp_base_id  igf_ap_fa_base_rec.base_id%TYPE,
                        cp_process_id igf_aw_award_t.process_id%TYPE
                       ) IS
    SELECT fcat.fund_code fund_code,
           fed_fund_code,
           NVL(awd.offered_amt,0) offered_amt ,
           award_date
      FROM igf_aw_award_all awd,
           igf_aw_fund_mast_all fm,
           igf_aw_fund_cat_all fcat
     WHERE awd.award_status IN ('OFFERED','ACCEPTED')
       AND awd.base_id = cp_base_id
       AND awd.fund_id = fm.fund_id
       AND fm.fund_code = fcat.fund_code
       AND fcat.fed_fund_code IN ('FLS','FLU','DLS','DLU')
       AND awd.award_id NOT IN (SELECT award_id
                                  FROM igf_aw_award_t
                                 WHERE award_id IS NOT NULL
                                   AND base_id = cp_base_id
                                   AND process_id = cp_process_id
                                   AND flag IN ('AU','AW'))
    /* Fetches all awards that are not getting repackaged */
     UNION
    SELECT fcat.fund_code fund_code,
           fed_fund_code,
           NVL(awdt.offered_amt,0),
           SYSDATE award_date
      FROM igf_aw_Award_t awdt,
           igf_aw_fund_mast_all fmt,
           igf_aw_fund_cat_all fcat
     WHERE awdt.base_id = cp_base_id
       AND awdt.process_id = cp_process_id
       AND awdt.fund_id = fmt.fund_id
       AND awdt.flag = 'AW'
       AND fmt.fund_code = fcat.fund_code
       AND fcat.fed_fund_code IN ('FLS','FLU','DLS','DLU');
    /* Fetches all awards that have been awarded or got repackaged */

    l_std_ln_awd_rec   c_std_ln_awd%ROWTYPE;

    -- Get the details of term percent
    CURSOR c_get_term_prsnt(
                            cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                            cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE
                           ) IS
      SELECT terms.ld_perct_num,
             terms.ld_cal_type,
             terms.ld_sequence_number
        FROM igf_aw_dp_terms terms
       WHERE terms.adplans_id = cp_adplans_id
         AND EXISTS (SELECT ld_cal_type,
                            ld_sequence_number
                       FROM igf_aw_coa_itm_terms coat
                      WHERE coat.base_id = cp_base_id
                        AND coat.ld_cal_type = terms.ld_cal_type
                        AND coat.ld_sequence_number = terms.ld_sequence_number
                    );
    lc_get_term_prsnt  c_get_term_prsnt%ROWTYPE;


    TYPE awd_grp_rec IS RECORD(
                               fund_id       igf_aw_fund_mast.fund_id%TYPE,
                               fund_Code     igf_aw_fund_mast_v.fund_code%TYPE,
                               offered_amt   igf_aw_award_t.offered_amt%TYPE,
                               accepted_amt  igf_aw_award_t.accepted_Amt%TYPE,
                               total         NUMBER,
                               seq_no        igf_aw_awd_frml_det.seq_no%TYPE,
                               adplans_id    igf_aw_awd_dist_plans.adplans_id%TYPE,
                               award_id      igf_aw_award_all.award_id%TYPE,
                               lock_award_flag igf_aw_award_all.lock_award_flag%TYPE
                              );

    l_awd_grp    awd_grp_rec;
    TYPE awd_grp IS REF CURSOR RETURN awd_grp_rec;

    TYPE efc_cur IS REF CURSOR;


    l_need_set         BOOLEAN;
    l_need             NUMBER(12,2) := 0;
    l_need_f           NUMBER(12,2) := 0;
    l_need_VB_AC_f     NUMBER(12,2) := 0;
    l_need_bkup_f      NUMBER(12,2) := 0;
    l_need_i           NUMBER(12,2) := 0;
    l_need_VB_AC_i     NUMBER(12,2) := 0;
    l_need_bkup_i      NUMBER(12,2) := 0;
    l_net_need_f       NUMBER(12,2) := 0;
    l_net_need_i       NUMBER(12,2) := 0;
    l_rem_rep_efc_f    NUMBER(12,2) := 0;
    l_rem_rep_efc_i    NUMBER(12,2) := 0;
    l_old_need         NUMBER(12,2) := 0;
    l_fund_total       NUMBER(12,2) := 0;
    l_aid              NUMBER       := 0;   -- Changed this from NUMBER(12,2) to NUMBER
    l_remaining_amt    NUMBER(12,2) := 0;
    l_overaward        NUMBER(12,2) := 0;
    l_accepted_amt     NUMBER(12,2) := 0;
    l_actual_aid       NUMBER(12,2) := 0;
    l_total_fund_amnt  NUMBER(12,2) := 0;
    l_round_tol_ant    NUMBER(12,2) := 0;
    lv_rowid           VARCHAR2(25);
    l_sl_number        NUMBER(15);
    l_found            BOOLEAN;
    l_match_fund_id    igf_aw_award_t.fund_id%TYPE;
    l_total_match_amnt NUMBER(12,2) := 0;
    l_match_sum        NUMBER(12,2) := 0;
    l_est_match_amnt   NUMBER(12,2) := 0;
    l_efc_cur          efc_cur;
    l_efc_qry          VARCHAR2(1500);
    l_efc              igf_ap_isir_matched.paid_efc%TYPE  := 0;
    l_pell_efc         igf_ap_isir_matched.paid_efc%TYPE  := 0;
    l_emulate_fed      VARCHAR2(30);
    l_inst_method      VARCHAR2(30);
    l_efc_months       NUMBER;
    l_rem_rep_efc      NUMBER;
    l_cnt              NUMBER := 0;
    l_rec_fnd          BOOLEAN := FALSE;
    c_awd_grp          awd_grp;
    l_std_loan_tab     igf_aw_packng_subfns.std_loan_tab := igf_aw_packng_subfns.std_loan_tab();
    l_reccnt           NUMBER := 0;
    l_msg_name         fnd_new_messages.message_name%TYPE;
    ln_award_perct     NUMBER(5,2) := 100;      -- To store the common terms percentage
    l_efc_ay           NUMBER := 0;
    l_reset_need       BOOLEAN := FALSE;
    lv_prof_value        VARCHAR2(10);

    -- Find if student already has FM awards
    CURSOR c_fm_awards(
                        cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_process_id igf_aw_award_t.process_id%TYPE
                      ) IS
    SELECT fmast.fm_fc_methd fm_fc_methd
    FROM igf_aw_fund_mast_all fmast,
         igf_aw_award_all awd
    WHERE awd.fund_id = fmast.fund_id
    AND   awd.base_id=cp_base_id
    AND fmast.fm_fc_methd = 'FEDERAL'
    UNION
    SELECT awd_t.temp_char_val1 fm_fc_methd
    FROM igf_aw_award_t awd_t
    WHERE awd_t.base_id = cp_base_id
    AND awd_t.temp_char_val1 = 'FEDERAL'
    and awd_t.flag = 'AA'
    and awd_t.process_id = cp_process_id;

    l_fm_awards c_fm_awards%ROWTYPE;

    l_existing_awards NUMBER := 0;

    lv_result       VARCHAR2(80);
    lv_method_code  igf_aw_awd_dist_plans.dist_plan_method_code%TYPE;
    lv_method_name  igf_aw_awd_dist_plans.awd_dist_plan_cd_desc%TYPE;
    lv_method_desc  igf_aw_awd_dist_plans_v.dist_plan_method_code_desc%TYPE;

    ln_com_perct    NUMBER;

    l_pell_seq_id    igf_gr_pell_setup_all.pell_seq_id%TYPE;
    lv_message       fnd_new_messages.message_text%TYPE;
    lv_return_status VARCHAR2(10);
    l_pell_schedule_code igf_aw_award_all.alt_pell_schedule%TYPE;

    lv_called_from   VARCHAR2(80);
    lb_coa_defined   BOOLEAN;


    CURSOR c_temp_awd(
                      cp_award_id igf_aw_award_all.award_id%TYPE
                     ) IS
      SELECT *
        FROM igf_aw_award_t
       WHERE award_id = cp_award_id
         AND process_id = l_process_id
         AND flag = 'AU';
    l_temp_awd c_temp_awd%ROWTYPE;

    CURSOR cur_term_amounts(
                            p_award_id NUMBER
                           ) IS
      SELECT disb.ld_cal_type,
             disb.ld_sequence_number,
             disb.base_attendance_type_code,
             SUM(disb.disb_gross_amt) term_total,
             awd.adplans_id
        FROM igf_aw_awd_disb_all disb,
             igf_aw_award_all    awd
       WHERE awd.award_id = disb.award_id
         AND awd.award_id = p_award_id
       GROUP BY disb.ld_cal_type,
                disb.ld_sequence_number,
                disb.base_attendance_type_code,
                awd.adplans_id;
    l_term_aid NUMBER;

    -- Get first disb date for a term
    CURSOR c_first_disb_dt(
                           cp_award_id             igf_aw_award_all.award_id%TYPE,
                           cp_ld_cal_type          igs_ca_inst.cal_type%TYPE,
                           cp_ld_sequence_number   igs_ca_inst.sequence_number%TYPE
                          ) IS
      SELECT disb_date,
             tp_cal_type,
             tp_sequence_number
        FROM igf_aw_awd_disb_all
       WHERE award_id = cp_award_id
         AND ld_cal_type = cp_ld_cal_type
         AND ld_sequence_number = cp_ld_sequence_number
         AND ROWNUM = 1
       ORDER BY disb_date;
    l_first_disb_dt    c_first_disb_dt%ROWTYPE;
    l_term_start  DATE;
    l_term_end    DATE;
    lv_msg_text             VARCHAR2(2000);
    ln_msg_index            NUMBER;

    l_pell_setup_rec igf_gr_pell_setup_all%ROWTYPE;
    l_pell_attend_type VARCHAR2(30);
    l_message fnd_new_messages.message_text%TYPE;
    l_return_status    VARCHAR2(30);
    l_program_cd       igs_en_stdnt_ps_att.course_cd%TYPE;
    l_program_version  igs_en_stdnt_ps_att.version_number%TYPE;

  BEGIN

    /*
      Do All the fund checks, Pick all the funds from the the Award Formulas and Temp table if the
      Trarget groups are mentioned else pick the fund details from the fund manager and temp table.
      ( Here Temp table contains all the funds which need be awarded for the student)

      1. For each fund from the above cursor get the fund details from the fund master.
      2. Check whether the fund is present in the fund master, if not present then skip the fund  with log message.
      3. If the fund is not allowed for auto packaging then skip the fund with log message.
      4. If the fund is already awarded to the student ( NON SIMULATED ) then skip the fund with the log message.
      5. If the fund is not having Teaching Periods defined for all the load calendars, then skip the fund with the log message
      6. Calculate the EFC, Remaining EFC and Need for the student for the given federal method. If these details are not present
         for the student in the Temp table then calculate these and insert also into Temp table with flag as 'ND'
      7. If the context fund is PELL, then get the PELL award amount form the PELL Regular or Alternate Matrix
         And do all the entilement checks etc
         a. If fund is Entitlement, then the student will get the awarded aid irrespective of target group level max limits.
            and for non Entitlement funds group level limits should be enforced ( Bug 3400556 ). At the same time update the running totals
            The following check are performed
              i. Check for the Max Grant Amount limit
             ii. Check for the Max Self Help Amount limit
            iii. Check for the Max Gift Aid Amount limit
             iv. Check for the Max Scholarship Amount limit
              v. Check whether the award aid amount is crosing Max slab amount
         b. If the fund package status is accepted, then update the accepted amount of the award
         c. Set the Global award percentage to 100 as we are not considering the common terms for PELL.
      8. If the fund is NOT PELL then
         a. Check whether the student is still having the Need, if not having and fund is
            not entilement or not replace FC then skip the fund and start awarding.
         b. Get the total awarding amount for the context fund. ( Sum up from the temp table with the flag = 'AW' for the fund id + base id )
         c. Get the Max amount limits defined at the fund level or target group level and award the student with that amount.
         d. Decrease the Awarded Aid upto the extent of the common terms present at the COA Items and at the FUND.
            Sum up all the percentages for the common terms and set to global variable.
         e. If the Replace EFC is set for the fund and it is not already awarded then update students need. (Replace for the fund can
            be considered only once for the fund. this check is not present for PELL as pell can be awarded only once for a student)
         f. Check whether the award can be given with the overaward limit defined at the fund if the available amount defined at
            the fund is vanished. ( This is making use of execeeding fund limits with the over award %)
         g. Check whether the award is vaoilating the Max limit of fund, then award upto max limit.
         h. If the fund is Entitlement then award aid upto the need of the student.
         i. Check for students Maximum Yearly amount for context fund.
         j. Check whether the student has already exceed the Max Life Terms (Maximum time student can get the fund), then log a message and skip the fund
         k. Check for students Maximum Life amount for context fund.
         l. Do all fund specific checks
              i. Check for the Max Grant Amount limit
             ii. Check for the Max Work Amount limit
            iii. Check for the Max Self Help Amount limit
             iv. Check for the Max Gift Aid Amount limit
              v. Check for the Max Scholarship Amount limit
             vi. Check whether the award aid amount is crosing Max slab amount
         m. For LOANS, check for max loan amount
              i. Update the Loans PL/SQL table with offered amounts and fund details
             ii. Check for the loan limits set at Target group level.
         n. check for the Minimum award Amount, If awarded aid is less then log a message and skip the fund.
         o. If the awarded Aid is less than ZERO then log a message and skip the fund.
         p. If the fund package status is accepted, then update the accepted amount of the award.
         q. Update the Remaining Amount and Over Award Limt for the fund as these were changed after the current award.
      9. Now the Actual Aid is calculated. Insert this award into the Temp table.
      10. If Replace FC and Update Need are set. Accordingly update the running totals in the Temp tables.
          This amounts will be used while awarding the same fund once again as specified in the Target Group.

    */

    -- initialise package variables.
    l_fund_fail           := FALSE;
    l_actual_grant_amt    := 0;
    l_actual_loan_amt     := 0;
    l_actual_work_amt     := 0;
    l_actual_shelp_amt    := 0;
    l_actual_gift_amt     := 0;
    l_actual_schlp_amt    := 0;

    -- Get the need
    -- Set Remaining FC

    -- Bug NUMBER: 2402622 (Need Analysis Issues)
    -- Calculation of teaching period months and federal verification status
    -- are moved out NOCOPY of fund loop as they are independent of fund
    -- Get the EFC months
    l_efc_months :=  igf_aw_coa_gen.coa_duration(l_fabase.base_id,g_awd_prd);

    IF l_efc_months > 12 OR l_efc_months < 1 THEN
      l_efc_months := 12;
    END IF;

    -- Get the Funds That need to be awarded to the student
    -- Loop through for all the funds in the Temp table

    -- Main loop

    OPEN c_fund(
                l_fabase.target_group,
                l_fabase.ci_cal_type,
                l_fabase.ci_sequence_number,
                l_fabase.base_id,
                l_process_id
               );
    LOOP

      FETCH c_fund INTO l_fund;
      EXIT WHEN c_fund%NOTFOUND; -- Exit when all the funds were awarded

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'----opened c_fund and it fetched----');
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.seq_no:'||l_fund.seq_no);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.fund_id:'||l_fund.fund_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.max_award_amt:'||l_fund.max_award_amt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.min_award_amt:'||l_fund.min_award_amt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.seq_no:'||l_fund.seq_no);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.award_id:'||l_fund.award_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'------------------------------------');
      END IF;

      l_seq_no      := l_fund.seq_no;
      l_aid         := 0;
      l_need        := 0;
      l_efc         := 0;
      l_rem_rep_efc := 0;
      l_reset_need  := FALSE;

      fnd_file.new_line(fnd_file.log,1);
      fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
      fnd_message.set_token('FUND',l_fund.fund_code);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      IF (NOT(g_sf_packaging = 'T' AND g_allow_to_exceed = 'COA')) THEN
        -- Based on the fund Methodology, check whether the student has either ISIR or PROFILE, if not log an error message
        IF (
            (l_fund.fm_fc_methd = 'FEDERAL' AND g_sf_packaging <> 'T' ) OR
            (l_fund.fund_source = 'FEDERAL' AND g_sf_packaging = 'T' AND get_fed_fund_code(l_fund.fund_id) NOT IN ('DLP','FLP'))
           )
        THEN

          IF hasActiveIsir(l_fabase.base_id) IS NULL THEN
            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            l_person_number := NULL;
            OPEN c_person_number(l_fabase.base_id);
            FETCH c_person_number INTO l_person_number;
            CLOSE c_person_number;
            fnd_message.set_name('IGF','IGF_AW_NO_ISIR');
            fnd_message.set_token('STDNT',l_person_number.person_number);
            fnd_file.put_line(fnd_file.log,fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'no active ISIR for '||l_person_number.person_number);
            END IF;

            EXIT;
          END IF;

        ELSIF l_fund.fm_fc_methd = 'INSTITUTIONAL' THEN


          IF hasActiveProfile(l_fabase.base_id) IS NOT NULL THEN
            --student has no profile
            fnd_message.set_name('IGF','IGF_AP_NO_ACTIVE_PROFILE');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'exiting as student has no active profile');
            END IF;
            EXIT;
          END IF;
        END IF;
      END IF;

      -- Get the Fund Properties
      OPEN c_fmast ( l_fund.fund_id );
      LOOP
        FETCH c_fmast INTO l_fmast;
        IF c_fmast%NOTFOUND THEN

          fnd_message.set_name('IGF','IGF_AW_PK_FUND_NOT_EXIST');
          fnd_message.set_token('FUND',l_fund.fund_code);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          l_fund_id := l_fund.fund_id;
          l_fund_fail := TRUE;
          l_award_id  := l_fund.award_id;
          EXIT;
        END IF;

        g_fm_fc_methd := l_fmast.fm_fc_methd;
        --
        -- Get the Max amount limit defined for the fund. if defined at group level then get it else get from fund manager
        -- Then award the student with that amount
        --
        IF ( NVL(l_fund.max_award_amt,0) > 0 ) THEN
           -- Take the formula level Max amt as base
           l_fmast.max_award_amt := l_fund.max_award_amt;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'------------------ Fund Code :'||l_fund.fund_code||'------------------');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'starting process_stud with g_sf_packaging:'||g_sf_packaging);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fmast.fm_fc_methd:'||l_fmast.fm_fc_methd);
        END IF;

        --Set fund's max and min amounts as specified in single fund packaging process
        IF g_sf_packaging = 'T' THEN
          l_fmast.max_award_amt := NVL(g_sf_max_amount,l_fmast.max_award_amt);
          l_fmast.min_award_amt := NVL(g_sf_min_amount,l_fmast.min_award_amt);
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'setting l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_fmast.min_award_amt:'||l_fmast.min_award_amt);
          END IF;
        END IF;

        -- Check if the fund can be Auto Packaged
        IF l_fmast.auto_pkg = 'N' THEN

          fnd_message.set_name('IGF','IGF_AW_PK_AUTO_SKIP');
          fnd_message.set_token('FUND_ID',l_fmast.fund_code);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          l_fund_id := l_fund.fund_id;
          l_fund_fail := TRUE;
          l_award_id  := l_fund.award_id;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'skipping fund '||l_fmast.fund_code||' as it cannot be autopackaged');
          END IF;
          EXIT;
        END IF;

        l_need_set := FALSE;

        check_plan(l_fund.adplans_id,lv_result,lv_method_code);
        IF lv_result <> 'TRUE' THEN
          fnd_message.set_name('IGF',lv_result);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          l_fund_id := l_fund.fund_id;
          l_fund_fail := TRUE;
          l_award_id  := l_fund.award_id;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'check_plan returned '||lv_result);
          END IF;
          EXIT;
        END IF;

        IF g_fm_fc_methd = 'INSTITUTIONAL' AND g_sf_packaging <> 'T' THEN

          IF hasActiveProfile(l_fabase.base_id) IS NOT NULL THEN
            --student has no profile
            fnd_message.set_name('IGF','IGF_AP_NO_ACTIVE_PROFILE');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'exiting as student has no active profile');
            END IF;
            EXIT;
          END IF;
        END IF;

        /*
           Enforce the check that FWS funds cannot have
           more than 1 disbursement per term for single-fund packaging.
           For packaging process, this is enforced in load_funds.
        */
        IF g_sf_packaging = 'T' THEN
          IF get_fed_fund_code(l_fund.fund_id) = 'FWS' THEN
            IF NOT check_disb(l_fabase.base_id,l_fund.adplans_id,g_awd_prd) THEN
              fnd_message.set_name('IGF','IGF_SE_MAX_TP_SETUP');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              l_fund_id := l_fund.fund_id;
              l_fund_fail := TRUE;
              l_award_id  := l_fund.award_id;
            END IF;
          END IF;
        END IF;

        -- GPLUSFL and GPLUSDL funds can be awarded only when the Student has ISIR
        IF l_fmast.fed_fund_code IN ('GPLUSDL', 'GPLUSFL') THEN

          IF hasActiveIsir(l_fabase.base_id) IS NULL THEN
            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            l_person_number := NULL;

            OPEN c_person_number(l_fabase.base_id);
            FETCH c_person_number INTO l_person_number;
            CLOSE c_person_number;

            fnd_message.set_name('IGF','IGF_AW_NO_ISIR');
            fnd_message.set_token('STDNT',l_person_number.person_number);
            fnd_file.put_line(fnd_file.log,fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'No active ISIR for '||l_person_number.person_number||'. For GPLUSDL/GPLUSFL funds the Student must have a valid ISIR');
            END IF;

            EXIT;
          END IF;
        END IF;

        -- Calculate the EFC, NEED and Remaining EFC for calculating the award
        -- For the fund if these are already calcualted then load the same.
        OPEN c_rem_efc;
        FETCH c_rem_efc INTO l_rem_efc;
        IF c_rem_efc%FOUND THEN
          WHILE c_rem_efc%FOUND LOOP
            IF l_rem_efc.temp_char_val1 = 'FEDERAL' THEN
              l_rem_rep_efc_f := NVL(l_rem_efc.temp_num_val1,0);
              l_efc_f         := NVL(l_rem_efc.temp_num_val1,0);
              l_need_f        := NVL(l_rem_efc.temp_num_val2,0);
              l_need_VB_AC_f  := NVL(l_rem_efc.temp_val3_num,0);
            ELSE
              l_rem_rep_efc_i := NVL(l_rem_efc.temp_num_val1,0);
              l_efc_i         := NVL(l_rem_efc.temp_num_val1,0);
              l_need_i        := NVL(l_rem_efc.temp_num_val2,0);
              l_need_VB_AC_i  := NVL(l_rem_efc.temp_val3_num,0);
            END IF;
            FETCH c_rem_efc INTO l_rem_efc;
          END LOOP;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'c_rem_efc%FOUND');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_efc_f:'||l_efc_f||' l_efc_i:'||l_efc_i);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_rem_rep_efc_f:'||l_rem_rep_efc_f||' l_rem_rep_efc_i:'||l_rem_rep_efc_i);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_f:'||l_need_f||' l_need_i:'||l_need_i);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_VB_AC_f:'||l_need_VB_AC_f||' l_need_VB_AC_i:'||l_need_VB_AC_i);
          END IF;

          IF g_fm_fc_methd = 'FEDERAL' THEN
            IF l_fmast.fed_fund_code in ('DLS','FLS') AND (l_need_VB_AC_f > l_need_f) THEN
              -- Do not consider VA30/AC awards as resource for Subsidized loans, increase need accordingly.
              l_need_bkup_f := l_need_f;
              l_need_f := l_need_VB_AC_f;
              l_reset_need := TRUE;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Increased Need to '||l_need_f||' for ' ||l_fmast.fed_fund_code|| ', bcoz student has VA30/AC award');
              END IF;
            END IF;

            l_need        := l_need_f;
            l_efc         := l_efc_f;
            l_rem_rep_efc := NVL(l_efc_f,0);
          ELSE
            IF l_fmast.fed_fund_code in ('DLS','FLS') AND (l_need_VB_AC_i > l_need_i) THEN
              -- Do not consider VA30/AC awards as resource for Subsidized loans, increase need accordingly
              l_need_bkup_i := l_need_i;
              l_need_i := l_need_VB_AC_i;
              l_reset_need := TRUE;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Increased Need to '||l_need_i||' for ' ||l_fmast.fed_fund_code|| ', bcoz student has VA30/AC award');
              END IF;
            END IF;

            l_need        := l_need_i;
            l_efc         := l_efc_i;
            l_rem_rep_efc := NVL(l_efc_i,0);
          END IF;

        ELSE

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'c_rem_efc%NOTFOUND');
          END IF;

          -- If Awarding PROFILE is present for the student, get the EFC, NEED
          l_efc_i := igf_aw_gen_004.efc_i(l_fabase.base_id,g_awd_prd);

          IF l_use_fixed_costs = 'Y' THEN
            l_need_i := NVL(l_fabase.coa_fixed,0) - NVL(l_efc_i,0) - NVL(l_gap_amt,0);
          ELSE
            l_need_i := NVL(l_fabase.coa_i,0) - NVL(l_efc_i,0)  - NVL(l_gap_amt,0);
          END IF;

          l_rem_rep_efc_i := NVL(l_efc_i,0);

          -- If Awarding ISIR is present for the student, get the EFC, NEED
          -- Get the EFC value for Federal Methodology
          igf_aw_packng_subfns.get_fed_efc(
                                           l_fabase.base_id,
                                           g_awd_prd,
                                           l_efc_f,
                                           l_pell_efc,
                                           l_efc_ay
                                          );

          -- If fixed costs were set, then calculate using the Fixed COA
          IF l_use_fixed_costs = 'Y' THEN
            l_need_f := NVL(l_fabase.coa_fixed,0) - NVL(l_efc_f,0) - NVL(l_gap_amt,0);
          ELSE
            l_need_f := NVL(l_fabase.coa_f,0) - NVL(l_efc_f,0)  - NVL(l_gap_amt,0);
          END IF;

          l_rem_rep_efc_f := NVL(l_efc_f,0);

          IF g_fm_fc_methd = 'FEDERAL' THEN
            l_need        := l_need_f;
            l_efc         := l_efc_f;
            l_rem_rep_efc := NVL(l_efc_f,0);
          ELSE
            l_need        := l_need_i;
            l_efc         := l_efc_i;
            l_rem_rep_efc := NVL(l_efc_i,0);
          END IF;

          IF l_use_fixed_costs = 'Y' THEN
            IF l_fabase.coa_fixed IS NOT NULL AND l_efc_f IS NOT NULL AND l_fabase.coa_fixed > 0 AND l_fabase.coa_fixed < l_efc_f THEN
              l_rem_rep_efc_f := l_fabase.coa_fixed;
              l_rem_rep_efc   := l_fabase.coa_fixed;
            END IF;
          ELSE
            IF l_fabase.coa_f IS NOT NULL AND l_efc_f IS NOT NULL AND l_fabase.coa_f > 0 AND l_fabase.coa_f < l_efc_f THEN
              l_rem_rep_efc_f := l_fabase.coa_f;
              l_rem_rep_efc   := l_fabase.coa_f;
            END IF;
          END IF;

          l_sl_number   := NULL;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'calculated need,efc for method:INSTITUTIONAL as l_efc_i: '||l_efc_i||' l_need_i: '||l_need_i||' l_rem_rep_efc_i: '||l_rem_rep_efc_i);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'calculated need,efc for method:FEDERAL as l_efc_f: '||l_efc_f||' l_need_f: '||l_need_f||' l_rem_rep_efc_f: '||l_rem_rep_efc_f);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'inserting into igf_aw_award_t with flag:ND and adplans_id: '||l_fund.adplans_id);
          END IF;

          fnd_message.set_name('IGF','IGF_AW_PKG_EFC_MONTH');
          fnd_message.set_token('MONTH',l_efc_months);
          fnd_file.put_line(fnd_file.log,fnd_message.get);


          igf_aw_award_t_pkg.insert_row(
                                        x_rowid              => lv_rowid ,
                                        x_process_id         => l_process_id ,
                                        x_sl_number          => l_sl_number,
                                        x_fund_id            => l_fund.fund_id,
                                        x_base_id            => l_fabase.base_id,
                                        x_offered_amt        => NULL,
                                        x_accepted_amt       => NULL,
                                        x_paid_amt           => NULL ,
                                        x_need_reduction_amt => NULL,
                                        x_flag               => 'ND',
                                        x_temp_num_val1      => NVL(l_efc_i,0),
                                        x_temp_num_val2      => NVL(l_need_i,0),
                                        x_temp_char_val1     => 'INSTITUTIONAL',--l_fmast.fm_fc_methd,
                                        x_tp_cal_type        => NULL,
                                        x_tp_sequence_number => NULL,
                                        x_ld_cal_type        => NULL,
                                        x_ld_sequence_number => NULL,
                                        x_mode               => 'R',
                                        x_adplans_id         => NULL,
                                        x_app_trans_num_txt  => NULL,
                                        x_award_id           => NULL,
                                        x_lock_award_flag    => NULL,
                                        x_temp_val3_num      => NULL,
                                        x_temp_val4_num      => NULL,
                                        x_temp_char2_txt     => NULL,
                                        x_temp_char3_txt     => NULL
                                       );

          igf_aw_award_t_pkg.insert_row(
                                        x_rowid              => lv_rowid ,
                                        x_process_id         => l_process_id ,
                                        x_sl_number          => l_sl_number,
                                        x_fund_id            => l_fund.fund_id,
                                        x_base_id            => l_fabase.base_id,
                                        x_offered_amt        => NULL,
                                        x_accepted_amt       => NULL,
                                        x_paid_amt           => NULL ,
                                        x_need_reduction_amt => NULL,
                                        x_flag               => 'ND',
                                        x_temp_num_val1      => NVL(l_efc_f,0),
                                        x_temp_num_val2      => NVL(l_need_f,0),
                                        x_temp_char_val1     => 'FEDERAL',--l_fmast.fm_fc_methd,
                                        x_tp_cal_type        => NULL,
                                        x_tp_sequence_number => NULL,
                                        x_ld_cal_type        => NULL,
                                        x_ld_sequence_number => NULL,
                                        x_mode               => 'R',
                                        x_adplans_id         => NULL,
                                        x_app_trans_num_txt  => NULL,
                                        x_award_id           => NULL,
                                        x_lock_award_flag    => NULL,
                                        x_temp_val3_num      => NULL,
                                        x_temp_val4_num      => NULL,
                                        x_temp_char2_txt     => NULL,
                                        x_temp_char3_txt     => NULL
                                       );
        END IF;
        CLOSE c_rem_efc;

        -- If the awarding fund is PELL then do all the PELL validations
        -- Process for Pell Grant
        IF l_fmast.fed_fund_code = 'PELL' THEN

          IF l_fund.award_id IS NULL OR (l_fund.award_id IS NOT NULL AND NOT g_phasein_participant) THEN
            --means PELL is being packaged or repackaged for a full participant-both follow similar logic
            -- Set the indicator from which PELL Grant was calculated ( either PELL Alternate matrix or PELL Regular matrix )
            -- also get the eligible PELL aid amount

            lv_return_status := NULL;
            lv_message       := NULL;
            l_pell_seq_id    := NULL;
            l_aid            := 0;

            --if student has no COA defined and g_allow_to_exceed is set to 'COA' in single_fund_packaging,call the pell wrapper with cp_called_from as 'PACKAGING_DP'
            --else call it with 'PACKAGING' as the wrapper needs to take care of the distribution

            IF igf_aw_gen_003.check_coa(l_fabase.base_id,g_awd_prd) THEN
              lb_coa_defined := TRUE;
            ELSE
              lb_coa_defined := FALSE;
            END IF;

            IF g_sf_packaging = 'T' AND g_allow_to_exceed = 'COA' AND lb_coa_defined = FALSE THEN
              lv_called_from := 'PACKAGING_DP';
            ELSE
              lv_called_from := 'PACKAGING';
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'before call to igf_gr_pell_calc.calc_pell >fund_id/adplans_id/base_id/lv_called_from ->'||
                l_fmast.fund_id || '/' || l_fund.adplans_id || '/' ||  l_fabase.base_id || '/' || lv_called_from);
            END IF;

            g_pell_tab.DELETE;
            igf_gr_pell_calc.calc_pell(
                                       cp_fund_id            => l_fmast.fund_id,
                                       cp_plan_id            => l_fund.adplans_id,
                                       cp_base_id            => l_fabase.base_id,
                                       cp_aid                => l_aid,
                                       cp_pell_tab           => g_pell_tab,
                                       cp_return_status      => lv_return_status,
                                       cp_message            => lv_message,
                                       cp_called_from        => lv_called_from,
                                       cp_pell_seq_id        => l_pell_seq_id,
                                       cp_pell_schedule_code => l_pell_schedule_code
                                      );

            g_alt_pell_schedule :=  l_pell_schedule_code;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'pell wrapper returned l_aid:'||l_aid);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'pell wrapper returned return_status:'||lv_return_status);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'pell wrapper returned message:'||lv_message);
            END IF;

            IF lv_return_status = 'E' THEN
              --Error occured in the pell calculation wrapper
              --so log the error message
              fnd_file.put_line(fnd_file.log,lv_message);
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'pell wrapper returned error message '||lv_message);
              END IF;
              l_fund_id := l_fund.fund_id;
              l_fund_fail := TRUE;
              l_award_id  := l_fund.award_id;
              EXIT;
            ELSIF ( l_aid <= 0 ) THEN
              l_aid := 0;
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'pell_calc returned NO pell aid');
              END IF;
              IF ( l_run_mode = 'D') THEN
                fnd_message.set_name('IGF','IGF_AW_NO_PELL_AID');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;

              l_fund_id := l_fund.fund_id;
              l_fund_fail := TRUE;
              l_award_id  := l_fund.award_id;
              EXIT;
            END IF;

            -- Note : After FA131 - All Group level checks will not be enforced for PELL

            -- If the Packaging status is Accepted, then set the accepted amount of the award
            IF ( l_fmast.pckg_awd_stat = 'ACCEPTED' ) THEN
              l_accepted_amt := l_aid;
            ELSE
              l_accepted_amt := NULL;
            END IF;

            -- For PELL awards do not consider the common terms accros the COA and FUND, so set the value to 100
            gn_fund_awd_cnt := NVL(gn_fund_awd_cnt, 0) + 1;
            g_fund_awd_prct.extend;
            g_fund_awd_prct(gn_fund_awd_cnt).base_id   := l_fabase.base_id;
            g_fund_awd_prct(gn_fund_awd_cnt).fund_id   := l_fund.fund_id;
            g_fund_awd_prct(gn_fund_awd_cnt).awd_prct  := 100;

            l_need        := l_need_f;
            l_efc         := l_efc_f;
            l_rem_rep_efc := l_rem_rep_efc_f;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after pell processing, actual amounts:');
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_actual_grant_amt:'||l_actual_grant_amt);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_actual_shelp_amt:'||l_actual_shelp_amt);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_actual_gift_amt:'||l_actual_gift_amt);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_actual_aid:'||l_actual_aid);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_accepted_amt:'||l_accepted_amt);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need:'||l_need);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_efc:'||l_efc);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_rem_rep_efc:'||l_rem_rep_efc);
            END IF;
          ELSE --means PELL is being repackaged.
            IF g_phasein_participant THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'phase in participant');
              END IF;
              -- before we repackage, we should check whether the student's PELL eligibility changed after PELL was awarded
              lv_return_status := NULL;
              igf_gr_pell_calc.pell_elig(l_fabase.base_id,lv_return_status);
              IF NVL(lv_return_status,'N') = 'E' THEN
                IF igs_ge_msg_stack.count_msg > 0 THEN
                  FOR i IN 1..igs_ge_msg_stack.count_msg LOOP
                    lv_msg_text := NULL;
                    igs_ge_msg_stack.get(i,'F',lv_msg_text, ln_msg_index);
                    fnd_file.put_line(fnd_file.log,lv_msg_text);
                  END LOOP;
                END IF;
                RAISE PELL_NO_REPACK;
              END IF;
              -- loop thru all terms in the award
              FOR l_term_amounts IN cur_term_amounts(l_fund.award_id) LOOP
                --for each of the terms, calculate the amount
                lv_message           := NULL;
                lv_return_status     := NULL;
                l_pell_schedule_code := NULL;
                l_term_aid           := NULL;

                igf_ap_gen_001.get_key_program(
                                               cp_base_id        => l_fabase.base_id,
                                               cp_course_cd      => l_program_cd,
                                               cp_version_number => l_program_version
                                              );
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'key prog:'||l_program_cd||'/'||l_program_version);
                END IF;

                igf_gr_pell_calc.get_pell_setup(
                                                cp_base_id         => l_fabase.base_id,
                                                cp_course_cd       => l_program_cd,
                                                cp_version_number  => l_program_version,
                                                cp_cal_type        => l_fabase.ci_cal_type,
                                                cp_sequence_number => l_fabase.ci_sequence_number ,
                                                cp_pell_setup_rec  => l_pell_setup_rec ,
                                                cp_message         => l_message  ,
                                                cp_return_status   => l_return_status
                                               );
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_pell_setup_rec.pell_seq_id:'||l_pell_setup_rec.pell_seq_id);
                END IF;

                igf_gr_pell_calc.get_pell_attendance_type(
                                                          cp_base_id            => l_fabase.base_id,
                                                          cp_ld_cal_type        => l_term_amounts.ld_cal_type ,
                                                          cp_ld_sequence_number => l_term_amounts.ld_sequence_number  ,
                                                          cp_pell_setup_rec     => l_pell_setup_rec  ,
                                                          cp_attendance_type    => l_pell_attend_type ,
                                                          cp_message            => l_message  ,
                                                          cp_return_status      => l_return_status
                                                         );
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_pell_attend_type:'||l_pell_attend_type);
                END IF;
                l_term_amounts.base_attendance_type_code := l_pell_attend_type;

                igf_gr_pell_calc.calc_term_pell(
                                                l_fabase.base_id,
                                                l_term_amounts.base_attendance_type_code,
                                                l_term_amounts.ld_cal_type,
                                                l_term_amounts.ld_sequence_number,
                                                l_term_aid,
                                                lv_return_status,
                                                lv_message,
                                                'PACKAGING',
                                                l_pell_schedule_code
                                               );
                IF NVL(lv_return_status,'N') = 'E' THEN
                  fnd_file.put_line(fnd_file.log,lv_message);
                  RAISE PELL_NO_REPACK;
                ELSE
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'for term '||l_term_amounts.ld_cal_type||
                                  '/'||l_term_amounts.ld_sequence_number||' existing amount:'||l_term_amounts.term_total||
                                  ' calc aid:'||l_term_aid);
                  END IF;
                  l_aid       := NVL(l_aid,0) + l_term_aid;
                  IF l_term_aid <> l_term_amounts.term_total THEN
                    --have to adjust the term total with the difference amount
                    --the difference can be either a positive amount or a negative amount
                    lv_rowid    := NULL;
                    l_sl_number := NULL;
                    l_term_start := NULL;
                    l_term_end   := NULL;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'calling get_term_dates');
                    END IF;
                    igf_ap_gen_001.get_term_dates(
                                                  p_base_id            => l_fabase.base_id,
                                                  p_ld_cal_type        => l_term_amounts.ld_cal_type,
                                                  p_ld_sequence_number => l_term_amounts.ld_sequence_number,
                                                  p_ld_start_date      => l_term_start,
                                                  p_ld_end_date        => l_term_end
                                                 );
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.process_stud.debug','l_term_start:'||l_term_start);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.process_stud.debug','l_term_end:'||l_term_end);
                    END IF;
                    IF l_term_end < TRUNC(SYSDATE) THEN
                      --term has lapsed
                      l_first_disb_dt := NULL;
                      OPEN c_first_disb_dt(l_fund.award_id,l_term_amounts.ld_cal_type,l_term_amounts.ld_sequence_number);
                      FETCH c_first_disb_dt INTO l_first_disb_dt;
                      CLOSE c_first_disb_dt;
                      l_first_disb_dt.disb_date := TRUNC(SYSDATE);
                    ELSIF TRUNC(SYSDATE) BETWEEN l_term_start AND l_term_end THEN
                      --current term
                      l_first_disb_dt := NULL;
                      OPEN c_first_disb_dt(l_fund.award_id,l_term_amounts.ld_cal_type,l_term_amounts.ld_sequence_number);
                      FETCH c_first_disb_dt INTO l_first_disb_dt;
                      CLOSE c_first_disb_dt;
                      l_first_disb_dt.disb_date := TRUNC(SYSDATE);
                    ELSE
                      --future term
                      l_first_disb_dt := NULL;
                      OPEN c_first_disb_dt(l_fund.award_id,l_term_amounts.ld_cal_type,l_term_amounts.ld_sequence_number);
                      FETCH c_first_disb_dt INTO l_first_disb_dt;
                      CLOSE c_first_disb_dt;
                    END IF;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'^^^inserting into igf_aw_award_t with flag GR^^^');
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.fund_id:'||l_fund.fund_id);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fabase.base_id:'||l_fabase.base_id);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_term_aid - l_term_amounts.term_total:'||(l_term_aid - l_term_amounts.term_total));
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_first_disb_dt.disb_date:'||l_first_disb_dt.disb_date);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_first_disb_dt.tp_cal_type:'||l_first_disb_dt.tp_cal_type);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_first_disb_dt.tp_sequence_number:'||l_first_disb_dt.tp_sequence_number);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_term_amounts.ld_cal_type:'||l_term_amounts.ld_cal_type);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_term_amounts.ld_sequence_number:'||l_term_amounts.ld_sequence_number);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_term_amounts.adplans_id:'||l_term_amounts.adplans_id);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.award_id:'||l_fund.award_id);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'^^^done inserting into igf_aw_award_t^^^');
                    END IF;
                    igf_aw_award_t_pkg.insert_row(
                                                  x_rowid              => lv_rowid ,
                                                  x_process_id         => l_process_id ,
                                                  x_sl_number          => l_sl_number,
                                                  x_fund_id            => l_fund.fund_id,
                                                  x_base_id            => l_fabase.base_id,
                                                  x_offered_amt        => l_term_aid - l_term_amounts.term_total,
                                                  x_accepted_amt       => NULL,
                                                  x_paid_amt           => NULL ,
                                                  x_need_reduction_amt => NULL,
                                                  x_flag               => 'GR',
                                                  x_temp_num_val1      => NULL,
                                                  x_temp_num_val2      => NULL,
                                                  x_temp_char_val1     => l_first_disb_dt.disb_date,
                                                  x_tp_cal_type        => l_first_disb_dt.tp_cal_type,
                                                  x_tp_sequence_number => l_first_disb_dt.tp_sequence_number,
                                                  x_ld_cal_type        => l_term_amounts.ld_cal_type,
                                                  x_ld_sequence_number => l_term_amounts.ld_sequence_number,
                                                  x_mode               => 'R',
                                                  x_adplans_id         => l_term_amounts.adplans_id,
                                                  x_app_trans_num_txt  => NULL,
                                                  x_award_id           => l_fund.award_id,
                                                  x_lock_award_flag    => NULL,
                                                  x_temp_val3_num      => NULL,
                                                  x_temp_val4_num      => NULL,
                                                  x_temp_char2_txt     => l_term_amounts.base_attendance_type_code,
                                                  x_temp_char3_txt     => NULL
                                                 );

                  END IF;
                END IF;
              END LOOP;
            END IF;
          END IF;
        ELSE

          -----------------------------------------------------------
          --   Process for funds other than Pell Grants
          -----------------------------------------------------------

          IF (l_need <= 0) AND g_allow_to_exceed IS NULL THEN  -- If Need is exhausted

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Need exhausted');
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.replace_fc:'||NVL(l_fund.replace_fc,'NULL')||
                                                     'l_fmast.entitlement:'||NVL(l_fmast.entitlement,'NULL'));
            END IF;
            -- If Need is over and Replace FC is not set and the fund is not a entitlement. then log a message and skip the fund
            IF ( l_fund.replace_fc <> 'Y' ) AND (l_fmast.entitlement <> 'Y') THEN

              IF ( l_run_mode = 'D' ) THEN
                fnd_message.set_name('IGF','IGF_AW_NEED_OVER');
                fnd_message.set_token('FUND', l_fmast.fund_code );
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;
              l_fund_id := l_fund.fund_id;
              l_fund_fail := TRUE;
              l_award_id  := l_fund.award_id;
              EXIT;

            -- Need is over but Replace FC is set. So the need is the Remaining FC
            ELSIF ( l_fund.replace_fc = 'Y') AND g_fm_fc_methd = 'FEDERAL' THEN
              l_old_need   := 0;
              l_need_f     := l_rem_rep_efc_f;
              l_need       := l_rem_rep_efc_f;
              l_need_set   := TRUE;
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'1.l_need_f:'||l_need_f);
              END IF;
            END IF;

            -- if need is still zero, log a message and skip the fund
            IF l_need <= 0 AND l_need_set THEN
              fnd_message.set_name('IGF','IGF_AW_NEED_OVER');
              fnd_message.set_token('FUND', l_fmast.fund_code );
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              l_fund_id := l_fund.fund_id;
              l_fund_fail := TRUE;
              l_award_id  := l_fund.award_id;
              EXIT;
            END IF;
          END IF; -- End of Need Check


          IF g_sf_packaging = 'T' AND l_fmast.fund_source = 'FEDERAL' THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund source is federal');
            END IF;

            IF l_fmast.replace_fc = 'Y' THEN

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'2.l_need_f:'||l_need_f);
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'2.l_rem_rep_efc_f:'||l_rem_rep_efc_f);
              END IF;

              IF l_need_f > 0 THEN
                l_need_f := l_rem_rep_efc_f + l_need_f;
              ELSE
                l_need_f := l_rem_rep_efc_f;
              END IF;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_f:'||l_need_f);
              END IF;

            END IF;

            IF l_fmast.fed_fund_code in ('DLP','FLP') THEN -- DLP/FLP Check
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund code is FLP/DLP');
              END IF;

              --if student has coa defined
              IF NOT igf_aw_gen_003.check_coa(l_fabase.base_id,g_awd_prd) THEN  -- COA Check
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no COA defined');
                END IF;
                fnd_message.set_name('IGF','IGF_AW_PK_COA_NULL');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                l_fund_id := l_fund.fund_id;
                l_fund_fail := TRUE;
                l_award_id  := l_fund.award_id;
                EXIT;

              ELSE
                --then aid = min((coa-existing awards),fund min)

                IF l_need_f < l_fmast.max_award_amt THEN
                  l_aid := l_need_f;
                ELSE
                  l_aid := l_fmast.max_award_amt;
                END IF;
                --
                -- if entitlement is set to TRUE then give max amount
                --
                IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                  l_aid := l_fmast.max_award_amt;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                  END IF;
                END IF;

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has COA-so aid=min(fund max,need)');
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_f:'||l_need_f||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_aid:'||l_aid);
                END IF;
              END IF; -- COA Check End

            ELSE -- DLP/FLP Else
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund code is not FLP/DLP');
              END IF;

              --if student has coa
              IF NOT igf_aw_gen_003.check_coa(l_fabase.base_id,g_awd_prd) THEN  --COA Check
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no COA defined');
                END IF;
                fnd_message.set_name('IGF','IGF_AW_PK_COA_NULL');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                l_fund_id := l_fund.fund_id;
                l_fund_fail := TRUE;
                l_award_id  := l_fund.award_id;
                EXIT;

              ELSE --COA Else
                --if student has awarding isir
                IF hasActiveIsir(l_fabase.base_id) IS NOT NULL THEN -- ISIR Check
                  --
                  -- award student
                  --
                  IF l_fmast.max_award_amt IS NOT NULL THEN
                  IF l_need_f < l_fmast.max_award_amt THEN
                    l_aid := l_need_f;
                  ELSE
                    l_aid := l_fmast.max_award_amt;
                  END IF;
                  ELSE
                    l_aid := l_need_f;
                  END IF;
                  --
                  -- if entitlement is set to TRUE then give max amount
                  --
                  IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                    l_aid := l_fmast.max_award_amt;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                    END IF;
                  END IF;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_f: '||l_need_f||' l_fmast.max_award_amt: '||l_fmast.max_award_amt||' l_aid:'||l_aid);
                  END IF;
                ELSE -- ISIR Else
                  --log error message
                  fnd_message.set_name('IGF','IGF_AW_NO_ISIR');
                  fnd_message.set_token('STDNT',l_person_number.person_number);
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                  l_fund_id := l_fund.fund_id;
                  l_fund_fail := TRUE;
                  l_award_id  := l_fund.award_id;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no active ISIR defined');
                  END IF;
                  EXIT;
                END IF; -- ISIR End
              END IF; -- COA End
            END IF; -- DLP/FLP End

          ELSIF g_sf_packaging = 'T' AND l_fmast.fund_source <> 'FEDERAL' THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund source is not federal');
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'g_allow_to_exceed: '||g_allow_to_exceed);
            END IF;
            IF NVL(g_allow_to_exceed,'*') = 'COA' AND l_fmast.max_award_amt IS NOT NULL THEN
              l_aid := l_fmast.max_award_amt;
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'since COA can be exceeded l_aid=fund max='||l_aid);
              END IF;
            ELSE
              IF NOT igf_aw_gen_003.check_coa(l_fabase.base_id,g_awd_prd) THEN --COA Check
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no COA defined');
                END IF;
                fnd_message.set_name('IGF','IGF_AW_PK_COA_NULL');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                l_fund_id := l_fund.fund_id;
                l_fund_fail := TRUE;
                l_award_id  := l_fund.award_id;
                EXIT;

              ELSE --COA Else
                IF NVL(g_allow_to_exceed,'*') = 'NEED' THEN --Start allow_to_exceed = 'need' check
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'allow NEED to be exceeded');
                  END IF;
                  --aid amount is minimum of COA-existing awards,max award amt
                  l_existing_awards := igf_aw_coa_gen.award_amount(l_fabase.base_id,g_awd_prd);

                  IF l_fmast.max_award_amt IS NOT NULL THEN
                  IF (l_fabase.coa_f - l_existing_awards) < l_fmast.max_award_amt THEN
                    l_aid := l_fabase.coa_f - l_existing_awards;
                  ELSE
                    l_aid := l_fmast.max_award_amt;
                  END IF;
                  ELSE
                    l_aid := l_fabase.coa_f - l_existing_awards;
                  END IF;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has COA-so aid=min(COA-existing awards,fund max)');
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'COA:'||l_fabase.coa_f||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_existing_awards:'||l_existing_awards||' l_aid:'||l_aid);
                  END IF;
                ELSE
                  --need cannot b exceeded
                  --check if fund used FM
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'NEED cannot be exceeded-finding need using active isir/profile');
                  END IF;

                  --if the fund replaces family contribution, then add remaining efc to be satisfied to the need.
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_f:'||l_need_f);
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_rem_rep_efc_f:'||l_rem_rep_efc_f);
                  END IF;

                  IF NVL(l_fmast.replace_fc,'N') = 'Y' THEN
                    IF l_need_f > 0 THEN
                      l_need_f := l_rem_rep_efc_f + l_need_f;
                    ELSE
                      l_need_f := l_rem_rep_efc_f;
                    END IF;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'3.l_need_f:'||l_need_f);
                    END IF;
                  END IF;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_f:'||l_need_f);
                  END IF;

                  IF l_fmast.fm_fc_methd = 'FEDERAL' THEN
                    --fund uses FM
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund uses FM-so using active isir');
                    END IF;

                    IF hasActiveIsir(l_fabase.base_id) IS NOT NULL THEN
                      --student has active isir
                      IF l_fmast.max_award_amt IS NOT NULL THEN
                      IF l_need_f < l_fmast.max_award_amt THEN
                        l_aid := l_need_f;
                      ELSE
                        l_aid := l_fmast.max_award_amt;
                      END IF;
                      ELSE
                        l_aid := l_need_f;
                      END IF;
                      --
                      -- if entitlement is set to TRUE then give max amount
                      --
                      IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                        l_aid := l_fmast.max_award_amt;
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                        END IF;
                      END IF;
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_f:'||l_need_f||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_aid:'||l_aid);
                      END IF;
                    ELSE
                      --student does not have isir
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no active ISIR-cant continue');
                      END IF;
                      fnd_message.set_name('IGF','IGF_AW_NO_ISIR');
                      fnd_message.set_token('STDNT',l_person_number.person_number);
                      fnd_file.put_line(fnd_file.log,fnd_message.get);
                      l_fund_id := l_fund.fund_id;
                      l_fund_fail := TRUE;
                      l_award_id  := l_fund.award_id;
                      EXIT;
                    END IF;
                  ELSE
                    --fund uses IM
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund uses IM-so using active profile');
                    END IF;

                    IF hasActiveProfile(l_fabase.base_id) IS NOT NULL THEN
                      --student has no profile
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no active profile-cant continue');
                      END IF;
                      fnd_message.set_name('IGF','IGF_AP_NO_ACTIVE_PROFILE');
                      fnd_file.put_line(fnd_file.log,fnd_message.get);
                      l_fund_id := l_fund.fund_id;
                      l_fund_fail := TRUE;
                      l_award_id  := l_fund.award_id;
                      EXIT;
                    ELSE
                      --student has active profile
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has active profile');
                      END IF;
                      --if student has fm awards
                      OPEN c_fm_awards(l_fabase.base_id,l_process_id);
                      FETCH c_fm_awards INTO l_fm_awards;
                      IF c_fm_awards%FOUND THEN
                        --student has fm awards
                        CLOSE c_fm_awards;
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has FM awards');
                        END IF;

                        --if student has active isir
                        IF hasActiveIsir(l_fabase.base_id) IS NOT NULL THEN
                          --student has active isir
                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has active isir-so aid=min(need_i,need_f,fund max)');
                          END IF;
                          --award amount is minimum of im need,fm need,fund max
                          IF l_fmast.max_award_amt IS NOT NULL THEN
                          l_aid := LEAST(l_need_i,LEAST(l_need_f,l_fmast.max_award_amt));
                          ELSE
                            l_aid := LEAST(l_need_i,l_need_f);
                          END IF;
                          --
                          -- IF fund is entitlement then give the fund max amount
                          --
                          IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                            l_aid := l_fmast.max_award_amt;
                          END IF;

                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_i:'||l_need_i||' l_need_f:'||l_need_f||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_aid:'||l_aid);
                          END IF;
                        ELSE
                          IF l_fmast.max_award_amt IS NOT NULL THEN
                          IF l_need_i < l_fmast.max_award_amt THEN
                            l_aid := l_need_i;
                          ELSE
                            l_aid := l_fmast.max_award_amt;
                          END IF;
                          ELSE
                            l_aid := l_need_i;
                          END IF;

                          --
                          -- if entitlement is set to TRUE then give max amount
                          --
                          IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                            l_aid := l_fmast.max_award_amt;
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                            END IF;
                          END IF;

                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no active isir-so aid=min(need_i,fund max)');
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_i:'||l_need_i||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_aid:'||l_aid);

                          END IF;
                        END IF;
                      ELSE
                        --student does not have fm awards
                        CLOSE c_fm_awards;
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no FM awards');
                        END IF;
                        --if student has active isir
                        IF hasActiveIsir(l_fabase.base_id) IS NOT NULL THEN
                          --student has active isir
                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has active isir');
                          END IF;
                          fnd_profile.get('IGF_AW_USE_LOW_IM_FM',lv_prof_value);
                          IF lv_prof_value = 'Y' THEN
                            --profile set
                            --here im need,fm need, fund max are known
                            --so award amount is minimum of these 3
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'IGF_AW_USE_LOW_IM_FM:'||lv_prof_value);
                            END IF;

                            IF l_fmast.max_award_amt IS NOT NULL THEN
                            l_aid := LEAST(l_need_i,LEAST(l_need_f,l_fmast.max_award_amt));
                            ELSE
                              l_aid := LEAST(l_need_i,l_need_f);
                            END IF;
                            --
                            -- if entitlement is set to TRUE then give max amount
                            --
                            IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                              l_aid := l_fmast.max_award_amt;
                              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                              END IF;
                            END IF;

                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'since profile is set aid=min(need_i,need_f,fund max)');
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_i:'||l_need_i||' l_need_f:'||l_need_f||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_aid:'||l_aid);
                            END IF;

                          ELSE
                            --profile not set
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'IGF_AW_USE_LOW_IM_FM:'||lv_prof_value);
                            END IF;

                            IF l_fmast.max_award_amt IS NOT NULL THEN
                            IF l_need_i < l_fmast.max_award_amt THEN
                              l_aid := l_need_i;
                            ELSE
                              l_aid := l_fmast.max_award_amt;
                            END IF;
                            ELSE
                              l_aid := l_need_i;
                            END IF;

                            --
                            -- if entitlement is set to TRUE then give max amount
                            --
                            IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                              l_aid := l_fmast.max_award_amt;
                              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                              END IF;
                            END IF;

                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'since profile is not set aid=min(need_i,fund max)');
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_i:'||l_need_i||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_aid:'||l_aid);
                            END IF;

                          END IF;
                        ELSE
                          --student does not have active isir;
                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no active ISIR-aid=min(need_i,fund max)');
                          END IF;

                          IF l_fmast.max_award_amt IS NOT NULL THEN
                          IF l_need_i < l_fmast.max_award_amt THEN
                            l_aid := l_need_i;
                          ELSE
                            l_aid := l_fmast.max_award_amt;
                          END IF;
                          ELSE
                            l_aid := l_need_i;
                          END IF;

                          --
                          -- if entitlement is set to TRUE then give max amount
                          --
                          IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                            l_aid := l_fmast.max_award_amt;
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                            END IF;
                          END IF;

                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_i:'||l_need_i||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_aid:'||l_aid);
                          END IF;

                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF; -- End allow_to_exceed ='need' check
              END IF;
            END IF;
          END IF;  -- End of Single fund

          IF g_sf_packaging <> 'T' THEN

            --if fund uses fm
            IF l_fmast.fm_fc_methd = 'FEDERAL' THEN

                IF NVL(l_fmast.replace_fc,'N') = 'Y' THEN
                  l_need_f := l_need_f + l_rem_rep_efc_f;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'4.l_need_f:'||l_need_f);
                  END IF;
                END IF;

                --award amount = min(fm need,fund max)
                IF l_fmast.max_award_amt IS NOT NULL THEN
                IF l_need_f < l_fmast.max_award_amt THEN
                  l_aid := l_need_f;
                ELSE
                  l_aid := l_fmast.max_award_amt;
                END IF;
                ELSE
                  -- l_fmast.max_award_amt is null, so l_aid is l_need_f
                  l_aid := l_need_f;
                END IF;

                --
                -- if entitlement is set to TRUE then give max amount
                --
                IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                  l_aid := l_fmast.max_award_amt;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                  END IF;
                END IF;

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'since fund uses federal method,aid=min(need_f,fund max)');
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_f: '||l_need_f||' l_fmast.max_award_amt: '||l_fmast.max_award_amt||' l_aid: '||l_aid);
                END IF;

            ELSE
              --if student has awarding profile
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'since fund used institutional method,checking if student has active profile');
              END IF;

              IF hasActiveProfile(l_fabase.base_id) IS NOT NULL THEN
                fnd_message.set_name('IGF','IGF_AP_NO_ACTIVE_PROFILE');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                l_fund_id := l_fund.fund_id;
                l_fund_fail := TRUE;
                l_award_id  := l_fund.award_id;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'student has no active profile');
                END IF;
                EXIT;
              END IF;
              --award amount = min(fm need,imneed, fund max)
              --here im need,fm need, fund max are known
              --so award amount is minimum of these 3
              IF l_fmast.max_award_amt IS NOT NULL THEN
              l_aid := LEAST(l_need_i,LEAST(l_need_f,l_fmast.max_award_amt));
              ELSE
                l_aid := LEAST(l_need_i,l_need_f);
              END IF;

              --
              -- if entitlement is set to TRUE then give max amount
              --
              IF NVL(l_fmast.entitlement,'N') = 'Y' THEN
                l_aid := l_fmast.max_award_amt;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Fund Entitlment is set to Y, so aid = l_fmast.max_award_amt ' || l_fmast.max_award_amt);
                END IF;
              END IF;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'aid=min(need_f,need_i,fund max)');
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_need_i:'||l_need_i||' l_need_f:'||l_need_f||' l_fmast.max_award_amt:'||l_fmast.max_award_amt||' l_aid:'||l_aid);
              END IF;

            END IF;
          END IF; -- End for g_sf_packaging <> 'T'

          -- Get the total amt awarded under current fund from Temp table
          OPEN c_temp(
                      l_process_id ,
                      l_fmast.fund_id ,
                      l_fabase.base_id
                     );
          FETCH c_temp INTO l_temp;
          CLOSE c_temp;
          l_fund_total := l_temp.offered;

          -- Decrease the Awarded Aid upto the extent of the common terms present at the COA Items and at the FUND
          -- Awards should be created for only the common terms for which student has enrolled for the
          -- COA Items and the same terms should be present at the Fund Terms

          -- Get the common terms and sum up the total percentages for calculating the award
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'before proceeding to find total award % - method is:'||lv_method_code);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fund.adplans_id: '||l_fund.adplans_id||' l_fabase.base_id: '||l_fabase.base_id);
          END IF;

          ln_award_perct := 0;
          IF lv_method_code = 'M' THEN

            IF igf_aw_gen_003.check_coa(l_fabase.base_id,g_awd_prd) THEN

              FOR c_get_term_prsnt_rec IN c_get_term_prsnt(l_fund.adplans_id, l_fabase.base_id) LOOP
                ln_award_perct := ln_award_perct + c_get_term_prsnt_rec.ld_perct_num;
              END LOOP;

            ELSE
              ln_award_perct := 100;

            END IF;

          ELSE
            ln_award_perct := 100;

          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'ln_award_perct:'||ln_award_perct);
          END IF;

          get_plan_desc(l_fund.adplans_id,lv_method_name,lv_method_desc);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWD_DIST_PLAN') || ' : ' || lv_method_name);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','DIST_PLAN_METHOD') || ' : ' || lv_method_desc);

          fnd_message.set_name('IGF','IGF_AW_PKG_PERSNT_CALC');
          fnd_message.set_token('PERSNT',ln_award_perct);
          fnd_file.put_line(fnd_file.log,fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'matching term percent ln_award_perct:'||ln_award_perct);
          END IF;
          -- Insert the Fund Awd percentage into the fund awd temp table if the fund is being awarded for the first time.
          IF l_fund_total = 0 THEN
            gn_fund_awd_cnt := NVL(gn_fund_awd_cnt, 0) + 1;
            g_fund_awd_prct.extend;
            g_fund_awd_prct(gn_fund_awd_cnt).base_id   := l_fabase.base_id;
            g_fund_awd_prct(gn_fund_awd_cnt).fund_id   := l_fund.fund_id;
            g_fund_awd_prct(gn_fund_awd_cnt).awd_prct  := ln_award_perct;
          END IF;

          -- Now decrease the amount upto the award percentage
          l_aid := (ln_award_perct * l_aid ) / 100;

          fnd_message.set_name('IGF','IGF_AW_PKG_PERSNT_AMT');
          fnd_message.set_token('AMOUNT',l_aid);
          fnd_file.put_line(fnd_file.log,fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'decreased aid,upto macthing terms is l_aid: '||l_aid||' l_need: '||l_need);
          END IF;

          -- Check if the Fund has the 'Can Replace FC flag '
          -- Check if Replace FC has alerady been applied for the fund
          -- if the l_fund_total has a value that means this is a second round run for the current fund
          IF ( l_fund.replace_fc = 'Y' ) AND ( NOT l_need_set) THEN -- Disb DLD Change
            l_old_need := l_need;
            l_need := l_need + l_rem_rep_efc;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'updated need after funding aid is l_need:'||l_need);
          END IF;
          l_overaward := 0;
          l_remaining_amt := 0;

          --Check whether the fund can be awarded with the Overaward limit set at the fund if the fund available amount is vanished
          l_cur_ovr_awd := NULL;
          OPEN c_cur_ovr_awd( l_fund.fund_id );
          FETCH c_cur_ovr_awd INTO l_cur_ovr_awd;
          CLOSE c_cur_ovr_awd;

          l_overaward := NVL(l_cur_ovr_awd.temp_num_val2,0);
          l_remaining_amt := NVL(l_cur_ovr_awd.temp_num_val1,0);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after checking fund has amount left for disbursments');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'overaward amount l_overaward:'||l_overaward);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund has amount l_remaining_amt:'||l_remaining_amt||' left');
          END IF;

          -- Check if award aid exceeds the available amount, then get the money from overaward limit
          IF l_fund.award_id IS NULL THEN
            IF  NVL(l_aid,0) > l_remaining_amt THEN
              l_aid := l_remaining_amt + l_overaward;
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after checking if packaged award exceeds overaward of aid,l_aid:'||l_aid);
              END IF;
            END IF;
          ELSE
            IF  NVL(l_aid,0) - l_fund.offered_amt > l_remaining_amt THEN
              l_aid := l_remaining_amt + l_overaward;
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after checking if repackaged award exceeds overaward of aid,l_aid:'||l_aid);
              END IF;
            END IF;
          END IF;
          --
          -- If l_aid is zero, it means there is no remaining amount in the fund
          --
          IF l_aid = 0 THEN
             fnd_message.set_name('IGF','IGF_AW_INSUFFCNT_FUND');
             fnd_message.set_token('AMOUNT',0);
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             l_fund_id := l_fund.fund_id;
             l_fund_fail := TRUE;
             l_award_id  := l_fund.award_id;
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'no remaining amount in fund '||l_fund.fund_id);
             END IF;
            EXIT;
          END IF;

          -- Check if it exceed the max amount for fund
          IF l_fmast.max_award_amt IS NOT NULL THEN
            IF  NVL(l_aid,0) > l_fmast.max_award_amt THEN
              l_aid := l_fmast.max_award_amt;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after checking if award exceeds fund max,l_aid:'||l_aid);
            END IF;
          END IF;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'before entitlement check-l_aid:'||l_aid||' g_allow_to_exceed :'||g_allow_to_exceed);
          END IF;
          -- If Entitlement fund then award upto need of the student
          IF (l_fmast.entitlement <>'Y') AND ( NVL(l_aid,0) > NVL(l_need,0)) THEN
            IF g_allow_to_exceed IS NULL THEN
              l_aid := l_need;
            END IF;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'inside entitlement check-l_aid:'||l_aid);
            END IF;
          END IF;

          -- Check for Max Yearly amt
          IF  NVL(l_fmast.max_yearly_amt,0) > 0  THEN
            OPEN c_max_yr_amt(
                              l_fmast.fund_id,
                              l_fabase.base_id
                             ) ;
            FETCH c_max_yr_amt INTO l_max_yr_amt;
            CLOSE c_max_yr_amt;

            IF ( l_max_yr_amt.yr_total + l_aid + l_fund_total )    > l_fmast.max_yearly_amt THEN
              l_aid := (l_fmast.max_yearly_amt ) - ( l_max_yr_amt.yr_total + l_fund_total );
            END IF;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund has max yearly amount l_fmast.max_yearly_amt:'||l_fmast.max_yearly_amt);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_max_yr_amt.yr_total:'||l_max_yr_amt.yr_total);
            END IF;
          END IF;  -- Max Yerly amt

          -- Check for Max NUMBER of Life Terms
          OPEN cur_max_lf_count ( l_fmast.fund_code, l_fabase.person_id);
          FETCH cur_max_lf_count INTO max_lf_count_rec;
          CLOSE cur_max_lf_count;

          OPEN  cur_agg_lf_count( l_fmast.fund_code, l_fabase.person_id );
          FETCH cur_agg_lf_count INTO agg_lf_count_rec;
          CLOSE cur_agg_lf_count;

          max_lf_count_rec.lf_count := agg_lf_count_rec.lf_count + max_lf_count_rec.lf_count;
          max_lf_count_rec.lf_total := agg_lf_count_rec.lf_total + max_lf_count_rec.lf_total;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund has max life terms count max_lf_count_rec.lf_count:'||max_lf_count_rec.lf_count);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fmast.max_life_term:'||l_fmast.max_life_term);
          END IF;

          IF ( max_lf_count_rec.lf_count  >= l_fmast.max_life_term ) THEN

            OPEN c_person_number( l_fabase.person_id );
            FETCH c_person_number INTO l_person_number;
            CLOSE c_person_number;

            fnd_message.set_name('IGF','IGF_AW_PK_EXCEED_LIFE_TERM');
            fnd_message.set_token('PERSON_NUMBER', l_person_number.person_number);
            fnd_message.set_token('FUND_ID',l_fmast.fund_code);
            fnd_file.put_line(fnd_file.log,fnd_message.get);

            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            EXIT;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'fund has max lifeterm amount as l_fmast.max_life_amt:'||l_fmast.max_life_amt);
          END IF;
          -- Check for max life amount
          IF  NVL(l_fmast.max_life_amt,0) > 0  THEN
            IF ( max_lf_count_rec.lf_total + l_aid + l_fund_total ) > l_fmast.max_life_amt THEN
              l_aid := (l_fmast.max_life_amt ) - ( max_lf_count_rec.lf_total + l_fund_total );
            END IF;
          END IF;  -- Max Life amt

          IF l_fmast.entitlement <> 'Y' THEN

            -- Check for Max Grant Amt
            IF ( l_fmast.sys_fund_type ='GRANT' and l_grant_amt <> 0  ) THEN

              l_actual_grant_amt := NVL(l_actual_grant_amt,0)  + l_aid;
              IF l_actual_grant_amt > l_grant_amt THEN
                l_aid := l_aid - ( l_actual_grant_amt - l_grant_amt );
                l_actual_grant_amt := l_grant_amt;
             END IF;

            END IF; -- Max grant chk

            -- Check for Max Work Aid Amt
            IF ( l_fmast.sys_fund_type ='WORK' and l_work_amt <> 0 ) THEN
              l_actual_work_amt := NVL(l_actual_work_amt,0)  + l_aid;
              IF l_actual_work_amt > l_work_amt THEN
                l_aid := l_aid - ( l_actual_work_amt - l_work_amt );
                l_actual_work_amt := l_work_amt;
              END IF;
            END IF; -- Max work chk

            -- Check for Max Self Help Amt
            IF ( l_fmast.self_help ='Y' and l_shelp_amt <> 0 ) THEN
              l_actual_shelp_amt := NVL(l_actual_shelp_amt,0)  + l_aid;

              IF l_actual_shelp_amt > l_shelp_amt THEN
                l_aid := l_aid - ( l_actual_shelp_amt - l_shelp_amt );
                l_actual_shelp_amt := l_shelp_amt;
              END IF;
            END IF; -- Max self chk

            -- Check for Max Gift Aid Amt
            IF ( l_fmast.gift_aid ='Y' and l_gift_amt <> 0 ) THEN
              l_actual_gift_amt := NVL(l_actual_gift_amt,0)  + l_aid;

              IF l_actual_gift_amt > l_gift_amt THEN
                l_aid := l_aid - ( l_actual_gift_amt - l_gift_amt );
                l_actual_gift_amt := l_gift_amt;
              END IF;
            END IF; -- Max Gift Aid

            -- Check for Max Scholarship Amt
            IF ( l_fmast.sys_fund_type ='SCHOLARSHIP' and l_schlp_amt <> 0 ) THEN
              l_actual_schlp_amt := NVL(l_actual_schlp_amt,0)  + l_aid;
              IF l_actual_schlp_amt > l_schlp_amt THEN
                l_aid := l_aid - ( l_actual_schlp_amt - l_schlp_amt );
                l_actual_schlp_amt := l_schlp_amt;
              END IF;
            END IF; -- Max Scholarship chk

            -- Check for amount exceeding net amount slab
            IF NVL(l_max_aid_pkg,0) <> 0 THEN
              l_actual_aid := NVL(l_actual_aid,0)  + l_aid;

              IF l_actual_aid > l_max_aid_pkg THEN
                l_aid := l_aid - ( l_actual_aid - l_max_aid_pkg );
                l_actual_aid := l_max_aid_pkg;
              END IF;
            END IF; -- Net amount Check

          ELSE

            -- Bug 2400556
            IF ( l_fmast.sys_fund_type ='GRANT' and l_grant_amt <> 0  ) THEN
              l_actual_grant_amt := NVL(l_actual_grant_amt,0)  + l_aid;
            END IF;

            -- Bug 2400556
            IF ( l_fmast.sys_fund_type ='WORK' and l_work_amt <> 0 ) THEN
              l_actual_work_amt := NVL(l_actual_work_amt,0)  + NVL(l_aid,0);
            END IF;

            -- Check for Max Self Help Amt
            IF ( l_fmast.self_help ='Y' and l_shelp_amt <> 0 ) THEN
              l_actual_shelp_amt := NVL(l_actual_shelp_amt,0)  + NVL(l_aid,0);
            END IF;

            -- Check for Max Gift Aid Amt
            IF ( l_fmast.gift_aid ='Y' and l_gift_amt <> 0 ) THEN
              l_actual_gift_amt := NVL(l_actual_gift_amt,0)  + NVL(l_aid,0);
            END IF;

            -- Check for Max Scholarship Amt
            IF ( l_fmast.sys_fund_type ='SCHOLARSHIP' and l_schlp_amt <> 0 ) THEN
              l_actual_schlp_amt := NVL(l_actual_schlp_amt,0)  + NVL(l_aid,0);
            END IF;

            IF NVL(l_max_aid_pkg,0) <> 0 THEN
              l_actual_aid := NVL(l_actual_aid,0)  + NVL(l_aid,0);
            END IF;

          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after fund processing, actual amounts are ');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_actual_grant_amt:'||l_actual_grant_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_actual_shelp_amt:'||l_actual_shelp_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_actual_gift_amt:'||l_actual_gift_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_actual_aid:'||l_actual_aid);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_accepted_amt:'||l_accepted_amt);
          END IF;

          -- Check for Max Loan Amt
          IF ( l_fmast.sys_fund_type ='LOAN'  ) THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'initiating loan checks');
            END IF;
            l_std_loan_tab.DELETE;
            OPEN c_std_ln_awd(l_fabase.base_id,l_process_id);
            LOOP
              FETCH c_std_ln_awd INTO l_std_ln_awd_rec;
              EXIT WHEN c_std_ln_awd%NOTFOUND;
              l_std_loan_tab.EXTEND;
              l_reccnt := l_std_loan_tab.COUNT;
              l_std_loan_tab(l_reccnt).fed_fund_code  := l_std_ln_awd_rec.fed_fund_code;
              l_std_loan_tab(l_reccnt).fund_code      := l_std_ln_awd_rec.fund_code;
              l_std_loan_tab(l_reccnt).award_amount   := l_std_ln_awd_rec.offered_amt;
              l_std_loan_tab(l_reccnt).award_date     := l_std_ln_awd_rec.award_date;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug','added fed_fund_code:'||l_std_ln_awd_rec.fed_fund_code
                                                                                                       ||' fund_code:'||l_std_ln_awd_rec.fund_code
                                                                                                       ||' award:'||l_std_ln_awd_rec.offered_amt
                                                                                                       ||' date:'||l_std_ln_awd_rec.award_date
                              );
              END IF;
            END LOOP;
            CLOSE c_std_ln_awd;

            /*
              Fix added for bug 4599103
            */
            IF l_std_loan_tab IS NULL OR l_std_loan_tab.COUNT = 0 THEN
              l_std_loan_tab.EXTEND;
              l_reccnt := l_std_loan_tab.COUNT;
              l_std_loan_tab(l_reccnt).fed_fund_code  := '';
              l_std_loan_tab(l_reccnt).fund_code      := '';
              l_std_loan_tab(l_reccnt).award_amount   := 0;
              l_std_loan_tab(l_reccnt).award_date     := NULL;
            END IF;

            l_msg_name := NULL;

            --Bug ID : 2404111
            --The Perkins loan should not be subjected to Stafford Limits processing
            IF l_fmast.fed_fund_code IN ('DLS','FLS','DLU','FLU') THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'loans fed_fund_code not in PRK,DLP,FLP');
              END IF;
              fnd_message.set_name('IGF','IGF_AW_PKG_CHK_LOAN_LMTS');
              fnd_message.set_token('FUND',l_fmast.fund_code);
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'calling igf_aw_packng_subfns.check_loan_limits');
              END IF;
              igf_aw_packng_subfns.check_loan_limits(
                                                     l_fabase.base_id,
                                                     l_fmast.fed_fund_code,
                                                     NULL,
                                                     l_fund.adplans_id,
                                                     l_aid,
                                                     l_std_loan_tab,
                                                     l_msg_name,
                                                     g_awd_prd,
                                                     'PACKAGING'
                                                    );
              -- Bug 3360702
              -- l_aid is the amount that can be maximum given to the student after checking the loan limits.
              -- If l_aid = 0 then either there is no available loan amount  or some of the error that class standing etc. has failed.
              -- depending on the returned l_msg_name
              -- If l_aid < 0 then some of the stafford loan limit check has failed and the corresponding message is in l_msg_name
              -- In the log file the amount that is returned from the check_loan_limits
              IF l_aid > 0 THEN
                fnd_message.set_name('IGF','IGF_AW_CHK_LOAN_LMT_AMT');
                fnd_message.set_token('AMOUNT',l_aid);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;

            END IF;

            IF l_aid = 0 and l_msg_name IS NULL THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after calling check_loan_limts l_aid=0');
              END IF;
              fnd_message.set_name('IGF','IGF_AW_PKG_NO_LOAN_AMT');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              l_fund_id := l_fund.fund_id;
              l_fund_fail := TRUE;
              l_award_id  := l_fund.award_id;
              EXIT;
            END IF; -- This condition is added as part of dl loan limit check

            IF l_aid <= 0 and l_msg_name IS NOT NULL THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after calling checkloan_limits l_msg_name:'||l_msg_name);
              END IF;
              IF l_aid = 0 THEN
                fnd_message.set_name('IGF',l_msg_name);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              ELSE
                fnd_message.set_name('IGF',l_msg_name);
                fnd_message.set_token('FUND_CODE',l_fmast.fed_fund_code);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;
              l_fund_id := l_fund.fund_id;
              l_fund_fail := TRUE;
              l_award_id  := l_fund.award_id;
              EXIT;
            END IF; -- This condition is added as part of dl loan limit check

            -- museshad (Build FA 163)
            IF l_fmast.fed_fund_code IN ('GPLUSDL','GPLUSFL') THEN

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Calling chk_gplus_loan_limits');
                END IF;

              IF NOT chk_gplus_loan_limits(
                                            p_base_id           =>    l_fabase.base_id,
                                            p_fed_fund_code     =>    l_fmast.fed_fund_code,
                                            p_adplans_id        =>    l_fund.adplans_id,
                                            p_aid               =>    l_aid,
                                            p_std_loan_tab      =>    l_std_loan_tab,
                                            p_msg_name          =>    l_msg_name
                                          ) THEN
                -- Failed
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'chk_gplus_loan_limits check FAILED with l_msg_name '||l_msg_name);
                END IF;

                IF l_msg_name = 'IGF_AW_LOAN_LMT_NOT_EXHST' THEN
                  fnd_message.set_name('IGF',l_msg_name);
                  fnd_message.set_token('FUND',l_fmast.fed_fund_code);
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                ELSE
                  IF l_msg_name IS NOT NULL THEN
                    fnd_message.set_name('IGF',l_msg_name);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                  END IF;
                END IF;

                l_fund_id := l_fund.fund_id;
                l_fund_fail := TRUE;
                l_award_id  := l_fund.award_id;
                EXIT;
              ELSE
                -- Passed
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'chk_gplus_loan_limits check PASSED');
                END IF;
              END IF;     -- <<chk_gplus_loan_limits>>
            END IF;       -- <<l_fmast.fed_fund_code IN ('GPLUSDL','GPLUSFL')>>
            -- museshad (Build FA 163)

           IF l_fmast.entitlement <> 'Y' THEN

              IF (  l_loan_amt <> 0 ) THEN
                l_actual_loan_amt := NVL(l_actual_loan_amt,0)  + l_aid;

                IF l_actual_loan_amt > l_loan_amt THEN
                  l_aid := l_aid - ( l_actual_loan_amt - l_loan_amt );
                  l_actual_loan_amt := l_loan_amt;
                END IF;
              END IF;

            ELSE

              -- Bug 2400556
              IF (  l_loan_amt <> 0 ) THEN
                l_actual_loan_amt := NVL(l_actual_loan_amt,0)  + l_aid;
              END IF;


            END IF;   -- entitlement check
          END IF; -- Max loan chk
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after calling check_loan_limits l_actual_loan_amt:'||l_actual_loan_amt);
          END IF;
          -- If Aid is less than Minimum amount that can be awarded
          -- Validate Award Group Min Amt check. ( Always Award Groups is higher priority than fund level)
          IF  NVL(l_aid,0) < NVL(l_fund.min_award_amt,0) AND g_sf_packaging <> 'T' THEN
            l_aid := 0;
            fnd_message.set_name('IGF','IGF_AW_MIN_AWD_CHK_AWDGRP');
            fnd_message.set_token('FUND',l_fmast.fund_code);
            fnd_message.set_token('AWDGRP',l_fabase.target_group);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'skipping fund as aid < awd grp min');
            END IF;
            EXIT;
          -- Validate Fund level Group Min Amt check.

          ELSIF  NVL(l_aid,0) < NVL(l_fmast.min_award_amt,0) THEN
            l_aid := 0;
            fnd_message.set_name('IGF','IGF_AW_MIN_AWD_CHECK');
            fnd_message.set_token('FUND',l_fmast.fund_code);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'skipping fund as aid < fund min');
            END IF;
            EXIT;

          END IF;  -- End of Min Award Check

          -- Incase of No Need Skip fund
          IF ( l_aid <= 0) THEN
            fnd_message.set_name('IGF','IGF_AW_NO_AID');
            fnd_message.set_token('FUND',l_fmast.fund_code);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            l_aid := 0;
            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'skipping fund as aid amount <= 0');
            END IF;
            EXIT;
          END IF;

          --If Packaging Status is Accepted or Estimated Accepted then set the Accepted amt
          IF (l_fmast.pckg_awd_stat = 'ACCEPTED')  THEN
            l_accepted_amt := l_aid;
          ELSE
            l_accepted_amt := NULL;
          END IF;

          -- Updating Remaining and the overaward amount
          l_remaining_amt := l_remaining_amt - NVL( l_accepted_amt, l_aid );

          -- Person awarded from the over award amount
          IF ( l_remaining_amt < 0 ) THEN
            l_overaward := l_overaward + l_remaining_amt;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after awarding updating amount for the fund as l_remaining_amt:'||l_remaining_amt||' l_overaward:'||l_overaward);
          END IF;

          igf_aw_award_t_pkg.update_row(
                                        x_rowid              => l_cur_ovr_awd.row_id,
                                        x_process_id         => l_cur_ovr_awd.process_id,
                                        x_sl_number          => l_cur_ovr_awd.sl_number,
                                        x_fund_id            => l_cur_ovr_awd.fund_id,
                                        x_base_id            => l_cur_ovr_awd.base_id,
                                        x_offered_amt        => l_cur_ovr_awd.offered_amt,
                                        x_accepted_amt       => l_cur_ovr_awd.accepted_amt,
                                        x_paid_amt           => l_cur_ovr_awd.paid_amt,
                                        x_need_reduction_amt => l_cur_ovr_awd.need_reduction_amt,
                                        x_flag               => l_cur_ovr_awd.flag,
                                        x_temp_num_val1      => l_remaining_amt,
                                        x_temp_num_val2      => l_overaward,
                                        x_temp_char_val1     => l_cur_ovr_awd.temp_char_val1,
                                        x_tp_cal_type        => l_cur_ovr_awd.tp_cal_type,
                                        x_tp_sequence_number => l_cur_ovr_awd.tp_sequence_number,
                                        x_ld_cal_type        => l_cur_ovr_awd.ld_cal_type,
                                        x_ld_sequence_number => l_cur_ovr_awd.ld_sequence_number,
                                        x_mode               => 'R',
                                        x_adplans_id         => l_cur_ovr_awd.adplans_id,
                                        x_app_trans_num_txt  => l_cur_ovr_awd.app_trans_num_txt,
                                        x_award_id           => l_cur_ovr_awd.award_id,
                                        x_lock_award_flag    => l_cur_ovr_awd.lock_award_flag,
                                        x_temp_val3_num      => l_cur_ovr_awd.temp_val3_num,
                                        x_temp_val4_num      => l_cur_ovr_awd.temp_val4_num,
                                        x_temp_char2_txt     => l_cur_ovr_awd.temp_char2_txt,
                                        x_temp_char3_txt     => l_cur_ovr_awd.temp_char3_txt
                                       );

          ----------------------------------------------
          -- Completed Non PELL funds
          ----------------------------------------------

        END IF;  -- End of Pell check i.e (IF (l_fmast.fed_fund_code = 'PELL'))

        -- Insert Data INTO the Temporary Table
        IF NVL(l_aid,0) > 0 THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after awarding,inserting to igf_aw_award_t with flag:AW and l_aid: '||l_aid||' ln_award_perct:'||ln_award_perct||
                           'lock_award_flag:'||l_fund.lock_award_flag);
          END IF;
          IF l_fund.award_id IS NULL THEN
            --Update the Overaward record in the Temp Award table for this fund
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'inserting a new award with flag=AW'||
                            'process_id:'||l_process_id||
                            'fund_id:'||l_fmast.fund_id||
                            'base_id:'||l_fabase.base_id);
            END IF;
            igf_aw_award_t_pkg.insert_row(
                                          x_rowid              => lv_rowid ,
                                          x_process_id         => l_process_id ,
                                          x_sl_number          => l_sl_number,
                                          x_fund_id            => l_fmast.fund_id,
                                          x_base_id            => l_fabase.base_id,
                                          x_offered_amt        => l_aid * 100 / ln_award_perct,
                                          x_accepted_amt       => l_accepted_amt * 100 / ln_award_perct,
                                          x_paid_amt           => NULL ,
                                          x_need_reduction_amt => NULL,
                                          x_flag               => 'AW',
                                          x_temp_num_val1      => NULL,
                                          x_temp_num_val2      => NULL,
                                          x_temp_char_val1     => NULL,
                                          x_tp_cal_type        => NULL,
                                          x_tp_sequence_number => NULL,
                                          x_ld_cal_type        => NULL,
                                          x_ld_sequence_number => NULL,
                                          x_mode               => 'R',
                                          x_adplans_id         => l_fund.adplans_id,
                                          x_app_trans_num_txt  => NULL,
                                          x_award_id           => NULL,
                                          x_lock_award_flag    => l_fund.lock_award_flag,
                                          x_temp_val3_num      => NULL,
                                          x_temp_val4_num      => NULL,
                                          x_temp_char2_txt     => NULL,
                                          x_temp_char3_txt     => NULL
                                         );
          ELSE
            OPEN c_temp_awd(l_fund.award_id);
            FETCH c_temp_awd INTO l_temp_awd;
            CLOSE c_temp_awd;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'updating old award with flag=AW'||
                            'process_id:'||l_temp_awd.process_id||
                            'fund_id:'||l_fmast.fund_id||
                            'base_id:'||l_fabase.base_id||
                            'award_id:'||l_temp_awd.award_id
                            );
            END IF;
            igf_aw_award_t_pkg.update_row(
                                          x_rowid              => l_temp_awd.row_id,
                                          x_process_id         => l_temp_awd.process_id,
                                          x_sl_number          => l_temp_awd.sl_number,
                                          x_fund_id            => l_fmast.fund_id,
                                          x_base_id            => l_fabase.base_id,
                                          x_offered_amt        => l_aid * 100 / ln_award_perct,
                                          x_accepted_amt       => l_accepted_amt * 100 / ln_award_perct,
                                          x_paid_amt           => l_temp_awd.paid_amt,
                                          x_need_reduction_amt => l_temp_awd.need_reduction_amt,
                                          x_flag               => 'AW',
                                          x_temp_num_val1      => l_temp_awd.temp_num_val1,
                                          x_temp_num_val2      => l_temp_awd.temp_num_val2,
                                          x_temp_char_val1     => l_temp_awd.temp_char_val1,
                                          x_tp_cal_type        => l_temp_awd.tp_cal_type,
                                          x_tp_sequence_number => l_temp_awd.tp_sequence_number,
                                          x_ld_cal_type        => l_temp_awd.ld_cal_type,
                                          x_ld_sequence_number => l_temp_awd.ld_sequence_number,
                                          x_mode               => 'R',
                                          x_adplans_id         => l_fund.adplans_id,
                                          x_app_trans_num_txt  => l_temp_awd.app_trans_num_txt,
                                          x_award_id           => l_temp_awd.award_id,
                                          x_lock_award_flag    => l_temp_awd.lock_award_flag,
                                          x_temp_val3_num      => l_temp_awd.temp_val3_num,
                                          x_temp_val4_num      => l_temp_awd.temp_val4_num,
                                          x_temp_char2_txt     => l_temp_awd.temp_char2_txt,
                                          x_temp_char3_txt     => l_temp_awd.temp_char3_txt
                                         );
          END IF;

          -- museshad (FA 163)
          -- If fund is DLS/FLS, then the reduced need(reduced bcoz of VA30/Americorps awds) must be
          -- reset to the proper need so that the next fund gets the right need.
          IF l_fmast.fed_fund_code IN ('DLS','FLS') AND l_reset_need THEN
            IF l_fmast.fm_fc_methd = 'FEDERAL' THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                              'Fund is Subsidized loan and Student has VA30/AMRICORPS awd, so need (FEDERAL) was increased to ' ||l_need|| '. Resetting Need.');
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'After resetting, Need= ' ||l_need_bkup_f);
              END IF;

              l_need    :=  l_need_bkup_f;
            ELSE
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                              'Fund is Subsidized loan and Student has VA30/AMRICORPS awd, so need (INSTITUTIONAL) was reduced to ' ||l_need|| '. Resetting Need.');
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'After resetting, Need= ' ||l_need_bkup_i);
              END IF;

              l_need    :=  l_need_bkup_i;
              l_need_i  :=  l_need_bkup_i;
            END IF;   -- << l_fmast.fm_fc_methd >>
          END IF;   -- << l_fmast.fed_fund_code >>
          -- museshad (FA 163)

          IF ( l_fund.replace_fc = 'Y' ) AND ( NOT l_need_set) THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                                                     'need set : l_need:'||l_need||
                                                     'l_rem_rep_efc:'||l_rem_rep_efc);
            END IF;
            l_need := NVL(l_need,0) - NVL(l_rem_rep_efc,0);
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                                                     'need set :need recalculated as: l_need:'||l_need);
            END IF;
          END IF;

          --Update Remaining FC if the Replace FC was checked
          IF l_fmast.fm_fc_methd = 'FEDERAL' THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                             '@@l_fmast.fm_fc_methd:'||l_fmast.fm_fc_methd||
                             'l_fund.replace_fc:'||l_fund.replace_fc||
                             'l_fmast.update_need:'||l_fmast.update_need||
                             'l_aid:'||l_aid||
                             'l_rem_rep_efc:'||l_rem_rep_efc||
                             'l_need:'||l_need||
                             'l_old_need:'||l_old_need
                            );
            END IF;
            IF l_fund.replace_fc = 'Y'  AND l_fmast.update_need = 'Y' THEN

              l_rem_rep_efc := NVL(l_rem_rep_efc,0) - NVL(l_aid,0);
              IF l_rem_rep_efc < 0 THEN
                l_rem_rep_efc := 0;
              END IF;

--              l_need_f := NVL(l_old_need,0);
              l_need_f := NVL(l_need,0) - (NVL(l_aid,0) - (NVL(l_efc,0) - NVL(l_rem_rep_efc,0)) );
              l_need_VB_AC_f  :=  NVL(l_need_VB_AC_f,0) - (NVL(l_aid,0) - (NVL(l_efc,0) - NVL(l_rem_rep_efc,0)));
              l_need_i := NVL(l_need_i,0) - NVL(l_aid,0);
              l_need_VB_AC_i  :=  NVL(l_need_VB_AC_i,0) - NVL(l_aid,0);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                              'Update Need and Replace FC are set, l_rem_rep_efc: '||l_rem_rep_efc
                              ||' l_need_f: '||l_need_f||' l_need_i: '||l_need_i
                              ||' l_need_VB_AC_f: '||l_need_VB_AC_f||' l_need_VB_AC_i: '||l_need_VB_AC_i);
              END IF;

            ELSIF l_fund.replace_fc = 'Y' THEN

              l_rem_rep_efc := NVL(l_rem_rep_efc,0) - NVL(l_aid,0);
              IF l_rem_rep_efc < 0 THEN
                l_need := l_need + l_rem_rep_efc;
                l_rem_rep_efc := 0;
              END IF;

--              l_need_f := NVL(l_old_need,0);
              l_need_f := l_need;
              l_need_i := l_need_i;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Only Replace FC is set, l_rem_rep_efc: '||l_rem_rep_efc||' l_need_f: '||l_need_f||' l_need_i: '||l_need_i);
              END IF;

            ELSIF l_fmast.update_need = 'Y' THEN
              l_need_f := NVL(l_need,0) - NVL(l_aid,0);
              l_need_VB_AC_f  :=  NVL(l_need_VB_AC_f,0) - NVL(l_aid,0);
              l_need_i := NVL(l_need_i,0) - NVL(l_aid,0);
              l_need_VB_AC_i  :=  NVL(l_need_VB_AC_i,0) - NVL(l_aid,0);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                              'Only Update Need is set, l_rem_rep_efc: '||l_rem_rep_efc
                              ||' l_need_f: '||l_need_f||' l_need_i: '||l_need_i
                              ||' l_need_VB_AC_f: '||l_need_VB_AC_f|| 'l_need_VB_AC_i: '||l_need_VB_AC_i);
              END IF;

            ELSE
              l_need_f := l_need_f;
              l_need_i := l_need_i;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Both Update Need and Replace FC are NOT set, l_rem_rep_efc: '||l_rem_rep_efc||' l_need_f: '||l_need_f||' l_need_i: '||l_need_i);
              END IF;

            END IF;

          ELSIF l_fmast.fm_fc_methd = 'INSTITUTIONAL' THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                             '@@l_fmast.fm_fc_methd:'||l_fmast.fm_fc_methd||
                             'l_fund.replace_fc:'||l_fund.replace_fc||
                             'l_fmast.update_need:'||l_fmast.update_need||
                             'l_aid:'||l_aid||
                             'l_rem_rep_efc:'||l_rem_rep_efc||
                             'l_need:'||l_need||
                             'l_old_need:'||l_old_need
                            );
            END IF;
            IF l_fmast.update_need = 'Y' THEN
              l_need_i := NVL(l_need,0) - NVL(l_aid,0);
              l_need_VB_AC_i  :=  NVL(l_need_VB_AC_i,0) - NVL(l_aid,0);
              l_need_f := NVL(l_need_f,0) - NVL(l_aid,0);
              l_need_VB_AC_f  :=  NVL(l_need_VB_AC_f,0) - NVL(l_aid,0);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                              'Only Update Need is set, l_rem_rep_efc: '||l_rem_rep_efc
                              ||' l_need_f: '||l_need_f||' l_need_i: '||l_need_i
                              ||' l_need_VB_AC_f: '||l_need_VB_AC_f||' l_need_VB_AC_i: '||l_need_VB_AC_i);
              END IF;
            ELSE
              l_need_i := l_need;
              l_need_f := l_need_f;
            END IF;

          END IF;

          -- Update the Need and Remaining EFC values for all Need and Already Awarded funds which are loaded in the temp table
          -- for the same student in the same methodology
          FOR l_rem_efc IN c_rem_efc LOOP

              IF l_rem_efc.temp_char_val1 = 'INSTITUTIONAL' THEN

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after awarding,updating igf_aw_awrd_t (ONLY INSTITUTIONAL) with l_need_i :'||l_need_i|| ' l_need_VB_AC_i: ' ||l_need_VB_AC_i);
                END IF;

                igf_aw_award_t_pkg.update_row(
                                              x_rowid              => l_rem_efc.row_id ,
                                              x_process_id         => l_rem_efc.process_id ,
                                              x_sl_number          => l_rem_efc.sl_number,
                                              x_fund_id            => l_rem_efc.fund_id,
                                              x_base_id            => l_rem_efc.base_id,
                                              x_offered_amt        => l_rem_efc.offered_amt,
                                              x_accepted_amt       => l_rem_efc.accepted_amt,
                                              x_paid_amt           => l_rem_efc.paid_Amt,
                                              x_need_reduction_amt => l_rem_efc.need_reduction_amt,
                                              x_flag               => l_rem_efc.flag,
                                              x_temp_num_val1      => l_rem_efc.temp_num_val1,
                                              x_temp_num_val2      => NVL(l_need_i,0),
                                              x_temp_char_val1     => l_rem_efc.temp_char_val1,
                                              x_tp_cal_type        => NULL,
                                              x_tp_sequence_number => NULL,
                                              x_ld_cal_type        => NULL,
                                              x_ld_sequence_number => NULL,
                                              x_mode               => 'R',
                                              x_adplans_id         => l_rem_efc.adplans_id,
                                              x_app_trans_num_txt  => l_rem_efc.app_trans_num_txt,
                                              x_award_id           => l_rem_efc.award_id,
                                              x_lock_award_flag    => l_rem_efc.lock_award_flag,
                                              x_temp_val3_num      => NVL(l_need_VB_AC_i,0),
                                              x_temp_val4_num      => l_rem_efc.temp_val4_num,
                                              x_temp_char2_txt     => l_rem_efc.temp_char2_txt,
                                              x_temp_char3_txt     => l_rem_efc.temp_char3_txt
                                             );

              ELSIF l_rem_efc.temp_char_val1 = 'FEDERAL' THEN

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,
                                'after awarding,updating igf_aw_awrd_t (ONLY FEDERAL) with l_rem_rep_efc:'||l_rem_rep_efc
                                ||' l_need_f :'||l_need_f|| ' l_need_VB_AC_f: ' ||l_need_VB_AC_f);
                END IF;

                igf_aw_award_t_pkg.update_row(
                                              x_rowid              => l_rem_efc.row_id ,
                                              x_process_id         => l_rem_efc.process_id ,
                                              x_sl_number          => l_rem_efc.sl_number,
                                              x_fund_id            => l_rem_efc.fund_id,
                                              x_base_id            => l_rem_efc.base_id,
                                              x_offered_amt        => l_rem_efc.offered_amt,
                                              x_accepted_amt       => l_rem_efc.accepted_amt,
                                              x_paid_amt           => l_rem_efc.paid_Amt,
                                              x_need_reduction_amt => l_rem_efc.need_reduction_amt,
                                              x_flag               => l_rem_efc.flag,
                                              x_temp_num_val1      => NVL(l_rem_rep_efc,0),
                                              x_temp_num_val2      => NVL(l_need_f,0),
                                              x_temp_char_val1     => l_rem_efc.temp_char_val1,
                                              x_tp_cal_type        => NULL,
                                              x_tp_sequence_number => NULL,
                                              x_ld_cal_type        => NULL,
                                              x_ld_sequence_number => NULL,
                                              x_mode               => 'R',
                                              x_adplans_id         => l_rem_efc.adplans_id,
                                              x_app_trans_num_txt  => l_rem_efc.app_trans_num_txt,
                                              x_award_id           => l_rem_efc.award_id,
                                              x_lock_award_flag    => l_rem_efc.lock_award_flag,
                                              x_temp_val3_num      => NVL(l_need_VB_AC_f,0),
                                              x_temp_val4_num      => l_rem_efc.temp_val4_num,
                                              x_temp_char2_txt     => l_rem_efc.temp_char2_txt,
                                              x_temp_char3_txt     => l_rem_efc.temp_char3_txt
                                             );

              END IF;

          END LOOP;  -- End of Loop c_rem_efc

        END IF;
        EXIT;

      END LOOP;
      CLOSE c_fmast;

      EXIT WHEN l_fund_fail = TRUE;

    END LOOP;  -- Main loop
    CLOSE c_fund;

    /*
      Do all the FSEOG Fund checks.
    */
    /* Code commented as part of FA126 Multiple Financial Aid Offices Build
       Bug 3102439
    */
    /*
    -- ssawhney FISAP DLD
    IF ( NOT l_fund_fail ) THEN  -- *1

      OPEN c_match_method;
      FETCH c_match_method INTO l_method_rec;
      CLOSE c_match_method;

      l_method := l_method_rec.fseog_match_mthd; -- this will be the FSEOG contribution
      l_pct    := l_method_rec.fseog_fed_pct;

      IF l_method = 'INDV_MATCH' THEN -- proceed -- *2

        -- get if any fund of type FSEOG is present in the base id
        OPEN c_find_fseog(l_fabase.base_id, l_process_id);
        FETCH c_find_fseog INTO l_fseog_rec;
        l_fseog_cnt := l_fseog_rec.cnt;
        l_fund_id := l_fseog_rec.fund_id;
        CLOSE c_find_fseog;

        IF NVL(l_fseog_cnt,0) <> 0 THEN  -- *3

          -- this means an FSEOG fund exists for the baseid
          -- now get the SUM for the FSEOG FUND

          OPEN c_get_fund_sum(
                              l_fund_id,
                              l_fabase.base_id,
                              l_process_id
                             );
          FETCH c_get_fund_sum INTO l_fseog_sum;
          CLOSE c_get_fund_sum;

          -- now get the list of matched fund ids
          OPEN c_find_match( l_fabase.ci_cal_type, l_fabase.ci_sequence_number);

          l_total_match_amnt := 0; -- reset the variable
          LOOP   -- there can be more than one fund ids that match this
            FETCH c_find_match INTO l_match_fund_id;
            EXIT WHEN c_find_match%NOTFOUND;

            -- for every match id get the sum of the fund amount
            OPEN c_get_fund_sum(
                                l_match_fund_id,
                                l_fabase.base_id,
                                l_process_id
                               );
            l_match_sum :=0;

            LOOP -- Added as part of disb build
              FETCH c_get_fund_sum INTO l_match_sum;
              EXIT WHEN c_get_fund_sum%NOTFOUND;
              l_total_match_amnt := NVL(l_total_match_amnt,0) + NVL(l_match_sum,0);
            END LOOP; -- Added as part of disb build;

            CLOSE c_get_fund_sum;

          END LOOP;
          CLOSE c_find_match;

          l_total_fund_amnt := NVL(l_total_match_amnt,0) + NVL(l_fseog_sum,0);

          -- this amount is the total fund amount and should be 100%.
          -- get total match funds percentage
          l_match_pct := ROUND(100 - NVL(l_pct,0));

          -- get the estimated match fund amount
          l_est_match_amnt := (l_total_fund_amnt*l_match_pct)/100;

          --  now compare the amounts
          IF NVL(l_total_match_amnt,0) < NVL(l_est_match_amnt,0) THEN

            -- since total matching fund amount is LESS than the amount estimated from
            -- the PERCENTAGE defined in the setup. THe FSEOG fund is marked as failed.
            -- set out NOCOPY varaibles. l_fund_id is already set to the FSEOG Fund Id
            -- If the matching fails, all the occurrence of FSEOG funds need to be
            -- deleted in the award_t table, so seq_no doesnt matter. Pass it as -1.

            l_seq_no := -1;
            l_fund_fail := TRUE;
            IF ( l_run_mode = 'D') THEN
              fnd_message.set_name('IGF','IGF_AW_FSEOG_MATCH_PCT');
              fnd_message.set_token('FUND',to_char(l_fund_id));
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            END IF;
          END IF;

        END IF;  -- *3
      END IF; -- *2

    END IF; -- *1
    -- ssawhney code end.

    */
    /*
      Fund Awards are calculated and they are ready to award. There will be multiple instances of the same fund
      in the Temp Table, these should be clubbed into a single award. So an final will be created in the
      Temp table with the falg status as 'FL' with the consolidated amounts.

      1. Below Dynamic cursor fetches the records based on the Single fund proceess or Packaging Process
      2. For the consolidated Award Amounts apply the rounding factor specified at the fund level
      3. After rounding, Check the for the Min and Max amount checks ( Note : Not necessary for PELL as PELL amounts is from PELL marrix)
      4. Remove all these consolidated funds from the temporary table ( flag = 'CF' )
      5. Update the running totals in the PL/SQL table for the base_id and Fund id combination
      6. Insert a consolidated Record for the fund with the falg as 'FL'
    */
    IF ( NOT l_fund_fail ) THEN

      -- Get Consolidated Totals for each fund and validate the consolidated checks
      IF g_sf_packaging = 'F' THEN

      OPEN c_awd_grp FOR
        SELECT awdt.fund_id,
               fmast.fund_code,
               SUM(NVL(awdt.offered_amt,0)) offered_amt ,
               SUM(awdt.accepted_amt) accepted_amt ,
               COUNT(*) total,
               frml.seq_no,
               awdt.adplans_id,
               awdt.award_id,
               awdt.lock_award_flag
          FROM igf_aw_award_t awdt ,
               igf_aw_fund_mast fmast,
               (SELECT MIN(awdt1.temp_char_val1) seq_no,
                       awdt1.fund_id fund_id
                  FROM igf_aw_award_t awdt1
                 WHERE awdt1.process_id  = l_process_id
                   AND awdt1.base_id     = l_fabase.base_id
                   AND awdt1.flag        = 'AW'
                 GROUP BY awdt1.fund_id) frml
         WHERE awdt.process_id    = l_process_id
           AND awdt.base_id       = l_fabase.base_id
           AND fmast.fund_id      = awdt.fund_id
           AND awdt.flag          = 'AW'
           AND frml.fund_id       = fmast.fund_id
      GROUP BY awdt.fund_id,
               awdt.adplans_id,
               fmast.fund_code,
               awdt.base_id,
               frml.seq_no,
               awdt.award_id,
               awdt.lock_award_flag
      ORDER BY frml.seq_no;


      ELSIF g_sf_packaging = 'T' THEN

        OPEN c_awd_grp FOR
        SELECT awdt.fund_id,
               fmast.fund_code,
               SUM(NVL(awdt.offered_amt,0)) offered_amt ,
               SUM(awdt.accepted_amt) accepted_amt ,
               COUNT(*) total,
               1,
               awdt.adplans_id,
               awdt.award_id,
               awdt.lock_award_flag
          FROM igf_aw_award_t awdt,
               igf_aw_fund_mast fmast
         WHERE awdt.process_id   = l_process_id
           AND awdt.base_id      = l_fabase.base_id
           AND awdt.fund_id      = fmast.fund_id
           AND awdt.flag         = 'AW'
      GROUP BY awdt.fund_id,
               awdt.adplans_id,
               fmast.fund_code,
               awdt.award_id,
               awdt.lock_award_flag;

      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'opened c_awd_grp');
      END IF;

      -- This loop will execute for each fund id once. This will group all the funds from the temp table
      LOOP

        FETCH c_awd_grp INTO l_awd_grp;
        EXIT WHEN c_awd_grp%NOTFOUND;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'===fetched c_awd_grp,fund_id:'||l_awd_grp.fund_id||' aid:'||l_awd_grp.offered_amt||
                        'l_awd_grp.lock_award_flag:'||l_awd_grp.lock_award_flag||'===');
        END IF;

        IF NVL(l_awd_grp.accepted_amt,0) = 0 THEN
          l_aid := l_awd_grp.offered_amt;
        ELSE
          l_aid := l_awd_grp.accepted_amt;
        END IF;
        l_accepted_amt := l_awd_grp.accepted_amt;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_aid:'||l_aid);
        END IF;

        OPEN c_fmast(l_awd_grp.fund_id );
        FETCH c_fmast INTO l_fmast;
        CLOSE c_fmast;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'opened and fetched c_fmast for fund_id:'||l_awd_grp.fund_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_fmast.roundoff_fact:'||l_fmast.roundoff_fact);
        END IF;
        -- Round off on consolidated totals per fund as set in Fund Manager
        IF l_fmast.roundoff_fact IS NOT NULL THEN

          IF LTRIM(RTRIM(NVL(l_fmast.roundoff_fact,'0'))) = '0.5' THEN
            -- museshad (Build# FA157 - Bug# 4382371)
            -- From FA 157 lookup-code '0.5' refers to 'Round off To Two Decimals'
            -- Changed the Round factor to 2 decimal places for this.
            l_aid := ROUND(l_aid, 2);         -- l_aid := ROUND(l_aid/0.5) * 0.5;
            l_round_tol_ant := 0.5;

          ELSIF LTRIM(RTRIM(NVL(l_fmast.roundoff_fact,'0'))) = '1' THEN
            l_aid := ROUND( l_aid );
            l_round_tol_ant := 1;

          ELSIF LTRIM(RTRIM(NVL(l_fmast.roundoff_fact,'0'))) = '10' THEN
            l_aid := ROUND(  l_aid/10 ) * 10 ;
            l_round_tol_ant := 10;

          ELSIF LTRIM(RTRIM(NVL(l_fmast.roundoff_fact,'0'))) = '50' THEN
            l_aid := ROUND(  l_aid/50 ) * 50 ;
            l_round_tol_ant := 50;

          ELSIF LTRIM(RTRIM(NVL(l_fmast.roundoff_fact,'0'))) = '100' THEN
            l_aid := ROUND(  l_aid/100 ) * 100 ;
            l_round_tol_ant := 100;

          ELSE
            l_round_tol_ant := 0;

          END IF;

        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after rouding off aid amount,l_aid:'||l_aid||' l_round_tol_ant:'||l_round_tol_ant);
        END IF;

        IF l_fmast.fed_fund_code <> 'PELL' THEN
          -- After rounding off now Check for Maximum Fund Check

          IF l_aid > l_fmast.max_award_amt THEN
            -- Aid can only be given to the extent of max award amt
            l_aid := l_aid - l_round_tol_ant ;
          END IF;

          -- After rounding off now Check for Minimum Fund Check
          IF ( l_aid < l_fmast.min_award_amt ) OR ( l_aid < 0 ) THEN
            IF ( l_run_mode = 'D') THEN
              fnd_message.set_name('IGF','IGF_AW_MIN_AWD_CHECK');
              fnd_message.set_token('FUND',l_fmast.fund_code);
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            END IF;
            l_fund_id := l_fund.fund_id;
            l_fund_fail := TRUE;
            l_award_id  := l_fund.award_id;
            EXIT;
          END IF;
        END IF;

        -- Clear out Individiual Values and Insert Groupwise values / of One per fund ID
        -- after applying Round Off Rule
        OPEN c_awd_grp_funds(
                             l_awd_grp.fund_id,
                             l_fabase.base_id,
                             l_process_id
                            );
        LOOP

          FETCH c_awd_grp_funds INTO l_awd_grp_funds;
          EXIT WHEN c_awd_grp_funds%NOTFOUND;
          igf_aw_award_t_pkg.delete_row(l_awd_grp_funds.row_id);
        END LOOP;
        CLOSE c_awd_grp_funds;

         -- Insert one consolidated Value per fund ID
        IF NVL(l_aid,0) > 0 THEN

          lv_rowid := NULL;
          l_sl_number := NULL;

          IF NVL(l_accepted_amt,0) > 0 THEN
            l_accepted_amt := l_aid;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Before Determining Over Award with l_aid : '||l_aid);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'before checking overaward situation-fund uses '||l_fmast.fm_fc_methd||'with aid '||l_aid||' l_need_f:'||l_need_f||' l_need_i:'||l_need_i);
          END IF;
          -- Check whether the award leads to Over Award, then set the indicator with the HOLD or NO HOLD
          g_over_awd := NULL;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'checking aid > need!l_aid:'||l_aid||' l_need_f:'||l_need_f);
            END IF;

-- ????           IF  NVL(l_aid,0) > NVL(l_need_f,0) THEN
            IF  NVL(l_need_f,0) < 0 THEN

                IF l_post = 'Y' THEN
                  g_over_awd := 'NO HOLD';
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_post=Y,g_over_awd=NO HOLD');
                  END IF;
                ELSE
                  g_over_awd := 'HOLD';
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_post <> Y,g_over_awd=HOLD');
                  END IF;
                END IF;

            END IF;  -- End of Over Award Hold

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'after determining overaward,l_post:'||l_post||' g_over_awd:'||g_over_awd);
          END IF;

          -- Update the running totals for the student
          IF NVL(g_awarded_aid.COUNT,0) = 0 THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'updating running totals - extending g_awarded_aid');
            END IF;
            l_cnt := 1;
            g_awarded_aid.extend;
            g_awarded_aid(l_cnt).base_id     := l_fabase.base_id;
            g_awarded_aid(l_cnt).need_f      := NVL(igf_aw_gen_004.need_f(l_fabase.base_id,g_awd_prd),0);
            g_awarded_aid(l_cnt).awarded_aid := NVL(l_aid,0);
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'set g_awarded_aid('||l_cnt||').base_id:'||g_awarded_aid(l_cnt).base_id);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'set g_awarded_aid('||l_cnt||').need_f:'||g_awarded_aid(l_cnt).need_f);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'set g_awarded_aid('||l_cnt||').awarded_aid:'||g_awarded_aid(l_cnt).awarded_aid);
            END IF;

          ELSIF NVL(g_awarded_aid.COUNT,0) > 0 THEN

            -- Loop thru all the records till there is match
            FOR i IN 1..g_awarded_aid.COUNT LOOP
              l_cnt := l_cnt + 1;
              IF g_awarded_aid(i).base_id = l_fabase.base_id THEN
                g_awarded_aid(i).awarded_aid := g_awarded_aid(i).awarded_aid + NVL(l_aid,0);
                l_rec_fnd := TRUE;
                EXIT;
              ELSE
                l_rec_fnd := FALSE;
              END IF;
            END LOOP;

            -- if awarded_aid is present then update the values
            IF l_rec_fnd THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_rec_fnd=TRUE!g_awarded_aid('||l_cnt||').awarded_aid:'||g_awarded_aid(l_cnt).awarded_aid);
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'g_awarded_aid('||l_cnt||').need_f:'||g_awarded_aid(l_cnt).need_f);
              END IF;
              -- Need to re-check this as Awarded Aid is getting increased for the student
-- ????              IF NVL(g_awarded_aid(l_cnt).awarded_aid,0) > NVL(g_awarded_aid(l_cnt).need_f,0) THEN
              IF NVL(g_awarded_aid(l_cnt).need_f,0) < 0 THEN
                IF l_post = 'Y' THEN
                  g_over_awd := 'NO HOLD';
                ELSE
                  g_over_awd := 'HOLD';
                END IF;
              END IF;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'inside (NVL(g_awarded_aid.COUNT,0) > 0) check,l_post:'||l_post||' g_over_awd:'||g_over_awd);
              END IF;

            -- if awarded_aid is not present then create the new record
            ELSE

              l_cnt := l_cnt + 1;
              g_awarded_Aid.extend;
              g_awarded_aid(l_cnt).base_id     := l_fabase.base_id;
              g_awarded_aid(l_cnt).need_f      := NVL(igf_aw_gen_004.need_f(l_fabase.base_id,g_awd_prd),0);
              g_awarded_aid(l_cnt).awarded_aid := NVL(l_aid,0);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'l_rec_fnd=FALSE!g_awarded_aid('||l_cnt||').awarded_aid:'||g_awarded_aid(l_cnt).awarded_aid);
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'g_awarded_aid('||l_cnt||').need_f:'||g_awarded_aid(l_cnt).need_f);
              END IF;

            END IF; -- End if awarded_aid found in running totals table

          END IF; -- end if awarded aid count

          l_cnt := 0;
          l_rec_fnd := FALSE;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'inserting to igf_aw_award_t with flag:FL for base_id:'||l_fabase.base_id||' g_over_awd:'||g_over_awd);
          END IF;
          -- Insert a new consolidated record into the temp table.
          -- These are the actual awards to the inserted in the igf_aw_award and igf_aw_awd_disb

          ln_com_perct := 100;
          igf_aw_gen_003.get_common_perct(l_awd_grp.adplans_id,l_fabase.base_id,ln_com_perct);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_stud.debug '|| g_req_id,'Before inserting with FL flag in the temp, ln_com_perct : '||ln_com_perct
                          ||' l_awd_grp.fund_id:'||l_awd_grp.fund_id
                          ||' l_aid:'||l_aid
                          ||' l_fabase.base_id:'||l_fabase.base_id
                          ||' l_awd_grp.award_id:'||l_awd_grp.award_id
                          );
          END IF;

          igf_aw_award_t_pkg.insert_row(
                                        x_rowid              => lv_rowid ,
                                        x_process_id         => l_process_id ,
                                        x_sl_number          => l_sl_number,
                                        x_fund_id            => l_awd_grp.fund_id,
                                        x_base_id            => l_fabase.base_id,
                                        x_offered_amt        => l_aid ,
                                        x_accepted_amt       => l_accepted_amt ,
                                        x_paid_amt           => NULL ,
                                        x_need_reduction_amt => NULL,
                                        x_flag               => 'FL',
                                        x_temp_num_val1      => NVL(ln_com_perct,100),
                                        x_temp_num_val2      => NULL,
                                        x_temp_char_val1     => g_over_awd,
                                        x_tp_cal_type        => NULL,
                                        x_tp_sequence_number => NULL,
                                        x_ld_cal_type        => NULL,
                                        x_ld_sequence_number => NULL,
                                        x_mode               => 'R',
                                        x_adplans_id         => l_awd_grp.adplans_id,
                                        x_app_trans_num_txt  => NULL,
                                        x_award_id           => l_awd_grp.award_id,
                                        x_lock_award_flag    => l_awd_grp.lock_award_flag,
                                        x_temp_val3_num      => NULL,
                                        x_temp_val4_num      => NULL,
                                        x_temp_char2_txt     => NULL,
                                        x_temp_char3_txt     => NULL
                                       );
        END IF;

      END LOOP; -- award group check ( dynamic cursor)
      CLOSE c_awd_grp;

    END IF;

  EXCEPTION
    WHEN PELL_NO_REPACK THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.PROCESS_STUD '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.process_stud.exception '|| g_req_id,'sql error:'||SQLERRM);
      END IF;
      RAISE;

  END process_stud;


  PROCEDURE get_process_id IS
    /*
    ||  Created By : cdcruz
    ||  Created On : 14-NOV-2000
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    */

  BEGIN

    -- If the process ID is not assigned then assign the same from the sequences
    -- This is uesd to uniquely identify the records in the temporary table
    IF l_process_id IS NULL THEN
      SELECT igf_aw_process_s.nextval INTO l_process_id FROM dual;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_process_id.debug '|| g_req_id,'l_process_id:'||l_process_id);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.GET_PROCESS_ID '|| SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.get_process_id.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END get_process_id;


  FUNCTION get_perct_amt(
                         l_perct_fact IN VARCHAR2,
                         l_perct_val  IN NUMBER,
                         l_base_id    IN NUMBER,
                         l_efc_f      IN NUMBER,
                         p_awd_prd_code IN VARCHAR2
                        ) RETURN NUMBER IS
    /*
    ||  Created By : cdcruz
    ||  Created On : 14-NOV-2000
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    */

    l_coa NUMBER;
    l_perct_amt  NUMBER(12,2);
    l_awd_aid NUMBER;

  BEGIN

    -- Get Federal COA of the student.
    -- Use these values while calculating the Net Need, COA, EFC or Gross Need for the student.
    l_coa := igf_aw_coa_gen.coa_amount(l_base_id,p_awd_prd_code);

    -- The group Policies set are irrespective of the Fund, so the EFC value of the Federal Methodology MUST be taken
    IF l_perct_fact = 'EFC' then
      l_perct_amt := l_efc_f * (l_perct_val / 100 ) ;

    ELSIF l_perct_fact = 'COA' then
      l_perct_amt := l_coa * (l_perct_val / 100 ) ;

    ELSIF l_perct_fact = 'GROSS_NEED' then
      IF (l_coa - l_efc_f) <= 0 THEN
        l_perct_amt := 0;
      ELSE
        l_perct_amt := ((l_coa - l_efc_f) * (l_perct_val / 100 ))  ;
      END IF;

    ELSIF l_perct_fact = 'NET_NEED' then

      l_awd_aid := igf_aw_coa_gen.award_amount(l_base_id,p_awd_prd_code);

      IF NVL(NVL(l_coa,0) - (NVL(l_efc_f,0) + NVL(l_awd_aid,0)),0) <=0 THEN
        l_perct_amt := 0;
      ELSE

        l_perct_amt := ((NVL(l_coa,0) - (NVL(l_efc_f,0) + NVL(l_awd_aid,0))) * (NVL(l_perct_val,0) / 100 ))  ;
      END IF;

    ELSE
      l_perct_amt := 0;

    END IF;

    RETURN l_perct_amt;

  END get_perct_amt;


  PROCEDURE update_fund(
                        l_fund_id    IN NUMBER,
                        l_seq_no     IN NUMBER,
                        l_process_id IN NUMBER,
                        l_base_id    IN NUMBER,
                        l_award_id   IN NUMBER
                       ) IS
    /*
    ||  Created By : skoppula
    ||  Created On : 02-JAN-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    */

    CURSOR c_awd_det(
                     x_fund_id    igf_aw_fund_mast.fund_id%TYPE,
                     x_process_id NUMBER,
                     x_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                     x_seq_no     NUMBER,
                     x_award_id  igf_aw_award_all.award_id%TYPE
                    ) IS
    SELECT awdt.*
      FROM igf_aw_award_t awdt
     WHERE fund_id = x_fund_id
       AND (temp_char_val1 = TO_CHAR( x_seq_no ) OR x_seq_no =-1)
       AND process_id = x_process_id
       AND flag IN ('CF','AU')
       AND base_id = x_base_id
       AND NVL(award_id,-1) = NVL(x_award_id,-1);

    l_awd_det   c_awd_det%ROWTYPE;

    l_paid_amt igf_aw_award_all.paid_amt%TYPE;
    -- Get paid amt
    CURSOR c_paid_amt(
                      cp_award_id igf_aw_award_all.award_id%TYPE
                     ) IS
      SELECT SUM(paid_amount) paid_amount
        FROM igf_se_payment pay,
             igf_se_auth auth
       WHERE pay.auth_id = auth.auth_id
         AND auth.award_id = cp_award_id
         AND auth.flag = 'A';

    -- check if the award has been repackaged
    CURSOR c_awd_ex(
                    cp_process_id NUMBER,
                    cp_award_id   igf_aw_award_all.award_id%TYPE,
                    cp_seq_no     NUMBER
                   ) IS
      SELECT 'x'
        FROM igf_aw_award_t
       WHERE process_id = cp_process_id
         AND award_id = cp_award_id
         AND flag = 'AU'
         AND TO_NUMBER(NVL(temp_char_val1,-1)) < cp_seq_no;
    l_awd_ex c_awd_ex%ROWTYPE;
  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'update_fund called');
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'fund_id:'||l_fund_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'base_id:'||l_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'process_id:'||l_process_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'l_seq_no:'||l_seq_no);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'l_award_id:'||l_award_id);
    END IF;
    -- ssawhney. Added LOOP, because id l_seq_no=-1 then fund=FSEOG and there will be more than one occurence of an FSEOG fund.
    -- Remove all Find Instances from the Temporary table for a given fund and base_id combination
    -- This is used to check the Fund Rules like Inclusive, Exclusive etc.
    OPEN c_awd_det( l_fund_id, l_process_id ,l_base_id,l_seq_no,l_award_id);
    LOOP
      FETCH c_awd_det INTO l_awd_det;
      EXIT WHEN c_awd_det%NOTFOUND;

      IF l_award_id IS NULL THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'Calling delete_row for');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'fund_id:'||l_awd_det.fund_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'base_id:'||l_awd_det.base_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'flag:'||l_awd_det.flag);
        END IF;

        igf_aw_award_t_pkg.delete_row( x_rowid => l_awd_det.row_id );
      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'Calling update_row for');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'fund_id:'||l_awd_det.fund_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'base_id:'||l_awd_det.base_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'flag:'||l_awd_det.flag);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'award_id:'||l_awd_det.award_id);
        END IF;
        --do a check for FWS before cancelling this
        IF get_fed_fund_code(l_awd_det.fund_id) = 'FWS' THEN
          l_paid_amt := NULL;
          OPEN c_paid_amt(l_awd_det.award_id);
          FETCH c_paid_amt INTO l_paid_amt;
          CLOSE c_paid_amt;
          IF l_paid_amt IS NOT NULL THEN
            fnd_message.set_name('IGF','IGF_AW_INV_FWS_AWD');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            RAISE INV_FWS_AWARD;
          END IF;
        END IF;

        --here, we need to check if the award has been already repackaged successfully
        OPEN c_awd_ex(l_process_id,l_awd_det.award_id,l_seq_no);
        FETCH c_awd_ex INTO l_awd_ex;
        IF c_awd_ex%NOTFOUND THEN
          --award has not been already repackaged
          --so it can be cancelled
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'cancelling the award');
          END IF;
          CLOSE c_awd_ex;
          igf_aw_award_t_pkg.update_row(
                                        x_rowid              => l_awd_det.row_id,
                                        x_process_id         => l_awd_det.process_id,
                                        x_sl_number          => l_awd_det.sl_number,
                                        x_fund_id            => l_awd_det.fund_id,
                                        x_base_id            => l_awd_det.base_id,
                                        x_offered_amt        => l_awd_det.offered_amt,
                                        x_accepted_amt       => l_awd_det.accepted_amt,
                                        x_paid_amt           => l_awd_det.paid_amt,
                                        x_need_reduction_amt => l_awd_det.need_reduction_amt,
                                        x_flag               => 'AC',
                                        x_temp_num_val1      => l_awd_det.temp_num_val1,
                                        x_temp_num_val2      => l_awd_det.temp_num_val2,
                                        x_temp_char_val1     => l_awd_det.temp_char_val1,
                                        x_tp_cal_type        => l_awd_det.tp_cal_type,
                                        x_tp_sequence_number => l_awd_det.tp_sequence_number,
                                        x_ld_cal_type        => l_awd_det.ld_cal_type,
                                        x_ld_sequence_number => l_awd_det.ld_sequence_number,
                                        x_mode               => 'R',
                                        x_adplans_id         => l_awd_det.adplans_id,
                                        x_app_trans_num_txt  => l_awd_det.app_trans_num_txt,
                                        x_award_id           => l_awd_det.award_id,
                                        x_lock_award_flag    => l_awd_det.lock_award_flag,
                                        x_temp_val3_num      => l_awd_det.temp_val3_num,
                                        x_temp_val4_num      => l_awd_det.temp_val4_num,
                                        x_temp_char2_txt     => l_awd_det.temp_char2_txt,
                                        x_temp_char3_txt     => l_awd_det.temp_char3_txt
                                       );
        ELSE
          --award has been repackaged. cancelling an repackaged award does not make sense
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'deleting the award');
          END IF;
          CLOSE c_awd_ex;
          igf_aw_award_t_pkg.delete_row( x_rowid => l_awd_det.row_id );
        END IF;
      END IF;
    END LOOP;

    CLOSE c_awd_det;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.update_fund.debug '|| g_req_id,'update_fund finished');
    END IF;

  EXCEPTION
    WHEN INV_FWS_AWARD THEN
      RAISE;
    WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_PACKAGING.UPDATE_FUND '||SQLERRM);
    igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.update_fund.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
    app_exception.raise_exception;

  END update_fund;


  PROCEDURE get_disbursements(
                              l_fund_id      IN NUMBER,
                              l_offered_amt  IN NUMBER,
                              l_base_id      IN NUMBER,
                              l_process_id   IN NUMBER,
                              l_accepted_amt IN NUMBER,
                              l_called_from  IN VARCHAR2,
                              l_nslds_da     IN VARCHAR2,
                              l_exp_da       IN VARCHAR2,
                              l_verf_da      IN VARCHAR2,
                              l_disb_dt      IN OUT NOCOPY disb_dt_tab,
                              l_adplans_id   IN NUMBER,
                              l_award_id     IN NUMBER
                             ) IS
    /*
    ||  Created By : skoppula
    ||  Created On : 02-JAN-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    ||  museshad        08-Jun-2005     Build# FA157 - Bug# 4382371.
    ||                                  In 'Equal' distribution method previously, the number of
    ||                                  terms in the awarding period was passed as parameter to the
    ||                                  cursors - c_auto_disb_equal, c_auto_disb_equal_wcoa. From now
    ||                                  on the number of teaching periods in the awarding period will
    ||                                  get passed. Changed the above mentioned two cursors
    ||                                  accordingly. This changes is needed because, Equal distribution plan
    ||                                  will not have teaching period percentages from here on.
    ||  veramach        08-Dec-2003     FA 131 COD Updates
    ||                                  Added 2 new cursors c_auto_disb_wcoa,c_auto_disb_equal_wcoa
    ||                                  These cursors do not use student's COA terms for distributing the award
    ||  veramach        03-Dec-2003     FA 131 COD Updates
    ||                                  Existing logic to find disbursement is now used only for non-PELL funds
    ||                                  For PELL funds, the disbursements returned from the PELL wrapper is used.
    ||  veramach        21-NOV-2003     FA 125 - changed c_tp_perct to choose distribution % using adplans_id
    ||                                  Added c_auto_disb_equal,cur_terms_count,c_auto_disb_coa_match,c_coa
    ||                                  Modified cursor c_get_ofst
    ||                                  Added logic to choose distribution % based on distribution method
    */

    -- Get the Teching and load calendar details of the fund for creating the disbursements
    CURSOR c_tp_perct(
                      cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                      cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE
                     ) IS
      SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
             terms.ld_cal_type ld_cal_type,
             terms.ld_sequence_number ld_sequence_number,
             teach_periods.tp_cal_type tp_cal_type,
             teach_periods.tp_sequence_number tp_sequence_number,
             (teach_periods.tp_perct_num * terms.ld_perct_num)/100 perct,
             teach_periods.start_date start_dt,
             teach_periods.date_offset_cd tp_offset_da,
             teach_periods.credit_points_num min_credit_points,
             teach_periods.attendance_type_code
        FROM igf_aw_dp_terms    terms,
             igf_aw_dp_teach_prds_v    teach_periods,
             (SELECT base_id,
                     ld_cal_type,
                     ld_sequence_number
                FROM igf_aw_coa_itm_terms
               WHERE base_id = cp_base_id
               GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms
        WHERE terms.adplans_id = cp_adplans_id
          AND terms.adterms_id = teach_periods.adterms_id
          AND coaterms.ld_cal_type = terms.ld_cal_type
          AND coaterms.ld_sequence_number = terms.ld_sequence_number
          AND coaterms.base_id = cp_base_id
        ORDER BY 1;

    l_tp_perct        c_tp_perct%ROWTYPE;

    --Added this cursor for processing student without COA when COA can be exceeded
    CURSOR c_auto_disb_wcoa(
                            cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                            cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                           ) IS
      SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
             terms.ld_cal_type ld_cal_type,
             terms.ld_sequence_number ld_sequence_number,
             teach_periods.tp_cal_type tp_cal_type,
             teach_periods.tp_sequence_number tp_sequence_number,
             (teach_periods.tp_perct_num * terms.ld_perct_num)/100 perct,
             teach_periods.start_date start_dt,
             teach_periods.date_offset_cd tp_offset_da,
             teach_periods.credit_points_num min_credit_points,
             teach_periods.attendance_type_code attendance_type_code
        FROM igf_aw_dp_terms        terms,
             igf_aw_dp_teach_prds_v teach_periods
       WHERE terms.adplans_id = cp_adplans_id
         AND terms.adterms_id = teach_periods.adterms_id
       ORDER BY 1;


    CURSOR c_auto_disb_equal(
                             cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                             cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                             cp_num_teach_periods  NUMBER
                            ) IS
      SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
             terms.ld_cal_type ld_cal_type,
             terms.ld_sequence_number ld_sequence_number,
             teach_periods.tp_cal_type tp_cal_type,
             teach_periods.tp_sequence_number tp_sequence_number,
             100/cp_num_teach_periods perct,
             teach_periods.start_date start_dt,
             teach_periods.date_offset_cd tp_offset_da,
             teach_periods.credit_points_num min_credit_points,
             teach_periods.attendance_type_code
        FROM igf_aw_dp_terms    terms,
             igf_aw_dp_teach_prds_v    teach_periods,
             (SELECT base_id,
                     ld_cal_type,
                     ld_sequence_number
                FROM igf_aw_coa_itm_terms
               WHERE base_id = cp_base_id
               GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms
       WHERE terms.adplans_id = cp_adplans_id
         AND terms.adterms_id = teach_periods.adterms_id
         AND coaterms.ld_cal_type = terms.ld_cal_type
         AND coaterms.ld_sequence_number = terms.ld_sequence_number
         AND coaterms.base_id = cp_base_id
       ORDER BY 1;

    -- Added this cursor to process students without COA when COA can be exceeded
    CURSOR c_auto_disb_equal_wcoa(
                                  cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                                  cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                                  cp_num_teach_periods  NUMBER
                                 ) IS
      SELECT NVL(igf_aw_packaging.get_date_instance (cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
             terms.ld_cal_type ld_cal_type,
             terms.ld_sequence_number ld_sequence_number,
             teach_periods.tp_cal_type tp_cal_type,
             teach_periods.tp_sequence_number tp_sequence_number,
             100/cp_num_teach_periods perct,
             teach_periods.start_date start_dt,
             teach_periods.date_offset_cd tp_offset_da,
             teach_periods.credit_points_num min_credit_points,
             teach_periods.attendance_type_code attendance_type_code
        FROM igf_aw_dp_terms        terms,
             igf_aw_dp_teach_prds_v teach_periods
       WHERE terms.adplans_id = cp_adplans_id
         AND terms.adterms_id = teach_periods.adterms_id
       ORDER BY 1;

    -- Get total terms
    CURSOR cur_terms_count(
                           cp_base_id     igf_ap_fa_base_rec_all.base_id%TYPE,
                           cp_adplans_id  igf_aw_awd_dist_plans.adplans_id%TYPE
                          ) IS
      SELECT COUNT(*)
        FROM igf_aw_dp_terms terms,
             (SELECT base_id,
                     ld_cal_type,
                     ld_sequence_number
                FROM igf_aw_coa_itm_terms
               WHERE base_id = cp_base_id
               GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms,
               igf_aw_awd_dist_plans adplans,
               igf_aw_awd_prd_term aprd
       WHERE terms.adplans_id            = cp_adplans_id
         AND coaterms.ld_cal_type        = terms.ld_cal_type
         AND coaterms.ld_sequence_number = terms.ld_sequence_number
         AND coaterms.base_id            = cp_base_id
         AND adplans.adplans_id          = terms.adplans_id
         AND adplans.cal_type            = aprd.ci_cal_type
         AND adplans.sequence_number     = aprd.ci_sequence_number
         AND aprd.ld_cal_type            = terms.ld_cal_type
         AND aprd.ld_sequence_number     = terms.ld_sequence_number
         AND aprd.award_prd_cd         = g_awd_prd;

    l_terms_count NUMBER := 0;

    CURSOR c_auto_disb_coa_match(
                                 cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                                 cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                                 cp_total_coa_amount NUMBER
                                ) IS
      SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
             terms.ld_cal_type ld_cal_type,
             terms.ld_sequence_number ld_sequence_number,
             teach_periods.tp_cal_type tp_cal_type,
             teach_periods.tp_sequence_number tp_sequence_number,
             (coa_term_amount/cp_total_coa_amount) * teach_periods.tp_perct_num perct,
             teach_periods.start_date start_dt,
             teach_periods.date_offset_cd tp_offset_da,
             teach_periods.credit_points_num min_credit_points,
             teach_periods.attendance_type_code
        FROM igf_aw_dp_terms    terms,
             igf_aw_dp_teach_prds_v    teach_periods,
             (SELECT base_id,
                     ld_cal_type,
                     ld_sequence_number,
                     amount coa_term_amount
                FROM igf_aw_coa_term_tot_v
               WHERE base_id = cp_base_id) coaterms
       WHERE terms.adplans_id = cp_adplans_id
         AND terms.adterms_id = teach_periods.adterms_id
         AND coaterms.ld_cal_type = terms.ld_cal_type
         AND coaterms.ld_sequence_number = terms.ld_sequence_number
         AND coaterms.base_id = cp_base_id
       ORDER BY 1;

    -- Get COA
    CURSOR c_coa(
                 cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                 cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                ) IS
      SELECT SUM(amount) coa
        FROM igf_aw_coa_itm_terms coa_terms,
             igf_aw_dp_terms terms,
             igf_aw_awd_dist_plans adplans,
             igf_aw_awd_prd_term aprd
      WHERE terms.ld_cal_type = coa_terms.ld_cal_type
        AND terms.ld_sequence_number = coa_terms.ld_sequence_number
        AND coa_terms.base_id = cp_base_id
        AND terms.adplans_id = cp_adplans_id
        AND terms.adplans_id = adplans.adplans_id
        AND adplans.cal_type = aprd.ci_cal_type
        AND adplans.sequence_number = aprd.ci_sequence_number
        AND aprd.ld_cal_type = terms.ld_cal_type
        AND aprd.ld_sequence_number = terms.ld_sequence_number
        AND aprd.award_prd_cd = g_awd_prd;
    ln_coa igf_ap_fa_base_rec_all.coa_f%TYPE;


    cnt               NUMBER := 0;
    lv_rowid          VARCHAR2(30);
    l_sl_number       NUMBER;
    l_disb_amt        NUMBER;   -- Changed from NUMBER(12,2) to NUMBER
    l_disb_num        NUMBER := 0;
    l_disb_accpt_amt  NUMBER;   -- Changed from NUMBER(12,2) to NUMBER
    l_cnt             NUMBER := 0;
    ln_fund_awd_prct  NUMBER;

    lv_result         VARCHAR2(80);
    lv_method_code    igf_aw_awd_dist_plans.dist_plan_method_code%TYPE;

    lb_use_wcoa_cur BOOLEAN := FALSE;

    -- Get existing pell disbursments
    CURSOR c_pelldisb(
                      cp_award_id igf_aw_award_all.award_id%TYPE
                     ) IS
      SELECT disb.rowid row_id,
             disb.*
        FROM igf_aw_awd_disb_all disb
       WHERE disb.award_id = cp_award_id
         AND disb.trans_type <> 'C'
       ORDER BY disb.disb_num;

    -- Get distribution plan for the pell award
    CURSOR c_pell_dp(
                     cp_award_id igf_aw_award_all.award_id%TYPE
                    ) IS
      SELECT adplans_id
        FROM igf_aw_award_all
       WHERE award_id = cp_award_id;
    l_pell_dp igf_aw_awd_dist_plans.adplans_id%TYPE;

    -- Get extra pell disbursements
    CURSOR c_pell_new_disb(
                           cp_award_id igf_aw_award_all.award_id%TYPE,
                           cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                          ) IS
      SELECT awdt.*
        FROM igf_aw_award_t awdt
       WHERE process_id = l_process_id
         AND base_id = cp_base_id
         AND award_id = cp_award_id
         AND flag = 'GR';

    CURSOR c_base_attendance(
                             cp_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                             cp_award_id            igf_aw_award_all.award_id%TYPE,
                             cp_ld_cal_type         igs_ca_inst_all.cal_type%TYPE,
                             cp_ld_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                            ) IS
      SELECT awdt.temp_char2_txt base_attendance_type_code
        FROM igf_aw_award_t awdt
       WHERE process_id         = l_process_id
         AND base_id            = cp_base_id
         AND award_id           = cp_award_id
         AND ld_cal_type        = cp_ld_cal_type
         AND ld_sequence_number = cp_ld_sequence_number;
    l_base_attendance c_base_attendance%ROWTYPE;

  BEGIN

    l_disb_num := NULL;
    l_disb_dt.delete;

    IF get_fed_fund_code(l_fund_id) <> 'PELL' THEN -- Added in FA 131 COD Updates Build
      -- Get the Fund details like Amount, Calendar dates etc for each fund and insert INTO the Temporary table
      -- and at the same time fetch the actual dates for the date aliases mentioned at the fund.
      -- These details are used while validating the awards of the sutdents

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'calling check_plan');
      END IF;

      check_plan(l_adplans_id,lv_result,lv_method_code);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'check_plan returned lv_result:'||lv_result);
      END IF;

      /*
        check if the student has COA or not and set a flag specifying what cursor should be used
      */
      IF igf_aw_gen_003.check_coa(l_base_id) = FALSE AND g_sf_packaging = 'T' AND g_allow_to_exceed = 'COA' THEN
        IF lv_method_code IN ('M','E') THEN
          lb_use_wcoa_cur := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'have to use alternate cursor for base_id:'||l_base_id||' and adplans_id:'||l_adplans_id);
          END IF;
        END IF;
      END IF;

      IF lv_result = 'TRUE' THEN
        IF lv_method_code = 'M' THEN -- Manual distribution
          IF lb_use_wcoa_cur = FALSE THEN
            OPEN c_tp_perct(l_adplans_id,l_base_id);
            FETCH c_tp_perct INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'opened and fetched cursor c_tp_perct');
            END IF;
          ELSE
            OPEN c_auto_disb_wcoa(l_base_id,l_adplans_id);
            FETCH c_auto_disb_wcoa INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'opened and fetched cursor c_auto_disb_wcoa');
            END IF;
          END IF;

        ELSIF lv_method_code = 'E' THEN -- Equal distribution
          --Find the number of terms
          OPEN cur_terms_count(l_base_id,l_adplans_id);
          FETCH cur_terms_count INTO l_terms_count;
          CLOSE cur_terms_count;

          IF lb_use_wcoa_cur = FALSE THEN
             OPEN c_auto_disb_equal(l_adplans_id,l_base_id,igf_aw_gen_003.get_plan_disb_count(l_adplans_id, g_awd_prd));
            FETCH c_auto_disb_equal INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'opened and fetched cursor c_auto_disb_equal');
            END IF;
          ELSE
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'igf_aw_gen_003.get_plan_disb_count('||l_adplans_id||'):'||igf_aw_gen_003.get_plan_disb_count(l_adplans_id));
            END IF;
            OPEN c_auto_disb_equal_wcoa(l_base_id,l_adplans_id,igf_aw_gen_003.get_plan_disb_count(l_adplans_id, g_awd_prd));
            FETCH c_auto_disb_equal_wcoa INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'opened and fetched cursor c_auto_disb_equal_wcoa');
            END IF;
          END IF;

        ELSIF lv_method_code = 'C' THEN -- Match COA distribution

          OPEN c_coa(l_base_id,l_adplans_id);
          FETCH c_coa INTO ln_coa;
          CLOSE c_coa;

          OPEN c_auto_disb_coa_match(l_adplans_id,l_base_id,NVL(ln_coa,0));
          FETCH c_auto_disb_coa_match INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'opened and fetched cursor c_auto_disb_coa_match');
            END IF;
        END IF;
      END IF;

      -- loop through till all the disbursements will get created for each teaching periods defined for a given fund,
      -- since disbursements are distributed at the teaching period level
      LOOP
        IF lv_method_code = 'M' THEN

          IF lb_use_wcoa_cur = FALSE THEN
            EXIT WHEN c_tp_perct%NOTFOUND;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'----will exit when c_tp_perct%NOTFOUND-------');
            END IF;

          ELSE
            EXIT WHEN c_auto_disb_wcoa%NOTFOUND;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'----will exit when c_auto_disb_wcoa%NOTFOUND-------');
            END IF;
          END IF;

        ELSIF lv_method_code = 'E' THEN

          IF lb_use_wcoa_cur = FALSE THEN
            EXIT WHEN c_auto_disb_equal%NOTFOUND;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'----will exit when c_auto_disb_equal%NOTFOUND-------');
            END IF;

          ELSE
            EXIT WHEN c_auto_disb_equal_wcoa%NOTFOUND;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'----will exit when c_auto_disb_equal_wcoa%NOTFOUND-------');
            END IF;
          END IF;

        ELSIF lv_method_code = 'C' THEN
          EXIT WHEN c_auto_disb_coa_match%NOTFOUND;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'----will exit when c_auto_disb_coa_match%NOTFOUND-------');
          END IF;

        END IF;


        lv_rowid         := NULL;
        l_sl_number      := NULL;
        ln_fund_awd_prct := 0;

        -- Get the fund award percentage calculated while calculating the award from the PL/SQL table
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'getting award percentage from temp table -g_fund_awd_prct.COUNT:'||g_fund_awd_prct.COUNT);
        END IF;
        FOR i IN 1..g_fund_awd_prct.COUNT LOOP
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_fund_awd_prct('||i||').base_id:'||g_fund_awd_prct(i).base_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_fund_awd_prct('||i||').fund_id:'||g_fund_awd_prct(i).fund_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_fund_awd_prct('||i||').awd_prct:'||g_fund_awd_prct(i).awd_prct);
          END IF;
          IF g_fund_awd_prct(i).base_id = l_base_id AND g_fund_awd_prct(i).fund_id = l_fund_id THEN
            ln_fund_awd_prct := g_fund_awd_prct(i).awd_prct;
          END IF;
        END LOOP;

        -- Split the Offered and Accepted amount specified at the fund INTO disbursements using the disbursement percentages
        l_disb_num       := NVL( l_disb_num, 0) + 1;
        l_disb_amt       := ( l_offered_amt * l_tp_perct.perct ) / 100;
        l_disb_accpt_amt := ( l_accepted_amt * l_tp_perct.perct ) / 100;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'after splitting award amount for disbursments l_disb_num:'||l_disb_num||' l_disb_amt:'||l_disb_amt||
                                                 ' l_disb_accpt_amt:'||l_disb_accpt_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_tp_perct.perct:'||l_tp_perct.perct||' l_accepted_amt:'||l_accepted_amt||' l_disb_amt:'||l_disb_amt);
        END IF;
        -- Create a disbursements INTO the temporary table with the fund deatils and the newly calculated disbursements amounts with the status = 'DB'
        l_sl_number := NULL;

        igf_aw_award_t_pkg.insert_row(
                                      x_rowid               => lv_rowid,
                                      x_process_id          => l_process_id,
                                      x_sl_number           => l_sl_number,
                                      x_fund_id             => l_fund_id,
                                      x_base_id             => l_base_id,
                                      x_offered_amt         => l_disb_amt,
                                      x_accepted_amt        => l_disb_accpt_amt,
                                      x_paid_amt            => 0,
                                      x_need_reduction_amt  => ((l_disb_amt/l_offered_amt)*100),
                                      x_flag                => 'DB',
                                      x_temp_num_val1       => l_disb_amt,
                                      x_temp_num_val2       => l_disb_num,
                                      x_temp_char_val1      => fnd_date.date_to_chardate(l_tp_perct.disb_dt),
                                      x_tp_cal_type         => l_tp_perct.tp_cal_type,
                                      x_tp_sequence_number  => l_tp_perct.tp_sequence_number,
                                      x_ld_cal_type         => l_tp_perct.ld_cal_type,
                                      x_ld_sequence_number  => l_tp_perct.ld_sequence_number,
                                      x_mode                => 'R',
                                      x_adplans_id          => l_adplans_id,
                                      x_app_trans_num_txt   => NULL,
                                      x_award_id            => l_award_id,
                                      x_lock_award_flag     => NULL,
                                      x_temp_val3_num       => NULL,
                                      x_temp_val4_num       => NULL,
                                      x_temp_char2_txt      => NULL,
                                      x_temp_char3_txt      => NULL
                                     );

        l_cnt := l_cnt + 1;
        l_disb_dt.extend(1);
        l_disb_dt(l_cnt).process_id           := l_process_id;
        l_disb_dt(l_cnt).sl_no                := l_sl_number;
        l_disb_dt(l_cnt).min_credit_pts       := l_tp_perct.min_credit_points;
        l_disb_dt(l_cnt).nslds_disb_date      := NULL;
        l_disb_dt(l_cnt).disb_verf_dt         := NULL;
        l_disb_dt(l_cnt).disb_exp_dt          := NULL;
        l_disb_dt(l_cnt).attendance_type_code := l_tp_perct.attendance_type_code;
        l_disb_dt(l_cnt).base_attendance_type_code := NULL;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'-------Disb Date PL-SQL Table values ---------');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_disb_dt('||l_cnt||').process_id ' ||l_disb_dt(l_cnt).process_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_disb_dt('||l_cnt||').sl_no ' || l_disb_dt(l_cnt).sl_no);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_disb_dt('||l_cnt||').min_credit_pts  ' || l_disb_dt(l_cnt).min_credit_pts);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_disb_dt('||l_cnt||').attendance_type_code ' || l_disb_dt(l_cnt).attendance_type_code);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_disb_dt('||l_cnt||').base_attendance_type ' || l_disb_dt(l_cnt).base_attendance_type_code);
        END IF;

        -- Get the Offset data alias instances of the Fund.
        l_disb_dt(l_cnt).nslds_disb_date := igf_ap_gen_001.get_date_alias_val(
                                                                              l_base_id,
                                                                              l_tp_perct.ld_cal_type,
                                                                              l_tp_perct.ld_sequence_number,
                                                                              l_nslds_da
                                                                             );
        l_disb_dt(l_cnt).disb_exp_dt := igf_ap_gen_001.get_date_alias_val(
                                                                          l_base_id,
                                                                          l_tp_perct.ld_cal_type,
                                                                          l_tp_perct.ld_sequence_number,
                                                                          l_exp_da
                                                                         );
        l_disb_dt(l_cnt).disb_verf_dt := igf_ap_gen_001.get_date_alias_val(
                                                                           l_base_id,
                                                                           l_tp_perct.ld_cal_type,
                                                                           l_tp_perct.ld_sequence_number,
                                                                           l_verf_da
                                                                          );

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'disb date offset l_disb_dt('||l_cnt||').nslds_disb_date:'||l_disb_dt(l_cnt).nslds_disb_date);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'disb date offset l_disb_dt('||l_cnt||').disb_exp_dt:'||l_disb_dt(l_cnt).disb_exp_dt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'disb date offset l_disb_dt('||l_cnt||').disb_verf_dt:'||l_disb_dt(l_cnt).disb_verf_dt);
        END IF;

        IF lv_method_code = 'M' THEN

          IF lb_use_wcoa_cur = FALSE THEN
            FETCH c_tp_perct INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'fetched c_tp_perct');
            END IF;
            EXIT WHEN c_tp_perct%NOTFOUND;

          ELSE
            FETCH c_auto_disb_wcoa INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'fetched c_auto_disb_wcoa');
            END IF;
            EXIT WHEN c_auto_disb_wcoa%NOTFOUND;
          END IF;

        ELSIF lv_method_code = 'E' THEN

          IF lb_use_wcoa_cur = FALSE THEN
            FETCH c_auto_disb_equal INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'fetched c_auto_disb_equal');
            END IF;
            EXIT WHEN c_auto_disb_equal%NOTFOUND;

          ELSE
            FETCH c_auto_disb_equal_wcoa INTO l_tp_perct;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'fetched c_auto_disb_equal_wcoa');
            END IF;
            EXIT WHEN c_auto_disb_equal_wcoa%NOTFOUND;

          END IF;

        ELSIF lv_method_code = 'C' THEN
          FETCH c_auto_disb_coa_match INTO l_tp_perct;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'fetched c_auto_disb_coa_match');
          END IF;
          EXIT WHEN c_auto_disb_coa_match%NOTFOUND;
        END IF;

      END LOOP;  -- ending teach percentage loop

      IF lv_method_code = 'M' THEN
        IF lb_use_wcoa_cur = FALSE THEN
          CLOSE c_tp_perct;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'closed c_tp_perct');
          END IF;
        ELSE
          CLOSE c_auto_disb_wcoa;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'closed c_auto_disb_wcoa');
          END IF;
        END IF;
      ELSIF lv_method_code = 'E' THEN
        IF lb_use_wcoa_cur = FALSE THEN
          CLOSE c_auto_disb_equal;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'closed c_auto_disb_equal');
          END IF;
        ELSE
          CLOSE c_auto_disb_equal_wcoa;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'closed c_auto_disb_wcoa');
          END IF;
        END IF;
      ELSIF lv_method_code = 'C' THEN
        CLOSE c_auto_disb_coa_match;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'closed c_auto_disb_coa_match');
          END IF;
      END IF;

    ELSE -- fed_fund_code is PELL

      --from here, the logic for phase-in participant and full participant schools differ
      IF NOT g_phasein_participant OR l_award_id IS NULL THEN
        l_sl_number := NULL;
        IF g_pell_tab IS NOT NULL THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'full participant logic');
         END IF;
         FOR i IN 1..g_pell_tab.COUNT LOOP
           igf_aw_award_t_pkg.insert_row(
                                         x_rowid               => lv_rowid,
                                         x_process_id          => l_process_id,
                                         x_sl_number           => l_sl_number,
                                         x_fund_id             => l_fund_id,
                                         x_base_id             => l_base_id,
                                         x_offered_amt         => g_pell_tab(i).offered_amt,
                                         x_accepted_amt        => g_pell_tab(i).accepted_amt,
                                         x_paid_amt            => 0,
                                         x_need_reduction_amt  => g_pell_tab(i).offered_amt * 100 / l_offered_amt,
                                         x_flag                => 'DB',
                                         x_temp_num_val1       => g_pell_tab(i).offered_amt,
                                         x_temp_num_val2       => i,
                                         x_temp_char_val1      => fnd_date.date_to_chardate(g_pell_tab(i).disb_dt),
                                         x_tp_cal_type         => g_pell_tab(i).tp_cal_type,
                                         x_tp_sequence_number  => g_pell_tab(i).tp_sequence_number,
                                         x_ld_cal_type         => g_pell_tab(i).ld_cal_type,
                                         x_ld_sequence_number  => g_pell_tab(i).ld_sequence_number,
                                         x_mode                => 'R',
                                         x_adplans_id          => g_pell_tab(i).adplans_id,
                                         x_app_trans_num_txt   => g_pell_tab(i).app_trans_num_txt,
                                         x_award_id            => l_award_id,
                                         x_lock_award_flag     => NULL,
                                         x_temp_val3_num       => NULL,
                                         x_temp_val4_num       => NULL,
                                         x_temp_char2_txt      => NULL,
                                         x_temp_char3_txt      => NULL
                                        );

           l_cnt := l_cnt + 1;
           l_disb_dt.extend(1);
           l_disb_dt(l_cnt).process_id           := l_process_id;
           l_disb_dt(l_cnt).sl_no                := l_sl_number;
           l_disb_dt(l_cnt).min_credit_pts       := g_pell_tab(i).min_credit_pts;
           l_disb_dt(l_cnt).nslds_disb_date      := NULL;
           l_disb_dt(l_cnt).disb_verf_dt         := g_pell_tab(i).verf_enfr_dt;
           l_disb_dt(l_cnt).disb_exp_dt          := g_pell_tab(i).disb_exp_dt;
           l_disb_dt(l_cnt).attendance_type_code := g_pell_tab(i).attendance_type_code;
           l_disb_dt(l_cnt).base_attendance_type_code := g_pell_tab(i).base_attendance_type_code;

           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'------pell disb:'||i||'------');
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'x_need_reduction_amt:'||g_pell_tab(i).offered_amt * 100 / l_offered_amt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).offered_amt:'||g_pell_tab(i).offered_amt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).accepted_amt:'||g_pell_tab(i).accepted_amt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).disb_dt:'||g_pell_tab(i).disb_dt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).tp_cal_type:'||g_pell_tab(i).tp_cal_type);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).tp_sequence_number:'||g_pell_tab(i).tp_sequence_number);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).ld_cal_type:'||g_pell_tab(i).ld_cal_type);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).ld_sequence_number:'||g_pell_tab(i).ld_sequence_number);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).app_trans_num_txt:'||g_pell_tab(i).app_trans_num_txt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).adplans_id:'||g_pell_tab(i).adplans_id);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).min_credit_pts:'||g_pell_tab(i).min_credit_pts);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).verf_enfr_dt:'||g_pell_tab(i).verf_enfr_dt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).disb_exp_dt:'||g_pell_tab(i).disb_exp_dt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).attendance_type_code:'||g_pell_tab(i).attendance_type_code);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'g_pell_tab(i).base_attendance_type_code:'||g_pell_tab(i).base_attendance_type_code);
           END IF;

         END LOOP; -- End g_pell_tab loop
        END IF;
      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'phase-in participant logic with Award Id : '||l_award_id);
        END IF;
        l_pell_dp := NULL;
        OPEN c_pell_dp(l_award_id);
        FETCH c_pell_dp INTO l_pell_dp;
        CLOSE c_pell_dp;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_dp:'||l_pell_dp);
        END IF;

        FOR l_pelldisb IN c_pelldisb(l_award_id) LOOP

          lv_rowid    := NULL;
          l_sl_number := NULL;

          OPEN c_base_attendance(l_base_id,l_award_id,l_pelldisb.ld_cal_type,l_pelldisb.ld_sequence_number);
          FETCH c_base_attendance INTO l_base_attendance;
          CLOSE c_base_attendance;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'^^^inserting into igf_aw_award_t for PELL(old)^^^');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_fund_id:'||l_fund_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_base_id:'||l_base_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.disb_gross_amt:'||l_pelldisb.disb_gross_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.disb_accepted_amt:'||l_pelldisb.disb_accepted_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.disb_gross_amt:'||l_pelldisb.disb_gross_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.disb_date:'||l_pelldisb.disb_date);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.tp_cal_type:'||l_pelldisb.tp_cal_type);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.tp_sequence_number:'||l_pelldisb.tp_sequence_number);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.ld_cal_type:'||l_pelldisb.ld_cal_type);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.ld_sequence_number:'||l_pelldisb.ld_sequence_number);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pelldisb.award_id:'||l_pelldisb.award_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'^^^done inserting into igf_aw_award_t^^^');
          END IF;
          igf_aw_award_t_pkg.insert_row(
                                        x_rowid               => lv_rowid,
                                        x_process_id          => l_process_id,
                                        x_sl_number           => l_sl_number,
                                        x_fund_id             => l_fund_id,
                                        x_base_id             => l_base_id,
                                        x_offered_amt         => l_pelldisb.disb_gross_amt,
                                        x_accepted_amt        => l_pelldisb.disb_accepted_amt,
                                        x_paid_amt            => 0,
                                        x_need_reduction_amt  => 100,
                                        x_flag                => 'DB',
                                        x_temp_num_val1       => l_pelldisb.disb_gross_amt,
                                        x_temp_num_val2       => NULL,
                                        x_temp_char_val1      => l_pelldisb.disb_date,
                                        x_tp_cal_type         => l_pelldisb.tp_cal_type,
                                        x_tp_sequence_number  => l_pelldisb.tp_sequence_number,
                                        x_ld_cal_type         => l_pelldisb.ld_cal_type,
                                        x_ld_sequence_number  => l_pelldisb.ld_sequence_number,
                                        x_mode                => 'R',
                                        x_adplans_id          => l_pell_dp,
                                        x_app_trans_num_txt   => NULL,
                                        x_award_id            => l_pelldisb.award_id,
                                        x_lock_award_flag     => NULL,
                                        x_temp_val3_num       => NULL,
                                        x_temp_val4_num       => NULL,
                                        x_temp_char2_txt      => NVL(l_base_attendance.base_attendance_type_code,l_pelldisb.base_attendance_type_code),
                                        x_temp_char3_txt      => NULL
                                       );
          l_cnt := l_cnt + 1;
          l_disb_dt.extend(1);
          l_disb_dt(l_cnt).process_id           := l_process_id;
          l_disb_dt(l_cnt).sl_no                := l_sl_number;
          l_disb_dt(l_cnt).min_credit_pts       := l_pelldisb.min_credit_pts;
          l_disb_dt(l_cnt).base_attendance_type_code := NVL(l_base_attendance.base_attendance_type_code,l_pelldisb.base_attendance_type_code);
        END LOOP;

        FOR l_pell_new_disb IN c_pell_new_disb(l_award_id,l_base_id) LOOP
          lv_rowid    := NULL;
          l_sl_number := NULL;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'^^^inserting into igf_aw_award_t for PELL(new)^^^');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.offered_amt:'||l_pell_new_disb.offered_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.accepted_amt:'||l_pell_new_disb.accepted_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.offered_amt:'||l_pell_new_disb.offered_amt);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.temp_num_val2:'||l_pell_new_disb.temp_num_val2);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.temp_char_val1:'||l_pell_new_disb.temp_char_val1);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.tp_cal_type:'||l_pell_new_disb.tp_cal_type);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.tp_sequence_number:'||l_pell_new_disb.tp_sequence_number);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.ld_cal_type:'||l_pell_new_disb.ld_cal_type);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.ld_sequence_number:'||l_pell_new_disb.ld_sequence_number);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.adplans_id:'||l_pell_new_disb.adplans_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'l_pell_new_disb.award_id:'||l_pell_new_disb.award_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.get_disbursements.debug '|| g_req_id,'^^^done inserting into igf_aw_award_t^^^');
          END IF;
          igf_aw_award_t_pkg.insert_row(
                                        x_rowid               => lv_rowid,
                                        x_process_id          => l_process_id,
                                        x_sl_number           => l_sl_number,
                                        x_fund_id             => l_fund_id,
                                        x_base_id             => l_base_id,
                                        x_offered_amt         => l_pell_new_disb.offered_amt,
                                        x_accepted_amt        => l_pell_new_disb.accepted_amt,
                                        x_paid_amt            => 0,
                                        x_need_reduction_amt  => 100,
                                        x_flag                => 'DB',
                                        x_temp_num_val1       => l_pell_new_disb.offered_amt,
                                        x_temp_num_val2       => l_pell_new_disb.temp_num_val2,
                                        x_temp_char_val1      => l_pell_new_disb.temp_char_val1,
                                        x_tp_cal_type         => l_pell_new_disb.tp_cal_type,
                                        x_tp_sequence_number  => l_pell_new_disb.tp_sequence_number,
                                        x_ld_cal_type         => l_pell_new_disb.ld_cal_type,
                                        x_ld_sequence_number  => l_pell_new_disb.ld_sequence_number,
                                        x_mode                => 'R',
                                        x_adplans_id          => l_pell_new_disb.adplans_id,
                                        x_app_trans_num_txt   => NULL,
                                        x_award_id            => l_pell_new_disb.award_id,
                                        x_lock_award_flag     => NULL,
                                        x_temp_val3_num       => NULL,
                                        x_temp_val4_num       => NULL,
                                        x_temp_char2_txt      => l_pell_new_disb.temp_char2_txt,
                                        x_temp_char3_txt      => NULL
                                       );
          l_cnt := l_cnt + 1;
          l_disb_dt.extend(1);
          l_disb_dt(l_cnt).process_id           := l_process_id;
          l_disb_dt(l_cnt).sl_no                := l_sl_number;
          l_disb_dt(l_cnt).base_attendance_type_code := l_pell_new_disb.temp_char2_txt;
        END LOOP;
      END IF;
    END IF; -- end fed_fund_code <> PELL Check

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.GET_DISBURSEMENTS '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.get_disbursements.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;
  END get_disbursements;

  PROCEDURE add_todo(
                     p_fund_id  IN igf_aw_fund_mast_all.fund_id%TYPE,
                     p_base_id  IN igf_ap_fa_base_rec_all.base_id%TYPE
                    ) IS
    /*
    ||  Created By : skoppula
    ||  Created On : 02-JAN-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    || gmuralid         10-030-2003     BUG 2829487 .In proc add_todo,
    ||                                  inactive_flag parameter was being passed as NULL in insert_row.changed that to 'N'.
    ||  (reverse chronological order - newest change first)
    */

    -- Get all the To Do Items which needs to be assigned to the student
    -- Fetch all To Do Items defined at the fund level and remove all To Do which are already assigned to the student
    CURSOR c_fnd_todo(
                      cp_person_id   igf_ap_fa_base_rec_all.person_id%TYPE,
                      cp_fund_id     igf_aw_fund_mast_all.fund_id%TYPE
                     ) IS
      SELECT tdmst.todo_number,
             tdmst.required_for_application,
             tdmst.max_attempt,
             tdmst.freq_attempt,
             tdmst.system_todo_type_code,
             td.row_id,
             td.base_id,
             td.item_sequence_number,
             td.status,
             td.status_date,
             td.add_date,
             td.corsp_date,
             td.corsp_count,
             td.inactive_flag,
             td.freq_attempt td_freq_attempt,
             td.max_attempt td_max_attempt,
             td.required_for_application td_required_for_application,
             td.legacy_record_flag,
             td.clprl_id
        FROM igf_aw_fund_td_map fndtd,
             igf_ap_td_item_mst tdmst,
             igf_ap_td_item_inst_v td
       WHERE fndtd.fund_id = cp_fund_id
         AND tdmst.todo_number = td.item_sequence_number(+)
         AND tdmst.todo_number = fndtd.item_sequence_number
         AND td.person_id(+) = cp_person_id;

    l_fd_td_rec c_fnd_todo%ROWTYPE;
    lv_rowid    VARCHAR2(30);

    CURSOR c_person_id(
                       cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                      ) IS
      SELECT person_id
        FROM igf_ap_fa_base_rec_all
       WHERE base_id = cp_base_id;
    l_person_id igf_ap_fa_base_rec_all.person_id%TYPE;

    CURSOR c_active_lender(
                           cp_person_id igf_ap_fa_base_rec_all.person_id%TYPE
                          ) IS
      SELECT relationship_cd
        FROM igf_sl_cl_pref_lenders
       WHERE person_id = cp_person_id
         AND TRUNC(SYSDATE) BETWEEN TRUNC(start_date) AND TRUNC(NVL(end_date,SYSDATE));
    l_active_lender igf_sl_cl_pref_lenders.relationship_cd%TYPE;

  BEGIN

    -- Assign all the To Dos which are present at the Fund level and not present for the student.

    l_person_id := NULL;
    OPEN c_person_id(p_base_id);
    FETCH c_person_id INTO l_person_id;
    CLOSE c_person_id;

    FOR c_fnd_todo_rec IN c_fnd_todo(l_person_id, p_fund_id) LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.add_todo.debug '|| g_req_id,'c_fnd_todo_rec.todo_number:'||c_fnd_todo_rec.todo_number);
      END IF;
      IF c_fnd_todo_rec.row_id IS NULL THEN
        igf_ap_td_item_inst_pkg.insert_row(
                                           x_rowid                     =>  lv_rowid,
                                           x_base_id                   =>  p_base_id,
                                           x_item_sequence_number      =>  c_fnd_todo_rec.todo_number,
                                           x_status                    =>  'REQ',
                                           x_status_date               =>  TRUNC(SYSDATE),
                                           x_add_date                  =>  TRUNC(SYSDATE),
                                           x_corsp_date                =>  NULL,
                                           x_corsp_count               =>  NULL,
                                           x_inactive_flag             =>  'N',
                                           x_required_for_application  =>  c_fnd_todo_rec.required_for_application,
                                           x_max_attempt               =>  c_fnd_todo_rec.max_attempt,
                                           x_freq_attempt              =>  c_fnd_todo_rec.freq_attempt,
                                           x_mode                      =>  'R',
                                           x_legacy_record_flag        =>  NULL,
                                           x_clprl_id                  =>  NULL
                                          );
      ELSIF c_fnd_todo_rec.row_id IS NOT NULL AND c_fnd_todo_rec.system_todo_type_code = 'PREFLEND' AND c_fnd_todo_rec.inactive_flag='Y' THEN
        --reactivate the preferred lender item after checking if the student has an active preferred lender
        l_active_lender := NULL;
        OPEN c_active_lender(l_person_id);
        FETCH c_active_lender INTO l_active_lender;
        CLOSE c_active_lender;

        IF l_active_lender IS NULL THEN
          igf_ap_td_item_inst_pkg.update_row(
                                             x_rowid                     =>  c_fnd_todo_rec.row_id,
                                             x_base_id                   =>  c_fnd_todo_rec.base_id,
                                             x_item_sequence_number      =>  c_fnd_todo_rec.todo_number,
                                             x_status                    =>  c_fnd_todo_rec.status,
                                             x_status_date               =>  c_fnd_todo_rec.status_date,
                                             x_add_date                  =>  c_fnd_todo_rec.add_date,
                                             x_corsp_date                =>  c_fnd_todo_rec.corsp_date,
                                             x_corsp_count               =>  c_fnd_todo_rec.corsp_count,
                                             x_inactive_flag             =>  'N',
                                             x_required_for_application  =>  c_fnd_todo_rec.td_required_for_application,
                                             x_max_attempt               =>  c_fnd_todo_rec.td_max_attempt,
                                             x_freq_attempt              =>  c_fnd_todo_rec.td_freq_attempt,
                                             x_mode                      =>  'R',
                                             x_legacy_record_flag        =>  c_fnd_todo_rec.legacy_record_flag,
                                             x_clprl_id                  =>  c_fnd_todo_rec.clprl_id
                                            );

        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_PACKAGING.ADD_TODO '||SQLERRM);
    igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.add_todo.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
    app_exception.raise_exception;

  END add_todo;


  FUNCTION get_date_instance(
                             p_base_id      IN igf_ap_fa_base_rec_all.base_id%TYPE,
                             p_dt_alias     IN igs_ca_da.dt_alias%TYPE,
                             p_cal_type     IN igs_ca_inst.cal_type%TYPE,
                             p_cal_sequence IN igs_ca_inst.sequence_number%TYPE
                            ) RETURN DATE IS
    /*
    ||  Created By : skoppula
    ||  Created On : 02-JAN-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    ||  veramach       30-Oct-2004      FA 152 Modified code to call igf_ap_gen_001.get_date_alias_val
    */

  BEGIN

    RETURN igf_ap_gen_001.get_date_alias_val(
                                             p_base_id         => p_base_id,
                                             p_cal_type        => p_cal_type,
                                             p_sequence_number => p_cal_sequence,
                                             p_date_alias      => p_dt_alias
                                            );
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_date_instance;


  PROCEDURE process_single_fund(
                                p_grp_code            IN  VARCHAR2,
                                p_ci_cal_type         IN  VARCHAR2,
                                p_ci_sequence_number  IN  NUMBER,
                                p_base_id             IN  NUMBER,
                                p_persid_grp          IN  NUMBER
                               ) IS
    /*
    ||  Created By : skoppula
    ||  Created On : 02-JAN-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
    ||  ridas           08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
    */

    -- Fetch the student for a given Base_id or fetch all students for a given group code
    CURSOR cur_sf_std IS
    SELECT fabase.*
      FROM igf_ap_fa_base_rec fabase
     WHERE fabase.ci_cal_type            = p_ci_cal_type
       AND fabase.ci_Sequence_number     = p_ci_sequence_number
       AND fabase.base_id                = NVL(p_base_id, fabase.base_id);
    l_sf_std_rec  cur_sf_std%ROWTYPE;

    -- Fetch all the students for a given Person ID Group
    -- Variables for the dynamic person id group
    lv_status     VARCHAR2(1) ;
    lv_sql_stmt   VARCHAR(32767) ;

    TYPE cur_sf_persidCurTyp IS REF CURSOR ;
    cur_sf_persid cur_sf_persidCurTyp ;
    TYPE l_persid_std_recTyp IS RECORD (  base_id igf_ap_fa_base_rec.base_id%TYPE, coa_f igf_ap_fa_base_rec.coa_f%TYPE );
    l_persid_std_rec l_persid_std_recTyp ;


    -- Get the details of students from the Temp Table in the descending order of their needs
    CURSOR c_ordered_stdnts IS
    SELECT base_id
      FROM igf_aw_award_t
     WHERE flag = 'ST'
       AND process_id = l_process_id
     ORDER BY temp_num_val2 DESC;

    ln_person_count   NUMBER;
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

  BEGIN
    lv_status   := 'S';  -- Defaulted to 'S' and the function will return 'F' in case of failure
    --Bug #5021084
    lv_sql_stmt := igf_ap_ss_pkg.get_pid(p_persid_grp,lv_status,lv_group_type);

    get_process_id;

    -- Process for a single student as the Person ID Group is not Present
    IF p_persid_grp IS NULL THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_single_fund.debug '|| g_req_id,'person id group not specified');
      END IF;
      OPEN cur_sf_std;
      LOOP
        FETCH cur_sf_std INTO l_sf_std_rec;
        EXIT WHEN cur_sf_std%NOTFOUND;

        g_over_awd := NULL;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_single_fund.debug '|| g_req_id,'calling stud_run with base_id:'||l_sf_std_rec.base_id);
        END IF;
        stud_run(
                 l_sf_std_rec.base_id,      -- l_base_id
                 'N',                       -- l_post
                 'D'                        -- l_run_mode
                );
        COMMIT;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_single_fund.debug '|| g_req_id,'----------------stud_run returned-------------------');
        END IF;
    END LOOP;
    CLOSE cur_sf_std;

    -- Process for all the student who belongs to the Given Person ID Group
    ELSE

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_single_fund.debug '|| g_req_id,'person id group specified');
      END IF;
      ln_person_count := 0;

      --Bug #5021084. Passing Group ID if the group type is STATIC.
      IF lv_group_type = 'STATIC' THEN
        OPEN  cur_sf_persid FOR 'SELECT fabase.base_id, igf_aw_coa_gen.coa_amount(fabase.base_id,:g_aprd) coa_f
                                   FROM igf_ap_fa_base_rec fabase
                                  WHERE fabase.ci_cal_type        =  :p_ci_cal_type
                                    AND fabase.ci_sequence_number =  :p_ci_sequence_number
                                    AND fabase.person_id IN ( '||lv_sql_stmt||' ) ' USING  g_awd_prd,g_ci_cal_type,g_ci_sequence,p_persid_grp;
      ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN  cur_sf_persid FOR 'SELECT fabase.base_id, igf_aw_coa_gen.coa_amount(fabase.base_id,:g_aprd) coa_f
                                   FROM igf_ap_fa_base_rec fabase
                                  WHERE fabase.ci_cal_type        =  :p_ci_cal_type
                                    AND fabase.ci_sequence_number =  :p_ci_sequence_number
                                    AND fabase.person_id IN ( '||lv_sql_stmt||' ) ' USING  g_awd_prd,g_ci_cal_type,g_ci_sequence;
      END IF;

      LOOP
        FETCH cur_sf_persid INTO l_persid_std_rec;
        EXIT WHEN cur_sf_persid%NOTFOUND;

        ln_person_count := ln_person_count + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_single_fund.debug '|| g_req_id,'calling calc_students_need with base_id:'||l_persid_std_rec.base_id);
        END IF;
        calc_students_needs(
                            l_persid_std_rec.base_id,
                            l_persid_std_rec.coa_f
                           );


      END LOOP;
      CLOSE cur_sf_persid;

      -- If There are no students in the person_id group then log message and exit
      IF ln_person_count = 0 THEN
        fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_single_fund.debug '|| g_req_id,'no persons in person id group');
        END IF;
      END IF;

      -- Fetch the students as per the decreasing order of their need.
      FOR c_ordered_stdnts_rec IN c_ordered_stdnts LOOP

        -- Process for the student in the decending order of their needs
        g_over_awd := NULL;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.process_single_fund.debug '|| g_req_id,'calling stud_run with base_id:'||c_ordered_stdnts_rec.base_id);
        END IF;

        stud_run(
                 c_ordered_stdnts_rec.base_id,
                 'N',
                 'D'
                );

        COMMIT;

      END LOOP;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.PROCESS_SINGLE_FUND '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.process_single_fund.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      app_exception.raise_exception;
  END process_single_fund;

  PROCEDURE log_parameters(
                           p_award_year           VARCHAR2 DEFAULT NULL,
                           p_awd_prd_code         VARCHAR2 DEFAULT NULL,
                           p_fund_id              NUMBER DEFAULT NULL,
                           p_dist_id              NUMBER DEFAULT NULL,
                           p_base_id              NUMBER DEFAULT NULL,
                           p_persid_grp           NUMBER DEFAULT NULL,
                           p_sf_min_amount        NUMBER DEFAULT NULL,
                           p_sf_max_amount        NUMBER DEFAULT NULL,
                           p_allow_to_exceed      VARCHAR2 DEFAULT NULL,
                           p_upd_awd_notif_status VARCHAR2 DEFAULT NULL,
                           p_lock_award           VARCHAR2 DEFAULT NULL,
                           p_grp_code             VARCHAR2 DEFAULT NULL,
                           p_sim_mode             VARCHAR2 DEFAULT NULL,
                           p_run_mode             VARCHAR2 DEFAULT NULL,
                           p_publish_in_ss_flag   VARCHAR2 DEFAULT NULL
                          ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  l_param_pass_log  igf_lookups_view.meaning%TYPE ;
  l_awd_yr_log      igf_lookups_view.meaning%TYPE ;
  l_pers_number_log igf_lookups_view.meaning%TYPE ;
  l_pers_id_grp_log igf_lookups_view.meaning%TYPE ;
  l_ap_log          igf_lookups_view.meaning%TYPE ;
  l_fund_log        igf_lookups_view.meaning%TYPE ;
  l_dp_log          igf_lookups_view.meaning%TYPE ;
  l_sf_min_log      igf_lookups_view.meaning%TYPE ;
  l_sf_max_log      igf_lookups_view.meaning%TYPE ;
  l_allow_log       igf_lookups_view.meaning%TYPE ;
  l_notif_log       igf_lookups_view.meaning%TYPE ;
  l_lock_log        igf_lookups_view.meaning%TYPE ;
  l_agrp_log        igf_lookups_view.meaning%TYPE ;
  l_sim_log         igf_lookups_view.meaning%TYPE ;
  l_runm_log        igf_lookups_view.meaning%TYPE ;
  l_publish_log     igf_lookups_view.meaning%TYPE ;

  -- Get alternate code
  CURSOR c_alternate_code(
                          cp_award_year VARCHAR2
                         ) IS
    SELECT alternate_code
      FROM igs_ca_inst_all
     WHERE cal_type        = TRIM(SUBSTR(cp_award_year,1,10))
       AND sequence_number = TO_NUMBER(SUBSTR(p_award_year,11));

  l_alternate_code igs_ca_inst_all.alternate_code%TYPE;

  -- Get get group description for group_id
  CURSOR c_person_group(
                        cp_persid_grp igs_pe_persid_group_all.group_id%TYPE
                       ) IS
    SELECT group_cd group_name
      FROM igs_pe_persid_group_all
     WHERE group_id = cp_persid_grp;

  l_persid_grp_name c_person_group%ROWTYPE;

  -- Get AP descripton
  CURSOR c_ap(
              cp_awd_prd_code igf_aw_award_prd.award_prd_cd%TYPE,
              cp_award_year VARCHAR2
             ) IS
    SELECT award_prd_desc
      FROM igf_aw_award_prd
     WHERE award_prd_cd  = cp_awd_prd_code
       AND ci_cal_type = TRIM(SUBSTR(cp_award_year,1,10))
       AND ci_sequence_number = TO_NUMBER(SUBSTR(p_award_year,11));
  l_ap  igf_aw_award_prd.award_prd_desc%TYPE;

  -- Get fund code
  CURSOR c_fund(
                cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE
               ) IS
    SELECT fund_code
      FROM igf_aw_fund_mast_all
     WHERE fund_id = cp_fund_id;
  l_fund igf_aw_fund_mast_all.fund_code%TYPE;

  -- Get person number
  CURSOR c_person_number(
                         cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
      SELECT party_number
        FROM hz_parties parties,
             igf_ap_fa_base_rec_all fabase
       WHERE fabase.person_id = parties.party_id
         AND fabase.base_id   = cp_base_id;
  l_person_number hz_parties.party_number%TYPE;

  -- Get DP details
  CURSOR c_dp(
              cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
             ) IS
    SELECT awd_dist_plan_cd_desc
      FROM igf_aw_awd_dist_plans
     WHERE adplans_id = cp_adplans_id;
  l_dp igf_aw_awd_dist_plans.awd_dist_plan_cd_desc%TYPE;

  -- Get award group
  CURSOR c_awd_grp(
                   cp_grp_code  igf_aw_target_grp_all.group_cd%TYPE,
                   cp_award_year VARCHAR2
                 ) IS
    SELECT description
      FROM igf_aw_target_grp_all
     WHERE group_cd = cp_grp_code
       AND cal_type = TRIM(SUBSTR(cp_award_year,1,10))
       AND sequence_number = TO_NUMBER(SUBSTR(p_award_year,11));
  l_awd_grp c_awd_grp%ROWTYPE;

  BEGIN

    l_param_pass_log  := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');
    l_awd_yr_log      := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_YEAR');
    l_pers_number_log := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PERSON_NUMBER');
    l_pers_id_grp_log := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PERSON_ID_GROUP');
    l_ap_log          := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_PERIOD');
    l_fund_log        := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','FUND_CODE');
    l_dp_log          := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWD_DIST_PLAN');
    l_sf_min_log      := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','MIN_AMOUNT');
    l_sf_max_log      := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','MAX_AMOUNT');
    l_allow_log       := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','ALLOW_EXCEED');
    l_notif_log       := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','UPD_NOTIF_STAT');
    l_lock_log        := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','LOCK_AWD');
    l_agrp_log        := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWD_GRP');
    l_sim_log         := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','SIM_MODE');
    l_runm_log        := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RUN_MODE');
    l_publish_log     := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PUBLISH_IN_SS');

    fnd_file.put_line(fnd_file.log,l_param_pass_log);

    --log award year
    IF p_award_year IS NOT NULL THEN
      OPEN c_alternate_code(p_award_year);
      FETCH c_alternate_code INTO l_alternate_code;
      CLOSE c_alternate_code;
      fnd_file.put_line(fnd_file.log,RPAD(l_awd_yr_log,40) || ' : ' || l_alternate_code);
    END IF;

    --log award period
    IF p_awd_prd_code IS NOT NULL THEN
      OPEN c_ap(p_awd_prd_code,p_award_year);
      FETCH c_ap INTO l_ap;
      CLOSE c_ap;
      fnd_file.put_line(fnd_file.log,RPAD(l_ap_log,40) || ' : ' || l_ap);
    END IF;

    --log fund_id
    IF p_fund_id IS NOT NULL THEN
      OPEN c_fund(p_fund_id);
      FETCH c_fund INTO l_fund;
      CLOSE c_fund;
      fnd_file.put_line(fnd_file.log,RPAD(l_fund_log,40) || ' : ' || l_fund);
    END IF;

    --log distribution plan
    IF p_dist_id IS NOT NULL THEN
      OPEN c_dp(p_dist_id);
      FETCH c_dp INTO l_dp;
      CLOSE c_dp;
      fnd_file.put_line(fnd_file.log,RPAD(l_dp_log,40) || ' : ' || l_dp);
    END IF;

    --log person number
    IF p_base_id IS NOT NULL THEN
      OPEN c_person_number(p_base_id);
      FETCH c_person_number INTO l_person_number;
      CLOSE c_person_number;
      fnd_file.put_line(fnd_file.log,RPAD(l_pers_number_log,40) || ' : ' || l_person_number);
    END IF;

    --log person id group
    IF p_persid_grp IS NOT NULL THEN
      OPEN c_person_group(p_persid_grp);
      FETCH c_person_group INTO l_persid_grp_name;
      CLOSE c_person_group;
      fnd_file.put_line(fnd_file.log,RPAD(l_pers_id_grp_log,40) || ' : ' || l_persid_grp_name.group_name);
    END IF;

    --log minimum amount
    IF p_sf_min_amount IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(l_sf_min_log,40) || ' : ' || p_sf_min_amount);
    END IF;

    --log maximum amount
    IF p_sf_max_amount IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(l_sf_max_log,40) || ' : ' || p_sf_max_amount);
    END IF;

    --log allow to exceed
    IF p_allow_to_exceed IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(l_allow_log,40) || ' : ' || igf_aw_gen.lookup_desc('IGF_AW_SF_ALLOW_EXCEED',p_allow_to_exceed));
    END IF;

    --log update award notification status
    IF p_upd_awd_notif_status IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(l_notif_log,40) || ' : ' || igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_upd_awd_notif_status));
    END IF;

    --log lock award setting
    IF p_lock_award IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(l_lock_log,40) || ' : ' || igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_lock_award));
    END IF;

    --log award group
    IF p_grp_code IS NOT NULL THEN
      OPEN c_awd_grp(p_grp_code,p_award_year);
      FETCH c_awd_grp INTO l_awd_grp;
      CLOSE c_awd_grp;
      fnd_file.put_line(fnd_file.log,RPAD(l_agrp_log,40) || ' : ' ||l_awd_grp.description);
    END IF;

    --log simulation
    IF p_sim_mode IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(l_sim_log,40) || ' : ' || igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_sim_mode));
    END IF;

    --log run mode
    IF p_run_mode IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(l_runm_log,40) || ' : ' || p_run_mode);
    END IF;

    --log publish mode
    IF p_publish_in_ss_flag IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(l_publish_log,40) || ' : ' || igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_publish_in_ss_flag));
    END IF;

    fnd_file.put_line(fnd_file.log,RPAD('-',55,'-'));
  END log_parameters;

  PROCEDURE run(
                errbuf                 OUT NOCOPY VARCHAR2,
                retcode                OUT NOCOPY NUMBER,
                l_award_year           IN  VARCHAR2,
                p_awd_prd_code         IN  VARCHAR2,
                l_grp_code             IN  VARCHAR2,
                l_base_id              IN  NUMBER,
                l_sim_mode             IN  VARCHAR2,
                p_upd_awd_notif_status IN  VARCHAR2,
                l_run_mode             IN  VARCHAR2,
                p_fund_id              IN  NUMBER,
                l_run_type             IN  VARCHAR2,  -- Obsoleted parameter, retaining for backward compatibility
                p_publish_in_ss_flag   IN  VARCHAR2,
                l_run_code             IN  VARCHAR2,  -- Obsoleted parameter, retaining for backward compatibility
                l_individual_pkg       IN  VARCHAR2  -- Obsoleted parameter, retaining for backward compatibility
               ) IS
    /*
    ||  Created By : cdcruz
    ||  Created On : 14-NOV-2000
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
	||  tsailaja		13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  veramach        13-OCT-2003     FA 124 Build - Added logic for validations on g_sf_max_award_amt,g_sf_min_award_amt,g_allow_to_exceed
    ||  (reverse chronological order - newest change first)
    */

    /*
      When Calling from the Packaging Conc. Job
          Award Year     Target Group     Person Number    Action

      1.    Yes              No               No           Get all the student from the FA Base Record who has Valid ISIR
                                                           and valid Target Group. Loop for each person and award the
                                                           funds which are present in that target group.

      2.    Yes              Yes              No           Get all the student from the FA Base Record who has Valid ISIR
                                                           and having mentioned Target Group. Loop for each person and award
                                                           the funds which are present in that target group.

      3.    Yes              No               Yes          Get the target group specified at the student and award the
                                                           funds which are present in that target group.

      4.    Yes              Yes              Yes          Invalid combination, log a message that invalid combination

      5. If fund id is present, that means it is called from singlr fund award process, so process only for that fund
         for the parameter combinations like Person Number ans Person ID Group
    */

    l_ci_cal_type        VARCHAR2(10);
    l_ci_sequence_number NUMBER;

    CURSOR c_temp_rec IS
    SELECT row_id row_id
      FROM igf_aw_award_t awdt
     WHERE awdt.process_id = l_process_id;

    l_temp_rec c_temp_rec%ROWTYPE;

    CURSOR c_summary_awd IS
    SELECT COUNT(*) cnt,
           SUM(awt.offered_amt * awt.temp_num_val1/100) offered_amt,
           fund_code,
           adplans_id
      FROM igf_aw_award_t awt,
           igf_aw_fund_mast_all fm
     WHERE fm.fund_id=awt.fund_id
       AND awt.flag = 'FL'
       AND awt.process_id = l_process_id
     GROUP BY fund_code,
              adplans_id;

    l_summ_rec c_summary_awd%ROWTYPE;

    -- Get the details of
    CURSOR c_fund_dtls( cp_fund_id  igf_aw_fund_mast_all.fund_id%TYPE) IS
    SELECT fm.auto_pkg,
           fm.fund_code,
           fcat.fed_fund_code,
           fcat.fund_source,
           fm.entitlement,
           fm.min_award_amt,
           fm.max_award_amt
      FROM igf_aw_fund_mast fm,
           igf_aw_fund_cat fcat
     WHERE fm.fund_id = cp_fund_id
       AND fm.fund_code = fcat.fund_code;

    -- Fetch all the student when the Target Group and Person Number is not specified who
    -- has valid Payment ISIR ID and also valid Target Group in descending order of their need
    CURSOR c_get_stds(
                      cp_cal_type         igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                      cp_sequence_number  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                     ) IS
    SELECT fabase.base_id,igf_aw_coa_gen.coa_amount(fabase.base_id,g_awd_prd) coa_f
      FROM igf_ap_fa_base_rec_all fabase,
           igf_ap_isir_matched_all im
     WHERE fabase.ci_cal_type = cp_cal_type
       AND fabase.ci_sequence_number = cp_sequence_number
       AND fabase.target_group IS NOT NULL
       AND im.system_record_type = 'ORIGINAL'
       AND im.payment_isir = 'Y'
       AND im.base_id = fabase.base_id;

    -- Get the details of students from the Temp Table in the descending order of their needs
    CURSOR c_ordered_stdnts IS
    SELECT base_id
      FROM igf_aw_award_t
     WHERE flag = 'ST'
       AND process_id = l_process_id
     ORDER BY temp_num_val2 DESC;

    l_str      VARCHAR(4000);
    l_count    NUMBER := 0;

    -- Get distribution plan associated with a target group
    CURSOR c_tgrp_dist(
                        cp_group_cd    igf_aw_target_grp_all.group_cd%TYPE
                      ) IS
      SELECT adplans_id
        FROM igf_aw_target_grp
       WHERE group_cd = cp_group_cd;
    l_tgrp_dist        c_tgrp_dist%ROWTYPE;
    lv_result         VARCHAR2(80);
    lv_method_code    igf_aw_awd_dist_plans.dist_plan_method_code%TYPE;

    l_error_code NUMBER;
  BEGIN
	igf_aw_gen.set_org_id(NULL);
    IF g_req_id IS NULL THEN
      g_req_id := fnd_global.conc_request_id;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'l_award_year:'||l_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'l_grp_code:'||l_grp_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'l_base_id:'||l_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'l_base_id:'||l_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'p_fund_id:'||p_fund_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'g_plan_id:'||g_plan_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'p_publish_in_ss_flag:'||p_publish_in_ss_flag);
    END IF;
    IF NVL(g_sf_packaging,'F') <> 'T' THEN
      log_parameters(
                     p_award_year           => l_award_year,
                     p_awd_prd_code         => p_awd_prd_code,
                     p_fund_id              => p_fund_id,
                     p_dist_id              => NULL,
                     p_base_id              => l_base_id,
                     p_persid_grp           => NULL,
                     p_sf_min_amount        => NULL,
                     p_sf_max_amount        => NULL,
                     p_allow_to_exceed      => NULL,
                     p_upd_awd_notif_status => p_upd_awd_notif_status,
                     p_lock_award           => NULL,
                     p_grp_code             => l_grp_code,
                     p_sim_mode             => NVL(l_sim_mode,'Y'),
                     p_run_mode             => l_run_mode,
                     p_publish_in_ss_flag   => p_publish_in_ss_flag
                    );
    END IF;
    -- Get the Calendar details form the award year paramter
    l_ci_cal_type          := TRIM(SUBSTR(l_award_year,1,10));
    l_ci_sequence_number   := TO_NUMBER(SUBSTR(l_award_year,11));
    l_process_id           := NULL;
    gn_fund_awd_cnt        := NULL;

    IF l_ci_cal_type IS NULL OR l_ci_sequence_number IS NULL THEN
      retcode := 2;
      fnd_message.set_name('IGS','IGS_AD_SYSCAL_CONFIG_NOT_DTMN');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RETURN;
    END IF;

    get_process_id;

    g_awd_prd := p_awd_prd_code;

    IF l_grp_code IS NOT NULL THEN
      OPEN c_tgrp_dist(l_grp_code);
      FETCH c_tgrp_dist INTO l_tgrp_dist;
      check_plan(l_tgrp_dist.adplans_id,lv_result,lv_method_code);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'check_plan returned lv_result: '||lv_result||' lv_method_code: '||lv_method_code);
      END IF;

      IF lv_result <> 'TRUE' THEN
        fnd_message.set_name('IGF',lv_result);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RETURN;
      END IF;
    END IF;


    -- Set all the global parameters
    g_upd_awd_notif_status := p_upd_awd_notif_status;

    g_phasein_participant := isPhaseInParticipant(l_ci_cal_type,l_ci_sequence_number);

    g_publish_in_ss_flag := p_publish_in_ss_flag;
    -- Process for a fund if fund id is present. This condition appears when this
    -- program is being called from "Single Fund Packaging"
    -- Senario : 5
    IF p_fund_id IS NOT NULL THEN

      g_sf_packaging := 'T';
      g_sf_fund      := p_fund_id;
      g_ci_cal_type  := l_ci_cal_type;
      g_ci_sequence  := l_ci_sequence_number;

      -- Check if the fund can be Auto Packaged, if not log a messae and exit
      FOR c_fund_dtls_rec IN c_fund_dtls(p_fund_id) LOOP
        IF c_fund_dtls_rec.auto_pkg <>'Y' THEN
          fnd_message.set_name('IGF','IGF_AW_PK_AUTO_SKIP');
          fnd_message.set_token('FUND_ID',c_fund_dtls_rec.fund_code);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RETURN;
        END IF;

        IF c_fund_dtls_rec.entitlement = 'Y' AND g_allow_to_exceed IS NOT NULL THEN
          fnd_message.set_name('IGF','IGF_AW_ALLOW_EXCD_WHEN_ENTLMNT');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE PARAM_ERR;
        END IF;

        IF c_fund_dtls_rec.fund_source = 'FEDERAL' AND g_allow_to_exceed IS NOT NULL THEN
          fnd_message.set_name('IGF','IGF_AW_ALLOW_EXCD_WHEN_FEDERAL');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE PARAM_ERR;
        END IF;

        IF g_sf_min_amount IS NOT NULL AND g_sf_max_amount IS NOT NULL AND g_sf_min_amount > g_sf_max_amount THEN
          fnd_message.set_name('IGF','IGF_AW_MAX_MIN');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE PARAM_ERR;
        END IF;

        IF c_fund_dtls_rec.fed_fund_code IN ('ACG','SMART') AND g_persid_grp IS NULL THEN
          fnd_message.set_name('IGF','IGF_AW_PER_GRP_REQD');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE PARAM_ERR;
        END IF;

        IF (g_sf_min_amount IS NOT NULL) AND
           ( g_sf_min_amount < NVL(c_fund_dtls_rec.min_award_amt,0) OR  g_sf_min_amount > c_fund_dtls_rec.max_award_amt)
        THEN
          fnd_message.set_name('IGF','IGF_AW_SF_MIN_AMT_LESS_FUND');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;

        IF (g_sf_max_amount IS NOT NULL) AND
           (g_sf_max_amount > c_fund_dtls_rec.max_award_amt OR g_sf_max_amount < NVL(c_fund_dtls_rec.min_award_amt,0))
        THEN
          fnd_message.set_name('IGF','IGF_AW_SF_MAX_AMT_GTR_FUND');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;

      END LOOP;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'calling process_single_fund');
      END IF;
      process_single_fund(
                          l_grp_code,                 -- p_grp_code
                          l_ci_Cal_type,              -- p_ci_cal_type
                          l_ci_sequence_number,       -- p_ci_sequence_number
                          l_base_id,                  -- p_base_id
                          g_persid_grp                -- p_persid_grp
                         );

    -- If calling Packaging process directly from the Conc Job
    ELSE
      g_sf_packaging := 'F';

      -- Conc program cannot be executed for both group code and the base id at a time, so log message and exit
      IF l_grp_code IS NOT NULL AND l_base_id IS NOT NULL THEN
        fnd_message.set_name('IGF','IGF_AW_SF_GRP_BASE');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'both base_id and l_grp_code specified');
        END IF;
        RAISE PARAM_ERR;

      -- Process run for the given Group Code
      ELSIF l_grp_code IS NOT NULL THEN

        group_run(
                  l_grp_code ,                 -- l_group_code
                  l_ci_cal_type  ,             -- l_ci_cal_type
                  l_ci_sequence_number,        -- l_ci_sequence_number
                  NVL(l_sim_mode,'Y'),                  -- l_post (Simulated mode or non simlated mode)
                  l_run_mode                   -- l_run_mode
                 );
      -- Process run for the given student
      ELSIF l_base_id IS NOT NULL THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'calling stud_run with base_id:'||l_base_id);
        END IF;
        g_over_awd := NULL;

        stud_run(
                 l_base_id,                    -- l_base_id
                 NVL(l_sim_mode,'Y'),                   -- l_post (Simulated mode or non simlated mode)
                 l_run_mode                    -- l_run_mode
                );
        IF NVL(l_sim_mode,'Y') = 'N' THEN
          COMMIT;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'stud_run complete.data committed');
          END IF;
        ELSE
          BEGIN
            ROLLBACK TO IGFAW03B_POST_AWARD;
            EXCEPTION
              WHEN OTHERS THEN
                l_error_code := SQLCODE;
                IF l_error_code = -1086 THEN
                  --savepoint not established error
                  --post_award was not called from stud_run as stud_run returned without processing the student
                  --rollback to savepoint established in stud_run
                  ROLLBACK TO STUD_SP;
                ELSE
                  RAISE;
                END IF;
           END;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.stud_run.debug '|| g_req_id,'stud_run complete.data rolled back');
          END IF;
        END IF;

      -- Both Target Group is NULL and Person ID is NULL
      ELSIF l_base_id IS NULL AND l_grp_code IS NULL THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'Processing all students in '||l_ci_cal_type||' '||l_ci_sequence_number);
        END IF;
        FOR c_get_stds_rec IN c_get_stds(l_ci_cal_type, l_ci_sequence_number) LOOP

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'calling calc_students_needs with base_id:'||c_get_stds_rec.base_id);
          END IF;

          calc_students_needs(
                              c_get_stds_rec.base_id,
                              c_get_stds_rec.coa_f
                             );

        END LOOP;

        -- Fetch the students as per the decreasing order of their need.
        FOR c_ordered_stdnts_rec IN c_ordered_stdnts LOOP

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.run.debug '|| g_req_id,'calling stud_run with base_id:'||c_ordered_stdnts_rec.base_id);
          END IF;

          -- Process for the student in the decending order of their needs
          g_over_awd := NULL;
          stud_run(
                   c_ordered_stdnts_rec.base_id,
                   NVL(l_sim_mode,'Y'),
                   l_run_mode
                  );
          IF NVL(l_sim_mode,'Y') = 'N' THEN
            COMMIT;
          ELSE
            BEGIN
              ROLLBACK TO IGFAW03B_POST_AWARD;
              EXCEPTION
                WHEN OTHERS THEN
                  l_error_code := SQLCODE;
                  IF l_error_code = -1086 THEN
                    --savepoint not established error
                    --post_award was not called from stud_run as stud_run returned without processing the student
                    --rollback to savepoint established in stud_run
                    ROLLBACK TO STUD_SP;
                  ELSE
                    RAISE;
                  END IF;
             END;
          END IF;

        END LOOP;

      END IF;
    END IF;

    --- Log the award count INTO output file.
    OPEN c_summary_awd;
    LOOP
      FETCH c_summary_awd INTO l_summ_rec;
      EXIT WHEN c_summary_awd%NOTFOUND;
      l_count := c_summary_awd%ROWCOUNT;

       IF c_summary_awd%ROWCOUNT = 1 THEN
        l_str := RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','FUND_CODE'), 40, ' ');
        l_str := l_str ||RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','AWARD_COUNT'), 30, ' ');
        l_str := l_str ||RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','AWARD_AMOUNT'), 30, ' ');
        fnd_file.put_line(fnd_file.output,RPAD('-',90,'-'));
        fnd_file.put_line(fnd_file.output,l_str);
        fnd_file.put_line(fnd_file.output,RPAD('-',90,'-'));
      END IF;

      l_str := NULL;
      l_str := RPAD(l_summ_rec.fund_code,40,' ');
      l_str :=l_str||RPAD(TO_CHAR(l_summ_rec.cnt),30,' ');
      l_str :=l_str||LPAD(TO_CHAR(l_summ_rec.offered_amt),20,' ');
      fnd_file.put_line(fnd_file.output,l_str );
    END LOOP;
    CLOSE c_summary_awd;

    IF l_count > 0 THEN
      fnd_file.put_line(fnd_file.output,RPAD('-',90,'-'));
    END IF;

    -- Clear out NOCOPY temporary records
    OPEN c_temp_rec;
    LOOP
      FETCH c_temp_rec INTO l_temp_rec;
      EXIT WHEN c_temp_rec%NOTFOUND;

      igf_aw_award_t_pkg.delete_row(l_temp_rec.row_id );

    END LOOP;
    CLOSE c_temp_rec;

    fnd_file.new_line(fnd_file.log,2);

  EXCEPTION

    WHEN PARAM_ERR THEN
      ROLLBACK;
      retcode := 2;
      fnd_file.new_line(fnd_file.log,2);
      fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
      igs_ge_msg_stack.add;
      igs_ge_msg_stack.conc_exception_hndl;

    WHEN OTHERS THEN
      ROLLBACK;
      RETCODE := 2;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.RUN '||SQLERRM);
      errbuf := fnd_message.get;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.run.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;

  END run;


  PROCEDURE pkg_single_fund(
                            errbuf                 OUT NOCOPY VARCHAR2,
                            retcode                OUT NOCOPY NUMBER,
                            p_award_year           IN  VARCHAR2,  -- 10
                            p_awd_prd_code         IN  VARCHAR2,
                            p_fund_id              IN  NUMBER,    -- 20
                            p_dist_id              IN  NUMBER,
                            p_base_id              IN  NUMBER,    -- 40
                            p_persid_grp           IN  NUMBER,    -- 50
                            p_sf_min_amount        IN  NUMBER,
                            p_sf_max_amount        IN  NUMBER,
                            p_allow_to_exceed      IN  VARCHAR2,
                            p_upd_awd_notif_status IN  VARCHAR2,  -- 60
                            p_lock_award           IN  VARCHAR2,
                            p_publish_in_ss_flag   IN  VARCHAR2
                           ) IS

    /*
    ||  Created By : skoppula
    ||  Created On : 02-JAN-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             WHEN            What
    ||  (reverse chronological order - newest change first)
	||  tsailaja	  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    || veramach       30-Jun-2004     bug 3709109 - Added call to function check_disb to enforce the rule that FWS funds can
    ||                                have only one disbursement per term
    ||  veramach      20-NOV-2003     FA 125 multiple distribution method
    ||                                Added p_dist_id as parameter and validations on this parameter
    ||  veramach      13-OCT-2003     FA 124 - Removed p_grp_code parameter. Added p_sf_min_amount,p_sf_max_amount,p_allow_to_exceed
    ||  pmarada       14-feb-2002     added p_upd_awd_notif_status parameter.
    */

    lv_result      VARCHAR2(80) := NULL;
    lv_method_code VARCHAR2(80) := NULL;
    l_terms        NUMBER       := 0;

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    IF g_req_id IS NULL THEN
      g_req_id := fnd_global.conc_request_id;
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'g_persid_grp:'||p_persid_grp);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'g_sf_min_amount:'||p_sf_min_amount);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'g_sf_max_amount:'||p_sf_max_amount);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'g_allow_to_exceed:'||p_allow_to_exceed);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'p_fund_id:'||p_fund_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'p_dist_id:'||p_dist_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'p_lock_award:'||p_lock_award);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'p_awd_prd_code:'||p_awd_prd_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'p_publish_in_ss_flag:'||p_publish_in_ss_flag);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'calling run');
    END IF;

    log_parameters(
                   p_award_year           => p_award_year,
                   p_awd_prd_code         => p_awd_prd_code,
                   p_fund_id              => p_fund_id,
                   p_dist_id              => p_dist_id,
                   p_base_id              => p_base_id,
                   p_persid_grp           => p_persid_grp,
                   p_sf_min_amount        => p_sf_min_amount,
                   p_sf_max_amount        => p_sf_max_amount,
                   p_allow_to_exceed      => p_allow_to_exceed,
                   p_upd_awd_notif_status =>  p_upd_awd_notif_status,
                   p_lock_award           => p_lock_award,
                   p_grp_code             => NULL,
                   p_sim_mode             => NULL,
                   p_run_mode             => NULL,
                   p_publish_in_ss_flag   => p_publish_in_ss_flag
                  );
    -- Check whether the required parameters are passed or not.
    -- If sufficient parameters are not present then log a message and exit the conc job
    IF p_base_id IS NULL AND p_persid_grp IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_SF_PARAM_NULL');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE PARAM_ERR;
    ELSIF p_base_id IS NOT NULL AND p_persid_grp IS NOT NULL THEN
      fnd_message.set_name('IGF','IGF_AW_SF_BASE_PERSID');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE PARAM_ERR;
    END IF;

    g_sf_packaging := 'T';
    g_lock_award   := p_lock_award;

    check_plan(p_dist_id,lv_result,lv_method_code);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packaging.pkg_single_fund.debug '|| g_req_id,'check_plan returned lv_result: '||lv_result||' lv_method_code: '||lv_method_code);
    END IF;

    IF lv_result <> 'TRUE' THEN
      fnd_message.set_name('IGF',lv_result);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE PARAM_ERR;
    ELSE
      g_plan_id     := p_dist_id;
      g_method_cd := lv_method_code;
    END IF;

    g_persid_grp      := p_persid_grp;
    g_sf_min_amount   := p_sf_min_amount;
    g_sf_max_amount   := p_sf_max_amount;
    g_allow_to_exceed := p_allow_to_exceed;
    g_publish_in_ss_flag := p_publish_in_ss_flag;

    run(
        errbuf,                        --  errbuf
        retcode,                       --  retcode
        p_award_year,                  --  l_award_year
        p_awd_prd_code,                --  p_awd_prd_code
        NULL,                          --  l_grp_code
        p_base_id,                     --  l_base_id
        'N',                           --  l_sim_mode
        p_upd_awd_notif_status,        --  p_upd_awd_notif_status
        'D',                           --  l_run_mode
        p_fund_id,                     --  p_fund_id
        NULL,                          --  l_run_type           -- Obsoleted parameter
        p_publish_in_ss_flag,          --  p_publish_in_ss_flag
        NULL,                          --  l_run_code           -- Obsoleted parameter
        NULL                           --  l_individual_pkg     -- Obsoleted parameter
       );

  EXCEPTION
    WHEN PARAM_ERR THEN
      ROLLBACK;
      retcode := 2;
      fnd_file.new_line(fnd_file.log,2);
      fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
      igs_ge_msg_stack.add;
      igs_ge_msg_stack.conc_exception_hndl;

    WHEN OTHERS THEN
      ROLLBACK;
      RETCODE := 2;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_PACKAGING.PKG_SINGLE_FUND '||SQLERRM);
      errbuf := fnd_message.get;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_packaging.pkg_single_fund.exception '|| g_req_id,'sql error message: '||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;

  END pkg_single_fund;

END igf_aw_packaging;

/
