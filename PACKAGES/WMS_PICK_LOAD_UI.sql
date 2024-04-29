--------------------------------------------------------
--  DDL for Package WMS_PICK_LOAD_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PICK_LOAD_UI" AUTHID CURRENT_USER AS
/* $Header: WMSPLUIS.pls 120.0.12010000.3 2008/08/04 19:34:00 ssrikaku ship $ */

TYPE t_genref IS REF CURSOR;

PROCEDURE validate_subinventory(p_organization_id                     IN  NUMBER,
                                p_item_id                             IN  NUMBER,
                                p_subinventory_code                   IN  VARCHAR2,
                                p_restrict_subinventories_code        IN  NUMBER,
                                p_transaction_type_id                 IN  NUMBER,
                                x_is_valid_subinventory               OUT nocopy VARCHAR2,
                                x_is_lpn_controlled                   OUT nocopy VARCHAR2,
                                x_message                             OUT nocopy VARCHAR2);
			      --x_alias_enabled                       OUT nocopy VARCHAR2);commented Bug 7225845

PROCEDURE validate_locator_lpn
  (p_organization_id        IN         NUMBER,
   p_restrict_locators_code IN         NUMBER,
   p_inventory_item_id      IN         NUMBER,
   p_revision               IN         VARCHAR2,
   p_locator_lpn            IN         VARCHAR2,
   p_subinventory_code      IN         VARCHAR2,
   p_transaction_temp_id    IN         NUMBER,
   p_transaction_type_id    IN         NUMBER,
   p_project_id             IN         NUMBER,
   p_task_id                IN         NUMBER,
   p_allocated_lpn          IN         VARCHAR2,
   p_suggested_loc          IN         VARCHAR2,
   p_suggested_loc_id       IN         NUMBER,
   p_suggested_sub          IN         VARCHAR2,
   p_serial_allocated       IN         VARCHAR2,
   p_allow_locator_change   IN         VARCHAR2,
   p_is_loc_or_lpn          IN         VARCHAR2,
   x_is_valid_locator       OUT nocopy VARCHAR2,
   x_is_valid_lpn           OUT nocopy VARCHAR2,
   x_subinventory_code      OUT nocopy VARCHAR2,
   x_locator                OUT nocopy VARCHAR2,
   x_locator_id             OUT nocopy NUMBER,
   x_lpn_id                 OUT nocopy NUMBER,
   x_is_lpn_controlled      OUT nocopy VARCHAR2,
   x_return_status          OUT nocopy VARCHAR2,
   x_msg_count              OUT nocopy NUMBER,
   x_msg_data               OUT nocopy VARCHAR2);

END wms_pick_load_ui;

/
