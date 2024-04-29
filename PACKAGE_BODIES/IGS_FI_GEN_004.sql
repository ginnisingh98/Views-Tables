--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_004" AS
/* $Header: IGSFI04B.pls 120.15 2006/06/22 12:55:55 abshriva ship $ */

/* Who                 When                    What
   abshriva           22-JUN-2006             Bug 5070074   Modifcation made in procedure 'finp_prc_enr_fee_ass()'
   abshriva             04-May-2006            Bug 5178077: Introduced igs_ge_gen_003.set_org_id
   abshriva             05-Dec-2005           Bug:4721566.Modification made in procedure 'finp_prc_enr_fee_ass()'
   abshriva             05-Dec-2005            Bug:4701695 Modification made in procedure 'finp_prc_enr_fee_ass()'
   pathipat            30-Sep-2005             Bug 4570538: FEE ASSESSMENTS FROM TO DO ENTRIES IGNORES PARM FEE ASSESSMENT PERIOD
                                               Modified finp_prc_enr_fa_todo
   bannamal            26-Aug-2005             Enh 3392095: Tuition Waiver build
   bannamal            01-Aug-2005             Enh 3392088: Campus Privilege Fees build
   bannamal            27-May-2005             Fee Calculation Performance Enhancement. Changes done as per TD.
   shtatiko            29-JUL-2004             Bug# 2734512, Modified message handling in finp_prc_enr_fa_todo
   vvutukur            03-Feb-2004             Enh#3167098.FICR112 Build. Modified finp_prc_cfar.
   shtatiko            24-DEC-2003             Enh# 3167098, Modified finp_prc_sca_unconf, finp_prc_enr_fee_ass, finpl_prc_reverse_fee_assess
   uudayapr            15-DEC-2003             Bug#3080983  Modified the Procedure finp_prc_enr_fee_ass,finp_prc_sca_unconf
                                               and the input parameter  of procedure finpl_prc_reverse_fee_assess, finpl_prc_this_crs_liable,
                                                finpl_prc_another_crs_liable to use IGS_FI_FEE_AS instead of IGS_FI_FEE_ASS_DEBT_V.
   shtatiko            25-NOV-2003             Bug# 3230754, Modified finp_prc_enr_fa_todo.
   pathipat            04-Nov-2003             Bug: 3151102 - Modified finp_prc_enr_fee_ass() Removed conditions before
                                               setting p_create_dt to v_create_dt
   pathipat            17-Oct-2003             Bug: 3151102 - Modified finp_prc_enr_fee_ass() - Added begin-end block for exception handling
   pathipat            07-Oct-2003             Bug 3122652: Modified finp_prc_enr_fee_ass() - Added validation for person id group
   pathipat            23-Sep-2003             Bug: 3151102 - Modified finp_prc_enr_fee_ass()
   pathipat            09-Sep-2003             Bug 3122652: Modified finp_prc_enr_fee_ass() - Replaced call to igf_ap_ss_pkg.get_pid() with
                                               call to igs_pe_dynamic_persid_group.igs_get_dynamic_sql()
                                               Removed commented out code
   knaraset            12-May-2003             Modified cursor c_get_todo_ref_csr to select uoo_id in procedure finp_prc_fa_ref_todo,
                                               also added uoo_id in TBH call to todo_ref, as part of MUS build bug 2829262
   shtatiko            06-MAY-2003             Enh# 2831569, Modified finp_prc_enr_fee_ass and finp_prc_enr_fa_todo.
   shtatiko            30-JAN-2003             Bug# 2765239, Replaced IGS_GE_INVALID_VALUE parameter with more meaningful messages.
                                               Affected procedures are finp_prc_enr_fa_todo, finp_prc_enr_fee_ass and finp_prc_cfar
   vchappid            21-Jan-2003             Bug#2711202, in the procedure finp_prc_enr_fa_todo,for the in-out variable for p_creation_dt
                                               parameter in the fee assessment call should be passed as v_creation_dt which is defined in the
                                               Main Procedure Call instead of the local variable defined in the local procedure finp_prc_fa_ref_todo
   vchappid            06-Jan-2003             Bug# 2660155, In procedure finp_prc_enr_fee_ass, Modified code to identify distinct persons when user don't
                                               provide Person Id or Person ID Group as an input value to the request.
   vchappid            02-Jan-2003             Bug# 2727402, Unhandled Exception should not occur when GL Date passed is invalid
   vchappid            11-Nov-02               Bug# 2584986, GL- Interface Build New Date parameter.
                                               p_d_gl_date is added to the finp_prc_enr_fa_todo, finp_prc_enr_fee_ass
                                               procedure specification
                                               In the procedure finp_prc_sca_unconf, in the local procedure finpl_prc_reverse_fee_assess
                                               a new gl_date parameter is passed as system date to the procedure igs_fi_prc_fee_ass.finp_ins_enr_fee_ass call
   vchappid            17-Oct-02               Enh bug#2595962.Modified procedures finp_prc_fa_ref_todo,
                                               finp_prc_enr_fa_todo,finp_prc_enr_fee_ass and
                                               finpl_prc_reverse_fee_assess.
   jbegum              06-jun-02               As part of bug fix of bug #2318488 the local procedure finp_prc_hecs_pymnt_optn is being
                                               obsoleted

   vchappid            24-May-2002             Bug#2228743, in the local procedure finpl_prc_reverse_fee_assess of finp_prc_sca_unconf
                                               fee assessment call has been changed to pass course cd in case of program approach, course type
                                               incase of the career approach and will pass null in the case of primary_career approach

   vchappid            21-May-2002             Bug#2374754, removed the clause 'for update NOWAIT' form the cursor c_get_todo_ref_csr
                                               in the local procedure finp_prc_fa_ref_todo, removed the commented code,
                                               In the fee assessment call process mode parameter is incorrectly passed as NULL,
                                               'ACTUAL' is passed instead of NULL, re-initialized the process next record variable
                                               to FASLE, it might have been set to TRUE while processing the previously fetched record
                                               Log messages format is changed

   rnirwani             05-May-02                Bug#2329407 removeed reference to IGS_FI_DSBR_SPSHT
   rnirwani             25-Apr-02                Bug# 2329407 Modified Procedure: finp_prc_enr_fa_todo
                                                 decalaration of cursor variable of cursor c_fee_cal_instance
                                                 was pointed to fee calendar from fin calendar

                                                 Modified Procedure: finp_prc_enr_fee_ass
                                                 decalaration of cursor variable of cursor c_fee_cal_instance
                                                 was pointed to fee calendar from fin calendar

                                                 Modified the procedure finpl_prc_reverse_fee_assess
                                                 Removed the parameters : p_fin_cal_type, p_fin_ci_sequence_number.

                                                 Modified the procedure finp_prc_sca_unconf
                                                 Altered cursor c_fasdv to not select fin calendar caloumns
                                                 Removed passage of fin calendar to invocation of procedure
                                                 finpl_prc_reverse_fee_assess

   schodava            01-APR-2002             Enh # 2280971
                                               Modified procedure finp_prc_enr_fa_todo
                                               New local procedure finpl_prc_fa_ref_todo
                                               added.
   smadathi            03-JAN-2002             Bug 2170429 : removed the private procedure
                                               finpl_prc_end_fee_sponsorship and all the references to it.
   vchappid            02-Jan-2002             Enh # 2162747 : Removed the reference to parameter p_fin_cal,
                                               p_c_career parameter is introduced in the fee Assessment routine
   schodava            28-NOV-2001             Enh # 2122257 : Implements the CR for 'Fee Category Change'
                                               Change in Procedure finp_prc_sca_unconf
*/

g_d_sysdate          CONSTANT DATE := TRUNC(SYSDATE);
g_v_ind_no           CONSTANT VARCHAR2(1) := 'N';

