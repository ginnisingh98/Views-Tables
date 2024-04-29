--------------------------------------------------------
--  DDL for Package Body FA_CUSTOM_GEN_CCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUSTOM_GEN_CCID_PKG" as
/* $Header: FACSTGCB.pls 120.4.12010000.2 2009/07/19 12:09:31 glchen ship $ */

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
return BOOLEAN is
BEGIN

   --  THIS IS THE STUB WHICH USERS CAN MODIFY
   --  RETURN TRUE AND A VALID CCID in X_rtn_ccid
   --  RETURN FALSE IF UNABLE TO GENERATE A VALID CCID
   --  DEFAULT IS TO RETURN FALSE AND X_rtn_ccid := -1

   X_rtn_ccid := -1;

   return FALSE;

   EXCEPTION
       WHEN OTHERS THEN
         FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN=>'FA_CUSTOM_GEN_CCID_PKG.gen_ccid',  p_log_level_rec => p_log_level_rec);
         return FALSE;
END;

END FA_CUSTOM_GEN_CCID_PKG;

/
