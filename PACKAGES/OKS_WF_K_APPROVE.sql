--------------------------------------------------------
--  DDL for Package OKS_WF_K_APPROVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_WF_K_APPROVE" AUTHID CURRENT_USER AS
/* $Header: OKSWCAPS.pls 120.3 2006/04/28 16:19:03 skkoppul noship $ */

procedure Selector  ( 	item_type	in varchar2,
			item_key  	in varchar2,
			activity_id	in number,
			command		in varchar2,
			resultout	out NOCOPY varchar2	);
procedure Post_Approval(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Post_Sign(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure note_filled(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure IS_related(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure IS_K_TEMPLATE(itemtype	in varchar2,
				itemkey  in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure MAKE_ACTIVE(itemtype	in varchar2,
				itemkey  in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Initialize ( 		itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Select_Approver(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);

procedure Update_AME(	        itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Select_Informed(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Select_Informed_A(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Select_Informed_AR(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Select_Informed_S(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Select_Informed_SR(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Record_Approved(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Erase_Approved(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Record_Signed(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure Record_Rejected(
                                itemtype  in         varchar2,
                                itemkey   in         varchar2,
                               	actid	  in         number,
                                funcmode  in         varchar2,
                                resultout out nocopy VARCHAR2          );
procedure was_approver(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure valid_approver(itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure notify_sales_rep_w (itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
procedure updt_quote_from_k   (itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);

PROCEDURE invalid_approver(itemtype	IN VARCHAR2,
				itemkey  	IN VARCHAR2,
				actid		IN NUMBER,
				funcmode	IN VARCHAR2,
				resultout	OUT NOCOPY VARCHAR2	);

PROCEDURE update_invalid_approver(itemtype	IN VARCHAR2,
				itemkey  	IN VARCHAR2,
				actid		IN NUMBER,
				funcmode	IN VARCHAR2,
				resultout	OUT NOCOPY VARCHAR2	);


--Global variables
--
G_TERMSFORQUOTE			CONSTANT OKC_K_REL_OBJS.RTY_CODE%TYPE := 'CONTRACTISTERMSFORQUOTE';

--added
G_NEGOTIATESQUOTE               CONSTANT OKC_K_REL_OBJS.RTY_CODE%TYPE := 'CONTRACTNEGOTIATESQUOTE';

G_OBJECT_CODE                   CONSTANT VARCHAR2(30) := 'OKX_QUOTEHEAD';

end OKS_WF_K_APPROVE;


 

/
