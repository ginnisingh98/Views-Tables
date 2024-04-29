--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_005" AS
/* $Header: IGSEN05B.pls 120.1 2006/01/18 22:52:59 ctyagi noship $ */

/* Change History
 who       when         what
 smvk   09-Jul-2004   Bug # 3676145. Modified the cursors c_uoo2 to select active (not closed) unit classes.
 */

FUNCTION enrp_get_fee_student(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 )
RETURN NUMBER AS
BEGIN
DECLARE
        cst_fee_paying_not              CONSTANT NUMBER := 1;
        cst_fee_paying_os               CONSTANT NUMBER := 2;
        cst_fee_paying_pg_course        CONSTANT NUMBER := 3;
        cst_fee_paying_non_os_ug        CONSTANT NUMBER := 4;
        cst_hecs_fee_paying_pg          CONSTANT VARCHAR2(2) := '20';
        cst_hecs_fee_paying_os          CONSTANT VARCHAR2(2) := '22';
        cst_hecs_os_student_charge      CONSTANT VARCHAR2(2) := '23';
        cst_hecs_fee_paying_os_spnsr    CONSTANT VARCHAR2(2) := '24';
        v_other_detail                  VARCHAR2(255);
        v_govt_hecs_payment_option      IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
        v_govt_course_type              IGS_PS_GOVT_TYPE.govt_course_type%TYPE;
        v_output                        NUMBER;

        CURSOR c_ghpo IS
                SELECT  govt_hecs_payment_option
                FROM    IGS_FI_HECS_PAY_OPTN
                WHERE   IGS_FI_HECS_PAY_OPTN.hecs_payment_option = p_hecs_payment_option;

        CURSOR c_get_govt_crs_type IS
                SELECT  govt_course_type
                FROM    IGS_EN_STDNT_PS_ATT,
                        IGS_PS_VER,
                        IGS_PS_TYPE
                WHERE   IGS_EN_STDNT_PS_ATT.person_id = p_person_id AND
                        IGS_EN_STDNT_PS_ATT.course_cd = p_course_cd AND
                        IGS_PS_VER.course_cd = IGS_EN_STDNT_PS_ATT.course_cd AND
                        IGS_PS_VER.version_number = IGS_EN_STDNT_PS_ATT.version_number AND
                        IGS_PS_TYPE.course_type = IGS_PS_VER.course_type;
BEGIN
        -- This module returns the govt. value (either 1/2/3/4) for FEE-STUDENT.
        -- DEETYA element 349.
        -- retrieving the govt. value for p_hecs_payment_option
        OPEN  c_ghpo;
        FETCH c_ghpo INTO v_govt_hecs_payment_option;
        CLOSE c_ghpo;
        -- determine value for FEE-STUDENT
        -- returning 2 (cst_fee_paying_os)
        IF (NVL(v_govt_hecs_payment_option, 'NULL') = cst_hecs_fee_paying_os)       OR
           (NVL(v_govt_hecs_payment_option, 'NULL') = cst_hecs_os_student_charge)   OR
           (NVL(v_govt_hecs_payment_option, 'NULL') =
                                        cst_hecs_fee_paying_os_spnsr) THEN
                v_output := cst_fee_paying_os;
                return v_output;
        ELSIF (NVL(v_govt_hecs_payment_option, 'NULL') = cst_hecs_fee_paying_pg) THEN
                OPEN c_get_govt_crs_type;
                FETCH c_get_govt_crs_type INTO v_govt_course_type;
                CLOSE c_get_govt_crs_type;
                -- returning 4 (cst_fee_paying_non_os_ug)
                IF (v_govt_course_type IS NOT NULL AND
                     v_govt_course_type BETWEEN 8 AND 10 OR
                     v_govt_course_type BETWEEN 20 AND 22) THEN
                        v_output := cst_fee_paying_non_os_ug;
                        return v_output;
                ELSE
                        -- returning 3 (cst_fee_paying_pg_course)
                        v_output := cst_fee_paying_pg_course;
                        return v_output;
                END IF;
        ELSE  -- returning 1 (cst_fee_paying_not)
                v_output := cst_fee_paying_not;
                return v_output;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_005.enrp_get_fee_student');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_get_fee_student;


