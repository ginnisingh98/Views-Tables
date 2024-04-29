--------------------------------------------------------
--  DDL for Package INV_KANBAN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_KANBAN_GRP" AUTHID CURRENT_USER as
/* $Header: INVGKBNS.pls 115.1 2003/08/21 00:40:24 cjandhya noship $ */



/*****************************************************************
** API name    INV_KANBAN_GRP
** Type        Group
**
**
**Version     Current version = 1.0
**            Initial version = 1.0
**Name
** PROCEDURE UPDATE_CARD_SUPPLY_STATUS
**
** Purpose
**    This procedure updates the supply status of the kanban card.
** Input parameters
**  p_api_version      IN  NUMBER (required)
**                API Version of this procedure
**  p_init_msg_level   IN  VARCHAR2 (optional)
**                     DEFAULT = FND_API.G_FALSE,
**  p_commit           IN  VARCHAR2 (optional)
**                     DEFAULT = FND_API.G_FALSE,
**  p_kanban_card_id   In VARCHAR2 (required)
**                     kanban card id to be updated
**  p_supply_status    IN varchar2 (required)
**                       INV_KANBAN_PVT.G_Supply_Status_New
**                       INV_KANBAN_PVT.G_Supply_Status_Full
**                       INV_KANBAN_PVT.G_Supply_Status_Empty
**                       INV_KANBAN_PVT.G_Supply_Status_InProcess
**                       INV_KANBAN_PVT.G_Supply_Status_InTransit
**  p_document_type   IN NUMBER
**                     INV_KANBAN_PVT.G_Doc_type_PO          	  1;
**                     INV_KANBAN_PVT.G_Doc_type_Release    	  2;
**                     INV_KANBAN_PVT.G_Doc_type_Internal_Req	  3;
**                     INV_KANBAN_PVT.G_Doc_type_Transfer_Order     4;
**                     INV_KANBAN_PVT.G_Doc_type_Discrete_Job       5;
**                     INV_KANBAN_PVT.G_Doc_type_Rep_Schedule       6;
**                     INV_KANBAN_PVT.G_Doc_type_Flow_Schedule      7;
**                     INV_KANBAN_PVT.G_Doc_type_lot_job   	  8;
**  p_Document_Header_Id IN  NUMBER
**                     Document header id displayed on card activity
**  p_Document_detail_Id IN  NUMBER
**                     Document detail id displayed on card activity
**  p_need_by_date       IN  DATE
**                     Need by date to be specified on the requisition
**  P_replenish_quantity IN  NUMBER
**                     Overrides the kanban size if passed
**  p_source_wip_entity_id IN NUMBER
**                     SOURCE_WIP_ENTITY diplayed on card activity.
**  Output Parameters
**    x_msg_count - number of error messages in the buffer
**    x_msg_data  - error messages
**    x_return_status - fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success,
**                      fnd_api.g_ret_unexp_error
******************************************************************/


Procedure UPDATE_CARD_SUPPLY_STATUS
(x_msg_count                     OUT NOCOPY NUMBER,
 x_msg_data                      OUT NOCOPY VARCHAR2,
 x_return_status                 OUT NOCOPY VARCHAR2,
 p_api_version_number            IN  NUMBER,
 p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
 p_kanban_card_id                IN  NUMBER,
 p_supply_status                 IN  NUMBER,
 p_document_type                 IN  NUMBER DEFAULT NULL,
 p_document_header_id            IN  NUMBER DEFAULT NULL,
 p_document_detail_id            IN  NUMBER DEFAULT NULL,
 p_replenish_quantity            IN  NUMBER DEFAULT NULL,
 p_need_by_date                  IN  DATE   DEFAULT NULL,
 p_source_wip_entity_id          IN  NUMBER DEFAULT NULL
 );

/*****************************************************************
**API name    INV_KANBAN_GRP
**Type        Group
**
**Version     Current version = 1.0
**            Initial version = 1.0
**Name
** PROCEDURE CREATE_NON_REPLENISHABLE_CARD
**
** Purpose
**    This procedure creates a non replenishable card
** Input parameters
**  p_pull_sequence_id IN NUMBER
**                     Pullsequence id to be associated with the non
**                     replenishable kanban card
**** Output Parameters
**  x_msg_count        number of error messages in the buffer
**  x_msg_data         error messages
**  x_return_status    fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success,
**                     fnd_api.g_ret_unexp_error
**  x_kanban_card_id   Kanban_card_id of the card generated
******************************************************************/

PROCEDURE CREATE_NON_REPLENISHABLE_CARD
  (x_return_status      Out NOCOPY VARCHAR2,
   x_msg_data           OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_kanban_card_id 	OUT NOCOPY NUMBER,
   p_pull_sequence_id   IN  NUMBER,
   p_kanban_size        IN  NUMBER);

END INV_KANBAN_GRP;

 

/
