--------------------------------------------------------
--  DDL for Package Body IGS_RE_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_GEN_002" AS
/* $Header: IGSRE02B.pls 120.1 2005/11/24 04:34:42 appldev ship $ */
/*******************************************************************************
Created by  :
Date created:

Known limitations/enhancements/remarks:

Change History: (who, when, what)
Who		When		What
sarakshi        02-Sep-2004     Bug#3815825, modified procedure RESP_GET_RSUP_START to add one else condition.
vkarthik        26-Apr-2004     Changed function resp_ins_dflt_mil for EN303 Milestone build Enh#3577974
rnirwani   13-Sep-2004    changed cursor c_intmsn_details  to not consider logically deleted records and
			also to avoid un-approved intermission records. Bug# 3885804
*******************************************************************************/

PROCEDURE resp_get_ca_exists(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_check_thesis IN BOOLEAN ,
  p_check_field_of_study IN BOOLEAN ,
  p_check_seo_class_cd IN BOOLEAN ,
  p_check_supervisor IN BOOLEAN ,
  p_check_milestone IN BOOLEAN ,
  p_check_scholarship IN BOOLEAN ,
  p_thesis_exists OUT NOCOPY BOOLEAN ,
  p_field_of_study_exists OUT NOCOPY BOOLEAN ,
  p_seo_class_cd_exists OUT NOCOPY BOOLEAN ,
  p_supervisor_exists OUT NOCOPY BOOLEAN ,
  p_milestone_exists OUT NOCOPY BOOLEAN ,
  p_scholarship_exists OUT NOCOPY BOOLEAN )
AS
BEGIN	-- resp_get_ca_exists
	-- Description: This module returns output parameters indicating whether
	-- or not data exists on IGS_RE_CANDIDATURE detail tables for the specified
	-- IGS_RE_CANDIDATURE.person_id /sequence_number.
