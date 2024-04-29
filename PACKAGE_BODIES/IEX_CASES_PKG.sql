--------------------------------------------------------
--  DDL for Package Body IEX_CASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASES_PKG" as
/* $Header: iextcasb.pls 120.0 2004/01/24 03:21:15 appldev noship $ */
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

procedure INSERT_ROW (
 X_ROWID                   in out NOCOPY VARCHAR2,
 X_CAS_ID                  in  NUMBER,
 X_CASE_NUMBER             in VARCHAR2,
 X_ACTIVE_FLAG             in VARCHAR2,
 X_PARTY_ID                in NUMBER,
 X_OBJECT_VERSION_NUMBER   in NUMBER,
 X_CASE_ESTABLISHED_DATE   in DATE,
 X_CASE_CLOSING_DATE       in DATE,
 X_ORIG_CAS_ID             in  NUMBER,
 X_CASE_STATE              in VARCHAR2,
 X_STATUS_CODE             in VARCHAR2,
 X_CLOSE_REASON             in VARCHAR2,
 X_ORG_ID                  in  NUMBER,
 X_OWNER_RESOURCE_ID       in  NUMBER,
 X_ACCESS_RESOURCE_ID      in  NUMBER,
 X_COMMENTS                in VARCHAR2,
 X_PREDICTED_RECOVERY_AMOUNT in NUMBER,
 X_PREDICTED_CHANCE           in NUMBER,
 X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2,
 X_CREATION_DATE           in DATE,
 X_CREATED_BY              in NUMBER,
 X_LAST_UPDATE_DATE        in DATE,
 X_LAST_UPDATED_BY         in NUMBER,
 X_LAST_UPDATE_LOGIN       in NUMBER
) is
  cursor C is select ROWID from IEX_CASES_ALL_B
    where  CAS_ID = X_CAS_ID   ;


BEGIN
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASES_PKG.INSERT_ROW ******** ');
  END IF;
  insert into IEX_CASES_ALL_B (
           CAS_ID,
           CASE_NUMBER,
		 ACTIVE_FLAG,
		 PARTY_ID,
           ORIG_CAS_ID,
           CASE_STATE,
           STATUS_CODE,
           OBJECT_VERSION_NUMBER,
           CASE_ESTABLISHED_DATE,
           CASE_CLOSING_DATE,
           OWNER_RESOURCE_ID,
           ACCESS_RESOURCE_ID,
           PREDICTED_RECOVERY_AMOUNT,
           PREDICTED_CHANCE,
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
           LAST_UPDATE_LOGIN,
           ORG_ID,
           CLOSE_REASON
           ) values
           (
           X_CAS_ID,
           X_CASE_NUMBER,
		 X_ACTIVE_FLAG,
		 X_PARTY_ID,
           decode( X_ORIG_CAS_ID, FND_API.G_MISS_NUM, NULL, X_ORIG_CAS_ID),
           X_CASE_STATE,
           X_STATUS_CODE,
           x_OBJECT_VERSION_NUMBER,
           x_CASE_ESTABLISHED_DATE,
           decode( x_CASE_CLOSING_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_CASE_CLOSING_DATE),
           decode( x_OWNER_RESOURCE_ID, FND_API.G_MISS_NUM, NULL, x_OWNER_RESOURCE_ID),
           decode( x_ACCESS_RESOURCE_ID, FND_API.G_MISS_NUM, NULL, x_ACCESS_RESOURCE_ID),
           decode( x_PREDICTED_RECOVERY_AMOUNT, FND_API.G_MISS_NUM, NULL, x_PREDICTED_RECOVERY_AMOUNT),
           decode( x_PREDICTED_CHANCE, FND_API.G_MISS_NUM, NULL, x_PREDICTED_CHANCE),
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL, x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_PROGRAM_UPDATE_DATE),
           decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE_CATEGORY),
           decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE1),
           decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE2),
           decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE3),
           decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE4),
           decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE5),
           decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE6),
           decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE7),
           decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE8),
           decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE9),
           decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE10),
           decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE11),
           decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE12),
           decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE13),
           decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE14),
           decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE15),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL, x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_CREATION_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATE_LOGIN),
           X_ORG_ID,
           decode( x_CLOSE_REASON, FND_API.G_MISS_CHAR, NULL, x_CLOSE_REASON));
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('INSERT_ROW: ' || 'After iex_case_All_b Insert and before iex_cases_tl insert');
   END IF;

  insert into IEX_CASES_TL (
    CAS_ID,
    COMMENTS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    ACTIVE_FLAG
  ) select
       X_CAS_ID,
        decode( x_COMMENTS, FND_API.G_MISS_CHAR, NULL, x_COMMENTS),
        decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL, x_CREATED_BY),
        decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_CREATION_DATE),
        decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATED_BY),
        decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_LAST_UPDATE_DATE),
        decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATE_LOGIN),
        L.LANGUAGE_CODE,
       userenv('LANG'),
	  X_ACTIVE_FLAG
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
      ( select NULL
        from iex_cases_tl T
        where T.cas_id      = X_cas_id
        and   T.active_flag = X_active_flag
	   and T.LANGUAGE = L.LANGUAGE_CODE);

