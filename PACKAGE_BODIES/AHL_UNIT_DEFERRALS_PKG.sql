--------------------------------------------------------
--  DDL for Package Body AHL_UNIT_DEFERRALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UNIT_DEFERRALS_PKG" as
/* $Header: AHLLUDFB.pls 120.2 2005/12/20 06:14 sracha noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_UNIT_DEFERRAL_ID in out nocopy NUMBER,
  X_ATA_SEQUENCE_ID in NUMBER,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_UNIT_EFFECTIVITY_ID in NUMBER,
  X_UNIT_DEFERRAL_TYPE in VARCHAR2,
  X_SET_DUE_DATE in DATE,
  X_APPROVAL_STATUS_CODE in VARCHAR2,
  X_SKIP_MR_FLAG in VARCHAR2,
  X_AFFECT_DUE_CALC_FLAG in VARCHAR2,
  X_DEFER_REASON_CODE in VARCHAR2,
  X_DEFERRAL_EFFECTIVE_ON in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_REMARKS in VARCHAR2,
  X_APPROVER_NOTES in VARCHAR2,
  X_USER_DEFERRAL_TYPE IN VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AHL_UNIT_DEFERRALS_B
    where UNIT_DEFERRAL_ID = X_UNIT_DEFERRAL_ID
    ;
begin
  insert into AHL_UNIT_DEFERRALS_B (
    ATA_SEQUENCE_ID,
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
    UNIT_DEFERRAL_ID,
    UNIT_EFFECTIVITY_ID,
    UNIT_DEFERRAL_TYPE,
    SET_DUE_DATE,
    APPROVAL_STATUS_CODE,
    SKIP_MR_FLAG,
    AFFECT_DUE_CALC_FLAG,
    DEFER_REASON_CODE,
    DEFERRAL_EFFECTIVE_ON,
    OBJECT_VERSION_NUMBER,
    USER_DEFERRAL_TYPE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATA_SEQUENCE_ID,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    AHL_UNIT_DEFERRALS_B_S.NEXTVAL,
    X_UNIT_EFFECTIVITY_ID,
    X_UNIT_DEFERRAL_TYPE,
    X_SET_DUE_DATE,
    X_APPROVAL_STATUS_CODE,
    X_SKIP_MR_FLAG,
    X_AFFECT_DUE_CALC_FLAG,
    X_DEFER_REASON_CODE,
    X_DEFERRAL_EFFECTIVE_ON,
    X_OBJECT_VERSION_NUMBER,
    X_USER_DEFERRAL_TYPE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  ) RETURNING UNIT_DEFERRAL_ID INTO X_UNIT_DEFERRAL_ID;

  insert into AHL_UNIT_DEFERRALS_TL (
    UNIT_DEFERRAL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REMARKS,
    APPROVER_NOTES,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_UNIT_DEFERRAL_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REMARKS,
    X_APPROVER_NOTES,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AHL_UNIT_DEFERRALS_TL T
    where T.UNIT_DEFERRAL_ID = X_UNIT_DEFERRAL_ID
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
  X_UNIT_DEFERRAL_ID in NUMBER,
  X_ATA_SEQUENCE_ID in NUMBER,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_UNIT_EFFECTIVITY_ID in NUMBER,
  X_UNIT_DEFERRAL_TYPE in VARCHAR2,
  X_SET_DUE_DATE in DATE,
  X_APPROVAL_STATUS_CODE in VARCHAR2,
  X_SKIP_MR_FLAG in VARCHAR2,
  X_AFFECT_DUE_CALC_FLAG in VARCHAR2,
  X_DEFER_REASON_CODE in VARCHAR2,
  X_DEFERRAL_EFFECTIVE_ON in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_REMARKS in VARCHAR2,
  X_APPROVER_NOTES in VARCHAR2,
  X_USER_DEFERRAL_TYPE IN VARCHAR2
) is
  cursor c is select
      ATA_SEQUENCE_ID,
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
      UNIT_EFFECTIVITY_ID,
      UNIT_DEFERRAL_TYPE,
      SET_DUE_DATE,
      APPROVAL_STATUS_CODE,
      SKIP_MR_FLAG,
      AFFECT_DUE_CALC_FLAG,
      DEFER_REASON_CODE,
      DEFERRAL_EFFECTIVE_ON,
      OBJECT_VERSION_NUMBER,
      USER_DEFERRAL_TYPE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4
    from AHL_UNIT_DEFERRALS_B
    where UNIT_DEFERRAL_ID = X_UNIT_DEFERRAL_ID
    for update of UNIT_DEFERRAL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      REMARKS,
      APPROVER_NOTES,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AHL_UNIT_DEFERRALS_TL
    where UNIT_DEFERRAL_ID = X_UNIT_DEFERRAL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of UNIT_DEFERRAL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATA_SEQUENCE_ID = X_ATA_SEQUENCE_ID)
           OR ((recinfo.ATA_SEQUENCE_ID is null) AND (X_ATA_SEQUENCE_ID is null)))
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
      AND (recinfo.UNIT_EFFECTIVITY_ID = X_UNIT_EFFECTIVITY_ID)
      AND (recinfo.UNIT_DEFERRAL_TYPE = X_UNIT_DEFERRAL_TYPE)
      AND ((recinfo.SET_DUE_DATE = X_SET_DUE_DATE)
           OR ((recinfo.SET_DUE_DATE is null) AND (X_SET_DUE_DATE is null)))
      AND ((recinfo.APPROVAL_STATUS_CODE = X_APPROVAL_STATUS_CODE)
           OR ((recinfo.APPROVAL_STATUS_CODE is null) AND (X_APPROVAL_STATUS_CODE is null)))
      AND ((recinfo.USER_DEFERRAL_TYPE = X_USER_DEFERRAL_TYPE)
           OR ((recinfo.USER_DEFERRAL_TYPE is null) AND (X_USER_DEFERRAL_TYPE is null)))
      AND ((recinfo.SKIP_MR_FLAG = X_SKIP_MR_FLAG)
           OR ((recinfo.SKIP_MR_FLAG is null) AND (X_SKIP_MR_FLAG is null)))
      AND ((recinfo.AFFECT_DUE_CALC_FLAG = X_AFFECT_DUE_CALC_FLAG)
           OR ((recinfo.AFFECT_DUE_CALC_FLAG is null) AND (X_AFFECT_DUE_CALC_FLAG is null)))
      AND ((recinfo.DEFER_REASON_CODE = X_DEFER_REASON_CODE)
           OR ((recinfo.DEFER_REASON_CODE is null) AND (X_DEFER_REASON_CODE is null)))
      AND ((recinfo.DEFERRAL_EFFECTIVE_ON = X_DEFERRAL_EFFECTIVE_ON)
           OR ((recinfo.DEFERRAL_EFFECTIVE_ON is null) AND (X_DEFERRAL_EFFECTIVE_ON is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.REMARKS = X_REMARKS)
               OR ((tlinfo.REMARKS is null) AND (X_REMARKS is null)))
          AND ((tlinfo.APPROVER_NOTES = X_APPROVER_NOTES)
               OR ((tlinfo.APPROVER_NOTES is null) AND (X_APPROVER_NOTES is null)))
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
  X_UNIT_DEFERRAL_ID in NUMBER,
  X_ATA_SEQUENCE_ID in NUMBER,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_UNIT_EFFECTIVITY_ID in NUMBER,
  X_UNIT_DEFERRAL_TYPE in VARCHAR2,
  X_SET_DUE_DATE in DATE,
  X_APPROVAL_STATUS_CODE in VARCHAR2,
  X_SKIP_MR_FLAG in VARCHAR2,
  X_AFFECT_DUE_CALC_FLAG in VARCHAR2,
  X_DEFER_REASON_CODE in VARCHAR2,
  X_DEFERRAL_EFFECTIVE_ON in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_REMARKS in VARCHAR2,
  X_APPROVER_NOTES in VARCHAR2,
  X_USER_DEFERRAL_TYPE IN VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AHL_UNIT_DEFERRALS_B set
    ATA_SEQUENCE_ID = X_ATA_SEQUENCE_ID,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    UNIT_EFFECTIVITY_ID = X_UNIT_EFFECTIVITY_ID,
    UNIT_DEFERRAL_TYPE = X_UNIT_DEFERRAL_TYPE,
    SET_DUE_DATE = X_SET_DUE_DATE,
    APPROVAL_STATUS_CODE = X_APPROVAL_STATUS_CODE,
    SKIP_MR_FLAG = X_SKIP_MR_FLAG,
    AFFECT_DUE_CALC_FLAG = X_AFFECT_DUE_CALC_FLAG,
    DEFER_REASON_CODE = X_DEFER_REASON_CODE,
    DEFERRAL_EFFECTIVE_ON = X_DEFERRAL_EFFECTIVE_ON,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    USER_DEFERRAL_TYPE =   X_USER_DEFERRAL_TYPE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where UNIT_DEFERRAL_ID = X_UNIT_DEFERRAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AHL_UNIT_DEFERRALS_TL set
    REMARKS = X_REMARKS,
    APPROVER_NOTES = X_APPROVER_NOTES,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where UNIT_DEFERRAL_ID = X_UNIT_DEFERRAL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_UNIT_DEFERRAL_ID in NUMBER
) is
begin
  delete from AHL_UNIT_DEFERRALS_TL
  where UNIT_DEFERRAL_ID = X_UNIT_DEFERRAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AHL_UNIT_DEFERRALS_B
  where UNIT_DEFERRAL_ID = X_UNIT_DEFERRAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AHL_UNIT_DEFERRALS_TL T
  where not exists
    (select NULL
    from AHL_UNIT_DEFERRALS_B B
    where B.UNIT_DEFERRAL_ID = T.UNIT_DEFERRAL_ID
    );

  update AHL_UNIT_DEFERRALS_TL T set (
      REMARKS,
      APPROVER_NOTES
    ) = (select
      B.REMARKS,
      B.APPROVER_NOTES
    from AHL_UNIT_DEFERRALS_TL B
    where B.UNIT_DEFERRAL_ID = T.UNIT_DEFERRAL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.UNIT_DEFERRAL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.UNIT_DEFERRAL_ID,
      SUBT.LANGUAGE
    from AHL_UNIT_DEFERRALS_TL SUBB, AHL_UNIT_DEFERRALS_TL SUBT
    where SUBB.UNIT_DEFERRAL_ID = SUBT.UNIT_DEFERRAL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.REMARKS <> SUBT.REMARKS
      or (SUBB.REMARKS is null and SUBT.REMARKS is not null)
      or (SUBB.REMARKS is not null and SUBT.REMARKS is null)
      or SUBB.APPROVER_NOTES <> SUBT.APPROVER_NOTES
      or (SUBB.APPROVER_NOTES is null and SUBT.APPROVER_NOTES is not null)
      or (SUBB.APPROVER_NOTES is not null and SUBT.APPROVER_NOTES is null)
  ));

  insert into AHL_UNIT_DEFERRALS_TL (
    UNIT_DEFERRAL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REMARKS,
    APPROVER_NOTES,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.UNIT_DEFERRAL_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.REMARKS,
    B.APPROVER_NOTES,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AHL_UNIT_DEFERRALS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AHL_UNIT_DEFERRALS_TL T
    where T.UNIT_DEFERRAL_ID = B.UNIT_DEFERRAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AHL_UNIT_DEFERRALS_PKG;

/