--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_009
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_009" AS
/* $Header: IGSEN09B.pls 120.1 2005/09/30 02:59:37 appldev ship $ */

--Added refernces to column ORG_UNIT_CD incall to IGS_EN_SU_ATTEMPT TBH call as a part of bug 1964697
--sarakshi     16-Nov-2004   Enh#4000939, added column APPROVED_DATE,EFFECTIVE_TERM_CAL_TYPE,EFFECTIVE_TERM_SEQUENCE_NUM and
--                           DISCONTINUE_SOURCE_FLAG in the insert row call of IGS_PS_STDNT_TRN_PKG in procedure Enrp_Ins_Sct_Trnsfr
-- pradhakr    16-Dec-2002   Changed the call to the update_row of igs_en_su_attempt
--                           table to igs_en_sua_api.update_unit_attempt.
--                           Changes wrt ENCR031 build. Bug#2643207
-- Aiyer     10-Oct-2001    Added the columns grading schema code and gs_version_number in all Tbh calls of IGS_EN_SU_ATTEMPT_PKG as a part of the bug 2037897.
-- kkillams  13-11-2001     Added the columns primary_program_type, primary_prog_type_source, catalog_cal_type, catalog_seq_num,key_program as part of the bug 2027984
-- Nalin Kumar 23-Nov-2001  Added enrp_ins_award_aim procedure as the part of
--              UK Award Aims DLD Bug ID: 1366899
-- pradhakr   06-Dec-2001   Added a column deg_aud_detail_id in the TBH call of IGS_EN_SU_ATTEMPT as part of
--              Degree Audit Interface build (Bug# 2033208)
-- svenkata   20-Dec-2001   Added columns student_career_transcript and Student_career_statistics as part of build Career
--                          Impact Part2 . Bug #2158626
-- svenkata   7-JAN-2002    Bug No. 2172405  Standard Flex Field columns have been added
--                          to table handler procedure calls as part of CCR - ENCR022.
--Nishikant  30-jan-2002     Added the column session_id  in the Tbh calls of IGS_EN_SU_ATTEMPT_PKG
--                           as a part of the bug 2172380.
-- svenkata 25-02-02     Removed the procedure ENRP_INS_ENRL_FORM as part of CCR
--                           ENCR024 .Bug # 2239050
-- Nishikant  13- JUN-2002       The code got modified to set the out NOCOPY parameter p_message instead of 'IGS_EN_NOT_CUR_ENROL'. as per the bug#2413811.
-- pradhakr   23-Sep-2002    Added a new parameter p_units_indicator in the package spec and body
--               as part of Core Vs Optional DLD. Bug# 2581270
-- amuthu     10-JUN-2003     modified as per the UK Streaming and Repeat TD (bug 2829265)
-- kkillams 17-Jun-2003       Three New parameters are added to Enrp_Ins_Pre_Pos function
--                            w.r.t. bug 3829270
-- ptandon     7-Oct-2003   Modified the existing function Enrp_Ins_Pre_Pos and Added a new Function Enrp_Check_Usec_Core as
--                          part of Prevent Dropping Core Units build. Enh Bug#3052432.

-- svanukur  18-oct-2003    modified enrp_ins_pre_pos as part of placements build 3052438 to process superior units first.
-- rvangala  02-Dec-2003    Added 4 new parameters to enrp_ins_sca_hist
-- bdeviset  11-DEC-2004   Added extra parameters to Enrp_Ins_Sct_Trnsfr as UOOID_TO_TRANSFER,SUSA_TO_TRANSFER, TRANSFER_ADV_STAND_FLAG transfer table
-- amuthu    05-JAN-2005   Added new method for deriving the core indicator value for the destinations program attempt in a transfer enrp_chk_dest_usec_core
-- ckasu     29-SEP-2005   Modfied signature of enrp_chk_dest_usec_core inorder to include cooid as a part of bug #4278867

 l_smil_id     IGS_EN_MERGE_ID_LOG.SMIL_id%TYPE;

PROCEDURE Enrp_Ins_Dflt_Effect(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_message_string IN OUT NOCOPY VARCHAR2 )
AS


BEGIN   -- enrp_ins_dflt_effect
    -- Insert the default IGS_PE_PERSENC_EFFCT's for a IGS_PE_PERS_ENCUMB
    -- base on the encumbrance_type and its associated encmb_type_dflt_effects.
    -- This procedure should only be called on createion of a IGS_PE_PERS_ENCUMB
    -- record
DECLARE
    v_closed_ind        VARCHAR2(1);
    v_error_ind     NUMBER(5) := 0;
    v_apply_to_course_ind   IGS_EN_ENCMB_EFCTTYP_V.apply_to_course_ind%TYPE;
    v_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
    v_pee_seq_num       IGS_PE_PERSENC_EFFCT.sequence_number%TYPE;
    v_message_string        VARCHAR2(5512);
    v_return_type       VARCHAR2(1);
    CURSOR c_s_encmb_effect_type (
            cp_s_encmb_effect_type IGS_EN_ENCMB_EFCTTYP_V.s_encmb_effect_type%TYPE) IS
        SELECT  closed_ind
        FROM    IGS_EN_ENCMB_EFCTTYP_V
        WHERE   s_encmb_effect_type = cp_s_encmb_effect_type;
    CURSOR c_encmb_type_dflt_effect IS
        SELECT  eft.*,
                seft.description encmb_meaning
        FROM    IGS_FI_ENC_DFLT_EFT     eft,
                IGS_EN_ENCMB_EFCTTYP_V  seft
        WHERE   eft.encumbrance_type = p_encumbrance_type          AND
                eft.s_encmb_effect_type = seft.s_encmb_effect_type;

    CURSOR c_get_apply_to_crs_ind (cp_s_encmb_effect_type
                IGS_FI_ENC_DFLT_EFT.s_encmb_effect_type%TYPE) IS
        SELECT apply_to_course_ind
        FROM    IGS_EN_ENCMB_EFCTTYP_V
        WHERE   s_encmb_effect_type = cp_s_encmb_effect_type;
    CURSOR c_student_course_attempt IS
        SELECT course_cd
        FROM    IGS_EN_STDNT_PS_ATT
        WHERE   person_id = p_person_id     AND
            course_attempt_status NOT IN ('DISCONTIN', 'COMPLETED', 'DELETED', 'LAPSED',
'UNCONFIRM');

BEGIN
    p_message_name := NULL;
    -- Set message 'Default effect results : ';
    fnd_message.set_name('IGS','IGS_EN_DFLT_EFFECT_RESULT');
    IGS_GE_MSG_STACK.ADD;
    fnd_message.set_name('IGS','IGS_EN_DFLT_EFFECT_RESULT');
    -- validate the input parameters
    IF (p_person_id IS NULL OR
            p_encumbrance_type IS NULL OR
            p_start_dt IS NULL) THEN
        RETURN;
    END IF;
    FOR v_etde_rec IN c_encmb_type_dflt_effect LOOP
        -- Check that the effect type is open
        OPEN c_s_encmb_effect_type(v_etde_rec.s_encmb_effect_type);
        FETCH c_s_encmb_effect_type INTO v_closed_ind;
        IF (v_closed_ind = 'Y') THEN
            fnd_message.set_name('IGS' , 'IGS_EN_CLOSE_NOT_CREATED');
            v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
                        v_etde_rec.encmb_meaning || ' ' ||
                        fnd_message.get;
--                      ' - closed, not created ';
            CLOSE c_s_encmb_effect_type;
            GOTO CONTINUE;
        END IF;
        CLOSE c_s_encmb_effect_type;
        -- This effect cannot be applied if a IGS_PE_PERSON is still enrolled in a IGS_PS_COURSE
        IF (v_etde_rec.s_encmb_effect_type = 'RVK_SRVC') THEN
            IF (IGS_EN_VAL_PEE.enrp_val_pee_sca(
                    p_person_id,
                    p_message_name) = FALSE) THEN
                -- This IGS_PE_PERSON is currently enrolled in IGS_PS_COURSE(s),
                -- effect type can not be created
                v_error_ind := v_error_ind + 1;
                -- The code modified by Nishikant - 13Jun2002 - as per bug#2413811
                -- Below the code got modified to set the out NOCOPY parameter p_message of the above function call
                -- instead of 'IGS_EN_NOT_CUR_ENROL'
                fnd_message.set_name('IGS' , p_message_name);
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
                        v_etde_rec.encmb_meaning ||' ' ||
                        fnd_message.get;
--                          'RVK_SRVC - not created ' ||
--                          'due to current enrolment';
                GOTO CONTINUE;
            END IF;
        END IF;
        -- check if selected s_encmb_effect_type applies to a IGS_PS_COURSE
        OPEN c_get_apply_to_crs_ind(v_etde_rec.s_encmb_effect_type);
        FETCH c_get_apply_to_crs_ind INTO v_apply_to_course_ind;
        CLOSE c_get_apply_to_crs_ind;
        IF (v_apply_to_course_ind = 'N') THEN
            -- no need to set the IGS_PS_COURSE
            v_course_cd := NULL;
        ELSIF (p_course_cd IS NOT NULL) THEN
        -- Validate that IGS_PE_PERSON is enrolled in the IGS_PS_COURSE.
            IF IGS_EN_VAL_PEE.enrp_val_pee_crs (
                p_person_id,
                p_course_cd,
                p_message_name) = FALSE THEN
                -- This IGS_PE_PERSON is not enrolled in IGS_PS_COURSE,
                -- IGS_PS_COURSE cannot be set
                v_course_cd := NULL;
            ELSE
                v_course_cd := p_course_cd;
            END IF;
        ELSE --(p_course_cd IS NULL)
            -- find each IGS_PS_COURSE the IGS_PE_PERSON is currently enrolled in
            OPEN c_student_course_attempt;
            LOOP
                FETCH c_student_course_attempt INTO v_course_cd;
                EXIT WHEN c_student_course_attempt%NOTFOUND;
            END LOOP;
            IF (c_student_course_attempt%ROWCOUNT = 1) THEN
                -- IGS_PE_PERSON is enrolled in one IGS_PS_COURSE
                -- v_course_cd is assigned by c_student_course_attempt.course_cd
                CLOSE c_student_course_attempt;
            ELSIF (c_student_course_attempt%ROWCOUNT > 1) THEN
                -- IGS_PE_PERSON is enrolled in more than one IGS_PS_COURSE
                v_error_ind := v_error_ind + 1;
                fnd_message.set_name('IGS' , 'IGS_EN_NC_MULTI_CUR_ENR');
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
                            v_etde_rec.encmb_meaning || ' ' ||
--                          v_etde_rec.s_encmb_effect_type || ' ' ||
                            fnd_message.get;
--                          'not created due to multiple current enrolments';
                CLOSE c_student_course_attempt;
                GOTO CONTINUE;
            ELSE
                -- IGS_PE_PERSON is not enrolled
                v_error_ind := v_error_ind + 1;
                fnd_message.set_name('IGS' , 'IGS_EN_NC_NO_CUR_ENR');
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                              v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                                    fnd_message.get;
--                              'not created due to no current enrolment';
                CLOSE c_student_course_attempt;
                GOTO CONTINUE;
            END IF;
        END IF;
        -- Validate if IGS_PE_PERSON already has a restricted attendance type encumbrance
        -- applied to the target IGS_PS_COURSE.  If so, don't create another.
        IF v_course_cd IS NOT NULL AND
            v_etde_rec.s_encmb_effect_type = 'RSTR_AT_TY' THEN
            IF IGS_EN_VAL_PEE.enrp_val_pee_crs_att(
                    p_person_id,
                    v_etde_rec.s_encmb_effect_type,
                    0,
                    v_course_cd,
                    p_message_name) = FALSE THEN
                v_error_ind := v_error_ind + 1;
                fnd_message.set_name('IGS' , 'IGS_EN_NC_EXIST_REC_CONFLICT');
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                              v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                                fnd_message.get;
--                              'not created due to existing record conflict';
                GOTO CONTINUE;
            END IF;
        END IF;
        -- Validate if IGS_PE_PERSON already has a restricted credit point encumbrance
        -- applied to the target IGS_PS_COURSE.  If so, don't create another.
        IF v_course_cd IS NOT NULL AND
            v_etde_rec.s_encmb_effect_type IN ('RSTR_LE_CP','RSTR_GE_CP') THEN
            IF IGS_EN_VAL_PEE.enrp_val_pee_crs_cp(
                    p_person_id,
                    v_etde_rec.s_encmb_effect_type,
                    0,
                    v_course_cd,
                    p_message_name) = FALSE THEN
                v_error_ind := v_error_ind + 1;
                fnd_message.set_name('IGS' , 'IGS_EN_NC_EXIST_REC_CONFLICT');
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                              v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                                    fnd_message.get;
--                              'not created due to existing record conflict';
                GOTO CONTINUE;
            END IF;
        END IF;
        SELECT  IGS_PE_PERSENC_EFFCT_SEQ_NUM_S.NEXTVAL
        INTO    v_pee_seq_num
        FROM    DUAL;
            -- Call Table Handler
            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN
        IGS_PE_PERSENC_EFFCT_PKG.INSERT_ROW (
                  x_rowid => l_rowid,
                  x_person_id => p_person_id,
            x_encumbrance_type => p_encumbrance_type,
            x_pen_start_dt => p_start_dt,
            x_s_encmb_effect_type => v_etde_rec.s_encmb_effect_type,
            x_pee_start_dt => p_start_dt,
            x_sequence_number => v_pee_seq_num,
            x_expiry_dt => p_expiry_dt,
            x_course_cd => v_course_cd,
            X_RESTRICTED_ENROLMENT_CP => NULL,
            X_RESTRICTED_ATTENDANCE_TYPE => NULL,
            X_MODE => 'R'
            );
            END;
                -- End of TBH
        IF v_etde_rec.s_encmb_effect_type IN (
                    'RSTR_GE_CP','RSTR_LE_CP','RSTR_AT_TY') THEN
            fnd_message.set_name('IGS' , 'IGS_EN_CR_EXTRA_DTL_REQ');
            v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
                        v_etde_rec.encmb_meaning || ' ' ||
--                          v_etde_rec.s_encmb_effect_type || ' ' ||
                             fnd_message.get;
--                          'created, extra detail required';
        ELSIF v_etde_rec.s_encmb_effect_type IN (
                    'EXC_CRS_GP','EXC_CRS_U','RQRD_CRS_U') THEN
                    fnd_message.set_name('IGS' , 'IGS_EN_CR_EXTRA_DTL_REQ');
            v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                          v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                            fnd_message.get;
--                          'created, extra detail required';
        ELSIF v_etde_rec.s_encmb_effect_type NOT IN (
                    'EXC_COURSE','SUS_COURSE') THEN
                    fnd_message.set_name('IGS' , 'IGS_EN_CR_SUCCESS');
            v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                          v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                                 fnd_message.get;
--                          'created successfully';
        ELSE
            NULL;
        END IF;
        IF (v_etde_rec.s_encmb_effect_type = 'EXC_COURSE' AND
                p_course_cd IS NOT NULL) THEN
            -- This effect cannot be applied if a IGS_PE_PERSON is still enrolled in the IGS_PS_COURSE
            IF (IGS_EN_VAL_PCE.enrp_val_pce_crs(
                    p_person_id,
                    p_course_cd,
                    p_start_dt,
                    p_message_name,
                    v_return_type) = FALSE) THEN
                -- This IGS_PE_PERSON is currently enrolled in the IGS_PS_COURSE,
                -- effect type can not be created
                fnd_message.set_name('IGS' , 'IGS_EN_CR_EXTRA_DTL_REQ');
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
                            v_etde_rec.encmb_meaning ||
                                fnd_message.get ;
                            --  'EXC_COURSE - created, ' ||
                            --  'extra detail required';
            ELSE
                                -- Call the Table Handler
            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN
                IGS_PE_COURSE_EXCL_PKG.INSERT_ROW(
                                        x_rowid => l_rowid,
                    x_person_id => p_person_id,
                    x_encumbrance_type => p_encumbrance_type,
                    x_pen_start_dt => p_start_dt,
                    x_s_encmb_effect_type => v_etde_rec.s_encmb_effect_type,
                    x_pee_start_dt  =>  p_start_dt,
                    x_pee_sequence_number => v_pee_seq_num,
                    x_course_cd => p_course_cd,
                    x_pce_start_dt => p_start_dt,
                    x_expiry_dt => p_expiry_dt,
                    x_mode => 'R'
                                       );
               END;
               fnd_message.set_name('IGS' , 'IGS_EN_CR_SUCCESS');
        v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                  v_etde_rec.s_encmb_effect_type || ' ' ||
                v_etde_rec.encmb_meaning || ' ' ||
                    fnd_message.get ;
--              'created successfully';
            END IF;
        ELSE
        IF (v_etde_rec.s_encmb_effect_type = 'SUS_COURSE' AND
            p_course_cd IS NOT NULL) THEN
            -- This effect cannot be applied if a IGS_PE_PERSON is still enrolled in the IGS_PS_COURSE
            IF (IGS_EN_VAL_PCE.enrp_val_pce_crs(
                    p_person_id,
                    p_course_cd,
                    p_start_dt,
                    p_message_name,
                    v_return_type) = FALSE) THEN
                -- This IGS_PE_PERSON is currently enrolled in the IGS_PS_COURSE,
                -- effect type can not be created
                  fnd_message.set_name('IGS' , 'IGS_EN_CR_EXTRA_DTL_REQ');
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                          v_etde_rec.encmb_meaning ||
                            v_etde_rec.encmb_meaning || ' ' ||
                                fnd_message.get ;
--                          'SUS_COURSE - created, ' ||
--                          'extra detail required';
            ELSE
                                --Call the Table Handler
            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN
                IGS_PE_COURSE_EXCL_PKG.INSERT_ROW(
                                        x_rowid => l_rowid,
                    x_person_id => p_person_id,
                    x_encumbrance_type => p_encumbrance_type,
                    x_pen_start_dt => p_start_dt,
                    x_s_encmb_effect_type => v_etde_rec.s_encmb_effect_type,
                    x_pee_start_dt => p_start_dt,
                    x_pee_sequence_number => v_pee_seq_num,
                    x_course_cd => p_course_cd,
                    x_pce_start_dt => p_start_dt,
                    x_expiry_dt => p_expiry_dt,
                    x_mode => 'R'
                                       );
               END;
                IF p_expiry_dt IS NULL THEN
                  fnd_message.set_name('IGS' , 'IGS_EN_CR_EXP_DT_REQ');
                    v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                                  v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                                    fnd_message.get;
--                              'created, expiry date required';
                ELSE
                  fnd_message.set_name('IGS' , 'IGS_EN_CR_SUCCESS');
                    v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                              v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                                fnd_message.get;
--                              'created successfully';
                END IF;
            END IF;
        ELSE
        IF (v_etde_rec.s_encmb_effect_type IN ('EXC_COURSE', 'SUS_COURSE') AND
            p_course_cd IS NULL) THEN
              fnd_message.set_name('IGS' , 'IGS_EN_CR_EXP_DT_REQ');
            v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                      v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                        fnd_message.get;
--                      'created, extra detail required';
        ELSE
        IF v_etde_rec.s_encmb_effect_type = 'SUS_COURSE' THEN
            IF p_expiry_dt IS NULL THEN
              fnd_message.set_name('IGS' , 'IGS_EN_CR_EXP_DT_REQ');
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                              v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                                   fnd_message.get;
--                                  'created, expiry date required';
            ELSE
              fnd_message.set_name('IGS' , 'IGS_EN_CR_SUCCESS');
                v_message_string := v_message_string || FND_GLOBAL.LOCAL_CHR(10) ||
--                          v_etde_rec.s_encmb_effect_type || ' ' ||
                        v_etde_rec.encmb_meaning || ' ' ||
                               fnd_message.get;
--                                  'created successfully';
            END IF;
        END IF;
        END IF;
        END IF;
        END IF;
        <<CONTINUE>>
        -- reset
        v_course_cd := NULL;
    END LOOP;
    IF (v_error_ind > 0) THEN
        -- There were records which could not be created
        p_message_name := 'IGS_EN_MULT_DFLT_ENCUMB';
    END IF;
    fnd_message.set_name('IGS','IGS_EN_DFLT_EFFECT_RESULT');
    fnd_message.set_token('PARAM1',v_message_string);
    p_message_string := v_message_string;
        --
        -- Write the following code in the form that calls this program directly / indirectly for message display
        --
        -- if v_message_name is not null then
        --    fnd_message.set_name('IGS',v_message_name);
        --    fnd_message.show;
        -- end if;
        -- fnd_message.retrieve;
        -- fnd_message.show;
        --
END;
END enrp_ins_dflt_effect;

  PROCEDURE enrp_ins_award_aim (
    p_person_id                         IN     NUMBER,
    p_course_cd                         IN     VARCHAR2,
    p_version_number                    IN     NUMBER,
    p_start_dt                          IN     DATE
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Added this procedure as per the UK Award Aims DLD.
  ||            This will get called from the igs_en_stdnt_ps_att_pkg.
  ||  Change History :
  ||  Who       When          What
  ||  anilk     30-Sep-2003   Changed for Program Completion Validation build
  ||  Prajeesh Chandran .K   11-Jun-2002
  ||           Added a check saying if in insert row of student program attempt is called
  ||           it insert the awards else if called in udpaterow it updates the date or inserts the new awards which is not
  ||           already inserted.
  ||  (reverse chronological order - newest change first) igs_en_spa_awd_aim
  */
    CURSOR cur_caw IS
      SELECT   caw.award_cd, awd.grading_schema_cd, awd.gs_version_number
      FROM     igs_ps_award  caw, igs_ps_awd awd
      WHERE    caw.course_cd = p_course_cd AND
               caw.version_number = p_version_number AND
               caw.default_ind = 'Y' AND
               caw.closed_ind = 'N' AND
	       caw.award_cd = awd.award_cd;

     CURSOR cur_spaa_awd_cnt IS
          SELECT count(*)
          FROM igs_en_spa_awd_aim awd
          WHERE person_id      = p_person_id AND
                course_cd      = p_course_cd;

     CURSOR cur_spaa_awd IS
          SELECT awd.*, awd.rowid
          FROM igs_en_spa_awd_aim awd
          WHERE person_id      = p_person_id AND
                course_cd      = p_course_cd;

     CURSOR cur_course IS
         SELECT commencement_dt, course_rqrmnt_complete_ind
           FROM igs_en_stdnt_ps_att
          WHERE person_id      = p_person_id AND
                course_cd      = p_course_cd AND
                version_number = p_version_number;


    lv_rowid             VARCHAR2(25) := NULL;
    l_course_rec         cur_course%ROWTYPE;
    l_spaa_awd_cnt       NUMBER(4);
    l_end_date           DATE := NULL;

  BEGIN
    OPEN cur_spaa_awd_cnt;
    FETCH cur_spaa_awd_cnt INTO l_spaa_awd_cnt;
    CLOSE cur_spaa_awd_cnt;

    IF l_spaa_awd_cnt = 0 THEN
      OPEN cur_course;
      FETCH cur_course INTO l_course_rec;
      CLOSE cur_course;
      IF l_course_rec.course_rqrmnt_complete_ind = 'Y' THEN
        l_end_date := SYSDATE;
      ELSE
        l_end_date := NULL;
      END IF;
      FOR v_cur_caw IN cur_caw LOOP
            igs_en_spa_awd_aim_pkg.insert_row (
              x_rowid                => lv_rowid,
              x_person_id            => p_person_id,
              x_course_cd            => p_course_cd,
              x_award_cd             => v_cur_caw.award_cd,
              x_start_dt             => p_start_dt,
              x_end_dt               => l_end_date,
              x_complete_ind         => 'N',
              x_conferral_date       => NULL,
              x_award_mark           => NULL,
              x_award_grade          => NULL,
              x_grading_schema_cd    => v_cur_caw.grading_schema_cd,
              x_gs_version_number    => v_cur_caw.gs_version_number,
              x_mode                 => 'R'
            );
      END LOOP;
    ELSE -- l_spaa_awd_cnt > 0
      FOR l_spaa_awd_rec IN cur_spaa_awd LOOP
          IF p_start_dt IS NOT NULL                AND
	     p_start_dt <> l_spaa_awd_rec.start_dt THEN
               igs_en_spa_awd_aim_pkg.update_row (
                   x_rowid             => l_spaa_awd_rec.rowid,
                   x_person_id         => l_spaa_awd_rec.person_id,
                   x_course_cd         => l_spaa_awd_rec.course_cd,
                   x_award_cd          => l_spaa_awd_rec.award_cd,
                   x_start_dt          => p_start_dt,
                   x_end_dt            => l_spaa_awd_rec.end_dt,
                   x_complete_ind      => l_spaa_awd_rec.complete_ind,
                   x_conferral_date    => l_spaa_awd_rec.conferral_date,
                   x_award_mark        => l_spaa_awd_rec.award_mark,
                   x_award_grade       => l_spaa_awd_rec.award_grade,
                   x_grading_schema_cd => l_spaa_awd_rec.grading_schema_cd,
                   x_gs_version_number => l_spaa_awd_rec.gs_version_number,
                   x_mode              => 'R');
          END IF;
      END LOOP;
    END IF;
  END enrp_ins_award_aim;



PROCEDURE Enrp_Ins_Merge_Log(
  p_smir_id IN NUMBER )
AS

BEGIN
DECLARE
    TYPE t_merge_type IS RECORD (
        obsolete_person_id  IGS_EN_MERGE_ID_ROWS.obsolete_person_id%TYPE,
        obsolete_id_row_info    IGS_EN_MERGE_ID_ROWS.obsolete_id_row_info%TYPE,
        current_person_id   IGS_EN_MERGE_ID_ROWS.current_person_id%TYPE,
        current_id_row_info IGS_EN_MERGE_ID_ROWS.current_id_row_info%TYPE,
        table_alias     IGS_EN_MERGE_ID_ROWS.table_alias%TYPE,
        action_id       IGS_EN_MRG_ID_ACT_CH.action_id%TYPE,
        perform_action_id   IGS_EN_MRG_ID_ACT_CH.perform_action_ind%TYPE );
    v_merge_record          t_merge_type;
    CURSOR c_get_merge_data IS
        SELECT  smir.obsolete_person_id,
            smir.obsolete_id_row_info,
            smir.current_person_id,
            smir.current_id_row_info,
            smir.table_alias,
            smiac.action_id,
            smiac.perform_action_ind
        FROM    IGS_EN_MERGE_ID_ROWS smir, IGS_EN_MRG_ID_ACT_CH smiac
        WHERE   smir.smir_id = p_smir_id    AND
            smir.smir_id = smiac.smir_id;
           l_seqval NUMBER;

BEGIN
    FOR v_merge_record IN c_get_merge_data LOOP


            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN

        -- Call table Handler
        IGS_EN_MERGE_ID_LOG_PKG.INSERT_ROW (
                        x_rowid => l_rowid,
            x_obsolete_person_id => v_merge_record.obsolete_person_id,
            x_obsolete_id_row_info => v_merge_record.obsolete_id_row_info,
            x_current_person_id => v_merge_record.current_person_id,
            x_current_id_row_info => v_merge_record.current_id_row_info,
            x_table_alias => v_merge_record.table_alias,
            x_action_id => v_merge_record.action_id,
            x_perform_action_ind => v_merge_record.perform_action_ind,
                        x_SMIL_ID => l_SMIL_id );
             END;

    END LOOP;
END;
END enrp_ins_merge_log;

FUNCTION Enrp_Ins_Pre_Pos(
  p_acad_cal_type         IN VARCHAR2 ,
  p_acad_sequence_number  IN NUMBER ,
  p_person_id             IN NUMBER ,
  p_course_cd             IN VARCHAR2 ,
  p_version_number        IN NUMBER ,
  p_location_cd           IN VARCHAR2 ,
  p_attendance_mode       IN VARCHAR2 ,
  p_attendance_type       IN VARCHAR2 ,
  p_unit_set_cd           IN VARCHAR2 ,
  p_adm_cal_type          IN VARCHAR2 ,
  p_admission_cat         IN VARCHAR2 ,
  p_log_creation_dt       IN DATE ,
  p_units_indicator       IN VARCHAR2,  -- Added this paramter as part of Core Vs Optional DLD.
  p_warn_level            IN OUT NOCOPY VARCHAR2 ,
  p_message_name          IN OUT NOCOPY VARCHAR2,
  p_progress_stat         IN VARCHAR2,
  p_progress_outcome_type IN VARCHAR2,
  p_enr_method            IN VARCHAR2 ,
  p_load_cal_type         IN VARCHAR2,
  p_load_ci_seq_num       IN NUMBER)
RETURN BOOLEAN AS

/**********************************/
--Change History :-
--Who         When                What
--mesriniv    12-sep-2002         Added a new parameter waitlist_manual_ind in insert row of IGS_EN_SU_ATTEMPT
--                                for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
--pradhakr    23-Sep-2002     Added a new parameter p_units_indicator in the package spec and body
--                as part of Core Vs Optional DLD. Bug# 2581270
--svanukur    09-jul-2003   Created the variable l_rec_exist  to check if the cursor c_pos returns any
--                          records into the vt_two_pos. Since this was causing an unhandled exception
--                           when no pattern of study units have been associated with the program.
--ptandon     07-Oct-2003         Modified the cursor c_posu and added logic to derive value for
--                                core indicator and pass in call to function enrp_vald_inst_sua as
--                                part of Prevent Dropping Core Units. Enh Bug# 3052432.

/********************************/



BEGIN   -- enrp_ins_pre_pos
    -- Insert pattern of study IGS_PS_UNIT pre-enrolments for a student
    -- IGS_PS_COURSE attempt within a nominated academic calendar instance.
    -- This routine may be called with a p_log_creation_dt, in which
    -- case it will log all errors and warnings to the log (of type PRE-ENROL).
DECLARE
    -- p_warn_level types
    cst_error       CONSTANT VARCHAR2(5) := 'ERROR';
    cst_minor       CONSTANT VARCHAR2(5) := 'MINOR';
    cst_major       CONSTANT VARCHAR2(5) := 'MAJOR';
    cst_pre_enrol       CONSTANT VARCHAR2(10) := 'PRE-ENROL';
    cst_active      CONSTANT VARCHAR2(10) := 'ACTIVE';
    cst_unconfirm       CONSTANT VARCHAR2(10) := 'UNCONFIRM';
    cst_false       CONSTANT VARCHAR2(5) := 'FALSE';
    CURSOR c_aci IS
        SELECT  aci.cal_type,
            aci.sequence_number,
            aci.start_dt,
            aci.end_dt
        FROM    IGS_CA_INST     aci
        WHERE   aci.cal_type        = p_acad_cal_type AND
            aci.sequence_number     = p_acad_sequence_number;
    v_aci_rec       c_aci%ROWTYPE;
    CURSOR c_pos ( cp_unit_set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE ) IS
        SELECT  pos.cal_type,
            pos.sequence_number,
            pos.always_pre_enrol_ind,
            pos.number_of_periods,
            pos.aprvd_ci_sequence_number ,
            pos.acad_perd_unit_set
        FROM    IGS_PS_PAT_OF_STUDY pos
        WHERE   pos.course_cd       = p_course_cd AND
            pos.version_number  = p_version_number AND
            pos.cal_type        = p_acad_cal_type AND
            ((pos.location_cd   IS NULL AND
            pos.attendance_mode     IS NULL AND
            pos.attendance_type     IS NULL AND
            pos.unit_set_cd     IS NULL AND
            pos.admission_cal_type  IS NULL AND
            pos.admission_cat   IS NULL) OR
            IGS_EN_GEN_005.enrp_get_pos_links(
                    p_location_cd,
                    p_attendance_mode,
                    p_attendance_type,
                    cp_unit_set_cd,
                    p_adm_cal_type,
                    p_admission_cat,
                    pos.location_cd,
                    pos.attendance_mode,
                    pos.attendance_type,
                    pos.unit_set_cd,
                    pos.admission_cal_type,
                    pos.admission_cat) > 0)
        ORDER BY IGS_EN_GEN_005.enrp_get_pos_links(
                    p_location_cd,
                    p_attendance_mode,
                    p_attendance_type,
                    cp_unit_set_cd,
                    p_adm_cal_type,
                    p_admission_cat,
                    pos.location_cd,
                    pos.attendance_mode,
                    pos.attendance_type,
                    pos.unit_set_cd,
                    pos.admission_cal_type,
                    pos.admission_cat) DESC;
    v_pos_rec       c_pos%ROWTYPE;
    v_stream_pos_rec c_pos%ROWTYPE;

    TYPE t_two_pos IS TABLE OF c_pos%ROWTYPE INDEX BY BINARY_INTEGER;
    vt_two_pos t_two_pos;
    v_index BINARY_INTEGER;

    CURSOR c_acad_us (cp_admin_unit_Set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE) IS
      SELECT usm.stream_unit_set_Cd
      FROM   igs_en_unit_set_map usm,
             igs_ps_us_prenr_cfg upc
      WHERE  upc.unit_set_cd = cp_admin_unit_set_cd
      AND    usm.mapping_set_cd = upc.mapping_set_cd
      AND    usm.sequence_no = upc.sequence_no;

    CURSOR c_susa_exists (cp_stream_unit_Set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE,
                      cp_person_id IGS_AS_SU_SETATMPT.PERSON_ID%TYPE,
                      cp_course_cd IGS_AS_SU_SETATMPT.COURSE_CD%TYPE) IS
      SELECT 'X'
      FROM   igs_as_su_setatmpt susa
      WHERE  susa.unit_set_cd = cp_stream_unit_set_cd
      AND    susa.person_id = cp_person_id
      AND    susa.course_cd  = cp_course_cd
      AND    susa.end_dt IS NULL
      AND    susa.rqrmnts_complete_dt IS NULL;

    v_dummy           VARCHAR2(1);

    CURSOR c_am IS
        SELECT  am.govt_attendance_mode
        FROM    IGS_EN_STDNT_PS_ATT sca,
            IGS_EN_ATD_MODE     am
        WHERE   sca.person_id       = p_person_id AND
            sca.course_cd       = p_course_cd AND
            am.attendance_mode  = sca.attendance_mode;
    v_am_rec        c_am%ROWTYPE;
    CURSOR c_posp (
        cp_sequence_number  IGS_PS_PAT_OF_STUDY.sequence_number%TYPE,
        cp_number_of_periods    IGS_PS_PAT_OF_STUDY.number_of_periods%TYPE,
        cp_period_number    NUMBER) IS
        SELECT  posp.acad_period_num,
            posp.teach_cal_type,
            posp.sequence_number
        FROM    IGS_PS_PAT_STUDY_PRD posp
        WHERE   posp.pos_sequence_number    = cp_sequence_number AND
            posp.acad_period_num        >= cp_period_number AND
            posp.acad_period_num        < (cp_period_number
                            + cp_number_of_periods) AND
            EXISTS  (SELECT 'x'
                FROM    IGS_PS_PAT_STUDY_UNT posu
                WHERE   posp.sequence_number    = posu.posp_sequence_number AND
                    posu.unit_cd        IS NOT NULL)
        ORDER BY posp.acad_period_num;
    CURSOR c_ci (
        cp_start_dt     IGS_CA_INST.start_dt%TYPE) IS
        SELECT  aci.cal_type,
                aci.sequence_number,
                aci.start_dt,
                aci.end_dt
        FROM    IGS_CA_INST     aci,
            IGS_CA_STAT     cs
        WHERE   aci.cal_type    = p_acad_cal_type AND
            aci.start_dt    > cp_start_dt AND
            cs.cal_status   = aci.cal_status AND
            cs.s_cal_status = cst_active
        ORDER BY aci.start_dt;
    v_ci_rec        c_ci%ROWTYPE;
    CURSOR c_ci2 (
        cp_cal_type         IGS_CA_INST.cal_type%TYPE,
        cp_sequence_number      IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  ci.start_dt
        FROM    IGS_CA_INST     ci
        WHERE   ci.cal_type         = cp_cal_type AND
            ci.sequence_number  = cp_sequence_number;
    v_ci2_rec       c_ci2%ROWTYPE;
    CURSOR c_cir (
        cp_acad_cal_type    IGS_CA_INST.cal_type%TYPE,
        cp_acad_sequence_number IGS_CA_INST.sequence_number%TYPE,
        cp_teach_cal_type   IGS_CA_INST.cal_type%TYPE) IS
        SELECT  tci.cal_type,
            tci.sequence_number
        FROM    IGS_CA_INST_REL cir,
            IGS_CA_INST tci,
            IGS_CA_TYPE cat,
            IGS_CA_STAT cs
        WHERE   cir.sup_cal_type    = cp_acad_cal_type AND
            sup_ci_sequence_number  = cp_acad_sequence_number AND
            sub_cal_type        = cp_teach_cal_type AND
            tci.cal_type        = cir.sub_cal_type AND
            sequence_number     = cir.sub_ci_sequence_number AND
            cat.cal_type        = tci.cal_type AND
            cat.s_cal_cat       = 'TEACHING' AND
            cs.cal_status       = tci.cal_status AND
            cs.s_cal_status     = cst_active
        ORDER BY tci.start_dt DESC;
    v_cir_rec       c_cir%ROWTYPE;

    -- Modified the cursor c_posu as part Core Vs Optional DLD.
    -- pradhakr; 23-Sep-2002; Bug# 2581270
    CURSOR c_posu (
        cp_sequence_number  IGS_PS_PAT_STUDY_PRD.sequence_number%TYPE,
        cp_core_only            VARCHAR2) IS
        SELECT  posu.unit_cd,
            posu.unit_location_cd,
            posu.unit_class,
            posu.core_ind

        FROM    IGS_PS_PAT_STUDY_UNT posu
        WHERE   posu.posp_sequence_number = cp_sequence_number AND
            unit_cd IS NOT NULL
        AND     (
              ( NVL (core_ind,'N') = cp_core_only
                AND  cp_core_only = 'Y'
              )
            OR
                        cp_core_only = 'N'
             );


    --smaddali added this new cursor for YOP-EN dld bug#2156956
    -- get the number of academic periods within the unit set
    CURSOR c_num_acad_perd  IS
    SELECT  DISTINCT acad_perd
    FROM   igs_en_susa_year_v
    WHERE  person_id = p_person_id
    AND   course_cd = p_course_cd
    AND   unit_set_cd = p_unit_set_cd ;
     -- end of changes by smaddali

      CURSOR c_uoo_status(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
      SELECT DECODE(sua.unit_attempt_status, 'UNCONFIRM', 'N', 'WAITLISTED', 'Y' , NULL)
      FROM  IGS_EN_SU_ATTEMPT sua
      WHERE sua.person_id   = p_person_id AND
        sua.course_cd   = p_course_cd AND
        sua.uoo_id   = p_uoo_id;

      CURSOR c_rel_type(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
      SELECT relation_type
      FROM IGS_PS_UNIT_OFR_OPT
      WHERE uoo_id = p_uoo_id;

    v_posu_rec      c_posu%ROWTYPE;
    v_attendance_mode   VARCHAR2(3) ;
    v_period_number     NUMBER(2) := 0;
    v_warn_level        VARCHAR2(5) ;
    vp_warn_level       VARCHAR2(5) ;
    v_message_name      VARCHAR2(2000) ;
    v_uoo_id        IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
    v_last_acad_start_dt    IGS_CA_INST.start_dt%TYPE;
    v_last_acad_period_num  NUMBER(2) := 0;
    v_ci_start_dt       DATE;
    v_ci_end_dt     DATE;
        v_core_only             VARCHAR2(1);
    cst_core_only       VARCHAR2(10) := 'CORE_ONLY';
    l_org_id NUMBER := igs_ge_gen_003.get_org_id;
    --smaddali added this cursor for YOP-EN dld
            CURSOR c_sua (
            cp_uoo_id   IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
            SELECT  'x'
            FROM    IGS_EN_SU_ATTEMPT sua
            WHERE   person_id   = p_person_id AND
                course_cd   = p_course_cd AND
                uoo_id  =      cp_uoo_id ;
                        v_sua_rec       VARCHAR2(1);

l_rec_exist            BOOLEAN;
l_core_indicator_code  IGS_EN_SU_ATTEMPT.core_indicator_code%TYPE;

    l_waitlist_flag              VARCHAR2(1) := NULL;
    l_rel_type                  IGS_PS_UNIT_OFR_OPT.relation_type%TYPE;
    l_enr_uoo_ids VARCHAR2(2000);
    l_out_uoo_ids VARCHAR2(2000);
    l_waitlist_uoo_ids VARCHAR2(2000);
    l_failed_uoo_ids VARCHAR2(2000);
    l_unit_cds VARCHAR2(2000);

    TYPE l_params_rec IS RECORD (
       uoo_id IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE,
       core_ind IGS_PS_PAT_STUDY_UNT.CORE_IND%TYPE );

     TYPE t_params_table IS TABLE OF l_params_rec INDEX BY BINARY_INTEGER;
     t_sup_params t_params_table;
     t_sub_params t_params_table;
     t_ord_params t_params_table;
     t_all_params t_params_table;
     v_sup_index BINARY_INTEGER := 1;
     v_sub_index BINARY_INTEGER := 1;
     v_ord_index BINARY_INTEGER := 1;
     v_all_index BINARY_INTEGER := 1;
     l_cal_type IGS_PS_UNIT_OFR_OPT.cal_type%TYPE;
      l_seq_num IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE;
      l_uoo_Id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;

      CURSOR cur_teach_cal(p_uoo_Id igs_ps_unit_ofr_opt.uoo_Id%TYPE) IS
   SELECT cal_type, ci_sequence_number
   FROM igs_ps_unit_ofr_opt
   WHERE uoo_id = p_uoo_id;


BEGIN

    -- Set the default message number
    p_message_name := NULL;
    l_rec_exist :=FALSE;
    SAVEPOINT sp_pos;
    -- Get the start/end dates from the academic period ?
    -- required by routine calls lower in the routine.
    -- The academic period has already been validated.
    OPEN c_aci;
    FETCH c_aci INTO v_aci_rec;
    CLOSE c_aci;
    -- Determine the pattern of study which applies to the current student.
    -- Use the first record found. ie. the record with the most links.
    v_index := 0;
    OPEN c_pos (p_unit_set_cd);
    FETCH c_pos INTO vt_two_pos(v_index);
    IF c_pos%FOUND THEN
       l_rec_exist := TRUE;
    END IF;
    CLOSE c_pos;

    IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN
      FOR vc_acad_us_rec IN c_acad_us(p_unit_set_cd) LOOP
        OPEN c_susa_exists(vc_acad_us_rec.stream_unit_set_cd, p_person_id, p_course_Cd);
        FETCH c_susa_exists INTO v_dummy;
        IF c_susa_exists%FOUND THEN
          l_rec_exist := TRUE;
          v_index := v_index + 1;
          OPEN c_pos (vc_acad_us_rec.stream_unit_set_cd);
          FETCH c_pos INTO vt_two_pos(v_index);
          CLOSE c_pos;
        END IF;
        CLOSE c_susa_exists;
      END LOOP;
    END IF;

    -- Get the relevant attendance mode
    OPEN c_am;
    FETCH c_am INTO v_am_rec;
    CLOSE c_am;
    IF v_am_rec.govt_attendance_mode = '1' THEN
        v_attendance_mode := 'ON';
    ELSIF v_am_rec.govt_attendance_mode = '2' THEN
        v_attendance_mode := 'OFF';
    ELSE
        v_attendance_mode :=  '%';
    END IF;
    -- Determine the number of academic periods in which the
    -- student has been enrolled.
    --smaddali adding code for YOP-EN dld . bug#2156956
    -- If year of program mode is enabled then check if 'academic period within unit sets' is checked
    -- for the pattern of study, if so get number of periods form igs_en_susa_year_v else use original function
    --l_rec_exist checks if vt_two_pos has any values in it.
    IF  NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y'  AND l_rec_exist THEN
        IF NVL(vt_two_pos(vt_two_pos.FIRST).acad_perd_unit_set,'N')  = 'Y' AND
           p_unit_set_cd IS NOT NULL THEN
           OPEN c_num_acad_perd ;
           FETCH c_num_acad_perd  INTO    v_period_number ;
           CLOSE c_num_acad_perd ;

           v_period_number  := v_period_number + 1;
        ELSE
         v_period_number := IGS_EN_GEN_004.enrp_get_perd_num(
                    p_person_id,
                    p_course_cd,
                    p_acad_cal_type,
                    p_acad_sequence_number,
                    v_aci_rec.start_dt);
        END IF;

    ELSE

       v_period_number := IGS_EN_GEN_004.enrp_get_perd_num(
                    p_person_id,
                    p_course_cd,
                    p_acad_cal_type,
                    p_acad_sequence_number,
                    v_aci_rec.start_dt);
    END IF;

    IF  NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y'
        AND NVL(p_progress_outcome_type,'ADVANCE') = 'REPEATYR'
        AND NVL(P_PROGRESS_STAT,'ADVANCE') IN ('BOTH','REPEATYR') THEN
      v_period_number := v_period_number - 1;
    END IF;

   ---Do following validation only if any units got added to the table.

    IF l_rec_exist THEN

      FOR v_index IN vt_two_pos.FIRST..vt_two_pos.LAST LOOP
        -- Check that the student is eligible to be pre-enrolled
        -- in the relevant academic period.

       IF IGS_EN_GEN_005.enrp_get_pos_elgbl(
             p_acad_cal_type,
             p_acad_sequence_number,
             p_person_id,
             p_course_cd,
             p_version_number,
             vt_two_pos(v_index).sequence_number,
             vt_two_pos(v_index).always_pre_enrol_ind,
             v_period_number,
             p_log_creation_dt,
             v_warn_level,
             v_message_name) = cst_false THEN
          IF v_message_name = 'IGS_EN_STUD_INELG_PROGRESSION'
             AND NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y'
             AND NVL(p_progress_outcome_type,'ADVANCE') = 'REPEATYR'
             AND NVL(P_PROGRESS_STAT,'ADVANCE') IN ('BOTH','REPEATYR')THEN
            NULL; -- do nothing
          ELSE
            p_warn_level := v_warn_level;
            p_message_name := v_message_name;
            RETURN FALSE;
          END IF;
        END IF;
      END LOOP;


    -- Loop through the relevant pattern of study periods;
    -- this is relative to the number of academic periods
    -- in which the student has been enrolled
    v_last_acad_start_dt := v_aci_rec.start_dt;
    v_last_acad_period_num := v_period_number;

    FOR v_index IN vt_two_pos.FIRST..vt_two_pos.LAST LOOP

      FOR v_posp_rec IN c_posp(
            vt_two_pos(v_index).sequence_number,
            vt_two_pos(v_index).number_of_periods,
            v_period_number) LOOP
        -- If the acad_period_num has been incremented,
        -- then move the pre-enrolment forward into the
        -- next instance of the academic calendar.

        IF v_posp_rec.acad_period_num > v_last_acad_period_num THEN
            OPEN c_ci(
                v_last_acad_start_dt);
            FETCH c_ci INTO v_aci_rec;
            IF c_ci%NOTFOUND THEN
                CLOSE c_ci;
                ROLLBACK TO sp_pos;
                IF p_log_creation_dt IS NOT NULL THEN
                    -- If the log creation date is set then log the HECS error
                    -- This is if the pre-enrolment is being performed in batch.
                    IGS_GE_GEN_003.genp_ins_log_entry(
                        cst_pre_enrol,
                        p_log_creation_dt,
                        cst_major || ',' ||
                            TO_CHAR(p_person_id) || ',' ||
                             p_course_cd,
                            'IGS_EN_UNABLE_FIND_ACADEMIC',
                            v_posp_rec.acad_period_num || ',' ||
                            v_posp_rec.teach_cal_type);
                END IF;
                p_warn_level := cst_major;
                v_message_name := 'IGS_EN_UNABLE_FIND_ACADEMIC';
                EXIT;
            ELSE
                CLOSE c_ci;
                -- Make the first record found current (ie. the next period)
                v_last_acad_start_dt := v_aci_rec.start_dt;
                v_last_acad_period_num := v_posp_rec.acad_period_num;
            END IF;
        END IF;
        -- Determine whether the pattern is eligible to be used in the
        -- period being pre-enrolled. This is determined by the
        -- aprvd_ci_sequence_number which indicates the latest
        -- academic period in which the pattern can be used.
        IF vt_two_pos(v_index).aprvd_ci_sequence_number IS NOT NULL THEN
            -- Select the start date from the admission calendar referred
            -- to by the sequence number ; if the start date is < the
            -- academic period being pre-enrolled then
            OPEN c_ci2(
                vt_two_pos(v_index).cal_type,
                vt_two_pos(v_index).aprvd_ci_sequence_number);
            FETCH c_ci2 INTO v_ci2_rec;
            CLOSE c_ci2;
            IF v_aci_rec.start_dt > v_ci2_rec.start_dt THEN
                IF p_log_creation_dt IS NOT NULL THEN
                    -- If the log creation date is set then log the HECS error
                    -- This is if the pre-enrolment is being performed in batch.
                    IGS_GE_GEN_003.genp_ins_log_entry(
                        cst_pre_enrol,
                        p_log_creation_dt,
                        cst_major || ',' ||
                        TO_CHAR(p_person_id) || ',' ||
                         p_course_cd,
                        'IGS_EN_UNABLE_PRE_ENR_UA',
                        v_posp_rec.acad_period_num || ',' ||
                        v_posp_rec.teach_cal_type);
                END IF;
                p_warn_level := cst_major;
                v_message_name := 'IGS_EN_UNABLE_PRE_ENR_UA';
                EXIT;
            END IF;
        END IF;
        -- Select the teaching calendar instance matching the
        -- IGS_PS_PAT_STUDY_PRD within the relevant academic
        -- calendar instance.
        OPEN c_cir (v_aci_rec.cal_type,
                v_aci_rec.sequence_number,
                v_posp_rec.teach_cal_type);
        FETCH c_cir INTO v_cir_rec;

        IF c_cir%NOTFOUND THEN
            CLOSE c_cir;
            ROLLBACK TO sp_pos;
            IF p_log_creation_dt IS NOT NULL THEN
                -- If the log creation date is set then log the HECS error
                -- This is if the pre-enrolment is being performed in batch.
                IGS_GE_GEN_003.genp_ins_log_entry(
                    cst_pre_enrol,
                    p_log_creation_dt,
                    cst_major || ',' ||
                        TO_CHAR(p_person_id) || ',' ||
                         p_course_cd,
                    'IGS_EN_UNABLE_LOCATE_TEACHCAL',
                    v_posp_rec.acad_period_num || ',' ||
                        v_posp_rec.teach_cal_type);
            END IF;
            p_warn_level := cst_major;
            v_message_name := 'IGS_EN_UNABLE_LOCATE_TEACHCAL';
            EXIT;
        END IF;
        CLOSE c_cir;
        -- Validate that the IGS_PS_UNIT attempt period is not prior to the commencement date
        -- of the student.

        IF IGS_EN_VAL_SUA.enrp_val_sua_ci(p_person_id,
                    p_course_cd,
                    v_cir_rec.cal_type,
                    v_cir_rec.sequence_number,
                    'UNCONFIRM',
                    NULL,
                    'T',
                    v_message_name) = FALSE THEN
            IF vp_warn_level IS NULL THEN
                vp_warn_level := cst_minor;
                p_message_name := 'IGS_EN_COULD_NOT_PREENR';
            END IF;
        ELSE

          -- Check whether the user wants to enroll only core units or all the units.
          -- If the user wants to pick only the core units then set the value for the
          -- varible v_core_only to 'Y' and pass the value to the cursor c_posu,
          -- so that it picks only core units. else if all the units are required
          -- then set the value for the varible v_core_only to 'N'.
          -- Added the following IF condition as part of Core Vs Optional DLD
          -- pradhakr; 23-Sep-2002; Bug# 2581270

          IF p_units_indicator = cst_core_only THEN
              v_core_only := 'Y';
          ELSIF p_units_indicator = 'Y' THEN
              v_core_only := 'N';
          ELSE
              v_core_only := 'X';
          END IF;

            -- Loop through the units that need to be pre-enrolled.
            FOR v_posu_rec IN c_posu(
                    v_posp_rec.sequence_number,
                    v_core_only) LOOP
                -- Validate whether there is anything preventing it
                -- being pre-enrolled ; including encumbrances and
                -- advanced standing.
                -- Modified by : jbegum
                -- Modification:
                -- The function Enrp_Val_Sua_Pre was being called from the package IGS_EN_GEN_013.But the
                            -- exact replica of it was found in the package IGS_EN_VAL_SUA.Hence this function was removed from
                            -- the package IGS_EN_GEN_013 and instead its replica in the package IGS_EN_VAL_SUA is getting called.
                IF NOT IGS_EN_VAL_SUA.enrp_val_sua_pre(
                        p_person_id,
                        p_course_cd,
                        v_posu_rec.unit_cd,
                        p_log_creation_dt,
                        v_warn_level,
                        v_message_name) THEN
                    IF vp_warn_level IS NULL OR
                        (vp_warn_level = cst_minor AND
                        v_warn_level IN (cst_major,
                                cst_error)) OR
                        (vp_warn_level = cst_major AND
                        v_warn_level = cst_error) THEN
                        vp_warn_level := v_warn_level;
                        p_message_name := v_message_name;
                    END IF;
                    -- continue with the next record
                ELSE
                    -- Call routine to get the applicable uoo in
                    -- which to pre-enrol the student.
                   IF NOT IGS_EN_GEN_005.enrp_get_pre_uoo(
                            v_posu_rec.unit_cd,
                            v_cir_rec.cal_type,
                            v_cir_rec.sequence_number,
                            v_posu_rec.unit_location_cd,
                            v_posu_rec.UNIT_CLASS,
                            v_attendance_mode,
                            p_location_cd,
                            v_uoo_id) THEN
                        IF p_log_creation_dt IS NOT NULL THEN
                            -- If the log creation date is set then log the HECS error
                            -- This is if the pre-enrolment is being performed in batch.
                            IGS_GE_GEN_003.genp_ins_log_entry(
                                cst_pre_enrol,
                                p_log_creation_dt,
                                cst_minor || ',' ||
                                    TO_CHAR(p_person_id) || ',' ||
                                     p_course_cd,
                                'IGS_EN_UNABLE_LOCATE_UOO',
                                v_posp_rec.acad_period_num || ',' ||
                                    v_posp_rec.teach_cal_type || ',' ||
                                    v_posu_rec.unit_cd || ',' ||
                                    v_posu_rec.unit_location_cd || ',' ||
                                    v_posu_rec.UNIT_CLASS);
                        END IF;
                        IF vp_warn_level IS NULL THEN
                            vp_warn_level := cst_minor;
                            p_message_name := 'IGS_EN_UNABLE_LOCATE_UOO';
                        END IF;
                    ELSE

                       OPEN c_rel_type(v_uoo_id);
                         FETCH c_rel_type INTO l_rel_type;
                         CLOSE c_rel_type;

                        IF l_rel_type= 'SUPERIOR' THEN
                                 t_sup_params(v_sup_index).uoo_id := v_uoo_id;
                                 t_sup_params(v_sup_index).core_ind := v_posu_rec.core_ind;
                                  v_sup_index :=v_sup_index+1;
                        ELSIF l_rel_type = 'SUBORDINATE' THEN
                                  t_sub_params(v_sub_index).uoo_id := v_uoo_id;
                                  t_sub_params(v_sub_index).core_ind := v_posu_rec.core_ind;
                                  v_sub_index := v_sub_index+1;
                        ELSE
                                  t_ord_params(v_ord_index).uoo_id := v_uoo_id;
                                  t_ord_params(v_ord_index).core_ind := v_posu_rec.core_ind;
                                  v_ord_index := v_ord_index+1;
                        END IF;

                      END IF;
                END IF;
            END LOOP; -- posu loop
 -- add all the uoo_ids to one pl/sql table, with superiors, first, subordinate next and the rest .
       --combine all of this in one pl/sql table

       IF t_sup_params.count > 0 THEN
           FOR i in 1 .. t_sup_params.count LOOP
             t_all_params(v_all_index) := t_sup_params(i);
             v_all_index := v_all_index + 1;
           END LOOP;
       END IF;
       IF t_sub_params.count > 0 THEN
           FOR i in 1 .. t_sub_params.count LOOP
             t_all_params(v_all_index) := t_sub_params(i);
             v_all_index := v_all_index + 1;
           END LOOP;
      END IF;
      IF t_ord_params.count > 0 THEN
           FOR i in 1 .. t_ord_params.count LOOP
             t_all_params(v_all_index) := t_ord_params(i);
             v_all_index := v_all_index + 1;
           END LOOP;
       END IF;


       IF t_all_params.count > 0 THEN
         FOR i in 1.. t_all_params.count LOOP
                              -- smaddali added this check to see if unit attempt already exists in YOP-EN dld
                              -- bug#2156956 as this was throwing duplicate record exception
                              -- Check if the IGS_PS_UNIT attempt already exists.

                              OPEN c_sua( t_all_params(i).uoo_id);
                              FETCH c_sua INTO v_sua_rec;
                              IF c_sua%NOTFOUND THEN
                                 CLOSE c_sua;
                                 IGS_CA_GEN_001.CALP_GET_CI_DATES(v_posp_rec.teach_cal_type,
                                                                  v_cir_rec.sequence_number,
                                                                  v_ci_start_dt,v_ci_end_dt);
                                --  Check whether the profile is set or not
                                 IF NVL(fnd_profile.value('IGS_EN_CORE_VAL'),'N') = 'N' THEN
                                    l_core_indicator_code := NULL;
                                 ELSE
                                 --  If the profile is set, derive the value of core indicator based
                                 --  on the value of core unit indicator in pattern of study periods table.
                                    IF t_all_params(i).core_ind = 'Y' THEN
                                       l_core_indicator_code := 'CORE';
                                    ELSE
                                       l_core_indicator_code := 'OPTIONAL';
                                    END IF;
                                 END IF;


                                  -- Add the unconfirmed IGS_PS_UNIT attempt to the students record.

                                 IF igs_en_gen_010.enrp_vald_inst_sua(p_person_id      => p_person_id,
                                                                      p_course_cd      => p_course_cd,
                                                                      p_unit_cd        => NULL,
                                                                      p_version_number => NULL,
                                                                      p_teach_cal_type => NULL,
                                                                      p_teach_seq_num  => NULL,
                                                                      p_load_cal_type  => p_load_cal_type,
                                                                      p_load_seq_num   => p_load_ci_seq_num,
                                                                      p_location_cd    => NULL,
                                                                      p_unit_class     => NULL,
                                                                      p_uoo_id         => t_all_params(i).uoo_id,
                                                                      p_enr_method     => p_enr_method,
                                                                      p_core_indicator_code => l_core_indicator_code,
                                                                      p_message        => v_message_name) THEN
                                      IF v_message_name IS NOT NULL THEN
                                         p_warn_level := 'MINOR';
                                         p_message_name := v_message_name;
                                      END IF;
                                         --call enr_sub_units to enroll any subordinate units that are marked as default enroll

                                             l_waitlist_flag := NULL;
                                             OPEN c_uoo_status(t_all_params(i).uoo_id);
                                             FETCH c_uoo_status INTO l_waitlist_flag;
                                             CLOSE c_uoo_status;

                                      --fetch the teach cal type and teach seq number
                                             l_cal_type := NULL;
                                             l_seq_num := NULL;
                                             OPEN cur_teach_cal(t_all_params(i).uoo_id);
                                             FETCH cur_teach_cal INTO l_cal_type, l_seq_num;
                                             CLOSE cur_teach_cal;

                                           l_enr_uoo_ids := NULL;
                                           IF i < t_all_params.count THEN
                                             FOR j in (i+1).. t_all_params.count LOOP
                                               l_enr_uoo_ids := to_char(t_all_params(i).uoo_id) || ',';
                                             END LOOP;
                                             IF l_enr_uoo_ids IS NOT NULL THEN
                                               l_enr_uoo_ids := substr(l_enr_uoo_ids,1, LENGTH(l_enr_uoo_ids) -1);
                                             END IF;
                                           END IF;


                                        igs_en_val_sua.enr_sub_units(
                                                p_person_id      => p_person_id,
                                                p_course_cd      => p_course_cd,
                                                p_uoo_id         => t_all_params(i).uoo_id,
                                                p_waitlist_flag  => l_waitlist_flag,
                                                p_load_cal_type  =>  p_load_cal_type ,
                                                p_load_seq_num   => p_load_ci_seq_num,
                                                p_enrollment_date => SYSDATE,
                                                p_enrollment_method =>p_enr_method,
                                                p_enr_uoo_ids     => l_enr_uoo_ids,
                                                p_uoo_ids         => l_out_uoo_ids,
                                                p_waitlist_uoo_ids => l_waitlist_uoo_ids,
                                                p_failed_uoo_ids  => l_failed_uoo_ids);


                                                IF l_failed_uoo_ids IS NOT NULL THEN
                                                l_unit_cds := NULL;
                                                --following function returns a string of units codes for teh passed in string of uoo_ids
                                               l_unit_cds := igs_en_gen_018.enrp_get_unitcds(l_failed_uoo_ids);
                                               p_warn_level := cst_error;
                                               p_message_name := 'IGS_EN_BLK_SUB_FAILED'||'*'||l_unit_cds;
                                               END IF;


                                 ELSE --igs_en_gen_010.enrp_vald_inst_sua returned false.
                                      p_warn_level := cst_error;
                                      p_message_name := v_message_name;

                                      RETURN FALSE;
                                 END IF;
                              ELSE
                                      CLOSE c_sua ;
                              END IF; -- If unit attempt already exists

             END LOOP;
           END IF; --        IF t_all_params.count > 0 THEN

        END IF;
      END LOOP; -- v_posp_rec IN c_posp
    END LOOP; -- vt_two_pos
  END IF; --l_record_exists

    IF vp_warn_level IS NOT NULL THEN
        p_warn_level := vp_warn_level;
    END IF;
    IF v_message_name IS NOT NULL THEN
        p_message_name := v_message_name;
        RETURN FALSE;
    END IF;
    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        IF c_cir%ISOPEN THEN
            CLOSE c_cir;
        END IF;
        IF c_aci%ISOPEN THEN
            CLOSE c_aci;
        END IF;
        IF c_ci%ISOPEN THEN
            CLOSE c_ci;
        END IF;
        IF c_ci2%ISOPEN THEN
            CLOSE c_ci2;
        END IF;
        IF c_posp%ISOPEN THEN
            CLOSE c_posp;
        END IF;
        IF c_posu%ISOPEN THEN
            CLOSE c_posu;
        END IF;
        IF c_am%ISOPEN THEN
            CLOSE c_am;
        END IF;
        IF c_pos%ISOPEN THEN
            CLOSE c_pos;
        END IF;
        RAISE;
END;
END enrp_ins_pre_pos;

FUNCTION Enrp_Ins_Scae_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS

BEGIN   -- enrp_ins_scae_trnsfr
    -- Insert a record into the IGS_AS_SC_ATMPT_ENR table.
DECLARE
    v_dummy     VARCHAR2(1);
    CURSOR c_scae IS
        SELECT  'x'
        FROM    IGS_AS_SC_ATMPT_ENR scae
        WHERE   scae.person_id          = p_person_id   AND
            scae.course_cd          = p_course_cd   AND
            scae.cal_type           = p_cal_type    AND
            scae.ci_sequence_number     = p_ci_sequence_number;
BEGIN
    p_message_name := NULL;
    -- 1. Check parameters.
    IF (p_person_id IS NULL OR
             p_course_cd IS NULL OR
             p_cal_type IS NULL OR
             p_ci_sequence_number IS NULL) THEN
        RETURN TRUE;
    END IF;
    -- 2. Check that record does not already exist.
    OPEN c_scae;
    FETCH c_scae INTO v_dummy;
    IF (c_scae%FOUND) THEN
        CLOSE c_scae;
        p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS ';
        RETURN FALSE;
    ELSE
        -- 3. Insert the record.
            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN

        IGS_AS_SC_ATMPT_ENR_PKG.INSERT_ROW(
                        x_rowid => l_rowid,
            x_person_id => p_person_id,
            x_course_cd => p_course_cd,
            x_cal_type => p_cal_type,
            x_ci_sequence_number => p_ci_sequence_number,
            x_enrolment_cat => p_enrolment_cat,
                        X_ENROLLED_DT => NULL,
                        X_ENR_FORM_DUE_DT => NULL,
                        X_ENR_PCKG_PROD_DT => NULL,
                        X_ENR_FORM_RECEIVED_DT => NULL );
                END;
    END IF;
    -- 4. Set p_message_name to (0)
    CLOSE c_scae;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_scae%ISOPEN) THEN
            CLOSE c_scae;
        END IF;
        RAISE;
END;
END enrp_ins_scae_trnsfr;

FUNCTION Enrp_Ins_Sca_Cah(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_old_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS

BEGIN   -- enrp_ins_sca_cah
    -- This modules inserts into IGS_RE_CDT_ATT_HIST when
    -- IGS_EN_STDNT_PS_ATT.attendance_type is changed.
    -- The following is validated:
    --  Research IGS_RE_CANDIDATURE exists.
    --  Research IGS_RE_CANDIDATURE requires attendance history details to be retained
DECLARE
    v_sequence_number       IGS_RE_CANDIDATURE.sequence_number%TYPE;
    v_attendance_percentage     IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
    v_hist_start_dt         IGS_RE_CDT_ATT_HIST.hist_start_dt%TYPE;
    v_hist_end_dt           IGS_RE_CDT_ATT_HIST.hist_end_dt%TYPE;
    v_attendance_percentage_new IGS_RE_CDT_ATT_HIST.attendance_percentage%TYPE;
    v_cah_sequence_number       IGS_RE_CDT_ATT_HIST.sequence_number%TYPE;

    l_org_id NUMBER := igs_ge_gen_003.get_org_id;

    CURSOR c_ca IS
        SELECT  ca.sequence_number,
            ca.attendance_percentage
        FROM    IGS_RE_CANDIDATURE ca
        WHERE   ca.person_id        = p_person_id   AND
            ca.sca_course_cd    = p_course_cd;
    CURSOR c_cah (
            cp_ca_sequence_number   IGS_RE_CDT_ATT_HIST.ca_sequence_number%TYPE) IS
        SELECT  cah.hist_end_dt
        FROM    IGS_RE_CDT_ATT_HIST cah
        WHERE   cah.person_id       = p_person_id   AND
            cah.ca_sequence_number  = cp_ca_sequence_number
        ORDER BY cah.hist_end_dt DESC;
    CURSOR  c_cah2 (
            cp_sequence_number  IGS_RE_CDT_ATT_HIST.sequence_number%TYPE) IS
        SELECT  NVL(MAX(cah2.sequence_number),0)+1
        FROM    IGS_RE_CDT_ATT_HIST cah2
        WHERE   cah2.person_id      = p_person_id AND
            cah2.ca_sequence_number     = cp_sequence_number;
BEGIN
    -- set default value
    p_message_name := NULL;
    IF p_student_confirmed_ind = 'Y' THEN
        -- Determine if student IGS_PS_COURSE attempt has a research IGS_RE_CANDIDATURE
        OPEN c_ca;
        FETCH c_ca INTO v_sequence_number,
                v_attendance_percentage;
        IF c_ca%NOTFOUND THEN
            CLOSE c_ca;
            RETURN TRUE;
        END IF;
        CLOSE c_ca;
        OPEN c_cah (
            v_sequence_number);
        FETCH c_cah INTO v_hist_end_dt;
        IF c_cah%NOTFOUND THEN
            CLOSE c_cah;
            -- First history inserted,
            -- start date should be set the student IGS_PS_COURSE attempt Commencement date
            IF p_commencement_dt IS NULL THEN
                p_message_name := 'IGS_RE_FIRST_HIST_CANT_INSERT';
                RETURN FALSE;
            ELSE
                v_hist_start_dt := p_commencement_dt;
            END IF;
        ELSE
            CLOSE c_cah;
            -- History start date should be set to latest history end date plus a day
            v_hist_start_dt := v_hist_end_dt + 1;
        END IF;
        IF v_hist_start_dt >= TRUNC(SYSDATE) THEN
            -- Changes not required in history, more than one change in a day or
            -- Commencement date has not been reached
            RETURN TRUE;
        END IF;
        -- Determine attendance percentage
        v_attendance_percentage_new := IGS_RE_GEN_001.resp_get_ca_att(
                        p_person_id,
                        p_course_cd,
                        TRUNC(SYSDATE),
                        v_sequence_number,
                        p_old_attendance_type,
                        v_attendance_percentage);
        -- Get next sequence number
        OPEN c_cah2(
            v_sequence_number);
        FETCH c_cah2 INTO v_cah_sequence_number;
        CLOSE c_cah2;
            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN

        IGS_RE_CDT_ATT_HIST_PKG.INSERT_ROW(
                                x_rowid => l_rowid,
                x_person_id => p_person_id,
                x_sequence_number => v_cah_sequence_number,
                x_ca_sequence_number =>  v_sequence_number,
                x_hist_start_dt => v_hist_start_dt,
                x_hist_end_dt => TRUNC(SYSDATE) - 1,
                x_attendance_type => p_old_attendance_type,
                x_attendance_percentage => v_attendance_percentage_new,
                x_mode => 'R',
                    x_org_id => l_org_id);
            END;
    END IF;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        IF c_ca%ISOPEN THEN
            CLOSE c_ca;
        END IF;
        IF c_cah%ISOPEN THEN
            CLOSE c_cah;
        END IF;
        RAISE;
END;
END; --enrp_ins_sca_cah

-- Modified by : jbegum
-- Added 4 new parameters p_new_last_date_of_attendance , p_old_last_date_of_attendance , p_new_dropped_by , p_old_dropped_by
-- as part of Enhancement Bug # 1832130

-- Modified by : kkillams
-- Added 10 new parameters p_new_primary_program_type,p_old_primary_program_type,p_new_primary_prog_type_source,p_old_primary_prog_type_source,
-- p_new_catalog_cal_type,p_old_catalog_cal_type,p_new_catalog_seq_num,p_old_catalog_seq_num,p_new_key_program,p_old_key_program
-- as part of Enhancement Bug # 2027984

-- Modified by pradhakr
-- Added 4 new parametes p_new_override_cmpl_dt, p_old_override_cmpl_dt, p_new_manual_ovr_cmpl_dt_ind,
-- p_old_manual_ovr_cmpl_dt_ind as part of the build ENCR015. Bug# 2158654

-- Modified by rvangala
-- Added 4 new parameters p_new_coo_id,p_old_coo_id,p_new_igs_pr_class_std_id,p_old_igs_pr_class_std_id
--Change History:
--Who         When            What
--stutta   11-Dec-2004     Replace insert_row of igs_as_sc_attempt_h_pkg with add_row. This is done
--                         avoid record already exists msg when more than one history record is created
--                         within the same second. Bug # 4061929
PROCEDURE Enrp_Ins_Sca_Hist(
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_new_version_number IN IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_old_version_number IN IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_new_cal_type IN IGS_EN_STDNT_PS_ATT_ALL.cal_type%TYPE ,
  p_old_cal_type IN IGS_EN_STDNT_PS_ATT_ALL.cal_type%TYPE ,
  p_new_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_old_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_new_attendance_mode IN IGS_EN_STDNT_PS_ATT_ALL.attendance_mode%TYPE ,
  p_old_attendance_mode IN IGS_EN_STDNT_PS_ATT_ALL.attendance_mode%TYPE ,
  p_new_attendance_type IN IGS_EN_STDNT_PS_ATT_ALL.attendance_type%TYPE ,
  p_old_attendance_type IN IGS_EN_STDNT_PS_ATT_ALL.attendance_type%TYPE ,
  p_new_student_confirmed_ind IN IGS_EN_STDNT_PS_ATT_ALL.student_confirmed_ind%TYPE ,
  p_old_student_confirmed_ind IN IGS_EN_STDNT_PS_ATT_ALL.student_confirmed_ind%TYPE ,
  p_new_commencement_dt IN IGS_EN_STDNT_PS_ATT_ALL.commencement_dt%TYPE ,
  p_old_commencement_dt IN IGS_EN_STDNT_PS_ATT_ALL.commencement_dt%TYPE ,
  p_new_course_attempt_status IN IGS_EN_STDNT_PS_ATT_ALL.course_attempt_status%TYPE ,
  p_old_course_attempt_status IN IGS_EN_STDNT_PS_ATT_ALL.course_attempt_status%TYPE ,
  p_new_progression_status IN VARCHAR2 ,
  p_old_progression_status IN VARCHAR2 ,
  p_new_derived_att_type IN IGS_EN_STDNT_PS_ATT_ALL.derived_att_type%TYPE ,
  p_old_derived_att_type IN IGS_EN_STDNT_PS_ATT_ALL.derived_att_type%TYPE ,
  p_new_derived_att_mode IN IGS_EN_STDNT_PS_ATT_ALL.derived_att_mode%TYPE ,
  p_old_derived_att_mode IN IGS_EN_STDNT_PS_ATT_ALL.derived_att_mode%TYPE ,
  p_new_provisional_ind IN IGS_EN_STDNT_PS_ATT_ALL.provisional_ind%TYPE ,
  p_old_provisional_ind IN IGS_EN_STDNT_PS_ATT_ALL.provisional_ind%TYPE ,
  p_new_discontinued_dt IN IGS_EN_STDNT_PS_ATT_ALL.discontinued_dt%TYPE ,
  p_old_discontinued_dt IN IGS_EN_STDNT_PS_ATT_ALL.discontinued_dt%TYPE ,
  p_new_dscntntn_reason_cd IN IGS_EN_STDNT_PS_ATT_ALL.discontinuation_reason_cd%TYPE ,
  p_old_dscntntn_reason_cd IN IGS_EN_STDNT_PS_ATT_ALL.discontinuation_reason_cd%TYPE ,
  p_new_lapsed_dt IN DATE ,
  p_old_lapsed_dt IN DATE ,
  p_new_funding_source IN IGS_EN_STDNT_PS_ATT_ALL.funding_source%TYPE ,
  p_old_funding_source IN IGS_EN_STDNT_PS_ATT_ALL.funding_source%TYPE ,
  p_new_exam_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.exam_location_cd%TYPE ,
  p_old_exam_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.exam_location_cd%TYPE ,
  p_new_derived_cmpltn_yr IN IGS_EN_STDNT_PS_ATT_ALL.derived_completion_yr%TYPE ,
  p_old_derived_cmpltn_yr IN IGS_EN_STDNT_PS_ATT_ALL.derived_completion_yr%TYPE ,
  p_new_derived_cmpltn_perd IN IGS_EN_STDNT_PS_ATT_ALL.derived_completion_perd%TYPE ,
  p_old_derived_cmpltn_perd IN IGS_EN_STDNT_PS_ATT_ALL.derived_completion_perd%TYPE ,
  p_new_nominated_cmpltn_yr IN IGS_EN_STDNT_PS_ATT_ALL.nominated_completion_yr%TYPE ,
  p_old_nominated_cmpltn_yr IN IGS_EN_STDNT_PS_ATT_ALL.nominated_completion_yr%TYPE ,
  p_new_nominated_cmpltn_perd IN IGS_EN_STDNT_PS_ATT_ALL.nominated_completion_perd%TYPE ,
  p_old_nominated_cmpltn_perd IN IGS_EN_STDNT_PS_ATT_ALL.nominated_completion_perd%TYPE ,
  p_new_rule_check_ind IN IGS_EN_STDNT_PS_ATT_ALL.rule_check_ind%TYPE ,
  p_old_rule_check_ind IN IGS_EN_STDNT_PS_ATT_ALL.rule_check_ind%TYPE ,
  p_new_waive_option_check_ind IN IGS_EN_STDNT_PS_ATT_ALL.waive_option_check_ind%TYPE ,
  p_old_waive_option_check_ind IN IGS_EN_STDNT_PS_ATT_ALL.waive_option_check_ind%TYPE ,
  p_new_last_rule_check_dt IN IGS_EN_STDNT_PS_ATT_ALL.last_rule_check_dt%TYPE ,
  p_old_last_rule_check_dt IN IGS_EN_STDNT_PS_ATT_ALL.last_rule_check_dt%TYPE ,
  p_new_publish_outcomes_ind IN IGS_EN_STDNT_PS_ATT_ALL.publish_outcomes_ind%TYPE ,
  p_old_publish_outcomes_ind IN IGS_EN_STDNT_PS_ATT_ALL.publish_outcomes_ind%TYPE ,
  p_new_crs_rqrmnt_complete_ind IN IGS_EN_STDNT_PS_ATT_ALL.course_rqrmnt_complete_ind%TYPE ,
  p_old_crs_rqrmnt_complete_ind IN IGS_EN_STDNT_PS_ATT_ALL.course_rqrmnt_complete_ind%TYPE ,
  p_new_crs_rqrmnts_complete_dt IN DATE ,
  p_old_crs_rqrmnts_complete_dt IN DATE ,
  p_new_s_completed_source_type IN VARCHAR2 ,
  p_old_s_completed_source_type IN VARCHAR2 ,
  p_new_override_time_limitation IN IGS_EN_STDNT_PS_ATT_ALL.override_time_limitation%TYPE ,
  p_old_override_time_limitation IN IGS_EN_STDNT_PS_ATT_ALL.override_time_limitation%TYPE ,
  p_new_advanced_standing_ind IN IGS_EN_STDNT_PS_ATT_ALL.advanced_standing_ind%TYPE ,
  p_old_advanced_standing_ind IN IGS_EN_STDNT_PS_ATT_ALL.advanced_standing_ind%TYPE ,
  p_new_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_old_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_new_self_help_group_ind IN VARCHAR2 ,
  p_old_self_help_group_ind IN VARCHAR2 ,
  p_new_correspondence_cat IN VARCHAR2 ,
  p_old_correspondence_cat IN IGS_EN_STDNT_PS_ATT_ALL.correspondence_cat%TYPE ,
  p_new_adm_adm_appl_number IN NUMBER ,
  p_old_adm_adm_appl_number IN NUMBER ,
  p_new_adm_nominated_course_cd IN VARCHAR2 ,
  p_old_adm_nominated_course_cd IN VARCHAR2 ,
  p_new_adm_sequence_number IN NUMBER ,
  p_old_adm_sequence_number IN NUMBER ,
  p_new_update_who IN IGS_EN_STDNT_PS_ATT_ALL.last_updated_by%TYPE ,
  p_old_update_who IN IGS_EN_STDNT_PS_ATT_ALL.last_updated_by%TYPE ,
  p_new_update_on IN IGS_EN_STDNT_PS_ATT_ALL.last_update_date%TYPE ,
  p_old_update_on IN IGS_EN_STDNT_PS_ATT_ALL.last_update_date%TYPE ,
  p_new_last_date_of_attendance IN IGS_EN_STDNT_PS_ATT_ALL.last_date_of_attendance%TYPE ,
  p_old_last_date_of_attendance IN IGS_EN_STDNT_PS_ATT_ALL.last_date_of_attendance%TYPE ,
  p_new_dropped_by IN IGS_EN_STDNT_PS_ATT_ALL.dropped_by%TYPE ,
  p_old_dropped_by IN IGS_EN_STDNT_PS_ATT_ALL.dropped_by%TYPE ,
  p_new_primary_program_type IN IGS_EN_STDNT_PS_ATT_ALL.primary_program_type%TYPE ,
  p_old_primary_program_type IN IGS_EN_STDNT_PS_ATT_ALL.primary_program_type%TYPE ,
  p_new_primary_prog_type_source IN IGS_EN_STDNT_PS_ATT_ALL.primary_prog_type_source%TYPE,
  p_old_primary_prog_type_source IN IGS_EN_STDNT_PS_ATT_ALl.primary_prog_type_source%TYPE ,
  p_new_catalog_cal_type IN  IGS_EN_STDNT_PS_ATT_ALl.catalog_cal_type%TYPE ,
  p_old_catalog_cal_type IN  IGS_EN_STDNT_PS_ATT_ALl.catalog_cal_type%TYPE ,
  p_new_catalog_seq_num IN  IGS_EN_STDNT_PS_ATT_ALl.catalog_seq_num%TYPE,
  p_old_catalog_seq_num IN  IGS_EN_STDNT_PS_ATT_ALl.catalog_seq_num%TYPE ,
  p_new_key_program IN  IGS_EN_STDNT_PS_ATT_ALl.key_program%TYPE ,
  p_old_key_program IN  IGS_EN_STDNT_PS_ATT_ALl.key_program%TYPE ,
  p_new_override_cmpl_dt IN IGS_EN_STDNT_PS_ATT_ALL.override_cmpl_dt%TYPE ,
  p_old_override_cmpl_dt IN IGS_EN_STDNT_PS_ATT_ALL.override_cmpl_dt%TYPE ,
  p_new_manual_ovr_cmpl_dt_ind IN IGS_EN_STDNT_PS_ATT_ALL.manual_ovr_cmpl_dt_ind%TYPE  ,
  p_old_manual_ovr_cmpl_dt_ind IN IGS_EN_STDNT_PS_ATT_ALL.manual_ovr_cmpl_dt_ind%TYPE,
  p_new_coo_id IN IGS_EN_STDNT_PS_ATT_ALL.coo_id%TYPE,
  p_old_coo_id IN IGS_EN_STDNT_PS_ATT_ALL.coo_id%TYPE,
  p_new_igs_pr_class_std_id IGS_EN_STDNT_PS_ATT_ALL.igs_pr_class_std_id%TYPE,
  p_old_igs_pr_class_std_id IGS_EN_STDNT_PS_ATT_ALL.igs_pr_class_std_id%TYPE
)
AS

BEGIN
DECLARE
    r_scah      IGS_AS_SC_ATTEMPT_H%ROWTYPE;
    v_create_history    BOOLEAN :=FALSE;
    v_fs_description    IGS_FI_FUND_SRC.description%TYPE;
    v_elo_description   IGS_AD_LOCATION.description%TYPE;
    v_fc_description    IGS_FI_FEE_CAT.description%TYPE;
    v_cc_description    IGS_CO_CAT.description%TYPE;

    CURSOR c_find_fs_desc IS
        SELECT  description
        FROM    IGS_FI_FUND_SRC
        WHERE   funding_source = r_scah.funding_source;
    CURSOR c_find_elo_desc IS
        SELECT  description
        FROM    IGS_AD_LOCATION
        WHERE   location_cd = r_scah.exam_location_cd;
    CURSOR c_find_fc_desc IS
        SELECT  description
        FROM    IGS_FI_FEE_CAT
        WHERE   fee_cat = r_scah.fee_cat;
    CURSOR c_find_cc_desc IS
        SELECT  description
        FROM    IGS_CO_CAT
        WHERE   correspondence_cat = r_scah.correspondence_cat;
BEGIN

    -- check if a history is required
    IF p_new_version_number <> p_old_version_number THEN
        r_scah.version_number := p_old_version_number;
        v_create_history := TRUE;
    END IF;
    IF p_new_cal_type <> p_old_cal_type THEN
        r_scah.cal_type := p_old_cal_type;
        v_create_history := TRUE;
    END IF;
    IF p_new_location_cd <> p_old_location_cd THEN
        r_scah.location_cd := p_old_location_cd;
        v_create_history := TRUE;
    END IF;
    IF p_new_attendance_mode <> p_old_attendance_mode THEN
        r_scah.attendance_mode := p_old_attendance_mode;
        v_create_history := TRUE;
    END IF;
    IF p_new_attendance_type <> p_old_attendance_type THEN
        r_scah.attendance_type := p_old_attendance_type;
        v_create_history := TRUE;
    END IF;
    IF p_new_student_confirmed_ind <> p_old_student_confirmed_ind THEN
        r_scah.student_confirmed_ind := p_old_student_confirmed_ind;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_commencement_dt, TO_DATE('01/01/1900', 'DD/MM/YYYY')) <>
            NVL(p_old_commencement_dt, TO_DATE('01/01/1900', 'DD/MM/YYYY')) THEN
        r_scah.commencement_dt := p_old_commencement_dt;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_course_attempt_status, 'NULL') <>
            NVL(p_old_course_attempt_status, 'NULL') THEN
        r_scah.course_attempt_status := p_old_course_attempt_status;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_progression_status, 'NULL') <>
            NVL(p_old_progression_status, 'NULL') THEN
        r_scah.progression_status := p_old_progression_status;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_derived_att_type, 'NULL') <>
            NVL( p_old_derived_att_type, 'NULL') THEN
        r_scah.derived_att_type := p_old_derived_att_type;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_derived_att_mode, 'NULL') <>
            NVL(p_old_derived_att_mode, 'NULL') THEN
        r_scah.derived_att_mode := p_old_derived_att_mode;
        v_create_history := TRUE;
    END IF;
    IF p_new_provisional_ind <> p_old_provisional_ind THEN
        r_scah.provisional_ind := p_old_provisional_ind;
        v_create_history := TRUE;
    END IF;

    IF NVL(p_new_discontinued_dt, TO_DATE('01/01/1900', 'DD/MM/YYYY')) <>
            NVL(p_old_discontinued_dt, TO_DATE('01/01/1900', 'DD/MM/YYYY')) THEN
        r_scah.discontinued_dt := p_old_discontinued_dt;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_dscntntn_reason_cd, 'NULL') <>
            NVL(p_old_dscntntn_reason_cd, 'NULL') THEN
        r_scah.discontinuation_reason_cd := p_old_dscntntn_reason_cd;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_lapsed_dt,TO_DATE('01/01/4000','DD/MM/YYYY')) <>
            NVL(p_old_lapsed_dt,TO_DATE('01/01/4000','DD/MM/YYYY')) THEN
        r_scah.lapsed_dt := p_old_lapsed_dt;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_funding_source, 'NULL') <> NVL(p_old_funding_source, 'NULL') THEN
        r_scah.funding_source := p_old_funding_source;
        IF NVL(p_old_funding_source, 'NULL') <> 'NULL' THEN
            -- get the funding source description
            OPEN    c_find_fs_desc;
            FETCH   c_find_fs_desc   INTO   r_scah.fs_description;
            CLOSE   c_find_fs_desc;
        END IF;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_exam_location_cd, 'NULL') <>
            NVL(p_old_exam_location_cd, 'NULL') THEN
        r_scah.exam_location_cd := p_old_exam_location_cd;
        IF NVL(p_old_exam_location_cd, 'NULL') <> 'NULL' THEN
            -- get the exam IGS_AD_LOCATION description
            OPEN    c_find_elo_desc;
            FETCH   c_find_elo_desc  INTO   r_scah.elo_description;
            CLOSE   c_find_elo_desc;
        END IF;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_derived_cmpltn_yr, 0) <>
            NVL(p_old_derived_cmpltn_yr, 0) THEN
        r_scah.derived_completion_yr := p_old_derived_cmpltn_yr;
        v_create_history := TRUE;
    END IF;

    IF NVL(p_new_derived_cmpltn_perd, 'NULL') <>
            NVL(p_old_derived_cmpltn_perd, 'NULL') THEN
        r_scah.derived_completion_perd := p_old_derived_cmpltn_perd;
        v_create_history := TRUE;
    END IF;

    IF NVL(p_new_nominated_cmpltn_yr, 0) <>
            NVL(p_old_nominated_cmpltn_yr, 0) THEN
        r_scah.nominated_completion_yr := p_old_nominated_cmpltn_yr;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_nominated_cmpltn_perd, 'NULL') <>
            NVL(p_old_nominated_cmpltn_perd, 'NULL') THEN
        r_scah.nominated_completion_perd := p_old_nominated_cmpltn_perd;
        v_create_history := TRUE;
    END IF;
    IF p_new_rule_check_ind <> p_old_rule_check_ind THEN
        r_scah.rule_check_ind := p_old_rule_check_ind;
        v_create_history := TRUE;
    END IF;
    IF p_new_waive_option_check_ind <> p_old_waive_option_check_ind THEN
        r_scah.waive_option_check_ind := p_old_waive_option_check_ind;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_last_rule_check_dt, TO_DATE('01/01/1900', 'DD/MM/YYYY')) <>
            NVL(p_old_last_rule_check_dt, TO_DATE('01/01/1900', 'DD/MM/YYYY')) THEN
        r_scah.last_rule_check_dt := p_old_last_rule_check_dt;
        v_create_history := TRUE;
    END IF;
    IF p_new_publish_outcomes_ind <> p_old_publish_outcomes_ind THEN
        r_scah.publish_outcomes_ind := p_old_publish_outcomes_ind;
        v_create_history := TRUE;
    END IF;
    IF p_new_crs_rqrmnt_complete_ind <> p_old_crs_rqrmnt_complete_ind THEN
        r_scah.course_rqrmnt_complete_ind := p_old_crs_rqrmnt_complete_ind;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_crs_rqrmnts_complete_dt, TO_DATE('01/01/1900', 'DD/MM/YYYY')) <>
            NVL(p_old_crs_rqrmnts_complete_dt,
                    TO_DATE('01/01/1900', 'DD/MM/YYYY')) THEN
        r_scah.course_rqrmnts_complete_dt := p_old_crs_rqrmnts_complete_dt;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_s_completed_source_type, 'NULL') <>
            NVL(p_old_s_completed_source_type, 'NULL') THEN
        r_scah.s_completed_source_type := p_old_s_completed_source_type;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_override_time_limitation, 0) <>
            NVL(p_old_override_time_limitation, 0) THEN
        r_scah.override_time_limitation := p_old_override_time_limitation;
        v_create_history := TRUE;
    END IF;
    IF p_new_advanced_standing_ind <> p_old_advanced_standing_ind THEN
        r_scah.advanced_standing_ind := p_old_advanced_standing_ind;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_fee_cat, 'NULL') <> NVL(p_old_fee_cat, 'NULL') THEN
        r_scah.fee_cat := p_old_fee_cat;
        IF NVL(p_old_fee_cat, 'NULL') <> 'NULL' THEN
            -- get the fee category description
            OPEN    c_find_fc_desc;
            FETCH   c_find_fc_desc   INTO   r_scah.fc_description;
            CLOSE   c_find_fc_desc;
        END IF;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_correspondence_cat, 'NULL') <>
            NVL(p_old_correspondence_cat, 'NULL') THEN
        r_scah.correspondence_cat := p_old_correspondence_cat;
        IF NVL(p_old_correspondence_cat, 'NULL') <> 'NULL' THEN
            -- get the correspondence category description
            OPEN    c_find_cc_desc;
            FETCH   c_find_cc_desc   INTO   r_scah.cc_description;
            CLOSE   c_find_cc_desc;
        END IF;
        v_create_history := TRUE;
    END IF;
    IF p_new_self_help_group_ind <> p_old_self_help_group_ind THEN
        r_scah.self_help_group_ind := p_old_self_help_group_ind;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_adm_adm_appl_number,-1) <>
                NVL(p_old_adm_adm_appl_number,-1) THEN
        r_scah.adm_admission_appl_number := p_old_adm_adm_appl_number;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_adm_nominated_course_cd,'NULL') <>
                NVL(p_old_adm_nominated_course_cd,'NULL') THEN
        r_scah.adm_nominated_course_cd := p_old_adm_nominated_course_cd;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_adm_sequence_number,-1) <>
                NVL(p_old_adm_sequence_number,-1) THEN
        r_scah.adm_sequence_number := p_old_adm_sequence_number;
        v_create_history := TRUE;
    END IF;

    -- Modified by : jbegum
        -- Added this IF condition as part of Enhancement Bug # 1832130

    IF NVL(p_new_last_date_of_attendance, TO_DATE('01/01/1900', 'DD/MM/YYYY')) <>
            NVL(p_old_last_date_of_attendance, TO_DATE('01/01/1900', 'DD/MM/YYYY')) THEN
        r_scah.last_date_of_attendance := p_old_last_date_of_attendance;
        v_create_history := TRUE;
    END IF;

    -- Modified by : jbegum
        -- Added this IF condition as part of Enhancement Bug # 1832130

    IF NVL(p_new_dropped_by,'NULL') <>
                NVL(p_old_dropped_by,'NULL') THEN
        r_scah.dropped_by := p_old_dropped_by;
        v_create_history := TRUE;
    END IF;

        -- Modified by : kkillams
        -- Added this IF condition(s) as part of Enhancement Bug # 2027984

    IF NVL(p_new_primary_program_type,'NULL') <>
                NVL(p_old_primary_program_type,'NULL') THEN
        r_scah.primary_program_type :=p_old_primary_program_type;
        v_create_history := TRUE;
    END IF;
       IF NVL(p_new_primary_prog_type_source,'NULL') <>
                NVL(  p_old_primary_prog_type_source ,'NULL') THEN
        r_scah.primary_prog_type_source :=  p_old_primary_prog_type_source ;
        v_create_history := TRUE;
    END IF;
        IF NVL(p_new_catalog_cal_type,'NULL') <>
                NVL(p_old_catalog_cal_type ,'NULL') THEN
        r_scah.catalog_cal_type  := p_old_catalog_cal_type ;
        v_create_history := TRUE;
    END IF;

        IF NVL(p_new_catalog_seq_num,-1) <>
                NVL(p_old_catalog_seq_num ,-1) THEN
        r_scah.catalog_seq_num  :=   p_old_catalog_seq_num ;
        v_create_history := TRUE;
    END IF;
        IF NVL(p_new_key_program ,'NULL') <>
                NVL(p_old_key_program ,'NULL') THEN
        r_scah.key_program  := p_old_key_program ;
        v_create_history := TRUE;
    END IF;
        IF NVL(p_new_override_cmpl_dt ,TO_DATE('01/01/1900', 'DD/MM/YYYY')) <>
                NVL(p_old_override_cmpl_dt ,TO_DATE('01/01/1900', 'DD/MM/YYYY')) THEN
        r_scah.override_cmpl_dt  := p_old_override_cmpl_dt ;
        v_create_history := TRUE;
    END IF;
    IF NVL(p_new_manual_ovr_cmpl_dt_ind ,'NULL') <>
                NVL(p_old_manual_ovr_cmpl_dt_ind ,'NULL') THEN
        r_scah.manual_ovr_cmpl_dt_ind  := p_old_manual_ovr_cmpl_dt_ind ;
        v_create_history := TRUE;
    END IF;

    -- validate coo_id and igs_pr_class_std_id
    IF NVL(p_new_coo_id,-1) <> NVL(p_old_coo_id,-1) THEN
        r_scah.coo_id := p_old_coo_id;
        v_create_history := TRUE;
    END IF;

   IF NVL(p_new_igs_pr_class_std_id,-1) <> NVL(p_old_igs_pr_class_std_id,-1) THEN
        r_scah.igs_pr_class_std_id := p_old_igs_pr_class_std_id;
        v_create_history := TRUE;
    END IF;


    -- create a history record if a column has changed value
    IF v_create_history = TRUE THEN
        r_scah.person_id := p_person_id;
        r_scah.course_cd := p_course_cd;
        r_scah.hist_start_dt := p_old_update_on;
        r_scah.hist_end_dt := p_new_update_on;
        r_scah.hist_who := p_old_update_who;
        -- remove one second from the hist_start_dt value
                -- when the hist_start_dt and hist_end_dt are the same
                -- to avoid a primary key constraint from occurring
                -- when saving the record
                IF (r_scah.hist_start_dt = r_scah.hist_end_dt) THEN
                            r_scah.hist_end_dt := r_scah.hist_start_dt + 1 /
                             (60*24*60);
                END IF;

            DECLARE
                    l_rowid VARCHAR2(25);
                    l_org_id NUMBER := igs_ge_gen_003.get_org_id;
            BEGIN
