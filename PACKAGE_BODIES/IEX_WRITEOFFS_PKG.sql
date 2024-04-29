--------------------------------------------------------
--  DDL for Package Body IEX_WRITEOFFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WRITEOFFS_PKG" as
/* $Header: iextwrob.pls 120.1 2007/10/31 13:00:26 ehuh ship $ */
-- Start of Comments
-- Package name     : IEX_WRITEOFFS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_WRITEOFFS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iextwrob.pls';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Insert_Row(
          X_ROWID                   IN out NOCOPY VARCHAR2,
          p_WRITEOFF_ID             IN NUMBER,
          p_PARTY_ID                IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
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
         )

 IS

    cursor C is select ROWID from IEX_WRITEOFFS
    where  writeoff_id = p_writeoff_id   ;

BEGIN
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_WRITEOFFS_PKG.INSERT_ROW ******** ');
  END IF;


   INSERT INTO IEX_WRITEOFFS(
           WRITEOFF_ID,
           PARTY_ID,
           DELINQUENCY_ID ,
           CAS_ID,
           CUST_ACCOUNT_ID  ,
           DISPOSITION_CODE ,
           OBJECT_ID,
           OBJECT_CODE,
           WRITEOFF_TYPE,
           ACTIVE_FLAG,
           OBJECT_VERSION_NUMBER,
           WRITEOFF_REASON,
           WRITEOFF_AMOUNT,
           WRITEOFF_CURRENCY_CODE,
           WRITEOFF_DATE,
           WRITEOFF_REQUEST_DATE,
           WRITEOFF_PROCESS,
           WRITEOFF_SCORE,
           BAD_DEBT_REASON,
           LEASING_CODE,
           REPOSSES_SCH_DATE,
           REPOSSES_COMP_DATE,
           CREDIT_HOLD_YN,
           APPROVER_ID,
           EXTERNAL_AGENT_ID,
           PROCEDURE_CODE,
           CHECKLIST_CODE,
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
	     ,SUGGESTION_APPROVED_FLAG
             ,CUSTOMER_SITE_USE_ID
             ,ORG_ID
             ,CONTRACT_ID
             ,CONTRACT_NUMBER
          ) VALUES (
           p_WRITEOFF_ID,
           p_PARTY_ID,
           decode( p_DELINQUENCY_ID, FND_API.G_MISS_NUM, NULL, p_DELINQUENCY_ID),
           decode( p_CAS_ID, FND_API.G_MISS_NUM, NULL, p_CAS_ID),
           decode( p_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, p_CUST_ACCOUNT_ID),
           decode( p_DISPOSITION_CODE, FND_API.G_MISS_CHAR, NULL, p_DISPOSITION_CODE),
           decode( p_OBJECT_ID, FND_API.G_MISS_NUM, NULL, p_OBJECT_ID),
           decode( p_OBJECT_CODE, FND_API.G_MISS_CHAR, NULL, p_OBJECT_CODE),
           p_WRITEOFF_TYPE,
           p_ACTIVE_FLAG,
           p_OBJECT_VERSION_NUMBER,
           p_WRITEOFF_REASON,
           decode( p_WRITEOFF_AMOUNT, FND_API.G_MISS_NUM, NULL, p_WRITEOFF_AMOUNT),
           decode( p_WRITEOFF_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_WRITEOFF_CURRENCY_CODE),
           decode( p_WRITEOFF_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_WRITEOFF_DATE),
           decode( p_WRITEOFF_REQUEST_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_WRITEOFF_REQUEST_DATE),
           decode( p_WRITEOFF_PROCESS, FND_API.G_MISS_CHAR, NULL, p_WRITEOFF_PROCESS),
           decode( p_WRITEOFF_SCORE, FND_API.G_MISS_CHAR, NULL, p_WRITEOFF_SCORE),
           decode( p_BAD_DEBT_REASON, FND_API.G_MISS_CHAR, NULL, p_BAD_DEBT_REASON),
           decode( p_LEASING_CODE, FND_API.G_MISS_CHAR, NULL, p_LEASING_CODE),
           decode( p_REPOSSES_SCH_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_REPOSSES_SCH_DATE),
           decode( p_REPOSSES_COMP_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_REPOSSES_COMP_DATE),
           decode( p_CREDIT_HOLD_YN, FND_API.G_MISS_CHAR, NULL, p_CREDIT_HOLD_YN),
           decode( p_APPROVER_ID, FND_API.G_MISS_CHAR, NULL, p_APPROVER_ID),
           decode( p_EXTERNAL_AGENT_ID, FND_API.G_MISS_CHAR, NULL, p_EXTERNAL_AGENT_ID),
           decode( p_PROCEDURE_CODE, FND_API.G_MISS_CHAR, NULL, p_PROCEDURE_CODE),
           decode( p_CHECKLIST_CODE, FND_API.G_MISS_CHAR, NULL, p_CHECKLIST_CODE),
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
	  ,decode( p_SUGGESTION_APPROVED_FLAG, FND_API.G_MISS_CHAR, NULL, p_SUGGESTION_APPROVED_FLAG)
          ,decode( p_CUSTOMER_SITE_USE_ID, FND_API.G_MISS_NUM, NULL, p_CUSTOMER_SITE_USE_ID)
          ,decode( p_ORG_ID, FND_API.G_MISS_NUM, NULL, p_ORG_ID)
          ,decode( p_CONTRACT_ID, FND_API.G_MISS_NUM, NULL, p_CONTRACT_ID)
	  ,decode( p_CONTRACT_NUMBER, FND_API.G_MISS_CHAR, NULL, p_CONTRACT_NUMBER));


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
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_WRITEOFFS_PKG.INSERT_ROW ******** ');
  END IF;

