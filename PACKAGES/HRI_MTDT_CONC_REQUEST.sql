--------------------------------------------------------
--  DDL for Package HRI_MTDT_CONC_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_MTDT_CONC_REQUEST" AUTHID CURRENT_USER AS
/* $Header: hrimcncr.pkh 120.0.12000000.2 2007/04/12 12:09:00 smohapat noship $ */

FUNCTION is_table_owned_by_page
  (p_page_list   IN hri_bpl_conc_admin.page_list_tab_type,
   p_table_name  IN VARCHAR2)
        RETURN VARCHAR2;

FUNCTION is_core_hri_process
  (p_table_name  IN VARCHAR2)
        RETURN VARCHAR2;

END hri_mtdt_conc_request;

 

/
