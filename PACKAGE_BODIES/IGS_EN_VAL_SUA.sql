--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SUA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SUA" AS
/* $Header: IGSEN68B.pls 120.19 2006/06/05 10:12:58 smaddali ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The Function genp_val_sdtt_sess removed
  --smadathi    29-AUG-2001     Bug No. 1956374 .The Function genp_val_staff_prsn removed
  --nalkumar    04-May-2002     Modified the enrp_val_sua_delete procedure as per the Bug# 2356997.
  --Nishikant   13-may-2002     Bug#2364216. A small modification in the function enrp_val_sua_enr_dt got.
  --prraj       16-May-2002     Changed condition that checks for credit points not syncing with
  --                            credit point min/max/increment in FUNCTION enrp_val_sua_ovrd_cp as part of (Bug# 2375757)
  --Sudhir      23-MAY-2002     Changed the message from IGS_EN_ADMIN_UNITST_NOTVALID to IGS_SS_EN_INVLD_ADMIN_UNITST
  --                            and the req. logic for procedure enrp_val_discont_aus.Also Added out NOCOPY parameter for
  --                            procedure enrp_val_discont_aus.
  --svenkata    20-Nov-2002     Added a new parameter p_legacy to selectively carry out NOCOPY validations for legacy.
  --                            The following routines have been modified : enrp_val_sua_uoo , enrp_val_sua_enr_dt,
  --                            enrp_val_sua_advstnd,resp_val_sua_cnfrm,enrp_val_sua_discont,enrp_val_discont_aus
  -- amuthu     20-JAn-2003     Added the no_assessment_ind column to the function enrp_val_sua_ovrd_cp
  --                            if the value of this column is 'Y' and the Acheivable CP is zero then
  --                            do not validate the acheivalbe CP.
  -- amuthu     04-FEB-2003     Modified the function enrp_get_sua_ausg to consider only audit grades
  --                            for audit units and only non-audit grades for non-audit unit attempts
  -- sarakshi   24-Feb-2003     Enh#2797116,modified cursor c_coo in function's enrp_val_coo_loc and enrp_val_coo_mode
  --                            to add delete_flag check in the where clause
  -- myoganat   23-MAY-2003     Modified the cursor C_SUA_UV in procedure ENRP_VAL_COO_CROSS
  --                            as part of Bug #2855870
  -- svenkata   3-Jun-2003      The function ENRP_VAL_COO_CROSS has been removed. The same functionality has been implemented as
  --                            cross-element restrictions of Validations. Bug# 2829272
  --svanukur   26-jun-2003    checking if discontinued date is set for dropped unit attempt status , then the validations
  --                          for discotinued unit attempts return true from functions enrp_val_discont_aus and
  --                          enrp_val_sua_discont as part of bug 2898213.
  -- ptandon    04-Jul-2003     Modified the function enrp_val_discont_aus to return list of valid administrative unit statuses
  --                            for discontinuation which was initially returning NULL as part of Bug# 3036433
  -- amuthu     07-JUL-2003   Added logic to check if the program attempt status is not Unconfirm/discontin
  --                          when the unit attempt status is enrolled or invalid.
  -- amuthu     04-AUG-2003   Bypassed the discontinuation validation for a dropped unit attempt in enrp_val_sua_discont
  -- rvivekan   09-sep-2003   Modified the behaviour of repeatable_ind column in igs_ps_unit_ver table. PSP integration build #3052433
  --svanukur   18-oct-2003    created procedures enr_sub_units and drop_sub_units as part of placements build 3052438
  --rvivekan    17-nov-2003   Bug3264064. Changed the datatype of variables holding the concatenated administrative unit status list
  --                          to varchar(2000) in enrp_val_discont_aus
  --ptandon     29-Dec-2003   Removed the exception handling sections of enrp_val_sua_cnfrm, enrp_val_sua_insert,
  --                          enrp_val_sua_intrmt, resp_val_sua_cnfrm, enrp_val_sua_excld, enrp_val_sua_advstnd,
  --                          enrp_val_coo_loc, enrp_val_coo_mode, enrp_val_sua_enr_dt, enrp_val_sua_ci and enrp_val_sua_dupl
  --                          so that the correct error message is displayed instead of the unhandled exception message.
  --                          Bug# 3328268.
  --smvk       09-Jul-2004    Bug # 3676145. Modified the cursors c_unit_class to select active (not closed) unit classes.
  -- rnirwani   13-Sep-2004    changed cursor c_sci_details (ENRP_VAL_SUA_INTRMT) to not consider logically deleted records and
  --                            also to avoid un-approved intermission records. Bug# 3885804
  -- ckasu      17-Nov-2004   modfied the ENRP_VAL_SUA_CNFRM_P procedure inorder to consider enrollment Category setup
  --                          for checking the Forced location, attendance mode as apart of Program
  --                          Transfer Build#4000939
  -- amuthu     26-NOV-2004   modified logic in two methods to allow the insertion of completed and dicontinued unit attempts
  -- amuthu     03-DEC-2004   On enrolling user was getting invalid cursor, fixed the issue
  -- ckasu      21-Dec-2004    modified enrp_val_sua_update procedure inorder to Transfer Unit outcomes in ABA Transfer as a part
  --                           of bug# 4080883
  -- sgurusam   17-Jun-2005    Modified to pass aditional parameter p_calling_obj = 'JOB' in the calls to
  --                           igs_ss_en_wrappers.insert_into_enr_worksheet, igs_en_elgbl_unit.eval_unit_forced_location,
  --                           and igs_en_elgbl_unit.eval_unit_forced_mode.
  -- bdeviset   24-Nov_2005    Added proc validate_mus for bug#4676023
  -- ckasu      28-NOV-2005    modified  v_message_name  <> NULL to v_message_name  IS NOT NULL in enrp_val_sua_dupl Function
  --                           as a part of bug #4666102
  -- smaddali  10-apr-06       Modified ENRP_VAL_SUA_INTRMT for bug#5091858 BUILD EN324
  --ckasu      02-May-2006     Modified as a part of bug#5191592
  -------------------------------------------------------------------------------------------
  -- To validate the confirmation of a research unit attempt.
 FUNCTION RESP_VAL_SUA_CNFRM(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2 )
  RETURN boolean AS

  BEGIN -- resp_val_sua_cnfrm
        -- Validate a research student unit attempt being added to a research student
        --(note: this routine is checking confirmation point ?
        -- there is another routine to check commit point processing),
        -- checking for :
        -- *    That the student has a candidature record
        -- *    That the student has supervisors to cover the entire duration
        --      of the teaching period
  DECLARE
        v_rsup_record_not_found BOOLEAN;
        v_teach_days            NUMBER;
        v_teach_end_dt          DATE;
        v_teach_start_dt        DATE;
        v_check_dt              DATE;
        CURSOR c_uv IS
                SELECT  'x'
                FROM    IGS_PS_UNIT_VER uv
                WHERE   uv.unit_cd              = p_unit_cd AND
                        uv.version_number       = p_version_number AND
                        uv.research_unit_ind    <> 'N';
        v_uv_exists     VARCHAR2(1);
        CURSOR c_ca IS
                SELECT  ca.sequence_number
                FROM    IGS_RE_CANDIDATURE      ca
                WHERE   ca.person_id            = p_person_id AND
                        (ca.sca_course_cd       IS NOT NULL AND
                        ca.sca_course_cd        = p_course_cd);
        v_ca_sequence_number    IGS_RE_CANDIDATURE.sequence_number%TYPE;
        CURSOR c_rsup(
                cp_ca_sequence_number   IGS_RE_CANDIDATURE.sequence_number%TYPE) IS
                SELECT  rsup.start_dt
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_person_id AND
                        rsup.ca_sequence_number = cp_ca_sequence_number AND
                        rsup.start_dt           <= v_teach_end_dt AND
                        (rsup.end_dt            IS NULL OR
                        rsup.end_dt             >= v_teach_start_dt)
                ORDER BY rsup.start_dt ASC;

--tray
        CURSOR c_com_dt(p_person_id IGS_EN_STDNT_PS_ATT_ALL.Person_id%TYPE,
                        p_course_cd IGS_EN_STDNT_PS_ATT_ALL.Course_cd%TYPE)IS
                        SELECT commencement_dt from igs_en_stdnt_ps_att_all
                        WHERE person_id = p_person_id
                        AND   course_cd = p_course_cd;
        v_commencement_dt igs_en_stdnt_ps_att_all.commencement_dt%TYPE;

        FUNCTION respl_check_percentage(
                pl_ca_sequence_number           IGS_RE_CANDIDATURE.sequence_number%TYPE,
                pl_check_dt                     IGS_RE_SPRVSR.start_dt%TYPE)
        RETURN BOOLEAN AS

        BEGIN
                -- This is a local function to check the total percentages of
                -- funding and supervision for the research_supervior
        DECLARE
                vl_total_supervision    NUMBER;
                vl_total_funding        NUMBER;
                CURSOR c_rsup_chk_pct IS
                        SELECT  SUM(NVL(rsup.supervision_percentage, 0)),
                                SUM(NVL(rsup.funding_percentage, 0))
                        FROM    IGS_RE_SPRVSR rsup
                        WHERE   rsup.ca_person_id       = p_person_id AND
                                rsup.ca_sequence_number = pl_ca_sequence_number AND
                                rsup.start_dt           <= pl_check_dt AND
                                (rsup.end_dt            IS NULL OR
                                rsup.end_dt             >= pl_check_dt);
                CURSOR  c_rsup_per_type IS
                        SELECT  IGS_EN_GEN_003.Get_Staff_Ind( rsup.person_id) person_type
                        FROM IGS_RE_SPRVSR rsup
                        WHERE rsup.ca_person_id       = p_person_id AND
                                rsup.ca_sequence_number = pl_ca_sequence_number AND
                                rsup.start_dt           <= pl_check_dt AND
                                (rsup.end_dt            IS NULL OR
                                rsup.end_dt             >= pl_check_dt);
               l_person_type  c_rsup_per_type%ROWTYPE ;
        BEGIN
                OPEN c_rsup_chk_pct;
                FETCH c_rsup_chk_pct INTO vl_total_supervision,
                                          vl_total_funding;
                IF c_rsup_chk_pct%NOTFOUND OR
                                vl_total_supervision < 100  THEN
                        CLOSE c_rsup_chk_pct;
                        p_message_name := 'IGS_RE_CAND_DOES_NOT_HAVE_SUP';
                        RETURN FALSE;
                END IF;
                IF NVL(vl_total_funding,0) < 100 THEN
                       FOR l_person_type IN c_rsup_per_type LOOP
                           IF l_person_type.person_type = 'Y' THEN
                              p_message_name := 'IGS_RE_CAND_DOES_NOT_HAVE_SUP';
                             RETURN FALSE;
                           END IF;
                       END LOOP;
                END IF;
                CLOSE c_rsup_chk_pct;
                RETURN TRUE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_rsup_chk_pct%ISOPEN THEN
                                CLOSE c_rsup_chk_pct;
                        END IF;
                        RAISE;
        END;
        END respl_check_percentage;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        OPEN c_uv;
        FETCH c_uv INTO v_uv_exists;
        IF c_uv%NOTFOUND THEN
                CLOSE c_uv;
                -- invalid parameters
                RETURN TRUE;
        END IF;
        CLOSE c_uv;
        --1. Check that student has a candidature matching the course attempt.
        OPEN c_ca;
        FETCH c_ca INTO v_ca_sequence_number;
        IF c_ca%NOTFOUND THEN

                CLOSE c_ca;
                p_message_name := 'IGS_RE_MUST_HAVE_RES_CANDIDAT';
        IF p_legacy <> 'Y' THEN
                    RETURN FALSE;
        ELSE
            Fnd_Message.Set_Name('IGS', p_message_name  );
            FND_MSG_PUB.ADD;
        END IF;
    ELSE
        CLOSE c_ca;
        END IF;

        IF p_cal_type IS NULL OR p_ci_sequence_number IS NULL THEN
                -- Remaining validations don't apply without calendar details.
                RETURN TRUE;
        END IF;
        v_teach_days := IGS_RE_GEN_002.RESP_GET_TEACH_DAYS(
                                        p_cal_type,
                                        p_ci_sequence_number,
                                        v_teach_start_dt,
                                        v_teach_end_dt );
        IF ( v_teach_days = 0 AND p_legacy <> 'Y' )THEN
                p_message_name := 'IGS_RE_TEACH_PER_NOT_SETUP';
                RETURN TRUE;    -- Warning Only
        END IF;


        --2. Check that student has 100% supervision to cover the teaching period.
OPEN c_com_dt (p_person_id,p_course_cd);
  FETCH c_com_dt INTO v_commencement_dt;
        v_rsup_record_not_found := TRUE;
        FOR v_rsup_rec IN c_rsup(
                                v_ca_sequence_number) LOOP
                --IF first record
                IF c_rsup%ROWCOUNT = 1 THEN
                 v_rsup_record_not_found := FALSE;

IF c_com_dt%NOTFOUND  THEN
    IF p_legacy <> 'Y' THEN
        p_message_name := 'IGS_RE_COM_DT_UNAVAIL';
        CLOSE c_com_dt;
        RETURN FALSE;
    END IF;
ELSE
   CLOSE c_com_dt;
   IF v_commencement_dt BETWEEN  v_teach_start_dt AND v_teach_end_dt THEN
     IF v_commencement_dt < v_rsup_rec.start_dt THEN
        p_message_name := 'IGS_RE_COM_DT_LESS_SUP_ST_DT';
        IF p_legacy <> 'Y' THEN
                        RETURN FALSE;
                ELSE
            Fnd_Message.Set_Name('IGS', p_message_name );
            FND_MSG_PUB.ADD;
                END IF ;
     END IF;
   ELSE
                        IF v_rsup_rec.start_dt > v_teach_start_dt THEN
                                p_message_name := 'IGS_RE_CAND_DOES_NOT_HAVE_SUP';
                                IF p_legacy <> 'Y' THEN
                                RETURN FALSE;
                        ELSE
                    Fnd_Message.Set_Name('IGS', p_message_name );
                    FND_MSG_PUB.ADD;
                        END IF ;
                        ELSE
                                v_check_dt := v_rsup_rec.start_dt;
                                --Execute <Check Percentages>
                                IF respl_check_percentage(
                                                        v_ca_sequence_number,
                                                        v_check_dt) = FALSE THEN
                    IF p_legacy <> 'Y' THEN
                                    RETURN FALSE;
                            ELSE
                        Fnd_Message.Set_Name('IGS', p_message_name );
                        FND_MSG_PUB.ADD;
                            END IF ;
                                END IF;
                        END IF;

    END IF;

END IF;
                ELSE  --if multiple records
                        v_check_dt := v_rsup_rec.start_dt;
                        --Execute <Check Percentages>
                        IF  respl_check_percentage(
                                                v_ca_sequence_number,
                                                v_check_dt) = FALSE THEN
                    IF p_legacy <> 'Y' THEN
                                    RETURN FALSE;
                            ELSE
                        Fnd_Message.Set_Name('IGS', p_message_name );
                        FND_MSG_PUB.ADD;
                            END IF ;
                        END IF;
        END IF;
        END LOOP;
        IF v_rsup_record_not_found THEN
                --No supervisors found - error
                p_message_name := 'IGS_RE_CAND_DOES_NOT_HAVE_SUP';
        IF p_legacy <> 'Y' THEN
                    RETURN FALSE;
        ELSE
            Fnd_Message.Set_Name('IGS', p_message_name );
            FND_MSG_PUB.ADD;
                END IF ;
        END IF;
        v_check_dt := v_teach_end_dt;
        --Execute <Check Percentages>
        IF respl_check_percentage(
                                v_ca_sequence_number,
                                v_check_dt) = FALSE THEN
                IF p_legacy <> 'Y' THEN
                    RETURN FALSE;
        ELSE
            Fnd_Message.Set_Name('IGS', p_message_name );
            FND_MSG_PUB.ADD;
                END IF ;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_uv%ISOPEN THEN
                        CLOSE c_uv;
                END IF;
                IF c_ca%ISOPEN THEN
                        CLOSE c_ca;
                END IF;
                RAISE;
  END;
  END RESP_VAL_SUA_CNFRM ;

  --
  -- To validate all research units in an academic period
  FUNCTION RESP_VAL_SUA_ALL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
  -------------------------------------------------------------------------------------------
  -- resp_val_sua_all
  -- Validate research unit attempts for a research student course attempt,
  -- checking for:
  -- * That a student doesn't have multiple research units enrolled in a
  -- single teaching period.
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified the c_sua cursor where clause due to change in the pk of
  --                            student unit attempt w.r.t. bug number 2829262
  --stutta      06-Mar-2006     Modified cursor c_sua and added c_acad for perf bug #5025850
  -------------------------------------------------------------------------------------------
  BEGIN
  DECLARE
        cst_enrolled            CONSTANT VARCHAR2(10) := 'ENROLLED';
        cst_academic            CONSTANT VARCHAR2(10) := 'ACADEMIC';
        cst_active              CONSTANT VARCHAR2(10) := 'ACTIVE';
        cst_completed           CONSTANT VARCHAR2(10) := 'COMPLETED';
        cst_discontin           CONSTANT VARCHAR2(10) := 'DISCONTIN';
        cst_load                CONSTANT VARCHAR2(10) := 'LOAD';

        CURSOR c_ca IS
                SELECT  'x'
                FROM    IGS_RE_CANDIDATURE      ca
                WHERE   ca.person_id            = p_person_id AND
                        (ca.sca_course_cd       IS NULL OR
                        ca.sca_course_cd        = p_course_cd);
        v_ca_exists     VARCHAR2(1);


        CURSOR c_acad IS
          SELECT DISTINCT cir.sup_cal_type acad_cal_type, cir.sup_ci_sequence_number acad_ci_sequence_number
           FROM igs_ca_inst_rel cir, igs_en_su_attempt_all sua
          WHERE sua.cal_type = cir.sub_cal_type
            AND sua.ci_sequence_number = cir.sub_ci_sequence_number
            AND sua.person_id = p_person_id
            AND sua.course_cd = p_course_cd
            AND cir.sup_cal_type = NVL(p_acad_cal_type,cir.sup_cal_type)
            AND cir.sup_ci_sequence_number = NVL(p_acad_ci_sequence_number,cir.sup_ci_sequence_number);


        CURSOR c_sua(cp_acad_cal_type igs_ca_inst.cal_type%TYPE,cp_acad_seq_num igs_ca_inst.sequence_number%TYPE) IS
            SELECT
                  sua2.cal_type sua_cal_type,
                  sua2.ci_sequence_number sua_ci_sequence_number,
                  sua2.discontinued_dt,
                  sua2.administrative_unit_status,
                  sua2.unit_attempt_status,
                  sua2.no_assessment_ind,
                  loadcal.cal_type ci_cal_type,
                  loadcal.sequence_number ci_sequence_number
            FROM
                  IGS_EN_SU_ATTEMPT_all       sua1,
                  IGS_EN_SU_ATTEMPT_all       sua2 ,
                  IGS_PS_UNIT_VER_ALL uv1,
                  IGS_PS_UNIT_VER_ALL uv2,
                  IGS_CA_INST_ALL loadcal,
                  IGS_CA_INST_REL acadterm,
                  IGS_CA_TYPE             cat2,
                  IGS_CA_STAT             cs2 ,
                  IGS_ST_DFT_LOAD_APPO    l2t,
                  IGS_ST_DFT_LOAD_APPO    l2tsua2

            WHERE sua1.person_id = p_person_id
            AND   sua1.course_cd = p_course_cd
            AND   sua1.unit_attempt_status = cst_enrolled
            AND   sua2.uoo_id <> sua1.uoo_id
            AND   sua1.person_id = sua2.person_id
            AND   sua1.course_cd = sua2.course_cd
            AND   sua2.unit_attempt_status IN (cst_enrolled,cst_completed,cst_discontin)
            AND   uv1.unit_cd = sua1.unit_cd
            AND   uv1.version_number = sua1.version_number
            AND   uv2.unit_cd = sua2.unit_cd
            AND   uv2.version_number =sua2.version_number
            AND   uv1.research_unit_ind = 'Y'
            AND   uv2.research_unit_ind = 'Y'
            AND   EXISTS (SELECT 'x' FROM IGS_CA_INST_REL acadteach
                      WHERE acadteach.sup_cal_type = cp_acad_cal_type
                      AND acadteach.sup_ci_sequence_number = cp_acad_seq_num
                      AND acadteach.sub_cal_type = sua1.cal_type
                      AND acadteach.sub_ci_sequence_number = sua1.ci_sequence_number)
            AND   EXISTS (SELECT 'x' FROM IGS_CA_INST_REL acadteach
                             WHERE acadteach.sup_cal_type = cp_acad_cal_type
                             AND acadteach.sup_ci_sequence_number = cp_acad_seq_num
                             AND acadteach.sub_cal_type = sua2.cal_type
                             AND acadteach.sub_ci_sequence_number = sua2.ci_sequence_number)
            AND  acadterm.sup_cal_type   = cp_acad_cal_type
            AND  acadterm.sup_ci_sequence_number     = cp_acad_seq_num
            AND  loadcal.cal_type                    = acadterm.sub_cal_type
            AND  loadcal.sequence_number             = acadterm.sub_ci_sequence_number
            AND  cat2.cal_type                   = loadcal.cal_type
            AND  cat2.s_cal_cat                  = cst_load
                 -- Check they are active
            AND  cs2.cal_status                  = loadcal.cal_status
            AND  cs2.s_cal_status                = cst_active
            AND l2t.cal_type            = loadcal.cal_type
            AND l2t.ci_sequence_number  = loadcal.sequence_number
            AND l2t.teach_cal_type      = sua1.cal_type
            AND l2tsua2.cal_type = l2t.cal_type
            AND l2tsua2.ci_sequence_number = l2t.ci_sequence_number
            AND l2tsua2.teach_cal_type = sua2.cal_type;




        v_return_false          BOOLEAN  :=  FALSE;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        -- 1. Check if the person is a candidate.
        OPEN c_ca;
        FETCH c_ca INTO v_ca_exists;
        IF c_ca%NOTFOUND THEN
                CLOSE c_ca;
                -- Not a research student - not applicable.
                RETURN TRUE;
        END IF;
        CLOSE c_ca;
        -- 2. Select all enrolled research units (in the academic year if specified)
        -- Determine the load calendar to which the teaching calendar contributes.
        -- Find any other research unit attempts which are
        -- incurring load within the same load calendar.

        FOR rec_acad IN c_acad LOOP
          FOR v_sua_rec IN c_sua(rec_acad.acad_cal_type, rec_acad.acad_ci_sequence_number) LOOP
                  IF IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR(
                                                  v_sua_rec.sua_cal_type,
                                                  v_sua_rec.sua_ci_sequence_number,
                                                  v_sua_rec.discontinued_dt,
                                                  v_sua_rec.administrative_unit_status,
                                                  v_sua_rec.unit_attempt_status,
                          v_sua_rec.no_assessment_ind,
                                                  v_sua_rec.ci_cal_type,
                                                  v_sua_rec.ci_sequence_number,
                                                  -- anilk, Audit special fee build
                                                  NULL, -- for p_uoo_id
                                                  'N') = 'Y' THEN
                          v_return_false := TRUE;
                          EXIT;
                  END IF;
          END LOOP;
        END LOOP;
        IF v_return_false THEN
                p_message_name := 'IGS_RE_CAND_ENROL_IN_SING_RES';
                RETURN FALSE;
        END IF;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sua%ISOPEN THEN
                        CLOSE c_sua;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.resp_val_sua_all');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END resp_val_sua_all;
  --
  -- To validate for student unit attempt being excluded
  FUNCTION enrp_val_sua_excld(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN -- enrp_val_sua_excld
        -- This module validates if a student unit attempt is excluded from
        -- enrolment / re-enrolment because of person, course, course group
        -- or course unit exclusions that are effective on the census date
        -- of the teaching period of the unit attempt.
  DECLARE
        v_message_name          varchar2(30);
        v_ret                   BOOLEAN;
        CURSOR  c_sua IS
                SELECT  daiv.alias_val,
                        ci.start_dt,
                        ci.end_dt
                FROM    IGS_CA_DA_INST_V        daiv,
                        IGS_CA_INST             ci,
                        IGS_GE_S_GEN_CAL_CON            sgcc
                WHERE   daiv.cal_type           = p_cal_type AND
                        daiv.ci_sequence_number = p_ci_sequence_number AND
                        daiv.dt_alias           = sgcc.census_dt_alias AND
                        sgcc.s_control_num      = 1 AND
                        daiv.cal_type           = ci.cal_type AND
                        daiv.ci_sequence_number = ci.sequence_number;
  BEGIN
        p_message_name := null;
        -- Validate parameters passed.
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_unit_cd IS NULL OR
                        p_cal_type IS NULL OR
                        p_ci_sequence_number IS NULL THEN
                p_message_name := 'IGS_EN_PARAM_ROUTINE_SPECIFY';
                RETURN FALSE;
        END IF;
        -- Validate records
        FOR v_sua_rec IN c_sua LOOP
                -- Only validate if census date is between ci.start_dt and ci.end_dt.
                IF (v_sua_rec.alias_val >= v_sua_rec.start_dt) AND
                                (v_sua_rec.alias_val <= v_sua_rec.end_dt) THEN
                        -- Validate against person, course and course group exclusions.
                        IF IGS_EN_VAL_ENCMB.enrp_val_excld_crs (
                                                        p_person_id,
                                                        p_course_cd,
                                                        v_sua_rec.alias_val,
                                                        v_message_name) = FALSE THEN
                                p_message_name := v_message_name;
                                v_ret := FALSE;
                                EXIT;
                        END IF;
                        -- Validate against course and unit exclusions.
                        IF IGS_EN_VAL_ENCMB.enrp_val_excld_unit (
                                                                p_person_id,
                                                                p_course_cd,
                                                                p_unit_cd,
                                                                v_sua_rec.alias_val,
                                                                v_message_name) = FALSE THEN
                                v_ret := FALSE;
                                p_message_name := v_message_name;
                                EXIT;
                        END IF;
                END IF;
        END LOOP;
        IF v_ret = FALSE THEN
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_sua%ISOPEN) THEN
                        CLOSE c_sua;
                END IF;
                RAISE;
  END;
  END enrp_val_sua_excld;
  --
  -- To validate update of SUA.
  FUNCTION enrp_val_sua_update(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_unit_attempt_status         IN VARCHAR2 ,
  p_new_version_number          IN NUMBER ,
  p_new_location_cd             IN VARCHAR2 ,
  p_new_unit_class              IN VARCHAR2 ,
  p_new_enrolled_dt             IN DATE ,
  p_new_discontinued_dt         IN DATE ,
  p_new_admin_unit_status       IN VARCHAR2 ,
  p_new_rule_waived_dt          IN DATE ,
  p_new_rule_waived_person_id   IN NUMBER ,
  p_new_no_assessment_ind       IN VARCHAR2 ,
  p_new_sup_unit_cd             IN VARCHAR2 ,
  p_new_sup_version_number      IN NUMBER ,
  p_new_exam_location_cd        IN VARCHAR2 ,
  p_old_version_number          IN NUMBER ,
  p_old_location_cd             IN VARCHAR2 ,
  p_old_unit_class              IN VARCHAR2 ,
  p_old_enrolled_dt             IN DATE ,
  p_old_discontinued_dt         IN DATE ,
  p_old_admin_unit_status       IN VARCHAR2 ,
  p_old_rule_waived_dt          IN DATE ,
  p_old_rule_waived_person_id   IN NUMBER ,
  p_old_no_assessment_ind       IN VARCHAR2 ,
  p_old_sup_unit_cd             IN VARCHAR2 ,
  p_old_sup_version_number      IN NUMBER ,
  p_old_exam_location_cd        IN VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN NUMBER)
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Added new parameter p_uoo_id to the function
  --                            Modified the c_sut cursor where clause due to change in pk
  --                            of student unit attempt table w.r.t. bug number 2829262
  -- ckasu      21-Dec-2004    modified  procedure inorder to  as a part of bug# 4080883
  -- ctyagi     29-Sept-2005   modified cursor c_sut for bug# 4524765
  -------------------------------------------------------------------------------------------
  BEGIN -- enrp_val_sua_update
        -- This modules validates the update of IGS_EN_SU_ATTEMPT in relation to
        -- unit_attempt_status.
  DECLARE
        CURSOR c_sut IS
               SELECT 'X'
               FROM IGS_PS_STDNT_UNT_TRN sut1
               WHERE
                sut1.person_id = p_person_id AND
                sut1.transfer_course_cd  = p_course_cd AND
                sut1.uoo_id = p_uoo_id and
                sut1.transfer_dt = ( SELECT max(sut2.transfer_dt)
                                     FROM IGS_PS_STDNT_UNT_TRN sut2
                                     where sut2.person_id = sut1.person_id
                                     and sut2.transfer_course_cd = sut1.transfer_course_cd
                                     and sut2.uoo_id = sut1.uoo_id)
                and sut1.transfer_dt > (SELECT NVL(max(sut3.transfer_dt),(sut1.transfer_dt-1))
                                     FROM IGS_PS_STDNT_UNT_TRN sut3
                                     where sut3.person_id = sut1.person_id
                                     and sut3.course_cd = sut1.transfer_course_cd
                                     and sut3.uoo_id = sut1.uoo_id);
        CURSOR c_sca IS
                SELECT  sca.course_attempt_status
                FROM    IGS_EN_STDNT_PS_ATT     sca
                WHERE   sca.person_id   = p_person_id AND
                        sca.course_cd   = p_course_cd;
        CURSOR c_old_sua_attr IS
                SELECT  sua.unit_attempt_status
                FROM    igs_en_su_attempt sua
                WHERE   sua.person_id = p_person_id AND
                        sua.course_cd = p_course_cd AND
                        sua.uoo_id = p_uoo_id;
        l_old_unit_status       igs_en_su_attempt.unit_attempt_status%TYPE;

        v_course_attempt_status         IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        v_sut_found                     VARCHAR2(1)  :=  NULL;
        cst_duplicate                   CONSTANT        VARCHAR2(10) := 'DUPLICATE';
        cst_completed                   CONSTANT        VARCHAR2(10) := 'COMPLETED';
        cst_discontin                   CONSTANT        VARCHAR2(10) := 'DISCONTIN';
        cst_lapsed                      CONSTANT        VARCHAR2(7)  := 'LAPSED';
        cst_unconfirm                   CONSTANT        VARCHAR2(10) := 'UNCONFIRM';
        cst_invalid                     CONSTANT        VARCHAR2(10) := 'INVALID';
        cst_enrolled                    CONSTANT        VARCHAR2(10) := 'ENROLLED';
        cst_dropped                     CONSTANT        VARCHAR2(10) := 'DROPPED';
  BEGIN
        -- Set p_message_name
        p_message_name := null;
        OPEN c_sca;
        FETCH c_sca INTO v_course_attempt_status;
        IF (c_sca%NOTFOUND) THEN
                CLOSE c_sca;
                RETURN TRUE;
        ELSE
                CLOSE c_sca;
                IF v_course_attempt_status = cst_lapsed THEN
                        p_message_name := 'IGS_EN_SUA_NOTUPD_PRGATT_LAPS';
                        RETURN FALSE;
                ELSIF  v_course_attempt_status = cst_discontin THEN
                        IF p_unit_attempt_status = cst_unconfirm THEN
                                p_message_name := 'IGS_EN_UNCONFIRM_SUA';
                                RETURN FALSE;
                        ELSIF p_unit_attempt_status = cst_invalid THEN
                                p_message_name := 'IGS_EN_INVALID_SUA_NOTUPD';
                                RETURN FALSE;
                        END IF;
                END IF;

                IF p_unit_attempt_status IN (cst_enrolled,cst_invalid) THEN
                  IF v_course_attempt_status = cst_unconfirm THEN
                    p_message_name := 'IGS_EN_SUA_NOTCONFIRM_SPA';
                    RETURN FALSE;
                  ELSIF v_course_attempt_status = cst_discontin THEN
                    p_message_name := 'IGS_EN_SUA_NOT_ENROL';
                    RETURN FALSE;
                  END IF;
                END IF;

        END IF;

        -- get the old unit attempt status. This will be available because this procedure is called from before_dml
        -- code added by ckasu as a part of bug# 4080883
        OPEN c_old_sua_attr ;
        FETCH c_old_sua_attr INTO l_old_unit_status;
        CLOSE c_old_sua_attr;

        IF p_unit_attempt_status = cst_duplicate AND l_old_unit_status <> cst_dropped THEN
                p_message_name := 'IGS_EN_SUPL_SUA_NOTUPD';
                RETURN FALSE;
        END IF;


        IF p_unit_attempt_status = cst_completed AND l_old_unit_status NOT IN (cst_dropped,cst_completed) THEN
                -- Check that completed unit is not a duplicate
                OPEN c_sut;
                FETCH c_sut INTO v_sut_found;
                IF (c_sut%FOUND) THEN
                        CLOSE c_sut;
                        p_message_name := 'IGS_EN_COMPL_UA_NOTUPD';
                        RETURN FALSE;
                END IF;
                CLOSE c_sut;
        END IF;

        IF p_unit_attempt_status = cst_completed AND l_old_unit_status <> cst_dropped THEN
                IF p_old_version_number <> p_new_version_number OR
                                p_old_location_cd <> p_new_location_cd OR
                                p_old_unit_class <> p_new_unit_class OR
                                TRUNC(p_old_enrolled_dt) <> TRUNC(p_new_enrolled_dt) OR
                                p_old_admin_unit_status <>  p_new_admin_unit_status OR
                                TRUNC(p_old_discontinued_dt) <> TRUNC(p_new_discontinued_dt) OR
                                p_old_rule_waived_dt <> p_new_rule_waived_dt OR
                                p_old_rule_waived_person_id <> p_new_rule_waived_person_id OR
                                p_old_no_assessment_ind <> p_new_no_assessment_ind OR
                                p_old_sup_unit_cd <> p_new_sup_unit_cd OR
                                p_old_sup_version_number <> p_new_sup_version_number OR
                                p_old_exam_location_cd <> p_new_exam_location_cd THEN
                        p_message_name := 'IGS_EN_COMPL_SUA_NOTUPD';
                        RETURN FALSE;
                END IF;
        END IF;
        IF p_unit_attempt_status = cst_discontin AND l_old_unit_status <> cst_dropped THEN
                OPEN c_sut;
                FETCH c_sut INTO v_sut_found;
                IF (c_sut%FOUND) THEN
                        CLOSE c_sut;
                        p_message_name := 'IGS_EN_DISCONT_UA_NOTUPD_DUPL';
                        RETURN FALSE;
                END IF;
                CLOSE c_sut;
                IF p_old_version_number <> p_new_version_number OR
                                p_old_location_cd <> p_new_location_cd OR
                                p_old_unit_class <> p_new_unit_class OR
                                TRUNC(p_old_enrolled_dt) <> TRUNC(p_new_enrolled_dt) OR
                                p_old_no_assessment_ind <> p_new_no_assessment_ind OR
                                p_old_sup_unit_cd <> p_new_sup_unit_cd OR
                                p_old_sup_version_number <> p_new_sup_version_number OR
                                p_old_exam_location_cd <> p_new_exam_location_cd THEN
                        p_message_name := 'IGS_EN_DISCONT_DET_SUA';
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_sut%ISOPEN) THEN
                        CLOSE c_sut;
                END IF;
                IF (c_sca%ISOPEN) THEN
                        CLOSE c_sca;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_update');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_update;
  --
  -- To validate SUA override credit reason
  FUNCTION enrp_val_sua_cp_rsn(
  p_override_enrolled_cp IN NUMBER ,
  p_override_achievable_cp IN NUMBER ,
  p_override_credit_reason IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN -- enrp_val_sua_cp_rsn
        -- This module validates that IGS_EN_SU_ATTEMPT.override_credit_reason
        -- only exists if one of IGS_EN_STDNT_PS_ATT.override_enrolled_cp or
        -- IGS_EN_STDNT_PS_ATT.override_achievalble_cp exists.
  BEGIN
        p_message_name := null;
        IF (p_override_credit_reason IS NOT NULL) AND
                        (p_override_enrolled_cp IS NULL) AND
                        (p_override_achievable_cp IS NULL) THEN
                p_message_name := 'IGS_EN_OVERRIDE_CRD_REASON';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_cp_rsn');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_cp_rsn;
  --
  -- Routine to clear records saved in a PL/SQL RECORD from a prior commit.
  PROCEDURE enrp_clear_sua_exist
  AS
  BEGIN
        -- initialise
        gt_sua_exists_table := gt_sua_exists_empty_table;
        gv_sua_exists_table_index := 1;
  END enrp_clear_sua_exist;

 --
  -- To validate enrolled date of SUA.
  FUNCTION enrp_val_sua_ci(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_form_trigger_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN -- enrp_val_sua_ci
        -- This module validates that the teaching period is valid for the
        -- IGS_EN_SU_ATTEMPT.
        -- * Teaching period must start after the commencement date of the
        -- IGS_EN_STDNT_PS_ATT.
  DECLARE
        CURSOR c_ci IS
                SELECT  ci.end_dt
                FROM    IGS_CA_INST     ci
                WHERE   ci.cal_type             = p_cal_type AND
                        ci.sequence_number      = p_ci_sequence_number;
        v_ci_rec        c_ci%ROWTYPE;
        CURSOR c_sca IS
                SELECT  sca.commencement_dt
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   sca.person_id = p_person_id AND
                        sca.course_cd = p_course_cd;
        v_sca_rec       c_sca%ROWTYPE;
        cst_duplicate   CONSTANT VARCHAR2(9) := 'DUPLICATE';
        cst_discontin   CONSTANT VARCHAR2(9) := 'DISCONTIN';
        cst_completed   CONSTANT VARCHAR2(9) := 'COMPLETED';
        v_commencement_dt       IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        IF p_unit_attempt_status NOT IN (cst_duplicate,cst_discontin,cst_completed) THEN
                IF p_form_trigger_ind = 'F' THEN
                        IF p_commencement_dt IS NULL THEN
                                RETURN TRUE;
                        ELSE
                                v_commencement_dt := p_commencement_dt;
                        END IF;
                ELSE
                        -- We need to get the commencement date from
                        -- the student course attempt
                        OPEN c_sca;
                        FETCH c_sca INTO v_sca_rec;
                        IF c_sca%NOTFOUND THEN
                                -- This should not occur, return from function
                                CLOSE c_sca;
                                RETURN TRUE;
                        END IF;
                        CLOSE c_sca;
                        IF v_sca_rec.commencement_dt IS NULL THEN
                                RETURN TRUE;
                        ELSE
                                v_commencement_dt := v_sca_rec.commencement_dt;
                        END IF;
                END IF;
                -- Determine end date of calendar instance
                -- (student unit attempt teaching period)
                OPEN c_ci;
                FETCH c_ci INTO v_ci_rec;
                IF c_ci%NOTFOUND THEN
                        -- This should not occur, return from function
                        CLOSE c_ci;
                        RETURN TRUE;
                END IF;
                CLOSE c_ci;
                -- Check that end date of teaching period is
                -- not less than the commencement date
                IF v_ci_rec.end_dt < v_commencement_dt THEN
                        p_message_name := 'IGS_EN_TEACHPRD_UA_NOT_PRIOR';
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_ci%ISOPEN THEN
                        CLOSE c_ci;
                END IF;
                RAISE;
  END;
  END enrp_val_sua_ci;
  --
  -- To validate SUA alternative title.
  FUNCTION enrp_val_sua_alt_ttl(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_alternative_title IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN         -- enrp_val_sua_alt_ttl
        -- validate the student unit attempt alternative title.
  DECLARE
        v_title_override_ind    IGS_PS_UNIT_VER.title_override_ind%TYPE;
        CURSOR c_uv IS
                SELECT  title_override_ind
                FROM    IGS_PS_UNIT_VER uv
                WHERE   uv.unit_cd              = p_unit_cd AND
                        uv.version_number       = p_version_number;
  BEGIN
        p_message_name := null;
        IF p_alternative_title IS NULL THEN
                RETURN TRUE;
        END IF;
        OPEN c_uv;
        FETCH c_uv INTO v_title_override_ind;
        IF (c_uv%FOUND) THEN
                IF (v_title_override_ind = 'N') THEN
                        CLOSE c_uv;
                        p_message_name := 'IGS_EN_ALT_TITLE_NOTPERMITTED';
                        RETURN FALSE;
                END IF;
        END IF;
        CLOSE c_uv;
        RETURN TRUE ;
  EXCEPTION
        WHEN OTHERS THEN
                IF(c_uv%ISOPEN) THEN
                        CLOSE c_uv;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_alt_ttl');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_alt_ttl;
  --
  -- Routine to clear records saved in a PL/SQL RECORD from a prior commit.
  PROCEDURE enrp_clear_sua_dupl
  AS
  BEGIN
        -- initialise
        gt_sua_duplicate_table := gt_sua_duplicate_empty_table;
        gv_sua_duplicate_table_index := 1;
  END enrp_clear_sua_dupl;

  --
  -- Validate whether unit attempt can be pre-enrolled
  FUNCTION enrp_val_sua_pre(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_log_creation_dt IN DATE ,
  p_warn_level OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS

  BEGIN -- enrp_val_sua_pre
        -- To check for advanced standing or encumbrances which would prevent
        -- the unit attempt being added as part of a pre-enrolment of units.
  DECLARE
        cst_pre_enrol           CONSTANT VARCHAR2(10) := 'PRE-ENROL';
        cst_minor               CONSTANT VARCHAR2(10) := 'MINOR';
        cst_granted             CONSTANT VARCHAR2(10) := 'GRANTED';
        cst_approved            CONSTANT VARCHAR2(10) := 'APPROVED';
        cst_credit              CONSTANT VARCHAR2(10) := 'CREDIT';
        cst_preclusion          CONSTANT VARCHAR2(10) := 'PRECLUSION';
        CURSOR c_adv IS
                SELECT  'x'
                FROM    IGS_AV_STND_UNIT        asu
                WHERE   asu.person_id           = p_person_id AND
                        asu.as_course_cd        = p_course_cd AND
                        asu.unit_cd             = p_unit_cd AND
                        ((asu.s_adv_stnd_recognition_type = cst_credit AND
                        igs_av_val_asu.granted_adv_standing(p_person_id,p_course_cd,NULL,
                                                            p_unit_cd,NULL,'BOTH',NULL) ='TRUE')
                         OR
                        (asu.s_adv_stnd_granting_status IN (cst_approved,cst_granted) AND
                         asu.s_adv_stnd_recognition_type = cst_preclusion));
        v_adv_exists            VARCHAR2(1);
        v_message_name          varchar2(30);
  BEGIN
        -- Set the default message number
        p_message_name := null;
        -- Check for advanced standing which is either Approved or Granted,
        -- and which is either a 100% credit or a preclusion from the nominated unit.
        OPEN c_adv;
        FETCH c_adv INTO v_adv_exists;
        IF c_adv%FOUND THEN
                CLOSE c_adv;
                IF p_log_creation_dt IS NOT NULL THEN
                        -- Write to the exception log
                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        cst_pre_enrol,
                                        p_log_creation_dt,
                                        cst_minor || ',' ||
                                                TO_CHAR(p_person_id) || ',' ||
                                                p_course_cd,
                                        'IGS_EN_STUD_INELG_ADV_STANDIN',
                                        p_unit_cd);
                END IF;
                p_warn_level := cst_minor;
                p_message_name := 'IGS_EN_STUD_INELG_ADV_STANDIN';
                RETURN FALSE;
        ELSE
                CLOSE c_adv;
        END IF;
        -- Check for an encumbrance on the unit which would prevent it
        -- being enrolled. This checks for a current encumbrance, irrespective
        -- of whether it may be lifted sometime during the academic year.
        IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_unit(
                                        p_person_id,
                                        p_course_cd,
                                        p_unit_cd,
                                        SYSDATE,
                                        v_message_name) THEN
                IF p_log_creation_dt IS NOT NULL THEN
                        -- Write to the exception log
                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        cst_pre_enrol,
                                        p_log_creation_dt,
                                        cst_minor || ',' ||
                                                TO_CHAR(p_person_id) || ',' ||
                                                p_course_cd,
                                                'IGS_EN_STUD_INELG_UNIT_EXCLUS',
                                                p_unit_cd);
                END IF;
                p_warn_level := cst_minor;
                p_message_name := 'IGS_EN_STUD_INELG_UNIT_EXCLUS';
                RETURN FALSE;
        END IF;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_adv%ISOPEN THEN
                        CLOSE c_adv;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_pre');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_pre;
  --

  --
  -- To validate SUA advanced standing unit.
  FUNCTION enrp_val_sua_advstnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crs_version_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_un_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2)
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    10-JUL-2003     Returning error message only if repeatable_ind is 'N' w.r.t. 3036367
  --rvivekan    09-sep-2003     Modified the behaviour of repeatable_ind column in igs_ps_unit_ver table. PSP integration build #3052433
  --rvivekan    24-SEP-2006     Removed p_legacy check for the granted advanced standing validation Bug#3132543
  -------------------------------------------------------------------------------------------
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_approved    CONSTANT VARCHAR2(10) := 'APPROVED';
        cst_granted     CONSTANT VARCHAR2(10) := 'GRANTED';
        cst_credit      CONSTANT VARCHAR2(10) := 'CREDIT';
        cst_preclusion  CONSTANT VARCHAR2(10) := 'PRECLUSION';
        v_other_detail                  VARCHAR2(255);
        v_total_exmptn_approved         IGS_AV_ADV_STANDING.total_exmptn_approved%TYPE;
        v_total_exmptn_granted          IGS_AV_ADV_STANDING.total_exmptn_granted%TYPE;
        v_total_exmptn_perc_grntd               IGS_AV_ADV_STANDING.total_exmptn_perc_grntd%TYPE;
        v_message_name                  varchar2(30);
        v_crs_version_number            IGS_EN_STDNT_PS_ATT.version_number%TYPE;
        v_repeatable_ind                        IGS_PS_UNIT_VER.repeatable_ind%TYPE;
        CURSOR c_sca(
                        cp_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                        cp_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
                SELECT  sca.version_number
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   sca.person_id = cp_person_id AND
                        sca.course_cd = cp_course_cd;
        CURSOR c_adv_stnd_unit_details (
                        cp_person_id      IGS_AV_STND_UNIT.person_id%TYPE,
                        cp_course_cd      IGS_AV_STND_UNIT.as_course_cd%TYPE,
                        cp_crs_vers_num   IGS_AV_STND_UNIT.as_version_number%TYPE,
                        cp_unit_cd        IGS_AV_STND_UNIT.unit_cd%TYPE,
                        cp_un_vers_num    IGS_AV_STND_UNIT.version_number%TYPE) IS
                SELECT unit_cd,version_number,s_adv_stnd_recognition_type
                FROM    IGS_AV_STND_UNIT asu
                WHERE   asu.person_id                   = cp_person_id AND
                        asu.as_course_cd                = cp_course_cd AND
                        asu.as_version_number           = cp_crs_vers_num AND
                        asu.unit_cd                     = cp_unit_cd AND
                        asu.version_number              = cp_un_vers_num AND
                        asu.s_adv_stnd_recognition_type IN (cst_credit,
                                                            cst_preclusion) AND
                        asu.s_adv_stnd_granting_status  IN (cst_approved, cst_granted)
                        GROUP BY unit_cd,version_number,s_adv_stnd_recognition_type;
        CURSOR c_unit_version(
                        cp_unit_cd      IGS_PS_UNIT_VER.unit_cd%TYPE,
                        cp_version_number IGS_PS_UNIT_VER.version_number%TYPE) IS
                SELECT  repeatable_ind
                FROM    IGS_PS_UNIT_VER uv
                WHERE   uv.unit_cd = cp_unit_cd AND
                        uv.version_number = cp_version_number;
       l_credits                       NUMBER;
       l_s_adv_atnd_granting_status    igs_av_stnd_unit_all.s_adv_stnd_granting_status%TYPE;
  BEGIN
        -- This function validates a IGS_EN_SU_ATTEMPT in
        -- relation to advanced standing units.
        p_message_name := null;
        -- validate the input parameters
        IF (p_person_id IS NULL                      OR
                        p_course_cd IS NULL          OR
                        p_unit_cd IS NULL            OR
                        p_un_version_number IS NULL) THEN
                p_message_name := 'IGS_EN_NOTVALIDATE_ADVSTD';
                RETURN FALSE;
        END IF;
        -- get course version number if it isn't passed
        IF p_crs_version_number IS NULL THEN
                OPEN c_sca(
                        p_person_id,
                        p_course_cd);
                FETCH c_sca INTO v_crs_version_number;
                IF c_sca%NOTFOUND THEN
                        CLOSE c_sca;
                        p_message_name := 'IGS_EN_NOTVALIDATE_ADVSTD';
                        RETURN FALSE;
                ELSE
                        CLOSE c_sca;
                END IF;
        ELSE
                v_crs_version_number := p_crs_version_number;
        END IF;
        -- get unit version repeatable indicator
        v_repeatable_ind := 'N';
        OPEN c_unit_version(
                p_unit_cd,
                p_un_version_number);
        FETCH c_unit_version INTO v_repeatable_ind;
        CLOSE c_unit_version;
        -- check for the existace of IGS_AV_STND_UNIT
        FOR v_adv_stnd IN c_adv_stnd_unit_details(
                                        p_person_id,
                                        p_course_cd,
                                        v_crs_version_number,
                                        p_unit_cd,
                                        p_un_version_number) LOOP
                -- Changed after academic records maitenance dld
            IF v_Adv_stnd.s_adv_stnd_recognition_type = cst_credit THEN
                IF NOT igs_av_val_asu.adv_Credit_pts(p_person_id,p_course_cd,v_crs_version_number,
                                                 v_adv_stnd.unit_cd,v_adv_stnd.version_number,'BOTH',NULL,
                                                 l_credits,l_s_adv_atnd_granting_status,p_message_name) THEN

                                -- unit will still need to be studied if credit is less than 100
                                p_message_name := null;
                                RETURN TRUE;
                        ELSE
                                IF (l_s_adv_atnd_granting_status= cst_granted) THEN
                                        -- unit doens't need to be attempted by
                                        -- student because advanced standing has been
                                        -- granted
                                        IF v_repeatable_ind <> 'X' THEN
                                                -- Warning only
                                                p_message_name := 'IGS_AV_STUD_GRANTED_ADV';
                                                RETURN TRUE;
                                        ELSE
                                                p_message_name := 'IGS_EN_STUD_GRANTED_ADVSTD';
                                                RETURN FALSE;
                                END IF;
                        ELSIF (l_s_adv_atnd_granting_status <> cst_granted AND p_legacy <> 'Y' ) THEN
                                -- check that course version advanced
                                -- standing limits are not exceeded by
                                -- approved and granted advanced standing
                                IF (IGS_AV_VAL_ASU.advp_val_as_totals (
                                        p_person_id,
                                        p_course_cd,
                                        v_crs_version_number,
                                        TRUE, -- include approved advanced standing
                                        '', -- IGS_AV_STND_UNIT.unit_cd
                                        '', -- IGS_AV_STND_UNIT.version_number
                                        '', -- IGS_AV_STND_UNIT.s_adv_stnd_granting_status
                                        '', -- IGS_AV_STND_UNIT_LVL.unit_LEVEL
                                        '', -- IGS_AV_STND_UNIT_LVL.exemption_institution_cd
                                        '', -- IGS_AV_STND_UNIT_LVL.s_adv_stnd_granting_status
                                        v_total_exmptn_approved,
                                        v_total_exmptn_granted,
                                        v_total_exmptn_perc_grntd,
                                        v_message_name) = FALSE) THEN
                                        -- check for invalid parameters error
                                        IF (v_message_name <> 'IGS_AV_INSUFFICIENT_INFO_VER') THEN
                                                -- warn that approved advanced standing exists
                                                p_message_name := 'IGS_EN_STUD_APPROVED_ADVSTD';
                                                RETURN TRUE;
                                        END IF;
                                ELSE
                                        -- unit doesn't need to be attempted by student
                                        -- because approved advanced standing exists and is
                                        -- liekly to be granted with nightly process
                                        IF v_repeatable_ind <> 'X' THEN
                                                -- Warning only
                                                p_message_name := 'IGS_EN_STUD_APPROVED_ADVSTD';
                                                RETURN TRUE;
                                        ELSE
                                                p_message_name := 'IGS_EN_STUD_APPR_ADVSTD';
                                                RETURN FALSE;
                                        END IF;
                                END IF;

                        END IF;
                END IF;
            END IF;
        END LOOP;
        -- return the default message number and type
        p_message_name := null;
        RETURN TRUE;
  END;
  END enrp_val_sua_advstnd;
  --
  -- To validate the insertion of an sua against any intermissions
  FUNCTION ENRP_VAL_SUA_INTRMT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
  BEGIN
  DECLARE
        NO_SGCC_RECORDS_FOUND   EXCEPTION;
        v_census_dt_alias               IGS_GE_S_GEN_CAL_CON.census_dt_alias%TYPE;
        v_start_dt                      IGS_EN_STDNT_PS_INTM.start_dt%TYPE;
        v_end_dt                        IGS_EN_STDNT_PS_INTM.end_dt%TYPE;
        v_rec_found             BOOLEAN := FALSE;

        CURSOR c_census_dt IS
                SELECT  sgcc.census_dt_alias
                FROM    IGS_GE_S_GEN_CAL_CON sgcc
                WHERE   sgcc.s_control_num = 1;
        CURSOR c_sci_details
                        (cp_person_id   IGS_EN_SU_ATTEMPT.person_id%TYPE,
                         cp_course_cd   IGS_EN_SU_ATTEMPT.course_cd%TYPE) IS
                SELECT  sci.start_dt,
                        sci.end_dt,
			sci.cond_return_flag , sci.logical_delete_date
                FROM    IGS_EN_STDNT_PS_INTM sci,
                        IGS_EN_INTM_TYPES eit
                WHERE   sci.person_id = cp_person_id AND
                        sci.course_cd = cp_course_cd AND
                        sci.approved  = eit.appr_reqd_ind AND
                        eit.intermission_type = sci.intermission_type AND
                        sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY');

        CURSOR c_daiv_details
                        (cp_person_id IGS_EN_SU_ATTEMPT.person_id%TYPE,
			 cp_course_cd   IGS_EN_SU_ATTEMPT.course_cd%TYPE,
			 cp_cal_type    IGS_EN_SU_ATTEMPT.cal_type%TYPE,
                         cp_ci_seq_num  IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
			 cp_cond_ret_ind IGS_EN_STDNT_PS_INTM.cond_return_flag%TYPE,
                         cp_census_dt   IGS_GE_S_GEN_CAL_CON.census_dt_alias%TYPE,
                         cp_start_dt    IGS_EN_STDNT_PS_INTM.start_dt%TYPE,
                         cp_end_dt      IGS_EN_STDNT_PS_INTM.end_dt%TYPE,
			 cp_logical_del_dt IGS_EN_STDNT_PS_INTM.logical_delete_date%TYPE) IS
                SELECT  daiv.dt_alias
                FROM    IGS_CA_DA_INST_V daiv
                WHERE   daiv.cal_type           = cp_cal_type           AND
                        daiv.ci_sequence_number = cp_ci_seq_num         AND
                        daiv.dt_alias           = cp_census_dt          AND
                        daiv.alias_val          >= cp_start_dt          AND
                        (daiv.alias_val          <= cp_end_dt  OR
				(daiv.alias_val          >  cp_end_dt            AND
				   cp_cond_ret_ind = 'Y' AND
				   EXISTS ( SELECT 'x'
						FROM IGS_EN_SPI_RCONDS
						WHERE person_id =p_person_id
						AND course_cd =p_course_cd
						AND start_dt =cp_start_dt
						AND logical_delete_date =cp_logical_del_dt
						AND status_code IN('FAILED','PENDING')
					  )
				)
		        );

  BEGIN
        -- this module validates that the teaching perion of
        -- UA being added is permitted according to any
        -- intermission details which exist.
        -- The validation will fail if the census date (or any
        -- of the census dates if there are multiple) fall
        -- within the intermission person.
        -- note : this is not inclusive of the end date.
        -- set the default message number
        p_message_name := null;
        -- select the census date alias from the general
        -- calendar confiration table
        OPEN  c_census_dt;
        FETCH c_census_dt INTO v_census_dt_alias;
        -- raise an exception if no IGS_GE_S_GEN_CAL_CON
        -- records are found
        IF (c_census_dt%NOTFOUND) THEN
                CLOSE c_census_dt;
                RAISE NO_SGCC_RECORDS_FOUND;
        END IF;
        CLOSE c_census_dt;
        -- select the student course intermission records
        -- for the relevant course
        FOR v_sci_details IN c_sci_details(
                                p_person_id,
                                p_course_cd) LOOP
                -- looping through dt_alias_INST_V records
                FOR v_daiv_details IN c_daiv_details(
		                        p_person_id,
					p_course_cd,
                                        p_cal_type,
                                        p_ci_sequence_number,
					v_sci_details.cond_return_flag,
                                        v_census_dt_alias,
                                        v_sci_details.start_dt,
                                        v_sci_details.end_dt,
					v_sci_details.logical_delete_date) LOOP
                                -- set that a record was found
                                v_rec_found := TRUE;
                END LOOP;
        END LOOP;
        -- checking if record(s) were found
        -- if so, set the message number and return
        -- FALSE
        IF (v_rec_found = TRUE) THEN
                p_message_name := 'IGS_EN_CANT_ADD_UNT_ATMPTS';
                RETURN FALSE;
        END IF;
        -- the default return type
        RETURN TRUE;
  EXCEPTION
        WHEN NO_SGCC_RECORDS_FOUND THEN
                Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');

                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END;
  END enrp_val_sua_intrmt;

  -- Routine to clear records saved in a PL/SQL RECORD from a prior commit.
  PROCEDURE enrp_clear_sua_disc
  AS
  BEGIN
        -- initialise
        gt_sua_discont_table := gt_sua_discont_empty_table;
        gv_sua_discont_table_index := 1;
  END enrp_clear_sua_disc;

  --
  -- Validate the discontinued administrative unit status.
  FUNCTION enrp_val_discont_aus(
  p_administrative_unit_status IN VARCHAR2 ,
  p_discontinued_dt IN DATE ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2,
  p_uoo_id IN NUMBER ,
  p_message_token OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
        v_other_detail                  VARCHAR2(255);
        v_closed_ind                    IGS_AD_ADM_UNIT_STAT.closed_ind%TYPE;
        v_unit_attempt_status           IGS_AD_ADM_UNIT_STAT.unit_attempt_status%TYPE;
        v_alias_val                     DATE;
        v_admin_unit_status_str         VARCHAR2(2000);
        v_first_char                    NUMBER;
        v_grading_schema_cd             IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE;
        v_version_number                IGS_AS_GRD_SCHEMA.version_number%TYPE;
        v_message_name                  varchar2(30);
        v_string_found                  BOOLEAN  :=  FALSE;
        v_current_string                IGS_AD_ADM_UNIT_STAT.administrative_unit_status%TYPE;
        v_administrative_unit_status    VARCHAR2(2000);
        v_admin_entered                 IGS_AD_ADM_UNIT_STAT.administrative_unit_status%TYPE;
        CURSOR  c_aus IS
                SELECT  closed_ind,
                        unit_attempt_status
                FROM    IGS_AD_ADM_UNIT_STAT
                WHERE   administrative_unit_status = p_administrative_unit_status;
  BEGIN
        -- This module validates the
        -- IGS_EN_SU_ATTEMPT.administrative_unit_status
        p_message_name := null;
        -- Validate no administrative unit status
       OPEN  c_aus;
        FETCH c_aus INTO v_closed_ind, v_unit_attempt_status;
        -- check if a record has been found
        IF (c_aus%NOTFOUND) AND p_legacy <> 'Y' THEN
                CLOSE c_aus;
                RETURN TRUE;
        END IF;
        CLOSE c_aus;

        IF p_administrative_unit_status IS NULL THEN
                IF v_unit_attempt_status = 'DROPPED' THEN
                   RETURN TRUE;
                END IF;
                IF p_discontinued_dt IS NULL THEN
                        -- return with no errors
                        RETURN TRUE;
                ELSE
                        -- return the message number if discontinued date exists
                        p_message_name := 'IGS_EN_ADMIN_UNIT_ST_SPECIFY';
            IF p_legacy <> 'Y' THEN
                        RETURN FALSE;
            ELSE
                Fnd_Message.Set_Name('IGS', p_message_name  );
                FND_MSG_PUB.ADD;
            END IF;
                END IF;
        END IF;

         IF (v_closed_ind = 'Y' AND p_legacy <> 'Y' ) THEN
                -- return the message number if the closed_ind = 'Y'
                p_message_name := 'IGS_EN_ADM_UNT_STAT_CLOSED';
                RETURN FALSE;
        END IF;

        IF (v_unit_attempt_status <> 'DISCONTIN' AND p_legacy <> 'Y' ) THEN
                -- must be for DISCONTIN unit attempt status
                p_message_name := 'IGS_EN_SPECIFY_ADM_UNT_STATUS';
                RETURN FALSE;
        END IF;

        -- validate that if the discontinued date is not set,
        -- then the related administrative status is not set
        IF  (p_discontinued_dt IS NULL) AND
             (v_unit_attempt_status = 'DISCONTIN') THEN
                p_message_name := 'IGS_EN_DISCONT_ADM_UNIT_ST';
        IF p_legacy <> 'Y' THEN
                    RETURN FALSE;
        ELSE
            Fnd_Message.Set_Name('IGS', p_message_name  );
            FND_MSG_PUB.ADD;
        END IF;
        END IF;

        -- Validate that administrative unit status applies at discontinuation
        -- as determined by unit discontinuation date criteria
        --Modified as a part of Enrollment Process build bug no:1832130
        -- Sarakshi , 27-07-2001, uoo_id is  passed to IGS_EN_GEN_008.ENRP_GET_UDDC_AUS
IF p_legacy <> 'Y' THEN
        v_administrative_unit_status := IGS_EN_GEN_008.ENRP_GET_UDDC_AUS(
                                                p_discontinued_dt,
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                v_admin_unit_status_str,
                                                v_alias_val,
                        p_uoo_id);

        IF v_admin_unit_status_str IS NULL THEN
        p_message_name := 'IGS_EN_ADMIN_UNITST_NOTVALID';
        RETURN FALSE;
    ELSE
                -- set the parameter passed in to a variable
                v_admin_entered := p_administrative_unit_status;
                IF (v_administrative_unit_status IS NULL) OR
                  ((v_administrative_unit_status IS NOT NULL) AND
                   (v_admin_entered <> v_administrative_unit_status)) THEN
                -- Administrative unit status is not equal to the defaults
                -- so check against string returned which contains list of
                -- valid administrative unit status delimited by ',' eg
                -- EARLY WDRW, LATE WDRW,
                -- set the current position in the string to 1
                v_first_char := 1;
                v_administrative_unit_status := NULL;
                LOOP
                  -- exit when the end of the string is reached
                  EXIT WHEN v_first_char >= LENGTH(v_admin_unit_status_str);
                  -- put 10 characters at a a time into a string for comparison
                  v_current_string := (SUBSTR(v_admin_unit_status_str, v_first_char, 10));
                  -- don't do anything if the string is null
                  IF (v_current_string IS NULL) THEN
                     EXIT;
                  ELSE
                  -- if the parameter string entered is part of string
                  -- passed in, then exit - it's been found
                     IF (RPAD(v_admin_entered,10,' ') = RPAD(v_current_string,10,' ')) THEN
                         v_string_found := TRUE;
                         EXIT;
                     ELSE
                        -- continue seaching the next 11 characters
                        -- along in the string passed in (as we have
                        -- to account for the fact that the string
                        -- is delimited by ','
                        IF v_administrative_unit_status IS NULL THEN
                            v_administrative_unit_status := RTRIM(RPAD(v_current_string,10,' '));
                        ELSE
                            v_administrative_unit_status := v_administrative_unit_status||','||RTRIM(RPAD(v_current_string,10,' '));
                        END IF;
                            v_first_char := v_first_char + 11;
                     END IF;
                   END IF;
                END LOOP;
                -- return an error if the parameter string entered
                -- wasn't part of the string passed in
                IF (v_string_found = FALSE) THEN
                 --p_message_name := 'IGS_EN_ADMIN_UNITST_NOTVALID';
                   p_message_name := 'IGS_SS_EN_INVLD_ADMIN_UNITST';
                   p_message_token := v_administrative_unit_status;
                   RETURN FALSE;
                END IF;
             END IF;
          END IF;   --end for v_admin_unit_status_str IS NULL
        -- Both the administrative unit status and administrative unit status (out parameter) string are both null return false.
        IF  v_administrative_unit_status IS NULL AND v_admin_unit_status_str IS NULL THEN
           p_message_name := 'IGS_SS_EN_INVLD_ADMIN_UNITST';
           p_message_token := v_administrative_unit_status;
           RETURN FALSE;
    END IF;
END IF;

        -- validate administrative unit status grade
        IF (IGS_EN_VAL_SUA.enrp_get_sua_gs(
                        p_discontinued_dt,
                        p_administrative_unit_status,
                        v_grading_schema_cd,
                        v_version_number,
                        v_message_name) = FALSE) THEN
                p_message_name := v_message_name;
        IF p_legacy <> 'Y' THEN
                    RETURN FALSE;
        ELSE
            Fnd_Message.Set_Name('IGS', p_message_name  );
            FND_MSG_PUB.ADD;
        END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_discont_aus');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END;
  END enrp_val_discont_aus;
  --
  -- Get SUA grading schema.
  FUNCTION enrp_get_sua_gs(
  p_effective_dt IN DATE ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_version_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
        TYPE t_schema_dtls IS RECORD (
                grading_schema_cd       IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE,
                version_number          IGS_AS_GRD_SCHEMA.version_number%TYPE );
        CURSOR c_get_schema_dtls IS
                SELECT  DISTINCT gs.grading_schema_cd,
                        gs.version_number
                FROM    IGS_AS_GRD_SCHEMA gs,
                        IGS_AS_GRD_SCH_GRADE gsg,
                        IGS_AD_ADM_UT_STA_GD ausg
                WHERE   gs.start_dt <= TRUNC(p_effective_dt)   AND
                        (gs.end_dt IS NULL OR
                        gs.end_dt >= TRUNC(p_effective_dt))    AND
                        gsg.grading_schema_cd = gs.grading_schema_cd AND
                        gsg.version_number = gs.version_number AND
                        ausg.grade = gsg.grade AND
                        ausg.administrative_unit_status = p_administrative_unit_status;
        v_grading_schema_dtls           t_schema_dtls;
        CURSOR  c_aus IS
                SELECT  unit_attempt_status
                FROM    IGS_AD_ADM_UNIT_STAT
                WHERE   administrative_unit_status = p_administrative_unit_status;
                l_status VARCHAR2(10);
  BEGIN
        --- Set the default message number
        p_message_name := null;
        OPEN c_aus;
        FETCH c_aus INTO l_status;
        close c_aus;

        --- Select the effective grading schema.
        OPEN c_get_schema_dtls;
        FETCH c_get_schema_dtls INTO v_grading_schema_dtls;
        --- No match
        IF c_get_schema_dtls%NOTFOUND THEN
             IF l_status <> 'DROPPED' THEN
                p_grading_schema_cd := NULL;
                p_version_number := NULL;
                p_message_name := 'IGS_EN_CHK_ADM_UNT_STATUS';
                CLOSE c_get_schema_dtls;
                RETURN FALSE;
             END IF;
        END IF;
        --- One or more matches were found
        --- then return first one found
        p_grading_schema_cd := v_grading_schema_dtls.grading_schema_cd;
        p_version_number := v_grading_schema_dtls.version_number;
        p_message_name := null;
        CLOSE c_get_schema_dtls;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_get_sua_gs');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_get_sua_gs;
  --
  -- Get SUA administrative unit status grade.
  FUNCTION enrp_get_sua_ausg(
  p_administrative_unit_status  IN VARCHAR2 ,
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_effective_dt                IN DATE ,
  p_grading_schema_cd           OUT NOCOPY VARCHAR2 ,
  p_version_number              OUT NOCOPY NUMBER ,
  p_grade                       OUT NOCOPY VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN NUMBER)
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Added new parameter p_uoo_id to the function
  --                            Modified the c_no_ass_ind and c_sua_ausg cursors where clause due
  --                            to change in pk of student unit attempt table
  --                            w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
  BEGIN
  DECLARE

        v_ausg_count            NUMBER;
        v_dummy                     VARCHAR2 (1);
    l_no_assessment_ind  IGS_EN_SU_ATTEMPT.NO_ASSESSMENT_IND%TYPE;

    CURSOR c_no_ass_ind IS
        SELECT no_assessment_ind
        FROM igs_en_su_attempt
        WHERE person_id          = p_person_id
        AND   course_cd          = p_course_cd
        AND   uoo_id             = p_uoo_id;

        CURSOR  c_ausg_exists
                (cp_admin_unit_status
                        IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE) IS
                SELECT  'X'
                FROM    IGS_AD_ADM_UT_STA_GD ausg
                WHERE   ausg.administrative_unit_status = cp_admin_unit_status;

        CURSOR  c_ausg_count
                (cp_admin_unit_status    IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE,
                 cp_effective_dt         IGS_AS_GRD_SCHEMA.start_dt%TYPE,
                 cp_no_assessment_ind    IGS_EN_SU_ATTEMPT.NO_ASSESSMENT_IND%TYPE) IS
                SELECT  COUNT(*)
                FROM    igs_ad_adm_ut_sta_gd ausg,
                        igs_as_grd_schema gs,
                        igs_as_grd_sch_grade gsg
                WHERE   ausg.administrative_unit_status  =  cp_admin_unit_status  AND
                                gs.grading_schema_cd    =  ausg.grading_schema_cd AND
                                gs.version_number               =  ausg.version_number AND
                                TRUNC(gs.start_dt)		<= TRUNC(cp_effective_dt) AND
                                TRUNC(NVL(gs.end_dt, cp_effective_dt)) >= TRUNC(cp_effective_dt) AND
                ausg.grading_schema_cd  =  gsg.grading_schema_cd AND
                                ausg.version_number             =  gsg.version_number AND
                                ausg.GRADE = gsg.grade AND
                (
                  ( gsg.s_result_type = 'AUDIT' AND cp_no_assessment_ind ='Y')
                OR
                  ( gsg.s_result_type <> 'AUDIT' AND cp_no_assessment_ind <> 'Y')
                );

        CURSOR  c_ausg
                (cp_admin_unit_status    IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE,
                 cp_effective_dt         IGS_AS_GRD_SCHEMA.start_dt%TYPE,
                 cp_no_assessment_ind    IGS_EN_SU_ATTEMPT.NO_ASSESSMENT_IND%TYPE) IS
                SELECT  ausg.grading_schema_cd,
                        ausg.version_number,
                        ausg.grade
                FROM    igs_ad_adm_ut_sta_gd ausg,
                        igs_as_grd_schema gs,
                        igs_as_grd_sch_grade gsg
                WHERE   ausg.administrative_unit_status  =  cp_admin_unit_status  AND
                                gs.grading_schema_cd    =  ausg.grading_schema_cd AND
                                gs.version_number               =  ausg.version_number AND
                                gs.start_dt                     <= TRUNC(cp_effective_dt) AND
                                NVL(gs.end_dt, TRUNC(cp_effective_dt)) >= TRUNC(cp_effective_dt) AND
                ausg.grading_schema_cd  =  gsg.grading_schema_cd AND
                                ausg.version_number             =  gsg.version_number AND
                                ausg.GRADE = gsg.grade AND
                (
                  ( gsg.s_result_type = 'AUDIT' AND cp_no_assessment_ind ='Y')
                OR
                  ( gsg.s_result_type <> 'AUDIT' AND cp_no_assessment_ind <> 'Y')
                );

        CURSOR  c_sua_ausg
                (cp_admin_unit_status
                        IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE,
                 cp_effective_dt        IGS_AS_GRD_SCHEMA.start_dt%TYPE) IS
                SELECT  ausg.grading_schema_cd,
                                ausg.version_number,
                                ausg.grade
                FROM            IGS_EN_SU_ATTEMPT sua,
                                IGS_PS_UNIT_OFR_OPT uoo,
                                IGS_AD_ADM_UT_STA_GD ausg,
                                IGS_AS_GRD_SCHEMA gs,
                                igs_as_grd_sch_grade gsg
                WHERE           sua.person_id                   = p_person_id            AND
                                sua.course_cd                   = p_course_cd            AND
                                sua.uoo_id                      = p_uoo_id               AND
                                sua.unit_cd                     = uoo.unit_cd            AND
                                sua.version_number              = uoo.version_number     AND
                                sua.cal_type                    = uoo.cal_type           AND
                                sua.ci_sequence_number          = uoo.ci_sequence_number AND
                                sua.location_cd                 = uoo.location_cd        AND
                                sua.unit_class                  = uoo.unit_class         AND
                                uoo.grading_schema_cd           = ausg.grading_schema_cd AND
                                ausg.administrative_unit_status = cp_admin_unit_status   AND
                                gs.grading_schema_cd            = ausg.grading_schema_cd AND
                                gs.version_number               = ausg.version_number    AND
                                gs.start_dt                     <= cp_effective_dt       AND
                                NVL(gs.end_dt, cp_effective_dt) >= cp_effective_dt       AND
                                ausg.grading_schema_cd          =  gsg.grading_schema_cd AND
                                ausg.version_number             =  gsg.version_number    AND
                                ausg.GRADE                      =  gsg.grade             AND
                (
                  ( gsg.s_result_type = 'AUDIT' AND sua.no_assessment_ind ='Y')
                OR
                  ( gsg.s_result_type <> 'AUDIT' AND sua.no_assessment_ind <> 'Y')
                );
  BEGIN
        -- This module gets the administrative unit status
        -- grading schema grade.
        -- If only one current grading schema grade mapped to the
        -- administrative_unit_status then use this grade which can be
        -- apply to all students. If multiple mappings exist, then determine
        -- the appropriate grade for the student's unit.
        -- Initialise out NOCOPY parameters.
        p_grading_schema_cd     := NULL;
        p_version_number                := NULL;
        p_grade                 := NULL;
        p_message_name          := null;

    OPEN c_no_ass_ind;
    FETCH c_no_ass_ind INTO l_no_assessment_ind;
    CLOSE c_no_ass_ind;

        -- Determine how many current grades are mapped against the administrative
        -- unit status.
        OPEN c_ausg_count(
                        p_administrative_unit_status,
                        p_effective_dt,
            l_no_assessment_ind);
        FETCH c_ausg_count INTO v_ausg_count;
        IF c_ausg_count%NOTFOUND THEN
                v_ausg_count := 0;
        END IF;
        CLOSE c_ausg_count;
        IF v_ausg_count = 1 THEN
                OPEN c_ausg(p_administrative_unit_status,
                                p_effective_dt,
                l_no_assessment_ind);
                FETCH c_ausg INTO       p_grading_schema_cd,
                                        p_version_number,
                                        p_grade;
                IF c_ausg%FOUND THEN
                        -- Return the retrieved values.
                        CLOSE c_ausg;
                        p_message_name := null;
                        RETURN TRUE;
                END IF;
                CLOSE c_ausg;
        ELSIF v_ausg_count > 1 THEN
                OPEN c_sua_ausg(p_administrative_unit_status,
                                p_effective_dt);
                FETCH c_sua_ausg INTO   p_grading_schema_cd,
                                        p_version_number,
                                        p_grade;
                IF c_sua_ausg%FOUND THEN
                        -- Return the retrieved values.
                        CLOSE c_sua_ausg;
                        p_message_name := null;
                        RETURN TRUE;
                END IF;
                CLOSE c_sua_ausg;
        END IF;

        -- If processing reaches here, check if any grades exist for the
        -- administrative unit status. It is valid as some do not have associated
        -- grades (eg. When discontinuing early and no student unit attempt
        -- outcome is record because the student unit attempt is deleted).
        OPEN c_ausg_exists(p_administrative_unit_status);
        FETCH c_ausg_exists INTO        v_dummy;
        IF c_ausg_exists%FOUND THEN
                -- Error as the grading schema is not available
                -- for the effective date
                CLOSE c_ausg_exists;
                p_grading_schema_cd     := NULL;
                p_version_number                := NULL;
                p_grade                 := NULL;
                p_message_name          := 'IGS_EN_CANT_DETR_UNIT_STATUS';
                RETURN FALSE;
        ELSE
                -- no records were found, so set the grade
                -- to NULL (this is acceptable, as some
                -- administrative unit statuses don't have
                -- associated grades)
                CLOSE c_ausg_exists;
                p_grading_schema_cd     := NULL;
                p_version_number                := NULL;
                p_grade                 := NULL;
                p_message_name          := null;
                RETURN TRUE;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_get_sua_ausg');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END;
  END enrp_get_sua_ausg;
  --
  -- To validate the discontinuation date
  FUNCTION enrp_val_sua_discont(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_ci_start_dt IN DATE ,
  p_enrolled_dt IN DATE ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_discontinued_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

        v_unit_attempt_status   IGS_AD_ADM_UNIT_STAT.unit_attempt_status%TYPE;
        v_s_unit_status         IGS_AD_ADM_UNIT_STAT.unit_attempt_status%TYPE;
        v_course_attempt_status IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        CURSOR  c_uas IS
                SELECT  unit_attempt_status
                FROM    IGS_AD_ADM_UNIT_STAT
                WHERE   administrative_unit_status = p_administrative_unit_status;
        CURSOR  c_uvus IS
                SELECT   us.s_unit_status
                FROM    IGS_PS_UNIT_VER uv,
                        IGS_PS_UNIT_STAT us
                WHERE   uv.unit_cd        = p_unit_cd        AND
                        uv.version_number = p_version_number AND
                        us.unit_status    = uv.unit_status;
        CURSOR  c_cas IS
                SELECT  course_attempt_status
                FROM    IGS_EN_STDNT_PS_ATT
                WHERE   person_id = p_person_id AND
                        course_cd = p_course_cd;
  BEGIN
        -- This module validates the discontinued_dt from
        -- the IGS_EN_SU_ATTEMPT
        p_message_name := null;

        -- This validation should not be done for dropped unit attempts
        -- which are being enrolled again. The administrative status
        -- will be null only for a dropped unit attempt. If the unit
        -- attempt was discontinued then the administrative unit status
        -- cannot be null.
        IF  p_administrative_unit_status IS NULL AND p_legacy <> 'Y' THEN
          RETURN TRUE;
        END IF;

        IF (p_discontinued_dt IS NOT NULL) THEN
                -- validate that the discontinued_dt is
                -- less than or equal to today's date
                IF (TRUNC(p_discontinued_dt) > TRUNC(SYSDATE)) THEN
                        p_message_name := 'IGS_EN_SUA_DISCONT_FUTUREDT';
            IF p_legacy <> 'Y' THEN
                        RETURN FALSE;
            ELSE
                Fnd_Message.Set_Name('IGS', p_message_name  );
                FND_MSG_PUB.ADD;
            END IF;
                END IF;
                -- validate that the discontinued_dt is
                -- greater than or equal to the enrolled date
                IF (p_enrolled_dt IS NOT NULL AND
                    (TRUNC(p_discontinued_dt) < TRUNC(p_enrolled_dt))) THEN
                        p_message_name := 'IGS_EN_DISCONT_DT_GE_ENRDT';
                        IF p_legacy <> 'Y' THEN
                        RETURN FALSE;
            ELSE
                Fnd_Message.Set_Name('IGS', p_message_name  );
                FND_MSG_PUB.ADD;
            END IF;
                END IF;
        END IF;
        -- validate that if the discontinued date is set,
        -- then the unit attempt status must be enrolled
        IF (p_discontinued_dt IS NOT NULL AND
            p_unit_attempt_status NOT IN ('ENROLLED', 'DISCONTIN' , 'DUPLICATE', 'DROPPED') AND
        p_legacy <> 'Y' ) THEN
                p_message_name := 'IGS_EN_ENROL_SUA_DISCONT';
                RETURN FALSE;
        END IF;
        -- validate that if the discontinued date is not set,
        -- then the related administrative status is not set
        IF (p_discontinued_dt IS NULL AND
            p_administrative_unit_status IS NOT NULL AND p_legacy <> 'Y'  ) THEN
                OPEN  c_uas;
                FETCH c_uas INTO v_unit_attempt_status;
                CLOSE c_uas;
                IF (v_unit_attempt_status = 'DISCONTIN') THEN
                        p_message_name := 'IGS_EN_DISCONT_ADM_UNIT_ST';
                        RETURN FALSE;
                END IF;
        END IF;
        IF (p_discontinued_dt IS NULL and p_legacy <> 'Y') THEN
                -- validate that if the discontinued date is not set,
                -- then the unit version is active
                OPEN  c_uvus;
                FETCH c_uvus INTO v_s_unit_status;
                CLOSE c_uvus;
                IF (v_s_unit_status <> 'ACTIVE') THEN
                        p_message_name := 'IGS_EN_UNITVERSION_INACTIVE';
                        RETURN FALSE;
                END IF;
                -- validate that the course attempt status
                -- is enrolled, inactive or completed
                OPEN  c_cas;
                FETCH c_cas INTO v_course_attempt_status;
                CLOSE c_cas;
                IF (v_course_attempt_status NOT IN ('ENROLLED', 'INACTIVE', 'COMPLETED')) THEN
                        p_message_name := 'IGS_EN_SUA_NOT_DISCONT';
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_discont');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END;
  END enrp_val_sua_discont;
  --
  -- To validate enrolled date of SUA.
  FUNCTION enrp_val_sua_enr_dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_enrolled_dt IN DATE ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_ci_end_dt IN DATE ,
  p_commencement_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who     When            What
  --amuthu  02-APR-2002     defined the constant cst_waitlisted.
  --                        the validation was presently being bypassed for unconfirmed units
  --                        alone. Now waitlist status is also being added to it. bug 2335455
  --Nishikant 13-may-2002   Bug#2364216 Dropped case is also removed in the condition while checking for the Enrolled date
  --                        is null or not. If the status is DROPPED then no need to check the Enrolled date is null or not.
  -- bdeviset 13-JUL-2005   if the status is PLANNED then no need to check the Enrolled date is null or not.
  --                           for bug# 4377985 BUILD FOR EN317 SELF SERVICE ENHANCEMENTS
  -------------------------------------------------------------------------------------------

  BEGIN
  DECLARE
        cst_unconfirm           CONSTANT VARCHAR2(10) := 'UNCONFIRM';
        cst_discontin           CONSTANT VARCHAR2(10) := 'DISCONTIN';
        cst_waitlisted          CONSTANT VARCHAR2(10) := 'WAITLISTED';
        cst_dropped             CONSTANT VARCHAR2(10) := 'DROPPED'; -- Added by Nishikant - bug#2364216
        cst_planned             CONSTANT VARCHAR2(10) := 'PLANNED';
        v_sca_details           IGS_EN_STDNT_PS_ATT%ROWTYPE;

        CURSOR c_sca_details (
                        cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
                        cp_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE) IS
                SELECT  *
                FROM    IGS_EN_STDNT_PS_ATT
                WHERE   person_id = cp_person_id AND
                        course_cd = cp_course_cd;
  BEGIN
        -- Validate that the IGS_EN_SU_ATTEMPT.enrolled_dt must be set
        -- for all unit attempt statuses with the exception of UNCONFIRM
        -- Validate that IGS_EN_SU_ATTEMPT.enrolled_dt >=
        -- IGS_EN_STDNT_PS_ATT.commencement_dt.
        -- Validate that the student unit attempt enrolled date must
        -- be set for all unit attempt statuses, with the exception
        -- of UNCONFIRM.
        -- amuthu 02-APR-2002, Now adding the WAITLISED status also
        -- to the exceptions, since for a waitlist status also the
        -- the enrolled date will not be set. see bug 2335455

        -- Nishikant - Bug#bug#2364216 -- Dropped case is also removed in the condition
        -- If the status is DROPPED then no need to check the Enrolled date is null or not.
        -- if the status is PLANNED then no need to check the Enrolled date is null or not
        IF (p_enrolled_dt IS NULL
            AND p_unit_attempt_status <> cst_unconfirm
            AND p_unit_attempt_status <> cst_waitlisted
            AND p_unit_attempt_status <> cst_dropped
            AND p_unit_attempt_status <> cst_planned
        AND p_legacy <> 'Y' ) THEN
                p_message_name := 'IGS_GE_MANDATORY_FLD';
                RETURN FALSE;
        END IF;
        IF (p_enrolled_dt IS NOT NULL) THEN
                OPEN  c_sca_details (p_person_id,
                                     p_course_cd);
                FETCH c_sca_details INTO v_sca_details;
                -- check if a record was found
                IF (c_sca_details%NOTFOUND) THEN
                        p_message_name := null;
                        CLOSE c_sca_details;
                        RETURN TRUE;
                ELSE
                        CLOSE c_sca_details;
                        -- check the status of the student_confirmed_ind
                        IF (v_sca_details.student_confirmed_ind = 'N') THEN
                                p_message_name := 'IGS_EN_SUA_NOTENR_SPA';
                                RETURN FALSE;
                        ELSE
                                -- check that not enrolling when course attempt is discontinued
                                IF (v_sca_details.course_attempt_status = cst_discontin) THEN
                                        IF p_unit_attempt_status = cst_unconfirm AND p_legacy <> 'Y' THEN
                                                p_message_name := 'IGS_EN_SUA_NOT_ENROL';
                                                RETURN FALSE;
                                        END IF;
                                END IF;
                                -- Do not perform the following validation
                                -- for now
                                -- if p_commencement_dt is null, then
                                -- retrieve the value from the database
                                --IF (p_commencement_dt IS NULL) THEN
                                --      IF (v_sca_details.commencement_dt > p_enrolled_dt) THEN
                                --              p_message_name := 'IGS_EN_ENRDT_GE_SPA_COMMDT';
                                --              RETURN FALSE;
                                --      END IF;
                                --ELSE
                                --      IF (p_commencement_dt > p_enrolled_dt) THEN
                                --              p_message_name := 'IGS_EN_ENRDT_GE_SPA_COMMDT';
                                --              RETURN FALSE;
                                --      END IF;
                                --END IF;
                        END IF;
                END IF;
        END IF;
/* comment for bug 2344075 as per ray's suggestion
        IF (p_enrolled_dt IS NOT NULL AND p_enrolled_dt > p_ci_end_dt) THEN
                        p_message_name := 'IGS_EN_ENRDT_LE_UOO_TEACHPRD';
                        RETURN FALSE;
        END IF;
*/
        -- set the default message number and return type
        p_message_name := null;
        RETURN TRUE;
  END;
  END enrp_val_sua_enr_dt;
  --
  -- To validate SCA sub-units.

  --
  -- To validate deletion of the student unit attempt
 FUNCTION enrp_val_sua_delete(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_form_trigger_ind    IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_discontinued_dt     IN DATE ,
  p_effective_dt        IN DATE ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Removed the cur_uoo_IGS_EN_SU_ATTEMPT cursor and it's references
  --                            and modified the c_sut cursor where clause w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
  RETURN BOOLEAN AS
        gv_other_details        VARCHAR2(255);
  BEGIN -- enrp_val_sua_delete
        -- Validate the deletion of a IGS_EN_SU_ATTEMPT
  DECLARE
        cst_duplicate           IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'DUPLICATE';
        cst_discontinued        IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'DISCONTIN';
        cst_completed           IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'COMPLETED';
        cst_unconfirmed         IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'UNCONFIRM';
        cst_enrolled            IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'ENROLLED';
        cst_invalid             IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'INVALID';
        v_del_alwd_dt           DATE  :=  NULL;
        CURSOR c_sca IS
                SELECT  course_rqrmnt_complete_ind
                FROM    IGS_EN_STDNT_PS_ATT
                WHERE   person_id = p_person_id AND
                        course_cd = p_course_cd;
        v_course_rqrmnt_complete_ind
                IGS_EN_STDNT_PS_ATT.course_rqrmnt_complete_ind%TYPE  :=  NULL;
        CURSOR c_sut IS
                SELECT  'x'
                FROM    IGS_PS_STDNT_UNT_TRN
                WHERE   person_id               = p_person_id AND
                        transfer_course_cd      = p_course_cd AND
                        uoo_id                  = p_uoo_id;
        v_sut_found             VARCHAR2(1)  :=  NULL;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        -- Unconfirmed unit attempts can be deleted at any stage.
        IF p_unit_attempt_status = cst_unconfirmed OR
                        p_unit_attempt_status = cst_invalid THEN
                RETURN TRUE;
        END IF;
        -- Duplicate unit attempts cannot be deleted when the
        -- course requirements are completed
        IF p_unit_attempt_status = cst_duplicate THEN
                OPEN c_sca;
                FETCH c_sca INTO v_course_rqrmnt_complete_ind;
                IF (c_sca%FOUND) THEN
                        CLOSE c_sca;
                        IF (v_course_rqrmnt_complete_ind = 'Y') THEN
                                p_message_name := 'IGS_EN_DUPL_SUA_NOTDEL';
                                RETURN FALSE;
                        END IF;
                ELSE
                        CLOSE c_sca;
                END IF;
                -- Validate that the duplicate student unit attempt is
                -- not a duplicate in another course.
                OPEN c_sut;
                FETCH c_sut INTO v_sut_found;
                IF (c_sut%FOUND) THEN
                        CLOSE c_sut;
                        p_message_name := 'IGS_EN_DUPL_STUD_UNIT_ATTEMPT';
                        RETURN FALSE;
                END IF;
                CLOSE c_sut;
        END IF;
        -- Completed or discontinued unit attempts cannot be deleted
        IF  p_unit_attempt_status = cst_completed OR
                        p_unit_attempt_status = cst_discontinued  THEN
                p_message_name := 'IGS_EN_CANT_DEL_DISCONT_ATMPT';
                RETURN FALSE;
        END IF;

        -- Validate that delete is allowed as per unit
        -- unit discontinuation date criteria
        -- This validation cannot be performed in the trigger
        -- to cater before backdating of discontinuation date
        -- resulting in a delete (the discontinuation date is
        -- not available in delete trigger).
        IF p_unit_attempt_status = cst_enrolled THEN
                IF p_form_trigger_ind = 'F' THEN
                        IF p_discontinued_dt IS NOT NULL THEN
                                v_del_alwd_dt := p_discontinued_dt;
                        ELSE
                                v_del_alwd_dt := p_effective_dt;
                        END IF;
                        --Modified as a part of Enrollment Process build bug no:1832130
                        -- Sarakshi , 27-07-2001,one cursor is opened to fetch the uoo_id corresponding
                        -- to the pk of igs_en_su_attempt and passed to IGS_EN_GEN_008.ENRP_GET_UA_DEL_ALWD
                        IF IGS_EN_GEN_008.ENRP_GET_UA_DEL_ALWD(
                                p_cal_type,
                                p_ci_sequence_number,
                                v_del_alwd_dt,
                                p_uoo_id) = 'N' THEN
                                p_message_name := 'IGS_EN_CANT_DEL_STUD_UNIT';
                                RETURN FALSE;
                        END IF;
                END IF;
        END IF;
        --- Validate that for enrolled student_unit_attempts, the
        --- record can only be deleted in the record enrolments time frame.
        IF p_unit_attempt_status = cst_enrolled THEN
           --Modified as a part of Enrollment Process build bug no:1832130
           -- Sarakshi , 27-07-2001,one cursor is opened to fetch the uoo_id corresponding
           -- to the pk of igs_en_su_attempt and passed to igs_en_gen_008.enrp_get_var_window

           -- Modified the Next IF logic as per the Bug# 2356997. Made the
           -- call to the igs_en_gen_008.enrp_get_var_window instead of IGS_EN_GEN_004.ENRP_GET_REC_WINDOW
             IF igs_en_gen_008.enrp_get_var_window(
                                        p_cal_type,
                                        p_ci_sequence_number,
                                        p_effective_dt,
                                        p_uoo_id) = FALSE THEN
                        p_message_name := 'IGS_EN_CANT_DEL_ENRL_STUD_UNT';
                        RETURN FALSE;
             END IF;
        END IF;
        --- Return the default return value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_sca%ISOPEN) THEN
                        CLOSE c_sca;
                END IF;
                IF (c_sut%ISOPEN) THEN
                        CLOSE c_sut;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_delete');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_delete;
  --
  -- To validate insert of SUA.
  FUNCTION enrp_val_sua_insert(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
        gv_other_details                VARCHAR2(255);
  BEGIN
  DECLARE
        cst_discontin   CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE:= 'DISCONTIN';
        cst_lapsed      CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'LAPSED';
        cst_unconfirm   CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'UNCONFIRM';
        cst_completed   CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'COMPLETED';
        cst_duplicate   CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'DUPLICATE';
        CURSOR c_sca IS
                SELECT  sca.course_attempt_status
                FROM    IGS_EN_STDNT_PS_ATT     sca
                WHERE   sca.person_id = p_person_id AND
                        sca.course_cd = p_course_cd;
        v_course_attempt_status         IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  BEGIN
        --- Set the default message number
        p_message_name := null;
        --- Get the course attempt status
        OPEN c_sca;
        FETCH c_sca INTO v_course_attempt_status;
        IF c_sca%NOTFOUND THEN
                CLOSE c_sca;
                RETURN TRUE;
        END IF;
        CLOSE c_sca;
        -- Validate against status of IGS_EN_STDNT_PS_ATT
        IF (v_course_attempt_status =  cst_discontin) THEN
                IF (p_unit_attempt_status <> cst_duplicate) THEN
                        p_message_name := 'IGS_EN_CANT_INS_STUD_UNT_ATMP';
                        RETURN FALSE;
                END IF;
        END IF;
        IF (v_course_attempt_status = cst_lapsed) THEN
                p_message_name := 'IGS_EN_CANT_INS_STUD_UNT_ATMP';
                RETURN FALSE;
        END IF;
        IF (v_course_attempt_status = cst_unconfirm) THEN
                IF (p_unit_attempt_status <> cst_unconfirm) THEN
                        p_message_name := 'IGS_EN_UNCONF_SUA_INSERTED';
                        RETURN FALSE;
                END IF;
        END IF;
        IF (v_course_attempt_status = cst_completed) THEN
                IF (p_unit_attempt_status = cst_duplicate) THEN
                        p_message_name := 'IGS_EN_DUPL_SUA_NOTINS';
                        RETURN FALSE;
                END IF;
        END IF;
        --  Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_sca%ISOPEN) THEN
                        CLOSE c_sca;
                END IF;
                RAISE;
  END;
  END enrp_val_sua_insert;
  --
  -- Validate the confirmation of a student unit attempt.
  FUNCTION ENRP_VAL_SUA_CNFRM(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number  NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ci_end_dt IN DATE ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_enrolled_dt IN DATE ,
  p_fail_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Impacted object, due to change in the signature of igs_en_val_sua.enrp_val_sua_dupl
  --                            of the function w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------

  BEGIN -- enrp_val_sua_cnfrm
        -- Perform all validations associated with the confirmation of a unit
        -- attempt for a student. This module is a grouping of existing
        -- validation modules.
        -- Performs the following modules:
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_insert;
        --      determine if the student is of the correct status to have
        --      a unit attempt added.
        -- Call IGS_EN_VAL_ENCMB.enrp_val_excld_unit;
        --      determine if the student is currently excluded from the unit.
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_advstnd;
        --      determine if the student has already satisfied the unit
        --      through advanced standing.
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_intrmt;
        --      determine if the attempt overlaps an existing period of
        --      intermission.
        -- Call IGS_EN_VAL_SUA.enrp_val_coo_loc;
        --      determine if the attempt is in line with students forced
        --      location (if applicable).
        -- Call IGS_EN_VAL_SUA.enrp_val_coo_mode;
        --      determine if the attemt is in line with students forced
        --      mode (if applicable).
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_enr_dt;
        --      validate the enrolled date.
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_ci;
        --      validate that the teaching period of the unit is not prior to
        --      the commencement date of the student course attempt.
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_dupl;
        --      determine if the student is already enrolled concurrently in the
        --      unit or has completed the unit with a pass or incomplete result type.
        -- Call IGS_EN_VAL_SUA.resp_val_sua_cnfrm;
        --       validate if attempting to confirm a research unit attempt.
        -- The current set of fail types are:
        -- course       The course isn?t in a correct state. ie.
        --              Discontinued or intermitted for the teaching period.
        -- ENCUMB       Excluded from the unit by either course/unit or person encumbrances
        -- ADVSTAND     Already granted in advanced standing
        -- CROSS        Breaches a cross-element restriction
        -- ENROLDT      Enrolment date invalid
        -- TEACHING     Teaching Period  invalid
        -- DUPLICATE    Already enrolled or completed unit attempt
  DECLARE
        cst_enrolled            CONSTANT VARCHAR2(10) := 'ENROLLED';
        cst_course              CONSTANT VARCHAR2(10) := 'course';
        cst_encumb              CONSTANT VARCHAR2(10) := 'ENCUMB';
        cst_advstand            CONSTANT VARCHAR2(10) := 'ADVSTAND';
        cst_cross               CONSTANT VARCHAR2(10) := 'CROSS';
        cst_enroldt             CONSTANT VARCHAR2(10) := 'ENROLDT';
        cst_teaching            CONSTANT VARCHAR2(10) := 'TEACHING';
        cst_duplicate           CONSTANT VARCHAR2(10) := 'DUPLICATE';
        CURSOR c_sca IS
                SELECT  sca.version_number,
                        sca.coo_id,
                        sca.commencement_dt
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   person_id       = p_person_id AND
                        course_cd       = p_course_cd;
        CURSOR c_sua IS
               SELECT uoo_id
               FROM igs_ps_unit_ofr_opt
               WHERE unit_cd            = p_unit_cd
               AND   version_number     = p_uv_version_number
               AND   cal_type           = p_cal_type
               AND   ci_sequence_number = p_ci_sequence_number
               AND   location_cd        = p_location_cd
               AND   unit_class         = p_unit_class;

        l_uoo_id                igs_en_su_attempt.uoo_id%TYPE;
        v_sca_rec               c_sca%ROWTYPE;
        v_return_val            BOOLEAN  :=  FALSE;
        v_message_name          varchar2(30);
        v_duplicate_course_cd   VARCHAR2(6);
  BEGIN
        -- Set the  :=  message number
        p_message_name := null;
        p_fail_type := NULL;
        OPEN c_sua;
        FETCH c_sua INTO l_uoo_id;
        CLOSE c_sua;
        -- Determine if the student is of the correct status to have a unit attempt
        -- added.
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_insert(
                                        p_person_id,
                                        p_course_cd,
                                        cst_enrolled,
                                        v_message_name) THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the attempt overlaps an existing period of intermission.
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_intrmt(
                                                p_person_id,
                                                p_course_cd,
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                v_message_name) THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
        END IF;
        -- Validate research unit attempt
        IF NOT IGS_EN_VAL_SUA.resp_val_sua_cnfrm(
                                                p_person_id,
                                                p_course_cd,
                                                p_unit_cd,
                                                p_uv_version_number,
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                v_message_name ,
                        'N' ) THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type :=  cst_course;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the student is currently excluded from the unit
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_excld(
                                                p_person_id,
                                                p_course_cd,
                                                p_unit_cd,
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                v_message_name) THEN
                p_fail_type := cst_encumb;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_encumb;
                p_message_name := v_message_name;
        END IF;
        -- Fetch student course attempt details
        OPEN c_sca;
        FETCH c_sca INTO v_sca_rec;
        CLOSE c_sca;
        -- Determine if the student has already satisfied the unit through advanced
        -- standing.
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_advstnd(
                                                p_person_id,
                                                p_course_cd,
                                                v_sca_rec.version_number,
                                                p_unit_cd,
                                                p_uv_version_number,
                                                v_message_name ,
                        'N' ) THEN
                p_fail_type := cst_advstand;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_advstand;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the attempt is in line with students
        -- forced location (if applicable).
        IF NOT IGS_EN_VAL_SUA.enrp_val_coo_loc(
                                        v_sca_rec.coo_id,
                                        p_location_cd,
                                        v_message_name) THEN
                p_fail_type := cst_cross;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_cross;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the attempt is in line with students forced mode (if
        -- applicable).
        IF NOT IGS_EN_VAL_SUA.enrp_val_coo_mode(
                                        v_sca_rec.coo_id,
                                        p_unit_class,
                                        v_message_name) THEN
                p_fail_type := cst_cross;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_cross;
                p_message_name := v_message_name;
        END IF;
        -- Validate the enrolled date.
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_enr_dt(
                                                p_person_id,
                                                p_course_cd,
                                                p_enrolled_dt,
                                                cst_enrolled,
                                                p_ci_end_dt,
                                                v_sca_rec.commencement_dt,
                                                v_message_name ,
                        'N' ) THEN
                p_fail_type := cst_enroldt;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL  THEN
                p_fail_type := cst_enroldt;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the student unit attempt has a teaching period
        -- which is prior to the commencement date of the student course attempt
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_ci(
                                        p_person_id,
                                        p_course_cd,
                                        p_cal_type,
                                        p_ci_sequence_number,
                                        'ENROLLED',
                                        v_sca_rec.commencement_dt,
                                        'F',    -- commencement date is known
                                        v_message_name) THEN
                p_fail_type := cst_teaching;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_teaching;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the student unit attempt already exists as
        -- enrolled or completed with pass or incomplete result
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_dupl(
                                        p_person_id,
                                        p_course_cd,
                                        p_unit_cd,
                                        p_uv_version_number,
                                        p_cal_type,
                                        p_ci_sequence_number,
                                        cst_enrolled,   -- unit_attempt_status when confirming
                                        v_duplicate_course_cd,
                                        v_message_name,
                                        l_uoo_id) THEN
                p_fail_type := cst_duplicate;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_duplicate;
                p_message_name := v_message_name;
        END IF;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                RAISE;
  END;
  END enrp_val_sua_cnfrm;
  --
  -- Validate the course against a posted change to student unit attempt.
  FUNCTION ENRP_VAL_SUA_CNFRM_P(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2,
  p_course_version IN NUMBER,
  p_coo_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_uoo_id    IN NUMBER,
  p_fail_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 ,
  p_message_name2 OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
   -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur      04-dec-2003   as part of the holds bug the procedure that checks student ecumbrances
  --                            IGS_EN_VAL_ENCMB.enrp_val_enr_encmb is being modified to consider only term calendar.
  --                            Hence modifying the call to this procedure to pass the load calendars under the
  --                            superior acad calendar in reference.
  --ckasu        17-Nov-2004    modfied the procedure inorder to consider enrollment Category setup
  --                            for checking the Forced location, attendance mode as apart of Program
  --                            Transfer Build#4000939
  --amuthu       18-May-2006    Removed the holds validation call from here. The logic for the same has been
  --                            moved to IGS_EN_TRANSFER_APIS.check_for_holds.
   -------------------------------------------------------------------------------------------

  BEGIN -- enrp_val_sua_cnfrm_p
        -- Perform all post-commit (or post) validations to a given student unit
        -- attempt. This module is a grouping of existing validation modules.
        -- Performs the following modules:
        -- Call IGS_EN_VAL_SUA.resp_val_sua_all to check any research unit related
        --      issues.
        -- Call IGS_EN_VAL_ENCMB.enrp_val_enr_encmb to check that the student hasn't
        --      breached any encumbrance restrictions (eg. max cp).
        -- Call IGS_EN_VAL_SCA.enrp_val_coo_att to ensure that the student is in line
        --      with their forced attendance mode.
        --               -- Call enrp_val_unit_rule.{rulp_val_coreq,rulp_val_incomp,rulp_val_prereq}
        --      to check all unit rules - these unit attempts should be rejected
        --      outright, and not set to Invalid.
        --   as part of the holds bug the procedure that checks student ecumbrances IGS_EN_VAL_ENCMB.enrp_val_enr_encmb
        --    is being modified to consider only term calendar. Hence modifying the call to this procedure
        --    to pass the load calendars under the superior calendars in reference.
  DECLARE
        cst_research            CONSTANT VARCHAR2(10) := 'RESEARCH';
        cst_cross               CONSTANT VARCHAR2(10) := 'CROSS';
        cst_superior            CONSTANT VARCHAR2(10) := 'SUPERIOR';
        v_message_name          varchar2(30);

       CURSOR c_get_teach_cal_dtls(cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
                                   cp_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                                   cp_uoo_id       IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
          SELECT cal_type,ci_sequence_number
          FROM IGS_EN_SU_ATTEMPT
          WHERE person_id = cp_person_id AND
                course_cd = cp_course_cd AND
                uoo_id    = cp_uoo_id;

       CURSOR c_get_load_cal_dtls(cp_teach_cal_type    IGS_CA_INST.cal_type%TYPE,
                                  cp_teach_cal_seq_num IGS_CA_INST.sequence_number%TYPE) IS
           SELECT load_cal_type,load_ci_sequence_number
           FROM  IGS_CA_TEACH_TO_LOAD_V
           WHERE teach_cal_type = cp_teach_cal_type AND
                 teach_ci_sequence_number = cp_teach_cal_seq_num ;


       l_person_type   igs_pe_person_types.person_type_code%TYPE;
       l_enr_meth_type igs_en_method_type.enr_method_type%TYPE;
       l_enr_category          VARCHAR2(20);
       l_enr_comm_type         VARCHAR2(2000);
       l_enrolment_cat         IGS_AS_SC_ATMPT_ENR.enrolment_cat%TYPE;
       l_enr_cal_type          IGS_AS_SC_ATMPT_ENR.cal_type%TYPE;
       l_enr_cal_seq_num       IGS_AS_SC_ATMPT_ENR.ci_sequence_number%TYPE;
       l_enr_method_type       IGS_EN_METHOD_TYPE.enr_method_type%TYPE;
       l_dummy                 VARCHAR2(255);
       l_notification_flag     IGS_EN_CPD_EXT.notification_flag%TYPE;
       l_teach_cal_type         IGS_CA_INST.cal_type%TYPE;
       l_teach_cal_seq_num      IGS_CA_INST.sequence_number%TYPE;
       l_load_cal_type         IGS_CA_INST.cal_type%TYPE;
       l_load_cal_seq_num      IGS_CA_INST.sequence_number%TYPE;
       l_message_name           FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
       l_message_name1          FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
       l_message_name2          FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
       l_return_status          VARCHAR2(10);
       l_status                 BOOLEAN;

  BEGIN
        p_fail_type := NULL;
        p_message_name := null;
        p_message_name2 := null;
        --  Check research unit related issues
        IF IGS_EN_VAL_SUA.resp_val_sua_all(
                                        p_person_id,
                                        p_course_cd,
                                        p_cal_type,
                                        p_ci_sequence_number,
                                        v_message_name) = FALSE THEN
                p_fail_type := cst_research;
                p_message_name := v_message_name;
                RETURN FALSE;
        ELSE
                IF v_message_name <> NULL THEN
                        p_fail_type := cst_research;
                        p_message_name := v_message_name;
                END IF;
        END IF;
        -- Determine if the student is of the correct status to have a unit attempt
        -- added.


-- code added by ckasu as a part of Program transfer build bug#4000939

   l_person_type  := IGS_EN_GEN_008.enrp_get_person_type(NULL);

  --get enrolment method type

   igs_en_gen_017.enrp_get_enr_method(p_enr_method_type => l_enr_method_type,
                                      p_error_message   => l_message_name,
                                      p_ret_status      => l_return_status);

  -- getting enrolment category , commencement type

   l_enr_category := IGS_EN_GEN_003.enrp_get_enr_cat( p_person_id => p_person_id,
                                                      p_course_cd => p_course_cd,
                                                      p_cal_type => p_cal_type,
                                                      p_ci_sequence_number => p_ci_sequence_number ,
                                                      p_session_enrolment_cat =>NULL,
                                                      p_enrol_cal_type => l_enr_cal_type        ,
                                                      p_enrol_ci_sequence_number => l_enr_cal_seq_num,
                                                      p_commencement_type => l_enr_comm_type,
                                                      p_enr_categories  => l_dummy );

   l_notification_flag := igs_ss_enr_details.get_notification(
                                       p_person_type         => l_person_type,
                                       p_enrollment_category => l_enr_category,
                                       p_comm_type           => l_enr_comm_type,
                                       p_enr_method_type     => l_enr_method_type,
                                       p_step_group_type     => 'UNIT',
                                       p_step_type           => 'FLOC_CHK',
                                       p_person_id           => p_person_id,
                                       p_message             => l_message_name);

   OPEN c_get_teach_cal_dtls(p_person_id,p_course_cd,p_uoo_id);
   FETCH c_get_teach_cal_dtls INTO l_teach_cal_type,l_teach_cal_seq_num;
   IF c_get_teach_cal_dtls%FOUND THEN
     CLOSE c_get_teach_cal_dtls;
     OPEN c_get_load_cal_dtls(l_teach_cal_type,l_teach_cal_seq_num);
     FETCH c_get_load_cal_dtls INTO l_load_cal_type,l_load_cal_seq_num;
     CLOSE c_get_load_cal_dtls;
   ELSE
     CLOSE c_get_teach_cal_dtls;
   END IF; -- end of c_get_teach_cal_dtls%FOUND IF THEN

   IF l_notification_flag IS NOT NULL THEN

       l_status := IGS_EN_ELGBL_UNIT.eval_unit_forced_location(p_person_id,
                                                               l_load_cal_type,
                                                               l_load_cal_seq_num,
                                                               p_uoo_id,
                                                               p_course_cd,
                                                               p_course_version,
                                                               l_message_name1,
                                                               l_notification_flag,
                                                               'JOB' -- parameter for calling_obj column
                                                               );
      IF l_notification_flag = 'DENY' AND l_message_name1 IS NOT NULL THEN
         p_message_name := l_message_name1;
         RETURN FALSE;
      END IF;

  END IF;

  l_notification_flag := igs_ss_enr_details.get_notification(
                                       p_person_type         => l_person_type,
                                       p_enrollment_category => l_enr_category,
                                       p_comm_type           => l_enr_comm_type,
                                       p_enr_method_type     => l_enr_method_type,
                                       p_step_group_type     => 'UNIT',
                                       p_step_type           => 'FATD_MODE',
                                       p_person_id           => p_person_id,
                                       p_message             => l_message_name);



  IF l_notification_flag IS NOT NULL THEN

      l_status := IGS_EN_ELGBL_UNIT.eval_unit_forced_mode (p_person_id,
                                                           l_load_cal_type,
                                                           l_load_cal_seq_num,
                                                           p_uoo_id,
                                                           p_course_cd,
                                                           p_course_version,
                                                           l_message_name2,
                                                           l_notification_flag,
                                                           'JOB' -- parameter for calling_obj column
                                                           );
      IF l_notification_flag = 'DENY' AND l_message_name2 IS NOT NULL THEN
         p_message_name := l_message_name2;
         RETURN FALSE;
      END IF;

  END IF;


-- end of code added by ckasu as a part of Program transfer build bug#4000939

   RETURN TRUE;

  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_cnfrm_p');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_cnfrm_p;
  --
  -- To validate SUA override credit point values
  -- New parameter p_uoo_id is added w.r.t. bug num: 2375757  by kkillams
  FUNCTION enrp_val_sua_ovrd_cp(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_achievable_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_message_name OUT NOCOPY varchar2,
  p_uoo_id IN NUMBER,
  p_no_assessment_ind IN VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN -- enrp_val_sua_ovrd_cp
        -- Validate the override credit point and EFTSU values against the
        -- constraints set in the IGS_PS_UNIT_VER table.
  DECLARE
        v_points_override_ind           IGS_PS_UNIT_VER.points_override_ind%TYPE;
        v_points_min                    IGS_PS_UNIT_VER.points_min%TYPE;
        v_points_max                    IGS_PS_UNIT_VER.points_max%TYPE;
        v_points_increment              IGS_PS_UNIT_VER.points_increment%TYPE;
        CURSOR  c_uv IS
                SELECT  uv.points_override_ind,
                        uv.points_min,
                        uv.points_max,
                        uv.points_increment
                FROM    IGS_PS_UNIT_VER uv
                WHERE   unit_cd         = p_unit_cd AND
                        version_number  = p_version_number;
       --New cursor is added w.r.t. bug 2375757 by kkillams
       --To get the details override credit points at unit section level
       CURSOR c_usv IS
              SELECT usv.minimum_credit_points,
                     usv.maximum_credit_points,
                     usv.variable_increment
              FROM   IGS_PS_USEC_CPS usv
              WHERE  usv.uoo_id         = p_uoo_id;

  BEGIN
        p_message_name := NULL;
        -- If none of the override values are set then there is no validation to occur.
        IF p_override_enrolled_cp IS NULL AND
                        p_override_achievable_cp        IS NULL AND
                        p_override_eftsu                IS NULL THEN
                RETURN TRUE;
        END IF;
        -- Select details from unit version.
        OPEN c_uv;
        FETCH c_uv INTO v_points_override_ind,
                        v_points_min,
                        v_points_max,
                        v_points_increment;
        IF (c_uv%NOTFOUND) THEN
                CLOSE c_uv;
                RETURN TRUE;
        END IF;
        CLOSE c_uv;
        -- If override points not allowed return error.
        IF v_points_override_ind = 'N' THEN
                p_message_name := 'IGS_EN_OVERRIDE_EFTSU_VALUES';
                RETURN FALSE;
        ELSE
             --If min and max credit points defined at unit section level
             --than override the values w.r.t bug no# 2375757 by kkillams
            IF p_uoo_id IS NOT NULL THEN
               OPEN  c_usv;
               FETCH c_usv INTO v_points_min,
                                v_points_max,
                                v_points_increment;
               CLOSE c_usv;
            END IF;
        END IF;

        -- If override cp is set and not in accordance with unit version ranges.
        IF p_override_enrolled_cp IS NOT NULL THEN
                IF p_override_enrolled_cp < v_points_min OR
                                p_override_enrolled_cp > v_points_max OR
                                ( MOD(p_override_enrolled_cp, v_points_increment) <> MOD(v_points_min, v_points_increment) ) THEN
                        p_message_name := 'IGS_EN_OVERRIDE_ENR_CREDITPNT';
                        RETURN FALSE;
                END IF;
        END IF;
        -- If override achievable cp is set and not in accordance with unit version
        --  ranges.
        IF p_override_achievable_cp IS NOT NULL THEN
      -- added as part of ENCR026 if the unit is an audit unit and the achievable CP is zero
      -- then should the acheivable CP should not be validated.
      IF        NOT       (NVL(p_no_assessment_ind,'N') = 'Y' AND p_override_achievable_cp = 0) THEN
                IF p_override_achievable_cp < v_points_min OR
                                p_override_achievable_cp > v_points_max OR
                                MOD (p_override_achievable_cp, v_points_increment) <> 0 THEN
                        p_message_name := 'IGS_EN_OVERRIDE_ACHCRD_POINT';
                        RETURN FALSE;
                END IF;
      END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_uv%ISOPEN) THEN
                        CLOSE c_uv;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_ovrd_cp');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_ovrd_cp;
  --
  -- To validate SUA rule waived date.
  FUNCTION enrp_val_sua_rule_wv(
  p_rule_waived_dt IN DATE ,
  p_enrolled_dt IN DATE ,
  p_rule_waived_person_id IN OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS


  BEGIN
  BEGIN
        --- Set the default message number
        p_message_name := null;


        --- Check that rule waived date is greater than the enrolled date if it exists
        IF p_enrolled_dt IS NOT NULL AND p_rule_waived_dt < TRUNC(p_enrolled_dt) THEN
                p_message_name := 'IGS_EN_RULE_WAV_DT_GE_ENRL_DT';
                RETURN FALSE;
        END IF;
        --- Return the default value
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_rule_wv');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_rule_wv;

  --
  -- To validate SUA unit offering option.
  FUNCTION enrp_val_sua_uoo(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS
        gv_other_details                VARCHAR2(255);
  BEGIN
  DECLARE
        CURSOR c_get_uv_status IS
                SELECT  IGS_PS_UNIT_STAT.s_unit_status
                FROM    IGS_PS_UNIT_VER,
                        IGS_PS_UNIT_STAT
                WHERE   IGS_PS_UNIT_VER.unit_cd = p_unit_cd             AND
                        IGS_PS_UNIT_VER.version_number = p_version_number       AND
                        IGS_PS_UNIT_STAT.unit_status = IGS_PS_UNIT_VER.unit_status;
        CURSOR c_val_uoo IS
                SELECT  offered_ind
                FROM    IGS_PS_UNIT_OFR_OPT
                WHERE   unit_cd = p_unit_cd                             AND
                        version_number = p_version_number               AND
                        cal_type = p_cal_type                           AND
                        ci_sequence_number = p_ci_sequence_number       AND
                        location_cd = p_location_cd                     AND
                        unit_class = p_unit_class;
        cst_no                  IGS_PS_UNIT_OFR_OPT.offered_ind%TYPE     :=  'N';
        cst_active              IGS_PS_UNIT_STAT.s_unit_status%TYPE              :=  'ACTIVE';
    cst_inactive                IGS_PS_UNIT_STAT.s_unit_status%TYPE              :=  'INACTIVE';
        v_uv_status             IGS_PS_UNIT_STAT.s_unit_status%TYPE;
        v_offered_ind           IGS_PS_UNIT_OFR_OPT.offered_ind%TYPE;
  BEGIN
        --- Set the default message number
        p_message_name := null;
        --- Validate that the unit version is ACTIVE.
        OPEN c_get_uv_status;
        FETCH c_get_uv_status INTO v_uv_status;
        IF c_get_uv_status%NOTFOUND THEN
        IF p_legacy <> 'Y' THEN
                    CLOSE c_get_uv_status;
                    RETURN TRUE;
        END IF ;
        END IF;
        CLOSE c_get_uv_status;
        IF v_uv_status <> cst_active THEN
        IF p_legacy <> 'Y' THEN
            p_message_name := 'IGS_EN_UNITVERSION_INACTIVE';
                    RETURN FALSE;
        ELSIF v_uv_status <> cst_inactive AND p_legacy = 'Y' THEN
            p_message_name := 'IGS_EN_UNITVERSION_INACTIVE';
            Fnd_Message.Set_name('IGS','IGS_EN_UNITVERSION_INACTIVE');
                    FND_MSG_PUB.ADD;
            END IF ;
        END IF;
        --- Validate that the unit offering option is offered.
        OPEN c_val_uoo;
        FETCH c_val_uoo INTO v_offered_ind;
        IF c_val_uoo%NOTFOUND THEN
                CLOSE c_val_uoo;
                RETURN TRUE;
        END IF;
        CLOSE c_val_uoo;
        IF v_offered_ind = cst_no THEN
                p_message_name := 'IGS_EN_STUD_UNT_OFF_NOT_AVALA';
        IF p_legacy <> 'Y' THEN
                        RETURN FALSE;
                ELSE
                    Fnd_Message.Set_name('IGS',p_message_name );
                    FND_MSG_PUB.ADD;
        END IF;
        END IF;
        --- Set the default return value
        RETURN TRUE;
  END;
  EXCEPTION
  WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_uoo');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sua_uoo;
  --
  -- To validate sca location code against coo restriction
  FUNCTION ENRP_VAL_COO_LOC(
  p_coo_id IN NUMBER ,
  p_unit_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
  BEGIN
  DECLARE
        v_coo_rec_found         BOOLEAN;
        v_unit_mode             IGS_AS_UNIT_CLASS.unit_mode%TYPE;
        v_s_unit_mode           IGS_AS_UNIT_MODE.s_unit_mode%TYPE;
        v_govt_attend_mode      IGS_EN_ATD_MODE.govt_attendance_mode%TYPE;
        v_other_detail  VARCHAR(255);
        CURSOR  c_coo(
                        cp_coo_id IGS_EN_STDNT_PS_ATT.coo_id%TYPE) IS
                SELECT  *
                FROM    IGS_PS_OFR_OPT
                WHERE   IGS_PS_OFR_OPT.coo_id = cp_coo_id
                AND     IGS_PS_OFR_OPT.delete_flag = 'N';
  BEGIN
        -- This module validates the nominated unit location code against
        -- course_offering_option location code for the enrolled course
        p_message_name := null;
        v_coo_rec_found := FALSE;
        FOR v_coo_rec IN c_coo(p_coo_id) LOOP
                v_coo_rec_found := TRUE;
                IF v_coo_rec.forced_location_ind = 'Y' THEN
                        IF (p_unit_location_cd<> v_coo_rec.location_cd) THEN
                                p_message_name := 'IGS_EN_UNT_LOC_CONFLICTS';
                                RETURN FALSE;
                        END IF;
                END IF;
        END LOOP;
        IF(NOT v_coo_rec_found) THEN
                RETURN TRUE;
        END IF;
        RETURN TRUE;
  END;
  END enrp_val_coo_loc;
  --
  -- To validate the sca att mode against coo restriction
  FUNCTION ENRP_VAL_COO_MODE(
  p_coo_id IN NUMBER ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean AS
  BEGIN
  DECLARE
        v_coo_rec_found         BOOLEAN;
        v_unit_mode             IGS_AS_UNIT_CLASS.unit_mode%TYPE;
        v_s_unit_mode           IGS_AS_UNIT_MODE.s_unit_mode%TYPE;
        v_govt_attend_mode      IGS_EN_ATD_MODE.govt_attendance_mode%TYPE;
        v_other_detail  VARCHAR(255);
        CURSOR  c_coo(
                        cp_coo_id IGS_EN_STDNT_PS_ATT.coo_id%TYPE) IS
                SELECT  *
                FROM    IGS_PS_OFR_OPT
                WHERE   IGS_PS_OFR_OPT.coo_id = cp_coo_id
                AND     IGS_PS_OFR_OPT.delete_flag = 'N';
        CURSOR  c_unit_class(
                        cp_unit_class IGS_EN_SU_ATTEMPT.unit_class%TYPE) IS
                SELECT  unit_mode
                FROM    IGS_AS_UNIT_CLASS
                WHERE   IGS_AS_UNIT_CLASS.unit_class = cp_unit_class AND IGS_AS_UNIT_CLASS.closed_ind = 'N';
        CURSOR  c_unit_mode(
                        cp_unit_mode IGS_AS_UNIT_CLASS.unit_mode%TYPE) IS
                SELECT  s_unit_mode
                FROM    IGS_AS_UNIT_MODE
                WHERE   IGS_AS_UNIT_MODE.unit_mode = cp_unit_mode;
        CURSOR  c_attend_mode(
                        cp_attend_mode IGS_EN_ATD_MODE.attendance_mode%TYPE) IS
                SELECT  govt_attendance_mode
                FROM    IGS_EN_ATD_MODE
                WHERE   IGS_EN_ATD_MODE.attendance_mode = cp_attend_mode;
  BEGIN
        -- This module validates the nominated unit class against
        -- course_offering_option attandance mode for the enrolled course
        p_message_name := null;
        v_coo_rec_found := FALSE;
        FOR v_coo_rec IN c_coo(p_coo_id) LOOP
                v_coo_rec_found := TRUE;
                IF v_coo_rec.forced_att_mode_ind = 'Y' THEN
                        OPEN c_unit_class(
                                        p_unit_class);
                        FETCH c_unit_class INTO v_unit_mode;
                        CLOSE c_unit_class;
                        OPEN c_unit_mode(
                                        v_unit_mode);
                        FETCH c_unit_mode INTO v_s_unit_mode;
                        CLOSE c_unit_mode;
                        OPEN c_attend_mode(
                                        v_coo_rec.attendance_mode);
                        FETCH c_attend_mode INTO v_govt_attend_mode;
                        CLOSE c_attend_mode;
                        IF v_s_unit_mode = 'ON' THEN
                                IF (v_govt_attend_mode <> '1' AND
                                    v_govt_attend_mode <> '3') THEN
                                        p_message_name := 'IGS_EN_UNIT_CD_CONFLICTS';
                                        RETURN FALSE;
                                END IF;
                        ELSIF v_s_unit_mode = 'OFF' THEN
                                IF (v_govt_attend_mode <> '2' AND
                                    v_govt_attend_mode <> '3') THEN
                                        p_message_name := 'IGS_EN_UNIT_CD_CONFLICTS';
                                        RETURN FALSE;
                                END IF;
                        END IF;
                END IF;
        END LOOP;
        IF(NOT v_coo_rec_found) THEN
                RETURN TRUE;
        END IF;
        RETURN TRUE;
  END;
  END enrp_val_coo_mode;
  --

  --
  -- To validate for student unit attempt being duplicated
 FUNCTION enrp_val_sua_dupl(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_uv_version_number   IN NUMBER ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_duplicate_course_cd OUT NOCOPY VARCHAR2 ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  -- enrp_val_sua_dupl
  -- This module validates that enrolled student unit attempt:
  -- * does not already exist for the student in any of their course attempts,
  --   is enrolled and being studied concurrently. note: Allow for duplicate if
  --   student_course_transfer between the two course attempts.
  -- This module warns if:
  -- * the unit attempt has already been  completed in any of the course
  --   attempts of the student with a s_result_type of ?PASS? or ?INCOMPLETE?.
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Added new parameter p_uoo_id to the function
  --                            Modified the c_sua cursor  where clause due
  --                            to change in pk of student unit attempt table
  --                            w.r.t. bug number 2829262
  -- rvivekan   09-sep-2003     Modified the behaviour of repeatable_ind column
  --                           in igs_ps_unit_ver table. PSP integration build #3052433
  -- ckasu      28-NOV-2005     modified  v_message_name  <> NULL to v_message_name  IS NOT NULL
  --                            as a partof bug #4666102
  -------------------------------------------------------------------------------------------

  BEGIN
  DECLARE
        cst_enrolled            CONSTANT VARCHAR2(10) := 'ENROLLED';
        cst_completed           CONSTANT VARCHAR2(10) := 'COMPLETED';
        cst_discontin           CONSTANT VARCHAR2(10) := 'DISCONTIN';
        cst_pass                CONSTANT VARCHAR2(10) := 'PASS';
        cst_incomp              CONSTANT VARCHAR2(10) := 'INCOMP';
        CURSOR c_daiv (
                cp_cal_type             IGS_CA_DA_INST_V.cal_type%TYPE,
                cp_ci_sequence_number   IGS_CA_DA_INST_V.ci_sequence_number%TYPE) IS
                SELECT  UNIQUE(daiv.alias_val)  alias_val
                FROM    IGS_CA_DA_INST_V        daiv,
                        IGS_GE_S_GEN_CAL_CON            sgcc
                WHERE   daiv.cal_type           = cp_cal_type AND
                        daiv.ci_sequence_number = cp_ci_sequence_number AND
                        daiv.dt_alias           = sgcc.census_dt_alias AND
                        sgcc.s_control_num      = 1;
        CURSOR c_sua(cp_location_cd IGS_EN_SU_ATTEMPT.LOCATION_CD%TYPE,
                     cp_unit_class  IGS_EN_SU_ATTEMPT.UNIT_CLASS%TYPE)IS
                SELECT  sua.course_cd,
                        sua.cal_type,
                        sua.ci_sequence_number,
                        sua.unit_attempt_status,
                        sua.uoo_id
                FROM    IGS_EN_SU_ATTEMPT sua
                WHERE   sua.person_id           = p_person_id AND
                        sua.unit_cd             = p_unit_cd AND
                        sua.version_number      = p_uv_version_number AND
                        sua.location_cd         = cp_location_cd AND
                        sua.unit_class          = cp_unit_class AND
                        (sua.course_cd          <> p_course_cd OR
                        sua.cal_type            <> p_cal_type OR
                        sua.ci_sequence_number  <> p_ci_sequence_number) AND
                        sua.unit_attempt_status IN (cst_enrolled,
                                                    cst_completed,
                                                    cst_discontin);
         CURSOR c_sua_d IS
                SELECT  sua.location_cd,
                        sua.unit_class
                FROM    IGS_EN_SU_ATTEMPT sua
                WHERE   sua.person_id           = p_person_id AND
                        sua.course_cd           = p_course_cd AND
                        sua.uoo_id              = p_uoo_id;
        CURSOR c_sct (
                cp_course_cd            IGS_PS_STDNT_TRN.transfer_course_cd%TYPE) IS
                SELECT  'x'
                FROM    IGS_PS_STDNT_TRN sct
                WHERE   sct.person_id           = p_person_id AND
                        sct.course_cd           = p_course_cd AND
                        sct.transfer_course_cd  = cp_course_cd;
        CURSOR c_uv IS
                SELECT  uv.repeatable_ind
                FROM    IGS_PS_UNIT_VER uv
                WHERE   uv.unit_cd              = p_unit_cd AND
                        uv.version_number       = p_uv_version_number;
        v_sct_exists            VARCHAR2(1);
        TYPE r_alias_val_record_type IS RECORD(
                alias_val               IGS_CA_DA_INST_V.alias_val%TYPE);
        r_alias_val_record      r_alias_val_record_type;
        TYPE    t_alias_val_type IS TABLE OF r_alias_val_record%TYPE
                INDEX BY BINARY_INTEGER;
        v_alias_val_table       t_alias_val_type;
        v_alias_val_index       BINARY_INTEGER  :=  0;
        v_index                 BINARY_INTEGER  :=  0;
        v_av_found              BOOLEAN  :=  FALSE;
        v_message_name          VARCHAR2(30);
        rec_sua_d               c_sua_d%ROWTYPE;
        v_s_result_type         IGS_LOOKUPS_VIEW.lookup_code%TYPE  :=  NULL;
        v_outcome_dt            IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
        v_grading_schema_cd     IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
        v_gs_version_number     IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
        v_grade                 IGS_AS_GRD_SCH_GRADE.grade%TYPE;
        v_mark                  IGS_AS_SU_STMPTOUT.mark%TYPE;
        v_origin_course_cd      IGS_AS_SU_STMPTOUT.course_cd%TYPE;
        v_repeatable_ind        IGS_PS_UNIT_VER.repeatable_ind%TYPE;
        v_duplicate_course_cd   IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  BEGIN
        -- Set the default message number and duplicate course code
        p_message_name := null;
        p_duplicate_course_cd := NULL;
        IF p_unit_attempt_status = cst_enrolled THEN
                -- Determine if the unit version is not repeatable
                OPEN c_uv;
                FETCH c_uv INTO v_repeatable_ind;
                IF (c_uv%NOTFOUND) THEN
                        CLOSE c_uv;
                        RETURN TRUE;
                END IF;
                CLOSE c_uv;
                -- Determine census date(s) in unit teaching period
                FOR v_daiv_rec IN c_daiv(
                                        p_cal_type,
                                        p_ci_sequence_number) LOOP
                        -- add a new record to the exceptions table
                        v_alias_val_index := v_alias_val_index + 1;
                        v_alias_val_table(v_alias_val_index).alias_val := v_daiv_rec.alias_val;
                END LOOP;       -- v_daiv_rec IN c_daiv

                OPEN c_sua_d;
                FETCH c_sua_d INTO rec_sua_d;
                CLOSE c_sua_d;
                FOR v_sua_rec IN c_sua(rec_sua_d.location_cd,
                                       rec_sua_d.unit_class)
                LOOP
                        IF v_sua_rec.unit_attempt_status = cst_enrolled THEN
                                -- Determine if another enrolled attempt exists
                                -- for this unit across all course attempts for the student
                                IF v_sua_rec.cal_type = p_cal_type AND
                                   v_sua_rec.ci_sequence_number = p_ci_sequence_number THEN
                                        -- Check that this isn't a result of a course Transfer,
                                        -- and is therefore valid
                                        OPEN c_sct(
                                                v_sua_rec.course_cd);
                                        FETCH c_sct INTO v_sct_exists;
                                        IF c_sct%NOTFOUND THEN
                                                -- unit is currently being studied against another course
                                                CLOSE c_sct;
                                                v_duplicate_course_cd := v_sua_rec.course_cd;
                                                v_message_name := 'IGS_EN_UNITVER_CURR_ATTEMPTED';
                                                EXIT;
                                        END IF;
                                        CLOSE c_sct;
                                        -- Continue processing
                                ELSE
                                        -- Determine if the matched unit is being studied concurrently
                                        -- Determine census date(s) in matched teaching period
                                        -- and check if same date value exists for the matched unit
                                        FOR v_daiv_rec IN c_daiv(
                                                                v_sua_rec.cal_type,                                                                                                     v_sua_rec.ci_sequence_number) LOOP
                                                v_index := 0;
                                                v_av_found := FALSE;
                                                WHILE v_index < v_alias_val_index AND
                                                                NOT v_av_found  LOOP
                                                        v_index := v_index + 1;
                                                        IF v_alias_val_table(v_index).alias_val =
                                                                                        v_daiv_rec.alias_val THEN
                                                                v_av_found := TRUE;
                                                        END IF;
                                                END LOOP;
                                                IF v_av_found THEN
                                                        v_duplicate_course_cd := v_sua_rec.course_cd;
                                                        v_message_name := 'IGS_EN_UNITVER_CURR_ATTEMPTED';
                                                        EXIT;
                                                END IF;
                                        END LOOP;       -- v_daiv_rec IN c_daiv2
                                END IF;
                        END IF;
                        IF v_message_name  IS NOT NULL THEN
                                EXIT;
                        END IF;
                        IF v_sua_rec.unit_attempt_status IN (cst_completed,
                                                             cst_discontin) THEN
                                IF v_repeatable_ind = 'X' THEN
                                    OPEN c_sct(v_sua_rec.course_cd);
                                    FETCH c_sct INTO v_sct_exists;
                                    IF c_sct%NOTFOUND THEN
                                        CLOSE c_sct;
                                        -- Continue processing
                                        -- Warn if the unit version is not repeatable
                                        -- and the unit has already been completed with
                                        -- a result type of pass or incomplete
                                        v_s_result_type := IGS_AS_GEN_003.ASSP_GET_SUA_OUTCOME(p_person_id,
                                                                                               v_sua_rec.course_cd,
                                                                                               p_unit_cd,
                                                                                               v_sua_rec.cal_type,
                                                                                               v_sua_rec.ci_sequence_number,
                                                                                               v_sua_rec.unit_attempt_status,
                                                                                               'N',    -- finalised indicator
                                                                                               v_outcome_dt,
                                                                                               v_grading_schema_cd,
                                                                                               v_gs_version_number,
                                                                                               v_grade,
                                                                                               v_mark,
                                                                                               v_origin_course_cd,
                                                                                               v_sua_rec.uoo_id,
--added by LKAKI---
                                                                                               'N');
                                        IF v_s_result_type = cst_pass THEN
                                                v_duplicate_course_cd := v_sua_rec.course_cd;
                                                v_message_name := 'IGS_EN_UNITVER_STUD_PASSED';
                                                EXIT;
                                        ELSIF v_s_result_type = cst_incomp THEN
                                                v_duplicate_course_cd := v_sua_rec.course_cd;
                                                v_message_name := 'IGS_EN_UNITVER_INCOMPL_RESULT';
                                                EXIT;
                                        END IF;
                                    ELSE
                                        CLOSE c_sct;
                                    END IF;


                                END IF;
                        END IF;
                END LOOP;       -- v_sua_rec IN c_sua
        END IF;
        IF v_message_name IS NOT NULL THEN
                p_duplicate_course_cd := v_duplicate_course_cd;
                p_message_name := v_message_name;
                IF v_message_name IN ('IGS_EN_UNITVER_INCOMPL_RESULT',
                                        'IGS_EN_UNITVER_STUD_PASSED') THEN
                        RETURN TRUE;
                END IF;
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_uv%ISOPEN THEN
                        CLOSE c_uv;
                END IF;
                IF c_daiv%ISOPEN THEN
                        CLOSE c_daiv;
                END IF;
                IF c_sua%ISOPEN THEN
                        CLOSE c_sua;
                END IF;
                IF c_sct%ISOPEN THEN
                        CLOSE c_sct;
                END IF;
                RAISE;
  END;
  END enrp_val_sua_dupl;

  PROCEDURE enr_sub_units(
p_person_id           IN NUMBER ,
p_course_cd           IN VARCHAR2 ,
p_uoo_id              IN NUMBER,
p_waitlist_flag       IN VARCHAR2,
p_load_cal_type       IN VARCHAR2,
p_load_seq_num        IN NUMBER,
p_enrollment_date     IN DATE ,
p_enrollment_method   IN VARCHAR2,
p_enr_uoo_ids         IN VARCHAR2,
p_uoo_ids             OUT NOCOPY VARCHAR2,
p_waitlist_uoo_ids     OUT NOCOPY VARCHAR2,
p_failed_uoo_ids      OUT NOCOPY VARCHAR2) AS
-------------------------------------------------------------------------------------------
--Created by  : Satya Vanukuri, Oracle IDC
  --Date created: 13-oct-2003
  -- Purpose : Created as part of  placements build .
  --procedure enrolls subordinate unit sections that are marked as default enroll
  --if the student is attempting superior unit section
  --if a subordinate units section is explicitly selected by the user along with the superior units
  --then no other sub units are enrolled
  -------------------------------------------------------------------------------------------
        CURSOR cur_sup is
        SELECT 1 FROM IGS_PS_UNIT_OFR_OPT
        WHERE uoo_id = p_uoo_id
        AND relation_type = 'SUPERIOR' ;

        l_check_sup NUMBER(1);

        TYPE sub_ref_cur IS REF CURSOR;
        cur_sub sub_ref_cur;
        cur_sub1 sub_ref_cur;
        sub_stmt VARCHAR2(1000);

        sub_stmt1 VARCHAR2(1000);

        CURSOR get_sub_usecs IS
        SELECT  * FROM IGS_PS_UNIT_OFR_OPT
        WHERE sup_uoo_id = p_uoo_id AND
        default_enroll_flag = 'Y' AND
        relation_type = 'SUBORDINATE';

        CURSOR cur_person_number IS
        SELECT party_number from hz_parties
        WHERE party_id = p_person_id;

        l_sub_id igs_ps_unit_ofr_opt.uoo_id%TYPE;
         l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE;
        l_unit_section_status  igs_ps_unit_ofr_opt.unit_section_status%TYPE;
        l_waitlist_ind VARCHAR2(1);
        l_return_status VARCHAR2(1);
        l_err_message VARCHAR2(1000);
        l_message_name VARCHAR2(1000);
        l_person_number IGS_PE_PERSON.person_number%TYPE;
        l_enroll BOOLEAN;
BEGIN
       sub_stmt := 'SELECT uoo_id FROM IGS_PS_UNIT_OFR_OPT WHERE sup_uoo_id = :p_uoo_id AND
       relation_type = ''SUBORDINATE'' AND  uoo_id in ('||p_enr_uoo_ids||')';

       sub_stmt1 := 'SELECT uoo_id FROM IGS_PS_UNIT_OFR_OPT WHERE sup_uoo_id = :p_uoo_id AND
        relation_type = ''SUBORDINATE'' AND  uoo_id = :1';

        p_uoo_ids := NULL;
        p_waitlist_uoo_ids := NULL;
        p_failed_uoo_ids   := NULL;
        l_check_sup := NULL;


     --Check whether context unit section is a superior unit attempt
        OPEN cur_sup;
        FETCH cur_sup INTO l_check_sup;
        CLOSE cur_sup;


        IF l_check_sup IS  NULL THEN
        RETURN;

        ELSE
          IF p_enr_uoo_ids IS NOT NULL THEN
        --then check whether anyone of uoo_ids in the list p_enr_uoo_ids is  subordinate to the context uoo_id
                IF(INSTR(p_enr_uoo_ids,',',1) = 0) THEN
                     l_uoo_id := TO_NUMBER(p_enr_uoo_ids);
                     OPEN cur_sub1 for sub_stmt1 using p_uoo_id,l_uoo_id;
                     FETCH cur_sub1 INTO l_sub_id;
                     CLOSE cur_sub1;
                ELSE

                     OPEN cur_sub FOR sub_stmt using p_uoo_id;
                     FETCH cur_sub INTO l_sub_id;
                     CLOSE cur_sub;
                END IF;

                 IF l_sub_id IS NOT NULL THEN
                 RETURN;
                END IF;
          END IF;
        END IF;
      --none of the sub units have been chosen, hence select all the sub units that have default enroll set


          FOR sub_usecs_rec IN get_sub_usecs LOOP
             l_enroll := TRUE;
             l_message_name := NULL;
             --call api to validate enrollment window
              IF NOT IGS_EN_GEN_004.ENRP_GET_REC_WINDOW(
                sub_usecs_rec.cal_type,
               sub_usecs_rec.ci_sequence_number,
                nvl(p_enrollment_date,SYSDATE),
                sub_usecs_rec.uoo_id,
                l_message_name)   THEN

                  IF p_failed_uoo_ids IS NOT NULL THEN
                      p_failed_uoo_ids := p_failed_uoo_ids ||','||sub_usecs_rec.uoo_id;
                  ELSE
                    p_failed_uoo_ids := sub_usecs_rec.uoo_id;
                  END IF;


               ELSE
                     --call api to validate variation window
                         IF NOT IGS_EN_GEN_008.ENRP_GET_VAR_WINDOW(
                           sub_usecs_rec.cal_type,
                           sub_usecs_rec.ci_sequence_number,
                           nvl(p_enrollment_date,SYSDATE),
                           sub_usecs_rec.uoo_id)  THEN

                              IF p_failed_uoo_ids IS NOT NULL THEN
                              p_failed_uoo_ids := p_failed_uoo_ids ||','||sub_usecs_rec.uoo_id;
                              ELSE
                              p_failed_uoo_ids := sub_usecs_rec.uoo_id;
                              END IF;

                         ELSE
                                 l_unit_section_status := NULL;
                                 l_waitlist_ind := NULL;
                         --check seat availibility for sub unit
                                 igs_en_gen_015.get_usec_status(
                                     p_uoo_id                     =>   sub_usecs_rec.uoo_id,
                                     p_person_id                  =>   p_person_id,
                                     p_unit_section_status        =>  l_unit_section_status,
                                     p_waitlist_ind               =>  l_waitlist_ind,
                                     p_load_cal_type              =>  p_load_cal_type,
                                     p_load_ci_sequence_number    =>  p_load_seq_num,
                                     p_course_cd                  =>  p_course_cd) ;

                                 IF l_waitlist_ind IS  NULL THEN
                                      IF p_failed_uoo_ids IS NOT NULL THEN
                                       p_failed_uoo_ids := p_failed_uoo_ids ||','||sub_usecs_rec.uoo_id;
                                       ELSE
                                       p_failed_uoo_ids := sub_usecs_rec.uoo_id;
                                     END IF;

                                 ELSE
                                        IF l_waitlist_ind = 'Y' AND p_waitlist_flag = 'Y' THEN
                                           l_enroll := FALSE;
                                            IF p_failed_uoo_ids IS NOT NULL THEN
                                               p_failed_uoo_ids := p_failed_uoo_ids ||','||sub_usecs_rec.uoo_id;
                                             ELSE
                                               p_failed_uoo_ids := sub_usecs_rec.uoo_id;
                                             END IF;
                                         END IF;
                                    IF l_enroll THEN
                                         l_return_status := NULL;
                                         l_err_message := NULL;

                                         OPEN cur_person_number;
                                         FETCH cur_person_number INTO l_person_number;
                                         CLOSE cur_person_number;
                               SAVEPOINT enrwksht;
                                     --create unconfirm/waitlist sub unit attmepts
                                       BEGIN
                                         igs_ss_en_wrappers.insert_into_enr_worksheet(
                                          p_person_number           =>l_person_number,
                                          p_course_cd               => p_course_cd,
                                          p_uoo_id                  => sub_usecs_rec.uoo_id,
                                          p_waitlist_ind            => l_waitlist_ind,
                                          p_session_id              => NULL,
                                          p_return_status           => l_return_status,
                                          p_message                 => l_err_message,
                                          p_cal_type                => p_load_cal_type,
                                          p_ci_sequence_number      => p_load_seq_num,
                                          p_audit_requested         => 'N',
                                          p_enr_method              => p_enrollment_method,
                                          p_override_cp             => null,
                                          p_subtitle                => null,
                                          p_gradsch_cd              => null,
                                          p_gs_version_num          => null,
                                          p_calling_obj             =>'JOB'
                                          );
                                       EXCEPTION WHEN OTHERS THEN
                                         l_return_status := 'D';
                                       END;


                                       IF l_return_status <> 'D' THEN --implies success

                                                IF l_waitlist_ind = 'Y' THEN --implies unit was waitlisted.

                                                        IF p_waitlist_uoo_ids IS NOT NULL THEN
                                                              p_waitlist_uoo_ids := p_waitlist_uoo_ids ||','||sub_usecs_rec.uoo_id;
                                                        ELSE
                                                              p_waitlist_uoo_ids := sub_usecs_rec.uoo_id;
                                                         END IF;
                                                ELSIF l_waitlist_ind = 'N' THEN --implies unit was preenrolled

                                                         IF p_uoo_ids IS NOT NULL THEN
                                                             p_uoo_ids := p_uoo_ids||','||sub_usecs_rec.uoo_id;
                                                          ELSE
                                                             p_uoo_ids := sub_usecs_rec.uoo_id;
                                                         END IF;
                                                END IF;
                                       ELSE --implies unit was not preenrolled or waitlisted.
                                              ROLLBACK to enrwksht;
                                                 IF p_failed_uoo_ids IS NOT NULL THEN
                                                    p_failed_uoo_ids := p_failed_uoo_ids ||','||sub_usecs_rec.uoo_id;
                                                  ELSE
                                                    p_failed_uoo_ids := sub_usecs_rec.uoo_id;
                                                   END IF;
                                       END IF;
                                END IF; -- l_enroll
                            END IF; --l_waitlst_ind  NULL

                         END IF; --IGS_EN_GEN_008.ENRP_GET_VAR_WINDOW
              END IF; --IF IGS_EN_GEN_004.ENRP_GET_REC_WINDOW
          END LOOP;
EXCEPTION
        WHEN OTHERS THEN
                IF cur_sup%ISOPEN THEN
                        CLOSE cur_sup;
                END IF;
                IF cur_sub%ISOPEN THEN
                        CLOSE cur_sub;
                END IF;
                IF cur_sub1%ISOPEN THEN
                        CLOSE cur_sub1;
                END IF;
                IF get_sub_usecs%ISOPEN THEN
                        CLOSE get_sub_usecs;
                END IF;
                 IF cur_person_number%ISOPEN THEN
                        CLOSE cur_person_number;
                END IF;
                RAISE;


END enr_sub_units;

PROCEDURE drop_sub_units(
p_person_id         IN      NUMBER,
p_course_cd         IN      VARCHAR2,
p_uoo_id            IN      NUMBER,
p_load_cal_type     IN      VARCHAR2,
p_load_seq_num      IN      NUMBER,
p_acad_cal_type     IN      VARCHAR2,
p_acad_seq_num      IN      NUMBER,
p_enrollment_method IN      VARCHAR2,
p_confirmed_ind     IN      VARCHAR2,
p_person_type       IN      VARCHAR2,
p_effective_date    IN      DATE,
p_course_ver_num    IN      NUMBER,
p_dcnt_reason_cd    IN      VARCHAR2,
p_admin_unit_status IN      VARCHAR2,
p_uoo_ids           OUT  NOCOPY   VARCHAR2,
p_error_message     OUT  NOCOPY   VARCHAR2) As

  -------------------------------------------------------------------------------------------
  --Created by  : Satya Vanukuri, Oracle IDC
  --Date created: 13-oct-2003
  -- Purpose : Created as part of  placements build .
  -- procedure drops subordinate unit sections if the student is dropping superior unit section
  --    who         when           what
  --    ckasu       25-APR-2006    Modfied as a part of bug#5191592.
  -------------------------------------------------------------------------------------------
        CURSOR cur_sup is
        SELECT 1 FROM IGS_PS_UNIT_OFR_OPT
        WHERE uoo_id = p_uoo_id
        AND relation_type = 'SUPERIOR' ;

        l_check_sup NUMBER(1);

        CURSOR cur_sub_sua IS
        SELECT sua.uoo_id sub_uoo_id
        FROM IGS_EN_SU_ATTEMPT sua, IGS_PS_UNIT_OFR_OPT uoo
        WHERE sua.person_id = p_person_id AND
        sua.course_cd = p_course_cd AND
        sua.uoo_id = uoo.uoo_id AND
        uoo.sup_uoo_id = p_uoo_id AND
        uoo.relation_type = 'SUBORDINATE' ;

        CURSOR cur_coo_id is
        SELECT sca.coo_id
        FROM igs_en_stdnt_ps_att sca
        WHERE sca.person_id = p_person_id
        AND sca.course_cd = p_course_cd;

        l_coo_id igs_en_stdnt_ps_att.coo_id%TYPE;

        l_sub_sua IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
        l_ovrrd_chk VARCHAR2(1);
        l_ovrrd_drop VARCHAR2(1);
        l_enrolment_cat  IGS_PS_TYPE.enrolment_cat%TYPE;
        l_en_cal_type igs_ca_inst.cal_type%TYPE;
        l_en_ci_seq_num igs_ca_inst.sequence_number%TYPE;
        l_commencement_type VARCHAR2(10);
        l_dummy VARCHAR2(255);
        l_total_credit_points NUMBER;
        l_att_type VARCHAR2(100);
        l_attendance_types VARCHAR2(2000);
        l_message_name VARCHAR2(2000);
        l_eftsu_total NUMBER;
        l_ret_status BOOLEAN;
        l_err_message VARCHAR2(2000);
BEGIN
        OPEN cur_sup;
        FETCH cur_sup INTO l_check_sup;
        CLOSE cur_sup;

        IF l_check_sup IS  NULL THEN
         RETURN;
        END IF;

        IF p_confirmed_ind = 'Y' THEN
           l_ovrrd_chk := 'Y';
           l_ovrrd_drop := 'N';

        ELSIF p_confirmed_ind = 'N' THEN
               l_ovrrd_chk := 'N';
              l_ovrrd_drop := 'N';

        ELSE
             l_ovrrd_chk := 'N';
             l_ovrrd_drop := 'Y';
         END IF;

        OPEN cur_sub_sua ;
        LOOP
           FETCH cur_sub_sua INTO l_sub_sua;
           EXIT WHEN cur_sub_sua%NOTFOUND;

         -- Determine the Enrollment method , Enrollment Commencement type.
            l_dummy := NULL;
            l_enrolment_cat:=IGS_EN_GEN_003.Enrp_Get_Enr_Cat(p_person_id                =>p_person_id,
                                                             p_course_cd                =>p_course_cd,
                                                             p_cal_type                 =>p_acad_cal_type,
                                                             p_ci_sequence_number       =>p_acad_seq_num,
                                                             p_session_enrolment_cat    =>NULL,
                                                             p_enrol_cal_type           =>l_en_cal_type,
                                                             p_enrol_ci_sequence_number =>l_en_ci_seq_num,
                                                             p_commencement_type        =>l_commencement_type,
                                                             p_enr_categories           =>l_dummy);

                   -- A call to igs_en_prc_load.enrp_clc_eftsu_total
                   -- The Total enrolled CP of the student has to be determined before the unit is dropped(l_total_credit_points) .
                   -- The unit is then dropped , and eval_min_cp is called with the value of l_total_enrolled_cp.
                   -- The value of l_total_enrolled_cp is essential to determine if the Min Credit Points is already reached
                   -- by the student before that Unit is dropped.
                   l_eftsu_total := igs_en_prc_load.enrp_clc_eftsu_total(p_person_id             => p_person_id,
                                                                         p_course_cd             => p_course_cd,
                                                                         p_acad_cal_type         => p_acad_cal_type,
                                                                         p_acad_sequence_number  => p_acad_seq_num,
                                                                         p_load_cal_type         => p_load_cal_type,
                                                                         p_load_sequence_number  => p_load_seq_num,
                                                                         p_truncate_ind          => 'N',
                                                                         p_include_research_ind  => 'Y'  ,
                                                                         p_key_course_cd         => NULL ,
                                                                         p_key_version_number    => NULL ,
                                                                         p_credit_points         => l_total_credit_points );

                   -- Check if the Forced Attendance Type has already been reached for the Student before transferring .
                 OPEN cur_coo_id;
                 FETCH cur_coo_id INTO l_coo_Id;
                 CLOSE cur_coo_id;
                   l_message_name :=NULL;

                  IF  igs_en_val_sca.enrp_val_coo_att(p_person_id          => p_person_id,
                                                                              p_coo_id             => l_coo_id,
                                                                              p_cal_type           => p_acad_cal_type,
                                                                              p_ci_sequence_number => p_acad_seq_num,
                                                                              p_message_name       => l_message_name,
                                                                              p_attendance_types   => l_attendance_types,
                                                                              p_load_or_teach_cal_type => p_load_cal_type,
                                                                              p_load_or_teach_seq_number => p_load_seq_num) THEN
                   -- Assign values to the parameter p_deny_warn_att based on if Attendance Type has not been already reached or not.
                   l_att_type  := 'AttTypReached' ;

                   ELSE
                   l_att_type  := 'AttTypNotReached' ;

                   END IF ;

          igs_ss_en_wrappers.blk_drop_units(
        p_uoo_id                      => l_sub_sua,
        p_person_id                   => p_person_id,
        p_person_type                 => p_person_type,
        p_load_cal_type               => p_load_cal_type,
        p_load_sequence_number        => p_load_seq_num,
        p_acad_cal_type               => p_acad_cal_type,
        p_acad_sequence_number        => p_acad_seq_num,
        p_program_cd                  => p_course_cd,
        p_program_version             => p_course_ver_num,
        p_dcnt_reason_cd              => p_dcnt_reason_cd ,
        p_admin_unit_status           => p_admin_unit_status,
        p_effective_date              => p_effective_date,
        p_enrolment_cat               => l_enrolment_Cat,
        p_comm_type                   => l_commencement_type,
        p_enr_meth_type               => p_enrollment_method,
        p_total_credit_points         => l_total_credit_points,
        p_force_att_type              => l_att_type,
        p_val_ovrrd_chk               => l_ovrrd_chk,
        p_ovrrd_drop                  => l_ovrrd_drop,
        p_return_status               =>l_ret_status,
        p_message                     =>l_err_message,
        P_sub_unit                    =>'Y' );

           IF NOT l_ret_status  THEN
               p_error_message := l_err_message;
               RETURN;

           ELSE

              IF p_confirmed_ind IS NOT NULL THEN
                 IF p_uoo_ids IS NOT NULL THEN
                     p_uoo_ids := p_uoo_ids||','||l_sub_sua;
                 ELSE
                     p_uoo_ids := l_sub_sua;
                 END IF;
              END IF;
          END IF;

         END LOOP;
     EXCEPTION
     WHEN OTHERS THEN

      IF cur_coo_id%ISOPEN THEN
         CLOSE cur_coo_id;
      END IF;
      IF cur_Sup%ISOPEN THEN
         CLOSE cur_sup;
      END IF;
      RAISE;

END drop_sub_units;

PROCEDURE validate_mus( p_person_id             IN NUMBER,
		                    p_course_cd             IN VARCHAR2,
                        p_uoo_id                IN NUMBER
                      ) AS


CURSOR c_same_section(cp_unit_cd VARCHAR2,cp_version_number NUMBER) IS
SELECT same_teaching_period
FROM  igs_ps_unit_ver uv
WHERE unit_cd = cp_unit_cd AND
     uv.version_number =cp_version_number;

CURSOR c_mus_allowed (cp_person_id NUMBER, cp_course_cd VARCHAR2, cp_unit_cd VARCHAR2,
                      cp_cal_type VARCHAR2, cp_ci_sequence_number NUMBER, cp_uoo_id NUMBER) IS
SELECT 'x'
FROM igs_en_su_attempt
WHERE person_id=cp_person_id AND
      course_cd=cp_course_cd AND
      unit_cd=cp_unit_cd AND
      cal_type=cp_cal_type AND
      ci_sequence_number=cp_ci_sequence_number AND
      unit_attempt_status NOT IN ('DROPPED','DISCONTIN') AND
      uoo_id<> cp_uoo_id;

CURSOR c_usec_exclude_mus_flag (cp_uoo_id NUMBER) IS
SELECT unit_cd,version_number,cal_type,ci_sequence_number,not_multiple_section_flag
FROM igs_ps_unit_ofr_opt
WHERE uoo_id=cp_uoo_id;

CURSOR c_mus_participate (cp_not_multiple_section_flag igs_ps_unit_ofr_opt.not_multiple_section_flag%TYPE,
                          cp_person_id NUMBER, cp_course_cd VARCHAR2, cp_unit_cd VARCHAR2,
                          cp_cal_type VARCHAR2, cp_ci_sequence_number NUMBER, cp_uoo_id NUMBER) IS
SELECT 'x'
FROM igs_en_su_attempt sua,
     igs_ps_unit_ofr_opt opt
WHERE sua.person_id=cp_person_id AND
      sua.course_cd=cp_course_cd AND
      sua.unit_cd=cp_unit_cd AND
      sua.cal_type=cp_cal_type AND
      sua.ci_sequence_number = cp_ci_sequence_number AND
      unit_attempt_status NOT IN ('DROPPED','DISCONTIN') AND
      sua.uoo_id<> cp_uoo_id AND
      sua.uoo_id=opt.uoo_id AND
      opt.not_multiple_section_flag=cp_not_multiple_section_flag;

l_unit_cd                 igs_en_su_attempt.unit_cd%TYPE;
l_unit_ver                igs_en_su_attempt.version_number%TYPE;
l_cal_type                igs_en_su_attempt.cal_type%TYPE;
l_ci_sequence_number      igs_en_su_attempt.ci_sequence_number%TYPE;
l_same_teaching_period    igs_ps_unit_ver.same_teaching_period%TYPE;
l_usec_exclude_mus_flag   igs_ps_unit_ofr_opt.not_multiple_section_flag%TYPE;
l_notused                 VARCHAR2(1);



BEGIN

          /*checking for multiple versions of same unit section, if exists raise an exception*/
         --processing for same_teaching_period at unit section level added as a part of Repeat and Reeenrollment build
         OPEN c_usec_exclude_mus_flag (p_uoo_id);
         FETCH c_usec_exclude_mus_flag INTO l_unit_cd,l_unit_ver,l_cal_type,l_ci_sequence_number,l_usec_exclude_mus_flag;
         CLOSE c_usec_exclude_mus_flag;

         OPEN c_same_section (l_unit_cd, l_unit_ver);
         FETCH c_same_section INTO l_same_teaching_period;
         CLOSE c_same_section;

         IF NVL(l_same_teaching_period,'N')='N' OR NVL(l_usec_exclude_mus_flag,'Y')='Y' THEN
                  --unit does not allow MUS..if any other attempts exist..raise error
                 OPEN c_mus_allowed (p_person_id,p_course_cd,l_unit_cd,l_cal_type,l_ci_sequence_number, p_uoo_id);
                 FETCH c_mus_allowed INTO l_notused;
                 IF c_mus_allowed%FOUND THEN
                   CLOSE c_mus_allowed;
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_MUS_NOT_ALLOWED');
                   IGS_GE_MSG_STACK.ADD;
                   APP_EXCEPTION.RAISE_EXCEPTION;
                 END IF;
                 CLOSE c_mus_allowed;
         ELSE
           --unit allows MUS..IF unit section allows MUS..check if any existing attempts do not allow MUS
           --if exits, raise error
           OPEN c_mus_participate ('Y',p_person_id,p_course_cd,l_unit_cd,l_cal_type,l_ci_sequence_number, p_uoo_id);
           FETCH c_mus_participate INTO l_notused;
           IF c_mus_participate%FOUND THEN
                   CLOSE c_mus_participate;
                    FND_MESSAGE.SET_NAME('IGS','IGS_EN_MUS_NOT_ALLOWED');
                    IGS_GE_MSG_STACK.ADD;
                    APP_EXCEPTION.RAISE_EXCEPTION;
           END IF;
           CLOSE c_mus_participate;
         END IF; -- IF NVL(l_same_teaching_period,'N')='N'

EXCEPTION

    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
         RAISE;

    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.validate_mus');
      IGS_GE_MSG_STACK.ADD;
      RAISE;

END validate_mus;

END IGS_EN_VAL_SUA;

/
