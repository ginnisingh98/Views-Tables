--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SPU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SPU" AUTHID CURRENT_USER AS
/* $Header: IGSPR22S.pls 115.7 2002/11/29 02:49:44 nsidana ship $ */

  /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid
  */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_UV_ACTIVE) - from the spec and body. -- kdande
*/
  --

  TYPE r_spu_record_type IS RECORD

  (

  person_id IGS_PR_STDNT_PR_OU_ALL.PERSON_ID%TYPE,

  course_cd IGS_PR_STDNT_PR_OU_ALL.COURSE_CD%TYPE,

  sequence_number IGS_PR_STDNT_PR_OU_ALL.SEQUENCE_NUMBER%TYPE);

  --

  --

  TYPE t_spu_table IS TABLE OF

  IGS_PR_VAL_SPU.r_spu_record_type


  INDEX BY BINARY_INTEGER;

  --

  --

  gt_rowid_table t_spu_table;

  --

  --

  gt_empty_table t_spu_table;

  --

  --

  gv_table_index BINARY_INTEGER;

  --


  -- Validate student progression unit / outcome relationship

  FUNCTION prgp_val_spu_spo(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_s_unit_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --


  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_spu_rowids(

  p_inserting IN BOOLEAN ,

  p_updating IN BOOLEAN ,


  p_deleting IN BOOLEAN ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_spu_rowid(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER )

;


END IGS_PR_VAL_SPU;

 

/