FUNCTION finp_prc_cfar(
  p_person_id  IGS_FI_FEE_AS_RT.person_id%TYPE ,
  p_course_cd  IGS_FI_FEE_AS_RT.course_cd%TYPE ,
  p_commencement_dt  IGS_FI_FEE_AS_RT.start_dt%TYPE ,
  p_completion_dt  IGS_FI_FEE_AS_RT.end_dt%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who        When             What
  --vvutukur    03-Feb-2004    Enh#3167098.FICR112 Build. Modified c_scafcflrv.
------------------------------------------------------------------

BEGIN   --finp_prc_cfar
        --This routine is used to control the creation of contract fee assessment
        --rate records from TUITION fee liabilities
DECLARE
        v_exit_loop             BOOLEAN := FALSE;
        v_rec_found             BOOLEAN := FALSE;
        cst_tuition             CONSTANT IGS_FI_F_CAT_FEE_LBL_SCA_RT_V.s_fee_type%TYPE := 'TUITION';
        cst_active
                                CONSTANT IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE :='ACTIVE';
        cst_planned
                                CONSTANT IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE :='PLANNED';
        v_previous_fee_type     IGS_FI_FEE_TYPE.FEE_TYPE%TYPE;

        CURSOR  c_scafcflrv( cp_v_s_fee_structure_status  igs_fi_fee_str_stat.s_fee_structure_status%TYPE,
                             cp_v_closed_ind              igs_fi_fee_type.closed_ind%TYPE,
                             cp_v_s_fee_trigger_cat       igs_fi_fee_type.s_fee_trigger_cat%TYPE,
                             cp_v_s_fee_type1             igs_fi_fee_type.s_fee_type%TYPE,
                             cp_v_s_fee_type2             igs_fi_fee_type.s_fee_type%TYPE,
                             cp_v_s_fee_type3             igs_fi_fee_type.s_fee_type%TYPE,
                             cp_v_chk_spa_liable          VARCHAR2,
                             cp_v_s_relation_type1        igs_fi_fee_as_rate.s_relation_type%TYPE,
                             cp_v_s_relation_type2        igs_fi_fee_as_rate.s_relation_type%TYPE
                            ) IS
          SELECT fcflv.fee_type fee_type,
                 far.chg_rate chg_rate,
                 fcflv.fee_cal_type fee_cal_type,
                 igs_ca_gen_001.calp_get_alias_val(fcflv.start_dt_alias,
                                                   fcflv.start_dai_sequence_number,
                                                   fcflv.fee_cal_type,
                                                   fcflv.fee_ci_sequence_number
                                                   ) start_dt,
                 far.location_cd chg_rate_location_cd,
                 far.attendance_type chg_rate_attendance_type,
                 far.attendance_mode chg_rate_attendance_mode
          FROM   igs_en_stdnt_ps_att          spa,
                 igs_fi_f_cat_fee_lbl_v       fcflv,
                 igs_fi_fee_str_stat          fsst,
                 igs_fi_fee_as_rate           far,
                 igs_fi_fee_type              ft,
                 igs_fi_fee_as_rt             cfar
          WHERE  spa.person_id               = p_person_id
          AND    spa.course_cd               = p_course_cd
          AND    spa.fee_cat                 = fcflv.fee_cat
          AND    fcflv.fee_liability_status  = fsst.fee_structure_status
          AND    fsst.s_fee_structure_status = cp_v_s_fee_structure_status
          AND    fcflv.fee_type              = ft.fee_type
          AND    ft.closed_ind               = cp_v_closed_ind
          AND    ft.s_fee_trigger_cat       <> cp_v_s_fee_trigger_cat
          AND    ft.s_fee_type in (cp_v_s_fee_type1, cp_v_s_fee_type2, cp_v_s_fee_type3)
          AND    igs_fi_gen_001.check_stdnt_prg_att_liable (spa.person_id,
                      spa.course_cd,
                      spa.version_number,
                      spa.fee_cat,
                      fcflv.fee_type,
                      ft.s_fee_trigger_cat,
                      fcflv.fee_cal_type,
                      fcflv.fee_ci_sequence_number,
                      spa.adm_admission_appl_number,
                      spa.adm_nominated_course_cd,
                      spa.adm_sequence_number,
                      spa.commencement_dt,
                      spa.discontinued_dt,
                      spa.cal_type,
                      spa.location_cd,
                      spa.attendance_mode,
                      spa.attendance_type) = cp_v_chk_spa_liable
          AND   far.fee_type                                     = fcflv.fee_type
          AND   far.fee_cal_type                                 = fcflv.fee_cal_type
          AND   far.fee_ci_sequence_number                       = fcflv.fee_ci_sequence_number
          AND   (
                 (far.fee_cat = fcflv.fee_cat AND far.s_relation_type = cp_v_s_relation_type1)
                 OR
                 (far.fee_cat is NULL and far.s_relation_type = cp_v_s_relation_type2)
                 )
          AND   far.logical_delete_dt is NULL
          AND   NVL(far.location_cd (+), spa.location_cd)        = spa.location_cd
          AND   NVL(far.attendance_type (+),spa.attendance_type) = spa.attendance_type
          AND   NVL(far.attendance_mode (+),spa.attendance_mode) = spa.attendance_mode
          AND   NVL(far.course_cd (+), spa.course_cd)            = spa.course_cd
          AND   (
                 (cfar.person_id = spa.person_id AND cfar.course_cd = spa.course_cd AND cfar.fee_type <> fcflv.fee_type)
                  OR
                 (cfar.person_id <> spa.person_id AND cfar.course_cd <> spa.course_cd)
                 )
          UNION
          SELECT fcflv.fee_type fee_type,
                 far.chg_rate chg_rate,
                 fcflv.fee_cal_type fee_cal_type,
                 igs_ca_gen_001.calp_get_alias_val(fcflv.start_dt_alias,
                                                   fcflv.start_dai_sequence_number,
                                                   fcflv.fee_cal_type,
                                                   fcflv.fee_ci_sequence_number
                                                   ) start_dt,
                 far.location_cd chg_rate_location_cd,
                 far.attendance_type chg_rate_attendance_type,
                 far.attendance_mode chg_rate_attendance_mode
          FROM   igs_en_spa_terms          spt,
                 igs_en_stdnt_ps_att       spa,
                 igs_fi_f_cat_fee_lbl_v               fcflv,
                 igs_fi_fee_str_stat                  fsst,
                 igs_fi_fee_as_rate                   far,
                 igs_fi_fee_type                      ft,
                 igs_fi_fee_as_rt                     cfar
          WHERE  spt.person_id                = p_person_id
          AND   spt.program_cd               = p_course_cd
          AND   spt.person_id                = spa.person_id
          AND   spt.program_cd               = spa.course_cd
          AND   spt.fee_cat                  = fcflv.fee_cat
          AND   fcflv.fee_liability_status   = fsst.fee_structure_status
          AND   fsst.s_fee_structure_status = cp_v_s_fee_structure_status
          AND   fcflv.fee_type               = ft.fee_type
          AND   ft.closed_ind                = cp_v_closed_ind
          AND   ft.s_fee_trigger_cat       <> cp_v_s_fee_trigger_cat
          AND   ft.s_fee_type in (cp_v_s_fee_type1, cp_v_s_fee_type2, cp_v_s_fee_type3)
          AND   igs_fi_gen_001.check_stdnt_prg_att_liable (spt.person_id,
                      spt.program_cd,
                      spt.program_version,
                      spt.fee_cat,
                      fcflv.fee_type,
                      ft.s_fee_trigger_cat,
                      fcflv.fee_cal_type,
                      fcflv.fee_ci_sequence_number,
                      spa.adm_admission_appl_number,
                      spa.adm_nominated_course_cd,
                      spa.adm_sequence_number,
                      spa.commencement_dt,
                      spa.discontinued_dt,
                      spa.cal_type,
                      spt.location_cd,
                      spt.attendance_mode,
                      spt.attendance_type) = cp_v_chk_spa_liable
          AND   far.fee_type               = fcflv.fee_type
          AND   far.fee_cal_type           = fcflv.fee_cal_type
          AND   far.fee_ci_sequence_number = fcflv.fee_ci_sequence_number
          AND   (
                 (far.fee_cat = fcflv.fee_cat and far.s_relation_type = cp_v_s_relation_type1)
                 OR
                 (far.fee_cat is NULL and far.s_relation_type = cp_v_s_relation_type2)
                 )
          AND   far.logical_delete_dt is NULL
          AND   NVL(far.location_cd (+), spt.location_cd)        = spt.location_cd
          AND   NVL(far.attendance_type (+),spt.attendance_type) = spt.attendance_type
          AND   NVL(far.attendance_mode (+),spt.attendance_mode) = spt.attendance_mode
          AND   NVL(far.course_cd (+), spt.program_cd)           = spt.program_cd
          AND   (
                 (cfar.person_id = spt.person_id AND cfar.course_cd = spt.program_cd AND cfar.fee_type <> fcflv.fee_type)
                 OR
                 (cfar.person_id <> spt.person_id AND cfar.course_cd <> spt.program_cd)
                )
          ORDER BY 1,4;


BEGIN
        p_message_name := Null;
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_commencement_dt IS NULL OR
                        p_completion_dt IS NULL THEN
          -- Replaced message IGS_GE_INVALID_VALUE with IGS_FI_PARAMETER_NULL
          Fnd_Message.Set_Name ('IGS', 'IGS_FI_PARAMETER_NULL');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception(Null, Null, fnd_message.get);
        END IF;
        v_previous_fee_type := NULL;
        FOR v_scafcflrv_rec IN c_scafcflrv('ACTIVE','N','INSTITUTN','OTHER','TUTNFEE','TUITION','TRUE','FCFL','FTCI') LOOP
                v_rec_found := TRUE;
                IF v_previous_fee_type IS NULL OR
                                v_previous_fee_type <> v_scafcflrv_rec.FEE_TYPE THEN
                                --Create a contract using the current default fee assessment rate
                        IF IGS_FI_GEN_003.finp_ins_cfar(
                                        p_person_id,
                                        p_course_cd,
                                        v_scafcflrv_rec.FEE_TYPE,
                                        v_scafcflrv_rec.start_dt,
                                        p_completion_dt,
                                        v_scafcflrv_rec.chg_rate_location_cd,
                                        v_scafcflrv_rec.chg_rate_attendance_type,
                                        v_scafcflrv_rec.chg_rate_attendance_mode,
                                        v_scafcflrv_rec.chg_rate,
                                        'N',
                                        p_message_name) = FALSE THEN
                                v_exit_loop := TRUE;
                                EXIT;
                        END IF;
                END IF;
                v_previous_fee_type := v_scafcflrv_rec.FEE_TYPE;
        END LOOP;
        IF v_rec_found = FALSE THEN
                p_message_name := 'IGS_FI_NO_CONTRACT_FEE_RATES';
                RETURN FALSE;
        END IF;
        IF v_exit_loop THEN
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_scafcflrv%ISOPEN THEN
                        CLOSE c_scafcflrv;
                END IF;
                RAISE;
END;
 EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_GEN_004.FINP_PRC_CFAR');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END finp_prc_cfar;
--
PROCEDURE finp_prc_disb_jnl(
  errbuf  out NOCOPY varchar2,
  retcode out NOCOPY NUMBER,
  p_fin_period IN VARCHAR2 ,
  p_fee_period IN VARCHAR2,
  p_fee_type IN IGS_FI_FEE_TYPE_all.fee_type%TYPE ,
  p_snapshot_create_dt_C IN DATE,
  p_income_type IN VARCHAR2 ,
  p_ignore_prior_journals IN CHAR ,
  p_percent_disbursement IN NUMBER,
  p_org_id NUMBER
) AS
BEGIN
        retcode:=0;

-- As per SFCR005, this concurrent program is obsolete and if the user
-- tries to run this program then an error message should be logged into the log
-- file that the concurrent program is obsolete and should not be run.
   FND_MESSAGE.Set_Name('IGS',
                        'IGS_GE_OBSOLETE_JOB');
   FND_FILE.Put_Line(FND_FILE.Log,
                     FND_MESSAGE.Get);
EXCEPTION
  WHEN OTHERS THEN
        RETCODE:=2;
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END finp_prc_disb_jnl;
--
PROCEDURE finp_prc_disb_snpsht(
  errbuf  out  NOCOPY varchar2,
  retcode out  NOCOPY NUMBER,
  p_fin_period IN VARCHAR2,
  p_fee_period IN VARCHAR2,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE,
  p_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE,
  p_org_id NUMBER
) AS
BEGIN
        retcode:=0;
-- As per SFCR005, this concurrent program is obsolete and if the user
-- tries to run this program then an error message should be logged into the log
-- file that the concurrent program is obsolete and should not be run.
   FND_MESSAGE.Set_Name('IGS',
                        'IGS_GE_OBSOLETE_JOB');
   FND_FILE.Put_Line(FND_FILE.Log,
                     FND_MESSAGE.Get);
EXCEPTION
  WHEN OTHERS THEN
        RETCODE:=2;
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END finp_prc_disb_snpsht;
--
PROCEDURE finp_prc_enr_fa_todo(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY number,
  P_FEE_CAL IN VARCHAR2 ,
  p_org_id NUMBER,
  p_d_gl_date IN VARCHAR2
) AS

/* Who                 When                    What
   pathipat            30-Sep-2005             Bug 4570538: FEE ASSESSMENTS FROM TO DO ENTRIES IGNORES PARM FEE ASSESSMENT PERIOD
                                               Modified logic to invoke finp_prc_fa_ref_todo
   shtatiko            29-JUL-2004             Bug# 2734512, Modified message handling.
   shtatiko            25-NOV-2003             Bug# 3230754, Modified finp_prc_fa_ref_todo. Added check for logical delete date is
                                               added in cursor c_get_todo_ref_csr's where clause.
   shtatiko            18-NOV-2003             Enh# 3117341, Added check for profile 'IGS: Charge tuition for Audited Student Attempt'
   shtatiko            08-MAY-2003             Enh# 2831569, Added Check for Manage Accounts System Option before running the process.
   shtatiko            30-JAN-2003             Bug# 2765239, Replaced IGS_GE_INVALID_VALUE with more meaningful messages.
   vchappid            21-Jan-2003             Bug#2711202, for the in-out variable for p_creation_dt parameter in the fee assessment call
                                               should be passed as v_creation_dt which is defined in the Main Procedure Call instead of the
                                               local variable defined in the local procedure finp_prc_fa_ref_todo
   vchappid            02-Jan-2003             Bug#2727402, Unhandled Exception should not occur when GL Date passed is invalid
   vchappid            21-May-2002             Bug#2374754, removed the clause 'for update NOWAIT' form the cursor c_get_todo_ref_csr
                                               in the local procedure finp_prc_fa_ref_todo, removed the commented code,
                                               In the fee assessment call process mode parameter is incorrectly passed as NULL,
                                               'ACTUAL' is passed instead of NULL, re-initialized the process next record variable
                                               to FASLE, it might have been set to TRUE while processing the previously fetched record
*/

        p_fee_cal_type                  igs_ca_inst.cal_type%TYPE ;
        p_fee_ci_sequence_num           igs_ca_inst.sequence_number%TYPE ;

        l_v_message_name    fnd_new_messages.message_name%TYPE;
        l_v_manage_accounts igs_fi_control.manage_accounts%TYPE;
        l_n_waiver_amount   NUMBER;

BEGIN   -- finp_prc_enr_fa_todo
        -- Module to control processing fee assessments from entries in the student
        -- todo table
        --Block for Parameter Validation/Splitting of Parameters

        igs_ge_gen_003.set_org_id(p_org_id);

        retcode:=0;
        BEGIN
          p_fee_cal_type          := RTRIM(SUBSTR(p_fee_cal, 102, 10));
          p_fee_ci_sequence_num   := TO_NUMBER(LTRIM(SUBSTR(p_fee_cal, 113, 8)));

          -- Get the value of "Manage Accounts" System Option value.
          -- If this value is NULL then this process cannot run. Added as part of Enh# 2831569.
          igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                        p_v_message_name => l_v_message_name );
          IF l_v_manage_accounts IS NULL THEN
            fnd_message.set_name ( 'IGS', l_v_message_name );
            fnd_file.put_line (fnd_file.log, ' ');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
            fnd_file.put_line (fnd_file.log, ' ');
            retcode :=2;
            RETURN;
          END IF;

        END;
        --End of Block for Parameter Validation/Splitting of Parameters