FUNCTION Enrp_Get_Pos_Elgbl(
  p_acad_cal_type               IN VARCHAR2 ,
  p_acad_sequence_number        IN NUMBER ,
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_version_number              IN NUMBER ,
  p_pos_sequence_number         IN NUMBER ,
  p_always_pre_enrol_ind        IN VARCHAR2 ,
  p_acad_period_num             IN NUMBER ,
  p_log_creation_dt             IN DATE ,
  p_warn_level                  OUT NOCOPY VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --ayedubat    16-MAY-2002     Changed the cursor,c_sua_cir to remove validation comparing the future academic periods
  --                            as part of the bug;2377045
  --kkillams    24-04-2003      Modified the c_sua cursor w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
/* HISTORY
   WHO        WHEN          WHAT

*/
BEGIN   -- enrp_get_pos_elgbl
        -- Check whether a student IGS_PS_COURSE attempt is eligible to be pre-enrolled
        -- using the pattern of study structure in a nominated academic period
        -- A student is deemed to be ineligible to be pre-enrolled via a pattern
        -- of study if:-
        -- * They already have IGS_PS_UNIT attempts in the target academic period(s)
        -- * They have been granted/approved IGS_PS_UNIT level advanced standing
        -- * They haven't got any IGS_PS_UNIT requirements (applied via encumbrances)
        --   which wouldn't be satisfied by the units in the pattern of study.
        -- * They have not passed (or are currently enrolled in) units which
        --   should have already been completed in accordance with the pattern
        --   of study. These units must be taken in the prescribed teaching
        --   calendars.
DECLARE
        cst_true        CONSTANT                VARCHAR2(5) := 'TRUE';
        cst_false       CONSTANT                VARCHAR2(5) := 'FALSE';
        cst_minor       CONSTANT                VARCHAR2(5) := 'MINOR';
        cst_pass        CONSTANT                VARCHAR2(5) := 'PASS';
        cst_incomp      CONSTANT                VARCHAR2(6) := 'INCOMP';
        cst_pre_enrol   CONSTANT                VARCHAR2(10) := 'PRE-ENROL';
        cst_granted     CONSTANT                VARCHAR2(10) := 'GRANTED';
        cst_approved    CONSTANT                VARCHAR2(10) := 'APPROVED';
        cst_enrolled    CONSTANT                VARCHAR2(10) := 'ENROLLED';
        cst_completed   CONSTANT                VARCHAR2(10) := 'COMPLETED';
        cst_active      CONSTANT                VARCHAR2(10) := 'ACTIVE';
        v_dummy                                 VARCHAR2(1);
        v_alt_code                              IGS_CA_INST.alternate_code%TYPE;
        v_acad_cal_type                         IGS_CA_INST.cal_type%TYPE;
        v_acad_sequence_number                  IGS_CA_INST.sequence_number%TYPE;
        v_acad_start_dt                         IGS_CA_INST.start_dt%TYPE;
        v_acad_end_dt                           IGS_CA_INST.end_dt%TYPE;
        v_return_flag                           BOOLEAN;
        v_message_name                          VARCHAR2(30);

        CURSOR c_sua_cir IS
                SELECT  sua.cal_type,
                        sua.ci_sequence_number,
                        ci.cal_type parent_cal_type,
                        ci.sequence_number parent_sequence_number
                FROM    IGS_CA_INST aci,
                        IGS_EN_SU_ATTEMPT sua,
                        IGS_CA_INST_REL cir,
                        IGS_CA_INST ci
                WHERE
                        aci.cal_type                    = p_acad_cal_type AND
                        aci.sequence_number             = p_acad_sequence_number AND
                        sua.person_id                   = p_person_id AND
                        sua.course_cd                   = p_course_cd AND
                        cir.sub_cal_type                = sua.cal_type AND
                        cir.sub_ci_sequence_number      = sua.ci_sequence_number AND
                        ci.cal_type                     = cir.sup_cal_type AND
                        ci.sequence_number              = cir.sup_ci_sequence_number AND
                        (cir.sup_cal_type               = p_acad_cal_type AND
                         cir.sup_ci_sequence_number     = p_acad_sequence_number);

        CURSOR c_asul IS
                SELECT  'X'
                FROM    IGS_AV_STND_UNIT_LVL            asul
                WHERE   asul.person_id                  = p_person_id AND
                        asul.as_course_cd               = p_course_cd AND
                        asul.s_adv_stnd_granting_status IN (cst_granted,
                                                        cst_approved);
        CURSOR c_pur_pee IS
                SELECT  'X'
                FROM    IGS_PE_UNT_REQUIRMNT    pur,
                        IGS_PE_PERSENC_EFFCT    pee
                WHERE   pur.person_id                   = p_person_id AND
                        pur.pur_start_dt                <= SYSDATE AND
                        NVL(pur.expiry_dt, igs_ge_date.igsdate('9999/01/01')) > SYSDATE AND
                        pee.person_id                   = pur.person_id AND
                        pee.encumbrance_type            = pur.encumbrance_type AND
                        pee.pen_start_dt                = pur.pen_start_dt AND
                        pee.s_encmb_effect_type         = pur.s_encmb_effect_type AND
                        pee.pee_start_dt                = pur.pee_start_dt AND
                        pee.sequence_number             = pur.pee_sequence_number AND
                        (pee.course_cd                  IS NULL OR
                        pee.course_cd                   = p_course_cd) AND
                        NOT EXISTS (
                                SELECT  'X'
                                FROM    IGS_PS_PAT_STUDY_UNT            posu,
                                        IGS_PS_PAT_STUDY_PRD            posp
                                WHERE   posu.course_cd                  = p_course_cd AND
                                        posu.version_number             = p_version_number AND
                                        posu.cal_type                   = p_acad_cal_type AND
                                        posu.pos_sequence_number        = p_pos_sequence_number AND
                                        NVL(posu.unit_cd, NULL)         = pur.unit_cd AND
                                        posp.course_cd                  = posu.course_cd AND
                                        posp.version_number             = posu.version_number AND
                                        posp.cal_type                   = posu.cal_type AND
                                        posp.pos_sequence_number        = posu.pos_sequence_number AND
                                        posp.sequence_number            = posu.posp_sequence_number AND
                                        posp.acad_period_num            = p_acad_period_num);
        CURSOR c_posu_posp IS
                SELECT  posu.unit_cd,
                        posp.teach_cal_type
                FROM    IGS_PS_PAT_STUDY_UNT            posu,
                        IGS_PS_PAT_STUDY_PRD            posp
                WHERE   posu.course_cd                  = p_course_cd AND
                        posu.version_number             = p_version_number AND
                        posu.cal_type                   = p_acad_cal_type AND
                        posu.pos_sequence_number        = p_pos_sequence_number AND
                        posu.unit_cd                    IS NOT NULL AND
                        posp.course_cd                  = posu.course_cd AND
                        posp.version_number             = posu.version_number AND
                        posp.cal_type                   = posu.cal_type AND
                        posp.pos_sequence_number        = posu.pos_sequence_number AND
                        posp.sequence_number            = posu.posp_sequence_number AND
                        posp.acad_period_num            < p_acad_period_num;
        CURSOR c_sua    (cp_posu_unit_cd                IGS_PS_PAT_STUDY_UNT.unit_cd%TYPE,
                         cp_posp_teach_cal_type         IGS_PS_PAT_STUDY_PRD.teach_cal_type%TYPE) IS
                SELECT  'X'
                FROM    IGS_EN_SU_ATTEMPT               sua
                WHERE   sua.person_id                   = p_person_id AND
                        sua.course_cd                   = p_course_cd AND
                        sua.unit_cd                     = cp_posu_unit_cd AND
                        sua.cal_type                    = cp_posp_teach_cal_type AND
                        (sua.unit_attempt_status        = cst_enrolled OR
                         (sua.unit_attempt_status               = cst_completed AND
                          EXISTS (
                                SELECT  'X'
                                FROM     IGS_AS_SUAO_V  suaov,
                                        IGS_AS_GRD_SCH_GRADE            gsg
                                WHERE   suaov.person_id                 = sua.person_id AND
                                        suaov.course_cd                 = sua.course_cd AND
                                        suaov.uoo_id                    = sua.uoo_id AND
                                        gsg.grading_schema_cd           = suaov.grading_schema_cd AND
                                        gsg.version_number              = suaov.version_number AND
                                        gsg.grade                       = suaov.grade AND
                                        gsg.s_result_type               IN (cst_pass,cst_incomp))));
        CURSOR  c_posp IS
        SELECT  teach_cal_type
        FROM    IGS_PS_PAT_STUDY_PRD posp
        WHERE   posp.course_cd = p_course_cd AND
                        posp.version_number = p_version_number AND
                        posp.cal_type = p_acad_cal_type AND
                        posp.pos_sequence_number = p_pos_sequence_number AND
                        posp.acad_period_num = p_acad_period_num;
        CURSOR  c_cir_tci       (cp_teach_cal_type      IGS_PS_PAT_STUDY_PRD.teach_cal_type%TYPE)
        IS
        SELECT  tci.cal_type,
                tci.sequence_number
        FROM    IGS_CA_INST_REL cir,
                        IGS_CA_INST tci,
                        IGS_CA_TYPE cat,
                        IGS_CA_STAT cs
        WHERE   cir.sup_cal_type = p_acad_cal_type AND
                        cir.sup_ci_sequence_number = p_acad_sequence_number AND
                        cir.sub_cal_type = cp_teach_cal_type AND
                        tci.cal_type = cir.sub_cal_type AND
                        tci.sequence_number = cir.sub_ci_sequence_number AND
                        cat.cal_type = tci.cal_type AND
                        cat.s_cal_cat = 'TEACHING' AND
                        cs.cal_status = tci.cal_status AND
                        cs.s_cal_status = cst_active
        ORDER BY        tci.start_dt DESC;
        v_teach_cal_type                IGS_CA_INST.cal_type%TYPE;
        v_teach_sequence_number IGS_CA_INST.sequence_number%TYPE;
BEGIN
        p_message_name := NULL;
        v_return_flag := FALSE;
        -- Check whether student has already been pre_enrolled into IGS_PS_UNIT attempts
        -- within the academic year.
        FOR v_sua_rec IN c_sua_cir LOOP
                -- Check that the IGS_PS_UNIT attempt was actually started within the
                -- academic year
                v_alt_code := IGS_EN_GEN_002.ENRP_GET_ACAD_ALT_CD(v_sua_rec.cal_type,
                                                v_sua_rec.ci_sequence_number,
                                                v_acad_cal_type,
                                                v_acad_sequence_number,
                                                v_acad_start_dt,
                                                v_acad_end_dt,
                                                v_message_name);
                IF      v_acad_cal_type         IS NOT NULL AND
                        v_acad_cal_type         = v_sua_rec.parent_cal_type AND
                        v_acad_sequence_number  = v_sua_rec.parent_sequence_number THEN
                        IF p_log_creation_dt IS NOT NULL THEN
                                -- If all warnings are logged then write the exception
                                IGS_GE_GEN_003.genp_ins_log_entry(cst_pre_enrol,
                                                p_log_creation_dt,
                                                cst_minor || ','
                                                || p_person_id ||','
                                                || p_course_cd,
                                                'IGS_EN_STUD_INELG_PREENR',
                                                NULL);
                        END IF;
                        v_return_flag := TRUE;
                        EXIT;
                END IF;
        END LOOP;
        IF v_return_flag = TRUE THEN
                p_warn_level := cst_minor;
                p_message_name := 'IGS_EN_STUD_INELG_PREENR';
                RETURN cst_false;
        END IF;
        -- Check for 'IGS_PS_UNIT level' advanced standing which is approved or granted.
        -- Existence of this level of advanced standing will prevent the
        -- pre-enrollment of the pattern of study occurring.
        OPEN c_asul;
        FETCH c_asul INTO v_dummy;
        IF (c_asul%FOUND) THEN
                IF p_log_creation_dt IS NOT NULL THEN
                        CLOSE c_asul;
                        -- If all warnings are logged then write the exception
                        IGS_GE_GEN_003.genp_ins_log_entry(cst_pre_enrol,
                                        p_log_creation_dt,
                                        cst_minor || ','
                                        || p_person_id ||','
                                        || p_course_cd,
                                        'IGS_EN_STUD_INELG_UNIT_LVL',
                                        NULL);
                END IF;
                p_warn_level := cst_minor;
                p_message_name := 'IGS_EN_STUD_INELG_UNIT_LVL';
                RETURN cst_false;
        END IF;
        CLOSE c_asul;
        -- Check whether student as a period (s) of intermission overlapping
        -- the target year(s) which would prevent the enrolment of units in
        -- the POS periods.
        FOR     v_posp_rec IN c_posp
        LOOP
                OPEN    c_cir_tci       (v_posp_rec.teach_cal_type);
                FETCH   c_cir_tci INTO v_teach_cal_type, v_teach_sequence_number;
                IF c_cir_tci%FOUND THEN
                        CLOSE   c_cir_tci;
                        -- If the student has an intermission overlapping the period
                        -- then they ineligible for POS pre-enrolment.
                        IF IGS_EN_VAL_SUA.enrp_val_sua_intrmt(
                                                        p_person_id,
                                                        p_course_cd,
                                                        v_teach_cal_type,
                                                        v_teach_sequence_number,
                                                        v_message_name) = FALSE THEN
                                IF p_log_creation_dt IS NOT NULL THEN
                                        IGS_GE_GEN_003.genp_ins_log_entry(cst_pre_enrol,
                                                        p_log_creation_dt,
                                                        cst_minor ||','
                                                        || p_person_id ||','
                                                        || p_course_cd,
                                                        'IGS_EN_STUD_INELG_POS_OVERLAP',
                                                        NULL);
                                END IF;
                                p_warn_level := cst_minor;
                                p_message_name := 'IGS_EN_STUD_INELG_POS_OVERLAP';
                                RETURN cst_false;
                        END IF;
                ELSE
                        CLOSE   c_cir_tci;
                END IF;
        END LOOP;
        -- If the student has the required units (applied through encumbrances) and
        -- one or more of the units are not within the set being pre-enrolled in
        -- the upcoming academic year.
        OPEN c_pur_pee;
        FETCH c_pur_pee INTO v_dummy;
        IF (c_pur_pee%FOUND) THEN
                IF p_log_creation_dt IS NOT NULL THEN
                        CLOSE c_pur_pee;
                        -- If all warnings are logged then write the exception
                        IGS_GE_GEN_003.genp_ins_log_entry(cst_pre_enrol,
                                        p_log_creation_dt,
                                        cst_minor ||','
                                        || p_person_id ||','
                                        || p_course_cd,
                                        'IGS_EN_STUD_INELG_ENCUMB',
                                        NULL);
                END IF;
                p_warn_level := cst_minor;
                p_message_name := 'IGS_EN_STUD_INELG_ENCUMB';
                RETURN cst_false;
        END IF;
        CLOSE c_pur_pee;
        -- Check that all of the units prior to the current year within the pattern
        -- of study have been completed (and passed) or are currently enrolled in
        -- the relevant teaching calendar types.
        IF p_always_pre_enrol_ind = 'N' THEN
                FOR v_posu_posp_rec IN c_posu_posp LOOP
                        -- Search for the IGS_PS_UNIT attempt within the academic year in the nominated
                        -- teaching calendar type. IGS_GE_NOTE: it is not checking whether it was studied
                        -- in the EXACT academic period number - this is not really necessary;
                        -- provided they've reached the current academic year having satisfied
                        -- the requirements of all units they are eligible.
                        OPEN c_sua(v_posu_posp_rec.unit_cd,
                                        v_posu_posp_rec.teach_cal_type);
                        FETCH c_sua INTO v_dummy;
                        IF (c_sua%NOTFOUND) THEN
                                IF p_log_creation_dt IS NOT NULL THEN
                                        CLOSE c_sua;
                                        -- If all warnings are logged then write the exception
                                        IGS_GE_GEN_003.genp_ins_log_entry(cst_pre_enrol,
                                                        p_log_creation_dt,
                                                        cst_minor || ','
                                                        || p_person_id ||','
                                                        || p_course_cd,
                                                        'IGS_EN_STUD_INELG_PROGRESSION',
                                                        v_posu_posp_rec.unit_cd);
                                END IF;
                                v_return_flag := TRUE;
                                EXIT;
                        END IF;
                        CLOSE c_sua;
                END LOOP;
                IF v_return_flag = TRUE THEN
                        p_warn_level := cst_minor;
                        p_message_name := 'IGS_EN_STUD_INELG_PROGRESSION';
                        RETURN cst_false;
                END IF;
        END IF;
        RETURN cst_true;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_sua_cir%ISOPEN) THEN
                        CLOSE c_sua_cir;
                END IF;
                IF (c_asul%ISOPEN) THEN
                        CLOSE c_asul;
                END IF;
                IF (c_pur_pee%ISOPEN) THEN
                        CLOSE c_pur_pee;
                END IF;
                IF (c_posu_posp%ISOPEN) THEN
                        CLOSE c_posu_posp;
                END IF;
                IF (c_sua%ISOPEN) THEN
                        CLOSE c_sua;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
                        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_005.enrp_get_pos_elgbl');
                        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_get_pos_elgbl;


