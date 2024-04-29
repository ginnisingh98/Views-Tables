--------------------------------------------------------
--  DDL for Package Body IEX_BANKRUPTCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_BANKRUPTCIES_PKG" as
/* $Header: iextbkrb.pls 120.0 2004/01/24 03:21:12 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_BANKRUPTCIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_BANKRUPTCIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iextbkrb.pls';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

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
          p_CHAPTER_CODE                  IN VARCHAR2,
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
	    ,p_CREDIT_HOLD_REQUEST_FLAG   IN  VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG  IN  VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG  IN  VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG IN  VARCHAR2
	    ,p_DISPOSITION_CODE           IN  VARCHAR2
            ,p_TURN_OFF_INVOICE_YN        IN VARCHAR2
	    ,p_NOTICE_ASSIGNMENT_YN       IN VARCHAR2
	    ,p_FILE_PROOF_CLAIM_YN        IN VARCHAR2
	    ,p_REQUEST_REPURCHASE_YN      IN VARCHAR2
	    ,p_FEE_PAID_DATE              IN DATE
	    ,p_REAFFIRMATION_DATE         IN DATE
	    ,p_RELIEF_STAY_DATE           IN DATE
	    ,p_FILE_CONTACT_ID            IN NUMBER
	    ,p_CASE_NUMBER                IN VARCHAR2
		) IS

    cursor C is select ROWID from IEX_BANKRUPTCIES
    where  bankruptcy_id = p_bankruptcy_id   ;

BEGIN
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_BANKRUPTCIES_PKG.INSERT_ROW ******** ');
  END IF;
   INSERT INTO IEX_BANKRUPTCIES(
           BANKRUPTCY_ID,
           CAS_ID,
           DELINQUENCY_ID,
           PARTY_ID,
           ACTIVE_FLAG,
           TRUSTEE_CONTACT_ID,
           COURT_ID,
           FIRM_CONTACT_ID,
           COUNSEL_CONTACT_ID,
           OBJECT_VERSION_NUMBER,
           CHAPTER_CODE,
           ASSET_AMOUNT,
           ASSET_CURRENCY_CODE,
           PAYOFF_AMOUNT,
           PAYOFF_CURRENCY_CODE,
           BANKRUPTCY_FILE_DATE,
           COURT_ORDER_DATE,
           FUNDING_DATE,
           OBJECT_BAR_DATE,
           REPOSSESSION_DATE,
           DISMISSAL_DATE,
           DATE_341A,
           DISCHARGE_DATE,
           WITHDRAW_DATE,
           CLOSE_DATE,
           PROCEDURE_CODE,
           MOTION_CODE,
           CHECKLIST_CODE,
           CEASE_COLLECTIONS_YN,
           TURN_OFF_INVOICING_YN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
		,CREDIT_HOLD_REQUEST_FLAG
		,CREDIT_HOLD_APPROVED_FLAG
		,SERVICE_HOLD_REQUEST_FLAG
		,SERVICE_HOLD_APPROVED_FLAG
		,DISPOSITION_CODE
          ,TURN_OFF_INVOICE_YN
	  ,NOTICE_ASSIGNMENT_YN
	  ,FILE_PROOF_CLAIM_YN
          ,REQUEST_REPURCHASE_YN
	  ,FEE_PAID_DATE
          ,REAFFIRMATION_DATE
	  ,RELIEF_STAY_DATE
	  ,FILE_CONTACT_ID
	  ,CASE_NUMBER
          ) VALUES (
           p_BANKRUPTCY_ID,
           decode( p_CAS_ID, FND_API.G_MISS_NUM, NULL, p_CAS_ID),
           decode( p_DELINQUENCY_ID, FND_API.G_MISS_NUM, NULL, p_DELINQUENCY_ID),
           p_PARTY_ID,
           p_ACTIVE_FLAG,
           decode( p_TRUSTEE_CONTACT_ID, FND_API.G_MISS_NUM, NULL, p_TRUSTEE_CONTACT_ID),
           decode( p_COURT_ID, FND_API.G_MISS_NUM, NULL, p_COURT_ID),
           decode( p_FIRM_CONTACT_ID, FND_API.G_MISS_NUM, NULL, p_FIRM_CONTACT_ID),
           decode( p_COUNSEL_CONTACT_ID, FND_API.G_MISS_NUM, NULL, p_COUNSEL_CONTACT_ID),
           decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
           decode( p_CHAPTER_CODE, FND_API.G_MISS_CHAR, NULL, p_CHAPTER_CODE),
           decode( p_ASSET_AMOUNT, FND_API.G_MISS_NUM, NULL, p_ASSET_AMOUNT),
           decode( p_ASSET_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_ASSET_CURRENCY_CODE),
           decode( p_PAYOFF_AMOUNT, FND_API.G_MISS_NUM, NULL, p_PAYOFF_AMOUNT),
           decode( p_PAYOFF_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_PAYOFF_CURRENCY_CODE),
           decode( p_BANKRUPTCY_FILE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_BANKRUPTCY_FILE_DATE),
           decode( p_COURT_ORDER_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_COURT_ORDER_DATE),
           decode( p_FUNDING_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_FUNDING_DATE),
           decode( p_OBJECT_BAR_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_OBJECT_BAR_DATE),
           decode( p_REPOSSESSION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_REPOSSESSION_DATE),
           decode( p_DISMISSAL_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_DISMISSAL_DATE),
           decode( p_DATE_341A, FND_API.G_MISS_DATE, TO_DATE(NULL), p_DATE_341A),
           decode( p_DISCHARGE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_DISCHARGE_DATE),
           decode( p_WITHDRAW_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_WITHDRAW_DATE),
           decode( p_CLOSE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CLOSE_DATE),
           decode( p_PROCEDURE_CODE, FND_API.G_MISS_CHAR, NULL, p_PROCEDURE_CODE),
           decode( p_MOTION_CODE, FND_API.G_MISS_CHAR, NULL, p_MOTION_CODE),
           decode( p_CHECKLIST_CODE, FND_API.G_MISS_CHAR, NULL, p_CHECKLIST_CODE),
           decode( p_CEASE_COLLECTIONS_YN, FND_API.G_MISS_CHAR, NULL, p_CEASE_COLLECTIONS_YN),
           decode( p_TURN_OFF_INVOICING_YN, FND_API.G_MISS_CHAR, NULL, p_TURN_OFF_INVOICING_YN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
		,decode( p_CREDIT_HOLD_REQUEST_FLAG, FND_API.G_MISS_CHAR, NULL, p_CREDIT_HOLD_REQUEST_FLAG)
		,decode( p_CREDIT_HOLD_APPROVED_FLAG, FND_API.G_MISS_CHAR, NULL, p_CREDIT_HOLD_APPROVED_FLAG)
		,decode( p_SERVICE_HOLD_REQUEST_FLAG, FND_API.G_MISS_CHAR, NULL, p_SERVICE_HOLD_REQUEST_FLAG)
		,decode( p_SERVICE_HOLD_APPROVED_FLAG, FND_API.G_MISS_CHAR, NULL, p_SERVICE_HOLD_APPROVED_FLAG)
		,decode( p_DISPOSITION_CODE, FND_API.G_MISS_CHAR, NULL, p_DISPOSITION_CODE)
                ,decode( p_TURN_OFF_INVOICE_YN, FND_API.G_MISS_CHAR, NULL, p_TURN_OFF_INVOICE_YN)
		,decode( p_NOTICE_ASSIGNMENT_YN,  FND_API.G_MISS_CHAR, NULL, p_NOTICE_ASSIGNMENT_YN)
		,decode( p_FILE_PROOF_CLAIM_YN,  FND_API.G_MISS_CHAR, NULL, p_FILE_PROOF_CLAIM_YN)
		,decode( p_REQUEST_REPURCHASE_YN,  FND_API.G_MISS_CHAR, NULL, p_REQUEST_REPURCHASE_YN)
		,decode( p_FEE_PAID_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_FEE_PAID_DATE)
		,decode( p_REAFFIRMATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_REAFFIRMATION_DATE)
		,decode( p_RELIEF_STAY_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_RELIEF_STAY_DATE)
		,decode( p_FILE_CONTACT_ID, FND_API.G_MISS_NUM, NULL, p_FILE_CONTACT_ID)
		,decode( p_CASE_NUMBER, FND_API.G_MISS_CHAR, NULL, p_CASE_NUMBER)
		 );
   open c;
   fetch c into X_ROWID;
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('Insert_Row: ' || 'Value of ROWID = '||X_ROWID);
   END IF;
   if (c%notfound) then
       close c;
   raise no_data_found;
   end if;
   close c;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_BANKRUPTCIES_PKG.INSERT_ROW ******** ');
  END IF;
End Insert_Row;



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
         ,p_CREDIT_HOLD_REQUEST_FLAG    IN VARCHAR2
	 ,p_CREDIT_HOLD_APPROVED_FLAG   IN VARCHAR2
	 ,p_SERVICE_HOLD_REQUEST_FLAG   IN VARCHAR2
	 ,p_SERVICE_HOLD_APPROVED_FLAG  IN VARCHAR2
	 ,p_DISPOSITION_CODE            IN VARCHAR2
         ,p_TURN_OFF_INVOICE_YN        IN VARCHAR2
	 ,p_NOTICE_ASSIGNMENT_YN       IN VARCHAR2
	 ,p_FILE_PROOF_CLAIM_YN        IN VARCHAR2
	 ,p_REQUEST_REPURCHASE_YN      IN VARCHAR2
	 ,p_FEE_PAID_DATE              IN DATE
         ,p_REAFFIRMATION_DATE         IN DATE
	 ,p_RELIEF_STAY_DATE           IN DATE
	 ,p_FILE_CONTACT_ID            IN NUMBER
	 ,p_CASE_NUMBER                IN VARCHAR2
		) IS


 BEGIN
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('********* start of Procedure =>IEX_BANKRUPTCIES_PKG.UPDATE_ROW ******** ');
   END IF;
    Update IEX_BANKRUPTCIES
    SET
              CAS_ID = decode( p_CAS_ID, FND_API.G_MISS_NUM, CAS_ID, p_CAS_ID),
              DELINQUENCY_ID = decode( p_DELINQUENCY_ID, FND_API.G_MISS_NUM, DELINQUENCY_ID, p_DELINQUENCY_ID),
              PARTY_ID = decode( p_PARTY_ID, FND_API.G_MISS_NUM, PARTY_ID, p_PARTY_ID),
              ACTIVE_FLAG = decode( p_ACTIVE_FLAG, FND_API.G_MISS_CHAR, ACTIVE_FLAG, p_ACTIVE_FLAG),
              TRUSTEE_CONTACT_ID = decode( p_TRUSTEE_CONTACT_ID, FND_API.G_MISS_NUM, TRUSTEE_CONTACT_ID, p_TRUSTEE_CONTACT_ID),
              COURT_ID = decode( p_COURT_ID, FND_API.G_MISS_NUM, COURT_ID, p_COURT_ID),
              FIRM_CONTACT_ID = decode( p_FIRM_CONTACT_ID, FND_API.G_MISS_NUM, FIRM_CONTACT_ID, p_FIRM_CONTACT_ID),
              COUNSEL_CONTACT_ID = decode( p_COUNSEL_CONTACT_ID, FND_API.G_MISS_NUM, COUNSEL_CONTACT_ID, p_COUNSEL_CONTACT_ID),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              CHAPTER_CODE= decode( p_CHAPTER_CODE, FND_API.G_MISS_CHAR, CHAPTER_CODE, p_CHAPTER_CODE),
              ASSET_AMOUNT = decode( p_ASSET_AMOUNT, FND_API.G_MISS_NUM, ASSET_AMOUNT, p_ASSET_AMOUNT),
              ASSET_CURRENCY_CODE = decode( p_ASSET_CURRENCY_CODE, FND_API.G_MISS_CHAR, ASSET_CURRENCY_CODE, p_ASSET_CURRENCY_CODE),
              PAYOFF_AMOUNT = decode( p_PAYOFF_AMOUNT, FND_API.G_MISS_NUM, PAYOFF_AMOUNT, p_PAYOFF_AMOUNT),
              PAYOFF_CURRENCY_CODE = decode( p_PAYOFF_CURRENCY_CODE, FND_API.G_MISS_CHAR, PAYOFF_CURRENCY_CODE, p_PAYOFF_CURRENCY_CODE),
              BANKRUPTCY_FILE_DATE = decode( p_BANKRUPTCY_FILE_DATE, FND_API.G_MISS_DATE, BANKRUPTCY_FILE_DATE, p_BANKRUPTCY_FILE_DATE),
              COURT_ORDER_DATE = decode( p_COURT_ORDER_DATE, FND_API.G_MISS_DATE, COURT_ORDER_DATE, p_COURT_ORDER_DATE),
              FUNDING_DATE = decode( p_FUNDING_DATE, FND_API.G_MISS_DATE, FUNDING_DATE, p_FUNDING_DATE),
              OBJECT_BAR_DATE = decode( p_OBJECT_BAR_DATE, FND_API.G_MISS_DATE, OBJECT_BAR_DATE, p_OBJECT_BAR_DATE),
              REPOSSESSION_DATE = decode( p_REPOSSESSION_DATE, FND_API.G_MISS_DATE, REPOSSESSION_DATE, p_REPOSSESSION_DATE),
              DISMISSAL_DATE = decode( p_DISMISSAL_DATE, FND_API.G_MISS_DATE, DISMISSAL_DATE, p_DISMISSAL_DATE),
              DATE_341A = decode( p_DATE_341A, FND_API.G_MISS_DATE, DATE_341A, p_DATE_341A),
              DISCHARGE_DATE = decode( p_DISCHARGE_DATE, FND_API.G_MISS_DATE, DISCHARGE_DATE, p_DISCHARGE_DATE),
              WITHDRAW_DATE = decode( p_WITHDRAW_DATE, FND_API.G_MISS_DATE, WITHDRAW_DATE, p_WITHDRAW_DATE),
              CLOSE_DATE = decode( p_CLOSE_DATE, FND_API.G_MISS_DATE, CLOSE_DATE, p_CLOSE_DATE),
              PROCEDURE_CODE = decode( p_PROCEDURE_CODE, FND_API.G_MISS_CHAR, PROCEDURE_CODE, p_PROCEDURE_CODE),
              MOTION_CODE = decode( p_MOTION_CODE, FND_API.G_MISS_CHAR, MOTION_CODE, p_MOTION_CODE),
              CHECKLIST_CODE = decode( p_CHECKLIST_CODE, FND_API.G_MISS_CHAR, CHECKLIST_CODE, p_CHECKLIST_CODE),
              CEASE_COLLECTIONS_YN = decode( p_CEASE_COLLECTIONS_YN, FND_API.G_MISS_CHAR, CEASE_COLLECTIONS_YN, p_CEASE_COLLECTIONS_YN),
              TURN_OFF_INVOICING_YN = decode( p_TURN_OFF_INVOICING_YN, FND_API.G_MISS_CHAR, TURN_OFF_INVOICING_YN, p_TURN_OFF_INVOICING_YN),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
             ,CREDIT_HOLD_REQUEST_FLAG = decode( p_CREDIT_HOLD_REQUEST_FLAG, FND_API.G_MISS_CHAR, CREDIT_HOLD_REQUEST_FLAG, p_CREDIT_HOLD_REQUEST_FLAG)
             ,CREDIT_HOLD_APPROVED_FLAG = decode( p_CREDIT_HOLD_APPROVED_FLAG, FND_API.G_MISS_CHAR, CREDIT_HOLD_APPROVED_FLAG, p_CREDIT_HOLD_APPROVED_FLAG)
             ,SERVICE_HOLD_REQUEST_FLAG = decode( p_SERVICE_HOLD_REQUEST_FLAG, FND_API.G_MISS_CHAR, SERVICE_HOLD_REQUEST_FLAG, p_SERVICE_HOLD_REQUEST_FLAG)
	     ,SERVICE_HOLD_APPROVED_FLAG = decode( p_SERVICE_HOLD_APPROVED_FLAG, FND_API.G_MISS_CHAR, SERVICE_HOLD_APPROVED_FLAG, p_SERVICE_HOLD_APPROVED_FLAG)
	     ,DISPOSITION_CODE = decode( p_DISPOSITION_CODE, FND_API.G_MISS_CHAR, DISPOSITION_CODE, p_DISPOSITION_CODE)
             ,TURN_OFF_INVOICE_YN  = decode( p_TURN_OFF_INVOICE_YN, FND_API.G_MISS_CHAR,TURN_OFF_INVOICE_YN,p_TURN_OFF_INVOICE_YN)
	     ,NOTICE_ASSIGNMENT_YN = decode( p_NOTICE_ASSIGNMENT_YN,FND_API.G_MISS_CHAR,NOTICE_ASSIGNMENT_YN,p_NOTICE_ASSIGNMENT_YN)
	     ,FILE_PROOF_CLAIM_YN  = decode( p_FILE_PROOF_CLAIM_YN, FND_API.G_MISS_CHAR,FILE_PROOF_CLAIM_YN, p_FILE_PROOF_CLAIM_YN)
	     ,REQUEST_REPURCHASE_YN = decode( p_REQUEST_REPURCHASE_YN,  FND_API.G_MISS_CHAR,REQUEST_REPURCHASE_YN, p_REQUEST_REPURCHASE_YN)
	     ,FEE_PAID_DATE = decode( p_FEE_PAID_DATE, FND_API.G_MISS_DATE,FEE_PAID_DATE, p_FEE_PAID_DATE)
	     ,REAFFIRMATION_DATE = decode( p_REAFFIRMATION_DATE, FND_API.G_MISS_DATE,REAFFIRMATION_DATE, p_REAFFIRMATION_DATE)
	     ,RELIEF_STAY_DATE = decode( p_RELIEF_STAY_DATE, FND_API.G_MISS_DATE, RELIEF_STAY_DATE, p_RELIEF_STAY_DATE)
	     ,FILE_CONTACT_ID = decode( p_FILE_CONTACT_ID, FND_API.G_MISS_NUM,FILE_CONTACT_ID, p_FILE_CONTACT_ID)
	     ,CASE_NUMBER = decode( p_CASE_NUMBER, FND_API.G_MISS_CHAR,CASE_NUMBER, p_CASE_NUMBER)

    where BANKRUPTCY_ID = p_BANKRUPTCY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_BANKRUPTCIES_PKG.UPDATE_ROW ******** ');
    END IF;
END Update_Row;


PROCEDURE Delete_Row(
    p_BANKRUPTCY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM IEX_BANKRUPTCIES
    WHERE BANKRUPTCY_ID = p_BANKRUPTCY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;


  procedure LOCK_ROW (
  p_bankruptcy_id in NUMBER,
  p_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_BANKRUPTCIES
    where bankruptcy_id = p_bankruptcy_id
    and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
    for update of bankruptcy_id nowait;
  recinfo c%rowtype;

begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_BANKRUPTCIES_PKG.LOCK_ROW ******** ');
 END IF;
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  close c;

  if recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_BANKRUPTCIES_PKG.LOCK_ROW ******** ');
END IF;
end LOCK_ROW;



/*
PROCEDURE Lock_Row(
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
	    ,p_CREDIT_HOLD_REQUEST_FLAG    IN VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG   IN VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG   IN VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG  IN VARCHAR2
	    ,p_DISPOSITION_CODE            IN VARCHAR2
		)

 IS
   CURSOR C IS
        SELECT *
         FROM IEX_BANKRUPTCIES
        WHERE BANKRUPTCY_ID =  p_BANKRUPTCY_ID
        FOR UPDATE of BANKRUPTCY_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.BANKRUPTCY_ID = p_BANKRUPTCY_ID)
       AND (    ( Recinfo.CAS_ID = p_CAS_ID)
            OR (    ( Recinfo.CAS_ID IS NULL )
                AND (  p_CAS_ID IS NULL )))
       AND (    ( Recinfo.DELINQUENCY_ID = p_DELINQUENCY_ID)
            OR (    ( Recinfo.DELINQUENCY_ID IS NULL )
                AND (  p_DELINQUENCY_ID IS NULL )))
       AND (    ( Recinfo.PARTY_ID = p_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID IS NULL )
                AND (  p_PARTY_ID IS NULL )))
       AND (    ( Recinfo.ACTIVE_FLAG = p_ACTIVE_FLAG)
            OR (    ( Recinfo.ACTIVE_FLAG IS NULL )
                AND (  p_ACTIVE_FLAG IS NULL )))
       AND (    ( Recinfo.TRUSTEE_CONTACT_ID = p_TRUSTEE_CONTACT_ID)
            OR (    ( Recinfo.TRUSTEE_CONTACT_ID IS NULL )
                AND (  p_TRUSTEE_CONTACT_ID IS NULL )))
       AND (    ( Recinfo.COURT_ID = p_COURT_ID)
            OR (    ( Recinfo.COURT_ID IS NULL )
                AND (  p_COURT_ID IS NULL )))
       AND (    ( Recinfo.FIRM_CONTACT_ID = p_FIRM_CONTACT_ID)
            OR (    ( Recinfo.FIRM_CONTACT_ID IS NULL )
                AND (  p_FIRM_CONTACT_ID IS NULL )))
       AND (    ( Recinfo.COUNSEL_CONTACT_ID = p_COUNSEL_CONTACT_ID)
            OR (    ( Recinfo.COUNSEL_CONTACT_ID IS NULL )
                AND (  p_COUNSEL_CONTACT_ID IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.CHAPTER_CODE= p_CHAPTER_CODE)
            OR (    ( Recinfo.CHAPTER_CODE IS NULL )
                AND (  p_CHAPTER_CODE IS NULL )))
       AND (    ( Recinfo.ASSET_AMOUNT = p_ASSET_AMOUNT)
            OR (    ( Recinfo.ASSET_AMOUNT IS NULL )
                AND (  p_ASSET_AMOUNT IS NULL )))
       AND (    ( Recinfo.ASSET_CURRENCY_CODE = p_ASSET_CURRENCY_CODE)
            OR (    ( Recinfo.ASSET_CURRENCY_CODE IS NULL )
                AND (  p_ASSET_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.PAYOFF_AMOUNT = p_PAYOFF_AMOUNT)
            OR (    ( Recinfo.PAYOFF_AMOUNT IS NULL )
                AND (  p_PAYOFF_AMOUNT IS NULL )))
       AND (    ( Recinfo.PAYOFF_CURRENCY_CODE = p_PAYOFF_CURRENCY_CODE)
            OR (    ( Recinfo.PAYOFF_CURRENCY_CODE IS NULL )
                AND (  p_PAYOFF_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.BANKRUPTCY_FILE_DATE = p_BANKRUPTCY_FILE_DATE)
            OR (    ( Recinfo.BANKRUPTCY_FILE_DATE IS NULL )
                AND (  p_BANKRUPTCY_FILE_DATE IS NULL )))
       AND (    ( Recinfo.COURT_ORDER_DATE = p_COURT_ORDER_DATE)
            OR (    ( Recinfo.COURT_ORDER_DATE IS NULL )
                AND (  p_COURT_ORDER_DATE IS NULL )))
       AND (    ( Recinfo.FUNDING_DATE = p_FUNDING_DATE)
            OR (    ( Recinfo.FUNDING_DATE IS NULL )
                AND (  p_FUNDING_DATE IS NULL )))
       AND (    ( Recinfo.OBJECT_BAR_DATE = p_OBJECT_BAR_DATE)
            OR (    ( Recinfo.OBJECT_BAR_DATE IS NULL )
                AND (  p_OBJECT_BAR_DATE IS NULL )))
       AND (    ( Recinfo.REPOSSESSION_DATE = p_REPOSSESSION_DATE)
            OR (    ( Recinfo.REPOSSESSION_DATE IS NULL )
                AND (  p_REPOSSESSION_DATE IS NULL )))
       AND (    ( Recinfo.DISMISSAL_DATE = p_DISMISSAL_DATE)
            OR (    ( Recinfo.DISMISSAL_DATE IS NULL )
                AND (  p_DISMISSAL_DATE IS NULL )))
       AND (    ( Recinfo.DATE_341A = p_DATE_341A)
            OR (    ( Recinfo.DATE_341A IS NULL )
                AND (  p_DATE_341A IS NULL )))
       AND (    ( Recinfo.DISCHARGE_DATE = p_DISCHARGE_DATE)
            OR (    ( Recinfo.DISCHARGE_DATE IS NULL )
                AND (  p_DISCHARGE_DATE IS NULL )))
       AND (    ( Recinfo.WITHDRAW_DATE = p_WITHDRAW_DATE)
            OR (    ( Recinfo.WITHDRAW_DATE IS NULL )
                AND (  p_WITHDRAW_DATE IS NULL )))
       AND (    ( Recinfo.CLOSE_DATE = p_CLOSE_DATE)
            OR (    ( Recinfo.CLOSE_DATE IS NULL )
                AND (  p_CLOSE_DATE IS NULL )))
       AND (    ( Recinfo.PROCEDURE_CODE = p_PROCEDURE_CODE)
            OR (    ( Recinfo.PROCEDURE_CODE IS NULL )
                AND (  p_PROCEDURE_CODE IS NULL )))
       AND (    ( Recinfo.MOTION_CODE = p_MOTION_CODE)
            OR (    ( Recinfo.MOTION_CODE IS NULL )
                AND (  p_MOTION_CODE IS NULL )))
       AND (    ( Recinfo.CHECKLISTS = p_CHECKLISTS)
            OR (    ( Recinfo.CHECKLIST_CODE IS NULL )
                AND (  p_CHECKLIST_CODE IS NULL )))
       AND (    ( Recinfo.CEASE_COLLECTIONS_YN = p_CEASE_COLLECTIONS_YN)
            OR (    ( Recinfo.CEASE_COLLECTIONS_YN IS NULL )
                AND (  p_CEASE_COLLECTIONS_YN IS NULL )))
       AND (    ( Recinfo.TURN_OFF_INVOICING_YN = p_TURN_OFF_INVOICING_YN)
            OR (    ( Recinfo.TURN_OFF_INVOICING_YN IS NULL )
                AND (  p_TURN_OFF_INVOICING_YN IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.CREDIT_HOLD_REQUEST_FLAG = p_CREDIT_HOLD_REQUEST_FLAG)
	       OR (    ( Recinfo.CREDIT_HOLD_REQUEST_FLAG IS NULL )
			 AND (  p_CREDIT_HOLD_REQUEST_FLAG IS NULL )))
	  AND (    ( Recinfo.CREDIT_HOLD_APPROVED_FLAG = p_CREDIT_HOLD_APPROVED_FLAG)
	       OR (    ( Recinfo.CREDIT_HOLD_APPROVED_FLAG IS NULL )
		      AND (  p_CREDIT_HOLD_APPROVED_FLAG IS NULL )))
	  AND (    ( Recinfo.SERVICE_HOLD_REQUEST_FLAG = p_SERVICE_HOLD_REQUEST_FLAG)
	       OR (    ( Recinfo.SERVICE_HOLD_REQUEST_FLAG IS NULL )
	           AND (  p_SERVICE_HOLD_REQUEST_FLAG IS NULL )))
	  AND (    ( Recinfo.SERVICE_HOLD_APPROVED_FLAG = p_SERVICE_HOLD_APPROVED_FLAG)
	       OR (    ( Recinfo.SERVICE_HOLD_APPROVED_FLAG IS NULL )
		    	 AND (  p_SERVICE_HOLD_APPROVED_FLAG IS NULL )))
       AND (    ( Recinfo.DISPOSITION_CODE = p_DISPOSITION_CODE)
			    OR (    ( Recinfo.DISPOSITION_CODE IS NULL )
		    	 AND (  p_DISPOSITION_CODE IS NULL )))

       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
*/
End IEX_BANKRUPTCIES_PKG;

/
