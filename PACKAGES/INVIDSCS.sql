--------------------------------------------------------
--  DDL for Package INVIDSCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVIDSCS" AUTHID CURRENT_USER as
/* $Header: INVIDSCS.pls 120.2.12010000.1 2008/07/24 01:35:19 appldev ship $ */

PROCEDURE  CHECK_CAT_SET_MANDATORY(
current_cat_set_id          IN     NUMBER,
func_area_flag1             OUT  NOCOPY    VARCHAR2,
func_area_flag2             OUT  NOCOPY    VARCHAR2,
func_area_flag3             OUT  NOCOPY    VARCHAR2,
func_area_flag4             OUT  NOCOPY    VARCHAR2,
func_area_flag5             OUT  NOCOPY    VARCHAR2,
func_area_flag6             OUT  NOCOPY    VARCHAR2,
func_area_flag7             OUT  NOCOPY    VARCHAR2,
func_area_flag8             OUT  NOCOPY    VARCHAR2,--Bug : 2527058
func_area_flag9             OUT  NOCOPY    VARCHAR2,
func_area_flag10            OUT  NOCOPY    VARCHAR2,
func_area_flag11            OUT  NOCOPY    VARCHAR2
);

PROCEDURE GET_ITEM_DEFINING_FLAGS(
current_item_id            IN   NUMBER,
current_org_id             IN   NUMBER,
inv_item_flag              OUT  NOCOPY  VARCHAR2,
purch_item_flag            OUT  NOCOPY  VARCHAR2,
int_order_flag             OUT  NOCOPY  VARCHAR2,
serv_item_flag             OUT  NOCOPY  VARCHAR2,
cost_enab_flag             OUT  NOCOPY  VARCHAR2,
engg_item_flag             OUT  NOCOPY  VARCHAR2,
cust_order_flag            OUT  NOCOPY  VARCHAR2,
mrp_plan_code              OUT  NOCOPY  NUMBER,
eam_item_type              OUT  NOCOPY  NUMBER, --Bug : 2527058
contract_item_type         OUT  NOCOPY  VARCHAR2
);

PROCEDURE INSERT_CATSET_CHILD_ORGS(
current_inv_item_id      IN    NUMBER,
current_org_id           IN    NUMBER,
current_master_org_id    IN    NUMBER,
current_cat_set_id       IN    NUMBER,
current_cat_id           IN    NUMBER,
cat_set_control_level    IN    NUMBER,
current_created_by       IN    NUMBER := NULL -- Bug: 6045866
);

PROCEDURE UPDATE_CATSET_CHILD_ORGS(
current_inv_item_id      IN    NUMBER,
current_org_id           IN    NUMBER,
current_master_org_id    IN    NUMBER,
current_cat_set_id       IN    NUMBER,
current_cat_id           IN    NUMBER,
cat_set_control_level    IN    NUMBER,
old_cat_id		 IN    NUMBER,
current_last_updated_by  IN    NUMBER := NULL -- Bug : 4949084
);

PROCEDURE redefault_material_overheads (
current_inv_item_id      IN    NUMBER,
current_org_id           IN    NUMBER,
current_master_org_id    IN    NUMBER,
current_cat_set_id       IN    NUMBER,
current_cat_id           IN    NUMBER,
cat_set_control_level    IN    NUMBER,
current_cst_item_type    IN    NUMBER,
current_last_updated_by  IN    NUMBER
);

PROCEDURE get_costing_values (
tmp_inv_item_id          IN    NUMBER,
tmp_organization_id      IN    NUMBER,
tmp_cost_method         OUT  NOCOPY    NUMBER,
tmp_cst_lot_size        OUT  NOCOPY    NUMBER,
tmp_cst_shrink_rate     OUT  NOCOPY    NUMBER
);

  /* Prasad Peddamatham - 12/8/2000
  Added current_cat_id parameter to allow the deletion of a Item Category
  Assignment based upon Multiple Item Category Assignment flag
  */
PROCEDURE DELETE_CATSET_CHILD_ORGS(
current_inv_item_id      IN    NUMBER,
current_master_org_id    IN    NUMBER,
current_cat_set_id       IN    NUMBER,
current_cat_id       IN    NUMBER
);


END INVIDSCS;

/
