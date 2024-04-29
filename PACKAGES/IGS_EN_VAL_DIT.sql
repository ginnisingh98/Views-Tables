--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_DIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_DIT" AUTHID CURRENT_USER AS
/* $Header: IGSEN31S.pls 115.4 2002/11/28 23:56:53 nsidana ship $ */
  --
/* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid,genp_set_row_id
*/
  --
  TYPE t_dit_rowids IS TABLE OF
  ROWID
  INDEX BY BINARY_INTEGER;
  --
  --
  gt_rowid_table t_dit_rowids;
  --
  --
  gt_empty_table t_dit_rowids;
  --
  --
  gv_table_index BINARY_INTEGER;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  --
  -- Routine to process dit rowids in a PL/SQL TABLE for the current commit
  FUNCTION enrp_prc_dit_rowids(
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_prc_dit_rowids,WNDS);
  --
  -- Validate the disability type.
  FUNCTION enrp_val_dit_open(
  p_disability_type IN VARCHAR2 ,
  p_govt_disability_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_dit_open,WNDS);
END IGS_EN_VAL_DIT;

 

/
