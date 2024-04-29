--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_ADT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_ADT" AS
/* $Header: IGSEN22B.pls 115.3 2002/11/28 23:54:27 nsidana ship $ */

  --
  -- Validate the address type correspondence indicator
  FUNCTION enrp_val_adt_corr(
  p_correspondence_ind IN VARCHAR2 DEFAULT 'N',
  p_line1_mail_ind IN VARCHAR2 DEFAULT 'N',
  p_line2_mail_ind IN VARCHAR2 DEFAULT 'N',
  p_line3_mail_ind IN VARCHAR2 DEFAULT 'N',
  p_line4_mail_ind IN VARCHAR2 DEFAULT 'N',
  p_line5_mail_ind IN VARCHAR2 DEFAULT 'N',
  p_line6_mail_ind IN VARCHAR2 DEFAULT 'N',
  p_line7_mail_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  BEGIN
  	-- If the IGS_CO_ADDR_TYPE.correspondence_ind field has been set,
  	-- then at least one of the first five IGS_CO_ADDR_TYPE.mail_ind fields also needs
  	-- to be set
  	IF (p_correspondence_ind = 'Y') THEN
  		IF     (p_line1_mail_ind  = 'N'	AND
  			p_line2_mail_ind  = 'N' AND
  			p_line3_mail_ind  = 'N' AND
  			p_line4_mail_ind  = 'N' AND
  			p_line5_mail_ind  = 'N') OR
  		         (p_line6_mail_ind = 'N' AND
  			p_line7_mail_ind = 'N')
  		THEN
  			p_message_name := 'IGS_EN_CHK_ADDRESS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_ADT.enrp_val_adt_corr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_adt_corr;
  --
  -- Validate the address type postcode and overseas code optionality
  FUNCTION enrp_val_adt_codes(
  p_line6_dis_ind IN VARCHAR2 DEFAULT 'N',
  p_line7_dis_ind IN VARCHAR2 DEFAULT 'N',
  p_line6_opt_ind IN VARCHAR2 DEFAULT 'N',
  p_line7_opt_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  BEGIN
  	-- If both line6_dis_ind and line7_dis_ind are set,
  	-- then neither line6_opt_ind or line7_opt_ind can be set
  	IF (p_line6_dis_ind = 'Y') AND (p_line7_dis_ind = 'Y') THEN
  		IF (p_line6_opt_ind = 'Y') OR (p_line7_opt_ind = 'Y') THEN
  			p_message_name := 'IGS_EN_CHK_CD_OVRSEAS_CD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_ADT.enrp_val_adt_codes');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_adt_codes;
END IGS_EN_VAL_ADT;

/
