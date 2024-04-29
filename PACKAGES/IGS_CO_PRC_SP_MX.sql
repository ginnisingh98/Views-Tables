--------------------------------------------------------
--  DDL for Package IGS_CO_PRC_SP_MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_PRC_SP_MX" AUTHID CURRENT_USER AS
/* $Header: IGSCO04S.pls 115.3 2002/02/12 16:42:10 pkm ship    $ */
  TYPE t_splrg_max_rec IS RECORD
  (
    letter_repeating_group_cd VARCHAR2(10),
    max_value NUMBER(3,0)
  );
  --
  --
  TYPE t_splrg_max_vals IS TABLE OF
  IGS_CO_PRC_SP_MX.t_splrg_max_rec
  INDEX BY BINARY_INTEGER;
  --
  --
  gt_splrg_table t_splrg_max_vals;
  --
  --
  gt_empty_table t_splrg_max_vals;
  --
  --
  gv_table_index BINARY_INTEGER;
  --
  -- Routine to retrieve splrg max value from a PL/SQL TABLE.
  FUNCTION corp_get_splrg_max(
  p_letter_repeating_group_cd IN VARCHAR2 )
  RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(corp_get_splrg_max,WNDS);
  --
  -- Routine to save splrg max value in a PL/SQL TABLE.
  PROCEDURE corp_set_splrg_max(
  p_letter_repeating_group_cd IN VARCHAR2 ,
  p_max_value IN NUMBER );
  --
  -- Routine to initialise splrg max value from a PL/SQL TABLE.
  PROCEDURE corp_prc_clear_splrg;
END IGS_CO_PRC_SP_MX;

 

/
