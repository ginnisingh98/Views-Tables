--------------------------------------------------------
--  DDL for Package IEX_STRATEGIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGIES_PKG" AUTHID CURRENT_USER as
/* $Header: iextstrs.pls 120.0.12010000.3 2008/08/13 10:53:14 pnaveenk ship $ */
PROCEDURE Insert_Row(
          X_ROWID                 IN OUT NOCOPY VARCHAR2
         ,X_STRATEGY_ID          IN  NUMBER
         ,X_STATUS_CODE           IN VARCHAR2
         ,X_STRATEGY_TEMPLATE_ID  IN  NUMBER
         ,X_DELINQUENCY_ID        IN  NUMBER
         ,X_OBJECT_TYPE           IN VARCHAR2
         ,X_OBJECT_ID             IN  NUMBER
         ,X_CUST_ACCOUNT_ID       IN  NUMBER
         ,X_PARTY_ID              IN  NUMBER
         ,X_SCORE_VALUE           IN  NUMBER
         ,X_NEXT_WORK_ITEM_ID     IN  NUMBER
         ,X_USER_WORK_ITEM_YN     IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER in NUMBER,
          X_CREATION_DATE         in DATE,
          X_CREATED_BY            in NUMBER,
          X_LAST_UPDATE_DATE      in DATE,
          X_LAST_UPDATED_BY       in NUMBER,
          X_LAST_UPDATE_LOGIN     in NUMBER,
          X_REQUEST_ID            in  NUMBER,
          X_PROGRAM_APPLICATION_ID in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE,
	X_CHECKLIST_STRATEGY_ID   IN  NUMBER,
	X_CHECKLIST_YN            IN  VARCHAR2,
        X_STRATEGY_LEVEL          IN  NUMBER,
        X_JTF_OBJECT_TYPE            IN  VARCHAR2,
        X_JTF_OBJECT_ID          IN  NUMBER,
        X_CUSTOMER_SITE_USE_ID         IN  NUMBER,
        X_ORG_ID                  IN NUMBER   --Bug# 6870773 Naveen
        );

PROCEDURE Update_Row(
          X_STRATEGY_ID          IN  NUMBER
         ,X_STATUS_CODE           IN VARCHAR2
         ,X_STRATEGY_TEMPLATE_ID  IN  NUMBER
         ,X_DELINQUENCY_ID        IN  NUMBER
         ,X_OBJECT_TYPE           IN VARCHAR2
         ,X_OBJECT_ID             IN  NUMBER
         ,X_CUST_ACCOUNT_ID       IN  NUMBER
         ,X_PARTY_ID              IN  NUMBER
         ,X_SCORE_VALUE           IN  NUMBER
         ,X_NEXT_WORK_ITEM_ID     IN  NUMBER
         ,X_USER_WORK_ITEM_YN     IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER in NUMBER,
          X_LAST_UPDATE_DATE      in DATE,
          X_LAST_UPDATED_BY       in NUMBER,
          X_LAST_UPDATE_LOGIN     in NUMBER,
          X_REQUEST_ID            in  NUMBER,
          X_PROGRAM_APPLICATION_ID in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE,
		X_CHECKLIST_STRATEGY_ID   IN  NUMBER,
		X_CHECKLIST_YN            IN  VARCHAR2,
        X_STRATEGY_LEVEL          IN  NUMBER,
        X_JTF_OBJECT_TYPE            IN  VARCHAR2,
        X_JTF_OBJECT_ID          IN  NUMBER,
        X_CUSTOMER_SITE_USE_ID         IN  NUMBER,
        X_ORG_ID                       IN NUMBER  --Bug# 6870773 Naveen
        );

/*PROCEDURE Lock_Row(
         X_STRATEGY_ID          IN  NUMBER
         ,X_STATUS_CODE           IN VARCHAR2
         ,X_STRATEGY_TEMPLATE_ID  IN  NUMBER
         ,X_DELINQUENCY_ID        IN  NUMBER
         ,X_OBJECT_TYPE           IN VARCHAR2
         ,X_OBJECT_ID             IN  NUMBER
         ,X_CUST_ACCOUNT_ID       IN  NUMBER
         ,X_PARTY_ID              IN  NUMBER
         ,X_SCORE_VALUE           IN  NUMBER
         ,X_NEXT_WORK_ITEM_ID     IN  NUMBER
         ,X_USER_WORK_ITEM_YN     IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER in NUMBER,
          X_CREATION_DATE         in DATE,
          X_CREATED_BY            in NUMBER,
          X_LAST_UPDATE_DATE      in DATE,
          X_LAST_UPDATED_BY       in NUMBER,
          X_LAST_UPDATE_LOGIN     in NUMBER,
          X_REQUEST_ID            in  NUMBER,
          X_PROGRAM_APPLICATION_ID in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE);
*/

procedure LOCK_ROW (
  X_STRATEGY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);

PROCEDURE Delete_Row(
    X_STRATEGY_ID  NUMBER);
End IEX_STRATEGIES_PKG;

/
