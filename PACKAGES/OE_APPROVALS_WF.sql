--------------------------------------------------------
--  DDL for Package OE_APPROVALS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_APPROVALS_WF" AUTHID CURRENT_USER AS
/* $Header: OEXWAPRS.pls 120.0.12010000.1 2008/07/25 08:08:12 appldev ship $ */

--  Start of Comments
--  API name    OE_APPROVALS_WF
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0


Procedure Initiate_Approval
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2);

Procedure Get_Next_Approver
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2);

function Get_Next_Approver_internal
         (
           p_transaction_id in NUMBER,
           p_itemtype in VARCHAR2,
           p_sales_document_type_code in VARCHAR2,
           p_query_mode   in VARCHAR2 default 'N'
         )
    return VARCHAR2;

Procedure Reject_Approval
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2);

Procedure Approval_Timeout
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2);

Procedure Approve_Approval
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2);

Procedure Get_Current_Approver
        (document_id in varchar2,
         display_type in varchar2,
         document in out NOCOPY /* file.sql.39 change */ varchar2,
         document_type in out NOCOPY /* file.sql.39 change */ varchar2);

function Get_Current_Approver_internal
         (
           p_transaction_id in NUMBER
         )
   return VARCHAR2;


Procedure Get_Sales_Document_Type
        (document_id in varchar2,
         display_type in varchar2,
         document in out NOCOPY /* file.sql.39 change */ varchar2,
         document_type in out NOCOPY /* file.sql.39 change */ varchar2);




END OE_APPROVALS_WF;

/
