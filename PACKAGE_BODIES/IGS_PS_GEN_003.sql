--------------------------------------------------------
--  DDL for Package Body IGS_PS_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GEN_003" AS
/* $Header: IGSPS03B.pls 120.6 2006/02/17 02:48:40 sarakshi ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sarakshi    21-oct-2003     Enh#3052452,added function enrollment_for_uoo_check
  --sarakshi    25-Feb-2003     Bug#2797116,modified curosr gc_cd_and_vn_passed and gc_coo_id_passed
  --                            in crsp_get_coo_key procedure,added delete_flag check in the where clause
  --shtatiko    05-FEB-2003     Bug# 2550392, Modified crsp_ins_ci_cop procedure and added
  --                            log_parameters procedures.
  --smadathi    28-AUG-2001     Bug No. 1956374 .The call to igs_ps_val_cop.genp_val_staff_prsn
  --                            is changed to igs_ad_val_acai.genp_val_staff_prsn
  -------------------------------------------------------------------------------------------
 -- Bug # 1956374 Procedure assp_val_gs_cur_fut reference is changed

PROCEDURE log_parameters ( p_c_param_name    VARCHAR2 ,
                           p_c_param_value   VARCHAR2
                         ) IS
/***********************************************************************************************

  Created By     :  SHTATIKO
  Date Created By:  05-FEB-2003

  Purpose        :  To log the parameters. This has been added as part of Bug Fix 2550392.

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */
BEGIN
  fnd_message.set_name('IGS','IGS_PS_DEL_PRIORITY_LOG');
  fnd_message.set_token('PARAMETER_NAME', p_c_param_name );
  fnd_message.set_token('PARAMETER_VAL' , p_c_param_value ) ;
  fnd_file.put_line(fnd_file.LOG,FND_MESSAGE.GET);
END log_parameters  ;


PROCEDURE crsp_get_coo_key(
  p_coo_id IN OUT NOCOPY NUMBER ,
  p_course_cd IN OUT NOCOPY VARCHAR2 ,
  p_version_number IN OUT NOCOPY NUMBER ,
  p_cal_type IN OUT NOCOPY VARCHAR2 ,
  p_location_cd IN OUT NOCOPY VARCHAR2 ,
  p_attendance_mode IN OUT NOCOPY VARCHAR2 ,
  p_attendance_type IN OUT NOCOPY VARCHAR2 )
AS
lv_param_values		VARCHAR2(1080);
BEGIN
DECLARE

	gv_cd_and_vn_passed	IGS_PS_OFR_OPT.coo_id%TYPE;
	gv_coo_id_passed	IGS_PS_OFR_OPT%ROWTYPE;
	-- this is used when the course_cd and version_number
	-- are passed
	CURSOR gc_cd_and_vn_passed IS
		SELECT 	coo_id
		FROM	IGS_PS_OFR_OPT
		WHERE	course_cd = p_course_cd AND
			version_number = p_version_number AND
			cal_type = p_cal_type AND
			location_cd = p_location_cd AND
			attendance_mode = p_attendance_mode AND
			attendance_type = p_attendance_type AND
                        delete_flag = 'N';
	-- this is used when the coo_id is passed
	CURSOR gc_coo_id_passed IS
		SELECT 	*
		FROM 	IGS_PS_OFR_OPT
		WHERE	coo_id = p_coo_id
                AND     delete_flag = 'N';
BEGIN
	-- if only the course_cd was enetered
	IF(NVL(p_course_cd, 'NO_VALUE') <> 'NO_VALUE') THEN
		OPEN 	gc_cd_and_vn_passed;
		FETCH	gc_cd_and_vn_passed INTO gv_cd_and_vn_passed;
		-- return the coo_id
		IF(gc_cd_and_vn_passed%ROWCOUNT <> 0) THEN
			CLOSE gc_cd_and_vn_passed;
			p_coo_id := gv_cd_and_vn_passed;
		END IF;
	ELSE
		-- if only the coo_id is entered
		IF p_coo_id IS NOT NULL THEN
			OPEN 	gc_coo_id_passed;
			FETCH	gc_coo_id_passed INTO gv_coo_id_passed;
			-- return the coo_id, course_cd, version_number,
			-- IGS_CA_TYPE, location_cd, attendance_mode, attendance_type
			IF(gc_coo_id_passed%ROWCOUNT <> 0) THEN
				CLOSE gc_coo_id_passed;
				p_course_cd := gv_coo_id_passed.course_cd;
				p_version_number := gv_coo_id_passed.version_number;
				p_cal_type := gv_coo_id_passed.cal_type;
				p_location_cd := gv_coo_id_passed.location_cd;
				p_attendance_mode := gv_coo_id_passed.attendance_mode;
				p_attendance_type := gv_coo_id_passed.attendance_type;
			END IF;
		ELSE
			-- Do nothing.
			NULL;
		END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_003.crsp_get_coo_key');
		IGS_GE_MSG_STACK.ADD;
		lv_param_values := to_char(p_coo_id)||','||p_course_cd||','||to_char(p_version_number)||','||p_cal_type||','
					||p_location_cd||','||p_attendance_mode||','||p_attendance_type;
		Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
		Fnd_Message.Set_Token('VALUE',lv_param_values);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END;
END crsp_get_coo_key;


PROCEDURE crsp_get_cop_key(
  p_cop_id IN OUT NOCOPY NUMBER ,
  p_course_cd IN OUT NOCOPY VARCHAR2 ,
  p_version_number IN OUT NOCOPY NUMBER ,
  p_cal_type IN OUT NOCOPY VARCHAR2 ,
  p_ci_sequence_number IN OUT NOCOPY NUMBER ,
  p_location_cd IN OUT NOCOPY VARCHAR2 ,
  p_attendance_mode IN OUT NOCOPY VARCHAR2 ,
  p_attendance_type IN OUT NOCOPY VARCHAR2 )
