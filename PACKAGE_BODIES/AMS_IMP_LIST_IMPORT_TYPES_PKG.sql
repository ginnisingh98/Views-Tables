--------------------------------------------------------
--  DDL for Package Body AMS_IMP_LIST_IMPORT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_LIST_IMPORT_TYPES_PKG" as
/* $Header: amsilmtb.pls 115.6 2004/04/07 21:52:13 usingh ship $ */
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_IMPORT_TYPE_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_VIEW_NAME in VARCHAR2,
  X_B2B_FLAG in VARCHAR2,
  X_CONCURRENT_PROGRAM in VARCHAR2,
  X_WORKBOOK_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_IMP_LIST_IMPORT_TYPES (
    IMPORT_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    IMPORT_TYPE,
    VIEW_NAME,
    B2B_FLAG,
    CONCURRENT_PROGRAM,
    WORKBOOK_NAME
  )
    values
  (
    X_IMPORT_TYPE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_IMPORT_TYPE,
    X_VIEW_NAME,
    X_B2B_FLAG,
    X_CONCURRENT_PROGRAM,
    X_WORKBOOK_NAME
   );

end INSERT_ROW;

procedure LOCK_ROW (
  X_IMPORT_TYPE_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_VIEW_NAME in VARCHAR2,
  X_B2B_FLAG in VARCHAR2,
  X_CONCURRENT_PROGRAM in VARCHAR2,
  X_WORKBOOK_NAME in VARCHAR2
) is
  cursor c1 is select
      import_type_id,
      IMPORT_TYPE,
      VIEW_NAME,
      B2B_FLAG,
      CONCURRENT_PROGRAM,
      WORKBOOK_NAME
    from AMS_IMP_LIST_IMPORT_TYPES
    where IMPORT_TYPE_ID = X_IMPORT_TYPE_ID
    for update of IMPORT_TYPE_ID nowait;

begin
  for tlinfo in c1 loop
      if (    ((tlinfo.IMPORT_TYPE_ID = X_IMPORT_TYPE_ID)
               OR ((tlinfo.IMPORT_TYPE_ID is null) AND (X_IMPORT_TYPE_ID is null)))
          AND (tlinfo.IMPORT_TYPE = X_IMPORT_TYPE)
          AND ((tlinfo.VIEW_NAME = X_VIEW_NAME)
               OR ((tlinfo.VIEW_NAME is null) AND (X_VIEW_NAME is null)))
          AND ((tlinfo.B2B_FLAG = X_B2B_FLAG)
               OR ((tlinfo.B2B_FLAG is null) AND (X_B2B_FLAG is null)))
          AND ((tlinfo.CONCURRENT_PROGRAM = X_CONCURRENT_PROGRAM)
               OR ((tlinfo.CONCURRENT_PROGRAM is null) AND (X_CONCURRENT_PROGRAM is null)))
          AND ((tlinfo.WORKBOOK_NAME = X_WORKBOOK_NAME)
               OR ((tlinfo.WORKBOOK_NAME is null) AND (X_WORKBOOK_NAME is null)))
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
  X_IMPORT_TYPE_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_VIEW_NAME in VARCHAR2,
  X_B2B_FLAG in VARCHAR2,
  X_CONCURRENT_PROGRAM in VARCHAR2,
  X_WORKBOOK_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_IMP_LIST_IMPORT_TYPES set
    IMPORT_TYPE = X_IMPORT_TYPE,
    VIEW_NAME = X_VIEW_NAME,
    B2B_FLAG = X_B2B_FLAG,
    CONCURRENT_PROGRAM = X_CONCURRENT_PROGRAM,
    WORKBOOK_NAME = X_WORKBOOK_NAME,
    IMPORT_TYPE_ID = X_IMPORT_TYPE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where IMPORT_TYPE_ID = X_IMPORT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_IMPORT_TYPE_ID in NUMBER
) is
begin
  delete from AMS_IMP_LIST_IMPORT_TYPES
  where IMPORT_TYPE_ID = X_IMPORT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_IMPORT_TYPE_ID in NUMBER,
  X_IMPORT_TYPE in VARCHAR2,
  X_VIEW_NAME in VARCHAR2,
  X_B2B_FLAG in VARCHAR2,
  X_CONCURRENT_PROGRAM in VARCHAR2,
  X_WORKBOOK_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
 )is
l_user_id number := 0;
l_imptype_id  number;
l_obj_verno number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

 cursor c_chk_col_exists is
  select 'x'
  from   ams_imp_list_import_types
  where  IMPORT_TYPE_ID = X_IMPORT_TYPE_ID;

  cursor c_get_import_type_id is
  select ams_imp_list_import_types_s.nextval
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
                if X_IMPORT_TYPE_ID is null
                then
                        open c_get_import_type_id;
                        fetch c_get_import_type_id into l_imptype_id;
                        close c_get_import_type_id;
                else
                        l_imptype_id := X_IMPORT_TYPE_ID;
                end if;
                 AMS_IMP_LIST_IMPORT_TYPES_PKG.INSERT_ROW (
			  X_ROWID => l_row_id,
  			  X_IMPORT_TYPE_ID => X_IMPORT_TYPE_ID,
  			  X_IMPORT_TYPE => X_IMPORT_TYPE,
  			  X_VIEW_NAME => X_VIEW_NAME,
  			  X_B2B_FLAG => X_B2B_FLAG,
  			  X_CONCURRENT_PROGRAM => X_CONCURRENT_PROGRAM,
  			  X_WORKBOOK_NAME => X_WORKBOOK_NAME,
  			  X_CREATION_DATE => X_CREATION_DATE, -- sysdate,
  			  X_CREATED_BY  => l_user_id ,
  			  X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE, -- sysdate,
  			  X_LAST_UPDATED_BY => l_user_id,
   			  X_LAST_UPDATE_LOGIN => 1);

		   else
                       close c_chk_col_exists;
                       l_imptype_id := X_IMPORT_TYPE_ID;
                       AMS_IMP_LIST_IMPORT_TYPES_PKG.UPDATE_ROW (
                          X_IMPORT_TYPE_ID => X_IMPORT_TYPE_ID,
                          X_IMPORT_TYPE => X_IMPORT_TYPE,
                          X_VIEW_NAME => X_VIEW_NAME,
                          X_B2B_FLAG => X_B2B_FLAG,
                          X_CONCURRENT_PROGRAM => X_CONCURRENT_PROGRAM,
                          X_WORKBOOK_NAME => X_WORKBOOK_NAME,
                          X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE, -- sysdate,
                          X_LAST_UPDATED_BY => l_user_id,
                          X_LAST_UPDATE_LOGIN => 1);
                end if;

end LOAD_ROW;

end AMS_IMP_LIST_IMPORT_TYPES_PKG;


/