--------------------------------------------------------
--  DDL for Package Body IGS_ST_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GEN_004" AS
/* $Header: IGSST04B.pls 120.0 2005/06/02 03:54:49 appldev noship $ */
/*------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA       |
 |                            All rights reserved.                              |
 +==============================================================================+
 |                                                                              |
 | DESCRIPTION                                                                  |
 |      PL/SQL body for package: IGS_ST_GEN_004                             |
 |                                                                              |
 | NOTES                                                                        |
 |                                                                              |
 |                                                                              |
 | HISTORY                                                                      |
 | Who          When            What                                            |
 | knaraset    15-May-2003    Modified code to have unit attempt context with
 |                            either uoo_id or location_cd and unit_class,
 |                            as part of MUS build bug 2829262
 | smvk        09-Jul-2004    Bug # 3676145. Modified the cursor c_sua_ucl_um
 |                            to select active (not closed) unit classes.
 | gmaheswa    25-Jan-2005    Bug 3882788 Modified c_get_api to exclude person
 |			      identifiers whose start_dt = end_dt.
 |
 | ctyagi      15-Apr-2004 Obsolete the procedure Stas_Ins_Ess for bug 4293239
 +------------------------------------------------------------------------------*/

Function Stap_Get_Supp_Fos(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2 AS
	gv_other_detail		VARCHAR2(255);
	BEGIN	-- stap_get_supp_fos
	-- Derive the supplementary field of study to which
	-- a combined IGS_PS_COURSE is classified
	-- DEETYA element 389
DECLARE
	cst_combined	CONSTANT	IGS_PS_GRP_TYPE.s_course_group_type%TYPE := 'COMBINED';
	v_dummy				VARCHAR2(1);
	v_govt_field_of_study		IGS_PS_FLD_OF_STUDY.govt_field_of_study%TYPE;
	CURSOR c_cgm_cgr_cgt IS
		SELECT	'X'
		FROM	IGS_PS_GRP_MBR	cgm,
			IGS_PS_GRP		cgr,
			IGS_PS_GRP_TYPE	cgt
		WHERE	cgm.course_cd		= p_course_cd AND
			cgm.version_number	= p_version_number AND
			cgr.course_group_cd	= cgm.course_group_cd AND
			cgt.course_group_type	= cgr.course_group_type AND
			cgt.s_course_group_type	= cst_combined;
	CURSOR c_cfos (
		cp_course_cd		IGS_PS_VER.course_cd%TYPE,
		cp_version_number	IGS_PS_VER.version_number%TYPE) IS
		SELECT	fos.govt_field_of_study
		FROM	IGS_PS_FIELD_STUDY	cfos,
			IGS_PS_FLD_OF_STUDY		fos
		WHERE	cfos.course_cd		= cp_course_cd	AND
			cfos.version_number	= cp_version_number AND
			fos.field_of_study	= cfos.field_of_study
		ORDER BY
			cfos.major_field_ind	ASC,
			cfos.percentage		DESC,
			cfos.field_of_study	ASC;

BEGIN
	OPEN c_cgm_cgr_cgt;
	FETCH c_cgm_cgr_cgt INTO v_dummy;
	IF c_cgm_cgr_cgt%NOTFOUND THEN
		CLOSE c_cgm_cgr_cgt;
		-- IGS_PS_COURSE version is not a combined IGS_PS_COURSE
		RETURN '000000';
	END IF;
	CLOSE c_cgm_cgr_cgt;
	-- IGS_PS_COURSE version is a combined IGS_PS_COURSE
	OPEN c_cfos (
		p_course_cd,
		p_version_number);
	FETCH c_cfos INTO v_govt_field_of_study;
	IF (c_cfos%NOTFOUND) THEN
		v_govt_field_of_study := '000000';
	END IF;
	CLOSE c_cfos;
	RETURN v_govt_field_of_study;
EXCEPTION
	WHEN OTHERS THEN
		IF c_cgm_cgr_cgt%ISOPEN THEN
			CLOSE c_cgm_cgr_cgt;
		END IF;
		IF c_cfos%ISOPEN THEN
			CLOSE c_cfos;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stap_get_supp_fos');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  END stap_get_supp_fos;

Function Stap_Get_Tot_Exmpt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN NUMBER AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_tot_exmp
	-- Description: This module retrieves the total exemption for a IGS_PS_COURSE
	-- granted to a student.
DECLARE
	v_total_exmptn_perc_grntd	NUMBER (5);
	CURSOR	c_ast IS
		SELECT 	trunc(total_exmptn_perc_grntd)
		FROM	IGS_AV_ADV_STANDING	ast
		WHERE	ast.person_id 		= p_person_id and
			ast.course_cd 		= p_course_cd and
			ast.version_number 	= p_version_number;
BEGIN
	v_total_exmptn_perc_grntd := 0;
	OPEN c_ast;
	FETCH c_ast INTO v_total_exmptn_perc_grntd;
	IF (c_ast%FOUND) THEN
		CLOSE c_ast;
		IF (v_total_exmptn_perc_grntd > 99) THEN
			v_total_exmptn_perc_grntd := 99;
			RETURN v_total_exmptn_perc_grntd;
		ELSE
			RETURN v_total_exmptn_perc_grntd;
		END IF;
	END IF;
	CLOSE c_ast;
	RETURN 0;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_ast%ISOPEN) THEN
			CLOSE c_ast;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stap_get_tot_exmpt');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END stap_get_tot_exmpt;

Function Stap_Get_Un_Comp_Sts(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_sua_cal_type IN VARCHAR2 ,
  p_sua_ci_sequence_number IN NUMBER,
  p_uoo_id IN igs_ps_unit_ofr_opt.uoo_id%TYPE)
RETURN NUMBER AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_un_comp_sts
	-- Derive the IGS_PS_UNIT of study completion status
	-- DEETYA element 355
DECLARE
	v_ret_val	NUMBER(2);
	v_unit_attempt_status		IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
	v_dummy_grading_schema_cd	IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
	v_dummy_version_number		IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
	v_dummy_grade			IGS_AS_GRD_SCH_GRADE.grade%TYPE;
	v_s_result_type			IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
	CURSOR c_get_unit_attempt_status IS
		SELECT	unit_attempt_status
		FROM	IGS_EN_SU_ATTEMPT
		WHERE	person_id	= p_person_id	AND
			course_cd	= p_course_cd	AND
			uoo_id		= p_uoo_id;
BEGIN
	OPEN c_get_unit_attempt_status;
	FETCH c_get_unit_attempt_status INTO v_unit_attempt_status;
	IF (c_get_unit_attempt_status%NOTFOUND) THEN
		CLOSE c_get_unit_attempt_status;
		RETURN 1;
	END IF;
	CLOSE c_get_unit_attempt_status;
	v_s_result_type := IGS_AS_GEN_003.assp_get_sua_grade (
					p_person_id,
					p_course_cd,
					p_unit_cd,
					p_sua_cal_type,
					p_sua_ci_sequence_number,
					v_unit_attempt_status,
					'Y',
					v_dummy_grading_schema_cd,
					v_dummy_version_number,
					v_dummy_grade,
                    p_uoo_id);
	IF (NVL(v_s_result_type, 'NULL_VAL') = 'WITHDRAWN') THEN
		-- Withdrew without penalty
		v_ret_val := 1;
	ELSIF (NVL(v_s_result_type, 'NULL_VAL') = 'FAIL') THEN
		-- Failed
		v_ret_val := 2;
	ELSIF (NVL(v_s_result_type, 'NULL_VAL') = 'PASS') THEN
		-- Successfully completed all the requirements
		v_ret_val := 3;
	ELSE
		-- IGS_PS_UNIT of student to be completed later in the year or still
		-- in the process of completing or completion status not yet determined
		v_ret_val := 4;
	END IF;
	RETURN v_ret_val;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stap_get_un_comp_sts');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
   END stap_get_un_comp_sts;


Function Stap_Ins_Govt_Snpsht(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_ess_snapshot_dt_time IN DATE ,
  p_use_most_recent_ess_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_log_creation_dt OUT NOCOPY DATE )
RETURN BOOLEAN AS
	gv_other_detail			VARCHAR2(255);
	gv_extra_details		VARCHAR2(255) DEFAULT NULL;
