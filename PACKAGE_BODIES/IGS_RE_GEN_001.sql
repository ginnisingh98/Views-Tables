--------------------------------------------------------
--  DDL for Package Body IGS_RE_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_GEN_001" AS
/* $Header: IGSRE01B.pls 120.1 2005/11/24 04:36:30 appldev ship $ */

-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --Nishikant   11DEC2002       ENCR027 Build (Program Length Integration) . In the function RESP_CLC_MAX_SBMSN and
  --                            RESP_CLC_MIN_SBMSN the signature of the function call igs_ps_gen_002.crsp_get_crv_eftd got
  --                            modified, which used to get the value for the variable v_crv_eftd.
  --vvutukur    19_oct-2002     Enh#2608227.Modified functions resp_clc_max_sbmsn,resp_clc_min_sbmsn.
  --prchandr    08-Jan-01       Enh Bug No: 2174101, As the Part of Change in IGSEN18B
  --                            Passing NULL as parameters  to ENRP_CLC_SUA_EFTSU
  --                            ENRP_CLC_EFTSU_TOTAL for Key course cd and version number
  -------------------------------------------------------------------------------------------
FUNCTION RESP_CLC_EFTSU_TRUNC(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_uoo_id IN NUMBER ,
  p_census_dt IN DATE ,
  p_eftsu IN NUMBER )
RETURN NUMBER AS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- resp_clc_eftsu_trunc
        -- Routine to perform the necessary truncation on the DEETYA reported EFTSU
        -- for research units - this is in accordance with the DEETYA guidelines, and
        -- is required to be able to reconcile EFTSU figures calculated on a day to
        -- day basis with those reported in the DEETYA submissions.
        -- This routine will ?roll down? the EFTSU to the lowest common denominator,
        -- truncate the value and then ?roll up? to the required level.
        -- Research IGS_PS_UNIT AOU?s are defined by the links with their supervisors (or
        -- if not specified, by the standards means).
DECLARE
        CURSOR c_rsup (
                cp_census_dt    IGS_CA_DA_INST.absolute_val%TYPE)
        IS
                SELECT  rsup.org_unit_cd,
                        rsup.ou_start_dt,
                        sum(rsup.funding_percentage) sum_fund_perc
                FROM    IGS_RE_SPRVSR   rsup
                WHERE   rsup.ca_person_id       = p_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number AND
                        rsup.funding_percentage IS NOT NULL AND
                        rsup.funding_percentage > 0 AND
                        rsup.start_dt           <= cp_census_dt AND
                        (rsup.end_dt            IS NULL OR
                         rsup.end_dt            >= cp_census_dt)
                GROUP BY
                        rsup.org_unit_cd,
                        rsup.ou_start_dt;
        CURSOR c_udis IS
                SELECT  udis.percentage
                FROM    IGS_PS_UNIT_DSCP udis
                WHERE   udis.unit_cd            = p_unit_cd AND
                        udis.version_number     = p_version_number;
        CURSOR c_sgcc_dai IS
                SELECT  NVL(dai.absolute_val, IGS_CA_GEN_001.calp_get_alias_val(
                                                dai.dt_alias,
                                                dai.sequence_number,
                                                dai.cal_type,
                                                dai.ci_sequence_number)) census_dt
                FROM    IGS_PS_UNIT_OFR_OPT uoo,
                        IGS_GE_S_GEN_CAL_CON            sgcc,
                        IGS_CA_DA_INST  dai
                WHERE   uoo.uoo_id              = p_uoo_id AND
                        sgcc.s_control_num      = 1 and
                        dai.dt_alias            = sgcc.census_dt_alias AND
                        dai.cal_type            = uoo.cal_type AND
                        dai.ci_sequence_number  = uoo.ci_sequence_number
                ORDER BY census_dt;
        v_census_dt     IGS_CA_DA_INST.absolute_val%TYPE;
        v_eftsu_total   NUMBER;
        -- So I can test whether any records were found for statement 2
        v_records_found BOOLEAN := FALSE;
BEGIN
        v_eftsu_total := 0.000;
        IF p_census_dt IS NULL THEN
                OPEN c_sgcc_dai;
                FETCH c_sgcc_dai INTO v_census_dt;
                IF c_sgcc_dai%NOTFOUND THEN
                        CLOSE c_sgcc_dai;
                        -- Bad parameters - return zero
                        RETURN 0;
                END IF;
                CLOSE c_sgcc_dai;
        ELSE -- p_census_dt IS NOT NULL
                v_census_dt := p_census_dt;
        END IF;
        FOR v_rsup_rec IN c_rsup (
                                v_census_dt) LOOP
                FOR v_udis_rec IN c_udis LOOP
                        -- No reason to reenter this IF - when v_records_found is already true
                        IF NOT v_records_found THEN
                                -- A supervision percentage record found!
                                v_records_found := TRUE;
                        END IF;
                        v_eftsu_total :=
                                        v_eftsu_total +
                                                TRUNC(
                                                        (p_eftsu * (v_rsup_rec.sum_fund_perc / 100)
                                                                        * (v_udis_rec.percentage / 100)),
                                                        3);
                END LOOP;
        END LOOP;
        IF NOT v_records_found THEN
                -- If no supervision percentage found then use the IGS_PS_UNIT values
                v_eftsu_total := IGS_EN_PRC_LOAD.enrp_clc_eftsu_trunc(
                                                                p_unit_cd,
                                                                p_version_number,
                                                                p_uoo_id,
                                                                p_eftsu);
        END IF;
        RETURN v_eftsu_total;
EXCEPTION
        WHEN OTHERS THEN
                IF c_rsup %ISOPEN THEN
                        CLOSE c_rsup;
                END IF;
                IF c_udis %ISOPEN THEN
                        CLOSE c_udis;
                END IF;
                IF c_sgcc_dai%ISOPEN THEN
                        CLOSE c_sgcc_dai;
                END IF;
                RAISE;
END;
END resp_clc_eftsu_trunc;


FUNCTION RESP_CLC_LOAD_EFTSU(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER )
RETURN NUMBER AS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- resp_clc_load_eftsu
        -- Calculate the maximum EFTSU applicable in a load calendar according to the
        -- percentage field held in the IGS_CA_INST_REL table for the
        -- relationship between the academic and load calendar instances.
DECLARE
        v_load_research_percentage
        IGS_CA_INST_REL.load_research_percentage%TYPE;
        CURSOR  c_cir IS
                SELECT  cir.load_research_percentage
                FROM    IGS_CA_INST_REL cir
                WHERE   sup_cal_type            = p_acad_cal_type               AND
                        sup_ci_sequence_number  = p_acad_ci_sequence_number     AND
                        sub_cal_type            = p_load_cal_type               AND
                        sub_ci_sequence_number  = p_load_ci_sequence_number;
BEGIN
        OPEN c_cir;
        FETCH c_cir INTO v_load_research_percentage;
        IF v_load_research_percentage IS NULL THEN
                CLOSE c_cir;
                RETURN 0;
        END IF;
        CLOSE c_cir;
        RETURN v_load_research_percentage/100;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_cir%ISOPEN) THEN
                        CLOSE c_cir;
                END IF;
                RAISE;
END;
END resp_clc_load_eftsu;


FUNCTION RESP_CLC_MAX_SBMSN(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_attendance_percentage IN NUMBER ,
  p_commencement_dt IN DATE )
RETURN DATE AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant   11DEC2002    The signature of the function call igs_ps_gen_002.crsp_get_crv_eftd got
  ||                           modified, which used to get the value for the variable v_crv_eftd
  ||  vvutukur    19-Oct-2002  Enh#2608227.Added cursor cur_coo_id to fetch coo_id of course and modified
  ||                           call to igs_ps_gen_002.crsp_get_crv_eftd.
  || svanukur     28-jul-2004  implemented an nvl check to pass p_acai_nominated_course_cd in the call to
  ||                            igs_ps_gen_002.crsp_get_crv_eftd bug 3487851
  ----------------------------------------------------------------------------*/
        gv_other_detail         VARCHAR2(255);
