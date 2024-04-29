--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SPC" AUTHID CURRENT_USER AS
/* $Header: IGSPR20S.pls 115.8 2002/11/29 02:49:06 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function declaration of prgp_val_crv_active removed

  -------------------------------------------------------------------------------------------
   /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid,genp_set_row_id
  */
  --

  TYPE r_spc_record_type IS RECORD

  (

  person_id IGS_PR_STDNT_PR_OU_ALL.PERSON_ID%TYPE,

  course_cd IGS_PR_STDNT_PR_OU_ALL.COURSE_CD%TYPE,

  sequence_number IGS_PR_STDNT_PR_OU_ALL.SEQUENCE_NUMBER%TYPE);

  --

  --

  TYPE t_spc_table IS TABLE OF

  IGS_PR_VAL_SPC.r_spc_record_type


  INDEX BY BINARY_INTEGER;

  --

  --

  gt_rowid_table t_spc_table;

  --

  --

  gt_empty_table t_spc_table;

  --

  --

  gv_table_index BINARY_INTEGER;



  -- Validate student progression course / outcome relationship

  FUNCTION prgp_val_spc_spo(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )


RETURN BOOLEAN;

  --


  --

  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_spc_rowids(

  p_inserting IN BOOLEAN ,

  p_updating IN BOOLEAN ,

  p_deleting IN BOOLEAN ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_spc_rowid(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER )

;

END IGS_PR_VAL_SPC;

 

/