DECLARE
        cst_fee_recalc                  CONSTANT VARCHAR2(10) := 'FEE_RECALC';
        v_dummy                         VARCHAR2(1);
        v_record_found                  BOOLEAN := FALSE;
        v_creation_dt                   DATE;
        v_message_name                  VARCHAR2(30);
        l_rpt_person_id                 hz_parties.party_id%TYPE;
        l_return_status                 VARCHAR2(1);
        l_msg_data                      fnd_new_messages.message_name%TYPE;
        l_fee_cal_type                  igs_ca_inst.cal_type%TYPE;
        l_fee_ci_sequence_number        igs_ca_inst.sequence_number%TYPE;
        l_d_gl_date                     DATE;
        l_c_closing_status              igs_fi_gl_periods_v.closing_status%TYPE;
        l_n_msg_count                   NUMBER(10);
        l_v_msg_data                    VARCHAR2(1000);

        l_v_include_audit VARCHAR2(1);
        l_v_message                     fnd_new_messages.message_name%TYPE;
        l_v_load_cal_type               igs_ca_inst_all.cal_type%TYPE;
        l_n_load_ci_seq_num             igs_ca_inst_all.sequence_number%TYPE;

        CURSOR c_fee_cal_instance (
                        cp_fee_cal_type IGS_FI_F_TYP_CA_INST.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number IGS_FI_F_TYP_CA_INST.fee_ci_sequence_number%TYPE)
        IS
                SELECT  'x'
                FROM    IGS_FI_F_TYP_CA_INST ftci
                WHERE   ftci.fee_cal_type               = cp_fee_cal_type AND
                        ftci.fee_ci_sequence_number     = cp_fee_ci_sequence_number;
        -- Modified the cursor
        -- removed the 'DISTINCT' clause, added for update of clause
        CURSOR c_student_todo IS
                SELECT  std.rowid,
                        std.person_id,
                        std.s_student_todo_type,
                        std.sequence_number,
                        std.todo_dt
                FROM    IGS_PE_STD_TODO std
                WHERE   std.s_student_todo_type = cst_fee_recalc AND
                        std.logical_delete_dt IS NULL
                ORDER BY std.person_id;

        -- Cursor to check if all REF records have been processed
        CURSOR cur_chk_todo_ref(cp_n_person_id    igs_pe_std_todo_ref.person_id%TYPE,
                                cp_v_todo_type    igs_pe_std_todo_ref.s_student_todo_type%TYPE,
                                cp_n_seq_num      igs_pe_std_todo_ref.sequence_number%TYPE) IS
           SELECT 'x'
           FROM igs_pe_std_todo_ref
           WHERE person_id = cp_n_person_id
           AND s_student_todo_type = cp_v_todo_type
           AND sequence_number = cp_n_seq_num
           AND logical_delete_dt IS NULL;

        l_v_todo_ref_exists    VARCHAR2(1);


        PROCEDURE finp_prc_fa_ref_todo(
          p_person_id IN hz_parties.party_id%TYPE,
          p_sequence_number IN igs_pe_std_todo_ref.sequence_number%TYPE,
          p_fee_cal_type IN igs_pe_std_todo_ref.cal_type%TYPE,
          p_fee_ci_sequence_number IN igs_pe_std_todo_ref.ci_sequence_number%TYPE,
          x_return_status OUT NOCOPY VARCHAR2,
          x_msg_data OUT NOCOPY VARCHAR2,
          p_v_load_cal_type   IN  igs_ca_inst_all.cal_type%TYPE,
          p_n_load_ci_seq_num IN  igs_ca_inst_all.sequence_number%TYPE
          ) AS
          /*************************************************************
          Who         When         What

          pathipat    30-Sep-2005  Bug 4570538: FEE ASSESSMENTS FROM TO DO ENTRIES
                                   IGNORES PARM FEE ASSESSMENT PERIOD
                                   Modified cursor c_get_todo_ref_csr to add join with
                                   cal_type and sequence_number
          **************************************************************/

        rpt_load_cal_type               igs_ca_inst.cal_type%TYPE;
        rpt_load_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
        l_message                       fnd_new_messages.message_name%TYPE;
        l_message_name                  fnd_new_messages.message_name%TYPE;
        l_n_waiver_amount               NUMBER;
        l_v_person_number               hz_parties.party_number%TYPE;

        CURSOR c_get_todo_ref_csr(cp_person_id           igs_pe_std_todo_ref.person_id%TYPE,
                                  cp_sequence_number     igs_pe_std_todo_ref.sequence_number%TYPE,
                                  cp_v_load_cal_type     igs_ca_inst_all.cal_type%TYPE,
                                  cp_n_load_ci_seq_num   igs_ca_inst_all.sequence_number%TYPE ) IS
          SELECT rowid,
                 person_id,
                 s_student_todo_type,
                 sequence_number,
                 reference_number,
                 cal_type,
                 ci_sequence_number,
                 course_cd,
                 unit_cd,
                 other_reference,
                 logical_delete_dt,
                 uoo_id
          FROM   igs_pe_std_todo_ref
          WHERE  person_id = cp_person_id
          AND    sequence_number = cp_sequence_number
          AND    s_student_todo_type = cst_fee_recalc
          AND    (cal_type = cp_v_load_cal_type OR cp_v_load_cal_type IS NULL)
          AND    (ci_sequence_number = cp_n_load_ci_seq_num OR cp_n_load_ci_seq_num IS NULL)
          AND    logical_delete_dt IS NULL -- Added this as part of Bug# 3230754
          ORDER BY cal_type, ci_sequence_number;

        BEGIN   -- finp_prc_fa_ref_todo
                -- Local procedure to reduce the possbility of Self Service version of fee
                -- assessment from todo process igs_fi_ss_acct_payment.finp_calc_fees_todo
                -- (IGSFI63B.pls) to experience a lock from the todo reference table.

         -- Initialize return status
           x_return_status := FND_API.G_RET_STS_SUCCESS;

         -- Initialize the repeat variable
           rpt_load_cal_type := 'NULL';
           rpt_load_ci_sequence_number := 0;

           FOR lp_todo_ref_rec IN c_get_todo_ref_csr(p_person_id,
                                                     p_sequence_number,
                                                     p_v_load_cal_type,
                                                     p_n_load_ci_seq_num) LOOP

             BEGIN
               IF (rpt_load_cal_type <> lp_todo_ref_rec.cal_type) OR
                 (rpt_load_ci_sequence_number <> lp_todo_ref_rec.ci_sequence_number) THEN

                  l_v_person_number := igs_fi_gen_008.get_party_number(p_person_id);
                  fnd_file.put_line(fnd_file.log,'');
                  fnd_file.put(fnd_file.log, l_v_person_number||': ');

                 -- get FCI from LCI
                  IF (p_v_load_cal_type IS NULL AND p_n_load_ci_seq_num IS NULL ) THEN
                        IF igs_fi_gen_001.finp_get_lfci_reln(p_cal_type                  => lp_todo_ref_rec.cal_type,
                                                             p_ci_sequence_number        => lp_todo_ref_rec.ci_sequence_number,
                                                             p_cal_category              => 'LOAD',
                                                             p_ret_cal_type              => l_fee_cal_type,
                                                             p_ret_ci_sequence_number    => l_fee_ci_sequence_number,
                                                             p_message_name              => l_message) = FALSE THEN
                              -- Code to add to stack has been added as part of 2734512
                              fnd_message.set_name('IGS',l_message);
                              igs_ge_msg_stack.add;
                              x_msg_data := l_message;
                              RAISE fnd_api.g_exc_error;
                         END IF;
                  ELSE
                     l_fee_cal_type := p_fee_cal_type;
                     l_fee_ci_sequence_number := p_fee_ci_sequence_number;
                  END IF;
                  -- Bug# 3230754, Removed check for Logical Delete Date as that is added in the cursor itself.
                  -- Call the Fee Assessment routine
                  fnd_msg_pub.initialize; -- Added as part of 2734512

                  IF (igs_fi_prc_fee_ass.finp_ins_enr_fee_ass(
                                      p_effective_dt                  => SYSDATE,
                                      p_person_id                     => p_person_id,
                                      p_course_cd                     => NULL,
                                      p_fee_category                  => NULL,
                                      p_fee_cal_type                  => l_fee_cal_type,
                                      p_fee_ci_sequence_num           => l_fee_ci_sequence_number,
                                      p_fee_type                      => NULL,
                                      p_trace_on                      => 'N',
                                      p_test_run                      => 'N',
                                      p_creation_dt                   => v_creation_dt,
                                      p_message_name                  => l_message_name,
                                      p_process_mode                  => 'ACTUAL',
                                      p_c_career                      => NULL,
                                      p_d_gl_date                     => l_d_gl_date,
                                      p_v_wav_calc_flag               => 'N',
                                      p_n_waiver_amount               => l_n_waiver_amount) = FALSE) THEN
                               fnd_message.set_name ('IGS', l_message_name);
                               IF l_message_name = 'IGS_FI_NO_CENSUS_DT_SETUP' THEN
                                 fnd_message.set_token('ALT_CD', igs_fi_prc_fee_ass.g_v_load_alt_code);
                               END IF;
                               igs_ge_msg_stack.add;
                               x_msg_data := l_message_name;
                               RAISE FND_API.G_EXC_ERROR;
                  ELSE
                               -- If call is success, action off child record
                               igs_pe_std_todo_ref_pkg.update_row(
                                  x_rowid                     => lp_todo_ref_rec.rowid,
                                  x_person_id                 => lp_todo_ref_rec.person_id ,
                                  x_s_student_todo_type       => lp_todo_ref_rec.s_student_todo_type ,
                                  x_sequence_number           => lp_todo_ref_rec.sequence_number ,
                                  x_reference_number          => lp_todo_ref_rec.reference_number,
                                  x_cal_type                  => lp_todo_ref_rec.cal_type,
                                  x_ci_sequence_number        => lp_todo_ref_rec.ci_sequence_number,
                                  x_course_cd                 => lp_todo_ref_rec.course_cd,
                                  x_unit_cd                   => lp_todo_ref_rec.unit_cd,
                                  x_other_reference           => lp_todo_ref_rec.other_reference,
                                  x_logical_delete_dt         => SYSDATE,
                                  x_mode                      => 'R',
                                  x_uoo_id                    => lp_todo_ref_rec.uoo_id
                               );

                               fnd_file.put_line(fnd_file.log, fnd_message.get_string('IGS','IGS_FI_SUCC_TODO_REC'));

                   END IF;            -- End if for core fee asssessment routine
               END IF;                  -- End if for repeat load calendar record

             -- Assignment of repeat indicator variables
             rpt_load_cal_type          := lp_todo_ref_rec.cal_type;
             rpt_load_ci_sequence_number:= lp_todo_ref_rec.ci_sequence_number;

           EXCEPTION
             WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
             WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
           END;
         END LOOP;      -- End of the loop for the child record

         COMMIT;

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            l_msg_data := 'IGS_GE_UNHANDLED_EXCEPTION';
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_file.put_line(fnd_file.log,substr(sqlerrm,1,300));

        END finp_prc_fa_ref_todo;       -- end of local procedure

  BEGIN

        l_rpt_person_id := 0;
        -- Main Begin of the public procedure finp_prc_enr_fa_todo
        -- Validate parameters
        IF(p_fee_cal_type IS NOT NULL) THEN
                FOR v_fee_cal_instance_rec IN c_fee_cal_instance(
                                                                        p_fee_cal_type,
                                                                        p_fee_ci_sequence_num) LOOP
                        v_record_found := TRUE;
                END LOOP;
                IF(v_record_found = FALSE) THEN
                  -- Replaced IGS_GE_INVALID_VALUE with IGS_FI_INVALID_PARAMETER, Bug# 2765239
                  fnd_message.set_name('IGS', 'IGS_FI_INVALID_PARAMETER' );
                  fnd_message.set_token('PARAMETER', igs_ge_gen_004.genp_get_lookup ( 'IGS_FI_LOCKBOX', 'FEE_CAL_TYPE') );
                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                  RETURN;
                ELSE
                        v_record_found := FALSE;
                END IF;
        END IF;

        -- When the Gl-Date parameter is not null then do the validation for checking the period status.
        -- If the period status is not in Open or Future periods then error out
        -- when the procedure returns a message name it is presumed as if an error has occurred
        -- show the message name that is returned from the general procedure and error out.
        IF p_d_gl_date IS NOT NULL THEN
          l_d_gl_date := igs_ge_date.igsdate(p_d_gl_date);
          igs_fi_gen_gl.get_period_status_for_date(p_d_date => l_d_gl_date,
                                                   p_v_closing_status => l_c_closing_status,
                                                   p_v_message_name => v_message_name);
          IF v_message_name IS NOT NULL THEN
            fnd_message.set_name('IGS', v_message_name);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            retcode :=2;
            RETURN;
          ELSIF  l_c_closing_status NOT IN ('O','F') THEN
            fnd_message.set_name('IGS', 'IGS_FI_INVALID_GL_DATE');
            fnd_message.set_token('GL_DATE',l_d_gl_date);
            fnd_file.put_line (fnd_file.log, fnd_message.get);
            retcode :=2;
            RETURN;
          END IF;
        ELSE
          fnd_message.set_name('IGS', 'IGS_UC_NO_MANDATORY_PARAMS');
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          retcode :=2;
          RETURN;
        END IF;

        -- Obtain the value of the profile 'IGS: Charge tuition for Audited Student Attempt'
        -- If this is not defined, then log error message
        -- Added as part of Enh# 3117341, Audit Special Fees.
        l_v_include_audit := fnd_profile.value('IGS_FI_CHARGE_AUDIT_FEES');
        IF l_v_include_audit IS NULL THEN
          fnd_message.set_name('IGS', 'IGS_FI_SP_FEE_NO_PROFILE');
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          retcode :=2;
          RETURN;
        END IF;

        IF (p_fee_cal IS NOT NULL) THEN
             IF igs_fi_gen_001.finp_get_lfci_reln (p_cal_type                  => p_fee_cal_type,
                                                   p_ci_sequence_number        => p_fee_ci_sequence_num,
                                                   p_cal_category              => 'FEE',
                                                   p_ret_cal_type              => l_v_load_cal_type,
                                                   p_ret_ci_sequence_number    => l_n_load_ci_seq_num,
                                                   p_message_name              => l_v_message) = FALSE THEN
                  fnd_message.set_name ('IGS', l_v_message);
                  igs_ge_msg_stack.add;
                  RAISE fnd_api.g_exc_error;
              END IF;
        ELSE
              l_v_load_cal_type := NULL;
              l_n_load_ci_seq_num := NULL;
        END IF;

        -- Call fee assessment routine from todo entries
        FOR v_student_todo_rec IN c_student_todo LOOP

           -- Must perform a commit or rollback before calling fee assessment routine
           COMMIT;

           -- Check to filter the same person id records in the loop
           IF (l_rpt_person_id <> v_student_todo_rec.person_id) THEN
                -- assignment of repeat variable rpt_person_id
                l_rpt_person_id := v_student_todo_rec.person_id;
                -- Call the new local procedure finpl_prc_fa_ref_todo
                BEGIN
                           finp_prc_fa_ref_todo( p_person_id                 => v_student_todo_rec.person_id,
                                                 p_sequence_number           => v_student_todo_rec.sequence_number,
                                                 p_fee_cal_type              => p_fee_cal_type,
                                                 p_fee_ci_sequence_number    => p_fee_ci_sequence_num,
                                                 x_return_status             => l_return_status,
                                                 x_msg_data                  => l_msg_data,
                                                 p_v_load_cal_type           => l_v_load_cal_type,
                                                 p_n_load_ci_seq_num         => l_n_load_ci_seq_num);
                 EXCEPTION
                   WHEN OTHERS THEN
                      fnd_file.put_line(fnd_file.log,SUBSTR(SQLERRM,1,300));
                 END;

                 IF l_return_status = fnd_api.g_ret_sts_error THEN
                    -- Bug# 2734512, Added following message handling
                    igs_ge_msg_stack.conc_exception_hndl;
                    IF (l_msg_data IS NULL) THEN
                        fnd_msg_pub.count_and_get( p_count  => l_n_msg_count,
                                                   p_data   => l_v_msg_data);
                        IF l_n_msg_count = 1 THEN
                             fnd_message.set_encoded(l_v_msg_data);
                             fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
                        ELSIF l_n_msg_count > 1 THEN
                             FOR l_var IN 1 .. l_n_msg_count LOOP
                                fnd_message.set_encoded(fnd_msg_pub.get);
                                fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
                             END LOOP;
                        END IF;
                    END IF;
                END IF;
              END IF;   -- End if for repeat person id check

              -- Clear the todo entries for the current IGS_PE_PERSON by setting the logical
              -- delete date
              -- NOTE that multiple todo entries may exist for the same IGS_PE_PERSON, they are
              -- all updated.

              -- Check if all child TODO_REF records have been updated before updating the parent TODO record.
              -- If any TODO_REF record is still not actioned off, then parent should not be updated.
              OPEN cur_chk_todo_ref(v_student_todo_rec.person_id, 'FEE_RECALC', v_student_todo_rec.sequence_number);
              FETCH cur_chk_todo_ref INTO l_v_todo_ref_exists;
              IF cur_chk_todo_ref%NOTFOUND THEN
                  CLOSE cur_chk_todo_ref;
                  BEGIN
                    igs_pe_std_todo_pkg.update_row(
                            x_rowid                     => v_student_todo_rec.rowid,
                            x_person_id                 => v_student_todo_rec.person_id ,
                            x_s_student_todo_type       => v_student_todo_rec.s_student_todo_type ,
                            x_sequence_number           => v_student_todo_rec.sequence_number ,
                            x_todo_dt                   => v_student_todo_rec.todo_dt ,
                            x_logical_delete_dt         => SYSDATE,
                            x_mode                      => 'R');
                  EXCEPTION
                    WHEN OTHERS THEN
                      FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET_STRING ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION'));
                      FND_FILE.Put_Line(FND_FILE.Log,substr(sqlerrm,1,300));
                  END;
                   -- assignment of repeat variable rpt_person_id
                  l_rpt_person_id := v_student_todo_rec.person_id;
              ELSE
                 CLOSE cur_chk_todo_ref;
              END IF;
            END LOOP;   -- End loop for header

          COMMIT;

          RETURN;