BEGIN   -- resp_clc_max_sbmsn
        -- Calculate the minimum submission date of a student IGS_PS_COURSE attempt
        -- IGS_RE_CANDIDATURE. This is calculated as the remaining EFTD (Effective
        -- Full Time Days) remaining in the IGS_PS_COURSE multiplied by the minimum
        -- submission percentage (stored against the students IGS_PS_COURSE version)
        -- factored with the students current attendance percentage.
DECLARE
        cst_unconfirm           CONSTANT        VARCHAR2(10) := 'UNCONFIRM';
        v_ca_acai_adm_appl_number               IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE;
        v_ca_acai_nominated_course_cd           IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE;
        v_ca_acai_sequence_number               IGS_RE_CANDIDATURE.acai_sequence_number%TYPE;
        v_ca_sca_course_cd                      IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
        v_ca_attendance_percentage              IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
        v_candidature_exists_ind                        VARCHAR2(1);
        v_sca_course_cd                         IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
        v_sca_version_number                    IGS_EN_STDNT_PS_ATT.version_number%TYPE;
        v_sca_attendance_type                   IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
        v_sca_course_attempt_status
                                                IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        v_sca_commencement_dt                   IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
        v_acai_course_cd                        IGS_PS_VER.course_cd%TYPE;
        v_acai_version_number                   IGS_PS_VER.version_number%TYPE;
        v_acai_attendance_type                  IGS_EN_ATD_TYPE.attendance_type%TYPE;
        v_attendance_percentage                 IGS_EN_ATD_TYPE.research_percentage%TYPE;
        v_att_attendance_percentage                     IGS_EN_ATD_TYPE.research_percentage%TYPE;
        v_crv_eftd                              NUMBER;
        v_used_eftd_days                        NUMBER;
        v_eftd_remaining                        NUMBER;
        v_remaining_days                        NUMBER;
        v_commencement_dt                       DATE;

        CURSOR c_ca IS
                SELECT  ca.acai_admission_appl_number,
                        ca.acai_nominated_course_cd,
                        ca.acai_sequence_number,
                        ca.sca_course_cd,
                        ca.attendance_percentage
                FROM    IGS_RE_CANDIDATURE                      ca
                WHERE   ca.person_id                    = p_person_id AND
                        ca.sequence_number              = p_ca_sequence_number;
        CURSOR c_sca IS
                SELECT  sca.course_cd,
                        sca.version_number,
                        sca.attendance_type,
                        sca.commencement_dt,
                        sca.course_attempt_status
                FROM    IGS_EN_STDNT_PS_ATT             sca
                WHERE   sca.person_id                   = p_person_id AND
                        sca.course_cd                   = v_ca_sca_course_cd;

        CURSOR c_acaiv IS
                SELECT  acai.course_cd,
                    acai.crv_version_number,
                    acai.attendance_type
             FROM
                    IGS_AD_PS_APPL_INST acai,
                        IGS_AD_APPL aa,
                    IGS_CA_INST ci,
                    IGS_AD_PS_APPL aca,
                    IGS_PS_VER crv
             WHERE  acai.person_id  = p_person_id AND
                    acai.admission_appl_number = v_ca_acai_adm_appl_number AND
                    acai.nominated_course_cd =  v_ca_acai_nominated_course_cd AND
                    acai.sequence_number = v_ca_acai_sequence_number AND
                    aa.person_id = acai.person_id AND
                      aa.admission_appl_number = acai.admission_appl_number AND
                      ci.cal_type (+) = acai.deferred_adm_cal_type AND
                      ci.sequence_number (+) = acai.deferred_adm_ci_sequence_num AND
                      aca.person_id = acai.person_id AND
                      aca.admission_appl_number = acai.admission_appl_number AND
                      aca.nominated_course_cd = acai.nominated_course_cd AND
                      crv.course_cd = acai.course_cd AND
                      crv.version_number = acai.crv_version_number;

    CURSOR c_att IS
                SELECT  att.research_percentage
                FROM    IGS_EN_ATD_TYPE att
                WHERE   att.attendance_type = NVL(v_sca_attendance_type,v_acai_attendance_type);

  l_dummy_bool   BOOLEAN;
        l_message_name fnd_new_messages.message_name%TYPE;

BEGIN
        v_ca_acai_adm_appl_number := NULL;
        v_ca_acai_nominated_course_cd := NULL;
        v_ca_acai_sequence_number := NULL;
        v_ca_sca_course_cd := NULL;
        v_ca_attendance_percentage := NULL;
        IF p_ca_sequence_number IS NOT NULL THEN
                -- Select details from IGS_RE_CANDIDATURE
                OPEN c_ca;
                FETCH c_ca INTO v_ca_acai_adm_appl_number,
                                v_ca_acai_nominated_course_cd,
                                v_ca_acai_sequence_number,
                                v_ca_sca_course_cd,
                                v_ca_attendance_percentage;
                IF c_ca%NOTFOUND THEN
                        CLOSE c_ca;
                        RETURN NULL;
                END IF;
                CLOSE c_ca;
        ELSE
                IF p_sca_course_cd IS NULL AND
                                (p_acai_admission_appl_number IS NULL OR
                                p_acai_nominated_course_cd IS NULL OR
                                p_acai_sequence_number IS NULL) THEN
                        RETURN NULL;
                END IF;
                v_ca_acai_adm_appl_number := p_acai_admission_appl_number;
                v_ca_acai_nominated_course_cd := p_acai_nominated_course_cd;
                v_ca_acai_sequence_number := p_acai_sequence_number;
                v_ca_sca_course_cd := p_sca_course_cd;
        END IF;
        -- Either select details from the admission application or the student
        -- IGS_PS_COURSE attempt depending on the IGS_RE_CANDIDATURE fields which are set.
        IF v_ca_sca_course_cd IS NOT NULL THEN
                OPEN c_sca;
                FETCH c_sca INTO v_sca_course_cd,
                                v_sca_version_number,
                                v_sca_attendance_type,
                                v_sca_commencement_dt,
                                v_sca_course_attempt_status;
                IF c_sca%NOTFOUND THEN
                        CLOSE c_sca;
                        RETURN NULL;
                END IF;
                CLOSE c_sca;
        ELSE
                v_sca_course_cd := NULL;
                v_sca_version_number := NULL;
                v_sca_attendance_type := NULL;
                v_sca_course_attempt_status := NULL;
        END IF;
        -- If the admission details have been passed then use these.
        IF v_ca_acai_adm_appl_number IS NOT NULL THEN

                OPEN c_acaiv;
                FETCH c_acaiv INTO v_acai_course_cd,
                                        v_acai_version_number,
                                        v_acai_attendance_type;
                IF c_acaiv%NOTFOUND THEN
                        CLOSE c_acaiv;
                        RETURN NULL;
                END IF;
                CLOSE c_acaiv;

        ELSE
                v_acai_course_cd := NULL;
                v_acai_version_number := NULL;
                v_acai_attendance_type := NULL;
        END IF;

        --Call routine to get the program length.
        --v_crv_eftd will have a valid value if the EFTD calculated properly in the
        --below function otherwise it will have a value zero
        --passing p_acai_nominated_course_cd since sca_course_cd will be null when called
        -- from admissions before prenerolment is triggered
        v_crv_eftd := igs_ps_gen_002.crsp_get_crv_eftd( p_person_id,
                                                        nvl(p_sca_course_cd,p_acai_nominated_course_cd));

        IF v_crv_eftd <= 0 THEN
                -- Cannot calculate date if the IGS_PS_COURSE version has no EFTD
                RETURN NULL;
        END IF;
        if v_crv_eftd is NULL then
                v_crv_eftd := 0 ;
        END IF;
        OPEN c_att;
        FETCH c_att INTO v_att_attendance_percentage;
        CLOSE c_att;
        -- Determine attendance percentage
        IF NVL(p_attendance_percentage, v_ca_attendance_percentage) IS NULL THEN
                v_attendance_percentage := v_att_attendance_percentage;
        ELSE
                v_attendance_percentage := NVL(
                                                p_attendance_percentage,
                                                v_ca_attendance_percentage);
        END IF;
        --added this condition since the research percentage can be set to 0
        -- this will raise an unhandled exception since it will result in
        -- a divide by 0

        IF (v_attendance_percentage = 0 ) OR (v_att_attendance_percentage = 0) THEN
        RETURN NULL;
        END IF;
        IF v_ca_sca_course_cd IS NOT NULL THEN
                -- Call routine to determine the effective full time days already used
                v_used_eftd_days := resp_clc_used_eftd(
                                                        p_person_id,
                                                        v_ca_sca_course_cd,
                                                        'Y',
                                                        p_ca_sequence_number,
                                                        v_attendance_percentage);
        ELSE
                -- Only enrolled students could have used EFTD
                v_used_eftd_days := 0;
        END IF;
        v_eftd_remaining := v_crv_eftd - v_used_eftd_days;
        IF v_eftd_remaining <= 0 THEN
                -- No days left - return the current date
                RETURN TRUNC(SYSDATE);
        END IF;
        -- Multiply the number of remaining EFTD by the students current attendance
        -- to determine the maximum submission date
        IF v_attendance_percentage <> 0 THEN
                v_remaining_days := v_eftd_remaining / (v_attendance_percentage / 100);
        ELSE
                v_remaining_days := v_eftd_remaining / (v_att_attendance_percentage / 100);
        END IF;
        -- Determine if the students commencement date is a future date - if so,
        -- the remaining days are added to their prospective commencement date
        -- rather than the current date
        IF p_commencement_dt IS NULL THEN
                IF v_ca_acai_adm_appl_number IS NULL OR
                        NVL(v_sca_course_attempt_status, cst_unconfirm) <> cst_unconfirm THEN
                        v_commencement_dt := NVL(v_sca_commencement_dt, TRUNC(SYSDATE));
                ELSE
                        v_commencement_dt := resp_get_ca_comm(
                                                p_person_id,
                                                v_ca_sca_course_cd,
                                                v_ca_acai_adm_appl_number,
                                                v_ca_acai_nominated_course_cd,
                                                v_ca_acai_sequence_number);
                END IF;
        ELSE
                v_commencement_dt := p_commencement_dt;
        END IF;
        IF v_commencement_dt >= TRUNC(SYSDATE) THEN
                RETURN (v_commencement_dt + v_remaining_days);
        ELSE
                RETURN (TRUNC(SYSDATE) + NVL(v_remaining_days,0));
        END IF;
