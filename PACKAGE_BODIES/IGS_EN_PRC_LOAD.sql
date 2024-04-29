--------------------------------------------------------
--  DDL for Package Body IGS_EN_PRC_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_PRC_LOAD" AS
/* $Header: IGSEN18B.pls 120.16 2006/02/24 00:45:42 ckasu ship $ */


/**************************************************************************************
 Who           When           What
 knaraset      04-Nov-2003    Added two functions enrp_get_inst_attendance enrp_get_inst_cp as part
                              of build EN212, bug 3198180
 sarakshi      27-Jun-2003    Enh#2930935, added parameter uoo_id to teh function ENRP_CLC_SUA_LOAD
                              also modified the call to include the uoo_id
 kkillams      09-MAY-2002    procedure enrp_clc_cp_upto_tp_start_dt to calculate
                              the total credit points with in a given load calendar
                              w.r.t. bug 2352142
 jbegum        21 Mar 02      As part of bug fix 2192616 added
                              pragma exception_init(NO_AUSL_RECORD_FOUND , -20010);
                              to the user defined exception NO_AUSL_RECORD_FOUND
                              in order to catch the exception in the form IGSPS047.
                              The function that got modified is ENRP_GET_LOAD_INCUR.
 Modified by:Prajeesh
 Modified Date:7-JAN-2002
 Purpose      : Modified as part of career impact on attendance type dld
                created 2 new functions one to calculate key programs
                and other to get institution level attendance type
                for both career centric and program centric model. Also
                Modified 2 functions to add 2 parameters key_course_cd and
                key_version_number
msrinivi      28 Oct 2002       Added 1 new function enrp_get_prg_att_type
                                and 1 new procedure get_latest_load_for_acad_cal
amuthu     15-NOV-2002          Modified as per the SS Worksheet Redesign TD
pradhakr   15-Jan-2003    Added one more parameter no_assessment_ind to the
                          procedure ENRP_CLC_SUA_EFTSU and ENRP_GET_LOAD_INCUR.
                          Changes wrt ENCR026. Bug# 2743459
myoganat      23-MAY-2003       Removed reference to profile
                                                        IGS_EN_INCL_AUDIT_CP in procedures
                                                        ENRP_GET_LOAD_INCUR and ENRP_CLC_SUA_EFTSU
                                                        as part of the ENCR032 Build - Bug #2855870
vkarthik                22-Jul-2004             ENRP_CLC_SUA_LOAD changed for Build EN308 Billable credit points #3782329
                                                        All calls to ENRP_CLC_SUA_LOAD modified to take up three dummy arguments
vijrajag       07-Jul-05      Added Function get_term_credits
sgurusam   07-Jul-2005    Modified enrp_get_load_incur
rvangala   13-Sep-2005    Modified enrp_get_inst_latt for EN 321 build 	#4606948
stutta     23-Feb-2006    Modified c_sua_cir in enrp_clc_eftsu_total for perf bug #5048405
ckasu      24-Feb-2006    Modified cur_stud_ua_acad curson in enrp_clc_cp_upto_tp_start_dt
                          for perf bug #5059308
********************************************************************************************/

  g_wlst_prfl CONSTANT VARCHAR2(240) := FND_PROFILE.VALUE('IGS_EN_VAL_WLST');

  -- To calculate the EFTSU total for a UNIT attempt across all load cals
  FUNCTION ENRP_CLC_SUA_EFTSUT(
  P_PERSON_ID               IN NUMBER ,
  P_COURSE_CD               IN VARCHAR2 ,
  P_CRV_VERSION_NUMBER      IN NUMBER ,
  P_UNIT_CD                 IN VARCHAR2 ,
  P_UNIT_VERSION_NUMBER     IN NUMBER ,
  P_TEACH_CAL_TYPE          IN VARCHAR2 ,
  P_TEACH_SEQUENCE_NUMBER   IN NUMBER ,
  p_uoo_id                  IN NUMBER ,
  p_override_enrolled_cp    IN NUMBER ,
  p_override_eftsu          IN NUMBER ,
  p_sca_cp_total            IN NUMBER ,
  p_original_eftsu          OUT NOCOPY NUMBER )
  RETURN NUMBER  AS
  -------------------------------------------------------------------------------------------
  -- enrp_clc_sua_eftsut
  -- Calculate the total EFTSU figure for a student UNIT attempt,
  --  disregarding any
  -- splits or truncation. This will return a 'nominal' figure for the
  -- purposes of
  -- displaying on forms.
  -- note: p_sca_cp_total - this is an optional parameter (ie. May be null) - is
  -- included
  -- as a parameter to avoid recalculating the credit points passed figure in the
  -- situation
  -- where the logic is calc'ing EFTSU for all of a students unit attempts. If it
  -- is not
  -- specified the routine will be called to derive it.
  -- p_override_eftsu - if specified, this is passed to the enrp_clc_sua_load and
  -- is used
  -- as the basis for the eftsu calculation. The figure is still split across
  -- load calendars
  -- and truncated according to the standard logic.
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified c_sua cursor due to change in pk of the student unit attempt
  --                            w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
  BEGIN
  DECLARE
    v_load_eftsu        NUMBER(6,3);
    v_eftsu_total       NUMBER(6,3);
    v_original_eftsu_total  NUMBER(6,3);
    v_credit_points     NUMBER(6,3);
    cst_academic        CONSTANT    VARCHAR2(10) := 'ACADEMIC';
    cst_active          CONSTANT    VARCHAR2(7) := 'ACTIVE';
    cst_load            CONSTANT    VARCHAR2(5) := 'LOAD';

    CURSOR  c_sua IS
        SELECT  sua.discontinued_dt,
                sua.administrative_unit_status,
                sua.unit_attempt_status,
                sua.no_assessment_ind
        FROM    IGS_EN_SU_ATTEMPT sua
        WHERE   sua.person_id   = p_person_id   AND
                sua.course_cd   = p_course_cd   AND
                sua.uoo_id      = p_uoo_id;
    v_sua_rec   c_sua%ROWTYPE;

    CURSOR  c_cir   (cp_discontinued_dt             IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE,
                     cp_administrative_unit_status  IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE,
                     cp_unit_attempt_status         IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE,
                     cp_no_assessment_ind           IGS_EN_SU_ATTEMPT.no_assessment_ind%TYPE) IS
        SELECT  lci.cal_type,
                lci.sequence_number
        FROM    IGS_CA_INST_REL acir,
                IGS_CA_INST         aci,
                IGS_CA_TYPE         acat,
                IGS_CA_STAT         acs,
                IGS_CA_INST_REL     lcir,
                IGS_CA_INST         lci,
                IGS_CA_TYPE         lcat,
                IGS_CA_STAT         lcs
        WHERE   acir.sub_cal_type       = p_teach_cal_type AND
                acir.sub_ci_sequence_number = p_teach_sequence_number AND
                aci.cal_type            = acir.sup_cal_type AND
                aci.sequence_number     = acir.sup_ci_sequence_number AND
                acat.cal_type           = aci.cal_type AND
                acat.s_cal_cat          = cst_academic AND
                acs.cal_status          = aci.cal_status AND
                acs.s_cal_status        = cst_active AND
                lcir.sup_cal_type       = aci.cal_type AND
                lcir.sup_ci_sequence_number = aci.sequence_number AND
                lci.cal_type            = lcir.sub_cal_type AND
                lci.sequence_number     = lcir.sub_ci_sequence_number AND
                lcat.cal_type           = lci.cal_type AND
                lcat.s_cal_cat          = cst_load AND
                lcs.cal_status          = lci.cal_status AND
                lcs.s_cal_status        = cst_active AND
                ENRP_GET_LOAD_INCUR(
                            p_teach_cal_type,
                            p_teach_sequence_number,
                            cp_discontinued_dt,
                            cp_administrative_unit_status,
                            cp_unit_attempt_status,
                            cp_no_assessment_ind,
                            lci.cal_type,
                            lci.sequence_number,
                            -- anilk, Audit special fee build
                            NULL, -- for p_uoo_id
                            'N'
                            ) = 'Y';
  BEGIN
    v_eftsu_total := 0.000;
    v_original_eftsu_total := 0.000;
    OPEN c_sua;
    FETCH c_sua INTO v_sua_rec;
    IF c_sua%NOTFOUND THEN
        CLOSE c_sua;
        RETURN 0.000;
    END IF;
    CLOSE c_sua;
    FOR v_cir_rec IN c_cir  (v_sua_rec.discontinued_dt,
                             v_sua_rec.administrative_unit_status,
                             v_sua_rec.unit_attempt_status,
                             v_sua_rec.no_assessment_ind) LOOP
        v_load_eftsu := enrp_clc_sua_eftsu(
                                p_person_id,
                                p_course_cd,
                                p_crv_version_number,
                                p_unit_cd,
                                p_unit_version_number,
                                p_teach_cal_type,
                                p_teach_sequence_number,
                                p_uoo_id,
                                v_cir_rec.cal_type,
                                v_cir_rec.sequence_number,
                                p_override_enrolled_cp,
                                p_override_eftsu,
                                'Y',
                                NULL,
                                NULL,
                                NULL,
                                v_credit_points,
                                -- anilk, Audit special fee build
                                'N');
        v_eftsu_total := v_eftsu_total + v_load_eftsu;

        IF p_override_eftsu IS NOT NULL THEN
            v_load_eftsu := enrp_clc_sua_eftsu(
                                    p_person_id,
                                    p_course_cd,
                                    p_crv_version_number,
                                    p_unit_cd,
                                    p_unit_version_number,
                                    p_teach_cal_type,
                                    p_teach_sequence_number,
                                    p_uoo_id,
                                    v_cir_rec.cal_type,
                                    v_cir_rec.sequence_number,
                                    p_override_enrolled_cp,
                                    NULL,
                                    'Y',
                                    NULL,
                                    NULL,
                                    NULL,
                                    v_credit_points,
                                    -- anilk, Audit special fee build
                                    'N');
            v_original_eftsu_total := v_original_eftsu_total + v_load_eftsu;
        END IF;
    END LOOP;
    p_original_eftsu := v_original_eftsu_total;
    RETURN v_eftsu_total;
  EXCEPTION
    WHEN OTHERS THEN
        IF (c_cir%ISOPEN) THEN
            CLOSE c_cir;
        END IF;
        IF (c_sua%ISOPEN) THEN
            CLOSE c_sua;
        END IF;
                RETURN v_eftsu_total;
        -- RAISE;

  END;
  END enrp_clc_sua_eftsut;
  --
  -- To calc the total EFTSU figure for a SCA within a load cal instance
  -- Modified by Prajeesh to add 2 parameters key_coursecd and keyversion number
  -- as part of the dld career impact attendance type ccr
  FUNCTION enrp_clc_eftsu_total(
  p_person_id             IN NUMBER ,
  p_course_cd             IN VARCHAR2 ,
  p_acad_cal_type         IN VARCHAR2 ,
  p_acad_sequence_number  IN NUMBER ,
  p_load_cal_type         IN VARCHAR2 ,
  p_load_sequence_number  IN NUMBER ,
  p_truncate_ind          IN VARCHAR2 ,
  p_include_research_ind  IN VARCHAR2 ,
  p_key_course_cd         IN igs_en_su_attempt.course_cd%TYPE,
  p_key_version_number    IN igs_en_su_attempt.version_number%TYPE,
  p_credit_points         OUT NOCOPY NUMBER )
  RETURN NUMBER  AS
  BEGIN
  DECLARE
    cst_enrolled    CONSTANT    VARCHAR2(10) := 'ENROLLED';
    cst_discontin   CONSTANT    VARCHAR2(10) := 'DISCONTIN';
    cst_completed   CONSTANT    VARCHAR2(10) := 'COMPLETED';
    cst_waitlisted  CONSTANT VARCHAR2(10)        := 'WAITLISTED';

    v_version_number        IGS_EN_STDNT_PS_ATT.version_number%TYPE;
    v_sca_total_cp          NUMBER;
    v_eftsu_total           NUMBER;
    v_cp_total              NUMBER;
    v_sua_cp                NUMBER;
    v_census_dt             IGS_CA_DA_INST.absolute_val%TYPE;
    v_sca_total_calculated  BOOLEAN;

    CURSOR c_sca IS
        SELECT  sca.version_number
        FROM    IGS_EN_STDNT_PS_ATT sca
        WHERE   sca.person_id = p_person_id AND
            sca.course_cd = p_course_cd;
    CURSOR c_load_to_teach IS
	SELECT teach_cal_type, teach_ci_sequence_number
	FROM igs_ca_load_to_teach_v
	WHERE load_cal_type = p_load_cal_type
	AND load_ci_sequence_number = p_load_sequence_number;

    CURSOR c_sua_cir(cp_cal_type igs_ca_inst.cal_type%TYPE, cp_seq_num igs_ca_inst.sequence_number%TYPE) IS
        SELECT  sua.unit_cd,
            sua.version_number,
            sua.cal_type,
            sua.ci_sequence_number,
            sua.override_enrolled_cp,
            sua.override_eftsu,
            sua.administrative_unit_status,
            sua.unit_attempt_status,
            sua.discontinued_dt,
            sua.uoo_id,
            sua.no_assessment_ind
        FROM    IGS_EN_SU_ATTEMPT       sua,
                IGS_CA_INST_REL cir,
                IGS_PS_UNIT_VER         uv
        WHERE   sua.person_id           = p_person_id AND
                sua.course_cd           = p_course_cd AND
                sua.unit_attempt_status     IN  (cst_enrolled,
                                                 cst_discontin,
                                                 cst_completed,
                                                 cst_waitlisted) AND
                uv.unit_cd          = sua.unit_cd AND
                uv.version_number       = sua.version_number AND
                (p_include_research_ind     = 'Y' OR
                uv.research_unit_ind        = 'N') AND
                cir.sup_cal_type        = p_acad_cal_type AND
                cir.sup_ci_sequence_number  = p_acad_sequence_number AND
                cir.sub_cal_type        = sua.cal_type AND
                cir.sub_ci_sequence_number  = sua.ci_sequence_number AND
                sua.cal_type = cp_cal_type AND
                sua.ci_sequence_number = cp_seq_num;


    CURSOR c_sgcc_dai (
            cp_cal_type     IGS_EN_SU_ATTEMPT.cal_type%TYPE,
            cp_ci_sequence_number   IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE) IS
        SELECT  NVL(    dai.absolute_val,
                IGS_CA_GEN_001.CALP_GET_ALIAS_VAL (
                            dai.dt_alias,
                            dai.sequence_number,
                            dai.cal_type,
                            dai.ci_sequence_number)) AS census_dt
        FROM    IGS_GE_S_GEN_CAL_CON            sgcc,
                IGS_CA_DA_INST      dai
        WHERE   sgcc.s_control_num      = 1 AND
                dai.cal_type            = cp_cal_type AND
                dai.ci_sequence_number      = cp_ci_sequence_number AND
                dai.dt_alias            = sgcc.census_dt_alias
        ORDER BY 1 ASC;         -- use earliest date value
  BEGIN
    -- Calculate the EFTSU total for a student course attempt within a
    -- nominated load calendar instance.
    -- Note: p_truncate_ind indicates whether the EFTSU figures should be
    --   truncated in accordance with the DEETYA reporting guidelines.
    -- Note: p_credit_points is used to return the total credit point
    --   value from which the EFTSU was calculated.
    -- Note: p_include_research_ind is used to eliminate research units
    --   from  the total, creating a total of 'coursework' units -
    --   a measure which is used within the research sub-system.
    ----------
    -- 1. Load student course attempt details.
    OPEN    c_sca;
    FETCH   c_sca   INTO    v_version_number;
    IF (c_sca%NOTFOUND) THEN
        CLOSE   c_sca;
        p_credit_points := 0;
        RETURN 0.000;
    END IF;
    CLOSE   c_sca;


    -- 3. Loop through all unit attempt that are child records of the academic
    -- calendar instance.
    v_eftsu_total := 0.000;
    v_cp_total := 0;

    FOR rec_cal IN c_load_to_teach LOOP
	OPEN c_sgcc_dai (
			    rec_cal.teach_cal_type,
			    rec_cal.teach_ci_sequence_number);
	FETCH c_sgcc_dai INTO v_census_dt;
	IF c_sgcc_dai%NOTFOUND THEN
	    CLOSE c_sgcc_dai;
	    v_census_dt := TRUNC(SYSDATE);
	ELSE
	    CLOSE c_sgcc_dai;
	END IF;
	v_sca_total_calculated := FALSE;



	    FOR v_sua_cir_rec IN c_sua_cir(rec_cal.teach_cal_type,rec_cal.teach_ci_sequence_number) LOOP
	    -- As part of the bug# 1956374 changed to the below call from IGS_EN_GEN_005.ENRP_GET_LOAD_INCUR
		IF ENRP_GET_LOAD_INCUR(
				v_sua_cir_rec.cal_type,
				v_sua_cir_rec.ci_sequence_number,
				v_sua_cir_rec.discontinued_dt,
				v_sua_cir_rec.administrative_unit_status ,
				v_sua_cir_rec.unit_attempt_status,
				v_sua_cir_rec.no_assessment_ind,
				p_load_cal_type,
				p_load_sequence_number,
				v_sua_cir_rec.uoo_id,
				-- anilk, Audit special fee build
				'N') = 'Y' THEN

			-- Call routine to calculate the total credit points passed in the students
			-- course attempt. This is used by a child routine.
			IF NOT v_sca_total_calculated  THEN
				v_sca_total_cp := Igs_En_Gen_001.ENRP_CLC_SCA_PASS_CP(
						p_person_id,
						p_course_cd,
						v_census_dt);
				v_sca_total_calculated := TRUE;
			END IF;
		    -- 3.1 Call the routine to calculate the EFTSU figure for the selected
		    -- student unit attempt within the nominated load calendar instance.
				-- Passed 2 parameters key_course_cd and key_version_number as
				-- part of the dld for career impact on attendance type ccr
		    v_eftsu_total := v_eftsu_total +
			    enrp_clc_sua_eftsu(
					p_person_id,
					p_course_cd,
					v_version_number, -- from c_sca
					v_sua_cir_rec.unit_cd,
					v_sua_cir_rec.version_number,
					v_sua_cir_rec.cal_type,
					v_sua_cir_rec.ci_sequence_number,
					v_sua_cir_rec.uoo_id,
					p_load_cal_type,
					p_load_sequence_number,
					v_sua_cir_rec.override_enrolled_cp,
					v_sua_cir_rec.override_eftsu,
					p_truncate_ind,
					v_sca_total_cp,
					p_key_course_cd ,
					p_key_version_number,
					v_sua_cp ,
					-- anilk, Audit special fee build
					'N');
		    v_cp_total := v_cp_total + v_sua_cp;
		END IF;
	    END LOOP;
     END LOOP;
    p_credit_points := v_cp_total;
    RETURN v_eftsu_total;
  EXCEPTION
    WHEN OTHERS THEN
        IF c_sca%ISOPEN THEN
            CLOSE c_sca;
        END IF;
        IF c_sua_cir%ISOPEN THEN
            CLOSE c_sua_cir;
        END IF;
        IF c_sgcc_dai%ISOPEN THEN
            CLOSE c_sgcc_dai;
        END IF;
        RAISE;
  END;
  END enrp_clc_eftsu_total;

  FUNCTION enrp_clc_sua_eftsu(
  p_person_id             IN NUMBER ,
  p_course_cd             IN VARCHAR2 ,
  p_crv_version_number    IN NUMBER ,
  p_unit_cd               IN VARCHAR2 ,
  p_unit_version_number   IN NUMBER ,
  p_teach_cal_type        IN VARCHAR2 ,
  p_teach_sequence_number IN NUMBER ,
  p_uoo_id                IN NUMBER ,
  p_load_cal_type         IN VARCHAR2 ,
  p_load_sequence_number  IN NUMBER ,
  p_override_enrolled_cp  IN NUMBER ,
  p_override_eftsu        IN NUMBER ,
  p_truncate_ind          IN VARCHAR2 ,
  p_sca_cp_total          IN NUMBER ,
  p_key_course_cd         IN igs_en_su_attempt.course_cd%TYPE,
  p_key_version_number    IN igs_en_su_attempt.version_number%TYPE,
  p_credit_points         OUT NOCOPY NUMBER ,
  -- anilk, Audit special fee build
  p_include_audit         IN VARCHAR2)
  -------------------------------------------------------------------------------------------
  -- enrp_clc_sua_eftsu
  -- This module calculates the EFTSU value of a
  -- student unit attempt within a load calendar
  -- instance (this routine also returns the credit
  -- point figure on which the EFTSU was based - this
  -- avoids having to call two routines to get the same
  -- values)
  -- Note : p_sca_cp_total is an optional parameter (may
  --    be NULL) - is included as a parameter to avoid
  --    recalculating the credit points passed figure in the
  --    situation where the logic is calculating EFTSU for
  --    all students IGS_PS_UNIT attempts.  If it is not specified,
  --    the routine will be called to derive it.
  -- Note : p_load_cal_type - this is a mandatory parameter
  --    to EFTSU (as apposed to CP's calculations where it
  --    was optional), due to the nature of the EFTSU truncation
  --    logic.
  -- Note : p_truncate_ind - this indicates whether the figure
  --    should be truncated according to the DEETYA guidelines.
  --Who         When            What
  --kkillams    28-04-2003      Modified c_uooid cursor due to change in pk of the student unit attempt
  --                            w.r.t. bug number 2829262
  --myoganat    23-MAY-2003     Removed reference to profile
  --                            IGS_EN_INCL_AUDIT_CP
  --                            as part of Bug #2855870
  -------------------------------------------------------------------------------------------
  RETURN NUMBER  AS
  BEGIN
  DECLARE
    v_research_unit_ind VARCHAR2(1);
    l_include_as_audit  VARCHAR2(1);
    v_annual_load       NUMBER;
    v_sua_cp            NUMBER;
    v_sua_eftsu         NUMBER;
    v_trunc_eftsu       NUMBER;
    v_return_eftsu      NUMBER;
    v_uoo_id            IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
    l_no_assessment_ind igs_en_su_attempt.no_assessment_ind%TYPE;
    --dummy variable to pick up audit, billing, enrolled credit points
    --due to signature change by EN308 Billing credit hours
    l_audit_cp          IGS_PS_USEC_CPS.billing_credit_points%TYPE;
    l_billing_cp        IGS_PS_USEC_CPS.billing_hrs%TYPE;
    l_enrolled_cp       IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;

    CURSOR  c_uooid IS
        SELECT  sua.uoo_id,
                NVL(sua.no_assessment_ind,'N')
        FROM    IGS_EN_SU_ATTEMPT sua
        WHERE   sua.person_id       = p_person_id AND
                sua.course_cd       = p_course_cd AND
                sua.uoo_id          = p_uoo_id;

    CURSOR c_uv IS
        SELECT  uv.research_unit_ind
        FROM    IGS_PS_UNIT_VER uv
        WHERE   uv.unit_cd          = p_unit_cd AND
                uv.version_number   = p_unit_version_number;

  BEGIN

    -- Get the no_assessement_ind value
    OPEN c_uooid;
    FETCH c_uooid INTO v_uoo_id, l_no_assessment_ind ;
    CLOSE c_uooid;

    -- Check whether the passed in Unit Attempt is a Audit Unit
    -- If so, return '0' for EFTSU and credit points else use the existing logic to get the EFTSU
    -- and credit points of the unit attempt.
    IF p_override_enrolled_cp = 0 OR p_override_eftsu = 0  OR
    (p_override_enrolled_cp IS NULL AND p_override_eftsu IS NULL) THEN

    IF l_no_assessment_ind = 'Y' THEN
      IF  p_include_audit = 'N' THEN
        p_credit_points := 0;
        RETURN 0;
      ELSE
        l_include_as_audit := 'Y';
      END IF;
    ELSE
      l_include_as_audit := 'N';
    END IF;
    ELSE
      l_include_as_audit := 'N';
    END IF;


    -- determine wheter the unit version is a 'research unit'.
    -- If so, an alternate path is used to calculate the EFTSU figure.
    OPEN c_uv;
    FETCH c_uv INTO v_research_unit_ind;
    IF c_uv%NOTFOUND THEN
        CLOSE c_uv;
        RETURN 0;
    END IF;
    CLOSE c_uv;

    IF v_research_unit_ind = 'Y' THEN
        v_trunc_eftsu := IGS_RE_GEN_001.RESP_CLC_SUA_EFTSU(
                    p_person_id,
                    p_course_cd,
                    p_unit_cd,
                    p_teach_cal_type,
                    p_teach_sequence_number,
                    p_load_cal_type,
                    p_load_sequence_number,
                    p_truncate_ind,
                    p_uoo_id);
        p_credit_points := 0;
    END IF;

    IF v_research_unit_ind = 'N' OR v_trunc_eftsu IS NULL THEN
        -- determine the annual load figure of the student course
        -- attempt for the particular unit attempt being studied
           --Modified by Prajeesh as part of career impact on attendance type dld
               -- First check if key_coursecd and version number exists then
               -- pass that as coursecd parameters for annual load procedure
               -- implies keyprogram is used to calculate the annual load that is
               -- it is career centric model as do asusual

          IF p_key_course_cd IS NOT NULL AND p_key_version_number IS NOT NULL THEN

               v_annual_load := enrp_get_ann_load(
                    p_person_id,
                    p_key_course_cd,
                    p_key_version_number,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    p_sca_cp_total);

          ELSE

            v_annual_load := enrp_get_ann_load(
                    p_person_id,
                    p_course_cd,
                    p_crv_version_number,
                    p_unit_cd,
                    p_unit_version_number,
                    p_teach_cal_type,
                    p_teach_sequence_number,
                    p_sca_cp_total);

          END IF;
        -- check the value of v_annual_load and
        -- return 0 if it has a value of 0
        IF (v_annual_load = 0) THEN
            p_credit_points := 0;
            RETURN 0;
        END IF;

        -- call routine to calcualte the credit point figure
        -- for the student unit attmpt
            v_sua_cp := enrp_clc_sua_load(
                                            p_unit_cd,
                                            p_unit_version_number,
                                            p_teach_cal_type,
                                            p_teach_sequence_number,
                                            p_load_cal_type,
                                            p_load_sequence_number,
                                            p_override_enrolled_cp,
                                            p_override_eftsu,
                                            v_return_eftsu,
                                            p_uoo_id,
                                            -- anilk, Audit special fee build
                                            l_include_as_audit,
                                            l_audit_cp,
                                            l_billing_cp,
                                            l_enrolled_cp
                                            );

        -- check the value of v_sua_cp and
        -- return 0 if it has a value of 0
        IF (v_sua_cp = 0.000) THEN
            p_credit_points := 0;
            RETURN 0;
        END IF;

        IF (p_override_eftsu IS NOT NULL AND v_return_eftsu IS NOT NULL) THEN
            v_sua_eftsu := v_return_eftsu;
        ELSE
            -- calculate the base EFTSU figure
            v_sua_eftsu := v_sua_cp / v_annual_load;
        END IF;

        IF (p_truncate_ind = 'Y') THEN
            IF p_uoo_id IS NOT NULL THEN
                v_uoo_id := p_uoo_id;
            END IF;
            -- call the routine to handle the rounding/truncation
            -- of the EFTSU figure
            v_trunc_eftsu := enrp_clc_eftsu_trunc(
                        p_unit_cd,
                        p_unit_version_number,
                        v_uoo_id,
                        v_sua_eftsu);
        ELSE
            v_trunc_eftsu := v_sua_eftsu;
        END IF;

        -- set the out NOCOPY paramter to the credit point figure used
        -- to calculate the EFTSU amount
        p_credit_points := v_sua_cp;
    END IF;
    -- return the EFTSU figure
    RETURN v_trunc_eftsu;



  EXCEPTION
    WHEN OTHERS THEN
        IF c_uv%ISOPEN THEN
            CLOSE c_uv;
        END IF;
        IF c_uooid%ISOPEN THEN
            CLOSE c_uooid;
        END IF;
        RAISE;
  END;
  END enrp_clc_sua_eftsu;
  --
  -- To calculate the WEFTSU for a student unit attempt
  FUNCTION ENRP_CLC_SUA_WEFTSU(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_discipline_group_cd IN VARCHAR2 ,
  p_org_unit_cd IN VARCHAR2 ,
  p_sua_eftsu IN NUMBER ,
  p_local_ins_deakin_ind IN VARCHAR2 )
  RETURN NUMBER  AS

  BEGIN
  DECLARE
    v_funding_index_1       IGS_PS_DSCP.funding_index_1%TYPE;
    v_funding_index_2       IGS_PS_DSCP.funding_index_2%TYPE;
    v_weftsu_factor         IGS_PS_UNIT_INT_LVL.weftsu_factor%TYPE;
    v_unit_level            IGS_PS_UNIT_VER.unit_level%TYPE;
    v_unit_int_course_level_cd  IGS_PS_UNIT_VER.unit_int_course_level_cd%TYPE;
    v_count             NUMBER;
    v_sua_weftsu            NUMBER;
    v_local_ins_deakin_ind      VARCHAR2(1);
    CURSOR c_di IS
        SELECT  di.funding_index_1,
            di.funding_index_2
        FROM    IGS_PS_DSCP di
        WHERE   di.discipline_group_cd = p_discipline_group_cd;
    CURSOR c_uv_uicl IS
        SELECT  uicl.weftsu_factor,
            uv.unit_level,
            uv.unit_int_course_level_cd
        FROM    IGS_PS_UNIT_VER     uv,
            IGS_PS_UNIT_INT_LVL uicl
        WHERE   uv.unit_cd          = p_unit_cd AND
            uv.version_number       = p_version_number AND
            uicl.unit_int_course_level_cd   = uv.unit_int_course_level_cd;
    CURSOR c_ins IS
        SELECT  COUNT(*)
        FROM    IGS_OR_INSTITUTION  ins
        WHERE   ins.govt_institution_cd = 3030 AND
            local_institution_ind   = 'Y';
  BEGIN
    -- Routine calculates the WEFTSU figure for a Student unit Attempt.
    -- This routine requires the IGS_PS_DSCP group code and org unit code as
    -- parameters,  so where units are split across multiples the calling
    -- routine must call this function multiple times and sum the results.
    -- Special Logic:
    -- Deakin University has two special scenarios which involve using the second
    -- funding index for particular matches on IGS_PS_DSCP group code, org unit,
    -- unit internal course level and unit level. These senarios have been coded,
    -- but surrounded by a check as to whether the local INSTITUTION (in which
    -- the system is running) is Deakin - all other institutions will revert to
    -- the standard check.
    IF (p_sua_eftsu = 0.000) THEN
        RETURN 0.000;
    END IF;
    -- Load the funding indexes from the IGS_PS_DSCP table.
    OPEN    c_di;
    FETCH   c_di    INTO    v_funding_index_1,
                v_funding_index_2;
    IF (c_di%NOTFOUND) THEN
        CLOSE   c_di;
        RETURN 0.000;
    END IF;
    CLOSE   c_di;
    -- Load the weftsu factor, unit level and IGS_PS_UNIT_INT_LVL from
    -- their respective tables.
    OPEN    c_uv_uicl;
    FETCH   c_uv_uicl   INTO    v_weftsu_factor,
                    v_unit_level,
                    v_unit_int_course_level_cd;
    IF (c_uv_uicl%NOTFOUND) THEN
        CLOSE   c_uv_uicl;
        RETURN 0.000;
    END IF;
    CLOSE   c_uv_uicl;
    -- Load the INSTITUTION code and the 'local' indicator from the IGS_OR_INSTITUTION
    -- table.
    IF (p_local_ins_deakin_ind IS NOT NULL) THEN
        v_local_ins_deakin_ind := p_local_ins_deakin_ind;
    ELSE
        OPEN    c_ins;
        FETCH   c_ins   INTO    v_count;
        CLOSE   c_ins;
        IF (v_count > 0) THEN
            -- records found
            -- Deakin is the local INSTITUTION
            v_local_ins_deakin_ind := 'Y';
        ELSE
            v_local_ins_deakin_ind := 'N';
        END IF;
    END IF;
    IF (v_local_ins_deakin_ind = 'Y') THEN -- if records found
        -- The institution is local and Deakin University,
        -- so apply the 'special case' scenarios.
        IF (p_discipline_group_cd = '201' AND
                p_org_unit_cd = '03' AND
                v_unit_int_course_level_cd <> '1') THEN
            v_sua_weftsu := p_sua_eftsu *
                    v_funding_index_2 *
                    v_weftsu_factor;
        ELSIF (p_discipline_group_cd = '503' AND
                p_org_unit_cd = '0504' AND
                v_unit_level IN ('3', '4', '8', '9')) THEN
            v_sua_weftsu := p_sua_eftsu *
                    v_funding_index_2 *
                    v_weftsu_factor;
        ELSE
            v_sua_weftsu := p_sua_eftsu *
                    v_funding_index_1 *
                    v_weftsu_factor;
        END IF;
    ELSE
        -- The institution is not Deakin University;
        -- apply the standard calculation.
        v_sua_weftsu := p_sua_eftsu *
                v_funding_index_1 *
                v_weftsu_factor;
    END IF;
    RETURN NVL(v_sua_weftsu,0.000);
  END;
  EXCEPTION
    WHEN OTHERS THEN
         IF SQLCODE <>-20001 THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_PRC_LOAD.enrp_clc_sua_weftsu');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception(NULL,NULL,fnd_message.get);
         ELSE
          RAISE;
       END IF;
  END enrp_clc_sua_weftsu;
  --
  -- To calculate the truncated EFTSU figure according to DEETYA IGS_RU_RULEs
  FUNCTION ENRP_CLC_EFTSU_TRUNC(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_uoo_id IN NUMBER ,
  p_eftsu IN NUMBER )
  RETURN NUMBER  AS

  BEGIN
  DECLARE
    v_eftsu_total           NUMBER;
    --modified cursor for perf bug :3712541
    CURSOR c_tr IS
       SELECT tr.percentage
       FROM IGS_PS_UNIT_OFR_OPT uoo, IGS_PS_TCH_RESP tr
       WHERE uoo.uoo_id = p_uoo_id
       AND NOT EXISTS ( SELECT unit_cd
                        FROM IGS_PS_TCH_RESP_OVRD
                        WHERE uoo_id =  uoo.uoo_id )
       AND tr.unit_cd = uoo.unit_cd
       AND tr.version_number = uoo.version_number
       UNION ALL
       SELECT tro.percentage
       FROM IGS_PS_TCH_RESP_OVRD tro
       WHERE tro.uoo_id = p_uoo_id;
    CURSOR c_ud IS
        SELECT  ud.percentage
        FROM    IGS_PS_UNIT_DSCP    ud
        WHERE   ud.unit_cd = p_unit_cd AND
            ud.version_number = p_version_number;
  BEGIN
    -- Routine to perform the necessary truncation on the DEETYA reported
    -- EFTSU - this is in accordance with the DEETYA guidelines, and  is required
    -- to be able to reconcile EFTSU figures calculated on a day to day basis
    -- with those reported in the DEETYA submissions.
    -- This routine will 'roll down the EFTSU to the lowest common denominator,
    -- being split across organisational units and IGS_PS_DSCP groups, truncate the
    -- value and then 'roll up' to the required level.
    -- Refer to Enrolments Analysis Document for example of this logic.
    -- Note: This routine is assuming that load has already been split across load
    -- calendars (ie: Semesters) and that there can be not further splitting of
    -- the values below OU/IGS_PS_DSCP.
    v_eftsu_total := 0.000;
    FOR v_tr_rec    IN  c_tr    LOOP
        FOR v_ud_rec    IN  c_ud    LOOP
            v_eftsu_total := v_eftsu_total +
                    TRUNC(
                        p_eftsu *
                        (v_tr_rec.percentage / 100) *
                        (v_ud_rec.percentage / 100), 3);
        END LOOP;
    END LOOP;
    RETURN v_eftsu_total;
  END;
  END enrp_clc_eftsu_trunc;
  --
  -- To get the annual load for a unit attempt within a course
  FUNCTION ENRP_GET_ANN_LOAD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sca_cp_total IN NUMBER )
  RETURN NUMBER  AS

  BEGIN
  DECLARE
    v_count         NUMBER;
    v_std_annual_load   IGS_PS_VER.std_annual_load%TYPE;
    v_annual_load_val   IGS_PS_ANL_LOAD.annual_load_val%TYPE;
    v_sca_cp_total      NUMBER;
    v_cumulative_load   NUMBER;
    v_census_dt     IGS_CA_DA_INST.absolute_val%TYPE;
    CURSOR c_cal IS
        SELECT  COUNT(*)
        FROM    IGS_PS_ANL_LOAD     cal
        WHERE   cal.course_cd           = p_course_cd AND
            cal.version_number      = p_version_number AND
            cal.effective_start_dt      <= SYSDATE AND
            (cal.effective_end_dt       IS NULL OR
            cal.effective_end_dt        >= SYSDATE);
    CURSOR c_crv IS
        SELECT  NVL(crv.std_annual_load, 0)
        FROM    IGS_PS_VER          crv
        WHERE   crv.course_cd           = p_course_cd AND
            crv.version_number      = p_version_number;
    CURSOR c_calul_cal IS
        SELECT  cal.annual_load_val
        FROM    IGS_PS_ANL_LOAD_U_LN    calul,
            IGS_PS_ANL_LOAD     cal
        WHERE   calul.course_cd         = p_course_cd AND
            calul.crv_version_number    = p_version_number AND
            calul.effective_start_dt    <= SYSDATE AND
            calul.unit_cd           = p_unit_cd AND
            calul.uv_version_number     = p_unit_version_number AND
            calul.course_cd         = cal.course_cd AND
            calul.crv_version_number    = cal.version_number AND
            calul.yr_num            = cal.yr_num AND
            calul.effective_start_dt    = cal.effective_start_dt AND
            (cal.effective_end_dt       IS NULL OR
            cal.effective_end_dt        >= SYSDATE)
        ORDER BY calul.effective_start_dt DESC,
            cal.yr_num;
    CURSOR c_cal2 IS
        SELECT  cal.annual_load_val
        FROM    IGS_PS_ANL_LOAD     cal
        WHERE   cal.course_cd           = p_course_cd AND
            cal.version_number      = p_version_number AND
            cal.effective_start_dt      <= SYSDATE AND
            (cal.effective_end_dt       IS NULL OR
            cal.effective_end_dt        >= SYSDATE)
        ORDER BY cal.yr_num;
    CURSOR c_sgcc_dai IS
        SELECT  NVL (   absolute_val,
                IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
                            dai.dt_alias,
                            dai.sequence_number,
                            dai.cal_type,
                            dai.ci_sequence_number)) AS census_dt
        FROM    IGS_GE_S_GEN_CAL_CON            sgcc,
            IGS_CA_DA_INST      dai
        WHERE   sgcc.s_control_num      = 1 AND
            dai.dt_alias            = sgcc.census_dt_alias AND
            dai.cal_type            = p_cal_type AND
            dai.ci_sequence_number      = p_ci_sequence_number
        ORDER BY 1 ASC;         --  use earliest value
  BEGIN
    -- Get the annual load figure of a student unit attempt within a course
    -- version.
    -- This figure may come from one of three places:
    --  Method 1. If the IGS_PS_COURSE has a standard annual load across all years then
    -- the IGS_PS_VER.std_annual_load figure is used. This is defined by the
    -- non-existence of a current IGS_PS_ANL_LOAD record for the course version.
    --  Method 2. By interrogating the IGS_PS_ANL_LOAD structure to determine
    -- which annual load value is applicable, given the students current passed
    -- credit  point total. This is used when no annual load unit link is
    -- defined (refer method 3).
    --  Method 3. By using the IGS_PS_ANL_LOAD_U_LN structure, which
    -- explicitely links the unit version to a IGS_PS_ANL_LOAD record, dictating
    --  the annual load figure.
    -- 1. Check whether course version has a 'standard' annual load across all
    --      years -  this is done by searching for the existence of a current
    --      IGS_PS_ANL_LOAD record -
    -- no records means a 'standard' structure.
    OPEN    c_cal;
    FETCH   c_cal   INTO    v_count;
    CLOSE   c_cal;
    IF (v_count = 0) THEN
        -- 1.1 Retrieve the annual load from the course version table and return it.
        OPEN    c_crv;
        FETCH   c_crv   INTO    v_std_annual_load;
        IF (c_crv%NOTFOUND) THEN
            CLOSE   c_crv;
            RETURN 0;
        END IF;
        CLOSE   c_crv;
        RETURN v_std_annual_load;
    END IF;
    -- 2. Check whether the unit version is explicitely linked to the course annual
    --      load structure - if so, use the annual load value in the structure.
    OPEN    c_calul_cal;
    FETCH   c_calul_cal INTO    v_annual_load_val;
    IF (c_calul_cal%FOUND) THEN
        CLOSE   c_calul_cal;
        RETURN v_annual_load_val;
    END IF;
    CLOSE   c_calul_cal;
    -- 3. IF the parameter was not set then call routine to determine the student's
    -- completed credit points.
    IF (p_sca_cp_total IS NOT NULL) AND
            (p_sca_cp_total <> 0) THEN
        v_sca_cp_total := p_sca_cp_total;
    ELSE
        IF p_cal_type IS NOT NULL AND
                p_ci_sequence_number IS NOT NULL THEN
            OPEN c_sgcc_dai;
            FETCH c_sgcc_dai INTO v_census_dt;
            IF c_sgcc_dai%NOTFOUND THEN
                CLOSE c_sgcc_dai;
                v_census_dt := TRUNC(SYSDATE);
            ELSE
                CLOSE c_sgcc_dai;
            END IF;
        ELSE
            v_census_dt := TRUNC(SYSDATE);
        END IF;
        v_sca_cp_total := Igs_En_Gen_001.ENRP_CLC_SCA_PASS_CP(
                        p_person_id,
                        p_course_cd,
                        v_census_dt);
    END IF;
    -- 4. Determine the course annual load record which applies to the students
    -- passed credit points range.
    v_cumulative_load := 0;
    v_annual_load_val := 0;
    FOR v_cal_rec   IN  c_cal2 LOOP
        v_cumulative_load := v_cumulative_load + v_cal_rec.annual_load_val;
        IF (v_sca_cp_total < v_cumulative_load) THEN
            v_annual_load_val := v_cal_rec.annual_load_val;
            EXIT;
        END IF;
    END LOOP;
    IF (v_annual_load_val = 0) THEN
        -- Revert to the course_version annual load value.
        OPEN    c_crv;
        FETCH   c_crv   INTO    v_std_annual_load;
        IF (c_crv%NOTFOUND) THEN
            -- At present, this will not occur because to reach this point
            -- a record must exist in IGS_PS_ANL_LOAD and for the course
            -- to exist in IGS_PS_ANL_LOAD it must exist in IGS_PS_VER.
            CLOSE   c_crv;
            RETURN 0;
        END IF;
        CLOSE   c_crv;
        v_annual_load_val := v_std_annual_load;
    END IF;
    RETURN v_annual_load_val;
  EXCEPTION
    WHEN OTHERS THEN
        IF c_cal%ISOPEN THEN
            CLOSE c_cal;
        END IF;
        IF c_crv%ISOPEN THEN
            CLOSE c_crv;
        END IF;
        IF c_calul_cal%ISOPEN THEN
            CLOSE c_calul_cal;
        END IF;
        IF c_cal2%ISOPEN THEN
            CLOSE c_cal2;
        END IF;
        IF c_sgcc_dai%ISOPEN THEN
            CLOSE c_sgcc_dai;
        END IF;
        RAISE;
  END;
  END enrp_get_ann_load;
  --
  -- To calc the total load for an SCA for a load period
  FUNCTION ENRP_CLC_LOAD_TOTAL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_sequence_number IN NUMBER )
  RETURN NUMBER  AS
  BEGIN
  DECLARE
    cst_active          CONSTANT VARCHAR2(10) := 'ACTIVE';
    cst_teaching        CONSTANT VARCHAR2(10) := 'TEACHING';
    cst_enrolled        CONSTANT VARCHAR2(10) := 'ENROLLED';
    cst_completed       CONSTANT VARCHAR2(10) := 'COMPLETED';
    cst_discontin       CONSTANT VARCHAR2(10) := 'DISCONTIN';
    cst_waitlisted      CONSTANT VARCHAR2(10) := 'WAITLISTED';

    v_calendar_load     NUMBER;
    v_return_eftsu      NUMBER;
    --dummy variable to pick up audit, billing, enrolled credit points
    --due to signature change by EN308 Billing credit hours
    l_audit_cp          IGS_PS_USEC_CPS.billing_credit_points%TYPE;
    l_billing_cp        IGS_PS_USEC_CPS.billing_hrs%TYPE;
    l_enrolled_cp       IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;
    CURSOR  c_cal_type_instance(  cp_cal_type IGS_CA_INST.cal_type%TYPE,
                cp_sequence_number IGS_CA_INST.sequence_number%TYPE)IS
        SELECT  CI.cal_type,
            CI.sequence_number
        FROM    IGS_CA_INST_REL CIR,
            IGS_CA_INST CI,
            IGS_CA_TYPE CT,
            IGS_CA_STAT CS
        WHERE   CT.closed_ind = 'N' AND
            CT.s_cal_cat = cst_teaching AND
            CS.s_cal_status = cst_active AND
            CI.cal_status = CS.cal_status AND
            CI.cal_type = CT.cal_type AND
            CIR.sup_cal_type = cp_cal_type AND
            CIR.sup_ci_sequence_number =  cp_sequence_number AND
            CIR.sub_cal_type = CI.cal_type AND
            CIR.sub_ci_sequence_number = CI.sequence_number;
  --            (IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(cp_cal_type,
  --                cp_sequence_number,
  --                CI.cal_type,
  --                CI.sequence_number,
  --                'N') = 'Y');
    CURSOR  c_stu_unit_atmpt(
            cp_person_id IGS_PE_PERSON.person_id%TYPE,
            cp_course_cd IGS_PS_COURSE.course_cd%TYPE,
            cp_cal_type IGS_CA_INST.cal_type%TYPE,
            cp_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  SUA.unit_cd,
                SUA.version_number,
                SUA.cal_type,
                SUA.ci_sequence_number,
                SUA.override_enrolled_cp,
                SUA.override_eftsu,
                SUA.unit_attempt_status,
                SUA.administrative_unit_status,
                SUA.discontinued_dt,
                SUA.uoo_id,
                SUA.no_assessment_ind
        FROM    IGS_EN_SU_ATTEMPT SUA
        WHERE   SUA.person_id = cp_person_id AND
                SUA.course_cd = cp_course_cd AND
                SUA.cal_type = cp_cal_type AND
                SUA.ci_sequence_number = cp_sequence_number AND
                SUA.unit_attempt_status IN (cst_enrolled, cst_completed, cst_discontin, cst_waitlisted);
  BEGIN
    -- Calculate a students total load within a nominated LOAD calendar.
    -- This routine will call other routines to determine the load apportionment
    -- values for the students unit attempts.
    v_calendar_load := 0;
    FOR v_cal_type_instance_rec IN c_cal_type_instance(
                            p_acad_cal_type,
                            p_acad_sequence_number)
    LOOP
         FOR v_stu_unit_atmpt_rec IN c_stu_unit_atmpt(
                p_person_id,
                p_course_cd,
                v_cal_type_instance_rec.cal_type,
                v_cal_type_instance_rec.sequence_number)
         LOOP
            IF (ENRP_GET_LOAD_INCUR(
                    v_cal_type_instance_rec.cal_type,
                    v_cal_type_instance_rec.sequence_number,
                    v_stu_unit_atmpt_rec.discontinued_dt,
                    v_stu_unit_atmpt_rec.administrative_unit_status,
                    v_stu_unit_atmpt_rec.unit_attempt_status,
                    v_stu_unit_atmpt_rec.no_assessment_ind,
                    p_load_cal_type,
                    p_load_sequence_number,
                    v_stu_unit_atmpt_rec.uoo_id,
                    -- anilk, Audit special fee build
                    'N') = 'Y') THEN

                    v_calendar_load := v_calendar_load + ENRP_CLC_SUA_LOAD(
                                        v_stu_unit_atmpt_rec.unit_cd,
                                        v_stu_unit_atmpt_rec.version_number,
                                        v_stu_unit_atmpt_rec.cal_type,
                                        v_stu_unit_atmpt_rec.ci_sequence_number,
                                        p_load_cal_type,
                                        p_load_sequence_number,
                                        v_stu_unit_atmpt_rec.override_enrolled_cp,
                                        v_stu_unit_atmpt_rec.override_eftsu,
                                        v_return_eftsu,
                                        v_stu_unit_atmpt_rec.uoo_id,
                                        -- anilk, Audit special fee build
                                        'N',
                                        l_audit_cp,
                                        l_billing_cp,
                                        l_enrolled_cp);

            END IF;
       END LOOP;
    END LOOP;
    RETURN v_calendar_load;
  EXCEPTION
    WHEN OTHERS THEN
       IF SQLCODE <>-20001 THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_PRC_LOAD.enrp_clc_load_total');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception(NULL,NULL,fnd_message.get);
    ELSE
        RAISE;
    END IF;
  END;
  END enrp_clc_load_total;
  --
  -- To calculate the load for a sua (optionally within a load calendar)
  FUNCTION ENRP_CLC_SUA_LOAD(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_return_eftsu OUT NOCOPY NUMBER ,
  p_uoo_id        IN NUMBER,
  -- anilk, Audit special fee build
  p_include_as_audit IN VARCHAR2,
  p_audit_cp                    OUT NOCOPY NUMBER,
  p_billing_cp          OUT NOCOPY NUMBER,
  p_enrolled_cp         OUT NOCOPY NUMBER)
  RETURN NUMBER  AS
/*
who          when     What
sarakshi 27-Jun-2003  Enh#2930935,modified cursor c_unit_version such that it picks enrolled credit points
                      from the usec level if exist else from the unit level
vkarthik 21-Jul-2004  Added two out parameters p_audit_cp and p_billing_cp for
                      EN308 for Billable credit points build.  Changed code logic to get various cps.
                      Added logic to get audit_cp
*/
  BEGIN
    BEGIN
    DECLARE
        v_enrolled_credit_points    IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;
        v_enrolled_cp               IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;
        v_billing_cp                IGS_PS_USEC_CPS.billing_hrs%TYPE;
        v_percentage                IGS_ST_DFT_LOAD_APPO.percentage%TYPE;
        v_second_percentage         IGS_ST_DFT_LOAD_APPO.second_percentage%TYPE;
        v_acad_cal_type             IGS_CA_INST.cal_type%TYPE;
        v_acad_ci_sequence_number   IGS_CA_INST.sequence_number%TYPE;
        v_acad_ci_start_dt          IGS_CA_INST.start_dt%TYPE;
        v_acad_ci_end_dt            IGS_CA_INST.end_dt%TYPE;
        v_first_cal_type            IGS_CA_INST.cal_type%TYPE;
        v_first_ci_sequence_number  IGS_CA_INST.sequence_number%TYPE;
        v_first_ci_start_dt         IGS_CA_INST.start_dt%TYPE;
        v_first_ci_end_dt           IGS_CA_INST.end_dt%TYPE;
        v_dummy_alt_cd              IGS_CA_INST.alternate_code%TYPE;
        v_message_name              VARCHAR2(30);
        v_audit_cp                  IGS_PS_USEC_CPS.billing_credit_points%TYPE;

        CURSOR  c_dflt_load_apportion(
                cp_acad_cal_type IGS_ST_DFT_LOAD_APPO.cal_type%TYPE,
                cp_acad_ci_sequence_number IGS_ST_DFT_LOAD_APPO.ci_sequence_number%TYPE,
                cp_cal_type IGS_ST_DFT_LOAD_APPO.teach_cal_type%TYPE)IS
            SELECT  DLA.percentage,
                DLA.second_percentage
            FROM    IGS_ST_DFT_LOAD_APPO DLA
            WHERE   DLA.cal_type = cp_acad_cal_type AND
                DLA.ci_sequence_number = cp_acad_ci_sequence_number AND
                DLA.teach_cal_type = cp_cal_type;
    BEGIN
        p_audit_cp := NULL;
        p_billing_cp := NULL;
        p_enrolled_cp := NULL;
        -- Calculate the load (credit points) for a nominated unit attempt within
        -- a nominated calendar instance. The calendar instance may be either a load
        -- period or null. If a calendar instance is specified, a search for a matching
        -- IGS_ST_DFT_LOAD_APPO record will be performed; if not found the apportionment
        -- is assumed to be 0%. If no calendar is specified the apportionment is always
        -- 100%.
        --get the various cps, using the inheritance model of PSP
        igs_ps_val_uv.get_cp_values(p_uoo_id,
                                    v_enrolled_cp,
                                    v_billing_cp,
                                    v_audit_cp);

        --set the valud of enrolled_credit_points according to overide_enrolled_cp, auditable,
        --non-auditable units
        IF p_override_enrolled_cp IS NOT NULL AND p_include_as_audit = 'N' THEN
                v_enrolled_credit_points := p_override_enrolled_cp;
        ELSIF p_include_as_audit = 'Y' THEN
                v_enrolled_credit_points := v_audit_cp;
        ELSE
                v_enrolled_credit_points := v_enrolled_cp;
        END IF;
        --set out cp parameters
        p_audit_cp := v_audit_cp;
        p_billing_cp := v_billing_cp;
        p_enrolled_cp := NVL(p_override_enrolled_cp, v_enrolled_cp);
        --return zero when values are not defined
        IF      p_billing_cp IS NULL                    AND
                v_enrolled_credit_points = 0    AND
                p_audit_cp IS NULL                      AND
                p_enrolled_cp IS NULL           THEN
                RETURN 0;
        END IF;
        -- Search for a apportionment record between the academic calendar
        -- instance and teaching calendar type. If not found, percentage is assumed
        -- to be 100 (assuming all of the teaching period is within the academic
        -- calendar instance).
        IF(p_load_cal_type IS NOT NULL AND p_load_ci_sequence_number IS NOT NULL) THEN
            OPEN    c_dflt_load_apportion(
                        p_load_cal_type,
                        p_load_ci_sequence_number,
                        p_cal_type);
            FETCH   c_dflt_load_apportion INTO v_percentage,  v_second_percentage;
            IF(c_dflt_load_apportion%NOTFOUND) THEN
                  v_percentage := 0;
            ELSIF (v_second_percentage IS NULL) THEN
                  NULL;
            ELSE
              v_dummy_alt_cd := Igs_En_Gen_002.ENRP_GET_ACAD_ALT_CD(
                            p_load_cal_type,
                            p_load_ci_sequence_number,
                            v_acad_cal_type,
                            v_acad_ci_sequence_number,
                            v_acad_ci_start_dt,
                            v_acad_ci_end_dt,
                            v_message_name);
              IF(v_dummy_alt_cd IS NULL) THEN
                NULL;
              ELSE
                v_dummy_alt_cd := Igs_En_Gen_002.ENRP_GET_ACAD_ALT_CD(
                                p_cal_type,
                                p_ci_sequence_number,
                                v_first_cal_type,
                                v_first_ci_sequence_number,
                                v_first_ci_start_dt,
                                v_first_ci_end_dt,
                                v_message_name);

                IF(v_dummy_alt_cd IS NULL) THEN
                  NULL;
                ELSE
                  IF((v_acad_cal_type = v_first_cal_type) AND
                 (v_acad_ci_sequence_number = v_first_ci_sequence_number)) THEN
                    NULL;
                  ELSE
                    v_percentage := v_second_percentage;
                  END IF;
                END IF;
              END IF;
            END IF;
            CLOSE   c_dflt_load_apportion;
        ELSE
            v_percentage := 100;
        END IF;
        -- If the override eftsu is passed then calculate the proportion of the EFTSU
        -- figure whch is incurred within the load calendar instance specified.
        IF p_override_eftsu IS NOT NULL THEN
            p_return_eftsu := p_override_eftsu * (v_percentage / 100);
        ELSE
            p_return_eftsu := NULL;
        END IF;
        IF p_billing_cp IS NOT NULL THEN
                p_billing_cp := v_billing_cp * (v_percentage/100);
        END IF;
        IF p_audit_cp IS NOT NULL THEN
                p_audit_cp := v_audit_cp * (v_percentage/100);
        END IF;
        IF p_enrolled_cp IS NOT NULL THEN
                p_enrolled_cp := p_enrolled_cp * (v_percentage/100);
        END IF;
                RETURN (v_enrolled_credit_points * (v_percentage/100));
     END;
  END enrp_clc_sua_load;
  END;

  --
  -- To get the attendance type of load within a nominated load calendar
  FUNCTION ENRP_GET_LOAD_ATT(
  p_load_cal_type IN VARCHAR2 ,
  p_load_figure IN NUMBER )
  RETURN VARCHAR2  AS
  BEGIN
  DECLARE
    v_record_found      BOOLEAN;
    v_record_count      NUMBER;
    v_attendance_type   IGS_EN_ATD_TYPE_LOAD.attendance_type%TYPE;
    CURSOR  c_attendance_type(
            cp_cal_type IGS_CA_TYPE.cal_type%TYPE,
            cp_load_figure IGS_EN_ATD_TYPE_LOAD.lower_enr_load_range%TYPE) IS
        SELECT  ATL.attendance_type
        FROM    IGS_EN_ATD_TYPE_LOAD ATL
        WHERE   ATL.cal_type = p_load_cal_type AND
                ATL.lower_enr_load_range <= p_load_figure AND
                ATL.upper_enr_load_range >= p_load_figure;
  BEGIN
    -- Get the attendance type for a nominated CP load in a nominated load calendar
    -- This is done by searching for an IGS_EN_ATD_TYPE_LOAD record which specifies
    -- the load ranges for the different attendance types within the load calendar
    -- types. If no record is found then NULL is returned, as it is not possible to
    -- derive the figure.
    IF p_load_figure = 0 THEN
        RETURN NULL;
    END IF;
    v_record_found := FALSE;
    v_record_count := 0;
    FOR v_attendance_type_rec IN c_attendance_type(
                        p_load_cal_type,
                        trunc(p_load_figure,3))
    LOOP
        v_record_found := TRUE;
        v_record_count := v_record_count + 1;
        v_attendance_type := v_attendance_type_rec.attendance_type;
    END LOOP;
    IF(v_record_found = FALSE) THEN
        RETURN NULL;
    END IF;
    IF(v_record_count > 1) THEN
        RETURN NULL;
    ELSE
        RETURN v_attendance_type;
    END IF;

  END;
  END enrp_get_load_att;
  --
  -- To get whether a UA incurs load within a nominated load calendar
  FUNCTION ENRP_GET_LOAD_INCUR(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_discontinued_dt IN DATE ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_no_assessment_ind IN VARCHAR2,
  p_load_cal_type IN VARCHAR2 ,
  p_load_sequence_number IN NUMBER,
  p_uoo_id IN NUMBER,
  -- anilk, Audit special fee build
  p_include_audit IN VARCHAR2 )
  RETURN VARCHAR2  AS
  /*   Who           When                What
      pradhakr      15-Jan-03           Added one parameter no_assessment_ind wrt ENCR026 build.
                                        Bug# 2743459
      jbegum        21 Mar 02           As part of bug fix 2192616 added
                                        pragma exception_init(NO_AUSL_RECORD_FOUND , -20010);
                                        to the user defined exception NO_AUSL_RECORD_FOUND
                                        in order to catch the exception in the form IGSPS047.
      pradhakr      30-Jul-01           Added the parameter uoo_id as part of Enrollment Process.
                                        Bug# 1832130
     myoganat      23-MAY-2003          Removed reference to profile
                                        IGS_EN_INCL_AUDIT_CP in
                                        procedure ENRP_GET_LOAD_INCUR
                                        as part of the ENCR032 Build Bug
                                        #2855870
                                        */
  BEGIN
  DECLARE
    NO_AUSL_RECORD_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_AUSL_RECORD_FOUND , -20010);

    cst_completed       CONSTANT VARCHAR2(10) := 'COMPLETED';
    cst_enrolled        CONSTANT VARCHAR2(10) := 'ENROLLED';
    cst_discontin       CONSTANT VARCHAR2(10) := 'DISCONTIN';
    cst_waitlisted      CONSTANT VARCHAR2(10) := 'WAITLISTED';

    CURSOR  c_dla(
            cp_load_cal_type IGS_CA_INST.cal_type%TYPE,
            cp_load_sequence_number IGS_CA_INST.sequence_number%TYPE,
            cp_cal_type IGS_CA_INST.cal_type%TYPE) IS
        SELECT  ci.start_dt,
                ci.end_dt
        FROM    IGS_ST_DFT_LOAD_APPO dla,
                IGS_CA_INST ci
        WHERE   dla.cal_type = cp_load_cal_type AND
                dla.ci_sequence_number = cp_load_sequence_number AND
                dla.teach_cal_type = cp_cal_type AND
                ci.cal_type = dla.cal_type AND
                ci.sequence_number = dla.ci_sequence_number;

    CURSOR  c_ausl(
             cp_load_cal_type IGS_CA_INST.cal_type%TYPE,
             cp_load_sequence_number IGS_CA_INST.sequence_number%TYPE,
             cp_cal_type IGS_CA_INST.cal_type%TYPE,
             cp_administrative_unit_status
               IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE) IS
        SELECT  AUSL.load_incurred_ind
        FROM    IGS_AD_ADM_UT_STT_LD AUSL
        WHERE   AUSL.cal_type = cp_load_cal_type AND
                AUSL.ci_sequence_number = cp_load_sequence_number AND
                AUSL.teach_cal_type = cp_cal_type AND
                AUSL.administrative_unit_status = cp_administrative_unit_status;

   CURSOR incl_org_wlst_cp is
          SELECT asses_chrg_for_wlst_stud
          FROM IGS_EN_OR_UNIT_WLST
          WHERE cal_type = p_load_cal_type AND
          closed_flag = 'N' AND
          org_unit_cd = (SELECT NVL(uoo.owner_org_unit_cd, uv.owner_org_unit_cd)
                         FROM igs_ps_unit_ofr_opt uoo,
                              igs_ps_unit_ver uv
                          WHERE uoo.uoo_id = p_uoo_id AND
                                uv.unit_cd = uoo.unit_cd AND
                                uv.version_number = uoo.version_number);
  CURSOR incl_inst_wlst_cp is
         SELECT include_waitlist_cp_flag
         FROM IGS_EN_INST_WL_STPS;

    v_alias_val     IGS_CA_DA_INST_V.alias_val%TYPE;
    v_load_incurred_ind IGS_AD_ADM_UT_STT_LD.load_incurred_ind%TYPE;
    v_start_dt      IGS_CA_INST.start_dt%TYPE;
    v_end_dt        IGS_CA_INST.end_dt%TYPE;
    v_dummy_aus     VARCHAR2(10);
    v_admin_unit_status_str VARCHAR2(2000);
    v_incl_wlst_cp VARCHAR2(1);
  BEGIN

    -- Routine to determine whether a nominated student unit attempt incurs load
    -- for a nominated load calendar.
    -- For DISCONTIN unit attempts, the routine  determines the date alias instance
    -- which was used in the original discontinuation.  If this alias_val :
    -- 1. if prior to the load calendar instance - then load is never incurred
    -- 2. is after the load calendar instance - then load is always incurred.
    -- ELSE
    -- it checks the IGS_AD_ADM_UT_STT_LD table for a link between the
    --  administrative
    -- unit status and the load calendar as at the effective date.
    -- For ENROLLED or COMPLETED unit attempts - the load is always incurred.
    -- For other statuses - load cannot be incurred.
    -- Check whether the teaching calendar has a load apportionment link
    -- th the load calendar. If no IGS_ST_DFT_LOAD_APPO detail exists then
    -- load is definitely not incurred. Processing concludes.
    -- Note: this query joints to the IGS_CA_INST tabel to get the start
    -- and end dates - this is to possibly save doing it later


    -- Check whether the passed in Unit Attempt is a Audit Unit
    -- If so, return 'N' else use the existing logic to get the EFTSU and credit points of the
    -- unit attempt.
    IF NVL(p_no_assessment_ind,'N') = 'Y'  AND p_include_audit = 'N' THEN
      RETURN 'N';
    END IF;

    OPEN    c_dla(
            p_load_cal_type,
            p_load_sequence_number,
            p_cal_type);
    FETCH c_dla INTO v_start_dt,  v_end_dt;
    IF (c_dla%NOTFOUND) THEN
        CLOSE c_dla;
        RETURN 'N';
    END IF;
    CLOSE c_dla;
   --fetch teh waitlist values, added as part of waitlist enhancement build #3052426
     OPEN incl_org_wlst_cp;
     FETCH incl_org_wlst_cp into v_incl_wlst_cp;

       IF incl_org_wlst_cp%NOTFOUND then
          OPEN incl_inst_wlst_cp;
          FETCH incl_inst_wlst_cp INTO v_incl_wlst_cp;
          CLOSE incl_inst_wlst_cp;
       END IF;
     CLOSE incl_org_wlst_cp;

    -- If the unit attempt is discontinued, select the load incurred indicator for
    -- the administrative unit status.
    IF(p_unit_attempt_status = cst_discontin) THEN
        -- call the routine to determine the alias_val of
        -- the original discontinuation criteria
        v_dummy_aus := Igs_En_Gen_008.ENRP_GET_UDDC_AUS (
                    p_discontinued_dt,
                    p_cal_type,
                    p_sequence_number,
                    v_admin_unit_status_str,
                    v_alias_val,
                    p_uoo_id);
        -- only continue with the below tests
        -- if a value was returned for the v_alias_val


        IF (v_alias_val IS NOT NULL) THEN
            -- if the alias_val is prior to the start date of
            -- the load calendar instance, then load is not
            -- incurred
            IF (v_alias_val < v_start_dt) THEN
                RETURN 'N';
            END IF;
            -- if the alias_val is after the end date of the
            -- load calendar instance, then load is always
            -- incurred
            IF (v_alias_val > v_end_dt) THEN
                RETURN 'Y';
            END IF;
        END IF;
        -- if none of the above is true, then look for
        -- the administrative unit status load details
        OPEN    c_ausl(
                p_load_cal_type,
                p_load_sequence_number,
                p_cal_type,
                p_administrative_unit_status);
        FETCH   c_ausl INTO v_load_incurred_ind;
        -- if no records found, raise an exception
        IF(c_ausl%NOTFOUND) THEN
            CLOSE   c_ausl;
            RAISE NO_AUSL_RECORD_FOUND;
        END IF;
        CLOSE c_ausl;
        IF(v_load_incurred_ind = 'Y') THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;
    ELSIF (p_unit_attempt_status = cst_enrolled OR
           p_unit_attempt_status = cst_completed) THEN
        RETURN 'Y';
    --logic to determine waitlisted credit points . earlier the profile IGS_EN_INCL_WLST_CP was used
    --this has been obsoleted as part of wailist enhancement build to determine form the checkbox setup at
    -- various level
    -- as per the functional requirement , if the check box to include waitlist CP  is unchecked then
    --check the profile value. If this is yes then include waitlist CP in validations. IF the institution level
    --   checkbox is checked then no need to check profile. The profile does not override the institution level
    --setup.

    ELSIF (p_unit_attempt_status = cst_waitlisted )AND
    (v_incl_wlst_cp = 'Y' OR ( v_incl_wlst_cp is null and g_wlst_prfl = 'Y' ) )THEN
                         RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

  END;

  END ENRP_GET_LOAD_INCUR;
  --
  -- To get whether a load applies to a UA within a nominated load calendar
  FUNCTION ENRP_GET_LOAD_APPLY(
  p_teach_cal_type          IN VARCHAR2 ,
  p_teach_sequence_number   IN NUMBER ,
  p_discontinued_dt         IN DATE ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_unit_attempt_status     IN VARCHAR2 ,
  p_no_assessment_ind       IN VARCHAR2,
  p_load_cal_type           IN VARCHAR2 ,
  p_load_sequence_number    IN NUMBER,
  -- anilk, Audit special fee build
  p_include_audit           IN VARCHAR2)
  RETURN VARCHAR2  AS
  BEGIN
  DECLARE
    -- cursor to check if a load and teaching calendar instance are related to
    -- the same academic period calendar instance.
    CURSOR  c_cal_reln(
            cp_load_cal_type        IGS_CA_INST.cal_type%TYPE,
            cp_load_sequence_number     IGS_CA_INST.sequence_number%TYPE,
            cp_teach_cal_type       IGS_CA_INST.cal_type%TYPE,
            cp_teach_sequence_number    IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  'X'
        FROM    IGS_CA_INST_REL cir1,
                IGS_CA_TYPE ct,
                IGS_CA_INST_REL cir2
        WHERE   cir1.sub_cal_type = cp_load_cal_type AND
                cir1.sub_ci_sequence_number = cp_load_sequence_number AND
                ct.cal_type = cir1.sup_cal_type AND
                ct.s_cal_cat = 'ACADEMIC' AND
                cir2.sup_cal_type = cir1.sup_cal_type AND
                cir2.sup_ci_sequence_number = cir1.sup_ci_sequence_number AND
                cir2.sub_cal_type = cp_teach_cal_type AND
                cir2.sub_ci_sequence_number = cp_teach_sequence_number;
    v_dummy     VARCHAR2(1);
  BEGIN

    -- Routine to determine whether load applies to a nominated student unit
    -- attempt for a nominated load calendar.
    OPEN    c_cal_reln(
            p_load_cal_type,
            p_load_sequence_number,
            p_teach_cal_type,
            p_teach_sequence_number);
    FETCH c_cal_reln INTO v_dummy;
    IF (c_cal_reln%NOTFOUND) THEN
        CLOSE c_cal_reln;
        RETURN 'N';
    END IF;
    CLOSE c_cal_reln;
    -- Call routine to check if load is incurred.
    RETURN ENRP_GET_LOAD_INCUR(
                    p_teach_cal_type,
                    p_teach_sequence_number,
                    p_discontinued_dt,
                    p_administrative_unit_status,
                    p_unit_attempt_status,
                    p_no_assessment_ind,
                    p_load_cal_type,
                    p_load_sequence_number,
                    -- anilk, Audit special fee build
                    NULL, -- for p_uoo_id
                    p_include_audit
                    );

  END;
  END ENRP_GET_LOAD_APPLY;

FUNCTION enrp_clc_key_prog(p_person_id                     IN   hz_parties.party_id%TYPE,
                           p_version_number                OUT NOCOPY  igs_en_su_attempt.version_number%TYPE,
                           p_term_cal_type                 IN VARCHAR2,
                           p_term_sequence_number          IN NUMBER
                           )
RETURN igs_en_su_attempt.course_cd%TYPE

/*******************************************************************************************
  Created By   :    Prajeesh Chandran .K
  Creation Date:    8-JAN-2002
  Purpose      :    Bug No:2174101
                    Added this Function to get the Key Programs for the Particular Person
*******************************************************************************************/
AS
 /*   Who           When                What
      stutta        24-NOV-2003         Introduced a new cursor c_term_key_prog to check the term records
                                        for the key program before checking the program attempt table. Term records Build  */
  CURSOR c_key_prog IS
         SELECT course_cd,
                version_number
         FROM
         igs_en_stdnt_ps_att WHERE
         key_program='Y' AND
         person_id=p_person_id;

  CURSOR c_term_key_prog IS
        SELECT program_cd, program_version
        FROM igs_en_spa_terms
        WHERE person_id = p_person_id
        AND   term_cal_type = p_term_cal_type
        AND   term_sequence_number = p_term_sequence_number
        AND   key_program_flag = 'Y';

  l_key_prog      igs_en_stdnt_ps_att.course_cd%TYPE;
  l_key_prog_ver  igs_en_stdnt_ps_att.version_number%TYPE;

BEGIN

  -- This Function gets the Person and finds the key_program for that particular person and returns that Key
  -- Program and version Number

  --## if the parameters are not sent withproper values it raises a error

  IF p_person_id IS NULL THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_INSUFFICIENT_PARAMETER');
    IGS_GE_MSG_STACK.ADD;
    p_version_number := NULL;
    RETURN NULL;
  END IF;

  OPEN c_term_key_prog;
  FETCH c_term_key_prog INTO l_key_prog, l_key_prog_ver;
  IF c_term_key_prog%NOTFOUND THEN
     OPEN c_key_prog;
     FETCH c_key_prog INTO l_key_prog,l_key_prog_ver;
     IF c_key_prog%NOTFOUND THEN
         p_version_number := NULL;
        CLOSE c_key_prog;
        CLOSE c_term_key_prog;
        RETURN NULL;
     END IF;
     CLOSE c_key_prog;
  END IF;

  CLOSE c_term_key_prog;
  p_version_number := l_key_prog_ver;

  RETURN l_key_prog;

EXCEPTION
       WHEN OTHERS THEN
        IF c_key_prog%ISOPEN THEN
           CLOSE c_key_prog;
        END IF;
        IF c_term_key_prog%ISOPEN THEN
           CLOSE c_term_key_prog;
        END IF;
        p_version_number:=NULL;
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        FND_MESSAGE.SET_TOKEN('NAME','enrp_clc_key_prog: '||SQLERRM);
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION(NULL,NULL,fnd_message.get);



END enrp_clc_key_prog;

PROCEDURE enrp_get_inst_latt(p_person_id                  IN  hz_parties.party_id%TYPE,
                             p_load_cal_type              IN  igs_ca_inst.cal_type%TYPE,
                             p_load_seq_number            IN  igs_ca_inst.sequence_number%TYPE,
                             p_attendance                 OUT NOCOPY igs_en_atd_type_load.attendance_type%TYPE,
                             p_credit_points              OUT NOCOPY igs_en_su_attempt.override_achievable_cp%TYPE,
                             p_fte                        OUT NOCOPY igs_en_su_attempt.override_achievable_cp%TYPE
                            )
AS

/*******************************************************************************************
  Created By   :    Prajeesh Chandran .K
  Creation Date:    8-JAN-2002
  Purpose      :    Bug No:2174101
                    Added this Function to get the Institution Level Attendance Type
                    crecit Points and Full Time Equivalent for the Person in a
                    load calendar
                    Logic for this Program:
                    1. First check for the existence of Key Programs
                       if it doesnot exists it is returned with error message
                    2. If it exists check it is career centric or Program Centric Model
                       If Career Centric Model then
                       a) Get all the active  Primary Programs (Active implies program_attempt_status
                           is ENROLLED,INACTIVE) and call the function enrp_clc_eftsu_total to get
                           the eftsu total for the primary programs. sum all the eftsu total
                           to get the total eftsu
                       b) If Program Centric Model then get all the active programs for the
                          person and call eftsu total to get the tota eftsu for each programs
                          sum all the eftsu to get the total eftsu

                     3. Call the igs_en_get_std_att procedure to get the attendance
                        type for the given FTE range
*******************************************************************************************/
 /*   Who          When          What
      stutta       24-NOV-2003   Modified cursor c_active_cd to consider term records while
                                 finding out the primary program of a student. Term Records Build.
 */
 l_acad_cal_type                 igs_ca_inst.cal_type%TYPE;
 l_acad_ci_sequence_number       igs_ca_inst.sequence_number%TYPE;
 l_acad_ci_start_dt              igs_ca_inst.start_dt%TYPE;
 l_acad_ci_end_dt                igs_ca_inst.end_dt%TYPE;
 l_message_name                  VARCHAR2(100) := NULL;
 l_credit_points                 igs_en_su_attempt.override_achievable_cp%TYPE  := 0;
 l_tot_credit_points             igs_en_su_attempt.override_achievable_cp%TYPE  := 0;
 l_eftsu_total                   igs_en_su_attempt.override_eftsu%TYPE  := 0;
 l_alternate_code                igs_ca_inst.alternate_code%TYPE := NULL;
 l_course_cd                     igs_en_su_attempt.course_cd%TYPE;
 l_version_number                igs_en_su_attempt.version_number%TYPE;
 l_attendance_type               igs_en_atd_type_load.attendance_type%TYPE;


 --## CURSOR to get the Person number for the person id for message tokens

 CURSOR c_person IS
        SELECT party_number
        FROM hz_parties
        WHERE party_id=p_person_id;

 l_person             hz_parties.party_number%TYPE;

   CURSOR c_spa(cp_person_id       IGS_PE_PERSON.person_id%TYPE,
              cp_load_cal_type   IGS_EN_SPA_TERMS.term_cal_type%TYPE,
              cp_load_seq_number IGS_EN_SPA_TERMS.term_sequence_number%TYPE) IS
  Select sca.course_cd
  From   igs_en_stdnt_ps_att_all sca,
         igs_ps_ver_all pv
        WHERE  sca.person_id = cp_person_id
      AND    sca.course_cd = pv.course_cd
      AND    sca.version_number = pv.version_number
      AND   (
       (NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y' AND igs_en_spa_terms_api.get_spat_primary_prg(sca.person_id, sca.course_cd, cp_load_cal_type,cp_load_seq_number)='PRIMARY')
       OR
       (NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'N')
       );


  vc_spa c_spa%ROWTYPE;


BEGIN

--## if the parameters are not sent withproper values it raises a error

IF p_load_cal_type IS NULL OR p_load_seq_number IS NULL OR p_person_id IS NULL THEN
  FND_MESSAGE.SET_NAME('IGS','IGS_GE_INSUFFICIENT_PARAMETER');
  IGS_GE_MSG_STACK.ADD;
  p_fte           := NULL;
  p_credit_points := NULL;
  p_attendance    := NULL;
  app_exception.raise_exception;
END IF;

--## It is a Cursor to retrive the Message tokens(Person Number) and hence
--## cursor is just closed if no record exist and no error is shown

OPEN c_person;
FETCH c_person INTO l_person;
CLOSE c_person;



--## First get the Key Programs  if it doesnot exists raise a error
l_course_cd := NULL;
l_course_cd  := enrp_clc_key_prog(p_person_id,l_version_number,p_load_cal_type,p_load_seq_number);
IF l_course_cd IS NULL THEN
  FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_KEY_PRG');
  FND_MESSAGE.SET_TOKEN('PERSON',l_person);
  IGS_GE_MSG_STACK.ADD;
  p_fte           := NULL;
  p_credit_points := NULL;
  p_attendance    := NULL;
  app_exception.raise_exception;
END IF;

--## Get the academic Calendar for the given load calendar

l_alternate_code:=  Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd
                             (
                             p_load_cal_type ,
                             p_load_seq_number,
                             l_acad_cal_type ,
                             l_acad_ci_sequence_number,
                             l_acad_ci_start_dt,
                             l_acad_ci_end_dt ,
                             l_message_name
                             );

--## If academic Calendar doesnot exists raise a error and stop the process

IF l_acad_cal_type IS NULL OR l_acad_ci_sequence_number IS NULL THEN
  FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_ACAD_CAL');
  IGS_GE_MSG_STACK.ADD;
  p_fte           := NULL;
  p_credit_points := NULL;
  p_attendance    := NULL;
  app_exception.raise_exception;
END IF;


 --loop through the program attempts related to the term records for the student
 -- in the passed in load cal type and sequence number
  FOR vc_spa IN c_spa(p_person_id, p_load_cal_type, p_load_seq_number) LOOP

    l_eftsu_total := l_eftsu_total +  ENRP_CLC_EFTSU_TOTAL
                                                (
                                                p_person_id ,
                                                vc_spa.course_cd,
                                                l_acad_cal_type ,
                                                l_acad_ci_sequence_number,
                                                p_load_cal_type ,
                                                p_load_seq_number,
                                               'N',
                                               'N' ,
                                                l_course_cd ,
                                                l_version_number,
                                                l_credit_points
                                                );

   l_tot_credit_points := l_tot_credit_points + NVL(l_credit_points,0);

  END LOOP;

 --end of new code

  p_credit_points := l_tot_credit_points;
  p_fte           := l_eftsu_total;

  --## Get the the attendance type by passing the load caltype and fte

  l_attendance_type :=     ENRP_GET_LOAD_ATT
                                (
                                p_load_cal_type ,
                                p_fte
                                );
   p_attendance    := l_attendance_type;


END enrp_get_inst_latt;



PROCEDURE enrp_get_inst_latt_fte(p_person_id              IN  hz_parties.party_id%TYPE,
                             p_load_cal_type              IN  igs_ca_inst.cal_type%TYPE,
                             p_load_seq_number            IN  igs_ca_inst.sequence_number%TYPE,
                             p_attendance                 OUT NOCOPY igs_en_atd_type_load.attendance_type%TYPE,
                             p_credit_points              OUT NOCOPY igs_en_su_attempt.override_achievable_cp%TYPE,
                             p_fte                        OUT NOCOPY igs_en_su_attempt.override_achievable_cp%TYPE
                            )
AS

/*******************************************************************************************
  Created By   :    anilk
  Creation Date:    06-AUG-2003
  Purpose      :    Bug No# 3046897
                    Added this Function to get the Institution Level Attendance Type
                    crecit Points and Full Time Equivalent for the Person in a
                    load calendar
                This procedure is called from ViewAcademicHistoryAMImpl.java, getFteValue()
*******************************************************************************************/
/*   Who          When          What
     stutta       24-NOV-2003   Modified cursor c_active_cd to consider term records while
                                finding out the primary program of a student. Term Records Build.
*/

 cst_enrolled    CONSTANT        VARCHAR2(10) := 'ENROLLED';
 cst_inactive    CONSTANT        VARCHAR2(10) := 'INACTIVE';
 cst_discontin   CONSTANT        VARCHAR2(10) := 'DISCONTIN';
 cst_completed   CONSTANT        VARCHAR2(10) := 'COMPLETED';
 l_acad_cal_type                 igs_ca_inst.cal_type%TYPE;
 l_acad_ci_sequence_number       igs_ca_inst.sequence_number%TYPE;
 l_acad_ci_start_dt              igs_ca_inst.start_dt%TYPE;
 l_acad_ci_end_dt                igs_ca_inst.end_dt%TYPE;
 l_message_name                  VARCHAR2(100) := NULL;
 l_credit_points                 igs_en_su_attempt.override_achievable_cp%TYPE  := 0;
 l_tot_credit_points             igs_en_su_attempt.override_achievable_cp%TYPE  := 0;
 l_eftsu_total                   igs_en_su_attempt.override_eftsu%TYPE  := 0;
 l_alternate_code                igs_ca_inst.alternate_code%TYPE := NULL;
 l_course_cd                     igs_en_su_attempt.course_cd%TYPE;
 l_version_number                igs_en_su_attempt.version_number%TYPE;
 l_attendance_type               igs_en_atd_type_load.attendance_type%TYPE;

 CURSOR c_active_cd(l_career VARCHAR2) IS
        SELECT course_cd,
               igs_en_spa_terms_api.get_spat_program_version(p_person_id, course_cd,
               p_load_cal_type, p_load_seq_number)

        FROM igs_en_stdnt_ps_att sca
        WHERE person_id            = p_person_id AND
              --anilk, Bug# 3046897
              course_attempt_status IN (cst_enrolled, cst_inactive, cst_discontin, cst_completed) AND
              ((l_career            ='Y' AND
               (EXISTS (SELECT 'x' FROM igs_en_spa_terms spat
                        WHERE spat.person_id = sca.person_id
                        AND   spat.program_cd = sca.course_cd
                        AND   spat.term_cal_type = p_load_cal_type
                        AND   spat.term_sequence_number = p_load_seq_number)
                 OR
                (sca.primary_program_type='PRIMARY' AND
                 NOT EXISTS (SELECT 'x'
                            FROM igs_en_spa_terms spat, igs_ps_ver pv1, igs_ps_ver pv2
                            WHERE spat.person_id = sca.person_id
                            AND   spat.program_cd = pv1.course_cd
                            AND   spat.program_version = pv1.version_number
                            AND   sca.course_cd = pv2.course_cd
                            AND   sca.version_number = pv2.version_number
                            AND   pv1.course_type = pv2.course_type
                            AND   spat.term_cal_type = p_load_cal_type
                            AND   spat.term_sequence_number = p_load_seq_number)
                )
               )
              )OR
              (l_career            ='N'
              ));

 l_active_cd          c_active_cd%ROWTYPE;

BEGIN

--## First get the Key Programs  if it doesnot exists raise a error

l_course_cd  := enrp_clc_key_prog(p_person_id,l_version_number,p_load_cal_type,p_load_seq_number);
IF l_course_cd IS NULL THEN
  p_fte           := NULL;
  p_credit_points := NULL;
  p_attendance    := NULL;
  RETURN;
END IF;

--## Get the academic Calendar for the given load calendar
l_alternate_code:=  Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd
                             (
                             p_load_cal_type ,
                             p_load_seq_number,
                             l_acad_cal_type ,
                             l_acad_ci_sequence_number,
                             l_acad_ci_start_dt,
                             l_acad_ci_end_dt ,
                             l_message_name
                             );

--## If academic Calendar doesnot exists raise a error and stop the process
IF l_acad_cal_type IS NULL OR l_acad_ci_sequence_number IS NULL THEN
  p_fte           := NULL;
  p_credit_points := NULL;
  p_attendance    := NULL;
  RETURN;
END IF;

--## Check for the type of Model whether career centric or Program Centric
 IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N')='N' THEN
  OPEN c_active_cd('N');
  FETCH c_active_cd INTO l_active_cd;
  IF c_active_cd%NOTFOUND THEN
     close c_active_cd;
     p_fte           := NULL;
     p_credit_points := NULL;
     p_attendance    := NULL;
     RETURN;
  END IF;

 --## Loop thru all the Primary programs and get the total eftsu
  LOOP
    l_eftsu_total := l_eftsu_total +  ENRP_CLC_EFTSU_TOTAL
                                                (
                                                p_person_id ,
                                                l_active_cd.course_cd,
                                                l_acad_cal_type ,
                                                l_acad_ci_sequence_number,
                                                p_load_cal_type ,
                                                p_load_seq_number,
                                               'N',
                                               'N' ,
                                                l_course_cd ,
                                                l_version_number,
                                                l_credit_points
                                                );
   l_tot_credit_points := l_tot_credit_points + NVL(l_credit_points,0);
   FETCH c_active_cd INTO l_active_cd;
    IF c_active_cd%NOTFOUND THEN
       CLOSE c_active_cd;
       EXIT;
    END IF;
  END LOOP;
ELSE
 --##Incase of Career Centric check if Primary program is defined
  OPEN c_active_cd('Y');
  FETCH c_active_cd INTO l_active_cd;
  IF c_active_cd%NOTFOUND THEN
     close c_active_cd;
     p_fte           := NULL;
     p_credit_points := NULL;
     p_attendance    := NULL;
     RETURN;
  END IF;

  --## Loop through all the programs and get the eftsu total
  LOOP
    l_eftsu_total := l_eftsu_total + ENRP_CLC_EFTSU_TOTAL
                                                   (
                                                    p_person_id ,
                                                    l_active_cd.course_cd,
                                                    l_acad_cal_type ,
                                                    l_acad_ci_sequence_number,
                                                    p_load_cal_type ,
                                                    p_load_seq_number,
                                                   'N',
                                                   'N' ,
                                                    l_course_cd ,
                                                    l_version_number,
                                                    l_credit_points
                                                    );
   l_tot_credit_points := l_tot_credit_points + NVL(l_credit_points,0);
   FETCH c_active_cd INTO l_active_cd;
    IF c_active_cd%NOTFOUND THEN
       CLOSE c_active_cd;
       EXIT;
    END IF;
  END LOOP;
END IF;

  p_credit_points := l_tot_credit_points;
  p_fte           := l_eftsu_total;
  --## Get the the attendance type by passing the load caltype and fte
  l_attendance_type :=     ENRP_GET_LOAD_ATT  ( p_load_cal_type ,
                                                p_fte  );
   p_attendance    := l_attendance_type;

END enrp_get_inst_latt_fte;


PROCEDURE enrp_clc_cp_upto_tp_start_dt
                           (
                              p_person_id             IN  NUMBER,
                              p_load_cal_type         IN  VARCHAR2,
                              p_load_sequence_number  IN  NUMBER,
                              p_include_research_ind  IN  VARCHAR2,
                              p_tp_sd_cut_off_date    IN  DATE ,
                              p_credit_points         OUT NOCOPY NUMBER  )  AS
/**********************************************************************************************************************
  Created By   :    kkillams
  Creation Date:    09-MAY-2002
  Purpose      :    Bug No:2352142
                    Calculate Student's Total Credit Points with in a given load calendar when load calendar's teaching
                    calendar instances start dates are less than or equal to given cut off date (Point in time)
                    Note :This procedure is designed only for Career Model, will not work for ProgramCentric Model.
***********************************************************************************************************************/
/*   Who          When          What
     stutta       24-NOV-2003   Modified cursor cur_stud_ua_acad to consider term records while
                                finding out the primary program of a student. Term Records Build.
     ckasu      24-Feb-2006    Modified cur_stud_ua_acad curson in for perf bug #5059308
 */

--added by ckasu as a part of bug#5059308
--Fetches the Teach calendar details
CURSOR c_get_teach_cal_dtls(cp_load_cal_type igs_ca_inst.cal_type%TYPE,
                            cp_load_seq_num igs_ca_inst.sequence_number%TYPE,
                            cp_tp_sd_cut_off_date DATE) IS
SELECT teach_cal_type,
       teach_ci_sequence_number
FROM  IGS_CA_LOAD_TO_TEACH_V  lt
WHERE  lt.load_cal_type           = cp_load_cal_type
AND    lt.load_ci_sequence_number = cp_load_seq_num
AND    lt.teach_start_dt          <= cp_tp_sd_cut_off_date
ORDER BY teach_cal_type ASC,teach_ci_sequence_number ASC;

--modified by ckasu as a part of bug#5059308
CURSOR cur_stud_ua_acad(cp_teach_cal_type igs_ca_inst.cal_type%TYPE,
                        cp_teach_seq_num igs_ca_inst.sequence_number%TYPE) IS

                        SELECT   sua.person_id,
                                    sua.course_cd,
                                    sua.unit_cd,
                                    sua.version_number,
                                    sua.cal_type,
                                    sua.ci_sequence_number,
                                    sua.override_enrolled_cp,
                                    sua.override_eftsu,
                                    sua.administrative_unit_status,
                                    sua.unit_attempt_status,
                                    sua.discontinued_dt,
                                    sua.uoo_id,
                                    sua.no_assessment_ind
                            FROM    IGS_EN_SU_ATTEMPT sua,
                                    IGS_EN_STDNT_PS_ATT sca,
                                    IGS_PS_UNIT_VER uv
                           WHERE
                                   sca.person_id             = p_person_id   AND
                                   sca.person_id             = sua.person_id AND
                                   sca.course_cd             = sua.course_cd AND
                                   (   EXISTS (SELECT 'x' FROM igs_en_spa_terms spat
                                                WHERE spat.person_id = sca.person_id
                                                AND   spat.program_cd = sca.course_cd
                                                AND   spat.term_cal_type = p_load_cal_type
                                                AND   spat.term_sequence_number = p_load_sequence_number)
                                       OR
                                       (sca.primary_program_type='PRIMARY' AND
                                        NOT EXISTS (SELECT 'x'
                                                 FROM igs_en_spa_terms spat, igs_ps_ver pv1, igs_ps_ver pv2
                                                 WHERE spat.person_id = sca.person_id
                                                 AND   spat.program_cd = pv1.course_cd
                                                 AND   spat.program_version = pv1.version_number
                                                 AND   sca.course_cd = pv2.course_cd
                                                 AND   sca.version_number = pv2.version_number
                                                 AND   pv1.course_type = pv2.course_type
                                                 AND   spat.term_cal_type = p_load_cal_type
                                                 AND   spat.term_sequence_number = p_load_sequence_number)
                                       )
                                   )   AND
                                   sua.unit_attempt_status   IN ('ENROLLED','DISCONTIN','COMPLETED','WAITLISTED') AND
                                   uv.unit_cd                = sua.unit_cd   AND
                                   uv.version_number         = sua.version_number AND
                                  (NVL(p_include_research_ind,'N')= 'Y' OR  uv.research_unit_ind       = 'N') AND
                                   sua.cal_type  = cp_teach_cal_type AND
                                   sua.ci_sequence_number = cp_teach_seq_num;

lv_sua_cp                  NUMBER(10) := 0;
lv_return_eftsu            NUMBER(10);
l_audit_cp              IGS_PS_USEC_CPS.billing_credit_points%TYPE;
l_billing_cp            IGS_PS_USEC_CPS.billing_hrs%TYPE;
l_enrolled_cp   IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;
BEGIN
lv_sua_cp := 0;
FOR l_get_teach_cal_dtls IN c_get_teach_cal_dtls(p_load_cal_type,p_load_sequence_number,p_tp_sd_cut_off_date) LOOP

        FOR rec_stud_ua_acad IN cur_stud_ua_acad(l_get_teach_cal_dtls.teach_cal_type,l_get_teach_cal_dtls.teach_ci_sequence_number)
        LOOP
             IF enrp_get_load_incur(
                             rec_stud_ua_acad.cal_type,
                             rec_stud_ua_acad.ci_sequence_number,
                             rec_stud_ua_acad.discontinued_dt,
                             rec_stud_ua_acad.administrative_unit_status ,
                             rec_stud_ua_acad.unit_attempt_status,
                             rec_stud_ua_acad.no_assessment_ind,
                             p_load_cal_type,
                             p_load_sequence_number,
                             -- anilk, Audit special fee build
                             NULL, -- for p_uoo_id
                             'N') = 'Y' THEN

                    lv_sua_cp := lv_sua_cp + enrp_clc_sua_load(
                                                                rec_stud_ua_acad.unit_cd,
                                                                rec_stud_ua_acad.version_number,
                                                                rec_stud_ua_acad.cal_type,
                                                                rec_stud_ua_acad.ci_sequence_number,
                                                                p_load_cal_type,
                                                                p_load_sequence_number,
                                                                rec_stud_ua_acad.override_enrolled_cp,
                                                                rec_stud_ua_acad.override_eftsu,
                                                                lv_return_eftsu,
                                                                rec_stud_ua_acad.uoo_id,
                                                                -- anilk, Audit special fee build
                                                                'N',
                                                                l_audit_cp,
                                                                l_billing_cp,
                                                                l_enrolled_cp);
            END IF;
        END LOOP;
END LOOP;-- end loop for l_get_teach_cal_dtls
p_credit_points := lv_sua_cp;

END enrp_clc_cp_upto_tp_start_dt;

FUNCTION  enrp_get_prg_att_type
                           (
                              p_person_id             IN  NUMBER,
                              p_course_cd             IN  VARCHAR2,
                              p_cal_type              IN  VARCHAR2,
                              p_sequence_number       IN  NUMBER
                           ) RETURN VARCHAR2 AS
/**********************************************************************************************************************
  Created By   :    msrinivi
  Creation Date:    28-Oct-2002
  Purpose      :    Order Documents Build
                    Attendance type for a student, course and academic or load calendar
***********************************************************************************************************************/
CURSOR c_cal_cat IS
SELECT  S_CAL_CAT
FROM    igs_ca_type
WHERE   cal_type = p_cal_type;

l_cal_cat igs_ca_type.s_cal_cat%TYPE;

l_load_cal_type   igs_ca_inst.cal_type%TYPE;
l_load_ci_seq_num igs_ca_inst.sequence_number%TYPE;

l_acad_cal_type   igs_ca_inst.cal_type%TYPE;
l_acad_ci_seq_num igs_ca_inst.sequence_number%TYPE;

l_acad_ci_start_dt DATE;
l_acad_ci_end_dt DATE;
l_message_name     VARCHAR2(1000);


l_course_cd       igs_ps_ver.course_cd%TYPE;
l_version_number   igs_ps_ver.version_number%TYPE;

l_credit_points NUMBER :=0;

l_eftsu_total   NUMBER :=0;

l_attendance_type IGS_EN_ATD_TYPE_ALL.ATTENDANCE_TYPE%TYPE;

lRet_for_cal VARCHAR2(100);

BEGIN



OPEN  c_cal_cat;
FETCH c_cal_cat INTO l_cal_cat;
CLOSE c_cal_cat;

IF l_cal_cat = 'ACADEMIC' THEN
  l_acad_cal_type    :=  p_cal_type         ;
  l_acad_ci_seq_num  :=  p_sequence_number  ;

  get_latest_load_for_acad_cal(
  p_acad_cal_type           => p_cal_type       ,
  p_acad_ci_sequence_number => p_sequence_number,
  p_load_cal_type           => l_load_cal_type ,
  p_load_ci_sequence_number => l_load_ci_seq_num
  );


END IF;

IF l_cal_cat = 'LOAD' THEN

  l_load_cal_type   :=   p_cal_type         ;
  l_load_ci_seq_num :=   p_sequence_number  ;

lRet_for_cal := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd
         (
         p_cal_type         ,
         p_sequence_number  ,
         l_acad_cal_type    ,
         l_acad_ci_seq_num   ,
         l_acad_ci_start_dt,
         l_acad_ci_end_dt ,
         l_message_name
         );
END IF;
l_course_cd  := enrp_clc_key_prog(p_person_id,l_version_number,l_load_cal_type
                                                ,l_load_ci_seq_num );

    l_eftsu_total := l_eftsu_total + ENRP_CLC_EFTSU_TOTAL
                                                   (
                                                    p_person_id ,
                                                    p_course_cd,
                                                    l_acad_cal_type    ,
                                                    l_acad_ci_seq_num    ,
                            l_load_cal_type ,
                            l_load_ci_seq_num ,
                                                   'N',
                                                   'N' ,
                                                    l_course_cd ,
                                                    l_version_number,
                                                    l_credit_points
                                                    );

  --## Get the the attendance type by passing the load caltype and fte

  l_attendance_type :=     ENRP_GET_LOAD_ATT
                                (
                                  l_load_cal_type ,
                                  l_eftsu_total
                                );
RETURN l_attendance_type;

END enrp_get_prg_att_type;


PROCEDURE get_latest_load_for_acad_cal
(
  p_acad_cal_type      IN igs_ca_inst.cal_type%TYPE,
  p_acad_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
  p_load_cal_type      OUT NOCOPY  igs_ca_inst.cal_type%TYPE,
  p_load_ci_sequence_number OUT NOCOPY igs_ca_inst.sequence_number%TYPE
 )
 AS
/**********************************************************************************************************************
  Created By   :    msrinivi
  Creation Date:    28-Oct-2002
  Purpose      :    Order Documents Build
                    Fetches the latest load under the given given academic calendar
***********************************************************************************************************************/
CURSOR c_latest_load IS
SELECT rel.SUB_CAL_TYPE    , rel.SUB_CI_SEQUENCE_NUMBER , NVL(dai.absolute_val, cai.start_dt) load_effective_dt
FROM  igs_ca_inst_rel rel,
      igs_ca_da_inst dai,
      igs_en_cal_conf conf,
      igs_ca_inst cai
WHERE
    rel.SUB_CAL_TYPE           =     dai.CAL_TYPE
AND rel.SUB_CI_SEQUENCE_NUMBER =     dai.CI_SEQUENCE_NUMBER
AND cai.CAL_TYPE               =     rel.SUB_CAL_TYPE
AND cai.SEQUENCE_NUMBER        =     rel.SUB_CI_SEQUENCE_NUMBER
AND dai.DT_ALIAS               =     conf.LOAD_EFFECT_DT_ALIAS
AND NVL(dai.absolute_val, cai.start_dt)         < SYSDATE
AND SUP_CAL_TYPE               =     p_acad_cal_type
AND SUP_CI_SEQUENCE_NUMBER     =     p_acad_ci_sequence_number
ORDER BY 3 DESC;

l_load_cal_type igs_ca_inst.cal_type%TYPE;
l_load_ci_sequence_number   igs_ca_inst.sequence_number%TYPE ;
l_load_effective_dt DATE;

 BEGIN

OPEN  c_latest_load;
FETCH c_latest_load INTO l_load_cal_type, l_load_ci_sequence_number,l_load_effective_dt;
CLOSE c_latest_load;

p_load_cal_type           :=  l_load_cal_type;
p_load_ci_sequence_number :=  l_load_ci_sequence_number;

END get_latest_load_for_acad_cal;

FUNCTION enrp_get_prg_load_cp(p_person_id             IN  NUMBER,
                              p_course_cd             IN VARCHAR2,
                              p_cal_type              IN  VARCHAR2,
                              p_sequence_number       IN  NUMBER) RETURN VARCHAR2 AS

/**********************************************************************************************************************
  Created By   :    svanukur
  Creation Date:    2-dec-2005
  Purpose      :    wrapper over enrp_get_prg_eftsu_cp to get the CP for a student for a given term and program
***********************************************************************************************************************/
L_EFTSU_TOTAL  NUMBER := 0;
L_CREDIT_POINTS NUMBER := 0;

begin

enrp_get_prg_eftsu_cp(
                              p_person_id            ,
                              p_course_cd             ,
                              p_cal_type             ,
                              p_sequence_number       ,
                              L_EFTSU_TOTAL           ,
                              L_CREDIT_POINTS         );
return L_CREDIT_POINTS;
exception
when others then
return null;

end;


PROCEDURE enrp_get_prg_eftsu_cp
                           (
                              p_person_id             IN  NUMBER,
                              p_course_cd             IN VARCHAR2,
                              p_cal_type              IN  VARCHAR2,
                              p_sequence_number       IN  NUMBER,
                              P_EFTSU_TOTAL           OUT NOCOPY NUMBER,
                              P_CREDIT_POINTS         OUT NOCOPY NUMBER
                           ) AS
/**********************************************************************************************************************
  Created By   :    amuthu
  Creation Date:    14-NOV-2002
  Purpose      :    SS Worksheet Redesign
***********************************************************************************************************************/
CURSOR c_cal_cat IS
SELECT  S_CAL_CAT
FROM    igs_ca_type
WHERE   cal_type = p_cal_type;

l_cal_cat igs_ca_type.s_cal_cat%TYPE;
l_load_cal_type   igs_ca_inst.cal_type%TYPE;
l_load_ci_seq_num igs_ca_inst.sequence_number%TYPE;
l_acad_cal_type   igs_ca_inst.cal_type%TYPE;
l_acad_ci_seq_num igs_ca_inst.sequence_number%TYPE;
l_acad_ci_start_dt DATE;
l_acad_ci_end_dt DATE;
lRet_for_cal VARCHAR2(100);

l_message_name     VARCHAR2(1000);

l_course_cd       igs_ps_ver.course_cd%TYPE;
l_version_number   igs_ps_ver.version_number%TYPE;


BEGIN



OPEN  c_cal_cat;
FETCH c_cal_cat INTO l_cal_cat;
CLOSE c_cal_cat;

-- if the passed in calendar is academic the determine the load calendar
IF l_cal_cat = 'ACADEMIC' THEN
  l_acad_cal_type    :=  p_cal_type         ;
  l_acad_ci_seq_num  :=  p_sequence_number  ;

  get_latest_load_for_acad_cal(
  p_acad_cal_type           => p_cal_type       ,
  p_acad_ci_sequence_number => p_sequence_number,
  p_load_cal_type           => l_load_cal_type ,
  p_load_ci_sequence_number => l_load_ci_seq_num
  );


END IF;

-- if the passed in calendar is load calendar then find the Academic calendar
IF l_cal_cat = 'LOAD' THEN

  l_load_cal_type   :=   p_cal_type         ;
  l_load_ci_seq_num :=   p_sequence_number  ;

lRet_for_cal := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd
         (
         p_cal_type         ,
         p_sequence_number  ,
         l_acad_cal_type    ,
         l_acad_ci_seq_num   ,
         l_acad_ci_start_dt,
         l_acad_ci_end_dt ,
         l_message_name
         );
END IF;

l_course_cd  := enrp_clc_key_prog(p_person_id,l_version_number,l_load_cal_type ,
                                                       l_load_ci_seq_num);

-- calculate the total EFTSU and Credit Points by making a call to ENRP_CLC_EFTSU_TOTAL

    P_EFTSU_TOTAL :=ENRP_CLC_EFTSU_TOTAL
                      (
                       p_person_id ,
                       p_course_cd,
                       l_acad_cal_type    ,
                       l_acad_ci_seq_num    ,
                       l_load_cal_type ,
                       l_load_ci_seq_num ,
                       'N',
                       'N' ,
                       l_course_cd ,
                       l_version_number,
                       P_CREDIT_POINTS
                       );



  END enrp_get_prg_eftsu_cp;

-- Function to calculate the Institutional Level Attendance Type

FUNCTION enrp_get_inst_attendance(
                          p_person_id        IN  hz_parties.party_id%TYPE,
                          p_load_cal_type    IN  igs_ca_inst.cal_type%TYPE,
                          p_load_seq_number  IN  igs_ca_inst.sequence_number%TYPE
                          ) RETURN VARCHAR2 AS

 l_attendance    igs_en_atd_type_load.attendance_type%TYPE;
 l_credit_points igs_en_su_attempt.override_achievable_cp%TYPE;
 l_fte           igs_en_su_attempt.override_achievable_cp%TYPE;

BEGIN

enrp_get_inst_latt(p_person_id      => p_person_id ,
                 p_load_cal_type    => p_load_cal_type,
                 p_load_seq_number  => p_load_seq_number,
                 p_attendance       => l_attendance,
                 p_credit_points    => l_credit_points,
                 p_fte              => l_fte
                );

  RETURN l_attendance;

EXCEPTION
  WHEN OTHERS THEN
  -- Supressing any exception raised and returning NULL, as this function is called from a View
    RETURN NULL;

END enrp_get_inst_attendance;

-- Function to calculate the Institutional Level Attendance Type
FUNCTION enrp_get_inst_cp(
                          p_person_id                  IN  hz_parties.party_id%TYPE,
                          p_load_cal_type              IN  igs_ca_inst.cal_type%TYPE,
                          p_load_seq_number            IN  igs_ca_inst.sequence_number%TYPE
                          ) RETURN VARCHAR2 AS

 l_attendance    igs_en_atd_type_load.attendance_type%TYPE;
 l_credit_points igs_en_su_attempt.override_achievable_cp%TYPE;
 l_fte           igs_en_su_attempt.override_achievable_cp%TYPE;

BEGIN

enrp_get_inst_latt(p_person_id      => p_person_id ,
                 p_load_cal_type    => p_load_cal_type,
                 p_load_seq_number  => p_load_seq_number,
                 p_attendance       => l_attendance,
                 p_credit_points    => l_credit_points,
                 p_fte              => l_fte
                );

  RETURN l_credit_points;

EXCEPTION
  WHEN OTHERS THEN
  -- Supressing any exception raised and returning NULL, as this function is called from a View
    RETURN NULL;

END enrp_get_inst_cp;

-- get_term_credits: Gets the total credits for the given person, program and term.
FUNCTION get_term_credits ( p_n_person_id IN NUMBER,
                            p_c_program IN VARCHAR2,
                            p_c_load_cal IN VARCHAR2,
                            p_n_load_seq_num IN NUMBER,
			    p_c_acad_cal IN VARCHAR2,
			    p_c_acad_seq_num IN NUMBER)
RETURN NUMBER IS

    CURSOR c_total_swap_credits ( cp_n_perosn_id IN NUMBER,
                                  cp_c_program IN VARCHAR2,
				  cp_c_load_cal IN VARCHAR2,
				  cp_n_load_seq_num IN NUMBER) IS
    SELECT NVL(SUM(igs_ss_enr_details.get_apor_credits ( uoo_id, override_enrolled_cp,ca.load_cal_type,ca.load_ci_sequence_number)),0) apor_cp
    FROM   IGS_EN_SU_ATTEMPT sua,
           IGS_CA_TEACH_TO_LOAD_V ca
    WHERE  sua.unit_attempt_status = 'UNCONFIRM'
    AND    sua.person_id = cp_n_perosn_id
    AND    sua.course_cd = cp_c_program
    AND    sua.ss_source_ind = 'S'
    AND    sua.cal_type = ca.teach_cal_type
    AND    sua.ci_sequence_number = ca.teach_ci_sequence_number
    AND    ca.load_cal_type = cp_c_load_cal
    AND    ca.load_ci_sequence_number = cp_n_load_seq_num;

  l_n_schd_credits NUMBER; -- Total aportioned credits for given person and term in an academic year
  l_n_credits NUMBER;      -- Total aportioned credit

BEGIN

   -- Getting total aportioned credits for a student in a term (Schedule credits for this term for the student).
   l_n_schd_credits := enrp_clc_load_total(p_person_id => p_n_person_id,
                                           p_course_cd => p_c_program,
                                           p_acad_cal_type => p_c_acad_cal,
                                           p_acad_sequence_number => p_c_acad_seq_num,
                                           p_load_cal_type => p_c_load_cal,
                                           p_load_sequence_number => p_n_load_seq_num);

   -- Getting total aportioned credits for the unit section added as a part of Swap.
   OPEN c_total_swap_credits ( p_n_person_id, p_c_program, p_c_load_cal, p_n_load_seq_num);
   FETCH c_total_swap_credits INTO l_n_credits;
   CLOSE c_total_swap_credits;

   RETURN  NVL(l_n_schd_credits,0) + NVL(l_n_credits,0);

END get_term_credits;


END Igs_En_Prc_Load;

/
