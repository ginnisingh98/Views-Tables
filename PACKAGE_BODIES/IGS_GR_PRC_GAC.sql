--------------------------------------------------------
--  DDL for Package Body IGS_GR_PRC_GAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_PRC_GAC" AS
/* $Header: IGSGR01B.pls 120.2 2006/02/21 00:56:30 sepalani noship $ */
  --
  -- Create graduand award ceremony records for graduands
  FUNCTION grdp_ins_gac(
  p_person_id IN NUMBER ,
  p_create_dt IN DATE ,
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_name_pronunciation IN VARCHAR2 ,
  p_name_announced IN VARCHAR2 ,
  p_academic_dress_rqrd_ind IN VARCHAR2 DEFAULT 'N',
  p_academic_gown_size IN VARCHAR2 ,
  p_academic_hat_size IN VARCHAR2 ,
  p_guest_tickets_requested IN NUMBER ,
  p_guest_tickets_allocated IN NUMBER ,
  p_guest_seats IN VARCHAR2 ,
  p_fees_paid_ind IN VARCHAR2 DEFAULT 'N',
  p_special_requirements IN VARCHAR2 ,
  p_resolve_stalemate_type IN VARCHAR2 ,
  p_ignore_unit_sets_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  	gv_t_awc_cntr		NUMBER DEFAULT 0;
  	gv_t_acusg_cntr		NUMBER DEFAULT 0;
  BEGIN	-- grdp_ins_gac
  	-- This process performs allocation of graduands to the appropriate ceremony
  	-- for their course award and unit set(s) depending on the campus location of
  	-- their student_course_attempt record.  The process ultimately creates
  	-- graduand_award_ceremony records
		--
		--  Change History :
		--  Who             When            What
		--  (reverse chronological order - newest change first)
		--
		--  Nalin Kumar   18-DEC-2002    Modified grdpl_ins_gac_record procedure to fix Bug# 2690151.
		--                               Added the code to log message when the Graduand ceremony record is created.
		--
  DECLARE
  	-- table to hold acusg records which have matching acus and susa unit sets
  	TYPE r_acusg_match_typ IS RECORD(
  		grd_cal_type			IGS_GR_AWD_CRM_US_GP.grd_cal_type%TYPE,
  		grd_ci_sequence_number
  						IGS_GR_AWD_CRM_US_GP.grd_ci_sequence_number%TYPE,
  		ceremony_number			IGS_GR_AWD_CRM_US_GP.ceremony_number%TYPE,
  		award_course_cd			IGS_GR_AWD_CRM_US_GP.award_course_cd%TYPE,
  		award_crs_version_number
  						IGS_GR_AWD_CRM_US_GP.award_crs_version_number%TYPE,
  		award_cd			IGS_GR_AWD_CRM_US_GP.award_cd%TYPE,
  		us_group_number			IGS_GR_AWD_CRM_US_GP.us_group_number%TYPE,
  		dflt_ind				IGS_AD_LOCATION_REL.dflt_ind%TYPE);
  	r_acusg_match			r_acusg_match_typ;
  	TYPE t_acusg_match_typ IS TABLE OF r_acusg_match%TYPE
  		INDEX BY BINARY_INTEGER;
  	t_acusg_match			t_acusg_match_typ;
  	t_acusg_match_blank		t_acusg_match_typ;
  	-- table to hold awc matching graduand award course_cd and version_num with
  	-- links through graduation ceremony - venue - location - sca location
  	TYPE r_awc_match_typ IS RECORD(
  		grd_cal_type			IGS_GR_AWD_CEREMONY.grd_cal_type%TYPE,
  		grd_ci_sequence_number		IGS_GR_AWD_CEREMONY.grd_ci_sequence_number%TYPE,
  		ceremony_number			IGS_GR_AWD_CEREMONY.ceremony_number%TYPE,
  		award_course_cd			IGS_GR_AWD_CEREMONY.award_course_cd%TYPE,
  		award_crs_version_number	IGS_GR_AWD_CEREMONY.award_crs_version_number%TYPE,
  		award_cd			IGS_GR_AWD_CEREMONY.award_cd%TYPE,
  		dflt_ind				IGS_AD_LOCATION_REL.dflt_ind%TYPE);
  	r_awc_match			r_awc_match_typ;
  	TYPE t_awc_match_typ IS TABLE OF r_awc_match%TYPE
  		INDEX BY BINARY_INTEGER;
  	t_awc_match			t_awc_match_typ;
  	t_awc_match_blank		t_awc_match_typ;
  	cst_alpha	CONSTANT	VARCHAR2(5) := 'ALPHA';
  	cst_proportion	CONSTANT	VARCHAR2(10) :='PROPORTION';
  	v_susa_count		NUMBER;
  	v_cntr			NUMBER;
  	v_row_num		NUMBER;
  	CURSOR	c_susa IS
  		SELECT	COUNT(*)
  		FROM	IGS_AS_SU_SETATMPT	susa,
  			IGS_GR_GRADUAND			gr
  		WHERE	gr.person_id 			= p_person_id			AND
  			gr.create_dt 			= p_create_dt			AND
  			gr.grd_cal_type 		= p_grd_cal_type		AND
  			gr.grd_ci_sequence_number 	= p_grd_ci_sequence_number 	AND
  			susa.person_id 			= gr.person_id			AND
  			susa.course_cd 			= gr.course_cd			AND
  			susa.primary_set_ind 		= 'Y'				AND
  			susa.student_confirmed_ind 	= 'Y'				AND
  			susa.end_dt 			IS NULL;
  	CURSOR	c_awc IS
  		SELECT	awc.grd_cal_type,
  			awc.grd_ci_sequence_number,
  			awc.ceremony_number,
  			awc.award_course_cd,
  			awc.award_crs_version_number,
  			awc.award_cd,
  			lr.dflt_ind
  		FROM	IGS_GR_GRADUAND		gr,
  			IGS_GR_AWD_CEREMONY		awc,
  			IGS_EN_STDNT_PS_ATT	sca,
  			IGS_GR_CRMN	gc,
  			IGS_GR_VENUE				ve,
  			IGS_AD_LOCATION_REL		lr,
  			IGS_CA_DA_INST_V		daiv
  		WHERE	gr.person_id 			= p_person_id			AND
  			gr.create_dt 			= p_create_dt			AND
  			gr.grd_cal_type 		= p_grd_cal_type		AND
  			gr.grd_ci_sequence_number 	= p_grd_ci_sequence_number	AND
  			sca.person_id 			= gr.person_id			AND
  			sca.course_cd 			= gr.course_cd			AND
  			sca.location_cd 		= lr.location_cd		AND
  			gc.grd_cal_type 		= gr.grd_cal_type		AND
  			gc.grd_ci_sequence_number 	= gr.grd_ci_sequence_number	AND
  			gc.venue_cd 			= ve.venue_cd 			AND
  			ve.exam_location_cd 		= lr.sub_location_cd		AND
  			gc.closing_dt_alias = daiv.dt_alias			AND
  			gc.closing_dai_sequence_number = daiv.sequence_number	AND
  			gc.grd_cal_type = daiv.cal_type			AND
  			gc.grd_ci_sequence_number = daiv.ci_sequence_number	AND
  			TRUNC(SYSDATE) < TRUNC(daiv.alias_val)		AND
  			awc.grd_cal_type 		= gc.grd_cal_type		AND
  			awc.grd_ci_sequence_number 	= gc.grd_ci_sequence_number	AND
  			awc.ceremony_number 		= gc.ceremony_number		AND
  			awc.award_course_cd 		= gr.award_course_cd		AND
  			awc.award_crs_version_number 	= gr.award_crs_version_number	AND
  			awc.award_cd 			= gr.award_cd			AND
  			awc.closed_ind 			= 'N'
  		ORDER BY	awc.grd_cal_type,
  				awc.grd_ci_sequence_number,
  				awc.ceremony_number,
  				awc.award_course_cd,
  				awc.award_crs_version_number,
  				awc.award_cd;
  	CURSOR	c_acusg (
  		cp_grd_cal_type			IGS_GR_AWD_CEREMONY.grd_cal_type%TYPE,
  		cp_grd_ci_sequence_number	IGS_GR_AWD_CEREMONY.grd_ci_sequence_number%TYPE,
  		cp_ceremony_number		IGS_GR_AWD_CEREMONY.ceremony_number%TYPE,
  		cp_award_course_cd		IGS_GR_AWD_CEREMONY.award_course_cd%TYPE,
  		cp_award_crs_version_number	IGS_GR_AWD_CEREMONY.award_crs_version_number%TYPE,
  		cp_award_cd			IGS_GR_AWD_CEREMONY.award_cd%TYPE) IS
  		SELECT	acusg.grd_cal_type,
  			acusg.grd_ci_sequence_number,
  			acusg.ceremony_number,
  			acusg.award_course_cd,
  			acusg.award_crs_version_number,
  			acusg.award_cd,
  			acusg.us_group_number
  		FROM	IGS_GR_AWD_CRM_US_GP		acusg
  		WHERE	acusg.grd_cal_type 		= cp_grd_cal_type		AND
  			acusg.grd_ci_sequence_number 	= cp_grd_ci_sequence_number	AND
  			acusg.ceremony_number 		= cp_ceremony_number		AND
  			acusg.award_course_cd 		= cp_award_course_cd		AND
  			acusg.award_crs_version_number 	= cp_award_crs_version_number	AND
  			acusg.award_cd 			= cp_award_cd			AND
  			acusg.closed_ind = 'N'						AND
  		NOT EXISTS
  			(SELECT	susa.unit_set_cd,
  				susa.us_version_number
  			FROM	IGS_AS_SU_SETATMPT	susa,
  				IGS_GR_GRADUAND			gr
  			WHERE	gr.person_id 			= p_person_id			AND
  				gr.create_dt 			= p_create_dt			AND
  				gr.grd_cal_type 		= p_grd_cal_type		AND
  				gr.grd_ci_sequence_number 	= p_grd_ci_sequence_number 	AND
  				susa.person_id 			= gr.person_id			AND
  				susa.course_cd 			= gr.course_cd			AND
  				susa.primary_set_ind 		= 'Y'				AND
  				susa.student_confirmed_ind 	= 'Y'				AND
  				susa.end_dt 			IS NULL
  			MINUS
  			SELECT	acus.unit_set_cd,
  				acus.us_version_number
  			FROM	IGS_GR_AWD_CRM_UT_ST	acus
  			WHERE	acus.grd_cal_type 		= acusg.grd_cal_type 			AND
  				acus.grd_ci_sequence_number	= acusg.grd_ci_sequence_number 		AND
  				acus.ceremony_number 		= acusg.ceremony_number 		AND
  				acus.award_course_cd 		= acusg.award_course_cd 		AND
  				acus.award_crs_version_number 	= acusg.award_crs_version_number 	AND
  				acus.award_cd 			= acusg.award_cd 			AND
  				acus.us_group_number 		= acusg.us_group_number) 		AND
  		NOT EXISTS
  			(SELECT	acus.unit_set_cd,
  				acus.us_version_number
  			FROM	IGS_GR_AWD_CRM_UT_ST	acus
  			WHERE	acus.grd_cal_type 		= acusg.grd_cal_type 			AND
  				acus.grd_ci_sequence_number 	= acusg.grd_ci_sequence_number 		AND
  				acus.ceremony_number 		= acusg.ceremony_number 		AND
  				acus.award_course_cd 		= acusg.award_course_cd 		AND
  				acus.award_crs_version_number 	= acusg.award_crs_version_number 	AND
  				acus.award_cd 			= acusg.award_cd 			AND
  				acus.us_group_number 		= acusg.us_group_number
  			MINUS
  			SELECT	susa.unit_set_cd,
  				susa.us_version_number
  			FROM	IGS_AS_SU_SETATMPT	susa,
  				IGS_GR_GRADUAND			gr
  			WHERE	gr.person_id 			= p_person_id			AND
  				gr.create_dt 			= p_create_dt 			AND
  				gr.grd_cal_type 		= p_grd_cal_type 		AND
  				gr.grd_ci_sequence_number 	= p_grd_ci_sequence_number 	AND
  				susa.person_id 			= gr.person_id 			AND
  				susa.course_cd 			= gr.course_cd 			AND
  				susa.primary_set_ind 		= 'Y'				AND
  				susa.student_confirmed_ind 	= 'Y'				AND
  				susa.end_dt 			IS NULL)
  		ORDER BY	acusg.grd_cal_type,
  				acusg.grd_ci_sequence_number,
  				acusg.ceremony_number,
  				acusg.award_course_cd,
  				acusg.award_crs_version_number,
  				acusg.award_cd,
  				acusg.us_group_number;
  	PROCEDURE grdpl_rslv_stlmt_default (
  			p_row_num OUT NOCOPY NUMBER)
  	AS
  		-- 8A. Internal procedure to resolve ceremony stalemates by using
  		-- the ceremony at the default graduation location for the students
  		-- campus location if one exists.
  	BEGIN
  	DECLARE
  		v_row_num	NUMBER;
  		v_row_num_new	NUMBER;
  		v_dflt_count	NUMBER;
  	BEGIN
  		p_row_num := 0;
  		v_dflt_count := 0;
  		FOR v_row_num IN 1.. gv_t_acusg_cntr LOOP
  			IF t_acusg_match(v_row_num).dflt_ind = 'Y' THEN
  				p_row_num := v_row_num;
  				v_dflt_count := v_dflt_count + 1;
  			END IF;
  		END LOOP;
  		IF v_dflt_count > 1 THEN
  			p_row_num := 0;
  			v_row_num_new := 0;
  			-- Remove the non-default location ceremonies from the set
  			FOR v_row_num IN 1.. gv_t_acusg_cntr LOOP
  				IF t_acusg_match(v_row_num).dflt_ind = 'Y' THEN
  					v_row_num_new := v_row_num_new + 1;
  					t_acusg_match(v_row_num_new) := t_acusg_match(v_row_num);
  				END IF;
  			END LOOP;
  			gv_t_acusg_cntr := v_row_num_new;
  		END IF;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
	       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	       		IGS_GE_MSG_STACK.ADD;
       			App_Exception.Raise_Exception;
  	END grdpl_rslv_stlmt_default;
  	PROCEDURE grdpl_rslv_stlmt_alpha (
  	 	p_row_number OUT NOCOPY NUMBER)
  	AS
  	BEGIN
  		--Internal procedure to resolve ceremony stalemates by splitting the
  		-- ceremonies alphabetically.  It passes back the row number for the
  		-- appropriate record in the t_acusg_match PL/SQL table.
  	DECLARE
  		v_letter_number		NUMBER;
  		CURSOR	c_pe IS
  			SELECT	(ASCII(UPPER(pe.last_name)) - 65)
  			FROM	IGS_PE_PERSON_BASE_V pe
  			WHERE	pe.person_id = p_person_id;
  	BEGIN
  		OPEN 	c_pe;
  		FETCH	c_pe INTO v_letter_number;
  		CLOSE 	c_pe;
  		p_row_number := FLOOR(v_letter_number / (26 / gv_t_acusg_cntr)) + 1;
  	EXCEPTION
  		WHEN OTHERS THEN
  			IF c_pe%ISOPEN THEN
  				CLOSE c_pe;
  			END IF;
  			RAISE;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
	       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	       		IGS_GE_MSG_STACK.ADD;
       			App_Exception.Raise_Exception;
  	END grdpl_rslv_stlmt_alpha;
  	PROCEDURE grdpl_rslv_stlmt_prprtn (
  			p_row_num OUT NOCOPY NUMBER)
  	AS
  		-- 8. Internal procedure to resolve ceremony stalemates by splitting the
  		-- ceremonies proportionally.  It passes back the row number for the
  		-- appropriate record in the t_acusg_match PL/SQL table.
  	BEGIN
  	DECLARE
  		v_lowest_count 	NUMBER;
  		v_row_num	NUMBER;
  		v_gac_count	NUMBER;
  		CURSOR	c_gac (
  			cp_row_num	NUMBER) IS
  			SELECT	COUNT(*)
  			FROM	IGS_GR_AWD_CRMN		gac
  			WHERE	gac.grd_cal_type 		= t_acusg_match(cp_row_num).grd_cal_type 	AND
  				gac.grd_ci_sequence_number 	=
  								t_acusg_match(cp_row_num).grd_ci_sequence_number AND
  				gac.ceremony_number 		= t_acusg_match(cp_row_num).ceremony_number 	AND
  				gac.award_course_cd 		= t_acusg_match(cp_row_num).award_course_cd 	AND
  				gac.award_crs_version_number 	=
  								t_acusg_match(cp_row_num).award_crs_version_number AND
  				gac.award_cd 			= t_acusg_match(cp_row_num).award_cd 		AND
  				NVL(gac.us_group_number, 0) 	=
  								NVL(t_acusg_match(cp_row_num).us_group_number, 0);
  	BEGIN
  		v_lowest_count := 999999;
  		FOR v_row_num IN 1.. gv_t_acusg_cntr LOOP
  			OPEN c_gac(v_row_num);
  			FETCH c_gac INTO v_gac_count;
  			CLOSE c_gac;
  			IF v_gac_count < v_lowest_count THEN
  				v_lowest_count := v_gac_count;
  				p_row_num := v_row_num;
  			END IF;
  		END LOOP;
  	EXCEPTION
  		WHEN OTHERS THEN
  			IF c_gac%ISOPEN THEN
  				CLOSE c_gac;
  			END IF;
  			RAISE;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
	       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	       		IGS_GE_MSG_STACK.ADD;
       			App_Exception.Raise_Exception;
  	END grdpl_rslv_stlmt_prprtn;
  	PROCEDURE grdpl_ins_gac_record (
  			p_row_num NUMBER)
  	AS
  	BEGIN
  		-- 9. Internal procedure to insert graduand_award_ceremony records.
  		-- It is passed the row number for the appropriate record in the
  		-- t_acusg_match PL/SQL table.
  	DECLARE
		  lv_rowid VARCHAR2(25);
		  lv_id	 NUMBER;

			-- Added the following coursor to get the Person Number. Bug# 2690151
	    CURSOR get_person_num IS
	    SELECT person_number
	    FROM igs_pe_person_base_v
	    WHERE person_id = p_person_id;
	    l_person_number igs_pe_person_base_v.person_number%TYPE := NULL;
  	BEGIN
		IGS_GR_AWD_CRMN_PKG.INSERT_ROW(
		  X_ROWID => lv_rowid,
		  X_GAC_ID => lv_id,
		  X_GRADUAND_SEAT_NUMBER => NULL,
		  X_NAME_PRONUNCIATION => p_name_pronunciation,
		  X_NAME_ANNOUNCED => p_name_announced,
		  X_ACADEMIC_DRESS_RQRD_IND => p_academic_dress_rqrd_ind,
		  X_ACADEMIC_GOWN_SIZE => p_academic_gown_size,
		  X_ACADEMIC_HAT_SIZE => p_academic_hat_size,
		  X_GUEST_TICKETS_REQUESTED => p_guest_tickets_requested,
		  X_GUEST_TICKETS_ALLOCATED => p_guest_tickets_allocated,
		  X_GUEST_SEATS => p_guest_seats,
		  X_FEES_PAID_IND => p_fees_paid_ind,
		  X_SPECIAL_REQUIREMENTS => p_special_requirements,
		  X_COMMENTS => NULL,
		  X_PERSON_ID => p_person_id,
		  X_CREATE_DT => p_create_dt,
		  X_GRD_CAL_TYPE => t_acusg_match(p_row_num).grd_cal_type,
		  X_GRD_CI_SEQUENCE_NUMBER => t_acusg_match(p_row_num).grd_ci_sequence_number,
		  X_CEREMONY_NUMBER => t_acusg_match(p_row_num).ceremony_number,
		  X_AWARD_COURSE_CD => t_acusg_match(p_row_num).award_course_cd,
		  X_AWARD_CRS_VERSION_NUMBER => t_acusg_match(p_row_num).award_crs_version_number,
		  X_AWARD_CD => t_acusg_match(p_row_num).award_cd,
		  X_US_GROUP_NUMBER => t_acusg_match(p_row_num).us_group_number,
		  X_ORDER_IN_PRESENTATION => NULL,
		  X_MODE => 'R');
  		COMMIT;
			--
			-- Added the following 'put_line' to fix bug# 2690151
			--
		  --Get the Person Number
		  OPEN get_person_num;
		  FETCH get_person_num INTO l_person_number;
		  CLOSE get_person_num;
			FND_MESSAGE.SET_NAME('IGS','IGS_GR_CRMN_REC_CRTD');
			FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
			FND_MESSAGE.SET_TOKEN('GRD_CAL',t_acusg_match(p_row_num).grd_cal_type);
			FND_MESSAGE.SET_TOKEN('CEREMONY',t_acusg_match(p_row_num).ceremony_number);
			FND_MESSAGE.SET_TOKEN('COURSE',t_acusg_match(p_row_num).award_course_cd);
			FND_MESSAGE.SET_TOKEN('AWARD',t_acusg_match(p_row_num).award_cd);
			FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
			FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
	       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	       		IGS_GE_MSG_STACK.ADD;
       			App_Exception.Raise_Exception;
  	END grdpl_ins_gac_record;
  BEGIN
  	gv_t_awc_cntr := 0;
  	gv_t_acusg_cntr := 0;
  	t_acusg_match := t_acusg_match_blank;
  	t_awc_match := t_awc_match_blank;
  	--1. Check parameters :
  	IF p_person_id IS NULL OR
     			p_create_dt IS NULL OR
     			p_grd_cal_type IS NULL OR
     			p_grd_ci_sequence_number IS NULL OR
     			p_academic_dress_rqrd_ind IS NULL OR
     			p_fees_paid_ind IS NULL OR
     			p_resolve_stalemate_type IS NULL OR
     			p_ignore_unit_sets_ind IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 2. Get the count of primary student_unit_set_attempts for the current
  	-- graduand.
  	OPEN c_susa;
  	FETCH c_susa INTO v_susa_count;
  	CLOSE c_susa;
  	-- 3. Find award_ceremony records which match the graduand award_course_cd,
  	-- award_crs_version_number and award_cd and are linked to a
  	-- graduation_ceremony at a venue linked to the location in the graduands
  	-- student_course_attempt.  Loop through the matching award_ceremony records.
  	FOR v_awc_rec IN c_awc LOOP
  		-- 4. If the graduand has any primary student_unit_set_attempt records
  		-- attempt to find an award_ceremony_us_group within the current
  		-- award_ceremony with a matching set of award_ceremony_unit_set records.
  		IF v_susa_count > 0 THEN
  			FOR v_acusg_rec IN c_acusg (
  					v_awc_rec.grd_cal_type,
  					v_awc_rec.grd_ci_sequence_number,
  					v_awc_rec.ceremony_number,
  					v_awc_rec.award_course_cd,
  					v_awc_rec.award_crs_version_number,
  					v_awc_rec.award_cd) LOOP
  				-- write record v_acusg_rec into PL/SQL table t_acusg_match
  				gv_t_acusg_cntr := gv_t_acusg_cntr + 1;
  				t_acusg_match(gv_t_acusg_cntr).grd_cal_type := v_acusg_rec.grd_cal_type;
  				t_acusg_match(gv_t_acusg_cntr).grd_ci_sequence_number :=
  							v_acusg_rec.grd_ci_sequence_number;
  				t_acusg_match(gv_t_acusg_cntr).ceremony_number :=
  							v_acusg_rec.ceremony_number;
  				t_acusg_match(gv_t_acusg_cntr).award_course_cd :=
  							v_acusg_rec.award_course_cd;
  				t_acusg_match(gv_t_acusg_cntr).award_crs_version_number :=
  							v_acusg_rec.award_crs_version_number;
  				t_acusg_match(gv_t_acusg_cntr).award_cd := v_acusg_rec.award_cd;
  				t_acusg_match(gv_t_acusg_cntr).us_group_number :=
  							v_acusg_rec.us_group_number;
  				t_acusg_match(gv_t_acusg_cntr).dflt_ind :=
  							v_awc_rec.dflt_ind;
  			END LOOP; -- c_acusg
  		END IF;
  		-- write record v_awc_rec into PL/SQL table t_awc_match
  		gv_t_awc_cntr := gv_t_awc_cntr + 1;
  		t_awc_match(gv_t_awc_cntr).grd_cal_type := v_awc_rec.grd_cal_type;
  		t_awc_match(gv_t_awc_cntr).grd_ci_sequence_number :=
  					v_awc_rec.grd_ci_sequence_number;
  		t_awc_match(gv_t_awc_cntr).ceremony_number := v_awc_rec.ceremony_number;
  		t_awc_match(gv_t_awc_cntr).award_course_cd := v_awc_rec.award_course_cd;
  		t_awc_match(gv_t_awc_cntr).award_crs_version_number :=
  					v_awc_rec.award_crs_version_number;
  		t_awc_match(gv_t_awc_cntr).award_cd := v_awc_rec.award_cd;
  		t_awc_match(gv_t_awc_cntr).dflt_ind := v_awc_rec.dflt_ind;
  	END LOOP;
  	-- 5. Place the award_ceremony records in the empty award_ceremony_us_group
  	-- PL/SQL table t_acusg_match.
  	IF(v_susa_count = 0 AND gv_t_awc_cntr > 0) OR
  	   		(v_susa_count > 0 AND
  			gv_t_acusg_cntr = 0 AND
  			p_ignore_unit_sets_ind = 'Y') THEN
  		-- Copy t_awc_match records into t_acusg_match
  		FOR v_cntr IN 1..gv_t_awc_cntr LOOP
  			gv_t_acusg_cntr := gv_t_acusg_cntr + 1;
  			t_acusg_match(gv_t_acusg_cntr).grd_cal_type :=
  						t_awc_match(v_cntr).grd_cal_type;
  			t_acusg_match(gv_t_acusg_cntr).grd_ci_sequence_number :=
  						t_awc_match(v_cntr).grd_ci_sequence_number;
  			t_acusg_match(gv_t_acusg_cntr).ceremony_number :=
  						t_awc_match(v_cntr).ceremony_number;
  			t_acusg_match(gv_t_acusg_cntr).award_course_cd :=
  						t_awc_match(v_cntr).award_course_cd;
  			t_acusg_match(gv_t_acusg_cntr).award_crs_version_number :=
  						t_awc_match(v_cntr).award_crs_version_number;
  			t_acusg_match(gv_t_acusg_cntr).award_cd := t_awc_match(v_cntr).award_cd;
  			t_acusg_match(gv_t_acusg_cntr).us_group_number := NULL;
  			t_acusg_match(gv_t_acusg_cntr).dflt_ind := t_awc_match(v_cntr).dflt_ind;
  		END LOOP;
  	END IF;
  	-- 6. If there is only one matching ceremony insert the record there.
  	-- If there is more than one matching ceremony call a function to resolve
  	-- the stalemate.
  	IF gv_t_acusg_cntr = 1 THEN
  		grdpl_ins_gac_record(gv_t_acusg_cntr);
  	ELSE
  		IF gv_t_acusg_cntr > 1 THEN
  			grdpl_rslv_stlmt_default(v_row_num);
  			IF v_row_num > 0 THEN
  				grdpl_ins_gac_record(v_row_num);
  			ELSE
  				IF p_resolve_stalemate_type = cst_alpha THEN
  					grdpl_rslv_stlmt_alpha(v_row_num);
  					grdpl_ins_gac_record(v_row_num);
  				ELSE
  					IF p_resolve_stalemate_type = cst_proportion THEN
  						grdpl_rslv_stlmt_prprtn(v_row_num);
  						grdpl_ins_gac_record(v_row_num);
  					END IF;
  				END IF;
  			END IF;
  		END IF;
  	END IF;
   	-- Return no error:
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_susa%ISOPEN) THEN
  			CLOSE c_susa;
  		END IF;
  		IF (c_awc%ISOPEN) THEN
  			CLOSE c_awc;
  		END IF;
  		IF (c_acusg%ISOPEN) THEN
  			CLOSE c_acusg;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_ins_gac;
  --
  -- Process the close of a Award Ceremony Unit Set Group
  FUNCTION grdp_prc_acusg_close(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_us_group_number IN NUMBER ,
  p_resolve_stalemate_type IN VARCHAR2 ,
  p_ignore_unit_sets_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- grdp_prc_acusg_close
  	-- Description: This process is passed the details of a award_ceremony_us_group
  	-- record which is closed.  It finds any associated graduand_award_ceremony
  	-- records
  DECLARE
  	v_loop_flag				BOOLEAN := FALSE;
  	e_resource_busy_exception		EXCEPTION;
  	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
  	CURSOR	c_gac IS
  		SELECT	gac.person_id,
  			gac.create_dt,
  			gac.name_pronunciation,
  			gac.name_announced,
  			gac.academic_dress_rqrd_ind,
  			gac.academic_gown_size,
  			gac.academic_hat_size,
  			gac.guest_tickets_requested,
  			gac.guest_tickets_allocated,
  			gac.guest_seats,
  			gac.fees_paid_ind,
  			gac.special_requirements,
  			gac.grd_cal_type,
  			gac.grd_ci_sequence_number,
  			gac.ceremony_number,
  			gac.award_course_cd,
  			gac.award_crs_version_number,
  			gac.award_cd
  		FROM	IGS_GR_AWD_CRMN			gac
  		WHERE	gac.grd_cal_type 			= p_grd_cal_type AND
  			gac.grd_ci_sequence_number 		= p_grd_ci_sequence_number AND
  			gac.ceremony_number 			= p_ceremony_number AND
  			NVL(gac.award_course_cd,'NULL')
  						= NVL(p_award_course_cd,'NULL') AND
  			NVL(gac.award_crs_version_number,0)
  						= NVL(p_award_crs_version_number,0) AND
  			gac.award_cd 				= p_award_cd AND
  			gac.us_group_number 			= p_us_group_number;
  	CURSOR	c_gac_del (
  			cp_person_id			IGS_GR_AWD_CRMN.person_id%TYPE,
  			cp_create_dt			IGS_GR_AWD_CRMN.create_dt%TYPE,
  			cp_grd_cal_type			IGS_GR_AWD_CRMN.grd_cal_type%TYPE,
  			cp_grd_ci_sequence_number
  							IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE,
  			cp_ceremony_number		IGS_GR_AWD_CRMN.ceremony_number%TYPE,
  			cp_award_cd			IGS_GR_AWD_CRMN.award_cd%TYPE) IS
  		SELECT	rowid,gac.*
  		FROM	IGS_GR_AWD_CRMN		gac
  		WHERE	gac.person_id 			= cp_person_id AND
  			gac.create_dt			= cp_create_dt AND
  			gac.grd_cal_type		= cp_grd_cal_type AND
  			gac.grd_ci_sequence_number	= cp_grd_ci_sequence_number AND
  			gac.award_cd			= cp_award_cd
  		FOR UPDATE OF gac.person_id NOWAIT;
  		v_gac_del		c_gac_del%ROWTYPE;
  	CURSOR	c_gach(
  			cp_gac_person_id			IGS_GR_AWD_CRMN.person_id%TYPE,
  			cp_gac_create_dt			IGS_GR_AWD_CRMN.create_dt%TYPE,
  			cp_grd_cal_type			IGS_GR_AWD_CRMN.grd_cal_type%TYPE,
  			cp_grd_ci_sequence_number
  							IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE,
  			cp_ceremony_number		IGS_GR_AWD_CRMN.ceremony_number%TYPE,
  			cp_award_cd			IGS_GR_AWD_CRMN.award_cd%TYPE) IS
  		SELECT	rowid, gach.person_id
  		FROM	IGS_GR_AWD_CRMN_HIST	gach
  		WHERE	gach.person_id 			= cp_gac_person_id AND
  			gach.create_dt			= cp_gac_create_dt AND
  			gach.grd_cal_type		= cp_grd_cal_type AND
  			gach.grd_ci_sequence_number	= cp_grd_ci_sequence_number AND
  			gach.ceremony_number 		= cp_ceremony_number AND
  			gach.award_cd			= cp_award_cd
  		FOR UPDATE OF gach.person_id NOWAIT;
  BEGIN
  	p_message_name := NULL;
  	-- 1.Check parameters
  	IF p_grd_cal_type IS NULL OR
    			p_grd_ci_sequence_number IS NULL OR
     			p_ceremony_number IS NULL OR
     			p_award_cd IS NULL OR
     			p_us_group_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- 2.Find any associated graduand_award_ceremony records for
  	-- this award_ceremony_us_group and loop through them.
  	FOR v_gac_rec IN c_gac LOOP
  		SAVEPOINT sp_gac_del;
  		BEGIN
  		OPEN c_gac_del(
  			v_gac_rec.person_id,
  			v_gac_rec.create_dt,
  			v_gac_rec.grd_cal_type,
  			v_gac_rec.grd_ci_sequence_number,
  			v_gac_rec.ceremony_number,
  			v_gac_rec.award_cd);
  		FETCH c_gac_del INTO v_gac_del;
  			-- 3.Delete the existing graduand_award_ceremony record
  			IF (c_gac_del%FOUND) THEN
				IGS_GR_AWD_CRMN_PKG.DELETE_ROW(
				  X_ROWID => v_gac_del.rowid);
  			END IF;
  			CLOSE c_gac_del;
  		EXCEPTION
  			WHEN e_resource_busy_exception THEN
  				IF c_gach %ISOPEN THEN
  					CLOSE c_gach;
  				END IF;
  				ROLLBACK TO sp_gac_del;
  				p_message_name := 'IGS_GR_CANNOT_DELETE_AWD_CERM';
  				RETURN FALSE;
  			WHEN OTHERS THEN
  				ROLLBACK TO sp_gac_del;
  				RAISE;
  		END;
  		BEGIN
  			FOR v_gach_rec IN c_gach(
  						v_gac_rec.person_id,
  						v_gac_rec.create_dt,
  						v_gac_rec.grd_cal_type,
  						v_gac_rec.grd_ci_sequence_number,
  						v_gac_rec.ceremony_number,
  						v_gac_rec.award_cd) LOOP
				IGS_GR_AWD_CRMN_HIST_PKG.DELETE_ROW(
				  X_ROWID => v_gach_rec.rowid);
  			END LOOP;
  		EXCEPTION
  			WHEN e_resource_busy_exception THEN
  				IF c_gach %ISOPEN THEN
  					CLOSE c_gach;
  				END IF;
  				ROLLBACK TO sp_gac_del;
  				p_message_name := 'IGS_GR_CANNOT_DELETE_AWD_CERM';
  				RETURN FALSE;
  			WHEN OTHERS THEN
  				ROLLBACK TO sp_gac_del;
  				RAISE;
  		END;
  		COMMIT;
  		-- 4.Call GRDP_INS_GAC to allocate this graduand to another
  		-- ceremony if one is available
  		IF NOT grdp_ins_gac(
  				v_gac_rec.person_id,
  				v_gac_rec.create_dt ,
  				p_grd_cal_type,
  				p_grd_ci_sequence_number,
  				v_gac_rec.name_pronunciation,
  				v_gac_rec.name_announced,
  				v_gac_rec.academic_dress_rqrd_ind,
  				v_gac_rec.academic_gown_size,
  				v_gac_rec.academic_hat_size,
  				v_gac_rec.guest_tickets_requested,
  				v_gac_rec.guest_tickets_allocated,
  				v_gac_rec.guest_seats,
  				v_gac_rec.fees_paid_ind,
  				v_gac_rec.special_requirements,
  				p_resolve_stalemate_type,
  				p_ignore_unit_sets_ind,
  				p_message_name) THEN
  			v_loop_flag := TRUE;
  			Exit;
  		END IF;
  	END LOOP; --c_gac
  	IF (v_loop_flag = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gac %ISOPEN THEN
  			CLOSE c_gac;
  		END IF;
  		IF c_gac_del %ISOPEN THEN
  			CLOSE c_gac_del;
  		END IF;
  		IF c_gach %ISOPEN THEN
  			CLOSE c_gach;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_prc_acusg_close;
  --
  -- Process the close of a Award Ceremony
  FUNCTION grdp_prc_awc_close(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_resolve_stalemate_type IN VARCHAR2 ,
  p_ignore_unit_sets_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- grdp_prc_awc_close
  	-- Description: This process is passed the details of a award_ceremony
  	-- record which is closed. It finds any related award_ceremony_us_group
  	-- records and calls GENP_PRC_ACUSG_CLOSE to delete associated
  	-- graduand_award_ceremony records and attempt to re-allocate them to
  	-- another ceremony.  After all the graduand_award_ceremony records are
  	-- removed the award_ceremony_us_group record is deleted.  The process
  	-- then finds any graduand_award_ceremony records associated with the
	-- award_ceremony, deletes them and calls GENP_PRC_GAC_CRMNY to attempt
  	-- to allocate them to another ceremony.
  DECLARE
  	v_loop_flag			BOOLEAN := FALSE;
  	e_resource_busy_exception		EXCEPTION;
  	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
  	CURSOR	c_acusg IS
  		SELECT	acusg.us_group_number
  		FROM	IGS_GR_AWD_CRM_US_GP		acusg
  		WHERE	acusg.grd_cal_type		= p_grd_cal_type AND
  			acusg.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
  			acusg.ceremony_number		= p_ceremony_number AND
  			NVL(acusg.award_course_cd, 'NULL') = NVL(p_award_course_cd, 'NULL') AND
  			NVL(acusg.award_crs_version_number, 0)
  						= NVL(p_award_crs_version_number, 0) AND
  			acusg.award_cd 			= p_award_cd;
  	CURSOR	c_gac IS
  		SELECT	gac.person_id,
  			gac.create_dt,
  			gac.name_pronunciation,
  			gac.name_announced,
  			gac.academic_dress_rqrd_ind,
  			gac.academic_gown_size,
  			gac.academic_hat_size,
  			gac.guest_tickets_requested,
  			gac.guest_tickets_allocated,
  			gac.guest_seats,
  			gac.fees_paid_ind,
  			gac.special_requirements,
  			gac.grd_cal_type,
  			gac.grd_ci_sequence_number,
  			gac.ceremony_number,
  			gac.award_course_cd,
  			gac.award_crs_version_number,
  			gac.award_cd
  		FROM	IGS_GR_AWD_CRMN		gac
  		WHERE	gac.grd_cal_type 		= p_grd_cal_type AND
  			gac.grd_ci_sequence_number 	= p_grd_ci_sequence_number AND
  			gac.ceremony_number 		= p_ceremony_number AND
  			gac.award_course_cd 		= p_award_course_cd AND
  			gac.award_crs_version_number 	= p_award_crs_version_number AND
  			gac.award_cd 			= p_award_cd AND
  			gac.us_group_number 		IS NULL;
  	CURSOR	c_gac_del (
  			cp_person_id			IGS_GR_AWD_CRMN.person_id%TYPE,
  			cp_create_dt			IGS_GR_AWD_CRMN.create_dt%TYPE,
  			cp_grd_cal_type			IGS_GR_AWD_CRMN.grd_cal_type%TYPE,
  			cp_grd_ci_sequence_number
  							IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE,
  			cp_ceremony_number		IGS_GR_AWD_CRMN.ceremony_number%TYPE,
  			cp_award_cd			IGS_GR_AWD_CRMN.award_cd%TYPE) IS
  		SELECT	rowid, gac.*
  		FROM	IGS_GR_AWD_CRMN		gac
  		WHERE	gac.person_id 			= cp_person_id AND
  			gac.create_dt			= cp_create_dt AND
  			gac.grd_cal_type		= cp_grd_cal_type AND
  			gac.grd_ci_sequence_number	= cp_grd_ci_sequence_number AND
  			gac.award_cd			= cp_award_cd
  		FOR UPDATE OF gac.person_id NOWAIT;
  		v_gac_del		c_gac_del%ROWTYPE;
  	CURSOR	c_gach(
  			cp_gac_person_id		IGS_GR_AWD_CRMN.person_id%TYPE,
  			cp_gac_create_dt		IGS_GR_AWD_CRMN.create_dt%TYPE,
  			cp_grd_cal_type			IGS_GR_AWD_CRMN.grd_cal_type%TYPE,
  			cp_grd_ci_sequence_number
  						IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE,
  			cp_ceremony_number		IGS_GR_AWD_CRMN.ceremony_number%TYPE,
  			cp_award_cd			IGS_GR_AWD_CRMN.award_cd%TYPE) IS
  		SELECT	rowid, gach.person_id
  		FROM	IGS_GR_AWD_CRMN_HIST	gach
  		WHERE	gach.person_id			= cp_gac_person_id AND
  			gach.create_dt			= cp_gac_create_dt AND
  			gach.grd_cal_type		= cp_grd_cal_type AND
  			gach.grd_ci_sequence_number	= cp_grd_ci_sequence_number AND
  			gach.ceremony_number		= cp_ceremony_number AND
  			gach.award_cd			= cp_award_cd
  		FOR UPDATE OF gach.person_id NOWAIT;
  BEGIN
  	p_message_name := NULL;
  	-- 1.Check parameters
  	IF p_grd_cal_type IS NULL OR
     			p_grd_ci_sequence_number IS NULL OR
     			p_ceremony_number IS NULL OR
     			p_award_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- 2.Find any associated award_ceremony_us_group records for
  	-- this award_ceremony and loop through them.
  	FOR v_acusg_rec IN c_acusg LOOP
  		-- 3.Call GRDP_PRC_ACUSG_CLOSE to process the graduands
  		-- for the award_ceremony_us_group record and then delete it.
  		IF NOT grdp_prc_acusg_close(
  					p_grd_cal_type,
  					p_grd_ci_sequence_number,
  					p_ceremony_number,
  					p_award_course_cd,
  					p_award_crs_version_number,
  					p_award_cd,
  					v_acusg_rec.us_group_number,
  					p_resolve_stalemate_type,
  					p_ignore_unit_sets_ind,
  					p_message_name) THEN
  			v_loop_flag := TRUE;
  			Exit;
  		END IF;
  	END LOOP;
  	IF (v_loop_flag = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	-- 4.Find any associated graduand_award_ceremony records for this
  	-- award_ceremony and loop through them.
  	FOR v_gac_rec IN c_gac LOOP
  		SAVEPOINT sp_gac_del;
  		BEGIN
  		OPEN c_gac_del(
  			v_gac_rec.person_id,
  			v_gac_rec.create_dt,
  			v_gac_rec.grd_cal_type,
  			v_gac_rec.grd_ci_sequence_number,
  			v_gac_rec.ceremony_number,
  			v_gac_rec.award_cd);
  		FETCH c_gac_del INTO v_gac_del;
  			-- 3.Delete the existing graduand_award_ceremony record
  			IF (c_gac_del%FOUND) THEN
				IGS_GR_AWD_CRMN_PKG.DELETE_ROW(
				  X_ROWID => v_gac_del.rowid);
  			END IF;
  			CLOSE c_gac_del;
  		EXCEPTION
  			WHEN e_resource_busy_exception THEN
  				IF c_gach %ISOPEN THEN
  					CLOSE c_gach;
  				END IF;
  				ROLLBACK TO sp_gac_del;
  				p_message_name := 'IGS_GR_CANNOT_DELETE_AWD_CERM';
  				RETURN FALSE;
  			WHEN OTHERS THEN
  				ROLLBACK TO sp_gac_del;
  				RAISE;
  		END;
  		BEGIN
  			FOR v_gach_rec IN c_gach(
  						v_gac_rec.person_id,
  						v_gac_rec.create_dt,
  						v_gac_rec.grd_cal_type,
  						v_gac_rec.grd_ci_sequence_number,
  						v_gac_rec.ceremony_number,
  						v_gac_rec.award_cd) LOOP
				IGS_GR_AWD_CRMN_HIST_PKG.DELETE_ROW(
				  X_ROWID => v_gach_rec.rowid);
  			END LOOP;
  		EXCEPTION
  			WHEN e_resource_busy_exception THEN
  				IF c_gach %ISOPEN THEN
  					CLOSE c_gach;
  				END IF;
  				ROLLBACK TO sp_gac_del;
  				p_message_name := 'IGS_GR_CANNOT_DELETE_AWD_CERM';
  				RETURN FALSE;
  			WHEN OTHERS THEN
  				ROLLBACK TO sp_gac_del;
  				RAISE;
  		END;
  		COMMIT;
  		-- 6.Call grdp_ins_gac to allocate this graduand to
  		-- another ceremony if one is available.
  		IF NOT grdp_ins_gac(
  				v_gac_rec.person_id,
  				v_gac_rec.create_dt ,
  				p_grd_cal_type,
  				p_grd_ci_sequence_number,
  				v_gac_rec.name_pronunciation,
  				v_gac_rec.name_announced,
  				v_gac_rec.academic_dress_rqrd_ind,
  				v_gac_rec.academic_gown_size,
  				v_gac_rec.academic_hat_size,
  				v_gac_rec.guest_tickets_requested,
  				v_gac_rec.guest_tickets_allocated,
  				v_gac_rec.guest_seats,
  				v_gac_rec.fees_paid_ind,
  				v_gac_rec.special_requirements,
  				p_resolve_stalemate_type,
  				p_ignore_unit_sets_ind,
  				p_message_name) THEN
  			v_loop_flag := TRUE;
  			Exit;
  		END IF;
  	END LOOP;
  	IF (v_loop_flag = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_acusg %ISOPEN THEN
  			CLOSE c_acusg;
  		END IF;
  		IF c_gac %ISOPEN THEN
  			CLOSE c_gac;
  		END IF;
  		IF c_gac_del %ISOPEN THEN
  			CLOSE c_gac_del;
  		END IF;
  		IF c_gach %ISOPEN THEN
  			CLOSE c_gach;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_prc_awc_close;
END IGS_GR_PRC_GAC;

/
