--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PUR" AUTHID CURRENT_USER AS
/* $Header: IGSEN59S.pls 115.4 2002/11/29 00:04:56 nsidana ship $ */
  --

--  gt_rowid_table t_pur_rowids;
  --
  --
--  gt_empty_table t_pur_rowids;
  --
  --
--  gv_table_index BINARY_INTEGER;
  --
  -- bug id : 1956374
  -- sjadhav,28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_encmb_dts
  --

  --
  -- Validate that PERSON doesn't already have an open UNIT requirement.
  FUNCTION enrp_val_pur_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_unit_cd IN VARCHAR2 ,
  p_pur_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_pur_open, WNDS);

  --
  --
  -- bug id : 1956374
  -- sjadhav, 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dts
END IGS_EN_VAL_PUR;

 

/
