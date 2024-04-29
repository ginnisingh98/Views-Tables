--------------------------------------------------------
--  DDL for Package CSD_PRODUCT_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_PRODUCT_TRANSACTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtptxs.pls 120.2.12000000.2 2007/06/27 22:47:22 swai ship $ */

PROCEDURE Insert_Row(
          px_PRODUCT_TRANSACTION_ID   IN OUT NOCOPY NUMBER,
          p_REPAIR_LINE_ID            NUMBER,
          p_ESTIMATE_DETAIL_ID        NUMBER,
          p_ACTION_TYPE               VARCHAR2,
          p_ACTION_CODE               VARCHAR2,
          p_LOT_NUMBER                VARCHAR2,
          p_SUB_INVENTORY             VARCHAR2,
          p_INTERFACE_TO_OM_FLAG      VARCHAR2,
          p_BOOK_SALES_ORDER_FLAG     VARCHAR2,
          p_RELEASE_SALES_ORDER_FLAG  VARCHAR2,
          p_SHIP_SALES_ORDER_FLAG     VARCHAR2,
          p_PROD_TXN_STATUS           VARCHAR2,
          p_PROD_TXN_CODE             VARCHAR2,
          p_LAST_UPDATE_DATE          DATE,
          p_CREATION_DATE             DATE,
          p_LAST_UPDATED_BY           NUMBER,
          p_CREATED_BY                NUMBER,
          p_LAST_UPDATE_LOGIN         NUMBER,
          p_ATTRIBUTE1                VARCHAR2,
          p_ATTRIBUTE2                VARCHAR2,
          p_ATTRIBUTE3                VARCHAR2,
          p_ATTRIBUTE4                VARCHAR2,
          p_ATTRIBUTE5                VARCHAR2,
          p_ATTRIBUTE6                VARCHAR2,
          p_ATTRIBUTE7                VARCHAR2,
          p_ATTRIBUTE8                VARCHAR2,
          p_ATTRIBUTE9                VARCHAR2,
          p_ATTRIBUTE10               VARCHAR2,
          p_ATTRIBUTE11               VARCHAR2,
          p_ATTRIBUTE12               VARCHAR2,
          p_ATTRIBUTE13               VARCHAR2,
          p_ATTRIBUTE14               VARCHAR2,
          p_ATTRIBUTE15               VARCHAR2,
          p_CONTEXT                   VARCHAR2,
          p_OBJECT_VERSION_NUMBER     NUMBER,
          P_REQ_HEADER_ID             NUMBER,
          P_REQ_LINE_ID               NUMBER,
          P_ORDER_HEADER_ID           NUMBER,
          P_ORDER_LINE_ID             NUMBER,
          P_PRD_TXN_QTY_RECEIVED      NUMBER,
          P_PRD_TXN_QTY_SHIPPED       NUMBER,
          P_SOURCE_SERIAL_NUMBER      VARCHAR2,
          P_SOURCE_INSTANCE_ID        NUMBER,
          P_NON_SOURCE_SERIAL_NUMBER  VARCHAR2,
          P_NON_SOURCE_INSTANCE_ID    NUMBER,
          P_LOCATOR_ID                NUMBER,
          P_SUB_INVENTORY_RCVD        VARCHAR2,
          P_LOT_NUMBER_RCVD           VARCHAR2,
          P_picking_rule_id           NUMBER,   -- R12 dEvelopment changes
          P_PROJECT_ID                NUMBER,   --taklam
          P_TASK_ID                   NUMBER,
          P_UNIT_NUMBER               VARCHAR2,
		-- swai: bug 6148019 internal po for 3rd party
          P_INTERNAL_PO_HEADER_ID     NUMBER    := Fnd_API.G_MISS_NUM
      );



PROCEDURE Update_Row(
          p_PRODUCT_TRANSACTION_ID     NUMBER,
          p_REPAIR_LINE_ID             NUMBER,
          p_ESTIMATE_DETAIL_ID         NUMBER,
          p_ACTION_TYPE                VARCHAR2,
          p_ACTION_CODE                VARCHAR2,
          p_LOT_NUMBER                 VARCHAR2,
          p_SUB_INVENTORY              VARCHAR2,
          p_INTERFACE_TO_OM_FLAG       VARCHAR2,
          p_BOOK_SALES_ORDER_FLAG      VARCHAR2,
          p_RELEASE_SALES_ORDER_FLAG   VARCHAR2,
          p_SHIP_SALES_ORDER_FLAG      VARCHAR2,
          p_PROD_TXN_STATUS            VARCHAR2,
          p_PROD_TXN_CODE              VARCHAR2,
          p_LAST_UPDATE_DATE           DATE,
          p_CREATION_DATE              DATE,
          p_LAST_UPDATED_BY            NUMBER,
          p_CREATED_BY                 NUMBER,
          p_LAST_UPDATE_LOGIN          NUMBER,
          p_ATTRIBUTE1                 VARCHAR2,
          p_ATTRIBUTE2                 VARCHAR2,
          p_ATTRIBUTE3                 VARCHAR2,
          p_ATTRIBUTE4                 VARCHAR2,
          p_ATTRIBUTE5                 VARCHAR2,
          p_ATTRIBUTE6                 VARCHAR2,
          p_ATTRIBUTE7                 VARCHAR2,
          p_ATTRIBUTE8                 VARCHAR2,
          p_ATTRIBUTE9                 VARCHAR2,
          p_ATTRIBUTE10                VARCHAR2,
          p_ATTRIBUTE11                VARCHAR2,
          p_ATTRIBUTE12                VARCHAR2,
          p_ATTRIBUTE13                VARCHAR2,
          p_ATTRIBUTE14                VARCHAR2,
          p_ATTRIBUTE15                VARCHAR2,
          p_CONTEXT                    VARCHAR2,
          p_OBJECT_VERSION_NUMBER      NUMBER,
          P_REQ_HEADER_ID              NUMBER,
          P_REQ_LINE_ID                NUMBER,
          P_ORDER_HEADER_ID            NUMBER,
          P_ORDER_LINE_ID              NUMBER,
          P_PRD_TXN_QTY_RECEIVED       NUMBER,
          P_PRD_TXN_QTY_SHIPPED        NUMBER,
          P_SOURCE_SERIAL_NUMBER       VARCHAR2,
          P_SOURCE_INSTANCE_ID         NUMBER,
          P_NON_SOURCE_SERIAL_NUMBER   VARCHAR2,
          P_NON_SOURCE_INSTANCE_ID     NUMBER,
          P_LOCATOR_ID                 NUMBER,
          P_SUB_INVENTORY_RCVD         VARCHAR2,
          P_LOT_NUMBER_RCVD            VARCHAR2,
          P_picking_rule_id            NUMBER,  -- R12 dEvelopment changes
          P_PROJECT_ID                 NUMBER,  --taklam
          P_TASK_ID                    NUMBER,
          P_UNIT_NUMBER                VARCHAR2,
		-- swai: bug 6148019 internal po for 3rd party
          P_INTERNAL_PO_HEADER_ID      NUMBER := Fnd_API.G_MISS_NUM

      );


PROCEDURE Lock_Row(
          p_PRODUCT_TRANSACTION_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_PRODUCT_TRANSACTION_ID  NUMBER);
End CSD_PRODUCT_TRANSACTIONS_PKG;

 

/
