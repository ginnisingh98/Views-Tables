--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_POUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_POUS" AUTHID CURRENT_USER AS
/* $Header: IGSPR18S.pls 115.7 2002/11/29 02:48:35 nsidana ship $ */

  /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid
  */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_US_ACTIVE) - from the spec and body. -- kdande
*/
  --

  TYPE r_pous_record_type IS RECORD

  (

  progression_rule_cat IGS_PR_OU_UNIT_SET_ALL.PROGRESSION_RULE_CAT%TYPE,

  pra_sequence_number IGS_PR_OU_UNIT_SET_ALL.PRA_SEQUENCE_NUMBER%TYPE,


  pro_sequence_number IGS_PR_OU_UNIT_SET_ALL.PRO_SEQUENCE_NUMBER%TYPE,

  unit_set_cd IGS_PR_OU_UNIT_SET_ALL.UNIT_SET_CD%TYPE,

  us_version_number IGS_PR_OU_UNIT_SET_ALL.US_VERSION_NUMBER%TYPE);

  --

  --

  TYPE t_pous_table IS TABLE OF


  IGS_PR_VAL_POUS.r_pous_record_type

  INDEX BY BINARY_INTEGER;

  --

  --

  gt_rowid_table t_pous_table;

  --

  --


  gt_empty_table t_pous_table;

  --

  --

  gv_table_index BINARY_INTEGER;

  --

  -- Validate that a prg_outcome_unit_set record can be created


  FUNCTION prgp_val_pous_pro(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --


  -- Validate progression rule outcome automatically apply indicator

  FUNCTION prgp_val_pous_auto(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,

  p_unit_set_cd IN VARCHAR2 ,


  p_us_version_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  --

  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_pous_rowids(

  p_inserting IN BOOLEAN ,

  p_updating IN BOOLEAN ,

  p_deleting IN BOOLEAN ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_pous_rowid(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,


  p_pro_sequence_number IN NUMBER ,

  p_unit_set_cd IN VARCHAR2 ,

  p_us_version_number IN NUMBER )

;
END IGS_PR_VAL_POUS;

 

/
