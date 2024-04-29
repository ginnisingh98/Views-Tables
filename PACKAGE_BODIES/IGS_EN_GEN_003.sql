--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_003" AS
/* $Header: IGSEN03B.pls 120.5 2006/01/23 01:58:08 smaddali ship $ */
/* change history
   rvangala       27-SEP-2005    Bug 4335046, modified UPD_MAT_MRADM_CAT_TERMS
   pkpatel        26-MAR-2003    Bug 2261717
                                 Tuned functions Enrp_Get_Encmbrd_Ind,
   npalanis       11-SEP-2002    Bug - 2608360
                                 the pe code classes for religion , soci eco status and further education
                                 has been transferred to lookups so new columns are added in igs_pe_stat_details table
                                 to store codes therefore the tbh calls is modified.
   ssawhney       30-APR         V2API OVN change, igs_pe_stat_pkg signature modified.

 */

 /*-------------------------------------------------------------------------------------------------------------
   Following package variable keeps the enrp_get_enr_cat function parameters values.
 -------------------------------------------------------------------------------------------------------------*/
 pkg_person_id                igs_pe_person.person_id%TYPE;
 pkg_course_cd                igs_en_stdnt_ps_att.course_cd%TYPE;
 pkg_cal_type                 igs_ca_inst.cal_type%TYPE;
 pkg_ci_sequence_number       igs_ca_inst.sequence_number%TYPE;
 pkg_session_enrolment_cat    igs_as_sc_atmpt_enr.enrolment_cat%TYPE;
 pkg_enrol_cal_type           igs_ca_inst.cal_type%TYPE;
 pkg_enrol_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
 pkg_commencement_type        VARCHAR2(20);
 pkg_enroll_catg              VARCHAR2(200);
 pkg_enr_categories           VARCHAR2(200);
 pkg_course_att_status        igs_en_stdnt_ps_att.course_attempt_status%TYPE;
 -------------------------------------------------------------------------------------------------------------

