--------------------------------------------------------
--  DDL for Package BIM_EDW_IH_OUTCM_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_EDW_IH_OUTCM_M_SIZE" AUTHID CURRENT_USER AS
/* $Header: bimszous.pls 115.0 2001/03/14 12:03:38 pkm ship       $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NUMBER);

PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NUMBER);



END BIM_EDW_IH_OUTCM_M_SIZE ;

 

/
