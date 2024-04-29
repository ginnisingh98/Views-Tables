--------------------------------------------------------
--  DDL for Package INV_MWB_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_TREE" AUTHID CURRENT_USER AS
/* $Header: INVMWBTS.pls 120.0 2005/05/25 06:59:52 appldev noship $ */

  PROCEDURE add_orgs(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_lot_controlled       IN             NUMBER DEFAULT 0
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_serial_controlled    IN             NUMBER DEFAULT 0
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_containerized        IN             NUMBER DEFAULT 0
  , p_prepacked            IN             NUMBER DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  , p_sub_type             IN             NUMBER  DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  , p_qty_from             IN             NUMBER   DEFAULT NULL
  , p_qty_to               IN             NUMBER   DEFAULT NULL
  , p_detailed		   IN             NUMBER   DEFAULT 0     -- Bug #3412002
  --End of ER Changes
  , p_view_by              IN             VARCHAR2 DEFAULT NULL  -- Bug #3411938
  , p_responsibility_id    IN             NUMBER   DEFAULT NULL
  , p_resp_application_id  IN             NUMBER   DEFAULT NULL
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_statuses(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  , p_qty_from             IN             NUMBER   DEFAULT NULL
  , p_qty_to               IN             NUMBER   DEFAULT NULL
  --End of ER Changes
  , p_responsibility_id    IN             NUMBER   DEFAULT NULL  -- Bug #3411938
  , p_resp_application_id  IN             NUMBER   DEFAULT NULL
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_subs(
    p_organization_id           IN             NUMBER DEFAULT NULL
  , p_subinventory_code         IN             VARCHAR2 DEFAULT NULL
  , p_locator_id                IN             NUMBER DEFAULT NULL
  , p_inventory_item_id         IN             NUMBER DEFAULT NULL
  , p_revision                  IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_from           IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to             IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from        IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to          IN             VARCHAR2 DEFAULT NULL
  , p_lpn_from                  IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to                    IN             VARCHAR2 DEFAULT NULL
  , p_cost_group_id             IN             NUMBER DEFAULT NULL
  , p_status_id                 IN             NUMBER DEFAULT NULL
  , p_lot_attr_query            IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code          IN             VARCHAR2 DEFAULT NULL
  , p_project_id                IN             NUMBER DEFAULT NULL
  , p_task_id                   IN             NUMBER DEFAULT NULL
  , p_unit_number               IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode           IN             NUMBER DEFAULT NULL
  , p_planning_query_mode       IN             NUMBER DEFAULT NULL
  , p_owning_org                IN             NUMBER DEFAULT NULL
  , p_planning_org              IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query         IN             VARCHAR2 DEFAULT NULL
  , p_only_subinventory_status  IN             NUMBER DEFAULT 1
  , p_node_state                IN             NUMBER
  , p_node_high_value           IN             NUMBER
  , p_node_low_value            IN             NUMBER
  , p_sub_type                  IN             NUMBER  DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description     	IN             VARCHAR2 DEFAULT NULL
  --End of ER Changes
  , x_node_value                IN OUT NOCOPY  NUMBER
  , x_node_tbl                  IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index                 IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_locs(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_only_locator_status  IN             NUMBER DEFAULT 1
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  , p_sub_type             IN             NUMBER  DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  --End of ER Changes
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_cgs(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  , p_qty_from             IN             NUMBER   DEFAULT NULL
  , p_qty_to               IN             NUMBER   DEFAULT NULL
  --End of ER Changes
  , p_responsibility_id    IN             NUMBER   DEFAULT NULL   -- Bug #3411938
  , p_resp_application_id  IN             NUMBER   DEFAULT NULL
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_lpns(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_locator_controlled   IN             NUMBER DEFAULT 0
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id        IN             VARCHAR2 DEFAULT NULL
  , p_prepacked            IN             NUMBER DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  , p_sub_type             IN             NUMBER  DEFAULT NULL --RCVLOCATORSSUPPORT
  , p_inserted_under_org   IN             VARCHAR2 DEFAULT 'N'
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  --End of ER Changes
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_items(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_locator_controlled   IN             NUMBER DEFAULT 0
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_lot_number           IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_serial_number        IN             VARCHAR2 DEFAULT NULL
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id        IN             VARCHAR2 DEFAULT NULL
  , p_containerized        IN             NUMBER DEFAULT 0
  , p_prepacked            IN             NUMBER DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  , p_sub_type             IN             NUMBER  DEFAULT NULL --RCVLOCATORSSUPPORT
  , p_inserted_under_org   IN             VARCHAR2 DEFAULT 'N'
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  --End of ER Changes
  , p_responsibility_id    IN             NUMBER   DEFAULT NULL  -- Bug #3411938
  , p_resp_application_id  IN             NUMBER   DEFAULT NULL
  , p_qty_from             IN             NUMBER   DEFAULT NULL  --Bug #3539766
  , p_qty_to               IN             NUMBER   DEFAULT NULL
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_revs(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_locator_controlled   IN             NUMBER DEFAULT 0
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_lot_number           IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_serial_number        IN             VARCHAR2 DEFAULT NULL
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id        IN             VARCHAR2 DEFAULT NULL
  , p_containerized        IN             NUMBER DEFAULT 0
  , p_prepacked            IN             NUMBER DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  , p_sub_type             IN             NUMBER  DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  --End of ER Changes
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_lots(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_locator_controlled   IN             NUMBER DEFAULT 0
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_revision_controlled  IN             NUMBER DEFAULT 0
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_serial_number        IN             VARCHAR2 DEFAULT NULL
  , p_serial_controlled    IN             NUMBER DEFAULT 0
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id        IN             VARCHAR2 DEFAULT NULL
  , p_containerized        IN             NUMBER DEFAULT 0
  , p_prepacked            IN             NUMBER DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_only_lot_status      IN             NUMBER DEFAULT 1
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  , p_sub_type             IN             NUMBER  DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  --End of ER Changes
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

  PROCEDURE add_serials(
    p_organization_id      IN             NUMBER DEFAULT NULL
  , p_subinventory_code    IN             VARCHAR2 DEFAULT NULL
  , p_locator_id           IN             NUMBER DEFAULT NULL
  , p_locator_controlled   IN             NUMBER DEFAULT 0
  , p_inventory_item_id    IN             NUMBER DEFAULT NULL
  , p_revision             IN             VARCHAR2 DEFAULT NULL
  , p_revision_controlled  IN             NUMBER DEFAULT 0
  , p_lot_number_from      IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        IN             VARCHAR2 DEFAULT NULL
  , p_lot_number           IN             VARCHAR2 DEFAULT NULL
  , p_lot_controlled       IN             NUMBER DEFAULT 0
  , p_serial_number_from   IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     IN             VARCHAR2 DEFAULT NULL
  , p_lpn_from             IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               IN             VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id        IN             VARCHAR2 DEFAULT NULL
  , p_containerized        IN             NUMBER DEFAULT 0
  , p_prepacked            IN             NUMBER DEFAULT NULL
  , p_cost_group_id        IN             NUMBER DEFAULT NULL
  , p_status_id            IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     IN             VARCHAR2 DEFAULT NULL
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_unit_number          IN             VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode      IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  IN             NUMBER DEFAULT NULL
  , p_owning_org           IN             NUMBER DEFAULT NULL
  , p_planning_org         IN             NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query    IN             VARCHAR2 DEFAULT NULL
  , p_only_serial_status   IN             NUMBER DEFAULT 1
  , p_node_state           IN             NUMBER
  , p_node_high_value      IN             NUMBER
  , p_node_low_value       IN             NUMBER
  , p_sub_type             IN             NUMBER  DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description     IN             VARCHAR2 DEFAULT NULL
  --End of ER Changes
  , x_node_value           IN OUT NOCOPY  NUMBER
  , x_node_tbl             IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            IN OUT NOCOPY  NUMBER
  -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL
  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  );

-- NSRIVAST, INVCONV, Start
-- Procedure to give grade nodes for view by Grade
 PROCEDURE add_grades
 (  p_organization_id      	IN             NUMBER DEFAULT NULL
  , p_subinventory_code    	IN             VARCHAR2 DEFAULT NULL
  , p_locator_id	        IN             NUMBER DEFAULT NULL
  , p_locator_controlled   	IN             NUMBER DEFAULT 0
  , p_inventory_item_id    	IN             NUMBER DEFAULT NULL
  , p_revision	                IN             VARCHAR2 DEFAULT NULL
  , p_revision_controlled  	IN             NUMBER DEFAULT 0
  , p_lot_number_from      	IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to        	IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from   	IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to     	IN             VARCHAR2 DEFAULT NULL
  , p_serial_number    	        IN             VARCHAR2 DEFAULT NULL
  , p_grade_from        	IN             VARCHAR2 DEFAULT NULL
  , p_grade_code                IN             VARCHAR2 DEFAULT NULL
  , p_serial_controlled    	IN             NUMBER DEFAULT 0
  , p_lpn_from             	IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to               	IN             VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id        	IN             VARCHAR2 DEFAULT NULL
  , p_containerized        	IN             NUMBER DEFAULT 0
  , p_prepacked            	IN             NUMBER DEFAULT 1
  , p_cost_group_id        	IN             NUMBER DEFAULT NULL
  , p_status_id            	IN             NUMBER DEFAULT NULL
  , p_lot_attr_query       	IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code     	IN             VARCHAR2 DEFAULT NULL
  , p_project_id           	IN             NUMBER DEFAULT NULL
  , p_task_id              	IN             NUMBER DEFAULT NULL
  , p_unit_number          	IN             VARCHAR2 DEFAULT NULL
   -- consinged changes
  , p_owning_qry_mode      	IN             NUMBER DEFAULT NULL
  , p_planning_query_mode  	IN             NUMBER DEFAULT NULL
  , p_owning_org           	IN             NUMBER DEFAULT NULL
  , p_planning_org         	IN             NUMBER DEFAULT NULL
  , p_only_lot_status      	IN             NUMBER DEFAULT 1
   -- consinged changes
  ,  p_serial_attr_query    	IN             VARCHAR2 DEFAULT NULL
   , p_node_state           	IN             NUMBER
  , p_node_high_value      	IN             NUMBER
  , p_node_low_value       	IN             NUMBER
  , p_sub_type             	IN             NUMBER  DEFAULT NULL      --RCVLOCATORSSUPPORT
  , p_item_description     	IN             VARCHAR2 DEFAULT NULL     --ER(3338592) Changes
  , p_qty_from                  IN             NUMBER   DEFAULT NULL
  , p_qty_to                    IN             NUMBER   DEFAULT NULL
  , p_responsibility_id         IN             NUMBER   DEFAULT NULL
  , p_resp_application_id       IN             NUMBER   DEFAULT NULL
  , x_node_value           	IN OUT NOCOPY  NUMBER
  , x_node_tbl             	IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index            	IN OUT NOCOPY  NUMBER
  );
  -- NSRIVAST, INVCONV, End

-- Procedure to get the flexfield structure of mtl_lot_numbers flexfield.
-- This procedure appends the entries to a table that has
-- already been populated
  PROCEDURE get_mln_attributes_structure(
    x_attributes        IN OUT NOCOPY  inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attributes_count  OUT NOCOPY     NUMBER
  , x_return_status     OUT NOCOPY     VARCHAR2
  , x_msg_count         OUT NOCOPY     NUMBER
  , x_msg_data          OUT NOCOPY     NUMBER
  , p_mln_context_code  IN             VARCHAR2);

-- Procedure to get the values populated in MTL_LOT_NUMBERS of the enabled segments
-- This procedure appends the entries to a table that has
-- already been populated
  PROCEDURE get_mln_attributes(
    x_attribute_values   IN OUT NOCOPY  inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attribute_prompts  IN OUT NOCOPY  inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attributes_count   OUT NOCOPY     NUMBER
  , x_return_status      OUT NOCOPY     VARCHAR2
  , x_msg_count          OUT NOCOPY     NUMBER
  , x_msg_data           OUT NOCOPY     NUMBER
  , p_organization_id    IN             NUMBER
  , p_inventory_item_id  IN             NUMBER
  , p_lot_number         IN             VARCHAR2);

  PROCEDURE get_msn_attributes_structure(
    x_attributes        IN OUT NOCOPY  inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attributes_count  OUT NOCOPY     NUMBER
  , x_return_status     OUT NOCOPY     VARCHAR2
  , x_msg_count         OUT NOCOPY     NUMBER
  , x_msg_data          OUT NOCOPY     NUMBER
  , p_msn_context_code  IN             VARCHAR2);

  PROCEDURE get_msn_attributes(
    x_attribute_values   IN OUT NOCOPY  inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attribute_prompts  IN OUT NOCOPY  inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attributes_count   OUT NOCOPY     NUMBER
  , x_return_status      OUT NOCOPY     VARCHAR2
  , x_msg_count          OUT NOCOPY     NUMBER
  , x_msg_data           OUT NOCOPY     NUMBER
  , p_organization_id    IN             NUMBER
  , p_inventory_item_id  IN             NUMBER
  , p_serial_number      IN             VARCHAR2);
END inv_mwb_tree;

 

/
