--------------------------------------------------------
--  DDL for Package WIP_EAM_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAM_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: WIPVETXS.pls 115.3 2003/01/30 20:21:24 hkarmach noship $*/

/*--------------------------------------------------------------------------+
 | This package contains the spec for transaction API for rebuildables.     |
 | This API will call the relevant transaction APIs for a miscellaneous     |
 | transaction.                                                             |
 | History:                                                                 |
 | July 10, 2000       hkarmach         Created package spec.               |
 +--------------------------------------------------------------------------*/

PROCEDURE process_eam_txn(
                       p_subinventory               IN  VARCHAR2 := null,
                       p_lot_number                 IN  VARCHAR2 := null,
                       p_serial_number              IN  VARCHAR2 := null,
                       p_organization_id            IN  NUMBER   := null,
                       p_locator_id                 IN  NUMBER   := null,
                       p_qa_collection_id           IN  NUMBER   := null,
                       p_inventory_item_id          IN  NUMBER   := null,
                       p_dist_acct_id               IN  NUMBER   := null,
                       p_user_id                    IN  NUMBER   := FND_GLOBAL.USER_ID,
                       p_transaction_type_id        IN  NUMBER   := null,
                       p_transaction_source_type_id IN  NUMBER   := null,
                       p_transaction_action_id      IN  NUMBER   := null,
                       p_transaction_quantity       IN  number   := 0,
		       p_revision		    IN  VARCHAR2 := null,
                       p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
                       x_errCode                    OUT NOCOPY NUMBER,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
                       x_statement                  OUT NOCOPY NUMBER);

END WIP_EAM_TRANSACTIONS_PVT;

 

/