FUNCTION Enrp_Get_Pre_Uoo(
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_crs_location_cd IN VARCHAR2 ,
  p_uoo_id OUT NOCOPY NUMBER )
RETURN BOOLEAN AS

BEGIN   -- enrp_get_pre_uoo
        -- Routine to select the IGS_PS_UNIT offering option matching the specified
        --   search criteria.
        -- If the IGS_PS_UNIT IGS_AD_LOCATION/class parameters are specified then only an
        --   exact match will be returned.
        -- If IGS_PS_UNIT IGS_AD_LOCATION and/or class are null then the routine will
        --   attempt to find a match, on the condition that:
        --   1. The IGS_AD_LOCATION code matches either the parameter or the enrolled IGS_PS_COURSE
        --      IGS_AD_LOCATION code.
        --   2. The option class matches the parameter, or if not set any mode will do
        --      (but a match with the IGS_PS_COURSE attendance mode will take priority)
DECLARE
        cst_active              CONSTANT VARCHAR2(10) := 'ACTIVE';
        CURSOR c_uoo IS
                SELECT  uoo_id
                FROM    IGS_PS_UNIT_OFR_OPT     uoo,
                        IGS_PS_UNIT_VER                 uv,
                        IGS_PS_UNIT_STAT                us
                WHERE   uoo.unit_cd             = p_unit_cd AND
                        uoo.cal_type            = p_cal_type AND
                        uoo.ci_sequence_number  = p_sequence_number AND
                        uoo.location_cd         = p_location_cd AND
                        uoo.unit_class          = p_unit_class AND
                        uoo.offered_ind         = 'Y' AND
                        uv.unit_cd              = uoo.unit_cd AND
                        uv.version_number       = uoo.version_number AND
                        uv.expiry_dt            IS NULL AND
                        us.unit_status          = uv.unit_status AND
                        us.s_unit_status        = 'ACTIVE';
        CURSOR c_uoo2 IS
                SELECT  uoo.uoo_id,
                        um.s_unit_mode
                FROM    IGS_PS_UNIT_OFR_OPT     uoo,
                        IGS_PS_UNIT_VER                 uv,
                        IGS_PS_UNIT_STAT                us,
                        IGS_AS_UNIT_CLASS               uc,
                        IGS_AS_UNIT_MODE                um
                WHERE   uoo.unit_cd             = p_unit_cd AND
                        uoo.cal_type            = p_cal_type AND
                        uoo.ci_sequence_number  = p_sequence_number AND
                        uoo.location_cd         = NVL(p_location_cd, p_crs_location_cd) AND
                        (p_unit_class           IS NULL OR
                        uoo.unit_class          = p_unit_class) AND
                        uoo.offered_ind         = 'Y' and
                        uoo.unit_cd             = uv.unit_cd AND
                        uoo.version_number      = uv.version_number AND
                        uv.expiry_dt            IS NULL and
                        us.unit_status          = uv.unit_status AND
                        us.s_unit_status        = 'ACTIVE' AND
                        uoo.unit_class          = uc.unit_class AND
			uc.closed_ind           = 'N' AND
                        uc.unit_mode            = um.unit_mode;
        v_uoo_rec               c_uoo%ROWTYPE;
        v_full_match_uoo_id     IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE DEFAULT NULL;
        v_partial_match_uoo_id  IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE DEFAULT NULL;
