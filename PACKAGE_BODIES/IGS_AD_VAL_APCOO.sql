--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_APCOO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_APCOO" AS
/* $Header: IGSAD40B.pls 115.7 2002/11/28 21:31:44 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Added Pragma to function "crsp_val_att_closed"
  -------------------------------------------------------------------------------------------

  -- Validate admission period course offering option course offering.

FUNCTION admp_val_apcoo_co(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  	--admp_val_apcoo_co
  	-- Routine to verify that the course offering is
  	-- valid for the admission period.
  DECLARE
  	v_record_found		BOOLEAN DEFAULT FALSE;
  	v_adm_cat_valid		BOOLEAN DEFAULT FALSE;
  	v_crv_valid 		BOOLEAN DEFAULT FALSE;
  	v_message_name		VARCHAR2(30);
  	CURSOR 	c_cop IS
  	SELECT	cop.course_cd,
  		cop.version_number,
  		cop.cal_type,
  		cop.location_cd,
  		cop.attendance_mode,
  		cop.attendance_type
  	FROM	IGS_CA_INST_REL	cir,
  		IGS_PS_OFR_PAT		cop
  	WHERE	cir.sub_cal_type		= p_adm_cal_type		AND
  		cir.sub_ci_sequence_number	= p_adm_ci_sequence_number	AND
  		cir.sup_cal_type		= p_acad_cal_type 		AND
  		cop.course_cd			= p_course_cd			AND
  		cop.version_number		= p_crv_version_number		AND
  		cop.offered_ind			= 'Y'				AND
  		cop.entry_point_ind		= 'Y'				AND
  		cop.cal_type			= cir.sup_cal_type		AND
  		cop.ci_sequence_number		= cir.sup_ci_sequence_number;
  	r_cop_rec	c_cop%ROWTYPE;
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	-- Check if at least one course offering pattern exists
  	-- for the admission period.
  	FOR v_cop_rec IN c_cop LOOP
  		v_record_found := TRUE;
  		-- For the first record determine if the course version is valid.
  		IF (c_cop%ROWCOUNT = 1) THEN
  			IF (IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_crv(
  					v_cop_rec.course_cd,
  					v_cop_rec.version_number,
  					p_s_admission_process_type,
  					'N',
  					v_message_name) = TRUE) THEN
  				v_crv_valid := TRUE;
  			ELSE
  				EXIT;
  			END IF;
  		END IF;
  		-- For each record determine if course offering is valid for
  		-- the admission category
  		IF (IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_adm_cat(
  				v_cop_rec.course_cd,
  				v_cop_rec.version_number,
  				v_cop_rec.cal_type,
  				v_cop_rec.location_cd,
  				v_cop_rec.attendance_mode,
  				v_cop_rec.attendance_type,
  				p_admission_cat,
  				v_message_name) = TRUE) THEN
  			v_adm_cat_valid := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF (v_record_found = FALSE) THEN
  		-- There are no course offering patterns being offered for
  		-- this IGS_PS_COURSE version in this commencement period.
  		p_message_name := 'IGS_AD_NO_PRGOFOP_ENTRYPOINT';
  		Return FALSE;
  	END IF;
  	IF (v_crv_valid = FALSE) THEN
  		-- This course version is being offered in the commencement period but
  		-- is either inactive, or is not valid for the Admission Period Admission
  		-- Process Type.
  		p_message_name := 'IGS_AD_PRGVER_OFR_COMPRD';
  		RETURN FALSE;
  	END IF;
  	IF (v_adm_cat_valid = FALSE) THEN
  		-- None of the course offering patterns being offered for this course
  		-- version in this commencement period have mappings to the Admission
  		-- Period Admission Category.
  		p_message_name := 'IGS_AD_NONE_PRGOFOP_COMPERIOD';
  		RETURN FALSE;
  	END IF;
  	-- Return the no error
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOO.admp_val_apcoo_co');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcoo_co;

 -- Validate the attendance type closed indicator.
   FUNCTION crsp_val_att_closed(
   p_attendance_type IN VARCHAR2 ,
   p_message_name OUT NOCOPY VARCHAR2 )
   RETURN BOOLEAN IS
   BEGIN
   DECLARE
   	v_other_detail		VARCHAR2(255);
   	v_closed_ind		IGS_EN_ATD_TYPE.closed_ind%TYPE;
   	CURSOR c_ci IS
   		SELECT	closed_ind
   		FROM	IGS_EN_ATD_TYPE
   		WHERE	attendance_type = p_attendance_type;
   BEGIN
   	-- Validates attendance type closed indicator.
   	p_message_name := Null;
   	OPEN	c_ci;
   	FETCH	c_ci	into	v_closed_ind;
   	IF (c_ci%NOTFOUND) THEN
   		CLOSE c_ci;
   		p_message_name := Null;
   		RETURN TRUE;
   	END IF;
   	IF (v_closed_ind = 'Y') THEN
   		CLOSE c_ci;
   		p_message_name := 'IGS_PS_ATTEND_TYPE_CLOSED';
   		RETURN FALSE;
   	END IF;
   	CLOSE c_ci;
   	--- Return the default value
   	p_message_name := Null;
   	RETURN TRUE;
   EXCEPTION
   	WHEN OTHERS THEN
 	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
 	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOO.crsp_val_att_closed');
-- 	    IGS_GE_MSG_STACK.ADD;
-- 	    App_Exception.Raise_Exception;
   END;
   END CRSP_VAL_ATT_CLOSED;
   --

--
  -- Validate admission period IGS_PS_COURSE offering option optional links.
  FUNCTION admp_val_apcoo_links(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN	-- admp_val_apcoo_links
  	-- Validates that the links to the location, attendance_mode and
  	--  IGS_EN_ATD_TYPE tables when inserting or updating an admission period
  	-- IGS_PS_COURSE offering option record  to avoid
  	-- conflicting or duplicate course offering option components.
  DECLARE
  	v_message_name	VARCHAR2(30);
  	CURSOR c_apcoo (
  			cp_adm_cal_type IGS_AD_PRD_PS_OF_OPT.adm_cal_type%TYPE,
  			cp_adm_ci_sequence_number
  				 IGS_AD_PRD_PS_OF_OPT.adm_ci_sequence_number%TYPE,
  			cp_admission_cat IGS_AD_PRD_PS_OF_OPT.admission_cat%TYPE,
  			cp_s_admission_process_type
  				 IGS_AD_PRD_PS_OF_OPT.s_admission_process_type%TYPE,
  			cp_course_cd IGS_AD_PRD_PS_OF_OPT.course_cd%TYPE,
  			cp_version_number IGS_AD_PRD_PS_OF_OPT.version_number%TYPE,
  			cp_acad_cal_type IGS_AD_PRD_PS_OF_OPT.acad_cal_type%TYPE,
  			cp_sequence_number IGS_AD_PRD_PS_OF_OPT.sequence_number%TYPE) IS
  		SELECT	apcoo.location_cd,
  			apcoo.attendance_mode,
  			apcoo.attendance_type
  		FROM	IGS_AD_PRD_PS_OF_OPT apcoo
  		WHERE	apcoo.adm_cal_type	= cp_adm_cal_type AND
  			apcoo.adm_ci_sequence_number = cp_adm_ci_sequence_number AND
  			apcoo.admission_cat	= cp_admission_cat AND
  			apcoo.s_admission_process_type = cp_s_admission_process_type AND
  			apcoo.course_cd		=  cp_course_cd AND
  			apcoo.version_number	=  cp_version_number AND
  			apcoo.acad_cal_type	=  cp_acad_cal_type AND
  			apcoo.sequence_number	<> cp_sequence_number;
  BEGIN
  	p_message_name := Null;
  	FOR v_apcoo_rec IN c_apcoo(
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				p_admission_cat,
  				p_s_admission_process_type,
  				p_course_cd,
  				p_version_number,
  				p_acad_cal_type,
  				p_sequence_number) LOOP
  		-- Validate parameter linkages against the selected record's linkages
  		IF(IGS_AD_VAL_APCOO.genp_val_optnl_coo(
  					p_location_cd,
  					p_attendance_mode,
  					p_attendance_type,
  					v_apcoo_rec.location_cd,
  					v_apcoo_rec.attendance_mode,
  					v_apcoo_rec.attendance_type,
  					v_message_name) = FALSE) THEN
  			IF(v_message_name = 'IGS_AS_SPECIFIED_LINK_CONFLIC') THEN
  				p_message_name := 'IGS_AD_LINKCONFLICT_ADMPRD';
  			ELSIF(v_message_name = 'IGS_GE_RECORD_ALREADY_EXISTS') THEN
  				p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			ELSIF(v_message_name = 'IGS_GE_RECORD_ALREADY_EXISTS') THEN
  				p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			ELSIF(v_message_name = 'IGS_AS_REC_INS_UPD_MORE_LINKS') THEN
  				p_message_name := 'IGS_AD_ADMPRD_PRGOFOP_INSUPD';
  			END IF;
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOO.admp_val_apcoo_links');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcoo_links;
  --
  -- Insert admission period course offering options
  FUNCTION admp_ins_dflt_apcoo(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- ADMP_INS_DFLT_APCOO
  	-- Routine to insert admission period course offering options.
  	-- This will be fired from the form when defining an admission
  	-- period for an admission category and process type.
  DECLARE
  	CURSOR c_apcoo(
  		cp_adm_cal_type			IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE,
  		cp_adm_ci_sequence_number  	IGS_AD_PRD_AD_PRC_CA.adm_ci_sequence_number%TYPE,
  		cp_admission_cat		      IGS_AD_PRD_AD_PRC_CA.admission_cat%TYPE,
  		cp_s_admission_process_type 	IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%TYPE) IS
  		SELECT  'x'
  		FROM    IGS_AD_PRD_PS_OF_OPT
  		WHERE   adm_cal_type 		= cp_adm_cal_type AND
  			adm_ci_sequence_number 	= cp_adm_ci_sequence_number AND
  			admission_cat	= cp_admission_cat AND
  			s_admission_process_type 	= cp_s_admission_process_type;
  	v_apc_exists        c_apcoo%ROWTYPE;
  	CURSOR c_acov(
  		cp_adm_cal_type			IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE,
  		cp_adm_ci_sequence_number     IGS_AD_PRD_AD_PRC_CA.adm_ci_sequence_number%TYPE) IS
  		SELECT DISTINCT	acov.course_cd,
  				      acov.version_number,
  				      acov.acad_cal_type
  		FROM    	IGS_PS_OFR_PAT_APCOO_V acov
  		WHERE	acov.adm_cal_type 	= cp_adm_cal_type AND
  			acov.adm_ci_sequence_number = cp_adm_ci_sequence_number AND
  			acov.admission_cat = p_admission_cat AND
  			acov.s_admission_process_type = p_s_admission_process_type AND
  			( IGS_AD_GEN_013.ADMS_GET_COO_CRV(
  					acov.course_cd,
  					acov.version_number,
  					p_s_admission_process_type,
  					'N') = 'Y' );
  	v_acov_rec		c_acov%ROWTYPE;
  	v_course_cd       IGS_PS_OFR_PAT.course_cd%TYPE DEFAULT NULL;
  	v_version_number 	IGS_PS_OFR_PAT.version_number%TYPE DEFAULT NULL;
  	v_cal_type      	IGS_PS_OFR_PAT.cal_type%TYPE DEFAULT NULL;
      v_rowid           VARCHAR2(25);
      v_sequence_number NUMBER(6);
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- Check that an adm_perd-course_off_option does not already exist
  	OPEN c_apcoo(
  		p_adm_cal_type,
  		p_adm_ci_sequence_number,
  		p_admission_cat,
  		p_s_admission_process_type);
  	FETCH c_apcoo INTO v_apc_exists;
  	IF c_apcoo%FOUND THEN
  		CLOSE c_apcoo;
  		p_message_name := 'IGS_AD_CAN_ONLY_DFLT_PRG_OFOP';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_apcoo;
  	FOR v_acov_rec IN c_acov(
  			p_adm_cal_type,
  			p_adm_ci_sequence_number) LOOP

                  select IGS_AD_PRD_PS_OF_OPT_SEQ_NUM_S.NEXTVAL into
                  v_sequence_number
                  from dual;

           IGS_AD_PRD_PS_OF_OPT_PKG.INSERT_ROW(
              X_ROWID => v_rowid,
              X_ADM_CAL_TYPE => p_adm_cal_type,
              X_ADM_CI_SEQUENCE_NUMBER => p_adm_ci_sequence_number,
              X_ADMISSION_CAT => p_admission_cat,
              X_S_ADMISSION_PROCESS_TYPE => p_s_admission_process_type,
              X_COURSE_CD => v_acov_rec.course_cd,
              X_VERSION_NUMBER => v_acov_rec.version_number,
              X_ACAD_CAL_TYPE => v_acov_rec.acad_cal_type,
              X_SEQUENCE_NUMBER => v_sequence_number,
              X_LOCATION_CD  => NULL,
              X_ATTENDANCE_MODE => NULL,
              X_ATTENDANCE_TYPE => NULL,
              X_ROLLOVER_INCLUSION_IND => 'Y',
              X_MODE => 'R');

  	END LOOP;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOO.admp_ins_dflt_apcoo');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END ADMP_INS_DFLT_APCOO;
  --
  -- Validate course offering option optional links.
  FUNCTION genp_val_optnl_coo(
  p_new_location_cd IN VARCHAR2 ,
  p_new_attendance_mode IN VARCHAR2 ,
  p_new_attendance_type IN VARCHAR2 ,
  p_db_location_cd IN VARCHAR2 ,
  p_db_attendance_mode IN VARCHAR2 ,
  p_db_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- genp_val_optnl_coo
  	-- Common routine to validate the optional links to the location,
  	--  attendance mode  and attendance type in tables where the
  	-- IGS_PS_OFR_OPT components are
  	-- made optional to cater for data volumes and the course code being the key
  	-- component. This routine detects conflicting or duplicate records.
  DECLARE
  	v_message_name 		VARCHAR2(30) := Null;
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- Validating 'N N N' parameters
  	IF (p_new_location_cd IS NULL) AND
  		 (p_new_attendance_mode IS NULL) AND
  		 (p_new_attendance_type IS NULL) THEN
  			IF (p_db_location_cd IS NULL AND
  					p_db_attendance_mode IS NULL AND
  					p_db_attendance_type IS NULL) THEN
  				v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			ELSE
  				v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			END IF;
  	END IF;
  	-- Validating 'N N Y' parameters
  	IF ((p_new_location_cd IS NULL)AND
  		 (p_new_attendance_mode IS NULL) AND
  		 (p_new_attendance_type IS NOT NULL)) THEN
  		IF (p_db_attendance_type IS NULL) THEN
  			IF (p_db_attendance_mode IS NULL) THEN
  				IF (p_db_location_cd IS NULL) THEN
  					v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  				ELSE
  					v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  				END IF;
  			ELSE
  				v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  			END IF;
  		ELSE
  			IF p_db_attendance_type = p_new_attendance_type THEN
  				IF (p_db_location_cd IS NULL AND
  						p_db_attendance_mode IS NULL) THEN
  					v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  				ELSE
  					v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  				END IF;
  			END IF;
  		END IF;
  	END IF;
  	-- Validating 'N Y N' parameters
  	IF (p_new_location_cd IS NULL)AND
  		 (p_new_attendance_mode IS NOT NULL) AND
  		 (p_new_attendance_type IS NULL) THEN
  		IF (p_db_attendance_mode IS NULL) THEN
  			IF  (p_db_attendance_type IS NULL) THEN
  				IF (p_db_location_cd IS NULL) THEN
  					v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  				ELSE
  					v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  				END IF;
  			ELSE
  				v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  			END IF;
  		ELSE
  			IF  (p_db_attendance_mode = p_new_attendance_mode) THEN
  				IF  (p_db_location_cd IS NULL AND
  						p_db_attendance_type IS NULL) THEN
  					v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  				ELSE
  					v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  				END IF;
  			END IF;
  		END IF;
  	END IF;
  	-- Validating 'N Y Y' parameters
  	IF (p_new_location_cd IS NULL)AND
  		 (p_new_attendance_mode IS NOT NULL) AND
  		 (p_new_attendance_type IS NOT NULL) THEN
  		IF (p_db_attendance_mode IS NULL) THEN
  			IF (p_db_attendance_type IS NULL) THEN
  				IF (p_db_location_cd IS NULL) THEN
  					v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  				ELSE
  					v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  				END IF;
  			ELSE
  				IF (p_db_attendance_type = p_new_attendance_type) THEN
  					v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  				END IF;
  			END IF;
  		ELSE
  			IF (p_db_attendance_mode = p_new_attendance_mode) THEN
  				IF (p_db_attendance_type IS NULL) THEN
  					IF (p_db_location_cd IS NULL) THEN
  						v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  					ELSE
  						v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  					END IF;
  				ELSE
  					IF p_db_attendance_type = p_new_attendance_type THEN
  						IF p_db_location_cd IS NULL THEN
  							v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  					ELSE
  							v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  						END IF;
  					END IF;
  				END IF;
  			END IF;
  		END IF;
  	END IF;
  	-- Validating 'Y N N' parameters
  	IF (p_new_location_cd IS NOT NULL)AND
  		 (p_new_attendance_mode IS NULL) AND
  		 (p_new_attendance_type IS NULL) THEN
  		IF (p_db_location_cd IS NULL) THEN
  			IF (p_db_attendance_mode IS NULL AND
  				p_db_attendance_type IS NULL) THEN
  					v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  			ELSE
  					v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  			END IF;
  		ELSE
  			IF (p_db_location_cd = p_new_location_cd) THEN
  				IF (p_db_attendance_mode IS NULL AND
  						p_db_attendance_type IS NULL) THEN
  					v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  				ELSE
  					v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  				END IF;
  			END IF;
  		END IF;
  	END IF;
  	-- Validating ?Y N Y? parameters
  	IF (p_new_location_cd IS NOT NULL)AND
  		 (p_new_attendance_mode IS NULL) AND
  		 (p_new_attendance_type IS NOT NULL) THEN
  		IF p_db_attendance_mode IS NULL THEN
  			IF p_db_location_cd IS NULL AND
  					p_db_attendance_type IS NULL THEN
  				v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  			END IF;
  			IF (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_type IS NULL) OR
  		  	   (p_db_attendance_type = p_new_attendance_type AND
  					p_db_location_cd IS NULL) THEN
  				v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  			END IF;
  			IF  (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_type = p_new_attendance_type) THEN
  				v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			END IF;
  		ELSE
  			IF  (p_db_location_cd IS NULL AND
  					p_db_attendance_type IS NULL) THEN
  				v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  			END IF;
  			IF  (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_type IS NULL) OR
  		    	    (p_db_attendance_type = p_new_attendance_type AND
  					p_db_location_cd IS NULL) THEN
  				v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  			END IF;
  			IF  (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_type = p_new_attendance_type) THEN
  				v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			END IF;
  		END IF;
  	END IF;
  	-- Validating ?Y Y N? parameters (ie; att parameter is null)
  	IF (p_new_location_cd IS NOT NULL)AND
  		 (p_new_attendance_mode IS NOT NULL) AND
  		 (p_new_attendance_type IS NULL) THEN
  		IF (p_db_attendance_type IS NULL) THEN
  			IF (p_db_location_cd IS NULL AND
  				p_db_attendance_mode IS NULL)THEN
  					v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  			END IF;
  			IF  (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_mode IS NULL) OR
       			    (p_db_attendance_mode = p_new_attendance_mode AND
  					p_db_location_cd IS NULL) THEN
  				v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  			END IF;
  			IF  (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_mode = p_new_attendance_mode) THEN
  				v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			END IF;
  		ELSE
  			IF  (p_db_location_cd IS NULL AND
  					p_db_attendance_mode IS NULL) OR
  			    (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_mode is null) OR
   			    (p_db_attendance_mode = p_new_attendance_mode AND
  					p_db_location_cd IS NULL) THEN
  				v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  			END IF;
  			IF  (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_mode = p_new_attendance_mode) THEN
  				v_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			END IF;
  		END IF;
  	END IF;
  	-- Validating ?Y Y Y? parameters (ie; no parameters are null)
  	IF (p_new_location_cd IS NOT NULL)AND
  		 (p_new_attendance_mode IS NOT NULL) AND
  		 (p_new_attendance_type IS NOT NULL) THEN
  		IF (p_db_attendance_type IS NULL) THEN
  			IF (p_db_location_cd IS NULL AND
  					p_db_attendance_mode IS NULL) OR
  			   (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_mode IS NULL) OR
       			   (p_db_attendance_mode = p_new_attendance_mode AND
  					p_db_location_cd IS NULL) THEN
  				v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  			END IF;
  			IF  (p_db_location_cd = p_new_location_cd AND
  					p_db_attendance_mode = p_new_attendance_mode) THEN
  				v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  			END IF;
  		ELSE
  			IF (p_db_attendance_type = p_new_attendance_type) THEN
  				IF  (p_db_location_cd IS NULL AND
  						p_db_attendance_mode IS NULL) OR
  				    (p_db_location_cd = p_new_location_cd AND
  						p_db_attendance_mode IS NULL) OR
       				    (p_db_attendance_mode = p_new_attendance_mode AND
  						p_db_location_cd IS NULL) THEN
  					v_message_name := 'IGS_AS_REC_INS_UPD_MORE_LINKS';
  				END IF;
  				IF  (p_db_location_cd = p_new_location_cd AND
  						p_db_attendance_mode = p_new_attendance_mode) THEN
  					v_message_name := 'IGS_AS_SPECIFIED_LINK_CONFLIC';
  				END IF;
  			END IF;
  		END IF;
  	END IF;
  	IF (v_message_name <> Null) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOO.genp_val_optnl_coo');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END genp_val_optnl_coo;
  --

  -- Validate the attendance mode closed indicator.
  FUNCTION crsp_val_am_closed(
  p_attendance_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- crsp_val_am_closed
  	-- Validate if IGS_EN_ATD_MODE.attendance_mod is closed.
  DECLARE
  	v_closed_ind	IGS_EN_ATD_MODE.closed_ind%TYPE;
  	v_ret_val	BOOLEAN	DEFAULT TRUE;
  	CURSOR	c_am IS
  		SELECT	closed_ind
  		FROM	IGS_EN_ATD_MODE
  		WHERE	attendance_mode = p_attendance_mode;
  BEGIN
  	p_message_name := Null;
  	OPEN c_am;
  	FETCH c_am INTO v_closed_ind;
  	IF (c_am%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_PS_ATTEND_MODE_CLOSED';
  			v_ret_val := FALSE;
  		END IF;
  	END IF;
  	CLOSE c_am;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOO.crsp_val_am_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END crsp_val_am_closed;
  --
  -- Validate the admission period course offering option details.
  FUNCTION admp_val_apcoo_opt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
     	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_apcoo_opt
  	-- Validate the admission period course offering option details
  DECLARE
          v_location_cd	        IGS_PS_OFR_PAT.location_cd%TYPE;
          v_attendance_mode	IGS_PS_OFR_PAT.attendance_mode%TYPE;
          v_attendance_type       IGS_PS_OFR_PAT.attendance_type%TYPE;
          v_message_name           varchar2(30);
  	CURSOR	c_acov IS
  		SELECT	location_cd,
                 		attendance_mode,
         			attendance_type
  		FROM	IGS_PS_OFR_PAT_APCOO_V
  		WHERE	course_cd                   = p_course_cd AND
  			version_number              = p_version_number AND
  			acad_cal_type         	    = p_acad_cal_type AND
  			adm_cal_type		    = p_adm_cal_type AND
  			adm_ci_sequence_number      = p_adm_ci_sequence_number AND
  			admission_cat		    = p_admission_cat AND
  			s_admission_process_type    = p_s_admission_process_type AND
  			(IGS_AD_GEN_013.ADMS_GET_COO_CRV(
  				course_cd,
  				version_number,
  				s_admission_process_type,
  				'N') = 'Y') AND
  			(IGS_AD_GEN_013.ADMS_GET_COO_ADM_CAT (
  				course_cd,
  				version_number,
  				acad_cal_type,
  				location_cd,
  				attendance_mode,
  				attendance_type,
  				admission_cat) = 'Y') AND
  			(p_location_cd IS NULL OR
  			location_cd		= p_location_cd) AND
  			(p_attendance_mode IS NULL OR
  			attendance_mode		= p_attendance_mode) AND
  			(p_attendance_type IS NULL OR
  			attendance_type 		= p_attendance_type);
  BEGIN
  	p_message_name := Null;
  	IF (p_location_cd IS NOT NULL OR
  			p_attendance_mode IS NOT NULL OR
  			p_attendance_type IS NOT NULL) THEN
  		OPEN c_acov;
  		FETCH c_acov INTO		v_location_cd,
  					v_attendance_mode,
  					v_attendance_type;
  		IF (c_acov%NOTFOUND) THEN
  			CLOSE c_acov;
  			p_message_name := 'IGS_AD_NOPOO_NOTSPECFY_PRG';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_acov;
  	END IF;
          RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOO.admp_val_apcoo_opt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcoo_opt;

END IGS_AD_VAL_APCOO;

/