EXCEPTION
  WHEN OTHERS THEN
        RETCODE:=2;
        FND_FILE.Put_Line(FND_FILE.Log,substr(sqlerrm,1,300));
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END;
END finp_prc_enr_fa_todo;
--

--Removed the IN parameter p_predictive_ass_ind from the procedure finp_prc_enr_fee_ass.
PROCEDURE finp_prc_enr_fee_ass(
  errbuf  OUT NOCOPY  VARCHAR2,
  retcode OUT NOCOPY  NUMBER,
  p_person_id IN VARCHAR2,
  p_person_grp_id IN VARCHAR2,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_fee_cal   IN VARCHAR2,
  p_fee_category IN IGS_EN_STDNT_PS_ATT_ALL.FEE_CAT%TYPE,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE,
  p_trace_on IN VARCHAR2,
  p_test_run IN VARCHAR2,
  p_org_id    NUMBER,
  p_process_mode IN VARCHAR2,
  p_c_career      IN igs_ps_ver.course_type%TYPE,
  p_d_gl_date     IN VARCHAR2,
  p_comments IN  VARCHAR2
  ) AS

/* Who       When           What
   abshriva  22-JUN-2006  Bug  5070074 Modified code handling condition when trace_on,test_run and gl_date is null
   abshriva  04-May-2006   Bug 5178077: Introduced igs_ge_gen_003.set_org_id
   abshriva  05-DEC-2005   Bug 4721566 Made the code modification so that log message corresponding to Test Run
                           parameter 'Yes' is displayed in log file
   abshriva  05-DEC-2005    Bug:4701695 Made the code modification so that 'Fee calculation method' and 'term'message
                            is displayed only once in log file  on execution of 'Process Fee Assessment'
   shtatiko  03-JAN-2004    Enh# 3167098, Providing Persin Id or Person Group is made mandatory. Initial and Combined Processing
                            modes are made functionally obsolete.
   uudayapr  15-dec-2003    Bug#3080983   Modified the Cursor c_fee_ass_debt to select data from IGS_FI_FEE_AS instead of
                            IGS_FI_FEE_ASS_DEBT_V .
   shtatiko  18-NOV-2003    Enh# 3117341, Added check for profile 'IGS: Charge tuition for Audited Student Attempt'
   pathipat  04-Nov-2003    Bug: 3151102 - Removed conditions before setting p_create_dt to v_create_dt
   pathipat  17-Oct-2003    Bug: 3151102 - Added begin-end block for exception handling
   pathipat  07-Oct-2003    Bug 3122652 - Logged messg IGF_AP_INVALID_QUERY if any error occurs
                            while obtaining the dynamic sql for the person id group, added validation for
                            person id group
   pathipat  23-Sep-2003    Bug: 3151102 - Called finp_ins_enr_fee_ass in a begin-end block
                            with exception handling when called for a Person ID Group.
   pathipat  09-Sep-2003    Bug 3122652: Replaced call to igf_ap_ss_pkg.get_pid() with
                            call to igs_pe_dynamic_persid_group.igs_get_dynamic_sql()
                            Increased length of l_dynamic_sql to 32767 from 2000
   shtatiko  28-APR-2003    Enh# 2831569, Added check for Manage Accounts System Option.
                                          Implemeted Dynamic Person Group feature for group id parameter.
   shtatiko  30-JAN-2003    Bug# 2765239, Replaced IGS_GE_INVALID_VALUE message with more meaningful messages
   vchappid  06-Jan-2003    Bug# 2660155, Modified code to identify distinct persons when user don't provide
                            Person Id or Person ID Group as an input value to the request.
*/
  -- prameters process mode , init process prior calendar instance
  -- and person id group have been added as a part
  -- of the build for fee calc undertaken in July 2001.
  -- Bug# 1851586

