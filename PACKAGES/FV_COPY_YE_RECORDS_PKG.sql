--------------------------------------------------------
--  DDL for Package FV_COPY_YE_RECORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_COPY_YE_RECORDS_PKG" AUTHID CURRENT_USER AS
/* $Header: FVYECPGS.pls 120.2.12010000.2 2009/12/23 10:23:22 amaddula ship $*/
procedure copy_record
 (v_ledger_id           IN gl_ledgers.ledger_id%TYPE,
  v_old_group_id        IN fv_ye_groups.group_id%TYPE,
  v_time_frame_new      IN fv_treasury_symbols.time_frame%TYPE,--modified for Bug.1575992
  v_fund_group_code_new IN varchar2,
  v_treasury_symbol_new IN fv_treasury_symbols.treasury_symbol%TYPE,
  v_closing_method      IN fv_ye_groups.closing_method%TYPE);--modified for Bug.1575992
END fv_copy_ye_records_pkg;

/
