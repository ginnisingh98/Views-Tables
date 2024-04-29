--------------------------------------------------------
--  DDL for Package WMS_TASK_DISPATCH_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_DISPATCH_ENGINE" AUTHID CURRENT_USER AS
/* $Header: WMSTDENS.pls 120.0.12010000.3 2010/03/14 17:24:09 kjujjuru ship $*/

--
-- File        : WMSTDENS.pls
-- Content     : WMS_task_schedule package specification
-- Description : WMS task dispatching API for mobile application
-- Notes       :
-- Modified    : 05/01/2000 lezhang created
--               09/06/2000 add task split, consolidation apis


-- API name    : dispatch_task
-- Type        : Private
-- Function    : Return a group of tasks that a sign-on employee is eligible
--               to perform
--               Or return a group of picking tasks with the same picking
--               methodology and pick slip number. This group of tasks includes
--               the most optimal task based on priority, locator picking
--               sequence, coordinates approximation, etc.
--               or reservation input parameters and creates recommendations
-- Pre-reqs    : 1. For each record in MTL_MATERIAL_TRANSACTIONS_TEMP, user
--               defined task type (standard_operation_id column ) has been
--               assigned,
--               2. System task type (wms_task_type column) has been assigned
--               3. Pick methdology code (pick_rule_id column) and pick slip
--               number (pick_slip_number column) has been assigned
--
-- Parameters  :
--   p_api_version          Standard Input Parameter
--   p_init_msg_list        Standard Input Parameter
--   p_commit               Standard Input Parameter
--   p_validation_level     Standard Input Parameter
--   p_sign_on_emp_id       NUMBER, sign on emplployee ID, mandatory
--   p_sign_on_org_id       NUMBER, org ID, mandatory
--   p_sign_on_zone         VARCHAR2, sign on sub ID, optional
--   p_sign_on_equipment_id NUMBER, sign on equipment item ID, optional,
--                          can be a specific number, NULL or -999,
--                          -999 means none
--   p_sign_on_equipment_srl   VARCHAR2, sign on equipment serial num, optional
--                          can be a specific serial number, NULL or '@@@',
--                          '@@@' means none
--   p_task_type            VARCHAR2, system task type this API will return,
--                          can be 'PICKING' or 'ALL'
--
--
-- Output Parameters
--   x_return_status        Standard Output Parameter
--   x_msg_count            Standard Output Parameter
--   x_msg_data             Standard Output Parameter
--   x_task_cur             Reference Cursor to deliver the queried tasks
--                          It includes following fields:
--                          mmtt.transaction_temp_id    NUMBER
--                          mmtt.subinventory_code      VARCHAR2
--                          mmtt.locator_id             NUMBER
--                          mmtt.revision               VARCHAR2
--                          mmtt.transaction_uom        VARCHAR2
--                          mmtt.transaction_quantity   NUMBER
--                          mmtt.lot_number             NUMBER
--
--
-- Version
--   Currently version is 1.0
--



TYPE task_rec_cur_tp IS REF CURSOR;

-- APL procedure
PROCEDURE dispatch_task
  (p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_sign_on_emp_id     IN NUMBER,
   p_sign_on_org_id     IN NUMBER,
   p_sign_on_zone       IN VARCHAR2 := NULL,
   p_sign_on_equipment_id     IN NUMBER := NULL,  -- specific equip id, NULL or -999. -999 stands for none
   p_sign_on_equipment_srl    IN VARCHAR2 := NULL,  -- same as above
   p_task_filter              IN            VARCHAR2,
   p_task_method              IN            VARCHAR2,
   x_grouping_document_type   IN OUT nocopy VARCHAR2,
   x_grouping_document_number IN OUT nocopy NUMBER,
   x_grouping_source_type_id  IN OUT nocopy NUMBER,
   x_task_cur           OUT NOCOPY task_rec_cur_tp,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2);

