--------------------------------------------------------
--  DDL for Package OE_NEGOTIATE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_NEGOTIATE_WF" AUTHID CURRENT_USER AS
/* $Header: OEXWNEGS.pls 120.1 2006/03/29 16:53:14 spooruli noship $ */


G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_NEGOTIATE_WF';

PROCEDURE Update_Status_Lost(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Negotiation_Complete(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Submit_Draft_Internal(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Customer_Acceptance(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Update_Customer_Accepted(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Update_Customer_Rejected(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Check_Expiration_Date(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Offer_Expired(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Set_Negotiate_Hdr_Descriptor
   (document_id   in VARCHAR2,
    display_type  in VARCHAR2,
    document      in out nocopy VARCHAR2,
    document_type in out nocopy VARCHAR2);



PROCEDURE Lost(p_header_id in NUMBER,
               p_entity_code in VARCHAR2,
               p_version_number in NUMBER,
               p_reason_type in VARCHAR2,
               p_reason_code in VARCHAR2,
               p_reason_comments in VARCHAR2,
               x_return_status out nocopy VARCHAR2);

PROCEDURE Customer_Accepted(p_header_id in NUMBER, x_return_status out nocopy VARCHAR2);

PROCEDURE Customer_Rejected(p_header_id in NUMBER,
                            p_entity_code in VARCHAR2,
                            p_version_number in NUMBER,
                            p_reason_type in VARCHAR2,
                            p_reason_code in VARCHAR2,
                            p_reason_comments in VARCHAR2,
                            x_return_status out nocopy VARCHAR2);

PROCEDURE Offer_Date_Changed(p_header_id in NUMBER, x_return_status out nocopy VARCHAR2);

PROCEDURE Submit_Draft(p_header_id in NUMBER, x_return_status out nocopy VARCHAR2);

PROCEDURE Set_Header_Attributes
   (itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Set_Header_Attributes_Internal(p_header_id IN NUMBER);

PROCEDURE Set_Final_Expiration_Date
   (itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);




FUNCTION At_Customer_Acceptance(p_header_id NUMBER) RETURN Boolean;

END OE_NEGOTIATE_WF;

/
