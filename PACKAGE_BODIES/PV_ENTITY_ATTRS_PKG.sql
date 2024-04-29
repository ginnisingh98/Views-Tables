--------------------------------------------------------
--  DDL for Package Body PV_ENTITY_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTITY_ATTRS_PKG" as
/* $Header: pvxteatb.pls 120.2 2005/08/23 01:43:22 appldev ship $ */
procedure INSERT_ROW(
  px_entity_attr_id		IN OUT NOCOPY NUMBER,
  px_object_version_number	IN OUT NOCOPY NUMBER,
  p_batch_sql_text		IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_display_external_value_flag IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_creation_date		IN DATE,
  p_created_by			IN NUMBER,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER)
  IS

BEGIN
  insert into PV_ENTITY_ATTRS (
    entity_attr_id,
    batch_sql_text,
    refresh_frequency,
    refresh_frequency_uom,
    last_refresh_date,
    display_external_value_flag,
    lov_string,
    enabled_flag,
    display_flag,
    locator_flag,
    entity_type,
    require_validation_flag,
    external_update_text,
    object_version_number,
    attribute_id,
    entity,
    sql_text,
    attr_data_type,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) VALUES (
    DECODE ( px_entity_attr_id,FND_API.g_miss_num,NULL,px_entity_attr_id),
    DECODE ( p_batch_sql_text,FND_API.g_miss_char,NULL,p_batch_sql_text ),
    DECODE ( p_refresh_frequency,FND_API.g_miss_char,NULL,p_refresh_frequency ),
    DECODE ( p_refresh_frequency_uom,FND_API.g_miss_char,NULL,p_refresh_frequency_uom ),
    DECODE ( p_last_refresh_date,FND_API.g_miss_date,NULL,p_last_refresh_date ),
    DECODE ( p_display_external_value_flag,FND_API.g_miss_char,NULL,p_display_external_value_flag ),
    DECODE ( p_lov_string,FND_API.g_miss_char,NULL,p_lov_string ),
    DECODE ( p_enabled_flag,FND_API.g_miss_char,NULL,p_enabled_flag ),
    DECODE ( p_display_flag,FND_API.g_miss_char,NULL,p_display_flag ),
    DECODE ( p_locator_flag,FND_API.g_miss_char,NULL,p_locator_flag ),
    DECODE ( p_entity_type,FND_API.g_miss_char,NULL,p_entity_type ),
    DECODE ( p_require_validation_flag,FND_API.g_miss_char,NULL,p_require_validation_flag ),
    DECODE ( p_external_update_text,FND_API.g_miss_char,NULL,p_external_update_text ),
    DECODE ( px_object_version_number,FND_API.g_miss_num,NULL,px_object_version_number ),
    DECODE ( p_attribute_id,FND_API.g_miss_num,NULL,p_attribute_id ),
    DECODE ( p_entity,FND_API.g_miss_char,NULL,p_entity ),
    DECODE ( p_sql_text,FND_API.g_miss_char,NULL,p_sql_text ),
    DECODE ( p_attr_data_type,FND_API.g_miss_char,NULL,p_attr_data_type ),
    DECODE ( p_creation_date,FND_API.g_miss_date,NULL,p_creation_date ),
    DECODE ( p_created_by,FND_API.g_miss_num,NULL,p_created_by ),
    DECODE ( p_last_update_date,FND_API.g_miss_date,NULL,p_last_update_date ),
    DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by ),
    DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login));



end INSERT_ROW;

