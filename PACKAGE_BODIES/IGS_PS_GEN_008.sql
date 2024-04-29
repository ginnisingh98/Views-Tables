--------------------------------------------------------
--  DDL for Package Body IGS_PS_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GEN_008" AS
/* $Header: IGSPS08B.pls 120.7 2006/01/31 02:33:55 sommukhe ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  -- Who         When            What
  --ijeddy     Dec 3, 2003        Grade Book Enh build, bug no 3201661
  -- ijeddy    03-nov-2003    Bug# 3181938; Modified this object as per Summary Measurement Of Attainment TD.
  --sarakshi   09-sep-2003       Enh#3052452,removed the local function crspl_ins_sub_unit_rel and its call
  --vvutukur   05-Aug-2003       Enh#3045069.PSP Enh Build. Modified crspl_ins_unit_off_opt,CRSP_INS_UOP_UOO.
  --vvutukur   24-May-2003       Enh#2831572.Financial Accounting Build. Modified procedure crsp_ins_unit_ver.
        --
        -- nalkumar    19-May-2003     Bug# 2829291; Modified the call of IGS_AS_UNITASS_ITEM_PKG.INSERT_ROW;
        --                             Modifications are as per 'Assessment Item Description' FD;
        --
  -- sarakshi    18-Apr-2003     Bug#2910695,modified procedure crspl_ins_unit_off_opt and CRSP_INS_UOP_UOO
  -- sarakshi    05-Mar-2003     Bug#2768783, modified procedure crsp_ins_uop_uoo and crspl_ins_unit_off_opt,
  --                             removed local function check_call_number
  -- shtatiko    06-NOV-2002     Added auditable_ind and audit_permission_ind parameters to
  --                             insert_row calls of igs_ps_unit_ofr_opt_pkg as part of
  --                             bug# 2636716, EN Integration.
  -- jbegum      11-Sep-2002     As part of bug#2563596
  --                             1) The logic of FUNCTION CRSP_INS_UOP_UOO has been modified.
  --                             2) The PROCEDURE  handle_excp has been modified.
  --                             3) The exception handling of FUNCTION CRSP_INS_UOP_UOO has been modified
  -- sarakshi     5-Jun-2002      bug#2332807, changes are mentioned in detail in the code, procedure crsp_ins_uop_uoo.
  -- prraj       14-Feb-2002     Added column NON_STD_USEC_IND to tbh calls for
  --                             pkg IGS_PS_UNIT_OFR_OPT_PKG (Bug# 2224366)
  -- ayedubat    30-JAN-2002     Changed the crsp_ins_unit_ver procedure to add the HESA functionality
  --                             as per the HESA Integration DLD ( Bug # 2201753)
  -- ddey        01-FEB-2002     Added columns anon_unit_grading_ind  and anon_assess_grading_ind in the calls
  --                             for the package IGS_PS_UNIT_OFR_OPT_PKG
  -- smadathi    28-AUG-2001     Bug No. 1956374 .The call to igs_ps_val_uoo.genp_val_staff_prsn
  --                             is changed to igs_ad_val_acai.genp_val_staff_prsn
  -- nalkumar  02-Jan-2002       Modified the crspl_ins_unit_assmnt_item procedure as per the
  --                             Calculation of Results Part-1 DLD. Bug# 2162831
  -- ayedubat    14-Jan-2003     Removed the cursor, cur_uv_obj_exist which checks for the HESA Package existence
  --                             Also removed the execute immediate and calling the package directly for bug, 3305858
  -------------------------------------------------------------------------------------------

        x_rowid                 VARCHAR2(25);

PROCEDURE crsp_ins_unit_set(
  p_old_unit_set_cd IN VARCHAR2 ,
  p_old_version_number IN NUMBER ,
  p_new_unit_set_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
AS
        cst_upper_limit_err             NUMBER;
        cst_lower_limit_err             NUMBER;
        gv_err_msg_proc_part1           VARCHAR2(255);
        gv_err_msg_proc_part2           VARCHAR2(255);
        gv_err_msg_proc1                VARCHAR2(60);
        gv_err_msg_proc2                VARCHAR2(60);
        gv_err_msg_proc3                VARCHAR2(60);
        gv_err_msg_proc4                VARCHAR2(60);
        gv_err_msg_proc5                VARCHAR2(60);
        gv_err_msg_proc6                VARCHAR2(60);
        gv_unit_version_exist           VARCHAR2(1);


BEGIN   -- crsp_ins_unit_set
        -- This module is the procedure responsible for transferring all of
        -- the details for a nominated IGS_PS_UNIT set over into another IGS_PS_UNIT set
        -- The logic consists of getting the records from the appropriate
        -- record types, which are children of the "old" IGS_EN_UNIT_SET and making
        -- duplicates of them under the "new" IGS_EN_UNIT_SET. Prior to the routine
        -- being called a new version of the IGS_EN_UNIT_SET record will have been created

       -- Assigning initial values to local variables which were being initialised using DEFAULT
       -- clause.Done as part of bug #2563596 to remove GSCC warning.
       cst_upper_limit_err := -20000;
       cst_lower_limit_err := -20999;

DECLARE
        v_message_name          varchar2(30);
--------------SUB-PROCEDURE 1---------------
        FUNCTION crspl_ins_duplicate_note (
                p_existing_ref_number           IGS_GE_NOTE.reference_number%TYPE,
                p_new_ref_number        OUT NOCOPY      IGS_GE_NOTE.reference_number%TYPE )
        RETURN BOOLEAN
        AS
        BEGIN
        DECLARE
                CURSOR c_note_seq IS
                        SELECT IGS_GE_NOTE_RF_NUM_S.nextval
                        FROM dual;
                CURSOR c_note IS
                        SELECT  IGS_GE_NOTE.s_note_format_type,
                                IGS_GE_NOTE.note_text
                        FROM    IGS_GE_NOTE IGS_GE_NOTE
                        WHERE   IGS_GE_NOTE.reference_number = p_existing_ref_number;
                v_note_rec              c_note%ROWTYPE;
                v_note_seq              IGS_GE_NOTE.reference_number%TYPE;

        BEGIN
                -- get next val of reference_number of IGS_GE_NOTE
                OPEN c_note_seq;
                FETCH c_note_seq INTO v_note_seq;
                CLOSE c_note_seq;
                --- Get related IGS_GE_NOTE and insert under new reference number
                OPEN c_note;
                FETCH c_note INTO v_note_rec;
                IF c_note%FOUND THEN
                        x_rowid :=      NULL;
                        IGS_GE_NOTE_PKG.Insert_Row(
                                                X_ROWID               =>        x_rowid,
                                                X_REFERENCE_NUMBER    =>        v_note_seq,
                                                X_S_NOTE_FORMAT_TYPE  =>        v_note_rec.s_note_format_type,
                                                X_NOTE_TEXT           =>        v_note_rec.note_text,
                                                X_MODE                =>        'R');

                                        p_new_ref_number := v_note_seq;
                        CLOSE c_note;
                        RETURN TRUE;
                END IF;
                CLOSE c_note;
                RETURN FALSE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_note%ISOPEN THEN
                                CLOSE c_note;
                        END IF;
                        IF c_note_seq%ISOPEN THEN
                                CLOSE c_note_seq;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_duplicate_note;
--------------SUB-PROCEDURE 2--------------------
        PROCEDURE crspl_unit_set_note
        AS
        BEGIN
        DECLARE
                v_new_reference_number  IGS_GE_NOTE.reference_number%TYPE;
                v_new_ref_number        IGS_GE_NOTE.reference_number%TYPE;
                v_new_ref_no            IGS_GE_NOTE.reference_number%TYPE;
                -- The following cursor excludes notes records with NULL
                -- values in the note_text field as this implies that it
                -- contains data in the note_ole field which cannot be
                -- copied with the current product limitations.
                -- i.e. must be copied manually
                CURSOR c_usn IS
                        SELECT  usn.reference_number,
                                usn.crs_note_type
                        FROM    IGS_EN_UNIT_SET_NOTE usn
                        WHERE   usn.unit_set_cd         = p_old_unit_set_cd     AND
                                usn.version_number      = p_old_version_number  AND
                                EXISTS (
                                         SELECT 'x'
                                         FROM   IGS_GE_NOTE nte
                                         WHERE  nte.reference_number =
                                                        usn.reference_number AND
                                                nte.note_text IS NOT NULL);

        BEGIN
                FOR v_usn_rec IN c_usn LOOP
                        IF crspl_ins_duplicate_note(
                                        v_usn_rec.reference_number,
                                        v_new_ref_number) = TRUE THEN
                                v_new_ref_no := v_new_ref_number;
                        END IF;
                        BEGIN
                                x_rowid :=      NULL;
                                IGS_EN_UNIT_SET_NOTE_PKG.Insert_Row(
                                                 X_ROWID              =>        x_rowid,
                                                 X_UNIT_SET_CD        =>        p_new_unit_set_cd,
                                                 X_VERSION_NUMBER     =>        p_new_version_number,
                                                 X_REFERENCE_NUMBER   =>        v_new_ref_no,
                                                 X_CRS_NOTE_TYPE      =>        v_usn_rec.crs_note_type,
                                                 X_MODE               =>        'R');

                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                SQLCODE <= cst_upper_limit_err THEN
                                                        p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_usn%ISOPEN) THEN
                                CLOSE c_usn;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                SQLCODE <= cst_upper_limit_err THEN
                                        p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_unit_set_note;
------------SUB-PROCEDURE 3-----------------------
        PROCEDURE crspl_unit_set_crs_type
        AS
        BEGIN
        DECLARE
                CURSOR c_usct IS
                        SELECT  usct.course_type
                        FROM    IGS_EN_UNITSETPSTYPE usct
                        WHERE   usct.unit_set_cd        = p_old_unit_set_cd AND
                                usct.version_number     = p_old_version_number;
        BEGIN
                FOR v_usct_rec IN c_usct LOOP
                        BEGIN
                                x_rowid :=      NULL;
                                IGS_EN_UNITSETPSTYPE_PKG.Insert_Row(
                                                        X_ROWID            =>   x_rowid,
                                                        X_UNIT_SET_CD      =>   p_new_unit_set_cd,
                                                        X_VERSION_NUMBER   =>   p_new_version_number,
                                                        X_COURSE_TYPE      =>   v_usct_rec.course_type,
                                                        X_MODE             =>   'R');

                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                SQLCODE <= cst_upper_limit_err THEN
                                                        p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_usct%ISOPEN) THEN
                                CLOSE c_usct;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                SQLCODE <= cst_upper_limit_err THEN
                                        p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_unit_set_crs_type;
-----------------SUB-PROCEDURE 4-----------------
        PROCEDURE crspl_crs_off_unit_set
        AS
        BEGIN
        DECLARE
                CURSOR c_cous IS
                        SELECT  cous.course_cd,
                                cous.crv_version_number,
                                cous.cal_type,
                                cous.override_title,
                                cous.only_as_sub_ind,
                                cous.show_on_official_ntfctn_ind
                        FROM    IGS_PS_OFR_UNIT_SET cous
                        WHERE   cous.unit_set_cd        = p_old_unit_set_cd AND
                                cous.us_version_number  = p_old_version_number;
                CURSOR c_cousr_sup (
                                cp_cous_course_cd       IGS_PS_OFR_UNIT_SET.course_cd%TYPE,
                                cp_cous_cal_type        IGS_PS_OFR_UNIT_SET.cal_type%TYPE,
                                cp_cous_crv_ver_num     IGS_PS_OFR_UNIT_SET.crv_version_number%TYPE) IS
                        SELECT  cousr.course_cd,
                                cousr.crv_version_number,
                                cousr.cal_type,
                                cousr.sub_unit_set_cd,
                                cousr.sub_us_version_number
                        FROM    IGS_PS_OF_UNT_SET_RL cousr
                        WHERE   cousr.sup_unit_set_cd           = p_old_unit_set_cd AND
                                cousr.sup_us_version_number     = p_old_version_number AND
                                cousr.course_cd                 = cp_cous_course_cd AND
                                cousr.cal_type                  = cp_cous_cal_type AND
                                cousr.crv_version_number        = cp_cous_crv_ver_num;
                CURSOR c_cousr_sub (
                                cp_cous_course_cd       IGS_PS_OFR_UNIT_SET.course_cd%TYPE,
                                cp_cous_cal_type        IGS_PS_OFR_UNIT_SET.cal_type%TYPE,
                                cp_cous_crv_ver_num     IGS_PS_OFR_UNIT_SET.crv_version_number%TYPE) IS
                        SELECT  cousr.course_cd,
                                cousr.crv_version_number,
                                cousr.cal_type,
                                cousr.sup_unit_set_cd,
                                cousr.sup_us_version_number
                        FROM    IGS_PS_OF_UNT_SET_RL cousr
                        WHERE   cousr.sub_unit_set_cd           = p_old_unit_set_cd AND
                                cousr.sub_us_version_number     = p_old_version_number AND
                                cousr.course_cd                 = cp_cous_course_cd AND
                                cousr.cal_type                  = cp_cous_cal_type AND
                                cousr.crv_version_number        = cp_cous_crv_ver_num;
                CURSOR c_coous (
                                cp_cous_course_cd       IGS_PS_OFR_UNIT_SET.course_cd%TYPE,
                                cp_cous_version_number  IGS_PS_OFR_UNIT_SET.crv_version_number%TYPE,
                                cp_cous_cal_type        IGS_PS_OFR_UNIT_SET.cal_type%TYPE) IS
                        SELECT  coous.course_cd,
                                coous.crv_version_number,
                                coous.cal_type,
                                coous.location_cd,
                                coous.attendance_mode,
                                coous.attendance_type,
                                coous.coo_id
                        FROM    IGS_PS_OF_OPT_UNT_ST coous
                        WHERE   coous.unit_set_cd        = p_old_unit_set_cd AND
                coous.us_version_number  = p_old_version_number AND
                                coous.course_cd              = cp_cous_course_cd AND
                coous.crv_version_number = cp_cous_version_number AND
                                coous.cal_type           = cp_cous_cal_type;

        BEGIN
                FOR v_cous_rec IN c_cous LOOP
                        BEGIN
                                x_rowid :=      NULL;
                                IGS_PS_OFR_UNIT_SET_PKG.Insert_Row(
                                                        X_ROWID                        =>   x_rowid,
                                                        X_COURSE_CD                    =>       v_cous_rec.course_cd,
                                                        X_CRV_VERSION_NUMBER           =>       v_cous_rec.crv_version_number,
                                                        X_CAL_TYPE                     =>       v_cous_rec.cal_type,
                                                        X_UNIT_SET_CD                  =>       p_new_unit_set_cd,
                                                        X_US_VERSION_NUMBER            =>       p_new_version_number,
                                                        X_OVERRIDE_TITLE               =>       v_cous_rec.override_title,
                                                        X_ONLY_AS_SUB_IND              =>       v_cous_rec.only_as_sub_ind,
                                                        X_SHOW_ON_OFFICIAL_NTFCTN_IND  =>       v_cous_rec.show_on_official_ntfctn_ind,
                                                        X_MODE                         =>       'R');

                                FOR v_cousr_sub_rec IN c_cousr_sub (
                                                        v_cous_rec.course_cd,
                                                        v_cous_rec.cal_type,
                                                        v_cous_rec.crv_version_number) LOOP
                                        x_rowid :=      NULL;
                                        IGS_PS_OF_UNT_SET_RL_PKG.Insert_Row(
                                                                X_ROWID                    =>           x_rowid,
                                                                X_COURSE_CD                =>           v_cousr_sub_rec.course_cd,
                                                                X_CRV_VERSION_NUMBER       =>           v_cousr_sub_rec.crv_version_number,
                                                                X_SUP_US_VERSION_NUMBER    =>           v_cousr_sub_rec.sup_us_version_number,
                                                                X_SUB_UNIT_SET_CD          =>           p_new_unit_set_cd,
                                                                X_SUP_UNIT_SET_CD          =>           v_cousr_sub_rec.sup_unit_set_cd,
                                                                X_CAL_TYPE                 =>           v_cousr_sub_rec.cal_type,
                                                                X_SUB_US_VERSION_NUMBER    =>           p_new_version_number,
                                                                X_MODE                     =>           'R');


                                END LOOP; -- cousr
                                FOR v_cousr_sup_rec IN c_cousr_sup (
                                                        v_cous_rec.course_cd,
                                                        v_cous_rec.cal_type,
                                                        v_cous_rec.crv_version_number) LOOP
                                                x_rowid :=      NULL;
                                                IGS_PS_OF_UNT_SET_RL_PKG.Insert_Row(
                                                                        X_ROWID                        =>       x_rowid,
                                                                        X_COURSE_CD                    =>       v_cousr_sup_rec.course_cd,
                                                                        X_CRV_VERSION_NUMBER           =>       v_cousr_sup_rec.crv_version_number,
                                                                        X_SUP_US_VERSION_NUMBER        =>       p_new_version_number,
                                                                        X_SUB_UNIT_SET_CD              =>       v_cousr_sup_rec.sub_unit_set_cd,
                                                                        X_SUP_UNIT_SET_CD              =>       p_new_unit_set_cd,
                                                                        X_CAL_TYPE                     =>       v_cousr_sup_rec.cal_type,
                                                                        X_SUB_US_VERSION_NUMBER        =>       v_cousr_sup_rec.sub_us_version_number,
                                                                        X_MODE                         =>       'R');

                                END LOOP; -- cousr
                                FOR v_coous_rec IN c_coous (
                                                v_cous_rec.course_cd,
                                                v_cous_rec.crv_version_number,
                                                v_cous_rec.cal_type) LOOP
                                                x_rowid :=      NULL;
                                                IGS_PS_OF_OPT_UNT_ST_PKG.Insert_Row(
                                                                        X_ROWID                        =>       x_rowid,
                                                                        X_COURSE_CD                    =>       v_coous_rec.course_cd,
                                                                        X_LOCATION_CD                  =>       v_coous_rec.location_cd,
                                                                        X_ATTENDANCE_MODE              =>       v_coous_rec.attendance_mode,
                                                                        X_CAL_TYPE                     =>       v_coous_rec.cal_type,
                                                                        X_CRV_VERSION_NUMBER           =>       v_coous_rec.crv_version_number,
                                                                        X_ATTENDANCE_TYPE              =>       v_coous_rec.attendance_type,
                                                                        X_US_VERSION_NUMBER            =>       p_new_version_number,
                                                                        X_UNIT_SET_CD                  =>       p_new_unit_set_cd,
                                                                        X_COO_ID                       =>       v_coous_rec.coo_id,
                                                                        X_MODE                         =>       'R');

                                END LOOP; -- coous
                EXCEPTION
                        WHEN OTHERS THEN
                                IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                                ELSE
                                        App_Exception.Raise_Exception;
                                END IF;
                END;
        END LOOP; --cous
        EXCEPTION

                WHEN OTHERS THEN
                        IF (c_cous%ISOPEN) THEN
                                CLOSE c_cous;
                        END IF;
                        IF (c_cousr_sup%ISOPEN) THEN
                                CLOSE c_cousr_sup;
                        END IF;
                        IF (c_cousr_sub%ISOPEN) THEN
                                CLOSE c_cousr_sub;
                        END IF;
                        IF (c_coous%ISOPEN) THEN
                                CLOSE c_cousr_sup;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                SQLCODE <= cst_upper_limit_err THEN
                                        p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_crs_off_unit_set;
-----------------SUB-PROCEDURE 5-------------------------
        PROCEDURE crspl_unit_set_rule
        AS
        BEGIN
        DECLARE
                v_new_rul_seq_number NUMBER;
                CURSOR c_usr IS
                        SELECT  usr.s_rule_call_cd,
                                usr.rul_sequence_number
                        FROM    IGS_EN_UNIT_SET_RULE usr
                        WHERE   usr.unit_set_cd         = p_old_unit_set_cd AND
                                usr.version_number      = p_old_version_number;
        BEGIN
                FOR v_usr_rec IN c_usr LOOP
                        BEGIN
                                v_new_rul_seq_number := IGS_RU_GEN_003.rulp_ins_copy_rule(
                                                                v_usr_rec.s_rule_call_cd,
                                                                v_usr_rec.rul_sequence_number);
                                x_rowid :=      NULL;
                                IGS_EN_UNIT_SET_RULE_PKG.Insert_Row(
                                                        X_ROWID                  =>             x_rowid,
                                                        X_UNIT_SET_CD            =>             p_new_unit_set_cd,
                                                        X_VERSION_NUMBER         =>             p_new_version_number,
                                                        X_S_RULE_CALL_CD         =>             v_usr_rec.s_rule_call_cd,
                                                        X_RUL_SEQUENCE_NUMBER    =>             v_new_rul_seq_number,
                                                        X_MODE                   =>             'R');

                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_usr%ISOPEN) THEN
                                CLOSE c_usr;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_unit_set_rule;
----------------SUB-PROCEDURE 6---------------------
        PROCEDURE crspl_coo_adm_cat_unit_set
        AS
        BEGIN
        DECLARE
                CURSOR c_cacus IS
                        SELECT  cacus.course_cd,
                                cacus.crv_version_number,
                                cacus.cal_type,
                                cacus.location_cd,
                                cacus.attendance_mode,
                                cacus.attendance_type,
                                cacus.admission_cat
                        FROM    IGS_PS_COO_AD_UNIT_S cacus
                        WHERE   cacus.unit_set_cd       = p_old_unit_set_cd AND
                                cacus.us_version_number = p_old_version_number;

        BEGIN
                FOR v_cacus_rec IN c_cacus LOOP
                        BEGIN
                                x_rowid :=      NULL;
                                IGS_PS_COO_AD_UNIT_S_PKG.Insert_Row(
                                                        X_ROWID                =>       x_rowid,
                                                        X_COURSE_CD            =>       v_cacus_rec.course_cd,
                                                        X_CRV_VERSION_NUMBER   =>       v_cacus_rec.crv_version_number,
                                                        X_CAL_TYPE             =>       v_cacus_rec.cal_type,
                                                        X_LOCATION_CD          =>       v_cacus_rec.location_cd,
                                                        X_ATTENDANCE_MODE      =>       v_cacus_rec.attendance_mode,
                                                        X_ATTENDANCE_TYPE      =>       v_cacus_rec.attendance_type,
                                                        X_ADMISSION_CAT        =>       v_cacus_rec.admission_cat,
                                                        X_UNIT_SET_CD          =>       p_new_unit_set_cd,
                                                        X_US_VERSION_NUMBER    =>       p_new_version_number,
                                                        X_MODE                 =>       'R');

                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF (c_cacus%ISOPEN) THEN
                                CLOSE c_cacus;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_UNIT_SET';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_coo_adm_cat_unit_set;
----------------- MAIN-------------------------
BEGIN
        -- initialise msg_no to default indicating that insert was
        -- successful
        p_message_name := 'IGS_PS_SUCCESS_COPY_UNIT_SET';
        -- 1. Validate new IGS_EN_UNIT_SET exists using
        --    IGS_EN_VAL_PUSE.crsp_val_us_exists and
        --    the 'new' parameters passed in.
        -- As part of the bug# 1956374 changed to the below call from  IGS_PS_VAL_US.crsp_val_us_exists
        IF IGS_EN_VAL_PUSE.crsp_val_us_exists(
                                        p_new_unit_set_cd,
                                        p_new_version_number,
                                        v_message_name) = FALSE THEN
                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                RETURN;
        END IF;
        -- 2. Validate old IGS_EN_UNIT_SET exists using
        --    IGS_EN_VAL_PUSE.crsp_val_us_exists and
        --    the 'old' parameters passed in.
        -- As part of the bug# 1956374 changed to the below call from  IGS_PS_VAL_US.crsp_val_us_exists
        IF IGS_EN_VAL_PUSE.crsp_val_us_exists(
                                        p_old_unit_set_cd,
                                        p_old_version_number,
                                        v_message_name) = FALSE THEN
                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                RETURN;
        END IF;
        -- 3. For each of the subordinate tables find records using the
        --    unit_set_cd and version_number as for the values of the
        --    'old' parameters passed in and insert records,
        --    substituting values for unit_set_cd and version_number
        --    with the values of the 'new' parameters passed in.
        -- IGS_GE_NOTE : An exception handler is raised when an error number is
        --        found to be in the range -20000 to -20999 (which
        --        indicates that the exception is user defined
        --        one of the validation routines within the system).
        --        If not within this range, it will be raised by
        --        standard exception handling.
        -- Check if the IGS_EN_UNIT_SET_NOTE record exists for the old IGS_PS_UNIT
        -- code and version number.  If so, create the new record
        -- with the substituted values.
        crspl_unit_set_note;
        --- Check if the IGS_EN_UNITSETPSTYPE record exists for
        --  the old IGS_PS_UNIT code and version number.  If so, create
        --  the new record with the substituted values.
        crspl_unit_set_crs_type;
        -- Check if the IGS_PS_OFR_UNIT_SET record exists
        --  for the old IGS_PS_UNIT code and version number.  If so,
        -- create the new record with the substituted values.
        -- Create new records for child records of cous
        -- i.e. cousr and coous
        crspl_crs_off_unit_set;
        --- Check if the IGS_EN_UNIT_SET_RULE record exists for the old IGS_PS_UNIT code and
        --- version number.  If so, create the new record with the substituted values.
        crspl_unit_set_rule;
        --- Check if the  record exists for the old IGS_PS_UNIT code and
        --- version number.  If so, create the new record with the substituted values.
        crspl_coo_adm_cat_unit_set;
END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_008.crsp_ins_unit_set');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END crsp_ins_unit_set;

FUNCTION get_section_status (p_c_src_usec_status igs_ps_unit_ofr_opt_all.unit_section_status%TYPE
                            ) RETURN VARCHAR2 AS
/*************************************************************
     Created By : sarakshi
     Date Created By :14-Oct-2004
     Purpose :To get the destination unit section status
     Know limitations, enhancements or remarks
     Change History
     Who             When            What

     (reverse chronological order - newest change first)
***************************************************************/
  l_c_usec_status igs_ps_unit_ofr_opt_all.unit_section_status%TYPE;
