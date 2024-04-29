--------------------------------------------------------
--  DDL for Package Body IGS_PS_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GEN_001" AS
/* $Header: IGSPS01B.pls 120.11 2006/05/15 03:16:40 sarakshi ship $ */
   -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sarakshi    23-Jan-2004     Enh#3345205, created new procedure crsp_ins_term_instr_time and invoked the same from the main body
  --schodava    17-Sep-2003     Bug # 2520994 PSP Inheritance Build
  --                            Modified procedure crsp_ins_unit_section
  --vvutukur    04-Aug-2003     Enh#3045069.PSP Enh Build. Modified crsp_ins_unit_section,change_unit_section_status.
  --jdeekoll    28-July-2003    Bug#3060697 Modified the local procedure crsp_ins_cal_rec
  --jbegum      23-July-2003    Bug#3060693 Modified the local procedure crsp_ins_ca_rec
  --jbegum      27-jun-2003     Bug#2930935 Added the columns ACHIEVABLE_CREDIT_POINTS,ENROLLED_CREDIT_POINTS
  --                            in the call to igs_ps_usec_cps_pkg.insert_row
  --jbegum      16-Jun-2003     Bug#2983445 .Obsoleted the column award_title from igs_ps_award table.
  --smvk        09-Jun-2003     Bug # 2858436. Modified the procedure crsp_ins_crs_ver.
  --shtatiko    03-JUN-2003     Enh# 2831572, Modified crsp_ins_unit_section and crsp_ins_crs_ver
        --Nalin Kumar 26-May-2003     Modified the call to the igs_ps_unitass_item_pkg.insert row;
        --                            Passed the correct value to the newly added parameter (x_descroption) of the insert_row;
        --                            This is as per Assessment Item Build. Bug# 2829291;
        --
  --sarakshi    24-Apr-2003     Enh#2858431,added procedure change_unit_section_status ,also modified the call to igs_ps_usec_ocur_ref_pkg.insert_row
  --jbegum      21-Apr-2003     Enh bug#2833850 added columns preferred_region_code and no_set_day_ind to the call of
  --                            igs_ps_usec_occurs_pkg.insert_row
  --sarakshi    23-Feb-2003     Enh#2797116,modified cursor gc_coo_rec in crsp_ins_crs_ver procedure.Also modified
  --                            cursor c_coo_new in crsp_ins_coi_rec procedure.
  --vvutukur    01-Nov-2002     Enh#2636716.Modifications done in crsp_ins_unit_section.
  --vvutukur    28-Oct-2002     Enh#2613933.Modifications done in crsp_ins_unit_section.
  --shtatiko        21-OCT-2002        Added two parameters, program_length and program_length_measurement, to insert_row call of IGS_PS_OFR_OPT_PKG as per bug# 2608227.
  --amuthu      24-Sep-02       added core_ind column to the cursor c_posu and also
  --                            added it to the insert row call of igs_ps_pat_study_unt_pkg
  --jbegum      11-Sep-02       1)As part of bug#2563596 modified CURSOR us_req_refcd.
  --                            2)Also added a for loop which inserts into the igs_ps_usec_ref_cd
  --                            all reference code records from old unit section to new unit section.
  --                            3)Added an IF condition that checks if the function igs_ru_gen_002.rulp_ins_parser
  --                            returns a TRUE or FALSE.
  --                            4)Modified the values being passed to the parameters in call to igs_ru_gen_002.rulp_ins_parser
  --sarakshi    5-Jun-2002      bug#2332807, changes are mentioned in detail in the code, procedure crsp_ins_unit_section.
  --smadathi    02-May-2002     Bug 2261649. The procedure crsp_ins_unit_section modified.
  --jbegum     19 April 02      As part of bug fix of bug #2322290 and bug#2250784
  --                            Removed the following 4 columns
  --                            BILLING_CREDIT_POINTS,BILLING_HRS,FIN_AID_CP,FIN_AID_HRS
  --                            from igs_ps_usec_cps_pkg.insert_row call
  --prraj       14-Feb-2002     Parameter ACHIEVABLE_CREDIT_POINTS removed from call to
  --                            tbh IGS_PS_USEC_CPS_PKG Bug# 2224366
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_ps_val_cop.genp_val_staff_prsn
  --                            is changed to igs_ad_val_acai.genp_val_staff_prsn
  --bayadav     19-Nov-2001     Bug no:2115430.Added column acad_perd_unit_set column in insert_orw call to IGS_PAT_OF_STUDY table
  -- Nalin Kumar 20-Nov-2001    Added 'DEFAULT_IND' parameter to call igs_ps_award_pkg.insert_row.
  --                            The changes are as per the UK Award Aims DLD. Bug ID: 1366899
  --Nalin Kumar 28-Jan-2002    Modified Procedure 'crsp_ins_crs_ver'
  --                           as pert of the HESA Intregation DLD (ENCR019). Bug# 2201753.
  --ijeddy, Dec 3, 2003        Grade Book Enh build, bug no 3201661
  -------------------------------------------------------------------------------------------
 -- Bug No. 1956374 Procedure assp_val_gs_cur_fut reference is changed

  PROCEDURE CRSP_INS_CRS_VER(
  p_old_course_cd IN VARCHAR2 ,
  p_old_version_number IN NUMBER ,
  p_new_course_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2
   )
  AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smvk        09-Jun-2003     Bug # 2858436. Modified the cursor gc_ca_rec to select open program awards.
  --shtatiko    23-MAY-2003     Enh# 2831572, Removed procedure crsp_ins_revseg_rec and removed
  --                            cursor gc_revseg_rec.
  -------------------------------------------------------------------------------------------
         cst_ret_message_name        CONSTANT VARCHAR2(30) := 'IGS_PS_FAIL_COPY_PRGVER_DETAI';
        cst_max_error_range        CONSTANT NUMBER := -20999;
        cst_min_error_range        CONSTANT NUMBER := -20000;
        gv_cv_rec                IGS_PS_VER%ROWTYPE;
        gv_con_rec                IGS_PS_OFR_NOTE%ROWTYPE;
        gv_coon_rec                IGS_PS_OFR_OPT_NOTE%ROWTYPE;
        gv_co_rec                IGS_PS_OFR%ROWTYPE;
        gv_coo_rec                IGS_PS_OFR_OPT%ROWTYPE;
        gv_ceprcd_rec                IGS_PS_ENT_PT_REF_CD%ROWTYPE;
        gv_calulink_rec                IGS_PS_ANL_LOAD_U_LN%ROWTYPE;
        gv_coi_rec                IGS_PS_OFR_INST%ROWTYPE;
        gv_cop_rec                IGS_PS_OFR_PAT%ROWTYPE;
        gv_copn_rec                IGS_PS_OFR_PAT_NOTE%ROWTYPE;
        gv_ref_num                IGS_GE_NOTE.reference_number%TYPE;
        gv_coo_seq_num                IGS_PS_OFR_OPT.coo_id%TYPE;
        gv_cop_seq_num                IGS_PS_OFR_PAT.cop_id%TYPE;
        gv_ca_rec                IGS_PS_AWARD%ROWTYPE;
        gv_cao_rec                IGS_PS_AWD_OWN%ROWTYPE;
        gv_cow_rec                IGS_PS_OWN%ROWTYPE;
        gv_cvn_rec                IGS_PS_VER_NOTE%ROWTYPE;
        gv_ae_rec                IGS_PE_ALTERNATV_EXT%ROWTYPE;
        gv_cgm_rec                IGS_PS_GRP_MBR%ROWTYPE;
        gv_fsr_rec                IGS_FI_FND_SRC_RSTN%ROWTYPE;
        gv_cfos_rec                IGS_PS_FIELD_STUDY%ROWTYPE;
        gv_ccat_rec                IGS_PS_CATEGORISE%ROWTYPE;
        gv_crcd_rec                IGS_PS_REF_CD%ROWTYPE;
        gv_cal_rec                IGS_PS_ANL_LOAD%ROWTYPE;
        gv_revseg_rec           IGS_PS_ACCTS%ROWTYPE;
        gv_err_msg_proc                VARCHAR2(255);
        gv_err_msg_proc1        VARCHAR2(255);
        gv_err_msg_proc2        VARCHAR2(255);
        gv_err_msg_proc3        VARCHAR2(255);
        gv_err_msg_proc4        VARCHAR2(255);
        gv_err_msg_proc5        VARCHAR2(255);
        gv_err_msg_proc6        VARCHAR2(255);
        gv_err_msg_proc7        VARCHAR2(255);
        gv_err_msg_proc8        VARCHAR2(255);
        x_rowid                VARCHAR2(25);

        --Next cursor added as per the HESA DLD Build. ENCR019 Bug# 2201753.
        CURSOR cur_obj_exists IS
        SELECT 1
        FROM user_objects
        WHERE object_name  = 'IGS_HE_PS_PKG';
        l_status    NUMBER(3);
        l_cur_obj_exists cur_obj_exists%ROWTYPE;


        CURSOR        gc_cv_old_rec IS
                SELECT        *
                FROM        IGS_PS_VER
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_cv_new_rec IS
                 SELECT         *
                FROM        IGS_PS_VER
                WHERE        course_cd = p_new_course_cd AND
                        version_number = p_new_version_number;
        CURSOR        gc_ca_rec IS
                SELECT        *
                FROM           IGS_PS_AWARD
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number AND
                        CLOSED_IND = 'N';
        CURSOR        gc_cao_rec IS
                SELECT        *
                FROM           IGS_PS_AWD_OWN
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number AND
                        award_cd = gv_ca_rec.award_cd;
        CURSOR        gc_cow_rec IS
                SELECT        *
                FROM           IGS_PS_OWN
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        -- Only interested in notes that are not OLE type as
        -- currently unable to copy long raw field within PL/SQL
        CURSOR        gc_cvn_rec IS
                SELECT        *
                FROM           IGS_PS_VER_NOTE cvn
                WHERE        cvn.course_cd = p_old_course_cd AND
                       cvn.version_number = p_old_version_number AND
                        EXISTS        (SELECT 1
                                FROM        IGS_GE_NOTE nte
                                WHERE        nte.reference_number = cvn.reference_number AND
                                        nte.note_text IS NOT NULL);
        CURSOR        gc_ae_rec IS
                SELECT        *
                FROM           IGS_PE_ALTERNATV_EXT
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_cgm_rec IS
                SELECT        *
                FROM           IGS_PS_GRP_MBR
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_fsr_rec IS
                SELECT        *
                FROM           IGS_FI_FND_SRC_RSTN
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_cfos_rec IS
                SELECT        *
                FROM           IGS_PS_FIELD_STUDY
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_ccat_rec IS
                SELECT        *
                FROM           IGS_PS_CATEGORISE
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_crcd_rec IS
                SELECT        *
                FROM           IGS_PS_REF_CD
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_cal_rec IS
                SELECT        *
                FROM           IGS_PS_ANL_LOAD
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_calulink_rec IS
                SELECT        *
                FROM           IGS_PS_ANL_LOAD_U_LN
                WHERE        course_cd = p_old_course_cd AND
                        crv_version_number = p_old_version_number AND
                        yr_num = gv_cal_rec.yr_num AND
                        effective_start_dt = gv_cal_rec.effective_start_dt;
        CURSOR        c_co_rec IS
                SELECT         *
                FROM        IGS_PS_OFR
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number;
        CURSOR        gc_coo_rec IS
                SELECT        *
                FROM           IGS_PS_OFR_OPT
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number AND
                        cal_type = gv_co_rec.cal_type
                        AND delete_flag = 'N';

        CURSOR        gc_ceprcd_rec IS
                SELECT        *
                FROM           IGS_PS_ENT_PT_REF_CD
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number AND
                        cal_type = gv_coo_rec.cal_type AND
                        location_cd = gv_coo_rec.location_cd AND
                        attendance_mode = gv_coo_rec.attendance_mode AND
                        attendance_type = gv_coo_rec.attendance_type;
        -- Only interested in notes that are not OLE type as
        -- currently unable to copy long raw field within PL/SQL
        CURSOR        gc_con_rec IS
                SELECT        *
                FROM           IGS_PS_OFR_NOTE con
                WHERE        con.course_cd = p_old_course_cd AND
                        con.version_number = p_old_version_number AND
                        cal_type = gv_co_rec.cal_type AND
                        EXISTS        (SELECT 1
                                FROM        IGS_GE_NOTE nte
                                WHERE        nte.reference_number = con.reference_number AND
                                        nte.note_text IS NOT NULL);
        -- Only interested in notes that are not OLE type as
        -- currently unable to copy long raw field within PL/SQL
        CURSOR        gc_coon_rec IS
                SELECT        *
                FROM           IGS_PS_OFR_OPT_NOTE coon
                WHERE        coon.course_cd = p_old_course_cd AND
                        coon.version_number = p_old_version_number AND
                        coon.cal_type = gv_coo_rec.cal_type AND
                        coon.location_cd = gv_coo_rec.location_cd AND
                        coon.attendance_mode = gv_coo_rec.attendance_mode AND
                        coon.attendance_type = gv_coo_rec.attendance_type AND
                        EXISTS        (SELECT 1
                                FROM        IGS_GE_NOTE nte
                                WHERE        nte.reference_number = coon.reference_number AND
                                        nte.note_text IS NOT NULL);
        -- Find the latest IGS_CA_INST of IGS_PS_OFR_INST
        -- which returns the list in descending order, and the first record
        -- (ie. the latest instance) will be selected
        CURSOR        gc_coi_rec IS
                SELECT         *
                FROM        IGS_PS_OFR_INST coi
                WHERE        coi.course_cd = p_old_course_cd AND
                        coi.version_number = p_old_version_number AND
                        coi.cal_type = gv_co_rec.cal_type
                ORDER BY coi.ci_end_dt DESC, coi.ci_start_dt DESC;
        CURSOR        gc_cop_rec IS
                SELECT  *
                FROM        IGS_PS_OFR_PAT
                WHERE        course_cd = p_old_course_cd AND
                        version_number = p_old_version_number AND
                        cal_type = gv_coi_rec.cal_type AND
                        ci_sequence_number = gv_coi_rec.ci_sequence_number;
        -- Only interested in notes that are not OLE type as
        -- currently unable to copy long raw field within PL/SQL
        CURSOR  gc_copn_rec IS
                SELECT        *
                FROM         IGS_PS_OFR_PAT_NOTE cop
                WHERE        cop.cop_id = gv_cop_rec.cop_id AND
                        EXISTS        (SELECT 1
                                FROM        IGS_GE_NOTE nte
                                WHERE        nte.reference_number = cop.reference_number AND
                                                nte.note_text IS NOT NULL);

        -- Removed cursor gc_revseg_rec as part of Enh# 2831572.

        CURSOR  gc_ref_num IS
                SELECT         IGS_GE_NOTE_RF_NUM_S.NEXTVAL
                FROM        DUAL;
        CURSOR  gc_coo_seq_num IS
                SELECT         IGS_PS_OFR_OPT_COO_ID_S.NEXTVAL
                FROM        DUAL;

        -- procedure for inserting new IGS_GE_NOTE and IGS_PS_OFR_OPT_NOTE records
        PROCEDURE crsp_ins_coon_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS

                CURSOR Cur_SGN IS
                                SELECT rowid,IGS_GE_NOTE.*
                                FROM IGS_GE_NOTE
                                WHERE reference_number = gv_coon_rec.reference_number;
        BEGIN
                OPEN  gc_ref_num;
                FETCH gc_ref_num INTO gv_ref_num;
                CLOSE gc_ref_num;
                -- inserting IGS_GE_NOTE record with this next reference_number
                -- Currently unable to copy Long Raw columns in PL/SQL.

                For SGN_Rec in CUR_SGN
                Loop
                        x_rowid        :=        NULL;
                        IGS_GE_NOTE_PKG.INSERT_ROW(
                                                X_ROWID               => X_ROWID,
                                                X_REFERENCE_NUMBER    =>gv_ref_num,
                                                X_S_NOTE_FORMAT_TYPE  =>SGN_Rec.s_note_format_type,
                                                X_NOTE_TEXT           =>SGN_Rec.note_text,
                                                X_MODE                =>'R');
                End Loop;


                -- inserting IGS_PS_OFR_OPT_NOTE records
                x_rowid        :=        NULL;
                IGS_PS_OFR_OPT_NOTE_PKG.INSERT_ROW(
                        X_ROWID             =>  X_ROWID,
                        X_COURSE_CD         =>         p_new_course_cd,
                        X_VERSION_NUMBER    =>         p_new_version_number,
                        X_CAL_TYPE          =>         gv_coon_rec.cal_type,
                        X_ATTENDANCE_MODE   =>         gv_coon_rec.attendance_mode,
                        X_REFERENCE_NUMBER  =>        gv_ref_num,
                        X_ATTENDANCE_TYPE   =>         gv_coon_rec.attendance_type,
                        X_LOCATION_CD       =>         gv_coon_rec.location_cd,
                        X_COO_ID            =>         gv_coo_seq_num,
                        X_CRS_NOTE_TYPE     =>         gv_coon_rec.crs_note_type,
                        X_MODE              =>        'R'
                        );

        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_coon_rec;
        -- procedure for inserting new IGS_GE_NOTE and IGS_PS_OFR_PAT_NOTE records

        PROCEDURE crsp_ins_copn_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        CURSOR Cur_SGN
        IS
        SELECT
                rowid , IGS_GE_NOTE.*
        FROM
                IGS_GE_NOTE
        WHERE
                reference_number = gv_copn_rec.reference_number;
        BEGIN
                -- select the next reference_number from the system
                OPEN  gc_ref_num;
                FETCH gc_ref_num INTO gv_ref_num;
                CLOSE gc_ref_num;
                -- inserting IGS_GE_NOTE record with this next reference_number
                -- Currently unable to copy Long Raw columns in PL/SQL.
                FOR Rec_SGN IN Cur_SGN        LOOP
                        x_rowid        :=        NULL;
                        IGS_GE_NOTE_PKG.INSERT_ROW(
                                X_ROWID              => x_rowid,
                                X_REFERENCE_NUMBER   =>        gv_ref_num,
                                X_S_NOTE_FORMAT_TYPE =>        Rec_SGN.s_note_format_type,
                                X_NOTE_TEXT          =>        Rec_SGN.note_text,
                                X_MODE               => 'R'
                                );
                END LOOP;

                -- inserting IGS_PS_OFR_PAT_NOTE records
                x_rowid        :=        NULL;
                IGS_PS_OFR_PAT_NOTE_PKG.INSERT_ROW(
                        X_ROWID               =>        x_rowid,
                        X_COURSE_CD           =>         p_new_course_cd,
                        X_CI_SEQUENCE_NUMBER  =>         gv_copn_rec.ci_sequence_number,
                        X_CAL_TYPE            =>         gv_copn_rec.cal_type,
                        X_VERSION_NUMBER      =>         p_new_version_number,
                        X_LOCATION_CD         =>         gv_copn_rec.location_cd,
                        X_ATTENDANCE_TYPE     =>         gv_copn_rec.attendance_type,
                        X_REFERENCE_NUMBER    =>         gv_ref_num,
                        X_ATTENDANCE_MODE     =>         gv_copn_rec.attendance_mode,
                        X_COP_ID              =>         gv_cop_seq_num,
                        X_CRS_NOTE_TYPE       =>        gv_copn_rec.crs_note_type,
                        X_MODE                =>         'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_copn_rec;
        -- procedure for inserting new IGS_GE_NOTE and IGS_PS_OFR_PAT records

        PROCEDURE crsp_ins_cop_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
        DECLARE
                v_gs_version_number        IGS_AS_GRD_SCHEMA.version_number%TYPE;
                v_message_name                VARCHAR2(30);
                CURSOR c_latest_gs_version (
                        cp_gs_cd                IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE) IS
                        SELECT        MAX(gs.version_number)
                        FROM        IGS_AS_GRD_SCHEMA        gs
                        WHERE        gs.grading_schema_cd        = cp_gs_cd;
        BEGIN
                -- select the next sequence_number from the system
                SELECT         IGS_PS_OFR_PAT_COP_ID_S.NEXTVAL
                INTO        gv_cop_seq_num
                FROM        DUAL;
                -- get the latest grading schema version number
                OPEN c_latest_gs_version (
                                gv_cop_rec.grading_schema_cd);
                FETCH c_latest_gs_version INTO v_gs_version_number;
                CLOSE c_latest_gs_version;
                IF IGS_AS_VAL_GSG.assp_val_gs_cur_fut (
                                                gv_cop_rec.grading_schema_cd,
                                                v_gs_version_number,
                                                v_message_name) = FALSE THEN
                        -- The latest grading schema fails the current or vuture valildation
                        gv_cop_rec.grading_schema_cd := NULL;
                        gv_cop_rec.gs_version_number := NULL;
                ELSE
                        gv_cop_rec.gs_version_number := v_gs_version_number;
                END IF;
                -- check if a IGS_PE_PERSON fails the staff IGS_PE_PERSON validation
                IF igs_ad_val_acai.genp_val_staff_prsn (
                                        gv_cop_rec.adm_ass_officer_person_id,
                                        v_message_name) = FALSE THEN
                        gv_cop_rec.adm_ass_officer_person_id := NULL;
                END IF;
                IF igs_ad_val_acai.genp_val_staff_prsn (
                                        gv_cop_rec.adm_contact_person_id,
                                        v_message_name) = FALSE THEN
                        gv_cop_rec.adm_contact_person_id := NULL;
                END IF;
                -- inserting IGS_PS_OFR_PAT records with this next sequence_number
                x_rowid        :=        NULL;
                IGS_PS_OFR_PAT_PKG.INSERT_ROW(
                        X_ROWID                         =>                X_ROWID,
                        X_COURSE_CD                     =>               p_new_course_cd,
                        X_CI_SEQUENCE_NUMBER            =>               gv_cop_rec.ci_sequence_number,
                        X_CAL_TYPE                      =>               gv_cop_rec.cal_type,
                        X_VERSION_NUMBER                =>               p_new_version_number,
                        X_LOCATION_CD                   =>               gv_cop_rec.location_cd,
                        X_ATTENDANCE_TYPE               =>               gv_cop_rec.attendance_type,
                        X_ATTENDANCE_MODE               =>               gv_cop_rec.attendance_mode,
                        X_COP_ID                        =>               gv_cop_seq_num,
                        X_COO_ID                        =>               gv_coo_seq_num,
                        X_OFFERED_IND                   =>               gv_cop_rec.offered_ind,
                        X_CONFIRMED_OFFERING_IND        =>               gv_cop_rec.confirmed_offering_ind,
                        X_ENTRY_POINT_IND               =>               gv_cop_rec.entry_point_ind,
                        X_PRE_ENROL_UNITS_IND           =>               gv_cop_rec.pre_enrol_units_ind,
                        X_ENROLLABLE_IND                =>               gv_cop_rec.enrollable_ind,
                        X_IVRS_AVAILABLE_IND                    =>               gv_cop_rec.ivrs_available_ind,
                        X_MIN_ENTRY_ASS_SCORE           =>               NULL,
                        X_GUARANTEED_ENTRY_ASS_SCR        =>                    NULL,
                        X_MAX_CROSS_FACULTY_CP          =>                 NULL,
                        X_MAX_CROSS_LOCATION_CP         =>                 NULL,
                        X_MAX_CROSS_MODE_CP             =>                 NULL,
                        X_MAX_HIST_CROSS_FACULTY_CP     =>                 NULL,
                        X_ADM_ASS_OFFICER_PERSON_ID     =>                 gv_cop_rec.adm_ass_officer_person_id,
                        X_ADM_CONTACT_PERSON_ID         =>                 gv_cop_rec.adm_contact_person_id,
                        X_GRADING_SCHEMA_CD             =>                 gv_cop_rec.grading_schema_cd,
                        X_GS_VERSION_NUMBER             =>                gv_cop_rec.gs_version_number,
                        X_MODE                          =>                 'R'
                );
                -- calling procedure to insert IGS_PS_OFR_PAT_NOTE records
                -- associated with each IGS_PS_OFR_PAT record
                OPEN gc_copn_rec;
                LOOP
                        FETCH gc_copn_rec INTO gv_copn_rec;
                        IF gc_copn_rec%FOUND THEN
                                crsp_ins_copn_rec(p_new_course_cd, p_new_version_number);
                        ELSE
                                EXIT;
                        END IF;
                END LOOP;
                CLOSE gc_copn_rec;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_latest_gs_version%ISOPEN THEN
                                CLOSE c_latest_gs_version;
                        END IF;
                        IF gc_copn_rec%ISOPEN THEN
                                CLOSE gc_copn_rec;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_cop_rec;
        -- procedure for inserting new IGS_GE_NOTE and IGS_PS_OFR_NOTE records
        PROCEDURE crsp_ins_con_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        CURSOR
                Cur_SGN
        IS
        SELECT
                rowid,IGS_GE_NOTE.*
        FROM
                IGS_GE_NOTE
        WHERE
                reference_number = gv_con_rec.reference_number;

        BEGIN
                -- select the next reference_number from the system
                OPEN  gc_ref_num;
                FETCH gc_ref_num INTO gv_ref_num;
                CLOSE gc_ref_num;
                -- inserting IGS_GE_NOTE record with this next reference_number
                -- Currently unable to copy Long Raw columns in PL/SQL.
                For Rec_SGN IN Cur_SGN        LOOP
                        x_rowid        :=        NULL;
                        IGS_GE_NOTE_PKG.INSERT_ROW(
                                X_ROWID               => x_rowid,
                                X_REFERENCE_NUMBER    => gv_ref_num,
                                X_S_NOTE_FORMAT_TYPE  => Rec_SGN.s_note_format_type,
                                X_NOTE_TEXT           => Rec_SGN.note_text,
                                X_MODE                => 'R'
                                );
                END LOOP;
                -- inserting IGS_PS_OFR_NOTE records
                x_rowid        :=        NULL;
                IGS_PS_OFR_NOTE_PKG.INSERT_ROW (
                        X_ROWID              =>          x_rowid,
                        X_COURSE_CD          =>          p_new_course_cd,
                        X_REFERENCE_NUMBER   =>          gv_ref_num,
                        X_CAL_TYPE           =>          gv_con_rec.cal_type,
                        X_VERSION_NUMBER     =>          p_new_version_number,
                        X_CRS_NOTE_TYPE      =>          gv_con_rec.crs_note_type,
                        X_MODE                   =>         'R'
                        );
            EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_con_rec;
        -- procedure for inserting new IGS_PS_ENT_PT_REF_CD records
        PROCEDURE crsp_ins_ceprcd_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                x_rowid        :=        NULL;
                IGS_PS_ENT_PT_REF_CD_PKG.INSERT_ROW(
                        X_ROWID                     =>          x_rowid,
                        X_COURSE_CD                 =>           p_new_course_cd,
                        X_SEQUENCE_NUMBER              =>        gv_ceprcd_rec.sequence_number,
                        X_REFERENCE_CD_TYPE            =>        gv_ceprcd_rec.reference_cd_type,
                        X_ATTENDANCE_TYPE              =>        gv_ceprcd_rec.attendance_type,
                        X_CAL_TYPE                     =>        gv_ceprcd_rec.cal_type,
                        X_LOCATION_CD                  =>        gv_ceprcd_rec.location_cd,
                        X_VERSION_NUMBER               =>        p_new_version_number,
                        X_ATTENDANCE_MODE              =>        gv_ceprcd_rec.attendance_mode,
                        X_COO_ID                       =>        gv_coo_seq_num,
                        X_UNIT_SET_CD                  =>        gv_ceprcd_rec.unit_set_cd,
                        X_US_VERSION_NUMBER            =>        gv_ceprcd_rec.us_version_number,
                        X_REFERENCE_CD                 =>        gv_ceprcd_rec.reference_cd,
                        X_DESCRIPTION                  =>        gv_ceprcd_rec.description,
                        X_MODE                         =>        'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_ceprcd_rec;
        PROCEDURE crspl_ins_cooac_rec
        IS
        BEGIN
        DECLARE
                CURSOR c_cooac IS
                        SELECT         cooac.cal_type,
                                 cooac.location_cd,
                                 cooac.attendance_mode,
                                 cooac.attendance_type,
                                 cooac.admission_cat,
                                cooac.system_default_ind
                        FROM        IGS_PS_OF_OPT_AD_CAT cooac
                        WHERE        cooac.course_cd                = p_old_course_cd AND
                                cooac.version_number        = p_old_version_number AND
                                cooac.cal_type                = gv_coo_rec.cal_type AND
                                cooac.location_cd                = gv_coo_rec.location_cd AND
                                cooac.attendance_mode        = gv_coo_rec.attendance_mode AND
                                cooac.attendance_type        = gv_coo_rec.attendance_type;
                CURSOR c_cacus (
                                cp_cooac_cal_type                IGS_PS_OF_OPT_AD_CAT.cal_type%TYPE,
                                cp_cooac_location_cd                IGS_PS_OF_OPT_AD_CAT.location_cd%TYPE,
                                cp_cooac_attendance_mode        IGS_PS_OF_OPT_AD_CAT.attendance_mode%TYPE,
                                cp_cooac_attendance_type        IGS_PS_OF_OPT_AD_CAT.attendance_type%TYPE,
                                cp_cooac_admission_cat                IGS_PS_OF_OPT_AD_CAT.admission_cat%TYPE) IS
                        SELECT         cacus.cal_type,
                                 cacus.location_cd,
                                 cacus.attendance_mode,
                                 cacus.attendance_type,
                                 cacus.admission_cat,
                                 cacus.unit_set_cd,
                                 cacus.us_version_number
                        FROM        IGS_PS_COO_AD_UNIT_S cacus
                        WHERE        cacus.course_cd                        = p_old_course_cd AND
                                cacus.crv_version_number        = p_old_version_number AND
                                cacus.cal_type                        = cp_cooac_cal_type AND
                                cacus.location_cd                        = cp_cooac_location_cd AND
                                cacus.attendance_mode                = cp_cooac_attendance_mode AND
                                cacus.attendance_type                = cp_cooac_attendance_type AND
                                cacus.admission_cat                = cp_cooac_admission_cat;
        BEGIN
                FOR v_cooac_rec IN c_cooac LOOP
                        BEGIN
                                x_rowid        :=        NULL;
                                IGS_PS_OF_OPT_AD_CAT_PKG.INSERT_ROW(
                                        X_ROWID                =>         x_rowid,
                                        X_COURSE_CD            =>        p_new_course_cd,
                                        X_VERSION_NUMBER       =>        p_new_version_number,
                                        X_CAL_TYPE             =>        v_cooac_rec.cal_type,
                                        X_LOCATION_CD          =>        v_cooac_rec.location_cd,
                                        X_ATTENDANCE_TYPE      =>        v_cooac_rec.attendance_type,
                                        X_ATTENDANCE_MODE      =>        v_cooac_rec.attendance_mode,
                                        X_ADMISSION_CAT        =>        v_cooac_rec.admission_cat,
                                        X_COO_ID               =>        gv_coo_seq_num,
                                        X_SYSTEM_DEFAULT_IND   =>        v_cooac_rec.system_default_ind,
                                        X_MODE                 =>        'R'
                                        );
                                FOR v_cacus_rec IN c_cacus(
                                                        v_cooac_rec.cal_type,
                                                        v_cooac_rec.location_cd,
                                                        v_cooac_rec.attendance_mode,
                                                        v_cooac_rec.attendance_type,
                                                        v_cooac_rec.admission_cat) LOOP

                                        x_rowid        :=        NULL;
                                        IGS_PS_COO_AD_UNIT_S_PKG.INSERT_ROW(
                                                X_ROWID               =>        x_rowid,
                                                X_COURSE_CD           =>        p_new_course_cd,
                                                X_CRV_VERSION_NUMBER  =>         p_new_version_number,
                                                X_CAL_TYPE            =>         v_cacus_rec.cal_type,
                                                X_LOCATION_CD         =>         v_cacus_rec.location_cd,
                                                X_ATTENDANCE_MODE     =>         v_cacus_rec.attendance_mode,
                                                X_ATTENDANCE_TYPE     =>         v_cacus_rec.attendance_type,
                                                X_ADMISSION_CAT       =>         v_cacus_rec.admission_cat,
                                                X_UNIT_SET_CD         =>         v_cacus_rec.unit_set_cd,
                                                X_US_VERSION_NUMBER   =>         v_cacus_rec.us_version_number,
                                                X_MODE                =>         'R'
                                        );

                                END LOOP;
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_max_error_range AND
                                                        SQLCODE <= cst_min_error_range THEN
                                                p_message_name := cst_ret_message_name;
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_cooac%ISOPEN) THEN
                                CLOSE c_cooac;
                        END IF;
                        IF (c_cacus%ISOPEN) THEN
                                CLOSE c_cacus;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_max_error_range AND
                                        SQLCODE <= cst_min_error_range THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_cooac_rec;
        -- procedure for inserting new IGS_PS_OFR_OPT records
        --modified by shtatiko on 21-OCT-2002 to incorporate the addition of two new columns to IGS_PS_OFR_OPT viz. program_length, program_length_measurement.
        --this has been done as per bug# 2608227.
        PROCEDURE crsp_ins_coo_rec(
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
        DECLARE
                CURSOR c_coous IS
                        SELECT  coous.cal_type,
                                coous.location_cd,
                                coous.attendance_mode,
                                coous.attendance_type,
                                coous.unit_set_cd,
                                coous.us_version_number
                        FROM        IGS_PS_OF_OPT_UNT_ST coous
                        WHERE        coous.course_cd                 = p_old_course_cd AND
                                coous.crv_version_number = p_old_version_number AND
                                coous.cal_type                 = gv_coo_rec.cal_type AND
                                coous.location_cd                 = gv_coo_rec.location_cd AND
                                coous.attendance_mode         = gv_coo_rec.attendance_mode AND
                                coous.attendance_type         = gv_coo_rec.attendance_type AND
                                EXISTS        (SELECT        'X'
                                                 FROM                IGS_PS_OFR_UNIT_SET cous
                                                 WHERE        cous.course_cd                = p_new_course_cd AND
                                                                cous.crv_version_number        = p_new_version_number AND
                                                                cous.cal_type                = coous.cal_type AND
                                                                cous.unit_set_cd                = coous.unit_set_cd AND
                                                                cous.us_version_number        = coous.us_version_number);
                l_org_id                NUMBER(15);
        BEGIN
                -- select the next IGS_PS_OFR_OPT reference_number
                -- from the system
                OPEN  gc_coo_seq_num;
                FETCH gc_coo_seq_num INTO gv_coo_seq_num;
                CLOSE gc_coo_seq_num;
                x_rowid        :=        NULL;
                l_org_id := IGS_GE_GEN_003.GET_ORG_ID;
                IGS_PS_OFR_OPT_PKG.INSERT_ROW(
                        X_ROWID                    =>                x_rowid,
                        X_COURSE_CD                =>            p_new_course_cd,
                        X_VERSION_NUMBER           =>            p_new_version_number,
                        X_CAL_TYPE                 =>            gv_coo_rec.cal_type,
                        X_ATTENDANCE_MODE          =>            gv_coo_rec.attendance_mode,
                        X_ATTENDANCE_TYPE          =>            gv_coo_rec.attendance_type,
                        X_LOCATION_CD              =>            gv_coo_rec.location_cd,
                        X_COO_ID                   =>            gv_coo_seq_num,
                        X_FORCED_LOCATION_IND      =>            gv_coo_rec.forced_location_ind,
                        X_FORCED_ATT_MODE_IND      =>            gv_coo_rec.forced_att_mode_ind,
                        X_FORCED_ATT_TYPE_IND      =>            gv_coo_rec.forced_att_type_ind,
                        X_TIME_LIMITATION          =>            gv_coo_rec.time_limitation,
                        X_ENR_OFFICER_PERSON_ID    =>            gv_coo_rec.enr_officer_person_id,
                        X_ATTRIBUTE_CATEGORY       =>                gv_coo_rec.attribute_category,
                        X_ATTRIBUTE1                   =>                gv_coo_rec.attribute1,
                        X_ATTRIBUTE2                   =>                gv_coo_rec.attribute2,
                        X_ATTRIBUTE3                   =>                gv_coo_rec.attribute3,
                        X_ATTRIBUTE4                   =>                gv_coo_rec.attribute4,
                        X_ATTRIBUTE5                   =>                gv_coo_rec.attribute5,
                        X_ATTRIBUTE6                   =>                gv_coo_rec.attribute6,
                        X_ATTRIBUTE7                   =>                gv_coo_rec.attribute7,
                        X_ATTRIBUTE8                   =>                gv_coo_rec.attribute8,
                        X_ATTRIBUTE9                   =>                gv_coo_rec.attribute9,
                        X_ATTRIBUTE10                   =>                gv_coo_rec.attribute10,
                        X_ATTRIBUTE11                   =>                gv_coo_rec.attribute11,
                        X_ATTRIBUTE12                   =>                gv_coo_rec.attribute12,
                        X_ATTRIBUTE13                   =>                gv_coo_rec.attribute13,
                        X_ATTRIBUTE14                   =>                gv_coo_rec.attribute14,
                        X_ATTRIBUTE15                   =>                gv_coo_rec.attribute15,
                        X_ATTRIBUTE16                   =>                gv_coo_rec.attribute16,
                        X_ATTRIBUTE17                   =>                gv_coo_rec.attribute17,
                        X_ATTRIBUTE18                   =>                gv_coo_rec.attribute18,
                        X_ATTRIBUTE19                   =>                gv_coo_rec.attribute19,
                        X_ATTRIBUTE20                   =>                gv_coo_rec.attribute20,
                          X_MODE                     =>                'R',
                          X_ORG_ID                    =>                l_org_id ,
                        x_program_length           =>                gv_coo_rec.program_length, --added as per bug# 2608227
                        x_program_length_measurement           =>                gv_coo_rec.program_length_measurement  --added as per bug# 2608227
                        );
                -- calling procedure to insert IGS_PS_OFR_OPT_NOTE records
                -- associated with each IGS_PS_OFR_OPT record
                OPEN gc_coon_rec;
                LOOP
                        FETCH gc_coon_rec INTO gv_coon_rec;
                        IF gc_coon_rec%FOUND THEN
                                crsp_ins_coon_rec(p_new_course_cd, p_new_version_number);
                        ELSE
                                EXIT;
                        END IF;
                END LOOP;
                CLOSE gc_coon_rec;
                -- calling procedure to insert IGS_PS_ENT_PT_REF_CD records
                -- associated with each IGS_PS_OFR instance record
                 OPEN gc_ceprcd_rec;
                LOOP
                           FETCH gc_ceprcd_rec INTO gv_ceprcd_rec;
                        IF gc_ceprcd_rec%FOUND THEN
                                crsp_ins_ceprcd_rec(p_new_course_cd, p_new_version_number);
                        ELSE
                                EXIT;
                        END IF;
                END LOOP;
                CLOSE gc_ceprcd_rec;
                FOR v_coous_rec IN c_coous LOOP
                        x_rowid        :=        NULL;
                        IGS_PS_OF_OPT_UNT_ST_PKG.INSERT_ROW(
                                X_ROWID                =>                x_rowid,
                                X_COURSE_CD            =>                p_new_course_cd,
                                X_LOCATION_CD          =>                v_coous_rec.location_cd,
                                X_ATTENDANCE_MODE      =>                v_coous_rec.attendance_mode,
                                X_CAL_TYPE             =>                 v_coous_rec.cal_type,
                                X_CRV_VERSION_NUMBER   =>                p_new_version_number,
                                X_ATTENDANCE_TYPE      =>                v_coous_rec.attendance_type,
                                X_US_VERSION_NUMBER    =>                v_coous_rec.us_version_number,
                                X_UNIT_SET_CD          =>                v_coous_rec.unit_set_cd,
                                X_COO_ID               =>                gv_coo_seq_num,
                                X_MODE                 =>                'R'
                                );
                END LOOP; -- coous
                -- calling procedure to insert IGS_PS_OF_OPT_AD_CAT records
                -- and its child table IGS_PS_COO_AD_UNIT_S
                crspl_ins_cooac_rec;
        EXCEPTION
                WHEN OTHERS THEN
                        IF ( gc_coo_seq_num%ISOPEN) THEN
                                CLOSE gc_coo_seq_num;
                        END IF;
                        IF ( gc_ceprcd_rec%ISOPEN) THEN
                                CLOSE gc_ceprcd_rec;
                        END IF;
                        IF ( gc_ceprcd_rec%ISOPEN) THEN
                                CLOSE gc_ceprcd_rec;
                        END IF;
                        IF (c_coous%ISOPEN) THEN
                                CLOSE c_coous;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_coo_rec;
        -- procedure for inserting new IGS_PS_OFR_INST records
        PROCEDURE crsp_ins_coi_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE)
        IS
        BEGIN
        DECLARE
                CURSOR c_coo_new (
                        cp_cal_type                IGS_PS_OFR_OPT.cal_type%TYPE,
                        cp_location_cd                IGS_PS_OFR_OPT.location_cd%TYPE,
                        cp_attendance_mode        IGS_PS_OFR_OPT.attendance_mode%TYPE,
                        cp_attendance_type        IGS_PS_OFR_OPT.attendance_type%TYPE) IS
                        SELECT        'x'
                        FROM        IGS_PS_OFR_OPT        coo
                        WHERE        coo.course_cd                = p_new_course_cd        AND
                                coo.version_number        = p_new_version_number        AND
                                coo.cal_type                = cp_cal_type                AND
                                coo.location_cd                = cp_location_cd        AND
                                coo.attendance_mode        = cp_attendance_mode        AND
                                coo.attendance_type        = cp_attendance_type    AND
                                coo.delete_flag         = 'N';
                v_dummy                VARCHAR2(1);
        BEGIN
                x_rowid        := NULL;
                IGS_PS_OFR_INST_PKG.INSERT_ROW(
                        X_ROWID                     =>        x_rowid,
                        X_COURSE_CD                 =>           p_new_course_cd,
                        X_VERSION_NUMBER            =>           p_new_version_number,
                        X_CAL_TYPE                  =>           gv_coi_rec.cal_type,
                        X_CI_SEQUENCE_NUMBER        =>           gv_coi_rec.ci_sequence_number,
                        X_CI_START_DT               =>           gv_coi_rec.ci_start_dt,
                        X_CI_END_DT                 =>           gv_coi_rec.ci_end_dt,
                        X_MIN_ENTRY_ASS_SCORE       =>           gv_coi_rec.min_entry_ass_score,
                        X_GUARANTEED_ENTRY_ASS_SCR  =>           gv_coi_rec.guaranteed_entry_ass_scr,
                        X_MODE                      =>        'R' );
                -- calling procedure to insert IGS_PS_OFR_PAT records
                -- associated with each IGS_PS_OFR instance record
                OPEN gc_cop_rec;
                LOOP
                        FETCH gc_cop_rec INTO gv_cop_rec;
                        IF gc_cop_rec%FOUND THEN
                                -- check COO paraents exists
                                OPEN c_coo_new (
                                                gv_cop_rec.cal_type,
                                                gv_cop_rec.location_cd,
                                                gv_cop_rec.attendance_mode,
                                                gv_cop_rec.attendance_type);
                                FETCH c_coo_new INTO v_dummy;
                                IF c_coo_new%FOUND THEN
                                        -- coo paraents exists then process this record
                                        CLOSE c_coo_new;
                                        crsp_ins_cop_rec(
                                                        p_new_course_cd,
                                                        p_new_version_number);
                                ELSE
                                        p_message_name := cst_ret_message_name;
                                        CLOSE c_coo_new;
                                END IF;
                        ELSE
                                EXIT;
                        END IF;
                END LOOP;
                CLOSE gc_cop_rec;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_coo_new%ISOPEN THEN
                                CLOSE c_coo_new;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_coi_rec;
        -- inserts into IGS_PS_PAT_OF_STUDY and its child tables including
        -- IGS_PS_PAT_STUDY_PRD and IGS_PS_PAT_STUDY_UNT
        PROCEDURE crspl_ins_pos_rec
        IS
	--WHo      When         WHAT
	--sarakshi 15-May-2006  Bug#3460640,modified the call to IGS_PS_PAT_STUDY_PRD_PKG.INSERT_ROW with correct values
        BEGIN
        DECLARE
                v_pos_seq_num                        IGS_PS_PAT_OF_STUDY.sequence_number%TYPE;
                v_posp_seq_num                        IGS_PS_PAT_STUDY_PRD.sequence_number%TYPE;
                v_posu_seq_num                        IGS_PS_PAT_STUDY_UNT.sequence_number%TYPE;
                CURSOR c_pos_seq_num IS
                        SELECT IGS_PS_PAT_OF_STUDY_POS_NUM_S.NEXTVAL
                        FROM         DUAL;
                CURSOR c_posp_seq_num IS
                        SELECT IGS_PS_PAT_STUDY_UNT_POSPSEQ_S.NEXTVAL
                        FROM         DUAL;
                CURSOR c_posu_seq_num IS
                        SELECT IGS_PS_PAT_STUDY_UNT_SEQ_NUM_S.NEXTVAL
                        FROM         DUAL;
                CURSOR c_pos IS
                        SELECT         pos.cal_type,
                                 pos.sequence_number,
                                 pos.location_cd,
                                 pos.attendance_mode,
                                 pos.attendance_type,
                                 pos.unit_set_cd,
                                 pos.admission_cal_type,
                                 pos.admission_cat,
                                 pos.aprvd_ci_sequence_number,
                                 pos.number_of_periods,
                                 pos.always_pre_enrol_ind,
                                 pos.acad_perd_unit_set
                        FROM        IGS_PS_PAT_OF_STUDY pos
                        WHERE        pos.course_cd                = p_old_course_cd AND
                                pos.version_number        = p_old_version_number AND
                                pos.cal_type                = gv_co_rec.cal_type;
                CURSOR c_posp (
                                cp_pos_seq_num                IGS_PS_PAT_OF_STUDY.sequence_number%TYPE) IS
                        SELECT         posp.cal_type,
                                posp.pos_sequence_number,
                                posp.sequence_number,
                                posp.acad_period_num,
                                posp.teach_cal_type,
                                posp.description
                        FROM        IGS_PS_PAT_STUDY_PRD posp
                        WHERE        posp.course_cd                = p_old_course_cd AND
                                posp.version_number        = p_old_version_number AND
                                posp.cal_type                = gv_co_rec.cal_type AND
                                posp.pos_sequence_number = cp_pos_seq_num;
                CURSOR c_posu (
                                cp_pos_seq_num                IGS_PS_PAT_OF_STUDY.sequence_number%TYPE,
                                cp_posp_seq_num                IGS_PS_PAT_STUDY_PRD.sequence_number%TYPE) IS
                        SELECT        posu.cal_type,
                                 posu.pos_sequence_number,
                                 posu.posp_sequence_number,
                                 posu.sequence_number,
                                 posu.unit_cd,
                                 posu.unit_location_cd,
                                 posu.unit_class,
                                 posu.description,
                                posu.core_ind
                        FROM        IGS_PS_PAT_STUDY_UNT posu
                        WHERE        posu.course_cd                        = p_old_course_cd AND
                                posu.version_number                = p_old_version_number AND
                                posu.cal_type                        = gv_co_rec.cal_type AND
                                posu.pos_sequence_number         = cp_pos_seq_num        AND
                                posu.posp_sequence_number         = cp_posp_seq_num;
        BEGIN
                FOR v_pos_rec IN c_pos LOOP
                        BEGIN
                                OPEN c_pos_seq_num;
                                FETCH c_pos_seq_num INTO v_pos_seq_num;
                                CLOSE c_pos_seq_num;
                                X_ROWID := NULL;
                                IGS_PS_PAT_OF_STUDY_PKG.INSERT_ROW(
                                        X_ROWID                                  =>        x_rowid,
                                        X_COURSE_CD                   =>         p_new_course_cd,
                                        X_CAL_TYPE                    =>         v_pos_rec.cal_type,
                                        X_VERSION_NUMBER              =>         p_new_version_number,
                                        X_SEQUENCE_NUMBER             =>         v_pos_seq_num,
                                        X_LOCATION_CD                 =>         v_pos_rec.location_cd,
                                        X_ATTENDANCE_MODE             =>         v_pos_rec.attendance_mode,
                                        X_ATTENDANCE_TYPE             =>         v_pos_rec.attendance_type,
                                        X_UNIT_SET_CD                 =>         v_pos_rec.unit_set_cd,
                                        X_ADMISSION_CAL_TYPE          =>         v_pos_rec.admission_cal_type,
                                        X_ADMISSION_CAT               =>         v_pos_rec.admission_cat,
                                        X_APRVD_CI_SEQUENCE_NUMBER    =>         v_pos_rec.aprvd_ci_sequence_number,
                                        X_NUMBER_OF_PERIODS           =>         v_pos_rec.number_of_periods,
                                        X_ALWAYS_PRE_ENROL_IND        =>         v_pos_rec.always_pre_enrol_ind,
                                        X_acad_perd_unit_set         =>         v_pos_rec.acad_perd_unit_set,
                                        X_MODE                        =>        'R'
                                        );
                                -- inserts into pattern_of_study_period table
                                FOR v_posp_rec IN c_posp (
                                                        v_pos_rec.sequence_number) LOOP
                                        OPEN c_posp_seq_num;
                                        FETCH c_posp_seq_num INTO v_posp_seq_num;
                                        CLOSE c_posp_seq_num;
                                        x_rowid := NULL;
                                        IGS_PS_PAT_STUDY_PRD_PKG.INSERT_ROW(
                                                X_ROWID                 =>               x_rowid,
                                                X_COURSE_CD             =>               p_new_course_cd,
                                                X_VERSION_NUMBER        =>               p_new_version_number,
                                                X_POS_SEQUENCE_NUMBER   =>               v_pos_seq_num,--this is the FK
                                                X_SEQUENCE_NUMBER       =>               v_posp_seq_num,--this is the PK
                                                X_CAL_TYPE              =>               v_posp_rec.cal_type,
                                                X_ACAD_PERIOD_NUM       =>               v_posp_rec.acad_period_num,
                                                X_TEACH_CAL_TYPE        =>               v_posp_rec.teach_cal_type,
                                                X_DESCRIPTION           =>               v_posp_rec.description,
                                                X_MODE                  =>                'R'
                                                );
                                        -- inserts into IGS_PS_PAT_STUDY_UNT table
                                        FOR v_posu_rec IN c_posu (
                                                v_pos_rec.sequence_number,
                                                v_posp_rec.sequence_number) LOOP
                                                OPEN c_posu_seq_num;
                                                FETCH c_posu_seq_num INTO v_posu_seq_num;
                                                CLOSE c_posu_seq_num;
                                                x_rowid := NULL;
                                                IGS_PS_PAT_STUDY_UNT_PKG.INSERT_ROW(
                                                        X_ROWID                   =>                x_rowid,
                                                        X_COURSE_CD               =>             p_new_course_cd,
                                                        X_VERSION_NUMBER          =>             p_new_version_number,
                                                        X_POS_SEQUENCE_NUMBER     =>             v_pos_seq_num,
                                                        X_SEQUENCE_NUMBER         =>             v_posu_seq_num,
                                                        X_POSP_SEQUENCE_NUMBER    =>             v_posp_seq_num,
                                                        X_CAL_TYPE                =>             v_posu_rec.cal_type,
                                                        X_UNIT_CD                 =>             v_posu_rec.unit_cd,
                                                        X_UNIT_LOCATION_CD        =>             v_posu_rec.unit_location_cd,
                                                        X_UNIT_CLASS              =>             v_posu_rec.unit_class,
                                                        X_DESCRIPTION             =>             v_posu_rec.description,
                                                        X_MODE                    =>                'R',
                                                        X_CORE_IND                =>        v_posu_rec.core_ind
                                                        );
                                        END LOOP; -- c_posu_rec
                                END LOOP;  -- c_posp_rec
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_max_error_range AND
                                                        SQLCODE <= cst_min_error_range THEN
                                                p_message_name := cst_ret_message_name;
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP; -- c_pos_rec
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_pos%ISOPEN) THEN
                                CLOSE c_pos;
                        END IF;
                        IF (c_posp%ISOPEN) THEN
                                CLOSE c_posp;
                        END IF;
                        IF (c_posu%ISOPEN) THEN
                                CLOSE c_posu;
                        END IF;
                        IF (c_pos_seq_num%ISOPEN) THEN
                                CLOSE c_pos_seq_num;
                        END IF;
                        IF (c_posp_seq_num%ISOPEN) THEN
                                CLOSE c_posp_seq_num;
                        END IF;
                        IF (c_posu_seq_num%ISOPEN) THEN
                                CLOSE c_posu_seq_num;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_max_error_range AND
                                        SQLCODE <= cst_min_error_range THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_pos_rec;

