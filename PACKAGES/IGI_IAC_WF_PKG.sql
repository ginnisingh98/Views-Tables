--------------------------------------------------------
--  DDL for Package IGI_IAC_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: igiiawfs.pls 120.4.12000000.1 2007/08/01 16:19:47 npandya ship $ */

FUNCTION START_PROCESS (X_flex_account_type  in varchar2,
		                X_book_type_code      in varchar2,
		                X_chart_of_accounts_id in number,
		                X_dist_ccid   in number,
		                X_acct_segval  in varchar2,
	 	                X_default_ccid in number,
	                    X_account_ccid in number,
                        X_distribution_id in number default null,
                        X_Workflowprocess in varchar2 default null,
                        X_return_ccid in out NOCOPY number)
return boolean;

PROCEDURE CHECK_ACCT(itemtype     in varchar2,
	    	         itemkey      in varchar2,
                     actid	      in number,
                     funcmode     in varchar2,
                      result       out NOCOPY varchar2);

PROCEDURE CHECK_GROUP( itemtype     in varchar2,
                	   itemkey	    in varchar2,
            		   actid    	in number,
		               funcmode     in varchar2,
            		   result       out NOCOPY varchar2);


END; -- IGI_IAC_WF_PKG Package spec

 

/
