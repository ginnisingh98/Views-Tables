--------------------------------------------------------
--  DDL for Package INV_MWB_CG_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_CG_TRANSFER" AUTHID CURRENT_USER AS
/* $Header: INVCGTRS.pls 120.2 2005/06/17 03:23:09 appldev  $ */

   PROCEDURE TRANSFER(
                       X_RETURN_STATUS          OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                       X_MSG_COUNT              OUT NOCOPY /* file.sql.39 change */    NUMBER,
                       X_MSG_DATA               OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                       X_TRANSACTION_HEADER_ID  IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                       P_IS_REVISION_CONTROLLED IN     VARCHAR2,
                       P_IS_LOT_CONTROLLED      IN     VARCHAR2,
                       P_IS_SERIAL_CONTROLLED   IN     VARCHAR2,
                       P_ORG_ID                 IN     NUMBER,
                       P_INVENTORY_ITEM_ID      IN     NUMBER,
                       P_REVISION               IN     VARCHAR2,
                       P_SUBINVENTORY           IN     VARCHAR2,
                       P_LOCATOR_ID             IN     NUMBER,
                       P_LPN_ID                 IN     NUMBER,
                       P_LOT_NUMBER             IN     VARCHAR2,
                       P_EXP_DATE               IN     DATE,
                       P_SERIAL_NUMBER          IN     VARCHAR2,
                       P_ONHAND                 IN     NUMBER,
                       P_AVAILABILITY           IN     NUMBER,
                       P_UOM                    IN     VARCHAR2,
                       P_PRIMARY_UOM            IN     VARCHAR2,
                       P_COSTGROUP_ID           IN     NUMBER,
                       P_XFR_COSTGROUP_ID       IN     NUMBER,
                       P_USER_ID                IN     NUMBER
                      );

   PROCEDURE VALIDATE(
                       X_RETURN_STATUS          OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                       X_MSG_COUNT              OUT NOCOPY /* file.sql.39 change */    NUMBER,
                       X_MSG_DATA               OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                       X_ONHAND                 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                       X_AVAILABILITY           IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                       P_IS_REVISION_CONTROLLED IN     VARCHAR2,
                       P_IS_LOT_CONTROLLED      IN     VARCHAR2,
                       P_IS_SERIAL_CONTROLLED   IN     VARCHAR2,
                       P_ORG_ID                 IN     NUMBER,
                       P_INVENTORY_ITEM_ID      IN     NUMBER,
                       P_REVISION               IN     VARCHAR2,
                       P_SUBINVENTORY           IN     VARCHAR2,
                       P_LOCATOR_ID             IN     NUMBER,
                       P_LPN_ID                 IN     NUMBER,
                       P_LOT_NUMBER             IN     VARCHAR2,
                       P_SERIAL_NUMBER          IN     VARCHAR2,
                       P_IS_LPN_REQUIRED        IN     VARCHAR2,
                       P_COST_GROUP_ID          IN     NUMBER
                      );

   PROCEDURE UPDATE_QUANTITY_TREE(
                                  X_RETURN_STATUS          OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                                  X_MSG_COUNT              OUT NOCOPY /* file.sql.39 change */    NUMBER,
                                  X_MSG_DATA               OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                                  P_IS_LOT_CONTROLLED      IN     VARCHAR2,
                                  P_IS_SERIAL_CONTROLLED   IN     VARCHAR2,
                                  P_IS_LPN_REQUIRED        IN     VARCHAR2,
                                  P_ORG_ID                 IN     NUMBER,
                                  P_INVENTORY_ITEM_ID      IN     NUMBER,
                                  P_REVISION               IN     VARCHAR2,
                                  P_SUBINVENTORY           IN     VARCHAR2,
                                  P_LOCATOR_ID             IN     NUMBER,
                                  P_LOT_NUMBER             IN     VARCHAR2,
                                  P_ONHAND                 IN     NUMBER,
                                  P_UOM                    IN     VARCHAR2,
                                  P_PRIMARY_UOM            IN     VARCHAR2,
                                  P_COSTGROUP_ID           IN     NUMBER,
                                  P_XFR_COSTGROUP_ID       IN     NUMBER
                                 );

END INV_MWB_CG_TRANSFER;

 

/
