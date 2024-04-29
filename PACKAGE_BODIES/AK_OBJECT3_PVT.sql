--------------------------------------------------------
--  DDL for Package Body AK_OBJECT3_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_OBJECT3_PVT" as
/* $Header: akdvob3b.pls 120.3.12010000.2 2008/09/04 21:16:35 tshort ship $*/

--=======================================================
--  Procedure   UPDATE_OBJECT
--
--  Usage       Private API for updating an object.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates an object using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Object columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_OBJECT (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_database_object_name     IN      VARCHAR2,
  p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
  p_primary_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_defaulting_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_defaulting_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_validation_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_validation_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_category       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute1               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute11              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute12              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute13              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute14              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute15              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_csr (lang_parm varchar2) is
    select *
    from  AK_OBJECTS
    where DATABASE_OBJECT_NAME = p_database_object_name
    for update of APPLICATION_ID;
  cursor l_get_tl_row_csr (lang_parm varchar2) is
    select *
    from  AK_OBJECTS_TL
    where DATABASE_OBJECT_NAME = p_database_object_name
    and   LANGUAGE = lang_parm
    for update of NAME;
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Update_Object';
  l_created_by              number;
  l_creation_date           date;
  l_objects_rec             AK_OBJECTS%ROWTYPE;
  l_objects_tl_rec          AK_OBJECTS_TL%ROWTYPE;
  l_lang varchar2(30);
  l_last_update_date date;
  l_last_update_login number;
  l_last_updated_by number;
  l_return_status varchar2(1);
  l_file_version	number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

  savepoint start_update_object;

  select userenv('LANG') into l_lang
  from dual;

  --** retrieve ak_objects row if it exists **
  open l_get_row_csr(l_lang);
  fetch l_get_row_csr into l_objects_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --** retrieve ak_objects_tl row if it exists **
  open l_get_tl_row_csr(l_lang);
  fetch l_get_tl_row_csr into l_objects_tl_rec;
  if (l_get_tl_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    close l_get_tl_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_tl_row_csr;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_OBJECT_PVT.VALIDATE_OBJECT(
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_database_object_name => p_database_object_name,
            p_name => p_name,
            p_description => p_description,
            p_application_id => p_application_id,
            p_primary_key_name => p_primary_key_name,
            p_defaulting_api_pkg => p_defaulting_api_pkg,
            p_defaulting_api_proc => p_defaulting_api_proc,
            p_validation_api_pkg => p_validation_api_pkg,
            p_validation_api_proc => p_validation_api_proc,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
			p_pass => p_pass
      ) then
	if (p_pass = 1) then
		p_copy_redo_flag := TRUE;
	else
      		raise FND_API.G_EXC_ERROR;
	end if;
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **

  if (p_primary_key_name <> FND_API.G_MISS_CHAR) or
     (p_primary_key_name is null) then
    l_objects_rec.primary_key_name := p_primary_key_name;
  end if;
  if (p_defaulting_api_pkg <> FND_API.G_MISS_CHAR) or
     (p_defaulting_api_pkg is null) then
    l_objects_rec.defaulting_api_pkg := p_defaulting_api_pkg;
  end if;
  if (p_defaulting_api_proc <> FND_API.G_MISS_CHAR) or
     (p_defaulting_api_proc is null) then
    l_objects_rec.defaulting_api_proc := p_defaulting_api_proc;
  end if;
  if (p_validation_api_pkg <> FND_API.G_MISS_CHAR) or
     (p_validation_api_pkg is null) then
    l_objects_rec.validation_api_pkg := p_validation_api_pkg;
  end if;
  if (p_validation_api_proc <> FND_API.G_MISS_CHAR) or
     (p_validation_api_proc is null) then
    l_objects_rec.validation_api_proc := p_validation_api_proc;
  end if;
  if (p_attribute_category <> FND_API.G_MISS_CHAR) or
     (p_attribute_category is null) then
    l_objects_rec.attribute_category := p_attribute_category;
  end if;
  if (p_attribute1 <> FND_API.G_MISS_CHAR) or
     (p_attribute1 is null) then
    l_objects_rec.attribute1 := p_attribute1;
  end if;
  if (p_attribute2 <> FND_API.G_MISS_CHAR) or
     (p_attribute2 is null) then
    l_objects_rec.attribute2 := p_attribute2;
  end if;
  if (p_attribute3 <> FND_API.G_MISS_CHAR) or
     (p_attribute3 is null) then
    l_objects_rec.attribute3 := p_attribute3;
  end if;
  if (p_attribute4 <> FND_API.G_MISS_CHAR) or
     (p_attribute4 is null) then
    l_objects_rec.attribute4 := p_attribute4;
  end if;
  if (p_attribute5 <> FND_API.G_MISS_CHAR) or
     (p_attribute5 is null) then
    l_objects_rec.attribute5 := p_attribute5;
  end if;
  if (p_attribute6 <> FND_API.G_MISS_CHAR) or
     (p_attribute6 is null) then
    l_objects_rec.attribute6 := p_attribute6;
  end if;
  if (p_attribute7 <> FND_API.G_MISS_CHAR) or
     (p_attribute7 is null) then
    l_objects_rec.attribute7 := p_attribute7;
  end if;
  if (p_attribute8 <> FND_API.G_MISS_CHAR) or
     (p_attribute8 is null) then
    l_objects_rec.attribute8 := p_attribute8;
  end if;
  if (p_attribute9 <> FND_API.G_MISS_CHAR) or
     (p_attribute9 is null) then
    l_objects_rec.attribute9 := p_attribute9;
  end if;
  if (p_attribute10 <> FND_API.G_MISS_CHAR) or
     (p_attribute10 is null) then
    l_objects_rec.attribute10 := p_attribute10;
  end if;
  if (p_attribute11 <> FND_API.G_MISS_CHAR) or
     (p_attribute11 is null) then
    l_objects_rec.attribute11 := p_attribute11;
  end if;
  if (p_attribute12 <> FND_API.G_MISS_CHAR) or
     (p_attribute12 is null) then
    l_objects_rec.attribute12 := p_attribute12;
  end if;
  if (p_attribute13 <> FND_API.G_MISS_CHAR) or
     (p_attribute13 is null) then
    l_objects_rec.attribute13 := p_attribute13;
  end if;
  if (p_attribute14 <> FND_API.G_MISS_CHAR) or
     (p_attribute14 is null) then
    l_objects_rec.attribute14 := p_attribute14;
  end if;
  if (p_attribute15 <> FND_API.G_MISS_CHAR) or
     (p_attribute15 is null) then
    l_objects_rec.attribute15 := p_attribute15;
  end if;
  if (p_name  <> FND_API.G_MISS_CHAR) or
     (p_name is null) then
    l_objects_tl_rec.name := p_name;
  end if;
  if (p_description <> FND_API.G_MISS_CHAR) or
     (p_description is null) then
    l_objects_tl_rec.description := p_description;
  end if;

  --** - next, load non-null columns **

  if (p_application_id <> FND_API.G_MISS_NUM) then
    l_objects_rec.application_id := p_application_id;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_objects_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_objects_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

  update AK_OBJECTS set
      APPLICATION_ID = l_objects_rec.application_id,
      PRIMARY_KEY_NAME = l_objects_rec.primary_key_name,
      DEFAULTING_API_PKG = l_objects_rec.defaulting_api_pkg,
      DEFAULTING_API_PROC = l_objects_rec.defaulting_api_proc,
      VALIDATION_API_PKG = l_objects_rec.validation_api_pkg,
      VALIDATION_API_PROC = l_objects_rec.validation_api_proc,
	  ATTRIBUTE_CATEGORY = l_objects_rec.attribute_category,
	  ATTRIBUTE1 = l_objects_rec.attribute1,
	  ATTRIBUTE2 = l_objects_rec.attribute2,
	  ATTRIBUTE3 = l_objects_rec.attribute3,
	  ATTRIBUTE4 = l_objects_rec.attribute4,
	  ATTRIBUTE5 = l_objects_rec.attribute5,
	  ATTRIBUTE6 = l_objects_rec.attribute6,
	  ATTRIBUTE7 = l_objects_rec.attribute7,
	  ATTRIBUTE8 = l_objects_rec.attribute8,
	  ATTRIBUTE9 = l_objects_rec.attribute9,
	  ATTRIBUTE10 = l_objects_rec.attribute10,
	  ATTRIBUTE11 = l_objects_rec.attribute11,
	  ATTRIBUTE12 = l_objects_rec.attribute12,
	  ATTRIBUTE13 = l_objects_rec.attribute13,
	  ATTRIBUTE14 = l_objects_rec.attribute14,
	  ATTRIBUTE15 = l_objects_rec.attribute15,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
  where DATABASE_OBJECT_NAME = p_database_object_name;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  update AK_OBJECTS_TL set
      NAME = l_objects_tl_rec.name,
      DESCRIPTION = l_objects_tl_rec.description,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login,
	  SOURCE_LANG = l_lang
  where DATABASE_OBJECT_NAME = p_database_object_name
  and   l_lang in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_OBJECT_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
    FND_MSG_PUB.Add;
  end if;

  end if;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name );
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_object;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name );
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_object;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_object;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPDATE_OBJECT;

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE
--
--  Usage       Private API for updating an object attribute.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates an object attribute using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Object Attribute columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ATTRIBUTE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_database_object_name     IN      VARCHAR2,
  p_attribute_application_id IN      NUMBER,
  p_attribute_code           IN      VARCHAR2,
  p_column_name              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
  p_display_value_length     IN      NUMBER := FND_API.G_MISS_NUM,
  p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_source_type         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_storage_type        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_table_name               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_base_table_column_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_required_flag            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
  p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
  p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
  p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_lov_foreign_key_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_lov_attribute_application_id IN  NUMBER := FND_API.G_MISS_NUM,
  p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_defaulting_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_defaulting_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_validation_api_pkg       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_validation_api_proc      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_category       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute1               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute11              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute12              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute13              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute14              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute15              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_csr is
    select *
    from  AK_OBJECT_ATTRIBUTES
    where DATABASE_OBJECT_NAME = p_database_object_name
    and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code
    for   update of ATTRIBUTE_APPLICATION_ID;
  cursor l_get_tl_row_csr (lang_parm varchar2) is
    select *
    from  AK_OBJECT_ATTRIBUTES_TL
    where DATABASE_OBJECT_NAME = p_database_object_name
    and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   LANGUAGE = lang_parm
    for update of ATTRIBUTE_APPLICATION_ID;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Update_Attribute';
  l_attributes_rec     ak_object_attributes%ROWTYPE;
  l_attributes_tl_rec  ak_object_attributes_tl%ROWTYPE;
  l_created_by         number;
  l_creation_date      date;
  l_dummy              number;
  l_error              boolean;
  l_lang               varchar2(30);
  l_last_update_date   date;
  l_last_update_login  number;
  l_last_updated_by    number;
  l_return_status      varchar2(1);
  l_file_version	number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

  savepoint start_update_attribute;

  select userenv('LANG') into l_lang
  from dual;

  --** retrieve ak_object_attributes row if it exists **
  open l_get_row_csr;
  fetch l_get_row_csr into l_attributes_rec;
  if (l_get_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_row_csr;

  --** retrieve ak_object_attributes_tl row if it exists **
  open l_get_tl_row_csr(l_lang);
  fetch l_get_tl_row_csr into l_attributes_tl_rec;
  if (l_get_tl_row_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(l_api_name || 'Error - TL Row does not exist');
    close l_get_tl_row_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_tl_row_csr;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_OBJECT_PVT.VALIDATE_ATTRIBUTE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_database_object_name => p_database_object_name,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_column_name => p_column_name,
            p_attribute_label_length => p_attribute_label_length,
            p_display_value_length => p_display_value_length,
            p_bold => p_bold,
            p_italic => p_italic,
            p_vertical_alignment => p_vertical_alignment,
            p_horizontal_alignment => p_horizontal_alignment,
            p_data_source_type => p_data_source_type,
            p_data_storage_type => p_data_storage_type,
            p_table_name => p_table_name,
            p_base_table_column_name => p_base_table_column_name,
            p_required_flag => p_required_flag,
            p_default_value_varchar2 => p_default_value_varchar2,
            p_default_value_number => p_default_value_number,
            p_default_value_date => p_default_value_date,
            p_lov_region_application_id => p_lov_region_application_id,
            p_lov_region_code => p_lov_region_code,
            p_lov_foreign_key_name => p_lov_foreign_key_name,
            p_lov_attribute_application_id => p_lov_attribute_application_id,
            p_lov_attribute_code => p_lov_attribute_code,
            p_defaulting_api_pkg => p_defaulting_api_pkg,
            p_defaulting_api_proc => p_defaulting_api_proc,
            p_validation_api_pkg => p_validation_api_pkg,
            p_validation_api_proc => p_validation_api_proc,
            p_attribute_label_long => p_attribute_label_long,
            p_attribute_label_short => p_attribute_label_short,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
			p_pass => p_pass
          ) then
      -- Do not raise an error if it's the first pass
	  if (p_pass = 1) then
	    p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if; -- /* if p_pass */
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **

  if (p_column_name <> FND_API.G_MISS_CHAR) or
     (p_column_name is null) then
    l_attributes_rec.column_name := p_column_name;
  end if;
  if (p_data_storage_type <> FND_API.G_MISS_CHAR) or
     (p_data_storage_type is null) then
    l_attributes_rec.data_storage_type := p_data_storage_type;
  end if;
  if (p_table_name <> FND_API.G_MISS_CHAR) or
     (p_table_name is null) then
    l_attributes_rec.table_name := p_table_name;
  end if;
  if (p_base_table_column_name <> FND_API.G_MISS_CHAR) or
     (p_base_table_column_name is null) then
    l_attributes_rec.base_table_column_name := p_base_table_column_name;
  end if;
  if (p_default_value_varchar2 <> FND_API.G_MISS_CHAR) or
     (p_default_value_varchar2 is null) then
    l_attributes_rec.default_value_varchar2 := p_default_value_varchar2;
  end if;
  if (p_default_value_number <> FND_API.G_MISS_NUM) or
     (p_default_value_number is null) then
    l_attributes_rec.default_value_number := p_default_value_number;
  end if;
  if (p_default_value_date <> FND_API.G_MISS_DATE) or
     (p_default_value_date is null) then
    l_attributes_rec.default_value_date := p_default_value_date;
  end if;
  if (p_lov_region_application_id <> FND_API.G_MISS_NUM) or
     (p_lov_region_application_id is null) then
    l_attributes_rec.lov_region_application_id := p_lov_region_application_id;
  end if;
  if (p_lov_region_code <> FND_API.G_MISS_CHAR) or
     (p_lov_region_code is null) then
    l_attributes_rec.lov_region_code := p_lov_region_code;
  end if;
  if (p_lov_foreign_key_name <> FND_API.G_MISS_CHAR) or
     (p_lov_foreign_key_name is null) then
    l_attributes_rec.lov_foreign_key_name := p_lov_foreign_key_name;
  end if;
  if (p_lov_attribute_application_id <> FND_API.G_MISS_NUM) or
     (p_lov_attribute_application_id is null) then
    l_attributes_rec.lov_attribute_application_id :=
                         p_lov_attribute_application_id;
  end if;
  if (p_lov_attribute_code <> FND_API.G_MISS_CHAR) or
     (p_lov_attribute_code is null) then
    l_attributes_rec.lov_attribute_code := p_lov_attribute_code;
  end if;
  if (p_defaulting_api_pkg <> FND_API.G_MISS_CHAR) or
     (p_defaulting_api_pkg is null) then
    l_attributes_rec.defaulting_api_pkg := p_defaulting_api_pkg;
  end if;
  if (p_defaulting_api_proc <> FND_API.G_MISS_CHAR) or
     (p_defaulting_api_proc is null) then
    l_attributes_rec.defaulting_api_proc := p_defaulting_api_proc;
  end if;
  if (p_validation_api_pkg <> FND_API.G_MISS_CHAR) or
     (p_validation_api_pkg is null) then
    l_attributes_rec.validation_api_pkg := p_validation_api_pkg;
  end if;
  if (p_validation_api_proc <> FND_API.G_MISS_CHAR) or
     (p_validation_api_proc is null) then
    l_attributes_rec.validation_api_proc := p_validation_api_proc;
  end if;
  if (p_attribute_category <> FND_API.G_MISS_CHAR) or
     (p_attribute_category is null) then
    l_attributes_rec.attribute_category := p_attribute_category;
  end if;
  if (p_attribute1 <> FND_API.G_MISS_CHAR) or
     (p_attribute1 is null) then
    l_attributes_rec.attribute1 := p_attribute1;
  end if;
  if (p_attribute2 <> FND_API.G_MISS_CHAR) or
     (p_attribute2 is null) then
    l_attributes_rec.attribute2 := p_attribute2;
  end if;
  if (p_attribute3 <> FND_API.G_MISS_CHAR) or
     (p_attribute3 is null) then
    l_attributes_rec.attribute3 := p_attribute3;
  end if;
  if (p_attribute4 <> FND_API.G_MISS_CHAR) or
     (p_attribute4 is null) then
    l_attributes_rec.attribute4 := p_attribute4;
  end if;
  if (p_attribute5 <> FND_API.G_MISS_CHAR) or
     (p_attribute5 is null) then
    l_attributes_rec.attribute5 := p_attribute5;
  end if;
  if (p_attribute6 <> FND_API.G_MISS_CHAR) or
     (p_attribute6 is null) then
    l_attributes_rec.attribute6 := p_attribute6;
  end if;
  if (p_attribute7 <> FND_API.G_MISS_CHAR) or
     (p_attribute7 is null) then
    l_attributes_rec.attribute7 := p_attribute7;
  end if;
  if (p_attribute8 <> FND_API.G_MISS_CHAR) or
     (p_attribute8 is null) then
    l_attributes_rec.attribute8 := p_attribute8;
  end if;
  if (p_attribute9 <> FND_API.G_MISS_CHAR) or
     (p_attribute9 is null) then
    l_attributes_rec.attribute9 := p_attribute9;
  end if;
  if (p_attribute10 <> FND_API.G_MISS_CHAR) or
     (p_attribute10 is null) then
    l_attributes_rec.attribute10 := p_attribute10;
  end if;
  if (p_attribute11 <> FND_API.G_MISS_CHAR) or
     (p_attribute11 is null) then
    l_attributes_rec.attribute11 := p_attribute11;
  end if;
  if (p_attribute12 <> FND_API.G_MISS_CHAR) or
     (p_attribute12 is null) then
    l_attributes_rec.attribute12 := p_attribute12;
  end if;
  if (p_attribute13 <> FND_API.G_MISS_CHAR) or
     (p_attribute13 is null) then
    l_attributes_rec.attribute13 := p_attribute13;
  end if;
  if (p_attribute14 <> FND_API.G_MISS_CHAR) or
     (p_attribute14 is null) then
    l_attributes_rec.attribute14 := p_attribute14;
  end if;
  if (p_attribute15 <> FND_API.G_MISS_CHAR) or
     (p_attribute15 is null) then
    l_attributes_rec.attribute15 := p_attribute15;
  end if;
  if (p_attribute_label_long <> FND_API.G_MISS_CHAR) or
     (p_attribute_label_long is null) then
    l_attributes_tl_rec.attribute_label_long := p_attribute_label_long;
  end if;
  if (p_attribute_label_short <> FND_API.G_MISS_CHAR) or
     (p_attribute_label_short is null) then
    l_attributes_tl_rec.attribute_label_short := p_attribute_label_short;
  end if;

  --** - next, load non-null columns **

  if (p_attribute_label_length <> FND_API.G_MISS_NUM) then
    l_attributes_rec.attribute_label_length := p_attribute_label_length;
  end if;
  if (p_display_value_length <> FND_API.G_MISS_NUM) then
    l_attributes_rec.display_value_length := p_display_value_length;
  end if;
  if (p_bold <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.bold := p_bold;
  end if;
  if (p_italic <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.italic := p_italic;
  end if;
  if (p_vertical_alignment <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.vertical_alignment := p_vertical_alignment;
  end if;
  if (p_horizontal_alignment <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.horizontal_alignment := p_horizontal_alignment;
  end if;
  if (p_data_source_type <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.data_source_type := p_data_source_type;
  end if;
  if (p_required_flag <> FND_API.G_MISS_CHAR) then
    l_attributes_rec.required_flag := p_required_flag;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;
  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;
  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;
  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;
  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_attributes_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_attributes_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

  update AK_OBJECT_ATTRIBUTES set
      COLUMN_NAME = l_attributes_rec.column_name,
      ATTRIBUTE_LABEL_LENGTH = l_attributes_rec.attribute_label_length,
      DISPLAY_VALUE_LENGTH = l_attributes_rec.display_value_length,
      BOLD = l_attributes_rec.bold,
      ITALIC = l_attributes_rec.italic,
      VERTICAL_ALIGNMENT = l_attributes_rec.vertical_alignment,
      HORIZONTAL_ALIGNMENT = l_attributes_rec.horizontal_alignment,
      DATA_SOURCE_TYPE = l_attributes_rec.data_source_type,
      DATA_STORAGE_TYPE = l_attributes_rec.data_storage_type,
      TABLE_NAME = l_attributes_rec.table_name,
      BASE_TABLE_COLUMN_NAME = l_attributes_rec.base_table_column_name,
      REQUIRED_FLAG = l_attributes_rec.required_flag,
      DEFAULT_VALUE_VARCHAR2 = l_attributes_rec.default_value_varchar2,
      DEFAULT_VALUE_NUMBER = l_attributes_rec.default_value_number,
      DEFAULT_VALUE_DATE = l_attributes_rec.default_value_date,
      LOV_REGION_APPLICATION_ID = l_attributes_rec.lov_region_application_id,
      LOV_REGION_CODE = l_attributes_rec.lov_region_code,
      LOV_FOREIGN_KEY_NAME = l_attributes_rec.lov_foreign_key_name,
      LOV_ATTRIBUTE_APPLICATION_ID =
                    l_attributes_rec.lov_attribute_application_id,
      LOV_ATTRIBUTE_CODE = l_attributes_rec.lov_attribute_code,
      DEFAULTING_API_PKG = l_attributes_rec.defaulting_api_pkg,
      DEFAULTING_API_PROC = l_attributes_rec.defaulting_api_proc,
      VALIDATION_API_PKG = l_attributes_rec.validation_api_pkg,
      VALIDATION_API_PROC = l_attributes_rec.validation_api_proc,
	  ATTRIBUTE_CATEGORY = l_attributes_rec.attribute_category,
	  ATTRIBUTE1 = l_attributes_rec.attribute1,
	  ATTRIBUTE2 = l_attributes_rec.attribute2,
	  ATTRIBUTE3 = l_attributes_rec.attribute3,
	  ATTRIBUTE4 = l_attributes_rec.attribute4,
	  ATTRIBUTE5 = l_attributes_rec.attribute5,
	  ATTRIBUTE6 = l_attributes_rec.attribute6,
	  ATTRIBUTE7 = l_attributes_rec.attribute7,
	  ATTRIBUTE8 = l_attributes_rec.attribute8,
	  ATTRIBUTE9 = l_attributes_rec.attribute9,
	  ATTRIBUTE10 = l_attributes_rec.attribute10,
	  ATTRIBUTE11 = l_attributes_rec.attribute11,
	  ATTRIBUTE12 = l_attributes_rec.attribute12,
	  ATTRIBUTE13 = l_attributes_rec.attribute13,
	  ATTRIBUTE14 = l_attributes_rec.attribute14,
	  ATTRIBUTE15 = l_attributes_rec.attribute15,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
  where database_object_name = p_database_object_name
  and   attribute_application_id = p_attribute_application_id
  and   attribute_code = p_attribute_code;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line('Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

  update AK_OBJECT_ATTRIBUTES_TL set
      ATTRIBUTE_LABEL_LONG = l_attributes_tl_rec.attribute_label_long,
      ATTRIBUTE_LABEL_SHORT = l_attributes_tl_rec.attribute_label_short,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATE_LOGIN = l_last_update_login,
	  SOURCE_LANG = l_lang
  where database_object_name = p_database_object_name
  and   attribute_application_id = p_attribute_application_id
  and   attribute_code = p_attribute_code
  and   l_lang in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line('TL Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                   ' ' || to_char(p_attribute_application_id) ||
                                   ' ' || p_attribute_code );
    FND_MSG_PUB.Add;
  end if;

  end if;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                   ' ' || to_char(p_attribute_application_id) ||
                                   ' ' || p_attribute_code );
      FND_MSG_PUB.Add;
    end if;
    rollback to start_update_attribute;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_ATTR_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                   ' ' || to_char(p_attribute_application_id) ||
                                   ' ' || p_attribute_code );
      FND_MSG_PUB.Add;
    end if;
	--dbms_output.put_line('OA Key: '||p_database_object_name ||
	--                     ' ' || to_char(p_attribute_application_id) ||
	--					 ' ' || p_attribute_code );
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_attribute;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
	--dbms_output.put_line('OA Key: '||p_database_object_name ||
	--                     ' ' || to_char(p_attribute_application_id) ||
	---					 ' ' || p_attribute_code );
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_attribute;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPDATE_ATTRIBUTE;

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE_NAVIGATION
--
--  Usage       Private API for updating an attribute navigation
--              record. This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates an attribute navigation record
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute Navigation columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ATTRIBUTE_NAVIGATION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_database_object_name     IN      VARCHAR2,
  p_attribute_application_id IN      NUMBER,
  p_attribute_code           IN      VARCHAR2,
  p_value_varchar2           IN      VARCHAR2,
  p_value_date               IN      DATE,
  p_value_number             IN      NUMBER,
  p_to_region_appl_id        IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_region_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_category       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute1               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute11              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute12              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute13              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute14              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute15              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
  p_pass                     IN      NUMBER,
  p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
  cursor l_get_row_1_csr is
    select *
    from  AK_OBJECT_ATTRIBUTE_NAVIGATION
    where DATABASE_OBJECT_NAME = p_database_object_name
    and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   VALUE_VARCHAR2 = p_value_varchar2
    and   VALUE_DATE is null
    and   VALUE_NUMBER is null
    for update of to_region_appl_id;
  cursor l_get_row_2_csr is
    select *
    from  AK_OBJECT_ATTRIBUTE_NAVIGATION
    where DATABASE_OBJECT_NAME = p_database_object_name
    and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   VALUE_VARCHAR2 is null
    and   VALUE_DATE = p_value_date
    and   VALUE_NUMBER is null
    for update of to_region_appl_id;
  cursor l_get_row_3_csr is
    select *
    from  AK_OBJECT_ATTRIBUTE_NAVIGATION
    where DATABASE_OBJECT_NAME = p_database_object_name
    and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
    and   ATTRIBUTE_CODE = p_attribute_code
    and   VALUE_VARCHAR2 is null
    and   VALUE_DATE is null
    and   VALUE_NUMBER = p_value_number
    for update of to_region_appl_id;
  l_api_version_number    CONSTANT number := 1.0;
  l_api_name              CONSTANT varchar2(30):= 'Update_Attribute_Navigation';
  l_count                 number;
  l_created_by            number;
  l_creation_date         date;
  l_error                 boolean;
  l_navigation_rec        ak_object_attribute_navigation%ROWTYPE;
  l_last_update_date      date;
  l_last_update_login     number;
  l_last_updated_by       number;
  l_return_status         varchar2(1);
  l_file_version	number;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

  savepoint start_update_navigation;

  --** check that one and only one value field can be non-null **
  l_count := 0;
  if (p_value_varchar2 is not null) then
    l_count := l_count + 1;
  end if;
  if (p_value_date is not null) then
    l_count := l_count + 1;
  end if;
  if (p_value_number is not null) then
    l_count := l_count + 1;
  end if;
  if (l_count <> 1) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_ONE_VALUE_ONLY');
        FND_MSG_PUB.Add;
      end if;
      -- dbms_output.put_line('One and only one value field must be non-null');
      raise FND_API.G_EXC_ERROR;
  end if;

  --** retrieve ak_object_attribute_navigation row if it exists **
  if (p_value_varchar2 is not null) then
    open l_get_row_1_csr;
    fetch l_get_row_1_csr into l_navigation_rec;
    if (l_get_row_1_csr%notfound) then
      close l_get_row_1_csr;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_NAV_DOES_NOT_EXIST');
        FND_MSG_PUB.Add;
      end if;
      -- dbms_output.put_line(l_api_name || 'Error - Row does not exist');
      raise FND_API.G_EXC_ERROR;
    end if;
    close l_get_row_1_csr;
  elsif (p_value_date is not null) then
    open l_get_row_2_csr;
    fetch l_get_row_2_csr into l_navigation_rec;
    if (l_get_row_2_csr%notfound) then
      close l_get_row_2_csr;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_NAV_DOES_NOT_EXIST');
        FND_MSG_PUB.Add;
      end if;
      -- dbms_output.put_line(l_api_name || 'Error - Row does not exist');
      raise FND_API.G_EXC_ERROR;
    end if;
    close l_get_row_2_csr;
  elsif (p_value_number is not null) then
    open l_get_row_3_csr;
    fetch l_get_row_3_csr into l_navigation_rec;
    if (l_get_row_3_csr%notfound) then
      close l_get_row_3_csr;
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
        FND_MESSAGE.SET_NAME('AK','AK_NAV_DOES_NOT_EXIST');
        FND_MSG_PUB.Add;
      end if;
      -- dbms_output.put_line(l_api_name || 'Error - Row does not exist');
      raise FND_API.G_EXC_ERROR;
    end if;
    close l_get_row_3_csr;
  end if;

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not AK_OBJECT_PVT.VALIDATE_ATTRIBUTE_NAVIGATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_database_object_name => p_database_object_name,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_value_varchar2 => p_value_varchar2,
            p_value_date => p_value_date,
            p_value_number => p_value_number,
            p_to_region_appl_id => p_to_region_appl_id,
            p_to_region_code => p_to_region_code,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
			p_pass => p_pass
          ) then
      -- dbms_output.put_line(l_api_name || ' validation failed');
      -- Do not raise an error if it's the first pass
	  if (p_pass = 1) then
	    p_copy_redo_flag := TRUE;
      else
        raise FND_API.G_EXC_ERROR;
      end if; -- /* if p_pass */
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - load non-null columns **

  if (p_to_region_appl_id <> FND_API.G_MISS_NUM) then
    l_navigation_rec.to_region_appl_id := p_to_region_appl_id;
  end if;
  if (p_to_region_code <> FND_API.G_MISS_CHAR) then
    l_navigation_rec.to_region_code := p_to_region_code;
  end if;

  if (p_attribute_category <> FND_API.G_MISS_CHAR) or
     (p_attribute_category is null) then
    l_navigation_rec.attribute_category := p_attribute_category;
  end if;
  if (p_attribute1 <> FND_API.G_MISS_CHAR) or
     (p_attribute1 is null) then
    l_navigation_rec.attribute1 := p_attribute1;
  end if;
  if (p_attribute2 <> FND_API.G_MISS_CHAR) or
     (p_attribute2 is null) then
    l_navigation_rec.attribute2 := p_attribute2;
  end if;
  if (p_attribute3 <> FND_API.G_MISS_CHAR) or
     (p_attribute3 is null) then
    l_navigation_rec.attribute3 := p_attribute3;
  end if;
  if (p_attribute4 <> FND_API.G_MISS_CHAR) or
     (p_attribute4 is null) then
    l_navigation_rec.attribute4 := p_attribute4;
  end if;
  if (p_attribute5 <> FND_API.G_MISS_CHAR) or
     (p_attribute5 is null) then
    l_navigation_rec.attribute5 := p_attribute5;
  end if;
  if (p_attribute6 <> FND_API.G_MISS_CHAR) or
     (p_attribute6 is null) then
    l_navigation_rec.attribute6 := p_attribute6;
  end if;
  if (p_attribute7 <> FND_API.G_MISS_CHAR) or
     (p_attribute7 is null) then
    l_navigation_rec.attribute7 := p_attribute7;
  end if;
  if (p_attribute8 <> FND_API.G_MISS_CHAR) or
     (p_attribute8 is null) then
    l_navigation_rec.attribute8 := p_attribute8;
  end if;
  if (p_attribute9 <> FND_API.G_MISS_CHAR) or
     (p_attribute9 is null) then
    l_navigation_rec.attribute9 := p_attribute9;
  end if;
  if (p_attribute10 <> FND_API.G_MISS_CHAR) or
     (p_attribute10 is null) then
    l_navigation_rec.attribute10 := p_attribute10;
  end if;
  if (p_attribute11 <> FND_API.G_MISS_CHAR) or
     (p_attribute11 is null) then
    l_navigation_rec.attribute11 := p_attribute11;
  end if;
  if (p_attribute12 <> FND_API.G_MISS_CHAR) or
     (p_attribute12 is null) then
    l_navigation_rec.attribute12 := p_attribute12;
  end if;
  if (p_attribute13 <> FND_API.G_MISS_CHAR) or
     (p_attribute13 is null) then
    l_navigation_rec.attribute13 := p_attribute13;
  end if;
  if (p_attribute14 <> FND_API.G_MISS_CHAR) or
     (p_attribute14 is null) then
    l_navigation_rec.attribute14 := p_attribute14;
  end if;
  if (p_attribute15 <> FND_API.G_MISS_CHAR) or
     (p_attribute15 is null) then
    l_navigation_rec.attribute15 := p_attribute15;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;
  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;
  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;
  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;
  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_navigation_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_navigation_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

  if (p_value_varchar2 is not null) then
    update AK_OBJECT_ATTRIBUTE_NAVIGATION set
      TO_REGION_APPL_ID = l_navigation_rec.to_region_appl_id,
      TO_REGION_CODE = l_navigation_rec.to_region_code,
	  ATTRIBUTE_CATEGORY = l_navigation_rec.attribute_category,
	  ATTRIBUTE1 = l_navigation_rec.attribute1,
	  ATTRIBUTE2 = l_navigation_rec.attribute2,
	  ATTRIBUTE3 = l_navigation_rec.attribute3,
	  ATTRIBUTE4 = l_navigation_rec.attribute4,
	  ATTRIBUTE5 = l_navigation_rec.attribute5,
	  ATTRIBUTE6 = l_navigation_rec.attribute6,
	  ATTRIBUTE7 = l_navigation_rec.attribute7,
	  ATTRIBUTE8 = l_navigation_rec.attribute8,
	  ATTRIBUTE9 = l_navigation_rec.attribute9,
	  ATTRIBUTE10 = l_navigation_rec.attribute10,
	  ATTRIBUTE11 = l_navigation_rec.attribute11,
	  ATTRIBUTE12 = l_navigation_rec.attribute12,
	  ATTRIBUTE13 = l_navigation_rec.attribute13,
	  ATTRIBUTE14 = l_navigation_rec.attribute14,
	  ATTRIBUTE15 = l_navigation_rec.attribute15,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
    where database_object_name = p_database_object_name
    and   attribute_application_id = p_attribute_application_id
    and   attribute_code = p_attribute_code
    and   value_varchar2 = p_value_varchar2
    and   value_date is null
    and   value_number is null;
  elsif (p_value_date is not null) then
    update AK_OBJECT_ATTRIBUTE_NAVIGATION set
      TO_REGION_APPL_ID = l_navigation_rec.to_region_appl_id,
      TO_REGION_CODE = l_navigation_rec.to_region_code,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
    where database_object_name = p_database_object_name
    and   attribute_application_id = p_attribute_application_id
    and   attribute_code = p_attribute_code
    and   value_varchar2 is null
    and   value_date = p_value_date
    and   value_number is null;
  elsif (p_value_number is not null) then
    update AK_OBJECT_ATTRIBUTE_NAVIGATION set
      TO_REGION_APPL_ID = l_navigation_rec.to_region_appl_id,
      TO_REGION_CODE = l_navigation_rec.to_region_code,
      LAST_UPDATE_DATE = l_last_update_date,
      LAST_UPDATED_BY = l_last_updated_by,
      LAST_UPDATE_LOGIN = l_last_update_login
    where database_object_name = p_database_object_name
    and   attribute_application_id = p_attribute_application_id
    and   attribute_code = p_attribute_code
    and   value_varchar2 is null
    and   value_date is null
    and   value_number = p_value_number;
  end if;
  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_NAV_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line('Row does not exist during update');
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_NAV_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                 ' ' || to_char(p_attribute_application_id) ||
                                 ' ' || p_value_varchar2 ||
                                 ' ' || to_char(p_value_date) ||
                                 ' ' || to_char(p_value_number) );
    FND_MSG_PUB.Add;
  end if;

  end if;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_NAV_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                   ' ' || to_char(p_attribute_application_id) ||
                                   p_value_varchar2 ||
                                   to_char(p_value_date) ||
                                   to_char(p_value_number) );
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line('Value error occurred in ' || l_api_name);
    rollback to start_update_navigation;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_NAV_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                   ' ' || to_char(p_attribute_application_id) ||
                                   p_value_varchar2 ||
                                   to_char(p_value_date) ||
                                   to_char(p_value_number) );
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_navigation;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_navigation;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPDATE_ATTRIBUTE_NAVIGATION;

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE_VALUE
--
--  Usage       Private API for updating an attribute value record.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates an attribute value record
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute Value columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ATTRIBUTE_VALUE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_init_msg_tbl             IN      BOOLEAN := FALSE,
  p_msg_count                OUT NOCOPY     NUMBER,
  p_msg_data                 OUT NOCOPY     VARCHAR2,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_database_object_name     IN      VARCHAR2,
  p_attribute_application_id IN      NUMBER,
  p_attribute_code           IN      VARCHAR2,
  p_key_value1               IN      VARCHAR2,
  p_key_value2               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_key_value3               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_key_value4               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_key_value5               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_key_value6               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_key_value7               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_key_value8               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_key_value9               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_key_value10              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_value_date               IN      DATE := FND_API.G_MISS_DATE,
  p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
  p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE
) is
  l_api_version_number    CONSTANT number := 1.0;
  l_api_name              CONSTANT varchar2(30) := 'Update_Attribute_Value';
  l_created_by            number;
  l_creation_date         date;
  l_error                 boolean;
  l_key_value2            VARCHAR2(100);
  l_key_value3            VARCHAR2(100);
  l_key_value4            VARCHAR2(100);
  l_key_value5            VARCHAR2(100);
  l_key_value6            VARCHAR2(100);
  l_key_value7            VARCHAR2(100);
  l_key_value8            VARCHAR2(100);
  l_key_value9            VARCHAR2(100);
  l_key_value10           VARCHAR2(100);
  l_last_update_date      date;
  l_last_update_login     number;
  l_last_updated_by       number;
  l_return_status         varchar2(1);
  l_sql_csr               integer;
  l_sql_stmt              varchar2(1000);
  l_where_clause          varchar2(1000);
  l_value_varchar2        VARCHAR2(240);
  l_value_date            DATE;
  l_value_number          NUMBER;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

  savepoint start_update_value;

  -- load the optional key values to be used to query the database.
  --
  if (p_key_value2 is not null and p_key_value2 <> FND_API.G_MISS_CHAR) then
    l_key_value2 := p_key_value2;
  end if;
  if (p_key_value3 is not null and p_key_value3 <> FND_API.G_MISS_CHAR) then
    l_key_value3 := p_key_value3;
  end if;
  if (p_key_value4 is not null and p_key_value4 <> FND_API.G_MISS_CHAR) then
    l_key_value4 := p_key_value4;
  end if;
  if (p_key_value5 is not null and p_key_value5 <> FND_API.G_MISS_CHAR) then
    l_key_value5 := p_key_value5;
  end if;
  if (p_key_value6 is not null and p_key_value6 <> FND_API.G_MISS_CHAR) then
    l_key_value6 := p_key_value6;
  end if;
  if (p_key_value7 is not null and p_key_value7 <> FND_API.G_MISS_CHAR) then
    l_key_value7 := p_key_value7;
  end if;
  if (p_key_value8 is not null and p_key_value8 <> FND_API.G_MISS_CHAR) then
    l_key_value8 := p_key_value8;
  end if;
  if (p_key_value9 is not null and p_key_value9 <> FND_API.G_MISS_CHAR) then
    l_key_value9 := p_key_value9;
  end if;
  if (p_key_value10 is not null and p_key_value10 <> FND_API.G_MISS_CHAR) then
    l_key_value10 := p_key_value10;
  end if;

  --
  -- build where clause
  --
  l_where_clause := 'where database_object_name = :database_object_name ' ||
                  'and attribute_application_id = :attribute_application_id '||
                  'and attribute_code = :attribute_code ' ||
                  'and key_value1 = :key_value1 ';
  if (l_key_value2 is null) then
    l_where_clause := l_where_clause || 'and key_value2 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value2 = :key_value2 ';
  end if;
  if (l_key_value3 is null) then
    l_where_clause := l_where_clause || 'and key_value3 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value3 = :key_value3 ';
  end if;
  if (l_key_value4 is null) then
    l_where_clause := l_where_clause || 'and key_value4 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value4 = :key_value4 ';
  end if;
  if (l_key_value5 is null) then
    l_where_clause := l_where_clause || 'and key_value5 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value5 = :key_value5 ';
  end if;
  if (l_key_value6 is null) then
    l_where_clause := l_where_clause || 'and key_value6 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value6 = :key_value6 ';
  end if;
  if (l_key_value7 is null) then
    l_where_clause := l_where_clause || 'and key_value7 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value7 = :key_value7 ';
  end if;
  if (l_key_value8 is null) then
    l_where_clause := l_where_clause || 'and key_value8 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value8 = :key_value8 ';
  end if;
  if (l_key_value9 is null) then
    l_where_clause := l_where_clause || 'and key_value9 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value9 = :key_value9 ';
  end if;
  if (l_key_value10 is null) then
    l_where_clause := l_where_clause || 'and key_value10 is null ';
  else
    l_where_clause := l_where_clause || 'and key_value10 = :key_value10 ';
  end if;

  --** retrieve ak_inst_attribute_values row if it exists **
  l_sql_stmt := 'select value_varchar2, value_date, value_number ' ||
                'from ak_inst_attribute_values ' || l_where_clause;
  l_sql_csr := dbms_sql.open_cursor;
  dbms_sql.parse(l_sql_csr, l_sql_stmt, DBMS_SQL.V7);
  dbms_sql.define_column(l_sql_csr, 1, l_value_varchar2, 240);
  dbms_sql.define_column(l_sql_csr, 2, l_value_date);
  dbms_sql.define_column(l_sql_csr, 3, l_value_number);

  dbms_sql.bind_variable(l_sql_csr, 'database_object_name',
                                        p_database_object_name);
  dbms_sql.bind_variable(l_sql_csr, 'attribute_application_id',
					p_attribute_application_id);
  dbms_sql.bind_variable(l_sql_csr, 'attribute_code',p_attribute_code);
  dbms_sql.bind_variable(l_sql_csr, 'key_value1', p_key_value1);
  if (l_key_value2 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value2', l_key_value2);
  end if;
  if (l_key_value3 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value3', l_key_value3);
  end if;
  if (l_key_value4 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value4', l_key_value4);
  end if;
  if (l_key_value5 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value5', l_key_value5);
  end if;
  if (l_key_value6 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value6', l_key_value6);
  end if;
  if (l_key_value7 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value7', l_key_value7);
  end if;
  if (l_key_value8 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value8', l_key_value8);
  end if;
  if (l_key_value9 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value9', l_key_value9);
  end if;
  if (l_key_value10 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value10', l_key_value10);
  end if;

  if (dbms_sql.execute_and_fetch(l_sql_csr) = 0) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_DOES_NOT_EXIST');
      FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    --close l_get_row_csr;
    dbms_sql.close_cursor(l_sql_csr);
    raise FND_API.G_EXC_ERROR;
  end if;
  dbms_sql.close_cursor(l_sql_csr);

  --** validate table columns passed in **
  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
    if not ak_object_pvt.validate_attribute_value (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_database_object_name => p_database_object_name,
            p_attribute_application_id => p_attribute_application_id,
            p_attribute_code => p_attribute_code,
            p_key_value1 => p_key_value1,
            p_key_value2 => p_key_value2,
            p_key_value3 => p_key_value3,
            p_key_value4 => p_key_value4,
            p_key_value5 => p_key_value5,
            p_key_value6 => p_key_value6,
            p_key_value7 => p_key_value7,
            p_key_value8 => p_key_value8,
            p_key_value9 => p_key_value9,
            p_key_value10 => p_key_value10,
            p_value_varchar2 => p_value_varchar2,
            p_value_date => p_value_date,
            p_value_number => p_value_number,
            p_caller => AK_ON_OBJECTS_PVT.G_UPDATE
          ) then
      -- dbms_output.put_line(l_api_name || ' validation failed');
      raise FND_API.G_EXC_ERROR;
    end if;
  end if;

  --** Load record to be updated to the database **
  --** - first load nullable columns **

  if (p_value_varchar2 <> FND_API.G_MISS_CHAR) or
     (p_value_varchar2 is null) then
    l_value_varchar2 := p_value_varchar2;
  end if;
  if (p_value_date <> FND_API.G_MISS_DATE) or
     (p_value_date is null) then
    l_value_date := p_value_date;
  end if;
  if (p_value_number <> FND_API.G_MISS_NUM) or
     (p_value_number is null) then
    l_value_number := p_value_number;
  end if;

  -- Set WHO columns
  AK_UPLOAD_GRP.G_UPLOAD_DATE := p_last_update_date;
  AK_ON_OBJECTS_PVT.SET_WHO (
       p_return_status => l_return_status,
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_last_update_date => l_last_update_date,
       p_last_update_login => l_last_update_login);

  if (AK_UPLOAD_GRP.G_NON_SEED_DATA) then
        l_created_by := p_created_by;
        l_last_updated_by := p_last_updated_by;
        l_last_update_login := p_last_update_login;
  end if;

  l_sql_stmt := 'update AK_INST_ATTRIBUTE_VALUES set ' ||
                'VALUE_VARCHAR2 = :value_varchar2, ' ||
                'VALUE_DATE = :value_date, ' ||
                'VALUE_NUMBER = :value_number, ' ||
                'LAST_UPDATE_DATE = :last_update_date, ' ||
                'LAST_UPDATED_BY = :last_updated_by, ' ||
                'LAST_UPDATE_LOGIN = :last_update_login ' ||
                l_where_clause;
  l_sql_csr := dbms_sql.open_cursor;
  dbms_sql.parse(l_sql_csr, l_sql_stmt, DBMS_SQL.V7);

  dbms_sql.bind_variable(l_sql_csr, 'value_varchar2', l_value_varchar2);
  dbms_sql.bind_variable(l_sql_csr, 'value_date', l_value_date);
  dbms_sql.bind_variable(l_sql_csr, 'value_number', l_value_number);
  dbms_sql.bind_variable(l_sql_csr, 'last_update_date', l_last_update_date);
  dbms_sql.bind_variable(l_sql_csr, 'last_updated_by', l_last_updated_by);
  dbms_sql.bind_variable(l_sql_csr, 'last_update_login', l_last_update_login);
  dbms_sql.bind_variable(l_sql_csr, 'database_object_name',
                                                 p_database_object_name);
  dbms_sql.bind_variable(l_sql_csr, 'attribute_application_id',
					p_attribute_application_id);
  dbms_sql.bind_variable(l_sql_csr, 'attribute_code', p_attribute_code);
  dbms_sql.bind_variable(l_sql_csr, 'key_value1', p_key_value1);
  if (l_key_value2 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value2', l_key_value2);
  end if;
  if (l_key_value3 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value3', l_key_value3);
  end if;
  if (l_key_value4 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value4', l_key_value4);
  end if;
  if (l_key_value5 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value5', l_key_value5);
  end if;
  if (l_key_value6 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value6', l_key_value6);
  end if;
  if (l_key_value7 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value7', l_key_value7);
  end if;
  if (l_key_value8 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value8', l_key_value8);
  end if;
  if (l_key_value9 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value9', l_key_value9);
  end if;
  if (l_key_value10 is not null) then
    dbms_sql.bind_variable(l_sql_csr, 'key_value10', l_key_value10);
  end if;

  if (dbms_sql.execute(l_sql_csr) = 0) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_UPDATE_FAILED');
      FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Row does not exist during update');
    dbms_sql.close_cursor(l_sql_csr);
    raise FND_API.G_EXC_ERROR;
  end if;
  dbms_sql.close_cursor(l_sql_csr);

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_OBJECT_UPDATED');
    FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
    FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                   ' ' || to_char(p_attribute_application_id) ||
                                   ' ' || p_attribute_code ||
                                   ' ' || p_key_value1 ||
                                   ' ' || l_key_value2 ||
                                   ' ' || l_key_value3 ||
                                   ' ' || l_key_value4 ||
                                   ' ' || l_key_value5 ||
                                   ' ' || l_key_value6 ||
                                   ' ' || l_key_value7 ||
                                   ' ' || l_key_value8 ||
                                   ' ' || l_key_value9 ||
                                   ' ' || l_key_value10);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
      FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                   ' ' || to_char(p_attribute_application_id) ||
                                   ' ' || p_attribute_code ||
                                   ' ' || p_key_value1 ||
                                   ' ' || l_key_value2 ||
                                   ' ' || l_key_value3 ||
                                   ' ' || l_key_value4 ||
                                   ' ' || l_key_value5 ||
                                   ' ' || l_key_value6 ||
                                   ' ' || l_key_value7 ||
                                   ' ' || l_key_value8 ||
                                   ' ' || l_key_value9 ||
                                   ' ' || l_key_value10);
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Value error occurred in ' || l_api_name);
    rollback to start_update_value;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('OBJECT','AK_ATTRIBUTE_VALUE', TRUE);
      FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name ||
                                   ' ' || to_char(p_attribute_application_id) ||
                                   ' ' || p_attribute_code ||
                                   ' ' || p_key_value1 ||
                                   ' ' || l_key_value2 ||
                                   ' ' || l_key_value3 ||
                                   ' ' || l_key_value4 ||
                                   ' ' || l_key_value5 ||
                                   ' ' || l_key_value6 ||
                                   ' ' || l_key_value7 ||
                                   ' ' || l_key_value8 ||
                                   ' ' || l_key_value9 ||
                                   ' ' || l_key_value10);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_value;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_value;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
end UPDATE_ATTRIBUTE_VALUE;

--=======================================================
--  Procedure   UPLOAD_OBJECT
--
--  Usage       Private API for loading objects from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the object data (including object
--              attributes, foreign and unique key definitions,
--              attribute values, and attribute navigation records) stored
--              in the loader file currently being processed, parses
--              the data, and loads them to the database. The tables
--              are updated with the timestamp passed. This API
--              will process the file until the EOF is reached,
--              a parse error is encountered, or when data for
--              a different business object is read from the file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_index : IN OUT required
--                  Index of PL/SQL file to be processed.
--              p_loader_timestamp : IN required
--                  The timestamp to be used when creating or updating
--                  records
--              p_line_num : IN optional
--                  The first line number in the file to be processed.
--                  It is used for keeping track of the line number
--                  read so that this info can be included in the
--                  error message when a parse error occurred.
--              p_buffer : IN required
--                  The content of the first line to be processed.
--                  The calling API has already read the first line
--                  that needs to be parsed by this API, so this
--                  line won't be read from the file again.
--              p_line_num_out : OUT
--                  The number of the last line in the loader file
--                  that is read by this API.
--              p_buffer_out : OUT
--                  The content of the last line read by this API.
--                  If an EOF has not reached, this line would
--                  contain the beginning of another business object
--                  that will need to be processed by another API.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD_OBJECT (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_index                    IN OUT NOCOPY  NUMBER,
  p_loader_timestamp         IN      DATE,
  p_line_num                 IN NUMBER := FND_API.G_MISS_NUM,
  p_buffer                   IN AK_ON_OBJECTS_PUB.Buffer_Type,
  p_line_num_out             OUT NOCOPY    NUMBER,
  p_buffer_out               OUT NOCOPY    AK_ON_OBJECTS_PUB.Buffer_Type,
  p_upl_loader_cur           IN OUT NOCOPY  AK_ON_OBJECTS_PUB.LoaderCurTyp,
  p_pass                     IN      NUMBER := 1
) is
  l_api_version_number       CONSTANT number := 1.0;
  l_api_name                 CONSTANT varchar2(30) := 'Upload_Object';
  l_attribute_index          NUMBER := 0;
  l_attribute_rec            AK_OBJECT_PUB.Object_Attribute_Rec_Type;
  l_attribute_tbl            AK_OBJECT_PUB.Object_Attribute_Tbl_Type;
  l_attribute_value_index    NUMBER := 0;
  l_attribute_value_rec      AK_OBJECT_PUB.Attribute_Value_Rec_Type;
  l_attribute_value_tbl      AK_OBJECT_PUB.Attribute_Value_Tbl_Type;
  l_buffer                   AK_ON_OBJECTS_PUB.Buffer_Type;
  l_column  	             varchar2(30);
  l_dummy                    NUMBER;
  l_eof_flag                 VARCHAR2(1);
  l_foreign_key_index        NUMBER := 0;
  l_foreign_key_rec          AK_KEY_PUB.Foreign_Key_Rec_Type;
  l_foreign_key_tbl          AK_KEY_PUB.Foreign_Key_Tbl_Type;
  l_foreign_key_column_index NUMBER := 0;
  l_foreign_key_column_rec   AK_KEY_PUB.Foreign_Key_Column_Rec_Type;
  l_foreign_key_column_tbl   AK_KEY_PUB.Foreign_Key_Column_Tbl_Type;
  l_index                    NUMBER;
  l_language                 VARCHAR2(30);
  l_line_num                 NUMBER;
  l_lines_read               NUMBER;
  l_more_object              BOOLEAN := TRUE;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_navigation_index         NUMBER := 0;
  l_navigation_rec           AK_OBJECT_PUB.Attribute_Nav_Rec_Type;
  l_navigation_tbl           AK_OBJECT_PUB.Attribute_Nav_Tbl_Type;
  l_object_index             NUMBER := 0;
  l_object_rec               AK_OBJECT_PUB.Object_Rec_Type;
  l_object_tbl               AK_OBJECT_PUB.Object_Tbl_Type;
  l_unique_key_index         NUMBER := 0;
  l_unique_key_rec           AK_KEY_PUB.Unique_Key_Rec_Type;
  l_unique_key_tbl           AK_KEY_PUB.Unique_Key_Tbl_Type;
  l_unique_key_column_index  NUMBER := 0;
  l_unique_key_column_rec    AK_KEY_PUB.Unique_Key_Column_Rec_Type;
  l_unique_key_column_tbl    AK_KEY_PUB.Unique_Key_Column_Tbl_Type;
  l_saved_token              AK_ON_OBJECTS_PUB.Buffer_Type;
  l_state                    NUMBER;
  l_return_status            varchar2(1);
  l_token                    AK_ON_OBJECTS_PUB.Buffer_Type;
  l_value_count              NUMBER;  -- # of values read for current column
  l_copy_redo_flag           BOOLEAN := FALSE;
  l_user_id1				 NUMBER;
  l_user_id2				 NUMBER;
  l_update1				DATE;
  l_update2				DATE;
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- dbms_output.put_line('Started object upload: ' ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

  SAVEPOINT Start_Upload;

  -- Retrieve the first non-blank, non-comment line
  l_state := 0;
  l_eof_flag := 'N';

  --
  -- if calling from ak_on_objects.upload (ie, loader timestamp is given),
  -- the tokens 'BEGIN OBJECT' has already been parsed. Set initial
  -- buffer to 'BEGIN OBJECT' before reading the next line from the
  -- file. Otherwise, set initial buffer to null.
  --
  if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
    l_buffer := 'BEGIN OBJECT ' || p_buffer;
  else
    l_buffer := null;
  end if;

  if (p_line_num = FND_API.G_MISS_NUM) then
    l_line_num := 0;
  else
    l_line_num := p_line_num;
  end if;

  while (l_buffer is null and l_eof_flag = 'N' and p_index <= AK_ON_OBJECTS_PVT.G_UPL_TABLE_NUM) loop
      AK_ON_OBJECTS_PVT.READ_LINE (
        p_return_status => l_return_status,
        p_index => p_index,
        p_buffer => l_buffer,
        p_lines_read => l_lines_read,
        p_eof_flag => l_eof_flag,
		p_upl_loader_cur => p_upl_loader_cur
      );
      if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
         (l_return_status = FND_API.G_RET_STS_ERROR) then
		  --dbms_output.put_line('Error from UPLOAD_OBJECT after READ_LINE');
          RAISE FND_API.G_EXC_ERROR;
      end if;
      l_line_num := l_line_num + l_lines_read;
      --
      -- trim leading spaces and discard comment lines
      --
      l_buffer := LTRIM(l_buffer);
      if (SUBSTR(l_buffer, 1, 1) = '#') then
        l_buffer := null;
      end if;
  end loop;

  --
  -- Error if there is nothing to be read from the file
  --
  if (l_buffer is null and l_eof_flag = 'Y') then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_EMPTY_BUFFER');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Read tokens from file, one at a time

  while (l_eof_flag = 'N') and (l_buffer is not null)
        and (l_more_object) loop

    AK_ON_OBJECTS_PVT.GET_TOKEN(
      p_return_status => l_return_status,
      p_in_buf => l_buffer,
      p_token => l_token
    );

   --dbms_output.put_line(' State:' || to_char(l_state) || ' Token:' || l_token);
    if (l_return_status = FND_API.G_RET_STS_ERROR) or
       (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_GET_TOKEN_ERROR');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || 'Error parsing buffer');
      raise FND_API.G_EXC_ERROR;
    end if;

	    --****     OBJECT processing (states 0 - 19)     ****

    if (l_state = 0) then
      if (l_token = 'BEGIN') then
        --== Clear out previous column data  ==--
	l_object_rec := AK_OBJECT_PUB.G_MISS_OBJECT_REC;
        l_state := 1;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','BEGIN');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting BEGIN');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 1) then
      if (l_token = 'OBJECT') then
        l_state := 2;
      else
        -- Found the beginning of a non-object object,
        -- rebuild last line and pass it back to the caller
        -- (ak_on_objects_pvt.upload).
        p_buffer_out := 'BEGIN ' || l_token || ' ' || l_buffer;
        l_more_object := FALSE;
      end if;
    elsif (l_state = 2) then
      if (l_token is not null) then
        l_object_rec.database_object_name := l_token;
        l_value_count := null;
        l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','DATABASE_OBJECT_NAME');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting database object name');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 10) then
      if (l_token = 'BEGIN') then
        l_state := 13;
      elsif (l_token = 'END') then
        l_state := 19;
      elsif (l_token = 'NAME') or
            (l_token = 'DESCRIPTION') or
            (l_token = 'APPLICATION_ID') or
            (l_token = 'PRIMARY_KEY_NAME') or
            (l_token = 'DEFAULTING_API_PKG') or
            (l_token = 'DEFAULTING_API_PROC') or
            (l_token = 'VALIDATION_API_PKG') or
            (l_token = 'VALIDATION_API_PROC') or
            (l_token = 'ATTRIBUTE_CATEGORY') or
            (l_token = 'ATTRIBUTE1') or
            (l_token = 'ATTRIBUTE2') or
            (l_token = 'ATTRIBUTE3') or
            (l_token = 'ATTRIBUTE4') or
            (l_token = 'ATTRIBUTE5') or
            (l_token = 'ATTRIBUTE6') or
            (l_token = 'ATTRIBUTE7') or
            (l_token = 'ATTRIBUTE8') or
            (l_token = 'ATTRIBUTE9') or
            (l_token = 'ATTRIBUTE10') or
            (l_token = 'ATTRIBUTE11') or
            (l_token = 'ATTRIBUTE12') or
            (l_token = 'ATTRIBUTE13') or
            (l_token = 'ATTRIBUTE14') or
            (l_token = 'ATTRIBUTE15') or
    	    (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 11;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_BEFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','OBJECT');
            FND_MSG_PUB.Add;
          end if;
        --dbms_output.put_line('Expecting object column name');
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 11) then
      if (l_token = '=') then
        l_state := 12;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 12) then
      l_value_count := 1;
      if (l_column = 'NAME') then
         l_object_rec.name := l_token;
      elsif (l_column = 'DESCRIPTION') then
         l_object_rec.description := l_token;
      elsif (l_column = 'APPLICATION_ID') then
         l_object_rec.application_id := to_number(l_token);
      elsif (l_column = 'PRIMARY_KEY_NAME') then
         l_object_rec.primary_key_name := l_token;
      elsif (l_column = 'DEFAULTING_API_PKG') then
         l_object_rec.defaulting_api_pkg := l_token;
      elsif (l_column = 'DEFAULTING_API_PROC') then
         l_object_rec.defaulting_api_proc := l_token;
      elsif (l_column = 'VALIDATION_API_PKG') then
         l_object_rec.validation_api_pkg := l_token;
      elsif (l_column = 'VALIDATION_API_PROC') then
         l_object_rec.validation_api_proc := l_token;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_object_rec.attribute_category := l_token;
      elsif (l_column = 'ATTRIBUTE1') then
         l_object_rec.attribute1 := l_token;
      elsif (l_column = 'ATTRIBUTE2') then
         l_object_rec.attribute2 := l_token;
      elsif (l_column = 'ATTRIBUTE3') then
         l_object_rec.attribute3 := l_token;
      elsif (l_column = 'ATTRIBUTE4') then
         l_object_rec.attribute4 := l_token;
      elsif (l_column = 'ATTRIBUTE5') then
         l_object_rec.attribute5 := l_token;
      elsif (l_column = 'ATTRIBUTE6') then
         l_object_rec.attribute6 := l_token;
      elsif (l_column = 'ATTRIBUTE7') then
         l_object_rec.attribute7 := l_token;
      elsif (l_column = 'ATTRIBUTE8') then
         l_object_rec.attribute8 := l_token;
      elsif (l_column = 'ATTRIBUTE9') then
         l_object_rec.attribute9 := l_token;
      elsif (l_column = 'ATTRIBUTE10') then
         l_object_rec.attribute10 := l_token;
      elsif (l_column = 'ATTRIBUTE11') then
         l_object_rec.attribute11 := l_token;
      elsif (l_column = 'ATTRIBUTE12') then
         l_object_rec.attribute12 := l_token;
      elsif (l_column = 'ATTRIBUTE13') then
         l_object_rec.attribute13 := l_token;
      elsif (l_column = 'ATTRIBUTE14') then
         l_object_rec.attribute14 := l_token;
      elsif (l_column = 'ATTRIBUTE15') then
         l_object_rec.attribute15 := l_token;
      elsif (l_column = 'CREATED_BY') then
         l_object_rec.created_by := to_number(l_token);
      elsif (l_column = 'CREATION_DATE') then
         l_object_rec.creation_date := to_date(l_token,
					AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_object_rec.last_updated_by := to_number(l_token);
      elsif (l_column = 'OWNER') then
         l_object_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_object_rec.last_update_date := to_date(l_token,
                                       AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_object_rec.last_update_login := to_number(l_token);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 10;
    elsif (l_state = 13) then
      if (l_token = 'OBJECT_ATTRIBUTE') then
        l_state := 100;
      elsif (l_token = 'UNIQUE_KEY') then
        l_state := 200;
      elsif (l_token = 'FOREIGN_KEY') then
        l_state := 300;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','OBJECT_ATTRIBUTE, UNIQUE_KEY, ' ||
                                           'FOREIGN_KEY');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting OBJECT_ATTRIBUTE, UNIQUE_KEY, or ' ||
        --                     'FOREIGN_KEY');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 19) then
      if (l_token = 'OBJECT') then
        l_state := 0;
        l_object_index := l_object_index + 1;
        l_object_tbl(l_object_index) := l_object_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'OBJECT');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     OBJECT_ATTRIBUTE processing (states 100 - 119)     ****

    elsif (l_state = 100) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
	l_attribute_rec := AK_OBJECT_PUB.G_MISS_OBJECT_ATTRIBUTE_REC;
        l_attribute_rec.attribute_appl_id := to_number(l_token);
        l_state := 101;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting attribute application ID');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 101) then
      if (l_token is not null) then
        l_attribute_rec.attribute_code := l_token;
        l_value_count := null;
        l_state := 110;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting attribute code');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 110) then
      if (l_token = 'BEGIN') then
        l_state := 113;
      elsif (l_token = 'END') then
        l_state := 119;
      elsif (l_token = 'COLUMN_NAME') or
            (l_token = 'ATTRIBUTE_LABEL_LENGTH') or
            (l_token = 'DISPLAY_VALUE_LENGTH') or
            (l_token = 'BOLD') or
            (l_token = 'ITALIC') or
            (l_token = 'VERTICAL_ALIGNMENT') or
            (l_token = 'HORIZONTAL_ALIGNMENT') or
            (l_token = 'DATA_SOURCE_TYPE') or
            (l_token = 'DATA_STORAGE_TYPE') or
            (l_token = 'TABLE_NAME') or
            (l_token = 'BASE_TABLE_COLUMN_NAME') or
            (l_token = 'REQUIRED_FLAG') or
            (l_token = 'DEFAULT_VALUE_VARCHAR2') or
            (l_token = 'DEFAULT_VALUE_NUMBER') or
            (l_token = 'DEFAULT_VALUE_DATE') or
            (l_token = 'LOV_REGION') or
            (l_token = 'LOV_FOREIGN_KEY_NAME') or
            (l_token = 'LOV_ATTRIBUTE') or
            (l_token = 'DEFAULTING_API_PKG') or
            (l_token = 'DEFAULTING_API_PROC') or
            (l_token = 'VALIDATION_API_PKG') or
            (l_token = 'VALIDATION_API_PROC') or
			(l_token = 'ATTRIBUTE_CATEGORY') or
			(l_token = 'ATTRIBUTE1') or
			(l_token = 'ATTRIBUTE2') or
			(l_token = 'ATTRIBUTE3') or
			(l_token = 'ATTRIBUTE4') or
			(l_token = 'ATTRIBUTE5') or
			(l_token = 'ATTRIBUTE6') or
			(l_token = 'ATTRIBUTE7') or
			(l_token = 'ATTRIBUTE8') or
			(l_token = 'ATTRIBUTE9') or
			(l_token = 'ATTRIBUTE10') or
			(l_token = 'ATTRIBUTE11') or
			(l_token = 'ATTRIBUTE12') or
			(l_token = 'ATTRIBUTE13') or
			(l_token = 'ATTRIBUTE14') or
			(l_token = 'ATTRIBUTE15') or
            (l_token = 'ATTRIBUTE_LABEL_LONG') or
            (l_token = 'ATTRIBUTE_LABEL_SHORT') or
            (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 111;
      else
        --
        -- error if not expecting attribute values added by the translation
        -- team or if we have read in more than a certain number of values
        -- for the same DB column
        --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_BEFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','OBJECT_ATTRIBUTE');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 111) then
      if (l_token = '=') then
        l_state := 112;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
		  --dbms_output.put_line('Error: Expected = ');
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 112) then
      l_value_count := 1;
      if (l_column = 'COLUMN_NAME') then
         l_attribute_rec.column_name := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE_LABEL_LENGTH') then
         l_attribute_rec.attribute_label_length := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'DISPLAY_VALUE_LENGTH') then
         l_attribute_rec.display_value_length := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'BOLD') then
         l_attribute_rec.bold := l_token;
         l_state := 110;
      elsif (l_column = 'ITALIC') then
         l_attribute_rec.italic := l_token;
         l_state := 110;
      elsif (l_column = 'VERTICAL_ALIGNMENT') then
         l_attribute_rec.vertical_alignment := l_token;
         l_state := 110;
      elsif (l_column = 'HORIZONTAL_ALIGNMENT') then
         l_attribute_rec.horizontal_alignment := l_token;
         l_state := 110;
      elsif (l_column = 'DATA_SOURCE_TYPE') then
         l_attribute_rec.data_source_type := l_token;
         l_state := 110;
      elsif (l_column = 'DATA_STORAGE_TYPE') then
         l_attribute_rec.data_storage_type := l_token;
         l_state := 110;
      elsif (l_column = 'TABLE_NAME') then
         l_attribute_rec.table_name := l_token;
         l_state := 110;
      elsif (l_column = 'BASE_TABLE_COLUMN_NAME') then
         l_attribute_rec.base_table_column_name := l_token;
         l_state := 110;
      elsif (l_column = 'REQUIRED_FLAG') then
         l_attribute_rec.required_flag := l_token;
         l_state := 110;
      elsif (l_column = 'DEFAULT_VALUE_VARCHAR2') then
         l_attribute_rec.default_value_varchar2 := l_token;
         l_state := 110;
      elsif (l_column = 'DEFAULT_VALUE_NUMBER') then
         l_attribute_rec.default_value_number := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'DEFAULT_VALUE_DATE') then
         l_attribute_rec.default_value_date := to_date(l_token,
                                               AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 110;
      elsif (l_column = 'LOV_REGION') then
         l_attribute_rec.lov_region_application_id := to_number(l_token);
         l_state := 114;
      elsif (l_column = 'LOV_FOREIGN_KEY_NAME') then
         l_attribute_rec.lov_foreign_key_name := l_token;
         l_state := 110;
      elsif (l_column = 'LOV_ATTRIBUTE') then
         l_attribute_rec.lov_attribute_application_id := to_number(l_token);
         l_state := 114;
      elsif (l_column = 'DEFAULTING_API_PKG') then
         l_attribute_rec.defaulting_api_pkg := l_token;
         l_state := 110;
      elsif (l_column = 'DEFAULTING_API_PROC') then
         l_attribute_rec.defaulting_api_proc := l_token;
         l_state := 110;
      elsif (l_column = 'VALIDATION_API_PKG') then
         l_attribute_rec.validation_api_pkg := l_token;
         l_state := 110;
      elsif (l_column = 'VALIDATION_API_PROC') then
         l_attribute_rec.validation_api_proc := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_attribute_rec.attribute_category := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE1') then
         l_attribute_rec.attribute1 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE2') then
         l_attribute_rec.attribute2 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE3') then
         l_attribute_rec.attribute3 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE4') then
         l_attribute_rec.attribute4 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE5') then
         l_attribute_rec.attribute5 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE6') then
         l_attribute_rec.attribute6 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE7') then
         l_attribute_rec.attribute7 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE8') then
         l_attribute_rec.attribute8 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE9') then
         l_attribute_rec.attribute9 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE10') then
         l_attribute_rec.attribute10 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE11') then
         l_attribute_rec.attribute11 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE12') then
         l_attribute_rec.attribute12 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE13') then
         l_attribute_rec.attribute13 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE14') then
         l_attribute_rec.attribute14 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE15') then
         l_attribute_rec.attribute15 := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE_LABEL_LONG') then
         l_attribute_rec.attribute_label_long := l_token;
         l_state := 110;
      elsif (l_column = 'ATTRIBUTE_LABEL_SHORT') then
         l_attribute_rec.attribute_label_short := l_token;
         l_state := 110;
      elsif (l_column = 'CREATED_BY') then
         l_attribute_rec.created_by := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'CREATION_DATE') then
         l_attribute_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 110;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_attribute_rec.last_updated_by := to_number(l_token);
         l_state := 110;
      elsif (l_column = 'OWNER') then
         l_attribute_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 110;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_attribute_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 110;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_attribute_rec.last_update_login := to_number(l_token);
         l_state := 110;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 113) then
      if (l_token = 'ATTRIBUTE_VALUE') then
        l_state := 120;
      elsif (l_token = 'ATTRIBUTE_NAVIGATION') then
        l_state := 140;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_VALUE, ' ||
                                           'ATTRIBUTE_NAVIGATION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 114) then
      if (l_column = 'LOV_REGION') then
         l_attribute_rec.lov_region_code := l_token;
      elsif (l_column = 'LOV_ATTRIBUTE') then
         l_attribute_rec.lov_attribute_code := l_token;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
	  l_state := 110;
    elsif (l_state = 119) then
      if (l_token = 'OBJECT_ATTRIBUTE') then
        l_value_count := null;
        l_state := 10;
        l_attribute_rec.database_object_name :=
                                         l_object_rec.database_object_name;
        l_attribute_index := l_attribute_index + 1;
        l_attribute_tbl(l_attribute_index) := l_attribute_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'OBJECT_ATTRIBUTE');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting OBJECT_ATTRIBUTE');
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     ATTRIBUTE_VALUE processing (states 120 - 139)     ****

    elsif (l_state = 120) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
        l_attribute_value_rec := AK_OBJECT_PUB.G_MISS_ATTRIBUTE_VALUE_REC;
        l_attribute_value_rec.key_value1 := l_token;
        l_state := 121;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'key_value1');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting key_value1');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 121) then
      l_attribute_value_rec.key_value2 := l_token;
      l_state := 122;
    elsif (l_state = 122) then
      l_attribute_value_rec.key_value3 := l_token;
      l_state := 123;
    elsif (l_state = 123) then
      l_attribute_value_rec.key_value4 := l_token;
      l_state := 124;
    elsif (l_state = 124) then
      l_attribute_value_rec.key_value5 := l_token;
      l_state := 125;
    elsif (l_state = 125) then
      l_attribute_value_rec.key_value6 := l_token;
      l_state := 126;
    elsif (l_state = 126) then
      l_attribute_value_rec.key_value7 := l_token;
      l_state := 127;
    elsif (l_state = 127) then
      l_attribute_value_rec.key_value8 := l_token;
      l_state := 128;
    elsif (l_state = 128) then
      l_attribute_value_rec.key_value9 := l_token;
      l_state := 129;
    elsif (l_state = 129) then
      l_attribute_value_rec.key_value10 := l_token;
      l_value_count := null;
      l_state := 130;
    elsif (l_state = 130) then
      if (l_token = 'END') then
        l_state := 139;
      elsif (l_token = 'VALUE') then
        l_column := l_token;
        l_state := 131;
      else
        --
        -- error if not expecting attribute values added by the translation
        -- team or if we have read in more than a certain number of values
        -- for the same DB column
        --
        l_value_count := l_value_count + 1;
        --dbms_output.put_line('Expecting attribute value field, or END');
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_VALUE');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 131) then
      if (l_token = '=') then
        l_state := 132;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 132) then
      l_value_count := 1;
      if (l_column = 'VALUE') then
         l_attribute_value_rec.value_varchar2:= l_token;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 134;
    elsif (l_state = 134) then
      if (l_column = 'VALUE') then
         l_attribute_value_rec.value_date:= to_date(l_token,
                                            AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 135;
    elsif (l_state = 135) then
      if (l_column = 'VALUE') then
         l_attribute_value_rec.value_number:= to_number(l_token);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 130;
    elsif (l_state = 139) then
      if (l_token = 'ATTRIBUTE_VALUE') then
        l_value_count := null;
        l_state := 110;
        l_attribute_value_rec.database_object_name :=
                                   l_object_rec.database_object_name;
        l_attribute_value_rec.attribute_appl_id :=
                                   l_attribute_rec.attribute_appl_id;
        l_attribute_value_rec.attribute_code :=
                                   l_attribute_rec.attribute_code;
        l_attribute_value_index := l_attribute_value_index + 1;
        l_attribute_value_tbl(l_attribute_value_index) := l_attribute_value_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_VALUE');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ATTRIBUTE_VALUE');
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     ATTRIBUTE_NAVIGATION processing (states 140 - 159)     ****

    -- Attribute_navigation is a special case: it's "key" value
    -- can be null, so the usual check for non-null token does
    -- not apply here in state 140.
    elsif (l_state = 140) then
      --== Clear out previous data  ==--
      l_navigation_rec := AK_OBJECT_PUB.G_MISS_ATTRIBUTE_NAV_REC;
      l_navigation_rec.value_varchar2 := l_token;
      l_state := 141;
    elsif (l_state = 141) then
      l_navigation_rec.value_date := to_date(l_token,
                                             AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      l_state := 142;
    elsif (l_state = 142) then
      l_navigation_rec.value_number := to_number(l_token);
      l_value_count := null;
      l_state := 150;
    elsif (l_state = 150) then
      if (l_token = 'END') then
        l_state := 159;
      elsif (l_token = 'TO_REGION') or
			(l_token = 'ATTRIBUTE_CATEGORY') or
			(l_token = 'ATTRIBUTE1') or
			(l_token = 'ATTRIBUTE2') or
			(l_token = 'ATTRIBUTE3') or
			(l_token = 'ATTRIBUTE4') or
			(l_token = 'ATTRIBUTE5') or
			(l_token = 'ATTRIBUTE6') or
			(l_token = 'ATTRIBUTE7') or
			(l_token = 'ATTRIBUTE8') or
			(l_token = 'ATTRIBUTE9') or
			(l_token = 'ATTRIBUTE10') or
			(l_token = 'ATTRIBUTE11') or
			(l_token = 'ATTRIBUTE12') or
			(l_token = 'ATTRIBUTE13') or
			(l_token = 'ATTRIBUTE14') or
			(l_token = 'ATTRIBUTE15') or
            (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 151;
      else
        --
        -- error if not expecting attribute values added by the translation
        -- team or if we have read in more than a certain number of values
        -- for the same DB column
        --
        l_value_count := l_value_count + 1;
        --dbms_output.put_line('Expecting attribute navigation field, or END');
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_NAVIGATION');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 151) then
      if (l_token = '=') then
        l_state := 152;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 152) then
      l_value_count := 1;
      if (l_column = 'TO_REGION') then
         l_navigation_rec.to_region_appl_id := to_number(l_token);
         l_state := 154;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_navigation_rec.attribute_category := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE1') then
         l_navigation_rec.attribute1 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE2') then
         l_navigation_rec.attribute2 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE3') then
         l_navigation_rec.attribute3 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE4') then
         l_navigation_rec.attribute4 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE5') then
         l_navigation_rec.attribute5 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE6') then
         l_navigation_rec.attribute6 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE7') then
         l_navigation_rec.attribute7 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE8') then
         l_navigation_rec.attribute8 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE9') then
         l_navigation_rec.attribute9 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE10') then
         l_navigation_rec.attribute10 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE11') then
         l_navigation_rec.attribute11 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE12') then
         l_navigation_rec.attribute12 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE13') then
         l_navigation_rec.attribute13 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE14') then
         l_navigation_rec.attribute14 := l_token;
         l_state := 150;
      elsif (l_column = 'ATTRIBUTE15') then
         l_navigation_rec.attribute15 := l_token;
         l_state := 150;
      elsif (l_column = 'CREATED_BY') then
         l_navigation_rec.created_by := to_number(l_token);
         l_state := 150;
      elsif (l_column = 'CREATION_DATE') then
         l_navigation_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 150;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_navigation_rec.last_updated_by := to_number(l_token);
         l_state := 150;
      elsif (l_column = 'OWNER') then
         l_navigation_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 150;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_navigation_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 150;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_navigation_rec.last_update_login := to_number(l_token);
         l_state := 150;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 154) then
      if (l_column = 'TO_REGION') then
         l_navigation_rec.to_region_code := l_token;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 150;
    elsif (l_state = 159) then
      if (l_token = 'ATTRIBUTE_NAVIGATION') then
        l_value_count := null;
        l_state := 110;
        l_navigation_rec.database_object_name :=
                                         l_object_rec.database_object_name;
        l_navigation_rec.attribute_appl_id := l_attribute_rec.attribute_appl_id;
        l_navigation_rec.attribute_code := l_attribute_rec.attribute_code;
        l_navigation_index := l_navigation_index + 1;
        l_navigation_tbl(l_navigation_index) := l_navigation_rec;
 --dbms_output.put_line('Uploaded Navigation:' || l_navigation_rec.value_varchar2 || to_char(l_navigation_rec.value_number) || to_char(l_navigation_rec.value_date));
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_NAVIGATION');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ATTRIBUTE_NAVIGATION');
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     UNIQUE_KEY processing (states 200 - 219)     ****

    elsif (l_state = 200) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
        l_unique_key_rec := AK_KEY_PUB.G_MISS_UNIQUE_KEY_REC;
        l_unique_key_rec.unique_key_name := l_token;
        l_value_count := null;
        l_state := 210;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'UNIQUE_KEY_NAME');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting unique_key_name');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 210) then
      if (l_token = 'END') then
        l_state := 219;
      elsif (l_token = 'BEGIN') then
        l_state := 213;
      elsif (l_token = 'APPLICATION_ID') or
			(l_token = 'ATTRIBUTE_CATEGORY') or
			(l_token = 'ATTRIBUTE1') or
			(l_token = 'ATTRIBUTE2') or
			(l_token = 'ATTRIBUTE3') or
			(l_token = 'ATTRIBUTE4') or
			(l_token = 'ATTRIBUTE5') or
			(l_token = 'ATTRIBUTE6') or
			(l_token = 'ATTRIBUTE7') or
			(l_token = 'ATTRIBUTE8') or
			(l_token = 'ATTRIBUTE9') or
			(l_token = 'ATTRIBUTE10') or
			(l_token = 'ATTRIBUTE11') or
			(l_token = 'ATTRIBUTE12') or
			(l_token = 'ATTRIBUTE13') or
			(l_token = 'ATTRIBUTE14') or
			(l_token = 'ATTRIBUTE15') or
            (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 211;
      else
        --
        -- error if not expecting attribute values added by the translation
        -- team or if we have read in more than a certain number of values
        -- for the same DB column
        --
        l_value_count := l_value_count + 1;
        --dbms_output.put_line('Expecting unique key field, or END');
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_BEFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','UNIQUE_KEY');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 211) then
      if (l_token = '=') then
        l_state := 212;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 212) then
      l_value_count := 1;
      if (l_column = 'APPLICATION_ID') then
         l_unique_key_rec.application_id := to_number(l_token);
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_unique_key_rec.attribute_category := l_token;
      elsif (l_column = 'ATTRIBUTE1') then
         l_unique_key_rec.attribute1 := l_token;
      elsif (l_column = 'ATTRIBUTE2') then
         l_unique_key_rec.attribute2 := l_token;
      elsif (l_column = 'ATTRIBUTE3') then
         l_unique_key_rec.attribute3 := l_token;
      elsif (l_column = 'ATTRIBUTE4') then
         l_unique_key_rec.attribute4 := l_token;
      elsif (l_column = 'ATTRIBUTE5') then
         l_unique_key_rec.attribute5 := l_token;
      elsif (l_column = 'ATTRIBUTE6') then
         l_unique_key_rec.attribute6 := l_token;
      elsif (l_column = 'ATTRIBUTE7') then
         l_unique_key_rec.attribute7 := l_token;
      elsif (l_column = 'ATTRIBUTE8') then
         l_unique_key_rec.attribute8 := l_token;
      elsif (l_column = 'ATTRIBUTE9') then
         l_unique_key_rec.attribute9 := l_token;
      elsif (l_column = 'ATTRIBUTE10') then
         l_unique_key_rec.attribute10 := l_token;
      elsif (l_column = 'ATTRIBUTE11') then
         l_unique_key_rec.attribute11 := l_token;
      elsif (l_column = 'ATTRIBUTE12') then
         l_unique_key_rec.attribute12 := l_token;
      elsif (l_column = 'ATTRIBUTE13') then
         l_unique_key_rec.attribute13 := l_token;
      elsif (l_column = 'ATTRIBUTE14') then
         l_unique_key_rec.attribute14 := l_token;
      elsif (l_column = 'ATTRIBUTE15') then
         l_unique_key_rec.attribute15 := l_token;
      elsif (l_column = 'CREATED_BY') then
         l_unique_key_rec.created_by := to_number(l_token);
      elsif (l_column = 'CREATION_DATE') then
         l_unique_key_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_unique_key_rec.last_updated_by := to_number(l_token);
      elsif (l_column = 'OWNER') then
         l_unique_key_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_unique_key_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_unique_key_rec.last_update_login := to_number(l_token);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 210;
    elsif (l_state = 213) then
      if (l_token = 'UNIQUE_KEY_COLUMN') then
        l_state := 220;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'UNIQUE_KEY_COLUMN');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting UNIQUE_KEY_COLUMN');
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 219) then
      if (l_token = 'UNIQUE_KEY') then
        l_value_count := null;
        l_state := 10;
        l_unique_key_rec.database_object_name := l_object_rec.database_object_name;
        l_unique_key_index := l_unique_key_index + 1;
        l_unique_key_tbl(l_unique_key_index) := l_unique_key_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'UNIQUE_KEY');
          FND_MSG_PUB.Add;
        end if;
        --dbms_output.put_line('Expecting UNIQUE_KEY');
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     UNIQUE_KEY_COLUMN processing (states 220 - 239)     ****

    elsif (l_state = 220) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
        l_unique_key_column_rec := AK_KEY_PUB.G_MISS_UNIQUE_KEY_COLUMN_REC;
        l_unique_key_column_rec.attribute_application_id := to_number(l_token);
        l_state := 221;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 221) then
      if (l_token is not null) then
        l_unique_key_column_rec.attribute_code := l_token;
        l_value_count := null;
        l_state := 230;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 230) then
      if (l_token = 'END') then
        l_state := 239;
      elsif (l_token = 'UNIQUE_KEY_SEQUENCE') or
			(l_token = 'ATTRIBUTE_CATEGORY') or
			(l_token = 'ATTRIBUTE1') or
			(l_token = 'ATTRIBUTE2') or
			(l_token = 'ATTRIBUTE3') or
			(l_token = 'ATTRIBUTE4') or
			(l_token = 'ATTRIBUTE5') or
			(l_token = 'ATTRIBUTE6') or
			(l_token = 'ATTRIBUTE7') or
			(l_token = 'ATTRIBUTE8') or
			(l_token = 'ATTRIBUTE9') or
			(l_token = 'ATTRIBUTE10') or
			(l_token = 'ATTRIBUTE11') or
			(l_token = 'ATTRIBUTE12') or
			(l_token = 'ATTRIBUTE13') or
			(l_token = 'ATTRIBUTE14') or
			(l_token = 'ATTRIBUTE15') or
            (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 231;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --dbms_output.put_line('Expecting unique key column field, or END');
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','UNIQUE_KEY_COLUMN');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 231) then
      if (l_token = '=') then
        l_state := 232;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 232) then
      l_value_count := 1;
      if (l_column = 'UNIQUE_KEY_SEQUENCE') then
         l_unique_key_column_rec.unique_key_sequence := to_number(l_token);
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_unique_key_column_rec.attribute_category := l_token;
      elsif (l_column = 'ATTRIBUTE1') then
         l_unique_key_column_rec.attribute1 := l_token;
      elsif (l_column = 'ATTRIBUTE2') then
         l_unique_key_column_rec.attribute2 := l_token;
      elsif (l_column = 'ATTRIBUTE3') then
         l_unique_key_column_rec.attribute3 := l_token;
      elsif (l_column = 'ATTRIBUTE4') then
         l_unique_key_column_rec.attribute4 := l_token;
      elsif (l_column = 'ATTRIBUTE5') then
         l_unique_key_column_rec.attribute5 := l_token;
      elsif (l_column = 'ATTRIBUTE6') then
         l_unique_key_column_rec.attribute6 := l_token;
      elsif (l_column = 'ATTRIBUTE7') then
         l_unique_key_column_rec.attribute7 := l_token;
      elsif (l_column = 'ATTRIBUTE8') then
         l_unique_key_column_rec.attribute8 := l_token;
      elsif (l_column = 'ATTRIBUTE9') then
         l_unique_key_column_rec.attribute9 := l_token;
      elsif (l_column = 'ATTRIBUTE10') then
         l_unique_key_column_rec.attribute10 := l_token;
      elsif (l_column = 'ATTRIBUTE11') then
         l_unique_key_column_rec.attribute11 := l_token;
      elsif (l_column = 'ATTRIBUTE12') then
         l_unique_key_column_rec.attribute12 := l_token;
      elsif (l_column = 'ATTRIBUTE13') then
         l_unique_key_column_rec.attribute13 := l_token;
      elsif (l_column = 'ATTRIBUTE14') then
         l_unique_key_column_rec.attribute14 := l_token;
      elsif (l_column = 'ATTRIBUTE15') then
         l_unique_key_column_rec.attribute15 := l_token;
      elsif (l_column = 'CREATED_BY') then
         l_unique_key_column_rec.created_by := to_number(l_token);
      elsif (l_column = 'CREATION_DATE') then
         l_unique_key_column_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_unique_key_column_rec.last_updated_by := to_number(l_token);
      elsif (l_column = 'OWNER') then
         l_unique_key_column_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_unique_key_column_rec.last_update_date := to_date(l_token,
                                       AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_unique_key_column_rec.last_update_login := to_number(l_token);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
         --dbms_output.put_line('Expecting ' || l_column || ' value');
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 230;
    elsif (l_state = 239) then
      if (l_token = 'UNIQUE_KEY_COLUMN') then
        l_value_count := null;
        l_state := 210;
        l_unique_key_column_rec.unique_key_name :=
                                    l_unique_key_rec.unique_key_name;
        l_unique_key_column_index := l_unique_key_column_index + 1;
        l_unique_key_column_tbl(l_unique_key_column_index) :=
                                        l_unique_key_column_rec;
--dbms_output.put_line('Downloaded unique key name:' || l_unique_key_column_rec.unique_key_name);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'UNIQUE_KEY_COLUMN');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     FOREIGN_KEY processing (states 300 - 319)     ****
    elsif (l_state = 300) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
        l_foreign_key_rec := AK_KEY_PUB.G_MISS_FOREIGN_KEY_REC;
        l_foreign_key_rec.foreign_key_name := l_token;
        l_value_count := null;
        l_state := 310;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FOREIGN_KEY_NAME');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 310) then
      if (l_token = 'END') then
        l_state := 319;
      elsif (l_token = 'BEGIN') then
        l_state := 313;
      elsif (l_token = 'APPLICATION_ID') or
            (l_token = 'UNIQUE_KEY_NAME') or
			(l_token = 'ATTRIBUTE_CATEGORY') or
			(l_token = 'ATTRIBUTE1') or
			(l_token = 'ATTRIBUTE2') or
			(l_token = 'ATTRIBUTE3') or
			(l_token = 'ATTRIBUTE4') or
			(l_token = 'ATTRIBUTE5') or
			(l_token = 'ATTRIBUTE6') or
			(l_token = 'ATTRIBUTE7') or
			(l_token = 'ATTRIBUTE8') or
			(l_token = 'ATTRIBUTE9') or
			(l_token = 'ATTRIBUTE10') or
			(l_token = 'ATTRIBUTE11') or
			(l_token = 'ATTRIBUTE12') or
			(l_token = 'ATTRIBUTE13') or
			(l_token = 'ATTRIBUTE14') or
			(l_token = 'ATTRIBUTE15') or
            (l_token = 'FROM_TO_NAME') or
            (l_token = 'FROM_TO_DESCRIPTION') or
            (l_token = 'TO_FROM_NAME') or
            (l_token = 'TO_FROM_DESCRIPTION') or
            (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 311;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
--        dbms_output.put_line('Expecting foreign key field, or END');
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_BEFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','FOREIGN_KEY');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 311) then
      if (l_token = '=') then
        l_state := 312;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 312) then
      l_value_count := 1;
      if (l_column = 'APPLICATION_ID') then
         l_foreign_key_rec.application_id := to_number(l_token);
      elsif (l_column = 'UNIQUE_KEY_NAME') then
         l_foreign_key_rec.unique_key_name := l_token;
      elsif (l_column = 'FROM_TO_NAME') then
         l_foreign_key_rec.from_to_name := l_token;
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_foreign_key_rec.attribute_category := l_token;
      elsif (l_column = 'ATTRIBUTE1') then
         l_foreign_key_rec.attribute1 := l_token;
      elsif (l_column = 'ATTRIBUTE2') then
         l_foreign_key_rec.attribute2 := l_token;
      elsif (l_column = 'ATTRIBUTE3') then
         l_foreign_key_rec.attribute3 := l_token;
      elsif (l_column = 'ATTRIBUTE4') then
         l_foreign_key_rec.attribute4 := l_token;
      elsif (l_column = 'ATTRIBUTE5') then
         l_foreign_key_rec.attribute5 := l_token;
      elsif (l_column = 'ATTRIBUTE6') then
         l_foreign_key_rec.attribute6 := l_token;
      elsif (l_column = 'ATTRIBUTE7') then
         l_foreign_key_rec.attribute7 := l_token;
      elsif (l_column = 'ATTRIBUTE8') then
         l_foreign_key_rec.attribute8 := l_token;
      elsif (l_column = 'ATTRIBUTE9') then
         l_foreign_key_rec.attribute9 := l_token;
      elsif (l_column = 'ATTRIBUTE10') then
         l_foreign_key_rec.attribute10 := l_token;
      elsif (l_column = 'ATTRIBUTE11') then
         l_foreign_key_rec.attribute11 := l_token;
      elsif (l_column = 'ATTRIBUTE12') then
         l_foreign_key_rec.attribute12 := l_token;
      elsif (l_column = 'ATTRIBUTE13') then
         l_foreign_key_rec.attribute13 := l_token;
      elsif (l_column = 'ATTRIBUTE14') then
         l_foreign_key_rec.attribute14 := l_token;
      elsif (l_column = 'ATTRIBUTE15') then
         l_foreign_key_rec.attribute15 := l_token;
      elsif (l_column = 'FROM_TO_DESCRIPTION') then
         l_foreign_key_rec.from_to_description := l_token;
      elsif (l_column = 'TO_FROM_NAME') then
         l_foreign_key_rec.to_from_name := l_token;
      elsif (l_column = 'TO_FROM_DESCRIPTION') then
         l_foreign_key_rec.to_from_description := l_token;
      elsif (l_column = 'CREATED_BY') then
         l_foreign_key_rec.created_by := to_number(l_token);
      elsif (l_column = 'CREATION_DATE') then
         l_foreign_key_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_foreign_key_rec.last_updated_by := to_number(l_token);
      elsif (l_column = 'OWNER') then
         l_foreign_key_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_foreign_key_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_foreign_key_rec.last_update_login := to_number(l_token);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column || ' value');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 310;
    elsif (l_state = 313) then
      if (l_token = 'FOREIGN_KEY_COLUMN') then
        l_state := 320;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FOREIGN_KEY_COLUMN');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 319) then
      if (l_token = 'FOREIGN_KEY') then
        l_value_count := null;
        l_state := 10;
        l_foreign_key_rec.database_object_name := l_object_rec.database_object_name;
        l_foreign_key_index := l_foreign_key_index + 1;
        l_foreign_key_tbl(l_foreign_key_index) := l_foreign_key_rec;
    --dbms_output.put_line('Upload foreign key:' || l_foreign_key_rec.foreign_key_name);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FOREIGN_KEY');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --****     FOREIGN_KEY_COLUMN processing (states 320 - 339)     ****
    elsif (l_state = 320) then
      if (l_token is not null) then
        --== Clear out previous data  ==--
        l_foreign_key_column_rec := AK_KEY_PUB.G_MISS_FOREIGN_KEY_COLUMN_REC;
        l_foreign_key_column_rec.attribute_application_id := to_number(l_token);
        l_state := 321;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_APPLICATION_ID');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 321) then
      if (l_token is not null) then
        l_foreign_key_column_rec.attribute_code := l_token;
        l_value_count := null;
        l_state := 330;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'ATTRIBUTE_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 330) then
      if (l_token = 'END') then
        l_state := 339;
      elsif (l_token = 'FOREIGN_KEY_SEQUENCE') or
			(l_token = 'ATTRIBUTE_CATEGORY') or
			(l_token = 'ATTRIBUTE1') or
			(l_token = 'ATTRIBUTE2') or
			(l_token = 'ATTRIBUTE3') or
			(l_token = 'ATTRIBUTE4') or
			(l_token = 'ATTRIBUTE5') or
			(l_token = 'ATTRIBUTE6') or
			(l_token = 'ATTRIBUTE7') or
			(l_token = 'ATTRIBUTE8') or
			(l_token = 'ATTRIBUTE9') or
			(l_token = 'ATTRIBUTE10') or
			(l_token = 'ATTRIBUTE11') or
			(l_token = 'ATTRIBUTE12') or
			(l_token = 'ATTRIBUTE13') or
			(l_token = 'ATTRIBUTE14') or
			(l_token = 'ATTRIBUTE15') or
            (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 331;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','FOREIGN_KEY_COLUMN');
            FND_MSG_PUB.Add;
          end if;
        raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 331) then
      if (l_token = '=') then
        l_state := 332;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 332) then
      l_value_count := 1;
      if (l_column = 'FOREIGN_KEY_SEQUENCE') then
         l_foreign_key_column_rec.foreign_key_sequence := to_number(l_token);
      elsif (l_column = 'ATTRIBUTE_CATEGORY') then
         l_foreign_key_column_rec.attribute_category := l_token;
      elsif (l_column = 'ATTRIBUTE1') then
         l_foreign_key_column_rec.attribute1 := l_token;
      elsif (l_column = 'ATTRIBUTE2') then
         l_foreign_key_column_rec.attribute2 := l_token;
      elsif (l_column = 'ATTRIBUTE3') then
         l_foreign_key_column_rec.attribute3 := l_token;
      elsif (l_column = 'ATTRIBUTE4') then
         l_foreign_key_column_rec.attribute4 := l_token;
      elsif (l_column = 'ATTRIBUTE5') then
         l_foreign_key_column_rec.attribute5 := l_token;
      elsif (l_column = 'ATTRIBUTE6') then
         l_foreign_key_column_rec.attribute6 := l_token;
      elsif (l_column = 'ATTRIBUTE7') then
         l_foreign_key_column_rec.attribute7 := l_token;
      elsif (l_column = 'ATTRIBUTE8') then
         l_foreign_key_column_rec.attribute8 := l_token;
      elsif (l_column = 'ATTRIBUTE9') then
         l_foreign_key_column_rec.attribute9 := l_token;
      elsif (l_column = 'ATTRIBUTE10') then
         l_foreign_key_column_rec.attribute10 := l_token;
      elsif (l_column = 'ATTRIBUTE11') then
         l_foreign_key_column_rec.attribute11 := l_token;
      elsif (l_column = 'ATTRIBUTE12') then
         l_foreign_key_column_rec.attribute12 := l_token;
      elsif (l_column = 'ATTRIBUTE13') then
         l_foreign_key_column_rec.attribute13 := l_token;
      elsif (l_column = 'ATTRIBUTE14') then
         l_foreign_key_column_rec.attribute14 := l_token;
      elsif (l_column = 'ATTRIBUTE15') then
         l_foreign_key_column_rec.attribute15 := l_token;
      elsif (l_column = 'CREATED_BY') then
         l_foreign_key_column_rec.created_by := to_number(l_token);
      elsif (l_column = 'CREATION_DATE') then
         l_foreign_key_column_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_foreign_key_column_rec.last_updated_by := to_number(l_token);
      elsif (l_column = 'OWNER') then
         l_foreign_key_column_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_foreign_key_column_rec.last_update_date := to_date(l_token,
                                       AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_foreign_key_column_rec.last_update_login := to_number(l_token);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 330;
    elsif (l_state = 339) then
      if (l_token = 'FOREIGN_KEY_COLUMN') then
        l_value_count := null;
        l_state := 310;
        l_foreign_key_column_rec.foreign_key_name :=
                                    l_foreign_key_rec.foreign_key_name;
        l_foreign_key_column_index := l_foreign_key_column_index + 1;
        l_foreign_key_column_tbl(l_foreign_key_column_index) :=
                                        l_foreign_key_column_rec;
--dbms_output.put_line('Downloaded foreign key column:' || l_foreign_key_column_rec.column_name);
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'FOREIGN_KEY_COLUMN');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    end if; /* if l_state = ... */

    -- Get rid of leading white spaces, so that buffer would become
    -- null if the only thing in it are white spaces
    l_buffer := LTRIM(l_buffer);

    -- Get the next non-blank, non-comment line if current line is
    -- fully parsed
    while (l_buffer is null and l_eof_flag = 'N' and p_index <=  AK_ON_OBJECTS_PVT.G_UPL_TABLE_NUM) loop
      AK_ON_OBJECTS_PVT.READ_LINE (
        p_return_status => l_return_status,
        p_index => p_index,
        p_buffer => l_buffer,
        p_lines_read => l_lines_read,
        p_eof_flag => l_eof_flag,
		p_upl_loader_cur => p_upl_loader_cur
      );
      if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
         (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
      end if;
      l_line_num := l_line_num + l_lines_read;
      --
      -- trim leading spaces and discard comment lines
      --
      l_buffer := LTRIM(l_buffer);
      if (SUBSTR(l_buffer, 1, 1) = '#') then
        l_buffer := null;
      end if;
    end loop;

  end LOOP; --** finish parsing the input file **

--dbms_output.put_line('finished parsing objects: ' ||
--                        to_char(sysdate, 'MON-DD HH24:MI:SS'));

  -- If the loops end in a state other then at the end of an object
  -- (state 0) or when the beginning of another business object was
  -- detected, then the file must have ended prematurely, which is an error
  if (l_state <> 0) and (l_more_object) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
      FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
      FND_MESSAGE.SET_TOKEN('TOKEN','END OF FILE');
      FND_MESSAGE.SET_TOKEN('EXPECTED',null);
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  --
  -- Insert or update all objects to the database
  --
  if (l_object_tbl.count > 0) then
    for l_index in l_object_tbl.FIRST .. l_object_tbl.LAST loop
      if (l_object_tbl.exists(l_index)) then
        if AK_OBJECT_PVT.OBJECT_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_database_object_name =>
                        l_object_tbl(l_index).database_object_name) then
          --
		  -- Update Object only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_OBJECT3_PVT.UPDATE_OBJECT (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_database_object_name =>
                                l_object_tbl(l_index).database_object_name,
              p_name => l_object_tbl(l_index).name,
              p_description => l_object_tbl(l_index).description,
              p_application_id => l_object_tbl(l_index).application_id,
              p_primary_key_name => l_object_tbl(l_index).primary_key_name,
              p_defaulting_api_pkg => l_object_tbl(l_index).defaulting_api_pkg,
              p_defaulting_api_proc => l_object_tbl(l_index).defaulting_api_proc,
              p_validation_api_pkg => l_object_tbl(l_index).validation_api_pkg,
              p_validation_api_proc => l_object_tbl(l_index).validation_api_proc,
              p_attribute_category => l_object_tbl(l_index).attribute_category,
			  p_attribute1 => l_object_tbl(l_index).attribute1,
			  p_attribute2 => l_object_tbl(l_index).attribute2,
			  p_attribute3 => l_object_tbl(l_index).attribute3,
			  p_attribute4 => l_object_tbl(l_index).attribute4,
			  p_attribute5 => l_object_tbl(l_index).attribute5,
			  p_attribute6 => l_object_tbl(l_index).attribute6,
			  p_attribute7 => l_object_tbl(l_index).attribute7,
			  p_attribute8 => l_object_tbl(l_index).attribute8,
			  p_attribute9 => l_object_tbl(l_index).attribute9,
			  p_attribute10 => l_object_tbl(l_index).attribute10,
			  p_attribute11 => l_object_tbl(l_index).attribute11,
			  p_attribute12 => l_object_tbl(l_index).attribute12,
			  p_attribute13 => l_object_tbl(l_index).attribute13,
			  p_attribute14 => l_object_tbl(l_index).attribute14,
			  p_attribute15 => l_object_tbl(l_index).attribute15,
		p_created_by => l_object_tbl(l_index).created_by,
		p_creation_date => l_object_tbl(l_index).creation_date,
		p_last_updated_by => l_object_tbl(l_index).last_updated_by,
		p_last_update_date => l_object_tbl(l_index).last_update_date,
		p_last_update_login => l_object_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
              p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
			select ao.last_updated_by, aot.last_updated_by,
			ao.last_update_date, aot.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
			from ak_objects ao, ak_objects_tl aot
			where ao.database_object_name = l_object_tbl(l_index).database_object_name
			and ao.database_object_name = aot.database_object_name
			and aot.language = userenv('LANG');
			/*if (( l_user_id1 = 1 or l_user_id1 = 2 ) and
				( l_user_id2 = 1  or l_user_id2 = 2)) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_object_tbl(l_index).created_by,
                      p_creation_date => l_object_tbl(l_index).creation_date,
                      p_last_updated_by => l_object_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_object_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_object_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_object_tbl(l_index).created_by,
                      p_creation_date => l_object_tbl(l_index).creation_date,
                      p_last_updated_by => l_object_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_object_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_object_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

	            AK_OBJECT3_PVT.UPDATE_OBJECT (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_database_object_name =>
	                                l_object_tbl(l_index).database_object_name,
	              p_name => l_object_tbl(l_index).name,
	              p_description => l_object_tbl(l_index).description,
	              p_application_id => l_object_tbl(l_index).application_id,
	              p_primary_key_name => l_object_tbl(l_index).primary_key_name,
	              p_defaulting_api_pkg => l_object_tbl(l_index).defaulting_api_pkg,
	              p_defaulting_api_proc => l_object_tbl(l_index).defaulting_api_proc,
	              p_validation_api_pkg => l_object_tbl(l_index).validation_api_pkg,
	              p_validation_api_proc => l_object_tbl(l_index).validation_api_proc,
	              p_attribute_category => l_object_tbl(l_index).attribute_category,
				  p_attribute1 => l_object_tbl(l_index).attribute1,
				  p_attribute2 => l_object_tbl(l_index).attribute2,
				  p_attribute3 => l_object_tbl(l_index).attribute3,
				  p_attribute4 => l_object_tbl(l_index).attribute4,
				  p_attribute5 => l_object_tbl(l_index).attribute5,
				  p_attribute6 => l_object_tbl(l_index).attribute6,
				  p_attribute7 => l_object_tbl(l_index).attribute7,
				  p_attribute8 => l_object_tbl(l_index).attribute8,
				  p_attribute9 => l_object_tbl(l_index).attribute9,
				  p_attribute10 => l_object_tbl(l_index).attribute10,
				  p_attribute11 => l_object_tbl(l_index).attribute11,
				  p_attribute12 => l_object_tbl(l_index).attribute12,
				  p_attribute13 => l_object_tbl(l_index).attribute13,
				  p_attribute14 => l_object_tbl(l_index).attribute14,
				  p_attribute15 => l_object_tbl(l_index).attribute15,
		p_created_by => l_object_tbl(l_index).created_by,
		p_creation_date => l_object_tbl(l_index).creation_date,
		p_last_updated_by => l_object_tbl(l_index).last_updated_by,
		p_last_update_date => l_object_tbl(l_index).last_update_date,
		p_last_update_login => l_object_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	              p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if l_user_id1 = 1 and l_user_id2 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_OBJECT_PVT.CREATE_OBJECT (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_database_object_name =>
                              l_object_tbl(l_index).database_object_name,
            p_name => l_object_tbl(l_index).name,
            p_description => l_object_tbl(l_index).description,
            p_application_id => l_object_tbl(l_index).application_id,
            p_primary_key_name => l_object_tbl(l_index).primary_key_name,
            p_defaulting_api_pkg => l_object_tbl(l_index).defaulting_api_pkg,
            p_defaulting_api_proc => l_object_tbl(l_index).defaulting_api_proc,
            p_validation_api_pkg => l_object_tbl(l_index).validation_api_pkg,
            p_validation_api_proc => l_object_tbl(l_index).validation_api_proc,
            p_attribute_category => l_object_tbl(l_index).attribute_category,
			p_attribute1 => l_object_tbl(l_index).attribute1,
			p_attribute2 => l_object_tbl(l_index).attribute2,
			p_attribute3 => l_object_tbl(l_index).attribute3,
			p_attribute4 => l_object_tbl(l_index).attribute4,
			p_attribute5 => l_object_tbl(l_index).attribute5,
			p_attribute6 => l_object_tbl(l_index).attribute6,
			p_attribute7 => l_object_tbl(l_index).attribute7,
			p_attribute8 => l_object_tbl(l_index).attribute8,
			p_attribute9 => l_object_tbl(l_index).attribute9,
			p_attribute10 => l_object_tbl(l_index).attribute10,
			p_attribute11 => l_object_tbl(l_index).attribute11,
			p_attribute12 => l_object_tbl(l_index).attribute12,
			p_attribute13 => l_object_tbl(l_index).attribute13,
			p_attribute14 => l_object_tbl(l_index).attribute14,
			p_attribute15 => l_object_tbl(l_index).attribute15,
		p_created_by => l_object_tbl(l_index).created_by,
		p_creation_date => l_object_tbl(l_index).creation_date,
		p_last_updated_by => l_object_tbl(l_index).last_updated_by,
		p_last_update_date => l_object_tbl(l_index).last_update_date,
		p_last_update_login => l_object_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
            );
        end if; -- /* if OBJECT_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  AK_OBJECT2_PVT.G_OBJECT_REDO_INDEX := AK_OBJECT2_PVT.G_OBJECT_REDO_INDEX + 1;
		  AK_OBJECT2_PVT.G_OBJECT_REDO_TBL(AK_OBJECT2_PVT.G_OBJECT_REDO_INDEX) := l_object_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if; -- /* if l_object_tbl.exists */
    end loop;
  end if;

  --
  -- Insert or update all object attributes to the database
  --
  if (l_attribute_tbl.count > 0) then
    for l_index in l_attribute_tbl.FIRST .. l_attribute_tbl.LAST loop
      if (l_attribute_tbl.exists(l_index)) then
        if AK_OBJECT_PVT.ATTRIBUTE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_database_object_name =>
                         l_attribute_tbl(l_index).database_object_name,
            p_attribute_application_id =>
                         l_attribute_tbl(l_index).attribute_appl_id,
            p_attribute_code =>
                         l_attribute_tbl(l_index).attribute_code) then
          --
		  -- Update Object Attributes only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_OBJECT3_PVT.UPDATE_ATTRIBUTE (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_database_object_name =>
                      l_attribute_tbl(l_index).database_object_name,
              p_attribute_application_id =>
                      l_attribute_tbl(l_index).attribute_appl_id,
              p_attribute_code => l_attribute_tbl(l_index).attribute_code,
              p_column_name => l_attribute_tbl(l_index).column_name,
              p_attribute_label_length =>
                      l_attribute_tbl(l_index).attribute_label_length,
              p_display_value_length =>
                      l_attribute_tbl(l_index).display_value_length,
              p_bold => l_attribute_tbl(l_index).bold,
              p_italic => l_attribute_tbl(l_index).italic,
              p_vertical_alignment =>
                      l_attribute_tbl(l_index).vertical_alignment,
              p_horizontal_alignment =>
                      l_attribute_tbl(l_index).horizontal_alignment,
              p_data_source_type => l_attribute_tbl(l_index).data_source_type,
              p_data_storage_type => l_attribute_tbl(l_index).data_storage_type,
              p_table_name => l_attribute_tbl(l_index).table_name,
              p_base_table_column_name =>
                      l_attribute_tbl(l_index).base_table_column_name,
              p_required_flag => l_attribute_tbl(l_index).required_flag,
              p_default_value_varchar2 =>
                      l_attribute_tbl(l_index).default_value_varchar2,
              p_default_value_number =>
                      l_attribute_tbl(l_index).default_value_number,
              p_default_value_date =>
                      l_attribute_tbl(l_index).default_value_date,
              p_lov_region_application_id =>
                      l_attribute_tbl(l_index).lov_region_application_id,
              p_lov_region_code => l_attribute_tbl(l_index).lov_region_code,
              p_lov_foreign_key_name =>
                      l_attribute_tbl(l_index).lov_foreign_key_name,
              p_lov_attribute_application_id =>
                      l_attribute_tbl(l_index).lov_attribute_application_id,
              p_lov_attribute_code =>
                      l_attribute_tbl(l_index).lov_attribute_code,
              p_defaulting_api_pkg =>
                      l_attribute_tbl(l_index).defaulting_api_pkg,
              p_defaulting_api_proc =>
                      l_attribute_tbl(l_index).defaulting_api_proc,
              p_validation_api_pkg =>l_attribute_tbl(l_index).validation_api_pkg,
              p_validation_api_proc =>
                      l_attribute_tbl(l_index).validation_api_proc,
              p_attribute_category => l_attribute_tbl(l_index).attribute_category,
			  p_attribute1 => l_attribute_tbl(l_index).attribute1,
			  p_attribute2 => l_attribute_tbl(l_index).attribute2,
			  p_attribute3 => l_attribute_tbl(l_index).attribute3,
			  p_attribute4 => l_attribute_tbl(l_index).attribute4,
			  p_attribute5 => l_attribute_tbl(l_index).attribute5,
			  p_attribute6 => l_attribute_tbl(l_index).attribute6,
			  p_attribute7 => l_attribute_tbl(l_index).attribute7,
			  p_attribute8 => l_attribute_tbl(l_index).attribute8,
			  p_attribute9 => l_attribute_tbl(l_index).attribute9,
			  p_attribute10 => l_attribute_tbl(l_index).attribute10,
			  p_attribute11 => l_attribute_tbl(l_index).attribute11,
			  p_attribute12 => l_attribute_tbl(l_index).attribute12,
			  p_attribute13 => l_attribute_tbl(l_index).attribute13,
			  p_attribute14 => l_attribute_tbl(l_index).attribute14,
			  p_attribute15 => l_attribute_tbl(l_index).attribute15,
              p_attribute_label_long =>
                      l_attribute_tbl(l_index).attribute_label_long,
              p_attribute_label_short =>
                      l_attribute_tbl(l_index).attribute_label_short,
		p_created_by => l_attribute_tbl(l_index).created_by,
		p_creation_date => l_attribute_tbl(l_index).creation_date,
		p_last_updated_by => l_attribute_tbl(l_index).last_updated_by,
		p_last_update_date => l_attribute_tbl(l_index).last_update_date,
		p_last_update_login => l_attribute_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
  		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
			select aoa.last_updated_by, aoat.last_updated_by,
			aoa.last_update_date, aoat.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
			from ak_object_attributes aoa, ak_object_attributes_tl aoat
			where aoa.database_object_name = l_attribute_tbl(l_index).database_object_name
			and aoa.attribute_code = l_attribute_tbl(l_index).attribute_code
			and aoa.attribute_application_id = l_attribute_tbl(l_index).attribute_appl_id
			and aoa.database_object_name = aoat.database_object_name
			and aoa.attribute_code = aoat.attribute_code
			and aoa.attribute_application_id = aoat.attribute_application_id
			and aoat.language = userenv('LANG');
			/*if (( l_user_id1 = 1 or l_user_id1 = 2) and
				(l_user_id2 = 1 or l_user_id2 = 2)) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_attribute_tbl(l_index).created_by,
                      p_creation_date => l_attribute_tbl(l_index).creation_date,
                      p_last_updated_by => l_attribute_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_attribute_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_attribute_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_attribute_tbl(l_index).created_by,
                      p_creation_date => l_attribute_tbl(l_index).creation_date,
                      p_last_updated_by => l_attribute_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_attribute_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_attribute_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

	            AK_OBJECT3_PVT.UPDATE_ATTRIBUTE (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_database_object_name =>
	                      l_attribute_tbl(l_index).database_object_name,
	              p_attribute_application_id =>
	                      l_attribute_tbl(l_index).attribute_appl_id,
	              p_attribute_code => l_attribute_tbl(l_index).attribute_code,
	              p_column_name => l_attribute_tbl(l_index).column_name,
	              p_attribute_label_length =>
	                      l_attribute_tbl(l_index).attribute_label_length,
	              p_display_value_length =>
	                      l_attribute_tbl(l_index).display_value_length,
	              p_bold => l_attribute_tbl(l_index).bold,
	              p_italic => l_attribute_tbl(l_index).italic,
	              p_vertical_alignment =>
	                      l_attribute_tbl(l_index).vertical_alignment,
	              p_horizontal_alignment =>
	                      l_attribute_tbl(l_index).horizontal_alignment,
	              p_data_source_type => l_attribute_tbl(l_index).data_source_type,
	              p_data_storage_type => l_attribute_tbl(l_index).data_storage_type,
	              p_table_name => l_attribute_tbl(l_index).table_name,
	              p_base_table_column_name =>
	                      l_attribute_tbl(l_index).base_table_column_name,
	              p_required_flag => l_attribute_tbl(l_index).required_flag,
	              p_default_value_varchar2 =>
	                      l_attribute_tbl(l_index).default_value_varchar2,
	              p_default_value_number =>
	                      l_attribute_tbl(l_index).default_value_number,
	              p_default_value_date =>
	                      l_attribute_tbl(l_index).default_value_date,
	              p_lov_region_application_id =>
	                      l_attribute_tbl(l_index).lov_region_application_id,
	              p_lov_region_code => l_attribute_tbl(l_index).lov_region_code,
	              p_lov_foreign_key_name =>
	                      l_attribute_tbl(l_index).lov_foreign_key_name,
	              p_lov_attribute_application_id =>
	                      l_attribute_tbl(l_index).lov_attribute_application_id,
	              p_lov_attribute_code =>
	                      l_attribute_tbl(l_index).lov_attribute_code,
	              p_defaulting_api_pkg =>
	                      l_attribute_tbl(l_index).defaulting_api_pkg,
	              p_defaulting_api_proc =>
	                      l_attribute_tbl(l_index).defaulting_api_proc,
	              p_validation_api_pkg =>l_attribute_tbl(l_index).validation_api_pkg,
	              p_validation_api_proc =>
	                      l_attribute_tbl(l_index).validation_api_proc,
	              p_attribute_category => l_attribute_tbl(l_index).attribute_category,
				  p_attribute1 => l_attribute_tbl(l_index).attribute1,
				  p_attribute2 => l_attribute_tbl(l_index).attribute2,
				  p_attribute3 => l_attribute_tbl(l_index).attribute3,
				  p_attribute4 => l_attribute_tbl(l_index).attribute4,
				  p_attribute5 => l_attribute_tbl(l_index).attribute5,
				  p_attribute6 => l_attribute_tbl(l_index).attribute6,
				  p_attribute7 => l_attribute_tbl(l_index).attribute7,
				  p_attribute8 => l_attribute_tbl(l_index).attribute8,
				  p_attribute9 => l_attribute_tbl(l_index).attribute9,
				  p_attribute10 => l_attribute_tbl(l_index).attribute10,
				  p_attribute11 => l_attribute_tbl(l_index).attribute11,
				  p_attribute12 => l_attribute_tbl(l_index).attribute12,
				  p_attribute13 => l_attribute_tbl(l_index).attribute13,
				  p_attribute14 => l_attribute_tbl(l_index).attribute14,
				  p_attribute15 => l_attribute_tbl(l_index).attribute15,
	              p_attribute_label_long =>
	                      l_attribute_tbl(l_index).attribute_label_long,
	              p_attribute_label_short =>
	                      l_attribute_tbl(l_index).attribute_label_short,
		p_created_by => l_attribute_tbl(l_index).created_by,
		p_creation_date => l_attribute_tbl(l_index).creation_date,
		p_last_updated_by => l_attribute_tbl(l_index).last_updated_by,
		p_last_update_date => l_attribute_tbl(l_index).last_update_date,
		p_last_update_login => l_attribute_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	  		      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if l_user_id1 = 1 and l_user_id2 = 1 */
		  end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_OBJECT_PVT.CREATE_ATTRIBUTE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_database_object_name =>
                    l_attribute_tbl(l_index).database_object_name,
            p_attribute_application_id =>
                    l_attribute_tbl(l_index).attribute_appl_id,
            p_attribute_code => l_attribute_tbl(l_index).attribute_code,
            p_column_name => l_attribute_tbl(l_index).column_name,
            p_attribute_label_length =>
                    l_attribute_tbl(l_index).attribute_label_length,
            p_display_value_length =>
                    l_attribute_tbl(l_index).display_value_length,
            p_bold => l_attribute_tbl(l_index).bold,
            p_italic => l_attribute_tbl(l_index).italic,
            p_vertical_alignment =>
                    l_attribute_tbl(l_index).vertical_alignment,
            p_horizontal_alignment =>
                    l_attribute_tbl(l_index).horizontal_alignment,
            p_data_source_type => l_attribute_tbl(l_index).data_source_type,
            p_data_storage_type => l_attribute_tbl(l_index).data_storage_type,
            p_table_name => l_attribute_tbl(l_index).table_name,
            p_base_table_column_name =>
                    l_attribute_tbl(l_index).base_table_column_name,
            p_required_flag => l_attribute_tbl(l_index).required_flag,
            p_default_value_varchar2 =>
                    l_attribute_tbl(l_index).default_value_varchar2,
            p_default_value_number =>
                    l_attribute_tbl(l_index).default_value_number,
            p_default_value_date =>
                    l_attribute_tbl(l_index).default_value_date,
            p_lov_region_application_id =>
                    l_attribute_tbl(l_index).lov_region_application_id,
            p_lov_region_code => l_attribute_tbl(l_index).lov_region_code,
            p_lov_foreign_key_name =>
                    l_attribute_tbl(l_index).lov_foreign_key_name,
            p_lov_attribute_application_id =>
                    l_attribute_tbl(l_index).lov_attribute_application_id,
            p_lov_attribute_code =>
                    l_attribute_tbl(l_index).lov_attribute_code,
            p_defaulting_api_pkg =>
                    l_attribute_tbl(l_index).defaulting_api_pkg,
            p_defaulting_api_proc =>
                    l_attribute_tbl(l_index).defaulting_api_proc,
            p_validation_api_pkg =>l_attribute_tbl(l_index).validation_api_pkg,
            p_validation_api_proc =>
                    l_attribute_tbl(l_index).validation_api_proc,
            p_attribute_category => l_attribute_tbl(l_index).attribute_category,
			p_attribute1 => l_attribute_tbl(l_index).attribute1,
			p_attribute2 => l_attribute_tbl(l_index).attribute2,
			p_attribute3 => l_attribute_tbl(l_index).attribute3,
			p_attribute4 => l_attribute_tbl(l_index).attribute4,
			p_attribute5 => l_attribute_tbl(l_index).attribute5,
			p_attribute6 => l_attribute_tbl(l_index).attribute6,
			p_attribute7 => l_attribute_tbl(l_index).attribute7,
			p_attribute8 => l_attribute_tbl(l_index).attribute8,
			p_attribute9 => l_attribute_tbl(l_index).attribute9,
			p_attribute10 => l_attribute_tbl(l_index).attribute10,
			p_attribute11 => l_attribute_tbl(l_index).attribute11,
			p_attribute12 => l_attribute_tbl(l_index).attribute12,
			p_attribute13 => l_attribute_tbl(l_index).attribute13,
			p_attribute14 => l_attribute_tbl(l_index).attribute14,
			p_attribute15 => l_attribute_tbl(l_index).attribute15,
            p_attribute_label_long =>
                    l_attribute_tbl(l_index).attribute_label_long,
            p_attribute_label_short =>
                    l_attribute_tbl(l_index).attribute_label_short,
	p_created_by => l_attribute_tbl(l_index).created_by,
	p_creation_date => l_attribute_tbl(l_index).creation_date,
	p_last_updated_by => l_attribute_tbl(l_index).last_updated_by,
	p_last_update_date => l_attribute_tbl(l_index).last_update_date,
	p_last_update_login => l_attribute_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if ATTRIBUTE_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  AK_OBJECT2_PVT.G_OBJECT_ATTR_REDO_INDEX := AK_OBJECT2_PVT.G_OBJECT_ATTR_REDO_INDEX + 1;
		  AK_OBJECT2_PVT.G_OBJECT_ATTR_REDO_TBL(AK_OBJECT2_PVT.G_OBJECT_ATTR_REDO_INDEX) := l_attribute_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

  --
  -- Insert or update all object attribute navigation to the database
  --
  if (l_navigation_tbl.count > 0) then
    for l_index in l_navigation_tbl.FIRST .. l_navigation_tbl.LAST loop
      if (l_navigation_tbl.exists(l_index)) then
        if  AK_OBJECT_PVT.ATTRIBUTE_NAVIGATION_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_database_object_name =>
                            l_navigation_tbl(l_index).database_object_name,
            p_attribute_application_id =>
                            l_navigation_tbl(l_index).attribute_appl_id,
            p_attribute_code => l_navigation_tbl(l_index).attribute_code,
            p_value_varchar2 => l_navigation_tbl(l_index).value_varchar2,
            p_value_date => l_navigation_tbl(l_index).value_date,
            p_value_number => l_navigation_tbl(l_index).value_number) then
          --
		  -- Update Object Attribute Navigation only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_OBJECT3_PVT.UPDATE_ATTRIBUTE_NAVIGATION (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_database_object_name =>
                              l_navigation_tbl(l_index).database_object_name,
              p_attribute_application_id =>
                              l_navigation_tbl(l_index).attribute_appl_id,
              p_attribute_code => l_navigation_tbl(l_index).attribute_code,
              p_value_varchar2 => l_navigation_tbl(l_index).value_varchar2,
              p_value_date => l_navigation_tbl(l_index).value_date,
              p_value_number => l_navigation_tbl(l_index).value_number,
              p_to_region_appl_id => l_navigation_tbl(l_index).to_region_appl_id,
              p_to_region_code => l_navigation_tbl(l_index).to_region_code,
              p_attribute_category => l_navigation_tbl(l_index).attribute_category,
			  p_attribute1 => l_navigation_tbl(l_index).attribute1,
			  p_attribute2 => l_navigation_tbl(l_index).attribute2,
			  p_attribute3 => l_navigation_tbl(l_index).attribute3,
			  p_attribute4 => l_navigation_tbl(l_index).attribute4,
			  p_attribute5 => l_navigation_tbl(l_index).attribute5,
			  p_attribute6 => l_navigation_tbl(l_index).attribute6,
			  p_attribute7 => l_navigation_tbl(l_index).attribute7,
			  p_attribute8 => l_navigation_tbl(l_index).attribute8,
			  p_attribute9 => l_navigation_tbl(l_index).attribute9,
			  p_attribute10 => l_navigation_tbl(l_index).attribute10,
			  p_attribute11 => l_navigation_tbl(l_index).attribute11,
			  p_attribute12 => l_navigation_tbl(l_index).attribute12,
			  p_attribute13 => l_navigation_tbl(l_index).attribute13,
			  p_attribute14 => l_navigation_tbl(l_index).attribute14,
			  p_attribute15 => l_navigation_tbl(l_index).attribute15,
		p_created_by => l_navigation_tbl(l_index).created_by,
		p_creation_date => l_navigation_tbl(l_index).creation_date,
		p_last_updated_by => l_navigation_tbl(l_index).last_updated_by,
		p_last_update_date => l_navigation_tbl(l_index).last_update_date,
		p_last_update_login => l_navigation_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
  		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
			select aoan.last_updated_by, aoan.last_update_date
			into l_user_id1, l_update1
			from ak_object_attribute_navigation aoan
			where aoan.database_object_name = l_navigation_tbl(l_index).database_object_name
			and aoan.attribute_code = l_navigation_tbl(l_index).attribute_code
			and aoan.attribute_application_id = l_navigation_tbl(l_index).attribute_appl_id
			and aoan.value_varchar2 = l_navigation_tbl(l_index).value_varchar2
			and aoan.value_date = l_navigation_tbl(l_index).value_date
			and aoan.value_number = l_navigation_tbl(l_index).value_number;
			/*if ( l_user_id1 = 1 or l_user_id1 = 2) then*/
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_navigation_tbl(l_index).created_by,
                      p_creation_date => l_navigation_tbl(l_index).creation_date,
                      p_last_updated_by => l_navigation_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_navigation_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_navigation_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_OBJECT3_PVT.UPDATE_ATTRIBUTE_NAVIGATION (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_database_object_name =>
	                              l_navigation_tbl(l_index).database_object_name,
	              p_attribute_application_id =>
	                              l_navigation_tbl(l_index).attribute_appl_id,
	              p_attribute_code => l_navigation_tbl(l_index).attribute_code,
	              p_value_varchar2 => l_navigation_tbl(l_index).value_varchar2,
	              p_value_date => l_navigation_tbl(l_index).value_date,
	              p_value_number => l_navigation_tbl(l_index).value_number,
	              p_to_region_appl_id => l_navigation_tbl(l_index).to_region_appl_id,
	              p_to_region_code => l_navigation_tbl(l_index).to_region_code,
	              p_attribute_category => l_navigation_tbl(l_index).attribute_category,
				  p_attribute1 => l_navigation_tbl(l_index).attribute1,
				  p_attribute2 => l_navigation_tbl(l_index).attribute2,
				  p_attribute3 => l_navigation_tbl(l_index).attribute3,
				  p_attribute4 => l_navigation_tbl(l_index).attribute4,
				  p_attribute5 => l_navigation_tbl(l_index).attribute5,
				  p_attribute6 => l_navigation_tbl(l_index).attribute6,
				  p_attribute7 => l_navigation_tbl(l_index).attribute7,
				  p_attribute8 => l_navigation_tbl(l_index).attribute8,
				  p_attribute9 => l_navigation_tbl(l_index).attribute9,
				  p_attribute10 => l_navigation_tbl(l_index).attribute10,
				  p_attribute11 => l_navigation_tbl(l_index).attribute11,
				  p_attribute12 => l_navigation_tbl(l_index).attribute12,
				  p_attribute13 => l_navigation_tbl(l_index).attribute13,
				  p_attribute14 => l_navigation_tbl(l_index).attribute14,
				  p_attribute15 => l_navigation_tbl(l_index).attribute15,
		p_created_by => l_navigation_tbl(l_index).created_by,
		p_creation_date => l_navigation_tbl(l_index).creation_date,
		p_last_updated_by => l_navigation_tbl(l_index).last_updated_by,
		p_last_update_date => l_navigation_tbl(l_index).last_update_date,
		p_last_update_login => l_navigation_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	  		      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if l_user_id1 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_OBJECT_PVT.CREATE_ATTRIBUTE_NAVIGATION (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_database_object_name =>
                            l_navigation_tbl(l_index).database_object_name,
            p_attribute_application_id =>
                            l_navigation_tbl(l_index).attribute_appl_id,
            p_attribute_code => l_navigation_tbl(l_index).attribute_code,
            p_value_varchar2 => l_navigation_tbl(l_index).value_varchar2,
            p_value_date => l_navigation_tbl(l_index).value_date,
            p_value_number => l_navigation_tbl(l_index).value_number,
            p_to_region_appl_id =>
                            l_navigation_tbl(l_index).to_region_appl_id,
            p_to_region_code => l_navigation_tbl(l_index).to_region_code,
            p_attribute_category => l_navigation_tbl(l_index).attribute_category,
			p_attribute1 => l_navigation_tbl(l_index).attribute1,
			p_attribute2 => l_navigation_tbl(l_index).attribute2,
			p_attribute3 => l_navigation_tbl(l_index).attribute3,
			p_attribute4 => l_navigation_tbl(l_index).attribute4,
			p_attribute5 => l_navigation_tbl(l_index).attribute5,
			p_attribute6 => l_navigation_tbl(l_index).attribute6,
			p_attribute7 => l_navigation_tbl(l_index).attribute7,
			p_attribute8 => l_navigation_tbl(l_index).attribute8,
			p_attribute9 => l_navigation_tbl(l_index).attribute9,
			p_attribute10 => l_navigation_tbl(l_index).attribute10,
			p_attribute11 => l_navigation_tbl(l_index).attribute11,
			p_attribute12 => l_navigation_tbl(l_index).attribute12,
			p_attribute13 => l_navigation_tbl(l_index).attribute13,
			p_attribute14 => l_navigation_tbl(l_index).attribute14,
			p_attribute15 => l_navigation_tbl(l_index).attribute15,
	p_created_by => l_navigation_tbl(l_index).created_by,
	p_creation_date => l_navigation_tbl(l_index).creation_date,
	p_last_updated_by => l_navigation_tbl(l_index).last_updated_by,
	p_last_update_date => l_navigation_tbl(l_index).last_update_date,
	p_last_update_login => l_navigation_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if ATTRIBUTE_NAVIGATION_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  AK_OBJECT2_PVT.G_ATTR_NAV_REDO_INDEX := AK_OBJECT2_PVT.G_ATTR_NAV_REDO_INDEX + 1;
		  AK_OBJECT2_PVT.G_ATTR_NAV_REDO_TBL(AK_OBJECT2_PVT.G_ATTR_NAV_REDO_INDEX) := l_navigation_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if; -- /* if l_navigation_tbl.exists */
    end loop;
  end if;

  --
  -- Insert or update all attribute values to the database
  --
  if (l_attribute_value_tbl.count > 0) then
    --dbms_output.put_line('l_attribute_value_tbl.count = '||to_char(l_attribute_value_tbl.count));
    for l_index in l_attribute_value_tbl.FIRST .. l_attribute_value_tbl.LAST loop
      if (l_attribute_value_tbl.exists(l_index)) then
        if  AK_OBJECT_PVT.ATTRIBUTE_VALUE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_database_object_name =>
                         l_attribute_value_tbl(l_index).database_object_name,
            p_attribute_application_id =>
                         l_attribute_value_tbl(l_index).attribute_appl_id,
            p_attribute_code => l_attribute_value_tbl(l_index).attribute_code,
            p_key_value1 => l_attribute_value_tbl(l_index).key_value1,
            p_key_value2 => l_attribute_value_tbl(l_index).key_value2,
            p_key_value3 => l_attribute_value_tbl(l_index).key_value3,
            p_key_value4 => l_attribute_value_tbl(l_index).key_value4,
            p_key_value5 => l_attribute_value_tbl(l_index).key_value5,
            p_key_value6 => l_attribute_value_tbl(l_index).key_value6,
            p_key_value7 => l_attribute_value_tbl(l_index).key_value7,
            p_key_value8 => l_attribute_value_tbl(l_index).key_value8,
            p_key_value9 => l_attribute_value_tbl(l_index).key_value9,
            p_key_value10 => l_attribute_value_tbl(l_index).key_value10
	  ) then
          --
		  -- Update Update Attribute Values only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_OBJECT3_PVT.UPDATE_ATTRIBUTE_VALUE (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_database_object_name =>
                           l_attribute_value_tbl(l_index).database_object_name,
              p_attribute_application_id =>
                           l_attribute_value_tbl(l_index).attribute_appl_id,
              p_attribute_code => l_attribute_value_tbl(l_index).attribute_code,
              p_key_value1 => l_attribute_value_tbl(l_index).key_value1,
              p_key_value2 => l_attribute_value_tbl(l_index).key_value2,
              p_key_value3 => l_attribute_value_tbl(l_index).key_value3,
              p_key_value4 => l_attribute_value_tbl(l_index).key_value4,
              p_key_value5 => l_attribute_value_tbl(l_index).key_value5,
              p_key_value6 => l_attribute_value_tbl(l_index).key_value6,
              p_key_value7 => l_attribute_value_tbl(l_index).key_value7,
              p_key_value8 => l_attribute_value_tbl(l_index).key_value8,
              p_key_value9 => l_attribute_value_tbl(l_index).key_value9,
              p_key_value10 => l_attribute_value_tbl(l_index).key_value10,
              p_value_varchar2 => l_attribute_value_tbl(l_index).value_varchar2,
              p_value_date => l_attribute_value_tbl(l_index).value_date,
              p_value_number => l_attribute_value_tbl(l_index).value_number,
		p_created_by => l_attribute_value_tbl(l_index).created_by,
		p_creation_date => l_attribute_value_tbl(l_index).creation_date,
		p_last_updated_by => l_attribute_value_tbl(l_index).last_updated_by,
		p_last_update_date => l_attribute_value_tbl(l_index).last_update_date,
		p_last_update_login => l_attribute_value_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp);
          end if; -- /* if G_UPDATE_MODE */
        else
          AK_OBJECT_PVT.CREATE_ATTRIBUTE_VALUE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_database_object_name =>
                         l_attribute_value_tbl(l_index).database_object_name,
            p_attribute_application_id =>
                         l_attribute_value_tbl(l_index).attribute_appl_id,
            p_attribute_code => l_attribute_value_tbl(l_index).attribute_code,
            p_key_value1 => l_attribute_value_tbl(l_index).key_value1,
            p_key_value2 => l_attribute_value_tbl(l_index).key_value2,
            p_key_value3 => l_attribute_value_tbl(l_index).key_value3,
            p_key_value4 => l_attribute_value_tbl(l_index).key_value4,
            p_key_value5 => l_attribute_value_tbl(l_index).key_value5,
            p_key_value6 => l_attribute_value_tbl(l_index).key_value6,
            p_key_value7 => l_attribute_value_tbl(l_index).key_value7,
            p_key_value8 => l_attribute_value_tbl(l_index).key_value8,
            p_key_value9 => l_attribute_value_tbl(l_index).key_value9,
            p_key_value10 => l_attribute_value_tbl(l_index).key_value10,
            p_value_varchar2 => l_attribute_value_tbl(l_index).value_varchar2,
            p_value_date => l_attribute_value_tbl(l_index).value_date,
            p_value_number => l_attribute_value_tbl(l_index).value_number,
	p_created_by => l_attribute_value_tbl(l_index).created_by,
	p_creation_date => l_attribute_value_tbl(l_index).creation_date,
	p_last_updated_by => l_attribute_value_tbl(l_index).last_updated_by,
	p_last_update_date => l_attribute_value_tbl(l_index).last_update_date,
	p_last_update_login => l_attribute_value_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp);
        end if; -- /* if ATTRIBUTE_VALUE_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
      end if;
    end loop;
  end if;

  --
  -- Insert or update all unique keys to the database
  --
  if (l_unique_key_tbl.count > 0) then
    for l_index in l_unique_key_tbl.FIRST .. l_unique_key_tbl.LAST loop
      if (l_unique_key_tbl.exists(l_index)) then
        if  AK_KEY_PVT.UNIQUE_KEY_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_unique_key_name =>
                           l_unique_key_tbl(l_index).unique_key_name) then
          --
		  -- Update Unique Keys only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_KEY_PVT.UPDATE_UNIQUE_KEY (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_unique_key_name =>
                             l_unique_key_tbl(l_index).unique_key_name,
              p_database_object_name =>
                             l_unique_key_tbl(l_index).database_object_name,
              p_application_id => l_unique_key_tbl(l_index).application_id,
              p_attribute_category => l_unique_key_tbl(l_index).attribute_category,
			  p_attribute1 => l_unique_key_tbl(l_index).attribute1,
			  p_attribute2 => l_unique_key_tbl(l_index).attribute2,
			  p_attribute3 => l_unique_key_tbl(l_index).attribute3,
			  p_attribute4 => l_unique_key_tbl(l_index).attribute4,
			  p_attribute5 => l_unique_key_tbl(l_index).attribute5,
			  p_attribute6 => l_unique_key_tbl(l_index).attribute6,
			  p_attribute7 => l_unique_key_tbl(l_index).attribute7,
			  p_attribute8 => l_unique_key_tbl(l_index).attribute8,
			  p_attribute9 => l_unique_key_tbl(l_index).attribute9,
			  p_attribute10 => l_unique_key_tbl(l_index).attribute10,
			  p_attribute11 => l_unique_key_tbl(l_index).attribute11,
			  p_attribute12 => l_unique_key_tbl(l_index).attribute12,
			  p_attribute13 => l_unique_key_tbl(l_index).attribute13,
			  p_attribute14 => l_unique_key_tbl(l_index).attribute14,
			  p_attribute15 => l_unique_key_tbl(l_index).attribute15,
		p_created_by => l_unique_key_tbl(l_index).created_by,
		p_creation_date => l_unique_key_tbl(l_index).creation_date,
		p_last_updated_by => l_unique_key_tbl(l_index).last_updated_by,
		p_last_update_date => l_unique_key_tbl(l_index).last_update_date,
		p_last_update_login => l_unique_key_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
  		      p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
			--
			-- Delete all children records in AK_UNIQUE_KEY_COLUMNS so
			-- that obsolete columns would not exist after upload.
            AK_KEY_PVT.DELETE_RELATED_UNIQUE_KEY_COL (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_unique_key_name =>
                             l_unique_key_tbl(l_index).unique_key_name
			);
		  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
			select last_updated_by, last_update_date
			into l_user_id1, l_update1
			from ak_unique_keys
			where database_object_name = l_unique_key_tbl(l_index).database_object_name
			and unique_key_name = l_unique_key_tbl(l_index).unique_key_name;

			/*if ( l_user_id1 = 1 or l_user_id1 = 2) then*/
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_unique_key_tbl(l_index).created_by,
                      p_creation_date => l_unique_key_tbl(l_index).creation_date,
                      p_last_updated_by => l_unique_key_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_unique_key_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_unique_key_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_KEY_PVT.UPDATE_UNIQUE_KEY (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_unique_key_name =>
	                             l_unique_key_tbl(l_index).unique_key_name,
	              p_database_object_name =>
	                             l_unique_key_tbl(l_index).database_object_name,
	              p_application_id => l_unique_key_tbl(l_index).application_id,
	              p_attribute_category => l_unique_key_tbl(l_index).attribute_category,
				  p_attribute1 => l_unique_key_tbl(l_index).attribute1,
				  p_attribute2 => l_unique_key_tbl(l_index).attribute2,
				  p_attribute3 => l_unique_key_tbl(l_index).attribute3,
				  p_attribute4 => l_unique_key_tbl(l_index).attribute4,
				  p_attribute5 => l_unique_key_tbl(l_index).attribute5,
				  p_attribute6 => l_unique_key_tbl(l_index).attribute6,
				  p_attribute7 => l_unique_key_tbl(l_index).attribute7,
				  p_attribute8 => l_unique_key_tbl(l_index).attribute8,
				  p_attribute9 => l_unique_key_tbl(l_index).attribute9,
				  p_attribute10 => l_unique_key_tbl(l_index).attribute10,
				  p_attribute11 => l_unique_key_tbl(l_index).attribute11,
				  p_attribute12 => l_unique_key_tbl(l_index).attribute12,
				  p_attribute13 => l_unique_key_tbl(l_index).attribute13,
				  p_attribute14 => l_unique_key_tbl(l_index).attribute14,
				  p_attribute15 => l_unique_key_tbl(l_index).attribute15,
		p_created_by => l_unique_key_tbl(l_index).created_by,
		p_creation_date => l_unique_key_tbl(l_index).creation_date,
		p_last_updated_by => l_unique_key_tbl(l_index).last_updated_by,
		p_last_update_date => l_unique_key_tbl(l_index).last_update_date,
		p_last_update_login => l_unique_key_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	  		      p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
				--
				-- Delete all children records in AK_UNIQUE_KEY_COLUMNS so
				-- that obsolete columns would not exist after upload.
	            AK_KEY_PVT.DELETE_RELATED_UNIQUE_KEY_COL (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_unique_key_name =>
	                             l_unique_key_tbl(l_index).unique_key_name
				);
			end if; -- /* if l_user_id1 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_KEY_PVT.CREATE_UNIQUE_KEY (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_unique_key_name =>
                           l_unique_key_tbl(l_index).unique_key_name,
            p_database_object_name =>
                           l_unique_key_tbl(l_index).database_object_name,
            p_application_id => l_unique_key_tbl(l_index).application_id,
            p_attribute_category => l_unique_key_tbl(l_index).attribute_category,
			p_attribute1 => l_unique_key_tbl(l_index).attribute1,
			p_attribute2 => l_unique_key_tbl(l_index).attribute2,
			p_attribute3 => l_unique_key_tbl(l_index).attribute3,
			p_attribute4 => l_unique_key_tbl(l_index).attribute4,
			p_attribute5 => l_unique_key_tbl(l_index).attribute5,
			p_attribute6 => l_unique_key_tbl(l_index).attribute6,
			p_attribute7 => l_unique_key_tbl(l_index).attribute7,
			p_attribute8 => l_unique_key_tbl(l_index).attribute8,
			p_attribute9 => l_unique_key_tbl(l_index).attribute9,
			p_attribute10 => l_unique_key_tbl(l_index).attribute10,
			p_attribute11 => l_unique_key_tbl(l_index).attribute11,
			p_attribute12 => l_unique_key_tbl(l_index).attribute12,
			p_attribute13 => l_unique_key_tbl(l_index).attribute13,
			p_attribute14 => l_unique_key_tbl(l_index).attribute14,
			p_attribute15 => l_unique_key_tbl(l_index).attribute15,
	p_created_by => l_unique_key_tbl(l_index).created_by,
	p_creation_date => l_unique_key_tbl(l_index).creation_date,
	p_last_updated_by => l_unique_key_tbl(l_index).lasT_updated_by,
	p_last_update_date => l_unique_key_tbl(l_index).last_update_date,
	p_last_update_login => l_unique_key_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if UNIQUE_KEY_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  AK_OBJECT2_PVT.G_UNIQUE_KEY_REDO_INDEX := AK_OBJECT2_PVT.G_UNIQUE_KEY_REDO_INDEX + 1;
		  AK_OBJECT2_PVT.G_UNIQUE_KEY_REDO_TBL(AK_OBJECT2_PVT.G_UNIQUE_KEY_REDO_INDEX) := l_unique_key_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

  --
  -- Insert or update all unique key columns to the database
  --
  if (l_unique_key_column_tbl.count > 0) then
    for l_index in l_unique_key_column_tbl.FIRST .. l_unique_key_column_tbl.LAST loop
      if (l_unique_key_column_tbl.exists(l_index)) then
        if  AK_KEY_PVT.UNIQUE_KEY_COLUMN_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_unique_key_name =>
                l_unique_key_column_tbl(l_index).unique_key_name,
            p_attribute_application_id =>
                l_unique_key_column_tbl(l_index).attribute_application_id,
            p_attribute_code =>
                l_unique_key_column_tbl(l_index).attribute_code) then
          --
		  -- Update Unique Key Columns only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_KEY_PVT.UPDATE_UNIQUE_KEY_COLUMN (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_unique_key_name =>
                             l_unique_key_column_tbl(l_index).unique_key_name,
              p_attribute_application_id =>
                  l_unique_key_column_tbl(l_index).attribute_application_id,
              p_attribute_code =>
                  l_unique_key_column_tbl(l_index).attribute_code,
              p_unique_key_sequence =>
                          l_unique_key_column_tbl(l_index).unique_key_sequence,
              p_attribute_category => l_unique_key_column_tbl(l_index).attribute_category,
			  p_attribute1 => l_unique_key_column_tbl(l_index).attribute1,
			  p_attribute2 => l_unique_key_column_tbl(l_index).attribute2,
			  p_attribute3 => l_unique_key_column_tbl(l_index).attribute3,
			  p_attribute4 => l_unique_key_column_tbl(l_index).attribute4,
			  p_attribute5 => l_unique_key_column_tbl(l_index).attribute5,
			  p_attribute6 => l_unique_key_column_tbl(l_index).attribute6,
			  p_attribute7 => l_unique_key_column_tbl(l_index).attribute7,
			  p_attribute8 => l_unique_key_column_tbl(l_index).attribute8,
			  p_attribute9 => l_unique_key_column_tbl(l_index).attribute9,
			  p_attribute10 => l_unique_key_column_tbl(l_index).attribute10,
			  p_attribute11 => l_unique_key_column_tbl(l_index).attribute11,
			  p_attribute12 => l_unique_key_column_tbl(l_index).attribute12,
			  p_attribute13 => l_unique_key_column_tbl(l_index).attribute13,
			  p_attribute14 => l_unique_key_column_tbl(l_index).attribute14,
			  p_attribute15 => l_unique_key_column_tbl(l_index).attribute15,
		p_created_by => l_unique_key_column_tbl(l_index).created_by,
		p_creation_date => l_unique_key_column_tbl(l_index).creation_date,
		p_last_updated_by => l_unique_key_column_tbl(l_index).last_updated_by,
		p_last_update_date => l_unique_key_column_tbl(l_index).last_update_date,
		p_last_update_login => l_unique_key_column_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
              p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
			select last_updated_by, last_update_date
			into l_user_id1, l_update1
			from ak_unique_key_columns
			where unique_key_name = l_unique_key_column_tbl(l_index).unique_key_name
			and attribute_code = l_unique_key_column_tbl(l_index).attribute_code
			and attribute_application_id = l_unique_key_column_tbl(l_index).attribute_application_id;
			/*if ( l_user_id1 = 1 or l_user_id1 = 2) then */
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_unique_key_column_tbl(l_index).created_by,
                      p_creation_date => l_unique_key_column_tbl(l_index).creation_date,
                      p_last_updated_by => l_unique_key_column_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_unique_key_column_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_unique_key_column_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_KEY_PVT.UPDATE_UNIQUE_KEY_COLUMN (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_unique_key_name =>
	                             l_unique_key_column_tbl(l_index).unique_key_name,
	              p_attribute_application_id =>
	                  l_unique_key_column_tbl(l_index).attribute_application_id,
	              p_attribute_code =>
	                  l_unique_key_column_tbl(l_index).attribute_code,
	              p_unique_key_sequence =>
	                          l_unique_key_column_tbl(l_index).unique_key_sequence,
	              p_attribute_category => l_unique_key_column_tbl(l_index).attribute_category,
				  p_attribute1 => l_unique_key_column_tbl(l_index).attribute1,
				  p_attribute2 => l_unique_key_column_tbl(l_index).attribute2,
				  p_attribute3 => l_unique_key_column_tbl(l_index).attribute3,
				  p_attribute4 => l_unique_key_column_tbl(l_index).attribute4,
				  p_attribute5 => l_unique_key_column_tbl(l_index).attribute5,
				  p_attribute6 => l_unique_key_column_tbl(l_index).attribute6,
				  p_attribute7 => l_unique_key_column_tbl(l_index).attribute7,
				  p_attribute8 => l_unique_key_column_tbl(l_index).attribute8,
				  p_attribute9 => l_unique_key_column_tbl(l_index).attribute9,
				  p_attribute10 => l_unique_key_column_tbl(l_index).attribute10,
				  p_attribute11 => l_unique_key_column_tbl(l_index).attribute11,
				  p_attribute12 => l_unique_key_column_tbl(l_index).attribute12,
				  p_attribute13 => l_unique_key_column_tbl(l_index).attribute13,
				  p_attribute14 => l_unique_key_column_tbl(l_index).attribute14,
				  p_attribute15 => l_unique_key_column_tbl(l_index).attribute15,
		p_created_by => l_unique_key_column_tbl(l_index).created_by,
		p_creation_date => l_unique_key_column_tbl(l_index).creation_date,
		p_last_updated_by => l_unique_key_column_tbl(l_index).last_updated_by,
		p_last_update_date => l_unique_key_column_tbl(l_index).last_update_date,
		p_last_update_login => l_unique_key_column_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	              p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if l_user_id1 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_KEY_PVT.CREATE_UNIQUE_KEY_COLUMN (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_unique_key_name =>
                           l_unique_key_column_tbl(l_index).unique_key_name,
            p_attribute_application_id =>
                l_unique_key_column_tbl(l_index).attribute_application_id,
            p_attribute_code =>
                l_unique_key_column_tbl(l_index).attribute_code,
            p_unique_key_sequence =>
                        l_unique_key_column_tbl(l_index).unique_key_sequence,
            p_attribute_category => l_unique_key_column_tbl(l_index).attribute_category,
			p_attribute1 => l_unique_key_column_tbl(l_index).attribute1,
			p_attribute2 => l_unique_key_column_tbl(l_index).attribute2,
			p_attribute3 => l_unique_key_column_tbl(l_index).attribute3,
			p_attribute4 => l_unique_key_column_tbl(l_index).attribute4,
			p_attribute5 => l_unique_key_column_tbl(l_index).attribute5,
			p_attribute6 => l_unique_key_column_tbl(l_index).attribute6,
			p_attribute7 => l_unique_key_column_tbl(l_index).attribute7,
			p_attribute8 => l_unique_key_column_tbl(l_index).attribute8,
			p_attribute9 => l_unique_key_column_tbl(l_index).attribute9,
			p_attribute10 => l_unique_key_column_tbl(l_index).attribute10,
			p_attribute11 => l_unique_key_column_tbl(l_index).attribute11,
			p_attribute12 => l_unique_key_column_tbl(l_index).attribute12,
			p_attribute13 => l_unique_key_column_tbl(l_index).attribute13,
			p_attribute14 => l_unique_key_column_tbl(l_index).attribute14,
			p_attribute15 => l_unique_key_column_tbl(l_index).attribute15,
		p_created_by => l_unique_key_column_tbl(l_index).created_by,
		p_creation_date => l_unique_key_column_tbl(l_index).creation_date,
		p_last_updated_by => l_unique_key_column_tbl(l_index).last_updated_by,
		p_last_update_date => l_unique_key_column_tbl(l_index).last_update_date,
		p_last_update_login => l_unique_key_column_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if UNIQUE_KEY_COLUMN_EXISTS */
	    --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  AK_OBJECT2_PVT.G_UNIQUE_KEY_COL_REDO_INDEX := AK_OBJECT2_PVT.G_UNIQUE_KEY_COL_REDO_INDEX + 1;
		  AK_OBJECT2_PVT.G_UNIQUE_KEY_COL_REDO_TBL(AK_OBJECT2_PVT.G_UNIQUE_KEY_COL_REDO_INDEX) := l_unique_key_column_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if;
	  --dbms_output.put_line('Bottom of for loop');
    end loop;
  end if;

  --
  -- Insert or update all foreign keys to the database
  --
  if (l_foreign_key_tbl.count > 0) then
    for l_index in l_foreign_key_tbl.FIRST .. l_foreign_key_tbl.LAST loop
      if (l_foreign_key_tbl.exists(l_index)) then
        if  AK_KEY_PVT.FOREIGN_KEY_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_foreign_key_name =>
                           l_foreign_key_tbl(l_index).foreign_key_name) then
          --
		  -- Update Foreign Keys only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_KEY_PVT.UPDATE_FOREIGN_KEY (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_foreign_key_name =>
                             l_foreign_key_tbl(l_index).foreign_key_name,
              p_database_object_name =>
                             l_foreign_key_tbl(l_index).database_object_name,
              p_unique_key_name =>
                             l_foreign_key_tbl(l_index).unique_key_name,
              p_application_id => l_foreign_key_tbl(l_index).application_id,
              p_attribute_category => l_foreign_key_tbl(l_index).attribute_category,
			  p_attribute1 => l_foreign_key_tbl(l_index).attribute1,
			  p_attribute2 => l_foreign_key_tbl(l_index).attribute2,
			  p_attribute3 => l_foreign_key_tbl(l_index).attribute3,
			  p_attribute4 => l_foreign_key_tbl(l_index).attribute4,
			  p_attribute5 => l_foreign_key_tbl(l_index).attribute5,
			  p_attribute6 => l_foreign_key_tbl(l_index).attribute6,
			  p_attribute7 => l_foreign_key_tbl(l_index).attribute7,
			  p_attribute8 => l_foreign_key_tbl(l_index).attribute8,
			  p_attribute9 => l_foreign_key_tbl(l_index).attribute9,
			  p_attribute10 => l_foreign_key_tbl(l_index).attribute10,
			  p_attribute11 => l_foreign_key_tbl(l_index).attribute11,
			  p_attribute12 => l_foreign_key_tbl(l_index).attribute12,
			  p_attribute13 => l_foreign_key_tbl(l_index).attribute13,
			  p_attribute14 => l_foreign_key_tbl(l_index).attribute14,
			  p_attribute15 => l_foreign_key_tbl(l_index).attribute15,
              p_from_to_name => l_foreign_key_tbl(l_index).from_to_name,
              p_from_to_description =>
                             l_foreign_key_tbl(l_index).from_to_description,
              p_to_from_name => l_foreign_key_tbl(l_index).to_from_name,
              p_to_from_description =>
                             l_foreign_key_tbl(l_index).to_from_description,
		p_created_by => l_foreign_key_tbl(l_index).created_by,
		p_creation_date => l_foreign_key_tbl(l_index).creation_date,
		p_last_updated_by => l_foreign_key_tbl(l_index).last_updated_by,
		p_last_update_date => l_foreign_key_tbl(l_index).last_update_date,
		p_last_update_login => l_foreign_key_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
 	          p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
			--
			-- Delete all children records in AK_FOREIGN_KEY_COLUMNS so
			-- that obsolete columns would not exist after upload.

            AK_KEY_PVT.DELETE_RELATED_FOREIGN_KEY_COL (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_foreign_key_name =>
                             l_foreign_key_tbl(l_index).foreign_key_name
			);
		  -- update non-customized data only
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
		    select afk.last_updated_by, afkt.last_updated_by,
			afk.last_update_date, afkt.last_update_date
			into l_user_id1, l_user_id2, l_update1, l_update2
			from ak_foreign_keys afk, ak_foreign_keys_tl afkt
			where afk.foreign_key_name = l_foreign_key_tbl(l_index).foreign_key_name
			and afk.foreign_key_name = afkt.foreign_key_name
			and afkt.language = userenv('LANG');
			/*if (( l_user_id1 = 1 or l_user_id1 = 2 ) and
				(l_user_id2 = 1 or l_user_id2 = 2)) then*/
                if (AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_foreign_key_tbl(l_index).created_by,
                      p_creation_date => l_foreign_key_tbl(l_index).creation_date,
                      p_last_updated_by => l_foreign_key_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_foreign_key_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_foreign_key_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') and

                   AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_foreign_key_tbl(l_index).created_by,
                      p_creation_date => l_foreign_key_tbl(l_index).creation_date,
                      p_last_updated_by => l_foreign_key_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id2,
                      p_last_update_date => l_foreign_key_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update2,
                      p_last_update_login => l_foreign_key_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE')) then

	            AK_KEY_PVT.UPDATE_FOREIGN_KEY (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_foreign_key_name =>
	                             l_foreign_key_tbl(l_index).foreign_key_name,
	              p_database_object_name =>
	                             l_foreign_key_tbl(l_index).database_object_name,
	              p_unique_key_name =>
	                             l_foreign_key_tbl(l_index).unique_key_name,
	              p_application_id => l_foreign_key_tbl(l_index).application_id,
	              p_attribute_category => l_foreign_key_tbl(l_index).attribute_category,
				  p_attribute1 => l_foreign_key_tbl(l_index).attribute1,
				  p_attribute2 => l_foreign_key_tbl(l_index).attribute2,
				  p_attribute3 => l_foreign_key_tbl(l_index).attribute3,
				  p_attribute4 => l_foreign_key_tbl(l_index).attribute4,
				  p_attribute5 => l_foreign_key_tbl(l_index).attribute5,
				  p_attribute6 => l_foreign_key_tbl(l_index).attribute6,
				  p_attribute7 => l_foreign_key_tbl(l_index).attribute7,
				  p_attribute8 => l_foreign_key_tbl(l_index).attribute8,
				  p_attribute9 => l_foreign_key_tbl(l_index).attribute9,
				  p_attribute10 => l_foreign_key_tbl(l_index).attribute10,
				  p_attribute11 => l_foreign_key_tbl(l_index).attribute11,
				  p_attribute12 => l_foreign_key_tbl(l_index).attribute12,
				  p_attribute13 => l_foreign_key_tbl(l_index).attribute13,
				  p_attribute14 => l_foreign_key_tbl(l_index).attribute14,
				  p_attribute15 => l_foreign_key_tbl(l_index).attribute15,
	              p_from_to_name => l_foreign_key_tbl(l_index).from_to_name,
	              p_from_to_description =>
	                             l_foreign_key_tbl(l_index).from_to_description,
	              p_to_from_name => l_foreign_key_tbl(l_index).to_from_name,
	              p_to_from_description =>
	                             l_foreign_key_tbl(l_index).to_from_description,
		p_created_by => l_foreign_key_tbl(l_index).created_by,
		p_creation_date => l_foreign_key_tbl(l_index).creation_date,
		p_last_updated_by => l_foreign_key_tbl(l_index).lasT_updated_by,
		p_last_update_date => l_foreign_key_tbl(l_index).last_update_date,
		p_last_update_login => l_foreign_key_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	 	          p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
				--
				-- Delete all children records in AK_FOREIGN_KEY_COLUMNS so
				-- that obsolete columns would not exist after upload.

	            AK_KEY_PVT.DELETE_RELATED_FOREIGN_KEY_COL (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_foreign_key_name =>
	                             l_foreign_key_tbl(l_index).foreign_key_name
				);
			end if; -- /* if l_user_id1 = 1 and l_user_id2 = 1 */
          end if; -- /* G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_KEY_PVT.CREATE_FOREIGN_KEY (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_foreign_key_name =>
                           l_foreign_key_tbl(l_index).foreign_key_name,
            p_database_object_name =>
                           l_foreign_key_tbl(l_index).database_object_name,
            p_unique_key_name =>
                           l_foreign_key_tbl(l_index).unique_key_name,
            p_application_id => l_foreign_key_tbl(l_index).application_id,
            p_attribute_category => l_foreign_key_tbl(l_index).attribute_category,
			p_attribute1 => l_foreign_key_tbl(l_index).attribute1,
			p_attribute2 => l_foreign_key_tbl(l_index).attribute2,
			p_attribute3 => l_foreign_key_tbl(l_index).attribute3,
			p_attribute4 => l_foreign_key_tbl(l_index).attribute4,
			p_attribute5 => l_foreign_key_tbl(l_index).attribute5,
			p_attribute6 => l_foreign_key_tbl(l_index).attribute6,
			p_attribute7 => l_foreign_key_tbl(l_index).attribute7,
			p_attribute8 => l_foreign_key_tbl(l_index).attribute8,
			p_attribute9 => l_foreign_key_tbl(l_index).attribute9,
			p_attribute10 => l_foreign_key_tbl(l_index).attribute10,
			p_attribute11 => l_foreign_key_tbl(l_index).attribute11,
			p_attribute12 => l_foreign_key_tbl(l_index).attribute12,
			p_attribute13 => l_foreign_key_tbl(l_index).attribute13,
			p_attribute14 => l_foreign_key_tbl(l_index).attribute14,
			p_attribute15 => l_foreign_key_tbl(l_index).attribute15,
            p_from_to_name => l_foreign_key_tbl(l_index).from_to_name,
            p_from_to_description =>
                           l_foreign_key_tbl(l_index).from_to_description,
            p_to_from_name => l_foreign_key_tbl(l_index).to_from_name,
            p_to_from_description =>
                           l_foreign_key_tbl(l_index).to_from_description,
	p_created_by => l_foreign_key_tbl(l_index).created_by,
	p_creation_date => l_foreign_key_tbl(l_index).creation_date,
	p_last_updated_by => l_foreign_key_tbl(l_index).last_updated_by,
	p_last_update_date => l_foreign_key_tbl(l_index).last_update_date,
	p_last_update_login => l_foreign_key_tbl(l_index).lasT_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if FOREIGN_KEY_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  AK_OBJECT2_PVT.G_FOREIGN_KEY_REDO_INDEX := AK_OBJECT2_PVT.G_FOREIGN_KEY_REDO_INDEX + 1;
		  AK_OBJECT2_PVT.G_FOREIGN_KEY_REDO_TBL(AK_OBJECT2_PVT.G_FOREIGN_KEY_REDO_INDEX) := l_foreign_key_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;

  --
  -- Insert or update all foreign key columns to the database
  --
  if (l_foreign_key_column_tbl.count > 0) then
    for l_index in l_foreign_key_column_tbl.FIRST .. l_foreign_key_column_tbl.LAST loop
      if (l_foreign_key_column_tbl.exists(l_index)) then
        if  AK_KEY_PVT.FOREIGN_KEY_COLUMN_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_foreign_key_name =>
                           l_foreign_key_column_tbl(l_index).foreign_key_name,
            p_attribute_application_id =>
                l_foreign_key_column_tbl(l_index).attribute_application_id,
            p_attribute_code =>
                l_foreign_key_column_tbl(l_index).attribute_code) then
          --
		  -- Update Foreign Key Columns only if G_UPDATE_MODE is TRUE
		  --
		  if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_KEY_PVT.UPDATE_FOREIGN_KEY_COLUMN (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_foreign_key_name =>
                             l_foreign_key_column_tbl(l_index).foreign_key_name,
              p_attribute_application_id =>
                  l_foreign_key_column_tbl(l_index).attribute_application_id,
              p_attribute_code =>
                  l_foreign_key_column_tbl(l_index).attribute_code,
              p_foreign_key_sequence =>
                          l_foreign_key_column_tbl(l_index).foreign_key_sequence,
              p_attribute_category => l_foreign_key_column_tbl(l_index).attribute_category,
			  p_attribute1 => l_foreign_key_column_tbl(l_index).attribute1,
			  p_attribute2 => l_foreign_key_column_tbl(l_index).attribute2,
			  p_attribute3 => l_foreign_key_column_tbl(l_index).attribute3,
			  p_attribute4 => l_foreign_key_column_tbl(l_index).attribute4,
			  p_attribute5 => l_foreign_key_column_tbl(l_index).attribute5,
			  p_attribute6 => l_foreign_key_column_tbl(l_index).attribute6,
			  p_attribute7 => l_foreign_key_column_tbl(l_index).attribute7,
			  p_attribute8 => l_foreign_key_column_tbl(l_index).attribute8,
			  p_attribute9 => l_foreign_key_column_tbl(l_index).attribute9,
			  p_attribute10 => l_foreign_key_column_tbl(l_index).attribute10,
			  p_attribute11 => l_foreign_key_column_tbl(l_index).attribute11,
			  p_attribute12 => l_foreign_key_column_tbl(l_index).attribute12,
			  p_attribute13 => l_foreign_key_column_tbl(l_index).attribute13,
			  p_attribute14 => l_foreign_key_column_tbl(l_index).attribute14,
			  p_attribute15 => l_foreign_key_column_tbl(l_index).attribute15,
		p_created_by => l_foreign_key_column_tbl(l_index).created_by,
		p_creation_date => l_foreign_key_column_tbl(l_index).creation_date,
		p_last_updated_by => l_foreign_key_column_tbl(l_index).last_updated_by,
		p_last_update_date => l_foreign_key_column_tbl(l_index).last_update_date,
		p_last_update_login => l_foreign_key_column_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
	          p_pass => p_pass,
              p_copy_redo_flag => l_copy_redo_flag
            );
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
		  -- update non-customized data only
		  --
			select last_updated_by, last_update_date
			into l_user_id1, l_update1
			from ak_foreign_key_columns
			where foreign_key_name = l_foreign_key_column_tbl(l_index).foreign_key_name
			and attribute_code = l_foreign_key_column_tbl(l_index).attribute_code
			and attribute_application_id = l_foreign_key_column_tbl(l_index).attribute_application_id;
			/*if ( l_user_id1 = 1 or l_user_id1 = 2) then*/
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_foreign_key_column_tbl(l_index).created_by,
                      p_creation_date => l_foreign_key_column_tbl(l_index).creation_date,
                      p_last_updated_by => l_foreign_key_column_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_foreign_key_column_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_foreign_key_column_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_KEY_PVT.UPDATE_FOREIGN_KEY_COLUMN (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_foreign_key_name =>
	                             l_foreign_key_column_tbl(l_index).foreign_key_name,
	              p_attribute_application_id =>
	                  l_foreign_key_column_tbl(l_index).attribute_application_id,
	              p_attribute_code =>
	                  l_foreign_key_column_tbl(l_index).attribute_code,
	              p_foreign_key_sequence =>
	                          l_foreign_key_column_tbl(l_index).foreign_key_sequence,
	              p_attribute_category => l_foreign_key_column_tbl(l_index).attribute_category,
				  p_attribute1 => l_foreign_key_column_tbl(l_index).attribute1,
				  p_attribute2 => l_foreign_key_column_tbl(l_index).attribute2,
				  p_attribute3 => l_foreign_key_column_tbl(l_index).attribute3,
				  p_attribute4 => l_foreign_key_column_tbl(l_index).attribute4,
				  p_attribute5 => l_foreign_key_column_tbl(l_index).attribute5,
				  p_attribute6 => l_foreign_key_column_tbl(l_index).attribute6,
				  p_attribute7 => l_foreign_key_column_tbl(l_index).attribute7,
				  p_attribute8 => l_foreign_key_column_tbl(l_index).attribute8,
				  p_attribute9 => l_foreign_key_column_tbl(l_index).attribute9,
				  p_attribute10 => l_foreign_key_column_tbl(l_index).attribute10,
				  p_attribute11 => l_foreign_key_column_tbl(l_index).attribute11,
				  p_attribute12 => l_foreign_key_column_tbl(l_index).attribute12,
				  p_attribute13 => l_foreign_key_column_tbl(l_index).attribute13,
				  p_attribute14 => l_foreign_key_column_tbl(l_index).attribute14,
				  p_attribute15 => l_foreign_key_column_tbl(l_index).attribute15,
		p_created_by => l_foreign_key_column_tbl(l_index).created_by,
		p_creation_date => l_foreign_key_column_tbl(l_index).creation_date,
		p_last_updated_by => l_foreign_key_column_tbl(l_index).last_updated_by,
		p_last_update_date => l_foreign_key_column_tbl(l_index).last_update_date,
		p_last_update_login => l_foreign_key_column_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
		          p_pass => p_pass,
	              p_copy_redo_flag => l_copy_redo_flag
	            );
			end if; -- /* if l_user_id1 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_KEY_PVT.CREATE_FOREIGN_KEY_COLUMN (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_foreign_key_name =>
                           l_foreign_key_column_tbl(l_index).foreign_key_name,
            p_attribute_application_id =>
                l_foreign_key_column_tbl(l_index).attribute_application_id,
            p_attribute_code =>
                l_foreign_key_column_tbl(l_index).attribute_code,
            p_foreign_key_sequence =>
                        l_foreign_key_column_tbl(l_index).foreign_key_sequence,
            p_attribute_category => l_foreign_key_column_tbl(l_index).attribute_category,
			p_attribute1 => l_foreign_key_column_tbl(l_index).attribute1,
			p_attribute2 => l_foreign_key_column_tbl(l_index).attribute2,
			p_attribute3 => l_foreign_key_column_tbl(l_index).attribute3,
			p_attribute4 => l_foreign_key_column_tbl(l_index).attribute4,
			p_attribute5 => l_foreign_key_column_tbl(l_index).attribute5,
			p_attribute6 => l_foreign_key_column_tbl(l_index).attribute6,
			p_attribute7 => l_foreign_key_column_tbl(l_index).attribute7,
			p_attribute8 => l_foreign_key_column_tbl(l_index).attribute8,
			p_attribute9 => l_foreign_key_column_tbl(l_index).attribute9,
			p_attribute10 => l_foreign_key_column_tbl(l_index).attribute10,
			p_attribute11 => l_foreign_key_column_tbl(l_index).attribute11,
			p_attribute12 => l_foreign_key_column_tbl(l_index).attribute12,
			p_attribute13 => l_foreign_key_column_tbl(l_index).attribute13,
			p_attribute14 => l_foreign_key_column_tbl(l_index).attribute14,
			p_attribute15 => l_foreign_key_column_tbl(l_index).attribute15,
		p_created_by => l_foreign_key_column_tbl(l_index).created_by,
		p_creation_date => l_foreign_key_column_tbl(l_index).creation_date,
		p_last_updated_by => l_foreign_key_column_tbl(l_index).last_updated_by,
		p_last_update_date => l_foreign_key_column_tbl(l_index).last_update_date,
		p_last_update_login => l_foreign_key_column_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
  		    p_pass => p_pass,
            p_copy_redo_flag => l_copy_redo_flag
          );
        end if; -- /* if FOREIGN_KEY_COLUMN_EXISTS */
		--
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  AK_OBJECT2_PVT.G_FOREIGN_KEY_COL_REDO_INDEX := AK_OBJECT2_PVT.G_FOREIGN_KEY_COL_REDO_INDEX + 1;
		  AK_OBJECT2_PVT.G_FOREIGN_KEY_COL_REDO_TBL(AK_OBJECT2_PVT.G_FOREIGN_KEY_COL_REDO_INDEX) := l_foreign_key_column_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
      end if;
    end loop;
  end if;
  --
  -- Load line number of the last file line processed
  --
  p_line_num_out := l_line_num;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- dbms_output.put_line('Leaving object upload: ' ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN VALUE_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AK','AK_OBJECT_VALUE_ERROR');
    FND_MESSAGE.SET_TOKEN('KEY',l_object_rec.database_object_name);
    FND_MSG_PUB.Add;
	FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240)||': '||l_column||'='||l_token );
	FND_MSG_PUB.Add;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	--dbms_output.put_line('UPLOAD_OBJECT l_line_num '||to_char(l_line_num));
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end UPLOAD_OBJECT;

end AK_OBJECT3_PVT;

/
