--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_OSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_OSE" AS
/* $Header: IGSAD64B.pls 115.3 2002/11/28 21:38:19 nsidana ship $ */

  --
  -- Validate the Overseas Scndry Education Qualification closed indicator.
  FUNCTION ADMP_VAL_OSEQ_CLOSED(
  p_os_scndry_edu_qualification IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_oseq_closed
  	-- Validate if IGS_AD_OS_SEC_EDU.os_scndry_edu_qualification is closed.
  DECLARE
  	v_oseq_closed_exist	VARCHAR2(1);
  	CURSOR c_oseq_closed IS
  		SELECT	'x'
  		FROM	IGS_AD_OS_SEC_EDU_QF	oseq
  		WHERE	oseq.os_scndry_edu_qualification=p_os_scndry_edu_qualification AND
  			closed_ind			= 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_oseq_closed;
  	FETCH c_oseq_closed INTO v_oseq_closed_exist;
  	IF c_oseq_closed%FOUND THEN
  		CLOSE c_oseq_closed;
		p_message_name := 'IGS_AD_OVERSEAS_EDU_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_oseq_closed;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_oseq_closed%ISOPEN THEN
  			CLOSE c_oseq_closed;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_OSE.admp_val_oseq_closed');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_oseq_closed;
  --
  -- Validate the Overseas Scndry Education Qualification Country Code.
  FUNCTION ADMP_VAL_OSE_QCNTRY(
  p_os_scndry_edu_qualification IN VARCHAR2 ,
  p_country_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_ose_qcntry
  	-- Validate that the IGS_AD_OS_SEC_EDU_QF.country_cd is the same as the
  	-- IGS_AD_OS_SEC_EDU.country_cd or that the
  	-- IGS_AD_OS_SEC_EDU_QF.country_cd is null.
  DECLARE
  	v_country_cd		IGS_AD_OS_SEC_EDU_QF.country_cd%TYPE;
  	CURSOR c_oseq IS
  		SELECT	COUNTRY_CD
  		FROM	IGS_AD_OS_SEC_EDU_QF
  		WHERE 	os_scndry_edu_qualification = p_os_scndry_edu_qualification;
  BEGIN
  	p_message_name := null;
  	IF (p_os_scndry_edu_qualification IS NOT NULL) THEN
  		OPEN c_oseq;
  		FETCH c_oseq INTO v_country_cd;
  		CLOSE c_oseq;
  		IF (v_country_cd IS NOT NULL) THEN
  			IF (v_country_cd <> p_country_cd) THEN
				p_message_name := 'IGS_AD_OVERSEAS_EDU_COUNTCD';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_OSE.admp_val_ose_qcntry');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_ose_qcntry;
END IGS_AD_VAL_OSE;

/