BEGIN   -- finp_prc_enr_fee_ass
        -- Module to control processing fee assessments

DECLARE
        v_message_name                  VARCHAR2(30);
        v_record_found                  BOOLEAN := FALSE;
        v_create_dt                     DATE;
        l_c_closing_status              igs_fi_gl_periods_v.closing_status%TYPE;
        l_n_person_id                   hz_parties.party_id%TYPE;
        l_v_fee_cal_type                igs_ca_inst_all.cal_type%TYPE;
        l_n_fee_ci_sequence_number      igs_ca_inst_all.sequence_number%TYPE;
        l_n_person_grp_id               igs_pe_prsid_grp_mem_v.group_id%TYPE;
        l_d_gl_date                     DATE;
        l_v_load_cal_type                igs_ca_inst_all.cal_type%TYPE;
        l_n_load_ci_sequence_number      igs_ca_inst_all.sequence_number%TYPE;
        l_b_fci_lci                      BOOLEAN := FALSE;
        l_org_id                         VARCHAR2(15);

        CURSOR c_fee_cal_instance (
                cp_fee_type                     IGS_FI_F_TYP_CA_INST.FEE_TYPE%TYPE,
                cp_fee_cal_type                 IGS_FI_F_TYP_CA_INST.fee_cal_type%TYPE,
                cp_fee_ci_sequence_number
                                                IGS_FI_F_TYP_CA_INST.fee_ci_sequence_number%TYPE) IS
                SELECT  'x'
                FROM    IGS_FI_F_TYP_CA_INST ftci
                WHERE   ftci.FEE_TYPE                   = cp_fee_type AND
                        ftci.fee_cal_type                       = cp_fee_cal_type AND
                        ftci.fee_ci_sequence_number     = cp_fee_ci_sequence_number;

        -- selecting the members of the given person id group such that the membership has not ended.
        -- Removed l_c_grp_members as Person Groups are implemented as Dynamic Groups as per Enh# 2831569.

        -- Record of person_id to get the values of
        TYPE person_grp_rec_type IS RECORD ( p_n_person_id igs_pe_prsid_grp_mem.person_id%TYPE );
        rec_person_grp person_grp_rec_type;

        -- REF CURSOR for dynamic person group.
        TYPE person_grp_ref_cur_type IS REF CURSOR;
        c_ref_person_grp person_grp_ref_cur_type;
        l_dynamic_sql VARCHAR2(32767);
        l_v_status    VARCHAR2(10);

        l_v_message_name    fnd_new_messages.message_name%TYPE;
        l_v_manage_accounts igs_fi_control.manage_accounts%TYPE;

        l_v_person_number       igs_fi_parties_v.person_number%TYPE := NULL;

          CURSOR cur_pers_grp(cp_n_pers_grp_id   igs_pe_persid_group_all.group_id%TYPE) IS
            SELECT 'x'
            FROM   igs_pe_persid_group_all
            WHERE  group_id = cp_n_pers_grp_id
            AND    TRUNC(create_dt) <= g_d_sysdate
            AND    NVL(closed_ind, g_v_ind_no) = g_v_ind_no;
          l_c_var     VARCHAR2(10) := NULL;

        l_v_include_audit VARCHAR2(1);
        l_v_wav_calc_flag VARCHAR2(1);
        l_n_waiver_amount NUMBER;

        CURSOR cur_wav_calc_flag ( cp_v_fee_cat igs_fi_f_cat_fee_lbl_all.fee_cat%TYPE,
                                     cp_v_fee_cal_type igs_fi_f_cat_fee_lbl_all.fee_cal_type%TYPE,
                                       cp_n_fee_ci_seq_num igs_fi_f_cat_fee_lbl_all.fee_ci_sequence_number%TYPE,
                                         cp_v_fee_type igs_fi_f_cat_fee_lbl_all.fee_type%TYPE) IS
          SELECT waiver_calc_flag
          FROM igs_fi_f_cat_fee_lbl_all
          WHERE fee_cat = cp_v_fee_cat OR cp_v_fee_cat IS NULL
          AND fee_cal_type = cp_v_fee_cal_type
          AND fee_ci_sequence_number = cp_n_fee_ci_seq_num
          AND fee_type = cp_v_fee_type;

          CURSOR cur_fee_calc_mthd
          IS
          SELECT fee_calc_mthd_code
          FROM   igs_fi_control;
          l_fee_calc_mthd_code igs_fi_control.fee_calc_mthd_code%TYPE;

