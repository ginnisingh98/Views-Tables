--------------------------------------------------------
--  DDL for Package OKC_WF_CHK_APPROVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_WF_CHK_APPROVE" AUTHID CURRENT_USER as
/* $Header: OKCWCHKS.pls 120.1 2005/10/21 05:58:18 nechatur noship $ */
procedure Selector  ( 	item_type	in varchar2,
			item_key  	in varchar2,
			activity_id	in number,
			command		in varchar2,
			resultout	out nocopy varchar2	);
procedure Initialize ( 		itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2	);
procedure Select_Approver(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2	);
procedure Select_Informed(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2	);
procedure Record_Approved(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2	);
procedure Record_Rejected(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2	);
procedure note_filled(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2	);
end OKC_WF_CHK_APPROVE;

 

/
