--------------------------------------------------------
--  DDL for Package Body AMW_RISKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_RISKS_PKG" AS
/* $Header: amwtrskb.pls 120.0 2005/05/31 18:44:57 appldev noship $*/
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RISK_REV_ID in NUMBER,
  X_RISK_REV_NUM in NUMBER,
  X_REQUESTOR_ID in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LATEST_REVISION_FLAG in VARCHAR2,
  X_END_DATE in DATE,
  X_CURR_APPROVED_FLAG in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_RISK_TYPE in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_ATTRIBUTE7 in VARCHAR2,
  X_RISK_ID in NUMBER,
  X_RISK_IMPACT in VARCHAR2,
  X_LIKELIHOOD in VARCHAR2,
  X_MATERIAL   in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CLASSIFICATION in NUMBER
) is
  cursor C is select ROWID from AMW_RISKS_B
    where RISK_REV_ID = X_RISK_REV_ID
    ;
begin
  insert into AMW_RISKS_B (
    RISK_REV_NUM,
    RISK_REV_ID,
    REQUESTOR_ID,
    ORIG_SYSTEM_REFERENCE,
    LATEST_REVISION_FLAG,
    END_DATE,
    CURR_APPROVED_FLAG,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    SECURITY_GROUP_ID,
    RISK_TYPE,
    APPROVAL_DATE,
    ATTRIBUTE7,
    RISK_ID,
    RISK_IMPACT,
    LIKELIHOOD,
    MATERIAL,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    APPROVAL_STATUS,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CLASSIFICATION
  ) values (
    X_RISK_REV_NUM,
    X_RISK_REV_ID,
    X_REQUESTOR_ID,
    X_ORIG_SYSTEM_REFERENCE,
    X_LATEST_REVISION_FLAG,
    X_END_DATE,
    X_CURR_APPROVED_FLAG,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_SECURITY_GROUP_ID,
    X_RISK_TYPE,
    X_APPROVAL_DATE,
    X_ATTRIBUTE7,
    X_RISK_ID,
    X_RISK_IMPACT,
    X_LIKELIHOOD,
    X_MATERIAL,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_APPROVAL_STATUS,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CLASSIFICATION
  );

  insert into AMW_RISKS_TL (
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    RISK_REV_ID,
    CREATION_DATE,
    CREATED_BY,
    RISK_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    X_RISK_REV_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_RISK_ID,
    X_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMW_RISKS_TL T
    where T.RISK_REV_ID = X_RISK_REV_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;



procedure LOCK_ROW (
  X_RISK_REV_ID in NUMBER,
  X_RISK_REV_NUM in NUMBER,
  X_REQUESTOR_ID in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LATEST_REVISION_FLAG in VARCHAR2,
  X_END_DATE in DATE,
  X_CURR_APPROVED_FLAG in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_RISK_TYPE in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_ATTRIBUTE7 in VARCHAR2,
  X_RISK_ID in NUMBER,
  X_RISK_IMPACT in VARCHAR2,
  X_LIKELIHOOD in VARCHAR2,
  X_MATERIAL   in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLASSIFICATION in NUMBER
) is
  cursor c is select
      RISK_REV_NUM,
      REQUESTOR_ID,
      ORIG_SYSTEM_REFERENCE,
      LATEST_REVISION_FLAG,
      END_DATE,
      CURR_APPROVED_FLAG,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      SECURITY_GROUP_ID,
      RISK_TYPE,
      APPROVAL_DATE,
      ATTRIBUTE7,
      RISK_ID,
      RISK_IMPACT,
      LIKELIHOOD,
      MATERIAL,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      APPROVAL_STATUS,
      OBJECT_VERSION_NUMBER,
      CLASSIFICATION
    from AMW_RISKS_B
    where RISK_REV_ID = X_RISK_REV_ID
    for update of RISK_REV_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMW_RISKS_TL
    where RISK_REV_ID = X_RISK_REV_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RISK_REV_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.RISK_REV_NUM = X_RISK_REV_NUM)
      AND ((recinfo.REQUESTOR_ID = X_REQUESTOR_ID)
           OR ((recinfo.REQUESTOR_ID is null) AND (X_REQUESTOR_ID is null)))
      AND ((recinfo.ORIG_SYSTEM_REFERENCE = X_ORIG_SYSTEM_REFERENCE)
           OR ((recinfo.ORIG_SYSTEM_REFERENCE is null) AND (X_ORIG_SYSTEM_REFERENCE is null)))
      AND (recinfo.LATEST_REVISION_FLAG = X_LATEST_REVISION_FLAG)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND (recinfo.CURR_APPROVED_FLAG = X_CURR_APPROVED_FLAG)
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
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.RISK_TYPE = X_RISK_TYPE)
           OR ((recinfo.RISK_TYPE is null) AND (X_RISK_TYPE is null)))
      AND ((recinfo.APPROVAL_DATE = X_APPROVAL_DATE)
           OR ((recinfo.APPROVAL_DATE is null) AND (X_APPROVAL_DATE is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND (recinfo.RISK_ID = X_RISK_ID)
      AND (recinfo.RISK_IMPACT = X_RISK_IMPACT)
      AND (recinfo.LIKELIHOOD = X_LIKELIHOOD)
      AND ((recinfo.MATERIAL = X_MATERIAL)
	       OR ((recinfo.MATERIAL is null) AND (X_MATERIAL is null)))
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
      AND ((recinfo.APPROVAL_STATUS = X_APPROVAL_STATUS)
           OR ((recinfo.APPROVAL_STATUS is null) AND (X_APPROVAL_STATUS is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.CLASSIFICATION = X_CLASSIFICATION)
           OR ((recinfo.CLASSIFICATION is null) AND (X_CLASSIFICATION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_RISK_REV_ID in NUMBER,
  X_RISK_REV_NUM in NUMBER,
  X_REQUESTOR_ID in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LATEST_REVISION_FLAG in VARCHAR2,
  X_END_DATE in DATE,
  X_CURR_APPROVED_FLAG in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_RISK_TYPE in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_ATTRIBUTE7 in VARCHAR2,
  X_RISK_ID in NUMBER,
  X_RISK_IMPACT in VARCHAR2,
  X_LIKELIHOOD in VARCHAR2,
  X_MATERIAL   in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CLASSIFICATION in NUMBER
) is
begin
  update AMW_RISKS_B set
    RISK_REV_NUM = X_RISK_REV_NUM,
    REQUESTOR_ID = X_REQUESTOR_ID,
    ORIG_SYSTEM_REFERENCE = X_ORIG_SYSTEM_REFERENCE,
    LATEST_REVISION_FLAG = X_LATEST_REVISION_FLAG,
    END_DATE = X_END_DATE,
    CURR_APPROVED_FLAG = X_CURR_APPROVED_FLAG,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    RISK_TYPE = X_RISK_TYPE,
    APPROVAL_DATE = X_APPROVAL_DATE,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    RISK_ID = X_RISK_ID,
    RISK_IMPACT = X_RISK_IMPACT,
    LIKELIHOOD = X_LIKELIHOOD,
    MATERIAL   = X_MATERIAL,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    APPROVAL_STATUS = X_APPROVAL_STATUS,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    CLASSIFICATION = X_CLASSIFICATION
  where RISK_REV_ID = X_RISK_REV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMW_RISKS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RISK_REV_ID = X_RISK_REV_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_RISK_REV_ID in NUMBER
) is
begin
  delete from AMW_RISKS_TL
  where RISK_REV_ID = X_RISK_REV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_RISKS_B
  where RISK_REV_ID = X_RISK_REV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMW_RISKS_TL T
  where not exists
    (select NULL
    from AMW_RISKS_B B
    where B.RISK_REV_ID = T.RISK_REV_ID
    );

  update AMW_RISKS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMW_RISKS_TL B
    where B.RISK_REV_ID = T.RISK_REV_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RISK_REV_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RISK_REV_ID,
      SUBT.LANGUAGE
    from AMW_RISKS_TL SUBB, AMW_RISKS_TL SUBT
    where SUBB.RISK_REV_ID = SUBT.RISK_REV_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMW_RISKS_TL (
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    RISK_REV_ID,
    CREATION_DATE,
    CREATED_BY,
    RISK_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.RISK_REV_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.RISK_ID,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_RISKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_RISKS_TL T
    where T.RISK_REV_ID = B.RISK_REV_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMW_RISKS_PKG;

/
