--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_SEOCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_SEOCC" AS
/* $Header: IGSRE14B.pls 115.3 2002/11/29 03:29:59 nsidana ship $ */
  --
  -- Validate whether govt_seo_class_cd exists for another record
  FUNCTION resp_val_scc_gscc(
  p_govt_seo_class_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_scc_gscc
  	-- This module validates whether a IGS_RE_SEO_CLASS_CD record currently exists
  	-- with a govt_seo_class_cd = p_govt_seo_class_cd
  DECLARE
  	v_count		NUMBER;
  	CURSOR	c_scc IS
  		SELECT	COUNT(govt_seo_class_cd)
  		FROM	IGS_RE_SEO_CLASS_CD
  		WHERE	govt_seo_class_cd	= p_govt_seo_class_cd AND
  			closed_ind		= 'N';
  BEGIN
  	p_message_name := NULL;
  	OPEN c_scc;
  	FETCH c_scc INTO v_count;
  	CLOSE c_scc;
  	IF v_count > 0 THEN
  		p_message_name := 'IGS_RE_SOCIO_ECON_OBJECT_MAPP';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_scc%ISOPEN THEN
  			CLOSE c_scc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_scc_gscc;
  --
  -- Validate if Government Socio-Economic Classification Code is closed.
  FUNCTION resp_val_gscc_closed(
  p_govt_seo_class_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_gscc_closed
  	-- Validate if IGS_RE_GV_SEO_CLS_CD.govt_seo_class_cd is closed.
  DECLARE
  	v_gscc_rec		VARCHAR2(1);
  	CURSOR	c_gscc IS
  		SELECT 	'X'
  		FROM	IGS_RE_GV_SEO_CLS_CD
  		WHERE 	govt_seo_class_cd = p_govt_seo_class_cd AND
  			closed_ind = 'Y';
  BEGIN
  	p_message_name := NULL;
  	OPEN c_gscc;
  	FETCH c_gscc INTO v_gscc_rec;
  	IF (c_gscc%FOUND)  THEN
  		CLOSE c_gscc;
  		p_message_name := 'IGS_RE_GOV_OBJ_CLASS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gscc;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_gscc_closed;
END IGS_RE_VAL_SEOCC;

/
