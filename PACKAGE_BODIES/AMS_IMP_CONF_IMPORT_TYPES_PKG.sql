--------------------------------------------------------
--  DDL for Package Body AMS_IMP_CONF_IMPORT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_CONF_IMPORT_TYPES_PKG" as
/* $Header: amsvcitb.pls 115.4 2004/04/08 16:27:49 usingh ship $ */
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_IMP_CONFIG_IMPORT_TYPES (
    IMP_CONFIG_IMPORT_TYPE_ID,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    APPLICATION_ID,
    IMPORT_TYPE,
    ACCESS_ALLOWED
  )
  VALUES
  (
    X_IMP_CONFIG_IMPORT_TYPE_ID,
    X_LAST_UPDATED_BY,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_APPLICATION_ID,
    X_IMPORT_TYPE,
    X_ACCESS_ALLOWED
    );
end INSERT_ROW;

procedure LOCK_ROW (
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      APPLICATION_ID,
      IMPORT_TYPE,
      ACCESS_ALLOWED,
      IMP_CONFIG_IMPORT_TYPE_ID
    from AMS_IMP_CONFIG_IMPORT_TYPES
    where IMP_CONFIG_IMPORT_TYPE_ID = X_IMP_CONFIG_IMPORT_TYPE_ID
    for update of IMP_CONFIG_IMPORT_TYPE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.IMP_CONFIG_IMPORT_TYPE_ID = X_IMP_CONFIG_IMPORT_TYPE_ID)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND (tlinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (tlinfo.IMPORT_TYPE = X_IMPORT_TYPE)
          AND (tlinfo.ACCESS_ALLOWED = X_ACCESS_ALLOWED)
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
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_ACCESS_ALLOWED in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_IMP_CONFIG_IMPORT_TYPES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    APPLICATION_ID = X_APPLICATION_ID,
    IMPORT_TYPE = X_IMPORT_TYPE,
    ACCESS_ALLOWED = X_ACCESS_ALLOWED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where IMP_CONFIG_IMPORT_TYPE_ID = X_IMP_CONFIG_IMPORT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER
) is
begin
  delete from AMS_IMP_CONFIG_IMPORT_TYPES
  where IMP_CONFIG_IMPORT_TYPE_ID = X_IMP_CONFIG_IMPORT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_IMP_CONFIG_IMPORT_TYPE_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
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
  from   AMS_IMP_CONFIG_IMPORT_TYPES
  where IMP_CONFIG_IMPORT_TYPE_ID = X_IMP_CONFIG_IMPORT_TYPE_ID;

  cursor c_get_con_com_id is
  select AMS_IMP_CONFIG_IMPORT_TYPES_S.nextval
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
                if X_IMP_CONFIG_IMPORT_TYPE_ID is null
                then
                        open c_get_con_com_id;
                        fetch c_get_con_com_id into l_concom_id;
                        close c_get_con_com_id;
                else
                        l_concom_id := X_IMP_CONFIG_IMPORT_TYPE_ID;
                end if;
                 AMS_IMP_CONF_IMPORT_TYPES_PKG.INSERT_ROW (
                        X_ROWID            => l_row_id,
                        X_IMP_CONFIG_IMPORT_TYPE_ID => X_IMP_CONFIG_IMPORT_TYPE_ID,
                        X_OBJECT_VERSION_NUMBER => l_obj_verno,
                        X_APPLICATION_ID      => X_APPLICATION_ID,
                        X_IMPORT_TYPE      => X_IMPORT_TYPE,
                        X_ACCESS_ALLOWED   => X_ACCESS_ALLOWED,
                        X_CREATION_DATE    => X_CREATION_DATE, -- sysdate,
                        X_CREATED_BY       => l_user_id,
                        X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE, -- sysdate,
                        X_LAST_UPDATED_BY  => l_user_id,
                        X_LAST_UPDATE_LOGIN => 1);

              else
                       close c_chk_col_exists;
                       l_concom_id := X_IMP_CONFIG_IMPORT_TYPE_ID;
                 AMS_IMP_CONF_IMPORT_TYPES_PKG.UPDATE_ROW (
                        X_IMP_CONFIG_IMPORT_TYPE_ID => X_IMP_CONFIG_IMPORT_TYPE_ID,
                        X_OBJECT_VERSION_NUMBER => l_obj_verno,
                        X_APPLICATION_ID      => X_APPLICATION_ID,
                        X_IMPORT_TYPE      => X_IMPORT_TYPE,
                        X_ACCESS_ALLOWED   => X_ACCESS_ALLOWED,
                        X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE, -- sysdate,
                        X_LAST_UPDATED_BY  => l_user_id,
                        X_LAST_UPDATE_LOGIN => 1);
               end if;
end LOAD_ROW;

end AMS_IMP_CONF_IMPORT_TYPES_PKG;

/
