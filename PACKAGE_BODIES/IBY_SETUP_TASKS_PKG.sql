--------------------------------------------------------
--  DDL for Package Body IBY_SETUP_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_SETUP_TASKS_PKG" as
/* $Header: ibytaskb.pls 120.3 2005/12/01 21:54:02 chhu noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TASK_CODE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LEAF_NODE_FLAG in VARCHAR2,
  X_PARENT_TASK_CODE in VARCHAR2,
  X_DEST_FUNCTION_NAME in VARCHAR2,
  X_SETUP_FLOW_CODE in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IBY_SETUP_TASKS_B
    where TASK_CODE = X_TASK_CODE
    ;
begin
  insert into IBY_SETUP_TASKS_B (
    TASK_CODE,
    STATUS,
    LEAF_NODE_FLAG,
    PARENT_TASK_CODE,
    DEST_FUNCTION_NAME,
    SETUP_FLOW_CODE,
    DISPLAY_ORDER,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TASK_CODE,
    X_STATUS,
    X_LEAF_NODE_FLAG,
    X_PARENT_TASK_CODE,
    X_DEST_FUNCTION_NAME,
    X_SETUP_FLOW_CODE,
    X_DISPLAY_ORDER,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IBY_SETUP_TASKS_TL (
    TASK_CODE,
    TASK_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TASK_CODE,
    X_TASK_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IBY_SETUP_TASKS_TL T
    where T.TASK_CODE = X_TASK_CODE
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
  X_TASK_CODE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LEAF_NODE_FLAG in VARCHAR2,
  X_PARENT_TASK_CODE in VARCHAR2,
  X_DEST_FUNCTION_NAME in VARCHAR2,
  X_SETUP_FLOW_CODE in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      STATUS,
      LEAF_NODE_FLAG,
      PARENT_TASK_CODE,
      DEST_FUNCTION_NAME,
      SETUP_FLOW_CODE,
      DISPLAY_ORDER,
      OBJECT_VERSION_NUMBER
    from IBY_SETUP_TASKS_B
    where TASK_CODE = X_TASK_CODE
    for update of TASK_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TASK_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IBY_SETUP_TASKS_TL
    where TASK_CODE = X_TASK_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TASK_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.STATUS = X_STATUS)
           OR ((recinfo.STATUS is null) AND (X_STATUS is null)))
      AND (recinfo.LEAF_NODE_FLAG = X_LEAF_NODE_FLAG)
      AND ((recinfo.PARENT_TASK_CODE = X_PARENT_TASK_CODE)
           OR ((recinfo.PARENT_TASK_CODE is null) AND (X_PARENT_TASK_CODE is null)))
      AND ((recinfo.DEST_FUNCTION_NAME = X_DEST_FUNCTION_NAME)
           OR ((recinfo.DEST_FUNCTION_NAME is null) AND (X_DEST_FUNCTION_NAME is null)))
      AND ((recinfo.SETUP_FLOW_CODE = X_SETUP_FLOW_CODE)
           OR ((recinfo.SETUP_FLOW_CODE is null) AND (X_SETUP_FLOW_CODE is null)))
      AND ((recinfo.DISPLAY_ORDER = X_DISPLAY_ORDER)
           OR ((recinfo.DISPLAY_ORDER is null) AND (X_DISPLAY_ORDER is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TASK_NAME = X_TASK_NAME)
               OR ((tlinfo.TASK_NAME is null) AND (X_TASK_NAME is null)))
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
  X_TASK_CODE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LEAF_NODE_FLAG in VARCHAR2,
  X_PARENT_TASK_CODE in VARCHAR2,
  X_DEST_FUNCTION_NAME in VARCHAR2,
  X_SETUP_FLOW_CODE in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IBY_SETUP_TASKS_B set
    STATUS = X_STATUS,
    LEAF_NODE_FLAG = X_LEAF_NODE_FLAG,
    PARENT_TASK_CODE = X_PARENT_TASK_CODE,
    DEST_FUNCTION_NAME = X_DEST_FUNCTION_NAME,
    SETUP_FLOW_CODE = X_SETUP_FLOW_CODE,
    DISPLAY_ORDER = X_DISPLAY_ORDER,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TASK_CODE = X_TASK_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IBY_SETUP_TASKS_TL set
    TASK_NAME = X_TASK_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TASK_CODE = X_TASK_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure UPDATE_ROW_NO_STATUS (
  X_TASK_CODE in VARCHAR2,
  X_LEAF_NODE_FLAG in VARCHAR2,
  X_PARENT_TASK_CODE in VARCHAR2,
  X_DEST_FUNCTION_NAME in VARCHAR2,
  X_SETUP_FLOW_CODE in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IBY_SETUP_TASKS_B set
    LEAF_NODE_FLAG = X_LEAF_NODE_FLAG,
    PARENT_TASK_CODE = X_PARENT_TASK_CODE,
    DEST_FUNCTION_NAME = X_DEST_FUNCTION_NAME,
    SETUP_FLOW_CODE = X_SETUP_FLOW_CODE,
    DISPLAY_ORDER = X_DISPLAY_ORDER,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TASK_CODE = X_TASK_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IBY_SETUP_TASKS_TL set
    TASK_NAME = X_TASK_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TASK_CODE = X_TASK_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW_NO_STATUS;

procedure DELETE_ROW (
  X_TASK_CODE in VARCHAR2
) is
begin
  delete from IBY_SETUP_TASKS_TL
  where TASK_CODE = X_TASK_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IBY_SETUP_TASKS_B
  where TASK_CODE = X_TASK_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IBY_SETUP_TASKS_TL T
  where not exists
    (select NULL
    from IBY_SETUP_TASKS_B B
    where B.TASK_CODE = T.TASK_CODE
    );

  update IBY_SETUP_TASKS_TL T set (
      TASK_NAME,
      DESCRIPTION
    ) = (select
      B.TASK_NAME,
      B.DESCRIPTION
    from IBY_SETUP_TASKS_TL B
    where B.TASK_CODE = T.TASK_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TASK_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.TASK_CODE,
      SUBT.LANGUAGE
    from IBY_SETUP_TASKS_TL SUBB, IBY_SETUP_TASKS_TL SUBT
    where SUBB.TASK_CODE = SUBT.TASK_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TASK_NAME <> SUBT.TASK_NAME
      or (SUBB.TASK_NAME is null and SUBT.TASK_NAME is not null)
      or (SUBB.TASK_NAME is not null and SUBT.TASK_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into IBY_SETUP_TASKS_TL (
    TASK_CODE,
    TASK_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TASK_CODE,
    B.TASK_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IBY_SETUP_TASKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IBY_SETUP_TASKS_TL T
    where T.TASK_CODE = B.TASK_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure LOAD_SEED_ROW (
  X_TASK_CODE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LEAF_NODE_FLAG in VARCHAR2,
  X_PARENT_TASK_CODE in VARCHAR2,
  X_DEST_FUNCTION_NAME in VARCHAR2,
  X_SETUP_FLOW_CODE in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)

is
    row_id VARCHAR2(200);
  begin
UPDATE_ROW_NO_STATUS (
  X_TASK_CODE,
  X_LEAF_NODE_FLAG,
  X_PARENT_TASK_CODE,
  X_DEST_FUNCTION_NAME,
  X_SETUP_FLOW_CODE,
  X_DISPLAY_ORDER,
  X_OBJECT_VERSION_NUMBER,
  X_TASK_NAME,
  X_DESCRIPTION,
  X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN
);

  exception
    when no_data_found then

INSERT_ROW (
  row_id,
  X_TASK_CODE,
  X_STATUS,
  X_LEAF_NODE_FLAG,
  X_PARENT_TASK_CODE,
  X_DEST_FUNCTION_NAME,
  X_SETUP_FLOW_CODE,
  X_DISPLAY_ORDER,
  X_OBJECT_VERSION_NUMBER,
  X_TASK_NAME,
  X_DESCRIPTION,
  X_CREATION_DATE,
  X_CREATED_BY,
  X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN
);

  end;

procedure TRANSLATE_ROW (
  X_TASK_CODE in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2)
is
begin
  update iby_setup_tasks_tl set
    TASK_NAME = X_TASK_NAME,
    DESCRIPTION = X_DESCRIPTION,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY = fnd_load_util.owner_id(X_OWNER),
    LAST_UPDATE_DATE = trunc(sysdate),
    LAST_UPDATE_LOGIN = fnd_load_util.owner_id(X_OWNER),
    SOURCE_LANG = userenv('LANG')
  where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    and TASK_CODE = X_TASK_CODE;
end;

end IBY_SETUP_TASKS_PKG;

/