AS
lv_param_values		VARCHAR2(1080);
BEGIN
DECLARE

	gv_cd_and_vn_passed	IGS_PS_OFR_PAT.coo_id%TYPE;
	gv_cop_id_passed	IGS_PS_OFR_PAT%ROWTYPE;
	-- this is used when the course_cd and version_number
	-- are passed
	CURSOR gc_cd_and_vn_passed IS
		SELECT 	cop_id
		FROM	IGS_PS_OFR_PAT
		WHERE	course_cd = p_course_cd AND
			version_number = p_version_number AND
			cal_type = p_cal_type AND
			ci_sequence_number = p_ci_sequence_number AND
			location_cd = p_location_cd AND
			attendance_mode = p_attendance_mode AND
			attendance_type = p_attendance_type;
	-- this is used when the coo_id is passed
	CURSOR gc_cop_id_passed IS
		SELECT 	*
		FROM 	IGS_PS_OFR_PAT
		WHERE	cop_id = p_cop_id;
BEGIN
	-- if only the course_cd was enetered
	IF(NVL(p_course_cd, 'NO_VALUE') <> 'NO_VALUE') THEN
		OPEN 	gc_cd_and_vn_passed;
		FETCH	gc_cd_and_vn_passed INTO gv_cd_and_vn_passed;
		-- return the cop_id
		IF(gc_cd_and_vn_passed%ROWCOUNT <> 0) THEN
			CLOSE gc_cd_and_vn_passed;
			p_cop_id := gv_cd_and_vn_passed;
		END IF;
	ELSE
		-- if only the cop_id is entered
		IF p_cop_id IS NOT NULL THEN
			OPEN 	gc_cop_id_passed;
			FETCH	gc_cop_id_passed INTO gv_cop_id_passed;
			-- return the cop_id, course_cd, version_number,
			-- IGS_CA_TYPE, ci_sequence_numberlocation_cd,
			-- attendance_mode, attendance_type
			IF(gc_cop_id_passed%ROWCOUNT <> 0) THEN
				CLOSE gc_cop_id_passed;
				p_course_cd := gv_cop_id_passed.course_cd;
				p_version_number := gv_cop_id_passed.version_number;
				p_cal_type := gv_cop_id_passed.cal_type;
				p_ci_sequence_number := gv_cop_id_passed.ci_sequence_number;
				p_location_cd := gv_cop_id_passed.location_cd;
				p_attendance_mode := gv_cop_id_passed.attendance_mode;
				p_attendance_type := gv_cop_id_passed.attendance_type;
			END IF;
		ELSE
			-- Do nothing.
			NULL;
		END IF;
	END IF;
EXCEPTION

	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_003.crsp_get_cop_key');
		IGS_GE_MSG_STACK.ADD;
		lv_param_values := to_char(p_cop_id)||','||p_course_cd||','||to_char(p_version_number)||','||p_cal_type||','
					||to_char(p_ci_sequence_number)||','||p_location_cd||','||p_attendance_mode||','||p_attendance_type;
		Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
		Fnd_Message.Set_Token('VALUE',lv_param_values);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END;
END crsp_get_cop_key;

FUNCTION crsp_get_cous_ind(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 )
RETURN VARCHAR2 AS
lv_param_values		VARCHAR2(1080);
BEGIN	-- crsp_get_cous_ind
	-- This module returns Y if the IGS_PS_COURSE offering and IGS_PS_UNIT set exists
	-- in the IGS_PS_OFR_UNIT_SET table.
DECLARE

	v_dummy		VARCHAR2(1);
	CURSOR c_cous IS
		SELECT	'X'
		FROM	IGS_PS_OFR_UNIT_SET	cous
		WHERE	cous.course_cd		= p_course_cd		AND
			cous.crv_version_number	= p_crv_version_number	AND
			cous.cal_type		= p_cal_type		AND
			cous.unit_set_cd		= p_unit_set_cd;
BEGIN
	OPEN c_cous;
	FETCH c_cous INTO v_dummy;
	IF c_cous%FOUND THEN
		CLOSE c_cous;
		RETURN 'Y';
	ELSE
		CLOSE c_cous;
		RETURN 'N';
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF c_cous%ISOPEN THEN
			CLOSE c_cous;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_003.crsp_get_cous_ind');
		IGS_GE_MSG_STACK.ADD;
		lv_param_values := p_course_cd||','||to_char(p_crv_version_number)||','||p_cal_type||','||p_unit_set_cd;

		Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
		Fnd_Message.Set_Token('VALUE',lv_param_values);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_get_cous_ind;

FUNCTION crsp_get_cous_subind(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER )
RETURN VARCHAR2 AS
lv_param_values		VARCHAR2(1080);
BEGIN	-- crsp_get_cous_subind
	-- This module fetches the value for the only_as_sub_ind for a IGS_PS_COURSE offering
	-- IGS_PS_UNIT set from the IGS_PS_OFR_UNIT_SET table.
DECLARE

	v_only_as_sub_ind	IGS_PS_OFR_UNIT_SET.only_as_sub_ind%TYPE;
	CURSOR c_cous IS
		SELECT	cous.only_as_sub_ind
		FROM	IGS_PS_OFR_UNIT_SET	cous
		WHERE	cous.course_cd		= p_course_cd		AND
			cous.crv_version_number	= p_crv_version_number	AND
			cous.cal_type		= p_cal_type		AND
			cous.unit_set_cd	= p_unit_set_cd		AND
			cous.us_version_number	= p_us_version_number;
BEGIN
	OPEN c_cous;
	FETCH c_cous INTO v_only_as_sub_ind;
	IF c_cous%FOUND THEN
		CLOSE c_cous;
		RETURN v_only_as_sub_ind;
	ELSE
		CLOSE c_cous;
		RETURN NULL;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF c_cous%ISOPEN THEN
			CLOSE c_cous;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN

		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_003.crsp_get_cous_subind');
		IGS_GE_MSG_STACK.ADD;
		lv_param_values := p_course_cd||','||to_char(p_crv_version_number)||','||p_cal_type||','||p_unit_set_cd||
					','||to_char(p_us_version_number);

		Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
		Fnd_Message.Set_Token('VALUE',lv_param_values);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_get_cous_subind;