BEGIN
        p_uoo_id := NULL;
        -- If both the mode and class have been specified,
        -- then search for a uoo matching.
        -- If not found, then return NULL.
        IF p_location_cd IS NOT NULL AND
                        p_unit_class IS NOT NULL THEN
                OPEN c_uoo;
                FETCH c_uoo INTO v_uoo_rec;
                IF c_uoo%NOTFOUND THEN
                        CLOSE c_uoo;
                        RETURN FALSE;
                END IF;
                CLOSE c_uoo;
                p_uoo_id := v_uoo_rec.uoo_id;
                RETURN TRUE;
        END IF;
        -- Attempt to select the closest match from the IGS_PS_UNIT offering option table.
        FOR v_uoo_rec IN c_uoo2 LOOP
                -- If the class  is set or the mode matches the IGS_PS_COURSE mode,
                -- then it is considered an exact match.
                IF p_unit_class IS NOT NULL THEN
                        v_full_match_uoo_id := v_uoo_rec.uoo_id;
                        EXIT;
                ELSIF p_unit_mode = '%' OR
                                p_unit_mode = v_uoo_rec.s_unit_mode THEN
                        v_full_match_uoo_id := v_uoo_rec.uoo_id;
                        EXIT;
                ELSE
                        v_partial_match_uoo_id := v_uoo_rec.uoo_id;
                END IF;
        END LOOP;
        -- If set, use the full match UOO, otherwise use the partial
        -- match (ie. mode differs).
        IF v_full_match_uoo_id IS NOT NULL THEN
                p_uoo_id := v_full_match_uoo_id;
                RETURN TRUE;
        ELSIF v_partial_match_uoo_id IS NOT NULL THEN
                p_uoo_id := v_partial_match_uoo_id;
                RETURN TRUE;
        END IF;
        p_uoo_id := NULL;
        RETURN FALSE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_uoo%ISOPEN THEN
                        CLOSE c_uoo;
                END IF;
                IF c_uoo2%ISOPEN THEN
                        CLOSE c_uoo2;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_005.enrp_get_pre_uoo');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_get_pre_uoo;


