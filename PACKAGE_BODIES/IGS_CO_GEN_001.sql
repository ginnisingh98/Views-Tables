--------------------------------------------------------
--  DDL for Package Body IGS_CO_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_GEN_001" AS
/* $Header: IGSCO01B.pls 115.5 2002/11/28 23:03:31 nsidana ship $ */
FUNCTION CORP_GET_COR_CAT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 DEFAULT null)
RETURN VARCHAR2 AS
BEGIN
DECLARE
	CURSOR c_student_course_attempt(
			cp_person_id	IGS_EN_STDNT_PS_ATT.person_id%TYPE,
			cp_course_cd	IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
	SELECT	CORRESPONDENCE_CAT
	FROM	IGS_EN_STDNT_PS_ATT
	WHERE	person_id = cp_person_id
	AND	course_cd = cp_course_cd;
	v_correspondence_cat	IGS_EN_STDNT_PS_ATT.CORRESPONDENCE_CAT%TYPE;
	BEGIN
		IF NVL(p_course_cd, ' ') = ' ' THEN
			RETURN NULL;
		END IF;
		OPEN	c_student_course_attempt(p_person_id,
					p_course_cd);
		LOOP
			FETCH	c_student_course_attempt 	INTO	v_correspondence_cat;
			IF (c_student_course_attempt%NOTFOUND) THEN
				CLOSE c_student_course_attempt;
				RETURN NULL;
			END IF;
			CLOSE c_student_course_attempt;
			RETURN v_correspondence_cat;
		END LOOP;
	END;
END corp_get_cor_cat;
--
FUNCTION corp_get_let_title(
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER )
RETURN VARCHAR2 AS
BEGIN	-- corp_get_let_title
	-- This module retrieves the letter IGS_PE_TITLE for a system letter
DECLARE
	v_letter_title		IGS_CO_S_LTR.letter_title%TYPE;
	CURSOR c_sl IS
	SELECT	sl.letter_title
	FROM 	IGS_CO_S_LTR	sl
	WHERE	sl.CORRESPONDENCE_TYPE		= p_correspondence_type
	AND	sl.letter_reference_number	= p_letter_reference_number;
BEGIN
	-- Set initial value
	v_letter_title := NULL;
	OPEN c_sl;
	FETCH c_sl INTO v_letter_title;
	CLOSE c_sl;
	RETURN v_letter_title;
EXCEPTION
	WHEN OTHERS THEN
		IF c_sl%ISOPEN THEN
			CLOSE c_sl;
		END IF;
		RAISE;
END;
END corp_get_let_title;
--
FUNCTION corp_get_ocr_refnum(
  p_s_other_reference_type IN VARCHAR2 ,
  p_other_reference IN VARCHAR2 )
RETURN NUMBER AS
BEGIN	--corp_get_ocr_refnum
	--This module retrieves the reference number for an
	--IGS_CO_OU_CO_REF record based on passed parameters
DECLARE
	v_ocr_cnt		NUMBER(1) DEFAULT 0;
	v_reference_number	IGS_CO_OU_CO_REF.reference_number%TYPE;
	CURSOR c_ocr IS
	SELECT	ocr.reference_number
	FROM	IGS_CO_OU_CO_REF	ocr
	WHERE	ocr.S_OTHER_REFERENCE_TYPE	= p_s_other_reference_type
	AND	ocr.other_reference		= p_other_reference;
BEGIN
	--validate parameters
	IF (p_s_other_reference_type IS NULL OR
   			p_other_reference IS NULL) THEN
		RETURN NULL;
	END IF;
	FOR v_ocr_rec IN c_ocr LOOP
		v_ocr_cnt := v_ocr_cnt + 1;
		v_reference_number := v_ocr_rec.reference_number;
		IF (v_ocr_cnt > 1) THEN
			EXIT;
		END IF;
	END LOOP;
	IF (v_ocr_cnt <> 1) THEN
		RETURN NULL;
	END IF;
	RETURN v_reference_number;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_ocr%ISOPEN) THEN
			CLOSE c_ocr;
		END IF;
		RAISE;