FUNCTION crsp_ins_coi_cop(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_source_cal_type IN VARCHAR2 ,
  p_source_sequence_number IN NUMBER ,
  p_dest_cal_type IN VARCHAR2 ,
  p_dest_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean AS
 lv_param_values		VARCHAR2(1080);
BEGIN   -- crsp_ins_coi_cop
DECLARE

        v_inserted_cnt          NUMBER(4);
        v_check                 CHAR;
        v_message_name          varchar2(30);
        v_gs_version_number     IGS_AS_GRD_SCHEMA.version_number%TYPE;
        CURSOR c_course_offering_pattern IS
                SELECT  location_cd,
                        attendance_mode,
                        attendance_type,
                        cop_id,
                        coo_id,
                        offered_ind,
                        entry_point_ind,
                        pre_enrol_units_ind,
                        enrollable_ind,
                        ivrs_available_ind,
                        min_entry_ass_score,
                        guaranteed_entry_ass_scr,
                        max_cross_faculty_cp,
                        max_cross_location_cp,
                        max_cross_mode_cp,
                        max_hist_cross_faculty_cp,
                        adm_ass_officer_person_id,
                        adm_contact_person_id,
                        grading_schema_cd,
                        gs_version_number
                FROM    IGS_PS_OFR_PAT
                WHERE   course_cd               = p_course_cd           AND
                        version_number          = p_version_number      AND
                        cal_type                = p_source_cal_type     AND
                        ci_sequence_number      = p_source_sequence_number;
        v_cop_rec               c_course_offering_pattern%ROWTYPE;
        CURSOR c_check_cop_exist IS
                SELECT  'x'
                FROM    IGS_PS_OFR_PAT
                WHERE   course_cd               = p_course_cd                   AND
                        version_number          = p_version_number              AND
                        cal_type                = p_dest_cal_type               AND
                        ci_sequence_number      = p_dest_sequence_number        AND
                        location_cd             = v_cop_rec.location_cd         AND
                        attendance_type         = v_cop_rec.attendance_type     AND
                        attendance_mode         = v_cop_rec.attendance_mode;
        CURSOR c_cop_sequence_number IS
                SELECT  IGS_PS_OFR_PAT_COP_ID_S.NEXTVAL
                FROM    DUAL;
        CURSOR c_latest_gs_version (
                cp_gs_cd                IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE) IS
                SELECT  MAX(gs.version_number)
                FROM    IGS_AS_GRD_SCHEMA  gs
                WHERE   gs.grading_schema_cd    = cp_gs_cd;

	x_rowid			VARCHAR2(25);
BEGIN
        p_message_name := NULL;
        v_inserted_cnt := 0; -- number of records inserted
        -- Rollover IGS_PS_COURSE offering patterns from
        -- source IGS_PS_COURSE offering instance
        --       (p_course_cd,p_version_number,
        --        p_source_cal_type,p_source_sequence_number) to
        -- destination IGS_PS_COURSE offering instance
        --      (p_course_cd,p_version_number,
        --       p_dest_cal_type,p_dest_sequence_number)
        OPEN c_course_offering_pattern;
        LOOP
                FETCH c_course_offering_pattern INTO v_cop_rec;
                EXIT WHEN c_course_offering_pattern%NOTFOUND;
                -- Check for closed IGS_AD_LOCATION code,
                --      closed attendance mode,
                --      and closed attendance type

                -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_COO.crsp_val_loc_cd
                IF (IGS_PS_VAL_UOO.crsp_val_loc_cd (
                                v_cop_rec.location_cd,
                                p_message_name) = TRUE)  AND
                   (IGS_PS_VAL_COo.crsp_val_coo_am (
                                v_cop_rec.attendance_mode,
                                p_message_name) = TRUE)  AND
                   (IGS_PS_VAL_COo.crsp_val_coo_att (
                                v_cop_rec.attendance_type,
                                p_message_name) = TRUE)  THEN
                        OPEN c_check_cop_exist;
                        FETCH c_check_cop_exist INTO v_check;
                        -- Only rollover if the record to be inserted not exists
                        IF (c_check_cop_exist%NOTFOUND) THEN
                                CLOSE c_check_cop_exist;
                                -- get the next sequence number
                                OPEN c_cop_sequence_number;
                                FETCH c_cop_sequence_number INTO v_cop_rec.cop_id;
                                CLOSE c_cop_sequence_number;
                                --  get the latest grading schema version number
                                OPEN c_latest_gs_version (
                                                v_cop_rec.grading_schema_cd);
                                FETCH c_latest_gs_version INTO v_gs_version_number;
                                CLOSE c_latest_gs_version;
                                IF IGS_AS_VAL_GSG.assp_val_gs_cur_fut (
                                                        v_cop_rec.grading_schema_cd,
                                                        v_gs_version_number,
                                                        v_message_name) = FALSE THEN
                                        -- The latest grading schema fails the current or vuture valildation
                                        v_cop_rec.grading_schema_cd := NULL;
                                        v_cop_rec.gs_version_number := NULL;
                                ELSE
                                        v_cop_rec.gs_version_number := v_gs_version_number;
                                END IF;
                                -- check if a IGS_PE_PERSON fails the staff IGS_PE_PERSON validation
                                IF igs_ad_val_acai.genp_val_staff_prsn (
                                                v_cop_rec.adm_ass_officer_person_id,
                                                v_message_name) = FALSE THEN
                                        v_cop_rec.adm_ass_officer_person_id := NULL;
                                END IF;
                                IF igs_ad_val_acai.genp_val_staff_prsn (
                                                v_cop_rec.adm_contact_person_id,
                                                v_message_name) = FALSE THEN
                                        v_cop_rec.adm_contact_person_id := NULL;
                                END IF;


					  IGS_PS_OFR_PAT_PKG.Insert_Row(
						X_ROWID				=>   x_rowid,
						X_COURSE_CD                   => 	p_course_cd,
						X_CI_SEQUENCE_NUMBER          => 	 p_dest_sequence_number,
						X_CAL_TYPE                    => 	 p_dest_cal_type,
						X_VERSION_NUMBER              => 	 p_version_number,
						X_LOCATION_CD                 => 	 v_cop_rec.location_cd,
						X_ATTENDANCE_TYPE             => 	 v_cop_rec.attendance_type,
						X_ATTENDANCE_MODE             => 	 v_cop_rec.attendance_mode,
						X_COP_ID                      => 	 v_cop_rec.cop_id,
						X_COO_ID                      => 	 v_cop_rec.coo_id,
						X_OFFERED_IND                 => 	 v_cop_rec.offered_ind,
						X_CONFIRMED_OFFERING_IND      =>	 NULL,
						X_ENTRY_POINT_IND             => 	 v_cop_rec.entry_point_ind,
						X_PRE_ENROL_UNITS_IND         => 	 v_cop_rec.pre_enrol_units_ind,
						X_ENROLLABLE_IND              => 	 v_cop_rec.enrollable_ind,
						X_IVRS_AVAILABLE_IND          => 	 v_cop_rec.ivrs_available_ind,
						X_MIN_ENTRY_ASS_SCORE         => 	 v_cop_rec.min_entry_ass_score,
						X_GUARANTEED_ENTRY_ASS_SCR    => 	 v_cop_rec.guaranteed_entry_ass_scr,
						X_MAX_CROSS_FACULTY_CP        => 	 v_cop_rec.max_cross_faculty_cp,
						X_MAX_CROSS_LOCATION_CP       => 	 v_cop_rec.max_cross_location_cp,
						X_MAX_CROSS_MODE_CP           => 	 v_cop_rec.max_cross_mode_cp,
						X_MAX_HIST_CROSS_FACULTY_CP	=> v_cop_rec.max_hist_cross_faculty_cp,
						X_ADM_ASS_OFFICER_PERSON_ID	=> v_cop_rec.adm_ass_officer_person_id,
						X_ADM_CONTACT_PERSON_ID       => 	 v_cop_rec.adm_contact_person_id,
						X_GRADING_SCHEMA_CD           => 	 v_cop_rec.grading_schema_cd,
						X_GS_VERSION_NUMBER           => 	 v_cop_rec.gs_version_number,
						X_MODE                        => 	 'R');


                                v_inserted_cnt := v_inserted_cnt + 1;
                        ELSE
                                CLOSE c_check_cop_exist;
                        END IF; -- dest record does not exist
                END IF; -- check closed IGS_AD_LOCATION code
        END LOOP;
        -- No record is selected
        IF (c_course_offering_pattern%ROWCOUNT = 0) THEN
                p_message_name := 'IGS_PS_NO_POP_TOBE_ENROLLED';
        -- No record is inserted
        ELSIF (v_inserted_cnt = 0) THEN
                p_message_name := 'IGS_PS_PRGOFFR_ROLLED_EXIST';
        -- Some records are inserted
        ELSIF (c_course_offering_pattern%ROWCOUNT <> v_inserted_cnt) THEN
                p_message_name := 'IGS_PS_PARTIALCREATION_OFFPAT';
        -- All records are inserted
        ELSIF (c_course_offering_pattern%ROWCOUNT = v_inserted_cnt) THEN
                p_message_name := 'IGS_PS_SUCCESS_CREATION_POP';
        END IF;
        CLOSE c_course_offering_pattern;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_course_offering_pattern%ISOPEN THEN
                        CLOSE c_course_offering_pattern;
                END IF;
                IF c_cop_sequence_number%ISOPEN THEN
                        CLOSE c_cop_sequence_number;
                END IF;
                IF c_check_cop_exist%ISOPEN THEN
                        CLOSE c_check_cop_exist;
                END IF;
                IF c_latest_gs_version%ISOPEN THEN
                        CLOSE c_latest_gs_version;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN

                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_003.crsp_ins_coi_cop');
		IGS_GE_MSG_STACK.ADD;
		lv_param_values := p_course_cd||','||to_char(p_version_number)||','||p_source_cal_type||','
					||to_char(p_source_sequence_number)||','||p_dest_cal_type||','||
					to_char(p_dest_sequence_number)||','||p_message_name;

		Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
		Fnd_Message.Set_Token('VALUE',lv_param_values);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_coi_cop;

PROCEDURE CRSP_INS_CI_COP (
errbuf  out NOCOPY  varchar2,
retcode out NOCOPY  number,
p_source_cal  IN VARCHAR2 ,
p_dest_cal  IN VARCHAR2 ,
p_org_unit  IN VARCHAR2,
p_org_id     IN NUMBER) AS
/*
  WHO             WHEN             WHAT
  shtatiko        05-FEB-2003      Bug# 2550392, Added code to log information wherever needed to make
                                   log file more informative.
*/

p_source_cal_type                    	igs_ca_inst.cal_type%type ;
p_source_sequence_number     	igs_ca_inst.sequence_number%type;
p_dest_cal_type                        	igs_ca_inst.cal_type%type;
p_dest_sequence_number         	igs_ca_inst.sequence_number%type;
p_org_unit_cd		         	igs_or_unit.org_unit_cd%type;
	v_check				CHAR;
	v_coi_rec			IGS_PS_OFR_INST%ROWTYPE;
	v_message			VARCHAR2(30);
	gv_ci_start_dt			IGS_PS_OFR_INST.ci_start_dt%TYPE;
	gv_ci_end_dt			IGS_PS_OFR_INST.ci_end_dt%TYPE;
	v_rec_inserted_cnt		NUMBER(4) := 0;
	cst_none_cop_rec_inserted	BOOLEAN := TRUE;
	cst_partial_cop_rec_inserted	BOOLEAN := TRUE;
	cst_all_cop_rec_inserted		BOOLEAN := TRUE;
	cst_none_coi_rec_inserted		BOOLEAN := FALSE;
	cst_partial_coi_rec_inserted	BOOLEAN := FALSE;
	cst_all_coi_rec_inserted		BOOLEAN := FALSE;

	CURSOR c_check_cal_type_exist IS
		SELECT 'x'
		FROM	IGS_CA_TYPE
		WHERE 	cal_type = p_source_cal_type;
	CURSOR c_check_cal_instance_exist(
			cp_cal_type		IGS_PS_OFR_INST.cal_type%TYPE,
			cp_sequence_number	IGS_PS_OFR_INST.version_number%TYPE) IS
		SELECT	'x'
		FROM	IGS_CA_INST
		WHERE	cal_type	= cp_cal_type	AND
			sequence_number	= cp_sequence_number;
	CURSOR c_get_cal_instance_dates(
			cp_cal_type		IGS_PS_OFR_INST.cal_type%TYPE,
			cp_sequence_number	IGS_PS_OFR_INST.version_number%TYPE) IS
		SELECT	start_dt, end_dt
		FROM	IGS_CA_INST
		WHERE	cal_type	= cp_cal_type	AND
			sequence_number	= cp_sequence_number;
	CURSOR c_course_offering_instance IS
		SELECT	coi.course_cd,
			coi.version_number,
			coi.cal_type,
			coi.ci_sequence_number,
			coi.ci_start_dt,
			coi.ci_end_dt,
			coi.min_entry_ass_score,
			coi.guaranteed_entry_ass_scr,
			coi.created_by,
			coi.creation_date,
			coi.last_updated_by,
			coi.last_update_date,
			coi.last_update_login,
			coi.request_id,
			coi.PROGRAM_APPLICATION_ID,
			coi.PROGRAM_ID,
			coi.PROGRAM_UPDATE_DATE
		FROM	IGS_PS_OFR_INST	coi,
			IGS_PS_VER			cv
		WHERE	coi.cal_type=p_source_cal_type			AND
			coi.ci_sequence_number= 	p_source_sequence_number	AND
			cv.course_cd	= 	coi.course_cd			AND
			cv.version_number= 	coi.version_number		AND
			cv.expiry_dt 		IS NULL			AND
			cv.responsible_org_unit_cd	LIKE 	p_org_unit_cd;
	CURSOR c_check_coi_exist (
			cp_course_cd		IGS_PS_OFR_INST.course_cd%TYPE,
			cp_version_number	IGS_PS_OFR_INST.version_number%TYPE) IS
		SELECT	'x'
		FROM	IGS_PS_OFR_INST
		WHERE	course_cd	= cp_course_cd		AND
			version_number	= cp_version_number	AND
			cal_type		= p_dest_cal_type	AND
			ci_sequence_number	= p_dest_sequence_number;
	x_rowid			VARCHAR2(25);
	INVALID		EXCEPTION;
        VALID		EXCEPTION;

	l_start_dt      igs_ca_inst.start_dt%TYPE;
	l_end_dt        igs_ca_inst.end_dt%TYPE;

BEGIN
-- Parameter Validation
-- Adding the default org id parameter as part of MULTI-ORG  changes
             IGS_GE_GEN_003.SET_ORG_ID(p_org_id);

-- Extract source calendar
              p_source_cal_type 	       	:= RTRIM(SUBSTR(p_source_cal, 102, 10));
              p_source_sequence_number 	:= TO_NUMBER(RTRIM(SUBSTR(p_source_cal, 113, 8)));

-- Extract destination calendar
              p_dest_cal_type			 := RTRIM(SUBSTR(p_dest_cal, 102, 10));
              p_dest_sequence_number 		:= TO_NUMBER(RTRIM(SUBSTR(p_dest_cal, 113, 8)));

-- Extract org_unit_cd
        p_org_unit_cd 			:= NVL(SUBSTR(p_org_unit, 1, 10),'%');

-- Log all the parameters passed. This has been added as part of Bug# 2550392 by shtatiko

  l_start_dt := TO_DATE ( RTRIM(SUBSTR(p_source_cal, 12, 10)), 'DD/MM/YYYY' ) ;
  l_end_dt := TO_DATE ( RTRIM(SUBSTR(p_source_cal, 23, 10)), 'DD/MM/YYYY' );

  fnd_file.put_line ( fnd_file.LOG,  ' ' );
  log_parameters ( p_c_param_name  => igs_ge_gen_004.GENP_GET_LOOKUP ( 'IGS_PS_LOG_PARAMETERS', 'SOURCE_CAL' ),
                   p_c_param_value => TO_CHAR ( l_start_dt, 'DD-MON-YYYY' ) || ' - ' ||
		                      TO_CHAR ( l_end_dt, 'DD-MON-YYYY' ) || ' - ' ||
				      p_source_cal_type );

  l_start_dt := TO_DATE ( RTRIM(SUBSTR(p_dest_cal, 12, 10)), 'DD/MM/YYYY' ) ;
  l_end_dt := TO_DATE ( RTRIM(SUBSTR(p_dest_cal, 23, 10)), 'DD/MM/YYYY' );

  log_parameters ( p_c_param_name  => igs_ge_gen_004.GENP_GET_LOOKUP ( 'IGS_PS_LOG_PARAMETERS', 'DEST_CAL' ),
                   p_c_param_value => TO_CHAR ( l_start_dt, 'DD-MON-YYYY' ) || ' - ' ||
		                      TO_CHAR ( l_end_dt, 'DD-MON-YYYY' ) || ' - ' ||
				      p_dest_cal_type );
  log_parameters ( p_c_param_name  => igs_ge_gen_004.GENP_GET_LOOKUP ( 'LEGACY_TOKENS', 'ORG_UNIT_CD' ),
                   p_c_param_value => p_org_unit_cd );
  fnd_file.put_line ( fnd_file.LOG,  ' ' );
  fnd_file.put_line ( fnd_file.LOG,  ' ' );

	v_message := NULL;

	-- Can only transfer within the same IGS_CA_TYPE
	IF (p_source_cal_type <> p_dest_cal_type) THEN
		v_message  :='IGS_PS_ROLLOVER_CALINSTANCES';
		RAISE invalid;
	END IF;


	-- Calendar type must exist
	OPEN c_check_cal_type_exist;
	FETCH c_check_cal_type_exist INTO v_check;
	IF (c_check_cal_type_exist%NOTFOUND) THEN
		CLOSE c_check_cal_type_exist;
		v_message := 'IGS_GE_VAL_DOES_NOT_XS';
		RAISE invalid;

	END IF;
	CLOSE c_check_cal_type_exist;
	-- validate the calendar type of IGS_PS_COURSE offering
	IF (IGS_PS_VAL_CO.crsp_val_co_cal_type (
			p_source_cal_type,
			v_message) = FALSE) THEN
		RAISE invalid;
	END IF;
	-- "Source" calendar instance must exist
	OPEN c_check_cal_instance_exist(
			p_source_cal_type,
			p_source_sequence_number);
	FETCH c_check_cal_instance_exist INTO v_check;
	IF (c_check_cal_instance_exist%NOTFOUND) THEN
		CLOSE c_check_cal_instance_exist;
		v_message := 'IGS_PS_SRC_CALINST_NOT_EXIST';
		RAISE invalid;
	END IF;
	CLOSE c_check_cal_instance_exist;
	-- "Destination" calendar instance must exist and fetch start_dt and end_dt
	OPEN c_get_cal_instance_dates(
			p_dest_cal_type,
			p_dest_sequence_number);
	FETCH c_get_cal_instance_dates INTO gv_ci_start_dt, gv_ci_end_dt;
	IF (c_get_cal_instance_dates%NOTFOUND) THEN
		CLOSE c_get_cal_instance_dates;
		v_message := 'IGS_PS_DEST_CAL_INST_NOT_EXIS';
		RAISE invalid;
	END IF;
	CLOSE c_get_cal_instance_dates;
	-- "Destination" calendar must be active
	IF (IGS_as_VAL_uai.crsp_val_crs_ci (
			p_dest_cal_type,
			p_dest_sequence_number,
			v_message) = FALSE) THEN
		RAISE invalid;
	END IF;
	OPEN c_course_offering_instance;
	LOOP
		FETCH c_course_offering_instance INTO v_coi_rec;
		EXIT WHEN c_course_offering_instance%NOTFOUND;

		-- This logging Unit information has been added as part of Bug# 2550392 by shtatiko
                fnd_file.put_line ( fnd_file.LOG, ' ');
		fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'PROGRAM_CD' )
		                                  || '        : ' || v_coi_rec.course_cd );
		fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'VERSION_NUMBER' )
		                                  || ' : ' || TO_CHAR (v_coi_rec.version_number) );
		fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'CAL_TYPE' )
		                                  || '  : ' || p_dest_cal_type );
		fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_FI_LOCKBOX', 'START_DT' )
		                                  || '     : ' || fnd_date.date_to_displaydate (gv_ci_start_dt) );
		fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_FI_LOCKBOX', 'END_DT' )
		                                  || '       : ' || fnd_date.date_to_displaydate (gv_ci_end_dt) );
		fnd_file.put_line ( fnd_file.LOG, ' ');

		-- Check that IGS_PS_COURSE version is still active and can be updated
		IF (IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
				v_coi_rec.course_cd,
				v_coi_rec.version_number,
				v_message) = TRUE) THEN
			OPEN c_check_coi_exist (
					v_coi_rec.course_cd,
					v_coi_rec.version_number);
			FETCH c_check_coi_exist INTO v_check;
			IF (c_check_coi_exist%NOTFOUND) THEN
			IGS_PS_OFR_INST_PKG.Insert_Row(
		        X_ROWID       		      =>	x_rowid,
			X_COURSE_CD                   => 	v_coi_rec.course_cd,
			X_VERSION_NUMBER              =>	v_coi_rec.version_number,
			X_CAL_TYPE                    => 	p_dest_cal_type,
			X_CI_SEQUENCE_NUMBER          => 	p_dest_sequence_number,
			X_CI_START_DT                 => 	gv_ci_start_dt,
			X_CI_END_DT                   => 	gv_ci_end_dt,
			X_MIN_ENTRY_ASS_SCORE         => 	v_coi_rec.min_entry_ass_score,
			X_GUARANTEED_ENTRY_ASS_SCR    =>         v_coi_rec.guaranteed_entry_ass_scr,
			X_MODE                        =>	'R');
      		          v_rec_inserted_cnt := v_rec_inserted_cnt + 1;
                          -- This message has been added as part of Bug# 2550392 by shtatiko
			  fnd_message.set_name ( 'IGS', 'IGS_PS_ROLL_POI_SUCCESS' );
			  fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get );
			ELSE
                          -- This message has been added as part of Bug# 2550392 by shtatiko
			  fnd_message.set_name ( 'IGS', 'IGS_PS_ROLL_POI_EXISTS' );
			  fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get );
			END IF;
			CLOSE c_check_coi_exist;
			-- Rollover all course_offering_patterns
			-- within IGS_PS_OFR_INST.
			IF (IGS_PS_GEN_003.crsp_ins_coi_cop(
					v_coi_rec.course_cd,
					v_coi_rec.version_number,
					p_source_cal_type,
					p_source_sequence_number,
					p_dest_cal_type,
					p_dest_sequence_number,
					v_message) = FALSE) THEN
				-- This function never return FALSE at the moment
				RAISE invalid;
			END IF;

			fnd_message.set_name ( 'IGS', v_message );
			fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get );
			-- no course_offering_patterns rolled over
			IF (v_message = 'IGS_PS_PRGOFFR_ROLLED_EXIST' OR
                            v_message = 'IGS_PS_NO_POP_TOBE_ENROLLED') THEN
				cst_all_cop_rec_inserted := FALSE;
			-- partial course_offering_patterns rolled over
			ELSIF (v_message = 'IGS_PS_PARTIALCREATION_OFFPAT') THEN

				cst_all_cop_rec_inserted := FALSE;
				cst_none_cop_rec_inserted := FALSE;
			-- all course_offering_pattenrs rolled over
			ELSIF (v_message = 'IGS_PS_SUCCESS_CREATION_POP') THEN
				cst_none_cop_rec_inserted := FALSE;
			END IF;
		END IF; -- course_version is active
	END LOOP;
	IF (cst_none_cop_rec_inserted AND NOT cst_all_cop_rec_inserted) OR
	   (cst_all_cop_rec_inserted AND NOT cst_none_cop_rec_inserted) THEN
		cst_partial_cop_rec_inserted := FALSE;
	END IF;
	-- none course_offering_instance is inserted
	IF (v_rec_inserted_cnt = 0) THEN
		cst_none_coi_rec_inserted := TRUE;
	-- all course_offering_instance are inserted
	ELSIF (v_rec_inserted_cnt = c_course_offering_instance%ROWCOUNT) THEN
		cst_all_coi_rec_inserted := TRUE;
	-- partial course_offering_instance are inserted
	ELSE
		cst_partial_coi_rec_inserted := TRUE;
	END IF;
	-- no course_offering_instances AND no course_offering_patterns are inserted
	IF (cst_none_coi_rec_inserted AND cst_none_cop_rec_inserted) THEN
		v_message := 'IGS_PS_NO_PRGOFFR_INST_FOUND';
                              RAISE VALID;
	END IF;
	-- (no coi AND all cop are inserted) OR (partial coi OR partial cop are
	-- inserted)
	IF (cst_none_coi_rec_inserted AND cst_all_cop_rec_inserted) OR
	   (cst_partial_coi_rec_inserted OR cst_partial_cop_rec_inserted) THEN
		v_message := 'IGS_PS_PARTIALCREATION_OFFINS';
                              RAISE VALID;
	END IF;
	-- otherwise: (all coi and all cop are inserted) OR
	--		(all coi and no cop are inserted)
	v_message := 'IGS_PS_SUCCESS_CREAT_POP';
	RAISE VALID;

