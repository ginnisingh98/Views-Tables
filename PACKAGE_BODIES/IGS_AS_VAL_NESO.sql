--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_NESO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_NESO" AS
/* $Header: IGSAS26B.pls 115.6 2002/11/28 22:45:58 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function orgp_val_loc_closed removed
  -------------------------------------------------------------------------------------------

  -- Validate the insert of a IGS_AS_NON_ENR_STDOT record
  FUNCTION ASSP_VAL_NESO_INS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_mark IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_grading_schema_cd IN VARCHAR2,
  p_gs_version_number IN NUMBER,
  p_s_grade_creation_method_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_closed_ind		IGS_LOOKUPS_VIEW.closed_ind%type;
  	s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%type;
  	v_person_id		IGS_EN_STDNT_PS_ATT.person_id%TYPE;
  	CURSOR c_sgcmt IS
  		SELECT	sgcmt.closed_ind
  		FROM	IGS_LOOKUPS_VIEW sgcmt
  		WHERE	sgcmt.LOOKUP_TYPE = p_s_grade_creation_method_type;
  	CURSOR c_uv IS
  		SELECT	us.s_unit_status
  		FROM	IGS_PS_UNIT_VER uv,
  			IGS_PS_UNIT_STAT us
  		WHERE	uv.unit_cd = p_unit_cd AND
  			uv.version_number = p_version_number AND
  			us.UNIT_STATUS = uv.UNIT_STATUS;
  	CURSOR c_sca IS
  		SELECT	sca.person_id
  		FROM 	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id;
  	CURSOR c_sca2 IS
  		SELECT	sca.person_id
  		FROM 	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd;
  BEGIN
  	-- Validate the insert of a IGS_AS_NON_ENR_STDOT record.
  	-- Checks for:
  	-- cannot be added against a closed s_grade_creation_method_type
  	-- one of mark or grade must be set
  	-- cannot be added against IGS_PS_UNIT_VER with a system status of
  	-- other than 'ACTIVE'.
  	-- Person id must have at least one student course attempt of any status.
  	--- Set the default message number
  	p_message_name := null;
  	IF (p_mark IS NULL) AND (p_grade IS NULL) THEN
  		p_message_name := 'IGS_AS_MARK_OR_GRD_MUSTBE_SET';
  		RETURN FALSE;
  	END IF;
  	OPEN c_sgcmt;
  	FETCH c_sgcmt INTO v_closed_ind;
  	IF (c_sgcmt%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AS_CANNOT_ADD_OUTCOME';
  			CLOSE c_sgcmt;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_sgcmt;
  	OPEN c_uv;
  	FETCH c_uv INTO s_unit_status;
  	IF (c_uv%NOTFOUND) THEN
  		CLOSE c_uv;
  		RETURN TRUE;
  	ELSE
  		IF (s_unit_status <> 'ACTIVE') THEN
  			p_message_name := 'IGS_AS_CANNOT_ADD_NONENR';
  			CLOSE c_uv;
  			RETURN FALSE;
  		ELSE
  			CLOSE c_uv;
  		END IF;
  	END IF;
  	-- 4. Check that Person has a course attempt
  	OPEN c_sca;
  	FETCH c_sca INTO v_person_id;
  	IF (c_sca%NOTFOUND) THEN
  		CLOSE c_sca;
  		p_message_name := 'IGS_AS_PRSN_ONE_PRG_ATTEMPT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sca;
  	-- 5. If the course code has been specified, check that
  	-- the student actually has a course attempt for the course.
  	IF (p_course_cd IS NOT NULL) THEN
  		OPEN c_sca2;
  		FETCH c_sca2 INTO v_person_id;
  		IF (c_sca2%NOTFOUND) THEN
  			CLOSE c_sca2;
  			p_message_name := 'IGS_AS_STUD_PRG_ATTEMPT';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_sca2;
  	END IF;
        -- 6. validate that the marks and grade are as per grd sch
        IF NOT (IGS_AS_VAL_SUAO.ASSP_VAL_MARK_GRADE(
                           p_mark => p_mark,
                           p_grade => p_grade,
                           p_grading_schema_cd => p_grading_schema_cd,
                           p_version_number => p_gs_version_number,
                           p_message_name => p_message_name)) THEN
               RETURN FALSE;
        END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_NESO.assp_val_neso_ins');
	       IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END assp_val_neso_ins;
END IGS_AS_VAL_NESO;

/
