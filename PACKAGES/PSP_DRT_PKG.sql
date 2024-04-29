--------------------------------------------------------
--  DDL for Package PSP_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPDRTS.pls 120.0.12010000.7 2018/04/12 06:25:23 mgidutur noship $ */



  -- DRC procedure.
  PROCEDURE ld_drc
    (p_person_id      IN NUMBER,
              p_result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
    ;

  -- DRC procedure.
  PROCEDURE psp_hr_drc
    (p_person_id      IN NUMBER,
              p_result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
    ;

/*
  -- Removal procedures, currently not scoped.
  PROCEDURE remove_adj_data
    (p_person_id IN number);

  PROCEDURE remove_enc_data
    (p_person_id IN number);

  PROCEDURE remove_actuals_data
    (p_person_id IN number);

  PROCEDURE remove_sched_data
    (p_person_id IN number);

  FUNCTION clear_lab_data
    (p_person_id IN number) RETURN varchar2;

*/


  PROCEDURE write_log
    (p_log_message IN varchar2);

  g_debug boolean DEFAULT hr_utility.debug_enabled;

  TYPE eff_rep_type IS RECORD (effort_report_id  t_num_15_type);

  eff_master_rec eff_rep_type;
END psp_drt_pkg;

/