BEGIN
DECLARE
	e_resource_busy		EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
	v_dummy				VARCHAR2(1);
	v_other_detail			VARCHAR2(255);
	v_ess_rec_found			BOOLEAN DEFAULT FALSE;
	v_message_name			VARCHAR2(30) DEFAULT NULL;
	v_sub_yr			IGS_ST_GVT_SPSHT_CTL.submission_yr%TYPE;
	-- define the submission census dates
	-- these can be changed if required
	v_submission_1_census_dt	DATE :=
					 IGS_GE_DATE.igsdate(TO_CHAR(p_submission_yr)||'03/31');
	v_submission_2_census_dt	DATE :=
					 IGS_GE_DATE.igsdate(TO_CHAR(p_submission_yr)||'08/31');
	v_ess_snapshot_dt_time		IGS_ST_GVT_SPSHT_CTL.ess_snapshot_dt_time%TYPE;
	v_effective_dt			DATE;
	v_unit_effective_dt			DATE;
	v_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
	v_derived_commencement_dt	IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
	v_attendance_type		IGS_EN_ATD_TYPE.attendance_type%TYPE;
	v_govt_attendance_type		IGS_EN_ATD_TYPE.govt_attendance_type%TYPE;
	v_attendance_mode_1		IGS_EN_ATD_MODE.attendance_mode%TYPE;
	v_govt_attendance_mode_1 	IGS_EN_ATD_MODE.govt_attendance_mode%TYPE;
	v_attendance_mode_2		IGS_EN_ATD_MODE.attendance_mode%TYPE;
	v_govt_attendance_mode_2 	IGS_EN_ATD_MODE.govt_attendance_mode%TYPE;
	v_attendance_mode_3		IGS_EN_ATD_MODE.attendance_mode%TYPE;
	v_govt_attendance_mode_3 	IGS_EN_ATD_MODE.govt_attendance_mode%TYPE;
	v_load_cal_type 		IGS_EN_ST_SNAPSHOT.ci_cal_type%TYPE DEFAULT NULL;
	v_load_ci_sequence_number
					IGS_EN_ST_SNAPSHOT.ci_sequence_number%TYPE DEFAULT NULL;
	v_teach_cal_type 		IGS_EN_ST_SNAPSHOT.sua_cal_type%TYPE DEFAULT NULL;
	v_teach_ci_sequence_number
					IGS_EN_ST_SNAPSHOT.sua_ci_sequence_number%TYPE DEFAULT NULL;
	v_person_id			IGS_PE_STATISTICS.person_id%TYPE DEFAULT NULL;
	v_course_cd			IGS_EN_ST_SNAPSHOT.course_cd%TYPE DEFAULT NULL;
	v_gse_person_id			IGS_PE_STATISTICS.person_id%TYPE DEFAULT NULL;
	v_gse_course_cd			IGS_EN_ST_SNAPSHOT.course_cd%TYPE DEFAULT NULL;
	v_alias_val			IGS_CA_DA_INST_V.alias_val%TYPE DEFAULT NULL;
	v_govt_semester			IGS_ST_GVT_STDNTLOAD.govt_semester%TYPE DEFAULT NULL;
	v_govt_reportable		IGS_EN_ST_SNAPSHOT.govt_reportable_ind%TYPE;
	v_birth_dt			IGS_ST_GOVT_STDNT_EN.birth_dt%TYPE;
	v_sex				IGS_ST_GOVT_STDNT_EN.sex%TYPE;
	v_govt_disability		IGS_ST_GOVT_STDNT_EN.govt_disability%TYPE;
	v_aborig_torres_cd		IGS_ST_GOVT_STDNT_EN.aborig_torres_cd%TYPE;
	v_govt_aborig_torres_cd		IGS_ST_GOVT_STDNT_EN.govt_aborig_torres_cd%TYPE;
	v_citizenship_cd		IGS_ST_GOVT_STDNT_EN.citizenship_cd%TYPE;
	v_govt_citizenship_cd		IGS_ST_GOVT_STDNT_EN.govt_citizenship_cd%TYPE;
	v_perm_resident_cd		IGS_ST_GOVT_STDNT_EN.perm_resident_cd%TYPE;
	v_govt_perm_resident_cd		IGS_ST_GOVT_STDNT_EN.govt_perm_resident_cd%TYPE;
	v_home_location_cd		IGS_ST_GOVT_STDNT_EN.home_location%TYPE;
	v_govt_home_location_cd		IGS_ST_GOVT_STDNT_EN.govt_home_location%TYPE;
	v_term_location_cd		IGS_ST_GOVT_STDNT_EN.term_location%TYPE;
	v_govt_term_location_cd		IGS_ST_GOVT_STDNT_EN.govt_term_location%TYPE;
	v_home_location_postcode	IGS_PE_STATISTICS.home_location_postcode%TYPE;
	v_home_location_country		IGS_PE_STATISTICS.home_location_country%TYPE;
	v_term_location_postcode	IGS_PE_STATISTICS.term_location_postcode%TYPE;
	v_term_location_country		IGS_PE_STATISTICS.term_location_country%TYPE;
	v_birth_country_cd		IGS_ST_GOVT_STDNT_EN.birth_country_cd%TYPE;
	v_govt_birth_country_cd		IGS_ST_GOVT_STDNT_EN.govt_birth_country_cd%TYPE;
	v_yr_arrival			IGS_ST_GOVT_STDNT_EN.yr_arrival%TYPE;
	v_home_language_cd		IGS_ST_GOVT_STDNT_EN.home_language_cd%TYPE;
	v_govt_home_language_cd		IGS_ST_GOVT_STDNT_EN.govt_home_language_cd%TYPE;
	v_prior_ug_inst			IGS_ST_GOVT_STDNT_EN.prior_ug_inst%TYPE;
	v_govt_prior_ug_inst		IGS_ST_GOVT_STDNT_EN.govt_prior_ug_inst%TYPE;
	v_prior_other_qual		IGS_ST_GOVT_STDNT_EN.prior_other_qual%TYPE;
	v_prior_post_grad		IGS_ST_GOVT_STDNT_EN.prior_post_grad%TYPE;
	v_prior_degree			IGS_ST_GOVT_STDNT_EN.prior_degree%TYPE;
	v_prior_subdeg_notafe		IGS_ST_GOVT_STDNT_EN.prior_subdeg_notafe%TYPE;
	v_prior_subdeg_tafe		IGS_ST_GOVT_STDNT_EN.prior_subdeg_tafe%TYPE;
	v_prior_seced_tafe		IGS_ST_GOVT_STDNT_EN.prior_seced_tafe%TYPE;
	v_prior_seced_school		IGS_ST_GOVT_STDNT_EN.prior_seced_school%TYPE;
	v_prior_tafe_award		IGS_ST_GOVT_STDNT_EN.prior_tafe_award%TYPE;
	v_prior_studies_exemption	IGS_ST_GOVT_STDNT_EN.prior_studies_exemption%TYPE;
	v_exempt_institution_cd
					IGS_ST_GOVT_STDNT_EN.exemption_institution_cd%TYPE;
	v_govt_exempt_institution_cd
					IGS_ST_GOVT_STDNT_EN.govt_exemption_institution_cd%TYPE;
	v_tertiary_entrance_score	IGS_ST_GOVT_STDNT_EN.tertiary_entrance_score%TYPE;
	v_basis_for_admission_type
					IGS_ST_GOVT_STDNT_EN.basis_for_admission_type%TYPE;
	v_govt_basis_for_adm_type
					IGS_ST_GOVT_STDNT_EN.govt_basis_for_admission_type% TYPE;
	v_hecs_amount_pd		IGS_ST_GVT_STDNT_LBL.hecs_amount_paid%TYPE;
	v_hecs_payment_option		IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE;
	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
	v_tuition_fee			IGS_ST_GVT_STDNT_LBL.tuition_fee%TYPE;
	v_hecs_fee			NUMBER;
	v_differential_hecs_ind		IGS_ST_GVT_STDNT_LBL.differential_hecs_ind%TYPE;
	v_industrial_ind		IGS_ST_GVT_STDNTLOAD.industrial_ind%TYPE;
	v_unit_cd			IGS_ST_GVT_STDNTLOAD.unit_cd%TYPE DEFAULT NULL;
	v_uv_version_number		IGS_ST_GVT_STDNTLOAD.uv_version_number%TYPE DEFAULT NULL;
	v_unit_completion_status	IGS_ST_GVT_STDNTLOAD.unit_completion_status%TYPE;
	v_indus_eftsu			IGS_ST_GVT_STDNT_LBL.industrial_eftsu%TYPE;
	v_total_eftsu			IGS_ST_GVT_STDNT_LBL.total_eftsu%TYPE;
	v_hecs_prexmt_exie_update	IGS_ST_GVT_STDNT_LBL.hecs_prexmt_exie%TYPE;
	v_hecs_prexmt_exie		IGS_ST_GVT_STDNT_LBL.hecs_prexmt_exie%TYPE;
	v_first_flag 			BOOLEAN;
	v_temp_person_id		NUMBER;
	v_tmp_person_id			NUMBER;
	v_flag				BOOLEAN;
	v_prev_sub			BOOLEAN;
	v_s_unit_mode			IGS_AS_UNIT_MODE.s_unit_mode%TYPE;
	v_govt_attendance_mode		IGS_EN_ATD_MODE.govt_attendance_mode%TYPE;
	v_attendance_mode		IGS_EN_ATD_MODE.attendance_mode%TYPE;
	v_lower_enr_load_range		IGS_EN_ATD_TYPE.lower_enr_load_range%TYPE;
	v_major_course			IGS_ST_GOVT_STDNT_EN.major_course%TYPE;
	v_on				BOOLEAN DEFAULT FALSE;
	v_off				BOOLEAN DEFAULT FALSE;
	v_composite			BOOLEAN DEFAULT FALSE;
	v_unit_total_eftsu		IGS_ST_GVT_STDNTLOAD.eftsu%TYPE;
	v_unit_industrial_eftsu		IGS_ST_GVT_STDNTLOAD.eftsu%TYPE;
	v_logged_ind			BOOLEAN;
	v_s_log_type			Varchar2(10);
	v_creation_dt			IGS_GE_S_LOG.creation_dt%TYPE;
	v_upd_total_eftsu		IGS_ST_GVT_STDNT_LBL.total_eftsu%TYPE;
	v_upd_indus_eftsu		IGS_ST_GVT_STDNT_LBL.industrial_eftsu%TYPE;
	v_owner				all_indexes.owner%TYPE;
	v_command			VARCHAR2(600);
	v_command_cursor		INTEGER;
	v_ret				INTEGER;
	v_start_dt_time			DATE;
	v_award_course_ind		IGS_PS_TYPE.award_course_ind%TYPE;
	v_fee_cat			IGS_FI_FEE_CAT.fee_cat%TYPE;
	v_old_govt_semester		IGS_ST_GVT_STDNTLOAD.govt_semester%TYPE DEFAULT NULL;
	v_old_person_id			IGS_PE_PERSON.person_id%TYPE;
	v_old_course_cd			IGS_PS_VER.course_cd%TYPE;
	v_appl_owner			all_indexes.owner%TYPE;
	v_start_dt			DATE;
	v_end_dt			DATE;
	v_start_dt_2			DATE;
	v_end_dt_2			DATE;
	v_other_detail			VARCHAR2(255);
	v_ret				INTEGER;
    v_unit_completion_stat NUMBER;
    CURSOR Cur_si_st_govtstdldtmp IS
            SELECT sgs.*,uoo.uoo_id
            FROM  IGS_ST_GVT_STDNTLOAD sgs,
                  igs_ps_unit_ofr_opt uoo
		WHERE	sgs.submission_yr = p_submission_yr AND
			sgs.submission_number = (p_submission_number - 1) AND
            sgs.unit_cd = uoo.unit_cd AND
            sgs.uv_version_number = uoo.version_number AND
            sgs.sua_cal_type  = uoo.cal_type AND
            sgs.sua_ci_sequence_number  = uoo.ci_sequence_number AND
            sgs.sua_location_cd = uoo.location_cd  AND
            sgs.unit_class = uoo.unit_class
		ORDER BY Person_id;

	CURSOR  c_govt_snpsht_ctl IS
		SELECT  gsc.submission_yr
		FROM	IGS_ST_GVT_SPSHT_CTL gsc
		WHERE	gsc.submission_yr	= p_submission_yr AND
			gsc.submission_number	= p_submission_number;
	CURSOR c_gsc_upd IS
		SELECT  rowid, gsc.*
		FROM	IGS_ST_GVT_SPSHT_CTL gsc
		WHERE	gsc.submission_yr	= p_submission_yr AND
			gsc.submission_number	= p_submission_number
		FOR UPDATE OF gsc.ess_snapshot_dt_time NOWAIT;
	CURSOR  c_gsc IS
		SELECT  gsc.ess_snapshot_dt_time
		FROM	IGS_ST_GVT_SPSHT_CTL gsc
		WHERE	gsc.submission_yr	= p_submission_yr AND
			gsc.submission_number	= 2;
	CURSOR 	c_essc IS
		SELECT 	essc.snapshot_dt_time
		FROM   	IGS_EN_ST_SPSHT_CTL essc
		ORDER BY essc.snapshot_dt_time DESC;
	CURSOR c_essc_upd (
		cp_ess_snapshot_dt_time	IGS_EN_ST_SPSHT_CTL.snapshot_dt_time%TYPE) IS
		SELECT rowid, essc.*
		FROM	IGS_EN_ST_SPSHT_CTL	essc
		WHERE	snapshot_dt_time = cp_ess_snapshot_dt_time
		FOR UPDATE OF essc.delete_snapshot_ind NOWAIT;
	CURSOR 	c_get_att_type IS
		SELECT 	aty.attendance_type,
	       		aty.govt_attendance_type
		FROM   	IGS_EN_ATD_TYPE aty
		WHERE 	aty.govt_attendance_type = 2 AND
			aty.upper_enr_load_range > 0;
	CURSOR 	c_get_att_mode_1 IS
		SELECT 	atm.attendance_mode,
	       		atm.govt_attendance_mode
		FROM   	IGS_EN_ATD_MODE atm
		WHERE 	atm.govt_attendance_mode = '1'
		ORDER BY atm.attendance_mode ASC;
	CURSOR 	c_get_att_mode_2 IS
		SELECT	atm.attendance_mode,
	    	   	atm.govt_attendance_mode
		FROM   	IGS_EN_ATD_MODE atm
		WHERE 	atm.govt_attendance_mode = '2'
		ORDER BY atm.attendance_mode ASC;
	CURSOR 	c_get_att_mode_3 IS
		SELECT 	atm.attendance_mode,
	    	   	atm.govt_attendance_mode
		FROM   	IGS_EN_ATD_MODE atm
		WHERE 	atm.govt_attendance_mode = '3'
		ORDER BY atm.attendance_mode ASC;
	CURSOR	c_enr_snpsht_rec (
		cp_dt_time	IGS_ST_GVT_SPSHT_CTL.ess_snapshot_dt_time%TYPE) IS
		SELECT	ess.ci_cal_type,
			ess.ci_sequence_number,
			ess.person_id,
			ess.course_cd,
			ess.crv_version_number,
			ess.unit_cd,
			ess.uv_version_number,
			ess.sua_cal_type,
			ess.sua_ci_sequence_number,
			ess.tr_org_unit_cd,
			ess.tr_ou_start_dt,
			ess.discipline_group_cd,
			ess.govt_discipline_group_cd,
			ess.unit_class,
			ess.enrolled_dt,
			ess.discontinued_dt,
			ess.eftsu,
			ess.commencing_student_ind,
			ct.award_course_ind,
            uoo.uoo_id,
            ess.sua_location_cd
		FROM	IGS_EN_ST_SNAPSHOT ess,
			IGS_PS_TYPE		ct,
            igs_ps_unit_ofr_opt uoo
		WHERE	ess.snapshot_dt_time 	= cp_dt_time AND
			ess.govt_reportable_ind	<> 'X' AND
			ct.course_type		= ess.course_type AND
            ess.unit_cd = uoo.unit_cd AND
            ess.uv_version_number = uoo.version_number  AND
            ess.sua_cal_type  = uoo.cal_type AND
            ess.sua_ci_sequence_number  = uoo.ci_sequence_number AND
            ess.sua_location_cd = uoo.location_cd AND
            ess.unit_class = uoo.unit_class
		ORDER BY	ess.person_id			ASC,
			 	ess.course_cd			ASC,
				ess.ci_cal_type			ASC,
				ess.ci_sequence_number		ASC,
		 		ess.sua_cal_type		ASC,
			 	ess.sua_ci_sequence_number	ASC,
				ess.unit_cd			ASC;
	CURSOR c_alias_val (
		cp_teach_cal_type IGS_CA_DA_INST_V.cal_type%TYPE,
		cp_teach_ci_seq_num IGS_CA_DA_INST_V.ci_sequence_number%TYPE) IS
		SELECT  daiv.alias_val
		FROM	IGS_CA_DA_INST_V daiv,
			IGS_GE_S_GEN_CAL_CON sgcc
		WHERE	daiv.cal_type		= cp_teach_cal_type AND
			daiv.ci_sequence_number = cp_teach_ci_seq_num AND
			daiv.dt_alias		= sgcc.census_dt_alias
		ORDER BY daiv.alias_val ASC;
	CURSOR c_ci (
		cp_teach_cal_type		IGS_EN_ST_SNAPSHOT.sua_cal_type%TYPE,
		cp_teach_ci_sequence_number
						IGS_EN_ST_SNAPSHOT.sua_ci_sequence_number%TYPE) IS
		SELECT	ci.start_dt,
			ci.end_dt
		FROM	IGS_CA_INST	ci
		WHERE	ci.cal_type		= cp_teach_cal_type AND
			ci.sequence_number	= cp_teach_ci_sequence_number;
	CURSOR c_get_api (
		cp_person_id	IGS_PE_PERSON.person_id%TYPE,
		cp_eff_dt	DATE) IS
		SELECT 	api.pe_person_id
		FROM	IGS_PE_ALT_PERS_ID api,
			IGS_PE_PERSON_ID_TYP pit
		WHERE	api.api_person_id	= TO_CHAR(cp_person_id) AND
			pit.person_id_type	= api.person_id_type AND
			pit.s_person_id_type	= 'OBSOLETE' AND
			api.start_dt		IS NOT NULL AND
			api.start_dt		<= cp_eff_dt AND
			(api.end_dt		IS NULL OR
			 api.end_dt		>= cp_eff_dt) AND
			(api.end_dt		IS NULL OR
		         api.start_dt		<> api.end_dt)
		ORDER BY api.end_dt ASC;
	CURSOR c_gse_att_mode IS
		SELECT	DISTINCT
			gse.person_id,
			gse.course_cd
		FROM	IGS_ST_GOVT_STDNT_EN gse
		WHERE	gse.submission_yr	= p_submission_yr AND
			gse.submission_number	= p_submission_number;
	CURSOR c_gslo (
		cp_person_id	IGS_ST_GVT_STDNTLOAD.person_id%TYPE,
		cp_course_cd 	IGS_ST_GVT_STDNTLOAD.course_cd%TYPE) IS
		SELECT  gslo.unit_cd,
			gslo.sua_cal_type,
			gslo.sua_ci_sequence_number,
			gslo.govt_semester,
			gslo.tr_org_unit_cd,
			gslo.tr_ou_start_dt,
			gslo.discipline_group_cd,
			gslo.govt_discipline_group_cd,
            gslo.sua_location_cd,
            gslo.unit_class
		FROM	IGS_ST_GVT_STDNTLOAD gslo
		WHERE	gslo.submission_yr	= p_submission_yr AND
			gslo.submission_number	= p_submission_number AND
			gslo.person_id		= cp_person_id AND
			gslo.course_cd		= cp_course_cd AND
			gslo.eftsu		<> 0;
	CURSOR c_sua_ucl_um (
		cp_person_id		IGS_ST_GOVT_STDNT_EN.person_id%TYPE,
		cp_course_cd		IGS_ST_GOVT_STDNT_EN.course_cd%TYPE,
		cp_unit_cd		IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
		cp_cal_type		IGS_CA_TYPE.cal_type%TYPE,
		cp_ci_seq_num		IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
        cp_location_cd IGS_EN_SU_ATTEMPT.location_cd%TYPE,
        cp_unit_class IGS_EN_SU_ATTEMPT.unit_class%TYPE) IS
		SELECT 	um.s_unit_mode
		FROM	IGS_EN_SU_ATTEMPT	sua,
			IGS_AS_UNIT_CLASS		ucl,
			IGS_AS_UNIT_MODE		um
		WHERE  	sua.person_id		= cp_person_id AND
			sua.course_cd		= cp_course_cd AND
			sua.unit_cd		= cp_unit_cd AND
			sua.cal_type		= cp_cal_type AND
			sua.ci_sequence_number	= cp_ci_seq_num AND
            sua.location_cd = cp_location_cd AND
            sua.unit_class = cp_unit_class AND
			ucl.unit_class		= sua.unit_class AND
			ucl.closed_ind          = 'N' AND
			um.unit_mode		= ucl.unit_mode;
	CURSOR c_att IS
		SELECT	att.attendance_type,
			att.govt_attendance_type,
			att.lower_enr_load_range
		FROM	IGS_EN_ATD_TYPE att
		WHERE	att.govt_attendance_type = 1 AND
			att.lower_enr_load_range > 0;
	CURSOR c_gse (
		cp_lower_enr_load_range		IGS_EN_ATD_TYPE.lower_enr_load_range%TYPE) IS
		SELECT	DISTINCT
			gse.person_id
		FROM	IGS_ST_GOVT_STDNT_EN gse
		WHERE	gse.submission_yr	= p_submission_yr AND
			gse.submission_number	= p_submission_number AND
			cp_lower_enr_load_range <=
				(SELECT	SUM(gsl.eftsu)
				FROM	IGS_ST_GVT_STDNTLOAD gsl
				WHERE	gsl.submission_yr	= p_submission_yr AND
					gsl.submission_number	= p_submission_number AND
					gsl.person_id		= gse.person_id);
	-- Cursor for searching through ess records to find students
	-- with more than one IGS_PS_COURSE
	CURSOR c_gse2 IS
		SELECT	gse.person_id,
			gse.course_cd
		FROM	IGS_ST_GOVT_STDNT_EN gse
		WHERE	gse.submission_yr	= p_submission_yr AND
			gse.submission_number	= p_submission_number
		ORDER BY
			gse.person_id;
	-- Called when a student is found more than once in gse
	CURSOR c_gse_sca (
		cp_person_id		IGS_ST_GOVT_STDNT_EN.person_id%TYPE) IS
		SELECT	gse.person_id,
			gse.course_cd,
			SUM(gslo.eftsu)
		FROM	IGS_ST_GOVT_STDNT_EN gse,
			IGS_ST_GVT_STDNTLOAD gslo,
			IGS_EN_STDNT_PS_ATT	sca
		WHERE	gse.submission_yr	= p_submission_yr AND
			gse.submission_number	= p_submission_number AND
			gse.person_id		= cp_person_id AND
			1 < 	(SELECT	COUNT(DISTINCT gse2.course_cd)
				FROM	IGS_ST_GOVT_STDNT_EN gse2
				WHERE	gse2.submission_yr	= p_submission_yr AND
					gse2.submission_number	= p_submission_number AND
					gse2.person_id		= cp_person_id) AND
			sca.person_id		= gse.person_id AND
			sca.course_cd		= gse.course_cd AND
			gslo.submission_yr	= gse.submission_yr AND
			gslo.submission_number	= gse.submission_number AND
			gslo.person_id		= gse.person_id AND
			gslo.course_cd		= gse.course_cd
		GROUP BY 	gse.person_id,
				gse.course_cd,
				sca.commencement_dt
		ORDER BY	gse.person_id		ASC,
				SUM(gslo.eftsu)		DESC,
				sca.commencement_dt	ASC;
		CURSOR c_gsli_upd IS
		SELECT rowid, gsli.*
		FROM   IGS_ST_GVT_STDNT_LBL gsli
		WHERE  submission_yr		= p_submission_yr AND
		       submission_number	= p_submission_number
		FOR UPDATE OF gsli.last_updated_by NOWAIT;
	CURSOR c_gsli_upd2 (
		cp_person_id		IGS_ST_GVT_STDNT_LBL.person_id%TYPE,
		cp_course_cd		IGS_ST_GVT_STDNT_LBL.course_cd%TYPE,
		cp_govt_semester	IGS_ST_GVT_STDNT_LBL.govt_semester%TYPE) IS
		SELECT rowid, gsli.*
		FROM	IGS_ST_GVT_STDNT_LBL	gsli
		WHERE	gsli.submission_yr	= p_submission_yr AND
			gsli.submission_number	= p_submission_number AND
			gsli.person_id		= cp_person_id AND
			gsli.course_cd		= cp_course_cd AND
			gsli.govt_semester	= cp_govt_semester
		FOR UPDATE OF gsli.last_updated_by NOWAIT;
	CURSOR c_gslo_upd IS
		SELECT rowid,gslo.*
		FROM   IGS_ST_GVT_STDNTLOAD gslo
		WHERE  submission_yr		= p_submission_yr AND
		       submission_number	= p_submission_number
		FOR UPDATE OF gslo.last_updated_by NOWAIT;
	CURSOR c_get_indus_ind (
		cp_unit_cd		IGS_PS_UNIT_VER.unit_cd%TYPE,
		cp_version_number	IGS_PS_UNIT_VER.version_number%TYPE) IS
		SELECT	uv.industrial_ind
		FROM	IGS_PS_UNIT_VER	uv
		WHERE	uv.unit_cd		= cp_unit_cd AND
			uv.version_number	= cp_version_number;
	CURSOR c_update_total_eftsu IS
		SELECT  gslo.person_id,
			gslo.course_cd,
			gslo.govt_semester,
			NVL(SUM(gslo.eftsu), 0) v_upd_total_eftsu
		FROM	IGS_ST_GVT_STDNTLOAD gslo
		WHERE	gslo.submission_yr	= p_submission_yr AND
			gslo.submission_number	= p_submission_number
		GROUP BY gslo.person_id,
			 gslo.course_cd,
			 gslo.govt_semester;
	CURSOR c_update_indus_eftsu IS
		SELECT  gslo.person_id,
			gslo.course_cd,
			gslo.govt_semester,
			NVL(SUM(gslo.eftsu), 0) v_upd_indus_eftsu
		FROM	IGS_ST_GVT_STDNTLOAD gslo
		WHERE	gslo.submission_yr	= p_submission_yr AND
			gslo.submission_number	= p_submission_number AND
			gslo.industrial_ind	= 'Y'
		GROUP BY gslo.person_id,
			 gslo.course_cd,
			 gslo.govt_semester;
	CURSOR c_gse_upd IS
		SELECT rowid,gse.*
		FROM   IGS_ST_GOVT_STDNT_EN gse
		WHERE  submission_yr		= p_submission_yr AND
		       submission_number	= p_submission_number
		FOR UPDATE OF gse.last_updated_by NOWAIT;
	CURSOR c_gse_upd2 (
		cp_person_id		IGS_ST_GOVT_STDNT_EN.person_id%TYPE) IS
		SELECT rowid, gse.*
		FROM	IGS_ST_GOVT_STDNT_EN	gse
		WHERE	submission_yr		= p_submission_yr AND
			submission_number	= p_submission_number AND
			person_id		= cp_person_id
		FOR UPDATE OF gse.last_updated_by NOWAIT;
	CURSOR c_gse_upd3 (
		cp_person_id		IGS_ST_GOVT_STDNT_EN.person_id%TYPE,
		cp_course_cd		IGS_ST_GOVT_STDNT_EN.course_cd%TYPE) IS
		SELECT	rowid, gse.*
		FROM	IGS_ST_GOVT_STDNT_EN	gse
		WHERE	gse.submission_yr	= p_submission_yr AND
			gse.submission_number	= p_submission_number AND
			gse.person_id		= cp_person_id AND
			gse.course_cd		= cp_course_cd
		FOR UPDATE OF gse.last_updated_by NOWAIT;
	CURSOR c_gsli IS
		SELECT	UNIQUE
			gsli.person_id,
			gsli.course_cd,
			gsli.version_number,
			gsli.commencement_dt
		FROM	IGS_ST_GVT_STDNT_LBL	gsli
		WHERE	gsli.submission_yr	= p_submission_yr AND
			gsli.submission_number	= p_submission_number;
	CURSOR c_gsli_upd_commencement (
		cp_person_id	IGS_ST_GVT_STDNT_LBL.person_id%TYPE,
		cp_course_cd	IGS_ST_GVT_STDNT_LBL.course_cd%TYPE) IS
		SELECT	rowid,gsli.*
		FROM	IGS_ST_GVT_STDNT_LBL	gsli
		WHERE	gsli.submission_yr	= p_submission_yr AND
			gsli.submission_number	= p_submission_number AND
			gsli.person_id		= cp_person_id AND
			gsli.course_cd		= cp_course_cd
		FOR UPDATE OF gsli.commencement_dt NOWAIT;
	CURSOR c_gse_enrolment IS
		SELECT	UNIQUE
			gse.person_id,
			gse.course_cd,
			gse.version_number,
			gse.commencement_dt
		FROM	IGS_ST_GOVT_STDNT_EN	gse
		WHERE	gse.submission_yr	= p_submission_yr AND
			gse.submission_number	= p_submission_number;
	CURSOR c_gse_upd_commencement (
		cp_person_id	IGS_ST_GVT_STDNT_LBL.person_id%TYPE,
		cp_course_cd	IGS_ST_GVT_STDNT_LBL.course_cd%TYPE) IS
		SELECT rowid,gse.*
		FROM	IGS_ST_GOVT_STDNT_EN	gse
		WHERE	gse.submission_yr	= p_submission_yr AND
			gse.submission_number	= p_submission_number AND
			gse.person_id		= cp_person_id AND
			gse.course_cd		= cp_course_cd
		FOR UPDATE OF gse.commencement_dt NOWAIT;

      PROCEDURE stapl_val_unit_compltn_status(
		p_person_id			IGS_EN_ST_SNAPSHOT.person_id%TYPE,
		p_course_cd			IGS_EN_ST_SNAPSHOT.course_cd%TYPE,
		p_unit_cd			IGS_EN_ST_SNAPSHOT.unit_cd%TYPE,
		p_sua_cal_type			IGS_EN_ST_SNAPSHOT.sua_cal_type%TYPE,
		p_sua_ci_sequence_number	IGS_EN_ST_SNAPSHOT.sua_ci_sequence_number%TYPE,
		p_unit_completion_status	OUT NOCOPY NUMBER,
        p_uoo_id          igs_ps_unit_ofr_opt.uoo_id%TYPE)
	AS
		gv_other_detail			VARCHAR2(255);
	BEGIN
	DECLARE
	BEGIN
		-- get the course UNIT completion status
		p_unit_completion_status := stap_get_un_comp_sts(
							p_person_id,
							p_course_cd,
							p_unit_cd,
							p_sua_cal_type,
							p_sua_ci_sequence_number,
                            p_uoo_id);
	END;
	EXCEPTION
		WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stapl_val_unit_compltn_status');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
 	END stapl_val_unit_compltn_status;
	PROCEDURE stapl_ins_govt_sdnt_load_rec(
		p_sub_yr			IGS_ST_GVT_STDNTLOAD.submission_yr%TYPE,
		p_sub_number			IGS_ST_GVT_STDNTLOAD.submission_number%TYPE,
		p_person_id			IGS_ST_GVT_STDNTLOAD.person_id%TYPE,
		p_course_cd			IGS_ST_GVT_STDNTLOAD.course_cd%TYPE,
		p_crv_version_number		IGS_ST_GVT_STDNTLOAD.crv_version_number%TYPE,
		p_govt_semester			IGS_ST_GVT_STDNTLOAD.govt_semester%TYPE,
		p_unit_cd			IGS_ST_GVT_STDNTLOAD.unit_cd%TYPE,
		p_uv_version_number		IGS_ST_GVT_STDNTLOAD.uv_version_number%TYPE,
		p_sua_cal_type			IGS_ST_GVT_STDNTLOAD.sua_cal_type%TYPE,
		p_sua_ci_sequence_number 	IGS_ST_GVT_STDNTLOAD.sua_ci_sequence_number%TYPE,
		p_tr_org_unit_cd		IGS_ST_GVT_STDNTLOAD.tr_org_unit_cd%TYPE,
		p_tr_ou_start_dt		IGS_ST_GVT_STDNTLOAD.tr_ou_start_dt%TYPE,
		p_discipline_group_cd		IGS_ST_GVT_STDNTLOAD.discipline_group_cd%TYPE,
		p_govt_discipline_group_cd	IGS_ST_GVT_STDNTLOAD.govt_discipline_group_cd%TYPE,
		p_industrial_ind		IGS_ST_GVT_STDNTLOAD.industrial_ind%TYPE,
		p_eftsu				NUMBER,
		p_unit_completion_status 	IGS_ST_GVT_STDNTLOAD.unit_completion_status%TYPE,
		p_logged_ind		IN OUT NOCOPY 	BOOLEAN,
		p_s_log_type			VARCHAR2,
		p_creation_dt			DATE,
        p_sua_location_cd IN IGS_ST_GVT_STDNTLOAD.sua_location_cd%TYPE,
        p_unit_class      IN IGS_ST_GVT_STDNTLOAD.unit_class%TYPE)
	AS
		gv_other_detail		VARCHAR2(255);
	BEGIN
	DECLARE
            v_rowid			VARCHAR2(25);
	BEGIN
		-- insert a record into IGS_ST_GVT_STDNTLOAD
		-- to insert row using the insertrow of TBH package
            IGS_ST_GVT_STDNTLOAD_PKG.INSERT_ROW(
                  X_ROWID => v_rowid,
			X_SUBMISSION_YR => p_sub_yr,
			X_SUBMISSION_NUMBER => p_sub_number,
			X_PERSON_ID => p_person_id,
			X_COURSE_CD => p_course_cd,
			X_CRV_VERSION_NUMBER => p_crv_version_number,
			X_GOVT_SEMESTER => p_govt_semester,
			X_UNIT_CD => p_unit_cd,
			X_UV_VERSION_NUMBER => p_uv_version_number,
			X_SUA_CAL_TYPE => p_sua_cal_type,
			X_SUA_CI_SEQUENCE_NUMBER => p_sua_ci_sequence_number,
			X_TR_ORG_UNIT_CD => p_tr_org_unit_cd,
			X_TR_OU_START_DT => p_tr_ou_start_dt,
			X_DISCIPLINE_GROUP_CD => p_discipline_group_cd,
			X_GOVT_DISCIPLINE_GROUP_CD => p_govt_discipline_group_cd,
			X_INDUSTRIAL_IND => p_industrial_ind,
			X_EFTSU => p_eftsu,
			X_UNIT_COMPLETION_STATUS => p_unit_completion_status,
			X_MODE   => 'R',
            X_SUA_LOCATION_CD => p_sua_location_cd,
            X_UNIT_CLASS => p_unit_class);

		IF p_eftsu > 1 THEN
			--Check if an entry has been written to the error log
			IF p_logged_ind = FALSE THEN

        -- set that an error has been logged
				p_logged_ind := TRUE;
			END IF;
			--Create an entry in the system log entry
			IGS_GE_GEN_003.genp_ins_log_entry (
					p_s_log_type,
					p_creation_dt,
						'IGS_PE_PERSON IGS_PS_COURSE IGS_PS_UNIT ' || ',' ||
						TO_CHAR(p_person_id) || ',' ||
						p_course_cd || ',' ||
						p_unit_cd,
					4221,
					NULL);
		END IF;
	END;
	EXCEPTION
		WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stapl_ins_govt_sdnt_load_rec');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
	END stapl_ins_govt_sdnt_load_rec;
	PROCEDURE stapl_get_sca_data_for_liab(
		p_current_person_id		IGS_EN_ST_SNAPSHOT.person_id%TYPE,
		-- current person_id
		p_old_person_id			IGS_EN_ST_SNAPSHOT.person_id%TYPE,
		-- last person_id retrieved
		p_current_course_cd		IGS_EN_ST_SNAPSHOT.course_cd%TYPE,
		-- current course_cd
		p_old_course_cd			IGS_EN_ST_SNAPSHOT.course_cd%TYPE,
		-- last course_cdretrieved
		p_effective_dt			DATE,
		p_logged_ind		IN OUT NOCOPY	BOOLEAN,
		p_s_log_type			VARCHAR2,
		p_creation_dt			IGS_GE_S_LOG.creation_dt%TYPE,
		p_birth_dt		IN OUT NOCOPY	IGS_ST_GOVT_STDNT_EN.birth_dt%TYPE,
		p_sex			IN OUT NOCOPY 	IGS_ST_GOVT_STDNT_EN.sex%TYPE,
		p_citizenship_cd	IN OUT NOCOPY	IGS_ST_GOVT_STDNT_EN.citizenship_cd%TYPE,
		p_govt_citizenship_cd	IN OUT NOCOPY	IGS_ST_GOVT_STDNT_EN.govt_citizenship_cd%TYPE,
		p_perm_resident_cd	IN OUT NOCOPY	IGS_ST_GOVT_STDNT_EN.perm_resident_cd%TYPE,
		p_govt_perm_resident_cd	IN OUT NOCOPY
						IGS_ST_GOVT_STDNT_EN.govt_perm_resident_cd%TYPE)
	AS
		gv_other_detail			VARCHAR2(255);
		GE_SCA_NOTFOUND			EXCEPTION;
	BEGIN
	DECLARE
		v_other_detail			VARCHAR2(255);
		v_current_log_ind		BOOLEAN;
		CURSOR  c_get_person_dtls IS
			SELECT	pe.birth_dt,
				pe.sex
			FROM	IGS_PE_PERSON pe
			WHERE	pe.person_id = p_current_person_id;
		CURSOR	c_prsn_stats IS
			SELECT	ps.citizenship_cd,
				ps.perm_resident_cd
			FROM	IGS_PE_STATISTICS ps
			WHERE	ps.person_id = p_current_person_id AND
				ps.start_dt <= p_effective_dt AND
				(ps.end_dt IS NULL OR
		 		ps.end_dt >= p_effective_dt)
			ORDER BY ps.end_dt ASC;
		CURSOR  c_citz IS
			SELECT 	ccd.govt_citizenship_cd
			FROM   	IGS_ST_CITIZENSHP_CD ccd
			WHERE	ccd.citizenship_cd = p_citizenship_cd;
		CURSOR  c_perm_res (
				cp_perm_res_cd	IGS_PE_PERM_RES_CD.perm_resident_cd%TYPE) IS
			SELECT 	prcd.govt_perm_resident_cd
			FROM   	IGS_PE_PERM_RES_CD prcd
			WHERE	prcd.perm_resident_cd = cp_perm_res_cd;
	BEGIN
		-- only get the IGS_PE_PERSON data if the IGS_PE_PERSON has changed
		IF p_old_person_id IS NULL OR
				p_old_person_id <> p_current_person_id THEN
			p_birth_dt := NULL;
			p_sex := NULL;
			p_citizenship_cd := NULL;
			p_govt_citizenship_cd := NULL;
			p_perm_resident_cd := NULL;
			p_govt_perm_resident_cd := NULL;
			-- get the IGS_PE_PERSON data
			OPEN  c_get_person_dtls;
			FETCH c_get_person_dtls INTO	p_birth_dt,
					   	  	p_sex;
			-- raise an exception if no IGS_PE_PERSON record found
			IF (c_get_person_dtls%NOTFOUND) THEN
				CLOSE c_get_person_dtls;
				 Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
			END IF;
			CLOSE c_get_person_dtls;
			IF (p_birth_dt IS NULL) THEN
				IF (p_logged_ind = FALSE) THEN
					-- log an error to the IGS_GE_S_ERROR_LOG
					-- using IGS_GE_GEN_003.genp_log_error

                    -- set that an error has been logged
					p_logged_ind := TRUE;
				END IF;
				-- create an entry in the system log entry
				IGS_GE_GEN_003.genp_ins_log_entry (
					p_s_log_type,
					p_creation_dt,
						'IGS_PE_PERSON' || ',' ||
						TO_CHAR(p_current_person_id),
					4194,
					NULL);
			END IF;
			-- retrieve the IGS_PE_PERSON statistics data
			-- get the first record only, which will
			-- be the end dated record if one exists
			OPEN  c_prsn_stats;
			FETCH c_prsn_stats INTO	p_citizenship_cd,
						p_perm_resident_cd;
			-- raise a user exception if no record exists
			IF (c_prsn_stats%NOTFOUND) THEN
				CLOSE c_prsn_stats;
				IF (p_logged_ind = FALSE) THEN
					-- log an error to the IGS_GE_S_ERROR_LOG
					-- using IGS_GE_GEN_003.genp_log_error

					p_logged_ind := TRUE;
				END IF;
				-- create an entry in the system log entry
				IGS_GE_GEN_003.genp_ins_log_entry (
					p_s_log_type,
					p_creation_dt,
					'IGS_PE_PERSON' || ',' || TO_CHAR(p_current_person_id),
					4196,
					NULL);
			ELSE
				CLOSE c_prsn_stats;
			END IF;
			-- reset statistics values and set the government values
			-- citizenship code
			IF (p_citizenship_cd IS NOT NULL) THEN
				-- a record will always exist because of
				-- referential integrity
				OPEN  c_citz;
				FETCH c_citz INTO p_govt_citizenship_cd;
				CLOSE c_citz;
			ELSE
				p_citizenship_cd := '9';
				p_govt_citizenship_cd := 9;
				IF (p_logged_ind = FALSE) THEN
					-- log an error to the IGS_GE_S_ERROR_LOG
					-- using IGS_GE_GEN_003.genp_log_error

					p_logged_ind := TRUE;
				END IF;
				-- create an entry in the system log entry
				IGS_GE_GEN_003.genp_ins_log_entry (
					p_s_log_type,
					p_creation_dt,
					'IGS_PE_PERSON' || ',' || TO_CHAR(p_current_person_id),
					4202,
					NULL);
			END IF;
			-- permanent resident code
			IF (p_perm_resident_cd IS NOT NULL) THEN
				-- a record will always exist because of
				-- referential integrity
				OPEN  c_perm_res(p_perm_resident_cd);
				FETCH c_perm_res INTO p_govt_perm_resident_cd;
				CLOSE c_perm_res;
			ELSE
				IF p_govt_citizenship_cd in (2, 3, 9) then
					p_perm_resident_cd := '9';
					p_govt_perm_resident_cd := 9;
					IF (p_logged_ind = FALSE) THEN
						-- log an error to the IGS_GE_S_ERROR_LOG
						-- using IGS_GE_GEN_003.genp_log_error

						p_logged_ind := TRUE;
					END IF;
					-- create an entry in the system log entry
					IGS_GE_GEN_003.genp_ins_log_entry (
						p_s_log_type,
						p_creation_dt,
						'IGS_PE_PERSON' || ',' ||
						TO_CHAR(p_current_person_id),
						4203,
						NULL);
				ELSE
					p_perm_resident_cd := '0';
					p_govt_perm_resident_cd := 0;
					IF (p_logged_ind = FALSE) THEN
						-- log an error to the IGS_GE_S_ERROR_LOG
						-- using IGS_GE_GEN_003.genp_log_error

                    	-- set that an error has been logged
						p_logged_ind := TRUE;
					END IF;
					-- create an entry in the system log entry
					IGS_GE_GEN_003.genp_ins_log_entry (
						p_s_log_type,
						p_creation_dt,
						'IGS_PE_PERSON' || ',' ||
						TO_CHAR(p_current_person_id),
						4644,
						NULL);
				END IF;
			END IF;
		END IF;
	EXCEPTION
		WHEN GE_SCA_NOTFOUND THEN
			IF c_get_person_dtls%ISOPEN THEN
				CLOSE c_get_person_dtls;
			END IF;
			IF c_prsn_stats%ISOPEN THEN
				CLOSE c_prsn_stats;
			END IF;
			IF c_citz%ISOPEN THEN
				CLOSE c_citz;
			END IF;
			IF c_perm_res%ISOPEN THEN
				CLOSE c_perm_res;
			END IF;
			v_other_detail := 'Cannot find student IGS_PS_COURSE attempt data- ' ||
				TO_CHAR(p_current_person_id);
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;

                     App_Exception.Raise_Exception;
		WHEN OTHERS THEN
			IF c_get_person_dtls%ISOPEN THEN
				CLOSE c_get_person_dtls;
			END IF;
			IF c_prsn_stats%ISOPEN THEN
				CLOSE c_prsn_stats;
			END IF;
			IF c_citz%ISOPEN THEN
				CLOSE c_citz;
			END IF;
			IF c_perm_res%ISOPEN THEN
				CLOSE c_perm_res;
			END IF;
			RAISE;
	END;
	EXCEPTION
		WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stapl_get_sca_data_for_liab');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
  	END stapl_get_sca_data_for_liab;
	PROCEDURE stapl_ins_govt_sdnt_liab_rec (
		p_sub_yr			IGS_ST_GVT_STDNT_LBL.submission_yr%TYPE,
		p_sub_number			IGS_ST_GVT_STDNT_LBL.submission_number%TYPE,
		p_person_id			IGS_ST_GVT_STDNT_LBL.person_id%TYPE,
		p_course_cd			IGS_ST_GVT_STDNT_LBL.course_cd%TYPE,
		p_version_number		IGS_ST_GVT_STDNT_LBL.version_number%TYPE,
		p_govt_semester			IGS_ST_GVT_STDNT_LBL.govt_semester%TYPE,
		p_hecs_payment_option		IGS_ST_GVT_STDNT_LBL.hecs_payment_option%TYPE,
		p_govt_hpo			IGS_ST_GVT_STDNT_LBL.govt_hecs_payment_option%TYPE,
		p_hecs_amount_pd		IGS_ST_GVT_STDNT_LBL.hecs_amount_paid%TYPE,
		p_tuition_fee			IGS_ST_GVT_STDNT_LBL.tuition_fee%TYPE,
		p_differential_hecs_ind		IGS_ST_GVT_STDNT_LBL.differential_hecs_ind%TYPE,
		p_birth_dt			IGS_ST_GVT_STDNT_LBL.birth_dt%TYPE,
		p_sex				IGS_ST_GVT_STDNT_LBL.sex%TYPE,
		p_citizenship_cd		IGS_ST_GVT_STDNT_LBL.citizenship_cd%TYPE,
		p_govt_citizenship_cd		IGS_ST_GVT_STDNT_LBL.govt_citizenship_cd%TYPE,
		p_perm_resident_cd		IGS_ST_GVT_STDNT_LBL.perm_resident_cd%TYPE,
		p_govt_perm_resident_cd		IGS_ST_GVT_STDNT_LBL.govt_perm_resident_cd%TYPE,
		p_commencement_dt		IGS_ST_GVT_STDNT_LBL.commencement_dt%TYPE,
		p_hecs_fee			IGS_ST_GVT_STDNT_LBL.hecs_prexmt_exie%TYPE)
	AS
		gv_other_detail		VARCHAR2(255);
	BEGIN
	DECLARE
		v_other_detail		VARCHAR2(255);
            v_rowid			VARCHAR2(25);
	BEGIN
		-- create the student liability record
		IF ((p_sub_number = 1 AND
				p_govt_semester IN (1, 3, 5)) OR
				(p_sub_number = 2 AND
				p_govt_semester IN (2, 4))) THEN
			-- insert liability record
			BEGIN

                              -- to insert row using the insert row of the respective TBH package

                              IGS_ST_GVT_STDNT_LBL_PKG.INSERT_ROW(
                                     X_ROWID => v_rowid,
 						 X_SUBMISSION_YR => p_sub_yr,
						 X_SUBMISSION_NUMBER => p_sub_number,
						 X_PERSON_ID  => p_person_id,
						 X_COURSE_CD => p_course_cd,
 						 X_VERSION_NUMBER => p_version_number,
						 X_GOVT_SEMESTER => p_govt_semester,
						 X_HECS_PAYMENT_OPTION => p_hecs_payment_option,
						 X_GOVT_HECS_PAYMENT_OPTION => p_govt_hpo,
						 X_TOTAL_EFTSU => 0,
						 X_INDUSTRIAL_EFTSU => 0,
						 X_HECS_PREXMT_EXIE =>  p_hecs_fee,
						 X_HECS_AMOUNT_PAID  => p_hecs_amount_pd,
						 X_TUITION_FEE =>  p_tuition_fee,
						 X_DIFFERENTIAL_HECS_IND => 	p_differential_hecs_ind,
						 X_BIRTH_DT => p_birth_dt,
						 X_SEX => p_sex,
						 X_CITIZENSHIP_CD => p_citizenship_cd,
						 X_GOVT_CITIZENSHIP_CD => p_govt_citizenship_cd,
						 X_PERM_RESIDENT_CD => p_perm_resident_cd,
					       X_GOVT_PERM_RESIDENT_CD => p_govt_perm_resident_cd,
						 X_COMMENCEMENT_DT => p_commencement_dt,
						 X_MODE => 'R' );

			EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN
					-- don't raise an exception, just handle it
					NULL;
			END;
		END IF;
	END;
	EXCEPTION
		WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stapl_ins_govt_sdnt_liab_rec');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
   	END stapl_ins_govt_sdnt_liab_rec;

	BEGIN	-- main
	-- This process is used to create a snapshot of
	-- data to be reported to the government for a
	-- specified submission year and number

	v_start_dt_time := SYSDATE;
	-- validate the input parameters
	OPEN  c_govt_snpsht_ctl;
	FETCH c_govt_snpsht_ctl INTO v_sub_yr;
	IF c_govt_snpsht_ctl%NOTFOUND THEN
		CLOSE c_govt_snpsht_ctl;
		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
		RETURN FALSE;
	END IF;
	CLOSE c_govt_snpsht_ctl;
	-- an enrolment statistics snapshot is only
	-- required for submissions 1 and 2
	IF (p_submission_number IN (1, 2) AND
			(p_ess_snapshot_dt_time IS NULL AND
			(p_use_most_recent_ess_ind IS NULL OR
			p_use_most_recent_ess_ind <> 'Y'))) THEN
		p_message_name := 'IGS_ST_ENRL_STAT_REQUIRED';
		RETURN FALSE;
	END IF;
	-- initialise the system log variables
	-- this flag is used to indicate whether or not an entry has
	-- been written to the IGS_GE_S_ERROR_LOG table (using IGS_GE_GEN_003.genp_log_error),
	-- stating that entries have been written to the system log
	v_logged_ind := FALSE;
	v_s_log_type := 'GOVT-SBMSN';
	-- check if the submission is complete
	IF NOT IGS_ST_VAL_GSC.stap_val_gsc_sdt_upd(
				p_submission_yr,
				p_submission_number,
				v_message_name) THEN
	 	p_message_name := v_message_name;
		RETURN FALSE;
	END IF;
	-- determine which enrolment statistics snapshot to use
	IF p_submission_number IN (1, 2) THEN
		IF p_ess_snapshot_dt_time IS NOT NULL THEN
			v_ess_snapshot_dt_time := p_ess_snapshot_dt_time;
		ELSIF p_use_most_recent_ess_ind = 'Y' THEN
			-- determine the most recent enrolment
			-- statistics snapshot
			-- select the first record only
			OPEN  c_essc;
			FETCH c_essc INTO v_ess_snapshot_dt_time;
			IF c_essc%NOTFOUND THEN
				CLOSE c_essc;
				p_message_name := 'IGS_ST_COULD_NOT_DET_ENR_STAT';
				RETURN FALSE;
			END IF;
			CLOSE c_essc;
		ELSE
			p_message_name := 'IGS_ST_COULD_NOT_DET_ENR_STAT';
			RETURN FALSE;
		END IF;
		-- validate the enrolment statistics snapshot to be used
		IF NOT IGS_ST_VAL_GSC.stap_val_gsc_sdt (
				p_submission_yr,
				v_ess_snapshot_dt_time,
				v_message_name) THEN
			IF v_message_name = 'IGS_ST_CANT_USE+ENRL_STATIST' THEN
				-- the enrolment statistics snapshot
				-- is marked for delete.  Update the
				-- delete snapshot indicator
				BEGIN
					FOR v_essc_upd_rec IN c_essc_upd(v_ess_snapshot_dt_time) LOOP

                                    v_essc_upd_rec.delete_snapshot_ind := 'N';

                                       IGS_EN_ST_SPSHT_CTL_PKG.UPDATE_ROW(
                                          X_ROWID => v_essc_upd_rec.rowid,
							X_SNAPSHOT_DT_TIME => v_essc_upd_rec.snapshot_dt_time,
							X_DELETE_SNAPSHOT_IND  => v_essc_upd_rec.delete_snapshot_ind,
							X_COMMENTS => v_essc_upd_rec.comments,
							X_MODE => 'R');

                              END LOOP;
				EXCEPTION
					WHEN e_resource_busy THEN
						p_message_name := 'IGS_GR_CER_CL_DT_LE_CERM_DT';
						RETURN FALSE;
					WHEN OTHERS THEN
						RAISE;
				END;
				COMMIT;

			ELSE
				p_message_name := v_message_name;
				RETURN FALSE;
			END IF;
		END IF;
		-- update the enrolment statistics snapshot date time
		-- for the government snapshot
		BEGIN
			FOR v_gsc_upd_rec IN c_gsc_upd LOOP

				v_gsc_upd_rec.ess_snapshot_dt_time := v_ess_snapshot_dt_time;
                        IGS_ST_GVT_SPSHT_CTL_PKG.UPDATE_ROW(
						X_ROWID => v_gsc_upd_rec.rowid,
						X_SUBMISSION_YR => v_gsc_upd_rec.submission_yr,
						X_SUBMISSION_NUMBER => v_gsc_upd_rec.submission_number,
						X_ESS_SNAPSHOT_DT_TIME => v_gsc_upd_rec.ess_snapshot_dt_time,
						X_COMPLETION_DT => v_gsc_upd_rec.completion_dt,
						X_MODE   => 'R');
			END LOOP;
		EXCEPTION
			WHEN e_resource_busy THEN
				p_message_name := 'IGS_ST_ENR_STAT_DT_TIM_NOT_UP';
				RETURN FALSE;
			WHEN OTHERS THEN
				RAISE;
		END;
		COMMIT;

	ELSIF p_submission_number = 3 THEN
		OPEN c_gsc;
		FETCH c_gsc INTO v_ess_snapshot_dt_time;
		CLOSE c_gsc;
		BEGIN
			FOR v_gsc_upd_rec IN c_gsc_upd LOOP

				v_gsc_upd_rec.ess_snapshot_dt_time := v_ess_snapshot_dt_time;
                        IGS_ST_GVT_SPSHT_CTL_PKG.UPDATE_ROW(
						X_ROWID => v_gsc_upd_rec.rowid,
						X_SUBMISSION_YR => v_gsc_upd_rec.submission_yr,
						X_SUBMISSION_NUMBER => v_gsc_upd_rec.submission_number,
						X_ESS_SNAPSHOT_DT_TIME => v_gsc_upd_rec.ess_snapshot_dt_time,
						X_COMPLETION_DT => v_gsc_upd_rec.completion_dt,
						X_MODE   => 'R');

			END LOOP;
		EXCEPTION
			WHEN e_resource_busy THEN
				p_message_name := 'IGS_ST_ENR_STAT_DT_TIM_NOT_UP';
				RETURN FALSE;
			WHEN OTHERS THEN
				RAISE;
		END;
		COMMIT;

	END IF;
	-- remove all existing government snapshot detail
	-- records
	BEGIN
		FOR v_gsli_upd_rec IN c_gsli_upd LOOP

			IGS_ST_GVT_STDNT_LBL_PKG.DELETE_ROW(
                    X_ROWID => v_gsli_upd_rec.rowid);

		END LOOP;
	EXCEPTION
		WHEN e_resource_busy THEN
			p_message_name := 'IGS_ST_GOV_STUD_REC_CANT_DEL';
			RETURN FALSE;
		WHEN OTHERS THEN
			RAISE;
	END;
	BEGIN
		FOR v_gslo_upd_rec IN c_gslo_upd LOOP

                  IGS_ST_GVT_STDNTLOAD_PKG.DELETE_ROW(
                    X_ROWID => v_gslo_upd_rec.rowid);

		END LOOP;
	EXCEPTION
		WHEN e_resource_busy THEN
			p_message_name := 'IGS_ST_GOV_STUD_LOAD_CANT_DEL';
			RETURN FALSE;
		WHEN OTHERS THEN
			RAISE;
	END;
	BEGIN
		FOR v_gse_upd_rec IN c_gse_upd LOOP

                  IGS_ST_GOVT_STDNT_EN_PKG.DELETE_ROW(
                    X_ROWID => v_gse_upd_rec.rowid);
		END LOOP;
	EXCEPTION
		WHEN e_resource_busy THEN
			p_message_name := 'IGS_ST_GOV_ENRL_REC_CANT_DEL';
			RETURN FALSE;
		WHEN OTHERS THEN
			RAISE;
	END;
	COMMIT;

  -- Create an entry in the system log.
	IGS_GE_GEN_003.genp_ins_log (
		v_s_log_type,
		TO_CHAR(p_submission_yr) ||
			' ' ||
			TO_CHAR(p_submission_number) ||
			',' ||
		IGS_GE_DATE.igscharDT(v_ess_snapshot_dt_time),	-- Key
		v_creation_dt);	-- Output parameter.  Needed for creating entries.
	p_log_creation_dt := v_creation_dt;
	-- for submissions 1 and 2, retrieve data from the
	-- enrolment statistics snapshot
	IF (p_submission_number IN (1, 2)) THEN
		-- determine and set the effective date
		IF (p_submission_number = 1) THEN
			v_effective_dt := v_submission_1_census_dt;
		ELSE	-- submission 2
			v_effective_dt := v_submission_2_census_dt;
		END IF;
		-- set the default attendance type
		OPEN  c_get_att_type;
		FETCH c_get_att_type INTO v_attendance_type,
					   v_govt_attendance_type;
		IF (c_get_att_type%NOTFOUND) THEN
			CLOSE c_get_att_type;
			gv_other_detail := 'Parm:'
				|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
				|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
				|| ', p_dt_time- ' 			||
					IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
				|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind;
		 Fnd_Message.Set_Name('IGS',v_message_name);
   		 IGS_GE_MSG_STACK.ADD;
                 App_Exception.Raise_Exception;
		END IF;
		CLOSE c_get_att_type;
		-- set the attendance mode values
		-- retrieve the first record only from each
		-- select (there are three different selects
		-- as different details are retrieved depending
		-- on the govt_attendance_mode specified)
		-- select the first record only
		-- internal attendance mode
		OPEN  c_get_att_mode_1;
		FETCH c_get_att_mode_1 INTO	v_attendance_mode_1,
						v_govt_attendance_mode_1;
		IF (c_get_att_mode_1%NOTFOUND) THEN
			CLOSE c_get_att_mode_1;
			gv_other_detail := 'Parm:'
				|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
				|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
				|| ', p_dt_time- ' 			||
					IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
				|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind;
		 Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
		END IF;
		CLOSE c_get_att_mode_1;
		-- external attendance mode
		OPEN  c_get_att_mode_2;
		FETCH c_get_att_mode_2 INTO v_attendance_mode_2,
					     v_govt_attendance_mode_2;
		IF (c_get_att_mode_2%NOTFOUND) THEN
			CLOSE c_get_att_mode_2;
			gv_other_detail := 'Parm:'
				|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
				|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
				|| ', p_dt_time- ' 			||
					IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
				|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind;
		 Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
		CLOSE c_get_att_mode_2;
		-- multi-modal attendance mode
		OPEN  c_get_att_mode_3;
		FETCH c_get_att_mode_3 INTO v_attendance_mode_3,
					     v_govt_attendance_mode_3;
		IF (c_get_att_mode_3%NOTFOUND) THEN
			CLOSE c_get_att_mode_3;
			gv_other_detail := 'Parm:'
				|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
				|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
				|| ', p_dt_time- ' 			||
					IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
				|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind;
		 Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;

                     App_Exception.Raise_Exception;
		END IF;
		CLOSE c_get_att_mode_3;


  	    -- retrieve the enrolment statistics snapshot data

		FOR v_enr_snpsht_rec IN c_enr_snpsht_rec(
						v_ess_snapshot_dt_time) LOOP
			-- setting that a record has been found
			v_ess_rec_found := TRUE;
			-- checking if the values of the cursor are
			-- the same as the previous ones retrieved,
			-- as the government semester only needs to
			-- be re-determined if they have changed
			IF v_load_cal_type IS NULL OR
			 		v_load_cal_type <> v_enr_snpsht_rec.ci_cal_type OR
			    		v_load_ci_sequence_number IS NULL OR
					v_load_ci_sequence_number <> v_enr_snpsht_rec.ci_sequence_number OR
			    		v_teach_cal_type IS NULL OR
					v_teach_cal_type <> v_enr_snpsht_rec.sua_cal_type THEN
				-- retrieve the government semester
				v_govt_semester := IGS_ST_GEN_002.stap_get_govt_sem(
							p_submission_yr,
							p_submission_number,
							v_enr_snpsht_rec.ci_cal_type,
							v_enr_snpsht_rec.ci_sequence_number,
							v_enr_snpsht_rec.sua_cal_type);
				IF (v_govt_semester IS NULL) THEN
					OPEN c_ci(
						v_enr_snpsht_rec.ci_cal_type,
						v_enr_snpsht_rec.ci_sequence_number);
					FETCH c_ci INTO	v_start_dt,
							v_end_dt;
					CLOSE c_ci;
					gv_extra_details := 'Cannot determine the Government Semester for - '
							|| v_enr_snpsht_rec.ci_cal_type || ', '
							|| IGS_GE_DATE.igschar(v_start_dt) || ' - '
							|| IGS_GE_DATE.igschar(v_end_dt) || ', '
							|| v_enr_snpsht_rec.sua_cal_type;
					gv_other_detail := 'Parm:'
						|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
						|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
						|| ', p_ess_snapshot_dt_time- ' 	||
							IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
						|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind || ' '
						|| gv_extra_details;
					 Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
					IGS_GE_MSG_STACK.ADD;

                     App_Exception.Raise_Exception;
				END IF;
			END IF;
			IF (p_submission_number = 1 OR
			   		(p_submission_number = 2 AND
			   		(v_govt_semester IN(2, 4)))) THEN
				-- retrieve the teaching calendar census date
				-- select the first record only
				IF v_teach_cal_type IS NULL OR
						v_teach_cal_type <> v_enr_snpsht_rec.sua_cal_type OR
			   	    		v_teach_ci_sequence_number IS NULL OR
						v_teach_ci_sequence_number <> v_enr_snpsht_rec.sua_ci_sequence_number THEN
					OPEN  c_alias_val(
						v_enr_snpsht_rec.sua_cal_type,
						v_enr_snpsht_rec.sua_ci_sequence_number);
					FETCH c_alias_val INTO v_alias_val;
					-- if no records found, raise a user exception
					IF (c_alias_val%NOTFOUND) THEN
						CLOSE c_alias_val;
						OPEN c_ci(
							v_enr_snpsht_rec.sua_cal_type,
							v_enr_snpsht_rec.sua_ci_sequence_number);
						FETCH c_ci INTO	v_start_dt,
								v_end_dt;
						CLOSE c_ci;
						gv_extra_details := 'Cannot determine the Teaching Census Date for - '
							|| v_enr_snpsht_rec.sua_cal_type || ', '
							|| IGS_GE_DATE.igschar(v_start_dt) || ' - '
							|| IGS_GE_DATE.igschar(v_end_dt);
						gv_other_detail := 'Parm:'
							|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
							|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
							|| ', p_ess_snapshot_dt_time- ' 	||
								IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
							|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind || ' '
							|| gv_extra_details;
					Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
					IGS_GE_MSG_STACK.ADD;
			                App_Exception.Raise_Exception;
					END IF;
					CLOSE c_alias_val;
				END IF;
				-- determine if the record is government
				-- reportable for the submission
				v_govt_reportable := IGS_ST_GEN_003.stap_get_rptbl_sbmsn(
						p_submission_yr,
						p_submission_number,
						v_enr_snpsht_rec.person_id,
						v_enr_snpsht_rec.course_cd,
						v_enr_snpsht_rec.crv_version_number,
						v_enr_snpsht_rec.unit_cd,
						v_enr_snpsht_rec.uv_version_number,
						v_enr_snpsht_rec.sua_cal_type,
						v_enr_snpsht_rec.sua_ci_sequence_number,
						v_enr_snpsht_rec.tr_org_unit_cd,
						v_enr_snpsht_rec.tr_ou_start_dt,
						v_enr_snpsht_rec.eftsu,
						v_enr_snpsht_rec.enrolled_dt,
						v_enr_snpsht_rec.discontinued_dt,
						v_govt_semester,
						v_alias_val,
						v_enr_snpsht_rec.ci_cal_type,
						v_enr_snpsht_rec.ci_sequence_number,
                        v_enr_snpsht_rec.uoo_id);
				-- check the value of gv_govt_reportable
				IF v_govt_reportable IS NULL THEN
					OPEN c_ci(
						v_enr_snpsht_rec.sua_cal_type,
						v_enr_snpsht_rec.sua_ci_sequence_number);
					FETCH c_ci INTO	v_start_dt,
							v_end_dt;
					CLOSE c_ci;
					OPEN c_ci(
						v_enr_snpsht_rec.ci_cal_type,
						v_enr_snpsht_rec.ci_sequence_number);
					FETCH c_ci INTO	v_start_dt_2,
							v_end_dt_2;
					CLOSE c_ci;
					gv_extra_details := 'Cannot determine the government '
						|| 'submission reportable value.  '
						|| p_submission_yr || ', '
						|| TO_CHAR(p_submission_number)	|| ', '
						|| TO_CHAR(v_enr_snpsht_rec.person_id) || ', '
						|| v_enr_snpsht_rec.course_cd || ', '
						|| TO_CHAR(v_enr_snpsht_rec.crv_version_number) || ', '
						|| v_enr_snpsht_rec.unit_cd || ', '
						|| TO_CHAR(v_enr_snpsht_rec.uv_version_number) || ', '
						|| v_enr_snpsht_rec.sua_cal_type || ', '
						|| IGS_GE_DATE.igschar(v_start_dt) || ' - '
						|| IGS_GE_DATE.igschar(v_end_dt) || ', '
						|| v_enr_snpsht_rec.tr_org_unit_cd || ', '
						|| IGS_GE_DATE.igscharDT(v_enr_snpsht_rec.tr_ou_start_dt) || ', '
						|| TO_CHAR(v_enr_snpsht_rec.eftsu) || ', '
						|| IGS_GE_DATE.igschar(v_enr_snpsht_rec.enrolled_dt) || ', '
						|| IGS_GE_DATE.igschar(v_enr_snpsht_rec.discontinued_dt) || ', '
						|| TO_CHAR(v_govt_semester) || ', '
						|| IGS_GE_DATE.igschar(v_alias_val) || ', '
						|| v_enr_snpsht_rec.ci_cal_type || ', '
						|| IGS_GE_DATE.igschar(v_start_dt_2) || ' - '
						|| IGS_GE_DATE.igschar(v_end_dt_2);
					gv_other_detail := 'Parm:'
						|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
						|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
						|| ', p_ess_snapshot_dt_time- ' 	||
							IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
						|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind || ' '
						|| gv_extra_details;

                          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			  IGS_GE_MSG_STACK.ADD;
                	  App_Exception.Raise_Exception;
				END IF;
				IF (v_govt_reportable <> 'N') THEN
					-- government student enrolment records
					-- are created in submission 1 only.
					-- government student load and liability
					-- records are created in submissions 1 and 2
					IF (p_submission_number = 1) THEN
						-- only get the IGS_PE_PERSON data if the
						-- person_id changes
						IF v_person_id IS NULL OR
						    v_person_id <> v_enr_snpsht_rec.person_id OR
						    v_course_cd IS NULL OR
						    v_course_cd <> v_enr_snpsht_rec.course_cd THEN
							IGS_ST_GEN_002.stap_get_person_data(
									v_enr_snpsht_rec.person_id,
									v_enr_snpsht_rec.course_cd,
									v_enr_snpsht_rec.crv_version_number,
									v_effective_dt,
									v_enr_snpsht_rec.commencing_student_ind,
									v_logged_ind,
									v_s_log_type,
									v_creation_dt,
									v_birth_dt,		-- OUT NOCOPY
									v_sex,			-- OUT NOCOPY
									v_aborig_torres_cd,	-- OUT NOCOPY
									v_govt_aborig_torres_cd,-- OUT NOCOPY
									v_citizenship_cd,	-- OUT NOCOPY
									v_govt_citizenship_cd,	-- OUT NOCOPY
									v_perm_resident_cd,	-- OUT NOCOPY
									v_govt_perm_resident_cd,-- OUT NOCOPY
									v_home_location_cd,	-- OUT NOCOPY
									v_govt_home_location_cd,-- OUT NOCOPY
									v_term_location_cd,	-- OUT NOCOPY
									v_govt_term_location_cd,-- OUT NOCOPY
									v_birth_country_cd,	-- OUT NOCOPY
									v_govt_birth_country_cd,-- OUT NOCOPY
									v_yr_arrival,		-- OUT NOCOPY
									v_home_language_cd,	-- OUT NOCOPY
									v_govt_home_language_cd,-- OUT NOCOPY
									v_prior_ug_inst,	-- OUT NOCOPY
									v_govt_prior_ug_inst,	-- OUT NOCOPY
									v_prior_other_qual,	-- OUT NOCOPY
									v_prior_post_grad,	-- OUT NOCOPY
									v_prior_degree,		-- OUT NOCOPY
									v_prior_subdeg_notafe,	-- OUT NOCOPY
									v_prior_subdeg_tafe,	-- OUT NOCOPY
									v_prior_seced_tafe,	-- OUT NOCOPY
									v_prior_seced_school,	-- OUT NOCOPY
									v_prior_tafe_award,	-- OUT NOCOPY
									v_govt_disability);	-- OUT NOCOPY
						END IF;
						-- get the IGS_PE_PERSON IGS_PS_COURSE details if the IGS_PE_PERSON
						-- and IGS_PS_COURSE has changed from the previous
						-- record retrieved
						IF v_person_id IS NULL OR
								v_person_id <> v_enr_snpsht_rec.person_id OR
								v_course_cd IS NULL OR
								v_course_cd <> v_enr_snpsht_rec.course_cd OR
								v_old_govt_semester IS NULL OR
								v_old_govt_semester <> v_govt_semester THEN
							IGS_ST_GEN_003.stap_get_sca_data(
									p_submission_yr,
									p_submission_number,
									v_enr_snpsht_rec.person_id,
									v_enr_snpsht_rec.course_cd,
									v_effective_dt,
									v_enr_snpsht_rec.crv_version_number,
									v_enr_snpsht_rec.commencing_student_ind,
									v_enr_snpsht_rec.ci_cal_type,
									v_enr_snpsht_rec.ci_sequence_number,
									v_logged_ind,
									v_s_log_type,
									v_creation_dt,
									v_govt_semester,
									v_enr_snpsht_rec.award_course_ind,
									v_govt_citizenship_cd,
									v_prior_seced_tafe,
									v_prior_seced_school,
									v_commencement_dt,		-- OUT NOCOPY
									v_prior_studies_exemption,	-- OUT NOCOPY
									v_exempt_institution_cd,	-- OUT NOCOPY
									v_govt_exempt_institution_cd,	-- OUT NOCOPY
									v_tertiary_entrance_score,	-- OUT NOCOPY
									v_basis_for_admission_type,	-- OUT NOCOPY
									v_govt_basis_for_adm_type,	-- OUT NOCOPY
									v_hecs_amount_pd,		-- OUT NOCOPY
									v_hecs_payment_option,		-- OUT NOCOPY
									v_govt_hecs_payment_option,	-- OUT NOCOPY
									v_tuition_fee,			-- OUT NOCOPY
									v_hecs_fee,			-- OUT NOCOPY
									v_differential_hecs_ind);	-- OUT NOCOPY
						END IF;
						-- get the industrial indicator from IGS_PS_UNIT_VER
						IF v_unit_cd IS NULL OR
								v_unit_cd <> v_enr_snpsht_rec.unit_cd OR
						    		v_uv_version_number IS NULL OR
								v_uv_version_number <> v_enr_snpsht_rec.uv_version_number THEN
							OPEN c_get_indus_ind(
								v_enr_snpsht_rec.unit_cd,
								v_enr_snpsht_rec.uv_version_number);
							FETCH c_get_indus_ind INTO v_industrial_ind;
							IF (c_get_indus_ind%NOTFOUND) THEN
								CLOSE c_get_indus_ind;
								gv_extra_details := ' Cannot find IGS_PS_UNIT data:'
									|| v_enr_snpsht_rec.unit_cd || ', '
									|| TO_CHAR(v_enr_snpsht_rec.uv_version_number);
								gv_other_detail := 'Parm:'
									|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
									|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
									|| ', p_ess_snapshot_dt_time- ' 	||
										IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
									|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind || ' '
									|| gv_extra_details;
							Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
							IGS_GE_MSG_STACK.ADD;
                                        		App_Exception.Raise_Exception;
  							END IF;
							CLOSE c_get_indus_ind;
						END IF;
						-- determine the IGS_PS_UNIT completion status
						stapl_val_unit_compltn_status(
								v_enr_snpsht_rec.person_id,
								v_enr_snpsht_rec.course_cd,
								v_enr_snpsht_rec.unit_cd,
								v_enr_snpsht_rec.sua_cal_type,
								v_enr_snpsht_rec.sua_ci_sequence_number,
								v_unit_completion_status,
                                v_enr_snpsht_rec.uoo_id);
						-- create the government student enrolment record,
						-- which only needs to be created if the IGS_PE_PERSON or
						-- IGS_PS_COURSE values are different from the previous record
						IF v_person_id IS NULL OR
								v_person_id <> v_enr_snpsht_rec.person_id OR
						    		v_course_cd IS NULL OR
								v_course_cd <> v_enr_snpsht_rec.course_cd THEN
							-- IGS_GE_NOTE : below some values are entered with a NVL
							--	  statement.  Even though they are set to all
							--	  spaces, it seems to interpret them as
							--	  as being NULLs (not null values on table).
                                          DECLARE
                                              v_rowid VARCHAR2(25);
							BEGIN

                                            -- to insert row using insertrow of the respective TBH package

                                             IGS_ST_GOVT_STDNT_EN_PKG.INSERT_ROW(
      							 X_ROWID => v_rowid,
 								 X_SUBMISSION_YR => p_submission_yr,
								 X_SUBMISSION_NUMBER => p_submission_number,
								 X_PERSON_ID => v_enr_snpsht_rec.person_id,
								 X_COURSE_CD => v_enr_snpsht_rec.course_cd,
								 X_VERSION_NUMBER => v_enr_snpsht_rec.crv_version_number,
								 X_BIRTH_DT => v_birth_dt,
								 X_SEX => v_sex,
								 X_ABORIG_TORRES_CD  => v_aborig_torres_cd,
								 X_GOVT_ABORIG_TORRES_CD => v_govt_aborig_torres_cd,
								 X_CITIZENSHIP_CD  => v_citizenship_cd,
								 X_GOVT_CITIZENSHIP_CD => v_govt_citizenship_cd,
								 X_PERM_RESIDENT_CD => v_perm_resident_cd,
								 X_GOVT_PERM_RESIDENT_CD => v_govt_perm_resident_cd,
								 X_HOME_LOCATION => v_home_location_cd,
								 X_GOVT_HOME_LOCATION => v_govt_home_location_cd,
								 X_TERM_LOCATION => v_term_location_cd,
								 X_GOVT_TERM_LOCATION => v_govt_term_location_cd,
								 X_BIRTH_COUNTRY_CD =>  v_birth_country_cd,
								 X_GOVT_BIRTH_COUNTRY_CD => v_govt_birth_country_cd,
								 X_YR_ARRIVAL =>  v_yr_arrival,
								 X_HOME_LANGUAGE_CD => v_home_language_cd,
								 X_GOVT_HOME_LANGUAGE_CD => v_govt_home_language_cd,
								 X_PRIOR_UG_INST => v_prior_ug_inst,
								 X_GOVT_PRIOR_UG_INST => v_govt_prior_ug_inst,
								 X_PRIOR_OTHER_QUAL => v_prior_other_qual,
								 X_PRIOR_POST_GRAD => v_prior_post_grad,
								 X_PRIOR_DEGREE => v_prior_degree,
								 X_PRIOR_SUBDEG_NOTAFE => v_prior_subdeg_notafe,
								 X_PRIOR_SUBDEG_TAFE => v_prior_subdeg_tafe,
								 X_PRIOR_SECED_TAFE => v_prior_seced_tafe,
								 X_PRIOR_SECED_SCHOOL => v_prior_seced_school,
								 X_PRIOR_TAFE_AWARD => v_prior_tafe_award,
								 X_PRIOR_STUDIES_EXEMPTION  => v_prior_studies_exemption,
								 X_EXEMPTION_INSTITUTION_CD => v_exempt_institution_cd,
								 X_GOVT_EXEMPT_INSTITU_CD => v_govt_exempt_institution_cd,
								 X_ATTENDANCE_MODE => v_attendance_mode_3,
								 X_GOVT_ATTENDANCE_MODE => v_govt_attendance_mode_3,
								 X_ATTENDANCE_TYPE => v_attendance_type,
								 X_GOVT_ATTENDANCE_TYPE => v_govt_attendance_type,
								 X_COMMENCEMENT_DT => v_commencement_dt,
								 X_MAJOR_COURSE => 1,
								 X_TERTIARY_ENTRANCE_SCORE => v_tertiary_entrance_score,
								 X_BASIS_FOR_ADMISSION_TYPE => v_basis_for_admission_type,
								 X_GOVT_BASIS_FOR_ADM_TYPE => v_govt_basis_for_adm_type,
								 X_GOVT_DISABILITY =>  NVL(v_govt_disability, '        '),
								 X_MODE => 'R');

							EXCEPTION
								WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
								FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004. 1');
								IGS_GE_MSG_STACK.ADD;
						                App_Exception.Raise_Exception;
							END;
						END IF;
						-- create the government student load record
						stapl_ins_govt_sdnt_load_rec(
								p_submission_yr,
								p_submission_number,
								v_enr_snpsht_rec.person_id,
								v_enr_snpsht_rec.course_cd,
								v_enr_snpsht_rec.crv_version_number,
								v_govt_semester,
								v_enr_snpsht_rec.unit_cd,
								v_enr_snpsht_rec.uv_version_number,
								v_enr_snpsht_rec.sua_cal_type,
								v_enr_snpsht_rec.sua_ci_sequence_number,
								v_enr_snpsht_rec.tr_org_unit_cd,
								v_enr_snpsht_rec.tr_ou_start_dt,
								v_enr_snpsht_rec.discipline_group_cd,
								v_enr_snpsht_rec.govt_discipline_group_cd,
								v_industrial_ind,
								v_enr_snpsht_rec.eftsu,
								v_unit_completion_stat,
								v_logged_ind,
								v_s_log_type,
								v_creation_dt,
                                v_enr_snpsht_rec.sua_location_cd,
                                v_enr_snpsht_rec.unit_class);
						-- create the government student liability record
						IF v_person_id IS NULL OR
								v_person_id <> v_enr_snpsht_rec.person_id OR
						    		v_course_cd IS NULL OR
								v_course_cd <> v_enr_snpsht_rec.course_cd OR
								v_old_govt_semester IS NULL OR
								v_old_govt_semester <> v_govt_semester THEN
							stapl_ins_govt_sdnt_liab_rec(
									p_submission_yr,
									p_submission_number,
									v_enr_snpsht_rec.person_id,
									v_enr_snpsht_rec.course_cd,
									v_enr_snpsht_rec.crv_version_number,
									v_govt_semester,
									v_hecs_payment_option,
									v_govt_hecs_payment_option,
									v_hecs_amount_pd,
									v_tuition_fee,
									v_differential_hecs_ind,
									v_birth_dt,
									v_sex,
									v_citizenship_cd,
									v_govt_citizenship_cd,
									v_perm_resident_cd,
									v_govt_perm_resident_cd,
									v_commencement_dt,
									v_hecs_fee);
						END IF;
					ELSE -- p_submission_number = 2
						-- get the IGS_PE_PERSON IGS_PS_COURSE details if the IGS_PE_PERSON
						-- and IGS_PS_COURSE has changed from the previous
						-- record retrieved
						IF v_person_id IS NULL OR
								v_person_id <> v_enr_snpsht_rec.person_id OR
						     		v_course_cd IS NULL OR
								v_course_cd <> v_enr_snpsht_rec.course_cd OR
								v_old_govt_semester IS NULL OR
								v_old_govt_semester <> v_govt_semester THEN
							IGS_ST_GEN_003.stap_get_sca_data(
									p_submission_yr,
									p_submission_number,
									v_enr_snpsht_rec.person_id,
									v_enr_snpsht_rec.course_cd,
									v_effective_dt,
									v_enr_snpsht_rec.crv_version_number,
									v_enr_snpsht_rec.commencing_student_ind,
									v_enr_snpsht_rec.ci_cal_type,
									v_enr_snpsht_rec.ci_sequence_number,
									v_logged_ind,
									v_s_log_type,
									v_creation_dt,
									v_govt_semester,
									v_enr_snpsht_rec.award_course_ind,
									v_govt_citizenship_cd,
									v_prior_seced_tafe,
									v_prior_seced_school,
									v_commencement_dt,		-- OUT NOCOPY
									v_prior_studies_exemption,	-- OUT NOCOPY
									v_exempt_institution_cd,	-- OUT NOCOPY
									v_govt_exempt_institution_cd,	-- OUT NOCOPY
									v_tertiary_entrance_score,	-- OUT NOCOPY
									v_basis_for_admission_type,	-- OUT NOCOPY
									v_govt_basis_for_adm_type,	-- OUT NOCOPY
									v_hecs_amount_pd,		-- OUT NOCOPY
									v_hecs_payment_option,		-- OUT NOCOPY
									v_govt_hecs_payment_option,	-- OUT NOCOPY
									v_tuition_fee,			-- OUT NOCOPY
									v_hecs_fee,			-- OUT NOCOPY
									v_differential_hecs_ind);	-- OUT NOCOPY
						END IF;
						-- get the industrial indicator from IGS_PS_UNIT_VER
						IF v_unit_cd IS NULL OR
								v_unit_cd <> v_enr_snpsht_rec.unit_cd OR
						    		v_uv_version_number IS NULL OR
								v_uv_version_number <> v_enr_snpsht_rec.uv_version_number THEN
							OPEN c_get_indus_ind(
								v_enr_snpsht_rec.unit_cd,
								v_enr_snpsht_rec.uv_version_number);
							FETCH c_get_indus_ind INTO v_industrial_ind;
							IF (c_get_indus_ind%NOTFOUND) THEN
								CLOSE c_get_indus_ind;
								gv_extra_details := ' Cannot find IGS_PS_UNIT data:'
									|| v_enr_snpsht_rec.unit_cd || ', '
									|| TO_CHAR(v_enr_snpsht_rec.uv_version_number);
								gv_other_detail := 'Parm:'
									|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
									|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
									|| ', p_ess_snapshot_dt_time- ' 	||
										IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
									|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind || ' '
									|| gv_extra_details;
							Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
							IGS_GE_MSG_STACK.ADD;
		                                          App_Exception.Raise_Exception;
							END IF;
							CLOSE c_get_indus_ind;
						END IF;
						-- determine the IGS_PS_UNIT completion status
						stapl_val_unit_compltn_status(
								v_enr_snpsht_rec.person_id,
								v_enr_snpsht_rec.course_cd,
								v_enr_snpsht_rec.unit_cd,
								v_enr_snpsht_rec.sua_cal_type,
								v_enr_snpsht_rec.sua_ci_sequence_number,
								v_unit_completion_status,
                                v_enr_snpsht_rec.uoo_id);
						-- create the government student load record
						stapl_ins_govt_sdnt_load_rec(
								p_submission_yr,
								p_submission_number,
								v_enr_snpsht_rec.person_id,
								v_enr_snpsht_rec.course_cd,
								v_enr_snpsht_rec.crv_version_number,
								v_govt_semester,
								v_enr_snpsht_rec.unit_cd,
								v_enr_snpsht_rec.uv_version_number,
								v_enr_snpsht_rec.sua_cal_type,
								v_enr_snpsht_rec.sua_ci_sequence_number,
								v_enr_snpsht_rec.tr_org_unit_cd,
								v_enr_snpsht_rec.tr_ou_start_dt,
								v_enr_snpsht_rec.discipline_group_cd,
								v_enr_snpsht_rec.govt_discipline_group_cd,
								v_industrial_ind,
								v_enr_snpsht_rec.eftsu,
								v_unit_completion_status,
								v_logged_ind,
								v_s_log_type,
								v_creation_dt,
                                v_enr_snpsht_rec.sua_location_cd,
                                v_enr_snpsht_rec.unit_class);
						-- retrieve IGS_PE_PERSON and IGS_PE_PERSON IGS_PS_COURSE data for the government
						-- student liability record
						stapl_get_sca_data_for_liab(
								v_enr_snpsht_rec.person_id,
								v_person_id,			-- old person_id
								v_enr_snpsht_rec.course_cd,
								v_course_cd,			-- old course_cd
								v_effective_dt,
								v_logged_ind,		-- IN OUT NOCOPY
								v_s_log_type,
								v_creation_dt,
								v_birth_dt,		-- IN OUT NOCOPY
								v_sex,			-- IN OUT NOCOPY
								v_citizenship_cd,	-- IN OUT NOCOPY
								v_govt_citizenship_cd,	-- IN OUT NOCOPY
								v_perm_resident_cd,	-- IN OUT NOCOPY
								v_govt_perm_resident_cd);	-- IN OUT NOCOPY
						-- create the government student liability record
						IF v_person_id IS NULL OR
								v_person_id <> v_enr_snpsht_rec.person_id OR
						    		v_course_cd IS NULL OR
								v_course_cd <> v_enr_snpsht_rec.course_cd OR
								v_old_govt_semester IS NULL OR
								v_old_govt_semester <> v_govt_semester THEN
							stapl_ins_govt_sdnt_liab_rec(
									p_submission_yr,
									p_submission_number,
									v_enr_snpsht_rec.person_id,
									v_enr_snpsht_rec.course_cd,
									v_enr_snpsht_rec.crv_version_number,
									v_govt_semester,
									v_hecs_payment_option,
									v_govt_hecs_payment_option,
									v_hecs_amount_pd,
									v_tuition_fee,
									v_differential_hecs_ind,
									v_birth_dt,
									v_sex,
									v_citizenship_cd,
									v_govt_citizenship_cd,
									v_perm_resident_cd,
									v_govt_perm_resident_cd,
									v_commencement_dt,
									v_hecs_fee);
						END IF;
					END IF;
					-- set the values before looping again
					v_person_id := v_enr_snpsht_rec.person_id;
					v_course_cd := v_enr_snpsht_rec.course_cd;
					v_unit_cd := v_enr_snpsht_rec.unit_cd;
					v_uv_version_number := v_enr_snpsht_rec.uv_version_number;
				END IF; --end if for reportable = Y
			END IF;  -- end if p_submission_number = 1 OR (p_submission_number = 2 AND
				-- 				 (v_govt_semester IN(2, 4))))
			-- setting the values again before going around
			-- the loop again, as retrieval of government
			-- semester only needs to be done if these
			-- values change
			v_load_cal_type := v_enr_snpsht_rec.ci_cal_type;
			v_load_ci_sequence_number := v_enr_snpsht_rec.ci_sequence_number;
			v_teach_cal_type := v_enr_snpsht_rec.sua_cal_type;
			v_teach_ci_sequence_number := v_enr_snpsht_rec.sua_ci_sequence_number;
			v_old_govt_semester := v_govt_semester;
		END LOOP;
		-- raise an error if no enrolment statistics
		-- snapshot records were found
		IF (v_ess_rec_found = FALSE) THEN
			p_message_name := 'IGS_ST_GOVT_SNAPSHOT_NO_DATA';
			RETURN FALSE;
		END IF;
		COMMIT;

	END IF;
	-- process data from previous submissions
	-- For submission 2 retrieve data for Government Semesters
	-- 1, 3 and 5 frm the previous submisson.
	-- For Submission 3, retrieve all data from the previous submission
	IF (p_submission_number IN (2, 3)) THEN
		-- Populate the government student load temporary table.
		-- set that no records have yet been found
		-- from the previous submission
		v_prev_sub := FALSE;
		-- retrieve the Government Snapshot data from the previous submission
		 FOR v_gslot_rec IN Cur_si_st_govtstdldtmp LOOP
		 		-- a previous submission exists
		       	  v_prev_sub := TRUE;
		          v_unit_completion_status := stap_get_un_comp_sts(
							v_gslot_rec.person_id,
							v_gslot_rec.course_cd,
							v_gslot_rec.unit_cd,
							v_gslot_rec.sua_cal_type,
	 						v_gslot_rec.sua_ci_sequence_number,
                            v_gslot_rec.uoo_id);

			IF ((p_submission_number = 2 AND
					v_gslot_rec.govt_semester IN (1, 3, 5)) OR
					p_submission_number = 3) THEN
				IF (v_gslot_rec.govt_semester IN (1, 3, 5)) THEN
					v_unit_effective_dt := v_submission_1_census_dt;
				ELSE
					v_unit_effective_dt := v_submission_2_census_dt;
				END IF;
				-- select the alternate person_id
				-- select the first record only, as this
				-- will be the end dated record if one exists
				OPEN c_get_api(
					v_gslot_rec.person_id,
					v_unit_effective_dt);
				FETCH c_get_api INTO v_temp_person_id;
				IF (c_get_api%FOUND) THEN
					v_person_id := v_temp_person_id;
				ELSE
					v_person_id := v_gslot_rec.person_id;
				END IF;
				CLOSE c_get_api;
				-- determine the IGS_PS_UNIT completion status
				-- This is done in the stapl_populate_gslo_tmp routine
				-- Create the Government Student Load record
				stapl_ins_govt_sdnt_load_rec(
					p_submission_yr,
					p_submission_number,
					v_person_id,
					v_gslot_rec.course_cd,
					v_gslot_rec.crv_version_number,
					v_gslot_rec.govt_semester,
					v_gslot_rec.unit_cd,
					v_gslot_rec.uv_version_number,
					v_gslot_rec.sua_cal_type,
					v_gslot_rec.sua_ci_sequence_number,
					v_gslot_rec.tr_org_unit_cd,
					v_gslot_rec.tr_ou_start_dt,
					v_gslot_rec.discipline_group_cd,
					v_gslot_rec.govt_discipline_group_cd,
					v_gslot_rec.industrial_ind,
					v_gslot_rec.eftsu,
					v_unit_completion_status, --changed
					v_logged_ind,
					v_s_log_type,
					v_creation_dt,
                    v_gslot_rec.sua_location_cd,
                    v_gslot_rec.unit_class);
			END IF;
		END LOOP;

	    -- return an error message if no previous submission
		-- records were found
		IF (v_prev_sub = FALSE) THEN
			p_message_name := 'IGS_ST_PREV_GOVT_SNAP_NO_DATA';
			RETURN FALSE;
		END IF;

	END IF;

	IF (p_submission_number = 1) THEN
	 	-- Update the Attendance Mode value for inserted records.
		FOR v_gse_att_mode IN c_gse_att_mode LOOP
			-- get IGS_ST_GVT_STDNTLOAD details
			FOR v_gslo IN c_gslo(
					v_gse_att_mode.person_id,
				     	v_gse_att_mode.course_cd) LOOP
				-- determine the system IGS_PS_UNIT mode of the IGS_PS_UNIT
				OPEN c_sua_ucl_um(
					v_gse_att_mode.person_id,
					v_gse_att_mode.course_cd,
					v_gslo.unit_cd,
					v_gslo.sua_cal_type,
					v_gslo.sua_ci_sequence_number,
                    v_gslo.sua_location_cd,
                    v_gslo.unit_class);
				FETCH c_sua_ucl_um INTO v_s_unit_mode;
				CLOSE c_sua_ucl_um;
				-- checking the value of the system IGS_PS_UNIT mode
				IF (v_s_unit_mode = 'ON') THEN
					v_on := TRUE;
				ELSIF (v_s_unit_mode = 'OFF') THEN
					v_off := TRUE;
				ELSIF (v_s_unit_mode = 'COMPOSITE') THEN
					v_composite := TRUE;
				ELSE
					v_person_id := v_gse_att_mode.person_id;
					v_course_cd := v_gse_att_mode.course_cd;
					gv_extra_details := 'Cannot determine the attendance mode for- '
							|| TO_CHAR(v_person_id) || ', '
							|| v_course_cd;
					gv_other_detail := 'Parm:'
						|| ' p_submission_yr- '		|| TO_CHAR(p_submission_yr)
						|| ', p_submission_number- ' 	|| TO_CHAR(p_submission_number)
						|| ', p_dt_time- ' 		||
							IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
						|| ', p_ind- ' 			|| p_use_most_recent_ess_ind
						|| ', ' || gv_extra_details;
				Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
                		App_Exception.Raise_Exception;
				END IF;
				IF (v_on = TRUE AND
						v_off = TRUE) THEN
					v_composite := TRUE;
				END IF;
				-- exit as soon as the IGS_PE_PERSON's mode is composite
				-- don't need to check any other records
				IF (v_composite = TRUE) THEN
					exit;
				END IF;
			END LOOP;
			-- set the appropriate attendance mode values
			IF (v_composite = TRUE) THEN
				v_attendance_mode := v_attendance_mode_3;
				v_govt_attendance_mode := v_govt_attendance_mode_3;
			ELSIF (v_on = TRUE) THEN
				v_attendance_mode := v_attendance_mode_1;
				v_govt_attendance_mode := v_govt_attendance_mode_1;
			ELSIF (v_off = TRUE) THEN
				v_attendance_mode := v_attendance_mode_2;
				v_govt_attendance_mode := v_govt_attendance_mode_2;
			ELSE
				v_person_id := v_gse_att_mode.person_id;
				v_course_cd := v_gse_att_mode.course_cd;
				gv_extra_details := 'Cannot determine the attendance mode for- '
						|| TO_CHAR(v_person_id) || ', '
						|| v_course_cd;
				gv_other_detail := 'Parm:'
					|| ' p_submission_yr- '		|| TO_CHAR(p_submission_yr)
					|| ', p_submission_number- ' 	|| TO_CHAR(p_submission_number)
					|| ', p_dt_time- ' 		||
						IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
					|| ', p_ind- ' 			|| p_use_most_recent_ess_ind
					|| ', ' || gv_extra_details;
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
                	App_Exception.Raise_Exception;
			END IF;
			-- update IGS_ST_GOVT_STDNT_EN table
			BEGIN
				FOR v_gse_upd3_rec IN c_gse_upd3(
								v_gse_att_mode.person_id,
								v_gse_att_mode.course_cd) LOOP

                              v_gse_upd3_rec.attendance_mode := v_attendance_mode;
                              v_gse_upd3_rec.govt_attendance_mode := v_govt_attendance_mode;
                              IGS_ST_GOVT_STDNT_EN_PKG.UPDATE_ROW(
						X_ROWID => v_gse_upd3_rec.rowid,
 						X_SUBMISSION_YR => v_gse_upd3_rec.submission_yr,
						X_SUBMISSION_NUMBER => v_gse_upd3_rec.submission_number,
						X_PERSON_ID => v_gse_upd3_rec.person_id,
						X_COURSE_CD => v_gse_upd3_rec.course_cd,
						X_VERSION_NUMBER => v_gse_upd3_rec.version_number,
						X_BIRTH_DT => v_gse_upd3_rec.birth_dt,
						X_SEX => v_gse_upd3_rec.sex,
						X_ABORIG_TORRES_CD  => v_gse_upd3_rec.aborig_torres_cd,
						X_GOVT_ABORIG_TORRES_CD => v_gse_upd3_rec.govt_aborig_torres_cd,
						X_CITIZENSHIP_CD  => v_gse_upd3_rec.citizenship_cd,
						X_GOVT_CITIZENSHIP_CD => v_gse_upd3_rec.govt_citizenship_cd,
						X_PERM_RESIDENT_CD => v_gse_upd3_rec.perm_resident_cd,
						X_GOVT_PERM_RESIDENT_CD => v_gse_upd3_rec.govt_perm_resident_cd,
						X_HOME_LOCATION => v_gse_upd3_rec.home_location,
						X_GOVT_HOME_LOCATION => v_gse_upd3_rec.govt_home_location,
						X_TERM_LOCATION => v_gse_upd3_rec.term_location,
						X_GOVT_TERM_LOCATION => v_gse_upd3_rec.govt_term_location,
						X_BIRTH_COUNTRY_CD =>  v_gse_upd3_rec.birth_country_cd,
						X_GOVT_BIRTH_COUNTRY_CD => v_gse_upd3_rec.govt_birth_country_cd,
						X_YR_ARRIVAL =>  v_gse_upd3_rec.yr_arrival,
						X_HOME_LANGUAGE_CD => v_gse_upd3_rec.home_language_cd,
						X_GOVT_HOME_LANGUAGE_CD => v_gse_upd3_rec.govt_home_language_cd,
						X_PRIOR_UG_INST => v_gse_upd3_rec.prior_ug_inst,
						X_GOVT_PRIOR_UG_INST => v_gse_upd3_rec.govt_prior_ug_inst,
						X_PRIOR_OTHER_QUAL => v_gse_upd3_rec.prior_other_qual,
						X_PRIOR_POST_GRAD => v_gse_upd3_rec.prior_post_grad,
						X_PRIOR_DEGREE => v_gse_upd3_rec.prior_degree,
						X_PRIOR_SUBDEG_NOTAFE => v_gse_upd3_rec.prior_subdeg_notafe,
						X_PRIOR_SUBDEG_TAFE => v_gse_upd3_rec.prior_subdeg_tafe,
						X_PRIOR_SECED_TAFE => v_gse_upd3_rec.prior_seced_tafe,
						X_PRIOR_SECED_SCHOOL => v_gse_upd3_rec.prior_seced_school,
						X_PRIOR_TAFE_AWARD => v_gse_upd3_rec.prior_tafe_award,
						X_PRIOR_STUDIES_EXEMPTION  => v_gse_upd3_rec.prior_studies_exemption,
						X_EXEMPTION_INSTITUTION_CD => v_gse_upd3_rec.exemption_institution_cd,
						X_GOVT_EXEMPT_INSTITU_CD => v_gse_upd3_rec.govt_exemption_institution_cd,
						X_ATTENDANCE_MODE => v_gse_upd3_rec.attendance_mode,
						X_GOVT_ATTENDANCE_MODE => v_gse_upd3_rec.govt_attendance_mode,
						X_ATTENDANCE_TYPE => v_gse_upd3_rec.attendance_type,
						X_GOVT_ATTENDANCE_TYPE => v_gse_upd3_rec.govt_attendance_type,
						X_COMMENCEMENT_DT => v_gse_upd3_rec.commencement_dt,
						X_MAJOR_COURSE => v_gse_upd3_rec.major_course,
						X_TERTIARY_ENTRANCE_SCORE => v_gse_upd3_rec.tertiary_entrance_score,
						X_BASIS_FOR_ADMISSION_TYPE => v_gse_upd3_rec.basis_for_admission_type,
						X_GOVT_BASIS_FOR_ADM_TYPE => v_gse_upd3_rec.govt_basis_for_admission_type,
						X_GOVT_DISABILITY =>  v_gse_upd3_rec.govt_disability,
						X_MODE => 'R');

				END LOOP;
			EXCEPTION
				WHEN e_resource_busy THEN
					p_message_name := 'IGS_ST_GOV_ENRL_REC_CANT_UPD';
					RETURN FALSE;
				WHEN OTHERS THEN
					RAISE;
			END;
			-- reset the system IGS_PS_UNIT mode variables
			v_on := FALSE;
			v_off := FALSE;
			v_composite := FALSE;
		END LOOP;
		COMMIT;

    -- Update the Attendance Type value for inserted records.
	    	OPEN c_att;
	    	FETCH c_att	INTO	v_attendance_type,
					v_govt_attendance_type,
					v_lower_enr_load_range;
		IF (c_att%NOTFOUND) THEN
			CLOSE c_att;
			gv_other_detail := 'Parm:'
				|| ' p_submission_yr- '			|| TO_CHAR(p_submission_yr)
				|| ', p_submission_number- ' 		|| TO_CHAR(p_submission_number)
				|| ', p_dt_time- ' 			||
					IGS_GE_DATE.igscharDT(p_ess_snapshot_dt_time)
				|| ', p_use_most_recent_ess_ind- ' 	|| p_use_most_recent_ess_ind;
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
        	        App_Exception.Raise_Exception;
		END IF;
		CLOSE c_att;
		-- select records from IGS_ST_GOVT_STDNT_EN which
		-- the SUM(eftsu) is greater than the lower_enr_load_range
		FOR v_gse IN c_gse(v_lower_enr_load_range) LOOP
			-- update the IGS_ST_GOVT_STDNT_EN record
			BEGIN
				FOR v_gse_upd2_rec IN c_gse_upd2(v_gse.person_id) LOOP

					v_gse_upd2_rec.attendance_type := v_attendance_type;
                              v_gse_upd2_rec.govt_attendance_type := v_govt_attendance_type;
                              IGS_ST_GOVT_STDNT_EN_PKG.UPDATE_ROW(
			                   X_ROWID => v_gse_upd2_rec.rowid,
						 X_SUBMISSION_YR => v_gse_upd2_rec.submission_yr,
						 X_SUBMISSION_NUMBER => v_gse_upd2_rec.submission_number,
						 X_PERSON_ID => v_gse_upd2_rec.person_id,
						 X_COURSE_CD => v_gse_upd2_rec.course_cd,
						 X_VERSION_NUMBER => v_gse_upd2_rec.version_number,
						 X_BIRTH_DT => v_gse_upd2_rec.birth_dt,
						 X_SEX => v_gse_upd2_rec.sex,
						 X_ABORIG_TORRES_CD  => v_gse_upd2_rec.aborig_torres_cd,
						 X_GOVT_ABORIG_TORRES_CD => v_gse_upd2_rec.govt_aborig_torres_cd,
						 X_CITIZENSHIP_CD  => v_gse_upd2_rec.citizenship_cd,
						 X_GOVT_CITIZENSHIP_CD => v_gse_upd2_rec.govt_citizenship_cd,
						 X_PERM_RESIDENT_CD => v_gse_upd2_rec.perm_resident_cd,
						 X_GOVT_PERM_RESIDENT_CD => v_gse_upd2_rec.govt_perm_resident_cd,
						 X_HOME_LOCATION => v_gse_upd2_rec.home_location,
						 X_GOVT_HOME_LOCATION => v_gse_upd2_rec.govt_home_location,
						 X_TERM_LOCATION => v_gse_upd2_rec.term_location,
						 X_GOVT_TERM_LOCATION => v_gse_upd2_rec.govt_term_location,
						 X_BIRTH_COUNTRY_CD =>  v_gse_upd2_rec.birth_country_cd,
						 X_GOVT_BIRTH_COUNTRY_CD => v_gse_upd2_rec.govt_birth_country_cd,
						 X_YR_ARRIVAL =>  v_gse_upd2_rec.yr_arrival,
						 X_HOME_LANGUAGE_CD => v_gse_upd2_rec.home_language_cd,
						 X_GOVT_HOME_LANGUAGE_CD => v_gse_upd2_rec.govt_home_language_cd,
						 X_PRIOR_UG_INST => v_gse_upd2_rec.prior_ug_inst,
						 X_GOVT_PRIOR_UG_INST => v_gse_upd2_rec.govt_prior_ug_inst,
						 X_PRIOR_OTHER_QUAL => v_gse_upd2_rec.prior_other_qual,
						 X_PRIOR_POST_GRAD => v_gse_upd2_rec.prior_post_grad,
						 X_PRIOR_DEGREE => v_gse_upd2_rec.prior_degree,
						 X_PRIOR_SUBDEG_NOTAFE => v_gse_upd2_rec.prior_subdeg_notafe,
						 X_PRIOR_SUBDEG_TAFE => v_gse_upd2_rec.prior_subdeg_tafe,
						 X_PRIOR_SECED_TAFE => v_gse_upd2_rec.prior_seced_tafe,
						 X_PRIOR_SECED_SCHOOL => v_gse_upd2_rec.prior_seced_school,
						 X_PRIOR_TAFE_AWARD => v_gse_upd2_rec.prior_tafe_award,
						 X_PRIOR_STUDIES_EXEMPTION  => v_gse_upd2_rec.prior_studies_exemption,
						 X_EXEMPTION_INSTITUTION_CD => v_gse_upd2_rec.exemption_institution_cd,
						 X_GOVT_EXEMPT_INSTITU_CD => v_gse_upd2_rec.govt_exemption_institution_cd,
						 X_ATTENDANCE_MODE => v_gse_upd2_rec.attendance_mode,
						 X_GOVT_ATTENDANCE_MODE => v_gse_upd2_rec.govt_attendance_mode,
						 X_ATTENDANCE_TYPE => v_gse_upd2_rec.attendance_type,
						 X_GOVT_ATTENDANCE_TYPE => v_gse_upd2_rec.govt_attendance_type,
						 X_COMMENCEMENT_DT => v_gse_upd2_rec.commencement_dt,
						 X_MAJOR_COURSE => v_gse_upd2_rec.major_course,
						 X_TERTIARY_ENTRANCE_SCORE => v_gse_upd2_rec.tertiary_entrance_score,
						 X_BASIS_FOR_ADMISSION_TYPE => v_gse_upd2_rec.basis_for_admission_type,
						 X_GOVT_BASIS_FOR_ADM_TYPE => v_gse_upd2_rec.govt_basis_for_admission_type,
						 X_GOVT_DISABILITY =>  v_gse_upd2_rec.govt_disability,
						 X_MODE => 'R');

					END LOOP;
			EXCEPTION
				WHEN e_resource_busy THEN
					p_message_name := 'IGS_ST_GOV_ENRL_ATT_CANT_UPD';
					RETURN FALSE;
				WHEN OTHERS THEN
					RAISE;
			END;
			IF v_total_eftsu > 1 THEN
				--Check if an entry has been written to the error log
					--Create an entry in the system log entry
					IGS_GE_GEN_003.genp_ins_log_entry (
						v_s_log_type,
						IGS_GE_DATE.igscharDT(v_creation_dt),
						'IGS_PE_PERSON IGS_PS_COURSE ' || ',' || TO_CHAR(v_person_id) || ',' || v_course_cd,
						4222,
						NULL);
					-- set that an error has been logged
					v_logged_ind := TRUE;
			END IF;
	    	END LOOP;
		COMMIT;

    -- Update the Major IGS_PS_COURSE value for inserted records
	   	v_tmp_person_id := 0;
	    	v_first_flag := TRUE;
		FOR v_gse2 IN c_gse2 LOOP
			IF (v_first_flag = TRUE) THEN
				v_person_id := v_gse2.person_id;
				v_course_cd := v_gse2.course_cd;
				v_first_flag := FALSE;
			ELSE
				-- If the IGS_PE_PERSON is same as the previous IGS_PE_PERSON and the IGS_PS_COURSE is
				-- different, but we haven't already changed the major IGS_PS_COURSE for
				-- the student.
				IF (v_gse2.person_id = v_person_id AND
						v_gse2.course_cd <> v_course_cd AND
						v_gse2.person_id <> v_tmp_person_id) THEN
					-- Not the first record and IGS_PE_PERSON enrolled in more than 1 IGS_PS_COURSE.
					-- Now using the flag for another purpose. Set the flag to true
					v_flag := TRUE;
					FOR v_gse_sca IN c_gse_sca(v_gse2.person_id) LOOP
						IF (v_flag = TRUE) THEN
							v_major_course := 2; -- major IGS_PS_COURSE
						ELSE
							v_major_course := 3; -- minor IGS_PS_COURSE
						END IF;
						v_flag := FALSE;
						-- update the IGS_ST_GOVT_STDNT_EN record
						BEGIN
							FOR v_gse_upd3_rec IN c_gse_upd3(
											v_person_id,
											v_gse_sca.course_cd) LOOP

							v_gse_upd3_rec.major_course := v_major_course;

                                           IGS_ST_GOVT_STDNT_EN_PKG.UPDATE_ROW(
					                   X_ROWID => v_gse_upd3_rec.rowid,
 								 X_SUBMISSION_YR => v_gse_upd3_rec.submission_yr,
								 X_SUBMISSION_NUMBER => v_gse_upd3_rec.submission_number,
								 X_PERSON_ID => v_gse_upd3_rec.person_id,
								 X_COURSE_CD => v_gse_upd3_rec.course_cd,
								 X_VERSION_NUMBER => v_gse_upd3_rec.version_number,
								 X_BIRTH_DT => v_gse_upd3_rec.birth_dt,
								 X_SEX => v_gse_upd3_rec.sex,
								 X_ABORIG_TORRES_CD  => v_gse_upd3_rec.aborig_torres_cd,
								 X_GOVT_ABORIG_TORRES_CD => v_gse_upd3_rec.govt_aborig_torres_cd,
								 X_CITIZENSHIP_CD  => v_gse_upd3_rec.citizenship_cd,
								 X_GOVT_CITIZENSHIP_CD => v_gse_upd3_rec.govt_citizenship_cd,
								 X_PERM_RESIDENT_CD => v_gse_upd3_rec.perm_resident_cd,
								 X_GOVT_PERM_RESIDENT_CD => v_gse_upd3_rec.govt_perm_resident_cd,
								 X_HOME_LOCATION => v_gse_upd3_rec.home_location,
								 X_GOVT_HOME_LOCATION => v_gse_upd3_rec.govt_home_location,
								 X_TERM_LOCATION => v_gse_upd3_rec.term_location,
								 X_GOVT_TERM_LOCATION => v_gse_upd3_rec.govt_term_location,
								 X_BIRTH_COUNTRY_CD =>  v_gse_upd3_rec.birth_country_cd,
								 X_GOVT_BIRTH_COUNTRY_CD => v_gse_upd3_rec.govt_birth_country_cd,
								 X_YR_ARRIVAL =>  v_gse_upd3_rec.yr_arrival,
								 X_HOME_LANGUAGE_CD => v_gse_upd3_rec.home_language_cd,
								 X_GOVT_HOME_LANGUAGE_CD => v_gse_upd3_rec.govt_home_language_cd,
								 X_PRIOR_UG_INST => v_gse_upd3_rec.prior_ug_inst,
								 X_GOVT_PRIOR_UG_INST => v_gse_upd3_rec.govt_prior_ug_inst,
								 X_PRIOR_OTHER_QUAL => v_gse_upd3_rec.prior_other_qual,
								 X_PRIOR_POST_GRAD => v_gse_upd3_rec.prior_post_grad,
								 X_PRIOR_DEGREE => v_gse_upd3_rec.prior_degree,
								 X_PRIOR_SUBDEG_NOTAFE => v_gse_upd3_rec.prior_subdeg_notafe,
								 X_PRIOR_SUBDEG_TAFE => v_gse_upd3_rec.prior_subdeg_tafe,
								 X_PRIOR_SECED_TAFE => v_gse_upd3_rec.prior_seced_tafe,
								 X_PRIOR_SECED_SCHOOL => v_gse_upd3_rec.prior_seced_school,
								 X_PRIOR_TAFE_AWARD => v_gse_upd3_rec.prior_tafe_award,
								 X_PRIOR_STUDIES_EXEMPTION  => v_gse_upd3_rec.prior_studies_exemption,
								 X_EXEMPTION_INSTITUTION_CD => v_gse_upd3_rec.exemption_institution_cd,
								 X_GOVT_EXEMPT_INSTITU_CD => v_gse_upd3_rec.govt_exemption_institution_cd,
								 X_ATTENDANCE_MODE => v_gse_upd3_rec.attendance_mode,
								 X_GOVT_ATTENDANCE_MODE => v_gse_upd3_rec.govt_attendance_mode,
								 X_ATTENDANCE_TYPE => v_gse_upd3_rec.attendance_type,
								 X_GOVT_ATTENDANCE_TYPE => v_gse_upd3_rec.govt_attendance_type,
								 X_COMMENCEMENT_DT => v_gse_upd3_rec.commencement_dt,
								 X_MAJOR_COURSE => v_gse_upd3_rec.major_course,
								 X_TERTIARY_ENTRANCE_SCORE => v_gse_upd3_rec.tertiary_entrance_score,
								 X_BASIS_FOR_ADMISSION_TYPE => v_gse_upd3_rec.basis_for_admission_type,
								 X_GOVT_BASIS_FOR_ADM_TYPE => v_gse_upd3_rec.govt_basis_for_admission_type,
								 X_GOVT_DISABILITY =>  v_gse_upd3_rec.govt_disability,
								 X_MODE => 'R');

							END LOOP;
						EXCEPTION
							WHEN e_resource_busy THEN
								p_message_name := 'IGS_ST_GOV_ENR_MAJ_CANT_UPD';
								RETURN FALSE;
							WHEN OTHERS THEN
								RAISE;
						END;
					END LOOP;
					v_tmp_person_id := v_gse2.person_id;
				END IF;
				v_person_id := v_gse2.person_id;
				v_course_cd := v_gse2.course_cd;
			END IF;
		END LOOP;
		COMMIT;

	END IF;
	IF (p_submission_number IN (1, 2)) THEN
		-- Determine the correct commencement dates for Government Student
		-- Liability and Government Student Enrolment records.
		FOR v_gsli_rec IN c_gsli LOOP
			-- Set default of derived commencement date to the government
			-- student liability (student IGS_PS_COURSE attempt) commencement date.
			v_derived_commencement_dt := v_gsli_rec.commencement_dt;
			-- Derive reportable commencement date
			v_dummy := IGS_ST_GEN_001.stap_get_comm_stdnt(
						v_gsli_rec.person_id,
						v_gsli_rec.course_cd,
						v_gsli_rec.version_number,
						v_derived_commencement_dt, -- IN OUT NOCOPY
						p_submission_yr);
			-- If the derived commencement date is different to the government
			-- student liability commencement date then we want to update the
			-- government student liability and government student enrolment
			-- commencement dates.
			IF v_derived_commencement_dt <> v_gsli_rec.commencement_dt THEN
				FOR v_gsli_upd_comm_rec IN c_gsli_upd_commencement(
									v_gsli_rec.person_id,
									v_gsli_rec.course_cd) LOOP
					BEGIN

						v_gsli_upd_comm_rec.commencement_dt := v_derived_commencement_dt;
                                    IGS_ST_GVT_STDNT_LBL_PKG.UPDATE_ROW(
                                          X_ROWID   => v_gsli_upd_comm_rec.rowid,
							X_SUBMISSION_YR =>  v_gsli_upd_comm_rec.submission_yr,
							X_SUBMISSION_NUMBER =>  v_gsli_upd_comm_rec.submission_number,
							X_PERSON_ID =>  v_gsli_upd_comm_rec.person_id,
							X_COURSE_CD =>  v_gsli_upd_comm_rec.course_cd,
							X_GOVT_SEMESTER =>  v_gsli_upd_comm_rec.govt_semester,
							X_VERSION_NUMBER =>  v_gsli_upd_comm_rec.version_number,
							X_HECS_PAYMENT_OPTION =>  v_gsli_upd_comm_rec.hecs_payment_option,
							X_GOVT_HECS_PAYMENT_OPTION =>  v_gsli_upd_comm_rec.govt_hecs_payment_option,
							X_TOTAL_EFTSU =>  v_gsli_upd_comm_rec.total_eftsu,
							X_INDUSTRIAL_EFTSU =>  v_gsli_upd_comm_rec.industrial_eftsu,
							X_HECS_PREXMT_EXIE =>  v_gsli_upd_comm_rec.hecs_prexmt_exie,
							X_HECS_AMOUNT_PAID =>  v_gsli_upd_comm_rec.hecs_amount_paid,
							X_TUITION_FEE =>  v_gsli_upd_comm_rec.tuition_fee,
							X_DIFFERENTIAL_HECS_IND =>  v_gsli_upd_comm_rec.differential_hecs_ind,
							X_BIRTH_DT =>  v_gsli_upd_comm_rec.birth_dt,
							X_SEX =>  v_gsli_upd_comm_rec.sex,
							X_CITIZENSHIP_CD =>  v_gsli_upd_comm_rec.citizenship_cd,
							X_GOVT_CITIZENSHIP_CD =>  v_gsli_upd_comm_rec.govt_citizenship_cd,
							X_PERM_RESIDENT_CD =>  v_gsli_upd_comm_rec.perm_resident_cd,
							X_GOVT_PERM_RESIDENT_CD =>  v_gsli_upd_comm_rec.govt_perm_resident_cd,
							X_COMMENCEMENT_DT =>  v_gsli_upd_comm_rec.commencement_dt,
							X_MODE => 'R');

					EXCEPTION
						WHEN e_resource_busy THEN
							p_message_name := 'IGS_ST_GOV_LIAB_CANT_UPD';
							RETURN FALSE;
						WHEN OTHERS THEN
							RAISE;
					END;
				END LOOP;
			END IF;
		END LOOP;
		IF p_submission_number = 1 THEN
			-- Determine the correct commencement dates for Government Enrolment records
			FOR v_gse_enrolment_rec IN c_gse_enrolment LOOP
				-- Set default of derived commencement date to the government
				-- student enrolment (student IGS_PS_COURSE attempt) commencement date.
				v_derived_commencement_dt := v_gse_enrolment_rec.commencement_dt;
				-- Derive reportable commencement date
				v_dummy := IGS_ST_GEN_001.stap_get_comm_stdnt(
							v_gse_enrolment_rec.person_id,
							v_gse_enrolment_rec.course_cd,
							v_gse_enrolment_rec.version_number,
							v_derived_commencement_dt, -- IN OUT NOCOPY
							p_submission_yr);
				-- If the derived commencement date is different to the government
				-- student liability commencement date then we want to update the
				-- government student enrolment commencement dates.
				IF v_derived_commencement_dt <> v_gse_enrolment_rec.commencement_dt THEN
					FOR v_gse_upd_comm_rec IN c_gse_upd_commencement(
										v_gse_enrolment_rec.person_id,
										v_gse_enrolment_rec.course_cd) LOOP
						BEGIN

							v_gse_upd_comm_rec.commencement_dt := v_derived_commencement_dt;

							IGS_ST_GOVT_STDNT_EN_PKG.UPDATE_ROW(
					                   X_ROWID => v_gse_upd_comm_rec.rowid,
 								 X_SUBMISSION_YR => v_gse_upd_comm_rec.submission_yr,
								 X_SUBMISSION_NUMBER => v_gse_upd_comm_rec.submission_number,
								 X_PERSON_ID => v_gse_upd_comm_rec.person_id,
								 X_COURSE_CD => v_gse_upd_comm_rec.course_cd,
								 X_VERSION_NUMBER => v_gse_upd_comm_rec.version_number,
								 X_BIRTH_DT => v_gse_upd_comm_rec.birth_dt,
								 X_SEX => v_gse_upd_comm_rec.sex,
								 X_ABORIG_TORRES_CD  => v_gse_upd_comm_rec.aborig_torres_cd,
								 X_GOVT_ABORIG_TORRES_CD => v_gse_upd_comm_rec.govt_aborig_torres_cd,
								 X_CITIZENSHIP_CD  => v_gse_upd_comm_rec.citizenship_cd,
								 X_GOVT_CITIZENSHIP_CD => v_gse_upd_comm_rec.govt_citizenship_cd,
								 X_PERM_RESIDENT_CD => v_gse_upd_comm_rec.perm_resident_cd,
								 X_GOVT_PERM_RESIDENT_CD => v_gse_upd_comm_rec.govt_perm_resident_cd,
								 X_HOME_LOCATION => v_gse_upd_comm_rec.home_location,
								 X_GOVT_HOME_LOCATION => v_gse_upd_comm_rec.govt_home_location,
								 X_TERM_LOCATION => v_gse_upd_comm_rec.term_location,
								 X_GOVT_TERM_LOCATION => v_gse_upd_comm_rec.govt_term_location,
								 X_BIRTH_COUNTRY_CD =>  v_gse_upd_comm_rec.birth_country_cd,
								 X_GOVT_BIRTH_COUNTRY_CD => v_gse_upd_comm_rec.govt_birth_country_cd,
								 X_YR_ARRIVAL =>  v_gse_upd_comm_rec.yr_arrival,
								 X_HOME_LANGUAGE_CD => v_gse_upd_comm_rec.home_language_cd,
								 X_GOVT_HOME_LANGUAGE_CD => v_gse_upd_comm_rec.govt_home_language_cd,
								 X_PRIOR_UG_INST => v_gse_upd_comm_rec.prior_ug_inst,
								 X_GOVT_PRIOR_UG_INST => v_gse_upd_comm_rec.govt_prior_ug_inst,
								 X_PRIOR_OTHER_QUAL => v_gse_upd_comm_rec.prior_other_qual,
								 X_PRIOR_POST_GRAD => v_gse_upd_comm_rec.prior_post_grad,
								 X_PRIOR_DEGREE => v_gse_upd_comm_rec.prior_degree,
								 X_PRIOR_SUBDEG_NOTAFE => v_gse_upd_comm_rec.prior_subdeg_notafe,
								 X_PRIOR_SUBDEG_TAFE => v_gse_upd_comm_rec.prior_subdeg_tafe,
								 X_PRIOR_SECED_TAFE => v_gse_upd_comm_rec.prior_seced_tafe,
								 X_PRIOR_SECED_SCHOOL => v_gse_upd_comm_rec.prior_seced_school,
								 X_PRIOR_TAFE_AWARD => v_gse_upd_comm_rec.prior_tafe_award,
								 X_PRIOR_STUDIES_EXEMPTION  => v_gse_upd_comm_rec.prior_studies_exemption,
								 X_EXEMPTION_INSTITUTION_CD => v_gse_upd_comm_rec.exemption_institution_cd,
								 X_GOVT_EXEMPT_INSTITU_CD => v_gse_upd_comm_rec.govt_exemption_institution_cd,
								 X_ATTENDANCE_MODE => v_gse_upd_comm_rec.attendance_mode,
								 X_GOVT_ATTENDANCE_MODE => v_gse_upd_comm_rec.govt_attendance_mode,
								 X_ATTENDANCE_TYPE => v_gse_upd_comm_rec.attendance_type,
								 X_GOVT_ATTENDANCE_TYPE => v_gse_upd_comm_rec.govt_attendance_type,
								 X_COMMENCEMENT_DT => v_gse_upd_comm_rec.commencement_dt,
								 X_MAJOR_COURSE => v_gse_upd_comm_rec.major_course,
								 X_TERTIARY_ENTRANCE_SCORE => v_gse_upd_comm_rec.tertiary_entrance_score,
								 X_BASIS_FOR_ADMISSION_TYPE => v_gse_upd_comm_rec.basis_for_admission_type,
								 X_GOVT_BASIS_FOR_ADM_TYPE => v_gse_upd_comm_rec.govt_basis_for_admission_type,
								 X_GOVT_DISABILITY =>  v_gse_upd_comm_rec.govt_disability,
								 X_MODE => 'R');

						EXCEPTION
							WHEN e_resource_busy THEN
								p_message_name := 'IGS_ST_GOV_ENRL_DT_CANT_UPD';
								RETURN FALSE;
							WHEN OTHERS THEN
								RAISE;
						END;
					END LOOP;
				END IF;
			END LOOP;
		END IF;
		COMMIT;

    -- Update the Government Student Liability values for the inserted records
		FOR v_update_total_eftsu IN c_update_total_eftsu LOOP
			BEGIN
				FOR v_gsli_upd2_rec IN c_gsli_upd2(
								v_update_total_eftsu.person_id,
								v_update_total_eftsu.course_cd,
								v_update_total_eftsu.govt_semester) LOOP

					v_gsli_upd2_rec.total_eftsu := v_update_total_eftsu.v_upd_total_eftsu;

                              IGS_ST_GVT_STDNT_LBL_PKG.UPDATE_ROW(
                                          X_ROWID   => v_gsli_upd2_rec.rowid,
							X_SUBMISSION_YR =>  v_gsli_upd2_rec.submission_yr,
							X_SUBMISSION_NUMBER =>  v_gsli_upd2_rec.submission_number,
							X_PERSON_ID =>  v_gsli_upd2_rec.person_id,
							X_COURSE_CD =>  v_gsli_upd2_rec.course_cd,
							X_GOVT_SEMESTER =>  v_gsli_upd2_rec.govt_semester,
							X_VERSION_NUMBER =>  v_gsli_upd2_rec.version_number,
							X_HECS_PAYMENT_OPTION =>  v_gsli_upd2_rec.hecs_payment_option,
							X_GOVT_HECS_PAYMENT_OPTION =>  v_gsli_upd2_rec.govt_hecs_payment_option,
							X_TOTAL_EFTSU =>  v_gsli_upd2_rec.total_eftsu,
							X_INDUSTRIAL_EFTSU =>  v_gsli_upd2_rec.industrial_eftsu,
							X_HECS_PREXMT_EXIE =>  v_gsli_upd2_rec.hecs_prexmt_exie,
							X_HECS_AMOUNT_PAID =>  v_gsli_upd2_rec.hecs_amount_paid,
							X_TUITION_FEE =>  v_gsli_upd2_rec.tuition_fee,
							X_DIFFERENTIAL_HECS_IND =>  v_gsli_upd2_rec.differential_hecs_ind,
							X_BIRTH_DT =>  v_gsli_upd2_rec.birth_dt,
							X_SEX =>  v_gsli_upd2_rec.sex,
							X_CITIZENSHIP_CD =>  v_gsli_upd2_rec.citizenship_cd,
							X_GOVT_CITIZENSHIP_CD =>  v_gsli_upd2_rec.govt_citizenship_cd,
							X_PERM_RESIDENT_CD =>  v_gsli_upd2_rec.perm_resident_cd,
							X_GOVT_PERM_RESIDENT_CD =>  v_gsli_upd2_rec.govt_perm_resident_cd,
							X_COMMENCEMENT_DT =>  v_gsli_upd2_rec.commencement_dt,
							X_MODE => 'R');





					IF v_update_total_eftsu.v_upd_total_eftsu > 1 THEN
						IF v_logged_ind = FALSE THEN

                   	v_logged_ind := TRUE;
						END IF;
						IGS_GE_GEN_003.genp_ins_log_entry(
							v_s_log_type,
							v_creation_dt,
							'IGS_PE_PERSON IGS_PS_COURSE,' 	||
							TO_CHAR(v_update_total_eftsu.person_id)	|| ',' ||
							v_update_total_eftsu.course_cd,
							4222,
							NULL);
					END IF;
				END LOOP;
			EXCEPTION
				WHEN e_resource_busy THEN
					p_message_name := 'IGS_ST_GOV_LIABILITY_CANT_UPD';
					RETURN FALSE;
				WHEN OTHERS THEN
					RAISE;
			END;
		END LOOP;
		COMMIT;

	FOR v_update_indus_eftsu IN c_update_indus_eftsu LOOP
			BEGIN
				FOR v_gsli_upd2_rec IN c_gsli_upd2(
								v_update_indus_eftsu.person_id,
								v_update_indus_eftsu.course_cd,
								v_update_indus_eftsu.govt_semester) LOOP

					v_gsli_upd2_rec.industrial_eftsu := v_update_indus_eftsu.v_upd_indus_eftsu;

					IGS_ST_GVT_STDNT_LBL_PKG.UPDATE_ROW(
                                          X_ROWID   => v_gsli_upd2_rec.rowid,
							X_SUBMISSION_YR =>  v_gsli_upd2_rec.submission_yr,
							X_SUBMISSION_NUMBER =>  v_gsli_upd2_rec.submission_number,
							X_PERSON_ID =>  v_gsli_upd2_rec.person_id,
							X_COURSE_CD =>  v_gsli_upd2_rec.course_cd,
							X_GOVT_SEMESTER =>  v_gsli_upd2_rec.govt_semester,
							X_VERSION_NUMBER =>  v_gsli_upd2_rec.version_number,
							X_HECS_PAYMENT_OPTION =>  v_gsli_upd2_rec.hecs_payment_option,
							X_GOVT_HECS_PAYMENT_OPTION =>  v_gsli_upd2_rec.govt_hecs_payment_option,
							X_TOTAL_EFTSU =>  v_gsli_upd2_rec.total_eftsu,
							X_INDUSTRIAL_EFTSU =>  v_gsli_upd2_rec.industrial_eftsu,
							X_HECS_PREXMT_EXIE =>  v_gsli_upd2_rec.hecs_prexmt_exie,
							X_HECS_AMOUNT_PAID =>  v_gsli_upd2_rec.hecs_amount_paid,
							X_TUITION_FEE =>  v_gsli_upd2_rec.tuition_fee,
							X_DIFFERENTIAL_HECS_IND =>  v_gsli_upd2_rec.differential_hecs_ind,
							X_BIRTH_DT =>  v_gsli_upd2_rec.birth_dt,
							X_SEX =>  v_gsli_upd2_rec.sex,
							X_CITIZENSHIP_CD =>  v_gsli_upd2_rec.citizenship_cd,
							X_GOVT_CITIZENSHIP_CD =>  v_gsli_upd2_rec.govt_citizenship_cd,
							X_PERM_RESIDENT_CD =>  v_gsli_upd2_rec.perm_resident_cd,
							X_GOVT_PERM_RESIDENT_CD =>  v_gsli_upd2_rec.govt_perm_resident_cd,
							X_COMMENCEMENT_DT =>  v_gsli_upd2_rec.commencement_dt,
							X_MODE => 'R');


					IF v_update_indus_eftsu.v_upd_indus_eftsu > 1 THEN
						IF v_logged_ind = FALSE THEN
			            		v_logged_ind := TRUE;
						END IF;
						IGS_GE_GEN_003.genp_ins_log_entry(
							v_s_log_type,
							v_creation_dt,
							'IGS_PE_PERSON IGS_PS_COURSE,' 	||
							TO_CHAR(v_update_indus_eftsu.person_id)	|| ',' ||
							v_update_indus_eftsu.course_cd,
							4223,
							NULL);
					END IF;
				END LOOP;
			EXCEPTION
				WHEN e_resource_busy THEN
					p_message_name := 'IGS_ST_GOV_LIA_INDUS_CANT_UPD';
					RETURN FALSE;
				WHEN OTHERS THEN
					RAISE;
			END;
		END LOOP;
		COMMIT;
     END IF;
	-- commit all the changes made
	COMMIT;
	-- set the default message number and return type
	p_message_name := NULL;
	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		IF c_govt_snpsht_ctl%ISOPEN THEN
			CLOSE c_govt_snpsht_ctl;
		END IF;
		IF c_gsc%ISOPEN THEN
			CLOSE c_gsc;
		END IF;
		IF c_essc%ISOPEN THEN
			CLOSE c_essc;
		END IF;
		IF c_get_att_type%ISOPEN THEN
			CLOSE c_get_att_type;
		END IF;
		IF c_get_att_mode_1%ISOPEN THEN
			CLOSE c_get_att_mode_1;
		END IF;
		IF c_get_att_mode_2%ISOPEN THEN
			CLOSE c_get_att_mode_2;
		END IF;
		IF c_get_att_mode_3%ISOPEN THEN
			CLOSE c_get_att_mode_3;
		END IF;
		IF c_enr_snpsht_rec%ISOPEN THEN
			CLOSE c_enr_snpsht_rec;
		END IF;
		IF c_alias_val%ISOPEN THEN
			CLOSE c_alias_val;
		END IF;
		IF c_get_api%ISOPEN THEN
			CLOSE c_get_api;
		END IF;
		IF c_gse_att_mode%ISOPEN THEN
			CLOSE c_gse_att_mode;
		END IF;
		IF c_gslo%ISOPEN THEN
			CLOSE c_gslo;
		END IF;
		IF c_sua_ucl_um%ISOPEN THEN
			CLOSE c_sua_ucl_um;
		END IF;
		IF c_att%ISOPEN THEN
			CLOSE c_att;
		END IF;
		IF c_gse%ISOPEN THEN
			CLOSE c_gse;
		END IF;
		IF c_gse2%ISOPEN THEN
			CLOSE c_gse2;
		END IF;
		IF c_gse_sca%ISOPEN THEN
			CLOSE c_gse_sca;
		END IF;
		IF c_get_indus_ind%ISOPEN THEN
			CLOSE c_get_indus_ind;
		END IF;
		IF c_update_total_eftsu%ISOPEN THEN
			CLOSE c_update_total_eftsu;
		END IF;
		IF c_update_indus_eftsu%ISOPEN THEN
			CLOSE c_update_indus_eftsu;
		END IF;
		IF c_gsc_upd%ISOPEN THEN
			CLOSE c_gsc_upd;
		END IF;
		IF c_essc_upd%ISOPEN THEN
			CLOSE c_essc_upd;
		END IF;
		IF c_gsli_upd%ISOPEN THEN
			CLOSE c_gsli_upd;
		END IF;
		IF c_gsli_upd2%ISOPEN THEN
			CLOSE c_gsli_upd2;
		END IF;
		IF c_gslo_upd%ISOPEN THEN
			CLOSE c_gslo_upd;
		END IF;
		IF c_gse_upd%ISOPEN THEN
			CLOSE c_gse_upd;
		END IF;
		IF c_gse_upd2%ISOPEN THEN
			CLOSE c_gse_upd2;
		END IF;
		IF c_gse_upd3%ISOPEN THEN
			CLOSE c_gse_upd3;
		END IF;
		IF c_gsli%ISOPEN THEN
			CLOSE c_gsli;
		END IF;
		IF c_gsli_upd_commencement%ISOPEN THEN
			CLOSE c_gsli_upd_commencement;
		END IF;
		IF c_gse_enrolment%ISOPEN THEN
			CLOSE c_gse_enrolment;
		END IF;
		IF c_gse_upd_commencement%ISOPEN THEN
			CLOSE c_gse_upd_commencement;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stap_ins_govt_snpsht');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END stap_ins_govt_snpsht;