BEGIN
  IF p_c_src_usec_status  = 'OPEN' THEN
    l_c_usec_status := 'OPEN';
  ELSIF p_c_src_usec_status  = 'PLANNED' THEN
    l_c_usec_status := 'PLANNED';
  ELSIF p_c_src_usec_status  = 'CANCELLED' THEN
    l_c_usec_status := 'CANCELLED';
  ELSIF p_c_src_usec_status  = 'NOT_OFFERED' THEN
    l_c_usec_status := 'NOT_OFFERED';
  ELSIF p_c_src_usec_status  = 'CLOSED' THEN
    l_c_usec_status := 'OPEN';
  ELSIF p_c_src_usec_status  = 'FULLWAITOK' THEN
    l_c_usec_status := 'OPEN';
  ELSIF p_c_src_usec_status  = 'HOLD' THEN
    l_c_usec_status := 'OPEN';
  END IF;

  RETURN l_c_usec_status;

END get_section_status;


--Private procedure for updating the sup_uo_id and relation_type value of IGS_PS_UNIT_OFR_OPT_ALL
PROCEDURE update_usec_record (p_uoo_id        igs_ps_unit_ofr_opt.uoo_id%TYPE,
            p_relation_type igs_ps_unit_ofr_opt.relation_type%TYPE,
            p_sup_uoo_id    igs_ps_unit_ofr_opt.sup_uoo_id%TYPE,
	    p_default_enroll_flag igs_ps_unit_ofr_opt.default_enroll_flag%TYPE) IS
 /*----------------------------------------------------------------------------
  ||  Created By :sarakshi
  ||  Created On :17-oct-2003
  ||  Purpose :For updating the sup_uo_id and relation_type value of IGS_PS_UNIT_OFR_OPT_ALL from multiple places in this package
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sarakshi   17-Nov-2005  Bug#4726940,changed the signature by adding p_default_enroll_flag
  ----------------------------------------------------------------------------*/

  CURSOR cur_usec(cp_uoo_id   igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT *
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id=cp_uoo_id;
  l_cur_usec  cur_usec%ROWTYPE;

BEGIN
  OPEN cur_usec(p_uoo_id);
  FETCH cur_usec INTO l_cur_usec;
  CLOSE cur_usec;

  igs_ps_unit_ofr_opt_pkg.update_row(  x_rowid                       =>l_cur_usec.row_id,
               x_unit_cd                     =>l_cur_usec.unit_cd,
               x_version_number              =>l_cur_usec.version_number,
               x_cal_type                    =>l_cur_usec.cal_type,
               x_ci_sequence_number          =>l_cur_usec.ci_sequence_number,
               x_location_cd                 =>l_cur_usec.location_cd,
               x_unit_class                  =>l_cur_usec.unit_class,
               x_uoo_id                      =>l_cur_usec.uoo_id,
               x_ivrs_available_ind          =>l_cur_usec.ivrs_available_ind,
               x_call_number                 =>l_cur_usec.call_number,
               x_unit_section_status         =>l_cur_usec.unit_section_status,
               x_unit_section_start_date     =>l_cur_usec.unit_section_start_date,
               x_unit_section_end_date       =>l_cur_usec.unit_section_end_date,
               x_enrollment_actual           =>l_cur_usec.enrollment_actual,
               x_waitlist_actual             =>l_cur_usec.waitlist_actual,
               x_offered_ind                 =>l_cur_usec.offered_ind,
               x_state_financial_aid         =>l_cur_usec.state_financial_aid,
               x_grading_schema_prcdnce_ind  =>l_cur_usec.grading_schema_prcdnce_ind,
               x_federal_financial_aid       =>l_cur_usec.federal_financial_aid,
               x_unit_quota                  =>l_cur_usec.unit_quota,
               x_unit_quota_reserved_places  =>l_cur_usec.unit_quota_reserved_places,
               x_institutional_financial_aid =>l_cur_usec.institutional_financial_aid,
               x_grading_schema_cd           =>l_cur_usec.grading_schema_cd,
               x_gs_version_number           =>l_cur_usec.gs_version_number,
               x_unit_contact                =>l_cur_usec.unit_contact,
               x_mode                        =>'R',
               x_ss_enrol_ind                => l_cur_usec.ss_enrol_ind,
               x_owner_org_unit_cd           => l_cur_usec.owner_org_unit_cd,
               x_attendance_required_ind     => l_cur_usec.attendance_required_ind,
               x_reserved_seating_allowed    => l_cur_usec.reserved_seating_allowed,
               x_ss_display_ind              => l_cur_usec.ss_display_ind,
               x_special_permission_ind      => l_cur_usec.special_permission_ind,
               x_rev_account_cd              => l_cur_usec.rev_account_cd ,
               x_anon_unit_grading_ind       => l_cur_usec.anon_unit_grading_ind,
               x_anon_assess_grading_ind     => l_cur_usec.anon_assess_grading_ind ,
               x_non_std_usec_ind            => l_cur_usec.non_std_usec_ind,
               x_auditable_ind               => l_cur_usec.auditable_ind,
               x_audit_permission_ind        => l_cur_usec.audit_permission_ind,
               x_not_multiple_section_flag   => l_cur_usec.not_multiple_section_flag,
               x_sup_uoo_id                  => p_sup_uoo_id,
               x_relation_type               => p_relation_type,
               x_default_enroll_flag         => NVL(p_default_enroll_flag,l_cur_usec.default_enroll_flag),
	       x_abort_flag                  => l_cur_usec.abort_flag
              );

END update_usec_record;


PROCEDURE crsp_ins_unit_ver(
  p_old_unit_cd IN VARCHAR2 ,
  p_old_version_number IN NUMBER ,
  p_new_unit_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_c_message_superior  OUT NOCOPY VARCHAR2) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sarakshi    03-Jun-2004     Bug#3655650, modified procedure crspl_ins_unit_assmnt_item to rollover the unit assessment items group records.Also modified the procedure crspl_uofr_wlist_details
  ||  sarakshi    17-oct-2003     Enh#3168650,Added procedure crspl_upd_usec_relation
  ||  vvutukur    24-May-2003     Enh#2831572.Financial Accounting Build. Removed the local procedure CRSP_INS_UNIT_REVSEG and its related call.
  ----------------------------------------------------------------------------*/

        cst_upper_limit_err             NUMBER;
        cst_lower_limit_err             NUMBER;
        gv_unit_version_exist           VARCHAR2(1);
        PROCEDURE crspl_ins_duplicate_note (
                p_existing_ref_number           IGS_GE_NOTE.reference_number%TYPE,
                p_new_ref_number        OUT NOCOPY      IGS_GE_NOTE.reference_number%TYPE )
        AS
                CURSOR SGN_CUR IS
                                SELECT *
                                FROM IGS_GE_NOTE
                                WHERE   reference_number = p_existing_ref_number;
        BEGIN
                --- Get new reference number
                SELECT  IGS_GE_NOTE_RF_NUM_S.nextval
                INTO    p_new_ref_number
                FROM    dual;
                --- Get related IGS_GE_NOTE and insert under new reference number

                For SGN_Rec In SGN_CUR
                Loop
                        x_rowid :=      NULL;
                        IGS_GE_NOTE_PKG.Insert_Row(
                                        X_ROWID                 => x_rowid,
                                        X_REFERENCE_NUMBER      => p_new_ref_number,
                                        X_S_NOTE_FORMAT_TYPE    => SGN_Rec.s_note_format_type,
                                        X_NOTE_TEXT             => SGN_Rec.Note_Text,
                                        X_MODE                  => 'R');
                End Loop;

        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_duplicate_note;

        PROCEDURE crspl_ins_unit_ver_note (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE )
        AS
                v_unit_ver_note_rec             IGS_PS_UNIT_VER_NOTE%ROWTYPE;
                v_new_ref_number                IGS_GE_NOTE.reference_number%TYPE;
                --- The following cursor excludes notes records with NULL values in the
                --- note_text field as this implies that it contains data in the note_ole
                --- field which cannot be copied with the current product limitations.
                CURSOR  c_unit_ver_note_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_VER_NOTE uvn
                        WHERE   uvn.unit_cd = p_unit_cd                 AND
                                uvn.version_number = p_version_number   AND
                                EXISTS (
                                        SELECT  'x'
                                        FROM    IGS_GE_NOTE nte
                                        WHERE   nte.reference_number = uvn.reference_number AND
                                                nte.note_text IS NOT NULL );
        BEGIN
                FOR v_unit_ver_note_rec IN c_unit_ver_note_rec LOOP
                        crspl_ins_duplicate_note(
                                v_unit_ver_note_rec.reference_number,
                                v_new_ref_number);
                        BEGIN
                                x_rowid :=      NULL;
                                IGS_PS_UNIT_VER_NOTE_PKG.Insert_Row(
                                                        X_ROWID              => x_rowid,
                                                        X_UNIT_CD            => p_new_unit_cd,
                                                        X_REFERENCE_NUMBER   => v_new_ref_number,
                                                        X_VERSION_NUMBER     => p_new_version_number,
                                                        X_CRS_NOTE_TYPE      => v_unit_ver_note_rec.crs_note_type,
                                                        X_MODE               => 'R');

                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err OR SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_ver_note;
        PROCEDURE crspl_ins_unit_offer_note (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE )
        AS
                v_unit_offer_note_rec           IGS_PS_UNIT_OFR_NOTE%ROWTYPE;
                v_new_ref_number                IGS_GE_NOTE.reference_number%TYPE;
                --- The following cursor excludes notes records with NULL values in the
                --- note_text field as this implies that it contains data in the note_ole
                --- field which cannot be copied with the current product limitations.
                CURSOR  c_unit_offer_note_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_OFR_NOTE uon
                        WHERE   uon.unit_cd = p_unit_cd                 AND
                                uon.version_number = p_version_number   AND
                                EXISTS (
                                        SELECT  'x'
                                        FROM    IGS_GE_NOTE nte
                                        WHERE   nte.reference_number = uon.reference_number AND
                                                nte.note_text IS NOT NULL );

        BEGIN
                FOR v_unit_offer_note_rec IN c_unit_offer_note_rec LOOP
                        crspl_ins_duplicate_note(
                                v_unit_offer_note_rec.reference_number,
                                v_new_ref_number);
                        BEGIN
                                x_rowid :=      NULL;
                                IGS_PS_UNIT_OFR_NOTE_PKG.Insert_Row(
                                                 X_ROWID                =>      x_rowid,
                                                 X_UNIT_CD              =>      p_new_unit_cd,
                                                 X_VERSION_NUMBER       =>      p_new_version_number,
                                                 X_CAL_TYPE             =>      v_unit_offer_note_rec.cal_type,
                                                 X_REFERENCE_NUMBER     =>      v_new_ref_number,
                                                 X_CRS_NOTE_TYPE        =>      v_unit_offer_note_rec.crs_note_type,
                                                 X_MODE                 =>      'R');
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_offer_note;
        PROCEDURE crspl_ins_teach_resp (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE )
        AS
                v_teach_resp_rec                IGS_PS_TCH_RESP%ROWTYPE;
                CURSOR  c_teach_resp_rec IS
                        SELECT  *
                        FROM    IGS_PS_TCH_RESP
                        WHERE   unit_cd = p_unit_cd AND
                                version_number = p_version_number;

        BEGIN
                FOR v_teach_resp_rec IN c_teach_resp_rec LOOP
                        BEGIN
                        x_rowid :=      NULL;
                        IGS_PS_TCH_RESP_PKG.Insert_Row(
                                                X_ROWID             =>          x_rowid,
                                                X_UNIT_CD           =>          p_new_unit_cd,
                                                X_VERSION_NUMBER    =>          p_new_version_number,
                                                X_OU_START_DT       =>          v_teach_resp_rec.ou_start_dt,
                                                X_ORG_UNIT_CD       =>          v_teach_resp_rec.org_unit_cd,
                                                X_PERCENTAGE        =>          v_teach_resp_rec.percentage,
                                                X_MODE              =>          'R');
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_teach_resp;
        PROCEDURE crspl_ins_unit_discipline (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE )
        AS
                v_unit_discipline_rec           IGS_PS_UNIT_DSCP%ROWTYPE;
                CURSOR  c_unit_discipline_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_DSCP
                        WHERE   unit_cd = p_unit_cd AND
                                version_number = p_version_number;

        BEGIN
                FOR v_unit_discipline_rec IN c_unit_discipline_rec LOOP
                        BEGIN
                                x_rowid :=      NULL;
                                IGS_PS_UNIT_DSCP_PKG.Insert_Row(
                                                        X_ROWID               => x_rowid,
                                                        X_UNIT_CD             => p_new_unit_cd,
                                                        X_VERSION_NUMBER      => p_new_version_number,
                                                        X_DISCIPLINE_GROUP_CD => v_unit_discipline_rec.discipline_group_cd,
                                                        X_PERCENTAGE          => v_unit_discipline_rec.percentage,
                                                        X_MODE                => 'R');
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_discipline;
        PROCEDURE crspl_ins_unit_categorisation (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE )
        AS
                v_unit_cat_rec                  IGS_PS_UNIT_CATEGORY%ROWTYPE;
                CURSOR  c_unit_cat_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_CATEGORY
                        WHERE   unit_cd = p_unit_cd AND
                                version_number = p_version_number;

                        l_org_id                        NUMBER(15);

        BEGIN
                FOR v_unit_cat_rec IN c_unit_cat_rec LOOP
                        BEGIN
                                x_rowid :=      NULL;
                                l_org_id := igs_ge_gen_003.get_org_id;

                                IGS_PS_UNIT_CATEGORY_PKG.Insert_Row(
                                                        X_ROWID              => x_rowid,
                                                        X_UNIT_CD            => p_new_unit_cd,
                                                        X_VERSION_NUMBER     => p_new_version_number,
                                                        X_UNIT_CAT           => v_unit_cat_rec.unit_cat,
                                                        X_MODE               => 'R',
                                                        X_ORG_ID             => l_org_id);

                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_categorisation;
        PROCEDURE crspl_ins_crs_unit_lvl (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE )
        AS
                v_crs_unit_lvl_rec              IGS_PS_UNIT_LVL%ROWTYPE;
                CURSOR  c_crs_unit_lvl_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_LVL
                        WHERE   unit_cd = p_unit_cd AND
                                version_number = p_version_number;

        l_org_id                        NUMBER(15);

        BEGIN
                FOR v_crs_unit_lvl_rec IN c_crs_unit_lvl_rec LOOP
                        BEGIN
                                x_rowid :=      NULL;

                                l_org_id := igs_ge_gen_003.get_org_id;
  -- ijeddy, Bug# 3181938 removed course_type from the parameters.
                                IGS_PS_UNIT_LVL_PKG.Insert_Row(
                                                        X_ROWID                   =>   x_rowid,
                                                        X_UNIT_CD                 =>   p_new_unit_cd,
                                                        X_VERSION_NUMBER          =>   p_new_version_number,
                                                        X_UNIT_LEVEL              =>   v_crs_unit_lvl_rec.unit_level,
                                                        X_WAM_WEIGHTING           =>   v_crs_unit_lvl_rec.wam_weighting,
                                                        X_MODE                    =>   'R',
                                                        X_ORG_ID                  =>    l_org_id,
                                                        X_COURSE_CD               =>   v_crs_unit_lvl_rec.course_cd,
                                                        X_COURSE_VERSION_NUMBER   =>   v_crs_unit_lvl_rec.course_version_number
                                                        );

                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_crs_unit_lvl;
        PROCEDURE crspl_ins_unit_ref_cd (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE )
        AS
                v_unit_ref_cd_rec               IGS_PS_UNIT_REF_CD%ROWTYPE;
                CURSOR  c_unit_ref_cd_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_REF_CD
                        WHERE   unit_cd = p_unit_cd AND
                                version_number = p_version_number;
        BEGIN
                FOR v_unit_ref_cd_rec IN c_unit_ref_cd_rec LOOP
                        BEGIN
                                x_rowid :=NULL;
                                IGS_PS_UNIT_REF_CD_PKG.Insert_Row(
                                                X_ROWID              => x_rowid,
                                                X_UNIT_CD            => p_new_unit_cd,
                                                X_VERSION_NUMBER     => p_new_version_number,
                                                X_REFERENCE_CD_TYPE  => v_unit_ref_cd_rec.reference_cd_type,
                                                X_REFERENCE_CD       => v_unit_ref_cd_rec.reference_cd,
                                                X_DESCRIPTION        => v_unit_ref_cd_rec.description,
                                                X_MODE               => 'R');

                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_ref_cd;
        PROCEDURE crspl_ins_unit_off_opt_note (
                p_exist_uoo_id          IN      IGS_PS_UNT_OFR_OPT_N.uoo_id%TYPE,
                p_new_uoo_id            IN      IGS_PS_UNT_OFR_OPT_N.uoo_id%TYPE )
        AS
                v_unit_offer_opt_note_rec       IGS_PS_UNT_OFR_OPT_N%ROWTYPE;
                v_new_ref_number                IGS_PS_UNT_OFR_OPT_N.reference_number%TYPE;
                v_uoo_id                        IGS_PS_UNT_OFR_OPT_N.uoo_id%TYPE;
                --- The following cursor excludes notes records with NULL values in the
                --- note_text field as this implies that it contains data in the note_ole
                --- field which cannot be copied with the current product limitations.
                CURSOR c_unit_off_opt_note_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNT_OFR_OPT_N uoon
                        WHERE   uoon.uoo_id = p_exist_uoo_id            AND
                                EXISTS (
                                        SELECT  'x'
                                        FROM    IGS_GE_NOTE nte
                                        WHERE   nte.reference_number = uoon.reference_number AND
                                                nte.note_text IS NOT NULL );
        BEGIN
                FOR v_unit_offer_opt_note_rec IN c_unit_off_opt_note_rec LOOP
                        crspl_ins_duplicate_note(
                                v_unit_offer_opt_note_rec.reference_number,
                                v_new_ref_number);
                        BEGIN
                                x_rowid :=      NULL;
                                v_uoo_id := p_new_uoo_id;
                                IGS_PS_UNT_OFR_OPT_N_PKG.INSERT_ROW(
                                        X_ROWID                 =>      x_rowid,
                                        X_UNIT_CD               =>      p_new_unit_cd,
                                        X_VERSION_NUMBER        =>      p_new_version_number,
                                        X_CI_SEQUENCE_NUMBER    =>      v_unit_offer_opt_note_rec.ci_sequence_number,
                                        X_UNIT_CLASS            =>      v_unit_offer_opt_note_rec.unit_class,
                                        X_REFERENCE_NUMBER      =>      v_new_ref_number,
                                        X_LOCATION_CD           =>      v_unit_offer_opt_note_rec.location_cd,
                                        X_CAL_TYPE              =>      v_unit_offer_opt_note_rec.cal_type,
                                        X_UOO_ID                =>      v_uoo_id,
                                        X_CRS_NOTE_TYPE         =>      v_unit_offer_opt_note_rec.crs_note_type,
                                        X_MODE                  =>      'R'
                                        );
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_off_opt_note;
        PROCEDURE crspl_ins_teach_resp_ovrd(
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE,
                p_cal_type              IN      IGS_PS_UNIT_OFR_OPT.cal_type%TYPE,
                p_ci_sequence_number    IN      IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE,
                p_location_cd           IN      IGS_PS_UNIT_OFR_OPT.location_cd%TYPE,
                p_unit_class            IN      IGS_PS_UNIT_OFR_OPT.unit_class%TYPE,
                p_new_uoo_id            IN      IGS_PS_UNT_OFR_OPT_N.uoo_id%TYPE)
        AS
                CURSOR c_tro IS
                        SELECT  tro.location_cd,
                                tro.unit_class,
                                tro.org_unit_cd,
                                tro.ou_start_dt,
                                tro.percentage
                        FROM    IGS_PS_TCH_RESP_OVRD tro
                        WHERE   tro.unit_cd             = p_unit_cd             AND
                                tro.version_number      = p_version_number      AND
                                tro.cal_type            = p_cal_type            AND
                                tro.ci_sequence_number  = p_ci_sequence_number  AND
                                tro.location_cd         = p_location_cd         AND
                                tro.unit_class          = p_unit_class;

                l_org_id                        NUMBER(15);
        BEGIN
                FOR c_tro_rec in c_tro LOOP
                        -- copy old IGS_PS_UNIT_VER IGS_PS_TCH_RESP_OVRD details to
                        -- new IGS_PS_UNIT-version
                        BEGIN
                                x_rowid :=      NULL;

                                l_org_id := igs_ge_gen_003.get_org_id;

                                IGS_PS_TCH_RESP_OVRD_PKG.INSERT_ROW(
                                        X_ROWID                =>               x_rowid,
                                        X_UNIT_CD              =>               p_new_unit_cd,
                                        X_VERSION_NUMBER       =>               p_new_version_number,
                                        X_LOCATION_CD          =>               c_tro_rec.location_cd,
                                        X_CI_SEQUENCE_NUMBER   =>               p_ci_sequence_number,
                                        X_CAL_TYPE             =>               p_cal_type,
                                        X_UNIT_CLASS           =>               c_tro_rec.unit_class,
                                        X_OU_START_DT          =>               c_tro_rec.ou_start_dt,
                                        X_ORG_UNIT_CD          =>               c_tro_rec.org_unit_cd,
                                        X_UOO_ID               =>               p_new_uoo_id,
                                        X_PERCENTAGE           =>               c_tro_rec.percentage,
                                        X_MODE                 =>               'R',
                                        X_ORG_ID               =>                l_org_id);
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_teach_resp_ovrd;


        PROCEDURE crspl_upd_usec_relation( p_old_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                   p_new_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE) AS
        /*----------------------------------------------------------------------------
        ||  Created By :sarakshi
        ||  Created On :17-oct-2003
        ||  Purpose :For Rolling over the unit section relationship
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
	||  sarakshi   13-Jan-2006  Bug#4926548, modified cursor c_new_sub and c_new_sup performance issue
        ||  sarakshi   17-Nov-2005  Bug#4726940, impact of change of signature of the update_usec_record
        ----------------------------------------------------------------------------*/
          l_c_none        VARCHAR2(10);
          l_c_superior    VARCHAR2(10);
          l_c_subordinate VARCHAR2(15);
          l_c_active      VARCHAR2(10);
          l_c_planned     VARCHAR2(10);

    CURSOR c_old_sub IS
    SELECT *
    FROM   igs_ps_unit_ofr_opt
    WHERE  relation_type = l_c_subordinate
    AND    sup_uoo_id = p_old_uoo_id;

    CURSOR c_old_sup IS
    SELECT *
    FROM   igs_ps_unit_ofr_opt
    WHERE  relation_type = l_c_superior
    AND    uoo_id  = (SELECT sup_uoo_id
          FROM igs_ps_unit_ofr_opt
          WHERE uoo_id = p_old_uoo_id
         );

    CURSOR c_new_sub(cp_cal_type            igs_ps_unit_ofr_opt_all.cal_type%TYPE,
         cp_ci_sequence_number  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE,
         cp_location_cd         igs_ps_unit_ofr_opt_all.location_cd%TYPE,
         cp_unit_class          igs_ps_unit_ofr_opt_all.unit_class%TYPE,
         cp_unit_cd             igs_ps_unit_ofr_opt_all.unit_cd%TYPE,
         cp_version_number      igs_ps_unit_ofr_opt_all.version_number%TYPE
        )IS
    SELECT uoo.*
    FROM  igs_ps_unit_ofr_opt_all uoo,igs_ps_unit_ver_all  uv, igs_ps_unit_stat us
    WHERE uoo.cal_type           = cp_cal_type
    AND   uoo.ci_sequence_number = cp_ci_sequence_number
    AND   uoo.location_cd        = cp_location_cd
    AND   uoo.unit_class         = cp_unit_class
    AND   uoo.unit_cd            = cp_unit_cd
    AND   uoo.version_number     > cp_version_number
    AND   uoo.unit_cd=uv.unit_cd
    AND   uoo.version_number=uv.version_number
    AND   uv.unit_status = us.unit_status
    AND   us.s_unit_status IN (l_c_active,l_c_planned)
    AND   uoo.relation_type = l_c_none
    AND   uoo_id NOT IN (SELECT uoo_id FROM igs_en_su_attempt)
    ORDER BY uoo.unit_cd,uoo.version_number ASC;

    CURSOR c_new_sup(cp_cal_type            igs_ps_unit_ofr_opt_all.cal_type%TYPE,
         cp_ci_sequence_number  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE,
         cp_location_cd         igs_ps_unit_ofr_opt_all.location_cd%TYPE,
         cp_unit_class          igs_ps_unit_ofr_opt_all.unit_class%TYPE,
         cp_unit_cd             igs_ps_unit_ofr_opt_all.unit_cd%TYPE,
         cp_version_number      igs_ps_unit_ofr_opt_all.version_number%TYPE
        )IS
    SELECT uoo.*
    FROM   igs_ps_unit_ofr_opt_all uoo,igs_ps_unit_ver_all  uv, igs_ps_unit_stat us
    WHERE uoo.cal_type           = cp_cal_type
    AND   uoo.ci_sequence_number = cp_ci_sequence_number
    AND   uoo.location_cd        = cp_location_cd
    AND   uoo.unit_class         = cp_unit_class
    AND   uoo.unit_cd            = cp_unit_cd
    AND   uoo.version_number     > cp_version_number
    AND   uoo.unit_cd=uv.unit_cd
    AND   uoo.version_number=uv.version_number
    AND   uv.unit_status = us.unit_status
    AND   us.s_unit_status IN (l_c_active,l_c_planned)
    AND   uoo_id NOT IN (SELECT uoo_id FROM igs_en_su_attempt)
    AND   uoo.relation_type IN (l_c_superior,l_c_none)
    ORDER BY uoo.unit_cd,uoo.version_number ASC;

    l_c_new_sub  c_new_sub%ROWTYPE;
      l_c_new_sup  c_new_sup%ROWTYPE;

  BEGIN
    --Initilizing this as it was giving gscc warning File.Sql.35
    l_c_none        := 'NONE';
    l_c_superior    := 'SUPERIOR';
    l_c_subordinate := 'SUBORDINATE';
    l_c_active      := 'ACTIVE';
    l_c_planned     := 'PLANNED';

    --Process all subordinates that is fetched from above cursor c_old_sub
    FOR l_old_sub_rec IN c_old_sub LOOP

      --A cursor to get the new version of  subordinate record
      OPEN c_new_sub(l_old_sub_rec.cal_type,l_old_sub_rec.ci_sequence_number,l_old_sub_rec.location_cd,l_old_sub_rec.unit_class,l_old_sub_rec.unit_cd,l_old_sub_rec.version_number);
      FETCH c_new_sub INTO l_c_new_sub;
      IF c_new_sub%FOUND THEN
        CLOSE c_new_sub;

        --Update the new subordinate unit section record
        update_usec_record (p_uoo_id        =>  l_c_new_sub.uoo_id,
          p_relation_type =>  l_c_subordinate,
          p_sup_uoo_id    =>  p_new_uoo_id,
	  p_default_enroll_flag => l_old_sub_rec.default_enroll_flag);

        --Update the new superior unit section record
        update_usec_record (p_uoo_id        =>  p_new_uoo_id,
          p_relation_type => l_c_superior,
          p_sup_uoo_id    =>  NULL,
	  p_default_enroll_flag => NULL);
      ELSE
        CLOSE c_new_sub;
        --Add the unsuccessful unit section's unit to the out variable to display it in the form
        IF p_c_message_superior IS NOT NULL THEN
            p_c_message_superior := p_c_message_superior ||','||l_old_sub_rec.unit_cd;
        ELSE
                p_c_message_superior := l_old_sub_rec.unit_cd;
              END IF;
      END IF;

    END LOOP;

    --Process all superior that is fetched from above cursor c_old_sup
    FOR l_old_sup_rec IN c_old_sup LOOP

      --A cursor to get the new version of  subordinate record
      OPEN c_new_sup(l_old_sup_rec.cal_type,l_old_sup_rec.ci_sequence_number,l_old_sup_rec.location_cd,l_old_sup_rec.unit_class,l_old_sup_rec.unit_cd,l_old_sup_rec.version_number);
      FETCH c_new_sup INTO l_c_new_sup;
      IF c_new_sup%FOUND THEN
        CLOSE c_new_sup;

            --Update the new superior unit section record
        update_usec_record (p_uoo_id        =>  l_c_new_sup.uoo_id,
          p_relation_type =>  l_c_superior,
          p_sup_uoo_id    =>  NULL ,
	  p_default_enroll_flag => NULL);

        --Update the new subordinate unit section record
        update_usec_record (p_uoo_id        =>  p_new_uoo_id,
          p_relation_type =>  l_c_subordinate,
          p_sup_uoo_id    =>  l_c_new_sup.uoo_id,
	  p_default_enroll_flag => NULL );
      ELSE
        CLOSE c_new_sup;
        --Add the unsuccessful unit section's unit to the out variable to display it in the form
        IF p_c_message_superior IS NOT NULL THEN
            p_c_message_superior := p_c_message_superior ||','||l_old_sup_rec.unit_cd;
        ELSE
                p_c_message_superior := l_old_sup_rec.unit_cd;
              END IF;
      END IF;

    END LOOP;

  END crspl_upd_usec_relation;


        PROCEDURE crspl_ins_unit_off_opt (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE,
                p_cal_type              IN      IGS_PS_UNIT_OFR_OPT.cal_type%TYPE,
                p_ci_sequence_number    IN      IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE )
        AS
        /*
        WHO      WHEN        WHAT
	sarakshi 14-oct-2004 Bug#3945817, passsing unit section status as mentioned in the bug.
	sarakshi 31-AUG-2004 Bug#3864738,passed unit_section_status as OPEN in the insert row call of IGS_PS_UNIT_OFR_OPT
	sarakshi 13-Apr-2004 Bug#3555871, removed the logic of getting the call number for AUTO profile option.
        sarakshi 17-oct-2003 Enh#3168650,Added call to the procedure crspl_upd_usec_relation
        sarakshi 23-sep-2003 Enh#3052452,Added column sup_uoo_id,relation_type,default_enroll_flag to the call of igs_ps_unit_ofr_opt_pkg.insert_row
        vvutukur 05-aug-2003 Enh#3045069.PSP Enh Build. Modified the call to igs_ps_unit_ofr_opt_pkg.insert_row to added new column not_multiple_section_flag.
        sarakshi 18-Apr-2003 Bug#2910695,passed actual_enrollment and actual_waitlist null in the table IGS_PS_OFR_OPT_ALL
        sarakshi 05-Mar-2003 bug#2768783,added logic for checking/generating the call number
        */
                v_unit_offer_opt_rec            IGS_PS_UNIT_OFR_OPT%ROWTYPE;
                v_new_uoo_id                    IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
                v_latest_gs_version             IGS_PS_UNIT_OFR_OPT.gs_version_number%TYPE;
                CURSOR  c_unit_offer_opt_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_OFR_OPT
                        WHERE   unit_cd         = p_unit_cd             AND
                                version_number  = p_version_number      AND
                                cal_type        = p_cal_type            AND
                                ci_sequence_number = p_ci_sequence_number;
                CURSOR c_latest_gs_version (
                                cp_gs_cd                IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE) IS
                        SELECT  MAX(gs.version_number)
                        FROM    IGS_AS_GRD_SCHEMA       gs
                        WHERE   gs.grading_schema_cd    = cp_gs_cd;

                        l_org_id        NUMBER(15);
                        l_c_usec_status igs_ps_unit_ofr_opt_all.unit_section_status%TYPE;
        BEGIN
                FOR v_unit_offer_opt_rec IN c_unit_offer_opt_rec LOOP
                        -- get the last version number for grading schema cd
                        OPEN c_latest_gs_version (
                                        v_unit_offer_opt_rec.grading_schema_cd);
                        FETCH c_latest_gs_version INTO v_latest_gs_version;
                        CLOSE c_latest_gs_version;
                        BEGIN
                                SELECT  IGS_PS_UNIT_OFR_OPT_UOO_ID_S.nextval
                                INTO    v_new_uoo_id
                                FROM    dual;
                                x_rowid :=      NULL;

                                l_org_id := igs_ge_gen_003.get_org_id;
                                -- Added auditable_ind, audit_permission_ind parameters to the following call to insert_row
                                -- as part of Bug# 2636716, EN Integration by shtatiko.

                                --bug#2768783, added the validate/generate call number logic

                                -- Validate/generate Call Number
                                IF fnd_profile.value('IGS_PS_CALL_NUMBER') IN ('AUTO','NONE') THEN
                                   v_unit_offer_opt_rec.call_number:=NULL;
                                ELSIF ( fnd_profile.value('IGS_PS_CALL_NUMBER') = 'USER_DEFINED' ) THEN

                                  IF v_unit_offer_opt_rec.call_number IS NOT NULL THEN
                                    IF NOT igs_ps_unit_ofr_opt_pkg.check_call_number ( p_teach_cal_type     => v_unit_offer_opt_rec.cal_type,
                                                                                       p_teach_sequence_num => v_unit_offer_opt_rec.ci_sequence_number,
                                                                                       p_call_number        => v_unit_offer_opt_rec.call_number,
                                                                                       p_rowid              => x_rowid ) THEN
                                       v_unit_offer_opt_rec.call_number:=NULL;
                                    END IF;
                                  END IF;

				END IF;

                                l_c_usec_status := get_section_status(v_unit_offer_opt_rec.unit_section_status);

                                IGS_PS_UNIT_OFR_OPT_PKG.INSERT_ROW(
                                        X_ROWID                       =>        x_rowid,
                                        X_UNIT_CD                     =>        p_new_unit_cd,
                                        X_VERSION_NUMBER              =>        P_new_version_number,
                                        X_CAL_TYPE                    =>        v_unit_offer_opt_rec.cal_type,
                                        X_CI_SEQUENCE_NUMBER          =>        v_unit_offer_opt_rec.ci_sequence_number,
                                        X_LOCATION_CD                 =>        v_unit_offer_opt_rec.location_cd,
                                        X_UNIT_CLASS                  =>        v_unit_offer_opt_rec.unit_class,
                                        X_UOO_ID                      =>        v_new_uoo_id,
                                        X_IVRS_AVAILABLE_IND          =>        v_unit_offer_opt_rec.ivrs_available_ind,
                                        X_CALL_NUMBER                 =>        v_unit_offer_opt_rec.call_number,
                                        X_UNIT_SECTION_STATUS         =>        l_c_usec_status,
                                        X_UNIT_SECTION_START_DATE     =>        v_unit_offer_opt_rec.unit_section_start_date,
                                        X_UNIT_SECTION_END_DATE       =>        v_unit_offer_opt_rec.unit_section_end_date,
                                        X_ENROLLMENT_ACTUAL           =>        NULL,
                                        X_WAITLIST_ACTUAL             =>        NULL,
                                        X_OFFERED_IND                 =>        v_unit_offer_opt_rec.offered_ind,
                                        X_STATE_FINANCIAL_AID         =>        v_unit_offer_opt_rec.state_financial_aid,
                                        X_GRADING_SCHEMA_PRCDNCE_IND  =>        v_unit_offer_opt_rec.grading_schema_prcdnce_ind,
                                        X_FEDERAL_FINANCIAL_AID       =>        v_unit_offer_opt_rec.federal_financial_aid,
                                        X_UNIT_QUOTA                  =>        v_unit_offer_opt_rec.unit_quota,
                                        X_UNIT_QUOTA_RESERVED_PLACES  =>        v_unit_offer_opt_rec.unit_quota_reserved_places,
                                        X_INSTITUTIONAL_FINANCIAL_AID =>        v_unit_offer_opt_rec.institutional_financial_aid,
                                        X_GRADING_SCHEMA_CD           =>        v_unit_offer_opt_rec.grading_schema_cd,
                                        X_GS_VERSION_NUMBER           =>        v_latest_gs_version,
                                        X_UNIT_CONTACT                =>        v_unit_offer_opt_rec.unit_contact,
                                        X_MODE                        =>        'R',
                                        X_ORG_ID                      =>        l_org_id,
                                        x_ss_enrol_ind                =>        v_unit_offer_opt_rec.ss_enrol_ind,
                                        x_ss_display_ind              =>        v_unit_offer_opt_rec.ss_display_ind, --Added by apelleti as per the DLD PSP001-US
                                        X_OWNER_ORG_UNIT_CD           =>        v_unit_offer_opt_rec.owner_org_unit_cd,  -- Added By Pradhakr as per DLD PSP001-US
                                        X_ATTENDANCE_REQUIRED_IND     =>        v_unit_offer_opt_rec.attendance_required_ind,
                                        X_RESERVED_SEATING_ALLOWED    =>        v_unit_offer_opt_rec.reserved_seating_allowed,
                                        X_SPECIAL_PERMISSION_IND      =>        v_unit_offer_opt_rec.special_permission_ind,
                                        X_DIR_ENROLLMENT              =>        v_unit_offer_opt_rec.dir_enrollment,  -- The following three fields were added by Pradhakr
                                        X_ENR_FROM_WLST               =>        v_unit_offer_opt_rec.enr_from_wlst,   -- as part of Enrollment Build process (Enh.Bug# 1832130)
                                        X_INQ_NOT_WLST                =>        v_unit_offer_opt_rec.inq_not_wlst,
-- msrinivi 16 Aug,2001 : Added the following col according to bug 1882122
                                        x_rev_account_cd              =>        v_unit_offer_opt_rec.rev_account_cd ,
                                        x_anon_unit_grading_ind       =>        v_unit_offer_opt_rec.anon_unit_grading_ind ,
                                        x_anon_assess_grading_ind     =>        v_unit_offer_opt_rec.anon_assess_grading_ind ,
                                        x_non_std_usec_ind            =>        v_unit_offer_opt_rec.non_std_usec_ind,
                                        x_auditable_ind               =>        v_unit_offer_opt_rec.auditable_ind,
                                        x_audit_permission_ind        =>        v_unit_offer_opt_rec.audit_permission_ind,
                                        x_not_multiple_section_flag   =>        v_unit_offer_opt_rec.not_multiple_section_flag,
                                        x_sup_uoo_id                  =>        NULL,
                                        x_relation_type               =>        'NONE',
                                        x_default_enroll_flag         =>        v_unit_offer_opt_rec.default_enroll_flag,
				        x_abort_flag                  =>        'N'
                                        );

                                crspl_upd_usec_relation(v_unit_offer_opt_rec.uoo_id,v_new_uoo_id);

                                crspl_ins_unit_off_opt_note(
                                                v_unit_offer_opt_rec.uoo_id,
                                                v_new_uoo_id);
                                crspl_ins_teach_resp_ovrd(
                                                v_unit_offer_opt_rec.unit_cd,
                                                v_unit_offer_opt_rec.version_number,
                                                v_unit_offer_opt_rec.cal_type,
                                                v_unit_offer_opt_rec.ci_sequence_number,
                                                v_unit_offer_opt_rec.location_cd,
                                                v_unit_offer_opt_rec.unit_class,
                                                v_new_uoo_id);
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                IF (c_latest_gs_version%ISOPEN) THEN
                                                        CLOSE c_latest_gs_version;
                                                END IF;
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                IF (c_latest_gs_version%ISOPEN) THEN
                                        CLOSE c_latest_gs_version;
                                END IF;
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_off_opt;

        PROCEDURE crspl_ins_unit_assmnt_item (
                p_unit_cd               IN      IGS_AS_UNITASS_ITEM.unit_cd%TYPE,
                p_version_number        IN      IGS_AS_UNITASS_ITEM.version_number%TYPE,
                p_cal_type              IN      IGS_AS_UNITASS_ITEM.cal_type%TYPE,
                p_ci_sequence_number    IN      IGS_AS_UNITASS_ITEM.ci_sequence_number%TYPE )
        AS
                v_assessment_unit_rec           IGS_AS_UNITASS_ITEM%ROWTYPE;
                v_new_sequence_number           IGS_AS_UNITASS_ITEM.sequence_number%TYPE;

		CURSOR cur_unit_ass_group(cp_unit_cd            igs_as_unit_ai_grp.unit_cd%TYPE,
                                          cp_version_number     igs_as_unit_ai_grp.version_number%TYPE,
			                  cp_cal_type           igs_as_unit_ai_grp.cal_type%TYPE,
			                  cp_ci_sequence_number igs_as_unit_ai_grp.ci_sequence_number%TYPE) IS
                SELECT  *
                FROM    igs_as_unit_ai_grp
                WHERE   unit_cd=cp_unit_cd
                AND     version_number=cp_version_number
                AND     cal_type = cp_cal_type
                AND     ci_sequence_number=cp_ci_sequence_number;

                CURSOR  c_unit_assessment_item(cp_unit_ass_item_group_id igs_as_unitass_item.unit_ass_item_group_id%TYPE) IS
                        SELECT  *
                        FROM    IGS_AS_UNITASS_ITEM     uai
                        WHERE   uai.unit_cd             = p_unit_cd                    AND
                                uai.version_number      = p_version_number             AND
                                uai.cal_type            = p_cal_type                   AND
                                uai.ci_sequence_number  = p_ci_sequence_number         AND
				uai.unit_ass_item_group_id = cp_unit_ass_item_group_id AND
                                uai.logical_delete_dt   IS NULL;
                CURSOR cur_latest_gs_ver (cp_grad_schema_cd IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE) IS
                SELECT max(gs.version_number) maxm
                FROM igs_as_grd_schema gs
                WHERE gs.grading_schema_cd = cp_grad_schema_cd;

                l_message_name  fnd_new_messages.message_name%TYPE;
                v_latest_gs_ver cur_latest_gs_ver%ROWTYPE;
                l_unit_ass_item_id igs_as_unitass_item_all.unit_ass_item_id%TYPE;

        BEGIN
                -- Assigning initial values to local variables which were being initialised using DEFAULT
                -- clause.Done as part of bug #2563596 to remove GSCC warning.
                l_message_name := NULL;

                FOR cur_unit_ass_group_rec  IN  cur_unit_ass_group(p_unit_cd,p_version_number,p_cal_type,p_ci_sequence_number) LOOP
                  DECLARE
                    l_rowid                         VARCHAR2(25);
                    l_unit_ass_item_group_id        NUMBER;
                  BEGIN
                    l_rowid :=NULL;
                    l_unit_ass_item_group_id := NULL;

                    igs_as_unit_ai_grp_pkg.insert_row(
                       x_rowid                   => l_rowid,
                       x_unit_ass_item_group_id  => l_unit_ass_item_group_id,
                       x_unit_cd                 => p_new_unit_cd,
                       x_version_number          => p_new_version_number,
                       x_cal_type                => cur_unit_ass_group_rec.cal_type,
                       x_ci_sequence_number      => cur_unit_ass_group_rec.ci_sequence_number,
                       x_group_name              => cur_unit_ass_group_rec.group_name,
                       x_midterm_formula_code    => cur_unit_ass_group_rec.midterm_formula_code,
                       x_midterm_formula_qty     => cur_unit_ass_group_rec.midterm_formula_qty,
                       x_midterm_weight_qty      => cur_unit_ass_group_rec.midterm_weight_qty,
                       x_final_formula_code      => cur_unit_ass_group_rec.final_formula_code,
                       x_final_formula_qty       => cur_unit_ass_group_rec.final_formula_qty,
                       x_final_weight_qty        => cur_unit_ass_group_rec.final_weight_qty
                    );


                    FOR v_unit_assessment_item_rec IN c_unit_assessment_item(cur_unit_ass_group_rec.unit_ass_item_group_id) LOOP
                        BEGIN
                                --
                                -- If grading schema is in the current or future,
                                -- continue validation
                                --
                                l_message_name := NULL;
                                OPEN cur_latest_gs_ver(v_unit_assessment_item_rec.grading_schema_cd);
                                FETCH cur_latest_gs_ver INTO v_latest_gs_ver;
                                CLOSE cur_latest_gs_ver;
                                IF (IGS_AS_VAL_GSG.assp_val_gs_cur_fut(
                                        v_unit_assessment_item_rec.grading_schema_cd,
                                        v_latest_gs_ver.maxm,
                                        l_message_name) = TRUE) THEN
                                  --
                                  --  End of the latest version check of Grading Schema.
                                  --
                                  SELECT        IGS_AS_UNITASS_ITEM_SEQ_NUM_S.nextval
                                  INTO  v_new_sequence_number
                                  FROM  dual;
                                  x_rowid       :=      NULL;
                                  l_unit_ass_item_id := NULL;

                                  IGS_AS_UNITASS_ITEM_PKG.INSERT_ROW(
                                    X_ROWID                         => x_rowid,
                                    X_UNIT_CD                       => p_new_unit_cd,
                                    X_VERSION_NUMBER                => p_new_version_number,
                                    X_CAL_TYPE                      => v_unit_assessment_item_rec.cal_type,
                                    X_CI_SEQUENCE_NUMBER            => v_unit_assessment_item_rec.ci_sequence_number,
                                    X_ASS_ID                        => v_unit_assessment_item_rec.ass_id,
                                    X_SEQUENCE_NUMBER               => v_new_sequence_number,
                                    X_CI_START_DT                   => v_unit_assessment_item_rec.ci_start_dt,
                                    X_CI_END_DT                     => v_unit_assessment_item_rec.ci_end_dt,
                                    X_UNIT_CLASS                    => v_unit_assessment_item_rec.unit_class,
                                    X_UNIT_MODE                     => v_unit_assessment_item_rec.unit_mode,
                                    X_LOCATION_CD                   => v_unit_assessment_item_rec.location_cd,
                                    X_DUE_DT                        => v_unit_assessment_item_rec.due_dt,
                                    X_REFERENCE                     => v_unit_assessment_item_rec.reference,
                                    X_DFLT_ITEM_IND                 => v_unit_assessment_item_rec.dflt_item_ind,
                                    X_LOGICAL_DELETE_DT             => v_unit_assessment_item_rec.logical_delete_dt,
                                    X_ACTION_DT                     => v_unit_assessment_item_rec.action_dt,
                                    X_EXAM_CAL_TYPE                 => v_unit_assessment_item_rec.exam_cal_type,
                                    X_EXAM_CI_SEQUENCE_NUMBER       => v_unit_assessment_item_rec.exam_ci_sequence_number,
                                    X_MODE                          => 'R',
                                    X_ORG_ID                        => igs_ge_gen_003.get_org_id,
                                    X_GRADING_SCHEMA_CD             => v_unit_assessment_item_rec.grading_schema_cd,
                                    X_GS_VERSION_NUMBER             => v_unit_assessment_item_rec.gs_version_number,
                                    X_RELEASE_DATE                  => v_unit_assessment_item_rec.release_date,
                                    X_UNIT_ASS_ITEM_ID              => l_unit_ass_item_id, --out parameter
                                    X_DESCRIPTION                   => v_unit_assessment_item_rec.description,
                                    x_unit_ass_item_group_id        => l_unit_ass_item_group_id,
                                    x_midterm_mandatory_type_code   => v_unit_assessment_item_rec.midterm_mandatory_type_code,
                                    x_midterm_weight_qty            => v_unit_assessment_item_rec.midterm_weight_qty,
                                    x_final_mandatory_type_code     => v_unit_assessment_item_rec.final_mandatory_type_code,
                                    x_final_weight_qty              => v_unit_assessment_item_rec.final_weight_qty
                                  );
                                END IF;
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF cur_latest_gs_ver%ISOPEN THEN
                                                CLOSE cur_latest_gs_ver;
                                        ELSIF SQLCODE >= cst_lower_limit_err    AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                    END LOOP;

                  EXCEPTION
                    WHEN OTHERS THEN
                       IF SQLCODE >= cst_lower_limit_err    AND
                          SQLCODE <= cst_upper_limit_err THEN
                          p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                       ELSE
                          App_Exception.Raise_Exception;
                       END IF;
                  END;
                END LOOP;


        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_assmnt_item;
        PROCEDURE crspl_ins_unit_off_pat_note(
                p_unit_cd               IN      IGS_PS_UNT_OFR_PAT_N.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNT_OFR_PAT_N.version_number%TYPE,
                p_cal_type              IN      IGS_PS_UNT_OFR_PAT_N.cal_type%TYPE,
                p_ci_sequence_number    IN      IGS_PS_UNT_OFR_PAT_N.ci_sequence_number%TYPE )
        AS
                v_unit_offer_pat_note_rec       IGS_PS_UNT_OFR_PAT_N%ROWTYPE;
                v_new_ref_number                IGS_PS_UNT_OFR_PAT_N.reference_number%TYPE;
                --- The following cursor excludes notes records with NULL values in the
                --- note_text field as this implies that it contains data in the note_ole
                --- field which cannot be copied with the current product limitations.
                CURSOR c_unit_off_pat_note_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNT_OFR_PAT_N uopn
                        WHERE   uopn.unit_cd            = p_unit_cd             AND
                                uopn.version_number     = p_version_number      AND
                                uopn.cal_type           = p_cal_type            AND
                                uopn.ci_sequence_number = p_ci_sequence_number  AND
                                EXISTS (
                                        SELECT  'x'
                                        FROM    IGS_GE_NOTE nte
                                        WHERE   nte.reference_number    = uopn.reference_number AND
                                                nte.note_text           IS NOT NULL );
        BEGIN
                FOR v_unit_offer_pat_note_rec IN c_unit_off_pat_note_rec LOOP
                        crspl_ins_duplicate_note(
                                v_unit_offer_pat_note_rec.reference_number,
                                v_new_ref_number);
                        BEGIN
                                x_rowid :=      NULL ;
                                IGS_PS_UNT_OFR_PAT_N_PKG.INSERT_ROW(
                                        X_ROWID              =>         x_rowid,
                                        X_UNIT_CD            =>         p_new_unit_cd,
                                        X_REFERENCE_NUMBER   =>         v_new_ref_number,
                                        X_VERSION_NUMBER     =>         p_new_version_number,
                                        X_CAL_TYPE           =>         v_unit_offer_pat_note_rec.cal_type,
                                        X_CI_SEQUENCE_NUMBER =>         v_unit_offer_pat_note_rec.ci_sequence_number,
                                        X_CRS_NOTE_TYPE      =>         v_unit_offer_pat_note_rec.crs_note_type,
                                        X_MODE               =>         'R'
                                        );
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_off_pat_note;

        /* Procedure     : crspl_uofr_wlst_details
         * Purpose       : To copy the waitlist details of the previous unit version offering to the new unit version that is being
         *                 created via the duplication record method.
         * Creation Date : 25 Aug 2000
         * Created By    : Sreenivas.Bonam
         */
        PROCEDURE crspl_uofr_wlist_details(
                p_unit_cd        IN     igs_ps_unit_ver.unit_cd%TYPE,
                p_version_number IN     igs_ps_unit_ver.version_number%TYPE,
		p_cal_type       IN     igs_ps_unit_ofr_pat.cal_type%TYPE,
		p_ci_sequence_number IN igs_ps_unit_ofr_pat.ci_sequence_number%TYPE)
        AS

          CURSOR c_uofr_wlst_pri_det IS
            SELECT *
            FROM igs_ps_uofr_wlst_pri
            WHERE unit_cd = p_unit_cd
            AND   version_number = p_version_number
	    AND   calender_type = p_cal_type
	    AND   ci_sequence_number= p_ci_sequence_number;

          v_unit_ofr_wlist_pri_id  igs_ps_uofr_wlst_pri.unit_ofr_waitlist_priority_id%TYPE;

          CURSOR c_uofr_wlst_prf_det(cp_unit_ofr_wlst_priority_id igs_ps_uofr_wlst_prf.unit_ofr_waitlist_priority_id%TYPE)  IS
            SELECT *
            FROM igs_ps_uofr_wlst_prf
            WHERE unit_ofr_waitlist_priority_id = cp_unit_ofr_wlst_priority_id;
          v_unit_ofr_wlist_prf_id  igs_ps_uofr_wlst_prf.unit_ofr_waitlist_pref_id%TYPE;


        BEGIN

                FOR c_uofr_wlst_pri_rec IN c_uofr_wlst_pri_det
                LOOP
                        x_rowid :=      NULL;
			v_unit_ofr_wlist_pri_id := NULL;
                        igs_ps_uofr_wlst_pri_pkg.Insert_Row(
                                        x_rowid                   => x_rowid,
                                        x_unit_ofr_wl_priority_id => v_unit_ofr_wlist_pri_id,
                                        x_unit_cd                 => p_new_unit_cd,
                                        x_version_number          => p_new_version_number,
                                        x_calender_type           => c_uofr_wlst_pri_rec.calender_type,
                                        x_ci_sequence_number      => c_uofr_wlst_pri_rec.ci_sequence_number,
                                        x_priority_number         => c_uofr_wlst_pri_rec.priority_number,
                                        x_priority_value          => c_uofr_wlst_pri_rec.priority_value,
                                        X_MODE                    => 'R');
                        FOR c_uofr_wlst_prf_rec IN c_uofr_wlst_prf_det(c_uofr_wlst_pri_rec.unit_ofr_waitlist_priority_id)
                        LOOP
			  x_rowid := NULL;
			  v_unit_ofr_wlist_prf_id := NULL;
                          igs_ps_uofr_wlst_prf_pkg.Insert_Row(
                                        x_rowid                   => x_rowid,
                                        x_unit_ofr_wl_pref_id     => v_unit_ofr_wlist_prf_id,
                                        x_unit_ofr_wl_priority_id => v_unit_ofr_wlist_pri_id,
                                        x_preference_order        => c_uofr_wlst_prf_rec.preference_order,
                                        x_preference_code         => c_uofr_wlst_prf_rec.preference_code,
                                        x_preference_version      => c_uofr_wlst_prf_rec.preference_version,
                                        X_MODE                    => 'R');
                        END LOOP;
                END LOOP;

        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_uofr_wlist_details;

        PROCEDURE crspl_ins_unit_off_pat (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE,
                p_cal_type              IN      IGS_PS_UNIT_OFR.cal_type%TYPE )
        AS
                v_unit_offer_pat_rec            IGS_PS_UNIT_OFR_PAT%ROWTYPE;
                --- This cursor is used to select the IGS_PS_UNIT offering pattern with the latest
                --- calendar instance (the join between the two tables is based on having
                --- similar IGS_CA_TYPE).
                CURSOR  c_unit_offer_pat_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_OFR_PAT UOP
                        WHERE   UOP.unit_cd     = p_unit_cd                     AND
                                UOP.version_number = p_version_number           AND
                                UOP.cal_type    = p_cal_type                    AND
				UOP.delete_flag = 'N'                           AND
                                UOP.ci_end_dt   = (
                                                        SELECT  MAX(ci_end_dt)
                                                        FROM    IGS_PS_UNIT_OFR_PAT UOP2
                                                        WHERE   UOP2.unit_cd            = UOP.unit_cd   AND
                                                                UOP2.version_number     = UOP.version_number AND
                                      				UOP2.delete_flag        = 'N'                AND
                                                                UOP2.cal_type           = UOP.cal_type)
                        ORDER BY UOP.ci_end_dt DESC, UOP.ci_start_dt DESC;

        l_org_id  NUMBER(15);

        BEGIN
                OPEN c_unit_offer_pat_rec;
                FETCH c_unit_offer_pat_rec INTO v_unit_offer_pat_rec;
                --- If the record cannot be found, then exit.
                IF c_unit_offer_pat_rec%NOTFOUND THEN
                        CLOSE c_unit_offer_pat_rec;
                        RETURN;
                END IF;
                CLOSE c_unit_offer_pat_rec;
                x_rowid :=      NULL;

                l_org_id := igs_ge_gen_003.get_org_id;

                IGS_PS_UNIT_OFR_PAT_PKG.INSERT_ROW(
                        X_ROWID               =>        x_rowid,
                        X_UNIT_CD             =>        p_new_unit_cd,
                        X_VERSION_NUMBER      =>        p_new_version_number,
                        X_CI_SEQUENCE_NUMBER  =>        v_unit_offer_pat_rec.ci_sequence_number,
                        X_CAL_TYPE            =>        v_unit_offer_pat_rec.cal_type,
                        X_CI_START_DT         =>        v_unit_offer_pat_rec.ci_start_dt,
                        X_CI_END_DT           =>        v_unit_offer_pat_rec.ci_end_dt,
                        X_WAITLIST_ALLOWED    =>      v_unit_offer_pat_rec.waitlist_allowed,
                        X_MAX_STUDENTS_PER_WAITLIST => v_unit_offer_pat_rec.max_students_per_waitlist,
                        X_MODE                =>        'R',
                        X_ORG_ID              => l_org_id,
			X_DELETE_FLAG         => v_unit_offer_pat_rec.delete_flag ,
			x_abort_flag          => 'N'
                        );
                --- Create the relevant notes for this IGS_PS_UNIT offering pattern.
                crspl_ins_unit_off_pat_note(
                                        p_unit_cd,
                                        p_version_number,
                                        v_unit_offer_pat_rec.cal_type,
                                        v_unit_offer_pat_rec.ci_sequence_number );
                --- Check if the IGS_PS_UNIT_OFR_OPT exists for the old IGS_PS_UNIT code and
                --- version number.  If it does exist, create the new record with the
                --- substituted values.
                crspl_ins_unit_off_opt(
                        p_unit_cd,
                        p_version_number,
                        v_unit_offer_pat_rec.cal_type,
                        v_unit_offer_pat_rec.ci_sequence_number );
                --- Check if the unit_asessment_item exists for the old IGS_PS_UNIT code and
                --- version number.  If it does exist, create the new record with the
                --- substituted values.
                crspl_ins_unit_assmnt_item(
                        p_unit_cd,
                        p_version_number,
                        v_unit_offer_pat_rec.cal_type,
                        v_unit_offer_pat_rec.ci_sequence_number );
               --Check if the unit offering pattern waitlist exists then roll the data
               crspl_uofr_wlist_details( p_unit_cd,
	                                 p_version_number,
 	                                 v_unit_offer_pat_rec.cal_type,
                                         v_unit_offer_pat_rec.ci_sequence_number);

        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                IF (c_unit_offer_pat_rec%ISOPEN) THEN
                                        CLOSE c_unit_offer_pat_rec;
                                END IF;
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_off_pat;
        PROCEDURE crspl_ins_unit_offer (
                p_unit_cd               IN      IGS_PS_UNIT_VER.unit_cd%TYPE,
                p_version_number        IN      IGS_PS_UNIT_VER.version_number%TYPE )
        AS
                v_unit_offer_rec                IGS_PS_UNIT_OFR%ROWTYPE;
                CURSOR  c_unit_offer_rec IS
                        SELECT  *
                        FROM    IGS_PS_UNIT_OFR
                        WHERE   unit_cd         = p_unit_cd AND
                                version_number  = p_version_number;
        BEGIN
                FOR v_unit_offer_rec IN c_unit_offer_rec LOOP
                        BEGIN
                                x_rowid :=      NULL;
                                IGS_PS_UNIT_OFR_PKG.INSERT_ROW(
                                        X_ROWID             =>                  x_rowid,
                                        X_UNIT_CD           =>                  p_new_unit_cd,
                                        X_VERSION_NUMBER    =>                  p_new_version_number,
                                        X_CAL_TYPE          =>                  v_unit_offer_rec.cal_type,
                                        X_MODE              =>                  'R'
                                        );
                                --- Check if the IGS_PS_UNIT_OFR_PAT exists for the old IGS_PS_UNIT code and
                                --- version number. If it does exist, create the new record with the
                                --- substituted values.
                                crspl_ins_unit_off_pat(
                                        p_unit_cd,
                                        p_version_number,
                                        v_unit_offer_rec.cal_type);
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF SQLCODE >= cst_lower_limit_err       AND
                                                        SQLCODE <= cst_upper_limit_err THEN
                                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                                        ELSE
                                                App_Exception.Raise_Exception;
                                        END IF;
                        END;
                END LOOP;
        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unit_offer;


        /* Procedure     : crspl_ins_location_details
         * Purpose       : To copy the location details of the previous unit version to the new unit version that is being
         *                 created via the duplication record method.
         * Creation Date : 25 Aug 2000
         * Created By    : Sreenivas.Bonam
         */
        PROCEDURE crspl_ins_location_details(
                p_unit_cd        IN     igs_ps_unit_ver.unit_cd%TYPE,
                p_version_number IN     igs_ps_unit_ver.version_number%TYPE )
        AS
          CURSOR c_unit_loc_det IS
            SELECT *
            FROM igs_ps_unit_location
            WHERE unit_code = p_unit_cd
              AND unit_version_number = p_version_number;
          v_unit_location_id  igs_ps_unit_location.unit_location_id%TYPE;
        BEGIN

                FOR c_unit_loc_rec IN c_unit_loc_det
                LOOP
                        x_rowid :=      NULL;
                        igs_ps_unit_location_pkg.Insert_Row(
                                        x_rowid                 => x_rowid,
                                        x_unit_location_id      => v_unit_location_id,
                                        x_unit_code             => p_new_unit_cd,
                                        x_unit_version_number   => p_new_version_number,
                                        x_location_code         => c_unit_loc_rec.location_code,
                                        x_building_id           => c_unit_loc_rec.building_id,
                                        x_room_id               => c_unit_loc_rec.room_id,
                                        X_MODE                  => 'R');
                END LOOP;

        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_location_details;

        /* Procedure     : crspl_ins_facility_details
         * Purpose       : To copy the facility details of the previous unit version to the new unit version that is being
         *                 created via the duplication record method.
         * Creation Date : 25 Aug 2000
         * Created By    : Sreenivas.Bonam
         */
        PROCEDURE crspl_ins_facility_details(
                p_unit_cd        IN     igs_ps_unit_ver.unit_cd%TYPE,
                p_version_number IN     igs_ps_unit_ver.version_number%TYPE )
        AS
          CURSOR c_unit_fac_det IS
            SELECT *
            FROM igs_ps_unit_facility
            WHERE unit_code = p_unit_cd
              AND unit_version_number = p_version_number;
          v_unit_media_id  igs_ps_unit_facility.unit_media_id%TYPE;
        BEGIN

                FOR c_unit_fac_rec IN c_unit_fac_det
                LOOP
                        x_rowid :=      NULL;
                        igs_ps_unit_facility_pkg.Insert_Row(
                                        x_rowid                 => x_rowid,
                                        x_unit_media_id         => v_unit_media_id,
                                        x_unit_code             => p_new_unit_cd,
                                        x_unit_version_number   => p_new_version_number,
                                        x_media_code            => c_unit_fac_rec.media_code,
                                        X_MODE                  => 'R');
                END LOOP;

        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_facility_details;

        /* Procedure     : crspl_ins_cros_ref_details
         * Purpose       : To copy the cros reference details of the previous unit version to the new unit version that is being
         *                 created via the duplication record method.
         * Creation Date : 25 Aug 2000
         * Created By    : Sreenivas.Bonam
         */
        PROCEDURE crspl_ins_cros_ref_details(
                p_unit_cd        IN     igs_ps_unit_ver.unit_cd%TYPE,
                p_version_number IN     igs_ps_unit_ver.version_number%TYPE )
        AS
          CURSOR c_unit_cros_ref_det IS
            SELECT *
            FROM igs_ps_unit_cros_ref
            WHERE parent_unit_code = p_unit_cd
              AND parent_unit_version_number = p_version_number;
          v_unit_cross_reference_id  igs_ps_unit_cros_ref.unit_cross_reference_id%TYPE;
        BEGIN

                FOR c_unit_cros_ref_rec IN c_unit_cros_ref_det
                LOOP
                        x_rowid :=      NULL;
                        igs_ps_unit_cros_ref_pkg.Insert_Row(
                                        x_rowid                      => x_rowid,
                                        x_unit_cross_reference_id    => v_unit_cross_reference_id,
                                        x_parent_unit_code           => p_new_unit_cd,
                                        x_parent_unit_version_number => p_new_version_number,
                                        x_child_unit_code            => c_unit_cros_ref_rec.child_unit_code,
                                        x_child_unit_version_number  => c_unit_cros_ref_rec.child_unit_version_number,
                                        X_MODE                       => 'R');
                END LOOP;

        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_cros_ref_details;


        /* Procedure     : crspl_ins_grd_schm_details
         * Purpose       : To copy the grading schema details of the previous unit version to the new unit version that is being
         *                 created via the duplication record method.
         * Creation Date : 25 Aug 2000
         * Created By    : Sreenivas.Bonam
         */
        PROCEDURE crspl_ins_grd_schm_details(
                p_unit_cd        IN     igs_ps_unit_ver.unit_cd%TYPE,
                p_version_number IN     igs_ps_unit_ver.version_number%TYPE )
        AS
          CURSOR c_unit_grd_schm_det IS
            SELECT *
            FROM igs_ps_unit_grd_schm
            WHERE unit_code = p_unit_cd
              AND unit_version_number = p_version_number;
          v_unit_grading_schema_id  igs_ps_unit_grd_schm.unit_grading_schema_id%TYPE;
        BEGIN

                FOR c_unit_grd_schm_rec IN c_unit_grd_schm_det
                LOOP
                        x_rowid :=      NULL;
                        igs_ps_unit_grd_schm_pkg.Insert_Row(
                                        x_rowid                   => x_rowid,
                                        x_unit_grading_schema_id  => v_unit_grading_schema_id,
                                        x_unit_code               => p_new_unit_cd,
                                        x_unit_version_number     => p_new_version_number,
                                        x_grading_schema_code     => c_unit_grd_schm_rec.grading_schema_code,
                                        x_grd_schm_version_number => c_unit_grd_schm_rec.grd_schm_version_number,
                                        x_default_flag            => c_unit_grd_schm_rec.default_flag,
                                        X_MODE                    => 'R');
                END LOOP;

        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_grd_schm_details;


        /* Procedure     : crspl_ins_unt_fld_details
         * Purpose       : To copy the field of Study details of the previous unit version to the new unit version that is being
         *                 created via the duplication record method.
         * Creation Date : 25 Aug 2000
         * Created By    : Sreenivas.Bonam
         */
        PROCEDURE crspl_ins_unt_fld_details(
                p_unit_cd        IN     igs_ps_unit_ver.unit_cd%TYPE,
                p_version_number IN     igs_ps_unit_ver.version_number%TYPE )
        AS
          CURSOR c_unit_fld_stdy_det IS
            SELECT *
            FROM igs_ps_unit_fld_stdy
            WHERE unit_code = p_unit_cd
              AND version_number = p_version_number;
          v_unit_field_of_study_id  igs_ps_unit_fld_stdy.unit_field_of_study_id%TYPE;
        BEGIN

                FOR c_unit_fld_stdy_rec IN c_unit_fld_stdy_det
                LOOP
                        x_rowid :=      NULL;
                        igs_ps_unit_fld_stdy_pkg.Insert_Row(
                                        x_rowid                  => x_rowid,
                                        x_unit_field_of_study_id => v_unit_field_of_study_id,
                                        x_unit_code              => p_new_unit_cd,
                                        x_version_number         => p_new_version_number,
                                        x_field_of_study         => c_unit_fld_stdy_rec.field_of_study,
                                        X_MODE                   => 'R');
                END LOOP;

        EXCEPTION
                WHEN OTHERS THEN
                        IF SQLCODE >= cst_lower_limit_err       AND
                                        SQLCODE <= cst_upper_limit_err THEN
                                p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
                        ELSE
                                App_Exception.Raise_Exception;
                        END IF;
        END crspl_ins_unt_fld_details;

        --removed the procedure CRSP_INS_UNIT_REVSEG by vvutukur as part of enh#2831572.

        /* Procedure     : crsp_ins_appr_ass_itm_grd
         * Purpose       : To roll the Approved Assessment Item Grading Schemas
         *                 for the Unit from its existing unit version number
         *                 to next new version number.
         *
         * Creation Date : 03 Jan 2002
         * Created By    : Nishikant
         */
        PROCEDURE crsp_ins_appr_ass_itm_grd(
                p_unit_cd        IN     igs_ps_unit_ver.unit_cd%TYPE,
                p_version_number IN     igs_ps_unit_ver.version_number%TYPE
        )
        AS
        CURSOR c_appr_grd_sch IS
          SELECT  *
          FROM    igs_as_appr_grd_sch
          WHERE   unit_cd = p_unit_cd AND
                  version_number = p_version_number AND
                  closed_ind = 'N';
        CURSOR c_max_ver_grd_sch(
                  p_grading_schema_cd  igs_as_appr_grd_sch.grading_schema_cd%TYPE)
        IS
          SELECT  MAX(version_number)
          FROM    igs_as_grd_schema
          WHERE   grading_schema_cd = p_grading_schema_cd;
        l_appr_grd_sch       igs_as_appr_grd_sch%ROWTYPE;
        l_max_ver_grd_sch    igs_as_grd_schema.version_number%TYPE;
        l_message_name       fnd_new_messages.message_name%TYPE;
        l_rowid              VARCHAR(30);

        BEGIN
          FOR l_appr_grd_sch  IN c_appr_grd_sch
          LOOP
              OPEN  c_max_ver_grd_sch(l_appr_grd_sch.grading_schema_cd);
              FETCH c_max_ver_grd_sch INTO l_max_ver_grd_sch;
              CLOSE c_max_ver_grd_sch;
          -- The function assp_val_gs_cur_fut checks for the new version of
          -- the Grading Schema is current or future and retrns a boolean value.
          -- When call to the following function returns TRUE it inserts the
          -- Approved Grading Schema with the new Unit Version and new Grading
          -- Schema Version if available. Otherwise it should not insert the
          -- Grading Schema for the Unit Version.
                  IF igs_as_val_gsg.assp_val_gs_cur_fut(
                                     l_appr_grd_sch.grading_schema_cd,
                                     l_max_ver_grd_sch,
                                     l_message_name)  THEN
                         l_rowid := NULL;
                         igs_as_appr_grd_sch_pkg.insert_row(
                               x_rowid             => l_rowid,
                               x_unit_cd           => p_new_unit_cd,
                               x_version_number    => p_new_version_number,
                               x_assessment_type   => l_appr_grd_sch.assessment_type,
                               x_grading_schema_cd => l_appr_grd_sch.grading_schema_cd,
                               x_gs_version_number => l_max_ver_grd_sch,
                               x_default_ind       => l_appr_grd_sch.default_ind,
                               x_closed_ind        => 'N',
                               x_mode              => 'R' );
                  END IF;
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
             IF SQLCODE >= cst_lower_limit_err  AND
                SQLCODE <= cst_upper_limit_err THEN
                       p_message_name := 'IGS_PS_FAIL_COPY_PRGVERDETAIL';
             ELSE
                App_Exception.Raise_Exception;
             END IF;
        END crsp_ins_appr_ass_itm_grd;

BEGIN
        --- The purpose of this procedure is to perform a rollover function by
        --- duplicating the details from one IGS_PS_UNIT code / version number combination
        --- to a new IGS_PS_UNIT code / version number combination.  Each local procedure
        --- handles the duplication of data for a table (or group of related tables).
        --- Each local procedure contains an anonymous block around the insert
        --- statement. This is to trap 'acceptable' errors within the defined range
        --- and to continue. This is also the case for the exception handling area
        --- for the whole procedure. Errors outside of this are handled in the usual
        --- way by GENP_LOG_ERROR().

        -- Assigning initial values to local variables which were being initialised using DEFAULT
        -- clause.Done as part of bug #2563596 to remove GSCC warning.
        cst_upper_limit_err := -20000;
        cst_lower_limit_err := -20999;

        DECLARE

                CURSOR  c_new_unit_vers_rec (
                        cp_new_unit_cd          IGS_PS_UNIT_VER.unit_cd%TYPE,
                        cp_new_version_number   IGS_PS_UNIT_VER.version_number%TYPE ) IS
                        SELECT  'x'
                        FROM    IGS_PS_UNIT_VER
                        WHERE   unit_cd         = cp_new_unit_cd AND
                                version_number  = cp_new_version_number;
                CURSOR  c_old_unit_vers_rec (
                        cp_old_unit_cd          IGS_PS_UNIT_VER.unit_cd%TYPE,
                        cp_old_version_number   IGS_PS_UNIT_VER.version_number%TYPE ) IS
                        SELECT  'x'
                        FROM    IGS_PS_UNIT_VER
                        WHERE   unit_cd         = cp_old_unit_cd AND
                                    version_number      = cp_old_version_number;
               l_status NUMBER;

        BEGIN
                --- Set default message number
                p_message_name := 'IGS_PS_SUCCESS_COPY_PRG_VER';
                -- Check if the new IGS_PS_UNIT version exists
                OPEN c_new_unit_vers_rec(
                                p_new_unit_cd,
                                p_new_version_number);
                FETCH c_new_unit_vers_rec INTO gv_unit_version_exist;
                IF c_new_unit_vers_rec%NOTFOUND THEN
                        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                        CLOSE c_new_unit_vers_rec;
                        RETURN;
                END IF;
                CLOSE c_new_unit_vers_rec;
                --- Check if the old IGS_PS_UNIT version exists
                OPEN c_old_unit_vers_rec(
                                p_old_unit_cd,
                                p_old_version_number);
                FETCH c_old_unit_vers_rec INTO gv_unit_version_exist;
                IF c_old_unit_vers_rec%NOTFOUND THEN
                        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                        CLOSE c_old_unit_vers_rec;
                        RETURN;
                END IF;
                CLOSE c_old_unit_vers_rec;
                --- Check if the IGS_PS_UNIT_VER_NOTE record exists for the old IGS_PS_UNIT code and
                --- version number. If it does exist, create the new record with the
                --- substituted values. A new IGS_GE_NOTE record must be created as well.
                crspl_ins_unit_ver_note(
                                p_old_unit_cd,
                                p_old_version_number);
                --- Check if the IGS_PS_TCH_RESP record exists for the old IGS_PS_UNIT code
                --- and version number. If it does exist, create the new record with the
                --- substituted values.
                crspl_ins_teach_resp(
                                p_old_unit_cd,
                                p_old_version_number);
                --- Check if the IGS_PS_UNIT_DSCP record exists for the old IGS_PS_UNIT code and
                --- version number. If it does exist, create the new record with the
                --- substituted values.
                crspl_ins_unit_discipline(
                                p_old_unit_cd,
                                p_old_version_number);
                --- Check if the IGS_PS_UNIT_CATEGORY record exists for the old IGS_PS_UNIT code and
                --- version number. If it does exist, create the new record with the
                --- substituted values.
                crspl_ins_unit_categorisation(
                                p_old_unit_cd,
                                p_old_version_number);
                --- Check if the IGS_PS_UNIT_LVL record exists for the old IGS_PS_UNIT code and
                --- version number. If it does exist, create the new record with the
                --- substituted values.
                crspl_ins_crs_unit_lvl(
                                p_old_unit_cd,
                                p_old_version_number);
                --- Check if the IGS_PS_UNIT_REF_CD exists for the old IGS_PS_UNIT code and version
                --- number. If it does exist, create the new record with the substituted
                --- values.
                crspl_ins_unit_ref_cd(
                                p_old_unit_cd,
                                p_old_version_number);
                --- Check if the IGS_PS_UNIT_OFR exists for the old IGS_PS_UNIT code and version
                --- number. If it does exist, create the new record with the substituted
                --- values.
                crspl_ins_unit_offer(
                                p_old_unit_cd,
                                p_old_version_number);
                --- Check if the IGS_PS_UNIT_OFR_NOTE record exists for the old IGS_PS_UNIT code and
                --- version number. If it does exist, create the new record with the
                --- substituted values. A new IGS_GE_NOTE record must be created as well.
                crspl_ins_unit_offer_note(
                                p_old_unit_cd,
                                p_old_version_number);

                -- The following calls have been added to copy details related to new forms added in 11.5
                -- The code for each of these procedures has been declared above locally
                crspl_ins_location_details(
                                p_old_unit_cd,
                                p_old_version_number);
                crspl_ins_facility_details(
                                p_old_unit_cd,
                                p_old_version_number);
                crspl_ins_cros_ref_details(
                                p_old_unit_cd,
                                p_old_version_number);
                crspl_ins_grd_schm_details(
                                p_old_unit_cd,
                                p_old_version_number);
                crspl_ins_unt_fld_details(
                                p_old_unit_cd,
                                p_old_version_number);
                 --Added by manu according to bug # 1882122, 1 Aug, 2001
                 --removed the call to crsp_ins_unit_revseg by vvutukur as part of enh#2831572.
                -- Added by Nishikant due to the enhancement bug#2162831
                crsp_ins_appr_ass_itm_grd(
                                p_old_unit_cd,
                                p_old_version_number);

                -- Added by Ayedubat as part of the HESA Integration DLD ( Eh Bug # 2201753)

                -- Check the Profile value of Country Code for OSS.

                IF fnd_profile.value('OSS_COUNTRY_CODE') = 'GB' THEN

                    -- Call the Procedure to copy the HESA related information old Unit to the New Unit
                    IGS_HE_UV_PKG.COPY_UNIT_VERSION
                      (p_old_unit_cd,
                       p_old_version_number,
                       p_new_unit_cd,
                       p_new_version_number,
                       l_status,
                       p_message_name) ;

                    -- If the Procedure has returned an error , then display the error message and abort the process
                    IF l_status = 2 THEN -- ie. The procedure call has resulted in error.

                       fnd_message.set_name('IGS', p_message_name);
                       IGS_GE_MSG_STACK.ADD;
                       app_exception.raise_exception;

                    END IF;

                END IF;
                -- End of the code added by ayedubat

                EXCEPTION
                WHEN OTHERS THEN
                        IF (c_new_unit_vers_rec%ISOPEN) THEN
                                CLOSE c_new_unit_vers_rec;
                        END IF;
                        IF (c_old_unit_vers_rec%ISOPEN) THEN
                                CLOSE c_old_unit_vers_rec;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_008.crsp_ins_unit_ver');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END crsp_ins_unit_ver;



FUNCTION CRSP_INS_UOP_UOO(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_source_ci_sequence_number IN NUMBER ,
  p_dest_ci_sequence_number IN NUMBER ,
  p_source_cal_type IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2,
  p_log_creation_date DATE )
RETURN BOOLEAN AS

-------------------------------------------------------------------------------------------------------------------------------------
--Change History:
--Who       When         What
--sarakshi  17-Oct-2005  Bug#4657596, added fnd logging
--sarakshi  14-oct-2004  Bug#3945817, passsing unit section status as mentioned in the bug.
--sarakshi  14-Sep-2004  Enh#3888835, added cursor c_teach_date and it's related logic.
--sarakshi  31-AUG-2004  Bug#3864738,passed unit_section_status as OPEN in the insert row call of IGS_PS_UNIT_OFR_OPT
--sarakshi  12-Jul-2004  Bug#3729462, Added the predicate DELETE_FLAG='N' to the cursor c_uop_dest_rec
--sarakshi  02-Jun-2004  Bug#3655650,modified cursor c_uai_source_rec and its usage, also added logic to rollover the unit assessment items groups
--sarakshi  13-Apr-2004  Bug#3555871, removed the logic of getting the call number for AUTO profile option.
--sarakshi  23-sep-2003  ENh#3052452,created local procedure crspl_upd_usec_relation and the call of the same .Also added column sup_uoo_id,relation_type,default_enroll_flag to the call of igs_ps_unit_ofr_opt_pkg.insert_row
--sarakhsi  29-Aug-2003  Bug#3076021,shifted teh local function crspl_ins_teach_resp_ovrd to IGSPS01B.pls(only logic),also set the value of unit_section_status,unit section start_dt and unit_section_end_dt appropriately
--vvutukur  05-Aug-2003  Enh#3045069.PSP Enh Build. Modified call to igs_ps_unit_ofr_opt_pkg.insert_row to include new parameter not_multiple_section_flag.
--sarakshi  18-Apr-2003  Bug#2910695,passed null to actual_enrollment,actual_waitlist to IGS_PS_UNIT_OFR_OPT_ALL
--sarakshi  05-Mar-2003  Bug#2768783,replaced the local function call check_call_number with
--                       igs_ps_unit_ofr_opt_pkg.check_call_number.Also coded logic for validating/generating call_number
--sarakshi  18-sep-2002  changed the variable name p_message_name to l_message_name,bug#2563596
--sarakshi  06-Jun-2002  Local procedure to handle the exception condition ,bug#2332807
-------------------------------------------------------------------------------------------------------------------------------------


  --This cursor added by sarakshi,bug#2332807
  CURSOR cur_check(cp_creation_dt igs_ge_s_log_entry.creation_dt%TYPE)  IS
  SELECT  'X'
  FROM    igs_ge_s_log_entry
  WHERE   s_log_type='USEC-ROLL'
  AND     creation_dt=cp_creation_dt;


  --This cursor added by jbegum for Bug#2563596
  CURSOR cur_check_log(cp_creation_dt igs_ge_s_log.creation_dt%TYPE)  IS
  SELECT  rowid
  FROM    igs_ge_s_log
  WHERE   s_log_type='USEC-ROLL'
  AND     creation_dt=cp_creation_dt;

  l_var                   VARCHAR2(1);
  l_var_log               cur_check_log%ROWTYPE;
  l_rowid                 VARCHAR2(25);
  x_rowid                 VARCHAR2(25);
  l_old_uoo_id            igs_ps_unit_ofr_opt.uoo_id%TYPE;
  v_new_uoo_id            igs_ps_unit_ofr_opt.uoo_id%TYPE;


BEGIN   -- crsp_ins_uop_uoo
        -- Copy the IGS_PS_UNIT offering options and IGS_PS_UNIT assessment patterns from
        -- the source IGS_PS_UNIT offering pattern to the destination IGS_PS_UNIT offering pattern.
DECLARE
  cst_exam      CONSTANT        VARCHAR2(4) := 'EXAM';
  v_uoo_inserted_cnt            NUMBER(4);
  v_uai_inserted_cnt            NUMBER(4);
  v_uai_fetched_cnt             NUMBER(4);
  v_message_name                VARCHAR2(30);
  v_uop_exists                  VARCHAR2(1);
  v_uoo_error                   BOOLEAN ;
  v_uai_error                   BOOLEAN ;
  v_tro_recs_skipped            BOOLEAN ;
  v_uai_continue                BOOLEAN ;
  v_ret_val                     BOOLEAN ;
  v_successful_pattern_mbr      BOOLEAN ;
  v_exam_cal_type               igs_ca_inst.cal_type%TYPE;
  v_exam_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
  v_latest_gs_version           igs_as_grd_schema.version_number%TYPE;
  v_unit_contact                igs_ps_unit_ofr_opt.unit_contact%TYPE;
  v_assessment_type             igs_as_assessmnt_typ.assessment_type%TYPE;
  v_reference                   igs_as_unitass_item.reference%TYPE;
  v_uai_seq_num                 igs_as_unitass_item.sequence_number%TYPE;
  l_org_id                      NUMBER(15);
  l_unit_ass_item_id            igs_as_unitass_item_all.unit_ass_item_id%TYPE;


  CURSOR c_uop_dest_rec IS
  SELECT 'x'
  FROM   igs_ps_unit_ofr_pat     uop
  WHERE  uop.unit_cd             = p_unit_cd
  AND    uop.version_number      = p_version_number
  AND    uop.cal_type            = p_cal_type
  AND    uop.ci_sequence_number  = p_dest_ci_sequence_number
  AND    uop.delete_flag         = 'N';

  CURSOR c_uoo_source_rec IS
  SELECT *
  FROM   igs_ps_unit_ofr_opt     uoo
  WHERE  uoo.unit_cd             = p_unit_cd
  AND    uoo.version_number      = p_version_number
  AND    uoo.cal_type            = p_source_cal_type
  AND    uoo.ci_sequence_number  = p_source_ci_sequence_number;
  v_uoo_rec             c_uoo_source_rec%ROWTYPE;

  CURSOR c_latest_gs_version (cp_grad_schema_cd        igs_as_grd_schema.grading_schema_cd%TYPE) IS
  SELECT MAX(gs.version_number)
  FROM   igs_as_grd_schema  gs
  WHERE  gs.grading_schema_cd = cp_grad_schema_cd;


  CURSOR cur_unit_ass_group(cp_unit_cd            igs_as_unit_ai_grp.unit_cd%TYPE,
                            cp_version_number     igs_as_unit_ai_grp.version_number%TYPE,
			    cp_cal_type           igs_as_unit_ai_grp.cal_type%TYPE,
			    cp_ci_sequence_number igs_as_unit_ai_grp.ci_sequence_number%TYPE) IS
   SELECT  *
   FROM    igs_as_unit_ai_grp
   WHERE   unit_cd=cp_unit_cd
   AND     version_number=cp_version_number
   AND     cal_type = cp_cal_type
   AND     ci_sequence_number=cp_ci_sequence_number;

  -- Only undeleted record to be selected
  CURSOR c_uai_source_rec(
         cp_unit_cd                      igs_ps_unit_ofr_pat.unit_cd%TYPE,
         cp_version_number               igs_ps_unit_ofr_pat.version_number%TYPE,
         cp_source_cal_type              igs_ps_unit_ofr_pat.cal_type%TYPE,
         cp_source_ci_sequence_number    igs_ps_unit_ofr_pat.ci_sequence_number%TYPE,
	 cp_unit_ass_item_group_id       igs_as_unitass_item.unit_ass_item_group_id%TYPE) IS
  SELECT *
  FROM   igs_as_unitass_item     uai
  WHERE  uai.logical_delete_dt   IS NULL
  AND    uai.unit_cd             = cp_unit_cd
  AND    uai.version_number      = cp_version_number
  AND    uai.cal_type            = cp_source_cal_type
  AND    uai.ci_sequence_number  = cp_source_ci_sequence_number
  AND    uai.unit_ass_item_group_id = cp_unit_ass_item_group_id
  ORDER BY uai.exam_cal_type, uai.exam_ci_sequence_number;
  v_uai_rec             c_uai_source_rec%ROWTYPE;

  CURSOR c_uoo_rec_exists(
         cp_unit_cd                      IGS_PS_UNIT_OFR_PAT.unit_cd%TYPE,
         cp_version_number               IGS_PS_UNIT_OFR_PAT.version_number%TYPE,
         cp_cal_type                     IGS_PS_UNIT_OFR_PAT.cal_type%TYPE,
         cp_dest_ci_sequence_number      IGS_PS_UNIT_OFR_PAT.ci_sequence_number%TYPE,
         cp_location_cd                  IGS_PS_UNIT_OFR_OPT.location_cd%TYPE,
         cp_unit_class                   IGS_PS_UNIT_OFR_PAT.unit_cd%TYPE) IS
  SELECT *
  FROM   igs_ps_unit_ofr_opt     uoo
  WHERE  uoo.unit_cd             = cp_unit_cd
  AND    uoo.version_number      = cp_version_number
  AND    uoo.cal_type            = cp_cal_type
  AND    uoo.ci_sequence_number  = cp_dest_ci_sequence_number
  AND    uoo.location_cd         = cp_location_cd
  AND    uoo.unit_class          = cp_unit_class;
  v_uoo_rec_exists                   c_uoo_rec_exists%ROWTYPE;

  CURSOR        c_uoo_seq_num IS
  SELECT        IGS_PS_UNIT_OFR_OPT_UOO_ID_S.NEXTVAL
  FROM  DUAL;

  CURSOR        c_uai_seq_num IS
  SELECT        IGS_AS_UNITASS_ITEM_SEQ_NUM_S.NEXTVAL
  FROM  DUAL;

  CURSOR c_teach_date(cp_cal_type igs_ca_inst_all.cal_type%TYPE ,cp_seq_num  igs_ca_inst_all.sequence_number%TYPE) IS
  SELECT start_dt,end_dt
  FROM   igs_ca_inst_all
  WHERE  cal_type = cp_cal_type
  AND    sequence_number = cp_seq_num;
  l_d_src_teach_cal_start_dt  DATE;
  l_d_src_teach_cal_end_dt    DATE;
  l_d_dst_teach_cal_start_dt  DATE;
  l_d_dst_teach_cal_end_dt    DATE;
  l_n_num_st_days             NUMBER;
  l_n_num_end_days            NUMBER;
  l_d_us_dest_start_dt        DATE;
  l_d_us_dest_end_dt          DATE;

  l_c_usec_status igs_ps_unit_ofr_opt_all.unit_section_status%TYPE;

  -- jbegum As part of bug#2563596 the call to IGS_GE_GEN_003.genp_ins_log_entry was modified .
  -- The concatenated string being passed to parameter p_key has the substring FND_MESSAGE.GET_STRING('IGS', l_message_name)
  -- removed as this was causing the TBH procedure IGS_GE_S_LOG_ENTRY_PKG.INSERT_ROW to throw up an invalid value error,which
  -- was in turn causing function IGS_PS_GEN_008.crsp_ins_uop_uoo to throw up an unhandled exception.
  -- Also the concatenated string being passed to parameter p_text has only l_message_name concatenated to it instead of
  -- FND_MESSAGE.GET_STRING('IGS', l_message_name)



  PROCEDURE  handle_excp( p_old_uoo_id        igs_ps_unit_ofr_opt.uoo_id%TYPE ) AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who       When         What
  --
  -------------------------------------------------------------------------------------------
    CURSOR cur_org_unit (cp_uoo_id IN NUMBER) IS
    SELECT   owner_org_unit_cd
    FROM     igs_ps_unit_ofr_opt
    WHERE    uoo_id = cp_uoo_id;
    lcur_org_unit cur_org_unit%rowtype;
    l_message_name fnd_new_messages.message_text%TYPE;
  BEGIN
    --l_message_name should contain error messasges from tbh while insertion, if any other error is occured
    --that is fetched by using sqlerrm and stored in l_message_name
    l_message_name:=fnd_message.get;
    IF l_message_name IS NULL THEN
      l_message_name:=sqlerrm;
    END IF;

    OPEN cur_org_unit (p_old_uoo_id);
    FETCH cur_org_unit INTO lcur_org_unit;
    CLOSE cur_org_unit;

    igs_ge_gen_003.genp_ins_log_entry (
    'USEC-ROLL' ,            --This s_log_type
    p_log_creation_date,     -- This will be accepted AS parameter AND defaulted TO NULL;
    lcur_org_unit.owner_org_unit_cd || ',' || p_old_uoo_id || ',' || p_source_cal_type ||
    ',' || p_source_ci_sequence_number,  --This is the key
    NULL, --This is message name
    --This is the message text
    lcur_org_unit.owner_org_unit_cd || ',' || p_old_uoo_id || ',' || p_source_cal_type || ',' ||p_source_ci_sequence_number || ',' || l_message_name);

  END handle_excp;


  PROCEDURE crspl_upd_usec_relation (p_src_cal_type igs_ca_inst.cal_type%TYPE,
                                     p_src_sequence_num igs_ca_inst.sequence_number%TYPE,
                                     p_dst_cal_type igs_ca_inst.cal_type%TYPE,
                                     p_dst_sequence_num igs_ca_inst.sequence_number%TYPE
                                     ) AS
    /*************************************************************
     Created By : sarakshi
     Date Created By :23-Sep-2003
     Purpose :To create relationship between the unit section that has been rolled over.
     Know limitations, enhancements or remarks
     Change History
     Who             When            What
     sarakshi   18-Jan-2006  Bug#4926548, modified cursor c_new_sub_us and c_new_sup_us1 to address the performance issue. Created local procedures and functions.
     sarakshi   17-Nov-2005  Bug#4726940, impact of change of signature of the update_usec_record, passing the default enroll flag
                             value from the source to the destination for the subordinate section. Also removed variable l_usec_roll
			     as relationship logic needs to be called irrespective of whether a single unit ssection has been rolled or not
     (reverse chronological order - newest change first)
    ***************************************************************/

    l_c_none        VARCHAR2(10) := 'NONE';
    l_c_superior    VARCHAR2(10) := 'SUPERIOR';
    l_c_subordinate VARCHAR2(15) := 'SUBORDINATE';
    l_c_notoffered  VARCHAR2(15) := 'NOT_OFFERED';
    l_c_inactive    VARCHAR2(10) :=  'INACTIVE';

    --Cursor to get list the subordinate unit sections whose superior unit sections have been rolled over
    CURSOR c_get_sub_us_list IS
    SELECT *
    FROM igs_ps_unit_ofr_opt
    WHERE  sup_uoo_id IN ( SELECT uoo_id
                           FROM igs_ps_unit_ofr_opt
                           WHERE cal_type = p_src_cal_type
                           AND   ci_sequence_number = p_src_sequence_num
         AND   unit_cd = p_unit_cd
         AND   version_number = p_version_number
                          );

    --Cursor to get unit_cd,version_number, location_code and unit_class for  SUP_UOO_ID
    CURSOR c_get_old_uoo_det(cp_uoo_id  igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
    SELECT unit_cd,version_number,location_cd,unit_class
    FROM   igs_ps_unit_ofr_opt
    WHERE  uoo_id = cp_uoo_id;

    --Cursor to get the new UOO_ID for the old SUP_UOO_ID
    CURSOR c_new_sup_uoo_id(cp_unit_cd        igs_ps_unit_ofr_opt.unit_cd%TYPE,
                            cp_version_number igs_ps_unit_ofr_opt.version_number%TYPE,
                            cp_location_cd    igs_ps_unit_ofr_opt.location_cd%TYPE,
                            cp_unit_class     igs_ps_unit_ofr_opt.unit_class%TYPE) IS
    SELECT uoo_id
    FROM   igs_ps_unit_ofr_opt
    WHERE  unit_cd            = cp_unit_cd
    AND    version_number     = cp_version_number
    AND    cal_type           = p_dst_cal_type
    AND    ci_sequence_number = p_dst_sequence_num
    AND    location_cd        = cp_location_cd
    AND    unit_class         = cp_unit_class;

    --Cursor to get the new subordinate unit sections
    CURSOR c_new_sub_us (cp_unit_cd        igs_ps_unit_ofr_opt.unit_cd%TYPE,
                         cp_version_number igs_ps_unit_ofr_opt.version_number%TYPE,
                         cp_location_cd    igs_ps_unit_ofr_opt.location_cd%TYPE,
                         cp_unit_class     igs_ps_unit_ofr_opt.unit_class%TYPE) IS
    SELECT uoo.*
    FROM  igs_ps_unit_ofr_opt uoo,
          igs_ps_unit_ver_all uv,
          igs_ps_unit_stat   us
    WHERE uoo.unit_cd         = cp_unit_cd
    AND   uoo.version_number  = cp_version_number
    AND   uoo.location_cd     = cp_location_cd
    AND   uoo.unit_class      = cp_unit_class
    AND   uoo.relation_type   = l_c_none
    AND   uoo.unit_section_status <> l_c_notoffered
    AND   uoo.unit_cd = uv.unit_cd
    AND   uoo.version_number = uv.version_number
    AND   uv.unit_status   = us.unit_status
    AND   us.s_unit_status <> l_c_inactive
    AND   uoo.uoo_id NOT IN (SELECT uoo_id FROM igs_ps_usec_x_grpmem);


    --Cursor to get list the subordiante unit sections have been rolled over
    CURSOR c_get_sub_us_list1 IS
    SELECT *
    FROM   igs_ps_unit_ofr_opt
    WHERE  cal_type           = p_src_cal_type
    AND    ci_sequence_number = p_src_sequence_num
    AND    unit_cd = p_unit_cd
    AND    version_number = p_version_number
    AND    relation_type      = l_c_subordinate;

    --Cursor to get from the new  subordinate unit section details
    CURSOR c_get_new_sub (cp_unit_cd        igs_ps_unit_ofr_opt.unit_cd%TYPE,
                          cp_version_number igs_ps_unit_ofr_opt.version_number%TYPE,
                          cp_location_cd    igs_ps_unit_ofr_opt.location_cd%TYPE,
                          cp_unit_class     igs_ps_unit_ofr_opt.unit_class%TYPE) IS
    SELECT *
    FROM   igs_ps_unit_ofr_opt
    WHERE  unit_cd            = cp_unit_cd
    AND    version_number     = cp_version_number
    AND    location_cd        = cp_location_cd
    AND    unit_class         = cp_unit_class
    AND    cal_type           = p_dst_cal_type
    AND    ci_sequence_number = p_dst_sequence_num;

    --Cursor to get the old superior unit section details
    CURSOR c_get_old_sup_det (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
    SELECT *
    FROM   igs_ps_unit_ofr_opt
    WHERE  uoo_id = cp_uoo_id;


    --Cursor to get the new superior unit sections
    CURSOR c_new_sup_us(cp_unit_cd        igs_ps_unit_ofr_opt.unit_cd%TYPE,
                        cp_version_number igs_ps_unit_ofr_opt.version_number%TYPE,
                        cp_location_cd    igs_ps_unit_ofr_opt.location_cd%TYPE,
                        cp_unit_class     igs_ps_unit_ofr_opt.unit_class%TYPE) IS
    SELECT uoo.uoo_id,uoo.sup_uoo_id
    FROM   igs_ps_unit_ofr_opt uoo,
           igs_ps_unit_ver_all uv,
           igs_ps_unit_stat   us
    WHERE  uoo.unit_cd        = cp_unit_cd
    AND    uoo.version_number = cp_version_number
    AND    uoo.location_cd    = cp_location_cd
    AND    uoo.unit_class     = cp_unit_class
    AND    uoo.relation_type IN (l_c_superior,l_c_none)
    AND    uoo.cal_type           = p_dst_cal_type
    AND    uoo.ci_sequence_number = p_dst_sequence_num
    AND    uoo.unit_cd = uv.unit_cd
    AND    uoo.version_number = uv.version_number
    AND    uv.unit_status   = us.unit_status
    AND    us.s_unit_status <> l_c_inactive
    AND    uoo.uoo_id NOT IN (SELECT uoo_id FROM igs_ps_usec_x_grpmem)
    AND    uoo.unit_section_status <> l_c_notoffered;

    CURSOR c_new_sup_us1 (cp_unit_cd        igs_ps_unit_ofr_opt.unit_cd%TYPE,
                          cp_version_number igs_ps_unit_ofr_opt.version_number%TYPE,
                          cp_location_cd    igs_ps_unit_ofr_opt.location_cd%TYPE,
                          cp_unit_class     igs_ps_unit_ofr_opt.unit_class%TYPE) IS
    SELECT uoo_id,sup_uoo_id,cal_type,ci_sequence_number
    FROM   igs_ps_unit_ofr_opt
    WHERE  unit_cd        = cp_unit_cd
    AND    version_number = cp_version_number
    AND    location_cd    = cp_location_cd
    AND    unit_class     = cp_unit_class
    AND    relation_type IN (l_c_superior,l_c_none)
    AND    uoo_id NOT IN (SELECT uoo_id FROM igs_ps_usec_x_grpmem)
    AND    unit_section_Status <> l_c_notoffered;

    l_c_get_old_uoo_det  c_get_old_uoo_det%ROWTYPE;
    l_c_new_sup_uoo_id   c_new_sup_uoo_id%ROWTYPE;
    l_c_get_new_sub      c_get_new_sub%ROWTYPE;
    l_c_get_old_sup_det  c_get_old_sup_det%ROWTYPE;
    l_c_new_sup_us       c_new_sup_us%ROWTYPE;
    l_c_new_sup_us1      c_new_sup_us1%ROWTYPE;
    l_b_var1             BOOLEAN := FALSE;

--- added as a part of performance activity ---
    TYPE teach_cal_rec IS RECORD(
				 cal_type igs_ca_inst_all.cal_type%TYPE,
				 sequence_number igs_ca_inst_all.sequence_number%TYPE
				 );
    TYPE teachCalendar IS TABLE OF teach_cal_rec INDEX BY BINARY_INTEGER;
    teachCalendar_tbl teachCalendar;
    l_n_counter NUMBER(10);
    l_c_proceed BOOLEAN ;


    PROCEDURE createCalendar  IS

    CURSOR cur_cal_teach(cp_load_cal igs_ca_teach_to_load_v.load_cal_type%TYPE,
                         cp_load_seq igs_ca_teach_to_load_v.load_ci_sequence_number%TYPE) IS
    SELECT teach_cal_type,teach_ci_sequence_number
    FROM   igs_ca_teach_to_load_v
    WHERE  load_cal_type = cp_load_cal
    AND    load_ci_sequence_number = cp_load_seq;

    CURSOR cur_cal_load IS
    SELECT load_cal_type,load_ci_sequence_number
    FROM   igs_ca_load_to_teach_v
    WHERE  teach_cal_type=p_dst_cal_type
    AND    teach_ci_sequence_number=p_dst_sequence_num;

    BEGIN
       --populate the pl-sql table with the teaching calendar's by mapping the load calendars.
       l_n_counter :=1;
       FOR rec_cur_cal_load IN cur_cal_load LOOP
           FOR rec_cur_cal_teach IN cur_cal_teach(rec_cur_cal_load.load_cal_type ,rec_cur_cal_load.load_ci_sequence_number) LOOP
	      teachCalendar_tbl(l_n_counter).cal_type :=rec_cur_cal_teach.teach_cal_type;
	      teachCalendar_tbl(l_n_counter).sequence_number :=rec_cur_cal_teach.teach_ci_sequence_number;
	      l_n_counter:=l_n_counter+1;
	   END LOOP;
       END LOOP;

    END createCalendar;

    FUNCTION testCalendar(cp_cal_type igs_ca_inst_all.cal_type%TYPE,
                          cp_sequence_number igs_ca_inst_all.sequence_number%TYPE)  RETURN BOOLEAN AS
    BEGIN
      IF teachCalendar_tbl.EXISTS(1) THEN
        FOR i IN 1..teachCalendar_tbl.last LOOP
	     IF cp_cal_type=teachCalendar_tbl(i).cal_type AND
		cp_sequence_number=teachCalendar_tbl(i).sequence_number THEN
		RETURN TRUE;
	     END IF;
	END LOOP;
      END IF;
      RETURN FALSE;
    END testCalendar;

--- added as a part of performance activity ---

  BEGIN
    --Store the teaching calendars in a pl-sql tables for the input teaching calendars
    createCalendar;
    --Fetch all the superior unit section from the source calendar instance
    FOR rec_get_sub_us_list IN c_get_sub_us_list LOOP

      l_b_var1 :=FALSE;
      --This cursor capture the details of old sup_uoo_id
      OPEN c_get_old_uoo_det (rec_get_sub_us_list.sup_uoo_id);
      FETCH c_get_old_uoo_det INTO l_c_get_old_uoo_det;
      CLOSE c_get_old_uoo_det;


      --This cursor fetches the new sup_uoo_id record
      OPEN c_new_sup_uoo_id  (l_c_get_old_uoo_det.unit_cd,l_c_get_old_uoo_det.version_number,l_c_get_old_uoo_det.location_cd,l_c_get_old_uoo_det.unit_class);
      FETCH c_new_sup_uoo_id INTO l_c_new_sup_uoo_id;
      CLOSE c_new_sup_uoo_id;

      --This cursor fetches the new uoo_id for the old uoo_id

      FOR rec_new_sub_us  IN  c_new_sub_us (rec_get_sub_us_list.unit_cd,rec_get_sub_us_list.version_number,rec_get_sub_us_list.location_cd,rec_get_sub_us_list.unit_class) LOOP
        IF testCalendar(rec_new_sub_us.cal_type ,rec_new_sub_us.ci_sequence_number ) THEN
  	  --update the new unit sections record, relation_type and sup_uoo_id column value
          update_usec_record(rec_new_sub_us.uoo_id,l_c_subordinate,l_c_new_sup_uoo_id.uoo_id,rec_get_sub_us_list.default_enroll_flag);
          l_b_var1 :=TRUE;
	END IF;
      END LOOP;

      --update the new unit sections relation_type for the superior record.
      IF l_b_var1 THEN
        update_usec_record(l_c_new_sup_uoo_id.uoo_id,l_c_superior,NULL,NULL);
      END IF;
    END LOOP;

    --Fetch all the records from the below cursor and process
    FOR rec_get_sub_us_list1 IN c_get_sub_us_list1 LOOP

      --capture the new uoo_id
      OPEN c_get_new_sub (rec_get_sub_us_list1.unit_cd,rec_get_sub_us_list1.version_number,rec_get_sub_us_list1.location_cd,rec_get_sub_us_list1.unit_class);
      FETCH c_get_new_sub INTO l_c_get_new_sub;
      CLOSE c_get_new_sub;

      --capture the details of sup_uoo_id
      OPEN c_get_old_sup_det (rec_get_sub_us_list1.sup_uoo_id);
      FETCH c_get_old_sup_det INTO l_c_get_old_sup_det;
      CLOSE c_get_old_sup_det;

      OPEN c_new_sup_us  (l_c_get_old_sup_det.unit_cd,l_c_get_old_sup_det.version_number,l_c_get_old_sup_det.location_cd,l_c_get_old_sup_det.unit_class);
      FETCH c_new_sup_us INTO l_c_new_sup_us;
      IF c_new_sup_us%FOUND THEN
        --update the new unit sections relation_type and sup_uoo_id column value
        update_usec_record(l_c_get_new_sub.uoo_id,l_c_subordinate,l_c_new_sup_us.uoo_id,rec_get_sub_us_list1.default_enroll_flag);
        CLOSE c_new_sup_us;
        --update the new unit sections relation_type
        update_usec_record(l_c_new_sup_us.uoo_id,l_c_superior,NULL,NULL);
      ELSE
	FOR l_c_new_sup_us1 IN c_new_sup_us1(l_c_get_old_sup_det.unit_cd,l_c_get_old_sup_det.version_number,l_c_get_old_sup_det.location_cd,l_c_get_old_sup_det.unit_class) LOOP
	  IF testCalendar(l_c_new_sup_us1.cal_type ,l_c_new_sup_us1.ci_sequence_number ) THEN
	    --update the new unit sections relation_type and sup_uoo_id column value
	    update_usec_record(l_c_get_new_sub.uoo_id,l_c_subordinate,l_c_new_sup_us1.uoo_id,rec_get_sub_us_list1.default_enroll_flag);

	    --update the new unit sections relation_type
	    update_usec_record(l_c_new_sup_us1.uoo_id,l_c_superior,NULL,NULL);
	    EXIT;
	  END IF;
        END LOOP;
      END IF;

    END LOOP;

    IF teachCalendar_tbl.EXISTS(1) THEN
      teachCalendar_tbl.DELETE;
    END IF;

  END crspl_upd_usec_relation;


  PROCEDURE crspl_get_new_exam_cal (
    p_old_exam_cal_type                 igs_ca_inst.cal_type%TYPE,
    p_old_exam_seq_num                  igs_ca_inst.sequence_number%TYPE,
    p_new_exam_cal_type OUT NOCOPY      igs_ca_inst.cal_type%TYPE,
    p_new_exam_seq_num  OUT NOCOPY      igs_ca_inst.sequence_number%TYPE,
    p_uoo_id                            NUMBER) AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who       When         What
  --sommukhe  01-SEP-2005  Bug#4538540,Added cursor cur_ass_item .
  --sarakshi  24-dec-2002  Bug#2689625,removed the exception section
  -------------------------------------------------------------------------------------------
    v_old_specific_occurrence   NUMBER(4) ;
    v_old_total_occurrence      NUMBER(4) ;
    v_new_total_occurrence      NUMBER(4) ;

    CURSOR c_exam_cal_type (
           cp_exam_cal_type             igs_ca_inst.cal_type%TYPE,
           cp_teach_cal_type            igs_ca_inst.cal_type%TYPE,
           cp_teach_seq_num             igs_ca_inst.sequence_number%TYPE) IS
    SELECT  ci.cal_type,
            ci.sequence_number
    FROM    igs_ca_type                     ct,
            igs_ca_inst                     ci,
            igs_ca_inst_rel cir
    WHERE   cir.sup_ci_sequence_number      = ci.sequence_number
    AND     cir.sup_cal_type                = ci.cal_type
    AND     ct.cal_type                     = ci.cal_type
    AND     ct.s_cal_cat                    = cst_exam
    AND     cir.sub_cal_type                = cp_teach_cal_type
    AND     cir.sub_ci_sequence_number      = cp_teach_seq_num
    AND     ci.cal_type                     = cp_exam_cal_type
    ORDER BY ci.start_dt;
    v_exam_cal_rec          c_exam_cal_type%ROWTYPE;

    CURSOR c_exam_cal_count (
                                cp_exam_cal_type                IGS_CA_INST.cal_type%TYPE,
                                cp_teach_cal_type               IGS_CA_INST.cal_type%TYPE,
                                cp_teach_seq_num                IGS_CA_INST.sequence_number%TYPE) IS
    SELECT  COUNT(ci.cal_type)
    FROM    IGS_CA_TYPE                     ct,
            IGS_CA_INST                     ci,
            IGS_CA_INST_REL cir
    WHERE   cir.sup_ci_sequence_number      = ci.sequence_number
    AND     cir.sup_cal_type                = ci.cal_type
    AND     ct.cal_type                     = ci.cal_type
    AND     ct.s_cal_cat                    = cst_exam
    AND     cir.sub_cal_type                = cp_teach_cal_type
    AND     cir.sub_ci_sequence_number      = cp_teach_seq_num
    AND     ci.cal_type                     = cp_exam_cal_type;

  BEGIN

    -- Assigning initial values to local variables which were being initialised using DEFAULT
    -- clause.Done as part of bug #2563596 to remove GSCC warning.

    v_old_specific_occurrence       := 0;
    v_old_total_occurrence          := 0;
    v_new_total_occurrence          := 0;

    IF p_old_exam_cal_type IS NOT NULL THEN
      IF p_old_exam_seq_num IS NULL THEN
        -- check for all exam periods for the new teaching calendar instance.
        OPEN c_exam_cal_type(
                             p_old_exam_cal_type,
                             p_cal_type,
                             p_dest_ci_sequence_number);
        FETCH c_exam_cal_type INTO v_exam_cal_rec;
        IF c_exam_cal_type%FOUND THEN
          p_new_exam_cal_type := p_old_exam_cal_type;
          p_new_exam_seq_num := NULL;
        ELSE
          p_new_exam_cal_type := NULL;
          p_new_exam_seq_num := NULL;
        END IF;
        CLOSE c_exam_cal_type;
      ELSE
        -- p_old_exam_seq_num is NOT NULL
        -- get the total occurrence of the exam period for this particular
        -- IGS_PS_UNIT assessment item for the old teaching calendar instance.
        OPEN c_exam_cal_count(
                              p_old_exam_cal_type,
                              p_source_cal_type,
                              p_source_ci_sequence_number);
        FETCH c_exam_cal_count INTO v_old_total_occurrence;
        CLOSE c_exam_cal_count;
        -- get the total occurrence of the exam period for this particular
        -- IGS_PS_UNIT assessment item for the new teaching calendar instance.
        OPEN c_exam_cal_count(
                              p_old_exam_cal_type,
                              p_cal_type,
                              p_dest_ci_sequence_number);
        FETCH c_exam_cal_count INTO v_new_total_occurrence;
        CLOSE c_exam_cal_count;
        IF v_new_total_occurrence >0 AND
          v_new_total_occurrence = v_old_total_occurrence THEN
          -- get the occurrence of the exam period for this particular
          -- IGS_PS_UNIT assessment item for the old teaching calendar instance.
          FOR v_old_exam_cal_rec IN c_exam_cal_type(
                                                    p_old_exam_cal_type,
                                                    p_source_cal_type,
                                                    p_source_ci_sequence_number) LOOP
            IF v_old_exam_cal_rec.sequence_number = p_old_exam_seq_num THEN
              v_old_specific_occurrence := c_exam_cal_type%ROWCOUNT;
              EXIT;
            END IF;
          END LOOP;
          IF v_old_specific_occurrence>0 THEN
            -- get the sequence number, which has the same occurrence as the
            -- old exam period, for this particular IGS_PS_UNIT assessment item for
            -- the new teaching calendar instance.
            FOR v_new_exam_cal_rec IN c_exam_cal_type(
                                                      p_old_exam_cal_type,
                                                      p_cal_type,
                                                      p_dest_ci_sequence_number) LOOP
              IF c_exam_cal_type%ROWCOUNT = v_old_specific_occurrence THEN
                p_new_exam_seq_num := v_new_exam_cal_rec.sequence_number;
                EXIT;
              END IF;
            END LOOP;
            p_new_exam_cal_type := p_old_exam_cal_type;
          ELSE
            p_new_exam_cal_type := NULL;
            p_new_exam_seq_num := NULL;
          END IF;
        ELSE    -- total occurrence for old and new teaching calendar are not equal
          p_new_exam_cal_type := NULL;
          p_new_exam_seq_num := NULL;
        END IF;
      END IF; -- p_old_exam_seq_number is NULL
    ELSE    -- p_old_exam_cal_type is NULL
       p_new_exam_cal_type := NULL;
       p_new_exam_seq_num  := NULL;
    END IF; -- p_old_exam_cal_type is NOT NULL

  END crspl_get_new_exam_cal;
BEGIN
  -- Main unit section rollover procedure
  -- Assigning initial values to local variables which were being initialised using DEFAULT
  -- clause.Done as part of bug #2563596 to remove GSCC warning.

  v_uoo_inserted_cnt              := 0;
  v_uai_inserted_cnt              := 0;
  v_uai_fetched_cnt               := 0;
  v_uoo_error                     := FALSE;
  v_uai_error                     := FALSE;
  v_tro_recs_skipped              := FALSE;
  v_uai_continue                  := FALSE;
  v_ret_val                       := TRUE;
  l_d_src_teach_cal_start_dt      := NULL;

  -- Set default value
  p_message_name := NULL;
  v_message_name := NULL;
  v_successful_pattern_mbr := TRUE;

  -- Validate the destination parent record(uop) exists.
  OPEN c_uop_dest_rec;
  FETCH c_uop_dest_rec INTO v_uop_exists;
  IF (c_uop_dest_rec%NOTFOUND) THEN
    p_message_name := 'IGS_PS_DEST_UOP_NOT_EXIST';
    CLOSE c_uop_dest_rec;
    RETURN FALSE;
  END IF;
  CLOSE c_uop_dest_rec;

  -- Added by jbegum as part of bug #2563596
  -- The package IGS_PS_GEN_006 has a call to IGS_PS_GEN_008.crsp_ins_uop_uoo.Before this call in the package IGS_PS_GEN_006
  -- an insert is happening into igs_ge_s_log table thru a call to IGS_GE_GEN_003.genp_ins_log.The same creation date is being
  -- passed to the call of IGS_PS_GEN_008.crsp_ins_uop_uoo.Hence added code here to check for existence of the record in
  -- igs_ge_s_log table before inserting into it.Thus preventing the error 'Record already exists' being thrown up as unhandled
  -- exception by the procedure IGS_PS_GEN_006.crsp_ins_ci_uop_uoo


  OPEN cur_check_log(p_log_creation_date);
  FETCH cur_check_log INTO l_var_log;
  IF  cur_check_log%NOTFOUND THEN

    --Added by sarakshi, as a part of bug#2332807
    --If any error condition occurs , from the exception handlers we are inserting to igs_ge_s_log_entry table
    --which is child table so here inserting in the parent table  first which is to be deleted if no child
    --entries are found
    igs_ge_s_log_pkg.insert_row( x_rowid => l_rowid ,
                                 x_s_log_type => 'USEC-ROLL',
                                 x_creation_dt =>p_log_creation_date,
                                 x_key =>NULL,
                                 x_mode => 'R' );
  ELSE
    l_rowid := l_var_log.rowid;
  END IF;
  CLOSE cur_check_log;


  -- Select the source IGS_PS_UNIT_OFR_OPT records.
  OPEN c_uoo_source_rec;
  LOOP
    BEGIN
      FETCH c_uoo_source_rec INTO v_uoo_rec;
      EXIT WHEN c_uoo_source_rec%NOTFOUND;
      -- all of the below conditions must be true for the
      -- insert to proceed, else don't insert this particular
      -- IGS_PS_UNIT_OFR_OPT record
      -- get the max version number for grading schema

      -- lpriyadh  for enhancement bug# 1516959
      l_old_uoo_id := v_uoo_rec.uoo_id;


      OPEN c_latest_gs_version (v_uoo_rec.grading_schema_cd);
      FETCH c_latest_gs_version INTO v_latest_gs_version;
      CLOSE c_latest_gs_version;

      IF      -- if location_cd is open or = 'CAMPUS', continue validation
         (igs_ps_val_uoo.crsp_val_loc_cd (
                         v_uoo_rec.location_cd,
                         p_message_name) = TRUE
         )       AND
         -- if IGS_AS_UNIT_CLASS is open, continue validation
         (igs_ps_val_uoo.crsp_val_uoo_uc (
                         v_uoo_rec.unit_class,
                         p_message_name) = TRUE
         )       AND
         -- if grading schema is in the current or future,
         -- continue validation
         (igs_as_val_gsg.assp_val_gs_cur_fut(
                 v_uoo_rec.grading_schema_cd,
                 v_latest_gs_version,
                 p_message_name) = TRUE) THEN

         -- Validate IGS_PS_UNIT contact is a staff member
         IF igs_ad_val_acai.genp_val_staff_prsn(v_uoo_rec.unit_contact,
                                                v_message_name) = TRUE THEN
           v_unit_contact := v_uoo_rec.unit_contact;
         ELSE
           v_unit_contact := NULL;
         END IF;

         OPEN  c_uoo_rec_exists(p_unit_cd,
                                p_version_number,
                                p_cal_type,
                                p_dest_ci_sequence_number,
                                v_uoo_rec.location_cd,
                                v_uoo_rec.unit_class);
         FETCH c_uoo_rec_exists INTO v_uoo_rec_exists;
         -- checking that no other IGS_PS_UNIT_OFR_OPT record exists
         IF (c_uoo_rec_exists%NOTFOUND) THEN
           CLOSE c_uoo_rec_exists;

           -- get the next IGS_PS_UNIT_OFR_OPT_UOO_ID_S from the system
           OPEN  c_uoo_seq_num;
           FETCH c_uoo_seq_num INTO v_new_uoo_id;
           CLOSE c_uoo_seq_num;

           -- insert the IGS_PS_UNIT_OFR_OPT record, with this next uoo_id
           x_rowid := NULL;
           l_org_id := igs_ge_gen_003.get_org_id;


           --bug#2768783, added the validate/generate call number logic

           -- Validate/generate Call Number
           IF fnd_profile.value('IGS_PS_CALL_NUMBER') IN ('AUTO','NONE') THEN
              v_uoo_rec.call_number:=NULL;
           ELSIF ( fnd_profile.value('IGS_PS_CALL_NUMBER') = 'USER_DEFINED' ) THEN

             IF v_uoo_rec.call_number IS NOT NULL THEN
               IF NOT igs_ps_unit_ofr_opt_pkg.check_call_number ( p_teach_cal_type     => p_cal_type,
                                                                  p_teach_sequence_num => p_dest_ci_sequence_number,
                                                                  p_call_number        => v_uoo_rec.call_number,
                                                                  p_rowid              => x_rowid ) THEN
                 v_uoo_rec.call_number:=NULL;
               END IF;
             END IF;

           END IF;

           IF l_d_src_teach_cal_start_dt IS NULL THEN
             OPEN c_teach_date(p_source_cal_type,p_source_ci_sequence_number);
  	     FETCH c_teach_date INTO l_d_src_teach_cal_start_dt,l_d_src_teach_cal_end_dt;
	     CLOSE c_teach_date;

             OPEN c_teach_date(p_cal_type,p_dest_ci_sequence_number);
	     FETCH c_teach_date INTO l_d_dst_teach_cal_start_dt,l_d_dst_teach_cal_end_dt;
	     CLOSE c_teach_date;
           END IF;

	   IF v_uoo_rec.unit_section_start_date IS NOT NULL THEN
             l_n_num_st_days  :=  v_uoo_rec.unit_section_start_date - l_d_src_teach_cal_start_dt;
             l_d_us_dest_start_dt := l_d_dst_teach_cal_start_dt + l_n_num_st_days;
           ELSE
             l_d_us_dest_start_dt := NULL;
           END IF;


	   IF v_uoo_rec.unit_section_end_date IS NOT NULL THEN
	     l_n_num_end_days := v_uoo_rec.unit_section_end_date   - l_d_src_teach_cal_end_dt;
             l_d_us_dest_end_dt   := l_d_dst_teach_cal_end_dt + l_n_num_end_days;
           ELSE
             l_d_us_dest_end_dt   := NULL;
	   END IF;

           --Unit section start date must not be gretaer than the teaching calendar end date
           IF l_d_us_dest_start_dt IS NOT NULL AND l_d_us_dest_start_dt > NVL(l_d_us_dest_end_dt, l_d_dst_teach_cal_end_dt)  THEN
             l_d_us_dest_start_dt := l_d_dst_teach_cal_start_dt;
           END IF;

           --Unit section end date must not be less than the teaching calendar start date
           IF l_d_us_dest_end_dt IS NOT NULL AND l_d_us_dest_end_dt <  NVL(l_d_us_dest_start_dt,l_d_dst_teach_cal_start_dt) THEN
              l_d_us_dest_end_dt := l_d_dst_teach_cal_end_dt;
           END IF;


           l_c_usec_status := get_section_status(v_uoo_rec.unit_section_status);

           -- Added auditable_ind and audit_permission_ind parameters to the following insert_row call
           -- as part of Bug# 2636716, EN Integration by shtatiko
           igs_ps_unit_ofr_opt_pkg.insert_row(
             x_rowid                        =>       x_rowid,
             x_unit_cd                      =>       v_uoo_rec.unit_cd,
             x_version_number               =>       v_uoo_rec.version_number,
             x_cal_type                     =>       p_cal_type,
             x_ci_sequence_number           =>       p_dest_ci_sequence_number,
             x_location_cd                  =>       v_uoo_rec.location_cd,
             x_unit_class                   =>       v_uoo_rec.unit_class,
             x_uoo_id                       =>       v_new_uoo_id,
             x_ivrs_available_ind           =>       v_uoo_rec.ivrs_available_ind,
             x_call_number                  =>       v_uoo_rec.call_number,
             x_unit_section_status          =>       l_c_usec_status,
             x_unit_section_start_date      =>       l_d_us_dest_start_dt,
             x_unit_section_end_date        =>       l_d_us_dest_end_dt,
             x_enrollment_actual            =>       NULL,
             x_waitlist_actual              =>       NULL,
             x_offered_ind                  =>       v_uoo_rec.offered_ind,
             x_state_financial_aid          =>       v_uoo_rec.state_financial_aid,
             x_grading_schema_prcdnce_ind   =>       v_uoo_rec.grading_schema_prcdnce_ind,
             x_federal_financial_aid        =>       v_uoo_rec.federal_financial_aid,
             x_unit_quota                   =>       v_uoo_rec.unit_quota,
             x_unit_quota_reserved_places   =>       v_uoo_rec.unit_quota_reserved_places,
             x_institutional_financial_aid  =>       v_uoo_rec.institutional_financial_aid,
             x_grading_schema_cd            =>       v_uoo_rec.grading_schema_cd,
             x_gs_version_number            =>       v_latest_gs_version,
             x_unit_contact                 =>       v_unit_contact,
             x_mode                         =>       'R',
             x_org_id                       =>       l_org_id,
             x_ss_enrol_ind                 =>       v_uoo_rec.SS_ENROL_ind,
             x_ss_display_ind               =>       v_uoo_rec.ss_display_ind,  --Added by apelleti as per DLD PSP001-US on 14-JUN-01
             x_owner_org_unit_cd            =>       v_uoo_rec.owner_org_unit_cd,
             x_attendance_required_ind      =>       v_uoo_rec.attendance_required_ind,
             x_reserved_seating_allowed     =>       v_uoo_rec.reserved_seating_allowed,
             x_special_permission_ind       =>       v_uoo_rec.special_permission_ind,
             x_dir_enrollment               =>       v_uoo_rec.dir_enrollment,  --The following three fields were added by Pradhakr
             x_enr_from_wlst                =>       v_uoo_rec.enr_from_wlst,   -- as part of Enrollment Build process (Enh.Bug# 1832130)
             x_inq_not_wlst                 =>       v_uoo_rec.inq_not_wlst,
             --Added the following col according to bug 1882122
             x_rev_account_cd              =>        v_uoo_rec.rev_account_cd , -- lpriyadh for enhacement bug # 1516959
             x_anon_unit_grading_ind       =>        v_uoo_rec.anon_unit_grading_ind ,
             x_anon_assess_grading_ind     =>        v_uoo_rec.anon_assess_grading_ind,
             x_non_std_usec_ind            =>        v_uoo_rec.non_std_usec_ind,
             x_auditable_ind               =>        v_uoo_rec.auditable_ind,
             x_audit_permission_ind        =>        v_uoo_rec.audit_permission_ind,
             x_not_multiple_section_flag   =>        v_uoo_rec.not_multiple_section_flag,
             x_sup_uoo_id                  =>        NULL,
             x_relation_type               =>        'NONE',
             x_default_enroll_flag         =>        v_uoo_rec.default_enroll_flag,
             x_abort_flag                  =>        'N'
             );


           --Procedure to insert the unit section detail records
           igs_ps_gen_001.crsp_ins_unit_section(l_old_uoo_id ,
                                                v_new_uoo_id ,
                                                p_message_name,
                                                p_log_creation_date );

           -- passing p_log_creation_date parameter enhancement bug 1800179 pmarada

           -- increment count to reflect that a successful insert of a IGS_PS_UNIT_OFR_OPT record occurred
           v_uoo_inserted_cnt := v_uoo_inserted_cnt + 1;

         ELSE
           -- if uoo record already exists not perform insert.
           -- lpriyadh enhancement bug# 1516959

           v_new_uoo_id := v_uoo_rec_exists.uoo_id;

           igs_ps_gen_001.crsp_ins_unit_section(l_old_uoo_id ,
                                                v_new_uoo_id ,
                                                p_message_name ,
                                                p_log_creation_date);
           CLOSE c_uoo_rec_exists;
         END IF;  -- checking no other destination record exists with this dest_ci_sequence_number.

       END IF; -- if location_cd, IGS_AS_UNIT_CLASS, grading schema validation is TRUE
    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_008.crsp_ins_uop_uoo.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Section:'||v_uoo_rec.uoo_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
	END IF;
	--This exception handler has been added as a part of bug#2332807
        handle_excp(l_old_uoo_id);
    END;
  END LOOP;       -- c_uoo_source_rec

  BEGIN

      --Call the below procedure for creating the unit section relationship.
      crspl_upd_usec_relation (p_src_cal_type     => p_source_cal_type ,
                               p_src_sequence_num => p_source_ci_sequence_number,
                               p_dst_cal_type     => p_cal_type,
                               p_dst_sequence_num => p_dest_ci_sequence_number );

  EXCEPTION
    WHEN OTHERS THEN
       NULL;
  END;



  /**** Roll Over the Unit Assessment items ******/
  --select the unit assessment items group
  FOR cur_unit_ass_group_rec  IN  cur_unit_ass_group(p_unit_cd,p_version_number,p_source_cal_type,p_source_ci_sequence_number) LOOP
    DECLARE
      CURSOR cur_unitassgrp_new (cp_unit_cd            igs_as_unit_ai_grp.unit_cd%TYPE,
                                 cp_version_number     igs_as_unit_ai_grp.version_number%TYPE,
				 cp_cal_type           igs_as_unit_ai_grp.cal_type%TYPE,
				 cp_ci_sequence_number igs_as_unit_ai_grp.ci_sequence_number%TYPE,
                                 cp_group_name         igs_as_unit_ai_grp.group_name%TYPE) IS
      SELECT unit_ass_item_group_id
      FROM   igs_as_unit_ai_grp
      WHERE  unit_cd = cp_unit_cd
      AND    version_number = cp_version_number
      AND    cal_type = cp_cal_type
      AND    ci_sequence_number= cp_ci_sequence_number
      AND    group_name = cp_group_name;
      l_rowid1                         VARCHAR2(25);
      l_unit_ass_item_group_id        NUMBER;

      CURSOR cur_ass_item(cp_unit_cd                igs_as_unitass_item_all.unit_cd%TYPE,
                          cp_version_number         igs_as_unitass_item_all.version_number%TYPE,
			  cp_cal_type               igs_as_unitass_item_all.cal_type%TYPE,
			  cp_ci_sequence_number     igs_as_unitass_item_all.ci_sequence_number%TYPE,
			  cp_unit_ass_item_group_id igs_as_unitass_item_all.unit_ass_item_group_id%TYPE) IS
      SELECT 'X'
      FROM   igs_as_unitass_item_all
      WHERE  unit_cd = cp_unit_cd
      AND    version_number = cp_version_number
      AND    cal_type = cp_cal_type
      AND    ci_sequence_number = cp_ci_sequence_number
      AND    unit_ass_item_group_id = cp_unit_ass_item_group_id;
      l_c_var  VARCHAR2(1);
    BEGIN
      l_rowid1 :=NULL;
      l_unit_ass_item_group_id := NULL;

      OPEN cur_unitassgrp_new(p_unit_cd,p_version_number,p_cal_type,p_dest_ci_sequence_number,cur_unit_ass_group_rec.group_name);
      FETCH cur_unitassgrp_new INTO l_unit_ass_item_group_id;
      IF cur_unitassgrp_new%NOTFOUND THEN
        igs_as_unit_ai_grp_pkg.insert_row(
	  x_rowid                   => l_rowid1,
          x_unit_ass_item_group_id  => l_unit_ass_item_group_id,
          x_unit_cd                 => p_unit_cd,
          x_version_number          => p_version_number,
          x_cal_type                => p_cal_type,
          x_ci_sequence_number      => p_dest_ci_sequence_number,
          x_group_name              => cur_unit_ass_group_rec.group_name,
          x_midterm_formula_code    => cur_unit_ass_group_rec.midterm_formula_code,
          x_midterm_formula_qty     => cur_unit_ass_group_rec.midterm_formula_qty,
          x_midterm_weight_qty      => cur_unit_ass_group_rec.midterm_weight_qty,
          x_final_formula_code      => cur_unit_ass_group_rec.final_formula_code,
          x_final_formula_qty       => cur_unit_ass_group_rec.final_formula_qty,
          x_final_weight_qty        => cur_unit_ass_group_rec.final_weight_qty
	  );
      END IF;
      CLOSE  cur_unitassgrp_new;

      --Rollover asssessmnet items if there is none for the section and group combination
      OPEN cur_ass_item(p_unit_cd,p_version_number,p_cal_type,p_dest_ci_sequence_number,l_unit_ass_item_group_id);
      FETCH cur_ass_item INTO l_c_var;
      IF cur_ass_item%NOTFOUND THEN
	FOR v_uai_rec IN c_uai_source_rec(p_unit_cd,p_version_number,p_source_cal_type,p_source_ci_sequence_number,cur_unit_ass_group_rec.unit_ass_item_group_id) LOOP
	  BEGIN
	    v_uai_fetched_cnt := v_uai_fetched_cnt +1;
	    -- all of the below conditions must be true for the
	    -- insert to proceed, else don't insert this particular
	    -- IGS_AS_UNITASS_ITEM record

	  -- Validate reference is valid in destination pattern's UAI records
	  v_reference := v_uai_rec.reference;

	  -- This call fetches the assessment type for the assessment Id
	  v_assessment_type := igs_as_gen_001.assp_get_ai_a_type(v_uai_rec.ass_id);

	  -- check if the assessment item is examinable
	  IF igs_as_gen_002.assp_get_atyp_exmnbl(v_assessment_type) = 'Y' THEN
	    -- Validate reference number is unique for examinable items
	    IF igs_as_val_uai.assp_val_uai_uniqref(
						   v_uai_rec.unit_cd,
						   v_uai_rec.version_number,
						   v_uai_rec.cal_type,
						   p_dest_ci_sequence_number,
						   v_uai_rec.sequence_number,
						   v_reference,
						   v_uai_rec.ass_id,
						   v_message_name) = TRUE THEN
	      v_uai_continue := TRUE;
	    ELSE
	      v_uai_continue := FALSE;
	      v_uai_error := TRUE;
	    END IF;
	  ELSE
	    v_uai_continue := TRUE;
	    -- Validate reference number is unique for non-examinable items
	    IF igs_as_val_uai.assp_val_uai_opt_ref(
						  v_uai_rec.unit_cd,
						  v_uai_rec.version_number,
						  v_uai_rec.cal_type,
						  p_dest_ci_sequence_number,
						  v_uai_rec.sequence_number,
						  v_reference,
						  v_uai_rec.ass_id,
						  v_assessment_type,
						  v_message_name) = FALSE THEN

	      IF  igs_as_gen_002.assp_get_ai_s_type ( v_uai_rec.ass_id) <> 'ASSIGNMENT' THEN
		v_uai_continue  := TRUE;
		v_reference     := NULL;
	      ELSE
		v_uai_continue  := FALSE;
		v_uai_error     := TRUE;
	      END IF;

	    ELSE
	      IF  NVL(v_reference, 'NULL') = 'NULL' AND
		igs_as_gen_002.assp_get_ai_s_type ( v_uai_rec.ass_id) = 'ASSIGNMENT' THEN
		v_uai_continue  := FALSE;
		v_uai_error     := TRUE;
	      END IF;
	    END IF;
	  END IF; -- if examinable


	  IF v_uai_continue = TRUE THEN
	    crspl_get_new_exam_cal(
				   v_uai_rec.exam_cal_type,
				   v_uai_rec.exam_ci_sequence_number,
				   v_exam_cal_type,
				   v_exam_ci_sequence_number,l_old_uoo_id);
	    OPEN c_uai_seq_num;
	    FETCH c_uai_seq_num INTO v_uai_seq_num;
	    CLOSE c_uai_seq_num;

	    -- Perform insert uai record
	    x_rowid :=      NULL;
	    l_unit_ass_item_id := NULL;

	    igs_as_unitass_item_pkg.insert_row(
		x_rowid                       => x_rowid,
		x_unit_cd                     => p_unit_cd,
		x_version_number              => p_version_number,
		x_cal_type                    => p_cal_type,
		x_ci_sequence_number          => p_dest_ci_sequence_number,
		x_ass_id                      => v_uai_rec.ass_id,
		x_sequence_number             => v_uai_seq_num,
		x_ci_start_dt                 => v_uai_rec.ci_start_dt,
		x_ci_end_dt                   => v_uai_rec.ci_end_dt,
		x_unit_class                  => v_uai_rec.unit_class,
		x_unit_mode                   => v_uai_rec.unit_mode,
		x_location_cd                 => v_uai_rec.location_cd,
		x_due_dt                      => NULL,
		x_reference                   => v_reference,
		x_dflt_item_ind               => v_uai_rec.dflt_item_ind,
		x_logical_delete_dt           => NULL,
		x_action_dt                   => NULL,
		x_exam_cal_type               => v_exam_cal_type,
		x_exam_ci_sequence_number     => v_exam_ci_sequence_number,
		x_mode                        => 'R',
		x_org_id                      => igs_ge_gen_003.get_org_id,
		x_grading_schema_cd           => v_uai_rec.grading_schema_cd,
		x_gs_version_number           => v_uai_rec.gs_version_number,
		x_release_date                => v_uai_rec.release_date,
		x_unit_ass_item_id            => l_unit_ass_item_id, --out parameter
		x_description                 => v_uai_rec.description,
		x_unit_ass_item_group_id      => l_unit_ass_item_group_id,
		x_midterm_mandatory_type_code => v_uai_rec.midterm_mandatory_type_code,
		x_midterm_weight_qty          => v_uai_rec.midterm_weight_qty,
		x_final_mandatory_type_code   => v_uai_rec.final_mandatory_type_code,
		x_final_weight_qty            => v_uai_rec.final_weight_qty
		);

	   v_uai_inserted_cnt := v_uai_inserted_cnt + 1;
	END IF; -- v_uai_continue

	EXCEPTION
	  WHEN OTHERS THEN
	    --Fnd log implementation
	    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_008.crsp_ins_uop_uoo.in_exception_section_OTHERS.err_msg',
	      SUBSTRB('unit ass item id-Pattern:'||v_uai_rec.unit_ass_item_id||'  '||
	      NVL(fnd_message.get,SQLERRM),1,4000));
            END IF;
	END;
      END LOOP; -- c_uai_source_rec
    END IF;
    CLOSE cur_ass_item;


    EXCEPTION
      WHEN OTHERS THEN
	--Fnd log implementation
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_008.crsp_ins_uop_uoo.in_exception_section_OTHERS.err_msg',
	  SUBSTRB('Unit Ass Item Group Id-Pattern:'||cur_unit_ass_group_rec.unit_ass_item_group_id||'  '||
	  NVL(fnd_message.get,SQLERRM),1,4000));
        END IF;

        IF cur_unitassgrp_new%ISOPEN THEN
          CLOSE  cur_unitassgrp_new;
        END IF;
    END;
  END LOOP; -- cur_unit_ass_group


  -- The following block of code covers all possible cases described
  -- in the "outcome grid" of the specification document.
  -- ie, (6 rows * 6 cols) = 36 cases.  From Left->Right; Top->Down;
  -- ref spec: row 1 in the outcome grid.
  -- no uoo records were selected

  IF (c_uoo_source_rec%ROWCOUNT = 0) THEN
    -- no uai records were selected
    IF (v_uai_fetched_cnt = 0) THEN
      p_message_name := 'IGS_PS_NO_UOO_AND_UAI_ROLLED';
      v_ret_val := TRUE;
    -- no uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = FALSE) THEN
      p_message_name := 'IGS_PS_UOO_NO_UOO_TOBE_ROLLED';
      v_ret_val := TRUE;
    -- no uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = TRUE) THEN
      p_message_name := 'IGS_PS_INV_NO_UOO_ROLLED';
      v_ret_val := FALSE;
    -- partial uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = FALSE) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UOO_USI';
      ELSE
        p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      END IF;
      v_ret_val := TRUE;
    -- partial uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = TRUE)  THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTILROLL_USI';
      ELSE
        p_message_name := 'IGS_PS_PRINV_NO_UOO_ROLLED';
      END IF;
      v_ret_val := FALSE;
    -- all uai inserted
    ELSIF   (v_uai_inserted_cnt = v_uai_fetched_cnt) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_SUCCESS_ROLL_UOO_UAI';
      ELSE
        p_message_name := 'IGS_PS_SUCCESSROLL_UOO_UAI';
      END IF;
      v_ret_val := TRUE;
    END IF;
  -- ref spec: row 2 in the outcome grid.
  -- no uoo inserted, uoo error NOT flagged
  ELSIF ( v_uoo_inserted_cnt = 0 AND v_uoo_error = FALSE)    THEN
    -- no uai records were selected
    IF (v_uai_fetched_cnt = 0)      THEN
      p_message_name := 'IGS_PS_UOO_NO_UAI_TOBE_ROLLED';
      v_ret_val := TRUE;
    -- no uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = FALSE) THEN
      p_message_name := 'IGS_PS_NO_UOO_UAI_ROLLED';
      v_ret_val := TRUE;
    -- no uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = TRUE)  THEN
      p_message_name := 'IGS_PS_INV_UOO_ROLLED';
      v_ret_val := FALSE;
    -- partial uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = FALSE) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UOO_USI';
      ELSE
        p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      END IF;
      v_ret_val := TRUE;
    -- partial uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = TRUE)  THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARROLL_UAI_INVLD_DATA';
      ELSE
        p_message_name := 'IGS_PS_PRINV_NO_UOO_OBS_DATA';
      END IF;
      v_ret_val := FALSE;
    -- all uai inserted
    ELSIF   (v_uai_inserted_cnt = v_uai_fetched_cnt) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UOO_USI';
      ELSE
        p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      END IF;
      v_ret_val := TRUE;
    END IF;
  -- ref spec: row 3 in the outcome grid.
  -- no uoo inserted, uoo error flagged
  ELSIF ( v_uoo_inserted_cnt = 0 AND v_uoo_error = TRUE) THEN
    -- no uai records were selected
    IF (v_uai_fetched_cnt = 0)      THEN
      p_message_name := 'IGS_PS_INV_NO_UAI_TOBE_ROLLED';
      v_ret_val := FALSE;
    -- no uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = FALSE) THEN
      p_message_name := 'IGS_PS_INV_NO_UAI_OBS_DATA';
      v_ret_val := FALSE;
    -- no uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = TRUE) THEN
      p_message_name := 'IGS_PS_INV_NO_UAI_OBS_DATA';
      v_ret_val := FALSE;
    -- partial uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error = FALSE) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_INVALID_DATA';
      ELSE
        p_message_name := 'IGS_PS_INV_UAI_PAR_ROLL';
      END IF;
      v_ret_val := FALSE;
    -- partial uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error = TRUE)  THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARROLL_USI_INVALID';
      ELSE
        p_message_name := 'IGS_PS_PRINV_NO_UOO_INVALID';
      END IF;
      v_ret_val := FALSE;
    -- all uai inserted
    ELSIF   (v_uai_inserted_cnt = v_uai_fetched_cnt) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_NOTROLLED_INVALID_DATA';
      ELSE
        p_message_name := 'IGS_PS_INV_ALL_UAI_ROLLED';
      END IF;
      v_ret_val := FALSE;
    END IF;
  -- ref spec: row 4 in the outcome grid.
  -- partial uoo inserted, uoo error NOT flagged
  ELSIF ((v_uoo_inserted_cnt < c_uoo_source_rec%ROWCOUNT OR v_tro_recs_skipped = TRUE) AND v_uoo_error = FALSE) THEN
    -- no uai records were selected
    IF (v_uai_fetched_cnt = 0)      THEN
      p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      v_ret_val := TRUE;
    -- no uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = FALSE) THEN
      p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      v_ret_val := TRUE;
    -- no uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = TRUE)          THEN
      p_message_name := 'IGS_PS_INV_PARROLL_UOO_OBSDAT';
      v_ret_val := FALSE;
    -- partial uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = FALSE) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UOO_USI';
      ELSE
        p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      END IF;
      v_ret_val := TRUE;
    -- partial uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = TRUE)  THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UAI';
      ELSE
        p_message_name := 'IGS_PS_PRINV_PARROL_UOO_OBS';
      END IF;
      v_ret_val := FALSE;
    -- all uai inserted
    ELSIF   (v_uai_inserted_cnt = v_uai_fetched_cnt) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UOO_USI';
      ELSE
        p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      END IF;
      v_ret_val := TRUE;
    END IF;
  -- ref spec: row 5 in the outcome grid.
  -- partial uoo inserted, uoo error flagged
  ELSIF ((v_uoo_inserted_cnt < c_uoo_source_rec%ROWCOUNT OR v_tro_recs_skipped = TRUE) AND v_uoo_error = TRUE) THEN
    -- no uai records were selected
    IF (v_uai_fetched_cnt = 0)      THEN
      p_message_name := 'IGS_PS_PRINV_PARROL_UOO_OBS';
      v_ret_val := FALSE;
    -- no uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = FALSE) THEN
      p_message_name := 'IGS_PS_PRINV_NO_UAI_ROL_OBS';
      v_ret_val := FALSE;
    -- no uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = TRUE)          THEN
      p_message_name := 'IGS_PS_PRINV_NO_UAI_INVALID';
      v_ret_val := FALSE;
    -- partial uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = FALSE) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UOO_INVALI';
      ELSE
        p_message_name := 'IGS_PS_PRINV_PARROLL_UAI';
      END IF;
      v_ret_val := FALSE;
    -- partial uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = TRUE)  THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARROLL_UOO_AND_UAI';
      ELSE
        p_message_name := 'IGS_PS_PRINV_UOO_UAI';
      END IF;
      v_ret_val := FALSE;
    -- all uai inserted
    ELSIF   (v_uai_inserted_cnt = v_uai_fetched_cnt) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UOO_INVDAT';
      ELSE
        p_message_name := 'IGS_PS_PRINV_ALL_UAI_ROLLED';
      END IF;
      v_ret_val := FALSE;
    END IF;
  -- ref spec: row 6 in the outcome grid.
  -- all uoo inserted
  ELSIF (v_uoo_inserted_cnt = c_uoo_source_rec%ROWCOUNT) THEN
    -- no uai records were selected
    IF (v_uai_fetched_cnt = 0)      THEN
      p_message_name := 'IGS_PS_SUCCESSROLL_UOO_UAI';
      v_ret_val := TRUE;
    -- no uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = FALSE) THEN
      p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      v_ret_val := TRUE;
    -- no uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt = 0 AND v_uai_error    = TRUE)          THEN
      p_message_name := 'IGS_PS_INV_ALL_UOO_ROLLED';
      v_ret_val := FALSE;
    -- partial uai inserted, uai error NOT flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = FALSE) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UOO_USI';
      ELSE
        p_message_name := 'IGS_PS_PARROLL_UOO_UAI';
      END IF;
      v_ret_val := TRUE;
    -- partial uai inserted, uai error flagged
    ELSIF   (v_uai_inserted_cnt < v_uai_fetched_cnt AND v_uai_error    = TRUE)  THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_PARTIALROLL_UAI_UAIINV';
      ELSE
        p_message_name := 'IGS_PS_PRINV_ALL_UOO_ROLLED';
      END IF;
      v_ret_val := FALSE;
    -- all uai inserted
    ELSIF   (v_uai_inserted_cnt = v_uai_fetched_cnt) THEN
      IF v_successful_pattern_mbr = FALSE THEN
        p_message_name := 'IGS_PS_SUCCESS_ROLL_UOO_UAI';
      ELSE
        p_message_name := 'IGS_PS_SUCCESSROLL_UOO_UAI';
      END IF;
      v_ret_val := TRUE;
    END IF;
  END IF;

  IF c_uoo_source_rec%ISOPEN THEN
     CLOSE c_uoo_source_rec;
  END IF;

  --Added by sarakshi, as a part of bug#2332807
  --If no record has been entered in details table igs_ge_s_loog_entry
  --then delete the parent record.
  OPEN cur_check(p_log_creation_date);
  FETCH cur_check INTO l_var;
  IF  cur_check%NOTFOUND THEN
    igs_ge_s_log_pkg.delete_row(x_rowid=>l_rowid);
  END IF;
  CLOSE cur_check;

  RETURN v_ret_val;