EXCEPTION
  WHEN VALID THEN
    COMMIT;
    RETCODE:=0;
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, fnd_message.get_string('IGS',v_message) );
  WHEN INVALID THEN
    RETCODE:=2;
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, fnd_message.get_string('IGS',v_message) );
  WHEN OTHERS THEN
    RETCODE:=2;
    ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
    ROLLBACK;
END crsp_ins_ci_cop;


PROCEDURE crsp_ins_cous(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_override_title IN VARCHAR2 ,
  p_only_as_sub_ind IN VARCHAR2 DEFAULT 'N')
AS
lv_param_values			VARCHAR2(1080);
BEGIN	-- crsp_ins_cous
	-- This module inserts a record into the IGS_PS_OFR_UNIT_SET table.
	-- The routine is used by the defaulting mechanism for a IGS_EN_UNIT_SET. This is
	-- invoked from the 'Apply IGS_PS_UNIT Set to IGS_PS_COURSE Offerings' form (ie: CRSF4210)
	-- and applies the unit_set_in context to all IGS_PS_COURSE offerings selected via
	-- the screen.
	-- The routine is not used by the IGS_EN_UNIT_SET rollover process.
DECLARE

	v_administrative_ind		IGS_EN_UNIT_SET.administrative_ind%TYPE;
	v_show_on_official_ntfctn_ind	VARCHAR2(1);
	v_dummy				VARCHAR2(1);
	CURSOR c_cous IS
		SELECT	'X'
		FROM	IGS_PS_OFR_UNIT_SET	cous
		WHERE	cous.course_cd		= p_course_cd AND
			cous.crv_version_number = p_crv_version_number AND
			cous.cal_type		= p_cal_type AND
			cous.unit_set_cd	= p_unit_set_cd AND
			cous.us_version_number	= p_us_version_number;

			x_rowid			VARCHAR2(25);
