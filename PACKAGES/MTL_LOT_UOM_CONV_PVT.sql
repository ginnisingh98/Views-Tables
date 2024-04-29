--------------------------------------------------------
--  DDL for Package MTL_LOT_UOM_CONV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_LOT_UOM_CONV_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVLUCS.pls 120.1 2005/07/06 04:19:53 schandru noship $ */


G_TRUE      CONSTANT NUMBER := 1;
G_FALSE     CONSTANT NUMBER := 0;
-- SCHANDRU INVERES Start
G_ERES_ENABLED VARCHAR2(1) :=  NVL(fnd_profile.VALUE('EDR_ERES_ENABLED'), 'N');
-- SCHANDRU INVERES End



FUNCTION validate_update_type (
  p_update_type     IN VARCHAR2)
  return NUMBER;


FUNCTION validate_lot_conversion_rules
( p_organization_id      IN              NUMBER
, p_inventory_item_id    IN              NUMBER
, p_lot_number           IN              VARCHAR2
, p_from_uom_code        IN              VARCHAR2
, p_to_uom_code          IN              VARCHAR2
, p_quantity_updates     IN              NUMBER
, p_update_type          IN              VARCHAR2
, p_header_id            IN              NUMBER DEFAULT NULL
)
  return NUMBER;


PROCEDURE process_conversion_data
( p_action_type          IN              VARCHAR2
, p_update_type_indicator  IN            NUMBER DEFAULT 5
, p_reason_id            IN              NUMBER
, p_batch_id             IN              NUMBER
, p_lot_uom_conv_rec     IN OUT NOCOPY   mtl_lot_uom_class_conversions%ROWTYPE
, p_qty_update_tbl       IN OUT NOCOPY   mtl_lot_uom_conv_pub.quantity_update_rec_type
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, x_sequence             OUT NOCOPY      NUMBER
);

PROCEDURE copy_lot_uom_conversions
( p_inventory_item_id   IN NUMBER,
  p_from_organization_id  IN NUMBER,
  p_from_lot_number     IN VARCHAR2,
  p_to_organization_id  IN NUMBER,
  p_to_lot_number       IN VARCHAR2,
  p_user_id             IN NUMBER,
  p_creation_date       IN DATE,
  p_commit              IN VARCHAR2,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2
);




FUNCTION validate_onhand_equals_avail (
  p_organization_id        IN NUMBER,
  p_inventory_item_id      IN NUMBER,
  p_lot_number             IN VARCHAR2,
  p_header_id              IN NUMBER)
  return NUMBER;

END MTL_LOT_UOM_CONV_PVT;

 

/