EXCEPTION
  WHEN OTHERS THEN
    IF c_uoo_source_rec%ISOPEN THEN
      CLOSE c_uoo_source_rec;
    END IF;
    IF c_uop_dest_rec%ISOPEN THEN
      CLOSE c_uop_dest_rec;
    END IF;
    IF c_uai_source_rec%ISOPEN THEN
      CLOSE c_uai_source_rec;
    END IF;
    IF c_uoo_rec_exists%ISOPEN THEN
      CLOSE c_uoo_rec_exists;
    END IF;
    IF c_latest_gs_version%ISOPEN THEN
      CLOSE c_latest_gs_version;
    END IF;
    IF c_uoo_seq_num%ISOPEN THEN
      CLOSE c_uoo_seq_num;
    END IF;
    App_Exception.Raise_Exception;
END;

 -- jbegum As part of bug#2563596 the call to IGS_GE_GEN_003.genp_ins_log_entry was modified .
 -- The concatenated string being passed to parameter p_key has the substring FND_MESSAGE.GET_STRING('IGS', p_message_name)
 -- removed as this was causing the TBH procedure IGS_GE_S_LOG_ENTRY_PKG.INSERT_ROW to throw up an invalid value error,which
 -- was in turn causing function IGS_PS_GEN_008.crsp_ins_uop_uoo to throw up an unhandled exception.
 -- Also the concatenated string being passed to parameter p_text has only p_message_name concatenated to it instead of
 -- FND_MESSAGE.GET_STRING('IGS', p_message_name)

