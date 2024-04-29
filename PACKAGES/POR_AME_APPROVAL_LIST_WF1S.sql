--------------------------------------------------------
--  DDL for Package POR_AME_APPROVAL_LIST_WF1S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_AME_APPROVAL_LIST_WF1S" AUTHID CURRENT_USER AS
/* $Header: POXAME1S.pls 120.1.12010000.2 2010/04/28 13:16:14 rojain ship $ */

applicationId     number :=201; /* ame is using PO id  */


procedure setAmeAttributes  (itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

procedure Is_Ame_For_Approval(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

procedure Is_Ame_For_Rco_Approval(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

procedure Get_Next_Approver(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

procedure Update_Approval_List_Response(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Approver_Timeout(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure SET_FORWARD_RESERVE_APPROVER(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

END POR_AME_APPROVAL_LIST_WF1S;

/
