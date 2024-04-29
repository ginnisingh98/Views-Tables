--------------------------------------------------------
--  DDL for Package JMF_PROCESS_SHIKYU_RCV_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_PROCESS_SHIKYU_RCV_TRX_PVT" AUTHID CURRENT_USER AS
-- $Header: JMFVSKTS.pls 120.4 2006/03/20 04:41 vmutyala noship $

-- Global variables
   G_TEAM_NAME CONSTANT VARCHAR2(3) := 'JMF';
   G_PKG_NAME CONSTANT VARCHAR2(30) := 'JMF_PROCESS_SHIKYU_RCV_TRX_PVT';


--========================================================================
-- PROCEDURE : Process_Shikyu_Rcv_trx	PUBLIC
-- PARAMETERS: p_api_version  	IN Standard in parameter API version
--             p_init_msg_list 	IN Standard in parameter message list
--             p_request_id  	IN Request Id
--             p_group_id 	IN Group Id
--             x_return_status  OUT Stadard out parameter for return status
--                                     (Values E(Error), S(Success), U(Unexpected error))
--
-- COMMENT   : This concurrent program will be called to process OSA Receipt,
--             OSA Return and RTV of SHIKYU Components at MP site. RTV of SHIKYU
--             Component is triggered by SHIKYU RMA at OEM site.
--========================================================================
PROCEDURE Process_Shikyu_Rcv_trx(
      p_api_version          IN  NUMBER,
      p_init_msg_list        IN  VARCHAR2,
      p_request_id           NUMBER,
      p_group_id             NUMBER,
      x_return_status    OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Process_Osa_Receipt	PUBLIC
-- PARAMETERS: p_api_version  	IN Standard in parameter API version
--             p_init_msg_list 	IN Standard in parameter message list
--             x_return_status      OUT Stadard out parameter for return status
--                                     (Values E(Error), S(Success), U(Unexpected error))
--             x_msg_count          OUT Stadard out parameter for number of messages
--             x_msg_data           OUT Stadard out parameter for message
--             p_po_shipment_id     IN Subcontracting PO shipment
--             p_quantity           IN Received quantity
--             p_uom                IN UOM of received quantity
--             p_transaction_type   IN Transaction Type
--	       p_project_id	    IN Project reference
--	       p_task_id	    IN Task reference
-- COMMENT   : This procedure is called after receipt of Outsourced Assembly
--             Item to perform WIP completion and Misc issue at Manufacturing
--             Partner organization. It does allocations if required.
--========================================================================
PROCEDURE Process_Osa_Receipt
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_po_shipment_id          IN  NUMBER
, p_quantity                IN  NUMBER
, p_uom                     IN VARCHAR2
, p_transaction_type        IN VARCHAR2
, p_project_id		    IN NUMBER
, p_task_id	            IN NUMBER
, p_status		    IN OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Process_Osa_Return	PUBLIC
-- PARAMETERS: p_api_version  	    IN Standard in parameter API version
--             p_init_msg_list 	    IN Standard in parameter message list
--             x_return_status      OUT Stadard out parameter for return status
--                                     (Values E(Error), S(Success), U(Unexpected error))
--             x_msg_count          OUT Stadard out parameter for number of messages
--             x_msg_data           OUT Stadard out parameter for message
--             p_po_shipment_id     IN Subcontracting PO shipment
--             p_quantity           IN Received quantity
--             p_uom                IN UOM of received quantity
--             p_transaction_type   IN Transaction Type
--	       p_project_id	    IN project reference
--	       p_task_id	    IN task reference
-- COMMENT   : This procedure is called after return of Outsourced Assembly
--             Item to Supplier to perform WIP assembly return and Misc receipt at
--             Manufacturing Partner organization.
--========================================================================
PROCEDURE Process_Osa_Return
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_po_shipment_id          IN  NUMBER
, p_quantity                IN  NUMBER
, p_uom                     IN VARCHAR2
, p_transaction_type        IN VARCHAR2
, p_project_id		    IN NUMBER
, p_task_id	            IN NUMBER
, p_status		    IN OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE  : Process_Component_Return	PUBLIC
-- PARAMETERS: p_api_version  		IN Standard in parameter API version
--             p_init_msg_list 		IN Standard in parameter message list
--             x_return_status      	OUT Stadard out parameter for return status
--                                     	 (Values E(Error), S(Success), U(Unexpected error))
--             x_msg_count          	OUT Stadard out parameter for number of messages
--             x_msg_data           	OUT Stadard out parameter for message
--             p_rma_line_id            IN RMA line id
--             p_quantity               IN Received quantity
--             p_uom                    IN UOM of received quantity
-- COMMENT   : This procedure is called after SHIKYU RMA at Subcontracting
--             Organizaiton. It initiates RTV transaction at MP Organization.
--             It also deallocates returned quantities.
--========================================================================
PROCEDURE Process_Component_Return
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_rma_line_id             IN  NUMBER
, p_quantity                IN  NUMBER
, p_uom                     IN VARCHAR2
, p_status		    IN OUT NOCOPY VARCHAR2
);

END JMF_PROCESS_SHIKYU_RCV_TRX_PVT;

 

/
