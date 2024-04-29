--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_FEE_ASS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_FEE_ASS" AUTHID CURRENT_USER AS
/* $Header: IGSFI09S.pls 120.6 2005/09/06 06:09:23 appldev ship $ */
/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who             When          What
 pathipat        06-Sep-2005   Bug 4540295 - Fee assessment produce double fees after program version change
                               Added a column crs_version_number in r_s_fee_as_items_typ
 bannamal        26-Aug-2005    Enh#3392095 Tuition Waiver Build. Added two new parameters in finp_ins_enr_fee_ass
 bannamal        08-Jul-2005   Enh#3392088 Campus Privilege Fee. Added the plsql table tbl_fai_unit_dtls,
                               Added some columns in the existing plsql table t_fee_as_items.
 bannamal        03-JUN-2005   Bug#3442712 Unit Level Fee Assessment Build. Added new columns in the
                               record type variable r_s_fee_as_items_typ.
 bannamal        27-May-2005   Fee Calculation Performance Enhancement. Changes done as per TD.
 shtatiko         23-JUL-2004  Enh# 3741400, Added finpl_clc_sua_cp.
 shtatiko        24-DEC-2003   Enh# 3167098, Removed g_b_prg_chg_da_use, g_d_prg_chg_da_alias_val, g_n_total_load,
                               g_b_sca_inactive and g_b_sca_unconfirm. Added g_d_ld_census_val.
 pathipat        05-Nov-2003   Enh 3117341 - Audit and Special Fees TD
                               Modifications according to TD, s1a
 pathipat        12-Sep-2003   Enh 3108052 - Unit Sets in Rate Table build
                               Added unit_set_cd and us_version_number to plsql table t_fee_as_items_typ
 vchappid        11-Nov-2002   Bug# 2584986, GL- Interface Build New Date parameter.
                               p_d_gl_date is added to the finp_ins_enr_fee_ass function specification
 npalanis        23-OCT-2002   Bug : 2608360
                               references to residency_status_id is changed to residency_status_cd as all pe code
                               classes are moved to igs lookups.
 vchappid        17-Oct-2002   Bug# 2595962, Removed parameter p_predictive_ass_ind from the function call,
                               Global variables are introduced.
 vchappid        25-Jul-2002   Bug# 2237227 - added flag 'add_flag' with Default value 'N' into the Pl/SQL table t_fee_as_items
                               added to take care the duplicate SUA incase of Primary Career fee calculation Method
 rnirwani        28-May-02     Bug# 2378804 - removed declaration of global variables for load cal inst
 smadathi        02-May-2002   Bug 2261649. The function finp_get_additional_charge removed.
 vchappid        02-Jan-02     Enh Bug#2162747, Key Program Implementation, Fin Cal Inst parameters
                            removed, new parameter p_c_career is added
 (reverse chronological order - newest change first)
