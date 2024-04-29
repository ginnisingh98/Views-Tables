--------------------------------------------------------
--  DDL for Package Body IGS_IN_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_IN_GEN_001" AS
 /* $Header: IGSIN01B.pls 120.0 2005/06/01 21:01:06 appldev noship $ */

/* Change History :
   Who             When             What
   jbegum          25-Jun-2003      BUG#2930935
                                    Modified local procedure INQP_GET_PRG_CP
   rvivekan        09-sep-2003      Modified the behaviour of repeatable_ind
                                    column in igs_ps_unit_ver table. PSP integration build #3052433
-- rnirwani   13-Sep-2004       changed cursor c_sci, procedure inqp_get_sci, inqp_get_sca_status to not consider logically
--				deleted records and also to avoid un-approved intermission records. Bug# 3885804

*/


FUNCTION inqp_get_appl_ind(
  p_person_id IN NUMBER )
RETURN BOOLEAN AS
       gv_other_detail             VARCHAR2(255);
BEGIN  -- inqp_get_appl_ind
       -- This module determines if the student is an applicant.
       -- An applicant is a person that has an incomplete application.
DECLARE
       cst_completed CONSTANT      VARCHAR2(12) := 'COMPLETED';
       cst_withdrawn CONSTANT      VARCHAR2(12) := 'WITHDRAWN';
       v_dummy                            VARCHAR2(1);
       CURSOR c_aa IS
              SELECT 'x'
              FROM   IGS_AD_APPL   aa
              WHERE  aa.person_id         = p_person_id AND
                     aa.adm_appl_status   IN
                            (SELECT       aas.adm_appl_status
                            FROM   IGS_AD_APPL_STAT     aas
                            WHERE  aas.s_adm_appl_status NOT IN
                                                        (cst_completed,
                                                        cst_withdrawn));
BEGIN
       OPEN c_aa;
       FETCH c_aa INTO v_dummy;
       IF (c_aa%NOTFOUND) THEN
              CLOSE c_aa;
              RETURN FALSE;
       END IF;
       CLOSE c_aa;
       RETURN TRUE;
EXCEPTION
       WHEN OTHERS THEN
              IF c_aa%ISOPEN THEN
                     CLOSE c_aa;
              END IF;
              RAISE;
END;
EXCEPTION
       WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_IN_GEN_001. 1');
              IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
END inqp_get_appl_ind;


FUNCTION inqp_get_encmb(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_level IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_serious_only_ind IN VARCHAR2 ,
  p_include_all_course_ind IN VARCHAR2 ,
  p_academic_ind OUT NOCOPY VARCHAR2 ,
  p_admin_ind OUT NOCOPY VARCHAR2 )
RETURN boolean AS
       gv_other_detail             VARCHAR2(255);
BEGIN  -- inqp_get_encmb
       -- Retrieve encumbrance lamps, at a number of possible detail levels, being:
       -- ALL        - Will return true if encumbrances exist for the person at any level
       -- PERSON     - Will return true if encumbrances exist against the person
       -- ENROLMENT  - Will return true if encumbrances exist against either course
       --              or units
       -- COURSE     - Will return true if encumbrances exist against the course
       -- UNITSET    - Will return true if encumbrances exist against the unit set
       -- UNIT              - Will return true if encumbrances exist against any unit
       -- The 'p_include_all_course' parameter controls which course based
       -- ncumbrances are reported at the COURSE level. eg. Unit exclusions and unit
       -- set exclusions don't directly affect the course, and as such only sometimes
       -- result in a lamp. This indicator is only really applicable to 'COURSE'
       -- level calls.
