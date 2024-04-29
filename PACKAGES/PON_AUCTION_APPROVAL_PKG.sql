--------------------------------------------------------
--  DDL for Package PON_AUCTION_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AUCTION_APPROVAL_PKG" AUTHID CURRENT_USER as
/* $Header: PONAPPRS.pls 120.2.12010000.6 2013/08/26 09:46:59 gkuncham ship $ */
g_module_prefix         CONSTANT VARCHAR2(50) := 'pon.plsql.PON_AUCTION_APPROVAL_PKG.';
yesChar VARCHAR2(1) := 'Y';
noChar  VARCHAR2(1) := 'N';
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),noChar);

PROCEDURE CANCEL_NOTIFICATION(p_auction_header_id number,
                                    p_user_name varchar2,
                                    p_resultOut out nocopy number);
PROCEDURE UPDATE_NOTIF_ONLINE (p_auction_header_id number,
                                    p_user_name varchar2,
                                    p_result varchar2,
                                    p_note_to_buyer varchar2,
                                    p_resultOut out nocopy number);
Procedure Close_Child_Process(p_parent_item_key Varchar2);
Procedure UPD_AUCTION_STATUSHISTORY(p_auction_header_id number,
                                      p_status Varchar2,
                                      p_notes Varchar2,
                                      p_user_id Number,
                                      p_upd_history_type varchar2,
									  p_original_approver_id number DEFAULT -1);
PROCEDURE Doc_Approved(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       uncmode   in varchar2,
                       resultout  out nocopy varchar2);
PROCEDURE Doc_TimedOut(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       uncmode   in varchar2,
                       resultout  out nocopy varchar2);
PROCEDURE Doc_Rejected(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       uncmode   in varchar2,
                       resultout  out nocopy varchar2);
PROCEDURE User_Approved(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              uncmode   in varchar2,
                              resultout  out nocopy varchar2);
PROCEDURE User_Rejected(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              uncmode   in varchar2,
                              resultout  out nocopy varchar2);


PROCEDURE UPDATE_DOC_TO_CANCELLED ( itemtype in varchar2,
                                Itemkey		in varchar2,
                                actid	        in number,
                                uncmode		in varchar2,
                                resultout	out nocopy varchar2);

PROCEDURE SUBMIT_FOR_APPROVAL(p_auction_header_id_encrypted   VARCHAR2,  -- 1
                              p_auction_header_id             number,    -- 2
                              p_note_to_approvers             varchar2,  -- 3
                              p_submit_user_name              varchar2,  -- 4
                              p_redirect_func                 varchar2); -- 5

PROCEDURE StartUserApprovalProcess(itemtype in varchar2,
                                   Itemkey         in varchar2,
                                   actid           in number,
                                   uncmode         in varchar2,
                                   resultout       out nocopy varchar2);

PROCEDURE User_Decision_Without_WF(p_user_id    in number,
                                   p_decision   in varchar2,
                                   p_notes      in varchar2,
                                   p_auctionHeaderId in number);

PROCEDURE SET_NOTIFICATION_SUBJECT(p_itemtype in varchar2,
                                   p_itemkey  in varchar2,
                                   p_msg_suffix in varchar2,
                                   p_doc_number in varchar2,
                                   p_orig_document_number in varchar2,
                                   p_amendment_number in number,
                                   p_auction_title in varchar2);

--added for eric test only,begin
PROCEDURE StartEmdApprovalProcess
(
  itemtype  IN VARCHAR2
, Itemkey   IN VARCHAR2
, actid     IN NUMBER
, uncmode   IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

--choli add for emd update page link in notification
Procedure Get_Emd_HeaderId(pn_notification_id IN NUMBER,
l_auction_header_id OUT NOCOPY NUMBER) ;

PROCEDURE Emd_User_Approved
(
  itemtype  IN VARCHAR2
, itemkey   IN VARCHAR2
, actid     IN NUMBER
, uncmode   IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

 PROCEDURE Emd_User_Rejected
(
  itemtype  IN VARCHAR2
, itemkey   IN VARCHAR2
, actid     IN NUMBER
, uncmode   IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);
--added for eric test only,end
PROCEDURE post_approval_action
(
  itemtype  IN VARCHAR2
, itemkey   IN VARCHAR2
, actid     IN NUMBER
, funcmode   IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);
end PON_AUCTION_APPROVAL_PKG;

/