--Enhancement bug 1800179, pmarada
-- insert record into log entry table

EXCEPTION
  WHEN OTHERS THEN
    DECLARE
      CURSOR cur_org_unit (cp_uoo_id IN NUMBER) IS
      SELECT   owner_org_unit_cd
      FROM     igs_ps_unit_ofr_opt
      WHERE    uoo_id = cp_uoo_id;
      lcur_org_unit cur_org_unit%rowtype;
    BEGIN
      --Fnd log implementation
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_008.crsp_ins_uop_uoo.in_exception_section_OTHERS.err_msg',
	SUBSTRB('From the Main Exception of crsp_ins_uop_uoo'||'  '||
	NVL(fnd_message.get,SQLERRM),1,4000));
      END IF;

      OPEN cur_org_unit (l_old_uoo_id);
      FETCH cur_org_unit INTO lcur_org_unit;

      IGS_GE_GEN_003.genp_ins_log_entry (
      'USEC-ROLL' ,
      p_log_creation_date,     -- This will be accepted AS parameter AND defaulted TO NULL;
      lcur_org_unit.owner_org_unit_cd || ',' || l_old_uoo_id || ',' || p_source_cal_type ||
      ',' || p_source_ci_sequence_number,
      NULL,
      lcur_org_unit.owner_org_unit_cd || ',' || l_old_uoo_id || ',' || p_source_cal_type ||
      ',' || p_source_ci_sequence_number || ',' || p_message_name);

      CLOSE cur_org_unit;
    END;
END crsp_ins_uop_uoo;

END igs_ps_gen_008;

/