EXCEPTION
        WHEN OTHERS THEN
                IF c_ca%ISOPEN THEN
                        CLOSE c_ca;
                END IF;
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;

                IF c_acaiv%ISOPEN THEN
                        CLOSE c_acaiv;
                END IF;

                IF c_att%ISOPEN THEN
                        CLOSE c_att;
                END IF;
                RAISE;
END;
END resp_clc_max_sbmsn;


FUNCTION RESP_CLC_MIN_SBMSN(
  P_PERSON_ID IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_attendance_percentage IN NUMBER ,
  p_commencement_dt IN DATE )
RETURN DATE AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant   11DEC2002    The signature of the function call igs_ps_gen_002.crsp_get_crv_eftd got
  ||                           modified, which used to get the value for the variable v_crv_eftd
  ||  vvutukur    19-Oct-2002  Enh#2608227.Added cursor cur_coo_id to fetch coo_id of course and modified
  ||                           call to igs_ps_gen_002.crsp_get_crv_eftd.
  || svanukur     28-jul-2004  implemented an nvl check to pass p_acai_nominated_course_cd in the call to
  ||                            igs_ps_gen_002.crsp_get_crv_eftd bug 3487851
  ----------------------------------------------------------------------------*/
        gv_other_detail         VARCHAR2(255);
BEGIN   -- resp_clc_min_sbmsn
        -- Calculate the minimum submission date of a student IGS_PS_COURSE attempt
        -- IGS_RE_CANDIDATURE. This is calculated as the remaining EFTD (Effective
        -- Full Time Days) remaining in the IGS_PS_COURSE multiplied by the minimum
        -- submission percentage (stored against the students IGS_PS_COURSE version)
        -- factored with the students current attendance percentage.