Procedure Stap_Ins_Gsch(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER )
AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_ins_gsch
	-- comment.
DECLARE
	-- table to hold old units
	TYPE r_units_typ IS RECORD (
			unit_cd				IGS_ST_GVT_STDNTLOAD.unit_cd%TYPE,
			sua_cal_type			IGS_ST_GVT_STDNTLOAD.sua_cal_type%TYPE,
			sua_ci_sequence_number		IGS_ST_GVT_STDNTLOAD.sua_ci_sequence_number%TYPE,
			tr_org_unit_cd			IGS_ST_GVT_STDNTLOAD.tr_org_unit_cd%TYPE,
			tr_ou_start_dt			IGS_ST_GVT_STDNTLOAD.tr_ou_start_dt%TYPE,
			govt_discipline_group_cd	IGS_ST_GVT_STDNTLOAD.govt_discipline_group_cd%TYPE,
			eftsu				IGS_ST_GVT_STDNTLOAD.eftsu%TYPE,
			industrial_ind			IGS_ST_GVT_STDNTLOAD.industrial_ind%TYPE,
            uoo_id             igs_ps_unit_ofr_opt.uoo_id%TYPE);
	r_units		r_units_typ;
	TYPE t_units_typ IS TABLE OF r_units%TYPE
		INDEX BY BINARY_INTEGER;
	t_old_units		t_units_typ;
	t_new_units		t_units_typ;
	t_blank			t_units_typ;
	cst_exempt		CONSTANT VARCHAR2(6) := 'EXEMPT';
	CURSOR c_ess IS
		SELECT UNIQUE	ess.snapshot_dt_time
		FROM		IGS_EN_ST_SNAPSHOT ess
		ORDER BY	ess.snapshot_dt_time DESC;
	CURSOR c_gsli_gslc IS
		SELECT 	gsli.person_id,
			gsli.course_cd,
			gsli.version_number,
			gsli.govt_semester,
			gsli.hecs_payment_option,
			gsli.differential_hecs_ind,
			gsli.hecs_prexmt_exie,
			gsli.hecs_amount_paid,
			gsli.citizenship_cd,
			gsli.perm_resident_cd,
			gslc.cal_type,
			gslc.ci_sequence_number,
			ghpo.s_hecs_payment_type
		FROM	IGS_ST_GVT_STDNT_LBL 	gsli,
			IGS_ST_GVTSEMLOAD_CA 	gslc,
			IGS_FI_HECS_PAY_OPTN 	hpo,
			IGS_FI_GOV_HEC_PA_OP 	ghpo
		WHERE	gsli.submission_yr 	= p_submission_yr		AND
			gsli.submission_number 	= p_submission_number 		AND
			gslc.submission_yr	= gsli.submission_yr 		AND
			gslc.submission_number 	= gsli.submission_number	AND
			gslc.govt_semester 	= gsli.govt_semester AND
			hpo.hecs_payment_option(+) 	= gsli.hecs_payment_option	AND
			ghpo.govt_hecs_payment_option(+) 	= hpo.hecs_payment_option
		ORDER BY	gsli.person_id,
				gsli.course_cd,
				gsli.govt_semester;
	CURSOR c_scho_hpo_ghpo (
				cp_person_id	IGS_EN_STDNTPSHECSOP.person_id%TYPE,
				cp_course_cd	IGS_EN_STDNTPSHECSOP.course_cd%TYPE,
				cp_effective_dt	IGS_EN_STDNTPSHECSOP.start_dt%TYPE) IS
		SELECT	scho.differential_hecs_ind,
			scho.hecs_payment_option,
			hpo.govt_hecs_payment_option,
			ghpo.s_hecs_payment_type
		FROM	IGS_EN_STDNTPSHECSOP 	scho,
			IGS_FI_HECS_PAY_OPTN 		hpo,
			IGS_FI_GOV_HEC_PA_OP 	ghpo
		WHERE	scho.person_id 			= cp_person_id			AND
			scho.course_cd 			= cp_course_cd			AND
			scho.start_dt 			<= cp_effective_dt		AND
			(scho.end_dt 			IS NULL				OR
			scho.end_dt 			>= cp_effective_dt)		AND
			hpo.hecs_payment_option 	= scho.hecs_payment_option	AND
			ghpo.govt_hecs_payment_option 	= hpo.hecs_payment_option
		ORDER BY	scho.end_dt;
	CURSOR	c_daiv_sgcc (
				cp_sua_cal_type			IGS_CA_DA_INST_V.cal_type%TYPE,
				cp_sua_ci_sequence_number	IGS_CA_DA_INST_V.ci_sequence_number%TYPE) IS
		SELECT 	daiv.alias_val
		FROM	IGS_CA_DA_INST_V 	daiv,
			IGS_GE_S_GEN_CAL_CON 		sgcc
		WHERE	daiv.cal_type 		= cp_sua_cal_type 		AND
 			daiv.ci_sequence_number = cp_sua_ci_sequence_number 	AND
			daiv.dt_alias 		= sgcc.census_dt_alias
		ORDER BY	daiv.alias_val;
	CURSOR	c_gsc1 (
			cp_person_id			IGS_ST_GVT_SPSHT_CHG.person_id%TYPE,
			cp_course_cd			IGS_ST_GVT_SPSHT_CHG.course_cd%TYPE,
			cp_crv_version_number		IGS_ST_GVT_SPSHT_CHG.version_number%TYPE,
			cp_govt_semester		IGS_ST_GVT_SPSHT_CHG.govt_semester%TYPE,
			cp_old_hecs_prexmt_exie		IGS_ST_GVT_SPSHT_CHG.old_hecs_prexmt_exie%TYPE,
			cp_old_hecs_amount_paid		IGS_ST_GVT_SPSHT_CHG.old_hecs_amount_paid%TYPE,
			cp_old_hecs_payment_option	IGS_ST_GVT_SPSHT_CHG.old_hecs_payment_option%TYPE,
			cp_old_differential_hecs_ind
							IGS_ST_GVT_SPSHT_CHG.old_differential_hecs_ind%TYPE,
			cp_hecs_amount_paid		IGS_ST_GVT_SPSHT_CHG.hecs_amount_paid%TYPE,
			cp_hecs_prexmt_exie		IGS_ST_GVT_SPSHT_CHG.hecs_prexmt_exie%TYPE,
			cp_hecs_payment_option		IGS_ST_GVT_SPSHT_CHG.hecs_payment_option%TYPE,
			cp_differential_hecs_ind	IGS_ST_GVT_SPSHT_CHG.differential_hecs_ind%TYPE) IS
		SELECT	'x'
		FROM	IGS_ST_GVT_SPSHT_CHG	gsc
		WHERE	gsc.submission_yr 		= p_submission_yr		AND
			gsc.submission_number 		= p_submission_number 		AND
			gsc.person_id 			= cp_person_id			AND
			gsc.course_cd 			= cp_course_cd			AND
			gsc.version_number 		= cp_crv_version_number		AND
			gsc.govt_semester 		= cp_govt_semester		AND
			gsc.old_hecs_prexmt_exie 	= cp_old_hecs_prexmt_exie	AND
			gsc.old_hecs_amount_paid  	= cp_old_hecs_amount_paid 	AND
			gsc.old_hecs_payment_option	= cp_old_hecs_payment_option	AND
			gsc.old_differential_hecs_ind	= cp_old_differential_hecs_ind	AND
			gsc.hecs_amount_paid  		= cp_hecs_amount_paid		AND
			gsc.hecs_prexmt_exie 		= cp_hecs_prexmt_exie		AND
			gsc.hecs_payment_option		= cp_hecs_payment_option	AND
			gsc.differential_hecs_ind	= cp_differential_hecs_ind;
	CURSOR	c_scho1 (
			cp_person_id			IGS_EN_STDNTPSHECSOP.person_id%TYPE,
			cp_course_cd			IGS_EN_STDNTPSHECSOP.course_cd%TYPE,
			cp_old_hecs_payment_option
							IGS_EN_STDNTPSHECSOP.hecs_payment_option%TYPE,
			cp_old_differential_hecs_ind
							IGS_EN_STDNTPSHECSOP.differential_hecs_ind%TYPE) IS
		SELECT 	scho.last_updated_by,
			scho.last_update_date
		FROM 	IGS_EN_STDNTPSHECSOP	scho
		WHERE	scho.person_id 			= cp_person_id			AND
			scho.course_cd 			= cp_course_cd			AND
			scho.end_dt			IS NOT NULL			AND
			scho.hecs_payment_option 	= cp_old_hecs_payment_option	AND
			scho.differential_hecs_ind 	= cp_old_differential_hecs_ind
		ORDER BY	scho.end_dt DESC;
	CURSOR c_scho2 (
			cp_person_id			IGS_EN_STDNTPSHECSOP.person_id%TYPE,
			cp_course_cd			IGS_EN_STDNTPSHECSOP.course_cd%TYPE,
			cp_effective_dt			IGS_EN_STDNTPSHECSOP.end_dt%TYPE) IS
		SELECT 	scho.last_updated_by,
			scho.last_update_date
		FROM 	IGS_EN_STDNTPSHECSOP	scho
		WHERE	scho.person_id 	= cp_person_id		AND
			scho.course_cd 	= cp_course_cd		AND
			scho.end_dt	IS NOT NULL		-- AND
