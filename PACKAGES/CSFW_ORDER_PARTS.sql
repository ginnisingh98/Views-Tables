--------------------------------------------------------
--  DDL for Package CSFW_ORDER_PARTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_ORDER_PARTS" AUTHID CURRENT_USER AS
/* $Header: csfwords.pls 120.1 2007/12/18 13:51:32 htank ship $ */
--
-- Purpose: To create parts order for Field Service Wireless
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- mmerchan	10/23/01	Created
-- mmerchan	05/23/02	Added task_id, task_assignment_id
-- htank    18-Dec-2007    Bug # 5242440


 PROCEDURE process_order
 ( order_type_id             IN NUMBER,
   ship_to_location_id       IN NUMBER,
   dest_organization_id      IN NUMBER,
   operation                 IN VARCHAR2,
   need_by_date		     IN DATE,
   inventory_item_id         IN NUMBER,
   revision                  IN VARCHAR2,
   unit_of_measure           IN VARCHAR2,
   ordered_quantity          IN NUMBER,
   task_id		     IN NUMBER,
   task_assignment_id	     IN NUMBER,
   order_number		     OUT NOCOPY NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_error_msg               OUT NOCOPY VARCHAR2
  );


PROCEDURE process_order
(order_type_id             IN NUMBER,
ship_to_location_id       IN NUMBER,
shipping_method_code      IN VARCHAR2,
task_id                   IN NUMBER,
task_assignment_id        IN NUMBER,
need_by_date              IN DATE ,
dest_organization_id      IN NUMBER,
operation                 IN VARCHAR2,
resource_type             IN VARCHAR2,
resource_id               IN NUMBER,
inventory_item_id         IN NUMBER,
revision                  IN VARCHAR2,
unit_of_measure           IN VARCHAR2,
source_organization_id    IN NUMBER,
source_subinventory       IN VARCHAR2,
ordered_quantity          IN NUMBER,
order_number		  OUT NOCOPY NUMBER,
x_return_status           OUT NOCOPY VARCHAR2,
x_error_msg               OUT NOCOPY VARCHAR2 );


PROCEDURE CREATE_MOVE_ORDER
(  p_organization_id        IN NUMBER
  ,p_from_subinventory_code IN VARCHAR2
  ,p_from_locator_id        IN NUMBER
  ,p_inventory_item_id      IN NUMBER
  ,p_revision               IN VARCHAR2
  ,p_lot_number             IN VARCHAR2
  ,p_serial_number_start    IN VARCHAR2
  ,p_serial_number_end      IN VARCHAR2
  ,p_quantity               IN NUMBER
  ,p_uom_code               IN VARCHAR2
  ,p_to_subinventory_code   IN VARCHAR2
  ,p_to_locator_id          IN NUMBER
  ,p_date_required          IN DATE
  ,p_comments               IN VARCHAR2
  ,x_move_order_number      OUT NOCOPY VARCHAR2
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2 );



PROCEDURE TRANSACT_MOVE_ORDER
( p_type_of_transaction IN VARCHAR2,
  p_inventory_item_id IN NUMBER,
  p_organization_id   IN NUMBER,
  p_source_sub        IN VARCHAR2,
  p_source_locator    IN NUMBER,
  p_lot               IN VARCHAR2,
  p_revision          IN VARCHAR2,
  p_serial_number     IN VARCHAR2,
  p_qty               IN NUMBER,
  p_uom               IN VARCHAR2,
  p_line_id           IN NUMBER DEFAULT NULL,
  p_dest_sub          IN VARCHAR2,
  p_dest_org_id       IN NUMBER DEFAULT NULL,
  p_dest_locator      IN NUMBER DEFAULT NULL,
  p_waybill           IN VARCHAR2 DEFAULT NULL,
  p_ship_Nr           IN VARCHAR2 DEFAULT NULL,
  p_freight_code      IN VARCHAR2 DEFAULT NULL,
  p_exp_del_date      IN VARCHAR2 DEFAULT NULL,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2 );


PROCEDURE RECEIVE_HEADER
(p_header_id in NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2 );



END CSFW_ORDER_PARTS; -- Package spec

/