END;
END corp_get_ocr_refnum;
--
PROCEDURE corp_get_ocv_details(
  p_person_id IN OUT NOCOPY IGS_CO_OU_CO_V.person_id%TYPE ,
  p_correspondence_type IN OUT NOCOPY IGS_CO_OU_CO_V.CORRESPONDENCE_TYPE%TYPE ,
  p_cal_type IN OUT NOCOPY IGS_CO_OU_CO_V.CAL_TYPE%TYPE ,
  p_ci_sequence_number IN OUT NOCOPY IGS_CO_OU_CO_V.ci_sequence_number%TYPE ,
  p_course_cd IN OUT NOCOPY IGS_CO_OU_CO_V.course_cd%TYPE ,
  p_cv_version_number IN OUT NOCOPY IGS_CO_OU_CO_V.cv_version_number%TYPE ,
  p_unit_cd IN OUT NOCOPY IGS_CO_OU_CO_V.unit_cd%TYPE ,
  p_uv_version_number IN OUT NOCOPY IGS_CO_OU_CO_V.uv_version_number%TYPE ,
  p_s_other_reference_type IN OUT NOCOPY IGS_CO_OU_CO_V.S_OTHER_REFERENCE_TYPE%TYPE ,
  p_other_reference IN OUT NOCOPY IGS_CO_OU_CO_V.other_reference%TYPE ,
  p_addr_type IN OUT NOCOPY IGS_CO_OU_CO_V.ADDR_TYPE%TYPE ,
  p_tracking_id IN OUT NOCOPY IGS_CO_OU_CO_V.tracking_id%TYPE ,
  p_request_num IN OUT NOCOPY IGS_CO_OU_CO_V.request_num%TYPE ,
  p_s_job_name IN OUT NOCOPY IGS_CO_OU_CO_V.s_job_name%TYPE ,
  p_request_job_id IN OUT NOCOPY IGS_CO_OU_CO_V.request_job_id%TYPE ,
  p_request_job_run_id IN OUT NOCOPY IGS_CO_OU_CO_V.request_job_run_id%TYPE ,
  p_correspondence_cat OUT NOCOPY IGS_CO_OU_CO_V.CORRESPONDENCE_CAT%TYPE ,
  p_reference_number OUT NOCOPY IGS_CO_OU_CO_V.reference_number%TYPE ,
  p_issue_dt OUT NOCOPY IGS_CO_OU_CO_V.issue_dt%TYPE ,
  p_dt_sent OUT NOCOPY IGS_CO_OU_CO_V.dt_sent%TYPE ,
  p_unknown_return_dt OUT NOCOPY IGS_CO_OU_CO_V.unknown_return_dt%TYPE ,
  p_adt_description OUT NOCOPY IGS_CO_OU_CO_V.adt_description%TYPE ,
  p_create_dt OUT NOCOPY IGS_CO_OU_CO_V.create_dt%TYPE ,
  p_originator_person_id OUT NOCOPY IGS_CO_OU_CO_V.originator_person_id%TYPE ,
  p_output_num OUT NOCOPY IGS_CO_OU_CO_V.output_num%TYPE ,
  p_oc_comments OUT NOCOPY IGS_CO_OU_CO_V.oc_comments%TYPE ,
  p_cori_comments OUT NOCOPY IGS_CO_OU_CO_V.cori_comments%TYPE ,
  p_message_name OUT NOCOPY varchar2)
AS
BEGIN	-- corp_get_ocv_details
	-- This module gets information from the latest record in the outgoing
	-- correspondence view for a set of variable parameters.
DECLARE
	CURSOR c_ocv IS
		SELECT	person_id,
			CORRESPONDENCE_TYPE,
			CAL_TYPE,
			ci_sequence_number,
			course_cd,
			cv_version_number,
			unit_cd,
			uv_version_number,
			S_OTHER_REFERENCE_TYPE,
			other_reference,
			ADDR_TYPE,
			tracking_id,
			request_num,
			s_job_name,
			request_job_id,
			request_job_run_id,
			CORRESPONDENCE_CAT,
			reference_number,
			issue_dt,
			dt_sent,
			unknown_return_dt,
			adt_description,
			create_dt,
			originator_person_id,
			output_num,
			oc_comments,
			cori_comments
		FROM	IGS_CO_OU_CO_V
		WHERE	(p_person_id IS NULL OR
			person_id 		= p_person_id) AND
			(p_correspondence_type IS NULL OR
			CORRESPONDENCE_TYPE 	= p_correspondence_type) AND
			(p_cal_type IS NULL OR
			CAL_TYPE 		= p_cal_type) AND
			(p_ci_sequence_number IS NULL OR
			ci_sequence_number 	= p_ci_sequence_number) AND
			(p_course_cd IS NULL OR
			course_cd 		= p_course_cd) AND
			(p_cv_version_number IS NULL OR
			cv_version_number 	= p_cv_version_number) AND
			(p_unit_cd IS NULL OR
			unit_cd 		= p_unit_cd) AND
			(p_uv_version_number IS NULL OR
			uv_version_number 	= p_uv_version_number) AND
			(p_s_other_reference_type IS NULL OR
			S_OTHER_REFERENCE_TYPE 	= p_s_other_reference_type) AND
			(p_other_reference IS NULL OR
			other_reference 	= p_other_reference) AND
			(p_addr_type IS NULL OR
			ADDR_TYPE 		= p_addr_type) AND
			(p_tracking_id IS NULL OR
			tracking_id 		= p_tracking_id) AND
			(p_request_num IS NULL OR
			request_num 		= p_request_num) AND
			(p_s_job_name IS NULL OR
			s_job_name 		= p_s_job_name) AND
			(p_request_job_id IS NULL OR
			request_job_id 		= p_request_job_id) AND
			(p_request_job_run_id IS NULL OR
			request_job_run_id 	= p_request_job_run_id)
		ORDER BY issue_dt DESC,
			reference_number DESC;
	v_ocv_rec 	c_ocv%ROWTYPE;
