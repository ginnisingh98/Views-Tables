--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SCSR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SCSR" AUTHID CURRENT_USER AS
/* $Header: IGSEN65S.pls 115.4 2002/11/29 00:06:59 nsidana ship $ */
  --
  --
  -- Validate the student course special requirement dates.
  FUNCTION enrp_val_scsr_dates(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_special_requirement_cd IN VARCHAR2 ,
  p_completed_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scsr_dates , WNDS);

  --
  -- Validate the student course special requirement completed date.
  FUNCTION enrp_val_scsr_cmp_dt(
  p_completed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scsr_cmp_dt , WNDS);
  --
  -- Validate the student course special requirement expiry date.
  FUNCTION enrp_val_scsr_exp_dt(
  p_completed_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scsr_exp_dt , WNDS);
  --
  -- Validate the student course special requirement SCA status.
  FUNCTION enrp_val_scsr_scas(
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scsr_scas , WNDS);
  --
  -- Validate the special requirement closed indicator.
  FUNCTION enrp_val_srq_closed(
  p_special_requirement_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_srq_closed, WNDS);
  --

END IGS_EN_VAL_SCSR;

 

/
