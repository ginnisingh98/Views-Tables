--------------------------------------------------------
--  DDL for Package IEX_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_COSTS_PKG" AUTHID CURRENT_USER as
/* $Header: iextcoss.pls 120.0 2004/01/24 03:21:32 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_COSTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          X_ROWID                   in out NOCOPY VARCHAR2,
          p_COST_ID                 IN NUMBER,
          p_CASE_ID                 IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
          p_COST_TYPE_CODE          IN VARCHAR2,
          p_COST_ITEM_TYPE_CODE     IN VARCHAR2,
          p_COST_ITEM_TYPE_DESC     IN VARCHAR2,
          p_COST_ITEM_AMOUNT        IN NUMBER,
          p_COST_ITEM_CURRENCY_CODE IN VARCHAR2,
          p_COST_ITEM_QTY           IN NUMBER,
          p_COST_ITEM_DATE          IN DATE,
          p_FUNCTIONAL_AMOUNT       IN NUMBER,
          p_EXCHANGE_TYPE           IN VARCHAR2,
          p_EXCHANGE_RATE           IN NUMBER,
          p_EXCHANGE_DATE           IN DATE,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          P_COST_ITEM_APPROVED      IN VARCHAR2,
          p_active_flag             IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID  IN NUMBER,
          p_PROGRAM_ID              IN NUMBER,
          p_PROGRAM_UPDATE_DATE     IN DATE,
          p_ATTRIBUTE_CATEGORY      IN VARCHAR2,
          p_ATTRIBUTE1              IN VARCHAR2,
          p_ATTRIBUTE2              IN VARCHAR2,
          p_ATTRIBUTE3              IN VARCHAR2,
          p_ATTRIBUTE4              IN VARCHAR2,
          p_ATTRIBUTE5              IN VARCHAR2,
          p_ATTRIBUTE6              IN VARCHAR2,
          p_ATTRIBUTE7             IN VARCHAR2,
          p_ATTRIBUTE8             IN VARCHAR2,
          p_ATTRIBUTE9             IN VARCHAR2,
          p_ATTRIBUTE10            IN VARCHAR2,
          p_ATTRIBUTE11            IN VARCHAR2,
          p_ATTRIBUTE12            IN VARCHAR2,
          p_ATTRIBUTE13            IN VARCHAR2,
          p_ATTRIBUTE14            IN VARCHAR2,
          p_ATTRIBUTE15            IN VARCHAR2,
          p_CREATED_BY             IN VARCHAR2,
          p_CREATION_DATE          IN DATE,
          p_LAST_UPDATED_BY        IN NUMBER,
          p_LAST_UPDATE_DATE       IN DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER
     );

PROCEDURE Update_Row(
          p_COST_ID                 IN NUMBER,
          p_CASE_ID                 IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
          p_COST_TYPE_CODE          IN VARCHAR2,
          p_COST_ITEM_TYPE_CODE     IN VARCHAR2,
          p_COST_ITEM_TYPE_DESC     IN VARCHAR2,
          p_COST_ITEM_AMOUNT        IN NUMBER,
          p_COST_ITEM_CURRENCY_CODE IN VARCHAR2,
          p_COST_ITEM_QTY           IN NUMBER,
          p_COST_ITEM_DATE          IN DATE,
          p_FUNCTIONAL_AMOUNT       IN NUMBER,
          p_EXCHANGE_TYPE           IN VARCHAR2,
          p_EXCHANGE_RATE           IN NUMBER,
          p_EXCHANGE_DATE           IN DATE,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          P_COST_ITEM_APPROVED      IN VARCHAR2,
          p_active_flag             IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID  IN NUMBER,
          p_PROGRAM_ID              IN NUMBER,
          p_PROGRAM_UPDATE_DATE     IN DATE,
          p_ATTRIBUTE_CATEGORY      IN VARCHAR2,
          p_ATTRIBUTE1              IN VARCHAR2,
          p_ATTRIBUTE2              IN VARCHAR2,
          p_ATTRIBUTE3              IN VARCHAR2,
          p_ATTRIBUTE4              IN VARCHAR2,
          p_ATTRIBUTE5              IN VARCHAR2,
          p_ATTRIBUTE6              IN VARCHAR2,
          p_ATTRIBUTE7             IN VARCHAR2,
          p_ATTRIBUTE8             IN VARCHAR2,
          p_ATTRIBUTE9             IN VARCHAR2,
          p_ATTRIBUTE10            IN VARCHAR2,
          p_ATTRIBUTE11            IN VARCHAR2,
          p_ATTRIBUTE12            IN VARCHAR2,
          p_ATTRIBUTE13            IN VARCHAR2,
          p_ATTRIBUTE14            IN VARCHAR2,
          p_ATTRIBUTE15            IN VARCHAR2,
          p_LAST_UPDATED_BY        IN NUMBER,
          p_LAST_UPDATE_DATE       IN DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER
);

procedure LOCK_ROW (
  p_COST_ID               in NUMBER,
  p_OBJECT_VERSION_NUMBER in NUMBER);
/*
PROCEDURE Lock_Row(
          p_CASE_ID                 IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
          p_COST_TYPE_CODE          IN VARCHAR2,
          p_COST_ITEM_TYPE_CODE     IN VARCHAR2,
          p_COST_ITEM_TYPE_DESC     IN VARCHAR2,
          p_COST_ITEM_AMOUNT        IN NUMBER,
          p_COST_ITEM_CURRENCY_CODE IN VARCHAR2,
          p_COST_ITEM_QTY           IN NUMBER,
          p_COST_ITEM_DATE          IN DATE,
          p_FUNCTIONAL_AMOUNT       IN NUMBER,
          p_EXCHANGE_TYPE           IN VARCHAR2,
          p_EXCHANGE_RATE           IN NUMBER,
          p_EXCHANGE_DATE           IN DATE,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          P_COST_ITEM_APPROVED      IN VARCHAR2
          p_active_flag             IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID  IN NUMBER,
          p_PROGRAM_ID              IN NUMBER,
          p_PROGRAM_UPDATE_DATE     IN DATE,
          p_ATTRIBUTE_CATEGORY      IN VARCHAR2,
          p_ATTRIBUTE1              IN VARCHAR2,
          p_ATTRIBUTE2              IN VARCHAR2,
          p_ATTRIBUTE3              IN VARCHAR2,
          p_ATTRIBUTE4              IN VARCHAR2,
          p_ATTRIBUTE5              IN VARCHAR2,
          p_ATTRIBUTE6              IN VARCHAR2,
          p_ATTRIBUTE7             IN VARCHAR2,
          p_ATTRIBUTE8             IN VARCHAR2,
          p_ATTRIBUTE9             IN VARCHAR2,
          p_ATTRIBUTE10            IN VARCHAR2,
          p_ATTRIBUTE11            IN VARCHAR2,
          p_ATTRIBUTE12            IN VARCHAR2,
          p_ATTRIBUTE13            IN VARCHAR2,
          p_ATTRIBUTE14            IN VARCHAR2,
          p_ATTRIBUTE15            IN VARCHAR2,
          p_CREATED_BY             IN VARCHAR2,
          p_CREATION_DATE          IN DATE,
          p_LAST_UPDATED_BY        IN NUMBER,
          p_LAST_UPDATE_DATE       IN DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER
);
*/

PROCEDURE Delete_Row(
    p_COST_ID  IN NUMBER);
End IEX_COSTS_PKG;

 

/