-- ADD_ROW is used instead of INSERT_ROW, so that the history record is updated in
-- case more than one history record is created within a second. More than one record
-- are being created while recursive update_row of ps att table is performed.
        IGS_AS_SC_ATTEMPT_H_PKG.ADD_ROW (
                        x_rowid => l_rowid,
                        x_person_id => r_scah.person_id,
            x_course_cd => r_scah.course_cd,
            x_hist_start_dt => r_scah.hist_start_dt,
            x_hist_end_dt => r_scah.hist_end_dt,
            x_hist_who => r_scah.hist_who,
            x_version_number => r_scah.version_number,
            x_cal_type => r_scah.cal_type,
            x_location_cd => r_scah.location_cd,
            x_attendance_mode => r_scah.attendance_mode,
            x_attendance_type => r_scah.attendance_type,
            x_student_confirmed_ind => r_scah.student_confirmed_ind,
            x_commencement_dt => r_scah.commencement_dt,
            x_course_attempt_status => r_scah.course_attempt_status,
            x_progression_status => r_scah.progression_status,
            x_derived_att_type => r_scah.derived_att_type,
            x_derived_att_mode => r_scah.derived_att_mode,
            x_provisional_ind => r_scah.provisional_ind,
            x_discontinued_dt => r_scah.discontinued_dt,
            x_discontinuation_reason_cd => r_scah.discontinuation_reason_cd,
            x_lapsed_dt => r_scah.lapsed_dt,
            x_funding_source => r_scah.funding_source,
            x_fs_description => r_scah.fs_description,
            x_exam_location_cd => r_scah.exam_location_cd,
            x_elo_description => r_scah.elo_description,
            x_derived_completion_yr => r_scah.derived_completion_yr,
            x_derived_completion_perd => r_scah.derived_completion_perd,
            x_nominated_completion_yr => r_scah.nominated_completion_yr,
            x_nominated_completion_perd => r_scah.nominated_completion_perd,
            x_rule_check_ind =>  r_scah.rule_check_ind,
            x_waive_option_check_ind => r_scah.waive_option_check_ind,
            x_last_rule_check_dt => r_scah.last_rule_check_dt,
            x_publish_outcomes_ind => r_scah.publish_outcomes_ind,
            x_course_rqrmnt_complete_ind => r_scah.course_rqrmnt_complete_ind,
            x_course_rqrmnts_complete_dt => r_scah.course_rqrmnts_complete_dt,
            x_s_completed_source_type => r_scah.s_completed_source_type,
            x_override_time_limitation => r_scah.override_time_limitation,
            x_advanced_standing_ind => r_scah.advanced_standing_ind,
            x_fee_cat => r_scah.fee_cat,
            x_fc_description => r_scah.fc_description,
            x_correspondence_cat => r_scah.correspondence_cat,
            x_cc_description => r_scah.cc_description,
            x_self_help_group_ind => r_scah.self_help_group_ind,
            x_adm_admission_appl_number => r_scah.adm_admission_appl_number,
            x_adm_nominated_course_cd => r_scah.adm_nominated_course_cd,
            x_adm_sequence_number => r_scah.adm_sequence_number,
            x_org_id => l_org_id,
            x_last_date_of_attendance => r_scah.last_date_of_attendance,
            x_dropped_by => r_scah.dropped_by,
            x_primary_program_type =>r_scah.primary_program_type,
            x_primary_prog_type_source =>r_scah.primary_prog_type_source,
            x_catalog_cal_type =>r_scah.catalog_cal_type,
            x_catalog_seq_num =>r_scah.catalog_seq_num,
            x_key_program =>r_scah.key_program,
            x_override_cmpl_dt => r_scah.override_cmpl_dt,
            x_manual_ovr_cmpl_dt_ind  => r_scah.manual_ovr_cmpl_dt_ind,
            x_coo_id  => r_scah.coo_id,
            x_igs_pr_class_std_id => r_scah.igs_pr_class_std_id
            );
           END;
    END IF;