BEGIN
	-- Fetch the administrative indicator from the IGS_EN_UNIT_SET table
	v_administrative_ind := IGS_PS_GEN_006.crsp_get_us_admin(
						p_unit_set_cd,
						p_us_version_number);
	IF (v_administrative_ind = 'Y') THEN
		v_show_on_official_ntfctn_ind := 'N';
	ELSE
		v_show_on_official_ntfctn_ind := 'Y';
	END IF;
	OPEN c_cous;
	FETCH c_cous INTO v_dummy;
	IF (c_cous%NOTFOUND) THEN
		CLOSE c_cous;

		IGS_PS_OFR_UNIT_SET_Pkg.Insert_Row(
					X_ROWID                       =>	x_rowid,
					X_COURSE_CD                   => 	p_course_cd,
					X_CRV_VERSION_NUMBER          => 	p_crv_version_number,
					X_CAL_TYPE                    => 	p_cal_type,
					X_UNIT_SET_CD                 => 	p_unit_set_cd,
					X_US_VERSION_NUMBER           => 	p_us_version_number,
					X_OVERRIDE_TITLE              => 	p_override_title,
					X_ONLY_AS_SUB_IND             => 	p_only_as_sub_ind,
					X_SHOW_ON_OFFICIAL_NTFCTN_IND => 	v_show_on_official_ntfctn_ind,
					X_MODE                        =>	'R');

					COMMIT;
	ELSE
		CLOSE c_cous;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_cous%ISOPEN) THEN
			CLOSE c_cous;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN

		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_003.crsp_ins_cous');
		IGS_GE_MSG_STACK.ADD;
		lv_param_values := p_course_cd||','||to_char(p_crv_version_number)||','||p_cal_type||','
					||p_unit_set_cd||','||to_char(p_us_version_number)||','||p_override_title||','||p_only_as_sub_ind;
		Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
		Fnd_Message.Set_Token('VALUE',lv_param_values);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_cous;

