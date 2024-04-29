--------------------------------------------------------
--  DDL for Package IGS_GE_PRC_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_PRC_TRANSFER" AUTHID CURRENT_USER AS
/* $Header: IGSGE07S.pls 115.6 2002/11/29 00:32:40 nsidana ship $ */
  --
  --
  /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid,genp_set_row_id
  */
	cst_home_location_type		VARCHAR2(10) DEFAULT 'HOME';
	cst_term_location_type		VARCHAR2(10) DEFAULT 'TERM';
  --
  --
  TYPE t_pe_rowids IS TABLE OF
  ROWID
  INDEX BY BINARY_INTEGER;
  --
  --
  gt_rowid_table t_pe_rowids;
  --
  --
  gt_empty_table t_pe_rowids;
  --
  --
  gv_table_index BINARY_INTEGER;
  --
  -- To get the alternate person ids for the data transfer mechanism.
  FUNCTION GENP_GET_ALT_PE_ID(
  p_person_id IN NUMBER ,
  p_person_id_type IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (genp_get_alt_pe_id,WNDS);

  --
  -- To get the person statistics location description for the data transf.
  FUNCTION GENP_GET_PS_LOCATION(
  p_person_id IN NUMBER ,
  p_start_dt IN DATE ,
  p_location_type IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (genp_get_ps_location,WNDS);

  --
  -- To insert data transfer IGS_PE_STD_TODO entries
  PROCEDURE GENP_INS_TRNSFR_TODO(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_todo_dt IN DATE )
;
  --
  -- Process PE rowids in a PL/SQL TABLE for the current commit.
  FUNCTION genp_prc_pe_rowids(
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name IN OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_GE_PRC_TRANSFER;

 

/