END;

END enrp_ins_sca_hist;

FUNCTION Enrp_Ins_Scho_Dflt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS

BEGIN   -- enrp_ins_scho_dflt_temp
    -- This routine will attempt to insert a default IGS_EN_STDNTPSHECSOP
    -- record based on just the hecs payment option (which has typically be
    -- collected during admissions).
    -- This routine will only default EXEMPT HECS payment options. It is not
    -- logical to default anything but exempt, as a HECS payment options form must
    -- be submitted anyway.
    -- It is assumed that the exempt categories don?t have applicable visa flags,
    -- tax file number details or differential HECS details. These are all
    -- defaulted to 'N' or NULL.
DECLARE
    e_resource_busy_exception       EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
    v_message_name          VARCHAR2(30);
    v_govt_hecs_payment_option  IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
    v_expire_aftr_acdmc_perd_ind
                    IGS_FI_HECS_PAY_OPTN.expire_aftr_acdmc_perd_ind%TYPE;
    v_scho_rec          IGS_EN_STDNTPSHECSOP%ROWTYPE;
    v_start_dt          IGS_EN_STDNTPSHECSOP.start_dt%TYPE;
    v_end_dt                IGS_EN_STDNTPSHECSOP.end_dt%TYPE;
    v_hecs_payment_option       IGS_EN_STDNTPSHECSOP.hecs_payment_option%TYPE;
    v_outside_aus_res_ind       IGS_EN_STDNTPSHECSOP.outside_aus_res_ind%TYPE;
    v_update_existing       BOOLEAN;

    CURSOR c_hpo IS
        SELECT  hpo.govt_hecs_payment_option,
            hpo.expire_aftr_acdmc_perd_ind
        FROM    IGS_FI_HECS_PAY_OPTN    hpo
        WHERE   hpo.hecs_payment_option = p_hecs_payment_option;
    CURSOR c_ghpo_exempt (
        cp_govt_hecs_payment_option
            IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE)  IS
        SELECT  'x'
        FROM    IGS_FI_GOV_HEC_PA_OP    ghpo
        WHERE   ghpo.govt_hecs_payment_option   = cp_govt_hecs_payment_option AND
            ghpo.s_hecs_payment_type    = 'EXEMPT';
    v_is_exempt     VARCHAR2(1);
    -- ensure that NULL end date is the max value.
    CURSOR c_scho_open_end IS
        SELECT  ROWID,
                        IGS_EN_STDNTPSHECSOP.*
        FROM    IGS_EN_STDNTPSHECSOP
        WHERE   person_id   = p_person_id   AND
            course_cd   = p_course_cd   AND
            end_dt  IS NULL
        FOR UPDATE OF end_dt NOWAIT;

              c_scho_open_end_rec c_scho_open_end%ROWTYPE;

    CURSOR c_scho_max_enddt IS
        SELECT  scho.end_dt,
            scho.start_dt,
            scho.hecs_payment_option
        FROM    IGS_EN_STDNTPSHECSOP scho
        WHERE   scho.person_id  = p_person_id   AND
            scho.course_cd  = p_course_cd
        ORDER BY scho.end_dt DESC;
    CURSOR c_scho_update IS
        SELECT  ROWID, IGS_EN_STDNTPSHECSOP.*
        FROM    IGS_EN_STDNTPSHECSOP
        WHERE   person_id   = p_person_id   AND
            course_cd   = p_course_cd
        FOR UPDATE OF hecs_payment_option NOWAIT;

          c_scho_update_rec c_scho_update%ROWTYPE;


    CURSOR c_ci IS
        SELECT  ci.end_dt
        FROM    IGS_CA_INST ci
        WHERE   ci.cal_type = p_acad_cal_type AND
            ci.sequence_number = p_acad_sequence_number;
    v_ci_end_dt IGS_CA_INST.end_dt%TYPE;
