--------------------------------------------------------
--  DDL for Package HRI_BPL_CONC_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_CONC_ADMIN" AUTHID CURRENT_USER AS
/* $Header: hribcnca.pkh 120.5 2006/10/06 12:18:57 jtitmas noship $ */

TYPE page_list_rec_type IS RECORD
 (page_owner     VARCHAR2(240)
 ,page_name      VARCHAR2(240)
 ,page_type      VARCHAR2(240));

TYPE page_list_tab_type IS TABLE OF page_list_rec_type INDEX BY BINARY_INTEGER;

FUNCTION get_full_refresh_flag( p_table_name        IN VARCHAR2 )
                RETURN VARCHAR2;

FUNCTION get_full_refresh_code( p_table_name        IN VARCHAR2 )
                RETURN VARCHAR2;

FUNCTION get_events_full_refresh_flag
                RETURN VARCHAR2;

FUNCTION get_hri_global_start_date
                RETURN DATE;

PROCEDURE get_request_set_details
   (p_request_set_id   OUT NOCOPY NUMBER,
    p_application_id   OUT NOCOPY NUMBER,
    p_refresh_mode     OUT NOCOPY VARCHAR2,
    p_page_list        OUT NOCOPY page_list_tab_type);

END hri_bpl_conc_admin;

/
