--------------------------------------------------------
--  DDL for Package IEX_WRITEOFFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WRITEOFFS_PKG" AUTHID CURRENT_USER as
/* $Header: iextwros.pls 120.1 2007/10/31 13:00:09 ehuh ship $ */
-- Start of Comments
-- Package name     : IEX_WRITEOFFS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          X_ROWID                   IN out NOCOPY VARCHAR2,
          p_WRITEOFF_ID             IN NUMBER,
          p_PARTY_ID                IN NUMBER,
          p_DELINQUENCY_ID                IN NUMBER,
          p_CAS_ID                  IN NUMBER,
          p_CUST_ACCOUNT_ID         IN NUMBER,
          p_DISPOSITION_CODE        IN VARCHAR2,
          p_OBJECT_ID               IN NUMBER,
          p_OBJECT_CODE             IN VARCHAR2,
          p_WRITEOFF_TYPE           IN VARCHAR2,
          p_ACTIVE_FLAG             IN VARCHAR2,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          p_WRITEOFF_REASON         IN VARCHAR2,
          p_WRITEOFF_AMOUNT         IN NUMBER,
          p_WRITEOFF_CURRENCY_CODE  IN VARCHAR2,
          p_WRITEOFF_DATE           IN DATE,
          p_WRITEOFF_REQUEST_DATE   IN  DATE,
          p_WRITEOFF_PROCESS        IN VARCHAR2,
          p_WRITEOFF_SCORE          IN VARCHAR2,
          p_BAD_DEBT_REASON         IN VARCHAR2,
          p_LEASING_CODE            IN VARCHAR2,
          p_REPOSSES_SCH_DATE       IN  DATE,
          p_REPOSSES_COMP_DATE      IN DATE,
          p_CREDIT_HOLD_YN          IN VARCHAR2,
          p_APPROVER_ID             IN VARCHAR2,
          p_EXTERNAL_AGENT_ID       IN VARCHAR2,
          p_PROCEDURE_CODE              IN VARCHAR2,
          p_CHECKLIST_CODE              IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID IN NUMBER,
          p_PROGRAM_ID             IN NUMBER,
          p_PROGRAM_UPDATE_DATE    IN DATE,
          p_ATTRIBUTE_CATEGORY     IN VARCHAR2,
          p_ATTRIBUTE1             IN VARCHAR2,
          p_ATTRIBUTE2             IN VARCHAR2,
          p_ATTRIBUTE3             IN VARCHAR2,
          p_ATTRIBUTE4             IN VARCHAR2,
          p_ATTRIBUTE5             IN VARCHAR2,
          p_ATTRIBUTE6             IN VARCHAR2,
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
         ,p_CREDIT_HOLD_REQUEST_FLAG   IN  VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG  IN  VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG  IN  VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG IN  VARCHAR2
	    ,p_SUGGESTION_APPROVED_FLAG   IN  VARCHAR2
         ,p_CUSTOMER_SITE_USE_ID    IN    NUMBER
         ,p_ORG_ID                  IN    NUMBER
         ,p_CONTRACT_ID             IN    NUMBER
         ,p_CONTRACT_NUMBER         IN    VARCHAR2
         );