DECLARE
	v_the_dummy_rec			VARCHAR2(1);
	v_cafos_dummy_rec		VARCHAR2(1);
	v_csc_dummy_rec			VARCHAR2(1);
	v_rsup_dummy_rec		VARCHAR2(1);
	v_mil_dummy_rec			VARCHAR2(1);
	v_sch_dummy_rec			VARCHAR2(1);
	CURSOR	c_the IS
		SELECT 	'X'
		FROM	IGS_RE_THESIS			the
		WHERE	the.person_id 		= p_person_id AND
			the.ca_sequence_number	= p_ca_sequence_number AND
			the.logical_delete_dt IS NULL;
	CURSOR	c_cafos IS
		SELECT 	'X'
		FROM	IGS_RE_CDT_FLD_OF_SY	 cafos
		WHERE	cafos.person_id		 = p_person_id AND
			cafos.ca_sequence_number = p_ca_sequence_number;
	CURSOR	c_csc IS
		SELECT	'X'
		FROM	IGS_RE_CAND_SEO_CLS		csc
		WHERE	csc.person_id		= p_person_id AND
			csc.ca_sequence_number	= p_ca_sequence_number;
	CURSOR	c_rsup IS
		SELECT	'X'
		FROM	IGS_RE_SPRVSR	rsup
		WHERE	rsup.ca_person_id		= p_person_id AND
			rsup.ca_sequence_number = p_ca_sequence_number AND
			rsup.start_dt		<= p_effective_dt AND
			NVL(rsup.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01')) >= p_effective_dt;
	CURSOR	c_mil IS
		SELECT	'X'
		FROM	IGS_PR_MILESTONE 		mil
		WHERE	mil.person_id		= p_person_id AND
			mil.ca_sequence_number 	= p_ca_sequence_number;
	CURSOR	c_sch IS
		SELECT	'X'
		FROM	IGS_RE_SCHOLARSHIP		sch
		WHERE	sch.person_id		= p_person_id AND
			sch.ca_sequence_number	= p_ca_sequence_number AND
			sch.start_dt		<= p_effective_dt AND
			NVL(sch.end_dt, IGS_GE_DATE.IGSDATE('9999/01/01')) >= p_effective_dt;
BEGIN
	p_thesis_exists := FALSE;
	p_field_of_study_exists := FALSE;
	p_seo_class_cd_exists := FALSE;
	p_supervisor_exists := FALSE;
	p_milestone_exists := FALSE;
	p_scholarship_exists := FALSE;
	IF p_check_thesis THEN
		--Validate for the existence of IGS_RE_THESIS details
		OPEN c_the;
		FETCH c_the INTO v_the_dummy_rec;
		IF (c_the%FOUND) THEN
			CLOSE c_the;
			p_thesis_exists := TRUE;
		ELSE
			CLOSE c_the;
		END IF;
	END IF;
	IF p_check_field_of_study THEN
		--Validate for existence of IGS_RE_CANDIDATURE field of study
		OPEN c_cafos;
		FETCH c_cafos INTO v_cafos_dummy_rec;
		IF (c_cafos%FOUND) THEN
			CLOSE c_cafos;
			p_field_of_study_exists := TRUE;
		ELSE
			CLOSE c_cafos;
		END IF;
	END IF;
	IF p_check_seo_class_cd THEN
		--Validate for existence of IGS_RE_CANDIDATURE socio-economic classification code
		OPEN c_csc;
		FETCH c_csc INTO v_csc_dummy_rec;
		IF (c_csc%FOUND) THEN
			CLOSE c_csc;
			p_seo_class_cd_exists := TRUE;
		ELSE
			CLOSE c_csc;
		END IF;
	END IF;
	IF p_check_supervisor THEN
		--Validate for existence of research supervisor
		OPEN c_rsup;
		FETCH c_rsup INTO v_rsup_dummy_rec;
		IF (c_rsup%FOUND) THEN
			CLOSE c_rsup;
			p_supervisor_exists := TRUE;
		ELSE
			CLOSE c_rsup;
		END IF;
	END IF;
	IF p_check_milestone THEN
		--Validate for existence of research IGS_RE_CANDIDATURE milestones
		OPEN c_mil;
		FETCH c_mil INTO v_mil_dummy_rec;
		IF (c_mil%FOUND) THEN
			CLOSE c_mil;
			p_milestone_exists := TRUE;
		ELSE
			CLOSE c_mil;
		END IF;
	END IF;
	IF p_check_scholarship THEN
		--Validate for existence of research IGS_RE_CANDIDATURE IGS_RE_SCHOLARSHIP
		OPEN c_sch;
		FETCH c_sch INTO v_sch_dummy_rec;
		IF (c_sch%FOUND) THEN
			CLOSE c_sch;
			p_scholarship_exists := TRUE;
		ELSE
			CLOSE c_sch;
		END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
	IF (c_the%ISOPEN) THEN
		CLOSE c_the;
	END IF;
	IF (c_cafos%ISOPEN) THEN
		CLOSE c_cafos;
	END IF;
	IF (c_csc%ISOPEN) THEN
		CLOSE c_csc;
	END IF;
	IF (c_rsup%ISOPEN) THEN
		CLOSE c_rsup;
	END IF;
	IF (c_mil%ISOPEN) THEN
		CLOSE c_mil;
	END IF;
	IF (c_sch%ISOPEN) THEN
		CLOSE c_sch;
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END resp_get_ca_exists;


FUNCTION resp_get_rsup_start(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_parent IN VARCHAR2 )
RETURN DATE AS
BEGIN	-- resp_get_rsup_start
	-- This module gets the date that supervision is required from for a
	-- IGS_RE_CANDIDATURE.
DECLARE
	cst_sca				CONSTANT VARCHAR2(10) := 'SCA';
	cst_acai			CONSTANT VARCHAR2(10) := 'ACAI';
	cst_rsup			CONSTANT VARCHAR2(10) := 'RSUP';
	v_start_dt			DATE;
	v_research_type_ind		VARCHAR2(1) DEFAULT 'N';
	v_s_adm_outcome_status		IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;
	v_s_admission_process_type	IGS_AD_APPL.s_admission_process_type%TYPE;
	v_research_unit_start_dt	DATE;
	CURSOR	c_ca IS
		SELECT	ca.sca_course_cd,
			ca.acai_admission_appl_number,
			ca.acai_nominated_course_cd,
			ca.acai_sequence_number
		FROM	IGS_RE_CANDIDATURE	ca
		WHERE	ca.person_id		= p_person_id AND
			ca.sequence_number	= p_ca_sequence_number;
	v_ca_rec			c_ca%ROWTYPE;
	CURSOR c_sca(
		cp_course_cd	IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
	IS
		SELECT	sca.course_attempt_status,
			sca.version_number,
			sca.commencement_dt
		FROM	IGS_EN_STDNT_PS_ATT	sca
		WHERE	sca.person_id	= p_person_id AND
			sca.course_cd	= cp_course_cd;
	v_sca_rec			c_sca%ROWTYPE;
	v_sca_rec1			c_sca%ROWTYPE;
	CURSOR c_acai(
		cp_adm_appl_number	IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE,
		cp_nom_course_cd	IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE,
		cp_sequence_number	IGS_RE_CANDIDATURE.acai_sequence_number%TYPE)
	IS
		SELECT	acai.course_cd,
			acai.crv_version_number,
			acai.adm_outcome_status,
			acai.prpsd_commencement_dt
		FROM	IGS_AD_PS_APPL_INST	acai
		WHERE	acai.person_id			= p_person_id AND
			acai.admission_appl_number	= cp_adm_appl_number AND
			acai.nominated_course_cd	= cp_nom_course_cd AND
			acai.sequence_number		= cp_sequence_number;
	v_acai_rec			c_acai%ROWTYPE;
	CURSOR	c_apcs (
			cp_adm_appl_num	IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE)
	IS
		SELECT	aa.s_admission_process_type
		FROM	IGS_AD_APPL		aa,
			IGS_AD_PRCS_CAT_STEP	apcs
		WHERE	aa.person_id			= p_person_id AND
			aa.admission_appl_number	= cp_adm_appl_num AND
			aa.admission_cat		= apcs.admission_cat AND
			aa.s_admission_process_type	=
						apcs.s_admission_process_type AND
			apcs.s_admission_step_type	= 'RESEARCH' AND
			apcs.mandatory_step_ind		= 'Y' AND
			apcs.step_group_type <> 'TRACK'; --2402377
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	-- Local procedure used to get the research IGS_PS_COURSE type.
	PROCEDURE respl_get_rsch_cty (
		p_course_cd			IGS_PS_VER.course_cd%TYPE,
		p_version_number		IGS_PS_VER.version_number%TYPE,
		p_research_type_ind	OUT NOCOPY	VARCHAR2)
	AS
	BEGIN	-- respl_get_rsch_cty
		-- Determine if IGS_PS_COURSE version is a research IGS_PS_COURSE type,
		-- this impliessupervision is required from IGS_PS_COURSE
		-- commencement date.
	DECLARE
		CURSOR c_crv IS
			SELECT	cty.research_type_ind
			FROM	IGS_PS_VER	crv,
				IGS_PS_TYPE	cty
			WHERE	crv.course_cd		= p_course_cd AND
				crv.version_number	= p_version_number AND
				crv.course_type		= cty.course_type;
	BEGIN
		p_research_type_ind := NULL;
		OPEN c_crv;
		FETCH c_crv INTO p_research_type_ind;
		CLOSE c_crv;
	EXCEPTION
		WHEN OTHERS THEN
			IF c_crv%ISOPEN THEN
				CLOSE c_crv;
			END IF;
			RAISE;
	END;
	END respl_get_rsch_cty;
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	-- Local function used to set start date to earliest research IGS_PS_UNIT enrolment

	FUNCTION respl_get_rsch_enrlmnt (
		p_person_id	IGS_EN_SU_ATTEMPT.person_id%TYPE,
		p_course_cd	IGS_EN_SU_ATTEMPT.course_cd%TYPE)
	RETURN DATE AS
	BEGIN 	-- respl_get_rsch_enrlmnt
		-- Set the start date to earliest research IGS_PS_UNIT enrolment.
	DECLARE
		v_start_dt			DATE;
		v_end_dt			DATE;
		v_research_unit_start_dt	DATE;
		v_teach_days			NUMBER;
		CURSOR c_sua IS
			SELECT	sua.cal_type,
				sua.ci_sequence_number
			FROM	IGS_EN_SU_ATTEMPT	sua,
				IGS_PS_UNIT_VER		uv
			WHERE	sua.person_id		= p_person_id AND
				sua.course_cd		= p_course_cd AND
				sua.unit_cd		= uv.unit_cd AND
				sua.version_number	= uv.version_number AND
				uv.research_unit_ind	= 'Y' AND
				sua.unit_attempt_status	IN (
							'ENROLLED',
							'COMPLETED',
							'DISCONTIN');
		BEGIN
			v_research_unit_start_dt := NULL;
			FOR v_sua_rec IN c_sua LOOP
				v_teach_days := resp_get_teach_days(
					v_sua_rec.cal_type,
					v_sua_rec.ci_sequence_number,
					v_start_dt,
					v_end_dt);
				IF v_research_unit_start_dt IS NULL OR
					v_research_unit_start_dt >= v_start_dt THEN
					v_research_unit_start_dt := v_start_dt;
				END IF;
			END LOOP;
			RETURN v_research_unit_start_dt;
			EXCEPTION
				WHEN OTHERS THEN
					IF c_sua%ISOPEN THEN
						CLOSE c_sua;
					END IF;
					RAISE;
		END;
	END respl_get_rsch_enrlmnt;
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
BEGIN -- main routine.
	IF p_parent = cst_rsup OR
			(p_sca_course_cd IS NULL AND
			(p_acai_admission_appl_number IS NULL OR
			p_acai_nominated_course_cd IS NULL OR
			p_acai_sequence_number IS NULL)) THEN
		OPEN c_ca;
		FETCH c_ca INTO v_ca_rec;
		IF c_ca%NOTFOUND THEN
			-- Something is wrong, handled elsewhere.
			CLOSE c_ca;
			RETURN IGS_GE_DATE.IGSDATE(NULL);
		END IF;
		CLOSE c_ca;
	ELSE
		v_ca_rec.sca_course_cd := p_sca_course_cd;
		v_ca_rec.acai_admission_appl_number := p_acai_admission_appl_number;
		v_ca_rec.acai_nominated_course_cd := p_acai_nominated_course_cd;
		v_ca_rec.acai_sequence_number := p_acai_sequence_number;
	END IF;
	IF v_ca_rec.acai_admission_appl_number IS NULL AND
			v_ca_rec.acai_nominated_course_cd IS NULL AND
			v_ca_rec.acai_sequence_number IS NULL THEN
		-- IGS_RE_CANDIDATURE has been added through ENRF3000.
		OPEN c_sca(v_ca_rec.sca_course_cd);
		FETCH c_sca INTO v_sca_rec;
		IF c_sca%NOTFOUND THEN
			CLOSE c_sca;
			RETURN IGS_GE_DATE.IGSDATE(NULL);
		END IF;
		CLOSE c_sca;
		IF v_sca_rec.course_attempt_status = 'UNCONFIRM' THEN
			-- There is no start date requirement for
			-- the IGS_RE_CANDIDATURE.
			RETURN IGS_GE_DATE.IGSDATE(NULL);
		ELSE
			-- Get research IGS_PS_COURSE type
			respl_get_rsch_cty (
				v_ca_rec.sca_course_cd,
				v_sca_rec.version_number,
				v_research_type_ind);
			IF v_research_type_ind = 'Y' THEN
				-- Set start date to
				-- IGS_EN_STDNT_PS_ATT.commencement_dt
				RETURN v_sca_rec.commencement_dt;
			ELSE
				-- Set start date to earliest research IGS_PS_UNIT
				-- enrolment.
				v_research_unit_start_dt := respl_get_rsch_enrlmnt(
								p_person_id,
								v_ca_rec.sca_course_cd);
				RETURN v_research_unit_start_dt;
			END IF;
		END IF;
	ELSE
		OPEN c_acai(
			v_ca_rec.acai_admission_appl_number,
			v_ca_rec.acai_nominated_course_cd,
			v_ca_rec.acai_sequence_number);
		FETCH c_acai INTO v_acai_rec;
		IF c_acai%NOTFOUND THEN
			CLOSE c_acai;
			RETURN IGS_GE_DATE.IGSDATE(NULL);
		END IF;
		CLOSE c_acai;
		v_s_adm_outcome_status := IGS_AD_GEN_008.admp_get_saos (
					v_acai_rec.adm_outcome_status);
		IF v_s_adm_outcome_status IN ('OFFER','COND-OFFER') OR
				p_parent = cst_acai THEN

              			respl_get_rsch_cty (
				v_acai_rec.course_cd,
				v_acai_rec.crv_version_number,
				v_research_type_ind);
			IF v_research_type_ind = 'N' THEN
				-- Determine if research is a mandatory step
				OPEN c_apcs (
					v_ca_rec.acai_admission_appl_number);
				FETCH c_apcs INTO v_s_admission_process_type;
				IF c_apcs%FOUND AND
					v_s_admission_process_type <> 'RE-ADMIT' THEN
					CLOSE c_apcs;

				        --If program attempt exists then starts date should be compared against the program attempt start date
                                        --else proposed commencement date of application instance should be taken into consideration
				        --This validation is added as a  part of bug#3815825.
             		                OPEN c_sca(v_ca_rec.sca_course_cd);
	        	                FETCH c_sca INTO v_sca_rec1;
		                        IF c_sca%FOUND THEN
			                  CLOSE c_sca;
			                  RETURN v_sca_rec1.commencement_dt;
		                        END IF;
		                        CLOSE c_sca;

					IF v_acai_rec.prpsd_commencement_dt IS NULL THEN
						v_sca_rec.commencement_dt :=
							IGS_EN_GEN_002.enrp_get_acad_comm (
								NULL,
								NULL,
								p_person_id,
								v_acai_rec.course_cd,
								v_ca_rec.acai_admission_appl_number,
								v_ca_rec.acai_nominated_course_cd,
								v_ca_rec.acai_sequence_number,
								'N');
					ELSE
						v_sca_rec.commencement_dt :=
							v_acai_rec.prpsd_commencement_dt;
					END IF;
					RETURN v_sca_rec.commencement_dt;
				ELSE
					IF c_apcs%NOTFOUND THEN
						CLOSE c_apcs;
					END IF;
					v_research_unit_start_dt := respl_get_rsch_enrlmnt(
									p_person_id,
									v_acai_rec.course_cd);
					RETURN v_research_unit_start_dt;
				END IF;
			ELSE
				--If program attempt exists then starts date should be compared against the program attempt start date
                                --else proposed commencement date of application instance should be taken into consideration
				--This validation is added as a  part of bug#3815825.
        		        OPEN c_sca(v_ca_rec.sca_course_cd);
        	                FETCH c_sca INTO v_sca_rec1;
	                        IF c_sca%FOUND THEN
		                  CLOSE c_sca;
		                  RETURN v_sca_rec1.commencement_dt;
	                        END IF;
	                        CLOSE c_sca;

				IF v_acai_rec.prpsd_commencement_dt IS NULL THEN
					v_sca_rec.commencement_dt :=
						IGS_EN_GEN_002.enrp_get_acad_comm (
							NULL,
							NULL,
							p_person_id,
							v_acai_rec.course_cd,
							v_ca_rec.acai_admission_appl_number,
							v_ca_rec.acai_nominated_course_cd,
							v_ca_rec.acai_sequence_number,
							'N');
				ELSE
					v_sca_rec.commencement_dt :=
						v_acai_rec.prpsd_commencement_dt;
				END IF;
				RETURN v_sca_rec.commencement_dt;
			END IF;
		ELSE
			-- There is no start date requirement yet.
			RETURN IGS_GE_DATE.IGSDATE(NULL);
		END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF c_ca%ISOPEN THEN
			CLOSE c_ca;
		END IF;
		IF c_sca%ISOPEN THEN
			CLOSE c_sca;
		END IF;
		IF c_acai%ISOPEN THEN
			CLOSE c_acai;
		END IF;
		IF c_apcs%ISOPEN THEN
			CLOSE c_apcs;
		END IF;
		RAISE;
END;
END resp_get_rsup_start;


PROCEDURE resp_get_sca_ca_acai(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_out_admission_appl_number OUT NOCOPY NUMBER ,
  p_out_nominated_course_cd OUT NOCOPY VARCHAR2 ,
  p_out_acai_sequence_number OUT NOCOPY NUMBER )
AS
BEGIN	-- resp_get_sca_ca_acai
	-- Return the admission IGS_PS_COURSE application instance to be used for
	-- the reasearch IGS_RE_CANDIDATURE.
DECLARE
	CURSOR	c_sca IS
		SELECT	sca.adm_admission_appl_number,
			sca.adm_nominated_course_cd,
			sca.adm_sequence_number
		FROM	IGS_EN_STDNT_PS_ATT	sca,
			IGS_RE_CANDIDATURE		ca
		WHERE	sca.person_id		= p_person_id AND
			sca.course_cd		= p_course_cd AND
			ca.person_id		= sca.person_id AND
			ca.sca_course_cd	= sca.course_cd;
	v_sca_rec		c_sca%ROWTYPE;
BEGIN
	OPEN c_sca;
	FETCH c_sca INTO v_sca_rec;
	IF c_sca%FOUND THEN
		CLOSE c_sca;
		p_out_admission_appl_number := v_sca_rec.adm_admission_appl_number;
		p_out_nominated_course_cd := v_sca_rec.adm_nominated_course_cd;
		p_out_acai_sequence_number := v_sca_rec.adm_sequence_number;
	ELSE
		CLOSE c_sca;
		p_out_admission_appl_number := p_admission_appl_number;
		p_out_nominated_course_cd := p_nominated_course_cd;
		p_out_acai_sequence_number := p_acai_sequence_number;
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END resp_get_sca_ca_acai;


FUNCTION RESP_GET_SUA_EFTD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_cal_type_eftd OUT NOCOPY NUMBER )
RETURN NUMBER AS
BEGIN	-- resp_get_sua_eftd
	-- Get the EFTD (Effective Full Time Day) figure for a nominated student
	-- IGS_PS_UNIT attempt. This is calculated as :
	-- The number of research days * The attendance percentage as at the
	-- effective date.
	-- add Days at a higher attendance percentage which are prior to the
	-- effective date
	-- less Days at a lower attendance percentage which are prior to the
	-- effective date
	-- less Days student is on intermission at the default rate for their
	-- attendance type
	-- less Days prior to the IGS_PS_COURSE commencement date, where the date is
	-- within the teaching period
DECLARE
	v_research_unit_ind		IGS_PS_UNIT_VER.research_unit_ind%TYPE;
	v_sca_course_cd			IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
	v_acai_admission_appl_number	IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE;
	v_acai_nominated_course_cd	IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE;
	v_acai_sequence_number		IGS_RE_CANDIDATURE.acai_sequence_number%TYPE;
	v_ca_attendance_percentage	IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
	v_commencement_dt		DATE;
	v_attendance_type		IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
	v_sca_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
	v_record_found			BOOLEAN DEFAULT FALSE;
	v_cah2_hist_end_dt		IGS_RE_CDT_ATT_HIST.hist_end_dt%TYPE;
	v_ca_sequence_number		IGS_RE_CANDIDATURE.sequence_number%TYPE;
	v_tp_days			NUMBER;
	v_effective_start_dt		DATE;
	v_effective_end_dt		DATE;
	v_attendance_percentage		NUMBER;
	v_baseline_eftd			NUMBER;
	v_removal_days			NUMBER;
	v_hist_start_dt			DATE;
	v_hist_end_dt			DATE;
	v_diff_days			NUMBER;
	v_intermit_start_dt		DATE;
	v_intermit_end_dt		DATE;
	v_remove_start_dt		DATE;
	v_remove_end_dt			DATE;
	v_last_hist_end_dt		DATE;
	v_diff_percentage		NUMBER;
	CURSOR	c_uv IS
		SELECT	uv.research_unit_ind
		FROM	IGS_PS_UNIT_VER uv
		WHERE	uv.unit_cd 		= p_unit_cd AND
	 		uv.version_number 	= p_unit_version_number;
	CURSOR	c_ca IS
		SELECT	ca.sequence_number,
			ca.attendance_percentage,
			ca.sca_course_cd,
			ca.acai_admission_appl_number,
			ca.acai_nominated_course_cd,
			ca.acai_sequence_number
		FROM	IGS_RE_CANDIDATURE ca
		WHERE	ca.person_id 		= p_person_id AND
			ca.sca_course_cd 	= p_course_cd;
	CURSOR c_sca IS
		SELECT	sca.attendance_type,
			sca.commencement_dt
		FROM	IGS_EN_STDNT_PS_ATT sca,
			IGS_PS_VER crv
		WHERE	sca.person_id 		= p_person_id 	AND
			sca.course_cd 		= p_course_cd;
	CURSOR c_cah1 (
		cp_effective_start_dt	DATE,
		cp_ca_sequence_number	IGS_RE_CANDIDATURE.sequence_number%TYPE)
	IS
		SELECT 	cah.hist_start_dt,
			cah.hist_end_dt,
			cah.attendance_percentage
		FROM	IGS_RE_CDT_ATT_HIST cah
		WHERE	cah.person_id 		= p_person_id 		AND
			cah.ca_sequence_number	= v_ca_sequence_number	AND
			cah.hist_end_dt 	>= cp_effective_start_dt AND
			cah.hist_start_dt 	<= p_effective_dt
		ORDER BY cah.hist_start_dt;
	CURSOR c_sci (
		cp_effective_start_dt	DATE)
	IS
		SELECT 	sci.start_dt,
			sci.end_dt
		FROM	IGS_EN_STDNT_PS_INTM sci,
                        IGS_EN_INTM_TYPES eit
		WHERE	sci.person_id 	= p_person_id 		AND
			sci.course_cd 	= p_course_cd 		AND
			sci.start_dt 	<= p_effective_dt 	AND
			sci.end_dt 	>= cp_effective_start_dt AND
                        sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY') AND
       			sci.approved  = eit.appr_reqd_ind AND
                        eit.intermission_type = sci.intermission_type
		ORDER BY sci.start_dt ASC;

        CURSOR c_cah2 (
		cp_ca_sequence_number	IGS_RE_CANDIDATURE.sequence_number%TYPE,
		cp_intermit_end_dt	DATE,
		cp_intermit_start_dt	DATE)
	IS
		SELECT	cah.hist_start_dt,
			cah.hist_end_dt,
			cah.attendance_percentage
		FROM	IGS_RE_CDT_ATT_HIST cah
		WHERE	cah.person_id 		= p_person_id 		AND
			cah.ca_sequence_number	= cp_ca_sequence_number AND
			cah.hist_start_dt 	<= cp_intermit_end_dt 	AND
			cah.hist_start_dt 	<= p_effective_dt 	AND
			cah.hist_end_dt 	>= cp_intermit_start_dt
		ORDER BY cah.hist_start_dt;
BEGIN
	--1. Load details from the IGS_PS_UNIT version
	OPEN c_uv;
	FETCH c_uv INTO v_research_unit_ind;
	IF c_uv%NOTFOUND THEN
		CLOSE c_uv;
		RETURN 0;
	END IF;
	CLOSE c_uv;
	IF v_research_unit_ind = 'N' THEN
		--IGS_PS_UNIT is not research load 'derivable'
		RETURN 0;
	END IF;
	--2. Load IGS_RE_CANDIDATURE details
	OPEN c_ca;
	FETCH c_ca INTO
			v_ca_sequence_number,
			v_ca_attendance_percentage,
			v_sca_course_cd,
			v_acai_admission_appl_number,
			v_acai_nominated_course_cd,
			v_acai_sequence_number;
	IF c_ca%NOTFOUND THEN
		CLOSE c_ca;
		--If no IGS_RE_CANDIDATURE then the student is not a research student
		RETURN 0;
	END IF;
	CLOSE c_ca;
	--3. Get the commencement date - this routine handles both enrolled students
	-- and students still in the admission stage.
	v_commencement_dt := IGS_RE_GEN_001.resp_get_ca_comm(
			p_person_id,
			v_sca_course_cd,
			v_acai_admission_appl_number,
			v_acai_nominated_course_cd,
			v_acai_sequence_number);
	--4. Load details from the student IGS_PS_COURSE attempt
	OPEN c_sca;
	FETCH c_sca INTO
			v_attendance_type,
			v_sca_commencement_dt;
	CLOSE c_sca;
	-- 5. Call routine to determine the number of effective days in the teaching
	-- period. If zero, then EFTSU cannot be calculated.
	v_tp_days := resp_get_teach_days(
			p_cal_type,
			p_ci_sequence_number,
			v_effective_start_dt,
			v_effective_end_dt);
	IF v_tp_days = 0 THEN
		p_cal_type_eftd := 0;
		RETURN 0;
	END IF;
	p_cal_type_eftd := v_tp_days;
	-- 6. Calculate the students attendance percentage as at the effective date
	v_attendance_percentage := IGS_RE_GEN_001.resp_get_ca_att(
						p_person_id,
						p_course_cd,
						p_effective_dt,
						v_ca_sequence_number,
						v_attendance_type,
						v_ca_attendance_percentage);
	IF v_attendance_percentage IS NULL THEN
		--Null attendance percentage indicates value could not be determined
		RETURN 0;
	END IF;
	-- 7. Calculate the 'baseline' EFTD figure using the attendance type as at
	-- the effective date.
	v_baseline_eftd := v_tp_days * ( v_attendance_percentage / 100 );
	-- 8. Subtract any commencement period from the figure.
	IF v_commencement_dt BETWEEN v_effective_start_dt AND
					v_effective_end_dt THEN
		v_removal_days := (v_commencement_dt - v_effective_start_dt);
		v_baseline_eftd := v_baseline_EFTD -
				(v_removal_days * (v_attendance_percentage / 100));
		-- Bring the effective start date up to the commencement date. All further
		-- calculations will exclude this period.
		v_effective_start_dt :=  v_commencement_dt;
	END IF;
	--9. Subtract/Add any periods of higher/lower percentage. Loop through
	-- attendance history to determine the values. Only consider histories
	-- which are between the earliest of commencement date / effective start
	-- date and the effective date of the calculation.
	FOR v_cah1_rec IN c_cah1(
			v_effective_start_dt,
			v_ca_sequence_number) LOOP
		IF v_cah1_rec.hist_start_dt >= v_effective_start_dt THEN
			v_hist_start_dt := v_cah1_rec.hist_start_dt;
		ELSE
			v_hist_start_dt := v_effective_start_dt;
		END IF;
		IF v_cah1_rec.hist_end_dt <= p_effective_dt THEN
			v_hist_end_dt := v_cah1_rec.hist_end_dt;
		ELSE
			v_hist_end_dt := p_effective_dt;
		END IF;
		v_diff_days := TRUNC(v_hist_end_dt) - TRUNC(v_hist_start_dt) + 1 ;
		IF v_cah1_rec.attendance_percentage > v_attendance_percentage THEN
			-- As history is higher add the difference in percentage to the total
			v_baseline_eftd := v_baseline_eftd +
					(((v_cah1_rec.attendance_percentage - v_attendance_percentage)
			 		/ 100) * v_diff_days);
		ELSE
			-- As history is lower subtract the difference in percentage from the total
			v_baseline_eftd := v_baseline_eftd -
					(((v_attendance_percentage - v_cah1_rec.attendance_percentage)
					/ 100) * v_diff_days);
		END IF;
	END LOOP;
	-- 10. During periods of intermission remove EFTD from the baseline figure
	-- to the equivalent of a 0% attendance. Only consider intermission up until
	-- the teaching period effective end date - anything beyond remains at the
	-- relevant attendance percentage.
	FOR v_sci_rec IN c_sci(
			v_effective_start_dt) LOOP
		IF v_sci_rec.start_dt >= v_effective_start_dt THEN
			v_intermit_start_dt := v_sci_rec.start_dt;
		ELSE
			v_intermit_start_dt := v_effective_start_dt;
		END IF;
		--Determine effective end date - this can be up until the effective end date
		-- of the teaching period.
		IF (v_sci_rec.end_dt ) <= v_effective_end_dt THEN
			v_intermit_end_dt := (v_sci_rec.end_dt );
		ELSE
			v_intermit_end_dt := v_effective_end_dt;
		END IF;
		FOR v_cah2_rec IN c_cah2 (
				v_ca_sequence_number,
				v_intermit_end_dt,
				v_intermit_start_dt) LOOP
			v_record_found := TRUE;
			v_cah2_hist_end_dt := v_cah2_rec.hist_end_dt;
			IF v_intermit_start_dt >= v_cah2_rec.hist_start_dt THEN
				v_remove_start_dt := v_intermit_start_dt;
			ELSE
				v_remove_start_dt := v_cah2_rec.hist_start_dt;
			END IF;
			IF v_intermit_end_dt <= v_cah2_rec.hist_end_dt THEN
				v_remove_end_dt := v_intermit_end_dt;
			ELSE
				v_remove_end_dt := v_cah2_rec.hist_end_dt;
			END IF;
			v_baseline_eftd := v_baseline_eftd -
					(( TRUNC(v_remove_end_dt) - TRUNC(v_remove_start_dt) + 1 )) *
					(v_cah2_rec.attendance_percentage / 100 );
		END LOOP;
		IF v_record_found = FALSE THEN
			v_last_hist_end_dt := v_intermit_start_dt - 1;
						 --(-1 allows for exclusive logic)
		ELSE
			v_last_hist_end_dt := v_cah2_hist_end_dt; -- (if last record processed)
		END IF;
		IF v_last_hist_end_dt < v_intermit_end_dt THEN
			v_diff_percentage := IGS_RE_GEN_001.resp_get_ca_att(
						p_person_id,
						p_course_cd,
						v_last_hist_end_dt,
						v_ca_sequence_number,
						v_attendance_type,
						v_ca_attendance_percentage);
			-- If the effective history did not cover until the end of the intermission
			-- period then subtract based on the load as at the effective date.
			v_baseline_eftd := v_baseline_eftd -
					(( v_intermit_end_dt - v_last_hist_end_dt - 1 ) *
					( v_diff_percentage / 100));
		END IF;
	END LOOP;
	RETURN v_baseline_eftd;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_uv%ISOPEN) THEN
			CLOSE c_uv;
		END IF;
		IF (c_ca%ISOPEN) THEN
			CLOSE c_ca;
		END IF;
		IF (c_sca%ISOPEN) THEN
			CLOSE c_sca;
		END IF;
		IF (c_cah1%ISOPEN) THEN
			CLOSE c_cah1;
		END IF;
		IF (c_sci%ISOPEN) THEN
			CLOSE c_sci;
		END IF;
		IF (c_cah2%ISOPEN) THEN
			CLOSE c_cah2;
		END IF;
		RAISE;
