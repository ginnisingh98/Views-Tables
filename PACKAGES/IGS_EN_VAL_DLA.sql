--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_DLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_DLA" AUTHID CURRENT_USER AS
/* $Header: IGSEN32S.pls 115.4 2002/11/28 23:57:07 nsidana ship $ */
  --
  -- Validate the calendar instance status has a system status of Active.
  FUNCTION stap_val_ci_status(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (stap_val_ci_status,WNDS);
  --
  -- Validate the DLA calendar instance status is ACTIVE or PLANNED
  FUNCTION enrp_val_dla_status(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_dla_status,WNDS);
  --
  -- Validate the DLA calendar type s_cal_cat = 'LOAD' and closed_ind
  FUNCTION enrp_val_dla_cat_ld(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_dla_cat_ld,WNDS);
  --
  -- Validate the DLA calendar type s_cal_cat = 'TEACHING' and closed_ind
  FUNCTION enrp_val_dla_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_dla_cat,WNDS);
END IGS_EN_VAL_DLA;

 

/