BEGIN
    -- Set the default message number
    p_message_name := NULL;
    -- Select the type of HECS option from the hecs_payment_option table
    OPEN c_hpo;
    FETCH c_hpo INTO v_govt_hecs_payment_option,
            v_expire_aftr_acdmc_perd_ind;
    IF c_hpo%NOTFOUND THEN
        -- Error will be picked up by calling routine
        CLOSE c_hpo;
        RETURN TRUE;
    ELSE
        CLOSE c_hpo;
        IF v_govt_hecs_payment_option IS NULL THEN
            -- The selected HPO must be mapped onto a govt payment option.
            p_message_name := 'IGS_EN_NOT_PREENR_HECS_NOTMAP';
            RETURN FALSE;
        END IF;
        OPEN c_ghpo_exempt(
                v_govt_hecs_payment_option);
        FETCH c_ghpo_exempt INTO v_is_exempt;
        -- Only exempt payment options can be defaulted through this process.
        -- Return an error if a non-exempt type has been passed.
        IF c_ghpo_exempt%NOTFOUND THEN
            CLOSE c_ghpo_exempt;
            p_message_name := 'IGS_EN_NOT_PREENR_HECS_EXEMPT';
            RETURN FALSE;
        END IF;
        CLOSE c_ghpo_exempt;
    END IF; -- c_hpo%NOTFOUND
    -- Default the fields which have no associated logic in the following sections.
    v_scho_rec.end_dt := NULL;
    v_scho_rec.differential_hecs_ind := 'N';
    v_scho_rec.diff_hecs_ind_update_who := NULL;
    v_scho_rec.diff_hecs_ind_update_on := NULL;
    v_scho_rec.diff_hecs_ind_update_comments := NULL;
    v_scho_rec.outside_aus_res_ind := 'N';
    v_scho_rec.nz_citizen_ind := 'N';
    v_scho_rec.nz_citizen_less2yr_ind := 'N';
    v_scho_rec.nz_citizen_not_res_ind := 'N';
    v_scho_rec.safety_net_ind := 'N';
    v_scho_rec.tax_file_number := NULL;
    v_scho_rec.tax_file_number_collected_dt := NULL;
    v_scho_rec.tax_file_invalid_dt := NULL;
    v_scho_rec.tax_file_certificate_number := NULL;
    -- Establish the start date for the HECS record.
    -- If required, end the previous record.
    v_update_existing := FALSE;
    OPEN c_scho_open_end;

    FETCH c_scho_open_end INTO c_scho_open_end_rec;

    -- IGS_EN_STDNTPSHECSOP.end_dt IS NOT NULL OR
    -- c_scho_open_end%NOTFOUND
    IF c_scho_open_end%NOTFOUND THEN
        CLOSE c_scho_open_end;
        OPEN c_scho_max_enddt;
        FETCH c_scho_max_enddt INTO     v_start_dt,
                        v_end_dt,
                        v_hecs_payment_option;
        IF c_scho_max_enddt%NOTFOUND THEN
            CLOSE c_scho_max_enddt;
            v_start_dt := TRUNC(SYSDATE);
            v_scho_rec.end_dt := NULL;
        ELSE
            CLOSE c_scho_max_enddt;
            -- If a HECS option record already exists which is past
            -- the current date then a new one cannot be defaulted.
            IF (v_end_dt > SYSDATE OR
                    v_start_dt > SYSDATE) THEN
                IF v_hecs_payment_option = p_hecs_payment_option THEN
                    p_message_name := NULL;
                    RETURN TRUE;
                ELSE
                    p_message_name := 'IGS_EN_NOT_PREENR_HECS_OPTION'
                ;
                    RETURN FALSE;
                END IF;
            ELSE    -- end_dt <= SYSDATE
                v_start_dt := TRUNC(SYSDATE);
                v_scho_rec.end_dt := NULL;
            END IF;
        END IF;
    ELSE -- c_scho_open_end%FOUND. End_dt is null.
        -- If the details which are being defaulted are different then end the
        -- record. If not, leave the record intact and exit the routine.
        IF (v_hecs_payment_option = p_hecs_payment_option AND
                v_outside_aus_res_ind = v_scho_rec.outside_aus_res_ind) THEN
            RETURN TRUE;
        ELSIF v_start_dt = TRUNC(SYSDATE) THEN
            v_update_existing := TRUE;
        ELSE
            -- End the existing record prior to inserting a new one.

                        IGS_EN_STDNTPSHECSOP_PKG.UPDATE_ROW(
                          X_ROWID => c_scho_open_end_rec.ROWID,
                          X_PERSON_ID => c_scho_open_end_rec.PERSON_ID,
                          X_COURSE_CD => c_scho_open_end_rec.COURSE_CD,
                          X_START_DT  => c_scho_open_end_rec.START_DT,
                          X_END_DT  => TRUNC(SYSDATE)-1,
                          X_HECS_PAYMENT_OPTION => c_scho_open_end_rec.HECS_PAYMENT_OPTION,
                          X_DIFFERENTIAL_HECS_IND => c_scho_open_end_rec.DIFFERENTIAL_HECS_IND,
                          X_DIFF_HECS_IND_UPDATE_WHO => c_scho_open_end_rec.DIFF_HECS_IND_UPDATE_WHO,
                          X_DIFF_HECS_IND_UPDATE_ON  => c_scho_open_end_rec.DIFF_HECS_IND_UPDATE_ON ,
                          X_OUTSIDE_AUS_RES_IND => c_scho_open_end_rec.OUTSIDE_AUS_RES_IND,
                          X_NZ_CITIZEN_IND => c_scho_open_end_rec.NZ_CITIZEN_IND,
                          X_NZ_CITIZEN_LESS2YR_IND => c_scho_open_end_rec.NZ_CITIZEN_LESS2YR_IND,
                          X_NZ_CITIZEN_NOT_RES_IND => c_scho_open_end_rec.NZ_CITIZEN_NOT_RES_IND,
                          X_SAFETY_NET_IND => c_scho_open_end_rec.SAFETY_NET_IND,
                          X_TAX_FILE_NUMBER  => c_scho_open_end_rec.TAX_FILE_NUMBER ,
                          X_TAX_FILE_NUMBER_COLLECTED_DT  => c_scho_open_end_rec.TAX_FILE_NUMBER_COLLECTED_DT,
                          X_TAX_FILE_INVALID_DT  => c_scho_open_end_rec.TAX_FILE_INVALID_DT,
                          X_TAX_FILE_CERTIFICATE_NUMBER  => c_scho_open_end_rec.TAX_FILE_CERTIFICATE_NUMBER,
                          X_DIFF_HECS_IND_UPDATE_COMMENT => c_scho_open_end_rec.DIFF_HECS_IND_UPDATE_COMMENTS,
                          X_MODE =>  'R'
                          );


        END IF;
        CLOSE c_scho_open_end;
        v_start_dt := TRUNC(SYSDATE);
        v_scho_rec.end_dt := NULL;
    END IF; -- c_scho_open_end%NOTFOUND
    -- Test whether the new option must expire at the end of the academic period.
    -- If so, set the end date accordingly.
    IF v_expire_aftr_acdmc_perd_ind = 'Y' THEN
        OPEN c_ci;
        FETCH c_ci INTO v_ci_end_dt;
        IF c_ci%FOUND THEN
            IF v_ci_end_dt >= TRUNC(SYSDATE) THEN
                v_scho_rec.end_dt := v_ci_end_dt;
            END IF;
        END IF;
        CLOSE c_ci;
    END IF;
    -- Call routine to validate the defaulted HECS option.
    -- If fails then defaulting is not possible.
    IF IGS_EN_VAL_SCHO.enrp_val_scho_all(
                p_person_id,
                p_course_cd,
                v_start_dt,
                v_scho_rec.end_dt,
                p_hecs_payment_option,
                v_scho_rec.differential_hecs_ind,
                v_scho_rec.diff_hecs_ind_update_who,
                v_scho_rec.diff_hecs_ind_update_on,
                v_scho_rec.diff_hecs_ind_update_comments,
                v_scho_rec.outside_aus_res_ind,
                v_scho_rec.nz_citizen_ind,
                v_scho_rec.nz_citizen_less2yr_ind,
                v_scho_rec.nz_citizen_not_res_ind,
                v_scho_rec.safety_net_ind,
                v_scho_rec.tax_file_number,
                v_scho_rec.tax_file_number_collected_dt,
                v_scho_rec.tax_file_invalid_dt,
                v_scho_rec.tax_file_certificate_number,
                v_message_name) = FALSE THEN
        p_message_name := v_message_name;
        RETURN FALSE;
    END IF;
    -- Insert default into scho
    v_scho_rec.person_id := p_person_id;
    v_scho_rec.course_cd := p_course_cd;
    v_scho_rec.hecs_payment_option := p_hecs_payment_option;
    IF v_update_existing = FALSE THEN

            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN

        IGS_EN_STDNTPSHECSOP_PKG.INSERT_ROW(
                        x_rowid => l_rowid,
            x_person_id => v_scho_rec.person_id,
            x_course_cd => v_scho_rec.course_cd,
            x_start_dt => v_start_dt,
            x_end_dt => v_scho_rec.end_dt,
            x_hecs_payment_option => v_scho_rec.hecs_payment_option,
            x_differential_hecs_ind => v_scho_rec.differential_hecs_ind,
            x_diff_hecs_ind_update_who => v_scho_rec.diff_hecs_ind_update_who,
            x_diff_hecs_ind_update_on => v_scho_rec.diff_hecs_ind_update_on,
            x_diff_hecs_ind_update_comment => v_scho_rec.diff_hecs_ind_update_comments,
            x_outside_aus_res_ind => v_scho_rec.outside_aus_res_ind,
            x_nz_citizen_ind => v_scho_rec.nz_citizen_ind,
            x_nz_citizen_less2yr_ind => v_scho_rec.nz_citizen_less2yr_ind,
            x_nz_citizen_not_res_ind => v_scho_rec.nz_citizen_not_res_ind,
            x_safety_net_ind => v_scho_rec.safety_net_ind,
            x_tax_file_number => v_scho_rec.tax_file_number,
            x_tax_file_number_collected_dt => v_scho_rec.tax_file_number_collected_dt,
            x_tax_file_invalid_dt => v_scho_rec.tax_file_invalid_dt,
            x_tax_file_certificate_number => v_scho_rec.tax_file_certificate_number);
            END;

    ELSE
        -- Get lock on record before updating. If lock couldn't be obtained,
        --  return FALSE with message number 4064
        OPEN c_scho_update;

        FETCH c_scho_update INTO c_scho_update_rec;

        IF c_scho_update%FOUND THEN


                        IGS_EN_STDNTPSHECSOP_PKG.UPDATE_ROW(
                          X_ROWID => c_scho_update_rec.ROWID,
                          X_PERSON_ID => c_scho_update_rec.PERSON_ID,
                          X_COURSE_CD => c_scho_update_rec.COURSE_CD,
                          X_START_DT  => c_scho_update_rec.START_DT,
                          X_END_DT  => v_scho_rec.end_dt,
                          X_HECS_PAYMENT_OPTION => p_hecs_payment_option,
                          X_DIFFERENTIAL_HECS_IND => v_scho_rec.differential_hecs_ind,
                          X_DIFF_HECS_IND_UPDATE_WHO => v_scho_rec.DIFF_HECS_IND_UPDATE_WHO,
                          X_DIFF_HECS_IND_UPDATE_ON  => v_scho_rec.DIFF_HECS_IND_UPDATE_ON ,
                          X_OUTSIDE_AUS_RES_IND => v_scho_rec.OUTSIDE_AUS_RES_IND,
                          X_NZ_CITIZEN_IND => v_scho_rec.NZ_CITIZEN_IND,
                          X_NZ_CITIZEN_LESS2YR_IND => v_scho_rec.NZ_CITIZEN_LESS2YR_IND,
                          X_NZ_CITIZEN_NOT_RES_IND => v_scho_rec.NZ_CITIZEN_NOT_RES_IND,
                          X_SAFETY_NET_IND => v_scho_rec.SAFETY_NET_IND,
                          X_TAX_FILE_NUMBER  => v_scho_rec.TAX_FILE_NUMBER ,
                          X_TAX_FILE_NUMBER_COLLECTED_DT  => v_scho_rec.TAX_FILE_NUMBER_COLLECTED_DT,
                          X_TAX_FILE_INVALID_DT  => v_scho_rec.TAX_FILE_INVALID_DT,
                          X_TAX_FILE_CERTIFICATE_NUMBER  => v_scho_rec.TAX_FILE_CERTIFICATE_NUMBER,
                          X_DIFF_HECS_IND_UPDATE_COMMENT => v_scho_rec.DIFF_HECS_IND_UPDATE_COMMENTS,
                          X_MODE =>  'R'
                          );



        END IF;
        CLOSE c_scho_update;
    END IF;
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy_exception THEN
        IF c_hpo%ISOPEN THEN
            CLOSE c_hpo;
        END IF;
        IF c_ghpo_exempt%ISOPEN THEN
            CLOSE c_ghpo_exempt;
        END IF;
        IF c_scho_open_end%ISOPEN THEN
            CLOSE c_scho_open_end;
        END IF;
        IF c_scho_max_enddt%ISOPEN THEN
            CLOSE c_scho_max_enddt;
        END IF;
        IF c_scho_update%ISOPEN THEN
            CLOSE c_scho_update;
        END IF;
        p_message_name := 'IGS_EN_STUD_HECS_REC_LOCKED';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_hpo%ISOPEN THEN
            CLOSE c_hpo;
        END IF;
        IF c_ghpo_exempt%ISOPEN THEN
            CLOSE c_ghpo_exempt;
        END IF;
        IF c_scho_open_end%ISOPEN THEN
            CLOSE c_scho_open_end;
        END IF;
        IF c_scho_max_enddt%ISOPEN THEN
            CLOSE c_scho_max_enddt;
        END IF;
        IF c_scho_update%ISOPEN THEN
            CLOSE c_scho_update;
        END IF;
        RAISE;
