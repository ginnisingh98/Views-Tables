--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_CAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_CAT" AUTHID CURRENT_USER AS
/* $Header: IGSCA04S.pls 115.3 2002/11/28 22:57:05 nsidana ship $ */
  -- Validate when System Calendar Category is changed.
  FUNCTION calp_val_sys_cal_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(calp_val_sys_cal_cat, WNDS);
--
  -- Validate if ARTS teaching calendar type code is closed.
  FUNCTION calp_val_atctc_clsd(
  p_arts_teaching_cal_type_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(calp_val_atctc_clsd, WNDS);
--
  -- Validate Calendar Type ARTS Teaching Code.
  FUNCTION calp_val_cat_arts_cd(
  p_s_cal_cat IN VARCHAR2 ,
  p_arts_teaching_cal_type_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(calp_val_cat_arts_cd, WNDS);
END IGS_CA_VAL_CAT;

 

/