procedure LOCK_ROW (
  p_entity_attr_id		IN NUMBER,
  p_batch_sql_text		IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_display_external_value_flag IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_object_version_number	IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2
) IS
  cursor c is select
      BATCH_SQL_TEXT,
      REFRESH_FREQUENCY,
      REFRESH_FREQUENCY_UOM,
      LAST_REFRESH_DATE,
      DISPLAY_EXTERNAL_VALUE_FLAG,
      LOV_STRING,
      ENABLED_FLAG,
      DISPLAY_FLAG,
      LOCATOR_FLAG,
      ENTITY_TYPE,
      REQUIRE_VALIDATION_FLAG,
      EXTERNAL_UPDATE_TEXT,
      OBJECT_VERSION_NUMBER,
      ATTRIBUTE_ID,
      ENTITY,
      SQL_TEXT,
      ATTR_DATA_TYPE
    from PV_ENTITY_ATTRS
    where ENTITY_ATTR_ID = p_ENTITY_ATTR_ID
    for update of ENTITY_ATTR_ID nowait;
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
  if (    ((recinfo.BATCH_SQL_TEXT = p_BATCH_SQL_TEXT)
           OR ((recinfo.BATCH_SQL_TEXT is null) AND (p_BATCH_SQL_TEXT is null)))
      AND ((recinfo.REFRESH_FREQUENCY = p_REFRESH_FREQUENCY)
           OR ((recinfo.REFRESH_FREQUENCY is null) AND (p_REFRESH_FREQUENCY is null)))
      AND ((recinfo.REFRESH_FREQUENCY_UOM = p_REFRESH_FREQUENCY_UOM)
           OR ((recinfo.REFRESH_FREQUENCY_UOM is null) AND (p_REFRESH_FREQUENCY_UOM is null)))
      AND ((recinfo.LAST_REFRESH_DATE = p_LAST_REFRESH_DATE)
           OR ((recinfo.LAST_REFRESH_DATE is null) AND (p_LAST_REFRESH_DATE is null)))
      AND ((recinfo.DISPLAY_EXTERNAL_VALUE_FLAG = p_DISPLAY_EXTERNAL_VALUE_FLAG)
           OR ((recinfo.DISPLAY_EXTERNAL_VALUE_FLAG is null) AND (p_DISPLAY_EXTERNAL_VALUE_FLAG is null)))
      AND ((recinfo.LOV_STRING = p_LOV_STRING)
           OR ((recinfo.LOV_STRING is null) AND (p_LOV_STRING is null)))
      AND (recinfo.ENABLED_FLAG = p_ENABLED_FLAG)
      AND (recinfo.DISPLAY_FLAG = p_DISPLAY_FLAG)
      AND ((recinfo.LOCATOR_FLAG = p_LOCATOR_FLAG)
           OR ((recinfo.LOCATOR_FLAG is null) AND (p_LOCATOR_FLAG is null)))
      AND ((recinfo.ENTITY_TYPE = p_ENTITY_TYPE)
           OR ((recinfo.ENTITY_TYPE is null) AND (p_ENTITY_TYPE is null)))
      AND ((recinfo.REQUIRE_VALIDATION_FLAG = p_REQUIRE_VALIDATION_FLAG)
           OR ((recinfo.REQUIRE_VALIDATION_FLAG is null) AND (p_REQUIRE_VALIDATION_FLAG is null)))
      AND ((recinfo.EXTERNAL_UPDATE_TEXT = p_EXTERNAL_UPDATE_TEXT)
           OR ((recinfo.EXTERNAL_UPDATE_TEXT is null) AND (p_EXTERNAL_UPDATE_TEXT is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
      AND (recinfo.ATTRIBUTE_ID = p_ATTRIBUTE_ID)
      AND (recinfo.ENTITY = p_ENTITY)
      AND ((recinfo.SQL_TEXT = p_SQL_TEXT)
           OR ((recinfo.SQL_TEXT is null) AND (p_SQL_TEXT is null)))
      AND ((recinfo.ATTR_DATA_TYPE = p_ATTR_DATA_TYPE)
           OR ((recinfo.ATTR_DATA_TYPE is null) AND (p_ATTR_DATA_TYPE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  p_entity_attr_id		IN NUMBER,
  p_batch_sql_text		IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_display_external_value_flag IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_object_version_number	IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER
) IS
begin
  update PV_ENTITY_ATTRS set
    batch_sql_text		= DECODE ( p_batch_sql_text,FND_API.g_miss_char,NULL,p_batch_sql_text ),
    refresh_frequency		= DECODE ( p_refresh_frequency,FND_API.g_miss_char,NULL,p_refresh_frequency ),
    refresh_frequency_uom	= DECODE ( p_refresh_frequency_uom,FND_API.g_miss_char,NULL,p_refresh_frequency_uom ),
    last_refresh_date		= DECODE ( p_last_refresh_date,FND_API.g_miss_date,NULL,p_last_refresh_date ),
    display_external_value_flag = DECODE ( p_display_external_value_flag,FND_API.g_miss_char,NULL,p_display_external_value_flag ),
    lov_string			= DECODE ( p_lov_string,FND_API.g_miss_char,NULL,p_lov_string ),
    enabled_flag		= DECODE ( p_enabled_flag,FND_API.g_miss_char,NULL,p_enabled_flag ),
    display_flag		= DECODE ( p_display_flag,FND_API.g_miss_char,NULL,p_display_flag ),
    locator_flag		= DECODE ( p_locator_flag,FND_API.g_miss_char,NULL,p_locator_flag ),
    entity_type			= DECODE ( p_entity_type,FND_API.g_miss_char,NULL,p_entity_type ),
    require_validation_flag	= DECODE ( p_require_validation_flag,FND_API.g_miss_char,NULL,p_require_validation_flag ),
    external_update_text	= DECODE ( p_external_update_text,FND_API.g_miss_char,NULL,p_external_update_text ),
    object_version_number	= DECODE ( p_object_version_number,FND_API.g_miss_num,NULL,p_object_version_number+1 ),
    attribute_id		= DECODE ( p_attribute_id,FND_API.g_miss_num,NULL,p_attribute_id ),
    entity			= DECODE ( p_entity,FND_API.g_miss_char,NULL,p_entity ),
    sql_text			= DECODE ( p_sql_text,FND_API.g_miss_char,NULL,p_sql_text ),
    attr_data_type		= DECODE ( p_attr_data_type,FND_API.g_miss_char,NULL,p_attr_data_type ),
    last_update_date		= DECODE ( p_last_update_date,FND_API.g_miss_date,NULL,p_last_update_date ),
    last_updated_by		= DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by ),
    last_update_login		= DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login)
  WHERE entity_attr_id = p_entity_attr_id;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

end UPDATE_ROW;

procedure UPDATE_SEED_ROW (
  p_entity_attr_id		IN NUMBER,
  p_batch_sql_text		IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_display_external_value_flag IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_object_version_number	IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER
)
IS
  cursor  c_updated_by is
  select last_updated_by
  from    pv_entity_attrs
  WHERE entity_attr_id = p_entity_attr_id;

  l_last_updated_by number;

BEGIN
     for x in c_updated_by
     loop
		l_last_updated_by :=  x.last_updated_by;
     end loop;

     -- Checking if some body updated seeded attribute codes other than SEED,
   -- If other users updated it, We will not updated enabled_flag and description.
   -- Else we will update enabled_flag and description

     IF ( l_last_updated_by = 1) THEN
         UPDATE_ROW (
	  p_entity_attr_id		=> p_entity_attr_id,
	  p_batch_sql_text		=> p_batch_sql_text,
	  p_refresh_frequency		=> p_refresh_frequency,
	  p_refresh_frequency_uom	=> p_refresh_frequency_uom,
	  p_last_refresh_date		=> p_last_refresh_date,
	  p_display_external_value_flag => p_display_external_value_flag ,
	  p_lov_string			=> p_lov_string,
	  p_enabled_flag		=> p_enabled_flag,
	  p_display_flag		=> p_display_flag,
	  p_locator_flag		=> p_locator_flag,
	  p_entity_type			=> p_entity_type,
	  p_require_validation_flag	=> p_require_validation_flag,
	  p_external_update_text	=> p_external_update_text,
	  p_object_version_number	=> p_object_version_number,
	  p_attribute_id		=> p_attribute_id,
	  p_entity			=> p_entity,
	  p_sql_text			=> p_sql_text,
	  p_attr_data_type		=> p_attr_data_type,
	  p_last_update_date		=> p_last_update_date,
	  p_last_updated_by		=> p_last_updated_by,
	  p_last_update_login		=> p_last_update_login);
      ELSE
         SEED_UPDATE_ROW (
	  p_entity_attr_id		=> p_entity_attr_id,
	  p_object_version_number	=> p_object_version_number,
	  p_attribute_id		=> p_attribute_id,
	  p_entity			=> p_entity,
	  p_sql_text			=> p_sql_text,
	  p_attr_data_type		=> p_attr_data_type,
	  p_lov_string			=> p_lov_string,
	  p_entity_type			=> p_entity_type,
	  p_enabled_flag		=> p_enabled_flag,
	  p_display_flag		=> p_display_flag,
	  p_external_update_text	=> p_external_update_text,
	  p_batch_sql_text		=> p_batch_sql_text,
	  p_display_external_value_flag => p_display_external_value_flag,
	  p_last_update_date		=> p_last_update_date,
	  p_last_updated_by		=> p_last_updated_by,
	  p_last_update_login		=> p_last_update_login);
      END IF;

END;
procedure SEED_UPDATE_ROW (
  p_entity_attr_id		IN NUMBER,
  p_object_version_number       IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_batch_sql_text		IN VARCHAR2,
  p_display_external_value_flag IN VARCHAR2,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER
)
IS
BEGIN
  update PV_ENTITY_ATTRS set
    attribute_id		= DECODE ( p_attribute_id,FND_API.g_miss_num,NULL,p_attribute_id ),
    entity			= DECODE ( p_entity,FND_API.g_miss_char,NULL,p_entity ),
    sql_text			= DECODE ( p_sql_text,FND_API.g_miss_char,NULL,p_sql_text ),
    attr_data_type		= DECODE ( p_attr_data_type,FND_API.g_miss_char,NULL,p_attr_data_type ),
    lov_string			= DECODE ( p_lov_string,FND_API.g_miss_char,NULL,p_lov_string ),
    entity_type			= DECODE ( p_entity_type,FND_API.g_miss_char,NULL,p_entity_type ),
    enabled_flag		= DECODE ( p_enabled_flag,FND_API.g_miss_char,NULL,p_enabled_flag ),
    display_flag		= DECODE ( p_display_flag,FND_API.g_miss_char,NULL,p_display_flag ),
    external_update_text	= DECODE ( p_external_update_text,FND_API.g_miss_char,NULL,p_external_update_text ),
    batch_sql_text		= DECODE ( p_batch_sql_text,FND_API.g_miss_char,NULL,p_batch_sql_text ),
    display_external_value_flag = DECODE ( p_display_external_value_flag,FND_API.g_miss_char,NULL,p_display_external_value_flag ),
    object_version_number	= DECODE ( p_object_version_number,FND_API.g_miss_num,NULL,p_object_version_number+1 ),
    last_update_date		= DECODE ( p_last_update_date,FND_API.g_miss_date,NULL,p_last_update_date ),
    last_updated_by		= DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by ),
    last_update_login		= DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login)
  WHERE entity_attr_id = p_entity_attr_id;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

END seed_update_row;

procedure LOAD_ROW (
  p_upload_mode                 IN VARCHAR2,
  p_entity_attr_id		IN NUMBER,
  p_object_version_number       IN NUMBER,
  p_attribute_id		IN NUMBER,
  p_entity			IN VARCHAR2,
  p_sql_text			IN VARCHAR2,
  p_attr_data_type		IN VARCHAR2,
  p_lov_string			IN VARCHAR2,
  p_locator_flag		IN VARCHAR2,
  p_entity_type			IN VARCHAR2,
  p_enabled_flag		IN VARCHAR2,
  p_display_flag		IN VARCHAR2,
  p_require_validation_flag	IN VARCHAR2,
  p_external_update_text	IN VARCHAR2,
  p_batch_sql_text		IN VARCHAR2,
  p_display_external_value_flag IN VARCHAR2,
  p_refresh_frequency		IN NUMBER,
  p_refresh_frequency_uom	IN VARCHAR2,
  p_last_refresh_date		IN DATE,
  p_owner                       IN VARCHAR2
)
IS
l_user_id           number := 0;
l_obj_verno         number;
l_dummy_char        varchar2(1);
l_row_id            varchar2(100);
l_entity_attr_id      number := p_entity_attr_id;

cursor  c_obj_verno is
  select object_version_number
  from   pv_entity_attrs
  where  entity_attr_id =  p_entity_attr_id;

cursor c_chk_attrib_exists is
  select 'x'
  from   pv_entity_attrs
  where  entity_attr_id =  p_entity_attr_id;

BEGIN
  if p_OWNER = 'SEED' then
     l_user_id := 1;
  else
     l_user_id := 0;
 end if;
 IF p_upload_mode = 'NLS' THEN
    NULL;
 ELSE
	 open c_chk_attrib_exists;
	 fetch c_chk_attrib_exists into l_dummy_char;
	 if c_chk_attrib_exists%notfound
	 then
	    close c_chk_attrib_exists;
	    l_obj_verno := 1;

	    INSERT_ROW(
		  px_entity_attr_id		=> l_entity_attr_id,
		  px_object_version_number	=> l_obj_verno,
		  p_batch_sql_text		=> p_batch_sql_text,
		  p_refresh_frequency		=> p_refresh_frequency,
		  p_refresh_frequency_uom	=> p_refresh_frequency_uom,
		  p_last_refresh_date		=> p_last_refresh_date,
		  p_display_external_value_flag => p_display_external_value_flag,
		  p_lov_string			=> p_lov_string,
		  p_enabled_flag		=> p_enabled_flag,
		  p_display_flag		=> p_display_flag,
		  p_locator_flag		=> p_locator_flag,
		  p_entity_type			=> p_entity_type,
		  p_require_validation_flag	=> p_require_validation_flag,
		  p_external_update_text	=> p_external_update_text,
		  p_attribute_id		=> p_attribute_id,
		  p_entity			=> p_entity,
		  p_sql_text			=> p_sql_text,
		  p_attr_data_type		=> p_attr_data_type,
		  p_creation_date		=> sysdate,
		  p_created_by			=> l_user_id,
		  p_last_update_date		=> sysdate,
		  p_last_updated_by		=> l_user_id,
		  p_last_update_login		=> 0);

	else
	   close c_chk_attrib_exists;
	   open c_obj_verno;
	   fetch c_obj_verno into l_obj_verno;
	   close c_obj_verno;

	    UPDATE_SEED_ROW(
		  p_entity_attr_id		=> l_entity_attr_id,
		  p_object_version_number	=> p_object_version_number,
		  p_batch_sql_text		=> p_batch_sql_text,
		  p_refresh_frequency		=> p_refresh_frequency,
		  p_refresh_frequency_uom	=> p_refresh_frequency_uom,
		  p_last_refresh_date		=> p_last_refresh_date,
		  p_display_external_value_flag => p_display_external_value_flag,
		  p_lov_string			=> p_lov_string,
		  p_enabled_flag		=> p_enabled_flag,
		  p_display_flag		=> p_display_flag,
		  p_locator_flag		=> p_locator_flag,
		  p_entity_type			=> p_entity_type,
		  p_require_validation_flag	=> p_require_validation_flag,
		  p_external_update_text	=> p_external_update_text,
		  p_attribute_id		=> p_attribute_id,
		  p_entity			=> p_entity,
		  p_sql_text			=> p_sql_text,
		  p_attr_data_type		=> p_attr_data_type,
		  p_last_update_date		=> sysdate,
		  p_last_updated_by		=> l_user_id,
		  p_last_update_login		=> 0);

	END IF;
  END IF;
END LOAD_ROW;

procedure DELETE_ROW (
  p_entity_attr_id		IN NUMBER
)
 IS
begin

  delete from PV_ENTITY_ATTRS
  where ENTITY_ATTR_ID = p_ENTITY_ATTR_ID;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
end DELETE_ROW;



end PV_ENTITY_ATTRS_PKG;

/
