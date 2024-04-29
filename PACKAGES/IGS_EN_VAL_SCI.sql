--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SCI" AUTHID CURRENT_USER AS
/* $Header: IGSEN64S.pls 120.1 2005/09/08 16:31:42 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  -------------------------------------------------------------------------------------------
 -- gt_empty_table t_sci_rowid;
  --
  --
  --gt_rowid_table t_sci_rowid;
  --
  --
  --gv_table_index BINARY_INTEGER;
  --
  -- To validate that SCI is possible with students UA's
  FUNCTION ENRP_VAL_SCI_UA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SCI_UA , WNDS);
  --
  -- Validate that intermission is allowed for the student course attempt
  FUNCTION ENRP_VAL_SCI_ALWD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SCI_ALWD, WNDS);
  --
  -- Validate course version of student course intermission.
  FUNCTION ENRP_VAL_SCI_CV_ALWD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SCI_CV_ALWD , WNDS);

  --
  -- Validate whether student course intermission deletion is allowed
  FUNCTION ENRP_VAL_SCI_DEL(
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SCI_DEL, WNDS);
  --
  -- Validate student course intermission duration
  FUNCTION ENRP_VAL_SCI_DRTN(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SCI_DRTN, WNDS);
  --
  -- Validate for overlap of student course intermission records.
  FUNCTION ENRP_VAL_SCI_OVRLP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SCI_OVRLP , WNDS);

END IGS_EN_VAL_SCI;

 

/