END;
END resp_get_sua_eftd;


FUNCTION RESP_GET_TEACH_DAYS(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE )
RETURN NUMBER AS
BEGIN 	-- resp_get_teach_days
	-- Get the number of days which apply to research students in a nominated
	-- teaching calendar instance.
	-- This figure is determined from the research effective date aliases, of
	-- which there should be a single start date and a single end date.
	-- If zero is returned, it indicates that the structure is not correctly
	-- set up for the nominated teaching period to be a research teaching
	-- period.
DECLARE
	E_NO_RESEARCH_CAL_CONFIG	EXCEPTION;
	v_effective_strt_dt_alias	IGS_RE_S_RES_CAL_CON.effective_strt_dt_alias%TYPE;
	v_effective_end_dt_alias	IGS_RE_S_RES_CAL_CON.effective_end_dt_alias%TYPE;
	v_start_alias_val		IGS_CA_DA_INST.absolute_val%TYPE DEFAULT NULL;
	v_end_alias_val			IGS_CA_DA_INST.absolute_val%TYPE DEFAULT NULL;
	CURSOR c_srcc IS
		SELECT	srcc.effective_strt_dt_alias,
			srcc.effective_end_dt_alias
		FROM	IGS_RE_S_RES_CAL_CON		srcc
		WHERE	srcc.s_control_num	= 1;
	FUNCTION resp_get_alias_val(
			p_cal_type		IGS_CA_INST.cal_type%TYPE,
			p_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE,
			p_effective_dt_alias	IGS_CA_DA_INST.dt_alias%TYPE)
	RETURN DATE aS
	BEGIN
	DECLARE
		v_num_recs_flag			BOOLEAN DEFAULT FALSE;
		v_alias_val			IGS_CA_DA_INST.absolute_val%TYPE;
		CURSOR c_dai IS
			SELECT	NVL(
				dai.absolute_val,
				IGS_CA_GEN_001.calp_get_alias_val(
						dai.dt_alias,
						dai.sequence_number,
						dai.cal_type,
						dai.ci_sequence_number)) AS v_absolute_val
			FROM	IGS_CA_DA_INST 	dai
			WHERE	dai.cal_type		= p_cal_type AND
				dai.ci_sequence_number	= p_ci_sequence_number AND
				dai.dt_alias		= p_effective_dt_alias;
	BEGIN
		-- Function selects a date from the teaching period, if zero or multiple
		-- values exist it returns null
		FOR v_dai_rec IN c_dai LOOP
			IF c_dai%ROWCOUNT = 1 THEN
				v_alias_val := v_dai_rec.v_absolute_val;
				v_num_recs_flag := TRUE;
			ELSE
				v_num_recs_flag := FALSE;
				EXIT;
			END IF;
		END LOOP;
		IF v_num_recs_flag THEN
			RETURN v_alias_val;
		END IF;
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			IF c_dai%ISOPEN THEN
				CLOSE c_dai;
			END IF;
			RAISE;
	END;
	END resp_get_alias_val;
