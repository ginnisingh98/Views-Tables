--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_POPU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_POPU" AUTHID CURRENT_USER AS
/* $Header: IGSPR17S.pls 115.7 2002/11/29 02:48:20 nsidana ship $ */

  --
   /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid,genp_set_row_id
  */
  --

  TYPE r_popu_record_type IS RECORD

  (

  progression_rule_cat IGS_PR_OU_UNIT_ALL.PROGRESSION_RULE_CAT%TYPE,

  pra_sequence_number IGS_PR_OU_UNIT_ALL.PRA_SEQUENCE_NUMBER%TYPE,


  pro_sequence_number IGS_PR_OU_UNIT_ALL.PRO_SEQUENCE_NUMBER%TYPE,

  unit_cd IGS_PR_OU_UNIT_ALL.UNIT_CD%TYPE,

  old_s_unit_type IGS_PR_OU_UNIT_ALL.S_UNIT_TYPE%TYPE);

  --

  --

  TYPE t_popu_table IS TABLE OF


  IGS_PR_VAL_POPU.r_popu_record_type

  INDEX BY BINARY_INTEGER;

  --

  --

  gt_rowid_table t_popu_table;

  --

  --


  gt_empty_table t_popu_table;

  --

  --

  gv_table_index BINARY_INTEGER;

  --

  -- Validate that a prg_outcome_unit record can be created


  FUNCTION prgp_val_popu_pro(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_sequence_number IN NUMBER ,

  p_s_unit_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


  --

  -- Validate progression rule outcome automatically apply indicator

  FUNCTION prgp_val_popu_auto(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,


  p_unit_cd IN VARCHAR2 ,

  p_old_s_unit_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_popu_rowids(

  p_inserting IN BOOLEAN ,

  p_updating IN BOOLEAN ,


  p_deleting IN BOOLEAN ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_popu_rowid(

  p_progression_rule_cat IN VARCHAR2 ,


  p_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,

  p_unit_cd IN VARCHAR2 ,

  p_old_s_unit_type IN VARCHAR2 )

;

  --


  -- Warn if the unit does not have an active unit version

  FUNCTION prgp_val_uv_active(

  p_unit_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

END IGS_PR_VAL_POPU;

 

/
