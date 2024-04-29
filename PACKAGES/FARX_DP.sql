--------------------------------------------------------
--  DDL for Package FARX_DP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_DP" AUTHID CURRENT_USER AS
/* $Header: farxdps.pls 120.6.12010000.3 2009/10/30 11:26:19 pmadas ship $ */

  --
  -- Backward compatible version
  --
    PROCEDURE deprn_run (
   book             in   varchar2,
   sob_id           in   varchar2 default NULL,   -- MRC: Set of books id
   period           in   varchar2,
   from_bal         in   varchar2,
   to_bal           in   varchar2,
   from_acct        in   varchar2,
   to_acct          in   varchar2,
   from_cc          in   varchar2,
   to_cc            in   varchar2,
   major_category   in   varchar2,
   minor_category   in   varchar2,
   cat_seg_num      in   varchar2,
   cat_seg_val      in   varchar2,
   prop_type        in   varchar2,
   request_id       in   number,
   login_id         in   number,
   retcode          out nocopy  number,
   errbuf           out nocopy  varchar2
);

  --
  -- Main version
  --
  PROCEDURE deprn_run (
   book             in   varchar2,
   sob_id           in   varchar2 default NULL,   -- MRC: Set of books id
   period           in   varchar2,
   from_bal         in   varchar2,
   to_bal           in   varchar2,
   from_acct        in   varchar2,
   to_acct          in   varchar2,
   from_cc          in   varchar2,
   to_cc            in   varchar2,
   from_maj_cat     in   varchar2,
   to_maj_cat       in   varchar2,
   from_min_cat     in   varchar2,
   to_min_cat       in   varchar2,
   cat_seg_num      in   varchar2,
   from_cat_seg_val in   varchar2,
   to_cat_seg_val   in   varchar2,
   prop_type        in   varchar2,
   from_asset_num   in   varchar2,
   to_asset_num     in   varchar2,
   report_style     in   varchar2 default 'S',
   request_id       in   number,
   login_id         in   number,
   retcode          out nocopy  number,
   errbuf           out nocopy  varchar2
                       );



  PROCEDURE before_report;
  PROCEDURE bind(c IN INTEGER);
  PROCEDURE after_fetch;

  TYPE var_t IS RECORD (
    book                      VARCHAR2(15),
    book_class                VARCHAR2(15),
    dist_source_book          VARCHAR2(15),
    currency_code             VARCHAR2(15),
    precision                 NUMBER,
    fy_name                   VARCHAR2(30),
    period                    VARCHAR2(15),
    period_name               VARCHAR2(15),
    period_counter            NUMBER,
    period_open_date          DATE,
    period_close_date         DATE,
    period_fy                 NUMBER,
    cat_flex_struct           NUMBER,
    loc_flex_struct           NUMBER,
    assetkey_flex_struct      NUMBER,
    acct_flex_struct          NUMBER,
    bal_segnum                NUMBER,
    acct_segnum               NUMBER,
    acct_appl_col             VARCHAR2(30),
    acct_segname              VARCHAR2(30),
    acct_prompt               VARCHAR2(80),
    acct_valueset_name        VARCHAR2(60),
    cc_segnum                 NUMBER,
    ccid                      NUMBER,
    concat_acct_str           VARCHAR2(500),
    acct_all_segs             fa_rx_shared_pkg.seg_array,
    account_description       VARCHAR2(240),
    fy                        NUMBER,
    asset_cost_acct           VARCHAR2(25),
    deprn_rsv_acct            VARCHAR2(25),
    asset_number              VARCHAR2(15),
    description               VARCHAR2(80),
    tag_number                VARCHAR2(15),
    serial_number             VARCHAR2(35),
    inventorial               VARCHAR2(3),
    date_placed_in_service    DATE,
    method_code               VARCHAR2(15),
    life                      NUMBER,
    life_yr_mo                VARCHAR2(20),
    rate                      NUMBER,
    bonus_rate                NUMBER,
    capacity                  NUMBER,
    cost                      NUMBER,
    deprn_amount              NUMBER,
    ytd_deprn                 NUMBER,
    reserve                   NUMBER,
    percent                   NUMBER,
    transaction_type          VARCHAR2(1),
    location_id               NUMBER,
    concat_loc_str            VARCHAR2(500),
    loc_segs                  fa_rx_shared_pkg.seg_array,
    category_id               NUMBER,
    concat_cat_str            VARCHAR2(500),
    cat_segs                  fa_rx_shared_pkg.seg_array,
    asset_key_ccid            NUMBER,
    concat_key_str            VARCHAR2(500),
    key_segs                  fa_rx_shared_pkg.seg_array,
    company_description       VARCHAR2(240),
    expense_acct_description  VARCHAR2(240),
    cost_center_description   VARCHAR2(240),
    category_description      VARCHAR2(240),
    emp_name                  VARCHAR2(240),
    emp_number                VARCHAR2(30),
    units                     NUMBER,
    organization_name         VARCHAR2(30),
    chart_of_accounts_id      NUMBER,
    nbv                       NUMBER,
    nbv_beginning_fy          NUMBER,
    set_of_books_id           NUMBER,
    major_category            VARCHAR2(240),
    minor_category            VARCHAR2(240),
    major_category_desc       VARCHAR2(240),
    minor_category_desc       VARCHAR2(240),
    cat_seg_num               VARCHAR2(15),
    specified_cat_seg         VARCHAR2(240),
    specified_cat_seg_desc    VARCHAR2(240),
    reserve_acct              VARCHAR2(25),
    reserve_acct_desc         VARCHAR2(240),
    date_idled                DATE,
    asset_id                  NUMBER,
    group_asset_id            NUMBER,
    group_asset_number        VARCHAR2(15),
    report_style              VARCHAR2(1),
    salvage_value             NUMBER,
    login_id                  NUMBER,
    user_id                   NUMBER,
    calendar_period_open_date DATE,   -- Bug3499862
    calendar_period_close_date DATE   -- Bug3499862
  );

   var var_t;
END FARX_DP;

/
