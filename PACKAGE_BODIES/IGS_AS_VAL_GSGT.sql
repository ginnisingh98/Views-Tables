--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_GSGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_GSGT" AS
/* $Header: IGSAS25B.pls 115.4 2002/11/28 22:45:45 nsidana ship $ */

  --

  -- Validate grade may not be translated against another grade in same ver
  FUNCTION assp_val_gsgt_gs_gs(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_to_grading_schema_cd IN VARCHAR2 ,
  p_to_version_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_gsgt_gs_gs
   	-- This module validates that a grade may not be translated against another
  	-- grade within the same version of the grading schema. It also provides a
  	-- warning if it is translated against the same grading schema but a
  	-- different version number.
  DECLARE
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_grading_schema_cd = p_to_grading_schema_cd THEN
  		IF p_version_number = p_to_version_number THEN
  			p_message_name := 'IGS_AS_GRD_NOT_TRANSLATED';
  			RETURN FALSE;
  		ELSE --version numbers are different
  			p_message_name := 'IGS_AS_TRANS_GRD_ANOTHER_GRD';
  			RETURN TRUE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSGT.assp_val_gs_cur_fut');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
  END assp_val_gsgt_gs_gs;
  --
  -- Validate grade may not be translated against more than 1 grade
  FUNCTION assp_val_gsgt_multi(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_to_grading_schema_cd IN VARCHAR2 ,
  p_to_version_number IN NUMBER ,
  p_to_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_gsgt_multi
  DECLARE
  	v_gsgt_exists		VARCHAR2(1);
  	CURSOR c_gsgt IS
  		SELECT 'x'
  		FROM IGS_AS_GRD_SCH_TRN gsgt
  		WHERE	gsgt.grading_schema_cd		= p_grading_schema_cd AND
  			gsgt.version_number		= p_version_number AND
  			gsgt.grade			= p_grade AND
  			gsgt.to_grading_schema_cd	= p_to_grading_schema_cd AND
  			gsgt.to_version_number 		= p_to_version_number AND
  			gsgt.to_grade 			<> p_to_grade;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	--ie; Do not validate against record being passed in
  	OPEN c_gsgt ;
  	FETCH c_gsgt INTO v_gsgt_exists;
  	IF c_gsgt %FOUND THEN
  		CLOSE c_gsgt;
  		p_message_name :='IGS_AS_GRD_MUSTBE_TRANSLATED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gsgt ;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gsgt %ISOPEN THEN
  			CLOSE c_gsgt;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSGT.assp_val_gsgt_multi');
	       IGS_GE_MSG_STACK.ADD;
       	       App_Exception.Raise_Exception;
  END assp_val_gsgt_multi;
  --
  -- Validate rslt type for grade is same as rslt type for xlation grade
  FUNCTION assp_val_gsgt_result(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_to_grading_schema_cd IN VARCHAR2 ,
  p_to_version_number IN NUMBER ,
  p_to_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_gsgt_result
  DECLARE
  	v_gsg_s_result_type		IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  	v_gsg_s_result_type_to		IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--2. Main Body
  	v_gsg_s_result_type := IGS_AS_GEN_002.ASSP_GET_GSG_RESULT(
  						p_grading_schema_cd,
  						p_version_number,
  						p_grade);
  	v_gsg_s_result_type_to := IGS_AS_GEN_002.ASSP_GET_GSG_RESULT(
  						p_to_grading_schema_cd,
  						p_to_version_number,
  						p_to_grade);
  	IF v_gsg_s_result_type <> v_gsg_s_result_type_to THEN
  		p_message_name := 'IGS_AS_FROM_TO_GRADES_SYS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSGT.assp_val_gsgt_multi');
	       IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END assp_val_gsgt_result;
  --
  -- Validate is SUAO exist when changing/deleting translations
  FUNCTION assp_val_gsgt_suao(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_to_grading_schema_cd IN VARCHAR2 ,
  p_to_version_number IN NUMBER ,
  p_to_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_gsgt_suao
  DECLARE
  	v_suao_exists		VARCHAR2(1);
  	CURSOR c_suao IS
  		SELECT	'x'
  		FROM	IGS_AS_SU_STMPTOUT	suao
  		WHERE	suao.grading_schema_cd			= p_grading_schema_cd		AND
  			suao.version_number			= p_version_number		AND
  			suao.grade				= p_grade			AND
  			suao.translated_grading_schema_cd	= p_to_grading_schema_cd	AND
  			suao.translated_version_number		= p_to_version_number		AND
  			suao.translated_grade			= p_to_grade			AND
  			suao.finalised_outcome_ind		= 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--2. Main Body
  	OPEN c_suao;
  	FETCH c_suao INTO v_suao_exists;
  	IF c_suao%FOUND THEN
  		CLOSE c_suao;
  		p_message_name := 'IGS_AS_FINAL_SUA_OUTCOMES';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_suao;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_suao%ISOPEN THEN
  			CLOSE c_suao;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSGT.assp_val_gsgt_suao');
	       IGS_GE_MSG_STACK.ADD;
       	      App_Exception.Raise_Exception;
  END assp_val_gsgt_suao;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
END IGS_AS_VAL_GSGT;

/