Function Enrp_Get_Dflt_Dr(
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 AS
BEGIN
DECLARE
        v_dis_reason_cd         IGS_EN_DCNT_REASONCD.discontinuation_reason_cd%TYPE;
        v_description           IGS_EN_DCNT_REASONCD.description%TYPE;

        CURSOR  c_drcd IS
                SELECT  discontinuation_reason_cd,
                        description
                FROM    IGS_EN_DCNT_REASONCD
                WHERE   dflt_ind = 'Y' AND
                        closed_ind = 'N';
BEGIN
        -- This module retrieves the default discontinuation
        -- reason code for a student IGS_PS_COURSE attempt if the
        -- discontinuation date has been specified
        OPEN  c_drcd;
        FETCH c_drcd INTO v_dis_reason_cd, v_description;
        IF (c_drcd%FOUND) THEN
                CLOSE c_drcd;
                p_description := v_description;
                RETURN v_dis_reason_cd;
        ELSE
                CLOSE c_drcd;
                p_description := NULL;
                RETURN NULL;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_003.enrp_get_dflt_dr');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_get_dflt_dr;


Function Enrp_Get_Dflt_Fs(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2 AS
BEGIN
DECLARE
        CURSOR  c_fund_source_rest(
                        cp_course_cd IGS_PS_VER.course_cd%TYPE,
                        cp_version_number IGS_PS_VER.version_number%TYPE) IS
                SELECT  funding_source
                FROM    IGS_FI_FND_SRC_RSTN
                WHERE   course_cd = cp_course_cd AND
                        version_number = cp_version_number AND
                        dflt_ind = 'Y';
BEGIN
        -- gets the default funding source for a IGS_PS_COURSE version if one
        -- has been specified
        FOR v_fund_source_rest_rec IN c_fund_source_rest(
                                                p_course_cd,
                                                p_version_number)
        LOOP
                RETURN v_fund_source_rest_rec.funding_source;
        END LOOP;
        RETURN NULL;
EXCEPTION
        WHEN OTHERS THEN
                        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_003.enrp_get_dflt_fs');
                        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_get_dflt_fs;


Function Enrp_Get_Ecps_Group(
  p_s_enrolment_step_type IN VARCHAR2 )
RETURN VARCHAR2 AS
        v_step_group_type               IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE;
        CURSOR  c_sest (cp_s_enrolment_step_type
                        IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE) IS
        SELECT  step_group_type
        FROM    IGS_LOOKUPS_VIEW
        WHERE   LOOKUP_CODE = cp_s_enrolment_step_type AND
                LOOKUP_TYPE = 'ENROLMENT_STEP_TYPE';
BEGIN
        v_step_group_type := NULL;
        OPEN c_sest(p_s_enrolment_step_type);
        FETCH c_sest INTO v_step_group_type;
        CLOSE c_sest;
        RETURN v_step_group_type;
END;


FUNCTION Enrp_Get_Encmbrd_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2 AS
/* change history
   WHO       WHEN         WHAT
   pkpatel   26-MAR-2003  Bug 2261717
                          Filter the query for efficiency. Removed the COUNT(*) and
                                                  replaced TRUNC(SYSDATE) with l_sysdate.
 */

        cst_yes                 CONSTANT VARCHAR2(1) := 'Y';
        cst_no                  CONSTANT VARCHAR2(1) := 'N';
        v_output                VARCHAR2(1);
        v_count                 NUMBER;
        l_sysdate       DATE := TRUNC(SYSDATE);
        --(pathipat) Modified cursor for performance issues.  Bug No: 2432563
        -- Removed variables not used.

        CURSOR  c_prsn_encumb
                (cp_person_id   IGS_PE_PERSON.person_id%TYPE) IS
                SELECT  1
                FROM    IGS_PE_PERS_ENCUMB
                WHERE   person_id = cp_person_id AND
                        (l_sysdate BETWEEN start_dt AND (expiry_dt - 1) OR
                        (expiry_dt IS NULL AND start_dt <= l_sysdate)) ;


BEGIN

        -- This module determines whether or not a IGS_PE_PERSON is
        -- an encumbranced student and returns the appropriate
        -- indicator

        -- (pathipat) 'For' loop replaced with the following code, Bug: 2432563
        -- Conditions checked for in the loop have been done in the cursor itself

        OPEN  c_prsn_encumb (p_person_id);
        FETCH c_prsn_encumb INTO v_count;
        IF c_prsn_encumb%FOUND THEN
                -- return Y - the student has encumbrances
                CLOSE c_prsn_encumb;
                v_output := cst_yes;
                return v_output;
        END IF;
        CLOSE c_prsn_encumb;

        -- return N - the student has no encumbrances
        v_output := cst_no;
        return v_output;

END enrp_get_encmbrd_ind;


Function Enrp_Get_Enr_Cat(
p_person_id                IN NUMBER ,
p_course_cd                IN VARCHAR2 ,
p_cal_type                 IN VARCHAR2 ,
p_ci_sequence_number       IN NUMBER ,
p_session_enrolment_cat    IN VARCHAR2 ,
p_enrol_cal_type           OUT NOCOPY VARCHAR2 ,
p_enrol_ci_sequence_number OUT NOCOPY NUMBER ,
p_commencement_type        OUT NOCOPY VARCHAR2,
p_enr_categories           OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------------------
-- This routine will determine the most appropriate enrolment category(ies) for
-- a nominated student (and optionally IGS_PS_COURSE attempt) for a nominated
-- academic period.
-- If the routine is being called for a specific IGS_PS_COURSE, it will also return
-- the  enrolment period calendar instance in which the match was found
-- (this cannot be done when a IGS_PS_COURSE isn?t specified as there may be many
-- periods).
-- If a IGS_PS_COURSE attempt is not specified the routine may return multiple
-- enrolment categories,
-- where the student may be eligible in more than one IGS_PS_COURSE. These will be
-- returned in the  form CATEGORY1,CATEGORY2,ETC?
-- The routine will determine the enrolment category(ies) by looking firstly
-- for one or more eligible IGS_PS_COURSE attempts (matching the specified
-- parameters); then pre-enrolment detail (IGS_AS_SC_ATMPT_ENR records)
-- will be searched for matching the specified  academic period (i.e. the
-- enrolment calendar is a subordinate of the academic calendar).
-- If this is not found and  the passed session enrolment category is set then
-- it will be used.
-- If not set, the fallback is to take the enrolment category from the latest
-- pre-enrolment detail for each eligible IGS_PS_COURSE.
-- It is possible that this routine will not find a match ,in that case find the enrolment category
-- at the program level as a part of bug#2043044 .IF stillnot found then return  NULL
-- enrolment category.
-- The calling routine will be responsible for handling this.
--Change History:
--Who         When            What
--kkillams    06-06-2003      Added new validation, check the input parameter values with
--                            newly created package level variables, if values are same then
--                            return the vaules stored in the package variable else do the
--                            validations. W.r.t. bug no.2829270
--ptandon     14-08-2003      Corrected logic to return concatenated string of Enrolment Categories
--                            as OUT parameter(p_enr_categories) if the student is attempting
--                            program under more than one Enrolment Category. Bug# 2968590
-------------------------------------------------------------------------------------------
RETURN VARCHAR2 AS
BEGIN
DECLARE
        v_applicable_enrolment_cat      VARCHAR2(255);
        v_crs_applicable_enrolment_cat  IGS_AS_SC_ATMPT_ENR.enrolment_cat%TYPE;
        v_sub_cal_type                  IGS_CA_INST_REL.sub_cal_type%TYPE;
        v_first_record                  BOOLEAN;
        v_first_time                    BOOLEAN;
        v_set_cal                       BOOLEAN;
        v_crs_commencement_type         VARCHAR2(10);
        v_commencement_type             VARCHAR2(10);
        v_version_number                IGS_EN_STDNT_PS_ATT.version_number%TYPE;
        v_enrolment_cat                 IGS_PS_TYPE.enrolment_cat%TYPE;
        l_position                      NUMBER;
        v_course_att_status             IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;

        CURSOR  c_sca(
                        cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                        cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
                SELECT  person_id,
                        course_cd,
                        version_number,
                        course_attempt_status,
                        student_confirmed_ind
                FROM    IGS_EN_STDNT_PS_ATT
                WHERE   ((cp_course_cd IS NULL AND person_id = cp_person_id) OR
                         (cp_course_cd IS NOT NULL AND course_cd = cp_course_cd AND
                          person_id = cp_person_id));
        CURSOR  c_scae_ci(
                        cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                        cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
                SELECT  IGS_AS_SC_ATMPT_ENR.enrolment_cat,
                        IGS_AS_SC_ATMPT_ENR.cal_type,
                        IGS_AS_SC_ATMPT_ENR.ci_sequence_number,
                        IGS_CA_INST.start_dt,
                        IGS_CA_INST.end_dt
                FROM    IGS_AS_SC_ATMPT_ENR,
                        IGS_CA_INST
                WHERE   IGS_AS_SC_ATMPT_ENR.person_id = cp_person_id AND
                        IGS_AS_SC_ATMPT_ENR.course_cd = cp_course_cd AND
                        IGS_AS_SC_ATMPT_ENR.cal_type = IGS_CA_INST.cal_type AND
                        IGS_AS_SC_ATMPT_ENR.ci_sequence_number = IGS_CA_INST.sequence_number
                ORDER BY IGS_CA_INST.start_dt desc;
        CURSOR  c_cir(
                        cp_sup_cal_type IGS_CA_INST.cal_type%TYPE,
                        cp_sup_ci_sequence_number IGS_CA_INST.sequence_number%TYPE,
                        cp_sub_cal_type IGS_CA_INST.cal_type%TYPE,
                        cp_sub_ci_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  sub_cal_type
                FROM    IGS_CA_INST_REL
                WHERE   sup_cal_type = cp_sup_cal_type AND
                        sup_ci_sequence_number = cp_sup_ci_sequence_number AND
                        sub_cal_type = cp_sub_cal_type AND
                        sub_ci_sequence_number = cp_sub_ci_sequence_number;

--To get the enrollment category at the program level if the enrollment category is NULL
-- as a part of self service setup DLD build enh bug#2043044
     CURSOR  c_pst(
                    cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                    cp_version_number IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
            SELECT ENROLMENT_CAT
            FROM   IGS_PS_TYPE pt,
                   IGS_PS_VER pv
            WHERE  pv.course_cd = p_course_cd AND
                   pv.course_type = pt.course_type AND
                   pv.version_number = cp_version_number ;

        CURSOR  c_scas( cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                        cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
            SELECT course_attempt_status
            FROM IGS_EN_STDNT_PS_ATT
            WHERE PERSON_ID = cp_person_id
            AND COURSE_CD = cp_course_cd;

BEGIN
        OPEN c_scas(p_person_id, p_course_cd);
        FETCH c_scas INTO v_course_att_status;
        CLOSE c_scas;

        IF ((pkg_person_id              = p_person_id) AND
            (pkg_course_cd              = p_course_cd) AND
            (pkg_cal_type               = p_cal_type ) AND
            (pkg_course_att_status      = v_course_att_status ) AND
            (pkg_ci_sequence_number     = p_ci_sequence_number) AND
            ((pkg_session_enrolment_cat = p_session_enrolment_cat) OR
             (p_session_enrolment_cat IS NULL AND pkg_session_enrolment_cat IS NULL))) THEN
             p_enrol_cal_type           := pkg_enrol_cal_type;
             p_enrol_ci_sequence_number := pkg_enrol_ci_sequence_number;
             p_commencement_type        := pkg_commencement_type;
             p_enr_categories           := pkg_enr_categories;
             RETURN pkg_enroll_catg;
        ELSE
             pkg_enrol_cal_type           := NULL;
             pkg_enrol_ci_sequence_number := NULL;
             pkg_commencement_type        := NULL;
             pkg_enroll_catg              := NULL;
             pkg_enr_categories           := NULL;
             pkg_person_id                := p_person_id;
             pkg_course_cd                := p_course_cd;
             pkg_cal_type                 := p_cal_type;
             pkg_ci_sequence_number       := p_ci_sequence_number;
             pkg_session_enrolment_cat    := p_session_enrolment_cat;
             pkg_course_att_status        := v_course_att_status;
        END IF;

        p_enrol_cal_type := NULL;
        p_enrol_ci_sequence_number := NULL;
        p_commencement_type := NULL;
        v_commencement_type := NULL;
        v_applicable_enrolment_cat := NULL;
        v_first_time := TRUE;
        FOR v_sca_rec IN c_sca(
                        p_person_id,
                        p_course_cd)
        LOOP
                -- Call routine to obtain IGS_PS_COURSE commencement_type
                IF IGS_EN_GEN_006.ENRP_GET_SCA_COMM(v_sca_rec.person_id,
                                             v_sca_rec.course_cd,
                                             v_sca_rec.student_confirmed_ind,
                                             SYSDATE) THEN
                        IF v_commencement_type IS NULL THEN
                                v_commencement_type := 'NEW';
                        ELSIF v_commencement_type = 'RETURN' THEN
                                v_commencement_type := 'BOTH';
                        END IF;
                ELSE
                        IF v_commencement_type IS NULL THEN
                                v_commencement_type := 'RETURN';
                        ELSIF v_commencement_type = 'NEW' THEN
                                v_commencement_type := 'BOTH';
                        END IF;
                END IF;
                --To get the version number as a part of bug 2043044
                v_version_number := v_sca_rec.version_number;

                v_crs_applicable_enrolment_cat := NULL;
                v_first_record := TRUE;
                v_set_cal := TRUE;
                FOR v_scae_ci_rec IN c_scae_ci(
                                        v_sca_rec.person_id,
                                        v_sca_rec.course_cd)
                LOOP
                        IF(v_first_record  AND p_session_enrolment_cat IS NULL) THEN
                           v_crs_applicable_enrolment_cat := v_scae_ci_rec.enrolment_cat;
                           IF(p_course_cd IS NOT NULL) THEN
                              p_enrol_cal_type := v_scae_ci_rec.cal_type;
                              p_enrol_ci_sequence_number := v_scae_ci_rec.ci_sequence_number;
                           END IF;
                        END IF;
                        v_first_record := FALSE;
                        OPEN c_cir(
                                p_cal_type,
                                p_ci_sequence_number,
                                v_scae_ci_rec.cal_type,
                                v_scae_ci_rec.ci_sequence_number);
                        FETCH c_cir INTO v_sub_cal_type;
                        IF (c_cir%FOUND) THEN
                                v_crs_applicable_enrolment_cat := v_scae_ci_rec.enrolment_cat;
                                IF(p_course_cd IS NOT NULL and v_set_cal) THEN
                                   p_enrol_cal_type := v_scae_ci_rec.cal_type;
                                   p_enrol_ci_sequence_number := v_scae_ci_rec.ci_sequence_number;
                                END IF;
                                CLOSE c_cir;
                                v_set_cal := FALSE;
                        END IF;
                        IF(c_cir%ISOPEN) THEN
                                CLOSE c_cir;
                        END IF;
                        IF(v_crs_applicable_enrolment_cat IS NULL AND
                           p_session_enrolment_cat IS NOT NULL) THEN
                                v_crs_applicable_enrolment_cat := p_session_enrolment_cat;
                        END IF;
                        IF(v_crs_applicable_enrolment_cat IS NOT NULL AND v_first_time) THEN
                                v_first_time := FALSE;
                                v_applicable_enrolment_cat := v_applicable_enrolment_cat||
                                                              v_crs_applicable_enrolment_cat;
                        ELSIF((v_crs_applicable_enrolment_cat IS NOT NULL) AND (NOT v_first_time) AND
                              (INSTR(v_applicable_enrolment_cat, v_crs_applicable_enrolment_cat) = 0))
                        THEN
                                v_applicable_enrolment_cat := v_applicable_enrolment_cat||','||
                                                              v_crs_applicable_enrolment_cat;
                        END IF;
                END LOOP;
        END LOOP;
        IF v_applicable_enrolment_cat IS NULL AND
            p_session_enrolment_cat IS NOT NULL THEN
                v_applicable_enrolment_cat := p_session_enrolment_cat;
        END IF;
        -- If commencement type cannot be determined the default to BOTH.
        IF v_commencement_type IS NOT NULL THEN
                p_commencement_type := v_commencement_type;
        ELSE
                p_commencement_type := 'BOTH';
        END IF;
--if value of v_applicable_enrolment_cat is NULL then fetch enrolment category at the program level as a part of self service setup dld
-- enh number #2043044

        IF v_applicable_enrolment_cat IS NULL THEN
           OPEN c_pst(p_course_cd, v_version_number );
           FETCH c_pst into v_applicable_enrolment_cat;
           CLOSE c_pst;
        END IF;

        pkg_enrol_cal_type           := p_enrol_cal_type;
        pkg_enrol_ci_sequence_number := p_enrol_ci_sequence_number;
        pkg_commencement_type        := p_commencement_type;
        pkg_enroll_catg              := v_applicable_enrolment_cat;
        pkg_enr_categories           := v_applicable_enrolment_cat;

        p_enr_categories := v_applicable_enrolment_cat;
        l_position := INSTR(v_applicable_enrolment_cat,',');
        IF l_position <> 0 THEN
           pkg_enroll_catg := SUBSTR(v_applicable_enrolment_cat,1,l_position-1);
           RETURN pkg_enroll_catg;
        END IF;
        return v_applicable_enrolment_cat;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_003.Enrp_Get_Enr_Cat');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END Enrp_Get_Enr_Cat;


Function Enrp_Get_Enr_Ci(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_sequence_number IN NUMBER ,
  p_enr_cal_type OUT NOCOPY VARCHAR2 ,
  p_enr_sequence_number OUT NOCOPY NUMBER )
RETURN boolean AS

BEGIN   -- enrp_get_enr_ci
        -- Get the enrolment period which applies to an admission period.
        -- This is picked up through the relationship between the admission
        --   and enrolment period, with the enrolment period being the
        --   subordinate in the relationship.
        -- If no relationship can be found, the routine will return FALSE.
        -- If multiple records found, the first period is used (this isn?t
        --   really a valid scenario)
DECLARE
        cst_active              CONSTANT VARCHAR2(10) := 'ACTIVE';
        cst_enrolment           CONSTANT VARCHAR2(10) := 'ENROLMENT';
        CURSOR c_cir IS
                SELECT  cir.sub_cal_type,
                        cir.sub_ci_sequence_number
                FROM    IGS_CA_INST_REL         cir,
                        IGS_CA_INST     ci,
                        IGS_CA_TYPE     cat,
                        IGS_CA_STAT     cs
                WHERE   cir.sup_cal_type                = p_adm_cal_type AND
                        cir.sup_ci_sequence_number      = p_adm_sequence_number AND
                        ci.cal_type             = cir.sub_cal_type AND
                        ci.sequence_number      = cir.sub_ci_sequence_number AND
                        cat.cal_type            = ci.cal_type AND
                        cat.S_CAL_CAT           = cst_enrolment AND
                        cs.cal_status           = ci.cal_status AND
                        cs.s_cal_status         = cst_active
                ORDER BY ci.start_dt;
        v_cir_rec               c_cir%ROWTYPE;
BEGIN
        OPEN c_cir;
        FETCH c_cir INTO v_cir_rec;
        IF c_cir%NOTFOUND THEN
                CLOSE c_cir;
                p_enr_cal_type := NULL;
                p_enr_sequence_number := NULL;
                RETURN FALSE;
        END IF;
        CLOSE c_cir;
        p_enr_cal_type := v_cir_rec.sub_cal_type;
        p_enr_sequence_number := v_cir_rec.sub_ci_sequence_number;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_cir%ISOPEN THEN
                        CLOSE c_cir;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_003.enrp_get_enr_ci');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_get_enr_ci;


Procedure Enrp_Get_Enr_Pp(
  p_username IN VARCHAR2 ,
  p_cal_type OUT NOCOPY VARCHAR2 ,
  p_sequence_number OUT NOCOPY NUMBER ,
  p_enrolment_cat OUT NOCOPY VARCHAR2 ,
  p_enr_method_type OUT NOCOPY VARCHAR2 )
AS
BEGIN
DECLARE
        v_person_id             IGS_PE_PERSON.person_id%TYPE;
        v_person_prefs_rec      IGS_PE_PERS_PREFS%ROWTYPE;
        CURSOR  c_person(
                        cp_username IGS_PE_PERSON.oracle_username%TYPE) IS
                SELECT  person_id
                FROM    IGS_PE_PERSON
                WHERE   oracle_username = cp_username;
        CURSOR  c_person_prefs(
                        cp_person_id IGS_PE_PERSON.person_id%TYPE) IS
                SELECT  *
                FROM    IGS_PE_PERS_PREFS
                WHERE   person_id = cp_person_id;
BEGIN
        -- this module gets the enrolment values for a IGS_PE_PERSON's preference
        -- table

       -- commented after ORACLE_USERNAME issue...
 -- added after ORACLE_USERNAME issue...
      v_person_id := FND_GLOBAL.USER_ID;

        OPEN    c_person_prefs(
                        v_person_id);
        FETCH   c_person_prefs INTO v_person_prefs_rec;

        IF (c_person_prefs%NOTFOUND) THEN
                CLOSE   c_person_prefs;
                p_cal_type := NULL;
                p_sequence_number := NULL;
                p_enrolment_cat := NULL;
                p_enr_method_type := NULL;
        ELSE
                CLOSE   c_person_prefs;
                p_cal_type := v_person_prefs_rec.enr_acad_cal_type;
                p_sequence_number := v_person_prefs_rec.enr_acad_sequence_number;
                p_enrolment_cat := v_person_prefs_rec.enr_enrolment_cat;
                p_enr_method_type := v_person_prefs_rec.enr_enr_method_type;
        END IF;
        RETURN;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_003.enrp_get_enr_pp');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_get_enr_pp;


Function Enrp_Get_Excld_Unit(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE )
RETURN VARCHAR2 AS

BEGIN
DECLARE
        v_pue_start_dt          IGS_PE_PERS_UNT_EXCL.pue_start_dt%TYPE;
        v_expiry_dt             IGS_PE_PERS_UNT_EXCL.expiry_dt%TYPE;
        v_message_name varchar2(30);
        CURSOR c_psd_ed IS
                SELECT  pue.pue_start_dt,
                        pue.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT    pee,
                        IGS_PE_PERS_UNT_EXCL            pue
                WHERE   pee.person_id = p_person_id AND
                        pee.s_encmb_effect_type = 'EXC_CRS_U' AND
                        pee.course_cd = p_course_cd AND
                        pue.person_id = pee.person_id AND
                        pue.encumbrance_type = pee.encumbrance_type AND
                        pue.pen_start_dt = pee.pen_start_dt AND
                        pue.s_encmb_effect_type = pee.s_encmb_effect_type AND
                        pue.pee_start_dt = pee.pee_start_dt AND
                        pue.pee_sequence_number = pee.sequence_number;
BEGIN
        -- This function validates whether or not a IGS_PE_PERSON is
        -- excluded from admission or enrolment in a specific IGS_PS_UNIT.
        -- Validate the input parameters
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_effective_dt IS NULL THEN
                RETURN 'N';
        END IF;
        --Validate for an exclusion from the university
        IF IGS_EN_VAL_ENCMB.enrp_val_excld_prsn(
                        p_person_id,
                        p_course_cd,
                        p_effective_dt,
                        v_message_name) = FALSE THEN
                RETURN 'Y';
        END IF;
        --Validate for an exclusion from a specific IGS_PS_UNIT.
        OPEN    c_psd_ed;
        LOOP
                FETCH   c_psd_ed        INTO    v_pue_start_dt,
                                                v_expiry_dt;
                EXIT WHEN c_psd_ed%NOTFOUND;
                --Validate if the dates of a returned record overlap with the effective date.
                IF v_expiry_dt IS NULL THEN
                        IF v_pue_start_dt <= p_effective_dt THEN
                                CLOSE c_psd_ed;
                                RETURN 'Y';
                        END IF;
                ELSE
                        IF p_effective_dt BETWEEN v_pue_start_dt AND (v_expiry_dt - 1) THEN
                                CLOSE c_psd_ed;
                                RETURN 'Y';
                        END IF;
                END IF;
        END LOOP;
        CLOSE   c_psd_ed;
        --- Return the default value
        RETURN 'N';
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_003.enrp_get_excld_unit');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_get_excld_unit;

Function Get_Student_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2 AS

    -- Cursor modified for the bug# 1956253
    CURSOR pe_typ_cd IS
    SELECT DISTINCT pti.person_type_code
    FROM igs_pe_typ_instances_all pti,
             igs_pe_person_types ppt
    WHERE person_id = p_person_id AND
          ppt.system_type  = 'STUDENT' AND
          ppt.person_type_code = pti.person_type_code AND
          SYSDATE BETWEEN start_date and NVL(end_date,igs_ge_date.igsdate('9999/01/01'));

    lv_pe_typ_cd pe_typ_cd%RowType;

BEGIN
  open pe_typ_cd;
  FETCH pe_typ_cd INTO lv_pe_typ_cd;
  IF (pe_typ_cd%FOUND) THEN
      CLOSE pe_typ_cd;
      RETURN('Y');
  ELSE
      CLOSE pe_typ_cd;
      RETURN('N');
  END IF;

END Get_Student_Ind;


Function Get_Staff_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2 AS

    -- Removed select from igs_pe_person_v  (pathipat) Bug:2432563

     CURSOR pe_typ_cd IS
     SELECT pti.person_type_code
     FROM igs_pe_typ_instances pti
     WHERE     pti.person_id = p_person_id
           AND pti.system_type = 'STAFF'
           AND SYSDATE BETWEEN pti.start_date AND NVL(pti.end_date,SYSDATE);

    lv_pe_typ_cd pe_typ_cd%RowType;

BEGIN

 open pe_typ_cd;
  FETCH pe_typ_cd INTO lv_pe_typ_cd;
  IF (pe_typ_cd%FOUND) THEN
      CLOSE pe_typ_cd;
      RETURN('Y');
  ELSE
      CLOSE pe_typ_cd;
      RETURN('N');
  END IF;
END Get_Staff_Ind;

 FUNCTION Stdnt_Crs_Atmpt_Stat (perid NUMBER)
  RETURN VARCHAR2 AS

       CURSOR stu_period_c IS
         SELECT COURSE_ATTEMPT_STATUS
         FROM IGS_EN_STDNT_PS_ATT
         WHERE PERSON_ID=perid;

  BEGIN
     FOR person_cursor IN stu_period_c LOOP
        IF person_cursor.COURSE_ATTEMPT_STATUS='ENROLLED' THEN
         RETURN ('Y');
        ELSE
         RETURN ('N');
        END IF;
      END LOOP;
      return('N');
   EXCEPTION WHEN OTHERS THEN
        Return('N');
END  Stdnt_Crs_Atmpt_Stat;
--Procedure added as a part of self service setup DLD to set values of matriculation term,
--recent admittance term and catalog terms based on the profile values setup for the passed person
--as a part of enh bug 2043044

--Removed columns from igs_pe_stat_details_pkg call as a part of bug number 2203778

PROCEDURE UPD_MAT_MRADM_CAT_TERMS(
    p_person_id IN NUMBER,
    p_program_cd IN VARCHAR2,
    p_unit_attempt_status IN VARCHAR2,
    p_teach_cal_type IN VARCHAR2,
    p_teach_ci_seq_num IN NUMBER)

/*
|| change history
|| WHO         WHEN          WHAT
|| ssawhney    30-APR        V2API OVN change, igs_pe_stat_pkg signature modified.
*/
IS
--Added attribute columns in IGS_PE_DETAILS TBH call as a part of descritpive flexfield added as a part of bug nu:2203778
 lv_profile_matr_cd  VARCHAR2(300) := FND_PROFILE.VALUE('IGS_PE_MATR_TERM');
 lv_profile_cat_cd   VARCHAR2(300) := FND_PROFILE.VALUE('IGS_PE_CATALOG');
 lv_profile_mr_admit_cd   VARCHAR2(300) := FND_PROFILE.VALUE('IGS_PE_RECENT_TERM');
 lv_cal_term   VARCHAR2(10) := 'FALSE';
 XXX_ROWID VARCHAR2(25);
 lv_rowid  VARCHAR2(25);

 v_return_status Varchar2(1) :='S';
 v_msg_count NUMBER;
 v_msg_Data VARCHAR2(2000);
 v_party_last_update_date DATE;
lv_perosn_profile_id  hz_person_profiles.person_profile_id%TYPE ;
l_ovn                 hz_parties.object_version_number%TYPE;




  CURSOR  c_espa(cp_course_cd  IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                 cp_person_id  IGS_EN_STDNT_PS_ATT.person_id%TYPE) IS
         Select version_number
         FROM   IGS_EN_STDNT_PS_ATT
         WHERE  course_cd = cp_course_cd AND
                person_id = cp_person_id;
        lv_version_number   IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  CURSOR  c_pst(cp_course_cd  IGS_PS_VER.course_cd%TYPE,
                cp_version_number IGS_PS_VER.version_number%TYPE) IS
         Select  award_course_ind
         FROM    IGS_PS_TYPE  pt,
                 IGS_PS_VER   pv
         WHERE   pv.course_type = pt.course_type AND
                 pv.course_cd   = cp_course_cd AND
                 pv.version_number = cp_version_number ;
    lv_award_course_ind   IGS_PS_TYPE.award_course_ind%TYPE;
   CURSOR  c_cttl(cp_teach_cal_type   IGS_CA_TEACH_TO_LOAD_V.teach_cal_type%TYPE,
                  cp_teach_ci_seq_num IGS_CA_TEACH_TO_LOAD_V.teach_ci_sequence_number%TYPE) IS
         Select  load_cal_type,
                 load_ci_sequence_number
         FROM    IGS_CA_TEACH_TO_LOAD_V
         WHERE   teach_cal_type             =  cp_teach_cal_type AND
                 teach_ci_sequence_number   = cp_teach_ci_seq_num
         ORDER   BY  load_start_dt desc ;
    lv_cttl_rec  c_cttl%ROWTYPE;
   CURSOR c_apai(cp_course_cd  IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                 cp_person_id  IGS_EN_STDNT_PS_ATT.person_id%TYPE) IS
          SELECT count(ai.person_id) cnt
          FROM   IGS_AD_PS_APPL_INST ai,
                 IGS_AD_OFR_RESP_STAT ar
          WHERE  ai.adm_offer_resp_status  = ar.adm_offer_resp_status  AND
                 ar.s_adm_offer_resp_status = 'ACCEPTED'  AND
                 ai.person_id = cp_person_id  AND
                 ai.course_cd = cp_course_cd ;
     lv_apai_rec  c_apai%ROWTYPE;
     --Cursor to get the row values for updating roe values
   CURSOR c_psd(cp_person_id  IGS_EN_STDNT_PS_ATT.person_id%TYPE) IS
         SELECT rowid,
    person_id,
                effective_start_date,
                effective_end_date,
                religion_cd,
                socio_eco_cd,
                next_to_kin,
                in_state_tuition,
                tuition_st_date,
                tuition_end_date,
                further_education_cd,
                MATR_CAL_TYPE,
          MATR_SEQUENCE_NUMBER ,
    INIT_CAL_TYPE ,
        INIT_SEQUENCE_NUMBER ,
        RECENT_CAL_TYPE ,
                RECENT_SEQUENCE_NUMBER ,
    CATALOG_CAL_TYPE ,
    CATALOG_SEQUENCE_NUMBER  ,
      ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20
         FROM IGS_PE_STAT_DETAILS
         WHERE person_id = cp_person_id;
    lv_psd_rec  c_psd%ROWTYPE;




BEGIN
--If for the person corresponding record does not exist in IGS_PE_STAT_DETAILS table then create a record in IGS_PE_STAT_DETAILS table
OPEN c_psd(p_person_id);
Fetch c_psd INTO lv_psd_rec;
IF c_psd%FOUND then
  CLOSE c_psd;
ELSE
  Igs_Pe_Stat_Details_Pkg.Insert_Row (
                                 x_rowid                             => lv_rowid,
                                 x_person_id                         => p_person_id,
                                 x_effective_start_date              => SYSDATE,
                                 x_effective_end_date                => NULL,
                                 x_religion_cd                       => NULL,
                                 x_socio_eco_cd                      => NULL,
                                 x_next_to_kin                       => NULL,
                                 x_in_state_tuition                  => 'N',
                                 x_tuition_st_date                   => NULL,
                                 x_tuition_end_date                  => NULL,
                                 x_further_education_cd              => NULL,
                                 X_MATR_CAL_TYPE                     => NULL,
                                 X_MATR_SEQUENCE_NUMBER              => NULL,
                                 X_INIT_CAL_TYPE                     => NULL,
                                 X_INIT_SEQUENCE_NUMBER              => NULL,
                                 X_RECENT_CAL_TYPE                   => NULL,
                                 X_RECENT_SEQUENCE_NUMBER            => NULL,
                                 X_CATALOG_CAL_TYPE                  => NULL,
                                 X_CATALOG_SEQUENCE_NUMBER           => NULL,
                                 X_MODE                              => 'R',
                                 X_ATTRIBUTE_CATEGORY                => NULL,
                                 X_ATTRIBUTE1                        => NULL,
                                 X_ATTRIBUTE2                        => NULL,
                                 X_ATTRIBUTE3                        => NULL,
                                 X_ATTRIBUTE4                        => NULL,
                                 X_ATTRIBUTE5                        => NULL,
                                 X_ATTRIBUTE6                        => NULL,
                                 X_ATTRIBUTE7                        => NULL,
                                 x_ATTRIBUTE8                        => NULL,
                                 X_ATTRIBUTE9                        => NULL,
                                 X_ATTRIBUTE10                       => NULL,
                                 X_ATTRIBUTE11                       => NULL,
                                 X_ATTRIBUTE12                       => NULL,
                                 X_ATTRIBUTE13                       => NULL,
                                 X_ATTRIBUTE14                       => NULL,
                                 X_ATTRIBUTE15                       => NULL,
                                 X_ATTRIBUTE16                       => NULL,
                                 X_ATTRIBUTE17                       => NULL,
                                 X_ATTRIBUTE18                       => NULL,
                                 X_ATTRIBUTE19                       => NULL,
                                 X_ATTRIBUTE20                       => NULL );



 CLOSE c_psd;
 END IF;


     lv_cal_term := 'FALSE';
      OPEN c_psd(p_person_id);
      FETCH c_psd into  lv_psd_rec;
  --Check the value of matriculation fields,if nULL then proceed to  populate them by the given logic
      IF  lv_psd_rec.MATR_CAL_TYPE  IS NULL OR lv_psd_rec.MATR_SEQUENCE_NUMBER IS NULL  THEN
          CLOSE c_psd;
  --derive the matriculation term based on the following logic if unit_attempt_status is ENROLLED
          IF p_unit_attempt_status = 'ENROLLED' then

  --derive the matriculation term based on the following logic if matriculation term profile value is NON GENERIC
             IF lv_profile_matr_cd = 'NON_GENERIC' THEN

                 OPEN c_espa(p_program_cd,p_person_id);
                 FETCH c_espa INTO lv_version_number ;

  --Check if the program code passed is a non-generic program by checking value of award_course_ind
                    OPEN  c_pst(p_program_cd,lv_version_number);
                    FETCH c_pst INTO lv_award_course_ind;

                      IF lv_award_course_ind = 'Y' THEN
                          lv_cal_term := 'TRUE' ;
                      ELSE
                         lv_cal_term := 'FALSE' ;
                      END IF;
                    CLOSE c_pst;
                 CLOSE c_espa;
 --derive the matriculation term based on the following logic if matriculation term profile value is Non Generic and Generic

              ELSIF lv_profile_matr_cd = 'ALL' THEN
                    lv_cal_term := 'TRUE' ;
             END IF;

             IF lv_cal_term = 'TRUE' THEN
                OPEN c_cttl(p_teach_cal_type,p_teach_ci_seq_num);
                FETCH c_cttl into     lv_cttl_rec ;
                 OPEN c_psd(p_person_id);
                 FETCH c_psd into lv_psd_rec;
                IF lv_profile_cat_cd  = 'MATRICULATION'  THEN
--If matriculation term is present and catalog profile option is MATRICULATION TERM then
--update the catalog fields of the IGS_PE_STAT_DETAILS with the values fetched above   beside updating the matricualtion fields also


                  Igs_Pe_Stat_Details_Pkg.update_row (
                         x_rowid                             => lv_psd_rec.rowid,
                         x_person_id                         => lv_psd_rec.person_id    ,
                         x_effective_start_date              => lv_psd_rec.effective_start_date,
                         x_effective_end_date                => lv_psd_rec.effective_end_date,
                         x_religion_cd                       => lv_psd_rec.religion_cd,
                         x_socio_eco_cd                      => lv_psd_rec.socio_eco_cd,
                         x_next_to_kin                       => lv_psd_rec.next_to_kin,
                         x_in_state_tuition                  => lv_psd_rec.in_state_tuition,
                         x_tuition_st_date                   => lv_psd_rec.tuition_st_date,
                         x_tuition_end_date                  => lv_psd_rec.tuition_end_date,
                         x_further_education_cd              => lv_psd_rec.further_education_cd,
                         X_MATR_CAL_TYPE                     => lv_cttl_rec.load_cal_type,
                         X_MATR_SEQUENCE_NUMBER              => lv_cttl_rec.load_ci_sequence_number,
                         X_INIT_CAL_TYPE                     => lv_psd_rec.INIT_CAL_TYPE,
                         X_INIT_SEQUENCE_NUMBER              => lv_psd_rec.INIT_SEQUENCE_NUMBER,
                         X_RECENT_CAL_TYPE                   => lv_psd_rec.RECENT_CAL_TYPE,
                         X_RECENT_SEQUENCE_NUMBER            => lv_psd_rec.RECENT_SEQUENCE_NUMBER ,
                         X_CATALOG_CAL_TYPE                  => lv_cttl_rec.load_cal_type ,
                         X_CATALOG_SEQUENCE_NUMBER           => lv_cttl_rec.load_ci_sequence_number,
                         X_MODE                              =>  'R' ,
                         X_ATTRIBUTE_CATEGORY                =>  lv_psd_rec.ATTRIBUTE_CATEGORY,
                         X_ATTRIBUTE1                        =>  lv_psd_rec.ATTRIBUTE1,
                         X_ATTRIBUTE2                        =>  lv_psd_rec.ATTRIBUTE2,
                         X_ATTRIBUTE3                        =>  lv_psd_rec.ATTRIBUTE3,
                         X_ATTRIBUTE4                        =>  lv_psd_rec.ATTRIBUTE4,
                         X_ATTRIBUTE5                        =>  lv_psd_rec.ATTRIBUTE5,
                         X_ATTRIBUTE6                        =>  lv_psd_rec.ATTRIBUTE6,
                         X_ATTRIBUTE7                        =>  lv_psd_rec.ATTRIBUTE7,
                         x_ATTRIBUTE8                        =>  lv_psd_rec.ATTRIBUTE8,
                         X_ATTRIBUTE9                        =>  lv_psd_rec.ATTRIBUTE9,
                         X_ATTRIBUTE10                       =>  lv_psd_rec.ATTRIBUTE10,
                         X_ATTRIBUTE11                       =>  lv_psd_rec.ATTRIBUTE11,
                         X_ATTRIBUTE12                       =>  lv_psd_rec.ATTRIBUTE12,
                         X_ATTRIBUTE13                       =>  lv_psd_rec.ATTRIBUTE13,
                         X_ATTRIBUTE14                       =>  lv_psd_rec.ATTRIBUTE14,
                         X_ATTRIBUTE15                       =>  lv_psd_rec.ATTRIBUTE15,
                         X_ATTRIBUTE16                       =>  lv_psd_rec.ATTRIBUTE16,
                         X_ATTRIBUTE17                       =>  lv_psd_rec.ATTRIBUTE17,
                         X_ATTRIBUTE18                       =>  lv_psd_rec.ATTRIBUTE18,
                         X_ATTRIBUTE19                       =>  lv_psd_rec.ATTRIBUTE19,
                         X_ATTRIBUTE20                       =>  lv_psd_rec.ATTRIBUTE20);

          ELSE
          --Just updating the matriculation fields
            Igs_Pe_Stat_Details_Pkg.update_row (
                          x_rowid                            => lv_psd_rec.rowid,
                          x_person_id                        => lv_psd_rec.person_id    ,
                          x_effective_start_date             => lv_psd_rec.effective_start_date,
                          x_effective_end_date               => lv_psd_rec.effective_end_date,
                          x_religion_cd                      => lv_psd_rec.religion_cd,
                          x_socio_eco_cd                     => lv_psd_rec.socio_eco_cd,
                          x_next_to_kin                      => lv_psd_rec.next_to_kin,
                          x_in_state_tuition                 => lv_psd_rec.in_state_tuition,
                          x_tuition_st_date                  => lv_psd_rec.tuition_st_date,
                          x_tuition_end_date                 => lv_psd_rec.tuition_end_date,
                          x_further_education_cd             => lv_psd_rec.further_education_cd,
                          X_MATR_CAL_TYPE                    => lv_cttl_rec.load_cal_type,
                          X_MATR_SEQUENCE_NUMBER             => lv_cttl_rec.load_ci_sequence_number,
                          X_INIT_CAL_TYPE                    => lv_psd_rec.INIT_CAL_TYPE,
                          X_INIT_SEQUENCE_NUMBER             => lv_psd_rec.INIT_SEQUENCE_NUMBER,
                          X_RECENT_CAL_TYPE                  => lv_psd_rec.RECENT_CAL_TYPE,
                          X_RECENT_SEQUENCE_NUMBER           => lv_psd_rec.RECENT_SEQUENCE_NUMBER ,
                          X_CATALOG_CAL_TYPE                 => lv_psd_rec.CATALOG_CAL_TYPE ,
                          X_CATALOG_SEQUENCE_NUMBER          => lv_psd_rec.CATALOG_SEQUENCE_NUMBER,
                          X_MODE                             =>  'R'  ,
                          X_ATTRIBUTE_CATEGORY               =>  lv_psd_rec.ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1                       =>  lv_psd_rec.ATTRIBUTE1,
                          X_ATTRIBUTE2                       =>  lv_psd_rec.ATTRIBUTE2,
                          X_ATTRIBUTE3                       =>  lv_psd_rec.ATTRIBUTE3,
                          X_ATTRIBUTE4                       =>  lv_psd_rec.ATTRIBUTE4,
                          X_ATTRIBUTE5                       =>  lv_psd_rec.ATTRIBUTE5,
                          X_ATTRIBUTE6                       =>  lv_psd_rec.ATTRIBUTE6,
                          X_ATTRIBUTE7                       =>  lv_psd_rec.ATTRIBUTE7,
                          x_ATTRIBUTE8                       =>  lv_psd_rec.ATTRIBUTE8,
                          X_ATTRIBUTE9                       =>  lv_psd_rec.ATTRIBUTE9,
                          X_ATTRIBUTE10                      =>  lv_psd_rec.ATTRIBUTE10,
                          X_ATTRIBUTE11                      =>  lv_psd_rec.ATTRIBUTE11,
                          X_ATTRIBUTE12                      =>  lv_psd_rec.ATTRIBUTE12,
                          X_ATTRIBUTE13                      =>  lv_psd_rec.ATTRIBUTE13,
                          X_ATTRIBUTE14                      =>  lv_psd_rec.ATTRIBUTE14,
                          X_ATTRIBUTE15                      =>  lv_psd_rec.ATTRIBUTE15,
                          X_ATTRIBUTE16                      =>  lv_psd_rec.ATTRIBUTE16,
                          X_ATTRIBUTE17                      =>  lv_psd_rec.ATTRIBUTE17,
                          X_ATTRIBUTE18                      =>  lv_psd_rec.ATTRIBUTE18,
                          X_ATTRIBUTE19                      =>  lv_psd_rec.ATTRIBUTE19,
                          X_ATTRIBUTE20                      =>  lv_psd_rec.ATTRIBUTE20);

                END IF;
                CLOSE c_psd;
                CLOSE c_cttl;
            END IF;
      END IF;
      END IF;
      IF(c_psd%ISOPEN) THEN
        CLOSE c_psd;
     END IF;

--To set the value of recent admittance term based on profile option value
      IF     lv_profile_mr_admit_cd = 'ACCPT_OFFER_UNIT_ATTEMPT' THEN
             OPEN  c_apai(p_program_cd,p_person_id);
             FETCH c_apai INTO lv_apai_rec;

             --if an accepted admission application exists
             IF lv_apai_rec.cnt > 0 THEN
               CLOSE c_apai;
               OPEN c_cttl(p_teach_cal_type,p_teach_ci_seq_num);
               FETCH c_cttl into     lv_cttl_rec ;
                  OPEN c_psd(p_person_id);
                 FETCH c_psd into lv_psd_rec ;

           IF lv_profile_cat_cd  = 'MR_ADM_TERM'  THEN
--Updating the catalog fields also alongwith recent admittacne term fields
--if recent admittance term is present and catalog prfile is set to Recent admittance term
          Igs_Pe_Stat_Details_Pkg.update_row (
                         x_rowid                             => lv_psd_rec.rowid,
                         x_person_id                         => lv_psd_rec.person_id    ,
                               x_effective_start_date              => lv_psd_rec.effective_start_date,
                         x_effective_end_date                => lv_psd_rec.effective_end_date,
                         x_religion_cd                       => lv_psd_rec.religion_cd,
                         x_socio_eco_cd                      => lv_psd_rec.socio_eco_cd,
                         x_next_to_kin                       => lv_psd_rec.next_to_kin,
                         x_in_state_tuition                  => lv_psd_rec.in_state_tuition,
                         x_tuition_st_date                   => lv_psd_rec.tuition_st_date,
                         x_tuition_end_date                  => lv_psd_rec.tuition_end_date,
                         x_further_education_cd              => lv_psd_rec.further_education_cd,
                         X_MATR_CAL_TYPE                     => lv_psd_rec.MATR_CAL_TYPE,
                   X_MATR_SEQUENCE_NUMBER              => lv_psd_rec.MATR_SEQUENCE_NUMBER,
                     X_INIT_CAL_TYPE                     => lv_psd_rec.INIT_CAL_TYPE,
                         X_INIT_SEQUENCE_NUMBER              => lv_psd_rec.INIT_SEQUENCE_NUMBER,
                         X_RECENT_CAL_TYPE                   => lv_cttl_rec.load_cal_type,
                         X_RECENT_SEQUENCE_NUMBER            => lv_cttl_rec.load_ci_sequence_number,
                         X_CATALOG_CAL_TYPE                  => lv_cttl_rec.load_cal_type ,
                         X_CATALOG_SEQUENCE_NUMBER           => lv_cttl_rec.load_ci_sequence_number,
                         X_MODE                              =>  'R',
             X_ATTRIBUTE_CATEGORY =>  lv_psd_rec.ATTRIBUTE_CATEGORY,
             X_ATTRIBUTE1               =>  lv_psd_rec.ATTRIBUTE1,
             X_ATTRIBUTE2                               =>  lv_psd_rec.ATTRIBUTE2,
             X_ATTRIBUTE3                               =>  lv_psd_rec.ATTRIBUTE3,
             X_ATTRIBUTE4                               =>  lv_psd_rec.ATTRIBUTE4,
             X_ATTRIBUTE5                               =>  lv_psd_rec.ATTRIBUTE5,
             X_ATTRIBUTE6                               =>  lv_psd_rec.ATTRIBUTE6,
             X_ATTRIBUTE7                               =>  lv_psd_rec.ATTRIBUTE7,
             x_ATTRIBUTE8                       =>  lv_psd_rec.ATTRIBUTE8,
             X_ATTRIBUTE9                       =>  lv_psd_rec.ATTRIBUTE9,
             X_ATTRIBUTE10                      =>  lv_psd_rec.ATTRIBUTE10,
             X_ATTRIBUTE11                      =>  lv_psd_rec.ATTRIBUTE11,
             X_ATTRIBUTE12                      =>  lv_psd_rec.ATTRIBUTE12,
             X_ATTRIBUTE13                        =>  lv_psd_rec.ATTRIBUTE13,
             X_ATTRIBUTE14                        =>  lv_psd_rec.ATTRIBUTE14,
             X_ATTRIBUTE15                        =>  lv_psd_rec.ATTRIBUTE15,
             X_ATTRIBUTE16                        =>  lv_psd_rec.ATTRIBUTE16,
             X_ATTRIBUTE17                        =>  lv_psd_rec.ATTRIBUTE17,
             X_ATTRIBUTE18                              =>  lv_psd_rec.ATTRIBUTE18,
             X_ATTRIBUTE19                        =>  lv_psd_rec.ATTRIBUTE19,
             X_ATTRIBUTE20                        =>  lv_psd_rec.ATTRIBUTE20);

          ELSE
          --only update the recent admittance fields
            Igs_Pe_Stat_Details_Pkg.update_row (
                          x_rowid                             => lv_psd_rec.rowid,
                          x_person_id                         => lv_psd_rec.person_id    ,
                          x_effective_start_date              => lv_psd_rec.effective_start_date,
                          x_effective_end_date                => lv_psd_rec.effective_end_date,
                          x_religion_cd                       => lv_psd_rec.religion_cd,
                          x_socio_eco_cd                      => lv_psd_rec.socio_eco_cd,
                            x_next_to_kin                       => lv_psd_rec.next_to_kin,
                            x_in_state_tuition                  => lv_psd_rec.in_state_tuition,
                            x_tuition_st_date                   => lv_psd_rec.tuition_st_date,
                            x_tuition_end_date                  => lv_psd_rec.tuition_end_date,
                            x_further_education_cd              => lv_psd_rec.further_education_cd,
                          X_MATR_CAL_TYPE                     => lv_psd_rec.MATR_CAL_TYPE,
                          X_MATR_SEQUENCE_NUMBER              => lv_psd_rec.MATR_SEQUENCE_NUMBER,
                          X_INIT_CAL_TYPE                     => lv_psd_rec.INIT_CAL_TYPE,
                          X_INIT_SEQUENCE_NUMBER              => lv_psd_rec.INIT_SEQUENCE_NUMBER,
                          X_RECENT_CAL_TYPE                   => lv_cttl_rec.load_cal_type,
                          X_RECENT_SEQUENCE_NUMBER            => lv_cttl_rec.load_ci_sequence_number,
                          X_CATALOG_CAL_TYPE                  => lv_psd_rec.CATALOG_CAL_TYPE ,
                          X_CATALOG_SEQUENCE_NUMBER           => lv_psd_rec.CATALOG_SEQUENCE_NUMBER,
                          X_MODE                              =>  'R' ,
            X_ATTRIBUTE_CATEGORY =>  lv_psd_rec.ATTRIBUTE_CATEGORY,
             X_ATTRIBUTE1               =>  lv_psd_rec.ATTRIBUTE1,
             X_ATTRIBUTE2                               =>  lv_psd_rec.ATTRIBUTE2,
             X_ATTRIBUTE3                               =>  lv_psd_rec.ATTRIBUTE3,
             X_ATTRIBUTE4                               =>  lv_psd_rec.ATTRIBUTE4,
             X_ATTRIBUTE5                               =>  lv_psd_rec.ATTRIBUTE5,
             X_ATTRIBUTE6                               =>  lv_psd_rec.ATTRIBUTE6,
             X_ATTRIBUTE7                               =>  lv_psd_rec.ATTRIBUTE7,
             x_ATTRIBUTE8                       =>  lv_psd_rec.ATTRIBUTE8,
             X_ATTRIBUTE9                       =>  lv_psd_rec.ATTRIBUTE9,
             X_ATTRIBUTE10                      =>  lv_psd_rec.ATTRIBUTE10,
             X_ATTRIBUTE11                      =>  lv_psd_rec.ATTRIBUTE11,
             X_ATTRIBUTE12                      =>  lv_psd_rec.ATTRIBUTE12,
             X_ATTRIBUTE13                        =>  lv_psd_rec.ATTRIBUTE13,
             X_ATTRIBUTE14                        =>  lv_psd_rec.ATTRIBUTE14,
             X_ATTRIBUTE15                        =>  lv_psd_rec.ATTRIBUTE15,
             X_ATTRIBUTE16                        =>  lv_psd_rec.ATTRIBUTE16,
             X_ATTRIBUTE17                        =>  lv_psd_rec.ATTRIBUTE17,
             X_ATTRIBUTE18                              =>  lv_psd_rec.ATTRIBUTE18,
             X_ATTRIBUTE19                        =>  lv_psd_rec.ATTRIBUTE19,
             X_ATTRIBUTE20                        =>  lv_psd_rec.ATTRIBUTE20);
                          NULL;

      END IF;

                  Close c_psd;
               CLOSE c_cttl;
             END IF;
           IF(c_apai%ISOPEN) THEN
             CLOSE c_apai;
          END IF;
      END IF;
--to close any cursor if open


     IF(c_psd%ISOPEN) THEN
        CLOSE c_psd;
     END IF;
     IF(c_cttl%ISOPEN) THEN
        CLOSE c_cttl;
     END IF;
     IF(c_apai%ISOPEN) THEN
        CLOSE c_apai;
     END IF;
EXCEPTION
        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_003.upd_mat_mradm_cat_terms');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

END  UPD_MAT_MRADM_CAT_TERMS;



END IGS_EN_GEN_003 ;

/
