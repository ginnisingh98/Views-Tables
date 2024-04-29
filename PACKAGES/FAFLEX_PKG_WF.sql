--------------------------------------------------------
--  DDL for Package FAFLEX_PKG_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FAFLEX_PKG_WF" AUTHID CURRENT_USER as
/* $Header: faflxwfs.pls 120.2.12010000.2 2009/07/19 13:53:29 glchen ship $ */
-------------------------------------------------------------------
-- This function replaces fafbgcc in FA_FLEX_PKG.fafb_call_flex.

--  used for caching the basic book info
G_flex_num        number;
G_last_book_used  varchar2(15);
ItemKey           varchar2(30);
ItemType          varchar2(30) :='FAFLEXWF';

FUNCTION START_PROCESS
            (X_flex_account_type  in varchar2,
             X_book_type_code     in varchar2,
             X_flex_num           in number,
             X_dist_ccid          in number,
             X_acct_segval        in varchar2,
             X_default_ccid       in number,
             X_account_ccid       in number,
             X_distribution_id    in number default null,
             X_Workflowprocess    in varchar2 default null,
             X_Validation_Date    in date default sysdate,
             X_return_ccid        in out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
          return boolean;

PROCEDURE CORP_OR_TAX
            (itemtype  in varchar2,
             itemkey   in varchar2,
             actid     in number,
             funcmode  in varchar2,
             result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

PROCEDURE CHECK_ACCT
            (itemtype  in varchar2,
             itemkey   in varchar2,
             actid     in number,
             funcmode  in varchar2,
             result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

PROCEDURE CHECK_GROUP
            (itemtype  in varchar2,
             itemkey   in varchar2,
             actid     in number,
             funcmode  in varchar2,
             result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);
PROCEDURE GET_BOOK_TYPE
            (itemtype  in varchar2,
             itemkey   in varchar2,
             actid     in number,
             funcmode  in varchar2,
             result       out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

END FAFLEX_PKG_WF;

/
