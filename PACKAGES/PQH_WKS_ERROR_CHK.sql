--------------------------------------------------------
--  DDL for Package PQH_WKS_ERROR_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WKS_ERROR_CHK" AUTHID CURRENT_USER AS
/* $Header: pqwkserr.pkh 115.9 2002/12/05 00:32:07 rpasapul ship $ */

PROCEDURE check_wks_errors
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_status                  OUT NOCOPY varchar2
);

PROCEDURE check_wks_dates
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_status                  OUT NOCOPY varchar2,
  p_message                 OUT NOCOPY varchar2
);
PROCEDURE populate_globals
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE
);

PROCEDURE check_level1_rows
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE
);

PROCEDURE check_wks_details
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE
);

PROCEDURE check_wks_periods
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_worksheet_period_id     IN pqh_worksheet_periods.worksheet_period_id%TYPE
);


PROCEDURE check_wks_budget_sets
(
  p_worksheet_period_id       IN pqh_worksheet_periods.worksheet_period_id%TYPE,
  p_worksheet_budget_set_id   IN pqh_worksheet_budget_sets.worksheet_budget_set_id%TYPE
);

PROCEDURE check_wks_budget_elements
(
  p_worksheet_budget_set_id   IN pqh_worksheet_budget_sets.worksheet_budget_set_id%TYPE,
  p_worksheet_bdgt_elmnt_id   IN pqh_worksheet_fund_srcs.worksheet_bdgt_elmnt_id%TYPE
);

PROCEDURE check_wks_fund_srcs
(
  p_worksheet_bdgt_elmnt_id   IN pqh_worksheet_fund_srcs.worksheet_bdgt_elmnt_id%TYPE,
  p_worksheet_fund_src_id     IN pqh_worksheet_fund_srcs.worksheet_fund_src_id%TYPE
);

PROCEDURE set_wks_log_context
(
  p_worksheet_detail_id     IN  pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_wpr_log_context
(
  p_worksheet_period_id     IN  pqh_worksheet_periods.worksheet_period_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_wst_log_context
(
  p_worksheet_budget_set_id     IN  pqh_worksheet_budget_sets.worksheet_budget_set_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_wel_log_context
(
  p_worksheet_bdgt_elmnt_id     IN  pqh_worksheet_bdgt_elmnts.worksheet_bdgt_elmnt_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_wfs_log_context
(
  p_worksheet_fund_src_id       IN  pqh_worksheet_fund_srcs.worksheet_fund_src_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE check_input_wks_details
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE
);

PROCEDURE end_log;

PROCEDURE updt_batch
(
 p_message_text   IN pqh_process_log.message_text%TYPE
);

PROCEDURE check_pc_posn
(
  p_position_id             IN pqh_worksheet_details.position_id%TYPE,
  p_status                  OUT NOCOPY varchar2
);

END ; -- end of specification for package pqh_wks_error_chk

 

/