BEGIN
	OPEN c_srcc;
	FETCH c_srcc INTO 	v_effective_strt_dt_alias,
				v_effective_end_dt_alias;
	IF c_srcc%NOTFOUND THEN
		CLOSE c_srcc;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE c_srcc;
	-- Select the start date from the teaching period
	v_start_alias_val := resp_get_alias_val(
						p_cal_type,
						p_ci_sequence_number,
						v_effective_strt_dt_alias);
	IF v_start_alias_val IS NULL THEN
		RETURN 0;
	END IF;
	-- Select the end date from the teaching period
	v_end_alias_val := resp_get_alias_val(
						p_cal_type,
						p_ci_sequence_number,
						v_effective_end_dt_alias);
	IF v_end_alias_val IS NULL THEN
		RETURN 0;
	END IF;
	-- Check that the end date is after the start date
	IF v_start_alias_val > v_end_alias_val THEN
		RETURN 0;
	END IF;
	p_start_dt := v_start_alias_val;
	p_end_dt := v_end_alias_val;
	RETURN ( v_end_alias_val - v_start_alias_val + 1 );
EXCEPTION
	WHEN OTHERS THEN
		IF c_srcc%ISOPEN THEN
			CLOSE c_srcc;
		END IF;
		RAISE;
END;
END resp_get_teach_days;