BEGIN
	-- Set the default message number
	p_message_name   := Null;
	-- Cursor handling
	OPEN c_ocv;
	FETCH c_ocv INTO v_ocv_rec;
	IF c_ocv%NOTFOUND THEN
		CLOSE c_ocv;
		-- Set the out NOCOPY parameters to null
		p_person_id := NULL;
		p_correspondence_type := NULL;
		p_cal_type := NULL;
		p_ci_sequence_number := NULL;
		p_course_cd := NULL;
		p_cv_version_number := NULL;
		p_unit_cd := NULL;
		p_uv_version_number := NULL;
		p_s_other_reference_type := NULL;
		p_other_reference := NULL;
		p_addr_type := NULL;
		p_tracking_id := NULL;
		p_request_num := NULL;
		p_s_job_name := NULL;
		p_request_job_id := NULL;
		p_request_job_run_id := NULL;
		p_correspondence_cat := NULL;
		p_reference_number := NULL;
		p_issue_dt := NULL;
		p_dt_sent := NULL;
		p_unknown_return_dt := NULL;
		p_adt_description := NULL;
		p_create_dt := NULL;
		p_originator_person_id := NULL;
		p_output_num := NULL;
		p_oc_comments := NULL;
		p_cori_comments := NULL;
		p_message_name := 'IGS_AS_OUTGOING_CORREC_NOTFND';
		RETURN;
	END IF;
	CLOSE c_ocv;
	p_person_id := v_ocv_rec.person_id;
	p_correspondence_type := v_ocv_rec.CORRESPONDENCE_TYPE;
	p_cal_type := v_ocv_rec.CAL_TYPE;
	p_ci_sequence_number := v_ocv_rec.ci_sequence_number;
	p_course_cd := v_ocv_rec.course_cd;
	p_cv_version_number := v_ocv_rec.cv_version_number;
	p_unit_cd := v_ocv_rec.unit_cd;
	p_uv_version_number := v_ocv_rec.uv_version_number;
	p_s_other_reference_type := v_ocv_rec.S_OTHER_REFERENCE_TYPE;
	p_other_reference := v_ocv_rec.other_reference;
	p_addr_type := v_ocv_rec.ADDR_TYPE;
	p_tracking_id := v_ocv_rec.tracking_id;
	p_request_num := v_ocv_rec.request_num;
	p_s_job_name := v_ocv_rec.s_job_name;
	p_request_job_id := v_ocv_rec.request_job_id;
	p_request_job_run_id := v_ocv_rec.request_job_run_id;
	p_correspondence_cat := v_ocv_rec.CORRESPONDENCE_CAT;
	p_reference_number := v_ocv_rec.reference_number;
	p_issue_dt := v_ocv_rec.issue_dt;
	p_dt_sent := v_ocv_rec.dt_sent;
	p_unknown_return_dt := v_ocv_rec.unknown_return_dt;
	p_adt_description := v_ocv_rec.adt_description;
	p_create_dt := v_ocv_rec.create_dt;
	p_originator_person_id := v_ocv_rec.originator_person_id;
	p_output_num := v_ocv_rec.output_num;
	p_oc_comments := v_ocv_rec.oc_comments;
	p_cori_comments := v_ocv_rec.cori_comments;
	RETURN;
EXCEPTION
	WHEN OTHERS THEN
		IF c_ocv%ISOPEN THEN
			CLOSE c_ocv;
		END IF;
		RAISE;
END;
END corp_get_ocv_details;
--
FUNCTION cors_get_ocv_issuedt(
  p_person_id IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cv_version_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_s_other_reference_type IN VARCHAR2 ,
  p_other_reference IN VARCHAR2 )
