--------------------------------------------------------
--  DDL for Package WSH_ROUTING_RESPONSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ROUTING_RESPONSE_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHRESPS.pls 115.1 2003/09/04 19:29:10 rlanka noship $ */

--
G_PKG_NAME	CONSTANT	VARCHAR2(100) := 'WSH_ROUTING_RESPONSE_PKG';
g_eventName	CONSTANT	VARCHAR2(50)  := 'oracle.apps.fte.inbound.routresp.send';
g_RespIdTab	WSH_UTIL_CORE.id_tab_type;
g_RoleExpDate	CONSTANT	DATE := SYSDATE + 15;
--
PROCEDURE GenerateRoutingResponse(
	p_deliveryIdTab 	IN  wsh_util_core.id_tab_type,
	x_routingRespIdTab 	OUT NOCOPY wsh_util_core.id_tab_type,
	x_RetStatus  		OUT NOCOPY VARCHAR2);


PROCEDURE CreateTxnHistory(p_delId IN NUMBER,
		           x_TxnId  OUT NOCOPY NUMBER,
			   x_RespNum OUT NOCOPY NUMBER,
			   x_DelName OUT NOCOPY VARCHAR2,
		           x_Status OUT NOCOPY VARCHAR2);

PROCEDURE SendNotification(p_delivId    IN NUMBER,
			   p_TxnId	IN NUMBER,
			   p_DelName	IN VARCHAR2,
			   p_RespNum    IN NUMBER,
                           x_RetSts     OUT NOCOPY VARCHAR2);


PROCEDURE PreNotification(itemtype    IN VARCHAR2,
        		  itemkey     IN VARCHAR2,
        		  actid       IN NUMBER,
        		  funcmode    IN VARCHAR2,
        		  resultout   OUT NOCOPY VARCHAR2);


PROCEDURE PostNotification(itemtype    IN VARCHAR2,
        		   itemkey     IN VARCHAR2,
        		   actid       IN NUMBER,
        		   funcmode    IN VARCHAR2,
        		   resultout   OUT NOCOPY VARCHAR2);


PROCEDURE UpdateTxnHistory(p_deliveryId IN NUMBER,
			   p_TxnId      IN NUMBER,
			   p_RevNum     IN NUMBER,
			   x_Status     OUT NOCOPY VARCHAR2);

PROCEDURE ValidateDelivery(p_delivery_id   IN NUMBER,
			   x_return_status OUT NOCOPY VARCHAR2);


FUNCTION GetFromRole(p_UserId IN NUMBER) RETURN VARCHAR2;

FUNCTION GetToRole(p_delivId IN NUMBER) RETURN VARCHAR2;

FUNCTION LockDelivery(p_deliveryId IN NUMBER) RETURN BOOLEAN;

PROCEDURE FTERRESP_SELECTOR(itemType      IN      VARCHAR2,
                           itemKey        IN      VARCHAR2,
                           actid          IN      NUMBER,
                           funcmode       IN      VARCHAR2,
                           resultout      IN OUT NOCOPY   VARCHAR2);

PROCEDURE CheckDeliveryInfo(p_routRespNum	IN	VARCHAR2,
			    x_changed		OUT NOCOPY VARCHAR2);


PROCEDURE Validate_PO(p_delivery_id       	IN      NUMBER,
        	      x_return_status         	OUT NOCOPY      VARCHAR2);


END WSH_ROUTING_RESPONSE_PKG;

 

/
