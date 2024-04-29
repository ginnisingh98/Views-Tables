--------------------------------------------------------
--  DDL for Package Body AHL_MR_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MR_ACTIONS_PKG" as
/* $Header: AHLLMRAB.pls 115.4 2002/12/04 19:22:06 rtadikon noship $ */
procedure INSERT_ROW (
  X_ROWID                       in out nocopy     VARCHAR2,
  X_MR_ACTION_ID                in      NUMBER,
  X_OBJECT_VERSION_NUMBER       in      NUMBER,
  X_MR_HEADER_ID                in      NUMBER,
  X_MR_ACTION_CODE              in      VARCHAR2,
  X_PLAN_ID                     in      NUMBER,
  X_ATTRIBUTE_CATEGORY          in      VARCHAR2,
  X_ATTRIBUTE1                  in      VARCHAR2,
  X_ATTRIBUTE2                  in      VARCHAR2,
  X_ATTRIBUTE3                  in      VARCHAR2,
  X_ATTRIBUTE4                  in      VARCHAR2,
  X_ATTRIBUTE5                  in      VARCHAR2,
  X_ATTRIBUTE6                  in      VARCHAR2,
  X_ATTRIBUTE7                  in      VARCHAR2,
  X_ATTRIBUTE8                  in      VARCHAR2,
  X_ATTRIBUTE9                  in      VARCHAR2,
  X_ATTRIBUTE10                 in      VARCHAR2,
  X_ATTRIBUTE11                 in      VARCHAR2,
  X_ATTRIBUTE12                 in      VARCHAR2,
  X_ATTRIBUTE13                 in      VARCHAR2,
  X_ATTRIBUTE14                 in      VARCHAR2,
  X_ATTRIBUTE15                 in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_CREATION_DATE               in      DATE,
  X_CREATED_BY                  in      NUMBER,
  X_LAST_UPDATE_DATE            in      DATE,
  X_LAST_UPDATED_BY             in      NUMBER,
  X_LAST_UPDATE_LOGIN           in      NUMBER
) is
  cursor C is select ROWID from AHL_MR_ACTIONS_B
    where MR_ACTION_ID = X_MR_ACTION_ID
    ;
begin
  insert into AHL_MR_ACTIONS_B (
    MR_ACTION_ID,
    OBJECT_VERSION_NUMBER,
    MR_HEADER_ID,
    MR_ACTION_CODE,
    PLAN_ID,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MR_ACTION_ID,
    X_OBJECT_VERSION_NUMBER,
    X_MR_HEADER_ID,
    X_MR_ACTION_CODE,
    X_PLAN_ID,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AHL_MR_ACTIONS_TL (
    MR_ACTION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_MR_ACTION_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AHL_MR_ACTIONS_TL T
    where T.MR_ACTION_ID = X_MR_ACTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_MR_ACTION_ID                in      NUMBER,
  X_OBJECT_VERSION_NUMBER       in      NUMBER,
  X_MR_HEADER_ID                in      NUMBER,
  X_MR_ACTION_CODE              in      VARCHAR2,
  X_PLAN_ID                     in      NUMBER,
  X_ATTRIBUTE_CATEGORY          in      VARCHAR2,
  X_ATTRIBUTE1                  in      VARCHAR2,
  X_ATTRIBUTE2                  in      VARCHAR2,
  X_ATTRIBUTE3                  in      VARCHAR2,
  X_ATTRIBUTE4                  in      VARCHAR2,
  X_ATTRIBUTE5                  in      VARCHAR2,
  X_ATTRIBUTE6                  in      VARCHAR2,
  X_ATTRIBUTE7                  in      VARCHAR2,
  X_ATTRIBUTE8                  in      VARCHAR2,
  X_ATTRIBUTE9                  in      VARCHAR2,
  X_ATTRIBUTE10                 in      VARCHAR2,
  X_ATTRIBUTE11                 in      VARCHAR2,
  X_ATTRIBUTE12                 in      VARCHAR2,
  X_ATTRIBUTE13                 in      VARCHAR2,
  X_ATTRIBUTE14                 in      VARCHAR2,
  X_ATTRIBUTE15                 in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      DATE,
  X_LAST_UPDATED_BY             in      NUMBER,
  X_LAST_UPDATE_LOGIN           in      NUMBER
) is
begin
  update AHL_MR_ACTIONS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER + 1 ,
    MR_HEADER_ID = X_MR_HEADER_ID,
    MR_ACTION_CODE = X_MR_ACTION_CODE,
    PLAN_ID = X_PLAN_ID,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MR_ACTION_ID = X_MR_ACTION_ID
  AND   object_version_number=x_object_version_number;

  if (sql%ROWCOUNT=0) then
             FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
             FND_MSG_PUB.ADD;
  else
          update AHL_MR_ACTIONS_TL set
            DESCRIPTION = X_DESCRIPTION,
            LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
            LAST_UPDATED_BY = X_LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
            SOURCE_LANG = userenv('LANG')
          where MR_ACTION_ID = X_MR_ACTION_ID
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_MR_ACTION_ID in NUMBER
) is
begin
  delete from AHL_MR_ACTIONS_TL
  where MR_ACTION_ID = X_MR_ACTION_ID;

  if (sql%ROWCOUNT=0) then
             FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
             FND_MSG_PUB.ADD;
  else
  delete from AHL_MR_ACTIONS_B
  where MR_ACTION_ID = X_MR_ACTION_ID;
  if (sql%ROWCOUNT=0) then
             FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
             FND_MSG_PUB.ADD;
  END IF;

  END IF;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AHL_MR_ACTIONS_TL T
  where not exists
    (select NULL
    from AHL_MR_ACTIONS_B B
    where B.MR_ACTION_ID = T.MR_ACTION_ID
    );

  update AHL_MR_ACTIONS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from AHL_MR_ACTIONS_TL B
    where B.MR_ACTION_ID = T.MR_ACTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MR_ACTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MR_ACTION_ID,
      SUBT.LANGUAGE
    from AHL_MR_ACTIONS_TL SUBB, AHL_MR_ACTIONS_TL SUBT
    where SUBB.MR_ACTION_ID = SUBT.MR_ACTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AHL_MR_ACTIONS_TL (
    MR_ACTION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MR_ACTION_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AHL_MR_ACTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AHL_MR_ACTIONS_TL T
    where T.MR_ACTION_ID = B.MR_ACTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AHL_MR_ACTIONS_PKG;

/