END;

END enrp_ins_scho_dflt;

FUNCTION Enrp_Ins_Sct_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_transfer_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_trans_approved_dt    IN DATE,
  p_term_cal_type        IN VARCHAR2,
  p_term_seq_num         IN NUMBER,
  p_discontinue_src_flag IN VARCHAR2,
  p_uooids_to_transfer IN VARCHAR2,
  p_susa_to_transfer IN VARCHAR2,
  p_transfer_adv_stand_flag IN VARCHAR2,
  p_status_date IN DATE,
  p_status_flag IN VARCHAR2
  )
RETURN BOOLEAN AS

BEGIN   --  enrp_ins_sct_trnsfr
    -- Insert a record into the IGS_PS_STDNT_TRN table.
DECLARE
BEGIN
    -- Set the default message number
    p_message_name := NULL;
    -- * Validate parameters.
    IF p_person_id IS NULL OR
            p_course_cd IS NULL OR
            p_transfer_course_cd IS NULL THEN
        RETURN TRUE;
    END IF;
    -- * Insert into IGS_PS_STDNT_TRN
      DECLARE
                    l_rowid VARCHAR2(25);
      BEGIN

    IGS_PS_STDNT_TRN_PKG.INSERT_ROW(
                x_rowid => l_rowid,
        x_person_id => p_person_id,
        x_course_cd => p_course_cd,
        x_transfer_course_cd => p_transfer_course_cd,
        x_TRANSFER_DT =>  NVL(p_transfer_dt,SYSDATE),
        x_COMMENTS => NULL,
	      X_APPROVED_DATE => p_trans_approved_dt,
        X_EFFECTIVE_TERM_CAL_TYPE => p_term_cal_type,
        X_EFFECTIVE_TERM_SEQUENCE_NUM => p_term_seq_num,
        X_DISCONTINUE_SOURCE_FLAG => p_discontinue_src_flag,
        X_UOOIDS_TO_TRANSFER => p_uooids_to_transfer,
        X_SUSA_TO_TRANSFER => p_susa_to_transfer,
        X_TRANSFER_ADV_STAND_FLAG => p_transfer_adv_stand_flag,
        X_STATUS_DATE => p_status_date,
        X_STATUS_FLAG => p_status_flag
	);
      END;

    RETURN TRUE;
