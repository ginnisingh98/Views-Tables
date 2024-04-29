--------------------------------------------------------
--  DDL for Package EAM_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVTXNS.pls 115.2 2002/11/20 19:03:13 aan noship $*/

PROCEDURE process_eam_txn(
                       p_subinventory       in VARCHAR2 := null,
                       p_lot_number         in VARCHAR2 := null,
                       p_serial_number      in VARCHAR2 := null,
                       p_organization_id             in NUMBER   := null,
                       p_locator_id         in NUMBER   := null,
                       p_qa_collection_id   in NUMBER   := null,
                       p_inventory_item_id    in NUMBER   := null,
                       p_dist_acct_id       in NUMBER   := null,
                       p_user_id            in NUMBER   := FND_GLOBAL.USER_ID,
                       p_transaction_type_id   in NUMBER   := null,
                       p_transaction_source_type_id in NUMBER   := null,
                       p_transaction_action_id in NUMBER   := null,
                       p_transaction_quantity in number := 0,
                       p_commit             in VARCHAR2 := FND_API.G_FALSE,
                       x_errCode            OUT NOCOPY NUMBER,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_statement          OUT NOCOPY NUMBER);

END eam_transactions_pvt;

 

/
