--------------------------------------------------------
--  DDL for Package OKC_DELIVERABLE_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DELIVERABLE_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVDELWFS.pls 120.0 2005/05/25 18:29:49 appldev noship $ */

---------------------------------------------------------------------------
  -- Global VARIABLES
  ---------------------------------------------------------------------------
    G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_DELIVERABLE_WF_PVT';
    G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
 ------------------------------------------------------------------------------
 G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
 G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
 G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
 G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
 G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
 G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
procedure deliverables_notifier(
	p_api_version  IN NUMBER:=1.0,
	p_init_msg_list IN VARCHAR2:=FND_API.G_FALSE,
	p_deliverable_id IN NUMBER,
	p_deliverable_name IN VARCHAR2,
	p_deliverable_type IN VARCHAR2,
	p_business_document_id IN NUMBER,
	p_business_document_version IN NUMBER,
	p_business_document_type IN VARCHAR2,
    p_business_document_number IN VARCHAR2,
    p_resp_party IN VARCHAR2,
	p_external_contact IN NUMBER,
	p_internal_contact  IN NUMBER,
	p_requester_id IN NUMBER default null,
    p_notify_prior_due_date_value IN VARCHAR2 default null,
    p_notify_prior_due_date_uom IN VARCHAR2 default null,
	p_msg_code IN VARCHAR2,
	x_notification_id OUT NOCOPY NUMBER,
	x_msg_data  OUT NOCOPY  VARCHAR2,
	x_msg_count OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE get_subject_text  (document_id in varchar2,
                            display_type in varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2);

procedure  set_int_notif_id  (itemtype in varchar2,
                                        itemkey in varchar2,
                                        actid in number,
                                        funcmode in varchar2,
                                        resultout out nocopy varchar2);

procedure  set_ext_notif_id  (itemtype in varchar2,
                                        itemkey in varchar2,
                                        actid in number,
                                        funcmode in varchar2,
                                        resultout out nocopy varchar2);

procedure  update_status  (itemtype in varchar2,
                                        itemkey in varchar2,
                                        actid in number,
                                        funcmode in varchar2,
                                        resultout out nocopy varchar2);

function send_notification_bus_event (p_subscription_guid in raw,
                                      p_event in out nocopy WF_EVENT_T) return varchar2;

END OKC_DELIVERABLE_WF_PVT;

 

/
