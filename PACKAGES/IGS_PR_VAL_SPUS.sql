--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SPUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SPUS" AUTHID CURRENT_USER AS
/* $Header: IGSPR23S.pls 115.7 2002/11/29 02:49:59 nsidana ship $ */

  /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid
  */

  --

  TYPE r_spus_record_type IS RECORD

  (

  person_id IGS_PR_STDNT_PR_OU_ALL.PERSON_ID%TYPE,

  course_cd IGS_PR_STDNT_PR_OU_ALL.COURSE_CD%TYPE,

  sequence_number IGS_PR_STDNT_PR_OU_ALL.SEQUENCE_NUMBER%TYPE);

  --

  --

  TYPE t_spus_table IS TABLE OF

  IGS_PR_VAL_SPUS.r_spus_record_type


  INDEX BY BINARY_INTEGER;

  --

  --

  gt_rowid_table t_spus_table;

  --

  --

  gt_empty_table t_spus_table;

  --

  --

  gv_table_index BINARY_INTEGER;

  --


  -- Validate student progression unit set / outcome relationship

  FUNCTION prgp_val_spus_spo(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate that the unit set is active

  FUNCTION prgp_val_us_active(

  p_unit_set_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --


  --

  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_spus_rowids(

  p_inserting IN BOOLEAN ,

  p_updating IN BOOLEAN ,


  p_deleting IN BOOLEAN ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_spus_rowid(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER )

;

END IGS_PR_VAL_SPUS;

 

/
