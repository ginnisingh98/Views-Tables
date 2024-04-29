--------------------------------------------------------
--  DDL for Package GMD_LM_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_LM_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: GMDLMMGS.pls 120.2 2005/09/14 05:07:09 kshukla noship $ */

 PROCEDURE generate_tech_parm_id;
 PROCEDURE insert_gmd_tech_seq_comps;
 PROCEDURE insert_gmd_tech_data_comps;
 PROCEDURE run;

 v_lm_prlt_asc_rec lm_prlt_asc_bak%ROWTYPE;
 v_lm_item_dat_rec lm_item_dat_bak%ROWTYPE;

END;

 

/
