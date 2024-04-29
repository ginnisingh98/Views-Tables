--------------------------------------------------------
--  DDL for Package Body JTF_TASK_PRIORITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_PRIORITIES_PKG" as
/* $Header: jtftkprb.pls 120.2 2006/05/30 13:16:22 sbarat ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_TASK_PRIORITY_ID in NUMBER,
  X_IMPORTANCE_LEVEL in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
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
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_TASK_PRIORITIES_B
    where TASK_PRIORITY_ID = X_TASK_PRIORITY_ID
    ;
begin
  insert into JTF_TASK_PRIORITIES_B (
    TASK_PRIORITY_ID,
    IMPORTANCE_LEVEL,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    SEEDED_FLAG,
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
    X_TASK_PRIORITY_ID,
    X_IMPORTANCE_LEVEL,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_SEEDED_FLAG,
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

  insert into JTF_TASK_PRIORITIES_TL (
    TASK_PRIORITY_ID,
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
    X_TASK_PRIORITY_ID,
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
    from JTF_TASK_PRIORITIES_TL T
    where T.TASK_PRIORITY_ID = X_TASK_PRIORITY_ID
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
  X_TASK_PRIORITY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
        OBJECT_VERSION_NUMBER
    from JTF_TASK_PRIORITIES_VL
    where TASK_PRIORITY_ID = X_TASK_PRIORITY_ID
    for update of TASK_PRIORITY_ID nowait;
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
  X_TASK_PRIORITY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_IMPORTANCE_LEVEL in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
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
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_TASK_PRIORITIES_B set
    IMPORTANCE_LEVEL = X_IMPORTANCE_LEVEL,
    /*CHANGED TO OBJECT_VERSION_NUMBER +1 */
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER+1,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    SEEDED_FLAG = X_SEEDED_FLAG,
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
  where TASK_PRIORITY_ID = X_TASK_PRIORITY_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_TASK_PRIORITIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TASK_PRIORITY_ID = X_TASK_PRIORITY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TASK_PRIORITY_ID in NUMBER
) is
begin
  delete from JTF_TASK_PRIORITIES_TL
  where TASK_PRIORITY_ID = X_TASK_PRIORITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_TASK_PRIORITIES_B
  where TASK_PRIORITY_ID = X_TASK_PRIORITY_ID ;

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
  delete from JTF_TASK_PRIORITIES_TL T
  where not exists
    (select NULL
    from JTF_TASK_PRIORITIES_B B
    where B.TASK_PRIORITY_ID = T.TASK_PRIORITY_ID
    );

  update JTF_TASK_PRIORITIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from JTF_TASK_PRIORITIES_TL B
    where B.TASK_PRIORITY_ID = T.TASK_PRIORITY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TASK_PRIORITY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TASK_PRIORITY_ID,
      SUBT.LANGUAGE
    from JTF_TASK_PRIORITIES_TL SUBB, JTF_TASK_PRIORITIES_TL SUBT
    where SUBB.TASK_PRIORITY_ID = SUBT.TASK_PRIORITY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
  */
  insert into JTF_TASK_PRIORITIES_TL (
    TASK_PRIORITY_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ INDEX(b JTF_TASK_PRIORITIES_TL_U1) INDEX (l FND_LANGUAGES_N1) */  -- Added index hint for bug# 5213367 on 30/05/2006
    B.TASK_PRIORITY_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_TASK_PRIORITIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_TASK_PRIORITIES_TL T
    where T.TASK_PRIORITY_ID = B.TASK_PRIORITY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_TASK_priority_ID in varchar2,
  X_NAME in varchar2,
  X_DESCRIPTION in varchar2,
  x_owner in varchar2  ) is
l_user_id                 NUMBER := 0;
   BEGIN
      IF x_owner = 'SEED'
      THEN
         l_user_id := 1;
      END IF;
  update jtf_task_priorities_tl set
    NAME= nvl(X_NAME,name),
    DESCRIPTION= nvl(X_DESCRIPTION,description),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG'),
    last_updated_by  = l_user_id
    where task_priority_id = X_task_priority_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_TASK_PRIORITY_ID in NUMBER,
  X_IMPORTANCE_LEVEL in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
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
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
)
AS
      l_user_id                 NUMBER := 0;
      l_task_type_id            NUMBER;
      l_rowid                   ROWID;
      l_object_version_number   NUMBER;
   BEGIN
      IF x_owner = 'SEED'
      THEN
         l_user_id := 1;
      END IF;

      --Check if there is record in the base table as well as in the TL table.
      --If there is some faulty data where we populate the base table without the
      --populating the TL table then this query will throw no_data_found exception.


      SELECT object_version_number
        INTO l_object_version_number
         from jtf_task_priorities_vl
         where  task_priority_id = x_task_priority_id;



      update JTF_TASK_PRIORITIES_B set
        IMPORTANCE_LEVEL = X_IMPORTANCE_LEVEL,
        /*CHANGED TO OBJECT_VERSION_NUMBER +1 */
         OBJECT_VERSION_NUMBER = l_object_version_number+1,
          START_DATE_ACTIVE = X_START_DATE_ACTIVE,
           END_DATE_ACTIVE = X_END_DATE_ACTIVE,
            SEEDED_FLAG = X_SEEDED_FLAG,
             LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = l_user_id,
           LAST_UPDATE_LOGIN = 0
         where TASK_PRIORITY_ID = X_TASK_PRIORITY_ID ;


      update JTF_TASK_PRIORITIES_TL set
         NAME = X_NAME,
          DESCRIPTION = X_DESCRIPTION,
            LAST_UPDATE_DATE = sysdate,
           LAST_UPDATED_BY = l_user_id,
          LAST_UPDATE_LOGIN = 0,
         SOURCE_LANG = userenv('LANG')
       where TASK_PRIORITY_ID = X_TASK_PRIORITY_ID
        and userenv('LANG') in (LANGUAGE, SOURCE_LANG);


   exception
   when no_data_found then


   jtf_task_priorities_pkg.insert_row (
	    x_rowid => l_rowid ,
         x_task_priority_id => x_task_priority_id,
	    x_importance_level => x_IMPORTANCE_LEVEL ,
         x_start_date_active => x_start_date_active,
         x_end_date_active => x_end_date_active,
         x_seeded_flag => x_seeded_flag,
         x_attribute1 => x_attribute1,
         x_attribute2 => x_attribute2,
         x_attribute3 => x_attribute3,
         x_attribute4 => x_attribute4,
         x_attribute5 => x_attribute5,
         x_attribute6 => x_attribute6,
         x_attribute7 => x_attribute7,
         x_attribute8 => x_attribute8,
         x_attribute9 => x_attribute9,
         x_attribute10 => x_attribute10,
         x_attribute11 => x_attribute11,
         x_attribute12 => x_attribute12,
         x_attribute13 => x_attribute13,
         x_attribute14 => x_attribute14,
         x_attribute15 => x_attribute15,
         x_attribute_category => x_attribute_category,
         x_name => x_name,
         x_description => x_description,
	    x_creation_date => sysdate ,
	    x_created_by => l_user_id  ,
         x_last_update_date => SYSDATE,
         x_last_updated_by => l_user_id  ,
         x_last_update_login => 0
      );

end ;



end JTF_TASK_PRIORITIES_PKG;

/
