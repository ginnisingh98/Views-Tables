--------------------------------------------------------
--  DDL for Package FA_TAX_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TAX_UPLOAD_PKG" AUTHID CURRENT_USER as
/* $Header: fataxups.pls 120.2.12010000.3 2009/07/19 13:34:42 glchen ship $   */

-- type for table variable
type num_tbl_type  is table of number        index by binary_integer;
type char_tbl_type is table of varchar2(150) index by binary_integer;
type date_tbl_type is table of date          index by binary_integer;

-- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam Start

TYPE msg_error_rec IS RECORD(asset_number    VARCHAR2(50)
                            ,exception_code  VARCHAR2(10)
                            );
TYPE msg_error_tbl IS TABLE OF msg_error_rec INDEX BY BINARY_INTEGER;
g_error_msg   msg_error_tbl;

TYPE new_taxbk_col_rec_type IS RECORD (
      nbv_at_switch                 NUMBER,
      prior_deprn_limit_amount      NUMBER,
      period_full_reserve           VARCHAR2(30),
      prior_deprn_method            VARCHAR2(20),
      period_extd_deprn             VARCHAR2(30),
      period_counter_fully_reserved NUMBER,
      extended_depreciation_period  NUMBER);

TYPE basic_info_rec_type IS RECORD (
      asset_id                 NUMBER,
      book_type_code           VARCHAR2(100),
      date_placed_in_service   DATE,
      deprn_method_code        VARCHAR2(100),
      asset_number             VARCHAR2(100),
      deprn_reserve            NUMBER
      );
-- Changes made as per the ER No.s 6606548 and 6606552 by Vkukutam End

PROCEDURE faxtaxup(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number);

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2);

PROCEDURE allocate_workers (
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status         OUT NOCOPY NUMBER);

END FA_TAX_UPLOAD_PKG ;

/