FUNCTION Enrp_Get_Pos_Links(
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_pos_location_cd IN VARCHAR2 ,
  p_pos_attendance_mode IN VARCHAR2 ,
  p_pos_attendance_type IN VARCHAR2 ,
  p_pos_unit_set_cd IN VARCHAR2 ,
  p_pos_adm_cal_type IN VARCHAR2 ,
  p_pos_admission_cat IN VARCHAR2 )
RETURN NUMBER AS

BEGIN   -- enrp_get_pos_links
        -- Totals the number of elements of the IGS_PS_PAT_OF_STUDY linkages which
        -- match the parameter record. If the values in the linkages are NULL,
        -- then they don't count as a match. The ain is to find the record which
        -- has the most number of specific matches.
DECLARE
        v_match_count           NUMBER;
BEGIN
        v_match_count := 0;
        IF p_location_cd = NVL(p_pos_location_cd, 'NOMATCH') THEN
                v_match_count := v_match_count + 1;
        END IF;
        IF p_attendance_mode = NVL(p_pos_attendance_mode, 'NOMATCH') THEN
                v_match_count := v_match_count + 1;
        END IF;
        IF p_attendance_type = NVL(p_pos_attendance_type, 'NOMATCH') THEN
                v_match_count := v_match_count + 1;
        END IF;
        IF NVL(p_unit_set_cd, 'NOVALUE') = NVL(p_pos_unit_set_cd, 'NOMATCH') THEN
                v_match_count := v_match_count + 1;
        END IF;
        IF NVL(p_adm_cal_type, 'NOVALUE') = NVL(p_pos_adm_cal_type, 'NOMATCH') THEN
                v_match_count := v_match_count + 1;
        END IF;
        IF NVL(p_admission_cat, 'NOVALUE') = NVL(p_pos_admission_cat, 'NOMATCH') THEN
                v_match_count := v_match_count + 1;
        END IF;
        RETURN v_match_count;
