--------------------------------------------------------
--  DDL for Package POR_AME_REQ_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_AME_REQ_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: POXAMEPS.pls 120.10 2006/06/29 14:19:33 kikhlaq noship $ */
applicationId     number :=201; /* ame is using PO id  */

procedure Get_Next_Approvers(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

procedure Launch_Parallel_Approval(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Process_Response_Approve (itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Process_Response_Reject (itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Process_Response_Timeout(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Insert_Action_History(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_Approve(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_Reject(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_Timeout(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_No_Act( itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2);

procedure Process_Beat_By_First( itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2);

PROCEDURE IS_AME_EXCEPTION(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);
END POR_AME_REQ_WF_PVT;

 

/