--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('INSERT_ROW: ' || 'After iex_cases_tl insert');
   END IF;
  open c;
  fetch c into X_ROWID;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('INSERT_ROW: ' || 'Value of ROWID = '||X_ROWID);
  END IF;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASES_PKG.INSERT_ROW ******** ');
END IF;
end INSERT_ROW;

procedure LOCK_ROW (
  X_CAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_CASES_ALL_B
    where CAS_ID = X_CAS_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of CAS_ID nowait;
  recinfo c%rowtype;


begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASES_PKG.LOCK_ROW ******** ');
 END IF;
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  close c;

  if recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASES_PKG.LOCK_ROW ******** ');
END IF;
end LOCK_ROW;

/*procedure LOCK_ROW (
 X_CAS_ID                  in NUMBER,
 X_CASE_NUMBER             in VARCHAR2,
 X_ACTIVE_FLAG             in VARCHAR2,
 X_PARTY_ID                in NUMBER,
 X_OBJECT_VERSION_NUMBER   in NUMBER,
 X_CASE_ESTABLISHED_DATE   in DATE,
 X_CASE_CLOSING_DATE       in DATE,
 X_STATUS_CODE             in VARCHAR2,
 X_CLOSE_REASON             in VARCHAR2,
 X_ORG_ID                  in  NUMBER,
 X_OWNER_RESOURCE_ID       in  NUMBER,
 X_ACCESS_RESOURCE_ID      in  NUMBER,
 X_COMMENTS                in VARCHAR2,
 X_PREDICTED_RECOVERY_AMOUNT in NUMBER,
 X_PREDICTED_CHANCE           in NUMBER,
 X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2
) is
  cursor c is select
     CAS_ID               ,
     CASE_NUMBER          ,
	ACTIVE_FLAG          ,
     PARTY_ID            ,
     OBJECT_VERSION_NUMBER,
     CASE_ESTABLISHED_DATE,
     CASE_CLOSING_DATE    ,
     STATUS_CODE          ,
     CLOSE_REASON          ,
     ORG_ID               ,
     OWNER_RESOURCE_ID    ,
     ACCESS_RESOURCE_ID   ,
     PREDICTED_RECOVERY_AMOUNT,
     PREDICTED_CHANCE,
     REQUEST_ID           ,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID           ,
     PROGRAM_UPDATE_DATE  ,
     ATTRIBUTE_CATEGORY   ,
     ATTRIBUTE1           ,
     ATTRIBUTE2           ,
     ATTRIBUTE3           ,
     ATTRIBUTE4           ,
     ATTRIBUTE5           ,
     ATTRIBUTE6           ,
     ATTRIBUTE7           ,
     ATTRIBUTE8           ,
     ATTRIBUTE9           ,
     ATTRIBUTE10          ,
     ATTRIBUTE11          ,
     ATTRIBUTE12          ,
     ATTRIBUTE13          ,
     ATTRIBUTE14          ,
     ATTRIBUTE15
    from IEX_CASES_ALL_B
    where  CAS_ID = X_CAS_ID
    for update of  CAS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select Comments,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEX_CASES_TL
    where  CAS_ID = X_CAS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of  CAS_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (  (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
        AND(recinfo.CASE_NUMBER = X_CASE_NUMBER)
        AND(recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
        AND(recinfo.STATUS_CODE = X_STATUS_CODE)
        AND(recinfo.ORG_ID      = X_ORG_ID)
        AND(recinfo.PARTY_ID    = X_PARTY_ID)

      AND ((recinfo.CASE_ESTABLISHED_DATE = X_CASE_ESTABLISHED_DATE)
           OR ((recinfo.CASE_ESTABLISHED_DATE is null) AND (X_CASE_ESTABLISHED_DATE is null)))
      AND ((recinfo.CASE_CLOSING_DATE = X_CASE_CLOSING_DATE)
           OR ((recinfo.CASE_CLOSING_DATE is null) AND (X_CASE_CLOSING_DATE is null)))
      AND ((recinfo.CLOSE_REASON = X_CLOSE_REASON)
           OR ((recinfo.CLOSE_REASON is null) AND (X_CLOSE_REASON is null)))
      AND ((recinfo.OWNER_RESOURCE_ID = X_OWNER_RESOURCE_ID)
           OR ((recinfo.OWNER_RESOURCE_ID is null) AND (X_OWNER_RESOURCE_ID is null)))
      AND ((recinfo.ACCESS_RESOURCE_ID = X_ACCESS_RESOURCE_ID)
           OR ((recinfo.ACCESS_RESOURCE_ID is null) AND (X_ACCESS_RESOURCE_ID is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo.PROGRAM_ID = X_PROGRAM_ID)
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo. PROGRAM_UPDATE_DATE  = X_PROGRAM_UPDATE_DATE )
           OR ((recinfo.PROGRAM_UPDATE_DATE  is null) AND (X_PROGRAM_UPDATE_DATE  is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND (recinfo.CAS_ID = X_CAS_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
       if (   ((tlinfo.COMMENTS = X_COMMENTS)
               OR ((tlinfo.COMMENTS IS NULL) AND (X_COMMENTS IS NULL)))
          ) THEN
         NULL;
      else
          fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;
*/

procedure UPDATE_ROW (
 X_CAS_ID                  in NUMBER,
 X_CASE_NUMBER             in VARCHAR2,
 X_ACTIVE_FLAG             in VARCHAR2,
 X_PARTY_ID                in NUMBER,
 X_OBJECT_VERSION_NUMBER   in NUMBER,
 X_CASE_ESTABLISHED_DATE   in DATE,
 X_CASE_CLOSING_DATE       in DATE,
 X_ORIG_CAS_ID             in  NUMBER,
 X_CASE_STATE              in VARCHAR2,
 X_STATUS_CODE             in VARCHAR2,
 X_CLOSE_REASON             in VARCHAR2,
 X_ORG_ID                  in  NUMBER,
 X_OWNER_RESOURCE_ID       in  NUMBER,
 X_ACCESS_RESOURCE_ID      in  NUMBER,
 X_COMMENTS                in VARCHAR2,
 X_PREDICTED_RECOVERY_AMOUNT in NUMBER,
 X_PREDICTED_CHANCE           in NUMBER,
 X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2,
 X_LAST_UPDATE_DATE        in DATE,
 X_LAST_UPDATED_BY         in NUMBER,
 X_LAST_UPDATE_LOGIN       in NUMBER) is
begin
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASES_PKG.UPDATE_ROW ******** ');
   END IF;
  update IEX_CASES_ALL_B set
              CASE_NUMBER = decode( x_CASE_NUMBER, FND_API.G_MISS_CHAR, CASE_NUMBER, x_CASE_NUMBER),
              ACTIVE_FLAG = decode( x_ACTIVE_FLAG, FND_API.G_MISS_CHAR, ACTIVE_FLAG, x_ACTIVE_FLAG),
              PARTY_ID = decode( X_PARTY_ID, FND_API.G_MISS_NUM, PARTY_ID, X_PARTY_ID),
              ORIG_CAS_ID = decode( X_ORIG_CAS_ID, FND_API.G_MISS_NUM, ORIG_CAS_ID, X_ORIG_CAS_ID),
              CASE_STATE = decode( x_CASE_STATE, FND_API.G_MISS_CHAR, CASE_STATE, x_CASE_STATE),
              STATUS_CODE = decode( x_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, x_STATUS_CODE),
              OBJECT_VERSION_NUMBER = decode( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, x_OBJECT_VERSION_NUMBER),
              CASE_ESTABLISHED_DATE = decode( x_CASE_ESTABLISHED_DATE, FND_API.G_MISS_DATE, CASE_ESTABLISHED_DATE, x_CASE_ESTABLISHED_DATE),
              CASE_CLOSING_DATE = decode( x_CASE_CLOSING_DATE, FND_API.G_MISS_DATE, CASE_CLOSING_DATE, x_CASE_CLOSING_DATE),
              OWNER_RESOURCE_ID = decode( x_OWNER_RESOURCE_ID, FND_API.G_MISS_NUM, OWNER_RESOURCE_ID, x_OWNER_RESOURCE_ID),
              ACCESS_RESOURCE_ID = decode( x_ACCESS_RESOURCE_ID, FND_API.G_MISS_NUM, ACCESS_RESOURCE_ID, x_ACCESS_RESOURCE_ID),
              PREDICTED_RECOVERY_AMOUNT = decode( x_PREDICTED_RECOVERY_AMOUNT, FND_API.G_MISS_NUM, PREDICTED_RECOVERY_AMOUNT, x_PREDICTED_RECOVERY_AMOUNT),
              PREDICTED_CHANCE = decode( x_PREDICTED_CHANCE, FND_API.G_MISS_NUM, PREDICTED_CHANCE, x_PREDICTED_CHANCE),
              REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, x_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, x_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, x_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, x_PROGRAM_UPDATE_DATE),
              ATTRIBUTE_CATEGORY = decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, x_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, x_ATTRIBUTE1),
              ATTRIBUTE2 = decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, x_ATTRIBUTE2),
              ATTRIBUTE3 = decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, x_ATTRIBUTE3),
              ATTRIBUTE4 = decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, x_ATTRIBUTE4),
              ATTRIBUTE5 = decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, x_ATTRIBUTE5),
              ATTRIBUTE6 = decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, x_ATTRIBUTE6),
              ATTRIBUTE7 = decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, x_ATTRIBUTE7),
              ATTRIBUTE8 = decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, x_ATTRIBUTE8),
              ATTRIBUTE9 = decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, x_ATTRIBUTE9),
              ATTRIBUTE10 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, x_ATTRIBUTE10),
              ATTRIBUTE11 = decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, x_ATTRIBUTE11),
              ATTRIBUTE12 = decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, x_ATTRIBUTE12),
              ATTRIBUTE13 = decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, x_ATTRIBUTE13),
              ATTRIBUTE14 = decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, x_ATTRIBUTE14),
              ATTRIBUTE15 = decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, x_ATTRIBUTE15),
              LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, x_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, x_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, x_LAST_UPDATE_LOGIN),
              ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, x_ORG_ID),
              CLOSE_REASON = decode( x_CLOSE_REASON, FND_API.G_MISS_CHAR, CLOSE_REASON, x_CLOSE_REASON)
    where  CAS_ID = X_CAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEX_CASES_TL set
     COMMENTS = decode( x_COMMENTS, FND_API.G_MISS_CHAR, COMMENTS, x_COMMENTS),
     LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, x_LAST_UPDATED_BY),
     LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, x_LAST_UPDATE_DATE),
     LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, x_LAST_UPDATE_LOGIN),
    SOURCE_LANG = userenv('LANG')
  where  CAS_ID = X_CAS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASES_PKG.UPDATE_ROW ******** ');
  END IF;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CAS_ID in NUMBER
) is
begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASES_PKG.DELETE_ROW ******** ');
 END IF;
  delete from IEX_CASES_TL
  where  CAS_ID = X_CAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEX_CASES_ALL_B
  where  CAS_ID = X_CAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASES_PKG.DELETE_ROW ******** ');
  END IF;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEX_CASES_TL T
  where not exists
    (select NULL
     from IEX_CASES_ALL_B B
     where B.CAS_ID = T.CAS_ID
    );

  update IEX_CASES_TL T
        set (COMMENTS) =
             (select B.COMMENTS
              from IEX_CASES_TL B
              where B.CAS_ID = T.CAS_ID
              and B.LANGUAGE = T.SOURCE_LANG)
        where (
              T.CAS_ID,T.LANGUAGE
               ) in (select
                       SUBT.CAS_ID,
                       SUBT.LANGUAGE
                     from IEX_CASES_TL SUBB,
                          IEX_CASES_TL SUBT
                     where SUBB.CAS_ID = SUBT.CAS_ID
                     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
                     and SUBB.COMMENTS<> SUBT.COMMENTS
                     OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                     OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                );

  insert into IEX_CASES_TL (
    CAS_ID,
    COMMENTS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    ACTIVE_FLAG
  ) select
    B.CAS_ID,
    B.COMMENTS,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.ACTIVE_FLAG
  from IEX_CASES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
     from IEX_CASES_TL T
     where T.CAS_ID = B.CAS_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_CAS_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
) IS

begin
	UPDATE IEX_CASES_tl SET
		comments=X_COMMENTS,
		last_update_date = sysdate,
		last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
		last_update_login = 0,
		source_lang = userenv('LANG')
	WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
		 CAS_id = X_CAS_ID;
end TRANSLATE_ROW;

end IEX_CASES_PKG;

/
