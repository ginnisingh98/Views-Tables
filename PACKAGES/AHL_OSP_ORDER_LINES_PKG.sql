--------------------------------------------------------
--  DDL for Package AHL_OSP_ORDER_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_ORDER_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLOSLS.pls 120.2 2008/01/30 22:21:46 jaramana ship $ */
PROCEDURE INSERT_ROW (
        P_X_OSP_ORDER_LINE_ID       IN OUT NOCOPY NUMBER,
        P_OBJECT_VERSION_NUMBER     IN NUMBER,
        P_LAST_UPDATE_DATE          IN DATE,
        P_LAST_UPDATED_BY           IN NUMBER,
        P_CREATION_DATE             IN DATE,
        P_CREATED_BY                IN NUMBER,
        P_LAST_UPDATE_LOGIN         IN NUMBER,
        P_OSP_ORDER_ID              IN NUMBER,
        P_OSP_LINE_NUMBER           IN NUMBER,
        P_STATUS_CODE               IN VARCHAR2,
        P_PO_LINE_TYPE_ID           IN NUMBER,
        P_SERVICE_ITEM_ID           IN NUMBER,
        P_SERVICE_ITEM_DESCRIPTION  IN VARCHAR2,
        P_SERVICE_ITEM_UOM_CODE     IN VARCHAR2,
        P_NEED_BY_DATE              IN DATE,
        P_SHIP_BY_DATE              IN DATE,
        P_PO_LINE_ID                IN NUMBER,
        P_OE_SHIP_LINE_ID           IN NUMBER,
        P_OE_RETURN_LINE_ID         IN NUMBER,
        P_WORKORDER_ID              IN NUMBER,
        P_OPERATION_ID              IN NUMBER,
        P_QUANTITY                  IN NUMBER,
        P_EXCHANGE_INSTANCE_ID      IN NUMBER,
        P_ATTRIBUTE_CATEGORY        IN VARCHAR2,
        P_ATTRIBUTE1                IN VARCHAR2,
        P_ATTRIBUTE2                IN VARCHAR2,
        P_ATTRIBUTE3                IN VARCHAR2,
        P_ATTRIBUTE4                IN VARCHAR2,
        P_ATTRIBUTE5                IN VARCHAR2,
        P_ATTRIBUTE6                IN VARCHAR2,
        P_ATTRIBUTE7                IN VARCHAR2,
        P_ATTRIBUTE8                IN VARCHAR2,
        P_ATTRIBUTE9                IN VARCHAR2,
        P_ATTRIBUTE10               IN VARCHAR2,
        P_ATTRIBUTE11               IN VARCHAR2,
        P_ATTRIBUTE12               IN VARCHAR2,
        P_ATTRIBUTE13               IN VARCHAR2,
        P_ATTRIBUTE14               IN VARCHAR2,
        P_ATTRIBUTE15               IN VARCHAR2,
        P_INVENTORY_ITEM_ID         IN NUMBER,
        P_INVENTORY_ORG_ID          IN NUMBER,
        P_SUB_INVENTORY             IN VARCHAR2,
        P_LOT_NUMBER                IN VARCHAR2,
        P_SERIAL_NUMBER             IN VARCHAR2,
        P_INVENTORY_ITEM_UOM        IN VARCHAR2,
        P_INVENTORY_ITEM_QUANTITY   IN NUMBER,
        P_PO_REQ_LINE_ID            IN NUMBER  -- Added by jaramana on January 14, 2008 for the Requisition ER 6034236
);

PROCEDURE UPDATE_ROW (
        P_OSP_ORDER_LINE_ID         IN NUMBER,
        P_OBJECT_VERSION_NUMBER     IN NUMBER,
        P_LAST_UPDATE_DATE          IN DATE,
        P_LAST_UPDATED_BY           IN NUMBER,
        P_LAST_UPDATE_LOGIN         IN NUMBER,
        P_OSP_ORDER_ID              IN NUMBER,
        P_OSP_LINE_NUMBER           IN NUMBER,
        P_STATUS_CODE               IN VARCHAR2,
        P_PO_LINE_TYPE_ID           IN NUMBER,
        P_SERVICE_ITEM_ID           IN NUMBER,
        P_SERVICE_ITEM_DESCRIPTION  IN VARCHAR2,
        P_SERVICE_ITEM_UOM_CODE     IN VARCHAR2,
        P_NEED_BY_DATE              IN DATE,
        P_SHIP_BY_DATE              IN DATE,
        P_PO_LINE_ID                IN NUMBER,
        P_OE_SHIP_LINE_ID           IN NUMBER,
        P_OE_RETURN_LINE_ID         IN NUMBER,
        P_WORKORDER_ID              IN NUMBER,
        P_OPERATION_ID              IN NUMBER,
        P_QUANTITY                  IN NUMBER,
        P_EXCHANGE_INSTANCE_ID      IN NUMBER,
        P_INVENTORY_ITEM_ID         IN NUMBER,
        P_INVENTORY_ORG_ID          IN NUMBER,
        P_INVENTORY_ITEM_UOM        IN VARCHAR2,
        P_INVENTORY_ITEM_QUANTITY   IN NUMBER,
        P_SUB_INVENTORY             IN VARCHAR2,
        P_LOT_NUMBER                IN VARCHAR2,
        P_SERIAL_NUMBER             IN VARCHAR2,
        P_PO_REQ_LINE_ID            IN NUMBER,  -- Added by jaramana on January 14, 2008 for the Requisition ER 6034236
        P_ATTRIBUTE_CATEGORY        IN VARCHAR2,
        P_ATTRIBUTE1                IN VARCHAR2,
        P_ATTRIBUTE2                IN VARCHAR2,
        P_ATTRIBUTE3                IN VARCHAR2,
        P_ATTRIBUTE4                IN VARCHAR2,
        P_ATTRIBUTE5                IN VARCHAR2,
        P_ATTRIBUTE6                IN VARCHAR2,
        P_ATTRIBUTE7                IN VARCHAR2,
        P_ATTRIBUTE8                IN VARCHAR2,
        P_ATTRIBUTE9                IN VARCHAR2,
        P_ATTRIBUTE10               IN VARCHAR2,
        P_ATTRIBUTE11               IN VARCHAR2,
        P_ATTRIBUTE12               IN VARCHAR2,
        P_ATTRIBUTE13               IN VARCHAR2,
        P_ATTRIBUTE14               IN VARCHAR2,
        P_ATTRIBUTE15               IN VARCHAR2
);


PROCEDURE DELETE_ROW (
        P_OSP_ORDER_LINE_ID         IN NUMBER
);

END AHL_OSP_ORDER_LINES_PKG; -- Package spec
----------------------------------------------


/