PROCEDURE RESP_GET_THE_EXISTS(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_check_thesis_exam IN boolean ,
  p_check_milestone IN boolean ,
  p_thesis_exam_exists OUT NOCOPY boolean ,
  p_milestone_exists OUT NOCOPY boolean )
AS
BEGIN	-- resp_get_the_exists
	-- This modulew returns output oarameters indicating whether
	-- or not data exists on IGS_RE_CANDIDATURE detail tables for the
	-- specified IGS_RE_THESIS.
DECLARE
	v_the_found		VARCHAR2(1);
	v_mil_found		VARCHAR2(1);
	CURSOR	c_the IS
		SELECT	'x'
		FROM	IGS_RE_THESIS_EXAM	tex
		WHERE	tex.person_id		= p_person_id AND
			tex.ca_sequence_number	= p_ca_sequence_number AND
			tex.the_sequence_number	= p_the_sequence_number;
	CURSOR	c_mil IS
		SELECT	'x'
		FROM	IGS_PR_MILESTONE	mil
		WHERE	mil.person_id		= p_person_id AND
			mil.ca_sequence_number	= p_ca_sequence_number;
BEGIN
	-- Initialise output parameters.
	p_thesis_exam_exists := FALSE;
	p_milestone_exists := FALSE;
	-- Check IGS_RE_THESIS exam
	IF p_check_thesis_exam THEN
		OPEN c_the;
		FETCH c_the INTO v_the_found;
		IF c_the%FOUND THEN
			CLOSE c_the;
			p_thesis_exam_exists := TRUE;
		ELSE
			CLOSE c_the;
		END IF;
	END IF;
	 -- Check IGS_PR_MILESTONE
	IF p_check_milestone THEN
		OPEN c_mil;
		FETCH c_mil INTO v_mil_found;
		IF c_mil%FOUND THEN
			CLOSE c_mil;
			p_milestone_exists := TRUE;
		ELSE
			CLOSE c_mil;
		END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF c_the%ISOPEN THEN
			CLOSE c_the;
		END IF;
		IF c_mil%ISOPEN THEN
			CLOSE c_mil;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END resp_get_the_exists;


 FUNCTION RESP_GET_THE_STATUS(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_details_passed_ind IN VARCHAR2 ,
  p_logical_delete_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 )