PROCEDURE dispatch_task
  (p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_sign_on_emp_id     IN NUMBER,
   p_sign_on_org_id     IN NUMBER,
   p_sign_on_zone       IN VARCHAR2 := NULL,
   p_sign_on_equipment_id     IN NUMBER := NULL,  -- specific equip id, NULL or -999. -999 stands for none
   p_sign_on_equipment_srl    IN VARCHAR2 := NULL,  -- same as above
   p_task_type          IN VARCHAR2,  -- 'PICKING' or 'ALL' to determine the API is called for dispatching picking tasks or displaying all tasks
   p_cartonization_id   IN NUMBER := NULL,
   x_task_cur           OUT NOCOPY task_rec_cur_tp,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2);

-- high volume project
  Procedure Duplicate_lot_serial_in_parent(
                  p_parent_transaction_temp_id     NUMBER
                  , x_return_status        OUT NOCOPY    VARCHAR2
                  , x_msg_count            OUT NOCOPY    NUMBER
                  , x_msg_data             OUT NOCOPY    VARCHAR2);


-- CP Enhancements
 -- Overridden this procedure to support cluster picking
PROCEDURE dispatch_task
  (p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_sign_on_emp_id     IN NUMBER,
   p_sign_on_org_id     IN NUMBER,
   p_sign_on_zone       IN VARCHAR2 := NULL,
   p_sign_on_equipment_id     IN NUMBER := NULL,  -- specific equip id, NULL or -999. -999 stands for none
   p_sign_on_equipment_srl    IN VARCHAR2 := NULL,  -- same as above
   p_task_type          IN VARCHAR2,  -- 'PICKING' or 'ALL' to determine the API is called for dispatching picking tasks or displaying all tasks
   p_task_filter        IN  VARCHAR2 := null,
   p_cartonization_id   IN NUMBER := NULL,
   x_task_cur           OUT NOCOPY task_rec_cur_tp,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_max_clusters       IN    NUMBER := 0,
   x_deliveries_list    OUT   nocopy VARCHAR2,
   x_cartons_list       OUT   nocopy VARCHAR2);


PROCEDURE split_task
  (p_api_version NUMBER,
   p_task_id NUMBER,
   p_commit VARCHAR2 := fnd_api.g_false,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data  OUT NOCOPY VARCHAR2);



PROCEDURE split_tasks
  (p_api_version NUMBER,
   p_move_order_header_id NUMBER,
   p_commit VARCHAR2 := fnd_api.g_false,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data  OUT NOCOPY VARCHAR2);



PROCEDURE consolidate_bulk_tasks
  (p_api_version            IN NUMBER,
   p_commit                 IN VARCHAR2 := fnd_api.g_false,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_move_order_header_id   IN NUMBER);

/* -------------------------------------------------------
   The following two APIs are defined for patchset J bulk picking
   enhancement

   is_serial_allocated is to check if the serial numbers is allocated
   or not.

    consolidate_bulk_tasks_for_so is to implement the new logic for
    bulk picking, works for sales order only for patchset J
*/

PROCEDURE consolidate_bulk_tasks_for_so
  (p_api_version            IN NUMBER,
   p_commit                 IN VARCHAR2 := fnd_api.g_false,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_move_order_header_id   IN NUMBER);

/* end of patchset J bulk picking */

FUNCTION is_equipment_cap_exceeded
  (p_standard_operation_id   IN NUMBER,
   p_item_id IN NUMBER,
   p_organization_id IN NUMBER,
   p_txn_qty  IN NUMBER,
   p_txn_uom_code IN VARCHAR2)
  RETURN VARCHAR2;

/*******************************************
* API to insert a record into mmtt
* Created by cjandhya originally
********************************************/

PROCEDURE insert_mmtt
  (l_mmtt_rec mtl_material_transactions_temp%ROWTYPE);


/*******************************************
* API to insert a record into wms_cartonization_temp
* Created by cjandhya originally
********************************************/


PROCEDURE insert_wct
  (l_wct_rec wms_cartonization_temp%ROWTYPE);

  PROCEDURE insert_mtlt   --Bug 9265033 added procedure
  (p_transaction_temp_id            IN NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2);


END wms_task_dispatch_engine;


/
