--------------------------------------------------------
--  DDL for Package FA_FLEX_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FLEX_UPG_PKG" AUTHID CURRENT_USER as
/* $Header: faflxups.pls 120.2.12010000.2 2009/07/19 14:03:12 glchen ship $ */

PROCEDURE CALL_UPGRADED_FLEX(itemtype  in varchar2,
	    	   itemkey	in varchar2,
		   actid	in number,
		   funcmode     in varchar2,
		   result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

FUNCTION BOOK_LEVEL_ACCT (X_flex_num in number,
		    X_func      in varchar2,
		    X_acct_seg  in varchar2,
		    X_def_ccid  in  varchar2,
		    X_dist_ccid	    in  varchar2,
		    X_flex_seg   in out nocopy varchar2,
		    X_error_msg  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN ;

FUNCTION CATE_LEVEL_ACCT (X_flex_num   in number,
		    X_func      in varchar2,
		    X_acct_ccid        in varchar2,
		    X_acct_seg  in varchar2,
		    X_def_ccid     in  varchar2,
		    X_dist_ccid	       in  varchar2,
		    X_flex_seg         in out nocopy varchar2,
		    X_error_msg        in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN ;

FUNCTION ASSET_LEVEL_ACCT (X_flex_num   in number,
		    X_func      in varchar2,
		    X_acct_seg  in varchar2,
		    X_dist_ccid	       in  varchar2,
		    X_flex_seg         in out nocopy varchar2,
		    X_error_msg        in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN ;
END FA_FLEX_UPG_PKG;

/