RETURN VARCHAR2 AS
BEGIN	-- resp_get_the_status
	-- Get the IGS_RE_THESIS status.
	-- Values are:
	-- PENDING - IGS_RE_THESIS detail has been keyed, but has not yet been submitted
	-- SUBMITTED - IGS_RE_THESIS has been submitted and is being processed in some way
	-- EXAMINED - IGS_RE_THESIS has been submitted and examined and a final outcome
	-- 		entered.
	-- DELETED - IGS_RE_THESIS has been logically deleted and no longer applies to the
	-- 		research
DECLARE
	cst_deleted		CONSTANT VARCHAR2(10) := 'DELETED';
	cst_examined		CONSTANT VARCHAR2(10) := 'EXAMINED';
	cst_submitted		CONSTANT VARCHAR2(10) := 'SUBMITTED';
	cst_pending		CONSTANT VARCHAR2(10) := 'PENDING';
	CURSOR	c_the IS
		SELECT	thes.logical_delete_dt,
			thes.thesis_result_cd
		FROM	IGS_RE_THESIS thes
		WHERE	thes.person_id		= p_person_id AND
			thes.ca_sequence_number = p_ca_sequence_number AND
			thes.sequence_number	= p_the_sequence_number;
	v_the_rec				c_the%ROWTYPE;
	CURSOR	c_tex IS
		SELECT	'x'
		FROM	IGS_RE_THESIS_EXAM tex
		WHERE	person_id 		= p_person_id AND
			ca_sequence_number	= p_ca_sequence_number AND
			the_sequence_number	= p_the_sequence_number AND
			submission_dt 		IS NOT NULL;
	v_tex_exists			VARCHAR2(1);
BEGIN
	IF p_details_passed_ind = 'N' THEN
		--Select details from the IGS_RE_THESIS table.
		OPEN c_the;
		FETCH c_the INTO v_the_rec;
		IF c_the%NOTFOUND THEN
			CLOSE c_the;
			RETURN NULL;
		END IF;
		CLOSE c_the;
	ELSE
		v_the_rec.logical_delete_dt := p_logical_delete_dt;
		v_the_rec.thesis_result_cd := p_thesis_result_cd;
	END IF;
	--Logical deletion will always take priority over all other statuses
	IF v_the_rec.logical_delete_dt IS NOT NULL THEN
		RETURN cst_deleted;
	END IF;
	--If final outcome exists then return examined-any submissions are irrelevant
	IF v_the_rec.thesis_result_cd IS NOT NULL THEN
		RETURN cst_examined;
	END IF;
	--Select detail from the IGS_RE_THESIS examinations section
	OPEN c_tex;
	FETCH c_tex INTO v_tex_exists;
	IF c_tex%FOUND THEN
		CLOSE c_tex;
		RETURN cst_submitted;
	END IF;
	CLOSE c_tex;
	--If none of the above, then 'PENDING'
	RETURN cst_pending;
END;
END resp_get_the_status;


 FUNCTION resp_ins_ca_cah(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_old_attendance_percentage IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
BEGIN	-- resp_ins_ca_cah
	-- This modules inserts into IGS_RE_CDT_ATT_HIST when
	-- IGS_RE_CANDIDATURE.attendance_percentage is changed. The following is validated:
	-- IGS_RE_CANDIDATURE requires attendance history details to be retained.
DECLARE
	v_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
	v_attendance_type		IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
	v_message_name			VARCHAR2(30);
	v_hist_end_dt			IGS_RE_CDT_ATT_HIST.hist_end_dt%TYPE;
	v_attendance_percentage		IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
	v_hist_start_dt			IGS_RE_CDT_ATT_HIST.hist_start_dt%TYPE;
	v_sequence_number		IGS_RE_CDT_ATT_HIST.sequence_number%TYPE;

      LV_ROWID			VARCHAR2(25);
      v_org_id	IGS_RE_CDT_ATT_HIST.org_id%TYPE := IGS_GE_GEN_003.Get_Org_Id;
	CURSOR	c_cah IS
		SELECT	cah.hist_end_dt
		FROM	IGS_RE_CDT_ATT_HIST cah
		WHERE	cah.person_id 		= p_person_id AND
			cah.ca_sequence_number 	= p_ca_sequence_number
		ORDER BY cah.hist_end_dt DESC;
	CURSOR	c_cah2 IS
		SELECT 	NVL(max(cah2.sequence_number),0)+1
		FROM	IGS_RE_CDT_ATT_HIST cah2
		WHERE	cah2.person_id 		= p_person_id AND
			cah2.ca_sequence_number 	= p_ca_sequence_number;
BEGIN
	p_message_name := NULL;
	-- Validate that IGS_RE_CANDIDATURE attendance history is required
	IF IGS_RE_VAL_CAH.resp_val_cah_ca_ins(
			p_person_id,
			p_ca_sequence_number,
			p_sca_course_cd,
			v_commencement_dt,
			v_attendance_type,
			v_message_name) = FALSE THEN
		--IGS_RE_CANDIDATURE attendance history is not retained yet
		RETURN TRUE;
	END IF;
	-- Determine attendance percentage
	v_attendance_percentage := IGS_RE_GEN_001.resp_get_ca_att(
			p_person_id,
			p_sca_course_cd,
			TRUNC(SYSDATE),
			p_ca_sequence_number,
			v_attendance_type,
	 	p_old_attendance_percentage);
--By bayadav as a part of bug 2399877
	--First history inserted, attendance % should be set the student
	-- to the histury table as it is a mandatory column in IGS_RE_CDT_ATT_HIST table
		IF v_attendance_percentage IS NULL THEN
			p_message_name := 'IGS_RE_ATT_PER_NOT_EXIST';
			RETURN FALSE;
		END IF;


	OPEN c_cah;
	FETCH c_cah INTO v_hist_end_dt;
	IF c_cah%NOTFOUND THEN
		CLOSE c_cah;
		--First history inserted, start date should be set the student
		-- IGS_PS_COURSE attempt Commencement date
		IF v_commencement_dt IS NULL THEN
			p_message_name := 'IGS_RE_FIRST_HIST_CANT_INSERT';
			RETURN FALSE;
		ELSE
			v_hist_start_dt := v_commencement_dt;
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
	-- Get next sequence in parent
	OPEN c_cah2;
	FETCH c_cah2 INTO v_sequence_number;
	CLOSE c_cah2;

       IGS_RE_CDT_ATT_HIST_PKG.INSERT_ROW( X_ROWID => LV_ROWID,
                                          X_PERSON_ID => p_person_id,
                                          X_CA_SEQUENCE_NUMBER => p_ca_sequence_number,
							X_SEQUENCE_NUMBER => v_sequence_number,
							X_HIST_START_DT  => v_hist_start_dt,
							X_HIST_END_DT  => TRUNC(SYSDATE) - 1,
							X_ATTENDANCE_TYPE  => v_attendance_type,
							X_ATTENDANCE_PERCENTAGE => v_attendance_percentage,
							X_ORG_ID	=> v_org_id,
							X_MODE    => 'R');

	 -- Warn that IGS_RE_CANDIDATURE attendance history has been inserted
	p_message_name := 'IGS_RE_CAND_ATT_HIST_INSERTED';
	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_cah%ISOPEN) THEN
			CLOSE c_cah;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END resp_ins_ca_cah;


 PROCEDURE resp_ins_ca_hist(
  p_person_id IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_old_sca_course_cd IN VARCHAR2 ,
  p_new_sca_course_cd IN VARCHAR2 ,
  p_old_acai_adm_appl_num IN NUMBER ,
  p_new_acai_adm_appl_num IN NUMBER ,
  p_old_acai_nominated_course_cd IN VARCHAR2 ,
  p_new_acai_nominated_course_cd IN VARCHAR2 ,
  p_old_acai_sequence_number IN NUMBER ,
  p_new_acai_sequence_number IN NUMBER ,
  p_old_attendance_percentage IN NUMBER ,
  p_new_attendance_percentage IN NUMBER ,
  p_old_govt_type_of_activity_cd IN VARCHAR2 ,
  p_new_govt_type_of_activity_cd IN VARCHAR2 ,
  p_old_max_submission_dt IN DATE ,
  p_new_max_submission_dt IN DATE ,
  p_old_min_submission_dt IN DATE ,
  p_new_min_submission_dt IN DATE ,
  p_old_research_topic IN VARCHAR2 ,
  p_new_research_topic IN VARCHAR2 ,
  p_old_industry_links IN VARCHAR2 ,
  p_new_industry_links IN VARCHAR2 ,
  p_old_update_who IN NUMBER ,
  p_new_update_who IN NUMBER ,
  p_old_update_on IN DATE ,
  p_new_update_on IN DATE )