END;

END enrp_get_pos_links;


FUNCTION Enrp_Get_First_Enr(
  p_person_id IN NUMBER )
RETURN VARCHAR2 AS
        gv_other_details                VARCHAR2(255);
BEGIN
DECLARE
-- modified cursor for performance bug 3687265
CURSOR c_get_acad_alt_cd IS
       SELECT SUBSTR(IGS_EN_GEN_014.enrs_get_acad_alt_cd(sua_v.cal_type,sua_v.ci_sequence_number),1,10)
       FROM  IGS_EN_SU_ATTEMPT sua_v,
             IGS_CA_INST ci
       WHERE sua_v.person_id = p_person_id  AND
             sua_v.enrolled_dt IS NOT NULL  AND
             sua_v.cal_type = ci.cal_type   AND
             sua_v.ci_sequence_number = ci.sequence_number
       ORDER BY   ci.start_dt,
                  ci.end_dt ;

        v_acad_alt_cd                   IGS_CA_INST.alternate_code%TYPE;
BEGIN
        --- Retrieve the student IGS_PS_UNIT attempt records for the IGS_PE_PERSON.
        --- The order the records are returned will ensure the oldest IGS_PS_UNIT
        --- attempt record for the IGS_PE_PERSON is returned first.
        OPEN c_get_acad_alt_cd;
        FETCH c_get_acad_alt_cd INTO v_acad_alt_cd;
        --- Many records may be returned, but we only want the first record.
        --- Return the result of the query, may be null if none were found.
        IF c_get_acad_alt_cd%NOTFOUND THEN
                CLOSE c_get_acad_alt_cd;
                RETURN NULL;
        ELSE
                CLOSE c_get_acad_alt_cd;
                RETURN v_acad_alt_cd;
        END IF;
