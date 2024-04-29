--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_CSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_CSC" AS
/* $Header: IGSRE07B.pls 115.4 2002/11/29 03:28:14 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .Thed function GENP_VAL_SDTT_SESS removed.
  -------------------------------------------------------------------------------------------
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (RESP_VAL_CA_CHILDUPD) - from the spec and body. -- kdande
*/
  --
  -- Validate IGS_RE_CANDIDATURE socio-economic classification code percentage.
  FUNCTION resp_val_csc_perc(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_csc_perc
  	-- This module validates IGS_RE_CAND_SEO_CLS.percentage. Validations are:
  	-- Total percentage for research IGS_RE_CANDIDATURE must be 100.
  DECLARE
  	v_total_percentage		IGS_RE_CAND_SEO_CLS.percentage%TYPE;
  	CURSOR	c_csc IS
  		SELECT 	NVL(sum(csc.percentage),0)
  		FROM	IGS_RE_CAND_SEO_CLS csc
  		WHERE 	csc.person_id		= p_person_id AND
  			csc.ca_sequence_number 	= p_ca_sequence_number;
  BEGIN
  	p_message_name := null;
  	OPEN c_csc;
  	FETCH c_csc INTO v_total_percentage;
  	CLOSE c_csc;
  	IF v_total_percentage = 0 THEN
  		-- no values for research IGS_RE_CANDIDATURE field of study entered yet
  		RETURN TRUE;
  	ELSIF v_total_percentage <> 100 THEN
  		p_message_name := 'IGS_RE_CAND_SOCIO_ECO_CLASS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_csc%ISOPEN) THEN
  			CLOSE c_csc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_csc_perc;
  --
  -- Validate IGS_RE_CANDIDATURE socio-economic classification code.
  FUNCTION resp_val_csc_seocc(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_seo_class_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_csc_seocc
  	-- Description: This module validate cand_seo_class.seo_class_cd.
  	-- Validations are:
  	-- *IGS_RE_SEO_CLASS_CD is not closed.
  	-- *IGS_RE_GV_SEO_CLS_CD.res_fcd_class_ind is the same for all
  	--  IGS_RE_CAND_SEO_CLS for a research IGS_RE_CANDIDATURE.
  DECLARE
  	CURSOR	c_seocc_gscc IS
  		SELECT	gscc.res_fcd_class_ind
  		FROM	IGS_RE_SEO_CLASS_CD		seocc,
  			IGS_RE_GV_SEO_CLS_CD	gscc
  		WHERE	seocc.seo_class_cd	= p_seo_class_cd AND
  			seocc.govt_seo_class_cd	= gscc.govt_seo_class_cd;
  	v_res_fcd_class_ind		IGS_RE_GV_SEO_CLS_CD.res_fcd_class_ind%TYPE;
  	CURSOR	c_csc_seocc_gscc(
  			cp_res_fcd_class_ind		IGS_RE_GV_SEO_CLS_CD.res_fcd_class_ind%TYPE)IS
  		SELECT	'X'
  		FROM	IGS_RE_CAND_SEO_CLS 		csc,
   			IGS_RE_SEO_CLASS_CD 		seocc,
  			IGS_RE_GV_SEO_CLS_CD 	gscc
  		WHERE	csc.person_id 		= p_person_id AND
  			csc.ca_sequence_number	= p_ca_sequence_number AND
  			csc.seo_class_cd	<>p_seo_class_cd AND
  			csc.seo_class_cd	= seocc.seo_class_cd AND
  			seocc.govt_seo_class_cd	= gscc.govt_seo_class_cd AND
  			gscc.res_fcd_class_ind	<>cp_res_fcd_class_ind;
  	v_dummy_exists		VARCHAR2(1);
  BEGIN
  	p_message_name := null;
  	IF NOT IGS_RE_VAL_CSC.resp_val_seocc_clsd(
  				p_seo_class_cd,
  				p_message_name) THEN
  		RETURN FALSE;
  	END IF;
  	OPEN c_seocc_gscc;
  	FETCH c_seocc_gscc INTO v_res_fcd_class_ind;
  	IF (c_seocc_gscc%NOTFOUND) THEN
  		CLOSE c_seocc_gscc;
  		RETURN TRUE;
  	END IF;
  	OPEN c_csc_seocc_gscc(
  			v_res_fcd_class_ind);
  	FETCH c_csc_seocc_gscc INTO v_dummy_exists;
  	IF (c_csc_seocc_gscc%FOUND) THEN
  		CLOSE c_csc_seocc_gscc;
  		p_message_name := 'IGS_RE_CHK_SOCIO_ECO_CLASSIF';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_seocc_gscc;
  	CLOSE c_csc_seocc_gscc;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_csc_seocc;
  --
  -- Validate if  Socio-Economic Classification Code is closed.
  FUNCTION resp_val_seocc_clsd(
  p_seo_class_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_seocc_clsd
  	-- Description: Validate if seo_class_cd.seo_class_cd is closed.
  DECLARE
  	v_seocc_exists	VARCHAR2(1);
  	CURSOR	c_seocc IS
  		SELECT	'X'
  		FROM	IGS_RE_SEO_CLASS_CD		seocc
  		WHERE	seocc.seo_class_cd 	= p_seo_class_cd AND
  			seocc.closed_ind 	= 'Y';
  BEGIN
  	p_message_name := null;
  	OPEN c_seocc;
  	FETCH c_seocc INTO v_seocc_exists;
  	IF (c_seocc%FOUND) THEN
  		CLOSE c_seocc;
  		p_message_name := 'IGS_RE_SOCIO_ECO_OBJ_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_seocc;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_seocc_clsd;
END IGS_RE_VAL_CSC;

/