DECLARE
       cst_academic  CONSTANT      IGS_FI_ENCMB_TYPE.s_encumbrance_cat%TYPE := 'ACADEMIC';
       cst_sus_srvc  CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'SUS_SRVC';
       cst_rvk_srvc  CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'RVK_SRVC';
       cst_exc_course       CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'EXC_COURSE';
       cst_sus_course       CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'SUS_COURSE';
       cst_exc_crs_gp       CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'EXC_CRS_GP';
       cst_exc_crs_u CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'EXC_CRS_U';
       cst_rqrd_crs_u       CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'RQRD_CRS_U';
       cst_exc_crs_us       CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'EXC_CRS_US';
       cst_rstr_ge_cp       CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'RSTR_GE_CP';
       cst_rstr_le_cp       CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'RSTR_LE_CP';
       cst_rstr_at_ty       CONSTANT
                                   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE := 'RSTR_AT_TY';
       cst_all              CONSTANT      VARCHAR2(10) := 'ALL';
       cst_person    CONSTANT      VARCHAR2(10) := 'PERSON';
       cst_course    CONSTANT      VARCHAR2(10) := 'COURSE';
       cst_enrolment CONSTANT      VARCHAR2(10) := 'ENROLMENT';
       cst_unitset   CONSTANT      VARCHAR2(10) := 'UNITSET';
       cst_unit      CONSTANT      VARCHAR2(10) := 'UNIT';
       v_dummy                            VARCHAR2(1);
       v_person_exists                    BOOLEAN;
       v_enrol_academic_exists            BOOLEAN;
       v_enrol_admin_exists        BOOLEAN;
       v_course_academic_exists    BOOLEAN;
       v_course_academic_direct    BOOLEAN;
       v_course_admin_exists              BOOLEAN;
       v_course_admin_direct              BOOLEAN;
       v_unitset_academic_exists   BOOLEAN;
       v_unitset_admin_exists             BOOLEAN;
       v_unit_academic_exists             BOOLEAN;
       v_unit_admin_exists         BOOLEAN;
       v_academic_ind                     VARCHAR2(1);
       v_administrative_ind        VARCHAR2(1);
       CURSOR c_pen_et IS
              SELECT pen.person_id,
                     pen.encumbrance_type,
                     pen.start_dt,
                     et.s_encumbrance_cat
              FROM   IGS_PE_PERS_ENCUMB   pen,
                     IGS_FI_ENCMB_TYPE    et
              WHERE  pen.person_id        = p_person_id AND
                     pen.start_dt         <= p_effective_dt AND
                     (pen.expiry_dt              IS NULL OR
                     pen.expiry_dt        > p_effective_dt) AND
                     et.encumbrance_type  = pen.encumbrance_type;
       CURSOR c_pee (
              cp_person_id         IGS_PE_PERS_ENCUMB.person_id%TYPE,
              cp_encumbrance_type  IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
              cp_start_dt          IGS_PE_PERS_ENCUMB.start_dt%TYPE) IS
              SELECT pee.course_cd,
                     pee.person_id,
                     pee.encumbrance_type,
                     pee.pen_start_dt,
                     pee.s_encmb_effect_type,
                     pee.pee_start_dt,
                     pee.sequence_number
              FROM   IGS_PE_PERSENC_EFFCT pee
              WHERE  -- child of current pen record
                     pee.person_id        = cp_person_id AND
                     pee.encumbrance_type = cp_encumbrance_type AND
                     pee.pen_start_dt     = cp_start_dt AND
                     pee.pee_start_dt     <= p_effective_dt AND
                     (pee.expiry_dt              IS NULL OR
                     pee.expiry_dt        > p_effective_dt) AND
                     (p_course_cd         IS NULL OR
                     pee.course_cd        IS NULL OR
                     pee.course_cd        = p_course_cd);
       CURSOR c_pce (
              cp_person_id         IGS_PE_PERSENC_EFFCT.person_id%TYPE,
              cp_encumbrance_type  IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
              cp_pen_start_dt             IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
              cp_s_encmb_effect_type      IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
              cp_pee_start_dt             IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
              cp_sequence_number   IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
              SELECT 'X'
              FROM   IGS_PE_COURSE_EXCL   pce
              WHERE  -- child of current pee record
                     pce.person_id        = cp_person_id AND
                     pce.encumbrance_type = cp_encumbrance_type AND
                     pce.pen_start_dt     = cp_pen_start_dt AND
                     pce.s_encmb_effect_type     = cp_s_encmb_effect_type AND
                     pce.pee_start_dt     = cp_pee_start_dt AND
                     pce.pee_sequence_number     = cp_sequence_number AND
                     pce.pce_start_dt     <= p_effective_dt AND
                     (pce.expiry_dt              IS NULL OR
                     pce.expiry_dt        > p_effective_dt) AND
                     pce.course_cd        = p_course_cd;
       CURSOR c_pcge (
              cp_person_id         IGS_PE_PERSENC_EFFCT.person_id%TYPE,
              cp_encumbrance_type  IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
              cp_pen_start_dt             IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
              cp_s_encmb_effect_type      IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
              cp_pee_start_dt             IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
              cp_sequence_number   IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
              SELECT 'X'
              FROM   IGS_PE_CRS_GRP_EXCL  pcge
              WHERE  -- child of current pee record
                     pcge.person_id                     = cp_person_id AND
                     pcge.encumbrance_type              = cp_encumbrance_type AND
                     pcge.pen_start_dt           = cp_pen_start_dt AND
                     pcge.s_encmb_effect_type    = cp_s_encmb_effect_type AND
                     pcge.pee_start_dt           = cp_pee_start_dt AND
                     pcge.pee_sequence_number    = cp_sequence_number AND
                     pcge.pcge_start_dt   <= p_effective_dt AND
                     (pcge.expiry_dt             IS NULL OR
                     pcge.expiry_dt              > p_effective_dt) AND
                     EXISTS (
                            SELECT 'X'
                            FROM   IGS_PS_GRP_MBR       cgm
                            WHERE  cgm.course_group_cd  = pcge.course_group_cd AND
                                   cgm.course_cd        = p_course_cd);
       CURSOR c_pue (
              cp_person_id         IGS_PE_PERSENC_EFFCT.person_id%TYPE,
              cp_encumbrance_type  IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
              cp_pen_start_dt             IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
              cp_s_encmb_effect_type      IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
              cp_pee_start_dt             IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
              cp_sequence_number   IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
              SELECT 'X'
              FROM   IGS_PE_PERS_UNT_EXCL pue
              WHERE  -- child of current pee record
                     pue.person_id        = cp_person_id AND
                     pue.encumbrance_type = cp_encumbrance_type AND
                     pue.pen_start_dt     = cp_pen_start_dt AND
                     pue.s_encmb_effect_type     = cp_s_encmb_effect_type AND
                     pue.pee_start_dt     = cp_pee_start_dt AND
                     pue.pee_sequence_number     = cp_sequence_number AND
                     pue.pue_start_dt     <= p_effective_dt AND
                     (pue.expiry_dt              IS NULL OR
                     pue.expiry_dt        > p_effective_dt);
       CURSOR c_pur (
              cp_person_id         IGS_PE_PERSENC_EFFCT.person_id%TYPE,
              cp_encumbrance_type  IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
              cp_pen_start_dt             IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
              cp_s_encmb_effect_type      IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
              cp_pee_start_dt             IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
              cp_sequence_number   IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
              SELECT 'X'
              FROM   IGS_PE_UNT_REQUIRMNT pur
              WHERE  -- child of current pee record
                     pur.person_id        = cp_person_id AND
                     pur.encumbrance_type = cp_encumbrance_type AND
                     pur.pen_start_dt     = cp_pen_start_dt AND
                     pur.s_encmb_effect_type     = cp_s_encmb_effect_type AND
                     pur.pee_start_dt     = cp_pee_start_dt AND
                     pur.pee_sequence_number     = cp_sequence_number AND
                     pur.pur_start_dt     <= p_effective_dt AND
                     (pur.expiry_dt              IS NULL OR
                     pur.expiry_dt        > p_effective_dt);
       CURSOR c_puse (
              cp_person_id         IGS_PE_PERSENC_EFFCT.person_id%TYPE,
              cp_encumbrance_type  IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
              cp_pen_start_dt             IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
              cp_s_encmb_effect_type      IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
              cp_pee_start_dt             IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
              cp_sequence_number   IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
              SELECT 'X'
              FROM   IGS_PE_UNT_SET_EXCL  puse
              WHERE  -- child of current pee record
                     puse.person_id                     = cp_person_id AND
                     puse.encumbrance_type              = cp_encumbrance_type AND
                     puse.pen_start_dt           = cp_pen_start_dt AND
                     puse.s_encmb_effect_type    = cp_s_encmb_effect_type AND
                     puse.pee_start_dt           = cp_pee_start_dt AND
                     puse.pee_sequence_number    = cp_sequence_number AND
                     puse.puse_start_dt   <= p_effective_dt AND
                     (puse.expiry_dt             IS NULL OR
                     puse.expiry_dt              > p_effective_dt);
BEGIN
       -- Set the varaibles, not the OUT NOCOPY parameters because we want to
       -- read these values and OUT NOCOPY values cannot be read
       v_administrative_ind := 'N';
       v_academic_ind := 'N';
       v_person_exists := FALSE;
       v_enrol_academic_exists := FALSE;
       v_enrol_admin_exists := FALSE;
       v_course_academic_exists := FALSE;
       v_course_academic_direct := FALSE;
       v_course_admin_exists := FALSE;
       v_course_admin_direct := FALSE;
       v_unitset_academic_exists := FALSE;
       v_unitset_admin_exists := FALSE;
       v_unit_academic_exists := FALSE;
       v_unit_admin_exists := FALSE;
       FOR v_pen_et_rec IN c_pen_et LOOP
              FOR v_pee_rec IN c_pee(
                                   v_pen_et_rec.person_id,
                                   v_pen_et_rec.encumbrance_type,
                                   v_pen_et_rec.start_dt) LOOP
                     IF v_pee_rec.course_cd IS NULL THEN
                            -- Person based encumbrance exists
                            IF p_serious_only_ind = 'N' OR
                                          (v_pee_rec.s_encmb_effect_type IN (
                                                                      cst_sus_srvc,
                                                                      cst_rvk_srvc)) THEN
                                   v_person_exists := TRUE;
                            END IF;
                            -- Check for person encumbrances which affect courses
                            IF v_pee_rec.s_encmb_effect_type IN (
                                                        cst_sus_srvc,
                                                        cst_rvk_srvc) THEN
                                   IF v_pen_et_rec.s_encumbrance_cat = cst_academic THEN
                                          v_course_academic_exists := TRUE;
                                          v_course_academic_direct := TRUE;
                                          v_unitset_academic_exists := TRUE;
                                          v_unit_academic_exists := TRUE;
                                   ELSE
                                          v_course_admin_exists := TRUE;
                                          v_course_admin_direct := TRUE;
                                          v_unitset_admin_exists := TRUE;
                                          v_unit_admin_exists := TRUE;
                                   END IF;
                            END IF;
                            IF v_pee_rec.s_encmb_effect_type IN (
                                                        cst_exc_course,
                                                        cst_sus_course,
                                                        cst_exc_crs_gp) THEN
                                   IF p_course_cd IS NULL THEN
                                          -- Any course exclusion/suspension affects if no
                                          -- course code parameter specified
                                          IF v_pen_et_rec.s_encumbrance_cat = cst_academic THEN
                                                 v_course_academic_exists := TRUE;
                                          ELSE
                                                 v_course_admin_exists := TRUE;
                                          END IF;
                                   ELSE
                                          -- Check that the context course (parameter) is in the
                                          -- exclusion set; only if it does the encumbrance apply
                                          OPEN c_pce(
                                                 v_pee_rec.person_id,
                                                 v_pee_rec.encumbrance_type,
                                                 v_pee_rec.pen_start_dt,
                                                 v_pee_rec.s_encmb_effect_type,
                                                 v_pee_rec.pee_start_dt,
                                                 v_pee_rec.sequence_number);
                                          FETCH c_pce INTO v_dummy;
                                          IF c_pce%FOUND THEN
                                                 IF v_pen_et_rec.s_encumbrance_cat = cst_academic THEN
                                                        v_course_academic_exists := TRUE;
                                                        v_course_academic_direct := TRUE;
                                                 ELSE
                                                        v_course_admin_exists := TRUE;
                                                        v_course_admin_direct := TRUE;
                                                 END IF;
                                          ELSE
                                                 OPEN c_pcge (
                                                        v_pee_rec.person_id,
                                                        v_pee_rec.encumbrance_type,
                                                        v_pee_rec.pen_start_dt,
                                                        v_pee_rec.s_encmb_effect_type,
                                                        v_pee_rec.pee_start_dt,
                                                        v_pee_rec.sequence_number);
                                                 FETCH c_pcge INTO v_dummy;
                                                 IF c_pcge%FOUND THEN
                                                        IF v_pen_et_rec.s_encumbrance_cat = cst_academic THEN
                                                               v_course_academic_exists := TRUE;
                                                               v_course_academic_direct := TRUE;
                                                        ELSE
                                                               v_course_admin_exists := TRUE;
                                                               v_course_admin_direct := TRUE;
                                                        END IF;
                                                 END IF;
                                                 CLOSE c_pcge;
                                          END IF;
                                          CLOSE c_pce;
                                   END IF;
                            END IF;
                     ELSE -- pee.course_cd is not null
                            -- Course Based Encumbrance
                            IF v_pen_et_rec.s_encumbrance_cat = cst_academic THEN
                                   -- Ignore detail exclusions - these are picked up below
                                   IF v_pee_rec.s_encmb_effect_type NOT IN (
                                                               cst_exc_crs_u,
                                                               cst_rqrd_crs_u,
                                                               cst_exc_crs_us) THEN
                                          v_course_academic_exists := TRUE;
                                   END IF;
                                   -- Encumbrance directly affecting the course atempt
                                   IF v_pee_rec.s_encmb_effect_type IN (
                                                               cst_sus_srvc,
                                                               cst_rvk_srvc,
                                                               cst_exc_course,
                                                               cst_sus_course,
                                                               cst_exc_crs_gp,
                                                               cst_rstr_ge_cp,
                                                               cst_rstr_le_cp,
                                                               cst_rstr_at_ty) THEN
                                          v_course_academic_direct := TRUE;
                                   END IF;
                            ELSE
                                   -- Ignore detail exclusions - these are picked up below
                                   IF v_pee_rec.s_encmb_effect_type NOT IN (
                                                               cst_exc_crs_u,
                                                               cst_rqrd_crs_u,
                                                               cst_exc_crs_us) THEN
                                          v_course_admin_exists := TRUE;
                                   END IF;
                                   -- Encumbrance directly affecting the course attempt
                                   IF v_pee_rec.s_encmb_effect_type IN (
                                                               cst_sus_srvc,
                                                               cst_rvk_srvc,
                                                               cst_exc_course,
                                                               cst_sus_course,
                                                               cst_exc_crs_gp,
                                                               cst_rstr_ge_cp,
                                                               cst_rstr_le_cp,
                                                               cst_rstr_le_cp,
                                                               cst_rstr_at_ty) THEN
                                          v_course_admin_direct := TRUE;
                                   END IF;
                            END IF;
                     END IF;
                     IF v_pee_rec.s_encmb_effect_type = cst_exc_crs_u THEN
                            -- Check for unit exclusions
                            OPEN c_pue (
                                   v_pee_rec.person_id,
                                   v_pee_rec.encumbrance_type,
                                   v_pee_rec.pen_start_dt,
                                   v_pee_rec.s_encmb_effect_type,
                                   v_pee_rec.pee_start_dt,
                                   v_pee_rec.sequence_number);
                            FETCH c_pue INTO v_dummy;
                            IF c_pue%FOUND THEN
                                   IF v_pen_et_rec.s_encumbrance_cat = cst_academic THEN
                                          v_unit_academic_exists := TRUE;
                                          v_course_academic_exists := TRUE;
                                   ELSE
                                          v_unit_admin_exists := TRUE;
                                          v_course_admin_exists := TRUE;
                                   END IF;
                            END IF;
                            CLOSE c_pue;
                     END IF;
                     IF v_pee_rec.s_encmb_effect_type = cst_rqrd_crs_u THEN
                            -- Check for required units
                            OPEN c_pur (
                                   v_pee_rec.person_id,
                                   v_pee_rec.encumbrance_type,
                                   v_pee_rec.pen_start_dt,
                                   v_pee_rec.s_encmb_effect_type,
                                   v_pee_rec.pee_start_dt,
                                   v_pee_rec.sequence_number);
                            FETCH c_pur INTO v_dummy;
                            IF c_pur%FOUND THEN
                                   IF v_pen_et_rec.s_encumbrance_cat = cst_academic THEN
                                          v_unit_academic_exists := TRUE;
                                          v_course_academic_exists := TRUE;
                                   ELSE
                                          v_unit_admin_exists := TRUE;
                                          v_course_admin_exists := TRUE;
                                   END IF;
                            END IF;
                            CLOSE c_pur;
                     END IF;
                     IF v_pee_rec.s_encmb_effect_type = cst_exc_crs_us THEN
                            -- Check for unit set exclusions
                            OPEN c_puse (
                                   v_pee_rec.person_id,
                                   v_pee_rec.encumbrance_type,
                                   v_pee_rec.pen_start_dt,
                                   v_pee_rec.s_encmb_effect_type,
                                   v_pee_rec.pee_start_dt,
                                   v_pee_rec.sequence_number);
                            FETCH c_puse INTO v_dummy;
                            IF c_puse%FOUND THEN
                                   IF v_pen_et_rec.s_encumbrance_cat = cst_academic THEN
                                          v_unitset_academic_exists := TRUE;
                                          v_course_academic_exists := TRUE;
                                   ELSE
                                          v_unitset_admin_exists := TRUE;
                                          v_course_admin_exists := TRUE;
                                   END IF;
                            END IF;
                            CLOSE c_puse;
                     END IF;
              END LOOP;
       END LOOP;
       -- Set the appropriate flags depending on the
       -- level of checking which is being performed
       IF p_level = cst_all THEN
              IF v_person_exists = TRUE THEN
                     v_administrative_ind := 'Y';
              END IF;
              IF (v_course_academic_exists = TRUE OR
                            v_unitset_academic_exists = TRUE OR
                            v_unit_academic_exists = TRUE) THEN
                     v_academic_ind := 'Y';
              END IF;
              IF (v_course_admin_exists = TRUE OR
                            v_unitset_admin_exists = TRUE OR
                            v_unit_admin_exists = TRUE) THEN
                     v_administrative_ind := 'Y';
              END IF;
       ELSIF p_level = cst_person THEN
              IF v_person_exists = TRUE THEN
                     v_administrative_ind := 'Y';
              END IF;
       ELSIF p_level = cst_course THEN
              IF p_include_all_course_ind = 'Y' THEN
                     IF v_course_academic_exists = TRUE THEN
                            v_academic_ind := 'Y';
                     END IF;
                     IF v_course_admin_exists = TRUE THEN
                            v_administrative_ind := 'Y';
                     END IF;
              ELSE
                     IF v_course_academic_direct = TRUE THEN
                            v_academic_ind := 'Y';
                     END IF;
                     IF v_course_admin_direct = TRUE THEN
                            v_administrative_ind := 'Y';
                     END IF;
              END IF;
       ELSIF p_level = cst_enrolment THEN
              IF (v_course_academic_exists = TRUE OR
                            v_unitset_academic_exists = TRUE OR
                            v_unit_academic_exists = TRUE) THEN
                     v_academic_ind := 'Y';
              END IF;
              IF (v_course_admin_exists = TRUE OR
                            v_unitset_admin_exists = TRUE OR
                            v_unit_admin_exists = TRUE) THEN
                     v_administrative_ind := 'Y';
              END IF;
       ELSIF p_level = cst_unitset THEN
              IF v_unitset_academic_exists = TRUE THEN
                     v_academic_ind := 'Y';
              END IF;
              IF v_unitset_admin_exists = TRUE THEN
                     v_administrative_ind := 'Y';
              END IF;
       ELSIF p_level = cst_unit THEN
              IF v_unit_academic_exists = TRUE THEN
                     v_academic_ind := 'Y';
              END IF;
              IF v_unit_admin_exists = TRUE THEN
                     v_administrative_ind := 'Y';
              END IF;
       END IF;
       p_academic_ind := v_academic_ind;
       p_admin_ind := v_administrative_ind;
       -- If either admin or academic encumbrances exist then the routine
       -- returns true to signify that an applicable encumbrance exists.
       IF v_academic_ind = 'Y' OR
                     v_administrative_ind = 'Y' THEN
              RETURN TRUE;
       ELSE
              RETURN FALSE;
       END IF;
EXCEPTION
       WHEN OTHERS THEN
              IF (c_pen_et%ISOPEN) THEN
                     CLOSE c_pen_et;
              END IF;
              IF (c_pee%ISOPEN) THEN
                     CLOSE c_pee;
              END IF;
              IF (c_pce%ISOPEN) THEN
                     CLOSE c_pce;
              END IF;
              IF (c_pcge%ISOPEN) THEN
                     CLOSE c_pcge;
              END IF;
              IF (c_pue%ISOPEN) THEN
                     CLOSE c_pue;
              END IF;
              IF (c_pur%ISOPEN) THEN
                     CLOSE c_pur;
              END IF;
              IF (c_puse%ISOPEN) THEN
                     CLOSE c_puse;
              END IF;
              RAISE;
END;
EXCEPTION
       WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_IN_GEN_001. 2');
              IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END inqp_get_encmb;


PROCEDURE inqp_get_enr_cat(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_enrolment_cat OUT NOCOPY VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
AS
       gv_other_detail             VARCHAR2(255);
BEGIN  -- inqp_get_enr_cat
DECLARE
       v_enrolment_cat             IGS_AS_SC_ATMPT_ENR.enrolment_cat%TYPE;
       v_description        IGS_EN_ENROLMENT_CAT.description%TYPE;
       CURSOR c_scae IS
              SELECT scae.enrolment_cat,
                     ec.description
              FROM   IGS_AS_SC_ATMPT_ENR scae,
                     IGS_CA_INST ci,
                     IGS_EN_ENROLMENT_CAT ec
              WHERE  scae.person_id              = p_person_id AND
                     scae.course_cd              =p_course_cd AND
                     ci.cal_type          = scae.cal_type AND
                     ci.sequence_number   =ci_sequence_number AND
                     ec.enrolment_cat     = scae.enrolment_cat
              ORDER BY ci.end_dt DESC;
BEGIN
       -- Cursor handling
       OPEN c_scae;
       FETCH c_scae INTO    v_enrolment_cat,
                            v_description;
       IF c_scae%FOUND THEN
              CLOSE c_scae;
              --Note: use only the first record found (and the latest calendar end date)
              p_enrolment_cat      := v_enrolment_cat;
              p_description := v_description;
       ELSE
              CLOSE c_scae;
              p_enrolment_cat      := NULL;
              p_description := NULL;
       END IF;
EXCEPTION
       WHEN OTHERS THEN
              IF c_scae%ISOPEN THEN
                     CLOSE c_scae;
              END IF;
              RAISE;
END;
EXCEPTION
       WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_IN_GEN_001. 3');
              IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END inqp_get_enr_cat;


PROCEDURE inqp_get_prg_cp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cp_required OUT NOCOPY NUMBER ,
  p_cp_passed OUT NOCOPY NUMBER ,
  p_adv_granted OUT NOCOPY NUMBER ,
  p_enrolled_cp OUT NOCOPY NUMBER ,
  p_cp_remaining OUT NOCOPY NUMBER )
AS
       gv_other_detail             VARCHAR2(255);
BEGIN  -- func_module
DECLARE
       cst_enrolled  CONSTANT
                     IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'ENROLLED';
       v_crv_credit_points_required       IGS_PS_VER.credit_points_required%TYPE;
       v_enrolled_total            NUMBER;
       v_cp_required               IGS_PS_VER.credit_points_required%TYPE;
       v_cp_passed                 NUMBER;
       v_adv_granted               NUMBER;
       v_cp_remaining                     NUMBER;
       CURSOR c_crv IS
              SELECT crv.credit_points_required
              FROM   IGS_PS_VER crv
              WHERE  crv.course_cd        = p_course_cd AND
                     crv.version_number   = p_version_number;


       --Who             When             What
       --jbegum          25-Jun-2003      BUG#2930935 - Modified cursor c_sua_uv.

       CURSOR c_sua_uv IS
              SELECT SUM( NVL(sua.override_achievable_cp,
                              NVL( NVL(cps.achievable_credit_points,uv.achievable_credit_points),
                                   NVL(cps.enrolled_credit_points,uv.enrolled_credit_points)
                                 )
                             )
                        )
              FROM   IGS_EN_SU_ATTEMPT sua,
                     IGS_PS_UNIT_VER uv ,
                     IGS_PS_USEC_CPS cps
              WHERE  sua.person_id        = p_person_id        AND
                     sua.course_cd        = p_course_cd               AND
                     sua.unit_attempt_status     = cst_enrolled              AND
                     sua.ci_start_dt             <= TRUNC(SYSDATE)    AND
                     sua.uoo_id = cps.uoo_id (+) AND
                     uv.unit_cd           = sua.unit_cd        AND
                     uv.version_number           = sua.version_number;
BEGIN
       --Select the required credit points from the students course version
       OPEN c_crv;
       FETCH c_crv INTO v_crv_credit_points_required;
       IF c_crv%FOUND THEN
              v_cp_required := v_crv_credit_points_required;
       ELSE
              v_cp_required := 0;
       END IF;
       CLOSE c_crv;
       --Total the advanced standing for a student
       v_adv_granted := IGS_AV_GEN_001.ADVP_GET_AS_TOTAL(      p_person_id,
                                          p_course_cd,
                                          TRUNC(SYSDATE));
       --Call routine to derive the credit points passed by the student
       v_cp_passed := (IGS_EN_GEN_001.ENRP_CLC_SCA_PASS_CP(    p_person_id,
                                          p_course_cd,
                                          TRUNC(SYSDATE)) - v_adv_granted);
       --Derived the number of credit points in which the student is currently
       -- enrolled
       OPEN c_sua_uv;
       FETCH c_sua_uv INTO v_enrolled_total;
       IF c_sua_uv%FOUND AND v_enrolled_total IS NOT NULL THEN
              p_enrolled_cp := v_enrolled_total;
       ELSE
              p_enrolled_cp := 0;
       END IF;
       CLOSE c_sua_uv;
       --Calculate the credit points remaining based on the above figures.
       v_cp_remaining := (v_cp_required -
                     v_cp_passed -
                     v_adv_granted);
       IF v_cp_remaining < 0 THEN
              p_cp_remaining := 0;
       ELSE
              p_cp_remaining := v_cp_remaining;
       END IF;
       p_cp_required := v_cp_required;
       p_cp_passed   := v_cp_passed;
       p_adv_granted := v_adv_granted;
EXCEPTION
       WHEN OTHERS THEN
              IF c_crv%ISOPEN THEN
                     CLOSE c_crv;
              END IF;
              IF c_sua_uv%ISOPEN THEN
                     CLOSE c_sua_uv;
              END IF;
              RAISE;
END;
EXCEPTION
       WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_IN_GEN_001. 4');
              IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END inqp_get_prg_cp;


PROCEDURE inqp_get_sca_status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_attempt_status IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_discontinued_dt IN DATE ,
  p_discontinuation_reason_cd IN VARCHAR2 ,
  p_lapsed_dt IN DATE ,
  p_status_dt OUT NOCOPY DATE ,
  p_reason_cd OUT NOCOPY VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
AS
       gv_other_detail                    VARCHAR2(255);
BEGIN  -- inqp_get_sca_status
DECLARE
       cst_unconfirm CONSTANT      VARCHAR2(9) := 'UNCONFIRM';
       cst_enrolled  CONSTANT      VARCHAR2(8) := 'ENROLLED';
       cst_inactive  CONSTANT      VARCHAR2(8) := 'INACTIVE';
       cst_discontin CONSTANT      VARCHAR2(9) := 'DISCONTIN';
       cst_lapsed    CONSTANT      VARCHAR2(6) := 'LAPSED';
       cst_intermit  CONSTANT      VARCHAR2(8) := 'INTERMIT';
       cst_completed CONSTANT      VARCHAR2(9) := 'COMPLETED';
       v_drc_description                  IGS_EN_DCNT_REASONCD.description%TYPE;
       v_sci_start_dt                     IGS_EN_STDNT_PS_INTM.start_dt%TYPE;
       v_scah_hist_end_dt                 IGS_AS_SC_ATTEMPT_H.hist_end_dt%TYPE;
       CURSOR c_drc IS
              SELECT drc.description
              FROM   IGS_EN_DCNT_REASONCD drc
              WHERE  drc.discontinuation_reason_cd = p_discontinuation_reason_cd;
       CURSOR c_sci IS
              SELECT sci.start_dt
              FROM   IGS_EN_STDNT_PS_INTM sci,
                     IGS_EN_INTM_TYPES eit
              WHERE  sci.person_id               = p_person_id AND
                     sci.course_cd               = p_course_cd AND
                     sci.start_dt         <= TRUNC(SYSDATE) AND
                     sci.end_dt           >= TRUNC(SYSDATE) AND
		     sci.approved  = eit.appr_reqd_ind AND
                     eit.intermission_type = sci.intermission_type AND
                     sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY');
       CURSOR c_scah IS
              SELECT scah.hist_end_dt
              FROM   IGS_AS_SC_ATTEMPT_H scah
              WHERE  person_id            = p_person_id AND
                     course_cd            = p_course_cd AND
                     course_attempt_status       IS NOT NULL
              ORDER BY hist_end_dt DESC;  --(use the first record)
BEGIN
       IF p_course_attempt_status = cst_unconfirm THEN
              p_status_dt := NULL;
       ELSIF p_course_attempt_status = cst_enrolled THEN
              p_status_dt := p_commencement_dt;
       ELSIF p_course_attempt_status = cst_inactive THEN
              p_status_dt := p_commencement_dt;
       ELSIF p_course_attempt_status = cst_discontin THEN
              p_status_dt := p_discontinued_dt;
              p_reason_cd := p_discontinuation_reason_cd;
              OPEN c_drc;
              FETCH c_drc INTO v_drc_description;
              IF c_drc%FOUND THEN
                     p_description := v_drc_description;
              END IF;
              CLOSE c_drc;
       ELSIF p_course_attempt_status = cst_lapsed THEN
              p_status_dt := p_lapsed_dt;
       ELSIF p_course_attempt_status = cst_intermit THEN
              OPEN c_sci;
              FETCH c_sci INTO v_sci_start_dt;
              IF c_sci%FOUND THEN
                     p_status_dt := v_sci_start_dt;
              END IF;
              CLOSE c_sci;
       ELSIF p_course_attempt_status = cst_completed THEN
              OPEN c_scah;
              FETCH c_scah INTO v_scah_hist_end_dt;
              IF c_scah %FOUND THEN
                     p_status_dt := v_scah_hist_end_dt;
              ELSE
                     p_status_dt := NULL;
              END IF;
              CLOSE c_scah;
       END IF;
EXCEPTION
       WHEN OTHERS THEN
              IF c_drc %ISOPEN THEN
                     CLOSE c_drc;
              END IF;
              IF c_sci %ISOPEN THEN
                     CLOSE c_sci;
              END IF;
              IF c_scah %ISOPEN THEN
                     CLOSE c_scah;
              END IF;
              RAISE;
END;
EXCEPTION
       WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_IN_GEN_001. 5');
              IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END inqp_get_sca_status;


PROCEDURE inqp_get_scho(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option OUT NOCOPY VARCHAR2 ,
  p_tax_file_number_ind OUT NOCOPY VARCHAR2 ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE )
AS
       gv_other_detail             VARCHAR2(255);
BEGIN  -- inqp_get_scho
DECLARE
       v_scho_hecs_payment_option  IGS_EN_STDNTPSHECSOP.hecs_payment_option%TYPE;
       v_scho_tax_file_number      VARCHAR2(10);
       v_scho_start_dt             IGS_EN_STDNTPSHECSOP.start_dt%TYPE;
       v_scho_end_dt        IGS_EN_STDNTPSHECSOP.end_dt%TYPE;
       CURSOR c_scho IS
              SELECT scho.hecs_payment_option,
                     scho.tax_file_number,
                     scho.start_dt,
                     scho.end_dt
              FROM   IGS_EN_STDNTPSHECSOP scho
              WHERE  scho.person_id                     = p_person_id AND
                     scho.course_cd                     = p_course_cd AND
                     scho.start_dt                      <= SYSDATE AND
                     (scho.end_dt                IS NULL OR
                     scho.end_dt                 >= SYSDATE)
              ORDER BY start_dt ASC;             --(only use the first and earliest record);
BEGIN
       -- Cursor handling
       OPEN c_scho;
       FETCH c_scho INTO    v_scho_hecs_payment_option,
                            v_scho_tax_file_number,
                            v_scho_start_dt,
                            v_scho_end_dt;
       IF c_scho%FOUND THEN
              CLOSE c_scho;
              p_hecs_payment_option       := v_scho_hecs_payment_option;
              p_start_dt           := v_scho_start_dt;
              p_end_dt             := v_scho_end_dt;
              IF  v_scho_tax_file_number IS NOT NULL THEN
                     p_tax_file_number_ind := 'Y';
              ELSE
                     p_tax_file_number_ind := 'N';
              END IF;
       ELSE
              CLOSE c_scho;
              p_hecs_payment_option       := NULL;
              p_tax_file_number_ind       := 'N';
              p_end_dt             := NULL;
              p_start_dt           := NULL;
       END IF;
EXCEPTION
       WHEN OTHERS THEN
              IF c_scho%ISOPEN THEN
                     CLOSE c_scho;
              END IF;
              RAISE;
END;
EXCEPTION
       WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_IN_GEN_001. 6');
              IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END inqp_get_scho;


PROCEDURE inqp_get_sci(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE ,
  p_voluntary_ind OUT NOCOPY VARCHAR2 )
AS
       gv_other_detail             VARCHAR2(255);
BEGIN  -- inqp_get_sci
DECLARE
       v_sci_start_dt              IGS_EN_STDNT_PS_INTM.start_dt%TYPE;
       v_sci_end_dt         IGS_EN_STDNT_PS_INTM.end_dt%TYPE;
       v_sci_voluntary_ind         IGS_EN_STDNT_PS_INTM.voluntary_ind%TYPE;
       CURSOR c_sci IS
              SELECT sci.start_dt,
                     sci.end_dt,
                     sci.voluntary_ind
              FROM   IGS_EN_STDNT_PS_INTM sci,
		     IGS_EN_INTM_TYPES eit
              WHERE  sci.person_id = p_person_id and
                     sci.course_cd = p_course_cd and
                     sci.end_dt    >= TRUNC(SYSDATE) AND
		     sci.approved  = eit.appr_reqd_ind AND
                     eit.intermission_type = sci.intermission_type AND
                     sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
              ORDER BY start_dt;   --(use the first record)
BEGIN
       -- Cursor handling
       OPEN c_sci;
       FETCH c_sci INTO     v_sci_start_dt,
                            v_sci_end_dt,
                            v_sci_voluntary_ind;
       IF c_sci%FOUND THEN
              CLOSE c_sci;
              p_start_dt := v_sci_start_dt;
              p_end_dt := v_sci_end_dt;
              p_voluntary_ind := v_sci_voluntary_ind;
       ELSE
              CLOSE c_sci ;
              p_start_dt := NULL;
              p_end_dt := NULL;
              p_voluntary_ind := NULL;
       END IF;
EXCEPTION
       WHEN OTHERS THEN
              IF c_sci%ISOPEN THEN
                     CLOSE c_sci;
              END IF;
              RAISE;
END;
EXCEPTION
       WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_IN_GEN_001. 7');
              IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END inqp_get_sci;


FUNCTION inqp_get_sua_achvd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_version_number IN NUMBER ,
  p_ci_end_dt IN DATE ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_override_achievable_cp IN NUMBER ,
  p_s_result_type IN VARCHAR2 ,
  p_repeatable_ind IN VARCHAR2 ,
  p_achievable_credit_points IN NUMBER ,
  p_enrolled_credit_points IN NUMBER,
  p_uoo_id IN igs_en_su_attempt.uoo_id%TYPE)
RETURN NUMBER AS
/*
| Who         When            What
|
| knaraset  09-May-03   Modified cursors c_sua and c_sua1 and passed uoo_id in call IGS_AS_GEN_003.ASSP_GET_SUA_OUTCOME,
|                       as part of MUS build bug 2829262
| rvivekan   09-sep-2003   Modified the behaviour of repeatable_ind column in igs_ps_unit_ver table. PSP integration build #3052433
|
*/
       gv_other_detail             VARCHAR2(255);
BEGIN  -- inqp_get_sua_achvd
       -- Get the acheived credit points for a nominated student unit attempt,
       -- allowing for:
       --     * Checking whether the student has passed.
       --     * Repeating of units which are either allowed or disallowed
       --       as repeatable units.
DECLARE
       cst_completed CONSTANT      VARCHAR2(12) := 'COMPLETED';
       cst_duplicate CONSTANT      VARCHAR2(12) := 'DUPLICATE';
       cst_pass      CONSTANT      VARCHAR2(7) := 'PASS';
       v_override_achievable_cp    IGS_EN_SU_ATTEMPT.override_achievable_cp%TYPE;
       v_result_type               IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
       v_repeatable_ind            IGS_PS_UNIT_VER.repeatable_ind%TYPE;
       v_achievable_credit_points  IGS_PS_UNIT_VER.achievable_credit_points%TYPE;
       v_enrolled_credit_points    IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;
       v_result_found                     BOOLEAN DEFAULT FALSE;
       v_outcome_dt                DATE;
       v_grading_schema_cd         IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
       v_gs_version_number         IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
       v_grade                            IGS_AS_GRD_SCH_GRADE.grade%TYPE;
       v_mark                      IGS_AS_SU_STMPTOUT.mark%TYPE;
       v_origin_course_cd          IGS_AS_SU_STMPTOUT.course_cd%TYPE;

       CURSOR c_sua(cp_person_id igs_en_su_attempt.person_id%TYPE,
                 cp_course_cd igs_en_su_attempt.course_cd%TYPE,
                 cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
              SELECT sua.version_number,
                     sua.ci_end_dt,
                     sua.unit_attempt_status,
            sua.location_cd,
            sua.unit_class
              FROM   IGS_EN_SU_ATTEMPT    sua
              WHERE  sua.person_id        = cp_person_id AND
                     sua.course_cd        = cp_course_cd AND
                     sua.uoo_id           = cp_uoo_id;
       v_sua_rec                   c_sua%ROWTYPE;
       CURSOR c_sua1 (cp_ci_end_dt igs_en_su_attempt.ci_end_dt%TYPE,
                   cp_location_cd igs_en_su_attempt.location_cd%TYPE,
                   cp_unit_class igs_en_su_attempt.unit_class%TYPE) IS
              SELECT sua.cal_type,
                     sua.ci_sequence_number,
                     sua.unit_attempt_status,
            sua.uoo_id
              FROM   IGS_EN_SU_ATTEMPT    sua
              WHERE  sua.person_id        = p_person_id AND
                     sua.course_cd        = p_course_cd AND
                     sua.unit_cd          = p_unit_cd AND
            sua.location_cd = cp_location_cd AND
            sua.unit_class = cp_unit_class AND
                     sua.unit_attempt_status     IN (
                                          cst_completed,
                                          cst_duplicate) AND
                     TRUNC(sua.ci_end_dt) < TRUNC(cp_ci_end_dt);
       CURSOR c_uv IS
              SELECT uv.repeatable_ind
              FROM   IGS_PS_UNIT_VER      uv
              WHERE  uv.unit_cd           = p_unit_cd AND
                     uv.version_number    = p_version_number;
BEGIN
       -- If any of the unit atempt details are null then select from the
       -- student unit attempt.
       IF p_version_number IS NULL OR
                     p_ci_end_dt IS NULL OR
                     p_unit_attempt_status IS NULL THEN
              OPEN c_sua(p_person_id,p_course_cd,p_uoo_id);
              FETCH c_sua INTO v_sua_rec;
              IF c_sua%NOTFOUND THEN
                     CLOSE c_sua;
                     RETURN NULL;
              END IF;
              CLOSE c_sua;
       ELSE
              v_sua_rec.version_number := p_version_number;
              v_sua_rec.ci_end_dt := p_ci_end_dt;
              v_sua_rec.unit_attempt_status := p_unit_attempt_status;
       END IF;
       -- If not completed, no credit points could have been achieved.
       IF v_sua_rec.unit_attempt_status NOT IN (
                                          cst_completed,
                                          cst_duplicate) THEN
              RETURN 0;
       END IF;
       -- If the result type has no been specified, then call routine to\n   -- retrieve it.
       IF p_s_result_type IS NULL THEN
              v_result_type := IGS_AS_GEN_003.ASSP_GET_SUA_OUTCOME(
                                   p_person_id,
                                   p_course_cd,
                                   p_unit_cd,
                                   p_cal_type,
                                   p_ci_sequence_number,
                                   v_sua_rec.unit_attempt_status,
                                   'Y',
                                   v_outcome_dt,
                                   v_grading_schema_cd,
                                   v_gs_version_number,
                                   v_grade,
                                   v_mark,
                                   v_origin_course_cd,
                                   p_uoo_id,
--added by LKAKI----
		                   'N');
       ELSE
              v_result_type := p_s_result_type;
       END IF;
       -- If the result is not a pass then acheived credit is always zero.
       IF v_result_type <> cst_pass THEN
              RETURN 0;
       END IF;
       IF p_repeatable_ind IS NULL THEN
              OPEN c_uv;
              FETCH c_uv INTO v_repeatable_ind;
              IF c_uv%NOTFOUND THEN
                     CLOSE c_uv;
                     RETURN NULL;
              END IF;
              CLOSE c_uv;
       ELSE
              v_repeatable_ind := p_repeatable_ind;
       END IF;
       IF v_repeatable_ind <> 'X' THEN
              -- If the unit is repeatable then full credit is always granted.
              RETURN NVL(p_override_achievable_cp,
                            NVL(p_achievable_credit_points,
                                   p_enrolled_credit_points));
       ELSE
              -- If the unit isn't repeatable, only the first pass counts;
              -- ensure that this is the first pass.
              FOR v_sua1_rec IN c_sua1(v_sua_rec.ci_end_dt,v_sua_rec.location_cd,v_sua_rec.unit_class) LOOP
                     v_result_type := IGS_AS_GEN_003.ASSP_GET_SUA_OUTCOME(
                                   p_person_id,
                                   p_course_cd,
                                   p_unit_cd,
                                   v_sua1_rec.cal_type,
                                   v_sua1_rec.ci_sequence_number,
                                   v_sua1_rec.unit_attempt_status,
                                   'Y',
                                   v_outcome_dt,
                                   v_grading_schema_cd,
                                   v_gs_version_number,
                                   v_grade,
                                   v_mark,
                                   v_origin_course_cd,
                                   v_sua1_rec.uoo_id,
--added by LKAKI---
		                   'N');
                     IF v_result_type = cst_pass THEN
                            v_result_found := TRUE;
                            EXIT;
                     END IF;
              END LOOP;
              IF v_result_found THEN
                     -- Earlier pass found; no achievement.
                     RETURN 0;
              ELSE
                     RETURN NVL(p_override_achievable_cp,
                            NVL(p_achievable_credit_points,
                                   p_enrolled_credit_points));
              END IF;
       END IF;
EXCEPTION
       WHEN OTHERS THEN
              IF c_sua%ISOPEN THEN
                     CLOSE c_sua;
              END IF;
              IF c_uv%ISOPEN THEN
                     CLOSE c_uv;
              END IF;
              IF c_sua1%ISOPEN THEN
                     CLOSE c_sua1;
              END IF;
              RAISE;
END;
END inqp_get_sua_achvd;


END IGS_IN_GEN_001 ;

/
