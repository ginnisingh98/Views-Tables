--------------------------------------------------------
--  DDL for Package Body AMS_IMP_COL_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_COL_MAPPING_PKG" as
/* $Header: amslccmb.pls 115.7 2004/04/07 21:22:10 usingh ship $ */
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_COL_MAPPING_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_TARGET_TABLE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_IMP_COL_MAPPING (
    TABLE_NAME,
    COLUMN_NAME,
    MEANING,
    REQUIRED_FLAG,
    TARGET_TABLE_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    COL_MAPPING_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  )
   values
  (
    X_TABLE_NAME,
    X_COLUMN_NAME,
    X_MEANING,
    X_REQUIRED_FLAG,
    X_TARGET_TABLE_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_COL_MAPPING_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_COL_MAPPING_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_TARGET_TABLE_NAME in VARCHAR2
) is
  cursor c1 is select
      TABLE_NAME,
      COLUMN_NAME,
      MEANING,
      REQUIRED_FLAG,
      TARGET_TABLE_NAME,
      COL_MAPPING_ID
    from AMS_IMP_COL_MAPPING
    where COL_MAPPING_ID = X_COL_MAPPING_ID
    for update of COL_MAPPING_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.COL_MAPPING_ID = X_COL_MAPPING_ID)
          AND (tlinfo.TABLE_NAME = X_TABLE_NAME)
          AND (tlinfo.COLUMN_NAME = X_COLUMN_NAME)
          AND (tlinfo.MEANING = X_MEANING)
          AND ((tlinfo.REQUIRED_FLAG = X_REQUIRED_FLAG)
               OR ((tlinfo.REQUIRED_FLAG is null) AND (X_REQUIRED_FLAG is null)))
          AND (tlinfo.TARGET_TABLE_NAME = X_TARGET_TABLE_NAME)
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
  X_COL_MAPPING_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_TARGET_TABLE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_IMP_COL_MAPPING set
    TABLE_NAME = X_TABLE_NAME,
    COLUMN_NAME = X_COLUMN_NAME,
    MEANING = X_MEANING,
    REQUIRED_FLAG = X_REQUIRED_FLAG,
    TARGET_TABLE_NAME = X_TARGET_TABLE_NAME,
    COL_MAPPING_ID = X_COL_MAPPING_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COL_MAPPING_ID = X_COL_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COL_MAPPING_ID in NUMBER
) is
begin
  delete from AMS_IMP_COL_MAPPING
  where COL_MAPPING_ID = X_COL_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_COL_MAPPING_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_TARGET_TABLE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
  ) IS

l_user_id number := 0;
l_colmap_id  number;
l_obj_verno number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

 cursor c_chk_col_exists is
  select 'x'
  from   AMS_IMP_COL_MAPPING
  where  COL_MAPPING_ID = X_COL_MAPPING_ID;

  cursor c_get_col_mapping_id is
  select AMS_IMP_COL_MAPPING_s.nextval
  from dual;

BEGIN
        if X_OWNER = 'SEED' then
                l_user_id := 1;
        end if;
   open c_chk_col_exists;
        fetch c_chk_col_exists into l_dummy_char;
        if c_chk_col_exists%notfound
        then
                close c_chk_col_exists;
                if X_COL_MAPPING_ID is null
                then
                        open c_get_col_mapping_id;
                        fetch c_get_col_mapping_id into l_colmap_id;
                        close c_get_col_mapping_id;
                else
                        l_colmap_id := X_COL_MAPPING_ID;
                end if;
                 AMS_IMP_COL_MAPPING_PKG.INSERT_ROW (
  			X_ROWID            => l_row_id,
  			X_COL_MAPPING_ID   => X_COL_MAPPING_ID,
  			X_TABLE_NAME       => X_TABLE_NAME,
  			X_COLUMN_NAME      => X_COLUMN_NAME,
  			X_MEANING          => X_MEANING,
  			X_REQUIRED_FLAG    => X_REQUIRED_FLAG,
  			X_TARGET_TABLE_NAME  => X_TARGET_TABLE_NAME,
  			X_CREATION_DATE    => X_CREATION_DATE , -- sysdate,
  			X_CREATED_BY       => l_user_id,
  			X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE, -- sysdate,
  			X_LAST_UPDATED_BY  => l_user_id,
  			X_LAST_UPDATE_LOGIN => 1);

              else
                       close c_chk_col_exists;
                       l_colmap_id := X_COL_MAPPING_ID ;

                        AMS_IMP_COL_MAPPING_PKG.UPDATE_ROW (
  			X_COL_MAPPING_ID     => X_COL_MAPPING_ID,
  			X_TABLE_NAME         => X_TABLE_NAME,
  			X_COLUMN_NAME        => X_COLUMN_NAME,
  			X_MEANING            => X_MEANING ,
  			X_REQUIRED_FLAG      => X_REQUIRED_FLAG,
  			X_TARGET_TABLE_NAME  => X_TARGET_TABLE_NAME,
  			X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE, -- sysdate,
  			X_LAST_UPDATED_BY    => l_user_id,
  			X_LAST_UPDATE_LOGIN  => 1
			);
               end if;

end LOAD_ROW;

end AMS_IMP_COL_MAPPING_PKG;

/