DECLARE
        cst_unconfirm           CONSTANT        VARCHAR2(10) := 'UNCONFIRM';
        v_ca_acai_adm_appl_number               IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE;
        v_ca_acai_nominated_course_cd           IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE;
        v_ca_acai_sequence_number               IGS_RE_CANDIDATURE.acai_sequence_number%TYPE;
        v_ca_sca_course_cd                      IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
        v_ca_attendance_percentage              IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
        v_candidature_exists_ind                        VARCHAR2(1);
        v_sca_course_cd                         IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
        v_sca_version_number                    IGS_EN_STDNT_PS_ATT.version_number%TYPE;
        v_sca_attendance_type                   IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
        v_sca_course_attempt_status
                                                IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        v_sca_commencement_dt                   IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
        v_acai_course_cd                        IGS_PS_VER.course_cd%TYPE;
        v_acai_version_number                   IGS_PS_VER.version_number%TYPE;
        v_acai_attendance_type                  IGS_EN_ATD_TYPE.attendance_type%TYPE;
        v_crv_min_sbmsn_percentage              IGS_PS_VER.min_sbmsn_percentage%TYPE;
        v_attendance_percentage                 IGS_EN_ATD_TYPE.research_percentage%TYPE;
        v_att_attendance_percentage             IGS_EN_ATD_TYPE.research_percentage%TYPE;
        v_crv_eftd                              NUMBER;
        v_used_eftd_days                        NUMBER;
        v_minimum_eftd                          NUMBER;
        v_eftd_remaining                        NUMBER;
        v_remaining_days                        NUMBER;
        v_commencement_dt                       DATE;
        CURSOR c_ca IS
                SELECT  ca.acai_admission_appl_number,
                        ca.acai_nominated_course_cd,
                        ca.acai_sequence_number,
                        ca.sca_course_cd,
                        ca.attendance_percentage
                FROM    IGS_RE_CANDIDATURE                      ca
                WHERE   ca.person_id                    = p_person_id AND
                        ca.sequence_number              = p_ca_sequence_number;
        CURSOR c_sca IS
                SELECT  sca.course_cd,
                        sca.version_number,
                        sca.attendance_type,
                        sca.commencement_dt,
                        sca.course_attempt_status
                FROM    IGS_EN_STDNT_PS_ATT             sca
                WHERE   sca.person_id                   = p_person_id AND
                        sca.course_cd                   = v_ca_sca_course_cd;

      CURSOR c_acaiv IS
                SELECT  acai.course_cd,
                    acai.crv_version_number,
                    acai.attendance_type
             FROM
                    IGS_AD_PS_APPL_INST acai,
                        IGS_AD_APPL aa,
                    IGS_CA_INST ci,
                    IGS_AD_PS_APPL aca,
                    IGS_PS_VER crv
             WHERE  acai.person_id  = p_person_id AND
                    acai.admission_appl_number = v_ca_acai_adm_appl_number AND
                    acai.nominated_course_cd =  v_ca_acai_nominated_course_cd AND
                    acai.sequence_number = v_ca_acai_sequence_number AND
                    aa.person_id = acai.person_id AND
                      aa.admission_appl_number = acai.admission_appl_number AND
                      ci.cal_type (+) = acai.deferred_adm_cal_type AND
                      ci.sequence_number (+) = acai.deferred_adm_ci_sequence_num AND
                      aca.person_id = acai.person_id AND
                      aca.admission_appl_number = acai.admission_appl_number AND
                      aca.nominated_course_cd = acai.nominated_course_cd AND
                      crv.course_cd = acai.course_cd AND
                      crv.version_number = acai.crv_version_number;


        CURSOR c_crv IS
                SELECT  crv.min_sbmsn_percentage
                FROM    IGS_PS_VER                      crv
                WHERE   crv.course_cd                   = NVL(
                                                                v_sca_course_cd,
                                                                v_acai_course_cd) AND
                        crv.version_number              = NVL(
                                                                v_sca_version_number,
                                                                v_acai_version_number);
        CURSOR c_att IS
                SELECT  att.research_percentage
                FROM    IGS_EN_ATD_TYPE                 att
                WHERE   att.attendance_type             = NVL(
                                                                v_sca_attendance_type,
                                                                v_acai_attendance_type);

        l_dummy_bool   BOOLEAN;
        l_message_name fnd_new_messages.message_name%TYPE;

  BEGIN
        v_ca_acai_adm_appl_number := NULL;
        v_ca_acai_nominated_course_cd := NULL;
        v_ca_acai_sequence_number := NULL;
        v_ca_sca_course_cd := NULL;
        v_ca_attendance_percentage := NULL;
        IF p_ca_sequence_number IS NOT NULL THEN
                -- Select details from IGS_RE_CANDIDATURE
                OPEN c_ca;
                FETCH c_ca INTO v_ca_acai_adm_appl_number,
                                v_ca_acai_nominated_course_cd,
                                v_ca_acai_sequence_number,
                                v_ca_sca_course_cd,
                                v_ca_attendance_percentage;
                IF c_ca%NOTFOUND THEN
                        CLOSE c_ca;
                        RETURN NULL;
                END IF;
                CLOSE c_ca;
        ELSE
                IF p_sca_course_cd IS NULL AND
                                (p_acai_admission_appl_number IS NULL OR
                                p_acai_nominated_course_cd IS NULL OR
                                p_acai_sequence_number IS NULL) THEN
                        RETURN NULL;
                END IF;
                v_ca_acai_adm_appl_number := p_acai_admission_appl_number;
                v_ca_acai_nominated_course_cd := p_acai_nominated_course_cd;
                v_ca_acai_sequence_number := p_acai_sequence_number;
                v_ca_sca_course_cd := p_sca_course_cd;
        END IF;
        -- Either select details from the admission application or the student
        -- IGS_PS_COURSE attempt depending on the IGS_RE_CANDIDATURE fields which are set.
        IF v_ca_sca_course_cd IS NOT NULL THEN
                OPEN c_sca;
                FETCH c_sca INTO v_sca_course_cd,
                                v_sca_version_number,
                                v_sca_attendance_type,
                                v_sca_commencement_dt,
                                v_sca_course_attempt_status;
                IF c_sca%NOTFOUND THEN
                        CLOSE c_sca;
                        RETURN NULL;
                END IF;
                CLOSE c_sca;
        ELSE
                v_sca_course_cd := NULL;
                v_sca_version_number := NULL;
                v_sca_attendance_type := NULL;
                v_sca_course_attempt_status := NULL;
        END IF;
        -- If the admission details have been passed then use these.
        IF v_ca_acai_adm_appl_number IS NOT NULL THEN

                OPEN c_acaiv;
                FETCH c_acaiv INTO v_acai_course_cd,
                                        v_acai_version_number,
                                        v_acai_attendance_type;
                IF c_acaiv%NOTFOUND THEN
                        CLOSE c_acaiv;
                        RETURN NULL;
                END IF;
                CLOSE c_acaiv;
        ELSE
                v_acai_course_cd := NULL;
                v_acai_version_number := NULL;
                v_acai_attendance_type := NULL;
        END IF;
        -- Select details from the IGS_PS_COURSE version table
        OPEN c_crv;
        FETCH c_crv INTO v_crv_min_sbmsn_percentage;
        CLOSE c_crv;

        -- Call routine to get the program length.
        --v_crv_eftd will have a valid value if the EFTD calculated properly in the
        --below function otherwise it will have a value zero
        --passing p_acai_nominated_course_cd since sca_course_cd will be null when called
        -- from admissions before prenerolment is triggered.
        v_crv_eftd := igs_ps_gen_002.crsp_get_crv_eftd( p_person_id,
                                                        nvl(p_sca_course_cd,p_acai_nominated_course_cd));

        IF v_crv_eftd <= 0 THEN
                -- Cannot calculate date if the IGS_PS_COURSE version has no EFTD
                RETURN NULL;
        END IF;
        IF v_crv_eftd is NULL then
                v_crv_eftd := 0;
        END IF;
        OPEN c_att;
        FETCH c_att INTO v_att_attendance_percentage;
        CLOSE c_att;
        -- Determine attendance percentage
        IF NVL(p_attendance_percentage, v_ca_attendance_percentage) IS NULL THEN
                v_attendance_percentage := v_att_attendance_percentage;
        ELSE
                v_attendance_percentage := NVL(
                                                p_attendance_percentage,
                                                v_ca_attendance_percentage);
        END IF;

        --added this condition since the research percentage can be set to 0
        -- this will raise an unhandled exception since it will result in
        -- a divide by 0
        IF (v_attendance_percentage = 0 ) OR (v_att_attendance_percentage = 0) THEN
        RETURN NULL;
        END IF;

        IF v_ca_sca_course_cd IS NOT NULL THEN
                -- Call routine to determine the effective full time days already used
                v_used_eftd_days := resp_clc_used_eftd(
                                                        p_person_id,
                                                        v_ca_sca_course_cd,
                                                        'Y',
                                                        p_ca_sequence_number,
                                                        v_attendance_percentage);
        ELSE
                -- Only enrolled students could have used days
                v_used_eftd_days := 0;
        END IF;
        v_minimum_eftd := v_crv_eftd * (v_crv_min_sbmsn_percentage / 100);
        IF v_used_eftd_days > v_minimum_eftd THEN
                -- Student has already consumed more days than the IGS_PS_COURSE permitted
                -- * return the current date as the minimum submission date
                RETURN TRUNC(SYSDATE);
        END IF;
        v_eftd_remaining := v_minimum_eftd - v_used_eftd_days;
        -- Multiply the number of remaining EFTD by the students current attendance
        -- to determine the maximum submission date
        IF v_attendance_percentage <> 0 THEN
                v_remaining_days := v_eftd_remaining / (v_attendance_percentage / 100);
        ELSE
                v_remaining_days := v_eftd_remaining / (v_att_attendance_percentage / 100);
        END IF;
        -- Determine if the students commencement date is a future date - if so,
        -- the remaining days are added to their prospective commencement date
        -- rather than the current date
        IF p_commencement_dt IS NULL THEN
                IF v_ca_acai_adm_appl_number IS NULL OR
                        NVL(v_sca_course_attempt_status, cst_unconfirm) <> cst_unconfirm THEN
                        v_commencement_dt := NVL(v_sca_commencement_dt, TRUNC(SYSDATE));
                ELSE
                        v_commencement_dt := resp_get_ca_comm(
                                                p_person_id,
                                                v_ca_sca_course_cd,
                                                v_ca_acai_adm_appl_number,
                                                v_ca_acai_nominated_course_cd,
                                                v_ca_acai_sequence_number);
                END IF;
        ELSE
                v_commencement_dt := p_commencement_dt;
        END IF;
        IF v_commencement_dt >= TRUNC(SYSDATE) THEN
                RETURN (v_commencement_dt + v_remaining_days);
        ELSE
                RETURN (TRUNC(SYSDATE) + NVL(v_remaining_days,0));
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_ca%ISOPEN THEN
                        CLOSE c_ca;
                END IF;
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;

                IF c_acaiv%ISOPEN THEN
                        CLOSE c_acaiv;
                END IF;

                IF c_crv%ISOPEN THEN
                        CLOSE c_crv;
                END IF;
                IF c_att%ISOPEN THEN
                        CLOSE c_att;
                END IF;
                RAISE;
  END;
