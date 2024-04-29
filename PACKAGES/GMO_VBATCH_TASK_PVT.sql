--------------------------------------------------------
--  DDL for Package GMO_VBATCH_TASK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_VBATCH_TASK_PVT" AUTHID CURRENT_USER AS
/* $Header: GMOVVTKS.pls 120.1 2007/06/21 06:17:16 rvsingh noship $ */

function is_wms_installed return varchar2;

procedure update_process_parameter
(
p_batch_no              IN              VARCHAR2
,p_org_code              IN              VARCHAR2
,p_validate_flexfields   IN              VARCHAR2
,p_batchstep_no          IN              NUMBER
,p_activity              IN              VARCHAR2
,p_parameter             IN              VARCHAR2
,p_process_param_rec     IN              fnd_table_of_varchar2_255
,x_process_param_rec     OUT NOCOPY      fnd_table_of_varchar2_255
,x_return_status         OUT NOCOPY      VARCHAR2
,x_message_count         OUT NOCOPY      NUMBER
,x_message_data          OUT NOCOPY      VARCHAR2
);


procedure setup_resource_transaction(
p_org_id 		NUMBER,
p_org_code		VARCHAR2,
p_batch_id		NUMBER,
x_return_status		OUT NOCOPY VARCHAR2,
x_message_count		OUT NOCOPY NUMBER,
x_message_data		OUT NOCOPY VARCHAR2
);

procedure create_resource_transaction (
p_resource_transaction_rec IN fnd_table_of_varchar2_255
,x_resource_transaction_rec OUT NOCOPY fnd_table_of_varchar2_255
,x_return_status	   OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure update_resource_transaction (
p_resource_transaction_rec IN fnd_table_of_varchar2_255
,x_return_status	   OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure delete_resource_transaction (
p_resource_transaction_rec IN fnd_table_of_varchar2_255
,x_return_status	   OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure save_batch (
p_table			   in number
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure get_resource_txn_end_date(
p_start_date		   IN DATE
,p_usage		   IN NUMBER
,p_trans_um                IN VARCHAR2
,x_end_date		   OUT NOCOPY DATE
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure get_resource_txn_usage(
p_start_date		   IN DATE
,p_end_date		   IN DATE
,p_trans_um                IN VARCHAR2
,x_usage		   OUT NOCOPY NUMBER
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure convert_um (
p_organization_id          IN NUMBER
,p_inventory_item_id 	   IN NUMBER
,p_lot_number              IN VARCHAR2
,p_from_qty 		   IN NUMBER
,p_from_um		   IN VARCHAR2
,p_to_um                   IN VARCHAR2
,x_to_qty                  OUT NOCOPY NUMBER
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure qty_within_deviation (
p_organization_id          IN NUMBER
,p_inventory_item_id       IN NUMBER
,p_lot_number              IN NUMBER
,p_qty                     IN NUMBER
,p_um                      IN VARCHAR2
,p_sec_qty                 IN NUMBER
,p_sec_um                  IN VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure get_material_transactions(
p_organization_id 	   IN NUMBER
,p_batch_id		   IN NUMBER
,p_material_detail_id	   IN NUMBER
,x_mmt_cur		   OUT NOCOPY gme_api_grp.g_gmo_txns
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure get_material_reservations(
p_organization_id          IN NUMBER
,p_batch_id                IN NUMBER
,p_material_detail_id      IN NUMBER
,x_res_cur                 OUT NOCOPY gme_api_grp.g_gmo_resvns
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure get_material_pplots(
p_organization_id          IN NUMBER
,p_batch_id                IN NUMBER
,p_material_detail_id      IN NUMBER
,x_pplot_cur               OUT NOCOPY gme_api_grp.g_gmo_pplots
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure get_lot_transactions(
p_transaction_id           IN NUMBER
,x_lt_cur                  OUT NOCOPY gme_api_grp.g_gmo_lot_txns
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure get_dispense_um(
p_material_detail_id       IN NUMBER
,x_dispense_um		   OUT NOCOPY VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure relieve_reservation(
p_reservation_id 	  IN NUMBER
,p_prim_relieve_quantity  IN NUMBER
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure relieve_pending_lot(
p_pending_lot_id           IN  NUMBER
,p_quantity                IN  NUMBER
,p_secondary_quantity      IN  NUMBER
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure create_material_transaction(
p_mtl_txn_rec		   IN fnd_table_of_varchar2_255
,p_mtl_lot_rec		   IN fnd_table_of_varchar2_255
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure update_material_transaction(
p_mtl_txn_rec              IN fnd_table_of_varchar2_255
,p_mtl_lot_rec             IN fnd_table_of_varchar2_255
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure delete_material_transaction(
p_mtl_txn_rec              IN fnd_table_of_varchar2_255
,p_mtl_lot_rec             IN fnd_table_of_varchar2_255
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure create_lot(
p_lot_rec		   IN fnd_table_of_varchar2_255
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure generate_lot(
p_organization_id	  IN NUMBER
,p_inventory_item_id	  IN NUMBER
,x_lot_number		  OUT NOCOPY VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
);

procedure get_lot_event_key (
p_organization_id         IN NUMBER
,p_inventory_item_id      IN NUMBER
,p_lot_number             IN VARCHAR2
,x_lot_event_key	  OUT NOCOPY VARCHAR2
);

end GMO_VBATCH_TASK_PVT;

/