--			scho.end_dt 	> cp_effective_dt
		ORDER BY	scho.end_dt DESC;
	CURSOR c_gslo (
			cp_govt_semester	IGS_ST_GVT_STDNTLOAD.govt_semester%TYPE,
			cp_person_id		IGS_ST_GVT_STDNTLOAD.person_id%TYPE,
			cp_course_cd		IGS_ST_GVT_STDNTLOAD.course_cd%TYPE) IS
		SELECT	gslo.unit_cd,
			gslo.sua_cal_type,
			gslo.sua_ci_sequence_number,
			gslo.tr_org_unit_cd,
			gslo.tr_ou_start_dt,
			gslo.govt_discipline_group_cd,
			gslo.eftsu,
			gslo.industrial_ind,
            uoo.uoo_id
		FROM	IGS_ST_GVT_STDNTLOAD	gslo,
                igs_ps_unit_ofr_opt uoo
		WHERE	gslo.submission_yr 	= p_submission_yr	AND
			gslo.submission_number 	= p_submission_number	AND
			gslo.govt_semester 	= cp_govt_semester	AND
			gslo.person_id 		= cp_person_id		AND
			gslo.course_cd 		= cp_course_cd AND
            gslo.unit_cd = uoo.unit_cd AND
            gslo.uv_version_number = uoo.version_number AND
            gslo.sua_cal_type  = uoo.cal_type AND
            gslo.sua_ci_sequence_number  = uoo.ci_sequence_number AND
            gslo.sua_location_cd = uoo.location_cd AND
            gslo.unit_class = uoo.unit_class;
	CURSOR c_ess_uv_gslc (
			cp_snapshot_dt_time	IGS_EN_ST_SNAPSHOT.snapshot_dt_time%TYPE,
			cp_govt_semester	IGS_ST_GVTSEMLOAD_CA.govt_semester%TYPE,
			cp_person_id		IGS_EN_ST_SNAPSHOT.person_id%TYPE,
			cp_course_cd		IGS_EN_ST_SNAPSHOT.course_cd%TYPE) IS
		SELECT	ess.unit_cd,
			ess.sua_cal_type,
			ess.sua_ci_sequence_number,
			ess.tr_org_unit_cd,
			ess.tr_ou_start_dt,
			ess.govt_discipline_group_cd,
			ess.eftsu,
			uv.industrial_ind,
			ess.crv_version_number,
			ess.uv_version_number,
			ess.enrolled_dt,
			ess.discontinued_dt,
			ess.ci_cal_type,
			ess.ci_sequence_number,
            uoo.uoo_id
		FROM	IGS_EN_ST_SNAPSHOT ess,
			IGS_PS_UNIT_VER 		uv,
			IGS_ST_GVTSEMLOAD_CA 	gslc,
            igs_ps_unit_ofr_opt uoo
		WHERE	ess.snapshot_dt_time 	= cp_snapshot_dt_time		AND
			ess.ci_cal_type 	= gslc.cal_type			AND
			ess.ci_sequence_number 	= gslc.ci_sequence_number	AND
			gslc.submission_yr 	= p_submission_yr		AND
			gslc.submission_number 	= p_submission_number		AND
			gslc.govt_semester 	= cp_govt_semester		AND
			ess.person_id 		= cp_person_id			AND
			ess.course_cd 		= cp_course_cd			AND
			ess.govt_reportable_ind <> 'X'				AND
			uv.unit_cd 		= ess.unit_cd			AND
			uv.version_number 	= ess.uv_version_number AND
            ess.unit_cd = uoo.unit_cd AND
            ess.uv_version_number = uoo.version_number AND
            ess.sua_cal_type  = uoo.cal_type AND
            ess.sua_ci_sequence_number  = uoo.ci_sequence_number AND
            ess.sua_location_cd = uoo.location_cd  AND
            ess.unit_class = uoo.unit_class ;
	CURSOR c_suah1 (
			cp_person_id		IGS_EN_SU_ATTEMPT_H.person_id%TYPE,
			cp_course_cd		IGS_EN_SU_ATTEMPT_H.course_cd%TYPE,
			cp_uoo_id		IGS_EN_SU_ATTEMPT_H.uoo_id%TYPE) IS
		SELECT	suah.last_updated_by,
			suah.last_update_date
		FROM	IGS_EN_SU_ATTEMPT_H 	suah
		WHERE	suah.person_id	 		= cp_person_id		AND
			suah.course_cd 			= cp_course_cd		AND
			suah.uoo_id 			= cp_uoo_id		AND
			(suah.enrolled_dt		IS NOT NULL		OR
 			suah.discontinued_dt 		IS NOT NULL)
		ORDER BY	suah.hist_end_dt DESC;
	CURSOR c_suah2 (
			cp_person_id		IGS_EN_SU_ATTEMPT_H.person_id%TYPE,
			cp_course_cd		IGS_EN_SU_ATTEMPT_H.course_cd%TYPE,
			cp_uoo_id		IGS_EN_SU_ATTEMPT_H.uoo_id%TYPE) IS
        SELECT	suah.last_updated_by,
			suah.last_update_date
		FROM	IGS_EN_SU_ATTEMPT_H	suah
		WHERE	suah.person_id 		= cp_person_id		AND
			suah.course_cd 		= cp_course_cd		AND
			suah.uoo_id 		= cp_uoo_id
		ORDER BY 	suah.hist_end_dt DESC;
	CURSOR c_suah3 (
			cp_person_id		IGS_EN_SU_ATTEMPT_H.person_id%TYPE,
			cp_course_cd		IGS_EN_SU_ATTEMPT_H.course_cd%TYPE,
			cp_uoo_id		IGS_EN_SU_ATTEMPT_H.uoo_id%TYPE) IS
		SELECT	suah.last_updated_by,
			suah.last_update_date
		FROM	IGS_EN_SU_ATTEMPT_H   suah
		WHERE	suah.person_id 		= cp_person_id		AND
			suah.course_cd 		= cp_course_cd		AND
			suah.uoo_id 		= cp_uoo_id		AND
			(suah.enrolled_dt 	IS NOT NULL	OR
			suah.discontinued_dt 	IS NOT NULL)
		ORDER BY	suah.hist_end_dt DESC;
	CURSOR	c_sua (
			cp_person_id		IGS_EN_SU_ATTEMPT.person_id%TYPE,
			cp_course_cd		IGS_EN_SU_ATTEMPT.course_cd%TYPE,
			cp_uoo_id		IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
		SELECT	sua.last_updated_by,
			sua.last_update_date
		FROM	IGS_EN_SU_ATTEMPT	sua
		WHERE 	sua.person_id 		= cp_person_id			AND
			sua.course_cd 		= cp_course_cd			AND
			sua.uoo_id 		= cp_uoo_id
		ORDER BY	sua.last_update_date DESC;
	CURSOR	c_gse (
			cp_person_id		IGS_ST_GOVT_STDNT_EN.person_id%TYPE,
			cp_course_cd		IGS_ST_GOVT_STDNT_EN.course_cd%TYPE) IS
		SELECT	gse.person_id,
			gse.course_cd,
			gse.version_number,
			gse.citizenship_cd,
			gse.perm_resident_cd,
			gse.prior_degree,
			gse.prior_post_grad
		FROM	IGS_ST_GOVT_STDNT_EN 	gse
		WHERE	gse.submission_yr 	= p_submission_yr	AND
			gse.submission_number =  1 AND		-- Government Enrolment only sub 1
			gse.person_id = cp_person_id AND
			gse.course_cd = cp_course_cd;
	CURSOR	c_ps (
			cp_person_id		IGS_PE_STATISTICS.person_id%TYPE,
			cp_effective_dt		IGS_PE_STATISTICS.start_dt%TYPE) IS
		SELECT 	NVL(ps.citizenship_cd, '9'),
			NVL(ps.perm_resident_cd, '9'),
			ps.prior_degree,
			ps.prior_post_grad
		FROM	IGS_PE_STATISTICS 	ps
		WHERE	ps.person_id 	= cp_person_id 		AND
			ps.start_dt 	<= cp_effective_dt 	AND
			(ps.end_dt 	IS NULL			OR
			ps.end_dt	>= cp_effective_dt)
		ORDER BY	ps.end_dt;
	CURSOR c_gsc2 (
			cp_person_id		IGS_ST_GVT_SPSHT_CHG.person_id%TYPE,
			cp_course_cd		IGS_ST_GVT_SPSHT_CHG.course_cd%TYPE,
			cp_crv_version_number	IGS_ST_GVT_SPSHT_CHG.version_number%TYPE,
			cp_old_citizenship_cd	IGS_ST_GVT_SPSHT_CHG.old_citizenship_cd%TYPE,
			cp_old_perm_resident_cd	IGS_ST_GVT_SPSHT_CHG.old_perm_resident_cd%TYPE,
			cp_old_prior_degree	IGS_ST_GVT_SPSHT_CHG.old_prior_degree%TYPE,
			cp_old_prior_post_grad	IGS_ST_GVT_SPSHT_CHG.old_prior_post_grad%TYPE,
			cp_perm_resident_cd	IGS_ST_GVT_SPSHT_CHG.perm_resident_cd%TYPE,
			cp_citizenship_cd	IGS_ST_GVT_SPSHT_CHG.citizenship_cd%TYPE,
			cp_prior_degree		IGS_ST_GVT_SPSHT_CHG.prior_degree%TYPE,
			cp_prior_post_grad	IGS_ST_GVT_SPSHT_CHG.prior_post_grad%TYPE) IS
		SELECT	'x'
		FROM	IGS_ST_GVT_SPSHT_CHG 	gsc
		WHERE	gsc.submission_yr		= p_submission_yr  		AND
			gsc.submission_number 		= p_submission_number 		AND
			gsc.person_id 			= cp_person_id 			AND
			gsc.course_cd 			= cp_course_cd 			AND
			gsc.version_number 		= cp_crv_version_number		AND
			NVL(gsc.old_citizenship_cd, -1) 	= NVL(cp_old_citizenship_cd, -1)  	AND
			NVL(gsc.old_perm_resident_cd, -1) 	= NVL(cp_old_perm_resident_cd, -1)  	AND
			NVL(gsc.perm_resident_cd, -1) 	= NVL(cp_perm_resident_cd, -1) 	AND
			NVL(gsc.citizenship_cd, -1) 		= NVL(cp_citizenship_cd, -1);
	CURSOR c_ps2 (
			cp_person_id		IGS_PE_STATISTICS.person_id%TYPE,
			cp_old_perm_resident_cd	IGS_PE_STATISTICS.perm_resident_cd%TYPE,
			cp_old_citizenship_cd	IGS_PE_STATISTICS.citizenship_cd%TYPE,
			cp_old_prior_degree	IGS_PE_STATISTICS.prior_degree%TYPE) IS
		SELECT 	ps.last_updated_by,
			ps.last_update_date
		FROM	IGS_PE_STATISTICS 	ps
		WHERE	ps.person_id 		= cp_person_id			AND
			ps.end_dt 		IS NOT NULL			AND
			ps.perm_resident_cd 	= cp_old_perm_resident_cd	AND
 			ps.citizenship_cd 	= cp_old_citizenship_cd
		ORDER BY	 ps.end_dt DESC;
	CURSOR c_ps3 (
			cp_person_id	IGS_PE_STATISTICS.person_id%TYPE,
			cp_effective_dt	IGS_PE_STATISTICS.end_dt%TYPE) IS
		SELECT 	ps.last_updated_by,
			ps.last_update_date
		FROM	IGS_PE_STATISTICS	ps
		WHERE 	ps.person_id 	= cp_person_id 		AND
			ps.end_dt	IS NOT NULL		-- AND
--			ps.end_dt	> cp_effective_dt
		ORDER BY	ps.end_dt DESC;
	cst_none		CONSTANT VARCHAR2(4) := 'NONE';
	v_snapshot_dt_time		IGS_EN_ST_SPSHT_CTL.snapshot_dt_time%TYPE;
	v_person_id			IGS_ST_GVT_STDNT_LBL.person_id%TYPE;
	v_course_cd			IGS_ST_GVT_STDNT_LBL.course_cd%TYPE;
	v_govt_semester			IGS_ST_GVT_STDNT_LBL.govt_semester%TYPE;
	v_old_hecs_payment_option		IGS_ST_GVT_STDNT_LBL.hecs_payment_option%TYPE;
	v_old_differential_hecs_ind		IGS_ST_GVT_STDNT_LBL.differential_hecs_ind%TYPE;
	v_old_hecs_prexmt_exie		IGS_ST_GVT_STDNT_LBL.hecs_prexmt_exie%TYPE;
	v_old_hecs_amount_paid		IGS_ST_GVT_STDNT_LBL.hecs_amount_paid%TYPE;
	v_old_s_hecs_payment_type		IGS_FI_GOV_HEC_PA_OP.s_hecs_payment_type%TYPE;
	v_load_cal_type			IGS_ST_GVTSEMLOAD_CA.cal_type%TYPE;
	v_load_ci_sequence_number	IGS_ST_GVTSEMLOAD_CA.ci_sequence_number%TYPE;
	v_differential_hecs_ind		IGS_EN_STDNTPSHECSOP.differential_hecs_ind%TYPE;
	v_hecs_payment_option		IGS_EN_STDNTPSHECSOP.hecs_payment_option%TYPE;
	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
	v_s_hecs_payment_type		IGS_FI_GOV_HEC_PA_OP.s_hecs_payment_type%TYPE;
	v_hecs_prexmt_exie		NUMBER;
	v_fee_cat			IGS_AS_SCAH_EFFECTIVE_H_V.fee_cat%TYPE;
	v_alias_val			IGS_CA_DA_INST_V.alias_val%TYPE;
	v_message_name			VARCHAR2(30);
	v_hecs_amount_paid		NUMBER;
	v_dummy				VARCHAR2(1);
	v_unit_cd 			IGS_EN_ST_SNAPSHOT.unit_cd%TYPE;
	v_uv_version_number 		IGS_EN_ST_SNAPSHOT.uv_version_number%TYPE;
	v_sua_cal_type 			IGS_EN_ST_SNAPSHOT.sua_cal_type%TYPE;
	v_sua_ci_sequence_number 	IGS_EN_ST_SNAPSHOT.sua_ci_sequence_number%TYPE;
	v_tr_org_unit_cd 			IGS_EN_ST_SNAPSHOT.tr_org_unit_cd%TYPE;
	v_tr_ou_start_dt 			IGS_EN_ST_SNAPSHOT.tr_ou_start_dt%TYPE;
	v_eftsu 				IGS_EN_ST_SNAPSHOT.eftsu%TYPE;
	v_enrolled_dt 			IGS_EN_ST_SNAPSHOT.enrolled_dt%TYPE;
	v_discontinued_dt 			IGS_EN_ST_SNAPSHOT.discontinued_dt%TYPE;
	v_old_unit_cd			IGS_EN_ST_SNAPSHOT.unit_cd%TYPE;
	v_old_eftsu			IGS_EN_ST_SNAPSHOT.eftsu%TYPE;
	v_new_unit_cd			IGS_EN_ST_SNAPSHOT.unit_cd%TYPE;
	v_new_eftsu			IGS_EN_ST_SNAPSHOT.eftsu%TYPE;
	v_last_updated_by			IGS_EN_STDNTPSHECSOP.last_updated_by%TYPE;
	v_last_update_date			IGS_EN_STDNTPSHECSOP.last_update_date%TYPE;
	v_old_units_rows			NUMBER;
	v_new_units_rows			NUMBER;
	v_record_found			BOOLEAN DEFAULT FALSE;
	v_old_citizenship_cd		IGS_ST_GVT_STDNT_LBL.citizenship_cd%TYPE;
	v_old_perm_resident_cd		IGS_ST_GVT_STDNT_LBL.perm_resident_cd%TYPE;
	v_old_prior_degree			IGS_ST_GOVT_STDNT_EN.prior_degree%TYPE;
	v_effective_dt			DATE;
	v_char_date			VARCHAR2(10);
	v_crv_version_number		IGS_ST_GVT_STDNT_LBL.version_number%TYPE;
	v_govt_reportable_ind		VARCHAR2(1);
	v_govt_discipline_group_cd
				IGS_EN_ST_SNAPSHOT.govt_discipline_group_cd%TYPE;
	v_industrial_ind			IGS_PS_UNIT_VER.industrial_ind%TYPE;
	v_old_cntr			NUMBER;
	v_new_cntr			NUMBER;
	v_citizenship_cd			IGS_PE_STATISTICS.citizenship_cd%TYPE;
	v_perm_resident_cd		IGS_PE_STATISTICS.perm_resident_cd%TYPE;
	v_prior_degree			IGS_PE_STATISTICS.prior_degree%TYPE;
	v_prior_post_grad			IGS_ST_GOVT_STDNT_EN.prior_post_grad%TYPE;
	v_old_prior_post_grad		IGS_ST_GOVT_STDNT_EN.prior_post_grad%TYPE;
    v_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE;
      -- declaration for rowid and the sequence number variable
      v_rowid VARCHAR2(25);
      v_seqnum IGS_ST_GVT_SPSHT_CHG.sequence_number%type;
BEGIN
	--  find the most recent run of the enrolment statistics snapshot
	OPEN c_ess;
	FETCH c_ess INTO v_snapshot_dt_time;
	CLOSE c_ess;
	-- Determine the Effective Date.
	IF p_submission_number = 1 THEN
		v_char_date := TO_CHAR(p_submission_yr)||'03/31/';
	ELSE	-- Submission 2
		v_char_date := TO_CHAR(p_submission_yr)||'08/31/';
	END IF;
	v_effective_dt :=  IGS_GE_DATE.igsdate(v_char_date);
	-- select all govt_student_liability_records for previous submission
	FOR v_gsli_gslc IN c_gsli_gslc LOOP
		v_person_id := v_gsli_gslc.person_id;
		v_course_cd := v_gsli_gslc.course_cd;
		v_crv_version_number := v_gsli_gslc.version_number;
		v_govt_semester := v_gsli_gslc.govt_semester;
		v_old_hecs_payment_option := v_gsli_gslc.hecs_payment_option;
		v_old_differential_hecs_ind := v_gsli_gslc.differential_hecs_ind;
		v_old_hecs_prexmt_exie := v_gsli_gslc.hecs_prexmt_exie;
		v_old_hecs_amount_paid := v_gsli_gslc.hecs_amount_paid;
		v_load_cal_type := v_gsli_gslc.cal_type;
		v_load_ci_sequence_number := v_gsli_gslc.ci_sequence_number;
		v_old_s_hecs_payment_type :=  v_gsli_gslc.s_hecs_payment_type;
		v_old_citizenship_cd :=  v_gsli_gslc.citizenship_cd;
		v_old_perm_resident_cd :=  v_gsli_gslc.perm_resident_cd;
		-- retrieve the new HECS payment option
		OPEN c_scho_hpo_ghpo (
				v_person_id,
				v_course_cd,
				v_effective_dt);
		FETCH c_scho_hpo_ghpo INTO
					v_differential_hecs_ind,
					v_hecs_payment_option,
					v_govt_hecs_payment_option,
					v_s_hecs_payment_type;
		IF c_scho_hpo_ghpo%NOTFOUND THEN
			v_differential_hecs_ind := 'Y';
			v_hecs_payment_option := '00';
			v_govt_hecs_payment_option := NULL;
			v_s_hecs_payment_type := NULL;
		END IF;
		CLOSE c_scho_hpo_ghpo;
		-- retrieve the HECS fee
		-- Only process students that are not HECS exempt
		IF v_s_hecs_payment_type <> cst_exempt OR
		    v_old_s_hecs_payment_type <> cst_exempt THEN
			v_hecs_prexmt_exie := ROUND(IGS_FI_GEN_001.finp_get_hecs_fee(
					v_load_cal_type,
					v_load_ci_sequence_number,
					v_person_id,
					v_course_cd));
			-- Retrieve the HECS Amount Paid
			v_hecs_amount_paid := ROUND(IGS_FI_GEN_001.finp_get_hecs_amt_pd (
							v_load_cal_type,
							v_load_ci_sequence_number,
							v_person_id,
							v_course_cd));
			IF v_hecs_amount_paid <> v_old_hecs_amount_paid OR
		  	  v_hecs_prexmt_exie <> v_old_hecs_prexmt_exie OR
		  	  v_old_differential_hecs_ind <> v_differential_hecs_ind OR
			    v_old_hecs_payment_option <> v_hecs_payment_option THEN
				-- Check if the change has already been recorded.
				OPEN c_gsc1 (
						v_person_id,
						v_course_cd,
						v_crv_version_number,
						v_govt_semester,
						v_old_hecs_prexmt_exie,
						v_old_hecs_amount_paid,
						v_old_hecs_payment_option,
						v_old_differential_hecs_ind,
						v_hecs_amount_paid,
						v_hecs_prexmt_exie,
						v_hecs_payment_option,
						v_differential_hecs_ind);
				FETCH c_gsc1 INTO v_dummy;
				IF c_gsc1%NOTFOUND THEN
					CLOSE c_gsc1;
					v_unit_cd := NULL;
					v_old_unit_cd := NULL;
					v_eftsu := NULL;
					v_old_eftsu := NULL;
					-- Find the extra details we need
					IF v_old_differential_hecs_ind <> v_differential_hecs_ind OR
							v_old_hecs_payment_option <> v_hecs_payment_option THEN
						--Attempt to find when the HECS was changed
						OPEN c_scho1 (
								v_person_id,
								v_course_cd,
								v_old_hecs_payment_option,
								v_old_differential_hecs_ind);
						FETCH c_scho1 INTO v_last_updated_by,
								v_last_update_date;
						IF (c_scho1%NOTFOUND) THEN
							CLOSE c_scho1;
								OPEN c_scho2 (
										v_person_id,
										v_course_cd,
										v_effective_dt);
								FETCH c_scho2 INTO v_last_updated_by,
										v_last_update_date;
						 		CLOSE c_scho2;
						ELSE
							CLOSE c_scho1;
						END IF;	-- c_scho1%NOTFOUND
					END IF;	-- v_old_differential_hecs_ind <> v_differential_hecs_ind...
					-- Find any IGS_PS_UNIT that has changed
					-- We need to create 2 PL/SQL tables to store the old units
					-- submitted and the new units so they can be compared
					t_old_units	:= t_blank;
					t_new_units	:= t_blank;
					v_new_units_rows := 0;
					v_old_units_rows := 0;
					FOR v_gslo IN c_gslo(
							v_govt_semester,
							v_person_id,
							v_course_cd)  LOOP
						v_unit_cd := v_gslo.unit_cd;
						v_eftsu := v_gslo.eftsu;
						v_old_units_rows := v_old_units_rows + 1;
						t_old_units(v_old_units_rows).unit_cd := v_unit_cd;
						t_old_units(v_old_units_rows).sua_cal_type := v_gslo.sua_cal_type;
						t_old_units(v_old_units_rows).sua_ci_sequence_number :=
										 v_gslo.sua_ci_sequence_number;
						t_old_units(v_old_units_rows).tr_org_unit_cd := v_gslo.tr_org_unit_cd;
						t_old_units(v_old_units_rows).tr_ou_start_dt := v_gslo.tr_ou_start_dt;
						t_old_units(v_old_units_rows).govt_discipline_group_cd :=
											v_gslo.govt_discipline_group_cd;
						t_old_units(v_old_units_rows).eftsu := v_eftsu;
						t_old_units(v_old_units_rows).industrial_ind := v_gslo.industrial_ind;
                        t_old_units(v_old_units_rows).uoo_id := v_gslo.uoo_id;
					END LOOP;
					-- now find the new units
					FOR v_ess_uv_gslc IN c_ess_uv_gslc (
							v_snapshot_dt_time,
							v_govt_semester,
							v_person_id,
							v_course_cd) LOOP
						v_unit_cd := v_ess_uv_gslc.unit_cd;
						v_sua_cal_type := v_ess_uv_gslc.sua_cal_type;
						v_sua_ci_sequence_number := v_ess_uv_gslc.sua_ci_sequence_number;
						v_tr_org_unit_cd := v_ess_uv_gslc.tr_org_unit_cd;
						v_tr_ou_start_dt := v_ess_uv_gslc.tr_ou_start_dt;
						v_govt_discipline_group_cd := v_ess_uv_gslc.govt_discipline_group_cd;
						v_eftsu	:= v_ess_uv_gslc.eftsu;
						v_industrial_ind := v_ess_uv_gslc.industrial_ind;
						v_crv_version_number := v_ess_uv_gslc.crv_version_number;
						v_uv_version_number := 	v_ess_uv_gslc.uv_version_number;
						v_enrolled_dt := v_ess_uv_gslc.enrolled_dt;
						v_discontinued_dt := v_ess_uv_gslc.discontinued_dt;
						v_load_cal_type	:= v_ess_uv_gslc.ci_cal_type;
						v_load_ci_sequence_number := v_ess_uv_gslc.ci_sequence_number;
                        v_uoo_id := v_ess_uv_gslc.uoo_id;
						OPEN c_daiv_sgcc(
								v_sua_cal_type,
								v_sua_ci_sequence_number);
						FETCH c_daiv_sgcc INTO v_alias_val;
						CLOSE c_daiv_sgcc;
						-- check if IGS_PS_UNIT is reportable
						v_govt_reportable_ind := IGS_ST_GEN_003.stap_get_rptbl_sbmsn (
								p_submission_yr,
								p_submission_number,
								v_person_id,
								v_course_cd,
								v_crv_version_number,
								v_unit_cd,
								v_uv_version_number,
								v_sua_cal_type,
								v_sua_ci_sequence_number,
								v_tr_org_unit_cd,
								v_tr_ou_start_dt,
								v_eftsu,
								v_enrolled_dt,
								v_discontinued_dt,
								v_govt_semester,
								v_alias_val,
								v_load_cal_type,
								v_load_ci_sequence_number,
                                v_uoo_id);
							IF v_govt_reportable_ind <> 'N' THEN
								v_new_units_rows := v_new_units_rows + 1;
							t_new_units(v_new_units_rows).unit_cd := v_unit_cd;
							t_new_units(v_new_units_rows).sua_cal_type := v_sua_cal_type;
							t_new_units(v_new_units_rows).sua_ci_sequence_number :=
												 v_sua_ci_sequence_number;
							t_new_units(v_new_units_rows).tr_org_unit_cd := v_tr_org_unit_cd;
							t_new_units(v_new_units_rows).tr_ou_start_dt := v_tr_ou_start_dt;
							t_new_units(v_new_units_rows).govt_discipline_group_cd :=
												 v_govt_discipline_group_cd;
							t_new_units(v_new_units_rows).eftsu := v_eftsu;
							t_new_units(v_new_units_rows).industrial_ind := v_industrial_ind;
                            t_new_units(v_new_units_rows).uoo_id := v_uoo_id;
						END IF;
					END LOOP; -- v_ess_uv_gslc
					-- now we need to compare the two tables t_old_units
					-- and t_new_units to see if there are differences
					-- loop through t_old units
					v_old_cntr := 1;
					WHILE v_old_cntr <= v_old_units_rows LOOP
						v_record_found := FALSE;
						-- loop through t_new units
						v_new_cntr := 1;
						WHILE v_new_cntr <= v_new_units_rows LOOP
							IF (t_old_units(v_old_cntr).unit_cd
									= t_new_units(v_new_cntr).unit_cd AND
								t_old_units(v_old_cntr).sua_cal_type
									= t_new_units(v_new_cntr).sua_cal_type AND
								t_old_units(v_old_cntr).sua_ci_sequence_number
									= t_new_units(v_new_cntr).sua_ci_sequence_number AND
								t_old_units(v_old_cntr).tr_org_unit_cd
									= t_new_units(v_new_cntr).tr_org_unit_cd AND
								t_old_units(v_old_cntr).tr_ou_start_dt
									= t_new_units(v_new_cntr).tr_ou_start_dt AND
								t_old_units(v_old_cntr).govt_discipline_group_cd
									= t_new_units(v_new_cntr).govt_discipline_group_cd AND
								t_old_units(v_old_cntr).eftsu
									= t_new_units(v_new_cntr).eftsu AND
								t_old_units(v_old_cntr).industrial_ind
									= t_new_units(v_new_cntr).industrial_ind AND
                                t_old_units(v_old_cntr).uoo_id
                                    = t_new_units(v_new_cntr).uoo_id) THEN
								v_record_found := TRUE;
									exit;
							END IF;
							v_new_cntr := v_new_cntr + 1;
						END LOOP;
						IF v_record_found = FALSE THEN
							v_old_unit_cd := t_old_units(v_old_cntr).unit_cd;
							v_old_eftsu := t_old_units(v_old_cntr).eftsu;
								OPEN c_suah1(
									v_person_id,
									v_course_cd,
									t_old_units(v_old_cntr).uoo_id);
							FETCH c_suah1 INTO v_last_updated_by,
									v_last_update_date;
								IF c_suah1%NOTFOUND THEN
									CLOSE c_suah1;
								OPEN c_suah2(
										v_person_id,
										v_course_cd,
										t_old_units(v_old_cntr).uoo_id);
								FETCH c_suah2 INTO v_last_updated_by,
										v_last_update_date;
								CLOSE c_suah2;
							ELSE
								CLOSE c_suah1;
							END IF;
								exit;
						END IF;	-- v_record_found = FALSE
						v_old_cntr := v_old_cntr +1;
					END LOOP; -- WHILE v_old_cntr <= old_units_rows
					-- we need to compare the two tables t_old_units
					-- and t_new_units to see if there are differences in
					-- reverse to last time
					-- loop through t_new units
					v_new_cntr := 1;
					WHILE v_new_cntr <= v_new_units_rows LOOP
						v_record_found := FALSE;
						-- loop through t_old _units
						v_old_cntr := 1;
						WHILE v_old_cntr <= v_old_units_rows LOOP
							IF (t_new_units(v_new_cntr).unit_cd
									= t_old_units(v_old_cntr).unit_cd AND
								t_new_units(v_new_cntr).sua_cal_type
									= t_old_units(v_old_cntr).sua_cal_type AND
								t_new_units(v_new_cntr).sua_ci_sequence_number
									= t_old_units(v_old_cntr).sua_ci_sequence_number AND
								t_new_units(v_new_cntr).tr_org_unit_cd
									= t_old_units(v_old_cntr).tr_org_unit_cd AND
								t_new_units(v_new_cntr).tr_ou_start_dt
									= t_old_units(v_old_cntr).tr_ou_start_dt AND
								t_new_units(v_new_cntr).govt_discipline_group_cd
									= t_old_units(v_old_cntr).govt_discipline_group_cd AND
								t_new_units(v_new_cntr).eftsu
									= t_old_units(v_old_cntr).eftsu AND
								t_new_units(v_new_cntr).industrial_ind
									= t_old_units(v_old_cntr).industrial_ind AND
                                t_new_units(v_new_cntr).uoo_id
                                    = t_old_units(v_old_cntr).uoo_id) THEN
								v_record_found := TRUE;
								   exit; -- WHILE v_old_cntr <= old_units_rows LOOP
							END IF;
							v_old_cntr := v_old_cntr + 1;
						END LOOP;
						IF v_record_found = FALSE THEN
							v_new_unit_cd := t_new_units(v_new_cntr).unit_cd;
							v_new_eftsu := t_new_units(v_new_cntr).eftsu;
								OPEN c_suah3 (
									v_person_id,
									v_course_cd,
									t_new_units(v_new_cntr).uoo_id);
							FETCH c_suah3 INTO v_last_updated_by,
									v_last_update_date;
							IF (c_suah3%NOTFOUND) THEN
								CLOSE c_suah3;
									OPEN c_sua (
										v_person_id,
										v_course_cd,
										t_new_units(v_new_cntr).uoo_id);
								FETCH c_sua INTO v_last_updated_by,
										v_last_update_date;
								CLOSE c_sua;
							ELSE
								CLOSE c_suah3;
							END IF;
							  exit; -- WHILE v_new_cntr <= new_units_rows LOOP
						END IF; -- v_record_found = FALSE
						v_new_cntr := v_new_cntr + 1;
					END LOOP; -- WHILE v_new_cntr <= new_units_rows
					-- Insert changed details in table

                              -- to insert row using the insertrow of respective TBH package

                              IGS_ST_GVT_SPSHT_CHG_PKG.INSERT_ROW(
                                    X_ROWID => v_rowid,
						X_SUBMISSION_YR => p_submission_yr,
						X_SUBMISSION_NUMBER => p_submission_number,
						X_PERSON_ID => v_person_id,
						X_COURSE_CD => v_course_cd,
						X_VERSION_NUMBER => v_crv_version_number,
						X_SEQUENCE_NUMBER => v_seqnum,
						X_CHANGED_UPDATE_WHO => v_last_updated_by,
						X_CHANGED_UPDATE_ON => v_last_update_date,
						X_GOVT_SEMESTER => v_govt_semester,
						X_UNIT_CD => v_new_unit_cd,
						X_EFTSU => v_new_eftsu,
						X_HECS_PREXMT_EXIE => v_hecs_prexmt_exie,
						X_HECS_AMOUNT_PAID => v_hecs_amount_paid,
						X_HECS_PAYMENT_OPTION => v_hecs_payment_option,
						X_DIFFERENTIAL_HECS_IND => v_differential_hecs_ind,
						X_CITIZENSHIP_CD => NULL,
						X_PERM_RESIDENT_CD => NULL,
						X_PRIOR_DEGREE => NULL,
						X_PRIOR_POST_GRAD => NULL,
						X_OLD_UNIT_CD => NULL,
						X_OLD_EFTSU => NULL,
						X_OLD_HECS_PREXMT_EXIE => v_old_hecs_prexmt_exie,
						X_OLD_HECS_AMOUNT_PAID =>  v_old_hecs_amount_paid,
						X_OLD_HECS_PAYMENT_OPTION => v_old_hecs_payment_option,
						X_OLD_DIFFERENTIAL_HECS_IND => v_old_differential_hecs_ind,
						X_OLD_CITIZENSHIP_CD => NULL,
						X_OLD_PERM_RESIDENT_CD => NULL,
						X_OLD_PRIOR_DEGREE => NULL,
						X_OLD_PRIOR_POST_GRAD => NULL,
						X_REPORTED_IND => 'N',
						X_MODE => 'R');

					-- reset the changed update who and on fields
					v_last_updated_by := NULL;
					v_last_update_date := NULL;
					v_new_unit_cd := NULL;
					v_new_eftsu := NULL;
					v_old_unit_cd := NULL;
					v_old_eftsu := NULL;
				ELSE
					CLOSE c_gsc1;
				END IF; --c_gsc1%NOTFOUND
			END IF; -- v_hecs_amount_paid <> v_old_hecs_amount_paid...
			/**********************************************************************/
			/* IGS_GE_NOTE: It has been decided that the check for prior degree and
			  prior post grad is no longer useful.  The relevant code has been commented
			  out NOCOPY so that if they change their mind again it can be put back easily */
			-- Find changes to IGS_PE_PERSON statistics
			/*
			OPEN c_gse(	v_person_id,
					v_course_cd);
			FETCH c_gse INTO	 v_person_id,
					 v_course_cd,
					 v_crv_version_number,
					v_old_citizenship_cd,
					v_old_perm_resident_cd,
					v_old_prior_degree,
					v_old_prior_post_grad;
			CLOSE c_gse;*/
			/**********************************************************************/
			v_old_prior_degree := NULL;
			v_old_prior_post_grad := NULL;
 			OPEN c_ps (
					v_person_id,
					v_effective_dt);
			FETCH c_ps INTO v_citizenship_cd,
					v_perm_resident_cd,
					v_prior_degree,
					v_prior_post_grad;
			IF c_ps%NOTFOUND THEN
				 v_citizenship_cd := '9';
				v_perm_resident_cd := '9';
			END IF;
			IF  v_citizenship_cd NOT IN (2, 3, 9) THEN
				v_perm_resident_cd := '0';
			END IF;
			CLOSE c_ps;
			/**********************************************************************/
			/* IGS_GE_NOTE: It has been decided that the check for prior degree and
			  prior post grad is no longer useful.  The relevant code has been commented
			  out NOCOPY so that if they change their mind again it can be put back easily */
			/* IF v_old_citizenship_cd <> v_citizenship_cd OR
					v_old_perm_resident_cd <> v_perm_resident_cd OR
					v_old_prior_degree <> v_prior_degree OR
					v_old_prior_post_grad <> v_prior_post_grad THEN  */
			/***********************************************************************/
			IF v_old_citizenship_cd <> v_citizenship_cd OR
			    v_old_perm_resident_cd <> v_perm_resident_cd THEN
				--Check if the change has already been recorded.
				OPEN c_gsc2 (
						v_person_id,
						v_course_cd,
						v_crv_version_number,
						v_old_citizenship_cd,
						v_old_perm_resident_cd,
						v_old_prior_degree,
						v_old_prior_post_grad,
						v_perm_resident_cd,
						v_citizenship_cd,
						v_prior_degree,
						v_prior_post_grad);
				FETCH c_gsc2 INTO v_dummy;
				IF c_gsc2%NOTFOUND THEN
					CLOSE c_gsc2;
					-- Find the extra details we need
					-- Attempt to find when it was changed
					OPEN c_ps2(
							v_person_id,
							v_old_perm_resident_cd,
							v_old_citizenship_cd,
							v_old_prior_degree);
					FETCH c_ps2 INTO v_last_updated_by,
							v_last_update_date;
					IF (c_ps2%NOTFOUND) THEN
						CLOSE c_ps2;
						OPEN c_ps3 (
								v_person_id,
								v_effective_dt);
						FETCH c_ps3 INTO v_last_updated_by,
								v_last_update_date;
						CLOSE c_ps3;
					ELSE
						CLOSE c_ps2;
					END IF;
					-- Insert changed details in table

                              -- to insert row using the insertrow of respective TBH package

                              IGS_ST_GVT_SPSHT_CHG_PKG.INSERT_ROW(
                                    X_ROWID => v_rowid,
						X_SUBMISSION_YR => p_submission_yr,
						X_SUBMISSION_NUMBER => p_submission_number,
						X_PERSON_ID => v_person_id,
						X_COURSE_CD => v_course_cd,
						X_SEQUENCE_NUMBER => v_seqnum,
						X_VERSION_NUMBER => v_crv_version_number,
						X_CHANGED_UPDATE_WHO => v_last_updated_by,
						X_CHANGED_UPDATE_ON => v_last_update_date,
						X_GOVT_SEMESTER => NULL,
						X_UNIT_CD => NULL,
						X_EFTSU => NULL,
						X_HECS_PREXMT_EXIE => NULL,
						X_HECS_AMOUNT_PAID => NULL,
						X_HECS_PAYMENT_OPTION => NULL,
						X_DIFFERENTIAL_HECS_IND => NULL,
						X_CITIZENSHIP_CD => v_citizenship_cd,
						X_PERM_RESIDENT_CD => v_perm_resident_cd,
						X_PRIOR_DEGREE => NULL,
						X_PRIOR_POST_GRAD => NULL,
						X_OLD_UNIT_CD => NULL,
						X_OLD_EFTSU => NULL,
						X_OLD_HECS_PREXMT_EXIE => NULL,
						X_OLD_HECS_AMOUNT_PAID => NULL,
						X_OLD_HECS_PAYMENT_OPTION => NULL,
						X_OLD_DIFFERENTIAL_HECS_IND => NULL,
						X_OLD_CITIZENSHIP_CD => v_old_citizenship_cd,
						X_OLD_PERM_RESIDENT_CD =>  v_old_perm_resident_cd,
						X_OLD_PRIOR_DEGREE =>   NULL,
						X_OLD_PRIOR_POST_GRAD => NULL,
						X_REPORTED_IND => 'N',
						X_MODE => 'R');

					-- reset the changed update who and on fields
					v_last_updated_by := NULL;
					v_last_update_date := NULL;
				ELSE
					CLOSE c_gsc2;
				END IF; -- c_gsc2%NOTFOUND
			END IF; -- v_old_citizenship_cd <> v_citizenship_cd...
		END IF; -- v_s_hecs_payment_type <> cst_exempt OR ...
	END LOOP;  -- v_gsli_gslc IN c_gsli_gslc LOOP
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_ess%ISOPEN) THEN
			CLOSE c_ess;
		END IF;
		IF (c_gsli_gslc%ISOPEN) THEN
			CLOSE c_gsli_gslc;
		END IF;
		IF (c_scho_hpo_ghpo%ISOPEN) THEN
			CLOSE c_scho_hpo_ghpo;
		END IF;
		IF (c_daiv_sgcc%ISOPEN) THEN
			CLOSE c_daiv_sgcc;
		END IF;
		IF (c_gsc1%ISOPEN) THEN
			CLOSE c_gsc1;
		END IF;
		IF (c_scho1%ISOPEN) THEN
			CLOSE c_scho1;
		END IF;
		IF (c_scho2%ISOPEN) THEN
			CLOSE c_scho2;
		END IF;
		IF (c_gslo%ISOPEN) THEN
			CLOSE c_gslo;
		END IF;
		IF (c_ess_uv_gslc%ISOPEN) THEN
			CLOSE c_ess_uv_gslc;
		END IF;
		IF (c_suah1%ISOPEN) THEN
			CLOSE c_suah1;
		END IF;
		IF (c_suah2%ISOPEN) THEN
			CLOSE c_suah2;
		END IF;
		IF (c_suah3%ISOPEN) THEN
			CLOSE c_suah3;
		END IF;
		IF (c_sua%ISOPEN) THEN
			CLOSE c_sua;
		END IF;
		IF (c_gse%ISOPEN) THEN
			CLOSE c_gse;
		END IF;
		IF (c_ps%ISOPEN) THEN
			CLOSE c_ps;
		END IF;
		IF (c_gsc2%ISOPEN) THEN
			CLOSE c_gsc2;
		END IF;
		IF (c_ps2%ISOPEN) THEN
			CLOSE c_ps2;
		END IF;
		IF (c_ps3%ISOPEN) THEN
			CLOSE c_ps3;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stap_ins_gsch');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END stap_ins_gsch;