END resp_clc_min_sbmsn;


FUNCTION RESP_CLC_SUA_EFTSU(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_truncate_ind IN VARCHAR2,
  p_uoo_id igs_en_su_attempt.uoo_id%TYPE )
RETURN NUMBER AS
/*
| Who         When            What
| knaraset  09-May-03   modified function to add parameter uoo_id which is used in cursor c_sua, as part of MUS build bug 2829262
|
|
*/
        gv_other_detail                 VARCHAR2(255);
BEGIN   -- resp_clc_sua_eftsu
        -- Calculate the EFTSU figure for a research load IGS_PS_UNIT attempt. This routine
        -- will,
        -- . Determine the base EFTSU figure for the SUA as either the override value
        --   or the value from the research EFTD.
        -- . Calculates the coursework load within the same teaching period and
        --   adjusts the research IGS_PS_UNIT accordingly.
        -- . Truncates the EFTSU (if the parameter requires it).
        -- Assumptions (highlighted by the calendar quality check):
        -- ? The EFTSU within research teaching periods only contributes to a single
        --   load calendar (ie. is never split across multiple load calendars).
        -- ? A student is only ever enrolled in a single research IGS_PS_UNIT within a load
        --   calendar (ie. multiple units are not taken into consideration when
        --   comparing the research load with the coursework load).
DECLARE
        v_census_dt                     IGS_CA_DA_INST.absolute_val%TYPE;
        v_ca_person_id                  IGS_RE_CANDIDATURE.person_id%TYPE;
        v_ca_sequence_number            IGS_RE_CANDIDATURE.sequence_number%TYPE;
        v_sua_override_eftsu            IGS_EN_SU_ATTEMPT.override_eftsu%TYPE;
        v_sua_cal_type                  IGS_EN_SU_ATTEMPT.cal_type%TYPE;
        v_sua_ci_sequence_number        IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE;
        v_sua_uoo_id                    IGS_EN_SU_ATTEMPT.uoo_id%TYPE;
        v_sua_version_number            IGS_EN_SU_ATTEMPT.version_number%TYPE;
        v_acad_cal_type                 IGS_CA_INST.cal_type%TYPE;
        v_acad_ci_sequence_number       IGS_CA_INST.sequence_number%TYPE;
        v_acad_ci_start_dt              IGS_CA_INST.start_dt%TYPE;
        v_acad_ci_end_dt                IGS_CA_INST.end_dt%TYPE;
        v_message_name                  VARCHAR2(30);
        v_credit_points                 NUMBER;
        v_load_eftsu                    NUMBER;
        v_sua_eftd                      NUMBER;
        v_cal_type_eftd                 NUMBER;
        v_sua_eftsu                     NUMBER;
        v_coursework_eftsu              NUMBER;
        v_dummy_string                  VARCHAR2(10);
        v_final_eftsu                   NUMBER;
        v_census_att_perc                       NUMBER;
        CURSOR c_ca IS
                SELECT  ca.person_id,
                        ca.sequence_number
                FROM    IGS_RE_CANDIDATURE ca
                WHERE   ca.person_id                    = p_person_id AND
                        NVL(ca.sca_course_cd, 'NULL')   = NVL(p_course_cd, 'NULL');
        CURSOR c_sua(cp_person_id igs_en_su_attempt.person_id%TYPE,
                 cp_course_cd  igs_en_su_attempt.course_cd%TYPE,
                 cp_uoo_id  igs_en_su_attempt.uoo_id%TYPE) IS
                SELECT  sua.override_eftsu,
                        sua.cal_type,
                        sua.ci_sequence_number,
                        sua.uoo_id,
                        sua.version_number
                FROM    IGS_EN_SU_ATTEMPT       sua,
                        IGS_EN_STDNT_PS_ATT     sca,
                        IGS_PS_UNIT_VER                 uv
                WHERE   sua.person_id           = cp_person_id AND
                        sua.course_cd           = cp_course_cd AND
                        sua.uoo_id              = cp_uoo_id AND
                        sca.person_id           = sua.person_id AND
                        sca.course_cd           = sua.course_cd AND
                        uv.unit_cd              = sua.unit_cd AND
                        uv.version_number       = sua.version_number AND
                        uv.research_unit_ind    = 'Y';
        CURSOR c_sgcc (
                cp_cal_type             IGS_EN_SU_ATTEMPT.cal_type%TYPE,
                cp_ci_sequence_number   IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE)
        IS
                SELECT  NVL(
                                dai.absolute_val,
                                IGS_CA_GEN_001.calp_get_alias_val(
                                                dai.dt_alias,
                                                dai.sequence_number,
                                                dai.cal_type,
                                                dai.ci_sequence_number)) v_census_dt
                FROM    IGS_GE_S_GEN_CAL_CON sgcc,
                        IGS_CA_DA_INST dai
                WHERE   sgcc.s_control_num      = 1 AND
                        dai.cal_type            = cp_cal_type AND
                        dai.ci_sequence_number  = cp_ci_sequence_number AND
                        dai.dt_alias            = sgcc.census_dt_alias
                ORDER BY 1;