AS
      LV_ROWID			VARCHAR2(25);
      v_org_id	igs_re_cdt_att_hist.org_id%TYPE;
BEGIN	-- resp_ins_ca_hist
	-- Description: Insert IGS_RE_CANDIDATURE history (IGS_RE_CDT_HIST)
        v_org_id	:= IGS_GE_GEN_003.Get_Org_Id;
DECLARE
	r_ch			IGS_RE_CDT_HIST%ROWTYPE;
	v_create_history	BOOLEAN := FALSE;

BEGIN
	IF NVL(p_new_sca_course_cd, 'NULL') <>
			NVL(p_old_sca_course_cd, 'NULL') THEN
		r_ch.sca_course_cd := p_old_sca_course_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_acai_adm_appl_num, -1) <>
			NVL(p_old_acai_adm_appl_num, -1) THEN
		r_ch.acai_admission_appl_number := p_old_acai_adm_appl_num;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_acai_nominated_course_cd, 'NULL') <>
			NVL(p_old_acai_nominated_course_cd, 'NULL') THEN
		r_ch.acai_nominated_course_cd := p_old_acai_nominated_course_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_acai_sequence_number, -1) <>
			NVL(p_old_acai_sequence_number, -1) THEN
		r_ch.acai_sequence_number := p_old_acai_sequence_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_attendance_percentage, -1) <>
			NVL(p_old_attendance_percentage, -1) THEN
		r_ch.attendance_percentage := p_old_attendance_percentage;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_govt_type_of_activity_cd, 'NULL') <>
			NVL(p_old_govt_type_of_activity_cd, 'NULL') THEN
		r_ch.govt_type_of_activity_cd := p_old_govt_type_of_activity_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_max_submission_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			NVL(p_old_max_submission_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
		r_ch.max_submission_dt := p_old_max_submission_dt;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_min_submission_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			NVL(p_old_min_submission_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
		r_ch.min_submission_dt := p_old_min_submission_dt;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_research_topic, 'NULL') <>
			NVL(p_old_research_topic, 'NULL') THEN
		r_ch.research_topic := p_old_research_topic;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_industry_links, 'NULL') <>
			NVL(p_old_industry_links, 'NULL') THEN
		r_ch.industry_links := p_old_industry_links;
		v_create_history := TRUE;
	END IF;
	IF v_create_history = TRUE THEN
		r_ch.person_id := p_person_id;
		r_ch.sequence_number := p_sequence_number;
		r_ch.hist_start_dt := p_old_update_on;
		r_ch.hist_end_dt := p_new_update_on;
		r_ch.hist_who := p_old_update_who;
              IGS_RE_CDT_HIST_PKG.INSERT_ROW(
			X_ROWID   => LV_ROWID,
              	X_person_id => r_ch.person_id,
			X_sequence_number => r_ch.sequence_number,
			X_hist_start_dt => r_ch.hist_start_dt,
			X_hist_end_dt => r_ch.hist_end_dt,
			X_hist_who => r_ch.hist_who,
			X_sca_course_cd => r_ch.sca_course_cd,
			X_acai_admission_appl_number => r_ch.acai_admission_appl_number,
			X_acai_nominated_course_cd => r_ch.acai_nominated_course_cd,
			X_acai_sequence_number => r_ch.acai_sequence_number,
			X_attendance_percentage => r_ch.attendance_percentage,
			X_govt_type_of_activity_cd => r_ch.govt_type_of_activity_cd,
			X_max_submission_dt => r_ch.max_submission_dt,
			X_min_submission_dt => r_ch.min_submission_dt,
			X_research_topic => r_ch.research_topic,
			X_industry_links => r_ch.industry_links,
			X_ORG_ID	=> v_org_id,
			X_MODE        =>  'R');

	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END resp_ins_ca_hist;


 FUNCTION RESP_INS_DFLT_MIL(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean AS
/*******************************************************************************
Created by  : vkarthik, ORACLE IDC
Date created: 26-Apr-2004

Known limitations/enhancements/remarks:

Change History: (who, when, what: NO CREATION RECORDS HERE!)
Who		When		What
vkarthik        26-Apr-2004     Removed the condition that inserts records from milestone
                                set only if due date is in the present or future for
                                EN303 Milestone build Enh#3577974
*******************************************************************************/
LV_ROWID			VARCHAR2(25);
v_org_id	igs_re_cdt_att_hist.org_id%TYPE;
BEGIN	-- resp_ins_dflt_mil
	-- Insert default milestones against a IGS_RE_CANDIDATURE based on their
	-- IGS_PS_COURSE version.
	v_org_id	:= IGS_GE_GEN_003.Get_Org_Id;

DECLARE
	cst_planned			CONSTANT VARCHAR2(10) := 'PLANNED';
	v_dummy				VARCHAR2(1);
	v_sca_course_cd			IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
	v_acai_admission_appl_number	IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE;
	v_acai_nominated_course_cd	IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE;
	v_acai_sequence_number		IGS_RE_CANDIDATURE.acai_sequence_number%TYPE;
	v_crv_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
	v_attendance_type		IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
	v_course_cd			IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
	v_milestone_status		IGS_PR_MS_STAT.milestone_status%TYPE;
	v_milestone_type		IGS_RE_DFLT_MS_SET.milestone_type%TYPE;
	v_offset_days			IGS_RE_DFLT_MS_SET.offset_days%TYPE;
	v_mil_sequence_number		IGS_PR_MILESTONE.sequence_number%TYPE;
	v_commencement_dt		DATE;
	v_records_inserted		NUMBER;

	CURSOR c_mil_exists	(
		cp_milestone_type	IGS_PR_MILESTONE.milestone_type%TYPE,
		cp_due_dt		IGS_PR_MILESTONE.due_dt%TYPE)  IS
		SELECT	'x'
		FROM	IGS_PR_MILESTONE mil
		WHERE	mil.person_id		= p_person_id AND
			mil.ca_sequence_number	= p_ca_sequence_number AND
			mil.milestone_type		= cp_milestone_type AND
			mil.due_dt		= cp_due_dt;
	CURSOR c_ca_detail IS
		SELECT	ca.sca_course_cd,
			ca.acai_admission_appl_number,
			ca.acai_nominated_course_cd,
			ca.acai_sequence_number
		FROM	IGS_RE_CANDIDATURE ca
		WHERE	ca.person_id		= p_person_id AND
			ca.sequence_number	= p_ca_sequence_number;
	CURSOR c_sca (
		cp_sca_course_cd		IGS_RE_CANDIDATURE.sca_course_cd%TYPE) IS
		SELECT	sca.version_number,
			sca.attendance_type
		FROM	IGS_EN_STDNT_PS_ATT sca
		WHERE	sca.person_id		= p_person_id AND
			sca.course_cd		= cp_sca_course_cd;
	CURSOR c_acai (
		cp_acai_admission_appl_number	IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE,
		cp_acai_nominated_course_cd	IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE,
		cp_acai_sequence_number		IGS_RE_CANDIDATURE.acai_sequence_number%TYPE) IS
		SELECT	acai.course_cd,
			acai.crv_version_number,
			acai.attendance_type
		FROM	IGS_AD_PS_APPL_INST acai
		WHERE	acai.person_id			= p_person_id			AND
			acai.admission_appl_number	= cp_acai_admission_appl_number AND
			acai.nominated_course_cd	= cp_acai_nominated_course_cd	AND
			acai.sequence_number		= cp_acai_sequence_number;
	CURSOR c_mst_planned IS
		SELECT	mst.milestone_status
		FROM	IGS_PR_MS_STAT mst
		WHERE	mst.s_milestone_status = cst_planned
                AND mst.closed_ind = 'N'
		ORDER BY mst.milestone_status;
	CURSOR c_dms (
		cp_course_cd			IGS_RE_DFLT_MS_SET.course_cd%TYPE,
		cp_crv_version_number		IGS_RE_DFLT_MS_SET.version_number%TYPE,
		cp_attendance_type		IGS_RE_DFLT_MS_SET.attendance_type%TYPE) IS
		SELECT	dms.milestone_type,
			dms.offset_days
		FROM	IGS_RE_DFLT_MS_SET dms,
			IGS_PR_MILESTONE_TYP mst
		WHERE	dms.course_cd		= cp_course_cd	AND
			dms.version_number	= cp_crv_version_number AND
			dms.attendance_type	= cp_attendance_type	AND
			mst.milestone_type	= dms.milestone_type	AND
			mst.closed_ind	= 'N'
		ORDER BY offset_days;
	CURSOR c_mil_seq_num IS
		SELECT	IGS_PR_MILESTONE_SEQ_NUM_S.NEXTVAL
		FROM	DUAL;
BEGIN
	-- Set default value
	p_message_name := null;
	v_records_inserted := 0;
	-- 2. Load details from the IGS_RE_CANDIDATURE table.
	OPEN c_ca_detail;
	FETCH c_ca_detail INTO	v_sca_course_cd,
				v_acai_admission_appl_number,
				v_acai_nominated_course_cd,
				v_acai_sequence_number;
	IF c_ca_detail%NOTFOUND THEN
		p_message_name := 'IGS_RE_CANT_LOCATE_CAND_DET';
		CLOSE c_ca_detail;
		RETURN FALSE;
	END IF;
	CLOSE c_ca_detail;
	-- 3. Get the commencement date of the research student.
	v_commencement_dt := IGS_RE_GEN_001.resp_get_ca_comm(
						p_person_id,
						v_sca_course_cd,
						v_acai_admission_appl_number,
						v_acai_nominated_course_cd,
						v_acai_sequence_number);
	IF v_commencement_dt IS NULL THEN
		v_commencement_dt := SYSDATE;
	END IF;
	-- 4. Select the IGS_PS_COURSE version number and attendance type
	--    from the appropriate source.
	IF v_sca_course_cd IS NOT NULL THEN
		OPEN c_sca (
				v_sca_course_cd);
		FETCH c_sca INTO	v_crv_version_number,
					v_attendance_type;
		CLOSE c_sca;
		v_course_cd := v_sca_course_cd;
	ELSIF v_acai_admission_appl_number IS NOT NULL THEN
		OPEN c_acai (
				v_acai_admission_appl_number,
				v_acai_nominated_course_cd,
				v_acai_sequence_number);
		FETCH c_acai INTO	v_course_cd,
					v_crv_version_number,
					v_attendance_type;
		CLOSE c_acai;
	ELSE
		v_crv_version_number := 0;
	END IF;
	-- 5. Select the planned IGS_PR_MILESTONE status (pick the first)
	OPEN c_mst_planned;
	FETCH c_mst_planned INTO v_milestone_status;
	IF c_mst_planned%NOTFOUND THEN
		p_message_name := 'IGS_RE_CANT_LOCATE_MILST_STAT';
		CLOSE c_mst_planned;
		RETURN FALSE;
	END IF;
	CLOSE c_mst_planned;
	-- 6. Loop through the default milestones and add records.
	OPEN c_dms (
		v_course_cd,
		v_crv_version_number,
		v_attendance_type);
	FETCH c_dms INTO	v_milestone_type,
				v_offset_days;
	IF c_dms%FOUND THEN
		LOOP
				OPEN c_mil_exists(	v_milestone_type,
							v_commencement_dt + v_offset_days);
				FETCH c_mil_exists INTO v_dummy;
				IF c_mil_exists%NOTFOUND THEN
					CLOSE c_mil_exists;
					OPEN c_mil_seq_num;
					FETCH c_mil_seq_num INTO v_mil_sequence_number;
					CLOSE c_mil_seq_num;
                               -- if condition removed for Enh#3577974 for milestone validation build EN303
                               IGS_PR_MILESTONE_PKG.INSERT_ROW(
                                                X_ROWID => LV_ROWID,
								X_PERSON_ID => p_person_id,
								X_ca_sequence_number => p_ca_sequence_number,
								X_sequence_number => v_mil_sequence_number,
 								X_milestone_type => v_milestone_type,
								X_milestone_status => v_milestone_status,
								X_due_dt => v_commencement_dt + v_offset_days,
                                                X_DESCRIPTION  => NULL,
								X_ACTUAL_REACHED_DT => NULL,
								X_PRECED_SEQUENCE_NUMBER => NULL,
								X_OVRD_NTFCTN_IMMINENT_DAYS => NULL,
								X_OVRD_NTFCTN_REMINDER_DAYS =>  NULL,
								X_OVRD_NTFCTN_RE_REMINDER_DAYS => NULL,
								X_COMMENTS   => NULL,
								X_ORG_ID	=> v_org_id,
                                                X_MODE => 'R');

					v_records_inserted := v_records_inserted + 1;
				ELSE
					CLOSE c_mil_exists;
				END IF;
			FETCH c_dms INTO	v_milestone_type,
						v_offset_days;
			EXIT WHEN c_dms%NOTFOUND;
		END LOOP;
		CLOSE c_dms;
	ELSE
		CLOSE c_dms;
	END IF;
	IF v_records_inserted = 0 THEN
		-- If no records found
		p_message_name := 'IGS_RE_NO_DFLT_MILSTN_EXIST';
		RETURN FALSE;
	END IF;
	-- Commit Changes
	COMMIT;
	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		IF c_mil_exists%ISOPEN THEN
			CLOSE c_mil_exists;
		END IF;
		IF c_ca_detail%ISOPEN THEN
			CLOSE c_ca_detail;
		END IF;
		IF c_sca%ISOPEN THEN
			CLOSE c_sca;
		END IF;
		IF c_acai%ISOPEN THEN
			CLOSE c_acai;
		END IF;
		IF c_mst_planned%ISOPEN THEN
			CLOSE c_mst_planned;
		END IF;
		IF c_dms%ISOPEN THEN
			CLOSE c_dms;
		END IF;
		IF c_mil_seq_num%ISOPEN THEN
			CLOSE c_mil_seq_num;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END  resp_ins_dflt_mil;


END IGS_RE_GEN_002 ;

/