END;
END enrp_ins_sct_trnsfr;
FUNCTION enrp_check_usec_core(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_uoo_id IN NUMBER )

  ------------------------------------------------------------------
  --Created by  : Parul Tandon, Oracle IDC
  --Date created: 07-OCT-2003
  --
  --Purpose: This Function checks whether the given unit section is
  --a core unit or not in the current pattern of study for the given
  --student program attempt.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

RETURN VARCHAR2
IS



  CURSOR c_ps_att_dtls
  IS
  SELECT location_cd,
         attendance_mode,
         attendance_type,
         version_number
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = p_person_id
  AND    course_cd = p_program_cd;

  l_ps_att_dtls_rec             c_ps_att_dtls%ROWTYPE;
  l_acad_cal_type               igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;

  CURSOR c_pos ( cp_unit_set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE ) IS
  SELECT  pos.cal_type,
    pos.sequence_number,
    pos.always_pre_enrol_ind,
    pos.number_of_periods,
    pos.aprvd_ci_sequence_number ,
    pos.acad_perd_unit_set
  FROM    IGS_PS_PAT_OF_STUDY pos
  WHERE   pos.course_cd       = p_program_cd AND
    pos.version_number  = l_ps_att_dtls_rec.version_number AND
    pos.cal_type        = l_acad_cal_type AND
    ((pos.location_cd   IS NULL AND
    pos.attendance_mode     IS NULL AND
    pos.attendance_type     IS NULL AND
    pos.unit_set_cd     IS NULL AND
    pos.admission_cal_type  IS NULL AND
    pos.admission_cat   IS NULL) OR
    IGS_EN_GEN_005.enrp_get_pos_links(
            l_ps_att_dtls_rec.location_cd,
            l_ps_att_dtls_rec.attendance_mode,
            l_ps_att_dtls_rec.attendance_type,
            cp_unit_set_cd,
            NULL,
            NULL,
            pos.location_cd,
            pos.attendance_mode,
            pos.attendance_type,
            pos.unit_set_cd,
            pos.admission_cal_type,
            pos.admission_cat) > 0)
  ORDER BY IGS_EN_GEN_005.enrp_get_pos_links(
            l_ps_att_dtls_rec.location_cd,
            l_ps_att_dtls_rec.attendance_mode,
            l_ps_att_dtls_rec.attendance_type,
            cp_unit_set_cd,
            NULL,
            NULL,
            pos.location_cd,
            pos.attendance_mode,
            pos.attendance_type,
            pos.unit_set_cd,
            pos.admission_cal_type,
            pos.admission_cat) DESC;
  l_pos_rec       c_pos%ROWTYPE;


  CURSOR c_last_unit_set IS
  SELECT susa.unit_set_cd
  FROM  igs_as_su_setatmpt susa ,
        igs_en_unit_set us ,
        igs_en_unit_set_cat usc
  WHERE susa.person_id = p_person_id AND
        susa.course_cd = p_program_cd  AND
        susa.rqrmnts_complete_dt IS NULL   AND
        susa.student_confirmed_ind = 'Y' AND
        susa.end_dt     IS NULL AND
        susa.unit_set_cd = us.unit_set_cd AND
        us.unit_set_cat = usc.unit_set_cat AND
        usc.s_unit_set_cat  = 'PRENRL_YR';
  l_last_unit_set_cd    igs_as_su_setatmpt.unit_set_cd%TYPE;

  CURSOR c_map_unit_set( cp_person_id igs_as_su_setatmpt.person_id%TYPE,
                         cp_course_cd igs_as_su_setatmpt.course_cd%TYPE,
                         cp_unit_set_cd igs_as_su_setatmpt.unit_set_cd%TYPE) IS
  SELECT unit_set_cd
  FROM igs_as_su_setatmpt
  WHERE (
           (unit_set_cd = cp_unit_set_cd) OR
           (unit_set_cd IN (SELECT stream_unit_set_cd
                         FROM igs_en_unit_set_map
                         WHERE (mapping_set_cd,sequence_no) IN (SELECT mapping_set_cd,sequence_no
                                                                FROM igs_ps_us_prenr_cfg
                                                                WHERE unit_set_cd = cp_unit_set_cd)))
        )
  AND person_id = cp_person_id
  AND course_cd = cp_course_cd;

  CURSOR c_susa IS
  SELECT  susa.unit_set_cd
  FROM  igs_as_su_setatmpt susa
  WHERE susa.person_id    = p_person_id AND
    susa.course_cd    = p_program_cd AND
    susa.student_confirmed_ind = 'Y' AND
    susa.rqrmnts_complete_dt IS NULL   AND
    susa.end_dt     IS NULL;

  CURSOR c_pos_unit_sets( cp_version_number igs_ps_pat_of_study.version_number%TYPE)  IS
  SELECT unit_set_cd
  FROM igs_ps_pat_of_study pos
  WHERE  course_cd = p_program_cd AND
         version_number = cp_version_number  AND
         cal_type = l_acad_cal_type AND
         unit_set_cd  IN
         ( SELECT susa.unit_set_cd
           FROM  igs_as_su_setatmpt susa
           WHERE susa.person_id    = p_person_id AND
            susa.course_cd    = pos.course_cd AND
            susa.student_confirmed_ind = 'Y' AND
            susa.end_dt     IS NULL);

  l_core_ind                    igs_ps_pat_study_unt.core_ind%TYPE;
  l_message                     VARCHAR2(100);
  l_unit_set_cd                 igs_as_su_setatmpt.unit_set_cd%TYPE;
  l_row_count                   NUMBER;
  l_pos_count                   NUMBER;

  FUNCTION get_core_indicator (p_acad_perd_unit_set     igs_ps_pat_of_study.acad_perd_unit_set%TYPE,
                               p_sequence_number        igs_ps_pat_of_study.sequence_number%TYPE,
                               p_number_of_periods      igs_ps_pat_of_study.number_of_periods%TYPE,
                               p_unit_set_cd            igs_as_su_setatmpt.unit_set_cd%TYPE)
  RETURN VARCHAR2
  IS
    CURSOR c_usec_details IS
    SELECT  unit_cd,
            cal_type
    FROM    igs_ps_unit_ofr_opt
    WHERE   uoo_id = p_uoo_id;
    l_usec_details_rec   c_usec_details%ROWTYPE;

    CURSOR c_aci IS
    SELECT  aci.cal_type,
            aci.sequence_number,
            aci.start_dt,
            aci.end_dt
    FROM    igs_ca_inst     aci
    WHERE   aci.cal_type        = l_acad_cal_type AND
            aci.sequence_number     = l_acad_ci_sequence_number;
    l_aci_rec       c_aci%ROWTYPE;

    CURSOR c_acad_us (cp_admin_unit_Set_cd igs_as_su_setatmpt.unit_set_cd%TYPE) IS
      SELECT usm.stream_unit_set_Cd
      FROM   igs_en_unit_set_map usm,
             igs_ps_us_prenr_cfg upc
      WHERE  upc.unit_set_cd = cp_admin_unit_set_cd
      AND    usm.mapping_set_cd = upc.mapping_set_cd
      AND    usm.sequence_no = upc.sequence_no;

    CURSOR c_susa_exists (cp_stream_unit_Set_cd igs_as_su_setatmpt.unit_set_cd%TYPE,
                          cp_person_id igs_as_su_setatmpt.person_id%TYPE,
                          cp_course_cd igs_as_su_setatmpt.course_cd%TYPE) IS
      SELECT 'X'
      FROM   igs_as_su_setatmpt susa
      WHERE  susa.unit_set_cd = cp_stream_unit_set_cd
      AND    susa.person_id = cp_person_id
      AND    susa.course_cd  = cp_course_cd
      AND    susa.end_dt IS NULL
      AND    susa.rqrmnts_complete_dt IS NULL;

    CURSOR c_num_acad_perd  IS
      SELECT  DISTINCT acad_perd
      FROM   igs_en_susa_year_v
      WHERE  person_id = p_person_id
      AND   course_cd = p_program_cd
      AND   unit_set_cd = p_unit_set_cd ;

    CURSOR c_posp (
        cp_sequence_number  igs_ps_pat_of_study.sequence_number%TYPE,
        cp_number_of_periods    igs_ps_pat_of_study.number_of_periods%TYPE,
        cp_period_number    NUMBER) IS
        SELECT  posp.acad_period_num,
            posp.teach_cal_type,
            posp.sequence_number
        FROM    igs_ps_pat_study_prd posp
        WHERE   posp.pos_sequence_number    = cp_sequence_number AND
            posp.acad_period_num        >= cp_period_number AND
            posp.acad_period_num        < (cp_period_number
                            + cp_number_of_periods) AND
            EXISTS  (SELECT 'x'
                FROM    igs_ps_pat_study_unt posu
                WHERE   posp.sequence_number    = posu.posp_sequence_number AND
                    posu.unit_cd        IS NOT NULL)
        ORDER BY posp.acad_period_num;

    CURSOR c_posu (
        cp_sequence_number  igs_ps_pat_study_prd.sequence_number%TYPE,
        cp_unit_cd          igs_ps_unit_ver.unit_cd%TYPE) IS
        SELECT  core_ind
        FROM    IGS_PS_PAT_STUDY_UNT posu
        WHERE   posu.posp_sequence_number = cp_sequence_number
        AND     posu.unit_cd = cp_unit_cd;

    l_dummy           VARCHAR2(1);
    l_rec_exist       BOOLEAN;
    l_period_number   NUMBER;
    l_core_ind        igs_ps_pat_study_unt.core_ind%TYPE;

  BEGIN
    -- Get the unit section details

    OPEN c_usec_details;
    FETCH c_usec_details INTO l_usec_details_rec;
    CLOSE c_usec_details;

    -- Get the start/end dates from the academic period
    -- required by routine calls lower in the routine.

    OPEN c_aci;
    FETCH c_aci INTO l_aci_rec;
    CLOSE c_aci;

    OPEN c_pos (p_unit_set_cd);
    IF c_pos%FOUND THEN
       l_rec_exist := TRUE;
    END IF;
    CLOSE c_pos;

    IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN

      FOR vc_acad_us_rec IN c_acad_us(p_unit_set_cd) LOOP
        OPEN c_susa_exists(vc_acad_us_rec.stream_unit_set_cd, p_person_id, p_program_cd);
        FETCH c_susa_exists INTO l_dummy;
        IF c_susa_exists%FOUND THEN
          l_rec_exist := TRUE;
        END IF;
        CLOSE c_susa_exists;
      END LOOP;
    END IF;

    -- Determine the number of academic periods in which the
    -- student has been enrolled

    -- If year of program mode is enabled
    IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' AND l_rec_exist THEN

       -- If 'Academic Period within Unit Sets' is checked for the pattern of study,
       -- Get number of periods from igs_en_susa_year_v else use original function
       -- igs_en_gen_004.enrp_get_perd_num.
       IF NVL(p_acad_perd_unit_set,'N') = 'Y' AND p_unit_set_cd IS NOT NULL THEN
          OPEN c_num_acad_perd;
          FETCH c_num_acad_perd INTO l_period_number;
          CLOSE c_num_acad_perd;

          l_period_number := l_period_number + 1;
       ELSE
          l_period_number := igs_en_gen_004.enrp_get_perd_num(
                                            p_person_id,
                                            p_program_cd,
                                            l_acad_cal_type,
                                            l_acad_ci_sequence_number,
                                            l_aci_rec.start_dt);
       END IF;
    ELSE
          l_period_number := igs_en_gen_004.enrp_get_perd_num(
                                            p_person_id,
                                            p_program_cd,
                                            l_acad_cal_type,
                                            l_acad_ci_sequence_number,
                                            l_aci_rec.start_dt);
    END IF;

    -- As the function igs_en_gen_004.enrp_get_perd_num returns incremented period number, so
    -- decrement by 1 to get the current period
        IF l_period_number > 1 THEN
    l_period_number := l_period_number - 1;
    END IF;

    FOR l_posp_rec IN c_posp(p_sequence_number,
                             p_number_of_periods,
                             l_period_number)
    LOOP
      OPEN c_posu(l_posp_rec.sequence_number,l_usec_details_rec.unit_cd);
      FETCH c_posu INTO l_core_ind;
      IF c_posu%FOUND THEN
         RETURN l_core_ind;
      END IF;
      CLOSE c_posu;
    END LOOP;
    RETURN 'X';
  END get_core_indicator;

