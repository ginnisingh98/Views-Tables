--------------------------------------------------------
--  DDL for Package Body AMS_EXP_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EXP_TEMPLATE_PKG" as
/* $Header: amsextmb.pls 115.3 2002/11/14 21:55:44 jieli noship $ */
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_EXP_TEMPLATE_ID in NUMBER,
  X_SET_CLAUSE in VARCHAR2,
  X_EXPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_SEEDED_SELECT_CLAUSE in LONG,
  X_FROM_CLAUSE in VARCHAR2,
  X_JOIN_CONDITION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_EXP_TEMPLATE (
    SET_CLAUSE,
    EXPORT_TYPE,
    EXP_TEMPLATE_ID,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    TEMPLATE_NAME,
    SEEDED_SELECT_CLAUSE,
    FROM_CLAUSE,
    JOIN_CONDITION
  ) values
    (
    X_SET_CLAUSE,
    X_EXPORT_TYPE,
    X_EXP_TEMPLATE_ID,
    X_LAST_UPDATED_BY,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_TEMPLATE_NAME,
    X_SEEDED_SELECT_CLAUSE,
    X_FROM_CLAUSE,
    X_JOIN_CONDITION);

end INSERT_ROW;

procedure LOCK_ROW (
  X_EXP_TEMPLATE_ID in NUMBER,
  X_SET_CLAUSE in VARCHAR2,
  X_EXPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_SEEDED_SELECT_CLAUSE in LONG,
  X_FROM_CLAUSE in VARCHAR2,
  X_JOIN_CONDITION in VARCHAR2
) is
  cursor c1 is select
      SET_CLAUSE,
      EXPORT_TYPE,
      OBJECT_VERSION_NUMBER,
      TEMPLATE_NAME,
      SEEDED_SELECT_CLAUSE,
      FROM_CLAUSE,
      JOIN_CONDITION,
      EXP_TEMPLATE_ID
    from AMS_EXP_TEMPLATE
    where EXP_TEMPLATE_ID = X_EXP_TEMPLATE_ID
    for update of EXP_TEMPLATE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.EXP_TEMPLATE_ID = X_EXP_TEMPLATE_ID)
          AND (tlinfo.SET_CLAUSE = X_SET_CLAUSE)
          AND (tlinfo.EXPORT_TYPE = X_EXPORT_TYPE)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND (tlinfo.TEMPLATE_NAME = X_TEMPLATE_NAME)
          AND (tlinfo.SEEDED_SELECT_CLAUSE = X_SEEDED_SELECT_CLAUSE)
          AND (tlinfo.FROM_CLAUSE = X_FROM_CLAUSE)
          AND (tlinfo.JOIN_CONDITION = X_JOIN_CONDITION)
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
  X_EXP_TEMPLATE_ID in NUMBER,
  X_SET_CLAUSE in VARCHAR2,
  X_EXPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_SEEDED_SELECT_CLAUSE in LONG,
  X_FROM_CLAUSE in VARCHAR2,
  X_JOIN_CONDITION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_EXP_TEMPLATE set
    SET_CLAUSE = X_SET_CLAUSE,
    EXPORT_TYPE = X_EXPORT_TYPE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TEMPLATE_NAME = X_TEMPLATE_NAME,
    SEEDED_SELECT_CLAUSE = X_SEEDED_SELECT_CLAUSE,
    FROM_CLAUSE = X_FROM_CLAUSE,
    JOIN_CONDITION = X_JOIN_CONDITION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where EXP_TEMPLATE_ID = X_EXP_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_EXP_TEMPLATE_ID in NUMBER
) is
begin
  delete from AMS_EXP_TEMPLATE
  where EXP_TEMPLATE_ID = X_EXP_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_EXP_TEMPLATE_ID in NUMBER,
  X_SET_CLAUSE in VARCHAR2,
  X_EXPORT_TYPE in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_SEEDED_SELECT_CLAUSE in LONG,
  X_FROM_CLAUSE in VARCHAR2,
  X_JOIN_CONDITION in VARCHAR2,
  X_OWNER in VARCHAR2
) is

l_user_id number := 0;
l_concom_id  number;
l_obj_verno number := 1;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

 cursor c_chk_col_exists is
  select 'x'
  from  AMS_EXP_TEMPLATE
  where  EXP_TEMPLATE_ID = X_EXP_TEMPLATE_ID;

  cursor c_get_con_com_id is
  select AMS_EXP_TEMPLATE_S.nextval
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
                if X_EXP_TEMPLATE_ID is null
                then
                        open c_get_con_com_id;
                        fetch c_get_con_com_id into l_concom_id;
                        close c_get_con_com_id;
                else
                        l_concom_id := X_EXP_TEMPLATE_ID;
                end if;
 		AMS_EXP_TEMPLATE_PKG.INSERT_ROW (
  			X_ROWID => l_row_id,
  			X_EXP_TEMPLATE_ID 	=> X_EXP_TEMPLATE_ID,
  			X_SET_CLAUSE 		=> X_SET_CLAUSE,
  			X_EXPORT_TYPE 		=> X_EXPORT_TYPE,
  			X_OBJECT_VERSION_NUMBER => l_obj_verno,
  			X_TEMPLATE_NAME 	=> X_TEMPLATE_NAME,
  			X_SEEDED_SELECT_CLAUSE  => X_SEEDED_SELECT_CLAUSE,
  			X_FROM_CLAUSE 		=> X_FROM_CLAUSE,
  			X_JOIN_CONDITION 	=> X_JOIN_CONDITION,
  			X_CREATION_DATE 	=> sysdate,
  			X_CREATED_BY  		=> l_user_id,
  			X_LAST_UPDATE_DATE 	=> sysdate,
  			X_LAST_UPDATED_BY 	=> l_user_id,
  			X_LAST_UPDATE_LOGIN 	=> 0);
              else
                       close c_chk_col_exists;
                       l_concom_id := X_EXP_TEMPLATE_ID;

               AMS_EXP_TEMPLATE_PKG.UPDATE_ROW(
                        X_EXP_TEMPLATE_ID       => X_EXP_TEMPLATE_ID,
                        X_SET_CLAUSE            => X_SET_CLAUSE,
                        X_EXPORT_TYPE           => X_EXPORT_TYPE,
                        X_OBJECT_VERSION_NUMBER => l_obj_verno,
                        X_TEMPLATE_NAME         => X_TEMPLATE_NAME,
                        X_SEEDED_SELECT_CLAUSE  => X_SEEDED_SELECT_CLAUSE,
                        X_FROM_CLAUSE           => X_FROM_CLAUSE,
                        X_JOIN_CONDITION        => X_JOIN_CONDITION,
                        X_LAST_UPDATE_DATE      => sysdate,
                        X_LAST_UPDATED_BY       => l_user_id,
                        X_LAST_UPDATE_LOGIN     => 0);
               end if;
end LOAD_ROW;

end AMS_EXP_TEMPLATE_PKG;

/