End Insert_Row;

PROCEDURE Update_Row(
          p_WRITEOFF_ID             IN NUMBER,
          p_PARTY_ID                IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
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
          p_PROCEDURE_CODE          IN VARCHAR2,
          p_CHECKLIST_CODE          IN VARCHAR2,
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
	    ,p_CREDIT_HOLD_REQUEST_FLAG    IN VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG   IN VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG   IN VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG  IN VARCHAR2
	    ,p_SUGGESTION_APPROVED_FLAG    IN VARCHAR2
         ,p_CUSTOMER_SITE_USE_ID    IN    NUMBER
         ,p_ORG_ID                  IN    NUMBER
         ,p_CONTRACT_ID             IN    NUMBER
         ,p_CONTRACT_NUMBER         IN    VARCHAR2)


 IS
 BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_WRITEOFFS_PKG.UPDATE_ROW ******** ');
    END IF;
    Update IEX_WRITEOFFS
    SET
              PARTY_ID = decode( p_PARTY_ID, FND_API.G_MISS_NUM, PARTY_ID, p_PARTY_ID),
              DELINQUENCY_ID = decode( p_DELINQUENCY_ID, FND_API.G_MISS_NUM, DELINQUENCY_ID, p_DELINQUENCY_ID),
              CAS_ID = decode( p_CAS_ID, FND_API.G_MISS_NUM, CAS_ID, p_CAS_ID),
              CUST_ACCOUNT_ID = decode( p_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM,
		                          CUST_ACCOUNT_ID, p_CUST_ACCOUNT_ID),
              DISPOSITION_CODE = decode( p_DISPOSITION_CODE, FND_API.G_MISS_CHAR,
		                           DISPOSITION_CODE, p_DISPOSITION_CODE),
              OBJECT_ID = decode( p_OBJECT_ID, FND_API.G_MISS_NUM, OBJECT_ID, p_OBJECT_ID),
              OBJECT_CODE = decode( p_OBJECT_CODE, FND_API.G_MISS_CHAR, OBJECT_CODE, p_OBJECT_CODE),
              WRITEOFF_TYPE = decode( p_WRITEOFF_TYPE, FND_API.G_MISS_CHAR, WRITEOFF_TYPE, p_WRITEOFF_TYPE),
              ACTIVE_FLAG = decode( p_ACTIVE_FLAG, FND_API.G_MISS_CHAR, ACTIVE_FLAG, p_ACTIVE_FLAG),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,
		                            OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              WRITEOFF_REASON = decode( p_WRITEOFF_REASON, FND_API.G_MISS_CHAR, WRITEOFF_REASON, p_WRITEOFF_REASON),
              WRITEOFF_AMOUNT = decode( p_WRITEOFF_AMOUNT, FND_API.G_MISS_NUM, WRITEOFF_AMOUNT, p_WRITEOFF_AMOUNT),
              WRITEOFF_CURRENCY_CODE = decode( p_WRITEOFF_CURRENCY_CODE, FND_API.G_MISS_CHAR, WRITEOFF_CURRENCY_CODE, p_WRITEOFF_CURRENCY_CODE),
              WRITEOFF_DATE = decode( p_WRITEOFF_DATE, FND_API.G_MISS_DATE, WRITEOFF_DATE, p_WRITEOFF_DATE),
              WRITEOFF_REQUEST_DATE = decode( p_WRITEOFF_REQUEST_DATE, FND_API.G_MISS_DATE, WRITEOFF_REQUEST_DATE, p_WRITEOFF_REQUEST_DATE),
              WRITEOFF_PROCESS = decode( p_WRITEOFF_PROCESS, FND_API.G_MISS_CHAR, WRITEOFF_PROCESS, p_WRITEOFF_PROCESS),
              WRITEOFF_SCORE = decode( p_WRITEOFF_SCORE, FND_API.G_MISS_CHAR, WRITEOFF_SCORE, p_WRITEOFF_SCORE),
              BAD_DEBT_REASON = decode( p_BAD_DEBT_REASON, FND_API.G_MISS_CHAR, BAD_DEBT_REASON, p_BAD_DEBT_REASON),
              LEASING_CODE = decode( p_LEASING_CODE, FND_API.G_MISS_CHAR, LEASING_CODE, p_LEASING_CODE),
              REPOSSES_SCH_DATE = decode( p_REPOSSES_SCH_DATE, FND_API.G_MISS_DATE, REPOSSES_SCH_DATE, p_REPOSSES_SCH_DATE),
              REPOSSES_COMP_DATE = decode( p_REPOSSES_COMP_DATE, FND_API.G_MISS_DATE, REPOSSES_COMP_DATE, p_REPOSSES_COMP_DATE),
              CREDIT_HOLD_YN = decode( p_CREDIT_HOLD_YN, FND_API.G_MISS_CHAR, CREDIT_HOLD_YN, p_CREDIT_HOLD_YN),
              APPROVER_ID = decode( p_APPROVER_ID, FND_API.G_MISS_CHAR, APPROVER_ID, p_APPROVER_ID),
              EXTERNAL_AGENT_ID = decode( p_EXTERNAL_AGENT_ID, FND_API.G_MISS_CHAR, EXTERNAL_AGENT_ID, p_EXTERNAL_AGENT_ID),
              PROCEDURE_CODE = decode( p_PROCEDURE_CODE, FND_API.G_MISS_CHAR, PROCEDURE_CODE, p_PROCEDURE_CODE),
              CHECKLIST_CODE = decode( p_CHECKLIST_CODE, FND_API.G_MISS_CHAR, CHECKLIST_CODE, p_CHECKLIST_CODE),
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
	    ,SUGGESTION_APPROVED_FLAG = decode( p_SUGGESTION_APPROVED_FLAG, FND_API.G_MISS_CHAR, SUGGESTION_APPROVED_FLAG, p_SUGGESTION_APPROVED_FLAG)
            ,CUSTOMER_SITE_USE_ID = decode( p_CUSTOMER_SITE_USE_ID, FND_API.G_MISS_NUM, CUSTOMER_SITE_USE_ID, p_CUSTOMER_SITE_USE_ID)
            ,ORG_ID = decode( p_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, p_ORG_ID)
            ,CONTRACT_ID = decode( p_CONTRACT_ID, FND_API.G_MISS_NUM, CONTRACT_ID, p_CONTRACT_ID)
            ,CONTRACT_NUMBER = decode( p_CONTRACT_NUMBER, FND_API.G_MISS_CHAR, CONTRACT_NUMBER, p_CONTRACT_NUMBER)
    where WRITEOFF_ID = p_WRITEOFF_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_WRITEOFFS_PKG.UPDATE_ROW ******** ');
    END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_WRITEOFF_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM IEX_WRITEOFFS
    WHERE WRITEOFF_ID = p_WRITEOFF_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;


 PROCEDURE LOCK_ROW (
  p_writeoff_id in NUMBER,
  p_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_WRITEOFFS
    where writeoff_id = p_writeoff_id
    and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
    for update of writeoff_id nowait;
  recinfo c%rowtype;

begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_WRITEOFFS_PKG.LOCK_ROW ******** ');
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
   IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_WRITEOFFS_PKG.LOCK_ROW ******** ');
END IF;
end LOCK_ROW;


/*
PROCEDURE Lock_Row(
          p_WRITEOFF_ID             IN NUMBER,
          p_PARTY_ID                IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
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
	    ,p_CREDIT_HOLD_REQUEST_FLAG    IN VARCHAR2
	    ,p_CREDIT_HOLD_APPROVED_FLAG   IN VARCHAR2
	    ,p_SERVICE_HOLD_REQUEST_FLAG   IN VARCHAR2
	    ,p_SERVICE_HOLD_APPROVED_FLAG  IN VARCHAR2
	    ,p_SUGGESTION_APPROVED_FLAG    IN VARCHAR2)


 IS
   CURSOR C IS
        SELECT *
         FROM IEX_WRITEOFFS
        WHERE WRITEOFF_ID =  p_WRITEOFF_ID
        FOR UPDATE of WRITEOFF_ID NOWAIT;
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
           (      Recinfo.WRITEOFF_ID = p_WRITEOFF_ID)
       AND (    ( Recinfo.PARTY_ID = p_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID IS NULL )
                AND (  p_PARTY_ID IS NULL )))
       AND (    ( Recinfo.DELINQUENCY_ID = p_DELINQUENCY_ID)
            OR (    ( Recinfo.DELINQUENCY_ID IS NULL )
                AND (  p_DELINQUENCY_ID IS NULL )))
       AND (    ( Recinfo.CAS_ID = p_CAS_ID)
            OR (    ( Recinfo.CAS_ID IS NULL )
                AND (  p_CAS_ID IS NULL )))
       AND (    ( Recinfo.OBJECT_ID = p_OBJECT_ID)
            OR (    ( Recinfo.OBJECT_ID IS NULL )
                AND (  p_OBJECT_ID IS NULL )))
       AND (    ( Recinfo.OBJECT_CODE = p_OBJECT_CODE)
            OR (    ( Recinfo.OBJECT_CODE IS NULL )
                AND (  p_OBJECT_CODE IS NULL )))
       AND (    ( Recinfo.WRITEOFF_TYPE = p_WRITEOFF_TYPE)
            OR (    ( Recinfo.WRITEOFF_TYPE IS NULL )
                AND (  p_WRITEOFF_TYPE IS NULL )))
       AND (    ( Recinfo.ACTIVE_FLAG = p_ACTIVE_FLAG)
            OR (    ( Recinfo.ACTIVE_FLAG IS NULL )
                AND (  p_ACTIVE_FLAG IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.WRITEOFF_REASON = p_WRITEOFF_REASON)
            OR (    ( Recinfo.WRITEOFF_REASON IS NULL )
                AND (  p_WRITEOFF_REASON IS NULL )))
       AND (    ( Recinfo.WRITEOFF_AMOUNT = p_WRITEOFF_AMOUNT)
            OR (    ( Recinfo.WRITEOFF_AMOUNT IS NULL )
                AND (  p_WRITEOFF_AMOUNT IS NULL )))
       AND (    ( Recinfo.WRITEOFF_CURRENCY_CODE = p_WRITEOFF_CURRENCY_CODE)
            OR (    ( Recinfo.WRITEOFF_CURRENCY_CODE IS NULL )
                AND (  p_WRITEOFF_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.WRITEOFF_DATE = p_WRITEOFF_DATE)
            OR (    ( Recinfo.WRITEOFF_DATE IS NULL )
                AND (  p_WRITEOFF_DATE IS NULL )))
       AND (    ( Recinfo.WRITEOFF_REQUEST_DATE = p_WRITEOFF_REQUEST_DATE)
            OR (    ( Recinfo.WRITEOFF_REQUEST_DATE IS NULL )
                AND (  p_WRITEOFF_REQUEST_DATE IS NULL )))
       AND (    ( Recinfo.WRITEOFF_PROCESS = p_WRITEOFF_PROCESS)
            OR (    ( Recinfo.WRITEOFF_PROCESS IS NULL )
                AND (  p_WRITEOFF_PROCESS IS NULL )))
       AND (    ( Recinfo.WRITEOFF_SCORE = p_WRITEOFF_SCORE)
            OR (    ( Recinfo.WRITEOFF_SCORE IS NULL )
                AND (  p_WRITEOFF_SCORE IS NULL )))
       AND (    ( Recinfo.BAD_DEBT_REASON = p_BAD_DEBT_REASON)
            OR (    ( Recinfo.BAD_DEBT_REASON IS NULL )
                AND (  p_BAD_DEBT_REASON IS NULL )))
       AND (    ( Recinfo.LEASING_CODE = p_LEASING_CODE)
            OR (    ( Recinfo.LEASING_CODE IS NULL )
                AND (  p_LEASING_CODE IS NULL )))
       AND (    ( Recinfo.REPOSSES_SCH_DATE = p_REPOSSES_SCH_DATE)
            OR (    ( Recinfo.REPOSSES_SCH_DATE IS NULL )
                AND (  p_REPOSSES_SCH_DATE IS NULL )))
       AND (    ( Recinfo.REPOSSES_COMP_DATE = p_REPOSSES_COMP_DATE)
            OR (    ( Recinfo.REPOSSES_COMP_DATE IS NULL )
                AND (  p_REPOSSES_COMP_DATE IS NULL )))
       AND (    ( Recinfo.CREDIT_HOLD_YN = p_CREDIT_HOLD_YN)
            OR (    ( Recinfo.CREDIT_HOLD_YN IS NULL )
                AND (  p_CREDIT_HOLD_YN IS NULL )))
       AND (    ( Recinfo.APPROVER_ID = p_APPROVER_ID)
            OR (    ( Recinfo.APPROVER_ID IS NULL )
                AND (  p_APPROVER_ID IS NULL )))
       AND (    ( Recinfo.EXTERNAL_AGENT_ID = p_EXTERNAL_AGENT_ID)
            OR (    ( Recinfo.EXTERNAL_AGENT_ID IS NULL )
                AND (  p_EXTERNAL_AGENT_ID IS NULL )))
       AND (    ( Recinfo.PROCEDURE_CODE = p_PROCEDURE_CODE)
            OR (    ( Recinfo.PROCEDURE_CODE IS NULL )
                AND (  p_PROCEDURE_CODE IS NULL )))
       AND (    ( Recinfo.CHECKLIST_CODE = p_CHECKLIST_CODE)
            OR (    ( Recinfo.CHECKLIST_CODE IS NULL )
                AND (  p_CHECKLIST_CODE IS NULL )))
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
	  AND (    ( Recinfo.SUGGESTION_APPROVED_FLAG = p_SUGGESTION_APPROVED_FLAG)
            OR (    ( Recinfo.SUGGESTION_APPROVED_FLAG IS NULL )
			 AND (  p_SUGGESTION_APPROVED_FLAG IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
*/
End IEX_WRITEOFFS_PKG;

/
