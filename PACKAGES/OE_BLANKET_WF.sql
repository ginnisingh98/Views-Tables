--------------------------------------------------------
--  DDL for Package OE_BLANKET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_WF" AUTHID CURRENT_USER AS
/* $Header: OEXWBSOS.pls 120.1.12010000.2 2015/09/03 11:47:57 suthumma ship $ */


G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_BLANKET_WF';

PROCEDURE Submit_Draft_Internal(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Check_Negotiation_Exists(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Calculate_Effective_Dates(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Set_Blanket_Hdr_Descriptor(
    document_id   in VARCHAR2,
    display_type  in VARCHAR2,
    document      in out nocopy VARCHAR2,
    document_type in out nocopy VARCHAR2);

PROCEDURE Get_Expire_Date(
    document_id   in VARCHAR2,
    display_type  in VARCHAR2,
    document      in out nocopy VARCHAR2,
    document_type in out nocopy VARCHAR2);

PROCEDURE Expired(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Terminate_Internal(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Close_Internal(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

PROCEDURE Blanket_Date_Changed(p_header_id IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Submit_Draft(p_header_id IN NUMBER,
                       p_transaction_phase_code IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Close(p_header_id IN NUMBER,
                x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Terminate(p_header_id IN NUMBER,
                    p_terminated_by IN NUMBER,
                    p_version_number IN NUMBER,
                    p_reason_type IN VARCHAR2,
                    p_reason_code IN VARCHAR2,
                    p_reason_comments IN VARCHAR2,
                    x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Extend(p_header_id IN NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2);

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

END OE_BLANKET_WF;

/
