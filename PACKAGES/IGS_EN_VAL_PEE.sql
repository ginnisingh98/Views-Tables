--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PEE" AUTHID CURRENT_USER AS
/* $Header: IGSEN53S.pls 115.4 2002/11/29 00:03:12 nsidana ship $ */

  -- Validate the cp restriction on the person exclusion effect table.
  FUNCTION enrp_val_pee_crs_cp(
  p_person_id IN NUMBER ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES( enrp_val_pee_crs_cp , WNDS);
  --
  -- Validate the att type on the person exclusion effect table.
  FUNCTION enrp_val_pee_crs_att(
  p_person_id IN NUMBER ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES( enrp_val_pee_crs_att , WNDS);
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_encmb_dts
  --
  -- Validate that person doesn't already have a matching encumb effect.
  FUNCTION enrp_val_pee_chk(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES( enrp_val_pee_chk , WNDS);
  --
  --
  -- Validate that person doesn't already have an open encumbrance effect.
  FUNCTION enrp_val_pee_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES( enrp_val_pee_open , WNDS);
  --
  -- Validate the COURSE code on the person exclusion effect table.
  FUNCTION enrp_val_pee_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES( enrp_val_pee_crs , WNDS);
  --
  -- Validate whether or not a person is enrolled in any COURSE.
  FUNCTION enrp_val_pee_sca(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(  enrp_val_pee_crs, WNDS);
  --
  -- Validate person is enrolled for encumbrance purposes
  FUNCTION enrp_val_pee_enrol(
  p_person_id IN NUMBER ,
  p_effect_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES( enrp_val_pee_enrol , WNDS);
  --
  -- Validate the encumbrance effect COURSE code
  FUNCTION enrp_val_pee_crs_cd(
  p_effect_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(  enrp_val_pee_crs_cd, WNDS);
  --
  -- Validate the encumbrance effect restricted credit points
  FUNCTION enrp_val_pee_rstr_cp(
  p_effect_type IN VARCHAR2 ,
  p_restricted_enrolment_cp IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES( enrp_val_pee_rstr_cp , WNDS);
  --
  -- Validate the encumbrance effect attendance type
  FUNCTION enrp_val_pee_rstr_at(
  p_effect_type IN VARCHAR2 ,
  p_restricted_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(  enrp_val_pee_rstr_at, WNDS);
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dts
  --
  -- Validate the attendance type closed indicator.
  FUNCTION enrp_val_att_closed(
  p_attend_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(  enrp_val_att_closed, WNDS);
  --
END IGS_EN_VAL_PEE;

 

/