***************************************************************/
  --
  -- Calculate and insert fee assessments as required

  FUNCTION finp_ins_enr_fee_ass(
  p_effective_dt IN DATE ,
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_fee_category IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_fee_cal_type IN IGS_CA_INST_ALL.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_num IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE ,
  p_trace_on IN VARCHAR2 ,
  p_test_run IN VARCHAR2 ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_process_mode IN VARCHAR2 DEFAULT 'ACTUAL',
  p_c_career IN igs_ps_ver_all.course_type%TYPE DEFAULT NULL,
  p_d_gl_date IN DATE DEFAULT NULL,
  p_v_wav_calc_flag IN VARCHAR2 DEFAULT NULL,
  p_n_waiver_amount OUT NOCOPY NUMBER
  )     RETURN BOOLEAN;

        gcst_planned    CONSTANT IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE := 'PLANNED';
        gcst_inactive   CONSTANT IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE := 'INACTIVE';
        gcst_active     CONSTANT IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE := 'ACTIVE';
        gcst_institutn  CONSTANT IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE := 'INSTITUTN';
        gcst_course     CONSTANT IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE := 'COURSE';
        gcst_flatrate   CONSTANT IGS_FI_F_CAT_FEE_LBL_ALL.s_chg_method_type%TYPE := 'FLATRATE';
        gcst_perunit    CONSTANT IGS_FI_F_CAT_FEE_LBL_ALL.s_chg_method_type%TYPE := 'PERUNIT';
        gcst_eftsu      CONSTANT IGS_FI_F_CAT_FEE_LBL_ALL.s_chg_method_type%TYPE := 'EFTSU';
        gcst_crpoint    CONSTANT IGS_FI_F_CAT_FEE_LBL_ALL.s_chg_method_type%TYPE := 'CRPOINT';
        gcst_tuition    CONSTANT IGS_FI_FEE_TYPE_ALL.s_fee_type%TYPE := 'TUITION';
        gcst_other      CONSTANT IGS_FI_FEE_TYPE_ALL.s_fee_type%TYPE := 'OTHER';
        gcst_tuition_other      CONSTANT IGS_FI_FEE_TYPE_ALL.s_fee_type%TYPE := 'TUTNFEE';

        g_v_audit       CONSTANT igs_fi_fee_type.s_fee_type%TYPE := 'AUDIT';

        g_v_include_audit  VARCHAR2(1) := 'N';

        TYPE r_s_fee_as_items_typ IS RECORD (
                                person_id               IGS_FI_FEE_AS_ITEMS.person_id%TYPE,
                                status                  IGS_FI_FEE_AS_ITEMS.status%TYPE,
                                fee_type                IGS_FI_FEE_AS_ITEMS.fee_type%TYPE,
                                fee_cat                 IGS_FI_FEE_AS_ITEMS.fee_cat%TYPE,
                                fee_cal_type            IGS_FI_FEE_AS_ITEMS.fee_cal_type%TYPE,
                                fee_ci_sequence_number  IGS_FI_FEE_AS_ITEMS.fee_ci_sequence_number%TYPE,
                                rul_sequence_number     IGS_FI_FEE_AS_ITEMS.rul_sequence_number%TYPE,
                                course_cd               IGS_FI_FEE_AS_ITEMS.course_cd%TYPE,
                                crs_version_number      igs_fi_fee_as_items.crs_version_number%TYPE,
                                old_chg_method_type     IGS_FI_FEE_AS_ITEMS.S_CHG_METHOD_TYPE%TYPE,
                                chg_method_type         IGS_FI_FEE_AS_ITEMS.S_CHG_METHOD_TYPE%TYPE,
                                description             IGS_FI_FEE_AS_ITEMS.description%TYPE,
                                old_chg_elements        IGS_FI_FEE_AS_ITEMS.chg_elements%TYPE,
                                chg_elements            IGS_FI_FEE_AS_ITEMS.chg_elements%TYPE,
                                old_amount              IGS_FI_FEE_AS_ITEMS.amount%TYPE,
                                amount                  IGS_FI_FEE_AS_ITEMS.amount%TYPE,
                                unit_attempt_status     IGS_FI_FEE_AS_ITEMS.unit_attempt_status%TYPE,
                                location_cd             IGS_FI_FEE_AS_ITEMS.location_cd%TYPE,
                                old_eftsu               IGS_FI_FEE_AS_ITEMS.eftsu%TYPE,
                                eftsu                   IGS_FI_FEE_AS_ITEMS.eftsu%TYPE,
                                old_credit_points       IGS_FI_FEE_AS_ITEMS.credit_points%TYPE,
                                credit_points           IGS_FI_FEE_AS_ITEMS.credit_points%TYPE,
                                chg_rate                IGS_FI_FEE_AS_RATE.chg_rate%TYPE,
                                org_unit_cd             IGS_FI_FEE_AS_ITEMS.org_unit_cd%TYPE,
                                class_standing          IGS_FI_FEE_AS_ITEMS.class_standing%TYPE,
                                residency_status_cd     IGS_FI_FEE_AS_ITEMS.residency_status_cd%TYPE,
                                uoo_id                  IGS_FI_FEE_AS_ITEMS.UOO_ID%TYPE,
                                add_flag                VARCHAR2(1) DEFAULT 'N',
                                unit_set_cd             igs_fi_fee_as_items.unit_set_cd%TYPE,
                                us_version_number       igs_fi_fee_as_items.us_version_number%TYPE,
                                unit_type_id            igs_fi_fee_as_items.unit_type_id%TYPE,
                                unit_class              igs_fi_fee_as_items.unit_class%TYPE,
                                unit_mode               igs_fi_fee_as_items.unit_mode%TYPE,
                                unit_cd                 igs_fi_fee_as_rate.unit_cd%TYPE,
                                unit_level              igs_fi_fee_as_items.unit_level%TYPE,
                                unit_version_number     igs_fi_fee_as_rate.unit_version_number%TYPE,
                                fee_ass_item_id         igs_fi_fee_as_items.fee_ass_item_id%TYPE,
                                element_order           NUMBER
                                );


       TYPE t_fee_as_items_typ IS TABLE OF r_s_fee_as_items_typ   INDEX BY BINARY_INTEGER;
       t_fee_as_items          t_fee_as_items_typ;

       TYPE rec_fai_unit_dtls_typ IS RECORD (
                                 fee_cat                 igs_fi_fai_dtls.fee_cat%TYPE,
                                 course_cd               igs_fi_fai_dtls.course_cd%TYPE,
                                 crs_version_number      igs_fi_fai_dtls.crs_version_number%TYPE,
                                 unit_attempt_status     igs_fi_fai_dtls.unit_attempt_status%TYPE,
                                 org_unit_cd             igs_fi_fai_dtls.org_unit_cd%TYPE,
                                 class_standing          igs_fi_fai_dtls.class_standing%TYPE,
                                 location_cd             igs_fi_fai_dtls.location_cd%TYPE,
                                 uoo_id                  igs_fi_fai_dtls.uoo_id%TYPE,
                                 unit_set_cd             igs_fi_fai_dtls.unit_set_cd%TYPE,
                                 us_version_number       igs_fi_fai_dtls.us_version_number%TYPE,
                                 chg_elements            igs_fi_fee_as_items.chg_elements%TYPE,
                                 unit_type_id            igs_fi_fee_as_items.unit_type_id%TYPE,
                                 unit_class              igs_fi_fee_as_items.unit_class%TYPE,
                                 unit_mode               igs_fi_fee_as_items.unit_mode%TYPE,
                                 unit_cd                 igs_fi_fee_as_items.unit_cd%TYPE,
                                 unit_level              igs_fi_fee_as_items.unit_level%TYPE,
                                 unit_version_number     igs_fi_fee_as_items.unit_version_number%TYPE
                                 );

       TYPE t_fai_unit_dtls_typ IS TABLE OF rec_fai_unit_dtls_typ  INDEX BY BINARY_INTEGER;

       tbl_fai_unit_dtls  t_fai_unit_dtls_typ;

       gv_as_item_cntr         NUMBER;

       t_dummy_fee_as_items    t_fee_as_items_typ;

       TYPE r_inst_fee_rec IS RECORD (
                     person_id          IGS_FI_FEE_AS_ITEMS.person_id%TYPE,
                     fee_type           IGS_FI_FEE_AS_ITEMS.fee_type%TYPE,
                     fee_cal_type               IGS_FI_FEE_AS_ITEMS.fee_cal_type%TYPE,
                     fee_ci_sequence_number     IGS_FI_FEE_AS_ITEMS.fee_ci_sequence_number%TYPE,
                     fcfl_status                IGS_FI_F_CAT_FEE_LBL.FEE_LIABILITY_STATUS%TYPE);

       TYPE t_inst_fee_rec_type IS TABLE OF  r_inst_fee_rec  INDEX BY BINARY_INTEGER;

                l_inst_fee_rec   t_inst_fee_rec_type;
                l_inst_fee_rec_dummy   t_inst_fee_rec_type;
                g_inst_fee_rec_cntr    NUMBER;

                /* Enh# 2162747 Added new global parameters */
                -- variable for Fee Calculation Method defined in the Recievables Control Form/ System Options Control Form
                g_c_fee_calc_mthd   igs_fi_control.fee_calc_mthd_code%TYPE;

                -- variable for storing Key Program of a student
                g_c_key_program        igs_ps_ver.course_cd%TYPE;
                g_n_key_version        igs_ps_ver.version_number%TYPE;

                -- Attendance type and Attendence Mode can be derived depending on the Load incurred by the Student or
                -- the attendance type and attendance Mode for the program that is being assessed can be used
                -- depending on the system Profile Value defined at the User level either Nominated or Derived values
                -- can be used.
                gcst_nominated   CONSTANT igs_lookups_view.lookup_code%TYPE := 'NOMINATED';
                gcst_derived     CONSTANT igs_lookups_view.lookup_code%TYPE := 'DERIVED';

                /* End Of Modifications for Enh# 2162747 */

                -- global variable to check if the Predictive Fee Assessment is being done
                -- when the process mode is passed as PREDICTIVE then this global variable will be set to 'Y'
                g_c_predictive_ind VARCHAR2(1) := 'N';

                g_d_ld_census_val DATE;

                -- Variables to hold information of Load Period associated to Fee Period assessed.
                g_v_load_cal_type  igs_fi_f_cat_ca_inst.fee_cal_type%TYPE;
                g_n_load_seq_num   igs_fi_f_cat_ca_inst.fee_ci_sequence_number%TYPE;
                g_v_load_alt_code  igs_ca_inst_all.alternate_code%TYPE;

  -- This function calls EN API to get values of different Credit Points: Enrolled, Billing and Audit
  FUNCTION finpl_clc_sua_cp( p_v_unit_cd                     IN igs_en_su_attempt_all.unit_cd%TYPE,
                             p_n_version_number              IN igs_en_su_attempt_all.version_number%TYPE,
                             p_v_cal_type                    IN igs_en_su_attempt_all.cal_type%TYPE,
                             p_n_ci_sequence_number          IN igs_en_su_attempt_all.ci_sequence_number%TYPE,
                             p_v_load_cal_type               IN igs_en_su_attempt_all.cal_type%TYPE,
                             p_n_load_ci_sequence_number     IN igs_en_su_attempt_all.ci_sequence_number%TYPE,
                             p_n_override_enrolled_cp        IN igs_en_su_attempt_all.override_enrolled_cp%TYPE,
                             p_n_override_eftsu              IN igs_en_su_attempt_all.override_eftsu%TYPE,
                             p_n_uoo_id                      IN igs_en_su_attempt_all.uoo_id%TYPE,
                             p_v_include_audit               IN igs_en_su_attempt_all.no_assessment_ind%TYPE ) RETURN NUMBER;

        END igs_fi_prc_fee_ass;

 

/