BEGIN

  -- If the value of profile 'IGS_EN_CORE_VAL' if not set or set to No then Return NULL
  IF NVL(fnd_profile.value('IGS_EN_CORE_VAL'),'N') = 'N' THEN

     RETURN NULL;
  END IF;

  --  Get the Program Attempt Details
  OPEN c_ps_att_dtls;
  FETCH c_ps_att_dtls INTO l_ps_att_dtls_rec;
  CLOSE c_ps_att_dtls;

  --  Get the academic calendar instance
  igs_en_gen_015.get_academic_cal
  (
     p_person_id,
     p_program_cd,
     l_acad_cal_type,
     l_acad_ci_sequence_number,
     l_message,
     SYSDATE
  );

  --  If Pre_Enrollment Year profile option is set to Yes
  IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN

     --  Get the current unit set attempt of type pre-enrollment
     OPEN c_last_unit_set;
     FETCH c_last_unit_set INTO l_last_unit_set_cd;
     CLOSE c_last_unit_set;

     --  For the unit set fetched above and all the unit set attempts mapped to the unit set
     FOR l_map_unit_set_rec IN c_map_unit_set(p_person_id, p_program_cd, l_last_unit_set_cd)
     LOOP
       --  Check whether the given unit is defined in pattern of study as either core or optional
       OPEN c_pos(l_map_unit_set_rec.unit_set_cd);
       FETCH c_pos INTO l_pos_rec;
       CLOSE c_pos;
       -- Call local function to get the core indicator
       l_core_ind := get_core_indicator(l_pos_rec.acad_perd_unit_set, l_pos_rec.sequence_number, l_pos_rec.number_of_periods, l_map_unit_set_rec.unit_set_cd);
       IF l_core_ind IN('Y','N') THEN
          EXIT;
       END IF;
     END LOOP;

     --  If the unit is defined then return appropriate value i.e. CORE or OPTIONAL
     --  If the unit is not defined then return ELECTIVE
     IF l_core_ind = 'Y' THEN
        RETURN 'CORE';
     ELSIF l_core_ind = 'N' THEN
        RETURN 'OPTIONAL';
     ELSIF l_core_ind = 'X' THEN
        RETURN 'ELECTIVE';
     ELSE
        RETURN NULL;
     END IF;

  --  If the Pre_Enrollment Year profile option is not set or set to No
  ELSE
     --  Get the current unit set attempt
     FOR l_susa_rec IN c_susa LOOP
         l_row_count := 1;
         l_unit_set_cd := l_susa_rec.unit_set_cd;
         IF c_susa%ROWCOUNT > 1 THEN
            l_row_count := 2;
            EXIT;
         END IF;
     END LOOP;
     IF l_row_count > 1 THEN
        FOR l_pos_unit_sets_rec IN c_pos_unit_sets(l_ps_att_dtls_rec.version_number) LOOP
            l_pos_count := 1;
            l_unit_set_cd := l_pos_unit_sets_rec.unit_set_cd;
            IF c_pos_unit_sets%ROWCOUNT > 1 THEN
               l_pos_count := 2;
               EXIT;
            END IF;
        END LOOP;
        IF l_pos_count <> 1 THEN
           l_unit_set_cd := NULL;
        END IF;
     ELSIF l_row_count = 0 THEN
           l_unit_set_cd := NULL;
     END IF;

     --  For this unit set check whether the given unit is defined in pattern of study as either core or optional
     OPEN c_pos(l_unit_set_cd);
     FETCH c_pos INTO l_pos_rec;
     CLOSE c_pos;

     -- Call local function to get the core indicator
     l_core_ind := get_core_indicator(l_pos_rec.acad_perd_unit_set, l_pos_rec.sequence_number, l_pos_rec.number_of_periods, l_unit_set_cd);

     --  If the unit is defined then return appropriate value i.e. CORE or OPTIONAL
     --  If the unit is not defined then return ELECTIVE
     IF l_core_ind = 'Y' THEN
        RETURN 'CORE';
     ELSIF l_core_ind = 'N' THEN
        RETURN 'OPTIONAL';
     ELSIF l_core_ind = 'X' THEN
        RETURN 'ELECTIVE';
     ELSE
        RETURN NULL;
     END IF;

  END IF;

