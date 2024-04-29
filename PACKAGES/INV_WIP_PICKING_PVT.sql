--------------------------------------------------------
--  DDL for Package INV_WIP_PICKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_WIP_PICKING_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVVWPKS.pls 120.4 2006/01/13 15:28:19 stdavid noship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_WIP_PICKING_PVT';

  -- Bug 4288399, moving g_wip_patch_level to spec
  -- Global variable for tracking WIP patch level
  g_wip_patch_level NUMBER := -999;

-- Bug 4288399, creating a new table of records which will be passed back to
-- WIP containing errored record information with the error message.
TYPE Trolin_ErrRec_Type IS RECORD
(   attribute1                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute_category            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   date_required                 DATE           := FND_API.G_MISS_DATE
,   from_locator_id               NUMBER         := FND_API.G_MISS_NUM
,   from_subinventory_code        VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   from_subinventory_id          NUMBER         := FND_API.G_MISS_NUM
,   header_id                     NUMBER         := FND_API.G_MISS_NUM
,   inventory_item_id             NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   line_id                       NUMBER         := FND_API.G_MISS_NUM
,   line_number                   NUMBER         := FND_API.G_MISS_NUM
,   line_status                   NUMBER         := FND_API.G_MISS_NUM
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
,   lot_number                    VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   organization_id               NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   project_id                    NUMBER         := FND_API.G_MISS_NUM
,   quantity                      NUMBER         := FND_API.G_MISS_NUM
,   quantity_delivered            NUMBER         := FND_API.G_MISS_NUM
,   quantity_detailed             NUMBER         := FND_API.G_MISS_NUM
,   reason_id                     NUMBER         := FND_API.G_MISS_NUM
,   reference                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   reference_id                  NUMBER         := FND_API.G_MISS_NUM
,   reference_type_code           NUMBER         := FND_API.G_MISS_NUM
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   revision                      VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   serial_number_end             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   serial_number_start           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   status_date                   DATE           := FND_API.G_MISS_DATE
,   task_id                       NUMBER         := FND_API.G_MISS_NUM
,   to_account_id                 NUMBER         := FND_API.G_MISS_NUM
,   to_locator_id                 NUMBER         := FND_API.G_MISS_NUM
,   to_subinventory_code          VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   to_subinventory_id            NUMBER         := FND_API.G_MISS_NUM
,   transaction_header_id         NUMBER         := FND_API.G_MISS_NUM
,   transaction_type_id		  NUMBER	 := FND_API.G_MISS_NUM
,   txn_source_id		  NUMBER	 := FND_API.G_MISS_NUM
,   txn_source_line_id		  NUMBER	 := FND_API.G_MISS_NUM
,   txn_source_line_detail_id	  NUMBER	 := FND_API.G_MISS_NUM
,   transaction_source_type_id	  NUMBER	 := FND_API.G_MISS_NUM
,   primary_quantity		  NUMBER	 := FND_API.G_MISS_NUM
,   to_organization_id		  NUMBER	 := FND_API.G_MISS_NUM
,   pick_strategy_id		  NUMBER	 := FND_API.G_MISS_NUM
,   put_away_strategy_id	  NUMBER	 := FND_API.G_MISS_NUM
,   uom_code                      VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   unit_number			  VARCHAR2(30)	 := FND_API.G_MISS_CHAR
,   ship_to_location_id           NUMBER         := FND_API.G_MISS_NUM
,   from_cost_group_id		  NUMBER	 := FND_API.G_MISS_NUM
,   to_cost_group_id		  NUMBER	 := FND_API.G_MISS_NUM
,   lpn_id			  NUMBER	 := FND_API.G_MISS_NUM
,   to_lpn_id			  NUMBER	 := FND_API.G_MISS_NUM
,   pick_methodology_id		  NUMBER	 := FND_API.G_MISS_NUM
,   container_item_id		  NUMBER	 := FND_API.G_MISS_NUM
,   carton_grouping_id		  NUMBER	 := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   inspection_status             NUMBER         :=NULL
,   wms_process_flag              NUMBER         :=NULL
,   pick_slip_number              NUMBER         :=NULL
,   pick_slip_date                DATE           :=NULL
,   ship_set_id                   NUMBER         :=NULL
,   ship_model_id                 NUMBER         :=NULL
,   model_quantity                NUMBER         :=NULL
,   required_quantity             NUMBER         :=NULL
,   error_message                 VARCHAR2(2000) := FND_API.G_MISS_CHAR);