BEGIN
        -- 1. Select detail from research IGS_RE_CANDIDATURE
        OPEN c_ca;
        FETCH c_ca INTO
                        v_ca_person_id,
                        v_ca_sequence_number;
        IF c_ca%NOTFOUND THEN
                -- No research IGS_PS_UNIT load for non-research students.
                CLOSE c_ca;
                RETURN NULL;
        END IF;
        CLOSE c_ca;
        -- 2. Select detail from IGS_PS_UNIT attempt and IGS_PS_UNIT version tables
        OPEN c_sua(p_person_id,p_course_cd,p_uoo_id);
        FETCH c_sua INTO
                        v_sua_override_eftsu,
                        v_sua_cal_type,
                        v_sua_ci_sequence_number,
                        v_sua_uoo_id,
                        v_sua_version_number;
        IF c_sua%NOTFOUND THEN
                -- Only existing IGS_PS_UNIT attempts in research 'Load' units can have EFTSU
                -- calculated through this method ; return zero.
                CLOSE c_sua;
                RETURN 0;
        END IF;
        CLOSE c_sua;
        -- 3. Calculate the EFTSU figure for the load calendar instance
        v_dummy_string := IGS_EN_GEN_002.enrp_get_acad_alt_cd (
                                                v_sua_cal_type,
                                                v_sua_ci_sequence_number,
                                                v_acad_cal_type,
                                                v_acad_ci_sequence_number,
                                                v_acad_ci_start_dt,
                                                v_acad_ci_end_dt,
                                                v_message_name);
        v_load_eftsu := resp_clc_load_eftsu (
                                                v_acad_cal_type,
                                                v_acad_ci_sequence_number,
                                                p_load_cal_type,
                                                p_load_ci_sequence_number);
        IF v_load_eftsu = 0 THEN
                -- No load EFTSU will lead to 0 SUA EFTSU, so exit at this point
                -- to enable standard EFTSU calculation ***JES
                RETURN NULL;
        END IF;
        -- 4. Retrieve the census date from the teaching period.
        -- Because I am ordering by 1 desc, if there are multiple records the
        -- earliest census date will be selected automatically.
        OPEN c_sgcc (
                v_sua_cal_type,
                v_sua_ci_sequence_number);
        FETCH c_sgcc INTO v_census_dt;
        IF c_sgcc%NOTFOUND THEN
                -- No census date - invalid calendar set-up - return zero
                CLOSE c_sgcc;
                RETURN 0;
        END IF;
        CLOSE c_sgcc;
        IF v_sua_override_eftsu IS NULL THEN
                -- 5. Call routine to determine the EFTD figure for the teaching period
                --    within the nominated load calendar instance.
                v_sua_eftd := IGS_RE_GEN_002.resp_get_sua_eftd (
                                        p_person_id,
                                        p_course_cd,
                                        p_unit_cd,
                                        v_sua_version_number,
                                        p_cal_type,
                                        p_ci_sequence_number,
                                        v_census_dt,
                                        p_load_cal_type,
                                        p_load_ci_sequence_number,
                                        v_cal_type_eftd);
                IF v_cal_type_eftd = 0 THEN
                        RETURN NULL;
                END IF;
                IF v_sua_eftd = 0 THEN
                        RETURN 0;
                END IF;
                -- 6. Calculate the EFTSU figure for the IGS_PS_UNIT attempt; this is as a
                --    proportion of the SUA EFTD against the teaching period EFTD multiplied
                --    by the load calendar EFTSU.
                v_sua_eftsu := (v_sua_eftd / v_cal_type_eftd )
                                * v_load_eftsu;
        ELSE    -- override EFTSU has been specified.
                IF v_sua_override_eftsu = 0 THEN
                        -- Override of zero - no further processing.
                        RETURN 0;
                ELSE
                        v_sua_eftsu := v_sua_override_eftsu;
                END IF;
        END IF;
        IF v_sua_override_eftsu IS NULL THEN
                -- 7. Call routine to determine the total of the coursework EFTSU in the load
                --    calendar instance. First get the academic parent of the parameter load
                --    calendar.
                v_dummy_string := IGS_EN_GEN_002.enrp_get_acad_alt_cd(
                                                p_load_cal_type,
                                                p_load_ci_sequence_number,
                                                v_acad_cal_type,
                                                v_acad_ci_sequence_number,
                                                v_acad_ci_start_dt,
                                                v_acad_ci_end_dt,
                                                v_message_name);
                v_coursework_eftsu := IGS_EN_PRC_LOAD.enrp_clc_eftsu_total(
                                                p_person_id,
                                                p_course_cd,
                                                v_acad_cal_type,
                                                v_acad_ci_sequence_number,
                                                p_load_cal_type,
                                                p_load_ci_sequence_number,
                                                p_truncate_ind,
                                                'N',    -- Don't include research units
                                                NULL,
                                               NULL,
                                                v_credit_points);
                -- Calculate the final figure factoring in the coursework component.
                IF v_coursework_eftsu = 0 THEN
                        v_final_eftsu := v_sua_eftsu;
                ELSIF v_coursework_eftsu >= v_sua_eftsu THEN
                        RETURN 0;
                ELSE
                        v_final_eftsu := v_sua_eftsu - v_coursework_eftsu;
                END IF;
        END IF;
        -- 9. If truncation is required then call the appropriate routine.
        IF p_truncate_ind = 'Y' THEN
                RETURN resp_clc_eftsu_trunc (
                                v_ca_person_id,
                                v_ca_sequence_number,
                                p_unit_cd,
                                v_sua_version_number,
                                v_sua_uoo_id,
                                v_census_dt,
                                v_final_eftsu);
        ELSE
                RETURN v_final_eftsu;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
                IF c_ca %ISOPEN THEN
                        CLOSE c_ca;
                END IF;
                IF c_sua %ISOPEN THEN
                        CLOSE c_sua;
                END IF;
                IF c_sgcc %ISOPEN THEN
                        CLOSE c_sgcc;
                END IF;
        RAISE;
END;

END resp_clc_sua_eftsu;


FUNCTION RESP_CLC_USED_EFTD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_candidature_identified_ind IN VARCHAR2,
  p_ca_sequence_number IN NUMBER ,
  p_attendance_percentage IN NUMBER )
RETURN NUMBER AS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- resp_clc_used_eftd
        -- Calculates the effective full time days used
        -- by a student within a research IGS_PS_COURSE.
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- svanukur   01-APR-2004    Changed cursor c_cah  to consider all history records for calcultation
  --                           of used EFTD instead of the using only those history records that
  --                           start after the commencement date. bug  3544986
  -- rnirwani   13-Sep-2004    changed cursor c_sci to not consider logically deleted records and
  --				also to avoid un-approved intermission records. Bug# 3885804
  -------------------------------------------------------------------------------------------
