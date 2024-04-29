--------------------------------------------------------
--  DDL for Package Body JTF_TASK_DATE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_DATE_TYPES_PKG" as
/* $Header: jtftkdtb.pls 115.17 2004/08/30 23:40:53 sachoudh ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DATE_TYPE_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_APPLICATION_REFERENCE in VARCHAR2,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_DATE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_TASK_DATE_TYPES_B
    where DATE_TYPE_ID = X_DATE_TYPE_ID
    ;
begin
  insert into JTF_TASK_DATE_TYPES_B (
    DATE_TYPE_ID,
    SEQUENCE,
    APPLICATION_REFERENCE,
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
    ATTRIBUTE_CATEGORY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_DATE_TYPE_ID,
    X_SEQUENCE,
    X_APPLICATION_REFERENCE,
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
    X_ATTRIBUTE_CATEGORY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );

  insert into JTF_TASK_DATE_TYPES_TL (
    DATE_TYPE_ID,
    DATE_TYPE,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DATE_TYPE_ID,
    X_DATE_TYPE,
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
    from JTF_TASK_DATE_TYPES_TL T
    where T.DATE_TYPE_ID = X_DATE_TYPE_ID
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
  X_DATE_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
        OBJECT_VERSION_NUMBER
    from JTF_TASK_DATE_TYPES_VL
    where DATE_TYPE_ID = X_DATE_TYPE_ID
    for update of DATE_TYPE_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;


end LOCK_ROW;

procedure UPDATE_ROW (
  X_DATE_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SEQUENCE in NUMBER,
  X_APPLICATION_REFERENCE in VARCHAR2,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_DATE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_TASK_DATE_TYPES_B set
    SEQUENCE = X_SEQUENCE,
    /*changed from X_OBJECT_VERSION_NUMBER TO X_OBJECT_VERSION_NUMBER +1 */
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER+1,
    APPLICATION_REFERENCE = X_APPLICATION_REFERENCE,
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
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DATE_TYPE_ID = X_DATE_TYPE_ID  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_TASK_DATE_TYPES_TL set
    DATE_TYPE = X_DATE_TYPE,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DATE_TYPE_ID = X_DATE_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DATE_TYPE_ID in NUMBER
) is
begin
  delete from JTF_TASK_DATE_TYPES_TL
  where DATE_TYPE_ID = X_DATE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_TASK_DATE_TYPES_B
  where DATE_TYPE_ID = X_DATE_TYPE_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

   /* Solving Perf. Bug 3723927*/
     /* The following delete and update statements are commented out */
     /* as a quick workaround to fix the time-consuming table handler issue */
   /*

  delete from JTF_TASK_DATE_TYPES_TL T
  where not exists
    (select NULL
    from JTF_TASK_DATE_TYPES_B B
    where B.DATE_TYPE_ID = T.DATE_TYPE_ID
    );

  update JTF_TASK_DATE_TYPES_TL T set (
      DATE_TYPE,
      DESCRIPTION
    ) = (select
      B.DATE_TYPE,
      B.DESCRIPTION
    from JTF_TASK_DATE_TYPES_TL B
    where B.DATE_TYPE_ID = T.DATE_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DATE_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DATE_TYPE_ID,
      SUBT.LANGUAGE
    from JTF_TASK_DATE_TYPES_TL SUBB, JTF_TASK_DATE_TYPES_TL SUBT
    where SUBB.DATE_TYPE_ID = SUBT.DATE_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DATE_TYPE <> SUBT.DATE_TYPE
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  )); */

  insert into JTF_TASK_DATE_TYPES_TL (
    DATE_TYPE_ID,
    DATE_TYPE,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DATE_TYPE_ID,
    B.DATE_TYPE,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_TASK_DATE_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_TASK_DATE_TYPES_TL T
    where T.DATE_TYPE_ID = B.DATE_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure translate_row(
   x_date_type_id in number,
   x_date_type in varchar2,
   x_description in varchar2,
   x_owner   in varchar2 )
as
begin
  update jtf_task_date_types_tl set
    date_type = nvl(x_date_type,date_type),
    description = nvl(x_description,description ),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATEd_by = decode(x_owner,'SEED',1,0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where date_type_id = X_date_type_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end ;

end JTF_TASK_DATE_TYPES_PKG;

/
