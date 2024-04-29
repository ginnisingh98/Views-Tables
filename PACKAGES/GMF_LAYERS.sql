--------------------------------------------------------
--  DDL for Package GMF_LAYERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_LAYERS" AUTHID CURRENT_USER AS
/*  $Header: GMFLAYRS.pls 120.1.12010000.2 2009/11/02 20:28:31 pkanetka ship $

 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMFLAYR.pls                                                           |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMF_LAYERS                                                            |
 |                                                                          |
 | DESCRIPTION                                                              |
 |                                                                          |
 | CONTENTS                                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 +==========================================================================+
*/

TYPE TRANS_REC_TYPE IS RECORD
(
    TRANSACTION_ID              mtl_material_transactions.transaction_id%TYPE
  , TRANSACTION_SOURCE_TYPE_ID  mtl_material_transactions.transaction_source_type_id%TYPE
  , TRANSACTION_ACTION_ID       mtl_material_transactions.transaction_action_id%TYPE
  , TRANSACTION_TYPE_ID         mtl_material_transactions.transaction_type_id%TYPE
  , INVENTORY_ITEM_ID           mtl_material_transactions.inventory_item_id%TYPE
  , ORGANIZATION_ID             mtl_material_transactions.organization_id%TYPE
  , LOT_NUMBER                  mtl_transaction_lot_numbers.lot_number%TYPE
  , TRANSACTION_DATE            mtl_material_transactions.transaction_date%TYPE
  , PRIMARY_QUANTITY            mtl_material_transactions.primary_quantity%TYPE
  , PRIMARY_UOM                 mtl_system_items_b.primary_uom_code%TYPE
  , DOC_QTY                     NUMBER
  , DOC_UOM                     gme_material_details.dtl_um%TYPE
  , TRANSACTION_SOURCE_ID       mtl_material_transactions.transaction_source_id%TYPE
  , TRX_SOURCE_LINE_ID          mtl_material_transactions.trx_source_line_id%TYPE
  , REVERSE_ID                  mtl_material_transactions.source_line_id%TYPE
  , LINE_TYPE                   gme_material_details.line_type%TYPE
  , LAST_UPDATED_BY             mtl_material_transactions.last_updated_by%TYPE
  , CREATED_BY                  mtl_material_transactions.created_by%TYPE
  , LAST_UPDATE_LOGIN           mtl_material_transactions.last_update_login%TYPE
);

PROCEDURE Create_Incoming_Layers
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_tran_rec      IN          GMF_LAYERS.TRANS_REC_TYPE,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

PROCEDURE Create_Outgoing_Layers
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_tran_rec      IN          GMF_LAYERS.TRANS_REC_TYPE,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

PROCEDURE Create_Resource_Layers
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_rsrc_rec      IN          gme_resource_txns%ROWTYPE,
  p_doc_qty       IN          NUMBER,
  p_doc_um        IN          VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2);

-- Begin Additions for relayering concurrent request.

PROCEDURE log_message
( p_table_name       IN   VARCHAR2,
  p_procedure_name   IN   VARCHAR2,
  p_parameters       IN   VARCHAR2,
  p_message          IN   VARCHAR2,
  p_error_type       IN   VARCHAR2);

PROCEDURE Delete_old_layers
( p_batch_id         IN   NUMBER);

PROCEDURE Delete_period_layers
( p_batch_id         IN   NUMBER,
  p_period_id        IN   NUMBER);

PROCEDURE Recreate_outgoing_layers
( p_batch_id         IN   NUMBER,
  p_period_id        IN   NUMBER);

PROCEDURE Recreate_resource_layers
( p_batch_id         IN   NUMBER,
  p_period_id        IN   NUMBER);

PROCEDURE Recreate_incoming_layers
( p_batch_id         IN   NUMBER,
  p_period_id        IN   NUMBER);

PROCEDURE Finalize_batch
( p_batch_id         IN   NUMBER,
  p_period_id        IN   NUMBER);


PROCEDURE Relayer
( errbuf             OUT NOCOPY VARCHAR2,
  retcode            OUT NOCOPY VARCHAR2,
  p_legal_entity_id  IN NUMBER,
  p_calendar_code    IN  VARCHAR2,
  p_period_code      IN  VARCHAR2,
  p_cost_type_id     IN  NUMBER,
  p_org_id           IN  NUMBER DEFAULT NULL,
  p_batch_id         IN  NUMBER DEFAULT NULL);

-- END Additions for relayering concurrent request.

END GMF_LAYERS;

/
