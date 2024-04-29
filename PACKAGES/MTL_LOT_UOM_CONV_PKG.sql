--------------------------------------------------------
--  DDL for Package MTL_LOT_UOM_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_LOT_UOM_CONV_PKG" AUTHID CURRENT_USER as
/* $Header: INVHLUCS.pls 120.0 2005/05/24 17:57:31 appldev noship $ */

PROCEDURE INSERT_ROW(
  X_CONVERSION_ID           IN OUT NOCOPY NUMBER,
  X_LOT_NUMBER              IN VARCHAR2,
  X_ORGANIZATION_ID         IN NUMBER,
  X_INVENTORY_ITEM_ID       IN NUMBER,
  X_FROM_UNIT_OF_MEASURE    IN VARCHAR2,
  X_FROM_UOM_CODE           IN VARCHAR2,
  X_FROM_UOM_CLASS          IN VARCHAR2,
  X_TO_UNIT_OF_MEASURE      IN VARCHAR2,
  X_TO_UOM_CODE             IN VARCHAR2,
  X_TO_UOM_CLASS            IN VARCHAR2,
  X_CONVERSION_RATE         IN NUMBER,
  X_DISABLE_DATE            IN DATE,
  X_EVENT_SPEC_DISP_ID      IN NUMBER,
  X_CREATED_BY              IN NUMBER,
  X_CREATION_DATE           IN DATE,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  X_REQUEST_ID              IN NUMBER,
  X_PROGRAM_APPLICATION_ID  IN NUMBER,
  X_PROGRAM_ID              IN NUMBER,
  X_PROGRAM_UPDATE_DATE     IN DATE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_ROW(
  X_CONVERSION_ID           IN NUMBER,
  X_LOT_NUMBER              IN VARCHAR2,
  X_ORGANIZATION_ID         IN NUMBER,
  X_INVENTORY_ITEM_ID       IN NUMBER,
  X_FROM_UNIT_OF_MEASURE    IN VARCHAR2,
  X_FROM_UOM_CODE           IN VARCHAR2,
  X_FROM_UOM_CLASS          IN VARCHAR2,
  X_TO_UNIT_OF_MEASURE      IN VARCHAR2,
  X_TO_UOM_CODE             IN VARCHAR2,
  X_TO_UOM_CLASS            IN VARCHAR2,
  X_CONVERSION_RATE         IN NUMBER,
  X_DISABLE_DATE            IN DATE,
  X_EVENT_SPEC_DISP_ID      IN NUMBER,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  X_REQUEST_ID              IN NUMBER,
  X_PROGRAM_APPLICATION_ID  IN NUMBER,
  X_PROGRAM_ID              IN NUMBER,
  X_PROGRAM_UPDATE_DATE     IN DATE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_ROW(
  X_CONVERSION_ID           IN NUMBER,
  X_DISABLE_DATE            IN DATE,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  X_REQUEST_ID              IN NUMBER,
  X_PROGRAM_APPLICATION_ID  IN NUMBER,
  X_PROGRAM_ID              IN NUMBER,
  X_PROGRAM_UPDATE_DATE     IN DATE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE lock_row(
    x_conversion_id                NUMBER
  , x_lot_number                   VARCHAR2
  , x_organization_id              NUMBER
  , x_inventory_item_id            NUMBER
  , x_from_unit_of_measure         VARCHAR2
  , x_from_uom_code                VARCHAR2
  , x_from_uom_class               VARCHAR2
  , x_to_unit_of_measure           VARCHAR2
  , x_to_uom_code                  VARCHAR2
  , x_to_uom_class                 VARCHAR2
  , x_conversion_rate              NUMBER
  , x_disable_date                 DATE
  , x_event_spec_disp_id           NUMBER
  );



END MTL_LOT_UOM_CONV_PKG;

 

/
