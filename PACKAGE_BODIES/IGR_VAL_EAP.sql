--------------------------------------------------------
--  DDL for Package Body IGR_VAL_EAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_VAL_EAP" AS
/* $Header: IGSRT08B.pls 120.0 2005/06/01 14:45:49 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sjlaport    18-Feb-05       Created for IGR Migration
  -------------------------------------------------------------------------------------------

  -- Validate the Enquiry application status.
  FUNCTION admp_val_eap_es_comp(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_enquiry_status IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- admp_val_eap_es_comp
    -- Validate IGR_I_APPL.enquiry_status:
    -- * Must be set to system status of 'COMPLETE' if no child
    --  IGR_I_A_PKGITM_V records exist with mailed_dt set to NULL.
  DECLARE
    cst_complete    CONSTANT VARCHAR2(20) := 'OSS_COMPLETE';
    CURSOR c_es IS
        SELECT  es.s_enquiry_status
        FROM    IGR_I_STATUS_V   es
        WHERE   es.enquiry_status   = p_enquiry_status;
    v_status IGR_I_STATUS_V.s_enquiry_status%TYPE;
    CURSOR c_epi IS
        SELECT  'x'
        FROM    IGR_I_A_PKGITM_V eapmpi
        WHERE   eapmpi.person_id        = p_person_id AND
            eapmpi.enquiry_appl_number  = p_enquiry_appl_number;
    CURSOR c_eapmpi IS
        SELECT  'x'
        FROM    IGR_I_A_PKGITM_V eapmpi
        WHERE   eapmpi.person_id        = p_person_id AND
            eapmpi.enquiry_appl_number  = p_enquiry_appl_number AND
            eapmpi.mailed_dt        IS NULL;
    v_eapmpi_exists VARCHAR2(1);
    v_epi_exists    VARCHAR2(1);
  BEGIN
    -- Set the default message number
    p_message_name := null;
    --1. Check parameters :
    IF p_person_id IS NULL OR
            p_enquiry_appl_number IS NULL OR
            p_enquiry_status IS NULL THEN
        RETURN TRUE;
    END IF;
    --2. Get the system status of the IGR_I_STATUS_V.
    OPEN c_es;
    FETCH c_es INTO v_status;
    IF c_es%NOTFOUND THEN
        CLOSE c_es;
        RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_es;
    --3. Validate that package items exist.
    IF v_status <> cst_complete THEN
        OPEN c_epi;
        FETCH c_epi INTO v_epi_exists;
        IF c_epi%NOTFOUND THEN
            CLOSE c_epi;
            RETURN TRUE;
        END IF;
        CLOSE c_epi;
    END IF; -- v_status
    --4. Validate that status must be set to system status of 'COMPLETE' if no
    --  child IGR_I_A_PKGITM_V records exist where mailed_dt is null.
    IF v_status <> cst_complete THEN
        OPEN c_eapmpi;
        FETCH c_eapmpi INTO v_eapmpi_exists;
        IF c_eapmpi%NOTFOUND THEN
            CLOSE c_eapmpi;
            --p_message_num := 4766;
            p_message_name := 'IGS_AD_ENQ_STATUS_SET_COMPLET';
            RETURN FALSE;
        END IF;
        CLOSE c_eapmpi;
    END IF; -- v_status
    --5.    Return no error:
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
        IF c_eapmpi%ISOPEN THEN
            CLOSE c_eapmpi;
        END IF;
        IF c_es%ISOPEN THEN
            CLOSE c_es;
        END IF;
        RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_eap_es_comp;
  --
  -- Validate the admission enquiry academic calendar.
  FUNCTION admp_val_ae_acad_cal(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- admp_val_aa_acad_cal
    -- Validate the admission enquiry application commencement period
    -- (IGR_I_APPL.acad_cal_type, IGR_I_APPL.acad_ci_sequence_number).
    -- Validations are -
    -- ? IGR_I_APPL.acad_cal_type must be an Academic calendar.
    -- ? IGR_I_APPL.acad_cal_type and IGR_I_APPL.acad_ci_sequence_number
    --  must be an Active  calendar instance.
  DECLARE
    CURSOR c_ct (
            cp_acad_cal_type        IGR_I_APPL.acad_cal_type%TYPE) IS
        SELECT  s_cal_cat
        FROM    IGS_CA_TYPE
        WHERE   cal_type = cp_acad_cal_type;
    CURSOR c_ci_cs (
            cp_acad_cal_type        IGR_I_APPL.acad_cal_type%TYPE,
            cp_acad_ci_sequence_number  IGR_I_APPL.acad_ci_sequence_number%TYPE) IS
        SELECT  cs.s_cal_status
        FROM    IGS_CA_STAT cs,
            IGS_CA_INST ci
        WHERE   ci.cal_type         = cp_acad_cal_type AND
            ci.sequence_number  = cp_acad_ci_sequence_number AND
            ci.cal_status   = cs.cal_status;
    v_ct_rec        c_ct%ROWTYPE;
    v_ci_cs_rec c_ci_cs%ROWTYPE;
    cst_academic    VARCHAR2(10) := 'ACADEMIC';
    cst_active      VARCHAR2(10) := 'ACTIVE';
  BEGIN
    -- Set the default message number
    p_message_name := null;
    -- Cursor handling
    OPEN c_ct (p_acad_cal_type);
    FETCH c_ct INTO v_ct_rec;
    IF c_ct%FOUND THEN
        CLOSE c_ct;
        IF v_ct_rec.s_cal_cat <> cst_academic THEN
            --p_message_num := 2401;
            p_message_name := 'IGS_AD_CAT_AS_ACADEMIC';
            RETURN FALSE;
        END IF;
    ELSE
        CLOSE c_ct;
    END IF;
    OPEN c_ci_cs (
            p_acad_cal_type,
            p_acad_ci_sequence_number);
    FETCH c_ci_cs INTO v_ci_cs_rec;
    IF c_ci_cs%NOTFOUND THEN
        CLOSE c_ci_cs;
        RETURN TRUE;
    END IF;
    CLOSE c_ci_cs;
    IF v_ci_cs_rec.s_cal_status <> cst_active THEN   --removed the planned status as per bug#2722785 --rghosh
        --p_message_num := 2402;
          p_message_name := 'IGS_AD_ACACAL_PLANNED_ACTIVE';
        RETURN FALSE;
    END IF;
    -- Return the default value
    RETURN TRUE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_ae_acad_cal;
  --
  -- Validate the admission enquiry admission calendar.
  FUNCTION admp_val_ae_adm_cal(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN
    DECLARE
    cst_admission           CONSTANT VARCHAR2(10) := 'ADMISSION';
    cst_active          CONSTANT VARCHAR2(10) := 'ACTIVE';
    v_s_cal_cat         IGS_CA_TYPE.s_cal_cat%TYPE;
    v_s_cal_status          IGS_CA_STAT.s_cal_status%TYPE;
    v_dummy             VARCHAR2(1);
    CURSOR c_cal_type (
            cp_cal_type IGS_CA_TYPE.cal_type%TYPE) IS
        SELECT  cat.s_cal_cat
        FROM    IGS_CA_TYPE cat
        WHERE   cat.cal_type = cp_cal_type;
    CURSOR c_cal_instance (
            cp_cal_type IGS_CA_INST.cal_type%TYPE,
            cp_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  cs.s_cal_status
        FROM    IGS_CA_INST ci,
            IGS_CA_STAT cs
        WHERE   ci.cal_status= cs.cal_status AND
            ci.cal_type = cp_cal_type AND
            ci.sequence_number = cp_sequence_number;
    CURSOR c_cal_ins_rel (
            cp_acad_cal_type IGS_CA_INST.cal_type%TYPE,
            cp_acad_ci_sequence_number IGS_CA_INST.sequence_number%TYPE,
            cp_adm_cal_type IGS_CA_INST.cal_type%TYPE,
            cp_adm_ci_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  'x'
        FROM    IGS_CA_INST_REL cir
        WHERE   cir.sup_cal_type =cp_acad_cal_type AND
            cir.sup_ci_sequence_number = cp_acad_ci_sequence_number AND
            cir.sub_cal_type = cp_adm_cal_type AND
            cir.sub_ci_sequence_number = cp_adm_ci_sequence_number;
    BEGIN
    -- Validate the admission enquiry admission calendar
    -- (IGR_I_APPL.adm_cal_type,
    -- IGR_I_APPL.adm_ci_sequence_number).
    -- Validations are -
    -- IGR_I_APPL.acad_cal_type must be an Admission calendar.
    -- IGR_I_APPL.adm_cal_type and IGR_I_APPL.adm_ci_sequence_number
    -- must be
    -- an Active  calendar instance.
    -- The Admission Calendar must be a child of the Academic Calendar.
    -- This validation is enforced in the database via the foreign key EAP_CIR_FK.
    -- It is included in this module for Forms processing purposes only.
    p_message_name := null;
    OPEN    c_cal_type(
            p_adm_cal_type);
    FETCH   c_cal_type INTO v_s_cal_cat;
    IF(c_cal_type%FOUND) THEN
        IF(v_s_cal_cat <> cst_admission) THEN
            CLOSE c_cal_type;
            --p_message_num := 2541;
            p_message_name := 'IGS_AD_ADMCAL_CAT_AS_ADM';
            RETURN FALSE;
        END IF;
    END IF;
    CLOSE c_cal_type;
    OPEN    c_cal_instance(
            p_adm_cal_type,
            p_adm_ci_sequence_number);
    FETCH   c_cal_instance INTO v_s_cal_status;
    IF(c_cal_instance%FOUND) THEN
        IF(v_s_cal_status <>  cst_active) THEN
            CLOSE c_cal_instance;
            --p_message_num := 2542;
            p_message_name := 'IGS_AD_ADMCAL_PLANNED_ACTIVE';  --removed the planned status as per bug#2722785 --rghosh
            RETURN FALSE;
        END IF;
    END IF;
    CLOSE   c_cal_instance;
    OPEN    c_cal_ins_rel(
            p_acad_cal_type,
            p_acad_ci_sequence_number,
            p_adm_cal_type,
            p_adm_ci_sequence_number);
    FETCH   c_cal_ins_rel INTO v_dummy;
    IF(c_cal_ins_rel%NOTFOUND) THEN
        CLOSE c_cal_ins_rel;
        --p_message_num := 2543;
        p_message_name := 'IGS_AD_ADMCAL_CHILD_ACACAL';
        RETURN FALSE;
    END IF;
    CLOSE c_cal_ins_rel;
    RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.admp_val_ae_adm_cal');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_ae_adm_cal;
  --
  -- Validate the Enquiry applicant has a current address.
  FUNCTION admp_val_eap_addr(
  p_person_id IN NUMBER ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- admp_val_eap_addr
    -- Description: Validate IGR_I_APPL.person_id has a current
    -- correspondence address.
  DECLARE
    v_ret_val   BOOLEAN DEFAULT TRUE;
    CURSOR  c_pa_adt IS
        SELECT  'X'
        FROM    IGS_PE_PERSON_ADDR      pa
        WHERE   pa.person_id        = p_person_id AND
            pa.correspondence_ind   = 'Y' AND
            (pa.status = 'A' AND
             SYSDATE BETWEEN NVL(pa.start_dt,SYSDATE) AND NVL(pa.end_dt,SYSDATE));
    v_pa_adt    c_pa_adt%ROWTYPE;
  BEGIN
    p_message_name := null;
    IF p_person_id IS NULL THEN
        RETURN TRUE;
    END IF;
    OPEN c_pa_adt;
    FETCH c_pa_adt INTO v_pa_adt;
    IF (c_pa_adt%NOTFOUND) THEN
        CLOSE c_pa_adt;
        --p_message_num := 4326;
        p_message_name := 'IGS_AD_PRSN_NO_COR_ADDRESS';
        RETURN  FALSE;
    END IF;
    CLOSE c_pa_adt;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
    IF (c_pa_adt%ISOPEN) THEN
        CLOSE c_pa_adt;
    END IF;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.admp_val_eap_addr');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_eap_addr;
  --
  -- Validate the Enquiry application status on insert.
  FUNCTION admp_val_eap_reg(
  p_enquiry_status IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- admp_val_eap_reg
    -- Description: Validate if IGR_I_APPL.enquiry_status maps to system
    -- status of 'REGISTERED' when inserting a new enquiry.
  DECLARE
    v_es_rec    VARCHAR2(1);
    CURSOR  c_es IS
        SELECT  'X'
        FROM IGR_I_STATUS_V    es
        WHERE   es.enquiry_status   = p_enquiry_status and
            es.s_enquiry_status = 'OSS_REGISTERED';
  BEGIN
    p_message_name := null;
    IF p_enquiry_status IS NULL THEN
        RETURN TRUE;
    ELSE
        OPEN c_es;
        FETCH c_es INTO v_es_rec;
        IF (c_es%NOTFOUND) THEN
            CLOSE c_es;
            --p_message_num := 4392;
            p_message_name := 'IGS_AD_STATUS_MAP_REGISTERED';
            RETURN FALSE;
        END IF;
        CLOSE c_es;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
    IF(c_es%ISOPEN) THEN
        CLOSE c_es;
    END IF;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.admp_val_eap_reg');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_eap_reg;
  --
  -- Validate the Enquiry application status.
  FUNCTION admp_val_eap_status(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_old_enquiry_status IN VARCHAR2 ,
  p_new_enquiry_status IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- admp_val_eap_status
    -- Validate IGR_I_APPL.enquiry_status
    --  * Cannot be set to a system status of COMPLETE if child
    --    IGR_I_A_PKGITM_V exists with mailed_dt set to NULL
    --  * Cannot be set to a system status of REGISTERED from a
    --    system status of ACKNOWLEGE or COMPLETE
    --  * Cannot be set to a system status of ACKNOWLEGE from a
    --    system status of COMPLETE
  DECLARE
    v_old_status        IGR_I_STATUS_V.enquiry_status%TYPE DEFAULT NULL;
    v_new_status        IGR_I_STATUS_V.enquiry_status%TYPE DEFAULT NULL;
    v_eapmpi_found      VARCHAR2(1) DEFAULT NULL;
        cst_complete  CONSTANT VARCHAR2(15) := 'OSS_COMPLETE';
        cst_acknowlege  CONSTANT VARCHAR2(15) := 'OSS_ACKNOWLEGE';
        cst_registered  CONSTANT VARCHAR2(15) := 'OSS_REGISTERED';
       CURSOR   c_es (cp_enquiry_status     IGR_I_APPL.enquiry_status%TYPE) IS
        SELECT  es.s_enquiry_status
        FROM IGR_I_STATUS_V es
        WHERE   es.enquiry_status   = cp_enquiry_status;
    CURSOR  c_eapmpi IS
        SELECT  'x'
        FROM    IGR_I_A_PKGITM_V eapmpi
        WHERE   eapmpi.person_id        = p_person_id AND
            eapmpi.enquiry_appl_number  = p_enquiry_appl_number AND
            eapmpi.mailed_dt        IS NULL;
  BEGIN
    p_message_name := null;
    -- Check parameters.
    IF p_person_id IS NULL OR
            p_enquiry_appl_number IS NULL OR
            p_new_enquiry_status IS NULL THEN
        RETURN TRUE;
    END IF;
    -- Get the system staus of the old and new equiry-statuses.
    IF p_old_enquiry_status IS NOT NULL THEN
        OPEN c_es(p_old_enquiry_status);
        FETCH c_es INTO v_old_status;
        CLOSE c_es;
    END IF;
    OPEN c_es(p_new_enquiry_status);
    FETCH c_es INTO v_new_status;
    CLOSE c_es;
    -- Validate that status can only be set to appropriate system status value.
    IF v_old_status = cst_complete THEN
        IF v_new_status = cst_acknowlege THEN
            p_message_name := 'IGS_AD_ST_ACKNOWLEDGE_COMPLET';
            RETURN FALSE;
        ELSIF v_new_status = cst_registered THEN
            p_message_name := 'IGS_AD_ST_REGISTERED_COMPLETE';
            RETURN FALSE;
        END IF;
    ELSIF v_old_status = cst_acknowlege THEN
        IF v_new_status = cst_registered THEN
            --p_message_num := 4322;
            p_message_name := 'IGS_AD_ST_REGISTERED_ACKNOWLE';
            RETURN FALSE;
        END IF;
    END IF;
    -- Validate that status cannot be set to system status of 'COMPLETE' if child
    -- IGR_I_A_PKGITM_V records exist where mailed_dt is null
    IF v_new_status = cst_complete THEN
        OPEN c_eapmpi;
        FETCH c_eapmpi INTO v_eapmpi_found;
        IF c_eapmpi%FOUND THEN
            CLOSE c_eapmpi;
            --p_message_num := 4320;
            p_message_name := 'IGS_AD_ST_COMPLETE';
            RETURN FALSE;
        END IF;
        CLOSE c_eapmpi;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
        IF c_es%ISOPEN THEN
            CLOSE c_es;
        END IF;
        IF c_eapmpi%ISOPEN THEN
            CLOSE c_eapmpi;
        END IF;
        RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.admp_val_eap_status');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_eap_status;
  --
  -- Validate the Enquiry completion status.
  FUNCTION admp_val_eap_comp(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- admp_val_eap_comp
    -- Validate if IGR_I_APPL.enquiiry_status maps to a system status of
    -- 'COMPLETE'.
  DECLARE
    v_eap_complete      VARCHAR2(1);
    CURSOR  c_eap IS
        SELECT  'X'
        FROM    IGR_I_APPL   eap
        WHERE   eap.person_id = p_person_id AND
            eap.enquiry_appl_number = p_enquiry_appl_number AND
            eap.s_enquiry_status NOT IN ('OSS_REGISTERED','OSS_ACKNOWLEGE');
  BEGIN
    p_message_name := null;
    --Check parameters.
    IF p_person_id IS NULL OR
            p_enquiry_appl_number IS NULL THEN
        RETURN TRUE;
    END IF;
    -- Check if status does NOT maps to system status of 'OSS_REGISTERED' or 'OSS_ACKNOWLEGE'.
    OPEN c_eap;
    FETCH c_eap INTO v_eap_complete;
    IF (c_eap%FOUND) THEN
        CLOSE c_eap;
        p_message_name := 'IGS_AD_ENQUIRY_COMPLETED';
        RETURN FALSE;
    END IF;
    CLOSE c_eap;
    RETURN TRUE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.admp_val_eap_comp');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_eap_comp;
  --
  -- Validate the Enquiry Status closed indicator.
  FUNCTION admp_val_es_status(
  p_enquiry_status IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN -- check if the IGS_IN_ENQ_STATUS is closed
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.admp_val_es_status');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_es_status;
  --
  -- To validate the indicated mailing date of the enquiry package.
  FUNCTION admp_val_eap_ind_dt(
  p_enquiry_dt IN DATE ,
  p_indicated_mailing_dt IN DATE ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
    gv_other_detail     VARCHAR2(255);
  BEGIN -- Validate that IGR_I_APPL.indicated_mailing_dt
    -- is greater than the enquiry_dt.
  DECLARE
    BEGIN
    p_message_name := null;
    -- Validate input parameters
    IF (p_enquiry_dt IS NULL OR p_indicated_mailing_dt IS NULL) THEN
        RETURN TRUE;
    END IF;
    -- Validate that indicated_mailing_dt is greater than or equal to
    -- the enquiry date
    IF (TRUNC(p_indicated_mailing_dt) < TRUNC(p_enquiry_dt)) THEN
        --p_message_num := 4318;
        p_message_name := 'IGS_AD_MAILDT_NOTPRIOR_ENQDT';
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGR_VAL_EAP.admp_val_eap_ind_dt');
        IGS_GE_MSG_STACK.ADD;
  END admp_val_eap_ind_dt;
  --


END IGR_VAL_EAP;

/
