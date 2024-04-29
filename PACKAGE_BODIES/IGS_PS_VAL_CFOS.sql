--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CFOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CFOS" AS
/* $Header: IGSPS19B.pls 120.1 2006/07/25 15:08:32 sommukhe noship $ */

  --
  -- Validate the IGS_PS_COURSE field of study.
  FUNCTION crsp_val_cfos_fos(
  p_field_of_study IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_FLD_OF_STUDY.closed_ind%TYPE;
  	CURSOR	c_field_of_study IS
  		SELECT closed_ind
  		FROM   IGS_PS_FLD_OF_STUDY
  		WHERE  field_of_study = p_field_of_study;
  BEGIN
  	OPEN c_field_of_study;
  	FETCH c_field_of_study INTO v_closed_ind;
  	IF c_field_of_study%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_field_of_study;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_field_of_study;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_FIELD_OF_STUDY_CLOSED';
  		CLOSE c_field_of_study;
  		RETURN FALSE;
  	END IF;
  END crsp_val_cfos_fos;
  --
  -- Validate IGS_PS_COURSE field of study percentage for the IGS_PS_COURSE version.
  FUNCTION crsp_val_cfos_perc(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
-- who      when          What
--sarakshi  23-dec-2002   Bug#2689625,removed the when other part of the exception
--skpandey  10-Jul-2006   Bug#5343912,Modified cursor gc_percent and the code logic.
  	gv_course_f_o_s		CHAR;
  	gv_course_status	IGS_PS_STAT.s_course_status%TYPE;
  	CURSOR	gc_course_status IS
  		SELECT	CS.s_course_status
  		FROM	IGS_PS_VER CV,
  			IGS_PS_STAT CS
  		WHERE	CV.course_cd = p_course_cd AND
  			CV.version_number = p_version_number AND
  			CV.course_status = CS.course_status;
  	CURSOR	gc_course_f_o_s_exists IS
  		SELECT	'x'
  		FROM	IGS_PS_FIELD_STUDY
  		WHERE	course_cd = p_course_cd AND
  			version_number = p_version_number;

	CURSOR gc_percent(cp_course_cd igs_ps_field_study.course_cd%TYPE,
	                  cp_version_number igs_ps_field_study.version_number%TYPE )IS
		  	SELECT	NVL(SUM(percentage),0) sum_per,fos_type_code
		  	FROM	IGS_PS_FIELD_STUDY_V
		  	WHERE  FOS_TYPE_CODE <> 'CIP'
			AND	course_cd = cp_course_cd
			AND version_number = cp_version_number
			GROUP BY  fos_type_code
			HAVING Sum(percentage) <>100;
       gv_percent gc_percent%ROWTYPE;



  BEGIN
  	-- finding the s_course_status
  	OPEN  gc_course_status;
  	FETCH gc_course_status INTO gv_course_status;
  	-- finding IGS_PS_FIELD_STUDY records
  	OPEN  gc_course_f_o_s_exists;
  	FETCH gc_course_f_o_s_exists INTO gv_course_f_o_s;
  	-- Find the sum of all percentages
  	-- when the percentage totals 100
	OPEN gc_percent(p_course_cd,p_version_number);
	FETCH gc_percent INTO gv_percent;
	IF gc_percent%NOTFOUND THEN
		CLOSE gc_percent;
		CLOSE gc_course_f_o_s_exists;
  		CLOSE gc_course_status;
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		-- when the percentage doesn't total 100 and
  		-- when the IGS_PS_STAT.s_unit_status is PLANNED
  		-- and no IGS_PS_FIELD_STUDY records exist
  		IF (gv_course_status = 'PLANNED' AND gc_course_f_o_s_exists%NOTFOUND) THEN
  			CLOSE gc_percent;
			CLOSE gc_course_status;
  			CLOSE gc_course_f_o_s_exists;
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			-- when the percentage doesn't total 100 and
  			-- when the IGS_PS_STAT.s_unit_status is not PLANNED
  			-- or IGS_PS_FIELD_STUDY records exist
  			CLOSE gc_percent;
			CLOSE gc_course_status;
  			CLOSE gc_course_f_o_s_exists;
  			p_message_name := 'IGS_PS_PRCALLOC_PRGFOS_100';
  			RETURN FALSE;
  		END IF;
  	END IF;

  END crsp_val_cfos_perc;
  --
  -- Validate IGS_PS_COURSE field of study major indicator.
  FUNCTION crsp_val_cfos_major(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
-- who      when          What
--sarakshi  23-dec-2002   Bug#2689625,removed the when other part of the exception
--skpandey  10-Jul-2006   Bug#5343912, Modified cursor c_course_field_of_study and the code logic.
  BEGIN
  DECLARE
--  	v_course_field_of_study_rec	IGS_PS_FIELD_STUDY%ROWTYPE;
  	v_course_status			IGS_PS_STAT.s_course_status%TYPE;
  	v_count_records			NUMBER;
  	CURSOR	c_course_status IS
  		SELECT	CS.s_course_status
  		FROM	IGS_PS_VER CV,
  			IGS_PS_STAT CS
  		WHERE	CV.course_cd = p_course_cd AND
  			CV.version_number = p_version_number AND
  			CV.course_status = CS.course_status;

	CURSOR	c_course_field_of_study (cp_course_cd igs_ps_field_study.course_cd%TYPE,
	                  cp_version_number igs_ps_field_study.version_number%TYPE )IS
  		SELECT fos_type_code
		FROM IGS_PS_FIELD_STUDY_V out_fos
		WHERE FOS_TYPE_Code <> 'CIP'
		AND course_cd = cp_course_cd
		AND version_number = cp_version_number
		AND NOT EXISTS( SELECT in_fos.FOS_TYPE_Code
				FROM IGS_PS_FIELD_STUDY_V in_fos
				WHERE in_fos.FOS_TYPE_Code = out_fos.FOS_TYPE_Code
				AND in_fos.course_cd = out_fos.course_cd
				AND in_fos.version_number = out_fos.version_number
				AND major_field_ind = 'Y'
				GROUP BY in_fos.FOS_TYPE_Code
				HAVING Count(major_field_ind) = 1);
       v_course_field_of_study_rec	c_course_field_of_study%ROWTYPE;

    CURSOR c_count_records IS
	  	SELECT  count(*)
	  	FROM	IGS_PS_FIELD_STUDY
	  	WHERE	course_cd = p_course_cd AND
  		version_number = p_version_number;
  BEGIN
  	-- finding the s_course_status
  	OPEN  c_course_status;
  	FETCH c_course_status INTO v_course_status;
  	-- counting all IGS_PS_FIELD_STUDY records
  	-- based on the course_cd and version_number
	OPEN c_count_records;
	FETCH c_count_records INTO v_count_records;
	IF c_count_records%NOTFOUND THEN
		RAISE no_data_found;
	END IF;
	CLOSE c_count_records;
  	-- selecting IGS_PS_FIELD_STUDY records based on course_cd,
  	-- version_number and major_field_ind
   	OPEN c_course_field_of_study(p_course_cd,p_version_number);
  	FETCH c_course_field_of_study INTO v_course_field_of_study_rec;
	IF c_course_field_of_study%NOTFOUND THEN


  	-- when exactly one IGS_PS_FIELD_STUDY
  	-- record is selected with a major_field_ind = 'Y'
          CLOSE c_course_status;
  	  CLOSE c_course_field_of_study;
  	  p_message_name := NULL;
  	  RETURN TRUE;
  	ELSE
  		-- when no records are selected for the given IGS_PS_VER
  		-- and the IGS_PS_STAT.s_unit_status is PLANNED
  		IF (v_course_status = 'PLANNED' AND v_count_records = 0) THEN
  			CLOSE c_course_status;
  			CLOSE c_course_field_of_study;
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			-- when none/more than one IGS_PS_FIELD_STUDY
  			-- record is selected for the given IGS_PS_VER with a
  			-- major_field_ind = 'Y' and the IGS_PS_STAT.s_unit_status
  			-- is not PLANNED
  			CLOSE c_course_status;
  			CLOSE c_course_field_of_study;
  			p_message_name := 'IGS_PS_ONLYONE_FOS_MAJORPRG';
  			return FALSE;
  		END IF;
  	END IF;
  EXCEPTION
  WHEN no_data_found THEN
  	IF c_count_records%ISOPEN THEN
		CLOSE c_count_records;
			App_Exception.Raise_Exception;
	END IF;
  END;
  END crsp_val_cfos_major;
  --
  -- Cross-table validation on IGS_PS_COURSE field of study and IGS_PS_COURSE IGS_PS_AWD.
  FUNCTION crsp_val_cfos_caw(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              :
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smvk     03-Jun-2003   Bug # 2858436. Modified the cursor c_get_cnt_course_award_rec to select open program awards only.
   ***************************************************************/

  	v_cnt_field_of_study_rec	NUMBER(5);
  	v_cnt_course_award_rec	NUMBER(5);
  	CURSOR c_get_cnt_field_of_study_rec IS
  		SELECT	count(*)
  		FROM	IGS_PS_FIELD_STUDY
  		WHERE	course_cd	= p_course_cd		AND
  			version_number	= p_version_number;
  	CURSOR c_get_cnt_course_award_rec IS
  		SELECT	count(*)
  		FROM	IGS_PS_AWARD
  		WHERE	course_cd	= p_course_cd		AND
  			version_number	= p_version_number      AND
                        closed_ind = 'N' ;
  BEGIN
  	OPEN c_get_cnt_field_of_study_rec;
  	FETCH c_get_cnt_field_of_study_rec INTO v_cnt_field_of_study_rec;
  	CLOSE c_get_cnt_field_of_study_rec;
  	OPEN c_get_cnt_course_award_rec;
  	FETCH c_get_cnt_course_award_rec INTO v_cnt_course_award_rec;
  	CLOSE c_get_cnt_course_award_rec;
  	-- Multiple fields of study should only exist for combined
  	-- degree IGS_PS_COURSE.
  	IF (v_cnt_field_of_study_rec > 1) AND (v_cnt_course_award_rec <= 1) THEN
  		p_message_name := 'IGS_PS_MULTIPLE_FOS_EXIST';
  		RETURN FALSE;
  	END IF;
  	-- Combined degree IGS_PS_COURSE is identified by multiple IGS_PS_AWDs
  	-- for the IGS_PS_COURSE
  	IF (v_cnt_course_award_rec > 1) AND (v_cnt_field_of_study_rec <= 1) THEN
  		p_message_name := 'IGS_PS_COMB_DEGREEPRG_FOS';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
END crsp_val_cfos_caw;
END IGS_PS_VAL_CFOS;

/
