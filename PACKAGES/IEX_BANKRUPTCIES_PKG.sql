--------------------------------------------------------
--  DDL for Package IEX_BANKRUPTCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_BANKRUPTCIES_PKG" AUTHID CURRENT_USER as
/* $Header: iextbkrs.pls 120.0 2004/01/24 03:21:13 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_BANKRUPTCIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          X_ROWID                    in out NOCOPY VARCHAR2,
          p_BANKRUPTCY_ID            IN  NUMBER,
          p_CAS_ID                   IN  NUMBER,
          p_DELINQUENCY_ID           IN  NUMBER,
          p_PARTY_ID                 IN  NUMBER,
          p_ACTIVE_FLAG              IN VARCHAR2,
          p_TRUSTEE_CONTACT_ID       IN NUMBER,
          p_COURT_ID                 IN  NUMBER,
          p_FIRM_CONTACT_ID          IN  NUMBER,
          p_COUNSEL_CONTACT_ID       IN  NUMBER,
          p_OBJECT_VERSION_NUMBER    IN NUMBER,
          p_CHAPTER_CODE                 IN VARCHAR2,
          p_ASSET_AMOUNT             IN NUMBER,
          p_ASSET_CURRENCY_CODE      IN VARCHAR2,
          p_PAYOFF_AMOUNT            IN NUMBER,
          p_PAYOFF_CURRENCY_CODE     IN VARCHAR2,
          p_BANKRUPTCY_FILE_DATE     IN DATE,
          p_COURT_ORDER_DATE         IN DATE,
          p_FUNDING_DATE             IN DATE,
          p_OBJECT_BAR_DATE          IN DATE,
          p_REPOSSESSION_DATE        IN DATE,
          p_DISMISSAL_DATE           IN DATE,
          p_DATE_341A                IN DATE,
          p_DISCHARGE_DATE           IN DATE,
          p_WITHDRAW_DATE            IN DATE,
          p_CLOSE_DATE               IN DATE,
          p_PROCEDURE_CODE               IN VARCHAR2,
          p_MOTION_CODE                  IN VARCHAR2,
          p_CHECKLIST_CODE               IN VARCHAR2,
          p_CEASE_COLLECTIONS_YN     IN VARCHAR2,
          p_TURN_OFF_INVOICING_YN    IN  VARCHAR2,
          p_REQUEST_ID             IN NUMBER,
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
	    ,p_CREDIT_HOLD_REQUEST_FLAG   IN VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG  IN VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG  IN VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG IN VARCHAR2
	    ,p_DISPOSITION_CODE           IN VARCHAR2
	    ,p_TURN_OFF_INVOICE_YN        IN VARCHAR2
	    ,p_NOTICE_ASSIGNMENT_YN       IN VARCHAR2
	    ,p_FILE_PROOF_CLAIM_YN        IN VARCHAR2
	    ,p_REQUEST_REPURCHASE_YN      IN VARCHAR2
	    ,p_FEE_PAID_DATE              IN DATE
	    ,p_REAFFIRMATION_DATE         IN DATE
	    ,p_RELIEF_STAY_DATE           IN DATE
	    ,p_FILE_CONTACT_ID            IN NUMBER
	    ,p_CASE_NUMBER                IN VARCHAR2
		);


PROCEDURE Update_Row(
          p_BANKRUPTCY_ID            IN  NUMBER,
          p_CAS_ID                   IN  NUMBER,
          p_DELINQUENCY_ID           IN  NUMBER,
          p_PARTY_ID                 IN  NUMBER,
          p_ACTIVE_FLAG              IN VARCHAR2,
          p_TRUSTEE_CONTACT_ID       IN NUMBER,
          p_COURT_ID                 IN  NUMBER,
          p_FIRM_CONTACT_ID          IN  NUMBER,
          p_COUNSEL_CONTACT_ID       IN  NUMBER,
          p_OBJECT_VERSION_NUMBER    IN NUMBER,
          p_CHAPTER_CODE                 IN VARCHAR2,
          p_ASSET_AMOUNT             IN NUMBER,
          p_ASSET_CURRENCY_CODE      IN VARCHAR2,
          p_PAYOFF_AMOUNT            IN NUMBER,
          p_PAYOFF_CURRENCY_CODE     IN VARCHAR2,
          p_BANKRUPTCY_FILE_DATE     IN DATE,
          p_COURT_ORDER_DATE         IN DATE,
          p_FUNDING_DATE             IN DATE,
          p_OBJECT_BAR_DATE          IN DATE,
          p_REPOSSESSION_DATE        IN DATE,
          p_DISMISSAL_DATE           IN DATE,
          p_DATE_341A                IN DATE,
          p_DISCHARGE_DATE           IN DATE,
          p_WITHDRAW_DATE            IN DATE,
          p_CLOSE_DATE               IN DATE,
          p_PROCEDURE_CODE               IN VARCHAR2,
          p_MOTION_CODE                  IN VARCHAR2,
          p_CHECKLIST_CODE               IN VARCHAR2,
          p_CEASE_COLLECTIONS_YN     IN VARCHAR2,
          p_TURN_OFF_INVOICING_YN    IN  VARCHAR2,
          p_REQUEST_ID             IN NUMBER,
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
         ,p_CREDIT_HOLD_REQUEST_FLAG   IN VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG  IN VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG  IN VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG IN VARCHAR2
	    ,p_DISPOSITION_CODE           IN VARCHAR2
         ,p_TURN_OFF_INVOICE_YN        IN VARCHAR2
  	    ,p_NOTICE_ASSIGNMENT_YN       IN VARCHAR2
	    ,p_FILE_PROOF_CLAIM_YN        IN VARCHAR2
	    ,p_REQUEST_REPURCHASE_YN      IN VARCHAR2
	    ,p_FEE_PAID_DATE              IN DATE
	    ,p_REAFFIRMATION_DATE         IN DATE
	    ,p_RELIEF_STAY_DATE           IN DATE
	    ,p_FILE_CONTACT_ID            IN NUMBER
	    ,p_CASE_NUMBER                IN VARCHAR2
	    );

procedure LOCK_ROW (
  p_BANKRUPTCY_ID         in NUMBER,
  p_OBJECT_VERSION_NUMBER in NUMBER);


/*PROCEDURE Lock_Row(
          p_BANKRUPTCY_ID            IN  NUMBER,
          p_CAS_ID                   IN  NUMBER,
          p_DELINQUENCY_ID           IN  NUMBER,
          p_PARTY_ID                 IN  NUMBER,
          p_ACTIVE_FLAG              IN VARCHAR2,
          p_TRUSTEE_CONTACT_ID       IN NUMBER,
          p_COURT_ID                 IN  NUMBER,
          p_FIRM_CONTACT_ID          IN  NUMBER,
          p_COUNSEL_CONTACT_ID       IN  NUMBER,
          p_OBJECT_VERSION_NUMBER    IN NUMBER,
          p_CHAPTER_CODE                 IN VARCHAR2,
          p_ASSET_AMOUNT             IN NUMBER,
          p_ASSET_CURRENCY_CODE      IN VARCHAR2,
          p_PAYOFF_AMOUNT            IN NUMBER,
          p_PAYOFF_CURRENCY_CODE     IN VARCHAR2,
          p_BANKRUPTCY_FILE_DATE     IN DATE,
          p_COURT_ORDER_DATE         IN DATE,
          p_FUNDING_DATE             IN DATE,
          p_OBJECT_BAR_DATE          IN DATE,
          p_REPOSSESSION_DATE        IN DATE,
          p_DISMISSAL_DATE           IN DATE,
          p_DATE_341A                IN DATE,
          p_DISCHARGE_DATE           IN DATE,
          p_WITHDRAW_DATE            IN DATE,
          p_CLOSE_DATE               IN DATE,
          p_PROCEDURE_CODE               IN VARCHAR2,
          p_MOTION_CODE                  IN VARCHAR2,
          p_CHECKLIST_CODE               IN VARCHAR2,
          p_CEASE_COLLECTIONS_YN     IN VARCHAR2,
          p_TURN_OFF_INVOICING_YN    IN  VARCHAR2,
          p_REQUEST_ID             IN NUMBER,
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
	    ,p_CREDIT_HOLD_REQUEST_FLAG   IN VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG  IN VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG  IN VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG IN VARCHAR2
	    ,p_DISPOSITION_CODE           IN VARCHAR2
	);
*/
PROCEDURE Delete_Row(
    p_BANKRUPTCY_ID  NUMBER);
End IEX_BANKRUPTCIES_PKG;

 

/
