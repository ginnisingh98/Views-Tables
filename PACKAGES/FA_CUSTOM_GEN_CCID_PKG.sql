--------------------------------------------------------
--  DDL for Package FA_CUSTOM_GEN_CCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUSTOM_GEN_CCID_PKG" AUTHID CURRENT_USER as
/* $Header: FACSTGCS.pls 120.3.12010000.2 2009/07/19 12:10:00 glchen ship $ */

FUNCTION gen_ccid (X_fn_trx_code       in varchar2,
                   X_book_type_code    in fa_book_controls.book_type_code%type,
                   X_flex_num          in number,
                   X_dist_ccid         in number,
                   X_acct_segval       in varchar2,
                   X_default_ccid      in number,
                   X_account_ccid      in number,
                   X_distribution_id   in number,
                   X_rtn_ccid          out NOCOPY number
                  ,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null)
return BOOLEAN;

END FA_CUSTOM_GEN_CCID_PKG;

/
