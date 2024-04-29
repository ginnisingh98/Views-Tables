--------------------------------------------------------
--  DDL for Package Body AMS_IMP_CONFIG_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_CONFIG_COMPONENTS_PKG" as
/* $Header: amsiccpb.pls 115.4 2004/04/07 19:12:12 usingh ship $ */
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_CONFIG_COMPONENT_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_IMPORT_MODULE in VARCHAR2,
  X_COMPONENT_NAME in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_IMP_CONFIG_COMPONENTS (
    CREATION_DATE,
    IMPORT_TYPE,
    COMPONENT_TYPE,
    IMPORT_MODULE,
    COMPONENT_NAME,
    ACCESS_ALLOWED,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    CONFIG_COMPONENT_ID,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER)
    values
    (
    X_CREATION_DATE,
    X_IMPORT_TYPE,
    X_COMPONENT_TYPE,
    X_IMPORT_MODULE,
    X_COMPONENT_NAME,
    X_ACCESS_ALLOWED,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_CONFIG_COMPONENT_ID,
    X_LAST_UPDATED_BY,
    X_OBJECT_VERSION_NUMBER);

end INSERT_ROW;

procedure LOCK_ROW (
  X_CONFIG_COMPONENT_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_IMPORT_MODULE in VARCHAR2,
  X_COMPONENT_NAME in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c1 is select
      IMPORT_TYPE,
      COMPONENT_TYPE,
      IMPORT_MODULE,
      COMPONENT_NAME,
      ACCESS_ALLOWED,
      OBJECT_VERSION_NUMBER,
      CONFIG_COMPONENT_ID
    from AMS_IMP_CONFIG_COMPONENTS
    where CONFIG_COMPONENT_ID = X_CONFIG_COMPONENT_ID
    for update of CONFIG_COMPONENT_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.CONFIG_COMPONENT_ID = X_CONFIG_COMPONENT_ID)
          AND (tlinfo.IMPORT_TYPE = X_IMPORT_TYPE)
          AND (tlinfo.COMPONENT_TYPE = X_COMPONENT_TYPE)
          AND (tlinfo.IMPORT_MODULE = X_IMPORT_MODULE)
          AND (tlinfo.COMPONENT_NAME = X_COMPONENT_NAME)
          AND (tlinfo.ACCESS_ALLOWED = X_ACCESS_ALLOWED)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CONFIG_COMPONENT_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_IMPORT_MODULE in VARCHAR2,
  X_COMPONENT_NAME in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_IMP_CONFIG_COMPONENTS set
    IMPORT_TYPE = X_IMPORT_TYPE,
    COMPONENT_TYPE = X_COMPONENT_TYPE,
    IMPORT_MODULE = X_IMPORT_MODULE,
    COMPONENT_NAME = X_COMPONENT_NAME,
    ACCESS_ALLOWED = X_ACCESS_ALLOWED,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CONFIG_COMPONENT_ID = X_CONFIG_COMPONENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CONFIG_COMPONENT_ID in NUMBER
) is
begin
  delete from AMS_IMP_CONFIG_COMPONENTS
  where CONFIG_COMPONENT_ID = X_CONFIG_COMPONENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_CONFIG_COMPONENT_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_IMPORT_MODULE in VARCHAR2,
  X_COMPONENT_NAME in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

l_user_id number := 0;
l_concom_id  number;
l_obj_verno number := 1;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

 cursor c_chk_col_exists is
  select 'x'
  from   AMS_IMP_CONFIG_COMPONENTS
  where  CONFIG_COMPONENT_ID = X_CONFIG_COMPONENT_ID;

  cursor c_get_con_com_id is
  select AMS_IMP_CONFIG_COMPONENTS_S.nextval
  from dual;

begin

        if X_OWNER = 'SEED' then
                l_user_id := 1;
        end if;
	open c_chk_col_exists;
        fetch c_chk_col_exists into l_dummy_char;

        if c_chk_col_exists%notfound
        then
                close c_chk_col_exists;
                if X_CONFIG_COMPONENT_ID is null
                then
                        open c_get_con_com_id;
                        fetch c_get_con_com_id into l_concom_id;
                        close c_get_con_com_id;
                else
                        l_concom_id := X_CONFIG_COMPONENT_ID;
                end if;
                 AMS_IMP_CONFIG_COMPONENTS_PKG.INSERT_ROW (
                        X_ROWID            => l_row_id,
                        X_CONFIG_COMPONENT_ID => X_CONFIG_COMPONENT_ID,
                        X_IMPORT_TYPE      => X_IMPORT_TYPE,
                        X_COMPONENT_TYPE   => X_COMPONENT_TYPE,
                        X_IMPORT_MODULE    => X_IMPORT_MODULE,
                        X_COMPONENT_NAME   => X_COMPONENT_NAME,
                        X_ACCESS_ALLOWED   => X_ACCESS_ALLOWED,
                        X_OBJECT_VERSION_NUMBER => l_obj_verno,
                        X_CREATION_DATE    => X_CREATION_DATE, -- sysdate,
                        X_CREATED_BY       => l_user_id,
                        X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE, -- sysdate,
                        X_LAST_UPDATED_BY  => l_user_id,
                        X_LAST_UPDATE_LOGIN => 0);

              else
                       close c_chk_col_exists;
                       l_concom_id := X_CONFIG_COMPONENT_ID;
                 AMS_IMP_CONFIG_COMPONENTS_PKG.UPDATE_ROW (
                        X_CONFIG_COMPONENT_ID => X_CONFIG_COMPONENT_ID,
                        X_IMPORT_TYPE      => X_IMPORT_TYPE,
                        X_COMPONENT_TYPE   => X_COMPONENT_TYPE,
                        X_IMPORT_MODULE    => X_IMPORT_MODULE,
                        X_COMPONENT_NAME   => X_COMPONENT_NAME,
                        X_ACCESS_ALLOWED   => X_ACCESS_ALLOWED,
                        X_OBJECT_VERSION_NUMBER => l_obj_verno,
                        X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE, -- sysdate,
                        X_LAST_UPDATED_BY  => l_user_id,
                        X_LAST_UPDATE_LOGIN => 1);
               end if;
end  LOAD_ROW;
end AMS_IMP_CONFIG_COMPONENTS_PKG;

/
