--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_RSUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_RSUP" AS
/* $Header: IGSRE11B.pls 120.3 2006/01/25 01:05:46 bdeviset ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sarakshi    08-Sep-2004     Bug#3869178, modified resp_val_rsup_perc , such that funding and supervisor % are calculated correctly .
  --smadathi    29-AUG-2001     Bug No. 1956374 .The Function genp_val_sdtt_sess removed
  -- pradhakr   20-Nov-2002     Bug# 2661533. Created a new function to get the
  --                            organization start date for the given organisation unit code.
  --                            Added p_legacy paramter to some of the functions.
  --ctyagi     11-April-2005    Bug No. 4287799 . Removed the cursor check_staff and modified the cursor c_funding.
  --bdeviset   29-AUG-2005      Modified procedure resp_val_rsup_perc for bug# 4480892
  --bdeviset   20-JAN-2006      Resolved Performance Issues related to bug# 4937664
-------------------------------------------------------------------------------------------
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (RESP_VAL_CA_CHILDUPD) - from the spec and body. -- kdande
||  Removed program unit (RESP_VAL_CA_TRG) - from the spec and body. -- kdande
*/
  --
  -- Validate research supervisor principal at commencement.
  FUNCTION resp_val_rsup_comm(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_rsup_comm
        -- This module validates that a principal supervisor exists
        -- on the commencement date of the research IGS_RE_CANDIDATURE.
        -- Validatios are:
        --      * At least one IGS_RE_SPRVSR with
        --        IGS_RE_SPRVSR_TYPE checked as a principal
        --        must exist fir an offer where research details
        --        are mandatory or where the IGS_PS_COURSE is defined as
        --        a research supervisor.
  DECLARE
        v_commencement_dt               DATE;
        v_crv_version_number            IGS_EN_STDNT_PS_ATT.version_number%TYPE;
        v_candidature_exists_ind        VARCHAR2(1);
        v_ca_sequence_number            IGS_RE_CANDIDATURE.sequence_number%TYPE;
        CURSOR c_ca IS
                SELECT  ca.sca_course_cd,
                        ca.acai_admission_appl_number,
                        ca.acai_nominated_course_cd,
                        ca.acai_sequence_number
                FROM    IGS_RE_CANDIDATURE              ca
                WHERE   ca.person_id            = p_ca_person_id AND
                        ca.sequence_number      = p_ca_sequence_number;
        v_ca_rec                        c_ca%ROWTYPE;
        CURSOR c_acai (
                cp_admin_appl_num       IGS_AD_PS_APPL.admission_appl_number%TYPE,
                cp_nom_course_cd        IGS_AD_PS_APPL.nominated_course_cd%TYPE,
                cp_seq_number           IGS_AD_PS_APPL_INST.sequence_number%TYPE)
        IS
                SELECT  acai.course_cd,
                        acai.crv_version_number,
                        acai.adm_outcome_status
                FROM    IGS_AD_PS_APPL_INST     acai
                WHERE   acai.person_id                  = p_ca_person_id AND
                        acai.admission_appl_number      = cp_admin_appl_num AND
                        acai.nominated_course_cd        = cp_nom_course_cd AND
                        acai.sequence_number            = cp_seq_number;
        v_acai_rec                      c_acai%ROWTYPE;
        CURSOR c_sca(
                cp_course_cd    IGS_PS_COURSE.course_cd%TYPE) IS
                SELECT  sca.version_number
                FROM    IGS_EN_STDNT_PS_ATT     sca
                WHERE   sca.person_id   = p_ca_person_id AND
                        sca.course_cd   = cp_course_cd;
  BEGIN
        p_message_name := null;
        OPEN c_ca;
        FETCH c_ca INTO v_ca_rec;
        CLOSE c_ca;
        -- Get research commencement date
        v_commencement_dt := IGS_RE_GEN_001.RESP_GET_CA_COMM (
                                p_ca_person_id,
                                v_ca_rec.sca_course_cd,
                                v_ca_rec.acai_admission_appl_number,
                                v_ca_rec.acai_nominated_course_cd,
                                v_ca_rec.acai_sequence_number);
        IF v_commencement_dt IS NOT NULL THEN
                IF v_ca_rec.sca_course_cd IS NOT NULL THEN
                        -- Get IGS_PS_COURSE attempt IGS_PS_COURSE version
                        OPEN c_sca(v_ca_rec.sca_course_cd);
                        FETCH c_sca INTO v_crv_version_number;
                        IF c_sca%NOTFOUND THEN
                                CLOSE c_sca;
                                RETURN TRUE;
                        END IF;
                        CLOSE c_sca;
                END IF;
                IF v_ca_rec.acai_admission_appl_number IS NOT NULL THEN
                        -- Get admission details.
                        OPEN c_acai(
                                v_ca_rec.acai_admission_appl_number,
                                v_ca_rec.acai_nominated_course_cd,
                                v_ca_rec.acai_sequence_number);
                        FETCH c_acai INTO v_acai_rec;
                        IF c_acai%NOTFOUND THEN
                                CLOSE c_acai;
                                RETURN TRUE;
                        ELSE
                                CLOSE c_acai;
                                IF v_ca_rec.sca_course_cd IS NULL THEN
                                        v_ca_rec.sca_course_cd := v_acai_rec.course_cd;
                                        v_crv_version_number := v_acai_rec.crv_version_number;
                                END IF;
                        END IF;
                END IF;
                v_ca_sequence_number := p_ca_sequence_number;
                -- Validate existence of principal on commencement date.
                IF NOT IGS_EN_VAL_SCA.admp_val_ca_comm(
                                p_ca_person_id,
                                v_ca_rec.sca_course_cd,
                                v_crv_version_number,
                                v_ca_rec.acai_admission_appl_number,
                                v_ca_rec.acai_nominated_course_cd,
                                v_ca_rec.acai_sequence_number,
                                v_acai_rec.adm_outcome_status,
                                v_commencement_dt,
                                NULL,
                                'RSUP',
                                v_ca_sequence_number,
                                v_candidature_exists_ind,
                                p_message_name) THEN
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_ca%ISOPEN THEN
                        CLOSE c_ca;
                END IF;
                IF c_acai%ISOPEN THEN
                        CLOSE c_acai;
                END IF;
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_rsup_comm;
  --

  -- Validate research supervisor percentage.
  FUNCTION resp_val_rsup_perc(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_val_supervision_perc_ind IN VARCHAR2 ,
  p_val_funding_perc_ind IN VARCHAR2 ,
  p_parent IN VARCHAR2 ,
  p_supervision_start_dt OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_rsup_perc
        -- This module validates IGS_RE_CANDIDATURE supervision.  Validations are:
        --      * supervision exists such that research load is covered
        --      * supervision is 100% at all times from the start onwards
        --      * funding exists such that research load is covered
        --      * funding is 100% at all times from the start onwards
  DECLARE
        v_total_supervision_percentage          NUMBER;
        v_total_funding_percentage              NUMBER;
        v_exit_loop                             BOOLEAN := FALSE;
        v_gap_exists                            BOOLEAN := FALSE;
        v_rsup2_found                           VARCHAR2(1);
        v_first_start_dt                        DATE;
        cst_rsup                CONSTANT        VARCHAR2(5) := 'RSUP';
        v_start_dt                              DATE;
        v_end_dt                                DATE;
	      l_c_var                                 VARCHAR2(1);
        l_total_no_of_record                    NUMBER;
        l_max_end_dt                            DATE;
        l_date                                  DATE;
        v_enddt_total_sup_per                   NUMBER;

        CURSOR  c_rsup IS
                SELECT  rsup.start_dt, rsup.end_dt
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_ca_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number
                ORDER BY
                        rsup.start_dt DESC;

        -- cursor to find the sum of supervision percentage on  the passed date
        CURSOR c_rsup_per (
                cp_date     IGS_RE_SPRVSR.start_dt%TYPE) IS
                SELECT  NVL(SUM(rsup.supervision_percentage),0)
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_ca_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number AND
                        rsup.start_dt           <= cp_date  AND
                        (rsup.end_dt            IS NULL OR
                        rsup.end_dt             >= cp_date);

        CURSOR  c_funding  IS
        SELECT  NVL(SUM(rsup.funding_percentage),0),count(*)
        FROM    IGS_RE_SPRVSR   rsup,
                igs_pe_person_types pt,
		            igs_pe_typ_instances pti
        WHERE   rsup.ca_person_id       = p_ca_person_id
        AND     rsup.ca_sequence_number = p_ca_sequence_number
	      AND     rsup.person_id = pti.person_id
        AND     pti.person_type_code = pt.person_type_code
        AND     pt.system_type = 'STAFF'
        AND     SYSDATE BETWEEN pti.start_date AND NVL(pti.end_date,SYSDATE);

        CURSOR  c_rsup2 (
                cp_start_dt     IGS_RE_SPRVSR.start_dt%TYPE) IS
                SELECT  'x'
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_ca_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number AND
                        rsup.start_dt           <= cp_start_dt  AND
                        rsup.end_dt             IS NOT NULL AND
                        rsup.end_dt             >= cp_start_dt;
        CURSOR c_rsup3 IS
                SELECT  rsup.start_dt,
                        rsup.end_dt
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_ca_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number
                ORDER BY
                        rsup.start_dt,
                        rsup.end_dt;

              -- cursor to get the latest supervsion end date
        CURSOR c_get_max_end_dt IS
                SELECT MAX(rsup.end_dt)
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_ca_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number;

        -- cursor to find if a open end dated record exists
        CURSOR c_chk_open_end_dt IS
                SELECT rsup.end_dt
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_ca_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number AND
                        rsup.end_dt IS NULL;
  BEGIN
        p_message_name := NULL;
        p_supervision_start_dt := NULL;
        IF p_val_supervision_perc_ind = 'Y' OR
                        p_val_funding_perc_ind = 'Y' THEN
                        v_start_dt := NULL;
                        v_end_dt := NULL;
                FOR v_rsup3_rec IN c_rsup3 LOOP
                        IF (c_rsup3%ROWCOUNT = 1) AND
                                v_rsup3_rec.end_dt IS NULL THEN
                                -- Research supervision is continuous.
                                EXIT;
                        END IF;
                        IF v_start_dt IS NULL THEN
                                -- Must be first record.
                                v_start_dt := v_rsup3_rec.start_dt;
                                v_end_dt := v_rsup3_rec.end_dt;
                        ELSE
                                IF v_start_dt <= v_rsup3_rec.start_dt AND
                                                v_rsup3_rec.start_dt <= (v_end_dt + 1) THEN
                                        IF v_rsup3_rec.end_dt > v_end_dt THEN
                                                v_end_dt := v_rsup3_rec.end_dt;
                                        END IF;
                                ELSE
                                        -- There is a gap in research supervision.
                                        p_message_name := 'IGS_RE_SUPERV_MUST_CONTINUE';
                                        v_gap_exists := TRUE;
                                        EXIT;
                                END IF;
                        END IF;
                END LOOP;
                IF v_gap_exists THEN
                        RETURN FALSE;
                END IF;


		--Funding pecentage must equal 100 at all times, for staff members only
                IF p_val_funding_perc_ind = 'Y' THEN

                  OPEN c_funding;
                  FETCH c_funding INTO v_total_funding_percentage,l_total_no_of_record;

                   IF l_total_no_of_record = 0 THEN
                      CLOSE c_funding;

                  ELSE
                   IF v_total_funding_percentage <> 100 THEN
                     IF p_parent = cst_rsup THEN
                        p_message_name := 'IGS_RE_FUND_%_MUST_100_TIMES';
                     ELSE
                        p_message_name := 'IGS_RE_CAND_DETAIL_INCOMPLETE';
                     END IF;
                     CLOSE c_funding;
                     RETURN FALSE;
                   END IF;
                   CLOSE c_funding;
                  END IF;
                END IF;

                -- set the max end date
                -- if an open end dated record exists then set the max end date to null
                -- else to max end date
                OPEN c_chk_open_end_dt;
                FETCH c_chk_open_end_dt INTO l_max_end_dt;
                IF c_chk_open_end_dt%NOTFOUND THEN
                  OPEN c_get_max_end_dt;
                  FETCH c_get_max_end_dt INTO l_max_end_dt;
                  CLOSE c_get_max_end_dt;
                END IF;
                CLOSE c_chk_open_end_dt;

                FOR v_rsup_rec IN c_rsup LOOP


                      IF p_val_supervision_perc_ind = 'Y' THEN

                          -- 1.To ensure the supervsion is 100 on all days during the supervision check is made on start and next day of end date
                          -- if the end date is null then this check is not made
                          -- if the end date is same as max end date then the check is made on the end date only
                          OPEN c_rsup_per(v_rsup_rec.start_dt);
                          FETCH c_rsup_per INTO v_total_supervision_percentage;
                          CLOSE c_rsup_per;

                          v_enddt_total_sup_per := 100;
                          IF  v_rsup_rec.end_dt IS NOT NULL THEN

                            IF l_max_end_dt IS NULL OR v_rsup_rec.end_dt < l_max_end_dt THEN
                              l_date :=  v_rsup_rec.end_dt + 1;
                            ELSE
                              l_date :=  v_rsup_rec.end_dt;
                            END IF;

                            OPEN c_rsup_per(l_date);
                            FETCH c_rsup_per INTO v_enddt_total_sup_per;
                            CLOSE c_rsup_per;

                          END IF;

                          IF v_total_supervision_percentage <> 100 OR v_enddt_total_sup_per <> 100 THEN
                                  -- Supervision pecentage must equal 100
                                  -- at all times.
                                  IF p_parent = cst_rsup THEN
                                          p_message_name := 'IGS_RE_CAND_SUPERV_%_MUST_100';
                                  ELSE
                                          p_message_name := 'IGS_RE_SUPERV_%_MUST_TOT_100';
                                  END IF;
                                  v_exit_loop := TRUE;
                                  EXIT;
                          END IF;

                      END IF;
                      v_start_dt := v_rsup_rec.start_dt;

                END LOOP; -- research supervisor
                IF v_exit_loop THEN
                        RETURN FALSE;
                END IF;
                IF p_parent <> 'SCA' THEN
                        -- Check that fist start date is on or prior to
                        -- required IGS_RE_CANDIDATURE supervision start.
                        -- Get start date required for supervision
                        v_first_start_dt := IGS_RE_GEN_002.RESP_GET_RSUP_START (
                                                p_ca_person_id,
                                                p_ca_sequence_number,
                                                p_sca_course_cd,
                                                p_acai_admission_appl_number,
                                                p_acai_nominated_course_cd,
                                                p_acai_sequence_number,
                                                p_parent);
                        IF v_first_start_dt IS NOT NULL AND
                                        (v_start_dt IS NULL OR
                                        v_first_start_dt < v_start_dt) THEN
                                IF p_parent = cst_rsup THEN
                                        p_message_name := 'IGS_RE_SUPERV_MUST_EXIST';
                                ELSE
                                        p_message_name := 'IGS_RE_CANDIDACY_DTL_INCOMPLETE';
                                END IF;
                                RETURN FALSE;
                        END IF;
                        p_supervision_start_dt := v_first_start_dt;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_rsup%ISOPEN THEN
                        CLOSE c_rsup;
                END IF;
                IF c_rsup2%ISOPEN THEN
                        CLOSE c_rsup2;
                END IF;
                IF c_rsup3%ISOPEN THEN
                        CLOSE c_rsup3;
                END IF;
                RAISE;
  END;
  END resp_val_rsup_perc;
  --
  -- Validate research supervisor IGS_PE_PERSON.
  FUNCTION resp_val_rsup_person(
  p_ca_person_id IN NUMBER ,
  p_person_id IN NUMBER ,
  p_legacy IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_rsup_person
        -- This module validates IGS_RE_SPRVSR.end_dt. Validations are:
        -- Validations are:
        --      * Cannot be the same as ca_person_id.
  DECLARE
        v_deceased_ind          VARCHAR2(1);

  BEGIN
        -- Set the default message number
     p_message_name := null;
     IF p_person_id IS NOT NULL AND
        p_ca_person_id IS NOT NULL THEN
        IF p_person_id = p_ca_person_id THEN
           p_message_name := 'IGS_RE_CHK_SUPERVISOR';
           RETURN FALSE;
        END IF;
     END IF;

     IF p_legacy = 'N' THEN
        -- Validate that IGS_PE_PERSON exists and warn if deceased.
        v_deceased_ind := IGS_PE_GEN_004.get_deceased_indicator( p_person_id );
        IF v_deceased_ind = 'Y' THEN
                p_message_name := 'IGS_GE_WARN_PERSON_DECEASED';
        END IF;
     END IF;

     -- Return the default value
     RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_rsup_person;
  --
  -- Validate research supervisor principal.
  FUNCTION resp_val_rsup_princ(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_parent IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN         -- resp_val_rsup_princ
        -- This module validates that research IGS_RE_CANDIDATURE has a principal supervisor
        -- for the required time.
  DECLARE
        cst_rsup        CONSTANT        VARCHAR2(10) := 'RSUP';
        v_start_dt                      IGS_RE_SPRVSR.start_dt%TYPE;
        v_dummy                         VARCHAR2(1);
        v_not_found                     BOOLEAN := FALSE;
        v_rsup_exists                   BOOLEAN := FALSE;
        CURSOR c_rsup IS
                SELECT  rsup.start_dt
                FROM    IGS_RE_SPRVSR           rsup
                WHERE   rsup.ca_person_id               = p_ca_person_id AND
                        rsup.ca_sequence_number         = p_ca_sequence_number AND
                        (p_end_dt                       IS NULL OR
                        rsup.start_dt                   <= p_end_dt) AND
                        (rsup.end_dt                    IS NULL OR
                        rsup.end_dt                     >= p_start_dt)
                ORDER BY rsup.start_dt;
        CURSOR c_rsup_rst (
                cp_start_dt                     IGS_RE_SPRVSR.start_dt%TYPE) IS
                SELECT  'X'
                FROM    IGS_RE_SPRVSR           rsup,
                        IGS_RE_SPRVSR_TYPE      rst
                WHERE   rsup.ca_person_id               = p_ca_person_id AND
                        rsup.ca_sequence_number         = p_ca_sequence_number AND
                        rsup.start_dt                   <= cp_start_dt AND
                        (rsup.end_dt                    IS NULL OR
                        rsup.end_dt                     >= cp_start_dt) AND
                        rsup.research_supervisor_type   = rst.research_supervisor_type AND
                        rst.principal_supervisor_ind = 'Y';
  BEGIN
        -- Set the default message number
        p_message_name := null;
        IF p_start_dt IS NOT NULL THEN
                FOR v_rsup_rec IN c_rsup LOOP
                        v_rsup_exists := TRUE;
                        IF v_rsup_rec.start_dt < p_start_dt THEN
                                v_start_dt := p_start_dt;
                        ELSE
                                v_start_dt := v_rsup_rec.start_dt;
                        END IF;
                        -- Validate that the principal supervisor exists
                        OPEN c_rsup_rst(
                                        v_start_dt);
                        FETCH c_rsup_rst INTO v_dummy;
                        IF c_rsup_rst%NOTFOUND THEN
                                CLOSE c_rsup_rst;
                                IF p_parent = cst_rsup THEN
                                        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                                ELSE
                                        p_message_name := 'IGS_RE_SPECIFY_PRIN_SUPERV';
                                END IF;
                                v_not_found := TRUE;
                                EXIT;
                        END IF;
                        CLOSE c_rsup_rst;
                END LOOP;
                IF NOT v_rsup_exists THEN
                        IF p_parent = cst_rsup THEN
                                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                        ELSE
                                p_message_name := 'IGS_RE_SPECIFY_PRIN_SUPERV';
                        END IF;
                        v_not_found := TRUE;
                END IF;
        END IF;
        IF v_not_found THEN
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_rsup%ISOPEN THEN
                        CLOSE c_rsup;
                END IF;
                IF c_rsup_rst%ISOPEN THEN
                        CLOSE c_rsup_rst;
                END IF;
                RAISE;
  END;

  END resp_val_rsup_princ;
  --
  -- Validate research supervisor replaced supervisor.
  FUNCTION resp_val_rsup_repl(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_start_dt IN DATE ,
  p_replaced_person_id IN NUMBER ,
  p_replaced_sequence_number IN NUMBER ,
  p_legacy IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_rsup_repl
        -- This module validates IGS_RE_SPRVSR.replaced_person_id
        -- IGS_RE_SPRVSR.replaced_start_dt. Validations are:
        --      A supervisor cannot be replaced by themselves.
        --              ie replaced_person_id <> person_id.
        --      Replaced _person_id/_sequence_number has to be the latest occurrence
        --              ie latest start_dt.
        --      The replaced supervisor has to have an end date prior to
        --      IGS_RE_SPRVSR.start_dt.
  DECLARE
        CURSOR c_rsup IS
                SELECT  rsup.sequence_number,
                        rsup.end_dt
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_ca_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number AND
                        rsup.person_id          = p_replaced_person_id
                ORDER BY rsup.start_dt DESC;
        v_c_rsup_seq_num        IGS_RE_SPRVSR.sequence_number%TYPE;
        v_c_rsup_end_dt         IGS_RE_SPRVSR.end_dt%TYPE;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        IF p_replaced_person_id IS NOT NULL THEN
                -- Validate that the supervisor and replacement are not the same IGS_PE_PERSON.
                IF p_replaced_person_id = p_person_id THEN
                   p_message_name := 'IGS_RE_SUPERV_REPL_INVALID';
                   IF p_legacy = 'Y' THEN
                      FND_MESSAGE.SET_NAME('IGS', p_message_name);
                      FND_MSG_PUB.Add;
                   ELSE
                      RETURN FALSE;
                   END IF;
                END IF;

                -- Validate that replaced supervisor has an end_dt that is less than
                -- the start_dt or the replacement supervisor
                OPEN c_rsup;
                FETCH c_rsup INTO v_c_rsup_seq_num,
                                v_c_rsup_end_dt;
                IF c_rsup%NOTFOUND THEN
                        CLOSE c_rsup;
                        -- invalid parameters
                        p_message_name := 'IGS_GE_INVALID_VALUE';
                        IF p_legacy = 'Y' THEN
                           FND_MESSAGE.SET_NAME('IGS', p_message_name);
                           FND_MSG_PUB.Add;
                        ELSE
                           RETURN FALSE;
                        END IF;
                ELSE
                        CLOSE c_rsup;
                        IF v_c_rsup_seq_num <> p_replaced_sequence_number THEN
                                -- not replacing latest occurence or research supervisor
                                p_message_name := 'IGS_RE_CHK_OCCURANCE_SUPERV';
                                IF p_legacy = 'Y' THEN
                                   FND_MESSAGE.SET_NAME('IGS', p_message_name);
                                   FND_MSG_PUB.Add;
                                ELSE
                                   RETURN FALSE;
                                END IF;
                        END IF;
                        IF v_c_rsup_end_dt IS NULL THEN
                                -- replaced supervisor must have ended supervision
                                p_message_name := 'IGS_RE_END_DATE_NOT_NULL';
                                IF p_legacy = 'Y' THEN
                                   FND_MESSAGE.SET_NAME('IGS', p_message_name);
                                   FND_MSG_PUB.Add;
                                ELSE
                                   RETURN FALSE;
                                END IF;
                        ELSIF v_c_rsup_end_dt >= p_start_dt THEN
                                -- replaced supervisor cannot overlap timeframe of replacing supervisor
                                p_message_name := 'IGS_RE_REPL_SUPERV_CANT_SUPER';
                                IF p_legacy = 'Y' THEN
                                   FND_MSG_PUB.Add;
                                ELSE
                                   RETURN FALSE;
                                END IF;
                        END IF; --IF v_c_rsup_end_dt IS NULL
                END IF; -- if c_rsup%NOTFOUND
        END IF; -- IF p_replaced_person_id IS NOT NULL
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_rsup %ISOPEN THEN
                        CLOSE c_rsup;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_rsup_repl;
  --
  -- Validate research supervisor funding percentage.
  FUNCTION resp_val_rsup_fund(
  p_person_id IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_funding_percentage IN NUMBER ,
  p_staff_member_ind IN VARCHAR2 ,
  p_legacy IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_rsup_fund
        -- This module validates IGS_RE_SPRVSR.funding_percentage.
        -- Validations are:
        --      If funding percentage exists, then
        --              organisational IGS_PS_UNIT must exist and be valid.
        --      If funding percentage exists, then
        --              supervisor must be a staff member.
  DECLARE
        v_staff_member_ind      IGS_PE_PERSON.staff_member_ind%TYPE;
        v_message_name          VARCHAR2(30);

  BEGIN
        -- Set the default message number
     p_message_name := NULL;

     IF (p_staff_member_ind IS NULL) AND (p_legacy <> 'Y') THEN
        -- determine if supervisor is a staff member
        v_staff_member_ind := igs_en_gen_003.get_staff_ind(p_person_id);
     ELSE
        v_staff_member_ind := p_staff_member_ind;
     END IF;


     IF p_funding_percentage IS NOT NULL THEN
              IF v_staff_member_ind = 'N' THEN
                   -- Only staff members req. funding percentage
                   p_message_name := 'IGS_RE_FUND_%_REQR_FOR_STAFF';
                   IF p_legacy <> 'Y' THEN
                      RETURN FALSE;
                   ELSE
                     FND_MESSAGE.SET_NAME('IGS', p_message_name);
                     FND_MSG_PUB.Add;
                   END IF;
                END IF;

                IF p_org_unit_cd IS NULL OR p_ou_start_dt IS NULL THEN
                   -- Organisational IGS_PS_UNIT must be specified with funding percentage.
                   p_message_name := 'IGS_RE_SPECIFY_ORG_UNIT';
                   IF p_legacy <> 'Y' THEN
                      RETURN FALSE;
                   ELSE
                      FND_MESSAGE.SET_NAME('IGS', p_message_name);
                      FND_MSG_PUB.Add;
                   END IF;
                END IF;

                IF p_legacy <> 'Y' THEN
                   -- Validate organisational IGS_PS_UNIT
                   IF NOT (IGS_RE_VAL_RSUP.resp_val_rsup_ou(
                                                p_person_id,
                                                p_org_unit_cd,
                                                p_ou_start_dt,
                                                p_staff_member_ind,
                                                p_legacy,
                                                p_message_name)) THEN
                      RETURN FALSE;
                   END IF;
               END IF;

        ELSE -- p_funding_percentage IS  NULL
                IF v_staff_member_ind = 'Y' THEN
                   p_message_name := 'IGS_RE_FUND_%_REQUIRED';
                   IF p_legacy <> 'Y' THEN
                      RETURN FALSE;
                   ELSE
                      FND_MESSAGE.SET_NAME('IGS', p_message_name);
                      FND_MSG_PUB.Add;
                   END IF;
                END IF;
        END IF;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_rsup_fund;
  --
  -- Validate research supervisor organisational IGS_PS_UNIT.
  FUNCTION resp_val_rsup_ou(
  p_person_id IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_staff_member_ind IN VARCHAR2 ,
  p_legacy IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
 BEGIN  -- resp_val_rsup_ou
        -- This module validates IGS_RE_SPRVSR.org_unit_cd/ou_start_dt.
        --      Organisational IGS_PS_UNIT must be active.
        --      Organisational IGS_PS_UNIT must be local is supervisor is a staff member.
  DECLARE
        cst_active      CONSTANT VARCHAR2(8) := 'ACTIVE';
        CURSOR c_ou_os_ins IS
                 SELECT os.s_org_status, ins.oi_local_institution_ind
                 FROM igs_or_status os,
                      igs_or_inst_org_base_v org,
                      igs_or_inst_org_base_v ins
                 WHERE org.inst_org_ind =  'O'
                 AND org.org_status = os.org_status
                 AND ins.inst_org_ind = 'I'
                 AND  ins.party_number = org.ou_institution_cd
                 AND org.party_number = p_org_unit_cd
                 AND org.start_dt = p_ou_start_dt;

        v_c_ooi_sos     IGS_OR_STATUS.s_org_status%TYPE;
        v_c_ooi_lii     IGS_OR_INSTITUTION.local_institution_ind%TYPE;
        v_staff_member_ind      IGS_PE_PERSON.staff_member_ind%TYPE;
  BEGIN
        -- Set the default message number
        p_message_name := NULL;
        IF p_org_unit_cd IS NOT NULL AND p_ou_start_dt IS NOT NULL THEN
           IF p_legacy <> 'Y' THEN
                OPEN c_ou_os_ins;
                FETCH c_ou_os_ins INTO v_c_ooi_sos,v_c_ooi_lii;
                IF c_ou_os_ins%NOTFOUND THEN
                        CLOSE c_ou_os_ins;
                        RETURN TRUE;
                END IF;
                CLOSE c_ou_os_ins;
                IF v_c_ooi_sos <> cst_active THEN
                        --must be organisational IGS_PS_UNIT
                        p_message_name := 'IGS_RE_ORG_UNIT_MUST_BE_ACTIV';
                        RETURN FALSE;
                END IF;
                IF p_staff_member_ind IS NULL THEN
                        v_staff_member_ind := igs_en_gen_003.get_staff_ind(p_person_id) ;
                ELSE
                        v_staff_member_ind := p_staff_member_ind;
                END IF;
            END IF;

            IF v_staff_member_ind = 'Y' THEN
               -- Must be a local IGS_OR_INSTITUTION organisational IGS_PS_UNIT if
               -- supervisor is a staff member.
                IF v_c_ooi_lii ='N' THEN
                   p_message_name := 'IGS_RE_CHK_ORG_UNIT';
                   IF p_legacy <> 'Y' THEN
                      RETURN FALSE;
                   ELSE
                      FND_MESSAGE.SET_NAME('IGS', p_message_name);
                      FND_MSG_PUB.Add;
                   END IF;
                END IF;
            END IF;
        END IF; -- p_org_unit_cd IS NOT NULL ...
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_ou_os_ins%ISOPEN THEN
                        CLOSE c_ou_os_ins;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_rsup_ou;
  --
  -- Validate research supervisor overlaps.
  FUNCTION resp_val_rsup_ovrlp(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_legacy IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_rsup_ovrlp
        -- This module validates IGS_RE_SPRVSR.person_id overlaps.
  DECLARE
        CURSOR c_rsup IS
                SELECT  rsup.start_dt,
                        rsup.end_dt
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_ca_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number AND
                        rsup.person_id          = p_person_id AND
                        (p_sequence_number      IS NULL OR
                        rsup.sequence_number    <> p_sequence_number)
                ORDER BY rsup.start_dt desc;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        FOR v_rsup_rec IN c_rsup LOOP
                IF v_rsup_rec.end_dt IS NULL THEN
                        IF p_end_dt IS NULL OR
                                v_rsup_rec.start_dt <= p_end_dt THEN
                                p_message_name := 'IGS_RE_SUPERV_PER_OVERLAP';
                                IF p_legacy = 'Y' THEN
                                   FND_MESSAGE.SET_NAME('IGS', p_message_name);
                                   FND_MSG_PUB.Add;
                                ELSE
                                   RETURN FALSE;
                                END IF;
                        END IF;
                ELSIF v_rsup_rec.end_dt >= p_start_dt AND
                                (p_end_dt IS NULL OR
                                v_rsup_rec.start_dt <= p_end_dt) THEN
                         -- Supervision period must overlap
                        p_message_name := 'IGS_RE_SUPERV_PER_OVERLAP';
                        IF p_legacy = 'Y' THEN
                           FND_MESSAGE.SET_NAME('IGS', p_message_name);
                           FND_MSG_PUB.Add;
                        ELSE
                           RETURN FALSE;
                        END IF;
                END IF;
        END LOOP; --IGS_RE_SPRVSR
        -- no records found.
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_rsup %ISOPEN THEN
                        CLOSE c_rsup;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_rsup_ovrlp;
  --

  --
  -- Validate research supervisor end date.
  FUNCTION resp_val_rsup_end_dt(
    p_ca_person_id IN NUMBER ,
    p_ca_sequence_number IN NUMBER ,
    p_person_id IN NUMBER ,
    p_sequence_number  NUMBER ,
    p_start_dt IN DATE ,
    p_end_dt IN DATE ,
    p_legacy IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
 BEGIN  -- resp_val_rsup_end_dt
        -- This module validates IGS_RE_SPRVSR.end_dt. Validations are:
        --      end_dt >= start_dt
        --      end_dt < any replacement supervisors
  DECLARE
        v_rsup_exists   VARCHAR2(1);
        CURSOR c_rsup IS
                SELECT  'x'
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id               = p_ca_person_id AND
                        rsup.ca_sequence_number         = p_ca_sequence_number AND
                        rsup.replaced_person_id         = p_person_id AND
                        rsup.replaced_sequence_number   = p_sequence_number AND
                        (p_end_dt                       IS NULL OR
                        rsup.start_dt                   <= p_end_dt);
  BEGIN
        -- Set the default message number
        p_message_name := null;
        IF p_end_dt IS NOT NULL THEN
                IF p_end_dt < p_start_dt THEN
                   p_message_name := 'IGS_GE_INVALID_DATE';
                   IF p_legacy <> 'Y' THEN
                     RETURN FALSE;
                   ELSE
                     FND_MESSAGE.SET_NAME('IGS', p_message_name);
                     FND_MSG_PUB.Add;
                   END IF;
                END IF;
        END IF;

        IF p_legacy = 'N' THEN
           IF p_person_id IS NOT NULL AND  p_sequence_number IS NOT NULL THEN
              OPEN c_rsup;
              FETCH c_rsup INTO v_rsup_exists;
              IF c_rsup%FOUND THEN
                 CLOSE c_rsup;
                 p_message_name := 'IGS_RE_END_DT_CANT_GE_ST_DT';
                 RETURN FALSE;
              END IF;
              CLOSE c_rsup;
           END IF;
        END IF;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_rsup %ISOPEN THEN
                        CLOSE c_rsup;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_rsup_end_dt;
  --
  -- Validate if Research Supervisor Type is closed.
  FUNCTION resp_val_rst_closed(
  p_research_supervisor_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_rst_closed
        -- Validate if IGS_RE_SPRVSR_TYPE.IGS_RE_SPRVSR_TYPE is closed.
  DECLARE
        CURSOR c_rst IS
                SELECT  'x'
                FROM    IGS_RE_SPRVSR_TYPE      rst
                WHERE   rst.research_supervisor_type    = p_research_supervisor_type AND
                        rst.closed_ind                  = 'Y';
        v_rst_exists    VARCHAR2(1);
  BEGIN
        -- Set the default message number
        p_message_name := null;
        -- Cursor handling
        OPEN c_rst;
        FETCH c_rst INTO v_rst_exists;
        IF c_rst %FOUND THEN
                CLOSE c_rst;
                p_message_name := 'IGS_RE_SUPERV_TYPE_CLOSED';
                RETURN FALSE;
        END IF;
        CLOSE c_rst;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_rst %ISOPEN THEN
                        CLOSE c_rst;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_rst_closed;

 -- Function to get the Start Date of the Organisation Unit.
 FUNCTION get_org_unit_dtls (
   p_org_unit_cd IN VARCHAR2,
   p_start_dt OUT NOCOPY DATE
 ) RETURN BOOLEAN IS

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 20-Nov-02
  Purpose         : This function returns the organization start date for a given
                    organisation unit code. Created as part of Research Supervisor Details build.
                    Bug# 2661533
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/

  -- Cursor to get the start date of the organization
  CURSOR c_org_date IS
    SELECT start_dt
    FROM igs_or_unit
    WHERE org_unit_cd = p_org_unit_cd;

  l_start_dt igs_or_unit.start_dt%TYPE;

 BEGIN

    OPEN c_org_date;
    FETCH c_org_date INTO l_start_dt;
    CLOSE c_org_date;

    IF l_start_dt IS NOT NULL THEN
       p_start_dt := l_start_dt;
       RETURN TRUE;
    ELSE
       p_start_dt := NULL;
      RETURN FALSE;
    END IF;

 END get_org_unit_dtls;

END IGS_RE_VAL_RSUP;

/