END enrp_check_usec_core;



FUNCTION enrp_chk_dest_usec_core(
  p_person_id IN NUMBER ,
  p_src_program_cd IN VARCHAR2 ,
  p_dest_program_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_coo_id IN NUMBER
  )

  ------------------------------------------------------------------
  --Created by  : Parul Tandon, Oracle IDC
  --Date created: 07-OCT-2003
  --
  --Purpose: This Function checks whether the given unit section is
  --a core unit or not in the current pattern of study for the given
  --student program attempt.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ckasu     29-SEP-2005   Modfied this procedure inorder to include cooid
  --                        inorder to show unit as Core when POS is setup in destination for
  --                        for unit as core a part of bug #4278867
  -------------------------------------------------------------------

RETURN VARCHAR2
IS

  CURSOR chk_dest_core_ind (cp_person_id IGS_EN_SU_ATTEMPT.PERSON_ID%TYPE,
                            cp_course_cd IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE,
                            cp_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
  SELECT core_indicator_code
  FROM IGS_EN_SU_ATTEMPT
  WHERE person_id = cp_person_id
  AND course_cd = cp_course_cd
  AND uoo_id = cp_uoo_id;

  -- modified this cursor as a part of bug #4278867
  CURSOR c_ps_att_dtls
  IS
  SELECT location_cd,
         attendance_mode,
         attendance_type,
         version_number
  FROM   IGS_PS_OFR_OPT
  WHERE  coo_id = p_coo_id;


  l_ps_att_dtls_rec             c_ps_att_dtls%ROWTYPE;
  l_acad_cal_type               igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;

  CURSOR c_pos ( cp_unit_set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE ) IS
  SELECT  pos.cal_type,
    pos.sequence_number,
    pos.always_pre_enrol_ind,
    pos.number_of_periods,
    pos.aprvd_ci_sequence_number ,
    pos.acad_perd_unit_set
  FROM    IGS_PS_PAT_OF_STUDY pos
  WHERE   pos.course_cd       = p_dest_program_cd AND
    pos.version_number  = l_ps_att_dtls_rec.version_number AND
    pos.cal_type        = l_acad_cal_type AND
    ((pos.location_cd   IS NULL AND
    pos.attendance_mode     IS NULL AND
    pos.attendance_type     IS NULL AND
    pos.unit_set_cd     IS NULL AND
    pos.admission_cal_type  IS NULL AND
    pos.admission_cat   IS NULL) OR
    IGS_EN_GEN_005.enrp_get_pos_links(
            l_ps_att_dtls_rec.location_cd,
            l_ps_att_dtls_rec.attendance_mode,
            l_ps_att_dtls_rec.attendance_type,
            cp_unit_set_cd,
            NULL,
            NULL,
            pos.location_cd,
            pos.attendance_mode,
            pos.attendance_type,
            pos.unit_set_cd,
            pos.admission_cal_type,
            pos.admission_cat) > 0)
  ORDER BY IGS_EN_GEN_005.enrp_get_pos_links(
            l_ps_att_dtls_rec.location_cd,
            l_ps_att_dtls_rec.attendance_mode,
            l_ps_att_dtls_rec.attendance_type,
            cp_unit_set_cd,
            NULL,
            NULL,
            pos.location_cd,
            pos.attendance_mode,
            pos.attendance_type,
            pos.unit_set_cd,
            pos.admission_cal_type,
            pos.admission_cat) DESC;
  l_pos_rec       c_pos%ROWTYPE;


  CURSOR c_last_unit_set IS
  SELECT susa.unit_set_cd
  FROM  igs_as_su_setatmpt susa ,
        igs_en_unit_set us ,
        igs_en_unit_set_cat usc
  WHERE susa.person_id = p_person_id AND
        susa.course_cd = p_src_program_cd  AND
        susa.rqrmnts_complete_dt IS NULL   AND
        susa.student_confirmed_ind = 'Y' AND
        susa.end_dt     IS NULL AND
        susa.unit_set_cd = us.unit_set_cd AND
        us.unit_set_cat = usc.unit_set_cat AND
        usc.s_unit_set_cat  = 'PRENRL_YR';
  l_last_unit_set_cd    igs_as_su_setatmpt.unit_set_cd%TYPE;

  CURSOR c_map_unit_set( cp_person_id igs_as_su_setatmpt.person_id%TYPE,
                         cp_course_cd igs_as_su_setatmpt.course_cd%TYPE,
                         cp_unit_set_cd igs_as_su_setatmpt.unit_set_cd%TYPE) IS
  SELECT unit_set_cd
  FROM igs_as_su_setatmpt
  WHERE (
           (unit_set_cd = cp_unit_set_cd) OR
           (unit_set_cd IN (SELECT stream_unit_set_cd
                         FROM igs_en_unit_set_map
                         WHERE (mapping_set_cd,sequence_no) IN (SELECT mapping_set_cd,sequence_no
                                                                FROM igs_ps_us_prenr_cfg
                                                                WHERE unit_set_cd = cp_unit_set_cd)))
        )
  AND person_id = cp_person_id
  AND course_cd = cp_course_cd;

  CURSOR c_susa IS
  SELECT  susa.unit_set_cd
  FROM  igs_as_su_setatmpt susa
  WHERE susa.person_id    = p_person_id AND
    susa.course_cd    = p_src_program_cd AND
    susa.student_confirmed_ind = 'Y' AND
    susa.rqrmnts_complete_dt IS NULL   AND
    susa.end_dt     IS NULL;

  CURSOR c_pos_unit_sets( cp_version_number igs_ps_pat_of_study.version_number%TYPE)  IS
  SELECT unit_set_cd
  FROM igs_ps_pat_of_study pos
  WHERE  course_cd = p_dest_program_cd AND
         version_number = cp_version_number  AND
         cal_type = l_acad_cal_type AND
         unit_set_cd  IN
         ( SELECT susa.unit_set_cd
           FROM  igs_as_su_setatmpt susa
           WHERE susa.person_id    = p_person_id AND
            susa.course_cd    = p_src_program_cd AND
            susa.student_confirmed_ind = 'Y' AND
            susa.end_dt     IS NULL);

  l_core_ind                    igs_ps_pat_study_unt.core_ind%TYPE;
  l_dest_core_ind               IGS_EN_SU_ATTEMPT.CORE_INDICATOR_CODE%TYPE;
  l_message                     VARCHAR2(100);
  l_unit_set_cd                 igs_as_su_setatmpt.unit_set_cd%TYPE;
  l_row_count                   NUMBER;
  l_pos_count                   NUMBER;

  FUNCTION get_trn_core_indicator (p_acad_perd_unit_set     igs_ps_pat_of_study.acad_perd_unit_set%TYPE,
                               p_sequence_number        igs_ps_pat_of_study.sequence_number%TYPE,
                               p_number_of_periods      igs_ps_pat_of_study.number_of_periods%TYPE,
                               p_unit_set_cd            igs_as_su_setatmpt.unit_set_cd%TYPE)
  RETURN VARCHAR2
  IS
    CURSOR c_usec_details IS
    SELECT  unit_cd,
            cal_type
    FROM    igs_ps_unit_ofr_opt
    WHERE   uoo_id = p_uoo_id;
    l_usec_details_rec   c_usec_details%ROWTYPE;

    CURSOR c_aci IS
    SELECT  aci.cal_type,
            aci.sequence_number,
            aci.start_dt,
            aci.end_dt
    FROM    igs_ca_inst     aci
    WHERE   aci.cal_type        = l_acad_cal_type AND
            aci.sequence_number     = l_acad_ci_sequence_number;
    l_aci_rec       c_aci%ROWTYPE;

    CURSOR c_acad_us (cp_admin_unit_Set_cd igs_as_su_setatmpt.unit_set_cd%TYPE) IS
      SELECT usm.stream_unit_set_Cd
      FROM   igs_en_unit_set_map usm,
             igs_ps_us_prenr_cfg upc
      WHERE  upc.unit_set_cd = cp_admin_unit_set_cd
      AND    usm.mapping_set_cd = upc.mapping_set_cd
      AND    usm.sequence_no = upc.sequence_no;


    CURSOR c_num_acad_perd  IS
      SELECT  DISTINCT acad_perd
      FROM   igs_en_susa_year_v
      WHERE  person_id = p_person_id
      AND   course_cd = p_src_program_cd
      AND   unit_set_cd = p_unit_set_cd ;

    CURSOR c_posp (
        cp_sequence_number  igs_ps_pat_of_study.sequence_number%TYPE,
        cp_number_of_periods    igs_ps_pat_of_study.number_of_periods%TYPE,
        cp_period_number    NUMBER) IS
        SELECT  posp.acad_period_num,
            posp.teach_cal_type,
            posp.sequence_number
        FROM    igs_ps_pat_study_prd posp
        WHERE   posp.pos_sequence_number    = cp_sequence_number AND
            posp.acad_period_num        >= cp_period_number AND
            posp.acad_period_num        < (cp_period_number
                            + cp_number_of_periods) AND
            EXISTS  (SELECT 'x'
                FROM    igs_ps_pat_study_unt posu
                WHERE   posp.sequence_number    = posu.posp_sequence_number AND
                    posu.unit_cd        IS NOT NULL)
        ORDER BY posp.acad_period_num;

    CURSOR c_posu (
        cp_sequence_number  igs_ps_pat_study_prd.sequence_number%TYPE,
        cp_unit_cd          igs_ps_unit_ver.unit_cd%TYPE) IS
        SELECT  core_ind
        FROM    IGS_PS_PAT_STUDY_UNT posu
        WHERE   posu.posp_sequence_number = cp_sequence_number
        AND     posu.unit_cd = cp_unit_cd;

    l_dummy           VARCHAR2(1);
    l_rec_exist       BOOLEAN;
    l_period_number   NUMBER;
    l_core_ind        igs_ps_pat_study_unt.core_ind%TYPE;

  BEGIN
    -- Get the unit section details

    OPEN c_usec_details;
    FETCH c_usec_details INTO l_usec_details_rec;
    CLOSE c_usec_details;

    -- Get the start/end dates from the academic period
    -- required by routine calls lower in the routine.

    OPEN c_aci;
    FETCH c_aci INTO l_aci_rec;
    CLOSE c_aci;

    OPEN c_pos (p_unit_set_cd);
    IF c_pos%FOUND THEN
       l_rec_exist := TRUE;
    END IF;
    CLOSE c_pos;

    -- Determine the number of academic periods in which the
    -- student has been enrolled

    -- If year of program mode is enabled
    IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN

       -- If 'Academic Period within Unit Sets' is checked for the pattern of study,
       -- Get number of periods from igs_en_susa_year_v else use original function
       -- igs_en_gen_004.enrp_get_perd_num.
       IF NVL(p_acad_perd_unit_set,'N') = 'Y' AND p_unit_set_cd IS NOT NULL THEN
          OPEN c_num_acad_perd;
          FETCH c_num_acad_perd INTO l_period_number;
          CLOSE c_num_acad_perd;

          l_period_number := l_period_number + 1;
       ELSE
          l_period_number := igs_en_gen_004.enrp_get_perd_num(
                                            p_person_id,
                                            p_src_program_cd,
                                            l_acad_cal_type,
                                            l_acad_ci_sequence_number,
                                            l_aci_rec.start_dt);
       END IF;
    ELSE
          l_period_number := igs_en_gen_004.enrp_get_perd_num(
                                            p_person_id,
                                            p_src_program_cd,
                                            l_acad_cal_type,
                                            l_acad_ci_sequence_number,
                                            l_aci_rec.start_dt);
    END IF;

    -- As the function igs_en_gen_004.enrp_get_perd_num returns incremented period number, so
    -- decrement by 1 to get the current period
        IF l_period_number > 1 THEN
    l_period_number := l_period_number - 1;
    END IF;

    FOR l_posp_rec IN c_posp(p_sequence_number,
                             p_number_of_periods,
                             l_period_number)
    LOOP
      OPEN c_posu(l_posp_rec.sequence_number,l_usec_details_rec.unit_cd);
      FETCH c_posu INTO l_core_ind;
      IF c_posu%FOUND THEN
         RETURN l_core_ind;
      END IF;
      CLOSE c_posu;
    END LOOP;
    RETURN 'X';
  END get_trn_core_indicator;

BEGIN

  -- If the value of profile 'IGS_EN_CORE_VAL' if not set or set to No then Return NULL
  IF NVL(fnd_profile.value('IGS_EN_CORE_VAL'),'N') = 'N' THEN

     RETURN NULL;
  END IF;

  -- if the destination unit attempt exists, then fetch the core indicator value
  -- from that record. This is mainly to show the correctly value when the
  -- program transfer completion messages is shown. In case unit attempt record
  -- already existts before the transfer is submitted then in the record
  -- will not be transferred as it already exists in the destination.
  OPEN chk_dest_core_ind(p_person_id, p_dest_program_cd, p_uoo_id);
  FETCH chk_dest_core_ind INTO l_dest_core_ind ;
  IF chk_dest_core_ind%FOUND THEN
    CLOSE chk_dest_core_ind;
    RETURN l_dest_core_ind;
  ELSE
    CLOSE chk_dest_core_ind;
  END IF;

  --  Get the Program Attempt Details
  OPEN c_ps_att_dtls;
  FETCH c_ps_att_dtls INTO l_ps_att_dtls_rec;
  CLOSE c_ps_att_dtls;

  --  Get the academic calendar instance
  igs_en_gen_015.get_academic_cal
  (
     p_person_id,
     p_src_program_cd,
     l_acad_cal_type,
     l_acad_ci_sequence_number,
     l_message,
     SYSDATE
  );

  --  If Pre_Enrollment Year profile option is set to Yes
  IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN

     --  Get the current unit set attempt of type pre-enrollment
	 IF p_unit_set_cd IS NULL THEN
       OPEN c_last_unit_set;
       FETCH c_last_unit_set INTO l_last_unit_set_cd;
       CLOSE c_last_unit_set;
     --  For the unit set fetched above and all the unit set attempts mapped to the unit set
	     FOR l_map_unit_set_rec IN c_map_unit_set(p_person_id, p_src_program_cd, l_last_unit_set_cd)
	     LOOP
	       --  Check whether the given unit is defined in pattern of study as either core or optional
	       OPEN c_pos(l_map_unit_set_rec.unit_set_cd);
	       FETCH c_pos INTO l_pos_rec;
	       CLOSE c_pos;
	       -- Call local function to get the core indicator
	       l_core_ind := get_trn_core_indicator(l_pos_rec.acad_perd_unit_set, l_pos_rec.sequence_number, l_pos_rec.number_of_periods, l_map_unit_set_rec.unit_set_cd);
	       IF l_core_ind IN('Y','N') THEN
	          EXIT;
	       END IF;
	     END LOOP;
	  ELSE
        OPEN c_pos(p_unit_set_cd);
	    FETCH c_pos INTO l_pos_rec;
	    CLOSE c_pos;

	    l_core_ind := get_trn_core_indicator(l_pos_rec.acad_perd_unit_set, l_pos_rec.sequence_number, l_pos_rec.number_of_periods, p_unit_set_cd);
	  END IF;

     --  If the unit is defined then return appropriate value i.e. CORE or OPTIONAL
     --  If the unit is not defined then return ELECTIVE
     IF l_core_ind = 'Y' THEN
        RETURN 'CORE';
     ELSIF l_core_ind = 'N' THEN
        RETURN 'OPTIONAL';
     ELSIF l_core_ind = 'X' THEN
        RETURN 'ELECTIVE';
     ELSE
        RETURN NULL;
     END IF;

  --  If the Pre_Enrollment Year profile option is not set or set to No
  ELSE
     --  Get the current unit set attempt
	 IF p_unit_set_cd IS NULL THEN
	     FOR l_susa_rec IN c_susa LOOP
	         l_row_count := 1;
	         l_unit_set_cd := l_susa_rec.unit_set_cd;
	         IF c_susa%ROWCOUNT > 1 THEN
	            l_row_count := 2;
	            EXIT;
	         END IF;
	     END LOOP;
	     IF l_row_count > 1 THEN
	        FOR l_pos_unit_sets_rec IN c_pos_unit_sets(l_ps_att_dtls_rec.version_number) LOOP
	            l_pos_count := 1;
	            l_unit_set_cd := l_pos_unit_sets_rec.unit_set_cd;
	            IF c_pos_unit_sets%ROWCOUNT > 1 THEN
	               l_pos_count := 2;
	               EXIT;
	            END IF;
	        END LOOP;
	        IF l_pos_count <> 1 THEN
	           l_unit_set_cd := NULL;
	        END IF;
	     ELSIF l_row_count = 0 THEN
	           l_unit_set_cd := NULL;
	     END IF;
	  ELSE
        l_unit_set_cd := p_unit_set_cd;
	  END IF;

     --  For this unit set check whether the given unit is defined in pattern of study as either core or optional
     OPEN c_pos(l_unit_set_cd);
     FETCH c_pos INTO l_pos_rec;
     CLOSE c_pos;
     -- Call local function to get the core indicator
     l_core_ind := get_trn_core_indicator(l_pos_rec.acad_perd_unit_set, l_pos_rec.sequence_number, l_pos_rec.number_of_periods, l_unit_set_cd);

     --  If the unit is defined then return appropriate value i.e. CORE or OPTIONAL
     --  If the unit is not defined then return ELECTIVE
     IF l_core_ind = 'Y' THEN
        RETURN 'CORE';
     ELSIF l_core_ind = 'N' THEN
        RETURN 'OPTIONAL';
     ELSIF l_core_ind = 'X' THEN
        RETURN 'ELECTIVE';
     ELSE
        RETURN NULL;
     END IF;

  END IF;

END enrp_chk_dest_usec_core;

END Igs_En_Gen_009;

/
