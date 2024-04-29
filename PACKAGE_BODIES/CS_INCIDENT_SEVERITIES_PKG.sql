--------------------------------------------------------
--  DDL for Package Body CS_INCIDENT_SEVERITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENT_SEVERITIES_PKG" as
/* $Header: csvidisb.pls 115.6 2003/09/01 12:43:19 anmukher ship $ */
procedure INSERT_ROW(
  X_ROWID in out NOCOPY VARCHAR2,
  X_INCIDENT_SEVERITY_ID in NUMBER,
  X_DISPLAY_COLOR in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_INCIDENT_SUBTYPE in VARCHAR2,
  X_IMPORTANCE_LEVEL in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RGB_COLOR in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DEFECT_SEVERITY_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  --Added priority code for Misc ERs project (11.5.10) --anmukher --09/01/03
  X_PRIORITY_CODE in VARCHAR2
) is
  cursor C is select ROWID from CS_INCIDENT_SEVERITIES_B
    where INCIDENT_SEVERITY_ID = X_INCIDENT_SEVERITY_ID
    ;
begin
  insert into CS_INCIDENT_SEVERITIES_B (
    INCIDENT_SEVERITY_ID,
    DISPLAY_COLOR,
    ATTRIBUTE6,
    INCIDENT_SUBTYPE,
    IMPORTANCE_LEVEL,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CONTEXT,
    OBJECT_VERSION_NUMBER,
    RGB_COLOR,
    DEFECT_SEVERITY_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    -- Added priority code --anmukher --09/01/03
    PRIORITY_CODE
  ) values (
    X_INCIDENT_SEVERITY_ID,
    X_DISPLAY_COLOR,
    X_ATTRIBUTE6,
    X_INCIDENT_SUBTYPE,
    X_IMPORTANCE_LEVEL,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CONTEXT,
    X_OBJECT_VERSION_NUMBER,
    X_RGB_COLOR,
    X_DEFECT_SEVERITY_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    -- Added priority code --anmukher --09/01/03
    X_PRIORITY_CODE
  );

  insert into CS_INCIDENT_SEVERITIES_TL (
    INCIDENT_SEVERITY_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INCIDENT_SEVERITY_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_INCIDENT_SEVERITIES_TL T
    where T.INCIDENT_SEVERITY_ID = X_INCIDENT_SEVERITY_ID
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
  X_INCIDENT_SEVERITY_ID in NUMBER,
  X_DISPLAY_COLOR in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_INCIDENT_SUBTYPE in VARCHAR2,
  X_IMPORTANCE_LEVEL in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RGB_COLOR in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DEFECT_SEVERITY_ID in NUMBER,
  --Added priority code for Misc ERs project (11.5.10) --anmukher --09/01/03
  X_PRIORITY_CODE in VARCHAR2
) is
  cursor c is select
      DISPLAY_COLOR,
      ATTRIBUTE6,
      INCIDENT_SUBTYPE,
      IMPORTANCE_LEVEL,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      --SEEDED_FLAG,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CONTEXT,
      OBJECT_VERSION_NUMBER,
      RGB_COLOR,
      DEFECT_SEVERITY_ID,
      -- Added priority code --anmukher --09/01/03
      PRIORITY_CODE
    from CS_INCIDENT_SEVERITIES_B
    where INCIDENT_SEVERITY_ID = X_INCIDENT_SEVERITY_ID
    for update of INCIDENT_SEVERITY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_INCIDENT_SEVERITIES_TL
    where INCIDENT_SEVERITY_ID = X_INCIDENT_SEVERITY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INCIDENT_SEVERITY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DISPLAY_COLOR = X_DISPLAY_COLOR)
           OR ((recinfo.DISPLAY_COLOR is null) AND (X_DISPLAY_COLOR is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND (recinfo.INCIDENT_SUBTYPE = X_INCIDENT_SUBTYPE)
      AND (recinfo.IMPORTANCE_LEVEL = X_IMPORTANCE_LEVEL)
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
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
      AND ((recinfo.CONTEXT = X_CONTEXT)
           OR ((recinfo.CONTEXT is null) AND (X_CONTEXT is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.RGB_COLOR = X_RGB_COLOR)
           OR ((recinfo.RGB_COLOR is null) AND (X_RGB_COLOR is null)))
      AND ((recinfo.DEFECT_SEVERITY_ID = X_DEFECT_SEVERITY_ID)
           OR ((recinfo.DEFECT_SEVERITY_ID is null)
		 AND (X_DEFECT_SEVERITY_ID is null)))
      -- Added check for priority code --anmukher --09/01/03
      AND ((recinfo.PRIORITY_CODE = X_PRIORITY_CODE)
           OR ((recinfo.PRIORITY_CODE is null) AND (X_PRIORITY_CODE is null)))
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
  X_INCIDENT_SEVERITY_ID in NUMBER,
  X_DISPLAY_COLOR in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_INCIDENT_SUBTYPE in VARCHAR2,
  X_IMPORTANCE_LEVEL in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RGB_COLOR in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DEFECT_SEVERITY_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  --Added priority code for Misc ERs project (11.5.10) --anmukher --09/01/03
  X_PRIORITY_CODE in VARCHAR2
) is
begin
  update CS_INCIDENT_SEVERITIES_B set
    DISPLAY_COLOR = X_DISPLAY_COLOR,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    INCIDENT_SUBTYPE = X_INCIDENT_SUBTYPE,
    IMPORTANCE_LEVEL = X_IMPORTANCE_LEVEL,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    CONTEXT = X_CONTEXT,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    RGB_COLOR = X_RGB_COLOR,
    DEFECT_SEVERITY_ID = X_DEFECT_SEVERITY_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    -- Added priority code --anmukher --09/01/03
    PRIORITY_CODE = X_PRIORITY_CODE
  where INCIDENT_SEVERITY_ID = X_INCIDENT_SEVERITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_INCIDENT_SEVERITIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INCIDENT_SEVERITY_ID = X_INCIDENT_SEVERITY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INCIDENT_SEVERITY_ID in NUMBER
) is
begin
  delete from CS_INCIDENT_SEVERITIES_TL
  where INCIDENT_SEVERITY_ID = X_INCIDENT_SEVERITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_INCIDENT_SEVERITIES_B
  where INCIDENT_SEVERITY_ID = X_INCIDENT_SEVERITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_INCIDENT_SEVERITIES_TL T
  where not exists
    (select NULL
    from CS_INCIDENT_SEVERITIES_B B
    where B.INCIDENT_SEVERITY_ID = T.INCIDENT_SEVERITY_ID
    );

  update CS_INCIDENT_SEVERITIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_INCIDENT_SEVERITIES_TL B
    where B.INCIDENT_SEVERITY_ID = T.INCIDENT_SEVERITY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INCIDENT_SEVERITY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INCIDENT_SEVERITY_ID,
      SUBT.LANGUAGE
    from CS_INCIDENT_SEVERITIES_TL SUBB, CS_INCIDENT_SEVERITIES_TL SUBT
    where SUBB.INCIDENT_SEVERITY_ID = SUBT.INCIDENT_SEVERITY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

insert into CS_INCIDENT_SEVERITIES_TL (
    INCIDENT_SEVERITY_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INCIDENT_SEVERITY_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_INCIDENT_SEVERITIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_INCIDENT_SEVERITIES_TL T
    where T.INCIDENT_SEVERITY_ID = B.INCIDENT_SEVERITY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CS_INCIDENT_SEVERITIES_PKG;

/