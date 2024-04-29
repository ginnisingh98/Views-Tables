--------------------------------------------------------
--  DDL for Package Body AMW_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_CONSTRAINTS_PKG" as
/* $Header: amwtcstb.pls 120.2 2005/09/27 13:34:19 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_CONSTRAINTS_PKG
-- Purpose
--
-- History
-- 		  	11/03/2003    tsho     Creates
-- 		  	10/01/2004    tsho     Add column: Approal_Status
--          09/27/2005    tsho     Add column: Control_Id
-- ===============================================================



-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new constraint
--          in AMW_CONSTRAINTS_B and AMW_CONSTRAINTS_TL
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CONSTRAINT_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENTERED_BY_ID in NUMBER,
  X_TYPE_CODE in VARCHAR2,
  X_RISK_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
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
  X_CONSTRAINT_NAME in VARCHAR2,
  X_CONSTRAINT_DESCRIPTION in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_CLASSIFICATION in VARCHAR2,
  X_OBJECTIVE_CODE in VARCHAR2,
  X_CONTROL_ID in NUMBER
) is
  cursor C is select ROWID from AMW_CONSTRAINTS_B
    where CONSTRAINT_REV_ID = X_CONSTRAINT_REV_ID
    ;
begin
  insert into AMW_CONSTRAINTS_B (
  CONSTRAINT_ID,
  CONSTRAINT_REV_ID,
  START_DATE,
  END_DATE,
  ENTERED_BY_ID,
  TYPE_CODE,
  RISK_ID,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID,
  OBJECT_VERSION_NUMBER,
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
  APPROVAL_STATUS,
  CLASSIFICATION,
  OBJECTIVE_CODE,
  CONTROL_ID
  ) values (
  X_CONSTRAINT_ID,
  X_CONSTRAINT_REV_ID,
  X_START_DATE,
  X_END_DATE,
  X_ENTERED_BY_ID,
  X_TYPE_CODE,
  X_RISK_ID,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_DATE,
  X_CREATED_BY,
  X_CREATION_DATE,
  X_LAST_UPDATE_LOGIN,
  X_SECURITY_GROUP_ID,
  X_OBJECT_VERSION_NUMBER,
  X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1,
  X_ATTRIBUTE2,
  X_ATTRIBUTE3,
  X_ATTRIBUTE4,
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
  X_APPROVAL_STATUS,
  nvl(X_CLASSIFICATION, (SELECT work_type_id from amw_work_types_b where
  work_type_code = 'AMW_CONSTRAINT_TYPE')),
  X_OBJECTIVE_CODE,
  X_CONTROL_ID
  );

  insert into AMW_CONSTRAINTS_TL (
    LAST_UPDATE_LOGIN,
    CONSTRAINT_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_CONSTRAINT_ID,
    X_CONSTRAINT_NAME,
    X_CONSTRAINT_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMW_CONSTRAINTS_TL T
    where T.CONSTRAINT_ID = X_CONSTRAINT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- ===============================================================
procedure LOCK_ROW (
  X_CONSTRAINT_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENTERED_BY_ID in NUMBER,
  X_TYPE_CODE in VARCHAR2,
  X_RISK_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
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
  X_CONSTRAINT_NAME in VARCHAR2,
  X_CONSTRAINT_DESCRIPTION in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_CLASSIFICATION in VARCHAR2,
  X_OBJECTIVE_CODE in VARCHAR2,
  X_CONTROL_ID in NUMBER
) is
  cursor c is select
    START_DATE,
    END_DATE,
    ENTERED_BY_ID,
    TYPE_CODE,
    RISK_ID,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
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
    APPROVAL_STATUS,
    CLASSIFICATION,
    OBJECTIVE_CODE,
    CONTROL_ID
    from AMW_CONSTRAINTS_B
    where CONSTRAINT_REV_ID = X_CONSTRAINT_REV_ID
    for update of CONSTRAINT_REV_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMW_CONSTRAINTS_TL
    where CONSTRAINT_ID = X_CONSTRAINT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CONSTRAINT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (
          ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.ENTERED_BY_ID = X_ENTERED_BY_ID)
           OR ((recinfo.ENTERED_BY_ID is null) AND (X_ENTERED_BY_ID is null)))
      AND ((recinfo.TYPE_CODE = X_TYPE_CODE)
           OR ((recinfo.TYPE_CODE is null) AND (X_TYPE_CODE is null)))
      AND ((recinfo.RISK_ID = X_RISK_ID)
           OR ((recinfo.RISK_ID is null) AND (X_RISK_ID is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
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
      AND ((recinfo.APPROVAL_STATUS = X_APPROVAL_STATUS)
           OR ((recinfo.APPROVAL_STATUS is null) AND (X_APPROVAL_STATUS is null)))
      AND ((recinfo.CLASSIFICATION = X_CLASSIFICATION)
           OR ((recinfo.CLASSIFICATION is null) AND (X_CLASSIFICATION is null)))
      AND ((recinfo.OBJECTIVE_CODE = X_OBJECTIVE_CODE)
           OR ((recinfo.OBJECTIVE_CODE is null) AND (X_OBJECTIVE_CODE is null)))
      AND ((recinfo.CONTROL_ID = X_CONTROL_ID)
           OR ((recinfo.CONTROL_ID is null) AND (X_CONTROL_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_CONSTRAINT_NAME)
          AND ((tlinfo.DESCRIPTION = X_CONSTRAINT_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_CONSTRAINT_DESCRIPTION is null)))
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



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
-- 		  	update AMW_CONSTRAINTS_B and AMW_CONSTRAINTS_TL
-- ===============================================================
procedure UPDATE_ROW (
  X_CONSTRAINT_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ENTERED_BY_ID in NUMBER,
  X_TYPE_CODE in VARCHAR2,
  X_RISK_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
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
  X_CONSTRAINT_NAME in VARCHAR2,
  X_CONSTRAINT_DESCRIPTION in VARCHAR2,
  X_APPROVAL_STATUS in VARCHAR2,
  X_CLASSIFICATION in VARCHAR2,
  X_OBJECTIVE_CODE in VARCHAR2,
  X_CONTROL_ID in NUMBER
) is
begin
  update AMW_CONSTRAINTS_B set
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    ENTERED_BY_ID = X_ENTERED_BY_ID,
    TYPE_CODE = X_TYPE_CODE,
    RISK_ID = X_RISK_ID,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
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
    APPROVAL_STATUS = X_APPROVAL_STATUS,
    CLASSIFICATION = X_CLASSIFICATION,
    OBJECTIVE_CODE = X_OBJECTIVE_CODE,
    CONTROL_ID = X_CONTROL_ID
  where CONSTRAINT_REV_ID = X_CONSTRAINT_REV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMW_CONSTRAINTS_TL set
    NAME = X_CONSTRAINT_NAME,
    DESCRIPTION = X_CONSTRAINT_DESCRIPTION,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CONSTRAINT_ID = X_CONSTRAINT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_CONSTRAINT_ID in NUMBER
) is
begin
  delete from AMW_CONSTRAINTS_TL
  where CONSTRAINT_ID = X_CONSTRAINT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_CONSTRAINTS_B
  where CONSTRAINT_ID = X_CONSTRAINT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;



-- ===============================================================
-- Procedure name
--          ADD_LANGUAGE
-- Purpose
--
-- ===============================================================
procedure ADD_LANGUAGE
is
begin
  delete from AMW_CONSTRAINTS_TL T
  where not exists
    (select NULL
    from AMW_CONSTRAINTS_B B
    where B.CONSTRAINT_ID = T.CONSTRAINT_ID
    );

  update AMW_CONSTRAINTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMW_CONSTRAINTS_TL B
    where B.CONSTRAINT_ID = T.CONSTRAINT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CONSTRAINT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CONSTRAINT_ID,
      SUBT.LANGUAGE
    from AMW_CONSTRAINTS_TL SUBB, AMW_CONSTRAINTS_TL SUBT
    where SUBB.CONSTRAINT_ID = SUBT.CONSTRAINT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMW_CONSTRAINTS_TL (
    LAST_UPDATE_LOGIN,
    CONSTRAINT_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.CONSTRAINT_ID,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_CONSTRAINTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_CONSTRAINTS_TL T
    where T.CONSTRAINT_ID = B.CONSTRAINT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- ----------------------------------------------------------------------
end AMW_CONSTRAINTS_PKG;


/
