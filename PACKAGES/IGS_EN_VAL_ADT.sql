--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_ADT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_ADT" AUTHID CURRENT_USER AS
/* $Header: IGSEN22S.pls 115.3 2002/11/28 23:54:34 nsidana ship $ */

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
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_adt_corr,WNDS);
  --
  -- Validate the address type postcode and overseas code optionality
  FUNCTION enrp_val_adt_codes(
  p_line6_dis_ind IN VARCHAR2 DEFAULT 'N',
  p_line7_dis_ind IN VARCHAR2 DEFAULT 'N',
  p_line6_opt_ind IN VARCHAR2 DEFAULT 'N',
  p_line7_opt_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_adt_codes,WNDS);
END IGS_EN_VAL_ADT;

 

/
