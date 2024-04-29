--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_CI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_CI" AUTHID CURRENT_USER AS
/* $Header: IGSCA05S.pls 115.4 2002/11/28 22:57:21 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- Validate if calendar status is closed.
  FUNCTION calp_val_cs_closed(
  p_cal_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES(calp_val_cs_closed, WNDS);
 --
  -- To validate calendar instance alternate code
  FUNCTION calp_val_ci_alt_cd(
  p_cal_type IN VARCHAR2 ,
  p_alternate_code IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
 PRAGMA RESTRICT_REFERENCES(calp_val_ci_alt_cd, WNDS);
 --
  -- To validate a change of calendar instance
  FUNCTION calp_val_ci_status(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER DEFAULT NULL,
  p_old_cal_status IN VARCHAR2 ,
  p_new_cal_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  PRAGMA RESTRICT_REFERENCES(calp_val_ci_status, WNDS);
--
  -- To validate columns on insert or update of calendar instance.
  FUNCTION calp_val_ci_upd(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER DEFAULT NULL,
  p_alternate_code IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
END IGS_CA_VAL_CI;

 

/
