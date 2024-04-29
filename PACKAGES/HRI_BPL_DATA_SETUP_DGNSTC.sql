--------------------------------------------------------
--  DDL for Package HRI_BPL_DATA_SETUP_DGNSTC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_DATA_SETUP_DGNSTC" AUTHID CURRENT_USER AS
/* $Header: hribdgdp.pkh 120.4.12000000.2 2007/04/12 12:04:41 smohapat noship $ */

TYPE data_cols_tab_type IS TABLE OF VARCHAR2(240)
                           INDEX BY BINARY_INTEGER;

TYPE data_results_tab_type IS TABLE OF data_cols_tab_type
                              INDEX BY BINARY_INTEGER;

TYPE loop_results_rec_type IS RECORD
 (person_name        per_all_people_f.full_name%TYPE,
  person_number      per_all_people_f.employee_number%TYPE,
  supervisor_name    per_all_people_f.full_name%TYPE,
  supervisor_number  per_all_people_f.employee_number%TYPE);

TYPE loop_results_tab_type IS TABLE OF loop_results_rec_type
                              INDEX BY BINARY_INTEGER;

PROCEDURE debug_sup_loop
     (p_person_id       IN NUMBER,
      p_effective_date  IN DATE,
      p_loop_tab        OUT NOCOPY loop_results_tab_type);

FUNCTION get_dynamic_sql(p_dyn_sql_type   IN VARCHAR2,
                         p_dyn_sql        IN VARCHAR2)
      RETURN VARCHAR2;

PROCEDURE run_diagnostic
     (p_object_name   IN VARCHAR2,
      p_object_type   IN VARCHAR2,
      p_mode          IN VARCHAR2,
      p_start_date    IN DATE,
      p_end_date      IN DATE,
      p_row_limit     IN PLS_INTEGER,
      p_results_tab   OUT NOCOPY data_results_tab_type,
      p_impact        OUT NOCOPY BOOLEAN,
      p_impact_msg    OUT NOCOPY VARCHAR2,
      p_doc_links_url OUT NOCOPY VARCHAR2,
      p_sql_stmt      OUT NOCOPY VARCHAR2);

END hri_bpl_data_setup_dgnstc;

 

/
