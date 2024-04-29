--------------------------------------------------------
--  DDL for Package EAM_MATERIAL_ALLOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MATERIAL_ALLOCATIONS_PVT" AUTHID CURRENT_USER AS
  /* $Header: EAMMTALS.pls 115.1 2003/10/09 03:20:44 dgupta noship $*/

PROCEDURE reduce_allocation_header(
  p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false,
  p_commit                   IN            VARCHAR2 := fnd_api.g_false,
  p_transaction_temp_id      IN            NUMBER,
  p_organization_id          IN            NUMBER := null,
  p_qty_to_reduce            IN            NUMBER := null,
  p_final_qty                IN            NUMBER := null,
  p_delete_remaining         IN            VARCHAR2 := 'N',
  x_new_transaction_temp_id  OUT NOCOPY    NUMBER,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2
);

PROCEDURE remove_serial(
  p_init_msg_list              IN            VARCHAR2 := fnd_api.g_false,
  p_commit                     IN            VARCHAR2 := fnd_api.g_false,
  p_transaction_temp_id        IN            NUMBER,
  p_serial                     IN            VARCHAR2,
  p_lot                        IN            VARCHAR2 := null,
  p_inventory_item_id          IN            NUMBER := null,
  p_new_transaction_temp_id    IN            NUMBER := null,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
);

PROCEDURE add_serial(
  p_init_msg_list              IN            VARCHAR2 := fnd_api.g_false,
  p_commit                     IN            VARCHAR2 := fnd_api.g_false,
  p_transaction_temp_id        IN            NUMBER,
  p_organization_id            IN            NUMBER,
  p_inventory_item_id          IN            NUMBER,
  p_serial                     IN            VARCHAR2,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
);

PROCEDURE update_lot(
  p_init_msg_list              IN            VARCHAR2 := fnd_api.g_false,
  p_commit                     IN            VARCHAR2 := fnd_api.g_false,
  p_transaction_temp_id        IN            NUMBER,
  p_serial_transaction_temp_id IN            NUMBER := null,
  p_lot                        IN            VARCHAR2,
  p_lot_quantity               IN            NUMBER,
  p_old_lot_quantity           IN            NUMBER,
  p_new_transaction_temp_id    IN            NUMBER := null,
  x_ser_trx_id                 OUT NOCOPY    NUMBER,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
);

PROCEDURE mark_lot_with_ser_temp_id(
  p_init_msg_list              IN            VARCHAR2 := fnd_api.g_false,
  p_commit                     IN            VARCHAR2 := fnd_api.g_false,
  p_transaction_temp_id        IN            NUMBER,
  p_lot                        IN            VARCHAR2,
  p_primary_quantity           IN            NUMBER,
  x_ser_trx_id                 OUT NOCOPY    NUMBER,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
);

PROCEDURE delete_allocation(
  p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false,
  p_commit                IN            VARCHAR2 := fnd_api.g_false,
  p_transaction_temp_id   IN            NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
);

END EAM_MATERIAL_ALLOCATIONS_PVT;

 

/