BEGIN
  BEGIN
     l_org_id := NULL;
     igs_ge_gen_003.set_org_id(l_org_id);
  EXCEPTION
    WHEN OTHERS THEN
       fnd_file.put_line (fnd_file.log, fnd_message.get);
       retcode :=2;
       RETURN;
  END;
        retcode := 0;
        l_n_person_id                := TO_NUMBER(p_person_id);
        l_v_fee_cal_type             := RTRIM(SUBSTR(p_fee_cal,102,10));
        l_n_fee_ci_sequence_number   := TO_NUMBER(LTRIM(SUBSTR(p_fee_cal,113,8)));
        l_n_person_grp_id            := TO_NUMBER(p_person_grp_id);
        l_d_gl_date                  := igs_ge_date.igsdate(p_canonical_date => p_d_gl_date);


        -- Get the value of "Manage Accounts" System Option value.
        -- If this value is NULL then this process cannot run. Added as part of Enh# 2831569.
        igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                      p_v_message_name => l_v_message_name );
        IF l_v_manage_accounts IS NULL THEN
          fnd_message.set_name ( 'IGS', l_v_message_name );
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception (NULL, NULL, fnd_message.get);
        END IF;

        -- Validate parameters
        -- Process can take only one parameter between Person Number and Person Group ID. Added as part of Enh# 2831569.
        IF ( (l_n_person_id IS NOT NULL) AND (l_n_person_grp_id IS NOT NULL) ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_PRS_PRSIDGRP_NULL') ;
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception(null, null, fnd_message.get);
        END IF;

        -- Enh# 3167098, Either of the two parameters must be specified.
        IF l_n_person_id IS NULL AND
           l_n_person_grp_id IS NULL THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_PRS_PRSIDGRP_NULL') ;
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception(null, null, fnd_message.get);
        END IF;

        -- Validate the person id group
        IF l_n_person_grp_id IS NOT NULL THEN
           OPEN cur_pers_grp(l_n_person_grp_id);
           FETCH cur_pers_grp INTO l_c_var;
           IF cur_pers_grp%NOTFOUND THEN
              CLOSE cur_pers_grp;
              fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
              fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP'));
              igs_ge_msg_stack.ADD;
              app_exception.raise_exception(null, null, fnd_message.get);
           END IF;
           CLOSE cur_pers_grp;
        END IF;

        IF(p_trace_on IS NULL ) THEN
           fnd_file.new_line(fnd_file.log);
           fnd_message.set_name('IGS', 'IGS_FI_INVALID_PARAMETER');
           fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'TRACE_ON'));
           fnd_file.put_line (fnd_file.log, fnd_message.get);
           fnd_file.new_line(fnd_file.log);
           retcode:=2;
        RETURN;
        END IF;

        IF( p_test_run IS NULL ) THEN
          fnd_file.new_line(fnd_file.log);
          fnd_message.set_name('IGS', 'IGS_FI_INVALID_PARAMETER');
          fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'TEST_RUN'));
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          retcode:=2;
        RETURN;
        END IF;

        IF( l_d_gl_date IS NULL ) THEN
          fnd_file.new_line(fnd_file.log);
          fnd_message.set_name('IGS', 'IGS_FI_INVALID_PARAMETER');
          fnd_message.set_token('PARAMETER', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'GL_DATE'));
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          retcode:=2;
          RETURN;
        END IF;

          -- ensuring that fee calendar instance is not null as a change implemented in
          -- fee calc build july-2001 (bug: 1851586)
        IF l_v_fee_cal_type IS NULL OR l_n_fee_ci_sequence_number IS NULL THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_FI_PARAMETER_NULL');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception(Null, Null, fnd_message.get);
          RETURN;
        END IF;

        -- Added as part of Tuition Waivers.
        IF (p_fee_type IS NOT NULL) THEN
          OPEN cur_wav_calc_flag( p_fee_category, l_v_fee_cal_type, l_n_fee_ci_sequence_number, p_fee_type );
          FETCH cur_wav_calc_flag INTO l_v_wav_calc_flag;
          CLOSE cur_wav_calc_flag;
          IF (l_v_wav_calc_flag = 'Y') THEN
            fnd_message.set_name('IGS', 'IGS_FI_WAV_FEE_TYPE');
            igs_ge_msg_stack.add;
            app_exception.raise_exception(Null, Null, fnd_message.get);
            RETURN;
          END IF;
        END IF;

        -- When the Gl-Date parameter is not null then do the validation for checking the period status.
        -- If the period status is not in Open or Future periods then error out
        -- when the procedure returns a message name it is presumed as if an error has occurred
        -- show the message name that is returned from the general procedure and error out.
        igs_fi_gen_gl.get_period_status_for_date(p_d_date => l_d_gl_date,
                                                 p_v_closing_status => l_c_closing_status,
                                                 p_v_message_name => v_message_name);
        IF v_message_name IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('IGS', v_message_name);
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        ELSIF  l_c_closing_status NOT IN ('O','F') THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_INVALID_GL_DATE');
          FND_MESSAGE.SET_TOKEN('GL_DATE',l_d_gl_date);
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

        -- validate fee assessment period
        IF (l_v_fee_cal_type IS NOT NULL AND
                p_fee_type IS NOT NULL) THEN
                FOR v_fee_cal_instance_rec IN c_fee_cal_instance(
                                                                p_fee_type,
                                                                l_v_fee_cal_type,
                                                                l_n_fee_ci_sequence_number) LOOP
                        v_record_found := TRUE;
                END LOOP;
                IF(v_record_found = FALSE) THEN
                  Fnd_Message.Set_Name ('IGS', 'IGS_FI_NO_FEE_CAL_INS');
                  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception(Null, Null, fnd_message.get);
                  RETURN;
                ELSE
                  v_record_found := FALSE;
                END IF;
        END IF;

        --Added the value 'PREDICTIVE' in the valid list of values the parameter
        --p_process_mode should have.

        -- validating for the new parameters added as a part of the fee clac build in july-2001
        -- validate that p_process_mode is not null and have only one of the defined values.
        -- fee calc build july-2001 (bug: 1851586)

        -- Enh# 3167098, Removed INITIAL and COMBINED modes.
        IF NVL(p_process_mode, 'NULL') NOT IN ('ACTUAL', 'PREDICTIVE') THEN
          fnd_message.set_name('IGS', 'IGS_FI_INVALID_PARAMETER' );
          fnd_message.set_token('PARAMETER', igs_ge_gen_004.genp_get_lookup ( 'IGS_FI_LOCKBOX', 'PROCESS_MODE' ) );
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception(Null, Null, fnd_message.get);
          RETURN;
        END IF;

        -- Obtain the value of the profile 'IGS: Charge tuition for Audited Student Attempt'
        -- If this is not defined, then log error message
        -- Added as part of Enh# 3117341, Audit Special Fees.
        l_v_include_audit := fnd_profile.value('IGS_FI_CHARGE_AUDIT_FEES');
        IF l_v_include_audit IS NULL THEN
          fnd_message.set_name('IGS', 'IGS_FI_SP_FEE_NO_PROFILE');
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception(null, null, fnd_message.get);
        END IF;

        fnd_file.new_line(fnd_file.log);
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'RUN_COMMENT') || ': ' || p_comments);
        fnd_message.set_name('IGS', 'IGS_FI_PERSON_NUM');
        IF l_n_person_id IS NOT NULL THEN
           fnd_message.set_token('PERSON_NUM',igs_fi_gen_008.get_party_number(l_n_person_id));
        ELSE
           fnd_message.set_token('PERSON_NUM',l_n_person_id);
        END IF;
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_ACCT_ENTITIES', 'PS') || ': ' || p_course_cd);
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_ASS_PERIOD') || ': ' || SUBSTR(p_fee_cal,1,40));
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_CAT') || ': ' || p_fee_category);
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_TYPE') || ': ' || p_fee_type);
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'TRACE_ON') || ': ' || igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_trace_on));
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'TEST_RUN') || ': ' || igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_test_run));
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'PROCESS_MODE') || ': ' || igs_fi_gen_gl.get_lkp_meaning('IGS_FI_PROCESS_MODE', p_process_mode));
        fnd_message.set_name('IGS', 'IGS_FI_PERSON_GROUP');
        IF l_n_person_grp_id IS NOT NULL THEN
           fnd_message.set_token('PERSON_GRP',igs_fi_gen_005.finp_get_prsid_grp_code(l_n_person_grp_id));
        ELSE
           fnd_message.set_token('PERSON_GRP',l_n_person_grp_id);
        END IF;
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'CAREER') || ': ' || p_c_career);
        fnd_message.set_name('IGS', 'IGS_FI_GL_DATE');
        fnd_message.set_token('GL_DATE', TO_CHAR(l_d_gl_date, 'DD-MON-YYYY'));
        fnd_file.put_line (fnd_file.log, fnd_message.get);

        -- case in which the person id is not provided but the person group id is provided.
        IF l_n_person_grp_id is NOT NULL AND l_n_person_id is NULL THEN
          -- Get the select query for REF CURSOR by calling igs_pe_dynamic_persid_group.igs_get_dynamic_sql
          l_dynamic_sql := igs_pe_dynamic_persid_group.igs_get_dynamic_sql(l_n_person_grp_id,l_v_status );
          IF l_v_status <> 'S' THEN
            fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
            igs_ge_msg_stack.add;
            app_exception.raise_exception(NULL,NULL,fnd_message.get);
          END IF;


          IF (p_trace_on = 'Y') THEN
             fnd_file.put_line( fnd_file.log, RPAD('=', '79', '=') );
          OPEN  cur_fee_calc_mthd;
          FETCH cur_fee_calc_mthd INTO l_fee_calc_mthd_code;
             fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_CALC_MTHD') || ': ' || igs_fi_gen_gl.get_lkp_meaning('IGS_FI_FEE_CALC_MTHD',l_fee_calc_mthd_code));
          CLOSE cur_fee_calc_mthd;
          l_b_fci_lci := igs_fi_gen_001.finp_get_lfci_reln( l_v_fee_cal_type,
                                                          l_n_fee_ci_sequence_number,
                                                          'FEE',
                                                          l_v_load_cal_type,
                                                          l_n_load_ci_sequence_number,
                                                          l_v_message_name);
           IF l_b_fci_lci=TRUE THEN
            fnd_file.put_line (fnd_file.log, igs_fi_gen_gl.get_lkp_meaning('IGS_AS_ALL_TERM', 'TERM') || ': ' || igs_ca_gen_001.calp_get_alt_cd(l_v_load_cal_type,l_n_load_ci_sequence_number));
           END IF;
            fnd_file.put_line( fnd_file.log, RPAD('=', '79', '=') );
           END IF;

          -- Open the REF CURSOR for above derived SQL statement ( l_dynamic_sql )
          OPEN c_ref_person_grp FOR l_dynamic_sql;
          -- looping across all the valid person ids in the group.
          LOOP
            FETCH c_ref_person_grp INTO rec_person_grp;
            EXIT WHEN c_ref_person_grp%NOTFOUND;

            -- Call fee assessment routine
            BEGIN
                      -- Removed the parameter p_predictive_ass_ind from call to
                      -- igs_fi_prc_fee_ass.finp_ins_enr_fee_ass
                      IF(igs_fi_prc_fee_ass.finp_ins_enr_fee_ass( SYSDATE,
                                                                  rec_person_grp.p_n_person_id,
                                                                  p_course_cd,
                                                                  p_fee_category,
                                                                  l_v_fee_cal_type,
                                                                  l_n_fee_ci_sequence_number,
                                                                  p_fee_type,
                                                                  p_trace_on,
                                                                  p_test_run,
                                                                  v_create_dt,
                                                                  v_message_name,
                                                                  p_process_mode,
                                                                  p_c_career,
                                                                  l_d_gl_date,
                                                                  'N',
                                                                  l_n_waiver_amount) = FALSE) THEN
                        Fnd_Message.Set_Name ('IGS', v_message_name);
                        IF v_message_name = 'IGS_FI_NO_CENSUS_DT_SETUP' THEN
                          fnd_message.set_token('ALT_CD', igs_fi_prc_fee_ass.g_v_load_alt_code);
                        END IF;
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception(Null, Null, fnd_message.get );
                      END IF;
            EXCEPTION
                    WHEN OTHERS THEN
                         -- If any exception is raised for a person, log person_number
                         -- and continue processing for next person
                         retcode:=1;
                         l_v_person_number := igs_fi_gen_008.get_party_number(rec_person_grp.p_n_person_id);
                         fnd_message.set_name('IGS','IGS_FI_PERSON_NUM');
                         fnd_message.set_token('PERSON_NUM',l_v_person_number);
                         igs_ge_msg_stack.add;
            END;

          END LOOP;

        ELSIF l_n_person_grp_id is NULL AND l_n_person_id is NOT NULL THEN
          -- case in which the person id is might be provided or be null

          -- Call fee assessment routine
             IF(igs_fi_prc_fee_ass.finp_ins_enr_fee_ass(
                                                SYSDATE,
                                                l_n_person_id,
                                                p_course_cd,
                                                p_fee_category,
                                                l_v_fee_cal_type,
                                                l_n_fee_ci_sequence_number,
                                                p_fee_type,
                                                p_trace_on,
                                                p_test_run,
                                                v_create_dt,
                                                v_message_name,
                                                p_process_mode,
                                                p_c_career,
                                                l_d_gl_date,
                                                'N',
                                                l_n_waiver_amount) = FALSE) THEN
                        Fnd_Message.Set_Name ('IGS', v_message_name);
                        IF v_message_name = 'IGS_FI_NO_CENSUS_DT_SETUP' THEN
                          fnd_message.set_token('ALT_CD', igs_fi_prc_fee_ass.g_v_load_alt_code);
                        END IF;
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception(Null, Null, fnd_message.get );
             END IF;

        END IF;
 IF p_test_run = 'Y' THEN
      fnd_message.set_name('IGS',
                           'IGS_FI_PRC_TEST_RUN');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
 END IF;

        RETURN;

END;
 EXCEPTION
  WHEN OTHERS THEN
        retcode:=2;
        errbuf:=fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.conc_exception_hndl;
END finp_prc_enr_fee_ass;

--
PROCEDURE finp_prc_hecs_pymnt_optn(
  errbuf  out NOCOPY varchar2,
  retcode out NOCOPY NUMBER,
  p_effective_dt_C  IN OUT NOCOPY VARCHAR2 ,
  P_fee_assessment_period IN VARCHAR2,
  p_person_id IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_fee_cat  IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_deferred_payment_option IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE,
  p_upfront_payment_option IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE,
  p_org_id NUMBER
) AS
        p_effective_dt          DATE;
        p_fee_cal_type  igs_ca_inst.cal_type%TYPE ;
        p_fee_ci_sequence_number  igs_ca_inst.sequence_number%TYPE;