END;

END enrp_get_first_enr;


FUNCTION Enrp_Get_Frst_Enr_Yr(
  p_person_id IN NUMBER )
RETURN DATE AS
BEGIN
        -- This is a stub only and needs to be updated when the spec is complete.
        RETURN NULL;
END enrp_get_frst_enr_yr;


FUNCTION Enrp_Get_Last_Enr(
  p_person_id IN NUMBER )
RETURN VARCHAR2 AS
        gv_other_details                VARCHAR2(255);
BEGIN
DECLARE
--modified cursor for performance bug 3687150
     CURSOR c_get_acad_alt_cd IS
     SELECT   SUBSTR(IGS_EN_GEN_014.enrs_get_acad_alt_cd(sua_v.cal_type,sua_v.ci_sequence_number),1,10)
     FROM     IGS_EN_SU_ATTEMPT sua_v,
              IGS_CA_INST ci
     WHERE    sua_v.person_id = p_person_id   AND
              sua_v.enrolled_dt IS NOT NULL   AND
              sua_v.cal_type = ci.cal_type    AND
              sua_v.ci_sequence_number = ci.sequence_number
     ORDER BY ci.start_dt desc,
              ci.end_dt desc ;
        v_acad_alt_cd                   IGS_CA_INST.alternate_code%TYPE;
BEGIN
        --- Retrieve the student IGS_PS_UNIT attempt records for the IGS_PE_PERSON.
        --- The order the records are returned will ensure the newest IGS_PS_UNIT
        --- attempt record for the IGS_PE_PERSON is returned first.
        OPEN c_get_acad_alt_cd;
        FETCH c_get_acad_alt_cd INTO v_acad_alt_cd;
        --- Many records may be returned, but we only want the first record.
        --- Return the result of the query, may be null if none were found.
        IF c_get_acad_alt_cd%NOTFOUND THEN
                CLOSE c_get_acad_alt_cd;
                RETURN NULL;
        ELSE
                CLOSE c_get_acad_alt_cd;
                RETURN v_acad_alt_cd;
        END IF;
END;

END enrp_get_last_enr;


FUNCTION Enrp_Get_Last_Enr_Yr(
  p_person_id IN NUMBER )
RETURN DATE AS
BEGIN
        -- This is a stub only and needs to be updated when the spec is complete.
        RETURN NULL;
END enrp_get_last_enr_yr;

END IGS_EN_GEN_005;

/