DECLARE
        cst_unconfirm   CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'UNCONFIRM';
        v_ca_sequence_number            IGS_RE_CANDIDATURE.sequence_number%TYPE;
        v_ca_attendance_percentage      IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
        v_course_attempt_status         IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        v_commencement_dt               IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
        v_attendance_type               IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
        v_version_number                IGS_EN_STDNT_PS_ATT.version_number%TYPE;
        v_last_hist_end_dt              IGS_RE_CDT_ATT_HIST.hist_end_dt%TYPE;
        v_last_attendance_percentage    IGS_RE_CDT_ATT_HIST.attendance_percentage%TYPE;
        v_cah_hist_start_dt             IGS_RE_CDT_ATT_HIST.hist_start_dt%TYPE;
        v_cah_hist_end_dt               IGS_RE_CDT_ATT_HIST.hist_end_dt%TYPE;
        v_cah_attendance_percentage     IGS_RE_CDT_ATT_HIST.attendance_percentage%TYPE;
        v_research_percentage           IGS_EN_ATD_TYPE.research_percentage%TYPE;
        v_count_intrmsn_in_time_ind     IGS_PS_VER.count_intrmsn_in_time_ind%TYPE;
        v_start_dt                      IGS_RE_CDT_ATT_HIST.hist_start_dt%TYPE;
        v_last_end_dt                   IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
        v_cah_last_end_dt                       IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
        v_attendance_percentage         IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
        v_today_dt                      DATE;
        v_EFTD_total                    NUMBER;
        v_next_rec_flg                  BOOLEAN;
        v_sci_end_dt                    IGS_EN_STDNT_PS_INTM.end_dt%TYPE;
        v_end_dt                        IGS_EN_STDNT_PS_INTM.end_dt%TYPE;
        CURSOR c_ca IS
                SELECT  ca.sequence_number,
                        ca.attendance_percentage
                FROM    IGS_RE_CANDIDATURE      ca
                WHERE   ca.person_id            = p_person_id AND
                        (ca.sca_course_cd       IS NULL OR
                        ca.sca_course_cd        = p_course_cd);
        CURSOR c_sca IS
                SELECT  sca.course_attempt_status,
                        sca.commencement_dt,
                        sca.attendance_type,
                        sca.version_number
                FROM    IGS_EN_STDNT_PS_ATT     sca
                WHERE   sca.person_id = p_person_id AND
                        sca.course_cd = p_course_cd;
        CURSOR c_cah (
                cp_sequence_number      IGS_RE_CANDIDATURE.sequence_number%TYPE
                ) IS
                SELECT  cah.hist_start_dt,
                        cah.hist_end_dt,
                        cah.attendance_percentage
                FROM    IGS_RE_CDT_ATT_HIST     cah
                WHERE   cah.person_id           = p_person_id AND
                        cah.ca_sequence_number  = cp_sequence_number
                        ORDER BY cah.hist_start_dt ASC;


        CURSOR c_att (
                cp_attendance_type      IGS_EN_STDNT_PS_ATT.attendance_type%TYPE) IS
                SELECT  att.research_percentage
                FROM    IGS_EN_ATD_TYPE att
                WHERE   att.attendance_type     = cp_attendance_type AND
                        att.closed_ind          = 'N';
        CURSOR c_crv (
                cp_version_number       IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
                SELECT  crv.count_intrmsn_in_time_ind
                FROM    IGS_PS_VER      crv
                WHERE   crv.course_cd           = p_course_cd AND
                        crv.version_number      = cp_version_number;
        CURSOR c_sci IS
                SELECT  sci.start_dt,
                        sci.end_dt
                FROM    IGS_EN_STDNT_PS_INTM    sci,
                        IGS_EN_INTM_TYPES eit
                WHERE   sci.person_id = p_person_id AND
			sci.course_cd = p_course_cd AND
			sci.approved  = eit.appr_reqd_ind AND
                        eit.intermission_type = sci.intermission_type AND
                        sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
                ORDER BY sci.start_dt;
        CURSOR c_cah2 (
                cp_sequence_number      IGS_RE_CANDIDATURE.sequence_number%TYPE,
                cp_sci_end_dt           IGS_EN_STDNT_PS_INTM.end_dt%TYPE,
                cp_sci_start_dt         IGS_EN_STDNT_PS_INTM.start_dt%TYPE) IS
                SELECT  cah.hist_start_dt,
                        cah.hist_end_dt,
                        cah.attendance_percentage
                FROM    IGS_RE_CDT_ATT_HIST     cah
                WHERE   cah.person_id           = p_person_id AND
                        cah.ca_sequence_number  = cp_sequence_number AND
                        cah.hist_start_dt       <= cp_sci_end_dt AND
                        cah.hist_end_dt         >= cp_sci_start_dt
                ORDER BY        cah.hist_start_dt ASC;
BEGIN
        -- 1. Determine whether IGS_PE_PERSON has a research
        --    IGS_RE_CANDIDATURE for the IGS_PS_COURSE attempt.
        IF (p_candidature_identified_ind = 'Y') THEN
                v_attendance_percentage := p_attendance_percentage;
                v_ca_sequence_number := p_ca_sequence_number;
        ELSE
                OPEN c_ca;
                FETCH c_ca INTO v_ca_sequence_number,
                                v_ca_attendance_percentage;
                IF (c_ca%NOTFOUND) THEN
                        -- Not a research student in the IGS_PS_COURSE - return zero
                        CLOSE c_ca;
                        RETURN 0;
                END IF;
                CLOSE c_ca;
                v_attendance_percentage := v_ca_attendance_percentage;
        END IF;
        -- 2. Select details from student IGS_PS_COURSE attempt record
        --    to be used further in routine.
        OPEN c_sca;
        FETCH c_sca INTO        v_course_attempt_status,
                                v_commencement_dt,
                                v_attendance_type,
                                v_version_number;
        CLOSE c_sca;
        IF (v_course_attempt_status = cst_unconfirm) THEN
                -- Unconfirmed IGS_PS_COURSE attempts can't have used any days
                RETURN 0;
        END IF;
        v_today_dt := TRUNC(SYSDATE);
        -- 3. Loop though IGS_RE_CANDIDATURE history totalling effective attendance periods
        v_EFTD_total := 0;

        FOR v_cah_rec IN c_cah( v_ca_sequence_number) LOOP
                v_start_dt := v_cah_rec.hist_start_dt;
                -- If the history starts after the commencement date then assume
                -- the first record applies from the commencement date onwards.
                IF (c_cah%ROWCOUNT = 1) THEN
                        IF (v_cah_rec.hist_start_dt > v_commencement_dt) THEN
                                v_start_dt := v_commencement_dt;
                        END IF;
                ELSE
                        IF ((v_cah_rec.hist_start_dt - v_last_hist_end_dt) > 1) THEN

                                v_EFTD_total := v_EFTD_total +
                                                ((v_cah_rec.hist_start_dt - v_last_hist_end_dt - 1) *
                                                (v_last_attendance_percentage / 100));
                        END IF;
                END IF;
                -- Add the EFTD figure for the effective period of time
                v_EFTD_total := v_EFTD_total +
                                ((v_cah_rec.hist_end_dt - v_start_dt + 1 ) *
                                (v_cah_rec.attendance_percentage / 100));
                v_last_hist_end_dt := v_cah_rec.hist_end_dt;
                v_last_attendance_percentage := v_cah_rec.attendance_percentage;
        END LOOP;
        OPEN c_cah(
                v_ca_sequence_number
                );
        FETCH c_cah INTO        v_cah_hist_start_dt,
                                v_cah_hist_end_dt,
                                v_cah_attendance_percentage;
        IF (c_cah%NOTFOUND) THEN
                v_last_end_dt := v_commencement_dt - 1 ;   -- Allow for inclusive commence dt
        ELSE
                v_last_end_dt := v_last_hist_end_dt;
        END IF;
        CLOSE c_cah;
        IF (v_last_end_dt < v_today_dt - 1) THEN
                -- If the current (IGS_RE_CANDIDATURE) attendance percentage is set then use it,
                -- otherwise load the default from the attendance type
                IF (v_attendance_percentage IS NULL) THEN
                        OPEN c_att(v_attendance_type);
                        FETCH c_att INTO v_research_percentage;
                        CLOSE c_att;
                        v_attendance_percentage := v_research_percentage;
                END IF;
                v_EFTD_total := v_EFTD_total +
                                ((v_today_dt - v_last_end_dt - 1) *
                                (v_attendance_percentage / 100));
        END IF;
        -- Retain last end date for intermission processing
        v_cah_last_end_dt := v_last_end_dt;
        -- 4. If intermission is not counted in time, Subtract any
        --    applicable periods of intermission from the total.
        OPEN c_crv(v_version_number);
        FETCH c_crv INTO v_count_intrmsn_in_time_ind;
        CLOSE c_crv;
        IF (v_count_intrmsn_in_time_ind = 'N') THEN
                FOR v_sci_rec IN c_sci LOOP
                        v_next_rec_flg := FALSE;
                        -- If period of intermission doesn't overlap then exclude.
                        --i.e if intermission is in future then exclude
                        IF v_sci_rec.start_dt >= v_today_dt THEN
                                -- Set flag to loop to next record
                                v_next_rec_flg := TRUE;
                        END IF;
                        IF (v_next_rec_flg = FALSE) THEN


                                -- added the end day to  include intermission end date.
				v_sci_end_dt := (v_sci_rec.end_dt );
                                -- Loop though periods of attendance history
                                -- and remove appropriate EFTD figures.
                                v_last_hist_end_dt := NULL;

                                --EFTD calculation has been changed as part of the bug 3453123
                                --All history records are to be taken into account even if they are
                                --prior to the commencement date of the student.

                                FOR v_cah2_rec IN c_cah2(
                                                        v_ca_sequence_number,
                                                        v_sci_end_dt,
                                                         v_sci_rec.start_dt) LOOP
                                        -- If first history doesn't go back as far as the intermission start
                                        -- then assume it applies during that period (as no other history exists)
                                        v_start_dt := v_cah2_rec.hist_start_dt;
                                        IF (c_cah2%ROWCOUNT = 1) THEN
                                                IF (v_cah2_rec.hist_start_dt <v_sci_rec.start_dt) THEN
                                                        v_start_dt :=  v_sci_rec.start_dt;
                                                END IF;
                                        ELSE
                                                IF ((v_cah2_rec.hist_start_dt - v_last_hist_end_dt) > 1) THEN
                                                        -- Use the same details as the previous
                                                        -- history to fill any gap in history
                                                        v_EFTD_total := v_EFTD_total +
                                                                        ((v_cah2_rec.hist_start_dt -
                                                                        v_last_hist_end_dt - 1) *
                                                                        (v_last_attendance_percentage / 100));
                                                END IF;
                                        END IF;
                                        v_end_dt := LEAST(
                                                        v_sci_end_dt,
                                                        v_cah2_rec.hist_end_dt);
                                        -- Remove EFTD figure from total
                                        v_EFTD_total := v_EFTD_total -
                                                        ((v_end_dt - v_start_dt + 1) *
                                                        (v_cah2_rec.attendance_percentage / 100));

                                        v_last_hist_end_dt := v_cah2_rec.hist_end_dt;
                                        v_last_attendance_percentage := v_cah2_rec.attendance_percentage;
                                END LOOP;
                                -- Determine intermission current attendance
                                IF v_sci_end_dt > v_cah_last_end_dt THEN
                                        IF v_last_hist_end_dt IS NULL THEN
                                                v_last_end_dt :=  v_sci_rec.start_dt - 1;
                                        ELSE
                                                v_last_end_dt := v_last_hist_end_dt;
                                        END IF;
                                        -- If the current (IGS_RE_CANDIDATURE) attendance percentage is set then
                                        -- use it, otherwise load the default from the attendance type
                                        IF (v_attendance_percentage IS NULL) THEN
                                                OPEN c_att(v_attendance_type);
                                                FETCH c_att INTO v_research_percentage;
                                                CLOSE c_att;
                                                v_attendance_percentage := v_research_percentage;
                                        END IF;
                                        v_sci_end_dt := LEAST(
                                                        v_today_dt - 1,
                                                        v_sci_end_dt);
                                        -- Subtract the last portion between the last history and the current date
                                        v_EFTD_total := v_EFTD_total -
                                                ((v_sci_end_dt - v_last_end_dt) *
                                                (v_attendance_percentage / 100));

                                END IF;
                        END IF;
                END LOOP;
        END IF;
        RETURN v_EFTD_total;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_ca%ISOPEN) THEN
                        CLOSE c_ca;
                END IF;
                IF (c_sca%ISOPEN) THEN
                        CLOSE c_sca;
                END IF;
                IF (c_cah%ISOPEN) THEN
                        CLOSE c_cah;
                END IF;
                IF (c_att%ISOPEN) THEN
                        CLOSE c_att;
                END IF;
                IF (c_crv%ISOPEN) THEN
                        CLOSE c_crv;
                END IF;
                IF (c_sci%ISOPEN) THEN
                        CLOSE c_sci;
                END IF;
                IF (c_cah2%ISOPEN) THEN
                        CLOSE c_cah2;
                END IF;
                RAISE;