PROCEDURE Update_Row(
          p_WRITEOFF_ID             IN NUMBER,
          p_PARTY_ID                IN NUMBER,
          p_DELINQUENCY_ID                IN NUMBER,
          p_CAS_ID                  IN NUMBER,
          p_CUST_ACCOUNT_ID         IN NUMBER,
          p_DISPOSITION_CODE        IN VARCHAR2,
          p_OBJECT_ID               IN NUMBER,
          p_OBJECT_CODE             IN VARCHAR2,
          p_WRITEOFF_TYPE           IN VARCHAR2,
          p_ACTIVE_FLAG             IN VARCHAR2,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          p_WRITEOFF_REASON         IN VARCHAR2,
          p_WRITEOFF_AMOUNT         IN NUMBER,
          p_WRITEOFF_CURRENCY_CODE  IN VARCHAR2,
          p_WRITEOFF_DATE           IN DATE,
          p_WRITEOFF_REQUEST_DATE   IN  DATE,
          p_WRITEOFF_PROCESS        IN VARCHAR2,
          p_WRITEOFF_SCORE          IN VARCHAR2,
          p_BAD_DEBT_REASON         IN VARCHAR2,
          p_LEASING_CODE            IN VARCHAR2,
          p_REPOSSES_SCH_DATE       IN  DATE,
          p_REPOSSES_COMP_DATE      IN DATE,
          p_CREDIT_HOLD_YN          IN VARCHAR2,
          p_APPROVER_ID             IN VARCHAR2,
          p_EXTERNAL_AGENT_ID       IN VARCHAR2,
          p_PROCEDURE_CODE              IN VARCHAR2,
          p_CHECKLIST_CODE              IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID IN NUMBER,
          p_PROGRAM_ID             IN NUMBER,
          p_PROGRAM_UPDATE_DATE    IN DATE,
          p_ATTRIBUTE_CATEGORY     IN VARCHAR2,
          p_ATTRIBUTE1             IN VARCHAR2,
          p_ATTRIBUTE2             IN VARCHAR2,
          p_ATTRIBUTE3             IN VARCHAR2,
          p_ATTRIBUTE4             IN VARCHAR2,
          p_ATTRIBUTE5             IN VARCHAR2,
          p_ATTRIBUTE6             IN VARCHAR2,
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
	    ,p_CREDIT_HOLD_REQUEST_FLAG  IN  VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG IN  VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG IN  VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG IN  VARCHAR2
	    ,p_SUGGESTION_APPROVED_FLAG   IN  VARCHAR2
         ,p_CUSTOMER_SITE_USE_ID   IN     NUMBER
         ,p_ORG_ID                 IN     NUMBER
         ,p_CONTRACT_ID            IN     NUMBER
         ,p_CONTRACT_NUMBER        IN     VARCHAR2
         );


procedure LOCK_ROW (
  p_WRITEOFF_ID          in NUMBER,
  p_OBJECT_VERSION_NUMBER in NUMBER);

/*

PROCEDURE Lock_Row(
          p_WRITEOFF_ID             IN NUMBER,
          p_PARTY_ID                IN NUMBER,
          p_DELINQUENCY_ID                IN NUMBER,
          p_CAS_ID                  IN NUMBER,
          p_OBJECT_ID               IN NUMBER,
          p_CUST_ACCOUNT_ID         IN NUMBER,
          p_DISPOSITION_CODE        IN VARCHAR2,
          p_OBJECT_CODE             IN VARCHAR2,
          p_WRITEOFF_TYPE           IN VARCHAR2,
          p_ACTIVE_FLAG             IN VARCHAR2,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          p_WRITEOFF_REASON         IN VARCHAR2,
          p_WRITEOFF_AMOUNT         IN NUMBER,
          p_WRITEOFF_CURRENCY_CODE  IN VARCHAR2,
          p_WRITEOFF_DATE           IN DATE,
          p_WRITEOFF_REQUEST_DATE   IN  DATE,
          p_WRITEOFF_PROCESS        IN VARCHAR2,
          p_WRITEOFF_SCORE          IN VARCHAR2,
          p_BAD_DEBT_REASON         IN VARCHAR2,
          p_LEASING_CODE            IN VARCHAR2,
          p_REPOSSES_SCH_DATE       IN  DATE,
          p_REPOSSES_COMP_DATE      IN DATE,
          p_CREDIT_HOLD_YN          IN VARCHAR2,
          p_APPROVER_ID             IN VARCHAR2,
          p_EXTERNAL_AGENT_ID       IN VARCHAR2,
          p_PROCEDURE_CODE              IN VARCHAR2,
          p_CHECKLIST_CODE              IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID IN NUMBER,
          p_PROGRAM_ID             IN NUMBER,
          p_PROGRAM_UPDATE_DATE    IN DATE,
          p_ATTRIBUTE_CATEGORY     IN VARCHAR2,
          p_ATTRIBUTE1             IN VARCHAR2,
          p_ATTRIBUTE2             IN VARCHAR2,
          p_ATTRIBUTE3             IN VARCHAR2,
          p_ATTRIBUTE4             IN VARCHAR2,
          p_ATTRIBUTE5             IN VARCHAR2,
          p_ATTRIBUTE6             IN VARCHAR2,
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
	    ,p_CREDIT_HOLD_REQUEST_FLAG  IN  VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG IN  VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG IN  VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG IN VARCHAR2
	    ,p_SUGGESTION_APPROVED_FLAG   IN VARCHAR2);

*/

PROCEDURE Delete_Row(
    p_WRITEOFF_ID  NUMBER);
End IEX_WRITEOFFS_PKG;

/
