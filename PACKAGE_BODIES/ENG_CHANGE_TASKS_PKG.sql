--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_TASKS_PKG" as
/* $Header: ENGTASKB.pls 115.0 2003/09/07 07:26:35 akumar noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CHANGE_TASK_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DEFAULT_ASSIGNEE_ID in NUMBER,
  X_DEFAULT_ASSIGNEE_TYPE in VARCHAR2,
  X_CHANGE_TEMPLATE_ID in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ENG_CHANGE_TASKS_B
    where CHANGE_TASK_ID = X_CHANGE_TASK_ID
    ;
begin
  insert into ENG_CHANGE_TASKS_B (
    CHANGE_TASK_ID,
    ORGANIZATION_ID,
    SEQUENCE_NUMBER,
    REQUIRED_FLAG,
    DEFAULT_ASSIGNEE_ID,
    DEFAULT_ASSIGNEE_TYPE,
    CHANGE_TEMPLATE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CHANGE_TASK_ID,
    X_ORGANIZATION_ID,
    X_SEQUENCE_NUMBER,
    X_REQUIRED_FLAG,
    X_DEFAULT_ASSIGNEE_ID,
    X_DEFAULT_ASSIGNEE_TYPE,
    X_CHANGE_TEMPLATE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ENG_CHANGE_TASKS_TL (
    CHANGE_TASK_ID,
    TASK_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHANGE_TASK_ID,
    X_TASK_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_TASKS_TL T
    where T.CHANGE_TASK_ID = X_CHANGE_TASK_ID
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
  X_CHANGE_TASK_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DEFAULT_ASSIGNEE_ID in NUMBER,
  X_DEFAULT_ASSIGNEE_TYPE in VARCHAR2,
  X_CHANGE_TEMPLATE_ID in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ORGANIZATION_ID,
      SEQUENCE_NUMBER,
      REQUIRED_FLAG,
      DEFAULT_ASSIGNEE_ID,
      DEFAULT_ASSIGNEE_TYPE,
      CHANGE_TEMPLATE_ID
    from ENG_CHANGE_TASKS_B
    where CHANGE_TASK_ID = X_CHANGE_TASK_ID
    for update of CHANGE_TASK_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TASK_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_TASKS_TL
    where CHANGE_TASK_ID = X_CHANGE_TASK_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHANGE_TASK_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
      AND ((recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
           OR ((recinfo.SEQUENCE_NUMBER is null) AND (X_SEQUENCE_NUMBER is null)))
      AND (recinfo.REQUIRED_FLAG = X_REQUIRED_FLAG)
      AND ((recinfo.DEFAULT_ASSIGNEE_ID = X_DEFAULT_ASSIGNEE_ID)
           OR ((recinfo.DEFAULT_ASSIGNEE_ID is null) AND (X_DEFAULT_ASSIGNEE_ID is null)))
      AND ((recinfo.DEFAULT_ASSIGNEE_TYPE = X_DEFAULT_ASSIGNEE_TYPE)
           OR ((recinfo.DEFAULT_ASSIGNEE_TYPE is null) AND (X_DEFAULT_ASSIGNEE_TYPE is null)))
      AND ((recinfo.CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID)
           OR ((recinfo.CHANGE_TEMPLATE_ID is null) AND (X_CHANGE_TEMPLATE_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TASK_NAME = X_TASK_NAME)
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
  X_CHANGE_TASK_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DEFAULT_ASSIGNEE_ID in NUMBER,
  X_DEFAULT_ASSIGNEE_TYPE in VARCHAR2,
  X_CHANGE_TEMPLATE_ID in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ENG_CHANGE_TASKS_B set
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
    REQUIRED_FLAG = X_REQUIRED_FLAG,
    DEFAULT_ASSIGNEE_ID = X_DEFAULT_ASSIGNEE_ID,
    DEFAULT_ASSIGNEE_TYPE = X_DEFAULT_ASSIGNEE_TYPE,
    CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CHANGE_TASK_ID = X_CHANGE_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_TASKS_TL set
    TASK_NAME = X_TASK_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHANGE_TASK_ID = X_CHANGE_TASK_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHANGE_TASK_ID in NUMBER
) is
begin
  delete from ENG_CHANGE_TASKS_TL
  where CHANGE_TASK_ID = X_CHANGE_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_TASKS_B
  where CHANGE_TASK_ID = X_CHANGE_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ENG_CHANGE_TASKS_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_TASKS_B B
    where B.CHANGE_TASK_ID = T.CHANGE_TASK_ID
    );

  update ENG_CHANGE_TASKS_TL T set (
      TASK_NAME,
      DESCRIPTION
    ) = (select
      B.TASK_NAME,
      B.DESCRIPTION
    from ENG_CHANGE_TASKS_TL B
    where B.CHANGE_TASK_ID = T.CHANGE_TASK_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHANGE_TASK_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHANGE_TASK_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_TASKS_TL SUBB, ENG_CHANGE_TASKS_TL SUBT
    where SUBB.CHANGE_TASK_ID = SUBT.CHANGE_TASK_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TASK_NAME <> SUBT.TASK_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ENG_CHANGE_TASKS_TL (
    CHANGE_TASK_ID,
    TASK_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CHANGE_TASK_ID,
    B.TASK_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_TASKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_TASKS_TL T
    where T.CHANGE_TASK_ID = B.CHANGE_TASK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ENG_CHANGE_TASKS_PKG;

/