RETURN DATE AS
BEGIN	-- cors_get_ocv_issuedt
	-- This module gets the issue date from the latest record in the
	-- outgoing correspondence view for a set of variable parameters.
DECLARE
	-- Local variables to replace input parameters
	v_person_id		IGS_CO_OU_CO_V.person_id%TYPE;
	v_correspondence_type	IGS_CO_OU_CO_V.CORRESPONDENCE_TYPE%TYPE;
	v_cal_type		IGS_CO_OU_CO_V.CAL_TYPE%TYPE;
	v_ci_sequence_number	IGS_CO_OU_CO_V.ci_sequence_number%TYPE;
	v_course_cd		IGS_CO_OU_CO_V.course_cd%TYPE;
	v_cv_version_number	IGS_CO_OU_CO_V.cv_version_number%TYPE;
	v_unit_cd		IGS_CO_OU_CO_V.unit_cd%TYPE;
	v_uv_version_number	IGS_CO_OU_CO_V.uv_version_number%TYPE;
	v_s_other_reference_type IGS_CO_OU_CO_V.S_OTHER_REFERENCE_TYPE%TYPE;
	v_other_reference	IGS_CO_OU_CO_V.other_reference%TYPE;
	-- Local variables which are set to NULL
	v_addr_type		IGS_CO_OU_CO_V.ADDR_TYPE%TYPE DEFAULT NULL;
	v_tracking_id		IGS_CO_OU_CO_V.tracking_id%TYPE DEFAULT NULL;
	v_request_num		IGS_CO_OU_CO_V.request_num%TYPE DEFAULT NULL;
	v_s_job_name		IGS_CO_OU_CO_V.s_job_name%TYPE DEFAULT NULL;
	v_request_job_id	IGS_CO_OU_CO_V.request_job_id%TYPE DEFAULT NULL;
	v_request_job_run_id	IGS_CO_OU_CO_V.request_job_run_id%TYPE
									DEFAULT NULL;
	-- Local output variables
	v_correspondence_cat	IGS_CO_OU_CO_V.CORRESPONDENCE_CAT%TYPE;
	v_reference_number	IGS_CO_OU_CO_V.reference_number%TYPE;
	v_issue_dt		IGS_CO_OU_CO_V.issue_dt%TYPE;
	v_dt_sent		IGS_CO_OU_CO_V.dt_sent%TYPE;
	v_unknown_return_dt	IGS_CO_OU_CO_V.unknown_return_dt%TYPE;
	v_adt_description	IGS_CO_OU_CO_V.adt_description%TYPE;
	v_create_dt		IGS_CO_OU_CO_V.create_dt%TYPE;
	v_originator_person_id	IGS_CO_OU_CO_V.originator_person_id%TYPE;
	v_output_num		IGS_CO_OU_CO_V.output_num%TYPE;
	v_oc_comments		IGS_CO_OU_CO_V.oc_comments%TYPE;
	v_cori_comments		IGS_CO_OU_CO_V.cori_comments%TYPE;
	v_message_name     varchar2(30);
	v_return		BOOLEAN;
BEGIN
	v_person_id := p_person_id;
	v_correspondence_type := p_correspondence_type;
	v_cal_type := p_cal_type;
	v_ci_sequence_number := p_ci_sequence_number;
	v_course_cd := p_course_cd;
	v_cv_version_number := p_cv_version_number;
	v_unit_cd := p_unit_cd;
	v_uv_version_number := p_uv_version_number;
	v_s_other_reference_type := p_s_other_reference_type;
	v_other_reference := p_other_reference;
	IGS_CO_GEN_001.corp_get_ocv_details(
				v_person_id,
				v_correspondence_type,
				v_cal_type,
				v_ci_sequence_number,
				v_course_cd,
				v_cv_version_number,
				v_unit_cd,
				v_uv_version_number,
				v_s_other_reference_type,
				v_other_reference,
				v_addr_type,
				v_tracking_id,
				v_request_num,
				v_s_job_name,
				v_request_job_id,
				v_request_job_run_id,
				v_correspondence_cat,
				v_reference_number,
				v_issue_dt,
				v_dt_sent,
				v_unknown_return_dt,
				v_adt_description,
				v_create_dt,
				v_originator_person_id,
				v_output_num,
				v_oc_comments,
				v_cori_comments,
				v_message_name);
	IF v_message_name IS NOT NULL THEN
		RETURN NULL;
	END IF;
	RETURN v_issue_dt;
END;
END cors_get_ocv_issuedt;
--
END IGS_CO_GEN_001;

/
