--------------------------------------------------------
--  DDL for Package WSH_TRANSACTIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRANSACTIONS_UTIL" 
-- $Header: WSHXUTLS.pls 120.0.12010000.2 2009/03/23 11:44:31 brana ship $
AUTHID CURRENT_USER AS

C_SDEBUG              CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
C_DEBUG               CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;


PROCEDURE Send_Document( p_entity_id IN NUMBER,
                         p_entity_type IN VARCHAR2,
                         p_action_type IN VARCHAR2,
                         p_document_type IN VARCHAR2,
                         p_organization_id IN NUMBER,
                         x_return_status OUT NOCOPY  VARCHAR2);


PROCEDURE Send_Shipment_Request ( p_entity_id IN NUMBER,
                                  p_entity_type IN VARCHAR2,
                                  p_action_type IN VARCHAR2,
                                  p_document_type IN VARCHAR2,
                                  p_organization_id IN NUMBER,
                                  x_return_status OUT NOCOPY  VARCHAR2
                                );

PROCEDURE Get_Event_Key(p_item_type	IN VARCHAR2 DEFAULT NULL,
			p_orig_doc_number IN VARCHAR2 DEFAULT NULL,
			p_organization_id	IN NUMBER,
			p_event_name	IN VARCHAR2,
			p_delivery_name IN VARCHAR2 DEFAULT NULL,
			x_event_key	OUT NOCOPY  VARCHAR2,
			x_return_status OUT NOCOPY  VARCHAR2
		      );

PROCEDURE Unlock_Delivery_WF( Item_type 	IN	VARCHAR2,
			      Item_key		IN	VARCHAR2,
			      Actid		IN	NUMBER,
			      Funcmode		IN	VARCHAR2,
			      Resultout		OUT NOCOPY 	VARCHAR2
                       	    );

PROCEDURE Process_Inbound_Delivery_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     );
    -- ---------------------------------------------------------------------
    -- Procedure:	Process_Inbound_SR_WF
    --
    -- Parameters:	Item_Type IN  VARCHAR2
    --                  Item_Key  IN  VARCHAR2
    --		       	Actid     IN  NUMBER
    --                  Funcmode  IN  VARCHAR2
    --                  Resultout OUT VARCHAR2
    --
    -- Description:  This procedure is called from Inbound workflow (WSHSTNDI) to process
    --               the Inbound Shipment Request information sent by Host ERP system
    -- Created:     Standalone WMS Project
    -- -----------------------------------------------------------------------

PROCEDURE Process_Inbound_SR_WF(	Item_type 	IN         VARCHAR2 ,
					Item_key	IN         VARCHAR2 ,
					Actid		IN         NUMBER   ,
					Funcmode	IN         VARCHAR2 ,
					Resultout	OUT NOCOPY VARCHAR2
                       	 	     );

PROCEDURE Update_Txn_Hist_Err_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     );
PROCEDURE Update_Txn_Hist_Success_WF(	Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	OUT NOCOPY 	VARCHAR2
                       	 	     );
    -- ---------------------------------------------------------------------
    -- Procedure:	Update_Txn_Hist_Closed_WF
    --
    -- Parameters:	Item_Type IN  VARCHAR2
    --                  Item_Key  IN  VARCHAR2
    --		       	Actid     IN  NUMBER
    --                  Funcmode  IN  VARCHAR2
    --                  Resultout OUT VARCHAR2
    --
    -- Description:  This procedure is called from Inbound Workflow (WSHSTNDI) to Close
    --                all the previous error out Shipment Request revision of the workflow
    -- Created:     Standalone WMS Project
    -- -----------------------------------------------------------------------

PROCEDURE Update_Txn_Hist_Closed_WF(	Item_type 	IN          VARCHAR2 ,
					Item_key	IN          VARCHAR2 ,
					Actid		IN	    NUMBER   ,
					Funcmode	IN	    VARCHAR2 ,
					Resultout	OUT NOCOPY  VARCHAR2
                       	 	     );

PROCEDURE Update_Txn_History(		p_item_type 	IN	VARCHAR2,
					p_item_key	IN	VARCHAR2,
					p_transaction_status IN VARCHAR2,
					x_return_status OUT NOCOPY 	VARCHAR2
                       	 	     );
PROCEDURE WSHSUPI_SELECTOR(		Item_type 	IN	VARCHAR2,
					Item_key	IN	VARCHAR2,
					Actid		IN	NUMBER,
					Funcmode	IN	VARCHAR2,
					Resultout	IN OUT NOCOPY 	VARCHAR2
                       	 	     );
  FUNCTION branch_cms_tpw_flow (p_event_key  IN       VARCHAR2)
  RETURN BOOLEAN;

  PROCEDURE Check_cancellation_inprogress (
                                        p_delivery_name  IN   varchar2,
                                        x_cancellation_in_progress OUT NOCOPY
                                                        BOOLEAN ,
                                        x_return_status OUT NOCOPY VARCHAR2
                                        );
  PROCEDURE Check_cancellation_wf (
                              item_type         IN      VARCHAR2,
                              item_key          IN      VARCHAR2,
                              actid             IN      NUMBER,
                              funcmode          IN      VARCHAR2,
                              resultout         OUT NOCOPY      VARCHAR2
                            );
  PROCEDURE process_cbod_wf (
                              item_type         IN      VARCHAR2,
                              item_key          IN      VARCHAR2,
                              actid             IN      NUMBER,
                              funcmode          IN      VARCHAR2,
                              resultout         OUT NOCOPY      VARCHAR2
                            );

END WSH_TRANSACTIONS_UTIL;

/