PROCEDURE crspl_ins_cous_rec
        AS
        BEGIN
        DECLARE
                CURSOR c_cous IS
                        SELECT  cous.cal_type,
                                cous.unit_set_cd,
                                cous.us_version_number,
                                cous.override_title,
                                cous.only_as_sub_ind,
                                cous.show_on_official_ntfctn_ind
                        FROM        IGS_PS_OFR_UNIT_SET cous
                        WHERE        cous.course_cd                         = p_old_course_cd AND
                                cous.crv_version_number          = p_old_version_number AND
                                cous.cal_type                        = gv_co_rec.cal_type;
                CURSOR c_cousr IS
                        SELECT  cousr.cal_type,
                                cousr.sup_unit_set_cd,
                                cousr.sup_us_version_number,
                                cousr.sub_unit_set_cd,
                                cousr.sub_us_version_number
                        FROM        IGS_PS_OF_UNT_SET_RL cousr,
                                IGS_PS_OFR_UNIT_SET cous_sup,
                                IGS_PS_OFR_UNIT_SET cous_sub
                        WHERE        cousr.course_cd                     = p_old_course_cd AND
                                cousr.crv_version_number         = p_old_version_number AND
                                cousr.cal_type                        = gv_co_rec.cal_type AND
                                cousr.cal_type                        = cous_sub.cal_type AND
                                cousr.sub_unit_set_cd                = cous_sub.unit_set_cd AND
                                cousr.sub_us_version_number        = cous_sub.us_version_number AND
                                cousr.course_cd                        = cous_sub.course_cd        AND
                                cousr.crv_version_number         = cous_sub.crv_version_number AND
                                cousr.sup_unit_set_cd                = cous_sup.unit_set_cd AND
                                cousr.sup_us_version_number        = cous_sup.us_version_number AND
                                cousr.course_cd                        = cous_sup.course_cd        AND
                                cousr.crv_version_number         = cous_sup.crv_version_number AND
                                cousr.cal_type                        = cous_sup.cal_type AND
                                EXISTS        (SELECT        'X'
                                                 FROM                IGS_PS_OFR_UNIT_SET cous
                                                 WHERE        cous.course_cd                = p_new_course_cd AND
                                                                cous.crv_version_number = p_new_version_number AND
                                                                cous.cal_type                = cous_sup.cal_type AND
                                                                cous.unit_set_cd                = cous_sup.unit_set_cd AND
                                                                cous.us_version_number         = cous_sup.us_version_number) AND
                                EXISTS        (SELECT        'X'
                                                 FROM                IGS_PS_OFR_UNIT_SET cous
                                                 WHERE        cous.course_cd                = p_new_course_cd AND
                                                                cous.crv_version_number = p_new_version_number AND
                                                                cous.cal_type                = cous_sub.cal_type AND
                                                                cous.unit_set_cd                = cous_sub.unit_set_cd AND
                                                                cous.us_version_number         = cous_sub.us_version_number);
                l_org_id                NUMBER(15);
        BEGIN
                FOR v_cous_rec IN c_cous LOOP
                        BEGIN
                                x_rowid        :=        NULL;
                                IGS_PS_OFR_UNIT_SET_PKG.INSERT_ROW(
                                        X_ROWID                        =>         x_rowid,
                                        X_COURSE_CD                    =>        p_new_course_cd,
                                        X_CRV_VERSION_NUMBER           =>        p_new_version_number,
                                        X_CAL_TYPE                     =>        v_cous_rec.cal_type,
                                        X_UNIT_SET_CD                  =>        v_cous_rec.unit_set_cd,
                                        X_US_VERSION_NUMBER            =>        v_cous_rec.us_version_number,
                                        X_OVERRIDE_TITLE               =>        v_cous_rec.override_title,
                                        X_ONLY_AS_SUB_IND              =>        v_cous_rec.only_as_sub_ind,
                                        X_SHOW_ON_OFFICIAL_NTFCTN_IND  =>        v_cous_rec.show_on_official_ntfctn_ind,
                                        X_MODE                         =>        'R'
                                        );
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_max_error_range AND
                                                        SQLCODE <= cst_min_error_range THEN
                                                p_message_name := cst_ret_message_name;
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;  -- c_cous
                FOR v_cousr_rec IN c_cousr LOOP
                                X_ROWID        := NULL;
                                IGS_PS_OF_UNT_SET_RL_PKG.INSERT_ROW(
                                        X_ROWID                               =>        x_rowid,
                                        X_COURSE_CD                   =>         p_new_course_cd,
                                        X_CRV_VERSION_NUMBER          =>         p_new_version_number,
                                        X_SUP_US_VERSION_NUMBER       =>         v_cousr_rec.sup_us_version_number,
                                        X_SUB_UNIT_SET_CD             =>         v_cousr_rec.sub_unit_set_cd,
                                        X_SUP_UNIT_SET_CD             =>         v_cousr_rec.sup_unit_set_cd,
                                        X_CAL_TYPE                    =>         v_cousr_rec.cal_type,
                                        X_SUB_US_VERSION_NUMBER       =>         v_cousr_rec.sub_us_version_number,
                                        X_MODE                        =>        'R'
                                        );
                END LOOP; -- cousr_sub
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_cous%ISOPEN) THEN
                                CLOSE c_cous;
                        END IF;
                        IF (c_cousr%ISOPEN) THEN
                                CLOSE c_cousr;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_max_error_range AND
                                        SQLCODE <= cst_min_error_range THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_cous_rec;
        -- procedure for inserting new IGS_PS_OFR records
        PROCEDURE crsp_ins_co_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS

                l_org_id                NUMBER(15);
        BEGIN
                X_ROWID        := NULL;
                l_org_id := IGS_GE_GEN_003.GET_ORG_ID;
                IGS_PS_OFR_PKG.INSERT_ROW(
                        X_ROWID                      =>                x_rowid,
                        X_COURSE_CD                  =>                  p_new_course_cd,
                        X_VERSION_NUMBER              =>                  p_new_version_number,
                        X_CAL_TYPE                    =>                  gv_co_rec.cal_type,
                        X_ATTRIBUTE_CATEGORY       =>                gv_co_rec.attribute_category,
                        X_ATTRIBUTE1                   =>                gv_co_rec.attribute1,
                        X_ATTRIBUTE2                   =>                gv_co_rec.attribute2,
                        X_ATTRIBUTE3                   =>                gv_co_rec.attribute3,
                        X_ATTRIBUTE4                   =>                gv_co_rec.attribute4,
                        X_ATTRIBUTE5                   =>                gv_co_rec.attribute5,
                        X_ATTRIBUTE6                   =>                gv_co_rec.attribute6,
                        X_ATTRIBUTE7                   =>                gv_co_rec.attribute7,
                        X_ATTRIBUTE8                   =>                gv_co_rec.attribute8,
                        X_ATTRIBUTE9                   =>                gv_co_rec.attribute9,
                        X_ATTRIBUTE10                   =>                gv_co_rec.attribute10,
                        X_ATTRIBUTE11                   =>                gv_co_rec.attribute11,
                        X_ATTRIBUTE12                   =>                gv_co_rec.attribute12,
                        X_ATTRIBUTE13                   =>                gv_co_rec.attribute13,
                        X_ATTRIBUTE14                   =>                gv_co_rec.attribute14,
                        X_ATTRIBUTE15                   =>                gv_co_rec.attribute15,
                        X_ATTRIBUTE16                   =>                gv_co_rec.attribute16,
                        X_ATTRIBUTE17                   =>                gv_co_rec.attribute17,
                        X_ATTRIBUTE18                   =>                gv_co_rec.attribute18,
                        X_ATTRIBUTE19                   =>                gv_co_rec.attribute19,
                        X_ATTRIBUTE20                   =>                gv_co_rec.attribute20,
                        X_MODE                       =>                'R' ,
                        X_ORG_ID                   =>                l_org_id
                        );
                        -- calling procedure to insert IGS_PS_OFR_UNIT_SET records
                        -- and its child tables IGS_PS_OF_OPT_UNT_ST and
                        -- IGS_PS_OF_UNT_SET_RL
                        crspl_ins_cous_rec;
                        -- calling procedure to insert IGS_PS_OFR_OPT records
                        -- associated with each IGS_PS_OFR record
                        OPEN gc_coo_rec;
                        LOOP
                                   FETCH gc_coo_rec INTO gv_coo_rec;
                                IF gc_coo_rec%FOUND THEN
                                        crsp_ins_coo_rec(p_new_course_cd, p_new_version_number);
                                ELSE
                                        EXIT;
                                END IF;
                        END LOOP;
                        CLOSE gc_coo_rec;
                        -- calling procedure to insert IGS_PS_OFR_INST records
                        -- associated with each IGS_PS_OFR record
                        OPEN gc_coi_rec;
                        FETCH gc_coi_rec INTO gv_coi_rec;
                        IF gc_coi_rec%FOUND THEN
                                -- if found, only the latest one needs to be copied over.
                                crsp_ins_coi_rec(p_new_course_cd, p_new_version_number);
                        END IF;
                        CLOSE gc_coi_rec;
                        -- calling procedure to insert IGS_PS_OFR_NOTE records
                        -- associated with each IGS_PS_OFR record
                        OPEN gc_con_rec;
                        LOOP
                                FETCH gc_con_rec INTO gv_con_rec;
                                IF gc_con_rec%FOUND THEN
                                        crsp_ins_con_rec(p_new_course_cd, p_new_version_number);
                                ELSE
                                        EXIT;
                                END IF;
                        END LOOP;
                        CLOSE gc_con_rec;
                        -- calling procedure to insert IGS_PS_PAT_OF_STUDY records
                        crspl_ins_pos_rec;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_co_rec;
        -- procedure for inserting new IGS_PS_AWD_OWN records
        PROCEDURE crsp_ins_cao_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                X_ROWID        :=        NULL ;
                IGS_PS_AWD_OWN_PKG.INSERT_ROW(
                        X_ROWID             =>                 x_rowid,
                        X_COURSE_CD         =>           p_new_course_cd,
                        X_ORG_UNIT_CD       =>           gv_cao_rec.org_unit_cd,
                        X_OU_START_DT       =>           gv_cao_rec.ou_start_dt,
                        X_AWARD_CD          =>           gv_cao_rec.award_cd,
                        X_VERSION_NUMBER    =>           p_new_version_number,
                        X_PERCENTAGE        =>           gv_cao_rec.percentage,
                        X_MODE              =>           'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                        App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_cao_rec;
        -- procedure for inserting new IGS_PS_ANL_LOAD_U_LN records
        PROCEDURE crsp_ins_calulink_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                x_rowid := NULL;
                IGS_PS_ANL_LOAD_U_LN_PKG.INSERT_ROW(
                        X_ROWID               =>        x_rowid,
                        X_COURSE_CD           =>         p_new_course_cd,
                        X_CRV_VERSION_NUMBER  =>         p_new_version_number,
                        X_EFFECTIVE_START_DT  =>         gv_calulink_rec.effective_start_dt,
                        X_YR_NUM              =>         gv_calulink_rec.yr_num,
                        X_UV_VERSION_NUMBER   =>         gv_calulink_rec.uv_version_number,
                        X_UNIT_CD             =>         gv_calulink_rec.unit_cd,
                        X_MODE                =>        'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_calulink_rec;
        -- procedure for inserting new IGS_PS_AWARD records
        PROCEDURE crsp_ins_ca_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                -- Bug#2983445 Removed the column award_title from call to igs_ps_award_pkg.insert_row.
                -- inserting IGS_PS_AWARD records

                -- Bug#3060693 Modified the call to IGS_PS_AWARD_PKG.INSERT_ROW.
                -- Replaced the string 'Y' with gv_ca_rec.default_ind as the parameter being passed to X_DEFAULT_IND


                x_rowid        :=        NULL;
                IGS_PS_AWARD_PKG.INSERT_ROW(
                        X_ROWID             =>        x_rowid,
                        X_COURSE_CD         =>        p_new_course_cd,
                        X_AWARD_CD          =>        gv_ca_rec.award_cd,
                        X_VERSION_NUMBER    =>        p_new_version_number,
                        X_MODE              =>        'R',
                        X_DEFAULT_IND       =>        gv_ca_rec.default_ind,
                        X_CLOSED_IND        =>        gv_ca_rec.closed_ind
                        );
                -- calling procedure to insert IGS_PS_AWD_OWN records
                -- associated with each IGS_PS_AWARD record
                OPEN gc_cao_rec;
                LOOP
                        FETCH gc_cao_rec INTO gv_cao_rec;
                        IF gc_cao_rec%FOUND THEN
                                crsp_ins_cao_rec(p_new_course_cd, p_new_version_number);
                        ELSE
                                EXIT;
                        END IF;
                END LOOP;
                CLOSE gc_cao_rec;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_ca_rec;
        -- procedure for inserting new IGS_PS_OWN records
        PROCEDURE crsp_ins_cow_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                X_ROWID        :=         NULL ;
                IGS_PS_OWN_PKG.INSERT_ROW(
                        X_ROWID             =>           x_rowid,
                        X_COURSE_CD         =>           p_new_course_cd,
                        X_OU_START_DT       =>           gv_cow_rec.ou_start_dt,
                        X_ORG_UNIT_CD       =>           gv_cow_rec.org_unit_cd,
                        X_VERSION_NUMBER    =>           p_new_version_number,
                        X_PERCENTAGE        =>           gv_cow_rec.percentage,
                        X_MODE              =>                'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_cow_rec;
        -- procedure for inserting new IGS_PE_ALTERNATV_EXT records
        PROCEDURE crsp_ins_ae_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                X_ROWID        :=        NULL;
                IGS_PE_ALTERNATV_EXT_PKG.INSERT_ROW(
                        X_ROWID              =>                X_ROWID,
                        X_COURSE_CD          =>          p_new_course_cd,
                        X_VERSION_NUMBER     =>          p_new_version_number,
                        X_EXIT_COURSE_CD     =>          gv_ae_rec.exit_course_cd,
                        X_EXIT_VERSION_SET   =>          gv_ae_rec.exit_version_set,
                        X_MODE               =>          'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_ae_rec;
        -- procedure for inserting new IGS_PS_GRP_MBR records
        PROCEDURE crsp_ins_cgm_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                x_rowid        :=        NULL;
                IGS_PS_GRP_MBR_PKG.INSERT_ROW(
                        X_ROWID             =>           x_rowid,
                        X_COURSE_CD         =>           p_new_course_cd,
                        X_COURSE_GROUP_CD   =>           gv_cgm_rec.course_group_cd,
                        X_VERSION_NUMBER    =>           p_new_version_number,
                        X_MODE              =>                'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_cgm_rec;

        -- procedure for inserting new IGS_FI_FND_SRC_RSTN records

        -- Bug#3060697 Modified the call to IGS_FI_FND_SRC_RSTN_PKG.INSERT_ROW.
        -- Replaced the string 'Y' with gv_fsr_rec.restricted_ind as the parameter being passed to X_RESTRICTED_IND


        PROCEDURE crsp_ins_fsr_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                x_rowid        :=        NULL;
                IGS_FI_FND_SRC_RSTN_PKG.INSERT_ROW(
                        X_ROWID             =>                x_rowid,
                        X_COURSE_CD         =>           p_new_course_cd,
                        X_FUNDING_SOURCE    =>           gv_fsr_rec.funding_source,
                        X_VERSION_NUMBER    =>           p_new_version_number,
                        X_DFLT_IND          =>           gv_fsr_rec.dflt_ind,
                        X_RESTRICTED_IND    =>           gv_fsr_rec.restricted_ind,
                        X_MODE              =>                'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END  crsp_ins_fsr_rec;
        -- procedure for inserting new IGS_PS_FIELD_STUDY records
        PROCEDURE crsp_ins_cfos_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                x_rowid        :=        NULL;
                IGS_PS_FIELD_STUDY_PKG.INSERT_ROW(
                        X_ROWID             =>                   x_rowid,
                        X_COURSE_CD         =>                   p_new_course_cd,
                        X_FIELD_OF_STUDY    =>                   gv_cfos_rec.field_of_study,
                        X_VERSION_NUMBER    =>           p_new_version_number,
                        X_MAJOR_FIELD_IND   =>           gv_cfos_rec.major_field_ind,
                        X_PERCENTAGE        =>           gv_cfos_rec.percentage,
                        X_MODE              =>                'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_cfos_rec;
        -- procedure for inserting new IGS_PS_CATEGORISE records
        PROCEDURE crsp_ins_ccat_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS

                l_org_id                NUMBER(15);
        BEGIN
                x_rowid        :=         NULL;
                l_org_id := IGS_GE_GEN_003.GET_ORG_ID;
                IGS_PS_CATEGORISE_PKG.INSERT_ROW(
                        X_ROWID            =>                x_rowid,
                        X_COURSE_CD        =>            p_new_course_cd,
                        X_VERSION_NUMBER   =>            p_new_version_number,
                        X_COURSE_CAT       =>            gv_ccat_rec.course_cat,
                        X_MODE             =>            'R',
                        X_ORG_ID           =>                l_org_id
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_ccat_rec;
        -- procedure for inserting new IGS_PS_REF_CD records
        PROCEDURE crsp_ins_crcd_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                x_rowid        :=        NULL;
                IGS_PS_REF_CD_PKG.INSERT_ROW(
                X_ROWID              =>                x_rowid,
                X_COURSE_CD          =>          p_new_course_cd,
                X_VERSION_NUMBER     =>          p_new_version_number,
                X_REFERENCE_CD       =>          gv_crcd_rec.reference_cd,
                X_REFERENCE_CD_TYPE  =>          gv_crcd_rec.reference_cd_type,
                X_DESCRIPTION        =>          gv_crcd_rec.description,
                X_MODE               =>                'R'
                );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END  crsp_ins_crcd_rec;
        -- procedure for inserting new IGS_PS_ANL_LOAD records
        PROCEDURE crsp_ins_cal_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE) AS
        BEGIN
                x_rowid        :=        NULL;
                IGS_PS_ANL_LOAD_PKG.INSERT_ROW(
                        X_ROWID                    =>                x_rowid,
                        X_VERSION_NUMBER           =>            p_new_version_number,
                        X_COURSE_CD                =>            p_new_course_cd,
                        X_YR_NUM                   =>            gv_cal_rec.yr_num,
                        X_EFFECTIVE_START_DT           =>                gv_cal_rec.effective_start_dt,
                        X_EFFECTIVE_END_DT             =>                gv_cal_rec.effective_end_dt,
                        X_ANNUAL_LOAD_VAL              =>                gv_cal_rec.annual_load_val,
                        X_MODE                         =>                'R'
                        );
                -- calling procedure to insert IGS_PS_ANL_LOAD_U_LN records
                -- associated with each IGS_PS_ANL_LOAD record
                OPEN gc_calulink_rec;
                LOOP
                         FETCH gc_calulink_rec INTO gv_calulink_rec;
                        IF gc_calulink_rec%FOUND THEN
                                crsp_ins_calulink_rec(p_new_course_cd, p_new_version_number);
                        ELSE
                                   EXIT;
                        END IF;
                END LOOP;
                CLOSE gc_calulink_rec;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_cal_rec;
        -- inserting new IGS_GE_NOTE and IGS_PS_VER_NOTE records
        PROCEDURE crsp_ins_cvn_rec (
                p_new_course_cd                IGS_PS_VER.course_cd%TYPE,
                p_new_version_number        IGS_PS_VER.version_number%TYPE)
        AS
        CURSOR Cur_SGN IS
                        SELECT rowid,IGS_GE_NOTE.*
                        FROM IGS_GE_NOTE
                        WHERE        reference_number = gv_cvn_rec.reference_number;
        BEGIN
                -- select the next reference_number from the system
                OPEN  gc_ref_num;
                FETCH gc_ref_num INTO gv_ref_num;
                CLOSE gc_ref_num;
                -- inserting IGS_GE_NOTE record with this next reference_number
                -- Currently unable to copy Long Raw columns in PL/SQL.


                FOR Rec_SGN IN Cur_SGN        LOOP
                        x_rowid        :=        NULL;
                        IGS_GE_NOTE_PKG.INSERT_ROW(
                                                X_ROWID               => X_ROWID,
                                                X_REFERENCE_NUMBER    =>gv_ref_num,
                                                X_S_NOTE_FORMAT_TYPE  => Rec_SGN.s_note_format_type,
                                                X_NOTE_TEXT           =>Rec_SGN.note_text,
                                                X_MODE                =>'R');
                END LOOP;
                -- inserting new IGS_PS_VER_NOTE records
                x_rowid        :=        NULL;
                IGS_PS_VER_NOTE_PKG.INSERT_ROW(
                        X_ROWID             =>                x_rowid,
                        X_COURSE_CD         =>           p_new_course_cd,
                        X_VERSION_NUMBER    =>           p_new_version_number,
                        X_REFERENCE_NUMBER  =>           gv_ref_num,
                        X_CRS_NOTE_TYPE     =>           gv_cvn_rec.crs_note_type,
                        X_MODE              =>                'R'
                        );
        EXCEPTION
                WHEN OTHERS THEN
                        IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crsp_ins_cvn_rec;
        -- inserts into IGS_PS_STAGE and its child table IGS_PS_STAGE_RU table
        PROCEDURE crspl_ins_cst_rec
        AS
        BEGIN
        DECLARE
                v_cst_seq_num                IGS_PS_STAGE.sequence_number%TYPE;
                v_new_rul_seq_num         IGS_PS_STAGE_RU.rul_sequence_number%TYPE;
                CURSOR c_cst_seq_num IS
                        SELECT IGS_PS_STAGE_SEQ_NUM_S.NEXTVAL
                        FROM         DUAL;
                CURSOR c_cst IS
                        SELECT         cst.sequence_number,
                                cst.course_stage_type,
                                cst.description,
                                cst.comments
                        FROM        IGS_PS_STAGE cst
                        WHERE        cst.course_cd                = p_old_course_cd AND
                                cst.version_number        = p_old_version_number;
                CURSOR c_csr (
                                cp_cst_seq_num                IGS_PS_STAGE.sequence_number%TYPE) IS
                        SELECT        csr.cst_sequence_number,
                                 csr.s_rule_call_cd,
                                 csr.rul_sequence_number
                        FROM        IGS_PS_STAGE_RU csr
                        WHERE        csr.course_cd                = p_old_course_cd AND
                                csr.version_number        = p_old_version_number AND
                                csr.cst_sequence_number        = cp_cst_seq_num;
        BEGIN
                FOR v_cst_rec IN c_cst LOOP
                        BEGIN
                                OPEN c_cst_seq_num;
                                FETCH c_cst_seq_num INTO v_cst_seq_num;
                                CLOSE c_cst_seq_num;
                                x_rowid        :=        NULL;
                                IGS_PS_STAGE_PKG.INSERT_ROW(
                                        X_ROWID              =>                x_rowid,
                                        X_COURSE_CD          =>          p_new_course_cd,
                                        X_VERSION_NUMBER     =>          p_new_version_number,
                                        X_SEQUENCE_NUMBER    =>          v_cst_seq_num,
                                        X_COURSE_STAGE_TYPE  =>          v_cst_rec.course_stage_type,
                                        X_DESCRIPTION        =>          v_cst_rec.description,
                                        X_COMMENTS           =>          v_cst_rec.comments,
                                        X_MODE               =>          'R'
                                        );
                                        FOR v_csr_rec IN c_csr (
                                                         v_cst_rec.sequence_number) LOOP
                                                v_new_rul_seq_num := IGS_RU_GEN_003.rulp_ins_copy_rule(
                                                                v_csr_rec.s_rule_call_cd,
                                                                v_csr_rec.rul_sequence_number);
                                                        X_ROWID        :=        NULL;
                                                        IGS_PS_STAGE_RU_PKG.INSERT_ROW(
                                                                X_ROWID                 =>        x_rowid,
                                                                X_COURSE_CD             =>           p_new_course_cd,
                                                                X_VERSION_NUMBER        =>           p_new_version_number,
                                                                X_S_RULE_CALL_CD        =>           v_csr_rec.s_rule_call_cd,
                                                                X_CST_SEQUENCE_NUMBER   =>           v_cst_seq_num,
                                                                X_RUL_SEQUENCE_NUMBER   =>           v_new_rul_seq_num,
                                                                X_MODE                  =>        'R'
                                                                );
                                        END LOOP;
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_max_error_range AND
                                                        SQLCODE <= cst_min_error_range THEN
                                                p_message_name := cst_ret_message_name;
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_cst%ISOPEN) THEN
                                CLOSE c_cst;
                        END IF;
                        IF (c_csr%ISOPEN) THEN
                                CLOSE c_csr;
                        END IF;
                        IF (c_cst_seq_num%ISOPEN) THEN
                                CLOSE c_cst_seq_num;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_max_error_range AND
                                        SQLCODE <= cst_min_error_range THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_cst_rec;
--------------------------------------------------------------------
        PROCEDURE crspl_ins_cvr_rec
        AS
        BEGIN
        DECLARE
                v_new_rul_seq_number         IGS_PS_VER_RU.rul_sequence_number%TYPE;
                CURSOR c_cvr IS
                        SELECT        cvr.s_rule_call_cd,
                                cvr.rul_sequence_number
                        FROM        IGS_PS_VER_RU cvr
                        WHERE        cvr.course_cd                = p_old_course_cd AND
                                cvr.version_number        = p_old_version_number;
        BEGIN
                FOR v_cvr_rec IN c_cvr LOOP
                        BEGIN
                                v_new_rul_seq_number := IGS_RU_GEN_003.rulp_ins_copy_rule(
                                                                v_cvr_rec.s_rule_call_cd,
                                                                v_cvr_rec.rul_sequence_number);
                                x_rowid        :=        NULL;
                                IGS_PS_VER_RU_PKG.INSERT_ROW(
                                        X_ROWID               =>        x_rowid,
                                        X_COURSE_CD           =>         p_new_course_cd,
                                        X_VERSION_NUMBER      =>         p_new_version_number,
                                        X_S_RULE_CALL_CD      =>         v_cvr_rec.s_rule_call_cd,
                                        X_RUL_SEQUENCE_NUMBER =>         v_new_rul_seq_number,
                                        X_MODE                =>        'R'
                                        );
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_max_error_range AND
                                                        SQLCODE <= cst_min_error_range THEN
                                                p_message_name := cst_ret_message_name;
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_cvr%ISOPEN) THEN
                                CLOSE c_cvr;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_max_error_range AND
                                        SQLCODE <= cst_min_error_range THEN
                                p_message_name := cst_ret_message_name;
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_cvr_rec;
-----------------------------------------------------------
        PROCEDURE crspl_ins_dms_rec
        AS

        BEGIN
        DECLARE
                v_seq_num        IGS_RE_DFLT_MS_SET.sequence_number%TYPE;
                l_org_id                NUMBER(15);
                CURSOR c_dms IS
                        SELECT        dms.milestone_type,
                                dms.attendance_type,
                                dms.attendance_mode,
                                dms.offset_days,
                                dms.comments
                        FROM        IGS_RE_DFLT_MS_SET        dms
                        WHERE        dms.course_cd                = p_old_course_cd AND
                                dms.version_number        = p_old_version_number;
                CURSOR c_dms_seq IS
                        SELECT        IGS_RE_DFLT_MS_SET_SEQ_NUM_S.NEXTVAL
                        FROM        DUAL;
        BEGIN
                FOR v_dms_rec IN c_dms LOOP
                        BEGIN
                                OPEN c_dms_seq;
                                FETCH c_dms_seq INTO v_seq_num;
                                CLOSE c_dms_seq;
                                x_rowid        :=        NULL;
                                l_org_id := IGS_GE_GEN_003.get_org_id;
                                IGS_RE_DFLT_MS_SET_PKG.INSERT_ROW(
                                        X_ROWID            =>                x_rowid,
                                        X_COURSE_CD        =>            p_new_course_cd,
                                        X_VERSION_NUMBER   =>            p_new_version_number,
                                        X_MILESTONE_TYPE   =>            v_dms_rec.milestone_type,
                                        X_ATTENDANCE_TYPE  =>            v_dms_rec.attendance_type,
                                        X_ATTENDANCE_MODE  =>           v_dms_rec.attendance_mode,
                                        X_SEQUENCE_NUMBER  =>            v_seq_num,
                                        X_OFFSET_DAYS      =>            v_dms_rec.offset_days,
                                        X_COMMENTS         =>            v_dms_rec.comments,
                                        X_MODE             =>                'R' ,
                                        X_ORG_ID           =>                l_org_id
                                        );
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_max_error_range AND
                                                        SQLCODE <= cst_min_error_range THEN
                                                p_message_name := cst_ret_message_name;
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_dms%ISOPEN THEN
                                CLOSE c_dms;
                        END IF;
                        IF c_dms_seq%ISOPEN THEN
                                CLOSE c_dms_seq;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                        Fnd_Message.Set_Token('NAME','IGS_PS_GEN_001.crspl_ins_dms_rec');
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
        END crspl_ins_dms_rec;

	PROCEDURE crsp_ins_term_instr_time AS
          CURSOR c_psv_term IS
	  SELECT *
          FROM   igs_en_psv_term_it
          WHERE  course_cd = p_old_course_cd
          AND    version_number = p_old_version_number;
          l_rowid VARCHAR2(25);

	BEGIN
	  --Rolllover the term instruction time from one version of program to another when duplicate record is done
          FOR l_psv_term_rec IN c_psv_term LOOP
	    BEGIN
              l_rowid := NULL;
  	      igs_en_psv_term_it_pkg.insert_row(x_rowid                 => l_rowid,
                                                x_cal_type              => l_psv_term_rec.cal_type,
                                                x_sequence_number       => l_psv_term_rec.sequence_number,
                                                x_course_cd             => p_new_course_cd,
                                                x_version_number        => p_new_version_number,
                                                x_term_instruction_time => l_psv_term_rec.term_instruction_time);
            EXCEPTION
              WHEN OTHERS THEN
                IF SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range THEN
                   p_message_name := cst_ret_message_name;
                ELSE
                  app_exception.raise_exception;
                END IF;
            END;
	  END LOOP;

	END crsp_ins_term_instr_time;

        -- Removed procedure crsp_ins_revseg_rec as part of Enh# 2831572.
        -- As per this Enh#, Revenue Account Segments are not rolled over to new program version.

----------------------------------------MAIN------------------------------
BEGIN        -- main procedure
        -- This procedure is responsible for transferring all the details of one
        -- IGS_PS_COURSE version to another. It gets records (old version_number) and
        -- transfers (duplicates)  them all over to a new version_number. An
        -- exception handler is raised when an error  number is found to be in the
        -- range -20000 to -20999 (which indicates that the exception is user
        --  defined - one of the validation routines within the system). If not
        -- within this range, it will be raised by standard exception handling.
        --  If the insertion  of a IGS_PS_COURSE IGS_GE_NOTE fails, the associated IGS_GE_NOTE is removed.
        -- IGS_GE_NOTE:        If any tables to be added, be careful to ensure relational integrity
        --                is preserved. Please check that all foreign keys are catered for.
        --                (For example, IGS_PS_OF_OPT_UNT_ST relies on
        --                IGS_PS_OFR_UNIT_SET and IGS_PS_OFR_OPT populated first.
        --                Only then can the records be created for the new version provided
        --                the parent records exist.)
        -- This checks if the specified new IGS_PS_COURSE version exists

        l_status := NULL;

        OPEN gc_cv_new_rec;
        FETCH gc_cv_new_rec INTO gv_cv_rec;
        IF gc_cv_new_rec%NOTFOUND THEN
                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                CLOSE gc_cv_new_rec;
                RETURN;
        END IF;
        CLOSE gc_cv_new_rec;
        -- This checks if the specified old IGS_PS_COURSE version exists
        OPEN gc_cv_old_rec;
        FETCH gc_cv_old_rec INTO gv_cv_rec;
        IF gc_cv_old_rec%NOTFOUND THEN
                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                CLOSE gc_cv_old_rec;
                RETURN;
        END IF;
        CLOSE gc_cv_old_rec;
        -- if validation is successful
        p_message_name := 'IGS_PS_SUCCESS_COPY_PRGVER';
        -- calling procedure to insert IGS_PS_AWARD records
        OPEN gc_ca_rec;
        LOOP
                FETCH gc_ca_rec INTO gv_ca_rec;
                IF gc_ca_rec%FOUND THEN
                        crsp_ins_ca_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_ca_rec;
        -- calling procedure to insert IGS_PS_OWN records
        OPEN gc_cow_rec;
        LOOP
                FETCH gc_cow_rec INTO gv_cow_rec;
                IF gc_cow_rec%FOUND THEN
                        crsp_ins_cow_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_cow_rec;
        -- calling procedure to insert IGS_PE_ALTERNATV_EXT records
        OPEN gc_ae_rec;
        LOOP
                FETCH gc_ae_rec INTO gv_ae_rec;
                IF gc_ae_rec%FOUND THEN
                        crsp_ins_ae_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_ae_rec;
        -- calling procedure to insert IGS_FI_FND_SRC_RSTN records
        OPEN gc_fsr_rec;
        LOOP
                FETCH gc_fsr_rec INTO gv_fsr_rec;
                IF gc_fsr_rec%FOUND THEN
                        crsp_ins_fsr_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_fsr_rec;
        -- calling procedure to insert IGS_PS_FIELD_STUDY records
        OPEN gc_cfos_rec;
        LOOP
                FETCH gc_cfos_rec INTO gv_cfos_rec;
                IF gc_cfos_rec%FOUND THEN
                        crsp_ins_cfos_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_cfos_rec;
        -- calling procedure to insert IGS_PS_GRP_MBR records
        OPEN gc_cgm_rec;
        LOOP
                FETCH gc_cgm_rec INTO gv_cgm_rec;
                IF gc_cgm_rec%FOUND THEN
                        crsp_ins_cgm_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_cgm_rec;
        -- calling procedure to insert IGS_PS_CATEGORISE records
        OPEN gc_ccat_rec;
        LOOP
                FETCH gc_ccat_rec INTO gv_ccat_rec;
                IF gc_ccat_rec%FOUND THEN
                        crsp_ins_ccat_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_ccat_rec;
        -- calling procedure to insert IGS_PS_REF_CD records
        OPEN gc_crcd_rec;
        LOOP
                FETCH gc_crcd_rec INTO gv_crcd_rec;
                IF gc_crcd_rec%FOUND THEN
                        crsp_ins_crcd_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_crcd_rec;
        -- calling procedure to insert IGS_PS_ANL_LOAD records
        OPEN gc_cal_rec;
        LOOP
                FETCH gc_cal_rec INTO gv_cal_rec;
                IF gc_cal_rec%FOUND THEN
                        crsp_ins_cal_rec(p_new_course_cd, p_new_version_number);
                ELSE
                           EXIT;
                END IF;
        END LOOP;
        CLOSE gc_cal_rec;
        -- calling procedure to insert IGS_PS_VER_NOTE records
        OPEN gc_cvn_rec;
        LOOP
                FETCH gc_cvn_rec INTO gv_cvn_rec;
                IF gc_cvn_rec%FOUND THEN
                        crsp_ins_cvn_rec(p_new_course_cd, p_new_version_number);
                ELSE
                        EXIT;
                END IF;
        END LOOP;
        CLOSE gc_cvn_rec;
        -- calling procedure to insert IGS_PS_OFR records
        OPEN c_co_rec;
        LOOP
                FETCH c_co_rec INTO gv_co_rec;
                IF c_co_rec%FOUND THEN
                        crsp_ins_co_rec(p_new_course_cd, p_new_version_number);
                ELSE
                        EXIT;
                END IF;
        END LOOP;
        CLOSE c_co_rec;

        -- Removed code to insert records into igs_ps_accounts table as part of Enh# 2831572

        -- calling procedure to insert IGS_PS_STAGE records and its
        -- child records
        crspl_ins_cst_rec;
        -- calling procedure to insert IGS_PS_VER_RU records
        crspl_ins_cvr_rec;
        -- calling procedure to insert IGS_RE_DFLT_MS_SET records
        crspl_ins_dms_rec;

        --Enh#3345205, calling procedure to insert IGS_EN_PSV_TERM_IT records
        crsp_ins_term_instr_time;

        --
        -- Start of new code as per the HESA DLD Build. ENCR019 Bug# 2201753.
        --

        --
        --Get the OSS_COUNTRY_CODE
        --
        IF fnd_profile.value('OSS_COUNTRY_CODE') = 'GB' THEN
          OPEN cur_obj_exists;
          FETCH cur_obj_exists INTO l_cur_obj_exists;
          IF cur_obj_exists%FOUND THEN
            CLOSE cur_obj_exists;
            l_status := 0;
            EXECUTE IMMEDIATE
            'BEGIN
              IGS_HE_PS_PKG.COPY_PROG_VERSION(:1, :2, :3, :4, :5, :6);
            END;'
            USING p_old_course_cd,
                  p_old_version_number,
                  p_new_course_cd,
                  p_new_version_number,
                  out p_message_name,
                  out l_status;

            IF NVL(l_Status,0) = 2 THEN -- ie. The procedure call has resulted in error.
              Fnd_Message.Set_Name('IGS', p_message_name);
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
            END IF;
          ELSE
            CLOSE cur_obj_exists;
          END IF;
        END IF;
        --
        -- End of new code added as per the HESA DLD Build. ENCR019 Bug# 2201753.
        --
        EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_001.CRSP_INS_CRS_VER');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
   END crsp_ins_crs_ver; -- main procedure


/*******************  UNIT SECTION DETAILS ROLLOVER *******************************************************/


 -- Procedure to duplicate child records of unit section.
PROCEDURE crsp_ins_unit_section(
  p_old_uoo_id IN NUMBER,
  p_new_uoo_id IN NUMBER,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_log_creation_date DATE )
  AS
  -------------------------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sommukhe	08-JAN-2006     Bug#3305881,modified cursor c_ou by replacing IGS_OR_UNIT with IGS_OR_INST_ORG_BASE_V
  --sarakshi    12-Jan-2006     BUg#4926548,modified cursor c_fee_type_exists and c_fee_type_cal_exists to address performance issues, created pl-sql table.
  --sommukhe    23-NOV-2005     Bug#4726560, added cursors cur_usec_tchr_lead,cur_usec_tchr1, c_tch_ins and cur_usec_gs_df.
  --sarakshi    17-Oct-2005     Bug#4657596, added fnd logging
  --sarakshi    12-Sep-2005     Bug#45772, placed flexfield attributes in the call to the occurrence insert row with the local variables.
  --sommukhe    01-SEP-2005     Bug# 4538540 , Added cursor cur_ass_item .
  --sarakshi    14-Sep-2004     Enh#3888835, added cursor c_rtn_us,c_rtn_us_dtl and c_fee_type_cal_exists  and it's related logic (of retention rollover).
  --sarakshi    12-Jul-2004     Bug#3729462, Added the column DELETE_FLAG in the where clause of the cursor cur_waitlist_chk .
  --sarakshi    02-Jun-2004     Bug#3658126,modified cursor usec_unitass and its usage, also added cursor cur_unitassgrp_new and its usage
  --sarakshi    04-Nov-2003     Enh#3116171,added field billing_credit_points in igs_ps_usec_cps insert_row.Also coded logic for rolling over igs_ps_usec_sp_fees data.
  --sarakshi    21-oct-2003     Enh# 3052452, removed the validation related to max_auditors_allowed
  --schodava    17-Sep-2003     Bug # 2520994 PSP Inheritance Build
  --                            Modified cursor wlst_pri and cursor cur_wlst_pri_new, to obsolete column UNIT_SECTION_LIMIT_WAITLIST_ID
  --                            and use column UOO_ID instead.
  --sarakshi    29-Aug-2003     Bug#3076021,before inserting the records checking if the record already exists for all the usec details .
  --                            Also max auditors field can be rolled over if auditable checkbox is chhecked.Also changed the length of the variable lv_rule_unprocessed
  --vvutukur    04-Aug-2003     Enh#3045069.PSP Enh Build. Removed cursor usec_rptc and related code as this cursor
  --                            refers to table igs_ps_usec_rpt_cond which is obsoleted as part of this design.
  --smvk        25-jun-2003     Enh bug#2918094. Added column cancel_flag.
  --shtatiko    23-MAY-2003     Enh# 2831572, Removed cursor cur_usec_accts and also removed code to rollover Revenue Account
  --                            Code into igs_ps_usec_accts
  --sarakshi    25-Apr-2003     Enh#2858431,modified call to igs_ps_us_req_ref_cd_pkg.insert_row
  --vvutukur    01-Nov-2002     Enh#2636716.Added new column max_auditors_allowd in the tbh call to
  --                            igs_ps_usec_lim_wlst_pkg.insert_row.
  --vvutukur    28-Oct-2002     Enh#2613933.Modified cursor usec_x_grpmem to select 2 new columns max_enr_group,
  --                            max_ovr_group.Also modified the tbh call to igs_ps_usec_x_grp_pkg.insert_row.
  --smadathi    02-May-2002     Bug 2261649. The procedure crsp_ins_unit_section contains reference to table IGS_PS_USEC_CHARGE.
  --                            The table became obsolete. The references to the same have been removed. The declarartion of cursor
  --                            usec_add_chrg and asscociated section of opening of cursor and calling the TBH of the above tables
  --                            removed.
  --smadathi    01-JUN-2001     The procedure crsp_ins_unit_section contains reference to tables IGS_PS_USEC_RPT_FMLY and
  --                            IGS_PS_USEC_PRV_GRAD . These tables became obsolete . The references to the same have been
  --                            removed . The declarartion of cursors usec_rfmly and usec_pgrad removed and asscociated section
  --                            of opening of cursor and calling the TBH of the above tables removed .The changes are as per DLD
  --skoppula    09-AUG-2001     Added code to rollover unit sectin account segment values.This comes as 27th cursor
  ---------------------------------------------------------------------------------------------------------------------
  gv_new_usec_rec                igs_ps_unit_ofr_opt%ROWTYPE;
  gv_old_usec_rec                igs_ps_unit_ofr_opt%ROWTYPE;

  -- get the old unit section values
  CURSOR  gc_usec_old_rec IS
  SELECT  *
  FROM    igs_ps_unit_ofr_opt
  WHERE   uoo_id = p_old_uoo_id ;

  -- get the new unit section values
  CURSOR  gc_usec_new_rec IS
  SELECT  *
  FROM    igs_ps_unit_ofr_opt
  WHERE   uoo_id = p_new_uoo_id ;

  --1
  CURSOR usec_occurs( p_uoo_id  NUMBER ) IS
  SELECT *
  FROM   igs_ps_usec_occurs
  WHERE  uoo_id = p_uoo_id;

  --2
  CURSOR usec_occurs_refcd( p_usec_id NUMBER ) IS
  SELECT *
  FROM   igs_ps_usec_ocur_ref
  WHERE  unit_section_occurrence_id = p_usec_id;

  --3
  --Enhancement bug no 1800179 , pmarada, added this cursor for unit section instructors
  CURSOR usec_instr(cp_Unit_Section_occurrence_id NUMBER) IS
  SELECT *
  FROM   igs_ps_uso_instrctrs
  WHERE  unit_section_occurrence_id =  cp_Unit_Section_occurrence_id;

  --4
  CURSOR wlst_limit( p_uoo_id NUMBER) IS
  SELECT *
  FROM  igs_ps_usec_lim_wlst
  WHERE uoo_id = p_uoo_id;


  --5
  CURSOR wlst_pri(p_uoo_id NUMBER) IS
  SELECT *
  FROM   igs_ps_usec_wlst_pri
  WHERE  uoo_id = p_uoo_id;

  --6
  CURSOR wlst_prf(p_usec_pri_id  NUMBER) IS
  SELECT *
  FROM   igs_ps_usec_wlst_prf
  WHERE  unit_sec_waitlist_priority_id = p_usec_pri_id;

  --7
  CURSOR usec_cps( p_uoo_id NUMBER) IS
  SELECT *
  FROM   igs_ps_usec_cps
  WHERE  uoo_id = p_uoo_id;

  --8
  CURSOR usec_x_grp (cp_grp_name VARCHAR2, cp_cal_type VARCHAR2, cp_seq_no NUMBER) IS
  SELECT *
  FROM  igs_ps_usec_x_grp
  WHERE usec_x_listed_group_name = cp_grp_name
  AND   cal_type = cp_cal_type
  AND   ci_sequence_number = cp_seq_no ;

  --9
  CURSOR usec_x_grpmem (cp_uoo_id NUMBER) IS
  SELECT grpmem.*, grp.usec_x_listed_group_name , grp.location_inheritance,
         grp.max_enr_group,max_ovr_group
  FROM   igs_ps_usec_x_grpmem grpmem, igs_ps_usec_x_grp grp
  WHERE  grp.usec_x_listed_group_id = grpmem.usec_x_listed_group_id
  AND    grpmem.uoo_id = cp_uoo_id;

  -- 10
  CURSOR usec_spn ( p_uoo_id NUMBER) IS
  SELECT *
  FROM   igs_ps_usec_spnsrshp
  WHERE  uoo_id = p_uoo_id;

  --11
  CURSOR usec_tchr ( p_uoo_id NUMBER)  IS
  SELECT *
  FROM   igs_ps_usec_tch_resp
  WHERE  uoo_id = p_uoo_id;

  --12
  CURSOR usec_as ( p_uoo_id NUMBER) IS
  SELECT *
  FROM   igs_ps_usec_as
  WHERE  uoo_id = p_uoo_id;

  --13.1
  CURSOR usec_unitassgrp ( p_uoo_id NUMBER) IS
  SELECT *
  FROM   igs_as_us_ai_group
  WHERE  uoo_id = p_uoo_id;

  --13.2
  CURSOR usec_unitass ( cp_uoo_id igs_ps_unitass_item.uoo_id%TYPE,
                        cp_us_ass_item_group_id igs_ps_unitass_item.us_ass_item_group_id%TYPE) IS
  SELECT *
  FROM   igs_ps_unitass_item
  WHERE  uoo_id = cp_uoo_id
  AND    us_ass_item_group_id=cp_us_ass_item_group_id;

  --14
  CURSOR usec_ref ( p_uoo_id NUMBER) IS
  SELECT *
  FROM   igs_ps_usec_ref
  WHERE  uoo_id = p_uoo_id;

  --15
  CURSOR usec_refcd( p_usec_ref_id NUMBER ) IS
  SELECT *
  FROM   igs_ps_usec_ref_cd
  WHERE  unit_section_reference_id = p_usec_ref_id;

  --Modified CURSOR us_req_refcd as part of bug#2563596.In the where condition the column unit_section_req_ref_cd_id
  --was replaced with column unit_section_reference_id.This was causing no unit section requirements reference codes
  --records to be selected for rollover
  --Enhancement bug no 1800179 , pmarada

  --16
  CURSOR us_req_refcd ( cp_usec_ref_id NUMBER) IS
  SELECT *
  FROM   igs_ps_us_req_ref_cd
  WHERE  unit_section_reference_id = cp_usec_ref_id;

  --17
  CURSOR usec_grdsch ( p_uoo_id NUMBER ) IS
  SELECT *
  FROM   igs_ps_usec_grd_schm
  WHERE  uoo_id = p_uoo_id;

  -- 18
  CURSOR c_unt_ofr_opt_n (cp_uoo_id NUMBER) IS
  SELECT snote.*,  genote.s_note_format_type, genote.note_text
  FROM   igs_ps_unt_ofr_opt_n snote,  igs_ge_note genote
  WHERE  uoo_id = cp_uoo_id
  AND    snote.reference_number = geNote.reference_number;

  -- 19
  CURSOR usec_pre_co_req_rule (cp_uoo_id NUMBER) IS
  SELECT *
  FROM   igs_ps_usec_ru_v
  WHERE  uoo_id = cp_uoo_id;

  -- 20
  CURSOR usec_cat (cp_uoo_id NUMBER) IS
  SELECT *
  FROM   igs_ps_usec_category
  WHERE  uoo_id = cp_uoo_id;

  -- 21
  CURSOR usec_plushr (cp_uoo_id NUMBER)  IS
  SELECT *
  FROM   igs_ps_us_unsched_cl
  WHERE  uoo_id = cp_uoo_id;

  --22
  CURSOR usec_tro (cp_uoo_id NUMBER)  IS
  SELECT *
  FROM   igs_ps_tch_resp_ovrd
  WHERE  uoo_id =  cp_uoo_id;

  --23
  CURSOR c_usec_spl_fees (cp_uoo_id NUMBER)  IS
  SELECT *
  FROM   igs_ps_usec_sp_fees
  WHERE  uoo_id =  cp_uoo_id;

  CURSOR c_rtn_us IS
  SELECT a.*
  FROM  igs_ps_nsus_rtn a,
        igs_ps_unit_ofr_opt_all b
  WHERE a.uoo_id = p_old_uoo_id
  AND   a.uoo_id = b.uoo_id
  AND   b.non_std_usec_ind = 'Y'
  AND   a.definition_code IN ('UNIT_SECTION','UNIT_SECTION_FEE_TYPE');

  CURSOR c_rtn_us_dtl(cp_non_std_usec_rtn_id igs_ps_nsus_rtn_dtl.non_std_usec_rtn_id%TYPE) IS
  SELECT *
  FROM  igs_ps_nsus_rtn_dtl
  WHERE non_std_usec_rtn_id = cp_non_std_usec_rtn_id;

  CURSOR usec_fac(cp_unit_section_occurrence_id  igs_ps_uso_facility.unit_section_occurrence_id%TYPE) IS
  SELECT *
  FROM igs_ps_uso_facility
  WHERE  unit_section_occurrence_id =  cp_unit_section_occurrence_id;

  CURSOR c_fee_type_cal_exists(cp_c_source_fee_type   igs_fi_fee_type.fee_type%TYPE) IS
  SELECT ci.cal_type,ci.sequence_number
  FROM  igs_fi_fee_type ft,
        igs_fi_f_typ_ca_inst ftci,
        igs_ca_inst ci,
        igs_ca_type ct,
        igs_ca_stat cs
  WHERE ft.s_fee_type IN ('TUTNFEE', 'OTHER', 'SPECIAL', 'AUDIT')
  AND   ft.closed_ind = 'N'
  AND   ft.fee_type = ftci.fee_type
  AND   ft.fee_type = cp_c_source_fee_type
  AND   ftci.fee_cal_type = ci.cal_type
  AND   ftci.fee_ci_sequence_number = ci.sequence_number
  AND   ci.cal_type = ct.cal_type
  AND   ct.s_cal_cat = 'FEE'
  AND   ci.cal_status = cs.cal_status
  AND   cs.s_cal_status = 'ACTIVE';

  CURSOR c_teach_date(cp_cal_type igs_ca_inst_all.cal_type%TYPE ,cp_seq_num  igs_ca_inst_all.sequence_number%TYPE) IS
  SELECT start_dt,end_dt
  FROM   igs_ca_inst_all
  WHERE  cal_type = cp_cal_type
  AND    sequence_number = cp_seq_num;

  l_d_src_teach_cal_start_dt  DATE;
  l_d_src_teach_cal_end_dt    DATE;
  l_d_dst_teach_cal_start_dt  DATE;
  l_d_dst_teach_cal_end_dt    DATE;

  CURSOR cur_config IS
  SELECT *
  FROM igs_ps_sch_ocr_cfig;
  l_rec_config cur_config%ROWTYPE;
  l_config_rec_found  BOOLEAN;

  CURSOR cur_ass_item(cp_uoo_id IN NUMBER, cp_us_ass_item_group_id IN NUMBER) IS
  SELECT 'X'
  FROM   igs_ps_unitass_item
  WHERE  uoo_id = cp_uoo_id
  AND    us_ass_item_group_id = cp_us_ass_item_group_id;
  l_c_var  VARCHAR2(1);

  --To find if there is any lead instructor in the Destination
  CURSOR cur_usec_tchr_lead(cp_uoo_id         igs_ps_usec_tch_resp.uoo_id%TYPE) IS
  SELECT instructor_id
  FROM  igs_ps_usec_tch_resp
  WHERE uoo_id =  cp_uoo_id
  AND lead_instructor_flag = 'Y';
  cur_usec_tchr_lead_rec cur_usec_tchr_lead%ROWTYPE;

  --To find if the occurrence instructor passed is a lead in the source.
  CURSOR cur_usec_tchr1(cp_uoo_id  igs_ps_usec_tch_resp.uoo_id%TYPE,cp_ins igs_ps_usec_tch_resp.instructor_id%TYPE) IS
  SELECT instructor_id
  FROM  igs_ps_usec_tch_resp
  WHERE uoo_id =  cp_uoo_id
  AND lead_instructor_flag = 'Y'
  AND instructor_id = cp_ins;
  cur_usec_tchr1_rec cur_usec_tchr1%ROWTYPE;


  l_resp_flag BOOLEAN ;
  l_dest_lead_inst_id igs_ps_usec_tch_resp.instructor_id%TYPE;

 ---------------------------
 CURSOR cur_ftci(cp_c_cal_type igs_ca_teach_to_load_v.teach_cal_type%TYPE,
                 cp_n_sequence_number igs_ca_teach_to_load_v.teach_ci_sequence_number%TYPE) IS
 SELECT sup_cal_type cal_type, sup_ci_sequence_number sequence_number
 FROM   igs_ca_inst_rel
 WHERE (sub_cal_type,sub_ci_sequence_number) IN (SELECT load_cal_type, load_ci_sequence_number
                                                 FROM   igs_ca_teach_to_load_v
						 WHERE  teach_cal_type = cp_c_cal_type
						 AND    teach_ci_sequence_number = cp_n_sequence_number);
  TYPE teach_cal_rec IS RECORD(
			       cal_type igs_ca_inst_all.cal_type%TYPE,
			       sequence_number igs_ca_inst_all.sequence_number%TYPE
			       );
  TYPE teachCalendar IS TABLE OF teach_cal_rec INDEX BY BINARY_INTEGER;
  teachCalendar_tbl teachCalendar;
  l_n_counter NUMBER(10);
  l_c_proceed BOOLEAN ;



BEGIN
  -- This PROCEDURE IS responsible FOR transferring ALL the details OF one unit offering OPTION TO
  -- another.It gets records (OLD location_cd AND unit class) AND transfers (duplicates)  them ALL
  -- over TO a NEW unit offering option. An EXCEPTION handler IS raised WHEN an error occurs.

  -- This checks IF the specified NEW unit offering OPTION exists
  OPEN gc_usec_new_rec;
  FETCH gc_usec_new_rec INTO gv_new_usec_rec;
  IF gc_usec_new_rec%NOTFOUND THEN
     p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
     CLOSE gc_usec_new_rec;
     RETURN;
  END IF;
  CLOSE gc_usec_new_rec;

  -- This checks IF the specified OLD unit offering OPTION NOT exists
  OPEN gc_usec_old_rec;
  FETCH gc_usec_old_rec INTO gv_old_usec_rec;
  IF gc_usec_old_rec%NOTFOUND THEN
     p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
     CLOSE gc_usec_old_rec;
     RETURN;
  END IF;
  CLOSE gc_usec_old_rec;

  -- Validation SUCCESSFUL

  -- Rollover of unit section occurrence records

  OPEN c_teach_date(gv_old_usec_rec.cal_type,gv_old_usec_rec.ci_sequence_number);
  FETCH c_teach_date INTO l_d_src_teach_cal_start_dt,l_d_src_teach_cal_end_dt;
  CLOSE c_teach_date;

  OPEN c_teach_date(gv_new_usec_rec.cal_type,gv_new_usec_rec.ci_sequence_number);
  FETCH c_teach_date INTO l_d_dst_teach_cal_start_dt,l_d_dst_teach_cal_end_dt;
  CLOSE c_teach_date;

  OPEN cur_config;
  FETCH cur_config INTO l_rec_config;
  IF cur_config%NOTFOUND THEN
    l_config_rec_found:= FALSE;
  ELSE
    l_config_rec_found:= TRUE;
  END IF;
  CLOSE cur_config;

  FOR  usec_occurs_rec IN  usec_occurs (p_old_uoo_Id ) LOOP
    DECLARE

       CURSOR cur_occur_new (cp_uoo_id   igs_ps_usec_occurs_all.uoo_id%TYPE,
                             cp_occurrence_identifier igs_ps_usec_occurs_all.occurrence_identifier%TYPE) IS
       SELECT 'X'
       FROM   igs_ps_usec_occurs_all
       WHERE  uoo_id = cp_uoo_id
       AND    occurrence_identifier=cp_occurrence_identifier
       AND    ROWNUM = 1 ;
       l_cur_occur_new   cur_occur_new%ROWTYPE;

       lv_rowid  VARCHAR2(25);
       l_usec_id NUMBER;
       l_org_id  NUMBER(15);
       l_d_uso_dest_start_dt       DATE;
       l_d_uso_dest_end_dt         DATE;
       l_n_num_st_days             NUMBER;
       l_n_num_end_days            NUMBER;


       l_c_monday igs_ps_usec_occurs_all.monday%TYPE;
       l_c_tuesday igs_ps_usec_occurs_all.tuesday%TYPE;
       l_c_wednesday igs_ps_usec_occurs_all.wednesday%TYPE;
       l_c_thursday igs_ps_usec_occurs_all.thursday%TYPE;
       l_c_friday igs_ps_usec_occurs_all.friday%TYPE;
       l_c_saturday igs_ps_usec_occurs_all.saturday%TYPE;
       l_c_sunday igs_ps_usec_occurs_all.sunday%TYPE;
       l_d_start_time igs_ps_usec_occurs_all.start_time%TYPE;
       l_d_end_time igs_ps_usec_occurs_all.end_time%TYPE;
       l_c_building_code igs_ps_usec_occurs_all.building_code%TYPE;
       l_c_room_code igs_ps_usec_occurs_all.room_code%TYPE;
       l_c_dedicated_building_code igs_ps_usec_occurs_all.dedicated_building_code%TYPE;
       l_c_dedicated_room_code igs_ps_usec_occurs_all.dedicated_room_code%TYPE;
       l_c_preferred_building_code igs_ps_usec_occurs_all.preferred_building_code%TYPE;
       l_c_preferred_room_code igs_ps_usec_occurs_all.preferred_room_code%TYPE;
       l_c_preferred_region_code igs_ps_usec_occurs_all.preferred_region_code%TYPE;
       l_c_inst_change_notify   igs_ps_usec_occurs_all.inst_notify_ind%TYPE;
       l_c_attribute_category igs_ps_usec_occurs_all.attribute_category%TYPE;
       l_c_attribute1  igs_ps_usec_occurs_all.attribute1%TYPE;
       l_c_attribute2  igs_ps_usec_occurs_all.attribute2%TYPE;
       l_c_attribute3  igs_ps_usec_occurs_all.attribute3%TYPE;
       l_c_attribute4  igs_ps_usec_occurs_all.attribute4%TYPE;
       l_c_attribute5  igs_ps_usec_occurs_all.attribute5%TYPE;
       l_c_attribute6  igs_ps_usec_occurs_all.attribute6%TYPE;
       l_c_attribute7  igs_ps_usec_occurs_all.attribute7%TYPE;
       l_c_attribute8  igs_ps_usec_occurs_all.attribute8%TYPE;
       l_c_attribute9  igs_ps_usec_occurs_all.attribute9%TYPE;
       l_c_attribute10 igs_ps_usec_occurs_all.attribute10%TYPE;
       l_c_attribute11 igs_ps_usec_occurs_all.attribute11%TYPE;
       l_c_attribute12 igs_ps_usec_occurs_all.attribute12%TYPE;
       l_c_attribute13 igs_ps_usec_occurs_all.attribute13%TYPE;
       l_c_attribute14 igs_ps_usec_occurs_all.attribute14%TYPE;
       l_c_attribute15 igs_ps_usec_occurs_all.attribute15%TYPE;
       l_c_attribute16 igs_ps_usec_occurs_all.attribute16%TYPE;
       l_c_attribute17 igs_ps_usec_occurs_all.attribute17%TYPE;
       l_c_attribute18 igs_ps_usec_occurs_all.attribute18%TYPE;
       l_c_attribute19 igs_ps_usec_occurs_all.attribute19%TYPE;
       l_c_attribute20 igs_ps_usec_occurs_all.attribute20%TYPE;
       l_occur_roll_allowed BOOLEAN;
    BEGIN
      l_org_id := igs_ge_gen_003.get_org_id;

      IF usec_occurs_rec.start_date IS NOT NULL THEN
        l_n_num_st_days       := usec_occurs_rec.start_date - NVL(gv_old_usec_rec.unit_section_start_date,l_d_src_teach_cal_start_dt);
        l_d_uso_dest_start_dt := NVL(gv_new_usec_rec.unit_section_start_date,l_d_dst_teach_cal_start_dt) + l_n_num_st_days;
      ELSE
        l_d_uso_dest_start_dt := NULL;
      END IF;

      IF usec_occurs_rec.end_date IS NOT NULL THEN
        l_n_num_end_days      := NVL(gv_old_usec_rec.unit_section_end_date,l_d_src_teach_cal_end_dt) - usec_occurs_rec.end_date ;
        l_d_uso_dest_end_dt   := NVL(gv_new_usec_rec.unit_section_end_date,l_d_dst_teach_cal_end_dt) - l_n_num_end_days;
      ELSE
        l_d_uso_dest_end_dt   := NULL;
      END IF;

      --Unit section occurrence start date must not be greater than the unit section end date if exists ,
      --if does not exists then must not be greater than teaching calendar end date
      IF l_d_uso_dest_start_dt IS NOT NULL THEN
          IF l_d_uso_dest_start_dt >  NVL(l_d_uso_dest_end_dt,NVL(gv_new_usec_rec.unit_section_end_date,l_d_dst_teach_cal_end_dt)) THEN
             l_d_uso_dest_start_dt :=  NVL(gv_new_usec_rec.unit_section_start_date,l_d_dst_teach_cal_start_dt);
	  END IF;
      END IF;
      --Unit section occurrence end date must not be less than the unit section start date if exists ,
      --if does not exists then must not be less than teaching calendar start date
      IF l_d_uso_dest_end_dt IS NOT NULL THEN
          IF l_d_uso_dest_end_dt < NVL(l_d_uso_dest_start_dt,NVL(gv_new_usec_rec.unit_section_start_date,l_d_dst_teach_cal_start_dt)) THEN
             l_d_uso_dest_end_dt := NVL(gv_new_usec_rec.unit_section_end_date,l_d_dst_teach_cal_end_dt);
	  END IF;
      END IF;

      -- As part of bug#2833850 added columns preferred_region_code and no_set_day_ind to the call of
      -- igs_ps_usec_occurs_pkg.insert_row

      --Added as a part of scheduling Enhancement IGS.M
      l_occur_roll_allowed := TRUE;

      IF l_config_rec_found = FALSE THEN
        l_c_monday:= usec_occurs_rec.monday;
        l_c_tuesday:= usec_occurs_rec.tuesday;
        l_c_wednesday:= usec_occurs_rec.wednesday;
        l_c_thursday:= usec_occurs_rec.thursday;
        l_c_friday:= usec_occurs_rec.friday;
        l_c_saturday:= usec_occurs_rec.saturday;
        l_c_sunday:= usec_occurs_rec.sunday;
        l_d_start_time:= usec_occurs_rec.start_time;
        l_d_end_time:= usec_occurs_rec.end_time;
        l_c_building_code:= usec_occurs_rec.building_code;
        l_c_room_code:= usec_occurs_rec.room_code;
        l_c_dedicated_building_code:= usec_occurs_rec.dedicated_building_code;
        l_c_dedicated_room_code:= usec_occurs_rec.dedicated_room_code;
        l_c_preferred_building_code:= usec_occurs_rec.preferred_building_code;
        l_c_preferred_room_code:= usec_occurs_rec.preferred_room_code;
        l_c_preferred_region_code:= usec_occurs_rec.preferred_region_code;
        l_c_inst_change_notify:= usec_occurs_rec.inst_notify_ind;
        l_c_attribute_category :=usec_occurs_rec.attribute_category;
        l_c_attribute1 := usec_occurs_rec.attribute1;
        l_c_attribute2 := usec_occurs_rec.attribute2;
        l_c_attribute3 := usec_occurs_rec.attribute3;
        l_c_attribute4 := usec_occurs_rec.attribute4;
        l_c_attribute5 := usec_occurs_rec.attribute5;
        l_c_attribute6 := usec_occurs_rec.attribute6;
        l_c_attribute7 := usec_occurs_rec.attribute7;
        l_c_attribute8 := usec_occurs_rec.attribute8;
        l_c_attribute9 := usec_occurs_rec.attribute9;
        l_c_attribute10 := usec_occurs_rec.attribute10;
        l_c_attribute11 := usec_occurs_rec.attribute11;
        l_c_attribute12 := usec_occurs_rec.attribute12;
        l_c_attribute13 := usec_occurs_rec.attribute13;
        l_c_attribute14 := usec_occurs_rec.attribute14;
        l_c_attribute15 := usec_occurs_rec.attribute15;
        l_c_attribute16 := usec_occurs_rec.attribute16;
        l_c_attribute17 := usec_occurs_rec.attribute17;
        l_c_attribute18 := usec_occurs_rec.attribute18;
        l_c_attribute19 := usec_occurs_rec.attribute19;
        l_c_attribute20 := usec_occurs_rec.attribute20;

      ELSE
        --If scheduling Not required/TBA checkbox is unchecked in configuration form then do not rollover Not required/TBA occurrences
	IF (l_rec_config.to_be_announced_roll_flag = 'N' AND usec_occurs_rec.to_be_announced='Y') OR (l_rec_config.schd_not_rqd_roll_flag = 'N' AND usec_occurs_rec.no_set_day_ind ='Y')  THEN
          l_occur_roll_allowed := FALSE;
	END IF;

        IF l_rec_config.day_roll_flag ='Y' THEN
          l_c_monday:= usec_occurs_rec.monday;
          l_c_tuesday:= usec_occurs_rec.tuesday;
          l_c_wednesday:= usec_occurs_rec.wednesday;
          l_c_thursday:= usec_occurs_rec.thursday;
          l_c_friday:= usec_occurs_rec.friday;
          l_c_saturday:= usec_occurs_rec.saturday;
          l_c_sunday:= usec_occurs_rec.sunday;
	ELSE
	  IF l_rec_config.schd_not_rqd_roll_flag = 'Y' THEN
            l_c_monday:= 'N';
            l_c_tuesday:= 'N';
            l_c_wednesday:= 'N';
            l_c_thursday:= 'N';
            l_c_friday:= 'N';
            l_c_saturday:= 'N';
            l_c_sunday:= 'N';
          ELSE
            l_c_monday:= usec_occurs_rec.monday;
            l_c_tuesday:= usec_occurs_rec.tuesday;
            l_c_wednesday:= usec_occurs_rec.wednesday;
            l_c_thursday:= usec_occurs_rec.thursday;
            l_c_friday:= usec_occurs_rec.friday;
            l_c_saturday:= usec_occurs_rec.saturday;
            l_c_sunday:= usec_occurs_rec.sunday;
	  END IF;
	END IF;

	IF l_rec_config.time_roll_flag = 'Y' THEN
          l_d_start_time:= usec_occurs_rec.start_time;
          l_d_end_time:= usec_occurs_rec.end_time;
        ELSE
          l_d_start_time:= NULL;
          l_d_end_time:= NULL;
	END IF;

        IF l_rec_config.scheduled_bld_roll_flag = 'Y' THEN
          l_c_building_code:= usec_occurs_rec.building_code;
	ELSE
          l_c_building_code:= NULL;
	END IF;

        IF l_rec_config.scheduled_room_roll_flag = 'Y' THEN
          l_c_room_code:= usec_occurs_rec.room_code;
	ELSE
          l_c_room_code:= NULL;
	END IF;

        IF l_rec_config.dedicated_bld_roll_flag = 'Y' THEN
          l_c_dedicated_building_code:= usec_occurs_rec.dedicated_building_code;
	ELSE
          l_c_dedicated_building_code:= NULL;
	END IF;

        IF l_rec_config.dedicated_room_roll_flag = 'Y' THEN
          l_c_dedicated_room_code:= usec_occurs_rec.dedicated_room_code;
	ELSE
          l_c_dedicated_room_code:= NULL;
	END IF;

        IF l_rec_config.preferred_bld_roll_flag = 'Y' THEN
          l_c_preferred_building_code:= usec_occurs_rec.preferred_building_code;
	ELSE
          l_c_preferred_building_code:= NULL;
	END IF;

        IF l_rec_config.preferred_room_roll_flag = 'Y' THEN
          l_c_preferred_room_code:= usec_occurs_rec.preferred_room_code;
	ELSE
          l_c_preferred_room_code:= NULL;
	END IF;

        IF l_rec_config.preferred_region_roll_flag = 'Y' THEN
          l_c_preferred_region_code:= usec_occurs_rec.preferred_region_code;
	ELSE
          l_c_preferred_region_code:= NULL;
	END IF;

        IF l_rec_config.inc_ins_change_notfy_roll_flag = 'Y' THEN
          l_c_inst_change_notify:= usec_occurs_rec.inst_notify_ind;
	ELSE
          l_c_inst_change_notify:= NULL;
	END IF;

        IF l_rec_config.occur_flexfield_roll_flag = 'Y' THEN
          l_c_attribute_category :=usec_occurs_rec.attribute_category;
          l_c_attribute1 := usec_occurs_rec.attribute1;
          l_c_attribute2 := usec_occurs_rec.attribute2;
          l_c_attribute3 := usec_occurs_rec.attribute3;
          l_c_attribute4 := usec_occurs_rec.attribute4;
          l_c_attribute5 := usec_occurs_rec.attribute5;
          l_c_attribute6 := usec_occurs_rec.attribute6;
          l_c_attribute7 := usec_occurs_rec.attribute7;
          l_c_attribute8 := usec_occurs_rec.attribute8;
          l_c_attribute9 := usec_occurs_rec.attribute9;
          l_c_attribute10 := usec_occurs_rec.attribute10;
          l_c_attribute11 := usec_occurs_rec.attribute11;
          l_c_attribute12 := usec_occurs_rec.attribute12;
          l_c_attribute13 := usec_occurs_rec.attribute13;
          l_c_attribute14 := usec_occurs_rec.attribute14;
          l_c_attribute15 := usec_occurs_rec.attribute15;
          l_c_attribute16 := usec_occurs_rec.attribute16;
          l_c_attribute17 := usec_occurs_rec.attribute17;
          l_c_attribute18 := usec_occurs_rec.attribute18;
          l_c_attribute19 := usec_occurs_rec.attribute19;
          l_c_attribute20 := usec_occurs_rec.attribute20;
        ELSE
          l_c_attribute_category :=NULL;
          l_c_attribute1 := NULL;
          l_c_attribute2 := NULL;
          l_c_attribute3 := NULL;
          l_c_attribute4 := NULL;
          l_c_attribute5 := NULL;
          l_c_attribute6 := NULL;
          l_c_attribute7 := NULL;
          l_c_attribute8 := NULL;
          l_c_attribute9 := NULL;
          l_c_attribute10 := NULL;
          l_c_attribute11 := NULL;
          l_c_attribute12 := NULL;
          l_c_attribute13 := NULL;
          l_c_attribute14 := NULL;
          l_c_attribute15 := NULL;
          l_c_attribute16 := NULL;
          l_c_attribute17 := NULL;
          l_c_attribute18 := NULL;
          l_c_attribute19 := NULL;
          l_c_attribute20 := NULL;
	END IF;


      END IF;

      IF l_occur_roll_allowed = TRUE THEN
	OPEN cur_occur_new(p_new_uoo_id,usec_occurs_rec.occurrence_identifier);
	FETCH cur_occur_new INTO l_cur_occur_new;
	IF cur_occur_new%NOTFOUND THEN

	      igs_ps_usec_occurs_pkg.insert_row (
		x_rowid                     => lv_rowid,
		x_unit_section_occurrence_id=> l_usec_id,
		x_uoo_id                    =>  p_new_uoo_id ,
		x_monday                    =>  l_c_monday,
		x_tuesday                   =>  l_c_tuesday,
		x_wednesday                 =>  l_c_wednesday,
		x_thursday                  =>  l_c_thursday,
		x_friday                    =>  l_c_friday,
		x_saturday                  =>  l_c_saturday,
		x_sunday                    =>  l_c_sunday,
		x_start_time                =>  l_d_start_time,
		x_end_time                  =>  l_d_end_time,
		x_building_code             =>  l_c_building_code,
		x_room_code                 =>  l_c_room_code,
		x_schedule_status           =>  NULL,
		x_status_last_updated       =>  NULL,
		x_instructor_id             =>  usec_occurs_rec.instructor_id  ,
		x_error_text                =>  NULL,
		x_mode                      =>  'R' ,
		x_org_id                    => l_org_id,
		x_start_date                => l_d_uso_dest_start_dt,
		x_end_date                  => l_d_uso_dest_end_dt,
		x_to_be_announced           => usec_occurs_rec.to_be_announced,
		x_attribute_category        => l_c_attribute_category,
		x_attribute1                => l_c_attribute1,
		x_attribute2                => l_c_attribute2,
		x_attribute3                => l_c_attribute3,
		x_attribute4                => l_c_attribute4,
		x_attribute5                => l_c_attribute5,
		x_attribute6                => l_c_attribute6,
		x_attribute7                => l_c_attribute7,
		x_attribute8                => l_c_attribute8,
		x_attribute9                => l_c_attribute9,
		x_attribute10               => l_c_attribute10,
		x_attribute11               => l_c_attribute11,
		x_attribute12               => l_c_attribute12,
		x_attribute13               => l_c_attribute13,
		x_attribute14               => l_c_attribute14,
		x_attribute15               => l_c_attribute15,
		x_attribute16               => l_c_attribute16,
		x_attribute17               => l_c_attribute17,
		x_attribute18               => l_c_attribute18,
		x_attribute19               => l_c_attribute19,
		x_attribute20               => l_c_attribute20,
		x_inst_notify_ind           => l_c_inst_change_notify,
		x_notify_status             => 'NEW',
		x_dedicated_building_code   => l_c_dedicated_building_code,
		x_dedicated_room_code       => l_c_dedicated_room_code,
		x_preferred_building_code   => l_c_preferred_building_code,
		x_preferred_room_code       => l_c_preferred_room_code,
		x_preferred_region_code     => l_c_preferred_region_code,
		x_no_set_day_ind            => usec_occurs_rec.no_set_day_ind,
		x_cancel_flag               => 'N',
		x_occurrence_identifier     => usec_occurs_rec.occurrence_identifier,
		x_abort_flag                => 'N');

	    -- Rollover of unit section occurrence reference code records
	    --Added this if condition as a part of scheduling Enhancement IGS.M
	    IF l_config_rec_found = FALSE OR l_rec_config.ref_cd_roll_flag ='Y' THEN
	      FOR  usec_occurs_refcd_rec IN usec_occurs_refcd(usec_occurs_rec.unit_section_occurrence_id ) LOOP
		DECLARE
		  lv_rowid VARCHAR2(25);
		  l_usec_ref_id NUMBER;
		BEGIN
		  igs_ps_usec_ocur_ref_pkg.insert_row(
		    x_rowid                       => lv_rowid,
		    x_unit_sec_occur_reference_id => l_usec_ref_id,
		    x_unit_section_occurrence_id  => l_usec_id,
		    x_reference_code_type         => usec_occurs_refcd_rec.reference_code_type,
		    x_reference_code              => usec_occurs_refcd_rec.reference_code,
		    x_mode                        => 'R',
		    x_reference_code_desc         => usec_occurs_refcd_rec.reference_code_desc);
		EXCEPTION
		  WHEN OTHERS THEN
		    --Fnd log implementation
		    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
		      fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	              SUBSTRB('Unit Section Occurrence Id:'||usec_occurs_refcd_rec.unit_section_occurrence_id||'  '||'Reference Code Type:'||usec_occurs_refcd_rec.reference_code_type||'  '||
		      'Reference Code:'||usec_occurs_refcd_rec.reference_code||'  '||NVL(fnd_message.get,SQLERRM),1,4000));
		    END IF;
		END;
	      END LOOP;
	    END IF;

	    --Enhancement bug no 1800179 , pmarada
	    -- Rollover of unit section occurrence Instructor records
	    --Added this if condition as a part of scheduling Enhancement IGS.M


	    IF l_config_rec_found = FALSE OR l_rec_config.instructor_roll_flag ='Y' THEN
	    OPEN cur_usec_tchr_lead(p_new_uoo_id);
	    FETCH cur_usec_tchr_lead INTO l_dest_lead_inst_id;
            CLOSE cur_usec_tchr_lead;

	      FOR usec_instr_rec IN usec_instr (usec_occurs_rec.unit_section_occurrence_id) Loop
		DECLARE
		  lv_rowid VARCHAR2(25);
		  l_uso_instructor_id NUMBER;
		BEGIN

		  OPEN cur_usec_tchr1(p_old_uoo_Id,usec_instr_rec.instructor_id);
		  FETCH cur_usec_tchr1 INTO cur_usec_tchr1_rec;
		  IF cur_usec_tchr1%FOUND AND l_dest_lead_inst_id IS NOT NULL THEN
                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
			fnd_log.string( fnd_log.level_statement, 'igs.plsql.IGS_PS_GEN_001.crsp_ins_unit_section.instructor_not_rolled_over_one_lead_already_in_destination_unit_section',
			'Not rolling over Lead Instructo:'||usec_instr_rec.instructor_id||'  '||'from Source UOO:'||p_old_uoo_Id||'  '||
			'to Destination UOO:'||p_new_uoo_id||'  '||'as there already exists a different Lead Instructor:'||cur_usec_tchr_lead_rec.instructor_id||'  '||
			'in the Destination');
		    END IF;
		    CLOSE cur_usec_tchr1;
		  ELSE
		    igs_ps_uso_instrctrs_pkg.insert_row (
		    x_rowid                      => lv_rowid,
		    x_uso_instructor_id          => l_uso_instructor_id,
		    x_unit_section_occurrence_id => l_usec_id,
		    x_instructor_id              => usec_instr_rec.instructor_id,
		    x_mode                       => 'R' );
		    CLOSE cur_usec_tchr1;
                    END IF;
		EXCEPTION
		  WHEN OTHERS THEN
		    --Fnd log implementation
		    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
		      fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	              SUBSTRB('Unit Section Occurrence Id:'||usec_instr_rec.unit_section_occurrence_id||'  '||'Instructor Id:'||usec_instr_rec.instructor_id||'  '||
		      NVL(fnd_message.get,SQLERRM),1,4000));
		    END IF;
		END;
	      END LOOP;
	    END IF;

	    -- Rollover of unit section occurrence facilities records
	    --Added this as a part of scheduling Enhancement IGS.M
	    IF l_config_rec_found = FALSE OR l_rec_config.facility_roll_flag ='Y' THEN
	      FOR usec_fac_rec IN usec_fac (usec_occurs_rec.unit_section_occurrence_id) LOOP
		DECLARE
		  lv_rowid VARCHAR2(25);
		  l_uso_facility_id NUMBER;
		BEGIN
		  igs_ps_uso_facility_pkg.insert_row (
		    x_rowid                      => lv_rowid,
		    x_uso_facility_id            => l_uso_facility_id,
		    x_unit_section_occurrence_id => l_usec_id,
		    x_facility_code              => usec_fac_rec.facility_code,
		    x_mode                       => 'R' );
		EXCEPTION
		  WHEN OTHERS THEN
		    --Fnd log implementation
		    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
		      fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	              SUBSTRB('Unit Section Occurrence Id:'||usec_fac_rec.unit_section_occurrence_id||'  '||'Facility Code:'||usec_fac_rec.facility_code||'  '||
		      NVL(fnd_message.get,SQLERRM),1,4000));
		    END IF;
		END;
	      END LOOP;
	    END IF;

	 END IF; --end of cur_occur_new
	 CLOSE cur_occur_new;

       END IF; --Roll allowed

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Section Occurrence Id:'||usec_occurs_rec.unit_section_occurrence_id||'  '||'Occurrence Identifier:'||usec_occurs_rec.occurrence_identifier||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;

  END LOOP;


  --Enhancement bug no 1800179 , pmarada
  -- Rollover of unit section enrollment limit records
  FOR wlst_limit_rec IN wlst_limit (p_old_uoo_Id ) LOOP
    DECLARE
      lv_rowid VARCHAR2(25);
      l_usec_lim_id NUMBER;

      --following two  cursors are added by sarakshi,bug#2332807
      CURSOR  cur_get_parameters IS
      SELECT unit_cd,version_number,cal_type,ci_sequence_number
      FROM   igs_ps_unit_ofr_opt
      WHERE  uoo_id=p_new_uoo_id;
      l_cur_get_parameters cur_get_parameters%ROWTYPE;

      CURSOR cur_waitlist_chk(cp_unit_cd            igs_ps_unit_ofr_opt.unit_cd%TYPE,
                              cp_version_number     igs_ps_unit_ofr_opt.version_number%TYPE,
                              cp_cal_type           igs_ps_unit_ofr_opt.cal_type%TYPE,
                              cp_ci_sequence_number igs_ps_unit_ofr_opt.ci_sequence_number%TYPE) IS
      SELECT waitlist_allowed
      FROM   igs_ps_unit_ofr_pat
      WHERE  unit_cd=cp_unit_cd
      AND    version_number=cp_version_number
      AND    cal_type=cp_cal_type
      AND    ci_sequence_number=cp_ci_sequence_number
      AND    delete_flag = 'N';
      l_cur_waitlist  cur_waitlist_chk%ROWTYPE;

      CURSOR cur_wlst_limit_new (cp_uoo_id   igs_ps_usec_lim_wlst.uoo_id%TYPE) IS
      SELECT unit_section_limit_waitlist_id ,waitlist_allowed
      FROM   igs_ps_usec_lim_wlst
      WHERE  uoo_id = cp_uoo_id
      AND    ROWNUM = 1 ;
      l_cur_wlst_limit_new   cur_wlst_limit_new%ROWTYPE;

    BEGIN

      OPEN cur_wlst_limit_new(p_new_uoo_id);
      FETCH cur_wlst_limit_new INTO l_cur_wlst_limit_new;
      IF cur_wlst_limit_new%NOTFOUND THEN
        --following validation is added by sarakshi,bug#2332807
        --if waitlist allowed is set to N at unit pattern level then in igs_ps_usec_lim_wlst we should pass N only
        --and not allow any insert in priority and preferences table.
        OPEN cur_get_parameters;
        FETCH cur_get_parameters INTO l_cur_get_parameters;
        CLOSE cur_get_parameters;

        OPEN cur_waitlist_chk(l_cur_get_parameters.unit_cd,l_cur_get_parameters.version_number,
                              l_cur_get_parameters.cal_type,l_cur_get_parameters.ci_sequence_number);
        FETCH cur_waitlist_chk INTO l_cur_waitlist;
        CLOSE cur_waitlist_chk;
        IF NVL(l_cur_waitlist.waitlist_allowed,'N') = 'N' THEN
          wlst_limit_rec.waitlist_allowed:='N';
          wlst_limit_rec.max_students_per_waitlist:=0;
        END IF;


        igs_ps_usec_lim_wlst_pkg.insert_row(
          x_rowid                        => lv_rowid,
          x_unit_section_limit_wlst_id   => l_usec_lim_id,
          x_uoo_id                       => p_new_uoo_id,
          x_enrollment_expected          => wlst_limit_rec.enrollment_expected ,
          x_enrollment_minimum           => wlst_limit_rec.enrollment_minimum  ,
          x_enrollment_maximum           => wlst_limit_rec.enrollment_maximum ,
          x_advance_maximum              => wlst_limit_rec.advance_maximum,
          x_override_enrollment_max      => wlst_limit_rec.override_enrollment_max,
          x_waitlist_allowed             => wlst_limit_rec.waitlist_allowed ,
          x_max_students_per_waitlist    => wlst_limit_rec.max_students_per_waitlist,
          x_max_auditors_allowed         => wlst_limit_rec.max_auditors_allowed,
          x_mode                         => 'R'
        );
      END IF;
      CLOSE cur_wlst_limit_new;
      IF NVL(l_cur_waitlist.waitlist_allowed,l_cur_wlst_limit_new.waitlist_allowed) = 'Y' THEN
        -- Rollover of unit section waitlist priority records
        FOR wlst_pri_rec IN wlst_pri (p_old_uoo_Id) LOOP
          DECLARE
            CURSOR cur_wlst_pri_new(cp_uoo_id                       igs_ps_usec_wlst_pri.uoo_id%TYPE,
                                    cp_priority_number              igs_ps_usec_wlst_pri.priority_number%TYPE,
                                    cp_priority_value               igs_ps_usec_wlst_pri.priority_value%TYPE)  IS
            SELECT unit_sec_waitlist_priority_id
            FROM   igs_ps_usec_wlst_pri
            WHERE  uoo_id = cp_uoo_id
            AND    priority_number = cp_priority_number
            AND    priority_value  = cp_priority_value
            AND    ROWNUM = 1 ;
            l_cur_wlst_pri_new  cur_wlst_pri_new%ROWTYPE;

            lv_rowid VARCHAR2(25);
            l_usec_pri_id NUMBER;
          BEGIN
	    OPEN cur_wlst_pri_new(p_new_uoo_id, wlst_pri_rec.priority_number, wlst_pri_rec.priority_value);
            FETCH cur_wlst_pri_new INTO l_cur_wlst_pri_new;
            IF cur_wlst_pri_new%NOTFOUND THEN
              igs_ps_usec_wlst_pri_pkg.insert_row(
                x_rowid                      => lv_rowid,
                x_unit_sec_wlst_priority_id  => l_usec_pri_id,
                x_priority_number            => wlst_pri_rec.priority_number  ,
                x_priority_value             => wlst_pri_rec.priority_value    ,
		x_uoo_id                     => p_new_uoo_Id,
                x_mode                       => 'R'
                );
            END IF;
            CLOSE cur_wlst_pri_new;

            -- Rollover of unit section waitlist preference records
            FOR wlst_prf_rec IN wlst_prf (wlst_pri_rec.unit_sec_waitlist_priority_id ) LOOP
              DECLARE
                CURSOR cur_wlst_prf_new(cp_unit_sec_wlst_priority_id   igs_ps_usec_wlst_prf.unit_sec_waitlist_priority_id%TYPE,
                                        cp_preference_code             igs_ps_usec_wlst_prf.preference_code%TYPE,
                                        cp_preference_version          igs_ps_usec_wlst_prf.preference_version%TYPE)  IS
                SELECT 'X'
                FROM   igs_ps_usec_wlst_prf
                WHERE  unit_sec_waitlist_priority_id = cp_unit_sec_wlst_priority_id
                AND    preference_code = cp_preference_code
                AND    preference_version  = cp_preference_version
                AND    ROWNUM = 1 ;
                l_cur_wlst_prf_new  cur_wlst_prf_new%ROWTYPE;

                lv_rowid VARCHAR2(25);
                l_usec_prf_id NUMBER;
              BEGIN

                OPEN cur_wlst_prf_new(NVL(l_usec_pri_id,l_cur_wlst_pri_new.unit_sec_waitlist_priority_id), wlst_prf_rec.preference_code, wlst_prf_rec.preference_version);
                FETCH cur_wlst_prf_new INTO l_cur_wlst_prf_new;
                IF cur_wlst_prf_new%NOTFOUND THEN
                  igs_ps_usec_wlst_prf_pkg.insert_row(
                    x_rowid                     => lv_rowid,
                    x_unit_sec_waitlist_pref_id => l_usec_prf_id,
                    x_unit_sec_wlst_priority_id => NVL(l_usec_pri_id,l_cur_wlst_pri_new.unit_sec_waitlist_priority_id),
                    x_preference_order          => wlst_prf_rec.preference_order ,
                    x_preference_code           => wlst_prf_rec.preference_code ,
                    x_preference_version        => wlst_prf_rec.preference_version  ,
                    x_mode                      => 'R');
                END IF;
                CLOSE cur_wlst_prf_new;

              EXCEPTION
                WHEN OTHERS THEN
		  --Fnd log implementation
		  IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
		    fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
		    SUBSTRB('Unit Sec Waitlist Pref Id:'||wlst_prf_rec.unit_sec_waitlist_pref_id||'  '||
		    NVL(fnd_message.get,SQLERRM),1,4000));
		  END IF;
              END;
            END LOOP;

          EXCEPTION
            WHEN OTHERS THEN
	      --Fnd log implementation
	      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
		SUBSTRB('Unit Sec Wait Priority Id:'||wlst_pri_rec.unit_sec_waitlist_priority_id||'  '||
		NVL(fnd_message.get,SQLERRM),1,4000));
	      END IF;
          END;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('unit section limit wlst id:'||wlst_limit_rec.unit_section_limit_waitlist_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;
  END LOOP;

  -- Rollover of unit section credit points records
  FOR usec_cps_rec IN usec_cps(p_old_uoo_Id ) LOOP
    DECLARE
      CURSOR cur_usec_cps_new (cp_uoo_id   igs_ps_usec_cps.uoo_id%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_usec_cps
      WHERE  uoo_id = cp_uoo_id
      AND    ROWNUM = 1;
      l_cur_usec_cps_new   cur_usec_cps_new%ROWTYPE;

      lv_rowid VARCHAR2(25);
      l_usec_cps_id NUMBER;
    BEGIN

      OPEN cur_usec_cps_new(p_new_uoo_id);
      FETCH cur_usec_cps_new INTO l_cur_usec_cps_new;
      IF cur_usec_cps_new%NOTFOUND THEN
        igs_ps_usec_cps_pkg.insert_row(
          x_rowid                        => lv_rowid,
          x_unit_sec_credit_points_id    => l_usec_cps_id,
          x_uoo_id                       => p_new_uoo_id,
          x_minimum_credit_points        => usec_cps_rec.minimum_credit_points ,
          x_maximum_credit_points        => usec_cps_rec.maximum_credit_points ,
          x_variable_increment           => usec_cps_rec.variable_increment ,
          x_lecture_credit_points        => usec_cps_rec.lecture_credit_points ,
          x_lab_credit_points            => usec_cps_rec.lab_credit_points ,
          x_other_credit_points          => usec_cps_rec.other_credit_points ,
          x_clock_hours                  => usec_cps_rec.clock_hours ,
          x_work_load_cp_lecture         => usec_cps_rec.work_load_cp_lecture ,
          x_work_load_cp_lab             => usec_cps_rec.work_load_cp_lab ,
          x_continuing_education_units   => usec_cps_rec.continuing_education_units ,
          x_work_load_other              => usec_cps_rec.work_load_other,
          x_contact_hrs_lecture          => usec_cps_rec.contact_hrs_lecture ,
          x_contact_hrs_lab              => usec_cps_rec.contact_hrs_lab,
          x_contact_hrs_other            => usec_cps_rec.contact_hrs_other,
          x_non_schd_required_hrs        => usec_cps_rec.non_schd_required_hrs,
          x_exclude_from_max_cp_limit    => usec_cps_rec.exclude_from_max_cp_limit,
          x_mode                         => 'R',
          x_claimable_hours		 => usec_cps_rec.claimable_hours,
          x_achievable_credit_points     => usec_cps_rec.achievable_credit_points,
          x_enrolled_credit_points       => usec_cps_rec.enrolled_credit_points,
	  x_billing_credit_points        => usec_cps_rec.billing_credit_points,
          x_billing_hrs                  => usec_cps_rec.billing_hrs
          );
      END IF;
      CLOSE cur_usec_cps_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Sec Credit Points Id:'||usec_cps_rec.unit_sec_credit_points_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;
  END LOOP;

  -- Enhancement bug no 1800179, pmarada
  -- removed unit section cross listed units and unit section cross list unit sections
  -- added the unit section cross list group and unit section group member.
  -- Unit SECTION cross list GROUP
  DECLARE
    CURSOR cur_usec_x_grpmem_new (cp_uoo_id   igs_ps_usec_x_grpmem.uoo_id%TYPE) IS
    SELECT 'X'
    FROM   igs_ps_usec_x_grpmem
    WHERE  uoo_id = cp_uoo_id
    AND    ROWNUM = 1;
    l_cur_usec_x_grpmem_new   cur_usec_x_grpmem_new%ROWTYPE;

    lnusec_x_listed_group_mem_id  NUMBER;
    lv_GrpMemrowid                VARCHAR2(25);
    lnUsec_X_Grp_Id               NUMBER;
    usec_x_grp_rec                usec_x_grp%ROWTYPE;
    lvGRp_Row_ID                  VARCHAR2(25);
    --added var l_parent and its usage inside this block,bug#2563596
    l_parent                      VARCHAR2(1);
    -- See IF the GROUP name OF which the OLD unit SECTION IS a member already exists

  BEGIN
    FOR usec_x_grpmem_rec IN usec_x_grpmem(p_old_uoo_Id) LOOP
      OPEN usec_x_grp(usec_x_grpmem_rec.usec_x_listed_group_name, gv_new_usec_rec.cal_type, gv_new_usec_rec.ci_sequence_number);
      FETCH usec_x_grp INTO usec_x_grp_rec;

      IF  usec_x_grp%FOUND THEN
        lnUsec_X_Grp_Id := usec_x_grp_rec.usec_x_listed_group_id;
        CLOSE  usec_x_grp;
        l_parent:='N';

      ELSE
        CLOSE  usec_x_grp;
        igs_ps_usec_x_grp_pkg.insert_row (
        x_rowid                    => lvGRp_Row_ID,
        x_usec_x_listed_group_id   => lnUsec_X_Grp_Id,
        x_usec_x_listed_group_name => usec_x_grpmem_rec.usec_x_listed_group_name,
        x_location_inheritance     => usec_x_grpmem_rec.location_inheritance,
        x_cal_type                 => gv_new_usec_rec.cal_type,
        x_ci_sequence_number       => gv_new_usec_rec.ci_sequence_number,
        x_max_enr_group            => usec_x_grpmem_rec.max_enr_group,
        x_max_ovr_group            => usec_x_grpmem_rec.max_ovr_group,
        x_mode                     => 'R' );

        l_parent:='Y';
      END IF;

      OPEN cur_usec_x_grpmem_new(p_new_uoo_id);
      FETCH cur_usec_x_grpmem_new INTO l_cur_usec_x_grpmem_new;
      IF cur_usec_x_grpmem_new%NOTFOUND THEN
        -- Rollover of unit section in cross listed group
        igs_ps_usec_x_grpmem_pkg.insert_row (
          x_rowid                      => lv_GrpMemrowid,
          x_usec_x_listed_group_mem_id => lnusec_x_listed_group_mem_id,
          x_usec_x_listed_group_id     => lnUsec_X_Grp_Id,
          x_uoo_id                     => p_new_uoo_id,
          x_parent                     => l_parent,
          x_mode                       => 'R' );
      END IF;
      CLOSE cur_usec_x_grpmem_new;

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Section-CrossListed:'||p_old_uoo_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
  END;


  --Enhancement bug no 1800179, pmarada
  -- Rollover of unit section sponsorship records
  FOR usec_spn_rec IN usec_spn (p_old_uoo_Id ) LOOP
    DECLARE
      CURSOR cur_usec_spn_new (cp_uoo_id             igs_ps_usec_spnsrshp.uoo_id%TYPE,
                               cp_organization_code  igs_ps_usec_spnsrshp.organization_code%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_usec_spnsrshp
      WHERE  uoo_id = cp_uoo_id
      AND    organization_code = cp_organization_code
      AND    ROWNUM = 1;
      l_cur_usec_spn_new   cur_usec_spn_new%ROWTYPE;

      lv_rowid VARCHAR2(25);
      l_usec_spn_id NUMBER;
    BEGIN

      OPEN cur_usec_spn_new(p_new_uoo_id,usec_spn_rec.organization_code);
      FETCH cur_usec_spn_new INTO l_cur_usec_spn_new;
      IF cur_usec_spn_new%NOTFOUND THEN
        igs_ps_usec_spnsrshp_pkg.insert_row (
          x_rowid                       => lv_rowid,
          x_unit_section_sponsorship_id => l_usec_spn_id,
          x_uoo_id                      => p_new_uoo_id,
          x_organization_code           => usec_spn_rec.organization_code ,
          x_sponsorship_percentage      => usec_spn_rec.sponsorship_percentage  ,
          x_mode                        => 'R'
        );
      END IF;
      CLOSE cur_usec_spn_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Section Sponsorship Id:'||usec_spn_rec.unit_section_sponsorship_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
        END IF;
    END;
  END LOOP;


  -- Rollover of unit section teaching responsibility records
  FOR usec_tchr_rec IN usec_tchr(p_old_uoo_Id ) LOOP
    DECLARE
      CURSOR cur_usec_tchr_new (cp_uoo_id         igs_ps_usec_tch_resp.uoo_id%TYPE,
                                cp_instructor_id  igs_ps_usec_tch_resp.instructor_id%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_usec_tch_resp
      WHERE  uoo_id = cp_uoo_id
      AND    instructor_id = cp_instructor_id
      AND    ROWNUM = 1;
      l_cur_usec_tchr_new   cur_usec_tchr_new%ROWTYPE;

      CURSOR c_tch_ins(cp_uoo_id igs_ps_usec_occurs_all.uoo_id%TYPE,cp_ins_id igs_ps_uso_instrctrs.instructor_id%TYPE) IS
      SELECT 'X'
      FROM igs_ps_usec_occurs_all a,igs_ps_uso_instrctrs b
      WHERE a.UNIT_SECTION_OCCURRENCE_ID = b.UNIT_SECTION_OCCURRENCE_ID
      AND a.uoo_id = cp_uoo_id
      AND b.instructor_id= cp_ins_id;
      c_tch_ins_rec c_tch_ins%ROWTYPE;

      l_ins_exists BOOLEAN := TRUE;
      lv_rowid VARCHAR2(25);
      l_usec_tchr_id NUMBER;
    BEGIN

      OPEN c_tch_ins(p_new_uoo_id, usec_tchr_rec.instructor_id);
      FETCH c_tch_ins INTO c_tch_ins_rec;
      IF c_tch_ins%NOTFOUND THEN
        l_ins_exists := FALSE;
      END IF;
      CLOSE c_tch_ins;
      OPEN cur_usec_tchr_new(p_new_uoo_id, usec_tchr_rec.instructor_id);
      FETCH cur_usec_tchr_new INTO l_cur_usec_tchr_new;
      IF cur_usec_tchr_new%NOTFOUND AND l_ins_exists THEN
        igs_ps_usec_tch_resp_pkg.insert_row(
          x_rowid                      => lv_rowid,
          x_unit_section_teach_resp_id => l_usec_tchr_id,
          x_instructor_id              =>  usec_tchr_rec.instructor_id ,
          x_confirmed_flag             =>  usec_tchr_rec.confirmed_flag ,
          x_percentage_allocation      =>  usec_tchr_rec.percentage_allocation ,
          x_instructional_load         =>  usec_tchr_rec.instructional_load ,
          x_lead_instructor_flag       =>  usec_tchr_rec.lead_instructor_flag ,
          x_uoo_id                     => p_new_uoo_id,
          x_instructional_load_lab     => usec_tchr_rec.instructional_load_lab,
          x_instructional_load_lecture => usec_tchr_rec.instructional_load_lecture,
          x_mode                       => 'R'
        );
      END IF;
      CLOSE cur_usec_tchr_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('unit section teach resp id:'||usec_tchr_rec.unit_section_teach_resp_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
        END IF;
    END;
  END LOOP;

  -- Rollover of unit section assessment records
  FOR usec_as_rec IN usec_as (p_old_uoo_Id ) LOOP
    DECLARE
      CURSOR cur_usec_as_new (cp_uoo_id     igs_ps_usec_as.uoo_id%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_usec_as
      WHERE  uoo_id = cp_uoo_id
      AND    ROWNUM = 1;
      l_cur_usec_as_new   cur_usec_as_new%ROWTYPE;

      lv_rowid VARCHAR2(25);
      l_usec_ass_id NUMBER;
    BEGIN

      OPEN cur_usec_as_new(p_new_uoo_id);
      FETCH cur_usec_as_new INTO l_cur_usec_as_new;
      IF cur_usec_as_new%NOTFOUND THEN
        igs_ps_usec_as_pkg.insert_row(
          x_rowid                      => lv_rowid,
          x_unit_section_assessment_id => l_usec_ass_id,
          x_uoo_id                     => p_new_uoo_id,
          x_final_exam_date            => usec_as_rec.final_exam_date ,
          x_exam_start_time            => usec_as_rec.exam_start_time ,
          x_exam_end_time              => usec_as_rec.exam_end_time ,
          x_location_cd                => usec_as_rec.location_cd  ,
          x_building_code              => usec_as_rec.building_code ,
          x_room_code                  => usec_as_rec.room_code ,
          x_mode                       => 'R'
        );
      END IF;
      CLOSE cur_usec_as_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Section Assessment Id-Exam:'||usec_as_rec.unit_section_assessment_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
        END IF;
    END;
  END LOOP;

  --ijeddy, Grade Book Enh build, bug no 3201661, Dec 3, 2003.
  FOR usec_unitassgrp_rec IN usec_unitassgrp (p_old_uoo_id) LOOP
   DECLARE
    CURSOR cur_unitassgrp_new (cp_uoo_id     igs_as_us_ai_group.uoo_id%TYPE,
                               cp_group_name igs_as_us_ai_group.group_name%TYPE) IS
    SELECT us_ass_item_group_id
    FROM   igs_as_us_ai_group
    WHERE  uoo_id = cp_uoo_id
    AND    group_name = cp_group_name;
    l_rowid                       VARCHAR2(25);
    l_us_ass_item_group_id        NUMBER;
   BEGIN
    l_rowid := NULL;
    l_us_ass_item_group_id := NULL;
    OPEN cur_unitassgrp_new(p_new_uoo_id,usec_unitassgrp_rec.group_name);
    FETCH cur_unitassgrp_new INTO l_us_ass_item_group_id;
    IF cur_unitassgrp_new%NOTFOUND THEN
      igs_as_us_ai_group_pkg.insert_row (
      x_rowid                             => l_rowid,
      x_us_ass_item_group_id              => l_us_ass_item_group_id,
      x_uoo_id                            => p_new_uoo_id,
      x_group_name                        => usec_unitassgrp_rec.group_name,
      x_midterm_formula_code              => usec_unitassgrp_rec.midterm_formula_code,
      x_midterm_formula_qty               => usec_unitassgrp_rec.midterm_formula_qty,
      x_midterm_weight_qty                => usec_unitassgrp_rec.midterm_weight_qty,
      x_final_formula_code                => usec_unitassgrp_rec.final_formula_code,
      x_final_formula_qty                 => usec_unitassgrp_rec.final_formula_qty,
      x_final_weight_qty                  => usec_unitassgrp_rec.final_weight_qty,
      x_mode                              => 'R'
      );
    END IF;
    CLOSE cur_unitassgrp_new;

    -- Rollover of unit section assessment item records
    --Rollover asssessmnet items if there is none for the section and group combination
    OPEN cur_ass_item(p_new_uoo_id,l_us_ass_item_group_id);
    FETCH cur_ass_item INTO l_c_var;
    IF cur_ass_item%NOTFOUND THEN
      FOR usec_unitass_rec IN usec_unitass (p_old_uoo_Id,usec_unitassgrp_rec.us_ass_item_group_id ) LOOP
	DECLARE
	  lv_rowid VARCHAR2(25);
	  l_usec_assitem_id NUMBER;
	  l_sequence_number NUMBER;
	  l_ci_start_dt DATE;
	  l_ci_end_dt DATE;
	BEGIN
	    --  Modification of the procedure call is done by DDEY as a part of Bug #2162831
	    igs_ps_unitass_item_pkg.insert_row(
	      x_rowid                       => lv_rowid,
	      x_unit_section_ass_item_id    => l_usec_assitem_id,
	      x_uoo_id                      => p_new_uoo_id,
	      x_ass_id                      => usec_unitass_rec.ass_id ,
	      x_sequence_number             => l_sequence_number,
	      x_ci_start_dt                 => l_ci_start_dt,
	      x_ci_end_dt                   => l_ci_end_dt,
	      x_due_dt                      => usec_unitass_rec.due_dt ,
	      x_reference                   => usec_unitass_rec.reference     ,
	      x_dflt_item_ind               => usec_unitass_rec.dflt_item_ind  ,
	      x_logical_delete_dt           => usec_unitass_rec.logical_delete_dt ,
	      x_action_dt                   => usec_unitass_rec.action_dt  ,
	      x_exam_cal_type               => usec_unitass_rec.exam_cal_type ,
	      x_exam_ci_sequence_number     => usec_unitass_rec.exam_ci_sequence_number ,
	      x_mode                        => 'R'  ,
	      x_grading_schema_cd           => usec_unitass_rec.grading_schema_cd,
	      x_gs_version_number           => usec_unitass_rec.gs_version_number,
	      x_release_date                => usec_unitass_rec.release_date,
	      x_description                 => usec_unitass_rec.description,
	      x_us_ass_item_group_id        => l_us_ass_item_group_id,
	      x_midterm_mandatory_type_code => usec_unitass_rec.midterm_mandatory_type_code,
	      x_midterm_weight_qty          => usec_unitass_rec.midterm_weight_qty,
	      x_final_mandatory_type_code   => usec_unitass_rec.final_mandatory_type_code,
	      x_final_weight_qty            => usec_unitass_rec.final_weight_qty
	    );
	EXCEPTION
	  WHEN OTHERS THEN
	    --Fnd log implementation
	    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	      SUBSTRB('Unit Section Ass Item Id:'||usec_unitass_rec.unit_section_ass_item_id||'  '||
	      NVL(fnd_message.get,SQLERRM),1,4000));
	    END IF;
	END;
      END LOOP;
    END IF;
    CLOSE cur_ass_item;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Section Ass Item Group Id:'||usec_unitassgrp_rec.us_ass_item_group_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;

  END LOOP;

  -- Rollover of unit section reference records
  FOR usec_ref_rec IN usec_ref  (p_old_uoo_Id ) LOOP
    DECLARE
      CURSOR usec_reference ( p_uoo_id NUMBER) IS
      SELECT *
      FROM   igs_ps_usec_ref
      WHERE  uoo_id = p_uoo_id;
      l_usec_ref  usec_reference%ROWTYPE;
    BEGIN
      --added by sarakshi, bug#2332807
      --Unit section TBH automatically inserts in igs_ps_usec_ref and igs_ps_usec_ref_cd, so removed those inserts
      --only igs_ps_us_req_ref_cd insertion is required

      OPEN usec_reference(p_new_uoo_id);
      FETCH usec_reference INTO l_usec_ref;
      CLOSE usec_reference;

      --Added the following For loop as part of bug#2563596
      --The Unit section TBH automatically inserts in igs_ps_usec_ref ,but inserts into igs_ps_usec_ref_cd only
      --if the reference codes are of mandatory ref code types.Hence an explicit insert into igs_ps_usec_ref_cd
      --table has been added here for rolling over all unit section reference code records of old unit section
      --into the new unit section

      -- Rollover of unit section reference code records
      FOR  usec_refcd_rec IN usec_refcd (usec_ref_rec.unit_section_reference_id ) LOOP
        DECLARE
          CURSOR cur_usec_refcd_new (cp_unit_section_reference_id     igs_ps_usec_ref_cd.unit_section_reference_id%TYPE,
                                     cp_reference_code_type           igs_ps_usec_ref_cd.reference_code_type%TYPE,
                                     cp_reference_code                igs_ps_usec_ref_cd.reference_code%TYPE) IS
          SELECT 'X'
          FROM   igs_ps_usec_ref_cd
          WHERE  unit_section_reference_id = cp_unit_section_reference_id
          AND    reference_code_type = cp_reference_code_type
          AND    reference_code = cp_reference_code
          AND    ROWNUM = 1;
          l_cur_usec_refcd_new   cur_usec_refcd_new%ROWTYPE;

          lv_rowid VARCHAR2(25);
          l_unit_section_reference_cd_id NUMBER;
        BEGIN

          OPEN cur_usec_refcd_new(l_usec_ref.unit_section_reference_id, usec_refcd_rec.reference_code_type, usec_refcd_rec.reference_code);
          FETCH cur_usec_refcd_new INTO l_cur_usec_refcd_new;
          IF cur_usec_refcd_new%NOTFOUND THEN
            igs_ps_usec_ref_cd_pkg.insert_row (
              x_rowid                        => lv_rowid,
              x_unit_section_reference_cd_id => l_unit_section_reference_cd_id,
              x_unit_section_reference_id    => l_usec_ref.unit_section_reference_id,
              x_mode                         => 'R',
              x_reference_code_type          => usec_refcd_rec.reference_code_type,
              x_reference_code               => usec_refcd_rec.reference_code,
              x_reference_code_desc          => usec_refcd_rec.reference_code_desc
            );
          END IF;
          CLOSE cur_usec_refcd_new;

        EXCEPTION
          WHEN OTHERS THEN
	    --Fnd log implementation
	    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	      SUBSTRB('Unit Section Reference Id:'||usec_refcd_rec.unit_section_reference_id||'  '||'Reference Code Type:'||usec_refcd_rec.reference_code_type||'  '||'Reference Code:'||usec_refcd_rec.reference_code||'  '||
	      NVL(fnd_message.get,SQLERRM),1,4000));
	    END IF;
        END;
      END LOOP;

      --Enhancement bug no 1800179 , pmarada
      -- Rollover of unit section requirement reference code records
      FOR  us_req_refcd_rec IN us_req_refcd (usec_ref_rec.unit_section_reference_id ) LOOP
        DECLARE
          CURSOR cur_us_req_refcd_new (cp_unit_section_reference_id     igs_ps_us_req_ref_cd.unit_section_reference_id%TYPE,
                                       cp_reference_cd_type             igs_ps_us_req_ref_cd.reference_cd_type%TYPE,
                                       cp_reference_code                igs_ps_us_req_ref_cd.reference_code%TYPE) IS
          SELECT 'X'
          FROM   igs_ps_us_req_ref_cd
          WHERE  unit_section_reference_id = cp_unit_section_reference_id
          AND    reference_cd_type = cp_reference_cd_type
          AND    reference_code = cp_reference_code
          AND    ROWNUM = 1;
          l_cur_us_req_refcd_new   cur_us_req_refcd_new%ROWTYPE;

          lv_rowid VARCHAR2(25);
          l_unit_section_req_ref_cd_id NUMBER;
        BEGIN

          OPEN cur_us_req_refcd_new(l_usec_ref.unit_section_reference_id,us_req_refcd_rec.reference_cd_type, us_req_refcd_rec.reference_code);
          FETCH cur_us_req_refcd_new INTO l_cur_us_req_refcd_new;
          IF cur_us_req_refcd_new%NOTFOUND THEN
            igs_ps_us_req_ref_cd_pkg.insert_row (
              x_rowid                      => lv_rowid,
              x_unit_section_req_ref_cd_id => l_unit_section_req_ref_cd_id,
              x_unit_section_reference_id  => l_usec_ref.unit_section_reference_id,
              x_reference_cd_type          => us_req_refcd_rec.reference_cd_type,
              x_mode                       => 'R',
              x_reference_code             => us_req_refcd_rec.reference_code,
              x_reference_code_desc        => us_req_refcd_rec.reference_code_desc
            );
          END IF;
          CLOSE cur_us_req_refcd_new;

        EXCEPTION
          WHEN OTHERS THEN
	    --Fnd log implementation
	    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	      SUBSTRB('Unit Section Reference Id:'||us_req_refcd_rec.unit_section_reference_id||'  '||'Reference Cd Type:'||us_req_refcd_rec.reference_cd_type||'  '||'Reference Cd:'||us_req_refcd_rec.reference_code||'  '||
	      NVL(fnd_message.get,SQLERRM),1,4000));
	    END IF;
        END;
      END LOOP;

    END;
  END LOOP;

  -- Rollover of unit section grading schema records
  FOR usec_grdsch_rec IN usec_grdsch  (p_old_uoo_Id )LOOP
    DECLARE
      CURSOR cur_usec_grdsch_new (cp_uoo_id                  igs_ps_usec_grd_schm.uoo_id%TYPE,
                                  cp_grading_schema_code     igs_ps_usec_grd_schm.grading_schema_code%TYPE,
                                  cp_grd_schm_version_number igs_ps_usec_grd_schm.grd_schm_version_number%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_usec_grd_schm
      WHERE  uoo_id = cp_uoo_id
      AND    grading_schema_code = cp_grading_schema_code
      AND    grd_schm_version_number = cp_grd_schm_version_number
      AND    ROWNUM = 1;
      l_cur_usec_grdsch_new   cur_usec_grdsch_new%ROWTYPE;

      CURSOR cur_usec_gs_df(cp_uoo_id         igs_ps_usec_grd_schm.uoo_id%TYPE) IS
      SELECT grading_schema_code,grd_schm_version_number
      FROM  igs_ps_usec_grd_schm
      WHERE uoo_id =  cp_uoo_id
      AND default_flag = 'Y';
      cur_usec_gs_df_rec cur_usec_gs_df%ROWTYPE;

      l_default_flag BOOLEAN := TRUE;
      lv_rowid VARCHAR2(25);
      l_usec_grdsch_id NUMBER;
    BEGIN

      OPEN cur_usec_gs_df(p_new_uoo_id);
      FETCH cur_usec_gs_df INTO cur_usec_gs_df_rec;
      IF cur_usec_gs_df%FOUND AND usec_grdsch_rec.default_flag ='Y' THEN
	l_default_flag := FALSE;
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.IGS_PS_GEN_001.crsp_ins_unit_section.usec_grading_schema_not_rolled_over_one_default_already_in_destination_unit_section',
	  'Not rolling over Default Grading Schema code'||usec_grdsch_rec.grading_schema_code||'  '||
	  'version number:'||usec_grdsch_rec.grd_schm_version_number||'  '||'from Source UOO'||p_old_uoo_Id||'  '||
	  'to Destination UOO:'||p_new_uoo_id||'  '||'as there already exists a different Default Grading Schema code'||cur_usec_gs_df_rec.grading_schema_code||'  '||
	  'version number'||cur_usec_gs_df_rec.grd_schm_version_number||'  '||'in the destination');
	END IF;
      END IF;
      CLOSE cur_usec_gs_df;
      OPEN cur_usec_grdsch_new(p_new_uoo_id,usec_grdsch_rec.grading_schema_code,usec_grdsch_rec.grd_schm_version_number );
      FETCH cur_usec_grdsch_new INTO l_cur_usec_grdsch_new;
      IF cur_usec_grdsch_new%NOTFOUND AND l_default_flag THEN
        igs_ps_usec_grd_schm_pkg.insert_row(
          x_rowid                       => lv_rowid,
          x_unit_section_grad_schema_id => l_usec_grdsch_id,
          x_uoo_id                      => p_new_uoo_id,
          x_grading_schema_code         => usec_grdsch_rec.grading_schema_code  ,
          x_grd_schm_version_number     => usec_grdsch_rec.grd_schm_version_number ,
          x_default_flag                => usec_grdsch_rec.default_flag ,
          x_mode                        => 'R'
        );
      END IF;
      CLOSE cur_usec_grdsch_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Section Grad Schema Id:'||usec_grdsch_rec.unit_section_grading_schema_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;
  END LOOP;

  -- Enhancement bug no 1800179 , pmarada
  -- Rollover of unit section note records
  FOR c_unt_ofr_opt_n_rec IN c_unt_ofr_opt_n( p_old_uoo_id ) LOOP
    DECLARE
      CURSOR cur_c_unt_ofr_opt_n_new (cp_uoo_id            igs_ps_unt_ofr_opt_n.uoo_id%TYPE,
                                      cp_crs_note_type     igs_ps_unt_ofr_opt_n.crs_note_type%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_unt_ofr_opt_n
      WHERE  uoo_id = cp_uoo_id
      AND    crs_note_type = cp_crs_note_type
      AND    ROWNUM = 1;
      l_cur_c_unt_ofr_opt_n_new   cur_c_unt_ofr_opt_n_new%ROWTYPE;

      lv_usrowid VARCHAR2(25);
      lv_gerowid VARCHAR2(25);
      lnnote_ref_number NUMBER;
    BEGIN

      OPEN cur_c_unt_ofr_opt_n_new(p_new_uoo_id, c_unt_ofr_opt_n_rec.crs_note_type);
      FETCH cur_c_unt_ofr_opt_n_new INTO l_cur_c_unt_ofr_opt_n_new;
      IF cur_c_unt_ofr_opt_n_new%NOTFOUND THEN
        --insert a record in the igs_ge_note table corresponding to the reference number create
        -- for unit section note.

        SELECT IGS_GE_NOTE_RF_NUM_S.NEXTVAL INTO lnnote_ref_number  FROM dual;

        igs_ge_note_pkg.insert_row(
          x_rowid              => lv_gerowid,
          x_reference_number   => lnnote_ref_number  ,
          x_s_note_format_type => c_unt_ofr_opt_n_rec.s_note_format_type,
          x_note_text          => c_unt_ofr_opt_n_rec.Note_text,
          x_mode               => 'R' );

        igs_ps_unt_ofr_opt_n_pkg.insert_row(
          x_rowid              => lv_usrowid,
          x_unit_cd            => gv_new_usec_rec.unit_cd,
          x_version_number     => gv_new_usec_rec.version_number,
          x_ci_sequence_number => gv_new_usec_rec.ci_sequence_number,
          x_unit_class         => gv_new_usec_rec.unit_class,
          x_reference_number   => lnnote_ref_number,
          x_location_cd        => gv_new_usec_rec.location_cd,
          x_cal_type           => gv_new_usec_rec.cal_type,
          x_uoo_id             => gv_new_usec_rec.uoo_id,
          x_crs_note_type      => c_unt_ofr_opt_n_rec.crs_note_type,
          x_mode               =>'R' );
      END IF;
      CLOSE cur_c_unt_ofr_opt_n_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Crs Note Type:'||c_unt_ofr_opt_n_rec.crs_note_type||'  '||'Unit Section:'||p_old_uoo_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;
  END LOOP;

  -- Rollover of unit section rule records
  FOR  usec_pre_co_req_rule_rec IN usec_pre_co_req_rule (p_old_uoo_id ) LOOP
    DECLARE
      CURSOR cur_usec_pre_co_req_rule_new (cp_uoo_id             igs_ps_usec_ru.uoo_id%TYPE,
                                           cp_s_rule_call_cd     igs_ps_usec_ru.s_rule_call_cd%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_usec_ru
      WHERE  uoo_id = cp_uoo_id
      AND    s_rule_call_cd = cp_s_rule_call_cd
      AND    ROWNUM = 1;
      l_cur_usec_pre_co_req_rule_new   cur_usec_pre_co_req_rule_new%ROWTYPE;

      lv_rowid VARCHAR2(25);
      l_usecru_id NUMBER;
      lv_rule_unprocessed VARCHAR2(4500);
      ln_rule_number igs_ps_usec_ru.rul_sequence_number%TYPE;
      ln_lov_number NUMBER;
      x BOOLEAN;
    BEGIN

      OPEN cur_usec_pre_co_req_rule_new(p_new_uoo_id,usec_pre_co_req_rule_rec.s_rule_call_cd);
      FETCH cur_usec_pre_co_req_rule_new INTO l_cur_usec_pre_co_req_rule_new;
      IF cur_usec_pre_co_req_rule_new%NOTFOUND THEN
        -- CREATE the relevant data IN rule SCHEMA TABLE AND returns the rule SEQUENCE NUMBER
        -- TO be used FOR the rule created FOR NEW unit section.

        lv_rule_unprocessed := NULL;
        ln_lov_number := NULL;
        -- As part of bug fix bug#2563596
        -- Modified the values being passed to the parameters in call to igs_ru_gen_002.rulp_ins_parser
        -- Passing value usec_pre_co_req_rule_rec.rule_text to parameter p_rule_processed instead of
        -- local variable lv_rule_processed.


        x := igs_ru_gen_002.rulp_ins_parser (
          p_group            => usec_pre_co_req_rule_rec.select_group,
          p_return_type      => usec_pre_co_req_rule_rec.s_return_type,
          p_rule_description => usec_pre_co_req_rule_rec.rule_description,
          p_rule_processed   => usec_pre_co_req_rule_rec.rule_text,
          p_rule_unprocessed => lv_rule_unprocessed,
          p_generate_rule    => TRUE,
          p_rule_number      => ln_rule_number,
          p_lov_number       => ln_lov_number );


        -- USE the returned SEQUENCE NUMBER FOR inserting the NEW RECORD FOR the
        -- NEW Unit section.

        -- As part of bug fix bug#2563596
        -- Added an IF condition that checks if the function igs_ru_gen_002.rulp_ins_parser
        -- returns a TRUE or FALSE.Only if it returns TRUE then insert into igs_ps_usec_ru

        IF x THEN
          igs_ps_usec_ru_pkg.insert_row (
            x_rowid               => lv_rowid,
            x_usecru_id           => l_usecru_id,
            x_uoo_id              => p_new_uoo_id,
            x_s_rule_call_cd      => usec_pre_co_req_rule_rec.s_rule_call_cd,
            x_rul_sequence_number => ln_rule_number,
            x_mode                => 'R' );
        END IF;
      END IF;
      CLOSE cur_usec_pre_co_req_rule_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('S Rule Call Cd:'||usec_pre_co_req_rule_rec.s_rule_call_cd||'  '||'Unit Section:'||p_old_uoo_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;
  END LOOP;

  -- Rollover of unit section categories record
  FOR usec_cat_rec IN usec_cat (p_old_uoo_id ) LOOP
    DECLARE
      CURSOR cur_usec_cat_new (cp_uoo_id             igs_ps_usec_category.uoo_id%TYPE,
                               cp_unit_cat           igs_ps_usec_category.unit_cat%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_usec_category
      WHERE  uoo_id = cp_uoo_id
      AND    unit_cat = cp_unit_cat
      AND    ROWNUM = 1;
      l_cur_usec_cat_new   cur_usec_cat_new%ROWTYPE;

      lv_rowid VARCHAR2(25);
      l_usec_cat_id NUMBER;
    BEGIN

      OPEN cur_usec_cat_new(p_new_uoo_id,usec_cat_rec.unit_cat);
      FETCH cur_usec_cat_new INTO l_cur_usec_cat_new;
      IF cur_usec_cat_new%NOTFOUND THEN
        igs_ps_usec_category_pkg.insert_row (
          x_rowid       => lv_rowid,
          x_usec_cat_id => l_usec_cat_id,
          x_uoo_id      => p_new_uoo_id,
          x_unit_cat    => usec_cat_rec.unit_cat,
          x_mode        => 'R' );
      END IF;
      CLOSE cur_usec_cat_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('unit Cat:'||usec_cat_rec.unit_cat||'  '||'Unit Section:'||p_old_uoo_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;
  END LOOP;

  -- Rollover of unit section plus hour records
  FOR usec_plushr_rec IN usec_plushr (p_old_uoo_id ) LOOP
    DECLARE
      CURSOR cur_usec_plushr_new (cp_uoo_id             igs_ps_us_unsched_cl.uoo_id%TYPE,
                                  cp_activity_type_id   igs_ps_us_unsched_cl.activity_type_id%TYPE,
                                  cp_location_cd        igs_ps_us_unsched_cl.location_cd%TYPE,
                                  cp_building_id        igs_ps_us_unsched_cl.building_id%TYPE,
                                  cp_room_id            igs_ps_us_unsched_cl.room_id%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_us_unsched_cl
      WHERE  uoo_id = cp_uoo_id
      AND    activity_type_id = cp_activity_type_id
      AND    location_cd = cp_location_cd
      AND    building_id = cp_building_id
      AND    room_id = cp_room_id
      AND    ROWNUM = 1;
      l_cur_usec_plushr_new   cur_usec_plushr_new%ROWTYPE;

      lv_rowid VARCHAR2(25);
      l_us_unscheduled_cl_id NUMBER;
    BEGIN

      OPEN cur_usec_plushr_new(p_new_uoo_id,usec_plushr_rec.activity_type_id,usec_plushr_rec.location_cd,usec_plushr_rec.building_id,usec_plushr_rec.room_id);
      FETCH cur_usec_plushr_new INTO l_cur_usec_plushr_new;
      IF cur_usec_plushr_new%NOTFOUND THEN
        igs_ps_us_unsched_cl_pkg.insert_row (
          x_rowid                => lv_rowid,
          x_us_unscheduled_cl_id => l_us_unscheduled_cl_id,
          x_uoo_id               => p_new_uoo_id,
          x_activity_type_id     => usec_plushr_rec.activity_type_id,
          x_location_cd          => usec_plushr_rec.location_cd,
          x_building_id          => usec_plushr_rec.building_id,
          x_room_id              => usec_plushr_rec.room_id,
          x_number_of_students   => usec_plushr_rec.number_of_students,
          x_hours_per_student    => usec_plushr_rec.hours_per_student,
          x_hours_per_faculty    => usec_plushr_rec.hours_per_faculty,
          x_instructor_id        => usec_plushr_rec.instructor_id,
          x_mode                 => 'R' );
      END IF;
      CLOSE cur_usec_plushr_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Us Unscheduled Cl Id:'||usec_plushr_rec.us_unscheduled_cl_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;
  END LOOP;


  -- Rollover of unit section teaching responsibility override records
  FOR usec_tro_rec IN usec_tro (p_old_uoo_id ) LOOP
    DECLARE
      cst_active        CONSTANT        VARCHAR2(6) := 'ACTIVE';
      l_ou_exists                       VARCHAR2(1);
      l_rowid                           VARCHAR2(25);

      CURSOR cur_usec_tro_new (cp_unit_cd               igs_ps_tch_resp_ovrd.unit_cd%TYPE,
                               cp_version_number        igs_ps_tch_resp_ovrd.version_number%TYPE,
                               cp_cal_type              igs_ps_tch_resp_ovrd.cal_type%TYPE,
                               cp_ci_sequence_number    igs_ps_tch_resp_ovrd.ci_sequence_number%TYPE,
                               cp_location_cd           igs_ps_tch_resp_ovrd.location_cd%TYPE,
                               cp_unit_class            igs_ps_tch_resp_ovrd.unit_class%TYPE,
                               cp_org_unit_cd           igs_ps_tch_resp_ovrd.org_unit_cd%TYPE,
                               cp_ou_start_dt           igs_ps_tch_resp_ovrd.ou_start_dt%TYPE) IS
      SELECT 'X'
      FROM   igs_ps_tch_resp_ovrd
      WHERE  unit_cd = cp_unit_cd
      AND    version_number = cp_version_number
      AND    cal_type = cp_cal_type
      AND    ci_sequence_number = cp_ci_sequence_number
      AND    location_cd = cp_location_cd
      AND    unit_class = cp_unit_class
      AND    org_unit_cd = cp_org_unit_cd
      AND    ou_start_dt = cp_ou_start_dt
      AND    ROWNUM = 1;
      l_cur_usec_tro_new   cur_usec_tro_new%ROWTYPE;


      CURSOR    c_ou( cp_org_unit_cd          igs_or_unit.org_unit_cd%TYPE,
                      cp_start_dt             igs_or_unit.start_dt%TYPE) IS
      SELECT    'x'
      FROM      igs_or_inst_org_base_v  ou,
                igs_or_status   os
      WHERE     ou.party_number  = cp_org_unit_cd
      AND       ou.start_dt      = cp_start_dt
      AND       os.org_status   = ou.org_status
      AND       os.s_org_status = cst_active;

      l_org_id                        NUMBER(15);

    BEGIN

      OPEN cur_usec_tro_new(gv_new_usec_rec.unit_cd,gv_new_usec_rec.version_number,gv_new_usec_rec.cal_type,
                            gv_new_usec_rec.ci_sequence_number,gv_new_usec_rec.location_cd,gv_new_usec_rec.unit_class,
                            usec_tro_rec.org_unit_cd, usec_tro_rec.ou_start_dt );
      FETCH cur_usec_tro_new INTO l_cur_usec_tro_new;
      IF cur_usec_tro_new%NOTFOUND THEN

        -- Validate the status of the org IGS_PS_UNIT.
        -- If the org IGS_PS_UNIT code is not 'ACTIVE' then do not perform the insert else perform the insert

        OPEN c_ou( usec_tro_rec.org_unit_cd,
                   usec_tro_rec.ou_start_dt);
        FETCH c_ou INTO l_ou_exists;
        IF c_ou%FOUND THEN
          l_org_id := igs_ge_gen_003.get_org_id;

          igs_ps_tch_resp_ovrd_pkg.insert_row(
            x_rowid                 =>   l_rowid,
            x_unit_cd               =>   gv_new_usec_rec.unit_cd,
            x_version_number        =>   gv_new_usec_rec.version_number,
            x_cal_type              =>   gv_new_usec_rec.cal_type,
            x_ci_sequence_number    =>   gv_new_usec_rec.ci_sequence_number,
            x_location_cd           =>   gv_new_usec_rec.location_cd,
            x_unit_class            =>   gv_new_usec_rec.unit_class,
            x_ou_start_dt           =>   usec_tro_rec.ou_start_dt,
            x_org_unit_cd           =>   usec_tro_rec.org_unit_cd,
            x_uoo_id                =>   p_new_uoo_id,
            x_percentage            =>   usec_tro_rec.percentage,
            x_mode                  =>   'R',
            x_org_id                =>   l_org_id);
        END IF;
        CLOSE c_ou;
      END IF;
      CLOSE cur_usec_tro_new;

    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Org Unit Cd:'||usec_tro_rec.org_unit_cd||'  '||'Unit Section:'||p_old_uoo_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
    END;
  END LOOP;


  --Create a pl-sql table which will hold the ftci calendar instances for the new teaching calendar instances.
  l_n_counter :=1;
  FOR cur_ftci_rec IN cur_ftci(gv_new_usec_rec.cal_type,gv_new_usec_rec.ci_sequence_number) LOOP
      teachCalendar_tbl(l_n_counter).cal_type :=cur_ftci_rec.cal_type;
      teachCalendar_tbl(l_n_counter).sequence_number :=cur_ftci_rec.sequence_number;
      l_n_counter:=l_n_counter+1;
  END LOOP;

  -- Rollover of unit section special fees records
  IF teachCalendar_tbl.EXISTS(1) THEN
    FOR usec_spl_fees_rec IN c_usec_spl_fees (p_old_uoo_id ) LOOP
      DECLARE
	CURSOR cur_usec_spl_fees_new(cp_n_uoo_id    igs_ps_usec_sp_fees.uoo_id%TYPE,
				     cp_c_fee_type  igs_ps_usec_sp_fees.fee_type%TYPE) IS
	SELECT 'x'
	FROM   igs_ps_usec_sp_fees
	WHERE  uoo_id = cp_n_uoo_id
	AND    fee_type = cp_c_fee_type
	AND    ROWNUM = 1;
	l_cur_usec_spl_fees_new   cur_usec_spl_fees_new%ROWTYPE;

	CURSOR c_fee_type_exists(cp_source_fee_type      igs_fi_fee_type.fee_type%TYPE) IS
	SELECT ci.cal_type,ci.sequence_number
	FROM  igs_fi_fee_type ft,
	      igs_fi_f_typ_ca_inst ftci,
	      igs_ca_inst ci,
	      igs_ca_type ct,
	      igs_ca_stat cs
	WHERE ft.s_fee_type = 'SPECIAL'
	AND   ft.closed_ind = 'N'
	AND   ft.fee_type = ftci.fee_type
	AND   ft.fee_type = cp_source_fee_type
	AND   ftci.fee_cal_type = ci.cal_type
	AND   ftci.fee_ci_sequence_number = ci.sequence_number
	AND   ci.cal_type = ct.cal_type
	AND   ct.s_cal_cat = 'FEE'
	AND   ci.cal_status = cs.cal_status
	AND   cs.s_cal_status = 'ACTIVE' ;

	lv_rowid           VARCHAR2(25);
	l_usec_sp_fees_id  NUMBER;
	l_c_var            VARCHAR2(1);
      BEGIN

	OPEN cur_usec_spl_fees_new(p_new_uoo_id,usec_spl_fees_rec.fee_type);
	FETCH cur_usec_spl_fees_new INTO l_cur_usec_spl_fees_new;
	IF cur_usec_spl_fees_new%NOTFOUND THEN
 	  l_c_proceed:= FALSE;
	  FOR  c_fee_type_exists_rec IN c_fee_type_exists(usec_spl_fees_rec.fee_type) LOOP

	     FOR i IN 1..teachCalendar_tbl.last LOOP
	       IF c_fee_type_exists_rec.cal_type=teachCalendar_tbl(i).cal_type AND
		  c_fee_type_exists_rec.sequence_number=teachCalendar_tbl(i).sequence_number THEN
		  l_c_proceed:= TRUE;
		  EXIT;
	       END IF;
	     END LOOP;
	     IF l_c_proceed THEN
	       EXIT;
             END IF;

	  END LOOP;

	  IF l_c_proceed THEN
	    igs_ps_usec_sp_fees_pkg.insert_row (
	      x_rowid            => lv_rowid,
	      x_usec_sp_fees_id  => l_usec_sp_fees_id,
	      x_uoo_id           => p_new_uoo_id,
	      x_fee_type         => usec_spl_fees_rec.fee_type,
	      x_sp_fee_amt       => usec_spl_fees_rec.sp_fee_amt,
	      x_closed_flag      => usec_spl_fees_rec.closed_flag,
	      x_mode             => 'R' );
	  END IF;
	END IF;
	CLOSE cur_usec_spl_fees_new;

      EXCEPTION
	WHEN OTHERS THEN
	  --Fnd log implementation
	  IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	    SUBSTRB('Fee Type-Special Fees:'||usec_spl_fees_rec.fee_type||'  '||'Unit Section:'||p_old_uoo_id||'  '||
	    NVL(fnd_message.get,SQLERRM),1,4000));
	  END IF;
      END;
    END LOOP;

  END IF;

  IF gv_new_usec_rec.non_std_usec_ind = 'Y' THEN
    --Rollover of unit section retention
    FOR c_rtn_us_rec IN c_rtn_us LOOP
      DECLARE
        CURSOR c_rtn_us_new(cp_uoo_id   igs_ps_nsus_rtn.uoo_id%TYPE,
                            cp_fee_type igs_ps_nsus_rtn.fee_type%TYPE) IS
        SELECT non_std_usec_rtn_id
        FROM   igs_ps_nsus_rtn
        WHERE  uoo_id = cp_uoo_id
        AND    fee_type = cp_fee_type;

        CURSOR c_rtn_us_new_1(cp_uoo_id   igs_ps_nsus_rtn.uoo_id%TYPE) IS
        SELECT non_std_usec_rtn_id
        FROM   igs_ps_nsus_rtn
        WHERE  uoo_id = cp_uoo_id
        AND    definition_code ='UNIT_SECTION';


        lv_rowid                 VARCHAR2(25);
        l_non_std_usec_rtn_id    igs_ps_nsus_rtn.non_std_usec_rtn_id%TYPE;
        l_b_fee_exists           BOOLEAN ;
        l_c_var                  VARCHAR2(1);
      BEGIN
        l_b_fee_exists := TRUE;
        IF c_rtn_us_rec.fee_type IS NOT NULL THEN

 	  l_c_proceed:= FALSE;
	  FOR  c_fee_type_cal_exists_rec IN c_fee_type_cal_exists(c_rtn_us_rec.fee_type) LOOP

	     FOR i IN 1..teachCalendar_tbl.last LOOP
	       IF c_fee_type_cal_exists_rec.cal_type=teachCalendar_tbl(i).cal_type AND
		  c_fee_type_cal_exists_rec.sequence_number=teachCalendar_tbl(i).sequence_number THEN
		  l_c_proceed:= TRUE;
		  EXIT;
	       END IF;
	     END LOOP;
	     IF l_c_proceed THEN
	       EXIT;
             END IF;

	  END LOOP;

	  IF l_c_proceed = FALSE THEN
             l_b_fee_exists := FALSE;
	  END IF;

        END IF;

        IF l_b_fee_exists THEN

          IF c_rtn_us_rec.definition_code = 'UNIT_SECTION_FEE_TYPE' THEN
            OPEN c_rtn_us_new(p_new_uoo_id,c_rtn_us_rec.fee_type);
            FETCH c_rtn_us_new INTO l_non_std_usec_rtn_id;
	    IF c_rtn_us_new%NOTFOUND THEN
              l_non_std_usec_rtn_id := NULL;
	    END IF;
	    CLOSE c_rtn_us_new;
          ELSIF c_rtn_us_rec.definition_code = 'UNIT_SECTION' THEN
            OPEN c_rtn_us_new_1(p_new_uoo_id);
            FETCH c_rtn_us_new_1 INTO l_non_std_usec_rtn_id;
	    IF c_rtn_us_new_1%NOTFOUND THEN
              l_non_std_usec_rtn_id := NULL;
	    END IF;
	    CLOSE c_rtn_us_new_1;
	  END IF;

          IF l_non_std_usec_rtn_id IS NULL THEN

            igs_ps_nsus_rtn_pkg.insert_row(
            x_rowid                      => lv_rowid,
            x_non_std_usec_rtn_id        => l_non_std_usec_rtn_id,
            x_uoo_id                     => p_new_uoo_id,
            x_fee_type                   => c_rtn_us_rec.fee_type,
            x_definition_code            => c_rtn_us_rec.definition_code,
            x_formula_method             => c_rtn_us_rec.formula_method,
            x_round_method               => c_rtn_us_rec.round_method,
            x_incl_wkend_duration_flag   => c_rtn_us_rec.incl_wkend_duration_flag,
            x_mode                       => 'R'
            );
          END IF;

          FOR c_rtn_us_dtl_rec IN c_rtn_us_dtl (c_rtn_us_rec.non_std_usec_rtn_id) LOOP
            DECLARE
              CURSOR c_rtn_us_dtl_new(cp_non_std_usec_rtn_id   igs_ps_nsus_rtn_dtl.non_std_usec_rtn_id%TYPE,
                                      cp_offset_value          igs_ps_nsus_rtn_dtl.offset_value%TYPE) IS
              SELECT 'X'
              FROM   igs_ps_nsus_rtn_dtl
              WHERE  non_std_usec_rtn_id = cp_non_std_usec_rtn_id
              AND    offset_value = cp_offset_value;

  	      l_c_var                     VARCHAR2(1);
              lv_rowid                    VARCHAR2(25);
              l_non_std_usec_rtn_dtl_id   igs_ps_nsus_rtn_dtl.non_std_usec_rtn_dtl_id%TYPE;
	      l_offset_date               DATE;
	    BEGIN
              OPEN c_rtn_us_new(l_non_std_usec_rtn_id,c_rtn_us_dtl_rec.offset_value);
              FETCH c_rtn_us_new INTO l_c_var;
              IF c_rtn_us_new%NOTFOUND THEN

  	        l_offset_date := igs_ps_gen_004.f_retention_offset_date(
	                                      p_n_uoo_id                   => p_new_uoo_id,
	                                      p_c_formula_method           => c_rtn_us_rec.formula_method,
	  	                              p_c_round_method             => c_rtn_us_rec.round_method,
		                              p_c_incl_wkend_duration      => c_rtn_us_rec.incl_wkend_duration_flag,
			                      p_n_offset_value             => c_rtn_us_dtl_rec.offset_value);

    	        igs_ps_nsus_rtn_dtl_pkg.insert_row(
	          x_rowid                      => lv_rowid,
	          x_non_std_usec_rtn_dtl_id    => l_non_std_usec_rtn_dtl_id,
	          x_non_std_usec_rtn_id        => l_non_std_usec_rtn_id,
	          x_offset_value               => c_rtn_us_dtl_rec.offset_value,
	          x_retention_percent          => c_rtn_us_dtl_rec.retention_percent,
	          x_retention_amount           => c_rtn_us_dtl_rec.retention_amount,
	          x_offset_date                => l_offset_date,
	          x_override_date_flag         => 'N',  -- calculating the dates while rolling over. So if in the source if it is overriden here it is calculated, to keep the data in the correct calendar.
	          x_mode                       => 'R'
	          );
              END IF;
              CLOSE c_rtn_us_new;

            EXCEPTION
  	       WHEN OTHERS THEN
		--Fnd log implementation
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
		  SUBSTRB('Non Std Usec Rtn Dtl Id:'||c_rtn_us_dtl_rec.non_std_usec_rtn_dtl_id||'  '||
		  NVL(fnd_message.get,SQLERRM),1,4000));
		END IF;
	    END;
          END LOOP;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
	  --Fnd log implementation
	  IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_001.crsp_ins_unit_section.in_exception_section_OTHERS.err_msg',
	    SUBSTRB('Non Std Usec Rtn Id:'||c_rtn_us_rec.non_std_usec_rtn_id||'  '||
	    NVL(fnd_message.get,SQLERRM),1,4000));
	  END IF;
      END;
    END LOOP;
  END IF;

  IF teachCalendar_tbl.EXISTS(1) THEN
      teachCalendar_tbl.DELETE;
   END IF;

  --SUCCESSFUL condition.
  p_message_name := 'IGS_PS_USEC_DUP_TRN_SUCC';

END crsp_ins_unit_section;


PROCEDURE change_unit_section_status(p_c_old_cal_status      IN  VARCHAR2,
                                     p_c_new_cal_status      IN  VARCHAR2,
                                     p_c_cal_type            IN  VARCHAR2,
                                     p_n_ci_sequence_number  IN  NUMBER,
                                     p_b_ret_status          OUT NOCOPY BOOLEAN,
                                     p_c_message_name        OUT NOCOPY VARCHAR2) IS
   /*
        ||  Created By : sarakshi
        ||  Created On : 24-Apr-2003
        ||  Purpose:Updates unit section status to 'Not Offered' if the calendar status is changes to INACTIVE
        ||          for those unit section of the calendar instance which are not having any enrollment
        ||          activity,also changes the status to OPEN when calendar status is updated from INACTIVE
        ||          to ACTIVE.This procedure returns status(p_b_ret_status), if this is false then p_c_message
        ||          _name will contain the error message name which needs to be shown to the calling env and
        ||          process needs to be stopped.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        ||  sarakshi    21-oct-2003     Enh#3052452,used function igs_ps_gen_003.enrollment_for_uoo_check for checking the
        ||                              existance of record in igs_en_su_attempt rather than explicitly coding a cursor locally.
	||  sarakshi    18-sep-2003     Enh#3052452, added new parameters relation_type,sup_uoo_id,default_enroll_flag to the
	||                              call of igs_ps_unit_ofr_opt_pkg.update_row .
	||  vvutukur    04-Aug-2003     Enh#3045069.PSP Enh Build.Modified the calls to igs_ps_unit_ofr_opt_pkg.update_row to add
	||                              new parameter not_multiple_section_flag.
        */

  CURSOR c_uoo_id IS
  SELECT usec.* ,usec.rowid
  FROM igs_ps_unit_ofr_opt_all usec
  WHERE cal_type=p_c_cal_type
  AND ci_sequence_number=p_n_ci_sequence_number;

  l_b_found BOOLEAN := FALSE;
BEGIN
  p_c_message_name:=NULL;
  p_b_ret_status:=TRUE;

  --If old calendar status and new status is same then do nothing
  IF p_c_old_cal_status = p_c_new_cal_status THEN
    p_b_ret_status:=TRUE;
    RETURN;
  END IF;

  --If the new calendar status is INACTIVE then  check if any enrollment activity exist for the
  --unit sections for the calendar instance, if exists then return false with error message name else
  --return true by updating the unit section statuses of all the unit section under this calendar
  --with value 'NOT_OFFERED'

  IF p_c_new_cal_status = 'INACTIVE' THEN

    FOR l_uoo_id IN c_uoo_id LOOP

      IF igs_ps_gen_003.enrollment_for_uoo_check(l_uoo_id.uoo_id) THEN
        l_b_found:=TRUE;
        EXIT;
      END IF;

    END LOOP;

    IF l_b_found THEN
      p_b_ret_status:=FALSE;
      p_c_message_name:='IGS_PS_STATUS_NOT_UPD_ALLOWED';
      RETURN;
    ELSE
      FOR l_uoo_id IN c_uoo_id LOOP
         igs_ps_unit_ofr_opt_pkg.update_row( x_rowid                        =>l_uoo_id.rowid,
                                             x_unit_cd                      =>l_uoo_id.unit_cd,
                                             x_version_number               =>l_uoo_id.version_number,
                                             x_cal_type                     =>l_uoo_id.cal_type,
                                             x_ci_sequence_number           =>l_uoo_id.ci_sequence_number,
                                             x_location_cd                  =>l_uoo_id.location_cd,
                                             x_unit_class                   =>l_uoo_id.unit_class,
                                             x_uoo_id                       =>l_uoo_id.uoo_id,
                                             x_ivrs_available_ind           =>l_uoo_id.ivrs_available_ind,
                                             x_call_number                  =>l_uoo_id.call_number,
                                             x_unit_section_status          => 'NOT_OFFERED',
                                             x_unit_section_start_date      =>l_uoo_id.unit_section_start_date,
                                             x_unit_section_end_date        =>l_uoo_id.unit_section_end_date,
                                             x_enrollment_actual            =>l_uoo_id.enrollment_actual,
                                             x_waitlist_actual              =>l_uoo_id.waitlist_actual,
                                             x_offered_ind                  =>l_uoo_id.offered_ind,
                                             x_state_financial_aid          =>l_uoo_id.state_financial_aid,
                                             x_grading_schema_prcdnce_ind   =>l_uoo_id.grading_schema_prcdnce_ind,
                                             x_federal_financial_aid        =>l_uoo_id.federal_financial_aid,
                                             x_unit_quota                   =>l_uoo_id.unit_quota,
                                             x_unit_quota_reserved_places   =>l_uoo_id.unit_quota_reserved_places,
                                             x_institutional_financial_aid  =>l_uoo_id.institutional_financial_aid,
                                             x_unit_contact                 =>l_uoo_id.unit_contact,
                                             x_grading_schema_cd            =>l_uoo_id.grading_schema_cd,
                                             x_gs_version_number            =>l_uoo_id.gs_version_number,
                                             x_owner_org_unit_cd            =>l_uoo_id.owner_org_unit_cd,
                                             x_attendance_required_ind      =>l_uoo_id.attendance_required_ind,
                                             x_reserved_seating_allowed     =>l_uoo_id.reserved_seating_allowed,
                                             x_special_permission_ind       =>l_uoo_id.special_permission_ind,
                                             x_ss_display_ind               =>l_uoo_id.ss_display_ind,
                                             x_mode                         =>'R',
                                             x_ss_enrol_ind                 =>l_uoo_id.ss_enrol_ind,
                                             x_dir_enrollment               =>l_uoo_id.dir_enrollment,
                                             x_enr_from_wlst                =>l_uoo_id.enr_from_wlst,
                                             x_inq_not_wlst                 =>l_uoo_id.inq_not_wlst,
                                             x_rev_account_cd               =>l_uoo_id.rev_account_cd,
                                             x_anon_unit_grading_ind        =>l_uoo_id.anon_unit_grading_ind,
                                             x_anon_assess_grading_ind      =>l_uoo_id.anon_assess_grading_ind,
                                             x_non_std_usec_ind             =>l_uoo_id.non_std_usec_ind,
                                             x_auditable_ind                =>l_uoo_id.auditable_ind,
                                             x_audit_permission_ind         =>l_uoo_id.audit_permission_ind,
					     x_not_multiple_section_flag    =>l_uoo_id.not_multiple_section_flag,
					     x_sup_uoo_id                   =>l_uoo_id.sup_uoo_id,
					     x_relation_type                =>l_uoo_id.relation_type,
					     x_default_enroll_flag          =>l_uoo_id.default_enroll_flag ,
					     x_abort_flag                   =>l_uoo_id.abort_flag
                                            );
      END LOOP;
      p_b_ret_status:=TRUE;
      RETURN;
    END IF;

  --If the new calendar status is ACTIVE and old status is INACTIVE then update the unit section status
  --to OPEN for all the unit section under the calendar instance

  ELSIF p_c_new_cal_status = 'ACTIVE' AND p_c_old_cal_status ='INACTIVE' THEN
    FOR l_uoo_id IN c_uoo_id LOOP
        igs_ps_unit_ofr_opt_pkg.update_row( x_rowid                        =>l_uoo_id.rowid,
                                            x_unit_cd                      =>l_uoo_id.unit_cd,
                                            x_version_number               =>l_uoo_id.version_number,
                                            x_cal_type                     =>l_uoo_id.cal_type,
                                            x_ci_sequence_number           =>l_uoo_id.ci_sequence_number,
                                            x_location_cd                  =>l_uoo_id.location_cd,
                                            x_unit_class                   =>l_uoo_id.unit_class,
                                            x_uoo_id                       =>l_uoo_id.uoo_id,
                                            x_ivrs_available_ind           =>l_uoo_id.ivrs_available_ind,
                                            x_call_number                  =>l_uoo_id.call_number,
                                            x_unit_section_status          => 'OPEN',
                                            x_unit_section_start_date      =>l_uoo_id.unit_section_start_date,
                                            x_unit_section_end_date        =>l_uoo_id.unit_section_end_date,
                                            x_enrollment_actual            =>l_uoo_id.enrollment_actual,
                                            x_waitlist_actual              =>l_uoo_id.waitlist_actual,
                                            x_offered_ind                  =>l_uoo_id.offered_ind,
                                            x_state_financial_aid          =>l_uoo_id.state_financial_aid,
                                            x_grading_schema_prcdnce_ind   =>l_uoo_id.grading_schema_prcdnce_ind,
                                            x_federal_financial_aid        =>l_uoo_id.federal_financial_aid,
                                            x_unit_quota                   =>l_uoo_id.unit_quota,
                                            x_unit_quota_reserved_places   =>l_uoo_id.unit_quota_reserved_places,
                                            x_institutional_financial_aid  =>l_uoo_id.institutional_financial_aid,
                                            x_unit_contact                 =>l_uoo_id.unit_contact,
                                            x_grading_schema_cd            =>l_uoo_id.grading_schema_cd,
                                            x_gs_version_number            =>l_uoo_id.gs_version_number,
                                            x_owner_org_unit_cd            =>l_uoo_id.owner_org_unit_cd,
                                            x_attendance_required_ind      =>l_uoo_id.attendance_required_ind,
                                            x_reserved_seating_allowed     =>l_uoo_id.reserved_seating_allowed,
                                            x_special_permission_ind       =>l_uoo_id.special_permission_ind,
                                            x_ss_display_ind               =>l_uoo_id.ss_display_ind,
                                            x_mode                         =>'R',
                                            x_ss_enrol_ind                 =>l_uoo_id.ss_enrol_ind,
                                            x_dir_enrollment               =>l_uoo_id.dir_enrollment,
                                            x_enr_from_wlst                =>l_uoo_id.enr_from_wlst,
                                            x_inq_not_wlst                 =>l_uoo_id.inq_not_wlst,
                                            x_rev_account_cd               =>l_uoo_id.rev_account_cd,
                                            x_anon_unit_grading_ind        =>l_uoo_id.anon_unit_grading_ind,
                                            x_anon_assess_grading_ind      =>l_uoo_id.anon_assess_grading_ind,
                                            x_non_std_usec_ind             =>l_uoo_id.non_std_usec_ind,
                                            x_auditable_ind                =>l_uoo_id.auditable_ind,
                                            x_audit_permission_ind         =>l_uoo_id.audit_permission_ind,
                                            x_not_multiple_section_flag    =>l_uoo_id.not_multiple_section_flag,
   					    x_sup_uoo_id                   =>l_uoo_id.sup_uoo_id,
					    x_relation_type                =>l_uoo_id.relation_type,
					    x_default_enroll_flag          =>l_uoo_id.default_enroll_flag,
				            x_abort_flag                   =>l_uoo_id.abort_flag
                                          );
    END LOOP;
    p_b_ret_status:=TRUE;
    RETURN;

  END IF;

END change_unit_section_status;

  FUNCTION fac_exceed_exp_wl(
                             p_c_cal_type IN VARCHAR2,
                             p_n_cal_seq_num IN NUMBER,
                             p_n_person_id IN NUMBER,
                             p_n_curr_wl IN NUMBER,
                             p_n_tot_fac_wl OUT NOCOPY NUMBER,
                             p_n_exp_wl OUT NOCOPY NUMBER) RETURN BOOLEAN
    ------------------------------------------------------------------------------------
          --Created by  : jdeekoll ( Oracle IDC)
          --Date created: 06-May-2003
          --
          --Purpose:  HR Integration build(# 2833853) - This function will be called when the passed calendar type is Load/Academic
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
          --sommukhe    09-Aug-2005     Bug#4318183, modified type for variable l_n_fac_assign_wl
   -------------------------------------------------------------------------------------
  AS

     /* Cursor to get the Calendar Category */
       CURSOR c_cal_cat IS
                          SELECT calendar_cat
                          FROM igs_ps_exp_wl;

       l_c_cal_cat_code igs_ps_exp_wl.calendar_cat%TYPE;

      l_c_emp_cat_code igs_ps_emp_cats_wl.emp_cat_code%TYPE;

     /* Cursor to get the expected workload for the respective employment category */
     CURSOR c_exp_wl(cp_c_emp_cat_code igs_ps_emp_cats_wl.emp_cat_code%TYPE,cp_n_cal_cat_code igs_ps_exp_wl.calendar_cat%TYPE) IS
                  SELECT ecw.expected_wl_num
                   FROM igs_ps_emp_cats_wl ecw
                   WHERE ecw.emp_cat_code = cp_c_emp_cat_code AND
                         cal_cat_code = cp_n_cal_cat_code ORDER BY ecw.last_update_date desc;

     l_n_exp_wl igs_ps_emp_cats_wl.expected_wl_num%TYPE:=0;

     /* Cursor to get the override expected workload */
     CURSOR c_fac_ovr_wl(cp_n_person_id hz_parties.party_id%TYPE,
                         cp_c_cal_type igs_ca_inst.cal_type%TYPE,
                         cp_n_cal_seq_num igs_ca_inst.sequence_number%TYPE
                        ) IS
                           SELECT NVL(fow.new_exp_wl,0)
                           FROM igs_ps_fac_wl fw,igs_ps_fac_ovr_wl fow
                           WHERE fw.person_id =  cp_n_person_id AND
                                 fow.fac_wl_id = fw.fac_wl_id AND
                                 fw.cal_type = cp_c_cal_type AND
                                 fw.ci_sequence_number=cp_n_cal_seq_num AND
                                 SYSDATE BETWEEN fow.start_date AND NVL(fow.end_date,SYSDATE);

     l_n_fac_ovr_wl igs_ps_fac_ovr_wl.new_exp_wl%TYPE:=0;

     /* Cursor to get sum of workload from assigned workload */
     CURSOR c_fac_assign_wl(cp_n_person_id hz_parties.party_id%TYPE,
                            cp_c_cal_type igs_ca_inst.cal_type%TYPE,
                              cp_n_cal_seq_num igs_ca_inst.sequence_number%TYPE
                            ) IS
                             SELECT NVL(SUM(NVL(fat.default_wl,0)),0)
                             FROM igs_ps_fac_wl fw,igs_ps_fac_asg_task fat
                             WHERE fw.person_id =  cp_n_person_id AND
                                   fat.fac_wl_id = fw.fac_wl_id AND
                                   fw.cal_type = cp_c_cal_type AND
                                   fw.ci_sequence_number=cp_n_cal_seq_num AND
                                   fat.confirmed_ind = 'Y';

     l_n_fac_assign_wl NUMBER:=0;

     /* Cursor to get sum of workload from Unit Section Teaching Responsibility */
     CURSOR c_tch_resp_wl(cp_n_person_id hz_parties.party_id%TYPE,
                          cp_c_cal_type igs_ca_inst.cal_type%TYPE,
                          cp_n_cal_seq_num igs_ca_inst.sequence_number%TYPE
                          )IS
                           SELECT NVL(utr.INSTRUCTIONAL_LOAD_LAB,0) +
                                 NVL(utr.INSTRUCTIONAL_LOAD_LECTURE,0) +
                                 NVL(utr.INSTRUCTIONAL_LOAD,0) teach_wl
                            FROM igs_ps_usec_tch_resp utr,igs_ps_unit_ofr_opt_all opt
                           WHERE utr.instructor_id =  cp_n_person_id AND
                                utr.uoo_id = opt.uoo_id AND
                                opt.cal_type = cp_c_cal_type AND
                                utr.confirmed_flag = 'Y' AND
                                opt.ci_sequence_number = cp_n_cal_seq_num AND
                                opt.unit_section_status NOT IN ('CANCELLED','NOT_OFFERED');

     l_n_wl NUMBER:=0;
     l_n_tch_resp_wl NUMBER:=0;
     l_c_s_cal_cat igs_ca_type.s_cal_cat%TYPE;
     l_c_tch_cal_type igs_ca_inst.cal_type%TYPE;
     l_n_tch_cal_seq_num igs_ca_inst.sequence_number%TYPE;

     TYPE ref_cur_get_teach_cal IS REF CURSOR;
     c_get_tch_cal ref_cur_get_teach_cal;


  BEGIN
     --Added this code as gscc warning was comming for file.sql.35
     l_c_emp_cat_code :=igs_pe_gen_002.get_active_emp_cat(p_n_person_id);
     l_c_s_cal_cat    :='TEACHING';

     /* Calendar category cursor*/
     OPEN c_cal_cat;
     FETCH c_cal_cat INTO l_c_cal_cat_code;
     CLOSE c_cal_cat;

     /* employment category cursor*/
     OPEN c_exp_wl(l_c_emp_cat_code,l_c_cal_cat_code);
     FETCH c_exp_wl INTO l_n_exp_wl;
     CLOSE c_exp_wl;

     /* Override expected workload cursor */
     OPEN c_fac_ovr_wl(p_n_person_id,p_c_cal_type,p_n_cal_seq_num);
     FETCH c_fac_ovr_wl INTO l_n_fac_ovr_wl;
     CLOSE c_fac_ovr_wl;

     /* Assigned workload cursor*/
     OPEN c_fac_assign_wl(p_n_person_id,p_c_cal_type,p_n_cal_seq_num);
     FETCH c_fac_assign_wl INTO l_n_fac_assign_wl;
     CLOSE c_fac_assign_wl;

     /* Load To Teaching calendar cursor */

     IF l_c_cal_cat_code = 'LOAD' THEN

     /* Cursor to get the teaching calendars for the respective load calendar */

       OPEN c_get_tch_cal FOR 'SELECT teach_cal_type,teach_ci_sequence_number'||
                                ' FROM igs_ca_load_to_teach_v WHERE load_cal_type = :1 AND'||
                                ' load_ci_sequence_number = :2 ' USING p_c_cal_type,p_n_cal_seq_num;

      ELSIF l_c_cal_cat_code = 'ACADEMIC' THEN

     /* Cursor to get teaching calendars for respective Academic calendars */

       OPEN c_get_tch_cal FOR 'SELECT cir.sub_cal_type,cir.sub_ci_sequence_number'||
                                ' FROM igs_ca_inst_rel cir, igs_ca_type ct'||
                                ' WHERE cir.sub_cal_type = ct.cal_type AND'||
                                ' ct.s_cal_cat = :1 AND'||
                                ' sup_cal_type = :2 AND'||
                                    ' sup_ci_sequence_number = :3 ' USING l_c_s_cal_cat,p_c_cal_type,p_n_cal_seq_num;
      END IF;

      IF l_c_cal_cat_code IN ('LOAD','ACADEMIC') THEN
        LOOP
          FETCH c_get_tch_cal INTO l_c_tch_cal_type,l_n_tch_cal_seq_num;
          EXIT WHEN c_get_tch_cal%NOTFOUND;
          l_n_wl :=0;

         /* Unit Section Teaching Responsibility workload cursor */

            FOR c_tch_resp_wl_rec IN c_tch_resp_wl(p_n_person_id,l_c_tch_cal_type,l_n_tch_cal_seq_num)
          LOOP
            l_n_wl := l_n_wl + NVL(c_tch_resp_wl_rec.teach_wl,0);
          END LOOP;

          l_n_tch_resp_wl := l_n_tch_resp_wl + l_n_wl;

         END LOOP;
       /* Close the cursor */
          CLOSE c_get_tch_cal;
       END IF;

     /* Total Faculty assigned workload, including the current workload passed (at present this is only from Unit Section Teaching Responsibility */

     p_n_tot_fac_wl := NVL(l_n_fac_assign_wl,0) + NVL(l_n_tch_resp_wl,0)+NVL(p_n_curr_wl,0);

     /* If override workload > 0 then, the total faculty assigned workload should be compared with override expected workload, else expected workload */

       IF NVL(l_n_fac_ovr_wl,0) > 0 THEN
         p_n_exp_wl := NVL(l_n_fac_ovr_wl,0);
       ELSE
         p_n_exp_wl := NVL(l_n_exp_wl,0);
       END IF;

       IF NVL(p_n_tot_fac_wl,0) > p_n_exp_wl THEN
         RETURN TRUE;
       ELSE
        RETURN FALSE;
       END IF;

  END fac_exceed_exp_wl;

  FUNCTION teach_fac_wl(
                         p_c_cal_type IN VARCHAR2,
                         p_n_cal_seq_num IN NUMBER,
                         p_n_person_id IN NUMBER,
                         p_n_curr_wl IN NUMBER,
                         p_n_tot_fac_wl OUT NOCOPY NUMBER,
                         p_n_exp_wl OUT NOCOPY NUMBER) RETURN BOOLEAN
    ------------------------------------------------------------------------------------
          --Created by  : jdeekoll ( Oracle IDC)
          --Date created: 11-May-2003
          --
          --Purpose:  HR Integration build - This function will be called when the passed calendar type is teaching
          --
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          --Who         When            What
   -------------------------------------------------------------------------------------
  AS

     /* Cursor to get the Calendar Category */
       CURSOR c_cal_cat IS
                          SELECT calendar_cat
                          FROM igs_ps_exp_wl;

       l_c_cal_cat_code igs_ps_exp_wl.calendar_cat%TYPE;
       l_c_s_cal_cat igs_ca_type.s_cal_cat%TYPE;
       l_c_cal_type igs_ca_inst.cal_type%TYPE;
       l_n_cal_seq_num igs_ca_inst.sequence_number%TYPE;


       TYPE ref_cur_get_cal IS REF CURSOR;
       c_get_cal ref_cur_get_cal;


  BEGIN
     --Added as it was giving file.sql.35 warning
     l_c_s_cal_cat :='ACADEMIC';

     /* Calendar category cursor*/
     OPEN c_cal_cat;
     FETCH c_cal_cat INTO l_c_cal_cat_code;
     CLOSE c_cal_cat;

     IF l_c_cal_cat_code = 'LOAD' THEN

     /* Cursor for to get Load calendar when Teach cal is passed */

       OPEN c_get_cal FOR 'SELECT load_cal_type,load_ci_sequence_number'||
                                ' FROM igs_ca_teach_to_load_v WHERE teach_cal_type = :1 AND'||
                                ' teach_ci_sequence_number = :2 ' USING p_c_cal_type,p_n_cal_seq_num;

      ELSIF l_c_cal_cat_code = 'ACADEMIC' THEN

     /* Cursor for to get Academic calendar when Teach cal is passed */

       OPEN c_get_cal FOR 'SELECT cir.sup_cal_type,cir.sup_ci_sequence_number'||
                                ' FROM igs_ca_inst_rel cir, igs_ca_type ct'||
                                ' WHERE cir.sup_cal_type = ct.cal_type AND'||
                                ' ct.s_cal_cat = :1 AND'||
                                ' sub_cal_type = :2 AND'||
                                ' sub_ci_sequence_number = :3 ' USING l_c_s_cal_cat,p_c_cal_type,p_n_cal_seq_num;
     END IF;

     IF l_c_cal_cat_code IN ('LOAD','ACADEMIC') THEN
       LOOP

         FETCH c_get_cal INTO l_c_cal_type,l_n_cal_seq_num;
           EXIT WHEN c_get_cal%NOTFOUND;

         /* If any one of the worklaod is exceeded with in particular Load calendar, then exist, else continue */

         IF igs_ps_gen_001.fac_exceed_exp_wl(
                                            l_c_cal_type,
                                            l_n_cal_seq_num,
                                            p_n_person_id,
                                            p_n_curr_wl,
                                            p_n_tot_fac_wl,
                                            p_n_exp_wl
                                           ) THEN
                       RETURN TRUE;
         END IF;
       END LOOP;
       /* Close the cursor */
       CLOSE c_get_cal;
     END IF;

     /* It will come to this step, only if the staff has not exceeded in any of the load calendars */

     RETURN FALSE;

  END teach_fac_wl;

END IGS_PS_GEN_001;

/
