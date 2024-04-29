--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_FEE_ASS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_FEE_ASS" AS
/* $Header: IGSFI09B.pls 120.45 2006/06/29 12:00:04 abshriva ship $ */

/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who            When         What
 abshriva       19-Jun-2006   Bug 5104329 -Introduced new function finpl_get_derived_am_at and involed in finpl_prc_fee_cat_fee_liab
 akandreg       31-May-2006  Bug 5134636 - Modified finpl_lock_records and finpl_insert_record
 abshriva       24-May-2006  Bug:5204728 - Added Order by clause in both cursor of finpl_find_far.Introduced p_trace_on in create_retention_charge
 abshriva       17-May-2006  Bug 5113295 - Modifies finpl_chk_debt_ret_sched - Added call to igs_fi_gen_008.chk_unit_prg_transfer
 abshriva       12-May-2006  Bug 5217319: Amount Precision change in create_retention_charge,finpl_ins_fee_ass
 gurprsin       06-Dec-2005  Bug 4735807, Modified function 'finp_ins_enr_fee_ass', Modified the logic to return and log the message
                             if No Fee category is attached to the SPA.
 abshriva       05-Dec-2005  Bug 4701695  Modified function 'finp_ins_enr_fee_ass'
 pathipat       23-Nov-2005  Bug 4718712 - Modified finpl_ins_fee_as, finpl_chk_debt_ret_sched, finp_clc_ass_amnt
                             and finpl_prc_fee_cat_fee_liab. Added course_cd and career to tbl_wav_fcfl.
 ayedubat       03-NOV-2005  Bug 4634950 - Changed the procedure, finp_ins_enr_fee_ass to set the Global
                             Parameter, g_v_wav_calc_flag to N after the call to create_waivers procedure
 ayedubat       17-OCT-2005  Bug 4639869 - Incase the Fee Assessment is invoked from Tutiton Waivers logic,
                             Rollback should not be used as this would cause to rollback the Waivers records
                             prior to invocation of Fee Assessment
 ayedubat       17-OCT-2005  Bug 4639869 - Changed the logic to Roll Back upto Save Point, fee_calc_sp only
                             if the global parameter g_v_wav_calc_flag is set to N. Also changed the logic to
                             assess the SPA records even if the profile, Auto Calculation of Waivers is set to N
 pathipat       14-Oct-2005  Bug 4644004 - Retention amount is not calculated for increment charge method
                             Modified finpl_ins_fee_as
 pathipat       14-Oct-2005  Bug 4634543 - Waiver amt not getting computed from fee assessment process
                             Modified finp_ins_enr_fee_ass
 pathipat       10-Oct-2005  Bug 4375258 - Change party_number FK to TCA parties impact -
                             Added new local function finpl_get_org_unit_cd to fetch the org_unit_cd\
                             Replaced usage of igs_fi_gen_008.get_party_number with finpl_get_org_unit_cd for Org derivation
 pathipat       04-Oct-2005  Bug 3781716 - Improper output message when fee category missing
                             Modified finp_ins_enr_fee_ass - added code to log message and error out if Fee Cat is
                             not specified for the SPA.
 pathipat       21-Sep-2005  Bug 4383148 - Fees not assessed if attendance type cannot be derived
                             Modified finpl_get_derived_values
 pathipat       21-Sep-2005  Enh 3513252 - Modified finp_clc_ass_amnt - Removed appending IGS_FI_PRE_SET_CHARGE
                             to the fee type description
 uudayapr       16-Sep-2005  Bug 4609164 - Modified the code logic in finpl_ins_fee_ass procedure
 pathipat       06-Sep-2005  Bug 4540295 - Fee assessment produce double fees after program version change
 bannamal       26-Aug-2005  Enh#3392095 Tuition Waiver Build.
 bannamal       08-Jul-2005  Enh#3392088 Campus Privilege Fee Build.
 bannamal       03-JUN-2005  Bug#3442712 Unit Level Fee Assessment Build. Changes done as per TD.
 bannamal       27-May-2005  Bug#4077763 Fee Calculation Performance Enhancement. Changes done as per TD.
 bannamal       14-Apr-2005  Bug#4297359 ER Registration Fee issue
                             Modified finpl_clc_chg_mthd_elements. Added code to check whether the credit points for the unit
                             attempt is non zero in case the non zero billable cp flag is set to 'Y'.
                             Also modified finpl_chk_debt_ret_sched. modified the call to igs_fi_gen_008.get_complete_withdr_ret_amt
                             to add one more parameter.
 bannamal       31-MAR-2005  Bug 4224364 STUDENT FINANCE UPTAKE OF PROGRAM TRANSFER FUTURE DATED FLAG VALUE CHANGES
                             Modified the cursors c_get_term_recs, c_get_scas_recs to ignore the program attempts
                             with Future-Dated Transfer flag set to 'C'
 svuppala       21-MAR-2005  Bug 4240402 Timezone impact; Truncating the time part in calling place of the table handlers
                             of the tables IGS_FI_FEE_AS_ALL, IGS_FI_FEE_AS_ITEMS.
                             Modified the sysdate entries as Trunc(Sysdate) and
                             p_effective_dt also modified as trunc(p_effective_dt) where ever required .
 pathipat       18-Nov-2004 Bug 4017841 - Modified get_stdnt_res_status_cd() and finp_ins_enr_fee_ass()
                            Removed reference to res_dt_alias of table igs_fi_control_all and associated code
 rmaddipa       05-NOV-2004 Enh 3988455, Modified get_stdnt_unit_set_dtls
 rmaddipa       03-Nov-2004 Enh 3988455, Modified the procedure finpl_prc_predictive_scas
 rnirwani       13-Sep-2004 changed cursor c_latest_intermit_date  to not consider logically deleted records and
                            also to avoid un-approved intermission records. Bug# 3885804
 pathipat       07-Sep-2004 Enh 3880438 - Retention Enhancements
                            Modified finpl_chk_debt_ret_sched, finpl_ins_fee_ass, finp_ins_enr_fee_ass
                            Added proc create_retention_charge.
                            Removed duplicate function finpl_chk_debt_ret_sched
 shtatiko       27-JUL-2004 Enh# 3787816, Removed function finpl_charge_is_declined. This call has been replaced with igs_fi_gen_008.chk_chg_adj
 shtatiko       23-JUL-2004 Enh# 3741400, Added finpl_clc_sua_cp and modified c_sua_load, finpl_clc_chg_mthd_elements.
 pathipat       01-Jul-2004 Bug 3734842 - Modified finpl_prc_fee_cat_fee_liab() to lock records before processing.
                            Modified finpl_ins_fee_ass() to check if header and line records were created correctly
                            Added functions finpl_lock_records(), finpl_insert_record() and finpl_check_header_lines()
 shtatiko       24-DEC-2003 Enh# 3167098, Removed references to g_d_prg_chg_da_alias_val and g_b_prg_chg_da_use
                            as fee assessment calculations based on program change enforcement date alias is removed.
                            Impacted procedures are finp_ins_enr_fee_ass, finpl_prc_fee_cat_fee_liab, finpl_clc_chg_mthd_elements and finpl_get_derived_values
                            Removed references to igs_fi_f_cat_cal_rel.
 uudayapr       17-dec-2003 Bug#3080983 ,Modified the cursor c_fadv to fetch data from the table IGS_FI_FEE_AS instead of the view
                            IGS_FI_FEE_ASS_DEBT_V. and also the declartions of IGS_FI_FEE_ASS_DEBT_V.assessment_amount%TYPE to NUMBER
 shtatiko       08-DEC-2003 Bug# 3175779, Modified finp_clc_ass_amnt. Separated the processing of element ranges and element range rates.
 shtatiko       13-NOV-2003 Bug# 3255069, p_charge_elements is made to 1 only when Charge Method is overridden.
                            And this is done only after processing all records in PL/SQL Table.
 pathipat       05-Nov-2003 Enh 3117341 - Audit and Special Fees TD - Modifications according to TD, s1a
 pathipat       29-Oct-2003 Bug 3166331 - Modified finp_clc_ass_amnt
                            Derived location_cd from SUA level if charge method <> Flatrate added cursor c_sua_location_cd for the same.
 pathipat       13-Oct-2003 Bug 3166331 - Modified finp_clc_ass_amnt
                            Modified code to derive org_unit_cd from Unit Attempt/Unit Section level
                            if the charge method is not Flatrate. Also for Predictive Mode.
 pathipat       01-Oct-2003 Bug 3164141 - Modified finpl_ins_fee_ass - Added check for Declined Charges
                            Modified code to log messages just before the insert into igs_fi_fee_as happens
 pathipat       12-Sep-2003 Enh 3108052 - Unit Sets in Rate Table build
                            Modifications according to TD - s1a
 pathipat       03-Sep-2003 Bug 3123669 - Modified finp_clc_ass_amnt - If charge method is overridden, then re-set charge method
                            to Flat Rate and Status = 'O'. Removed commented out code.
 vchappid       22-Jul-2003 Bug#3048175, Element Ranges mapping bug. In function finp_clc_ass_amnt, parameter p_charge_elements
                            should be set only when the element rate range is found and not when the Element Range Applies.
 vchappid       11-Jul-2003 Bug#2916881 procedure finpl_get_derived_values, flags v_on_att_mode,v_off_att_mode,
                            v_composite_att_mod are initialized to FALSE. When, attendance mode/type is not derived
                            then the assessment should be stopped.
 vvutukur       26-May-2003 Enh#2831572.Financial Accounting Build.Modified procedure finpl_ins_fee_ass.
 knaraset       02-May-03   Modified cursors c_suah_load_scahfv and c_sua_hist_load in function finpl_clc_chg_mthd_elements
                            and c_org_unit_cd and c_unit_class_att in function finpl_prc_sua_load to consider uoo_id
                            as part of MUS build bug 2829262.
 vchappid       12-Feb-03   Bug#2788346, function finpl_clc_chg_mthd_elements invokes function finpl_prc_sua_load. This
                            invoking logic is changed for 'Flat Rate' charge method.
 vchappid       27-Jan-03   Bug#2656411, in the function finpl_ins_match_chg_rate, modified the logic for identifying
                            matching fee assessment rate
 pradhakr       15-Jan-03   Added one more paramter no_assessment_ind to
                            the call enrp_get_load_apply as an impact, following
                            the modification of the package Igs_En_Prc_Load.
                            Changes wrt ENCR026. Bug# 2743459
 vchappid        09-Jan-03  Bug# 2660155, As a review comment, in the log messages Person id is replaced with the person number
 vchappid        11-Nov-02  Bug# 2584986, GL- Interface Build, New Date parameter p_d_gl_date
                            is added to the finp_ins_enr_fee_ass procedure specification,
                            the same parameter is passed to the charges API
                            Reference to the igs_fi_curr is removed, Exchange_Rate is always passed as 1 only.
 npalanis        23-OCT-02  Bug : 2608360
                            references to residency_class_id and residency_status_id is changed to residency_status_cd
                            and residency_class_cd due to transtion of residency_class and residency_status code class
                            to igs lookups
 vchappid        21-Oct-02  Bug# 2580672, Modifications to the code as suggested by Enrolment Unit Attempt TD
 vchappid        17-Oct-02  Bug# 2595962, Removed the procedure finpl_create_todo_rec,
                            changes as per the Predictive Fee Assessment TD
 sarakshi        13-Sep-02  Enh#2564643,removed the reference of subaccount also default for gscc fix
 vchappid        25-jul-02  Bug#2237227, added 'add_flag' with Default value 'N' into the Pl/SQL table t_fee_as_items
                            In the Function finpl_sum_fee_ass_item, if the record in the pl/sql table matches with values
                            that are passed to the function and the Fee Calculation Method is Primary Career then the Charge
                            Elements, EFTSU, Credit Points and the assessment amount are added to the existing PL/SQL table
                            otherwise the values are replaced with the values that are passed to the Function
 vchappid        18-Jul-02  Bug# 2326166, values of Credit Points, Eftsu are also recorded when a charge is created incase when the
                            charge method is Per Unit, Per Credit Points and EFTSU incase of Institution/Non-Institution Fee Triggers
 vchappid        15-Jul-02  Bug# 2433955, logging of message -IGS_FI_DER_RES_STAT is incorrectly done.
                            Same Message Name is logged using procedure r_s_log_entry and the same message name is used to set
                            the name of the message name when the details have to be shown to the user
                            Message Name IGS_FI_DER_RES_STAT is changed to IGS_FI_RES_STAT, the new message is already
                            registered in the system but is not being used in the process.
 rnirwani        11-Jun-02  Bug# 2396536
                            Modified procedure finp_ins_enr_fee_ass so that after the check for key program in case it is found that the key program does
                            not exist then the message is logged. The log entry is saved and a return true is done. This will enable the process to continue
                            processing for other students - if applicable.
 rnirwani        28-May-02  Bug# 2378804
                            Removed the generic invocation of get-lci-fci-rel and moved the same to procedures: get_derived_elemens
                            and clc_chg_method_elems where actually the load calendar values would be used. removed the usage of global variable since
                            it is not required any longer.
 rnirwani        27-May-02  Bug# 2378804
                            Moved the code related to setting the global variable gv_Current_Data at the beginning of the procedure.
                            Altered the invocation of get-lci-fci-rel so that in case teh prior fee cal instance is passed then
                            the load calendar for prior fee calendar should be returned by the this function. This load calendar is
                            then used for all further calculations.
 rnirwani        13-May-02  Bug# 2261649 - Removed the variable lv_usec_amount since it was not being used
                            and referrd to table IGS_PS_USEC_CHARGE which has been obsolete.
 rnirwani        02-May-02  Bug# 2344901 - modification in procedure finp_clc_ass_amnt.
                            fee assessment does not happen in case a charge rate record is not located
                            for any one line item records (where multiple exists).
 smadathi        02-May-2002   Bug 2261649. The function finp_get_additional_charge removed.
 rnirwani        02-May-02  Bug# 2345191  modified procedure finp_clc_ass_amnt
                            the contract fee rate identification code was using the parameter passed attributes
                            for attendance type, mode and location.
                            It is supposed to use the derived values.
 rnirwani        17-apr-02  bug# 2317155  modified finpl_ins_fee_ass .
                            passed org unit code to the charges API
 vchappid        17-Jan-02  Enh Bug#2162747, Key Program Implementation, Fin Cal Inst parameters
                            removed, new parameter p_c_career is added
 masehgal        17-Jan-2002   ENH # 2170429
                               Obsoletion of SPONSOR_CD
 vchappid        29-Nov-01  Enh Bug#2122257, Changed some of the cursor definitions
                            obsolecence of function finpl_get_fee_cat is done
 (reverse chronological order - newest change first)
***************************************************************/
  --
  X_ROWID               VARCHAR2(25);
  v_fa_sequence_number  igs_fi_fee_as_all.transaction_id%TYPE;
  g_v_person_number     hz_parties.party_number%TYPE;
  l_v_lkp_all           CONSTANT VARCHAR2(60) := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'ALL');

  TYPE inst_prog_details_rec_type IS RECORD (
         program_cd       igs_ps_ver_all.course_cd%TYPE,
         program_version  igs_ps_ver_all.version_number%TYPE,
         career           igs_ps_ver_all.course_type%TYPE );

  -- This table type will hold the program details which are liable for an Institution system fee trigger category.
  TYPE inst_prog_det_tbl_typ IS TABLE OF inst_prog_details_rec_type  INDEX BY BINARY_INTEGER;

  g_inst_liable_progs_tbl inst_prog_det_tbl_typ;
  g_n_inst_progs_cntr     NUMBER;

  g_v_fee_alt_code   igs_ca_inst_all.alternate_code%TYPE;

  -- This is set to TRUE if Institution Fee is to be assessed in Predictive Mode.
  g_b_prc_inst_fee  BOOLEAN;

  g_v_career         CONSTANT igs_fi_control_all.fee_calc_mthd_code%TYPE := 'CAREER';
  g_v_program        CONSTANT igs_fi_control_all.fee_calc_mthd_code%TYPE := 'PROGRAM';
  g_v_primary_career CONSTANT igs_fi_control_all.fee_calc_mthd_code%TYPE := 'PRIMARY_CAREER';
  g_v_retention      CONSTANT igs_fi_inv_int_all.transaction_type%TYPE   := 'RETENTION';

  g_v_chgmthd_flatrate  CONSTANT igs_fi_invln_int_all.s_chg_method_type%TYPE := 'FLATRATE';


  -- This indicates whether any records exists in PL/SQL table maintained.
  g_b_fee_chgs_exists BOOLEAN;

  g_v_fcfl_source VARCHAR2(10) := NULL;
  g_v_wav_calc_flag VARCHAR2(1) := NULL;

  -- Profile for determining whether Nominated or Derived values are used
  g_v_att_profile         CONSTANT fnd_lookup_values.lookup_code%TYPE := FND_PROFILE.VALUE('IGS_FI_NOM_DER_VALUES');
  g_v_auto_calc_wav_prof  CONSTANT VARCHAR2(30) := fnd_profile.VALUE('IGS_FI_AUTO_CALC_WAIVERS');

  g_n_org_id      CONSTANT igs_fi_fee_as_all.org_id%TYPE := igs_ge_gen_003.get_org_id;

  -- Global variable to hold Currency Code - assigned a value in finp_ins_enr_fee_ass, cursor c_fi_control
  g_v_currency_cd igs_fi_control_all.currency_cd%TYPE := NULL;

  -- Global Cursor to get the Alternate Code for a Calendar Instance passed.
  CURSOR g_c_alternate_code ( cp_v_cal_type igs_ca_inst_all.cal_type%TYPE,
                              cp_n_seq_num  igs_ca_inst_all.sequence_number%TYPE ) IS
    SELECT alternate_code
    FROM igs_ca_inst_all
    WHERE cal_type = cp_v_cal_type
    AND sequence_number = cp_n_seq_num;

  g_v_res_profile    CONSTANT VARCHAR2(100) := fnd_profile.VALUE('IGS_FI_RES_CLASS_ID');

  tbl_fee_as_items t_fee_as_items_typ;  -- Holds the records of previous assessment while processing for retention
  tbl_fee_as_items_diff t_fee_as_items_typ;  -- Holds the records which are the diff between previous assessment and current assessment while processing retention
  tbl_fee_as_items_dummy t_fee_as_items_typ;  -- This is the dummy table used in retention calculation

  TYPE t_unit_status IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE t_date IS TABLE OF igs_en_su_attempt_all.enrolled_dt%TYPE INDEX BY BINARY_INTEGER;

  TYPE wav_fcfl_rec_type IS RECORD (
                    p_fee_category   igs_fi_f_cat_fee_lbl_all.fee_cat%TYPE,
                    p_fee_type       igs_fi_f_cat_fee_lbl_all.fee_type%TYPE,
                    p_course_cd      igs_en_stdnt_ps_att_all.course_cd%TYPE,
                    p_career         igs_ps_ver_all.course_type%TYPE);

  TYPE wav_fcfl_tbl_type IS TABLE OF wav_fcfl_rec_type INDEX BY BINARY_INTEGER;
  tbl_wav_fcfl  wav_fcfl_tbl_type;
  t_dummy_wav_fcfl wav_fcfl_tbl_type;

  -- Procedure to log given String to fnd_log_messages. Message Level will be STATEMENT.
  PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                         p_v_string IN VARCHAR2 ) IS
  BEGIN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

      fnd_log.string( fnd_log.level_statement, 'Fee Assessment:' || p_v_module, p_v_string);

    END IF;
  END log_to_fnd;

PROCEDURE check_census_dt_setup(
              p_v_predictive_mode     IN VARCHAR2,
              p_v_load_cal_type       IN igs_fi_f_cat_ca_inst.fee_cal_type%TYPE,
              p_n_load_ci_seq_number  IN igs_fi_f_cat_ca_inst.fee_ci_sequence_number%TYPE,
              p_d_cns_dt_als_val      OUT NOCOPY DATE,
              p_b_return_status       OUT NOCOPY BOOLEAN,
              p_v_message_name        OUT NOCOPY VARCHAR2 ) IS
/*----------------------------------------------------------------------------
||  Created By : UMESH UDAYAPRAKASH
||  Created On : 06-JAN-2004
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  bannamal        27-May-2005     Bug#4077763 Fee Calculation Performance Enhancement.
||                                  Replaced the literal used in the cursor c_census_dt_alias by cursor parameter.
||  (reverse chronological order - newest change first)
----------------------------------------------------------------------------*/
  CURSOR c_census_dt_alias (cp_n_s_control_num igs_ge_s_gen_cal_con.s_control_num%TYPE) IS
    SELECT census_dt_alias
    FROM igs_ge_s_gen_cal_con
    WHERE s_control_num = cp_n_s_control_num;

  CURSOR c_check_dt_alias (cp_dt_alias igs_ca_da_inst.dt_alias%TYPE,
                           cp_cal_type igs_ca_da_inst.cal_type%TYPE,
                           cp_ci_sequence_number igs_ca_da_inst.ci_sequence_number%TYPE) IS
    SELECT MAX(alias_val)
    FROM igs_ca_da_inst_v
    WHERE dt_alias = cp_dt_alias
    AND cal_type = cp_cal_type
    AND ci_sequence_number = cp_ci_sequence_number;

  l_v_census_dt_alias     igs_ge_s_gen_cal_con.census_dt_alias%TYPE;
  l_d_check_dt_alias      igs_ca_da_inst_v.alias_val%TYPE;
BEGIN

  p_d_cns_dt_als_val := NULL;
  IF p_v_load_cal_type IS NULL OR
     p_n_load_ci_seq_number IS NULL OR
     p_v_predictive_mode IS NULL
  THEN
    p_b_return_status := FALSE;
    RETURN ;
  END IF;

  log_to_fnd( p_v_module => 'check_census_dt_setup',
              p_v_string => 'Entered check_census_dt_setup. ');

  IF (p_v_predictive_mode = 'Y') OR (p_v_predictive_mode = 'N' AND g_c_fee_calc_mthd = g_v_program) THEN
    OPEN c_census_dt_alias ( cp_n_s_control_num => 1 );
    FETCH c_census_dt_alias INTO l_v_census_dt_alias;
    CLOSE c_census_dt_alias;

    IF l_v_census_dt_alias IS NULL THEN
      p_b_return_status := FALSE;
      p_v_message_name :='IGS_FI_NO_CENSUS_DT_SETUP';
      log_to_fnd( p_v_module => 'check_census_dt_setup',
                  p_v_string => 'Returning with message IGS_FI_NO_CENSUS_DT_SETUP.');
      RETURN;
    END IF;

    OPEN c_check_dt_alias(cp_dt_alias           => l_v_census_dt_alias,
                          cp_cal_type           => p_v_load_cal_type,
                          cp_ci_sequence_number => p_n_load_ci_seq_number);
    FETCH c_check_dt_alias INTO l_d_check_dt_alias;
    CLOSE c_check_dt_alias;

    IF l_d_check_dt_alias IS NOT NULL THEN
       p_d_cns_dt_als_val := l_d_check_dt_alias;
       p_b_return_status := TRUE;
    ELSE
      p_v_message_name := 'IGS_FI_NO_CENSUS_DT_SETUP';
      p_b_return_status := FALSE;
    END IF;

    log_to_fnd( p_v_module => 'check_census_dt_setup',
                p_v_string => 'Returning Out: Alias Val:' || TO_CHAR(p_d_cns_dt_als_val, 'DD-MON-YYYY') || ', Message: ' || p_v_message_name);
    RETURN;

  ELSE
    log_to_fnd( p_v_module => 'check_census_dt_setup',
                p_v_string => 'Returning in case of Non-Predictive and Non-Program.');
    p_b_return_status := TRUE;
    RETURN ;
  END IF;

END check_census_dt_setup;

FUNCTION  finpl_lock_records(p_n_person_id                 IN igs_fi_fee_as_all.person_id%TYPE,
                             p_v_course_cd                 IN igs_ps_ver_all.course_cd%TYPE,
                             p_v_fee_cal_type              IN igs_fi_fee_as_all.fee_cal_type%TYPE,
                             p_n_fee_ci_sequence_number    IN igs_fi_fee_as_all.fee_ci_sequence_number%TYPE)  RETURN BOOLEAN;

FUNCTION finpl_get_derived_am_at (p_person_id                 IN     hz_parties.party_id%TYPE,
                                  p_course_cd                 IN     igs_ps_course.course_cd%TYPE,
                                  p_effective_dt              IN     DATE,
                                  p_fee_cal_type              IN     igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
                                  p_fee_ci_sequence_number    IN     igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE,
                                  p_fee_type                  IN     igs_fi_f_cat_fee_lbl_all.fee_type%TYPE,
                                  p_s_fee_trigger_cat         IN     igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                                  p_trace_on                  IN     VARCHAR2,
                                  p_c_career                  IN     igs_ps_ver_all.course_type%TYPE,
                                  p_derived_attendance_type   OUT    NOCOPY igs_fi_fee_as_rate.attendance_type%TYPE,
                                  p_derived_att_mode          OUT    NOCOPY igs_en_atd_mode_all.govt_attendance_mode%TYPE) RETURN BOOLEAN;


FUNCTION  finpl_check_header_lines(p_n_person_id       igs_fi_fee_as_all.person_id%TYPE,
                                   p_n_transaction_id  igs_fi_fee_as_all.transaction_id%TYPE) RETURN BOOLEAN;

PROCEDURE create_retention_charge( p_n_person_id               IN igs_fi_inv_int_all.person_id%TYPE,
                                   p_v_course_cd               IN igs_fi_inv_int_all.course_cd%TYPE,
                                   p_v_fee_cal_type            IN igs_fi_inv_int_all.fee_cal_type%TYPE,
                                   p_n_fee_ci_sequence_number  IN igs_fi_inv_int_all.fee_ci_sequence_number%TYPE,
                                   p_v_fee_type                IN igs_fi_inv_int_all.fee_type%TYPE,
                                   p_v_fee_cat                 IN igs_fi_inv_int_all.fee_cat%TYPE,
                                   p_d_gl_date                 IN igs_fi_invln_int_all.gl_date%TYPE,
                                   p_n_uoo_id                  IN igs_fi_invln_int_all.uoo_id%TYPE,
                                   p_n_amount                  IN igs_fi_inv_int_all.invoice_amount%TYPE,
                                   p_v_fee_type_desc           IN igs_fi_fee_type_all.description%TYPE,
                                   p_v_fee_trig_cat            IN igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                                   p_trace_on                  IN VARCHAR2);

  FUNCTION finp_clc_ass_amnt(
  p_effective_dt                   IN DATE ,
  p_person_id                      IN hz_parties.party_id%TYPE ,
  p_course_cd                      IN igs_en_stdnt_ps_att_all.course_cd%TYPE ,
  p_course_version_number          IN igs_en_stdnt_ps_att_all.version_number%TYPE ,
  p_course_attempt_status          IN VARCHAR2 ,
  p_fee_type                       IN igs_fi_f_cat_fee_lbl_all.fee_type%TYPE ,
  p_fee_cal_type                   IN igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number         IN igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE ,
  p_fee_cat                        IN IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE ,
  p_s_fee_type                     IN igs_fi_fee_type_all.s_fee_type%TYPE ,
  p_s_fee_trigger_cat              IN VARCHAR2 ,
  p_rul_sequence_number            IN igs_fi_f_cat_fee_lbl_all.rul_sequence_number%TYPE ,
  p_charge_method                  IN igs_fi_f_typ_ca_inst_all.s_chg_method_type%TYPE ,
  p_location_cd                    IN VARCHAR2 ,
  p_attendance_type                IN VARCHAR2 ,
  p_attendance_mode                IN VARCHAR2 ,
  p_trace_on                       IN VARCHAR2 ,
  p_creation_dt                    IN OUT NOCOPY DATE ,
  p_charge_elements                IN OUT NOCOPY igs_fi_fee_as_all.chg_elements%TYPE ,
  p_fee_assessment                 IN OUT NOCOPY NUMBER ,
  p_charge_rate                    OUT NOCOPY IGS_FI_FEE_AS_RATE.chg_rate%TYPE,
  p_c_career                       IN igs_ps_ver_all.course_type%TYPE,
  p_elm_rng_order_name             IN igs_fi_f_typ_ca_inst_all.elm_rng_order_name%TYPE,
  p_n_max_chg_elements             IN igs_fi_fee_as_items.max_chg_elements%TYPE,
  p_n_called                       IN NUMBER) RETURN BOOLEAN;


  FUNCTION finpl_get_org_unit_cd(p_n_party_id   IN hz_parties.party_id%TYPE) RETURN VARCHAR2;

  FUNCTION get_stdnt_res_status_cd ( p_n_person_id IN igs_en_stdnt_ps_att_all.person_id%TYPE) RETURN VARCHAR2 AS
  /*************************************************************
   Created By :      Shirish Tatikonda
   Date Created By : 30-DEC-2003
   Purpose :         To derive Residency Status Code.
                     Called from finpl_get_derived_values in ACTUAL mode.
                            from finp_clc_ass_amnt in PREDICTIVE mode.
   Know limitations, enhancements or remarks
   Change History
   Who             When          What
   shtatiko        30-DEC-2003   Enh# 3167098, Created this function.
   pathipat        17-Nov-2004   Bug 4017841 - Revamped code to invoke PE function to obtain
                                 Residency Status instead of cursor c_res_status
   bannamal        01-Jul-2005   Bug#4077763 Fee Calculation Performance Enhancement.
                                 replaced the usage of local variable l_v_res_profile
                                 by global variable g_v_res_profile
  ***************************************************************/

    l_v_res_status     igs_pe_res_dtls_all.residency_class_cd%TYPE;

  BEGIN

    log_to_fnd( p_v_module => 'get_stdnt_res_status_cd',
                p_v_string => 'Entered get_stdnt_res_status_cd. Params: ' ||p_n_person_id ||
                              ',Profile Value: ' || g_v_res_profile ||
                              ', Load Calendar: '|| g_v_load_cal_type ||' - '||g_n_load_seq_num);

    IF p_n_person_id IS NULL OR g_v_load_cal_type IS NULL OR g_n_load_seq_num IS NULL THEN
      RETURN NULL;
    END IF;

    -- Check if profile 'IGS: Residency Class' is set or not.
    IF g_v_res_profile IS NULL THEN
      l_v_res_status := NULL;
    ELSE
      l_v_res_status := igs_pe_gen_001.get_res_status(p_person_id        => p_n_person_id,
                                                      p_residency_class  => g_v_res_profile,
                                                      p_cal_type         => g_v_load_cal_type,
                                                      p_sequence_number  => g_n_load_seq_num);
    END IF;

    log_to_fnd( p_v_module => 'get_stdnt_res_status_cd',
                p_v_string => 'Returning Derived Res Status Cd: ' ||  l_v_res_status);

    RETURN l_v_res_status;

  END get_stdnt_res_status_cd;

  FUNCTION get_stdnt_class_standing ( p_n_person_id          IN igs_en_stdnt_ps_att_all.person_id%TYPE,
                                      p_v_course_cd          IN igs_ps_ver_all.course_cd%TYPE,
                                      p_v_s_fee_trigger_cat  IN igs_fi_fee_type_all.s_fee_trigger_cat%TYPE ) RETURN VARCHAR2 AS
  /*************************************************************
   Created By :      Shirish Tatikonda
   Date Created By : 30-DEC-2003
   Purpose :         To derive Student Class Standing
                     Called from finpl_get_derived_values in ACTUAL mode.
                            Class Standing is not derived in PREDICTIVE mode.
   Know limitations, enhancements or remarks
   Change History
   Who             When          What
   shtatiko        30-DEC-2003   Enh# 3167098, Created this function.
  ***************************************************************/

   l_v_derived_class_standing  igs_fi_fee_as_rate.class_standing%TYPE;

  BEGIN

    IF p_n_person_id IS NULL
       OR p_v_course_cd IS NULL
       OR p_v_s_fee_trigger_cat IS NULL THEN
      RETURN NULL;
    END IF;

    log_to_fnd( p_v_module => 'get_stdnt_class_standing',
                p_v_string => 'Entered get_stdnt_class_standing. Params: ' ||p_n_person_id || ', ' || p_v_course_cd );

    -- Assessment Mode: ACTUAL
    --   Fee Calc Method: PROGRAM
    --                       -- For Institution Fee, Class Standing needn't be derived.
    --                    CAREER
    --                       -- Derive irrespective System Fee Trigger Category.
    --                    PRIMARY_CAREER
    --                       -- Determine Class Standing based on Key Program.
    -- Assessment Mode: PREDICTIVE
    --                       -- Class Standing Cannnot be derived in Predictive Mode.

    IF (g_c_fee_calc_mthd IN (g_v_program, g_v_career)) THEN
      IF (p_v_s_fee_trigger_cat <> gcst_institutn) THEN
        l_v_derived_class_standing := igs_pr_get_class_std.get_class_standing(p_person_id => p_n_person_id,
                                                                              p_course_cd => p_v_course_cd,
                                                                              p_predictive_ind => g_c_predictive_ind,
                                                                              p_effective_dt => NULL,
                                                                              p_load_cal_type => g_v_load_cal_type,
                                                                              p_load_ci_sequence_number => g_n_load_seq_num
                                                                             );
      ELSE
        IF (g_c_fee_calc_mthd=g_v_career) THEN
          l_v_derived_class_standing := igs_pr_get_class_std.get_class_standing( p_person_id => p_n_person_id,
                                                                                 p_course_cd => g_c_key_program,
                                                                                 p_predictive_ind => g_c_predictive_ind,
                                                                                 p_effective_dt => NULL,
                                                                                 p_load_cal_type => g_v_load_cal_type,
                                                                                 p_load_ci_sequence_number => g_n_load_seq_num
                                                                               );
        END IF;
      END IF;
    ELSE -- g_c_fee_calc_mthd = g_v_primary_career
      l_v_derived_class_standing := igs_pr_get_class_std.get_class_standing(p_person_id => p_n_person_id,
                                                                            p_course_cd => g_c_key_program,
                                                                            p_predictive_ind => g_c_predictive_ind,
                                                                            p_effective_dt => NULL,
                                                                            p_load_cal_type => g_v_load_cal_type,
                                                                            p_load_ci_sequence_number => g_n_load_seq_num
                                                                           );
    END IF;

    log_to_fnd( p_v_module => 'get_stdnt_class_standing',
                p_v_string => 'Derived Class Standing: ' || l_v_derived_class_standing);
    RETURN l_v_derived_class_standing;

  END get_stdnt_class_standing;

  PROCEDURE get_stdnt_unit_set_dtls ( p_n_person_id          IN igs_en_stdnt_ps_att_all.person_id%TYPE,
                                      p_v_course_cd          IN igs_ps_ver_all.course_cd%TYPE,
                                      p_v_s_fee_trigger_cat  IN igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                                      p_v_unit_set_cd        OUT NOCOPY igs_as_su_setatmpt.unit_set_cd%TYPE,
                                      p_n_unit_set_ver_num   OUT NOCOPY igs_as_su_setatmpt.us_version_number%TYPE ) AS
  /*************************************************************
   Created By :      Shirish Tatikonda
   Date Created By : 30-DEC-2003
   Purpose :         To derive Unit Set Details.
                     Called from finpl_get_derived_values in ACTUAL mode.
                            from finp_clc_ass_amnt in PREDICTIVE mode.
   Know limitations, enhancements or remarks
   Change History
   Who             When          What
   rmaddipa        05-NOV-2004   Enh# 3988455 Added statement to close the
                                              cursor cur_unit_set
   shtatiko        30-DEC-2003   Enh# 3167098, Created this function.
  ***************************************************************/

    -- Derive the Unit Set Code and Version Number, but only of category Pre Enrollment.
    CURSOR cur_unit_set (cp_person_id     hz_parties.party_id%TYPE,
                         cp_course_cd     igs_ps_ver_all.course_cd%TYPE,
                         cp_effective_dt  DATE,
                         cp_v_student_confirmed_ind  igs_as_su_setatmpt.student_confirmed_ind%TYPE,
                         cp_v_s_unit_set_cat  igs_en_unit_set_cat.s_unit_set_cat%TYPE) IS
      SELECT asu.unit_set_cd,
             asu.us_version_number
      FROM igs_as_su_setatmpt asu,
           igs_en_unit_set_all us,
           igs_en_unit_set_cat usc
      WHERE asu.person_id = cp_person_id
      AND asu.course_cd = cp_course_cd
      AND asu.student_confirmed_ind = cp_v_student_confirmed_ind
      AND TRUNC(cp_effective_dt) BETWEEN TRUNC(asu.selection_dt) AND NVL(TRUNC(asu.rqrmnts_complete_dt), NVL(TRUNC(asu.end_dt), TRUNC(cp_effective_dt)))
      AND asu.unit_set_cd = us.unit_set_cd
      AND asu.us_version_number = us.version_number
      AND us.unit_set_cat = usc.unit_set_cat
      AND usc.s_unit_set_cat = cp_v_s_unit_set_cat;

    l_v_unit_set_cd  igs_en_unit_set_all.unit_set_cd%TYPE;
    l_n_us_version_number igs_en_unit_set_all.version_number%TYPE;

  BEGIN

    p_v_unit_set_cd := NULL;
    p_n_unit_set_ver_num := NULL;

    IF p_n_person_id IS NULL
       OR p_v_course_cd IS NULL THEN
      RETURN;
    END IF;

    log_to_fnd( p_v_module => 'get_stdnt_unit_set_dtls',
                p_v_string => 'Entered get_stdnt_unit_set_dtls. Params: ' ||p_n_person_id || ', ' || p_v_course_cd ||', ' || p_v_s_fee_trigger_cat );

    IF (g_c_fee_calc_mthd <> g_v_program OR p_v_s_fee_trigger_cat = 'INSTITUTN') THEN
      log_to_fnd( p_v_module => 'get_stdnt_unit_set_dtls',
                  p_v_string => 'Returning NULL in case of Non-Program or Institution case.' );
      RETURN;
    ELSE
      OPEN cur_unit_set( p_n_person_id, p_v_course_cd, g_d_ld_census_val, 'Y', 'PRENRL_YR' );
      FETCH cur_unit_set INTO l_v_unit_set_cd,
                              l_n_us_version_number;
      IF cur_unit_set%NOTFOUND THEN
        p_v_unit_set_cd := NULL;
        p_n_unit_set_ver_num := NULL;
      ELSE
        p_v_unit_set_cd := l_v_unit_set_cd;
        p_n_unit_set_ver_num := l_n_us_version_number;
      END IF;
      CLOSE cur_unit_set;
      log_to_fnd( p_v_module => 'get_stdnt_unit_set_dtls',
                  p_v_string => 'Derived Unit Set Cd: ' || p_v_unit_set_cd || ', ' || p_n_unit_set_ver_num );
    END IF;

  END get_stdnt_unit_set_dtls;

  PROCEDURE finpl_get_unit_type_level(p_n_uoo_id              IN  igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                      p_n_unit_prg_type_level OUT NOCOPY igs_ps_unit_ver_all.unit_type_id%TYPE,
                                      p_v_unit_level          OUT NOCOPY igs_ps_unit_ver_all.unit_level%TYPE ) AS

  /*************************************************************
   Created By :      Bhaskar Annamalai
   Date Created By : 03-JUN-2005
   Purpose :         To derive Unit Program Type Level, Unit Level.

   Know limitations, enhancements or remarks

   Change History
   Who             When          What
     ***************************************************************/

    CURSOR cur_unit_type_level (cp_n_uoo_id  igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT uv.unit_type_id, uv.unit_level
    FROM igs_ps_unit_ver_all uv,
             igs_ps_unit_ofr_opt_all uoo
    WHERE uv.unit_cd = uoo.unit_cd
    AND   uv.version_number = uoo.version_number
    AND   uoo.uoo_id = cp_n_uoo_id;

    l_n_unit_prg_type_level  igs_ps_unit_ver_all.unit_type_id%TYPE;
    l_v_unit_level           igs_ps_unit_ver_all.unit_level%TYPE;

  BEGIN
   p_n_unit_prg_type_level := NULL;
   p_v_unit_level := NULL;

   log_to_fnd( p_v_module => 'finpl_get_unit_type_level',
               p_v_string => 'Entered finpl_get_unit_type_level. Params: ' ||p_n_uoo_id || ', ' || p_n_unit_prg_type_level ||', ' || p_v_unit_level );

   IF p_n_uoo_id IS NOT NULL THEN

     OPEN cur_unit_type_level( p_n_uoo_id );
     FETCH cur_unit_type_level INTO l_n_unit_prg_type_level, l_v_unit_level;
     IF cur_unit_type_level%FOUND  THEN
       p_n_unit_prg_type_level := l_n_unit_prg_type_level;
       p_v_unit_level := l_v_unit_level;
     END IF;
     CLOSE cur_unit_type_level;
     log_to_fnd( p_v_module => 'finpl_get_unit_type_level',
                 p_v_string => 'Derived  Unit Program Type Level ID: ' || p_n_unit_prg_type_level ||', Unit Level: ' || p_v_unit_level );

   END IF;

  END finpl_get_unit_type_level;

  FUNCTION finpl_get_uptl(p_n_unit_type_id IN igs_ps_unit_type_lvl.unit_type_id%TYPE) RETURN VARCHAR2 AS

  /*************************************************************
   Created By :      Priya Athipatla
   Date Created By : 02-Sep-2005
   Purpose :         To derive Unit Program Type Level (Level Code)

   Know limitations, enhancements or remarks

   Change History
   Who             When          What
   ***************************************************************/

    -- Cursor to fetch the Level Code for the Unit Program Type Level Id.
    CURSOR cur_uptl(cp_n_unit_type_id    igs_ps_unit_type_lvl.unit_type_id%TYPE) IS
      SELECT level_code
      FROM igs_ps_unit_type_lvl
      WHERE unit_type_id = cp_n_unit_type_id;

    l_v_level_code  igs_ps_unit_type_lvl.level_code%TYPE;

  BEGIN

     OPEN cur_uptl(p_n_unit_type_id);
     FETCH cur_uptl INTO l_v_level_code;
     CLOSE cur_uptl;

     RETURN l_v_level_code;

  END finpl_get_uptl;


  PROCEDURE finpl_get_unit_class_mode( p_n_uoo_id     IN  igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                       p_v_unit_class OUT NOCOPY igs_as_unit_class_all.unit_class%TYPE,
                                       p_v_unit_mode  OUT NOCOPY igs_as_unit_class_all.unit_mode%TYPE ) AS

    /*************************************************************
   Created By :      Bhaskar Annamalai
   Date Created By : 03-JUN-2005
   Purpose :         To derive Unit Class, Unit Mode.

   Know limitations, enhancements or remarks

   Change History
   Who             When          What
     ***************************************************************/
  CURSOR cur_unit_class_mode (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT uc.unit_class, uc.unit_mode
  FROM   igs_as_unit_class_all uc,
             igs_ps_unit_ofr_opt_all uoo
  WHERE uc.unit_class =  uoo.unit_class
  AND   uoo.uoo_id = p_n_uoo_id;

  l_v_unit_class  igs_as_unit_class_all.unit_class%TYPE;
  l_v_unit_mode   igs_as_unit_class_all.unit_mode%TYPE;

  BEGIN
    p_v_unit_class := NULL;
    p_v_unit_mode := NULL;

   log_to_fnd( p_v_module => 'finpl_get_unit_class_mode',
               p_v_string => 'Entered finpl_get_unit_class_mode. Params: ' ||p_n_uoo_id || ', ' || p_v_unit_class ||', ' || p_v_unit_mode );

    IF p_n_uoo_id  IS NOT NULL THEN

      OPEN cur_unit_class_mode( p_n_uoo_id );
      FETCH cur_unit_class_mode INTO l_v_unit_class, l_v_unit_mode;
      IF cur_unit_class_mode%FOUND THEN
        p_v_unit_class  := l_v_unit_class;
        p_v_unit_mode   := l_v_unit_mode;
      END IF;
      CLOSE cur_unit_class_mode;
     log_to_fnd( p_v_module => 'finpl_get_unit_class_mode',
                 p_v_string => 'Derived  Unit Class: ' || p_v_unit_class ||', Unit Mode: ' || p_v_unit_mode );

    END IF;

  END finpl_get_unit_class_mode;


  PROCEDURE finpl_sort_table ( p_input_tbl  IN OUT NOCOPY t_fee_as_items_typ,
                            p_v_elm_rng_order_name IN igs_fi_elm_rng_ords.elm_rng_order_name%TYPE ) AS
   /*************************************************************
   Created By :      Bhaskar Annamalai
   Date Created By : 20-JUN-2005
   Purpose :         To Sort the Pl/sql table.

   Know limitations, enhancements or remarks

   Change History
   Who             When          What
  ***************************************************************/

   j NUMBER;
   l_rec_index_row r_s_fee_as_items_typ;
   l_n_order_num  igs_fi_er_ord_dtls.order_num%TYPE;
   l_v_order_attr_val  igs_fi_er_ord_dtls.order_attr_value%TYPE;

   CURSOR cur_order_num (cp_n_unit_type_id   igs_fi_fee_as_items.unit_type_id%TYPE) IS
     SELECT order_num, order_attr_value
     FROM igs_fi_er_ord_dtls
     WHERE elm_rng_order_name = p_v_elm_rng_order_name
     AND order_attr_value = TO_CHAR(cp_n_unit_type_id);

  BEGIN
    -- Populate the value of UNIT_TYPE_ID in the PL/SQL table
    FOR i IN 1..p_input_tbl.COUNT LOOP
      l_n_order_num := NULL;
      l_v_order_attr_val := NULL;
      IF (p_input_tbl(i).unit_type_id  IS NOT NULL) THEN
        OPEN cur_order_num (p_input_tbl(i).unit_type_id);
        FETCH cur_order_num INTO l_n_order_num, l_v_order_attr_val;
        CLOSE cur_order_num;
        p_input_tbl(i).element_order := l_n_order_num;
      ELSE
        p_input_tbl(i).element_order := NULL;
      END IF;
    END LOOP;

    -- Sort the table
    FOR i IN 1..p_input_tbl.COUNT LOOP
       l_rec_index_row := p_input_tbl(i);
       j := i;
       WHILE ((j > 1) AND (p_input_tbl(j-1).element_order > l_rec_index_row.element_order) )
       LOOP
           p_input_tbl(j) := p_input_tbl(j-1);
           j := j-1;
       END LOOP;
       p_input_tbl(j) := l_rec_index_row;
    END LOOP;
  EXCEPTION
      WHEN OTHERS THEN
        log_to_fnd( p_v_module => 'finpl_sort_table',
                    p_v_string => 'From WHEN OTHERS. ' || SUBSTR(sqlerrm,1,500));
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','finpl_sort_table -'||SUBSTR(sqlerrm,1,500));
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
  END finpl_sort_table;


  PROCEDURE finpl_retn_sort_table ( p_input_tbl1  IN OUT NOCOPY t_fee_as_items_typ,
                                    p_input_tbl2  IN OUT NOCOPY t_unit_status,
                                    p_input_tbl3  IN OUT NOCOPY t_date ) AS

   /*************************************************************
   Created By :      Bhaskar Annamalai
   Date Created By : 23-Aug-2005
   Purpose :         To Sort the Pl/sql table used in Retention.

   Know limitations, enhancements or remarks

   Change History
   Who             When          What
  ***************************************************************/
   j NUMBER;
   l_rec_index_row r_s_fee_as_items_typ;
   l_d_temp  DATE;
   l_d_status VARCHAR2(1);

  BEGIN

    FOR i IN 1..p_input_tbl3.COUNT LOOP
       l_rec_index_row := p_input_tbl1(i);
       l_d_temp := p_input_tbl3(i);
       l_d_status := p_input_tbl2(i);

       j := i;
       WHILE ((j > 1) AND (p_input_tbl3(j-1) > l_d_temp) )
       LOOP
         p_input_tbl3(j) := p_input_tbl3(j-1);
         p_input_tbl2(j) := p_input_tbl2(j-1);
         p_input_tbl1(j) := p_input_tbl1(j-1);
         j := j-1;
       END LOOP;
       p_input_tbl1(j) := l_rec_index_row;
       p_input_tbl2(j) := l_d_status;
       p_input_tbl3(j) := l_d_temp;
    END LOOP;

  EXCEPTION
      WHEN OTHERS THEN
        log_to_fnd( p_v_module => 'finpl_retn_sort_table',
                    p_v_string => 'From WHEN OTHERS. ' || SUBSTR(sqlerrm,1,500));
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','finpl_retn_sort_table -'||SUBSTR(sqlerrm,1,500));
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
  END finpl_retn_sort_table;


  PROCEDURE finpl_prc_teach_prd_retn_levl(p_person_id                 igs_fi_fee_as_all.person_id%TYPE,
                                           p_fee_cat                   igs_fi_fee_as_all.fee_cat%TYPE,
                                           p_fee_type                  igs_fi_fee_as_all.fee_type%TYPE,
                                           p_fee_cal_type              igs_fi_fee_as_all.fee_cal_type%TYPE,
                                           p_fee_ci_sequence_number    igs_fi_fee_as_all.fee_ci_sequence_number%TYPE,
                                           p_course_cd                 igs_fi_fee_as_all.course_cd%TYPE,
                                           p_n_uoo_id                  igs_fi_fai_dtls.uoo_id%TYPE,
                                           p_trace_on                  VARCHAR2,
                                           p_d_gl_date                 igs_fi_invln_int_all.gl_date%TYPE,
                                           p_n_diff_amount             NUMBER,
                                           p_v_retention_level         igs_fi_f_typ_ca_inst_all.retention_level_code%TYPE,
                                           p_v_cmp_withdr_ret          igs_fi_f_typ_ca_inst_all.complete_ret_flag%TYPE,
                                           p_v_fee_type_desc           igs_fi_fee_type_all.description%TYPE,
                                           p_v_fee_trig_cat            igs_fi_fee_type_all.s_fee_trigger_cat%TYPE
                                          ) AS
 /*************************************************************
 Created By :      Bhaskar Annamalai
 Date Created By : 20-JUN-2005
 Purpose :  For processing teaching period level retention.

 Know limitations, enhancements or remarks

 Change History
 Who             When          What
 ***************************************************************/
  -- Cursor to obtain the Unit Section details
  -- Retention not applicable for Unit Sections with status Invalid or Duplicate
  CURSOR cur_usec_dtls(cp_n_person_id     igs_en_su_attempt_all.person_id%TYPE,
                       cp_v_course_cd     igs_en_su_attempt_all.course_cd%TYPE,
                       cp_n_uoo_id        igs_en_su_attempt_all.uoo_id%TYPE) IS
    SELECT *
    FROM igs_en_su_attempt_all
    WHERE person_id = cp_n_person_id
    AND course_cd = cp_v_course_cd
    AND uoo_id = cp_n_uoo_id
    ORDER BY  discontinued_dt;

  -- Cursor to determine if a given Unit Section is Non-Standard
  CURSOR cur_non_std_usec(cp_n_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT non_std_usec_ind
    FROM igs_ps_unit_ofr_opt_all
    WHERE uoo_id = cp_n_uoo_id;

  l_v_load_incurred       VARCHAR2(1) := NULL;
  l_v_non_std_usec        VARCHAR2(1) := NULL;
  l_n_retention_amount    NUMBER := 0.0;

  BEGIN

    -- If a downward adjustment has happened, then Retention could be applicable.
    -- Determine if load is incurred
    FOR rec_usec_dtls IN cur_usec_dtls(p_person_id,
                                       p_course_cd,
                                       p_n_uoo_id)
    LOOP
       IF (rec_usec_dtls.unit_attempt_status IN ('INVALID','DUPLICATE')) THEN
           log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                       p_v_string => 'Teach Period level retention : Unit Status in Invalid or Duplicate, No retention'||
                                     '  Uoo Id: '|| p_n_uoo_id);
           RETURN;
       END IF;

       log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                   p_v_string => 'Teach Period level retention : Checking if load is incurred');
       -- Determine if the Unit Section incurs load
       l_v_load_incurred := igs_en_prc_load.enrp_get_load_apply(p_teach_cal_type              => rec_usec_dtls.cal_type,
                                                                   p_teach_sequence_number       => rec_usec_dtls.ci_sequence_number,
                                                                   p_discontinued_dt             => rec_usec_dtls.discontinued_dt,
                                                                   p_administrative_unit_status  => rec_usec_dtls.administrative_unit_status,
                                                                   p_unit_attempt_status         => rec_usec_dtls.unit_attempt_status,
                                                                   p_no_assessment_ind           => rec_usec_dtls.no_assessment_ind,
                                                                   p_load_cal_type               => g_v_load_cal_type,
                                                                   p_load_sequence_number        => g_n_load_seq_num,
                                                                   p_include_audit               => rec_usec_dtls.no_assessment_ind);
       -- If the Unit Section incurs load, then retention is not applicable.
       IF (l_v_load_incurred = 'Y') THEN
           log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                       p_v_string => 'Teach Period level retention : Load incurred for Usec, so skip Unit Section'||
                                     '  Uoo Id: '|| p_n_uoo_id);
           RETURN;
       END IF;

       log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                   p_v_string => 'Teach Period level retention : Load not incurred for Usec, continue for'||
                                 ' Uoo Id: '|| p_n_uoo_id);

       -- Determine if Unit Section is Non-Standard or not.
       OPEN cur_non_std_usec(p_n_uoo_id);
       FETCH cur_non_std_usec INTO l_v_non_std_usec;
       CLOSE cur_non_std_usec;

       IF (l_v_non_std_usec = 'Y') THEN
           -- If the Unit Section is Non-Standard, invoked function to determine Retention Amount
           log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                       p_v_string => 'Non Standard USEC - Invoking igs_fi_gen_008.get_ns_usec_retention');
           l_n_retention_amount := igs_fi_gen_008.get_ns_usec_retention(p_n_uoo_id  => p_n_uoo_id,
                                                                           p_v_fee_type       => p_fee_type,
                                                                           p_d_effective_date => rec_usec_dtls.discontinued_dt,
                                                                           p_n_diff_amount    => p_n_diff_amount);
           log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                       p_v_string => 'Teach Period Retention - Retention Amount Derived: ' || l_n_retention_amount);

           IF NVL(l_n_retention_amount, 0.0) > 0.0 THEN
                   log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                               p_v_string => 'Teach Period Retention - Retention Amount > 0, invoking create_retention_charge.');
                   IF (p_trace_on = 'Y') THEN
                      fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'RET_LEVEL') || ': ' || igs_fi_gen_gl.get_lkp_meaning('IGS_FI_RET_LEVEL', p_v_retention_level));
                      fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'WITHDWR_RET') || ': ' || igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_v_cmp_withdr_ret));
                   END IF;

                   create_retention_charge( p_n_person_id               => p_person_id,
                                            p_v_course_cd               => p_course_cd,
                                            p_v_fee_cal_type            => p_fee_cal_type,
                                            p_n_fee_ci_sequence_number  => p_fee_ci_sequence_number,
                                            p_v_fee_type                => p_fee_type,
                                            p_v_fee_cat                 => p_fee_cat,
                                            p_d_gl_date                 => TRUNC(p_d_gl_date),
                                            p_n_uoo_id                  => p_n_uoo_id,
                                            p_n_amount                  => l_n_retention_amount,
                                            p_v_fee_type_desc           => p_v_fee_type_desc,
                                            p_v_fee_trig_cat            => p_v_fee_trig_cat ,
                                            p_trace_on                  => p_trace_on);
            END IF;  -- End if for l_n_retention_amount > 0.0
       ELSE
            -- If Unit Section is NOT Non-Standard, then invoke Teaching Period level retention
            log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                        p_v_string => 'Not NS - Apply Teaching Period Retention - Invoking igs_fi_gen_008.get_teach_retention');
            l_n_retention_amount := igs_fi_gen_008.get_teach_retention(p_v_fee_cal_type             => p_fee_cal_type,
                                                                         p_n_fee_ci_sequence_number   => p_fee_ci_sequence_number,
                                                                         p_v_fee_type                 => p_fee_type,
                                                                         p_v_teach_cal_type           => rec_usec_dtls.cal_type,
                                                                         p_n_teach_ci_sequence_number => rec_usec_dtls.ci_sequence_number,
                                                                         p_d_effective_date           => rec_usec_dtls.discontinued_dt,
                                                                         p_n_diff_amount              => p_n_diff_amount);
            log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                        p_v_string => 'Teach Period Retention - Retention Amount Derived: ' || l_n_retention_amount);

            IF NVL(l_n_retention_amount, 0.0) > 0.0 THEN
                   log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                               p_v_string => 'Teach Period Retention - Retention Amount > 0, invoking create_retention_charge.');
                   IF (p_trace_on = 'Y') THEN
                      fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'RET_LEVEL') || ': ' || igs_fi_gen_gl.get_lkp_meaning('IGS_FI_RET_LEVEL', p_v_retention_level));
                      fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'WITHDWR_RET') || ': ' || igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_v_cmp_withdr_ret));
                   END IF;

                   create_retention_charge( p_n_person_id               => p_person_id,
                                            p_v_course_cd               => p_course_cd,
                                            p_v_fee_cal_type            => p_fee_cal_type,
                                            p_n_fee_ci_sequence_number  => p_fee_ci_sequence_number,
                                            p_v_fee_type                => p_fee_type,
                                            p_v_fee_cat                 => p_fee_cat,
                                            p_d_gl_date                 => TRUNC(p_d_gl_date),
                                            p_n_uoo_id                  => p_n_uoo_id,
                                            p_n_amount                  => l_n_retention_amount,
                                            p_v_fee_type_desc           => p_v_fee_type_desc,
                                            p_v_fee_trig_cat            => p_v_fee_trig_cat,
                                            p_trace_on                  => p_trace_on);
            END IF;  -- End if for l_n_retention_amount > 0.0
       END IF;  -- End if for l_v_non_std_usec = 'Y'
    END LOOP;

  EXCEPTION
      WHEN Others THEN
        log_to_fnd( p_v_module => 'finpl_prc_teach_prd_retn_levl',
                    p_v_string => 'From Exception Handler of When Others.');
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_PRC_TEACH_PRD_RETN_LEVL-'||SUBSTR(SQLERRM,1,500));
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END finpl_prc_teach_prd_retn_levl;

  FUNCTION finpl_clc_sua_cp( p_v_unit_cd                     IN igs_en_su_attempt_all.unit_cd%TYPE,
                             p_n_version_number              IN igs_en_su_attempt_all.version_number%TYPE,
                             p_v_cal_type                    IN igs_en_su_attempt_all.cal_type%TYPE,
                             p_n_ci_sequence_number          IN igs_en_su_attempt_all.ci_sequence_number%TYPE,
                             p_v_load_cal_type               IN igs_en_su_attempt_all.cal_type%TYPE,
                             p_n_load_ci_sequence_number     IN igs_en_su_attempt_all.ci_sequence_number%TYPE,
                             p_n_override_enrolled_cp        IN igs_en_su_attempt_all.override_enrolled_cp%TYPE,
                             p_n_override_eftsu              IN igs_en_su_attempt_all.override_eftsu%TYPE,
                             p_n_uoo_id                      IN igs_en_su_attempt_all.uoo_id%TYPE,
                             p_v_include_audit               IN igs_en_su_attempt_all.no_assessment_ind%TYPE ) RETURN NUMBER AS
    /*************************************************************
     Created By      : Shirish Tatikonda
     Date Created By : 21-JUL-2004
     Purpose         : This function returns Enrolled/Audit/Billable Credit points.
                       This is invoked in finpl_clc_chg_mthd_elements, in cursor c_sua_load.
     Know limitations, enhancements or remarks
     Change History
     Who             When          What
     shtatiko        21-JUL-2004   Enh# 3741400, Created this function.
    ***************************************************************/
    l_n_eftsu        igs_fi_fee_as_items.eftsu%TYPE;
    l_n_enrolled_cp  igs_fi_fee_as_items.credit_points%TYPE;
    l_n_billing_cp   igs_fi_fee_as_items.credit_points%TYPE;
    l_n_audit_cp     igs_fi_fee_as_items.credit_points%TYPE;
    l_n_ret_cp       igs_fi_fee_as_items.credit_points%TYPE;
  BEGIN

    -- Invoke EN API to calculate Enrolled/Billable/Audit Credit Points
    l_n_ret_cp := igs_en_prc_load.enrp_clc_sua_load (
                         p_unit_cd                 => p_v_unit_cd,
                         p_version_number          => p_n_version_number,
                         p_cal_type                => p_v_cal_type,
                         p_ci_sequence_number      => p_n_ci_sequence_number,
                         p_load_cal_type           => p_v_load_cal_type,
                         p_load_ci_sequence_number => p_n_load_ci_sequence_number,
                         p_override_enrolled_cp    => p_n_override_enrolled_cp,
                         p_override_eftsu          => p_n_override_eftsu,
                         p_return_eftsu            => l_n_eftsu,                -- OUT
                         p_uoo_id                  => p_n_uoo_id,
                         p_include_as_audit        => p_v_include_audit,
                         p_billing_cp              => l_n_billing_cp,           -- OUT
                         p_audit_cp                => l_n_audit_cp,             -- OUT
                         p_enrolled_cp             => l_n_enrolled_cp);         -- OUT

    IF p_v_include_audit = 'Y' THEN
      RETURN NVL(l_n_audit_cp, 0);
    ELSE
      RETURN NVL(NVL(l_n_billing_cp, l_n_enrolled_cp), 0);
    END IF;

  END finpl_clc_sua_cp;

-----------------------------------------------------------------------------------
FUNCTION finpl_get_derived_am_at (
        p_person_id                     hz_parties.party_id%TYPE,
        p_course_cd                     IGS_PS_COURSE.course_cd%TYPE,
        p_effective_dt                  DATE,
        p_fee_cal_type                  igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
        p_fee_ci_sequence_number        igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE,
        p_fee_type                      igs_fi_f_cat_fee_lbl_all.fee_type%TYPE,
        p_s_fee_trigger_cat             igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
        p_trace_on                      VARCHAR2,
        p_c_career                      IN      igs_ps_ver_all.course_type%TYPE,
        p_derived_attendance_type       OUT NOCOPY      igs_fi_fee_as_rate.attendance_type%TYPE,
        p_derived_att_mode              OUT NOCOPY      igs_en_atd_mode_all.govt_attendance_mode%TYPE) RETURN BOOLEAN  AS
/*************************************************************
 Created By : abshriva
 Date Created By : 1-Jun-2006
 Purpose : Bug 5104329:Getting derived values of attendance mode and type.
 Know limitations, enhancements or remarks
 Change History
 Who             When          What
*************************************************************/

BEGIN
  DECLARE
    cst_on          CONSTANT        VARCHAR2(10) := 'ON';
    cst_off         CONSTANT        VARCHAR2(10) := 'OFF';
    cst_composite   CONSTANT        VARCHAR2(10) := 'COMPOSITE';
    v_derived_attendance_type       igs_en_atd_type_all.attendance_type%TYPE;
    v_derived_attendance_mode       VARCHAR2(10);  -- Used only in case of Derived Profile. Holds values On, Off, and Composite.
    v_derived_govt_att_mode         igs_en_atd_mode_all.govt_attendance_mode%TYPE;
    v_derived_prog_att_mode         igs_en_atd_mode_all.attendance_mode%TYPE;  -- Used in Nominated Profile. Holds value of AM associated at Prog Attempt.
    v_on_att_mode                   BOOLEAN := FALSE;
    v_off_att_mode                  BOOLEAN := FALSE;
    v_composite_att_mode            BOOLEAN := FALSE;
    TYPE derived_values_rec IS RECORD ( course_cd      igs_ps_ver_all.course_cd%TYPE,
                                        course_type    igs_ps_ver_all.course_type%TYPE);
    TYPE derived_values_ref IS REF CURSOR RETURN derived_values_rec;
    c_scafv    derived_values_ref;
    l_c_scafv  c_scafv%ROWTYPE;

    -- record type variable defined for geeting the attendance type and govt attendance mode when the
    -- nominated values are used
    TYPE l_der_nom_rec IS RECORD ( attendance_type  igs_en_atd_type_all.attendance_type%TYPE,
                                   govt_att_mode    igs_en_atd_mode_all.govt_attendance_mode%TYPE,
                                   prog_att_mode    igs_en_atd_mode_all.attendance_mode%TYPE);
    TYPE l_der_nom_ref IS REF CURSOR RETURN l_der_nom_rec;
    l_v_prg_liabale      VARCHAR2(10);
    c_att_md_ty    l_der_nom_ref;
    l_c_att_md_ty  c_att_md_ty%ROWTYPE;
    l_n_cr_points        igs_en_su_attempt_all.override_achievable_cp%TYPE;
    l_n_fte              igs_en_su_attempt_all.override_achievable_cp%TYPE;
CURSOR c_sca_psv ( cp_v_lookup_type igs_lookups_view.lookup_type%TYPE,
                           cp_v_fee_ass_ind igs_lookups_view.fee_ass_ind%TYPE ) IS
          SELECT  spat.person_id,
                  spat.program_cd,
                  spat.program_version,
                  spat.fee_cat,
                  sca.commencement_dt,
                  sca.discontinued_dt,
                  sca.adm_admission_appl_number,
                  sca.adm_nominated_course_cd,
                  sca.adm_sequence_number,
                  sca.cal_type,
                  spat.location_cd,
                  spat.attendance_mode,
                  spat.attendance_type,
                  ps.course_type
          FROM    igs_en_spa_terms spat,
                  igs_en_stdnt_ps_att_all sca,
                  igs_ps_ver_all ps,
                  igs_lookups_view lkps
          WHERE   spat.person_id = p_person_id
          AND     spat.person_id = sca.person_id
          AND     spat.program_cd = sca.course_cd
          AND     spat.program_version = sca.version_number
          AND     spat.term_cal_type = g_v_load_cal_type
          AND     spat.term_sequence_number = g_n_load_seq_num
          AND     spat.program_cd = ps.course_cd
          AND     spat.program_version = ps.version_number
          AND     lkps.lookup_type = cp_v_lookup_type
          AND     sca.course_attempt_status = lkps.lookup_code
          AND     lkps.fee_ass_ind = cp_v_fee_ass_ind;


  BEGIN
    log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                p_v_string => 'Entered finpl_get_derived_am_at. Parameters are: ' ||
                              p_person_id || ', ' || p_course_cd || ', ' || TO_CHAR(p_effective_dt, 'DD-MON-YYYY')
                              || ', ' || p_fee_cal_type || ', ' || p_fee_ci_sequence_number || ', ' || p_fee_type
                               || ', ' || p_s_fee_trigger_cat || ', ' || p_trace_on || ', ' || p_c_career );
    IF (p_trace_on = 'Y') THEN
      fnd_file.new_line(fnd_file.log);
    END IF;
    -- Obtain System Fee Type for the fee_type provided

    log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                p_v_string => 'Profile IGS_FI_NOM_DER_VALUES value: ' || g_v_att_profile );
    -- Get the derived attendance type
    ----------------------------------

    -- Profile Value is NOMINATED:
    --       If Institution Fee OR Primary Career Calculation Method
    --          Get AT and AM from Key Program
    --       Else
    --          Get AT and AM from Program in context
    -- Profile Value is DERIVED
    --       Call EN APIs to get AT.

    IF (g_v_att_profile = gcst_nominated) THEN --Enh# 2162747, SFCR06

        IF (p_s_fee_trigger_cat = 'INSTITUTN' OR g_c_fee_calc_mthd = g_v_primary_career) THEN  -- For Institutional Level
            OPEN c_att_md_ty FOR SELECT a.attendance_type,
                                        b.govt_attendance_mode,
                                        a.attendance_mode
                                 FROM   igs_en_spa_terms a,
                                        igs_en_atd_mode_all b
                                 WHERE  a.person_id = p_person_id
                                 AND    a.term_cal_type = g_v_load_cal_type
                                 AND    a.term_sequence_number = g_n_load_seq_num
                                 AND    b.attendance_mode = a.attendance_mode
                                 AND    a.key_program_flag = 'Y';
        ELSE -- For Other than Institutional Level
            OPEN c_att_md_ty FOR SELECT a.attendance_type,
                                        b.govt_attendance_mode,
                                        a.attendance_mode
                                 FROM   igs_en_spa_terms a,
                                        igs_en_atd_mode_all b
                                 WHERE  a.person_id = p_person_id
                                 AND    a.program_cd = p_course_cd
                                 AND    a.term_cal_type = g_v_load_cal_type
                                 AND    a.term_sequence_number = g_n_load_seq_num
                                 AND    b.attendance_mode = a.attendance_mode;
        END IF;

      FETCH c_att_md_ty INTO l_c_att_md_ty;
      -- Same Attendance Mode and Attendance Type variables are used to avoid duplicate declaring of the local variables
      v_derived_attendance_type := l_c_att_md_ty.attendance_type;
      v_derived_govt_att_mode   := l_c_att_md_ty.govt_att_mode;
      v_derived_prog_att_mode   := l_c_att_md_ty.prog_att_mode;
      CLOSE c_att_md_ty;

      log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                  p_v_string => 'Nominated Profile. Derived Att Type: ' || v_derived_attendance_type ||
                                ', Govt. Att Mode: ' || v_derived_govt_att_mode ||
                                ', Prog Att Mode: ' || v_derived_prog_att_mode);

    ELSE
      log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                  p_v_string => 'Profile value is Derived. Deriving Attendance Type.');
      -- Get Attendance Type by calling EN API.
      IF p_s_fee_trigger_cat = gcst_institutn OR
         g_c_fee_calc_mthd = g_v_primary_career THEN
        igs_en_prc_load.enrp_get_inst_latt_fte ( p_person_id        => p_person_id,
                                                 p_load_cal_type    => g_v_load_cal_type,
                                                 p_load_seq_number  => g_n_load_seq_num,
                                                 p_attendance       => v_derived_attendance_type,
                                                 p_credit_points    => l_n_cr_points,
                                                 p_fte              => l_n_fte );

      ELSE /* p_s_fee_trigger_cat <> gcst_institutn AND g_c_fee_calc_mthd <> g_v_primary_career */
        v_derived_attendance_type := igs_en_prc_load.enrp_get_prg_att_type ( p_person_id        => p_person_id,
                                                                             p_course_cd        => p_course_cd,
                                                                             p_cal_type         => g_v_load_cal_type,
                                                                             p_sequence_number  => g_n_load_seq_num );
      END IF;
    END IF;

    IF (v_derived_attendance_type IS NULL) THEN
      IF (p_trace_on = 'Y') THEN
        fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTTYPE');
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
    END IF;

    log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                p_v_string => 'Deriving Attendance Mode...');
    -- Get the derived attendance mode
    ----------------------------------
    IF (g_v_att_profile = gcst_nominated) THEN
      IF v_derived_govt_att_mode IS NULL AND v_derived_prog_att_mode IS NULL THEN
        IF (p_trace_on = 'Y') THEN
          -- Trace Entry
           fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTMODE');
           fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;
      END IF;
    ELSE

      -- Processing for PRIMARY_CAREER is same for Institution and Non-Institution Fees.
      IF (p_s_fee_trigger_cat = gcst_institutn AND g_c_fee_calc_mthd <> g_v_primary_career) THEN

        log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                    p_v_string => 'Looping through Liable Programs in Institution case. (table g_inst_liable_progs_tbl) ');
        FOR l_sca_psv IN c_sca_psv('CRS_ATTEMPT_STATUS', 'Y') LOOP
          l_v_prg_liabale := igs_fi_gen_001.check_stdnt_prg_att_liable (
                                       p_n_person_id              => l_sca_psv.person_id,
                                       p_v_course_cd              => l_sca_psv.program_cd,
                                       p_n_course_version         => l_sca_psv.program_version,
                                       p_v_fee_cat                => l_sca_psv.fee_cat,
                                       p_v_fee_type               => p_fee_type,
                                       p_v_s_fee_trigger_cat      => p_s_fee_trigger_cat,
                                       p_v_fee_cal_type           => p_fee_cal_type,
                                       p_n_fee_ci_seq_number      => p_fee_ci_sequence_number,
                                       p_n_adm_appl_number        => l_sca_psv.adm_admission_appl_number,
                                       p_v_adm_nom_course_cd      => l_sca_psv.adm_nominated_course_cd,
                                       p_n_adm_seq_number         => l_sca_psv.adm_sequence_number,
                                       p_d_commencement_dt        => l_sca_psv.commencement_dt,
                                       p_d_disc_dt                => l_sca_psv.discontinued_dt,
                                       p_v_cal_type               => l_sca_psv.cal_type,
                                       p_v_location_cd            => l_sca_psv.location_cd,
                                       p_v_attendance_mode        => l_sca_psv.attendance_mode,
                                       p_v_attendance_type        => l_sca_psv.attendance_type ) ;
          IF l_v_prg_liabale = 'TRUE' THEN
            v_derived_attendance_mode := igs_en_gen_006.enrp_get_sca_am(p_person_id,
                                                                        l_sca_psv.program_cd,
                                                                        g_v_load_cal_type,
                                                                        g_n_load_seq_num);
            log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                        p_v_string => 'Attendance Mode derived for course ' || l_sca_psv.program_cd || ' is ' || v_derived_attendance_mode);
            IF (v_derived_attendance_mode = cst_on) THEN
              v_on_att_mode := TRUE;
            ELSIF (v_derived_attendance_mode = cst_off) THEN
              v_off_att_mode := TRUE;
            ELSIF (v_derived_attendance_mode = cst_composite) THEN
              v_composite_att_mode := TRUE;
            END IF;
          END IF;
        END LOOP;
        -- Determine the govt attendance mode from the combination
        -- of derived values across the student program attempts
        v_derived_prog_att_mode := NULL; -- This variable holds value only in case of Nominated Profile
        IF (v_on_att_mode = TRUE AND
          v_off_att_mode = FALSE AND
          v_composite_att_mode = FALSE) THEN
          v_derived_govt_att_mode := 1;
        ELSIF (v_on_att_mode = FALSE AND
          v_off_att_mode = TRUE AND
          v_composite_att_mode = FALSE) THEN
          v_derived_govt_att_mode := 2;
        ELSIF ((v_on_att_mode = TRUE AND
          v_off_att_mode = TRUE) OR
          v_composite_att_mode = TRUE) THEN
          v_derived_govt_att_mode := 3;
        ELSE
          IF (p_trace_on = 'Y') THEN
            -- Trace Entry
            fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTMODE');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
          END IF;
        END IF;
        log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                    p_v_string => 'Institution Case: Attendance Mode: ' || v_derived_govt_att_mode);


      ELSE /* p_s_fee_trigger_cat <> gcst_institutn OR g_c_fee_calc_mthd = 'PRIMARY_CAREER' */

        IF ( g_c_fee_calc_mthd IN (g_v_program, g_v_career)) THEN

          -- PROGRAM: Derive AM from the course in context
          -- CAREER : Derive AM for the Primary Program of career i.e., course in context

            v_derived_attendance_mode := igs_en_gen_006.enrp_get_sca_am(p_person_id,
                                                                        p_course_cd,
                                                                        g_v_load_cal_type,
                                                                        g_n_load_seq_num);

          v_derived_prog_att_mode := NULL; -- This variable holds value only in case of Nominated Profile
          IF (v_derived_attendance_mode = cst_on) THEN
            v_derived_govt_att_mode := 1;
          ELSIF (v_derived_attendance_mode = cst_off) THEN
            v_derived_govt_att_mode := 2;
          ELSIF (v_derived_attendance_mode = cst_composite) THEN
            v_derived_govt_att_mode := 3;
          ELSE
            IF (p_trace_on = 'Y') THEN
              -- Trace Entry
              fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTMODE');
              fnd_file.put_line (fnd_file.log, fnd_message.get);
            END IF;
          END IF;
          log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                      p_v_string => 'Non-Institution Case, PROGRAM/CAREER: Attendance Mode: ' || v_derived_govt_att_mode);

        ELSIF ( g_c_fee_calc_mthd =g_v_primary_career) THEN
          -- Derive AM from Key Program of the person for the given term.

          OPEN c_scafv FOR SELECT program_cd course_cd,
                                    NULL
                             FROM   igs_en_spa_terms
                             WHERE  person_id = p_person_id
                             AND    term_cal_type = g_v_load_cal_type
                             AND    term_sequence_number = g_n_load_seq_num;

          LOOP
          FETCH c_scafv INTO l_c_scafv;
          EXIT WHEN c_scafv%NOTFOUND;

            v_derived_attendance_mode := igs_en_gen_006.enrp_get_sca_am( p_person_id,
                                                                           l_c_scafv.course_cd,
                                                                           g_v_load_cal_type,
                                                                           g_n_load_seq_num);

            IF (v_derived_attendance_mode = cst_on) THEN
                v_on_att_mode := TRUE;
            ELSIF (v_derived_attendance_mode = cst_off) THEN
              v_off_att_mode := TRUE;
            ELSIF (v_derived_attendance_mode = cst_composite) THEN
              v_composite_att_mode := TRUE;
            END IF;

          END LOOP;
          CLOSE c_scafv;

          -- Determine the govt attendance mode from the combination
          -- of derived values across the load periods
          v_derived_prog_att_mode := NULL; -- This variable holds value only in case of Nominated Profile
          IF (v_on_att_mode = TRUE AND
            v_off_att_mode = FALSE AND
            v_composite_att_mode = FALSE) THEN
            v_derived_govt_att_mode := 1;
          ELSIF (v_on_att_mode = FALSE AND
            v_off_att_mode = TRUE AND
            v_composite_att_mode = FALSE) THEN
            v_derived_govt_att_mode := 2;
          ELSIF ((v_on_att_mode = TRUE AND
            v_off_att_mode = TRUE) OR
            v_composite_att_mode = TRUE) THEN
            v_derived_govt_att_mode := 3;
          ELSE
            IF (p_trace_on = 'Y') THEN
              -- Trace Entry
              fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTMODE');
              fnd_file.put_line (fnd_file.log, fnd_message.get);
            END IF;
          END IF;
          log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                      p_v_string => 'Non-Institution Case, PRIMARY_CAREER: Attendance Mode: ' || v_derived_govt_att_mode);
        END IF; /* g_c_fee_calc_mthd */
      END IF;
    END IF; /* Nominated or Derived */

    -- Message about derivation of Attendance type and mode needs to be shown only if both
    -- have been derived.
    IF (v_derived_attendance_type IS NOT NULL) AND (v_derived_govt_att_mode IS NOT NULL) THEN
      IF (p_trace_on = 'Y') THEN
        fnd_message.set_name ( 'IGS', 'IGS_FI_ATTTYPE_GOVT_ATTMODE');
        fnd_message.set_token('ATT_TYPE', v_derived_attendance_type);
        fnd_file.put_line(fnd_file.log, fnd_message.get );
        fnd_message.set_name('IGS', 'IGS_FI_DER_ATT_TYPE_GOVT_MODE');
        fnd_message.set_token('ATT_MODE', v_derived_govt_att_mode);
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
    END IF;

    p_derived_attendance_type := v_derived_attendance_type;
    IF (g_v_att_profile = gcst_nominated) THEN
      p_derived_att_mode := v_derived_prog_att_mode;
    ELSE
      p_derived_att_mode := v_derived_govt_att_mode;
    END IF;
    log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
                p_v_string => 'End of finpl_get_derived_am_at. Out: Att Type: '|| p_derived_attendance_type
                              || ', Govt Att Mode: ' || p_derived_att_mode );
    RETURN TRUE;

  END;
EXCEPTION
WHEN OTHERS THEN
  log_to_fnd( p_v_module => 'finpl_get_derived_am_at',
              p_v_string => 'From Exception Handler of When Others.');
  fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
  fnd_message.set_token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_GET_DERIVED_AM_AT-'||SUBSTR(sqlerrm,1,500));
  igs_ge_msg_stack.add;
  app_exception.raise_exception;
END finpl_get_derived_am_at;
-----------------------------------------------------------------------------------

FUNCTION finp_clc_ass_amnt( p_effective_dt             IN DATE ,
                        p_person_id                    IN hz_parties.party_id%TYPE ,
                        p_course_cd                    IN igs_en_stdnt_ps_att_all.course_cd%TYPE ,
                        p_course_version_number        IN igs_en_stdnt_ps_att_all.version_number%TYPE ,
                        p_course_attempt_status        IN VARCHAR2 ,
                        p_fee_type                     IN igs_fi_f_cat_fee_lbl_all.fee_type%TYPE ,
                        p_fee_cal_type                 IN igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE ,
                        p_fee_ci_sequence_number       IN igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE ,
                        p_fee_cat                      IN IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE ,
                        p_s_fee_type                   IN igs_fi_fee_type_all.s_fee_type%TYPE ,
                        p_s_fee_trigger_cat            IN VARCHAR2 ,
                        p_rul_sequence_number          IN igs_fi_f_cat_fee_lbl_all.rul_sequence_number%TYPE ,
                        p_charge_method                IN igs_fi_f_typ_ca_inst_all.s_chg_method_type%TYPE ,
                        p_location_cd                  IN VARCHAR2 ,
                        p_attendance_type              IN VARCHAR2 ,
                        p_attendance_mode              IN VARCHAR2 ,
                        p_trace_on                     IN VARCHAR2 ,
                        p_creation_dt                  IN OUT NOCOPY DATE ,
                        p_charge_elements              IN OUT NOCOPY igs_fi_fee_as_all.chg_elements%TYPE ,
                        p_fee_assessment               IN OUT NOCOPY NUMBER,
                        p_charge_rate                  OUT NOCOPY IGS_FI_FEE_AS_RATE.chg_rate%TYPE,
                        p_c_career                     IN igs_ps_ver_all.course_type%TYPE,
                        p_elm_rng_order_name           IN igs_fi_f_typ_ca_inst_all.elm_rng_order_name%TYPE,
                        p_n_max_chg_elements           IN igs_fi_fee_as_items.max_chg_elements%TYPE,
                        p_n_called                     IN NUMBER) RETURN BOOLEAN AS
/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who             When          What
 pathipat        23-Nov-2005   Bug 4718712 - Added code to set local variable to p_course_version_number
 pathipat        21-Sep-2005   Bug 3513252 - Removed appending IGS_FI_PRE_SET_CHARGE to the fee type description
                               Removed local variable v_fee_description as it is not being used anymore
 bannamal        08-Jul-2005   Enh#3392088 Campus Privilege Fee. Changes done as per TD.
 bannamal        03-JUN-2005   Bug#3442712 Unit Level Fee Assessment Build. Modified c_elm_rng_rates to include
                               unit_type_id,  unit_mode, unit_cd, unit_version_number,unit_level. Added code to
                               get derived Unit Program Type level, Unit Class, Unit Mode, Version Number, Unit Level.
 bannamal        27-May-2005   Bug#4077763 Fee Calculation Performance Enhancement. Changes done as per TD.
 shtatiko        27-JUL-2004   Bug# 3795849, Added l_v_derived_prog_att_mode to hold value of AM set at Program Attempt.
                               Bug# 3784618, Changed parameters and defnition of c_cfar
 UUDAYAPR 17-DEC-2003 --Modified The Parameter Type Of P_fee_assessment To Number
                         From Igs_fi_fee_ass_debt_v.Assessment_amount%Type.
 shtatiko        08-DEC-2003   Bug# 3175779, Removed the cursor c_fterrv. Added c_elm_rng_rates and c_elm_ranges.
                               Modified the remaining code to effect this change.
 shtatiko        13-NOV-2003   Bug# 3255069, p_charge_elements is made to 1 only when Charge Method is overridden.
                               And this is done only after processing all records in PL/SQL Table.
 pathipat        05-Nov-2003   Enh 3117341 - Audit and Special Fees TD
                               Added code for Audit Fee Type
 pathipat        29-Oct-2003   Bug 3166331 - Derived location_cd from SUA level if charge method <> Flatrate.
                               Added cursor c_sua_location_cd for the same.
 pathipat        13-Oct-2003   Bug 3166331 - Modified code to derive org_unit_cd from Unit Attempt/Unit Section level
                               if the charge method is not Flatrate. Also to derive course_cd irrespective of override
                               Also for Predictive Mode, derived the course_cd and org_unit_Cd from SPA level.
 pathipat        12-Sep-2003   Enh 3108052 - Unit Sets in Rate Table build
                               Modified c_fterrv to include unit_set_cd and us_Version_number
                               Added logic w.r.t unit_set_cd and version_number
 pathipat       03-Sep-2003    Bug 3123669 - If charge method is overridden, then re-set charge method
                               to Flat Rate and Status = 'O'.
 rnirwani        02-May-02  Bug# 2344901
                            Modification done to local procedure finpl_fin_far
                            in the section where the calculation is done for the assessment based upon the
                            charge elements and the charge rate code has been modified to take care of null values for
                            the charge elements, charge rate and the assessed amount.
 rnirwani        02-May-02  Bug# 2345191
                            cursor c_cfar has been modified to accept the attendance mode, type and location code
                            as parameter when the cursor is invoked.
                            the cursor invocation has been changed to accept the derived values of above.
                            The parameter values would not be used for identifying the contract charge rate.

 (reverse chronological order - newest change first)
***************************************************************/
lv_param_values VARCHAR2(1080);
BEGIN
DECLARE
e_one_record_expected           EXCEPTION;
v_message_name                  VARCHAR2(30);
v_charge_rate                   IGS_FI_FEE_AS_RATE.chg_rate%TYPE := 0.0;
v_lower_nrml_rate_ovrd_ind      IGS_FI_FEE_AS_RT.lower_nrml_rate_ovrd_ind%TYPE;
v_residency_status_cd           igs_fi_fee_as_rate.residency_status_cd%TYPE;
v_class_standing                igs_fi_fee_as_rate.class_standing%TYPE;
v_cfar_chg_rate                 IGS_FI_FEE_AS_RT.chg_rate%TYPE;
v_derived_location_cd           igs_fi_fee_as_rate.location_cd%TYPE;
v_derived_attendance_type       igs_fi_fee_as_rate.attendance_type%TYPE;
v_derived_govt_att_mode         igs_en_atd_mode_all.govt_attendance_mode%TYPE;
l_v_derived_prog_att_mode       igs_en_atd_mode_all.attendance_mode%TYPE;

v_derived_residency_status_cd   igs_fi_fee_as_rate.residency_status_cd%TYPE;
v_derived_org_unit_cd           hz_parties.party_number%TYPE;
v_derived_class_standing        igs_fi_fee_as_rate.class_standing%TYPE;

v_derived_unit_set_cd           igs_fi_fee_as_rate.unit_set_cd%TYPE := NULL;
v_derived_us_version_num        igs_fi_fee_as_rate.us_version_number%TYPE := NULL;

lv_cntrct_rt_apply              BOOLEAN;

/**to check  whether override charge method is actioned**/
lv_charge_override BOOLEAN := FALSE;
lv_fee_assessment IGS_FI_FEE_AS_ITEMS.amount%TYPE;
v_derived_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE;
l_overide_chg_method igs_fi_f_typ_ca_inst_all.s_chg_method_type%TYPE;
l_fee_category IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE;

l_ch_ovr_exist BOOLEAN := FALSE;

l_b_elm_ranges_defined BOOLEAN := FALSE;
l_b_elm_range_applies BOOLEAN := FALSE;
l_n_crs_version_num   igs_fi_fee_as_items.crs_version_number%TYPE;

v_derived_unit_type_id             igs_fi_fee_as_rate.unit_type_id%TYPE;
v_derived_unit_class               igs_fi_fee_as_rate.unit_class%TYPE;
v_derived_unit_mode                igs_fi_fee_as_rate.unit_mode%TYPE;
v_derived_unit_cd                  igs_fi_fee_as_rate.unit_cd%TYPE;
v_derived_unit_version_num         igs_fi_fee_as_rate.unit_version_number%TYPE;
v_derived_unit_level               igs_fi_fee_as_rate.unit_level%TYPE;
l_v_level_code                     igs_ps_unit_type_lvl.level_code%TYPE;

l_v_inst_course_cd                 igs_fi_fai_dtls.course_cd%TYPE;
l_v_inst_unit_att_status           igs_fi_fai_dtls.unit_attempt_status%TYPE;
l_v_inst_location_cd               igs_fi_fai_dtls.location_cd%TYPE;
l_v_inst_org_unit_cd               igs_fi_fai_dtls.org_unit_cd%TYPE;
l_b_derived        BOOLEAN := FALSE;
l_n_called         NUMBER;
l_n_count          NUMBER;
l_v_trace_on       VARCHAR2(5);
l_b_elm_rng        BOOLEAN  := FALSE;
l_b_pred           BOOLEAN  := FALSE;

/**Cursor to get fee type description**/
 CURSOR c_fee_type( cp_fee_type      IGS_FI_FEE_AS_ITEMS.FEE_TYPE%TYPE ) IS
        SELECT description
        FROM igs_fi_fee_type_all
        WHERE fee_type = cp_fee_type;

v_fee_type_description     igs_fi_fee_type_all.description%TYPE;

-- Cursor to find all rates defined under element range found in above cursor.
CURSOR c_elm_rng_rates ( cp_v_fee_type       igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                         cp_v_fee_cal_type   igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                         cp_n_ci_seq_number  igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE,
                         cp_v_fee_cat        igs_fi_fee_cat_all.fee_cat%TYPE,
                         cp_n_range_number   igs_fi_elm_range.range_number%TYPE,
                         cp_v_relation_type  igs_fi_elm_range.s_relation_type%TYPE) IS
  SELECT err.rate_number,
         far.order_of_precedence,
         far.chg_rate,
         far.govt_hecs_payment_option,
         far.govt_hecs_cntrbtn_band,
         far.location_cd,
         far.attendance_type,
         far.attendance_mode,
         far.unit_class,
         far.residency_status_id,
         far.residency_status_cd,
         far.course_cd,
         far.version_number,
         far.class_standing ,
         far.org_party_id,
         far.unit_set_cd,
         far.us_version_number,
         far.unit_type_id,
         far.unit_mode,
         far.unit_cd,
         far.unit_version_number,
         far.unit_level
  FROM igs_fi_elm_range_rt err,
       igs_fi_fee_as_rate far
  WHERE far.fee_type = err.fee_type
  AND far.fee_cal_type = err.fee_cal_type
  AND far.fee_ci_sequence_number = err.fee_ci_sequence_number
  AND far.rate_number = err.rate_number
  AND far.s_relation_type = err.s_relation_type
  AND (far.fee_cat = err.fee_cat OR (far.fee_cat IS NULL AND err.fee_cat IS NULL))
  AND err.fee_type = cp_v_fee_type
  AND err.fee_cal_type = cp_v_fee_cal_type
  AND err.fee_ci_sequence_number = cp_n_ci_seq_number
  AND (err.fee_cat IS NULL OR err.fee_cat = cp_v_fee_cat)
  AND err.range_number = cp_n_range_number
  AND err.s_relation_type = cp_v_relation_type  -- just to be sure that Elm Ranges and Elm Range Rates are picked up from same level and so redundant.
  AND err.logical_delete_dt IS NULL
  AND far.logical_delete_dt IS NULL
  ORDER BY far.order_of_precedence ASC;

-- This cursor identifies the contact rate based for the person program attempt for the fee type being processed.
-- If the Profile is Nominated, Rate's AM is compared against Nominated Program AM.
--                   Derived, Derived Govt AM is compared against Govt AM mapped to Rate's AM.
CURSOR c_cfar ( cp_location_cd      igs_fi_fee_as_rate.location_cd%TYPE,
                cp_attendance_type  igs_fi_fee_as_rate.attendance_type%TYPE,
                cp_prog_att_mode    igs_fi_fee_as_rate.attendance_mode%TYPE,
                cp_govt_att_mode    igs_en_atd_mode_all.govt_attendance_mode%TYPE) IS
  SELECT cfar.lower_nrml_rate_ovrd_ind,
         cfar.chg_rate
  FROM igs_fi_fee_as_rt  cfar,
       igs_en_atd_mode_all am
  WHERE cfar.person_id = p_person_id AND
        cfar.course_cd = p_course_cd AND
        cfar.FEE_TYPE = p_fee_type AND
        NVL(cfar.location_cd, cp_location_cd) = cp_location_cd AND
        NVL(cfar.attendance_type, cp_attendance_type) = cp_attendance_type AND
        am.attendance_mode (+) = cfar.attendance_mode AND
        (
         (g_v_att_profile = gcst_nominated AND NVL(cfar.attendance_mode, cp_prog_att_mode) = cp_prog_att_mode)
         OR
         (g_v_att_profile = gcst_derived AND NVL(am.govt_attendance_Mode, cp_govt_att_mode) = cp_govt_att_mode)
        ) AND
        TRUNC(p_effective_dt) >= TRUNC(cfar.start_dt) AND
        (cfar.end_dt IS NULL OR
        TRUNC(p_effective_dt) <= TRUNC(cfar.end_dt));

  CURSOR c_am (cp_attendance_mode  igs_en_atd_mode_all.attendance_mode%TYPE) IS
        SELECT  am.GOVT_ATTENDANCE_MODE
        FROM    igs_en_atd_mode_all am
        WHERE   am.ATTENDANCE_MODE = cp_attendance_mode;

  -- To find the organization unit code from the Student Attempt Table (For Charge Method of
  -- FLATRATE)
  CURSOR c_resp_org_unit_cd(cp_course_cd IN igs_ps_ver_all.course_cd%TYPE,
                            cp_version_number IN igs_ps_ver_all.version_number%TYPE ) IS
  SELECT responsible_org_unit_cd
  FROM   igs_ps_ver_all v
  WHERE  v.course_cd            = cp_course_cd
  AND    v.version_number       = cp_version_number;

  -- To find the organization unit code from the Unit Section Level
  CURSOR c_org_unit_sec_cd(cp_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT owner_org_unit_cd, location_cd
  FROM   igs_ps_unit_ofr_opt_all
  WHERE  uoo_id = cp_uoo_id;

  CURSOR cur_unit_cd (cp_n_uoo_id  igs_fi_fee_as_items.uoo_id%TYPE) IS
  SELECT unit_cd, version_number
  FROM   igs_ps_unit_ofr_opt_all
  WHERE  uoo_id = cp_n_uoo_id;

FUNCTION finpl_ins_match_chg_rate(
        p_rate_location_cd              igs_fi_fee_as_rate.location_cd%TYPE,
        p_rate_attendance_type          igs_fi_fee_as_rate.attendance_type%TYPE,
        p_rate_attendance_mode          igs_fi_fee_as_rate.attendance_mode%TYPE,
        p_rate_class_standing           IGS_PR_CLASS_STD.CLASS_STANDING%TYPE,
        p_rate_course_cd                igs_ps_ver_all.course_cd%TYPE,
        p_rate_version_number           igs_ps_ver_all.version_number%TYPE,
        p_rate_org_unit_cd              igs_ps_unit_ver_all.owner_org_unit_cd%TYPE,
        p_rate_residency_status_cd      igs_pe_res_dtls_all.residency_status_cd%TYPE,
        p_derived_location_cd           igs_fi_fee_as_rate.location_cd%TYPE,
        p_derived_attendance_type       igs_fi_fee_as_rate.attendance_type%TYPE,
        p_derived_govt_att_mode         igs_en_atd_mode_all.govt_attendance_mode%TYPE,
        p_derived_prog_att_mode         igs_en_atd_mode_all.attendance_mode%TYPE,
        p_derived_class_standing        IGS_PR_CLASS_STD.CLASS_STANDING%TYPE,
        p_derived_course_cd             igs_ps_ver_all.course_cd%TYPE,
        p_derived_version_number        igs_ps_ver_all.version_number%TYPE,
        p_derived_org_unit_cd           igs_ps_unit_ver_all.owner_org_unit_cd%TYPE,
        p_derived_residency_status_cd   igs_pe_res_dtls_all.residency_status_cd%TYPE,
        p_rate_unit_set_cd              igs_fi_fee_as_rate.unit_set_cd%TYPE,
        p_rate_us_version_num           igs_fi_fee_as_rate.us_version_number%TYPE,
        p_derived_unit_set_cd           igs_fi_fee_as_rate.unit_set_cd%TYPE,
        p_derived_us_version_num        igs_fi_fee_as_rate.us_version_number%TYPE,
        p_rate_unit_type_id             igs_fi_fee_as_items.unit_type_id%TYPE,
        p_derived_unit_type_id          igs_fi_fee_as_items.unit_type_id%TYPE,
        p_rate_unit_class               igs_fi_fee_as_items.unit_class%TYPE,
        p_derived_unit_class            igs_fi_fee_as_items.unit_class%TYPE,
        p_rate_unit_mode                igs_fi_fee_as_items.unit_mode%TYPE,
        p_derived_unit_mode             igs_fi_fee_as_items.unit_mode%TYPE,
        p_rate_unit_cd                  igs_fi_fee_as_rate.unit_cd%TYPE,
        p_derived_unit_cd               igs_fi_fee_as_rate.unit_cd%TYPE,
        p_rate_unit_version_num         igs_fi_fee_as_rate.unit_version_number%TYPE,
        p_derived_unit_version_num      igs_fi_fee_as_rate.unit_version_number%TYPE,
        p_rate_unit_level               igs_fi_fee_as_items.unit_level%TYPE,
        p_derived_unit_level            igs_fi_fee_as_items.unit_level%TYPE
        ) RETURN BOOLEAN AS
/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who             When          What
 bannamal        03-JUN-2005   Bug#3442712 Unit Level Fee Assessment Build.
                               Added new parameters and added checks on these parameters.
 shtatiko        27-JUL-2004   Enh# 3795849, Added p_derived_prog_att_mode.
 pathipat        12-Sep-2003   Enh 3108052 - Unit Sets in Rate Table build
                               Added code and params related to unit_set_cd and us_version_number
 vchappid       27-Jan-03      Bug#2656411, modified the logic for identifying matching fee assessment rate
*************************************************************/

BEGIN   -- finpl_ins_match_chg_rate
        -- 2.3.1 Match Charge Rate
        -- Attempt to match assessment rate attributes with student IGS_PS_COURSE attempt.
        -- The order of precedence ensures the first
        -- match found is the desired charge rate.
  DECLARE
    v_rate_govt_att_mode   igs_en_atd_mode_all.govt_attendance_mode%TYPE;
    CURSOR c_am IS
      SELECT am.govt_attendance_mode
      FROM igs_en_atd_mode_all am
      WHERE am.attendance_mode = p_rate_attendance_mode;

  BEGIN
    log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                p_v_string => 'Entered finpl_ins_match_chg_rate. Rate Parameters are: ' ||
                              p_rate_location_cd || ', ' || p_rate_attendance_type || ', ' || p_rate_attendance_mode
                              || ', ' || p_rate_class_standing || ', ' || p_rate_course_cd || ', ' || p_rate_version_number
                              || ', ' || p_rate_org_unit_cd || ', ' || p_rate_residency_status_cd
                              || ', ' || p_rate_unit_set_cd || ', ' || p_rate_us_version_num);
    log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                p_v_string => 'Entered finpl_ins_match_chg_rate. Derived Parameters are: ' ||
                              p_derived_location_cd || ', ' || p_derived_attendance_type || ', ' || p_derived_govt_att_mode
                              || ', ' || p_derived_prog_att_mode || ', ' || p_derived_class_standing || ', ' || p_derived_course_cd
                              || ', ' || p_derived_version_number || ', ' || p_derived_org_unit_cd
                              || ', ' || p_derived_residency_status_cd || ', ' || p_derived_unit_set_cd || ', ' || p_derived_us_version_num);

    IF (p_rate_location_cd IS NOT NULL) THEN
      IF ((p_derived_location_cd <> p_rate_location_cd) OR p_derived_location_cd IS NULL) THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Location Code Mismatch. Values:'|| p_rate_location_cd || ', ' || p_derived_location_cd || '. Returning false.');
        RETURN FALSE;
      END IF;
    END IF;

    IF (p_rate_attendance_type IS NOT NULL) THEN
      IF ((p_derived_attendance_type <> p_rate_attendance_type) OR p_derived_attendance_type IS NULL) THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Att Type Mismatch. Values:'|| p_rate_attendance_type || ', ' || p_derived_attendance_type || '. Returning false.');
       RETURN FALSE;
      END IF;
    END IF;

    IF (p_rate_attendance_mode IS NOT NULL) THEN
      -- Get the govt attendance mode for the fee assessment rate attendance mode
      IF g_v_att_profile = gcst_nominated THEN
        -- In case of Nominated, compare Rate's AM with Derived Program AM.
        IF ((p_derived_prog_att_mode <> p_rate_attendance_mode) OR p_derived_prog_att_mode IS NULL) THEN
          log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                      p_v_string => 'Nominated: Att Mode Mismatch. Values:'|| p_rate_attendance_mode || ', Prog AM: ' || p_derived_prog_att_mode || ', Govt AM: ' || p_derived_govt_att_mode || '. Returning false.');
          RETURN FALSE;
        END IF;
      ELSE
        -- In case of Derived, compare Rate's Govt AM with Derived Govt AM (In case of Derived, only Govt AM is derived)
        OPEN c_am;
        FETCH c_am INTO v_rate_govt_att_mode;
        CLOSE c_am;
        IF ((p_derived_govt_att_mode <> v_rate_govt_att_mode) OR p_derived_govt_att_mode IS NULL) THEN
          log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                      p_v_string => 'Derived: Att Mode Mismatch. Values:'|| p_rate_attendance_mode || ', ' || v_rate_govt_att_mode || ', ' || p_derived_govt_att_mode || '. Returning false.');
          RETURN FALSE;
        END IF;
      END IF;
    END IF;

    IF (p_rate_class_standing IS NOT NULL )THEN
      IF ((p_derived_class_standing <> p_rate_class_standing) OR p_derived_class_standing IS NULL)  THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Class Standing Mismatch. Values:'|| p_rate_class_standing || ', ' || p_derived_class_standing || '. Returning false.');
        RETURN FALSE;
      END IF;
    END IF;

    IF (p_rate_course_cd IS NOT NULL) THEN
      IF ((p_derived_course_cd <> p_rate_course_cd) OR p_derived_course_cd IS NULL) THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Course Cd Mismatch. Values:'|| p_rate_course_cd || ', ' || p_derived_course_cd || '. Returning false.');
        RETURN FALSE;
      ELSIF (p_rate_version_number IS NOT NULL) THEN
        IF ((p_derived_version_number <> p_rate_version_number) OR p_derived_version_number IS NULL) THEN
           log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Course Ver Mismatch. Values:'|| p_rate_version_number || ', ' || p_derived_version_number || '. Returning false.');
           RETURN FALSE;
        END IF;
      END IF;
    END IF;

    IF (p_rate_org_unit_cd IS NOT NULL )THEN
      IF ((p_derived_org_unit_cd <> p_rate_org_unit_cd ) OR p_derived_org_unit_cd IS NULL)  THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Org Unit Mismatch. Values:'|| p_rate_org_unit_cd || ', ' || p_derived_org_unit_cd || '. Returning false.');
        RETURN FALSE;
      END IF;
    END IF;

    IF (p_rate_residency_status_cd IS NOT NULL )THEN
      IF ((p_derived_residency_status_cd <> p_rate_residency_status_cd ) OR p_derived_residency_status_cd IS NULL) THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Res Stat Mismatch. Values:'|| p_rate_residency_status_cd || ', ' || p_derived_residency_status_cd || '. Returning false.');
       RETURN FALSE;
      END IF;
    END IF;

    IF (p_rate_unit_set_cd IS NOT NULL) THEN
      IF ((p_derived_unit_set_cd <> p_rate_unit_set_cd) OR  p_derived_unit_set_cd IS NULL) THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Unit Set Cd Mismatch. Values:'|| p_rate_unit_set_cd || ', ' || p_derived_unit_set_cd || '. Returning false.');
       RETURN FALSE;
      ELSIF (p_rate_us_version_num IS NOT NULL) THEN
        IF ((p_derived_us_version_num <> p_rate_us_version_num) OR p_derived_us_version_num IS NULL) THEN
           log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'Unit Set Ver Mismatch. Values:'|| p_rate_us_version_num || ', ' || p_derived_us_version_num || '. Returning false.');
           RETURN FALSE;
        END IF;
      END IF;
    END IF;

    IF (p_rate_unit_type_id IS NOT NULL) THEN
      IF ((p_derived_unit_type_id <> p_rate_unit_type_id) OR p_derived_unit_type_id IS NULL) THEN
         log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                 p_v_string => 'Unit Program Type Level Mismatch. Values:'|| p_rate_unit_type_id || ', ' || p_derived_unit_type_id || '. Returning false.');
         RETURN FALSE;
      END IF;
    END IF;

    IF (p_rate_unit_class IS NOT NULL) THEN
      IF ((p_derived_unit_class <> p_rate_unit_class) OR p_derived_unit_class IS NULL) THEN
         log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
               p_v_string => 'Unit Class Mismatch. Values:'|| p_rate_unit_class || ', ' || p_derived_unit_class || '. Returning false.');
        RETURN FALSE;
      END IF;
    END IF;

    IF (p_rate_unit_mode IS NOT NULL) THEN
      IF ((p_derived_unit_mode <> p_rate_unit_mode) OR p_derived_unit_mode IS NULL) THEN
         log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
              p_v_string => 'Unit Mode Mismatch. Values:'|| p_rate_unit_mode || ', ' || p_derived_unit_mode || '. Returning false.');
        RETURN FALSE;
      END IF;
    END IF;

   IF (p_rate_unit_cd IS NOT NULL) THEN
      IF ((p_derived_unit_cd <> p_rate_unit_cd) OR p_derived_unit_cd IS NULL) THEN
         log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
              p_v_string => 'Unit Code Mismatch. Values:'|| p_rate_unit_cd || ', ' || p_derived_unit_cd || '. Returning false.');
         RETURN FALSE;
      ELSIF (p_rate_unit_version_num IS NOT NULL) THEN
         IF ((p_derived_unit_version_num <> p_rate_unit_version_num) OR p_derived_unit_version_num IS NULL) THEN
            log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                 p_v_string => 'Unit Version Mismatch. Values:'|| p_rate_unit_version_num || ', ' || p_derived_unit_version_num || '. Returning false.');
            RETURN FALSE;
         END IF;
      END IF;
   END IF;

   IF (p_rate_unit_level IS NOT NULL) THEN
     IF ((p_derived_unit_level <> p_rate_unit_level) OR p_derived_unit_level IS NULL) THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
               p_v_string => 'Unit Level Mismatch. Values:'|| p_rate_unit_level || ', ' || p_derived_unit_level || '. Returning false.');
        RETURN FALSE;
     END IF;
   END IF;

    log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                p_v_string => 'All rate attributes matched. Returning True.');
    RETURN TRUE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        log_to_fnd( p_v_module => 'finpl_ins_match_chg_rate',
                    p_v_string => 'From WHEN OTHERS. ' || SUBSTR(sqlerrm,1,500));
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_INS_MATCH_CHG_RATE-'||SUBSTR(sqlerrm,1,500));
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END finpl_ins_match_chg_rate;

-------------------------------------------------------------------------------
FUNCTION finpl_get_derived_values (
        p_person_id                     hz_parties.party_id%TYPE,
        p_course_cd                     IGS_PS_COURSE.course_cd%TYPE,
        p_effective_dt                  DATE,
        p_fee_cal_type                  igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
        p_fee_ci_sequence_number        igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE,
        p_fee_type                      igs_fi_f_cat_fee_lbl_all.fee_type%TYPE,
        p_s_fee_trigger_cat             igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
        p_trace_on                      VARCHAR2,
        p_derived_attendance_type       OUT NOCOPY      igs_fi_fee_as_rate.attendance_type%TYPE,
        p_derived_govt_att_mode         OUT NOCOPY      igs_en_atd_mode_all.govt_attendance_mode%TYPE,
        p_derived_prog_att_mode         OUT NOCOPY      igs_en_atd_mode_all.attendance_mode%TYPE, -- Added as part of 3795849
        p_derived_residency_status_cd   OUT NOCOPY      igs_pe_res_dtls_all.residency_status_cd%TYPE,
        p_derived_class_standing        OUT NOCOPY   IGS_PR_CLASS_STD.CLASS_STANDING%TYPE,
        p_c_career                      IN      igs_ps_ver_all.course_type%TYPE,
        p_derived_unit_set_cd           OUT NOCOPY igs_en_unit_set_all.unit_set_cd%TYPE,
        p_derived_us_version_num        OUT NOCOPY igs_en_unit_set_all.version_number%TYPE
        ) RETURN BOOLEAN  AS
/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who             When          What
 pathipat        21-Sep-2005   Bug 4383148 - Fees not assessed if attendance type cannot be derived
                               Removed code that returns FALSE if AT could not be derived.
 pathipat        12-Sep-2003   Enh 3108052 - Unit Sets in Rate Table build
                               Added params p_derived_unit_set_cd and p_derived_us_version_num
 shtatiko        27-Jul-2004   Bug# 3795849, Added p_derived_attendance_mode. This holds value only in case of Nominated Profile.
 bannamal        1-Jul-2005    Bug#4077763 Fee Calculation Performance Enhancement.
                               Removed the parameters p_prior_fee_cal_type, p_prior_fee_ci_sequence_number
*************************************************************/

BEGIN
  DECLARE
    cst_on          CONSTANT        VARCHAR2(10) := 'ON';
    cst_off         CONSTANT        VARCHAR2(10) := 'OFF';
    cst_composite   CONSTANT        VARCHAR2(10) := 'COMPOSITE';
    v_total_period_load             NUMBER;
    v_derived_attendance_type       igs_en_atd_type_all.attendance_type%TYPE;
    v_derived_attendance_mode       VARCHAR2(10);  -- Used only in case of Derived Profile. Holds values On, Off, and Composite.
    v_derived_govt_att_mode         igs_en_atd_mode_all.govt_attendance_mode%TYPE;
    v_derived_prog_att_mode         igs_en_atd_mode_all.attendance_mode%TYPE;  -- Used in Nominated Profile. Holds value of AM associated at Prog Attempt.
    v_trigger_fired                 fnd_lookup_values.lookup_code%TYPE;
    v_count                         NUMBER(5);
    v_on_att_mode                   BOOLEAN := FALSE;
    v_off_att_mode                  BOOLEAN := FALSE;
    v_composite_att_mode            BOOLEAN := FALSE;

    v_derived_residency_status_cd           igs_pe_res_dtls_all.residency_status_cd%TYPE;
    v_derived_class_standing                IGS_PR_CLASS_STD.CLASS_STANDING%TYPE;

    -- Bug# 2122257, Modified the cursor select statement to include the audit table (IGS_FI_F_CAT_CAL_REL)
    -- for selecting Fee Category when it is changed.
    /* Modified by vchappid as a part of SFCR015 Build */
    -- cursor modified as per enh# 2162747, implemented as ref cursor
    TYPE derived_values_rec IS RECORD ( course_cd      igs_ps_ver_all.course_cd%TYPE,
                                        course_type    igs_ps_ver_all.course_type%TYPE);
    TYPE derived_values_ref IS REF CURSOR RETURN derived_values_rec;
    c_scafv    derived_values_ref;
    l_c_scafv  c_scafv%ROWTYPE;

    l_c_course_cd igs_ps_ver_all.course_cd%TYPE;

    -- record type variable defined for geeting the attendance type and govt attendance mode when the
    -- nominated values are used
    TYPE l_der_nom_rec IS RECORD ( attendance_type  igs_en_atd_type_all.attendance_type%TYPE,
                                   govt_att_mode    igs_en_atd_mode_all.govt_attendance_mode%TYPE,
                                   prog_att_mode    igs_en_atd_mode_all.attendance_mode%TYPE);
    TYPE l_der_nom_ref IS REF CURSOR RETURN l_der_nom_rec;

    c_att_md_ty    l_der_nom_ref;
    l_c_att_md_ty  c_att_md_ty%ROWTYPE;

    CURSOR cur_fee_type(cp_v_fee_type   igs_fi_fee_type_all.fee_type%TYPE) IS
      SELECT s_fee_type
      FROM igs_fi_fee_type_all
      WHERE fee_type =  cp_v_fee_type;

    l_v_s_fee_type       igs_fi_fee_type_all.s_fee_type%TYPE := NULL;
    l_n_cr_points        igs_en_su_attempt_all.override_achievable_cp%TYPE;
    l_n_fte              igs_en_su_attempt_all.override_achievable_cp%TYPE;

  BEGIN
    log_to_fnd( p_v_module => 'finpl_get_derived_values',
                p_v_string => 'Entered finpl_get_derived_values. Parameters are: ' ||
                              p_person_id || ', ' || p_course_cd || ', ' || TO_CHAR(p_effective_dt, 'DD-MON-YYYY')
                              || ', ' || p_fee_cal_type || ', ' || p_fee_ci_sequence_number || ', ' || p_fee_type
                               || ', ' || p_s_fee_trigger_cat || ', ' || p_trace_on || ', ' || p_c_career );
    IF (p_trace_on = 'Y') THEN
      fnd_file.new_line(fnd_file.log);
    END IF;
    -- Obtain System Fee Type for the fee_type provided
    OPEN cur_fee_type(p_fee_type);
    FETCH cur_fee_type INTO l_v_s_fee_type;
    CLOSE cur_fee_type;

    log_to_fnd( p_v_module => 'finpl_get_derived_values',
                p_v_string => 'Profile IGS_FI_NOM_DER_VALUES value: ' || g_v_att_profile );
    -- Get the derived attendance type
    ----------------------------------

    -- Profile Value is NOMINATED:
    --       If Institution Fee OR Primary Career Calculation Method
    --          Get AT and AM from Key Program
    --       Else
    --          Get AT and AM from Program in context
    -- Profile Value is DERIVED
    --       Call EN APIs to get AT.

    IF (g_v_att_profile = gcst_nominated) THEN --Enh# 2162747, SFCR06

        IF (p_s_fee_trigger_cat = 'INSTITUTN' OR g_c_fee_calc_mthd = g_v_primary_career) THEN  -- For Institutional Level
            OPEN c_att_md_ty FOR SELECT a.attendance_type,
                                        b.govt_attendance_mode,
                                        a.attendance_mode
                                 FROM   igs_en_spa_terms a,
                                        igs_en_atd_mode_all b
                                 WHERE  a.person_id = p_person_id
                                 AND    a.term_cal_type = g_v_load_cal_type
                                 AND    a.term_sequence_number = g_n_load_seq_num
                                 AND    b.attendance_mode = a.attendance_mode
                                 AND    a.key_program_flag = 'Y';
        ELSE -- For Other than Institutional Level
            OPEN c_att_md_ty FOR SELECT a.attendance_type,
                                        b.govt_attendance_mode,
                                        a.attendance_mode
                                 FROM   igs_en_spa_terms a,
                                        igs_en_atd_mode_all b
                                 WHERE  a.person_id = p_person_id
                                 AND    a.program_cd = p_course_cd
                                 AND    a.term_cal_type = g_v_load_cal_type
                                 AND    a.term_sequence_number = g_n_load_seq_num
                                 AND    b.attendance_mode = a.attendance_mode;
        END IF;

      FETCH c_att_md_ty INTO l_c_att_md_ty;
      -- Same Attendance Mode and Attendance Type variables are used to avoid duplicate declaring of the local variables
      v_derived_attendance_type := l_c_att_md_ty.attendance_type;
      v_derived_govt_att_mode   := l_c_att_md_ty.govt_att_mode;
      v_derived_prog_att_mode   := l_c_att_md_ty.prog_att_mode;
      CLOSE c_att_md_ty;

      log_to_fnd( p_v_module => 'finpl_get_derived_values',
                  p_v_string => 'Nominated Profile. Derived Att Type: ' || v_derived_attendance_type ||
                                ', Govt. Att Mode: ' || v_derived_govt_att_mode ||
                                ', Prog Att Mode: ' || v_derived_prog_att_mode);
      -- End of Modification Enh# 2162747
    ELSE
      log_to_fnd( p_v_module => 'finpl_get_derived_values',
                  p_v_string => 'Profile value is Derived. Deriving Attendance Type.');
      -- Get Attendance Type by calling EN API.
      IF p_s_fee_trigger_cat = gcst_institutn OR
         g_c_fee_calc_mthd = g_v_primary_career THEN
        igs_en_prc_load.enrp_get_inst_latt_fte ( p_person_id        => p_person_id,
                                                 p_load_cal_type    => g_v_load_cal_type,
                                                 p_load_seq_number  => g_n_load_seq_num,
                                                 p_attendance       => v_derived_attendance_type,
                                                 p_credit_points    => l_n_cr_points,
                                                 p_fte              => l_n_fte );

      ELSE /* p_s_fee_trigger_cat <> gcst_institutn AND g_c_fee_calc_mthd <> g_v_primary_career */
        v_derived_attendance_type := igs_en_prc_load.enrp_get_prg_att_type ( p_person_id        => p_person_id,
                                                                             p_course_cd        => p_course_cd,
                                                                             p_cal_type         => g_v_load_cal_type,
                                                                             p_sequence_number  => g_n_load_seq_num );
      END IF;
    END IF;

    IF (v_derived_attendance_type IS NULL) THEN
      IF (p_trace_on = 'Y') THEN
        fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTTYPE');
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
    END IF;

    log_to_fnd( p_v_module => 'finpl_get_derived_values',
                p_v_string => 'Deriving Attendance Mode...');
    -- Get the derived attendance mode
    ----------------------------------
    -- Start of Modification Enh# 2162747
    IF (g_v_att_profile = gcst_nominated) THEN
      IF v_derived_govt_att_mode IS NULL AND v_derived_prog_att_mode IS NULL THEN
        IF (p_trace_on = 'Y') THEN
          -- Trace Entry
           fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTMODE');
           fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;
      END IF;
      -- End of Modification Enh# 2162747
    ELSE

      -- Processing for PRIMARY_CAREER is same for Institution and Non-Institution Fees.
      IF (p_s_fee_trigger_cat = gcst_institutn AND g_c_fee_calc_mthd <> g_v_primary_career) THEN

          -- For all the liable program attempts identified in finpl_clc_chg_mthd_elements, find attendance mode.
          IF g_inst_liable_progs_tbl.COUNT > 0 THEN
            log_to_fnd( p_v_module => 'finpl_get_derived_values',
                        p_v_string => 'Looping through Liable Programs in Institution case. (table g_inst_liable_progs_tbl) ');
            FOR l_n_cntr IN g_inst_liable_progs_tbl.FIRST..g_inst_liable_progs_tbl.LAST LOOP
              IF g_inst_liable_progs_tbl.EXISTS(l_n_cntr) THEN

                l_c_course_cd := g_inst_liable_progs_tbl(l_n_cntr).program_cd;
                -- get the attendance mode for the current load period for the course in context.
                v_derived_attendance_mode := igs_en_gen_006.enrp_get_sca_am(p_person_id,
                                                                            l_c_course_cd,
                                                                            g_v_load_cal_type,
                                                                            g_n_load_seq_num);
                log_to_fnd( p_v_module => 'finpl_get_derived_values',
                            p_v_string => 'Attendance Mode derived for course ' || l_c_course_cd || ' is ' || v_derived_attendance_mode);
                IF (v_derived_attendance_mode = cst_on) THEN
                  v_on_att_mode := TRUE;
                ELSIF (v_derived_attendance_mode = cst_off) THEN
                  v_off_att_mode := TRUE;
                ELSIF (v_derived_attendance_mode = cst_composite) THEN
                  v_composite_att_mode := TRUE;
                END IF;
              END IF;
            END LOOP;
          END IF;

        -- Determine the govt attendance mode from the combination
        -- of derived values across the student program attempts
        v_derived_prog_att_mode := NULL; -- This variable holds value only in case of Nominated Profile
        IF (v_on_att_mode = TRUE AND
          v_off_att_mode = FALSE AND
          v_composite_att_mode = FALSE) THEN
          v_derived_govt_att_mode := 1;
        ELSIF (v_on_att_mode = FALSE AND
          v_off_att_mode = TRUE AND
          v_composite_att_mode = FALSE) THEN
          v_derived_govt_att_mode := 2;
        ELSIF ((v_on_att_mode = TRUE AND
          v_off_att_mode = TRUE) OR
          v_composite_att_mode = TRUE) THEN
          v_derived_govt_att_mode := 3;
        ELSE
          IF (p_trace_on = 'Y') THEN
            -- Trace Entry
            fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTMODE');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
        END IF;
        log_to_fnd( p_v_module => 'finpl_get_derived_values',
                    p_v_string => 'Institution Case: Attendance Mode: ' || v_derived_govt_att_mode);


      ELSE /* p_s_fee_trigger_cat <> gcst_institutn OR g_c_fee_calc_mthd = 'PRIMARY_CAREER' */

        IF ( g_c_fee_calc_mthd IN (g_v_program, g_v_career)) THEN

          -- PROGRAM: Derive AM from the course in context
          -- CAREER : Derive AM for the Primary Program of career i.e., course in context

            v_derived_attendance_mode := igs_en_gen_006.enrp_get_sca_am(p_person_id,
                                                                        p_course_cd,
                                                                        g_v_load_cal_type,
                                                                        g_n_load_seq_num);

          v_derived_prog_att_mode := NULL; -- This variable holds value only in case of Nominated Profile
          IF (v_derived_attendance_mode = cst_on) THEN
            v_derived_govt_att_mode := 1;
          ELSIF (v_derived_attendance_mode = cst_off) THEN
            v_derived_govt_att_mode := 2;
          ELSIF (v_derived_attendance_mode = cst_composite) THEN
            v_derived_govt_att_mode := 3;
          ELSE
            IF (p_trace_on = 'Y') THEN
              -- Trace Entry
              fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTMODE');
              fnd_file.put_line (fnd_file.log, fnd_message.get);
            END IF;
          END IF;
          log_to_fnd( p_v_module => 'finpl_get_derived_values',
                      p_v_string => 'Non-Institution Case, PROGRAM/CAREER: Attendance Mode: ' || v_derived_govt_att_mode);

        ELSIF ( g_c_fee_calc_mthd =g_v_primary_career) THEN
          -- Derive AM from Key Program of the person for the given term.

          OPEN c_scafv FOR SELECT program_cd course_cd,
                                    NULL
                             FROM   igs_en_spa_terms
                             WHERE  person_id = p_person_id
                             AND    term_cal_type = g_v_load_cal_type
                             AND    term_sequence_number = g_n_load_seq_num;

          LOOP
          FETCH c_scafv INTO l_c_scafv;
          EXIT WHEN c_scafv%NOTFOUND;

            v_derived_attendance_mode := igs_en_gen_006.enrp_get_sca_am( p_person_id,
                                                                           l_c_scafv.course_cd,
                                                                           g_v_load_cal_type,
                                                                           g_n_load_seq_num);

            IF (v_derived_attendance_mode = cst_on) THEN
                v_on_att_mode := TRUE;
            ELSIF (v_derived_attendance_mode = cst_off) THEN
              v_off_att_mode := TRUE;
            ELSIF (v_derived_attendance_mode = cst_composite) THEN
              v_composite_att_mode := TRUE;
            END IF;

          END LOOP;
          CLOSE c_scafv;

          -- Determine the govt attendance mode from the combination
          -- of derived values across the load periods
          v_derived_prog_att_mode := NULL; -- This variable holds value only in case of Nominated Profile
          IF (v_on_att_mode = TRUE AND
            v_off_att_mode = FALSE AND
            v_composite_att_mode = FALSE) THEN
            v_derived_govt_att_mode := 1;
          ELSIF (v_on_att_mode = FALSE AND
            v_off_att_mode = TRUE AND
            v_composite_att_mode = FALSE) THEN
            v_derived_govt_att_mode := 2;
          ELSIF ((v_on_att_mode = TRUE AND
            v_off_att_mode = TRUE) OR
            v_composite_att_mode = TRUE) THEN
            v_derived_govt_att_mode := 3;
          ELSE
            IF (p_trace_on = 'Y') THEN
              -- Trace Entry
              fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DERIVE_ATTMODE');
              fnd_file.put_line (fnd_file.log, fnd_message.get);
            END IF;
          END IF;
          log_to_fnd( p_v_module => 'finpl_get_derived_values',
                      p_v_string => 'Non-Institution Case, PRIMARY_CAREER: Attendance Mode: ' || v_derived_govt_att_mode);
        END IF; /* g_c_fee_calc_mthd */
      END IF;
    END IF; /* Nominated or Derived */

    -- Message about derivation of Attendance type and mode needs to be shown only if both
    -- have been derived.
    IF (v_derived_attendance_type IS NOT NULL) AND (v_derived_govt_att_mode IS NOT NULL) THEN
      IF (p_trace_on = 'Y') THEN
        fnd_message.set_name ( 'IGS', 'IGS_FI_ATTTYPE_GOVT_ATTMODE');
        fnd_message.set_token('ATT_TYPE', v_derived_attendance_type);
        fnd_file.put_line(fnd_file.log, fnd_message.get );
        fnd_message.set_name('IGS', 'IGS_FI_DER_ATT_TYPE_GOVT_MODE');
        fnd_message.set_token('ATT_MODE', v_derived_govt_att_mode);
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
    END IF;

    -- Get the derived Residency Status
    ----------------------------------
    -- If the Profile is not set, then no Residency Status matching is required

    log_to_fnd( p_v_module => 'finpl_get_derived_values',
                p_v_string => 'Deriving Residency Status..');
    v_derived_residency_status_cd := get_stdnt_res_status_cd( p_n_person_id => p_person_id );

    IF v_derived_residency_status_cd IS NOT NULL THEN
      IF (p_trace_on = 'Y') THEN
        fnd_message.set_name('IGS', 'IGS_FI_RES_STAT');
        fnd_message.set_token('RES_STAT',  v_derived_residency_status_cd);
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
      log_to_fnd( p_v_module => 'finpl_get_derived_values',
                  p_v_string => 'Residency Status Code: ' || v_derived_residency_status_cd);
    ELSE
      IF (p_trace_on = 'Y') THEN
        fnd_message.set_name('IGS', 'IGS_FI_NO_RES_STAT');
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
      log_to_fnd( p_v_module => 'finpl_get_derived_values',
                  p_v_string => 'Unable to derive Residency Status Code.');
    END IF;

    -- Get the derived Class Standing
    ----------------------------------
    log_to_fnd( p_v_module => 'finpl_get_derived_values',
                p_v_string => 'Deriving Class Standing..');
    v_derived_class_standing := get_stdnt_class_standing ( p_n_person_id => p_person_id,
                                                           p_v_course_cd => p_course_cd,
                                                           p_v_s_fee_trigger_cat => p_s_fee_trigger_cat );
    IF (v_derived_class_standing IS NOT NULL) THEN
      IF (p_trace_on = 'Y') THEN
        fnd_message.set_name('IGS', 'IGS_FI_CLASS_STD');
        fnd_message.set_token('CLASS_STD', v_derived_class_standing);
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
      log_to_fnd( p_v_module => 'finpl_get_derived_values',
                  p_v_string => 'Class Standing: ' || v_derived_class_standing);
    ELSE
      IF (p_trace_on = 'Y') THEN
        fnd_message.set_name ( 'IGS', 'IGS_FI_NO_CLASS_STD' );
        fnd_file.put_line (fnd_file.log, fnd_message.get);
      END IF;
      log_to_fnd( p_v_module => 'finpl_get_derived_values',
                  p_v_string => 'Unable to derive Class Standing.');
   END IF;

    -- Get the derived Unit Set Details
    ----------------------------------

    log_to_fnd( p_v_module => 'finpl_get_derived_values',
                p_v_string => 'Deriving Unit Set Details..');
    get_stdnt_unit_set_dtls ( p_n_person_id => p_person_id,
                              p_v_course_cd => p_course_cd,
                              p_v_s_fee_trigger_cat => p_s_fee_trigger_cat,
                              p_v_unit_set_cd => p_derived_unit_set_cd,
                              p_n_unit_set_ver_num => p_derived_us_version_num );

    -- Log appropriate messages if the Unit Set could or could not be derived
    -- Unit set details are derived only in case of PROGRAM and non-institution case.
    IF (g_c_fee_calc_mthd = g_v_program AND p_s_fee_trigger_cat <> 'INSTITUTN') THEN
      IF p_derived_unit_set_cd IS NOT NULL AND
         p_derived_us_version_num IS NOT NULL THEN
        IF (p_trace_on = 'Y') THEN
          fnd_message.set_name('IGS','IGS_FI_DER_UNIT_SET');
          fnd_message.set_token('UNIT_SET',p_derived_unit_set_cd);
          fnd_message.set_token('VER',p_derived_us_version_num);
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log);
        END IF;
        log_to_fnd( p_v_module => 'finpl_get_derived_values',
                    p_v_string => 'Unit Set Details: ' || p_derived_unit_set_cd || ', ' || p_derived_us_version_num);
      ELSE
        p_derived_unit_set_cd := NULL;
        p_derived_us_version_num := NULL;
        v_message_name := 'IGS_FI_NO_UNIT_SET';
        IF (p_trace_on = 'Y') THEN
           fnd_message.set_name ( 'IGS', v_message_name);
           fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;
        log_to_fnd( p_v_module => 'finpl_get_derived_values',
                    p_v_string => 'Unable to derive Unit Set Details.');
      END IF;
    END IF;

    p_derived_attendance_type := v_derived_attendance_type;
    p_derived_govt_att_mode := v_derived_govt_att_mode;
    p_derived_prog_att_mode := v_derived_prog_att_mode;
    p_derived_residency_status_cd := v_derived_residency_status_cd;
    p_derived_class_standing := v_derived_class_standing;

    log_to_fnd( p_v_module => 'finpl_get_derived_values',
                p_v_string => 'End of finpl_get_derived_values. Out: Att Type: '|| p_derived_attendance_type
                              || ', Govt Att Mode: ' || p_derived_govt_att_mode
                              || ', Prog Att Mode: ' || p_derived_prog_att_mode
                              || ', Residency Status Cd:' || p_derived_residency_status_cd
                              || ', Class Standing: ' || p_derived_class_standing
                              || ', Unit Set Code: ' || p_derived_unit_set_cd
                              || ', Unit Set Version: ' || p_derived_us_version_num );
    RETURN TRUE;

  END;
EXCEPTION
WHEN OTHERS THEN
  log_to_fnd( p_v_module => 'finpl_get_derived_values',
              p_v_string => 'From Exception Handler of When Others.');
  fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
  fnd_message.set_token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_GET_DERIVED_VALUES-'||SUBSTR(sqlerrm,1,500));
  igs_ge_msg_stack.add;
  app_exception.raise_exception;
END finpl_get_derived_values;


-------------------------------------------------------------------------------
PROCEDURE finpl_find_far(
        p_person_id                             hz_parties.party_id%TYPE,
        p_course_cd                             igs_en_stdnt_ps_att_all.course_cd%TYPE,
        p_fee_cat                               IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE,
        p_fee_cal_type                          igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
        p_fee_ci_sequence_number                igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE,
        p_fee_type                              igs_fi_f_cat_fee_lbl_all.fee_type%TYPE,
        p_location_cd                           igs_en_stdnt_ps_att_all.location_cd%TYPE,
        p_effective_dt                          DATE,
        p_s_fee_trigger_cat                     igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
        p_derived_location_cd                   igs_fi_fee_as_rate.location_cd%TYPE,
        p_derived_attendance_type               igs_fi_fee_as_rate.attendance_type%TYPE,
        p_derived_govt_att_mode                 igs_en_atd_mode_all.govt_attendance_mode%TYPE,
        p_derived_prog_att_mode                 igs_en_atd_mode_all.attendance_mode%TYPE,
        p_trace_on                              VARCHAR2,
        p_derived_residency_status_cd           igs_pe_res_dtls_all.residency_status_cd%TYPE,
        p_derived_org_unit_cd                   igs_ps_unit_ver_all.owner_org_unit_cd%TYPE,
        p_derived_course_cd                     igs_ps_ver_all.course_cd%TYPE,
        p_derived_version_number                igs_ps_ver_all.version_number%TYPE,
        p_derived_class_standing                IGS_PR_CLASS_STD.CLASS_STANDING%TYPE,
        p_charge_rate               OUT NOCOPY  IGS_FI_FEE_AS_RATE.chg_rate%TYPE,
        p_derived_unit_set_cd       IN          igs_fi_fee_as_rate.unit_set_cd%TYPE,
        p_derived_us_version_num    IN          igs_fi_fee_as_rate.us_version_number%TYPE,
        p_derived_unit_type_id      IN          igs_fi_fee_as_items.unit_type_id%TYPE,
        p_derived_unit_class        IN          igs_fi_fee_as_items.unit_class%TYPE,
        p_derived_unit_mode         IN          igs_fi_fee_as_items.unit_mode%TYPE,
        p_derived_unit_cd           IN          igs_fi_fee_as_rate.unit_cd%TYPE,
        p_derived_unit_version_num  IN          igs_fi_fee_as_rate.unit_version_number%TYPE,
        p_derived_unit_level        IN          igs_fi_fee_as_items.unit_level%TYPE
        ) AS
  /***********************************************************************************************
  Change History:
  Who         When            What
  abshriva    23-May-2006     Bug 5204728: Added ORDER BY order_of_precedence in cursor c_ftfarv1 and c_ftfarv2
  pathipat    10-Oct-2005     Bug 4375258 - Change party_number FK to TCA parties impact
                              Replaced usage of igs_fi_gen_008.get_party_number with finpl_get_org_unit_cd
                              for Org derivation
  bannamal    03-JUN-2005     Bug#3442712 Unit Level Fee Assessment Build.
                              Added new parameters for this build.
  shtatiko    27-JUL-2004     Enh# 3795849, Added p_derived_prog_att_mode.
  pathipat    12-Sep-2003     Enh 3108052 - Unit Sets in Rate Table build
                              Added params p_derived_unit_set_cd and p_derived_us_version_num
                              Modified cursor c_ftfarv to include unit_set_cd and us_Version_number
  rnirwani    02-May-02       Bug# 2344901
                              in case no matching record is found then no value is assigned to the out NOCOPY parameter
                              p_charge_rate. This has been modified to assign a zero to this parameter.
  smadathi    02-May-2002     Bug 2261649. The reference to function finp_get_additional_charge removed.
  **********************************************************************************************/
BEGIN
  DECLARE
    v_chg_rate                      igs_fi_fee_as_rate.chg_rate%TYPE;
    v_s_relation_type               igs_fi_fee_as_rate.s_relation_type%TYPE;
    v_location_cd                   igs_fi_fee_as_rate.location_cd%TYPE;
    v_attendance_type               igs_fi_fee_as_rate.attendance_type%TYPE;
    v_attendance_mode               igs_fi_fee_as_rate.attendance_mode%TYPE;
    v_rate_number                   igs_fi_fee_as_rate.rate_number%TYPE;
    v_fee_ass_rate_match            BOOLEAN;
    l_b_fee_ass_rate_found          BOOLEAN;
    v_residency_status_cd           igs_pe_res_dtls_all.residency_status_cd%TYPE;
    v_org_unit_cd                   igs_ps_unit_ver_all.owner_org_unit_cd%TYPE;
    v_course_cd                     igs_fi_fee_as_rate.course_cd%TYPE;
    v_version_number                igs_fi_fee_as_rate.version_number%TYPE;
    v_class_standing                 igs_fi_fee_as_rate.class_standing%TYPE;
    v_unit_set_cd                   igs_fi_fee_as_rate.unit_set_cd%TYPE := NULL;
    v_us_version_number             igs_fi_fee_as_rate.us_version_number%TYPE := NULL;

    CURSOR c_ftfarv1(cp_v_s_relation_type igs_fi_fee_as_rate.s_relation_type%TYPE) IS
    SELECT  far.chg_rate,
            far.s_relation_type,
            far.location_cd,
            far.attendance_type,
            far.attendance_mode,
            far.rate_number,
            far.residency_status_cd,
            far.org_party_id,
            far.course_cd,
            far.version_number,
            far.class_standing,
            far.unit_set_cd,
            far.us_version_number,
            far.unit_type_id,
            far.unit_class,
            far.unit_mode,
            far.unit_cd,
            far.unit_version_number,
            far.unit_level
    FROM igs_fi_fee_as_rate far,
                 igs_fi_f_cat_fee_lbl_all fcfl
    WHERE far.s_relation_type = cp_v_s_relation_type
    AND   far.logical_delete_dt is NULL
    AND   fcfl.fee_cat = far.fee_cat
    AND   fcfl.fee_cal_type = far.fee_cal_type
    AND   fcfl.fee_ci_sequence_number = far.fee_ci_sequence_number
    AND   fcfl.fee_type = far.fee_type
    AND   far.fee_type = p_fee_type
    AND   far.fee_cal_type = p_fee_cal_type
    AND   far.fee_ci_sequence_number = p_fee_ci_sequence_number
    AND   far.fee_cat = p_fee_cat
    ORDER BY far.order_of_precedence ASC;

    CURSOR c_ftfarv2(cp_v_s_relation_type igs_fi_fee_as_rate.s_relation_type%TYPE) IS
    SELECT  far.chg_rate,
            far.s_relation_type,
            far.location_cd,
            far.attendance_type,
            far.attendance_mode,
            far.rate_number,
            far.residency_status_cd,
            far.org_party_id,
            far.course_cd,
            far.version_number,
            far.class_standing,
            far.unit_set_cd,
            far.us_version_number,
            far.unit_type_id,
            far.unit_class,
            far.unit_mode,
            far.unit_cd,
            far.unit_version_number,
            far.unit_level
    FROM   igs_fi_fee_as_rate far,
                   igs_fi_f_cat_fee_lbl_all fcfl
    WHERE  far.s_relation_type = cp_v_s_relation_type
    AND   far.logical_delete_dt is NULL
    AND   fcfl.fee_type = far.fee_type
    AND   fcfl.fee_cal_type = far.fee_cal_type
    AND   fcfl.fee_ci_sequence_number = far.fee_ci_sequence_number
    AND   fcfl.fee_cat = p_fee_cat
    AND   far.fee_type = p_fee_type
    AND   far.fee_cal_type = p_fee_cal_type
    AND   far.fee_ci_sequence_number = p_fee_ci_sequence_number
    AND   (far.fee_cat = p_fee_cat or far.fee_cat is NULL)
    ORDER BY far.order_of_precedence ASC;

    l_c_ftfarv1  c_ftfarv1%ROWTYPE;
    l_b_cursor   BOOLEAN;
    l_v_party_number hz_parties.party_number%TYPE := NULL;
    l_v_level_code   igs_ps_unit_type_lvl.level_code%TYPE;

  BEGIN
    log_to_fnd( p_v_module => 'finpl_find_far',
                p_v_string => 'Entered finpl_find_far. Parameters are: ' ||
                               p_person_id || ', ' || p_course_cd || ', ' || p_fee_cat
                               || ', ' || p_fee_cal_type || ', ' || p_fee_ci_sequence_number
                               || ', ' || p_fee_type || ', ' || p_location_cd || ', ' || TO_CHAR(p_effective_dt, 'DD-MON-YYYY')
                               || ', ' || p_s_fee_trigger_cat
                               || ', ' || p_derived_location_cd || ', ' || p_derived_attendance_type
                               || ', ' || p_derived_govt_att_mode || ', ' || p_derived_prog_att_mode || ', ' || p_trace_on
                               || ', ' || p_derived_residency_status_cd
                               || ', ' || p_derived_org_unit_cd || ', ' || p_derived_course_cd || ', ' || p_derived_version_number
                               || ', ' || p_derived_class_standing || ', ' || p_derived_unit_set_cd
                               || ', ' || p_derived_us_version_num|| ', ' || p_derived_unit_type_id || ', ' || p_derived_unit_class
                               || ', ' || p_derived_unit_mode || ', ' || p_derived_unit_cd || ', ' || p_derived_unit_version_num
                               || ', ' || p_derived_unit_level);

    p_charge_rate := 0;
    v_fee_ass_rate_match := FALSE;
    l_b_fee_ass_rate_found := FALSE;
    l_b_cursor := FALSE;

    FOR v_ftfarv_rec IN c_ftfarv1('FCFL') LOOP
      l_b_cursor := TRUE;
      l_v_party_number := NULL;
      IF v_ftfarv_rec.org_party_id IS NOT NULL THEN
         l_v_party_number := finpl_get_org_unit_cd(v_ftfarv_rec.org_party_id);
      END IF;

      IF v_ftfarv_rec.unit_type_id IS NOT NULL THEN
        l_v_level_code := finpl_get_uptl(v_ftfarv_rec.unit_type_id);
      ELSE
        l_v_level_code := NULL;
      END IF;

      l_b_fee_ass_rate_found := TRUE;
      IF (v_fee_ass_rate_match = TRUE) THEN
        EXIT;
      END IF;

      -- Attempt to match the assessment rate
        -- Perform 2.3.1 Match Charge Rate
        IF (finpl_ins_match_chg_rate(
                  v_ftfarv_rec.location_cd,
                  v_ftfarv_rec.ATTENDANCE_TYPE,
                  v_ftfarv_rec.ATTENDANCE_MODE,
                  v_ftfarv_rec.class_standing,
                  v_ftfarv_rec.course_cd,
                  v_ftfarv_rec.version_number,
                  l_v_party_number,
                  v_ftfarv_rec.residency_status_cd,
                  p_derived_location_cd,
                  p_derived_attendance_type,
                  p_derived_govt_att_mode,
                  p_derived_prog_att_mode,
                  p_derived_class_standing,
                  p_course_cd,
                  p_course_version_number,
                  p_derived_org_unit_cd,
                  p_derived_residency_status_cd,
                  v_ftfarv_rec.unit_set_cd,
                  v_ftfarv_rec.us_version_number,
                  p_derived_unit_set_cd,
                  p_derived_us_version_num,
                  v_ftfarv_rec.unit_type_id,
                  p_derived_unit_type_id,
                  v_ftfarv_rec.unit_class,
                  p_derived_unit_class,
                  v_ftfarv_rec.unit_mode,
                  p_derived_unit_mode,
                  v_ftfarv_rec.unit_cd,
                  p_derived_unit_cd,
                  v_ftfarv_rec.unit_version_number,
                  p_derived_unit_version_num,
                  v_ftfarv_rec.unit_level,
                  p_derived_unit_level
                  ) = TRUE) THEN
          p_charge_rate := v_ftfarv_rec.chg_rate;
          IF (p_trace_on = 'Y') THEN
                      fnd_file.new_line(fnd_file.log);
                      IF (p_derived_unit_cd IS NOT NULL) THEN
                        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'UNIT') || ': ' || p_derived_unit_cd);
                      END IF;
                      fnd_message.set_name('IGS', 'IGS_FI_LEV_CHG_RATE_NO');
                      fnd_message.set_token('LEVEL', v_ftfarv_rec.s_relation_type);
                      fnd_message.set_token('CH_RT', TO_CHAR(v_ftfarv_rec.chg_rate));
                      fnd_message.set_token('RT_NUM', TO_CHAR(v_ftfarv_rec.rate_number));
                      fnd_message.set_token('ATT_TYP', NVL(v_ftfarv_rec.ATTENDANCE_TYPE, l_v_lkp_all));
                      fnd_message.set_token('ATT_MOD', NVL(v_ftfarv_rec.ATTENDANCE_MODE, l_v_lkp_all));
                      fnd_message.set_token('LOC', NVL(v_ftfarv_rec.location_cd, l_v_lkp_all));
                      fnd_message.set_token('RES_STAT', NVL(v_ftfarv_rec.residency_status_cd, l_v_lkp_all));
                      fnd_message.set_token('ORG_UNIT_CD', NVL(l_v_party_number, l_v_lkp_all));
                      fnd_message.set_token('COURSE_CD', NVL(v_ftfarv_rec.course_cd, l_v_lkp_all));
                      fnd_message.set_token('VERSION', NVL(TO_CHAR(v_ftfarv_rec.version_number), l_v_lkp_all));
                      fnd_message.set_token('CLAS_STNDNG', NVL(v_ftfarv_rec.class_standing, l_v_lkp_all));
                      fnd_message.set_token('UNIT_SET_CD', NVL(v_ftfarv_rec.unit_set_cd, l_v_lkp_all));
                      fnd_message.set_token('US_VER', NVL(TO_CHAR(v_ftfarv_rec.us_version_number), l_v_lkp_all));
                      fnd_message.set_token('UNIT_TYP_CD', NVL(l_v_level_code, l_v_lkp_all));
                      fnd_message.set_token('UNIT_CLASS', NVL(v_ftfarv_rec.unit_class, l_v_lkp_all));
                      fnd_message.set_token('UNIT_MODE', NVL(v_ftfarv_rec.unit_mode, l_v_lkp_all));
                      fnd_message.set_token('UNIT_CODE', NVL(v_ftfarv_rec.unit_cd, l_v_lkp_all));
                      fnd_message.set_token('UNIT_VER_NUM', NVL(TO_CHAR(v_ftfarv_rec.unit_version_number), l_v_lkp_all));
                      fnd_message.set_token('UNIT_LEVEL', NVL(v_ftfarv_rec.unit_level, l_v_lkp_all));
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                      fnd_message.set_name('IGS', 'IGS_FI_FEEASS_RATE_MATCHES');
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                      fnd_file.new_line(fnd_file.log);
          END IF;
          -- stop processing Rate Records
          log_to_fnd( p_v_module => 'finpl_find_far',
                      p_v_string => 'Rate Matched: ' || p_charge_rate );
          v_fee_ass_rate_match := TRUE;

        ELSE -- Not Matched
          -- Process next rate record
          NULL;
        END IF; -- finpl_ins_match_chg_rate
    END LOOP;

    IF l_b_cursor = FALSE THEN
            FOR v_ftfarv_rec IN c_ftfarv2('FTCI') LOOP
              l_v_party_number := NULL;
              IF v_ftfarv_rec.org_party_id IS NOT NULL THEN
                  l_v_party_number := finpl_get_org_unit_cd(v_ftfarv_rec.org_party_id);
              END IF;
              IF v_ftfarv_rec.unit_type_id IS NOT NULL THEN
                  l_v_level_code := finpl_get_uptl(v_ftfarv_rec.unit_type_id);
              ELSE
                  l_v_level_code := NULL;
              END IF;
              l_b_fee_ass_rate_found := TRUE;
              IF (v_fee_ass_rate_match = TRUE) THEN
                EXIT;
              END IF;

              -- Attempt to match the assessment rate
                -- Perform 2.3.1 Match Charge Rate
                IF (finpl_ins_match_chg_rate(
                          v_ftfarv_rec.location_cd,
                          v_ftfarv_rec.ATTENDANCE_TYPE,
                          v_ftfarv_rec.ATTENDANCE_MODE,
                          v_ftfarv_rec.class_standing,
                          v_ftfarv_rec.course_cd,
                          v_ftfarv_rec.version_number,
                          l_v_party_number,
                          v_ftfarv_rec.residency_status_cd,
                          p_derived_location_cd,
                          p_derived_attendance_type,
                          p_derived_govt_att_mode,
                          p_derived_prog_att_mode,
                          p_derived_class_standing,
                          p_course_cd,
                          p_course_version_number,
                          p_derived_org_unit_cd,
                          p_derived_residency_status_cd,
                          v_ftfarv_rec.unit_set_cd,
                          v_ftfarv_rec.us_version_number,
                          p_derived_unit_set_cd,
                          p_derived_us_version_num,
                          v_ftfarv_rec.unit_type_id,
                          p_derived_unit_type_id,
                          v_ftfarv_rec.unit_class,
                          p_derived_unit_class,
                          v_ftfarv_rec.unit_mode,
                          p_derived_unit_mode,
                          v_ftfarv_rec.unit_cd,
                          p_derived_unit_cd,
                          v_ftfarv_rec.unit_version_number,
                          p_derived_unit_version_num,
                          v_ftfarv_rec.unit_level,
                          p_derived_unit_level
                          ) = TRUE) THEN
                  p_charge_rate := v_ftfarv_rec.chg_rate;
                  IF (p_trace_on = 'Y') THEN
                      fnd_file.new_line(fnd_file.log);
                      IF (p_derived_unit_cd IS NOT NULL) THEN
                        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'UNIT') || ': ' || p_derived_unit_cd);
                      END IF;
                      fnd_message.set_name('IGS', 'IGS_FI_LEV_CHG_RATE_NO');
                      fnd_message.set_token('LEVEL', v_ftfarv_rec.s_relation_type);
                      fnd_message.set_token('CH_RT', TO_CHAR(v_ftfarv_rec.chg_rate));
                      fnd_message.set_token('RT_NUM', TO_CHAR(v_ftfarv_rec.rate_number));
                      fnd_message.set_token('ATT_TYP', NVL(v_ftfarv_rec.ATTENDANCE_TYPE, l_v_lkp_all));
                      fnd_message.set_token('ATT_MOD', NVL(v_ftfarv_rec.ATTENDANCE_MODE, l_v_lkp_all));
                      fnd_message.set_token('LOC', NVL(v_ftfarv_rec.location_cd, l_v_lkp_all));
                      fnd_message.set_token('RES_STAT', NVL(v_ftfarv_rec.residency_status_cd, l_v_lkp_all));
                      fnd_message.set_token('ORG_UNIT_CD', NVL(l_v_party_number, l_v_lkp_all));
                      fnd_message.set_token('COURSE_CD', NVL(v_ftfarv_rec.course_cd, l_v_lkp_all));
                      fnd_message.set_token('VERSION', NVL(TO_CHAR(v_ftfarv_rec.version_number), l_v_lkp_all));
                      fnd_message.set_token('CLAS_STNDNG', NVL(v_ftfarv_rec.class_standing, l_v_lkp_all));
                      fnd_message.set_token('UNIT_SET_CD', NVL(v_ftfarv_rec.unit_set_cd, l_v_lkp_all));
                      fnd_message.set_token('US_VER', NVL(TO_CHAR(v_ftfarv_rec.us_version_number), l_v_lkp_all));
                      fnd_message.set_token('UNIT_TYP_CD', NVL(l_v_level_code, l_v_lkp_all));
                      fnd_message.set_token('UNIT_CLASS', NVL(v_ftfarv_rec.unit_class, l_v_lkp_all));
                      fnd_message.set_token('UNIT_MODE', NVL(v_ftfarv_rec.unit_mode, l_v_lkp_all));
                      fnd_message.set_token('UNIT_CODE', NVL(v_ftfarv_rec.unit_cd, l_v_lkp_all));
                      fnd_message.set_token('UNIT_VER_NUM', NVL(TO_CHAR(v_ftfarv_rec.unit_version_number), l_v_lkp_all));
                      fnd_message.set_token('UNIT_LEVEL', NVL(v_ftfarv_rec.unit_level, l_v_lkp_all));
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                      fnd_message.set_name('IGS', 'IGS_FI_FEEASS_RATE_MATCHES');
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  -- stop processing Rate Records
                  log_to_fnd( p_v_module => 'finpl_find_far',
                              p_v_string => 'Rate Matched: ' || p_charge_rate );
                  v_fee_ass_rate_match := TRUE;

                ELSE -- Not Matched
                  -- Process next rate record
                  NULL;
                END IF; -- finpl_ins_match_chg_rate
            END LOOP;
    END IF;

    -- If there are no rates defined, return with charge rate of 0.
    IF l_b_fee_ass_rate_found = FALSE THEN
      log_to_fnd( p_v_module => 'finpl_find_far',
                  p_v_string => 'No Rate record found. Returning with 0 rate.');
      p_charge_rate := 0;
      IF (p_trace_on = 'Y') THEN
        fnd_file.new_line(fnd_file.log);
        IF (p_derived_unit_cd IS NOT NULL) THEN
            fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'UNIT') || ': ' || p_derived_unit_cd);
        END IF;
        fnd_message.set_name ( 'IGS', 'IGS_FI_FEEASS_RATE_FOUND');
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
        fnd_message.set_token('RATE', '0');
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log);
      END IF;
    END IF;

    IF (l_b_fee_ass_rate_found = TRUE AND v_fee_ass_rate_match = FALSE) THEN
      -- In case no matching record found then charge rate is set as zero.
      log_to_fnd( p_v_module => 'finpl_find_far',
                  p_v_string => 'No Rate Matched. Returning with 0 rate.');
      p_charge_rate := 0;
      -- fee ass rate records existed, but none matched
      IF (p_trace_on = 'Y') THEN
        fnd_file.new_line(fnd_file.log);
        IF (p_derived_unit_cd IS NOT NULL) THEN
            fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'UNIT') || ': ' || p_derived_unit_cd);
        END IF;
        fnd_message.set_name('IGS', 'IGS_FI_FEEASS_RATE_EXISTS');
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
        fnd_message.set_token('RATE', '0');
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log);
      END IF;
    END IF;

    log_to_fnd( p_v_module => 'finpl_find_far',
                p_v_string => 'End of finpl_find_far. Out: Rate: ' || p_charge_rate );
  END;
  EXCEPTION
     WHEN OTHERS THEN
        log_to_fnd( p_v_module => 'finpl_find_far',
                    p_v_string => 'From exception handler of When Others.');
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_FIND_FAR-'||SUBSTR(sqlerrm,1,500));
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END finpl_find_far;

PROCEDURE finpl_prc_element_ranges (p_n_person_id                IN  NUMBER,
                               p_v_fee_cat                  IN  VARCHAR2,
                               p_v_fee_type                 IN  VARCHAR2,
                               p_v_fee_cal_type             IN  VARCHAR2,
                               p_n_fee_ci_sequence_num      IN  NUMBER,
                               p_v_fee_trigger_cat          IN  VARCHAR2,
                               p_n_rul_sequence_num         IN  NUMBER,
                               p_v_der_course_cd            IN  VARCHAR2,
                               p_n_der_crs_version_num      IN  NUMBER,
                               p_v_der_location_cd          IN  VARCHAR2,
                               p_v_der_attendance_type      IN  VARCHAR2,
                               p_v_der_govt_att_mode        IN  VARCHAR2,
                               p_v_der_prog_att_mode        IN  VARCHAR2,
                               p_v_der_class_standing       IN  VARCHAR2,
                               p_v_der_org_unit_cd          IN  VARCHAR2,
                               p_v_der_residency_status_cd  IN  VARCHAR2,
                               p_v_der_unit_set_cd          IN  VARCHAR2,
                               p_n_der_us_version_num       IN  NUMBER,
                               p_v_fee_description          IN  VARCHAR2,
                               p_v_elm_rng_order_name       IN  VARCHAR2,
                               p_n_chg_elements             IN  NUMBER,
                               p_n_fee_amount               OUT NOCOPY NUMBER,
                               p_n_charge_rate              OUT NOCOPY NUMBER,
                               p_t_fee_as_items             IN OUT NOCOPY t_fee_as_items_typ,
                               p_v_trace_on                 IN VARCHAR2,
                               p_n_element_cap              IN NUMBER,
                               p_n_called                   IN NUMBER ) AS

 /*************************************************************
 Created By :      Bhaskar Annamalai
 Date Created By : 20-JUN-2005
 Purpose :  For processing element ranges.

 Know limitations, enhancements or remarks

 Change History
 Who         When            What
 pathipat    10-Oct-2005     Bug 4375258 - Change party_number FK to TCA parties impact
                             Replaced usage of igs_fi_gen_008.get_party_number with finpl_get_org_unit_cd
                             for Org derivation
 ***************************************************************/


l_n_record_found  NUMBER;                        /* Used to check whether global element ranges are defined or not*/
l_n_sub_rec_found NUMBER;                        /* Used to check whether sub ranges are defined or not*/
l_n_match_elm_rng NUMBER;                        /* Used to check whether global element range matches*/
l_n_charge_rate igs_fi_fee_as_rate.chg_rate%TYPE;
l_b_rate_matched BOOLEAN;                        /* To check whether rate matches*/
l_v_fee_category igs_fi_f_cat_ca_inst.fee_cat%TYPE;
l_v_derived_location_cd  igs_fi_fee_as_rate.location_cd%TYPE;
l_b_elm_range_rate_match BOOLEAN := FALSE;       /* To check whether global element range rate matches or not*/

-- Cursor to find all Global Element ranges defined for the input parameter combination.
CURSOR c_elm_ranges ( cp_v_fee_type       igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                      cp_v_fee_cal_type   igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                      cp_n_ci_seq_number  igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE,
                      cp_v_fee_cat        igs_fi_fee_cat_all.fee_cat%TYPE ) IS
  SELECT er_id,
         s_relation_type,
         range_number,
         lower_range,
         upper_range,
         s_chg_method_type override_chg_method_type -- Override charge method at element range level
  FROM igs_fi_elm_range
  WHERE fee_type = cp_v_fee_type
  AND fee_cal_Type = cp_v_fee_cal_type
  AND fee_ci_sequence_number = cp_n_ci_seq_number
  AND (fee_cat IS NULL OR fee_cat = cp_v_fee_cat)
  AND logical_delete_dt IS NULL
  ORDER BY lower_range ASC;

-- Cursor to find all rates defined under element range found in above cursor.
  CURSOR c_elm_rng_rates ( cp_v_fee_type       igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                           cp_v_fee_cal_type   igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                           cp_n_ci_seq_number  igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE,
                           cp_v_fee_cat        igs_fi_fee_cat_all.fee_cat%TYPE,
                           cp_n_range_number   igs_fi_elm_range.range_number%TYPE,
                           cp_v_relation_type  igs_fi_elm_range.s_relation_type%TYPE) IS
   SELECT far.*
   FROM igs_fi_elm_range_rt err,
        igs_fi_fee_as_rate far
   WHERE far.fee_type = err.fee_type
   AND far.fee_cal_type = err.fee_cal_type
   AND far.fee_ci_sequence_number = err.fee_ci_sequence_number
   AND far.rate_number = err.rate_number
   AND far.s_relation_type = err.s_relation_type
   AND (far.fee_cat = err.fee_cat OR (far.fee_cat IS NULL AND err.fee_cat IS NULL))
   AND err.fee_type = cp_v_fee_type
   AND err.fee_cal_type = cp_v_fee_cal_type
   AND err.fee_ci_sequence_number = cp_n_ci_seq_number
   AND (err.fee_cat IS NULL OR err.fee_cat = cp_v_fee_cat)
   AND err.range_number = cp_n_range_number
   AND err.s_relation_type = cp_v_relation_type  -- just to be sure that Elm Ranges and Elm Range Rates are picked up from same level and so redundant.
   AND err.logical_delete_dt IS NULL
   AND far.logical_delete_dt IS NULL
   ORDER BY far.order_of_precedence ASC;

-- Cursor to find all Sub Element ranges defined for the input parameter
CURSOR cur_sub_elm_ranges (cp_n_er_id  igs_fi_elm_range.er_id%TYPE) IS
SELECT *
FROM igs_fi_sub_elm_rng
WHERE er_id = cp_n_er_id
ORDER BY sub_lower_range;

-- Cursor to find all rates defined under sub element range found in above cursor.
CURSOR cur_sub_elm_rng_rates (cp_n_sub_er_id  igs_fi_sub_er_rt.sub_er_id%TYPE) IS
SELECT far.*
FROM igs_fi_sub_er_rt ser,
             igs_fi_fee_as_rate far
WHERE ser.sub_er_id = cp_n_sub_er_id
AND far.far_id = ser.far_id
AND ser.logical_delete_date IS NULL
AND far.logical_delete_dt IS NULL
ORDER BY far.order_of_precedence;

 -- To find the organization unit code from the Prgoram Version Table (For Charge Method of
 -- FLATRATE)
 CURSOR c_resp_org_unit_cd(cp_course_cd IN igs_ps_ver_all.course_cd%TYPE,
                           cp_version_number IN igs_ps_ver_all.version_number%TYPE
                          )IS
 SELECT responsible_org_unit_cd
 FROM   igs_ps_ver_all v
 WHERE  v.course_cd            = cp_course_cd
 AND    v.version_number       = cp_version_number;

 CURSOR cur_get_ret_level (cp_v_fee_type              igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                            cp_v_fee_cal_type          igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                             cp_n_fee_ci_sequence_num   igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE) IS
   SELECT retention_level_code
   FROM  igs_fi_f_typ_ca_inst_all
   WHERE fee_type               = cp_v_fee_type
   AND   fee_cal_type           = cp_v_fee_cal_type
   AND   fee_ci_sequence_number = cp_n_fee_ci_sequence_num;

l_v_derived_org_unit_cd        igs_ps_ver_all.responsible_org_unit_cd%TYPE;
l_rec_sub_rates                cur_sub_elm_rng_rates%ROWTYPE;
l_rec_global_rates             c_elm_rng_rates%ROWTYPE;
l_n_count                      NUMBER;   -- Used like an index variable when a new record in added to the plsql table tbl_fai_unit_dtls
l_v_party_number               hz_parties.party_number%TYPE := NULL;
l_n_loop_subelm_rng            NUMBER;
l_n_previous_upper             igs_fi_sub_elm_rng.sub_upper_range%TYPE;
l_v_lower_nrml_rate_ovrd_ind   IGS_FI_FEE_AS_RT.lower_nrml_rate_ovrd_ind%TYPE;
l_n_cfar_chg_rate              IGS_FI_FEE_AS_RT.chg_rate%TYPE;
lv_cntrct_rt_apply             BOOLEAN;
l_n_summed_chg_elm             igs_fi_fee_as_items.chg_elements%TYPE;
l_n_rate_factor                igs_fi_fee_as_items.chg_elements%TYPE;
l_b_flag                       BOOLEAN;
l_b_first_rate_match           BOOLEAN;
l_v_ret_level                  igs_fi_f_typ_ca_inst_all.retention_level_code%TYPE;
l_v_level_code                 igs_ps_unit_type_lvl.level_code%TYPE;

BEGIN

  l_n_record_found  := 0;
  l_n_match_elm_rng := 0;
  l_n_sub_rec_found := 0;
  p_n_fee_amount   := 0;
  l_n_loop_subelm_rng := 0;
  l_b_first_rate_match := FALSE;

  log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
              p_v_string => 'Entered finpl_prc_element_ranges. ');

  l_n_summed_chg_elm := p_n_chg_elements;

  OPEN cur_get_ret_level(p_v_fee_type, p_v_fee_cal_type, p_n_fee_ci_sequence_num);
  FETCH cur_get_ret_level INTO l_v_ret_level;
  CLOSE cur_get_ret_level;

  FOR rec_elm_ranges IN c_elm_ranges( p_v_fee_type,
                                   p_v_fee_cal_type,
                                   p_n_fee_ci_sequence_num,
                                   p_v_fee_cat)
  LOOP
    l_n_record_found := 1;
    IF ((rec_elm_ranges.lower_range IS NULL OR l_n_summed_chg_elm >= rec_elm_ranges.lower_range)
         AND (rec_elm_ranges.upper_range IS NULL OR l_n_summed_chg_elm <= rec_elm_ranges.upper_range)) THEN
    --Global Element range matched
      log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                  p_v_string => 'Global Element Range applies. Lower ' || rec_elm_ranges.lower_range || ', Upper: ' || rec_elm_ranges.upper_range);
      -- Global Element Range Applies
      IF (p_v_trace_on = 'Y') THEN
         fnd_file.new_line(fnd_file.log);
         fnd_message.set_name ( 'IGS', 'IGS_FI_ELE_RANGE_APPLIES');
         fnd_file.put_line (fnd_file.log, fnd_message.get);
         fnd_message.set_name('IGS', 'IGS_FI_TESTING_ELEMENT_RANGE');
         fnd_message.set_token('ELM_RNG_NUM', TO_CHAR(rec_elm_ranges.range_number));
         fnd_file.put_line (fnd_file.log, fnd_message.get);
         fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'LOW_RANGE') || ': ' || TO_CHAR(rec_elm_ranges.lower_range));
         fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'UPPER_RANGE') || ': ' || TO_CHAR(rec_elm_ranges.upper_range));
         IF (rec_elm_ranges.override_chg_method_type IS NOT NULL) THEN
            fnd_message.set_name('IGS', 'IGS_FI_OVRRIDE_CHG_METH_TYPE');
            fnd_message.set_token('CHG_MTHD', igs_fi_gen_gl.get_lkp_meaning('CHG_METHOD', rec_elm_ranges.override_chg_method_type));
            fnd_file.put_line (fnd_file.log, fnd_message.get);
         END IF;
      END IF;

      IF p_v_elm_rng_order_name IS NOT NULL THEN
        log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                    p_v_string => 'Calling finpl_sort_table to sort the record in the plsql table');
        finpl_sort_table( p_t_fee_as_items, p_v_elm_rng_order_name);
      END IF;

      l_n_match_elm_rng := 1;
      IF (rec_elm_ranges.override_chg_method_type = gcst_flatrate) THEN
        l_n_rate_factor := 1;
        OPEN c_elm_rng_rates ( p_v_fee_type,
                               p_v_fee_cal_type,
                               p_n_fee_ci_sequence_num,
                               p_v_fee_cat,
                               rec_elm_ranges.range_number,
                               rec_elm_ranges.s_relation_type);
        FETCH c_elm_rng_rates INTO l_rec_global_rates;
        IF (c_elm_rng_rates%NOTFOUND) THEN

          CLOSE c_elm_rng_rates;
          --Rate records not found
          IF (p_v_trace_on = 'Y') THEN
              fnd_message.set_name('IGS', 'IGS_FI_GLBELM_NO_RATE');
              fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          p_n_charge_rate := 0;
          p_n_fee_amount  := 0;
         log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                     p_v_string => 'Returning from the procedure since there are no active rates.');
          RETURN;
        ELSE
          CLOSE c_elm_rng_rates;

          IF ((g_c_fee_calc_mthd = g_v_primary_career) OR
                  ((g_c_fee_calc_mthd <> g_v_primary_career) AND (p_v_fee_trigger_cat <> 'INSTITUTN'))) THEN

              OPEN c_resp_org_unit_cd(p_v_der_course_cd, p_n_der_crs_version_num);
              FETCH c_resp_org_unit_cd INTO l_v_derived_org_unit_cd;
              CLOSE c_resp_org_unit_cd;
              l_v_derived_location_cd := p_v_der_location_cd;
              l_v_fee_category := p_v_fee_cat;

          ELSE --If fee calculation method is not primary career and fee trigger category is Institution
              l_v_derived_org_unit_cd := NULL;
              l_v_derived_location_cd := NULL;
              l_v_fee_category := NULL;
          END IF;

          OPEN c_elm_rng_rates ( p_v_fee_type,
                            p_v_fee_cal_type,
                            p_n_fee_ci_sequence_num,
                            p_v_fee_cat,
                            rec_elm_ranges.range_number,
                            rec_elm_ranges.s_relation_type);
          FETCH c_elm_rng_rates INTO l_rec_global_rates;

          l_b_elm_range_rate_match := FALSE;

          WHILE (c_elm_rng_rates%FOUND)
          LOOP
              IF (l_rec_global_rates.org_party_id IS NOT NULL) THEN
                l_v_party_number := finpl_get_org_unit_cd(l_rec_global_rates.org_party_id);
              ELSE
                l_v_party_number := NULL;
              END IF;
              log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                          p_v_string => 'Calling finpl_ins_match_chg_rate');
              IF ( finpl_ins_match_chg_rate(
                                   l_rec_global_rates.location_cd,
                                   l_rec_global_rates.attendance_type,
                                   l_rec_global_rates.attendance_mode,
                                   l_rec_global_rates.class_standing,
                                   l_rec_global_rates.course_cd,
                                   l_rec_global_rates.version_number,
                                   l_v_party_number,
                                   l_rec_global_rates.residency_status_cd,
                                   l_v_derived_location_cd,
                                   p_v_der_attendance_type,
                                   p_v_der_govt_att_mode,
                                   p_v_der_prog_att_mode,
                                   p_v_der_class_standing,
                                   p_v_der_course_cd,
                                   p_n_der_crs_version_num,
                                   l_v_derived_org_unit_cd,
                                   p_v_der_residency_status_cd,
                                   l_rec_global_rates.unit_set_cd,
                                   l_rec_global_rates.us_version_number,
                                   p_v_der_unit_set_cd,
                                   p_n_der_us_version_num,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL ) = TRUE ) THEN

                   log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                               p_v_string => 'Global Element Range rate matches');
                   IF (p_v_trace_on = 'Y') THEN
                     fnd_file.new_line(fnd_file.log);
                     fnd_message.set_name('IGS', 'IGS_FI_LEV_CHG_RATE_NO');
                     fnd_message.set_token('LEVEL', l_rec_global_rates.s_relation_type);
                     fnd_message.set_token('CH_RT', TO_CHAR(l_rec_global_rates.chg_rate));
                     fnd_message.set_token('RT_NUM', TO_CHAR(l_rec_global_rates.rate_number));
                     fnd_message.set_token('ATT_TYP', NVL(l_rec_global_rates.ATTENDANCE_TYPE, l_v_lkp_all));
                     fnd_message.set_token('ATT_MOD', NVL(l_rec_global_rates.ATTENDANCE_MODE, l_v_lkp_all));
                     fnd_message.set_token('LOC', NVL(l_rec_global_rates.location_cd, l_v_lkp_all));
                     fnd_message.set_token('RES_STAT', NVL(l_rec_global_rates.residency_status_cd, l_v_lkp_all));
                     fnd_message.set_token('ORG_UNIT_CD', NVL(l_v_party_number, l_v_lkp_all));
                     fnd_message.set_token('COURSE_CD', NVL(l_rec_global_rates.course_cd, l_v_lkp_all));
                     fnd_message.set_token('VERSION', NVL(TO_CHAR(l_rec_global_rates.version_number), l_v_lkp_all));
                     fnd_message.set_token('CLAS_STNDNG', NVL(l_rec_global_rates.class_standing, l_v_lkp_all));
                     fnd_message.set_token('UNIT_SET_CD', NVL(l_rec_global_rates.unit_set_cd, l_v_lkp_all));
                     fnd_message.set_token('US_VER', NVL(TO_CHAR(l_rec_global_rates.us_version_number), l_v_lkp_all));
                     fnd_message.set_token('UNIT_TYP_CD', NVL(TO_CHAR(l_rec_global_rates.unit_type_id), l_v_lkp_all));
                     fnd_message.set_token('UNIT_CLASS', NVL(l_rec_global_rates.unit_class, l_v_lkp_all));
                     fnd_message.set_token('UNIT_MODE', NVL(l_rec_global_rates.unit_mode, l_v_lkp_all));
                     fnd_message.set_token('UNIT_CODE', NVL(l_rec_global_rates.unit_cd, l_v_lkp_all));
                     fnd_message.set_token('UNIT_VER_NUM', NVL(TO_CHAR(l_rec_global_rates.unit_version_number), l_v_lkp_all));
                     fnd_message.set_token('UNIT_LEVEL', NVL(l_rec_global_rates.unit_level, l_v_lkp_all));
                     fnd_file.put_line (fnd_file.log, fnd_message.get);
                     fnd_message.set_name('IGS', 'IGS_FI_FEEASS_RATE_MATCHES');
                     fnd_file.put_line (fnd_file.log, fnd_message.get);
                     fnd_file.new_line(fnd_file.log);
                   END IF;

                   l_b_elm_range_rate_match := TRUE;
                   p_n_charge_rate := l_rec_global_rates.chg_rate;
                   EXIT;
              END IF;
          FETCH c_elm_rng_rates INTO l_rec_global_rates;
          END LOOP;
          CLOSE c_elm_rng_rates;

          --If rate is not matched
          IF (NOT l_b_elm_range_rate_match) THEN
              log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                          p_v_string => 'No Rate Matched. Returning with 0 rate.');
              p_n_charge_rate := 0;
              p_n_fee_amount  := 0;
              IF (p_v_trace_on = 'Y') THEN
                fnd_file.new_line(fnd_file.log);
                fnd_message.set_name ( 'IGS', 'IGS_FI_NO_ELM_RNG_RATE_MATCH');
                fnd_file.put_line (fnd_file.log, fnd_message.get);
                fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
                fnd_message.set_token('RATE', TO_CHAR(p_n_charge_rate) );
                fnd_file.put_line (fnd_file.log, fnd_message.get);
                fnd_file.new_line(fnd_file.log);
              END IF;
              RETURN;
          END IF;

          OPEN c_cfar (l_v_derived_location_cd, p_v_der_attendance_type, p_v_der_prog_att_mode, p_v_der_govt_att_mode);
          FETCH c_cfar INTO       l_v_lower_nrml_rate_ovrd_ind,
                                  l_n_cfar_chg_rate;

          IF (c_cfar%FOUND) THEN
            log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                        p_v_string => 'l_n_cfar_chg_rate: ' || l_n_cfar_chg_rate || ', l_v_lower_nrml_rate_ovrd_ind: ' || l_v_lower_nrml_rate_ovrd_ind);
            IF (l_v_lower_nrml_rate_ovrd_ind = 'Y') THEN
              -- the normal rate is used when it
              -- is lower than the contract rate
              IF (p_n_charge_rate > l_n_cfar_chg_rate) THEN
                IF (p_trace_on = 'Y') THEN
                  fnd_message.set_name('IGS', 'IGS_FI_CONTRACT_RATE');
                  fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_cfar_chg_rate, 0)) );
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                  fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
                  fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_charge_rate, 0)) );
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                END IF;
                lv_cntrct_rt_apply := TRUE;
                p_n_charge_rate := l_n_cfar_chg_rate;
                log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                            p_v_string => 'The contract rate is lower than the charge rate, so the contract rate will be used. Chg Rate: ' || l_n_charge_rate);
              END IF;
            ELSE
              -- Use the contract rate
              lv_cntrct_rt_apply := TRUE;
              p_n_charge_rate := l_n_cfar_chg_rate;
              IF (p_trace_on = 'Y') THEN
                fnd_message.set_name('IGS', 'IGS_FI_CONTRACT_RATE');
                fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_charge_rate, 0)) );
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;
              log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                          p_v_string => 'The contract rate will be used. Chg Rate: ' || l_n_charge_rate);
            END IF;

          ELSE
            log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                        p_v_string => 'No Contract Rate Found ..');
          END IF;
          -- attempt to find a second contract rate - only one record should be found
          FETCH c_cfar INTO l_v_lower_nrml_rate_ovrd_ind,
                            l_n_cfar_chg_rate;
          IF (c_cfar%FOUND) THEN
            CLOSE c_cfar;
            IF g_v_wav_calc_flag = 'N' THEN
              ROLLBACK TO fee_calc_sp;
            END IF;

            IF (p_trace_on = 'Y') THEN
                fnd_message.set_name('IGS', 'IGS_FI_MULTI_CONTRACT_RT');
                fnd_file.put_line (fnd_file.log, fnd_message.get);
            END IF;
            log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                        p_v_string => 'Raising e_one_record_expected.');
            RAISE e_one_record_expected;
          END IF;
          CLOSE c_cfar;

          p_n_fee_amount := igs_ru_gen_003.rulp_clc_student_fee( p_n_rul_sequence_num,
                                                                 NVL(l_n_rate_factor,0),
                                                                 NVL(p_n_charge_rate,0) );

          l_b_flag := FALSE;

          IF (p_n_called <> 1) THEN
             IF (p_v_fee_trigger_cat <> gcst_institutn) THEN
                tbl_fai_unit_dtls.DELETE;
             END IF;

             FOR i IN 1..p_t_fee_as_items.COUNT
             LOOP
               IF (p_v_fee_trigger_cat <> gcst_institutn AND l_v_ret_level = 'TEACH_PERIOD' AND g_c_predictive_ind = 'N') THEN
                  IF (p_t_fee_as_items(i).uoo_id IS NOT NULL AND NVL(p_t_fee_as_items(i).chg_elements,0) > 0) THEN
                    l_n_count := tbl_fai_unit_dtls.COUNT + 1;
                    tbl_fai_unit_dtls(l_n_count).fee_cat             :=  p_v_fee_cat;
                    tbl_fai_unit_dtls(l_n_count).course_cd           :=  p_v_der_course_cd;
                    tbl_fai_unit_dtls(l_n_count).crs_version_number  :=  p_n_der_crs_version_num;
                    tbl_fai_unit_dtls(l_n_count).unit_attempt_status :=  p_t_fee_as_items(i).unit_attempt_status;
                    tbl_fai_unit_dtls(l_n_count).org_unit_cd         :=  p_t_fee_as_items(i).org_unit_cd;
                    tbl_fai_unit_dtls(l_n_count).class_standing      :=  p_v_der_class_standing;
                    tbl_fai_unit_dtls(l_n_count).location_cd         :=  p_t_fee_as_items(i).location_cd;
                    tbl_fai_unit_dtls(l_n_count).uoo_id              :=  p_t_fee_as_items(i).uoo_id;
                    tbl_fai_unit_dtls(l_n_count).unit_set_cd         :=  p_v_der_unit_set_cd;
                    tbl_fai_unit_dtls(l_n_count).us_version_number   :=  p_n_der_us_version_num;
                    tbl_fai_unit_dtls(l_n_count).chg_elements        :=  p_t_fee_as_items(i).chg_elements;
                    tbl_fai_unit_dtls(l_n_count).unit_type_id        :=  p_t_fee_as_items(i).unit_type_id;
                    tbl_fai_unit_dtls(l_n_count).unit_class          :=  p_t_fee_as_items(i).unit_class;
                    tbl_fai_unit_dtls(l_n_count).unit_mode           :=  p_t_fee_as_items(i).unit_mode;
                    tbl_fai_unit_dtls(l_n_count).unit_cd             :=  p_t_fee_as_items(i).unit_cd;
                    tbl_fai_unit_dtls(l_n_count).unit_level          :=  p_t_fee_as_items(i).unit_level;
                    tbl_fai_unit_dtls(l_n_count).unit_version_number :=  p_t_fee_as_items(i).unit_version_number;
                  END IF;
               END IF;
               IF t_fee_as_items(i).chg_elements >= 0 AND
                     t_fee_as_items(i).uoo_id IS NULL AND
                     t_fee_as_items(i).old_amount > 0 THEN
                          p_t_fee_as_items(i).chg_elements := 1;
                          p_t_fee_as_items(i).amount := p_n_fee_amount;

                 l_b_flag := TRUE;

               ELSE
                 p_t_fee_as_items(i).amount := 0;
               END IF;

             END LOOP;

             IF (l_b_flag = FALSE) THEN

                gv_as_item_cntr := nvl(gv_as_item_cntr,0) + 1;
                -- Insert a new record in the IGS_FI_FEE_AS_ITEMS table
                p_t_fee_as_items(gv_as_item_cntr).person_id               := p_n_person_id;
                p_t_fee_as_items(gv_as_item_cntr).status                  := 'O';
                p_t_fee_as_items(gv_as_item_cntr).fee_type                := p_v_fee_type;
                p_t_fee_as_items(gv_as_item_cntr).fee_cat                 := l_v_fee_category;
                p_t_fee_as_items(gv_as_item_cntr).fee_cal_type            := p_v_fee_cal_type;
                p_t_fee_as_items(gv_as_item_cntr).fee_ci_sequence_number  := p_n_fee_ci_sequence_num;
                p_t_fee_as_items(gv_as_item_cntr).course_cd               := p_v_der_course_cd;
                p_t_fee_as_items(gv_as_item_cntr).crs_version_number      := l_n_crs_version_num;
                p_t_fee_as_items(gv_as_item_cntr).description             := p_v_fee_description;
                p_t_fee_as_items(gv_as_item_cntr).chg_method_type         := gcst_flatrate;
                p_t_fee_as_items(gv_as_item_cntr).old_chg_elements        := 0;
                p_t_fee_as_items(gv_as_item_cntr).chg_elements            := NVL(l_n_rate_factor,0);
                p_t_fee_as_items(gv_as_item_cntr).old_amount              := 0;
                p_t_fee_as_items(gv_as_item_cntr).amount                  := NVL(p_n_fee_amount,0);
                p_t_fee_as_items(gv_as_item_cntr).unit_attempt_status     := null;
                p_t_fee_as_items(gv_as_item_cntr).location_cd             := l_v_derived_location_cd;
                p_t_fee_as_items(gv_as_item_cntr).old_eftsu               := NULL;
                p_t_fee_as_items(gv_as_item_cntr).eftsu                   := NULL;
                p_t_fee_as_items(gv_as_item_cntr).old_credit_points       := NULL;
                p_t_fee_as_items(gv_as_item_cntr).credit_points           := NULL;
                p_t_fee_as_items(gv_as_item_cntr).org_unit_cd             := l_v_derived_org_unit_cd;
                p_t_fee_as_items(gv_as_item_cntr).uoo_id                  := NULL;
                p_t_fee_as_items(gv_as_item_cntr).chg_rate                := NVL(p_n_charge_rate,0);
                p_t_fee_as_items(gv_as_item_cntr).rul_sequence_number     := p_n_rul_sequence_num;
                p_t_fee_as_items(gv_as_item_cntr).unit_set_cd             := p_v_der_unit_set_cd;
                p_t_fee_as_items(gv_as_item_cntr).us_version_number       := p_n_der_us_version_num;
                p_t_fee_as_items(gv_as_item_cntr).residency_status_cd     := p_v_der_residency_status_cd;
                p_t_fee_as_items(gv_as_item_cntr).class_standing          := p_v_der_class_standing;
                p_t_fee_as_items(gv_as_item_cntr).unit_type_id            := NULL;
                p_t_fee_as_items(gv_as_item_cntr).unit_class              := NULL;
                p_t_fee_as_items(gv_as_item_cntr).unit_mode               := NULL;
                p_t_fee_as_items(gv_as_item_cntr).unit_cd                 := NULL;
                p_t_fee_as_items(gv_as_item_cntr).unit_version_number     := NULL;
                p_t_fee_as_items(gv_as_item_cntr).unit_level              := NULL;

                log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                            p_v_string => 'Charge Method Overidden. Adding record to PL/SQL table as record number: ' || gv_as_item_cntr );
             END IF;
          END IF;
        END IF;

      ELSIF rec_elm_ranges.override_chg_method_type  IS NULL THEN
        IF ((p_n_element_cap IS NOT NULL) AND (p_n_element_cap < l_n_summed_chg_elm)) THEN
          l_n_rate_factor := p_n_element_cap;
        ELSE
          l_n_rate_factor := l_n_summed_chg_elm;
        END IF;

        OPEN c_elm_rng_rates ( p_v_fee_type,
                               p_v_fee_cal_type,
                               p_n_fee_ci_sequence_num,
                               p_v_fee_cat,
                               rec_elm_ranges.range_number,
                               rec_elm_ranges.s_relation_type);
        FETCH c_elm_rng_rates INTO l_rec_global_rates;
        IF (c_elm_rng_rates%NOTFOUND) THEN

          CLOSE c_elm_rng_rates;
          --Rate records not found
          IF (p_v_trace_on = 'Y') THEN
              fnd_message.set_name('IGS', 'IGS_FI_GLBELM_NO_RATE');
              fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          p_n_charge_rate := 0;
          p_n_fee_amount  := 0;
          log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                     p_v_string => 'Returning from the procedure since there are no active rates.');
          RETURN;

        ELSE

          CLOSE c_elm_rng_rates;

                  log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                              p_v_string => 'Looping across the input PLSQL table, p_t_fee_as_items');
          FOR i IN 1..p_t_fee_as_items.COUNT
          LOOP
            log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                        p_v_string => 'Record: '||i||' - Status: '||p_t_fee_as_items(i).status||' Chg Elements: '||p_t_fee_as_items(i).chg_elements);
            IF (p_t_fee_as_items(i).status = 'E' AND p_t_fee_as_items(i).chg_elements > 0) THEN
              l_b_elm_range_rate_match := FALSE;
                  log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                              p_v_string => 'Looping across the Global Element Range Rates');
              OPEN c_elm_rng_rates ( p_v_fee_type,
                                p_v_fee_cal_type,
                                p_n_fee_ci_sequence_num,
                                p_v_fee_cat,
                                rec_elm_ranges.range_number,
                                rec_elm_ranges.s_relation_type);
              FETCH c_elm_rng_rates INTO l_rec_global_rates;
              WHILE (c_elm_rng_rates%FOUND)
              LOOP

                  IF (l_rec_global_rates.org_party_id IS NOT NULL) THEN
                    l_v_party_number := finpl_get_org_unit_cd(l_rec_global_rates.org_party_id);
                  ELSE
                    l_v_party_number := NULL;
                  END IF;
                  IF l_rec_global_rates.unit_type_id IS NOT NULL THEN
                      l_v_level_code := finpl_get_uptl(l_rec_global_rates.unit_type_id);
                  ELSE
                      l_v_level_code := NULL;
                  END IF;
                  log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                              p_v_string => 'Calling finpl_ins_match_chg_rate');
                  IF ( finpl_ins_match_chg_rate(
                                       l_rec_global_rates.location_cd,
                                       l_rec_global_rates.attendance_type,
                                       l_rec_global_rates.attendance_mode,
                                       l_rec_global_rates.class_standing,
                                       l_rec_global_rates.course_cd,
                                       l_rec_global_rates.version_number,
                                       l_v_party_number,
                                       l_rec_global_rates.residency_status_cd,
                                       p_t_fee_as_items(i).location_cd,
                                       p_v_der_attendance_type,
                                       p_v_der_govt_att_mode,
                                       p_v_der_prog_att_mode,
                                       p_v_der_class_standing,
                                       p_v_der_course_cd,
                                       p_n_der_crs_version_num,
                                       p_t_fee_as_items(i).org_unit_cd,
                                       p_v_der_residency_status_cd,
                                       l_rec_global_rates.unit_set_cd,
                                       l_rec_global_rates.us_version_number,
                                       p_v_der_unit_set_cd,
                                       p_n_der_us_version_num,
                                       l_rec_global_rates.unit_type_id,
                                       p_t_fee_as_items(i).unit_type_id,
                                       l_rec_global_rates.unit_class,
                                       p_t_fee_as_items(i).unit_class,
                                       l_rec_global_rates.unit_mode,
                                       p_t_fee_as_items(i).unit_mode,
                                       l_rec_global_rates.unit_cd,
                                       p_t_fee_as_items(i).unit_cd,
                                       l_rec_global_rates.unit_version_number,
                                       p_t_fee_as_items(i).unit_version_number,
                                       l_rec_global_rates.unit_level,
                                       p_t_fee_as_items(i).unit_level) = TRUE ) THEN

                       log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                                   p_v_string => 'Global Element Range rate matches');
                       IF (p_v_trace_on = 'Y') THEN
                         fnd_file.new_line(fnd_file.log);
                         IF (p_v_fee_trigger_cat <> gcst_institutn) THEN
                           fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'UNIT') || ': ' || p_t_fee_as_items(i).unit_cd);
                         END IF;
                         fnd_message.set_name('IGS', 'IGS_FI_LEV_CHG_RATE_NO');
                         fnd_message.set_token('LEVEL', l_rec_global_rates.s_relation_type);
                         fnd_message.set_token('CH_RT', TO_CHAR(l_rec_global_rates.chg_rate));
                         fnd_message.set_token('RT_NUM', TO_CHAR(l_rec_global_rates.rate_number));
                         fnd_message.set_token('ATT_TYP', NVL(l_rec_global_rates.ATTENDANCE_TYPE, l_v_lkp_all));
                         fnd_message.set_token('ATT_MOD', NVL(l_rec_global_rates.ATTENDANCE_MODE, l_v_lkp_all));
                         fnd_message.set_token('LOC', NVL(l_rec_global_rates.location_cd, l_v_lkp_all));
                         fnd_message.set_token('RES_STAT', NVL(l_rec_global_rates.residency_status_cd, l_v_lkp_all));
                         fnd_message.set_token('ORG_UNIT_CD', NVL(l_v_party_number, l_v_lkp_all));
                         fnd_message.set_token('COURSE_CD', NVL(l_rec_global_rates.course_cd, l_v_lkp_all));
                         fnd_message.set_token('VERSION', NVL(TO_CHAR(l_rec_global_rates.version_number), l_v_lkp_all));
                         fnd_message.set_token('CLAS_STNDNG', NVL(l_rec_global_rates.class_standing, l_v_lkp_all));
                         fnd_message.set_token('UNIT_SET_CD', NVL(l_rec_global_rates.unit_set_cd, l_v_lkp_all));
                         fnd_message.set_token('US_VER', NVL(TO_CHAR(l_rec_global_rates.us_version_number), l_v_lkp_all));
                         fnd_message.set_token('UNIT_TYP_CD', NVL(l_v_level_code, l_v_lkp_all));
                         fnd_message.set_token('UNIT_CLASS', NVL(l_rec_global_rates.unit_class, l_v_lkp_all));
                         fnd_message.set_token('UNIT_MODE', NVL(l_rec_global_rates.unit_mode, l_v_lkp_all));
                         fnd_message.set_token('UNIT_CODE', NVL(l_rec_global_rates.unit_cd, l_v_lkp_all));
                         fnd_message.set_token('UNIT_VER_NUM', NVL(TO_CHAR(l_rec_global_rates.unit_version_number), l_v_lkp_all));
                         fnd_message.set_token('UNIT_LEVEL', NVL(l_rec_global_rates.unit_level, l_v_lkp_all));
                         fnd_file.put_line (fnd_file.log, fnd_message.get);
                         fnd_message.set_name('IGS', 'IGS_FI_FEEASS_RATE_MATCHES');
                         fnd_file.put_line (fnd_file.log, fnd_message.get);
                         fnd_file.new_line(fnd_file.log);
                       END IF;

                       l_b_elm_range_rate_match := TRUE;
                       p_n_charge_rate := l_rec_global_rates.chg_rate;
                       p_t_fee_as_items(i).chg_rate := l_rec_global_rates.chg_rate;
                       EXIT;
                  END IF;

              FETCH c_elm_rng_rates INTO l_rec_global_rates;
              END LOOP;
              CLOSE c_elm_rng_rates;

              --If rate is not matched
              IF (NOT l_b_elm_range_rate_match) THEN
                  log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                              p_v_string => 'No Rate Matched. Returning with 0 rate.');
                  p_n_charge_rate := 0;
                  p_t_fee_as_items(i).chg_rate := 0;
                  IF (p_v_trace_on = 'Y') THEN
                    fnd_file.new_line(fnd_file.log);
                    fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'UNIT') || ': ' || p_t_fee_as_items(i).unit_cd);
                    fnd_message.set_name ( 'IGS', 'IGS_FI_NO_ELM_RNG_RATE_MATCH');
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                    fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
                    fnd_message.set_token('RATE', TO_CHAR(p_n_charge_rate) );
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                    fnd_file.new_line(fnd_file.log);
                  END IF;
              END IF;

              lv_cntrct_rt_apply := FALSE;

              OPEN c_cfar (p_t_fee_as_items(i).location_cd, p_v_der_attendance_type, p_v_der_prog_att_mode, p_v_der_govt_att_mode);
              FETCH c_cfar INTO       l_v_lower_nrml_rate_ovrd_ind,
                                      l_n_cfar_chg_rate;

              IF (c_cfar%FOUND) THEN
                log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                            p_v_string => 'l_n_cfar_chg_rate: ' || l_n_cfar_chg_rate || ', l_v_lower_nrml_rate_ovrd_ind: ' || l_v_lower_nrml_rate_ovrd_ind);
                IF (l_v_lower_nrml_rate_ovrd_ind = 'Y') THEN
                  -- the normal rate is used when it
                  -- is lower than the contract rate
                  IF (p_n_charge_rate > l_n_cfar_chg_rate) THEN
                    IF (p_trace_on = 'Y') THEN
                      fnd_message.set_name('IGS', 'IGS_FI_CONTRACT_RATE');
                      fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_cfar_chg_rate, 0)) );
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                      fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
                      fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_charge_rate, 0)) );
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                    END IF;
                    lv_cntrct_rt_apply := TRUE;
                    p_n_charge_rate := l_n_cfar_chg_rate;
                    p_t_fee_as_items(i).chg_rate := p_n_charge_rate;
                    log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                                p_v_string => 'The contract rate is lower than the charge rate, so the contract rate will be used. Chg Rate: ' || l_n_charge_rate);
                  END IF;
                ELSE
                  -- Use the contract rate
                  lv_cntrct_rt_apply := TRUE;
                  p_n_charge_rate := l_n_cfar_chg_rate;
                  p_t_fee_as_items(i).chg_rate := p_n_charge_rate;
                  IF (p_trace_on = 'Y') THEN
                    fnd_message.set_name('IGS', 'IGS_FI_CONTRACT_RATE');
                    fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_charge_rate, 0)) );
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                              p_v_string => 'The contract rate will be used. Chg Rate: ' || l_n_charge_rate);
                END IF;

              ELSE
                log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                            p_v_string => 'No Contract Rate Found ..');
              END IF;
              -- attempt to find a second contract rate - only one record should be found
              FETCH c_cfar INTO l_v_lower_nrml_rate_ovrd_ind,
                                l_n_cfar_chg_rate;
              IF (c_cfar%FOUND) THEN
                CLOSE c_cfar;
                IF g_v_wav_calc_flag = 'N' THEN
                  ROLLBACK TO fee_calc_sp;
                END IF;

                IF (p_trace_on = 'Y') THEN
                    fnd_message.set_name('IGS', 'IGS_FI_MULTI_CONTRACT_RT');
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                END IF;
                log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                            p_v_string => 'Raising e_one_record_expected.');
                RAISE e_one_record_expected;
              END IF;
              CLOSE c_cfar;

              IF l_n_rate_factor < p_t_fee_as_items(i).chg_elements THEN

                p_t_fee_as_items(i).amount := igs_ru_gen_003.rulp_clc_student_fee(p_n_rul_sequence_num,
                                                                        l_n_rate_factor, p_t_fee_as_items(i).chg_rate);
                p_t_fee_as_items(i).rul_sequence_number := p_n_rul_sequence_num;
                p_t_fee_as_items(i).residency_status_cd := p_v_der_residency_status_cd;
                p_t_fee_as_items(i).class_standing := p_v_der_class_standing;
                p_t_fee_as_items(i).unit_set_cd := p_v_der_unit_set_cd;
                p_t_fee_as_items(i).us_version_number := p_n_der_us_version_num;
                p_n_fee_amount := p_n_fee_amount + p_t_fee_as_items(i).amount;
                l_n_rate_factor := 0;
                EXIT;
              ELSE
                p_t_fee_as_items(i).amount := igs_ru_gen_003.rulp_clc_student_fee(p_n_rul_sequence_num,
                                                                        p_t_fee_as_items(i).chg_elements, p_t_fee_as_items(i).chg_rate);
                p_t_fee_as_items(i).rul_sequence_number := p_n_rul_sequence_num;
                p_t_fee_as_items(i).residency_status_cd := p_v_der_residency_status_cd;
                p_t_fee_as_items(i).class_standing := p_v_der_class_standing;
                p_t_fee_as_items(i).unit_set_cd := p_v_der_unit_set_cd;
                p_t_fee_as_items(i).us_version_number := p_n_der_us_version_num;
                p_n_fee_amount := p_n_fee_amount + p_t_fee_as_items(i).amount;
                l_n_rate_factor := l_n_rate_factor - p_t_fee_as_items(i).chg_elements;
              END IF;
            END IF;
          END LOOP;
        END IF;

       ELSIF (rec_elm_ranges.override_chg_method_type = 'INCREMENTAL') THEN
        l_n_previous_upper := 0;
        p_n_fee_amount := 0;
        l_n_rate_factor := l_n_summed_chg_elm;

        FOR rec_sub_elm_ranges IN cur_sub_elm_ranges(rec_elm_ranges.er_id)
        LOOP
          IF (l_n_loop_subelm_rng = 0) THEN
             IF (p_v_trace_on = 'Y') THEN
               fnd_file.new_line(fnd_file.log);
               fnd_message.set_name ( 'IGS', 'IGS_FI_SUB_ELM_RNG_MATCH');
               fnd_file.put_line (fnd_file.log, fnd_message.get);
               fnd_file.new_line(fnd_file.log);
             END IF;
             l_n_loop_subelm_rng := 1;
          END IF;

          IF (rec_sub_elm_ranges.sub_chg_method_code IS NOT NULL) THEN
             IF (p_v_trace_on = 'Y') THEN
               fnd_message.set_name('IGS', 'IGS_FI_OVRRIDE_CHG_METH_TYPE');
               fnd_message.set_token('CHG_MTHD', igs_fi_gen_gl.get_lkp_meaning('CHG_METHOD', rec_sub_elm_ranges.sub_chg_method_code));
               fnd_file.put_line (fnd_file.log, fnd_message.get);
             END IF;
          END IF;

          log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                      p_v_string => 'Sub Element Range. Lower ' || rec_sub_elm_ranges.sub_lower_range || ', Upper ' ||  rec_sub_elm_ranges.sub_upper_range);

          l_n_sub_rec_found := 1;

          IF ((g_c_fee_calc_mthd = g_v_primary_career) OR
             ((g_c_fee_calc_mthd <> g_v_primary_career) AND (p_v_fee_trigger_cat <> 'INSTITUTN'))) THEN

            OPEN c_resp_org_unit_cd(p_v_der_course_cd, p_n_der_crs_version_num);
            FETCH c_resp_org_unit_cd INTO l_v_derived_org_unit_cd;
            CLOSE c_resp_org_unit_cd;
            l_v_derived_location_cd := p_v_der_location_cd;
            l_v_fee_category := p_v_fee_cat;

          ELSE --If fee calculation method is not primary career and fee trigger category is Institution
            l_v_derived_org_unit_cd := NULL;
            l_v_derived_location_cd := NULL;
            l_v_fee_category := NULL;
          END IF;


          OPEN cur_sub_elm_rng_rates(rec_sub_elm_ranges.sub_er_id);
          FETCH cur_sub_elm_rng_rates INTO l_rec_sub_rates;
          IF (cur_sub_elm_rng_rates%NOTFOUND) THEN
          --Rate records not found
            CLOSE cur_sub_elm_rng_rates;
            IF (p_v_trace_on = 'Y') THEN
              fnd_message.set_name('IGS', 'IGS_FI_SUBELM_NO_RATE');
              fnd_file.put_line (fnd_file.log, fnd_message.get);
              fnd_file.new_line(fnd_file.log);
            END IF;
            p_n_charge_rate := 0;
            l_n_charge_rate := 0;
            log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                        p_v_string => 'Rates not defined for Sub Element Range');

            IF (l_b_first_rate_match = FALSE) THEN
              p_n_fee_amount  := 0;
              RETURN;
            END IF;
          ELSE
          --Rate records exist
            l_b_rate_matched := FALSE;
            --Loop through the sub element range rates
            WHILE (cur_sub_elm_rng_rates%FOUND)
            LOOP

                IF (l_rec_sub_rates.org_party_id IS NOT NULL) THEN
                  l_v_party_number := finpl_get_org_unit_cd(l_rec_sub_rates.org_party_id);
                ELSE
                  l_v_party_number := NULL;
                END IF;
                log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                            p_v_string => 'Calling finpl_ins_match_chg_rate');

                IF ( finpl_ins_match_chg_rate (p_rate_location_cd             => l_rec_sub_rates.location_cd,
                                           p_rate_attendance_type         => l_rec_sub_rates.attendance_type,
                                           p_rate_attendance_mode         => l_rec_sub_rates.attendance_mode,
                                           p_rate_class_standing          => l_rec_sub_rates.class_standing,
                                           p_rate_course_cd               => l_rec_sub_rates.course_cd,
                                           p_rate_version_number          => l_rec_sub_rates.version_number,
                                           p_rate_org_unit_cd             => l_v_party_number,
                                           p_rate_residency_status_cd     => l_rec_sub_rates.residency_status_cd,
                                           p_derived_location_cd          => l_v_derived_location_cd,
                                           p_derived_attendance_type      => p_v_der_attendance_type,
                                           p_derived_govt_att_mode        => p_v_der_govt_att_mode,
                                           p_derived_prog_att_mode        => p_v_der_prog_att_mode,
                                           p_derived_class_standing       => p_v_der_class_standing,
                                           p_derived_course_cd            => p_v_der_course_cd,
                                           p_derived_version_number       => p_n_der_crs_version_num,
                                           p_derived_org_unit_cd          => l_v_derived_org_unit_cd,
                                           p_derived_residency_status_cd  => p_v_der_residency_status_cd,
                                           p_rate_unit_set_cd             => l_rec_sub_rates.unit_set_cd,
                                           p_rate_us_version_num          => l_rec_sub_rates.us_version_number,
                                           p_derived_unit_set_cd          => p_v_der_unit_set_cd,
                                           p_derived_us_version_num       => p_n_der_us_version_num,
                                           p_rate_unit_type_id            => NULL,
                                           p_derived_unit_type_id         => NULL,
                                           p_rate_unit_class              => NULL,
                                           p_derived_unit_class           => NULL,
                                           p_rate_unit_mode               => NULL,
                                           p_derived_unit_mode            => NULL,
                                           p_rate_unit_cd                 => NULL,
                                           p_derived_unit_cd              => NULL,
                                           p_rate_unit_version_num        => NULL,
                                           p_derived_unit_version_num     => NULL,
                                           p_rate_unit_level              => NULL,
                                           p_derived_unit_level           => NULL ) = TRUE ) THEN
                  log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                              p_v_string => 'Sub Element Range rate matches');
                  IF (p_v_trace_on = 'Y') THEN
                     fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'LOW_RANGE') || ': ' || TO_CHAR(rec_sub_elm_ranges.sub_lower_range));
                     fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'UPPER_RANGE') || ': ' || TO_CHAR(rec_sub_elm_ranges.sub_upper_range));
                     fnd_message.set_name('IGS', 'IGS_FI_LEV_CHG_RATE_NO');
                     fnd_message.set_token('LEVEL', l_rec_sub_rates.s_relation_type);
                     fnd_message.set_token('CH_RT', TO_CHAR(l_rec_sub_rates.chg_rate));
                     fnd_message.set_token('RT_NUM', TO_CHAR(l_rec_sub_rates.rate_number));
                     fnd_message.set_token('ATT_TYP', NVL(l_rec_sub_rates.ATTENDANCE_TYPE, l_v_lkp_all));
                     fnd_message.set_token('ATT_MOD', NVL(l_rec_sub_rates.ATTENDANCE_MODE, l_v_lkp_all));
                     fnd_message.set_token('LOC', NVL(l_rec_sub_rates.location_cd, l_v_lkp_all));
                     fnd_message.set_token('RES_STAT', NVL(l_rec_sub_rates.residency_status_cd, l_v_lkp_all));
                     fnd_message.set_token('ORG_UNIT_CD', NVL(l_v_party_number, l_v_lkp_all));
                     fnd_message.set_token('COURSE_CD', NVL(l_rec_sub_rates.course_cd, l_v_lkp_all));
                     fnd_message.set_token('VERSION', NVL(TO_CHAR(l_rec_sub_rates.version_number), l_v_lkp_all));
                     fnd_message.set_token('CLAS_STNDNG', NVL(l_rec_sub_rates.class_standing, l_v_lkp_all));
                     fnd_message.set_token('UNIT_SET_CD', NVL(l_rec_sub_rates.unit_set_cd, l_v_lkp_all));
                     fnd_message.set_token('US_VER', NVL(TO_CHAR(l_rec_sub_rates.us_version_number), l_v_lkp_all));
                     fnd_message.set_token('UNIT_TYP_CD', NVL(TO_CHAR(l_rec_sub_rates.unit_type_id), l_v_lkp_all));
                     fnd_message.set_token('UNIT_CLASS', NVL(l_rec_sub_rates.unit_class, l_v_lkp_all));
                     fnd_message.set_token('UNIT_MODE', NVL(l_rec_sub_rates.unit_mode, l_v_lkp_all));
                     fnd_message.set_token('UNIT_CODE', NVL(l_rec_sub_rates.unit_cd, l_v_lkp_all));
                     fnd_message.set_token('UNIT_VER_NUM', NVL(TO_CHAR(l_rec_sub_rates.unit_version_number), l_v_lkp_all));
                     fnd_message.set_token('UNIT_LEVEL', NVL(l_rec_sub_rates.unit_level, l_v_lkp_all));
                     fnd_file.put_line (fnd_file.log, fnd_message.get);
                     fnd_message.set_name('IGS', 'IGS_FI_FEEASS_RATE_MATCHES');
                     fnd_file.put_line (fnd_file.log, fnd_message.get);
                     fnd_file.new_line(fnd_file.log);
                  END IF;

                --If the rate matches
                  l_n_charge_rate := l_rec_sub_rates.chg_rate;
                  l_b_rate_matched := TRUE;
                  l_b_first_rate_match := TRUE;
                  EXIT;
                END IF; -- If rate is matched.
                FETCH cur_sub_elm_rng_rates INTO l_rec_sub_rates;
            END LOOP; -- Loop across the sub element range rates
            CLOSE cur_sub_elm_rng_rates;
            --If rate is not matched
            IF (NOT l_b_rate_matched) THEN
              log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
              p_v_string => 'No Rate Matched. Returning with 0 rate.');
              p_n_charge_rate := 0;
              l_n_charge_rate := 0;
              IF (l_b_first_rate_match = FALSE) THEN
                p_n_fee_amount  := 0;
              END IF;
            END IF;

          END IF; --If sub element range rates defined

          lv_cntrct_rt_apply := FALSE;

          OPEN c_cfar (l_v_derived_location_cd, p_v_der_attendance_type, p_v_der_prog_att_mode, p_v_der_govt_att_mode);
          FETCH c_cfar INTO       l_v_lower_nrml_rate_ovrd_ind,
                                  l_n_cfar_chg_rate;

          IF (c_cfar%FOUND) THEN
            log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                        p_v_string => 'l_n_cfar_chg_rate: ' || l_n_cfar_chg_rate || ', l_v_lower_nrml_rate_ovrd_ind: ' || l_v_lower_nrml_rate_ovrd_ind);
            IF (l_v_lower_nrml_rate_ovrd_ind = 'Y') THEN
              -- the normal rate is used when it
              -- is lower than the contract rate
              IF (l_n_charge_rate > l_n_cfar_chg_rate) THEN
                IF (p_trace_on = 'Y') THEN
                  fnd_message.set_name('IGS', 'IGS_FI_CONTRACT_RATE');
                  fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_cfar_chg_rate, 0)) );
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                  fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
                  fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_charge_rate, 0)) );
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                END IF;
                lv_cntrct_rt_apply := TRUE;
                l_n_charge_rate := l_n_cfar_chg_rate;
                log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                            p_v_string => 'The contract rate is lower than the charge rate, so the contract rate will be used. Chg Rate: ' || l_n_charge_rate);
              END IF;
            ELSE
              -- Use the contract rate
              lv_cntrct_rt_apply := TRUE;
              l_n_charge_rate := l_n_cfar_chg_rate;
              IF (p_trace_on = 'Y') THEN
                fnd_message.set_name('IGS', 'IGS_FI_CONTRACT_RATE');
                fnd_message.set_token('RATE', TO_CHAR(NVL(l_n_charge_rate, 0)) );
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;
              log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                          p_v_string => 'The contract rate will be used. Chg Rate: ' || l_n_charge_rate);
            END IF;

          ELSE
            log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                        p_v_string => 'No Contract Rate Found ..');
          END IF;
          -- attempt to find a second contract rate - only one record should be found
          FETCH c_cfar INTO l_v_lower_nrml_rate_ovrd_ind,
                            l_n_cfar_chg_rate;
          IF (c_cfar%FOUND) THEN
            CLOSE c_cfar;
            IF g_v_wav_calc_flag = 'N' THEN
              ROLLBACK TO fee_calc_sp;
            END IF;

            IF (p_trace_on = 'Y') THEN
                fnd_message.set_name('IGS', 'IGS_FI_MULTI_CONTRACT_RT');
                fnd_file.put_line (fnd_file.log, fnd_message.get);
            END IF;
            log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                        p_v_string => 'Raising e_one_record_expected.');
            RAISE e_one_record_expected;
          END IF;
          CLOSE c_cfar;


          IF (l_n_summed_chg_elm > rec_sub_elm_ranges.sub_upper_range) THEN

            l_n_rate_factor := rec_sub_elm_ranges.sub_upper_range - l_n_previous_upper;
            IF (rec_sub_elm_ranges.sub_chg_method_code = gcst_flatrate) THEN
              p_n_fee_amount := p_n_fee_amount + igs_ru_gen_003.rulp_clc_student_fee(p_n_rul_sequence_num,1, l_n_charge_rate);
            ELSIF (rec_sub_elm_ranges.sub_chg_method_code IS NULL) THEN
              p_n_fee_amount := p_n_fee_amount + igs_ru_gen_003.rulp_clc_student_fee(p_n_rul_sequence_num, l_n_rate_factor, l_n_charge_rate);
            END IF;

          ELSE

            l_n_rate_factor := l_n_summed_chg_elm - l_n_previous_upper;
            IF (rec_sub_elm_ranges.sub_chg_method_code = gcst_flatrate) THEN
              p_n_fee_amount := p_n_fee_amount + igs_ru_gen_003.rulp_clc_student_fee(p_n_rul_sequence_num,1, l_n_charge_rate);
            ELSIF (rec_sub_elm_ranges.sub_chg_method_code IS NULL) THEN
              p_n_fee_amount := p_n_fee_amount + igs_ru_gen_003.rulp_clc_student_fee(p_n_rul_sequence_num, l_n_rate_factor, l_n_charge_rate);
            END IF;
            EXIT;
          END IF;

          l_n_previous_upper := rec_sub_elm_ranges.sub_upper_range;

        END LOOP;
        --Sub Element Ranges are not found
        IF l_n_sub_rec_found = 0 THEN
          p_n_charge_rate := 0;
          p_n_fee_amount  := 0;

          IF (p_v_trace_on = 'Y') THEN
            fnd_message.set_name('IGS', 'IGS_FI_SUBELM_NO_RANGE');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          RETURN;

        ELSE
          l_b_flag := FALSE;
          IF (p_n_called <> 1) THEN
             IF (p_v_fee_trigger_cat <> gcst_institutn) THEN
                tbl_fai_unit_dtls.DELETE;
             END IF;

              FOR  i IN 1..p_t_fee_as_items.COUNT
              LOOP
                IF (p_v_fee_trigger_cat <> gcst_institutn ) THEN
                    IF (p_t_fee_as_items(i).uoo_id IS NOT NULL AND l_v_ret_level = 'TEACH_PERIOD' AND g_c_predictive_ind = 'N' AND
                         NVL(p_t_fee_as_items(i).chg_elements,0) > 0) THEN
                      l_n_count := tbl_fai_unit_dtls.COUNT + 1;
                      tbl_fai_unit_dtls(l_n_count).fee_cat             :=  p_v_fee_cat;
                      tbl_fai_unit_dtls(l_n_count).course_cd           :=  p_v_der_course_cd;
                      tbl_fai_unit_dtls(l_n_count).crs_version_number  :=  p_n_der_crs_version_num;
                      tbl_fai_unit_dtls(l_n_count).unit_attempt_status :=  p_t_fee_as_items(i).unit_attempt_status;
                      tbl_fai_unit_dtls(l_n_count).org_unit_cd         :=  p_t_fee_as_items(i).org_unit_cd;
                      tbl_fai_unit_dtls(l_n_count).class_standing      :=  p_v_der_class_standing;
                      tbl_fai_unit_dtls(l_n_count).location_cd         :=  p_t_fee_as_items(i).location_cd;
                      tbl_fai_unit_dtls(l_n_count).uoo_id              :=  p_t_fee_as_items(i).uoo_id;
                      tbl_fai_unit_dtls(l_n_count).unit_set_cd         :=  p_v_der_unit_set_cd;
                      tbl_fai_unit_dtls(l_n_count).us_version_number   :=  p_n_der_us_version_num;
                      tbl_fai_unit_dtls(l_n_count).chg_elements        :=  p_t_fee_as_items(i).chg_elements;
                      tbl_fai_unit_dtls(l_n_count).unit_type_id        :=  p_t_fee_as_items(i).unit_type_id;
                      tbl_fai_unit_dtls(l_n_count).unit_class          :=  p_t_fee_as_items(i).unit_class;
                      tbl_fai_unit_dtls(l_n_count).unit_mode           :=  p_t_fee_as_items(i).unit_mode;
                      tbl_fai_unit_dtls(l_n_count).unit_cd             :=  p_t_fee_as_items(i).unit_cd;
                      tbl_fai_unit_dtls(l_n_count).unit_level          :=  p_t_fee_as_items(i).unit_level;
                      tbl_fai_unit_dtls(l_n_count).unit_version_number :=  p_t_fee_as_items(i).unit_version_number;
                    END IF;
                END IF;

                IF  p_t_fee_as_items(i).chg_elements >= 0 AND
                    p_t_fee_as_items(i).uoo_id IS NULL AND
                    p_t_fee_as_items(i).old_amount > 0 THEN

                      p_t_fee_as_items(i).amount := p_n_fee_amount;
                      l_b_flag := TRUE;
                      EXIT;
                ELSE
                  p_t_fee_as_items(i).amount := 0;
                END IF;
              END LOOP; --Loop Across the plsql table

              IF (l_b_flag = FALSE) THEN

                  gv_as_item_cntr := gv_as_item_cntr + 1;
                  p_t_fee_as_items(gv_as_item_cntr).person_id              := p_n_person_id;
                  p_t_fee_as_items(gv_as_item_cntr).status                 := 'I';
                  p_t_fee_as_items(gv_as_item_cntr).fee_type               := p_v_fee_type;
                  p_t_fee_as_items(gv_as_item_cntr).fee_cat                := p_v_fee_cat;
                  p_t_fee_as_items(gv_as_item_cntr).fee_cal_type           := p_v_fee_cal_type;
                  p_t_fee_as_items(gv_as_item_cntr).fee_ci_sequence_number := p_n_fee_ci_sequence_num;
                  p_t_fee_as_items(gv_as_item_cntr).course_cd              := p_v_der_course_cd;
                  p_t_fee_as_items(gv_as_item_cntr).crs_version_number     := l_n_crs_version_num;
                  p_t_fee_as_items(gv_as_item_cntr).description            := p_v_fee_description;
                  p_t_fee_as_items(gv_as_item_cntr).chg_method_type        := 'INCREMENTAL';
                  p_t_fee_as_items(gv_as_item_cntr).old_chg_elements       := 0;
                  p_t_fee_as_items(gv_as_item_cntr).chg_elements           := NVL(p_n_chg_elements,0);
                  p_t_fee_as_items(gv_as_item_cntr).old_amount             := 0;
                  p_t_fee_as_items(gv_as_item_cntr).amount                 := NVL(p_n_fee_amount,0);
                  p_t_fee_as_items(gv_as_item_cntr).unit_attempt_status    := NULL;
                  p_t_fee_as_items(gv_as_item_cntr).location_cd            := l_v_derived_location_cd;
                  p_t_fee_as_items(gv_as_item_cntr).old_eftsu              := NULL;
                  p_t_fee_as_items(gv_as_item_cntr).eftsu                  := NULL;
                  p_t_fee_as_items(gv_as_item_cntr).old_credit_points      := NULL;
                  p_t_fee_as_items(gv_as_item_cntr).credit_points          := NULL;
                  p_t_fee_as_items(gv_as_item_cntr).org_unit_cd            := l_v_derived_org_unit_cd;
                  p_t_fee_as_items(gv_as_item_cntr).uoo_id                 := NULL;
                  p_t_fee_as_items(gv_as_item_cntr).chg_rate               := NULL;
                  p_t_fee_as_items(gv_as_item_cntr).rul_sequence_number    := p_n_rul_sequence_num;
                  p_t_fee_as_items(gv_as_item_cntr).unit_set_cd            := p_v_der_unit_set_cd;
                  p_t_fee_as_items(gv_as_item_cntr).us_version_number      := p_n_der_us_version_num;
                  p_t_fee_as_items(gv_as_item_cntr).residency_status_cd    := p_v_der_residency_status_cd;
                  p_t_fee_as_items(gv_as_item_cntr).class_standing         := p_v_der_class_standing;

              END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;

  IF l_n_record_found = 0 THEN
    log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                p_v_string => 'Global Element Ranges not defined.' );
    p_n_charge_rate  := NULL;
    p_n_fee_amount   := NULL;
    RETURN;
  END IF;

  IF l_n_match_elm_rng = 0 THEN

       log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                   p_v_string => 'No Element Range Matches. IGS_FI_NO_ELEMNTRNG_MATCH' );
       p_n_charge_rate  := 0;
       p_n_fee_amount   := 0;
       IF (p_v_trace_on = 'Y') THEN
         fnd_message.set_name ( 'IGS', 'IGS_FI_NO_ELEMNTRNG_MATCH');
         fnd_file.put_line (fnd_file.log, fnd_message.get);
         fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
         fnd_message.set_token('RATE', TO_CHAR(p_n_charge_rate) );
         fnd_file.put_line (fnd_file.log, fnd_message.get);
       END IF;
       RETURN;
  END IF;

EXCEPTION
    WHEN e_one_record_expected THEN
        log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                    p_v_string => 'From Exception Handler of e_one_record_expected.');
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_PRC_FEE_ASS.FINPL_PRC_ELEMENT_RANGES-'||SUBSTR(sqlerrm,1,500));
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

   WHEN OTHERS THEN
        log_to_fnd( p_v_module => 'finpl_prc_element_ranges',
                    p_v_string => 'From exception handler of When Others.');
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_fi_prc_fee_ass.finpl_prc_element_ranges-'||SUBSTR(sqlerrm,1,500));
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END finpl_prc_element_ranges;

BEGIN

BEGIN

log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
            p_v_string => 'Entered finp_clc_ass_amnt. Parameters are: ' ||
                          TO_CHAR(p_effective_dt, 'DD-MON-YYYY') || ', ' || p_person_id || ', ' || p_course_cd || ', ' || p_course_version_number
                           || ', ' || p_course_attempt_status || ', ' || p_fee_type || ', ' || p_fee_cal_type || ', ' || p_fee_ci_sequence_number
                           || ', ' || p_fee_cat|| ', ' ||p_s_fee_type|| ', ' ||p_s_fee_trigger_cat|| ', ' ||p_rul_sequence_number|| ', ' ||
                           p_charge_method|| ', ' ||p_location_cd|| ', ' ||p_attendance_type|| ', ' ||p_attendance_mode
                           || ', ' || TO_CHAR(p_creation_dt, 'DD-MON-YYYY') || ', ' ||
                           p_charge_elements|| ', ' ||p_fee_assessment|| ', ' ||p_charge_rate|| ', ' || p_c_career);

IF (g_c_predictive_ind = 'Y') THEN
   v_derived_unit_type_id       :=   NULL;
   v_derived_unit_class         :=   NULL;
   v_derived_unit_mode          :=   NULL;
   v_derived_unit_cd            :=   NULL;
   v_derived_unit_version_num   :=   NULL;
   v_derived_unit_level         :=   NULL;
END IF;

-- This function calculates the assessment amount--finp_clc_ass_amnt
lv_charge_override := FALSE;
l_b_elm_ranges_defined :=  FALSE;
l_b_derived        := FALSE;
l_ch_ovr_exist     := FALSE;
l_b_elm_rng := FALSE;
l_b_pred    := FALSE;

IF ((p_s_fee_type = gcst_tuition OR p_s_fee_type = gcst_other OR p_s_fee_type  = gcst_tuition_other OR p_s_fee_type = g_v_audit)) THEN

  --The value of parameter p_n_called will be 1 if it is called from finpl_chk_debt_ret_sched for retention.
  --The value of parameter p_n_called will be 0 if it is called from finpl_prc_fee_cat_fee_liab for calculation of actual amount.
   IF (p_n_called = 1) THEN
      l_n_called := 1;
      l_n_count := tbl_fee_as_items_dummy.COUNT;
      l_v_trace_on := 'N';
--When this function is called for retention the plsql table tbl_fee_as_items_dummy is used. No messages are logged.
   ELSE
      l_n_called := 0;
      l_n_count := t_fee_as_items.COUNT;
      l_v_trace_on := p_trace_on;
--When this function is called for actual amount calculation the plsql table t_fee_as_items is used.
   END IF;

    FOR i IN 1..l_n_count
    LOOP
      IF ((p_n_called = 1 AND tbl_fee_as_items_dummy(i).chg_elements > 0) OR
            (p_n_called = 0 AND NVL(t_fee_as_items(i).chg_elements,0) > 0)) THEN

       IF (g_c_predictive_ind = 'N') THEN

          IF (l_b_derived = FALSE) THEN
             l_b_derived := TRUE;
             -- Perform 2.3.1 Get Derived Values
             -- function call has been modified to pass the prior fee calendar instance
             -- as apart of the early/prior assessment changes for fee calc DLD (bug 1851586)
             log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                         p_v_string => 'Actual Mode: Deriving Attributes by calling finpl_get_derived_values..');
             v_derived_location_cd := p_location_cd;
             IF (finpl_get_derived_values(
                      p_person_id,
                      p_course_cd,
                      p_effective_dt,
                      p_fee_cal_type,
                      p_fee_ci_sequence_number,
                      p_fee_type,
                      p_s_fee_trigger_cat,
                      l_v_trace_on,
                      v_derived_attendance_type,
                      v_derived_govt_att_mode,
                      l_v_derived_prog_att_mode,
                      v_derived_residency_status_cd,
                      v_derived_class_standing,
                      p_c_career,
                      v_derived_unit_set_cd,
                      v_derived_us_version_num) = FALSE) THEN
               RETURN FALSE;
             END IF;
          END IF;
          IF (g_c_fee_calc_mthd <> g_v_primary_career) THEN
                IF p_s_fee_trigger_cat <> 'INSTITUTN' THEN
                       -- Course Code is null for Institution type of Fee
                       -- Course_Cd is derived irrespective of Charge Override, hence brought out
                       -- from the loop 'v_fterrv_rec.override_chg_method_type IS NOT NULL'
                       v_derived_course_cd := p_course_cd;
                       l_n_crs_version_num := p_course_version_number;

                       IF (p_n_called = 1) THEN
                         OPEN c_org_unit_sec_cd(tbl_fee_as_items_dummy(i).uoo_id);
                       ELSE
                         OPEN c_org_unit_sec_cd(t_fee_as_items(i).uoo_id);
                       END IF;
                       FETCH c_org_unit_sec_cd INTO v_derived_org_unit_cd, v_derived_location_cd;
                       CLOSE c_org_unit_sec_cd;

                ELSE
                       l_v_inst_course_cd := p_course_cd;
                       IF (p_n_called = 1) THEN
                         OPEN c_org_unit_sec_cd(tbl_fee_as_items_dummy(i).uoo_id);
                       ELSE
                         OPEN c_org_unit_sec_cd(t_fee_as_items(i).uoo_id);
                       END IF;
                       FETCH c_org_unit_sec_cd INTO l_v_inst_org_unit_cd, l_v_inst_location_cd;
                       CLOSE c_org_unit_sec_cd;

                       -- For Institution type Fee, following attributes are Null
                       v_derived_course_cd := NULL;
                       l_n_crs_version_num := NULL;
                       v_derived_org_unit_cd := NULL;
                       v_derived_location_cd := NULL;
                END IF;

          ELSE --g_c_fee_calc_mthd is 'PRIMARY_CAREER'
                   v_derived_course_cd := p_course_cd;
                   l_n_crs_version_num := p_course_version_number;
                   IF (p_n_called = 1) THEN
                     OPEN c_org_unit_sec_cd(tbl_fee_as_items_dummy(i).uoo_id);
                   ELSE
                     OPEN c_org_unit_sec_cd(t_fee_as_items(i).uoo_id);
                   END IF;
                   FETCH c_org_unit_sec_cd INTO v_derived_org_unit_cd, v_derived_location_cd;
                   CLOSE c_org_unit_sec_cd;

          END IF; -- End if for fee calc mthd <> Primary Career
          log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                      p_v_string => 'Actual Case: Derived Course Cd: ' || v_derived_course_cd || ', Org Unit:' || v_derived_org_unit_cd
                                    || ', Location Cd: ' || v_derived_location_cd );

       ELSIF (g_c_predictive_ind = 'Y') THEN
           IF l_b_pred = FALSE THEN
              l_b_pred := TRUE;
              log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                          p_v_string => 'Predictive Mode: Deriving Attributes..');
              v_derived_location_cd := p_location_cd;
              l_n_crs_version_num := p_course_version_number;
              v_derived_attendance_type := p_attendance_type;
              OPEN c_am (p_attendance_mode);
              FETCH c_am INTO v_derived_govt_att_mode;
              CLOSE c_am;
              l_v_derived_prog_att_mode := p_attendance_mode;
              v_derived_residency_status_cd:= get_stdnt_res_status_cd(p_person_id);
              get_stdnt_unit_set_dtls( p_n_person_id => p_person_id,
                                       p_v_course_cd => p_course_cd,
                                       p_v_s_fee_trigger_cat => p_s_fee_trigger_cat,
                                       p_v_unit_set_cd => v_derived_unit_set_cd,
                                       p_n_unit_set_ver_num => v_derived_us_version_num );
           END IF;
           IF (p_n_called = 1) THEN
             v_derived_course_cd := tbl_fee_as_items_dummy(i).course_cd;
             v_derived_org_unit_cd := tbl_fee_as_items_dummy(i).org_unit_cd;
           ELSE
             v_derived_course_cd := t_fee_as_items(i).course_cd;
             v_derived_org_unit_cd := t_fee_as_items(i).org_unit_cd;
           END IF;
           log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                       p_v_string => 'Predictive Mode: Derived Values are: Location: ' || v_derived_location_cd ||
                                     ', AT: ' || v_derived_attendance_type || ', AM: ' || p_attendance_mode ||
                                     ', Govt AM: ' || v_derived_govt_att_mode || ', Crs Cd: ' || v_derived_course_cd ||
                                     ', Org Unit Cd: ' || v_derived_org_unit_cd || ', Res Code: ' || v_derived_residency_status_cd ||
                                     ', Unit Set Cd: ' || v_derived_unit_set_cd || ', Unit Set Ver: ' || v_derived_us_version_num );

       END IF;

       v_residency_status_cd := v_derived_residency_status_cd;
       v_class_standing := v_derived_class_standing;
       IF (p_charge_method = gcst_flatrate) THEN
              log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                          p_v_string => 'Calling finpl_find_far directly as FLAT RATE');
              IF (p_n_called = 1) THEN

                finpl_find_far(
                      p_person_id,
                      p_course_cd,
                      p_fee_cat,
                      p_fee_cal_type,
                      p_fee_ci_sequence_number,
                      p_fee_type,
                      p_location_cd,
                      p_effective_dt,
                      p_s_fee_trigger_cat,
                      tbl_fee_as_items_dummy(i).location_cd,
                      v_derived_attendance_type,
                      v_derived_govt_att_mode,
                      l_v_derived_prog_att_mode,
                      l_v_trace_on,
                      v_derived_residency_status_cd,
                      tbl_fee_as_items_dummy(i).org_unit_cd,
                      tbl_fee_as_items_dummy(i).course_cd,
                      p_course_version_number,
                      v_derived_class_standing,
                      v_charge_rate,
                      v_derived_unit_set_cd,
                      v_derived_us_version_num,
                      tbl_fee_as_items_dummy(i).unit_type_id,
                      tbl_fee_as_items_dummy(i).unit_class,
                      tbl_fee_as_items_dummy(i).unit_mode,
                      tbl_fee_as_items_dummy(i).unit_cd,
                      tbl_fee_as_items_dummy(i).unit_version_number,
                      tbl_fee_as_items_dummy(i).unit_level
                      ); -- out

                  tbl_fee_as_items_dummy(i).chg_rate := v_charge_rate;
              ELSE
                finpl_find_far(
                      p_person_id,
                      p_course_cd,
                      p_fee_cat,
                      p_fee_cal_type,
                      p_fee_ci_sequence_number,
                      p_fee_type,
                      p_location_cd,
                      p_effective_dt,
                      p_s_fee_trigger_cat,
                      t_fee_as_items(i).location_cd,
                      v_derived_attendance_type,
                      v_derived_govt_att_mode,
                      l_v_derived_prog_att_mode,
                      l_v_trace_on,
                      v_derived_residency_status_cd,
                      t_fee_as_items(i).org_unit_cd,
                      t_fee_as_items(i).course_cd,
                      p_course_version_number,
                      v_derived_class_standing,
                      v_charge_rate,
                      v_derived_unit_set_cd,
                      v_derived_us_version_num,
                      t_fee_as_items(i).unit_type_id,
                      t_fee_as_items(i).unit_class,
                      t_fee_as_items(i).unit_mode,
                      t_fee_as_items(i).unit_cd,
                      t_fee_as_items(i).unit_version_number,
                      t_fee_as_items(i).unit_level
                      ); -- out

                  t_fee_as_items(i).chg_rate := v_charge_rate;

              END IF;

         ELSIF (p_charge_method IN (gcst_eftsu, gcst_crpoint, gcst_perunit)) THEN
            IF (l_b_elm_rng = FALSE) THEN
               l_b_elm_rng := TRUE;
               --to get fee type description
               OPEN  c_fee_type(p_fee_type);
               FETCH c_fee_type INTO v_fee_type_description;
               CLOSE c_fee_type;

               IF (p_n_called = 1) THEN
                  log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                           p_v_string => 'Calling finpl_prc_element_ranges with tbl_fee_as_item2');
                  finpl_prc_element_ranges(
                               p_n_person_id               => p_person_id,
                               p_v_fee_cat                 => p_fee_cat,
                               p_v_fee_type                => p_fee_type,
                               p_v_fee_cal_type            => p_fee_cal_type,
                               p_n_fee_ci_sequence_num     => p_fee_ci_sequence_number,
                               p_v_fee_trigger_cat         => p_s_fee_trigger_cat,
                               p_n_rul_sequence_num        => p_rul_sequence_number,
                               p_v_der_course_cd           => v_derived_course_cd,
                               p_n_der_crs_version_num     => p_course_version_number,
                               p_v_der_location_cd         => v_derived_location_cd,
                               p_v_der_attendance_type     => v_derived_attendance_type,
                               p_v_der_govt_att_mode       => v_derived_govt_att_mode,
                               p_v_der_prog_att_mode       => l_v_derived_prog_att_mode,
                               p_v_der_class_standing      => v_class_standing,
                               p_v_der_org_unit_cd         => v_derived_org_unit_cd,
                               p_v_der_residency_status_cd => v_residency_status_cd,
                               p_v_der_unit_set_cd         => v_derived_unit_set_cd,
                               p_n_der_us_version_num      => v_derived_us_version_num,
                               p_v_fee_description         => v_fee_type_description,
                               p_v_elm_rng_order_name      => p_elm_rng_order_name,
                               p_n_chg_elements            => p_charge_elements,
                               p_n_fee_amount              => p_fee_assessment,
                               p_n_charge_rate             => v_charge_rate,
                               p_t_fee_as_items            => tbl_fee_as_items_dummy,
                               p_v_trace_on                => l_v_trace_on,
                               p_n_element_cap             => p_n_max_chg_elements,
                               p_n_called                  => p_n_called
                               );
               ELSE
                  log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                           p_v_string => 'Calling finpl_prc_element_ranges with t_fee_as_items');
                 finpl_prc_element_ranges(
                               p_n_person_id               => p_person_id,
                               p_v_fee_cat                 => p_fee_cat,
                               p_v_fee_type                => p_fee_type,
                               p_v_fee_cal_type            => p_fee_cal_type,
                               p_n_fee_ci_sequence_num     => p_fee_ci_sequence_number,
                               p_v_fee_trigger_cat         => p_s_fee_trigger_cat,
                               p_n_rul_sequence_num        => p_rul_sequence_number,
                               p_v_der_course_cd           => v_derived_course_cd,
                               p_n_der_crs_version_num     => p_course_version_number,
                               p_v_der_location_cd         => v_derived_location_cd,
                               p_v_der_attendance_type     => v_derived_attendance_type,
                               p_v_der_govt_att_mode       => v_derived_govt_att_mode,
                               p_v_der_prog_att_mode       => l_v_derived_prog_att_mode,
                               p_v_der_class_standing      => v_class_standing,
                               p_v_der_org_unit_cd         => v_derived_org_unit_cd,
                               p_v_der_residency_status_cd => v_residency_status_cd,
                               p_v_der_unit_set_cd         => v_derived_unit_set_cd,
                               p_n_der_us_version_num      => v_derived_us_version_num,
                               p_v_fee_description         => v_fee_type_description,
                               p_v_elm_rng_order_name      => p_elm_rng_order_name,
                               p_n_chg_elements            => p_charge_elements,
                               p_n_fee_amount              => p_fee_assessment,
                               p_n_charge_rate             => v_charge_rate,
                               p_t_fee_as_items            => t_fee_as_items,
                               p_v_trace_on                => l_v_trace_on,
                               p_n_element_cap             => p_n_max_chg_elements,
                               p_n_called                  => p_n_called
                               );

               END IF;

              IF (v_charge_rate IS NULL AND p_fee_assessment IS NULL) THEN
                 l_b_elm_ranges_defined := FALSE;
              ELSE
                 l_b_elm_ranges_defined := TRUE;
                 EXIT;
              END IF;
            END IF;
            IF (l_b_elm_ranges_defined = FALSE) THEN
                -------------------------------
                -- No Element Range is defined
                -------------------------------
                -- match derived attributes from Fee Assessessment Rates table.
                log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                            p_v_string => 'No Element Ranges Defined. Calling finpl_find_far');
                IF (p_n_called = 1) THEN
                   finpl_find_far(
                        p_person_id,
                        p_course_cd,
                        p_fee_cat,
                        p_fee_cal_type,
                        p_fee_ci_sequence_number,
                        p_fee_type,
                        p_location_cd,
                        p_effective_dt,
                        p_s_fee_trigger_cat,
                        tbl_fee_as_items_dummy(i).location_cd,
                        v_derived_attendance_type,
                        v_derived_govt_att_mode,
                        l_v_derived_prog_att_mode,
                        l_v_trace_on,
                        v_derived_residency_status_cd,
                        tbl_fee_as_items_dummy(i).org_unit_cd,
                        tbl_fee_as_items_dummy(i).course_cd,
                        p_course_version_number,
                        v_derived_class_standing,
                        v_charge_rate,
                        v_derived_unit_set_cd,
                        v_derived_us_version_num,
                        tbl_fee_as_items_dummy(i).unit_type_id,
                        tbl_fee_as_items_dummy(i).unit_class,
                        tbl_fee_as_items_dummy(i).unit_mode,
                        tbl_fee_as_items_dummy(i).unit_cd,
                        tbl_fee_as_items_dummy(i).unit_version_number,
                        tbl_fee_as_items_dummy(i).unit_level
                        );
                   tbl_fee_as_items_dummy(i).chg_rate := v_charge_rate;
                ELSE
                   finpl_find_far(
                        p_person_id,
                        p_course_cd,
                        p_fee_cat,
                        p_fee_cal_type,
                        p_fee_ci_sequence_number,
                        p_fee_type,
                        p_location_cd,
                        p_effective_dt,
                        p_s_fee_trigger_cat,
                        t_fee_as_items(i).location_cd,
                        v_derived_attendance_type,
                        v_derived_govt_att_mode,
                        l_v_derived_prog_att_mode,
                        l_v_trace_on,
                        v_derived_residency_status_cd,
                        t_fee_as_items(i).org_unit_cd,
                        t_fee_as_items(i).course_cd,
                        p_course_version_number,
                        v_derived_class_standing,
                        v_charge_rate,
                        v_derived_unit_set_cd,
                        v_derived_us_version_num,
                        t_fee_as_items(i).unit_type_id,
                        t_fee_as_items(i).unit_class,
                        t_fee_as_items(i).unit_mode,
                        t_fee_as_items(i).unit_cd,
                        t_fee_as_items(i).unit_version_number,
                        t_fee_as_items(i).unit_level
                        );
                   t_fee_as_items(i).chg_rate := v_charge_rate;

                END IF;
            END IF;
       END IF;

       lv_cntrct_rt_apply := FALSE;

       -- Check if a contract fee assessment rate is to apply
       -- If the Profile is Nominated, Rate's AM is compared against Nominated Program AM.
       --                   Derived, Derived Govt AM is compared against Govt AM mapped to Rate's AM. (Bug# 3784618)
       IF (p_n_called = 1) THEN
         log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                     p_v_string => 'Calling c_cfar. Parameters: ' || tbl_fee_as_items_dummy(i).location_cd
                                    || ','||v_derived_attendance_type ||','||l_v_derived_prog_att_mode ||','||v_derived_govt_att_mode);
       ELSE
         log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                     p_v_string => 'Calling c_cfar. Parameters: ' || t_fee_as_items(i).location_cd
                                    || ','||v_derived_attendance_type ||','||l_v_derived_prog_att_mode ||','||v_derived_govt_att_mode);
       END IF;

       IF (p_n_called = 1) THEN
         OPEN c_cfar (tbl_fee_as_items_dummy(i).location_cd, v_derived_attendance_type, l_v_derived_prog_att_mode, v_derived_govt_att_mode);
       ELSE
         OPEN c_cfar (t_fee_as_items(i).location_cd, v_derived_attendance_type, l_v_derived_prog_att_mode, v_derived_govt_att_mode);
       END IF;

       FETCH c_cfar INTO       v_lower_nrml_rate_ovrd_ind,
                               v_cfar_chg_rate;


       IF (c_cfar%FOUND) THEN
         log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                     p_v_string => 'v_cfar_chg_rate: ' || v_cfar_chg_rate || ', v_lower_nrml_rate_ovrd_ind: ' || v_lower_nrml_rate_ovrd_ind);
         IF (v_lower_nrml_rate_ovrd_ind = 'Y') THEN
           -- the normal rate is used when it
           -- is lower than the contract rate
           IF (v_charge_rate > v_cfar_chg_rate) THEN
             IF (l_v_trace_on = 'Y') THEN
               fnd_message.set_name('IGS', 'IGS_FI_CONTRACT_RATE');
               fnd_message.set_token('RATE', TO_CHAR(NVL(v_cfar_chg_rate, 0)) );
               fnd_file.put_line (fnd_file.log, fnd_message.get);
               fnd_message.set_name('IGS', 'IGS_FI_CHG_RATE');
               fnd_message.set_token('RATE', TO_CHAR(NVL(v_charge_rate, 0)) );
               fnd_file.put_line (fnd_file.log, fnd_message.get);
             END IF;
             lv_cntrct_rt_apply := TRUE;
             v_charge_rate := v_cfar_chg_rate;
             IF (p_n_called = 1) THEN
               tbl_fee_as_items_dummy(i).chg_rate := v_charge_rate;
             ELSE
               t_fee_as_items(i).chg_rate := v_charge_rate;
             END IF;
             log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                         p_v_string => 'The contract rate is lower than the charge rate, so the contract rate will be used. Chg Rate: ' || v_charge_rate);
           END IF;
         ELSE
           -- Use the contract rate
           lv_cntrct_rt_apply := TRUE;
           v_charge_rate := v_cfar_chg_rate;
           IF (p_n_called = 1) THEN
             tbl_fee_as_items_dummy(i).chg_rate := v_charge_rate;
           ELSE
             t_fee_as_items(i).chg_rate := v_charge_rate;
           END IF;
           IF (l_v_trace_on = 'Y') THEN
             fnd_message.set_name('IGS', 'IGS_FI_CONTRACT_RATE');
             fnd_message.set_token('RATE', TO_CHAR(NVL(v_charge_rate, 0)) );
             fnd_file.put_line (fnd_file.log, fnd_message.get);
           END IF;
           log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                       p_v_string => 'The contract rate will be used. Chg Rate: ' || v_charge_rate);
         END IF;

       ELSE
         log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                     p_v_string => 'No Contract Rate Found ..');
       END IF;
       -- attempt to find a second contract rate - only one record should be found
       FETCH c_cfar INTO v_lower_nrml_rate_ovrd_ind,
                         v_cfar_chg_rate;
       IF (c_cfar%FOUND) THEN
         CLOSE c_cfar;
         IF g_v_wav_calc_flag = 'N' THEN
           ROLLBACK TO fee_calc_sp;
         END IF;

         IF (l_v_trace_on = 'Y') THEN
             fnd_message.set_name('IGS', 'IGS_FI_MULTI_CONTRACT_RT');
             fnd_file.put_line (fnd_file.log, fnd_message.get);
         END IF;
         log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                     p_v_string => 'Raising e_one_record_expected.');
         RAISE e_one_record_expected;
       END IF;
       CLOSE c_cfar;

       IF (p_n_called = 1) THEN
           lv_fee_assessment := igs_ru_gen_003.rulp_clc_student_fee( p_rul_sequence_number,
                                                                     tbl_fee_as_items_dummy(i).chg_elements,
                                                                     tbl_fee_as_items_dummy(i).chg_rate);

           tbl_fee_as_items_dummy(i).amount                := NVL(lv_fee_assessment,0);
           tbl_fee_as_items_dummy(i).rul_sequence_number   := p_rul_sequence_number;
           tbl_fee_as_items_dummy(i).residency_status_cd   := v_residency_status_cd ;
           tbl_fee_as_items_dummy(i).class_standing        := v_class_standing ;
           p_fee_assessment := NVL(p_fee_assessment,0) + NVL(tbl_fee_as_items_dummy(i).amount,0);

           tbl_fee_as_items_dummy(i).unit_set_cd           := v_derived_unit_set_cd;
           tbl_fee_as_items_dummy(i).us_version_number     := v_derived_us_version_num;
       ELSE
           lv_fee_assessment := igs_ru_gen_003.rulp_clc_student_fee( p_rul_sequence_number,
                                                                     t_fee_as_items(i).chg_elements,
                                                                     t_fee_as_items(i).chg_rate);

           t_fee_as_items(i).amount                := NVL(lv_fee_assessment,0);
           t_fee_as_items(i).rul_sequence_number   := p_rul_sequence_number;
           t_fee_as_items(i).residency_status_cd   := v_residency_status_cd ;
           t_fee_as_items(i).class_standing        := v_class_standing ;
           p_fee_assessment := NVL(p_fee_assessment,0) + NVL(t_fee_as_items(i).amount,0);

           t_fee_as_items(i).unit_set_cd           := v_derived_unit_set_cd;
           t_fee_as_items(i).us_version_number     := v_derived_us_version_num;
       END IF;
      END IF;
    END LOOP;
END IF;

p_charge_rate := v_charge_rate;

 log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
             p_v_string => 'End of finp_clc_ass_amnt. Out - Creation Dt: ' || TO_CHAR(p_creation_dt, 'DD-MON-YYYY')
                            || ', Chg Elements: ' || p_charge_elements || ', Fee As Amount: ' || p_fee_assessment
                            || ', Charge Rate: ' || p_charge_rate );
 RETURN TRUE;
EXCEPTION

WHEN e_one_record_expected THEN
        log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                    p_v_string => 'From Exception Handler of e_one_record_expected.');
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_PRC_FEE_ASS.FINP_CLC_ASS_AMNT-'||SUBSTR(sqlerrm,1,500));
        IGS_GE_MSG_STACK.ADD;
         lv_param_values := to_char(p_effective_dt)||','||to_char(p_person_id)||','||
          p_course_cd||','||p_course_attempt_status||','||
          p_fee_type||','||
          to_char(p_fee_ci_sequence_number)||','||
          p_fee_cat||','||p_s_fee_type||','||
          p_s_fee_trigger_cat||','||
          to_char(p_rul_sequence_number)||','||
          p_charge_method||','||
          p_location_cd||','||
          p_attendance_type||','||
          p_attendance_mode||','||
          p_trace_on||','||
          to_char(p_creation_dt)||','||
          p_charge_elements||','||
          p_fee_assessment;
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARAMETERS');
         FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
         IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception(Null, Null, fnd_message.get);

WHEN OTHERS THEN
        log_to_fnd( p_v_module => 'finp_clc_ass_amnt',
                    p_v_string => 'When Others.' || SUBSTR(sqlerrm,1,500));
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_PRC_FEE_ASS.FINP_CLC_ASS_AMNT');
        IGS_GE_MSG_STACK.ADD;
         lv_param_values := to_char(p_effective_dt)||','||to_char(p_person_id)||','||
          p_course_cd||','||p_course_attempt_status||','||
          p_fee_type||','||
          to_char(p_fee_ci_sequence_number)||','||
          p_fee_cat||','||p_s_fee_type||','||
          p_s_fee_trigger_cat||','||
          to_char(p_rul_sequence_number)||','||
          p_charge_method||','||
          p_location_cd||','||
          p_attendance_type||','||
          p_attendance_mode||','||
          p_trace_on||','||
          to_char(p_creation_dt)||','||
          p_charge_elements||','||
          p_fee_assessment;
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARAMETERS');
         FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
         IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

END;
END;
END finp_clc_ass_amnt;

  --
  -- Calculate and insert fee assessments as required
   FUNCTION finp_ins_enr_fee_ass(p_effective_dt          IN DATE ,
                            p_person_id                  IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
                            p_course_cd                  IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
                            p_fee_category               IN IGS_EN_STDNT_PS_ATT_ALL.FEE_CAT%TYPE ,
                            p_fee_cal_type               IN IGS_CA_INST_ALL.CAL_TYPE%TYPE ,
                            p_fee_ci_sequence_num        IN IGS_CA_INST_ALL.sequence_number%TYPE ,
                            p_fee_type                   IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE ,
                            p_trace_on                   IN VARCHAR2 ,
                            p_test_run                   IN VARCHAR2 ,
                            p_creation_dt                IN OUT NOCOPY DATE ,
                            p_message_name               OUT    NOCOPY VARCHAR2,
                            p_process_mode               IN VARCHAR2 ,
                            p_c_career                   IN igs_ps_ver_all.course_type%TYPE,
                            p_d_gl_date                  IN DATE,
                            p_v_wav_calc_flag            IN VARCHAR2,
                            p_n_waiver_amount            OUT NOCOPY NUMBER
                            ) RETURN BOOLEAN AS
/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who            When         What
 gurprsin       06-Dec-2005  Bug 4735807, Modified function 'finp_ins_enr_fee_ass', Modified the logic to return and log the message
                             if No Fee category is attached to the SPA.
 abshriva       5-Dec-2005   Bug 4701695 Removed condition to display 'Fee calculation method' and 'term'message
                             in log file  on execution of 'Process Fee Assessment'
 pathipat       23-Nov-2005  Bug 4718712 - Modified cur_spa - removed condition on course_type.
*************************************************************/
    BEGIN
    DECLARE
        e_one_record_expected           EXCEPTION;
        v_fee_cat                       igs_fi_f_cat_ca_inst.fee_cat%TYPE;
        v_record_found                  BOOLEAN := FALSE;
        v_message_name                  VARCHAR2(30);

        l_fee_category          igs_fi_fee_cat_all.fee_cat%TYPE;
        l_b_fci_lci             BOOLEAN := FALSE;
        l_b_ret_status          BOOLEAN;
        l_b_recs_found          BOOLEAN;
        l_b_return_status       BOOLEAN := FALSE;
        l_v_message_name        fnd_new_messages.message_name%TYPE := NULL;
        l_n_sum_waiver_amount   NUMBER := 0.0;
        l_v_raise_wf_event      VARCHAR2(1);
        l_v_err_msg             VARCHAR2(2000);

        CURSOR c_fcci_fss ( cp_effective_dt DATE) IS
                SELECT fcci.fee_cat
                FROM igs_fi_f_cat_ca_inst fcci,
                     igs_fi_fee_str_stat  fss
                WHERE fcci.fee_cat = p_fee_category
                AND (
                     -- In Predictive, Select only when Effective Date (i.e., SYSDATE) is less than FCCI Start Date Alias Value.
                     ( g_c_predictive_ind = 'Y' AND
                       (TRUNC(cp_effective_dt) < (SELECT TRUNC(daiv.alias_val)
                                                  FROM igs_ca_da_inst_v  daiv
                                                  WHERE daiv.DT_ALIAS = fcci.start_dt_alias AND
                                                  daiv.sequence_number = fcci.start_dai_sequence_number AND
                                                  daiv.CAL_TYPE =fcci.fee_cal_type AND
                                                  daiv.ci_sequence_number = fcci.fee_ci_sequence_number)
                       )
                     )
                     OR
                     -- In Actual, Select only when FCCI is active as on Effective Date. (i.e., Eff Date <= FCCI Start Date Alias)
                     ( g_c_predictive_ind = 'N' AND
                       (TRUNC(cp_effective_dt) >= (SELECT TRUNC(daiv.alias_val)
                                                   FROM igs_ca_da_inst_v  daiv
                                                   WHERE daiv.DT_ALIAS = fcci.start_dt_alias AND
                                                   daiv.sequence_number = fcci.start_dai_sequence_number AND
                                                   daiv.CAL_TYPE =fcci.fee_cal_type AND
                                                   daiv.ci_sequence_number = fcci.fee_ci_sequence_number)
                       )
                     )
                    )
                AND TRUNC(cp_effective_dt) <= ( SELECT  TRUNC(daiv.alias_val)
                                                FROM    IGS_CA_DA_INST_V        daiv
                                                WHERE   daiv.DT_ALIAS = fcci.end_dt_alias
                                                AND     daiv.sequence_number = fcci.end_dai_sequence_number
                                                AND     daiv.CAL_TYPE =fcci.fee_cal_type
                                                AND     daiv.ci_sequence_number = fcci.fee_ci_sequence_number)
                AND     fcci.fee_cat_ci_status = fss.FEE_STRUCTURE_STATUS
                AND     fss.s_fee_structure_status = gcst_active;


        -- cursor for getting Fee Calculation Method, Program Change Date Alias
        CURSOR c_fi_control  IS
        SELECT fee_calc_mthd_code,
               currency_cd
        FROM   igs_fi_control_all;

        l_c_fi_control  c_fi_control%ROWTYPE;

        -- cursor for checking course type
        CURSOR c_course_type  IS
        SELECT 'X'
        FROM   igs_ps_type_all
        WHERE course_type = p_c_career;

        l_c_temp VARCHAR2(1);

        CURSOR c_daiv( cp_dt_alias  igs_fi_f_cat_ca_inst.start_dt_alias%TYPE) IS
        SELECT  alias_val
        FROM    igs_ca_da_inst_v
        WHERE   dt_alias = cp_dt_alias
        AND     cal_type = p_fee_cal_type
        AND     ci_sequence_number = p_fee_ci_sequence_num;

        l_c_daiv  c_daiv%ROWTYPE;

       l_c_control_curr  igs_fi_control_all.currency_cd%TYPE;

       CURSOR cur_fee_cat_curr(cp_fee_cat IN VARCHAR2) IS
       SELECT currency_cd
       FROM igs_fi_fee_cat_all
       WHERE fee_cat = cp_fee_cat;
       l_cur_fee_cat_curr cur_fee_cat_curr%ROWTYPE;

    lv_sum_message varchar2(30);

    -- Get the Program Attempt Status for the program that is passed as input to the process
    CURSOR cur_sca IS
    SELECT  sca.course_attempt_status
    FROM    igs_en_stdnt_ps_att_all sca
    WHERE   sca.person_id = p_person_id
    AND     sca.course_cd = p_course_cd;

    -- Cursor to check if there are any Incomplete Program Transfers.
    CURSOR c_sua_for_sec (cp_n_person_id PLS_INTEGER,
                          cp_v_secondary VARCHAR2,
                          cp_v_enrolled  VARCHAR2) IS
    SELECT 'X'
    FROM igs_en_stdnt_ps_att_all sca,
         igs_en_su_attempt_all sua
    WHERE sca.person_id = cp_n_person_id
    AND   sca.person_id = sua.person_id
    AND   sca.course_cd = sua.course_cd
    AND   NVL(sca.primary_program_type, cp_v_secondary) = cp_v_secondary
    AND   sua.unit_attempt_status = cp_v_enrolled;
    rec_sua_for_sec c_sua_for_sec%ROWTYPE;

    -- Cursor to derive Key Program for a given student and for a given term.
    CURSOR c_key_program ( cp_n_person_id PLS_INTEGER,
                           cp_v_load_cal_type igs_fi_f_cat_ca_inst.fee_cal_type%TYPE,
                           cp_n_load_ci_seq_num igs_fi_f_cat_ca_inst.fee_ci_sequence_number%TYPE,
                           cp_v_key_prog_flag   igs_en_spa_terms.key_program_flag%TYPE ) IS
    SELECT program_cd, program_version
    FROM igs_en_spa_terms
    WHERE person_id = cp_n_person_id
    AND term_cal_type = cp_v_load_cal_type
    AND term_sequence_number = cp_n_load_ci_seq_num
    AND key_program_flag = cp_v_key_prog_flag;

    -- Cursor to fetch program details when the processing mode is ACTUAL.
    CURSOR c_scas ( cp_n_person_id   PLS_INTEGER,
                    cp_v_load_cal_type VARCHAR2,
                    cp_n_load_ci_seq_num NUMBER,
                    cp_v_program_cd VARCHAR2,
                    cp_v_fee_cat VARCHAR2,
                    cp_v_course_type VARCHAR2,
                    cp_v_key_program_flag igs_en_spa_terms.key_program_flag%TYPE,
                    cp_v_lookup_type igs_lookups_view.lookup_type%TYPE,
                    cp_v_fee_ass_ind igs_lookups_view.fee_ass_ind%TYPE) IS
    SELECT esptv.person_id,
           esptv.program_cd,
           esptv.program_version,
           psv.course_type,
           esptv.fee_cat,
           esptv.location_cd,
           esptv.attendance_mode,
           esptv.attendance_type,
           sca.course_attempt_status,
           sca.cal_type,
           sca.commencement_dt,
           sca.discontinued_dt,
           psv.short_title,
           esptv.key_program_flag
    FROM igs_en_spa_terms esptv,
         igs_ps_ver_all psv,
         igs_en_stdnt_ps_att_all sca,
         igs_lookups_view scas
    WHERE esptv.program_cd = psv.course_cd
    AND esptv.program_version = psv.version_number
    AND esptv.program_cd = sca.course_cd
    AND esptv.program_version = sca.version_number
    AND esptv.person_id = sca.person_id
    AND esptv.person_id = cp_n_person_id
    AND
     (esptv.term_cal_type = cp_v_load_cal_type
      AND
      esptv.term_sequence_number = cp_n_load_ci_seq_num
     )
    AND (cp_v_program_cd IS NULL OR esptv.program_cd = cp_v_program_cd)
    AND (cp_v_fee_cat IS NULL OR esptv.fee_cat = cp_v_fee_cat)
    AND (  /* If Fee Calc Mthd is CAREER, Term records are created only for primary programs. So select all records from terms table */
         (g_c_fee_calc_mthd IN (g_v_program,g_v_career))
         OR
         (esptv.key_program_flag = cp_v_key_program_flag AND g_c_fee_calc_mthd = g_v_primary_career)
        )
    AND (cp_v_course_type IS NULL OR psv.course_type = cp_v_course_type)
    AND sca.course_attempt_status = scas.lookup_code
    AND scas.lookup_type = cp_v_lookup_type
    AND scas.fee_ass_ind = cp_v_fee_ass_ind
    ORDER BY esptv.fee_cat, esptv.person_id, esptv.program_cd;

    CURSOR cur_person_name (cp_n_person_id PLS_INTEGER) IS
    SELECT party_name
    FROM  hz_parties p
    WHERE  p.party_id = cp_n_person_id;

    CURSOR cur_spa (cp_n_person_id         hz_parties.party_id%TYPE,
                    cp_v_load_cal_type     igs_ca_inst_all.cal_type%TYPE,
                    cp_n_load_ci_seq_num   igs_ca_inst_all.sequence_number%TYPE,
                    cp_v_key_program_flag  igs_en_spa_terms.key_program_flag%TYPE,
                    cp_v_course_type       igs_ps_ver_all.course_type%TYPE,
                    cp_v_lookup_type       igs_lookups_view.lookup_type%TYPE,
                    cp_v_fee_ass_ind       igs_lookups_view.fee_ass_ind%TYPE,
                    cp_v_fee_cat           igs_en_spa_terms.fee_cat%TYPE) IS
    SELECT     esptv.person_id,
               esptv.program_cd,
               esptv.program_version,
               psv.course_type,
               esptv.fee_cat,
               esptv.location_cd,
               esptv.attendance_mode,
               esptv.attendance_type,
               sca.course_attempt_status,
               sca.cal_type,
               sca.commencement_dt,
               sca.discontinued_dt,
               psv.short_title,
               esptv.key_program_flag
       FROM    igs_en_spa_terms esptv,
               igs_ps_ver_all psv,
               igs_en_stdnt_ps_att_all sca,
               igs_lookups_view scas
       WHERE   esptv.program_cd = psv.course_cd
       AND     esptv.program_version = psv.version_number
       AND     esptv.program_cd = sca.course_cd
       AND     esptv.program_version = sca.version_number
       AND     esptv.person_id = sca.person_id
       AND     esptv.person_id = cp_n_person_id
       AND    (esptv.term_cal_type = cp_v_load_cal_type
       AND     esptv.term_sequence_number = cp_n_load_ci_seq_num)
       AND    ((g_c_fee_calc_mthd in (g_v_program, g_v_career)) OR
                (esptv.key_program_flag = cp_v_key_program_flag AND
                g_c_fee_calc_mthd = g_v_primary_career))
       AND    sca.course_attempt_status = scas.lookup_code
       AND    scas.lookup_type = cp_v_lookup_type
       AND    scas.fee_ass_ind = cp_v_fee_ass_ind
       AND    esptv.fee_cat = cp_v_fee_cat;

    l_v_person_name hz_parties.party_name%TYPE;
    l_v_currency_cd igs_fi_fee_cat_all.currency_cd%TYPE;

    TYPE t_fee_type_typ IS TABLE OF igs_fi_fee_type_all.fee_type%TYPE INDEX BY BINARY_INTEGER;
    tbl_fee_type t_fee_type_typ;
    l_b_found    BOOLEAN;
    l_n_waiver_amount NUMBER;
    l_v_return_status VARCHAR2(10);
    l_n_msg_count NUMBER;
    l_v_msg_data  VARCHAR2(2000);

    CURSOR cur_fee_cat(cp_n_person_id   IN igs_en_stdnt_ps_att.person_id%TYPE,
                       cp_v_course_cd   IN igs_en_stdnt_ps_att.course_cd%TYPE) IS
      SELECT fee_cat
      FROM igs_en_stdnt_ps_att
      WHERE person_id = cp_n_person_id
      AND course_cd = cp_v_course_cd;

    l_v_fee_cat      igs_en_stdnt_ps_att.fee_cat%TYPE;

    FUNCTION finpl_sum_fee_ass_item (
                        p_person_id                             IGS_FI_FEE_AS_ITEMS.person_id%TYPE,
                        p_status                                IGS_FI_FEE_AS_ITEMS.status%TYPE,
                        p_fee_type                              IGS_FI_FEE_AS_ITEMS.fee_type%TYPE,
                        P_fee_cat                               IGS_FI_FEE_AS_ITEMS.fee_cat%TYPE,
                        p_fee_cal_type                          IGS_FI_FEE_AS_ITEMS.fee_cal_type%TYPE,
                        p_fee_ci_sequence_number                IGS_FI_FEE_AS_ITEMS.fee_ci_sequence_number%TYPE,
                        p_course_cd                             IGS_FI_FEE_AS_ITEMS.course_cd%TYPE,
                        p_n_crs_version_number                  igs_fi_fee_as_items.crs_version_number%TYPE,
                        p_chg_method_type                       IGS_FI_FEE_AS_ITEMS.s_chg_method_type%TYPE,
                        p_description                           IGS_FI_FEE_AS_ITEMS.description%TYPE,
                        p_chg_elements                          IGS_FI_FEE_AS_ITEMS.chg_elements%TYPE,
                        p_unit_attempt_status                   IGS_FI_FEE_AS_ITEMS.unit_attempt_status%TYPE,
                        p_location_cd                           IGS_FI_FEE_AS_ITEMS.location_cd%TYPE,
                        p_eftsu                                 IGS_FI_FEE_AS_ITEMS.eftsu%TYPE,
                        p_credit_points                         IGS_FI_FEE_AS_ITEMS.credit_points%TYPE,
                        p_amount                                IGS_FI_FEE_AS_ITEMS.amount%TYPE,
                        p_org_unit_cd                           IGS_FI_FEE_AS_ITEMS.org_unit_cd%TYPE,
                        p_trace_on                              VARCHAR2,
                        p_message_name                  OUT NOCOPY      VARCHAR2,
                        p_uoo_id        igs_fi_fee_as_items.uoo_id%TYPE,
                        p_n_unit_type_id                        igs_fi_fee_as_items.unit_type_id%TYPE,
                        p_v_unit_level                          igs_fi_fee_as_items.unit_level%TYPE,
                        p_v_unit_class                          igs_fi_fee_as_items.unit_class%TYPE,
                        p_v_unit_mode                           igs_fi_fee_as_items.unit_mode%TYPE,
                        p_v_unit_cd                             igs_fi_fee_as_items.unit_cd%TYPE,
                        p_n_unit_version                        igs_fi_fee_as_items.unit_version_number%TYPE
                        )
                RETURN BOOLEAN  AS
                /*************************************************************
                  Created By :syam shankar
                  Date Created By :18-sep-2000
                  Purpose :
                  Know limitations, enhancements or remarks
                  Change History
                  Who             When            What
                  pathipat        06-Sep-2005     Bug 4540295 - Fee assessment produce double fees after program version change
                                                  Added parameter p_n_crs_version_number
                  bannamal        08-Jul-2005     Enh#3392088 Campus Privilege Fee.
                                                  Removed the condition that checks for a change in the Charge Method.
                  vchappid        25-jul-2002     bug#2237227, added 'add_flag' with Default value 'N' into the Pl/SQL table t_fee_as_items
                                                  if the record in the pl/sql table matches with values that are passed to the function  and
                                                  the Fee Calculation Method is Primary Career then the Charge Elements, EFTSU, Credit Points and the
                                                  assessment amount are added to the existing PL/SQL table otherwise the values are replaced
                                                  with the values that are passed to the Function

                  (reverse chronological order - newest change first)
                ***************************************************************/
                        v_message_name                  VARCHAR2(30);
                        lv_record_found boolean := FALSE;
                        CURSOR c_fee_type( cp_fee_type      IGS_FI_FEE_AS_ITEMS.FEE_TYPE%TYPE ) IS
                           SELECT description, s_fee_trigger_cat
                           FROM igs_fi_fee_type_all
                           WHERE fee_type = cp_fee_type;

                        v_fee_type_description      igs_fi_fee_type_all.description%type;
                        l_fee_trigger_cat           igs_fi_fee_type_all.s_fee_trigger_cat%TYPE;
                BEGIN
                  log_to_fnd( p_v_module => 'finpl_sum_fee_ass_item',
                              p_v_string => 'Entered finpl_sum_fee_ass_item. Parameters are: ' ||
                                            p_person_id || ', ' || p_status || ', ' || p_fee_type || ', ' || P_fee_cat || ', ' || p_fee_cal_type
                                            || ', ' || p_fee_ci_sequence_number || ', ' || p_course_cd || ', ' || p_chg_method_type || ', ' ||
                                            p_description || ', ' || p_chg_elements || ', ' ||p_unit_attempt_status || ', ' || p_location_cd || ', '||
                                            p_eftsu || ', '|| p_credit_points || ', ' || p_amount || ', ' || p_org_unit_cd || ', ' || p_uoo_id );

                  -- added the trigger cat to the cursor
                  -- bug 1928360
                  OPEN  c_fee_type(p_fee_type);
                  FETCH c_fee_type INTO v_fee_type_description, l_fee_trigger_cat;
                  CLOSE c_fee_type;

                  log_to_fnd( p_v_module => 'finpl_sum_fee_ass_item',
                              p_v_string => 'Looping through Records in PL/SQL Table..');
                  FOR i in 1..gv_as_item_cntr LOOP
                    -- for a flat rate of charge method and fee trigger of institution the course code
                    -- fee cat should not be matched as these would be stored as null in the table.
                    -- bug # 1928360
                    IF (t_fee_as_items(i).person_id       = p_person_id) AND
                       (t_fee_as_items(i).fee_type        = p_fee_type)  AND
                       ((t_fee_as_items(i).fee_cat = p_fee_cat) or (t_fee_as_items(i).fee_cat IS NULL AND p_fee_cat IS NULL)) AND
                       (t_fee_as_items(i).fee_cal_type    = p_fee_cal_type)  AND
                       (t_fee_as_items(i).fee_ci_sequence_number = p_fee_ci_sequence_number)   AND
                       ((t_fee_as_items(i).course_cd = p_course_cd) OR (t_fee_as_items(i).course_cd IS NULL AND p_course_cd IS NULL)) AND
                       ((t_fee_as_items(i).location_cd = p_location_cd) OR
                                    ((t_fee_as_items(i).location_cd IS NULL) AND (p_location_cd IS NULL) ) )         AND
                               -- Added by schodava as a part of the CCR to the Fee Calc Build (Enh# 1851586)
                       ((t_fee_as_items(i).org_unit_cd = p_org_unit_cd) OR
                       ((t_fee_as_items(i).org_unit_cd IS NULL) AND (p_org_unit_cd IS NULL) )) AND
                         ((t_fee_as_items(i).uoo_id = p_uoo_id) OR (t_fee_as_items(i).uoo_id IS NULL AND p_uoo_id IS NULL ))
                    THEN
                      -- If the Fee Calculation Method
                      -- bug#2237227, added 'add_flag' with Default value 'N' into the Pl/SQL table t_fee_as_items
                      -- if the record in the pl/sql table matches with values that are passed to the function  and
                      -- the Fee Calculation Method is Primary Career then the Charge Elements, EFTSU, Credit Points and the
                      -- assessment amount are added to the existing PL/SQL table otherwise the values are replaced
                      -- with the values that are passed to the Function
                      IF ((t_fee_as_items(i).add_flag = 'Y') AND g_c_fee_calc_mthd =g_v_primary_career) THEN
                        t_fee_as_items(i).eftsu            := t_fee_as_items(i).eftsu + p_eftsu;
                        t_fee_as_items(i).credit_points    := t_fee_as_items(i).credit_points + p_credit_points;
                        t_fee_as_items(i).chg_elements     := t_fee_as_items(i).chg_elements + p_chg_elements;
                        t_fee_as_items(i).amount           := t_fee_as_items(i).amount + p_amount;
                        log_to_fnd( p_v_module => 'finpl_sum_fee_ass_item',
                                    p_v_string => 'Record Found. Primary Career so adding..');
                      ELSE
                        t_fee_as_items(i).eftsu            := p_eftsu;
                        t_fee_as_items(i).credit_points    := p_credit_points;
                        t_fee_as_items(i).chg_elements     := p_chg_elements;
                        t_fee_as_items(i).amount           := p_amount;
                        IF g_c_fee_calc_mthd =g_v_primary_career THEN
                           t_fee_as_items(i).add_flag := 'Y';
                        END IF;
                        log_to_fnd( p_v_module => 'finpl_sum_fee_ass_item',
                                    p_v_string => 'Record Found..');
                      END IF;
                      t_fee_as_items(i).chg_method_type            := p_chg_method_type;
                      t_fee_as_items(i).unit_attempt_status        := p_unit_attempt_status;
                      t_fee_as_items(i).unit_type_id               := p_n_unit_type_id;
                      t_fee_as_items(i).unit_mode                  := p_v_unit_mode;
                      t_fee_as_items(i).unit_class                 := p_v_unit_class;
                      t_fee_as_items(i).unit_cd                    := p_v_unit_cd;
                      t_fee_as_items(i).unit_version_number        := p_n_unit_version;
                      t_fee_as_items(i).unit_level                 := p_v_unit_level;
                      lv_record_found := TRUE;
                    END IF;
                  END LOOP;

                  --new record add if not found
                  IF NOT lv_record_found  THEN
                    gv_as_item_cntr := nvl(gv_as_item_cntr,0) + 1;
                    log_to_fnd( p_v_module => 'finpl_sum_fee_ass_item',
                                p_v_string => 'Record Not Found. Adding it as ' || gv_as_item_cntr || ' record in table.');
                    t_fee_as_items(gv_as_item_cntr).person_id               := p_person_id;
                    t_fee_as_items(gv_as_item_cntr).status                  := p_status;
                    t_fee_as_items(gv_as_item_cntr).fee_type                := p_fee_type;
                    t_fee_as_items(gv_as_item_cntr).fee_cat                 := p_fee_cat;
                    t_fee_as_items(gv_as_item_cntr).fee_cal_type            := p_fee_cal_type;
                    t_fee_as_items(gv_as_item_cntr).fee_ci_sequence_number  := p_fee_ci_sequence_number;
                    t_fee_as_items(gv_as_item_cntr).course_cd               := p_course_cd;
                    t_fee_as_items(gv_as_item_cntr).crs_version_number      := p_n_crs_version_number;
                    t_fee_as_items(gv_as_item_cntr).description             := v_fee_type_description;
                    t_fee_as_items(gv_as_item_cntr).chg_method_type         := p_chg_method_type;
                    t_fee_as_items(gv_as_item_cntr).old_chg_elements        := 0;
                    t_fee_as_items(gv_as_item_cntr).chg_elements            := p_chg_elements;
                    t_fee_as_items(gv_as_item_cntr).old_amount              := 0;
                    t_fee_as_items(gv_as_item_cntr).amount                  := p_amount;
                    t_fee_as_items(gv_as_item_cntr).unit_attempt_status     := p_unit_attempt_status;
                    t_fee_as_items(gv_as_item_cntr).location_cd             := p_location_cd;
                    t_fee_as_items(gv_as_item_cntr).old_eftsu               := 0;
                    t_fee_as_items(gv_as_item_cntr).eftsu                   := p_eftsu;
                    t_fee_as_items(gv_as_item_cntr).old_credit_points       := 0;
                    t_fee_as_items(gv_as_item_cntr).credit_points           := p_credit_points;
                    t_fee_as_items(gv_as_item_cntr).chg_rate                := NULL;
                    t_fee_as_items(gv_as_item_cntr).org_unit_cd             := p_org_unit_cd;
                    t_fee_as_items(gv_as_item_cntr).uoo_id                  := p_uoo_id;
                    t_fee_as_items(gv_as_item_cntr).unit_type_id            := p_n_unit_type_id;
                    t_fee_as_items(gv_as_item_cntr).unit_class              := p_v_unit_class;
                    t_fee_as_items(gv_as_item_cntr).unit_mode               := p_v_unit_mode;
                    t_fee_as_items(gv_as_item_cntr).unit_cd                 := p_v_unit_cd;
                    t_fee_as_items(gv_as_item_cntr).unit_level              := p_v_unit_level;
                    t_fee_as_items(gv_as_item_cntr).unit_version_number     := p_n_unit_version;
                    IF g_c_fee_calc_mthd =g_v_primary_career THEN
                        t_fee_as_items(gv_as_item_cntr).add_flag := 'Y';
                    END IF;
                   END IF;
                   RETURN TRUE;
        EXCEPTION
                  WHEN OTHERS THEN
                    log_to_fnd( p_v_module => 'finpl_sum_fee_ass_item',
                                p_v_string => 'From Exception Handler of When Others.');
                    v_message_name := 'IGS_GE_UNHANDLED_EXP';
                    IF (p_trace_on = 'Y') THEN
                        fnd_message.set_name('IGS', v_message_name);
                        Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_SUM_FEE_ASS_ITEM-'||SUBSTR(sqlerrm,1,500));
                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                    END IF;
                    p_message_name := v_message_name;
                    RETURN FALSE;
    END finpl_sum_fee_ass_item;


   PROCEDURE finpl_chk_debt_ret_sched(p_person_id                 igs_fi_fee_as_all.person_id%TYPE,
                                      p_fee_cat                   igs_fi_fee_as_all.fee_cat%TYPE,
                                      p_fee_type                  igs_fi_fee_as_all.fee_type%TYPE,
                                      p_fee_cal_type              igs_fi_fee_as_all.fee_cal_type%TYPE,
                                      p_fee_ci_sequence_number    igs_fi_fee_as_all.fee_ci_sequence_number%TYPE,
                                      p_course_cd                 igs_fi_fee_as_all.course_cd%TYPE,
                                      p_crs_version_number        igs_fi_fee_as_items.crs_version_number%TYPE,
                                      p_course_attempt_status     igs_fi_fee_as_items.course_attempt_status%TYPE,
                                      p_old_ass_amount            igs_fi_fee_as_all.transaction_amount%TYPE,
                                      p_new_ass_amount            igs_fi_fee_as_all.transaction_amount%TYPE,
                                      p_effective_date            DATE,
                                      p_trace_on                  VARCHAR2,
                                      p_d_gl_date                 igs_fi_invln_int_all.gl_date%TYPE,
                                      p_v_s_fee_type              igs_fi_fee_type_all.s_fee_type%TYPE,
                                      p_n_rul_sequence_number     igs_fi_fee_as_items.rul_sequence_number%TYPE,
                                      p_n_scope_rul_seq_num       igs_fi_fee_as_items.scope_rul_sequence_num%TYPE,
                                      p_v_chg_method_type         igs_fi_fee_as_items.s_chg_method_type%TYPE,
                                      p_s_fee_trigger_cat         igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                                      p_v_location_cd             igs_fi_fee_as_items.location_cd%TYPE,
                                      p_v_career                  igs_ps_ver_all.course_type%TYPE,
                                      p_elm_rng_order_name        igs_fi_f_typ_ca_inst_all.elm_rng_order_name%TYPE,
                                      p_attendance_mode           igs_fi_fee_as_items.attendance_mode%TYPE,
                                      p_attendance_type           igs_fi_fee_as_items.attendance_type%TYPE,
                                      p_n_max_chg_elements        igs_fi_fee_as_items.max_chg_elements%TYPE
                                      ) AS
/********************************************************************************************************
  CHANGE HISTORY:
  WHO            WHEN            WHAT
  abshriva       17-May-2006     Bug 5113295 - Added check (igs_fi_gen_008.chk_unit_prg_transfer) for units that were
                                 part of Program Transfer.Added cur_disc_dt to select only dcnt_reason_cd.
  pathipat       22-Nov-2005     Bug 4718712 - Added code to log Old and New Amts only if atleast one is non-zero
  bannamal       08-Jul-2005     Enh#3392088 Campus Privilege Fee. Changes done as per TD.
  bannamal       14-Apr-2005     Bug#4297359 ER Registration Fee issue
                                 Modified the call to igs_fi_gen_008.get_complete_withdr_ret_amt to add
                                 a new parameter p_v_nonzero_billable_cp_flag.
  pathipat       07-Sep-2004     Enh 3880438 - Retention Enhancements
                                 Completely revamped retention logic to include Teaching Period retention.
  pathipat       05-Nov-2003     Enh 3117341 - Audit and Special Fees TD
                                 Removed code for retention amount, added call to generic pkg to get amount
  pathipat     12-Sep-2003     Enh 3108052 - Unit Sets in Rate table build
                               Modified TBH calls of igs_Fi_fee_As_items
  sarakshi     13-Sep-2002     Enh#2564643,removed teh reference of subaccount from this procedure
  vvutukur     11-02-2002      Removed the cursor l_c_invoice_id and the check if the retention amount is greater than 0,
                               within which source invoice id is derived. This is done for bug 2195715 as part of SFCR003,
                               as there is no negative adjustment charge crated by Retention.
*********************************************************************************************************/
  -- Local variables
  l_v_retention_level     igs_fi_f_typ_ca_inst_all.retention_level_code%TYPE := NULL;
  l_v_cmp_withdr_ret      igs_fi_f_typ_ca_inst_all.complete_ret_flag%TYPE := NULL;
  l_n_diff_amount         NUMBER := 0.0;
  l_n_retention_amount    NUMBER := 0.0;
  l_v_fee_type_desc       igs_fi_fee_type_all.description%TYPE  := NULL;
  l_v_fee_trig_cat        igs_fi_fee_type_all.s_fee_trigger_cat%TYPE  := NULL;
  l_n_sum_amount          NUMBER := 0.0;

  tbl_unit_status t_unit_status;  -- Table which says whether the corresponding unit record in tbl_fee_as_items_diff table is enrolled unit or discontinued unit
  tbl_enr_disc_dt t_date;         -- Table which has the discontinued dt/enrolled dt for the corresponding unit record in tbl_fee_as_items_diff table

  -- User-defined exceptions
  skip          EXCEPTION;

  -- Cursor to determine Optional Indicator of the fee type
  CURSOR cur_opt_ind(cp_v_fee_type   igs_fi_fee_type_all.fee_type%TYPE) IS
    SELECT optional_payment_ind, description, s_fee_trigger_cat
    FROM igs_fi_fee_type_all
    WHERE fee_type = cp_v_fee_type;

  --- Cursor for getting nonzero_billable_cp_flag from ftci

   CURSOR cur_nz_bill_cp_flag ( cp_v_fee_type           igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                cp_v_fee_cal_type       igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                                cp_n_fee_ci_seq_number  igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE )IS
     SELECT nonzero_billable_cp_flag
     FROM   igs_fi_f_typ_ca_inst_all
     WHERE fee_type = cp_v_fee_type
     AND   fee_cal_type = cp_v_fee_cal_type
     AND   fee_ci_sequence_number = cp_n_fee_ci_seq_number;

   CURSOR cur_fai_dtls (cp_n_fee_ass_item_id igs_fi_fai_dtls.fee_ass_item_id%TYPE) IS
     SELECT fai.*
     FROM igs_fi_fai_dtls fai
     WHERE fee_ass_item_id = cp_n_fee_ass_item_id;

   CURSOR cur_dropped_unit (cp_person_id  hz_parties.party_id%TYPE,
                            cp_course_cd  igs_en_su_attempt_all.course_cd%TYPE,
                            cp_v_fee_ass_ind VARCHAR2,
                            cp_v_lookup_type       igs_lookups_view.lookup_type%TYPE,
                            cp_v_enrp_get_load_apply   VARCHAR2,
                            cp_n_uoo_id igs_en_su_attempt_all.uoo_id%TYPE)  IS
     SELECT discontinued_dt
     FROM   igs_en_su_attempt_all sua,
            igs_lookups_view lkp
     WHERE lkp.lookup_code = sua.unit_attempt_status
     AND   lkp.lookup_type = cp_v_lookup_type
     AND   (sua.no_assessment_ind = cp_v_fee_ass_ind OR cp_v_fee_ass_ind IS NULL)
     AND   sua.person_id = cp_person_id
     AND   sua.course_cd = cp_course_cd
     AND   (igs_en_prc_load.enrp_get_load_apply(sua.cal_type,
                                                sua.ci_sequence_number,
                                                sua.discontinued_dt,
                                                sua.administrative_unit_status,
                                                sua.unit_attempt_status,
                                                sua.no_assessment_ind,
                                                g_v_load_cal_type,
                                                g_n_load_seq_num,
                                                sua.no_assessment_ind ) = cp_v_enrp_get_load_apply )
     AND  sua.uoo_id = cp_n_uoo_id
     AND  (igs_fi_gen_008.chk_unit_prg_transfer(sua.dcnt_reason_cd) = 'N')
     ORDER BY sua.discontinued_dt;

   CURSOR cur_enr_date (cp_person_id hz_parties.party_id%TYPE,
                        cp_course_cd igs_en_su_attempt_all.course_cd%TYPE,
                        cp_n_uoo_id  igs_en_su_attempt_all.uoo_id%TYPE)  IS
     SELECT sua.enrolled_dt
     FROM   igs_en_su_attempt_all sua
     WHERE sua.uoo_id = cp_n_uoo_id
     AND   sua.person_id = cp_person_id
     AND   sua.course_cd = cp_course_cd;

   CURSOR cur_disc_dt (cp_n_person_id hz_parties.party_id%TYPE,
                       cp_v_course_cd igs_en_su_attempt_all.course_cd%TYPE,
                       cp_n_uoo_id  igs_en_su_attempt_all.uoo_id%TYPE)  IS
     SELECT sua.dcnt_reason_cd
     FROM   igs_en_su_attempt_all sua
     WHERE sua.uoo_id = cp_n_uoo_id
     AND   sua.person_id = cp_n_person_id
     AND   sua.course_cd = cp_v_course_cd;

   CURSOR cur_unit_cd (cp_n_uoo_id  igs_fi_fee_as_items.uoo_id%TYPE) IS
    SELECT unit_cd, version_number
    FROM   igs_ps_unit_ofr_opt_all
    WHERE  uoo_id = cp_n_uoo_id;

  l_v_optional_ind      igs_fi_fee_type_all.optional_payment_ind%TYPE := NULL;
  l_v_nz_bill_cp_flag   igs_fi_f_typ_ca_inst_all.nonzero_billable_cp_flag%TYPE;
  l_v_fee_ass_ind       VARCHAR2(1);
  l_n_chg_elements      igs_fi_fee_as_items.chg_elements%TYPE;
  l_n_count             NUMBER;
  l_n_prg_type_level   igs_ps_unit_ver_all.unit_type_id%TYPE;
  l_v_unit_level       igs_ps_unit_ver_all.unit_level%TYPE;
  l_v_unit_class       igs_as_unit_class_all.unit_class%TYPE;
  l_v_unit_mode        igs_as_unit_class_all.unit_mode%TYPE;
  l_v_unit_cd          igs_ps_unit_ofr_opt_all.unit_cd%TYPE;
  l_n_version_num      igs_ps_unit_ofr_opt_all.version_number%TYPE;
  l_n_amount           igs_fi_fee_as_items.amount%TYPE;
  l_v_charge_rate      igs_fi_fee_as_rate.chg_rate%TYPE;
  l_n_uoo_id           igs_fi_fee_as_items.uoo_id%TYPE;
  l_n_old_amount       igs_fi_fee_as_items.amount%TYPE;
  l_d_disc_dt          igs_en_su_attempt_all.enrolled_dt%TYPE;
  l_d_enr_dt           igs_en_su_attempt_all.enrolled_dt%TYPE;
  l_b_rec_found        BOOLEAN;
  l_n_disc_units       NUMBER;
  l_b_flag             BOOLEAN;

  l_v_dcnt_reason_cd   igs_en_su_attempt_all.dcnt_reason_cd%TYPE;

  BEGIN

    log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                p_v_string => 'Entered finpl_chk_debt_ret_sched. Parameters are: ' ||
                              p_person_id || ', ' || p_fee_cat || ', ' || p_fee_type || ', ' || p_fee_cal_type || ', ' ||
                              p_fee_ci_sequence_number || ', ' || ', ' || p_course_cd || ', ' ||
                              p_old_ass_amount || ', ' || p_new_ass_amount || ', ' || TO_CHAR(p_effective_date, 'DD-MON-YYYY') ||', '||
                              TO_CHAR(p_d_gl_date, 'DD-MON-YYYY'));

    IF (p_trace_on = 'Y') THEN
       -- Old and New Amounts need not be logged in the log file if both are zero.
       IF (p_old_ass_amount > 0 OR p_new_ass_amount > 0) THEN
           fnd_file.new_line(fnd_file.log);
           fnd_message.set_name('IGS', 'IGS_FI_ST_DT_ASS_AMT');
           fnd_message.set_token('OLD_AMT', TO_CHAR(p_old_ass_amount));
           fnd_file.put_line (fnd_file.log, fnd_message.get);
           fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'NEW_AMOUNT') || ': ' || TO_CHAR(p_new_ass_amount));
           fnd_file.new_line(fnd_file.log);
       END IF;
    END IF;

    -- If the Fee Type has Optional Indicator set to 'Y', Retention is not applicable. Return 0.0
    OPEN cur_opt_ind(p_fee_type);
    FETCH cur_opt_ind INTO l_v_optional_ind, l_v_fee_type_desc, l_v_fee_trig_cat;
    CLOSE cur_opt_ind;

    IF l_v_optional_ind = 'Y' THEN
       log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                   p_v_string => 'Fee Type - ' || p_fee_type ||' is Optional. Retention not applicable. Return. ');

       RETURN;
    END IF;

    -- Obtain values of Retention Level and Complete Withdrawal Retention checkbox from FTCI
    igs_fi_gen_008.get_retention_params(p_v_fee_cal_type            => p_fee_cal_type,
                                        p_n_fee_ci_sequence_number  => p_fee_ci_sequence_number,
                                        p_v_fee_type                => p_fee_type,
                                        p_v_ret_level               => l_v_retention_level,
                                        p_v_complete_withdr_ret     => l_v_cmp_withdr_ret);
    log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                p_v_string => 'Retention Params - Retention Level: ' || l_v_retention_level ||' Complete Withdrawal Flag: '||l_v_cmp_withdr_ret);

    -- Calculate the Difference Amount
    -- This Amount is used in Fee Period Retention or when the Complete Withdrawal Retention Flag is 'Y'
    l_n_diff_amount := NVL(p_new_ass_amount,0) - NVL(p_old_ass_amount,0);
    log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                p_v_string => 'Diff between summed up New and Old Amounts = ' || l_n_diff_amount);


    -- Based on Retention Params, different methods of calculating retention are used.
    IF (l_v_cmp_withdr_ret = 'Y') THEN

        -- Retention is applicable only for downward adjustments. For upward adj, do not check for retention
        IF (l_n_diff_amount >= 0) THEN
           log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                       p_v_string => 'Complete Withdrawal Retention : Diff Amount >= 0, so return without any retention');
           RETURN;
        END IF;
        -- If downward adjustment has happened, then determine the Retention Amount applicable
        log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                    p_v_string => 'Complete Withdrawal Retention : Invoking igs_fi_gen_008.get_complete_withdr_ret_amt');
        OPEN cur_nz_bill_cp_flag( p_fee_type, p_fee_cal_type, p_fee_ci_sequence_number );
        FETCH cur_nz_bill_cp_flag INTO l_v_nz_bill_cp_flag;
        CLOSE cur_nz_bill_cp_flag;
        -- Included the parameter p_v_nonzero_billable_cp_flag in the call to get_complete_withdr_ret_amt
        l_n_retention_amount := igs_fi_gen_008.get_complete_withdr_ret_amt(p_n_person_id               => p_person_id,
                                                                           p_v_course_cd               => p_course_cd,
                                                                           p_v_load_cal_type           => g_v_load_cal_type,
                                                                           p_n_load_ci_sequence_number => g_n_load_seq_num,
                                                                           p_n_diff_amount             => l_n_diff_amount,
                                                                           p_v_fee_type                => p_fee_type,
                                                                           p_v_nonzero_billable_cp_flag  => l_v_nz_bill_cp_flag);
        log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                    p_v_string => 'Complete Withdrawal Retention - Retention Amount Derived: ' || l_n_retention_amount);

        IF NVL(l_n_retention_amount, 0.0) > 0.0 THEN
             log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                         p_v_string => 'Complete Withdrawal Retention - Retention Amount > 0, invoking create_retention_charge.');
             IF (p_trace_on = 'Y') THEN
               fnd_file.new_line(fnd_file.log);
               fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'RET_LEVEL') || ': ' || igs_fi_gen_gl.get_lkp_meaning('IGS_FI_RET_LEVEL', l_v_retention_level));
               fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'WITHDWR_RET') || ': ' || igs_fi_gen_gl.get_lkp_meaning('YES_NO', l_v_cmp_withdr_ret));
             END IF;
             create_retention_charge( p_n_person_id               => p_person_id,
                                      p_v_course_cd               => p_course_cd,
                                      p_v_fee_cal_type            => p_fee_cal_type,
                                      p_n_fee_ci_sequence_number  => p_fee_ci_sequence_number,
                                      p_v_fee_type                => p_fee_type,
                                      p_v_fee_cat                 => p_fee_cat,
                                      p_d_gl_date                 => TRUNC(p_d_gl_date),
                                      p_n_uoo_id                  => NULL,
                                      p_n_amount                  => l_n_retention_amount,
                                      p_v_fee_type_desc           => l_v_fee_type_desc,
                                      p_v_fee_trig_cat            => l_v_fee_trig_cat,
                                      p_trace_on                  => p_trace_on);
        END IF;  -- End if for l_n_retention_amount > 0.0

    ELSIF (l_v_cmp_withdr_ret = 'N') THEN
       -- If Retention Level is set to Fee Period, obtain Retention Amount from Fee Type level
       IF (l_v_retention_level = 'FEE_PERIOD') THEN
           -- Retention is applicable only for downward adjustments. For upward adj, do not check for retention
           IF (l_n_diff_amount >= 0) THEN
              log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                          p_v_string => 'Fee Period retention : Diff Amount >= 0, so return without any retention');
              RETURN;
           END IF;
           -- If downward adjustment has happened, then determine the Retention Amount applicable
           log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                       p_v_string => 'Fee Period retention : Invoking igs_fi_gen_008.get_fee_retention_amount');
           l_n_retention_amount := igs_fi_gen_008.get_fee_retention_amount(p_v_fee_cat                 => p_fee_cat,
                                                                           p_v_fee_cal_type            => p_fee_cal_type,
                                                                           p_n_fee_ci_sequence_number  => p_fee_ci_sequence_number,
                                                                           p_v_fee_type                => p_fee_type,
                                                                           p_n_diff_amount             => l_n_diff_amount);
           log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                       p_v_string => 'Fee Period retention - Retention Amount Derived: ' || l_n_retention_amount);

           IF NVL(l_n_retention_amount, 0.0) > 0.0 THEN
                log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                            p_v_string => 'Fee Period retention - Retention Amount > 0, invoking create_retention_charge.');
                IF (p_trace_on = 'Y') THEN
                  fnd_file.new_line(fnd_file.log);
                  fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'RET_LEVEL') || ': ' || igs_fi_gen_gl.get_lkp_meaning('IGS_FI_RET_LEVEL', l_v_retention_level));
                  fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'WITHDWR_RET') || ': ' || igs_fi_gen_gl.get_lkp_meaning('YES_NO', l_v_cmp_withdr_ret));
                END IF;

                create_retention_charge( p_n_person_id            => p_person_id,
                                      p_v_course_cd               => p_course_cd,
                                      p_v_fee_cal_type            => p_fee_cal_type,
                                      p_n_fee_ci_sequence_number  => p_fee_ci_sequence_number,
                                      p_v_fee_type                => p_fee_type,
                                      p_v_fee_cat                 => p_fee_cat,
                                      p_d_gl_date                 => TRUNC(p_d_gl_date),
                                      p_n_uoo_id                  => NULL,
                                      p_n_amount                  => l_n_retention_amount,
                                      p_v_fee_type_desc           => l_v_fee_type_desc,
                                      p_v_fee_trig_cat            => l_v_fee_trig_cat,
                                      p_trace_on                  => p_trace_on);
           END IF;  -- End if for l_n_retention_amount > 0.0

       -- If Retention Level is set to Teach Period, obtain Retention Amount from FTCI + Teach Period level
       ELSIF (l_v_retention_level = 'TEACH_PERIOD') THEN

           log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                       p_v_string => 'Teach Period level Retention : Looping across pl/sql tbl t_fee_as_items. Count = '||t_fee_as_items.COUNT);

           IF t_fee_as_items.COUNT > 0 THEN
               FOR i in t_fee_as_items.FIRST..t_fee_as_items.LAST LOOP
                   BEGIN
                       IF t_fee_as_items.EXISTS(i) THEN
                           log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                       p_v_string => 'Teach Period level Retention : Record '|| i ||
                                                     ' - Uoo ID: '||t_fee_as_items(i).uoo_id||
                                                     ' Status: '||t_fee_as_items(i).status);

                           -- Only charges that have not been declined/reversed will be processed
                           IF (t_fee_as_items(i).status <> 'D') THEN
                             IF (t_fee_as_items(i).uoo_id IS NULL) THEN
                               IF (NVL(t_fee_as_items(i).old_amount, 0) > 0) THEN
                                  log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                              p_v_string => 'Teach Period level Retention: t_fee_as_items('||i||').old_amount < 0');
                                  tbl_fee_as_items.DELETE;
                               --The table tbl_fee_as_items is loaded with unit records of previous assessment
                                  FOR rec_fai_dlts IN cur_fai_dtls(t_fee_as_items(i).fee_ass_item_id)
                                  LOOP
                                    log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                p_v_string => 'Teach Period level Retention: UOO Id: '||rec_fai_dlts.uoo_id);
                                    finpl_get_unit_type_level(rec_fai_dlts.uoo_id, l_n_prg_type_level, l_v_unit_level);
                                    finpl_get_unit_class_mode(rec_fai_dlts.uoo_id, l_v_unit_class, l_v_unit_mode);
                                    OPEN cur_unit_cd (rec_fai_dlts.uoo_id);
                                    FETCH cur_unit_cd INTO l_v_unit_cd, l_n_version_num;
                                    IF cur_unit_cd%NOTFOUND THEN
                                      l_v_unit_cd := NULL;
                                      l_n_version_num := NULL;
                                    END IF;
                                    CLOSE cur_unit_cd;
                                    l_n_count := tbl_fee_as_items.COUNT + 1;
                                    log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                p_v_string => 'Teach Period level Retention: Adding record to tbl_fee_as_items at position - '||l_n_count);
                                    tbl_fee_as_items(l_n_count).chg_elements           := rec_fai_dlts.chg_elements;
                                    tbl_fee_as_items(l_n_count).person_id              := p_person_id;
                                    tbl_fee_as_items(l_n_count).fee_type               := p_fee_type;
                                    tbl_fee_as_items(l_n_count).fee_cat                := p_fee_cat;
                                    tbl_fee_as_items(l_n_count).fee_cal_type           := p_fee_cal_type;
                                    tbl_fee_as_items(l_n_count).fee_ci_sequence_number := p_fee_ci_sequence_number;
                                    tbl_fee_as_items(l_n_count).course_cd              := p_course_cd;
                                    tbl_fee_as_items(l_n_count).chg_method_type        := p_v_chg_method_type;
                                    tbl_fee_as_items(l_n_count).unit_attempt_status    := rec_fai_dlts.unit_attempt_status;
                                    tbl_fee_as_items(l_n_count).location_cd            := rec_fai_dlts.location_cd;
                                    tbl_fee_as_items(l_n_count).org_unit_cd            := rec_fai_dlts.org_unit_cd;
                                    tbl_fee_as_items(l_n_count).class_standing         := rec_fai_dlts.class_standing;
                                    tbl_fee_as_items(l_n_count).uoo_id                 := rec_fai_dlts.uoo_id;
                                    tbl_fee_as_items(l_n_count).unit_set_cd            := rec_fai_dlts.unit_set_cd;
                                    tbl_fee_as_items(l_n_count).us_version_number      := rec_fai_dlts.us_version_number;
                                    tbl_fee_as_items(l_n_count).unit_type_id           := l_n_prg_type_level;
                                    tbl_fee_as_items(l_n_count).unit_class             := l_v_unit_class;
                                    tbl_fee_as_items(l_n_count).unit_mode              := l_v_unit_mode;
                                    tbl_fee_as_items(l_n_count).unit_cd                := l_v_unit_cd;
                                    tbl_fee_as_items(l_n_count).unit_level             := l_v_unit_level;
                                    tbl_fee_as_items(l_n_count).unit_version_number    := l_n_version_num;
                                    tbl_fee_as_items(l_n_count).status                 := t_fee_as_items(i).status;
                                  END LOOP;

                                  l_v_fee_ass_ind := NULL;

                                  IF (p_v_s_fee_type = gcst_tuition_other OR  p_v_s_fee_type = gcst_other) THEN
                                     IF g_v_include_audit = 'Y' THEN
                                        l_v_fee_ass_ind := NULL;   -- Consider All units
                                     ELSE
                                        l_v_fee_ass_ind := 'N';  -- Consider only non-auditable units
                                     END IF;
                                  -- For Audit Fee Type, ONLY auditable units are considered, irrespective of the profile value
                                  ELSIF (p_v_s_fee_type = g_v_audit) THEN
                                     l_v_fee_ass_ind := 'Y';   -- Consider only auditable units
                                  END IF;

                                  tbl_fee_as_items_diff.DELETE;
                                  tbl_unit_status.DELETE;
                                  tbl_enr_disc_dt.DELETE;

                            -- The table tbl_fee_as_items_diff is loaded with diff records between previous assessment and current assessment
                            -- The table tbl_unit_status says whether the corresponding unit record in tbl_fee_as_items_diff is dropped or enrolled
                            -- The table tbl_enr_disc_dt has the discontinued dt/enrolled dt for the corresponding unit record in tbl_fee_as_items_diff

                               --Add record to tbl_fee_as_items_diff only if its not present in the old assessment.
                               -- i.e. the unit details of enrolled units after the previous assessment
                                  IF p_s_fee_trigger_cat = gcst_institutn THEN
                                -- In case of Institution fee type the unit level details are obtained from the plsql table tbl_fai_unit_dtls.
                                     FOR j IN 1..tbl_fai_unit_dtls.COUNT
                                     LOOP
                                        l_b_rec_found := FALSE;
                                        FOR k IN 1..tbl_fee_as_items.COUNT
                                        LOOP
                                          IF tbl_fai_unit_dtls(j).uoo_id = tbl_fee_as_items(k).uoo_id THEN
                                            l_b_rec_found := TRUE;
                                            EXIT;
                                          END IF;
                                        END LOOP;

                                        IF (l_b_rec_found = FALSE) THEN
                                           l_n_count := tbl_fee_as_items_diff.COUNT + 1;
                                           tbl_fee_as_items_diff(l_n_count).chg_elements           := tbl_fai_unit_dtls(j).chg_elements;
                                           tbl_fee_as_items_diff(l_n_count).person_id              := p_person_id;
                                           tbl_fee_as_items_diff(l_n_count).fee_type               := p_fee_type;
                                           tbl_fee_as_items_diff(l_n_count).fee_cat                := p_fee_cat;
                                           tbl_fee_as_items_diff(l_n_count).fee_cal_type           := p_fee_cal_type;
                                           tbl_fee_as_items_diff(l_n_count).fee_ci_sequence_number := p_fee_ci_sequence_number;
                                           tbl_fee_as_items_diff(l_n_count).course_cd              := p_course_cd;
                                           tbl_fee_as_items_diff(l_n_count).chg_method_type        := p_v_chg_method_type;
                                           tbl_fee_as_items_diff(l_n_count).unit_attempt_status    := tbl_fai_unit_dtls(j).unit_attempt_status;
                                           tbl_fee_as_items_diff(l_n_count).location_cd            := tbl_fai_unit_dtls(j).location_cd;
                                           tbl_fee_as_items_diff(l_n_count).org_unit_cd            := tbl_fai_unit_dtls(j).org_unit_cd;
                                           tbl_fee_as_items_diff(l_n_count).class_standing         := tbl_fai_unit_dtls(j).class_standing;
                                           tbl_fee_as_items_diff(l_n_count).uoo_id                 := tbl_fai_unit_dtls(j).uoo_id;
                                           tbl_fee_as_items_diff(l_n_count).unit_set_cd            := tbl_fai_unit_dtls(j).unit_set_cd;
                                           tbl_fee_as_items_diff(l_n_count).us_version_number      := tbl_fai_unit_dtls(j).us_version_number;
                                           tbl_fee_as_items_diff(l_n_count).unit_type_id           := tbl_fai_unit_dtls(j).unit_type_id;
                                           tbl_fee_as_items_diff(l_n_count).unit_class             := tbl_fai_unit_dtls(j).unit_class;
                                           tbl_fee_as_items_diff(l_n_count).unit_mode              := tbl_fai_unit_dtls(j).unit_mode;
                                           tbl_fee_as_items_diff(l_n_count).unit_cd                := tbl_fai_unit_dtls(j).unit_cd;
                                           tbl_fee_as_items_diff(l_n_count).unit_level             := tbl_fai_unit_dtls(j).unit_level;
                                           tbl_fee_as_items_diff(l_n_count).unit_version_number    := tbl_fai_unit_dtls(j).unit_version_number;
                                           tbl_fee_as_items_diff(l_n_count).status                 := t_fee_as_items(i).status;
                                           tbl_unit_status(l_n_count) := 'E';
                                           OPEN cur_enr_date(p_person_id, p_course_cd, tbl_fai_unit_dtls(j).uoo_id);
                                           FETCH cur_enr_date INTO l_d_enr_dt;
                                           CLOSE cur_enr_date ;
                                           tbl_enr_disc_dt(l_n_count) := l_d_enr_dt;
                                        END IF;
                                     END LOOP;


                                  ELSE
                                -- In case of Non-Institution fee type the unit level details are obtained from the plsql table t_fee_as_items.
                                    log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                p_v_string => 'Teach Period level Retention: Looping across Main table, t_fee_as_items');
                                    FOR j IN 1..t_fee_as_items.COUNT
                                    LOOP
                                      IF ( t_fee_as_items(j).fee_type = p_fee_type AND t_fee_as_items(i).course_cd = p_course_cd AND
                                           t_fee_as_items(j).old_amount = 0 ) THEN
                                        l_b_rec_found := FALSE;
                                        log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                    p_v_string => 'Teach Period level Retention: Looping across Prev Assmnt table, tbl_fee_as_items');
                                        FOR k IN 1..tbl_fee_as_items.COUNT
                                        LOOP
                                          IF t_fee_as_items(j).uoo_id = tbl_fee_as_items(k).uoo_id THEN
                                            log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                        p_v_string => 'Teach Period level Retention: Found same record in Prev Assmnt and Main table');
                                            l_b_rec_found := TRUE;
                                            EXIT;
                                          END IF;
                                        END LOOP;
                                        IF (l_b_rec_found = FALSE) THEN
                                          log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                      p_v_string => 'Teach Period level Retention: Did not find record in main table, so adding '||
                                                                    'new record in Diff table, tbl_fee_as_items_diff with status Enrolled');
                                          l_n_count := tbl_fee_as_items_diff.COUNT + 1;
                                          tbl_fee_as_items_diff(l_n_count) := t_fee_as_items(j);
                                          tbl_unit_status(l_n_count) := 'E';
                                          OPEN cur_enr_date(p_person_id, p_course_cd, t_fee_as_items(j).uoo_id);
                                          FETCH cur_enr_date INTO l_d_enr_dt;
                                          CLOSE cur_enr_date ;
                                          tbl_enr_disc_dt(l_n_count) := l_d_enr_dt;
                                        END IF;
                                      END IF;
                                    END LOOP;
                                  END IF;
                                  l_n_disc_units := 0;

                               --Add unit records to tbl_fee_as_items_diff which were assessed in the previous assessment and dropped after tbat.
                                  log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                              p_v_string => 'Teach Period level Retention: Looping across tbl_fee_as_items for adding dropped units');
                                  FOR j IN 1..tbl_fee_as_items.COUNT
                                  LOOP
                                    -- Replace p_course_cd being passed as input to this cursor with tbl_fee_as_items(j).course_cd
                                    OPEN cur_dropped_unit(p_person_id, tbl_fee_as_items(j).course_cd,l_v_fee_ass_ind,
                                                          'UNIT_ATTEMPT_STATUS', 'N', tbl_fee_as_items(j).uoo_id);
                                    FETCH cur_dropped_unit INTO l_d_disc_dt;
                                    CLOSE cur_dropped_unit;
                                    IF l_d_disc_dt IS NOT NULL THEN
                                      l_n_disc_units := l_n_disc_units + 1;
                                      l_n_count := tbl_fee_as_items_diff.COUNT + 1;
                                      log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                  p_v_string => 'Teach Period level Retention: Adding dropped unit in tbl_fee_as_items_diff at '||l_n_count);
                                      tbl_fee_as_items_diff(l_n_count) := tbl_fee_as_items(j);
                                      tbl_unit_status(l_n_count) := 'D';
                                      tbl_enr_disc_dt(l_n_count) := l_d_disc_dt;
                                    END IF;
                                  END LOOP;

                                  l_b_flag := TRUE;
                                  l_n_old_amount := NVL(t_fee_as_items(i).old_amount, 0);
                                  l_n_amount :=  NVL(t_fee_as_items(i).old_amount, 0);
                                  IF l_n_disc_units > 0 THEN
                               -- sort the records using the discontinued dt/enrolled dt
                                     log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                 p_v_string => 'Calling finpl_retn_sort_table since there are dropped units');
                                     finpl_retn_sort_table(tbl_fee_as_items_diff, tbl_unit_status, tbl_enr_disc_dt);

                                     log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                 p_v_string => 'Teach Period level Retention: Looping across tbl_fee_as_items_diff');
                               --For each diff record finp_clc_ass_amnt is called and retention is calculated if the unit in context is dropped.
                                     FOR j IN 1..tbl_fee_as_items_diff.COUNT
                                     LOOP
                                       l_b_flag := FALSE;
                                       tbl_fee_as_items_dummy.DELETE;
                                       IF (tbl_unit_status(j) = 'D') THEN
                              --If the unit in context is dropped load the table tbl_fee_as_items_dummy with the records of previous calculation excluding the dropped unit
                                         l_n_disc_units := l_n_disc_units - 1;
                                         IF (l_n_disc_units < 0) THEN
                                           IF j = tbl_fee_as_items_diff.COUNT THEN
                                             log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                         p_v_string => 'Teach Period level Retention: Only one unit is dropped or the dropped unit'||
                                                                       ' is the last record in tbl_fee_as_items_diff');
                                             l_b_flag := TRUE;
                                             l_n_uoo_id := tbl_fee_as_items_diff(j).uoo_id;
                                             EXIT;
                                           END IF;
                                         END IF;

                                         log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                     p_v_string => 'Teach Period level Retention: Looping across tbl_fee_as_items');
                                         FOR k IN 1..tbl_fee_as_items.COUNT
                                         LOOP
                                           IF (tbl_fee_as_items(k).uoo_id <> tbl_fee_as_items_diff(j).uoo_id) THEN
                                             log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                         p_v_string => 'Teach Period level Retention: Add to dummy table tbl_fee_as_items_dummy, '||
                                                                       'all units exluding the dropped unit from the Prev assmnt table, tbl_fee_as_items');
                                             l_n_count := tbl_fee_as_items_dummy.COUNT + 1;
                                             tbl_fee_as_items_dummy(l_n_count) := tbl_fee_as_items(k);
                                           END IF;
                                         END LOOP;
                                         tbl_fee_as_items := tbl_fee_as_items_dummy;

                                       ELSIF (tbl_unit_status(j) = 'E') THEN
                              --If the unit in context is enrolled load the table tbl_fee_as_items_dummy with the records of previous calculation
                              --including the enrolled unit
                                         IF j = tbl_fee_as_items_diff.COUNT THEN
                                           l_b_flag := FALSE;
                                           EXIT;
                                         END IF;

                                         FOR k IN 1..tbl_fee_as_items.COUNT
                                         LOOP
                                           l_n_count := tbl_fee_as_items_dummy.COUNT + 1;
                                           tbl_fee_as_items_dummy(l_n_count) := tbl_fee_as_items(k);
                                         END LOOP;
                                         l_n_count := tbl_fee_as_items_dummy.COUNT + 1;
                                         tbl_fee_as_items_dummy(l_n_count) := tbl_fee_as_items_diff(j);
                                         tbl_fee_as_items := tbl_fee_as_items_dummy;
                                       END IF;
                                       l_n_chg_elements := 0;
                                       FOR k IN 1..tbl_fee_as_items_dummy.COUNT
                                       LOOP
                                         l_n_chg_elements := l_n_chg_elements + tbl_fee_as_items_dummy(k).chg_elements;
                                       END LOOP;
                                       l_n_amount := 0;

                                       log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                   p_v_string => 'Calling finp_clc_ass_amnt');

                                       IF (finp_clc_ass_amnt(p_effective_dt              =>  p_effective_date,
                                                p_person_id                          =>  p_person_id,
                                                p_course_cd                          =>  p_course_cd,
                                                p_course_version_number              =>  p_crs_version_number,
                                                p_course_attempt_status              =>  p_course_attempt_status,
                                                p_fee_type                           =>  p_fee_type,
                                                p_fee_cal_type                       =>  p_fee_cal_type,
                                                p_fee_ci_sequence_number             =>  p_fee_ci_sequence_number,
                                                p_fee_cat                            =>  p_fee_cat,
                                                p_s_fee_type                         =>  p_v_s_fee_type,
                                                p_s_fee_trigger_cat                  =>  p_s_fee_trigger_cat,
                                                p_rul_sequence_number                =>  p_n_rul_sequence_number,
                                                p_charge_method                      =>  p_v_chg_method_type,
                                                p_location_cd                        =>  p_v_location_cd,
                                                p_attendance_type                    =>  p_attendance_type,
                                                p_attendance_mode                    =>  p_attendance_mode,
                                                p_trace_on                           =>  p_trace_on,
                                                p_creation_dt                        =>  p_creation_dt, -- in out
                                                p_charge_elements                    =>  l_n_chg_elements,      -- in out
                                                p_fee_assessment                     =>  l_n_amount,       -- in out
                                                p_charge_rate                        =>  l_v_charge_rate,
                                                p_c_career                           =>  p_v_career,
                                                p_elm_rng_order_name                 =>  p_elm_rng_order_name,
                                                p_n_max_chg_elements                 =>  p_n_max_chg_elements,
                                                p_n_called                           =>  1 ) = FALSE) THEN

                                              log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                              p_v_string => 'finp_clc_ass_amnt returned FALSE. Out Vars: Chg Elms: '
                                                             || l_n_chg_elements || ', Amount: ' || l_n_amount );
                                       ELSE
                                         IF (tbl_unit_status(j) = 'D') THEN
                              --calculate retention only if the unit attempt is dropped
                                            l_n_diff_amount := NVL(l_n_amount,0) - NVL(l_n_old_amount,0);
                                            IF (l_n_diff_amount < 0) THEN
                                               l_n_uoo_id := tbl_fee_as_items_diff(j).uoo_id;
                                               log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                           p_v_string => 'Calling finpl_prc_teach_prd_retn_levl, l_n_diff_amount is '||NVL(l_n_diff_amount,0));
                                               finpl_prc_teach_prd_retn_levl( p_person_id                =>  p_person_id,
                                                                          p_fee_cat                  =>  p_fee_cat,
                                                                          p_fee_type                 =>  p_fee_type,
                                                                          p_fee_cal_type             =>  p_fee_cal_type,
                                                                          p_fee_ci_sequence_number   =>  p_fee_ci_sequence_number,
                                                                          p_course_cd                =>  p_course_cd,
                                                                          p_n_uoo_id                 =>  l_n_uoo_id,
                                                                          p_trace_on                 =>  p_trace_on,
                                                                          p_d_gl_date                =>  p_d_gl_date,
                                                                          p_n_diff_amount            =>  l_n_diff_amount,
                                                                          p_v_retention_level        =>  l_v_retention_level,
                                                                          p_v_cmp_withdr_ret         =>  l_v_cmp_withdr_ret,
                                                                          p_v_fee_type_desc          =>  l_v_fee_type_desc,
                                                                          p_v_fee_trig_cat           =>  l_v_fee_trig_cat );
                                           END IF;
                                         END IF;
                                         l_n_old_amount := l_n_amount;
                                       END IF;
                                     END LOOP;
                                  END IF;
                               END IF;
                             ELSE -- uoo_id not null
                                 -- Calculate the Difference Amount
                                 l_n_diff_amount := NVL(t_fee_as_items(i).amount, 0) - NVL(t_fee_as_items(i).old_amount, 0);

                                 log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                             p_v_string => 'Teach Period level Retention : Difference Amount = ' || l_n_diff_amount ||
                                                           ' UOO Id: '||t_fee_as_items(i).uoo_id);

                                 IF (l_n_diff_amount >= 0) THEN
                                     log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                 p_v_string => 'Teach Period level retention : Diff Amount >= 0, so skip Unit Section');
                                     RAISE skip;
                                 END IF;

                                 -- Check if the unit has been dropped due to a Program Transfer. If yes, then do not invoke retention
                                 OPEN cur_disc_dt(p_person_id, t_fee_as_items(i).course_cd, t_fee_as_items(i).uoo_id);
                                 FETCH cur_disc_dt INTO l_v_dcnt_reason_cd;
                                 CLOSE cur_disc_dt;
                                 IF (igs_fi_gen_008.chk_unit_prg_transfer(l_v_dcnt_reason_cd) = 'Y') THEN
                                       log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                                                   p_v_string => 'Teach Period level Retention: Unit Transferred, UOO_ID: '||t_fee_as_items(i).uoo_id
                                                                  ||' Course Cd: '||t_fee_as_items(i).course_cd||' and Disc Reason: '||l_v_dcnt_reason_cd);
                                       RAISE SKIP;
                                 END IF;

                                 finpl_prc_teach_prd_retn_levl( p_person_id                =>  p_person_id,
                                                                 p_fee_cat                  =>  p_fee_cat,
                                                                 p_fee_type                 =>  p_fee_type,
                                                                 p_fee_cal_type             =>  p_fee_cal_type,
                                                                 p_fee_ci_sequence_number   =>  p_fee_ci_sequence_number,
                                                                 p_course_cd                =>  p_course_cd,
                                                                 p_n_uoo_id                 =>  t_fee_as_items(i).uoo_id,
                                                                 p_trace_on                 =>  p_trace_on,
                                                                 p_d_gl_date                =>  p_d_gl_date,
                                                                 p_n_diff_amount            =>  l_n_diff_amount,
                                                                 p_v_retention_level        =>  l_v_retention_level,
                                                                 p_v_cmp_withdr_ret         =>  l_v_cmp_withdr_ret,
                                                                 p_v_fee_type_desc          =>  l_v_fee_type_desc,
                                                                 p_v_fee_trig_cat           =>  l_v_fee_trig_cat );

                             END IF; -- If uoo_id is null
                           END IF;  -- End if for t_fee_as_items(i).status <> 'D'
                       END IF;  -- End if for t_fee_as_items.EXISTS(i)
                   EXCEPTION
                      WHEN skip THEN
                         -- Do nothing, skip record
                         NULL;
                   END;
               END LOOP;
           END IF;  -- End if for t_fee_as_items.COUNT > 0
       END IF; -- End if for check on l_v_retention_level
    END IF;  -- End if for check on l_v_cmp_withdr_ret

   log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
               p_v_string => 'Returning from finpl_chk_debt_ret_sched');

  EXCEPTION
    WHEN Others THEN
      log_to_fnd( p_v_module => 'finpl_chk_debt_ret_sched',
                  p_v_string => 'From Exception Handler of When Others.');
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_CHK_DEBT_RET_SCHED-'||SUBSTR(SQLERRM,1,500));
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END finpl_chk_debt_ret_sched;

        PROCEDURE finpl_ins_fee_ass(
                p_person_id               hz_parties.party_id%TYPE,
                p_course_cd               igs_en_stdnt_ps_att_all.course_cd%TYPE,
                p_fee_type                igs_fi_f_cat_fee_lbl_all.fee_type%TYPE,
                p_fee_cal_type            igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
                p_fee_ci_sequence_number  igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE,
                p_s_fee_trigger_cat       igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                p_fee_cat                 igs_en_stdnt_ps_att_all.fee_cat%TYPE,
                p_currency                igs_fi_control_all.currency_cd%TYPE,
                p_charge_rate             igs_fi_fee_as_rate.chg_rate%TYPE,
                p_s_fee_type              igs_fi_fee_type_all.s_fee_type%TYPE,
                p_effective_dt            DATE,
                p_trace_on                VARCHAR2,
                p_crs_version_number      igs_fi_fee_as_items.crs_version_number%TYPE,
                p_course_attempt_status   igs_fi_fee_as_items.course_attempt_status%TYPE,
                p_attendance_mode         igs_fi_fee_as_items.attendance_mode%TYPE,
                p_attendance_type         igs_fi_fee_as_items.attendance_type%TYPE,
                p_charge_elements       IN OUT NOCOPY   Igs_fi_fee_as_all.chg_elements%TYPE,
                p_fee_assessment        IN OUT NOCOPY   NUMBER,
                -- Added to initialize the new pl/sql table for Institution related records
                p_fcfl_status           IN igs_fi_f_cat_fee_lbl_all.fee_liability_status%TYPE,
                p_n_rul_sequence_number IN igs_fi_fee_as_items.rul_sequence_number%TYPE,
                p_n_scope_rul_seq_num   IN igs_fi_fee_as_items.scope_rul_sequence_num%TYPE,
                p_v_chg_method_type     IN igs_fi_fee_as_items.s_chg_method_type%TYPE,
                p_v_location_cd         IN igs_fi_fee_as_items.location_cd%TYPE,
                p_v_career              IN igs_ps_ver_all.course_type%TYPE,
                p_elm_rng_order_name    IN igs_fi_f_typ_ca_inst_all.elm_rng_order_name%TYPE,
                p_n_max_chg_elements    IN igs_fi_fee_as_items.max_chg_elements%TYPE) AS

         /*************************************************************************************************
         CHANGE HISTORY:
         WHO             WHEN            WHAT
         abshriva       12-May-2006       Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
         pathipat       22-Nov-2005      Bug 4718712 - Removed code setting t_fee_as_items(i).crs_version_number to
                                         p_crs_version_number when t_fee_as_items(i).course_cd is not null.
         pathipat       14-Oct-2005      Bug 4644004 - Retention amount is not calculated for increment charge method
                                         Added code to set t_fee_as_items(i).crs_version_number to p_crs_version_number
         uudayapr       14-Sep-2005      Bug 4609164 - passed the value of unit_class and unit_mode to the charges Api.
         pathipat       06-Sep-2005      Bug 4540295 - Fee assessment produce double fees after program version change
                                         Used t_Fee_as_items.crs_version_number for inserting into igs_fi_fee_as_items
                                         instead of the local variable l_crs_version_number.
         bannamal       08-Jul-2005      Enh#3392088 Campus Privilege Fee.
                                         Modified the tbh call to fee as items table to include two new columns.
         bannamal       03-Jun-2005      Bug#3442712 Unit Level Fee Assessment Build. Modified the call to igs_fi_fee_as_items_pkg.insert_row
                                         added new parameters unit_type_id, unit_class, unit_mode and unit_level.
         pathipat       07-Sep-2004      Enh 3880438 - Retention Enhancements build
                                         Removed condition checking if new amount < old amount before invoking finpl_chk_debt_ret_sched
         shtatiko       27-JUL-2004      Enh# 3787816, Replaced the call to finpl_charge_is_declined with igs_fi_gen_008.chk_chg_adj.
         pathipat       06-Jul-2004      Bug 3734842 - Added logic to check if records have been created correctly
                                         in IGS_FI_FEE_AS and IGS_FI_FEE_AS_ITEMS tables - added call to finpl_check_header_lines
         UUDAYAPR       17-DEC-2003      BUG#3080983 Modified V_assessment_amount,V_transaction_amount,p_fee_assessment
                                             To Number From Igs_fi_fee_ass_debt_v.Assessment_amount%Type,
                                                     V_manual_entry_ind To Varchar2(1)
                                                    v_last_effective_assessment_dt =  IGS_FI_FEE_ASS_DEBT_V.last_effective_assessment_dt%TYPE TO DATE;
                                         and also the Cursor c_fadv
         pathipat       01-Oct-2003      Bug 3164141 - Added check for Declined Charges
                                         Moved code for logging messages to before the actual insert happens
         pathipat       12-Sep-2003      Enh 3108052 - Unit Sets in Rate Table build
                                         Modified TBH call of igs_fi_fee_as_items
         vvutukur       26-May-2003      Enh#2831572.Financial Accounting Build. Assigned proper value to p_v_residency_cd before calling charges api.
         sarakshi       13-Sep-2002      Enh#2564643,removed teh reference of subaccount from this procedure
         VVUTUKUR       11-02-2002       Removed cursor l_c_invoice_id and related logic reg. the derivation of the source transaction ID.
                                         Since this part of covered  in Charges API. bug 2195715 as part of SFCR003
         rnirwani       17-apr-02        Before invocation to the charges api the orgunit code is also assigned to record group
                                         relating to lines entry for bug# 2317155
         ************************************************************************************************/
       -- Exception raised when insertion into IGS_FI_FEE_AS and IGS_FI_FEE_AS_ITEMS had some errors
          e_unexpected_error              EXCEPTION;

        BEGIN
          DECLARE
                e_one_record_expected           EXCEPTION;

                cst_assessment  CONSTANT        igs_fi_fee_as_all.s_transaction_type%TYPE := 'ASSESSMENT';
                v_chg_rate                      IGS_FI_FEE_AS_RATE.chg_rate%TYPE;
                v_chg_elements                  NUMBER;
                v_course_cd                     igs_en_stdnt_ps_att_all.course_cd%TYPE;
                v_message_name                  VARCHAR2(30);

                l_source_invoice_id igs_fi_inv_int_all.invoice_id%TYPE;
                l_invoice_id igs_fi_inv_int_all.invoice_id%TYPE;
                l_header_rec  igs_fi_charges_api_pvt.header_rec_type;
                l_line_rec    igs_fi_charges_api_pvt.line_tbl_type;
                l_line_rec_dummy    igs_fi_charges_api_pvt.line_tbl_type;
                l_line_id_tbl  igs_fi_charges_api_pvt.line_id_tbl_type;
                l_line_id_tbl_dummy  igs_fi_charges_api_pvt.line_id_tbl_type;
                l_status  VARCHAR2(1);
                l_msg_count NUMBER;
                l_msg_data VARCHAR2(2000);

                l_crs_attempt_status  igs_fi_fee_as_items.course_attempt_status%TYPE;

                v_rec_found             BOOLEAN;
                l_v_invoice_number      igs_fi_inv_int_all.invoice_number%TYPE;
                l_b_charge_declined     BOOLEAN;
                l_v_elm_rng_ord_name    igs_fi_f_typ_ca_inst_all.elm_rng_order_name%TYPE;
                l_v_chg_mthd_typ        igs_fi_f_cat_fee_lbl_all.s_chg_method_type%TYPE;
                l_v_invoice_num         igs_fi_inv_int_all.invoice_number%TYPE;
                l_n_waiver_amt          NUMBER;

                CURSOR  c_chg_method ( cp_fee_cat                igs_fi_f_cat_fee_lbl_all.fee_cat%TYPE,
                                       cp_fee_type               igs_fi_f_cat_fee_lbl_all.fee_type%TYPE,
                                       cp_fee_cal_type           igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
                                       cp_fee_ci_sequence_number igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE) IS
                      SELECT s_chg_method_type, elm_rng_order_name
                      FROM igs_fi_f_cat_fee_lbl_v
                      WHERE fee_cat =  cp_fee_cat
                      AND fee_type =   cp_fee_type
                      AND fee_cal_type = cp_fee_cal_type
                      AND fee_ci_sequence_number = cp_fee_ci_sequence_number;

          BEGIN
                log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                            p_v_string => 'Entered finpl_ins_fee_ass. Parameters are: '
                                          || 'Person Id: '      || p_person_id
                                          || ', Course Cd: '    || p_course_cd
                                          || ', Fee Type: '     || p_fee_type
                                          || ', Fee Cal: '      || p_fee_cal_type
                                          || ', Fee Cal Seq: '  || p_fee_ci_sequence_number
                                          || ', Sys Fee Trig: ' || p_s_fee_trigger_cat
                                          || ', Fee Cat: '      || p_fee_cat
                                          || ', Curr: '         || p_currency
                                          || ', Chg Rate: '     || p_charge_rate
                                          || ', Sys Fee Type: ' || p_s_fee_type
                                          || ', Eff Date: '     || TO_CHAR(p_effective_dt, 'DD-MON-YYYY HH24:MI:SS')
                                          || ', Crs Vers: '     || p_crs_version_number
                                          || ', Att Mode: '     || p_attendance_mode
                                          || ', Att TYpe: '     || p_attendance_type
                                          || ', Chg Elements: ' || p_charge_elements
                                          || ', Fee As Amount: '|| p_fee_assessment
                                          || ', FCFL Status: '  || p_fcfl_status
                                          || ', FCFL Source: '  || g_v_fcfl_source );

                IF p_fee_assessment <= 0 AND g_b_fee_chgs_exists = FALSE THEN

                  log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                              p_v_string => 'Returning with message - Fee assessment transaction record not created.' );
                  RETURN;
                END IF;

                log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                            p_v_string => 'Try inserting Fee As Transaction.' );
                -- Enh# 3167098, For an Institution Fee, Course Code and Fee Category should be NULL (Only if Fee Calc Mthd is not Primary Career)
                IF (p_s_fee_trigger_cat = gcst_institutn
                   AND g_c_fee_calc_mthd <> g_v_primary_career) THEN
                  v_fee_cat := NULL;
                  v_course_cd := NULL;
                ELSE
                  v_fee_cat := p_fee_cat;
                  v_course_cd := p_course_cd;
                END IF;

                v_chg_rate := p_charge_rate;
                v_chg_elements := p_charge_elements;

                log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                            p_v_string => 'Vars to be used: ' || v_fee_cat||','||v_course_cd||','||v_chg_rate||','||v_chg_elements );
                DECLARE
                  lv_diff_amount igs_fi_fee_as_items.amount%type := 0;
                  lv_sum_diff    igs_fi_fee_as_items.amount%type := 0;
                  lv_as_record_ins boolean := FALSE;
                  lv_fee_ass_item_id              IGS_FI_FEE_AS_ITEMS.fee_ass_item_id%TYPE;
                  lv_as_items_rowid               VARCHAR2(25);
                  lv_as_rowid                     VARCHAR2(25);
                  lv_sum_old_amount               igs_fi_fee_as_all.transaction_amount%TYPE := 0;
                  lv_sum_new_amount               igs_fi_fee_as_all.transaction_amount%TYPE := 0;
                  l_v_fai_rowid                   VARCHAR2(25);
                  l_v_fee_as_item_dtl_id          NUMBER;

                BEGIN
                        lv_sum_diff := 0;

                       log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                   p_v_string => 'Looping through records in PL/SQL Table.');

                        FOR i in 1..gv_as_item_cntr LOOP
                            lv_diff_amount := 0;
                            IF t_fee_as_items(i).fee_type = p_fee_type THEN

                                -- A declined charge should not be considered for re-assessment
                                l_b_charge_declined := FALSE;
                                igs_fi_gen_008.chk_chg_adj(
                                     p_n_person_id              => p_person_id,
                                     p_v_location_cd            => t_fee_as_items(i).location_cd,
                                     p_v_course_cd              => t_fee_as_items(i).course_cd,
                                     p_v_fee_cal_type           => t_fee_as_items(i).fee_cal_type,
                                     p_v_fee_cat                => t_fee_as_items(i).fee_cat,
                                     p_n_fee_ci_sequence_number => t_fee_as_items(i).fee_ci_sequence_number,
                                     p_v_fee_type               => t_fee_as_items(i).fee_type,
                                     p_n_uoo_id                 => t_fee_as_items(i).uoo_id,
                                     p_v_transaction_type       => 'ASSESSMENT',
                                     p_n_invoice_id             => NULL,
                                     p_v_invoice_num            => l_v_invoice_number,
                                     p_b_chg_decl_rev           => l_b_charge_declined );

                                IF l_b_charge_declined = FALSE  THEN
                                  /** check diff in amount**/
                                  lv_diff_amount :=  NVL(t_fee_as_items(i).amount,0) - NVL(t_fee_as_items(i).old_amount,0);
                                  lv_sum_old_amount := NVL(lv_sum_old_amount,0) +  NVL(t_fee_as_items(i).old_amount,0);
                                  lv_sum_new_amount := NVL(lv_sum_new_amount,0) +  NVL(t_fee_as_items(i).amount,0);

                                  log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                              p_v_string => 'Charge not declined. Charge level: Old: '
                                                            || NVL(t_fee_as_items(i).old_amount,0) || ', New Amt: '
                                                            || NVL(t_fee_as_items(i).amount,0) );
                                  log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                              p_v_string => 'Cumulative: Old: ' || lv_sum_old_amount || ', New: ' || lv_sum_new_amount);

                                  IF (NVL(lv_diff_amount,0) <> 0)  THEN
                                  /*** to set flag to true for insert into AS table only one record in AS table **/
                                     IF NOT lv_as_record_ins THEN
                                          lv_as_record_ins := TRUE;
                                     END IF;
                                    /** summing up the differential amount for insert into AS Table**/
                                    lv_sum_diff := NVL(lv_sum_diff,0) + NVL(lv_diff_amount,0);
                                  END IF;
                                ELSE
                                  -- If charge is declined, then set status to 'D'.
                                  -- This record will not be processed, hence not inserted into the fee assessment tables
                                  t_fee_as_items(i).status := 'D';
                                  IF (p_trace_on = 'Y') THEN
                                    fnd_message.set_name('IGS', 'IGS_FI_SP_FEE_DECLINED');
                                    fnd_message.set_token('INVOICE_NUM', l_v_invoice_number);
                                    fnd_file.new_line(fnd_file.log);
                                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                                  END IF;
                                  log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                              p_v_string => 'Charge (Number: ' || l_v_invoice_number || ') is declined.' );
                                END IF;
                             END IF;  /** added by syam on 21-NOV-2000 to insert proper sum into amount of as table **/
                        END LOOP;

                        log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                    p_v_string => 'Total: lv_sum_new_amount:' || lv_sum_new_amount || ', lv_sum_old_amount' || lv_sum_old_amount);

                          -- As part of Retention Enhancements build, removed condition  "IF lv_sum_new_amount < lv_sum_old_amount THEN"
                          -- from here. Retention is invoked irrespective of old and new amounts.
                          -- Also passed p_fee_cat and p_course_cd instead of v_fee_cat and v_course_cd
                          log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                      p_v_string => 'Calling finpl_chk_debt_ret_sched');
                          finpl_chk_debt_ret_sched(p_person_id                => p_person_id,
                                                   p_fee_cat                  => p_fee_cat,
                                                   p_fee_type                 => p_fee_type,
                                                   p_fee_cal_type             => p_fee_cal_type,
                                                   p_fee_ci_sequence_number   => p_fee_ci_sequence_number,
                                                   p_course_cd                => p_course_cd,
                                                   p_crs_version_number       => p_crs_version_number,
                                                   p_course_attempt_status    => p_course_attempt_status,
                                                   p_old_ass_amount           => lv_sum_old_amount,
                                                   p_new_ass_amount           => lv_sum_new_amount,
                                                   p_trace_on                 => p_trace_on,
                                                   p_effective_date           => p_effective_dt,
                                                   p_d_gl_date                => TRUNC(p_d_gl_date),
                                                   p_v_s_fee_type             => p_s_fee_type,
                                                   p_n_rul_sequence_number    => p_n_rul_sequence_number,
                                                   p_n_scope_rul_seq_num      => p_n_scope_rul_seq_num,
                                                   p_v_chg_method_type        => p_v_chg_method_type,
                                                   p_s_fee_trigger_cat        => p_s_fee_trigger_cat,
                                                   p_v_location_cd            => p_v_location_cd,
                                                   p_v_career                 => p_v_career,
                                                   p_elm_rng_order_name       => p_elm_rng_order_name,
                                                   p_attendance_mode          => p_attendance_mode,
                                                   p_attendance_type          => p_attendance_type,
                                                   p_n_max_chg_elements       => p_n_max_chg_elements
                                                   );

                      -- modified as a part of fix for Bug # 2021281 (schodava)
                      -- adding the record for institution fee to the new pl/sql table
                      -- For a system fee trigger category of 'INSTITUTION',
                      -- If a record is found in the new pl/sql table for the person and FTCI,
                      -- then update the status of the record in the pl/sql table to the current status of the FCFL.
                      -- else, insert a record in the pl/sql table
                        v_rec_found := FALSE;
                        IF p_s_fee_trigger_cat = gcst_institutn THEN
                                  FOR l_cntr IN 1..g_inst_fee_rec_cntr LOOP
                                       IF p_person_id = l_inst_fee_rec(l_cntr).person_id
                                          AND p_fee_type = l_inst_fee_rec(l_cntr).fee_type
                                          AND p_fee_cal_type           = l_inst_fee_rec(l_cntr).fee_cal_type
                                          AND p_fee_ci_sequence_number = l_inst_fee_rec(l_cntr).fee_ci_sequence_number
                                          THEN
                                         log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                                     p_v_string => 'Institution Case: Updating status from '
                                                                   || l_inst_fee_rec(l_cntr).fcfl_status || ' to status ' || p_fcfl_status );
                                         l_inst_fee_rec(l_cntr).fcfl_status := p_fcfl_status;
                                         v_rec_found := TRUE;
                                         EXIT WHEN v_rec_found;
                                       END IF;
                                  END LOOP;
                                  IF v_rec_found = FALSE THEN
                                       log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                                   p_v_string => 'Institution Case: Adding record to l_inst_fee_rec.');
                                       g_inst_fee_rec_cntr := NVL(g_inst_fee_rec_cntr,0) + 1;
                                       l_inst_fee_rec(g_inst_fee_rec_cntr).person_id := p_person_id;
                                       l_inst_fee_rec(g_inst_fee_rec_cntr).fee_type := p_fee_type;
                                       l_inst_fee_rec(g_inst_fee_rec_cntr).fee_cal_type := p_fee_cal_type;
                                       l_inst_fee_rec(g_inst_fee_rec_cntr).fee_ci_sequence_number := p_fee_ci_sequence_number;
                                       l_inst_fee_rec(g_inst_fee_rec_cntr).fcfl_status := p_fcfl_status;
                                  END IF;
                        END IF;

                        IF lv_as_record_ins THEN
                                DECLARE
                                   l_n_org_id  igs_fi_fee_As_all.ORG_ID%TYPE := igs_ge_gen_003.get_org_id;

                                BEGIN
                                       log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                                   p_v_string => 'Trying to insert records..');
                                       -- If Fee Assessment Debt record has been found (from cursor c_fadv)
                                        -- Message: Inserting Fee Assessment Transaction

                                  log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                              p_v_string => 'Inserting Fee As Record for Amount: ' || lv_sum_diff );
                                --  Modified transaction_dt entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact
                                  igs_fi_fee_as_pkg.insert_row(
                                                x_rowid                   => lv_as_rowid,
                                                x_person_id               => p_person_id,
                                                x_transaction_id          => v_fa_sequence_number,
                                                x_fee_type                => p_fee_type,
                                                x_fee_cal_type            => p_fee_cal_type,
                                                x_fee_ci_sequence_number  => p_fee_ci_sequence_number,
                                                x_fee_cat                 => v_fee_cat,
                                                x_s_transaction_type      => cst_assessment,
                                                x_transaction_dt          => TRUNC(SYSDATE),
                                                x_transaction_amount      => igs_fi_gen_gl.get_formatted_amount(NVL(lv_sum_diff,0)),
                                                x_currency_cd             => p_currency,
                                                x_exchange_rate           => 1,
                                                x_chg_elements            => v_chg_elements,
                                                x_effective_dt            => TRUNC(p_effective_dt),
                                                x_course_cd               => v_course_cd,
                                                x_notification_dt         => NULL,
                                                x_logical_delete_dt       => NULL,
                                                x_comments                => NULL,
                                                x_mode                    => 'R',
                                                x_org_id                  => l_n_org_id );

                                     IF (p_trace_on = 'Y') THEN
                                        fnd_message.set_name('IGS', 'IGS_FI_STUDFEE_ASSESSED_PRG');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                        fnd_file.new_line(fnd_file.log);
                                     END IF;

                                END;

                                FOR i in 1..gv_as_item_cntr LOOP
                                    lv_diff_amount := 0;
                                    IF t_fee_as_items(i).fee_type = p_fee_type THEN
                                          -- The status is set to 'D' if the charge has been declined
                                          -- In such a case no further processing happens for that charge
                                          IF t_fee_as_items(i).status <> 'D' THEN
                                                /** check diff in amount**/
                                                lv_diff_amount :=  NVL(t_fee_as_items(i).amount,0) - NVL(t_fee_as_items(i).old_amount,0);
                                                IF (nvl(lv_diff_amount,0) <> 0)  THEN
                                                    /*** to insert all records  in AS  ITEMs table with difference in amount ***/
                                                    OPEN  c_chg_method (t_fee_as_items(i).fee_cat,
                                                                        t_fee_as_items(i).fee_type,
                                                                        t_fee_as_items(i).fee_cal_type,
                                                                        t_fee_as_items(i).fee_ci_sequence_number);
                                                    FETCH c_chg_method INTO l_v_chg_mthd_typ, l_v_elm_rng_ord_name;
                                                    CLOSE c_chg_method;

                                                    IF t_fee_as_items(i).chg_method_type is NULL THEN
                                                        t_fee_as_items(i).chg_method_type := l_v_chg_mthd_typ;
                                                    END IF;

                                                    IF t_fee_as_items(i).course_cd IS NULL THEN
                                                        t_fee_as_items(i).crs_version_number := NULL;
                                                        l_crs_attempt_status     := NULL;
                                                    END IF;
                                                    -- setting the values for the header record variable to be passed to
                                                    -- charges API. bug # 1851586

                                                    l_header_rec.p_person_id                  := t_fee_as_items(i).person_id;
                                                    l_header_rec.p_fee_type                   := t_fee_as_items(i).fee_type;
                                                    l_header_rec.p_fee_cat                    := t_fee_as_items(i).fee_cat;
                                                    l_header_rec.p_fee_cal_type               := t_fee_as_items(i).fee_cal_type;
                                                    l_header_rec.p_fee_ci_sequence_number     := t_fee_as_items(i).fee_ci_sequence_number;
                                                    l_header_rec.p_course_cd                  := t_fee_as_items(i).course_cd;
                                                    l_header_rec.p_attendance_type            := p_attendance_type;
                                                    l_header_rec.p_attendance_mode            := p_attendance_mode;
                                                    l_header_rec.p_invoice_amount             := nvl(lv_diff_amount,0);
                                                    l_header_rec.p_invoice_creation_date      := SYSDATE;
                                                    l_header_rec.p_invoice_desc               := t_fee_as_items(i).description;
                                                    l_header_rec.p_transaction_type           := cst_assessment;
                                                    l_header_rec.p_currency_cd                := p_currency;
                                                    l_header_rec.p_exchange_rate              := 1;
                                                    l_header_rec.p_effective_date             := p_effective_dt;
                                                    l_header_rec.p_waiver_flag                := NULL;
                                                    l_header_rec.p_waiver_reason              := NULL;
                                                    l_header_rec.p_source_transaction_id      := NULL;

                                                    --initializing the line record variable
                                                    l_line_rec := l_line_rec_dummy;

                                                    -- setting the values for the line record variable to bne passed to the
                                                    -- charges API bug # 1851586
                                                    l_line_rec(1).p_s_chg_method_type     := t_fee_as_items(i).chg_method_type;
                                                    l_line_rec(1).p_description           := t_fee_as_items(i).description;
                                                    l_line_rec(1).p_chg_elements          := t_fee_as_items(i).chg_elements;
                                                    l_line_rec(1).p_amount                := nvl(lv_diff_amount,0);
                                                    l_line_rec(1).p_unit_attempt_status   := t_fee_as_items(i).unit_attempt_status;
                                                    l_line_rec(1).p_eftsu                 := t_fee_as_items(i).eftsu;
                                                    l_line_rec(1).p_credit_points         := t_fee_as_items(i).credit_points;
                                                    l_line_rec(1).p_org_unit_cd           := t_fee_as_items(i).org_unit_cd;
                                                    l_line_rec(1).p_location_cd           := t_fee_as_items(i).location_cd;
                                                    l_line_rec(1).p_uoo_id                := t_fee_as_items(i).uoo_id;
                                                    l_line_rec(1).p_d_gl_date             := TRUNC(p_d_gl_date);
                                                    l_line_rec(1).p_residency_status_cd   := t_fee_as_items(i).residency_status_cd;
                                                    l_line_rec(1).p_unit_type_id          := t_fee_as_items(i).unit_type_id;
                                                    l_line_rec(1).p_unit_level            := t_fee_as_items(i).unit_level;
                                                    l_line_rec(1).p_unit_class            := t_fee_as_items(i).unit_class;
                                                    l_line_rec(1).p_unit_mode             := t_fee_as_items(i).unit_mode;
                                                    -- initializing the line id variable which would accept the out NOCOPY values from the chargtes API
                                                    l_line_id_tbl := l_line_id_tbl_dummy;

                                                    -- invoking the charges API to create a charge against the assessment done.
                                                    log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                                                p_v_string => 'Inserting Charge for Amount: ' || lv_diff_amount );
                                                    igs_fi_charges_api_pvt.create_charge(
                                                                p_api_version => 2.0,
                                                                p_init_msg_list => 'F',
                                                                p_commit => 'F',
                                                                p_header_rec => l_header_rec,
                                                                p_line_tbl => l_line_rec,
                                                                x_invoice_id => l_invoice_id,
                                                                x_line_id_tbl => l_line_id_tbl,
                                                                x_return_status => l_status,
                                                                x_msg_count => l_msg_count,
                                                                x_msg_data => l_msg_data,
                                                                x_waiver_amount => l_n_waiver_amt);

                                                      -- If status returned by the Charges API is not 'S' then raise exception
                                                      IF l_status <> 'S' THEN
                                                          log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                                                      p_v_string => 'Charges API returned with status <> S, stack message and raise exception');

                                                          IF l_msg_count = 1 THEN
                                                               fnd_message.set_encoded(l_msg_data);
                                                          ELSIF l_msg_count > 1 THEN
                                                               FOR l_n_cntr IN 1 .. l_msg_count
                                                               LOOP
                                                                    fnd_message.set_encoded(fnd_msg_pub.get (p_msg_index => l_n_cntr,
                                                                                                             p_encoded => 'T')
                                                                                            );
                                                               END LOOP;
                                                          END IF;
                                                          app_exception.raise_exception;
                                                      END IF;

                                                      IF (p_trace_on = 'Y') THEN
                                                        -- Trace Entry
                                                        IF lv_diff_amount > 0 THEN
                                                          l_v_invoice_num := igs_fi_gen_008.get_invoice_number(l_invoice_id);
                                                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'CHARGE_NUMBER') || ': ' || l_v_invoice_num);
                                                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'CHG_AMOUNT') || ': ' || TO_CHAR(NVL(lv_diff_amount, 0)));
                                                          fnd_file.new_line(fnd_file.log);
                                                        END IF;
                                                      END IF;

                                                      IF (p_s_fee_trigger_cat = gcst_institutn) THEN
                                                        t_fee_as_items(i).residency_status_cd := NULL;
                                                      END IF;

                                                        -- if the error status returned by tehe charges API is success then the insert
                                                        -- to the lines table is made by passing the invoice id.
                                                            lv_as_items_rowid := NULL;
                                                            log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                                                        p_v_string => 'Inserting Fee Assessment Items Record.');

                                                            igs_fi_fee_as_items_pkg.insert_row(
                                                                  x_rowid               =>   lv_as_items_rowid,
                                                                  x_fee_ass_item_id     =>   lv_fee_ass_item_id,
                                                                  x_transaction_id      =>   v_fa_sequence_number,
                                                                  x_person_id           =>   t_fee_as_items(i).person_id,
                                                                  x_status              =>   t_fee_as_items(i).status,
                                                                  x_fee_type            =>   t_fee_as_items(i).fee_type,
                                                                  x_fee_cat             =>   t_fee_as_items(i).fee_cat ,
                                                                  x_fee_cal_type        =>   t_fee_as_items(i).fee_cal_type ,
                                                                  x_fee_ci_sequence_number => t_fee_as_items(i).fee_ci_sequence_number,
                                                                  x_rul_sequence_number =>    t_fee_as_items(i).rul_sequence_number,
                                                                  x_s_chg_method_type   =>   t_fee_as_items(i).chg_method_type,
                                                                  x_description         =>   t_fee_as_items(i).description,
                                                                  x_chg_elements        =>   t_fee_as_items(i).chg_elements,
                                                                  x_amount              =>   igs_fi_gen_gl.get_formatted_amount(NVL(lv_diff_amount,0)),
                                                                  x_fee_effective_dt    =>   TRUNC(p_effective_dt),
                                                                  x_course_cd           =>   t_fee_as_items(i).course_cd,
                                                                  x_crs_version_number =>    t_fee_as_items(i).crs_version_number,
                                                                  x_course_attempt_status => l_crs_attempt_status,
                                                                  x_attendance_mode     =>   p_attendance_mode,
                                                                  x_attendance_type     =>   p_attendance_type,
                                                                  x_unit_attempt_status =>   t_fee_as_items(i).unit_attempt_status,
                                                                  x_location_cd         =>   t_fee_as_items(i).location_cd,
                                                                  x_eftsu               =>   t_fee_as_items(i).eftsu,
                                                                  x_credit_points       =>   t_fee_as_items(i).credit_points,
                                                                  x_logical_delete_date =>   null,
                                                                  X_INVOICE_ID          => l_invoice_id,
                                                                  x_org_unit_cd         =>  t_fee_as_items(i).org_unit_cd,
                                                                  x_class_standing      =>  t_fee_as_items(i).class_standing,
                                                                  x_residency_status_cd =>  t_fee_as_items(i).residency_status_cd,
                                                                  x_uoo_id              => t_fee_as_items(i).uoo_id,
                                                                  x_chg_rate            => igs_fi_gen_gl.get_formatted_amount(t_fee_as_items(i).chg_rate),
                                                                  x_unit_set_cd         => t_fee_as_items(i).unit_set_cd,
                                                                  x_us_version_number   => t_fee_as_items(i).us_version_number,
                                                                  x_unit_type_id        => t_fee_as_items(i).unit_type_id,
                                                                  x_unit_class          => t_fee_as_items(i).unit_class,
                                                                  x_unit_mode           => t_fee_as_items(i).unit_mode,
                                                                  x_unit_level          => t_fee_as_items(i).unit_level,
                                                                  x_scope_rul_sequence_num => p_n_scope_rul_seq_num,
                                                                  x_elm_rng_order_name  => l_v_elm_rng_ord_name,
                                                                  x_max_chg_elements    => p_n_max_chg_elements
                                                                  );

                                                                -- Code for addition of a record in the new pl/sql table
                                                                -- for 'INSTIUTION' fee trigger category is moved from here
                                                                -- to above, before the call to IGS_FI_FEE_AS_PKG.insert_row
                                                                -- This was to handle the case, where NO adjustment was required for the fee.
                                                                -- In this case, the code present at this point was not accessed,
                                                                -- and no record was being created in the pl/sql table. (Bug # 2021281) schodava
                                                END IF;  -- End if for (nvl(lv_diff_amount,0) <> 0)
                                        END IF;  -- End if for t_fee_as_items(i).status <> 'D'
                                    END IF; -- End if for t_fee_as_items(i).fee_type = p_fee_type
                                END LOOP;

                                FOR j IN 1..tbl_fai_unit_dtls.COUNT
                                LOOP
                                  l_v_fai_rowid := NULL;
                                  l_v_fee_as_item_dtl_id := NULL;
                                  log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                  p_v_string => 'Inserting record in IGS_FI_FAI_DTLS with UOO_ID: '||tbl_fai_unit_dtls(j).uoo_id||
                                                ' for Fee Assessment Item ID: '||lv_fee_ass_item_id);
                                  igs_fi_fai_dtls_pkg.insert_row(
                                                          x_rowid                 => l_v_fai_rowid,
                                                          x_fee_as_item_dtl_id    => l_v_fee_as_item_dtl_id,
                                                          x_fee_ass_item_id       => lv_fee_ass_item_id,
                                                          x_fee_cat              => tbl_fai_unit_dtls(j).fee_cat,
                                                          x_course_cd             => tbl_fai_unit_dtls(j).course_cd,
                                                          x_crs_version_number    => tbl_fai_unit_dtls(j).crs_version_number,
                                                          x_unit_attempt_status   => tbl_fai_unit_dtls(j).unit_attempt_status,
                                                          x_org_unit_cd           => tbl_fai_unit_dtls(j).org_unit_cd,
                                                          x_class_standing        => tbl_fai_unit_dtls(j).class_standing,
                                                          x_location_cd           => tbl_fai_unit_dtls(j).location_cd,
                                                          x_uoo_id                => tbl_fai_unit_dtls(j).uoo_id,
                                                          x_unit_set_cd           => tbl_fai_unit_dtls(j).unit_set_cd,
                                                          x_us_version_number     => tbl_fai_unit_dtls(j).us_version_number,
                                                          x_chg_elements          => tbl_fai_unit_dtls(j).chg_elements
                                                          );
                                END LOOP;

                                log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                            p_v_string => 'Checking if Header and Lines match, calling finpl_check_header_lines');
                                -- Check if records have been created correctly in IGS_FI_FEE_AS and IGS_FI_FEE_AS_ITEMS
                                IF NOT finpl_check_header_lines(p_person_id,v_fa_sequence_number) THEN
                                     -- Any error in Header and Lines records, raise error
                                     log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                                                 p_v_string => 'Header and Lines do not match, RAISE e_unexpected_error');
                                     RAISE e_unexpected_error;
                                END IF;

                        END IF;  /** end if for lv_as_record_ins **/
                END;
          END;
          EXCEPTION
             WHEN e_unexpected_error THEN

                IF g_v_wav_calc_flag = 'N' THEN
                  ROLLBACK TO fee_calc_sp;
                END IF;
                log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                            p_v_string => 'From Exception Handler of e_unexpected_error.');
                fnd_message.set_name ('IGS', 'IGS_GE_UNEXPECTED_ERR');
                igs_ge_msg_stack.add;
                app_exception.raise_exception(NULL, NULL, fnd_message.get);

             WHEN e_one_record_expected THEN
                IF g_v_wav_calc_flag = 'N' THEN
                  ROLLBACK TO fee_calc_sp;
                END IF;
                log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                            p_v_string => 'From Exception Handler of e_one_record_expected.' || SUBSTR(sqlerrm,1,500));
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_INS_FEE_ASS-'||SUBSTR(sqlerrm,1,500));
                IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception(Null, Null, fnd_message.get);
             WHEN OTHERS THEN
                IF g_v_wav_calc_flag = 'N' THEN
                  ROLLBACK TO fee_calc_sp;
                END IF;
                log_to_fnd( p_v_module => 'finpl_ins_fee_ass',
                            p_v_string => 'From Exception Handler of When Others.' || SUBSTR(sqlerrm,1,500));
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_INS_FEE_ASS-'||SUBSTR(sqlerrm,1,500));
                IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
          END finpl_ins_fee_ass;

    -------------------------------------------------------------------------------
        FUNCTION finpl_prc_sua_load (
                p_effective_dt                          DATE,
                p_trace_on                              VARCHAR2,
                p_person_id                             hz_parties.party_id%TYPE,
                p_course_cd                             igs_en_stdnt_ps_att_all.course_cd%TYPE,
                p_course_version_number                 igs_en_stdnt_ps_att_all.version_number%TYPE,
                p_unit_cd                               igs_en_su_attempt_h_all.unit_cd%TYPE,
                p_unit_version_number                   igs_en_su_attempt_h_all.version_number%TYPE,
                p_cal_type                              igs_en_su_attempt_h_all.CAL_TYPE%TYPE,
                p_effective_start_dt                    igs_en_su_attempt_h_all.hist_start_dt%TYPE,
                p_effective_end_dt                      igs_en_su_attempt_h_all.hist_end_dt%TYPE,
                p_eftsu                                 igs_fi_fee_as_items.eftsu%TYPE,
                p_credit_points                         igs_fi_fee_as_items.credit_points%TYPE,
                p_s_fee_type                            igs_fi_fee_type_all.s_fee_type%TYPE,
                p_charge_method                         igs_fi_f_typ_ca_inst_all.s_chg_method_type%TYPE,
                p_fee_type                              IGS_FI_FEE_AS_ITEMS.FEE_TYPE%TYPE ,
                p_fee_cat                               IGS_FI_FEE_AS_ITEMS.FEE_CAT%TYPE,
                p_fee_cal_type                          IGS_FI_FEE_AS_ITEMS.FEE_CAL_TYPE%TYPE,
                p_fee_ci_sequence_number                IGS_FI_FEE_AS_ITEMS.fee_ci_sequence_number%TYPE,
                p_unit_attempt_status                   IGS_FI_FEE_AS_ITEMS.unit_attempt_status%TYPE,
                p_location_cd                   IGS_FI_FEE_AS_ITEMS.location_cd%TYPE,
                p_ci_sequence_number                    IGS_FI_FEE_AS_ITEMS.ci_sequence_number%TYPE,
                p_charge_elements               IN OUT NOCOPY   igs_fi_fee_as_all.chg_elements%TYPE,
                p_ret_true_flag                 OUT NOCOPY      BOOLEAN,
                p_message_name                  OUT NOCOPY      VARCHAR2,
                p_s_fee_trigger_cat                     igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                p_uoo_id                                IGS_FI_FEE_AS_ITEMS.UOO_ID%TYPE,
                p_unit_course_cd                        igs_ps_ver_all.course_cd%TYPE,
                p_n_unit_type_id                        igs_fi_fee_as_items.unit_type_id%TYPE,
                p_v_unit_level                          igs_fi_fee_as_items.unit_level%TYPE,
                p_v_unit_mode                           igs_fi_fee_as_items.unit_mode%TYPE
                )         RETURN BOOLEAN  AS
                        -- added the parameter p_s_fee_trigger_cat Bug# 1906022
                        -- since certain processing here would vary for the fee trigger
                        -- generally special handling for INSTITUTN trigger
        BEGIN
          DECLARE
                v_message_name                  VARCHAR2(30);
                v_derived_org_unit_cd           IGS_FI_FEE_AS_ITEMS.org_unit_cd%TYPE;

                l_v_no_assessment_ind           igs_en_su_attempt_all.no_assessment_ind%TYPE;
                l_n_eftsu                       igs_fi_fee_as_items.eftsu%TYPE;
                l_n_credit_points  igs_fi_fee_as_items.credit_points%TYPE;


                CURSOR c_unit_class_att (cp_person_id           igs_en_su_attempt_all.person_id%TYPE,
                                        cp_course_cd            igs_en_su_attempt_all.course_cd%TYPE,
                                        cp_uoo_id              igs_en_su_attempt_all.uoo_id%TYPE ) IS
                        SELECT  unit_class, no_assessment_ind
                        FROM    igs_en_su_attempt_all
                        WHERE   person_id = cp_person_id
                        AND     course_cd = cp_course_cd
                        AND     uoo_id = cp_uoo_id;

                lv_unit_class_att       igs_en_su_attempt_all.unit_class%TYPE;

  -- Added by schodava as a part of the CCR for the Fee Calc (Enh # 1851586) DLD
  -- To find the organization unit code from the Student Attempt Table (For Charge Method of
  -- CREDIT_POINT or PERUNIT)
  CURSOR  c_org_unit_cd(cp_person_id IN igs_en_su_attempt_all.person_id%TYPE,
                        cp_course_cd in igs_en_su_attempt_all.course_cd%TYPE,
                        cp_uoo_id IN igs_en_su_attempt_all.uoo_id%TYPE
                        ) IS
  SELECT  org_unit_cd   -- this column needs to be added as yet to the table as a part of Nov 2001 Build
  FROM    igs_en_su_attempt_all su
  WHERE   su.person_id = cp_person_id
  AND     su.course_cd = cp_course_cd
  AND     su.uoo_id   = cp_uoo_id;

  -- To find the organization unit code from the Student Attempt Table (For Charge Method of
  -- CREDIT_POINT or PERUNIT)Note : If the above cursor c_org_unit_cd returns no rows,the
  -- Organization Unit Code from this cursor is used.
  CURSOR c_org_unit_sec_cd(cp_unit_cd IN igs_ps_unit_ofr_opt_all.unit_cd%TYPE,
                           cp_version_number IN igs_ps_unit_ofr_opt_all.version_number%TYPE,
                           cp_cal_type IN igs_ps_unit_ofr_opt_all.cal_type%TYPE,
                           cp_ci_sequence_number IN igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE,
                           cp_location_cd IN igs_ps_unit_ofr_opt_all.location_cd%TYPE,
                           cp_unit_class IN igs_ps_unit_ofr_opt_all.unit_class%TYPE
                          ) IS
  SELECT owner_org_unit_cd -- this column is added as a part of Unit Section Reference information Build
  FROM   igs_ps_unit_ofr_opt_all uoo
  WHERE  uoo.unit_cd            = cp_unit_cd
  AND    uoo.version_number     = cp_version_number
  AND    uoo.cal_type           = cp_cal_type
  AND    uoo.ci_sequence_number = cp_ci_sequence_number
  AND    uoo.location_cd        = cp_location_cd
  AND    uoo.unit_class         = cp_unit_class;

  -- To find the organization unit code from the Prgoram Version Table (For Charge Method of
  -- FLATRATE)
  CURSOR c_resp_org_unit_cd(cp_course_cd IN igs_ps_ver_all.course_cd%TYPE,
                            cp_version_number IN igs_ps_ver_all.version_number%TYPE
                           )IS
  SELECT responsible_org_unit_cd
  FROM   igs_ps_ver_all v
  WHERE  v.course_cd            = cp_course_cd
  AND    v.version_number       = cp_version_number;

  -- End of Additions made by schodava as a part of Fee Calc CCR
  BEGIN
                log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                            p_v_string => 'Entered finpl_prc_sua_load. Parameters are: '
                                          || 'Effective Dt: '   || TO_CHAR(p_effective_dt, 'DD-MON-YYYY HH24:MI:SS')
                                          || ', Person Id: '    || p_person_id
                                          || ', Course Cd: '    || p_course_cd
                                          || ', Course Ver: '   || p_course_version_number
                                          || ', Unit Cd: '      || p_unit_cd
                                          || ', Unit Ver: '     || p_unit_version_number
                                          || ', Cal Type: '     || p_cal_type
                                          || ', Eff St Dt: '    || TO_CHAR(p_effective_start_dt, 'DD-MON-YYYY HH24:MI:SS')
                                          || ', Eff End Dt: '   || TO_CHAR(p_effective_end_dt, 'DD-MON-YYYY HH24:MI:SS')
                                          || ', Eftsu: '        || p_eftsu
                                          || ', Cr Points: '    || p_credit_points
                                          || ', Sys Fee Type: ' || p_s_fee_type
                                          || ', Chg Mthd: '     || p_charge_method
                                          || ', Fee Type: '     || p_fee_type
                                          || ', Fee Cat: '      || p_fee_cat
                                          || ', Fee Cal Type: ' || p_fee_cal_type
                                          || ', Fee Cal Seq Num: ' || p_fee_ci_sequence_number
                                          || ', Unit Att Stat: '|| p_unit_attempt_status
                                          || ', Loc Cd: '       || p_location_cd
                                          || ', Ci Seq Num: '   || p_ci_sequence_number
                                          || ', Chg Elms: '     || p_charge_elements
                                          || ', Sys Fee Trig Cat: ' || p_s_fee_trigger_cat
                                          || ', Uoo Id: '       || p_uoo_id
                                          || ', Unit Crs Cd: '  || p_unit_course_cd );
                -- Initialize the OUT variable with FALSE
                p_ret_true_flag := FALSE;
                OPEN c_unit_class_att ( p_person_id     ,
                                        p_unit_course_cd,
                                        p_uoo_id );
                FETCH c_unit_class_att INTO lv_unit_class_att, l_v_no_assessment_ind;
                CLOSE c_unit_class_att;

                IF (p_trace_on = 'Y') THEN
                     -- Trace Entry
                     IF (p_charge_method = gcst_flatrate) THEN
                             NULL;
                     ELSE
                          fnd_file.new_line(fnd_file.log);
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_TRIGGER_GROUP', 'UNIT') || ': ' || p_unit_cd);
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'TEACH_CAL_ALT_CD') || ': ' || p_cal_type ||
                                                           '  ' || TO_CHAR(p_effective_start_dt,'DD/MM/YYYY') ||
                                                           '  ' || TO_CHAR(p_effective_end_dt,'DD/MM/YYYY'));
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'LOC') || ': ' || p_location_cd);
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'UNIT_CLASS') || ': ' || lv_unit_class_att);
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'AUDITED') || ': ' || l_v_no_assessment_ind);
                          IF ((p_unit_cd IS NOT NULL) AND (p_unit_version_number IS NOT NULL)) THEN
                             fnd_message.set_name('IGS', 'IGS_FI_UNIT_CD_VERSION');
                             fnd_message.set_token('UNIT_CD', p_unit_cd);
                             fnd_message.set_token('UNIT_VER', TO_CHAR(p_unit_version_number));
                             fnd_file.put_line (fnd_file.log, fnd_message.get);
                          END IF;
                          IF (p_n_unit_type_id IS NULL) THEN
                             fnd_message.set_name('IGS', 'IGS_FI_NO_UNIT_TYPE');
                             fnd_file.put_line (fnd_file.log, fnd_message.get);
                          ELSE
                             fnd_file.put_line (fnd_file.log,
                                                igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'UNIT_PROG_TYP') ||
                                                ': ' || finpl_get_uptl(p_n_unit_type_id));
                          END IF;
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'UNIT_LEVEL') || ': ' || p_v_unit_level);
                          IF (p_v_unit_mode IS NULL) THEN
                            fnd_message.set_name('IGS', 'IGS_FI_NO_UNIT_MODE');
                            fnd_file.put_line (fnd_file.log, fnd_message.get);
                          ELSE
                            fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'UNIT_MODE') || ': ' || p_v_unit_mode);
                          END IF;
                     END IF;
                END IF;

              v_derived_org_unit_cd := NULL;
              -- For Non Institution Fee, check for Org Unit Cd first at Unit level then at Unit Section
              -- Note: Org Unit Code WILL exists at least one level.
              -- For Flat Rate, Fetch it from Program Level.
              IF (p_charge_method <> gcst_flatrate) THEN  --Enh# 2162747, Derive the Org_Unit_cd at Unit Level or Unit Section Level only when the Charge Method is not Flat Rate
                log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                            p_v_string => 'Other Than Flat Rate. Try for Org Unit code from Unit and Unit Section levels.' );
                OPEN c_org_unit_cd(p_person_id,
                                   p_unit_course_cd, --Enh#2162747 Changed p_course_cd to p_unit_course_cd
                                   p_uoo_id);
                FETCH c_org_unit_cd INTO v_derived_org_unit_cd;
                CLOSE c_org_unit_cd;

                IF v_derived_org_unit_cd IS NOT NULL THEN
                  IF (p_trace_on = 'Y') THEN
                    fnd_message.set_name ( 'IGS', 'IGS_FI_ORG_UNIT');
                    fnd_message.set_token('ORG_UNIT_CD',v_derived_org_unit_cd );
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;

                ELSE
                  -- Couldn't derive from Unit level, try at Unit Section
                  OPEN c_org_unit_sec_cd(p_unit_cd,
                                         p_unit_version_number,
                                         p_cal_type,
                                         p_ci_sequence_number,
                                         p_location_cd,
                                         lv_unit_class_att);
                  FETCH c_org_unit_sec_cd INTO v_derived_org_unit_cd;
                  CLOSE c_org_unit_sec_cd;
                  IF v_derived_org_unit_cd IS NOT NULL THEN
                    IF (p_trace_on = 'Y') THEN
                      fnd_message.set_name ( 'IGS', 'IGS_FI_ORG_UNIT');
                      fnd_message.set_token('ORG_UNIT_CD',v_derived_org_unit_cd);
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                    END IF;
                  ELSE
                    v_message_name := 'IGS_FI_NO_ORG_UNIT';
                    IF (p_trace_on = 'Y') THEN
                      fnd_message.set_name('IGS', v_message_name);
                      fnd_message.set_token('UNIT_CD', p_unit_cd);
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                    END IF;
                    log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                p_v_string => 'Other than Flat Rate: Could not derive Org Unit Code.' );
                  END IF;
                END IF;
                log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                            p_v_string => 'Other than Flat Rate: Derived Org Unit cd: ' || v_derived_org_unit_cd );
              END IF;

                IF (p_charge_method = gcst_flatrate) THEN
                  p_charge_elements := 1;
                  BEGIN
                    -- The org unit cd is derived at the Program Level if the Charge method is FLATRATE
                    OPEN c_resp_org_unit_cd(p_course_cd,
                                            p_course_version_number);
                    FETCH c_resp_org_unit_cd INTO v_derived_org_unit_cd;
                    CLOSE c_resp_org_unit_cd;

                    log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                p_v_string => 'Flat Rate: Derived Org Unit Cd from Program level: '
                                              || v_derived_org_unit_cd || '.Call finpl_sum_fee_ass_item..' );
                    IF finpl_sum_fee_ass_item (
                            p_person_id=>p_person_id,
                            p_status=>'E',
                            p_fee_type=>p_fee_type,
                            P_fee_cat=>p_fee_cat,
                            p_fee_cal_type=>p_fee_cal_type,
                            p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                            p_course_cd=>p_course_cd,
                            p_n_crs_version_number => p_course_version_number,
                            p_chg_method_type=>p_charge_method,
                            p_description=>null,--fee type desc selected inside
                            p_chg_elements=>p_charge_elements,--which is 1
                            p_unit_attempt_status =>NULL,
                            p_location_cd=>p_location_cd,
                            p_eftsu =>null,
                            p_credit_points=>null,
                            p_amount=>0,
                            p_org_unit_cd => v_derived_org_unit_cd, -- CCR for Enh# 1851586
                            p_trace_on=>p_trace_on,
                            p_message_name=>lv_sum_message,
                            p_uoo_id => NULL,
                            p_n_unit_type_id => NULL,
                            p_v_unit_level => NULL,
                            p_v_unit_class => NULL,
                            p_v_unit_mode => NULL,
                            p_v_unit_cd => NULL,
                            p_n_unit_version => NULL
                            )  = FALSE THEN
                      log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                  p_v_string => 'Returning false as finpl_sum_fee_ass_item returned with message:'|| lv_sum_message );
                      RETURN FALSE;
                    END IF;
                  END;
                  IF (p_trace_on = 'Y') THEN
                    -- Trace Entry
                    fnd_file.new_line(fnd_file.log);
                    fnd_message.set_name ( 'IGS', 'IGS_FI_LOAD_INCURRED');
                    fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y') );
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                    fnd_message.set_name('IGS', 'IGS_FI_CHG_METH_TYPE');
                    fnd_message.set_token('CHG_MTHD', igs_fi_gen_gl.get_lkp_meaning('CHG_METHOD', p_charge_method));
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                    fnd_message.set_name('IGS', 'IGS_FI_CHRG_METHOD_ELEMENTS');
                    fnd_message.set_token('CHG_ELM', TO_CHAR(p_charge_elements));
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  p_ret_true_flag := TRUE;
                  RETURN TRUE;

                ELSIF (p_charge_method = gcst_perunit) THEN
                  p_charge_elements := p_charge_elements + 1;
                  BEGIN
                    log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                p_v_string => 'Per Unit: Calling finpl_sum_fee_ass_item with elements ' || p_charge_elements );
                    IF finpl_sum_fee_ass_item (
                            p_person_id=>p_person_id,
                            p_status=>'E',
                            p_fee_type=>p_fee_type,
                            P_fee_cat=>p_fee_cat,
                            p_fee_cal_type=>p_fee_cal_type,
                            p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                            p_course_cd=>p_course_cd,
                            p_n_crs_version_number => p_course_version_number,
                            p_chg_method_type=>p_charge_method,
                            p_description=>null,--fee type desc selected inside
                            p_chg_elements=>1,  -- The Charge Method is Per Unit, Charge Elements will be passed as 1 for each assessable Unit
                            p_unit_attempt_status =>p_unit_attempt_status,
                            p_location_cd=>p_location_cd,
                            p_eftsu =>p_eftsu,
                            p_credit_points=>p_credit_points,
                            p_amount=>0,
                            p_org_unit_cd => v_derived_org_unit_cd, -- CCR for Enh# 1851586
                            p_trace_on=>p_trace_on,
                            p_message_name=>lv_sum_message,
                            p_uoo_id => p_uoo_id,
                            p_n_unit_type_id => p_n_unit_type_id,
                            p_v_unit_level => p_v_unit_level,
                            p_v_unit_class => lv_unit_class_att,
                            p_v_unit_mode => p_v_unit_mode,
                            p_v_unit_cd => p_unit_cd,
                            p_n_unit_version => p_unit_version_number )  = FALSE THEN
                      log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                  p_v_string => 'Returning false as finpl_sum_fee_ass_item returned with message:'|| lv_sum_message );
                      RETURN FALSE;
                    END IF;
                  END;
                  IF (p_trace_on = 'Y') THEN
                    -- Trace Entry
                    fnd_message.set_name ( 'IGS', 'IGS_FI_LOAD_INCURRED');
                    fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y') );
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                    fnd_message.set_name('IGS', 'IGS_FI_CHRG_METHOD_ELEMENTS');
                    fnd_message.set_token('CHG_ELM', TO_CHAR(p_charge_elements));
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;

                ELSIF (p_charge_method = gcst_eftsu) THEN
                  p_charge_elements := p_charge_elements + p_eftsu;
                  BEGIN
                    log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                p_v_string => 'Per Unit: Calling finpl_sum_fee_ass_item with elements ' || p_charge_elements );
                    IF finpl_sum_fee_ass_item (
                         p_person_id=>p_person_id,
                         p_status=>'E',
                         p_fee_type=>p_fee_type,
                         P_fee_cat=>p_fee_cat,
                         p_fee_cal_type=>p_fee_cal_type,
                         p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                         p_course_cd=>p_course_cd,
                         p_n_crs_version_number => p_course_version_number,
                         p_chg_method_type=>p_charge_method,
                         p_description=>null,--fee type desc selected inside
                         p_chg_elements=>p_eftsu,
                         p_unit_attempt_status =>p_unit_attempt_status,
                         p_location_cd=>p_location_cd,
                         p_eftsu =>p_eftsu,
                         p_credit_points=>p_credit_points,
                         p_amount=>0,
                         p_org_unit_cd => v_derived_org_unit_cd, -- CCR for Enh# 1851586
                         p_trace_on=>p_trace_on,
                         p_message_name=>lv_sum_message,
                         p_uoo_id => p_uoo_id,
                         p_n_unit_type_id => p_n_unit_type_id,
                         p_v_unit_level => p_v_unit_level,
                         p_v_unit_class => lv_unit_class_att,
                         p_v_unit_mode => p_v_unit_mode,
                         p_v_unit_cd => p_unit_cd,
                         p_n_unit_version => p_unit_version_number )  = FALSE THEN
                      log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                  p_v_string => 'Returning false as finpl_sum_fee_ass_item returned with message:'|| lv_sum_message );
                      RETURN FALSE;
                    END IF;
                  END;

                  IF (p_trace_on = 'Y') THEN
                    -- Auditable Units contribute to only Charge Elements but not for Load. Load Incurred for such a unit is always ZERO.
                    -- But igs_en_gen_014.enrs_clc_sua_eftsu in cursor c_sua_load returns Billing Credit Points for an Auditable Unit.
                    l_n_eftsu := 0;
                    IF l_v_no_assessment_ind = 'N' THEN
                      l_n_eftsu := p_eftsu;
                    END IF;
                    fnd_message.set_name('IGS', 'IGS_FI_LOAD_INCURRED');
                    fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y') );
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                    fnd_message.set_name('IGS', 'IGS_FI_CHG_ELE');
                    fnd_message.set_token('ELEMENTS', TO_CHAR(NVL(p_eftsu, 0)));
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;

                ELSIF (p_charge_method = gcst_crpoint) THEN
                  p_charge_elements := p_charge_elements + p_credit_points;
                  BEGIN
                    log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                p_v_string => 'Credit Points: Calling finpl_sum_fee_ass_item with elements ' || p_charge_elements );
                    IF finpl_sum_fee_ass_item (
                         p_person_id=>p_person_id,
                         p_status=>'E',
                         p_fee_type=>p_fee_type,
                         p_fee_cat=>p_fee_cat,
                         p_fee_cal_type=>p_fee_cal_type,
                         p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                         p_course_cd=>p_course_cd,
                         p_n_crs_version_number => p_course_version_number,
                         p_chg_method_type=>p_charge_method,
                         p_description=>null,--fee type desc selected inside
                         p_chg_elements=>p_credit_points,
                         p_unit_attempt_status =>p_unit_attempt_status,
                         p_location_cd=>p_location_cd,
                         p_eftsu =>p_eftsu,
                         p_credit_points=>p_credit_points,
                         p_amount=>0,
                         p_org_unit_cd => v_derived_org_unit_cd, -- CCR for Enh# 1851586
                         p_trace_on=>p_trace_on,
                         p_message_name=>lv_sum_message,
                         p_uoo_id => p_uoo_id,
                         p_n_unit_type_id => p_n_unit_type_id,
                         p_v_unit_level => p_v_unit_level,
                         p_v_unit_class => lv_unit_class_att,
                         p_v_unit_mode => p_v_unit_mode,
                         p_v_unit_cd => p_unit_cd,
                         p_n_unit_version => p_unit_version_number )  = FALSE THEN
                      log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                                  p_v_string => 'Returning false as finpl_sum_fee_ass_item returned with message:'|| lv_sum_message );
                      RETURN FALSE;
                    END IF;
                  END;

                  IF (p_trace_on = 'Y') THEN
                    -- Auditable Units contribute to only Charge Elements but not for Load. Load Incurred for such a unit is always ZERO.
                    -- But igs_en_gen_014.enrs_clc_sua_cp in cursor c_sua_load returns Billing Credit Points for an Auditable Unit.
                    l_n_credit_points := 0;
                    IF l_v_no_assessment_ind = 'N' THEN
                      l_n_credit_points := p_credit_points;
                    END IF;
                    fnd_message.set_name('IGS', 'IGS_FI_LOAD_INCURRED');
                    fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y') );
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                    fnd_message.set_name('IGS', 'IGS_FI_CHG_ELE');
                    fnd_message.set_token('ELEMENTS', TO_CHAR(NVL(p_credit_points, 0)));
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                END IF;

                log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                            p_v_string => 'Returning from finpl_prc_sua_load. Out: Charge elements ' || p_charge_elements );
                RETURN TRUE;
        END;
   EXCEPTION
          WHEN OTHERS THEN
            log_to_fnd( p_v_module => 'finpl_prc_sua_load',
                        p_v_string => 'From Exception Handler of When Others' );
            fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_PRC_SUA_LOAD-'||SUBSTR(sqlerrm,1,500));
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
        END finpl_prc_sua_load;

    ------------------------------------------------------------------------------
        FUNCTION finpl_clc_chg_mthd_elements(
                p_effective_dt                  DATE,
                p_trace_on                      VARCHAR2,
                p_person_id                     igs_en_stdnt_ps_att_all.person_id%TYPE,
                p_course_cd                     igs_en_stdnt_ps_att_all.course_cd%TYPE,
                p_course_version_number         igs_en_stdnt_ps_att_all.version_number%TYPE,
                p_attendance_type               igs_en_stdnt_ps_att_all.ATTENDANCE_TYPE%TYPE,
                p_course_attempt_status         igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                p_charge_method                 igs_fi_f_cat_fee_lbl_all.s_chg_method_type%TYPE,
                p_fee_cat                       IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE,
                p_fee_cal_type                  igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
                p_fee_ci_sequence_number        igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE,
                p_fee_type                      igs_fi_f_cat_fee_lbl_all.fee_type%TYPE,
                p_s_fee_type                    igs_fi_fee_type_all.s_fee_type%TYPE,
                p_s_fee_trigger_cat             igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                p_charge_elements       IN OUT NOCOPY   igs_fi_fee_as_all.chg_elements%TYPE,
                p_message_name          OUT NOCOPY      VARCHAR2,
                p_location_cd                   IGS_FI_FEE_AS_ITEMS.LOCATION_CD%TYPE,
                p_c_career                      igs_ps_ver_all.course_type%TYPE,
                p_n_selection_rule      IN      igs_ru_rule.sequence_number%TYPE
                )
        RETURN BOOLEAN AS
/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who             When       What
 bannamal       08-Jul-2005 Enh#3392088 Campus Privilege Fee.
                            Changes done as per TD.
 bannamal       14-Apr-2005 Bug#4297359 ER Registration Fee issue
                            Added code to check whether the credit points for the unit
                            attempt is non zero in case the non zero billable cp flag is
                            set to 'Y'.
 pathipat       05-Nov-2003 Enh 3117341 - Audit and Special Fees TD
                            Modifications according to TD, s1a
 vchappid       12-Feb-03   Bug#2788346, In this function, function finpl_pr8/16/2005
                            invoking logic is changed for 'Flat Rate' charge method.
***************************************************************/
   lv_param_values VARCHAR2(1080);
   BEGIN
        DECLARE
                v_version_number                igs_en_stdnt_ps_att_all.version_number%TYPE;
                v_eftsu                         igs_fi_fee_as_all.chg_elements%TYPE;
                v_credit_points                 igs_fi_fee_as_all.chg_elements%TYPE;
                v_ret_true_flag                 BOOLEAN;
                v_trigger_fired                 fnd_lookup_values.lookup_code%TYPE;
                v_message_name                  VARCHAR2(30);
                v_derived_org_unit_cd           IGS_FI_FEE_AS_ITEMS.org_unit_cd%TYPE;
                v_derived_location_cd           IGS_FI_FEE_AS_ITEMS.LOCATION_CD%TYPE;
                l_eftsu     NUMBER;
                l_crpoint   NUMBER;

                l_v_fee_ass_ind           VARCHAR2(1) := NULL;

                l_n_eftsu   igs_fi_fee_as_items.eftsu%TYPE;
                l_n_credit_points  igs_fi_fee_as_items.credit_points%TYPE;

                l_b_sca_liable_fcfl  BOOLEAN;
                l_v_prg_liabale      VARCHAR2(10);

                -- cursor to find student IGS_PS_UNIT attempts across multiple
                -- student IGS_PS_COURSE attempts
                -- this cursor has been modified to incorporate the changes for early/prioe assessment
                -- fee clac DLD  (Bug# 1851586)
                -- the records are fetched in the basis of the prior fee calendar instance

                -- Bug# 2122257, Modified the cursor select statement to include the audit table (IGS_FI_F_CAT_CAL_REL)
                -- for selecting Fee Category when it is changed.
                /* Modified by vchappid as a part of SFCR015 Build */

                -- Enh#2162747, Modified the cursor, removed the eftsu and credit point calculation, same function is invoked to calculate EFTSU, CREDIT POINTS
                -- when the the charge method is either EFTSU or CREDIT POINTS
                -- Enh# 3167098, modified following cursor
                CURSOR c_sualv_scafv (cp_person_id  hz_parties.party_id%TYPE,
                                      cp_course_cd  igs_en_su_attempt_all.course_cd%TYPE,
                                      cp_v_fee_ass_ind VARCHAR2,
                                      cp_v_lookup_type       igs_lookups_view.lookup_type%TYPE,
                                      cp_v_fee_ass_indicator igs_lookups_view.fee_ass_ind%TYPE)  IS
                  SELECT  sua.cal_type,
                          sua.ci_sequence_number,
                          sua.discontinued_dt,
                          sua.administrative_unit_status,
                          sua.unit_attempt_status,
                          sua.unit_cd,
                          sua.version_number,
                          sua.uoo_id,
                          sua.override_enrolled_cp,
                          sua.override_eftsu,
                          sua.no_assessment_ind,
                          sua.location_cd,
                          sua.org_unit_cd,
                          uoo.owner_org_unit_cd
                  FROM    igs_en_su_attempt_all sua,
                          igs_lookups_view lkp,
                          igs_ps_unit_ofr_opt_all uoo
                  WHERE lkp.lookup_code = sua.unit_attempt_status
                  AND   lkp.lookup_type = cp_v_lookup_type
                  AND   lkp.fee_ass_ind = cp_v_fee_ass_indicator
                  AND   (sua.no_assessment_ind = cp_v_fee_ass_ind OR cp_v_fee_ass_ind IS NULL)
                  AND   sua.person_id = cp_person_id
                  AND   sua.course_cd = cp_course_cd
                  AND   uoo.uoo_id    = sua.uoo_id;

                -- cursor to find student unit attempt for a course in context and in the given term.
                -- Enh# 3741400, igs_en_get_suaeh_dtl.enrp_get_suaeh_eff_st is replaced with SYSDATE
                CURSOR c_sua_load ( cp_person_id               hz_parties.party_id%TYPE,
                                    cp_course_cd               igs_ps_ver_all.course_cd%TYPE,
                                    cp_course_version          igs_ps_ver_all.version_number%TYPE,
                                    cp_load_cal_type           igs_ca_inst_all.cal_type%TYPE,
                                    cp_load_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                                    cp_v_fee_ass_ind           VARCHAR2,
                                    cp_v_lookup_type           igs_lookup_values.lookup_type%TYPE,
                                    cp_v_fee_ass_indicator     igs_lookups_view.fee_ass_ind%TYPE,
                                    cp_v_enrp_get_load_apply   VARCHAR2
                                    ) IS
                        SELECT  sua.course_cd,
                                sua.unit_cd,
                                sua.version_number,
                                sua.cal_type,
                                sua.unit_attempt_status,
                                sua.ci_sequence_number,
                                sua.location_cd,
                                SYSDATE effective_start_dt,
                                SYSDATE effective_end_dt,
                                NVL(igs_en_gen_014.enrs_clc_sua_eftsu(
                                                sua.person_id,
                                                p_course_cd, -- Enh#2162747 changed sua.course_cd to p_course_cd
                                                p_course_version_number, -- Enh#2162747
                                                sua.unit_cd,
                                                sua.version_number,
                                                sua.cal_type,
                                                sua.ci_sequence_number,
                                                sua.uoo_id,
                                                cp_load_cal_type,
                                                cp_load_ci_sequence_number,
                                                sua.override_enrolled_cp,
                                                sua.override_eftsu,
                                                'Y',            -- truncate_ind
                                                NULL,
                                                sua.no_assessment_ind
                                                ),0)   eftsu,  -- sca_cp_total
                                finpl_clc_sua_cp( sua.unit_cd,
                                                  sua.version_number,
                                                  sua.cal_type,
                                                  sua.ci_sequence_number,
                                                  cp_load_cal_type,
                                                  cp_load_ci_sequence_number,
                                                  sua.override_enrolled_cp,
                                                  sua.override_eftsu,
                                                  sua.uoo_id,
                                                  sua.no_assessment_ind) credit_points,
                                sua.uoo_id uoo_id,
                                sua.no_assessment_ind,
                                sua.org_unit_cd,
                                uoo.owner_org_unit_cd
                        FROM    igs_en_su_attempt_all       sua,
                                igs_lookups_view        suas,
                                igs_en_spa_terms        terms,
                                igs_ps_unit_ofr_opt_all uoo
                        WHERE   sua.person_id = p_person_id AND
                                sua.person_id = terms.person_id AND
                                sua.course_cd = terms.program_cd AND
                                uoo.uoo_id    = sua.uoo_id AND
                                terms.term_cal_type = g_v_load_cal_type AND
                                terms.term_sequence_number = g_n_load_seq_num AND
                                (
                                 ( sua.course_cd = p_course_cd AND g_c_fee_calc_mthd IN (g_v_program, g_v_career))
                                 OR
                                 (g_c_fee_calc_mthd= g_v_primary_career)
                                ) AND
                                suas.lookup_code = sua.unit_attempt_status AND
                                suas.lookup_type = cp_v_lookup_type AND
                                suas.fee_ass_ind = cp_v_fee_ass_indicator AND
                                (sua.no_assessment_ind = cp_v_fee_ass_ind OR cp_v_fee_ass_ind IS NULL) AND
                                igs_en_prc_load.enrp_get_load_apply(
                                      sua.cal_type,
                                      sua.ci_sequence_number,
                                      sua.discontinued_dt,
                                      sua.administrative_unit_status,
                                      sua.unit_attempt_status,
                                      sua.no_assessment_ind,
                                      cp_load_cal_type,
                                      cp_load_ci_sequence_number,
                                      sua.no_assessment_ind
                                      ) = cp_v_enrp_get_load_apply;

  -- Added by schodava as a part of the CCR for the Fee Calc (Enh # 1851586) DLD
  -- To find the organization unit code from the Program Version Table (For Charge Method of 'FLATRATE','EFTSU','PERUNIT','CREDIT POINT')
  CURSOR c_resp_org_unit_cd(cp_course_cd IN igs_ps_ver_all.course_cd%TYPE,
                            cp_version_number IN igs_ps_ver_all.version_number%TYPE
                           )IS
  SELECT responsible_org_unit_cd
  FROM   igs_ps_ver_all v
  WHERE  v.course_cd            = cp_course_cd
  AND    v.version_number       = cp_version_number;

        -- Enh# 3167098, Removed references to igs_fi_f_cat_cal_rel and igs_fi_cng_fcat_lbl_sca_pr_v in following cursor.
        -- For CAREER, Term records are created only for primary programs. So, select all programs from terms table.
        CURSOR c_sca_psv ( cp_v_lookup_type igs_lookups_view.lookup_type%TYPE,
                           cp_v_fee_ass_ind igs_lookups_view.fee_ass_ind%TYPE ) IS
          SELECT  spat.person_id,
                  spat.program_cd,
                  spat.program_version,
                  spat.fee_cat,
                  sca.commencement_dt,
                  sca.discontinued_dt,
                  sca.adm_admission_appl_number,
                  sca.adm_nominated_course_cd,
                  sca.adm_sequence_number,
                  sca.cal_type,
                  spat.location_cd,
                  spat.attendance_mode,
                  spat.attendance_type,
                  ps.course_type
          FROM    igs_en_spa_terms spat,
                  igs_en_stdnt_ps_att_all sca,
                  igs_ps_ver_all ps,
                  igs_lookups_view lkps
          WHERE   spat.person_id = p_person_id
          AND     spat.person_id = sca.person_id
          AND     spat.program_cd = sca.course_cd
          AND     spat.program_version = sca.version_number
          AND     spat.term_cal_type = g_v_load_cal_type
          AND     spat.term_sequence_number = g_n_load_seq_num
          AND     spat.program_cd = ps.course_cd
          AND     spat.program_version = ps.version_number
          AND     lkps.lookup_type = cp_v_lookup_type
          AND     sca.course_attempt_status = lkps.lookup_code
          AND     lkps.fee_ass_ind = cp_v_fee_ass_ind;

---  Cursor for getting nonzero_billable_cp_flag from ftci

         CURSOR cur_nz_bill_cp_flag ( cp_v_fee_type           igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                      cp_v_fee_cal_type       igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                                      cp_n_fee_ci_seq_number  igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE ) IS
           SELECT nonzero_billable_cp_flag
           FROM igs_fi_f_typ_ca_inst_all
           WHERE fee_type = cp_v_fee_type
           AND   fee_cal_type = cp_v_fee_cal_type
           AND   fee_ci_sequence_number = cp_n_fee_ci_seq_number;

         CURSOR cur_unit_cd (cp_n_uoo_id  igs_fi_fee_as_items.uoo_id%TYPE) IS
           SELECT unit_cd, version_number
           FROM   igs_ps_unit_ofr_opt_all
           WHERE  uoo_id = cp_n_uoo_id;

         CURSOR cur_get_ret_level (cp_v_fee_type              igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                   cp_v_fee_cal_type          igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                                   cp_n_fee_ci_sequence_num   igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE) IS
           SELECT retention_level_code
           FROM  igs_fi_f_typ_ca_inst_all
           WHERE fee_type               = cp_v_fee_type
           AND   fee_cal_type           = cp_v_fee_cal_type
           AND   fee_ci_sequence_number = cp_n_fee_ci_sequence_num;

         CURSOR cur_unit_set (cp_person_id     hz_parties.party_id%TYPE,
                              cp_course_cd     igs_ps_ver_all.course_cd%TYPE,
                              cp_effective_dt  DATE,
                              cp_v_student_confirmed_ind  igs_as_su_setatmpt.student_confirmed_ind%TYPE,
                              cp_v_s_unit_set_cat  igs_en_unit_set_cat.s_unit_set_cat%TYPE) IS
           SELECT asu.unit_set_cd,
                  asu.us_version_number
           FROM igs_as_su_setatmpt asu,
                igs_en_unit_set_all us,
                igs_en_unit_set_cat usc
           WHERE asu.person_id = cp_person_id
           AND asu.course_cd = cp_course_cd
           AND asu.student_confirmed_ind = cp_v_student_confirmed_ind
           AND TRUNC(cp_effective_dt) BETWEEN TRUNC(asu.selection_dt) AND NVL(TRUNC(asu.rqrmnts_complete_dt), NVL(TRUNC(asu.end_dt), TRUNC(cp_effective_dt)))
           AND asu.unit_set_cd = us.unit_set_cd
           AND asu.us_version_number = us.version_number
           AND us.unit_set_cat = usc.unit_set_cat
           AND usc.s_unit_set_cat = cp_v_s_unit_set_cat;


        l_v_course_cd   VARCHAR2(30);
        l_v_fee_cat     VARCHAR2(30);
        l_v_location_cd VARCHAR2(30);
        l_v_org_unit_cd VARCHAR2(30);
        l_v_nz_bill_cp_flag  igs_fi_f_typ_ca_inst_all.nonzero_billable_cp_flag%TYPE;
        l_n_crs_version_number  igs_fi_Fee_as_items.crs_version_number%TYPE;

        l_n_prg_type_level   igs_ps_unit_ver_all.unit_type_id%TYPE;
        l_v_unit_level       igs_ps_unit_ver_all.unit_level%TYPE;
        l_v_unit_class       igs_as_unit_class_all.unit_class%TYPE;
        l_v_unit_mode        igs_as_unit_class_all.unit_mode%TYPE;
        l_n_count            NUMBER;
        l_b_rule             BOOLEAN;
        l_v_unit_cd          igs_ps_unit_ofr_opt_all.unit_cd%TYPE;
        l_n_version_num      igs_ps_unit_ofr_opt_all.version_number%TYPE;
        l_v_ret_level        igs_fi_f_typ_ca_inst_all.retention_level_code%TYPE;
        l_v_class_standing   igs_fi_fee_as_rate.class_standing%TYPE;
        l_v_unit_set_cd      igs_as_su_setatmpt.unit_set_cd%TYPE;
        l_n_us_version_num   igs_as_su_setatmpt.us_version_number%TYPE;


        BEGIN
          -- Begin for finpl_clc_chg_mthd_elements

          log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                      p_v_string => 'Entered finpl_clc_chg_mthd_elements. Parameters are: '
                                    || 'Effective Dt: ' || TO_CHAR(p_effective_dt, 'DD-MON-YYYY HH24:MI:SS')
                                    || ', Trace On: ' || p_trace_on
                                    || ', Person Id: ' || p_person_id
                                    || ', Course Cd: ' || p_course_cd
                                    || ', Course Ver: ' || p_course_version_number
                                    || ', Att Type: ' || p_attendance_type
                                    || ', Crs Att Stat: ' || p_course_attempt_status
                                    || ', Chg Mthd: ' || p_charge_method
                                    || ', Fee Cat: ' || p_fee_cat
                                    || ', Fee Cal Type: ' || p_fee_cal_type
                                    || ', Fee Cal Seq Num: ' || p_fee_ci_sequence_number
                                    || ', Fee Type: ' || p_fee_type
                                    || ', Sys Fee Type: ' || p_s_fee_type
                                    || ', Sys Fee Trig Cat: ' || p_s_fee_trigger_cat
                                    || ', Charge Elms: ' || p_charge_elements
                                    || ', Location Cd: ' || p_location_cd
                                    || ', Career: ' || p_c_career );

          -- Step 1. Derive Load from the parameters (In case of PREDICTIVE, From Program and
          --                                          in case of ACTUAL, from Units attached to Program)
          -- Step 2. Derive Number of Charge Elements based on charge method and load derived.

          p_message_name := NULL;
          v_eftsu := 0;
          v_credit_points := 0;

          -- ====> PREDICTIVE MODE
          -------------------------

          -- check if a predictive assessment is being carried out
          -- if so use Default Load attached for the program.
          IF ( g_c_predictive_ind = 'Y' ) THEN

            log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                        p_v_string => 'Following path of Predictive. Deriving Default Load.');
            IF (igs_en_gen_002.enrp_get_att_dflt(p_course_cd,
                                                 p_course_version_number,
                                                 p_attendance_type,
                                                 g_v_load_cal_type, --Enh# SFCR021 v_ftcmav_rec.load_cal_type,
                                                 v_eftsu,
                                                 v_credit_points) = TRUE) THEN
              -- Enh# 3167098, In Predictive, org unit cd is derived from the Program Level as attributes are derived from Program level.
              OPEN c_resp_org_unit_cd(p_course_cd,p_course_version_number);
              FETCH c_resp_org_unit_cd INTO v_derived_org_unit_cd;
              CLOSE c_resp_org_unit_cd;

              log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                          p_v_string => 'Derived Values. Eftsu: ' || v_eftsu
                                        || ', Cr Points: ' || v_credit_points
                                        ||', Org Unit Cd: ' || v_derived_org_unit_cd);


              -- Enh# 3167098, For an Institution Fee, Course Code and Fee Category should be NULL (Only if Fee Calc Mthd is not Primary Career)
              IF p_s_fee_trigger_cat = gcst_institutn
                 AND g_c_fee_calc_mthd <> g_v_primary_career THEN
                l_v_course_cd := NULL;
                l_n_crs_version_number := NULL;
                l_v_fee_cat := NULL;
                l_v_location_cd := NULL;
                l_v_org_unit_cd := NULL;
              ELSE
                l_v_course_cd := p_course_cd;
                l_n_crs_version_number := p_course_version_number;
                l_v_fee_cat := p_fee_cat;
                l_v_location_cd := p_location_cd;
                l_v_org_unit_cd := v_derived_org_unit_cd;
              END IF;

              IF (p_charge_method = gcst_flatrate) THEN
                p_charge_elements := 1;
                        ---SYAM-KSS----added  by syam as part of DLD chap 9 devlp  call to sum_fee for insert if flat rate
                BEGIN
                  log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                              p_v_string => 'Calling finpl_sum_fee_ass_item in Flat Rate Case.');
                  IF finpl_sum_fee_ass_item (
                        p_person_id            => p_person_id,
                        p_status               => 'E',
                        p_fee_type             => p_fee_type,
                        P_fee_cat              => l_v_fee_cat,
                        p_fee_cal_type         => p_fee_cal_type,
                        p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                        p_course_cd            => l_v_course_cd,
                        p_n_crs_version_number => l_n_crs_version_number,
                        p_chg_method_type      => p_charge_method,
                        p_description          => null,                --fee type desc selected inside
                        p_chg_elements         => p_charge_elements,   --which is 1
                        p_unit_attempt_status  => null,
                        p_location_cd          => l_v_location_cd,
                        p_eftsu                => null,
                        p_credit_points        => null,
                        p_amount               => 0,
                        p_org_unit_cd          => l_v_org_unit_cd, -- CCR for Enh# 1851586
                        p_trace_on             => p_trace_on,
                        p_message_name         => lv_sum_message,
                        p_uoo_id               => NULL,
                        p_n_unit_type_id       => NULL,
                        p_v_unit_level         => NULL,
                        p_v_unit_class         => NULL,
                        p_v_unit_mode          => NULL,
                        p_v_unit_cd            => NULL,
                        p_n_unit_version       => NULL
                        )  = FALSE THEN
                    log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                                p_v_string => 'Returning False as finpl_sum_fee_ass_item returned false with message: ' || lv_sum_message);
                    RETURN FALSE;
                  END IF;
                END;
                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                            p_v_string => 'Returning with Charge Elements 1 in Flat Rate Case.');
                RETURN TRUE;

              ELSIF (p_charge_method = gcst_eftsu) THEN
                p_charge_elements := NVL(p_charge_elements,0) + NVL(v_eftsu,0);
                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                            p_v_string => 'EFTSU Case: Calling finpl_sum_fee_ass_item with Charge Elemsnts: ' || p_charge_elements);
                BEGIN
                  IF finpl_sum_fee_ass_item (
                                 p_person_id            => p_person_id,
                                 p_status               => 'E',
                                 p_fee_type             => p_fee_type,
                                 P_fee_cat              => l_v_fee_cat,
                                 p_fee_cal_type         => p_fee_cal_type,
                                 p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                                 p_course_cd            => l_v_course_cd,
                                 p_n_crs_version_number => l_n_crs_version_number,
                                 p_chg_method_type      => p_charge_method,
                                 p_description          => null,--fee type desc selected inside
                                 p_chg_elements         => v_eftsu,
                                 p_unit_attempt_status  => null,
                                 p_location_cd          => l_v_location_cd,
                                 p_eftsu                => v_eftsu,
                                 p_credit_points        => null,
                                 p_amount               => 0,
                                 p_org_unit_cd          => l_v_org_unit_cd, -- CCR for Enh# 1851586
                                 p_trace_on             => p_trace_on,
                                 p_message_name         => lv_sum_message,
                                 p_uoo_id               => NULL,
                                 p_n_unit_type_id       => NULL,
                                 p_v_unit_level         => NULL,
                                 p_v_unit_class         => NULL,
                                 p_v_unit_mode          => NULL,
                                 p_v_unit_cd            => NULL,
                                 p_n_unit_version       => NULL
                                 )  = FALSE THEN
                              RETURN FALSE;
                  END IF;
                END;
              ELSIF (p_charge_method = gcst_crpoint) THEN
                p_charge_elements := NVL(p_charge_elements,0) + NVL(v_credit_points,0);
                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                            p_v_string => 'Cr Point Case: Calling finpl_sum_fee_ass_item with Charge Elemsnts: ' || p_charge_elements);
                BEGIN
                  IF finpl_sum_fee_ass_item (
                                 p_person_id            => p_person_id,
                                 p_status               => 'E',
                                 p_fee_type             => p_fee_type,
                                 P_fee_cat              => l_v_fee_cat,
                                 p_fee_cal_type         => p_fee_cal_type,
                                 p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                                 p_course_cd            => l_v_course_cd,
                                 p_n_crs_version_number => l_n_crs_version_number,
                                 p_chg_method_type      => p_charge_method,
                                 p_description          => null,--fee type desc selected inside
                                 p_chg_elements         => v_credit_points,
                                 p_unit_attempt_status  => null,
                                 p_location_cd          => l_v_location_cd,
                                 p_eftsu                => null,
                                 p_credit_points        => v_credit_points,
                                 p_amount               => 0,
                                 p_org_unit_cd          => l_v_org_unit_cd, -- CCR for Enh# 1851586
                                 p_trace_on             => p_trace_on,
                                 p_message_name         => lv_sum_message,
                                 p_uoo_id               => NULL,
                                 p_n_unit_type_id       => NULL,
                                 p_v_unit_level         => NULL,
                                 p_v_unit_class         => NULL,
                                 p_v_unit_mode          => NULL,
                                 p_v_unit_cd            => NULL,
                                 p_n_unit_version       => NULL )  = FALSE THEN
                              RETURN FALSE;
                  END IF;
                END;
              END IF;
            ELSE
              IF (p_trace_on = 'Y') THEN
                fnd_message.set_name ( 'IGS', 'IGS_FI_UNABLE_DETM_DFLTLOAD');
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;
              log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                          p_v_string => 'Unable derive Default load. Returning false with message IGS_FI_UNABLE_DETM_DFLTLOAD.');
              RETURN FALSE;
            END IF;
          END IF;

          -- ====> ACTUAL MODE
          -------------------------

          -- For fee types = Tuition and Other, if profile is Y, then All units are considered.
          -- For Audit fee type, consider only Auditable Units (Enh# 3167098, Term Based Fee Calc)
          IF (p_s_fee_type = gcst_tuition_other OR  p_s_fee_type = gcst_other) THEN
             IF g_v_include_audit = 'Y' THEN
                l_v_fee_ass_ind := NULL;   -- Consider All units
             ELSE
                l_v_fee_ass_ind := 'N';  -- Consider only non-auditable units
             END IF;
          -- For Audit Fee Type, ONLY auditable units are considered, irrespective of the profile value
          ELSIF (p_s_fee_type = g_v_audit) THEN
                l_v_fee_ass_ind := 'Y';   -- Consider only auditable units
          END IF;

          -- Processing incase of PRIMARY_CAREER is same for Institution and Non-Institution Fees. This is handled after the following code.
          IF ( p_s_fee_trigger_cat = gcst_institutn  AND
               g_c_fee_calc_mthd <> g_v_primary_career AND
               g_c_predictive_ind = 'N') THEN

            log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                        p_v_string => 'Actual Mode: Following path 1 (Institution case). l_v_fee_ass_ind: ' || l_v_fee_ass_ind);

            -- This is set to TRUE if the charge method id FLAT RATE and load is incurred.
            v_ret_true_flag := FALSE;
            tbl_fai_unit_dtls.DELETE;

            ----------------
            -- 1. Get all the Program Attempts for the given TERM.
            -- 2. Check if the program attempt is liable under FCFL in context.
            -- 3. If Yes, Get all unit attached to program attempt in context.
            -- 4.         For each unit, calculate Load and derive number of charge elements based on calculated load and charge method.
            -- 5. After getting the number of charge elements, call finpl_sum_fee_ass_item to sum up all records in PL/SQL table.
            ----------------

              log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                          p_v_string => 'Looping thru Program Attempts from TERMS table. Cursor c_sca_psv.');
              -- Identify programs for calculating charge elements.
              FOR l_sca_psv IN c_sca_psv('CRS_ATTEMPT_STATUS', 'Y') LOOP

                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                            p_v_string => 'Calling check_stdnt_prg_att_liable with Arguments: '
                                          || l_sca_psv.person_id        || ', ' || l_sca_psv.program_cd  || ', '
                                          || l_sca_psv.program_version  || ', ' || l_sca_psv.fee_cat  || ', '
                                          || p_fee_type                 || ', ' || p_s_fee_trigger_cat  || ', '
                                          || p_fee_cal_type             || ', ' || p_fee_ci_sequence_number  || ', '
                                          || l_sca_psv.adm_admission_appl_number || ', ' || l_sca_psv.adm_nominated_course_cd  || ', '
                                          || l_sca_psv.adm_sequence_number || ', ' || TO_CHAR(l_sca_psv.commencement_dt, 'DD-MON-YYYY') || ', '
                                          || TO_CHAR(l_sca_psv.discontinued_dt, 'DD-MON-YYYY') || ', ' || l_sca_psv.cal_type  || ', '
                                          || l_sca_psv.location_cd      || ', ' || l_sca_psv.attendance_mode  || ', '
                                          || l_sca_psv.attendance_type);
                -- Check if Program Attempt is liable under FCFL in context.
                -- If not, skip this term record and proceed with the next.
                l_b_sca_liable_fcfl := TRUE;
                l_v_prg_liabale := igs_fi_gen_001.check_stdnt_prg_att_liable (
                                       p_n_person_id              => l_sca_psv.person_id,
                                       p_v_course_cd              => l_sca_psv.program_cd,
                                       p_n_course_version         => l_sca_psv.program_version,
                                       p_v_fee_cat                => l_sca_psv.fee_cat,
                                       p_v_fee_type               => p_fee_type,
                                       p_v_s_fee_trigger_cat      => p_s_fee_trigger_cat,
                                       p_v_fee_cal_type           => p_fee_cal_type,
                                       p_n_fee_ci_seq_number      => p_fee_ci_sequence_number,
                                       p_n_adm_appl_number        => l_sca_psv.adm_admission_appl_number,
                                       p_v_adm_nom_course_cd      => l_sca_psv.adm_nominated_course_cd,
                                       p_n_adm_seq_number         => l_sca_psv.adm_sequence_number,
                                       p_d_commencement_dt        => l_sca_psv.commencement_dt,
                                       p_d_disc_dt                => l_sca_psv.discontinued_dt,
                                       p_v_cal_type               => l_sca_psv.cal_type,
                                       p_v_location_cd            => l_sca_psv.location_cd,
                                       p_v_attendance_mode        => l_sca_psv.attendance_mode,
                                       p_v_attendance_type        => l_sca_psv.attendance_type ) ;
                IF l_v_prg_liabale = 'TRUE' THEN
                  -- Program Attempt is liable for the FCFL
                  l_b_sca_liable_fcfl := TRUE;
                ELSE
                  -- Program Attempt is not liable for the FCFL
                  log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                              p_v_string => 'After check_stdnt_prg_att_liable: Program Attempt is not liable under this FCFL.');
                  l_b_sca_liable_fcfl := FALSE;
                END IF;

                IF l_b_sca_liable_fcfl THEN
                  -- Add entry to global table for Programs liable under Institution Fee FCFL.
                  -- This is used in deriving Attendance Mode.
                  g_n_inst_progs_cntr := g_n_inst_progs_cntr + 1;
                  g_inst_liable_progs_tbl(g_n_inst_progs_cntr).program_cd := l_sca_psv.program_cd;
                  g_inst_liable_progs_tbl(g_n_inst_progs_cntr).program_version := l_sca_psv.program_version;
                  g_inst_liable_progs_tbl(g_n_inst_progs_cntr).career := l_sca_psv.course_type;

                  log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                              p_v_string => 'After check_stdnt_prg_att_liable: Program Attempt is liable under this FCFL. ' ||
                                            'Added to g_inst_liable_progs_tbl (' || g_n_inst_progs_cntr ||'). Looping thru Units..' );

                  -- For the each liable program in context, get Unit Attempts for calculation of load.
                  FOR v_sualv_scafv_rec IN c_sualv_scafv(p_person_id,
                                                         l_sca_psv.program_cd,
                                                         l_v_fee_ass_ind,
                                                         'UNIT_ATTEMPT_STATUS',
                                                         'Y')
                  LOOP
                    -- initializing the local variables before invoking the load incurred
                    v_eftsu :=0;
                    v_credit_points :=0;
                    l_b_rule := FALSE;
                    finpl_get_unit_type_level(v_sualv_scafv_rec.uoo_id, l_n_prg_type_level, l_v_unit_level);
                    finpl_get_unit_class_mode(v_sualv_scafv_rec.uoo_id, l_v_unit_class, l_v_unit_mode);
                    OPEN cur_unit_cd (v_sualv_scafv_rec.uoo_id);
                    FETCH cur_unit_cd INTO l_v_unit_cd, l_n_version_num;
                    IF cur_unit_cd%NOTFOUND THEN
                      l_v_unit_cd := NULL;
                      l_n_version_num := NULL;
                    END IF;
                    CLOSE cur_unit_cd;

                    IF (p_n_selection_rule IS NOT NULL) THEN
                            IF (igs_ru_gen_003.rulp_clc_student_scope(p_rule_number           =>  p_n_selection_rule,
                                                                      p_unit_loc_cd           =>  v_sualv_scafv_rec.location_cd,
                                                                      p_prg_type_level        =>  finpl_get_uptl(l_n_prg_type_level),
                                                                      p_org_code              =>  v_sualv_scafv_rec.owner_org_unit_cd,
                                                                      p_unit_mode             =>  l_v_unit_mode,
                                                                      p_unit_class            =>  l_v_unit_class,
                                                                      p_message               =>  l_v_message_name ) = TRUE) THEN

                               l_b_rule := TRUE;
                            END IF;
                    ELSE
                     l_b_rule := TRUE;
                    END IF;
                    IF (l_b_rule = TRUE) THEN
                          IF ( igs_en_prc_load.enrp_get_load_apply( p_teach_cal_type             => v_sualv_scafv_rec.cal_type,
                                                                      p_teach_sequence_number      => v_sualv_scafv_rec.ci_sequence_number,
                                                                      p_discontinued_dt            => v_sualv_scafv_rec.discontinued_dt,
                                                                      p_administrative_unit_status => v_sualv_scafv_rec.administrative_unit_status,
                                                                      p_unit_attempt_status        => v_sualv_scafv_rec.unit_attempt_status,
                                                                      p_no_assessment_ind          => v_sualv_scafv_rec.no_assessment_ind,
                                                                      p_load_cal_type              => g_v_load_cal_type,
                                                                      p_load_sequence_number       => g_n_load_seq_num,
                                                                      p_include_audit              => v_sualv_scafv_rec.no_assessment_ind
                                                                     ) ='Y') THEN

                              OPEN cur_get_ret_level(p_fee_type, p_fee_cal_type, p_fee_ci_sequence_number);
                              FETCH cur_get_ret_level INTO l_v_ret_level;
                              CLOSE cur_get_ret_level;
                              IF l_v_ret_level = 'TEACH_PERIOD' THEN
                                  l_v_class_standing := igs_pr_get_class_std.get_class_standing(p_person_id => p_person_id,
                                                                                                p_course_cd => p_course_cd,
                                                                                                p_predictive_ind => g_c_predictive_ind,
                                                                                                p_effective_dt => NULL,
                                                                                                p_load_cal_type => g_v_load_cal_type,
                                                                                                p_load_ci_sequence_number => g_n_load_seq_num
                                                                                               );

                                  OPEN cur_unit_set( p_person_id, p_course_cd, g_d_ld_census_val, 'Y', 'PRENRL_YR' );
                                  FETCH cur_unit_set INTO l_v_unit_set_cd, l_n_us_version_num;
                                  IF cur_unit_set%NOTFOUND THEN
                                    l_v_unit_set_cd := NULL;
                                    l_n_us_version_num := NULL;
                                  END IF;
                                  CLOSE cur_unit_set;

                                  l_n_count := tbl_fai_unit_dtls.COUNT + 1;
                                  tbl_fai_unit_dtls(l_n_count).fee_cat              := p_fee_cat;
                                  tbl_fai_unit_dtls(l_n_count).course_cd            := l_sca_psv.program_cd;
                                  tbl_fai_unit_dtls(l_n_count).crs_version_number   := l_sca_psv.program_version;
                                  tbl_fai_unit_dtls(l_n_count).unit_attempt_status  := v_sualv_scafv_rec.unit_attempt_status;
                                  tbl_fai_unit_dtls(l_n_count).org_unit_cd          := v_sualv_scafv_rec.org_unit_cd;
                                  tbl_fai_unit_dtls(l_n_count).class_standing       := l_v_class_standing;
                                  tbl_fai_unit_dtls(l_n_count).location_cd          := v_sualv_scafv_rec.location_cd;
                                  tbl_fai_unit_dtls(l_n_count).uoo_id               := v_sualv_scafv_rec.uoo_id;
                                  tbl_fai_unit_dtls(l_n_count).unit_set_cd          := l_v_unit_set_cd;
                                  tbl_fai_unit_dtls(l_n_count).us_version_number    := l_n_us_version_num;
                                  tbl_fai_unit_dtls(l_n_count).unit_type_id         := l_n_prg_type_level;
                                  tbl_fai_unit_dtls(l_n_count).unit_level           := l_v_unit_level;
                                  tbl_fai_unit_dtls(l_n_count).unit_class           := l_v_unit_class;
                                  tbl_fai_unit_dtls(l_n_count).unit_mode            := l_v_unit_mode;
                                  tbl_fai_unit_dtls(l_n_count).unit_cd              := l_v_unit_cd;
                                  tbl_fai_unit_dtls(l_n_count).unit_version_number  := l_n_version_num;
                              END IF;


                              -- In case of FLAT RATE, finpl_sum_fee_ass_item should be called only once for all courses. For doing this, use v_ret_true_flag.
                              IF (p_charge_method = gcst_flatrate) AND (NOT v_ret_true_flag) THEN
                              -- If the nonzero billable cp flag is 'Y' then check the credit points
                                OPEN cur_nz_bill_cp_flag( p_fee_type, p_fee_cal_type, p_fee_ci_sequence_number );
                                FETCH cur_nz_bill_cp_flag INTO l_v_nz_bill_cp_flag;
                                CLOSE cur_nz_bill_cp_flag;
                                IF l_v_nz_bill_cp_flag = 'Y' THEN
                                  -- call finpl_clc_sua_cp to get the credit points
                                  v_credit_points := finpl_clc_sua_cp( p_v_unit_cd                => v_sualv_scafv_rec.unit_cd,
                                                                     p_n_version_number           => v_sualv_scafv_rec.version_number,
                                                                     p_v_cal_type                 => v_sualv_scafv_rec.cal_type,
                                                                     p_n_ci_sequence_number       => v_sualv_scafv_rec.ci_sequence_number,
                                                                     p_v_load_cal_type            => g_v_load_cal_type,
                                                                     p_n_load_ci_sequence_number  => g_n_load_seq_num,
                                                                     p_n_override_enrolled_cp     => v_sualv_scafv_rec.override_enrolled_cp,
                                                                     p_n_override_eftsu           => v_sualv_scafv_rec.override_eftsu,
                                                                     p_n_uoo_id                   => v_sualv_scafv_rec.uoo_id,
                                                                     p_v_include_audit            => v_sualv_scafv_rec.no_assessment_ind);
                                  v_credit_points := NVL(v_credit_points,0);
                                END IF;

                                  IF (l_v_nz_bill_cp_flag = 'Y' AND v_credit_points > 0) OR l_v_nz_bill_cp_flag = 'N'  THEN
                                     p_charge_elements := 1;
                                     IF finpl_sum_fee_ass_item ( p_person_id=>p_person_id,
                                                                 p_status=>'E',
                                                                 p_fee_type=>p_fee_type,
                                                                 P_fee_cat=>NULL,
                                                                 p_fee_cal_type=>p_fee_cal_type,
                                                                 p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                                                                 p_course_cd=>NULL,
                                                                 p_n_crs_version_number => NULL,
                                                                 p_chg_method_type=>p_charge_method,
                                                                 p_description=>null ,--fee type desc selected inside
                                                                 p_chg_elements=>p_charge_elements,--which is 1
                                                                 p_unit_attempt_status =>NULL,
                                                                 p_location_cd=>NULL,
                                                                 p_eftsu =>NULL,
                                                                 p_credit_points=>NULL,
                                                                 p_amount=>0,
                                                                 p_org_unit_cd => NULL,
                                                                 p_trace_on=>p_trace_on,
                                                                 p_message_name=>lv_sum_message,
                                                                 p_uoo_id => NULL,
                                                                 p_n_unit_type_id => NULL,
                                                                 p_v_unit_level   => NULL,
                                                                 p_v_unit_class   => NULL,
                                                                 p_v_unit_mode    => NULL,
                                                                 p_v_unit_cd      => NULL,
                                                                 p_n_unit_version => NULL )  = FALSE THEN
                                      log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                                                 p_v_string => 'Flat Rate Case: Returning False as finpl_sum_fee_ass_item returned message: ' || lv_sum_message);
                                      RETURN FALSE;
                                     END IF;
                                     IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_LOAD_INCURRED');
                                        fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y') );
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                        fnd_message.set_name('IGS', 'IGS_FI_CHRG_METHOD_ELEMENTS');
                                        fnd_message.set_token('CHG_ELM', TO_CHAR(p_charge_elements));
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                     END IF;
                                    v_ret_true_flag := TRUE;
                                  END IF;


                              ELSIF (p_charge_method = gcst_perunit) THEN
                                -- Consider all Units that are assessable, Cursor c_sualv_scafv will get all assessable units only.
                                p_charge_elements := p_charge_elements + 1;
                                IF l_v_ret_level = 'TEACH_PERIOD' THEN
                                  tbl_fai_unit_dtls(l_n_count).chg_elements := 1;
                                END IF;
                                IF (p_trace_on = 'Y') THEN
                                  fnd_file.new_line(fnd_file.log);
                                  fnd_message.set_name ( 'IGS', 'IGS_FI_LOAD_INCURRED');
                                  fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y') );
                                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                                  fnd_message.set_name('IGS', 'IGS_FI_CHG_ELE');
                                  fnd_message.set_token('ELEMENTS', TO_CHAR(p_charge_elements));
                                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;

                              ELSIF (p_charge_method = gcst_eftsu) THEN
                                -- Consider all Units that are assessable, Cursor c_sualv_scafv will get all assessable units only.
                                v_eftsu := igs_en_prc_load.enrp_clc_sua_eftsu(
                                               p_person_id,
                                               p_course_cd,
                                               p_course_version_number,
                                               v_sualv_scafv_rec.unit_cd,
                                               v_sualv_scafv_rec.version_number,
                                               v_sualv_scafv_rec.cal_type,
                                               v_sualv_scafv_rec.ci_sequence_number,
                                               v_sualv_scafv_rec.uoo_id,
                                               g_v_load_cal_type,
                                               g_n_load_seq_num,
                                               v_sualv_scafv_rec.override_enrolled_cp,
                                               v_sualv_scafv_rec.override_eftsu,
                                               'Y',
                                               NULL,
                                               g_c_key_program,  -- new parameters , key program and version number are newly added, Career Impact DLD
                                               g_n_key_version,
                                               v_credit_points,
                                               v_sualv_scafv_rec.no_assessment_ind );
                                v_eftsu := NVL(v_eftsu,0);
                                IF l_v_ret_level = 'TEACH_PERIOD' THEN
                                  tbl_fai_unit_dtls(l_n_count).chg_elements := v_eftsu;
                                END IF;
                                p_charge_elements := p_charge_elements + v_eftsu;

                                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                                            p_v_string => 'Derived Vals from enrp_clc_sua_eftsu- Uoo: ' || v_sualv_scafv_rec.uoo_id
                                                          || ', Eftsu:' || v_eftsu || ', Charge Elements: ' || p_charge_elements );
                                IF (p_trace_on = 'Y') THEN
                                 fnd_file.new_line(fnd_file.log);
                                 fnd_message.set_name('IGS', 'IGS_FI_LOAD_INCURRED');
                                 fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y') );
                                 fnd_file.put_line (fnd_file.log, fnd_message.get);
                                 fnd_message.set_name('IGS', 'IGS_FI_CHG_ELE');
                                 fnd_message.set_token('ELEMENTS', TO_CHAR(NVL(v_eftsu, 0)));
                                 fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;

                              ELSIF (p_charge_method = gcst_crpoint) THEN  -- Credit Points
                                -- Consider all Units that are assessable, Cursor c_sualv_scafv will get all assessable units only.
                                -- Added this call as part of Enh# 3741400, Billable Credit Points
                                v_credit_points := finpl_clc_sua_cp( p_v_unit_cd                  => v_sualv_scafv_rec.unit_cd,
                                                                     p_n_version_number           => v_sualv_scafv_rec.version_number,
                                                                     p_v_cal_type                 => v_sualv_scafv_rec.cal_type,
                                                                     p_n_ci_sequence_number       => v_sualv_scafv_rec.ci_sequence_number,
                                                                     p_v_load_cal_type            => g_v_load_cal_type,
                                                                     p_n_load_ci_sequence_number  => g_n_load_seq_num,
                                                                     p_n_override_enrolled_cp     => v_sualv_scafv_rec.override_enrolled_cp,
                                                                     p_n_override_eftsu           => v_sualv_scafv_rec.override_eftsu,
                                                                     p_n_uoo_id                   => v_sualv_scafv_rec.uoo_id,
                                                                     p_v_include_audit            => v_sualv_scafv_rec.no_assessment_ind);
                                v_credit_points := NVL(v_credit_points,0);
                                IF l_v_ret_level = 'TEACH_PERIOD' THEN
                                  tbl_fai_unit_dtls(l_n_count).chg_elements := v_credit_points;
                                END IF;
                                p_charge_elements := p_charge_elements + v_credit_points;

                                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                                            p_v_string => 'Derived Vals from finpl_clc_sua_cp- Uoo: ' || v_sualv_scafv_rec.uoo_id
                                                          || ', Credit Points:' || v_credit_points || ', Charge Elements: ' || p_charge_elements );
                                IF (p_trace_on = 'Y') THEN
                                 fnd_file.new_line(fnd_file.log);
                                 fnd_message.set_name('IGS', 'IGS_FI_LOAD_INCURRED');
                                 fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y') );
                                 fnd_file.put_line (fnd_file.log, fnd_message.get);
                                 fnd_message.set_name('IGS', 'IGS_FI_CHG_ELE');
                                 fnd_message.set_token('ELEMENTS', TO_CHAR(NVL(v_credit_points, 0)));
                                 fnd_file.put_line (fnd_file.log, fnd_message.get);
                               END IF;
                              END IF;
                            END IF;
                    END IF;
                  END LOOP; /* For cursor, c_sualv_scafv */
                END IF; /* l_b_sca_liable_fcfl */
              END LOOP; /* For Cursor c_sca_psv */

            -- inserting the record in the pl/sql table only once for the case of institution
            -- triggered fee. this is change implemented thru CCR SFCR009
            IF p_charge_method <> gcst_flatrate THEN
              IF p_charge_method = gcst_eftsu THEN
                l_eftsu := p_charge_elements;
                l_crpoint := NULL;
              ELSIF p_charge_method = gcst_crpoint THEN
                l_eftsu := NULL;
                l_crpoint := p_charge_elements;
              END IF;
              log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                          p_v_string => 'Other than Flat Rate Case: calling finpl_sum_fee_ass_item.');
              IF finpl_sum_fee_ass_item (p_person_id=>p_person_id,
                                         p_status=>'E',
                                         p_fee_type=>p_fee_type,
                                         P_fee_cat=>NULL,
                                         p_fee_cal_type=>p_fee_cal_type,
                                         p_fee_ci_sequence_number=>p_fee_ci_sequence_number,
                                         p_course_cd=>NULL,
                                         p_n_crs_version_number => NULL,
                                         p_chg_method_type=>p_charge_method,
                                         p_description=>null ,--fee type desc selected inside
                                         p_chg_elements=>p_charge_elements,
                                         p_unit_attempt_status =>NULL,
                                         p_location_cd=>NULL,
                                         p_eftsu    => l_eftsu,
                                         p_credit_points=> l_crpoint,
                                         p_amount=>0,
                                         p_org_unit_cd => NULL, -- CCR for Enh# 1851586
                                         p_trace_on=>p_trace_on,
                                         p_message_name=>lv_sum_message,
                                         p_uoo_id => NULL,
                                         p_n_unit_type_id => NULL,
                                         p_v_unit_level   => NULL,
                                         p_v_unit_class   => NULL,
                                         p_v_unit_mode    => NULL,
                                         p_v_unit_cd      => NULL,
                                         p_n_unit_version => NULL)  = FALSE THEN
                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                            p_v_string => 'Other than Flat Rate Case: Returning false as finpl_sum_fee_ass_item returned message: '||lv_sum_message);
                RETURN FALSE;
              END IF;
            END IF;
          END IF;

          IF ((p_s_fee_trigger_cat <> gcst_institutn OR g_c_fee_calc_mthd= g_v_primary_career)
               AND (g_c_predictive_ind = 'N')) THEN

            log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                        p_v_string => 'Actual Mode: Following path 2 (Non-Institution case). l_v_fee_ass_ind: ' || l_v_fee_ass_ind);
            -- This captures return value from finpl_prc_sua_load which returns true if the charge method is FLAT RATE.
            v_ret_true_flag := FALSE;

            log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                          p_v_string => 'Loop Thru Units of course: ' || p_course_cd);
                -- Current date - use current student Unit attempt
              FOR v_sua_load_rec IN c_sua_load ( p_person_id,
                                                 p_course_cd,
                                                 p_course_version_number,
                                                 g_v_load_cal_type,
                                                 g_n_load_seq_num,
                                                 l_v_fee_ass_ind,
                                                 'UNIT_ATTEMPT_STATUS',
                                                 'Y',
                                                 'Y' )
              LOOP
                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                            p_v_string => 'Derived Vals from c_sua_load- Uoo: ' || v_sua_load_rec.uoo_id || ', Auditable Ind: ' || v_sua_load_rec.no_assessment_ind
                                           || ', Credit Points:' || v_sua_load_rec.credit_points || ', Charge Elements: ' || v_sua_load_rec.eftsu );

                l_b_rule := FALSE;

                finpl_get_unit_type_level(v_sua_load_rec.uoo_id, l_n_prg_type_level, l_v_unit_level);
                finpl_get_unit_class_mode(v_sua_load_rec.uoo_id, l_v_unit_class, l_v_unit_mode);

                IF (p_n_selection_rule IS NOT NULL) THEN
                        IF (igs_ru_gen_003.rulp_clc_student_scope (p_rule_number              =>  p_n_selection_rule,
                                                                      p_unit_loc_cd           =>  v_sua_load_rec.location_cd,
                                                                      p_prg_type_level        =>  finpl_get_uptl(l_n_prg_type_level),
                                                                      p_org_code              =>  v_sua_load_rec.owner_org_unit_cd,
                                                                      p_unit_mode             =>  l_v_unit_mode,
                                                                      p_unit_class            =>  l_v_unit_class,
                                                                      p_message               =>  l_v_message_name ) = TRUE) THEN
                               l_b_rule := TRUE;
                        END IF;
                ELSE
                    l_b_rule := TRUE;
                END IF;
                IF (l_b_rule = TRUE) THEN
                        --In case of flat rate the program level location code is to be used # 1906022
                        OPEN cur_nz_bill_cp_flag( p_fee_type, p_fee_cal_type, p_fee_ci_sequence_number );
                        FETCH cur_nz_bill_cp_flag INTO l_v_nz_bill_cp_flag;
                        CLOSE cur_nz_bill_cp_flag;
                       -- if the nonzero billable cp flag is 'Y' and credit points is 0 then ignore that unit attempt
                        IF NOT(p_charge_method = gcst_flatrate AND l_v_nz_bill_cp_flag = 'Y'  AND v_sua_load_rec.credit_points = 0) THEN

                        IF p_charge_method = gcst_flatrate THEN
                          v_derived_location_cd := p_location_cd;
                        ELSE
                          v_derived_location_cd := v_sua_load_rec.location_cd;
                        END IF;
                        -- Flag v_ret_true_flag will be set to TRUE in the function finpl_prc_sua_load for 'Flat Rate' charge method
                        -- For all other charge methods the FALSE will be returned from this function and should continue for each
                        -- fee assessable unit
                        IF NOT v_ret_true_flag THEN
                          log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                                      p_v_string => 'Calling finpl_prc_sua_load..');
                          IF (finpl_prc_sua_load(p_effective_dt,
                                                 p_trace_on,
                                                 p_person_id,
                                                 p_course_cd,
                                                 p_course_version_number,
                                                 v_sua_load_rec.unit_cd,
                                                 v_sua_load_rec.version_number,
                                                 v_sua_load_rec.cal_type,
                                                 v_sua_load_rec.effective_start_dt,
                                                 v_sua_load_rec.effective_end_dt,
                                                 NVL(v_sua_load_rec.eftsu,0),
                                                 NVL(v_sua_load_rec.credit_points,0),
                                                 p_s_fee_type,
                                                 p_charge_method,
                                                 p_fee_type ,
                                                 p_fee_cat  ,
                                                 p_fee_cal_type,
                                                 p_fee_ci_sequence_number,
                                                 v_sua_load_rec.unit_attempt_status,
                                                 v_derived_location_cd,
                                                 v_sua_load_rec.ci_sequence_number,
                                                 p_charge_elements,      -- IN OUT
                                                 v_ret_true_flag,        -- OUT
                                                 p_message_name,
                                                 p_s_fee_trigger_cat,
                                                 v_sua_load_rec.uoo_id,
                                                 v_sua_load_rec.course_cd,
                                                 l_n_prg_type_level,
                                                 l_v_unit_level,
                                                 l_v_unit_mode
                                                 ) = FALSE) THEN   --Enh# 2162747, added new parameter p_unit_course_cd to finpl_prc_sua_load
                            log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                                        p_v_string => 'Returning as finpl_prc_sua_load returned false. Out: ' || p_charge_elements );
                            RETURN FALSE;
                          END IF;
                          log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                                      p_v_string => 'After call to finpl_prc_sua_load, Charge Elements: ' || p_charge_elements );
                        END IF;
                        END IF;
                END IF;
              END LOOP;

          END IF;         -- not institution and not unconfirm

          log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                      p_v_string => 'At the end of processing, Charge Elements: ' || p_charge_elements );
          RETURN TRUE;
        END;
        EXCEPTION
        WHEN OTHERS THEN
                log_to_fnd( p_v_module => 'finpl_clc_chg_mthd_elements',
                            p_v_string => 'From Exception Handler of When Others.');
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_PRC_FEE_ASS.FINPL_CLC_CHG_MTHD_ELEMENTS-'||SUBSTR(sqlerrm,1,500));
                IGS_GE_MSG_STACK.ADD;
                 lv_param_values := to_char(p_effective_dt)||','||p_trace_on||','||
                 to_char(p_person_id)||','||
                  p_course_cd||','||to_char(p_course_version_number)||','||
                  p_attendance_type||','||p_course_attempt_status||','||
                  p_charge_method||','||
                  p_fee_cat||','||
                  p_fee_cal_type||','||
                  to_char(p_fee_ci_sequence_number)||','||
                  p_fee_type||','||
                  p_s_fee_type||','||
                  p_s_fee_trigger_cat||','||
                  p_charge_elements;
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
       END finpl_clc_chg_mthd_elements;


    -------------------------------------------------------------------------------

    -- Removed finpl_val_sua_census as part of Enh# 3167098, Term Based Fee Calc

    -------------------------------------------------------------------------------
        FUNCTION finpl_prc_fee_cat_fee_liab (
                p_effective_dt                  DATE,
                p_trace_on                      VARCHAR2,
                p_fee_cal_type                  igs_ca_inst_all.cal_type%TYPE,
                p_fee_ci_sequence_num           igs_ca_inst_all.sequence_number%TYPE,
                p_local_currency                igs_fi_control_all.currency_cd%TYPE,
                p_fee_cat                       igs_en_stdnt_ps_att_all.fee_cat%tYPE,
                p_person_id                     hz_parties.party_id%TYPE,
                p_course_cd                     igs_en_stdnt_ps_att_all.course_cd%TYPE,
                p_course_version_number         igs_en_stdnt_ps_att_all.version_number%TYPE,
                p_cal_type                      igs_en_stdnt_ps_att_all.cal_type%TYPE,
                p_scahv_location_cd             igs_en_stdnt_ps_att_all.location_cd%TYPE,
                p_scahv_attendance_mode         igs_en_stdnt_ps_att_all.attendance_mode%TYPE,
                p_scahv_attendance_type         igs_en_stdnt_ps_att_all.attendance_type%TYPE,
                p_discontinued_dt               igs_en_stdnt_ps_att_all.discontinued_dt%TYPE,
                p_course_attempt_status         igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                p_message_name              OUT NOCOPY  VARCHAR2,
                p_process_mode               IN VARCHAR2 ,
                p_c_career                   IN igs_ps_ver_all.course_type%TYPE,
                p_waiver_call_ind            IN VARCHAR2,
                p_target_fee_type            IN VARCHAR2
                ) RETURN BOOLEAN AS
                /*************************************************************
                  Change History
                  Who             When            What
                  abshriva       19-Jun-2006     Bug 5104329 -Invoked finpl_get_derived_am_at to pass derived values of
                                                 attendance mode and type before all callouts to finpl_ins_fee_ass.
                  pathipat       23-Nov-2005      Bug 4718712 - Added code to assign values to p_course_cd and p_career
                                                  in tbl_wav_fcfl if Waiver Assignment exists.
                  bannamal       26-Aug-2005      Enh#3392095 Tuition Waiver Build. Added two new parameters.
                  bannamal       08-Jul-2005      Enh#3392088 Campus Privilege Fee.
                                                  Modified the cursor c_fcflv and changed the call to finpl_clc_ass_amnt.
                  pathipat        06-Jul-2004     Bug 3734842 - Added logic to lock records before processing
                  UUDYAPR         17-DEC-2003    --BUG 3080983Modified The Parameter Type Of v_fee_assessment To
                                                   Number From Igs_fi_fee_ass_debt_v.Assessment_amount%Type.
                  pathipat        05-Nov-2003     Enh 3117341 - Audit and Special Fees TD
                                                  Added code for Audit Fee Trigger fired
                  (reverse chronological order - newest change first)
                ***************************************************************/
                -- Exception raised when a lock could not be obtained in the Temp table. (pathipat, as part of bug 3734842)
                e_lock_exception                EXCEPTION;
                PRAGMA EXCEPTION_INIT(e_lock_exception, -54);

        BEGIN
          DECLARE
                cst_completed   CONSTANT        igs_en_stdnt_ps_att_all.course_attempt_status%TYPE := 'COMPLETED';
                v_next_fcfl_flag                BOOLEAN;
                v_charge_rate                   IGS_FI_FEE_AS_RATE.chg_rate%TYPE;
                v_charge_elements               igs_fi_fee_as_all.chg_elements%TYPE;
                v_fee_assessment                NUMBER;
                v_fee_cat                       IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE;
                v_fee_cal_type                  IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE;
                v_fee_ci_sequence_number        IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE;
                v_fcci_end_dt                   IGS_CA_DA_INST_V.alias_val%TYPE;
                v_fcflv_start_dt                IGS_CA_DA_INST_V.alias_val%TYPE;
                v_fcflv_end_dt                  IGS_CA_DA_INST_V.alias_val%TYPE;
                v_fcci_found                    BOOLEAN;
                v_fcfl_found                    BOOLEAN;
                v_message_name                  VARCHAR2(30);
                v_trigger_fired                 fnd_lookup_values.lookup_code%TYPE;
                l_n_rec_count                   NUMBER;
                l_v_attendance_type             igs_en_stdnt_ps_att_all.attendance_type%TYPE;
                l_v_attendance_mode             igs_en_stdnt_ps_att_all.attendance_mode%TYPE;

                inst_liable_prog_dummy_tbl      inst_prog_det_tbl_typ;

                CURSOR c_fcci_fss (
                        cp_effective_dt DATE) IS
                        SELECT  fcci.FEE_CAT,
                                fcci.fee_cal_type,
                                fcci.fee_ci_sequence_number,
                                fcci.start_dt_alias,
                                fcci.start_dai_sequence_number,
                                fcci.end_dt_alias,
                                fcci.end_dai_sequence_number,
                                ci.start_dt,
                                ci.end_dt
                        FROM    IGS_FI_F_CAT_CA_INST    fcci,
                                IGS_FI_FEE_STR_STAT     fss,
                                igs_ca_inst_all             ci
                        WHERE   fcci.FEE_CAT = p_fee_cat AND
                                (p_fee_cal_type IS NULL OR fcci.fee_cal_type = p_fee_cal_type) AND
                                (p_fee_ci_sequence_num IS NULL OR
                                fcci.fee_ci_sequence_number = p_fee_ci_sequence_num) AND
                                (
                                 -- In Predictive, Select only when Effective Date (i.e., SYSDATE) is less than FCFL Start Date Alias Value.
                                 ( g_c_predictive_ind = 'Y' AND
                                   (TRUNC(cp_effective_dt) < (SELECT TRUNC(daiv.alias_val)
                                                              FROM igs_ca_da_inst_v  daiv
                                                              WHERE daiv.DT_ALIAS = fcci.start_dt_alias AND
                                                              daiv.sequence_number = fcci.start_dai_sequence_number AND
                                                              daiv.CAL_TYPE =fcci.fee_cal_type AND
                                                              daiv.ci_sequence_number = fcci.fee_ci_sequence_number AND
                                                              daiv.alias_val IS NOT NULL))
                                 )
                                 OR
                                 -- In Actual, Select only when FCFL is active as on Effective Date. (i.e., Eff Date <= FCFL Start Date Alias)
                                 ( g_c_predictive_ind = 'N' AND
                                   (TRUNC(cp_effective_dt) >= (SELECT TRUNC(daiv.alias_val)
                                                               FROM igs_ca_da_inst_v  daiv
                                                               WHERE daiv.DT_ALIAS = fcci.start_dt_alias AND
                                                               daiv.sequence_number = fcci.start_dai_sequence_number AND
                                                               daiv.CAL_TYPE =fcci.fee_cal_type AND
                                                               daiv.ci_sequence_number = fcci.fee_ci_sequence_number AND
                                                               daiv.alias_val IS NOT NULL))
                                 )
                                ) AND
                                TRUNC(cp_effective_dt) <=
                                        (SELECT TRUNC(daiv.alias_val)
                                        FROM    IGS_CA_DA_INST_V        daiv
                                        WHERE   daiv.DT_ALIAS = fcci.end_dt_alias AND
                                                daiv.sequence_number = fcci.end_dai_sequence_number AND
                                                daiv.CAL_TYPE =fcci.fee_cal_type AND
                                                daiv.ci_sequence_number = fcci.fee_ci_sequence_number AND
                                                daiv.alias_val IS NOT NULL) AND
                                (p_discontinued_dt IS NULL OR
                                (TRUNC(p_discontinued_dt) >=
                                        (SELECT TRUNC(daiv.alias_val)
                                        FROM    IGS_CA_DA_INST_V        daiv
                                        WHERE   daiv.DT_ALIAS = fcci.start_dt_alias AND
                                                daiv.sequence_number = fcci.start_dai_sequence_number AND
                                                daiv.CAL_TYPE =fcci.fee_cal_type AND
                                                daiv.ci_sequence_number = fcci.fee_ci_sequence_number AND
                                                daiv.alias_val IS NOT NULL) AND
                                TRUNC(p_discontinued_dt) <=
                                        (SELECT TRUNC(daiv.alias_val)
                                        FROM    IGS_CA_DA_INST_V        daiv
                                        WHERE   daiv.DT_ALIAS = fcci.end_dt_alias AND
                                                daiv.sequence_number = fcci.end_dai_sequence_number AND
                                                daiv.CAL_TYPE =fcci.fee_cal_type AND
                                                daiv.ci_sequence_number = fcci.fee_ci_sequence_number AND
                                                daiv.alias_val IS NOT NULL))) AND
                                fcci.fee_cat_ci_status = fss.FEE_STRUCTURE_STATUS AND
                                fss.s_fee_structure_status = gcst_active AND
                                ci.CAL_TYPE = fcci.fee_cal_type AND
                                ci.sequence_number = fcci.fee_ci_sequence_number;
                CURSOR c_daiv (
                        cp_dt_alias                     IGS_CA_DA_INST.DT_ALIAS%TYPE,
                        cp_dai_sequence_number          IGS_CA_DA_INST.sequence_number%TYPE,
                        cp_fee_cal_type                 IGS_CA_DA_INST.CAL_TYPE%TYPE,
                        cp_fee_ci_sequence_number       IGS_CA_DA_INST.ci_sequence_number%TYPE) IS
                        SELECT  daiv.alias_val
                        FROM    IGS_CA_DA_INST_V        daiv
                        WHERE   daiv.DT_ALIAS = cp_dt_alias AND
                                daiv.sequence_number = cp_dai_sequence_number AND
                                daiv.CAL_TYPE =cp_fee_cal_type AND
                                daiv.ci_sequence_number = cp_fee_ci_sequence_number;
                CURSOR c_fcflv (
                        cp_fee_cat              IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE,
                        cp_fee_cal_type         IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE,
                        cp_v_s_transaction_type igs_fi_fee_as_all.s_transaction_type%TYPE ) IS
                  SELECT fcflv.fee_cal_type,
                          fcflv.fee_ci_sequence_number,
                          fcflv.FEE_TYPE,
                          fcflv.fee_liability_status,
                          fcflv.start_dt_alias,
                          fcflv.start_dai_sequence_number,
                          fcflv.end_dt_alias,
                          fcflv.end_dai_sequence_number,
                          fcflv.s_chg_method_type,
                          fcflv.rul_sequence_number,
                          fcflv.currency_cd,
                          fss.s_fee_structure_status,
                          ft.s_fee_trigger_cat,
                          ft.s_fee_type,
                          fcflv.fee_cat,
                          'CURRENT' source,
                          fcflv.elm_rng_order_name,
                          fcflv.scope_rul_sequence_num,
                          fcflv.max_chg_elements
                  FROM    igs_fi_f_cat_fee_lbl_v  fcflv,
                          igs_fi_fee_str_stat     fss,
                          igs_fi_fee_type_all         ft
                  WHERE   fcflv.fee_cat = cp_fee_cat AND
                          fcflv.fee_cal_type = cp_fee_cal_type AND
                          fcflv.fee_ci_sequence_number = cp_fee_ci_sequence_number AND
                          (p_fee_type IS NULL OR fcflv.fee_type = p_fee_type) AND
                          fcflv.fee_liability_status = fss.fee_structure_status AND
                          fcflv.fee_type = ft.fee_type AND
                          (p_waiver_call_ind = 'N' OR (p_waiver_call_ind = 'Y' AND fcflv.fee_type = p_target_fee_type)) AND
                          ((p_v_wav_calc_flag = 'Y' AND fcflv.waiver_calc_flag = 'Y') OR (p_v_wav_calc_flag = 'N' AND fcflv.waiver_calc_flag = 'N'))
                  UNION ALL
                  -- This will select FCFLs from Fee As Items table that are not selected in above part of cursor.
                  SELECT DISTINCT ast.fee_cal_type,
                         ast.fee_ci_sequence_number,
                         ast.fee_type,
                         NULL,
                         NULL,
                         TO_NUMBER(NULL),
                         NULL,
                         TO_NUMBER(NULL),
                         NULL,
                         TO_NUMBER(NULL),
                         NULL,
                         'INACTIVE',
                         ft.s_fee_trigger_cat,
                         ft.s_fee_type,
                         ast.fee_cat,
                         'OLD' source,
                         ast.elm_rng_order_name,
                         ast.scope_rul_sequence_num,
                         ast.max_chg_elements
                  FROM igs_fi_fee_as_items ast,
                       igs_fi_fee_as_all fas,
                       igs_fi_fee_type_all ft,
                       igs_ps_ver_all ps
                  WHERE ast.person_id = p_person_id
                  AND (p_fee_type IS NULL OR (p_fee_type IS NOT NULL AND ast.fee_type = p_fee_type))-- will reverse existing charges only when user has not provided Fee Type as input
                  AND ps.course_cd (+) = ast.course_cd
                  AND ps.version_number (+) = ast.crs_version_number
                  AND ast.fee_cal_type = cp_fee_cal_type
                  AND ast.fee_ci_sequence_number = cp_fee_ci_sequence_number
                  AND ast.fee_type = ft.fee_type
                  AND ast.person_id = fas.person_id
                  AND ast.transaction_id = fas.transaction_id
                  AND fas.s_transaction_type = cp_v_s_transaction_type
                  AND (
                        ((ft.s_fee_trigger_cat = gcst_institutn
                          AND (ast.course_cd IS NULL
                               OR (g_c_fee_calc_mthd = g_v_program AND ast.course_cd IS NOT NULL)
                              ))
                        OR
                        ( ft.s_fee_trigger_cat <> gcst_institutn AND
                         (
                          (ast.course_cd = p_course_cd AND g_c_fee_calc_mthd = g_v_program) OR
                          (ps.course_type = p_c_career AND g_c_fee_calc_mthd = g_v_career)
                         )
                        ))
                        OR
                        (g_c_fee_calc_mthd = g_v_primary_career)
                      ) AND (ast.fee_type,NVL(ast.fee_cat,cp_fee_cat)) NOT IN (SELECT fee_type,fee_cat FROM igs_fi_f_cat_fee_lbl_all
                                                                               WHERE fee_cat = cp_fee_cat
                                                                               AND fee_cal_type = ast.fee_cal_type
                                                                               AND fee_ci_sequence_number = ast.fee_ci_sequence_number
                                                                               AND fee_type = ast.fee_type);

                -- Actual Mode of processing, when the fee calculation method is 'Program','Career'.
                -- Get all the program attempts from the student terms table, other than the program/career that is in context
                CURSOR c_std_term_spas( cp_v_lookup_type igs_lookups_view.lookup_type%TYPE,
                                        cp_v_fee_ass_ind igs_lookups_view.fee_ass_ind%TYPE ) IS
                  SELECT spt.program_cd,
                         spt.program_version,
                         spt.fee_cat,
                         spa.adm_admission_appl_number,
                         spa.adm_nominated_course_cd,
                         spa.adm_sequence_number,
                         spa.commencement_dt,
                         spa.discontinued_dt,
                         spa.cal_type,
                         spt.location_cd,
                         spt.attendance_mode,
                         spt.attendance_type
                  FROM igs_en_spa_terms spt,
                       igs_en_stdnt_ps_att_all spa,
                       igs_ps_ver_all ps,
                       igs_lookups_view lkps
                  WHERE spt.person_id = spa.person_id
                  AND spt.program_cd = spa.course_cd
                  AND spt.program_version = spa.version_number
                  AND spt.person_id = p_person_id
                  AND spt.term_cal_type = g_v_load_cal_type
                  AND spt.term_sequence_number = g_n_load_seq_num
                  AND spt.program_cd = ps.course_cd
                  AND spt.program_version = ps.version_number
                  AND spa.course_attempt_status = lkps.lookup_code
                  AND lkps.lookup_type = cp_v_lookup_type
                  AND lkps.fee_ass_ind = cp_v_fee_ass_ind
                  AND (
                       (spt.program_cd <> p_course_cd AND g_c_fee_calc_mthd = g_v_program) OR
                       (ps.course_type <> p_c_career AND g_c_fee_calc_mthd = g_v_career)
                      );

              CURSOR cur_fcfl (cp_v_fee_cat igs_fi_f_cat_fee_lbl_all.fee_cat%TYPE,
                                cp_v_fee_cal_type igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
                                 cp_n_fee_ci_seq_num igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE,
                                   cp_v_fee_type igs_fi_f_cat_fee_lbl_all.fee_type%TYPE) IS
               SELECT fee_cat, fee_type
               FROM igs_fi_f_cat_fee_lbl_all
               WHERE fee_cal_type = cp_v_fee_cal_type
               AND fee_ci_sequence_number = cp_n_fee_ci_seq_num
               AND fee_type = cp_v_fee_type;

              l_v_liable VARCHAR2(10) := 'FALSE';

          FUNCTION finpl_init_fee_ass_item (
                 p_person_id                             IGS_FI_FEE_AS_ITEMS.person_id%TYPE,
                 p_fee_type                              IGS_FI_FEE_AS_ITEMS.fee_type%TYPE,
                 P_fee_cat                               IGS_FI_FEE_AS_ITEMS.fee_cat%TYPE,
                 p_fee_cal_type                          IGS_FI_FEE_AS_ITEMS.fee_cal_type%TYPE,
                 p_fee_ci_sequence_number                IGS_FI_FEE_AS_ITEMS.fee_ci_sequence_number%TYPE,
                 p_course_cd                             IGS_FI_FEE_AS_ITEMS.course_cd%TYPE,
                 p_effective_date                        DATE,
                 p_trace_on                              VARCHAR2,
                 p_c_career                              igs_ps_ver_all.course_type%TYPE)
          RETURN BOOLEAN
          AS
          /*************************************************************
            Created By :syam shankar
            Date Created By :18-sep-2000
            Purpose :
            Know limitations, enhancements or remarks
            Change History
            Who             When            What
            pathipat        06-Sep-2005     Bug 4540295 - Fee assessment produce double fees after program version change
            bannamal        08-Jul-2005     Enh#3392088 Campus Privilege Fee. Modified
                                            the cursor cur_chg_method.
            pathipat        12-Sep-2003     Enh 3108052 - Unit Sets in Rate Table build
                                            Added unit_set_cd and us_version_number to plsql table
            (reverse chronological order - newest change first)
          ***************************************************************/
            v_message_name                  VARCHAR2(30);
            ln_fee_ass_item_id              igs_fi_fee_as_items.fee_ass_item_id%TYPE;
            lv_fee_trg_cat                  igs_fi_fee_type_all.s_fee_trigger_cat%TYPE;
            lv_chg_method                   IGS_FI_FEE_AS_ITEMS.S_Chg_Method_Type%TYPE;


            CURSOR c_fee_type( cp_fee_type      IGS_FI_FEE_AS_ITEMS.FEE_TYPE%TYPE ) IS
                    SELECT description,
                           s_fee_trigger_cat
                    FROM igs_fi_fee_type_all
                    WHERE fee_type = cp_fee_type;
            v_fee_type_description igs_fi_fee_type_all.description%type;
            l_n_scope_rul_seq_num  igs_fi_f_typ_ca_inst_all.scope_rul_sequence_num%TYPE;

            CURSOR cur_chg_method1(cp_fee_type                igs_fi_fee_as_all.fee_type%TYPE,
                                   cp_fee_cal_type            igs_fi_fee_as_all.fee_cal_type%TYPE,
                                   cp_fee_ci_Sequence_number  igs_fi_fee_as_all.fee_ci_sequence_number%TYPE) IS
                   SELECT s_chg_method_type,
                          scope_rul_sequence_num
                   FROM   igs_fi_f_typ_ca_inst_all
                   WHERE  fee_type               = cp_fee_type
                   AND    fee_cal_type           = cp_fee_cal_type
                   AND    fee_ci_sequence_number = cp_fee_ci_sequence_number;

            -- Enh# 3167098, Removed the context of Fee Category when selecting as Fee Cat can be changed after assessment.
            CURSOR c_as_items  (cp_person_id            igs_fi_fee_as_items.person_id%TYPE,
                                cp_fee_type             igs_fi_fee_as_items.fee_type%TYPE ,
                                cp_fee_cal_type         igs_fi_fee_as_items.fee_cal_type%TYPE,
                                cp_fee_ci_sequence_number  igs_fi_fee_as_items.fee_ci_sequence_number%TYPE,
                                cp_course_cd            igs_fi_fee_as_items.course_cd%TYPE,
                                cp_career               igs_ps_ver_all.course_type%TYPE,
                                cp_s_trigger_cat        igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                                cp_v_s_transaction_type1 igs_fi_fee_as_all.s_transaction_type%TYPE,
                                cp_v_s_transaction_type2 igs_fi_fee_as_all.s_transaction_type%TYPE
                                ) IS
              SELECT   a.course_cd,
                       a.crs_version_number,
                       a.location_cd,
                       SUM(a.chg_elements) sum_elements,
                       SUM(a.amount) sum_amount,
                       SUM(a.credit_points) sum_credit_points,
                       SUM(a.eftsu) sum_eftsu,
                       a.org_unit_cd,
                       a.uoo_id,
                       a.fee_cat
              FROM    igs_fi_fee_as_items a,
                      igs_ps_ver_all ps
              WHERE   a.course_cd = ps.course_cd (+)
              AND     a.crs_version_number = ps.version_number (+)
              AND     a.person_id = cp_person_id
              AND     a.fee_type  = cp_fee_type
              AND     a.fee_cal_type = cp_fee_cal_type
              AND     a.fee_ci_sequence_number  = cp_fee_ci_sequence_number
              AND     ((p_fee_cat IS NOT NULL AND a.fee_cat = p_fee_cat ) OR (a.fee_cat IS NULL OR p_fee_cat IS NULL))
              AND     ((cp_s_trigger_cat =  gcst_institutn AND
                                  (a.course_cd is NULL
                                    OR (g_c_fee_calc_mthd = g_v_program AND a.course_cd IS NOT NULL)
                                  ))
                       OR (
                           (g_c_fee_calc_mthd = g_v_program AND a.course_cd = cp_course_cd)
                           OR
                           (g_c_fee_calc_mthd = g_v_career AND ps.course_type = cp_career)
                           OR
                           (g_c_fee_calc_mthd = g_v_primary_career)
                          )
                      )
              AND     a.logical_delete_date IS NULL
              AND     TRUNC(a.fee_effective_dt) <= TRUNC(p_effective_date)
              AND     NOT EXISTS ( SELECT 'x'
                                   FROM   igs_fi_fee_as_all b
                                   WHERE  b.person_id  = cp_person_id
                                   AND    b.transaction_id = a.transaction_id
                                   AND    b.fee_type = cp_fee_type
                                   AND    b.fee_cal_type = cp_fee_cal_type
                                   AND    b.fee_ci_sequence_number = cp_fee_ci_sequence_number
                                   AND    ((p_fee_cat IS NOT NULL AND b.fee_cat = p_fee_cat ) OR (b.fee_cat IS NULL OR p_fee_cat IS NULL))
                                   AND    ((cp_s_trigger_cat =  gcst_institutn AND
                                                     (a.course_cd is NULL
                                                       OR (g_c_fee_calc_mthd = g_v_program AND a.course_cd IS NOT NULL)
                                                     ))
                                           OR (
                                               (g_c_fee_calc_mthd = g_v_program AND a.course_cd = cp_course_cd)
                                                OR
                                               (g_c_fee_calc_mthd = g_v_career AND ps.course_type = cp_career)
                                                OR
                                               (g_c_fee_calc_mthd = g_v_primary_career)
                                              )
                                          )
                                   AND    b.s_transaction_type in (cp_v_s_transaction_type1, cp_v_s_transaction_type2)
                                  )
              GROUP BY a.course_cd,
                       a.crs_version_number,
                       a.fee_cat,
                       a.uoo_id,
                       a.location_cd,
                       a.org_unit_cd;

            -- Cursor to select all charges created if is is 'Institution' Fee and the charge method identified is 'Flat Rate'
            CURSOR c_as_inst_items  (cp_person_id              igs_fi_fee_as_items.person_id%TYPE,
                                     cp_fee_type               igs_fi_fee_as_items.fee_type%TYPE,
                                     cp_fee_cal_type           igs_fi_fee_as_items.fee_cal_type%TYPE,
                                     cp_fee_ci_sequence_number igs_fi_fee_as_items.fee_ci_sequence_number%TYPE,
                                     cp_course_cd              igs_fi_fee_as_items.course_cd%TYPE,
                                     cp_v_s_transaction_type1  igs_fi_fee_as_all.s_transaction_type%TYPE,
                                     cp_v_s_transaction_type2  igs_fi_fee_as_all.s_transaction_type%TYPE
                                     ) IS

              SELECT   a.course_cd,
                       a.crs_version_number,
                       a.location_cd,
                       SUM(a.chg_elements) sum_elements,
                       SUM(a.amount) sum_amount,
                       SUM(a.credit_points) sum_credit_points,
                       SUM(a.eftsu) sum_eftsu,
                       a.org_unit_cd,
                       a.uoo_id,
                       a.fee_cat
               FROM    igs_fi_fee_as_items a
               WHERE   a.person_id = cp_person_id AND
                       a.fee_type  = cp_fee_type AND
                       a.fee_cal_type = cp_fee_cal_type AND
                       a.fee_ci_sequence_number  = cp_fee_ci_sequence_number AND
                       ((p_fee_cat IS NOT NULL AND a.fee_cat = p_fee_cat ) OR (a.fee_cat IS NULL OR p_fee_cat IS NULL)) AND
                       a.logical_delete_date IS NULL AND
                       TRUNC(a.fee_effective_dt) <= TRUNC(p_effective_date) AND
                       NOT EXISTS ( SELECT 'X'
                                    FROM   igs_fi_fee_as_all b
                                    WHERE  b.person_id  = cp_person_id
                                    AND    b.transaction_id = a.transaction_id
                                    AND    b.fee_type   = cp_fee_type
                                    AND    b.fee_cal_type = cp_fee_cal_type
                                    AND    b.fee_ci_sequence_number = cp_fee_ci_sequence_number
                                    AND    ((p_fee_cat IS NOT NULL AND b.fee_cat = p_fee_cat ) OR (b.fee_cat IS NULL OR p_fee_cat IS NULL))
                                    AND    b.s_transaction_type in (cp_v_s_transaction_type1, cp_v_s_transaction_type2)
                                  )
               GROUP BY a.course_cd,
                        a.crs_version_number,
                        a.fee_cat,
                        a.uoo_id,
                        a.location_cd,
                        a.org_unit_cd;

            CURSOR cur_chg_method(cp_person_id               igs_fi_fee_as_all.person_id%TYPE,
                                  cp_fee_type                igs_fi_fee_as_all.fee_type%TYPE,
                                  cp_course_cd               igs_fi_fee_as_all.course_cd%TYPE,
                                  cp_fee_cal_type            igs_fi_fee_as_all.fee_cal_type%TYPE,
                                  cp_fee_ci_Sequence_number  igs_fi_fee_as_all.fee_ci_sequence_number%TYPE,
                                  cp_career                  igs_ps_ver_all.course_type%TYPE) IS

              SELECT a.fee_ass_item_id upd,
                     a.s_chg_method_type
              FROM   igs_fi_fee_as_items a,
                     igs_ps_ver_all ps
              WHERE  a.course_cd = ps.course_cd (+)
              AND    a.crs_version_number = ps.version_number (+)
              AND    a.person_id   = cp_person_id
              AND    a.fee_type    = cp_fee_type
              AND    (a.course_cd  IS NULL
                      OR
                      (
                       (g_c_fee_calc_mthd = g_v_program AND a.course_cd = cp_course_cd)
                        OR
                        /* Select based on Career but not on the course code passed as Primary Program can be changed after the assessment. */
                       (g_c_fee_calc_mthd = g_v_career AND ps.course_type = cp_career)
                        OR
                       (g_c_fee_calc_mthd = g_v_primary_career)
                      )
                     )
              AND    a.fee_cal_type = cp_fee_cal_type
              AND    a.fee_ci_sequence_number = cp_fee_ci_sequence_number
              AND    a.chg_elements <> 0
              ORDER BY upd DESC;

          BEGIN
            log_to_fnd( p_v_module => 'finpl_init_fee_ass_item',
                        p_v_string => 'Entered  . Parameters are: '
                                      || 'Person Id: '      || p_person_id
                                      || ', Fee Type: '     || p_fee_type
                                      || ', Fee Cat : '     || P_fee_cat
                                      || ', Fee Cal Type: ' || p_fee_cal_type
                                      || ', Fee Seq Num: '  || p_fee_ci_sequence_number
                                      || ', Cousre Cd: '    || p_course_cd
                                      || ', Effective Dt: ' || TO_CHAR(p_effective_dt, 'DD-MON-YYYY HH24:MI:SS')
                                      || ', Trace On: '     || p_trace_on
                                      || ', Career: '       || p_c_career );
            t_fee_as_items := t_dummy_fee_as_items; /**initialise pl/sql structure**/
            gv_as_item_cntr := 0;
            g_b_fee_chgs_exists := FALSE;

            OPEN  c_fee_type(p_fee_type);
            FETCH c_fee_type INTO v_fee_type_description,
                                  lv_fee_trg_cat;
            CLOSE c_fee_type;

            OPEN cur_chg_method1(p_fee_type,
                                 p_fee_cal_type,
                                 p_fee_ci_sequence_number);
            FETCH cur_chg_method1 INTO lv_chg_method, l_n_scope_rul_seq_num;
            CLOSE cur_chg_method1;

            IF lv_fee_trg_cat = gcst_institutn AND lv_chg_method = gcst_flatrate THEN

              log_to_fnd( p_v_module => 'finpl_init_fee_ass_item',
                          p_v_string => 'Institution Fee with Flat Rate. Following Path 1 with cursor c_as_inst_items.');
              FOR r_inst_items IN c_as_inst_items ( p_person_id,
                                                    p_fee_type,
                                                    p_fee_cal_type,
                                                    p_fee_ci_sequence_number,
                                                    p_course_cd,
                                                    'RETENTION','EXTERNAL')
              LOOP
                gv_as_item_cntr :=  NVL(gv_as_item_cntr, 0) + 1;
                t_fee_as_items(gv_as_item_cntr).person_id               := p_person_id;
                t_fee_as_items(gv_as_item_cntr).status                  := 'E';
                t_fee_as_items(gv_as_item_cntr).fee_type                := p_fee_type;
                t_fee_as_items(gv_as_item_cntr).fee_cat                 := r_inst_items.fee_cat;
                t_fee_as_items(gv_as_item_cntr).fee_cal_type            := p_fee_cal_type;
                t_fee_as_items(gv_as_item_cntr).description             := v_fee_type_description;
                t_fee_as_items(gv_as_item_cntr).fee_ci_sequence_number  := p_fee_ci_sequence_number;
                t_fee_as_items(gv_as_item_cntr).course_cd               := r_inst_items.course_cd;
                t_fee_as_items(gv_as_item_cntr).crs_version_number      := r_inst_items.crs_version_number;
                t_fee_as_items(gv_as_item_cntr).old_chg_elements        := r_inst_items.sum_elements;
                t_fee_as_items(gv_as_item_cntr).old_amount              := r_inst_items.sum_amount;
                t_fee_as_items(gv_as_item_cntr).location_cd             := r_inst_items.location_cd;
                t_fee_as_items(gv_as_item_cntr).old_eftsu               := r_inst_items.sum_eftsu;
                t_fee_as_items(gv_as_item_cntr).old_credit_points       := r_inst_items.sum_credit_points;
                t_fee_as_items(gv_as_item_cntr).org_unit_cd             := r_inst_items.org_unit_cd;
                t_fee_as_items(gv_as_item_cntr).chg_elements            := 0;
                t_fee_as_items(gv_as_item_cntr).uoo_id                  := r_inst_items.uoo_id ;
                t_fee_as_items(gv_as_item_cntr).unit_set_cd             := NULL;
                t_fee_as_items(gv_as_item_cntr).us_version_number       := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_type_id            := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_class              := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_mode               := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_cd                 := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_level              := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_version_number     := NULL;

                OPEN cur_chg_method(p_person_id,
                                    p_fee_type,
                                    p_course_cd,
                                    p_fee_cal_type,
                                    p_fee_ci_sequence_number,
                                    p_c_career);
                FETCH cur_chg_method INTO ln_fee_ass_item_id,
                                          t_fee_as_items(gv_as_item_cntr).chg_method_type;
                CLOSE cur_chg_method;

                t_fee_as_items(gv_as_item_cntr).fee_ass_item_id         := ln_fee_ass_item_id;

                g_b_fee_chgs_exists := TRUE;
              END LOOP;

            ELSE
              log_to_fnd( p_v_module => 'finpl_init_fee_ass_item',
                          p_v_string => 'NOT(Institution Fee with Flat Rate). Following Path 2 with cursor c_as_items.');
              FOR r_items IN c_as_items(p_person_id,
                                        p_fee_type,
                                        p_fee_cal_type,
                                        p_fee_ci_sequence_number,
                                        p_course_cd,
                                        p_c_career,
                                        lv_fee_trg_cat,
                                        'RETENTION','EXTERNAL')
              LOOP
                gv_as_item_cntr :=  nvl(gv_as_item_cntr,0) + 1;
                t_fee_as_items(gv_as_item_cntr).person_id               := p_person_id;
                t_fee_as_items(gv_as_item_cntr).status                  := 'E';
                t_fee_as_items(gv_as_item_cntr).fee_type                := p_fee_type;
                t_fee_as_items(gv_as_item_cntr).fee_cat                 := r_items.fee_cat;
                t_fee_as_items(gv_as_item_cntr).fee_cal_type            := p_fee_cal_type;
                t_fee_as_items(gv_as_item_cntr).description             := v_fee_type_description;
                t_fee_as_items(gv_as_item_cntr).fee_ci_sequence_number  := p_fee_ci_sequence_number;
                t_fee_as_items(gv_as_item_cntr).course_cd               := r_items.course_cd;
                t_fee_as_items(gv_as_item_cntr).crs_version_number      := r_items.crs_version_number;
                t_fee_as_items(gv_as_item_cntr).old_chg_elements        := r_items.sum_elements;
                t_fee_as_items(gv_as_item_cntr).old_amount              := r_items.sum_amount;
                t_fee_as_items(gv_as_item_cntr).location_cd             := r_items.location_cd;
                t_fee_as_items(gv_as_item_cntr).old_eftsu               := r_items.sum_eftsu;
                t_fee_as_items(gv_as_item_cntr).old_credit_points       := r_items.sum_credit_points;
                t_fee_as_items(gv_as_item_cntr).org_unit_cd             := r_items.org_unit_cd;
                t_fee_as_items(gv_as_item_cntr).chg_elements            := 0;
                t_fee_as_items(gv_as_item_cntr).uoo_id                  := r_items.uoo_id ;
                t_fee_as_items(gv_as_item_cntr).unit_set_cd             := NULL;
                t_fee_as_items(gv_as_item_cntr).us_version_number       := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_type_id            := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_class              := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_mode               := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_cd                 := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_level              := NULL;
                t_fee_as_items(gv_as_item_cntr).unit_version_number     := NULL;

                OPEN cur_chg_method(p_person_id,
                                    p_fee_type,
                                    p_course_cd,
                                    p_fee_cal_type,
                                    p_fee_ci_sequence_number,
                                    p_c_career);
                FETCH cur_chg_method INTO ln_fee_ass_item_id,
                                          t_fee_as_items(gv_as_item_cntr).chg_method_type;
                CLOSE cur_chg_method;

                t_fee_as_items(gv_as_item_cntr).fee_ass_item_id         := ln_fee_ass_item_id;

                g_b_fee_chgs_exists := TRUE;
              END LOOP;
            END IF;

            log_to_fnd( p_v_module => 'finpl_init_fee_ass_item',
                        p_v_string => 'Returning from finpl_init_fee_ass_item. Added ' ||t_fee_as_items.COUNT || ' record(s) to PL/SQL Table.');
            RETURN TRUE;

          EXCEPTION
            WHEN OTHERS THEN
              log_to_fnd( p_v_module => 'finpl_init_fee_ass_item',
                          p_v_string => 'From Exception Handler of When Others.');
              v_message_name := 'IGS_GE_UNHANDLED_EXP';
              IF (p_trace_on = 'Y') THEN
                fnd_message.set_name('IGS', v_message_name);
                Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_INIT_FEE_ASS_ITEM');
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;
            RETURN FALSE;
          END finpl_init_fee_ass_item;

       BEGIN
               -- Beginning of Main for finpl_prc_fee_cat_fee_liab
               log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                           p_v_string => 'Entered finpl_prc_fee_cat_fee_liab. Parameters are: '
                                         || 'Effective Date: '    || TO_CHAR(p_effective_dt, 'DD-MON-YYYY HH24:MI:SS')
                                         || ', Trace On: '        || p_trace_on
                                         || ', Fee Cal Type: '    || p_fee_cal_type
                                         || ', Fee Cal Seq Num: ' || p_fee_ci_sequence_num
                                         || ', Local Currency: '  || p_local_currency
                                         || ', Fee Cat: '         || p_fee_cat
                                         || ', Person Id: '       || p_person_id
                                         || ', Course Cd: '       || p_course_cd
                                         || ', Course Version: '  || p_course_version_number
                                         || ', Location Cd: '     || p_scahv_location_cd
                                         || ', Att Mode: '        || p_scahv_attendance_mode
                                         || ', Att Type: '        || p_scahv_attendance_type
                                         || ', Disc Date: '       || p_discontinued_dt
                                         || ', Crs Attempt Status: ' || p_course_attempt_status
                                         || ', Process Mode: '    || p_process_mode
                                         || ', Career: '          || p_c_career );
                p_message_name := NULL;
                log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                            p_v_string => 'Calling finpl_lock_records' );

               l_n_rec_count := 0;

              -- Before processing, obtain a lock in table IGS_FI_SPA_FEE_PRDS for the given Person-Course-Fee Period.
              IF  NOT finpl_lock_records(p_n_person_id               => p_person_id,
                                         p_v_course_cd               => p_course_cd,
                                         p_v_fee_cal_type            => p_fee_cal_type,
                                         p_n_fee_ci_sequence_number  => p_fee_ci_sequence_num) THEN
                      -- If lock could not be obtained, error out.
                      log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                  p_v_string => 'finpl_lock_records returned FALSE, locking not successful' );
                      RAISE e_lock_exception;
              END IF;

                -- Loop Across Active FCCIs as on Process Effective Date.
                log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                            p_v_string => 'Looping across FCCIs...');
                v_fcci_found := FALSE;
                FOR v_fcci_fss_rec IN c_fcci_fss(p_effective_dt) LOOP
                  v_fcci_found := TRUE;

                  log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                              p_v_string => 'FCCI: ' || v_fcci_fss_rec.fee_cal_type || ' '
                                            || TO_CHAR(v_fcci_fss_rec.start_dt, 'DD/MM/YYYY') || ' '
                                            || TO_CHAR(v_fcci_fss_rec.end_dt, 'DD/MM/YYYY'));
                  IF (p_trace_on = 'Y') THEN
                    -- Trace Entry
                    fnd_file.new_line(fnd_file.log);
                    fnd_message.set_name('IGS', 'IGS_FI_FEE_CAL');
                    fnd_message.set_token('CAL_TYPE', v_fcci_fss_rec.fee_cal_type);
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                    fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'START_DT') || ': ' || TO_CHAR(v_fcci_fss_rec.start_dt, 'DD/MM/YYYY'));
                    fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'END_DT') || ': ' || TO_CHAR(v_fcci_fss_rec.end_dt, 'DD/MM/YYYY'));
                  END IF;

                  log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                              p_v_string => 'Loop Accross FCFLs..' );

                  -- Process liabilities belonging to the fee category, operating in the assessment period
                  v_fcfl_found := FALSE;
                  g_v_fcfl_source := NULL;
                  FOR v_fcflv_rec IN c_fcflv( v_fcci_fss_rec.FEE_CAT,
                                              v_fcci_fss_rec.fee_cal_type,
                                              v_fcci_fss_rec.fee_ci_sequence_number,
                                              'ASSESSMENT')
                  LOOP

                    log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                p_v_string => '--------------------------' );
                    log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                p_v_string => 'FCFL: Source: ' || v_fcflv_rec.source || ': '
                                              || v_fcflv_rec.fee_cat || ', ' || v_fcflv_rec.fee_type || ', '|| v_fcflv_rec.fee_cal_type || ', '
                                              || v_fcflv_rec.fee_ci_sequence_number || ', '|| v_fcflv_rec.fee_liability_status || ', '
                                              || v_fcflv_rec.s_chg_method_type || ', '|| v_fcflv_rec.rul_sequence_number || ', '
                                              || v_fcflv_rec.currency_cd || ', '|| v_fcflv_rec.s_fee_structure_status || ', '
                                              || v_fcflv_rec.s_fee_trigger_cat || ', '|| v_fcflv_rec.s_fee_type || ', '|| v_fcflv_rec.start_dt_alias || ', '
                                              || v_fcflv_rec.start_dai_sequence_number || ', '|| v_fcflv_rec.end_dt_alias || ', '
                                              || v_fcflv_rec.end_dai_sequence_number);

                    g_inst_liable_progs_tbl := inst_liable_prog_dummy_tbl;
                    g_n_inst_progs_cntr := 0;
                    v_next_fcfl_flag := FALSE;
                    tbl_fai_unit_dtls.DELETE;
                    g_v_fcfl_source := RTRIM(v_fcflv_rec.source);

                    -- Check if Institution Fees can be assessed in Predictive Mode.
                    -- Flag g_b_prc_inst_fee is set in finpl_prc_predictive_scas
                    IF g_c_predictive_ind = 'Y' AND
                       v_fcflv_rec.s_fee_trigger_cat = gcst_institutn AND
                       g_b_prc_inst_fee = FALSE THEN

                      log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                  p_v_string => 'Predictive: Institution Fees can not be assessed. Proceeding with next FCFL.' );
                      v_next_fcfl_flag := TRUE;
                    END IF;

                    -- If validation of Institution fees fails, and those are the only FCFLs found
                    -- then message, IGS_FI_NOACTIVE_FEECAT_FEE_LI needs to be logged at the end.
                    IF v_next_fcfl_flag = FALSE THEN
                      v_fcfl_found := TRUE;
                    END IF;

                    -- added by schodava for Bug # 2021281
                    -- in case the fee trigger is institution then check
                    -- whether this particular fee cal instance has already been assessed for.
                    -- compare the FCFL status of the record in the pl/sql table with the v_fcflv_rec fcfl status
                    -- If already assessed, then set the next flag to true,
                    -- i.e. stop the processing of the present fcfl record.

                    IF v_next_fcfl_flag = FALSE AND
                       (v_fcflv_rec.s_fee_trigger_cat = gcst_institutn) THEN
                      FOR l_cntr IN 1..g_inst_fee_rec_cntr LOOP
                        IF p_person_id                            = l_inst_fee_rec(l_cntr).person_id              AND
                           v_fcflv_rec.fee_type                   = l_inst_fee_rec(l_cntr).fee_type               AND
                           v_fcflv_rec.fee_cal_type               = l_inst_fee_rec(l_cntr).fee_cal_type           AND
                           v_fcflv_rec.fee_ci_sequence_number     = l_inst_fee_rec(l_cntr).fee_ci_sequence_number AND
                           ( (v_fcflv_rec.fee_liability_status    <> l_inst_fee_rec(l_cntr).fcfl_status AND l_inst_fee_rec(l_cntr).fcfl_status = 'ACTIVE')
                             OR ( v_fcflv_rec.fee_liability_status = l_inst_fee_rec(l_cntr).fcfl_status ))        THEN

                          log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                      p_v_string => 'Institution Fee is already assessed for someother FCFL that has same FTCI. Proceed with next FCFL.' );
                          v_next_fcfl_flag := TRUE;
                        END IF;
                      END LOOP;
                    END IF;

                    -- If the FCFL source is OLD i.e., Fee As Table, and if its Institution Fee,
                    --   Then in case of ACTUAL mode, check if the FCFL is liable in any program that is other than program in context
                    --   If any other program is liable, then we don't reverse the Institution charge that is already present in DB.
                    --   i.e, proceed to next FCFL.
                    -- In case of PREDICTIVE mode, Institution Fees is assessed only for Key Program.

                    log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                p_v_string => 'Checking for other liable programs for Institution Fee in context.' );

                    IF (v_fcflv_rec.source = 'OLD') THEN
                      IF (g_c_predictive_ind = 'N') THEN
                        IF (v_fcflv_rec.s_fee_trigger_cat = gcst_institutn AND g_c_fee_calc_mthd <> g_v_primary_career) THEN
                          -- Check if any other program/career is liable for this Institution Fee
                          log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                      p_v_string => 'Checking for other liable programs for Institution Fee in context.' );
                          FOR l_std_term_spas IN c_std_term_spas('CRS_ATTEMPT_STATUS','Y') LOOP
                            -- check if the program is liable for any other program/ career
                            log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                        p_v_string => 'Calling check_stdnt_prg_att_liable for '|| l_std_term_spas.program_cd
                                                      || ', ' || l_std_term_spas.program_version || ', ' ||l_std_term_spas.fee_cat );
                            l_v_liable := igs_fi_gen_001.check_stdnt_prg_att_liable(
                                                           p_person_id,
                                                           l_std_term_spas.program_cd,
                                                           l_std_term_spas.program_version,
                                                           l_std_term_spas.fee_cat,
                                                           v_fcflv_rec.fee_type,
                                                           v_fcflv_rec.s_fee_trigger_cat,
                                                           v_fcflv_rec.fee_cal_type,
                                                           v_fcflv_rec.fee_ci_sequence_number,
                                                           l_std_term_spas.adm_admission_appl_number,
                                                           l_std_term_spas.adm_nominated_course_cd,
                                                           l_std_term_spas.adm_sequence_number,
                                                           l_std_term_spas.commencement_dt,
                                                           l_std_term_spas.discontinued_dt,
                                                           l_std_term_spas.cal_type,
                                                           l_std_term_spas.location_cd,
                                                           l_std_term_spas.attendance_mode,
                                                           l_std_term_spas.attendance_type);
                            IF l_v_liable = 'TRUE' THEN
                              -- If found liable for any other program/career then we should not be reversing the existing institution charges
                              log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                          p_v_string => 'Program ' || l_std_term_spas.program_cd || ' is liable. So proceed to next FCFL');
                              v_next_fcfl_flag := TRUE;
                              EXIT;
                            END IF;
                          END LOOP;
                        END IF;
                      END IF;
                    END IF;

                    IF v_next_fcfl_flag = FALSE THEN
                      BEGIN
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Calling finpl_init_fee_ass_item.' );
                        IF finpl_init_fee_ass_item (
                               p_person_id,
                               v_fcflv_rec.fee_type,
                               v_fcflv_rec.fee_cat,
                               v_fcflv_rec.fee_cal_type,
                               v_fcflv_rec.fee_ci_sequence_number,
                               p_course_cd,
                               p_effective_dt,
                               p_trace_on,
                               p_c_career) = FALSE THEN
                          log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                      p_v_string => 'finpl_init_fee_ass_item returned FALSE. Returning from finpl_prc_fee_cat_fee_liab.' );
                          RETURN FALSE;
                         END IF;
                      END;
                      -- Reset variables
                      v_charge_elements := 0;
                      v_fee_assessment := 0;

                      -- Log FCFL information.
                      IF (p_trace_on = 'Y' AND v_fcflv_rec.source <> 'OLD') THEN

                        IF (v_fcflv_rec.start_dt_alias IS NOT NULL) THEN
                                fnd_file.new_line(fnd_file.log);
                                OPEN c_daiv (
                                                v_fcflv_rec.start_dt_alias,
                                                v_fcflv_rec.start_dai_sequence_number,
                                                v_fcci_fss_rec.fee_cal_type,
                                                v_fcci_fss_rec.fee_ci_sequence_number);
                                FETCH c_daiv INTO v_fcflv_start_dt;
                                CLOSE c_daiv;
                                fnd_message.set_name('IGS', 'IGS_FI_START_DATE_ALIAS');
                                fnd_message.set_token('DT_ALIAS', v_fcflv_rec.start_dt_alias ||'    ');
                                fnd_file.put (fnd_file.log, fnd_message.get);
                                fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'START_DT') || ': ' || TO_CHAR(v_fcflv_start_dt, 'DD/MM/YYYY'));
                        END IF;
                        IF (v_fcflv_rec.end_dt_alias IS NOT NULL) THEN
                                OPEN c_daiv (
                                                v_fcflv_rec.end_dt_alias,
                                                v_fcflv_rec.end_dai_sequence_number,
                                                v_fcci_fss_rec.fee_cal_type,
                                                v_fcci_fss_rec.fee_ci_sequence_number);
                                FETCH c_daiv INTO v_fcflv_end_dt;
                                CLOSE c_daiv;
                                fnd_message.set_name('IGS', 'IGS_FI_END_DATE_ALIAS');
                                fnd_message.set_token('DT_ALIAS', v_fcflv_rec.end_dt_alias ||'    ');
                                fnd_file.put (fnd_file.log, fnd_message.get);
                                fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'END_DT') || ': ' || TO_CHAR(v_fcflv_end_dt, 'DD/MM/YYYY'));
                        END IF;

                        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_TYPE') || ': ' || v_fcflv_rec.fee_type);
                        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'SYSTEM_FEE_TYPE') || ': ' || v_fcflv_rec.s_fee_type);
                        fnd_message.set_name('IGS', 'IGS_FI_FEE_TYPE_TRG_CAT');
                        fnd_message.set_token('S_FEE_TRIG', v_fcflv_rec.s_fee_trigger_cat);
                        fnd_file.put_line (fnd_file.log, fnd_message.get);

                        fnd_message.set_name('IGS', 'IGS_FI_CHG_METH_TYPE');
                        fnd_message.set_token('CHG_MTHD', igs_fi_gen_gl.get_lkp_meaning('CHG_METHOD', v_fcflv_rec.s_chg_method_type));
                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'RULE_SEQ') || ': ' || TO_CHAR(v_fcflv_rec.rul_sequence_number));
                        IF (v_fcflv_rec.scope_rul_sequence_num IS NOT NULL) THEN
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'SEL_CRI_RULE') || ': ' || TO_CHAR(v_fcflv_rec.scope_rul_sequence_num));
                        END IF;
                        IF (v_fcflv_rec.elm_rng_order_name IS NOT NULL) THEN
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'ELM_RNG_ORDER') || ': ' || v_fcflv_rec.elm_rng_order_name);
                        END IF;
                        IF (v_fcflv_rec.max_chg_elements IS NOT NULL) THEN
                          fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'MAX_CHG_ELM') || ': ' || TO_CHAR(v_fcflv_rec.max_chg_elements));
                        END IF;
                      END IF;
                    END IF; /* v_next_fcfl_flag = FALSE */

                    -- Audit Fees Cannot be assessed in Predictive mode.
                    IF v_next_fcfl_flag = FALSE
                       AND g_c_predictive_ind = 'Y'
                       AND v_fcflv_rec.s_fee_type = g_v_audit THEN
                      IF (p_trace_on = 'Y' AND v_fcflv_rec.source <> 'OLD') THEN
                        fnd_message.set_name ( 'IGS', 'IGS_FI_PRED_MODE_NO_AUDIT_FEE');
                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                      END IF;
                      log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                  p_v_string => 'Predictive: Audit Fees can not be assessed. Proceeding with next FCFL.' );
                      v_next_fcfl_flag := TRUE;
                    END IF;

                    -- Charge method 'Per Unit' cannot be processed in Predictive mode.

                    IF (v_next_fcfl_flag = FALSE) THEN
                      IF (g_c_predictive_ind = 'Y') THEN

                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Predictive: Checking validation of PER UNIT Chg Mthd.' );

                        IF (v_fcflv_rec.s_chg_method_type = gcst_perunit) THEN
                          -- a PER UNIT charge method cannot be carried out in predictive assessment
                          IF (p_trace_on = 'Y' AND v_fcflv_rec.source <> 'OLD') THEN
                            fnd_message.set_name ( 'IGS', 'IGS_FI_PREDASS_PERUNIT_CHGMTH');
                            fnd_file.put_line (fnd_file.log, fnd_message.get);
                          END IF;
                          log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                      p_v_string => 'PER UNIT Chg Mthd can not be processed in Predictive. Proceed to next FCFL.' );
                          v_next_fcfl_flag := TRUE;
                        END IF;
                      END IF;
                    END IF;

                    IF (v_next_fcfl_flag = FALSE) THEN
                      IF (finpl_get_derived_am_at(p_person_id,
                                                  p_course_cd,
                                                  p_effective_dt,
                                                  v_fcflv_rec.fee_cal_type,
                                                  v_fcflv_rec.fee_ci_sequence_number,
                                                  v_fcflv_rec.FEE_TYPE,
                                                  v_fcflv_rec.s_fee_trigger_cat,
                                                  p_trace_on,
                                                  p_c_career,
                                                  l_v_attendance_type,
                                                  l_v_attendance_mode) = FALSE) THEN
                        RETURN FALSE;
                      END IF;
                      log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                  p_v_string => 'Checking FCFL status...' );
                      -- Check the fee liability status
                      IF (v_fcflv_rec.s_fee_structure_status = gcst_planned) THEN
                        v_message_name := 'IGS_FI_FEELIAB_STATU_PLANNED';
                        IF (p_trace_on = 'Y' AND v_fcflv_rec.source <> 'OLD') THEN
                          fnd_message.set_name ( 'IGS', v_message_name);
                          fnd_file.put_line (fnd_file.log, fnd_message.get);
                        END IF;
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'FCFL Status is Planned. So Proceed with next FCFL.' );
                        v_next_fcfl_flag := TRUE;

                      ELSIF (v_fcflv_rec.s_fee_structure_status = gcst_inactive) THEN
                        -- The liability may have been ACTIVE at the time of
                        -- the last assessment and an assessment could have
                        -- been recorded, therefore we must clear it.
                        v_message_name := 'IGS_FI_FEELIAB_STATU_INACTIVE';
                        IF (p_trace_on = 'Y' AND v_fcflv_rec.source <> 'OLD') THEN
                          -- Trace entry
                          fnd_message.set_name ( 'IGS', v_message_name);
                          fnd_file.put_line (fnd_file.log, fnd_message.get);
                        END IF;

                        v_fee_assessment := 0;
                        v_charge_rate := 0;

                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'FCFL Status is Inactive. So call finpl_ins_fee_ass with assessment amount 0.' );
                        -- Perform 2.4 Record Assessment Amount
                        finpl_ins_fee_ass(
                                        p_person_id,
                                        p_course_cd,
                                        v_fcflv_rec.FEE_TYPE,
                                        v_fcflv_rec.fee_cal_type,
                                        v_fcflv_rec.fee_ci_sequence_number,
                                        v_fcflv_rec.s_fee_trigger_cat,
                                        v_fcflv_rec.fee_cat,
                                        p_local_currency,
                                        v_charge_rate,
                                        v_fcflv_rec.s_fee_type,
                                        p_effective_dt,
                                        p_trace_on,
                                        p_course_version_number,
                                        p_course_attempt_status,
                                        l_v_attendance_mode,
                                        l_v_attendance_type,
                                        v_charge_elements,
                                        v_fee_assessment,
                                        v_fcflv_rec.fee_liability_status,
                                        v_fcflv_rec.rul_sequence_number,
                                        v_fcflv_rec.scope_rul_sequence_num,
                                        v_fcflv_rec.s_chg_method_type,
                                        p_scahv_location_cd,
                                        p_c_career,
                                        v_fcflv_rec.elm_rng_order_name,
                                        v_fcflv_rec.max_chg_elements );
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'FCFL Status is Inactive. So proceed with next FCFL.' );
                        v_next_fcfl_flag := TRUE;

                      ELSIF (v_fcflv_rec.s_fee_structure_status = gcst_active) THEN
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'FCFL Status is Active. So carrying out Date Alias Validations.' );
                        -- Check if End Date Alias of FCCI and FCFL are same. If Not, check End Date Alias validation.
                        IF v_fcci_fss_rec.end_dt_alias <> v_fcflv_rec.end_dt_alias
                           OR v_fcci_fss_rec.end_dai_sequence_number <> v_fcflv_rec.end_dai_sequence_number THEN
                          IF (TRUNC(SYSDATE) > TRUNC(v_fcflv_end_dt)) THEN
                            IF (p_trace_on = 'Y') THEN
                              fnd_file.new_line(fnd_file.log);
                              fnd_message.set_name('IGS','IGS_ST_PROC_NEXT_FEE_CAT_CAL');
                              fnd_file.put_line (fnd_file.log, fnd_message.get);
                            END IF;
                            log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                        p_v_string => 'Today is past the fee assessment processing period. Processing next fee category calendar instance.' );
                            v_next_fcfl_flag := TRUE;
                          END IF;
                        END IF;
                      END IF; /* FCFL Status */
                    END IF; /* v_next_fcfl_flag = FALSE */

                    -- Check if Process Effective Date falls within Start and End Dates of FCFL.
                    IF (v_next_fcfl_flag = FALSE) THEN
                      IF g_c_predictive_ind = 'N'
                         AND (TRUNC(p_effective_dt) NOT BETWEEN TRUNC(v_fcflv_start_dt)
                                                                AND TRUNC(v_fcflv_end_dt)) THEN

                        v_fee_assessment := 0;
                        v_charge_rate := 0;
                        IF (p_trace_on = 'Y') THEN
                          -- Trace Entry
                          fnd_file.new_line(fnd_file.log);
                          fnd_message.set_name('IGS','IGS_FI_ST_DT_ASS_AMT');
                          fnd_message.set_token('OLD_AMT', TO_CHAR(v_fee_assessment) );
                          fnd_file.put_line (fnd_file.log, fnd_message.get);
                        END IF;

                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Effective Date does not fall within FCFL start date and end date. Calling finpl_ins_fee_ass with Assessment amount as 0.' );

                        -- Perform 2.4 Record Assessment Amount
                        finpl_ins_fee_ass(
                                        p_person_id,
                                        p_course_cd,
                                        v_fcflv_rec.FEE_TYPE,
                                        v_fcflv_rec.fee_cal_type,
                                        v_fcflv_rec.fee_ci_sequence_number,
                                        v_fcflv_rec.s_fee_trigger_cat,
                                        v_fcflv_rec.fee_cat,
                                        p_local_currency,
                                        v_charge_rate,
                                        v_fcflv_rec.s_fee_type,
                                        p_effective_dt,
                                        p_trace_on,
                                        p_course_version_number,
                                        p_course_attempt_status,
                                        l_v_attendance_mode,
                                        l_v_attendance_type,
                                        v_charge_elements,
                                        v_fee_assessment,
                                        v_fcflv_rec.fee_liability_status,
                                        v_fcflv_rec.rul_sequence_number,
                                        v_fcflv_rec.scope_rul_sequence_num,
                                        v_fcflv_rec.s_chg_method_type,
                                        p_scahv_location_cd,
                                        p_c_career,
                                        v_fcflv_rec.elm_rng_order_name,
                                        v_fcflv_rec.max_chg_elements );
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Effective Date does not fall within FCFL start date and end date. Proceed with next FCFL.' );
                        v_next_fcfl_flag := TRUE;
                      END IF;
                    END IF;

                    -- In case of Predictive, FCFL Start Date should be less than or equal to SYSDATE
                    IF v_next_fcfl_flag = FALSE THEN
                      IF g_c_predictive_ind = 'Y' AND  TRUNC(SYSDATE) >= TRUNC(v_fcflv_start_dt) THEN
                        IF (p_trace_on = 'Y') THEN
                          fnd_message.set_name('IGS','IGS_FI_PRED_PAST_TERM');
                          fnd_message.set_token('DT_ALIAS', v_fcflv_rec.start_dt_alias );
                          fnd_message.set_token('ALT_CD', g_v_fee_alt_code );
                          fnd_file.put_line (fnd_file.log, fnd_message.get);
                        END IF;
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'FCFL Start Date is greater than SYSDATE. Proceed to next FCFL.' );
                        v_next_fcfl_flag := TRUE;
                      END IF;
                    END IF;

                    -- Perform 2.1 Check Fee Triggers
                    IF (v_next_fcfl_flag = FALSE) THEN

                      log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                  p_v_string => 'Checking Fee Trigger. Arguments passed: '
                                                || 'Fee Cat: ' || v_fcci_fss_rec.fee_cat
                                                || ', Fee Cal Type: ' || p_fee_cal_type
                                                || ', Fee Cal Seq Num: ' || p_fee_ci_sequence_num
                                                || ', Fee Type: ' || v_fcflv_rec.fee_type
                                                || ', Fee Trig Cat: ' || v_fcflv_rec.s_fee_trigger_cat
                                                || ', Effective Dt: ' || TO_CHAR(p_effective_dt, 'DD-MON-YYYY HH24:MI:SS')
                                                || ', Person Id: ' || p_person_id
                                                || ', Course Cd: ' || p_course_cd
                                                || ', Course Ver: ' || p_course_version_number
                                                || ', Cal Type: ' || p_cal_type
                                                || ', Location Cd: ' || p_scahv_location_cd
                                                || ', Att Mode: ' || p_scahv_attendance_mode
                                                || ', Att Type: ' || p_scahv_attendance_type );
                      IF (igs_fi_gen_005.finp_val_fee_trigger(
                                      v_fcci_fss_rec.fee_cat,
                                      p_fee_cal_type,
                                      p_fee_ci_sequence_num,
                                      v_fcflv_rec.fee_type,
                                      v_fcflv_rec.s_fee_trigger_cat,
                                      p_effective_dt,
                                      p_person_id,
                                      p_course_cd,
                                      p_course_version_number,
                                      p_cal_type,
                                      p_scahv_location_cd,
                                      p_scahv_attendance_mode,
                                      p_scahv_attendance_type,
                                      v_trigger_fired) = TRUE) THEN
                        -- Trigger was fired.
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Trigger Fired: ' || v_trigger_fired );
                        IF (v_trigger_fired = 'INSTITUTN') THEN
                                IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_FEETRGCAT_INSTITUTN');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;
                        ELSIF (v_trigger_fired = 'CTFT') THEN
                                IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_PRGTYPE_FEETRG_MATCHES');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;
                        ELSIF (v_trigger_fired = 'CGFT') THEN
                                IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_PRGGRP_FEETRG_PRGATT');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;
                        ELSIF (v_trigger_fired = 'CFT') THEN
                                IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_PRGFEE_TRGATTRIB_MATCH');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;
                        ELSIF (v_trigger_fired = 'UFT') THEN
                                IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_UNIT_FEETRG_ATTRIB');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;
                        ELSIF (v_trigger_fired = 'USFT') THEN
                                IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_UNIT_SET_FEETRG_ATTRIB');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;
                        ELSIF (v_trigger_fired = 'AUDIT') THEN
                                IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_AUD_FEE_TRIG_FIRED');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;
                        ELSIF (v_trigger_fired = 'COMPOSITE') THEN
                                IF (p_trace_on = 'Y') THEN
                                        fnd_file.new_line(fnd_file.log);
                                        fnd_message.set_name ( 'IGS', 'IGS_FI_FEETRG_GRP_MEMBER');
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END IF;

                        END IF;
                      ELSE    -- Trigger did not fire
                        v_fee_assessment := 0;
                        v_charge_rate := 0;
                        v_message_name := 'IGS_FI_TRG_DID_NOT_FIRE';
                        IF (p_trace_on = 'Y') THEN
                                -- Trace Entry
                                fnd_message.set_name ( 'IGS', v_message_name);
                                fnd_file.put_line (fnd_file.log, fnd_message.get);
                                fnd_file.new_line(fnd_file.log);
                                fnd_message.set_name('IGS','IGS_FI_ASS_AMT');
                                fnd_message.set_token('AMOUNT',TO_CHAR(v_fee_assessment) );
                                fnd_file.put_line (fnd_file.log, fnd_message.get);
                        END IF;

                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Trigger Not fired. Call finpl_ins_fee_ass with assessment amount 0.');
                        -- Perform 2.4 Record Assessment Amount
                        finpl_ins_fee_ass(
                                        p_person_id,
                                        p_course_cd,
                                        v_fcflv_rec.FEE_TYPE,
                                        v_fcflv_rec.fee_cal_type,
                                        v_fcflv_rec.fee_ci_sequence_number,
                                        v_fcflv_rec.s_fee_trigger_cat,
                                        p_fee_cat,
                                        p_local_currency,
                                        v_charge_rate,
                                        v_fcflv_rec.s_fee_type,
                                        p_effective_dt,
                                        p_trace_on,
                                        p_course_version_number,
                                        p_course_attempt_status,
                                        l_v_attendance_mode,
                                        l_v_attendance_type,
                                        v_charge_elements,
                                        v_fee_assessment,
                                        v_fcflv_rec.fee_liability_status,
                                        v_fcflv_rec.rul_sequence_number,
                                        v_fcflv_rec.scope_rul_sequence_num,
                                        v_fcflv_rec.s_chg_method_type,
                                        p_scahv_location_cd,
                                        p_c_career,
                                        v_fcflv_rec.elm_rng_order_name,
                                        v_fcflv_rec.max_chg_elements );
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Trigger Not fired. Proceed with next FCFL.');
                        v_next_fcfl_flag := TRUE;
                      END IF; /* igs_fi_gen_005.finp_val_fee_trigger */
                    END IF;


                    IF p_process_mode IN ('ACTUAL','PREDICTIVE') THEN
                      IF (v_next_fcfl_flag = FALSE) THEN
                        -- Perform 2.2 Calculate Charge Method Elements
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Calling finpl_clc_chg_mthd_elements...');
                        IF (finpl_clc_chg_mthd_elements(
                                        p_effective_dt,
                                        p_trace_on,
                                        p_person_id,
                                        p_course_cd,
                                        p_course_version_number,
                                        p_scahv_attendance_type,
                                        p_course_attempt_status,
                                        v_fcflv_rec.s_chg_method_type,
                                        v_fcci_fss_rec.FEE_CAT,
                                        v_fcflv_rec.fee_cal_type,
                                        v_fcflv_rec.fee_ci_sequence_number,
                                        v_fcflv_rec.FEE_TYPE,
                                        v_fcflv_rec.s_fee_type,
                                        v_fcflv_rec.s_fee_trigger_cat,
                                        v_charge_elements,
                                        p_message_name,
                                        p_scahv_location_cd,
                                        p_c_career,
                                        v_fcflv_rec.scope_rul_sequence_num) = FALSE) THEN
                          log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                      p_v_string => 'finpl_clc_chg_mthd_elements returned FALSE with message ' || p_message_name || '. Proceed with next FCFL.');
                          v_next_fcfl_flag := TRUE;
                        END IF;
                      END IF;

                      IF (v_next_fcfl_flag = FALSE) THEN
                        IF (v_charge_elements > 0) THEN
                          -- Perform 2.3 Calculate Assessment Amount
                          IF (p_trace_on = 'Y') THEN
                              fnd_file.new_line(fnd_file.log);
                              fnd_message.set_name('IGS','IGS_FI_CHRG_METHOD_ELEMENTS');
                              fnd_message.set_token('CHG_ELM',TO_CHAR(v_charge_elements) );
                              fnd_file.put_line (fnd_file.log, fnd_message.get);
                          END IF;
                          log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                      p_v_string => 'Calling finp_clc_ass_amnt..');
                          IF (finp_clc_ass_amnt(
                                      p_effective_dt,
                                      p_person_id,
                                      p_course_cd,
                                      p_course_version_number,
                                      p_course_attempt_status,
                                      v_fcflv_rec.FEE_TYPE,
                                      v_fcflv_rec.fee_cal_type,
                                      v_fcflv_rec.fee_ci_sequence_number,
                                      v_fcci_fss_rec.FEE_CAT,
                                      v_fcflv_rec.s_fee_type,
                                      v_fcflv_rec.s_fee_trigger_cat,
                                      v_fcflv_rec.rul_sequence_number,
                                      v_fcflv_rec.s_chg_method_type,
                                      p_scahv_location_cd,
                                      p_scahv_attendance_type,
                                      p_scahv_attendance_mode,
                                      p_trace_on,
                                      p_creation_dt, -- in out
                                      v_charge_elements,      -- in out
                                      v_fee_assessment,       -- in out
                                      v_charge_rate,
                                      p_c_career,
                                      v_fcflv_rec.elm_rng_order_name,
                                      v_fcflv_rec.max_chg_elements,
                                      0) = FALSE) THEN
                            log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                        p_v_string => 'finp_clc_ass_amnt returned FALSE. Proceed with next FCFL. Out Vars: Chg Elms: '
                                                      || v_charge_elements || ', Amount: ' || v_fee_assessment );
                            v_next_fcfl_flag := TRUE;
                          END IF;
                        ELSE
                          log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                      p_v_string => 'No Charge Elements found so make Assessment Amount to 0.');
                          v_fee_assessment := 0;
                          v_charge_rate := 0;
                          IF (p_trace_on = 'Y') THEN
                            fnd_message.set_name ( 'IGS', 'IGS_FI_NO_CHARGE_ELEMENTS');
                            fnd_file.put_line (fnd_file.log, fnd_message.get);
                            fnd_file.new_line(fnd_file.log);
                            fnd_message.set_name('IGS', 'IGS_FI_ASS_AMT');
                            fnd_message.set_token('AMOUNT', TO_CHAR(v_fee_assessment) );
                            fnd_file.put_line (fnd_file.log, fnd_message.get);
                          END IF;

                        END IF; /* v_charge_elements > 0 */
                      END IF;
                    END IF; /* p_process_mode IN ('ACTUAL','PREDICTIVE') */

                    IF (v_next_fcfl_flag = FALSE) THEN

                      --Added as part of Tuition Waivers
                      IF (NVL(p_v_wav_calc_flag,'N') = 'Y') THEN
                        p_n_waiver_amount := NVL(p_n_waiver_amount,0) + NVL(v_fee_assessment,0);
                        log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                    p_v_string => 'Assigning v_fee_assessment cumulatively to p_n_waiver_amount of '||p_n_waiver_amount);
                        RETURN TRUE;
                      END IF;

                      -- Perform 2.4 Record Assessment Amount
                      log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                  p_v_string => 'Calling finpl_ins_fee_ass..' );
                      finpl_ins_fee_ass(
                               p_person_id,
                               p_course_cd,
                               v_fcflv_rec.fee_type,
                               v_fcflv_rec.fee_cal_type,
                               v_fcflv_rec.fee_ci_sequence_number,
                               v_fcflv_rec.s_fee_trigger_cat,
                               p_fee_cat,
                               p_local_currency,
                               v_charge_rate,
                               v_fcflv_rec.s_fee_type,
                               p_effective_dt,
                               p_trace_on,
                               p_course_version_number,
                               p_course_attempt_status,
                               l_v_attendance_mode,
                               l_v_attendance_type,
                               v_charge_elements,
                               v_fee_assessment,
                               v_fcflv_rec.fee_liability_status,
                               v_fcflv_rec.rul_sequence_number,
                               v_fcflv_rec.scope_rul_sequence_num,
                               v_fcflv_rec.s_chg_method_type,
                               p_scahv_location_cd,
                               p_c_career,
                               v_fcflv_rec.elm_rng_order_name,
                               v_fcflv_rec.max_chg_elements );
                      log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                  p_v_string => 'After finpl_ins_fee_ass for this FCFL. Proceed with next FCFL.' );
                    END IF;
                    --Added as part of Tuition Waivers Build
                    IF (p_v_wav_calc_flag = 'N' AND p_waiver_call_ind = 'N') THEN
                      IF (igs_fi_wav_utils_002.check_stdnt_wav_assignment( p_n_person_id         => p_person_id,
                                                                       p_v_fee_type          => v_fcflv_rec.fee_type,
                                                                       p_v_fee_cal_type      => p_fee_cal_type,
                                                                       p_n_fee_ci_seq_number => p_fee_ci_sequence_num ) = TRUE) THEN
                         FOR rec_fcfl IN cur_fcfl(v_fcflv_rec.fee_cat, p_fee_cal_type, p_fee_ci_sequence_num, v_fcflv_rec.fee_type)
                         LOOP
                           l_n_rec_count := tbl_wav_fcfl.COUNT + 1;
                           tbl_wav_fcfl(l_n_rec_count).p_fee_category := rec_fcfl.fee_cat;
                           tbl_wav_fcfl(l_n_rec_count).p_fee_type := rec_fcfl.fee_type;
                           tbl_wav_fcfl(l_n_rec_count).p_course_cd := p_course_cd;
                           tbl_wav_fcfl(l_n_rec_count).p_career := p_c_career;
                           log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                       p_v_string => 'Adding record '||l_n_rec_count||' in tbl_wav_fcfl, Fee Cat: '|| rec_fcfl.fee_cat
                                                     ||', Fee Type: '||rec_fcfl.fee_type||', Course Cd: '||p_course_cd
                                                     ||', Career: '||p_c_career);
                         END LOOP;
                      END IF;
                    END IF;
                  END LOOP; /* End of Loop of FCFL */

                  IF (v_fcfl_found = FALSE) THEN
                    v_message_name := 'IGS_FI_NOACTIVE_FEECAT_FEE_LI';
                    IF (p_trace_on = 'Y') THEN
                      fnd_message.set_name ( 'IGS', v_message_name);
                      fnd_file.put_line (fnd_file.log, fnd_message.get);
                    END IF;
                    log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                                p_v_string => 'No Active FCFL found. Ending the processing. ' || v_message_name );
                  END IF;
                END LOOP; /* End of Loop of FCCI */

                -- Log a message if no Active FCCI records exist.
                IF (v_fcci_found = FALSE) THEN
                  IF (p_trace_on = 'Y') THEN
                    fnd_file.new_line(fnd_file.log);
                    fnd_message.set_name ( 'IGS', 'IGS_FI_NOACTIVE_FEECATCAL_INS');
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                              p_v_string => 'No Active FCCI found. Ending the processing. IGS_FI_NOACTIVE_FEECATCAL_INS' );
                END IF;

                log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                            p_v_string => 'Returning from finpl_prc_fee_cat_fee_liab. Out - Message: ' || p_message_name );
                RETURN TRUE;
        END;
   EXCEPTION
        WHEN e_lock_exception THEN
                log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                            p_v_string => 'In Exception Handler of e_lock_exception' );
                fnd_message.set_name('IGS', 'IGS_FI_FEEAS_NO_CONC_RUN');
                fnd_message.set_token('PERSON_NUM',g_v_person_number);
                fnd_message.set_token('FEE_PERIOD',g_v_fee_alt_code);
                igs_ge_msg_stack.add;
                app_exception.raise_exception(NULL, NULL, fnd_message.get);
          WHEN OTHERS THEN
                  log_to_fnd( p_v_module => 'finpl_prc_fee_cat_fee_liab',
                              p_v_string => 'From exception handler of WHEN OTHERS of finpl_prc_fee_cat_fee_liab.' );
                  Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                  Fnd_Message.Set_Token('NAME','IGS_FI_PRC_FEE_ASS.FINPL_PRC_FEE_CAT_FEE_LIAB-'||SUBSTR(sqlerrm,1,500));
                  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
        END finpl_prc_fee_cat_fee_liab;

    PROCEDURE finpl_prc_predictive_scas ( p_n_person_id           IN igs_fi_fee_as_items.person_id%TYPE,
                                          p_v_course_cd           IN igs_ps_ver_all.course_cd%TYPE,
                                          p_v_career              IN igs_ps_ver_all.course_type%TYPE,
                                          p_v_fee_category        IN igs_fi_fee_cat_all.fee_cat%TYPE,
                                          p_v_fee_cal_type        IN igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                                          p_n_fee_ci_sequence_num IN igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE,
                                          p_v_curr_cd             IN igs_fi_control_all.currency_cd%TYPE,
                                          p_d_effective_date      IN DATE,
                                          p_v_trace_on            IN VARCHAR2,
                                          p_b_record_found        OUT NOCOPY BOOLEAN,
                                          p_v_message_name        OUT NOCOPY VARCHAR2,
                                          p_b_return_status       OUT NOCOPY BOOLEAN,
                                          p_waiver_call_ind       IN VARCHAR2,
                                          p_target_fee_type       IN VARCHAR2
                                          ) IS
    /*************************************************************
     Created By :      Shirish Tatikonda
     Date Created By : 30-DEC-2003
     Purpose :         All program attempts that needs to be assessed in PREDICTIVE Mode
                       will be identified in this procedure.
                       Called from finp_ins_enr_fee_ass.

     Know limitations, enhancements or remarks
     Change History
     Who             When          What
     rmaddipa        03-NOV-2004   Enh 3988455, Modified definitions of cursors c_get_term_recs, c_get_scas_recs
     shtatiko        30-DEC-2003   Enh# 3167098, Created this function.
    ***************************************************************/

      TYPE prd_prog_details_rec_typ IS RECORD (
             person_id          hz_parties.party_id%TYPE,
             program_cd         igs_ps_ver_all.course_cd%TYPE,
             program_version    igs_ps_ver_all.version_number%TYPE,
             career             igs_ps_ver_all.course_type%TYPE,
             fee_cat            igs_fi_fee_cat_all.fee_cat%TYPE,
             crs_cal_type       igs_en_stdnt_ps_att_all.cal_type%TYPE,
             location_cd        igs_en_stdnt_ps_att_all.location_cd%TYPE,
             att_mode           igs_en_stdnt_ps_att_all.attendance_mode%TYPE,
             att_type           igs_en_stdnt_ps_att_all.attendance_type%TYPE,
             key_program        igs_en_stdnt_ps_att_all.key_program%TYPE,
             crs_attempt_status igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
             crs_commence_dt    igs_en_stdnt_ps_att_all.commencement_dt%TYPE,
             disc_dt            igs_en_stdnt_ps_att_all.discontinued_dt%TYPE,
             adm_admission_appl_number igs_en_stdnt_ps_att_all.adm_admission_appl_number%TYPE,
             adm_nominated_course_cd   igs_en_stdnt_ps_att_all.adm_nominated_course_cd%TYPE,
             adm_sequence_number       igs_en_stdnt_ps_att_all.adm_sequence_number%TYPE,
             source             VARCHAR2 (1)
           );

      -- This table type will hold the assessable program details Under Predictive Mode of Processing.
      TYPE predictive_progs_tbl_typ IS TABLE OF prd_prog_details_rec_typ
        INDEX BY BINARY_INTEGER;

      l_predictive_progs_tbl predictive_progs_tbl_typ;
      l_n_prd_progs_cntr   NUMBER;

      l_b_term_key_prg_found  BOOLEAN;

      -- Cursor to get Fee Assessable Program Attempts from Terms Table.
      --Enh 3988455: Uptake of Program Transfer Enhancements
      --Cursor modified to ignore program attempts with Future-Dated Transfer flag set to 'C'
      CURSOR c_get_term_recs(cp_n_person_id    igs_fi_fee_as_items.person_id%TYPE,
                             cp_v_fee_category igs_fi_fee_cat_all.fee_cat%TYPE,
                             cp_v_course_cd    igs_ps_ver_all.course_cd%TYPE,
                             cp_v_career       igs_ps_ver_all.course_type%TYPE,
                             cp_v_key_program_flag        igs_en_spa_terms.key_program_flag%TYPE,
                             cp_v_course_attempt_status1  igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                             cp_v_course_attempt_status2  igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                             cp_v_course_attempt_status3  igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                             cp_v_course_attempt_status4  igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                             cp_v_future_dated_trans_flag igs_en_stdnt_ps_att_all.future_dated_trans_flag%TYPE
                            ) IS
        SELECT spat.person_id,
               spat.program_cd,
               spat.program_version,
               psv.course_type,
               spat.fee_cat,
               sca.cal_type,
               spat.location_cd,
               spat.attendance_mode,
               spat.attendance_type,
               spat.key_program_flag,
               sca.course_attempt_status,
               sca.commencement_dt,
               sca.discontinued_dt
        FROM igs_en_spa_terms spat,
             igs_en_stdnt_ps_att_all sca,
             igs_ps_ver_all psv
        WHERE spat.program_cd = psv.course_cd
        AND spat.program_version = psv.version_number
        AND spat.person_id = cp_n_person_id
        AND spat.program_cd = sca.course_cd
        AND spat.program_version = sca.version_number
        AND spat.person_id = sca.person_id
        AND
         (spat.term_cal_type = g_v_load_cal_type
          AND
          spat.term_sequence_number = g_n_load_seq_num
         )
        AND (cp_v_fee_category IS NULL OR spat.fee_cat = cp_v_fee_category)
        AND (cp_v_course_cd IS NULL OR spat.program_cd = cp_v_course_cd)
        AND (cp_v_career IS NULL OR cp_v_career = psv.course_type)
        AND (
             (g_c_fee_calc_mthd IN (g_v_program,g_v_career)) -- Get all Term Records
             OR
             (spat.key_program_flag = cp_v_key_program_flag AND g_c_fee_calc_mthd = g_v_primary_career)  -- Get only record of Key Program
            )
        AND (
             ( g_c_fee_calc_mthd = g_v_program
               AND (sca.course_attempt_status IN  (cp_v_course_attempt_status1, cp_v_course_attempt_status2, cp_v_course_attempt_status3, cp_v_course_attempt_status4)
                    AND (NVL(sca.future_dated_trans_flag,'N') <> cp_v_future_dated_trans_flag)
                    )
             )
             OR
             ( g_c_fee_calc_mthd IN (g_v_career, g_v_primary_career)
               AND sca.course_attempt_status in (cp_v_course_attempt_status1, cp_v_course_attempt_status2, cp_v_course_attempt_status3))
            )
        ORDER BY spat.fee_cat,
                 spat.person_id,
                 spat.program_cd;

      -- Cursor to fetch Program Attempts from Student Program Attempt table.
      --Enh 3988455: Uptake of Program Transfer Enhancements
      --Cursor modified to ignore program attempts with Future-Dated Transfer flag set to 'C'
      CURSOR c_get_scas_recs(cp_n_person_id igs_fi_fee_as_items.person_id%TYPE,
                             cp_v_fee_cat   igs_fi_fee_cat_all.fee_cat%TYPE,
                             cp_v_course_cd igs_ps_ver_all.course_cd%TYPE,
                             cp_v_career    igs_ps_ver_all.course_type%TYPE,
                             cp_v_primary_program_type    igs_en_stdnt_ps_att_all.primary_program_type%TYPE,
                             cp_v_key_program             igs_en_stdnt_ps_att_all.key_program%TYPE,
                             cp_v_course_attempt_status1  igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                             cp_v_course_attempt_status2  igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                             cp_v_course_attempt_status3  igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                             cp_v_course_attempt_status4  igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                             cp_v_future_dated_trans_flag igs_en_stdnt_ps_att_all.future_dated_trans_flag%TYPE ) IS
        SELECT sca.person_id,
               sca.course_cd,
               sca.version_number,
               psv.course_type,
               sca.fee_cat,
               sca.cal_type,
               sca.location_cd,
               sca.attendance_mode,
               sca.attendance_type,
               sca.key_program,
               sca.course_attempt_status,
               sca.commencement_dt,
               sca.discontinued_dt,
               sca.adm_admission_appl_number,
               sca.adm_nominated_course_cd,
               sca.adm_sequence_number
        FROM igs_en_stdnt_ps_att_all sca,
             igs_ps_ver_all psv
        WHERE sca.course_cd = psv.course_cd
        AND sca. version_number = psv.version_number
        AND sca.person_id = cp_n_person_id
        AND (cp_v_fee_cat IS NULL OR sca.fee_cat = cp_v_fee_cat)
        AND (cp_v_course_cd IS NULL OR sca.course_cd = cp_v_course_cd)
        AND (cp_v_career IS NULL OR psv.course_type = cp_v_career)
        AND (
             (g_c_fee_calc_mthd =g_v_program)
             OR
             (g_c_fee_calc_mthd =g_v_career AND sca.primary_program_type = cp_v_primary_program_type )
             OR
             (g_c_fee_calc_mthd = g_v_primary_career AND sca.key_program = cp_v_key_program)
            )
        AND (
             (g_c_fee_calc_mthd = g_v_program AND (sca.course_attempt_status IN  (cp_v_course_attempt_status1, cp_v_course_attempt_status2, cp_v_course_attempt_status3, cp_v_course_attempt_status4)
                                                   AND (NVL(sca.future_dated_trans_flag,'N') <> cp_v_future_dated_trans_flag)
                                                   )
             )
             OR
             (g_c_fee_calc_mthd IN (g_v_career, g_v_primary_career) AND sca.course_attempt_status in (cp_v_course_attempt_status1, cp_v_course_attempt_status2, cp_v_course_attempt_status3))
            )
        ORDER BY sca.fee_cat,
                 sca.person_id,
                 sca.course_cd;

      CURSOR c_fee_cat_curr (cp_v_fee_cat IN igs_fi_fee_cat_all.fee_cat%TYPE) IS
        SELECT currency_cd
        FROM igs_fi_fee_cat_all
        WHERE fee_cat = cp_v_fee_cat;
      rec_cur_fee_cat_curr c_fee_cat_curr%ROWTYPE;

      l_b_rec_found_at_terms BOOLEAN;
      l_b_prog_att_liable    BOOLEAN;
      l_n_cntr               NUMBER;

      FUNCTION find_record_exists ( p_v_course_cd  IN igs_ps_ver_all.course_cd%TYPE,
                                    p_v_career     IN igs_ps_ver_all.course_type%TYPE ) RETURN BOOLEAN IS
      /*************************************************************
       Created By :      Shirish Tatikonda
       Date Created By : 30-DEC-2003
       Purpose :         Function to check whether the given course/career is already existing in the table.

       Know limitations, enhancements or remarks
       Change History
       Who             When          What
       shtatiko        30-DEC-2003   Enh# 3167098, Created this function.
      ***************************************************************/
        l_n_cntr  NUMBER := 0;
      BEGIN

        IF l_predictive_progs_tbl.COUNT > 0 THEN
          FOR l_n_cntr IN l_predictive_progs_tbl.FIRST..l_predictive_progs_tbl.LAST LOOP
            IF l_predictive_progs_tbl.EXISTS(l_n_cntr) THEN

              IF ( (g_c_fee_calc_mthd = g_v_program AND l_predictive_progs_tbl(l_n_cntr).program_cd = p_v_course_cd)
                   OR
                   (g_c_fee_calc_mthd = g_v_career AND l_predictive_progs_tbl(l_n_cntr).career = p_v_career)
                   -- find_record_exists is not called for PRIMARY_CAREER case.
                 ) THEN
                log_to_fnd( p_v_module => 'find_record_exists',
                            p_v_string => 'Record found. Returning TRUE.' );
                RETURN TRUE;
              END IF;
            END IF;
          END LOOP;
        END IF;

        log_to_fnd( p_v_module => 'find_record_exists',
                    p_v_string => 'Record Not found. Returning FALSE.' );
        RETURN FALSE;

      END find_record_exists;

      FUNCTION validate_prog_att ( p_n_cntr IN NUMBER ) RETURN BOOLEAN IS
      /*************************************************************
       Created By :      Shirish Tatikonda
       Date Created By : 09-JAN-2003
       Purpose :         Function to check whether the current Program Attempt is liable for assessment.

       Know limitations, enhancements or remarks
       Change History
       Who             When          What
       shtatiko        09-JAN-2003   Enh# 3167098, Created this function.
      ***************************************************************/

        current_rec  prd_prog_details_rec_typ;
        l_d_adm_ld_start_dt igs_ca_inst_all.start_dt%TYPE;
        l_d_fee_ld_start_dt igs_ca_inst_all.start_dt%TYPE;
        l_d_crs_cmpl_dt     DATE;
        l_v_message_name    fnd_new_messages.message_name%TYPE;

        -- Cursor to get latest intermission end date.
        CURSOR c_latest_intermit_date ( cp_n_person_id  igs_en_stdnt_ps_intm.person_id%TYPE,
                                        cp_v_course_cd  igs_ps_ver_all.course_cd%TYPE,
                                        cp_logical_delete_date igs_en_stdnt_ps_intm.logical_delete_date%TYPE) IS
          SELECT sci.end_dt
          FROM igs_en_stdnt_ps_intm sci,
               IGS_EN_INTM_TYPES eit
          WHERE sci.person_id = cp_n_person_id
          AND sci.course_cd = cp_v_course_cd
          AND sci.logical_delete_date = cp_logical_delete_date
          AND sci.approved  = eit.appr_reqd_ind AND
          eit.intermission_type = sci.intermission_type
          ORDER BY end_dt DESC;
        l_d_int_end_dt  igs_en_stdnt_ps_intm.end_dt%TYPE;

        -- Cursor to get the admission offer response status and admission calendar instance details
        CURSOR c_adm_details ( cp_n_person_id                  igs_en_stdnt_ps_intm.person_id%TYPE,
                               cp_n_adm_admission_appl_number  igs_en_stdnt_ps_att_all.adm_admission_appl_number%TYPE,
                               cp_v_adm_nominated_course_cd    igs_en_stdnt_ps_att_all.adm_nominated_course_cd%TYPE,
                               cp_n_adm_sequence_number        igs_en_stdnt_ps_att_all.adm_sequence_number%TYPE ) IS
          SELECT off.s_adm_offer_resp_status,
                 app.adm_cal_type,
                 app.adm_ci_sequence_number
          FROM igs_ad_ps_appl_inst_all apl_in,
               igs_ad_ofr_resp_stat off,
               igs_ad_appl_all app
          WHERE apl_in.adm_offer_resp_status = off.adm_offer_resp_status
          AND apl_in.person_id = cp_n_person_id
          AND apl_in.nominated_course_cd = cp_v_adm_nominated_course_cd
          AND apl_in.sequence_number = cp_n_adm_sequence_number
          AND apl_in.admission_appl_number = cp_n_adm_admission_appl_number
          AND app.person_id = apl_in.person_id
          AND app.admission_appl_number = apl_in.admission_appl_number;
        rec_adm_details  c_adm_details%ROWTYPE;

        -- Cursor to Get the subordinate Load Calendar Instance for the derived Admission Calendar Instance
        CURSOR c_sub_adm_cal ( cp_v_adm_cal_type   igs_ca_inst_all.cal_type%TYPE,
                               cp_n_adm_ci_seq_num igs_ca_inst_all.sequence_number%TYPE,
                               cp_v_admission      igs_ca_type.s_cal_cat%TYPE,
                               cp_v_load           igs_ca_type.s_cal_cat%TYPE ) IS
          SELECT rl.sub_cal_type,
                 rl.sub_ci_sequence_number
          FROM igs_ca_inst_rel rl,
               igs_ca_type ct1,
               igs_ca_type ct2
          WHERE rl.sup_cal_type = ct1.cal_type
          AND ct1.s_cal_cat = cp_v_admission
          AND rl.sub_cal_type = ct2.cal_type
          AND ct2.s_cal_cat = cp_v_load
          AND rl.sup_cal_type = cp_v_adm_cal_type
          AND rl.sup_ci_sequence_number = cp_n_adm_ci_seq_num;
        rec_sub_adm_cal  c_sub_adm_cal%ROWTYPE;

        -- Cursor to get Start Date of Calendar Instance given
        CURSOR c_get_start_dt ( cp_v_cal_type   igs_ca_inst_all.cal_type%TYPE,
                                cp_n_ci_seq_num igs_ca_inst_all.sequence_number%TYPE ) IS
          SELECT start_dt
          FROM igs_ca_inst_all
          WHERE cal_type = cp_v_cal_type
          AND sequence_number = cp_n_ci_seq_num;

        l_v_adm_alt_code       igs_ca_inst_all.alternate_code%TYPE;
        l_v_adm_load_alt_code  igs_ca_inst_all.alternate_code%TYPE;


      BEGIN

        current_rec := l_predictive_progs_tbl(p_n_cntr);

        log_to_fnd( p_v_module => 'validate_prog_att',
                    p_v_string => 'Entered validate_prog_att. Program Attempt Status: ' || current_rec.crs_attempt_status );

        IF current_rec.crs_attempt_status = 'INTERMIT' THEN
          -- check if the intermission type is defined and if the latest intermission end date is less than the census date alias value.
          OPEN c_latest_intermit_date ( p_n_person_id,
                                        current_rec.program_cd,
                                        TO_DATE('31-12-4712','DD-MM-YYYY') );
          FETCH c_latest_intermit_date INTO l_d_int_end_dt;
          CLOSE c_latest_intermit_date;

          log_to_fnd( p_v_module => 'validate_prog_att',
                      p_v_string => 'Intermission End Date: ' || TO_CHAR(l_d_int_end_dt,'DD-MON-YYYY') ||
                                    ', Census Date Alias Value: ' || TO_CHAR(g_d_ld_census_val,'DD-MON-YYYY'));
          IF l_d_int_end_dt >= g_d_ld_census_val THEN
            RETURN FALSE;
          ELSE
            RETURN TRUE;
          END IF;

        ELSIF current_rec.crs_attempt_status IN ('INACTIVE', 'UNCONFIRM') THEN
          IF current_rec.source = 'T' THEN
            IF current_rec.crs_attempt_status = 'UNCONFIRM' THEN
              log_to_fnd( p_v_module => 'validate_prog_att',
                          p_v_string => 'Return True at Point 1.' );
              RETURN TRUE;
            ELSE
              NULL;
              -- Go to 'Program Completion Date validations' below
            END IF;
          ELSE
            IF current_rec.adm_admission_appl_number IS NULL
               OR current_rec.adm_nominated_course_cd IS NULL
               OR current_rec.adm_sequence_number IS NULL THEN
              IF current_rec.crs_attempt_status = 'UNCONFIRM' THEN
                IF p_v_trace_on = 'Y' THEN
                  fnd_message.set_name ( 'IGS', 'IGS_FI_PRED_NO_START_DATE');
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                END IF;
                log_to_fnd( p_v_module => 'validate_prog_att',
                            p_v_string => 'Return False with message: IGS_FI_PRED_NO_START_DATE' );
                RETURN FALSE;
              ELSE
                -- Note: Course Commencement Date is always avaliable for an INACTIVE program attempt.
                IF current_rec.crs_commence_dt > g_d_ld_census_val THEN
                  IF p_v_trace_on = 'Y' THEN
                    fnd_message.set_name('IGS', 'IGS_FI_PRED_STRTDT_EARLY_CNSDT');
                    fnd_message.set_token('ALT_CD', g_v_load_alt_code);
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  log_to_fnd( p_v_module => 'validate_prog_att',
                              p_v_string => 'Return False with message: IGS_FI_PRED_STRTDT_EARLY_CNSDT' );
                  RETURN FALSE;
                ELSE
                  NULL;
                  -- Go to 'Program Completion Date validations' below
                END IF;
              END IF;
            ELSE
              -- get the student admission application offer response status and the admission calendar instance.
              OPEN c_adm_details ( current_rec.person_id,
                                   current_rec.adm_admission_appl_number,
                                   current_rec.adm_nominated_course_cd,
                                   current_rec.adm_sequence_number );
              FETCH c_adm_details INTO rec_adm_details;
              CLOSE c_adm_details;
              log_to_fnd( p_v_module => 'validate_prog_att',
                          p_v_string => 'Admission Calendar Derived: '
                                        || rec_adm_details.adm_cal_type || ', '
                                        || rec_adm_details.adm_ci_sequence_number || ', '
                                        || rec_adm_details.s_adm_offer_resp_status );

              IF current_rec.crs_attempt_status = 'INACTIVE' THEN
                IF rec_adm_details.s_adm_offer_resp_status = 'ACCEPTED' THEN
                  NULL;
                  -- Go to 'Admission Calendar Instance Validation' below
                ELSE
                  IF p_v_trace_on = 'Y' THEN
                    fnd_message.set_name ( 'IGS', 'IGS_FI_PRED_STATUS_NO_ACCEPTED');
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  log_to_fnd( p_v_module => 'validate_prog_att',
                              p_v_string => 'Returning False with message: IGS_FI_PRED_STATUS_NO_ACCEPTED' );
                  RETURN FALSE;
                END IF; /* rec_adm_details.s_adm_offer_resp_status */
              ELSE
                IF rec_adm_details.s_adm_offer_resp_status = 'PENDING' THEN
                  NULL;
                  -- Go to 'Admission Calendar Instance Validation' below
                ELSE
                  IF p_v_trace_on = 'Y' THEN
                    fnd_message.set_name ( 'IGS', 'IGS_FI_PRED_STATUS_NOT_PENDING');
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  log_to_fnd( p_v_module => 'validate_prog_att',
                              p_v_string => 'Returning False with message: IGS_FI_PRED_STATUS_NOT_PENDING' );
                  RETURN FALSE;
                END IF;
              END IF;

              -- Admission Calendar Instance Validation
              -- Get the subordinate Load Calendar Instance for the derived Admission Calendar Instance
              OPEN c_sub_adm_cal ( rec_adm_details.adm_cal_type,
                                   rec_adm_details.adm_ci_sequence_number,
                                   'ADMISSION',
                                   'LOAD' );
              FETCH c_sub_adm_cal INTO rec_sub_adm_cal;
              CLOSE c_sub_adm_cal;
              log_to_fnd( p_v_module => 'validate_prog_att',
                          p_v_string => 'Sub Calendar of Admission Calendar Derived: '
                                        || rec_sub_adm_cal.sub_cal_type || ', '
                                        || rec_sub_adm_cal.sub_ci_sequence_number );

              -- Get the Alternate Code of Admission Calendar
              OPEN g_c_alternate_code ( rec_adm_details.adm_cal_type, rec_adm_details.adm_ci_sequence_number );
              FETCH g_c_alternate_code INTO l_v_adm_alt_code;
              CLOSE g_c_alternate_code;

              IF rec_sub_adm_cal.sub_cal_type IS NULL OR rec_sub_adm_cal.sub_ci_sequence_number IS NULL THEN
                IF p_v_trace_on = 'Y' THEN
                  fnd_message.set_name( 'IGS', 'IGS_FI_NO_ADM_LD_RELN_EXISTS' );
                  fnd_message.set_token('ADM_ALT_CD', l_v_adm_alt_code);
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                END IF;
                log_to_fnd( p_v_module => 'validate_prog_att',
                            p_v_string => 'Returning False with message: IGS_FI_NO_ADM_LD_RELN_EXISTS' );
                RETURN FALSE;
              END IF;

              IF current_rec.crs_attempt_status = 'INACTIVE' THEN
                -- Get Start Date of Admission Load Period derived above
                OPEN c_get_start_dt ( rec_sub_adm_cal.sub_cal_type,
                                      rec_sub_adm_cal.sub_ci_sequence_number );
                FETCH c_get_start_dt INTO l_d_adm_ld_start_dt;
                CLOSE c_get_start_dt;

                -- Get Start Date of Load Period of the Fee Calendar passed to process
                OPEN c_get_start_dt ( g_v_load_cal_type,
                                      g_n_load_seq_num );
                FETCH c_get_start_dt INTO l_d_fee_ld_start_dt;
                CLOSE c_get_start_dt;

                log_to_fnd( p_v_module => 'validate_prog_att',
                            p_v_string => 'Adm Load Period St Dt: ' || TO_CHAR(l_d_adm_ld_start_dt, 'DD-MON-YYYY')
                                          || ', Fee Load Period St Dt: ' || TO_CHAR(l_d_fee_ld_start_dt, 'DD-MON-YYYY'));
                IF l_d_fee_ld_start_dt < l_d_adm_ld_start_dt THEN
                  IF p_v_trace_on = 'Y' THEN
                    -- Get the Alternate Code of Load Calendar associated to Admission Calendar
                    OPEN g_c_alternate_code ( rec_sub_adm_cal.sub_cal_type,
                                              rec_sub_adm_cal.sub_ci_sequence_number );
                    FETCH g_c_alternate_code INTO l_v_adm_load_alt_code;
                    CLOSE g_c_alternate_code;

                    fnd_message.set_name( 'IGS', 'IGS_FI_PRED_FEE_LP_ERLY_ADM_LP' );
                    fnd_message.set_token('LC1_ALT_CD', l_v_adm_load_alt_code);
                    fnd_message.set_token('ALT_CD', l_v_adm_alt_code);
                    fnd_message.set_token('LC2_ALT_CD', g_v_load_alt_code);
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  log_to_fnd( p_v_module => 'validate_prog_att',
                              p_v_string => 'Returning False with message: IGS_FI_PRED_FEE_LP_ERLY_ADM_LP' );
                  RETURN FALSE;
                ELSE
                  NULL;
                  -- Go to 'Program Completion Date validations' below
                END IF;
              ELSE
                -- Check if Derived Load period of Admission Calendar is same as Load Period of Fee Calendar passed to process.
                IF g_v_load_cal_type <> rec_sub_adm_cal.sub_cal_type
                   OR g_n_load_seq_num <> rec_sub_adm_cal.sub_ci_sequence_number THEN
                  IF p_v_trace_on = 'Y' THEN
                    -- Get the Alternate Code of Load Calendar associated to Admission Calendar
                    OPEN g_c_alternate_code ( rec_sub_adm_cal.sub_cal_type,
                                              rec_sub_adm_cal.sub_ci_sequence_number );
                    FETCH g_c_alternate_code INTO l_v_adm_load_alt_code;
                    CLOSE g_c_alternate_code;

                    fnd_message.set_name( 'IGS', 'IGS_FI_PRED_LOAD_PRDS_NOTSAME' );
                    fnd_message.set_token('LC1_ALT_CD', l_v_adm_load_alt_code);
                    fnd_message.set_token('ALT_CD', l_v_adm_alt_code);
                    fnd_message.set_token('LC2_ALT_CD', g_v_load_alt_code);
                    fnd_file.put_line (fnd_file.log, fnd_message.get);
                  END IF;
                  log_to_fnd( p_v_module => 'validate_prog_att',
                              p_v_string => 'Returning False with message: IGS_FI_PRED_LOAD_PRDS_NOTSAME' );
                  RETURN FALSE;
                ELSE
                  log_to_fnd( p_v_module => 'validate_prog_att',
                              p_v_string => 'Returning True at Point 2.' );
                  RETURN TRUE;
                END IF;
              END IF;
            END IF; /* Check for nulls */
          END IF; /* current_rec.source */
        END IF; /* crs_attempt_status */

        -- Program Completion Date validations

        IF current_rec.crs_attempt_status IN ('ENROLLED', 'INACTIVE') THEN
          -- Call EN API to get Course Completion Date.
          l_d_crs_cmpl_dt := igs_en_gen_015.enrf_drv_cmpl_dt ( p_person_id => current_rec.person_id,
                                                               p_course_cd => current_rec.program_cd,
                                                               p_achieved_cp => NULL,
                                                               p_attendance_type => current_rec.att_type,
                                                               p_load_cal_type => NULL,
                                                               p_load_ci_seq_num => NULL,
                                                               p_load_ci_alt_code => NULL,
                                                               p_load_ci_start_dt => NULL,
                                                               p_load_ci_end_dt => NULL,
                                                               p_message_name => l_v_message_name );
          log_to_fnd( p_v_module => 'validate_prog_att',
                      p_v_string => 'Completion Date Derived: ' || TO_CHAR(l_d_crs_cmpl_dt,'DD-MON-YYYY') );
          IF l_d_crs_cmpl_dt IS NULL THEN
            log_to_fnd( p_v_module => 'validate_prog_att',
                        p_v_string => 'Returning True at Point 3.' );
            RETURN TRUE;
          ELSE
            -- Check if derived course completion date is less than Census Date Alias
            IF l_d_crs_cmpl_dt < g_d_ld_census_val THEN
              IF p_v_trace_on = 'Y' THEN
                fnd_message.set_name ( 'IGS', 'IGS_FI_CRS_END_DT_LT_CNS_DT');
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;
              log_to_fnd( p_v_module => 'validate_prog_att',
                          p_v_string => 'Returning False with message: IGS_FI_CRS_END_DT_LT_CNS_DT' );
              RETURN FALSE;
            ELSE
              log_to_fnd( p_v_module => 'validate_prog_att',
                          p_v_string => 'Returning True at Point 4.' );
              RETURN TRUE;
            END IF;
          END IF;
        END IF;

      END validate_prog_att;

    BEGIN

      log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                  p_v_string => 'Entered finpl_prc_predictive_scas. Parameters are: '
                                || 'Person Id: '        || p_n_person_id
                                || ', Course Cd: '        || p_v_course_cd
                                || ', Career: '           || p_v_career
                                || ', Fee Cat: '          || p_v_fee_category
                                || ', Fee Cal Type: '     || p_v_fee_cal_type
                                || ', Fee Cal Seq Num: '  || p_n_fee_ci_sequence_num
                                || ', Currency Cd: '      || p_v_curr_cd
                                || ', Effective Dt: '     || TO_CHAR(p_d_effective_date, 'DD-MON-YYYY')
                                || ', Trace On: '         || p_v_trace_on );

      -- If there any term records for the given term, then ALWAYS select Key Program from Terms table
      -- IRRESPECTIVE of whether this key program is selected in following cursor c_get_term_recs or not.
      --   If it finds this key program in c_get_term_recs, then INSTITUTION Fees is assessed for that program.
      --   If it doesn't, then no INSTITUTION Fees is assessed for the person.
      -- If Key Program is not there in Terms table, then check in SPA Table for Key Program.

      -- Check if Key Program Exists in Terms Table for the given term and for the person in context.
      -- g_c_key_program and g_n_key_version  are determined in finp_ins_enr_fee_ass
      IF g_c_key_program IS NOT NULL AND g_n_key_version IS NOT NULL THEN
        log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                    p_v_string => 'Key Program found in TERMS table.' );
        l_b_term_key_prg_found := TRUE;
      ELSE
        log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                    p_v_string => 'Key Program NOT found in TERMS table.' );
        l_b_term_key_prg_found := FALSE;
      END IF;

      ------------------------------------------------
      -- Identification of Assessable Program Attempts
      ------------------------------------------------

      log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                  p_v_string => 'Predictive: Finding Student Program Attempts from TERMS table.' );
      -- Get assessable Program Attempts from Terms Table.
      l_n_prd_progs_cntr := 0;
      FOR rec_term_prog_att IN c_get_term_recs ( p_n_person_id,
                                                 p_v_fee_category,
                                                 p_v_course_cd,
                                                 p_v_career,
                                                 'Y',
                                                 'INTERMIT','ENROLLED','INACTIVE','UNCONFIRM',
                                                 'C' )
      LOOP

        -- Add the current record to PL/SQL table, l_predictive_progs_tbl
        l_n_prd_progs_cntr := l_n_prd_progs_cntr + 1;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).person_id        := rec_term_prog_att.person_id;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).program_cd       := rec_term_prog_att.program_cd;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).program_version  := rec_term_prog_att.program_version;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).career           := rec_term_prog_att.course_type;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).fee_cat          := rec_term_prog_att.fee_cat;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).crs_cal_type     := rec_term_prog_att.cal_type;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).location_cd      := rec_term_prog_att.location_cd;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).att_mode         := rec_term_prog_att.attendance_mode;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).att_type         := rec_term_prog_att.attendance_type;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).key_program      := rec_term_prog_att.key_program_flag;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).crs_attempt_status := rec_term_prog_att.course_attempt_status;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).crs_commence_dt  := rec_term_prog_att.commencement_dt;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).disc_dt          := rec_term_prog_att.discontinued_dt;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).adm_admission_appl_number := NULL;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).adm_nominated_course_cd := NULL;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).adm_sequence_number := NULL;
        l_predictive_progs_tbl(l_n_prd_progs_cntr).source           := 'T'; -- From Terms Table.
        log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                    p_v_string => 'Added Record to PL/SQL table(' || l_n_prd_progs_cntr || '). Parameters are: '
                                  || 'Program Cd: '             || rec_term_prog_att.program_cd
                                  ||', Program Ver:'            || rec_term_prog_att.program_version
                                  ||', Career:'                 || rec_term_prog_att.course_type
                                  ||', Fee Cat:'                || rec_term_prog_att.fee_cat
                                  ||', Cal Type:'               || rec_term_prog_att.cal_type
                                  ||', Location Cd:'            || rec_term_prog_att.location_cd
                                  ||', Att Mode:'               || rec_term_prog_att.attendance_mode
                                  ||', Att Type:'               || rec_term_prog_att.attendance_type
                                  ||', Key Prog Flag:'          || rec_term_prog_att.key_program_flag
                                  ||', Crs_attempt_status:'     || rec_term_prog_att.course_attempt_status
                                  ||', crs_commence_dt:'        || TO_CHAR(rec_term_prog_att.commencement_dt, 'DD-MON-YYYY')
                                  ||', disc_dt:'                || TO_CHAR(rec_term_prog_att.discontinued_dt, 'DD-MON-YYYY'));
      END LOOP; /* Loop across Term Records. */

      -- Now determine Program Attempts from Student Program Attempts table.
      -- EXCEPT in case of PRIMARY_CAREER and Key program is found in terms table.
      IF NOT (g_c_fee_calc_mthd = g_v_primary_career AND
              l_b_term_key_prg_found = TRUE) THEN

        log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                    p_v_string => 'Predictive: Finding Student Program Attempts from SPA table.' );
        FOR rec_scas IN c_get_scas_recs ( p_n_person_id,
                                          p_v_fee_category,
                                          p_v_course_cd,
                                          p_v_career,
                                          'PRIMARY',
                                          'Y',
                                          'INTERMIT','ENROLLED','INACTIVE','UNCONFIRM',
                                          'C' )
        LOOP
          l_b_rec_found_at_terms := FALSE;

          -- Check whether this record exists already. Check it only if its not PRIMARY_CAREER.
          -- If its PRIMARY_CAREER, then only record we get is Key Program, which we have to add it.
          IF g_c_fee_calc_mthd <> g_v_primary_career THEN
            log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                        p_v_string => 'Find whether record already exists in PL/SQL table by calling find_record_exists: '
                                      || rec_scas.course_cd || ', ' || rec_scas.course_type );
            l_b_rec_found_at_terms := find_record_exists ( p_v_course_cd => rec_scas.course_cd,
                                                           p_v_career    => rec_scas.course_type );
          END IF;

          -- If the record is not already existing in table, then add this record to table.
          IF NOT l_b_rec_found_at_terms THEN
            l_n_prd_progs_cntr := l_n_prd_progs_cntr + 1;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).person_id := rec_scas.person_id;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).program_cd := rec_scas.course_cd;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).program_version := rec_scas.version_number;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).career := rec_scas.course_type;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).fee_cat := rec_scas.fee_cat;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).crs_cal_type := rec_scas.cal_type;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).location_cd := rec_scas.location_cd;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).att_mode := rec_scas.attendance_mode;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).att_type := rec_scas.attendance_type;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).key_program := rec_scas.key_program;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).crs_attempt_status := rec_scas.course_attempt_status;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).crs_commence_dt := rec_scas.commencement_dt;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).disc_dt := rec_scas.discontinued_dt;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).adm_admission_appl_number := rec_scas.adm_admission_appl_number;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).adm_nominated_course_cd := rec_scas.adm_nominated_course_cd;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).adm_sequence_number := rec_scas.adm_sequence_number;
            l_predictive_progs_tbl(l_n_prd_progs_cntr).source := 'S'; -- From SPA Table.
            log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                        p_v_string => 'Added Record to PL/SQL table(' || l_n_prd_progs_cntr || '). Parameters are: '
                                  || 'Program Cd: '             || rec_scas.course_cd
                                  ||', Program Ver:'            || rec_scas.version_number
                                  ||', Career:'                 || rec_scas.course_type
                                  ||', Fee Cat:'                || rec_scas.fee_cat
                                  ||', Cal Type:'               || rec_scas.cal_type
                                  ||', Location Cd:'            || rec_scas.location_cd
                                  ||', Att Mode:'               || rec_scas.attendance_mode
                                  ||', Att Type:'               || rec_scas.attendance_type
                                  ||', Key Prog Flag:'          || rec_scas.key_program
                                  ||', Crs_attempt_status:'     || rec_scas.course_attempt_status
                                  ||', crs_commence_dt:'        || TO_CHAR(rec_scas.commencement_dt, 'DD-MON-YYYY')
                                  ||', disc_dt:'                || TO_CHAR(rec_scas.discontinued_dt, 'DD-MON-YYYY')
                                  ||', Adm Appl Num: '          || rec_scas.adm_admission_appl_number
                                  ||', Adm Nom Crs Cd: '        || rec_scas.adm_nominated_course_cd
                                  ||', Adm Seq Num: '           || rec_scas.adm_sequence_number );

          END IF; /* NOT l_b_rec_found_at_terms */
        END LOOP;
      END IF; /* NOT (PRIMARY_CAREER and Key Prog Found) */

      -------------------------------------------------
      -- Call finpl_prc_fee_cat_fee_liab for assessment
      -------------------------------------------------

      IF l_predictive_progs_tbl.COUNT > 0 THEN
        log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                    p_v_string => 'There are records in PL/SQL Table. Process each Program Att found.');
        fnd_file.new_line(fnd_file.log);
        FOR l_n_cntr IN l_predictive_progs_tbl.FIRST..l_predictive_progs_tbl.LAST LOOP
          IF l_predictive_progs_tbl.EXISTS(l_n_cntr) THEN

            IF (p_trace_on = 'Y') THEN
              fnd_message.set_name ( 'IGS', 'IGS_FI_MAJOR_PRGLOC_USED');
              fnd_message.set_token('PROG', l_predictive_progs_tbl(l_n_cntr).program_cd);
              fnd_message.set_token('VER', TO_CHAR(l_predictive_progs_tbl(l_n_cntr).program_version));
              fnd_file.put_line (fnd_file.log, fnd_message.get);
              fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'STATUS') || ': ' || l_predictive_progs_tbl(l_n_cntr).crs_attempt_status);
              fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'START_DT') || ': ' || TO_CHAR(l_predictive_progs_tbl(l_n_cntr).crs_commence_dt, 'DD/MM/YYYY'));
              fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_CAT') || ': ' || l_predictive_progs_tbl(l_n_cntr).fee_cat);
              fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'LOC') || ': ' || l_predictive_progs_tbl(l_n_cntr).location_cd);
              fnd_message.set_name ( 'IGS', 'IGS_FI_DER_ATT_TYPE_GOVT_MODE');
              fnd_message.set_token('ATT_MODE', l_predictive_progs_tbl(l_n_cntr).att_mode);
              fnd_file.put_line (fnd_file.log, fnd_message.get);
              fnd_message.set_name ( 'IGS', 'IGS_FI_ATTTYPE_GOVT_ATTMODE');
              fnd_message.set_token('ATT_TYPE', l_predictive_progs_tbl(l_n_cntr).att_type);
              fnd_file.put_line (fnd_file.log, fnd_message.get);
              fnd_message.set_name ( 'IGS', 'IGS_FI_NO_KEY_PROGRAM');
              fnd_message.set_token('YES_NO', l_predictive_progs_tbl(l_n_cntr).key_program);
            END IF;

            log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                        p_v_string => 'Calling validate_prog_att for record ' || l_n_cntr);
            l_b_prog_att_liable := validate_prog_att ( p_n_cntr => l_n_cntr);

            IF l_b_prog_att_liable = TRUE THEN
              log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                          p_v_string => 'Check if Institution Fee can be assessed.');
              -- Check if Institution Fee is to be assessed or not.
              -- Note: In Predictive Mode, Institution Fees is assessed ONLY for a Key Program.
              IF l_predictive_progs_tbl(l_n_cntr).source = 'T' THEN
                IF l_predictive_progs_tbl(l_n_cntr).key_program = 'Y' THEN
                  g_b_prc_inst_fee := TRUE;
                ELSE
                  g_b_prc_inst_fee := FALSE;
                END IF;
              ELSE
                IF l_predictive_progs_tbl(l_n_cntr).key_program = 'Y' THEN
                  IF l_b_term_key_prg_found THEN
                    g_b_prc_inst_fee := FALSE;
                  ELSE
                    g_b_prc_inst_fee := TRUE;
                  END IF;
                ELSE
                  g_b_prc_inst_fee := FALSE;
                END IF;
              END IF;

              IF g_b_prc_inst_fee THEN
                log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                            p_v_string => 'Institution Fee is assessed for this Program Attempt.');
              ELSE
                log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                            p_v_string => 'Institution Fee is NOT assessed for this Program Attempt.');
              END IF;

              -- If Fee Category is not specified for the SPA, error out.
              IF l_predictive_progs_tbl(l_n_cntr).fee_cat IS NULL THEN
                 log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                             p_v_string => 'Predictive: Fee Category at SPA level is Null, so log message and abort.');
                 fnd_message.set_name ( 'IGS', 'IGS_FI_NO_SPA_FEE_CAT');
                 fnd_message.set_token('PROG_ATT', l_predictive_progs_tbl(l_n_cntr).program_cd);
                 fnd_file.new_line(fnd_file.log);
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
                 p_b_return_status := FALSE;
                 p_b_record_found := TRUE;
                 RETURN;
              END IF;

              -- Check if currency code that is attached at the Fee Category Level is same
              -- as the currency code that is set at the System Options Level.
              OPEN c_fee_cat_curr(l_predictive_progs_tbl(l_n_cntr).fee_cat);
              FETCH c_fee_cat_curr INTO rec_cur_fee_cat_curr;
              CLOSE c_fee_cat_curr;

              IF (rec_cur_fee_cat_curr.currency_cd <> p_v_curr_cd
                  OR rec_cur_fee_cat_curr.currency_cd IS NULL
                 ) THEN
                IF (p_trace_on = 'Y') THEN
                  fnd_message.set_name ( 'IGS', 'IGS_FI_INVALID_CURR_CODE');
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                  fnd_message.set_name('IGS', 'IGS_FI_INV_FEE_CAT_CURR_CODE');
                  fnd_message.set_token('CUR_CODE1', rec_cur_fee_cat_curr.currency_cd );
                  fnd_message.set_token('FEE_CAT', RTRIM(l_predictive_progs_tbl(l_n_cntr).fee_cat) );
                  fnd_message.set_token('CUR_CODE2', p_v_curr_cd );
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                END IF;
                log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                            p_v_string => 'Currency at Sys Opt Level('|| p_v_curr_cd || ') and Fee Cat level('
                                          || rec_cur_fee_cat_curr.currency_cd ||') are not same. Proceed with next Program Att.');
              ELSE

                IF (p_trace_on = 'Y') THEN
                  fnd_file.new_line(fnd_file.log);
                  fnd_message.set_name ( 'IGS', 'IGS_FI_PREDICTIVE_FEEASS_SPA');
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                END IF;

                     log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                                 p_v_string => 'Calling finpl_prc_fee_cat_fee_liab for Predictive Assessment.');

                     IF (finpl_prc_fee_cat_fee_liab (
                            p_d_effective_date,
                            p_v_trace_on,
                            p_v_fee_cal_type,
                            p_n_fee_ci_sequence_num,
                            p_v_curr_cd,
                            l_predictive_progs_tbl(l_n_cntr).fee_cat,
                            l_predictive_progs_tbl(l_n_cntr).person_id,
                            l_predictive_progs_tbl(l_n_cntr).program_cd,
                            l_predictive_progs_tbl(l_n_cntr).program_version,
                            l_predictive_progs_tbl(l_n_cntr).crs_cal_type,
                            l_predictive_progs_tbl(l_n_cntr).location_cd,
                            l_predictive_progs_tbl(l_n_cntr).att_mode,
                            l_predictive_progs_tbl(l_n_cntr).att_type,
                            l_predictive_progs_tbl(l_n_cntr).disc_dt,
                            l_predictive_progs_tbl(l_n_cntr).crs_attempt_status,
                            p_v_message_name,
                            'PREDICTIVE',
                            l_predictive_progs_tbl(l_n_cntr).career,
                            p_waiver_call_ind,
                            p_target_fee_type
                            ) = FALSE
                        ) THEN
                            p_b_return_status := FALSE;
                            p_b_record_found := TRUE;
                            log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                                        p_v_string => 'finpl_prc_fee_cat_fee_liab returned FALSE. Returning from finpl_prc_predictive_scas as Failure.');
                            RETURN;
                     END IF;
              END IF; /* Check for Fee Category */
            ELSE
              log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                          p_v_string => 'Program Attempt is not Liable for Assessing. Proceed with next Program Attempt..');
            END IF; /* l_b_prog_att_liable */
          END IF;
        END LOOP;
      END IF;

      IF l_predictive_progs_tbl.COUNT > 0 THEN
        log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                    p_v_string => 'There are records and processed successfully. So returning as Success.');
        p_b_return_status := TRUE;
        p_b_record_found := TRUE;
        p_v_message_name := NULL;
      ELSE
        log_to_fnd( p_v_module => 'finpl_prc_predictive_scas',
                    p_v_string => 'There are no records found. So returning as Success.');
        p_b_return_status := TRUE;
        p_b_record_found := FALSE;
        p_v_message_name := NULL;
      END IF;

    END finpl_prc_predictive_scas;


    BEGIN       -- FINP_INS_ENR_FEE_ASS main
        -- Set the rollback segment. This is the biggest rollback segment.
        -- initialise PL/SQL tables

        -- The savepoint needs to be set only if Fee Calc is not invoked from the Waiver processing logic.
        IF p_v_wav_calc_flag = 'N' THEN
           SAVEPOINT fee_calc_sp;
        END IF;

        -- Set the global variable with the procedure parameter, p_v_wav_calc_flag
        g_v_wav_calc_flag := p_v_wav_calc_flag;

        log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                    p_v_string => 'Entered finp_ins_enr_fee_ass. Parameters are: '
                                  || 'Effective Date: ' || TO_CHAR(p_effective_dt, 'DD-MON-YYYY HH24:MI:SS')
                                  || ', Person Id: '    || p_person_id
                                  || ', Course Cd: '    || p_course_cd
                                  || ', Fee Category: ' || p_fee_category
                                  || ', Fee Cal Type: ' || p_fee_cal_type
                                  || ', Fee Cal Seq Num: ' || p_fee_ci_sequence_num
                                  || ', Fee Type: '     || p_fee_type
                                  || ', Trace On: '     || p_trace_on
                                  || ', Test Run: '     || p_test_run
                                  || ', Process Mode: ' || p_process_mode
                                  || ', Career: '       || p_c_career
                                  || ', GL Date: '      || TO_CHAR(p_d_gl_date, 'DD-MON-YYYY') );

        l_inst_fee_rec := l_inst_fee_rec_dummy;
        g_inst_fee_rec_cntr := 0;

        IF (p_trace_on = 'Y') THEN
           fnd_file.new_line(fnd_file.log);
        END IF;

        -- Check calling parameters
        IF (p_effective_dt IS NULL OR
                        p_trace_on IS NULL OR
                        p_test_run IS NULL) THEN
                p_message_name := Null;
                RETURN TRUE;
        END IF;

        /* Select the fee calculation method and program change date alias,
           error out NOCOPY when there is no fee calculation method setup */
        OPEN  c_fi_control;
        FETCH c_fi_control INTO l_c_fi_control;
        IF c_fi_control%FOUND THEN
          /* Check if Fee Calculation Method is defined, error out NOCOPY if not defined */
          l_c_control_curr := l_c_fi_control.currency_cd;
          IF (l_c_fi_control.fee_calc_mthd_code IS NOT NULL) THEN
            g_c_fee_calc_mthd := l_c_fi_control.fee_calc_mthd_code;
            g_v_currency_cd := l_c_fi_control.currency_cd;
            log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                        p_v_string => 'Fee Calculation Method: ' || g_c_fee_calc_mthd );

            log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                        p_v_string => 'Currency Code: ' || g_v_currency_cd );
          ELSE
            CLOSE c_fi_control;
            IF (p_trace_on = 'Y') THEN
              /* Could not determine Fee calculation method */
              fnd_message.set_name ( 'IGS', 'IGS_FI_FEE_CALC_MTHD_NOT_SET');
              fnd_file.put_line (fnd_file.log, fnd_message.get);
            END IF;
            p_message_name := 'IGS_FI_FEE_CALC_MTHD_NOT_SET';
            log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                        p_v_string => 'Returning from finp_ins_enr_fee_ass with message ' || p_message_name );
            RETURN FALSE;
          END IF;
        ELSE
          CLOSE c_fi_control;
          IF (p_trace_on = 'Y') THEN
            fnd_message.set_name ( 'IGS', 'IGS_FI_FEE_CALC_MTHD_NOT_SET');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          p_message_name := 'IGS_FI_FEE_CALC_MTHD_NOT_SET';
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Returning from finp_ins_enr_fee_ass with message ' || p_message_name || '.');
          -- Could not determine Fee calculation method
          RETURN FALSE;
        END IF;
        CLOSE c_fi_control;

        -- p_c_career should have value only when Fee Calc Method is CAREER.
        IF ( g_c_fee_calc_mthd = g_v_career) THEN
          IF ( p_c_career IS NOT NULL) THEN
            -- Validate whether p_c_career is a valid program type.
            OPEN c_course_type;
            FETCH c_course_type INTO l_c_temp;
            IF (c_course_type%NOTFOUND) THEN
              CLOSE c_course_type;
              IF (p_trace_on = 'Y') THEN
                fnd_message.set_name ( 'IGS', 'IGS_GE_INVALID_VALUE');
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;
              p_message_name := 'IGS_GE_INVALID_VALUE';
              log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                          p_v_string => 'Returning from finp_ins_enr_fee_ass: Invalid Course Type.' );
              RETURN FALSE;
            -- Log an error message since it course type is not a valid course type
            END IF;
          END IF;
        ELSE
          IF ( p_c_career IS NOT NULL) THEN
             IF (p_trace_on = 'Y') THEN
                fnd_message.set_name ( 'IGS', 'IGS_GE_INVALID_VALUE');
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;
              p_message_name := 'IGS_GE_INVALID_VALUE';
              log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                          p_v_string => 'Returning from finp_ins_enr_fee_ass: Course Type passed when not CAREER.' );
              RETURN FALSE;
          END IF;
        END IF;

        g_v_person_number := igs_fi_gen_008.get_party_number(p_person_id);

        -- Check for existence of incomplete Primary Program Transfers. If there are any, Fee Assessment cannot be carried out.
        -- This check needs to be done only in ACTUAL mode.
        IF g_c_fee_calc_mthd IN (g_v_career, g_v_primary_career)
           AND p_process_mode <> 'PREDICTIVE' THEN
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Checking for Incomplete Primary Program Transfer.' );
          OPEN c_sua_for_sec( p_person_id,
                              'SECONDARY',
                              'ENROLLED' );
          FETCH c_sua_for_sec INTO rec_sua_for_sec;
          IF c_sua_for_sec%FOUND THEN   /* Incomplete transfers found */
            -- If this is called from Concurrent Manager
            IF fnd_global.conc_request_id <> -1 THEN
              IF (p_trace_on = 'Y') THEN
                fnd_message.set_name('IGS', 'IGS_FI_PERSON_NUM');
                fnd_message.set_token('PERSON_NUM', g_v_person_number);
                fnd_file.put_line (fnd_file.log, fnd_message.get);

                fnd_message.set_name('IGS', 'IGS_FI_INC_PRG_TRANSFER');
                fnd_message.set_token('PERSON_NUM', g_v_person_number);
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;
              p_message_name := 'IGS_FI_INC_PRG_TRANSFER';
              fnd_message.set_name('IGS', 'IGS_FI_INC_PRG_TRANSFER');
              igs_ge_msg_stack.ADD;
              log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                          p_v_string => 'Returning from finp_ins_enr_fee_ass with message ' || p_message_name );
              -- Return TRUE so that the message is shown in Report and continues with next person, if any.
              RETURN TRUE;
            ELSE
              -- This is called from Self-Service Package. Return FALSE so that this message is shown on page.
              p_message_name := 'IGS_FI_SS_SP_NOT_ASSESSED';
              log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                          p_v_string => 'SS: Returning from finp_ins_enr_fee_ass with message ' || p_message_name );
              RETURN FALSE;
            END IF;
          END IF;
        END IF;

        -- Validating Course Code and Fee Calc Method
        -- Course Cd (p_course_cd) parameter is allowed only incase the fee calculation method is PROGRAM and the process should be errored out NOCOPY
        -- other fee calculation methods.
        IF ( p_course_cd IS NOT NULL AND g_c_fee_calc_mthd <> g_v_program) THEN
          IF (p_trace_on = 'Y') THEN
            fnd_message.set_name ( 'IGS', 'IGS_GE_INVALID_VALUE');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          p_message_name := 'IGS_GE_INVALID_VALUE';
          RETURN FALSE;
        END IF;

        -- Set Flag to determine if the current assessment mode is Predictive
        IF (p_process_mode = 'PREDICTIVE' ) THEN
          g_c_predictive_ind := 'Y';
        ELSE
          g_c_predictive_ind := 'N';
        END IF;

        -- Derive Load Period for the passed Fee Period.
        l_b_fci_lci := igs_fi_gen_001.finp_get_lfci_reln( p_fee_cal_type,
                                                          p_fee_ci_sequence_num,
                                                          'FEE',
                                                          g_v_load_cal_type,
                                                          g_n_load_seq_num,
                                                          v_message_name);
        IF NOT l_b_fci_lci THEN
          IF (p_trace_on = 'Y') THEN
            fnd_message.set_name ( 'IGS', v_message_name);
            fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          p_message_name := v_message_name;
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Error in finp_get_lfci_reln. Returning from finp_ins_enr_fee_ass with message ' || p_message_name );
          RETURN FALSE;
        END IF;
        OPEN g_c_alternate_code ( g_v_load_cal_type, g_n_load_seq_num );
        FETCH g_c_alternate_code INTO g_v_load_alt_code;
        CLOSE g_c_alternate_code;

        OPEN g_c_alternate_code ( p_fee_cal_type, p_fee_ci_sequence_num );
        FETCH g_c_alternate_code INTO g_v_fee_alt_code;
        CLOSE g_c_alternate_code;

        log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                    p_v_string => 'Load Period: ' || g_v_load_cal_type || ', ' || g_n_load_seq_num );



        -- Note: There will always be a key program, if there are any records for this term.
        g_c_key_program := NULL;
        g_n_key_version := NULL;
        OPEN c_key_program ( p_person_id,
                             g_v_load_cal_type,
                             g_n_load_seq_num,
                             'Y' );
        FETCH c_key_program INTO g_c_key_program, g_n_key_version;
        CLOSE c_key_program;
        log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                    p_v_string => 'Key Program Derived: ' || g_c_key_program || ', ' || g_n_key_version );

        -- If fee category is provided, Check if there exists any Active FCCIs as on Process Effective Date.
        IF (p_fee_category IS NOT NULL) THEN
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Checking if there exists any Active FCCIs as on Process Effective Date.' );
          OPEN c_fcci_fss(p_effective_dt);
          FETCH c_fcci_fss INTO v_fee_cat;
          IF (c_fcci_fss%NOTFOUND) THEN
            CLOSE   c_fcci_fss;
            v_message_name := 'IGS_FI_FEECAT_NOACTIVE_FEEASS';
            IF (p_trace_on = 'Y') THEN
              fnd_message.set_name ( 'IGS', v_message_name);
              fnd_file.put_line (fnd_file.log, fnd_message.get);
            END IF;
            -- call proc to save traces
            p_message_name := v_message_name;
            log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                        p_v_string => 'Returning from finp_ins_enr_fee_ass with message ' || p_message_name );
            RETURN TRUE;
          END IF;
          CLOSE   c_fcci_fss;
        END IF;

        -- Obtain the value of the profile 'IGS: Charge tuition for Audited Student Attempt'
        -- If this is not defined, then log error message
        g_v_include_audit := fnd_profile.value('IGS_FI_CHARGE_AUDIT_FEES');
        IF g_v_include_audit IS NULL THEN
          v_message_name := 'IGS_FI_SP_FEE_NO_PROFILE';
          IF (p_trace_on = 'Y') THEN
            fnd_message.set_name ( 'IGS', v_message_name);
            fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          -- call proc to save traces
          p_message_name := v_message_name;
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Returning from finp_ins_enr_fee_ass with message ' || p_message_name );
          RETURN FALSE;
        ELSE
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Value of Profile IGS_FI_SP_FEE_NO_PROFILE: ' || g_v_include_audit );
        END IF;

        -- Check if Census Date Alias setup is complete. If Yes, derive it into g_d_ld_census_val
        log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                    p_v_string => 'Checking Census date setup by calling check_census_dt_setup.' );
        check_census_dt_setup ( p_v_predictive_mode => g_c_predictive_ind,
                                p_v_load_cal_type   => g_v_load_cal_type,
                                p_n_load_ci_seq_number => g_n_load_seq_num,
                                p_d_cns_dt_als_val  => g_d_ld_census_val,
                                p_b_return_status   => l_b_return_status,
                                p_v_message_name    => l_v_message_name );
        log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                    p_v_string => 'After check_census_dt_setup, Derived Census Date: ' || TO_CHAR(g_d_ld_census_val, 'DD-MON-YYYY') );
        IF l_b_return_status = FALSE THEN
          p_message_name := l_v_message_name;
          IF (p_trace_on = 'Y' AND l_v_message_name IS NOT NULL ) THEN
            fnd_message.set_name( 'IGS', l_v_message_name );
            IF l_v_message_name = 'IGS_FI_NO_CENSUS_DT_SETUP' THEN
              fnd_message.set_token('ALT_CD', g_v_load_alt_code );
            END IF;
            fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Error in check_census_dt_setup: ' || l_v_message_name );
          RETURN FALSE;
        END IF;

        -- Fee Calc Method: PROGRAM
        --                    -- Identify All Valid Program Attempts from Terms table.
        --                  CAREER
        --                    -- All Primary Programs. (Note: Terms table will have only Primary Programs when CAREER)
        --                  PRIMARY_CAREER
        --                    -- Only Key Program is identified for Assessment.

          v_record_found := FALSE;

            IF (p_trace_on = 'Y') THEN
               fnd_file.new_line(fnd_file.log);
               OPEN cur_person_name(p_person_id);
               FETCH cur_person_name INTO l_v_person_name;
               CLOSE cur_person_name;
               fnd_file.put_line( fnd_file.log, RPAD('-', '79', '-') );
               fnd_message.set_name('IGS', 'IGS_FI_PERSON_NUM');
               fnd_message.set_token('PERSON_NUM', g_v_person_number);
               fnd_file.put_line (fnd_file.log, fnd_message.get);
               fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS', 'PERSON_NAME') || ': ' || l_v_person_name);
            END IF;

            tbl_wav_fcfl.DELETE;

          -- ACTUAL Mode processing.
          IF g_c_predictive_ind = 'N' THEN

            log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                        p_v_string => 'ACTUAL Mode: Looping Across Student Program Attempts from TERMS Table.' );
            -- Loop accross all programs for the student in context and for the given term period.
            FOR rec_scas IN c_scas ( p_person_id,
                                     g_v_load_cal_type,
                                     g_n_load_seq_num,
                                     p_course_cd,
                                     p_fee_category,
                                     p_c_career,
                                     'Y',
                                     'CRS_ATTEMPT_STATUS',
                                     'Y' ) LOOP
              v_record_found := TRUE;
              l_fee_category := rec_scas.fee_cat;

              -- If Fee Category is not specified for the SPA, error out.
              IF l_fee_category IS NULL THEN
                 log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                             p_v_string => 'Fee Category at SPA level (rec_scas.fee_cat) is Null, so log message and abort.');
                 fnd_message.set_name ( 'IGS', 'IGS_FI_NO_SPA_FEE_CAT');
                 fnd_message.set_token('PROG_ATT', rec_scas.program_cd);
                 --Bug 4735807,If this is called from Concurrent Manager
                 IF fnd_global.conc_request_id <> -1 THEN
                   fnd_file.new_line(fnd_file.log);
                   fnd_file.put_line(fnd_file.log,fnd_message.get);
                 ELSE
                   -- This is called from Self-Service Package. Return FALSE so that this message is shown on page.
                   p_message_name := 'IGS_FI_NO_SPA_FEE_CAT';
                   igs_ge_msg_stack.ADD;
                 END IF;
                 RETURN FALSE;
              END IF;

              IF (p_trace_on = 'Y') THEN
                fnd_file.new_line(fnd_file.log);
                fnd_message.set_name ( 'IGS', 'IGS_FI_MAJOR_PRGLOC_USED');
                fnd_message.set_token('PROG', rec_scas.program_cd);
                fnd_message.set_token('VER', TO_CHAR(rec_scas.program_version));
                fnd_file.put_line (fnd_file.log, fnd_message.get);
                fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'TITLE') || ': ' || rec_scas.short_title);
                fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'STATUS') || ': ' || igs_fi_gen_gl.get_lkp_meaning('VS_EN_COURSE_ATMPT_STATUS', rec_scas.course_attempt_status));
                fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'START_DT') || ': ' || TO_CHAR(rec_scas.commencement_dt, 'DD/MM/YYYY'));
                fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_CAT') || ': ' || l_fee_category);
                fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'LOC') || ': ' || rec_scas.location_cd);
                fnd_message.set_name ( 'IGS', 'IGS_FI_DER_ATT_TYPE_GOVT_MODE');
                fnd_message.set_token('ATT_MODE', rec_scas.attendance_mode);
                fnd_file.put_line (fnd_file.log, fnd_message.get);
                fnd_message.set_name ( 'IGS', 'IGS_FI_ATTTYPE_GOVT_ATTMODE');
                fnd_message.set_token('ATT_TYPE', rec_scas.attendance_type);
                fnd_file.put_line (fnd_file.log, fnd_message.get);
                fnd_message.set_name ( 'IGS', 'IGS_FI_NO_KEY_PROGRAM');
                fnd_message.set_token('YES_NO', rec_scas.key_program_flag);
                fnd_file.put_line (fnd_file.log, fnd_message.get);
              END IF;

              -- Process Fee Category Fee Liabilities

              -- GL Interface Build, check if currency code that is attached at the Fee Category Level is same
              -- as the currency code that is set at the System Options Level. If not, proceed with next Program Attempt.
              OPEN cur_fee_cat_curr(l_fee_category);
              FETCH cur_fee_cat_curr INTO l_cur_fee_cat_curr;
              CLOSE cur_fee_cat_curr;

              IF (l_cur_fee_cat_curr.currency_cd <> l_c_control_curr OR l_cur_fee_cat_curr.currency_cd IS NULL)  THEN
                IF (p_trace_on = 'Y') THEN
                  fnd_file.new_line(fnd_file.log);
                  fnd_message.set_name ( 'IGS', 'IGS_FI_INVALID_CURR_CODE');
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                  fnd_message.set_name('IGS', 'IGS_FI_INV_FEE_CAT_CURR_CODE');
                  fnd_message.set_token('CUR_CODE1', l_cur_fee_cat_curr.currency_cd );
                  fnd_message.set_token('FEE_CAT', RTRIM(l_fee_category) );
                  fnd_message.set_token('CUR_CODE2', l_c_control_curr );
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                  log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                              p_v_string => 'Currency at Fee Cat is Invalid. Sys Opt Level: ' || l_c_control_curr || ', Fee Cat Level: ' || l_cur_fee_cat_curr.currency_cd );
                END IF;
              ELSE
                       log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                   p_v_string => 'Calling finpl_prc_fee_cat_fee_liab' );

                       IF (finpl_prc_fee_cat_fee_liab(p_effective_dt          => p_effective_dt,
                                                      p_trace_on              => p_trace_on,
                                                      p_fee_cal_type          => p_fee_cal_type,
                                                      p_fee_ci_sequence_num   => p_fee_ci_sequence_num,
                                                      p_local_currency        => l_c_control_curr,
                                                      p_fee_cat               => l_fee_category,
                                                      p_person_id             => rec_scas.person_id,
                                                      p_course_cd             => rec_scas.program_cd,
                                                      p_course_version_number => rec_scas.program_version,
                                                      p_cal_type              => rec_scas.cal_type,
                                                      p_scahv_location_cd     => rec_scas.location_cd,
                                                      p_scahv_attendance_mode => rec_scas.attendance_mode,
                                                      p_scahv_attendance_type => rec_scas.attendance_type,
                                                      p_discontinued_dt       => rec_scas.discontinued_dt,
                                                      p_course_attempt_status => rec_scas.course_attempt_status,
                                                      p_message_name          => p_message_name,
                                                      p_process_mode          => p_process_mode,
                                                      p_c_career              => rec_scas.course_type,
                                                      p_waiver_call_ind       => 'N',
                                                      p_target_fee_type       => NULL) = FALSE ) THEN
                             log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                         p_v_string => 'finpl_prc_fee_cat_fee_liab returned FALSE. Returning from finp_ins_enr_fee_ass.' );
                             RETURN FALSE;
                       END IF;

              END IF; /* Check for Fee Category */
            END LOOP; /* c_scas, Loop across programs */

            IF p_v_wav_calc_flag = 'N' THEN
               IF (p_fee_category IS NOT NULL OR  p_course_cd IS NOT NULL OR p_c_career IS NOT NULL) THEN
                 FOR i IN 1..tbl_wav_fcfl.COUNT
                 LOOP
                   IF tbl_wav_fcfl.EXISTS(i) THEN
                       FOR rec_spa IN cur_spa ( p_person_id,
                                            g_v_load_cal_type,
                                            g_n_load_seq_num,
                                            'Y',
                                            p_c_career,
                                            'CRS_ATTEMPT_STATUS',
                                            'Y',
                                            tbl_wav_fcfl(i).p_fee_category )
                       LOOP
                          -- If Fee Category is not specified for the SPA, error out.
                          IF rec_spa.fee_cat IS NULL THEN
                              log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                          p_v_string => 'Waiver Processing: Fee Category at SPA level is Null, so log message and abort.');
                              fnd_message.set_name ( 'IGS', 'IGS_FI_NO_SPA_FEE_CAT');
                              fnd_message.set_token('PROG_ATT', rec_spa.program_cd);
                              fnd_file.new_line(fnd_file.log);
                              fnd_file.put_line(fnd_file.log,fnd_message.get);
                              RETURN FALSE;
                          END IF;

                         IF NOT((p_fee_category IS NOT NULL AND p_fee_category = rec_spa.fee_cat)
                             OR (p_course_cd IS NOT NULL AND p_course_cd = rec_spa.program_cd)
                             OR (p_c_career IS NOT NULL AND p_c_career = rec_spa.course_type)) THEN
                             -- Log the Program Details
                             IF (p_trace_on = 'Y') THEN
                               fnd_file.new_line(fnd_file.log);
                               fnd_message.set_name ( 'IGS', 'IGS_FI_MAJOR_PRGLOC_USED');
                               fnd_message.set_token('PROG', rec_spa.program_cd);
                               fnd_message.set_token('VER', TO_CHAR(rec_spa.program_version));
                               fnd_file.put_line (fnd_file.log, fnd_message.get);
                               fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'TITLE') || ': ' || rec_spa.short_title);
                               fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'STATUS') || ': ' || igs_fi_gen_gl.get_lkp_meaning('VS_EN_COURSE_ATMPT_STATUS', rec_spa.course_attempt_status));
                               fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'START_DT') || ': ' || TO_CHAR(rec_spa.commencement_dt, 'DD/MM/YYYY'));
                               fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_CAT') || ': ' || rec_spa.fee_cat);
                               fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'LOC') || ': ' || rec_spa.location_cd);
                               fnd_message.set_name ( 'IGS', 'IGS_FI_DER_ATT_TYPE_GOVT_MODE');
                               fnd_message.set_token('ATT_MODE', rec_spa.attendance_mode);
                               fnd_file.put_line (fnd_file.log, fnd_message.get);
                               fnd_message.set_name ( 'IGS', 'IGS_FI_ATTTYPE_GOVT_ATTMODE');
                               fnd_message.set_token('ATT_TYPE', rec_spa.attendance_type);
                               fnd_file.put_line (fnd_file.log, fnd_message.get);
                               fnd_message.set_name ( 'IGS', 'IGS_FI_NO_KEY_PROGRAM');
                               fnd_message.set_token('YES_NO', rec_spa.key_program_flag);
                               fnd_file.put_line (fnd_file.log, fnd_message.get);
                             END IF;

                            -- Validate Currency against the currency setup in System Options
                            OPEN cur_fee_cat_curr(rec_spa.fee_cat);
                            FETCH cur_fee_cat_curr INTO l_v_currency_cd;
                            CLOSE cur_fee_cat_curr;
                            IF (l_v_currency_cd <> l_c_control_curr OR l_v_currency_cd IS NULL)  THEN
                              IF (p_trace_on = 'Y') THEN
                                fnd_file.new_line(fnd_file.log);
                                fnd_message.set_name ( 'IGS', 'IGS_FI_INVALID_CURR_CODE');
                                fnd_file.put_line (fnd_file.log, fnd_message.get);
                                fnd_message.set_name('IGS', 'IGS_FI_INV_FEE_CAT_CURR_CODE');
                                fnd_message.set_token('CUR_CODE1', l_v_currency_cd );
                                fnd_message.set_token('FEE_CAT', RTRIM(rec_spa.fee_cat) );
                                fnd_message.set_token('CUR_CODE2', l_c_control_curr );
                                fnd_file.put_line (fnd_file.log, fnd_message.get);
                                log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                            p_v_string => 'Waiver Procesing: Currency at Fee Cat is Invalid. Sys Opt Level: ' || l_c_control_curr
                                                          || ', Fee Cat Level: ' || l_v_currency_cd );
                              END IF;
                            ELSE
                               log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                           p_v_string => 'Waiver Processing: Calling finpl_prc_fee_cat_fee_liab' );

                                IF (finpl_prc_fee_cat_fee_liab ( p_effective_dt          => p_effective_dt,
                                                      p_trace_on              => p_trace_on,
                                                      p_fee_cal_type          => p_fee_cal_type,
                                                      p_fee_ci_sequence_num   => p_fee_ci_sequence_num,
                                                      p_local_currency        => l_v_currency_cd,
                                                      p_fee_cat               => rec_spa.fee_cat,
                                                      p_person_id             => rec_spa.person_id,
                                                      p_course_cd             => rec_spa.program_cd,
                                                      p_course_version_number => rec_spa.program_version,
                                                      p_cal_type              => rec_spa.cal_type,
                                                      p_scahv_location_cd     => rec_spa.location_cd,
                                                      p_scahv_attendance_mode => rec_spa.attendance_mode,
                                                      p_scahv_attendance_type => rec_spa.attendance_type,
                                                      p_discontinued_dt       => rec_spa.discontinued_dt,
                                                      p_course_attempt_status => rec_spa.course_attempt_status,
                                                      p_message_name          => l_v_message_name,
                                                      p_process_mode          => p_process_mode,
                                                      p_c_career              => rec_spa.course_type,
                                                      p_waiver_call_ind       => 'Y',
                                                      p_target_fee_type       => tbl_wav_fcfl(i).p_fee_type ) = TRUE ) THEN
                                  log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                              p_v_string => 'Waiver Processing: finpl_prc_fee_cat_fee_liab returned true' );
                               ELSE
                                 log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                             p_v_string => 'Waiver Processing: finpl_prc_fee_cat_fee_liab returned false' );
                               END IF;
                            END IF;
                            END IF;  -- End if for check on p_fee_category and p_course_cd
                       END LOOP; -- End loop for cur_spa
                   END IF;
                 END LOOP;  -- End loop for tbl_wav_fcfl
               END IF;  -- End if for (p_fee_category IS NOT NULL OR  p_course_cd IS NOT NULL)
            END IF;

          ELSE  -- Predictive Mode of processing.

            l_b_recs_found := FALSE;
            l_b_ret_status := FALSE;
            log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                        p_v_string => 'PREDICTIVE Mode: Calling finpl_prc_predictive_scas.' );
            finpl_prc_predictive_scas ( p_n_person_id           => p_person_id,
                                            p_v_course_cd           => p_course_cd,
                                            p_v_career              => p_c_career,
                                            p_v_fee_category        => p_fee_category,
                                            p_v_fee_cal_type        => p_fee_cal_type,
                                            p_n_fee_ci_sequence_num => p_fee_ci_sequence_num,
                                            p_v_curr_cd             => l_c_control_curr,
                                            p_d_effective_date      => p_effective_dt,
                                            p_v_trace_on            => p_trace_on,
                                            p_b_record_found        => l_b_recs_found,
                                            p_v_message_name        => p_message_name,
                                            p_b_return_status       => l_b_ret_status,
                                            p_waiver_call_ind       => 'N',
                                            p_target_fee_type       => NULL );
            -- Assign l_b_recs_found to v_record_found so that proper message (IGS_FI_NO_STUDPRG_ATTEMPT) is logged if no records found.
            v_record_found := l_b_recs_found;

            IF l_b_ret_status = FALSE THEN
                log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                            p_v_string => 'finpl_prc_predictive_scas returned FALSE. Returning from finp_ins_enr_fee_ass.' );
                RETURN FALSE;
            ELSE
              IF p_v_wav_calc_flag = 'N' THEN
                 IF (p_fee_category IS NOT NULL OR  p_course_cd IS NOT NULL OR p_c_career IS NOT NULL) THEN
                    --- Loop across the PLSQL table to assess fees in entirety
                    FOR i IN 1..tbl_wav_fcfl.COUNT
                    LOOP
                      IF tbl_wav_fcfl.EXISTS(i) THEN
                          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                      p_v_string => 'PREDICTIVE Mode: Waiver Processing - Calling finpl_prc_predictive_scas.' );
                           -- If the SPA has already been assessed, then skip it. Else invoke Predictive processing again.
                           IF ((p_fee_category IS NOT NULL AND p_fee_category = tbl_wav_fcfl(i).p_fee_category)
                                OR (p_course_cd IS NOT NULL AND p_course_cd = tbl_wav_fcfl(i).p_course_cd)
                                OR (p_c_career IS NOT NULL AND p_c_career = tbl_wav_fcfl(i).p_career)) THEN
                                NULL;
                           ELSE
                                finpl_prc_predictive_scas ( p_n_person_id           => p_person_id,
                                              p_v_course_cd           => NULL,
                                              p_v_career              => NULL,
                                              p_v_fee_category        => tbl_wav_fcfl(i).p_fee_category,
                                              p_v_fee_cal_type        => p_fee_cal_type,
                                              p_n_fee_ci_sequence_num => p_fee_ci_sequence_num,
                                              p_v_curr_cd             => l_c_control_curr,
                                              p_d_effective_date      => p_effective_dt,
                                              p_v_trace_on            => p_trace_on,
                                              p_b_record_found        => l_b_recs_found,
                                              p_v_message_name        => p_message_name,
                                              p_b_return_status       => l_b_ret_status,
                                              p_waiver_call_ind       => 'Y',
                                              p_target_fee_type       => tbl_wav_fcfl(i).p_fee_type );
                                IF (l_b_ret_status = FALSE) THEN
                                      log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                                                  p_v_string => 'Waiver Processing: finpl_prc_predictive_scas returned FALSE. Returning from finp_ins_enr_fee_ass.' );
                                      RETURN FALSE;
                                END IF;
                           END IF;  -- End if for NOT condition
                      END IF;  -- End if for tbl_wav_fcfl.EXISTS(i)
                    END LOOP;
                 END IF;  -- End if for (p_fee_category IS NOT NULL OR  p_course_cd IS NOT NULL)
              END IF;  -- End if for ( p_v_wav_calc_flag = 'N' )
            END IF;  -- End if for l_b_ret_status = FALSE
          END IF; /* Predictive Mode = 'N' */

        IF v_record_found = FALSE THEN
          v_message_name := 'IGS_FI_NO_STUDPRG_ATTEMPT';
          IF (p_trace_on = 'Y') THEN
            fnd_message.set_name ( 'IGS', v_message_name);
            fnd_file.put_line (fnd_file.log, fnd_message.get);
          END IF;
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'No Program Attempt Found. Returning from finp_ins_enr_fee_ass with message ' || v_message_name );
        ELSE

          -- If invoked for Waiver Amount calculation only, then it need not process the remaining part
          -- The OUT param, p_n_waiver_amount, has been assigned the appropriate value in finp_clc_ass_amnt
          -- So, return TRUE from here.
          IF  p_v_wav_calc_flag = 'Y' THEN
              log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                          p_v_string => 'Invoked from Waiver Logic, so return TRUE without doing COMMIT or ROLLBACK');
              RETURN TRUE;
          END IF;

          -- If the Auto Calculation of Waivers profile is set to Yes and this is invoked by the normal
          -- run of Fee Calc, then proceed.
          IF (g_v_auto_calc_wav_prof = 'Y' AND p_v_wav_calc_flag = 'N' ) THEN

            -- For Waivers, raise Workflow event only if the process is run with Test Run = No.
            -- For Test Run mode, do not raise Workflow event.
            IF p_test_run = 'N' THEN
               l_v_raise_wf_event := 'Y';
            ELSE
               l_v_raise_wf_event := 'N';
            END IF;

            log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                        p_v_string => 'Before looping across tbl_wav_fcfl');
            FOR i IN 1..tbl_wav_fcfl.COUNT
            LOOP
              l_b_found := FALSE;
              FOR j IN 1..tbl_fee_type.COUNT
              LOOP
                IF (tbl_wav_fcfl(i).p_fee_type = tbl_fee_type(j)) THEN
                  l_b_found := TRUE;
                  EXIT;
                END IF;
              END LOOP;
              IF (l_b_found = FALSE) THEN
                tbl_fee_type(tbl_fee_type.COUNT + 1) := tbl_wav_fcfl(i).p_fee_type;
              END IF;
            END LOOP;

            l_v_err_msg := NULL;
            log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                        p_v_string => 'Waiver Processing: calling igs_fi_prc_waivers.create_waivers for '||tbl_fee_type.COUNT||' record(s)');
            FOR i IN 1..tbl_fee_type.COUNT
            LOOP
              -- Invoke  Waiver API to calculate waiver, always in ACTUAL mode irrespective of the mode Fee Calc is run in
              igs_fi_prc_waivers.create_waivers( p_n_person_id          => p_person_id,
                                                 p_v_fee_type           => tbl_fee_type(i),
                                                 p_v_fee_cal_type       => p_fee_cal_type,
                                                 p_n_fee_ci_seq_number  => p_fee_ci_sequence_num,
                                                 p_v_waiver_name        => NULL,
                                                 p_v_currency_cd        => l_c_control_curr,
                                                 p_d_gl_date            => p_d_gl_date,
                                                 p_v_real_time_flag     => g_v_auto_calc_wav_prof,
                                                 p_v_process_mode       => 'ACTUAL',
                                                 p_v_career             => p_c_career,
                                                 p_b_init_msg_list      => TRUE,
                                                 p_validation_level     => 0,
                                                 p_v_raise_wf_event     => l_v_raise_wf_event,
                                                 x_waiver_amount        => l_n_waiver_amount,
                                                 x_return_status        => l_v_return_status,
                                                 x_msg_count            => l_n_msg_count,
                                                 x_msg_data             => l_v_msg_data );
              IF l_v_return_status = 'S' THEN
                  l_n_sum_waiver_amount := NVL(l_n_sum_waiver_amount,0) + NVL(l_n_waiver_amount,0);
                  log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                              p_v_string => 'Waiver Processing: Waiver Amount '||i||': '||NVL(l_n_waiver_amount,0));
              ELSE
                  l_n_sum_waiver_amount := 0;
                  log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                              p_v_string => 'Waiver Processing: Error: Message Count - '||NVL(l_n_msg_count,0)||' Message Data: '||l_v_msg_data);
                  IF (p_trace_on = 'Y') THEN
                     IF l_n_msg_count = 1 THEN
                        fnd_message.set_encoded(l_v_msg_data);
                        fnd_file.put_line(fnd_file.log,fnd_message.get);
                     ELSIF l_n_msg_count > 1 THEN
                        FOR l_n_count IN 1..l_n_msg_count LOOP
                            l_v_err_msg := fnd_msg_pub.get(p_msg_index => l_n_count, p_encoded => 'T');
                            fnd_message.set_encoded(l_v_err_msg);
                            fnd_file.put_line(fnd_file.log,fnd_message.get);
                        END LOOP;
                     END IF;
                  END IF;  -- End if for p_trace_on
              END IF;
            END LOOP;

            -- Setting the Global Parameter, g_v_wav_calc_flag to N as part Bug# 4634950
            -- When the Fee Assessment is submitted and before calling the create_waivers procedure the value of variable, g_v_wav_calc_flag is N.
            -- But after the completion of create_waivers this parameter is set 'Y' as create_waivers internally call the Fee Assessment process
            g_v_wav_calc_flag := 'N';

            IF (p_trace_on = 'Y') THEN
                fnd_file.put_line(fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','WAIVER_AMOUNT')||': '||NVL(l_n_sum_waiver_amount,0));
                fnd_file.new_line(fnd_file.log);
            END IF;

          END IF;
        END IF;

        IF (p_test_run = 'N') THEN
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Test Run: No, so issuing COMMIT');
          COMMIT;
        ELSE
          log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                      p_v_string => 'Test Run: Yes, so issuing ROLLBACK till savepoint fee_calc_sp');

          -- Rollback is not required in case the Fee Assessment is called from Tuition Waivers,
          -- since all the insertion/updation operations are performed in procedure finpl_ins_fee_ass and
          -- this procedure would be bypassed for Tuition Waivers functionality. Ref Bug# 4639869
          IF g_v_wav_calc_flag = 'N' THEN
            ROLLBACK TO fee_calc_sp;
          END IF;

        END IF;

        p_message_name := NULL;

        log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                    p_v_string => 'Finished the Processing Successfully. OUT Variables: Creation Date: '
                                  || TO_CHAR(p_creation_dt, 'DD-MON-YYYY HH24:MI:SS') || ', Message: ' || p_message_name);

        RETURN TRUE;

    EXCEPTION
        WHEN e_one_record_expected THEN
                log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                            p_v_string => 'In Exception Handler of e_one_record_expected.' );
                fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                fnd_message.set_token('NAME','IGS_FI_PRC_FEE_ASS.FINP_INS_ENR_FEE_ASS-'||SUBSTR(SQLERRM,1,500));
                igs_ge_msg_stack.add;
                app_exception.raise_exception(NULL, NULL, fnd_message.get);
        WHEN OTHERS THEN
                log_to_fnd( p_v_module => 'finp_ins_enr_fee_ass',
                            p_v_string => 'In Exception Handler WHEN OTHERS.' );
                fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                fnd_message.set_token('NAME','IGS_FI_PRC_FEE_ASS.FINP_INS_ENR_FEE_ASS-'||SUBSTR(SQLERRM,1,500));
                igs_ge_msg_stack.add;
                app_exception.raise_exception;
        END ;
    END finp_ins_enr_fee_ass;

FUNCTION finpl_insert_record(p_n_person_id                 IN igs_fi_fee_as_all.person_id%TYPE,
                             p_v_course_cd                 IN igs_ps_ver_all.course_cd%TYPE,
                             p_v_fee_cal_type              IN igs_fi_fee_as_all.fee_cal_type%TYPE,
                             p_n_fee_ci_sequence_number    IN igs_fi_fee_as_all.fee_ci_sequence_number%TYPE)
RETURN BOOLEAN
IS
PRAGMA AUTONOMOUS_TRANSACTION;
/*************************************************************
 Created By : Priya Athipatla
 Date Created By : 01-Jul-2004
 Purpose : Function inserts records into table IGS_FI_SPA_FEE_PRDS
           if such a record doesnt exist already. Invoked from
           finpl_lock_records().

           Returns TRUE if insertion was successful, FALSE otherwise.

 Know limitations, enhancements or remarks
 Change History
 Who            When        What
 akandreg       24-Apr-2006  Bug 5134627 - Modified TBH callout to pass value for TRANSACTION_TYPE
***************************************************************/
l_rowid                ROWID;

BEGIN

   log_to_fnd( p_v_module => 'finpl_insert_record',
                   p_v_string => 'Proceeding to insert an Assessment record into IGS_FI_SPA_FEE_PRDS' );

   l_rowid := NULL;
   igs_fi_spa_fee_prds_pkg.insert_row ( x_rowid                   => l_rowid,
                                        x_person_id               => p_n_person_id,
                                        x_course_cd               => p_v_course_cd,
                                        x_fee_cal_type            => p_v_fee_cal_type,
                                        x_fee_ci_sequence_number  => p_n_fee_ci_sequence_number,
                                        x_mode                    => 'R',
                                        x_transaction_type        => 'ASSESSMENT'
                                      );
   COMMIT;
   log_to_fnd( p_v_module => 'finpl_insert_record',
               p_v_string => 'Record inserted into IGS_FI_SPA_FEE_PRDS, Commit successful, Return TRUE' );

   RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
     log_to_fnd( p_v_module => 'finpl_insert_record',
                 p_v_string => 'Exception section of finpl_insert_record : '||SQLERRM );
     IF g_v_wav_calc_flag = 'N' THEN
       ROLLBACK TO fee_calc_sp;
     END IF;

     RETURN FALSE;

END finpl_insert_record;


FUNCTION  finpl_lock_records(p_n_person_id                 IN igs_fi_fee_as_all.person_id%TYPE,
                             p_v_course_cd                 IN igs_ps_ver_all.course_cd%TYPE,
                             p_v_fee_cal_type              IN igs_fi_fee_as_all.fee_cal_type%TYPE,
                             p_n_fee_ci_sequence_number    IN igs_fi_fee_as_all.fee_ci_sequence_number%TYPE)
RETURN BOOLEAN IS
/*************************************************************
 Created By : Priya Athipatla
 Date Created By : 01-Jul-2004
 Purpose : This function locks the record in the table IGS_FI_SPA_FEE_PRDS
           based on the combination of Person-Course-Fee Period that is
           passed as the input parameters. Added as a fix to prevent
           concurrent running of multiple instances of the process.

           Returns TRUE if locking was successful, FALSE otherwise.

 Know limitations, enhancements or remarks
 Change History
 Who            When        What
 akandreg       31-May-2006 Bug 5134636 - Modified cur_fee_spa to add check on TRANSACTION_TYPE
***************************************************************/

CURSOR cur_fee_spa (cp_person_id               igs_fi_spa_fee_prds.person_id%TYPE,
                    cp_course_cd               igs_fi_spa_fee_prds.course_cd%TYPE,
                    cp_fee_cal_type            igs_fi_spa_fee_prds.fee_cal_type%TYPE,
                    cp_fee_ci_sequence_number  igs_fi_spa_fee_prds.fee_ci_sequence_number%TYPE,
                    cp_transaction_type        igs_fi_spa_fee_prds.transaction_type%TYPE) IS
  SELECT 'x'
  FROM igs_fi_spa_fee_prds
  WHERE person_id = cp_person_id
  AND course_cd = cp_course_cd
  AND fee_cal_type = cp_fee_cal_type
  AND fee_ci_sequence_number = cp_fee_ci_sequence_number
  AND transaction_type = cp_transaction_type
  FOR UPDATE NOWAIT;

l_v_dummy  VARCHAR2(2) := NULL;   -- Dummy variable to hold the value selected in cur_fee_spa

BEGIN

   log_to_fnd( p_v_module => 'finpl_lock_records',
               p_v_string => 'Checking if record already exists in IGS_FI_SPA_FEE_PRDS to lock' );

   OPEN cur_fee_spa(p_n_person_id,
                    p_v_course_cd,
                    p_v_fee_cal_type,
                    p_n_fee_ci_sequence_number,
                    'ASSESSMENT');
   FETCH cur_fee_spa INTO l_v_dummy;
   IF cur_fee_spa%NOTFOUND THEN
       -- If the record does not exist in igs_fi_spa_fee_period table, then insert into the table.
       log_to_fnd( p_v_module => 'finpl_lock_records',
                   p_v_string => 'Record not present in IGS_FI_SPA_FEE_PRDS, so call finpl_insert_record' );
       CLOSE cur_fee_spa;
       -- Call autonomous function to insert into IGS_FI_SPA_FEE_PRDS
       IF finpl_insert_record(p_n_person_id,
                              p_v_course_cd,
                              p_v_fee_cal_type,
                              p_n_fee_ci_sequence_number) THEN
         -- After insertion (if insertion was successful), lock the record
         log_to_fnd( p_v_module => 'finpl_lock_records',
                     p_v_string => 'Insertion of record in IGS_FI_SPA_FEE_PRDS successful, lock and return TRUE');
         OPEN cur_fee_spa(p_n_person_id,
                          p_v_course_cd,
                          p_v_fee_cal_type,
                          p_n_fee_ci_sequence_number,
                          'ASSESSMENT');
         FETCH cur_fee_spa INTO l_v_dummy;
         CLOSE cur_fee_spa;
         RETURN TRUE;
       ELSE
         -- Insertion failed, return FALSE
         log_to_fnd( p_v_module => 'finpl_lock_records',
                     p_v_string => 'Insertion of record into IGS_FI_SPA_FEE_PRDS not successful, return FALSE');
         RETURN FALSE;
       END IF;
   ELSE
       -- If record exists in table igs_fi_spa_fee_period, then lock the record.
       CLOSE cur_fee_spa;
       log_to_fnd( p_v_module => 'finpl_lock_records',
                   p_v_string => 'Record exists in IGS_FI_SPA_FEE_PRDS, so lock and return TRUE');
       RETURN TRUE;
   END IF;  -- End if for cursor cur_fee_spa NOTFOUND

EXCEPTION
  WHEN OTHERS THEN
     log_to_fnd( p_v_module => 'finpl_lock_records',
                 p_v_string => 'Exception section of finpl_lock_records : '||SQLERRM );

     IF g_v_wav_calc_flag = 'N' THEN
       ROLLBACK TO fee_calc_sp;
     END IF;

     RETURN FALSE;

END finpl_lock_records;


FUNCTION  finpl_check_header_lines(p_n_person_id       igs_fi_fee_as_all.person_id%TYPE,
                                   p_n_transaction_id  igs_fi_fee_as_all.transaction_id%TYPE)
RETURN BOOLEAN IS
/*************************************************************
 Created By : Priya Athipatla
 Date Created By : 01-Jul-2004
 Purpose : This function checks if a header in IGS_FI_FEE_AS and
           line records in IGS_FI_FEE_AS_ITEMS have been created
           correctly or not.

 Know limitations, enhancements or remarks
 Change History
 Who            When        What
***************************************************************/
CURSOR cur_fee_as(cp_n_person_id        igs_fi_fee_as_all.person_id%TYPE,
                  cp_n_transaction_id   igs_fi_fee_as_all.transaction_id%TYPE) IS
  SELECT SUM(transaction_amount)
  FROM igs_fi_fee_as_all
  WHERE person_id = cp_n_person_id
  AND transaction_id = cp_n_transaction_id;

CURSOR cur_fee_as_items(cp_n_person_id        igs_fi_fee_as_all.person_id%TYPE,
                        cp_n_transaction_id   igs_fi_fee_as_all.transaction_id%TYPE) IS
  SELECT amount
  FROM igs_fi_fee_as_items
  WHERE person_id = cp_n_person_id
  AND transaction_id = cp_n_transaction_id;

l_n_lines_sum      NUMBER := 0.0;
l_n_header_sum     NUMBER := 0.0;
l_b_line_exists    BOOLEAN := FALSE;


BEGIN

    log_to_fnd( p_v_module => 'finpl_check_header_lines',
                p_v_string => 'Proceeding to check if header and lines are created correctly');

    -- Obtain total amount in IGS_FI_FEE_AS - the Header table
    OPEN cur_fee_as(p_n_person_id, p_n_transaction_id);
    FETCH cur_fee_as INTO l_n_header_sum;
    IF cur_fee_as%NOTFOUND THEN
       log_to_fnd( p_v_module => 'finpl_check_header_lines',
                   p_v_string => 'Record not found in IGS_FI_FEE_AS for Person ID: '||p_n_person_id||
                                 ' and Transaction ID: '||p_n_transaction_id||
                                 '. Returning FALSE');
       CLOSE cur_fee_as;
       RETURN FALSE;
    END IF;
    CLOSE cur_fee_as;

    -- Loop through Line records and obtain total amount in IGS_FI_FEE_AS_ITEMS
    FOR l_rec_fee_as_items IN cur_fee_as_items(p_n_person_id, p_n_transaction_id) LOOP
        l_b_line_exists := TRUE;
        -- 'Amount' is a Nullable column, so check for Null
        IF l_rec_fee_as_items.amount IS NULL THEN
           log_to_fnd( p_v_module => 'finpl_check_header_lines',
                       p_v_string => 'Amount in IGS_FI_FEE_AS_ITEMS is NULL for Person ID: '||p_n_person_id||
                                     ' and Transaction ID: '||p_n_transaction_id||
                                     '. Returning FALSE');
           RETURN FALSE;
        ELSE
           -- Sum of amounts
           l_n_lines_sum := l_n_lines_sum + l_rec_fee_as_items.amount;
        END IF;
    END LOOP;

    -- Check if atleast one line record was found in IGS_FI_FEE_AS_ITEMS for the given transaction
    IF NOT l_b_line_exists THEN
        log_to_fnd( p_v_module => 'finpl_check_header_lines',
                    p_v_string => 'Record not found in IGS_FI_FEE_AS_ITEMS for Person ID: '||p_n_person_id||
                                  ' and Transaction ID: '||p_n_transaction_id||'  Returning FALSE');
        RETURN FALSE;
    END IF;

    log_to_fnd( p_v_module => 'finpl_check_header_lines',
                p_v_string => 'Header and Lines Amount for Person ID: '||p_n_person_id||
                              ' and Transaction ID: '||p_n_transaction_id||
                              '   Header Amount: '||l_n_header_sum||
                              '   Lines Amount: '||l_n_lines_sum);

    -- If there is any mismatch in the amounts in the Header and Lines tables, return FALSE
    IF (l_n_lines_sum <> l_n_header_sum) THEN
       log_to_fnd( p_v_module => 'finpl_check_header_lines',
                   p_v_string => 'Difference in Sum between Header and Lines for Person ID: '||p_n_person_id||
                                 ' and Transaction ID: '||p_n_transaction_id||
                                 '   Header Amount: '||l_n_header_sum||
                                 '   Lines Amount: '||l_n_lines_sum||
                                 '. Returning FALSE');
       RETURN FALSE;
    ELSE
      -- Header and Lines sum match, so return TRUE
       log_to_fnd( p_v_module => 'finpl_check_header_lines',
                   p_v_string => 'Header and Lines Amount match for Person ID: '||p_n_person_id||
                                 ' and Transaction ID: '||p_n_transaction_id||
                                 '   Header Amount: '||l_n_header_sum||
                                 '   Lines Amount: '||l_n_lines_sum||
                                 '. Returning TRUE');
       RETURN TRUE;
    END IF;

END finpl_check_header_lines;

PROCEDURE create_retention_charge( p_n_person_id               IN igs_fi_inv_int_all.person_id%TYPE,
                                   p_v_course_cd               IN igs_fi_inv_int_all.course_cd%TYPE,
                                   p_v_fee_cal_type            IN igs_fi_inv_int_all.fee_cal_type%TYPE,
                                   p_n_fee_ci_sequence_number  IN igs_fi_inv_int_all.fee_ci_sequence_number%TYPE,
                                   p_v_fee_type                IN igs_fi_inv_int_all.fee_type%TYPE,
                                   p_v_fee_cat                 IN igs_fi_inv_int_all.fee_cat%TYPE,
                                   p_d_gl_date                 IN igs_fi_invln_int_all.gl_date%TYPE,
                                   p_n_uoo_id                  IN igs_fi_invln_int_all.uoo_id%TYPE,
                                   p_n_amount                  IN igs_fi_inv_int_all.invoice_amount%TYPE,
                                   p_v_fee_type_desc           IN igs_fi_fee_type_all.description%TYPE,
                                   p_v_fee_trig_cat            IN igs_fi_fee_type_all.s_fee_trigger_cat%TYPE,
                                   p_trace_on                  IN VARCHAR2) AS
/*************************************************************
 Created By : Priya Athipatla
 Date Created By : 07-Sep-2004
 Purpose : Procedure invoked to create a retention charge.
 Know limitations, enhancements or remarks
 Change History
 Who            When        What
 abshriva    24-May-2006    Bug 5204728: Introduced p_trace_on in parameter list.
 abshriva    12-May-2006    Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
 bannamal    03-Jun-2005    Bug#3442712 Unit Level Fee Assessment Build. Modified the call
                            to igs_fi_fee_as_items_pkg.insert_row added new parameters
                            unit_type_id, unit_class, unit_mode and unit_level.

***************************************************************/

  -- Cursor to fetch the Fee Type Description

  l_rowid               ROWID := NULL;
  l_n_transaction_id    igs_fi_fee_as_all.transaction_id%TYPE := NULL;
  l_v_fee_cat           igs_fi_fee_as_all.fee_cat%TYPE := NULL;
  l_v_course_cd         igs_fi_fee_as_all.course_cd%TYPE := NULL;
  l_n_invoice_id        igs_fi_inv_int_all.invoice_id%TYPE    := NULL;
  l_n_fee_ass_item_id   igs_fi_fee_as_items.fee_ass_item_id%TYPE := NULL;

  l_header_rec          igs_fi_charges_api_pvt.header_rec_type;
  l_line_rec            igs_fi_charges_api_pvt.line_tbl_type;
  l_line_rec_dummy      igs_fi_charges_api_pvt.line_tbl_type;
  l_line_id_tbl         igs_fi_charges_api_pvt.line_id_tbl_type;
  l_line_id_tbl_dummy   igs_fi_charges_api_pvt.line_id_tbl_type;

  l_v_status        VARCHAR2(1)    := NULL;
  l_n_msg_count     NUMBER         := NULL;
  l_v_msg_data      VARCHAR2(2000) := NULL;
  l_n_waiver_amt    NUMBER         := NULL;
  l_v_invoice_num   igs_fi_inv_int_all.invoice_number%TYPE;

BEGIN

   log_to_fnd( p_v_module => 'create_retention_charge',
               p_v_string => 'Parameters: '|| p_n_person_id ||', '|| p_v_course_cd || ', '|| p_v_fee_cal_type|| ', '||
                              p_n_fee_ci_sequence_number||', '||p_v_fee_type||', '|| p_v_fee_cat||', '||TO_CHAR(p_d_gl_date,'DD-MON-YYYY') ||', '||
                              p_n_uoo_id||', '||p_n_amount);

   -- Initialize values of Fee Cat and Course Cd
   l_v_fee_cat     := p_v_fee_cat;
   l_v_course_cd   := p_v_course_cd;

   -- For Institution Type Trigger, Fee Category and Course Code is passed as Null.
   IF p_v_fee_trig_cat = 'INSTITUTN' THEN
      log_to_fnd( p_v_module => 'create_retention_charge',
                  p_v_string => 'Institution Type trigger, so assigning Null to fee_cat and course_cd');
      l_v_fee_cat    := NULL;
      l_v_course_cd  := NULL;
   END IF;

   log_to_fnd( p_v_module => 'create_retention_charge',
               p_v_string => 'Inserting AS record for Retention Amount.');
   -- Insert the Retention Charge in the Fee Assessment Header table
   -- Modified transaction_dt, effective_dt entries as Trunc(Sysdate) as part of Bug 4240402: Timezone impact
   igs_fi_fee_as_pkg.insert_row (x_rowid                   => l_rowid,
                                 x_person_id               => p_n_person_id,
                                 x_transaction_id          => l_n_transaction_id,
                                 x_fee_type                => p_v_fee_type,
                                 x_fee_cal_type            => p_v_fee_cal_type,
                                 x_fee_ci_sequence_number  => p_n_fee_ci_sequence_number,
                                 x_fee_cat                 => l_v_fee_cat,
                                 x_s_transaction_type      => g_v_retention,
                                 x_transaction_dt          => TRUNC(SYSDATE),
                                 x_transaction_amount      => igs_fi_gen_gl.get_formatted_amount(p_n_amount),
                                 x_currency_cd             => g_v_currency_cd,
                                 x_exchange_rate           => 1,
                                 x_chg_elements            => NULL,
                                 x_effective_dt            => TRUNC(SYSDATE),
                                 x_course_cd               => l_v_course_cd,
                                 x_notification_dt         => NULL,
                                 x_logical_delete_dt       => NULL,
                                 x_comments                => NULL,
                                 x_mode                    => 'R',
                                 x_org_id                  => g_n_org_id);

   l_header_rec.p_person_id              := p_n_person_id;
   l_header_rec.p_fee_type               := p_v_fee_type;
   l_header_rec.p_fee_cat                := l_v_fee_cat;
   l_header_rec.p_fee_cal_type           := p_v_fee_cal_type;
   l_header_rec.p_fee_ci_sequence_number := p_n_fee_ci_sequence_number;
   l_header_rec.p_course_cd              := l_v_course_cd;
   l_header_rec.p_attendance_type        := NULL;
   l_header_rec.p_attendance_mode        := NULL;
   l_header_rec.p_invoice_amount         := p_n_amount;
   l_header_rec.p_invoice_creation_date  := SYSDATE;
   l_header_rec.p_invoice_desc           := p_v_fee_type_desc;
   l_header_rec.p_transaction_type       := g_v_retention;
   l_header_rec.p_currency_cd            := g_v_currency_cd;
   l_header_rec.p_exchange_rate          := 1;
   l_header_rec.p_effective_date         := SYSDATE;
   l_header_rec.p_waiver_flag            := NULL;
   l_header_rec.p_waiver_reason          := NULL;
   l_header_rec.p_source_transaction_id  := NULL;

   -- Initializing the line record variable
   l_line_rec := l_line_rec_dummy;

   -- Setting the values for the line record
   l_line_rec(1).p_s_chg_method_type := g_v_chgmthd_flatrate;
   l_line_rec(1).p_description       := p_v_fee_type_desc;
   l_line_rec(1).p_chg_elements      := NULL;
   l_line_rec(1).p_amount            := p_n_amount;
   l_line_rec(1).p_d_gl_date         := TRUNC(p_d_gl_date);
   l_line_rec(1).p_uoo_id            := p_n_uoo_id;

   -- Initializing the line record
   l_line_id_tbl := l_line_id_tbl_dummy;

   log_to_fnd( p_v_module => 'create_retention_charge',
               p_v_string => 'Invoking Charges API to create Retention Charge.');
   -- Invoke Charges API to create a retention charge.
   igs_fi_charges_api_pvt.create_charge( p_api_version   => 2.0,
                                         p_init_msg_list => 'F',
                                         p_commit        => 'F',
                                         p_header_rec    => l_header_rec,
                                         p_line_tbl      => l_line_rec,
                                         x_invoice_id    => l_n_invoice_id,
                                         x_line_id_tbl   => l_line_id_tbl,
                                         x_return_status => l_v_status,
                                         x_msg_count     => l_n_msg_count,
                                         x_msg_data      => l_v_msg_data,
                                         x_waiver_amount => l_n_waiver_amt);

   -- If status returned by the Charges API is not 'S' then raise exception
   IF l_v_status <> 'S' THEN
      log_to_fnd( p_v_module => 'create_retention_charge',
                  p_v_string => 'Charges API returned with status <> S, stack message and raise exception');

      IF l_n_msg_count = 1 THEN
         fnd_message.set_encoded(l_v_msg_data);
      ELSIF l_n_msg_count > 1 THEN
        FOR l_n_cntr IN 1 .. l_n_msg_count
        LOOP
           fnd_message.set_encoded(fnd_msg_pub.get (p_msg_index => l_n_cntr,
                                                    p_encoded => 'T')
                                  );
        END LOOP;
      END IF;
      app_exception.raise_exception;
   END IF;
  IF (p_trace_on = 'Y') THEN
    l_v_invoice_num := igs_fi_gen_008.get_invoice_number(l_n_invoice_id);
    fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'RET_CHG_NUM') || ': ' || l_v_invoice_num);
    fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'RET_CHG_AMT') || ': ' || TO_CHAR(p_n_amount));
    fnd_file.new_line(fnd_file.log);
  END IF;
   -- Call the TBH for inserting record in IGS_FI_FEE_AS_ITEMS if Charges API returned successfully
  --  Modified fee_effective_dt entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact
   l_rowid := NULL;
   l_n_fee_ass_item_id := NULL;
   log_to_fnd( p_v_module => 'create_retention_charge',
               p_v_string => 'Inserting Fee Assessment Items Record for Rentention charge.');
   igs_fi_fee_as_items_pkg.insert_row( x_rowid                  => l_rowid,
                                       x_fee_ass_item_id        => l_n_fee_ass_item_id,
                                       x_transaction_id         => l_n_transaction_id,
                                       x_person_id              => p_n_person_id,
                                       x_status                 => 'E',
                                       x_fee_type               => p_v_fee_type,
                                       x_fee_cat                => l_v_fee_cat ,
                                       x_fee_cal_type           => p_v_fee_cal_type ,
                                       x_fee_ci_sequence_number => p_n_fee_ci_sequence_number,
                                       x_rul_sequence_number    => NULL,
                                       x_s_chg_method_type      => g_v_chgmthd_flatrate,
                                       x_description            => NULL,
                                       x_chg_elements           => NULL,
                                       x_amount                 => igs_fi_gen_gl.get_formatted_amount(p_n_amount),
                                       x_fee_effective_dt       => TRUNC(SYSDATE),
                                       x_course_cd              => l_v_course_cd,
                                       x_crs_version_number     => NULL,
                                       x_course_attempt_status  => NULL,
                                       x_attendance_mode        => NULL,
                                       x_attendance_type        => NULL,
                                       x_unit_attempt_status    => NULL,
                                       x_location_cd            => NULL,
                                       x_eftsu                  => NULL,
                                       x_credit_points          => NULL,
                                       x_logical_delete_date    => NULL,
                                       x_invoice_id             => l_n_invoice_id,
                                       x_org_unit_cd            => NULL,
                                       x_class_standing         => NULL,
                                       x_residency_status_cd    => NULL,
                                       x_uoo_id                 => p_n_uoo_id,
                                       x_chg_rate               => NULL,
                                       x_unit_set_cd            => NULL,
                                       x_us_version_number      => NULL,
                                       x_unit_type_id           => NULL,
                                       x_unit_class             => NULL,
                                       x_unit_mode              => NULL,
                                       x_unit_level             => NULL
                                  );
   log_to_fnd( p_v_module => 'create_retention_charge',
               p_v_string => 'Returning from create_retention_charge');

END create_retention_charge;


FUNCTION finpl_get_org_unit_cd(p_n_party_id   IN hz_parties.party_id%TYPE) RETURN VARCHAR2 AS
/*************************************************************
 Created By : Priya Athipatla
 Date Created By : 10-Oct-2005
 Purpose : Function to return the Party Number for an Organization
 Know limitations, enhancements or remarks
 Change History
 Who            When        What
***************************************************************/

-- Cursor to fetch the Org Unit Cd
CURSOR cur_org_unit_cd(cp_n_party_id  hz_parties.party_id%TYPE) IS
  SELECT party_number
  FROM igs_or_inst_org_base_v
  WHERE party_id = cp_n_party_id;

l_v_org_unit_cd  igs_or_inst_org_base_v.party_number%TYPE;

BEGIN

   l_v_org_unit_cd := NULL;

   OPEN cur_org_unit_cd(p_n_party_id);
   FETCH cur_org_unit_cd INTO l_v_org_unit_cd;
   CLOSE cur_org_unit_cd;

   RETURN l_v_org_unit_cd;

END finpl_get_org_unit_cd;

END igs_fi_prc_fee_ass;

/
