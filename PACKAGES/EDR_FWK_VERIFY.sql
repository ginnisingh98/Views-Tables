--------------------------------------------------------
--  DDL for Package EDR_FWK_VERIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_FWK_VERIFY" AUTHID CURRENT_USER AS
/* $Header: EDRFWKVS.pls 120.0.12000000.1 2007/01/18 05:53:11 appldev ship $


/* Verify if a notificaiton is Require or Not */

PROCEDURE CHECK_REQUIREMENT
	(
	 p_itemtype   IN VARCHAR2,
      	 p_itemkey    IN VARCHAR2,
      	 p_actid      IN NUMBER,
         p_funcmode   IN VARCHAR2,
         p_resultout  OUT NOCOPY VARCHAR2
	) ;

PROCEDURE SET_ATTRIBUTES
	(
	 p_itemtype   IN VARCHAR2,
      	 p_itemkey    IN VARCHAR2,
      	 p_actid      IN NUMBER,
         p_funcmode   IN VARCHAR2,
         p_resultout  OUT NOCOPY VARCHAR2
	) ;

PROCEDURE UPDATE_EVIDENCE
	(p_itemtype   IN VARCHAR2,
      	 p_itemkey    IN VARCHAR2,
      	 p_actid      IN NUMBER,
         p_funcmode   IN VARCHAR2,
         p_resultout  OUT NOCOPY VARCHAR2
	) ;

PROCEDURE Test_EvidenceStore (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default FND_API.G_FALSE,
	p_itemtype   IN VARCHAR2,
      	p_itemkey    IN VARCHAR2,
        p_notif_id   IN NUMBER,
        p_event_name 	IN VARCHAR2,
        p_event_key 	IN VARCHAR2,
        x_resultout  OUT NOCOPY VARCHAR2
	) ;


end EDR_FWK_VERIFY;

 

/