END;
END resp_clc_used_eftd;


FUNCTION RESP_GET_CA_ATT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_ca_sequence_number IN NUMBER ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_percentage IN NUMBER )
RETURN NUMBER AS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- resp_get_ca_att
        -- Get the attendance percentage of a IGS_RE_CANDIDATURE as at a given date.
        -- This is determined by looking through attendance history for the persons
        -- IGS_RE_CANDIDATURE.
        -- IGS_GE_NOTE: A returned value of NULL indicates that the value could not be
        -- determined.
DECLARE
        v_ca_sequence_number            IGS_RE_CANDIDATURE.sequence_number%TYPE;
        v_attendance_percentage         IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
        v_attendance_type               IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
        CURSOR c_ca_sca IS
                SELECT  ca.sequence_number,
                        ca.attendance_percentage,
                        sca.attendance_type
                FROM    IGS_RE_CANDIDATURE              ca,
                        IGS_EN_STDNT_PS_ATT     sca
                WHERE   ca.person_id            = p_person_id AND
                        ca.sca_course_cd        = p_course_cd AND
                        sca.course_cd           = ca.sca_course_cd AND
                        sca.person_id           = ca.person_id;
        CURSOR c_cah (
                        cp_person_id            IGS_RE_CANDIDATURE.person_id%TYPE,
                        cp_ca_sequence_number   IGS_RE_CANDIDATURE.sequence_number%TYPE,
                        cp_effective_dt         DATE) IS
                SELECT  cah.attendance_type,
                        cah.attendance_percentage
                FROM    IGS_RE_CDT_ATT_HIST     cah
                WHERE   cah.person_id           = cp_person_id AND
                        cah.ca_sequence_number  = cp_ca_sequence_number AND
                        cah.hist_end_dt         >= cp_effective_dt
                ORDER BY cah.hist_start_dt ASC;
        v_cah_rec               c_cah%ROWTYPE;
        CURSOR c_att (
                        cp_attendance_type      IGS_EN_STDNT_PS_ATT.attendance_type%TYPE) IS
                SELECT  att.research_percentage
                FROM    IGS_EN_ATD_TYPE         att
                WHERE   att.attendance_type     = cp_attendance_type;
BEGIN
        -- If IGS_RE_CANDIDATURE details have not been passed then load the record
        IF p_ca_sequence_number IS NULL OR
                        p_attendance_type IS NULL THEN
                OPEN c_ca_sca;
                FETCH c_ca_sca INTO     v_ca_sequence_number,
                                        v_attendance_percentage,
                                        v_attendance_type;
                IF c_ca_sca%NOTFOUND THEN
                        CLOSE c_ca_sca;
                        RETURN NULL;
                END IF;
                CLOSE c_ca_sca;
        ELSE
                v_ca_sequence_number := p_ca_sequence_number;
                v_attendance_percentage := p_attendance_percentage;
                v_attendance_type := p_attendance_type;
        END IF;
        OPEN c_cah(
                p_person_id,
                v_ca_sequence_number,
                p_effective_dt);
        FETCH c_cah INTO v_cah_rec;
        IF c_cah%FOUND THEN
                CLOSE c_cah;
                v_attendance_type := v_cah_rec.attendance_type;
                v_attendance_percentage := v_cah_rec.attendance_percentage;
        ELSE
                CLOSE c_cah;
        END IF;
        IF v_attendance_percentage IS NULL THEN
                -- If no percentage then get the default for the attendance type.
                OPEN c_att(v_attendance_type);
                FETCH c_att INTO v_attendance_percentage;
                CLOSE c_att;
        END IF;
        RETURN v_attendance_percentage;
EXCEPTION
        WHEN OTHERS THEN
                IF c_ca_sca%ISOPEN THEN
                        CLOSE c_ca_sca;
                END IF;
                IF c_cah%ISOPEN THEN
                        CLOSE c_cah;
                END IF;
                IF c_att%ISOPEN THEN
                        CLOSE c_att;
                END IF;
                RAISE;
END;
END resp_get_ca_att;


FUNCTION resp_get_ca_comm(
  p_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN DATE AS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- resp_get_ca_comm
        -- Set to IGS_EN_STDNT_PS_ATT.commencement_dt if it exists.
        -- Set to derived commencement date if IGS_EN_STDNT_PS_ATT.commencement_dt
        -- doesn't exist.
DECLARE
        CURSOR  c_sca IS
                SELECT  sca.commencement_dt
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   sca.person_id = p_person_id AND
                        sca.course_cd = p_sca_course_cd;
        v_sca_rec       c_sca%ROWTYPE;
BEGIN
        IF p_sca_course_cd IS NOT NULL THEN
                OPEN c_sca;
                FETCH c_sca INTO v_sca_rec;
                IF (c_sca%NOTFOUND) THEN
                        CLOSE c_sca;
                        RETURN SYSDATE;
                END IF;
                CLOSE c_sca;
                IF v_sca_rec.commencement_dt IS NOT NULL THEN
                        RETURN v_sca_rec.commencement_dt;
                END IF;
        END IF;
        RETURN IGS_EN_GEN_002.enrp_get_acad_comm(
                                NULL,
                                NULL,
                                p_person_id,
                                p_sca_course_cd,
                                p_acai_admission_appl_number,
                                p_acai_nominated_course_cd,
                                p_acai_sequence_number,
                                'Y');
END;
END resp_get_ca_comm;

END IGS_RE_GEN_001 ;

/