BEGIN
        -- finp_prc_hecs_pymnt_optn
        -- Routine to control processing student's IGS_PS_COURSE attempt HECS payment option
        -- on the basis of their assessed liability and any up front payments made
        --Block for Parameter Validation/Splitting of Parameters


        --As part of bug fix of bug #2318488 the following code has been added
        retcode:=0;
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_OBSOLETE_JOB');
        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

EXCEPTION
  WHEN OTHERS THEN
        RETCODE:=2;
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END finp_prc_hecs_pymnt_optn;
--
PROCEDURE finp_prc_penalties(
  errbuf  out NOCOPY varchar2,
  retcode out NOCOPY number,
  p_effective_dt_C IN VARCHAR2,
  P_fee_assessment_period IN VARCHAR2,
  p_person_id IN      IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_fee_type IN     IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN     IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_course_cd IN     IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_pending_fee_encmb_status IN VARCHAR2,
  p_n_authorising_person_id  IN NUMBER,
  p_org_id NUMBER
) AS
BEGIN

        retcode:=0;
-- As per SFCR005, this concurrent program is obsolete and if the user
-- tries to run this program then an error message should be logged into the log
-- file that the concurrent program is obsolete and should not be run.
   FND_MESSAGE.Set_Name('IGS',
                        'IGS_GE_OBSOLETE_JOB');
   FND_FILE.Put_Line(FND_FILE.Log,
                     FND_MESSAGE.Get);
EXCEPTION
  WHEN OTHERS THEN
        RETCODE:=2;
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END finp_prc_penalties;
--
PROCEDURE finp_prc_sca_unconf(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_attempt_status IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_log_creation_dt IN DATE ,
  p_key IN VARCHAR2 ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_fee_ass_log_creation_dt IN OUT NOCOPY DATE ,
  p_delete_sca_ind OUT NOCOPY VARCHAR2 )
AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  shtatiko        24-DEC-2003     Enh# 3167098, Modified finpl_prc_this_crs_liable and finpl_prc_another_crs_liable
  uudayapr        15-dec-2003     Bug#3080983 Modified the cursor c_fasdv to fetch Data from IGS_FI_FEE_AS instead of IGS_FI_FEE_ASS_DEBT_V.
  vchappid        24-May-2002     Bug#2228743, in the local procedure finpl_prc_reverse_fee_assess of finp_prc_sca_unconf
                                  fee assessment call has been changed to pass course cd in case of program approach, course type
                                  incase of the career approach and will pass null in the case of primary_career approach
  SCHODAVA        28-NOV-2001     Enh # 2122257
                                  (SFCR015 : Change In Fee Category)
                                  Modified local procedures FINPL_PRC_THIS_CRS_LIABLE
                                  and FINPL_PRC_ANOTHER_CRS_LIABLE
  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN   -- finp_prc_sca_unconf
        -- Process finance details for unconfirmed student IGS_PS_COURSE attempts. This
        -- routine is called from ADMP_DEL_SCA_UNCONF when deleting unconfirmed
        -- student IGS_PS_COURSE attempts.
        -- IGS_GE_NOTE: The call to IGS_FI_PRC_FEE_ASS.finp_ins_enr_fee performs a commit,
        -- this means that all outstanding transactions will be committed.
DECLARE
        cst_unconfirm   CONSTANT        VARCHAR2(10) := 'UNCONFIRM';
        e_resource_busy                 EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
        v_delete_sca_ind                VARCHAR2(1) := 'Y';
        v_log_entry_ind                 VARCHAR2(1) := 'N';
        CURSOR c_fas IS
                SELECT DISTINCT fas.course_cd
                FROM    IGS_FI_FEE_AS                   fas
                WHERE   fas.person_id           = p_person_id;
     --Modifed to fetch data from IGS_FI_FEE_AS insted of IGS_FI_FEE_ASS_DEBT_V.
         CURSOR  c_fasdv (cp_fee_ass_course_cd  IGS_FI_FEE_AS.course_cd%TYPE) IS
        SELECT  fasdv.course_cd,
                fasdv.fee_cal_type,
                fasdv.fee_ci_sequence_number,
                fasdv.FEE_TYPE,
                fasdv.FEE_CAT,
                SUM(fasdv.transaction_amount) assessment_amount
        FROM    IGS_FI_FEE_AS          fasdv
        WHERE   fasdv.person_id        = p_person_id
        AND     (fasdv.course_cd        = cp_fee_ass_course_cd
                                       OR
                  (fasdv.course_cd        IS NULL AND  cp_fee_ass_course_cd    IS NULL)
                )
        AND fasdv.logical_delete_dt IS NULL
        GROUP BY fasdv.course_cd,
                fasdv.fee_cal_type,
                fasdv.fee_ci_sequence_number,
                fasdv.FEE_TYPE,
                fasdv.FEE_CAT ;

        PROCEDURE finpl_prc_ins_log_entry (
                p_message_name                  VARCHAR2,
                p_sca_deleted_ind               VARCHAR2)
        AS
        BEGIN   -- finpl_prc_ins_log_entry
                -- create a log entry
        DECLARE
                cst_del_un_sca  CONSTANT        VARCHAR2(10) := 'DEL-UN-SCA';
        BEGIN
                IGS_GE_GEN_003.genp_ins_log_entry (
                                cst_del_un_sca,
                                p_log_creation_dt,
                                p_sca_deleted_ind || '|' || p_key,
                                p_message_name,
                                NULL);
                v_log_entry_ind := 'Y';
        END;
 EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_GEN_004.FINP_PRC_INS_LOG_ENTRY');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END finpl_prc_ins_log_entry;
        PROCEDURE finpl_prc_end_fee_contract(
                p_person_id             IGS_FI_FEE_AS_RT.person_id%TYPE,
                p_course_cd             IGS_FI_FEE_AS_RT.course_cd%TYPE)
        AS
        BEGIN   -- finpl_prc_end_fee_contract
                -- End the fee contract
        DECLARE
                CURSOR c_cfar IS
                        SELECT
                              cfar.ROWID,
                                        cfar.PERSON_ID,
                                        cfar.COURSE_CD,
                                        cfar.FEE_TYPE,
                                        cfar.START_DT,
                                        cfar.END_DT,
                                        cfar.LOCATION_CD,
                                        cfar.ATTENDANCE_TYPE,
                                        cfar.ATTENDANCE_MODE,
                                        cfar.CHG_RATE,
                                        cfar.LOWER_NRML_RATE_OVRD_IND
                        FROM    IGS_FI_FEE_AS_RT        cfar
                        WHERE   cfar.person_id          = p_person_id AND
                                cfar.course_cd          = p_course_cd
                        FOR UPDATE OF cfar.end_dt NOWAIT;
        BEGIN
                FOR v_cfar_rec IN c_cfar LOOP
                    IGS_FI_FEE_AS_RT_PKG.UPDATE_ROW(
                        X_ROWID => v_cfar_rec.ROWID ,
                                X_PERSON_ID => v_cfar_rec.PERSON_ID ,
                                X_COURSE_CD => v_cfar_rec.COURSE_CD,
                                X_FEE_TYPE  => v_cfar_rec.FEE_TYPE ,
                                X_START_DT  => v_cfar_rec.START_DT ,
                                X_END_DT => v_cfar_rec.start_dt,
                                X_LOCATION_CD => v_cfar_rec.LOCATION_CD,
                                X_ATTENDANCE_TYPE => v_cfar_rec.ATTENDANCE_TYPE,
                                X_ATTENDANCE_MODE => v_cfar_rec.ATTENDANCE_MODE,
                                X_CHG_RATE => v_cfar_rec.CHG_RATE ,
                                X_LOWER_NRML_RATE_OVRD_IND => v_cfar_rec.LOWER_NRML_RATE_OVRD_IND ,
                                X_MODE => 'R');
                END LOOP;
        EXCEPTION
                WHEN e_resource_busy THEN
                        IF c_cfar%ISOPEN THEN
                                CLOSE c_cfar;
                        END IF;
                        finpl_prc_ins_log_entry(
                                                4722,
                                                'N');
        END;
 EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_GEN_004.FINP_PRC_END_FEE_CONTRACT');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END finpl_prc_end_fee_contract;

        PROCEDURE finpl_prc_reverse_fee_assess (
                p_person_id                     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                p_course_cd                     IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_fee_cal_type                  IGS_FI_FEE_AS.fee_cal_type%TYPE,
                p_fee_ci_sequence_number        IGS_FI_FEE_AS.fee_ci_sequence_number%TYPE,
                p_fee_type                      IGS_FI_FEE_AS.FEE_TYPE%TYPE,
                p_fee_cat                       IGS_EN_STDNT_PS_ATT.FEE_CAT%TYPE)
        AS

          CURSOR cur_fee_calc_mthd
          IS
          SELECT fee_calc_mthd_code
          FROM   igs_fi_control;
          l_fee_calc_mthd_code igs_fi_control.fee_calc_mthd_code%TYPE;

          CURSOR cur_career (cp_course_cd IN igs_ps_ver.course_cd%type)
          IS
          SELECT course_type
          FROM   igs_ps_ver
          WHERE  course_cd = cp_course_cd;
          l_course_type igs_ps_ver.course_type%TYPE;
          l_course_cd   igs_ps_ver.course_cd%TYPE;
          l_n_waiver_amount NUMBER;


        BEGIN   -- finpl_prc_reverse_fee_assess
                -- Reverse the fee assessment
        DECLARE
                v_message_name                  VARCHAR2(30);
        BEGIN
          OPEN  cur_fee_calc_mthd;
          FETCH cur_fee_calc_mthd INTO l_fee_calc_mthd_code;
          CLOSE cur_fee_calc_mthd;

          -- if the calculation method is career then pass the career/ course type, pass null to course cd
          IF (l_fee_calc_mthd_code = 'CAREER') THEN
            OPEN cur_career(p_course_cd);
            FETCH cur_career INTO l_course_type;
            CLOSE cur_career;
            l_course_cd := NULL;

          -- if the calculation method is program then pass the course cd and pass null to the career parameter
          ELSIF (l_fee_calc_mthd_code = 'PROGRAM') THEN
            l_course_type := NULL;
            l_course_cd   := p_course_cd;
          -- if the calculation method is primary career then pass the career/ course type and course cd as null
          ELSIF (l_fee_calc_mthd_code = 'PRIMARY_CAREER') THEN
            l_course_type := NULL;
            l_course_cd := NULL;
          END IF;



                -- IGS_GE_NOTE: Must perform a commit before calling
                -- IGS_FI_PRC_FEE_ASS.finp_ins_enr_fee_ass because the first statement of
                -- IGS_FI_PRC_FEE_ASS.finp_ins_enr_fee_ass is to alter the rollback segment,
                -- which requires all the outstanding transactions to be committed or rolled back
                COMMIT;

                -- Enh# 3167098, Removed call to igs_en_gen_002.enrp_get_acad_comm which was used to derive the commencement date.
                -- This is removed as SYSDATE is passed to effective date.

                -- Removed the parameter p_predictive_ass_ind from call to
                -- igs_fi_prc_fee_ass.finp_ins_enr_fee_ass
                IF NOT igs_fi_prc_fee_ass.finp_ins_enr_fee_ass (
                                TRUNC(SYSDATE),       -- effective date
                                p_person_id,
                                l_course_cd,
                                p_fee_cat,
                                p_fee_cal_type,
                                p_fee_ci_sequence_number,
                                p_fee_type,
                                'N',                            -- trace on
                                'N',                            -- test run
                                p_fee_ass_log_creation_dt,
                                v_message_name,
                                'ACTUAL', -- Process Mode
                                l_course_type,
                                TRUNC(SYSDATE),
                                'N',
                                l_n_waiver_amount
                                ) THEN
                        finpl_prc_ins_log_entry(
                                                v_message_name,
                                                'N');
                END IF;
        END;
 EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_GEN_004.FINPL_PRC_REVERSE_FEE_ASSESS');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END finpl_prc_reverse_fee_assess;
        --Modified the declartion of datatype based on IGS_FI_FEE_ASS_DEBT_V to point to IGS_FI_FEE_AS.
        FUNCTION finpl_prc_this_crs_liable (
                p_person_id                     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                p_course_cd                     IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_fee_cat                       IGS_EN_STDNT_PS_ATT.FEE_CAT%TYPE,
                p_fee_type                      IGS_FI_FEE_AS.FEE_TYPE%TYPE,
                p_fee_cal_type                  IGS_FI_FEE_AS.fee_cal_type%TYPE,
                p_fee_ci_sequence_number        IGS_FI_FEE_AS.fee_ci_sequence_number%TYPE)
        RETURN VARCHAR2 AS
        BEGIN   -- finpl_prc_this_crs_liable
                -- Check if this IGS_PS_COURSE is liable for the fees
        DECLARE
                v_dummy                         VARCHAR2(1);

                -- Enh # 2122257
                -- SFCR015 : Change in Fee Category
                -- Modified the cursor c_sfv
                -- Enh# 3167098, Removed usage of igs_fi_f_cat_cal_rel and igs_fi_cng_fcat_lbl_sca_pr_v
                CURSOR c_sfv IS
                        SELECT  'X'
                        FROM    IGS_FI_F_CAT_FEE_LBL_SCA_V sfv
                        WHERE   sfv.person_id                   = p_person_id
                        AND     sfv.course_cd                   = p_course_cd
                        AND     sfv.FEE_CAT                     = p_fee_cat
                        AND     sfv.FEE_TYPE                    = p_fee_type
                        AND     sfv.fee_cal_type                = p_fee_cal_type
                        AND     sfv.fee_ci_sequence_number      = p_fee_ci_sequence_number;

        BEGIN
                OPEN c_sfv;
                FETCH c_sfv INTO v_dummy;
                IF c_sfv%FOUND THEN
                        CLOSE c_sfv;
                        RETURN 'Y';
                ELSE
                        CLOSE c_sfv;
                        RETURN 'N';
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_sfv%ISOPEN THEN
                                CLOSE c_sfv;
                        END IF;
                        RAISE;
        END;
 EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_GEN_004.FINPL_PRC_THIS_CRS_LIABLE');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END finpl_prc_this_crs_liable;
       --Modified the declartion of datatype based on IGS_FI_FEE_ASS_DEBT_V to point to IGS_FI_FEE_AS.
        FUNCTION finpl_prc_another_crs_liable (
                p_person_id                     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                p_course_cd                     IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_fee_cal_type                  IGS_FI_FEE_AS.fee_cal_type%TYPE,
                p_fee_ci_sequence_number        IGS_FI_FEE_AS.fee_ci_sequence_number%TYPE,
                p_fee_type                      IGS_FI_FEE_AS.FEE_TYPE%TYPE)
        RETURN VARCHAR2 AS
        BEGIN   -- finpl_prc_another_crs_liable
                -- Check if another IGS_PS_COURSE is liable for the fees
        DECLARE
                cst_unconfirm   CONSTANT        VARCHAR2(10) := 'UNCONFIRM';
                v_dummy                         VARCHAR2(1);

                -- Enh # 2122257
                -- SFCR015 : Change in Fee Category
                -- Modified the cursor c_sfv
                -- Enh# 3167098, Removed usage of igs_fi_f_cat_cal_rel and igs_fi_cng_fcat_lbl_sca_pr_v
                CURSOR c_sfv IS
                SELECT  'X'
                FROM    IGS_FI_F_CAT_FEE_LBL_SCA_V sfv
                WHERE   sfv.person_id                   = p_person_id
                AND     sfv.course_cd                   <> p_course_cd
                AND     sfv.FEE_TYPE                    = p_fee_type
                AND     sfv.fee_cal_type                = p_fee_cal_type
                AND     sfv.fee_ci_sequence_number      = p_fee_ci_sequence_number
                AND     (sfv.fee_ass_ind                = 'Y'
                        OR sfv.course_attempt_status    = cst_unconfirm);

        BEGIN
                OPEN c_sfv;
                FETCH c_sfv INTO v_dummy;
                IF c_sfv%FOUND THEN
                        CLOSE c_sfv;
                        RETURN 'Y';
                ELSE
                        CLOSE c_sfv;
                        RETURN 'N';
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_sfv%ISOPEN THEN
                                CLOSE c_sfv;
                        END IF;
                        RAISE;
        END;
 EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_GEN_004.FINPL_PRC_ANOTHER_CRS_LIABLE');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END finpl_prc_another_crs_liable;
        PROCEDURE finpl_prc_delete_fee_contract (
                p_person_id             IGS_FI_FEE_AS_RT.person_id%TYPE,
                p_course_cd             IGS_FI_FEE_AS_RT.course_cd%TYPE)
        AS
        BEGIN   -- finpl_prc_delete_fee_contract
                -- Delete the fee contract
        DECLARE
                CURSOR c_cfar IS
                        SELECT  cfar.person_id , cfar.ROWID
                        FROM    IGS_FI_FEE_AS_RT        cfar
                        WHERE   cfar.person_id          = p_person_id AND
                                cfar.course_cd          = p_course_cd
                        FOR UPDATE OF cfar.person_id NOWAIT;
        BEGIN
                FOR v_cfar_rec IN c_cfar LOOP
                  IGS_FI_FEE_AS_RT_PKG.DELETE_ROW(X_ROWID =>v_cfar_rec.ROWID);
                END LOOP;
        EXCEPTION
                WHEN e_resource_busy THEN
                        finpl_prc_ins_log_entry(
                                                4724,
                                                'N');
                        v_delete_sca_ind := 'N';
                WHEN OTHERS THEN
                        IF c_cfar%ISOPEN THEN
                                CLOSE c_cfar;
                        END IF;
                        RAISE;
        END;
 EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_GEN_004.FINPL_PRC_DELETE_FEE_CONTRACT');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END finpl_prc_delete_fee_contract;
