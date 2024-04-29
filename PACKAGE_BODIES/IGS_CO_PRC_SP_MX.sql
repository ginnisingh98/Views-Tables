--------------------------------------------------------
--  DDL for Package Body IGS_CO_PRC_SP_MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_PRC_SP_MX" AS
/* $Header: IGSCO04B.pls 115.3 2002/02/12 16:42:08 pkm ship    $ */
  -- Routine to retrieve splrg max value from a PL/SQL TABLE.
  FUNCTION corp_get_splrg_max(
  p_letter_repeating_group_cd IN VARCHAR2 )
  RETURN NUMBER AS
  	v_index			BINARY_INTEGER;
  	v_max_value		NUMBER(3) := 0;
  	v_splrg_max_vals_rec	t_splrg_max_rec;
  BEGIN
  	-- Process saved values.
  	FOR  v_index IN 1..gv_table_index - 1
  	LOOP
  		 v_splrg_max_vals_rec := gt_splrg_table(v_index);
  		IF  v_splrg_max_vals_rec.letter_repeating_group_cd =
  				 p_letter_repeating_group_cd THEN
  			v_max_value :=  v_splrg_max_vals_rec.max_value;
  		END IF;
  	END LOOP;
  	RETURN(NVL(v_max_value, 0));
  END corp_get_splrg_max;
  --
  -- Routine to save splrg max value in a PL/SQL TABLE.
  PROCEDURE corp_set_splrg_max(
  p_letter_repeating_group_cd IN VARCHAR2 ,
  p_max_value IN NUMBER )
  AS
  	v_splrg_max_vals_rec		t_splrg_max_rec;
  BEGIN
  	-- Save letter repeating group code and max value
  	v_splrg_max_vals_rec.letter_repeating_group_cd :=  p_letter_repeating_group_cd;
  	v_splrg_max_vals_rec.max_value := p_max_value;
  	gt_splrg_table(gv_table_index) := v_splrg_max_vals_rec;
  	gv_table_index := gv_table_index +1;
  END corp_set_splrg_max;
  --
  -- Routine to initialise splrg max value from a PL/SQL TABLE.
  PROCEDURE corp_prc_clear_splrg
  AS
  BEGIN
  	-- initialise
  	gt_splrg_table := gt_empty_table;
  	gv_table_index := 1;
  END corp_prc_clear_splrg;
END IGS_CO_PRC_SP_MX;

/
