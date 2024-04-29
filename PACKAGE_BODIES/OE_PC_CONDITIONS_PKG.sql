--------------------------------------------------------
--  DDL for Package Body OE_PC_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_CONDITIONS_PKG" as
/* $Header: OEXPCCDB.pls 120.1 2005/07/15 01:32:02 ppnair noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CONDITION_ID in NUMBER,
  X_CONSTRAINT_ID in NUMBER,
  X_GROUP_NUMBER in NUMBER,
  X_SYSTEM_FLAG in VARCHAR2,
  X_MODIFIER_FLAG in VARCHAR2,
  X_VALIDATION_ENTITY_ID in NUMBER,
  X_VALIDATION_TMPLT_ID in NUMBER,
  X_RECORD_SET_ID in NUMBER,
  X_SCOPE_OP in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2 DEFAULT NULL,
  X_USER_MESSAGE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from OE_PC_CONDITIONS
    where CONDITION_ID = X_CONDITION_ID
    ;
begin

  insert into OE_PC_CONDITIONS (
    CONDITION_ID,
    CONSTRAINT_ID,
    GROUP_NUMBER,
    SYSTEM_FLAG,
    MODIFIER_FLAG,
    VALIDATION_ENTITY_ID,
    VALIDATION_TMPLT_ID,
    RECORD_SET_ID,
    SCOPE_OP,
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
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CONDITION_ID,
    X_CONSTRAINT_ID,
    X_GROUP_NUMBER,
    X_SYSTEM_FLAG,
    X_MODIFIER_FLAG,
    X_VALIDATION_ENTITY_ID,
    X_VALIDATION_TMPLT_ID,
    X_RECORD_SET_ID,
    X_SCOPE_OP,
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
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into OE_PC_CONDITIONS_TL (
    CONDITION_ID,
    USER_MESSAGE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CONDITION_ID,
    X_USER_MESSAGE,
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
    from OE_PC_CONDITIONS_TL T
    where T.CONDITION_ID = X_CONDITION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    fnd_message.set_name('ONT', 'INSERT_NO_DATA_FOUND');
    app_exception.raise_exception;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CONDITION_ID in NUMBER,
  X_CONSTRAINT_ID in NUMBER,
  X_GROUP_NUMBER in NUMBER,
  X_SYSTEM_FLAG in VARCHAR2,
  X_MODIFIER_FLAG in VARCHAR2,
  X_VALIDATION_ENTITY_ID in NUMBER,
  X_VALIDATION_TMPLT_ID in NUMBER,
  X_RECORD_SET_ID in NUMBER,
  X_SCOPE_OP in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2 DEFAULT NULL,
  X_USER_MESSAGE in VARCHAR2
) is
  cursor c is select
      CONSTRAINT_ID,
      GROUP_NUMBER,
      SYSTEM_FLAG,
      MODIFIER_FLAG,
      VALIDATION_ENTITY_ID,
      VALIDATION_TMPLT_ID,
      RECORD_SET_ID,
      SCOPE_OP,
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
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      ENABLED_FLAG
    from OE_PC_CONDITIONS
    where CONDITION_ID = X_CONDITION_ID
    for update of CONDITION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_MESSAGE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OE_PC_CONDITIONS_TL
    where CONDITION_ID = X_CONDITION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CONDITION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CONSTRAINT_ID = X_CONSTRAINT_ID)
      AND (recinfo.GROUP_NUMBER = X_GROUP_NUMBER)
      AND (recinfo.SYSTEM_FLAG = X_SYSTEM_FLAG)
      AND (recinfo.MODIFIER_FLAG = X_MODIFIER_FLAG)
      AND (recinfo.VALIDATION_ENTITY_ID = X_VALIDATION_ENTITY_ID)
      AND (recinfo.VALIDATION_TMPLT_ID = X_VALIDATION_TMPLT_ID)
      AND (recinfo.RECORD_SET_ID = X_RECORD_SET_ID)
      AND (recinfo.SCOPE_OP = X_SCOPE_OP)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_MESSAGE = X_USER_MESSAGE)
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
  X_CONDITION_ID in NUMBER,
  X_CONSTRAINT_ID in NUMBER,
  X_GROUP_NUMBER in NUMBER,
  X_SYSTEM_FLAG in VARCHAR2,
  X_MODIFIER_FLAG in VARCHAR2,
  X_VALIDATION_ENTITY_ID in NUMBER,
  X_VALIDATION_TMPLT_ID in NUMBER,
  X_RECORD_SET_ID in NUMBER,
  X_SCOPE_OP in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2 DEFAULT NULL,
  X_USER_MESSAGE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin

  update OE_PC_CONDITIONS set
    CONSTRAINT_ID = X_CONSTRAINT_ID,
    GROUP_NUMBER = X_GROUP_NUMBER,
    SYSTEM_FLAG = X_SYSTEM_FLAG,
    MODIFIER_FLAG = X_MODIFIER_FLAG,
    VALIDATION_ENTITY_ID = X_VALIDATION_ENTITY_ID,
    VALIDATION_TMPLT_ID = X_VALIDATION_TMPLT_ID,
    RECORD_SET_ID = X_RECORD_SET_ID,
    SCOPE_OP = X_SCOPE_OP,
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
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ENABLED_FLAG = NVL(X_ENABLED_FLAG, ENABLED_FLAG),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CONDITION_ID = X_CONDITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OE_PC_CONDITIONS_TL set
    USER_MESSAGE = X_USER_MESSAGE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CONDITION_ID = X_CONDITION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
  X_CONDITION_ID in NUMBER
) is
begin

  delete from OE_PC_CONDITIONS_TL
  where CONDITION_ID = X_CONDITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from OE_PC_CONDITIONS
  where CONDITION_ID = X_CONDITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OE_PC_CONDITIONS_TL T
  where not exists
    (select NULL
    from OE_PC_CONDITIONS B
    where B.CONDITION_ID = T.CONDITION_ID
    );

  update OE_PC_CONDITIONS_TL T set (
      USER_MESSAGE
    ) = (select
      B.USER_MESSAGE
    from OE_PC_CONDITIONS_TL B
    where B.CONDITION_ID = T.CONDITION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CONDITION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CONDITION_ID,
      SUBT.LANGUAGE
    from OE_PC_CONDITIONS_TL SUBB, OE_PC_CONDITIONS_TL SUBT
    where SUBB.CONDITION_ID = SUBT.CONDITION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_MESSAGE <> SUBT.USER_MESSAGE
  ));

  insert into OE_PC_CONDITIONS_TL (
    CONDITION_ID,
    USER_MESSAGE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CONDITION_ID,
    B.USER_MESSAGE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OE_PC_CONDITIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OE_PC_CONDITIONS_TL T
    where T.CONDITION_ID = B.CONDITION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_CONDITION_ID in VARCHAR2,
  x_owner		  in VARCHAR2,
  x_user_message in	VARCHAR2
)
is
  l_user_id number:=0;
begin
  l_user_id :=fnd_load_util.owner_id(x_owner); --seed data versioning changes
  update OE_PC_CONDITIONS_TL set
    USER_MESSAGE = X_USER_MESSAGE,
    LAST_UPDATE_DATE = sysdate,
    --LAST_UPDATED_BY = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATED_BY =l_user_id ,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where CONDITION_ID = X_CONDITION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end Translate_Row;


procedure LOAD_ROW (
  X_CONDITION_ID in VARCHAR2,
  x_owner		  in VARCHAR2,
  x_user_message in	VARCHAR2,
  X_CONSTRAINT_ID in VARCHAR2,
  X_GROUP_NUMBER in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_MODIFIER_FLAG in VARCHAR2,
  X_VALIDATION_ENTITY_ID in VARCHAR2,
  X_VALIDATION_TMPLT_ID in VARCHAR2,
  X_RECORD_SET_ID in VARCHAR2,
  X_SCOPE_OP in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_START_DATE_ACTIVE in VARCHAR2,
  X_END_DATE_ACTIVE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2 DEFAULT NULL
) is
CURSOR CID IS SELECT oe_pc_conditions_s.nextval from dual;
begin

    declare
	user_id	number := 0;
	row_id	varchar2(64);
        l_db_user_id	number := 0;
	l_valid_release boolean :=false;
    begin

     if (X_OWNER = 'SEED') then
		  user_id := 1;
     end if;
    --seed data version changes start
    user_id :=fnd_load_util.owner_id(x_owner);
    begin
      select last_updated_by
        into l_db_user_id
	from OE_PC_CONDITIONS
	where CONDITION_ID = X_CONDITION_ID;
      exception
         when no_data_found then null;
    end;
     if (l_db_user_id <= user_id)
           or (l_db_user_id in (0,1,2)
              and user_id in (0,1,2))       then
	  l_valid_release :=true ;
    end if;
    if l_valid_release then
    --seed data version changes end
    OE_PC_CONDITIONS_pkg.UPDATE_ROW(
      x_condition_id 		 => x_condition_id
	 ,x_group_number		 => x_group_number
      ,x_constraint_id		 => x_constraint_id
      ,x_system_flag	      => x_system_flag
	 ,x_modifier_flag		 => x_modifier_flag
      ,x_validation_entity_id		 => x_validation_entity_id
	 ,x_validation_tmplt_id		 => x_validation_tmplt_id
      ,x_record_set_id		 => x_record_set_id
      ,x_scope_op	      	 => x_scope_op
	 ,x_start_date_active	 => to_date(x_start_date_active,'YYYY/MM/DD')
	 ,x_end_date_active		 => to_date(x_end_date_active,'YYYY/MM/DD')
         ,x_enabled_flag                 => NULL
	 ,x_user_message		 => x_user_message
      ,x_last_updated_by 	 => user_id
      ,x_last_update_date      => sysdate
      ,x_last_update_login     => 0
      ,x_attribute_category    => x_attribute_category
      ,x_attribute1	           => x_attribute1
      ,x_attribute2	           => x_attribute2
      ,x_attribute3	           => x_attribute3
      ,x_attribute4	           => x_attribute4
      ,x_attribute5	           => x_attribute5
      ,x_attribute6	           => x_attribute6
      ,x_attribute7	           => x_attribute7
      ,x_attribute8	           => x_attribute8
      ,x_attribute9	           => x_attribute9
      ,x_attribute10	           => x_attribute10
      ,x_attribute11	           => x_attribute11
      ,x_attribute12	           => x_attribute12
      ,x_attribute13	           => x_attribute13
      ,x_attribute14	           => x_attribute14
      ,x_attribute15	           => x_attribute15
	 );
    end if;
    exception
	when NO_DATA_FOUND then

	 OE_PC_CONDITIONS_pkg.INSERT_ROW(
	 x_rowid				 => row_id
      ,x_condition_id 		 => x_condition_id
	 ,x_group_number		 => x_group_number
      ,x_constraint_id		 => x_constraint_id
      ,x_system_flag	      => x_system_flag
	 ,x_modifier_flag		 => x_modifier_flag
      ,x_validation_entity_id		 => x_validation_entity_id
	 ,x_validation_tmplt_id		 => x_validation_tmplt_id
      ,x_record_set_id		 => x_record_set_id
      ,x_scope_op	      	 => x_scope_op
	 ,x_start_date_active	 => to_date(x_start_date_active,'YYYY/MM/DD')
	 ,x_end_date_active		 => to_date(x_end_date_active,'YYYY/MM/DD')
	 ,x_user_message		 => x_user_message
      ,x_created_by            => user_id
      ,x_creation_date         => sysdate
      ,x_last_updated_by 	 => user_id
      ,x_last_update_date      => sysdate
      ,x_last_update_login     => 0
      ,x_attribute_category    => x_attribute_category
      ,x_attribute1	           => x_attribute1
      ,x_attribute2	           => x_attribute2
      ,x_attribute3	           => x_attribute3
      ,x_attribute4	           => x_attribute4
      ,x_attribute5	           => x_attribute5
      ,x_attribute6	           => x_attribute6
      ,x_attribute7	           => x_attribute7
      ,x_attribute8	           => x_attribute8
      ,x_attribute9	           => x_attribute9
      ,x_attribute10	           => x_attribute10
      ,x_attribute11	           => x_attribute11
      ,x_attribute12	           => x_attribute12
      ,x_attribute13	           => x_attribute13
      ,x_attribute14	           => x_attribute14
      ,x_attribute15	           => x_attribute15
      ,x_enabled_flag              => x_enabled_flag
	 );
  end;

end Load_Row;

end OE_PC_CONDITIONS_PKG;

/
