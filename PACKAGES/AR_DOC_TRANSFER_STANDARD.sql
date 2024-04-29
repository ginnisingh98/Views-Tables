--------------------------------------------------------
--  DDL for Package AR_DOC_TRANSFER_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DOC_TRANSFER_STANDARD" AUTHID CURRENT_USER as
/* $Header: ARDOCTFS.pls 120.5 2005/07/22 10:33:49 naneja noship $ */

/*Bug 44509019 Removed GSCC warning file.sql.39 used NOCOPY hint for OUT and IN OUT parameter type*/
PROCEDURE CallbackFunction(     p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2);

function  otaCallBackRule(p_subscription_guid in     raw,
                          p_event            in out nocopy wf_event_t) return varchar2;
procedure updateStatus;
procedure xml_transfer(		ITEMTYPE  IN      VARCHAR2,
	               		ITEMKEY   IN      VARCHAR2,
        	       		ACTID     IN      NUMBER,
               			FUNCMODE  IN      VARCHAR2,
               			RESULTOUT IN OUT NOCOPY  VARCHAR2);

procedure email_transfer(	ITEMTYPE  IN      VARCHAR2,
               			ITEMKEY   IN      VARCHAR2,
               			ACTID     IN      NUMBER,
               			FUNCMODE  IN      VARCHAR2,
	               		RESULTOUT IN OUT NOCOPY  VARCHAR2);

procedure edi_transfer(		ITEMTYPE  IN      VARCHAR2,
               			ITEMKEY   IN      VARCHAR2,
               			ACTID     IN      NUMBER,
               			FUNCMODE  IN      VARCHAR2,
               			RESULTOUT IN OUT NOCOPY  VARCHAR2);

procedure raiseTransferEvent(	p_event_name       in VARCHAR2,
                             	p_trx_type         in VARCHAR2,
                             	p_trx_sub_type     in VARCHAR2,
                             	p_party_id         in NUMBER,
                             	p_party_site_id    in NUMBER,
                                p_party_type       in VARCHAR2,
                             	p_doc_transfer_id  in NUMBER);

procedure debug(p_line in varchar2);
function isDebugOn return boolean;
end;

 

/
