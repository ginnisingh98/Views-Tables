--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_ENCMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_ENCMB" AS
/* $Header: IGSEN37B.pls 120.1 2006/05/18 11:32:31 amuthu noship $ */

/*------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA       |
 |                            All rights reserved.                              |
 +==============================================================================+
 |                                                                              |
 | DESCRIPTION                                                                  |
 |      PL/SQL body for package: IGS_EN_VAL_ENCMB                               |
 |                                                                              |
 |                                                                              |
 | HISTORY                                                                      |
 | Who        When         What                                                 |
 | amuthu     18-May-2006  Modified the spec for ENRP_VAL_ENR_ENCMB to pass the |
 |                         the effective date                                   |
 |-----------------------------------------------------------------------------*/
  --
  -- Validate whether a IGS_PE_PERSON is excluded from a IGS_PS_UNIT.
  FUNCTION enrp_val_excld_unit(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
        v_pue_start_dt          IGS_PE_PERS_UNT_EXCL.pue_start_dt%TYPE;
        v_expiry_dt             IGS_PE_PERS_UNT_EXCL.expiry_dt%TYPE;
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
                        pue.pee_sequence_number = pee.sequence_number AND
                        pue.unit_cd = p_unit_cd;
  BEGIN
        -- This function validates whether or not a IGS_PE_PERSON is
        -- excluded from admission or enrolment in a specific IGS_PS_UNIT.
        p_message_name := null;
        -- Validate the input parameters
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_unit_cd IS NULL OR
                        p_effective_dt IS NULL THEN
                p_message_name := null;
                RETURN TRUE;
        END IF;
        --Validate for an exclusion from the university
        IF IGS_EN_VAL_ENCMB.enrp_val_excld_prsn(
                        p_person_id,
                        p_course_cd,
                        p_effective_dt,
                        p_message_name) = FALSE THEN
                RETURN FALSE;
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
                                p_message_name := 'IGS_EN_PRSN_ENCUMB_EXC_ENR';
                                RETURN FALSE;
                        END IF;
                ELSE
                        IF p_effective_dt BETWEEN v_pue_start_dt AND (v_expiry_dt - 1) THEN
                                CLOSE c_psd_ed;
                                p_message_name := 'IGS_EN_PRSN_ENCUMB_EXC_ENR';
                                RETURN FALSE;
                        END IF;
                END IF;
        END LOOP;
        CLOSE   c_psd_ed;
        --- Return the default value
        p_message_name := null;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_excld_unit');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END enrp_val_excld_unit;
  --
  -- Validate whether or not a IGS_PE_PERSON is excluded from the university.
  FUNCTION enrp_val_excld_prsn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
        TYPE t_pee_dt_record IS RECORD (
                pee_start_dt            IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                expiry_dt               IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE);
        cst_suspend_service
                 CONSTANT IGS_EN_ENCMB_EFCTTYP_V.s_encmb_effect_type%TYPE := 'SUS_SRVC';
        cst_revoke_service
                CONSTANT IGS_EN_ENCMB_EFCTTYP_V.s_encmb_effect_type%TYPE := 'RVK_SRVC';
        v_sus_apply_to_course_ind       IGS_EN_ENCMB_EFCTTYP_V.apply_to_course_ind%TYPE;
        v_rvk_apply_to_course_ind       IGS_EN_ENCMB_EFCTTYP_V.apply_to_course_ind%TYPE;
        v_validate_sus_srvc             BOOLEAN := TRUE;
        v_validate_rvk_srvc             BOOLEAN := TRUE;
        v_pee_dates                     t_pee_dt_record;
        CURSOR c_chk_crs_for_srv_type
        ( cp_srv_type                   IGS_EN_ENCMB_EFCTTYP_V.s_encmb_effect_type%TYPE ) IS
                SELECT  apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V
                WHERE   s_encmb_effect_type = cp_srv_type;
        CURSOR c_get_pee_dates (
                cp_srv_type                     IGS_EN_ENCMB_EFCTTYP.s_encmb_effect_type%TYPE ) IS
                SELECT  pee_start_dt, expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT
                WHERE   person_id = p_person_id                 AND
                        s_encmb_effect_type = cp_srv_type;
        CURSOR c_get_pee_dates_for_crs (
                cp_srv_type                     IGS_EN_ENCMB_EFCTTYP.s_encmb_effect_type%TYPE ) IS
                SELECT  pee_start_dt, expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT
                WHERE   person_id = p_person_id                 AND
                        s_encmb_effect_type = cp_srv_type       AND
                        course_cd = p_course_cd;
  BEGIN

        --- Set the default message number
        p_message_name := null;
        --- Validate the input parameters.
        IF p_person_id IS NULL OR p_effective_dt IS NULL THEN
                RETURN TRUE;
        END IF;
        --- The requirement of the IGS_PS_COURSE code parameter (p_course_cd) is
        --- dependant on whether or not the system encumbrance effect should be applied
        --- to a IGS_PS_COURSE (s_encmb_effect_type.apply_to_course_ind).
        --- IGS_GE_NOTE: v_validate_sus_srvc and v_validate_rvk_srvc should be
        --- defaulted to True when defined.
        --- Check if a IGS_PS_COURSE code is required for the Suspended Services effect type.
        OPEN c_chk_crs_for_srv_type( cst_suspend_service );
        FETCH c_chk_crs_for_srv_type INTO v_sus_apply_to_course_ind;
        IF c_chk_crs_for_srv_type%NOTFOUND THEN
                CLOSE c_chk_crs_for_srv_type;
                v_validate_sus_srvc := FALSE;
        ELSE
                CLOSE c_chk_crs_for_srv_type;
                IF v_sus_apply_to_course_ind = 'Y' AND p_course_cd IS NULL THEN
                        v_validate_sus_srvc := FALSE;
                END IF;
        END IF;
        --- Check if a IGS_PS_COURSE code is required for the Revoked Services effect type.
        OPEN c_chk_crs_for_srv_type( cst_revoke_service );
        FETCH c_chk_crs_for_srv_type INTO v_rvk_apply_to_course_ind;
        IF c_chk_crs_for_srv_type%NOTFOUND THEN
                CLOSE c_chk_crs_for_srv_type;
                v_validate_rvk_srvc := FALSE;
        ELSE
                CLOSE c_chk_crs_for_srv_type;
                IF v_rvk_apply_to_course_ind = 'Y' AND p_course_cd IS NULL THEN
                        v_validate_rvk_srvc := FALSE;
                END IF;
        END IF;
        --- Validate for an encumbrance which suspends all services.

        IF v_validate_sus_srvc = TRUE THEN

                IF v_sus_apply_to_course_ind = 'N' THEN
                        --- Check when the Suspended Services effect type is not applied to a IGS_PS_COURSE.
                        FOR v_pee_dates IN c_get_pee_dates( cst_suspend_service ) LOOP
                                --- Validate if dates of a returned record overlap with the effective date.
                                IF v_pee_dates.expiry_dt IS NULL THEN
                                        IF v_pee_dates.pee_start_dt <= p_effective_dt THEN
                                                p_message_name := 'IGS_EN_PERS_HAS_ENCUMB';
                                                RETURN FALSE;
                                        END IF;
                                ELSE --? The Expiry Date is set.
                                        IF p_effective_dt BETWEEN v_pee_dates.pee_start_dt AND
                                                        (v_pee_dates.expiry_dt - 1) THEN
                                                p_message_name := 'IGS_EN_PERS_HAS_ENCUMB';
                                                RETURN FALSE;
                                        END IF;
                                END IF;
                        END LOOP;
                ELSE
                        --- Check when the Suspended Services effect type is applied to a IGS_PS_COURSE.
                        FOR v_pee_dates IN c_get_pee_dates_for_crs( cst_suspend_service ) LOOP
                                --- Validate if dates of a returned record overlap with the effective date.
                                IF v_pee_dates.expiry_dt IS NULL THEN
                                        IF v_pee_dates.pee_start_dt <= p_effective_dt THEN
                                                p_message_name := 'IGS_EN_PERS_HAS_ENCUMB';
                                                RETURN FALSE;
                                        END IF;
                                ELSE --? The Expiry Date is set.
                                        IF p_effective_dt BETWEEN v_pee_dates.pee_start_dt AND
                                                        (v_pee_dates.expiry_dt - 1) THEN
                                                p_message_name := 'IGS_EN_PERS_HAS_ENCUMB';
                                                RETURN FALSE;
                                        END IF;
                                END IF;
                        END LOOP;
                END IF;
        END IF; -- (validating for suspended services).
        --- Validate for an encumbrance which revokes all services.

        IF v_validate_rvk_srvc = TRUE THEN

                IF v_rvk_apply_to_course_ind = 'N' THEN
                        --- Check when the Revoked Services effect type is not applied to a IGS_PS_COURSE.
                        FOR v_pee_dates IN c_get_pee_dates( cst_revoke_service ) LOOP
                                --- Validate if dates of a returned record overlap with the effective date.
                                IF v_pee_dates.expiry_dt IS NULL THEN
                                        IF v_pee_dates.pee_start_dt <= p_effective_dt THEN
                                                p_message_name := 'IGS_EN_PRSN_ENCUMB_REVOKING';

                                                RETURN FALSE;
                                        END IF;
                                ELSE
                                        -- The Expiry Date is set.
                                        IF p_effective_dt BETWEEN v_pee_dates.pee_start_dt AND
                                        (v_pee_dates.expiry_dt - 1) THEN
                                                p_message_name := 'IGS_EN_PRSN_ENCUMB_REVOKING';

                                                RETURN FALSE;
                                        END IF;
                                END IF;
                        END LOOP;
                ELSE
                        --- Check when the Revoked Services effect type is applied to a IGS_PS_COURSE.
                        FOR v_pee_dates IN c_get_pee_dates_for_crs( cst_revoke_service ) LOOP
                                --- Validate if dates of a returned record overlap with the effective date.
                                IF v_pee_dates.expiry_dt IS NULL THEN
                                        IF v_pee_dates.pee_start_dt <= p_effective_dt THEN
                                                p_message_name := 'IGS_EN_PRSN_ENCUMB_REVOKING';

                                                RETURN FALSE;
                                        END IF;
                                ELSE
                                        -- The Expiry Date is set.
                                        IF p_effective_dt BETWEEN v_pee_dates.pee_start_dt AND
                                        (v_pee_dates.expiry_dt - 1) THEN
                                                p_message_name := 'IGS_EN_PRSN_ENCUMB_REVOKING';

                                                RETURN FALSE;
                                        END IF;
                                END IF;
                        END LOOP;
                END IF;
        END IF; -- (validating for revoked services)
        --- Return the default value

        RETURN TRUE;
  END;
/*
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_excld_prsn');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
*/
  END enrp_val_excld_prsn;
  --
  -- Validate whether a IGS_PE_PERSON is excluded from a IGS_PS_COURSE.
  FUNCTION enrp_val_excld_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN -- enrp_val_excld_crs
        -- Validate whether or not a IGS_PE_PERSON is excluded from admission or enrolment
        -- in a specific IGS_PS_COURSE.
  DECLARE
        cst_excluded                    CONSTANT VARCHAR2(10) := 'EXC_COURSE';
        cst_excluded_grp                CONSTANT VARCHAR2(10) := 'EXC_CRS_GP';
        cst_suspended                   CONSTANT VARCHAR2(10) := 'SUS_COURSE';
      v_message_name  varchar2(30);
        CURSOR  c_pce IS
                SELECT  pce.pce_start_dt,
                        pce.expiry_dt
                FROM    IGS_PE_COURSE_EXCL              pce
                WHERE   pce.person_id           = p_person_id AND
                        pce.course_cd           = p_course_cd AND
                        pce.s_encmb_effect_type IN (
                                                cst_excluded,
                                                cst_suspended);
        CURSOR  c_pcge IS
                SELECT  pcge.pcge_start_dt,
                        pcge.expiry_dt
                FROM    IGS_PE_CRS_GRP_EXCL     pcge,
                        IGS_PS_GRP_MBR          cgm,
                        IGS_PS_GRP                      cg
                WHERE   pcge.person_id                  = p_person_id AND
                        pcge.s_encmb_effect_type        = cst_excluded_grp AND
                        pcge.course_group_cd            = cg.course_group_cd AND
                        cg.course_group_cd              = cgm.course_group_cd AND
                        cgm.course_cd                   = p_course_cd;
  BEGIN
        p_message_name := null;
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_effective_dt IS NULL THEN
                RETURN TRUE;
        END IF;
        -- Validate for an exclusion from the university.
        -- Invoke existing function to perform this check.
        IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_prsn(
                                        p_person_id,
                                        NULL,
                                        p_effective_dt,
                                        v_message_name) THEN
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        -- Validate for an exclusion from a specific IGS_PS_COURSE.
        FOR v_pce_rec IN c_pce LOOP
                -- Validate if the dates of a returned record
                -- overlap with the effective date.
                IF v_pce_rec.expiry_dt IS NULL THEN
                        IF v_pce_rec.pce_start_dt <= p_effective_dt THEN
                                p_message_name := 'IGS_EN_PRSN_ENCUMB_ADM_ENRPRG';
                                RETURN FALSE;
                        END IF;
                ELSE
                        IF p_effective_dt BETWEEN v_pce_rec.pce_start_dt AND
                                                (v_pce_rec.expiry_dt - 1) THEN
                                p_message_name := 'IGS_EN_PRSN_ENCUMB_ADM_ENRPRG';
                                RETURN FALSE;
                        END IF;
                END IF;
        END LOOP;
        -- Validate for an exclusion from
        -- a IGS_PS_COURSE within a IGS_PS_COURSE group.
        FOR v_pcge_rec IN c_pcge LOOP
                -- Validate if the dates of a returned
                -- record overlap with the effective date.
                IF v_pcge_rec.expiry_dt IS NULL THEN
                        IF v_pcge_rec.pcge_start_dt <= p_effective_dt THEN
                                p_message_name := 'IGS_EN_PRSN_ENCUMB_ADM_ENRPRG';
                                RETURN FALSE;
                        END IF;
                ELSE
                        IF p_effective_dt BETWEEN v_pcge_rec.pcge_start_dt AND
                                        (v_pcge_rec.expiry_dt - 1) THEN
                                p_message_name := 'IGS_EN_PRSN_ENCUMB_ADM_ENRPRG';
                                RETURN FALSE;
                        END IF;
                END IF;
        END LOOP;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_pce%ISOPEN THEN
                        CLOSE c_pce;
                END IF;
                IF c_pcge%ISOPEN THEN
                        CLOSE c_pcge;
                END IF;
                RAISE;
  END;
/*
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_excld_crs');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

*/
  END enrp_val_excld_crs;
  --
  -- Validate whether a IGS_PE_PERSON is excluded from a IGS_PS_UNIT set.
  FUNCTION enrp_val_excld_us(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
        v_puse_start_dt         IGS_PE_UNT_SET_EXCL.puse_start_dt%TYPE;
        v_expiry_dt             IGS_PE_UNT_SET_EXCL.expiry_dt%TYPE;
        CURSOR c_psd_ed IS
                SELECT  puse.puse_start_dt,
                        puse.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT    pee,
                        IGS_PE_UNT_SET_EXCL             puse
                WHERE   pee.person_id = p_person_id AND
                        pee.s_encmb_effect_type = 'EXC_CRS_US' AND
                        pee.course_cd = p_course_cd AND
                        puse.person_id = pee.person_id AND
                        puse.encumbrance_type = pee.encumbrance_type AND
                        puse.pen_start_dt = pee.pen_start_dt AND
                        puse.s_encmb_effect_type = pee.s_encmb_effect_type AND
                        puse.pee_start_dt = pee.pee_start_dt AND
                        puse.pee_sequence_number = pee.sequence_number AND
                        puse.unit_set_cd = p_unit_set_cd AND
                        puse.us_version_number = p_us_version_number;
  BEGIN
        -- This function validates whether or not a IGS_PE_PERSON is
        -- excluded from admission or enrolment in a specific IGS_PS_UNIT set.
        p_message_name := null;
        -- Validate the input parameters
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_unit_set_cd IS NULL OR
                        p_us_version_number IS NULL OR
                        p_effective_dt IS NULL THEN
                p_message_name := null;
                RETURN TRUE;
        END IF;
        --Validate for an exclusion from the university
        IF IGS_EN_VAL_ENCMB.enrp_val_excld_prsn(
                        p_person_id,
                        p_course_cd,
                        p_effective_dt,
                        p_message_name) = FALSE THEN
                RETURN FALSE;
        END IF;
        --Validate for an exclusion from a specific IGS_PS_UNIT set.
        OPEN    c_psd_ed;
        LOOP
                FETCH   c_psd_ed        INTO    v_puse_start_dt,
                                                v_expiry_dt;
                EXIT WHEN c_psd_ed%NOTFOUND;
                --Validate if the dates of a returned record overlap with the effective date.
                IF v_expiry_dt IS NULL THEN
                        IF v_puse_start_dt <= p_effective_dt THEN
                                CLOSE c_psd_ed;
                                p_message_name := 'IGS_EN_PERS_EXL_ENRL_UNT_SET';
                                RETURN FALSE;
                        END IF;
                ELSE
                        IF p_effective_dt BETWEEN v_puse_start_dt AND (v_expiry_dt - 1) THEN
                                CLOSE c_psd_ed;
                                p_message_name := 'IGS_EN_PERS_EXL_ENRL_UNT_SET';
                                RETURN FALSE;
                        END IF;
                END IF;
        END LOOP;
        CLOSE   c_psd_ed;
        --- Return the default value
        p_message_name := null;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_excld_us');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END enrp_val_excld_us;
  --
  -- Validate whether a IGS_PE_PERSON is enrolled in all required units.
  FUNCTION enrp_val_rqrd_units(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  ------------------------------------------------------------------------------
--Created by  :
--Date created:
--
-- Purpose:

-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-- Who         When            What
-- svanukur    24-nov-2003     setting the p_return_type if enrp_val_excld_prsn returns false.bug#3052426
------------------------------------------------------------------------------
  BEGIN
  DECLARE
        cst_warn                CONSTANT VARCHAR2(1)            := 'W';
        cst_error               CONSTANT VARCHAR2(1)            := 'E';
        cst_effect_type         CONSTANT VARCHAR2(10)   := 'RQRD_CRS_U';
        -- boolean used to check if a warning occured.
        v_warning_ind           BOOLEAN := FALSE;
        v_unit_cd               IGS_PE_UNT_REQUIRMNT.unit_cd%TYPE;
        v_pur_start_dt          IGS_PE_UNT_REQUIRMNT.pur_start_dt%TYPE;
        v_expiry_dt             IGS_PE_UNT_REQUIRMNT.expiry_dt%TYPE;
        v_ci_start_dt           IGS_EN_SU_ATTEMPT.ci_start_dt%TYPE;
        v_ci_end_dt             IGS_EN_SU_ATTEMPT.ci_end_dt%TYPE;
        v_unit_attempt_status   IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
        -- Cursor on IGS_PE_PERSENC_EFFCT (pee) and
        -- IGS_PE_UNT_REQUIRMNT (pur) tables.
        -- Cursor validates required IGS_PS_UNIT(s).
        CURSOR c_pee_pur IS
                SELECT  pur.unit_cd,
                        pur.pur_start_dt,
                        pur.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT    pee,
                        IGS_PE_UNT_REQUIRMNT            pur
                WHERE   pee.person_id = p_person_id AND
                        pee.s_encmb_effect_type = cst_effect_type AND
                        pee.course_cd = p_course_cd AND
                        pur.person_id = pee.person_id AND
                        pur.encumbrance_type = pee.encumbrance_type AND
                        pur.pen_start_dt = pee.pen_start_dt AND
                        pur.s_encmb_effect_type = pee.s_encmb_effect_type AND
                        pur.pee_start_dt = pee.pee_start_dt AND
                        pur.pee_sequence_number = pee.sequence_number;
        -- Cursor on IGS_EN_SU_ATTEMPT (sua).
        -- Cursor validates which units a student is enrolled in,
        -- for a particular IGS_PS_COURSE.
        CURSOR c_sua (
                cp_unit_cd      IGS_PE_UNT_REQUIRMNT.unit_cd%TYPE,
                cp_p_person_id  IGS_PE_PERSON.person_id%TYPE,
                cp_p_course_cd  IGS_PS_COURSE.course_cd%TYPE) IS
                SELECT  sua.ci_start_dt,
                        sua.ci_end_dt,
                        sua.unit_attempt_status
                FROM    IGS_EN_SU_ATTEMPT       sua
                WHERE   sua.person_id = cp_p_person_id AND
                        sua.course_cd = cp_p_course_cd AND
                        sua.unit_cd = cp_unit_cd AND
                        sua.unit_attempt_status IN ('COMPLETED',
                                        'DUPLICATE',
                                        'ENROLLED',
                                        'DISCONTIN');
  BEGIN
        -- This function validates whether or not a IGS_PE_PERSON is enrolled
        -- in all units they are required to enrol in.
        -- Validate the input parameters
        IF p_person_id IS NULL OR
                        p_course_cd     IS NULL OR
                        p_effective_dt  IS NULL THEN
                p_message_name := null;
                RETURN TRUE;
        END IF;

        -- Validate for an exclusion from the university.
        IF IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (
                        p_person_id,
                        p_course_cd,
                        p_effective_dt,
                        p_message_name) = FALSE THEN

                        p_return_type := cst_error;

                RETURN FALSE;
        END IF;
        -- Loop through IGS_PE_UNT_REQUIRMNT records.
        FOR v_rqrd_units IN c_pee_pur LOOP
                IF v_rqrd_units.expiry_dt IS NULL THEN
                        IF v_rqrd_units.pur_start_dt <= p_effective_dt THEN
                                OPEN    c_sua(v_rqrd_units.unit_cd, p_person_id, p_course_cd);
                                FETCH   c_sua   INTO    v_ci_start_dt,
                                                        v_ci_end_dt,
                                                        v_unit_attempt_status;
                                IF (c_sua%NOTFOUND) THEN
                                        -- Student is not enrolled in
                                        -- the required IGS_PS_UNIT
                                        p_message_name := 'IGS_EN_PRSN_NOTENR_REQUIRE';
                                        p_return_type := cst_error;
                                        CLOSE c_sua;
                                        RETURN FALSE;
                                END IF;
                                CLOSE   c_sua;
                                -- reset cursor
                                OPEN    c_sua(v_rqrd_units.unit_cd, p_person_id, p_course_cd);
                                -- Loop through the units the student is enrolled
                                -- in to see if the student is enrolled in the
                                -- required IGS_PS_UNIT
                                LOOP
                                        FETCH   c_sua   INTO    v_ci_start_dt,
                                                                v_ci_end_dt,
                                                                v_unit_attempt_status;
                                        IF (c_sua%NOTFOUND) THEN
                                                -- Student is not enrolled in the required date period.
                                                p_message_name := 'IGS_EN_PRSN_NOTENR_REQUIRE';
                                                p_return_type := cst_error;
                                                CLOSE c_sua;
                                                RETURN FALSE;
                                        END IF;
                                        IF (v_rqrd_units.pur_start_dt BETWEEN
                                                        v_ci_start_dt AND
                                                        v_ci_end_dt) THEN
                                                IF v_unit_attempt_status =
                                                                'DISCONTIN' THEN
                                                        -- IGS_PS_UNIT has been discontinued
                                                        v_warning_ind := TRUE;
                                                END IF;
                                                -- exit from the inner loop and
                                                -- continue processing the outer loop
                                                EXIT;
                                        END IF;
                                        IF (v_rqrd_units.pur_start_dt <=
                                                        v_ci_start_dt) THEN
                                                -- Student is enrolled in the IGS_PS_UNIT
                                                -- in the required period.
                                                IF v_unit_attempt_status =
                                                                'DISCONTIN' THEN
                                                        -- IGS_PS_UNIT has been discontinued
                                                        v_warning_ind := TRUE;
                                                END IF;
                                                -- exit from the inner loop and
                                                -- continue processing the outer loop
                                                EXIT;
                                        END IF;
                                END LOOP;
                                CLOSE   c_sua;
                        END IF;
                ELSE    -- The expiry date is set
                        IF p_effective_dt BETWEEN v_rqrd_units.pur_start_dt AND
                                        (v_rqrd_units.expiry_dt - 1) THEN
                                OPEN    c_sua(v_rqrd_units.unit_cd, p_person_id, p_course_cd);
                                FETCH   c_sua   INTO    v_ci_start_dt,
                                                        v_ci_end_dt,
                                                        v_unit_attempt_status;
                                IF (c_sua%NOTFOUND) THEN
                                        -- Student is not enrolled in the required IGS_PS_UNIT
                                        CLOSE c_sua;
                                        p_message_name := 'IGS_EN_PRSN_NOTENR_REQUIRE';
                                        p_return_type := cst_error;
                                        RETURN FALSE;
                                END IF;
                                CLOSE   c_sua;
                                -- reset cursor
                                OPEN    c_sua(v_rqrd_units.unit_cd, p_person_id, p_course_cd);
                                -- Loop through the units the student is enrolled in
                                -- to see if the student is enrolled in the required
                                -- IGS_PS_UNIT in the required date period
                                LOOP
                                        FETCH   c_sua   INTO    v_ci_start_dt,
                                                                v_ci_end_dt,
                                                                v_unit_attempt_status;
                                        IF (c_sua%NOTFOUND) THEN
                                                -- Student is not enrolled in the
                                                -- required date period
                                                p_message_name := 'IGS_EN_PRSN_NOTENR_REQUIRE';
                                                p_return_type := cst_error;
                                                CLOSE c_sua;
                                                RETURN FALSE;
                                        END IF;
                                        -- Check if the student is enrolled in the IGS_PS_UNIT
                                        -- in the required date period.
                                        IF (v_rqrd_units.pur_start_dt BETWEEN
                                                        v_ci_start_dt AND
                                                        v_ci_end_dt) THEN
                                                -- Student is enrolled in the IGS_PS_UNIT
                                                -- in the required period.
                                                IF v_unit_attempt_status =
                                                                'DISCONTIN' THEN
                                                        -- IGS_PS_UNIT has been discontinued
                                                        v_warning_ind := TRUE;
                                                END IF;
                                                -- exit from the inner loop and
                                                -- continue processing the outer loop
                                                EXIT;
                                        END IF;
                                        IF ((v_rqrd_units.expiry_dt - 1) BETWEEN
                                                        v_ci_start_dt AND
                                                        v_ci_end_dt) THEN
                                                -- Student is enrolled in the IGS_PS_UNIT
                                                -- in the required period.
                                                IF v_unit_attempt_status =
                                                                'DISCONTIN' THEN
                                                        -- IGS_PS_UNIT has been discontinued
                                                        v_warning_ind := TRUE;
                                                END IF;
                                                -- exit from the inner loop and
                                                -- continue processing the outer loop
                                                EXIT;
                                        END IF;
                                        IF ((v_ci_start_dt BETWEEN
                                                        v_rqrd_units.pur_start_dt AND
                                                        (v_rqrd_units.expiry_dt - 1))   AND
                                                        (v_ci_end_dt BETWEEN
                                                        v_rqrd_units.pur_start_dt AND
                                                        (v_rqrd_units.expiry_dt - 1)))  THEN
                                                -- Student is enrolled in the IGS_PS_UNIT
                                                -- in the required period.
                                                IF v_unit_attempt_status =
                                                                'DISCONTIN' THEN
                                                        -- IGS_PS_UNIT has been discontinued
                                                        v_warning_ind := TRUE;
                                                END IF;
                                                -- exit from the inner loop and
                                                -- continue processing the outer loop
                                                EXIT;
                                        END IF;
                                END LOOP;
                                CLOSE   c_sua;
                        END IF;
                END IF;
        END LOOP;
        IF (v_warning_ind = TRUE) THEN
                -- Warn that a required IGS_PS_UNIT has been discontinued
                p_message_name := 'IGS_EN_PRSN_DISCONT_REQUNIT';
                p_return_type := cst_warn;
                RETURN FALSE;
        END IF;
        --- Return the default value
        p_message_name := null;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_rqrd_units');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END enrp_val_rqrd_units;
  --
  -- Validate whether or not a IGS_PE_PERSON is restricted to an attendance type.
  FUNCTION enrp_val_rstrct_atyp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_restricted_attendance_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        v_apply_to_course_ind           IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;

        v_pee_start_dt                  IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE;
        v_expiry_dt                     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        v_restricted_attendance_type
                        IGS_PE_PERSENC_EFFCT.restricted_attendance_type%TYPE;
        CURSOR  c_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = 'RSTR_AT_TY';
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt,
                        PEE.restricted_attendance_type
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = 'RSTR_AT_TY';
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt,
                        PEE.restricted_attendance_type
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = 'RSTR_AT_TY' AND
                        course_cd           = p_course_cd;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON is restricted to an attendance type.
        p_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- Restricted Attendance Type effect type
        OPEN  c_course_ind;
        FETCH c_course_ind INTO v_apply_to_course_ind;
        -- check if a record was found
        IF (c_course_ind%NOTFOUND) THEN
                CLOSE c_course_ind;
                RETURN TRUE;
        ELSE
                CLOSE c_course_ind;
                IF (v_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        RETURN TRUE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                p_message_name) = FALSE) THEN
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which restricts the
        -- attendance type
        IF (v_apply_to_course_ind = 'N') THEN
            FOR c_pee_rec IN c_pee_details_1 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_restricted_attendance_type :=
                            c_pee_rec.restricted_attendance_type;
                           p_message_name := 'IGS_EN_PERS_RESTR_ATTEND_TYPE';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_restricted_attendance_type :=
                            c_pee_rec.restricted_attendance_type;
                           p_message_name := 'IGS_EN_PERS_RESTR_ATTEND_TYPE';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        ELSE -- v_apply_to_course_ind = 'Y'
            -- check whether the restricted type effect
            -- is applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_2 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_restricted_attendance_type :=
                            c_pee_rec.restricted_attendance_type;
                           p_message_name := 'IGS_EN_PERS_RESTR_ATTEND_TYPE';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_restricted_attendance_type :=
                            c_pee_rec.restricted_attendance_type;
                           p_message_name := 'IGS_EN_PERS_RESTR_ATTEND_TYPE';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_rstrct_atyp');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_rstrct_atyp;
  --
  -- Validate whether or not a IGS_PE_PERSON is restricted to an enrolment cp.
  FUNCTION enrp_val_rstrct_cp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_rstrct_le_cp_value OUT NOCOPY NUMBER ,
  p_rstrct_ge_cp_value OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_rstr_ge_cp                  CONSTANT VARCHAR2(10) :=  'RSTR_GE_CP';
        cst_rstr_le_cp                  CONSTANT VARCHAR2(10) :=  'RSTR_LE_CP';
        v_ge_apply_to_course_ind        IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_le_apply_to_course_ind        IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_message_name                  VARCHAR2(30);
        v_validate_rstr_ge_cp           BOOLEAN := TRUE;
        v_validate_rstr_le_cp           BOOLEAN := TRUE;
        CURSOR  c_ge_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_rstr_ge_cp;
        CURSOR  c_le_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_rstr_le_cp;
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt,
                        PEE.restricted_enrolment_cp
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_rstr_ge_cp AND
                        restricted_enrolment_cp IS NOT NULL
                ORDER BY PEE.restricted_enrolment_cp DESC;
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt,
                        PEE.restricted_enrolment_cp
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_rstr_ge_cp AND
                        course_cd           = p_course_cd AND
                        restricted_enrolment_cp IS NOT NULL
                ORDER BY PEE.restricted_enrolment_cp DESC;
        CURSOR  c_pee_details_3 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt,
                        PEE.restricted_enrolment_cp
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_rstr_le_cp AND
                        restricted_enrolment_cp IS NOT NULL
                ORDER BY PEE.restricted_enrolment_cp ASC;
        CURSOR  c_pee_details_4 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt,
                        PEE.restricted_enrolment_cp
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_rstr_le_cp AND
                        course_cd           = p_course_cd AND
                        restricted_enrolment_cp IS NOT NULL
                ORDER BY PEE.restricted_enrolment_cp ASC;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON is restricted to an enrolment credit point value.
        v_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                p_message_name := v_message_name;
                RETURN TRUE;
        END IF;
        -- The requirement of the IGS_PS_COURSE code parameter (p_course_cd) is dependant on
        -- whether or not the system encumbrance effect should be applied to a IGS_PS_COURSE.
        -- (s_encmb_effect_type.apply_to_course_ind).
        -- IGS_GE_NOTE: v_validate_rstr_ge_cp and v_validate_rstr_le_cp should be defaulted
        -- to TRUE when defined.
        -- Check if a IGS_PS_COURSE code is required for the
        -- Restricted Greater Than Credit Point effect type
        OPEN  c_ge_course_ind;
        FETCH c_ge_course_ind INTO v_ge_apply_to_course_ind;
        -- check if a record was found
        IF (c_ge_course_ind%NOTFOUND) THEN
                CLOSE c_ge_course_ind;
                v_validate_rstr_ge_cp := FALSE;
        ELSE
                CLOSE c_ge_course_ind;
                IF (v_ge_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        v_validate_rstr_ge_cp := FALSE;
                END IF;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- Restricted Less Than Credit Point effect type
        OPEN  c_le_course_ind;
        FETCH c_le_course_ind INTO v_le_apply_to_course_ind;
        -- check if a record was found
        IF (c_le_course_ind%NOTFOUND) THEN
                CLOSE c_le_course_ind;
                v_validate_rstr_le_cp := FALSE;
        ELSE
                CLOSE c_le_course_ind;
                IF (v_le_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        v_validate_rstr_le_cp := FALSE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                v_message_name) = FALSE) THEN
                        p_message_name := v_message_name;
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which restricts the
        -- enrolment credit points to greater than or equal to a
        -- nominated credit point value
        IF (v_validate_rstr_ge_cp = TRUE) THEN
                IF (v_ge_apply_to_course_ind = 'N') THEN
                    FOR c_pee_rec IN c_pee_details_1 LOOP
                        IF (c_pee_rec.expiry_dt IS NULL) THEN
                            IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                                p_rstrct_ge_cp_value := c_pee_rec.restricted_enrolment_cp;
                                v_message_name := 'IGS_EN_PRSN_ENCUMB_GE_ENRCRD';
                                EXIT;
                            END IF;
                        ELSE -- expiry_dt is set
                            IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                                        (c_pee_rec.expiry_dt - 1)) THEN
                                p_rstrct_ge_cp_value := c_pee_rec.restricted_enrolment_cp;
                                v_message_name := 'IGS_EN_PRSN_ENCUMB_GE_ENRCRD';
                                EXIT;
                            END IF;
                        END IF;
                    END LOOP;
                ELSE -- v_ge_apply_to_course_ind = 'Y'
                    -- check whether the restricted type effect
                    -- is applied to a IGS_PS_COURSE
                    FOR c_pee_rec IN c_pee_details_2 LOOP
                        IF (c_pee_rec.expiry_dt IS NULL) THEN
                            IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                                p_rstrct_ge_cp_value := c_pee_rec.restricted_enrolment_cp;
                                v_message_name := 'IGS_EN_PRSN_ENCUMB_GE_ENRCRD';
                                EXIT;
                            END IF;
                        ELSE -- expiry_dt is set
                            IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                                        (c_pee_rec.expiry_dt - 1)) THEN
                                p_rstrct_ge_cp_value := c_pee_rec.restricted_enrolment_cp;
                                v_message_name := 'IGS_EN_PRSN_ENCUMB_GE_ENRCRD';
                                EXIT;
                            END IF;
                        END IF;
                    END LOOP;
                END IF;
        END IF; -- Validating for greater than restriction.
        -- validate for an encumbrance which restricts the
        -- enrolment credit points to less than or equal to a
        -- nominated credit point value
        IF (v_validate_rstr_le_cp = TRUE) THEN
                IF (v_le_apply_to_course_ind = 'N') THEN
                    FOR c_pee_rec IN c_pee_details_3 LOOP
                        IF (c_pee_rec.expiry_dt IS NULL) THEN
                            IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                                   p_rstrct_le_cp_value :=
                                    c_pee_rec.restricted_enrolment_cp;
                                   v_message_name := 'IGS_EN_PRSN-ENCUMB_LE_ENRCRD';
                                   EXIT;
                            END IF;
                        ELSE -- expiry_dt is set
                            IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                                (c_pee_rec.expiry_dt - 1)) THEN
                                   p_rstrct_le_cp_value :=
                                    c_pee_rec.restricted_enrolment_cp;
                                   v_message_name := 'IGS_EN_PRSN-ENCUMB_LE_ENRCRD';
                                   EXIT;
                            END IF;
                        END IF;
                    END LOOP;
                ELSE -- v_le_apply_to_course_ind = 'Y'
                    -- check whether the restricted type effect
                    -- is applied to a IGS_PS_COURSE
                    FOR c_pee_rec IN c_pee_details_4 LOOP
                        IF (c_pee_rec.expiry_dt IS NULL) THEN
                            IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                                   p_rstrct_le_cp_value :=
                                    c_pee_rec.restricted_enrolment_cp;
                                   v_message_name := 'IGS_EN_PRSN-ENCUMB_LE_ENRCRD';
                                   EXIT;
                            END IF;
                        ELSE -- expiry_dt is set
                            IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                                (c_pee_rec.expiry_dt - 1)) THEN
                                   p_rstrct_le_cp_value :=
                                    c_pee_rec.restricted_enrolment_cp;
                                   v_message_name := 'IGS_EN_PRSN-ENCUMB_LE_ENRCRD';
                                   EXIT;
                            END IF;
                        END IF;
                    END LOOP;
                END IF;
        END IF; -- Validating for less than restriction
        -- return FALSE if the p_message_name
        -- has been set
        IF (v_message_name IS NOT NULL ) THEN
                p_message_name := v_message_name;
                RETURN FALSE;
        ELSE
                p_message_name := v_message_name;
                RETURN TRUE;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_rstrct_cp');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_rstrct_cp;
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking IGS_PS_COURSE material.
  FUNCTION enrp_val_blk_crsmtrl(
  p_person_id IN NUMBER ,
  p_course_cd  VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_crsmtrl_blk                 CONSTANT VARCHAR2(10) := 'C_MTRL_BLK';
        v_apply_to_course_ind           IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_pee_start_dt                  IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE;
        v_expiry_dt                     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        CURSOR  c_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_crsmtrl_blk;
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_crsmtrl_blk;
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_crsmtrl_blk AND
                        course_cd           = p_course_cd;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON has an encumbracne blocking the
        -- issue of IGS_PS_COURSE materials
        p_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- Materials Blocked effect type
        OPEN  c_course_ind;
        FETCH c_course_ind INTO v_apply_to_course_ind;
        -- check if a record was found
        IF (c_course_ind%NOTFOUND) THEN
                CLOSE c_course_ind;
                RETURN TRUE;
        ELSE
                CLOSE c_course_ind;
                IF (v_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        RETURN TRUE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                p_message_name) = FALSE) THEN
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which blocks the issue
        -- of IGS_PS_COURSE materials
        IF (v_apply_to_course_ind = 'N') THEN
            -- check when the IGS_PS_COURSE Materials Blocked effect
            -- type is not appplied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_1 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_ISSUE_OF_COURS_MATEER';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_ISSUE_OF_COURS_MATEER';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        ELSE -- v_apply_to_course_ind = 'Y'
            -- check when the IGS_PS_COURSE Materials Blocked effect
            -- type is appplied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_2 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_ISSUE_OF_COURS_MATEER';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_ISSUE_OF_COURS_MATEER';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_blk_crsmtrl');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_blk_crsmtrl;
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking graduation.
  FUNCTION enrp_val_blk_grd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_grad_blk                    CONSTANT VARCHAR2(10) := 'GRAD_BLK';
        v_apply_to_course_ind           IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_pee_start_dt                  IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE;
        v_expiry_dt                     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        CURSOR  c_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_grad_blk;
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_grad_blk;
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_grad_blk AND
                        course_cd           = p_course_cd;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON has an encumbrance blocking
        -- graduation
        p_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- Graduation Blocked effect type
        OPEN  c_course_ind;
        FETCH c_course_ind INTO v_apply_to_course_ind;
        -- check if a record was found
        IF (c_course_ind%NOTFOUND) THEN
                CLOSE c_course_ind;
                RETURN TRUE;
        ELSE
                CLOSE c_course_ind;
                IF (v_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        RETURN TRUE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                p_message_name) = FALSE) THEN
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which blocks
        -- graduation
        IF (v_apply_to_course_ind = 'N') THEN
            -- check when the Graduation Blocked effect
            -- type is not applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_1 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_GRADUATION';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_GRADUATION';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        ELSE -- v_apply_to_course_ind = 'Y'
            -- check when the Graduation Blocked effect
            -- type is applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_2 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_GRADUATION';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_GRADUATION';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_blk_grd');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_blk_grd;
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking their ID card.
  FUNCTION enrp_val_blk_id_card(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_idcard_blk                  CONSTANT VARCHAR2(10) := 'IDCARD_BLK';
        v_apply_to_course_ind           IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_pee_start_dt                  IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE;
        v_expiry_dt                     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        CURSOR  c_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_idcard_blk;
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_idcard_blk;
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_idcard_blk AND
                        course_cd           = p_course_cd;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON has an encumbracne blocking the
        -- issue of an ID card
        p_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- ID Card Blocked effect type
        OPEN  c_course_ind;
        FETCH c_course_ind INTO v_apply_to_course_ind;
        -- check if a record was found
        IF (c_course_ind%NOTFOUND) THEN
                CLOSE c_course_ind;
                RETURN TRUE;
        ELSE
                CLOSE c_course_ind;
                IF (v_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        RETURN TRUE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                p_message_name) = FALSE) THEN
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which blocks the issue
        -- of an ID card
        IF (v_apply_to_course_ind = 'N') THEN
            -- check when the ID Card Blocked effect
            -- type is not applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_1 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_IDCARD';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_IDCARD';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        ELSE -- v_apply_to_course_ind = 'Y'
            -- check when the ID Card Blocked effect
            -- type is applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_2 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_IDCARD';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_IDCARD';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_blk_id_card');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_blk_id_card;
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking the info booth.
  FUNCTION enrp_val_blk_inf_bth(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_infbth_blk                  CONSTANT VARCHAR2(10) := 'INFBTH_BLK';
        v_apply_to_course_ind           IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_pee_start_dt                  IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE;
        v_expiry_dt                     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        CURSOR  c_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_infbth_blk;
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_infbth_blk;
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_infbth_blk AND
                        course_cd           = p_course_cd;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON has an encumbracne blocking the
        -- secure services of the Information Booth
        -- (ie. services accessed via a PIN)
        p_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- Information Booth Blocked effect type
        OPEN  c_course_ind;
        FETCH c_course_ind INTO v_apply_to_course_ind;
        -- check if a record was found
        IF (c_course_ind%NOTFOUND) THEN
                CLOSE c_course_ind;
                RETURN TRUE;
        ELSE
                CLOSE c_course_ind;
                IF (v_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        RETURN TRUE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                p_message_name) = FALSE) THEN
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which blocks the
        -- secure services of the Information Booth
        IF (v_apply_to_course_ind = 'N') THEN
            -- check when the Information Booth Blocked effect
            -- type is not applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_1 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_SECURE_SERV_BLOCKING';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_SECURE_SERV_BLOCKING';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        ELSE -- v_apply_to_course_ind = 'Y'
            -- check when the Information Booth Blocked effect
            -- type is applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_2 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_SECURE_SERV_BLOCKING';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_SECURE_SERV_BLOCKING';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_blk_inf_bth');

                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_blk_inf_bth;
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking issue of results
  FUNCTION enrp_val_blk_result(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_result_blk                  CONSTANT VARCHAR2(10) := 'RESULT_BLK';
        v_apply_to_course_ind           IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_pee_start_dt                  IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE;
        v_expiry_dt                     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        CURSOR  c_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_result_blk;
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_result_blk;
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_result_blk AND
                        course_cd           = p_course_cd;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON has an encumbracne blocking the
        -- issue of results
        p_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- Result Blocked effect type
        OPEN  c_course_ind;
        FETCH c_course_ind INTO v_apply_to_course_ind;
        -- check if a record was found
        IF (c_course_ind%NOTFOUND) THEN
                CLOSE c_course_ind;
                RETURN TRUE;
        ELSE
                CLOSE c_course_ind;
                IF (v_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        RETURN TRUE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                p_message_name) = FALSE) THEN
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which blocks the issue
        -- of results
        IF (v_apply_to_course_ind = 'N') THEN
            -- check when the Results Blocked effect
            -- type is not applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_1 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_RESULT';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_RESULT';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        ELSE -- v_apply_to_course_ind = 'Y'
            -- check when the Results Blocked effect
            -- type is applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_2 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_RESULT';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_RESULT';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_blk_result');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END;
  END enrp_val_blk_result;
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking system corresp.
  FUNCTION enrp_val_blk_sys_cor(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_cor_blk                     CONSTANT VARCHAR2(10) := 'S_COR_BLK';
        v_apply_to_course_ind           IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_pee_start_dt                  IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE;
        v_expiry_dt                     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        CURSOR  c_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_cor_blk;
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_cor_blk;
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_cor_blk AND
                        course_cd           = p_course_cd;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON has an encumbracne blocking the
        -- issue of systme generated correspondence
        p_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- System Correspondence Blocked effect type
        OPEN  c_course_ind;
        FETCH c_course_ind INTO v_apply_to_course_ind;
        -- check if a record was found
        IF (c_course_ind%NOTFOUND) THEN
                CLOSE c_course_ind;
                RETURN TRUE;
        ELSE
                CLOSE c_course_ind;
                IF (v_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        RETURN TRUE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                p_message_name) = FALSE) THEN
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which blocks the issue
        -- of system generated correspondence
        IF (v_apply_to_course_ind = 'N') THEN
            -- check when the System Correspondence Blocked effect
            -- type is not applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_1 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PERS_BLK_ISSUE_OF_CORR';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PERS_BLK_ISSUE_OF_CORR';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        ELSE -- v_apply_to_course_ind = 'Y'
            -- check when the System Correspondence Blocked effect
            -- type is applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_2 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PERS_BLK_ISSUE_OF_CORR';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PERS_BLK_ISSUE_OF_CORR';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_blk_sys_cor');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_blk_sys_cor;
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking acad transcript.
  FUNCTION enrp_val_blk_trscrpt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_trans_blk                   CONSTANT VARCHAR2(10) := 'TRANS_BLK';
        v_apply_to_course_ind           IGS_EN_ENCMB_EFCTTYP.apply_to_course_ind%TYPE;
        v_pee_start_dt                  IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE;
        v_expiry_dt                     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        CURSOR  c_course_ind IS
                SELECT  SEET.apply_to_course_ind
                FROM    IGS_EN_ENCMB_EFCTTYP_V SEET
                WHERE   s_encmb_effect_type = cst_trans_blk;
        CURSOR  c_pee_details_1 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id AND
                        s_encmb_effect_type = cst_trans_blk;
        CURSOR  c_pee_details_2 IS
                SELECT  PEE.pee_start_dt,
                        PEE.expiry_dt
                FROM    IGS_PE_PERSENC_EFFCT PEE
                WHERE   person_id           = p_person_id  AND
                        s_encmb_effect_type = cst_trans_blk AND
                        course_cd           = p_course_cd;
  BEGIN
        -- This module validates whether or not
        -- a IGS_PE_PERSON has an encumbrance blocking the
        -- issue of an academic transcript
        p_message_name := null;
        -- validating the input parameters
        IF (p_person_id IS NULL OR p_effective_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- check if a IGS_PS_COURSE code is required for the
        -- Transcript Blocked effect type
        OPEN  c_course_ind;
        FETCH c_course_ind INTO v_apply_to_course_ind;
        -- check if a record was found
        IF (c_course_ind%NOTFOUND) THEN
                CLOSE c_course_ind;
                RETURN TRUE;
        ELSE
                CLOSE c_course_ind;
                IF (v_apply_to_course_ind = 'Y' AND p_course_cd IS NULL) THEN
                        RETURN TRUE;
                END IF;
        END IF;
        -- validate for an exclusion from the university -
        -- invoke and existing function to perform this check
        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (p_person_id,
                                                p_course_cd,
                                                p_effective_dt,
                                                p_message_name) = FALSE) THEN
                        RETURN FALSE;
        END IF;
        -- validate for an encumbrance which blocks the issue
        -- of the academic transcript
        IF (v_apply_to_course_ind = 'N') THEN
            -- check when the Transcript Blocked effect
            -- type is not applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_1 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_ACATRN';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_ACATRN';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        ELSE -- v_apply_to_course_ind = 'Y'
            -- check whether the restricted type effect
            -- is applied to a IGS_PS_COURSE
            FOR c_pee_rec IN c_pee_details_2 LOOP
                IF (c_pee_rec.expiry_dt IS NULL) THEN
                    IF (c_pee_rec.pee_start_dt <= p_effective_dt) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_ACATRN';
                           RETURN FALSE;
                    END IF;
                ELSE -- expiry_dt is set
                    IF (p_effective_dt BETWEEN c_pee_rec.pee_start_dt AND
                        (c_pee_rec.expiry_dt - 1)) THEN
                           p_message_name := 'IGS_EN_PRSN_ENCUMB_ISS_ACATRN';
                           RETURN FALSE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_blk_trscrpt');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_blk_trscrpt;
  --
  -- Valiate enrolment encumbrances related to load periods
 FUNCTION ENRP_VAL_ENR_ENCMB(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_message_name2 OUT NOCOPY varchar2 ,
  p_return_type OUT NOCOPY VARCHAR2,
  p_effective_dt IN DATE DEFAULT NULL)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
   -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    05-DEC-2003     The calendar parameters now refer to the load calendar and not the academic calendar.
  --                            This was done as part of the bug 3227399 to validate holds only for the term in question and
  --                             not the entire academic year.
  --                             p_cal_type and p_ci_sequence_number are the load calendar instance details and
  --                             the curosor
  -------------------------------------------------------------------------------------------


        cst_acad                CONSTANT        VARCHAR2(10) := 'ACADEMIC';
        v_load_error            BOOLEAN;
        v_required_error        BOOLEAN;

        v_attendance_type       IGS_EN_ATD_TYPE.attendance_type%TYPE;
        v_period_cp             NUMBER;
        v_period_load           NUMBER;
        v_credit_points         NUMBER;
        v_alias_val             IGS_CA_DA_INST_V.alias_val%TYPE;
        v_s_encmb_effect_type   IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE;
        v_restricted_attendance_type
                                IGS_PE_PERSENC_EFFCT.restricted_attendance_type%TYPE;
        v_rstrct_le_cp_value    IGS_PE_PERSENC_EFFCT.restricted_enrolment_cp%TYPE;
        v_rstrct_ge_cp_value    IGS_PE_PERSENC_EFFCT.restricted_enrolment_cp%TYPE;
        v_return_type           VARCHAR2(1);
        v_load_effect_dt_alias  IGS_EN_CAL_CONF.load_effect_dt_alias%TYPE;
        v_load_effect_dt        DATE;
        v_message_name          VARCHAR2(200);




                -- Getting the academic calender for the load calender.
        CURSOR sup_cal(cp_cal_Type igs_ca_inst.cal_type%TYPE, cp_cal_seq igs_ca_inst.sequence_number%TYPE) IS
        SELECT SUP_CAL_TYPE, SUP_CI_SEQUENCE_NUMBER
        FROM igs_ca_inst_rel
        WHERE sub_cal_type = cp_cal_Type
        AND sub_ci_sequence_number = cp_cal_seq
        AND sup_cal_type
        IN (SELECT CAL_TYPE FROM IGS_CA_TYPE  WHERE S_CAL_CAT = 'ACADEMIC');

        v_sup_rec sup_cal%ROWTYPE;
        l_effective_dt DATE;
   BEGIN
      -- Apply all of the encumbrance validation checks for all load calendar
      -- instances within a nominated academic calendar instance. All of the
      -- encumbrance checks are point in time based. This routine uses the 'load
      -- effective' date from all of the load calendars as the effective date for
      -- the encumbrance checks.
      -- This routine returns 2 possible message numbers - the first is for 'load'
      -- encumbrance errors and the second for 'restricted IGS_PS_UNIT' encumbrance
      -- errors. The routine will run for all periods even if an error has been
      -- found - the user needs to see the errors of both types.

      p_message_name  := null;
      p_message_name2 := null;
      v_load_error := FALSE;
      v_required_error := FALSE;

      --fetch the superior acad calendar.
         OPEN sup_cal(p_cal_type, p_ci_sequence_number) ;
         FETCH sup_cal INTO v_sup_rec;
         CLOSE sup_cal;

      --get the census date of the passed in load cal
       IF p_effective_dt IS NULL THEN
         l_effective_dt := Igs_En_Gen_015.get_effective_census_date(p_cal_type,
                                                                     p_ci_sequence_number,
                                                                       NULL,
                                                                       NULL);
       ELSE
         l_effective_dt := p_effective_dt;
       END IF;

        --if census date is not found, then return true
          IF l_effective_dt IS NULL THEN
             RETURN TRUE;
          END IF;

                      -- call the routine to check whether the student
                      -- IGS_PS_COURSE attempt has a credit point restriction
                IF(IGS_EN_VAL_ENCMB.ENRP_VAL_RSTRCT_CP(
                                                      p_person_id,
                                                      p_course_cd,
                                                      l_effective_dt,
                                                      v_rstrct_le_cp_value,
                                                      v_rstrct_ge_cp_value,
                                                      v_message_name) = FALSE) THEN
                              -- call the routine to calculate the credit point
                              -- figure for the load calendar
                              v_period_cp := IGS_EN_PRC_LOAD.ENRP_CLC_LOAD_TOTAL(
                                                              p_person_id => p_person_id,
                                                              p_course_cd => p_course_cd,
                                                              p_acad_cal_type =>v_sup_rec.sup_cal_type,
                                                              p_acad_sequence_number =>v_sup_rec.sup_ci_sequence_number,
                                                              p_load_cal_type => p_cal_type,
                                                              p_load_sequence_number =>p_ci_sequence_number
                                                             );
                           -- depending on whether the restriction is 'greater or equal'
                           -- or 'less ot equal' test against the calcuated credit points
                           -- provided not equal to 0 (0 returned if no IGS_PS_UNIT exist for the load period)
                           IF NVL(v_period_cp, 0) <> 0 THEN
                                IF (v_rstrct_le_cp_value IS NOT NULL AND
                                            v_rstrct_ge_cp_value IS NOT NULL) THEN
                                                IF (v_period_cp NOT BETWEEN v_rstrct_le_cp_value AND
                                                     v_rstrct_ge_cp_value) THEN
                                                        p_message_name := 'IGS_EN_PRSN_ENR_CRDPNT_VALUE';
                                                        v_load_error := TRUE;
                                                END IF;
                                ELSIF (v_rstrct_le_cp_value IS NOT NULL) THEN
                                                IF (v_period_cp > v_rstrct_le_cp_value) THEN
                                                     p_message_name := 'IGS_EN_PRSN_ENRCRDPNT';
                                                     v_load_error := TRUE;
                                                 END IF;
                                ELSIF (v_rstrct_ge_cp_value IS NOT NULL) THEN
                                               IF (v_period_cp < v_rstrct_ge_cp_value) THEN
                                                  p_message_name := 'IGS_EN_PRSN_ENR_CRDPOINT';
                                                  v_load_error := TRUE;
                                               END IF;
                                END IF;
                           END IF; --NVL(v_period_cp, 0)

                      -- call the routine to check whether the student IGS_PS_COURSE
                      -- attempt has a restricted attendance type
                 ELSIF(IGS_EN_VAL_ENCMB.ENRP_VAL_RSTRCT_ATYP(
                                                      p_person_id,
                                                      p_course_cd,
                                                      l_effective_dt,
                                                      v_restricted_attendance_type,
                                                      v_message_name) = FALSE) THEN
                              -- call routine to calculate the load figure for
                              -- the load calendar
                             v_period_load := IGS_EN_PRC_LOAD.ENRP_CLC_EFTSU_TOTAL(
                                                p_person_id => p_person_id,
                                                p_course_cd => p_course_cd,
                                                p_acad_cal_type => v_sup_rec.sup_cal_type,
                                                p_acad_sequence_number => v_sup_rec.sup_ci_sequence_number ,
                                                p_load_cal_type =>  p_cal_type,
                                                p_load_sequence_number => p_ci_sequence_number,
                                                p_truncate_ind  => 'Y',
                                                p_include_research_ind => 'Y',
                                                p_key_course_cd => NULL,
                                                p_key_version_number => NULL,
                                                p_credit_points => v_credit_points);
                                -- call the routine to determine the attendance type
                                -- for calculated load figure within the load calendar
                                 v_attendance_type := IGS_EN_PRC_LOAD.ENRP_GET_LOAD_ATT(
                                 p_cal_type,
                                 v_period_load);
                                IF(v_attendance_type IS NOT NULL and
                                     v_attendance_type <> v_restricted_attendance_type) THEN
                                      p_message_name := 'IGS_EN_PRSN_ATTTYPE_NE_ATT_TY';
                                      v_load_error := TRUE;
                                END IF;
                   END IF;



                      -- check whether there is an outstanding encumbrance
                      -- for a required IGS_PS_UNIT

                      IF(IGS_EN_VAL_ENCMB.ENRP_VAL_RQRD_UNITS(
                                              p_person_id,
                                              p_course_cd,
                                              l_effective_dt,
                                              v_message_name,
                                              v_return_type) = FALSE) THEN
                              p_message_name2 := v_message_name;
                              p_return_type := v_return_type;
                              v_required_error := TRUE;

                      END IF;


      --return false if any one check failed.
      IF(v_load_error = TRUE OR v_required_error = TRUE) THEN
              RETURN FALSE;
      ELSE
              RETURN TRUE;
      END IF;
   EXCEPTION
            WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ENCMB.enrp_val_enr_encmbf 2');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
   END;
   END enrp_val_enr_encmb;

  END IGS_EN_VAL_ENCMB;

/