BEGIN
        -- Validate input parameters
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_course_attempt_status IS NULL OR
                        p_log_creation_dt IS NULL OR
                        p_key IS NULL THEN
                RETURN;
        END IF;
        -- Initialise the output parameter
        p_delete_sca_ind := 'Y';
        -- Only process unconfirmed IGS_PS_COURSE attempts
        IF p_course_attempt_status <> cst_unconfirm THEN
                RETURN;
        END IF;
        -- Check if a fee assessment exists for the IGS_PE_PERSON
        FOR v_fas_rec IN c_fas LOOP
                IF v_fas_rec.course_cd = p_course_cd OR
                                v_fas_rec.course_cd IS NULL THEN
                        IF v_fas_rec.course_cd = p_course_cd THEN
                                v_delete_sca_ind := 'N';
                        END IF;
                        -- Check if an assessed debt liability exists for the IGS_PS_COURSE attempt
                        FOR v_fasdv_rec IN c_fasdv(
                                                v_fas_rec.course_cd) LOOP
                                IF v_fasdv_rec.course_cd IS NOT NULL THEN
                                        -- Process this IGS_PS_COURSE attempt
                                        finpl_prc_end_fee_contract(
                                                                p_person_id,
                                                                p_course_cd);
                                        IF v_fasdv_rec.assessment_amount <> 0 THEN
                                                finpl_prc_reverse_fee_assess(
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        v_fasdv_rec.fee_cal_type,
                                                                        v_fasdv_rec.fee_ci_sequence_number,
                                                                        v_fasdv_rec.FEE_TYPE,
                                                                        p_fee_cat);
                                        END IF;
                                ELSE
                                        -- Process IGS_OR_INSTITUTION fees
                                        IF v_fasdv_rec.assessment_amount <> 0 THEN
                                                IF finpl_prc_this_crs_liable (
                                                                p_person_id,
                                                                p_course_cd,
                                                                p_fee_cat,
                                                                v_fasdv_rec.FEE_TYPE,
                                                                v_fasdv_rec.fee_cal_type,
                                                                v_fasdv_rec.fee_ci_sequence_number) = 'Y' THEN
                                                        IF finpl_prc_another_crs_liable (
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        v_fasdv_rec.fee_cal_type,
                                                                        v_fasdv_rec.fee_ci_sequence_number,
                                                                        v_fasdv_rec.FEE_TYPE) = 'N' THEN
                                                                v_delete_sca_ind := 'N';
                                                                finpl_prc_end_fee_contract(
                                                                                        p_person_id,
                                                                                        p_course_cd);
                                                                finpl_prc_reverse_fee_assess(
                                                                                p_person_id,
                                                                                p_course_cd,
                                                                                v_fasdv_rec.fee_cal_type,
                                                                                v_fasdv_rec.fee_ci_sequence_number,
                                                                                v_fasdv_rec.FEE_TYPE,
                                                                                p_fee_cat);
                                                        END IF;
                                                END IF;
                                        END IF;
                                END IF;
                        END LOOP;       -- c_fasdv
                END IF;
        END LOOP;       -- c_fas
        IF v_delete_sca_ind = 'Y' THEN
                finpl_prc_delete_fee_contract (
                                                p_person_id,
                                                p_course_cd);
        END IF;
        IF v_delete_sca_ind = 'N' AND
                        v_log_entry_ind = 'N' THEN
                finpl_prc_ins_log_entry(
                                        4741,
                                        'N');
        END IF;
        p_delete_sca_ind := v_delete_sca_ind;
EXCEPTION
        WHEN OTHERS THEN
                IF c_fas%ISOPEN THEN
                        CLOSE c_fas;
                END IF;
                IF c_fasdv%ISOPEN THEN
                        CLOSE c_fasdv;
                END IF;
                RAISE;
END;
 EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_FI_GEN_004.FINP_PRC_SCA_UNCONF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END finp_prc_sca_unconf;
END igs_fi_gen_004;

/