TYPE Trolin_ErrTbl_Type IS TABLE OF Trolin_ErrRec_Type
    INDEX BY BINARY_INTEGER;

  --
  -- The procedure release_pick_batch is overloaded so that
  -- WIP 'H' works with Inventory 'I'.
  --
  -- pre patchset I version
  --
  PROCEDURE release_pick_batch
  ( p_mo_header_rec           IN   INV_Move_Order_PUB.Trohdr_Rec_Type
  , p_mo_line_rec_tbl         IN   INV_Move_Order_PUB.Trolin_Tbl_Type
  , p_auto_detail_flag        IN   VARCHAR2  DEFAULT  FND_API.G_TRUE
  , p_auto_pick_confirm_flag  IN   VARCHAR2  DEFAULT  FND_API.G_FALSE
  , p_allow_partial_pick      IN   VARCHAR2  DEFAULT  FND_API.G_TRUE
  , p_commit                  IN   VARCHAR2  DEFAULT  FND_API.G_FALSE
  , p_init_msg_lst            IN   VARCHAR2  DEFAULT  FND_API.G_FALSE
  , x_return_status           OUT  NOCOPY  VARCHAR2
  , x_msg_count               OUT  NOCOPY  NUMBER
  , x_msg_data                OUT  NOCOPY  VARCHAR2
  );

  --
  -- patchset I version
  --
  PROCEDURE release_pick_batch
  ( p_mo_header_rec           IN OUT NOCOPY inv_move_order_pub.trohdr_rec_type
  , p_mo_line_rec_tbl         IN     inv_move_order_pub.trolin_tbl_type
  , p_auto_detail_flag        IN     VARCHAR2  DEFAULT  fnd_api.g_true
  , p_auto_pick_confirm_flag  IN     VARCHAR2  DEFAULT  NULL
  , p_allow_partial_pick      IN     VARCHAR2  DEFAULT  fnd_api.g_true
  , p_print_pick_slip         IN     VARCHAR2  DEFAULT  fnd_api.g_false
  , p_plan_tasks              IN     BOOLEAN   DEFAULT  FALSE
  , p_commit                  IN     VARCHAR2  DEFAULT  fnd_api.g_false
  , p_init_msg_lst            IN     VARCHAR2  DEFAULT  fnd_api.g_false
  , x_return_status           OUT    NOCOPY  VARCHAR2
  , x_msg_count               OUT    NOCOPY  NUMBER
  , x_msg_data                OUT    NOCOPY  VARCHAR2
  , x_conc_req_id             OUT    NOCOPY  NUMBER
  , x_mo_line_errrec_tbl      OUT    NOCOPY  INV_WIP_Picking_PVT.Trolin_ErrTbl_Type  -- Bug 4288399
  );

  PROCEDURE pick_release(
    x_return_status      OUT  NOCOPY  VARCHAR2
  , x_msg_count          OUT  NOCOPY  NUMBER
  , x_msg_data           OUT  NOCOPY  VARCHAR2
  , p_commit             IN   VARCHAR2  DEFAULT  fnd_api.g_false
  , p_init_msg_lst       IN   VARCHAR2  DEFAULT  fnd_api.g_false
  , p_mo_line_tbl        IN   inv_move_order_pub.trolin_tbl_type
  , p_allow_partial_pick IN   VARCHAR2  DEFAULT  fnd_api.g_true
  , p_grouping_rule_id   IN   NUMBER    DEFAULT  NULL
  , p_plan_tasks         IN   BOOLEAN   DEFAULT  FALSE
  , p_call_wip_api       IN   BOOLEAN   DEFAULT  FALSE
  );

  PROCEDURE update_mol_for_wip
  ( x_return_status       OUT  NOCOPY VARCHAR2
  , x_msg_count           OUT  NOCOPY NUMBER
  , x_msg_data            OUT  NOCOPY VARCHAR2
  , p_move_order_line_id  IN   NUMBER
  , p_op_seq_num          IN   NUMBER
  );

  PROCEDURE get_wip_attributes(
    x_return_status           OUT NOCOPY VARCHAR2
  , x_wip_entity_type         OUT NOCOPY NUMBER
  , x_push_vs_pull            OUT NOCOPY VARCHAR2
  , x_repetitive_line_id      OUT NOCOPY NUMBER
  , x_department_id           OUT NOCOPY NUMBER
  , x_department_code         OUT NOCOPY VARCHAR2
  , x_pick_slip_number        OUT NOCOPY NUMBER
  , p_wip_entity_id            IN        NUMBER
  , p_operation_seq_num        IN        NUMBER
  , p_rep_schedule_id          IN        NUMBER
  , p_organization_id          IN        NUMBER
  , p_inventory_item_id        IN        NUMBER
  , p_transaction_type_id      IN        NUMBER
  , p_get_pick_slip_number     IN        BOOLEAN
  );

END inv_wip_picking_pvt;

 

/