Procedure Stas_Ins_Govt_Snpsht(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_ess_snapshot_dt_time IN DATE ,
  p_use_most_recent_ess_ind IN VARCHAR2 DEFAULT 'N',
  p_log_creation_dt OUT NOCOPY DATE )
AS
	gv_other_detail		VARCHAR2(255);
	gv_message_name		VARCHAR2(30);
BEGIN	-- stas_ins_govt_snpsht
	-- This routine is a stored database procedure that calls the stored database
	-- function STAP_INS_GOVT_SNPSHT. This routine is needed because Job Schedular
	-- can only call stored database procedures, not functions. If the called
	-- function returns false, this routine will log an entry in the system log
	-- and an error in the system error log.
DECLARE
	cst_s_log_type		CONSTANT IGS_GE_S_LOG.s_log_type%TYPE := 'GOVT-SBMSN';
	v_creation_dt		IGS_GE_S_LOG.creation_dt%TYPE;
	v_log_creation_dt	IGS_GE_S_LOG.creation_dt%TYPE;
BEGIN
	v_creation_dt := SYSDATE;
	IF (stap_ins_govt_snpsht(
			p_submission_yr,
			p_submission_number,
			p_ess_snapshot_dt_time,
			p_use_most_recent_ess_ind,
			gv_message_name,
			v_log_creation_dt) = FALSE) THEN
		ROLLBACK;
		p_log_creation_dt := v_log_creation_dt;
		-- Output the exception to the job run log.
	Fnd_Message.Set_Name('IGS',gv_message_name);
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
	END IF;
	p_log_creation_dt := v_log_creation_dt;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_004.stas_ins_govt_snpsht');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END stas_ins_govt_snpsht;

END IGS_ST_GEN_004;

/
