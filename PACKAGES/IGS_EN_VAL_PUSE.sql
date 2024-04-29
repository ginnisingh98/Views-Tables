--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PUSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PUSE" AUTHID CURRENT_USER AS
/* $Header: IGSEN60S.pls 115.4 2002/11/29 00:05:24 nsidana ship $ */
  --
  --
  --
  -- bug id  :  1956374
  -- sjadhav, 28-aug-2001
  -- removed  FUNCTION enrp_val_encmb_dt
  -- removed  FUNCTION enrp_val_encmb_dts
  --
--  gt_rowid_table t_puse_rowids;
  --
  --
--  gt_empty_table t_puse_rowids;
  --
  --
--  gv_table_index BINARY_INTEGER;
  --
  -- Validate if PERSON is enrolled in an excluded UNIT set.
  FUNCTION enrp_val_puse_us(
  p_person_id IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_puse_us , WNDS);
  --
  -- Validate that PERSON doesn't already have an open UNIT set exclusion.
  FUNCTION enrp_val_puse_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_puse_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_puse_open , WNDS);
  --
  -- Validate UNIT set exists
  FUNCTION crsp_val_us_exists(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  crsp_val_us_exists, WNDS);


END IGS_EN_VAL_PUSE;

 

/
