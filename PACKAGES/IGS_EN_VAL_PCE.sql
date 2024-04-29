--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PCE" AUTHID CURRENT_USER AS
/* $Header: IGSEN50S.pls 115.4 2002/11/29 00:02:19 nsidana ship $ */
  --
  /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid, genp_set_rowid
  */
  --
  TYPE t_pce_rowids IS TABLE OF
  ROWID
  INDEX BY BINARY_INTEGER;
  --
  --
  gt_rowid_table t_pce_rowids;
  --
  --
  gt_empty_table t_pce_rowids;
  --
  --
  gv_table_index BINARY_INTEGER;
  --
  -- Validate that IGS_PE_PERSON doesn't already have an open crs exclusion.
  FUNCTION enrp_val_pce_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_pce_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_pce_open,WNDS);
  --
  -- Routine to process pce rowids in PL/SQL TABLE for the current commit.
  FUNCTION enrp_prc_pce_rowids(
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name IN OUT NOCOPY VARCHAR2  )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_prc_pce_rowids,WNDS);
  --

  -- To validate the nominated date is not less than current date..
  FUNCTION enrp_val_encmb_dt(
  p_date IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_encmb_dt,WNDS);
  --
  -- To validate that expiry date is greater than or equal to start date.
  FUNCTION enrp_val_strt_exp_dt(
  p_start_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_strt_exp_dt,WNDS);
  --
  -- Validate if a IGS_PS_COURSE must be discontinued before it can excluded.
  FUNCTION enrp_val_crs_exclsn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_exclusion_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_crs_exclsn,WNDS);
  --
  -- Validate the IGS_PS_COURSE code on the IGS_PE_PERSON IGS_PS_COURSE exclusion table.
  FUNCTION enrp_val_pce_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_exclusion_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_pce_crs,WNDS);
  --
  -- Validate the encumbrance effect table
  FUNCTION enrp_val_pee_table(
  p_effect_type IN VARCHAR2 ,
  p_table_name IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_pee_table,WNDS);
  --
  -- To validate that child date is not less than parent start date.
  FUNCTION enrp_val_encmb_dts(
  p_parent_start_dt IN DATE ,
  p_child_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_encmb_dts,WNDS);
END IGS_EN_VAL_PCE;

 

/
