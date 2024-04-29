--------------------------------------------------------
--  DDL for Package FA_SORP_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SORP_UPG_PKG" AUTHID CURRENT_USER AS
/* $Header: FAVSRUS.pls 120.2.12010000.1 2009/07/21 12:37:53 glchen noship $   */
   p_fa_book             fa_books.book_type_code%TYPE;
   p_acct_flex_struct    NUMBER;
   p_capital_adj_flex    VARCHAR2 (1000);
   p_general_fund_flex   VARCHAR2 (1000);
   p_mode                VARCHAR2 (25);
   p_summary_mode        VARCHAR2 (250);
   p_report_mode         VARCHAR2 (250);
   p_display_mode        VARCHAR2 (250);
   p_from varchar2(250);
   p_where varchar2(1000);
   P_REQUEST_WHERE varchar2(1000);
   p_order_by varchar2(250); -- Bug#7632825
   FUNCTION fa_category_impl (
      p_book                fa_books.book_type_code%TYPE,
      p_acct_flex_struct    NUMBER,
      p_capital_adj_acct    VARCHAR2,
      p_general_fund_acct   VARCHAR2,
      p_run_mode            VARCHAR2
   )
      RETURN BOOLEAN;
   FUNCTION fa_sorp_reval_chk_fn (p_book_type_code VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN;
   FUNCTION fa_sorp_upg_cagf_fn (p_book_type_code VARCHAR2, p_mode VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN;
   FUNCTION fa_sorp_upg_impreval_fn (p_book VARCHAR2, p_mode VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN;
END fa_sorp_upg_pkg;

/