FUNCTION enrollment_for_uoo_check ( p_n_uoo_id NUMBER) RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     : sarakshi
  Date Created By: 21-oct-2003

  Purpose        : To check if enrollment exists for a unit section, i.e to check if a record exists in IGS_EN_SU_ATTEMPT
                   for the input unit section

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */
CURSOR c_enroll (cp_n_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
  SELECT  'X'
  FROM    igs_en_su_attempt
  WHERE   uoo_id=cp_n_uoo_id
  AND     ROWNUM=1;
  l_c_var    VARCHAR2(1) ;

BEGIN
   --If enrollment exists for a unit section (uoo_id) then return TRUE else FALSE
   OPEN c_enroll(p_n_uoo_id);
   FETCH c_enroll INTO l_c_var;
   IF c_enroll%FOUND THEN
     CLOSE c_enroll;
     RETURN TRUE;
   END IF;
   CLOSE c_enroll;
   RETURN FALSE;

END enrollment_for_uoo_check;

  FUNCTION CheckValid(
		      p_n_uoo_id           NUMBER,
		      p_n_usec_occurs_id   NUMBER,
                      p_c_building_cd      VARCHAR2,
                      p_c_room_cd          VARCHAR2,
		      p_d_start_date       DATE,
		      p_d_end_date         DATE,
		      p_d_start_time       DATE,
		      p_d_end_time         DATE,
		      p_c_monday           VARCHAR2,
		      p_c_tuesday          VARCHAR2,
		      p_c_wednesday        VARCHAR2,
		      p_c_thrusday         VARCHAR2,
		      p_c_friday           VARCHAR2,
		      p_c_saturday         VARCHAR2,
		      p_c_sunday           VARCHAR2,
		      p_called_from        VARCHAR2,
		      p_c_clash_section    OUT NOCOPY VARCHAR2,
		      p_c_clash_occurrence OUT NOCOPY VARCHAR2
		      )
  RETURN BOOLEAN AS
  /***********************************************************************************************

  Created By     : sarakshi
  Date Created By: 17-May-2005

  Purpose        : To check if an occurrence is having a building and Room conflict with other occurrences which
                   are not in same crosslistd/meetwith group.

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
  --sarakshi    29-Sep-2005     Bug#4589117, changed the signature of the function CheckValid and related validation.
  --sarakshi    26-Sep-2005     Bug#4589301, modified the signature of function CheckValid and related processing
  ********************************************************************************************** */


    CURSOR chk IS
    SELECT uso.unit_section_occurrence_id, uso.uoo_id, crs.usec_x_listed_group_id, mwg.class_meet_group_id
    FROM   igs_ps_usec_occurs   uso, igs_ps_usec_x_grpmem crs, igs_ps_uso_clas_meet mwg
    WHERE  uso.building_code  = p_c_building_cd AND
           uso.room_code = p_c_room_cd AND
           (
	     TRUNC( uso.start_date ) BETWEEN TRUNC(p_d_start_date) AND TRUNC(p_d_end_date) OR
	     TRUNC(uso.end_date) BETWEEN TRUNC(p_d_start_date) AND TRUNC(p_d_end_date) OR
	     TRUNC(p_d_start_date) BETWEEN TRUNC(uso.start_date) AND TRUNC(uso.end_date) OR
	     TRUNC(p_d_end_date) BETWEEN TRUNC(uso.start_date) AND TRUNC(uso.end_date)
	   ) AND

	   (
	     (((TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI') BETWEEN TO_DATE(TO_CHAR(p_d_start_time,'HH24:MI'),'HH24:MI') AND TO_DATE(TO_CHAR(p_d_end_time,'HH24:MI'),'HH24:MI')) OR
	      (TO_DATE(TO_CHAR(uso.end_time,'HH24:MI'),'HH24:MI') BETWEEN TO_DATE(TO_CHAR(p_d_start_time,'HH24:MI'),'HH24:MI') AND TO_DATE(TO_CHAR(p_d_end_time,'HH24:MI'),'HH24:MI'))) AND
	     (
	     -- considering boundary conditions as no conflict
	     (TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI') <> TO_DATE(TO_CHAR(p_d_end_time,'HH24:MI'),'HH24:MI')) AND
	     (TO_DATE(TO_CHAR(uso.end_time,'HH24:MI'),'HH24:MI') <> TO_DATE(TO_CHAR(p_d_start_time,'HH24:MI'),'HH24:MI'))))

	     OR

	     (((TO_DATE(TO_CHAR(p_d_start_time,'HH24:MI'),'HH24:MI') BETWEEN TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI') AND TO_DATE(TO_CHAR(uso.end_time,'HH24:MI'),'HH24:MI')) OR
	      (TO_DATE(TO_CHAR(p_d_end_time ,'HH24:MI'),'HH24:MI') BETWEEN TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI') AND TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI'))) AND
	     (
	     -- considering boundary conditions as no conflict
	     (TO_DATE(TO_CHAR(p_d_start_time ,'HH24:MI'),'HH24:MI') <> TO_DATE(TO_CHAR(uso.end_time,'HH24:MI'),'HH24:MI')) AND
	     (TO_DATE(TO_CHAR(p_d_end_time ,'HH24:MI'),'HH24:MI') <> TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI'))))

	   ) AND


           (uso.monday = DECODE (p_c_monday,'Y','Y','-') OR
           uso.tuesday = DECODE (p_c_tuesday,'Y','Y','-') OR
           uso.wednesday = DECODE (p_c_wednesday,'Y','Y','-') OR
           uso.thursday = DECODE (p_c_thrusday,'Y','Y','-') OR
           uso.friday = DECODE (p_c_friday,'Y','Y','-') OR
           uso.saturday = DECODE (p_c_saturday,'Y','Y','-') OR
           uso.sunday = DECODE (p_c_sunday,'Y','Y','-'))  AND
           uso.uoo_id=crs.uoo_id(+) AND
           uso.uoo_id=mwg.uoo_id(+) AND
           uso.unit_section_occurrence_id <> p_n_usec_occurs_id;

     --check if member of cross listed group
     CURSOR chk_crs_list_grp (cp_usec_x_listed_group_id NUMBER) IS
     SELECT 'X'
     FROM  igs_ps_usec_x_grpmem
     WHERE usec_x_listed_group_id = cp_usec_x_listed_group_id
     AND   uoo_id = p_n_uoo_id;

     --check if member of meet with group
     CURSOR chk_meet_with_grp (cp_class_meet_group_id NUMBER) IS
     SELECT 'X'
     FROM  igs_ps_uso_clas_meet
     WHERE class_meet_group_id = cp_class_meet_group_id
     AND   uoo_id = p_n_uoo_id;

     CURSOR c_occur(cp_unit_section_occurrence_id  igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
     SELECT b.occurrence_identifier,a.unit_cd,a.version_number,a.location_cd,a.unit_class,c.alternate_code
     FROM   igs_ps_unit_ofr_opt_all a, igs_ps_usec_occurs_all b, igs_ca_inst_all c
     WHERE  a.uoo_id=b.uoo_id
     AND    b.unit_section_occurrence_id=cp_unit_section_occurrence_id
     AND    a.cal_type=c.cal_type
     AND    a.ci_sequence_number=c.sequence_number;

     l_c_occur c_occur%ROWTYPE;

     l_c_valid  BOOLEAN := TRUE;
     l_c_var   VARCHAR2(1);
  BEGIN
        FOR chk_rec IN chk LOOP
           l_c_valid  := FALSE;

           IF p_called_from='OCCURRENCE' THEN
	     IF chk_rec.usec_x_listed_group_id IS NOT NULL THEN
		OPEN chk_crs_list_grp (chk_rec.usec_x_listed_group_id);
		FETCH chk_crs_list_grp INTO l_c_var;
		IF chk_crs_list_grp%FOUND THEN
		   l_c_valid  := TRUE;
		END IF;
		CLOSE chk_crs_list_grp;
	     END IF;

	     IF chk_rec.class_meet_group_id IS NOT NULL THEN
		OPEN chk_meet_with_grp (chk_rec.class_meet_group_id);
		FETCH chk_meet_with_grp INTO l_c_var;
		IF chk_meet_with_grp%FOUND THEN
		   l_c_valid  := TRUE;
		END IF;
		CLOSE chk_meet_with_grp;
	     END IF;
           END IF;

           IF NOT l_c_valid THEN
              OPEN c_occur(chk_rec.unit_section_occurrence_id);
	      FETCH c_occur INTO l_c_occur;
	      CLOSE c_occur;
	      p_c_clash_section:='"'||l_c_occur.unit_cd||'-'||l_c_occur.version_number||'-'||l_c_occur.alternate_code||'-'||l_c_occur.location_cd||'-'||l_c_occur.unit_class||'"';
	      p_c_clash_occurrence:='"'||l_c_occur.occurrence_identifier||'"';
              EXIT;
           END IF;

        END LOOP;

        IF l_c_valid  THEN
          RETURN TRUE;
	ELSE
	  RETURN FALSE;
        END IF;

  END CheckValid;


END IGS_PS_GEN_003;

/
